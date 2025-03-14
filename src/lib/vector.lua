local Vector = {}
Vector.__index = Vector

function Vector:new(x, y)
	local vector = {
		x = x or 0,
		y = y or 0,
	}
	setmetatable(vector, Vector)
	return vector
end

function Vector:magnitude()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:add(other --[[ other: Vector ]])
	self.x = self.x + other.x
	self.y = self.y + other.y
end

function Vector:multiply(scalar --[[ int ]])
	self.x = self.x * scalar
	self.y = self.y * scalar
end

function Vector:div(scalar --[[ int ]])
	if scalar == 0 then return self end
	self.x = self.x / scalar
	self.y = self.y / scalar
end

return Vector
