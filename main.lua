--
-- Spaceman
--
local Vec2 = require "Vec2_ffi"

function love.load()
   spaceship = love.graphics.newImage("assets/spaceship96x96.png")
   rocketTexture = love.graphics.newImage("assets/yellowtexture.png")
   ground = love.graphics.newImage("assets/ground_0.png")
   x = 350
   y = 473
   angle = 0
   speed = 300
   angular_speed = 1
   love.graphics.setBackgroundColor(126, 192, 238)
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
   end
   if love.keyboard.isDown("up") then
      y = y - (speed * dt)
   end
end

function love.draw()
   love.graphics.draw(spaceship, x, y, angle)
   -- if current height below the first camera change
   love.graphics.draw(ground, 0, 570)
end