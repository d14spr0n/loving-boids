require "flock"
require "grid"

BOIDS_NUM=1000
BOIDS_VISUAL_RANGE=60
BOIDS_PROTECTED_RANGE=10
GRID_CELL_SIZE=40

if os.getenv("GRID")~=nil then 
   GRID=1
else 
   GRID=0
end

function love.load()
   -- starting the profiler
   -- love.profiler = require('profile')
   -- love.profiler.start()
   
   love.window.setMode(1920,1024) --, { resizable = true })
   width, height = love.graphics.getDimensions()
   
   flock = Flock:new(BOIDS_NUM, BOIDS_VISUAL_RANGE, BOIDS_PROTECTED_RANGE, width, height)
   -- grid to track the flock
   trackingGrid = Grid:new(flock, width, height, GRID_CELL_SIZE)
end

-- love.frame = 0
function love.update(dt)
   -- update the profiler report every 100 frames
   -- love.frame = love.frame + 1
   -- if love.frame % 100 == 0 then
   --    love.report = love.profiler.report(50)
   -- end
   -- love.profiler.reset()

   -- flock:update(dt)
   trackingGrid:update(dt)
end

function love.draw()
   -- if needed draw grid before flock, so that it doesn't cover the boids
   if GRID==1 then
      trackingGrid:draw()
   end

   flock:draw()
   
   -- print stats
   love.graphics.setColor(1, 1, 1)
   love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
   love.graphics.print(string.format("Update: %.1fms", love.timer.getAverageDelta() * 1000), 10, 30)
   love.graphics.print("# BOIDS: " .. BOIDS_NUM, 10, 50)

   -- print profiler report data
   -- love.graphics.print(love.report or "Please wait...")
end

function love.keypressed(k)
   if k == "escape" then
      love.event.quit()
   elseif k == "g" then
      if GRID==0 then 
         GRID=1
      else 
         GRID=0 
      end
   elseif k=="q" or k=="escape" then
      love.event.quit()
   end
end
