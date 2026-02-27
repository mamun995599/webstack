<?php
$webstackRoot = getenv('WEBSTACK_ROOT') ?: dirname(__DIR__);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cache Test - WebStack</title>
    <style>
        body { font-family: -apple-system, sans-serif; max-width: 900px; margin: 50px auto; padding: 20px; background: #f5f5f5; }
        h1 { color: #333; text-align: center; }
        .card { background: white; border-radius: 8px; padding: 20px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h2 { margin-top: 0; padding-bottom: 10px; border-bottom: 2px solid #eee; }
        .success { color: #155724; }
        .error { color: #721c24; }
        .warning { color: #856404; }
        .status-box { padding: 10px 15px; border-radius: 5px; margin: 10px 0; }
        .status-box.ok { background: #d4edda; }
        .status-box.fail { background: #f8d7da; }
        .status-box.warn { background: #fff3cd; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; font-size: 13px; }
        .links { text-align: center; margin-top: 30px; }
        .links a { display: inline-block; margin: 5px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
        .links a:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>? WebStack Cache Test</h1>
    
    <!-- Redis Test -->
    <div class="card">
        <h2>Redis</h2>
        <?php
        if (!extension_loaded('redis')) {
            echo '<div class="status-box fail"><strong class="error">? Redis extension not loaded</strong></div>';
            echo '<p>Install with: <code>./install_redis_memcached.sh</code></p>';
        } else {
            echo '<div class="status-box ok"><strong class="success">? Redis extension loaded</strong></div>';
            
            try {
                $redis = new Redis();
                $connected = @$redis->connect('127.0.0.1', 6379, 2);
                
                if ($connected && $redis->ping()) {
                    echo '<div class="status-box ok"><strong class="success">? Connected to Redis server</strong></div>';
                    
                    // Test operations
                    $testKey = 'webstack_test_' . time();
                    $testValue = 'Hello from WebStack at ' . date('Y-m-d H:i:s');
                    
                    $redis->set($testKey, $testValue);
                    $retrieved = $redis->get($testKey);
                    $redis->del($testKey);
                    
                    if ($retrieved === $testValue) {
                        echo '<div class="status-box ok"><strong class="success">? Read/Write operations working</strong></div>';
                    }
                    
                    // Server info
                    $info = $redis->info('server');
                    $memory = $redis->info('memory');
                    $stats = $redis->info('stats');
                    
                    echo '<h4>Server Info:</h4>';
                    echo '<pre>';
                    echo "Version:     " . ($info['redis_version'] ?? 'N/A') . "\n";
                    echo "Memory Used: " . ($memory['used_memory_human'] ?? 'N/A') . "\n";
                    echo "Clients:     " . ($redis->info('clients')['connected_clients'] ?? 'N/A') . "\n";
                    echo "Total Cmds:  " . ($stats['total_commands_processed'] ?? 'N/A') . "\n";
                    echo "Uptime:      " . ($info['uptime_in_seconds'] ?? 'N/A') . " seconds\n";
                    echo '</pre>';
                    
                } else {
                    echo '<div class="status-box fail"><strong class="error">? Cannot connect to Redis server</strong></div>';
                    echo '<p>Start Redis: <code>./webstack redis start</code></p>';
                }
            } catch (Exception $e) {
                echo '<div class="status-box fail"><strong class="error">? Error: ' . htmlspecialchars($e->getMessage()) . '</strong></div>';
            }
        }
        ?>
    </div>
    
    <!-- Memcached Test -->
    <div class="card">
        <h2>Memcached</h2>
        <?php
        if (!extension_loaded('memcached')) {
            echo '<div class="status-box fail"><strong class="error">? Memcached extension not loaded</strong></div>';
            echo '<p>Install with: <code>./install_redis_memcached.sh</code></p>';
        } else {
            echo '<div class="status-box ok"><strong class="success">? Memcached extension loaded</strong></div>';
            
            try {
                $memcached = new Memcached();
                $memcached->addServer('127.0.0.1', 11211);
                
                $stats = $memcached->getStats();
                $serverKey = '127.0.0.1:11211';
                
                if (!empty($stats) && isset($stats[$serverKey]) && $stats[$serverKey]['pid'] > 0) {
                    echo '<div class="status-box ok"><strong class="success">? Connected to Memcached server</strong></div>';
                    
                    // Test operations
                    $testKey = 'webstack_test_' . time();
                    $testValue = 'Hello from WebStack at ' . date('Y-m-d H:i:s');
                    
                    $memcached->set($testKey, $testValue, 60);
                    $retrieved = $memcached->get($testKey);
                    $memcached->delete($testKey);
                    
                    if ($retrieved === $testValue) {
                        echo '<div class="status-box ok"><strong class="success">? Read/Write operations working</strong></div>';
                    }
                    
                    // Server info
                    $serverStats = $stats[$serverKey];
                    echo '<h4>Server Info:</h4>';
                    echo '<pre>';
                    echo "Version:      " . ($serverStats['version'] ?? 'N/A') . "\n";
                    echo "Memory Used:  " . round(($serverStats['bytes'] ?? 0) / 1024 / 1024, 2) . " MB\n";
                    echo "Memory Limit: " . round(($serverStats['limit_maxbytes'] ?? 0) / 1024 / 1024, 2) . " MB\n";
                    echo "Curr Items:   " . ($serverStats['curr_items'] ?? 'N/A') . "\n";
                    echo "Connections:  " . ($serverStats['curr_connections'] ?? 'N/A') . "\n";
                    echo "Get Hits:     " . ($serverStats['get_hits'] ?? 'N/A') . "\n";
                    echo "Get Misses:   " . ($serverStats['get_misses'] ?? 'N/A') . "\n";
                    echo "Uptime:       " . ($serverStats['uptime'] ?? 'N/A') . " seconds\n";
                    echo '</pre>';
                    
                } else {
                    echo '<div class="status-box fail"><strong class="error">? Cannot connect to Memcached server</strong></div>';
                    echo '<p>Start Memcached: <code>./webstack memcached start</code></p>';
                }
            } catch (Exception $e) {
                echo '<div class="status-box fail"><strong class="error">? Error: ' . htmlspecialchars($e->getMessage()) . '</strong></div>';
            }
        }
        ?>
    </div>
    
    <!-- PHP OPcache -->
    <div class="card">
        <h2>OPcache</h2>
        <?php
        if (!extension_loaded('Zend OPcache')) {
            echo '<div class="status-box warn"><strong class="warning">? OPcache not loaded</strong></div>';
        } else {
            $status = opcache_get_status(false);
            if ($status && $status['opcache_enabled']) {
                echo '<div class="status-box ok"><strong class="success">? OPcache enabled and running</strong></div>';
                
                echo '<h4>OPcache Info:</h4>';
                echo '<pre>';
                echo "Memory Used:  " . round($status['memory_usage']['used_memory'] / 1024 / 1024, 2) . " MB\n";
                echo "Memory Free:  " . round($status['memory_usage']['free_memory'] / 1024 / 1024, 2) . " MB\n";
                echo "Cached Files: " . $status['opcache_statistics']['num_cached_scripts'] . "\n";
                echo "Hit Rate:     " . round($status['opcache_statistics']['opcache_hit_rate'], 2) . "%\n";
                echo "JIT Enabled:  " . (isset($status['jit']['enabled']) && $status['jit']['enabled'] ? 'Yes' : 'No') . "\n";
                echo '</pre>';
            } else {
                echo '<div class="status-box warn"><strong class="warning">? OPcache installed but not enabled</strong></div>';
            }
        }
        ?>
    </div>
    
    <div class="links">
        <a href="/">Home</a>
        <a href="index.php">PHP Test</a>
        <a href="phpinfo.php">PHP Info</a>
    </div>
</body>
</html>
