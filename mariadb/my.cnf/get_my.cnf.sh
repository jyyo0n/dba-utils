#!/bin/bash

function print_usage {
cat << EOF
##################################################
# Created by DBA jy.yoon                         #
# Get mariaDB optimal parameter values           #
# last modified at "2023.05.22"                  #
##################################################

EOF
}

print_usage

page_size=$(getconf PAGE_SIZE)
phys_pages=$(getconf _PHYS_PAGES)
phys_mem=$((page_size * phys_pages))
cpu_cores=$(grep processor /proc/cpuinfo | wc -l)

echo "CPU core : $cpu_cores"
echo "Physical mem : $phys_mem"
echo "##################################################"
echo ""
echo "You need to input {basedir datadir tmpdir socket pid-file plugin_dir slow-query-log-file log-error general_log_file innodb_undo_directory-query-log-file innodb_data_home_dir innodb_data_file_path innodb_log_group_home_dir relay-log log-bin}."
echo "Just Enter to use default script directory."
echo ""

declare -A parameters
parameter_names=("basedir" "datadir" "tmpdir" "socket" "pid-file" "plugin_dir" "slow-query-log-file" "log-error" "general_log_file" "innodb_undo_directory" "innodb_data_home_dir" "innodb_data_file_path" "innodb_log_group_home_dir" "relay-log" "log-bin")
declare -A default_values=(
  [basedir]="/usr/local/mariadb"
  [datadir]="/mariadb/dbdata/DATA"
  [tmpdir]="/mariadb/dbdata/TMP"
  [socket]="/mariadb/mysql.sock"
  [pid-file]="/mariadb/mysqld.pid"
  [plugin_dir]="/usr/local/mariadb/lib/plugin"
  [slow-query-log-file]="/mariadb/dblog/ADMIN/slow_query.log"
  [log-error]="/mariadb/dblog/ADMIN/error.log"
  [general_log_file]="/mariadb/dblog/ADMIN/general_query.log"
  [innodb_undo_directory]="/mariadb/dbdata/UNDO"
  [innodb_data_home_dir]="/usr/local/mariadb/"
  [innodb_data_file_path]="/mariadb/dbext/IBDATA/ibdata1:100M:autoextend"
  [innodb_log_group_home_dir]="/mariadb/dbext/IBLOG"
  [relay-log]="/mariadb/dbext/RELAYLOG/relay_log"
  [log-bin]="/mariadb/dbext/BINLOG/binary_log"
)

# Function to prompt for parameter input
function prompt_input {
  local var_name="$1"
  local default_value="$2"

  read -p "INPUT $var_name (default:$default_value) : " value
  value="${value:-$default_value}"
  parameters[$var_name]="$value"
}

# Prompt for parameter inputs
for param_name in "${parameter_names[@]}"; do
  prompt_input "$param_name" "${default_values[$param_name]}"
done

# Access the values
var_basedir=${parameters["basedir"]}
var_datadir=${parameters["datadir"]}
var_tmpdir=${parameters["tmpdir"]}
var_socket=${parameters["socket"]}
var_pidfile=${parameters["pid-file"]}
var_plugin_dir=${parameters["plugin_dir"]}
var_slowquerylogfile=${parameters["slow-query-log-file"]}
var_logerror=${parameters["log-error"]}
var_general_log_file=${parameters["general_log_file"]}
var_innodb_undo_directory=${parameters["innodb_undo_directory"]}
var_innodb_data_home_dir=${parameters["innodb_data_home_dir"]}
var_innodb_data_file_path=${parameters["innodb_data_file_path"]}
var_innodb_log_group_home_dir=${parameters["innodb_log_group_home_dir"]}
var_relaylog=${parameters["relay-log"]}
var_logbin=${parameters["log-bin"]}

echo "##################################################"

var_innodb_buffer_pool_size=$((phys_mem / 60))
var_innodb_log_file_size=$((var_innodb_buffer_pool_size / 25))

# Generate my.cnf.output file
cat << EOF > my.cnf.output
[mysqld]
server-id = 101
user = mysql
basedir = ${parameters["basedir"]}
datadir = ${parameters["datadir"]}
tmpdir = ${parameters["tmpdir"]}
socket = ${parameters["socket"]}
pid-file = ${parameters["pid-file"]}
plugin_dir = ${parameters["plugin_dir"]}
open-files-limit = 65536
port = 33069
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
max_prepared_stmt_count = 1048576
event-scheduler = ON
lower_case_table_names = 1
explicit_defaults_for_timestamp # no_zero_date, 첫 timestamp컬럼을 not null default current timestamp 설정되는 것을 방지
lc_messages = en_US
performance_schema = on
skip-name-resolve 				# avoid DNC lookup for connection performance
skip-character-set-client-handshake # ignore client character set

## thread pool
thread_handling = pool-of-threads
thread_pool_max_threads = 65536
thread_pool_idle_timeout = 120
thread_cache_size = 28   # 8+(max_connections/100)

session_track_system_variables = last_gtid # Maxscale Use causal_reads
transaction-isolation = READ-COMMITTED
max_connections = 2000
sql_mode = STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_AUTO_VALUE_ON_ZERO
wait_timeout = 600 # idle timeout
interactive_timeout = 600 # define timeout for mysql shell cmd, dbeaver, etc..
#large-pages

## Mysql logging
slow-query-log = on
slow-query-log-file = ${parameters["slow-query-log-file"]}
log_queries_not_using_indexes = on
min_examined_row_limit = 100
log_slow_admin_statements = on
log_slow_slave_statements = on
log_slow_verbosity = query_plan,explain
long_query_time = 1
log-error = ${parameters["log-error"]}
#general_log = on
general_log_file = ${parameters["general_log_file"]}

## Buffer size
sort_buffer_size = 128K # order by or group by
read_buffer_size = 128K # Bulk insert
join_buffer_size = 256K # Used when no key can be used to find a row in next table
net_buffer_length = 16K  # Max size network packet
mrr_buffer_size = 256K # Multi-range read
key_buffer_size = 128K # show global status Key_read_requests/Key_reads > = 10 (myisam)
# max_heap_table_size = # Use to store temporary tables in memory

## Innodb add setting
default-storage-engine = InnoDB
innodb_buffer_pool_size = $var_innodb_buffer_pool_size 	# physical mem 60% to avoid swap
innodb_log_file_size = $var_innodb_log_file_size  # buffer_pool_size 25%, redo log size.
innodb_buffer_pool_load_at_startup = ON
innodb_buffer_pool_dump_at_shutdown = ON
innodb_fast_shutdown = 0
innodb_undo_tablespaces = 10  # undo tablespace
innodb_undo_directory = ${parameters["innodb_undo_directory"]}
innodb_file_per_table = ON
innodb_log_buffer_size = 67108864 # 64M
innodb_stats_on_metadata = 0
innodb_flush_method = O_DIRECT

innodb_read_io_threads = 24       # show engine innodb status pending read request < 64* innodb_read_io_thread
innodb_write_io_threads = 24

## adaptive hash index
innodb_adaptive_hash_index = 1       # Max Memory no limit. Check show global status like 'Innodb_mem_adaptive_hash';
innodb_adaptive_hash_index_parts = $cpu_cores      # Per CPU

innodb_data_home_dir = ${parameters["innodb_data_home_dir"]}
innodb_data_file_path = ${parameters["innodb_data_file_path"]}
innodb_log_group_home_dir = ${parameters["innodb_log_group_home_dir"]}
EOF
