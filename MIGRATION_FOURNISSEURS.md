# Migration : Création de la table des fournisseurs

## Problème identifié

L'erreur "la table des fournisseurs est indisponible" se produit car **la table des fournisseurs n'existe pas dans votre base de données**.

Le code de l'application s'attend à trouver une table pour gérer les fournisseurs, mais actuellement votre base de données ne contient que :
- `products`
- `product_categories`
- `movements`
- `commandes`
- `kit_components`
- `product_history`

## Solution

Il faut créer la table `suppliers` (fournisseurs) dans votre base de données.

## Instructions d'application de la migration

### Option 1 : Via phpMyAdmin (Recommandé)

1. Connectez-vous à phpMyAdmin : https://phpmyadmin.hosting-data.io/
2. Sélectionnez la base de données `dbs1363734`
3. Cliquez sur l'onglet "SQL"
4. Copiez-collez le contenu du fichier `create_suppliers_table.sql`
5. Cliquez sur "Exécuter"

### Option 2 : Via ligne de commande MySQL

Si vous avez accès à un terminal MySQL :

```bash
mysql -h db5001643902.hosting-data.io -u dbu1662343 -p dbs1363734 < create_suppliers_table.sql
```

Mot de passe : `14Juillet@`

### Option 3 : Via un client SQL

Si vous utilisez un client SQL (HeidiSQL, MySQL Workbench, DBeaver, etc.) :

1. Connectez-vous à la base de données avec les informations suivantes :
   - Hôte : `db5001643902.hosting-data.io`
   - Port : `3306`
   - Utilisateur : `dbu1662343`
   - Mot de passe : `14Juillet@`
   - Base de données : `dbs1363734`

2. Ouvrez le fichier `create_suppliers_table.sql`
3. Exécutez le script

## Que fait cette migration ?

1. **Crée la table `suppliers`** avec les colonnes suivantes :
   - `id` : Identifiant unique auto-incrémenté
   - `nom` : Nom du fournisseur (obligatoire)
   - `contact` : Personne de contact (optionnel)
   - `telephone` : Numéro de téléphone (optionnel)
   - `email` : Adresse email (optionnel)
   - `created_at` : Date de création automatique
   - `updated_at` : Date de modification automatique

2. **Ajoute la colonne `supplier`** à la table `products` pour lier les produits aux fournisseurs

3. **Insère un fournisseur par défaut** pour commencer

## Vérification

Après avoir appliqué la migration, vous pouvez vérifier que tout fonctionne :

1. Retournez sur votre application
2. Essayez d'ajouter un nouveau fournisseur
3. L'erreur "la table des fournisseurs est indisponible" ne devrait plus apparaître

## En cas de problème

Si vous obtenez toujours l'erreur après avoir appliqué la migration, vérifiez :

1. Que la table a bien été créée : `SHOW TABLES LIKE 'suppliers';`
2. Que la structure est correcte : `DESCRIBE suppliers;`
3. Les logs d'erreur PHP pour plus de détails

## Support

Si vous avez besoin d'aide, n'hésitez pas à demander !
