-- Migration SQL: Création de la table des fournisseurs
-- Date: 2025-10-22

-- Création de la table des fournisseurs (suppliers)
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) NOT NULL COMMENT 'Nom du fournisseur',
  `contact` varchar(255) DEFAULT NULL COMMENT 'Personne de contact',
  `telephone` varchar(50) DEFAULT NULL COMMENT 'Numéro de téléphone',
  `email` varchar(255) DEFAULT NULL COMMENT 'Adresse email',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date de modification',
  PRIMARY KEY (`id`),
  KEY `idx_nom` (`nom`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table des fournisseurs';

-- Ajout de la colonne fournisseur dans la table products si elle n'existe pas
ALTER TABLE `products`
ADD COLUMN IF NOT EXISTS `supplier` varchar(255) DEFAULT NULL COMMENT 'Nom du fournisseur' AFTER `category`;

-- Ajout d'un index sur la colonne supplier
ALTER TABLE `products`
ADD INDEX IF NOT EXISTS `idx_supplier` (`supplier`);

-- Insertion de quelques fournisseurs par défaut (optionnel)
INSERT INTO `suppliers` (`nom`, `contact`, `telephone`, `email`) VALUES
('Fournisseur par défaut', NULL, NULL, NULL)
ON DUPLICATE KEY UPDATE nom = nom;
