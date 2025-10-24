<?php
/**
 * Gestion des Données de Référence (Brands, Product Types, Models)
 *
 * Handlers AJAX pour gérer les marques, types de produits et modèles
 */

if (!defined('ABSPATH')) {
    exit;
}

final class Sempa_Reference_Data
{
    private const NONCE_ACTION = 'sempa_reference_data_nonce';

    public static function register()
    {
        // Hooks AJAX pour brands
        add_action('wp_ajax_sempa_get_brands', [__CLASS__, 'ajax_get_brands']);
        add_action('wp_ajax_sempa_save_brand', [__CLASS__, 'ajax_save_brand']);
        add_action('wp_ajax_sempa_delete_brand', [__CLASS__, 'ajax_delete_brand']);

        // Hooks AJAX pour product types
        add_action('wp_ajax_sempa_get_product_types', [__CLASS__, 'ajax_get_product_types']);
        add_action('wp_ajax_sempa_save_product_type', [__CLASS__, 'ajax_save_product_type']);
        add_action('wp_ajax_sempa_delete_product_type', [__CLASS__, 'ajax_delete_product_type']);

        // Hooks AJAX pour models
        add_action('wp_ajax_sempa_get_models', [__CLASS__, 'ajax_get_models']);
        add_action('wp_ajax_sempa_save_model', [__CLASS__, 'ajax_save_model']);
        add_action('wp_ajax_sempa_delete_model', [__CLASS__, 'ajax_delete_model']);
    }

    // ============================================
    // BRANDS (Marques)
    // ============================================

    public static function ajax_get_brands()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $db = Sempa_Stocks_DB::instance();
        $brands = $db->get_results("SELECT * FROM `brands` WHERE `active` = 1 ORDER BY `name` ASC", ARRAY_A);

        wp_send_json_success(['brands' => $brands ?: []]);
    }

    public static function ajax_save_brand()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;
        $name = isset($_POST['name']) ? sanitize_text_field(trim($_POST['name'])) : '';
        $logo_url = isset($_POST['logo_url']) ? esc_url_raw(trim($_POST['logo_url'])) : null;
        $description = isset($_POST['description']) ? sanitize_textarea_field(trim($_POST['description'])) : null;

        if (empty($name)) {
            wp_send_json_error(['message' => __('Le nom est obligatoire.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        if ($id > 0) {
            // Mise à jour
            $result = $db->update(
                'brands',
                [
                    'name' => $name,
                    'logo_url' => $logo_url,
                    'description' => $description,
                ],
                ['id' => $id],
                ['%s', '%s', '%s'],
                ['%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la mise à jour.', 'sempa')], 500);
            }

            $brand = $db->get_row($db->prepare("SELECT * FROM `brands` WHERE `id` = %d", $id), ARRAY_A);
        } else {
            // Création
            $result = $db->insert(
                'brands',
                [
                    'name' => $name,
                    'logo_url' => $logo_url,
                    'description' => $description,
                    'active' => 1,
                ],
                ['%s', '%s', '%s', '%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la création.', 'sempa')], 500);
            }

            $brand = $db->get_row($db->prepare("SELECT * FROM `brands` WHERE `id` = %d", $db->insert_id), ARRAY_A);
        }

        wp_send_json_success(['brand' => $brand, 'message' => __('Marque enregistrée.', 'sempa')]);
    }

    public static function ajax_delete_brand()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;

        if ($id <= 0) {
            wp_send_json_error(['message' => __('ID invalide.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        // Soft delete: marquer comme inactif
        $result = $db->update(
            'brands',
            ['active' => 0],
            ['id' => $id],
            ['%d'],
            ['%d']
        );

        if ($result === false) {
            wp_send_json_error(['message' => __('Erreur lors de la suppression.', 'sempa')], 500);
        }

        wp_send_json_success(['message' => __('Marque supprimée.', 'sempa')]);
    }

    // ============================================
    // PRODUCT TYPES (Types de Produits)
    // ============================================

    public static function ajax_get_product_types()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $db = Sempa_Stocks_DB::instance();
        $product_types = $db->get_results("SELECT * FROM `product_types` WHERE `active` = 1 ORDER BY `name` ASC", ARRAY_A);

        wp_send_json_success(['product_types' => $product_types ?: []]);
    }

    public static function ajax_save_product_type()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;
        $name = isset($_POST['name']) ? sanitize_text_field(trim($_POST['name'])) : '';
        $icon = isset($_POST['icon']) ? sanitize_text_field(trim($_POST['icon'])) : null;
        $description = isset($_POST['description']) ? sanitize_textarea_field(trim($_POST['description'])) : null;

        if (empty($name)) {
            wp_send_json_error(['message' => __('Le nom est obligatoire.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        if ($id > 0) {
            // Mise à jour
            $result = $db->update(
                'product_types',
                [
                    'name' => $name,
                    'icon' => $icon,
                    'description' => $description,
                ],
                ['id' => $id],
                ['%s', '%s', '%s'],
                ['%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la mise à jour.', 'sempa')], 500);
            }

            $product_type = $db->get_row($db->prepare("SELECT * FROM `product_types` WHERE `id` = %d", $id), ARRAY_A);
        } else {
            // Création
            $result = $db->insert(
                'product_types',
                [
                    'name' => $name,
                    'icon' => $icon,
                    'description' => $description,
                    'active' => 1,
                ],
                ['%s', '%s', '%s', '%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la création.', 'sempa')], 500);
            }

            $product_type = $db->get_row($db->prepare("SELECT * FROM `product_types` WHERE `id` = %d", $db->insert_id), ARRAY_A);
        }

        wp_send_json_success(['product_type' => $product_type, 'message' => __('Type enregistré.', 'sempa')]);
    }

    public static function ajax_delete_product_type()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;

        if ($id <= 0) {
            wp_send_json_error(['message' => __('ID invalide.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        // Soft delete
        $result = $db->update(
            'product_types',
            ['active' => 0],
            ['id' => $id],
            ['%d'],
            ['%d']
        );

        if ($result === false) {
            wp_send_json_error(['message' => __('Erreur lors de la suppression.', 'sempa')], 500);
        }

        wp_send_json_success(['message' => __('Type supprimé.', 'sempa')]);
    }

    // ============================================
    // MODELS (Modèles)
    // ============================================

    public static function ajax_get_models()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $brand_id = isset($_GET['brand_id']) ? intval($_GET['brand_id']) : 0;

        $db = Sempa_Stocks_DB::instance();

        if ($brand_id > 0) {
            // Modèles pour une marque spécifique
            $models = $db->get_results($db->prepare(
                "SELECT m.*, b.name as brand_name FROM `models` m
                INNER JOIN `brands` b ON m.brand_id = b.id
                WHERE m.`brand_id` = %d AND m.`active` = 1
                ORDER BY m.`name` ASC",
                $brand_id
            ), ARRAY_A);
        } else {
            // Tous les modèles
            $models = $db->get_results(
                "SELECT m.*, b.name as brand_name FROM `models` m
                INNER JOIN `brands` b ON m.brand_id = b.id
                WHERE m.`active` = 1
                ORDER BY b.name, m.`name` ASC",
                ARRAY_A
            );
        }

        wp_send_json_success(['models' => $models ?: []]);
    }

    public static function ajax_save_model()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;
        $brand_id = isset($_POST['brand_id']) ? intval($_POST['brand_id']) : 0;
        $name = isset($_POST['name']) ? sanitize_text_field(trim($_POST['name'])) : '';
        $image_url = isset($_POST['image_url']) ? esc_url_raw(trim($_POST['image_url'])) : null;
        $description = isset($_POST['description']) ? sanitize_textarea_field(trim($_POST['description'])) : null;

        if (empty($name)) {
            wp_send_json_error(['message' => __('Le nom est obligatoire.', 'sempa')], 400);
        }

        if ($brand_id <= 0) {
            wp_send_json_error(['message' => __('La marque est obligatoire.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        if ($id > 0) {
            // Mise à jour
            $result = $db->update(
                'models',
                [
                    'brand_id' => $brand_id,
                    'name' => $name,
                    'image_url' => $image_url,
                    'description' => $description,
                ],
                ['id' => $id],
                ['%d', '%s', '%s', '%s'],
                ['%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la mise à jour.', 'sempa')], 500);
            }

            $model = $db->get_row($db->prepare(
                "SELECT m.*, b.name as brand_name FROM `models` m
                INNER JOIN `brands` b ON m.brand_id = b.id
                WHERE m.`id` = %d",
                $id
            ), ARRAY_A);
        } else {
            // Création
            $result = $db->insert(
                'models',
                [
                    'brand_id' => $brand_id,
                    'name' => $name,
                    'image_url' => $image_url,
                    'description' => $description,
                    'active' => 1,
                ],
                ['%d', '%s', '%s', '%s', '%d']
            );

            if ($result === false) {
                wp_send_json_error(['message' => __('Erreur lors de la création.', 'sempa')], 500);
            }

            $model = $db->get_row($db->prepare(
                "SELECT m.*, b.name as brand_name FROM `models` m
                INNER JOIN `brands` b ON m.brand_id = b.id
                WHERE m.`id` = %d",
                $db->insert_id
            ), ARRAY_A);
        }

        wp_send_json_success(['model' => $model, 'message' => __('Modèle enregistré.', 'sempa')]);
    }

    public static function ajax_delete_model()
    {
        check_ajax_referer(self::NONCE_ACTION, 'nonce');

        if (!self::current_user_allowed()) {
            wp_send_json_error(['message' => __('Accès refusé.', 'sempa')], 403);
        }

        $id = isset($_POST['id']) ? intval($_POST['id']) : 0;

        if ($id <= 0) {
            wp_send_json_error(['message' => __('ID invalide.', 'sempa')], 400);
        }

        $db = Sempa_Stocks_DB::instance();

        // Soft delete
        $result = $db->update(
            'models',
            ['active' => 0],
            ['id' => $id],
            ['%d'],
            ['%d']
        );

        if ($result === false) {
            wp_send_json_error(['message' => __('Erreur lors de la suppression.', 'sempa')], 500);
        }

        wp_send_json_success(['message' => __('Modèle supprimé.', 'sempa')]);
    }

    // ============================================
    // HELPERS
    // ============================================

    private static function current_user_allowed()
    {
        if (!is_user_logged_in()) {
            return false;
        }

        // Allow administrators
        if (current_user_can('manage_options')) {
            return true;
        }

        // Allow users with Gestionnaire de Stock role
        if (current_user_can('manage_sempa_stock')) {
            return true;
        }

        return false;
    }
}
