--
-- Spaceman
--
local Vec2 = require "Vec2_ffi"

function love.load()
   spaceship = love.graphics.newImage("spaceship96x96.png")
   x = 400
   y = 300
   angle = 0
   speed = 300
   angular_speed = 1
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
end