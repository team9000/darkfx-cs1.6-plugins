#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fun>
#include <sub_weapons>
#include <sub_roundtime>

/*
PLUGIN LIST
0 = MAP SETUP
1 = MODES
2 = SURF
3 = DEFAULTS
*/
#define NUM_PLUGINS 4
new plugin_order[NUM_PLUGINS] = {
1, 0, 2, 3
}

new bool:reloadon[NUM_PLUGINS][36]
new reload[NUM_PLUGINS][36][32]
new reloaddefault[NUM_PLUGINS][36]
new bool:forceon[NUM_PLUGINS][36]
new bool:forcerules[NUM_PLUGINS][36][32]
new forcereload[NUM_PLUGINS][36][32]
new forcereloaddefault[NUM_PLUGINS][36]
new allowbuy[NUM_PLUGINS][36]
new allowpickup_ground[NUM_PLUGINS][36]
new allowpickup_drop[NUM_PLUGINS][36]
new allowdrop[NUM_PLUGINS][36]

new hideground[NUM_PLUGINS]
new removedrop[NUM_PLUGINS]
new blockfirein[NUM_PLUGINS]

new laststrip[33]

public plugin_init() {
	register_plugin("Subsys - Weapons","T9k","Team9000")
	set_task(1.0, "remove_ents")

	register_clcmd("buy", "buy")
	register_clcmd("buyequip", "buy")
	register_clcmd("buyammo1", "buy")
	register_clcmd("buyammo2", "buy")
	register_clcmd("drop", "drop")

	for(new i = 0; i < NUM_PLUGINS; i++) {
		for(new j = 0; j < 36; j++) {
			reloadon[i][j] = false
			forceon[i][j] = false
			allowbuy[i][j] = -1
			allowpickup_ground[i][j] = -1
			allowpickup_drop[i][j] = -1
			allowdrop[i][j] = -1
		}
		hideground[i] = -1
		removedrop[i] = -1
		blockfirein[i] = -1
	}

	for(new i = 0; i < 33; i++) {
		laststrip[i] = 0
	}

	set_task(0.3, "check_weapons", 9999, "", 0, "b")

	register_message(get_user_msgid("SendAudio"), "message_SendAudio")
	register_event("TextMsg", "message_TextMsg", "b", "2&#Game_radio", "4&#Fire_in_the_hole")

	return PLUGIN_CONTINUE
}

public round_freezestart_e() {
	for(new i = 0; i < 33; i++) {
		laststrip[i] = time_time()
	}
}

public client_connect(id) {
	laststrip[id] = 0

	for(new i = 0; i < NUM_PLUGINS; i++) {
		reloadon[i][id] = false
		forceon[i][id] = false
		allowbuy[i][id] = -1
		allowpickup_ground[i][id] = -1
		allowpickup_drop[i][id] = -1
		allowdrop[i][id] = -1
	}
}

public plugin_natives() {
	register_library("sub_weapons")

	register_native("weap_reload","weap_reload_impl")
	register_native("weap_reload_off","weap_reload_off_impl")
	register_native("weap_force","weap_force_impl")
	register_native("weap_force_off","weap_force_off_impl")
	register_native("weap_allowbuy","weap_allowbuy_impl")
	register_native("weap_allowpickup_ground","weap_allowpickup_ground_impl")
	register_native("weap_allowpickup_drop","weap_allowpickup_drop_impl")
	register_native("weap_allowdrop","weap_allowdrop_impl")
	register_native("weap_hideground","weap_hideground_impl")
	register_native("weap_removedrop","weap_removedrop_impl")
	register_native("weap_blockfirein","weap_blockfirein_impl")
	register_native("weap_forcedefault","weap_forcedefault_impl")
}

public remove_ents() {
	remove_ent("player_weaponstrip")
	remove_ent("game_player_equip")
}

public remove_ent(classname[]) {
	new ent = find_ent_by_class(-1, classname)
	new temp

	while(ent) {
		temp = find_ent_by_class(ent, classname)
		remove_entity(ent)
		ent = temp
	}
}

public weap_reload_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)

	if(target == -1) {
		reloadon[plugin][33] = true
		get_array(3,reload[plugin][33],32)
		reloaddefault[plugin][33] = get_param(4)
	} else if(target == -2) {
		reloadon[plugin][34] = true
		get_array(3,reload[plugin][34],32)
		reloaddefault[plugin][34] = get_param(4)
	} else if(target == 0) {
		reloadon[plugin][35] = true
		get_array(3,reload[plugin][35],32)
		reloaddefault[plugin][35] = get_param(4)
	} else {
		reloadon[plugin][target] = true
		get_array(3,reload[plugin][target],32)
		reloaddefault[plugin][target] = get_param(4)
	}

	return 1
}

public weap_reload_off_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)

	if(target == -1) {
		reloadon[plugin][33] = false
	} else if(target == -2) {
		reloadon[plugin][34] = false
	} else if(target == 0) {
		reloadon[plugin][35] = false
	} else {
		reloadon[plugin][target] = false
	}

	return 1
}

public weap_force_impl(id, numparams) {
	if(numparams != 5)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)

	if(target == -1) {
		forceon[plugin][33] = true
		get_array(3,forcerules[plugin][33],32)
		get_array(4,forcereload[plugin][33],32)
		forcereloaddefault[plugin][33] = get_param(5)
	} else if(target == -2) {
		forceon[plugin][34] = true
		get_array(3,forcerules[plugin][34],32)
		get_array(4,forcereload[plugin][34],32)
		forcereloaddefault[plugin][34] = get_param(5)
	} else if(target == 0) {
		forceon[plugin][35] = true
		get_array(3,forcerules[plugin][35],32)
		get_array(4,forcereload[plugin][35],32)
		forcereloaddefault[plugin][35] = get_param(5)
	} else {
		forceon[plugin][target] = true
		get_array(3,forcerules[plugin][target],32)
		get_array(4,forcereload[plugin][target],32)
		forcereloaddefault[plugin][target] = get_param(5)
	}

	return 1
}

public weap_force_off_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)

	if(target == -1) {
		forceon[plugin][33] = false
	} else if(target == -2) {
		forceon[plugin][34] = false
	} else if(target == 0) {
		forceon[plugin][35] = false
	} else {
		forceon[plugin][target] = false
	}

	return 1
}

public weap_allowbuy_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)
	new status = get_param(3)

	if(target == -1) {
		allowbuy[plugin][33] = status
	} else if(target == -2) {
		allowbuy[plugin][34] = status
	} else if(target == 0) {
		allowbuy[plugin][35] = status
	} else {
		allowbuy[plugin][target] = status
	}

	return 1
}

public weap_allowpickup_ground_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)
	new status = get_param(3)

	if(target == -1) {
		allowpickup_ground[plugin][33] = status
	} else if(target == -2) {
		allowpickup_ground[plugin][34] = status
	} else if(target == 0) {
		allowpickup_ground[plugin][35] = status
	} else {
		allowpickup_ground[plugin][target] = status
	}

	return 1
}

public weap_allowpickup_drop_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)
	new status = get_param(3)

	if(target == -1) {
		allowpickup_drop[plugin][33] = status
	} else if(target == -2) {
		allowpickup_drop[plugin][34] = status
	} else if(target == 0) {
		allowpickup_drop[plugin][35] = status
	} else {
		allowpickup_drop[plugin][target] = status
	}

	return 1
}

public weap_allowdrop_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new target = get_param(2)
	new status = get_param(3)

	if(target == -1) {
		allowdrop[plugin][33] = status
	} else if(target == -2) {
		allowdrop[plugin][34] = status
	} else if(target == 0) {
		allowdrop[plugin][35] = status
	} else {
		allowdrop[plugin][target] = status
	}

	return 1
}

public weap_hideground_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new status = get_param(2)

	new oldhideground_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(hideground[plugin_order[i]] != -1) {
			oldhideground_t = hideground[plugin_order[i]]
			break
		}
	}

	hideground[plugin] = status

	new hideground_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(hideground[plugin_order[i]] != -1) {
			hideground_t = hideground[plugin_order[i]]
			break
		}
	}

	if(oldhideground_t && !hideground_t) {
		new ent = -1
		while((ent = find_ent_by_class(ent, "armoury_entity"))) {
			set_entity_visibility(ent)
		}
	}

	return 1
}

public weap_removedrop_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new status = get_param(2)

	removedrop[plugin] = status

	return 1
}

public weap_blockfirein_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new plugin = get_param(1)
	new status = get_param(2)

	blockfirein[plugin] = status

	return 1
}

public get_teamarraynum(id) {
	if(cs_get_user_team(id) == CS_TEAM_T) {
		return 33
	}
	return 34
}

weapforce(id, force=0) {
	new hasc4 = user_has_weapon(id, CSW_C4)
	strip_user_weapons(id)
	laststrip[id] = time_time()

	new reload_t[32]
	for(new i = 0; i < 32; i++) {
		reload_t[i] = 0
	}
	new reloaddefault_t = 0

	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(reloadon[plugin_order[i]][id]) {
			for(new j = 0; j < 32; j++) {
				reload_t[j] = reload[plugin_order[i]][id][j]
			}
			reloaddefault_t = reloaddefault[plugin_order[i]][id]
			break
		}
		if(reloadon[plugin_order[i]][get_teamarraynum(id)]) {
			for(new j = 0; j < 32; j++) {
				reload_t[j] = reload[plugin_order[i]][get_teamarraynum(id)][j]
			}
			reloaddefault_t = reloaddefault[plugin_order[i]][get_teamarraynum(id)]
			break
		}
		if(reloadon[plugin_order[i]][35]) {
			for(new j = 0; j < 32; j++) {
				reload_t[j] = reload[plugin_order[i]][35][j]
			}
			reloaddefault_t = reloaddefault[plugin_order[i]][35]
			break
		}
	}
	if(force) {
		for(new i = 0; i < NUM_PLUGINS; i++) {
			if(forceon[plugin_order[i]][id]) {
				for(new j = 0; j < 32; j++) {
					reload_t[j] = forcereload[plugin_order[i]][id][j]
				}
				reloaddefault_t = forcereloaddefault[plugin_order[i]][id]
				break
			}
			if(forceon[plugin_order[i]][get_teamarraynum(id)]) {
				for(new j = 0; j < 32; j++) {
					reload_t[j] = forcereload[plugin_order[i]][get_teamarraynum(id)][j]
				}
				reloaddefault_t = forcereloaddefault[plugin_order[i]][get_teamarraynum(id)]
				break
			}
			if(forceon[plugin_order[i]][35]) {
				for(new j = 0; j < 32; j++) {
					reload_t[j] = forcereload[plugin_order[i]][35][j]
				}
				reloaddefault_t = forcereloaddefault[plugin_order[i]][35]
				break
			}
		}
	}

	for(new i = 0; i < 32; i++) {
		if(reload_t[i]) {
			new weapon[32]
			get_weaponname(i, weapon, 31)
			for(new j = 0; j < reload_t[i]; j++) {
				give_item(id, weapon)
			}
		}
	}
	new defaultname[32]
	get_weaponname(reloaddefault_t, defaultname, 31)
	engclient_cmd(id,defaultname)
	defaultname[30] = id
	set_task(0.1, "select_weap", 0, defaultname, 31)

	if(hasc4) {
		give_item(id, "weapon_c4")
		cs_set_user_plant(id)
	}
}

public select_weap(defaultname[]) {
	engclient_cmd(defaultname[30],defaultname)
}

weapcompliance(id) {
	new bool:forceon_t = false
	new forcerules_t[32]
	for(new i = 0; i < 32; i++) {
		forcerules_t[i] = 0
	}

	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(forceon[plugin_order[i]][id]) {
			forceon_t = true
			for(new j = 0; j < 32; j++) {
				forcerules_t[j] = forcerules[plugin_order[i]][id][j]
			}
			break
		}
		if(forceon[plugin_order[i]][get_teamarraynum(id)]) {
			forceon_t = true
			for(new j = 0; j < 32; j++) {
				forcerules_t[j] = forcerules[plugin_order[i]][get_teamarraynum(id)][j]
			}
			break
		}
		if(forceon[plugin_order[i]][35]) {
			forceon_t = true
			for(new j = 0; j < 32; j++) {
				forcerules_t[j] = forcerules[plugin_order[i]][35][j]
			}
			break
		}
	}

	if(forceon_t) {
		new clip, ammo
		new wepi = get_user_weapon(id, clip, ammo)

		if(wepi < 1 || wepi > 32 || forcerules_t[wepi] || wepi == CSW_C4) {
			return true
		} else {
			return false
		}
	}

	return true
}

public weap_forcedefault_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new target = get_param(1)

	if(target == -1) {
		new targetindex, targetname[33]
		if(cmd_targetset(-1, "@T", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				weapforce(targetindex)
			}
		}
	} else if(target == -2) {
		new targetindex, targetname[33]
		if(cmd_targetset(-1, "@CT", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				weapforce(targetindex)
			}
		}
	} else if(target == 0) {
		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				weapforce(targetindex)
			}
		}
	} else {
		weapforce(target)
	}

	return 1
}

public dam_respawn(id) {
	while(task_exists(id)) {
		remove_task(id)
	}

	set_task(0.2, "spawned", id)
	laststrip[id] = time_time()
}

public message_TextMsg() {
	new blockfirein_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(blockfirein[plugin_order[i]] != -1) {
			blockfirein_t = removedrop[plugin_order[i]]
			break
		}
	}

	if(!blockfirein_t) {
		return PLUGIN_CONTINUE
	}

	return PLUGIN_HANDLED
}

public message_SendAudio(msg_id, msg_dest, entity) {
	new blockfirein_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(blockfirein[plugin_order[i]] != -1) {
			blockfirein_t = removedrop[plugin_order[i]]
			break
		}
	}

	if(!blockfirein_t) {
		return PLUGIN_CONTINUE
	}

	new string[18]
	get_msg_arg_string(2, string, 17)
	if(!equal(string, "%!MRAD_FIREINHOLE")) {
		return PLUGIN_CONTINUE
	}

	return PLUGIN_HANDLED
}

public check_weapons() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(!weapcompliance(targetindex)) {
				weapforce(targetindex,1)
			}
		}
	}

	new removedrop_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(removedrop[plugin_order[i]] != -1) {
			removedrop_t = removedrop[plugin_order[i]]
			break
		}
	}

	if(removedrop_t) {
		new ent = -1
		while((ent = find_ent_by_class(ent, "weaponbox"))) {
			if(entity_get_int(ent, EV_ENT_owner) <= 32) {
				remove_entity(ent)
			}
		}
	}

	new hideground_t = 0
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(hideground[plugin_order[i]] != -1) {
			hideground_t = hideground[plugin_order[i]]
			break
		}
	}

	if(hideground_t) {
		new ent = -1
		while((ent = find_ent_by_class(ent, "armoury_entity"))) {
			set_entity_visibility(ent,0)
		}
	}
}

public spawned(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		weapforce(id)
	}
}

public buy(id) {
	new allowbuy_t = true
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(allowbuy[i][id] != -1) {
			allowbuy_t = allowbuy[i][id]
			break
		}
		if(allowbuy[i][get_teamarraynum(id)] != -1) {
			allowbuy_t = allowbuy[i][get_teamarraynum(id)]
			break
		}
		if(allowbuy[i][35] != -1) {
			allowbuy_t = allowbuy[i][35]
			break
		}
	}

	if(!allowbuy_t) {
		client_print(id, print_center, "You cannot purchase weapons at this time!")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

#define BUYCMDS_NUM 74
new buycmds[BUYCMDS_NUM][] = {
"usp",
"glock",
"deagle",
"p228",
"elites",
"fn57",
"m3",
"xm1014",
"mp5",
"tmp",
"p90",
"mac10",
"ump45",
"ak47",
"galil",
"famas",
"sg552",
"m4a1",
"aug",
"scout",
"awp",
"g3sg1",
"sg550",
"m249",
"vest",
"vesthelm",
"flash",
"hegren",
"sgren",
"defuser",
"nvgs",
"shield",
"primammo",
"secammo",
"km45",
"9x19mm",
"nighthawk",
"228compact",
"elites",
"fiveseven",
"12gauge",
"autoshotgun",
"smg",
"mp",
"c90",
"mac10",
"ump45",
"cv47",
"defender",
"clarion",
"krieg552",
"m4a1",
"bullup",
"scout",
"magnum",
"d3au1",
"krieg550",
"m249",
"vest",
"vesthelm",
"flash",
"hegren",
"sgren",
"defuser",
"nvgs",
"shield",
"primammo",
"secammo",
"rebuy",
"cl_rebuy",
"cl_setrebuy",
"autobuy",
"cl_autobuy",
"cl_setautobuy"
}

public client_command(id) {
	new arg[13]
	if(read_argv(0,arg,12) > 11) {
		return PLUGIN_CONTINUE
	}

	for(new i = 0; i < BUYCMDS_NUM; i++) {
		if(equal(buycmds[i], arg)) {
			return buy(id)
		}
	}

	return PLUGIN_CONTINUE
}

public drop(id) {
	new allowdrop_t = true
	for(new i = 0; i < NUM_PLUGINS; i++) {
		if(allowdrop[i][id] != -1) {
			allowdrop_t = allowdrop[i][id]
			break
		}
		if(allowdrop[i][get_teamarraynum(id)] != -1) {
			allowdrop_t = allowdrop[i][get_teamarraynum(id)]
			break
		}
		if(allowdrop[i][35] != -1) {
			allowdrop_t = allowdrop[i][35]
			break
		}
	}

	if(!allowdrop_t) {
		client_print(id, print_center, "You cannot drop weapons at this time!")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public pfn_touch(ptr,ptd) {
	if(!ptr || !ptd) {
		return PLUGIN_CONTINUE
	}

	new toucherclass[32], touchedclass[32]
	entity_get_string(ptr, EV_SZ_classname, toucherclass, 31)
	entity_get_string(ptd, EV_SZ_classname, touchedclass, 31)

	if(!equal(touchedclass, "player")) {
		return PLUGIN_CONTINUE
	}

	new touchermodel[32]
	entity_get_string(ptr, EV_SZ_model, touchermodel, 31)

	if(equal(touchermodel, "models/w_backpack.mdl")) {
		return PLUGIN_CONTINUE
	}

	new id = ptd
	if(equal(toucherclass, "weaponbox") && entity_get_int(ptr,EV_ENT_owner) <= 32) {
		new allowpickup_drop_t = true
		for(new i = 0; i < NUM_PLUGINS; i++) {
			if(allowpickup_drop[i][id] != -1) {
				allowpickup_drop_t = allowpickup_drop[i][id]
				break
			}
			if(allowpickup_drop[i][get_teamarraynum(id)] != -1) {
				allowpickup_drop_t = allowpickup_drop[i][get_teamarraynum(id)]
				break
			}
			if(allowpickup_drop[i][35] != -1) {
				allowpickup_drop_t = allowpickup_drop[i][35]
				break
			}
		}

		if(!allowpickup_drop_t || laststrip[id] >= time_time()-1) {
			return PLUGIN_HANDLED
		}
	}

	if((equal(toucherclass, "weaponbox") && entity_get_int(ptr,EV_ENT_owner) > 32) || equal(toucherclass, "armoury_entity")) {
		new allowpickup_ground_t = true
		for(new i = 0; i < NUM_PLUGINS; i++) {
			if(allowpickup_ground[i][id] != -1) {
				allowpickup_ground_t = allowpickup_ground[i][id]
				break
			}
			if(allowpickup_ground[i][get_teamarraynum(id)] != -1) {
				allowpickup_ground_t = allowpickup_ground[i][get_teamarraynum(id)]
				break
			}
			if(allowpickup_ground[i][35] != -1) {
				allowpickup_ground_t = allowpickup_ground[i][35]
				break
			}
		}

		if(!allowpickup_ground_t || laststrip[id] >= time_time()-1) {
			return PLUGIN_HANDLED
		}
	}

	return PLUGIN_CONTINUE
}
