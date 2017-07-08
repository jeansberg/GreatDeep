function love.load()
  xPos = 0
  yPos = 0
  playerWidth = 64
  playerHeight = 64
  playerSpeed = 200
  submarineImage = love.graphics.newImage("resources/images/submarine.png")
end

function love.draw()
  love.graphics.draw(submarineImage, xPos, yPos, 0, 2, 2)
end

function love.update(dt)
  downUp = love.keyboard.isDown("down") or love.keyboard.isDown("up")
  leftRight = love.keyboard.isDown("left") or love.keyboard.isDown("right")

  speed = playerSpeed
  if(downUp and leftRight) then
    speed = speed / math.sqrt(2)
  end

  if love.keyboard.isDown("down") and yPos<love.graphics.getHeight()-playerHeight then
    yPos = yPos + dt * speed
  elseif love.keyboard.isDown("up") and yPos>0 then
    yPos = yPos - dt * speed
  end

  if love.keyboard.isDown("right") and xPos<love.graphics.getWidth()-playerWidth then
    xPos = xPos + dt * speed
  elseif love.keyboard.isDown("left") and xPos>0 then
    xPos = xPos - dt * speed
  end
end
