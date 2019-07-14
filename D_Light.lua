local Light = {}
Light.__index = Light

function Light:create()
  nixDoTimer = 30
  --print("Erstelle Light")
  local this = {}
  this.first = true
  this.cursor = 1
  this.modified = false
  this.select = false
  this.name = "Light"
  this.selected = ""
  --settings Einträge
  local function c(val)
    return {val, 0}
  end
  this.settings = {}
  table.insert(this.settings, c("Sunrise"))
  table.insert(this.settings, c("Fade"))
  table.insert(this.settings, c("Rainbow"))
  table.insert(this.settings, c("BinaryClock"))

  for k, v in pairs(this.settings) do
    if v[1] == led.mode.name then
      this.cursor = k
      this.select = true
    end
  end

  setmetatable(this, Light)
  return this
end

function Light:show()
  if self.first then
    self.first = false
    display.rect({27, 28}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)
    display.rect({27, 43}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)
    display.rect({27, 58}, 100, 1, gdisplay.WHITE, gdisplay.WHITE)
    self:update()
  end
end

function Light:update()
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
    display.write({27, y}, self.settings[rpos][1]..":"..leer)
    display.write({gdisplay.RIGHT, y}, self.settings[rpos][2].."   ")
  end

  if self.select then
    display.write({0, 30}, "->>")
  else
    display.write({0, 30}, "->  ")
  end

  display.rect({27, 26}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(-1, 15)
  display.rect({27, 41}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(0, 30)
  display.rect({27, 56}, 100, 2, gdisplay.BLACK, gdisplay.BLACK)
  getValue(1, 45)
end

function Light:next()
  --led.start("Fade", {r=0, b=0, g=0})
  changeMode("TimeDisplay")
end

function Light:set()
  nixDoTimer = 30
  self.select = not self.select
  if self.select then
    led.start(self.settings[self.cursor][1], self:set_color(self.settings[self.cursor][2]))
  else
    led.start("Fade", {r = 0, b = 0, g = 0})
  end
  self:update()
end

function Light:set_long()
  changeMode("SleepTmr")
end

function Light:up()
  nixDoTimer = 30
  local function testName(inp)
    return inp == self.settings[self.cursor][1]
  end

  if not self.select then
    if self.cursor > 1 then
      self.cursor = self.cursor - 1
    else
      self.cursor = #self.settings
    end
  else
    if testName("Sunrise") or testName("Fade") then
      if self.settings[self.cursor][2] < 6 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] + 1
      end
      led.start(self.settings[self.cursor][1], self:set_color(self.settings[self.cursor][2]))
    end
  end

  self:update()
end

function Light:set_color(int)
  if int == 1 then
    return {r = 200, g = 10, b = 10}
  elseif int == 2 then
    return {r = 20, g = 200, b = 20}
  elseif int == 3 then
    return {r = 20, g = 20, b = 200}
  elseif int == 4 then
    return {r = 20, g = 100, b = 100}
  elseif int == 5 then
    return {r = 150, g = 70, b = 20}
  end
  return {}
end

function Light:down()
  nixDoTimer = 30

  local function testName(inp)
    return inp == self.settings[self.cursor][1]
  end

  if not self.select then
    if self.cursor < #self.settings then
      self.cursor = self.cursor + 1
    else
      self.cursor = 1
    end
  else
    if testName("Sunrise") or testName("Fade") then
      if self.settings[self.cursor][2] > 0 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] - 1
      end
      led.start(self.settings[self.cursor][1], self:set_color(self.settings[self.cursor][2]))
    end
  end
  self:update()
end

return Light
