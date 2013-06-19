module(..., package.seeall)

function onCreate()
  local layer = flower.Layer()
  layer:setScene(scene)

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
