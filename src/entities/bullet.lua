local Vector = require "src.lib.vector"
local drawable = require "src.util.drawable"
local util = require "src.util.util"

---@class Bullet
---@field position Vector
---@field direction Vector
---@field velocity Vector
---@field sprite unknown Love sprite
---@field shadow unknown Love sprite
---@field hitEdge number Counter for how many times the bullet has hit the edge of the screen
local Bullet = {}
Bullet.__index = Bullet

local BULLET_SPEED = 8;

-- Create a new bullet
---@param position Vector
---@param direction Vector
---@param velocity Vector
---@return Bullet
function Bullet:new(position, direction, velocity)
	local bullet = {
		position = position,
		direction = direction,
		velocity = velocity,
		sprite = love.graphics.newImage("assets/sprites/bullet.png"),
		shadow = love.graphics.newImage("assets/sprites/bullet-shadow.png"),
		hitEdgeCounter = 0
	}

	local f = Vector:new(bullet.direction.x, bullet.direction.y)
	f:mult(BULLET_SPEED)
	bullet.velocity:add(f)

	setmetatable(bullet, Bullet)
	return bullet
end

-- Update the bullet's position
---@return nil
function Bullet:update()
	self.position:add(self.velocity)
	self:bounceEdges()
end

-- Draw the bullet
---@return nil
function Bullet:draw()
	drawable.draw(self, 1, false)
end

-- Draw the bullet's shadow
---@return nil
function Bullet:drawShadow()
	drawable.drawShadow(self)
end

-- Check if the bullet has hit the edge of the screen. Make sure it stays
-- within bounds, and invert velocity when it hits the edge. A counter is used
-- to track how many times the bullet has hit the edge.
---@return nil
function Bullet:bounceEdges()
	if (util.bounceEdges(self.position, self.velocity)) then
		self.hitEdgeCounter = self.hitEdgeCounter + 1
	end
end

return Bullet
