module(..., package.seeall)

local tiled = require "tiled"

local PLAYER_OFFSET_LEFT = 3 * 16

local KEY_A = 97
local KEY_D = 100

local keyDown = {}
local started = false

function onCreate()
  local layer = flower.Layer()
  layer:setClearColor(92 / 255, 148 / 255, 252 / 255)
  layer:setScene(scene)

  scene.tileMap = tiled.TileMap()
  scene.tileMap:loadLueFile("level1.lua")
  scene.tileMap:setLayer(layer)

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

local function start()
  started = true
  scene.player:moveLoc(800, 0, 0, 5, MOAIEaseType.LINEAR)
end

local function onKeyDown(e)
  keyDown[e.key] = true

  if not started then
    bothKeysDown = e.key == KEY_A and keyDown[KEY_D] or e.key == KEY_D and keyDown[KEY_A]
    if bothKeysDown then start() end
  end
end

local function onKeyUp(e)
  keyDown[e.key] = false
end

function onOpen()
  flower.InputMgr:addEventListener(flower.Event.KEY_DOWN, onKeyDown)
  flower.InputMgr:addEventListener(flower.Event.KEY_UP, onKeyUp)
end

function onClose()
  flower.InputMgr:removeEventListener(flower.Event.KEY_DOWN, onKeyDown)
  flower.InputMgr:removeEventListener(flower.Event.KEY_UP, onKeyUp)
end
