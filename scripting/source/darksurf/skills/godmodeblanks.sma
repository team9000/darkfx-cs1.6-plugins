#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <sub_handler>
#include <fun>
#include <cstrike>
#include <sub_damage>
#include <sub_hud>

new godmodeon[33]

public plugin_init() {
	register_plugin("DARKSURF - *GodmodeBlanks","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Godmode/Blanks", "godmode", 0)
}

public client_connect(id) {
	godmodeon[id] = 0
	return PLUGIN_CONTINUE
}

public dam_respawn(id) {
	godmodeon[id] = 0
	dam_set_semigodmode(id, 0)
	dam_set_blanks(id, 0)
	surf_change_skill(id)
}

public surf_change_skill(id) {
	new skill = surf_getskill(id, "godmode") && surf_getskillon(id, "godmode")

	if(skill) {
		godmodeon[id] = 1
		dam_set_semigodmode(id, 1)
		dam_set_blanks(id, 1)
		myhud_small(11, id, "", 0.0)
	} else {
		if(godmodeon[id]) {
			myhud_small(11, id, "GODMODE WILL REMAIN ON UNTIL RESPAWN!", -1.0)
		} else {
			myhud_small(11, id, "", 0.0)
		}
	}
}
