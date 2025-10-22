<?php
if (!defined('ABSPATH')) {
    exit;
}

if (!class_exists('Sempa_Stocks_Schema_Setup')) {
    final class Sempa_Stocks_Schema_Setup
    {
        /**
         * Ensure all required tables exist in the database
         * This function will create missing tables automatically
         */
        public static function ensure_schema()
        {
            try {
                self::ensure_suppliers_table();
                self::ensure_products_supplier_column();
            } catch (\Throwable $exception) {
                if (function_exists('error_log')) {
                    error_log('[Sempa] Schema setup error: ' . $exception->getMessage());
                }
            }
        }

        /**
         * Create the suppliers table if it doesn't exist
         */
        private static function ensure_suppliers_table()
        {
            $db = Sempa_Stocks_DB::instance();

            if (!($db instanceof \wpdb) || empty($db->dbh)) {
                error_log('[Sempa] Cannot create suppliers table: database connection not available');
                return false;
            }

            // Check if table already exists using any of the aliases
            if (Sempa_Stocks_DB::table_exists('fournisseurs_sempa')) {
                return true; // Table already exists
            }

            // Create the suppliers table
            $sql = "CREATE TABLE IF NOT EXISTS `suppliers` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `nom` varchar(255) NOT NULL COMMENT 'Nom du fournisseur',
                `contact` varchar(255) DEFAULT NULL COMMENT 'Personne de contact',
                `telephone` varchar(50) DEFAULT NULL COMMENT 'Numéro de téléphone',
                `email` varchar(255) DEFAULT NULL COMMENT 'Adresse email',
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
                `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date de modification',
                PRIMARY KEY (`id`),
                KEY `idx_nom` (`nom`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table des fournisseurs'";

            $result = $db->query($sql);

            if ($result === false) {
                error_log('[Sempa] Failed to create suppliers table: ' . $db->last_error);
                return false;
            }

            // Clear the table cache to force re-detection
            Sempa_Stocks_DB::clear_cache();

            error_log('[Sempa] Suppliers table created successfully');
            return true;
        }

        /**
         * Add supplier column to products table if it doesn't exist
         */
        private static function ensure_products_supplier_column()
        {
            $db = Sempa_Stocks_DB::instance();

            if (!($db instanceof \wpdb) || empty($db->dbh)) {
                return false;
            }

            $products_table = Sempa_Stocks_DB::table('stocks_sempa');
            if (empty($products_table)) {
                return false;
            }

            // Check if supplier column already exists
            $columns = $db->get_results("SHOW COLUMNS FROM " . Sempa_Stocks_DB::escape_identifier($products_table) . " LIKE 'supplier'");

            if (!empty($columns)) {
                return true; // Column already exists
            }

            // Add supplier column
            $sql = "ALTER TABLE " . Sempa_Stocks_DB::escape_identifier($products_table) . "
                    ADD COLUMN `supplier` varchar(255) DEFAULT NULL COMMENT 'Nom du fournisseur' AFTER `category`";

            $result = $db->query($sql);

            if ($result === false) {
                error_log('[Sempa] Failed to add supplier column to products table: ' . $db->last_error);
                return false;
            }

            // Add index on supplier column
            $sql_index = "ALTER TABLE " . Sempa_Stocks_DB::escape_identifier($products_table) . "
                         ADD INDEX `idx_supplier` (`supplier`)";

            $db->query($sql_index); // Index creation can fail if it already exists, don't check result

            error_log('[Sempa] Supplier column added to products table successfully');
            return true;
        }
    }
}
