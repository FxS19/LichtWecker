local speaker = {}
speaker.state = 0
speaker.deep_err_count=0
speaker.endPlay=false
speaker.tracks=0
speaker.track=1
speaker.mtx = thread.createmutex()

uart.attach(uart.UART2, 9600, 8, uart.PARNONE, uart.STOP1)

--SEND-COMMANDS
speaker.PLAY = 0x0D
speaker.PAUSE = 0x0E
speaker.STOP = 0x16
speaker.NEXT = 0x01
speaker.PREV = 0x02
speaker.INC_VOL = 0x04
speaker.DEC_VOL = 0x05
speaker.SET_VOL = 0x06
speaker.SLEEP = 0x0A
speaker.PLAY_TRACK_FOLDER = 0xF
speaker.FILE_NUM = 0x48
speaker.FILE_NUM_FOLDER = 0x4E
speaker.RESET = 0x0C
speaker.CURRENT_TRACK= 0x4C

--RETURN-COMMANDS
speaker.ret = {}
speaker.ret.PLAYBACK_END = 0x3D
speaker.ret.ERROR = 0x40
speaker.ret.OK = 0x41
speaker.ret.SD_ONLINE = 0x3F
speaker.ret.SD_PLUGGED_IN = 0x3A
speaker.ret.SD_REMOVED = 0x3B

--RETURN-ERROR-CODES (0x40==speaker.return.ERROR)
speaker.error = {}
speaker.error.BUSY = 0x01
speaker.error.SLEEP = 0x02
speaker.error.FRAME = 0x03
speaker.error.CHECKSUM = 0x04
speaker.error.NO_TRACK = 0x05
speaker.error.NOT_FOUND = 0x06
speaker.error.SD_ERROR = 0x08
speaker.error.GO_IN_SLEEP = 0x0A


local function listener()
  local d = ""
  local function check()

    local mode = string.byte(d, 4)
    local data = string.byte(d, 6) * 256 + string.byte(d, 7)
    d = ""

    --Titel fertig
    --komischerweise sendet der MP3 Player das Fertig-Signal 2x
    if mode == speaker.ret.PLAYBACK_END then
      if not speaker.endPlay then
        speaker.endPlay=true
      else
        print("Send next Track")
        thread.sleepms(200)
        speaker.send(speaker.NEXT)--next
        speaker.endPlay=false
        speaker.send(speaker.CURRENT_TRACK)
      end
    end

    --Anzahl Daten im Ordner
    if mode==speaker.FILE_NUM_FOLDER then
      speaker.tracks=data
    end

    --Aktueller Track
    if mode==speaker.CURRENT_TRACK then
      speaker.track=data
    end
    --CODE-Suchen...ubersetzen
    local found=flase
    for k, v in pairs(speaker.ret) do
      if v == mode then
         if k:find("SD") then
           changeMode("SD_ERROR", {text = k})
         end
         print("Speaker: "..k)
         found=true
       end
    end
    for k,v in pairs(speaker) do
      if v==mode then
        if data==0 then
          print("Speaker: "..k)
        else
          print("Speaker: "..k, data)
        end
        found=true
      end
    end
    if not found then
      local p=""
      local tmp=copy(d)
      for k=1, tmp:len()  do
        local x=tmp:byte(k)
        p=p.." "..string.format("%02X",x)
      end
      print("Speaker: "..p)
    end

    if mode == speaker.ret.ERROR then
      --print("Error", "Data: "..data)
      for k, v in pairs(speaker.error) do
        if data == v then
          print(k)
        end
      end
      if data == speaker.error.SLEEP then
        speaker.state = "sleep"
      end
      if data == speaker.error.BUSY then
        changeMode("SD_ERROR", {text = "MP3_BUSY"})
      end
      if data == speaker.error.FRAME then
        speaker.deep_err_count=speaker.deep_err_count+1
        if speaker.deep_err_count>0 then
          addTodo(function()
            speaker.force_send(speaker.RESET)
            speaker.init()
            speaker.deep_err_count=0
          end)
        end
      end
    end

    if Modus and Modus.speaker then
      local ok, err = assert(Modus.speaker,Modus,mode, data)
      if not ok then print(ok,err) end
    end
  end

  while true do
    local v = uart.read(uart.UART2, "*c", 100000)
    if v ~= nil then
      if v == 0x7E then
        d=""
      end
      d = d..string.char(v)
    end
    if d:len() == 10 then check() end
    collectgarbage()
  end
end
thread.start(listener, 4096, nil, 0, "Speaker")

function speaker.force_send(c, d)
  d = d or 0
  local needAck = 1

  local precomm = string.pack(">I1s1", 0xff, string.pack(">I1I1I2I2", c, needAck, d, 0))
  local sum = 0
  for i = 1, precomm:len() do
    sum = sum + string.byte(precomm, i)
  end
  sum = -sum
  sum = string.unpack(">xxI2", string.pack(">i4", sum))
  local content = string.pack(">I1I1I1I1I1I2I2I1", 0x7e, 0xff, 0x06, c, needAck, d, sum, 0xef)
  --print("vor MUTEX")
  speaker.mtx:lock()
  --print("nach MUTEX")
  for i = 1, content:len() do
    --print(string.byte(content,i))
    uart.write(uart.UART2, string.byte(content, i))
  end
  --print("GESENDET")
  speaker.mtx:unlock()
  --print("MUTEX ENTSPERRT")
end

function speaker.sleep()
  speaker.state = speaker.SLEEP
  speaker.force_send(speaker.SLEEP)
end

function speaker.send(command, data)
  --print("SENDEN")
  if speaker.state == speaker.SLEEP then
    --print("Will Wecken")
    speaker.force_send(0x09, 0x01)
    speaker.state = 0
    print("Lautsprecher Geweckt")
  end
  thread.sleepms(100)
  speaker.force_send(command, data)
end

function speaker.init()
  thread.sleepms(500)
  speaker.force_send(0x09, 0x01)--WECKEN
  speaker.send(speaker.STOP)

  local ok, s = pcall(nvs.read, "settings", "Volume")
  if not ok then s = 10 end
  print("Volume to: "..s)
  speaker.send(speaker.SET_VOL, s)--Lautstärke s/30
  speaker.send(speaker.FILE_NUM_FOLDER, 1)--Titel in Ordner 1
  speaker.sleep()
end

return speaker
