#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>
#include <sqlx>

#define MYSQL_HOST "127.0.0.1:3306"
#define MYSQL_USER "amxmodx"
#define MYSQL_PASS "jra61jyr65s465f1sgh8"
#define MYSQL_DB "amxmodx"

new Handle:g_DbInfo
new g_DbInfo_init = 0

new DEBUG = 0
new cvar_storage_debug = 0

#define PRIORITYQUEUE_NUM 30
#define MAX_DATALENGTH 128
#define MAX_FIELDLENGTH 32

#define MAX_MAPFIELDS 10

// 0 = inactive
// loading
// 101 = select
// 102 = insert
// saving
// 201 = select
// 202 = insert
// 203 = update
// status update
// 301 = purge check
// 302 = purge remove
new currentaction

new currentprocessing

// 0 = map
// id = player
new currenttarget

new currentattempt

// [0] = action
//     0 = inactive
//     1 = loading
//     2 = saving
// [1] = target
//     0 = map
//     id = player

new priorityqueue[PRIORITYQUEUE_NUM][2]
new lastplayersave

new bool:playerloaded[33]
new Array:playerdata[33]
new Array:playerdata_changed[33]
new Array:playerfields
new Array:playerfields_read
new onlinetimewhenjoined[33]
new timewhenjoined[33]

new bool:maploaded
new Array:mapdata
new Array:mapdata_changed
new Array:mapfields
new Array:mapfields_read

new tick = 0

public debug_print(fmt[], {Float,DoNotUse,_}:...) {
	new message[512]
	vformat(message, 511, fmt, 2)
	client_print(0, print_console, message)
	server_print(message)
}

public plugin_init() {
	register_plugin("Subsys - Storage - MYSQL","T9k","Team9000")

	for(new i = 0; i < 33; i++) {
		playerdata[i] = ArrayCreate(MAX_DATALENGTH)
		playerdata_changed[i] = ArrayCreate()
	}
	playerfields = ArrayCreate(MAX_FIELDLENGTH)
	playerfields_read = ArrayCreate()

	mapdata = ArrayCreate(MAX_DATALENGTH)
	mapdata_changed = ArrayCreate()
	mapfields = ArrayCreate(MAX_FIELDLENGTH)
	mapfields_read = ArrayCreate()

	DEBUG = 0
	currentaction = 0
	currentprocessing = 0
	currenttarget = 0
	currentattempt = 0
	tick = 0

	for(new i = 0; i < PRIORITYQUEUE_NUM; i++) {
		priorityqueue[i][0] = 0
		priorityqueue[i][1] = 0
	}

	lastplayersave = 1

	for(new i = 0; i < 33; i++) {
		playerloaded[i] = false
		timewhenjoined[i] = 0
		onlinetimewhenjoined[i] = 0
	}
	maploaded = false

	load_fields()

	if(!g_DbInfo_init) {
		g_DbInfo = SQL_MakeDbTuple(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB)
		g_DbInfo_init = 1
	}

	cvar_storage_debug = register_cvar("amx_storage_debug", "0")

	set_task(0.2, "updatenow", 0, "", 0, "b")
}

public storage_register_fw() {
	storage_reg_playerfield("steamid")
	storage_reg_playerfield("nick")
	storage_reg_playerfield("lastip")
	storage_reg_playerfield("lasttime")
	storage_reg_playerfield("firsttime")
	storage_reg_playerfield("onlinetime")
	storage_reg_mapfield("id",1)
	storage_reg_mapfield("name")
	storage_reg_mapfield("lasttime")
	storage_reg_mapfield("firsttime")
}

public load_fields() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("storage_register_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}
}

public storage_reg_playerfield_impl(id, numparams) {
	if(numparams < 1 || numparams > 2)
		return log_error(10, "Bad native parameters")

	new fieldname[MAX_FIELDLENGTH]
	get_string(1, fieldname, MAX_FIELDLENGTH-1)
	ArrayPushString(playerfields, fieldname)

	if(numparams >= 2 && get_param(2)) {
		ArrayPushCell(playerfields_read, 1)
	} else {
		ArrayPushCell(playerfields_read, 0)
	}

	return 1
}

public storage_reg_mapfield_impl(id, numparams) {
	if(numparams < 1 || numparams > 2)
		return log_error(10, "Bad native parameters")

	new fieldname[MAX_FIELDLENGTH]
	get_string(1, fieldname, MAX_FIELDLENGTH-1)
	ArrayPushString(mapfields, fieldname)

	if(numparams >= 2 && get_param(2)) {
		ArrayPushCell(mapfields_read, 1)
	} else {
		ArrayPushCell(mapfields_read, 0)
	}

	ArrayPushString(mapdata, "")
	ArrayPushCell(mapdata_changed, 0)

	return 1
}

public priorityqueue_add(action, target) {
	for(new i = 0; i < PRIORITYQUEUE_NUM; i++) {
		if(priorityqueue[i][0] == 0) {
			priorityqueue[i][0] = action
			priorityqueue[i][1] = target
			return i
		}
	}

	return 0
}

public priorityqueue_remove(target) {
	for(new i = 0; i < PRIORITYQUEUE_NUM; i++) {
		if(priorityqueue[i][1] == target) {
			for(new j = i; j < PRIORITYQUEUE_NUM - 2; j++) {
				priorityqueue[j][0] = priorityqueue[j+1][0]
				priorityqueue[j][1] = priorityqueue[j+1][1]
			}
			priorityqueue[PRIORITYQUEUE_NUM-1][0] = 0
			priorityqueue[PRIORITYQUEUE_NUM-1][1] = 0
		}
	}
}

public priorityqueue_extract() {
	if(priorityqueue[0][0]) {
		currenttarget = priorityqueue[0][1]
		if(priorityqueue[0][0] == 1) {
			currentaction = 101
		} else {
			if(currenttarget == 0) {
				if(maploaded) {
					presavecallback(0)
					for(new j = 0; j < ArraySize(mapfields); j++) {
						if(!ArrayGetCell(mapfields_read, j) && ArrayGetCell(mapdata_changed, j)) {
							currentaction = 201
							break
						}
					}
				}
			} else {
				if(playerloaded[currenttarget] && is_user_authorized(currenttarget)) {
					presavecallback(currenttarget)
					for(new j = 0; j < ArraySize(playerfields); j++) {
						if(!ArrayGetCell(playerfields_read, j) && ArrayGetCell(playerdata_changed[currenttarget], j)) {
							currentaction = 201
							break
						}
					}
				}
			}
		}
		currentattempt = 0

		for(new j = 0; j < PRIORITYQUEUE_NUM - 2; j++) {
			priorityqueue[j][0] = priorityqueue[j+1][0]
			priorityqueue[j][1] = priorityqueue[j+1][1]
		}

		priorityqueue[PRIORITYQUEUE_NUM-1][0] = 0
		priorityqueue[PRIORITYQUEUE_NUM-1][1] = 0
	}
}

public client_connect(id) {
	priorityqueue_remove(id)

	playerloaded[id] = false

	for(new i = 0; i < ArraySize(playerfields); i++) {
		ArrayPushString(playerdata[id], "")
		ArrayPushCell(playerdata_changed[id], 0)
	}
}

public is_user_authorized(id) {
	if(!is_user_connected(id) && !is_user_connecting(id)) {
		return false
	}

	new steamid[32]
	get_user_authid(id, steamid, 31)

	if(	equal(steamid, "") ||
		equal(steamid, "STEAM_ID_PENDING") ||
		equal(steamid, "STEAM_ID_LAN") ||
		equal(steamid, "HLTV") ||
		equal(steamid, "BOT")
	) {
		return false
	}

	if(is_user_bot(id) || is_user_hltv(id)) {
		return false
	}

	return true
}

public client_disconnect(id) {
	priorityqueue_remove(id)

	playerloaded[id] = false
}

public plugin_natives() {
	register_library("sub_storage")

	register_native("storage_get_dbinfo","storage_get_dbinfo_impl")
	register_native("storage_get_debug","storage_get_debug_impl")
	register_native("storage_loadplayer","storage_loadplayer_impl")
	register_native("storage_saveplayer","storage_saveplayer_impl")
	register_native("get_playervalue","get_playervalue_impl")
	register_native("set_playervalue","set_playervalue_impl")
	register_native("storage_reg_playerfield","storage_reg_playerfield_impl")
	register_native("storage_reg_mapfield","storage_reg_mapfield_impl")
}

public Handle:storage_get_dbinfo_impl(id, numparams) {
	if(numparams != 0)
		return Handle:log_error(10, "Bad native parameters")

	if(!g_DbInfo_init) {
		g_DbInfo = SQL_MakeDbTuple(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB)
		g_DbInfo_init = 1
	}
	return g_DbInfo
}

public storage_get_debug_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return DEBUG
}

public storage_loadplayer_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)

	priorityqueue_remove(id)
	priorityqueue_add(1, id)

	return 1
}

public storage_saveplayer_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)

	priorityqueue_remove(id)
	priorityqueue_add(2, id)

	return 1
}

public updatenow() {
	DEBUG = get_pcvar_num(cvar_storage_debug)

	if(currentprocessing) {
		return
	}

	if(!currentaction) {
		priorityqueue_extract()
	}

	if(!currentaction) {
		if(!maploaded) {
			currentaction = 101
			currenttarget = 0
			currentattempt = 0
		}
	}

	if(!currentaction) {
		for(new i = 1; i < 33; i++) {
			if(!playerloaded[i] && is_user_authorized(i)) {
				currentaction = 101
				currenttarget = i
				currentattempt = 0
				break
			}
		}
	}

	if(!currentaction) {
		for(new i = 1; i < 36; i++) {
			lastplayersave++
			if(lastplayersave > 32) {
				lastplayersave = -2
			}

			if(lastplayersave == -2) {
				currentaction = 301
				currenttarget = 0
				currentattempt = 0
				break
			} else if(lastplayersave == -1) {
				currentaction = 301
				currenttarget = 1
				currentattempt = 0
				break
			} else if(lastplayersave == 0) {
				if(maploaded) {
					presavecallback(0)
					for(new j = 0; j < ArraySize(mapfields); j++) {
						if(!ArrayGetCell(mapfields_read, j) && ArrayGetCell(mapdata_changed, j)) {
							currentaction = 201
							currenttarget = 0
							currentattempt = 0
							break
						}
					}
					if(currentaction) {
						break
					}
				}
			} else {
				if(playerloaded[lastplayersave] && is_user_authorized(lastplayersave)) {
					presavecallback(lastplayersave)
					for(new j = 0; j < ArraySize(playerfields); j++) {
						if(!ArrayGetCell(playerfields_read, j) && ArrayGetCell(playerdata_changed[lastplayersave], j)) {
							currentaction = 201
							currenttarget = lastplayersave
							currentattempt = 0
							break
						}
					}
					if(currentaction) {
						break
					}
				}
			}
		}
	}

	if(!currentaction) {
		return
	}

	// EMERGENCY PULLOUT CHECK
	if(	(currenttarget > 0 && !playerloaded[currenttarget] && currentaction / 100 == 2) ||
		(currenttarget > 0 && !is_user_authorized(currenttarget) && currentaction / 100 != 3) ||
		(currenttarget == 0 && !maploaded && currentaction / 100 == 2)) {
		currentaction = 0
		if(DEBUG) {
			debug_print("EMERGENCY PULL OUT!")
		}
		return
	}

	tick++
	if(DEBUG) {
		if(currentaction == 101) {
			debug_print("TICK %d - LOADING TARGET #%d (SELECT)", tick, currenttarget)
		} else if(currentaction == 102) {
			debug_print("TICK %d - LOADING TARGET #%d (INSERT)", tick, currenttarget)
		} else if(currentaction == 201) {
			debug_print("TICK %d - SAVING TARGET #%d (SELECT)", tick, currenttarget)
		} else if(currentaction == 202) {
			debug_print("TICK %d - SAVING TARGET #%d (INSERT)", tick, currenttarget)
		} else if(currentaction == 203) {
			debug_print("TICK %d - SAVING TARGET #%d (UPDATE)", tick, currenttarget)
		} else if(currentaction == 301) {
			if(currenttarget == 0) {
				debug_print("TICK %d - CHECKING PURGE DATA - MAP", tick)
			} else {
				debug_print("TICK %d - CHECKING PURGE DATA - PLAYERS", tick)
			}
		} else if(currentaction == 302) {
			debug_print("TICK %d - REMOVING PURGE DATA", tick)
		}
	}

	new data[2]
	data[0] = tick
	if(currenttarget > 0) {
		data[1] = get_user_userid(currenttarget)
	} else {
		data[1] = 0
	}

	if(currentaction == 101) {
		if(currenttarget != 0) {
			new steamid[32]
			get_user_authid(currenttarget, steamid, 31)

			new query[256]
			format(query, 255, "SELECT * FROM storage_players WHERE steamid='%s'", steamid)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[256]
			format(query, 255, "SELECT * FROM storage_maps WHERE name='%s'", mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	} else if(currentaction == 102) {
		if(currenttarget != 0) {
			new steamid[32]
			get_user_authid(currenttarget, steamid, 31)

			new query[256]
			format(query, 255, "INSERT INTO storage_players (steamid) VALUES ('%s')", steamid)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[256]
			format(query, 255, "INSERT INTO storage_maps (name) VALUES ('%s')", mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	} else if(currentaction == 201) {
		if(currenttarget > 0) {
			new steamid[MAX_DATALENGTH] = ""
			for(new i = 0; i < ArraySize(playerfields); i++) {
				new fieldname[MAX_FIELDLENGTH] = ""
				ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
				if(equal(fieldname, "steamid")) {
					ArrayGetString(playerdata[currenttarget], i, steamid, MAX_DATALENGTH)
				}
			}

			new query[256]
			format(query, 255, "SELECT purge_gamedata FROM storage_players WHERE steamid='%s'", steamid)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else if(currenttarget == 0) {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[256]
			format(query, 255, "SELECT purge_gamedata FROM storage_maps WHERE name='%s'", mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	} else if(currentaction == 202) {
		if(currenttarget != 0) {
			new steamid[MAX_DATALENGTH] = ""
			for(new i = 0; i < ArraySize(playerfields); i++) {
				new fieldname[MAX_FIELDLENGTH] = ""
				ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
				if(equal(fieldname, "steamid")) {
					ArrayGetString(playerdata[currenttarget], i, steamid, MAX_DATALENGTH)
				}
			}

			new query[256]
			format(query, 255, "INSERT INTO storage_players (steamid) VALUES ('%s')", steamid)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[256]
			format(query, 255, "INSERT INTO storage_maps (name) VALUES ('%s')", mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	} else if(currentaction == 203) {
		if(currenttarget != 0) {
			new steamid[MAX_DATALENGTH] = ""
			for(new i = 0; i < ArraySize(playerfields); i++) {
				new fieldname[MAX_FIELDLENGTH] = ""
				ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
				if(equal(fieldname, "steamid")) {
					ArrayGetString(playerdata[currenttarget], i, steamid, MAX_DATALENGTH)
				}
			}

			new query[2048]
			format(query, 2047, "UPDATE storage_players SET ")
			new firstblock = 1
			for(new i = 0; i < ArraySize(playerfields); i++) {
				new fieldname[MAX_FIELDLENGTH] = ""
				ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
				if(!equal(fieldname, "steamid") && !ArrayGetCell(playerfields_read, i) && ArrayGetCell(playerdata_changed[currenttarget], i)) {
					if(!firstblock) {
						format(query, 2047, "%s, ", query)
					}
					firstblock = 0

					format(query, 2047, "%s%a='%a'", query, ArrayGetStringHandle(playerfields, i), ArrayGetStringHandle(playerdata[currenttarget], i))
					ArraySetCell(playerdata_changed[currenttarget], i, 0)
				}
			}
			format(query, 2047, "%s WHERE steamid='%s' AND purge_gamedata='0'", query, steamid)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[2048]
			format(query, 2047, "UPDATE storage_maps SET ")
			new firstblock = 1
			for(new i = 0; i < ArraySize(mapfields); i++) {
				new fieldname[MAX_FIELDLENGTH] = ""
				ArrayGetString(mapfields, i, fieldname, MAX_FIELDLENGTH)
				if(!equal(fieldname, "name") && !ArrayGetCell(mapfields_read, i) && ArrayGetCell(mapdata_changed, i)) {
					if(!firstblock) {
						format(query, 2047, "%s, ", query)
					}
					firstblock = 0
					format(query, 2047, "%s%a='%a'", query, ArrayGetStringHandle(mapfields, i), ArrayGetStringHandle(mapdata, i))
					ArraySetCell(mapdata_changed, i, 0)
				}
			}
			format(query, 2047, "%s WHERE name='%s' AND purge_gamedata='0'", query, mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	} else if(currentaction == 301) {
		if(currenttarget != 0) {
			new query[2048]
			format(query, 2047, "SELECT steamid FROM storage_players WHERE purge_gamedata='1' AND (1=0")

			for(new i = 1; i <= 32; i++) {
				if(playerloaded[i] && is_user_authorized(i)) {
					new steamid[32]
					get_user_authid(i, steamid, 31)

					format(query, 2047, "%s OR steamid='%s'", query, steamid)
				}
			}
			format(query, 2047, "%s)", query)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		} else {
			new mapname[32], mapname_striped[32]
			get_mapname(mapname,31)
			mysql_strip(mapname, mapname_striped, 31)

			new query[2048]
			format(query, 2047, "SELECT name FROM storage_maps WHERE purge_gamedata='1' AND name='%s'", mapname_striped)

			SQL_ThreadQuery(g_DbInfo, "QueryHandled", query, data, 2)
			if(DEBUG) {
				debug_print("%s", query)
			}

			currentprocessing = 1
		}
	}
}

public storage_loadplayer_fw(id, status) {
	if(id > 0) {
		timewhenjoined[id] = time_time()
		new value[128]
		get_playervalue(id, "onlinetime", value, 127)
		onlinetimewhenjoined[id] = str_to_num(value)
	}
}

public storage_presaveplayer_fw(id) {
	if(id > 0) {
		new nick[33], nick_striped[33]
		get_user_name(id, nick, 32)

		mysql_strip(nick, nick_striped, 32)

		set_playervalue(id, "nick", nick_striped)

		new currentip[32]
		get_user_ip(id, currentip, 31, 1)
		set_playervalue(id, "lastip", currentip)

		new lasttime[32]
		format(lasttime, 31, "%d", time_time())
		set_playervalue(id, "lasttime", lasttime)

		new value[128]
		if(time_time() - timewhenjoined[id] < -1 || time_time() - timewhenjoined[id] > 60) {
			get_playervalue(id, "onlinetime", value, 127)
			timewhenjoined[id] = time_time()
			onlinetimewhenjoined[id] = str_to_num(value)
		} else {
			format(value, 127, "%d", onlinetimewhenjoined[id]+(time_time() - timewhenjoined[id]))
			set_playervalue(id, "onlinetime", value)
		}

		new firsttime[32]
		new result = get_playervalue(id, "firsttime", firsttime, 31)
		if(result) {
			if(equal(firsttime, "0")) {
				set_playervalue(id, "firsttime", lasttime)
			}
		}
	} else {
		new lasttime[32]
		format(lasttime, 31, "%d", time_time())
		set_playervalue(0, "lasttime", lasttime)

		new firsttime[32]
		new result = get_playervalue(0, "firsttime", firsttime, 31)
		if(result) {
			if(equal(firsttime, "0")) {
				set_playervalue(0, "firsttime", lasttime)
			}
		}
	}
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, DEBUG)) {
		currentattempt++
		if(currentattempt == 5) {
			log_message("CONNECTION TO MYSQL DATABASE LOST - UNLOADED ALL PLAYERS")
			if(DEBUG) {
				debug_print("CONNECTION TO MYSQL DATABASE LOST - UNLOADED ALL PLAYERS")
			}
			for(new i = 0; i < 33; i++) {
				if(is_user_connected(i) || is_user_connecting(i)) {
					playerloaded[i] = false
					loadcallback(i,0)
				}
			}
		}
	}

	if(!currentprocessing) {
		currentaction = 0
		currentprocessing = 0
		if(DEBUG) {
			debug_print("NOT PROCESSING ON HANDLER!")
		}
		return
	}
	if(!currentaction) {
		currentaction = 0
		currentprocessing = 0
		if(DEBUG) {
			debug_print("NO ACTION ON QUERY RETURNED!")
		}
		return
	}

	if(data[0] != tick ||
	(currenttarget == 0 && data[1] != 0) ||
	(currenttarget > 0 && data[1] != get_user_userid(currenttarget))
	) {
		currentaction = 0
		currentprocessing = 0
		if(DEBUG) {
			debug_print("QUERY RETURNED IS OFF SYNCED!")
		}
		return
	}

	if(DEBUG) {
		if(currentaction == 101) {
			debug_print("TICK %d - LOADING TARGET #%d (SELECT-)", tick, currenttarget)
		} else if(currentaction == 102) {
			debug_print("TICK %d - LOADING TARGET #%d (INSERT-)", tick, currenttarget)
		} else if(currentaction == 201) {
			debug_print("TICK %d - SAVING TARGET #%d (SELECT-)", tick, currenttarget)
		} else if(currentaction == 202) {
			debug_print("TICK %d - SAVING TARGET #%d (INSERT-)", tick, currenttarget)
		} else if(currentaction == 203) {
			debug_print("TICK %d - SAVING TARGET #%d (UPDATE-)", tick, currenttarget)
		} else if(currentaction == 301) {
			debug_print("TICK %d - CHECKING PURGE DATA-", tick)
		} else if(currentaction == 302) {
			debug_print("TICK %d - REMOVING PURGE DATA-", tick)
		}
	}

	new resend = 0

	if(currentaction == 101) {
		if(currenttarget != 0) {
			if(!failstate) {
				if(SQL_NumResults(query) > 0) {
					for(new i = 0; i < ArraySize(playerfields); i++) {
						new fieldname[MAX_FIELDLENGTH]
						ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
						new colnum = SQL_FieldNameToNum(query, fieldname)
						if(colnum != -1) {
							new dataread[MAX_DATALENGTH]
							SQL_ReadResult(query, colnum, dataread, MAX_DATALENGTH)
							ArraySetString(playerdata[currenttarget], i, dataread)
						}
						ArraySetCell(playerdata_changed[currenttarget], i, 0)
					}

					playerloaded[currenttarget] = true
					loadcallback(currenttarget,1)
					currentaction = 0
				} else {
					currentaction = 102
				}
			} else {
				resend = 1
			}
		} else {
			if(!failstate) {
				if(SQL_NumResults(query) > 0) {
					for(new i = 0; i < ArraySize(mapfields); i++) {
						new fieldname[MAX_FIELDLENGTH]
						ArrayGetString(mapfields, i, fieldname, MAX_FIELDLENGTH)
						new colnum = SQL_FieldNameToNum(query, fieldname)
						if(colnum != -1) {
							new dataread[MAX_DATALENGTH]
							SQL_ReadResult(query, colnum, dataread, MAX_DATALENGTH)
							ArraySetString(mapdata, i, dataread)
						}
						ArraySetCell(mapdata_changed, i, 0)
					}

					maploaded = true
					loadcallback(currenttarget,1)
					currentaction = 0
				} else {
					currentaction = 102
				}
			} else {
				resend = 1
			}
		}
	} else if(currentaction == 102) {
		if(!failstate) {
			currentaction = 101
		} else {
			resend = 1
		}
	} else if(currentaction == 201) {
		if(currenttarget != 0) {
			if(!failstate) {
				if(SQL_NumResults(query) > 0) {
					new colnum = SQL_FieldNameToNum(query, "purge_gamedata")
					if(colnum != -1) {
						new purgecheck = SQL_ReadResult(query, colnum)

						if(purgecheck == 0) {
							currentaction = 203
						} else {
							currentaction = 0
						}
					} else {
						currentaction = 203
					}
				} else {
					currentaction = 202
				}
			} else {
				resend = 1
			}
		} else {
			if(!failstate) {
				if(SQL_NumResults(query) > 0) {
					new colnum = SQL_FieldNameToNum(query, "purge_gamedata")
					if(colnum != -1) {
						new purgecheck = SQL_ReadResult(query, colnum)

						if(purgecheck == 0) {
							currentaction = 203
						} else {
							currentaction = 0
						}
					} else {
						currentaction = 203
					}
				} else {
					currentaction = 202
				}
			} else {
				resend = 1
			}
		}
	} else if(currentaction == 202) {
		if(!failstate) {
			currentaction = 201
		} else {
			resend = 1
		}
	} else if(currentaction == 203) {
		if(!failstate) {
			savecallback(currenttarget,1)
			currentaction = 0
		} else {
			resend = 1
		}
	} else if(currentaction == 301) {
		if(currenttarget != 0) {
			if(!failstate) {
				new querystr[2048], foundone = 0
				format(querystr, 2047, "UPDATE storage_players SET purge_gamedata='0' WHERE 1=0")

				for(new i = 0; i < SQL_NumResults(query); i++) {
					new steamid[32] = ""
					new colnum = SQL_FieldNameToNum(query, "steamid")
					if(colnum != -1) {
						SQL_ReadResult(query, colnum, steamid, 31)
					}

					for(new i = 1; i <= 32; i++) {
						if(playerloaded[i] && is_user_authorized(i)) {
							new steamid2[32]
							get_user_authid(i, steamid2, 31)

							if(equal(steamid, steamid2)) {
								playerloaded[i] = false	// FAIL AND UNLOAD,
								loadcallback(i,0)	// WERE SUPPOSED TO RELOAD IT!
								format(querystr, 2047, "%s OR steamid='%s'", querystr, steamid)
								foundone = 1
							}
						}
					}
					SQL_NextRow(query)
				}

				if(foundone) {
					currentaction = 302
					SQL_ThreadQuery(g_DbInfo, "QueryHandled", querystr, data, 2)
					return
				} else {
					currentaction = 0
				}
			} else {
				resend = 1
			}
		} else {
			if(!failstate) {
				if(SQL_NumResults(query) > 0) {
					new mapname[32], mapname_striped[32]
					get_mapname(mapname,31)
					mysql_strip(mapname, mapname_striped, 31)

					new querystr[512]
					format(querystr, 511, "UPDATE storage_maps SET purge_gamedata='0' WHERE name='%s'", mapname_striped)

					maploaded = false	// FAIL AND UNLOAD,
					loadcallback(0,0)	// WERE SUPPOSED TO RELOAD IT!

					currentaction = 302
					SQL_ThreadQuery(g_DbInfo, "QueryHandled", querystr, data, 2)
					return
				} else {
					currentaction = 0
				}
			} else {
				resend = 1
			}
		}
	} else if(currentaction == 302) {
		if(!failstate) {
			currentaction = 0
		} else {
			resend = 1
		}
	}

	if(DEBUG) {
		debug_print("End of query return")
	}
	currentprocessing = 0

	if(currentaction && resend) {
		new queryran[2048]
		SQL_GetQueryString(query, queryran, 2047)

		SQL_ThreadQuery(g_DbInfo, "QueryHandled", queryran, data, 2)

		currentprocessing = 1
		if(DEBUG) debug_print("QUERY RESENT!")
	}
}

public loadcallback(id, status) {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("storage_loadplayer_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_push_int(status)
				callfunc_end()
			}
		}
	}
}

public presavecallback(id) {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("storage_presaveplayer_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}
}

public savecallback(id, status) {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("storage_saveplayer_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_push_int(status)
				callfunc_end()
			}
		}
	}
}

public get_playervalue_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new key[MAX_FIELDLENGTH]
	get_string(2, key, MAX_FIELDLENGTH)

	if((id != 0 && !playerloaded[id]) || (id == 0 && !maploaded)) {
		set_string(3, "", get_param(4))
		return 0
	}

	if(id != 0) {
		for(new i = 0; i < ArraySize(playerfields); i++) {
			new fieldname[MAX_FIELDLENGTH]
			ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
			if(equal(fieldname, key)) {
				new dataget[MAX_DATALENGTH]
				ArrayGetString(playerdata[id], i, dataget, MAX_DATALENGTH)
				set_string(3, dataget, get_param(4))
				return 1
			}
		}
	} else {
		for(new i = 0; i < ArraySize(mapfields); i++) {
			new fieldname[MAX_FIELDLENGTH]
			ArrayGetString(mapfields, i, fieldname, MAX_FIELDLENGTH)
			if(equal(fieldname, key)) {
				new dataget[MAX_DATALENGTH]
				ArrayGetString(mapdata, i, dataget, MAX_DATALENGTH)
				set_string(3, dataget, get_param(4))
				return 1
			}
		}
	}

	log_message("Unknown storage key on get! Key: %s ID: %d", key, id)
	set_string(3, "", get_param(4))
	return 0
}

public set_playervalue_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new key[64]
	get_string(2, key, 63)
	new value[MAX_FIELDLENGTH]
	get_string(3, value, MAX_FIELDLENGTH)

	if((id != 0 && !playerloaded[id]) || (id == 0 && !maploaded)) {
		set_string(3, "", get_param(4))
		return 0
	}

	if(id != 0) {
		for(new i = 0; i < ArraySize(playerfields); i++) {
			new fieldname[MAX_FIELDLENGTH]
			ArrayGetString(playerfields, i, fieldname, MAX_FIELDLENGTH)
			if(equal(fieldname, key)) {
				new dataget[MAX_DATALENGTH]
				ArrayGetString(playerdata[id], i, dataget, MAX_DATALENGTH)
				if(!equal(dataget, value)) {
					ArraySetString(playerdata[id], i, value)
					ArraySetCell(playerdata_changed[id], i, 1)
				}
				return 1
			}
		}
	} else {
		for(new i = 0; i < ArraySize(mapfields); i++) {
			new fieldname[MAX_FIELDLENGTH]
			ArrayGetString(mapfields, i, fieldname, MAX_FIELDLENGTH)
			if(equal(fieldname, key)) {
				new dataget[MAX_DATALENGTH]
				ArrayGetString(mapdata, i, dataget, MAX_DATALENGTH)
				if(!equal(dataget, value)) {
					ArraySetString(mapdata, i, value)
					ArraySetCell(mapdata_changed, i, 1)
				}
				return 1
			}
		}
	}

	log_message("Unknown storage key on set! Key: %s ID: %d", key, id)
	return 0
}
