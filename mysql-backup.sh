#!/bin/bash
mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /var/backups/backup.sql
