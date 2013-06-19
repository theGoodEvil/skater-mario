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
  local char = string.char(e.key)
end

function onOpen()
  flower.InputMgr:addEventListener(flower.Event.KEY_DOWN, onKeyDown)
end

function onClose()
  flower.InputMgr:removeEventListener(flower.Event.KEY_DOWN, onKeyDown)
end
