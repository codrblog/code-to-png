const FS = require('fs');

require('http').createServer(function(req, res) {
  if (req.url === '/') {
    FS.createReadStream('./client/index.html').pipe(res);
    return;
  }

  res.writeHead(404);
  res.end();
}).listen(process.env.PORT || 3000);