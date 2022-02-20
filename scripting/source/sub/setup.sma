#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_storage>
#include <sub_setup>
#include <sub_hud>

new loaded

new setup_page[33]
new issetup

#define OPTIONS_PER_PAGE 6

#define MAX_OPTIONS 30
new NUM_OPTIONS = 0
new options[MAX_OPTIONS][64]
new optionversion[MAX_OPTIONS]
new optionplugin[MAX_OPTIONS]

#define MAX_FIELDS 100
new NUM_FIELDS = 0
new fields[MAX_FIELDS][64]

public plugin_init() {
	register_plugin("Subsys - Setup","T9k","Team9000")

	register_clcmd("amx_setup","admin_setup",LVL_SETUP)
	register_menucmd(register_menuid("DarkMod Setup - Main"),1023,"setup_menu")

	set_task(0.5, "loaddata")

	loaded = 0
	issetup = 0
}

public plugin_natives() {
	register_library("sub_setup")

	register_native("setup_registeroption","setup_registeroption_impl")
	register_native("setup_registerfield","setup_registerfield_impl")
	register_native("setup_showmain","setup_showmain_impl")
}

public setup_registeroption_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(NUM_OPTIONS >= MAX_OPTIONS) {
		log_message("Over max setup options!")
		return 0
	}

	get_string(1, options[NUM_OPTIONS], 63)
	optionversion[NUM_OPTIONS] = get_param(2)
	optionplugin[NUM_OPTIONS] = id
	NUM_OPTIONS++

	return 1
}

public setup_registerfield_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(NUM_FIELDS >= MAX_FIELDS) {
		log_message("Over max setup fields!")
		return 0
	}

	get_string(1, fields[NUM_FIELDS], 63)
	NUM_FIELDS++

	return 1
}

public setup_showmain_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	setup_page[get_param(1)] = 1
	setup_menu(get_param(1), -1)

	return 1
}

public loaddata() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("setup_register_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}

	loaddataquery()
}

public loaddataquery() {
	new query[1024], current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)
	format(query, 1023, "SELECT ")
	for(new i = 0; i < NUM_FIELDS; i++) {
		format(query, 1023, "%s%s, ", query, fields[i])
	}
	format(query, 1023, "%ssetup_issetup FROM storage_maps WHERE name='%s'", query, current_map_striped)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", query)
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", queryran, data, size)
	} else {
		if(loaded) {
			return
		}
		if(SQL_NumResults(query) > 0) {
			loaded = 1

			new colnum = SQL_FieldNameToNum(query, "setup_issetup")
			issetup = 0
			if(colnum != -1) {
				new value[32]
				SQL_ReadResult(query, colnum, value, 31)
				issetup = str_to_num(value)
			}

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("setup_loaded_fw", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(_:query)
						callfunc_end()
					}
				}
			}
			return
		}

		set_task(2.0, "loaddataquery")
	}
}

public setup_save() {
	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[256]
	format(query, 255, "UPDATE storage_maps SET")
	format(query, 255, "%s %s='%d'", query, "setup_issetup", issetup)
	format(query, 255, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public admin_setup(id,level,cid) { 
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED
	if(!loaded) {
		alertmessage(id,3,"Map data is not yet loaded!")
		return PLUGIN_HANDLED
	}

	setup_page[id] = 1
	setup_menu(id, -1)

	return PLUGIN_HANDLED
}

public setup_menu(id, key) {
	set_menuopen(id, 0)

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("setup_clear_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}

	new currentversion = 0
	for(new i = 0; i < NUM_OPTIONS; i++) {
		if(optionversion[i] > currentversion) {
			currentversion = optionversion[i]
		}
	}

	new max_page = floatround(float(NUM_OPTIONS) / OPTIONS_PER_PAGE, floatround_ceil)

	new item=-1
	if(key >= 0 && key < OPTIONS_PER_PAGE) {
		item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
	}
	if(key == 6) {
		if(issetup != currentversion) {
			issetup = currentversion
			setup_save()
		}
	}
	if(key == 7 && setup_page[id] > 1) {
		setup_page[id] -= 1
	}
	if(key == 8 && setup_page[id] < max_page) {
		setup_page[id] += 1
	}
	if(key == 9) {
		return PLUGIN_HANDLED
	}

	if(item != -1 && item < NUM_OPTIONS) {
		new funcid = 0
		if((funcid = get_func_id("setup_menu_fw", optionplugin[item])) != -1) {
			if(callfunc_begin_i(funcid, optionplugin[item]) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
		return PLUGIN_HANDLED
	}

	new menuBody[512]
	format(menuBody,511,"\yDarkMod Setup - Main^n")

	new flags = 0

	for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < NUM_OPTIONS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
		format(menuBody,511,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, options[i])
		flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
	}

	format(menuBody,511,"%s^n", menuBody)

	if(issetup == currentversion) {
		format(menuBody,511,"%s\d7. Setup Version (%d)^n", menuBody, issetup)
	} else {
		format(menuBody,511,"%s\r7. Setup Version (%d)^n", menuBody, issetup)
		flags |= (1<<6)
	}

	format(menuBody,511,"%s^n", menuBody)

	if(setup_page[id] > 1) {
		format(menuBody,511,"%s\y8. Back^n", menuBody)
		flags |= (1<<7)
	} else {
		format(menuBody,511,"%s^n", menuBody)
	}

	if(setup_page[id] < max_page) {
		format(menuBody,511,"%s\y9. More^n", menuBody)
		flags |= (1<<8)
	} else {
		format(menuBody,511,"%s^n", menuBody)
	}

	format(menuBody,511,"%s^n", menuBody)

	format(menuBody,511,"%s\r0. Exit", menuBody)
	flags |= (1<<9)

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}
