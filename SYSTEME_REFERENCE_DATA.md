# Système de Gestion des Données de Référence - StockPilot

## 📋 Vue d'Ensemble

Ce système permet de gérer de manière professionnelle les **marques**, **types de produits** et **modèles** dans StockPilot avec :
- ✅ Tables dédiées avec relations (Foreign Keys)
- ✅ Interface de gestion complète (ajout/modification/suppression)
- ✅ Dropdowns liés et cohérents
- ✅ Validation des données
- ✅ Statistiques par marque/modèle

## 🗂️ Structure des Tables

### 1. **`brands`** (Marques)
```sql
- id (INT, auto)
- name (VARCHAR) - Nom de la marque
- logo_url (VARCHAR) - URL du logo
- description (TEXT) - Description
- active (BOOLEAN) - Actif/Inactif
- created_at, updated_at (TIMESTAMP)
```

**Exemples** : Zumex, Orangeland, TMP

### 2. **`product_types`** (Types de Produits)
```sql
- id (INT, auto)
- name (VARCHAR) - Nom du type
- icon (VARCHAR) - Icône
- description (TEXT)
- active (BOOLEAN)
- created_at, updated_at (TIMESTAMP)
```

**Exemples** : Machine, Pièce détachée, Accessoire, Consommable

### 3. **`models`** (Modèles)
```sql
- id (INT, auto)
- brand_id (INT) - FK vers brands
- name (VARCHAR) - Nom du modèle
- image_url (VARCHAR) - URL image
- description (TEXT)
- active (BOOLEAN)
- created_at, updated_at (TIMESTAMP)
```

**Exemples** :
- Orangeland → OL41, OL61, OL80
- Zumex → Speed Pro, Versatile Pro, Essential Pro

### 4. **`products`** (Modification)
Ajout de 3 colonnes ID :
```sql
- brand_id (INT) - FK vers brands
- product_type_id (INT) - FK vers product_types
- model_id (INT) - FK vers models
```

Les anciennes colonnes VARCHAR (`brand`, `product_type`, `model`) sont conservées temporairement pour sécurité.

## 🚀 Installation (Ordre Important !)

### Étape 1 : Créer les Tables de Référence

**Exécutez dans phpMyAdmin :**
```bash
create_reference_tables.sql
```

**Ce script :**
- ✅ Crée les 3 tables (brands, product_types, models)
- ✅ Ajoute les index pour les performances
- ✅ Insère les données initiales (Zumex, Orangeland, OL41, Speed Pro, etc.)

### Étape 2 : Migrer les Produits Existants

**Exécutez dans phpMyAdmin :**
```bash
migrate_products_to_foreign_keys.sql
```

**Ce script :**
- ✅ Ajoute les colonnes `brand_id`, `product_type_id`, `model_id` à `products`
- ✅ Migre automatiquement les données VARCHAR → IDs
- ✅ Crée les contraintes de clés étrangères
- ⚠️ **Conserve** les colonnes VARCHAR pour sécurité (à supprimer plus tard)

### Étape 3 : Vérifier la Migration

**Dans phpMyAdmin, exécutez :**
```sql
-- Vérifier que les IDs ont été assignés
SELECT
    p.id,
    p.name,
    b.name AS brand,
    pt.name AS product_type,
    m.name AS model
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
LEFT JOIN product_types pt ON p.product_type_id = pt.id
LEFT JOIN models m ON p.model_id = m.id
LIMIT 20;
```

## 🎨 Utilisation

### Via l'Interface StockPilot (À venir)

**Section Paramètres → Données de Référence**

**Gérer les Marques** :
- Ajouter une nouvelle marque
- Modifier le nom/logo/description
- Supprimer (soft delete)

**Gérer les Types** :
- Ajouter un nouveau type
- Modifier les informations
- Supprimer

**Gérer les Modèles** :
- Ajouter un modèle à une marque
- Lier automatiquement au brand_id
- Modifier/Supprimer

### Via AJAX (Déjà Implémenté)

**Endpoints disponibles :**

```javascript
// Récupérer toutes les marques
jQuery.post(ajaxurl, {
    action: 'sempa_get_brands',
    nonce: nonce
});

// Sauvegarder une marque
jQuery.post(ajaxurl, {
    action: 'sempa_save_brand',
    nonce: nonce,
    id: 0, // 0 pour créer, >0 pour modifier
    name: 'Zumex',
    logo_url: 'https://...',
    description: 'Presse-agrumes Zumex'
});

// Supprimer une marque
jQuery.post(ajaxurl, {
    action: 'sempa_delete_brand',
    nonce: nonce,
    id: 1
});

// Idem pour product_types et models
```

## 📊 Avantages du Système

### ✅ **Cohérence des Données**
- Impossible de faire des fautes de frappe ("Orangelend" vs "Orangeland")
- Validation automatique
- Données normalisées

### ✅ **Relations Logiques**
- Un modèle appartient à UNE marque
- Dropdowns liés : sélectionner Orangeland → affiche uniquement OL41, OL61, OL80

### ✅ **Flexibilité**
- Ajouter/modifier/supprimer sans toucher au code
- Interface user-friendly
- Soft delete (les données ne sont pas perdues)

### ✅ **Performance**
- Index sur toutes les FK
- Requêtes optimisées avec JOIN
- Filtrage rapide

### ✅ **Statistiques**
Possibilité de faire des requêtes comme :
```sql
-- Combien de produits par marque ?
SELECT b.name, COUNT(p.id) as total
FROM brands b
LEFT JOIN products p ON b.id = p.brand_id
GROUP BY b.id;

-- Quels sont les modèles les plus vendus ?
SELECT m.name, COUNT(p.id) as products_count
FROM models m
LEFT JOIN products p ON m.id = p.model_id
GROUP BY m.id
ORDER BY products_count DESC;
```

## 🔧 Import CSV avec le Nouveau Système

### Format CSV Mis à Jour

**Avec les IDs** (Recommandé après migration) :
```csv
name,reference,brand_id,product_type_id,model_id,category,minStock,purchasePrice,salePrice,description
"CAPOT OL 41","300 104 010",2,2,1,"capot",1,0.00,378.00,"Capot de rechange"
```

**Avec les noms** (Compatible, convertit automatiquement) :
```csv
name,reference,brand,product_type,model,category,minStock,purchasePrice,salePrice,description
"CAPOT OL 41","300 104 010","Orangeland","Pièce détachée","OL41","capot",1,0.00,378.00,"Capot de rechange"
```

Le système convertira automatiquement les noms en IDs lors de l'import.

## ⚠️ Important

### Suppression des Colonnes VARCHAR

**APRÈS avoir vérifié que tout fonctionne** (attendez 1-2 semaines), vous pouvez supprimer les anciennes colonnes :

```sql
ALTER TABLE `products`
DROP COLUMN `brand`,
DROP COLUMN `product_type`,
DROP COLUMN `model`;
```

**⚠️ NE FAITES CECI QU'APRÈS** :
- ✅ Vérification complète de la migration
- ✅ Tests d'import/export
- ✅ Tests des formulaires
- ✅ Backup de la base de données

## 📁 Fichiers Créés

1. **`create_reference_tables.sql`** - Création des tables + données initiales
2. **`migrate_products_to_foreign_keys.sql`** - Migration des produits existants
3. **`includes/functions_reference_data.php`** - Handlers AJAX pour gérer les données
4. **`functions.php`** - Intégration du nouveau système

## 🎯 Prochaines Étapes

1. ✅ Créer les tables SQL (fait)
2. ✅ Migrer les produits existants (fait)
3. ✅ Handlers AJAX (fait)
4. ⏳ Interface de gestion dans StockPilot (en cours)
5. ⏳ Dropdowns liés dans les formulaires (en cours)
6. ⏳ Tests et validation

## 💡 Aide

Si vous rencontrez un problème :
1. Vérifiez que `create_reference_tables.sql` a été exécuté
2. Vérifiez que `migrate_products_to_foreign_keys.sql` a été exécuté
3. Vérifiez les IDs dans phpMyAdmin :
   ```sql
   SELECT * FROM brands;
   SELECT * FROM product_types;
   SELECT * FROM models;
   ```
4. Vérifiez les logs d'erreur WordPress/PHP
