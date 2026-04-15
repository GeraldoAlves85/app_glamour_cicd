DROP DATABASE IF EXISTS catalog_db;
CREATE DATABASE catalog_db;
USE catalog_db;

-- Categorias
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Produtos
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    short_description VARCHAR(500),
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    compare_at_price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    sku VARCHAR(100),
    brand VARCHAR(100),
    category_id INT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    sales_count INT DEFAULT 0,
    rating_average DECIMAL(3,2) DEFAULT 0,
    rating_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inserir categorias PRIMEIRO
INSERT INTO categories (id, name, slug, display_order) VALUES
(1, 'Batom', 'batom', 1),
(2, 'Base', 'base', 2),
(3, 'Sombra', 'sombra', 3),
(4, 'Blush', 'blush', 4),
(5, 'Pó', 'po', 5),
(6, 'Delineador', 'delineador', 6),
(7, 'Máscara', 'mascara', 7),
(8, 'Corretivo', 'corretivo', 8),
(9, 'Iluminador', 'iluminador', 9),
(10, 'Primer', 'primer', 10),
(11, 'Fixador', 'fixador', 11);

-- Inserir produtos DEPOIS
INSERT INTO products (name, slug, price, compare_at_price, stock_quantity, brand, category_id, is_featured) VALUES
('Batom Matte Ruby', 'batom-matte-ruby', 29.90, 39.90, 150, 'Ruby Rose', 1, TRUE),
('Base Líquida Boca Rosa', 'base-boca-rosa', 89.90, 119.90, 75, 'Boca Rosa', 2, TRUE),
('Paleta Nude Mari Maria', 'paleta-nude-mari', 129.90, 159.90, 50, 'Mari Maria', 3, TRUE),
('Blush Francisca', 'blush-francisca', 49.90, NULL, 200, 'Francisca', 4, FALSE),
('Pó Compacto Vult', 'po-compacto-vult', 39.90, 49.90, 180, 'Vult', 5, TRUE),
('Delineador Boticário', 'delineador-boticario', 34.90, NULL, 120, 'O Boticário', 6, FALSE),
('Máscara Maybelline', 'mascara-maybelline', 44.90, 59.90, 90, 'Maybelline', 7, TRUE),
('Corretivo Natura', 'corretivo-natura', 39.90, 49.90, 110, 'Natura', 8, FALSE),
('Iluminador Dior', 'iluminador-dior', 159.90, 189.90, 45, 'Dior', 9, TRUE),
('Primer Benefit', 'primer-benefit', 199.90, 229.90, 60, 'Benefit', 10, TRUE),
('Spray Urban Decay', 'spray-urban', 149.90, 179.90, 70, 'Urban Decay', 11, TRUE),
('Batom Dior Rouge', 'batom-dior-rouge', 199.90, 249.90, 45, 'Dior', 1, TRUE);
