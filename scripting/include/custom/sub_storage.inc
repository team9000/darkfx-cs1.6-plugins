#if defined _sub_storage_included
  #endinput
#endif
#define _sub_storage_included

#pragma reqlib sub_storage

#include <sqlx>

native storage_loadplayer(id);
native storage_saveplayer(id);
native get_playervalue(id, key[], value[], len);
native set_playervalue(id, key[], value[]);

forward storage_loadplayer_fw(id, status);
forward storage_presaveplayer_fw(id);
forward storage_saveplayer_fw(id, status);

forward storage_register_fw();
native storage_reg_playerfield(field[], readonly=0);
native storage_reg_mapfield(field[], readonly=0);

native Handle:storage_get_dbinfo();
native storage_get_debug();
