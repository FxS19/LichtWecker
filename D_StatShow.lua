local MODE = {}
MODE.__index = MODE

function MODE:create(dings)
  nixDoTimer = 20
  --print("Erstelle MODE")
  local this = {}
  this.type = "standart"
  --Umspeichern
  for k, v in pairs(dings) do
    this[k] = v
  end
  this.name=this.key
  setmetatable(this, MODE)
  return this
end

function MODE:show()
  local val, ok
  display.setfont(gdisplay.FONT_DEFAULT)
  display.write({gdisplay.RIGHT, 1}, "CLEAR")
  --Werte auslesen
  if self.type == "nvs" then
    ok, val = pcall(nvs.read, self.storage, self.key)
    if not ok then val = 0 end
  elseif self.type == "function" then
    ok, val = pcall(function() return self.fun() end)
  end


  --Werte anzeigen
  if self.outtype == "date" then
    val = os.date("%H:%M:%S\n%a\n%d/%m/%Y", val)
    display.write({1, gdisplay.CENTER}, val)
  else
    display.setwrap(true)
    display.write({0, 14}, val)
    display.setwrap(false)
  end
end

function MODE:next()
  changeMode("StatDisplay")
end

function MODE:set()
  changeMode("StatDisplay")
end

function MODE:up()
  if self.type == "nvs" then
    nvs.write(self.storage, self.key, 0)
  end
  self:show()
end

function MODE:down()
  --nvs.write(self.storage, self.key, 0)
  self:show()
end

return MODE
