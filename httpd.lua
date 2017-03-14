srv = net.createServer(net.TCP)


srv:listen(80,function(conn)

    conn:on("receive", function(client,request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end

            if (_GET.settemp ~= nil) then
                local tmp = tonumber(_GET.settemp)
                if (tmp ~= nil) then
                    targettemp = tmp
                end
            end

            header = "HTTP/1.1 302 Found\r\nLocation: /\r\n"
            html = ""
        else
            header = "HTTP/1.1 200 OK\r\n\r\n"
            html   = "<h1>ESP8266 Fermentation Controller</h1>"
            if (lasttemp ~= nil) then
                html = html .. "<p>Current temperature is: " .. lasttemp .. "</p>"
            end
            if (targettemp ~= nil) then
                html = html .. "<p>Target temperature is: " .. targettemp .. "</p>"
            end
            html = html .. "<form action='' method='GET'>"
            html = html .. "<p>Set target temperature: <input name='settemp'> (Celsius)</p>"
            html = html .. "<br>"
            if (thing_field_chart_url ~= nil) then
                html = html .. '<iframe width="450" height="260" style="border: 1px solid #cccccc;"src="'
                html = html .. thing_field_chart_url
                html = html .. '"></iframe>'
            end
        end

        client:send(header..html)
        print("HTTP Server is now listening. Free Heap:", node.heap())
    end)

    conn:on("sent",function(conn) conn:close() end)
end)
