#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <dfx>
#include <dfx-stealth>

public plugin_init() {
	register_plugin("DFX-MOD - *Stealth","MM","doubleM")

	set_task(5.0, "stealthall")
}

public darkfx_register_fw() {
	dfx_registerskill2("Deluxe Stealth", "stealth")
}

public plugin_natives() {
	register_library("dfx-mod-stealth")

	register_native("is_stealth","is_stealth_impl")
}

public is_stealth_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return dfx_getskill2(get_param(1), "stealth")
}

public stealthall() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(dfx_getskill2(targetindex, "stealth")) {
				nofootsteps(targetindex, 1)
			} else {
				nofootsteps(targetindex, 0)
			}
		}
	}

	set_task(5.0, "stealthall")
}

public nofootsteps(id, onoff) {
	if(is_user_connected(id)) {
		if((get_user_team(id) == 1 || get_user_team(id) == 2) && is_user_alive(id)) {
			set_user_footsteps(id, onoff)
		}
	}

	return PLUGIN_CONTINUE
}
