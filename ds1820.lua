-- Measure temperature and post data to thingspeak.com
-- Based on code by: 2014 OK1CDJ

dofile('config.lua')

ow.setup(ds1820_pin)

counter = 0

function bxor(a, b)
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
function getTemp(pin, callback_func)
    ow.reset_search(pin)
    -- FIXME: Only gets the first device on the 1-Wire bus!
    local addr = ow.search(pin)

    if (addr ~= nil) then
        local crc = ow.crc8(string.sub(addr, 1, 7))
        if (crc == addr:byte(8)) then
            if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin, 0x44, 1)
                tmr.create():alarm(1000, tmr.ALARM_SINGLE,
                    function()
                        local present = ow.reset(pin)
                        ow.select(pin, addr)
                        ow.write(pin, 0xBE, 1)
                        local data = nil
                        data = string.char(ow.read(pin))
                        for i = 1, 8 do
                            data = data .. string.char(ow.read(pin))
                        end
                        local crc = ow.crc8(string.sub(data, 1, 8))
                        if (crc == data:byte(9)) then
                            local t = (data:byte(1) + data:byte(2) * 256)
                            if (t > 32768) then
                                t = (bxor(t, 0xffff)) + 1
                                t = (-1) * t
                            end
                            t = t * 625
                            -- NB: This expects -float firmware
                            callback_func(t / 10000)
                        end
                    end)
            end
        end
    end
end

--- Get temp and send data to thingspeak.com
function sendData(t)
    lasttemp = t
    local temp = string.format("%.2f", t)
    print("Temperature: " .. temp .. "°C")
    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end)
    conn:on("connection",
        function(conn)
            --print("Sending data to thingspeak.com")
            local req = "GET /update?key=" .. thing_api_key
            req = req .. "&" .. thing_field .. "=" .. temp
            req = req .. " HTTP/1.1\r\n"
            req = req .. "Host: api.thingspeak.com\r\n"
            req = req .. "Accept: */*\r\n"
            req = req .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua)\r\n"
            req = req .. "\r\n"
            conn:send(req)
        end)

    conn:on("sent", function(conn) conn:close() end)

    -- api.thingspeak.com 184.106.153.149
    conn:connect(80, '184.106.153.149')
end

loop(1 * 60 * 1000, function() getTemp(ds1820_pin, sendData) end)
