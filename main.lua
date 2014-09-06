--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"

function love.load()

	spaceship = love.graphics.newImage("assets/spaceship96x96.png")
	rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
	groundImage = love.graphics.newImage("assets/ground_0.png")
	groundY = love.graphics:getHeight() - groundImage:getHeight()

	x = 350
	y = 473
	angle = 0
	speed = 300
	angular_speed = 1
	love.graphics.setBackgroundColor(126, 192, 238)
	scoreDisplayRoot = "Score: "
	scoreDisplay = "Score: 0"

	scoreX = 50
	scoreY = 50

	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	rocketforce = -5000
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = body:getY()
	maxHeight = 0
   	currentHeight = 0
	shape = love.physics.newRectangleShape(spaceship:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.

	ground = {}
	ground.body = love.physics.newBody(world, 0, groundY) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(groundImage:getDimensions()) --make a rectangle with a width of 650 and a height of 50
	ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
end

function love.update(dt)
	world:update(dt)
	--local forceVec = Vec2.fromAngle(body:getAngle) * rocketforce
	--local rightLocationVec = Vec2(body:getX, body:getY)
	--local 
	if love.keyboard.isDown("up") then
		body:applyForce(0, rocketforce)
	end

	currentHeight = startY - body:getY()
	if currentHeight > maxHeight then
		maxHeight = currentHeight
		scoreDisplay = scoreDisplayRoot .. math.floor(maxHeight)
	end
end

local v = Vec2(0.0, 3.0)
local multiplied_v = v * 3

function love.draw()
   displayScore()
   -- if current height below the first camera change
   love.graphics.draw(groundImage, 0, groundY)
   love.graphics.draw(spaceship,body:getX(),body:getY(),body:getAngle(),1,1,spaceship:getDimensions() / 2)
end

function displayScore()
	love.graphics.print(scoreDisplay, scoreX, scoreY)
	love.graphics.print("maxHeight: "..maxHeight, scoreX, scoreY + 100)
	love.graphics.print("currentHeight: "..currentHeight, scoreX, scoreY + 200)
end