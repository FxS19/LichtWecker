local Fade = {}
Fade.__index = Fade
--[[
led.start("Fade",{speed=2,r=50,g=20,b=40})

led.start("Fade",{speed=2,r=0,g=0,b=0})

]]
function Fade:create(val)
  print("Creating")
  local this = {}
  this.ok = true
  this.name = "Fade"
  --Wunschfarbe
  local ok
  ok,this.brightness=pcall(nvs.read,"settings", "Lampe")
  if not ok then this.brightness=10 end
  this.brightness=11-this.brightness
  this.r = 250
  this.g = 80
  this.b = 10
  this.speed = 1
  this.ctr = 1
  this.front = true
  this.back = true
  --Farbe und parameter übertragen
  if val then
    for k, v in pairs(val) do
      this[k] = v
    end
  end
  this.r = math.floor(this.r/this.brightness)
  this.g = math.floor(this.g/this.brightness)
  this.b = math.floor(this.b/this.brightness)
  setmetatable(this, Fade)
  return this
end

--mit 25Hz aufgerufen
function Fade:update()
  if self.ctr < self.speed then
    self.ctr = self.ctr + 1
    return 0
  else
    self.ctr = 1
  end
  self.ok = true

  if self.back then
    --Leselampe
    for a, b in pairs(led.leds.back) do
      if b.r ~= self.r then
        if b.r > self.r then
          b:red(b.r - 1)
        else
          b:red(b.r + 1)
        end
        self.ok = false
      end

      if b.g ~= self.g then
        if b.g > self.g then
          b:green(b.g - 1)
        else
          b:green(b.g + 1)
        end
        self.ok = false
      end

      if b.b ~= self.b then
        if b.b > self.b then
          b:blue(b.b - 1)
        else
          b:blue(b.b + 1)
        end
        self.ok = false
      end
    end
  end
  if self.front then
    --Gehe jede LED durch
    for i = 1, 6 do
      for a, b in pairs(led.leds.front[i]) do
        if b.r ~= self.r then
          if b.r > self.r then
            b:red(b.r - 1)
          else
            b:red(b.r + 1)
          end
          self.ok = false
        end

        if b.g ~= self.g then
          if b.g > self.g then
            b:green(b.g - 1)
          else
            b:green(b.g + 1)
          end
          self.ok = false
        end

        if b.b ~= self.b then
          if b.b > self.b then
            b:blue(b.b - 1)
          else
            b:blue(b.b + 1)
          end
          self.ok = false
        end
      end
    end
  end
  if self.ok then led.stop() print("Fertig") end
  led.show()
end

return Fade
