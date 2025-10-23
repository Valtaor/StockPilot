-- Migration SQL: Création de la table des fournisseurs
-- Date: 2025-10-22
-- Updated: 2025-10-23 - Correspond à la structure réelle de la table

-- Création de la table des fournisseurs
CREATE TABLE IF NOT EXISTS `fournisseurs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom_contact` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telephone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nom_unique` (`nom`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ajout de la colonne fournisseur dans la table products si elle n'existe pas
-- Note: Cette table peut s'appeler 'products' ou 'stocks_sempa' selon votre configuration
ALTER TABLE `products`
ADD COLUMN IF NOT EXISTS `supplier` varchar(255) DEFAULT NULL COMMENT 'Nom du fournisseur' AFTER `category`;

-- Ajout d'un index sur la colonne supplier
ALTER TABLE `products`
ADD INDEX IF NOT EXISTS `idx_supplier` (`supplier`);
