-- Script SQL : Ajout des produits du formulaire de commande dans la table products
-- Ces produits doivent exister pour que la synchronisation des stocks fonctionne

-- IMPORTANT : Ce script REMPLACE les produits ID 1-14 existants
-- Sauvegardez d'abord vos données si nécessaire !

-- Option 1 : SUPPRIMER les anciens produits ID 1-14 (pièces détachées)
-- et les remplacer par les produits du formulaire
-- Décommentez les lignes suivantes si vous voulez cette approche :
-- DELETE FROM products WHERE id BETWEEN 1 AND 14;

-- Option 2 : MODIFIER les IDs des produits existants pour faire de la place
-- Déplacer les pièces détachées vers des IDs plus élevés (500+)
UPDATE products SET id = id + 500 WHERE id BETWEEN 1 AND 14;

-- Insertion des produits du formulaire de commande
-- IDs 1-14 correspondent aux dbId du formulaire (commande-express.php ligne 197-202)

INSERT INTO `products` (`id`, `name`, `reference`, `stock`, `minStock`, `purchasePrice`, `salePrice`, `category`, `description`, `imageUrl`, `is_kit`, `lastUpdated`) VALUES
-- Bouteilles Classiques PET
(1, 'Bouteille 1L', 'BTL-1L-CLASSIC', 0, 10, '15.00', '22.62', 'classic', 'Carton x78', NULL, 0, CURRENT_TIMESTAMP),
(2, 'Bouteille 0,5L', 'BTL-05L-CLASSIC', 0, 10, '30.00', '51.84', 'classic', 'Carton x192', NULL, 0, CURRENT_TIMESTAMP),
(3, 'Bouteille 0,33L', 'BTL-033L-CLASSIC', 0, 10, '35.00', '60.06', 'classic', 'Carton x231', NULL, 0, CURRENT_TIMESTAMP),
(4, 'Bouteille 0,25L', 'BTL-025L-CLASSIC', 0, 10, '50.00', '81.00', 'classic', 'Carton x324', NULL, 0, CURRENT_TIMESTAMP),

-- Bouteilles Bio
(5, 'Bouteille 1L Bio', 'BTL-1L-BIO', 0, 10, '30.00', '45.00', 'bio', 'Carton x100', NULL, 0, CURRENT_TIMESTAMP),
(6, 'Bouteille 0,5L Bio', 'BTL-05L-BIO', 0, 10, '50.00', '80.00', 'bio', 'Carton x200', NULL, 0, CURRENT_TIMESTAMP),
(7, 'Bouteille 0,25L Bio', 'BTL-025L-BIO', 0, 10, '100.00', '156.00', 'bio', 'Carton x400', NULL, 0, CURRENT_TIMESTAMP),

-- Smoothies SEMPA
(8, 'LE FRISSON (1 carton)', 'SMO-FRISSON', 0, 5, '30.00', '46.50', 'smoothie', '9x1L - Pomme, Kiwi', NULL, 0, CURRENT_TIMESTAMP),
(9, 'LE TENDRE (1 carton)', 'SMO-TENDRE', 0, 5, '30.00', '46.50', 'smoothie', '9x1L - Pomme, Banane', NULL, 0, CURRENT_TIMESTAMP),
(10, 'L''AIMABLE (1 carton)', 'SMO-AIMABLE', 0, 5, '20.00', '31.00', 'smoothie', '2 BIB de 3L - Pomme, Carotte, Citron', NULL, 0, CURRENT_TIMESTAMP),
(11, 'L''EXOTIK (1 carton)', 'SMO-EXOTIK', 0, 5, '20.00', '31.00', 'smoothie', '2 BIB de 3L - Pomme, Mangue, Gingembre', NULL, 0, CURRENT_TIMESTAMP),
(12, 'LE TONIK (1 carton)', 'SMO-TONIK', 0, 5, '20.00', '31.00', 'smoothie', '2 BIB de 3L - Pomme, Menthe, Citron', NULL, 0, CURRENT_TIMESTAMP),

-- Gobelets
(13, 'Gobelets (x1000)', 'GOB-1000', 0, 5, '120.00', '180.00', 'cups', 'Avec couvercles et pailles', NULL, 0, CURRENT_TIMESTAMP),

-- Nettoyant
(14, 'Nettoyant Machines (5L)', 'NET-5L-D2A', 0, 5, '75.00', '109.00', 'cleaning', 'Kit D2A', NULL, 0, CURRENT_TIMESTAMP);

-- Vérification
SELECT id, name, reference, stock, salePrice FROM products WHERE id BETWEEN 1 AND 14 ORDER BY id;
