const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8081 });
let clientId = 0;

wss.on('connection', (ws, req) => {
    const id = ++clientId;
    console.log(`Client ${id} connected`);
    
    ws.send(JSON.stringify({ type: 'welcome', id: id, time: new Date().toISOString() }));
    
    ws.on('message', data => {
        const message = data.toString();
        console.log(`Client ${id}: ${message}`);
        
        // Echo back
        ws.send(JSON.stringify({ type: 'echo', data: message, time: new Date().toISOString() }));
        
        // Broadcast to all clients
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ type: 'broadcast', from: id, data: message }));
            }
        });
    });
    
    ws.on('close', () => console.log(`Client ${id} disconnected`));
});

console.log('WebSocket server running on port 8081');
