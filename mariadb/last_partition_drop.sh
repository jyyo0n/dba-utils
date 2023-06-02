#!/bin/bash

DATE=`date +'%Y%m%d'`
LOG_FILENM=partition_mng_"${DATE}".log
LOG_DIR=/home/jywork/last_partition_drop/log
LOG_FILE="${LOG_DIR}"/"${LOG_FILENM}"

FNC_DB() {
        DB_IP=`192.168.0.1`
        DB_CONN="mysql -h ${DB_IP} -uroot -proot mysql -BN"
}
FNC_DB

for tbl_part in $(echo "select concat(table_name,\"|\",partition_name) from information_schema.partitions where partition_name is not null and partition_ordinal_position=1" | ${DB_CONN});
do
        tbl_nm=`echo $tbl_part | cut -d'|' -f 1`
        part_nm=`echo $tbl_part | cut -d'|' -f 2`
        echo "${tbl_nm}.${part_nm} drop.." >> $LOG_FILE
        echo "  alter table $tbl_nm drop partition $part_nm;" >> $LOG_FILE
        echo "alter table $tbl_nm drop partition $part_nm;" | ${DB_CONN} >> $LOG_FILE
        if [ $? -eq 0 ]; then
                echo "  ${tbl_nm}.${part_nm} drop success" >> $LOG_FILE
        else
                echo "  ${tbl_nm}.${part_nm} drop fail" >> $LOG_FILE
        fi
        echo "MAX PARTITION INFO.." >>$LOG_FILE
        echo "select table_schema,table_name,partition_name from information_schema.partitions where partition_name is not null and table_name ='$tbl_nm' order by partition_ordinal_position desc limit 2" | ${DB_CONN} | sed 's/[[:space:]]\+/./g' | sed 's/^/  /' >> $LOG_FILE
        echo "" >> $LOG_FILE
done

# sending slack to #infra-monitoring

# add crontab
#crontab -e
#00 10 3 * * /home/jywork/last_partition_drop.sh
