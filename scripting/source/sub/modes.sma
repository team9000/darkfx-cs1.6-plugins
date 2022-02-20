#include <amxmodx>
#include <sub_stocks>
#include <sub_modes>
#include <sub_votes>
#include <sub_roundtime>
#include <sub_setup>
#include <sub_storage>
#include <sub_hud>

#define OPTIONS_PER_PAGE 7
new setup_page[33]
new changed

#define MAX_MODES 5

new NUM_MODES = 0
new modeallowed[MAX_MODES]
new modechat[MAX_MODES][64]		// EX "grenade" for say vote_grenade
new modeadmincmd[MAX_MODES][64]	// EX "grenademode" for amx_grenademode
new modename[MAX_MODES][64]		// EX Grenade Mode
new modetype[MAX_MODES]		// 1 = ONE ROUND - ONE TIME
					// 2 = ONE ROUND - UNLIMITED TIMES
					// 3 = UNLIIMITED ON/OFF
new modeplugin[MAX_MODES]
new modeadminlvl[MAX_MODES]
new modeactive[MAX_MODES]	// 0 = OFF
				// 1 = ON NEXT ROUND
				// 2 = ON EARLY
				// 3 = ON
				// 4 = OFF NEXT ROUND
				// 5 = OFF EARLY
new modehistory[MAX_MODES]
new currentvote			// 0 = TO OFF
				// 1 = TO ON
new currentvotetype

public plugin_init() {
	register_plugin("Subsys - Modes","T9k","Team9000")

	NUM_MODES = 0

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("mode_init", i)) != -1) {
			callfunc_begin_i(funcid, i)
			callfunc_end()
		}
	}

	changed = 0

	register_menucmd(register_menuid("DarkMod Setup - Modes"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_modes")

	register_native("register_mode","register_mode_impl")
}

public register_mode_impl(id, numparams) {
	if(numparams != 5)
		return log_error(10, "Bad native parameters")

	if(NUM_MODES >= MAX_MODES) {
		log_message("Over max modes!")
		return 0
	}

	get_string(1, modechat[NUM_MODES], 63)
	get_string(2, modeadmincmd[NUM_MODES], 63)
	get_string(3, modename[NUM_MODES], 63)
	modetype[NUM_MODES] = get_param(4)
	modeadminlvl[NUM_MODES] = get_param(5)
	modeactive[NUM_MODES] = 0
	modehistory[NUM_MODES] = 0
	modeplugin[NUM_MODES] = id
	modeallowed[NUM_MODES] = -1

	new command[64]
	format(command, 63, "say vote_%s", modechat[NUM_MODES])
	register_concmd(command,"start_vote")
	format(command, 63, "say /vote_%s", modechat[NUM_MODES])
	register_concmd(command,"start_vote")
	format(command, 63, "vote_%s", modechat[NUM_MODES])
	register_concmd(command,"start_vote")
	format(command, 63, "/vote_%s", modechat[NUM_MODES])
	register_concmd(command,"start_vote")

	format(command, 63, "amx_%s", modeadmincmd[NUM_MODES])
	register_concmd(command,"admin_mode", modeadminlvl[NUM_MODES])

	NUM_MODES++

	return 1
}

public start_vote(id) {
	new arg[32]
	read_argv(1,arg,31)

	new voteid = -1
	for(new i = 0; i < NUM_MODES; i++) {
		if(containi(arg, modechat[i]) != -1) {
			voteid = i
			break
		}
	}
	if(voteid == -1) {
		return PLUGIN_CONTINUE
	}

	if(modeallowed[voteid] == 0) {
		alertmessage_v(id,3,"%s is restricted on this map", modename[voteid])
		return PLUGIN_HANDLED
	}
	if(modetype[voteid] == 1 && modehistory[voteid]) { 
		alertmessage_v(id,3,"%s has already been used this map!", modename[voteid])
		return PLUGIN_HANDLED
	}
	if(time_time() < get_cvar_num("amx_last_vote") + get_cvar_num("amx_vote_delay")){ 
		alertmessage_v(id,3,"You cant start a vote for another %d minutes!", floatround(float((get_cvar_num("amx_last_vote") + get_cvar_num("amx_vote_delay")) - time_time()) / 60.0, floatround_ceil))
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("amx_voting")) {
		alertmessage_v(id,3,"There is already a vote in progress")
		return PLUGIN_HANDLED
	}
	for(new i = 0; i < NUM_MODES; i++) {
		if((modetype[i] == 1 || modetype[i] == 2) && (modeactive[i] == 1 || modeactive[i] == 2)) {
			alertmessage_v(id,3,"%s is already going to be activated next round!", modename[i])
			return PLUGIN_HANDLED
		} else if(modetype[i] == 3 && (modeactive[i] == 1 || modeactive[i] == 2 || modeactive[i] == 3) && i != voteid) {
			alertmessage_v(id,3,"%s must be deactivated before you can start a different mode!", modename[i])
			return PLUGIN_HANDLED
		}
	}
	if(modetype[voteid] == 3 && (modeactive[voteid] == 1 || modeactive[voteid] == 2)) {
		alertmessage_v(id,3,"%s is already going to be activated next round!", modename[voteid])
		return PLUGIN_HANDLED
	}
	if(modetype[voteid] == 3 && (modeactive[voteid] == 4 || modeactive[voteid] == 5)) {
		alertmessage_v(id,3,"%s is already going to be deactivated next round!", modename[voteid])
		return PLUGIN_HANDLED
	}

	currentvotetype = voteid

	new question[128]
	if(modeactive[voteid] == 0) {
		format(question, 127, "Activate %s?", modename[voteid])
		currentvote = 1
	} else {
		format(question, 127, "Dectivate %s?", modename[voteid])
		currentvote = 0
	}
	vote_new("analyze_vote", 10, question, 2)
	vote_addoption("Yes")
	vote_addoption("No")

	set_cvar_num("amx_last_vote", time_time())
	set_cvar_num("amx_voting", 1)

	new name[32]
	get_user_name(id,name,31)
	alertmessage_v(0,3,"(%s) vote_%s", name, modechat[voteid]) 
	return PLUGIN_HANDLED
}

public analyze_vote(votes[], results[]) {
	if(modetype[currentvotetype] == 1) {
		if(results[0] == 0) {
			alertmessage_v(0,3,"%s will be activated for next round!", modename[currentvotetype])
			modehistory[currentvotetype] = 1
			modeactive[currentvotetype] = 1
		} else {
			alertmessage_v(0,3,"%s will remain deactivated!", modename[currentvotetype])
		}
	} else if(modetype[currentvotetype] == 2) {
		if(results[0] == 0) {
			alertmessage_v(0,3,"%s will be activated for next round!", modename[currentvotetype])
			modehistory[currentvotetype] = 1
			modeactive[currentvotetype] = 1
		} else {
			alertmessage_v(0,3,"%s will remain deactivated!", modename[currentvotetype])
		}
	} else {
		if(results[0] == 0) {
			if(currentvote == 0) {
				alertmessage_v(0,3,"%s will be deactivated next round!", modename[currentvotetype])
				modehistory[currentvotetype] = 1
				modeactive[currentvotetype] = 4
			} else {
				alertmessage_v(0,3,"%s will be activated next round!", modename[currentvotetype])
				modehistory[currentvotetype] = 1
				modeactive[currentvotetype] = 1
			}
		} else {
			if(currentvote == 0) {
				alertmessage_v(0,3,"%s will remain activated!", modename[currentvotetype])
			} else {
				alertmessage_v(0,3,"%s will remain deactivated!", modename[currentvotetype])
			}
		}
	}

	set_cvar_num("amx_voting", 0)
	return PLUGIN_HANDLED
}

public admin_mode(id,level,cid) {
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(0,arg,31)

	new voteid = -1
	for(new i = 0; i < NUM_MODES; i++) {
		if(containi(arg, modeadmincmd[i]) != -1) {
			voteid = i
			break
		}
	}
	if(voteid == -1) {
		return PLUGIN_CONTINUE
	}

	if(modeallowed[voteid] == 0) {
		client_print(id,print_console,"%s is restricted on this map", modename[voteid])
		return PLUGIN_HANDLED
	}
	for(new i = 0; i < NUM_MODES; i++) {
		if((modetype[i] == 1 || modetype[i] == 2) && (modeactive[i] == 1 || modeactive[i] == 2)) {
			client_print(id,print_console,"%s is already going to be activated next round!", modename[i])
			return PLUGIN_HANDLED
		} else if(modetype[i] == 3 && (modeactive[i] == 1 || modeactive[i] == 2 || modeactive[i] == 3) && i != voteid) {
			client_print(id,print_console,"%s must be deactivated before you can start a different mode!", modename[i])
			return PLUGIN_HANDLED
		}
	}
	if(modetype[voteid] == 3 && (modeactive[voteid] == 1 || modeactive[voteid] == 2)) {
		client_print(id,print_console,"%s is already going to be activated next round!", modename[voteid])
		return PLUGIN_HANDLED
	}
	if(modetype[voteid] == 3 && (modeactive[voteid] == 4 || modeactive[voteid] == 5)) {
		client_print(id,print_console,"%s is already going to be deactivated next round!", modename[voteid])
		return PLUGIN_HANDLED
	}

	if(modetype[voteid] == 1 || modetype[voteid] == 2) {
		adminalert_v(id, "", "activated %s for next round", modename[voteid])

		modehistory[voteid] = 1
		modeactive[voteid] = 1
	} else {
		if(modeactive[voteid] == 0) {
			adminalert_v(id, "", "activated %s starting next round", modename[voteid])

			modehistory[voteid] = 1
			modeactive[voteid] = 1
		} else {
			adminalert_v(id, "", "deactivated %s starting next round", modename[voteid])

			modehistory[voteid] = 3
			modeactive[voteid] = 1
		}
	}

	return PLUGIN_HANDLED
}

public activate(voteid) {
	new funcid
	if((funcid = get_func_id("mode_activate", modeplugin[voteid])) != -1) {
		callfunc_begin_i(funcid, modeplugin[voteid])
		callfunc_end()
	}
}

public activate_e(voteid) {
	new funcid
	if((funcid = get_func_id("mode_activate_e", modeplugin[voteid])) != -1) {
		callfunc_begin_i(funcid, modeplugin[voteid])
		callfunc_end()
	}
}

public deactivate(voteid) {
	new funcid
	if((funcid = get_func_id("mode_deactivate", modeplugin[voteid])) != -1) {
		callfunc_begin_i(funcid, modeplugin[voteid])
		callfunc_end()
	}
}

public deactivate_e(voteid) {
	new funcid
	if((funcid = get_func_id("mode_deactivate_e", modeplugin[voteid])) != -1) {
		callfunc_begin_i(funcid, modeplugin[voteid])
		callfunc_end()
	}
}

public round_freezestart_e() {
	for(new i = 0; i < NUM_MODES; i++) {
		if(modeactive[i] == 1) {
			activate_e(i)
			modeactive[i] = 2
		} else if(modeactive[i] == 4 || ((modetype[i] == 1 || modetype[i] == 2) && modeactive[i] == 3)) {
			deactivate_e(i)
			modeactive[i] = 5
		}
	}
}

public round_freezestart() {
	for(new i = 0; i < NUM_MODES; i++) {
		if(modeactive[i] == 2) {
			activate(i)
			modeactive[i] = 3
			alertmessage_v(0,3,"%s is now activated", modename[i])
		} else if(modeactive[i] == 5) {
			deactivate(i)
			modeactive[i] = 0
			alertmessage_v(0,3,"%s is now deactivated", modename[i])
		}
	}
}

public setup_register_fw() {
	setup_registeroption("Modes", 1)

	new key[32]
	for(new i = 0; i < NUM_MODES; i++) {
		format(key, 31, "setup_mode_%s", modechat[i])
		setup_registerfield(key)
	}
}

public setup_loaded_fw(Handle:query) {
	new key[32], value[32]
	for(new i = 0; i < NUM_MODES; i++) {
		format(key, 31, "setup_mode_%s", modechat[i])

		new colnum = SQL_FieldNameToNum(query, key)
		modeallowed[i] = 0
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, value, 31)
			modeallowed[i] = str_to_num(value)
		}
	}
}

public setup_menu_fw(id) {
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
	for(new i = 0; i < NUM_MODES; i++) {
		format(query, 1023, "%ssetup_mode_%s='%d', ", query, modechat[i], modeallowed[i])
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

	new max_page = floatround(float(NUM_MODES) / OPTIONS_PER_PAGE, floatround_ceil)

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

	if(item != -1 && item < NUM_MODES) {
		modeallowed[item] += 1
		if(modeallowed[item] > 1) {
			modeallowed[item] = -1
		}
		changed = 1
	}

	new menuBody[2048]
	format(menuBody,2047,"\yDarkMod Setup - Modes^n")

	new flags = 0

	for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < NUM_MODES && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
		format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, modename[i])
		if(modeallowed[i] == -1) {
			format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
		} else if(modeallowed[i] == 0) {
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

	return PLUGIN_HANDLED
}
