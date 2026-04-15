-- =============================================
-- GLAMOUR E-COMMERCE - CATALOG DATABASE
-- =============================================
-- Este script é executado automaticamente na primeira
-- inicialização do container MySQL do catálogo
-- =============================================

-- Garante que o banco existe
CREATE DATABASE IF NOT EXISTS catalog_db;
USE catalog_db;

-- =============================================
-- TABELA: categories (Categorias de Produtos)
-- =============================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug),
    INDEX idx_active_order (is_active, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABELA: products (Produtos da Loja)
-- =============================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    price DECIMAL(10,2) NOT NULL,
    compare_at_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    stock_quantity INT NOT NULL DEFAULT 0,
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    brand VARCHAR(100),
    category_id INT,
    image_url VARCHAR(500),
    images JSON,
    video_url VARCHAR(500),
    weight_grams INT,
    dimensions VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_digital BOOLEAN DEFAULT FALSE,
    tags JSON,
    seo_title VARCHAR(255),
    seo_description TEXT,
    seo_keywords VARCHAR(500),
    view_count INT DEFAULT 0,
    sales_count INT DEFAULT 0,
    rating_average DECIMAL(3,2) DEFAULT 0,
    rating_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_slug (slug),
    INDEX idx_sku (sku),
    INDEX idx_category (category_id),
    INDEX idx_brand (brand),
    INDEX idx_active_featured (is_active, is_featured),
    INDEX idx_price (price),
    INDEX idx_search (name, description, brand)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABELA: product_variants (Variações como cor/tamanho)
-- =============================================
CREATE TABLE IF NOT EXISTS product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    price_adjustment DECIMAL(10,2) DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,
    attributes JSON,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_sku (sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABELA: inventory_log (Histórico de Estoque)
-- =============================================
CREATE TABLE IF NOT EXISTS inventory_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    variant_id INT NULL,
    quantity_change INT NOT NULL,
    reason VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
    INDEX idx_product (product_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INSERIR CATEGORIAS
-- =============================================
INSERT INTO categories (name, slug, description, display_order) VALUES
('Batom', 'batom', 'Batom líquido, matte, cremoso e muito mais para realçar seus lábios', 1),
('Base', 'base', 'Base líquida, em pó, stick e cushion para uma pele perfeita', 2),
('Sombra', 'sombra', 'Sombras unitárias e paletas para criar looks incríveis', 3),
('Blush', 'blush', 'Blush em pó, líquido e cremoso para um ar saudável', 4),
('Pó', 'po', 'Pó solto, compacto e translúcido para finalizar a make', 5),
('Delineador', 'delineador', 'Delineador líquido, caneta e gel para um olhar marcante', 6),
('Máscara', 'mascara', 'Máscara de cílios para volume, alongamento e curvatura', 7),
('Corretivo', 'corretivo', 'Corretivo líquido e em bastão para cobrir imperfeições', 8),
('Iluminador', 'iluminador', 'Iluminador em pó, líquido e cremoso para um glow radiante', 9),
('Primer', 'primer', 'Primer facial para preparar a pele antes da maquiagem', 10),
('Fixo', 'fixador', 'Spray fixador para prolongar a duração da maquiagem', 11)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    description = VALUES(description),
    display_order = VALUES(display_order);

-- =============================================
-- INSERIR PRODUTOS
-- =============================================
INSERT INTO products (
    name, slug, short_description, description, 
    price, compare_at_price, stock_quantity, sku, brand, 
    category_id, image_url, is_active, is_featured, rating_average, rating_count
) VALUES
(
    'Batom Matte Ruby Rose', 'batom-matte-ruby-rose', 
    'Batom de longa duração com acabamento matte aveludado',
    'O Batom Matte Ruby Rose oferece alta pigmentação e acabamento matte aveludado que dura por horas. Sua fórmula enriquecida com vitamina E e manteiga de karité hidrata os lábios enquanto proporciona cor intensa. Disponível em diversas cores lindas.',
    29.90, 39.90, 150, 'BAT-RUBY-001', 'Ruby Rose', 
    1, 'https://via.placeholder.com/600x600/FF69B4/FFFFFF?text=Batom+Ruby', 
    TRUE, TRUE, 4.5, 128
),
(
    'Base Líquida Boca Rosa Beauty', 'base-liquida-boca-rosa-beauty', 
    'Base de alta cobertura com efeito matte natural e proteção solar FPS 30',
    'A Base Líquida Boca Rosa Beauty oferece cobertura de média a alta com acabamento matte natural. Sua fórmula leve não obstrui os poros e contém proteção solar FPS 30. Ideal para todos os tipos de pele, especialmente peles oleosas e mistas.',
    89.90, 119.90, 75, 'BAS-BOCA-001', 'Boca Rosa Beauty', 
    2, 'https://via.placeholder.com/600x600/FFB6C1/FFFFFF?text=Base+Boca+Rosa', 
    TRUE, TRUE, 4.8, 256
),
(
    'Paleta de Sombras Nude Mari Maria', 'paleta-sombras-nude-mari-maria', 
    'Paleta profissional com 12 cores neutras para looks versáteis',
    'A Paleta Nude da Mari Maria contém 12 sombras altamente pigmentadas em tons neutros, perfeitas para criar desde looks naturais até produções mais elaboradas. As sombras possuem textura aveludada, fácil de esfumar e longa duração. Contém acabamentos matte, shimmer e metálico.',
    129.90, 159.90, 50, 'SOM-PAL-001', 'Mari Maria', 
    3, 'https://via.placeholder.com/600x600/D2B48C/FFFFFF?text=Paleta+Nude', 
    TRUE, TRUE, 4.9, 312
),
(
    'Blush Líquido Francisca Makeup', 'blush-liquido-francisca-makeup', 
    'Blush líquido de fácil aplicação com acabamento natural e radiante',
    'O Blush Líquido da Francisca Makeup tem textura leve e pigmentação modulável, permitindo construir a cor desejada. Seu aplicador em bisnaga facilita a dosagem do produto. Fórmula vegana, não testada em animais e livre de parabenos.',
    49.90, NULL, 200, 'BLU-FRA-001', 'Francisca Makeup', 
    4, 'https://via.placeholder.com/600x600/FFC0CB/FFFFFF?text=Blush+Liquido', 
    TRUE, FALSE, 4.3, 89
),
(
    'Pó Compacto Translúcido Vult', 'po-compacto-translucido-vult', 
    'Pó compacto que controla a oleosidade sem marcar linhas',
    'O Pó Compacto Translúcido da Vult proporciona acabamento matte e aveludado, controlando o brilho da pele por horas. Sua textura fina não acumula nas linhas de expressão e não altera a cor da base. Ideal para retoques ao longo do dia.',
    39.90, 49.90, 180, 'PO-TRA-001', 'Vult', 
    5, 'https://via.placeholder.com/600x600/F5DEB3/FFFFFF?text=Po+Compacto', 
    TRUE, TRUE, 4.6, 167
),
(
    'Delineador Líquido Preto O Boticário', 'delineador-liquido-preto-o-boticario', 
    'Delineador de ponta fina para traços precisos e intensos',
    'O Delineador Líquido do Boticário possui ponta ultrafina que permite traços precisos e variados. Fórmula à prova d''água, de longa duração e secagem rápida. Cor preta intensa que não desbota ao longo do dia.',
    34.90, NULL, 120, 'DEL-LIQ-001', 'O Boticário', 
    6, 'https://via.placeholder.com/600x600/000000/FFFFFF?text=Delineador', 
    TRUE, FALSE, 4.4, 203
),
(
    'Máscara de Cílios Volume Maybelline', 'mascara-cilios-volume-maybelline', 
    'Máscara que proporciona volume extremo e alongamento sem empelotar',
    'A Máscara de Cílios Volume da Maybelline possui fórmula enriquecida com colágeno e aplicador curvado que envolve cada cílio, proporcionando volume extremo e alongamento. Não empelota, não borra e é oftalmologicamente testada.',
    44.90, 59.90, 90, 'MAS-VOL-001', 'Maybelline', 
    7, 'https://via.placeholder.com/600x600/8B4513/FFFFFF?text=Mascara', 
    TRUE, TRUE, 4.7, 445
),
(
    'Corretivo Líquido Alta Cobertura Natura', 'corretivo-liquido-alta-cobertura-natura', 
    'Corretivo de alta cobertura para olheiras e imperfeições',
    'O Corretivo Líquido Natura oferece alta cobertura com acabamento natural. Sua fórmula contém ativos hidratantes que não ressecam a pele e não acumulam nas linhas finas. Disponível em 8 tons para todos os tons de pele brasileira.',
    39.90, 49.90, 110, 'COR-LIQ-001', 'Natura', 
    8, 'https://via.placeholder.com/600x600/D2691E/FFFFFF?text=Corretivo', 
    TRUE, FALSE, 4.5, 178
),
(
    'Iluminador Líquido Glow Dior', 'iluminador-liquido-glow-dior', 
    'Iluminador líquido que proporciona glow natural e radiante',
    'O Iluminador Líquido Dior Glow possui textura leve que se funde à pele, proporcionando um brilho natural e sofisticado. Pode ser usado sozinho, misturado à base ou aplicado em pontos estratégicos do rosto. Disponível em 4 tons deslumbrantes.',
    159.90, 189.90, 45, 'ILU-LIQ-001', 'Dior', 
    9, 'https://via.placeholder.com/600x600/FFD700/FFFFFF?text=Iluminador', 
    TRUE, TRUE, 4.9, 98
),
(
    'Primer Facial Poreless Benefit', 'primer-facial-poreless-benefit', 
    'Primer que minimiza poros e prepara a pele para maquiagem',
    'O Primer Poreless da Benefit minimiza a aparência dos poros e linhas finas, criando uma tela perfeita para a maquiagem. Sua textura siliconada alisa a pele e aumenta a durabilidade da make. Oil-free e não comedogênico.',
    199.90, 229.90, 60, 'PRI-POR-001', 'Benefit', 
    10, 'https://via.placeholder.com/600x600/98FB98/FFFFFF?text=Primer', 
    TRUE, TRUE, 4.8, 234
),
(
    'Spray Fixador All Nighter Urban Decay', 'spray-fixador-all-nighter-urban-decay', 
    'Spray fixador que mantém a maquiagem intacta por até 16 horas',
    'O Spray Fixador All Nighter da Urban Decay utiliza tecnologia de controle de temperatura para manter a maquiagem fresca e intacta por até 16 horas. Resistente à água, suor e umidade. Não transfere e não borra.',
    149.90, 179.90, 70, 'FIX-SPR-001', 'Urban Decay', 
    11, 'https://via.placeholder.com/600x600/87CEEB/FFFFFF?text=Fixador', 
    TRUE, TRUE, 4.9, 567
)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    price = VALUES(price),
    stock_quantity = VALUES(stock_quantity);

-- =============================================
-- INSERIR VARIAÇÕES (Exemplo para Base)
-- =============================================
INSERT INTO product_variants (product_id, name, sku, stock_quantity, attributes) VALUES
(2, 'Tom 01 - Clara', 'BAS-BOCA-001-01', 25, '{"cor": "Clara", "tom": 1}'),
(2, 'Tom 02 - Média Clara', 'BAS-BOCA-001-02', 30, '{"cor": "Média Clara", "tom": 2}'),
(2, 'Tom 03 - Média', 'BAS-BOCA-001-03', 20, '{"cor": "Média", "tom": 3}')
ON DUPLICATE KEY UPDATE 
    stock_quantity = VALUES(stock_quantity);

-- =============================================
-- CONCEDER PRIVILÉGIOS AO USUÁRIO DA APLICAÇÃO
-- =============================================
GRANT ALL PRIVILEGES ON catalog_db.* TO 'catalog_user'@'%' IDENTIFIED BY 'catalog_pass';
FLUSH PRIVILEGES;

-- =============================================
-- MENSAGEM DE SUCESSO
-- =============================================
SELECT '✅ Banco de dados GLAMOUR CATALOG inicializado com sucesso!' AS status;
SELECT COUNT(*) AS total_categories FROM categories;
SELECT COUNT(*) AS total_products FROM products;