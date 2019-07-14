local TimeSet={}
TimeSet.__index = TimeSet

function TimeSet:create()
  nixDoTimer=20
  --print("Erstelle Settings")
  local this={}
  this.corsorBlink=true
  this.cursor=0
  this.osTime=clock.getOsTime()
  this.modified=false
  this.name="Uhr stellen"
  setmetatable(this, TimeSet)
  return this
end

--Zeige das Uhr-Stellen an
function TimeSet:show()
  self.cursorBlink= not self.cursorBlink

  local minute=copy(self.osTime.min)
  local hour=copy(self.osTime.hour)
  local second=copy(self.osTime.sec)

  if(self.osTime.sec<10)then
    second="0"..tostring(second)
  end
  if(self.osTime.min<10)then
    minute="0"..tostring(minute)
  end
  if(self.osTime.hour<10)then
    hour="0"..tostring(hour)
  end

  display.setfont(gdisplay.FONT_DEJAVU24)
  if(self.cursorBlink or not (self.cursor==0))then
    display.write({0,20},hour)
  else
    display.write({0,20},"    ")
  end
  display.write({35,20},":")
  if(self.cursorBlink or not (self.cursor==1))then
    display.write({45,20},minute)
  else
    display.write({45,20},"    ")
  end
  display.write({80,20},":")
  if(self.cursorBlink or not (self.cursor==2))then
    display.write({90,20},second)
  else
    display.write({90,20},"    ")
  end
end

--Button set
function TimeSet:next()
  if self.cursor<2 then
    self.cursor=self.cursor+1
  else
    self.cursor=0
  end
  nixDoTimer=20
  display.update()
end

--Button set
--Wenn Zeit Verändert, Zeit speichern
function TimeSet:set()
  nixDoTimer=0
  if self.modified==true then
    clock.setTime(os.date("*t",os.time({day=self.osTime.day,month=self.osTime.month,year=self.osTime.year,hour=self.osTime.hour,min=self.osTime.min,sec=self.osTime.sec})))
  end
  changeMode("Settings")
end

--Button
function TimeSet:up()
  nixDoTimer=20
  self.modified=true
  self.cursorBlink=false
  if self.cursor==0 then
    if self.osTime.hour<23 then
      self.osTime.hour=self.osTime.hour+1
    else
      self.osTime.hour=0
    end
  elseif self.cursor==1 then
    if self.osTime.min<59 then
      self.osTime.min=self.osTime.min+1
    else
      self.osTime.min=0
    end
  elseif self.cursor==2 then
    if self.osTime.sec<59 then
      self.osTime.sec=self.osTime.sec+1
    else
      self.osTime.sec=0
    end
  end
  display.update()
end

--Button
function TimeSet:down()
  self.cursorBlink=false
  self.modified=true
  if self.cursor==0 then
    if self.osTime.hour>0 then
      self.osTime.hour=self.osTime.hour-1
    else
      self.osTime.hour=23
    end
  elseif self.cursor==1 then
    if self.osTime.min>0 then
      self.osTime.min=self.osTime.min-1
    else
      self.osTime.min=59
    end
  elseif self.cursor==2 then
    if self.osTime.sec>0 then
      self.osTime.sec=self.osTime.sec-1
    else
      self.osTime.sec=59
    end
  end
  nixDoTimer=20
  display.update()
end

return TimeSet
