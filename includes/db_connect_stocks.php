<?php
if (!defined('ABSPATH')) {
    exit;
}

if (!class_exists('Sempa_Stocks_DB')) {
    final class Sempa_Stocks_DB
    {
        private const DB_HOST = 'db5001643902.hosting-data.io';
        private const DB_NAME = 'dbs1363734';
        private const DB_USER = 'dbu1662343';
        private const DB_PASSWORD = '14Juillet@';
        private const DB_PORT = 3306;

        private const TABLE_ALIASES = [
            'stocks_sempa' => ['stocks_sempa', 'stocks', 'products'],
            'mouvements_stocks_sempa' => ['mouvements_stocks_sempa', 'stock_movements', 'movements'],
            'categories_stocks' => ['categories_stocks', 'stock_categories', 'product_categories'],
            'fournisseurs_sempa' => ['fournisseurs_sempa', 'stock_suppliers', 'suppliers'],
        ];

        private const COLUMN_ALIASES = [
            'stocks_sempa' => [
                'id' => ['id'],
                'product_id' => ['id', 'product_id'],
                'designation' => ['designation', 'name', 'nom'],
                'name' => ['name', 'designation'],
                'reference' => ['reference', 'sku'],
                'stock' => ['stock', 'stock_actuel'],
                'stock_actuel' => ['stock_actuel', 'stock'],
                'stock_minimum' => ['stock_minimum', 'minstock', 'min_stock', 'minStock'],
                'stock_maximum' => ['stock_maximum', 'maxstock', 'max_stock', 'maxStock'],
                'prix_achat' => ['prix_achat', 'purchase_price', 'purchaseprice', 'purchasePrice'],
                'prix_vente' => ['prix_vente', 'sale_price', 'saleprice', 'salePrice'],
                'categorie' => ['categorie', 'category'],
                'fournisseur' => ['fournisseur', 'supplier', 'supplier_name'],
                'emplacement' => ['emplacement', 'location'],
                'date_entree' => ['date_entree', 'date_entree_stock', 'date_added', 'created_at'],
                'date_modification' => ['date_modification', 'modified', 'updated_at', 'lastUpdated'],
                'notes' => ['notes', 'description'],
                'document_pdf' => ['document_pdf', 'document', 'document_url', 'imageUrl'],
                'ajoute_par' => ['ajoute_par', 'added_by', 'created_by'],
                'prix_achat_total' => ['prix_achat_total', 'total_purchase'],
            ],
            'mouvements_stocks_sempa' => [
                'id' => ['id'],
                'produit_id' => ['produit_id', 'product_id', 'productId'],
                'product_id' => ['product_id', 'produit_id', 'productId'],
                'type' => ['type', 'movement_type', 'type_mouvement'],
                'type_mouvement' => ['type_mouvement', 'type', 'movement_type'],
                'quantite' => ['quantite', 'quantity'],
                'quantity' => ['quantity', 'quantite'],
                'ancien_stock' => ['ancien_stock', 'previous_stock', 'stock_before'],
                'nouveau_stock' => ['nouveau_stock', 'new_stock', 'stock_after'],
                'motif' => ['motif', 'reason'],
                'utilisateur' => ['utilisateur', 'user', 'user_name'],
                'date_mouvement' => ['date_mouvement', 'date', 'created_at'],
            ],
            'categories_stocks' => [
                'id' => ['id'],
                'nom' => ['nom', 'name'],
                'couleur' => ['couleur', 'color', 'colour'],
                'icone' => ['icone', 'icon'],
            ],
            'fournisseurs_sempa' => [
                'id' => ['id'],
                'nom' => ['nom', 'name'],
                'contact' => ['contact', 'contact_name'],
                'telephone' => ['telephone', 'phone', 'phone_number'],
                'email' => ['email'],
            ],
        ];

        private static $instance = null;
        private static $table_cache = [];
        private static $columns_cache = [];

        public static function instance()
        {
            if (self::$instance instanceof \wpdb) {
                return self::$instance;
            }

            require_once ABSPATH . 'wp-includes/wp-db.php';

            $wpdb = new \wpdb(self::DB_USER, self::DB_PASSWORD, self::DB_NAME, self::DB_HOST, self::DB_PORT);
            $wpdb->show_errors(false);
            if (!empty($wpdb->dbh)) {
                $wpdb->set_charset($wpdb->dbh, 'utf8mb4');
            }

            self::$instance = $wpdb;

            return self::$instance;
        }

        public static function table(string $name)
        {
            $key = strtolower($name);

            if (array_key_exists($key, self::$table_cache)) {
                $cached = self::$table_cache[$key];

                return $cached !== false ? $cached : $name;
            }

            try {
                $db = self::instance();
            } catch (\Throwable $exception) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Unable to resolve table ' . $name . ': ' . $exception->getMessage());
                }

                self::$table_cache[$key] = false;

                return $name;
            }

            if (!($db instanceof \wpdb) || empty($db->dbh)) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Database connection not established when resolving table ' . $name);
                }

                self::$table_cache[$key] = false;

                return $name;
            }

            $candidates = self::TABLE_ALIASES[$key] ?? [$name];

            foreach ($candidates as $candidate) {
                $candidate = trim((string) $candidate);

                if ($candidate === '') {
                    continue;
                }

                $found = $db->get_var($db->prepare('SHOW TABLES LIKE %s', $candidate));
                if (!empty($found)) {
                    self::$table_cache[$key] = $found;

                    return $found;
                }
            }

            self::$table_cache[$key] = false;

            return $name;
        }

        public static function escape_identifier(string $identifier): string
        {
            $parts = array_filter(array_map('trim', explode('.', $identifier)));

            if (empty($parts)) {
                return '``';
            }

            $escaped = [];

            foreach ($parts as $part) {
                $clean = preg_replace('/[^A-Za-z0-9_]/', '', $part);
                if ($clean === '') {
                    continue;
                }

                $escaped[] = '`' . $clean . '`';
            }

            if (empty($escaped)) {
                return '``';
            }

            return implode('.', $escaped);
        }

        public static function resolve_column(string $table, string $column, bool $fallback = true)
        {
            $table_key = strtolower($table);
            $column_key = strtolower($column);

            $candidates = [];

            if (isset(self::COLUMN_ALIASES[$table_key][$column_key])) {
                $mapped = self::COLUMN_ALIASES[$table_key][$column_key];
                $candidates = is_array($mapped) ? $mapped : [$mapped];
            }

            $actual_table = self::table($table);
            $columns = self::get_table_columns($actual_table);

            foreach ($candidates as $candidate) {
                $candidate = (string) $candidate;
                if ($candidate === '') {
                    continue;
                }

                if (in_array(strtolower($candidate), $columns, true)) {
                    return $candidate;
                }
            }

            if (in_array($column_key, $columns, true)) {
                return $column;
            }

            return $fallback ? $column : null;
        }

        public static function value($row, string $table, string $column, $default = null)
        {
            if (is_object($row)) {
                $row = (array) $row;
            }

            if (!is_array($row)) {
                return $default;
            }

            $table_key = strtolower($table);
            $column_key = strtolower($column);

            $candidates = [];

            $resolved = self::resolve_column($table, $column, false);
            if ($resolved !== null) {
                $candidates[] = $resolved;
            }

            if (isset(self::COLUMN_ALIASES[$table_key][$column_key])) {
                $mapped = self::COLUMN_ALIASES[$table_key][$column_key];
                $mapped = is_array($mapped) ? $mapped : [$mapped];
                foreach ($mapped as $candidate) {
                    if ($candidate !== null && $candidate !== '') {
                        $candidates[] = $candidate;
                    }
                }
            }

            $candidates[] = $column;

            $checked = [];

            foreach ($candidates as $candidate) {
                $candidate_key = strtolower((string) $candidate);

                if ($candidate_key === '') {
                    continue;
                }

                if (in_array($candidate_key, $checked, true)) {
                    continue;
                }

                $checked[] = $candidate_key;

                foreach ($row as $key => $value) {
                    if (strcasecmp((string) $key, $candidate) === 0) {
                        return $value;
                    }
                }
            }

            return $default;
        }

        public static function normalize_columns(string $table, array $data): array
        {
            $normalized = [];

            foreach ($data as $column => $value) {
                $resolved = self::resolve_column($table, (string) $column, false);

                if ($resolved !== null) {
                    $normalized[$resolved] = $value;
                    continue;
                }

                $actual_table = self::table($table);
                $columns = self::get_table_columns($actual_table);
                $column_key = strtolower((string) $column);

                if (in_array($column_key, $columns, true)) {
                    $normalized[$column] = $value;
                }
            }

            return $normalized;
        }

        public static function table_exists(string $name): bool
        {
            $key = strtolower($name);

            if (!array_key_exists($key, self::$table_cache)) {
                self::table($name);
            }

            return !empty(self::$table_cache[$key]);
        }

        /**
         * Clear all internal caches (table names and column names)
         * Useful after creating or modifying tables
         */
        public static function clear_cache(): void
        {
            self::$table_cache = [];
            self::$columns_cache = [];
        }

        private static function get_table_columns(string $table): array
        {
            $table_key = strtolower($table);

            if (isset(self::$columns_cache[$table_key])) {
                return self::$columns_cache[$table_key];
            }

            if ($table === '' || $table === null) {
                self::$columns_cache[$table_key] = [];

                return [];
            }

            $columns = [];

            try {
                $db = self::instance();
            } catch (\Throwable $exception) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Unable to inspect table columns for ' . $table . ': ' . $exception->getMessage());
                }

                self::$columns_cache[$table_key] = [];

                return [];
            }

            if (!($db instanceof \wpdb) || empty($db->dbh)) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Database connection not established when inspecting columns for ' . $table);
                }

                self::$columns_cache[$table_key] = [];

                return [];
            }

            try {
                $results = $db->get_results('SHOW COLUMNS FROM ' . self::escape_identifier($table));

                if (is_array($results)) {
                    foreach ($results as $column) {
                        if (isset($column->Field)) {
                            $columns[] = strtolower((string) $column->Field);
                        }
                    }
                }
            } catch (\Throwable $exception) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Unable to fetch columns for ' . $table . ': ' . $exception->getMessage());
                }
            }

            self::$columns_cache[$table_key] = $columns;

            return $columns;
        }
    }
}
