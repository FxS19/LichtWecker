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
  this.name = "Variablen"
  this.selected = ""
  this.ready = false
  --Settings Einträge

  this.settings = {}

  setmetatable(this, Settings)
  return this
end

function Settings:show()
  if self.first then
    self.first = false
    display.setfont(gdisplay.FONT_DEFAULT)
    display.write({30, 27}, "Wird geladen...")
    local function x()
      print("Laden...")
      local function read(key)
        local ok, val = pcall(nvs.read, "settings", key)
        if not ok then val = 0 end
        return {key, val}
      end
      table.insert(self.settings, read("Lampe"))
      table.insert(self.settings, read("Volume"))
      table.insert(self.settings, read("AlrMin"))
      for k, v in pairs(self.settings) do print(k, v[1], v[2]) end
      --Nicht toll, aber sollte gehen, da der Modus erst mit ready=true geändert werden kann !Wecker
      --gibt probleme mit self
      Modus.ready = true
      display.clear()
      display.showMenue(Modus.name)
      print("showMenue")
      Modus.update(Modus)
      print("update complete")
      collectgarbage()
    end

    thread.start(x)
    print("Start prozedur eigeleitet")
  end
end

function Settings:update()
  if not self.ready then return 0 end
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

function Settings:set()
  if not self.ready then return 0 end
  --led.start("Fade", {r=0, b=0, g=0})
  changeMode("Settings")
end

function Settings:next()
  nixDoTimer = 20
  if not self.ready then return 0 end
  self.select = not self.select
  led.start("Fade", {r = 0, b = 0, g = 0})
  self:update()
end

function Settings:up()
  nixDoTimer = 20
  if not self.ready then return 0 end
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
    if testName("Lampe") then
      if self.settings[self.cursor][2] < 10 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] + 1
        local l = 11 - self.settings[self.cursor][2]
        led.start("Fade", {r = math.floor(250 / l), b = math.floor(10 / l), g = math.floor(80 / l)})
      end
    end
    if testName("Volume") then
      if self.settings[self.cursor][2] < 30 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] + 1
      end
    end
    if testName("AlrMin") then
      if self.settings[self.cursor][2] < 100 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] + 1
      end
    end

    nvs.write("settings", self.settings[self.cursor][1], self.settings[self.cursor][2])--Speichere den neuen Wert
  end

  self:update()
end

function Settings:down()
  nixDoTimer = 20
  if not self.ready then return 0 end
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
    if testName("Lampe") then
      if self.settings[self.cursor][2] > 1 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] - 1
        local l = 11 - self.settings[self.cursor][2]
        led.start("Fade", {r = math.floor(250 / l), b = math.floor(10 / l), g = math.floor(80 / l)})
      end
    end
    if testName("Volume") then
      if self.settings[self.cursor][2] > 1 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] - 1
      end
    end
    if testName("AlrMin") then
      if self.settings[self.cursor][2] > 1 then
        self.settings[self.cursor][2] = self.settings[self.cursor][2] - 1
      end
    end
    nvs.write("settings", self.settings[self.cursor][1], self.settings[self.cursor][2])--Speichere den neuen Wert
  end

  self:update()
end

return Settings
