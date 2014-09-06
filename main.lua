--
-- Spaceman
--
local Vec2 = require "Vec2_ffi"

function love.load()
   spaceship = love.graphics.newImage("assets/spaceship96x96.png")
   rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
   ground = love.graphics.newImage("assets/ground_0.png")
   groundY = love.graphics:getHeight() - ground:getHeight()
   
   x = 350
   y = 473
   angle = 0
   speed = 300
   angular_speed = 1
   love.graphics.setBackgroundColor(126, 192, 238)
   scoreDisplayRoot = "Score: "
   scoreDisplay = "Score: 0"
   maxHeight = 0
   currentHeight = 0
   scoreX = 50
   scoreY = 50
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      x = x + (speed * dt)
      angle = angle + (angular_speed * dt)
   end
   if love.keyboard.isDown("left") then
      x = x - (speed * dt)
      angle = angle - (angular_speed * dt)
   end

   if love.keyboard.isDown("down") then
      y = y + (speed * dt)
      --this needs to be revised for gravity
      currentHeight = currentHeight - (speed * dt)
   end
   if love.keyboard.isDown("up") then
      y = y - (speed * dt)
      currentHeight = currentHeight + (speed * dt)
   end

   if currentHeight > maxHeight then
		maxHeight = currentHeight
		scoreDisplay = scoreDisplayRoot .. math.floor(maxHeight)
	end
end

function love.draw()
   love.graphics.draw(spaceship, x, y, angle)
   displayScore()
   -- if current height below the first camera change
   love.graphics.draw(ground, 0, groundY)
end

function displayScore()
	love.graphics.print(scoreDisplay, scoreX, scoreY)
end