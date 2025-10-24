-- ===============================================
-- Migration des Produits vers Foreign Keys
-- ===============================================
--
-- Ce script ajoute les colonnes ID pour les relations
-- et migre les données des colonnes VARCHAR vers les IDs
--
-- ⚠️ IMPORTANT : Exécuter create_reference_tables.sql EN PREMIER !
--
-- Base de données : dbs1363734
--
-- ===============================================

USE dbs1363734;

-- ===============================================
-- 1. Ajouter les nouvelles colonnes ID
-- ===============================================

-- Ajouter brand_id
ALTER TABLE `products`
ADD COLUMN `brand_id` INT(11) DEFAULT NULL AFTER `category`,
ADD INDEX `idx_brand_id` (`brand_id`);

-- Ajouter product_type_id
ALTER TABLE `products`
ADD COLUMN `product_type_id` INT(11) DEFAULT NULL AFTER `brand_id`,
ADD INDEX `idx_product_type_id` (`product_type_id`);

-- Ajouter model_id
ALTER TABLE `products`
ADD COLUMN `model_id` INT(11) DEFAULT NULL AFTER `product_type_id`,
ADD INDEX `idx_model_id` (`model_id`);

-- ===============================================
-- 2. Migrer les Données Existantes
-- ===============================================

-- Migrer brand → brand_id
UPDATE `products` p
INNER JOIN `brands` b ON LOWER(TRIM(p.`brand`)) = LOWER(TRIM(b.`name`))
SET p.`brand_id` = b.`id`
WHERE p.`brand` IS NOT NULL AND p.`brand` != '';

-- Migrer product_type → product_type_id
UPDATE `products` p
INNER JOIN `product_types` pt ON LOWER(TRIM(p.`product_type`)) = LOWER(TRIM(pt.`name`))
SET p.`product_type_id` = pt.`id`
WHERE p.`product_type` IS NOT NULL AND p.`product_type` != '';

-- Migrer model → model_id (en vérifiant la cohérence avec brand)
UPDATE `products` p
INNER JOIN `models` m ON LOWER(TRIM(p.`model`)) = LOWER(TRIM(m.`name`))
INNER JOIN `brands` b ON m.`brand_id` = b.`id` AND LOWER(TRIM(p.`brand`)) = LOWER(TRIM(b.`name`))
SET p.`model_id` = m.`id`
WHERE p.`model` IS NOT NULL AND p.`model` != '' AND p.`brand` IS NOT NULL;

-- ===============================================
-- 3. Ajouter les Contraintes de Clés Étrangères
-- ===============================================

ALTER TABLE `products`
ADD CONSTRAINT `fk_products_brand`
  FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`)
  ON DELETE SET NULL ON UPDATE CASCADE,
ADD CONSTRAINT `fk_products_product_type`
  FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`)
  ON DELETE SET NULL ON UPDATE CASCADE,
ADD CONSTRAINT `fk_products_model`
  FOREIGN KEY (`model_id`) REFERENCES `models` (`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;

-- ===============================================
-- 4. (Optionnel) Supprimer les Anciennes Colonnes VARCHAR
-- ===============================================

-- ⚠️ NE SUPPRIMEZ CES COLONNES QU'APRÈS AVOIR VÉRIFIÉ LA MIGRATION !
-- ⚠️ Gardez-les pendant quelques jours pour sécurité

-- ALTER TABLE `products` DROP COLUMN `brand`;
-- ALTER TABLE `products` DROP COLUMN `product_type`;
-- ALTER TABLE `products` DROP COLUMN `model`;

-- ===============================================
-- Vérifications
-- ===============================================

-- Vérifier la migration des brands
SELECT
    COUNT(*) as total_products,
    SUM(CASE WHEN brand_id IS NOT NULL THEN 1 ELSE 0 END) as with_brand_id,
    SUM(CASE WHEN brand IS NOT NULL AND brand != '' THEN 1 ELSE 0 END) as with_brand_text
FROM `products`;

-- Vérifier les produits avec brand texte mais sans brand_id (erreurs de migration)
SELECT id, name, reference, brand, brand_id
FROM `products`
WHERE brand IS NOT NULL AND brand != '' AND brand_id IS NULL
LIMIT 10;

-- Afficher quelques produits avec les nouvelles relations
SELECT
    p.id,
    p.name,
    b.name AS brand,
    pt.name AS product_type,
    m.name AS model,
    p.category
FROM `products` p
LEFT JOIN `brands` b ON p.brand_id = b.id
LEFT JOIN `product_types` pt ON p.product_type_id = pt.id
LEFT JOIN `models` m ON p.model_id = m.id
LIMIT 20;

-- ===============================================
-- Notes
-- ===============================================
--
-- Après cette migration :
-- 1. Les colonnes brand, product_type, model (VARCHAR) existent toujours (sécurité)
-- 2. Les nouvelles colonnes brand_id, product_type_id, model_id sont utilisées
-- 3. Les contraintes FK assurent l'intégrité des données
-- 4. Vous pouvez supprimer les colonnes VARCHAR après vérification
--
-- ===============================================
