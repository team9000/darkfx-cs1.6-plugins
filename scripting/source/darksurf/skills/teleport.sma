#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <darksurf.inc>
#include <admin_teleport>

public plugin_init() {
	register_plugin("DARKSURF - *Teleportation","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Teleportation", "teleport", 999999, 0)
}

public surf_change_skill(id) {
	if(get_user_flags(id) & LVL_TELEPORTATION && surf_getskillon(id, "teleport")) {
		if(is_user_alive(id)) {
			set_task(0.01, "menu", id)
		}
		surf_setskillon(id, "teleport", 0)
	}
}

public menu(id) {
	teleport_playermenu(id)
}
