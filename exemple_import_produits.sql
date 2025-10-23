-- ===============================================
-- Script d'Import de Produits - StockPilot
-- ===============================================
--
-- Ce script insère des produits dans la table products
-- SANS les quantités en stock (stock = 0 par défaut)
--
-- Base de données : dbs1363734
-- Table : products
--
-- ===============================================

-- IMPORTANT : Vérifiez que vous êtes dans la bonne base de données
USE dbs1363734;

-- Exemple d'insertion de produits
-- Adaptez les valeurs selon vos besoins

INSERT INTO `products` (`name`, `reference`, `stock`, `minStock`, `purchasePrice`, `salePrice`, `category`, `description`) VALUES
-- Remplacez les lignes ci-dessous par vos produits
('Produit Exemple 1', 'REF-001', 0, 1, 10.00, 25.00, 'piece', 'Description du produit 1'),
('Produit Exemple 2', 'REF-002', 0, 5, 15.50, 38.00, 'capot', 'Description du produit 2'),
('Produit Exemple 3', 'REF-003', 0, 1, 0.00, 50.00, 'autre', NULL);

-- ===============================================
-- Notes importantes :
-- ===============================================
--
-- 1. Le stock est mis à 0 (vous le remplirez plus tard dans l'interface)
-- 2. minStock = stock minimum avant alerte
-- 3. Les prix sont en décimal (utilisez le POINT, pas la virgule)
-- 4. category : 'piece', 'capot', 'vis_capot', 'tete_robinet', 'couteau', 'languette_presse', 'presse', 'autre'
-- 5. description peut être NULL
--
-- Pour exécuter ce script :
-- mysql -u dbu1662343 -p dbs1363734 < exemple_import_produits.sql
--
-- Ou via phpMyAdmin : copiez-collez le contenu dans l'onglet SQL
--
-- ===============================================
