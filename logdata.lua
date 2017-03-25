

--- Get temp and send data to thingspeak.com
function sendData(sensor_id)
    t = lasttemp
    if validTemp(t) then
        local temp = string.format("%.2f", t)
        print("Temperature: " .. temp .. "°C")
        local conn = net.createConnection(net.TCP, 0)
        conn:on("receive", function(conn, payload) print(payload) end)
        conn:on("connection",
            function(conn)
                --print("Sending data to thingspeak.com")
                local req = "GET /update?key=" .. thing_api_key
                req = req .. "&" .. sensor_id .. "=" .. temp
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
    else
        print("... temp out of range, not logging.")
    end
end

loop(sendDataInterval * 1000, function() sendData(thing_field) end)
