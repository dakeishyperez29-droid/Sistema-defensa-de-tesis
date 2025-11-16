<?php
// Configuración de base de datos - usa variables de entorno si están disponibles (Docker)
// o valores por defecto para desarrollo local
$host = getenv('DB_HOST') ?: "localhost";
$dbname = getenv('DB_NAME') ?: "sistema_compras_zapatos";
$user = getenv('DB_USER') ?: "root";
$pass = getenv('DB_PASS') ?: "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error de conexión: " . $e->getMessage());
}
?>