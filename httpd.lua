print("in httpd.lua")
srv = net.createServer(net.TCP)

--srv:listen(80,function(conn)
--  conn:on("receive",function(conn,payload)
--    print(payload)
--    conn:send("<h1> Hello, NodeMCU!!! </h1>")
--  end)
--  conn:on("sent",function(conn) conn:close() end)
--end)


srv:listen(80,function(conn)
    print("srv:listen()")
    conn:on("receive", function(client,request)

        buf    = "<h1>ESP8266 Beer Server</h1>"
        buf    = buf .. "<p>Temperature is:" .. lasttemp .. "</p>"
        header = "HTTP/1.1 200 OK\r\n\r\n"

        print("--------")
        print(header..buf)
        print("--------")

        client:send(header..buf)

        print("Done with http request")
        print("HTTP Server is now listening. Free Heap:", node.heap())
    end)

    conn:on("sent",function(conn) conn:close() end)
end)
