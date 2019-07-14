local BinaryClock = {}
BinaryClock.__index = BinaryClock

function BinaryClock:create(val)
  print("Creating")
  local this = {}
  local ok, l = pcall(nvs.read, "settings", "Lampe")
  if not ok then l = 10 end
  this.brightness = 11 - l
  this.name = "BinaryClock"
  this.ctr = 0
  this.lastsec = clock.osTime.sec
  --Farbe und parameter übertragen
  if val then
    for k, v in pairs(val) do
      this[k] = v
    end
  end
  led.setColor(0, 0, 0)
  setmetatable(this, BinaryClock)
  return this
end

--mit 25Hz aufgerufen
function BinaryClock:update()
  if clock.osTime.sec == self.lastsec then
    self.ctr = self.ctr + 1
  else
    --1x pro sekunde
    self.lastsec = copy(clock.osTime.sec)
    local function toColor(num)
      -- returns a table of Color, least significant first.
      local t = {} -- will contain the Color
      while num > 0 do
        rest = math.fmod(num, 2)
        --if rest == 1 then t[#t + 1] = 20 else t[#t + 1] = 0 end
        t[#t + 1] = rest
        num = (num - rest) / 2
      end
      return t
    end
    local function c(l, val)
      val = val or 0
      if l == 1 then
        val = val * 2
      end
      return val
    end
    local sec = toColor(clock.osTime.sec)
    local min = toColor(clock.osTime.min)
    local hour = toColor(clock.osTime.hour)
    for i = 1, 6 do
      for l = 0, 2 do
        led.leds.front[i][7 + l]:red(c(l, sec[i]))
        led.leds.front[i][4 + l]:green(c(l, min[i]))
        led.leds.front[i][1 + l]:blue(c(l, hour[i]))
      end
    end
    led.show()
  end
end

return BinaryClock
