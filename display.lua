local display={}

--Variablen
display.brightness=255

function display.update(mode,param)
  if not mode then mode="show" end
  Modus[mode](Modus,param)
end

--setze Helligkeit
function display.dimm(val)
  if(display.brightness ~= val)then
    mtx:lock()
    port1:start()
    port1:address(0x3C,false)
    port1:write(0,0x81)
    port1:stop()
    port1:start()
    port1:address(0x3C,false)
    port1:write(0,val)
    port1:stop()
    mtx:unlock()
    display.brightness=val
  end
end

--Die Displayhelligkeit anpassen
function display.updateBrightness(hour, val)
  if not val then val=1 end
  --if not type(hour)=="number" then print("updateBrightnessErr") error("Zahl als hour verwenden") end
  --hour=tonumber(hour)
  val=math.floor(tonumber(val))
  if hour>=18 or hour<8 then
    if display.brightness-val>=0 then
      display.dimm(display.brightness-val)
    else
      display.dimm(0)
    end
  end
  if(hour>7 and hour<20)then
    if display.brightness+val<255 then
      display.dimm(display.brightness+val)
    else
      display.dimm(255)
    end
  end
end

--Menütext anzeigen
function display.showMenue(s)
  print("Modus: "..s)
  display.setfont(gdisplay.FONT_DEFAULT)
  display.write({1,1},s)
end


--HilfsFunktionen für todo
function display.write(pos,value)
  addTodo(function() gdisplay.write(pos,value) end)
end
function display.clear()
  addTodo(function() gdisplay.clear() end)
end
function display.setfont(name)
  addTodo(function() gdisplay.setfont(name) end)
end
function display.rect(point, width, height, color, fillcolor)
  addTodo(function() gdisplay.rect(point, width, height, color, fillcolor) end)
end
function display.setwrap(bool)
  addTodo(function() gdisplay.setwrap(bool) end)
end

return display
