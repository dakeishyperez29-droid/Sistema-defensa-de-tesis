<?php
// Iniciar buffer de salida para evitar que se envíen headers antes de tiempo
ob_start();

require_once __DIR__ . '/../../includes/config.php';

// Iniciar sesión si no está iniciada
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Destruir todas las variables de sesión
$_SESSION = array();

// Borrar la cookie de sesión
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(), 
        '', 
        time() - 42000,
        $params["path"], 
        $params["domain"],
        $params["secure"], 
        $params["httponly"]
    );
}

// Destruir la sesión solo si está iniciada
if (session_status() === PHP_SESSION_ACTIVE) {
    session_destroy();
}

// Limpiar el buffer de salida
ob_end_clean();

// Headers para prevenir cache
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
header("Expires: Thu, 19 Nov 1981 08:52:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");

// Redireccionar a login
header("Location: " . BASE_URL . "/");

// Asegurarse que el script termine
exit();
?>