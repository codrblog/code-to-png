const FS = require('fs');

require('http')
  .createServer((_, res) => FS.createReadStream('./client/index.html').pipe(res))
  .listen(process.env.PORT || 3000);
