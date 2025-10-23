# Problème : Produits du formulaire de commande manquants

## Erreur rencontrée

```
Impossible de soumettre la commande : Le produit "#1" est introuvable dans la base des stocks.
```

## Cause du problème

Les **produits du formulaire de commande** (Bouteilles, Smoothies, Gobelets, Nettoyant) n'existent **PAS** dans la table `products` de votre base de données.

### État actuel

- **IDs 1-14** dans la table `products` : Pièces détachées (AIMANT, BASE INOX, etc.)
- **IDs 1-14** dans le formulaire `commande-express.php` : Bouteilles, Smoothies, etc.

**→ Conflit d'IDs ! Le formulaire référence des produits qui n'existent pas.**

### Preuve

Dans votre table `movements`, on voit des commandes passées avec :
- `productId: 1` → "Bouteille 1L"
- `productId: 2` → "Bouteille 0,5L"
- `productId: 8` → "LE FRISSON (1 carton)"

Ces produits ont existé à un moment mais ne sont plus dans la table `products`.

## Solution 1 : Insérer les produits manquants (RECOMMANDÉ)

### Étape 1 : Sauvegarder les pièces détachées

Si vous voulez conserver les pièces détachées actuellement dans les IDs 1-14, le script SQL les déplacera automatiquement vers les IDs 501-514.

### Étape 2 : Exécuter le script SQL

#### Via phpMyAdmin

1. Connectez-vous à phpMyAdmin : https://phpmyadmin.hosting-data.io/
2. Sélectionnez la base de données `dbs1363734`
3. Cliquez sur l'onglet "SQL"
4. Copiez-collez le contenu du fichier **`add_order_form_products.sql`**
5. Cliquez sur "Exécuter"

#### Via ligne de commande MySQL

```bash
mysql -h db5001643902.hosting-data.io -u dbu1662343 -p dbs1363734 < add_order_form_products.sql
```

Mot de passe : `14Juillet@`

### Étape 3 : Vérifier l'insertion

Exécutez cette requête SQL pour vérifier :

```sql
SELECT id, name, reference, stock, salePrice
FROM products
WHERE id BETWEEN 1 AND 14
ORDER BY id;
```

Vous devriez voir :

| id | name | reference | stock | salePrice |
|----|------|-----------|-------|-----------|
| 1 | Bouteille 1L | BTL-1L-CLASSIC | 0 | 22.62 |
| 2 | Bouteille 0,5L | BTL-05L-CLASSIC | 0 | 51.84 |
| 3 | Bouteille 0,33L | BTL-033L-CLASSIC | 0 | 60.06 |
| ... | ... | ... | ... | ... |

### Étape 4 : Ajuster les stocks initiaux

Les produits sont créés avec un stock de 0. Pour ajouter du stock :

**Option A : Via StockPilot**
1. Allez dans StockPilot → Onglet "Produits"
2. Modifiez chaque produit pour définir le stock initial
3. Les stocks initiaux seront maintenant visibles

**Option B : Via SQL**

```sql
UPDATE products SET stock = 100 WHERE id = 1;  -- 100 cartons de Bouteille 1L
UPDATE products SET stock = 50 WHERE id = 2;   -- 50 cartons de Bouteille 0,5L
-- etc.
```

### Étape 5 : Tester une commande

1. Retournez sur le formulaire de commande
2. Remplissez le formulaire
3. Commandez au moins un produit
4. **Résultat attendu :**
   - ✅ Commande confirmée
   - ✅ Stock décrémenté dans StockPilot
   - ✅ Mouvement enregistré

## Solution 2 : Désactiver la synchronisation des stocks

Si vous ne voulez **PAS** gérer le stock de ces produits dans StockPilot, vous pouvez désactiver la synchronisation :

### Modifier `includes/db_commandes.php`

Commentez les lignes 98-112 :

```php
// Sync stock using Sempa_Order_Stock_Sync
/*
if (class_exists('Sempa_Order_Stock_Sync')) {
    $context = [
        'order_id' => $order_id,
        'order_number' => $order_reference,
        'order_date' => $data['date_commande'] ?? date('Y-m-d'),
        'client_name' => $data['nom_societe'] ?? '',
        'client_email' => $data['email'] ?? '',
    ];

    $sync_result = Sempa_Order_Stock_Sync::sync($data['produits'] ?? [], $context);

    if (is_wp_error($sync_result)) {
        throw new \Exception($sync_result->get_error_message());
    }
}
*/
```

**Inconvénients :**
- ❌ Pas de décrémentation automatique du stock
- ❌ Pas de traçabilité des mouvements
- ❌ Gestion manuelle nécessaire

## Solution 3 : Modifier les IDs du formulaire

Si vous voulez garder les pièces détachées aux IDs 1-14, modifiez les `dbId` dans le formulaire pour utiliser des IDs libres (par exemple 1001-1014).

### Modifier `commande-express.php` ligne 197-202

```javascript
classic: {
    title: "Bouteilles Classiques PET",
    items: [
        { id: 'c1', dbId: 1001, name: 'Bouteille 1L', ... },
        { id: 'c2', dbId: 1002, name: 'Bouteille 0,5L', ... },
        // etc.
    ]
}
```

Puis insérez les produits avec ces nouveaux IDs dans la base.

## Recommandation

**Solution 1** est la meilleure approche car :
- ✅ Synchronisation automatique fonctionnelle
- ✅ Traçabilité complète
- ✅ Gestion de stock intégrée
- ✅ Les pièces détachées sont préservées (déplacées vers IDs 501+)

## Que faire après ?

1. **Exécutez le script SQL** `add_order_form_products.sql`
2. **Définissez les stocks initiaux** pour chaque produit
3. **Testez une commande** pour vérifier que tout fonctionne
4. **Vérifiez dans StockPilot** que le stock a bien diminué

## Questions fréquentes

### Q : Vais-je perdre mes données de pièces détachées ?

**R :** Non, le script les déplace automatiquement vers les IDs 501-514. Elles resteront visibles dans StockPilot.

### Q : Que se passe-t-il si j'ai déjà des produits aux IDs 501+ ?

**R :** Modifiez le script SQL pour utiliser des IDs différents (par exemple 1001+) :
```sql
UPDATE products SET id = id + 1000 WHERE id BETWEEN 1 AND 14;
```

### Q : Puis-je supprimer les pièces détachées ?

**R :** Oui, si vous ne les utilisez pas. Modifiez le script et décommentez la ligne `DELETE` :
```sql
DELETE FROM products WHERE id BETWEEN 1 AND 14;
```

### Q : Les anciennes commandes fonctionneront-elles encore ?

**R :** Oui, les commandes déjà passées restent dans la table `commandes` avec leur historique intact.

## Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs PHP : `/wp-content/debug.log`
2. Recherchez les messages `[Sempa Order]` ou `[Sempa]`
3. Vérifiez que les produits existent bien avec `SELECT * FROM products WHERE id BETWEEN 1 AND 14;`
