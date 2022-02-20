#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_modes>
#include <sub_weapons>
#include <sub_damage>
#include <sub_ents>

new bool:grenademode = false

public plugin_init() {
	register_plugin("Mode - Grenade","T9k","Team9000")

	grenademode = false

	return PLUGIN_CONTINUE 
} 

public ent_registerremove_fw() {
	ent_registerremove("hostage_entity")
	ent_registerremove("info_bomb_target")
	ent_registerremove("info_hostage_rescue")
}

public mode_init() {
	register_mode("grenade", "grenademode", "Grenade Mode", 1, LVL_GRENADEMODE)
}

public mode_activate_e() {
	ent_remove("hostage_entity")
	ent_remove("info_bomb_target")
	ent_remove("info_hostage_rescue")
	set_restrictions()
}

public mode_activate() {
	weap_forcedefault(0)

	grenademode = true

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

	grenademode = false
}

public mode_deactivate() {
	weap_forcedefault(0)
}

public set_restrictions() {
	new bool:allow[32] = {false,...}
	allow[CSW_HEGRENADE] = true

	new override[32] = {0,...}
	override[CSW_KNIFE] = 1
	override[CSW_HEGRENADE] = 1

	weap_force(1, 0, allow, override, CSW_HEGRENADE)

	weap_reload(1, 0, override, CSW_HEGRENADE)

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

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(grenademode && !private && attacker && victim != attacker) {
		if(equal(weapon, "grenade")) {
			new origin[3]
			get_user_origin(attacker, origin)

			dam_dealdamage(victim, attacker, 100000, weapon, headshot, 0, origin[0], origin[1], origin[2])
		}
	}
}
