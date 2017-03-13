-- Measure temperature and post data to thingspeak.com
-- 2014 OK1CDJ

dofile('config.lua')

pin = 3

ow.setup(pin)

counter = 0
lasttemp = -999

function bxor(a,b)
    local r = 0
    for i = 0, 31 do
        if (a % 2 + b % 2 == 1) then
            r = r + 2^i
        end
        a = a / 2
        b = b / 2
    end
    return r
end

--- Get temperature from DS18B20
function getTemp()
    addr = ow.reset_search(pin)
    repeat
        tmr.wdclr()

        if (addr ~= nil) then
            crc = ow.crc8(string.sub(addr,1,7))
            if (crc == addr:byte(8)) then
                if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                    ow.reset(pin)
                    ow.select(pin, addr)
                    ow.write(pin, 0x44, 1)
                    tmr.delay(1000000)
                    present = ow.reset(pin)
                    ow.select(pin, addr)
                    ow.write(pin,0xBE, 1)
                    data = nil
                    data = string.char(ow.read(pin))
                    for i = 1, 8 do
                        data = data .. string.char(ow.read(pin))
                    end
                    crc = ow.crc8(string.sub(data,1,8))
                    if (crc == data:byte(9)) then
                        t = (data:byte(1) + data:byte(2) * 256)
                        if (t > 32768) then
                            t = (bxor(t, 0xffff)) + 1
                            t = (-1) * t
                        end
                        t = t * 625
                        lasttemp = t
                        print("Last temp: " .. lasttemp)
                    end
                    tmr.wdclr()
                end
            end
        end
        addr = ow.search(pin)
    until(addr == nil)
end

--- Get temp and send data to thingspeak.com
function sendData()
    getTemp()
    local temp = string.format("%.2f", lasttemp / 10000)
    -- If not compiled with floating point support
    --local t1 = lasttemp / 10000
    --local t2 = (lasttemp >= 0 and lasttemp % 10000) or (10000 - lasttemp % 10000)
    --local temp = string.format("%d.%04d", t1, t2)
    print("Temp: " .. temp .. "°C\n")
    -- connection to thingspeak.com
    print("Sending data to thingspeak.com")
    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end)
    -- api.thingspeak.com 184.106.153.149
    conn:connect(80, '184.106.153.149')
    conn:send("GET /update?key="..thing_api_key.."&"..thing_field.."="..temp.." HTTP/1.1\r\n")
    conn:send("Host: api.thingspeak.com\r\n")
    conn:send("Accept: */*\r\n")
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",
    function(conn)
        print("Closing connection")
        conn:close()
    end)
    conn:on("disconnection",
    function(conn)
        print("Got disconnection...")
    end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 300000, 1, function() sendData() end)
