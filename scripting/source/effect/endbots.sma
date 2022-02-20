#include <amxmodx>
#include <sub_stocks>
#include <sub_time>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <sub_handler>

new ctbot = 0
new tbot = 0
new botsstarted = 0

public plugin_init() {
   	register_plugin("Effect - End Bots","T9k","Team9000")

	ctbot = 0
	tbot = 0
	botsstarted = 0

	if(find_ent_by_class(-1, "info_player_deathmatch") && find_ent_by_class(-1, "info_player_start")) {
		set_task(0.5, "check_bots", 0, "", 0, "b")
	}

	return PLUGIN_CONTINUE
}

static const botnames[2][] = {
"Anti-Round End Bot T",
"Anti-Round End Bot CT"
}

public refresh_bot(bot) {
	new Float:origin[3]
	origin[0] = -2000.0
	origin[1] = -2000.0
	origin[2] = -2000.0
	entity_set_int(bot, EV_INT_solid, SOLID_NOT)
	entity_set_int(bot, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_vector(bot, EV_VEC_origin, origin)
	set_pev(bot, pev_effects, (pev(bot, pev_effects) | 128))
	set_pev(bot, pev_solid, 0)

	new params[6]
	params[0] = kRenderFxGlowShell
	params[1] = 0
	params[2] = 0
	params[3] = 0
	params[4] = kRenderTransAlpha
	params[5] = 0

	handle_rendering(6, bot, params)
}

public check_bots() {
//	if(!botsstarted) {
//		new targetindex, targetname[33]
//		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
//			while((targetindex = cmd_target())) {
//				if(is_user_alive(targetindex)) {
					botsstarted = 1
//				}
//			}
//		}
//	}

	if(!botsstarted) {
		return
	}

	if(num_onteam(CS_TEAM_T) < 3 &&
		(!tbot || !is_user_connected(tbot))) {
		tbot = engfunc(EngFunc_CreateFakeClient, botnames[0])
		if(tbot) {
			new ptr[128]
			dllfunc(DLLFunc_ClientConnect, tbot, botnames[0], "127.0.0.1", ptr)
			dllfunc(DLLFunc_ClientPutInServer, tbot)
			cs_set_user_team(tbot, CS_TEAM_T, CS_T_TERROR)
//			cs_user_spawn(tbot)
		}
	} else if(num_onteam(CS_TEAM_T) >= 4 &&
		(tbot && is_user_connected(tbot))) {
		server_cmd("kick #%d", get_user_userid(tbot))
		tbot = 0
	}

	if(num_onteam(CS_TEAM_CT) < 3 &&
		(!ctbot || !is_user_connected(ctbot))) {
		ctbot = engfunc(EngFunc_CreateFakeClient, botnames[1])
		if(ctbot) {
			new ptr[128]
			dllfunc(DLLFunc_ClientConnect, ctbot, botnames[1], "127.0.0.1", ptr)
			dllfunc(DLLFunc_ClientPutInServer, ctbot)
			cs_set_user_team(ctbot, CS_TEAM_CT, CS_CT_URBAN)
//			cs_user_spawn(ctbot)
		}
	} else if(num_onteam(CS_TEAM_CT) >= 4 &&
		(ctbot && is_user_connected(ctbot))) {
		server_cmd("kick #%d", get_user_userid(ctbot))
		ctbot = 0
	}

	if(tbot && is_user_connected(tbot)) {
		refresh_bot(tbot)
	}
	if(ctbot && is_user_connected(ctbot)) {
		refresh_bot(ctbot)
	}
}
