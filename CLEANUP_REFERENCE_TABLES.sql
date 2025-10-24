-- ===============================================
-- SCRIPT DE NETTOYAGE ET RÉINSTALLATION
-- ===============================================
--
-- ⚠️ ATTENTION : Ce script SUPPRIME et RECRÉE les tables !
-- Utilisez-le UNIQUEMENT si vous voulez repartir de zéro.
--
-- Base de données : dbs1363734
--
-- ===============================================

USE dbs1363734;

-- ===============================================
-- ÉTAPE 1 : SUPPRIMER LES CONTRAINTES FK DE PRODUCTS
-- ===============================================

-- Supprimer les FK si elles existent
SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_brand'
);

SET @sql = IF(@fk_exists > 0,
    'ALTER TABLE `products` DROP FOREIGN KEY `fk_products_brand`',
    'SELECT "FK fk_products_brand does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_product_type'
);

SET @sql = IF(@fk_exists > 0,
    'ALTER TABLE `products` DROP FOREIGN KEY `fk_products_product_type`',
    'SELECT "FK fk_products_product_type does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND CONSTRAINT_NAME = 'fk_products_model'
);

SET @sql = IF(@fk_exists > 0,
    'ALTER TABLE `products` DROP FOREIGN KEY `fk_products_model`',
    'SELECT "FK fk_products_model does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- ÉTAPE 2 : SUPPRIMER LES COLONNES DE PRODUCTS
-- ===============================================

-- Supprimer les colonnes si elles existent
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'brand_id'
);

SET @sql = IF(@column_exists > 0,
    'ALTER TABLE `products` DROP COLUMN `brand_id`',
    'SELECT "Column brand_id does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'product_type_id'
);

SET @sql = IF(@column_exists > 0,
    'ALTER TABLE `products` DROP COLUMN `product_type_id`',
    'SELECT "Column product_type_id does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbs1363734'
    AND TABLE_NAME = 'products'
    AND COLUMN_NAME = 'model_id'
);

SET @sql = IF(@column_exists > 0,
    'ALTER TABLE `products` DROP COLUMN `model_id`',
    'SELECT "Column model_id does not exist" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===============================================
-- ÉTAPE 3 : SUPPRIMER LES TABLES
-- ===============================================

DROP TABLE IF EXISTS `models`;
DROP TABLE IF EXISTS `product_types`;
DROP TABLE IF EXISTS `brands`;

-- ===============================================
-- ÉTAPE 4 : MESSAGE DE CONFIRMATION
-- ===============================================

SELECT '
✅ NETTOYAGE TERMINÉ !

Les éléments suivants ont été supprimés :
- Table models (avec ses données)
- Table product_types (avec ses données)
- Table brands (avec ses données)
- Colonnes brand_id, product_type_id, model_id de products
- Toutes les contraintes FK associées

🎯 PROCHAINE ÉTAPE :
Exécutez maintenant le script SCRIPT_COMPLET_REFERENCE_TABLES.sql
pour recréer tout proprement !
' AS RESULT;
