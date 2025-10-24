-- ===============================================
-- SCRIPT SIMPLIFIÉ : Tables de Référence (Sans Migration)
-- ===============================================
--
-- Ce script crée les tables ET ajoute les colonnes ID
-- SANS tenter de migrer depuis des colonnes VARCHAR inexistantes
--
-- Base de données : dbs1363734
--
-- ===============================================

USE dbs1363734;

-- ===============================================
-- PARTIE 1 : CRÉATION DES TABLES
-- ===============================================

CREATE TABLE IF NOT EXISTS `brands` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `logo_url` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_brand_name` (`name`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `product_types` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `icon` VARCHAR(50) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_type_name` (`name`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `models` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `brand_id` INT(11) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_brand_model` (`brand_id`, `name`),
  KEY `idx_brand_id` (`brand_id`),
  KEY `idx_active` (`active`),
  CONSTRAINT `fk_models_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================================
-- PARTIE 2 : INSERTION DES DONNÉES
-- ===============================================

INSERT INTO `brands` (`name`, `description`, `active`) VALUES
('Zumex', 'Presse-agrumes professionnels Zumex', 1),
('Orangeland', 'Presse-agrumes Orangeland (TMP)', 1),
('TMP', 'The Maintenance Process', 1),
('Autre', 'Autres marques', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `product_types` (`name`, `description`, `active`) VALUES
('Machine', 'Presse-agrumes complets', 1),
('Pièce détachée', 'Pièces de rechange', 1),
('Accessoire', 'Accessoires et compléments', 1),
('Consommable', 'Produits consommables', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL41', 'Orangeland 41', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL61', 'Orangeland 61', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL80', 'Orangeland 80', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'Speed Pro', 'Speed Pro', 1 FROM `brands` WHERE `name` = 'Zumex'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'Versatile Pro', 'Versatile Pro', 1 FROM `brands` WHERE `name` = 'Zumex'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'Essential Pro', 'Essential Pro', 1 FROM `brands` WHERE `name` = 'Zumex'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ===============================================
-- PARTIE 3 : AJOUTER LES COLONNES ID DANS PRODUCTS
-- ===============================================

-- Ajouter brand_id (si n'existe pas déjà)
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'brand_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `brand_id` INT(11) DEFAULT NULL AFTER `category`, ADD INDEX `idx_brand_id` (`brand_id`)',
    'SELECT "Column brand_id already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Ajouter product_type_id
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'product_type_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `product_type_id` INT(11) DEFAULT NULL AFTER `brand_id`, ADD INDEX `idx_product_type_id` (`product_type_id`)',
    'SELECT "Column product_type_id already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Ajouter model_id
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'model_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `model_id` INT(11) DEFAULT NULL AFTER `product_type_id`, ADD INDEX `idx_model_id` (`model_id`)',
    'SELECT "Column model_id already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- PARTIE 4 : CRÉER LES CONTRAINTES FK
-- ===============================================

-- FK brand_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_brand'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_brand already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- FK product_type_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_product_type'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_product_type` FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_product_type already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- FK model_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_model'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_model` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_model already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- PARTIE 5 : VÉRIFICATIONS
-- ===============================================

SELECT '=== TABLES CRÉÉES ===' AS '';
SELECT 'BRANDS' AS table_name, COUNT(*) AS nb_lignes FROM brands
UNION ALL
SELECT 'PRODUCT_TYPES', COUNT(*) FROM product_types
UNION ALL
SELECT 'MODELS', COUNT(*) FROM models;

SELECT '=== BRANDS ===' AS '';
SELECT id, name FROM brands ORDER BY name;

SELECT '=== PRODUCT_TYPES ===' AS '';
SELECT id, name FROM product_types ORDER BY name;

SELECT '=== MODELS ===' AS '';
SELECT m.id, b.name AS marque, m.name AS modele
FROM models m
INNER JOIN brands b ON m.brand_id = b.id
ORDER BY b.name, m.name;

SELECT '=== COLONNES AJOUTÉES DANS PRODUCTS ===' AS '';
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbs1363734'
AND TABLE_NAME = 'products'
AND COLUMN_NAME IN ('brand_id', 'product_type_id', 'model_id');

SELECT '
✅ INSTALLATION TERMINÉE !

Tables créées :
- brands (4 marques)
- product_types (4 types)
- models (6 modèles)

Colonnes ajoutées à products :
- brand_id (INT)
- product_type_id (INT)
- model_id (INT)

⚠️ NOTE IMPORTANTE :
Les colonnes sont vides (NULL) car il n''y avait pas de données à migrer.
Vous devrez remplir ces colonnes lors de l''import de vos produits.

🎯 PROCHAINE ÉTAPE :
Importez vos produits en utilisant les IDs des marques/types/modèles !
' AS RESULTAT;
