local Sunrise = {}
Sunrise.__index = Sunrise
--led.start("Sunrise",{r=150,g=55,b=5,offset=0,seconds=10})
function Sunrise:create(val)
  if not val then val={} end
  if val.seconds == nil then val.seconds = 20 end
  print("Creating")
  local this = {}
  this.totalSteps = val.seconds * 25
  --Anzahl der Aufrufe
  this.name = "Sunrise"
  this.step = 0
  local ok
  ok,this.brightness=pcall(nvs.read,"settings", "Lampe")
  if not ok then this.brightness=10 end
  this.brightness=11-this.brightness
  this.r = 250
  this.g = 80
  this.b = 10
  this.offset = 0.5
  this.front=true
  this.back=true
  --Werte überschreiben
  for k, v in pairs(val) do
    this[k] = v
  end
  this.r = math.floor(this.r/this.brightness)
  this.g = math.floor(this.g/this.brightness)
  this.b = math.floor(this.b/this.brightness)

  setmetatable(this, Sunrise)
  --led.setColor(0, 0, 0)
  return this
end
--[[
led.start("Sunrise",5)
]]
--mit 25Hz aufgerufen
function Sunrise:update()

  --Den wert der led-Farbe berechnen
  local function calcValue(input, real, percent)
    --gewünschte Farbe--Aktuelle Farbe--Prozent
    --local l =input
    local a=math.floor(real * (1 - percent))
    local l = math.floor(input*percent)
    --[[
    if real>input then
      a=a*-1
    end
    --]]
    l=l+a
    if l > 255 then print("ovf") return 255 else return l end
  end

  local function updateBack(r, g, b, p)
    --Indirekte Lampe
    --die Farbe wird über den Streifen geschmiert
    for i = 1, 6 do
      local lper = p^i
      --print(calcValue(r,led.leds.back[i].r,p), calcValue(g,led.leds.back[i].g,p), calcValue(b,led.leds.back[i].b,p))

      led.leds.back[i]:set(calcValue(r, led.leds.back[i].r, lper), calcValue(g, led.leds.back[i].g, lper), calcValue(b, led.leds.back[i].b, lper))
    end
  end

  local function updateFront(r, g, b, p)
    --Licht Vorne
    --die Farbe wird über den Streifen geschmiert (unten links-->daigonal nach oben rechts)
    local per = p
    for i = 1, 6 do
      local lper = per
      for j = 1, 9 do
        lper = per^((j+1)/2)
        if(j == 2) then
          per = lper
        end
        led.leds.front[i][j]:set(calcValue(r, led.leds.front[i][j].r, lper), calcValue(g, led.leds.front[i][j].g, lper), calcValue(b, led.leds.front[i][j].b, lper))
      end
    end
  end

  self.step = self.step + 1
  local percent = self.step / self.totalSteps --(von 0--1)

  if self.step%125 == 1 then print(math.floor(percent * 100).."%") end

  if self.back then updateBack(self.r, self.g, self.b, percent) end
  if self.front and percent >= self.offset then
    updateFront(self.r, self.g, self.b, (percent - self.offset) * (1 / (1 - self.offset)))
  end
  led.show()
  if self.step >= self.totalSteps then
    led.stop()
    print("Fertig")
  end
end
return Sunrise
