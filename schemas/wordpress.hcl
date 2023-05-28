table "columns_priv" {
  schema  = schema.mysql
  comment = "Column privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Db" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Table_name" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Column_name" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Timestamp" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "Column_priv" {
    null    = false
    type    = set("Select","Insert","Update","References")
    default = ""
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.Host, column.Db, column.User, column.Table_name, column.Column_name]
  }
}
table "component" {
  schema  = schema.mysql
  comment = "Components"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "component_id" {
    null           = false
    type           = int
    unsigned       = true
    auto_increment = true
  }
  column "component_group_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "component_urn" {
    null = false
    type = text
  }
  primary_key {
    columns = [column.component_id]
  }
}
table "db" {
  schema  = schema.mysql
  comment = "Database privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Db" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Select_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Insert_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Update_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Delete_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Drop_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Grant_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "References_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Index_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Alter_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_tmp_table_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Lock_tables_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_view_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Show_view_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_routine_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Alter_routine_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Execute_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Event_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Trigger_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.Host, column.Db, column.User]
  }
  index "User" {
    columns = [column.User]
  }
}
table "default_roles" {
  schema  = schema.mysql
  comment = "Default roles"
  charset = "utf8"
  collate = "utf8_bin"
  column "HOST" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "USER" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "DEFAULT_ROLE_HOST" {
    null    = false
    type    = char(255)
    default = "%"
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "DEFAULT_ROLE_USER" {
    null    = false
    type    = char(32)
    default = ""
  }
  primary_key {
    columns = [column.HOST, column.USER, column.DEFAULT_ROLE_HOST, column.DEFAULT_ROLE_USER]
  }
}
table "engine_cost" {
  schema  = schema.mysql
  charset = "utf8"
  collate = "utf8_general_ci"
  column "engine_name" {
    null = false
    type = varchar(64)
  }
  column "device_type" {
    null = false
    type = int
  }
  column "cost_name" {
    null = false
    type = varchar(64)
  }
  column "cost_value" {
    null = true
    type = float
  }
  column "last_update" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "comment" {
    null = true
    type = varchar(1024)
  }
  column "default_value" {
    null = true
    type = float
    as {
      expr = "(case `cost_name` when _utf8mb4'io_block_read_cost' then 1.0 when _utf8mb4'memory_block_read_cost' then 0.25 else NULL end)"
      type = VIRTUAL
    }
  }
  primary_key {
    columns = [column.engine_name, column.device_type, column.cost_name]
  }
}
table "func" {
  schema  = schema.mysql
  comment = "User defined functions"
  charset = "utf8"
  collate = "utf8_bin"
  column "name" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "ret" {
    null    = false
    type    = tinyint
    default = 0
  }
  column "dl" {
    null    = false
    type    = char(128)
    default = ""
  }
  column "type" {
    null    = false
    type    = enum("function","aggregate")
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.name]
  }
}
table "general_log" {
  schema  = schema.mysql
  comment = "General log"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "event_time" {
    null      = false
    type      = timestamp(6)
    default   = sql("CURRENT_TIMESTAMP(6)")
    on_update = sql("CURRENT_TIMESTAMP(6)")
  }
  column "user_host" {
    null = false
    type = mediumtext
  }
  column "thread_id" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "server_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "command_type" {
    null = false
    type = varchar(64)
  }
  column "argument" {
    null = false
    type = mediumblob
  }
}
table "global_grants" {
  schema  = schema.mysql
  comment = "Extended global grants"
  charset = "utf8"
  collate = "utf8_bin"
  column "USER" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "HOST" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "PRIV" {
    null    = false
    type    = char(32)
    default = ""
    collate = "utf8_general_ci"
  }
  column "WITH_GRANT_OPTION" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.USER, column.HOST, column.PRIV]
  }
}
table "gtid_executed" {
  schema = schema.mysql
  column "source_uuid" {
    null    = false
    type    = char(36)
    comment = "uuid of the source where the transaction was originally executed."
  }
  column "interval_start" {
    null    = false
    type    = bigint
    comment = "First number of interval."
  }
  column "interval_end" {
    null    = false
    type    = bigint
    comment = "Last number of interval."
  }
  primary_key {
    columns = [column.source_uuid, column.interval_start]
  }
}
table "help_category" {
  schema  = schema.mysql
  comment = "help categories"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "help_category_id" {
    null     = false
    type     = smallint
    unsigned = true
  }
  column "name" {
    null = false
    type = char(64)
  }
  column "parent_category_id" {
    null     = true
    type     = smallint
    unsigned = true
  }
  column "url" {
    null = false
    type = text
  }
  primary_key {
    columns = [column.help_category_id]
  }
  index "name" {
    unique  = true
    columns = [column.name]
  }
}
table "help_keyword" {
  schema  = schema.mysql
  comment = "help keywords"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "help_keyword_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "name" {
    null = false
    type = char(64)
  }
  primary_key {
    columns = [column.help_keyword_id]
  }
  index "name" {
    unique  = true
    columns = [column.name]
  }
}
table "help_relation" {
  schema  = schema.mysql
  comment = "keyword-topic relation"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "help_topic_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "help_keyword_id" {
    null     = false
    type     = int
    unsigned = true
  }
  primary_key {
    columns = [column.help_topic_id, column.help_keyword_id]
  }
}
table "help_topic" {
  schema  = schema.mysql
  comment = "help topics"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "help_topic_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "name" {
    null = false
    type = char(64)
  }
  column "help_category_id" {
    null     = false
    type     = smallint
    unsigned = true
  }
  column "description" {
    null = false
    type = text
  }
  column "example" {
    null = false
    type = text
  }
  column "url" {
    null = false
    type = text
  }
  primary_key {
    columns = [column.help_topic_id]
  }
  index "name" {
    unique  = true
    columns = [column.name]
  }
}
table "innodb_index_stats" {
  schema  = schema.mysql
  charset = "utf8"
  collate = "utf8_bin"
  column "database_name" {
    null = false
    type = varchar(64)
  }
  column "table_name" {
    null = false
    type = varchar(199)
  }
  column "index_name" {
    null = false
    type = varchar(64)
  }
  column "last_update" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "stat_name" {
    null = false
    type = varchar(64)
  }
  column "stat_value" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "sample_size" {
    null     = true
    type     = bigint
    unsigned = true
  }
  column "stat_description" {
    null = false
    type = varchar(1024)
  }
  primary_key {
    columns = [column.database_name, column.table_name, column.index_name, column.stat_name]
  }
}
table "innodb_table_stats" {
  schema  = schema.mysql
  charset = "utf8"
  collate = "utf8_bin"
  column "database_name" {
    null = false
    type = varchar(64)
  }
  column "table_name" {
    null = false
    type = varchar(199)
  }
  column "last_update" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "n_rows" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "clustered_index_size" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "sum_of_other_index_sizes" {
    null     = false
    type     = bigint
    unsigned = true
  }
  primary_key {
    columns = [column.database_name, column.table_name]
  }
}
table "password_history" {
  schema  = schema.mysql
  comment = "Password history for user accounts"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Password_timestamp" {
    null    = false
    type    = timestamp(6)
    default = sql("CURRENT_TIMESTAMP(6)")
  }
  column "Password" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.Host, column.User, column.Password_timestamp]
  }
}
table "plugin" {
  schema  = schema.mysql
  comment = "MySQL plugins"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "name" {
    null    = false
    type    = varchar(64)
    default = ""
  }
  column "dl" {
    null    = false
    type    = varchar(128)
    default = ""
  }
  primary_key {
    columns = [column.name]
  }
}
table "procs_priv" {
  schema  = schema.mysql
  comment = "Procedure privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Db" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Routine_name" {
    null    = false
    type    = char(64)
    default = ""
    collate = "utf8_general_ci"
  }
  column "Routine_type" {
    null = false
    type = enum("FUNCTION","PROCEDURE")
  }
  column "Grantor" {
    null    = false
    type    = varchar(288)
    default = ""
  }
  column "Proc_priv" {
    null    = false
    type    = set("Execute","Alter Routine","Grant")
    default = ""
    collate = "utf8_general_ci"
  }
  column "Timestamp" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  primary_key {
    columns = [column.Host, column.Db, column.User, column.Routine_name, column.Routine_type]
  }
  index "Grantor" {
    columns = [column.Grantor]
  }
}
table "proxies_priv" {
  schema  = schema.mysql
  comment = "User proxy privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Proxied_host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Proxied_user" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "With_grant" {
    null    = false
    type    = bool
    default = 0
  }
  column "Grantor" {
    null    = false
    type    = varchar(288)
    default = ""
  }
  column "Timestamp" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  primary_key {
    columns = [column.Host, column.User, column.Proxied_host, column.Proxied_user]
  }
  index "Grantor" {
    columns = [column.Grantor]
  }
}
table "role_edges" {
  schema  = schema.mysql
  comment = "Role hierarchy and role grants"
  charset = "utf8"
  collate = "utf8_bin"
  column "FROM_HOST" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "FROM_USER" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "TO_HOST" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "TO_USER" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "WITH_ADMIN_OPTION" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.FROM_HOST, column.FROM_USER, column.TO_HOST, column.TO_USER]
  }
}
table "server_cost" {
  schema  = schema.mysql
  charset = "utf8"
  collate = "utf8_general_ci"
  column "cost_name" {
    null = false
    type = varchar(64)
  }
  column "cost_value" {
    null = true
    type = float
  }
  column "last_update" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "comment" {
    null = true
    type = varchar(1024)
  }
  column "default_value" {
    null = true
    type = float
    as {
      expr = "(case `cost_name` when _utf8mb4'disk_temptable_create_cost' then 20.0 when _utf8mb4'disk_temptable_row_cost' then 0.5 when _utf8mb4'key_compare_cost' then 0.05 when _utf8mb4'memory_temptable_create_cost' then 1.0 when _utf8mb4'memory_temptable_row_cost' then 0.1 when _utf8mb4'row_evaluate_cost' then 0.1 else NULL end)"
      type = VIRTUAL
    }
  }
  primary_key {
    columns = [column.cost_name]
  }
}
table "servers" {
  schema  = schema.mysql
  comment = "MySQL Foreign Servers table"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Server_name" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Db" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Username" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Password" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Port" {
    null    = false
    type    = int
    default = 0
  }
  column "Socket" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Wrapper" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Owner" {
    null    = false
    type    = char(64)
    default = ""
  }
  primary_key {
    columns = [column.Server_name]
  }
}
table "slave_master_info" {
  schema  = schema.mysql
  comment = "Master Information"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Number_of_lines" {
    null     = false
    type     = int
    unsigned = true
    comment  = "Number of lines in the file."
  }
  column "Master_log_name" {
    null    = false
    type    = text
    comment = "The name of the master binary log currently being read from the master."
    collate = "utf8_bin"
  }
  column "Master_log_pos" {
    null     = false
    type     = bigint
    unsigned = true
    comment  = "The master log position of the last read event."
  }
  column "Host" {
    null    = true
    type    = char(255)
    comment = "The host name of the master."
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "User_name" {
    null    = true
    type    = text
    comment = "The user name used to connect to the master."
    collate = "utf8_bin"
  }
  column "User_password" {
    null    = true
    type    = text
    comment = "The password used to connect to the master."
    collate = "utf8_bin"
  }
  column "Port" {
    null     = false
    type     = int
    unsigned = true
    comment  = "The network port used to connect to the master."
  }
  column "Connect_retry" {
    null     = false
    type     = int
    unsigned = true
    comment  = "The period (in seconds) that the slave will wait before trying to reconnect to the master."
  }
  column "Enabled_ssl" {
    null    = false
    type    = bool
    comment = "Indicates whether the server supports SSL connections."
  }
  column "Ssl_ca" {
    null    = true
    type    = text
    comment = "The file used for the Certificate Authority (CA) certificate."
    collate = "utf8_bin"
  }
  column "Ssl_capath" {
    null    = true
    type    = text
    comment = "The path to the Certificate Authority (CA) certificates."
    collate = "utf8_bin"
  }
  column "Ssl_cert" {
    null    = true
    type    = text
    comment = "The name of the SSL certificate file."
    collate = "utf8_bin"
  }
  column "Ssl_cipher" {
    null    = true
    type    = text
    comment = "The name of the cipher in use for the SSL connection."
    collate = "utf8_bin"
  }
  column "Ssl_key" {
    null    = true
    type    = text
    comment = "The name of the SSL key file."
    collate = "utf8_bin"
  }
  column "Ssl_verify_server_cert" {
    null    = false
    type    = bool
    comment = "Whether to verify the server certificate."
  }
  column "Heartbeat" {
    null = false
    type = float
  }
  column "Bind" {
    null    = true
    type    = text
    comment = "Displays which interface is employed when connecting to the MySQL server"
    collate = "utf8_bin"
  }
  column "Ignored_server_ids" {
    null    = true
    type    = text
    comment = "The number of server IDs to be ignored, followed by the actual server IDs"
    collate = "utf8_bin"
  }
  column "Uuid" {
    null    = true
    type    = text
    comment = "The master server uuid."
    collate = "utf8_bin"
  }
  column "Retry_count" {
    null     = false
    type     = bigint
    unsigned = true
    comment  = "Number of reconnect attempts, to the master, before giving up."
  }
  column "Ssl_crl" {
    null    = true
    type    = text
    comment = "The file used for the Certificate Revocation List (CRL)"
    collate = "utf8_bin"
  }
  column "Ssl_crlpath" {
    null    = true
    type    = text
    comment = "The path used for Certificate Revocation List (CRL) files"
    collate = "utf8_bin"
  }
  column "Enabled_auto_position" {
    null    = false
    type    = bool
    comment = "Indicates whether GTIDs will be used to retrieve events from the master."
  }
  column "Channel_name" {
    null    = false
    type    = char(64)
    comment = "The channel on which the slave is connected to a source. Used in Multisource Replication"
  }
  column "Tls_version" {
    null    = true
    type    = text
    comment = "Tls version"
    collate = "utf8_bin"
  }
  column "Public_key_path" {
    null    = true
    type    = text
    comment = "The file containing public key of master server."
    collate = "utf8_bin"
  }
  column "Get_public_key" {
    null    = false
    type    = bool
    comment = "Preference to get public key from master."
  }
  column "Network_namespace" {
    null    = true
    type    = text
    comment = "Network namespace used for communication with the master server."
    collate = "utf8_bin"
  }
  column "Master_compression_algorithm" {
    null    = false
    type    = char(64)
    comment = "Compression algorithm supported for data transfer between master and slave."
    collate = "utf8_bin"
  }
  column "Master_zstd_compression_level" {
    null     = false
    type     = int
    unsigned = true
    comment  = "Compression level associated with zstd compression algorithm."
  }
  column "Tls_ciphersuites" {
    null    = true
    type    = text
    comment = "Ciphersuites used for TLS 1.3 communication with the master server."
    collate = "utf8_bin"
  }
  primary_key {
    columns = [column.Channel_name]
  }
}
table "slave_relay_log_info" {
  schema  = schema.mysql
  comment = "Relay Log Information"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Number_of_lines" {
    null     = false
    type     = int
    unsigned = true
    comment  = "Number of lines in the file or rows in the table. Used to version table definitions."
  }
  column "Relay_log_name" {
    null    = true
    type    = text
    comment = "The name of the current relay log file."
    collate = "utf8_bin"
  }
  column "Relay_log_pos" {
    null     = true
    type     = bigint
    unsigned = true
    comment  = "The relay log position of the last executed event."
  }
  column "Master_log_name" {
    null    = true
    type    = text
    comment = "The name of the master binary log file from which the events in the relay log file were read."
    collate = "utf8_bin"
  }
  column "Master_log_pos" {
    null     = true
    type     = bigint
    unsigned = true
    comment  = "The master log position of the last executed event."
  }
  column "Sql_delay" {
    null    = true
    type    = int
    comment = "The number of seconds that the slave must lag behind the master."
  }
  column "Number_of_workers" {
    null     = true
    type     = int
    unsigned = true
  }
  column "Id" {
    null     = true
    type     = int
    unsigned = true
    comment  = "Internal Id that uniquely identifies this record."
  }
  column "Channel_name" {
    null    = false
    type    = char(64)
    comment = "The channel on which the slave is connected to a source. Used in Multisource Replication"
  }
  column "Privilege_checks_username" {
    null    = true
    type    = char(32)
    comment = "Username part of PRIVILEGE_CHECKS_USER."
    collate = "utf8_bin"
  }
  column "Privilege_checks_hostname" {
    null    = true
    type    = char(255)
    comment = "Hostname part of PRIVILEGE_CHECKS_USER."
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Require_row_format" {
    null    = false
    type    = bool
    comment = "Indicates whether the channel shall only accept row based events."
  }
  primary_key {
    columns = [column.Channel_name]
  }
}
table "slave_worker_info" {
  schema  = schema.mysql
  comment = "Worker Information"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Relay_log_name" {
    null    = false
    type    = text
    collate = "utf8_bin"
  }
  column "Relay_log_pos" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "Master_log_name" {
    null    = false
    type    = text
    collate = "utf8_bin"
  }
  column "Master_log_pos" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "Checkpoint_relay_log_name" {
    null    = false
    type    = text
    collate = "utf8_bin"
  }
  column "Checkpoint_relay_log_pos" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "Checkpoint_master_log_name" {
    null    = false
    type    = text
    collate = "utf8_bin"
  }
  column "Checkpoint_master_log_pos" {
    null     = false
    type     = bigint
    unsigned = true
  }
  column "Checkpoint_seqno" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Checkpoint_group_size" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Checkpoint_group_bitmap" {
    null = false
    type = blob
  }
  column "Channel_name" {
    null    = false
    type    = char(64)
    comment = "The channel on which the slave is connected to a source. Used in Multisource Replication"
  }
  primary_key {
    columns = [column.Id, column.Channel_name]
  }
}
table "slow_log" {
  schema  = schema.mysql
  comment = "Slow log"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "start_time" {
    null      = false
    type      = timestamp(6)
    default   = sql("CURRENT_TIMESTAMP(6)")
    on_update = sql("CURRENT_TIMESTAMP(6)")
  }
  column "user_host" {
    null = false
    type = mediumtext
  }
  column "query_time" {
    null = false
    type = time(6)
  }
  column "lock_time" {
    null = false
    type = time(6)
  }
  column "rows_sent" {
    null = false
    type = int
  }
  column "rows_examined" {
    null = false
    type = int
  }
  column "db" {
    null = false
    type = varchar(512)
  }
  column "last_insert_id" {
    null = false
    type = int
  }
  column "insert_id" {
    null = false
    type = int
  }
  column "server_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "sql_text" {
    null = false
    type = mediumblob
  }
  column "thread_id" {
    null     = false
    type     = bigint
    unsigned = true
  }
}
table "tables_priv" {
  schema  = schema.mysql
  comment = "Table privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "Db" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Table_name" {
    null    = false
    type    = char(64)
    default = ""
  }
  column "Grantor" {
    null    = false
    type    = varchar(288)
    default = ""
  }
  column "Timestamp" {
    null      = false
    type      = timestamp
    default   = sql("CURRENT_TIMESTAMP")
    on_update = sql("CURRENT_TIMESTAMP")
  }
  column "Table_priv" {
    null    = false
    type    = set("Select","Insert","Update","Delete","Create","Drop","Grant","References","Index","Alter","Create View","Show view","Trigger")
    default = ""
    collate = "utf8_general_ci"
  }
  column "Column_priv" {
    null    = false
    type    = set("Select","Insert","Update","References")
    default = ""
    collate = "utf8_general_ci"
  }
  primary_key {
    columns = [column.Host, column.Db, column.User, column.Table_name]
  }
  index "Grantor" {
    columns = [column.Grantor]
  }
}
table "time_zone" {
  schema  = schema.mysql
  comment = "Time zones"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Time_zone_id" {
    null           = false
    type           = int
    unsigned       = true
    auto_increment = true
  }
  column "Use_leap_seconds" {
    null    = false
    type    = enum("Y","N")
    default = "N"
  }
  primary_key {
    columns = [column.Time_zone_id]
  }
}
table "time_zone_leap_second" {
  schema  = schema.mysql
  comment = "Leap seconds information for time zones"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Transition_time" {
    null = false
    type = bigint
  }
  column "Correction" {
    null = false
    type = int
  }
  primary_key {
    columns = [column.Transition_time]
  }
}
table "time_zone_name" {
  schema  = schema.mysql
  comment = "Time zone names"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Name" {
    null = false
    type = char(64)
  }
  column "Time_zone_id" {
    null     = false
    type     = int
    unsigned = true
  }
  primary_key {
    columns = [column.Name]
  }
}
table "time_zone_transition" {
  schema  = schema.mysql
  comment = "Time zone transitions"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Time_zone_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Transition_time" {
    null = false
    type = bigint
  }
  column "Transition_type_id" {
    null     = false
    type     = int
    unsigned = true
  }
  primary_key {
    columns = [column.Time_zone_id, column.Transition_time]
  }
}
table "time_zone_transition_type" {
  schema  = schema.mysql
  comment = "Time zone transition types"
  charset = "utf8"
  collate = "utf8_general_ci"
  column "Time_zone_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Transition_type_id" {
    null     = false
    type     = int
    unsigned = true
  }
  column "Offset" {
    null    = false
    type    = int
    default = 0
  }
  column "Is_DST" {
    null     = false
    type     = tinyint
    default  = 0
    unsigned = true
  }
  column "Abbreviation" {
    null    = false
    type    = char(8)
    default = ""
  }
  primary_key {
    columns = [column.Time_zone_id, column.Transition_type_id]
  }
}
table "user" {
  schema  = schema.mysql
  comment = "Users and global privileges"
  charset = "utf8"
  collate = "utf8_bin"
  column "Host" {
    null    = false
    type    = char(255)
    default = ""
    charset = "ascii"
    collate = "ascii_general_ci"
  }
  column "User" {
    null    = false
    type    = char(32)
    default = ""
  }
  column "Select_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Insert_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Update_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Delete_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Drop_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Reload_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Shutdown_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Process_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "File_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Grant_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "References_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Index_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Alter_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Show_db_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Super_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_tmp_table_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Lock_tables_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Execute_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Repl_slave_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Repl_client_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_view_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Show_view_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_routine_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Alter_routine_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_user_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Event_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Trigger_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_tablespace_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "ssl_type" {
    null    = false
    type    = enum("","ANY","X509","SPECIFIED")
    default = ""
    collate = "utf8_general_ci"
  }
  column "ssl_cipher" {
    null = false
    type = blob
  }
  column "x509_issuer" {
    null = false
    type = blob
  }
  column "x509_subject" {
    null = false
    type = blob
  }
  column "max_questions" {
    null     = false
    type     = int
    default  = 0
    unsigned = true
  }
  column "max_updates" {
    null     = false
    type     = int
    default  = 0
    unsigned = true
  }
  column "max_connections" {
    null     = false
    type     = int
    default  = 0
    unsigned = true
  }
  column "max_user_connections" {
    null     = false
    type     = int
    default  = 0
    unsigned = true
  }
  column "plugin" {
    null    = false
    type    = char(64)
    default = "caching_sha2_password"
  }
  column "authentication_string" {
    null = true
    type = text
  }
  column "password_expired" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "password_last_changed" {
    null = true
    type = timestamp
  }
  column "password_lifetime" {
    null     = true
    type     = smallint
    unsigned = true
  }
  column "account_locked" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Create_role_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Drop_role_priv" {
    null    = false
    type    = enum("N","Y")
    default = "N"
    collate = "utf8_general_ci"
  }
  column "Password_reuse_history" {
    null     = true
    type     = smallint
    unsigned = true
  }
  column "Password_reuse_time" {
    null     = true
    type     = smallint
    unsigned = true
  }
  column "Password_require_current" {
    null    = true
    type    = enum("N","Y")
    collate = "utf8_general_ci"
  }
  column "User_attributes" {
    null = true
    type = json
  }
  primary_key {
    columns = [column.Host, column.User]
  }
}
schema "mysql" {
  charset = "utf8mb4"
  collate = "utf8mb4_0900_ai_ci"
}
