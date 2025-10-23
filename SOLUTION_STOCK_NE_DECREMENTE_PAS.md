# Solution : Le stock ne se décrémente pas après une commande

## Symptômes observés

1. ✅ La commande s'enregistre correctement
2. ✅ Les emails sont envoyés
3. ✅ Un mouvement de stock apparaît dans l'onglet "Mouvements"
4. ❌ **Mais le stock ne diminue PAS dans l'onglet "Produits"**
5. ❌ **La colonne "stock" contient du TEXTE** (ex: "BTL-025L-CLASSIC") au lieu d'un nombre

## Cause du problème

Lors de l'insertion initiale des produits avec le script `add_order_form_products.sql`, **les valeurs se sont décalées dans les mauvaises colonnes**.

### Ce qui s'est passé :

```
Données attendues :
┌────┬───────────────┬──────────────────┬───────┬──────────┐
│ id │ name          │ reference        │ stock │ minStock │
├────┼───────────────┼──────────────────┼───────┼──────────┤
│ 1  │ Bouteille 1L  │ BTL-1L-CLASSIC   │ 100   │ 10       │
└────┴───────────────┴──────────────────┴───────┴──────────┘

Données réellement insérées (MAUVAIS) :
┌────┬───────────────┬──────────────────────┬──────────┬──────┐
│ id │ name          │ reference ???        │ stock ❌ │ ...  │
├────┼───────────────┼──────────────────────┼──────────┼──────┤
│ 1  │ Bouteille 1L  │ ???                  │ BTL-... │ ...  │
└────┴───────────────┴──────────────────────┴──────────┴──────┘
```

**Résultat :** La colonne `stock` contient "BTL-025L-CLASSIC" (une référence) au lieu d'un nombre.

### Pourquoi la décrémentation ne fonctionne pas

Le code de synchronisation essaie de faire :
```php
$current_stock = (int) "BTL-025L-CLASSIC";  // = 0
$new_stock = 0 - 10;                         // = -10 → devient 0
UPDATE products SET stock = 0 WHERE id = 1;
```

Mais comme la colonne contient du texte, l'UPDATE échoue ou ne produit pas l'effet attendu.

---

## Solution : Corriger les données

### Étape 1 : Diagnostiquer le problème

Accédez au script de diagnostic :
```
https://votre-site.com/diagnostic_stock_decrement.php
```

Ce script va afficher :
- ✅ La connexion à la base de données
- ✅ Les colonnes résolues
- ✅ L'état de chaque produit
- ✅ Le TYPE de données dans la colonne stock

**Résultat attendu :** Vous verrez des ❌ rouges si la colonne stock contient du texte.

### Étape 2 : Exécuter le script de correction

#### Via phpMyAdmin

1. Allez sur https://phpmyadmin.hosting-data.io/
2. Connectez-vous
3. Sélectionnez la base `dbs1363734`
4. Onglet "SQL"
5. Copiez-collez le contenu du fichier **`fix_products_columns.sql`**
6. Cliquez sur "Exécuter"

#### Via ligne de commande

```bash
mysql -h db5001643902.hosting-data.io -u dbu1662343 -p dbs1363734 < fix_products_columns.sql
```

### Étape 3 : Vérifier la correction

1. **Retournez sur le script de diagnostic** : `diagnostic_stock_decrement.php`
2. **Rafraîchissez la page**
3. **Vérifiez que** :
   - La colonne "Stock (valeur brute)" contient des **NOMBRES** (ex: 100, 80, 60)
   - La colonne "Type de stock" affiche "integer ✅"
   - Le test de simulation montre "✅ UPDATE réussi"

4. **Ou vérifiez via SQL** :

```sql
SELECT id, name, reference, stock
FROM products
WHERE id BETWEEN 1 AND 14
ORDER BY id;
```

**Résultat attendu :**

| id | name | reference | stock |
|----|------|-----------|-------|
| 1 | Bouteille 1L | BTL-1L-CLASSIC | **100** ← NOMBRE |
| 2 | Bouteille 0,5L | BTL-05L-CLASSIC | **80** ← NOMBRE |
| ... | ... | ... | ... |

### Étape 4 : Tester une commande

1. Allez sur le formulaire de commande
2. Commandez **1 Bouteille 1L**
3. Validez la commande
4. **Allez dans StockPilot** → Onglet "Produits"
5. **Vérifiez que le stock de "Bouteille 1L" est maintenant 99** ✅

### Étape 5 : Vérifier les mouvements

1. Dans StockPilot → Onglet "Mouvements"
2. Vous devriez voir un mouvement avec :
   - Type : OUT (sortie)
   - Produit : Bouteille 1L
   - Quantité : 1
   - Ancien stock : 100
   - Nouveau stock : 99
   - Motif : Commande Express CMD-...

---

## Pourquoi cela s'est produit

Le script initial `add_order_form_products.sql` contenait probablement une erreur de syntaxe ou de séquence qui a causé un décalage des valeurs lors de l'INSERT.

Causes possibles :
1. Ordre des colonnes différent dans la vraie base vs le fichier SQL de référence
2. Colonnes manquantes ou supplémentaires
3. Problème d'encodage ou de guillemets
4. Exécution partielle du script (erreur non détectée)

---

## Script de correction détaillé

Le script `fix_products_columns.sql` fait :

1. **Supprime** les produits IDs 1-14 (données incorrectes)
2. **Réinsère** les produits avec les bonnes valeurs dans les bonnes colonnes
3. **Définit des stocks initiaux** (100 pour Bouteille 1L, 80 pour 0,5L, etc.)
4. **Affiche une requête de vérification** pour confirmer que tout est bon

---

## Ajustement des stocks initiaux

Si les quantités de stock par défaut (100, 80, 60...) ne correspondent pas à votre inventaire réel, modifiez-les :

### Option A : Via StockPilot (interface graphique)

1. Allez dans StockPilot → Onglet "Produits"
2. Cliquez sur "Modifier" pour chaque produit
3. Changez le stock
4. Sauvegardez

### Option B : Via SQL (plus rapide)

```sql
-- Ajuster les stocks selon votre inventaire réel
UPDATE products SET stock = 150 WHERE id = 1;  -- Bouteille 1L
UPDATE products SET stock = 120 WHERE id = 2;  -- Bouteille 0,5L
UPDATE products SET stock = 80 WHERE id = 3;   -- Bouteille 0,33L
UPDATE products SET stock = 50 WHERE id = 4;   -- Bouteille 0,25L
UPDATE products SET stock = 40 WHERE id = 5;   -- Bouteille 1L Bio
UPDATE products SET stock = 30 WHERE id = 6;   -- Bouteille 0,5L Bio
UPDATE products SET stock = 20 WHERE id = 7;   -- Bouteille 0,25L Bio
UPDATE products SET stock = 15 WHERE id = 8;   -- LE FRISSON
UPDATE products SET stock = 15 WHERE id = 9;   -- LE TENDRE
UPDATE products SET stock = 10 WHERE id = 10;  -- L'AIMABLE
UPDATE products SET stock = 10 WHERE id = 11;  -- L'EXOTIK
UPDATE products SET stock = 10 WHERE id = 12;  -- LE TONIK
UPDATE products SET stock = 25 WHERE id = 13;  -- Gobelets
UPDATE products SET stock = 8 WHERE id = 14;   -- Nettoyant
```

---

## Vérification finale

### Checklist complète

- [ ] Script `fix_products_columns.sql` exécuté
- [ ] Script de diagnostic affiche des stocks numériques ✅
- [ ] Commande test passée
- [ ] Stock diminué dans StockPilot après la commande
- [ ] Mouvement de stock enregistré correctement
- [ ] Stocks initiaux ajustés selon inventaire réel

---

## Dépannage

### Le stock ne diminue toujours pas

1. **Vérifiez les logs PHP** : `/wp-content/debug.log`
   - Recherchez : `[Sempa]` ou `[Sempa Order]`

2. **Activez le mode debug WordPress** (`wp-config.php`) :
   ```php
   define('WP_DEBUG', true);
   define('WP_DEBUG_LOG', true);
   define('WP_DEBUG_DISPLAY', false);
   ```

3. **Vérifiez que la bonne base est utilisée** :
   - Dans `includes/db_connect_stocks.php` ligne 10
   - Host : `db5001643902.hosting-data.io`
   - Database : `dbs1363734`

4. **Testez manuellement l'UPDATE** :
   ```sql
   UPDATE products SET stock = stock - 1 WHERE id = 1;
   SELECT id, name, stock FROM products WHERE id = 1;
   -- Le stock doit avoir diminué de 1
   ```

### Les mouvements s'enregistrent mais pas les modifications de stock

- **Cause probable** : Les deux tables (`products` et `movements`) utilisent des connexions différentes
- **Solution** : Vérifiez que `Sempa_Stocks_DB::instance()` et `Sempa_Order_Manager::instance()` pointent vers la même base

---

## Prévention

Pour éviter ce problème à l'avenir :

1. **Toujours vérifier** la structure de la table avant un INSERT :
   ```sql
   DESCRIBE products;
   ```

2. **Utiliser des noms de colonnes explicites** dans les INSERT

3. **Tester avec un seul produit** d'abord avant d'insérer les 14

4. **Utiliser le script de diagnostic** après chaque modification de base

---

## Support

Si le problème persiste après avoir suivi toutes ces étapes :

1. Vérifiez que vous avez bien exécuté `fix_products_columns.sql`
2. Consultez le script de diagnostic : `diagnostic_stock_decrement.php`
3. Vérifiez les logs d'erreur PHP
4. Assurez-vous que la table `products` existe bien et contient des données

---

## Résumé rapide

```
1. Exécutez fix_products_columns.sql
2. Vérifiez avec diagnostic_stock_decrement.php
3. Testez une commande
4. Vérifiez que le stock a diminué
5. ✅ Terminé !
```
