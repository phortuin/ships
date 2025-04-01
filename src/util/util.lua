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

return util
