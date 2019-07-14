local DateDisplay={}
DateDisplay.__index = DateDisplay

function DateDisplay:create()
  local this = {}
  nixDoTimer=10
  this.name="Datum"
  setmetatable(this, DateDisplay)
  return this
end

function DateDisplay:show()
  display.updateBrightness(clock.osTime.hour,10)
  local dom=copy(clock.osTime.day)
  local moy=copy(clock.osTime.month)
  local yea=tostring(clock.osTime.year)

  if dom<10 then dom="0"..tostring(dom) end
  if moy<10 then moy="0"..tostring(moy) end

  display.setfont(gdisplay.FONT_DEJAVU18)
  display.write({8,15},clock.getDayName())
  display.write({8,35},dom.."."..moy.."."..yea)
end

function DateDisplay:set()
  --changeMode("DateSet")
end

function DateDisplay:next()
  changeMode("Settings")
end

function DateDisplay:up()
  --display.dimm(255)
end

function DateDisplay:down()
  --display.dimm(0)
end

return DateDisplay
