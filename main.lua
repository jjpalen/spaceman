--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"
require "camera"

local moveCamera = false
local moveCameraAmount = 0
local cameraMiddle = love.graphics:getHeight() / 2
local cameraQuarter = 3 * cameraMiddle / 2

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

	spaceshipImage = love.graphics.newImage("assets/spaceship96x96.png")
	rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
	groundImage = love.graphics.newImage("assets/ground_0.png")
	groundY = love.graphics:getHeight() - groundImage:getHeight()

	love.graphics.setBackgroundColor(126, 192, 238)

	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 64*9.81*.75, true)
	--world = love.physics.newWorld(0, 0, true)
	rocketforce = 2300
	spaceship = {}
	spaceship.body = love.physics.newBody(world, 400, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = spaceship.body:getY()
	local x,y,mass,inertia = spaceship.body:getMassData()
	x = x + spaceshipImage:getHeight() / 4
	--mass = mass * 5000
	--inertia = inertia * 5000
	spaceship.body:setMassData(x, y, mass, inertia)
	spaceship.body:setAngularDamping(0.07)
	spaceship.body:setLinearDamping(0.07)
	spaceship.body:setAngle(-math.pi/2)
	shape = love.physics.newRectangleShape(spaceshipImage:getDimensions())
	fixture = love.physics.newFixture(spaceship.body, shape, 1) -- Attach fixture to body and give it a density of 1.
	ground = {}
	ground.body = love.physics.newBody(world, love.graphics:getWidth()/2, groundY + groundImage:getHeight()/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(groundImage:getDimensions())
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
		leftRocketOffsetX = -spaceshipImage:getWidth() * 2/3
		leftRocketOffsetY = -spaceshipImage:getHeight() / 4
		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()), rocketforce * math.sin(spaceship.body:getAngle()), spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if love.keyboard.isDown("right") then
		rightOn = true
		rightRocketOffsetX = -spaceshipImage:getWidth() * 2/3
		rightRocketOffsetY = spaceshipImage:getHeight() / 4
		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()), rocketforce * math.sin(spaceship.body:getAngle()), spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY ))
	end
	if love.keyboard.isDown(" ") then
		love.load()
	end

	moveCamera = false
	currentHeight = startY - spaceship.body:getY()
	if currentHeight > maxHeight then
		maxHeight = currentHeight
		scoreDisplay = scoreDisplayRoot .. math.floor(maxHeight / 10)
	end
	if spaceship.body:getY() < cameraMiddle then
		moveCamera = true
		moveCameraAmount = spaceship.body:getY() - cameraMiddle --this is negative
		cameraMiddle = cameraMiddle + moveCameraAmount
		cameraQuarter = cameraQuarter + moveCameraAmount
		scoreY = scoreY + moveCameraAmount
	end
	if spaceship.body:getY() > cameraQuarter then
		moveCamera = true
		moveCameraAmount = spaceship.body:getY() - cameraQuarter --this is positive
		cameraMiddle = cameraMiddle + moveCameraAmount
		cameraQuarter = cameraQuarter + moveCameraAmount
		scoreY = scoreY + moveCameraAmount
	end

end

function love.draw()
	camera:set()
	displayScore()
	-- if current height below the first camera change
	--love.graphics.draw(groundImage, 0, groundY)
	--love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  	love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
	
	--love.graphics.draw(spaceship,body:getX(),body:getY(),body:getAngle() + math.pi/2,1,1,spaceship:getDimensions() / 2)
	love.graphics.draw(spaceshipImage,spaceship.body:getX(),spaceship.body:getY(),spaceship.body:getAngle() + math.pi/2,1,1,spaceshipImage:getWidth()/2,spaceshipImage:getHeight()/2)

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
	love.graphics.print("cameraQuarter: "..cameraQuarter, scoreX, scoreY + 175)
	love.graphics.print("bodyY: "..spaceship.body:getY(), scoreX, scoreY + 200)

	if rightOn then
		local worldX, worldY = spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	if leftOn then
		local worldX, worldY = spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end

	love.graphics.print("body angle: "..spaceship.body:getAngle() * 180/math.pi, scoreX, scoreY + 250)
end