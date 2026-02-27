<?php
$webstack_root = dirname(__DIR__);
$socket = $webstack_root . '/tmp/mysql.sock';

echo "<h1>🐬 MySQL Connection Test</h1>";
echo "<p><strong>Socket:</strong> <code>$socket</code></p>";

// Check socket exists
if (!file_exists($socket)) {
    echo "<p style='color:red'>❌ Socket not found! Is MySQL running?</p>";
    echo "<pre>Run: ./webstack start-mysql</pre>";
    exit;
}

// Test connection
try {
    $pdo = new PDO("mysql:unix_socket=$socket", 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    
    echo "<p style='color:green'>✅ Connected successfully!</p>";
    
    // Get version
    $version = $pdo->query("SELECT VERSION()")->fetchColumn();
    echo "<p><strong>MySQL Version:</strong> $version</p>";
    
    // List databases
    echo "<h2>Databases</h2>";
    echo "<ul>";
    $dbs = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
    foreach ($dbs as $db) {
        echo "<li>$db</li>";
    }
    echo "</ul>";
    
} catch (PDOException $e) {
    echo "<p style='color:red'>❌ Connection failed: " . $e->getMessage() . "</p>";
    echo "<p>If password is set, update the password in this test file.</p>";
}

echo "<hr>";
echo "<p><a href='/phpmyadmin'>Open phpMyAdmin</a></p>";
?>