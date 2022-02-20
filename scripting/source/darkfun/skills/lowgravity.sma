#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <dfx>
#include <dfx-hook>
#include <sub_handler>

public plugin_init() {
	register_plugin("DFX-MOD - Gravity","MM","doubleM")
}

public darkfx_register_fw() {
	dfx_registerskill("Low Gravity", "lowgrav")
}

public darkfx_change_skill(id) {
	new skill = dfx_getskill(id, "lowgrav")
	handle_gravity(0, id, 1-0.15*skill)
}
