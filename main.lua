--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"
local scoreX = 50
local scoreY = 50

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	--world = love.physics.newWorld(0, 0, true)
	uprocketforce = 2000
	rocketforce = 1500
	image = love.graphics.newImage("spaceship96x96.png")
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	body:setAngularDamping(0.02)
	body:setInertia(40000)
	body:setAngle(-math.pi/2)
	shape = love.physics.newRectangleShape(image:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.
	ground = {}
	ground.body = love.physics.newBody(world, 0, 500) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(800, 32) --make a rectangle with a width of 650 and a height of 50
	ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
	rightOn = false
	leftOn = false
end

function love.update(dt)
	leftOn = false
	rightOn = false
	world:update(dt)
	if love.keyboard.isDown("left") then
		leftOn = true
		leftRocketOffsetX = -image:getWidth() / 2;
		leftRocketOffsetY = -image:getHeight() / 2;  
		body:applyForce(rocketforce * math.cos(body:getAngle()), rocketforce * math.sin(body:getAngle()), body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if love.keyboard.isDown("right") then
		rightOn = true
		rightRocketOffsetX = -image:getWidth() / 2;
		rightRocketOffsetY = image:getHeight() / 2;  
		body:applyForce(rocketforce * math.cos(body:getAngle()), rocketforce * math.sin(body:getAngle()), body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY ))
	end
end

local v = Vec2(0.0, 3.0)
local multiplied_v = v * 3

function love.draw()
	love.graphics.draw(image,body:getX(),body:getY(),body:getAngle() + math.pi/2,1,1,image:getDimensions() / 2)
	if rightOn then
		local worldX, worldY = body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	if leftOn then
		local worldX, worldY = body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end

	love.graphics.print("body angle: "..body:getAngle() * 180/math.pi, scoreX, scoreY)
end