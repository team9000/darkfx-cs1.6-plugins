#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <darksurf.inc>
#include <settings>
#include <sub_hud>
#include <sub_damage>
#include <sub_roundtime>
#include <sub_frozen>

public plugin_init() {
	register_plugin("DARKSURF - POINTS","T9k","Team9000")
}

public plugin_natives() {
	register_library("darksurf_points")

	register_native("surf_updatepointshud","surf_updatepointshud_impl")
}

public surf_updatepointshud_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	points_update(get_param(1))
	return 1
}

public client_putinserver(id) {
	points_update(id)
}

public points_update(id) {
	if(is_user_connected(id)) {
		if(surf_playerloaded(id)) {
			if(get_frozen(id)) {
				myhud_small(0, id, "ACCOUNT FROZEN^n^n", -1.0)
			} else {
				new hud_points[129]
				format(hud_points, 128, "Points: %d^n^n", surf_getpoints(id))
				myhud_small(0, id, hud_points, -1.0)
			}
		} else {
			myhud_small(0, id, "LOADING ACCOUNT...^n^n", -1.0)
		}
	}
}
