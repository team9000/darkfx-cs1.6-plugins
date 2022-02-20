#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_modes>
#include <sub_weapons>
#include <sub_ents>
#include <sub_respawn>

public plugin_init() { 
   	register_plugin("Mode - Respawn","T9k","Team9000") 
	register_concmd("amx_respawn","admin_respawn",LVL_RESPAWN,"<authid, nick, #userid, @team or *> - Respawns a player")

	return PLUGIN_CONTINUE 
} 

public ent_registerremove_fw() {
	ent_registerremove("hostage_entity")
	ent_registerremove("info_bomb_target")
	ent_registerremove("func_bomb_target")
	ent_registerremove("info_hostage_rescue")
}

public mode_init() {
	register_mode("respawn", "respawnmode", "Respawn Mode", 1, LVL_RESPAWNMODE)
}

public mode_activate_e() {
	ent_remove("hostage_entity")
	ent_remove("info_bomb_target")
	ent_remove("func_bomb_target")
	ent_remove("info_hostage_rescue")
	set_restrictions()
}

public mode_activate() {
//	weap_forcedefault(0)

	set_task(get_cvar_float("mp_roundtime")*60.0, "stoprespawn",100)
	respawn_auto(0, 3, 2)

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(cs_get_user_vip(targetindex)) {
				cs_set_user_vip(targetindex, 0)
			}
		}
	}
}

public stoprespawn() {
	respawn_auto_off()
}

public mode_deactivate_e() {
	ent_restore("hostage_entity")
	ent_restore("info_bomb_target")
	ent_restore("func_bomb_target")
	ent_restore("info_hostage_rescue")

	set_restrictions_off()

	respawn_auto_off()
	remove_task(100)
}

public mode_deactivate() {
	weap_forcedefault(0)
}

public set_restrictions() {
	new override[32] = {0,...}
	override[CSW_KNIFE] = 1
	override[CSW_HEGRENADE] = 1
	override[CSW_SCOUT] = 10
	override[CSW_M3] = 10
	override[CSW_M4A1] = 10
	override[CSW_AK47] = 10
	override[CSW_ELITE] = 10
	override[CSW_DEAGLE] = 10

	weap_reload(1, 0, override,CSW_M4A1)

	weap_allowbuy(1, 0, 0)
	weap_allowpickup_ground(1, 0, 0)
	weap_allowpickup_drop(1, 0, 0)
	weap_allowdrop(1, 0, 0)
	weap_hideground(1, 1)
	weap_removedrop(1, 1)
}

public set_restrictions_off() {
	weap_reload_off(1, 0)

	weap_allowbuy(1, 0, -1)
	weap_allowpickup_ground(1, 0, -1)
	weap_allowpickup_drop(1, 0, -1)
	weap_allowdrop(1, 0, -1)
	weap_hideground(1, -1)
	weap_removedrop(1, -1)
}

public admin_respawn(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			respawn_now(targetindex)
		}

		adminalert_v(id, "", "respawned %s", targetname)
	}

	return PLUGIN_HANDLED 
} 
