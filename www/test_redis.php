
<?php
echo "<h1>Redis Test</h1>\n";

// Check extension
if (!extension_loaded('redis')) {
    die("Redis extension not loaded!");
}
echo "<p>✓ Redis extension loaded</p>\n";

try {
    // Connect
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379);
    echo "<p>✓ Connected to Redis server</p>\n";
    
    // Test ping
    $pong = $redis->ping();
    echo "<p>✓ PING: " . ($pong ? "PONG" : "Failed") . "</p>\n";
    
    // Test set/get
    $redis->set('php_test', 'Hello from PHP at ' . date('Y-m-d H:i:s'));
    $value = $redis->get('php_test');
    echo "<p>✓ SET/GET: $value</p>\n";
    
    // Test increment
    $redis->set('counter', 0);
    $redis->incr('counter');
    $redis->incr('counter');
    $redis->incr('counter');
    echo "<p>✓ Counter: " . $redis->get('counter') . "</p>\n";
    
    // Test hash
    $redis->hSet('user:1', 'name', 'John');
    $redis->hSet('user:1', 'email', 'john@example.com');
    $user = $redis->hGetAll('user:1');
    echo "<p>✓ Hash: " . print_r($user, true) . "</p>\n";
    
    // Test list
    $redis->del('mylist');
    $redis->rPush('mylist', 'item1', 'item2', 'item3');
    $list = $redis->lRange('mylist', 0, -1);
    echo "<p>✓ List: " . implode(', ', $list) . "</p>\n";
    
    // Info
    $info = $redis->info('server');
    echo "<p>✓ Redis Version: " . $info['redis_version'] . "</p>\n";
    
    echo "<h2 style='color: green;'>Redis is working!</h2>\n";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>Error: " . $e->getMessage() . "</p>\n";
}