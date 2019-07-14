local AlarmSelect = {}
AlarmSelect.__index = AlarmSelect
function AlarmSelect:create(pos)
  nixDoTimer = 20
  --print("Erstelle Settings")
  local this = {}
  this.corsorBlink = true
  if pos then
    this.cursor = pos
  else
    this.cursor = 1
  end
  this.modified = false
  this.name = "Weckerauswahl"

  local function fd(i)
    if i < 10 then return "0"..i end
    return i
  end

  if clock.nextAlarm then
    this.nextText = "next: "..clock.getShortDay(2, clock.nextAlarm.wday).." "..fd(clock.nextAlarm.hour)..":"..fd(clock.nextAlarm.min)
  else
    this.nextText = "next: ---"
  end
  this.first=true
  setmetatable(this, AlarmSelect)
  return this
end

function AlarmSelect:show()
  if self.first then
    self.first=false
    self:update()
  end
end

function AlarmSelect:update()
  local function fd(i)
    if i < 10 then return "0"..i end
    return i
  end

  local function getAlarm(rpos)
    if(type(clock.alarms[self.cursor + rpos]) == "table") then
      local r=clock.getShortDay(2, clock.alarms[self.cursor + rpos].wday).." "..fd(clock.alarms[self.cursor + rpos].hour)..":"..fd(clock.alarms[self.cursor + rpos].min)
      if clock.alarms[self.cursor + rpos].enabled then
        r=(self.cursor +rpos)..": "..r
      else
        r="X: "..r
      end
      return r
    else
      return (self.cursor +rpos)..": ---"
    end
  end
  display.setfont(gdisplay.FONT_DEFAULT)
  display.write({0, 15}, self.nextText)
  display.rect({20, 30}, 100, 30, gdisplay.BLACK, gdisplay.BLACK)
  display.write({0, 30}, "-> "..getAlarm(0))
  display.write({20, 45}, getAlarm(1))
end

function AlarmSelect:next()
  changeMode("Settings")
end

function AlarmSelect:set()
  changeMode("AlarmSet", self.cursor)
end

function AlarmSelect:up()
  nixDoTimer = 20
  if self.cursor > 1 then
    self.cursor = self.cursor - 1
  end
  self:update()
end

function AlarmSelect:down()
  nixDoTimer = 20
  self.cursor = self.cursor + 1
  self:update()
end

return AlarmSelect
