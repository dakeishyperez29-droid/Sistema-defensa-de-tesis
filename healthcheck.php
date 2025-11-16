<?php
// Healthcheck endpoint - no requiere base de datos
// Este archivo se usa para verificar que la aplicación está funcionando

http_response_code(200);
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'service' => 'sistema-compras',
    'timestamp' => date('Y-m-d H:i:s')
]);

