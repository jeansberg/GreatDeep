function love.load()
  submarineImage = love.graphics.newImage("resources/images/submarine.png")
  torpedoImage = love.graphics.newImage("resources/images/torpedo.png")

  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  torpedoes = {}

  canFire = false
  torpedoTimerMax = 0.2
  torpedoTimer = torpedoTimerMax
end

function love.draw()
  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2)

  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
  end
end

function love.update(dt)
  downUp = love.keyboard.isDown("down") or love.keyboard.isDown("up")
  leftRight = love.keyboard.isDown("left") or love.keyboard.isDown("right")

  speed = player.speed
  if(downUp and leftRight) then
    speed = speed / math.sqrt(2)
  end

  if love.keyboard.isDown("down") and player.yPos<love.graphics.getHeight()-player.height then
    player.yPos = player.yPos + dt * speed
  elseif love.keyboard.isDown("up") and player.yPos>0 then
    player.yPos = player.yPos - dt * speed
  end

  if love.keyboard.isDown("right") and player.xPos<love.graphics.getWidth()-player.width then
    player.xPos = player.xPos + dt * speed
  elseif love.keyboard.isDown("left") and player.xPos>0 then
    player.xPos = player.xPos - dt * speed
  end

  if love.keyboard.isDown("space") then
    if canFire then
      torpedo = {xPos = player.xPos + player.width, yPos = player.yPos + player.height/2, width = 16, height=16, speed=400, img = torpedoImage}
      table.insert(torpedoes, torpedo)

      canFire = false
      torpedoTimer = torpedoTimerMax
    end
  end

  for index, torpedo in ipairs(torpedoes) do
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
  end

  torpedoTimer = torpedoTimer - dt
  if torpedoTimer <= 0 then
    canFire = true
  end
end
