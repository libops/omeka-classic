#!/command/with-contenv bash
# shellcheck shell=bash

set -eou pipefail

function mysql_create_database {
    cat <<-SQL | create-database.sh
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* to '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SET PASSWORD FOR ${DB_USER}@'%' = PASSWORD('${DB_PASSWORD}');
SQL
}

function wait_for_database {
    local attempts=0
    until mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e 'SELECT 1' >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ "$attempts" -ge 60 ]; then
            echo "Database was not ready in time"
            exit 1
        fi
        sleep 2
    done
}

function check_installed {
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" \
        -e "SELECT 1 FROM ${OMEKA_CLASSIC_TABLE_PREFIX}options LIMIT 1" >/dev/null 2>&1
}

function install_omeka {
    if check_installed; then
        echo "Omeka Classic is already installed."
        return 0
    fi

    timeout 300 wait-for-open-port.sh localhost 80
    curl -fsS -d "username=${OMEKA_CLASSIC_ADMIN_USERNAME}" \
        -d "password=${OMEKA_CLASSIC_ADMIN_PASSWORD}" \
        -d "password_confirm=${OMEKA_CLASSIC_ADMIN_PASSWORD}" \
        -d "super_email=${OMEKA_CLASSIC_ADMIN_EMAIL}" \
        -d "administrator_email=${OMEKA_CLASSIC_ADMIN_EMAIL}" \
        -d "site_title=${OMEKA_CLASSIC_SITE_TITLE}" \
        -d "tag_delimiter=," \
        -d "fullsize_constraint=800" \
        -d "thumbnail_constraint=200" \
        -d "square_thumbnail_constraint=200" \
        -d "per_page_admin=10" \
        -d "per_page_public=10" \
        -d "path_to_convert=/usr/bin" \
        -d "install_submit=Install" \
        http://localhost/install/install.php >/tmp/omeka-classic-install.log 2>&1 || {
            cat /tmp/omeka-classic-install.log
            exit 1
        }
}

function main {
    if [ "${DB_HOST}" = "mariadb" ]; then
        mysql_create_database
    fi
    wait_for_database
    install_omeka
    touch /installed
}

main
