# Intégration Formulaire de Commande Express - StockPilot

## Problème résolu

L'erreur "aucune route correspondante à l'URL et à la méthode de requête n'a été trouvé" se produisait car :
- Le formulaire de commande `commande-express.php` essayait d'envoyer des données à `sempa/v1/commande`
- **Cette route REST API n'existait pas**

## Solution implémentée

### 1. Création de la route REST API (`includes/db_commandes.php`)

Création de la classe `Sempa_Order_Manager` qui :
- ✅ Enregistre la route REST API `POST /wp-json/sempa/v1/commande`
- ✅ Valide les données du formulaire (champs obligatoires, email, produits)
- ✅ Insère la commande dans la table `commandes`
- ✅ **Décrémente automatiquement les stocks** via `Sempa_Order_Stock_Sync`
- ✅ Utilise des transactions pour garantir l'intégrité des données
- ✅ Gère les erreurs et rollback en cas de problème

### 2. Synchronisation des stocks (`includes/functions_commandes.php`)

La classe `Sempa_Order_Stock_Sync` (déjà existante) gère :
- ✅ Décrémentation du stock pour chaque produit commandé
- ✅ Enregistrement des mouvements de stock dans `movements`
- ✅ Gestion des stocks insuffisants (ajustement à 0)
- ✅ Traçabilité complète (référence commande, client, date, etc.)

### 3. Intégration dans WordPress (`functions.php`)

- ✅ Chargement automatique de `db_commandes.php`
- ✅ Enregistrement de `Sempa_Order_Manager` dans `Sempa_App::boot()`

### 4. Corrections mineures

- ✅ Ajout de `'product_id'` dans la liste des clés recherchées pour l'ID produit

## Flux de traitement d'une commande

```
1. Client remplit le formulaire sur commande-express.php
2. Formulaire envoie POST à /wp-json/sempa/v1/commande
3. Sempa_Order_Manager::handle_order_submission() :
   a. Valide les données
   b. Démarre une transaction SQL
   c. Insère la commande dans table `commandes`
   d. Appelle Sempa_Order_Stock_Sync::sync() pour décrémenter les stocks
   e. Enregistre les mouvements de stock
   f. Commit la transaction
   g. Retourne la référence de commande (ex: CMD-20251023-42)
4. Front-end affiche la confirmation et envoie les emails
```

## Structure des données

### Données envoyées par le formulaire

```json
{
  "nom_societe": "Ma Société",
  "email": "contact@societe.fr",
  "telephone": "0123456789",
  "numero_client": "123456",
  "code_postal": "75001",
  "ville": "Paris",
  "date_commande": "2025-10-23",
  "produits": [
    {
      "product_id": 1,
      "product_name": "Bouteille 1L",
      "quantity": 10,
      "price": 22.62
    }
  ],
  "sous_total": 226.20,
  "frais_livraison": 49.95,
  "tva": 55.23,
  "total_ttc": 331.38,
  "instructions_speciales": "Livraison avant 10h",
  "confirmation_email": true
}
```

### Table `commandes`

| Colonne | Type | Description |
|---------|------|-------------|
| id | int(11) | ID auto-incrémenté |
| nom_societe | varchar(255) | Nom du client |
| email | varchar(255) | Email du client |
| telephone | varchar(50) | Téléphone |
| numero_client | varchar(100) | N° client (optionnel) |
| code_postal | varchar(20) | Code postal |
| ville | varchar(255) | Ville |
| date_commande | date | Date de la commande |
| details_produits | text | JSON des produits |
| sous_total | decimal(10,2) | Total HT |
| frais_livraison | decimal(10,2) | Frais de port |
| tva | decimal(10,2) | TVA |
| total_ttc | decimal(10,2) | Total TTC |
| instructions_speciales | text | Instructions |
| confirmation_email | tinyint(1) | Email de confirmation ? |
| date_creation | timestamp | Date création |

### Mouvements de stock enregistrés

Pour chaque produit commandé, un mouvement de stock est créé dans la table `movements` :

| Colonne | Valeur exemple |
|---------|----------------|
| productId | 1 |
| productName | Bouteille 1L |
| type | OUT |
| quantity | 10 |
| reason | Commande Express CMD-20251023-42 | 2025-10-23 | Ma Société | Bouteille 1L | Ref. 001 | Qté: 10 (stock 100 → 90) |
| date | 2025-10-23 14:30:00 |

## Test

### 1. Vérifier que la route existe

Accédez à : `https://votre-site.com/wp-json/sempa/v1/commande`

Vous devriez obtenir une erreur 405 (Method Not Allowed) car seul POST est accepté, ce qui confirme que la route existe.

### 2. Tester une commande

1. Accédez au formulaire de commande
2. Remplissez tous les champs obligatoires
3. Sélectionnez au moins un produit
4. Validez la commande

**Résultat attendu :**
- ✅ Message de confirmation affiché
- ✅ Nouvelle ligne dans table `commandes`
- ✅ Stocks décrémentés dans table `products`
- ✅ Mouvements enregistrés dans table `movements`
- ✅ Emails envoyés (client + admin)

### 3. Vérifier les stocks

Dans StockPilot :
1. Onglet "Produits" : vérifier que le stock a diminué
2. Onglet "Mouvements" : vérifier qu'un mouvement de type "OUT" a été créé avec la référence de la commande

## Fichiers modifiés

1. **`includes/db_commandes.php`** (création complète)
   - Classe `Sempa_Order_Manager`
   - Enregistrement route REST API
   - Logique de traitement des commandes

2. **`includes/functions_commandes.php`** (modification mineure)
   - Ajout de `'product_id'` dans `extract_product_id()`

3. **`functions.php`** (modifications)
   - Chargement de `db_commandes.php`
   - Enregistrement de `Sempa_Order_Manager`

## Sécurité

- ✅ Validation des données côté serveur
- ✅ Sanitization de toutes les entrées utilisateur
- ✅ Transactions SQL pour l'intégrité des données
- ✅ Rollback automatique en cas d'erreur
- ✅ Logs d'erreur pour le débogage
- ✅ Vérification des emails
- ✅ Protection contre les injections SQL (requêtes préparées)

## Débogage

En cas de problème, vérifier les logs PHP :
- `/wp-content/debug.log` (si WP_DEBUG activé)
- Logs serveur

Rechercher les messages contenant `[Sempa Order]` ou `[Sempa]`.

## API Endpoint

**URL:** `POST /wp-json/sempa/v1/commande`

**Headers:**
- `Content-Type: application/json`
- `X-WP-Nonce: <nonce>` (généré automatiquement par le formulaire)

**Réponse succès (200):**
```json
{
  "success": true,
  "message": "Commande enregistrée avec succès.",
  "orderRef": "CMD-20251023-42",
  "orderId": 42
}
```

**Réponse erreur (4xx/5xx):**
```json
{
  "code": "invalid_data",
  "message": "Le champ \"email\" est obligatoire.",
  "data": {
    "status": 400
  }
}
```
