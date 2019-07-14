local Settings = {}
Settings.__index = Settings

function Settings:create()
  nixDoTimer = 20
  --print("Erstelle Settings")
  local this = {}
  this.first = true
  this.cursor = 1
  this.modified = false
  this.select = false
  this.name = "Settings"
  this.selected = ""
  --Settings Einträge
  this.settings = {}
  table.insert(this.settings, {"Uhrzeit", "TimeSet"})
  table.insert(this.settings, {"Datum", "DateSet"})
  table.insert(this.settings, {"Variablen", "ValSettings"})
  table.insert(this.settings, {"Stats", "StatDisplay"})
  table.insert(this.settings, {"Wecker", "AlarmSelect"})

  setmetatable(this, Settings)
  return this
end

function Settings:show()
  if self.first then
    self.first = false
    display.setfont(gdisplay.FONT_DEFAULT)
    self:update()
  end
end

function Settings:update()
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
    for i = 1, 10 - #self.settings[rpos][1] do
      leer = leer .. " "
    end
    display.rect({27, y}, 100, 12, gdisplay.BLACK, gdisplay.BLACK)
    display.write({27, y}, self.settings[rpos][1])
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

function Settings:next()
  changeMode("TimeDisplay")
end

function Settings:set()
  changeMode(self.settings[self.cursor][2])
end

function Settings:up()
  nixDoTimer = 20
  if self.cursor > 1 then
    self.cursor = self.cursor - 1
  else
    self.cursor = #self.settings
  end
  self:update()
end

function Settings:down()
  nixDoTimer = 20
  if self.cursor < #self.settings then
    self.cursor = self.cursor + 1
  else
    self.cursor = 1
  end
  self:update()
end

return Settings
