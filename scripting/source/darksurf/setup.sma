#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_setup>
#include <sub_storage>
#include <darksurf.inc>
#include <sub_hud>

#define OPTIONS_PER_PAGE 7
new setup_page[33]
new setup_mode[33]
new setup_waitingfor[33]
new changed

public plugin_init() {
	register_plugin("DARKSURF - SETUP","T9k","Team9000")

	changed = 0

	for(new i = 0; i < 33; i++) {
		setup_waitingfor[i] = 0
	}

	register_clcmd("say","handle_say")
	register_menucmd(register_menuid("DarkMod Setup - DARKSURF"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	setup_waitingfor[id] = 0
}

public plugin_natives() {
	register_library("darksurf_setup")
}

public setup_register_fw() {
	setup_registeroption("DARKSURF", 1)

	new key[32]
	for(new i = 0; i < surf_get_numskills(); i++) {
		new skillshort[32]
		surf_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_surf_skill_%s", skillshort)
		setup_registerfield(key)
	}

	setup_registerfield("setup_surf_finish")
}

public setup_loaded_fw(Handle:query) {
	new key[32], value[128]
	for(new i = 0; i < surf_get_numskills(); i++) {
		new skillshort[32]
		surf_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_surf_skill_%s", skillshort)

		new colnum = SQL_FieldNameToNum(query, key)
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, value, 63)
			surf_set_skillactive(i, str_to_num(value))
		}
	}

	new colnum = SQL_FieldNameToNum(query, "setup_surf_finish")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 127)

		new Float:pos[3]

		new left[32], right[127]
		strtok(value, left, 31, right, 127, ' ')
		pos[0] = str_to_float(left)
		copy(value, 127, right)

		strtok(value, left, 31, right, 127, ' ')
		pos[1] = str_to_float(left)
		copy(value, 127, right)

		strtok(value, left, 31, right, 127, ' ')
		pos[2] = str_to_float(left)
		copy(value, 127, right)

		surf_set_finish(pos)
	}
}

public setup_menu_fw(id) {
	setup_page[id] = 1
	setup_mode[id] = 1
	setup_waitingfor[id] = 0
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
	for(new i = 0; i < surf_get_numskills(); i++) {
		new skillshort[32]
		surf_get_skillshort(i, skillshort, 31)
		format(query, 1023, "%ssetup_surf_skill_%s='%d', ", query, skillshort, surf_get_skillactive(i))
	}

	new Float:pos[3]
	surf_get_finish(pos)
	format(query, 1023, "%ssetup_surf_finish='%f %f %f'", query, pos[0], pos[1], pos[2])

	format(query, 1023, "%s WHERE name='%s'", query, current_map_striped)

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
	if(setup_waitingfor[id] == 0) {
		set_menuopen(id, 0)
	}

	if(setup_mode[id] == 1) {
		if(key == 0) {
			setup_page[id] = 1
			setup_mode[id] = 2
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 1) {
			new Float:pos[3]
			entity_get_vector(id, EV_VEC_origin, pos)
			surf_set_finish(pos)
			changed = 1
		}
		if(key == 2) {
			new Float:pos[3] = {0.0,0.0,0.0}
			surf_set_finish(pos)
			changed = 1
		}
		if(key == 3) {
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
		format(menuBody,2047,"\yDarkMod Setup - DARKSURF^n")

		new flags = 0

		format(menuBody,2047,"%s\w1. Skills^n^n", menuBody)
		flags |= (1<<0)

		format(menuBody,2047,"%s\w2. Set Finish Point^n", menuBody)
		flags |= (1<<1)

		new Float:pos[3]
		surf_get_finish(pos)
		if(pos[0] != 0.0 || pos[1] != 0.0 || pos[2] != 0.0) {
			format(menuBody,2047,"%s\w3. Remove Finish Point^n", menuBody)
			flags |= (1<<2)
		} else {
			format(menuBody,2047,"%s\d3. Remove Finish Point^n", menuBody)
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		new max_page = floatround(float(surf_get_numskills()) / OPTIONS_PER_PAGE, floatround_ceil)

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

		if(item != -1 && item < surf_get_numskills()) {
			surf_set_skillactive(item, surf_get_skillactive(item)+1)
			if(surf_get_skillactive(item) > 1) {
				surf_set_skillactive(item, -1)
			}
			changed = 1
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - DARKSURF^n")
		format(menuBody,2047,"%s\dSkills^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < surf_get_numskills() && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			new skillname[32]
			surf_get_skillname(i, skillname, 31)
			format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, skillname)
			if(surf_get_skillactive(i) == -1) {
				format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
			} else if(surf_get_skillactive(i) == 0) {
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
