# 🚀 Drupal 11 Headless — Docker Template

A turnkey Docker environment for running **Drupal 11 in Headless / API-first mode**, powered by **Nginx + PHP-FPM 8.3** and pre-configured with all necessary modules for decoupled architecture (REST, JSON:API, GraphQL, OAuth2…).

---

## 📦 Stack

| Service   | Image                       | Port            | Description                            |
| --------- | --------------------------- | --------------- | -------------------------------------- |
| **nginx** | `nginx:alpine`              | `80`            | Web server / reverse proxy to PHP-FPM  |
| **php**   | Custom `php:8.3-fpm-alpine` | —               | PHP-FPM with Composer & all extensions |
| **db**    | `mariadb:11.4`              | —               | Database (using a named Docker volume) |
| **redis** | `redis:7-alpine`            | —               | Cache backend for Drupal               |
| **pma**   | `phpmyadmin:5.2`            | `8081`          | Database GUI                           |
| **mail**  | `maildev/maildev:2.1.0`     | `8080` / `1025` | Local SMTP / email catcher             |

---

## ⚡ Quick Start

### 1. Prerequisites

- [Docker](https://www.docker.com/get-started) (Desktop or Engine) installed and running
- **Make** installed in your system (Standard on most Unix/Linux systems)

### 2. Configure environment

Copy the example environment file and adjust if needed:

```bash
cp .env.example .env
```

> The defaults work out of the box for local development.

### 3. Install Drupal

Run the full automated installation with a single command:

```bash
make install
```

This will:

1. Build the custom PHP-FPM Docker image (with Redis support)
2. Start all containers (MariaDB, Redis, Nginx, MailDev...)
3. Install dependencies via Composer
4. Run `drush site:install` to initialize the database
5. Enable all Headless modules and configure the **Gin** admin theme
6. Configure Drupal for **Pure Headless** mode (Frontpage redirects to login)
7. Finalize Redis caching and environment integration

---

## 🛠️ Available Make Commands

```bash
make help       # Show all available commands
make up         # Start containers (detached)
make down       # Stop and remove containers
make stop       # Stop containers
make restart    # Restart all containers
make logs       # Tail container logs
make shell      # Open bash shell inside PHP container
make install    # Full Drupal 11 Headless installation (FRESH)
make clean      # ⚠️  Destroy everything (containers + volumes)
```

---

## 🔗 Access Points

| Service         | URL                                                                                            | Description                    |
| --------------- | ---------------------------------------------------------------------------------------------- | ------------------------------ |
| **Admin Panel** | [http://localhost](http://localhost)                                                           | Direct access to Gin interface |
| **JSON:API**    | [http://localhost/jsonapi](http://localhost/jsonapi)                                           | API Root                       |
| **GraphQL**     | [http://localhost/graphql](http://localhost/graphql)                                           | GraphQL Explorer / Endpoint    |
| **Swagger UI**  | [http://localhost/.../jsonapi](http://localhost/admin/config/services/openapi/swagger/jsonapi) | Interactive API Doc (JSON:API) |
| **ReDoc UI**    | [http://localhost/.../jsonapi](http://localhost/admin/config/services/openapi/redoc/jsonapi)   | Modern API Doc (JSON:API)      |
| **phpMyAdmin**  | [http://localhost:8081](http://localhost:8081)                                                 | Database GUI                   |
| **MailDev**     | [http://localhost:8080](http://localhost:8080)                                                 | Local Email catcher            |

> **Default credentials:** `admin` / `admin`

---

## 🧩 Pre-installed Headless Modules

### 🔌 API & Exposition

| Module               | Package                     | Description                                        |
| -------------------- | --------------------------- | -------------------------------------------------- |
| REST API             | `drupal/core` (core)        | RESTful Web Services (JSON, XML)                   |
| JSON:API             | `drupal/core` (core)        | Standards-compliant automatic API endpoints        |
| JSON:API Extras      | `drupal/jsonapi_extras`     | Field aliasing, disabled resources, resource types |
| GraphQL              | `drupal/graphql`            | Full GraphQL schema based on Drupal content model  |
| OpenAPI / Swagger UI | `drupal/openapi_ui_swagger` | Interactive API documentation (Swagger / ReDoc)    |

### 🔐 Authentication

| Module       | Package               | Description                                 |
| ------------ | --------------------- | ------------------------------------------- |
| Simple OAuth | `drupal/simple_oauth` | OAuth 2.0 / Bearer Token for decoupled auth |

### 🧭 Routing & Integration

| Module           | Package                   | Description                                           |
| ---------------- | ------------------------- | ----------------------------------------------------- |
| Decoupled Router | `drupal/decoupled_router` | Resolves Drupal paths for React/Vue/Next.js frontends |
| Subrequests      | `drupal/subrequests`      | Batch multiple API requests in a single HTTP call     |

### 📝 Content

| Module     | Package             | Description                                   |
| ---------- | ------------------- | --------------------------------------------- |
| Paragraphs | `drupal/paragraphs` | Flexible content components / blocks          |
| Metatag    | `drupal/metatag`    | SEO meta tags and Open Graph exposed via API  |
| Pathauto   | `drupal/pathauto`   | Automatic URL alias generation                |
| Token      | `drupal/token`      | Token system (required by Pathauto & Metatag) |

### ⚡ Performance

| Module        | Package                | Description                                       |
| ------------- | ---------------------- | ------------------------------------------------- |
| Redis         | `drupal/redis`         | Redis cache backend integration                   |
| Ultimate Cron | `drupal/ultimate_cron` | Granular cron management, logs and parallel tasks |

---

## 📁 Project Structure

```
.
├── .docker/           # Infrastructure config (nginx/php)
├── scripts/           # Installation & automation scripts
├── web/               # Drupal public root
├── vendor/            # Composer dependencies
├── Dockerfile         # PHP 8.3-FPM image with Redis
├── Makefile           # Developer commands (make install)
├── composer.json      # Dependencies
├── .env.example       # Environment template
└── README.md
```

> After running `make install`, the Drupal codebase (`web/`, `vendor/`, `composer.json`…) will appear directly at the project root.

---

## 🔧 Configuration

### Change PHP settings

Edit `.docker/php/php.ini` and restart the PHP container:

```bash
docker compose restart php
```

### Change Nginx config

Edit `.docker/nginx/default.conf` and restart Nginx:

```bash
docker compose restart web
```

### Add a Composer package

```bash
make shell
composer require drupal/PACKAGE_NAME
```

---

## 📄 License

GNU General Public License v3.0 — See [LICENSE](LICENSE) for details.
