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
function getTemp(pin)
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
                            --callback_func(t / 10000)
                            lasttemp = t / 10000
                        end
                    end)
            end
        end
    end
end

loop(getTempInterval * 1000, function() getTemp(ds1820_pin) end)
