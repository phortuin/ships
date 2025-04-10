---@class Vector
---@field x number
---@field y number
local Vector = {}
Vector.__index = Vector

-- For some excellent examples and documentation on what vectors are and however
-- to use them, see https://natureofcode.com/vectors/
-- An excellent reference for common Vector
-- functions is: https://p5js.org/reference/p5/p5.Vector/

-- Initialize a new vector.
---@param x? number | table If x is a table, assume it’s a Vector and unpack it
---@param y? number
---@return Vector
function Vector:new(x, y)
	if type(x) == "table" then
		y = x.y
		x = x.x
	end
	local vector = {
		x = x or 0,
		y = y or 0,
	}
	setmetatable(vector, Vector)
	return vector
end

-- Add vector to current vector (inverse of Vector:sub)
-- @param other Vector
-- @return nil
function Vector:add(other)
	self.x = self.x + other.x
	self.y = self.y + other.y
end

-- Calculate the arc tangent of a vector (in radians)
---@return number
function Vector:angle()
	return math.atan2(self.y, self.x)
end

-- Divides current vector by scalar. Can be used to make the vector smaller,
-- eg. to normalize it. Inverse of Vector:mult
---@param scalar number
---@return nil
function Vector:div(scalar)
	if scalar == 0 then return self end
	self.x = self.x / scalar
	self.y = self.y / scalar
end

-- Calculates the distance between two vectors
---@param other Vector
---@return number
function Vector:dist(other)
	local m = Vector:new(self.x, self.y)
	m:sub(other)
	return m:mag()
end

-- Limit the magnitude (length) of the vector to a maximum value
---@param max integer
---@return nil
function Vector:limit(max)
	if self:mag() > max then
		self:normalize()
		self:mult(max)
	end
end

-- Calculate the magnitude (length) of the vector
---@return number
function Vector:mag()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

-- Multiply current vector by scalar value. Can be used to scale the vector
-- (make it longer or shorter; in combination with normalize you can redefine
-- the magnitude of the vector). Inverse of Vector:div
---@param scalar number
---@return nil
function Vector:mult(scalar)
	self.x = self.x * scalar
	self.y = self.y * scalar
end

-- Normalize the vector (make it a unit vector). This will set the vector’s
-- magnitude to 1
---@return nil
function Vector:normalize()
	local m = self:mag()
	if m > 0 then
		self:div(m)
	end
end

-- Rotate the vector by an angle (in degrees)
---@param angle number
---@return nil
function Vector:rotate(angle)
	local x = self.x
	local y = self.y
	local rad = math.rad(angle)
	self.x = x * math.cos(rad) - y * math.sin(rad)
	self.y = x * math.sin(rad) + y * math.cos(rad)
end

-- Subtract vector from current vector (inverse of Vector:add)
---@param other Vector
---@return nil
function Vector:sub(other)
	self.x = self.x - other.x
	self.y = self.y - other.y
end

return Vector
