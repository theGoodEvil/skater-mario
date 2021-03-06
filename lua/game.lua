module(..., package.seeall)

local statemachine = require "statemachine"
local tiled = require "tiled"

local PLAYER_OFFSET_LEFT = 3 * 16
local PLAYER_OFFSET_TOP = 11 * 16
local PLAYER_JUMP_TIME = 0.4
local PLAYER_JUMP_HEIGHT = 80

local TILE_IS_OBSTACLE = {}
TILE_IS_OBSTACLE[265] = true
TILE_IS_OBSTACLE[266] = true
TILE_IS_OBSTACLE[298] = true
TILE_IS_OBSTACLE[299] = true

local KEY_A = 97
local KEY_D = 100

function onCreate()

  local layer = flower.Layer()
  layer:setClearColor(92 / 255, 148 / 255, 252 / 255)
  layer:setScene(scene)

  scene.tileMap = tiled.TileMap()
  scene.tileMap:loadLueFile("level1.lua")
  scene.tileMap:setLayer(layer)

  for _, tileSet in ipairs(scene.tileMap:getTilesets()) do
    tileSet:loadTexture():setFilter(MOAITexture.GL_NEAREST)
  end

  scene.player = flower.Group()
  scene.player:setLoc(PLAYER_OFFSET_LEFT, PLAYER_OFFSET_TOP)
  scene.player:setLayer(layer)

  local playerBottom = flower.SheetImage("../img/mario-players.png")
  playerBottom:setTileSize(16, 16)
  playerBottom:setIndex(34)
  playerBottom:setPriority(1000)
  scene.player:addChild(playerBottom)

  local playerTop = flower.SheetImage("../img/mario-players.png")
  playerTop:setTileSize(16, 16)
  playerTop:setIndex(12)
  playerTop:setLoc(0, -16)
  playerTop:setPriority(1000)
  scene.player:addChild(playerTop)

  scene.camera = flower.Camera()
  layer:setCamera(scene.camera)
end

local levelState = statemachine.create({
  initial = "stopped",
  events = {
    { name = "start", from = "stopped",                to = "running" },
    { name = "stop",  from = { "running", "jumping" }, to = "stopped" },
    { name = "jump",  from = "running",                to = "jumping" },
    { name = "land",  from = "jumping",                to = "running" }
  }
})

levelState.did.apply.start = function()
  local distance = scene.tileMap:getWidth()
  scene.playerAction = scene.player:moveLoc(distance, 0, 0, distance / 160, MOAIEaseType.LINEAR)
end

levelState.did.apply.stop = function()
  scene.playerAction:stop()

  -- reset player
  x, y = scene.player:getLoc()
  scene.player:setLoc(16 * (x / 16 + 2), PLAYER_OFFSET_TOP)

  -- play intermediate level
  flower.gotoScene("cutscene", {
    message = "your skateboard is gone. go pick it up again!",
    next = function() flower.gotoScene("skateboard") end
  })
end

levelState.did.apply.jump = function()
  scene.playerAction:addChild(
    scene.player:moveLoc(0, -PLAYER_JUMP_HEIGHT, 0, PLAYER_JUMP_TIME, MOAIEaseType.EASE_IN))

  flower.Executors.callLaterTime(PLAYER_JUMP_TIME, function()
    scene.playerAction:addChild(
      scene.player:moveLoc(0, PLAYER_JUMP_HEIGHT, 0, PLAYER_JUMP_TIME, MOAIEaseType.EASE_OUT))
  end)
  flower.Executors.callLaterTime(2 * PLAYER_JUMP_TIME, function()
    levelState:land()
  end)
end

function gameOver()
  scene.playerAction:stop()

  -- reset player
  x, y = scene.player:getLoc()
  scene.player:setLoc(16 * (x / 16 + 2), PLAYER_OFFSET_TOP)

  -- play intermediate level
  flower.gotoScene("cutscene", {
    message = "well done. you made the ride!!",
    next = function() flower.gotoScene("game") end
  })
end

function onUpdate()
  -- update camera
  x, y = scene.player:getLoc()
  cameraX = math.min(
    x - PLAYER_OFFSET_LEFT,
    scene.tileMap:getWidth() - flower.viewWidth)
  scene.camera:setLoc(cameraX, 0)

  if x >= 3200 then
    gameOver()
  end

  -- check collision
  tileX = math.floor(x / 16)
  tileY = math.floor(y / 16)
  local layer = scene.tileMap:getMapLayers()[1]
  local gidLeft = layer:getGid(tileX, tileY)
  local gidRight = layer:getGid(tileX + 1, tileY)

  if TILE_IS_OBSTACLE[gidLeft] or TILE_IS_OBSTACLE[gidRight] then
    levelState:stop()
  end
end

local keyState = statemachine.create({
  initial = "up",
  events = {
    { name = "keysDown", from = "up", to = "down" },
    { name = "keysUp", from = "down", to = "up" }
  }
})

keyState.did.enter.down = function()
  levelState:start()
end

keyState.did.enter.up = function(self, name, from, to)
  levelState:jump()
end

local keyIsDown = {}

local function onKeyDown(e)
  keyIsDown[e.key] = true
  if keyIsDown[KEY_A] == true and keyIsDown[KEY_D] == true then
    keyState:keysDown()
  end
end

local function onKeyUp(e)
  keyIsDown[e.key] = false
  if keyIsDown[KEY_A] ~= true and keyIsDown[KEY_D] ~= true then
    keyState:keysUp()
  end
end

function onOpen()
  flower.InputMgr:addEventListener(flower.Event.KEY_DOWN, onKeyDown)
  flower.InputMgr:addEventListener(flower.Event.KEY_UP, onKeyUp)
end

function onClose()
  flower.InputMgr:removeEventListener(flower.Event.KEY_DOWN, onKeyDown)
  flower.InputMgr:removeEventListener(flower.Event.KEY_UP, onKeyUp)
end
