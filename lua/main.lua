io.stdout:setvbuf("no")

flower = require "flower"

local scale = 3

flower.openWindow("rhythmic", scale * 256, scale * 224, scale)
flower.openScene("game")
