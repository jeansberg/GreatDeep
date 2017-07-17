function love.load()
  submarineImage = love.graphics.newImage("resources/images/submarine.png")
  torpedoImage = love.graphics.newImage("resources/images/torpedo.png")
  squidImage = love.graphics.newImage("resources/images/squid.png")
  sharkImage = love.graphics.newImage("resources/images/shark.png")
  swordfishImage = love.graphics.newImage("resources/images/swordfish.png")

  torpedoTimerMax = 0.2
  torpedoStartSpeed = 100
  torpedoMaxSpeed = 300

  squidSpeed = 200
  sharkSpeed = 250
  swordfishSpeed = 300
  chargeSpeed = 500

  spawnTimerMax = 0.5

  startGame()
end

function startGame()
  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  torpedoes = {}
  enemies = {}

  canFire = true
  torpedoTimer = torpedoTimerMax
  spawnTimer = 0
end

function love.draw()
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2)

  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
  end

  for index, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.xPos, enemy.yPos, 0, 2, 2)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateTorpedoes(dt)
  updateEnemies(dt)
  checkCollisions()
end

-- Player logic

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
end

-- Projectile logic

function updateTorpedoes(dt)
  for i=table.getn(torpedoes), 1, -1 do
    torpedo = torpedoes[i]
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
    if torpedo.speed < torpedoMaxSpeed then
      torpedo.speed = torpedo.speed + dt * 100
    end
    if torpedo.xPos > love.graphics.getWidth() then
      table.remove(torpedoes, i)
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

-- Enemy logic

function updateEnemies(dt)
  if spawnTimer > 0 then
    spawnTimer = spawnTimer - dt
  else
    spawnEnemy()
  end

  for i=table.getn(enemies), 1, -1 do
    enemy=enemies[i]
    enemy.update = enemy:update(dt)
    if enemy.xPos < -enemy.width then
      table.remove(enemies, i)
    end
  end
end

function spawnEnemy()
  y = love.math.random(0, love.graphics.getHeight() - 64)
  enemyType = love.math.random(0, 2)
  if enemyType == 0 then
    enemy = Enemy:new{yPos = y, speed = squidSpeed, img = squidImage, update=moveLeft}
  elseif enemyType == 1 then
    enemy = Enemy:new{yPos = y, speed = sharkSpeed, img = sharkImage, update=moveToPlayer}
  else
    enemy = Enemy:new{yPos = y, speed = swordfishSpeed, img = swordfishImage, update=chargePlayer}
  end
  table.insert(enemies, enemy)

  spawnTimer = spawnTimerMax
end

Enemy = {xPos = love.graphics.getWidth(), yPos = 0, width = 64, height = 64}

function Enemy:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function moveLeft(obj, dt)
  obj.xPos = obj.xPos - obj.speed * dt
  return moveLeft
end

function moveToPlayer(obj, dt)
  xSpeed = math.sin(45) * obj.speed
  ySpeed = math.cos(45) * obj.speed
  if (obj.yPos - player.yPos) > 10 then
    obj.yPos = obj.yPos - ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
  elseif (obj.yPos - player.yPos) < -10 then
    obj.yPos = obj.yPos + ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
  else
    obj.xPos = obj.xPos - obj.speed * dt
  end
  return moveToPlayer
end

function chargePlayer(obj, dt)
  xDistance = math.abs(obj.xPos - player.xPos)
  yDistance = math.abs(obj.yPos - player.yPos)
  distance = math.sqrt(yDistance^2 + xDistance^2)
  if distance < 150 then
    obj.speed = chargeSpeed
    return moveLeft
  end 
  moveToPlayer(obj, dt)
  return chargePlayer
end

-- Helper functions

function checkCollisions()
  for index, enemy in ipairs(enemies) do
    if intersects(player, enemy) or intersects(enemy, player) then
      startGame()
    end

    for index2, torpedo in ipairs(torpedoes) do
      if intersects(enemy, torpedo) then
        table.remove(enemies, index)
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