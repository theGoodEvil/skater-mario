module(..., package.seeall)

local statemachine = require "statemachine"
local tiled = require "tiled"

local PLAYER_OFFSET_LEFT = 3 * 16
local PLAYER_JUMP_TIME = 0.3
local PLAYER_JUMP_HEIGHT = 64

local KEY_A = 97
local KEY_D = 100

local started = false

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

  scene.player = flower.SheetImage("../img/mario-players.png")
  scene.player:setTileSize(16, 16)
  scene.player:setIndex(51)
  scene.player:setLoc(PLAYER_OFFSET_LEFT, 11 * 16)
  scene.player:setLayer(layer)

  scene.camera = flower.Camera()
  layer:setCamera(scene.camera)
end

function onUpdate()
  x = scene.player:getLoc()
  cameraX = math.min(
    x - PLAYER_OFFSET_LEFT,
    scene.tileMap:getWidth() - flower.viewWidth)
  scene.camera:setLoc(cameraX, 0)
end

local levelState = statemachine.create({
  initial = "stopped",
  events = {
    { name = "start", from = "stopped", to = "running" },
    { name = "jump", from = "running", to = "jumping" },
    { name = "land", from = "jumping", to = "running" }
  }
})

levelState.did.apply.start = function()
  scene.player:moveLoc(800, 0, 0, 5, MOAIEaseType.LINEAR)
end

levelState.did.apply.jump = function()
  scene.player:moveLoc(0, -PLAYER_JUMP_HEIGHT, 0, PLAYER_JUMP_TIME, MOAIEaseType.EASE_IN)
  flower.Executors.callLaterTime(PLAYER_JUMP_TIME, function()
    scene.player:moveLoc(0, PLAYER_JUMP_HEIGHT, 0, PLAYER_JUMP_TIME, MOAIEaseType.EASE_OUT)
  end)
  flower.Executors.callLaterTime(PLAYER_JUMP_TIME, function()
    levelState:land()
  end)
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
