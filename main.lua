--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"
require "camera"

local moveCamera = false
local moveCameraAmount = 0
local cameraMiddle = love.graphics:getHeight() / 2

local scoreDisplayRoot = "Score: "
local scoreDisplay = "Score: 0"

local startY
local maxHeight = 0
local currentHeight = 0

local scoreX = 50
local scoreY = 50

local rocketforce = -5000

local ground = {}
function love.load()

	spaceship = love.graphics.newImage("assets/spaceship96x96.png")
	rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
	groundImage = love.graphics.newImage("assets/ground_0.png")
	groundY = love.graphics:getHeight() - groundImage:getHeight()

	love.graphics.setBackgroundColor(126, 192, 238)


	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = body:getY()
	shape = love.physics.newRectangleShape(spaceship:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.

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

	moveCamera = false
	currentHeight = startY - body:getY()
	if currentHeight > maxHeight then
		maxHeight = currentHeight
		scoreDisplay = scoreDisplayRoot .. math.floor(maxHeight / 10)
	end
	if body:getY() < cameraMiddle then
		moveCamera = true
		moveCameraAmount = body:getY() - cameraMiddle --this is negative
		cameraMiddle = cameraMiddle + moveCameraAmount
		scoreY = scoreY + moveCameraAmount
	end

end

local v = Vec2(0.0, 3.0)
local multiplied_v = v * 3

function love.draw()
	camera:set()
	displayScore()
	-- if current height below the first camera change
	love.graphics.draw(groundImage, 0, groundY)
	love.graphics.draw(spaceship,body:getX(),body:getY(),body:getAngle(),1,1,spaceship:getDimensions() / 2)
	if (moveCamera) then
		camera:move(0, moveCameraAmount)
	end
	camera:unset()
end

function displayScore()
	love.graphics.print(scoreDisplay, scoreX, scoreY)
	--debug
	love.graphics.print("maxHeight: "..maxHeight, scoreX, scoreY + 50)
	love.graphics.print("currentHeight: "..currentHeight, scoreX, scoreY + 100)
	love.graphics.print("cameraMiddle: "..cameraMiddle, scoreX, scoreY + 150)
	love.graphics.print("bodyY: "..body:getY(), scoreX, scoreY + 200)
end