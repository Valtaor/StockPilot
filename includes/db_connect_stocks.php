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

        private const COLUMN_ALIASES = [
            'stocks_sempa' => [
                'id' => 'id',
                'product_id' => 'id',
                'stock' => 'stock_actuel',
                'stock_actuel' => 'stock_actuel',
                'date_modification' => 'date_modification',
                'modified' => 'date_modification',
                'designation' => 'designation',
                'reference' => 'reference',
            ],
            'mouvements_stocks_sempa' => [
                'id' => 'id',
                'produit_id' => 'produit_id',
                'product_id' => 'produit_id',
                'type' => 'type_mouvement',
                'type_mouvement' => 'type_mouvement',
                'quantite' => 'quantite',
                'quantity' => 'quantite',
                'ancien_stock' => 'ancien_stock',
                'previous_stock' => 'ancien_stock',
                'nouveau_stock' => 'nouveau_stock',
                'new_stock' => 'nouveau_stock',
                'motif' => 'motif',
                'reason' => 'motif',
                'utilisateur' => 'utilisateur',
                'user' => 'utilisateur',
                'date_mouvement' => 'date_mouvement',
            ],
        ];

        private static $instance = null;

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

            if (isset(self::COLUMN_ALIASES[$table_key])) {
                $mapping = self::COLUMN_ALIASES[$table_key];

                if (isset($mapping[$column_key])) {
                    return $mapping[$column_key];
                }
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

            $resolved = self::resolve_column($table, $column, false);

            if ($resolved !== null) {
                foreach ($row as $key => $value) {
                    if (strcasecmp((string) $key, $resolved) === 0) {
                        return $value;
                    }
                }
            }

            if (array_key_exists($column, $row)) {
                return $row[$column];
            }

            return $default;
        }
    }
}
