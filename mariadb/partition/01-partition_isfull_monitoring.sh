# Partition monitoring
# Check the last 3 partitions.

source /mariadb/mysql_env

dbname=mysql
dbhost=localhost
db_user=`cat /mariadb/pass_conf | grep mysql_mon | awk '{print $1}'
db_pass=`cat /mariadb/pass_conf | grep myqsl_mon | awk '{print $2}'
input_type=$1

fn_mariadb_partition_chk()
{
result=`mysql -u${db_user} -h${dbhost} -p${db_pass} -P${db_port} -BNe "select table_schema, table_name,partition_name,table_rows \
from (select table_schema, table_name,partition_name,TABLE_ROWS, rank() over (partition by table_schema, table_name order by any_value(PARTITION_ORDINAL_POSITION) desc) as rn\
        from information_schema.PARTITIONS p\
        where table_schema not in ('information_schema','performance_schema')\
        and partition_name is not null\
        group by table_schema, table_name,partition_name,TABLE_ROWS\
        )a\
where rn <=3;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g"`
# sed : convert blank to comma
echo "${result}"
}

if [ ${input_type^^} == "PARTITION" ]
then
  fn_mariadb_partition_chk
fi

## plain sql
#select table_schema, table_name,partition_name,table_rows
#from (select table_schema, table_name,partition_name,TABLE_ROWS, rank() over (partition by table_schema, table_name order by any_value(PARTITION_ORDINAL_POSITION) desc) as rn
#      from information_schema.PARTITIONS p
#      where table_schema not in ('information_schema','performance_schema')
#      and partition_name is not null
#      group by table_schema, table_name,partition_name,TABLE_ROWS
#      )a
#where rn <=3;
