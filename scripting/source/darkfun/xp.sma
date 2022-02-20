#define DFX_NEEDEARNINGXP
#define DFX_NEEDEARNINGNAME

#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <dfx>
#include <settings>
#include <sub_hud>
#include <sub_damage>
#include <sub_auth>
#include <sub_roundtime>
#include <sub_frozen>

new planter

public plugin_init() {
	register_plugin("DFX-MOD - XP","MM","doubleM")

	register_logevent("xp_player_event",3, "1=triggered")
	register_logevent("xp_team_event",6, "2=triggered")
}

#define NUM_EVENTS 9
new oneevent[NUM_EVENTS]

public round_freezestart() {
	for(new i = 0; i < NUM_EVENTS; i++) {
		oneevent[i] = 0
	}
}

public plugin_natives() {
	register_library("dfx-mod-xp")

	register_native("dfx_updatexphud","dfx_updatexphud_impl")
}

public xp_levelxpcalc(level) {
	if(level >= 23) {
		return 2000000
	}

	new Float:total = float(FIRST_LEVEL)
	for(new i = 0; i < level-2; i++) {
		total *= LEVEL_MULTIPLIER
	}
	return floatround(total)
}

public dfx_updatexphud_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	xp_update(get_param(1))
	return 1
}

public client_putinserver(id) {
	xp_update(id)
	if(dfx_getxp(id) == 0 && dfx_getlevel(id) == 8) {
		set_task(10.0, "free_msg", id)
	}
}

public free_msg(id) {
	alertmessage(id, 3, "You have recieved level 8 for free!")
	alertmessage(id, 3, "To learn how to buy skills, type /help")
}

public xp_update(id) {
	if(is_user_connected(id)) {
		if(dfx_playerloaded(id)) {
			if(get_authed(id)) {
				if(dfx_getxp(id) >= xp_levelxpcalc(dfx_getlevel(id)+1)) {
					dfx_setxp(id, dfx_getxp(id) - xp_levelxpcalc(dfx_getlevel(id)+1))
					dfx_setlevel(id, dfx_getlevel(id) + 1)
					dfx_settokens(id, dfx_gettokens(id) + 1)

					new message[256]
					format(message, 255, "CONGRADULATIONS - You have leveled up to level %d^nTo spend level tokens, type /shop^nYou need %d more XP to reach level %d", dfx_getlevel(id), dfx_getxp(id) > xp_levelxpcalc(dfx_getlevel(id)+1) ? 0 : xp_levelxpcalc(dfx_getlevel(id)+1)-dfx_getxp(id), dfx_getlevel(id)+1)
					myhud_large(message, id, 10.0, 3, 0, 200, 0, 2, -1.0, 0.30, 0.7, 0.02, 0.5)

					if(dfx_getlevel(id) >= 20) {
						dfx_settokens2(id, dfx_gettokens2(id) + 1)
						format(message, 255, "CONGRADULATIONS - You have earned a DELUXE TOKEN^nTo view deluxe skills, type /shop2")
						myhud_large(message, id, 10.0, 3, 200, 0, 0, 2, -1.0, 0.30, 0.7, 0.02, 0.5)
					}

					if(dfx_getxp(id) >= xp_levelxpcalc(dfx_getlevel(id)+1)) {
						set_task(10.0, "xp_update", id)
					}
				}

				if(get_frozen(id)) {
					myhud_small(0, id, "ACCOUNT FROZEN^n^n", -1.0)
				} else {
					new hud_xp[129]
					format(hud_xp, 128, "Level %d^nXP: %d/%d^n^n", dfx_getlevel(id), dfx_getxp(id), xp_levelxpcalc(dfx_getlevel(id)+1))
					myhud_small(0, id, hud_xp, -1.0)
				}
			} else {
				myhud_small(0, id, "", -1.0)
			}
		} else {
			myhud_small(0, id, "LOADING ACCOUNT...^n^n", -1.0)
		}
	}
}

public xp_earn(id, earning, Float:multiplyer) {
	if(!dfx_playerloaded(id) || !get_authed(id) || get_frozen(id)) {
		return
	}
	if(oneevent[earning]) {
		return
	}

	new earnxp = floatround(earningXP[earning]*multiplyer)

	new temp[256]
	format(temp, 255, "[DFX-MOD]%s - Gained %d XP", earningName[earning], earnxp)
	alertmessage(id,3,temp)
	dfx_setxp(id, dfx_getxp(id) + earnxp)

	xp_update(id)
}

public Float:enough_apponents(id) {
	if(num_apponents(id) > 1) {
		return 1.0
	} else if(num_apponents(id) == 1) {
		return 0.3
	}

	return 0.0
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(attacker && victim != attacker) {
		xp_earn(attacker, 0, enough_apponents(attacker))
	}
}

public xp_tswin() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "@T", 0, targetname, 32, 0)) {
		while((targetindex = cmd_target(0))) {
			xp_earn(targetindex, 4, enough_apponents(targetindex))
		}
	}
	oneevent[4] = 1
}

public xp_ctswin() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "@CT", 0, targetname, 32, 0)) {
		while((targetindex = cmd_target(0))) {
			xp_earn(targetindex, 4, enough_apponents(targetindex))
		}
	}
	oneevent[4] = 1
}

public xp_player_event() {
	new sArg[256], sAction[256], sName[33]
	new id, iUserId

	read_logargv(0, sArg, 255)
	read_logargv(2, sAction, 255)
	parse_loguser(sArg, sName, 32, iUserId)
	id = find_player("k", iUserId)

	// Bomb Planted
	if(equal(sAction, "Planted_The_Bomb")) {
		xp_earn(id, 1, enough_apponents(id))
		planter = id
		oneevent[1] = 1
	}

	// Bomb Defused
	else if(equal(sAction, "Defused_The_Bomb")) {
		xp_earn(id, 2, enough_apponents(id))
		oneevent[2] = 1
	}

	// Hostage Touched
	else if(equal(sAction, "Touched_A_Hostage")) {
		xp_earn(id, 5, enough_apponents(id))
	}

	// Hostage Rescued
	else if(equal(sAction, "Rescued_A_Hostage")) {
		xp_earn(id, 6, enough_apponents(id))
	}

	// VIP Escaped
	else if(equal(sAction, "Escaped_As_VIP")) {
		xp_earn(id, 7, enough_apponents(id))
		oneevent[7] = 1
	}

	// VIP Assassinated
	else if(equal(sAction, "Assassinated_The_VIP")) {
		xp_earn(id, 8, enough_apponents(id))
		oneevent[8] = 1
	}
}

public xp_team_event() {
	new sTeam[256], sAction[256]

	read_logargv(1, sTeam, 255)
	read_logargv(3, sAction, 255)

	if(equal(sTeam, "TERRORIST")) {
		if(equal(sAction, "Target_Bombed")) {
			xp_earn(planter, 3, enough_apponents(planter))
			oneevent[3] = 1
			xp_tswin()
		} else if(equal(sAction, "VIP_Assassinated")) {
			xp_tswin()
		} else if(equal(sAction, "Terrorists_Win")) {
			xp_tswin()
		} else if(equal(sAction, "Hostages_Not_Rescued")) {
			xp_tswin()
		} else if(equal(sAction, "VIP_Not_Escaped")) {
			xp_tswin()
		}
	} else if(equal(sTeam, "CT")) {
		if(equal(sAction, "VIP_Escaped")) {
			xp_ctswin()
		} else if(equal(sAction, "Bomb_Defused")) {
			xp_ctswin()
		} else if(equal(sAction, "All_Hostages_Rescued")) {
			xp_ctswin()
		} else if(equal(sAction, "CTs_Win")) {
			xp_ctswin()
		}
	}
}
