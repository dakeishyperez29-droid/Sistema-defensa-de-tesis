-- ============================================================
-- SCRIPT COMPLETO: ESTRUCTURA DE BASE DE DATOS
-- Sistema de Ventas - sistema_admin
-- Compatible con phpMyAdmin
-- ============================================================

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS sistema_admin CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE sistema_admin;

-- ============================================================
-- TABLA 1: usuarios
-- ============================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id INT(11) NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) DEFAULT NULL,
    direccion VARCHAR(255) DEFAULT NULL,
    telefono VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY username (username),
    UNIQUE KEY email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 2: clientes
-- ============================================================

CREATE TABLE IF NOT EXISTS clientes (
    id INT(11) NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    identificacion VARCHAR(20) NOT NULL,
    direccion TEXT DEFAULT NULL,
    telefono VARCHAR(20) DEFAULT NULL,
    email VARCHAR(255) DEFAULT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY identificacion (identificacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 3: productos
-- ============================================================

CREATE TABLE IF NOT EXISTS productos (
    id INT(11) NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) DEFAULT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT(11) DEFAULT 0,
    stock_minimo INT(11) DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 4: metodo_pago
-- ============================================================

CREATE TABLE IF NOT EXISTS metodo_pago (
    id INT(11) NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    requiere_referencia TINYINT(1) DEFAULT 0 COMMENT '1 si requiere número de referencia, 0 si no',
    PRIMARY KEY (id),
    UNIQUE KEY nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 5: ventas
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas (
    id INT(11) NOT NULL AUTO_INCREMENT,
    cliente_id INT(11) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_dolares DECIMAL(10,2) NOT NULL,
    total_bs DECIMAL(10,2) NOT NULL,
    numero_factura VARCHAR(30) NOT NULL,
    numero_control VARCHAR(30) NOT NULL,
    metodo_pago_id INT(11) NOT NULL,
    numero_referencia VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY cliente_id (cliente_id),
    KEY metodo_pago_id (metodo_pago_id),
    CONSTRAINT ventas_ibfk_1 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    CONSTRAINT ventas_ibfk_2 FOREIGN KEY (metodo_pago_id) REFERENCES metodo_pago(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 6: detalles_venta
-- ============================================================

CREATE TABLE IF NOT EXISTS detalles_venta (
    id INT(11) NOT NULL AUTO_INCREMENT,
    venta_id INT(11) NOT NULL,
    producto_id INT(11) NOT NULL,
    cantidad INT(3) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    descuento TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si se aplicó descuento del 10%, 0 si no',
    PRIMARY KEY (id),
    KEY venta_id (venta_id),
    KEY producto_id (producto_id),
    CONSTRAINT detalles_venta_ibfk_1 FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    CONSTRAINT detalles_venta_ibfk_2 FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLA 7: tasa_diaria
-- ============================================================

CREATE TABLE IF NOT EXISTS tasa_diaria (
    id INT(11) NOT NULL AUTO_INCREMENT,
    fecha DATE NOT NULL,
    tasa DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TRIGGER: Descontar stock al registrar venta
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS after_detalle_venta_insert$$

CREATE TRIGGER after_detalle_venta_insert
AFTER INSERT ON detalles_venta
FOR EACH ROW
BEGIN
    -- Descontar stock del producto
    UPDATE productos 
    SET stock = stock - NEW.cantidad 
    WHERE id = NEW.producto_id;
END$$

DELIMITER ;

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Insertar usuarios
-- Contraseña para todos: admin123
INSERT INTO usuarios (id, username, password, nombre, email, direccion, telefono) VALUES
(1, 'admin', '$2y$10$atDIOJWUJ0rO7WUOcW7OheWyTVCiseZVGZEGdHeeFT6e9xLRoZM8C', 'Dakeishy Hung', 'dakeishy.hung@sistema.com', 'Caracas, Venezuela', '+58 212 1234567'),
(2, 'vendedor1', '$2y$10$igxdmn9re44UJqEsejpOD.099rMTVson3QxuKZpXTDhQhvCvStUEK', 'Juan Pérez', 'juan.perez@sistema.com', 'Valencia, Venezuela', '+58 241 9876543'),
(3, 'vendedor2', '$2y$10$OoGfNXuf2gooWbBHTQMMrOIF9jClzmBl9Ew5r.zxqSiEvyv23SYzi', 'María González', 'maria.gonzalez@sistema.com', 'Maracaibo, Venezuela', '+58 261 5551234'),
(4, 'vendedor3', '$2y$10$atDIOJWUJ0rO7WUOcW7OheWyTVCiseZVGZEGdHeeFT6e9xLRoZM8C', 'Carlos Ramírez', 'carlos.ramirez@sistema.com', 'Barquisimeto, Venezuela', '+58 251 6667788'),
(5, 'vendedor4', '$2y$10$atDIOJWUJ0rO7WUOcW7OheWyTVCiseZVGZEGdHeeFT6e9xLRoZM8C', 'Laura Torres', 'laura.torres@sistema.com', 'Mérida, Venezuela', '+58 274 7778899');

-- Insertar clientes
INSERT INTO clientes (id, nombre, identificacion, direccion, telefono, email, creado_en) VALUES
(1, 'Carlos Rodríguez', 'V-12345678', 'Av. Bolívar, Caracas', '+58 412 1234567', 'carlos.rodriguez@email.com', '2025-01-15 10:30:00'),
(2, 'Ana Martínez', 'V-87654321', 'Calle 5, Valencia', '+58 414 2223344', 'ana.martinez@email.com', '2025-01-16 14:20:00'),
(3, 'Luis Fernández', 'V-11223344', 'Av. Libertador, Maracaibo', '+58 416 3334455', 'luis.fernandez@email.com', '2025-01-17 09:15:00'),
(4, 'Sofía Herrera', 'V-55667788', 'Calle Principal, Barquisimeto', '+58 424 4445566', 'sofia.herrera@email.com', '2025-01-18 16:45:00'),
(5, 'Pedro Sánchez', 'V-99887766', 'Av. Universidad, Mérida', NULL, 'pedro.sanchez@email.com', '2025-01-19 11:00:00'),
(6, 'María López', 'V-22334455', 'Av. Francisco de Miranda, Caracas', '+58 414 5556677', 'maria.lopez@email.com', '2025-01-20 08:00:00'),
(7, 'José González', 'V-33445566', 'Calle 72, Maracaibo', '+58 416 6667788', 'jose.gonzalez@email.com', '2025-01-21 15:30:00'),
(8, 'Carmen Silva', 'V-44556677', 'Av. Las Delicias, Valencia', '+58 424 7778899', 'carmen.silva@email.com', '2025-01-22 10:15:00'),
(9, 'Roberto Díaz', 'V-77889900', 'Calle 15, Barquisimeto', '+58 251 8889900', 'roberto.diaz@email.com', '2025-01-23 12:45:00'),
(10, 'Patricia Morales', 'V-66778899', 'Av. 5 de Julio, Puerto La Cruz', '+58 281 9990011', 'patricia.morales@email.com', '2025-01-24 09:20:00');

-- Insertar productos
-- NOTA: Los stocks iniciales incluyen las unidades que se venderán en las ventas de ejemplo
-- El trigger descontará automáticamente el stock al insertar los detalles_venta
INSERT INTO productos (id, nombre, descripcion, precio, stock, stock_minimo) VALUES
(1, 'Nike Air Max 90', 'Zapatillas deportivas clásicas', 120.00, 27, 5),  -- Vendido: 2 unidades
(2, 'Adidas Ultraboost 23', 'Running de alto rendimiento', 150.00, 20, 5),  -- Vendido: 2 unidades
(3, 'Puma Suede Classic', 'Estilo retro y comodidad', 80.00, 33, 5),  -- Vendido: 3 unidades (2 en venta 11)
(4, 'Reebok Club C 85', 'Tenis vintage', 90.00, 23, 5),  -- Vendido: 1 unidad
(5, 'Nike Air Force 1', 'Clásico atemporal', 100.00, 16, 5),  -- Vendido: 1 unidad
(6, 'Adidas Stan Smith', 'Clásico de la cancha', 85.00, 21, 5),  -- Vendido: 1 unidad
(7, 'Converse Chuck Taylor', 'Icono del streetwear', 70.00, 30, 5),  -- Vendido: 2 unidades
(8, 'Vans Old Skool', 'Estilo skater', 75.00, 25, 5),  -- Vendido: 1 unidad
(9, 'New Balance 574', 'Comodidad y estilo', 95.00, 20, 5),  -- Vendido: 1 unidad
(10, 'Jordan 1 Retro', 'Básquetbol premium', 180.00, 13, 5),  -- Vendido: 1 unidad
(11, 'Nike Dunk Low', 'Zapatillas urbanas', 110.00, 22, 5),  -- Vendido: 2 unidades
(12, 'Adidas Samba', 'Clásico futbolístico', 90.00, 26, 5),  -- Vendido: 1 unidad
(13, 'Puma RS-X', 'Diseño futurista', 130.00, 16, 5),  -- Vendido: 1 unidad
(14, 'Reebok Classic Leather', 'Estilo casual', 85.00, 23, 5),  -- Vendido: 1 unidad
(15, 'Nike Blazer Mid', 'Retro basketball', 95.00, 20, 5),  -- Vendido: 2 unidades
(16, 'Adidas Gazelle', 'Icono de los 90s', 100.00, 21, 5),  -- Vendido: 1 unidad
(17, 'Vans Authentic', 'Skateboarding clásico', 65.00, 31, 5),  -- Vendido: 1 unidad
(18, 'Converse One Star', 'Estilo minimalista', 75.00, 26, 5),  -- Vendido: 1 unidad
(19, 'New Balance 550', 'Basketball retro', 120.00, 17, 5),  -- Vendido: 1 unidad
(20, 'Jordan 4 Retro', 'Básquetbol premium', 200.00, 11, 5);  -- Vendido: 1 unidad

-- Insertar métodos de pago
INSERT INTO metodo_pago (id, nombre, requiere_referencia) VALUES
(1, 'Efectivo', 0),
(2, 'Pago Móvil', 1),
(3, 'Transferencia Bancaria', 1),
(4, 'Zelle', 1),
(5, 'PayPal', 1);

-- Insertar tasa diaria
INSERT INTO tasa_diaria (id, fecha, tasa, descripcion) VALUES
(1, '2025-01-15', 36.50, 'Tasa oficial BCV'),
(2, '2025-01-16', 36.75, 'Tasa oficial BCV'),
(3, '2025-01-17', 37.00, 'Tasa oficial BCV'),
(4, '2025-01-18', 37.25, 'Tasa oficial BCV'),
(5, '2025-01-19', 37.50, 'Tasa oficial BCV'),
(6, '2025-01-20', 37.75, 'Tasa oficial BCV'),
(7, '2025-01-21', 38.00, 'Tasa oficial BCV'),
(8, '2025-01-22', 38.25, 'Tasa oficial BCV'),
(9, '2025-01-23', 38.50, 'Tasa oficial BCV'),
(10, '2025-01-24', 38.75, 'Tasa oficial BCV'),
(11, CURDATE(), 39.00, 'Tasa del día actual');

-- Insertar ventas
INSERT INTO ventas (id, cliente_id, fecha, total_dolares, total_bs, numero_factura, numero_control, metodo_pago_id, numero_referencia) VALUES
(1, 1, '2025-01-15 10:45:00', 200.00, 7300.00, '0000001', '00-0000001', 1, NULL),
(2, 2, '2025-01-16 14:30:00', 150.00, 5512.50, '0000002', '00-0000002', 2, 'PM-1234567890'),
(3, 3, '2025-01-17 09:20:00', 280.00, 10360.00, '0000003', '00-0000003', 3, 'TRF-9876543210'),
(4, 1, '2025-01-18 16:15:00', 95.00, 3538.75, '0000004', '00-0000004', 1, NULL),
(5, 4, '2025-01-19 11:30:00', 180.00, 6750.00, '0000005', '00-0000005', 2, 'PM-1122334455'),
(6, 5, '2025-01-20 08:45:00', 250.00, 9437.50, '0000006', '00-0000006', 4, 'ZELLE-5566778899'),
(7, 6, '2025-01-21 13:20:00', 165.00, 6270.00, '0000007', '00-0000007', 1, NULL),
(8, 7, '2025-01-22 15:10:00', 320.00, 12240.00, '0000008', '00-0000008', 3, 'TRF-2233445566'),
(9, 8, '2025-01-23 10:30:00', 140.00, 5390.00, '0000009', '00-0000009', 2, 'PM-3344556677'),
(10, 9, '2025-01-24 12:00:00', 195.00, 7571.25, '0000010', '00-0000010', 1, NULL),
(11, 10, '2025-01-24 16:45:00', 275.00, 10725.00, '0000011', '00-0000011', 5, 'PAYPAL-4455667788'),
(12, 2, '2025-01-24 17:30:00', 110.00, 4290.00, '0000012', '00-0000012', 2, 'PM-6677889900');

-- Insertar detalles de venta
INSERT INTO detalles_venta (id, venta_id, producto_id, cantidad, precio_unitario, subtotal, descuento) VALUES
-- Venta 1: Cliente 1 - 2 productos
(1, 1, 1, 1, 120.00, 120.00, 0),
(2, 1, 3, 1, 80.00, 80.00, 0),
-- Venta 2: Cliente 2 - 1 producto
(3, 2, 2, 1, 150.00, 150.00, 0),
-- Venta 3: Cliente 3 - 3 productos (uno con descuento)
(4, 3, 10, 1, 180.00, 180.00, 0),
(5, 3, 4, 1, 90.00, 90.00, 0),
(6, 3, 6, 1, 85.00, 76.50, 1),
-- Venta 4: Cliente 1 - 1 producto con descuento
(7, 4, 5, 1, 100.00, 90.00, 1),
-- Venta 5: Cliente 4 - 2 productos
(8, 5, 2, 1, 150.00, 150.00, 0),
(9, 5, 7, 1, 70.00, 63.00, 1),
-- Venta 6: Cliente 5 - 3 productos
(10, 6, 11, 1, 110.00, 110.00, 0),
(11, 6, 12, 1, 90.00, 90.00, 0),
(12, 6, 8, 1, 75.00, 67.50, 1),
-- Venta 7: Cliente 6 - 2 productos
(13, 7, 13, 1, 130.00, 130.00, 0),
(14, 7, 14, 1, 85.00, 76.50, 1),
-- Venta 8: Cliente 7 - 3 productos
(15, 8, 15, 2, 95.00, 190.00, 0),
(16, 8, 16, 1, 100.00, 100.00, 0),
(17, 8, 17, 1, 65.00, 58.50, 1),
-- Venta 9: Cliente 8 - 2 productos
(18, 9, 18, 1, 75.00, 75.00, 0),
(19, 9, 19, 1, 120.00, 108.00, 1),
-- Venta 10: Cliente 9 - 2 productos
(20, 10, 20, 1, 200.00, 180.00, 1),
(21, 10, 1, 1, 120.00, 108.00, 1),
-- Venta 11: Cliente 10 - 3 productos
(22, 11, 3, 2, 80.00, 160.00, 0),
(23, 11, 9, 1, 95.00, 95.00, 0),
(24, 11, 7, 1, 70.00, 63.00, 1),
-- Venta 12: Cliente 2 - 1 producto
(25, 12, 11, 1, 110.00, 110.00, 0);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================

