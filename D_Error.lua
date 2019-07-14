local Error={}
Error.__index = Error

function Error:create(mess)
  --nixDoTimer=26
  print("Erstelle Settings")
  local this={}
  --Neustarten nach 25 sek
  this.thread=thread.start(function()
    thread.sleep(25)
    os.exit()
  end)
  this.blink=true
  this.name=""
  this.message="ERROR"
  this.err=mess
  setmetatable(this, Error)
  return this
end

function Error:show()
  self.blink=not self.blink
  if self.blink then
    display.dimm(0)
  else
    display.dimm(255)
  end
  display.setfont(gdisplay.FONT_LCD)
  display.write({1, 1}, self.message)
  display.setwrap(true)
  display.setfont(gdisplay.FONT_LCD)
  display.write({1, 10}, self.err.." ("..(nixDoTimer-1).." sek)")
  display.setwrap(false)
  if nixDoTimer==1 then os.exit(-1) end
end

function Error:exit()
  thread.stop(self.thread)
  changeMode("TimeDisplay")
end

function Error:next()
  self:exit()
end

function Error:set()
  self:exit()
end

function Error:up()
  self:exit()
end

function Error:down()
  self:exit()
end
return Error
