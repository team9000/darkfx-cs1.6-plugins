#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <darksurf.inc>
#include <sub_roundtime>
#include <sub_storage>
#include <sub_disqualify>
#include <fun>
#include <sub_damage>
#include <sub_respawn>

new loaded, times_sum, times_num

public plugin_init() {
   	register_plugin("DARKSURF - MAP WORTH","T9k","Team9000");

	loaded = 0;
	times_sum = 0;
	times_num = 0;
	average_query();

	return PLUGIN_CONTINUE;
}

public average_query() {
	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new query[512]
	format(query, 511, "SELECT surf_times_sum, surf_times_num FROM storage_maps where name='%s'", mapname_striped)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", query)
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", queryran, data, size)
		return;
	}

	if(SQL_NumResults(query) <= 0)
		return;

	new value[128]

	new colnum = SQL_FieldNameToNum(query, "surf_times_sum")
	if(colnum == -1)
		return;

	SQL_ReadResult(query, colnum, value, 127)
	times_sum = str_to_num(value)

	colnum = SQL_FieldNameToNum(query, "surf_times_num")
	if(colnum == -1)
		return;

	SQL_ReadResult(query, colnum, value, 127)
	times_num = str_to_num(value)

	loaded = 1;
}

public save_average() {
	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[256]
	format(query, 255, "UPDATE storage_maps SET ")

	format(query, 255, "%ssurf_times_sum='%d', ", query, times_sum)
	format(query, 255, "%ssurf_times_num='%d' ", query, times_num)
	format(query, 255, "%sWHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[256]
		SQL_GetQueryString(query, queryran, 255)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public plugin_natives() {
	register_library("darksurf_mapworth")

	register_native("surf_mapworth_add","surf_mapworth_add_impl")
	register_native("surf_mapworth_get","surf_mapworth_get_impl")
}

public surf_mapworth_add_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	if(!loaded) return;

	new Float:time = get_param_f(1);

	new Float:old_average = 0;
	if(times_num > 0)
		old_average = float(times_sum) / float(times_num);

	if(time > old_average * 5 && times_num > 20)
		return; // outlier - don't add

	times_sum += floatround(time);
	times_num++;
	save_average();
}

public surf_mapworth_get_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")
	if(!loaded) return -1;

	if(times_num == 0) return 0;
	return times_sum / times_num;
}
