#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <darksurf.inc>
#include <sub_handler>

public plugin_init() {
	register_plugin("DARKSURF - *Speed","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Turbo Speed", "speed", 200, 1)
}

public surf_change_skill(id) {
	new skill = surf_getskill(id, "speed") && surf_getskillon(id, "speed")
	new Float:mult = 1.0+2.0*skill
	handle_speed(0, id, mult, 1)
}
