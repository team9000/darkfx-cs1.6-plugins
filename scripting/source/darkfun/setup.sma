#include <amxmodx>
#include <sub_stocks>
#include <sub_setup>
#include <sub_storage>
#include <dfx>
#include <sub_hud>

#define OPTIONS_PER_PAGE 7
new setup_page[33]
new setup_mode[33]
new changed

public plugin_init() {
	register_plugin("DFX-MOD - SETUP","MM","doubleM")

	changed = 0

	register_menucmd(register_menuid("Team9000 Setup - DFX-MOD"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("dfx-mod-setup")
}

public setup_register_fw() {
	setup_registeroption("DFX-MOD", 1)

	new key[32]
	for(new i = 0; i < dfx_get_numskills(); i++) {
		new skillshort[32]
		dfx_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_skill_%s", skillshort)
		setup_registerfield(key)
	}
	for(new i = 0; i < dfx_get_numskills2(); i++) {
		new skillshort[32]
		dfx_get_skillshort2(i, skillshort, 31)
		format(key, 31, "setup_skill2_%s", skillshort)
		setup_registerfield(key)
	}
}

public setup_loaded_fw(Handle:query) {
	new key[32], value[32]
	for(new i = 0; i < dfx_get_numskills(); i++) {
		new skillshort[32]
		dfx_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_skill_%s", skillshort)

		new colnum = SQL_FieldNameToNum(query, key)
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, value, 31)
			dfx_set_skillactive(i, str_to_num(value))
		}
	}
	for(new i = 0; i < dfx_get_numskills2(); i++) {
		new skillshort[32]
		dfx_get_skillshort2(i, skillshort, 31)
		format(key, 31, "setup_skill2_%s", skillshort)

		new colnum = SQL_FieldNameToNum(query, key)
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, value, 31)
			dfx_set_skillactive2(i, str_to_num(value))
		}
	}
}

public setup_menu_fw(id) {
	setup_page[id] = 1
	setup_mode[id] = 1
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
	for(new i = 0; i < dfx_get_numskills(); i++) {
		new skillshort[32]
		dfx_get_skillshort(i, skillshort, 31)
		format(query, 1023, "%ssetup_skill_%s='%d', ", query, skillshort, dfx_get_skillactive(i))
	}
	for(new i = 0; i < dfx_get_numskills2(); i++) {
		new skillshort[32]
		dfx_get_skillshort2(i, skillshort, 31)
		format(query, 1023, "%ssetup_skill2_%s='%d', ", query, skillshort, dfx_get_skillactive2(i))
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

public setup_menu(id, key) {
	set_menuopen(id, 0)

	if(setup_mode[id] == 1) {
		if(key == 0) {
			setup_page[id] = 1
			setup_mode[id] = 2
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 1) {
			setup_page[id] = 1
			setup_mode[id] = 3
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_save()
			setup_showmain(id)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DFX-MOD^n")

		new flags = 0

		format(menuBody,2047,"%s\w1. Skills^n", menuBody)
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Deluxe Skills^n", menuBody)
		flags |= (1<<1)

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		new max_page = floatround(float(dfx_get_numskills()) / OPTIONS_PER_PAGE, floatround_ceil)

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
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		if(item != -1 && item < dfx_get_numskills()) {
			dfx_set_skillactive(item, dfx_get_skillactive(item)+1)
			if(dfx_get_skillactive(item) > 1) {
				dfx_set_skillactive(item, -1)
			}
			changed = 1
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DFX-MOD^n")
		format(menuBody,2047,"%s\dSkills^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < dfx_get_numskills() && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			new skillname[32]
			dfx_get_skillname(i, skillname, 31)
			format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, skillname)
			if(dfx_get_skillactive(i) == -1) {
				format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
			} else if(dfx_get_skillactive(i) == 0) {
				format(menuBody,2047,"%s(\rDisabled\w)^n", menuBody)
			} else {
				format(menuBody,2047,"%s(\yEnabled\w)^n", menuBody)
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
	} else if(setup_mode[id] == 3) {
		new max_page = floatround(float(dfx_get_numskills2()) / OPTIONS_PER_PAGE, floatround_ceil)

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
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		if(item != -1 && item < dfx_get_numskills2()) {
			dfx_set_skillactive2(item, dfx_get_skillactive2(item)+1)
			if(dfx_get_skillactive2(item) > 1) {
				dfx_set_skillactive2(item, -1)
			}
			changed = 1
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DFX-MOD^n")
		format(menuBody,2047,"%s\dDeluxe Skills^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < dfx_get_numskills2() && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			new skillname[32]
			dfx_get_skillname2(i, skillname, 31)
			format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, skillname)
			if(dfx_get_skillactive2(i) == -1) {
				format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
			} else if(dfx_get_skillactive2(i) == 0) {
				format(menuBody,2047,"%s(\rDisabled\w)^n", menuBody)
			} else {
				format(menuBody,2047,"%s(\yEnabled\w)^n", menuBody)
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
	}

	return PLUGIN_HANDLED
}
