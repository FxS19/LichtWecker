local DateSet={}
DateSet.__index = DateSet

function DateSet:create()
  nixDoTimer=20
  --print("Erstelle Settings")
  local this={}
  this.corsorBlink=true
  this.cursor=0
  this.osTime=clock.getOsTime()
  this.modified=false
  this.name="Datum stellen"
  setmetatable(this, DateSet)
  return this
end

function DateSet:show()
  self.cursorBlink= not self.cursorBlink

  display.setfont(gdisplay.FONT_DEJAVU18)

  display.write({44,15},clock.getShortDay(2,self.osTime.wday).."  ")

  if(self.cursorBlink or not (self.cursor==0))then
    local a=copy(self.osTime.day)
    if a<10 then a="0"..tostring(a) end
    display.write({6,35},a)
  else
    display.rect({6, 35}, 25, 18, gdisplay.BLACK, gdisplay.BLACK)
  end

  display.write({32,35},".")

  if(self.cursorBlink or not (self.cursor==1))then
    local a = copy(self.osTime.month)
    if a<10 then a="0"..tostring(a) end
    display.write({39,35},a)
  else
    display.rect({39, 35}, 25, 18, gdisplay.BLACK, gdisplay.BLACK)
  end

  display.write({65,35},".")

  if(self.cursorBlink or not (self.cursor==2))then
    display.write({73,35},self.osTime.year)
  else
    display.write({73,35},"        ")
    display.rect({73, 35}, 55, 18, gdisplay.BLACK, gdisplay.BLACK)
  end
end

function DateSet:set()
  nixDoTimer=0
  if self.modified then
    local x= os.date("*t",os.time({day=self.osTime.day,month=self.osTime.month,year=self.osTime.year,hour=self.osTime.hour,min=self.osTime.min,sec=self.osTime.sec}))

    clock.setDate(x)
  end
  changeMode("Settings")
end

function DateSet:next()
  nixDoTimer=20
  self.corsorBlink=false
  if self.cursor<2 then
    self.cursor=self.cursor+1
  else
    self.cursor=0
  end
  display.update()
end

function DateSet:up()
  nixDoTimer=20
  if self.cursor==0 then
    if self.osTime.day<31 then
      self.osTime.day=self.osTime.day+1
    else
      self.osTime.day=1
    end
  elseif self.cursor==1 then
    if self.osTime.month<12 then
      self.osTime.month=self.osTime.month+1
    else
      self.osTime.month=1
    end
  else
    self.osTime.year=self.osTime.year+1
  end
  self.modified=true
  self.cursorBlink=false
  self.osTime=os.date("*t",os.time({day=self.osTime.day,month=self.osTime.month,year=self.osTime.year,hour=self.osTime.hour,min=self.osTime.min,sec=self.osTime.sec}))
  display.update()
  -- body...
end

function DateSet:down()
  nixDoTimer=20
  if self.cursor==0 then
    if self.osTime.day>1 then
      self.osTime.day=self.osTime.day-1
    else
      self.osTime.day=31
    end
  elseif self.cursor==1 then
    if self.osTime.month>1 then
      self.osTime.month=self.osTime.month-1
    else
      self.osTime.month=12
    end
  else
    self.osTime.year=self.osTime.year-1
  end
  self.modified=true
  self.cursorBlink=false
  self.osTime=os.date("*t",os.time({day=self.osTime.day,month=self.osTime.month,year=self.osTime.year,hour=self.osTime.hour,min=self.osTime.min,sec=self.osTime.sec}))
  display.update()
  -- body...
end

return DateSet
