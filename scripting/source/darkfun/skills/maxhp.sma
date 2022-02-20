#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <sub_handler>

public plugin_init() {
	register_plugin("DFX-MOD - Max HP","MM","doubleM")
	set_task(30.0, "update_maxhp", 0, "", 0, "b")
}

public darkfx_register_fw() {
	dfx_registerskill("Max HP Upgrade", "maxhp")
}

public client_authorized(id) {
	darkfx_change_skill(id)
}

public darkfx_change_skill(id) {
	new skill = dfx_getskill(id, "maxhp")
	if(skill > 0) {
		new hpamount = 100+35*(skill)
		handle_maxhp(0, id, hpamount)
	} else {
		handle_maxhp_off(0, id)
	}
}

public update_maxhp() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			darkfx_change_skill(targetindex)
		}
	}
}
