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
	world = love.physics.newWorld(0, 64*9.81*.75, true)
	--world = love.physics.newWorld(0, 0, true)
	rocketforce = 2300
	body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = body:getY()
	local x,y,mass,inertia = body:getMassData()
	x = x + spaceship:getHeight() / 4
	--mass = mass * 5000
	--inertia = inertia * 5000
	body:setMassData(x, y, mass, inertia)
	body:setAngularDamping(0.07)
	body:setLinearDamping(0.07)
	body:setAngle(-math.pi/2)
	shape = love.physics.newRectangleShape(spaceship:getDimensions())
	fixture = love.physics.newFixture(body, shape, 1) -- Attach fixture to body and give it a density of 1.
	ground = {}
	ground.body = love.physics.newBody(world, 0, groundY) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(groundImage:getDimensions()) --make a rectangle with a width of 650 and a height of 50
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
		leftRocketOffsetX = -spaceship:getWidth() * 2/3
		leftRocketOffsetY = -spaceship:getHeight() / 4
		body:applyForce(rocketforce * math.cos(body:getAngle()), rocketforce * math.sin(body:getAngle()), body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if love.keyboard.isDown("right") then
		rightOn = true
		rightRocketOffsetX = -spaceship:getWidth() * 2/3
		rightRocketOffsetY = spaceship:getHeight() / 4
		body:applyForce(rocketforce * math.cos(body:getAngle()), rocketforce * math.sin(body:getAngle()), body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY ))
	end
	if love.keyboard.isDown(" ") then
		love.load()
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

function love.draw()
	camera:set()
	displayScore()
	-- if current height below the first camera change
	love.graphics.draw(groundImage, 0, groundY)
	love.graphics.draw(spaceship,body:getX(),body:getY(),body:getAngle() + math.pi/2,1,1,spaceship:getDimensions() / 2)
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

	if rightOn then
		local worldX, worldY = body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	if leftOn then
		local worldX, worldY = body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end

	love.graphics.print("body angle: "..body:getAngle() * 180/math.pi, scoreX, scoreY + 250)
end