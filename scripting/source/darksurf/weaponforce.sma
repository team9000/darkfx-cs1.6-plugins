#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <darksurf.inc>
#include <sub_roundtime>
#include <sub_weapons>

public plugin_init() {
   	register_plugin("DARKSURF - WEAPON FORCE","T9k","Team9000")

	set_task(0.2, "do_weapons")

	return PLUGIN_CONTINUE
}

public do_weapons() {
	new reload[32] = {0,...}
	reload[CSW_SCOUT] = 10
	reload[CSW_KNIFE] = 1
	weap_reload(2, 0, reload, CSW_SCOUT)
	weap_removedrop(2, 1)

	new bool:allow[32] = {true,...}
	allow[CSW_FLASHBANG] = false
	allow[CSW_SMOKEGRENADE] = false

	weap_force(2, 0, allow, reload, CSW_SCOUT)

	weap_blockfirein(2,1)
}

public round_roundstart() {
	weap_forcedefault(0)
}
