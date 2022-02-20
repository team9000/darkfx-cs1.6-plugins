#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_damage>

new CsTeams:player_team[33]

public plugin_init() { 
	register_plugin("Admin Log", "T9k", "Team9000") 

	register_logevent("team_event",6, "2=triggered")
	register_logevent("event", 2, "0=World triggered")

	return PLUGIN_CONTINUE 
} 

public client_connect(id) {
	player_team[id] = CS_TEAM_SPECTATOR
}

public client_authorized(id) {
	playeralert(id, "connected")
}

public client_putinserver(id) {
	playeralert(id, "entered the game")
}

public client_PreThink(id) {
	if(is_user_connected(id)) {
		new CsTeams:team = cs_get_user_team(id)
		if(team != player_team[id]) {
			if(team == CS_TEAM_T) {
				playeralert(id, "joined the Terrorists")
			} else if(team == CS_TEAM_CT) {
				playeralert(id, "joined the CTs")
			} else {
				playeralert(id, "joined the Spectators")
			}

			player_team[id] = team
		}
	}
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(victim == attacker) {
		playeralert(attacker, "commited suicide")
	} else {
		new name[33]
		get_user_name(victim, name, 32)
		new steamid[32]
		get_user_authid(victim, steamid, 31)
		if(headshot) {
			playeralert_v(attacker, "killed %s<%s> with a headshot from a %s", name, steamid, weapon)
		} else {
			playeralert_v(attacker, "killed %s<%s> with a %s", name, steamid, weapon)
		}
	}
}

public team_event() {
	new sTeam[256], sAction[256]

	read_logargv(1, sTeam, 255)
	read_logargv(3, sAction, 255)

	if(equal(sTeam, "TERRORIST")) {
		if(equal(sAction, "Target_Bombed")) {
			game_log_v("Terrorists Win - Target Bombed")
		} else if(equal(sAction, "VIP_Assassinated")) {
			game_log_v("Terrorists Win - VIP Assassinated")
		} else if(equal(sAction, "Terrorists_Win")) {
			game_log_v("Terrorists Win - Enemies Destroyed")
		} else if(equal(sAction, "Hostages_Not_Rescued")) {
			game_log_v("Terrorists Win - Hostages Not Rescued")
		} else if(equal(sAction, "VIP_Not_Escaped")) {
			game_log_v("Terrorists Win - VIP Not Escaped")
		}
	} else if(equal(sTeam, "CT")) {
		if(equal(sAction, "VIP_Escaped")) {
			game_log_v("CTs Win - VIP Escaped")
		} else if(equal(sAction, "Bomb_Defused")) {
			game_log_v("CTs Win - Bomb Defused")
		} else if(equal(sAction, "All_Hostages_Rescued")) {
			game_log_v("CTs Win - All Hostages Rescued")
		} else if(equal(sAction, "CTs_Win")) {
			game_log_v("CTs Win - Enemies Destroyed")
		}
	}
}

public event() {
	new sAction[256]
	read_logargv(1, sAction, 255)

	if(equal(sAction, "Game_Commencing")) {
		game_log_v("Game Commencing")
	}
}
