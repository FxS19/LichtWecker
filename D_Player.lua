local Player = {}
Player.__index = Player

function Player:create()
  nixDoTimer = 20
  --print("Erstelle Player")
  local this = {}
  this.mode=2
  this.name="Player"
  this.first=true
  setmetatable(this, Player)
  return this
end

function Player:show()
  if self.first then
    self.first=false
    speaker.send(speaker.CURRENT_TRACK)
    self:update()
  end
end

function Player:update()
  display.setfont(gdisplay.FONT_DEFAULT)
  display.write({0, gdisplay.BOTTOM},"Mode")
  function showButtons(up,down)
    display.rect({50, 0}, 78, 18, gdisplay.BLACK, gdisplay.BLACK)
    display.rect({50, 46}, 78, 18, gdisplay.BLACK, gdisplay.BLACK)
    display.write({gdisplay.RIGHT,0},up)
    display.write({gdisplay.RIGHT,49},down)
    --display.write({2,50}, left.." : "..right.."       ")
  end
  if self.mode==1 then
    showButtons("NEXT","PREV")
  elseif self.mode==2 then
    showButtons("PLAY","PAUSE")
  elseif self.mode==3 then
    showButtons("Vol+","Vol-")
  end
  display.rect({0, 23}, 127, 18, gdisplay.BLACK, gdisplay.BLACK)
  display.write({gdisplay.CENTER,gdisplay.CENTER},speaker.track.."/"..speaker.tracks)
end

function Player:next()
  changeMode("DateDisplay")
end

function Player:set()
  nixDoTimer = 20
  if self.mode<3 then self.mode=self.mode+1 else self.mode=1 end
  self:update()
end

function Player:up()
  nixDoTimer = 20
  if self.mode==1 then
    speaker.send(speaker.NEXT)--next
    speaker.send(speaker.CURRENT_TRACK)
  elseif self.mode==2 then
    --speaker.send(speaker.PLAY_TRACK_FOLDER, 0x100+speaker.track)--play
    speaker.send(speaker.PLAY)
    speaker.send(speaker.CURRENT_TRACK)
  elseif self.mode==3 then
    speaker.send(speaker.INC_VOL)--inc vol
  end
end

function Player:down()
  nixDoTimer = 20
  if self.mode==1 then
    speaker.send(speaker.PREV)--prev
    speaker.send(speaker.CURRENT_TRACK)
  elseif self.mode==2 then
    speaker.send(speaker.PAUSE)--pause
  elseif self.mode==3 then
    speaker.send(speaker.DEC_VOL)--dec vol
  end
end

function Player:speaker(mode,value)
  --print(mode,value)
  local function updater()
    self:update()
  end
  if mode==speaker.CURRENT_TRACK then
    addTodo(updater)
  end
end

return Player
