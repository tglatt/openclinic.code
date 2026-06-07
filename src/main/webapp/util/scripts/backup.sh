cd /root
./automysqlbackup.sh
tar cf /mnt/nas/db.tar /backups/latest
find /backups -name "*" -mtime +120 -exec rm -f {} \;
