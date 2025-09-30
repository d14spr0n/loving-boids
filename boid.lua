require "os"
require "math"

local SCREEN_MARGIN = 400
local TURN_FACTOR = .35
local CENTERING_FACTOR = .0005
local AVOID_FACTOR = .05
local MATCHING_FACTOR = .025
local MAX_SPEED = 75
local MIN_SPEED = 50
local ALPHA, BETA = 0.898204193266868, 0.485968200201465

Boid = {}
Boid.__index = Boid

function Boid:new(visualRange, protectedRange, winW, winH)
   local lvx, lvy

   -- prevents the 0 value which would make a boid still
   if love.math.random(-1,1) == 1 then lvx=1 else lvx=-1 end
   if love.math.random(-1,1) == 1 then lvy=1 else lvy=-1 end

   local b = {
      x=love.math.random(SCREEN_MARGIN, winW-SCREEN_MARGIN),
      y=love.math.random(SCREEN_MARGIN, winH-SCREEN_MARGIN),
      vx=lvx,
      vy=lvy,
      vRange=visualRange,
      pRange=protectedRange,
      winW=winW,
      winH=winH
   }
   setmetatable(b, self)

   return b
end

function Boid:moveWithAdjacents(adjacentBoids, dt)
   -- initialize accumulators before computing updates
   local close = { x = 0, y = 0 }
   local speed_avg = { x = 0, y = 0 }
   local pos_avg = { x = 0, y = 0 }
   local n_count = 0

   -- compute distances for every other boid present in the world
   for _, other in ipairs(adjacentBoids) do
      -- if to exclude the referenced boid
      if other ~= self then
         -- compute squares
         local dx = other.x - self.x
         local dy = other.y - self.y
         local dist_sq = dx * dx + dy * dy
         local protected_range_sq = self.pRange * self.pRange
         local visual_range_sq = self.vRange * self.vRange

         -- separation, i.e. avoid running in boids in protected range
         if dist_sq < protected_range_sq then
            -- separation accumulator, i.e. it's about the distancing from close boids
            close.x = close.x + self.x - other.x
            close.y = close.x + self.y - other.y
         elseif dist_sq < visual_range_sq then
            -- alignment, i.e. it's about matching the speed of boids in visible range
            speed_avg.x = speed_avg.x + other.vx
            speed_avg.y = speed_avg.y + other.vy

            -- cohesion, i.e. it's about steering towards the center of other boids in visible range
            pos_avg.x = pos_avg.x + other.x
            pos_avg.y = pos_avg.y + other.y

            n_count = n_count + 1
         end
      end
   end

   -- apply rules only for neighboring boids
   if n_count > 0 then
      -- separation actions
      self.vx = self.vx + close.x * AVOID_FACTOR
      self.vy = self.vy + close.y * AVOID_FACTOR

      -- alignment actions
      speed_avg.x = speed_avg.x / n_count
      speed_avg.y = speed_avg.y / n_count
      self.vx = self.vx + (speed_avg.x - self.vx) * MATCHING_FACTOR
      self.vy = self.vy + (speed_avg.y - self.vy) * MATCHING_FACTOR

      -- cohesion actions
      pos_avg.x = pos_avg.x / n_count
      pos_avg.y = pos_avg.y / n_count
      self.vx = self.vx + (pos_avg.x - self.x) * CENTERING_FACTOR
      self.vy = self.vy + (pos_avg.y - self.y) * CENTERING_FACTOR
   end

   -- separation, add the avoidance contribution to a boid's speed
   self.vx = self.vx + (close.x * AVOID_FACTOR)
   self.vy = self.vy + (close.y * AVOID_FACTOR)

   -- add the turn contribution to a boid's speed
   -- turn at margins (left, right, top, bottom)
   local width, height = love.graphics.getDimensions()
   if self.x < SCREEN_MARGIN then self.vx = self.vx + TURN_FACTOR end
   if self.x > width - SCREEN_MARGIN then self.vx = self.vx - TURN_FACTOR end
   if self.y < SCREEN_MARGIN then self.vy = self.vy + TURN_FACTOR end
   if self.y > height - SCREEN_MARGIN then self.vy = self.vy - TURN_FACTOR end

   -- enforce speed limits
   -- alpha max plus beta min algorithm to approximate Pitagora
   -- https://math.stackexchange.com/a/2307948
   local s = ALPHA * math.max(math.abs(self.vx), math.abs(self.vy)) + BETA * math.min(math.abs(self.vx), math.abs(self.vy))
   if s < MIN_SPEED then
      self.vx = (self.vx / s) * MIN_SPEED
      self.vy = (self.vy / s) * MIN_SPEED
   end
   if s > MAX_SPEED then
      self.vx = (self.vx / s) * MAX_SPEED
      self.vy = (self.vy / s) * MAX_SPEED
   end

   -- update boid's position using its computed speed
   self.x = self.x + (self.vx * dt)
   self.y = self.y + (self.vy * dt)

   -- Screen wrapping
   self.x = self.x % width
   self.y = self.y % height
end

function Boid:moveAlone(dt)
   local s = ALPHA * math.max(math.abs(self.vx), math.abs(self.vy)) + BETA * math.min(math.abs(self.vx), math.abs(self.vy))
   if s < MIN_SPEED then
      self.vx = (self.vx / s) * MIN_SPEED
      self.vy = (self.vy / s) * MIN_SPEED
   end
   if s > MAX_SPEED then
      self.vx = (self.vx / s) * MAX_SPEED
      self.vy = (self.vy / s) * MAX_SPEED
   end

   -- update boid's position using its computed speed
   self.x = self.x + (self.vx * dt)
   self.y = self.y + (self.vy * dt)

   -- Screen wrapping
   self.x = self.x % width
   self.y = self.y % height
end
