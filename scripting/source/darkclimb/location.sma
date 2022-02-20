#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <engine>
#include <darkclimb.inc>
#include <settings>
#include <sub_storage>

new climbing[33]
new usebuttonon[33]
new wastouching[33]

new triggerareas[10][7]
//[0] = type
//      1=entrance 2=exit 3=finish 4=shortcut
//[1-3] = min
//[4-6] = max
new triggerbutton[5][4]
//[0] = type
//      1=entrance 2=exit 3=finish 4=shortcut
//[1-3] = origin
new features[7]
//[0] = Autoheal
//[1] = Godmode
//[2] = Scout
//[3] = Nightvision
//[4] = Checkpoint Limit (-1 = OFF|0 = UNLIMITED)
//[5] = Auto-bhop
//[6] = Semiclip

public plugin_init() {
	register_plugin("DARKCLIMB - LOCATION","T9k","Team9000")

	climb_clearlocations()
	set_task(30.0, "climb_alert", 0, "", 0, "b")
}

public plugin_natives() {
	register_library("darkclimb_location")

	register_native("climb_setclimbing","climb_setclimbing_impl")
	register_native("climb_getclimbing","climb_getclimbing_impl")

	register_native("climb_setfeature","climb_setfeature_impl")
	register_native("climb_getfeature","climb_getfeature_impl")

	register_native("climb_clearlocations","climb_clearlocations_impl")

	register_native("climb_setarea","climb_setarea_impl")
	register_native("climb_getarea","climb_getarea_impl")

	register_native("climb_setbutton","climb_setbutton_impl")
	register_native("climb_getbutton","climb_getbutton_impl")
}

public climb_alert() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(climbing[targetindex] == 0) {
				alertmessage_v(targetindex,3,"[DARKCLIMB] ALERT! You have not yet started the climb timer!")
				alertmessage_v(targetindex,3,"[DARKCLIMB] You must start the timer to be able to complete the map!")
			}
		}
	}
}

public dam_respawn_postmove(id) {
	if(climbing[id] == 1) {
		if(!climb_getchecks(id)) {
			alertmessage_v(id,3,"[DARKCLIMB] You had no checkpoints and died!")
			alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Stopped")
			climbing[id] = 0

			climb_timerstop(id)
		}
	}
}

public climb_setclimbing_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	climbing[get_param(1)] = get_param(2)
	return get_param(2)
}

public climb_getclimbing_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return climbing[get_param(1)]
}

public climb_setfeature_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	features[get_param(1)] = get_param(2)

	return 1
}

public climb_getfeature_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return features[get_param(1)]
}

public climb_clearlocations_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	for(new i = 0; i < 10; i++) {
		for(new j = 0; j < 7; j++) {
			triggerareas[i][j] = 0
		}
	}
	for(new i = 0; i < 5; i++) {
		for(new j = 0; j < 4; j++) {
			triggerbutton[i][j] = 0
		}
	}
	features[0] = 1
	features[1] = 0
	features[2] = 1
	features[3] = 1
	features[4] = 0
	features[5] = 0
	features[6] = 1

	return 1
}

public climb_setarea_impl(id, numparams) {
	if(numparams != 8)
		return log_error(10, "Bad native parameters")

	triggerareas[get_param(1)][0] = get_param(2)
	triggerareas[get_param(1)][1] = get_param(3)
	triggerareas[get_param(1)][2] = get_param(4)
	triggerareas[get_param(1)][3] = get_param(5)
	triggerareas[get_param(1)][4] = get_param(6)
	triggerareas[get_param(1)][5] = get_param(7)
	triggerareas[get_param(1)][6] = get_param(8)

	return 1
}

public climb_getarea_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	set_array(2, triggerareas[get_param(1)], 7)

	return 1
}

public climb_setbutton_impl(id, numparams) {
	if(numparams != 5)
		return log_error(10, "Bad native parameters")

	triggerbutton[get_param(1)][0] = get_param(2)
	triggerbutton[get_param(1)][1] = get_param(3)
	triggerbutton[get_param(1)][2] = get_param(4)
	triggerbutton[get_param(1)][3] = get_param(5)

	return 1
}

public climb_getbutton_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	set_array(2, triggerbutton[get_param(1)], 4)

	return 1
}

public client_connect(id) {
	usebuttonon[id] = 0
	climbing[id] = 0
	wastouching[id] = 0
}

public client_PreThink(id) {
	if(is_user_connected(id) && !is_user_connecting(id)) {
		if(is_user_alive(id) && (get_user_team(id) == 1 || get_user_team(id) == 2)) {
			if(get_user_button(id)&IN_USE && !usebuttonon[id]) {
				usebuttonon[id] = 1
				Use(id)
			} else if(!(get_user_button(id)&IN_USE) && usebuttonon[id]) {
				usebuttonon[id] = 0
			}

			new origin[3]
			get_user_origin(id, origin)

			new touching = 0
			for(new i = 0; i < 10; i++) {
				if(triggerareas[i][0]) {
					if(origin[0] > triggerareas[i][1] &&
					   origin[1] > triggerareas[i][2] &&
					   origin[2] > triggerareas[i][3] &&
					   origin[0] < triggerareas[i][4] &&
					   origin[1] < triggerareas[i][5] &&
					   origin[2] < triggerareas[i][6]) {
						touching = 1
						if(!wastouching[id]) {
							action(id, triggerareas[i][0])
						}
					}
				}
			}
			wastouching[id] = touching
		}
	}
}

public action(id, action) {
	if(action == 1) {
		if(climbing[id] == 1) {
			alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Restarted")
		} else {
			alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Started")
		}
		climbing[id] = 1

		climb_cpstart(id)
		climb_timerstart(id)
	}
	if(action == 2) {
		if(climbing[id] == 1) {
			alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Stopped")
			climbing[id] = 0

			climb_timerstop(id)
		}
	}
	if(action == 3) {
		if(climbing[id] == 1) {
			climbing[id] = 2

			climb_timerfinish(id)
		}
	}
	if(action == 4) {
		if(climbing[id] == 1) {
			alertmessage_v(id,3,"[DARKCLIMB] Disqualified by a Shortcut!")
			alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Stopped")
			climbing[id] = 0

			climb_timerstop(id)
		}
	}
}

public Use(id) {
	new origin[3]
	get_user_origin(id, origin)

	for(new i = 0; i < 5; i++) {
		if(triggerbutton[i][0]) {
			if(origin[0] > triggerbutton[i][1] - BUTTON_DISTANCE &&
			   origin[1] > triggerbutton[i][2] - BUTTON_DISTANCE &&
			   origin[2] > triggerbutton[i][3] - BUTTON_DISTANCE &&
			   origin[0] < triggerbutton[i][1] + BUTTON_DISTANCE &&
			   origin[1] < triggerbutton[i][2] + BUTTON_DISTANCE &&
			   origin[2] < triggerbutton[i][3] + BUTTON_DISTANCE) {
				action(id, triggerbutton[i][0])
			}
		}
	}
}
