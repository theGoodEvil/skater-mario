io.stdout:setvbuf("no")

flower = require "flower"

flower.Font.DEFAULT_FONT = "../img/emulogic.ttf"

local scale = 3
flower.openWindow("skater mario", scale * 256, scale * 224, scale)
flower.openScene("game")
