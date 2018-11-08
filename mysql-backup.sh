#!/bin/bash
perl -le 'sleep rand 10800' && mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /var/backups/backup.sql
