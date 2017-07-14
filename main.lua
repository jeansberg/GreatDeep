function love.load()
  submarineImage = love.graphics.newImage("resources/images/submarine.png")
  torpedoImage = love.graphics.newImage("resources/images/torpedo.png")
  squidImage = love.graphics.newImage("resources/images/squid.png")

  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  torpedoes = {}
  squids = {}

  canFire = false
  torpedoTimerMax = 0.2
  torpedoTimer = torpedoTimerMax
  torpedoStartSpeed = 100
  torpedoMaxSpeed = 300

  squidTimerMax = 1
  squidTimer = 0
  squidSpeed = 200
end

function restart()
  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  torpedoes = {}
  squids = {}
end

function love.draw()
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2)

  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
  end

  for index, squid in ipairs(squids) do
    love.graphics.draw(squid.img, squid.xPos, squid.yPos, 0, 2, 2)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateTorpedoes(dt)
  updateSquids(dt)

  checkCollisions()
end

function updatePlayer(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")

  speed = player.speed
  if((down or up) and (left or right)) then
    speed = speed / math.sqrt(2)
  end

  if down and player.yPos<love.graphics.getHeight()-player.height then
    player.yPos = player.yPos + dt * speed
  elseif up and player.yPos>0 then
    player.yPos = player.yPos - dt * speed
  end

  if right and player.xPos<love.graphics.getWidth()-player.width then
    player.xPos = player.xPos + dt * speed
  elseif left and player.xPos>0 then
    player.xPos = player.xPos - dt * speed
  end

  if love.keyboard.isDown("space") then
    torpedoSpeed = torpedoStartSpeed
    if(left) then
      torpedoSpeed = torpedoSpeed - player.speed/2
    elseif(right) then
      torpedoSpeed = torpedoSpeed + player.speed/2
    end
    spawnTorpedo(player.xPos + player.width, player.yPos + player.height/2, torpedoSpeed)
  end

  if torpedoTimer > 0 then
    torpedoTimer = torpedoTimer - dt
  else
    canFire = true
  end

  if squidTimer > 0 then
    squidTimer = squidTimer - dt
  else
    spawnSquid()
  end
end

function updateTorpedoes(dt)
  print(table.getn(torpedoes))
  for index, torpedo in ipairs(torpedoes) do
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
    if torpedo.speed < torpedoMaxSpeed then
      torpedo.speed = torpedo.speed + dt * 100
    end
    if torpedo.xPos > love.graphics.getWidth() then
      table.remove(torpedoes, index)
    end
  end
end

function updateSquids(dt)
  for index, squid in ipairs(squids) do
    squid.xPos = squid.xPos - squidSpeed * dt
    if squid.xPos < 0 then
      squid = nil
    end
  end
end

function checkCollisions()
  for index, squid in ipairs(squids) do
    if intersects(player, squid) or intersects(squid, player) then
      restart()
    end

    for index2, torpedo in ipairs(torpedoes) do
      if intersects(squid, torpedo) then
        table.remove(squids, index)
        table.remove(torpedoes, index2)
        break
      end
    end
  end
end

function intersects(rect1, rect2)
  if rect1.xPos < rect2.xPos and rect1.xPos + rect1.width > rect2.xPos and
     rect1.yPos < rect2.yPos and rect1.yPos + rect1.height > rect2.yPos then
    return true
  else
    return false
  end
end

function spawnTorpedo(x, y, speed)
  if canFire then
    torpedo = {xPos = x, yPos = y, width = 16, height=16, speed=speed, img = torpedoImage}
    table.insert(torpedoes, torpedo)

    canFire = false
    torpedoTimer = torpedoTimerMax
  end
end

function spawnSquid()
  y = love.math.random(0, love.graphics.getHeight() - 64)
  squid = {xPos = love.graphics.getWidth(), yPos = y, width = 64, height = 64, speed = squidSpeed, img = squidImage}
  table.insert(squids, squid)

  squidTimer = squidTimerMax
end
