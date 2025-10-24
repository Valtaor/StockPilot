<?php
/**
 * Script d'Import CSV de Produits pour StockPilot
 *
 * IMPORTANT : Ce script doit être exécuté une seule fois puis SUPPRIMÉ du serveur
 *
 * Utilisation :
 * 1. Uploadez votre fichier CSV nommé "produits_import.csv" dans le même dossier
 * 2. Accédez à : https://sempa.fr/wp-content/themes/sempa-child/import_csv_produits.php
 * 3. SUPPRIMEZ ce fichier après l'import !
 */

// Configuration de la base de données
define('DB_HOST', 'db5001643902.hosting-data.io');
define('DB_NAME', 'dbs1363734');
define('DB_USER', 'dbu1662343');
define('DB_PASSWORD', '14Juillet@');

// Sécurité : Limiter l'accès par IP (décommentez et ajustez si nécessaire)
// $allowed_ips = ['VOTRE_IP_ICI'];
// if (!in_array($_SERVER['REMOTE_ADDR'], $allowed_ips)) {
//     die('Accès refusé');
// }

// Nom du fichier CSV à importer
$csv_file = __DIR__ . '/produits_import.csv';

// Vérifier que le fichier existe
if (!file_exists($csv_file)) {
    die("❌ Erreur : Le fichier 'produits_import.csv' n'existe pas dans ce dossier.");
}

// Connexion à la base de données
try {
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASSWORD,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (PDOException $e) {
    die("❌ Erreur de connexion à la base de données : " . $e->getMessage());
}

echo "<!DOCTYPE html>
<html lang='fr'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Import CSV - StockPilot</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #f4a412;
            border-bottom: 3px solid #f4a412;
            padding-bottom: 10px;
        }
        .success { color: #0f9d58; }
        .error { color: #dc2626; }
        .warning { color: #f97316; }
        .info { color: #1f2937; }
        ul { list-style: none; padding: 0; }
        li { padding: 8px 0; border-bottom: 1px solid #eee; }
        .stats {
            background: #f4a41220;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class='container'>
        <h1>📦 Import CSV - StockPilot</h1>";

// Ouvrir le fichier CSV
$handle = fopen($csv_file, 'r');
if (!$handle) {
    die("❌ Erreur : Impossible d'ouvrir le fichier CSV.");
}

// Lire l'en-tête
$header = fgetcsv($handle, 0, ',');
if (!$header) {
    die("❌ Erreur : Le fichier CSV est vide ou mal formaté.");
}

echo "<p class='info'><strong>✅ Fichier CSV ouvert :</strong> " . basename($csv_file) . "</p>";
echo "<p class='info'><strong>📋 Colonnes détectées :</strong> " . implode(', ', $header) . "</p>";

// Préparer la requête d'insertion avec structure hiérarchique
$sql = "INSERT INTO `products` (
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
) VALUES (
    :name,
    :reference,
    :brand,
    :product_type,
    :model,
    :category,
    :stock,
    :minStock,
    :purchasePrice,
    :salePrice,
    :description
)";

$stmt = $pdo->prepare($sql);

// Compteurs
$success_count = 0;
$error_count = 0;
$errors = [];

echo "<h2>🔄 Import en cours...</h2>";
echo "<ul>";

// Lire chaque ligne
while (($row = fgetcsv($handle, 0, ',')) !== false) {
    // Convertir la ligne en tableau associatif
    $data = array_combine($header, $row);

    // Nettoyer les données
    $name = trim($data['name'] ?? '');
    $reference = trim($data['reference'] ?? '');
    $brand = trim($data['brand'] ?? '') ?: null;
    $product_type = trim($data['product_type'] ?? '') ?: null;
    $model = trim($data['model'] ?? '') ?: null;
    $stock = isset($data['stock']) ? (int)$data['stock'] : 0;
    $minStock = isset($data['minStock']) ? (int)$data['minStock'] : 1;
    $purchasePrice = isset($data['purchasePrice']) ? (float)$data['purchasePrice'] : 0.00;
    $salePrice = isset($data['salePrice']) ? (float)$data['salePrice'] : 0.00;
    $category = trim($data['category'] ?? 'autre');
    $description = trim($data['description'] ?? '') ?: null;

    // Vérifier que le nom n'est pas vide
    if (empty($name)) {
        $error_count++;
        $errors[] = "Ligne ignorée : nom vide (ref: $reference)";
        echo "<li class='warning'>⚠️ Ligne ignorée : nom vide</li>";
        continue;
    }

    try {
        // Insérer dans la base
        $stmt->execute([
            ':name' => $name,
            ':reference' => $reference,
            ':brand' => $brand,
            ':product_type' => $product_type,
            ':model' => $model,
            ':stock' => $stock,
            ':minStock' => $minStock,
            ':purchasePrice' => $purchasePrice,
            ':salePrice' => $salePrice,
            ':category' => $category,
            ':description' => $description,
        ]);

        $success_count++;
        echo "<li class='success'>✅ $name (ref: $reference)</li>";

    } catch (PDOException $e) {
        $error_count++;
        $errors[] = "Erreur pour '$name' : " . $e->getMessage();
        echo "<li class='error'>❌ Erreur : $name - " . $e->getMessage() . "</li>";
    }
}

echo "</ul>";

fclose($handle);

// Afficher les statistiques
echo "<div class='stats'>
    <h2>📊 Résultat de l'Import</h2>
    <p><strong class='success'>✅ Produits importés avec succès :</strong> $success_count</p>
    <p><strong class='error'>❌ Erreurs :</strong> $error_count</p>
</div>";

if (!empty($errors)) {
    echo "<h3 class='error'>Détails des erreurs :</h3><ul>";
    foreach ($errors as $error) {
        echo "<li class='error'>$error</li>";
    }
    echo "</ul>";
}

echo "<div class='warning' style='margin-top: 30px; padding: 20px; background: #fff3cd; border-left: 4px solid #f97316;'>
    <h3>⚠️ IMPORTANT : Sécurité</h3>
    <p><strong>SUPPRIMEZ immédiatement ce fichier (import_csv_produits.php) et le fichier CSV du serveur !</strong></p>
    <p>Ces fichiers représentent un risque de sécurité s'ils restent accessibles.</p>
</div>";

echo "<p style='margin-top: 30px; text-align: center;'>
    <a href='https://sempa.fr/stocks-pilot' style='
        display: inline-block;
        padding: 15px 30px;
        background: #f4a412;
        color: white;
        text-decoration: none;
        border-radius: 5px;
        font-weight: bold;
    '>Accéder à StockPilot →</a>
</p>";

echo "
    </div>
</body>
</html>";
