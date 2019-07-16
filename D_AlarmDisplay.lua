local AlarmDisplay = {}
AlarmDisplay.__index = AlarmDisplay

function AlarmDisplay:create()
  --print(os.time(clock.osTime))
  local this = {}
  math.randomseed(os.time(clock.osTime)%1567)
  math.random(); math.random(); math.random()
  local arrg=math.random(1,speaker.tracks)
  this.name = "Alarm"
  this.snooze = 600
  this.cursor = 1
  this.tick = 0
  this.volume = 0
  this.code=math.random(1,4)
  this.maxVol=15
  this.maxcursor=6
  local ok, val = pcall(nvs.read, "settings", "Volume")
  if ok then this.maxVol = val end
  setmetatable(this, AlarmDisplay)
  startBar(this.maxcursor, 55)
  display.dimm(255)
  speaker.send(0x06, 1)--Volume 1
  speaker.send(0x4E, 1)--Titel in Ordner 1
  print("Track"..arrg, "Es gibt "..speaker.tracks.." Lieder")
  speaker.send(speaker.PLAY_TRACK_FOLDER, 0x100 + arrg)--Titel in Ordner 1
  print("gesendet")
  --speaker.send(0x0D)--Play
  return this
end

function AlarmDisplay:show()
  self.snooze = self.snooze - 1
  if self.snooze==0 then
    self:disable()
    led.start("Flash",{amount=60,seconds=30})
  end
  self.tick = self.tick + 1
  if self.tick%15 == 0 and self.volume < self.maxVol then
    print("Volume: "..self.volume)
    self.volume = self.volume + 1
    speaker.send(speaker.SET_VOL, self.volume)
  end
  if clock.osTime.sec==0 or self.snooze==599 then
    self:update()
  end
end

function AlarmDisplay:update()
  display.setfont(gdisplay.FONT_DEFAULT)
  display.rect({gdisplay.CENTER, 15}, 100, 15, gdisplay.BLACK, gdisplay.BLACK)
  display.write({gdisplay.CENTER, 15}, self.cursor..". Taste")

  local x
  if clock.osTime.min > 9 then
    x = clock.osTime.min
  else
    x = "0"..clock.osTime.min
  end
  --gdisplay.write({95, 1}, math.floor(self.snooze / 60)..":"..x)
  display.write({85, 1}, clock.osTime.hour..":"..x)
  display.setfont(gdisplay.FONT_DEJAVU18)
  display.rect({gdisplay.CENTER, 30}, 100, 18, gdisplay.BLACK, gdisplay.BLACK)
  if self.code == 1 then
    display.write({gdisplay.CENTER, 30}, "SET")
  elseif self.code == 2 then
    display.write({gdisplay.CENTER, 30}, "NEXT")
  elseif self.code == 3 then
    display.write({gdisplay.CENTER, 30}, "UP")
  elseif self.code == 4 then
    display.write({gdisplay.CENTER, 30}, "DOWN")
  else
    display.write({gdisplay.CENTER, 30}, "INTERN")
  end
end

function AlarmDisplay:disable()
  speaker.send(speaker.STOP)
  led.start("Fade", {r = 0, g = 0, b = 0})
  thread.sleep(1)
  changeMode("TimeDisplay")
end

function AlarmDisplay:check(id)
  if not self.firstpress then
    self.firstpress = true
    led.start("Fade", {speed = 1, r = 20, g = 8, b = 8})
  end
  self.snooze = 500
  if self.code== id then
    showBar(1)
    if self.cursor < self.maxcursor then
      self.cursor = self.cursor + 1
      --self:show()
    else
      self:disable()
      return
    end
  else
    startBar(self.maxcursor, 55)
    self.cursor = 1
  end
  math.randomseed(os.time(clock.osTime)%1567)
  math.random(); math.random(); math.random()
  self.code=math.random(4)
  self:update()
end

function AlarmDisplay:set()
  self:check(1)
end

function AlarmDisplay:next()
  self:check(2)
end

function AlarmDisplay:up()
  self:check(3)
end

function AlarmDisplay:down()
  self:check(4)
end

return AlarmDisplay
