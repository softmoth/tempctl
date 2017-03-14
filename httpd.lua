print("in httpd.lua")
srv = net.createServer(net.TCP)


srv:listen(80,function(conn)

    conn:on("receive", function(client,request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
        --local _GET = {}
        _GET = {}
        print("getting vars")
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                print("k:"..k)
                print("v:"..v)
                _GET[k] = v
            end
        end

        if(_GET.settemp ~= nil)then
            print("received: settemp")
            targettemp = _GET.settemp
        end
        if(_GET.tempadjust ~= nil)then
            print("received: tempadjust")
            targettemp = targettemp + _GET.tempadjust
        end

        header = "HTTP/1.1 200 OK\r\n\r\n"

        html = "<h1>ESP8266 Beer Server</h1>"
        if (lasttemp ~= nil) then
            html = html .. "<p>Current temperature is:" .. lasttemp .. "</p>"
        end
        if (targettemp ~= nil) then
            html = html .. "<p>Target temperature is:" .. targettemp .. "</p>"
        end
        html = html .. "<p><a href=\"?settemp=0\"><button>0</button></a>&nbsp;<a href=\"?settemp=100\"><button>100</button></a></p>"
        html = html .. "<p><a href=\"?tempadjust=5\"><button>+5</button></a>&nbsp;<a href=\"?tempadjust=-5\"><button>-5</button></a></p>"
        if (thing_field_chart_url ~= nil) then
            html = html .. '<iframe width="450" height="260" style="border: 1px solid #cccccc;"src="'
            html = html .. thing_field_chart_url
            html = html .. '"></iframe>'
        end

        client:send(header..html)
        print("HTTP Server is now listening. Free Heap:", node.heap())
    end)

    conn:on("sent",function(conn) conn:close() end)
end)
