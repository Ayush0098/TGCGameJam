// Serve only the exported build, using Node.js's built-in HTTP server.
import { createServer } from 'node:http';
import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { extname, isAbsolute, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webRoot = fileURLToPath(new URL('../../build/web/', import.meta.url));
const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.pck': 'application/octet-stream',
};

createServer(async (request, response) => {
  if (!['GET', 'HEAD'].includes(request.method)) {
    response.writeHead(405, { Allow: 'GET, HEAD' });
    response.end();
    return;
  }

  try {
    const url = new URL(request.url, 'http://127.0.0.1:8765');
    const pathname = decodeURIComponent(url.pathname);
    const file = resolve(webRoot, `.${pathname === '/' ? '/index.html' : pathname}`);
    const withinRoot = relative(webRoot, file);
    if (withinRoot.startsWith('..') || isAbsolute(withinRoot)) {
      response.writeHead(403);
      response.end();
      return;
    }
    const info = await stat(file);
    if (!info.isFile()) throw new Error('Not a file');
    response.writeHead(200, {
      'Content-Type': types[extname(file)] ?? 'application/octet-stream',
      'Content-Length': info.size,
      'Cache-Control': 'no-store',
    });
    if (request.method === 'HEAD') {
      response.end();
    } else {
      createReadStream(file).on('error', () => response.destroy()).pipe(response);
    }
  } catch {
    response.writeHead(404);
    response.end('Export the Web preset first.');
  }
}).listen(8765, '127.0.0.1', () => {
  console.log('Godot web preview: http://127.0.0.1:8765');
  console.log('Press Ctrl+C to stop.');
});
