--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	uprocketforce = 2000
	rocketforce = 2000
	image = love.graphics.newImage("spaceship96x96.png")
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	body:setAngularDamping(0.05)
	body:setInertia(40000)
	body:setAngle(-math.pi/2)
	shape = love.physics.newRectangleShape(image:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.
end

function love.update(dt)
	world:update(dt)
	if love.keyboard.isDown("left") then
		local leftRocketOffsetX = -image:getWidth() / 2;
		local leftRocketOffsetY = image:getHeight() / 2;  
		body:applyForce(rocketforce * math.cos(body:getAngle()), -rocketforce * math.sin(body:getAngle()), body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if love.keyboard.isDown("right") then
		local rightRocketOffsetX = image:getWidth() / 2;
		local rightRocketOffsetY = image:getHeight() / 2;  
		body:applyForce(rocketforce * math.cos(body:getAngle()), -rocketforce * math.sin(body:getAngle()), body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY))
	end
end

local v = Vec2(0.0, 3.0)
local multiplied_v = v * 3

function love.draw()
	love.graphics.draw(image,body:getX(),body:getY(),body:getAngle() + math.pi/2,1,1,image:getDimensions() / 2)

end