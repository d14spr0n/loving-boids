require "boid"

Flock={}
Flock.__index=Flock

function Flock:new(numBoids, visualRange, protectedRange, winW, winH)
   -- prepare image to use in batch drawing
   local boidCanvas=love.graphics.newCanvas(24,24)
   love.graphics.setCanvas(boidCanvas)
   love.graphics.clear(0,0,0,0)
   local polygon_vertices = {0,0, 14,4, 0,8}
   love.graphics.polygon("fill", polygon_vertices)
   love.graphics.setCanvas()
   local boidImg=love.graphics.newImage(boidCanvas:newImageData())
   
   -- actual flock object
   local f={
      components={},
      numBoids=numBoids,
      boidsBatch=love.graphics.newSpriteBatch(boidImg, numBoids, "dynamic")
   }
   setmetatable(f, Flock)

   -- populate flock with boids
   for i=1, f.numBoids do
      f.components[i]=Boid:new(visualRange, protectedRange, winW, winH)
   end

   return f
end

function Flock:draw()
   -- draw flock (batching boids)
   love.graphics.setColor(1, 1, 0, 1)
   self.boidsBatch:clear()
   for _, b in ipairs(self.components) do
      -- love.graphics.circle("fill", b.x, b.y, 4)
      local angle=math.atan2(b.vy, b.vx)
      -- love.graphics.push()
      -- love.graphics.translate(b.x, b.y)
      -- love.graphics.rotate(angle)
      self.boidsBatch:add(b.x, b.y, angle)
      -- love.graphics.pop()
   end
   self.boidsBatch:flush()
   love.graphics.draw(self.boidsBatch)
   love.graphics.setColor(1, 1, 1, 1)
end

function Flock:move(collisionCell, rangeType)
   if rangeType=="protected" then
      for _, boid in ipairs(collisionCell) do
      end
   elseif rangeType=="visual" then
      for _, boid in ipairs(collisionCell) do
      end
   end
end
