#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <sub_respawn>
#include <sub_damage>
#include <cstrike>

new transferteam[33]

public plugin_init() {
	register_plugin("DARKSURF - RESPAWN","T9k","Team9000")

	set_task(2.0, "respawn")
	set_task(60.0,"respawn",0,"",0,"b")

//	register_concmd("say /spec","player_spec")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	transferteam[id] = 0;
}

public plugin_natives() {
	register_library("darksurf_respawn")
}

public respawn() {
	respawn_auto(0, 2, 1)
}

public player_spec(id) {
	if(cs_get_user_team(id) == CS_TEAM_CT || cs_get_user_team(id) == CS_TEAM_T) {
		if(cs_get_user_team(id) == CS_TEAM_CT) {
			transferteam[id] = 2;
		} else {
			transferteam[id] = 1;
		}
		cs_set_user_team(id, CS_TEAM_SPECTATOR)
		user_kill(id)
	} else if(cs_get_user_team(id) == CS_TEAM_SPECTATOR) {
		if(transferteam[id] == 1) {
 			cs_set_user_team(id, CS_TEAM_T)
		} else if(transferteam[id] == 2) {
			cs_set_user_team(id, CS_TEAM_CT)
		}
		user_kill(id);
	}
	return PLUGIN_HANDLED
}
