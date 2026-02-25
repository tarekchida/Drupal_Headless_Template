#!/bin/bash

# 🚀 Master Install Script for Drupal 11 Headless
set -e

echo -e "\033[1;34m━━━ 📦 Step 1: Installing dependencies (Composer) ━━━\033[0m"
export COMPOSER_PROCESS_TIMEOUT=2000
composer install --prefer-dist --no-interaction

echo -e "\n\033[1;34m━━━ ⏳ Step 2: Waiting for Database ━━━\033[0m"
until mariadb-admin ping -h db --user=drupal --password=drupal --silent; do
    echo "  ... waiting for mariadb at 'db' host ..."
    sleep 3
done
echo "  ✅ Database is ready!"

echo -e "\n\033[1;34m━━━ 🛠️  Step 3: Site Installation (Fresh) ━━━\033[0m"
# On force une installation fraîche en vidant la base
echo "  🧹 Cleaning up and dropping existing tables..."
# 1. On droppe les tables (on a encore besoin du settings.php pour les creds)
chmod 644 web/sites/default/settings.php 2>/dev/null || true
./vendor/bin/drush sql-drop -y || true

# 2. On repart d'un dossier settings propre pour l'installateur
chmod 777 web/sites/default 2>/dev/null || true
rm -f web/sites/default/settings.php web/sites/default/settings.local.php

./vendor/bin/drush site:install standard \
    --db-url=mysql://drupal:drupal@db:3306/drupal \
    --site-name="Drupal 11 Headless API" \
    --account-name=admin \
    --account-pass=admin \
    --account-mail=admin@example.com \
    -y

echo -e "\n\033[1;34m━━━ ⚙️  Step 4: Finalizing Headless Configuration ━━━\033[0m"


# 1. Configurer les thèmes (Gin partout pour éviter le front "site")
echo "  🎨 Configuring Headless UI (Gin for everyone)..."
./vendor/bin/drush theme:install gin -y
./vendor/bin/drush config:set system.theme default gin -y
./vendor/bin/drush config:set system.theme admin gin -y
./vendor/bin/drush theme:uninstall olivero -y || true

# 2. Rediriger la home vers le login admin
echo "  🏠 Redirecting frontpage to /user/login..."
./vendor/bin/drush config:set system.site page.front "/user/login" -y

# 3. Activer les modules
echo "  📦 Enabling modules..."
./vendor/bin/drush en admin_toolbar next simple_oauth graphql jsonapi_extras metatag paragraphs redis ultimate_cron content_cleaner focal_point crop search_api pathauto facets decoupled_router subrequests jsonapi_resources field_group scheduler content_moderation_notifications admin_toolbar_tools openapi openapi_jsonapi openapi_rest openapi_ui openapi_ui_swagger openapi_ui_redoc -y

# 4. Inclusion des settings.local.php (IMPORTANT: APRES activation du module Redis)
if [ -f "/var/www/html/settings.local.php" ]; then
    echo "  📝 Injecting settings.local.php into settings.php..."
    cp /var/www/html/settings.local.php /var/www/html/web/sites/default/settings.local.php
    chmod 644 /var/www/html/web/sites/default/settings.php
    if ! grep -v '^#' "/var/www/html/web/sites/default/settings.php" | grep -q "include .*/settings.local.php"; then
        echo -e "\nif (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {\n  include \$app_root . '/' . \$site_path . '/settings.local.php';\n}" >> /var/www/html/web/sites/default/settings.php
    fi
fi

./vendor/bin/drush cr

# Permissions
chown -R www-data:www-data web/sites/default/files || true

echo -e "\n\033[1;32m══════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m 🎉 INSTALLATION COMPLETE !\033[0m"
echo -e "\033[1;32m══════════════════════════════════════════════════\033[0m"

echo -e "\n  🚀 \033[1mYour Drupal 11 Headless is ready:\033[0m"
echo -e "  --------------------------------------------------"
echo -e "  🌐 \033[36mAdmin Panel:\033[0m      http://localhost"
echo -e "  📡 \033[36mJSON:API:\033[0m         http://localhost/jsonapi"
echo -e "  📊 \033[36mGraphQL:\033[0m          http://localhost/graphql"
echo -e "  📖 \033[36mSwagger UI:\033[0m       http://localhost/admin/config/services/openapi/swagger"
echo -e "  --------------------------------------------------"
echo -e "  🗄️  \033[36mPhpMyAdmin:\033[0m       http://localhost:8081"
echo -e "  ✉️  \033[36mMailDev:\033[0m          http://localhost:8080"
echo -e "  --------------------------------------------------"
echo -e "  🔑 \033[1mCredentials:\033[0m      admin / admin"
echo -e "  --------------------------------------------------\n"
