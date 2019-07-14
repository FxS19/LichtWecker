local MODE = {}
MODE.__index = MODE

function MODE:create()
  local this = {}
  nixDoTimer = 20
  this.name = "SleepTmr"
  this.minutes = 10
  this.first = true
  setmetatable(this, MODE)

  clock.osTime = clock.getOsTime()
  return this
end

function MODE:show()
  if self.first then self.first = false self:update() end
end

function MODE:update()
  --display.clear()
  display.rect({1,18},100,28,gdisplay.BLACK,gdisplay.BLACK)
  display.setfont(gdisplay.FONT_DEJAVU24)
  display.write({gdisplay.CENTER, gdisplay.CENTER}, self.minutes)
  --display.showMenue(self.name)
end

function MODE:set()
  --print("SET")
  nixDoTimer = 20
  if self.minutes < 40 then
    self.minutes = math.floor(self.minutes / 10) * 10 + 10
  else
    self.minutes = 0
  end
  self:setTimer()
  self:update()
end

function MODE:next()
  changeMode("TimeDisplay")
end

function MODE:setTimer()
  if SleepTmr then
    thread.stop(SleepTmr)
    SleepTmr=nil
  end
  if self.minutes ~= 0 then
    SleepTmr = thread.start(function()
      thread.sleep(self.minutes * 60)
      speaker.send(0x0E)
      speaker.sleep()
      SleepTmr=nil
      led.start("Sunrise", {r = 0, g = 0, b = 0, offset = 0})
    end,4096,nil,nil,"Sleep-TMR")
  end
end

function MODE:up()
  --print("UP")
  nixDoTimer = 20
  if self.minutes < 40 then
    self.minutes = self.minutes + 1
  else
    self.minutes = 0
  end
  self:setTimer()
  self:update()
end

function MODE:down()
  --print("DOWN")
  nixDoTimer = 20
  if self.minutes > 0 then
    self.minutes = self.minutes - 1
  else
    self.minutes = 40
  end
  self:setTimer()
  self:update()
end

return MODE
