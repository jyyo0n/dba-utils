# dba_utils/mariadb
## get_my.cnf.sh
generator mariadb /etc/my.cnf config file

### 주요 dir 관련 파라미터
```
My mariaDB dir tree
/mariadb
├── dbdata
│   ├── DATA
│   ├── TMP
│   ├── UNDO
│   ├── mysql.sock
│   └── mysqld.pid
└── dblog
    ├── ADMIN
    │   ├── error.log
    │   └── slow_query.log
    │   └── general_query.log
    ├── BINLOG
    ├── INDBDATA
    ├── INDBLOG
    └── RELAYLOG
```

| name  | desc | default | my |
|--|--|--|--|
basedir | engine dir. | |/usr/local/mariadb |
datadir | data dir.| | /mariadb/dbdata/DATA|
tmpdir | temp file dir. || /mariadb/dbdata/TMP|
socket |  | |/mariadb/mysql.sock |
pid-file |  | |/mariadb/mysqld.pid|
plugin_dir |  | |/usr/local/mariadb/lib/plugin
slow-query-log-file |  || /mariadb/dblog/ADMIN/slow_query.log
log-error | | | /mariadb/dblog/ADMIN/error.log
general_log_file |  || /mariadb/dblog/ADMIN/general_query.log
innodb_undo_directory | | | /mariadb/dbdata/UNDO
innodb_data_home_dir |  | |/usr/local/mariadb/
innodb_data_file_path |  || /mariadb/dblog/INDBDATA/indbdata1:100M:autoextend
innodb_log_group_home_dir | | | /mariadb/dblog/INDBLOG
relay-log | | |/mariadb/dblog/RELAYLOG/relay_log
log-bin |  | |/mariadb/dblog/BINLOG/binary_log | 




### 주요 성능 관련 파라미터
* **innodb_buffer_pool_size**
	* physical mem 60% to avoid swap.
* **innodb_log_file_size**
	* buffer_pool_size 25%, redo log size. 너무 크면 복구 시간이 지연 될 수 있음.
	* 
