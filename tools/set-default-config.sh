#!/usr/bin/env bash

source $(dirname $0)/common.sh

:: Import the config from files
warden env exec -T php-fpm bin/magento app:config:import

:: Set BASE URL Config
warden env exec -T php-fpm bin/magento config:set web/unsecure/base_url ${URL_FRONT}
warden env exec -T php-fpm bin/magento config:set web/secure/base_url ${URL_FRONT}
warden env exec -T php-fpm bin/magento config:set web/unsecure/base_link_url ${URL_FRONT}
warden env exec -T php-fpm bin/magento config:set web/secure/base_link_url ${URL_FRONT}

:: Create an admin user
warden env exec -T php-fpm bin/magento admin:user:create --admin-user=admin --admin-password=123123q --admin-email=admin@example.com --admin-firstname=Admin --admin-lastname=Admin
