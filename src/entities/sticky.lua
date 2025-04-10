local Vector = require "src.lib.vector"

---@class Sticky
---@field position Vector
---@field velocity Vector
---@field acceleration Vector
local Sticky = {}
Sticky.__index = Sticky

local MASS = 5
local TOP_SPEED = 8;

-- Create a new Sticky
---@return Sticky
function Sticky:new()
	local sticky = {
		position = Vector:new(400, 300),
		velocity = Vector:new(),
		acceleration = Vector:new(),
	}
	setmetatable(sticky, Sticky)
	return sticky
end

-- Sticks to another Vector; in this case, the ship's position
---@param ship Ship
---@return nil
function Sticky:update(ship)
	local direction = Vector:new(ship.position.x, ship.position.y)
	direction:sub(self.position)
	direction:normalize()
	direction:mult(0.35) -- adds inertia; if set to 1, it will stick to the ship's position
	self.acceleration = direction
	self.velocity:add(self.acceleration)
	self.velocity:limit(TOP_SPEED)
	self.position:add(self.velocity)
end

-- Draw the sticky thing (a filled circle)
---@return nil
function Sticky:draw()
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.circle("fill", self.position.x, self.position.y, MASS)
	love.graphics.setColor(1, 1, 1, 1)
end

return Sticky
