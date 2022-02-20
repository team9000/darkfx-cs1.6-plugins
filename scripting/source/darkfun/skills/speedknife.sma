#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <sub_damage>
#include <sub_handler>

new Float:highset[33]

public plugin_init() {
	register_plugin("DFX-MOD - Speed Knife","MM","doubleM")
}

public darkfx_register_fw() {
	dfx_registerskill("Knife/Speed Upgrade", "knifespeed")
}

public client_connect(id) {
	highset[id] = 0.0
}

public darkfx_change_skill(id) {
	new skill = dfx_getskill(id, "knifespeed")
	new Float:mult = 1.0+0.2*skill
	handle_speed(0, id, mult, 1)
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(!private && attacker && victim != attacker && containi(weapon, "kni") != -1) {
		new origin[3]
		get_user_origin(attacker, origin)

		new skill = dfx_getskill(attacker, "knifespeed")
		dam_dealdamage(victim, attacker, floatround(0.3*damage*(skill)), weapon, headshot, 0, origin[0], origin[1], origin[2])
	}
}
