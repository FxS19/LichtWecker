local Fade = {}
Fade.__index = Fade

function Fade:create(val)
  print("Creating")
  local this = {}
  local ok,l=pcall(nvs.read,"settings", "Lampe")
  if not ok then l=10 end
  this.brightness=11-l
  this.ok = true
  this.name = "Rainbow"
  this.r = 0
  this.b = 0
  this.g = 0
  this.speed = 2
  this.ctr = 1
  this.front = true
  this.back = true
  --Farbe und parameter übertragen
  if val then
    for k, v in pairs(val) do
      this[k] = v
    end
  end
  setmetatable(this, Fade)
  return this
end

--mit 25Hz aufgerufen
function Fade:update()

  local function Wheel(wp)
    if wp < 85 then
      return wp * 3, 255 - wp * 3, 0
    elseif wp < 170 then
      wp = wp - 85
      return 255 - wp * 3, 0, wp * 3
    else
      wp = wp - 170
      return 0, wp * 3, 255 - wp * 3
    end
  end

  if self.ctr < 255 then
    self.ctr = self.ctr + 1
  else
    self.ctr = 0
  end
  for j = 1, 6 do
    for i = 1, 9 do
      local r,g,b= Wheel((i*2 + self.ctr + j*2)%256)
      led.leds.front[j][i]:set(math.floor(r/self.brightness), math.floor(g/self.brightness), math.floor(b/self.brightness))
    end
  end

  led.show()
end

return Fade
