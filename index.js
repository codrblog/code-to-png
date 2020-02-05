const FS = require('fs');
const http = require('http');
const crypto = require('crypto');

const sseHeaders = {
  'Content-Type': 'text/event-stream',
  'Connection': 'keep-alive',
  'Cache-Control': 'no-cache'
};

let clients = [];
const queue = new Map();

function dispatch(payload) {
  const { action } = payload;

  switch (action) {
    case 'get':
      addToQueue(payload);
      sendEvent(payload);
      break;

    case 'set':
      returnImage(payload);
      break;
  }
}

function returnImage(payload) {
  const { image, hash } = JSON.parse(payload.content);

  if (!queue.has(hash)) {
    return;
  }

  const response = queue.get(hash);
  queue.delete(hash);

  response.writeHead(200, { 'Access-Control-Allow-Origin': '*' });
  response.end(image);
}

function addToQueue({response, content}) {
  const hash = crypto.createHash('sha256').update(content).digest('hex');
  queue.set(hash, response);
}

function sendEvent({content}) {
  const event = `data: ${JSON.stringify({ content })}\n\n`;
  clients.forEach(client => {
    client.events.write(event);
  });
}

function readBody(request, callback) {
  let body = '';
  request.on('data', (chunk) => body += chunk);
  request.on('end', () => callback(body));
}

http.createServer((request, response) => {
  if (request.method === 'OPTIONS') {
    response.writeHead(204, { 'Access-Control-Allow-Origin': '*' });
    return;
  }

  if (request.method === 'POST' && request.url === '/get') {
    readBody(request, (content) => dispatch({response, content, action: 'get'}))
    return;
  }

  response.writeHead(404);
  response.end();
}).listen(process.env.PORT || 5000, '0.0.0.0');

http.createServer((request, response) => {
  if (request.method === 'POST' && request.url === '/set') {
    readBody(request, (content) => dispatch({response, content, action: 'set'}))
    return;
  }

  if (request.url === '/events') {
    const clientId = Date.now();

    response.writeHead(200, sseHeaders);
    clients.push({
      id: clientId,
      events: response
    });

    request.on('close', () => {
      clients = clients.filter(client => client.id !== clientId);
    });

    return;
  }

  FS.createReadStream(`./client/${request.url.endsWith('test') ? 'test' : 'index'}.html`).pipe(response);
})
  .listen(3000, '127.0.0.1');
