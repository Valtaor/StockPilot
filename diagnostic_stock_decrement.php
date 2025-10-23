<?php
/**
 * Script de diagnostic - Décrémentation des stocks
 * Accéder via : https://votre-site.com/diagnostic_stock_decrement.php
 */

// Configuration minimale
define('ABSPATH', __DIR__ . '/');

// Charger wpdb
if (!class_exists('wpdb')) {
    class wpdb {
        public $dbh;
        public $last_error = '';

        public function __construct($dbuser, $dbpassword, $dbname, $dbhost, $dbport = 3306) {
            $this->dbh = @mysqli_connect($dbhost, $dbuser, $dbpassword, $dbname, $dbport);
            if (!$this->dbh) {
                $this->last_error = mysqli_connect_error();
            }
        }

        public function get_results($query, $output = OBJECT) {
            if (!$this->dbh) return false;
            $result = mysqli_query($this->dbh, $query);
            if (!$result) {
                $this->last_error = mysqli_error($this->dbh);
                return false;
            }
            $rows = [];
            while ($row = mysqli_fetch_assoc($result)) {
                $rows[] = (object)$row;
            }
            return $rows;
        }

        public function get_row($query, $output = OBJECT) {
            if (!$this->dbh) return null;
            $result = mysqli_query($this->dbh, $query);
            if (!$result) {
                $this->last_error = mysqli_error($this->dbh);
                return null;
            }
            return (object)mysqli_fetch_assoc($result);
        }

        public function query($query) {
            if (!$this->dbh) return false;
            $result = mysqli_query($this->dbh, $query);
            if (!$result) {
                $this->last_error = mysqli_error($this->dbh);
                return false;
            }
            return $result;
        }

        public function update($table, $data, $where, $formats = null, $where_formats = null) {
            $sql = "UPDATE `$table` SET ";
            $sets = [];
            foreach ($data as $col => $val) {
                if (is_null($val)) {
                    $sets[] = "`$col` = NULL";
                } elseif (is_numeric($val)) {
                    $sets[] = "`$col` = $val";
                } else {
                    $val = mysqli_real_escape_string($this->dbh, $val);
                    $sets[] = "`$col` = '$val'";
                }
            }
            $sql .= implode(', ', $sets);

            $sql .= " WHERE ";
            $wheres = [];
            foreach ($where as $col => $val) {
                if (is_numeric($val)) {
                    $wheres[] = "`$col` = $val";
                } else {
                    $val = mysqli_real_escape_string($this->dbh, $val);
                    $wheres[] = "`$col` = '$val'";
                }
            }
            $sql .= implode(' AND ', $wheres);

            return $this->query($sql);
        }
    }
}

require_once __DIR__ . '/includes/db_connect_stocks.php';

echo "<html><head><meta charset='UTF-8'><title>Diagnostic Stock</title>";
echo "<style>body{font-family:monospace;margin:20px;} table{border-collapse:collapse;margin:20px 0;} th,td{border:1px solid #ddd;padding:8px;text-align:left;} th{background:#f4a412;color:white;} .error{color:red;} .success{color:green;} .warning{color:orange;}</style>";
echo "</head><body>";

echo "<h1>🔍 Diagnostic - Décrémentation des Stocks</h1>";

// Test 1 : Connexion à la base
echo "<h2>1. Test de connexion</h2>";
try {
    $db = Sempa_Stocks_DB::instance();
    if ($db instanceof wpdb && !empty($db->dbh)) {
        echo "<p class='success'>✅ Connexion établie</p>";
    } else {
        echo "<p class='error'>❌ Connexion échouée</p>";
        die();
    }
} catch (Throwable $e) {
    echo "<p class='error'>❌ Exception: " . htmlspecialchars($e->getMessage()) . "</p>";
    die();
}

// Test 2 : Trouver la table
echo "<h2>2. Résolution de la table 'stocks_sempa'</h2>";
$table = Sempa_Stocks_DB::table('stocks_sempa');
echo "<p>Table résolue : <strong>" . htmlspecialchars($table) . "</strong></p>";

// Test 3 : Résolution des colonnes
echo "<h2>3. Résolution des colonnes</h2>";
$id_column = Sempa_Stocks_DB::resolve_column('stocks_sempa', 'id', false);
$stock_column = Sempa_Stocks_DB::resolve_column('stocks_sempa', 'stock_actuel', false);
$name_column = Sempa_Stocks_DB::resolve_column('stocks_sempa', 'designation', false);

echo "<ul>";
echo "<li>Colonne ID : <strong>" . ($id_column ?: "❌ NON TROUVÉE") . "</strong></li>";
echo "<li>Colonne Stock : <strong>" . ($stock_column ?: "❌ NON TROUVÉE") . "</strong></li>";
echo "<li>Colonne Nom : <strong>" . ($name_column ?: "❌ NON TROUVÉE") . "</strong></li>";
echo "</ul>";

if (!$stock_column) {
    echo "<p class='error'>❌ PROBLÈME : La colonne de stock n'a pas pu être résolue !</p>";
}

// Test 4 : Afficher les produits IDs 1-14
echo "<h2>4. État des produits (IDs 1-14)</h2>";
$products = $db->get_results("SELECT * FROM `$table` WHERE `$id_column` BETWEEN 1 AND 14 ORDER BY `$id_column`");

if ($products) {
    echo "<table>";
    echo "<tr><th>ID</th><th>Nom</th><th>Référence</th><th>Stock (valeur brute)</th><th>Type de stock</th><th>Stock (int)</th></tr>";

    foreach ($products as $product) {
        $stock_value = $product->{$stock_column} ?? 'N/A';
        $stock_type = gettype($stock_value);
        $stock_int = (int)$stock_value;

        $is_number = is_numeric($stock_value);
        $row_class = $is_number ? 'success' : 'error';

        echo "<tr class='$row_class'>";
        echo "<td>" . htmlspecialchars($product->{$id_column}) . "</td>";
        echo "<td>" . htmlspecialchars($product->{$name_column} ?? 'N/A') . "</td>";
        echo "<td>" . htmlspecialchars($product->reference ?? 'N/A') . "</td>";
        echo "<td>" . htmlspecialchars($stock_value) . "</td>";
        echo "<td>" . $stock_type . ($is_number ? " ✅" : " ❌") . "</td>";
        echo "<td>" . $stock_int . "</td>";
        echo "</tr>";
    }

    echo "</table>";

    echo "<p class='warning'>⚠️ Si la colonne 'Stock (valeur brute)' contient du TEXTE (ex: BTL-025L-CLASSIC), ";
    echo "c'est le problème ! Les données ont été mal insérées.</p>";
} else {
    echo "<p class='error'>❌ Aucun produit trouvé ou erreur SQL: " . htmlspecialchars($db->last_error) . "</p>";
}

// Test 5 : Simuler une décrémentation
echo "<h2>5. Test de décrémentation (simulation)</h2>";
echo "<p><strong>Produit ID 1</strong> - Essai de décrémentation de 1 unité :</p>";

$product = $db->get_row("SELECT * FROM `$table` WHERE `$id_column` = 1");

if ($product) {
    $current_stock = $product->{$stock_column} ?? 0;
    echo "<p>Stock actuel (brut) : <code>" . htmlspecialchars($current_stock) . "</code></p>";
    echo "<p>Stock actuel (int) : <code>" . (int)$current_stock . "</code></p>";

    $is_numeric = is_numeric($current_stock);
    if (!$is_numeric) {
        echo "<p class='error'>❌ ERREUR : Le stock n'est PAS numérique ! C'est pour ça que la décrémentation ne fonctionne pas.</p>";
        echo "<p><strong>Solution :</strong> Exécutez le script <code>fix_products_columns.sql</code> pour corriger les données.</p>";
    } else {
        $new_stock = (int)$current_stock - 1;

        echo "<p>Nouveau stock (calculé) : <code>$new_stock</code></p>";

        // Essayer l'UPDATE
        echo "<p>Tentative d'UPDATE...</p>";
        $result = $db->update(
            $table,
            [$stock_column => $new_stock],
            [$id_column => 1],
            ['%d'],
            ['%d']
        );

        if ($result !== false) {
            echo "<p class='success'>✅ UPDATE réussi ! (Test uniquement - ne sera pas committé)</p>";

            // Rollback
            $db->update(
                $table,
                [$stock_column => $current_stock],
                [$id_column => 1],
                ['%d'],
                ['%d']
            );
            echo "<p class='success'>✅ Rollback effectué - aucune modification permanente</p>";
        } else {
            echo "<p class='error'>❌ UPDATE échoué : " . htmlspecialchars($db->last_error) . "</p>";
        }
    }
} else {
    echo "<p class='error'>❌ Produit ID 1 non trouvé</p>";
}

// Conclusion
echo "<h2>📊 Conclusion</h2>";
echo "<p>Si vous voyez des valeurs de stock contenant du TEXTE au lieu de NOMBRES :</p>";
echo "<ol>";
echo "<li>Exécutez le script <strong>fix_products_columns.sql</strong> dans phpMyAdmin</li>";
echo "<li>Revenez sur cette page pour vérifier que les stocks sont maintenant des nombres</li>";
echo "<li>Testez une commande en ligne</li>";
echo "<li>Vérifiez dans StockPilot que le stock a bien diminué</li>";
echo "</ol>";

echo "</body></html>";
