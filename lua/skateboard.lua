module(..., package.seeall)

local tiled = require "tiled"

local PLAYER_OFFSET_LEFT = 3 * 16
local PLAYER_OFFSET_TOP = 11 * 16

local KEY_A = 97
local KEY_D = 100

function onCreate()
  local layer = flower.Layer()
  layer:setClearColor(92 / 255, 148 / 255, 252 / 255)
  layer:setScene(scene)

  scene.tileMap = tiled.TileMap()
  scene.tileMap:loadLueFile("level-skateboard.lua")
  scene.tileMap:setLayer(layer)

  for _, tileSet in ipairs(scene.tileMap:getTilesets()) do
    tileSet:loadTexture():setFilter(MOAITexture.GL_NEAREST)
  end

  scene.player = flower.SheetImage("../img/mario-players.png")
  scene.player:setTileSize(16, 16)
  scene.player:setIndex(51)
  scene.player:setLoc(PLAYER_OFFSET_LEFT, PLAYER_OFFSET_TOP)
  scene.player:setLayer(layer)

  scene.camera = flower.Camera()
  layer:setCamera(scene.camera)
end

function onUpdate()
  -- update camera
  x, y = scene.player:getLoc()
  cameraX = math.min(
    x - PLAYER_OFFSET_LEFT,
    scene.tileMap:getWidth() - flower.viewWidth)
  scene.camera:setLoc(cameraX, 0)
end

local function moveForward()
  scene.player:moveLoc(16, 0, 0, 0.2)
end

local nextKey = nil

local function onKeyDown(e)
  local key = e.key
  if nextKey == nil or key == nextKey then
    if e.key == KEY_A then
      moveForward()
      nextKey = KEY_D
    elseif e.key == KEY_D then
      moveForward()
      nextKey = KEY_A
    end
  end
end

function onOpen()
  flower.InputMgr:addEventListener(flower.Event.KEY_DOWN, onKeyDown)
end

function onClose()
  flower.InputMgr:removeEventListener(flower.Event.KEY_DOWN, onKeyDown)
end
