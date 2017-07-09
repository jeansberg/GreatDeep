function love.load()
  submarineImage = love.graphics.newImage("resources/images/submarine.png")
  torpedoImage = love.graphics.newImage("resources/images/torpedo.png")

  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  torpedoes = {}

  canFire = false
  torpedoTimerMax = 0.2
  torpedoTimer = torpedoTimerMax
  torpedoStartSpeed = 100
  torpedoMaxSpeed = 300
end

function love.draw()
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2)
  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateTorpedoes(dt)
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

  torpedoTimer = torpedoTimer - dt
  if torpedoTimer <= 0 then
    canFire = true
  end
end

function updateTorpedoes(dt)
  for index, torpedo in ipairs(torpedoes) do
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
    if torpedo.speed < torpedoMaxSpeed then
      torpedo.speed = torpedo.speed + dt * 100
    end
    if torpedo.xPos > love.graphics.getWidth() then
      torpedo = nil
    end
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
