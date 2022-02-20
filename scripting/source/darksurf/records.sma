#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <darksurf.inc>
#include <sub_storage>

new loaded, trying, querying

public plugin_init() {
   	register_plugin("DARKSURF - RECORDS","T9k","Team9000")

	loaded = 0
	trying = 0
	querying = 0

	return PLUGIN_CONTINUE
}

public record_query() {
savenow()
	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new query[512]
	format(query, 511, "SELECT surf_record_time, surf_record_hangtime, surf_record_speed, surf_record_dist, surf_record_height FROM storage_maps where name='%s'", mapname_striped)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_load", query)
}


public QueryHandled_load(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[512]
		SQL_GetQueryString(query, queryran, 511)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_load", queryran, data, size)
	} else {
		if(SQL_NumResults(query) > 0) {
			loaded = 1
			new value[1024], left[32], right[1024]

			new colnum = SQL_FieldNameToNum(query, "surf_record_time")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record_time[i] = 0.0
						copy(record_time_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record_time[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_time_id[i], 31, left)
					copy(value, 1023, right)
				}
			} else {
				loaded = 0
			}

			colnum = SQL_FieldNameToNum(query, "surf_record_hangtime")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record_hangtime[i] = 0.0
						copy(record_hangtime_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record_hangtime[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_hangtime_id[i], 31, left)
					copy(value, 1023, right)
				}
			} else {
				loaded = 0
			}

			colnum = SQL_FieldNameToNum(query, "surf_record_speed")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record_speed[i] = 0.0
						copy(record_speed_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record_speed[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_speed_id[i], 31, left)
					copy(value, 1023, right)
				}
			} else {
				loaded = 0
			}

			colnum = SQL_FieldNameToNum(query, "surf_record_dist")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record_dist[i] = 0.0
						copy(record_dist_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record_dist[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_dist_id[i], 31, left)
					copy(value, 1023, right)
				}
			} else {
				loaded = 0
			}

			colnum = SQL_FieldNameToNum(query, "surf_record_height")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 1023)
				for(new i = 0; i < 15; i++) {
					if(equal(value, "")) {
						record_height[i] = 0.0
						copy(record_height_id[i], 31, "0")
						continue
					}
					strtok(value, left, 31, right, 1023, ' ')
					record_height[i] = str_to_float(left)
					copy(value, 1023, right)

					strtok(value, left, 31, right, 1023, ' ')
					copy(record_height_id[i], 31, left)
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
	register_library("darksurf_records")

	register_native("surf_submitrecord","surf_submitrecord_impl")
}

public surf_checkrecord_impl(id, numparams) {
	if(numparams != 4)	
		return log_error(10, "Bad native parameters")

	if(!loaded) {
		return 0
	}

	new id = get_param(1)
	new Float:amount = get_param_f(2)
	new record = get_param(3)
	new higher = get_param(4)

	if(amount == 0.0) {
		return 0
	}

	new Float:records[15], records_id[15][32]

	for(new i = 0; i < 15; i++) {
		if(record == 1) {
			records[i] = record_time[i]
			copy(records_id[i], 31, record_time_id[i])
		} else if(record == 2) {
			records[i] = record_hangtime[i]
			copy(records_id[i], 31, record_hangtime_id[i])
		} else if(record == 3) {
			records[i] = record_speed[i]
			copy(records_id[i], 31, record_speed_id[i])
		} else if(record == 4) {
			records[i] = record_dist[i]
			copy(records_id[i], 31, record_dist_id[i])
		} else if(record == 5) {
			records[i] = record_height[i]
			copy(records_id[i], 31, record_height_id[i])
		}
	}

	new place = -1
	for(new i = 0; i < 15; i++) {
		if(equal(records_id[i], "0") || (amount >= records[i] && higher != 2) || (amount <= records[i] && higher == 2)) {
			place = i
			break
		}
	}

	if(place == -1) {
		return 0
	}

	new oldplace = -1, steamid[32]
	get_user_authid(id, steamid, 31)
	for(new i = 0; i < 15; i++) {
		if(equal(records_id[i], steamid)) {
			oldplace = i
			break
		}
	}

	if(oldplace != -1 && place > oldplace) {
		return 0
	}

	if(oldplace != -1) {
		for(new i = oldplace; i < 14; i++) {
			records[i] = records[i+1]
			copy(records_id[i], 31, records_id[i+1])
		}
	}

	for(new i = 14; i > place; i--) {
		records[i] = records[i-1]
		copy(records_id[i], 31, records_id[i-1])
	}

	records[place] = amount
	get_user_authid(id, records_id[place], 31)

	for(new i = 0; i < 15; i++) {
		if(record == 1) {
			record_time[i] = records[i]
			copy(record_time_id[i], 31, records_id[i])
		} else if(record == 2) {
			record_hangtime[i] = records[i]
			copy(record_hangtime_id[i], 31, records_id[i])
		} else if(record == 3) {
			record_speed[i] = records[i]
			copy(record_speed_id[i], 31, records_id[i])
		} else if(record == 4) {
			record_dist[i] = records[i]
			copy(record_dist_id[i], 31, records_id[i])
		} else if(record == 5) {
			record_height[i] = records[i]
			copy(record_height_id[i], 31, records_id[i])
		}
	}

//	server_print("new record new-%d old-%d amount-%f record-%d", place, oldplace, amount, record)

	save(record)
	return place+1
}

public surf_get_numrecords_impl(id, numparams) {
	if(numparams != 1)	
		return log_error(10, "Bad native parameters")

	if(!loaded) {
		return 0
	}

	new record = get_param(1)

	new Float:records[15]

	for(new i = 0; i < 15; i++) {
		if(record == 1) {
			records[i] = record_time[i]
		} else if(record == 2) {
			records[i] = record_hangtime[i]
		} else if(record == 3) {
			records[i] = record_speed[i]
		} else if(record == 4) {
			records[i] = record_dist[i]
		} else if(record == 5) {
			records[i] = record_height[i]
		}
	}

	for(new i = 0; i < 15; i++) {
		if(records[i] == 0.0) {
			return i
		}
	}
	return 15
}

public save(record) {
	tosave[record] = 1
}

public savenow() {
	if(querying || (!tosave[1] && !tosave[2] && !tosave[3] && !tosave[4] && !tosave[5])) {
		return
	}
	if(querying) return;

	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)

	mysql_strip(current_map, current_map_striped, 31)

	new query[4096]
	format(query, 4095, "UPDATE storage_maps SET ")
	new writecomma = 0

	if(tosave[1]) {
		tosave[1] = 0
		if(writecomma) {
			format(query, 4095, "%s, ", query)
		}
		format(query, 4095, "%ssurf_record_time='", query)
		for(new i = 0; i < 15; i++) {
			if(i != 0) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%f %s", query, record_time[i], record_time_id[i])
		}
		format(query, 4095, "%s'", query)
		writecomma = 1
	}
	if(tosave[2]) {
		tosave[2] = 0
		if(writecomma) {
			format(query, 4095, "%s, ", query)
		}
		format(query, 4095, "%ssurf_record_hangtime='", query)
		for(new i = 0; i < 15; i++) {
			if(i != 0) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%f %s", query, record_hangtime[i], record_hangtime_id[i])
		}
		format(query, 4095, "%s'", query)
		writecomma = 1
	}
	if(tosave[3]) {
		tosave[3] = 0
		if(writecomma) {
			format(query, 4095, "%s, ", query)
		}
		format(query, 4095, "%ssurf_record_speed='", query)
		for(new i = 0; i < 15; i++) {
			if(i != 0) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%f %s", query, record_speed[i], record_speed_id[i])
		}
		format(query, 4095, "%s'", query)
		writecomma = 1
	}
	if(tosave[4]) {
		tosave[4] = 0
		if(writecomma) {
			format(query, 4095, "%s, ", query)
		}
		format(query, 4095, "%ssurf_record_dist='", query)
		for(new i = 0; i < 15; i++) {
			if(i != 0) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%f %s", query, record_dist[i], record_dist_id[i])
		}
		format(query, 4095, "%s'", query)
		writecomma = 1
	}
	if(tosave[5]) {
		tosave[5] = 0
		if(writecomma) {
			format(query, 4095, "%s, ", query)
		}
		format(query, 4095, "%ssurf_record_height='", query)
		for(new i = 0; i < 15; i++) {
			if(i != 0) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%f %s", query, record_height[i], record_height_id[i])
		}
		format(query, 4095, "%s'", query)
		writecomma = 1
	}

	format(query, 4095, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_save", query)
	querying = 1
}
