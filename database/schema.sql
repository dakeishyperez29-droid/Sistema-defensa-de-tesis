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
INSERT INTO usuarios (id, username, password, nombre, email, direccion, telefono) VALUES
(1, 'admin', '$2y$10$atDIOJWUJ0rO7WUOcW7OheWyTVCiseZVGZEGdHeeFT6e9xLRoZM8C', 'Administrador Sistema', 'admin@sistema.com', 'Caracas, Venezuela', '+58 212 1234567'),
(2, 'vendedor1', '$2y$10$igxdmn9re44UJqEsejpOD.099rMTVson3QxuKZpXTDhQhvCvStUEK', 'Juan Pérez', 'juan.perez@sistema.com', 'Valencia, Venezuela', '+58 241 9876543'),
(3, 'vendedor2', '$2y$10$OoGfNXuf2gooWbBHTQMMrOIF9jClzmBl9Ew5r.zxqSiEvyv23SYzi', 'María González', 'maria.gonzalez@sistema.com', 'Maracaibo, Venezuela', '+58 261 5551234');

-- Insertar clientes
INSERT INTO clientes (id, nombre, identificacion, direccion, telefono, email, creado_en) VALUES
(1, 'Carlos Rodríguez', 'V-12345678', 'Av. Bolívar, Caracas', '+58 412 1234567', 'carlos.rodriguez@email.com', '2025-01-15 10:30:00'),
(2, 'Ana Martínez', 'V-87654321', 'Calle 5, Valencia', '+58 414 2223344', 'ana.martinez@email.com', '2025-01-16 14:20:00'),
(3, 'Luis Fernández', 'V-11223344', 'Av. Libertador, Maracaibo', '+58 416 3334455', 'luis.fernandez@email.com', '2025-01-17 09:15:00'),
(4, 'Sofía Herrera', 'V-55667788', 'Calle Principal, Barquisimeto', '+58 424 4445566', 'sofia.herrera@email.com', '2025-01-18 16:45:00'),
(5, 'Pedro Sánchez', 'V-99887766', 'Av. Universidad, Mérida', NULL, 'pedro.sanchez@email.com', '2025-01-19 11:00:00');

-- Insertar productos
INSERT INTO productos (id, nombre, descripcion, precio, stock, stock_minimo) VALUES
(1, 'Nike Air Max 90', 'Zapatillas deportivas clásicas', 120.00, 25, 5),
(2, 'Adidas Ultraboost 23', 'Running de alto rendimiento', 150.00, 18, 5),
(3, 'Puma Suede Classic', 'Estilo retro y comodidad', 80.00, 30, 5),
(4, 'Reebok Club C 85', 'Tenis vintage', 90.00, 22, 5),
(5, 'Nike Air Force 1', 'Clásico atemporal', 100.00, 15, 5),
(6, 'Adidas Stan Smith', 'Clásico de la cancha', 85.00, 20, 5),
(7, 'Converse Chuck Taylor', 'Icono del streetwear', 70.00, 28, 5),
(8, 'Vans Old Skool', 'Estilo skater', 75.00, 24, 5),
(9, 'New Balance 574', 'Comodidad y estilo', 95.00, 19, 5),
(10, 'Jordan 1 Retro', 'Básquetbol premium', 180.00, 12, 5);

-- Insertar métodos de pago
INSERT INTO metodo_pago (id, nombre, requiere_referencia) VALUES
(1, 'Efectivo', 0),
(2, 'Pago Móvil', 1),
(3, 'Transferencia Bancaria', 1),
(4, 'Zelle', 1),
(5, 'PayPal', 1);

-- Insertar tasa diaria
INSERT INTO tasa_diaria (id, fecha, tasa, descripcion) VALUES
(1, '2025-01-20', 36.50, 'Tasa oficial del día');

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================

