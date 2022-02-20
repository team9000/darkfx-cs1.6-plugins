#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <darkclimb.inc>
#include <sub_storage>

new loaded, trying
new Float:record[15]
new record_cps[15]
new record_id[15][32]

new tosave
new querying

public plugin_init() {
   	register_plugin("DARKCLIMB - RECORDS","T9k","Team9000")

	loaded = 0
	trying = 0

	tosave = 0
	querying = 0

	set_task(10.0, "savenow", 0, "", 0, "b")

	return PLUGIN_CONTINUE
}

public storage_loadplayer_fw(id, status) {
	if(id == 0 && status && !loaded && !trying) {
		trying = 1
		set_task(0.5, "record_query")
	}
}

public record_query() {
	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new query[512]
	format(query, 511, "SELECT climb_record FROM storage_maps where name='%s'", mapname_striped)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_load", query)
}

public QueryHandled_load(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_load", queryran, data, size)
	} else {
		if(SQL_NumResults(query) > 0) {
			loaded = 1
			new value[1024], left[32], right[1024]

			new colnum = SQL_FieldNameToNum(query, "climb_record")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record[i] = 0.0
						copy(record_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					record_cps[i] = str_to_num(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_id[i], 31, left)
					copy(value, 1023, right)
				}
			} else {
				loaded = 0
			}
		}
	}
}

public QueryHandled_save(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_save", queryran, data, size)
	} else {
		querying = 0
	}
}

public plugin_natives() {
	register_library("darkclimb_records")

	register_native("climb_checkrecord","climb_checkrecord_impl")
	register_native("climb_get_numrecords","climb_get_numrecords_impl")
}

public climb_checkrecord_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(!loaded) {
		return 0
	}

	new id = get_param(1)
	new Float:timer = get_param_f(2)
	new checkpoints = get_param(3)

	if(timer == 0.0) {
		return 0
	}

	new place = -1
	for(new i = 0; i < 15; i++) {
		if(equal(record_id[i], "0")) {
			place = i
			break
		}
		if(checkpoints == 0 && record_cps[i] != 0) {
			place = i
			break
		}
		if((checkpoints != 0 && record_cps[i] != 0) || (checkpoints == 0 && record_cps[i] == 0)) {
			if(timer <= record[i]) {
				place = i
				break
			}
		}
	}

	if(place == -1) {
		return 0
	}

	new oldplace = -1, steamid[32]
	get_user_authid(id, steamid, 31)
	for(new i = 0; i < 15; i++) {
		if(equal(record_id[i], steamid)) {
			oldplace = i
			break
		}
	}

	if(oldplace != -1 && place > oldplace) {
		return 0
	}

	if(oldplace != -1) {
		for(new i = oldplace; i < 14; i++) {
			record[i] = record[i+1]
			record_cps[i] = record_cps[i+1]
			copy(record_id[i], 31, record_id[i+1])
		}
	}

	for(new i = 14; i > place; i--) {
		record[i] = record[i-1]
		record_cps[i] = record_cps[i-1]
		copy(record_id[i], 31, record_id[i-1])
	}

	record[place] = timer
	record_cps[place] = checkpoints
	get_user_authid(id, record_id[place], 31)

//	server_print("new record new-%d old-%d amount-%f record-%d", place, oldplace, amount, record)

	tosave = 1
	return place+1
}

public climb_get_numrecords_impl(id, numparams) {
	if(numparams != 0)	
		return log_error(10, "Bad native parameters")

	if(!loaded) {
		return 0
	}

	for(new i = 0; i < 15; i++) {
		if(record[i] == 0.0) {
			return i
		}
	}
	return 15
}

public savenow() {
	if(querying || !tosave) {
		return
	}

	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[4096]
	format(query, 4095, "UPDATE storage_maps SET ")

	tosave = 0
	format(query, 4095, "%sclimb_record='", query)
	for(new i = 0; i < 15; i++) {
		if(i != 0) {
			format(query, 4095, "%s ", query)
		}
		format(query, 4095, "%s%f %d %s", query, record[i], record_cps[i], record_id[i])
	}
	format(query, 4095, "%s'", query)

	format(query, 4095, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_save", query)
	querying = 1
}
