const http = require('http');
const PORT = 3000;

http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    if (req.url.startsWith('/api/status')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            status: 'ok', 
            time: new Date().toISOString(),
            node: process.version 
        }));
    } else if (req.url.startsWith('/api/')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            endpoint: req.url, 
            method: req.method,
            time: new Date().toISOString() 
        }));
    } else if (req.url === '/events') {
        res.writeHead(200, { 
            'Content-Type': 'text/event-stream', 
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        });
        const interval = setInterval(() => {
            res.write(`data: ${JSON.stringify({ time: new Date().toISOString() })}\n\n`);
        }, 2000);
        req.on('close', () => clearInterval(interval));
    } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not Found' }));
    }
}).listen(PORT, '127.0.0.1', () => console.log('Node.js API on port ' + PORT));
