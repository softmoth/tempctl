collectgarbage()
abort = false

function startup()
    uart.on("data")
        if abort == true then
                print('Aborted')
                return
        end
        dofile('main.lua')
end

print('Press c to abort')
-- if <CR> is pressed, abort
uart.on("data", "c",
        function(data)
                --print("receive from uart:", data)
                if data == "c" then
                        abort = true
                        uart.on("data")
                end
        end, 0)

tmr.alarm(0, 2000, 0, startup)
