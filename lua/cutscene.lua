module(..., package.seeall)

function onCreate()
  local layer = flower.Layer()
  layer:setScene(scene)

  scene.label = flower.Label("", 256 - 32, 224 - 32, flower.Font.DEFAULT_FONT, 16)
  scene.label:setLoc(16, 16)
  scene.label:setLayer(layer)
end

function onOpen(e)
  local params = e.data
  scene.label:setString(params.message)

  flower.Executors.callLaterTime(4, function()
    flower.openScene(params.nextScene)
    flower.closeScene()
  end)
end
