--thread.start(function()
--Das Display iniziieren
--Vor i2c sachen immer mtx:lock() ausführen, wenn beendet mtx:unlock()
--Während desssen werden alle anderen Versuche mit dem mtx etwas zu machen geblockt
mtx = thread.createmutex()
todo = {}
function addTodo(func)
  if #todo < 50 then
    table.insert(todo,func)
  end
  if type(TODOTHREAD) == "number" and thread.status(TODOTHREAD) == "suspended" then
    thread.resume(TODOTHREAD)
  end
end


function copy(orig)
  local cvalue
  if type(orig) == 'table' then
    cvalue = {}
    for orig_key, orig_value in next, orig, nil do
      cvalue[copy(orig_key)] = copy(orig_value)
    end
    setmetatable(cvalue, copy(getmetatable(orig)))
  else -- number, string, boolean, etc
    cvalue = orig
  end
  return cvalue
end

speaker = require "speaker"
speaker.init()
led = require "led"
--Neustarten, wenn hardware nicht bereit

--gdisplay.attach(gdisplay.SSD1306_128_64, gdisplay.LANDSCAPE_FLIP, true)
--
local _, ok = pcall(gdisplay.attach, gdisplay.SSD1306_128_64, gdisplay.LANDSCAPE_FLIP, true)
if ok and ok:find("timeout") then
  print(ok)
  led.start("Fade", {r = 200, g = 1, b = 1})
  thread.sleep(10)
  speaker.send(0x0D)--ALARM
  speaker.send(0x06, 15)--Lautstärke 15/30
end
--]]
port1, ok = i2c.attach(i2c.I2C1, i2c.MASTER)
if ok and ok:find("timeout") then
  thread.sleep(2)
  os.exit()
end
gdisplay.clear()
gdisplay.setfont(gdisplay.FONT_DEJAVU24)
gdisplay.write({gdisplay.CENTER, 18}, "Starten")
gdisplay.settransp(false)
--AB jetzt kann alles Weitere starten

--cjoson iniziieren
cjson = require "cjson"

local boot = 1


mtx:lock()
gdisplay.setfont(gdisplay.FONT_UBUNTU16)
gdisplay.write({0, 0}, "NEXT")
gdisplay.write({0, gdisplay.BOTTOM}, "SET")
gdisplay.write({gdisplay.RIGHT, 0}, "UP")
gdisplay.write({gdisplay.RIGHT, gdisplay.BOTTOM}, "DOWN")
mtx:unlock()
pio.pin.setdir(pio.INPUT, pio.GPIO22) --beseitige laestiges Blinken
nixDoTimer = 0
Modus = {}

--Einbinden von Perepherie
clock = require "clock"
display = require "display"
math.randomseed(os.time(clock.osTime))
math.random(10); math.random(10); math.random(10)

local function bootStat()
  nvs.write("stat", "lastBoot", os.time(clock.osTime))

  local ok, val = pcall(nvs.read, "stat", "BootCtr")
  if not ok then val = 0 end
  nvs.write("stat", "BootCtr", val+1)
end
bootStat()


--Error
function lerror(mess)
  local file = io.open("error", "w")
  file:write(mess.."\n"..debug.traceback())
  file:close()
  print("--------------------------")
  print(mess)
  print(debug.traceback())
  print("--------------------------")
  changeMode("Error", mess)
  --thread.sleep(25)
  --os.exit(-1)
end

--Fortschrittsbalken
local progressbar = {}
function startBar(steps, y)
  if steps == nil then progressbar.steps = 5 else progressbar.steps = steps end
  if y == nil then progressbar.y = 47 else progressbar.y = y end
  progressbar.progress = 0
  display.rect({1, progressbar.y}, 128, 5, gdisplay.BLACK, gdisplay.BLACK)
end

function showBar(inc)
  if type(inc) ~= "number" then inc = 0 end
  progressbar.progress = progressbar.progress + inc
  local w=math.floor((128 / progressbar.steps) * progressbar.progress)
  display.rect({1, progressbar.y}, w, 5, gdisplay.WHITE, gdisplay.WHITE)
  if w<128 then
    display.rect({w+1, progressbar.y}, 128-w, 5, gdisplay.BLACK, gdisplay.BLACK)
  end
end

function changeMode(newMode, arg)
  print("ModusWechsel nach: "..newMode)
  collectgarbage()
  if not type(newMode) == "string" then lerror("string required") return nil end
  nixDoTimer = 0
  --if not modes[newMode] then lerror(newMode)end
  --Modus = modes[newMode]:create(arg)

  addTodo(function()
    for k in pairs(package.loaded) do
      if k:find("D_") then
        package.loaded[k] = nil
        print(k .. " aus Speicher entfernt")
      end
    end
    local tmp, ok = require("D_"..newMode)
    print("geladen")
    if not ok then
      Modus = tmp:create(arg)
    else
      Modus = require("D_Error"):create("Laden fehlgeschlagen")
    end
    --display.wait()
    display.clear()
    display.update()
    display.showMenue(Modus.name)
  end)
end
--Festlegen des Modi
changeMode("TimeDisplay")



--Definiere die Buttons
pio.pin.setpull(pio.PULLUP, pio.GPIO2, pio.GPIO0, pio.GPIO13, pio.GPIO15)
button = {counter = {}, mode = {}, active = false}
for a = 1, 4 do
  button.counter[a] = 0
end
button.mode[1] = "set"
button.mode[2] = "up"
button.mode[3] = "down"
button.mode[4] = "next"
function button.unlock()
  addTodo(function() button.active=false end)
end
function button.lock()
  button.active=true
end

--[[AusgabenThread
--Macht das ganze etw. ungenau, spart aber Threads
TODO_Liste
--]]
TODOTHREAD=thread.start(function()
  while true do
    while #todo > 0 do
      local task = table.remove(todo, 1)
      if type(task) == "function" then
        mtx:lock()
        local ok,err = pcall(function() task() end)
        mtx:unlock()
        if not ok then print(err.."\n"..debug.traceback()) end
      end
    end
    --Ausgabe ans Display
    collectgarbage()
    thread.suspend(TODOTHREAD)--Warten auf Aufwecken->addTodo()
  end
end,20480,nil,0,"TODO")

--Clock Interrupt
--pio.pin.interrupt(pio.GPIO5, function()
--displayTimer = tmr.attach(tmr.TMR2, 1000000, function()--jede 1 sek
--buttons.display = true
function updateDisplay1s()
  --if not (Modus and Modus.show) then changeMode("TimeDisplay") return end
  --Boot screen entfernen
  if boot then
    boot = false
    display.clear()
  end
  --Zeit aktualisieren
  clock.getTime()
  --zurückwechseln zur Uhr, wenn lange nichts passiert
  if(nixDoTimer == 1)then
    nixDoTimer = 0
    display.clear()
    changeMode("TimeDisplay")
  end
  if nixDoTimer > 1 then nixDoTimer = nixDoTimer - 1 end

  --Display automatisch aktualisieren
  local function x()
    display.updateBrightness(clock.osTime.hour, 10)
    Modus:show()
  end
  xpcall(x, lerror)

  --Auf Wecker pruefen --Volle Minute//Alarm vorhanden
  if clock.osTime.sec == 0 and clock.nextAlarm then
    if clock.compAlarm(clock.nextAlarm, clock.osTime) or clock.alarmOverride_D then
      --ALARM
      changeMode("AlarmDisplay")
      clock.getNextAlarm()
    end
    if clock.compAlarm(clock.preAlarm, clock.osTime) or clock.alarmOverride_L then
      --LED Alarm
      --20
      local ok, s = pcall(nvs.read, "settings", "AlrMin")
      if not ok then s = 20 end
      led.start("Sunrise", {seconds = 60 * (s + 1), offset = 0.5})
    end
  end
  collectgarbage()
end

updaterCTR=0
updater=tmr.attach(tmr.TMR2, 40000, function()--komischer Wert..., sollte eig. 40000 sein. liegt vermutlich an einer falschen software
  thread.start(function ()
    local pin = {}
    pin[1], pin[2], pin[3], pin[4] = pio.pin.getval(pio.GPIO2, pio.GPIO0, pio.GPIO13, pio.GPIO15)

    for a in pairs(pin) do
      if pin[a] == 1 then
        button.counter[a] = 0
      else
        button.counter[a] = button.counter[a] + 1
        local function x()
          Modus[button.mode[a]](Modus)
        end
        --Single Press
        if button.counter[a] == 1 and button.active == false then
          --print("Button: "..button.mode[a])
          button.lock()
          xpcall(x, print)
          button.unlock()
        end
        --Long Press
        if button.counter[a] > 20 and button.counter[a]%3==0 and button.active == false then
          button.lock()
          if type(Modus[button.mode[a].."_long"]) == "function" then
            xpcall(function() Modus[button.mode[a].."_long"](Modus) end, lerror)
          else
            xpcall(x, lerror)
          end
          button.unlock()
        end
      end
    end
    if led.tmr == true and led.mode.name then addTodo(led.update) end
    if updaterCTR%25 == 0 then addTodo(updateDisplay1s) end
    updaterCTR = updaterCTR + 1
    collectgarbage()
  end,nil,nil,1,"Updater")
end)
updater:start()
function u() Modus:up() end
function d() Modus:down() end
function s() Modus:set() end
function n() Modus:next() end
--end)
