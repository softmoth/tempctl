dofile('config.lua')

function trythen(initf, contf, delay, delay_msg)
    local result = initf()
    if (result == nil) then
        local i = 0
        local timer = tmr.create()
        timer:alarm(delay, tmr.ALARM_AUTO, function()
                i = i + 1
                print("Attempt #" .. i)
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

print("Setting up WIFI (" .. wifi_ssid .. ")")
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_password)
wifi.sta.connect()
trythen(
    function() return wifi.sta.getip() end,
    function(res)
        print("Config done, IP is " .. res)
        dofile('ds1820.lua')
    end,
    1000,
    "IP unavailable, waiting...")
