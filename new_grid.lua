-- ALGORITHMS USED
-- 
-- GRID PARTITIONING (as boids protected/visual ranges)
-- https://gameprogrammingpatterns.com/spatial-partition.html
-- https://www.1bardesign.com/words/?p=2017.001
-- https://www.youtube.com/watch?v=D2M8jTtKi44

Grid={}
Grid.__index=Grid

function Grid:new(obj, win_width, win_heigth, cell_size)
    local canvas=love.graphics.newCanvas(cell_size, cell_size)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, cell_size, cell_size)
    love.graphics.setCanvas()
    local img=love.graphics.newImage(canvas:newImageData())

    -- data structure and metatable
    local cs=math.ceil(win_width / cell_size)
    local rs=math.ceil(win_heigth / cell_size)
    local g={
        tracked_obj=obj,
        w=win_width,
        h=win_heigth,
        csize=cell_size,
        rows=rs,
        cols=cs,
        matrix={},
        cell_image=img,
        batch=love.graphics.newSpriteBatch(img,rs*cs,"dynamic"),
    }
    setmetatable(g, Grid)

    return g
end

function Grid:update(dt)
   -- empty matrix at each update cycle
   self.matrix={}

   -- position boids in the correct cells
   for _, boid in ipairs(self.tracked_obj.components) do
      -- compute cols bucket
      xb=math.floor(boid.x / self.csize) + 1

      -- compute rows bucket
      yb=math.floor(boid.y / self.csize) + 1

      -- check if they already exist in the emptied matrix
      -- and insert the boids in the correct matrix cell
      if self.matrix[yb]==nil then self.matrix[yb]={} end
      if self.matrix[yb][xb]==nil then self.matrix[yb][xb]={} end
      table.insert(self.matrix[yb][xb], boid)
   end

   self:resolveCollisions(dt)
end

function Grid:draw()
   love.graphics.setColor(1, 1, 1, .1)

   -- draw rows
   for r=1, self.rows do
      love.graphics.line(0, self.csize*r, self.w, self.csize*r)
   end

   -- draw cols
   for c=1, self.cols do
      love.graphics.line(self.csize*c, 0, self.csize*c, self.h)
   end

   -- highlight cells when there's a collision
   love.graphics.setColor(1, 0, 0, .75)
   self.batch:clear()
   for yb=1, self.rows do
      for xb=1, self.cols do
         if self.matrix[yb]~=nil and self.matrix[yb][xb]~=nil and #self.matrix[yb][xb] > 1 then
            self.batch:add(
               (xb - 1) * self.csize,
               (yb - 1) * self.csize
            )
         end
      end
   end
   love.graphics.draw(self.batch)
   love.graphics.setColor(1, 1, 1, 1)
   self.batch:flush()
end

function Grid:resolveCollisions(dt)
   for yb=1, self.rows do
      for xb=1, self.cols do
         if self.matrix[yb]~=nil and self.matrix[yb][xb]~=nil then
            if #self.matrix[yb][xb]>1 then
               -- collect adjacent boids to the current collision cell
               -- they will be used to compute distances in the flock movement Boid's method
               local adjacentBoids={}

               local min_yb = yb-1
               local max_yb = yb+1
               if min_yb<=0 then min_yb=1 end
               if max_yb>self.rows then max_yb=self.rows end

               local min_xb = xb-1
               local max_xb = xb+1
               if min_xb<=0 then min_xb=1 end
               if max_xb>self.cols then max_xb=self.cols end

               for y=min_yb, max_yb do
                  for x=min_xb, max_xb do
                     if self.matrix[y]~=nil and self.matrix[y][x]~=nil then
                        for _, boid in ipairs(self.matrix[y][x]) do
                           table.insert(adjacentBoids, boid)
                        end
                     end
                  end
               end

               -- update the state of each boid included in the table
               -- here the grid is used to avoid computing distances with all the boids during the movements computations, but only with the adjacent ones
               for _, boid in ipairs(adjacentBoids) do
                  boid:moveWithAdjacents(adjacentBoids, dt)
               end
            else
               -- make a boid move even if it has not being involved in a collision
               -- maybe it has some adjacent but they won't be considered, as they are only when a collision has been detected
               for _, boid in ipairs(self.matrix[yb][xb]) do
                  boid:moveAlone(dt)
               end
            end
         end
      end
   end
end
