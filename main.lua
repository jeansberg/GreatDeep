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
  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2)

  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
  end
end

function love.update(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")

  speed = player.speed
  if((down or up) and (left or right)) then
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
    torpedoSpeed = torpedoStartSpeed
    if(left) then
      torpedoSpeed = torpedoSpeed - player.speed/2
    elseif(right) then
      torpedoSpeed = torpedoSpeed + player.speed/2
    end
    spawnTorpedo(player.xPos + player.width, player.yPos + player.height/2, torpedoSpeed)
  end

  for index, torpedo in ipairs(torpedoes) do
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
    if torpedo.speed < torpedoMaxSpeed then
      torpedo.speed = torpedo.speed + dt * 100
    end
  end

  torpedoTimer = torpedoTimer - dt
  if torpedoTimer <= 0 then
    canFire = true
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
