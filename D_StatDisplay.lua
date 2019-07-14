local MODE = {}
MODE.__index = MODE

function MODE:create()
  nixDoTimer = 20
  --print("Erstelle MODE")
  local this = {}
  this.first = true
  this.cursor = 1
  this.modified = false
  this.select = false
  this.name = "StatDisplay"
  this.selected = ""
  --Settings Einträge
  this.settings = {}
  table.insert(this.settings, {type="nvs", storage="stat", key="lastBoot", outtype="date"})
  table.insert(this.settings, {type="nvs", storage="stat", key="BootCtr", outtype="number"})
  table.insert(this.settings, {type="function", fun=function() display.setfont(gdisplay.FONT_LCD) local ret="" local file=io.open("error","r") for line in file:lines() do ret=ret..line.."\n" end file:close() return ret end, key="Error", outtype="text"})
  table.insert(this.settings, {type="function", fun=function() return cpu.temperature().."°C" end, key="Temperature", outtype="text"})
  table.insert(this.settings, {type="function", fun=function() return display.brightness.."/255" end, key="DisplayBright", outtype="text"})
  setmetatable(this, MODE)
  return this
end

function MODE:show()
  if self.first then
    self.first = false
    gdisplay.setfont(gdisplay.FONT_DEFAULT)
    self:update()
  end
end

function MODE:update()
  display.setfont(gdisplay.FONT_DEFAULT)
  local function getValue(rpos, y)
    rpos = rpos + self.cursor
    if rpos > #self.settings then
      rpos = rpos - #self.settings
    end
    if rpos == 0 then
      rpos = #self.settings
    end
    local leer = ""
    for i = 1, 10 - #self.settings[rpos].key do
      leer = leer .. " "
    end
    display.rect({27, y}, 100, 12, gdisplay.BLACK, gdisplay.BLACK)
    display.write({27, y}, self.settings[rpos].key)
  end

  display.write({0, 30}, "->  ")


  display.rect({27, 28}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)
  display.rect({27, 43}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)
  display.rect({27, 58}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)

  display.rect({27, 26}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(-1, 15)
  display.rect({27, 41}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(0, 30)
  display.rect({27, 56}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(1, 45)
end

function MODE:next()
  changeMode("Settings")
end

function MODE:set()
  changeMode("StatShow",self.settings[self.cursor])
end

function MODE:up()
  nixDoTimer = 20
  if self.cursor > 1 then
    self.cursor = self.cursor - 1
  else
    self.cursor = #self.settings
  end
  self:update()
end

function MODE:down()
  nixDoTimer = 20
  if self.cursor < #self.settings then
    self.cursor = self.cursor + 1
  else
    self.cursor = 1
  end
  self:update()
end

return MODE
