local MODE = {}
MODE.__index = MODE

function MODE:create(dings)
  --print("Erstelle MODE")
  nixDoTimer=30
  local this = {}
  this.name=""
  this.text="SD_REMOVED"
  for k, v in pairs(dings) do
    this[k] = v
  end
  this.text=this.text:gsub("_","\n")
  setmetatable(this, MODE)
  return this
end

function MODE:show()
  display.setfont(gdisplay.FONT_DEJAVU18)
  display.write({1, 1}, self.text)
end

function MODE:next()
  changeMode("TimeDisplay")
end

function MODE:set()
  changeMode("TimeDisplay")
end

function MODE:up()
  changeMode("TimeDisplay")
end

function MODE:down()
  changeMode("TimeDisplay")
end

return MODE
