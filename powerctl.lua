dofile('config.lua')

local heat_pin = 6
local cool_pin = 7

gpio.mode(heat_pin, gpio.OUTPUT)
gpio.mode(cool_pin, gpio.OUTPUT)

function pin_off(pin)
    gpio.write(pin, gpio.HIGH)
end

function pin_on(pin)
    gpio.write(pin, gpio.LOW)
end

function powerctl()
    print("powerctl:  last = ", lasttemp, "  target = ", targettemp)
    if (targettemp < -10 or targettemp > 110) then
        print("... target out of range, ignoring")
        pin_off(heat_pin)
        pin_off(cool_pin)
    elseif (math.abs(targettemp - lasttemp) < 1) then
        print("... at target temp")
        pin_off(heat_pin)
        pin_off(cool_pin)
    elseif (targettemp > lasttemp) then
        print("... heating up to target")
        pin_off(cool_pin)
        pin_on(heat_pin)
    else
        print("... cooling down to target")
        pin_off(cool_pin)
        pin_on(heat_pin)
    end
end

local timer = tmr.create()
timer:alarm(10 * 1000, tmr.ALARM_AUTO, powerctl)

--timer:alarm(3 * 1000, tmr.ALARM_AUTO, function ()
--        print("powerctl, last = ", lasttemp, ", target = ", targettemp)
--    end)
