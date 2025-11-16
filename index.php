<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once __DIR__ . '/src/includes/config.php';

// Si ya está autenticado, redirigir al dashboard
if (isset($_SESSION['usuario_id'])) {
    header("Location: " . PAGES_URL . "/index.php");
    exit();
}

// Si no está autenticado, mostrar el login
// Manejar errores de conexión a BD de forma elegante
try {
    include __DIR__ . '/src/pages/auth/login.php';
} catch (Exception $e) {
    // Si hay error de conexión, mostrar página de error
    http_response_code(503);
    ?>
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Error de Conexión</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background: #f5f5f5;
            }
            .error-container {
                text-align: center;
                padding: 2rem;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1 { color: #dc3545; }
        </style>
    </head>
    <body>
        <div class="error-container">
            <h1>⚠️ Error de Conexión</h1>
            <p>No se puede conectar a la base de datos.</p>
            <p>Por favor, verifica la configuración e intenta nuevamente.</p>
        </div>
    </body>
    </html>
    <?php
    exit();
}
?>

