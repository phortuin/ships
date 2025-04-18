local Vector = require "src.lib.vector"

local drawable = require "src.util.drawable"
local util = require "src.util.util"

local Health = require "src.util.health"
local Bullet = require "src.entities.bullet"

---@class Ship
---@field position Vector
---@field spawnPosition Vector
---@field velocity Vector
---@field acceleration Vector
---@field direction Vector
---@field spawnDirection Vector
---@field sprite table
---@field shadow table
---@field health Health
---@field score number
---@field isOutsideScreen boolean
---@field outsideScreenCounter number
---@field isJumping boolean
---@field jumpingCounter number
---@field bullets table<Bullet>
local Ship = {}
Ship.__index = Ship

VIEWPORT_WIDTH = love.graphics.getWidth()
VIEWPORT_HEIGHT = love.graphics.getHeight()

EDGE_DAMAGE = 0
JUMP_RESET_AFTER = 0.5
BULLET_BOUNCE_TIMES = 3
RESPAWN_AFTER = 5
HP = 3

-- Create a new Ship
---@param position Vector
---@param direction Vector
---@param sprite string
---@return Ship
function Ship:new(position, direction, sprite)
	local ship = {
		position = position,
		spawnPosition = Vector:new(position),
		velocity = Vector:new(),
		acceleration = Vector:new(),
		direction = direction,
		spawnDirection = Vector:new(direction),
		sprite = love.graphics.newImage(string.format("assets/sprites/%s.png", sprite)),
		shadow = love.graphics.newImage(string.format("assets/sprites/%s-shadow.png", sprite)),
		health = Health:new(HP, HP),
		score = 0,
		isOutsideScreen = false,
		outsideScreenCounter = 0,
		isJumping = false,
		jumpingCounter = 0,
		bullets = {}
	}

	setmetatable(ship, Ship)
	return ship
end

-- Thrust the ship into the direction it’s facing. Thrust should be a low number
-- (eg. 0.1) otherwise the ship accelerates too fast
---@param thrust number
---@return nil
function Ship:thrust(thrust)
	local f = Vector:new(self.direction)
	f:mult(thrust)
	self.velocity:add(f)
end

-- Steer the ship left (-1) or right (1)
---@param direction number [-1, 1]
---@return nil
function Ship:steer(direction)
	local angle = Vector:new(self.direction)
	angle:rotate(direction * 4)
	self.direction = angle
end

-- Makes a 'jump', meaning a short burst of thrust. State is remembered so
-- the player can’t jump all the time
---@return nil
function Ship:jump()
	if not self.isJumping then
		self:thrust(-5)
		self.isJumping = true
	end
end

-- Reduces the ship’s velocity
---@return nil
function Ship:slowDown()
	self.velocity:mult(0.97)
end

-- Fires a bullet
---@return nil
function Ship:fire()
	local p = Vector:new(self.position)
	local d = Vector:new(self.direction)
	local v = Vector:new(self.velocity)
	table.insert(self.bullets, Bullet:new(p, d, v))
end

-- Check if ship gets hit
---@param bullets table<Bullet>
---@return boolean
function Ship:getsHit(bullets)
	local hit = false
	for i, bullet in ipairs(bullets) do
		if self.position.x < bullet.position.x + 10 and
				self.position.x + 10 > bullet.position.x and
				self.position.y < bullet.position.y + 10 and
				self.position.y + 10 > bullet.position.y then
			self.health:takeDamage(0.4)
			table.remove(bullets, i)
			hit = true
		end
	end
	return hit
end

-- Check if ship is outside viewport
---@param dt number delta time, from love:update
---@return nil
function Ship:checkOutsideScreen(dt)
	if util.outsideBounds(self.position) then
		self.isOutsideScreen = true
		self.outsideScreenCounter = self.outsideScreenCounter + dt
		if self.outsideScreenCounter > RESPAWN_AFTER then
			self:respawn()
		end
	else
		self.isOutsideScreen = false
		self.outsideScreenCounter = 0
	end
end

-- Check if the ship has hit the edge of the screen. Make sure it stays
-- within bounds, and invert velocity when it hits the edge. The ship may
-- take damage if so configured
---@return nil
function Ship:bounceEdges()
	if (util.bounceEdges(self.position, self.velocity) and EDGE_DAMAGE > 0) then
		self.health:takeDamage(EDGE_DAMAGE)
	end
end

-- Respwan the ship; set various modifiers and position to their defaults
---@return nil
function Ship:respawn()
	self.position = Vector:new(self.spawnPosition)
	self.direction = Vector:new(self.spawnDirection)
	self.health = Health:new(HP, HP)
	self.acceleration = Vector:new()
	self.velocity = Vector:new()
	self.isOutsideScreen = false
	self.outsideScreenCounter = 0
	self.isJumping = false
	self.jumpingCounter = 0
end

-- Update ship before drawing
---@param dt number delta time, from love:update
---@return nil
function Ship:update(dt)
	self.velocity:add(self.acceleration)
	self.position:add(self.velocity)
	self.acceleration:mult(0) -- Reset acceleration to 0 so it doesn’t "auto" accelerate without user input

	-- self:checkOutsideScreen(dt) -- Ship can go outside viewport
	self:bounceEdges() -- Ship bounces within viewport

	if self.health:isDead() then
		self:respawn()
	end

	if self.isJumping then
		self.jumpingCounter = self.jumpingCounter + dt
		if self.jumpingCounter > JUMP_RESET_AFTER then
			self.isJumping = false
			self.jumpingCounter = 0
		end
	end

	-- Update bullets
	-- If they’ve reached their 'max edge hits', remove the bullet
	for i, bullet in ipairs(self.bullets) do
		bullet:update()
		if bullet.hitEdgeCounter > BULLET_BOUNCE_TIMES then
			table.remove(self.bullets, i)
		end
	end
end

-- Draw the ship and its bullets
---@return nil
function Ship:draw()
	for i, bullet in ipairs(self.bullets) do
		bullet:draw()
	end

	-- Draw the ship and it’s health bar
	drawable.draw(self, 1, self.health.takingDamage)
	self.health:drawBar(self)

	-- Draw score
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(self.score, self.spawnPosition.x, self.spawnPosition.y)
	love.graphics.setColor(1, 1, 1, 1)

	-- Draw stuff to track the ship outside the screen
	if self.isOutsideScreen then
		local arrowOffset = 20
		local textOffset = 40

		local arrowX = util.clamp(self.position.x, arrowOffset, VIEWPORT_WIDTH - arrowOffset)
		local arrowY = util.clamp(self.position.y, arrowOffset, VIEWPORT_HEIGHT - arrowOffset)
		love.graphics.setColor(1, 0, 0, 1)

		local printOffsetX = util.clamp(arrowX, textOffset, VIEWPORT_WIDTH - textOffset)
		local printOffsetY = util.clamp(arrowY, textOffset, VIEWPORT_HEIGHT - textOffset)

		love.graphics.circle("fill", arrowX, arrowY, 5)
		local timer = string.format("[%.2f]", 5 - self.outsideScreenCounter)
		love.graphics.print(timer, printOffsetX - 9,
			printOffsetY - 8)
		love.graphics.setColor(1, 1, 1, 1)
	end

	-- Reset takingDamage state after being drawn
	self.health.takingDamage = false
end

-- Draw the ship’s shadow and its bullet’s shadowses
---@return nil
function Ship:drawShadow()
	drawable.drawShadow(self)
	for i, bullet in ipairs(self.bullets) do
		bullet:drawShadow()
	end
end

return Ship
