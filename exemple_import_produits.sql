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

-- Exemple d'insertion de produits avec structure hiérarchique
-- Adaptez les valeurs selon vos besoins

INSERT INTO `products` (
    `name`,
    `reference`,
    `brand`,
    `product_type`,
    `model`,
    `category`,
    `stock`,
    `minStock`,
    `purchasePrice`,
    `salePrice`,
    `description`
) VALUES
-- MACHINES
('Presse-agrumes OL 41', '300-000-041', 'Orangeland', 'Machine', 'OL41', 'machine', 0, 1, 1890.00, 2490.00, 'Presse-agrumes professionnel'),
('Presse-agrumes Speed Pro', 'ZUM-SPEED', 'Zumex', 'Machine', 'Speed Pro', 'machine', 0, 1, 2400.00, 3200.00, 'Presse-agrumes haute performance'),

-- PIÈCES DÉTACHÉES ORANGELAND OL41
('CAPOT OL 41', '300 104 010', 'Orangeland', 'Pièce détachée', 'OL41', 'capot', 0, 1, 0.00, 378.00, 'Capot de rechange'),
('COUTEAU OL 41', '300 211 023', 'Orangeland', 'Pièce détachée', 'OL41', 'couteau', 0, 2, 0.00, 114.00, 'Couteau de remplacement'),
('ROBINET NOUVEAU OL 41', '300 112 050', 'Orangeland', 'Pièce détachée', 'OL41', 'tete_robinet', 0, 1, 0.00, 159.00, NULL),

-- PIÈCES DÉTACHÉES ZUMEX
('Filtre Speed Pro', 'ZUM-FIL-001', 'Zumex', 'Pièce détachée', 'Speed Pro', 'filtre', 0, 5, 0.00, 45.00, 'Filtre métallique');

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
