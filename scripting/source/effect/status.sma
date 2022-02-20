#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>
#include <sub_time>

public plugin_init() {
	register_plugin("Effect - Online Status","T9k","Team9000")

	set_task(15.0, "savenow")
}

public savenow() {
	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new ident[32]
	get_cvar_string("amx_server_ident_status", ident, 31)

	if(equal(ident, "")) {
		set_task(15.0, "savenow")
		return
	}

	new query[256]
	format(query, 255, "UPDATE hlds SET lasttime='%d', players='%d', slots='%d', map='%s' WHERE server='%s'", time_time(), get_playersnum(1), get_maxplayers(), mapname_striped, ident)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", query)
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", queryran, data, size)
	} else {
		set_task(15.0, "savenow")
	}
}