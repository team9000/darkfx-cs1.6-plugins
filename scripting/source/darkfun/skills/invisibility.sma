#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <sub_handler>

public plugin_init() {
	register_plugin("DFX-MOD - Invisibility","MM","doubleM")
}

public darkfx_register_fw() {
	dfx_registerskill("Invisibility", "invisibility")
}

public darkfx_change_skill(id) {
	if(id && is_user_connected(id)) {
		new skill = dfx_getskill(id, "invisibility")

		new params[6]
		params[0] = kRenderFxGlowShell
		params[1] = 0
		params[2] = 0
		params[3] = 0
		params[4] = kRenderTransAlpha
		params[5] = 255-30*(skill)

		handle_rendering(0, id, params)
	}
}
