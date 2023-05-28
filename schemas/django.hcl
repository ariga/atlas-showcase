table "auth_group" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "name" {
    null = false
    type = character_varying(150)
  }
  primary_key {
    columns = [column.id]
  }
  index "auth_group_name_a6ea08ec_like" {
    on {
      column = column.name
      ops    = varchar_pattern_ops
    }
  }
  index "auth_group_name_key" {
    unique  = true
    columns = [column.name]
  }
}
table "auth_group_permissions" {
  schema = schema.public
  column "id" {
    null = false
    type = bigint
    identity {
      generated = BY_DEFAULT
    }
  }
  column "group_id" {
    null = false
    type = integer
  }
  column "permission_id" {
    null = false
    type = integer
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "auth_group_permissio_permission_id_84c5c92e_fk_auth_perm" {
    columns     = [column.permission_id]
    ref_columns = [table.auth_permission.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "auth_group_permissions_group_id_b120cbf9_fk_auth_group_id" {
    columns     = [column.group_id]
    ref_columns = [table.auth_group.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "auth_group_permissions_group_id_b120cbf9" {
    columns = [column.group_id]
  }
  index "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" {
    unique  = true
    columns = [column.group_id, column.permission_id]
  }
  index "auth_group_permissions_permission_id_84c5c92e" {
    columns = [column.permission_id]
  }
}
table "auth_permission" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "name" {
    null = false
    type = character_varying(255)
  }
  column "content_type_id" {
    null = false
    type = integer
  }
  column "codename" {
    null = false
    type = character_varying(100)
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "auth_permission_content_type_id_2f476e4b_fk_django_co" {
    columns     = [column.content_type_id]
    ref_columns = [table.django_content_type.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "auth_permission_content_type_id_2f476e4b" {
    columns = [column.content_type_id]
  }
  index "auth_permission_content_type_id_codename_01ab375a_uniq" {
    unique  = true
    columns = [column.content_type_id, column.codename]
  }
}
table "auth_user" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "password" {
    null = false
    type = character_varying(128)
  }
  column "last_login" {
    null = true
    type = timestamptz
  }
  column "is_superuser" {
    null = false
    type = boolean
  }
  column "username" {
    null = false
    type = character_varying(150)
  }
  column "first_name" {
    null = false
    type = character_varying(150)
  }
  column "last_name" {
    null = false
    type = character_varying(150)
  }
  column "email" {
    null = false
    type = character_varying(254)
  }
  column "is_staff" {
    null = false
    type = boolean
  }
  column "is_active" {
    null = false
    type = boolean
  }
  column "date_joined" {
    null = false
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  index "auth_user_username_6821ab7c_like" {
    on {
      column = column.username
      ops    = varchar_pattern_ops
    }
  }
  index "auth_user_username_key" {
    unique  = true
    columns = [column.username]
  }
}
table "auth_user_groups" {
  schema = schema.public
  column "id" {
    null = false
    type = bigint
    identity {
      generated = BY_DEFAULT
    }
  }
  column "user_id" {
    null = false
    type = integer
  }
  column "group_id" {
    null = false
    type = integer
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "auth_user_groups_group_id_97559544_fk_auth_group_id" {
    columns     = [column.group_id]
    ref_columns = [table.auth_group.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "auth_user_groups_user_id_6a12ed8b_fk_auth_user_id" {
    columns     = [column.user_id]
    ref_columns = [table.auth_user.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "auth_user_groups_group_id_97559544" {
    columns = [column.group_id]
  }
  index "auth_user_groups_user_id_6a12ed8b" {
    columns = [column.user_id]
  }
  index "auth_user_groups_user_id_group_id_94350c0c_uniq" {
    unique  = true
    columns = [column.user_id, column.group_id]
  }
}
table "auth_user_user_permissions" {
  schema = schema.public
  column "id" {
    null = false
    type = bigint
    identity {
      generated = BY_DEFAULT
    }
  }
  column "user_id" {
    null = false
    type = integer
  }
  column "permission_id" {
    null = false
    type = integer
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm" {
    columns     = [column.permission_id]
    ref_columns = [table.auth_permission.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id" {
    columns     = [column.user_id]
    ref_columns = [table.auth_user.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "auth_user_user_permissions_permission_id_1fbb5f2c" {
    columns = [column.permission_id]
  }
  index "auth_user_user_permissions_user_id_a95ead1b" {
    columns = [column.user_id]
  }
  index "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" {
    unique  = true
    columns = [column.user_id, column.permission_id]
  }
}
table "django_admin_log" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "action_time" {
    null = false
    type = timestamptz
  }
  column "object_id" {
    null = true
    type = text
  }
  column "object_repr" {
    null = false
    type = character_varying(200)
  }
  column "action_flag" {
    null = false
    type = smallint
  }
  column "change_message" {
    null = false
    type = text
  }
  column "content_type_id" {
    null = true
    type = integer
  }
  column "user_id" {
    null = false
    type = integer
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "django_admin_log_content_type_id_c4bce8eb_fk_django_co" {
    columns     = [column.content_type_id]
    ref_columns = [table.django_content_type.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "django_admin_log_user_id_c564eba6_fk_auth_user_id" {
    columns     = [column.user_id]
    ref_columns = [table.auth_user.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "django_admin_log_content_type_id_c4bce8eb" {
    columns = [column.content_type_id]
  }
  index "django_admin_log_user_id_c564eba6" {
    columns = [column.user_id]
  }
  check "django_admin_log_action_flag_check" {
    expr = "(action_flag >= 0)"
  }
}
table "django_content_type" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "app_label" {
    null = false
    type = character_varying(100)
  }
  column "model" {
    null = false
    type = character_varying(100)
  }
  primary_key {
    columns = [column.id]
  }
  index "django_content_type_app_label_model_76bd3d3b_uniq" {
    unique  = true
    columns = [column.app_label, column.model]
  }
}
table "django_session" {
  schema = schema.public
  column "session_key" {
    null = false
    type = character_varying(40)
  }
  column "session_data" {
    null = false
    type = text
  }
  column "expire_date" {
    null = false
    type = timestamptz
  }
  primary_key {
    columns = [column.session_key]
  }
  index "django_session_expire_date_a5c62663" {
    columns = [column.expire_date]
  }
  index "django_session_session_key_c0390e0f_like" {
    on {
      column = column.session_key
      ops    = varchar_pattern_ops
    }
  }
}
schema "public" {
}
