dofile('config.lua')

lasttemp = -999
targettemp = -999

function trythen(initf, contf, delay, delay_msg)
    local result = initf()
    if (result == nil) then
        local timer = tmr.create()
        timer:alarm(delay, tmr.ALARM_AUTO, function()
                result = initf()
                if result == nil then
                    print(delay_msg)
                else
                    timer:unregister()
                    contf(result)
                end
            end)
    end
end

function loop(delay, func)
    func()
    local timer = tmr.create()
    timer:alarm(delay, tmr.ALARM_AUTO, func)
end

print("Setting up WIFI (" .. wifi_ssid .. ")")
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_password)
wifi.sta.connect()

trythen(
    function() return wifi.sta.getip() end,
    function(res)
        print("Config done, IP is " .. res)
        dofile('ds1820.lua')
        dofile('httpd.lua')
        dofile('powerctl.lua')
    end,
    1000,
    "IP unavailable, waiting...")

