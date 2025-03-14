local Vector = require "src.lib.vector"

local Mover = {}
Mover.__index = Mover

-- position, velocity, acceleration are vectors
-- @see https://natureofcode.com/forces/
function Mover:new()
	local mover = {
		position = Vector:new(400, 30),
		velocity = Vector:new(),
		acceleration = Vector:new(),
		mass = 10,
	}
	setmetatable(mover, Mover)
	return mover
end

function Mover:applyForce(force --[[ Vector ]])
	local f = Vector:new(force.x, force.y)
	f:div(self.mass)
	self.acceleration:add(f)
end

function Mover:update()
	self.velocity:add(self.acceleration)
	self.position:add(self.velocity)
	self.acceleration:multiply(0)
end

function Mover:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle("fill", self.position.x, self.position.y, self.mass)
end

function Mover:checkEdges()
	if self.position.x > 800 then
		self.position.x = 800
		self.velocity.x = self.velocity.x * -1
	elseif self.position.x < 0 then
		self.position.x = 0
		self.velocity.x = self.velocity.x * -1
	end
	if self.position.y > 600 then
		self.velocity.y = self.velocity.y * -1
		self.position.y = 600
	end
end

return Mover
