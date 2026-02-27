<?php
echo "<h1>Memcached Test</h1>\n";

// Check extension
if (!extension_loaded('memcached')) {
    die("Memcached extension not loaded!");
}
echo "<p>✓ Memcached extension loaded</p>\n";

try {
    // Connect
    $memcached = new Memcached();
    $memcached->addServer('127.0.0.1', 11211);
    
    // Check connection
    $stats = $memcached->getStats();
    if (empty($stats)) {
        die("<p style='color: red;'>Cannot connect to Memcached server</p>");
    }
    echo "<p>✓ Connected to Memcached server</p>\n";
    
    // Test set/get
    $memcached->set('php_test', 'Hello from PHP at ' . date('Y-m-d H:i:s'), 3600);
    $value = $memcached->get('php_test');
    echo "<p>✓ SET/GET: $value</p>\n";
    
    // Test with array
    $memcached->set('user_data', ['name' => 'John', 'email' => 'john@example.com'], 3600);
    $userData = $memcached->get('user_data');
    echo "<p>✓ Array: " . print_r($userData, true) . "</p>\n";
    
    // Test increment
    $memcached->set('visits', 0);
    $memcached->increment('visits');
    $memcached->increment('visits');
    $memcached->increment('visits');
    echo "<p>✓ Counter: " . $memcached->get('visits') . "</p>\n";
    
    // Stats
    $server = array_values($stats)[0];
    echo "<p>✓ Version: " . $server['version'] . "</p>\n";
    echo "<p>✓ Uptime: " . $server['uptime'] . " seconds</p>\n";
    echo "<p>✓ Current items: " . $server['curr_items'] . "</p>\n";
    
    echo "<h2 style='color: green;'>Memcached is working!</h2>\n";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>Error: " . $e->getMessage() . "</p>\n";
}
