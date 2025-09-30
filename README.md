# Loving Boids
This is just a very simple implementation of the [Boids Algorithm](https://en.wikipedia.org/wiki/Boids) in the [Lua](https://www.lua.org/) programming language and using the [Love2D framework](https://love2d.org/).
This specific implementation uses a few algorithms to speed things up, namely:
* [Spatial Grid Partitioning](https://gameprogrammingpatterns.com/spatial-partition.html), to track close boids
* [Alpha Max + Beta Min](https://en.wikipedia.org/wiki/Alpha_max_plus_beta_min_algorithm), to compute distances (thus avoiding the computationally expensive square root)
both of which are well documented at the given links, and at many other places around the web.

Just as a quick reminder, both of these algorithms are about speeding up computation and they're especially useful when dealing with a lot of objects which, in one way or another, need to be aware of what's going on around them.
In the _Boids Algorithm_ each object needs to know how close other objects are to trigger the right actions and, in this implementation, the _grid_ data structure is the one responsible for tracking close objects. When a boid receives a list of close objects from the grid he computes all the necessary distances using the __Alpha Max + Beta Min__ formula. Once these distances are known they're then reviewed to check if they fall within the boundaries of the boid's _Visual Distance_ or within those of the boid's _Protected Distance_ (two concepts useful for the Boids Algorithm). Based on those consideration different actions are triggered at the single _boid_ level to keep boids flying together (in a flock fashion) without having them crashing into each other.

The project is basically composed of the following files:
* boid.lua, containing all the logic for the boids algorithm
* flock.lua, tasked of grouping the boids together in a single entity
* grid.lua, expressing the logic used to track how close boids are

Following there are a couple of screenshots taken from this little simulation, the first one showing the boids without the grid and the second one visualizing the grid too.

![flock of boids w/o grid](/screenshots/loving-boids.png)

![flock of boids w/ grid](/screenshots/loving-boids-with-grid.png)

## Shortcuts
The only two available shortcuts in this project are the letter __g__ to reveal the grid, visualing how boids are tracked, and the letter __q__ to quit the simulation.

## Dependencies
The only necessary dependency to run this simple project is the [Love2D framework](https://love2d.org/) which is available on almost every platform. The main.lua file contains the core functions that each Love2D project should have, namely:
* load (executed only once, at the start of the program)
* update
* draw

