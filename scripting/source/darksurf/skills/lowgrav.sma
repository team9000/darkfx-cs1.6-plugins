#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <darksurf.inc>
#include <sub_handler>

public plugin_init() {
	register_plugin("DARKSURF - *Gravity","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Low Gravity", "lowgrav", 100, 1)
}

public surf_change_skill(id) {
	new skill = surf_getskill(id, "lowgrav") && surf_getskillon(id, "lowgrav")
	handle_gravity(0, id, 1-0.5*skill)
}
