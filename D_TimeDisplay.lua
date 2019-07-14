local TimeDisplay = {}
TimeDisplay.__index = TimeDisplay

function TimeDisplay:create()
  local this = {}
  this.dx = math.random(0, 29)
  this.dy = math.random(25, 44)

  this.name = "Uhr"
  setmetatable(this, TimeDisplay)

  clock.osTime = clock.getOsTime()
  return this
end

--Zeige die Zeit auf einem zufälligem Punkt des Displays an
function TimeDisplay:show()
  --print(clock.getBitSecond(),(math.floor(clock.time.second/10)<<4)+(clock.time.second%10),clock.time.second)
  local minute = copy(clock.osTime.min)
  local hour = copy(clock.osTime.hour)
  local second = copy(clock.osTime.sec)

  if (clock.osTime.sec == 0) then
    self.dx = math.random(1, 30)
    self.dy = math.random(1, 44)
  end
  if(clock.osTime.sec < 10)then
    second = "0"..tostring(second)
  end
  if(clock.osTime.min < 10)then
    minute = "0"..tostring(minute)
  end
  if(clock.osTime.hour < 10)then
    hour = "0"..tostring(hour)
  end

  display.setfont(gdisplay.FONT_DEJAVU24)
  display.write({self.dx, self.dy}, hour..":"..minute)
  display.setfont(gdisplay.FONT_DEFAULT)
  display.write({self.dx + 73, self.dy + 9}, second)

  if clock.osTime.sec == 0 then
    --Fuelle mit schwarz
    --oben
    display.rect({0, 0}, 127, self.dy, gdisplay.BLACK, gdisplay.BLACK)

    --links
    display.rect({0, 0}, self.dx + 1, 63, gdisplay.BLACK, gdisplay.BLACK)

    --unten
    display.rect({127, 63}, - 127, 0 - (63 - (self.dy + 19)), gdisplay.BLACK, gdisplay.BLACK)

    --rechts
    display.rect({127, 63}, 0 - (127 - (self.dx + 90)), - 63, gdisplay.BLACK, gdisplay.BLACK)

    --ueber sec
    display.rect({self.dx + 73, self.dy + 9}, 17, - 9, gdisplay.BLACK, gdisplay.BLACK)
  end
end

function TimeDisplay:set()
  changeMode("Light")
end

function TimeDisplay:next()
  changeMode("Player")
end

function TimeDisplay:up()
  if led.is_active() == false then
    led.start("Sunrise", {seconds = 10, offset = 0.3})
  else
    led.start("Sunrise", {seconds = 20, r = 0, g = 0, b = 0, offset = 0})
  end
end

function TimeDisplay:down()
  if led.is_active() == false then
    led.start("Sunrise", {seconds = 10, front=false, offset = 0})
  else
    led.start("Sunrise", {seconds = 20, r = 0, g = 0, b = 0, offset = 0})
  end
end

return TimeDisplay
