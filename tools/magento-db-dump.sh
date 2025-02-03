#!/usr/bin/env bash
source $(dirname $0)/common.sh

:: Dump Magento database
warden env exec db sh -c "mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE}" |sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' |gzip > backfill/dump-$(date "+%Y%m%d_%H%M%S").sql.gz
