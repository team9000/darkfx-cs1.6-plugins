#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>

public plugin_init() {
	register_plugin("Admin Commands","T9k","Team9000")
	register_concmd("amx_team", "admin_team",LVL_TEAM, "<authid, nick, #userid, @team or *> <1=T|2=CT> - Changes the team of a player")

	return PLUGIN_CONTINUE
}

public admin_team(id, level, cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new team[32]
	read_argv(2,team,31)

	if(!equal(team, "1") && !equal(team, "2")) {
		client_print(id, print_console, "* Invalid Team Number")
		return PLUGIN_HANDLED
	}

	new teamname[32]
	if(equal(team, "1")) {
		if(!find_ent_by_class(-1, "info_player_deathmatch")) {
			client_print(id, print_console, "* Invalid Team Number")
			return PLUGIN_HANDLED
		}
		copy(teamname, 31, "TERRORIST")
	} else if(equal(team, "2")) {
		if(!find_ent_by_class(-1, "info_player_start")) {
			client_print(id, print_console, "* Invalid Team Number")
			return PLUGIN_HANDLED
		}
		copy(teamname, 31, "CT")
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(equal(team, "1") && cs_get_user_team(targetindex) == CS_TEAM_CT) {
				user_kill(targetindex, 1)
				cs_set_user_team(targetindex, CS_TEAM_T)
			} else if(equal(team, "2") && cs_get_user_team(targetindex) == CS_TEAM_T) {
				user_kill(targetindex, 1)
				cs_set_user_team(targetindex, CS_TEAM_CT)
			}
		}

		adminalert_v(id, "", "swapped %s to the %s team", targetname, teamname)
	}

	return PLUGIN_HANDLED 
} 
