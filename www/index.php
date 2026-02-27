<?php
echo "<h1>🚀 PHP " . phpversion() . " Working!</h1>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Extensions: " . count(get_loaded_extensions()) . " loaded</p>";

$extensions = ['redis', 'memcached', 'curl', 'openssl', 'mbstring', 'gd', 'zip'];
echo "<h3>Key Extensions:</h3><ul>";
foreach ($extensions as $ext) {
    $status = extension_loaded($ext) ? '✓' : '✗';
    echo "<li>$status $ext</li>";
}
echo "</ul>";

echo "<p><a href='phpinfo.php'>Full PHP Info</a> | <a href='phpmyadmin/'>phpMyAdmin</a></p>";
