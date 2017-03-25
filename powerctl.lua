--dofile('config.lua')

gpio.mode(heat_pin, gpio.OUTPUT)
gpio.mode(cool_pin, gpio.OUTPUT)

function pin_off(pin)
    gpio.write(pin, gpio.HIGH)
end

function pin_on(pin)
    gpio.write(pin, gpio.LOW)
end

function validTemp(t)
    if (t < -10 or t > 110) then
        return false
    end
    return true
end

function powerctl()
    print("powerctl:  last = ", lasttemp, "  target = ", targettemp)
    --if (targettemp < -10 or targettemp > 110) then
    if not validTemp(targettemp) then
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
        pin_off(heat_pin)
        pin_on(cool_pin)
    end
end

loop(10 * 1000, powerctl)
