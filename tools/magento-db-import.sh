#!/usr/bin/env bash
source $(dirname $0)/common.sh

:: Restore Magento database
pv backfill/magento-db.sql.gz | gunzip -c | warden db import

./tools/set-default-config.sh