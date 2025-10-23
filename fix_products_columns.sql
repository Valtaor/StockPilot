-- Script de correction : Réparer les produits mal insérés
-- Ce script supprime les produits incorrects et les réinsère proprement

-- Étape 1 : Supprimer les produits mal insérés (IDs 1-14)
DELETE FROM products WHERE id BETWEEN 1 AND 14;

-- Étape 2 : Réinsérer les produits CORRECTEMENT avec les bonnes valeurs

-- IMPORTANT : Vérifier que la structure correspond bien à :
-- id, name, reference, stock, minStock, purchasePrice, salePrice, category, description, imageUrl, is_kit, lastUpdated

INSERT INTO `products` (`id`, `name`, `reference`, `stock`, `minStock`, `purchasePrice`, `salePrice`, `category`, `description`, `imageUrl`, `is_kit`, `lastUpdated`) VALUES

-- Bouteilles Classiques PET
(1, 'Bouteille 1L', 'BTL-1L-CLASSIC', 100, 10, 15.00, 22.62, 'classic', 'Carton x78', NULL, 0, CURRENT_TIMESTAMP),
(2, 'Bouteille 0,5L', 'BTL-05L-CLASSIC', 80, 10, 30.00, 51.84, 'classic', 'Carton x192', NULL, 0, CURRENT_TIMESTAMP),
(3, 'Bouteille 0,33L', 'BTL-033L-CLASSIC', 60, 10, 35.00, 60.06, 'classic', 'Carton x231', NULL, 0, CURRENT_TIMESTAMP),
(4, 'Bouteille 0,25L', 'BTL-025L-CLASSIC', 50, 10, 50.00, 81.00, 'classic', 'Carton x324', NULL, 0, CURRENT_TIMESTAMP),

-- Bouteilles Bio
(5, 'Bouteille 1L Bio', 'BTL-1L-BIO', 40, 10, 30.00, 45.00, 'bio', 'Carton x100', NULL, 0, CURRENT_TIMESTAMP),
(6, 'Bouteille 0,5L Bio', 'BTL-05L-BIO', 30, 10, 50.00, 80.00, 'bio', 'Carton x200', NULL, 0, CURRENT_TIMESTAMP),
(7, 'Bouteille 0,25L Bio', 'BTL-025L-BIO', 20, 10, 100.00, 156.00, 'bio', 'Carton x400', NULL, 0, CURRENT_TIMESTAMP),

-- Smoothies SEMPA
(8, 'LE FRISSON (1 carton)', 'SMO-FRISSON', 25, 5, 30.00, 46.50, 'smoothie', '9x1L - Pomme, Kiwi', NULL, 0, CURRENT_TIMESTAMP),
(9, 'LE TENDRE (1 carton)', 'SMO-TENDRE', 25, 5, 30.00, 46.50, 'smoothie', '9x1L - Pomme, Banane', NULL, 0, CURRENT_TIMESTAMP),
(10, 'L''AIMABLE (1 carton)', 'SMO-AIMABLE', 15, 5, 20.00, 31.00, 'smoothie', '2 BIB de 3L - Pomme, Carotte, Citron', NULL, 0, CURRENT_TIMESTAMP),
(11, 'L''EXOTIK (1 carton)', 'SMO-EXOTIK', 15, 5, 20.00, 31.00, 'smoothie', '2 BIB de 3L - Pomme, Mangue, Gingembre', NULL, 0, CURRENT_TIMESTAMP),
(12, 'LE TONIK (1 carton)', 'SMO-TONIK', 15, 5, 20.00, 31.00, 'smoothie', '2 BIB de 3L - Pomme, Menthe, Citron', NULL, 0, CURRENT_TIMESTAMP),

-- Gobelets
(13, 'Gobelets (x1000)', 'GOB-1000', 10, 5, 120.00, 180.00, 'cups', 'Avec couvercles et pailles', NULL, 0, CURRENT_TIMESTAMP),

-- Nettoyant
(14, 'Nettoyant Machines (5L)', 'NET-5L-D2A', 8, 5, 75.00, 109.00, 'cleaning', 'Kit D2A', NULL, 0, CURRENT_TIMESTAMP);

-- Étape 3 : Vérification - Cette requête doit montrer des NOMBRES dans la colonne stock
SELECT
    id,
    name,
    reference,
    stock,           -- DOIT être un nombre (ex: 100, 80, 60)
    minStock,
    salePrice,
    category
FROM products
WHERE id BETWEEN 1 AND 14
ORDER BY id;

-- Si vous voyez encore des textes dans la colonne stock,
-- la structure de votre table est peut-être différente.
-- Dans ce cas, exécutez cette requête pour voir la structure :
-- DESCRIBE products;
