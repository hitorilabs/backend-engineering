import WebSocket, { WebSocketServer } from 'ws';

const wss = new WebSocketServer({
  port: 8080,
  perMessageDeflate: {
    zlibDeflateOptions: {
      // See zlib defaults.
      chunkSize: 1024,
      memLevel: 7,
      level: 3
    },
    zlibInflateOptions: {
      chunkSize: 10 * 1024
    },
    // Other options settable:
    clientNoContextTakeover: true, // Defaults to negotiated value.
    serverNoContextTakeover: true, // Defaults to negotiated value.
    serverMaxWindowBits: 10, // Defaults to negotiated value.
    // Below options specified as default values.
    concurrencyLimit: 10, // Limits zlib concurrency for perf.
    threshold: 1024 // Size (in bytes) below which messages
    // should not be compressed if context takeover is disabled.
  }
});

let connections = [];

wss.on("request", request => {

    const connection = request.accept(null, request.origin);
    connection.on("message", message => {
        connections.forEach(c => c.send(`User${connection.socket.remotePort} says ${message.utf8Data}`))
    })

    connections.push(connection)

    connections.forEach(c => c.send(`User${connection.socket.remotePort} just connected.`))
})