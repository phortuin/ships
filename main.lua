local moonshine = require "vendor.moonshine"

local Sticky = require "src.entities.sticky"
local Ship = require "src.entities.ship"
local Vector = require "src.lib.vector"

--[x] reverse thrust boost
--[ ] machine gun die overheat en dan weer moet afkoelen
--[ ] shield die je kan activeren (idee van de robot :D)
--[x] arrow die wijst waar je buiten beeld bent met een countdown; als je te lang buiten beeld bent dan ga je dood
--[x] arrow naar buiten beeld position moet ook echt een arrow zijn
--[ ] 'terrein' achtergrond
--[ ] areas met bijv water/ijs/vuur waar je doorheen moet die je schip vertragen of slopen
--[x] bouncy walls zodat je niet uit scherm gaat
--[x] beginnen in de hoeken in tegenovergestelde richting
--[ ] sturen moet incremental. dus je kan dan ook per 0.1 nudgen, en je max stuursnelheid is bijv 10 en heeft ook weer slowdown
--[ ] verschillende wapens die je kan switchen en oppakken en waar je sneller mee dood gaat
--[x] je kan een soort jump achteruit maken die moet refillen
--[ ] je moet rakketten kunnen ontwijken, de eerste keer dat je ontwijkt gaat hij nog achter je aan, de tweede keer niet meer (en dan moet je op enter drukken)
--[ ] thrusters renderen
--[ ] background een supersnelle 'starry sky' met een parallax effect (thanks, chatbot)
--[ ] outside pijltje steeds sneller laten knipperen als je te lang buiten screen bent

VIEWPORT_WIDTH = love.graphics.getWidth()
VIEWPORT_HEIGHT = love.graphics.getHeight()
START_POSITION_OFFSET = 50
THRUST = 0.1
STEER = 1

local sticky = Sticky:new()

local player1 = Ship:new(
	Vector:new(START_POSITION_OFFSET, START_POSITION_OFFSET),
	Vector:new(1, 1),
	"fender"
)
local player2 = Ship:new(
	Vector:new(VIEWPORT_WIDTH - START_POSITION_OFFSET, VIEWPORT_HEIGHT - START_POSITION_OFFSET),
	Vector:new(-1, -1),
	"rokkit"
)

love.graphics.setBackgroundColor(0.97, 0.97, 0.97)
local bg = love.graphics.newImage("assets/backgrounds/waves.png")

Effect = moonshine.chain(moonshine.effects.fastgaussianblur)
Effect.fastgaussianblur.sigma = 4

-- Draw repeating background pattern
---@return nil
local function drawBackground()
	local size = 3
	for i = 0, love.graphics.getWidth() / (bg:getWidth() * size) do
		for j = 0, love.graphics.getHeight() / (bg:getHeight() * size) do
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.draw(bg, i * bg:getWidth() * size, j * bg:getHeight() * size, 0, size, size)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then player1:fire() end
	if key == "down" then player1:jump() end
	if key == "3" then player2:fire() end
	if key == "s" then player2:jump() end
end

function love.update(dt)
	-- Player 1
	if love.keyboard.isDown("up") then
		player1:thrust(THRUST)
	else
		player1:slowDown()
	end
	if love.keyboard.isDown("right") then
		player1:steer(STEER)
	elseif love.keyboard.isDown("left") then
		player1:steer(-1 * STEER)
	end

	-- Player 2
	if love.keyboard.isDown("w") then
		player2:thrust(THRUST)
	else
		player2:slowDown()
	end
	if love.keyboard.isDown("d") then
		player2:steer(STEER)
	elseif love.keyboard.isDown("a") then
		player2:steer(-1 * STEER)
	end

	-- Update players
	player1:update(dt)
	player2:update(dt)

	-- Player 1 hit!
	if player1:getsHit(player2.bullets) then
		if player1.health:isDead() then
			player2.score = player2.score + 1
			player1:respawn()
		end
	end

	-- Player 2 hit!
	if player2:getsHit(player1.bullets) then
		if player2.health:isDead() then
			player1.score = player1.score + 1
			player2:respawn()
		end
	end

	-- Update sticky; PoC for homing rocket
	sticky:update(player1)
end

function love.draw()
	-- Draw shadows inside a moonshine effect (blur)
	Effect.draw(function()
		player1:drawShadow()
		player2:drawShadow()
	end)

	-- Draw other stuff
	drawBackground()
	sticky:draw()
	player1:draw()
	player2:draw()
end
