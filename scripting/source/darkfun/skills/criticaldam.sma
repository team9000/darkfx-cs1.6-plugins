#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <sub_damage>

public plugin_init() {
	register_plugin("DFX-MOD - Critical Damage","MM","doubleM")
}

public darkfx_register_fw() {
	dfx_registerskill("Critical Damage", "critdam")
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(!private && attacker && victim != attacker) {
		new origin[3]
		get_user_origin(attacker, origin)

		new skill = dfx_getskill(attacker, "critdam")
		dam_dealdamage(victim, attacker, floatround(0.15*damage*(skill)), weapon, headshot, 0, origin[0], origin[1], origin[2])
	}
}
