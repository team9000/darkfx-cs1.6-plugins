#include <amxmodx>
#include <fakemeta>

new const g_objective_ents[][] = {
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone"
}

new const bool:g_objective_prim[] = {
	true,
	true,
	true,
	false,
	false,
	false,
	false,
	true,
	true
}

#define HIDE_ROUND_TIMER (1<<4)

new g_msgid_hideweapon

public plugin_precache() {
	register_forward(FM_Spawn, "forward_spawn")
}

public plugin_init() {
	register_plugin("Effect - No Objectives", "1.0", "Team9000")

	if(is_objective_map())
		return

	g_msgid_hideweapon = get_user_msgid("HideWeapon")
	register_message(g_msgid_hideweapon, "message_hide_weapon")
	register_event("ResetHUD", "event_hud_reset", "b")
	set_msg_block(get_user_msgid("RoundTime"), BLOCK_SET)
}

public forward_spawn(ent) {
	if (!pev_valid(ent))
		return FMRES_IGNORED

	static classname[32], i
	pev(ent, pev_classname, classname, sizeof classname - 1)
	for (i = 0; i < sizeof g_objective_ents; ++i) {
		if (equal(classname, g_objective_ents[i])) {
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}

public message_hide_weapon() {
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | HIDE_ROUND_TIMER)
}

public event_hud_reset(id) {
	message_begin(MSG_ONE, g_msgid_hideweapon, _, id)
	write_byte(HIDE_ROUND_TIMER)
	message_end()
}

bool:is_objective_map() {
	new const classname[] = "classname"
	for (new i = 0; i < sizeof g_objective_ents; ++i) {
		if (g_objective_prim[i] && engfunc(EngFunc_FindEntityByString, FM_NULLENT, classname, g_objective_ents[i]))
			return true
	}

	return false
}
