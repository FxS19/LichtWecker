local AlarmSet = {}
AlarmSet.__index = AlarmSet

function AlarmSet:create(c)
  nixDoTimer = 20
  --print("Erstelle Settings")
  local this = {}
  this.corsorBlink = true
  this.num = c
  --hole den entsprechenden Alarm
  this.alarm = clock.alarms[this.num]
  --Wenn der Alarm nicht vorhanden ist
  if not (type(this.alarm) == "table") then
    this.alarm = {
      hour = 0,
      min = 0,
      sec = 0,
      wday = 1,
      enabled=true
    }
  end
  this.cursor = 0--0=Wochentag, 1=Stunde, 2=Minute
  this.modified = false
  this.name = "Wecker "..c.." stellen"
  setmetatable(this, AlarmSet)
  return this
end

function AlarmSet:show()
  self.cursorBlink = not self.cursorBlink

  local minute = copy(self.alarm.min)
  local hour = copy(self.alarm.hour)

  if(self.alarm.min < 10)then
    minute = "0"..tostring(minute)
  end
  if(self.alarm.hour < 10)then
    hour = "0"..tostring(hour)
  end

  display.setfont(gdisplay.FONT_DEJAVU24)
  if(self.cursorBlink or not (self.cursor == 0))then
    display.write({0, 20}, clock.getShortDay(2, self.alarm.wday))
  else
    display.rect({0, 20}, 49, 24, gdisplay.BLACK, gdisplay.BLACK)
  end
  --gdisplay.write({35, 20}, " ")
  if(self.cursorBlink or not (self.cursor == 1))then
    display.write({50, 20}, hour)
  else
    display.rect({50, 20}, 34, 24, gdisplay.BLACK, gdisplay.BLACK)
  end
  display.write({85, 20}, ":")
  if(self.cursorBlink or not (self.cursor == 2))then
    display.write({95, 20}, minute)
  else
    display.rect({95, 20}, 34, 24, gdisplay.BLACK, gdisplay.BLACK)
  end
  display.setfont(gdisplay.FONT_DEFAULT)
  if(self.cursorBlink or not (self.cursor == 3))then
    if self.alarm.enabled then
      display.write({10, 48}, "ON")
    else
      display.write({10, 48}, "OFF")
    end
  else
    display.rect({10, 48}, 50, 18, gdisplay.BLACK, gdisplay.BLACK)
  end
  if(self.cursorBlink or not (self.cursor == 4))then
    display.write({80, 48}, "delete")
  else
    display.rect({80, 48}, 50, 18, gdisplay.BLACK, gdisplay.BLACK)
  end
end

function AlarmSet:next()
  if self.cursor < 4 then
    self.cursor = self.cursor + 1
  else
    self.cursor = 0
  end
  display.update()
end

function AlarmSet:set()
  if self.modified == true then
    clock.alarms[self.num] = self.alarm
    clock.saveAlarms()
    thread.sleepms(100)
    clock.getNextAlarm()
  end
  changeMode("AlarmSelect", self.num)
end

function AlarmSet:up()
  nixDoTimer = 20
  self.modified = true
  self.cursorBlink = false
  if self.cursor == 0 then
    if self.alarm.wday < 10 then
      self.alarm.wday = self.alarm.wday + 1
    else
      self.alarm.wday = 1
    end
  elseif self.cursor == 1 then
    if self.alarm.hour < 23 then
      self.alarm.hour = self.alarm.hour + 1
    else
      self.alarm.hour = 0
    end
  elseif self.cursor == 2 then
    if self.alarm.min < 59 then
      self.alarm.min = self.alarm.min + 1
    else
      self.alarm.min = 0
    end
  elseif self.cursor == 3 then
    self.alarm.enabled = not self.alarm.enabled
  elseif self.cursor == 4 then
    self.alarm=nil
    self:set()
    return 0
  end
  display.update()
end

function AlarmSet:down()
  nixDoTimer = 20
  self.modified = true
  self.cursorBlink = false
  if self.cursor == 0 then
    if self.alarm.wday > 1 then
      self.alarm.wday = self.alarm.wday - 1
    else
      self.alarm.wday = 10
    end
  elseif self.cursor == 1 then
    if self.alarm.hour > 0 then
      self.alarm.hour = self.alarm.hour - 1
    else
      self.alarm.hour = 23
    end
  elseif self.cursor == 2 then
    if self.alarm.min > 0 then
      self.alarm.min = self.alarm.min - 1
    else
      self.alarm.min = 59
    end
  elseif self.cursor == 3 then
    self.alarm.enabled = not self.alarm.enabled
  elseif self.cursor == 4 then
    self.alarm=nil
    self:set()
    return 0
  end
  display.update()
end

return AlarmSet
