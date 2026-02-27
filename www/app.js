const http = require('http');
const PORT = 3000;

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }
    
    const url = req.url;
    
    // Status endpoint
    if (url === '/api/status' || url === '/api/status/') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'ok',
            service: 'WebStack Node.js API',
            node: process.version,
            platform: process.platform,
            uptime: Math.floor(process.uptime()),
            memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
            time: new Date().toISOString()
        }, null, 2));
        return;
    }
    
    // Health check
    if (url === '/api/health' || url === '/api/health/') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ healthy: true }));
        return;
    }
    
    // Echo endpoint
    if (url.startsWith('/api/echo')) {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                method: req.method,
                url: req.url,
                headers: req.headers,
                body: body || null,
                time: new Date().toISOString()
            }, null, 2));
        });
        return;
    }
    
    // Server-Sent Events
    if (url === '/api/events' || url === '/events') {
        res.writeHead(200, {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        });
        
        const sendEvent = () => {
            res.write(`data: ${JSON.stringify({ time: new Date().toISOString(), random: Math.random() })}\n\n`);
        };
        
        sendEvent();
        const interval = setInterval(sendEvent, 2000);
        
        req.on('close', () => {
            clearInterval(interval);
        });
        return;
    }
    
    // Generic API endpoint
    if (url.startsWith('/api/')) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            endpoint: url,
            method: req.method,
            message: 'API endpoint ready',
            time: new Date().toISOString()
        }));
        return;
    }
    
    // 404 for everything else
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not Found', path: url }));
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`[${new Date().toISOString()}] Node.js API server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down...');
    server.close(() => process.exit(0));
});
