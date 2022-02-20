#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <sub_handler>

#define HPAMOUNT 200

public plugin_init() {
	register_plugin("DARKSURF - *Max HP","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Max HP Upgrade", "maxhp", 50, 1)
}

public surf_change_skill(id) {
	if(surf_getskill(id, "maxhp") && surf_getskillon(id, "maxhp")) {
		handle_maxhp(0, id, HPAMOUNT)
	} else {
		handle_maxhp_off(0, id)
	}
}
