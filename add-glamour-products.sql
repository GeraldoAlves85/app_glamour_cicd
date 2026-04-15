-- Conectar ao banco de dados
USE catalog_db;

-- Limpar produtos existentes (opcional - mantém os atuais)
-- DELETE FROM products;

-- Adicionar mais produtos GLAMUROSOS com imagens
INSERT INTO products (
    name, slug, short_description, description, 
    price, compare_at_price, stock_quantity, sku, brand, 
    category_id, image_url, is_active, is_featured, rating_average, rating_count
) VALUES
-- BATONS DE LUXO
(
    'Batom Líquido Matte Dior Rouge', 'batom-liquido-matte-dior-rouge',
    'Batom líquido de luxo com acabamento matte aveludado',
    'O Batom Líquido Dior Rouge oferece cor intensa e acabamento matte confortável que dura até 12 horas. Enriquecido com óleo de peônia para hidratação profunda.',
    199.90, 249.90, 45, 'BAT-DIOR-001', 'Dior',
    1, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 234
),
(
    'Batom Cremoso Chanel Rouge Allure', 'batom-cremoso-chanel-rouge-allure',
    'Batom cremoso de alta pigmentação com acabamento luminoso',
    'Chanel Rouge Allure desliza suavemente nos lábios, proporcionando cor vibrante e hidratação intensa. Fórmula enriquecida com manteiga de karité e óleo de jojoba.',
    229.90, NULL, 30, 'BAT-CHA-001', 'Chanel',
    1, 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 178
),

-- BASES DE LUXO
(
    'Base Líquida Giorgio Armani Luminous Silk', 'base-liquida-giorgio-armani-luminous-silk',
    'Base premiada com acabamento sedoso e luminoso',
    'A Luminous Silk é a base favorita das celebridades e maquiadores. Cobertura modulável de média a alta, com acabamento natural radiante que dura o dia todo.',
    399.90, 459.90, 25, 'BAS-ARM-001', 'Giorgio Armani',
    2, 'https://images.unsplash.com/photo-1631730359585-38a5e9983ca3?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 567
),
(
    'Base Cushion Lancôme Blanc Expert', 'base-cushion-lancome-blanc-expert',
    'Base em cushion com proteção solar FPS 50',
    'O Cushion Lancôme oferece cobertura leve e natural com aplicação prática. Contém proteção solar FPS 50 e ingredientes clareadores para uniformizar o tom da pele.',
    289.90, 329.90, 40, 'BAS-LAN-001', 'Lancôme',
    2, 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&h=600&fit=crop',
    TRUE, FALSE, 4.7, 312
),

-- PALETAS DE SOMBRAS
(
    'Paleta de Sombras Huda Beauty Rose Quartz', 'paleta-sombras-huda-beauty-rose-quartz',
    'Paleta com 18 sombras em tons rosados e neutros',
    'A Paleta Rose Quartz traz 18 sombras altamente pigmentadas em acabamentos matte, shimmer e metálico. Inspirada no poder de cura do quartzo rosa.',
    349.90, 399.90, 20, 'PAL-HUD-001', 'Huda Beauty',
    3, 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 456
),
(
    'Paleta Naked Heat Urban Decay', 'paleta-naked-heat-urban-decay',
    'Paleta icônica com 12 tons quentes e terrosos',
    'Naked Heat é a paleta perfeita para criar looks quentes e sensuais. 12 sombras exclusivas em tons de âmbar, terracota e cobre com textura aveludada.',
    299.90, 359.90, 35, 'PAL-URB-001', 'Urban Decay',
    3, 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 892
),

-- MÁSCARAS DE CÍLIOS
(
    'Máscara Better Than Sex Too Faced', 'mascara-better-than-sex-too-faced',
    'Máscara volumizadora que proporciona cílios dramáticos',
    'A máscara mais vendida da Too Faced! Proporciona volume extremo, curvatura e alongamento em uma única aplicação. Fórmula à prova dágua disponível.',
    159.90, 189.90, 60, 'MAS-TOO-001', 'Too Faced',
    7, 'https://images.unsplash.com/photo-1611080621390-08ef308e646b?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.7, 1234
),
(
    'Máscara Monsieur Big Lancôme', 'mascara-monsieur-big-lancome',
    'Máscara de volume extremo para cílios impactantes',
    'Monsieur Big proporciona até 12x mais volume sem empelotar. O aplicador curvado envolve cada cílio para um efeito dramático e duradouro.',
    189.90, NULL, 50, 'MAS-LAN-001', 'Lancôme',
    7, 'https://images.unsplash.com/photo-1586012046646-2ab731c3e2c3?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 678
),

-- ILUMINADORES
(
    'Iluminador Dior Backstage Glow Face Palette', 'iluminador-dior-backstage-glow-face-palette',
    'Paleta de iluminadores 4 em 1 para um glow profissional',
    'A Paleta Glow Face da Dior contém 4 tons de iluminador para criar um brilho personalizado. Fórmula fina que se funde à pele sem marcar poros.',
    329.90, 379.90, 25, 'ILU-DIO-001', 'Dior',
    9, 'https://images.unsplash.com/photo-1631214503851-69d34c4b2b5d?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 234
),
(
    'Iluminador Líquido Charlotte Tilbury Hollywood Flawless Filter', 'iluminador-liquido-charlotte-tilbury',
    'Filtro de beleza em frasco para um glow instantâneo',
    'O Hollywood Flawless Filter é um híbrido de primer, iluminador e base. Proporciona um glow natural e filtrado, como se você estivesse sob a luz perfeita.',
    279.90, 319.90, 30, 'ILU-CHA-001', 'Charlotte Tilbury',
    9, 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 345
),

-- PRIMERS
(
    'Primer Hidratante Too Faced Hangover', 'primer-hidratante-too-faced-hangover',
    'Primer hidratante que revitaliza a pele cansada',
    'O Hangover Primer é enriquecido com água de coco e probióticos para hidratar e revitalizar a pele. Ideal para peles ressecadas ou com aspecto cansado.',
    199.90, 229.90, 45, 'PRI-TOO-001', 'Too Faced',
    10, 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.6, 567
),
(
    'Primer Porefessional Benefit', 'primer-porefessional-benefit',
    'Primer que minimiza poros e disfarça imperfeições',
    'O Porefessional é o primer número 1 no mundo! Minimiza instantaneamente a aparência dos poros e linhas finas, criando uma tela perfeita para a maquiagem.',
    189.90, 219.90, 55, 'PRI-BEN-001', 'Benefit',
    10, 'https://images.unsplash.com/photo-1570171264690-24b1c9c8b4f3?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 1890
),

-- SPRAYS FIXADORES
(
    'Spray Fixador Charlotte Tilbury Airbrush Flawless', 'spray-fixador-charlotte-tilbury-airbrush',
    'Spray fixador que prolonga a maquiagem por até 16 horas',
    'O Airbrush Flawless Setting Spray cria uma película protetora que mantém a maquiagem intacta por até 16 horas. Resistente à água, suor e umidade.',
    199.90, 239.90, 40, 'FIX-CHA-001', 'Charlotte Tilbury',
    11, 'https://images.unsplash.com/photo-1601049541289-9e1c2a4937b2?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 456
),
(
    'Spray Fixador MAC Prep + Prime Fix+', 'spray-fixador-mac-prep-prime-fix',
    'Spray multifuncional que hidrata e fixa a maquiagem',
    'O Fix+ da MAC é um ícone! Hidrata, refresca e fixa a maquiagem. Pode ser usado antes da make para preparar a pele ou depois para finalizar.',
    129.90, 159.90, 65, 'FIX-MAC-001', 'MAC Cosmetics',
    11, 'https://images.unsplash.com/photo-1608248597279-f99d5d1ba5b2?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.8, 2345
),

-- CORRETIVOS
(
    'Corretivo NARS Radiant Creamy', 'corretivo-nars-radiant-creamy',
    'Corretivo cremoso de alta cobertura com acabamento radiante',
    'O Radiant Creamy Concealer é um best-seller mundial! Cobertura modulável que não acumula nas linhas finas e não resseca a pele delicada dos olhos.',
    189.90, 219.90, 35, 'COR-NAR-001', 'NARS',
    8, 'https://images.unsplash.com/photo-1600689607173-2c8a3f3a0c0c?w=600&h=600&fit=crop',
    TRUE, TRUE, 4.9, 1567
);

-- Atualizar produtos existentes com imagens
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1599305090597-7a19d3a3b0e1?w=600&h=600&fit=crop' WHERE brand = 'Ruby Rose' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&h=600&fit=crop' WHERE brand = 'Boca Rosa Beauty' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&h=600&fit=crop' WHERE brand = 'Mari Maria' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?w=600&h=600&fit=crop' WHERE brand = 'Francisca Makeup' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=600&h=600&fit=crop' WHERE brand = 'Vult' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1631730359585-38a5e9983ca3?w=600&h=600&fit=crop' WHERE brand = 'O Boticário' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1586012046646-2ab731c3e2c3?w=600&h=600&fit=crop' WHERE brand = 'Maybelline' AND image_url LIKE '%placeholder%';
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=600&h=600&fit=crop' WHERE brand = 'Natura' AND image_url LIKE '%placeholder%';

SELECT '✅ Produtos GLAMUROSOS adicionados com sucesso!' AS status;
SELECT COUNT(*) as total_products FROM products;
