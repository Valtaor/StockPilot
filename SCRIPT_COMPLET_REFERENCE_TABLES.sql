-- ===============================================
-- SCRIPT COMPLET : Système de Gestion de Référence
-- ===============================================
--
-- Ce script unique fait tout :
-- 1. Crée les 3 tables de référence (brands, product_types, models)
-- 2. Insère les données initiales
-- 3. Ajoute les colonnes FK dans products
-- 4. Migre les données existantes
-- 5. Crée les contraintes FK
--
-- Base de données : dbs1363734
-- À exécuter dans phpMyAdmin en UNE SEULE FOIS
--
-- ===============================================

USE dbs1363734;

-- ===============================================
-- PARTIE 1 : CRÉATION DES TABLES DE RÉFÉRENCE
-- ===============================================

-- ---------------------------------------------
-- Table : brands (Marques)
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS `brands` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `logo_url` VARCHAR(255) DEFAULT NULL COMMENT 'URL du logo de la marque',
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = actif, 0 = désactivé',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_brand_name` (`name`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Marques de produits';

-- ---------------------------------------------
-- Table : product_types (Types de Produits)
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS `product_types` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `icon` VARCHAR(50) DEFAULT NULL COMMENT 'Icône (optionnel)',
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_type_name` (`name`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Types de produits';

-- ---------------------------------------------
-- Table : models (Modèles)
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS `models` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `brand_id` INT(11) NOT NULL COMMENT 'Référence à brands.id',
  `name` VARCHAR(100) NOT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL COMMENT 'URL image du modèle',
  `description` TEXT DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_brand_model` (`brand_id`, `name`),
  KEY `idx_brand_id` (`brand_id`),
  KEY `idx_active` (`active`),
  CONSTRAINT `fk_models_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Modèles de produits par marque';

-- ===============================================
-- PARTIE 2 : INSERTION DES DONNÉES INITIALES
-- ===============================================

-- ---------------------------------------------
-- Marques
-- ---------------------------------------------
INSERT INTO `brands` (`name`, `description`, `active`) VALUES
('Zumex', 'Presse-agrumes professionnels Zumex', 1),
('Orangeland', 'Presse-agrumes Orangeland (TMP)', 1),
('TMP', 'The Maintenance Process', 1),
('Autre', 'Autres marques', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ---------------------------------------------
-- Types de produits
-- ---------------------------------------------
INSERT INTO `product_types` (`name`, `description`, `active`) VALUES
('Machine', 'Presse-agrumes complets', 1),
('Pièce détachée', 'Pièces de rechange', 1),
('Accessoire', 'Accessoires et compléments', 1),
('Consommable', 'Produits consommables', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ---------------------------------------------
-- Modèles Orangeland
-- ---------------------------------------------
INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL41', 'Orangeland 41', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL61', 'Orangeland 61', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL80', 'Orangeland 80', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ---------------------------------------------
-- Modèles Zumex
-- ---------------------------------------------
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
-- PARTIE 3 : MODIFICATION DE LA TABLE PRODUCTS
-- ===============================================

-- ---------------------------------------------
-- Ajouter les colonnes ID (si elles n'existent pas déjà)
-- ---------------------------------------------

-- Vérifier et ajouter brand_id
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'brand_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `brand_id` INT(11) DEFAULT NULL AFTER `category`, ADD INDEX `idx_brand_id` (`brand_id`)',
    'SELECT "Column brand_id already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et ajouter product_type_id
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'product_type_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `product_type_id` INT(11) DEFAULT NULL AFTER `brand_id`, ADD INDEX `idx_product_type_id` (`product_type_id`)',
    'SELECT "Column product_type_id already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier et ajouter model_id
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'model_id'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `model_id` INT(11) DEFAULT NULL AFTER `product_type_id`, ADD INDEX `idx_model_id` (`model_id`)',
    'SELECT "Column model_id already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- PARTIE 4 : MIGRATION DES DONNÉES EXISTANTES
-- ===============================================

-- ---------------------------------------------
-- Migrer brand → brand_id
-- ---------------------------------------------
UPDATE `products` p
INNER JOIN `brands` b ON LOWER(TRIM(p.`brand`)) = LOWER(TRIM(b.`name`))
SET p.`brand_id` = b.`id`
WHERE p.`brand` IS NOT NULL AND p.`brand` != '' AND p.`brand_id` IS NULL;

-- ---------------------------------------------
-- Migrer product_type → product_type_id
-- ---------------------------------------------
UPDATE `products` p
INNER JOIN `product_types` pt ON LOWER(TRIM(p.`product_type`)) = LOWER(TRIM(pt.`name`))
SET p.`product_type_id` = pt.`id`
WHERE p.`product_type` IS NOT NULL AND p.`product_type` != '' AND p.`product_type_id` IS NULL;

-- ---------------------------------------------
-- Migrer model → model_id
-- ---------------------------------------------
UPDATE `products` p
INNER JOIN `models` m ON LOWER(TRIM(p.`model`)) = LOWER(TRIM(m.`name`))
INNER JOIN `brands` b ON m.`brand_id` = b.`id` AND LOWER(TRIM(p.`brand`)) = LOWER(TRIM(b.`name`))
SET p.`model_id` = m.`id`
WHERE p.`model` IS NOT NULL AND p.`model` != '' AND p.`brand` IS NOT NULL AND p.`model_id` IS NULL;

-- ===============================================
-- PARTIE 5 : CONTRAINTES DE CLÉS ÉTRANGÈRES
-- ===============================================

-- Note: Les FK sont ajoutées seulement si elles n'existent pas déjà

-- FK pour brand_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_brand'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_brand already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- FK pour product_type_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_product_type'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_product_type` FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_product_type already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- FK pour model_id
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_model'
);

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_model` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "FK fk_products_model already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- PARTIE 6 : VÉRIFICATIONS
-- ===============================================

-- Afficher les marques créées
SELECT '=== BRANDS ===' AS '';
SELECT * FROM `brands` ORDER BY `name`;

-- Afficher les types de produits
SELECT '=== PRODUCT TYPES ===' AS '';
SELECT * FROM `product_types` ORDER BY `name`;

-- Afficher les modèles avec leurs marques
SELECT '=== MODELS ===' AS '';
SELECT m.id, b.name AS brand, m.name AS model, m.description
FROM `models` m
INNER JOIN `brands` b ON m.brand_id = b.id
ORDER BY b.name, m.name;

-- Statistiques de migration
SELECT '=== MIGRATION STATISTICS ===' AS '';
SELECT
    COUNT(*) as total_products,
    SUM(CASE WHEN brand_id IS NOT NULL THEN 1 ELSE 0 END) as products_with_brand,
    SUM(CASE WHEN product_type_id IS NOT NULL THEN 1 ELSE 0 END) as products_with_type,
    SUM(CASE WHEN model_id IS NOT NULL THEN 1 ELSE 0 END) as products_with_model
FROM `products`;

-- Afficher quelques produits avec les nouvelles relations
SELECT '=== SAMPLE PRODUCTS WITH RELATIONS ===' AS '';
SELECT
    p.id,
    p.name,
    p.reference,
    b.name AS brand,
    pt.name AS product_type,
    m.name AS model,
    p.category
FROM `products` p
LEFT JOIN `brands` b ON p.brand_id = b.id
LEFT JOIN `product_types` pt ON p.product_type_id = pt.id
LEFT JOIN `models` m ON p.model_id = m.id
LIMIT 20;

-- Vérifier s'il y a des produits avec brand texte mais sans brand_id (erreurs potentielles)
SELECT '=== PRODUCTS WITH UNMIGRATED BRANDS ===' AS '';
SELECT COUNT(*) as unmigrated_count
FROM `products`
WHERE brand IS NOT NULL AND brand != '' AND brand_id IS NULL;

-- ===============================================
-- FIN DU SCRIPT
-- ===============================================

SELECT '
✅ SCRIPT TERMINÉ !

Tables créées :
- brands (marques)
- product_types (types de produits)
- models (modèles)

Données insérées :
- 4 marques (Zumex, Orangeland, TMP, Autre)
- 4 types (Machine, Pièce détachée, Accessoire, Consommable)
- 6 modèles (OL41, OL61, OL80, Speed Pro, Versatile Pro, Essential Pro)

Table products modifiée :
- Colonnes ajoutées : brand_id, product_type_id, model_id
- Données migrées automatiquement
- Contraintes FK créées

⚠️ NOTES IMPORTANTES :
1. Les anciennes colonnes VARCHAR (brand, product_type, model) sont conservées pour sécurité
2. Vous pouvez les supprimer plus tard après vérification complète
3. Les FK utilisent ON DELETE SET NULL (sécurité)
4. Soft delete activé (active flag) pour toutes les tables

🎯 PROCHAINE ÉTAPE :
Vérifiez les statistiques ci-dessus pour confirmer que tout est OK !
' AS RESULT;
