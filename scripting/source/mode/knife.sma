#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_modes>
#include <sub_weapons>
#include <sub_ents>

public plugin_init() {
	register_plugin("Mode - Knife","T9k","Team9000")

	return PLUGIN_CONTINUE 
} 

public ent_registerremove_fw() {
	ent_registerremove("hostage_entity")
	ent_registerremove("info_bomb_target")
	ent_registerremove("info_hostage_rescue")
}

public mode_init() {
	register_mode("knife", "knifemode", "Knife Only Mode", 1, LVL_KNIFEMODE)
}

public mode_activate_e() {
	ent_remove("hostage_entity")
	ent_remove("info_bomb_target")
	ent_remove("info_hostage_rescue")
	set_restrictions()
}

public mode_activate() {
	weap_forcedefault(0)

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(cs_get_user_vip(targetindex)) {
				cs_set_user_vip(targetindex, 0)
			}
		}
	}
}

public mode_deactivate_e() {
	ent_restore("hostage_entity")
	ent_restore("info_bomb_target")
	ent_restore("info_hostage_rescue")

	set_restrictions_off()
}

public mode_deactivate() {
	weap_forcedefault(0)
}

public set_restrictions() {
	new bool:allow[32] = {false,...}
	allow[CSW_KNIFE] = true
	allow[CSW_FLASHBANG] = true
	allow[CSW_SMOKEGRENADE] = true
	allow[CSW_HEGRENADE] = true

	new override[32] = {0,...}
	override[CSW_KNIFE] = 1

	weap_force(1, 0, allow, override, CSW_KNIFE)

	weap_reload(1, 0, override, CSW_KNIFE)

	weap_allowbuy(1, 0, 0)
	weap_allowpickup_ground(1, 0, 0)
	weap_allowpickup_drop(1, 0, 0)
	weap_allowdrop(1, 0, 0)
	weap_hideground(1, 1)
	weap_removedrop(1, 1)
}

public set_restrictions_off() {
	weap_reload_off(1, 0)
	weap_force_off(1, 0)

	weap_allowbuy(1, 0, -1)
	weap_allowpickup_ground(1, 0, -1)
	weap_allowpickup_drop(1, 0, -1)
	weap_allowdrop(1, 0, -1)
	weap_hideground(1, -1)
	weap_removedrop(1, -1)
}
