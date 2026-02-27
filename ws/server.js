const WebSocket = require('ws');
const PORT = 8081;

const wss = new WebSocket.Server({ port: PORT });
let clientId = 0;
const clients = new Map();

wss.on('connection', (ws, req) => {
    const id = ++clientId;
    const clientIp = req.socket.remoteAddress;
    
    clients.set(id, { ws, ip: clientIp, joinedAt: new Date() });
    
    console.log(`[${new Date().toISOString()}] Client ${id} connected from ${clientIp}`);
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        id: id,
        message: 'Connected to WebStack WebSocket server',
        clients: clients.size,
        time: new Date().toISOString()
    }));
    
    // Broadcast new client to others
    broadcast({
        type: 'client_joined',
        id: id,
        clients: clients.size
    }, ws);
    
    // Handle messages
    ws.on('message', (data) => {
        const message = data.toString();
        console.log(`[${new Date().toISOString()}] Client ${id}: ${message}`);
        
        try {
            const parsed = JSON.parse(message);
            
            // Handle different message types
            if (parsed.type === 'ping') {
                ws.send(JSON.stringify({ type: 'pong', time: new Date().toISOString() }));
            } else if (parsed.type === 'broadcast') {
                broadcast({
                    type: 'broadcast',
                    from: id,
                    data: parsed.data,
                    time: new Date().toISOString()
                });
            } else {
                // Echo back
                ws.send(JSON.stringify({
                    type: 'echo',
                    data: parsed,
                    time: new Date().toISOString()
                }));
            }
        } catch (e) {
            // Plain text message - echo back
            ws.send(JSON.stringify({
                type: 'echo',
                data: message,
                time: new Date().toISOString()
            }));
            
            // Broadcast to others
            broadcast({
                type: 'message',
                from: id,
                data: message,
                time: new Date().toISOString()
            }, ws);
        }
    });
    
    // Handle disconnect
    ws.on('close', () => {
        clients.delete(id);
        console.log(`[${new Date().toISOString()}] Client ${id} disconnected`);
        
        broadcast({
            type: 'client_left',
            id: id,
            clients: clients.size
        });
    });
    
    // Handle errors
    ws.on('error', (error) => {
        console.error(`[${new Date().toISOString()}] Client ${id} error:`, error.message);
    });
});

function broadcast(message, exclude = null) {
    const data = JSON.stringify(message);
    clients.forEach((client) => {
        if (client.ws !== exclude && client.ws.readyState === WebSocket.OPEN) {
            client.ws.send(data);
        }
    });
}

console.log(`[${new Date().toISOString()}] WebSocket server running on port ${PORT}`);
