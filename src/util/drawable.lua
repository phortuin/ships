local Vector = require "src.lib.vector"
local util = require "src.util.util"

local drawable = {}

local SHADOW_OFFSET = 35

---@alias Entity {position: Vector, direction: Vector, sprite: unknown, shadow: unknown, size: number, x: number, y: number	}

-- Draw an entity
---@param entity Entity Can be a ship, a bullet, ...
---@param takingDamage boolean
---@return nil
function drawable.draw(entity, takingDamage)
	if takingDamage then
		drawable.drawCircle(entity)
	end
	love.graphics.draw(
		entity.sprite,
		entity.position.x,
		entity.position.y,
		entity.direction:angle(),
		2,
		2,
		entity.sprite:getWidth() / 2,
		entity.sprite:getHeight() / 2)
end

-- Draw an entity’s shadow
---@param entity Entity can be a ship, a bullet, ...
---@return nil
function drawable.drawShadow(entity)
	local position = Vector:new(entity.position.x, entity.position.y) -- Copy the entity’s position
	local center = Vector:new(VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT / 2) -- Create a vector for the canvas center, this is the 'light source' for our shadow
	position:sub(center)                                              -- Subtract center from entity’s position. Position can now be pos/neg in all quadrants; if not, the shadow will always render in the southeast quadrant
	position:normalize()                                              -- Normalize so that we can render it relative to the ship’s position instead of the center of the canvas
	local dist = entity.position:dist(center)                         -- Calculate the distance of the entity to the center of the canvas
	position:mult(dist / SHADOW_OFFSET)                               -- Multiply shadow’s position by entity’s distance to the center, divided by an offset modifier (larger offset = shadow is closer to the ship). This will render the shadow 'behind' the ship relative to the light source
	local shadowSize = util.clamp(dist / 120, 2.5, 8)                 -- Arbitrary numbers to make the shadow not too small, not too large
	love.graphics.setColor(1, 1, 1, util.clamp(50 / dist, 0.1, 0.25)) -- Let shadow’s opacity be fairly low, it gets dark fast
	love.graphics.draw(
		entity.shadow,
		entity.position.x + position.x,
		entity.position.y + position.y,
		entity.direction:angle(),
		shadowSize,
		shadowSize,
		entity.sprite:getWidth() / 2,
		entity.sprite:getHeight() / 2
	)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Draw a red translucent circle around an entity
---@param entity Entity
---@return nil
function drawable.drawCircle(entity)
	love.graphics.setColor(1, 0, 0, 0.4)
	love.graphics.circle(
		"fill",
		entity.position.x,
		entity.position.y,
		entity.sprite:getWidth() * 2
	)
	love.graphics.setColor(1, 1, 1, 1)
end

return drawable
