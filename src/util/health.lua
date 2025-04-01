---@class Health
---@field hp integer
---@field maxHp integer
---@field takingDamage boolean
local Health = {}
Health.__index = Health

-- Create a new Health instance
---@param hp integer
---@param maxHp integer
---@return Health
function Health:new(hp, maxHp)
	local health = {
		hp = hp or 0,
		maxHp = maxHp or 0,
		takingDamage = false,
	}
	setmetatable(health, Health)
	return health
end

-- Decrease health by damage. Sets the takingDamage flag to true
---@param damage integer
---@return nil
function Health:takeDamage(damage)
	self.hp = self.hp - damage
	self.takingDamage = true
end

-- Check if health is zero or below, meaning ur ded
---@return boolean
function Health:isDead()
	return self.hp <= 0
end

-- Draw a health bar over an entity (ship, in our case)
---@param entity table
---@return nil
function Health:drawBar(entity)
	local xOffset = -20
	local yOffset = -30
	local length = 40
	local width = 4
	love.graphics.setColor(0, 0, 0, 0.2)
	love.graphics.rectangle("fill",
		entity.position.x + xOffset,
		entity.position.y + yOffset,
		length,
		width)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill",
		entity.position.x + xOffset,
		entity.position.y + yOffset,
		self.hp / self.maxHp * length,
		width)
	love.graphics.setColor(1, 1, 1, 1)
end

return Health
