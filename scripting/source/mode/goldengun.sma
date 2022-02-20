#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <sub_modes>
#include <sub_weapons>
#include <sub_damage>
#include <sub_ents>

new bool:goldengunmode = false
new lastweap[33]

public plugin_init() {
	register_plugin("Mode - Golden Gun","T9k","Team9000")

	goldengunmode = false

	register_event("CurWeapon","curweapon","b")

	return PLUGIN_CONTINUE 
} 

public plugin_precache() {
	precache_model("models/team9000/v_golddeagle.mdl")
	precache_model("models/team9000/p_golddeagle.mdl")
}

public ent_registerremove_fw() {
	ent_registerremove("hostage_entity")
	ent_registerremove("info_bomb_target")
	ent_registerremove("info_hostage_rescue")
}

public mode_init() {
	register_mode("goldengun", "goldengunmode", "Golden Gun Mode", 1, LVL_GOLDENGUNMODE)
}

public mode_activate_e() {
	ent_remove("hostage_entity")
	ent_remove("info_bomb_target")
	ent_remove("info_hostage_rescue")
	set_restrictions()
}

public mode_activate() {
	goldengunmode = true

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

	goldengunmode = false
}

public mode_deactivate() {
	weap_forcedefault(0)
}

public set_restrictions() {
	new bool:allow[32] = {false,...}
	allow[CSW_KNIFE] = true
	allow[CSW_DEAGLE] = true
	allow[CSW_FLASHBANG] = true
	allow[CSW_SMOKEGRENADE] = true
	allow[CSW_HEGRENADE] = true

	new override[32] = {0,...}
	override[CSW_KNIFE] = 1
	override[CSW_DEAGLE] = 10

	weap_force(1, 0, allow, override, CSW_DEAGLE)

	weap_reload(1, 0, override, CSW_DEAGLE)

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

public cs_set_user_ammo(id, amount) {
	new ent = -1, weapon[32], clip, ammo
	new wid = get_user_weapon(id, clip, ammo)
	get_weaponname(wid, weapon, 31)
	while((ent = find_ent_by_class(ent, weapon)) != 0) {
		if(id == entity_get_edict(ent, EV_ENT_owner)) {
			cs_set_weapon_ammo(ent, amount)
			break
		}
	}
}

public curweapon(id) {
	if(goldengunmode) {
		if(is_user_connected(id) && is_user_alive(id)) {
			new clip, ammo
			new wepi = get_user_weapon(id, clip, ammo)
			if(wepi == CSW_DEAGLE) {
				if(wepi != lastweap[id]) {
					entity_set_string(id, EV_SZ_viewmodel, "models/team9000/v_golddeagle.mdl")
					entity_set_string(id, EV_SZ_weaponmodel, "models/team9000/p_golddeagle.mdl")

					set_task(0.1, "setmodel", id)
					set_task(0.2, "setmodel", id)
					set_task(0.5, "setmodel", id)
					set_task(1.0, "setmodel", id)
				}

				if(clip > 1) {
					cs_set_user_ammo(id, 1)

					message_begin(MSG_ONE, get_user_msgid("CurWeapon"), _, id)
					write_byte(1)
					write_byte(CSW_DEAGLE)
					write_byte(1)
					message_end()
				}
				cs_set_user_bpammo(id,wepi,99)
			}
			lastweap[id] = wepi
		}
	}
}

public setmodel(id) {
	if(goldengunmode) {
		if(is_user_connected(id) && is_user_alive(id)) {
			new clip, ammo
			new wepi = get_user_weapon(id, clip, ammo)
			if(wepi == CSW_DEAGLE) {
				entity_set_string(id, EV_SZ_viewmodel, "models/team9000/v_golddeagle.mdl")
				entity_set_string(id, EV_SZ_weaponmodel, "models/team9000/p_golddeagle.mdl")
			}
		}
	}
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(goldengunmode && !private && attacker && victim != attacker) {
		if(equal(weapon, "deagle")) {
			new origin[3]
			get_user_origin(attacker, origin)

			dam_dealdamage(victim, attacker, 100000, weapon, headshot, 0, origin[0], origin[1], origin[2])
		}
	}
}
