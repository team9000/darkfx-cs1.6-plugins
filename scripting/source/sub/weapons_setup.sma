#include <amxmodx>
#include <sub_stocks>
#include <sub_setup>
#include <sub_storage>
#include <sub_weapons>
#include <sub_roundtime>
#include <sub_hud>

new DEF_RELOAD_T[32]
new DEF_RELOAD_DEF_T
new DEF_RELOAD_CT[32]
new DEF_RELOAD_DEF_CT
new DEF_FORCERULES[32]
new DEF_FORCERELOAD[32]
new DEF_FORCEDEFAULT
new DEF_ALLOWBUY
new DEF_ALLOWPICKUP_GROUND
new DEF_ALLOWPICKUP_DROP
new DEF_ALLOWDROP
new DEF_HIDEGROUND
new DEF_REMOVEDROP

#define NUM_WEAPONCATS 7
new weaponcats[NUM_WEAPONCATS][] = {
"Primary - Assault Rifles",
"Primary - Sniper Rifles",
"Primary - SMGs",
"Primary - Shotguns",
"Primary - Machine Gun",
"Secondary - Pistols",
"Other"
}
new weaponcatspots[NUM_WEAPONCATS][6] = {
{CSW_FAMAS, CSW_GALIL, CSW_AK47, CSW_M4A1, 0, 0},
{CSW_AUG, CSW_SG552, CSW_SCOUT, CSW_AWP, CSW_SG550, CSW_G3SG1},
{CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_MAC10, CSW_UMP45, 0},
{CSW_M3, CSW_XM1014, 0, 0, 0, 0},
{CSW_M249, 0, 0, 0, 0, 0},
{CSW_USP, CSW_GLOCK18, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FIVESEVEN},
{CSW_KNIFE, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_FLASHBANG, CSW_C4, 0}
}
new weaponnames[32][] = {
"",
"228 Compact",
"",
"Scout",
"HE Grenade",
"Auto Shotgun",
"C4",
"MAC-10",
"AUG (CT Semi-Sniper)",
"Smoke Grenade",
"Dual Elites",
"Five-Seven",
"UMP45",
"SG550 (CT Auto-Sniper)",
"Defender",
"Clarion",
"USP",
"Glock",
"AWP",
"MP5 Navy",
"M249",
"12 Gauge",
"M4",
"TMP",
"G3SG1 (T Auto-Sniper)",
"Flashbang",
"Deagle",
"SG552 (T Semi-Sniper)",
"AK47",
"Knife",
"P90",
""
}

new reload[32]
new defaultweap
new forcerules[32]
new forcereload[32]
new forcedefaultweap
new allowbuy
new allowpickup_ground
new allowpickup_drop
new allowdrop
new hideground
new removedrop
new roundreload

#define OPTIONS_PER_PAGE 7
new setup_waitingfor[33]
new setup_page[33]
new setup_mode[33]
new setup_mode2[33]
new changed

public plugin_init() {
	register_plugin("Subsys - Weapons-Setup","T9k","Team9000")

	arrayset(DEF_RELOAD_T,0,32)
	DEF_RELOAD_T[CSW_KNIFE] = 1
	DEF_RELOAD_T[CSW_GLOCK18] = 3
	DEF_RELOAD_DEF_T = CSW_GLOCK18
	arrayset(DEF_RELOAD_CT,0,32)
	DEF_RELOAD_CT[CSW_KNIFE] = 1
	DEF_RELOAD_CT[CSW_USP] = 3
	DEF_RELOAD_DEF_CT = CSW_USP
	arrayset(DEF_FORCERULES,1,32)
	arrayset(DEF_FORCERELOAD,0,32)
	DEF_FORCEDEFAULT = 0
	DEF_ALLOWBUY = 1
	DEF_ALLOWPICKUP_GROUND = 1
	DEF_ALLOWPICKUP_DROP = 1
	DEF_ALLOWDROP = 1
	DEF_HIDEGROUND = 0
	DEF_REMOVEDROP = 0

	for(new i = 0; i < 32; i++) {
		reload[i] = -1
		forcerules[i] = -1
		forcereload[i] = -1
	}
	defaultweap = -1
	forcedefaultweap = -1
	allowbuy = -1
	allowpickup_ground = -1
	allowpickup_drop = -1
	allowdrop = -1
	hideground = -1
	removedrop = -1
	roundreload = -1

	changed = 0

	for(new i = 0; i < 33; i++) {
		setup_waitingfor[i] = 0
	}

	register_clcmd("say","handle_say")
	register_menucmd(register_menuid("DarkMod Setup - Weapons"),1023,"setup_menu")

	set_task(0.2, "do_defaults")

	return PLUGIN_CONTINUE
}

public do_defaults() {
	weap_reload(3, -1, DEF_RELOAD_T, DEF_RELOAD_DEF_T)
	weap_reload(3, -2, DEF_RELOAD_CT, DEF_RELOAD_DEF_CT)
	weap_force(3, 0, DEF_FORCERULES, DEF_FORCERELOAD, DEF_FORCEDEFAULT)
	weap_allowbuy(3, 0, DEF_ALLOWBUY)
	weap_allowpickup_ground(3, 0, DEF_ALLOWPICKUP_GROUND)
	weap_allowpickup_drop(3, 0, DEF_ALLOWPICKUP_DROP)
	weap_allowdrop(3, 0, DEF_ALLOWDROP)
	weap_hideground(3, DEF_HIDEGROUND)
	weap_removedrop(3, DEF_REMOVEDROP)
}

public client_connect(id) {
	setup_waitingfor[id] = 0
}

public setup_register_fw() {
	setup_registeroption("Weapons", 1)

	setup_registerfield("setup_weapons_reload")
	setup_registerfield("setup_weapons_defaultweap")
	setup_registerfield("setup_weapons_forcerules")
	setup_registerfield("setup_weapons_forcereload")
	setup_registerfield("setup_weapons_forcedefaultweap")
	setup_registerfield("setup_weapons_allowbuy")
	setup_registerfield("setup_weapons_allowpickup_ground")
	setup_registerfield("setup_weapons_allowpickup_drop")
	setup_registerfield("setup_weapons_allowdrop")
	setup_registerfield("setup_weapons_hideground")
	setup_registerfield("setup_weapons_removedrop")
	setup_registerfield("setup_weapons_roundreload")
}

public setup_loaded_fw(Handle:query) {
	new value[256], left[32], right[256]

	new colnum = SQL_FieldNameToNum(query, "setup_weapons_reload")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)

		for(new i = 0; i < 32; i++) {
			strtok(value, left, 31, right, 255, ' ')
			reload[i] = str_to_num(left)
			copy(value, 255, right)
		}
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_defaultweap")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		defaultweap = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_forcerules")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)

		for(new i = 0; i < 32; i++) {
			strtok(value, left, 31, right, 255, ' ')
			forcerules[i] = str_to_num(left)
			copy(value, 255, right)
		}
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_forcereload")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)

		for(new i = 0; i < 32; i++) {
			strtok(value, left, 31, right, 255, ' ')
			forcereload[i] = str_to_num(left)
			copy(value, 255, right)
		}
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_forcedefaultweap")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		forcedefaultweap = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_allowbuy")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		allowbuy = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_allowpickup_ground")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		allowpickup_ground = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_allowpickup_drop")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		allowpickup_drop = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_allowdrop")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		allowdrop = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_hideground")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		hideground = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_removedrop")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		removedrop = str_to_num(value)
	}

	colnum = SQL_FieldNameToNum(query, "setup_weapons_roundreload")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 255)
		roundreload = str_to_num(value)
	}

	update_weaps()
}

public setup_menu_fw(id) {
	setup_waitingfor[id] = 0
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

	new reloadstr[256] = ""
	for(new i = 0; i < 32; i++) {
		if(i != 0) {
			format(reloadstr, 255, "%s ", reloadstr)
		}
		format(reloadstr, 255, "%s%d", reloadstr, reload[i])
	}
	new forcerulesstr[256] = ""
	for(new i = 0; i < 32; i++) {
		if(i != 0) {
			format(forcerulesstr, 255, "%s ", forcerulesstr)
		}
		format(forcerulesstr, 255, "%s%d", forcerulesstr, forcerules[i])
	}
	new forcereloadstr[256] = ""
	for(new i = 0; i < 32; i++) {
		if(i != 0) {
			format(forcereloadstr, 255, "%s ", forcereloadstr)
		}
		format(forcereloadstr, 255, "%s%d", forcereloadstr, forcereload[i])
	}

	new query[1024]
	format(query, 1023, "UPDATE storage_maps SET ")
	format(query, 1023, "%s%s='%s', ", query, "setup_weapons_reload", reloadstr)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_defaultweap", defaultweap)
	format(query, 1023, "%s%s='%s', ", query, "setup_weapons_forcerules", forcerulesstr)
	format(query, 1023, "%s%s='%s', ", query, "setup_weapons_forcereload", forcereloadstr)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_forcedefaultweap", forcedefaultweap)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_allowbuy", allowbuy)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_allowpickup_ground", allowpickup_ground)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_allowpickup_drop", allowpickup_drop)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_allowdrop", allowdrop)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_hideground", hideground)
	format(query, 1023, "%s%s='%d', ", query, "setup_weapons_removedrop", removedrop)
	format(query, 1023, "%s%s='%d' ", query, "setup_weapons_roundreload", roundreload)

	format(query, 4095, "%sWHERE name='%s'", query, current_map_striped)

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
			setup_page[id] = 0
			setup_mode[id] = 2
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 1) {
			setup_page[id] = 0
			setup_mode[id] = 3
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 2) {
			setup_page[id] = 0
			setup_mode[id] = 4
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 3) {
			setup_page[id] = 0
			setup_mode[id] = 5
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 4) {
			setup_page[id] = 0
			setup_mode[id] = 6
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 5) {
			setup_mode[id] = 7
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_save()
			setup_showmain(id)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")

		new flags = 0

		format(menuBody,2047,"%s\w1. Spawn Weapons^n", menuBody)
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Default Spawn Weapon^n^n", menuBody)
		flags |= (1<<1)

		format(menuBody,2047,"%s\w3. Force Rules^n", menuBody)
		flags |= (1<<2)
		format(menuBody,2047,"%s\w4. Force Reload^n", menuBody)
		flags |= (1<<3)
		format(menuBody,2047,"%s\w5. Force Default^n^n", menuBody)
		flags |= (1<<4)

		format(menuBody,2047,"%s\w6. Weapon Handling^n^n", menuBody)
		flags |= (1<<5)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		if(setup_waitingfor[id] == 1) {
			new temp[32]
			read_args(temp, 31)
			remove_quotes(temp)
			reload[weaponcatspots[setup_page[id]][setup_mode2[id]]] = str_to_num(temp)

			for(new i = 0; i < 32; i++) {
				if(reload[i] == -1) {
					reload[i] = 0
				}
			}

			changed = 1
			update_weaps()
			setup_waitingfor[id] = 0
		} else {
			if(key >= 0 && key <= 5) {
				setup_mode2[id] = key
				setup_waitingfor[id] = 1
				client_cmd(id, "messagemode")
				return PLUGIN_HANDLED
			}
			if(key == 6) {
				for(new i = 0; i < 32; i++) {
					reload[i] = -1
				}
				changed = 1
				update_weaps()
			}
			if(key == 7 && setup_page[id] > 0) {
				setup_page[id] -= 1
			}
			if(key == 8 && setup_page[id] < NUM_WEAPONCATS-1) {
				setup_page[id] += 1
			}
			if(key == 9) {
				setup_mode[id] = 1
				setup_menu(id, -1)
				return PLUGIN_HANDLED
			}
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dSpawn Reload^n", menuBody)
		format(menuBody,2047,"%s\d%s^n^n", menuBody, weaponcats[setup_page[id]])

		new flags = 0

		for(new i = 0; i < 6; i++) {
			if(weaponcatspots[setup_page[id]][i] != 0) {
				format(menuBody,2047,"%s\w%d. %s ", menuBody, i+1, weaponnames[weaponcatspots[setup_page[id]][i]])
				if(reload[weaponcatspots[setup_page[id]][i]] == -1) {
					format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
				} else if(reload[weaponcatspots[setup_page[id]][i]] == 0) {
					format(menuBody,2047,"%s(\rNone\w)^n", menuBody)
				} else {
					format(menuBody,2047,"%s(\y%d\w)^n", menuBody, reload[weaponcatspots[setup_page[id]][i]])
				}
				flags |= (1<<i)
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,2047,"%s\y7. Default^n\w", menuBody)
		flags |= (1<<6)

		if(setup_page[id] > 0) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < NUM_WEAPONCATS-1) {
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
		if(key >= 0 && key <= 5) {
			if(defaultweap == weaponcatspots[setup_page[id]][key]) {
				defaultweap = -1
			} else {
				defaultweap = weaponcatspots[setup_page[id]][key]
			}
			changed = 1
			update_weaps()
		}
		if(key == 6) {
			defaultweap = -1
			changed = 1
			update_weaps()
		}
		if(key == 7 && setup_page[id] > 0) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < NUM_WEAPONCATS-1) {
			setup_page[id] += 1
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dSpawn Default^n", menuBody)
		format(menuBody,2047,"%s\d%s^n^n", menuBody, weaponcats[setup_page[id]])

		new flags = 0

		for(new i = 0; i < 6; i++) {
			if(weaponcatspots[setup_page[id]][i] != 0) {
				format(menuBody,2047,"%s\w%d. %s ", menuBody, i+1, weaponnames[weaponcatspots[setup_page[id]][i]])
				if(defaultweap == -1) {
					format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
				} else if(defaultweap != weaponcatspots[setup_page[id]][i]) {
					format(menuBody,2047,"%s(\rNot Selected\w)^n", menuBody)
				} else {
					format(menuBody,2047,"%s(\ySelected\w)^n", menuBody)
				}
				flags |= (1<<i)
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,2047,"%s\y7. Default^n\w", menuBody)
		flags |= (1<<6)

		if(setup_page[id] > 0) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < NUM_WEAPONCATS-1) {
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
	} else if(setup_mode[id] == 4) {
		if(key >= 0 && key <= 5) {
			if(forcerules[weaponcatspots[setup_page[id]][key]] == -1) {
				for(new i = 0; i < 32; i++) {
					forcerules[i] = 0
				}
				forcerules[weaponcatspots[setup_page[id]][key]] = 1
			} else if(forcerules[weaponcatspots[setup_page[id]][key]] == 0) {
				forcerules[weaponcatspots[setup_page[id]][key]] = 1
			} else {
				forcerules[weaponcatspots[setup_page[id]][key]] = 0
			}
			changed = 1
			update_weaps()
		}
		if(key == 6) {
			for(new i = 0; i < 32; i++) {
				forcerules[i] = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 7 && setup_page[id] > 0) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < NUM_WEAPONCATS-1) {
			setup_page[id] += 1
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dForce Rules^n", menuBody)
		format(menuBody,2047,"%s\d%s^n^n", menuBody, weaponcats[setup_page[id]])

		new flags = 0

		for(new i = 0; i < 6; i++) {
			if(weaponcatspots[setup_page[id]][i] != 0) {
				format(menuBody,2047,"%s\w%d. %s ", menuBody, i+1, weaponnames[weaponcatspots[setup_page[id]][i]])
				if(forcerules[weaponcatspots[setup_page[id]][i]] == -1) {
					format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
				} else if(forcerules[weaponcatspots[setup_page[id]][i]] == 0) {
					format(menuBody,2047,"%s(\rNot Allowed\w)^n", menuBody)
				} else {
					format(menuBody,2047,"%s(\yAllowed\w)^n", menuBody)
				}
				flags |= (1<<i)
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,2047,"%s\y7. Default^n\w", menuBody)
		flags |= (1<<6)

		if(setup_page[id] > 0) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < NUM_WEAPONCATS-1) {
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
	} else if(setup_mode[id] == 5) {
		if(setup_waitingfor[id] == 1) {
			new temp[32]
			read_args(temp, 31)
			remove_quotes(temp)
			forcereload[weaponcatspots[setup_page[id]][setup_mode2[id]]] = str_to_num(temp)

			for(new i = 0; i < 32; i++) {
				if(forcereload[i] == -1) {
					forcereload[i] = 0
				}
			}

			changed = 1
			update_weaps()
			setup_waitingfor[id] = 0
		} else {
			if(key >= 0 && key <= 5) {
				setup_mode2[id] = key
				setup_waitingfor[id] = 1
				client_cmd(id, "messagemode")
				return PLUGIN_HANDLED
			}
			if(key == 6) {
				for(new i = 0; i < 32; i++) {
					forcereload[i] = -1
				}
				changed = 1
				update_weaps()
			}
			if(key == 7 && setup_page[id] > 0) {
				setup_page[id] -= 1
			}
			if(key == 8 && setup_page[id] < NUM_WEAPONCATS-1) {
				setup_page[id] += 1
			}
			if(key == 9) {
				setup_mode[id] = 1
				setup_menu(id, -1)
				return PLUGIN_HANDLED
			}
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dForce Reload^n", menuBody)
		format(menuBody,2047,"%s\d%s^n^n", menuBody, weaponcats[setup_page[id]])

		new flags = 0

		for(new i = 0; i < 6; i++) {
			if(weaponcatspots[setup_page[id]][i] != 0) {
				format(menuBody,2047,"%s\w%d. %s ", menuBody, i+1, weaponnames[weaponcatspots[setup_page[id]][i]])
				if(forcereload[weaponcatspots[setup_page[id]][i]] == -1) {
					format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
				} else if(forcereload[weaponcatspots[setup_page[id]][i]] == 0) {
					format(menuBody,2047,"%s(\rNone\w)^n", menuBody)
				} else {
					format(menuBody,2047,"%s(\y%d\w)^n", menuBody, forcereload[weaponcatspots[setup_page[id]][i]])
				}
				flags |= (1<<i)
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,2047,"%s\y7. Default^n\w", menuBody)
		flags |= (1<<6)

		if(setup_page[id] > 0) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < NUM_WEAPONCATS-1) {
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
	} else if(setup_mode[id] == 6) {
		if(key >= 0 && key <= 5) {
			if(forcedefaultweap == weaponcatspots[setup_page[id]][key]) {
				forcedefaultweap = -1
			} else {
				forcedefaultweap = weaponcatspots[setup_page[id]][key]
			}
			changed = 1
			update_weaps()
		}
		if(key == 6) {
			forcedefaultweap = -1
			changed = 1
			update_weaps()
		}
		if(key == 7 && setup_page[id] > 0) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < NUM_WEAPONCATS-1) {
			setup_page[id] += 1
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dForce Default^n", menuBody)
		format(menuBody,2047,"%s\d%s^n^n", menuBody, weaponcats[setup_page[id]])

		new flags = 0

		for(new i = 0; i < 6; i++) {
			if(weaponcatspots[setup_page[id]][i] != 0) {
				format(menuBody,2047,"%s\w%d. %s ", menuBody, i+1, weaponnames[weaponcatspots[setup_page[id]][i]])
				if(forcedefaultweap == -1) {
					format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
				} else if(forcedefaultweap != weaponcatspots[setup_page[id]][i]) {
					format(menuBody,2047,"%s(\rNot Selected\w)^n", menuBody)
				} else {
					format(menuBody,2047,"%s(\ySelected\w)^n", menuBody)
				}
				flags |= (1<<i)
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,2047,"%s\y7. Default^n\w", menuBody)
		flags |= (1<<6)

		if(setup_page[id] > 0) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < NUM_WEAPONCATS-1) {
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
	} else if(setup_mode[id] == 7) {
		if(key == 0) {
			allowbuy += 1
			if(allowbuy > 1) {
				allowbuy = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 1) {
			allowpickup_ground += 1
			if(allowpickup_ground > 1) {
				allowpickup_ground = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 2) {
			allowpickup_drop += 1
			if(allowpickup_drop > 1) {
				allowpickup_drop = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 3) {
			allowdrop += 1
			if(allowdrop > 1) {
				allowdrop = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 4) {
			hideground += 1
			if(hideground > 1) {
				hideground = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 5) {
			removedrop += 1
			if(removedrop > 1) {
				removedrop = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 6) {
			roundreload += 1
			if(roundreload > 1) {
				roundreload = -1
			}
			changed = 1
			update_weaps()
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Weapons^n")
		format(menuBody,2047,"%s\dWeapon Handling^n^n", menuBody)

		new flags = 0

		format(menuBody,2047,"%s\w1. Allow Buy (%s)^n", menuBody, allowbuy == -1 ? "\dDefault\w" : (allowbuy == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Allow Pickup - Ground (%s)^n", menuBody, allowpickup_ground == -1 ? "\dDefault\w" : (allowpickup_ground == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<1)
		format(menuBody,2047,"%s\w3. Allow Pickup - Drop (%s)^n", menuBody, allowpickup_drop == -1 ? "\dDefault\w" : (allowpickup_drop == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<2)
		format(menuBody,2047,"%s\w4. Allow Drop (%s)^n", menuBody, allowdrop == -1 ? "\dDefault\w" : (allowdrop == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<3)
		format(menuBody,2047,"%s\w5. Hide Ground Weapons (%s)^n", menuBody, hideground == -1 ? "\dDefault\w" : (hideground == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<4)
		format(menuBody,2047,"%s\w6. Remove Dropped Weapons (%s)^n", menuBody, removedrop == -1 ? "\dDefault\w" : (removedrop == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<5)
		format(menuBody,2047,"%s\w7. Reload Every Round (%s)^n^n", menuBody, roundreload == -1 ? "\dDefault\w" : (roundreload == 0 ? "\rNo\w" : "\yYes\w"))
		flags |= (1<<6)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}

	return PLUGIN_HANDLED
}

public update_weaps() {
	if(reload[0] != -1 && defaultweap != -1) {
		weap_reload(0, 0, reload, defaultweap)
	} else {
		weap_reload_off(0, 0)
	}

	if(forcerules[0] != -1 && forcereload[0] != -1 && forcedefaultweap != -1) {
		weap_force(0, 0, forcerules, forcereload, forcedefaultweap)
	} else {
		weap_force_off(0, 0)
	}

	if(allowbuy != -1) {
		weap_allowbuy(0, 0, allowbuy)
	} else {
		weap_allowbuy(0, 0, -1)
	}

	if(allowpickup_ground != -1) {
		weap_allowpickup_ground(0, 0, allowpickup_ground)
	} else {
		weap_allowpickup_ground(0, 0, -1)
	}

	if(allowpickup_drop != -1) {
		weap_allowpickup_drop(0, 0, allowpickup_drop)
	} else {
		weap_allowpickup_drop(0, 0, -1)
	}

	if(allowdrop != -1) {
		weap_allowdrop(0, 0, allowdrop)
	} else {
		weap_allowdrop(0, 0, -1)
	}

	if(hideground != -1) {
		weap_hideground(0, hideground)
	} else {
		weap_hideground(0, -1)
	}

	if(removedrop != -1) {
		weap_removedrop(0, removedrop)
	} else {
		weap_removedrop(0, -1)
	}
}

public round_freezestart() {
	if(roundreload == 1) {
		weap_forcedefault(0)
	}
}
