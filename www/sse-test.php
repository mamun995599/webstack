<!DOCTYPE html>
<html>
<head>
    <title>SSE Test</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; background: #f5f5f5; }
        h1 { color: #333; }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin: 20px 0; }
        #status { padding: 15px; margin: 10px 0; border-radius: 5px; font-weight: bold; text-align: center; }
        .connected { background: #d4edda; color: #155724; }
        .disconnected { background: #f8d7da; color: #721c24; }
        .connecting { background: #fff3cd; color: #856404; }
        #messages { height: 300px; overflow-y: auto; border: 1px solid #ddd; padding: 10px; 
                    margin: 10px 0; background: #1e1e1e; color: #00ff00; font-family: monospace;
                    border-radius: 5px; font-size: 13px; }
        .msg { padding: 3px 0; }
        button { padding: 12px 20px; font-size: 16px; cursor: pointer; border: none; border-radius: 5px; margin: 5px; }
        .btn-connect { background: #28a745; color: white; }
        .btn-disconnect { background: #dc3545; color: white; }
        button:disabled { background: #ccc; cursor: not-allowed; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .info code { background: #d4d4d4; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>📢 Server-Sent Events (SSE) Test</h1>
    
    <div class="card">
        <h2>Node.js SSE (/events)</h2>
        <div class="info">
            <strong>Endpoint:</strong> <code>/events</code>
            <br><small>SSE through Node.js - sends heartbeat every 2 seconds</small>
        </div>
        
        <div>
            <button id="connectBtn1" class="btn-connect" onclick="connectNodeSSE()">Connect</button>
            <button id="disconnectBtn1" class="btn-disconnect" onclick="disconnectNodeSSE()" disabled>Disconnect</button>
        </div>
        
        <div id="status1" class="disconnected">● Disconnected</div>
        <div id="messages1" class="messages"></div>
    </div>
    
    <div class="card">
        <h2>Push Stream SSE (/sse/sub)</h2>
        <div class="info">
            <strong>Endpoint:</strong> <code>/sse/sub?channel=test</code>
            <br><small>Nginx Push Stream module - pub/sub messaging</small>
        </div>
        
        <div>
            <input type="text" id="channel" value="test" placeholder="Channel name" style="padding:10px;width:150px;">
            <button id="connectBtn2" class="btn-connect" onclick="connectPushSSE()">Subscribe</button>
            <button id="disconnectBtn2" class="btn-disconnect" onclick="disconnectPushSSE()" disabled>Unsubscribe</button>
        </div>
        
        <div>
            <input type="text" id="pubMessage" placeholder="Message to publish" style="padding:10px;width:250px;margin-top:10px;">
            <button onclick="publishMessage()" style="background:#007bff;color:white;padding:12px 20px;border:none;border-radius:5px;">Publish</button>
        </div>
        
        <div id="status2" class="disconnected">● Disconnected</div>
        <div id="messages2" class="messages"></div>
    </div>

    <script>
        let nodeSSE = null;
        let pushSSE = null;
        
        function log(containerId, text) {
            const container = document.getElementById(containerId);
            const div = document.createElement('div');
            div.className = 'msg';
            div.textContent = `[${new Date().toLocaleTimeString()}] ${text}`;
            container.appendChild(div);
            container.scrollTop = container.scrollHeight;
        }
        
        // Node.js SSE
        function connectNodeSSE() {
            document.getElementById('status1').textContent = '● Connecting...';
            document.getElementById('status1').className = 'connecting';
            log('messages1', 'Connecting to /events...');
            
            try {
                nodeSSE = new EventSource('https://localhost/api/events');
                
                nodeSSE.onopen = function() {
                    log('messages1', 'Connected!');
                    document.getElementById('status1').textContent = '● Connected';
                    document.getElementById('status1').className = 'connected';
                    document.getElementById('connectBtn1').disabled = true;
                    document.getElementById('disconnectBtn1').disabled = false;
                };
                
                nodeSSE.onmessage = function(event) {
                    log('messages1', 'Data: ' + event.data);
                };
                
                nodeSSE.onerror = function() {
                    log('messages1', 'Error or connection closed');
                    document.getElementById('status1').textContent = '● Error';
                    document.getElementById('status1').className = 'disconnected';
                    document.getElementById('connectBtn1').disabled = false;
                    document.getElementById('disconnectBtn1').disabled = true;
                };
            } catch (e) {
                log('messages1', 'Error: ' + e.message);
            }
        }
        
        function disconnectNodeSSE() {
            if (nodeSSE) {
                nodeSSE.close();
                nodeSSE = null;
                log('messages1', 'Disconnected');
                document.getElementById('status1').textContent = '● Disconnected';
                document.getElementById('status1').className = 'disconnected';
                document.getElementById('connectBtn1').disabled = false;
                document.getElementById('disconnectBtn1').disabled = true;
            }
        }
        
        // Push Stream SSE
        function connectPushSSE() {
            const channel = document.getElementById('channel').value || 'test';
            document.getElementById('status2').textContent = '● Connecting...';
            document.getElementById('status2').className = 'connecting';
            log('messages2', 'Subscribing to channel: ' + channel);
            
            try {
                pushSSE = new EventSource('https://localhost/sse/sub?channel=' + channel);
                
                pushSSE.onopen = function() {
                    log('messages2', 'Subscribed!');
                    document.getElementById('status2').textContent = '● Subscribed to: ' + channel;
                    document.getElementById('status2').className = 'connected';
                    document.getElementById('connectBtn2').disabled = true;
                    document.getElementById('disconnectBtn2').disabled = false;
                };
                
                pushSSE.onmessage = function(event) {
                    log('messages2', 'Message: ' + event.data);
                };
                
                pushSSE.onerror = function() {
                    log('messages2', 'Error or connection closed');
                    document.getElementById('status2').textContent = '● Error';
                    document.getElementById('status2').className = 'disconnected';
                    document.getElementById('connectBtn2').disabled = false;
                    document.getElementById('disconnectBtn2').disabled = true;
                };
            } catch (e) {
                log('messages2', 'Error: ' + e.message);
            }
        }
        
        function disconnectPushSSE() {
            if (pushSSE) {
                pushSSE.close();
                pushSSE = null;
                log('messages2', 'Unsubscribed');
                document.getElementById('status2').textContent = '● Disconnected';
                document.getElementById('status2').className = 'disconnected';
                document.getElementById('connectBtn2').disabled = false;
                document.getElementById('disconnectBtn2').disabled = true;
            }
        }
        
        function publishMessage() {
            const channel = document.getElementById('channel').value || 'test';
            const message = document.getElementById('pubMessage').value || 'Hello!';
            
            fetch('https://localhost/sse/pub?channel=' + channel, {
                method: 'POST',
                body: message
            })
            .then(r => {
                if (r.ok) {
                    log('messages2', 'Published: ' + message);
                    document.getElementById('pubMessage').value = '';
                } else {
                    log('messages2', 'Publish failed: ' + r.status);
                }
            })
            .catch(e => {
                log('messages2', 'Publish error: ' + e.message);
            });
        }
    </script>
    
    <style>
        .messages { 
            height: 200px; 
            overflow-y: auto; 
            border: 1px solid #ddd; 
            padding: 10px; 
            margin: 10px 0; 
            background: #1e1e1e; 
            color: #00ff00; 
            font-family: monospace;
            border-radius: 5px; 
            font-size: 13px; 
        }
    </style>
</body>
</html>