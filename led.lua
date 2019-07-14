local oneLED = {}
oneLED.__index = oneLED

function oneLED:create(i)
  local this = {}
  this.num = i
  this.r = 0
  this.g = 0
  this.b = 0
  setmetatable(this, oneLED)
  return this
end

function oneLED:update()
  led.neo:setPixel(self.num - 1, self.r, self.g, self.b)
end

function oneLED:red(v)
  if v < 256 then self.r = math.floor(v) else print("LED_OVF_r", v) end
  self:update()
end

function oneLED:green(v)
  if v < 256 then self.g = math.floor(v) else print("LED_OVF_g", v) end
  self:update()
end

function oneLED:blue(v)
  if v < 256 then self.b = math.floor(v) else print("LED_OVF_b", v) end
  self:update()
end

function oneLED:set(r, g, b)
  if r < 256 and b < 256 and g < 256 then
    self.r = r
    self.g = g
    self.b = b
  else
    print("LED-OVF", r, g, b)
  end
  self:update()
end

---------------------------LED
local led = {}
led.mode = {}
--[[
led.modes = {}
led.modes.Sunrise = require "L_Sunrise"
led.modes.Fade = require "L_Fade"
led.modes.Rainbow = require "L_Rainbow"
--]]

--Wenn das Bild verändert werden soll (von Modus abhängig)
function led.update()
  if led.mode.update then
    led.mode:update()
  end
end

function led.setColor(r, g, b)
  for i = 1, 6 do
    for a = 1, 9 do
      led.leds.front[i][a]:set(r, g, b)
    end
  end
  for i = 1, 6 do
    led.leds.back[i]:set(r, g, b)
  end
end

--Die LEDS
led.neo = neopixel.attach(neopixel.WS2812B, pio.GPIO14, 60)
--der LED Speicher

led.leds = {}

led.leds.front = {}
for a = 1, 6 do
  led.leds.front[a] = {}
  for i = 1, 9 do
    led.leds.front[a][i] = oneLED:create((a - 1) * 9 + i)
  end
end

led.leds.back = {}
for i = 1, 6 do
  led.leds.back[i] = oneLED:create(i + 54)
end

function led.show()
  if addTodo then
    addTodo(function() led.neo:update() end)
  else
    led.neo:update()
  end
end

function led.is_active(w)
  if w == "front" or w == nil then
    for a = 1, 6 do
      for b = 1, 9 do
        if led.leds.front[a][b].r ~= 0 then
          return true
        elseif led.leds.front[a][b].g ~= 0 then
          return true
        elseif led.leds.front[a][b].b ~= 0 then
          return true
        end
      end
    end
  end
  if w == "back" or w == nil then
    for a = 1, 6 do
      if led.leds.back[a].r ~= 0 then
        return true
      elseif led.leds.back[a].g ~= 0 then
        return true
      elseif led.leds.back[a].b ~= 0 then
        return true
      end
    end
  end
  return false
end

--Starte einen Modus
function led.start(mode, val)
  local function innerstart()
    led.tmr = false
    --print("Timer Aus")
    --if not (type(led.modes[mode]) == "table") then lerror(mode.." :wrong mode") return nil end
    --led.mode = led.modes[mode]:create(val)

    --
    for k in pairs(package.loaded) do
      if k:find("L_") then
        package.loaded[k] = nil
        print(k .. " aus Speicher entfernt")
      end
    end
    local tmp, ok = require("L_"..mode)
    print("geladen")
    if not ok then
      led.mode = tmp:create(val)
    else
      Modus = require("D_Error"):create("LED-Laden fehlgeschlagen")
    end
    --]]
    print("Erzeugt")
    led.tmr = true
    print("gestartet")
  end
  if addTodo then
    addTodo(function() innerstart() end)
  else
    print("Unsicherer Aufruf-LED.start")
    innerstart()
  end
end

function led.stop()
  led.tmr = false
  led.mode = {}
end

led.show()
return led
