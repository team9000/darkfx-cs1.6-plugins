#include <amxmodx>
#include <sub_stocks>
#include <sub_votes>
#include <sub_hud>

new quest[128]
new option_name[10][128]

new next_map[64]
new next_map_admin

public plugin_init() { 
	register_plugin("Admin Votes","T9k","Team9000")

	register_concmd("amx_vote","admin_vote",LVL_VOTE,"<question> <answer> [answer]... - Starts a vote")
	register_concmd("amx_votemap","admin_votemap",LVL_VOTEMAP,"<mapname> [mapname] [mapname]... - Starts a map vote")
	register_menucmd(register_menuid("Accept Map Vote?"), 1023, "mapvote_menu")
	return PLUGIN_CONTINUE 
} 

public analyze_vote(votes[], results[]) {
	alertmessage_v(0,3,"%s Result: %s", quest, option_name[results[0]]) 
	admin_log_v("%s Result: %s", quest, option_name[results[0]])

	set_cvar_num("amx_voting", 0)
	return PLUGIN_HANDLED
} 

public admin_vote(id, level, cid) {
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED

	if(get_cvar_num("amx_voting")) { 
		client_print(id,print_console,"There is already a vote in progress") 
		return PLUGIN_HANDLED 
	}

	adminalert_v(id, "", "started a vote")
	new name[33]
	get_user_name(id, name, 32)
	new steamid[33]
	get_user_authid(id, steamid, 32)

	read_argv(1,quest,127)
	vote_new("analyze_vote", 30, quest, 2)
	admin_log_v("ADMIN %s<%s> - %s", name, steamid, quest)

	for(new i = 0; i < read_argc()-2 && i < 10; i++) {
		read_argv(i+2, option_name[i], 127)
		vote_addoption(option_name[i])
		admin_log_v("ADMIN %s<%s> - >%s", name, steamid, option_name[i])
	}

	set_cvar_num("amx_voting", 1)

	return PLUGIN_HANDLED 
}

public analyze_votemap(votes[], results[]) {
	if(next_map_admin == 0) {
		alertmessage_v(0,3,"Map Vote admin has left! Result Refused")
		set_cvar_num("amx_voting", 0)
		return PLUGIN_HANDLED
	}

	alertmessage_v(0,3,"Map Vote Result: %s, Awaiting Admin Acceptance...", option_name[results[0]]) 
	admin_log_v("Map Vote Result: %s, Awaiting Admin Acceptance...", option_name[results[0]])
	copy(next_map, 63, option_name[results[0]])

	new content[192]
	new keys = MENU_KEY_1|MENU_KEY_2
	format(content, 191, "\yAccept Map Vote?^nChange Map to %s?^n", next_map)
	format(content, 191, "%s\w1. Yes^n", content)
	format(content, 191, "%s\r2. No", content)
	show_menu(next_map_admin,keys,content)
	set_menuopen(next_map_admin, 1)

	set_task(10.0, "auto_refuse", 123)

	return PLUGIN_HANDLED
}

public client_disconnect(id) {
	if(id == next_map_admin) {
		next_map_admin = 0
	}
}

public mapvote_menu(id,key) {
	set_menuopen(id, 0)

	if(id != next_map_admin) {
		return PLUGIN_CONTINUE
	}

	set_cvar_num("amx_voting", 0)
	remove_task(123)

	if(key == 0) {
		alertmessage_v(0,3,"Map Vote Result Accepted!")
		alertmessage_v(0,3,"Changing map to %s", next_map)
		admin_log_v("Map Vote Result Accepted!")

		set_task(2.8,"delayed_showscores")
		set_task(3.0,"delayed_changemap")
	} else if(key == 1) {
		alertmessage_v(0,3,"Map Vote Result Refused")
	}

	return PLUGIN_CONTINUE
}

public delayed_changemap(mapname[]) {
	server_cmd("changelevel %s",next_map)
}

public delayed_showscores() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex,"+showscores")
		}
	}
}

public auto_refuse() {
	alertmessage_v(0,3,"Admin did not respond! Map Vote Result Refused")
	set_cvar_num("amx_voting", 0)
	next_map_admin = 0
}

public admin_votemap(id, level, cid) {
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	if(get_cvar_num("amx_voting")) { 
		client_print(id,print_console,"There is already a vote in progress") 
		return PLUGIN_HANDLED 
	}

	new mapname[128]
	for(new i = 0; i < read_argc()-1 && i < 10; i++) {
		read_argv(i+1, mapname, 127)
		if(is_map_valid(mapname)==0) {
			client_print(id,print_console,"%s is an invalid map",mapname)
			return PLUGIN_HANDLED 
		}
	}

	adminalert_v(id, "", "started a map vote")
	new name[33]
	get_user_name(id, name, 32)
	new steamid[33]
	get_user_authid(id, steamid, 32)

	vote_new("analyze_votemap", 30, "Admin Map Vote", 2)
	admin_log_v("ADMIN %s<%s> - Admin Map Vote", name, steamid)

	for(new i = 0; i < read_argc()-1 && i < 10; i++) {
		read_argv(i+1, option_name[i], 127)
		vote_addoption(option_name[i])
		admin_log_v("ADMIN %s<%s> - >%s", name, steamid, option_name[i])
	}

	set_cvar_num("amx_voting", 1)
	next_map_admin = id

	return PLUGIN_HANDLED 
}
