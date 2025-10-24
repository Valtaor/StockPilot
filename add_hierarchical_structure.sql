-- ===============================================
-- Ajout de la Structure Hiérarchique - StockPilot
-- ===============================================
--
-- Ce script ajoute 3 colonnes pour organiser les produits :
-- - brand : Marque/Gamme (Zumex, Orangeland, TMP)
-- - product_type : Type de produit (Machine, Pièce détachée, Accessoire)
-- - model : Modèle de machine (OL41, OL61, Speed Pro, etc.)
--
-- Base de données : dbs1363734
-- Table : products
--
-- ===============================================

USE dbs1363734;

-- Ajouter les nouvelles colonnes
ALTER TABLE `products`
ADD COLUMN `brand` VARCHAR(50) DEFAULT NULL COMMENT 'Marque: Zumex, Orangeland, TMP' AFTER `category`,
ADD COLUMN `product_type` VARCHAR(50) DEFAULT NULL COMMENT 'Type: Machine, Pièce détachée, Accessoire' AFTER `brand`,
ADD COLUMN `model` VARCHAR(50) DEFAULT NULL COMMENT 'Modèle: OL41, OL61, Speed Pro, etc.' AFTER `product_type`;

-- Ajouter des index pour améliorer les performances de recherche/filtrage
ALTER TABLE `products`
ADD INDEX `idx_brand` (`brand`),
ADD INDEX `idx_product_type` (`product_type`),
ADD INDEX `idx_model` (`model`);

-- Ajouter un index composite pour les recherches combinées
ALTER TABLE `products`
ADD INDEX `idx_brand_model` (`brand`, `model`);

-- ===============================================
-- Exemples de valeurs pour référence :
-- ===============================================
--
-- BRANDS (Marques) :
-- - 'Zumex'
-- - 'Orangeland'
-- - 'TMP'
-- - 'Autre'
--
-- PRODUCT_TYPES (Types de produit) :
-- - 'Machine'
-- - 'Pièce détachée'
-- - 'Accessoire'
-- - 'Consommable'
--
-- MODELS (Modèles) :
-- - 'OL41', 'OL61', 'OL80'
-- - 'Speed Pro', 'Versatile Pro', 'Essential Pro'
-- - etc.
--
-- ===============================================
-- Exemple de mise à jour de produits existants :
-- ===============================================
--
-- Mettre à jour tous les produits OL 41 existants :
-- UPDATE `products`
-- SET `brand` = 'Orangeland',
--     `product_type` = 'Pièce détachée',
--     `model` = 'OL41'
-- WHERE `name` LIKE '%OL 41%' OR `reference` LIKE '%OL 41%';
--
-- Mettre à jour tous les produits OL 61 existants :
-- UPDATE `products`
-- SET `brand` = 'Orangeland',
--     `product_type` = 'Pièce détachée',
--     `model` = 'OL61'
-- WHERE `name` LIKE '%OL 61%' OR `reference` LIKE '%OL 61%';
--
-- ===============================================
-- Vérification :
-- ===============================================
--
-- Afficher la nouvelle structure :
-- DESCRIBE `products`;
--
-- Tester les filtres :
-- SELECT name, reference, brand, product_type, model FROM `products`
-- WHERE brand = 'Orangeland' AND model = 'OL41' LIMIT 10;
--
-- ===============================================
