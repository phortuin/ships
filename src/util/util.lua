local util = {}

-- Clamp a value between a lower and upper bound, meaning the value will never
-- be over or under the bounds
---@param value number
---@param lower number
---@param upper number
---@return number
function util.clamp(value, lower, upper)
	if value > upper then return upper end
	if value < lower then return lower end
	return value
end

-- Wrap a value between a lower and upper bound, meaning the value will Wrap
-- around (when over upper bound, will set to lower bound and vice versa)
---@param value number
---@param lower number
---@param upper number
---@return number
function util.wrap(value, lower, upper)
	if value > upper then return lower end
	if value < lower then return upper end
	return value
end

-- Check if position Vector is outside the viewport
---@param position Vector
---@return boolean
function util.outsideBounds(position)
	if position.x < 0 or position.x > VIEWPORT_WIDTH then return true end
	if position.y < 0 or position.y > VIEWPORT_HEIGHT then return true end
	return false
end

-- Check if a Vector is outside the viewport and make it bounce by
-- inverting the velocity Vector. Return true or false if the Vector
-- did 'bounce'
---@param position Vector
---@param velocity Vector
---@return boolean
function util.bounceEdges(position, velocity)
	local bounces = false

	-- Bounce horizontally
	if position.x > VIEWPORT_WIDTH or position.x < 0 then
		velocity.x = velocity.x * -1
		bounces = true
	end

	-- Bounce vertically
	if position.y > VIEWPORT_HEIGHT or position.y < 0 then
		velocity.y = velocity.y * -1
		bounces = true
	end

	position.x = util.clamp(position.x, 0, VIEWPORT_WIDTH)
	position.y = util.clamp(position.y, 0, VIEWPORT_HEIGHT)

	return bounces
end

return util
