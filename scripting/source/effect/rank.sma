#include <amxmodx>
#include <sub_stocks>
#include <sub_damage>
#include <sub_storage>
#include <csx>

new onlinetime[33]
new kills[33]
new hs[33]
new deaths[33]
new hosties[33]
new bombs[33]
new defused[33]

new planter

public plugin_init() {
	register_plugin("Effect - Rank","T9k","Team9000")

	register_logevent("player_event",3, "1=triggered")
	register_logevent("team_event",6, "2=triggered")
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(num_apponents(victim) > 1) {
		deaths[victim]++
	}
	if(num_apponents(attacker) > 1) {
		if(victim != attacker) {
			kills[attacker]++
			if(headshot) {
				hs[attacker]++
			}
		}
	}
}

public player_event() {
	new sArg[256], sAction[256], sName[33]
	new id, iUserId

	read_logargv(0, sArg, 255)
	read_logargv(2, sAction, 255)
	parse_loguser(sArg, sName, 32, iUserId)
	id = find_player("k", iUserId)

	if(!id) {
		return
	}

	// Bomb Planted
	if(equal(sAction, "Planted_The_Bomb")) {
		planter = id
	}

	// Bomb Defused
	else if(equal(sAction, "Defused_The_Bomb")) {
		if(num_apponents(id) > 1) {
			defused[id]++
		}
	}

	// Hostage Rescued
	else if(equal(sAction, "Rescued_A_Hostage")) {
		if(num_apponents(id) > 1) {
			hosties[id]++
		}
	}
}

public team_event() {
	new sTeam[256], sAction[256]

	read_logargv(1, sTeam, 255)
	read_logargv(3, sAction, 255)

	if(equal(sTeam, "TERRORIST")) {
		if(equal(sAction, "Target_Bombed")) {
			if(is_user_connected(planter)) {
				if(num_apponents(planter) > 1) {
					bombs[planter]++
				}
			}
		}
	} else if(equal(sTeam, "CT")) {

	}
}

public client_connect(id) {
	onlinetime[id] = time_time()
	kills[id] = 0
	hs[id] = 0
	deaths[id] = 0
	hosties[id] = 0
	bombs[id] = 0
	defused[id] = 0
}

public storage_register_fw() {
	storage_reg_playerfield("onlinetime")
	storage_reg_playerfield("kills")
	storage_reg_playerfield("headshots")
	storage_reg_playerfield("deaths")
	storage_reg_playerfield("hosties")
	storage_reg_playerfield("bombs")
	storage_reg_playerfield("defused")
}

public storage_presaveplayer_fw(id) {
	new value[32]

	if(id > 0) {
		new result = get_playervalue(id, "onlinetime", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += time_time() - onlinetime[id]
			onlinetime[id] = time_time()
			format(value, 31, "%d", valuei)
			set_playervalue(id, "onlinetime", value)
		}

		result = get_playervalue(id, "kills", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += kills[id]
			kills[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "kills", value)
		}

		result = get_playervalue(id, "headshots", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += hs[id]
			hs[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "headshots", value)
		}

		result = get_playervalue(id, "deaths", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += deaths[id]
			deaths[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "deaths", value)
		}

		result = get_playervalue(id, "hosties", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += hosties[id]
			hosties[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "hosties", value)
		}

		result = get_playervalue(id, "bombs", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += bombs[id]
			bombs[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "bombs", value)
		}

		result = get_playervalue(id, "defused", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei += defused[id]
			defused[id] = 0
			format(value, 31, "%d", valuei)
			set_playervalue(id, "defused", value)
		}
	}
}
