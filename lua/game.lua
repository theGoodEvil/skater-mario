module(..., package.seeall)

local tiled = require "tiled"

local KEY_A = 97
local KEY_D = 100

local keyDown = {}
local started = false

function onCreate()
  local layer = flower.Layer()
  layer:setClearColor(92 / 255, 148 / 255, 252 / 255)
  layer:setScene(scene)

  local tileMap = tiled.TileMap()
  tileMap:loadLueFile("level1.lua")
  tileMap:setLayer(layer)

  scene.camera = flower.Camera()
  layer:setCamera(scene.camera)
end

local function onKeyDown(e)
  keyDown[e.key] = true

  if not started then
    started = e.key == KEY_A and keyDown[KEY_D] or e.key == KEY_D and keyDown[KEY_A]
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
