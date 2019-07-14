local clock = {}
clock.day = {
  "Sonntag",
  "Montag",
  "Dienstag",
  "Mittwoch",
  "Donnerstag",
  "Freitag",
  "Samstag",
  "WTag",
  "WEnde",
  "WOche"
}

--ALARM
clock.alarms = {}
clock.nextAlarm = false

function clock.compAlarm(a, b)
  local override = false
  if a.wday==8 and (b.wday-1)<6 or b.wday==8 and (a.wday-1)<6 then override=true end
  if a.wday==9 and (b.wday==1 or b.wday==7) or b.wday==9 and (a.wday==1 or a.wday==7) then override=true end
  if a.wday==10 or b.wday==10 then override=true end

  if((b.wday == a.wday or override) and (b.hour == a.hour) and (b.min == a.min)) then
    return true
  else
    return false
  end
end

--Werte in clock.alarms in Datei speichern
function clock.saveAlarms()
  print("Speichern-Der AlarmDatei")
  --os.remove("alarms")
  local file = io.open("alarms", "w")
  for k in pairs(clock.alarms) do
    file:write(cjson.encode(clock.alarms[k]).."\n")
  end
  file:close()
end

--Werte aus Gespeicherter Datei in clock.alarms laden
function clock.readAlarmFile()
  local ret = {}
  print("LESEN-Der Alarme")
  local file = io.open("alarms", "r")
  for line in file:lines() do
    table.insert(ret, line)
  end
  file:close()

  for k in pairs(ret) do
    ret[k] = cjson.decode(ret[k])
  end
  clock.alarms = ret
end

function clock.getNextAlarm()
  local wday = copy(clock.osTime.wday)

  --Szund und Minute zusammen fassen
  local function getTimeInt(h, m)
    h = copy(h)
    m = copy(m)
    if m < 10 then
      m = "0"..m
    end
    return tonumber(h..m)
  end

  --Rückgabe der Alarme des Tages
  local function testdow(x)
    --print("------------"..x)
    local ret = {}
    for a, b in ipairs(clock.alarms) do

      if type(b) == "table" then
        -- 1-7=Tage
        -- 8=Unter der Woche
        -- 9=Wochenende
        -- 10=Jeden Tag
        if b.wday == x or (b.wday ==8 and (x-1)<6) or (b.wday==9 and (x==1 or x==7)) or b.wday==10 then
          ret[#ret + 1] = copy(b)
        end
      end
    end
    --print("----------------"..#ret.." Treffer")
    return ret
  end

  local now = getTimeInt(clock.osTime.hour, clock.osTime.min)

  --Gehe alle Tage nacheinander durch von dem Jetzigen
  for a = 1, 8 do
    local tmpalm = testdow(wday)
    local tmpres = {
      hour = 99,
      min = 99
    }
    --Gehe die Testresultate durch
    for b, c in pairs(tmpalm) do
      local cInt = getTimeInt(c.hour, c.min)
      --Wenn es heute ist
      if c.enabled then
        if a == 1 then
          --print("Heute")
          print(now, "<", cInt, "and", getTimeInt(tmpres.hour, tmpres.min), ">", cInt)
          --Wenn später als jetzt und früher als letzter Treffer
          if now < cInt and getTimeInt(tmpres.hour, tmpres.min) > cInt then
            print("GEFUNDEN--HEUTE")
            tmpres = c
          end
        else
          --wenn früher als letzter Treffer
          print(getTimeInt(tmpres.hour, tmpres.min), ">", cInt)
          if getTimeInt(tmpres.hour, tmpres.min) > cInt then
            print("GEFUNDEN")
            tmpres = c
          end
        end
      end
    end

    if tmpres.wday then
      --print("Alarm",clock.getDayName(tmpres.wday),tmpres.hour,tmpres.min)
      --pcall(nvs.write, "alarm", "next", cjson.encode(tmpres))
      clock.nextAlarm = tmpres
      clock.getPreAlarm()
      return tmpres
    end

    if wday == 7 then
      wday = 1
    else
      wday = wday + 1
    end
  end
  clock.getPreAlarm()
  clock.nextAlarm = false
  return false
end

function clock.getPreAlarm()
  if not clock.nextAlarm then return false end
  local alm = copy(clock.nextAlarm)
  local ok, s = pcall(nvs.read, "settings", "AlrMin")
  if not ok then s=20 end
  --20
  for a = 1, s do
    if alm.min > 0 then
      alm.min = alm.min - 1
    elseif alm.hour > 0 then
      alm.hour = alm.hour - 1
      alm.min = 59
    else
      if alm.wday > 1 then
        alm.wday = alm.wday - 1
      else
        alm.wday = 7
      end
      alm.hour = 23
      alm.min = 59
    end
  end
  clock.preAlarm = alm
  return alm
end
--ALARM


function clock.getDayName(d)
  if not d then d = clock.osTime.wday end
  return clock.day[d]
end

function clock.getShortDay(l, d)
  if not d then d = clock.osTime.wday end
  if not l then l = 2 end
  local ret = {}
  for i = 1, l, 1 do
    ret[i] = string.sub(clock.day[d], i, i)
  end
  return table.concat(ret, "")
end

function clock.setTime(time)
  if not(time.hour and time.min and time.sec) then error("keine Werte") end
  local h = math.floor(tonumber(time.hour))
  local m = math.floor(tonumber(time.min))
  local s = math.floor(tonumber(time.sec))
  h = (math.floor(h / 10) << 4) + (h%10)
  m = (math.floor(m / 10) << 4) + (m%10)
  s = (math.floor(s / 10) << 4) + (s%10)
  --[[
  print((math.floor(x/10)<<4)+(x%10))
  ]]
  clock.write(0x0, s)
  clock.write(0x1, m)
  clock.write(0x2, h)

  clock.osTime = clock.getOsTime()
end

--------------------------------------------------------------------------------
--Ermittle Zeit, rueckgabe --muss durch interrupt alle 1s aufgreufen werden
function clock.getTime()
  if(clock.osTime.sec == 30)then
    clock.osTime = clock.getOsTime()
    return clock.osTime
  else
    clock.osTime = os.date("*t", os.time(clock.osTime) + 1)
    return clock.osTime
  end
end

function clock.write(addr, val)
  --clock.wait()
  mtx:lock()
  port1:start()
  port1:address(0x68, false)
  port1:write(addr)
  port1:write(val)
  port1:stop()
  mtx:unlock()
end

function clock.setDate(time)
  local ndow = time.wday&0x7
  local ndom = ((math.floor(time.day / 10)&0x3) << 4) + (time.day%10)
  local century = 0
  local nyea = copy(time.year - 2000)
  if(nyea > 99) then
    century = 1
  end
  local nmoy = (century << 7) + (math.floor(time.month / 10) << 4) + time.month%10
  nyea = (math.floor((nyea%100) / 10) << 4) + (nyea%10)
  --[[
  print("DOW",time.wday,"-->",ndow)
  print("DOM",time.day,"-->",ndom)
  print("MOY",time.month,"-->",nmoy)
  print("YEA",time.year,"-->",nyea)
]]
  clock.write(0x3, ndow)
  clock.write(0x4, ndom)
  clock.write(0x5, nmoy)
  clock.write(0x6, nyea)

  clock.osTime = clock.getOsTime()
end

function clock.getOsTime()
  --clock.wait()
  --i2cAvailable = false
  mtx:lock()
  port1:start()
  port1:address(0x68, false)
  port1:write(0x0)--erstes register
  port1:stop()

  port1:start()
  port1:address(0x68, true)
  --Zeit
  local s = port1:read()
  local m = port1:read()
  local h = port1:read()

  --Datum
  local dow = port1:read()--nicht benoetigt, muss aber wegen der Reihenfolge im Speicher abgefragt werden
  local dom = port1:read()
  local moy = port1:read()
  local yea = port1:read()
  port1:stop()
  --i2cAvailable = true
  mtx:unlock()
  --konvertierung
  s = (s&0xf) + ((s >> 4) * 10)
  m = (m&0xf) + ((m >> 4) * 10)
  h = (h&0xf) + ((h >> 4)&3) * 10

  dom = ((dom&0x30) >> 4) * 10 + (dom&0xf)
  moy = ((moy&0x10) >> 4) * 10 + (moy&0xf)
  yea = 2000 + ((moy&0x8) >> 8) * 100 + ((yea&0xf0) >> 4) * 10 + (yea&0xf)
  local date = os.time({day = dom, month = moy, year = yea, hour = h, min = m, sec = s})
  if date ~= 0 then--kp ob das geht
    return os.date("*t", date)
  else
    return os.date("*t",os.time(clock.osTime)+1)
  end
  --[[
  for k,v in pairs(clock.getOsTime()) do print(k,v) end

isdst   false
hour    13
day     23
wday    6
yday    327
min     44
sec     33
year    2018
month   11

  ]]
end


--Variablen
clock.osTime = clock.getOsTime()

--clock.time=clock.getRealTime()
--clock.date=clock.getDate()

--Starten des Weckers
xpcall(clock.readAlarmFile, clock.saveAlarms)
clock.getNextAlarm()
--konfiguriere den RTC Chip
--clock.write(0xE, 0)
return clock
