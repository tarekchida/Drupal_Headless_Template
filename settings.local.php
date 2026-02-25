<?php

/**
 * @file
 * Local development settings for Drupal 11 Headless.
 *
 * This file is NOT committed to version control (.gitignore).
 * It is created automatically by `make install`.
 */

// ─── Disable caching for development (optional) ──────────────────────────────
// $settings['cache']['default'] = 'cache.backend.null';
// $settings['cache']['bins']['render']         = 'cache.backend.null';
// $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
// $settings['cache']['bins']['page']           = 'cache.backend.null';
$config['system.performance']['css']['preprocess']  = FALSE;
$config['system.performance']['js']['preprocess']   = FALSE;

// ─── Redis cache backend ──────────────────────────────────────────────────────
// Only enable Redis if we are not in the middle of an installation and the module exists.
if (!Drupal\Core\Installer\InstallerKernel::installationAttempted() && file_exists(__DIR__ . '/../../modules/contrib/redis/example.services.yml')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host']      = getenv('REDIS_HOST') ?: 'redis';
  $settings['redis.connection']['port']      = getenv('REDIS_PORT') ?: 6379;
  $settings['cache']['default']              = 'cache.backend.redis';
  $settings['cache']['bins']['bootstrap']    = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery']    = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config']       = 'cache.backend.chainedfast';
  $settings['container_yamls'][]             = 'modules/contrib/redis/example.services.yml';
}

// ─── Database ─────────────────────────────────────────────────────────────────
$databases['default']['default'] = [
  'driver'    => 'mysql',
  'database'  => getenv('DB_NAME')     ?: 'drupal',
  'username'  => getenv('DB_USER')     ?: 'drupal',
  'password'  => getenv('DB_PASSWORD') ?: 'drupal',
  'host'      => 'db',
  'port'      => '3306',
  'prefix'    => '',
  'collation' => 'utf8mb4_general_ci',
];

// ─── Trusted hosts ────────────────────────────────────────────────────────────
$settings['trusted_host_patterns'] = [
  '^.*$',
];

// ─── Error display (dev only) ─────────────────────────────────────────────────
$config['system.logging']['error_level'] = 'verbose';

// ─── File paths ───────────────────────────────────────────────────────────────
$settings['file_public_path']  = 'sites/default/files';
$settings['file_private_path'] = '/var/www/html/private';

// ─── Hash salt ────────────────────────────────────────────────────────────────
// Auto-generated during install. DO NOT change this manually.
$settings['hash_salt'] = 'change_me_in_production_use_random_hash';

// ─── Config split (optional) ─────────────────────────────────────────────────
// $config['config_split.config_split.dev']['status'] = TRUE;
