const ws = require('ws');

const server = new ws.Server({
  port: process.env.PORT || 5000
});

server.on('connection', function(socket) {
  socket.send('OK');
  socket.on('message', console.log);
});
