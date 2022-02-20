#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <sub_handler>

public plugin_init() {
	register_plugin("DARKSURF - *Invisibility","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Stealth", "invis", 200)
}

public surf_change_skill(id) {
	new skill = surf_getskill(id, "invis") && surf_getskillon(id, "invis")

	new params[6]
	params[0] = kRenderFxGlowShell
	params[1] = 0
	params[2] = 0
	params[3] = 0
	params[4] = kRenderTransAlpha
	params[5] = 255-150*(skill)

	handle_rendering(0, id, params)
}
