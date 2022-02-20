#include <amxmodx>
#include <sub_stocks>
#include <sub_setup>
#include <sub_storage>
#include <sub_hud>

#define NUM_CVARS 2
new cvarnames[NUM_CVARS][] = {
"Gravity",
"Air Accelerate"
}
new cvarvars[NUM_CVARS][] = {
"sv_gravity",
"sv_airaccelerate"
}

new cvarsettings[NUM_CVARS][128]

#define OPTIONS_PER_PAGE 7
new setup_page[33]
new setup_mode2[33]
new setup_waitingfor[33]
new changed

public plugin_init() {
	register_plugin("Subsys - Cvars","T9k","Team9000")

	for(new i = 0; i < NUM_CVARS; i++) {
		copy(cvarsettings[i], 127, "")
	}

	for(new i = 0; i < 33; i++) {
		setup_waitingfor[i] = 0
	}

	changed = 0

	register_clcmd("say","handle_say")
	register_menucmd(register_menuid("DarkMod Setup - CVARS"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	setup_waitingfor[id] = 0
}

public setup_register_fw() {
	setup_registeroption("Cvars", 1)

	for(new i = 0; i < NUM_CVARS; i++) {
		new key[64]
		format(key, 63, "setup_cvar_%s", cvarvars[i])
		setup_registerfield(key)
	}
}

public setup_loaded_fw(Handle:query) {
	new key[64]

	for(new i = 0; i < NUM_CVARS; i++) {
		format(key, 63, "setup_cvar_%s", cvarvars[i])

		new colnum = SQL_FieldNameToNum(query, key)
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, cvarsettings[i], 127)
		}
	}

	update_cvars()
}

public setup_menu_fw(id) {
	setup_waitingfor[id] = 0
	setup_page[id] = 1
	setup_menu(id, -1)
}

public setup_save() {
	if(!changed) {
		return
	}
	changed = 0

	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[1024]
	format(query, 1023, "UPDATE storage_maps SET ")
	for(new i = 0; i < NUM_CVARS; i++) {
		new striped[128]
		mysql_strip(cvarsettings[i], striped, 127)
		format(query, 1023, "%ssetup_cvar_%s='%s', ", query, cvarvars[i], striped)
	}
	query[strlen(query)-2] = 0 // remove last comma
	format(query, 4095, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public handle_say(id) {
	if(setup_waitingfor[id] == 1) {
		setup_menu(id, -1)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public setup_menu(id, key) {
	new max_page = floatround(float(NUM_CVARS) / OPTIONS_PER_PAGE, floatround_ceil)

	if(setup_waitingfor[id] == 0) {
		set_menuopen(id, 0)
	}

	if(setup_waitingfor[id] == 1) {
		new temp[128]
		read_args(temp, 127)
		remove_quotes(temp)
		copy(cvarsettings[setup_mode2[id]], 127, temp)

		changed = 1
		update_cvars()
		setup_waitingfor[id] = 0
	} else {
		new item=-1
		if(key >= 0 && key < OPTIONS_PER_PAGE) {
			item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
		}
		if(key == 7 && setup_page[id] > 1) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < max_page) {
			setup_page[id] += 1
		}
		if(key == 9) {
			setup_save()
			setup_showmain(id)
			return PLUGIN_HANDLED
		}

		if(item != -1 && item < NUM_CVARS) {
			setup_mode2[id] = item
			setup_waitingfor[id] = 1
			client_cmd(id, "messagemode")
			return PLUGIN_HANDLED
		}
	}

	new menuBody[2048]
	format(menuBody,2047,"\yDarkMod Setup - CVARS^n")

	new flags = 0

	for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < NUM_CVARS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
		format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, cvarnames[i])
		if(equal(cvarsettings[i], "")) {
			format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
		} else {
			format(menuBody,2047,"%s(\y%s\w)^n", menuBody, cvarsettings[i])
		}

		flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
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

public update_cvars() {
	for(new i = 0; i < NUM_CVARS; i++) {
		if(!equal(cvarsettings[i], "")) {
			set_cvar_string(cvarvars[i], cvarsettings[i])
		}
	}
}
