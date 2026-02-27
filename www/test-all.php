<!DOCTYPE html>
<html>
<head>
    <title>WebStack - Test All Features</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
               background: #f5f5f5; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { text-align: center; color: #333; margin-bottom: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; }
        .card { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .card h2 { color: #667eea; margin-bottom: 15px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .status { padding: 8px 12px; border-radius: 5px; margin: 5px 0; font-family: monospace; }
        .ok { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .pending { background: #fff3cd; color: #856404; }
        .info { background: #d1ecf1; color: #0c5460; }
        button { padding: 10px 20px; background: #667eea; color: white; border: none; 
                 border-radius: 5px; cursor: pointer; margin: 5px; font-size: 14px; }
        button:hover { background: #5a67d8; }
        button:disabled { background: #ccc; cursor: not-allowed; }
        .log { background: #1e1e1e; color: #00ff00; padding: 10px; border-radius: 5px;
               font-family: monospace; font-size: 12px; max-height: 200px; overflow-y: auto;
               white-space: pre-wrap; word-break: break-all; }
        input[type="text"] { padding: 8px; width: 200px; border: 1px solid #ddd; border-radius: 4px; }
        .row { margin: 10px 0; }
        a { color: #667eea; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 WebStack - Test All Features</h1>
        
        <div class="grid">
            <!-- Protocol Info -->
            <div class="card">
                <h2>📡 Connection Info</h2>
                <div class="status info" id="protocol-info">Loading...</div>
                <div class="row">
                    <strong>URL:</strong> <span id="current-url"></span>
                </div>
                <div class="row">
                    <strong>Protocol:</strong> <span id="current-protocol"></span>
                </div>
                <div class="row">
                    <strong>HTTP Version:</strong> <span id="http-version"></span>
                </div>
            </div>

            <!-- HTTP/2 Test -->
            <div class="card">
                <h2>⚡ HTTP/2 Test</h2>
                <div class="status pending" id="http2-status">Not tested</div>
                <button onclick="testHttp2()">Test HTTP/2</button>
                <div class="log" id="http2-log"></div>
                <p style="margin-top:10px;font-size:12px;color:#666;">
                    HTTP/2 requires HTTPS. Check browser DevTools → Network → Protocol column.
                </p>
            </div>

            <!-- HTTP/3 Test -->
            <div class="card">
                <h2>🚀 HTTP/3 (QUIC) Test</h2>
                <div class="status pending" id="http3-status">Not tested</div>
                <button onclick="testHttp3()">Test HTTP/3</button>
                <div class="log" id="http3-log"></div>
                <p style="margin-top:10px;font-size:12px;color:#666;">
                    HTTP/3 uses QUIC (UDP). Check Alt-Svc header. May need browser flags enabled.
                </p>
            </div>

            <!-- WebSocket Test -->
            <div class="card">
                <h2>🔌 WebSocket Test</h2>
                <div class="status pending" id="ws-status">Not connected</div>
                <button id="ws-connect" onclick="testWebSocket()">Connect</button>
                <button id="ws-disconnect" onclick="disconnectWs()" disabled>Disconnect</button>
                <div class="row">
                    <input type="text" id="ws-message" placeholder="Message to send" disabled>
                    <button id="ws-send" onclick="sendWsMessage()" disabled>Send</button>
                </div>
                <div class="log" id="ws-log"></div>
            </div>

            <!-- SSE Test -->
            <div class="card">
                <h2>📢 SSE (Server-Sent Events) Test</h2>
                <div class="status pending" id="sse-status">Not connected</div>
                <button id="sse-connect" onclick="testSSE()">Connect SSE</button>
                <button id="sse-disconnect" onclick="disconnectSSE()" disabled>Disconnect</button>
                <div class="log" id="sse-log"></div>
            </div>

            <!-- Push Stream SSE Test -->
            <div class="card">
                <h2>📡 Push Stream SSE Test</h2>
                <div class="status pending" id="push-status">Not connected</div>
                <div class="row">
                    <input type="text" id="push-channel" value="test" placeholder="Channel name">
                </div>
                <button onclick="testPushSSE()">Subscribe</button>
                <button onclick="publishPushSSE()">Publish Message</button>
                <div class="log" id="push-log"></div>
            </div>

            <!-- API Test -->
            <div class="card">
                <h2>🔗 Node.js API Test</h2>
                <div class="status pending" id="api-status">Not tested</div>
                <button onclick="testAPI()">Test API</button>
                <div class="log" id="api-log"></div>
            </div>

            <!-- PHP Test -->
            <div class="card">
                <h2>🐘 PHP Test</h2>
                <div class="status pending" id="php-status">Not tested</div>
                <button onclick="testPHP()">Test PHP</button>
                <div class="log" id="php-log"></div>
                <p style="margin-top:10px;">
                    <a href="/phpinfo.php" target="_blank">Open PHP Info</a>
                </p>
            </div>

            <!-- RTMP Info -->
            <div class="card">
                <h2>📺 RTMP Streaming</h2>
                <div class="status info">RTMP Port: 1935</div>
                <p><strong>Stream with FFmpeg:</strong></p>
                <div class="log">ffmpeg -re -i video.mp4 -c copy -f flv rtmp://localhost/live/stream</div>
                <p style="margin-top:10px;"><strong>Watch HLS:</strong></p>
                <div class="log">http://localhost/hls/stream.m3u8</div>
                <p style="margin-top:10px;">
                    <a href="/hls/" target="_blank">View HLS Directory</a>
                </p>
            </div>
        </div>
    </div>

    <script>
        let ws = null;
        let sse = null;
        let pushSSE = null;

        // Protocol Info
        document.getElementById('current-url').textContent = location.href;
        document.getElementById('current-protocol').textContent = location.protocol;
        
        // Check HTTP version using Performance API
        function checkHttpVersion() {
            const entries = performance.getEntriesByType('navigation');
            if (entries.length > 0 && entries[0].nextHopProtocol) {
                const protocol = entries[0].nextHopProtocol;
                document.getElementById('http-version').textContent = protocol;
                document.getElementById('protocol-info').textContent = 'Using: ' + protocol.toUpperCase();
                if (protocol === 'h2') {
                    document.getElementById('http2-status').textContent = 'HTTP/2 Active!';
                    document.getElementById('http2-status').className = 'status ok';
                } else if (protocol === 'h3') {
                    document.getElementById('http3-status').textContent = 'HTTP/3 Active!';
                    document.getElementById('http3-status').className = 'status ok';
                }
            } else {
                document.getElementById('http-version').textContent = 'Unknown (check DevTools)';
            }
        }
        setTimeout(checkHttpVersion, 500);

        // HTTP/2 Test
        function testHttp2() {
            const log = document.getElementById('http2-log');
            log.textContent = 'Testing HTTP/2...\n';
            
            if (location.protocol !== 'https:') {
                log.textContent += 'ERROR: HTTP/2 requires HTTPS!\n';
                log.textContent += 'Please access via: https://' + location.host + location.pathname;
                document.getElementById('http2-status').textContent = 'Requires HTTPS';
                document.getElementById('http2-status').className = 'status error';
                return;
            }
            
            fetch('/nginx_status')
                .then(r => {
                    const protocol = performance.getEntriesByName(r.url)[0]?.nextHopProtocol || 'unknown';
                    log.textContent += 'Protocol: ' + protocol + '\n';
                    if (protocol === 'h2') {
                        document.getElementById('http2-status').textContent = 'HTTP/2 Working!';
                        document.getElementById('http2-status').className = 'status ok';
                    }
                    return r.text();
                })
                .then(text => {
                    log.textContent += 'Response:\n' + text;
                })
                .catch(e => {
                    log.textContent += 'Error: ' + e.message;
                    document.getElementById('http2-status').className = 'status error';
                });
        }

        // HTTP/3 Test
        function testHttp3() {
            const log = document.getElementById('http3-log');
            log.textContent = 'Testing HTTP/3...\n';
            
            fetch('/')
                .then(r => {
                    const altSvc = r.headers.get('alt-svc');
                    log.textContent += 'Alt-Svc Header: ' + (altSvc || 'Not found') + '\n';
                    
                    const entries = performance.getEntriesByType('navigation');
                    const protocol = entries[0]?.nextHopProtocol || 'unknown';
                    log.textContent += 'Current Protocol: ' + protocol + '\n';
                    
                    if (protocol === 'h3') {
                        document.getElementById('http3-status').textContent = 'HTTP/3 Working!';
                        document.getElementById('http3-status').className = 'status ok';
                    } else if (altSvc && altSvc.includes('h3')) {
                        document.getElementById('http3-status').textContent = 'HTTP/3 Available (Alt-Svc present)';
                        document.getElementById('http3-status').className = 'status info';
                        log.textContent += '\nHTTP/3 is advertised but browser may not use it yet.\n';
                        log.textContent += 'Try refreshing or using Chrome/Firefox with QUIC enabled.';
                    } else {
                        document.getElementById('http3-status').textContent = 'HTTP/3 Not Detected';
                        document.getElementById('http3-status').className = 'status pending';
                    }
                })
                .catch(e => {
                    log.textContent += 'Error: ' + e.message;
                });
        }

        // WebSocket Test
        function testWebSocket() {
            const log = document.getElementById('ws-log');
            const status = document.getElementById('ws-status');
            const wsUrl = 'ws://' + location.hostname + ':8081';
            
            log.textContent = 'Connecting to ' + wsUrl + '...\n';
            status.textContent = 'Connecting...';
            status.className = 'status pending';
            
            try {
                ws = new WebSocket(wsUrl);
                
                ws.onopen = () => {
                    log.textContent += 'Connected!\n';
                    status.textContent = 'Connected';
                    status.className = 'status ok';
                    document.getElementById('ws-connect').disabled = true;
                    document.getElementById('ws-disconnect').disabled = false;
                    document.getElementById('ws-message').disabled = false;
                    document.getElementById('ws-send').disabled = false;
                };
                
                ws.onmessage = (e) => {
                    log.textContent += 'Received: ' + e.data + '\n';
                    log.scrollTop = log.scrollHeight;
                };
                
                ws.onclose = () => {
                    log.textContent += 'Disconnected\n';
                    status.textContent = 'Disconnected';
                    status.className = 'status pending';
                    document.getElementById('ws-connect').disabled = false;
                    document.getElementById('ws-disconnect').disabled = true;
                    document.getElementById('ws-message').disabled = true;
                    document.getElementById('ws-send').disabled = true;
                };
                
                ws.onerror = (e) => {
                    log.textContent += 'Error: Connection failed\n';
                    log.textContent += 'Make sure WebSocket server is running on port 8081\n';
                    status.textContent = 'Error';
                    status.className = 'status error';
                };
            } catch (e) {
                log.textContent += 'Error: ' + e.message + '\n';
                status.className = 'status error';
            }
        }
        
        function disconnectWs() {
            if (ws) ws.close();
        }
        
        function sendWsMessage() {
            const msg = document.getElementById('ws-message').value;
            if (ws && msg) {
                ws.send(msg);
                document.getElementById('ws-log').textContent += 'Sent: ' + msg + '\n';
                document.getElementById('ws-message').value = '';
            }
        }

        // SSE Test (via Node.js /events endpoint)
        function testSSE() {
            const log = document.getElementById('sse-log');
            const status = document.getElementById('sse-status');
            
            log.textContent = 'Connecting to /events...\n';
            status.textContent = 'Connecting...';
            status.className = 'status pending';
            
            try {
                sse = new EventSource('/events');
                
                sse.onopen = () => {
                    log.textContent += 'Connected!\n';
                    status.textContent = 'Connected';
                    status.className = 'status ok';
                    document.getElementById('sse-connect').disabled = true;
                    document.getElementById('sse-disconnect').disabled = false;
                };
                
                sse.onmessage = (e) => {
                    log.textContent += 'Event: ' + e.data + '\n';
                    log.scrollTop = log.scrollHeight;
                };
                
                sse.onerror = () => {
                    log.textContent += 'Error or disconnected\n';
                    status.textContent = 'Error';
                    status.className = 'status error';
                };
            } catch (e) {
                log.textContent += 'Error: ' + e.message + '\n';
            }
        }
        
        function disconnectSSE() {
            if (sse) {
                sse.close();
                document.getElementById('sse-log').textContent += 'Closed\n';
                document.getElementById('sse-status').textContent = 'Disconnected';
                document.getElementById('sse-status').className = 'status pending';
                document.getElementById('sse-connect').disabled = false;
                document.getElementById('sse-disconnect').disabled = true;
            }
        }

        // Push Stream SSE Test
        function testPushSSE() {
            const log = document.getElementById('push-log');
            const status = document.getElementById('push-status');
            const channel = document.getElementById('push-channel').value || 'test';
            const url = '/sse/sub?channel=' + channel;
            
            log.textContent = 'Subscribing to channel: ' + channel + '\n';
            status.textContent = 'Connecting...';
            status.className = 'status pending';
            
            try {
                pushSSE = new EventSource(url);
                
                pushSSE.onopen = () => {
                    log.textContent += 'Subscribed!\n';
                    status.textContent = 'Subscribed to: ' + channel;
                    status.className = 'status ok';
                };
                
                pushSSE.onmessage = (e) => {
                    log.textContent += 'Message: ' + e.data + '\n';
                    log.scrollTop = log.scrollHeight;
                };
                
                pushSSE.onerror = () => {
                    log.textContent += 'Error or disconnected\n';
                    status.className = 'status error';
                };
            } catch (e) {
                log.textContent += 'Error: ' + e.message + '\n';
            }
        }
        
        function publishPushSSE() {
            const channel = document.getElementById('push-channel').value || 'test';
            const log = document.getElementById('push-log');
            const message = 'Hello at ' + new Date().toLocaleTimeString();
            
            fetch('/sse/pub?channel=' + channel, {
                method: 'POST',
                body: message
            })
            .then(r => r.text())
            .then(text => {
                log.textContent += 'Published: ' + message + '\n';
            })
            .catch(e => {
                log.textContent += 'Publish error: ' + e.message + '\n';
                log.textContent += '(Note: Publishing may only work from localhost)\n';
            });
        }

        // API Test
        function testAPI() {
            const log = document.getElementById('api-log');
            const status = document.getElementById('api-status');
            
            log.textContent = 'Testing /api/test...\n';
            
            fetch('/api/test')
                .then(r => r.json())
                .then(data => {
                    log.textContent += 'Response:\n' + JSON.stringify(data, null, 2);
                    status.textContent = 'API Working!';
                    status.className = 'status ok';
                })
                .catch(e => {
                    log.textContent += 'Error: ' + e.message + '\n';
                    log.textContent += 'Make sure Node.js app is running';
                    status.textContent = 'Error';
                    status.className = 'status error';
                });
        }

        // PHP Test
        function testPHP() {
            const log = document.getElementById('php-log');
            const status = document.getElementById('php-status');
            
            log.textContent = 'Testing PHP...\n';
            
            fetch('/index.php')
                .then(r => r.text())
                .then(text => {
                    if (text.includes('PHP') || text.includes('php')) {
                        log.textContent += 'PHP is working!\n';
                        log.textContent += 'Response preview:\n' + text.substring(0, 500);
                        status.textContent = 'PHP Working!';
                        status.className = 'status ok';
                    } else {
                        log.textContent += 'Unexpected response';
                        status.className = 'status error';
                    }
                })
                .catch(e => {
                    log.textContent += 'Error: ' + e.message;
                    status.textContent = 'Error';
                    status.className = 'status error';
                });
        }
    </script>
</body>
</html>