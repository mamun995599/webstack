<?php
$phpVersion = phpversion();
$extensionCount = count(get_loaded_extensions());
$serverTime = date('Y-m-d H:i:s');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP Test - WebStack</title>
    <style>
        body { font-family: -apple-system, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 8px; margin: 15px 0; }
        .extensions { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 10px; }
        .ext { padding: 8px; background: #f5f5f5; border-radius: 4px; text-align: center; }
        .ext.loaded { background: #d4edda; color: #155724; }
        .ext.missing { background: #f8d7da; color: #721c24; }
        .links a { display: inline-block; margin: 5px 10px 5px 0; padding: 8px 16px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>? PHP <?php echo $phpVersion; ?> Working!</h1>
    
    <div class="info">
        <p><strong>Server Time:</strong> <?php echo $serverTime; ?></p>
        <p><strong>Extensions Loaded:</strong> <?php echo $extensionCount; ?></p>
        <p><strong>Memory Limit:</strong> <?php echo ini_get('memory_limit'); ?></p>
        <p><strong>Max Execution Time:</strong> <?php echo ini_get('max_execution_time'); ?>s</p>
    </div>
    
    <h3>Key Extensions</h3>
    <div class="extensions">
        <?php
        $keyExtensions = ['redis', 'memcached', 'curl', 'openssl', 'mbstring', 'gd', 'zip', 'pdo_mysql', 'mysqli', 'json', 'xml', 'opcache', 'intl', 'sodium'];
        foreach ($keyExtensions as $ext):
            $loaded = extension_loaded($ext);
            $class = $loaded ? 'loaded' : 'missing';
            $status = $loaded ? '?' : '?';
        ?>
        <div class="ext <?php echo $class; ?>"><?php echo $status; ?> <?php echo $ext; ?></div>
        <?php endforeach; ?>
    </div>
    
    <h3>Links</h3>
    <div class="links">
        <a href="phpinfo.php">Full PHP Info</a>
        <a href="test_cache.php">Cache Test</a>
        <a href="phpmyadmin/">phpMyAdmin</a>
        <a href="/">Home</a>
    </div>
</body>
</html>
