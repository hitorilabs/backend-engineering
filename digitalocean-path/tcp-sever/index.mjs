import net from "net"

const server = net.createServer((socket) => {
    console.log(`New connection ${socket.remoteAddress}:${socket.remotePort}`)

    socket.write("Hello, I am the server. What is your name?\r\n")
    socket.on("data", (data) => {
        console.log(data.toString())
    })
})

server.listen(8800, "127.0.0.1")