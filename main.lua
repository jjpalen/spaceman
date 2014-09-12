--
-- Spaceman
--

local Vec2 = require "Vec2_ffi"
require "camera"

local moveCamera = false
local moveCameraAmount = 0
local windowHeight = love.graphics:getHeight()
local windowWidth = love.graphics:getWidth()
local cameraMiddle = windowHeight / 2
local halfWindowHeight = cameraMiddle
local cameraQuarter = 3 * cameraMiddle / 2

local heightDisplayRoot = "Height: "
local heightDisplay = heightDisplayRoot .. "0"

local heightX = 50
local heightY = 50

local heightDisplayRoot = "Height: "
local heightDisplay = heightDisplayRoot .. "0"

local heightX = 50
local heightY = 50

local maxDisplayRoot = "Best: "
local maxDisplay = maxDisplayRoot .. "0"

local maxX = 50
local maxY = 75

local startY
local maxHeight = 0
local currentHeight = 0
local score = 0

local indicatorY = 15

local resistanceCoeff = 0.001

local rocketforce = -5000
local metersPerScreen

local invertedControls = true

local gravity = 5.4
local spaceshipAngularDamping = .5
local spaceshipLinearDamping = .07
local spaceshipDensity = 2
local rocketforce = 2000
local wallFriction = 1
local wallRestitution = .8

local ground = {}

function random99to101()
	return (.99 + .02 * love.math.random())
end

function love.load()

	spaceshipImage = love.graphics.newImage("assets/spaceship96x96.png")
	rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
	groundImage = love.graphics.newImage("assets/ground_0.png")
	groundY = windowHeight - groundImage:getHeight()

	love.graphics.setBackgroundColor(30, 0, 30)

	love.physics.setMeter(64)
	metersPerScreen = windowHeight / love.physics.getMeter()
	resetWorld()

end

function resetWorld()
	world = love.physics.newWorld(0, love.physics.getMeter()*gravity, true)

	spaceship = {}
	spaceship.body = love.physics.newBody(world, 400, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	startY = spaceship.body:getY()
	local x,y,mass,inertia = spaceship.body:getMassData()
	x = x + spaceshipImage:getHeight() / 6
	spaceship.body:setAngularDamping(spaceshipAngularDamping)
	spaceship.body:setLinearDamping(spaceshipAngularDamping)
	spaceship.body:setAngle(-math.pi/2 * random99to101()^6)
	spaceship.body:setBullet(true)
	spaceship.shape = love.physics.newPolygonShape(48,0, -16,48, -32,48, -48,0, -32,-48, -16,-48)
	spaceship.fixture = love.physics.newFixture(spaceship.body, spaceship.shape, spaceshipDensity) -- Attach fixture to body and give it a density of 1.

	ground = {}
	ground.body = love.physics.newBody(world, windowWidth / 2, groundY + halfWindowHeight) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	ground.shape = love.physics.newRectangleShape(groundImage:getDimensions())
	ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
	ground.fixture:setRestitution(.25)

	walls = {}
	walls.leftBody = love.physics.newBody(world, 0, 0)
	walls.leftShape = love.physics.newRectangleShape(1,400 * windowHeight)
	walls.leftFixture = love.physics.newFixture(walls.leftBody, walls.leftShape)
	walls.leftFixture:setRestitution(wallRestitution)
	walls.leftFixture:setFriction(wallFriction)
	walls.rightBody = love.physics.newBody(world, windowWidth, 0)
	walls.rightShape = love.physics.newRectangleShape(1, 400 * windowHeight)
	walls.rightFixture = love.physics.newFixture(walls.rightBody, walls.rightShape)
	walls.rightFixture:setRestitution(wallRestitution)
	walls.rightFixture:setFriction(wallFriction)

	rightOn = false
	leftOn = false
	currentHeight = 0
	score = 0

	gates = {}
	for i = 1,1000 do
		gates[i] = {}
		gates[i].leftLength = math.random() * love.window:getWidth() / 2
		gates[i].rightLength = love.window:getWidth() / 2 - gates[i].leftLength
	end
	--generateObstacles(nObstacles, 6)
	
	nObstacles = 0
	obstacles = {}
	for height = 400,32000,800 do
		local n = math.ceil(2*height/6400)
		--print (n, height)
		generateObstacles(nObstacles, n, 2, height)
		nObstacles = nObstacles + n
	end

	heightDisplay = heightDisplayRoot .. currentHeight
	love.graphics.print(heightDisplay, heightX, heightY)
	maxDisplay = maxDisplayRoot .. math.floor(maxHeight)
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
	spaceship.body:applyForce(0, -resistanceCoeff * yVelocity * math.abs(yVelocity))

	if (love.keyboard.isDown("right") and invertedControls == true)
		or (love.keyboard.isDown("left") and invertedControls == false) then
		leftOn = true
		leftRocketOffsetX = -spaceshipImage:getWidth() * .4
		leftRocketOffsetY = -spaceshipImage:getHeight() / 4

		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()) * random99to101(),
			rocketforce * math.sin(spaceship.body:getAngle()),
			spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY))
	end
	if (love.keyboard.isDown("left") and invertedControls == true)
		or (love.keyboard.isDown("right") and invertedControls == false) then
		rightOn = true
		rightRocketOffsetX = -spaceshipImage:getWidth() * .4
		rightRocketOffsetY = spaceshipImage:getHeight() / 4
		spaceship.body:applyForce(rocketforce * math.cos(spaceship.body:getAngle()),
			rocketforce * math.sin(spaceship.body:getAngle()),
			spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY))
	end

	previousLine = getPreviousLine()
	nextLine = getNextLine()
	cameraMiddleHeight = -cameraMiddle + love.window.getHeight()/2

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
		indicatorY = indicatorY + moveCameraAmount
	end
	if spaceship.body:getY() > cameraQuarter and cameraMiddle < love.window.getHeight()/2 then
		moveCamera = true
		moveCameraAmount = spaceship.body:getY() - cameraQuarter --this is positive
		cameraMiddle = cameraMiddle + moveCameraAmount
		cameraQuarter = cameraQuarter + moveCameraAmount
		heightY = heightY + moveCameraAmount
		maxY = maxY + moveCameraAmount
		indicatorY = indicatorY + moveCameraAmount

	end
end

function love.keypressed(key)
	if key == "i" then
		invertedControls = not invertedControls
	end
	if key == " " then
		resetWorld()
	end
end

function love.draw()
	camera:set()

	local i = previousLine / 1000 + 1
	local j = nextLine / 1000 + 1
	if i > 1 then
		addGate(previousLine, gates[i].leftLength, gates[i].rightLength)
	end
	if j > 1 then
		addGate(nextLine, gates[j].leftLength, gates[j].rightLength)
		drawIndicator(gates[j].leftLength + love.window:getWidth() / 4)
	end

	displayScore()
	-- if current height below the first camera change
	--love.graphics.draw(groundImage, 0, groundY)
	--love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  	love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
	--love.graphics.draw(spaceship,body:getX(),body:getY(),body:getAngle() + math.pi/2,1,1,spaceship:getDimensions() / 2)
	love.graphics.draw(spaceshipImage,spaceship.body:getX(),spaceship.body:getY(),spaceship.body:getAngle() + math.pi/2,1,1,spaceshipImage:getWidth()/2,spaceshipImage:getHeight()/2)
	print ("ship", spaceship.body:getX(), spaceship.body:getY())
	
	drawObstacles(nObstacles);

	if rightOn then
		local worldX, worldY = spaceship.body:getWorldPoint(rightRocketOffsetX, rightRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end
	if leftOn then
		local worldX, worldY = spaceship.body:getWorldPoint(leftRocketOffsetX, leftRocketOffsetY)
		love.graphics.circle("fill", worldX , worldY , 10, 100)
	end

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
	if not invertedControls then
		love.graphics.print("Legacy Controls Activated", maxX, maxY + 25)
	end
end

function getPreviousLine()
	return math.floor(currentHeight / 1000) * 1000
end

function getNextLine()
	return math.ceil(currentHeight / 1000) * 1000
end

function drawLines(center, h)
	for height = h - 1000, h, 100 do
		if math.abs(cameraMiddleHeight - height) < love.window.getHeight()/2 then
			local printHeight = cameraMiddle + cameraMiddleHeight - height
			love.graphics.line(center - 10, printHeight, center + 10, printHeight)
		end
	end
end

function drawIndicator(center)
	love.graphics.polygon("line", center, indicatorY, center - 5, indicatorY + 5, center + 5, indicatorY + 5)
end

function addGate(height, leftLength, rightLength)
	if math.abs(cameraMiddleHeight - height) < love.window.getHeight()/2 then
		local printHeight = cameraMiddle + cameraMiddleHeight - height
		leftGate = {}
		rightGate = {}
		leftGate.body = love.physics.newBody(world, leftLength / 2, printHeight)
		leftGate.shape = love.physics.newRectangleShape(leftLength, 20)
		leftGate.fixture = love.physics.newFixture(leftGate.body, leftGate.shape)
		leftGate.fixture:setRestitution(.5)
		leftGate.fixture:setFriction(1)
		rightGate.body = love.physics.newBody(world, love.window:getWidth() - rightLength / 2, printHeight)
		rightGate.shape = love.physics.newRectangleShape(rightLength, 20)
		rightGate.fixture = love.physics.newFixture(rightGate.body, rightGate.shape)
		rightGate.fixture:setRestitution(.5)
		rightGate.fixture:setFriction(1)

		love.graphics.polygon("fill", leftGate.body:getWorldPoints(leftGate.shape:getPoints()))
		love.graphics.polygon("fill", rightGate.body:getWorldPoints(rightGate.shape:getPoints()))
		--love.graphics.rectangle("fill", 0, printHeight-10, leftLength, 20)
		--love.graphics.rectangle("fill", love.window:getWidth()-rightLength, printHeight-10, rightLength, 20)
	end
end

function generateObstacles(start, n, m, height)
	for i = start+1,start+n do
		obstacles[i] = {}
		local obst = obstacles[i]
		obst.radius = 30 + math.random() * 30
		obst.x = 2*obst.radius + math.random() * (love.window:getWidth() - 4*obst.radius)
		obst.y = -math.random() * love.window:getHeight() * m - height
		--print (obst.y)
		obst.xVelocity = (2 * math.random() - 1) * 500
		obst.yVelocity = (2 * math.random() - 1) * 200
		obst.body = love.physics.newBody(world, obst.x, obst.y, "dynamic")
		obst.shape = love.physics.newCircleShape(obst.radius)
		obst.fixture = love.physics.newFixture(obst.body, obst.shape, 5)
		obst.body:setLinearVelocity(obst.xVelocity, obst.yVelocity)
		obst.body:setGravityScale(0)
		obst.fixture:setRestitution(.5)
	end
end

function drawObstacles(n)
	for i = 1,n do
		if math.abs(obstacles[i].body:getY() - spaceship.body:getY()) < 1000 then
			print ("obstacles", i, obstacles[i].body:getX(), obstacles[i].body:getY(), obstacles[i].radius)
			love.graphics.circle("fill", obstacles[i].body:getX(), obstacles[i].body:getY(), obstacles[i].radius, 100)
		end
	end
end


