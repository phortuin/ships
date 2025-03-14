local Mover = require "src.entities.mover"
local Vector = require "src.lib.vector"

local ball = Mover:new()
local wind = Vector:new(1, 0)
local gravity = Vector:new(0, 1)

function love.update(dt)
	if love.mouse.isDown(1) then
		-- wind!
		ball:applyForce(wind)
	end
	ball:applyForce(gravity)
	ball:update()
	ball:checkEdges()
end

function love.draw()
	ball:draw()
end
