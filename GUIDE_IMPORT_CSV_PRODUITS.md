# Guide d'Import CSV des Produits - StockPilot

## 📋 Aperçu

Ce guide vous explique comment importer vos produits dans StockPilot via un fichier CSV.

## 🗂️ Structure de la Table `products`

La table de la base de données contient les colonnes suivantes :

| Colonne | Type | Obligatoire | Description | Exemple |
|---------|------|-------------|-------------|---------|
| `id` | int | Auto | Identifiant unique (auto-incrémenté) | 1, 2, 3 |
| `name` | varchar(255) | ✅ Oui | Nom/Désignation du produit | "AIMANT + CACHE AIMANT OL 41" |
| `reference` | varchar(100) | Non | Référence produit | "300 128 010" |
| `brand` | varchar(50) | 🆕 Non | Marque/Gamme | "Zumex", "Orangeland", "TMP" |
| `product_type` | varchar(50) | 🆕 Non | Type de produit | "Machine", "Pièce détachée", "Accessoire" |
| `model` | varchar(50) | 🆕 Non | Modèle de machine | "OL41", "OL61", "Speed Pro" |
| `category` | varchar(100) | Non | Type de pièce (défaut: "autre") | "piece", "capot", "vis_capot" |
| `stock` | int | Non | Quantité en stock (défaut: 0) | 0 |
| `minStock` | int | Non | Stock minimum (défaut: 1) | 5 |
| `purchasePrice` | decimal(10,2) | Non | Prix d'achat HT (défaut: 0.00) | 15.50 |
| `salePrice` | decimal(10,2) | Non | Prix de vente TTC (défaut: 0.00) | 38.00 |
| `description` | text | Non | Description ou notes | "Pièce de rechange pour OL 41" |
| `imageUrl` | varchar(255) | Non | URL vers image/document | NULL |
| `is_kit` | tinyint(1) | Non | Est-ce un kit ? (défaut: 0) | 0 ou 1 |
| `lastUpdated` | timestamp | Auto | Date de dernière modification | Auto |

### 🆕 Nouveauté : Structure Hiérarchique

Les 3 nouvelles colonnes (`brand`, `product_type`, `model`) permettent d'organiser vos produits de manière hiérarchique :

**Exemple d'organisation :**
```
Orangeland (brand)
  └─ Machine (product_type)
      └─ OL41 (model)
  └─ Pièce détachée (product_type)
      └─ OL41 (model)
          ├─ capot (category)
          ├─ couteau (category)
          └─ vis_capot (category)

Zumex (brand)
  └─ Machine (product_type)
      └─ Speed Pro (model)
  └─ Pièce détachée (product_type)
      └─ Speed Pro (model)
```

## 📄 Format CSV Recommandé

### Option 1 : Import SANS stock avec structure hiérarchique (recommandé)

Si vous n'avez pas les quantités en stock, utilisez ce format avec brand/product_type/model :

```csv
name,reference,brand,product_type,model,category,minStock,purchasePrice,salePrice,description
"Presse-agrumes OL 41","300-000-041","Orangeland","Machine","OL41","machine",1,1890.00,2490.00,"Presse-agrumes professionnel"
"CAPOT OL 41","300 104 010","Orangeland","Pièce détachée","OL41","capot",1,0.00,378.00,"Capot de rechange"
"COUTEAU OL 41","300 211 023","Orangeland","Pièce détachée","OL41","couteau",2,0.00,114.00,"Couteau de remplacement"
"Presse-agrumes Speed Pro","ZUM-SPEED","Zumex","Machine","Speed Pro","machine",1,2400.00,3200.00,"Presse-agrumes haute performance"
```

**📌 Points importants :**
- ✅ Mettez les noms entre guillemets si ils contiennent des virgules ou espaces
- ✅ Le stock sera mis à 0 par défaut
- ✅ minStock à 1 par défaut (vous pouvez ajuster)
- ✅ Les prix en format décimal avec point (ex: 15.50)

### Option 2 : Utiliser l'export StockPilot comme base

**Oui, vous pouvez !** Voici comment :

1. **Exportez depuis StockPilot** (bouton "Exporter CSV")
2. **Ouvrez le fichier CSV** dans Excel ou LibreOffice
3. **Supprimez les lignes de données existantes**
4. **Gardez uniquement l'en-tête** :
```csv
ID,Référence,Désignation,Catégorie,Fournisseur,Prix achat,Prix vente,Stock actuel,Stock minimum,Stock maximum,Emplacement,Date entrée,Date modification,Notes,Document,Ajouté par
```

5. **Ajoutez vos produits** :
```csv
ID,Référence,Désignation,Catégorie,Fournisseur,Prix achat,Prix vente,Stock actuel,Stock minimum,Stock maximum,Emplacement,Date entrée,Date modification,Notes,Document,Ajouté par
,"300 128 010","AIMANT + CACHE AIMANT OL 41","piece",,0.00,38.00,0,1,,,,,,,
,"300 243 010","BASE INOX OL 41","piece",,0.00,289.00,0,1,,,,,,,
```

**⚠️ Important :** Laissez la colonne `ID` vide pour les nouveaux produits !

## 🛠️ Méthode d'Import

### Méthode Recommandée : SQL Direct

Créez un fichier `import_produits.sql` :

```sql
-- Import de produits SANS stock
INSERT INTO `products` (`name`, `reference`, `stock`, `minStock`, `purchasePrice`, `salePrice`, `category`, `description`) VALUES
('AIMANT + CACHE AIMANT OL 41', '300 128 010', 0, 1, 0.00, 38.00, 'piece', NULL),
('BASE INOX OL 41', '300 243 010', 0, 1, 0.00, 289.00, 'piece', NULL),
('CAPOT OL 41', '300 104 010', 0, 1, 0.00, 378.00, 'capot', NULL);
```

**Exécutez via phpMyAdmin ou MySQL :**
```bash
mysql -u dbu1662343 -p dbs1363734 < import_produits.sql
```

### Alternative : Script PHP d'Import CSV

Je peux créer un script PHP qui lit votre CSV et insère les produits automatiquement.

## 🎨 Valeurs Recommandées pour les Nouvelles Colonnes

### **Brands (Marques)** :
- `Zumex` - Presse-agrumes Zumex
- `Orangeland` - Presse-agrumes Orangeland
- `TMP` - The Maintenance Process
- `Autre` - Autres marques

### **Product Types (Types de produit)** :
- `Machine` - Presse-agrumes complets
- `Pièce détachée` - Pièces de rechange
- `Accessoire` - Accessoires et compléments
- `Consommable` - Produits consommables

### **Models (Modèles)** :
**Orangeland :**
- `OL41` - Orangeland 41
- `OL61` - Orangeland 61
- `OL80` - Orangeland 80

**Zumex :**
- `Speed Pro` - Speed Pro
- `Versatile Pro` - Versatile Pro
- `Essential Pro` - Essential Pro

### **Categories (Types de pièces)** - Existantes :
- `machine` - Machine complète
- `piece` - Pièce générique
- `capot` - Capots
- `vis_capot` - Vis de capot
- `tete_robinet` - Têtes de robinet
- `couteau` - Couteaux
- `languette_presse` - Languettes de presse
- `presse` - Presses
- `filtre` - Filtres
- `autre` - Autre

## 📊 Template CSV Prêt à Remplir

Voici un template que vous pouvez copier dans Excel :

| name | reference | brand | product_type | model | category | minStock | purchasePrice | salePrice | description |
|------|-----------|-------|--------------|-------|----------|----------|---------------|-----------|-------------|
| Nom du produit | REF-001 | Orangeland | Pièce détachée | OL41 | piece | 1 | 10.00 | 25.00 | Notes optionnelles |
|  |  |  |  |  |  |  |  |  |  |

**Enregistrez en CSV (UTF-8 avec séparateur virgule)**

## ✅ Checklist Avant Import

- [ ] Le fichier CSV est en UTF-8
- [ ] Les noms de colonnes correspondent exactement
- [ ] Les prix utilisent le point comme séparateur décimal (15.50 pas 15,50)
- [ ] La colonne ID est vide pour les nouveaux produits
- [ ] Les valeurs de stock sont à 0 si vous ne connaissez pas les quantités
- [ ] Les colonnes `brand`, `product_type` et `model` sont remplies pour une meilleure organisation
- [ ] Les valeurs de `brand`, `product_type`, `model` et `category` correspondent aux listes recommandées
- [ ] Vous avez exécuté le script `add_hierarchical_structure.sql` pour ajouter les nouvelles colonnes
- [ ] Vous avez fait une sauvegarde de la base avant import

## 🚀 Prochaines Étapes

### Étape 1 : Ajouter les nouvelles colonnes à la base de données

**⚠️ IMPORTANT : À faire en PREMIER !**

Exécutez le script SQL pour ajouter les colonnes `brand`, `product_type` et `model` :

```bash
# Via phpMyAdmin : Copiez-collez le contenu de add_hierarchical_structure.sql
# Ou via MySQL CLI :
mysql -u dbu1662343 -p dbs1363734 < add_hierarchical_structure.sql
```

### Étape 2 : Préparez vos données

1. **Créez votre fichier CSV** avec les colonnes : name, reference, brand, product_type, model, category, minStock, purchasePrice, salePrice, description
2. **Utilisez `template_import_produits.csv`** comme modèle
3. **Remplissez vos produits** en respectant les valeurs recommandées

### Étape 3 : Import

**Option A - Script SQL (Recommandé)** :
1. Partagez-moi votre CSV
2. Je génère le script SQL optimisé
3. Vous l'exécutez dans phpMyAdmin

**Option B - Script PHP** :
1. Uploadez `import_csv_produits.php` et votre CSV sur le serveur
2. Accédez à l'URL pour lancer l'import
3. ⚠️ **Supprimez les fichiers après !**

## 💡 Recommandation

Pour votre cas (import sans stock avec structure hiérarchique), je vous conseille de :
1. **Exécuter d'abord** `add_hierarchical_structure.sql` pour ajouter les colonnes
2. **Créer votre fichier CSV** avec les colonnes brand, product_type, model
3. **Me partager le fichier** → Je créerai le script SQL optimisé pour l'import

Cela sera plus rapide, sécurisé et permettra une meilleure organisation de vos produits !
