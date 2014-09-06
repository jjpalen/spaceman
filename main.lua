--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	rocketforce = -5000
	image = love.graphics.newImage("spaceship96x96.png")
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	shape = love.physics.newRectangleShape(image:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.
end

function love.update(dt)
	world:update(dt)
	--local forceVec = Vec2.fromAngle(body:getAngle) * rocketforce
	--local rightLocationVec = Vec2(body:getX, body:getY)
	--local 
	if love.keyboard.isDown("up") then
		body:applyForce(0, rocketforce)

	end
end

local v = Vec2(0.0, 3.0)
local multiplied_v = v * 3

function love.draw()
	love.graphics.draw(image,body:getX(),body:getY(),body:getAngle(),1,1,image:getDimensions() / 2)

end