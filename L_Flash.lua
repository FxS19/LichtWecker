local LED_MODE = {}
LED_MODE.__index = LED_MODE

function LED_MODE:create(val)
  local this = {}
  local ok,l=pcall(nvs.read,"settings", "Lampe")
  if not ok then l=10 end
  this.brightness=11-l
  this.name = "Flash"
  this.r = 255
  this.b = 0
  this.g = 0
  this.amount = 5
  this.ctr = 1
  this.seconds=10
  this.ticks=0
  this.front = true
  this.back = true
  --Farbe und parameter übertragen
  if val then
    for k, v in pairs(val) do
      this[k] = v
    end
  end
  if this.amount<1 then this.amount=1 end
  if (this.seconds/this.amount)*25 < 2 then
    this.amount=this.seconds
  end
  setmetatable(this, LED_MODE)
  return this
end

--mit 25Hz aufgerufen
function LED_MODE:update()
  self.ticks=self.ticks+1
  local steps=math.floor((self.seconds/self.amount)*25)--Schritte pro Durchgang
  local progress = (self.ticks%steps)/(steps-1) --Wert von 0-1
  progress=progress*progress
  led.setColor(math.floor(self.r*progress),math.floor(self.g*progress),math.floor(self.b*progress));
  if self.ticks==self.seconds*25 then
    led.setColor(0,0,0)
    led.show()
    led.stop()
    print("Fertig")
  else
    led.show()
  end
end

return LED_MODE
