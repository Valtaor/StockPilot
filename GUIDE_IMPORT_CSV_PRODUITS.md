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
| `stock` | int | Non | Quantité en stock (défaut: 0) | 0 |
| `minStock` | int | Non | Stock minimum (défaut: 1) | 5 |
| `purchasePrice` | decimal(10,2) | Non | Prix d'achat HT (défaut: 0.00) | 15.50 |
| `salePrice` | decimal(10,2) | Non | Prix de vente TTC (défaut: 0.00) | 38.00 |
| `category` | varchar(100) | Non | Catégorie (défaut: "autre") | "piece", "capot", "vis_capot" |
| `description` | text | Non | Description ou notes | "Pièce de rechange pour OL 41" |
| `imageUrl` | varchar(255) | Non | URL vers image/document | NULL |
| `is_kit` | tinyint(1) | Non | Est-ce un kit ? (défaut: 0) | 0 ou 1 |
| `lastUpdated` | timestamp | Auto | Date de dernière modification | Auto |

## 📄 Format CSV Recommandé

### Option 1 : Import SANS stock (votre cas)

Si vous n'avez pas les quantités en stock, utilisez ce format :

```csv
name,reference,minStock,purchasePrice,salePrice,category,description
"AIMANT + CACHE AIMANT OL 41","300 128 010",1,0.00,38.00,"piece",""
"BASE INOX OL 41","300 243 010",1,0.00,289.00,"piece",""
"CAPOT OL 41","300 104 010",1,0.00,378.00,"capot",""
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

## 📊 Template CSV Prêt à Remplir

Voici un template que vous pouvez copier dans Excel :

| name | reference | minStock | purchasePrice | salePrice | category | description |
|------|-----------|----------|---------------|-----------|----------|-------------|
| Nom du produit | REF-001 | 1 | 10.00 | 25.00 | piece | Notes optionnelles |
|  |  |  |  |  |  |  |

**Enregistrez en CSV (UTF-8 avec séparateur virgule)**

## 🎯 Catégories Existantes

D'après vos données actuelles, voici les catégories utilisées :
- `piece` (pièce générique)
- `capot`
- `vis_capot`
- `tete_robinet`
- `couteau`
- `languette_presse`
- `presse`
- `autre` (par défaut)

## ✅ Checklist Avant Import

- [ ] Le fichier CSV est en UTF-8
- [ ] Les noms de colonnes correspondent exactement
- [ ] Les prix utilisent le point comme séparateur décimal (15.50 pas 15,50)
- [ ] La colonne ID est vide pour les nouveaux produits
- [ ] Les valeurs de stock sont à 0 si vous ne connaissez pas les quantités
- [ ] Vous avez fait une sauvegarde de la base avant import

## 🚀 Prochaines Étapes

1. **Préparez votre CSV** avec vos produits
2. **Partagez-le moi** et je peux :
   - Vérifier qu'il est bien formaté
   - Créer le script SQL d'insertion
   - Ou créer un script PHP d'import automatique

## 💡 Recommandation

Pour votre cas (import sans stock), je vous conseille de :
1. **Créer un fichier Excel** avec les colonnes : name, reference, minStock, purchasePrice, salePrice, category
2. **Remplir vos données**
3. **M'envoyer le fichier** → Je créerai le script SQL optimisé pour l'import

Cela sera plus rapide et sécurisé qu'un import CSV direct !
