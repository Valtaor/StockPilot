-- ===============================================
-- Création des Tables de Référence - StockPilot
-- ===============================================
--
-- Ce script crée les tables pour gérer :
-- - Marques (brands)
-- - Types de produits (product_types)
-- - Modèles (models)
--
-- Base de données : dbs1363734
--
-- ===============================================

USE dbs1363734;

-- ===============================================
-- 1. Table des Marques
-- ===============================================

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

-- ===============================================
-- 2. Table des Types de Produits
-- ===============================================

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

-- ===============================================
-- 3. Table des Modèles
-- ===============================================

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
-- 4. Insertion des Données Initiales
-- ===============================================

-- Marques
INSERT INTO `brands` (`name`, `description`, `active`) VALUES
('Zumex', 'Presse-agrumes professionnels Zumex', 1),
('Orangeland', 'Presse-agrumes Orangeland (TMP)', 1),
('TMP', 'The Maintenance Process', 1),
('Autre', 'Autres marques', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Types de produits
INSERT INTO `product_types` (`name`, `description`, `active`) VALUES
('Machine', 'Presse-agrumes complets', 1),
('Pièce détachée', 'Pièces de rechange', 1),
('Accessoire', 'Accessoires et compléments', 1),
('Consommable', 'Produits consommables', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Modèles Orangeland
INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL41', 'Orangeland 41', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL61', 'Orangeland 61', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `models` (`brand_id`, `name`, `description`, `active`)
SELECT id, 'OL80', 'Orangeland 80', 1 FROM `brands` WHERE `name` = 'Orangeland'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Modèles Zumex
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
-- 5. Migration des Données Existantes (Optionnel)
-- ===============================================

-- Cette section migre les valeurs textuelles existantes dans products
-- vers les nouvelles tables de référence

-- NOTE: Décommentez ces requêtes APRÈS avoir vérifié les données

-- Mettre à jour brand_id dans products basé sur le texte brand
-- UPDATE `products` p
-- INNER JOIN `brands` b ON p.`brand` = b.`name`
-- SET p.`brand_id` = b.`id`
-- WHERE p.`brand` IS NOT NULL;

-- Mettre à jour product_type_id dans products
-- UPDATE `products` p
-- INNER JOIN `product_types` pt ON p.`product_type` = pt.`name`
-- SET p.`product_type_id` = pt.`id`
-- WHERE p.`product_type` IS NOT NULL;

-- Mettre à jour model_id dans products
-- UPDATE `products` p
-- INNER JOIN `models` m ON p.`model` = m.`name`
-- INNER JOIN `brands` b ON p.`brand` = b.`name` AND m.`brand_id` = b.`id`
-- SET p.`model_id` = m.`id`
-- WHERE p.`model` IS NOT NULL AND p.`brand` IS NOT NULL;

-- ===============================================
-- Vérifications
-- ===============================================

-- Afficher les marques
SELECT * FROM `brands`;

-- Afficher les types de produits
SELECT * FROM `product_types`;

-- Afficher les modèles avec leurs marques
SELECT m.id, b.name AS brand, m.name AS model, m.description
FROM `models` m
INNER JOIN `brands` b ON m.brand_id = b.id
ORDER BY b.name, m.name;

-- ===============================================
