--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"
require "camera"

local moveCamera = false
local moveCameraAmount = 0
local cameraMiddle = love.graphics:getHeight() / 2
local cameraQuarter = 3 * cameraMiddle / 2

local heightDisplayRoot = "Height: "
local heightDisplay = heightDisplayRoot .. "0"

local heightX = 50
local heightY = 50

local heightDisplayRoot = "Height: "
local heightDisplay = heightDisplayRoot .. "0"

local heightX = 50
local heightY = 50

local maxDisplayRoot = "Max: "
local maxDisplay = maxDisplayRoot .. "0"

local maxX = 50
local maxY = 75

local startY
local maxHeight = 0
local currentHeight = 0
local score = 0

local resistanceCoeff = 0.001

local rocketforce = -5000
local metersPerScreen

local ground = {}

function random99to101()
	return (.99 + .02 * love.math.random())
end

function love.load()

	spaceshipImage = love.graphics.newImage("assets/spaceship96x96.png")
	rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
	groundImage = love.graphics.newImage("assets/ground_0.png")
	groundY = love.graphics:getHeight() - groundImage:getHeight()

	love.graphics.setBackgroundColor(30, 0, 30)

	love.physics.setMeter(64)
	metersPerScreen = love.window.getHeight() / love.physics.getMeter()
	world = love.physics.newWorld(0, 64*9.81*.75, true)
	--world = love.physics.newWorld(0, 0, true)
	rocketforce = 2000
	spaceship = {}
	spaceship.body = love.physics.newBody(world, 400, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = spaceship.body:getY()
	local x,y,mass,inertia = spaceship.body:getMassData()
	x = x + spaceshipImage:getHeight() / 6
	spaceship.body:setMassData(x, y, mass, inertia)
	spaceship.body:setAngularDamping(0.07)
	spaceship.body:setLinearDamping(0.07)
	spaceship.body:setAngle(-math.pi/2 * random99to101()^6)
	spaceship.body:setBullet(true)
	spaceship.shape = love.physics.newPolygonShape(48,0, -16,48, -32,48, -48,0, -32,-48, -16,-48)
	spaceship.fixture = love.physics.newFixture(spaceship.body, spaceship.shape, 1.7) -- Attach fixture to body and give it a density of 1.

	ground = {}
	ground.body = love.physics.newBody(world, love.graphics:getWidth()/2, groundY + groundImage:getHeight()/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(groundImage:getDimensions())
	ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
	ground.fixture:setRestitution(0.25)

	walls = {}
	walls.leftBody = love.physics.newBody(world, 0, 0)
	walls.leftShape = love.physics.newRectangleShape(1,4 * love.window:getHeight())
	walls.leftFixture = love.physics.newFixture(walls.leftBody, walls.leftShape)
	walls.leftFixture:setRestitution(0.9)
	walls.leftFixture:setFriction(1)
	walls.rightBody = love.physics.newBody(world, love.window.getWidth(), 0)
	walls.rightShape = love.physics.newRectangleShape(1,4 * love.window:getHeight())
	walls.rightFixture = love.physics.newFixture(walls.rightBody, walls.rightShape)
	walls.rightFixture:setRestitution(0.9)
	walls.rightFixture:setFriction(1)

	rightOn = false
	leftOn = false
	maxHeight = 0
	currentHeight = 0
	score = 0
	
	heightDisplay = heightDisplayRoot .. "0"
	love.graphics.print(heightDisplay, heightX, heightY)
	maxDisplay = maxDisplayRoot .. "0"
	love.graphics.print(maxDisplay, maxX, maxY)

end

function love.update(dt)
	leftOn = false
	rightOn = false
	world:update(dt)

	walls.leftBody:setPosition(0, spaceship.body:getY())
	walls.rightBody:setPosition(love.window:getWidth(), spaceship.body:getY())

	local xVelocity, yVelocity = spaceship.body:getLinearVelocity();
	spaceship.body:applyForce(-resistanceCoeff * xVelocity * math.abs(xVelocity), 0)
	if yVelocity < 0 then
		spaceship.body:applyForce(0, resistanceCoeff * yVelocity^2)
	end
	if love.keyboard.isDown("left") then
		leftOn = true
		leftRocketOffsetX = -spaceshipImage:getWidth() * 1/2
		leftRocketOffsetY = -spaceshipImage:getHeight() / 4
		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()) * random99to101(),
			rocketforce * math.sin(spaceship.body:getAngle()) * random99to101(),
			spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if love.keyboard.isDown("right") then
		rightOn = true
		rightRocketOffsetX = -spaceshipImage:getWidth() * 1/2
		rightRocketOffsetY = spaceshipImage:getHeight() / 4
		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()) * random99to101(),
			rocketforce * math.sin(spaceship.body:getAngle()) * random99to101(),
			spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY))
	end
	if love.keyboard.isDown(" ") then
		love.load()
	end

	previousLine = getPreviousLine()
	nextLine = getNextLine()
	cameraMiddleHeight = -cameraMiddle + 325

	moveCamera = false
	currentHeight = startY - spaceship.body:getY()
	if currentHeight > maxHeight then
		maxHeight = currentHeight
		maxText = math.floor(maxHeight)
		maxDisplay = maxDisplayRoot .. maxText
	end
	if currentHeight < 0 then
		heightText = 0
	else
		heightText = math.floor(currentHeight)
	end
	heightDisplay = heightDisplayRoot .. heightText
	if spaceship.body:getY() < cameraMiddle  then
		moveCamera = true
		moveCameraAmount = spaceship.body:getY() - cameraMiddle --this is negative
		cameraMiddle = cameraMiddle + moveCameraAmount
		cameraQuarter = cameraQuarter + moveCameraAmount
		heightY = heightY + moveCameraAmount
		maxY = maxY + moveCameraAmount
	end
	if spaceship.body:getY() > cameraQuarter and cameraMiddle < 300 then
		moveCamera = true
		moveCameraAmount = spaceship.body:getY() - cameraQuarter --this is positive
		cameraMiddle = cameraMiddle + moveCameraAmount
		cameraQuarter = cameraQuarter + moveCameraAmount
		heightY = heightY + moveCameraAmount
		maxY = maxY + moveCameraAmount
	end

end

function love.draw()
	camera:set()
	drawLine(previousLine)
	drawLine(nextLine)
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
	love.graphics.print(heightDisplay, heightX, heightY)
	love.graphics.print(maxDisplay, maxX, maxY)
	--debug
	-- love.graphics.print("maxHeight: "..maxHeight, maxX, maxY + 50)
	-- love.graphics.print("currentHeight: "..currentHeight, maxX, maxY + 100)
	-- love.graphics.print("cameraMiddle: "..cameraMiddle, maxX, maxY + 150)
	-- love.graphics.print("cameraQuarter: "..cameraQuarter, maxX, maxY + 175)
	-- love.graphics.print("bodyY: "..spaceship.body:getY(), maxX, maxY + 200)

	if rightOn then
		local worldX, worldY = spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	if leftOn then
		local worldX, worldY = spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	-- love.graphics.print("prevline: "..previousLine, maxX, maxY + 225)
	-- love.graphics.print("nextline: "..nextLine, maxX, maxY + 250)
	-- love.graphics.print("cameraHeight "..-cameraMiddle + 325, maxX, maxY + 275)
end

function getPreviousLine()
	if currentHeight < 1000 then
		return 0
	end
	return math.floor(currentHeight / 1000) * 1000
end

function getNextLine()
	if currentHeight < 0 then
		return 0
	end
	return math.ceil(currentHeight / 1000) * 1000
end

function drawLine(height)
	if math.abs(cameraMiddleHeight - height) < love.window.getHeight()/2 then
		local printHeight = cameraMiddle + cameraMiddleHeight - height
		love.graphics.print(height, 25, printHeight)
		love.graphics.line(50, printHeight, 700, printHeight)
	end
end