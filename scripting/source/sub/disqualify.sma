#include <amxmodx>
#include <sub_stocks>
#include <sub_roundtime>

#define NUM_DISQUALIFY 4
/*
0 = CHICKEN
1 = SURF SKILL
2 = GODMODE
3 = NOCLIP
*/

/*
ONE TIME DISQUALIFIES
0 = SURF SKILL
1 = ARMOR
2 = HEALTH
3 = GIVE
4 = SLAP
5 = STACK
6 = ROCKET
7 = UBERSLAP
8 = TELEPORT
*/

new disqualified[33][NUM_DISQUALIFY]

public plugin_init() {
	register_plugin("Subsys - Disqualify","T9k","Team9000")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	for(new i = 0; i < NUM_DISQUALIFY; i++) {
		disqualified[id][i] = 0
	}
}

public plugin_natives() {
	register_library("sub_disqualify")

	register_native("disqualify_now", "disqualify_now_impl")
	register_native("disqualify_start", "disqualify_start_impl")
	register_native("disqualify_stop", "disqualify_stop_impl")
	register_native("disqualify_get", "disqualify_get_impl")
}

public disqualify_now_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new reason = get_param(2)

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("disqualify_now_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_push_int(reason)
				callfunc_end()
			}
		}
	}

	return 1
}

public disqualify_start_impl(pid, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new reason = get_param(2)

	disqualified[id][reason] = 1

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("disqualify_changed_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}

	return 1
}

public disqualify_stop_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new reason = get_param(2)

	disqualified[id][reason] = 0

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("disqualify_changed_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}

	return 1
}

public disqualify_get_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)

	for(new i = 0; i < NUM_DISQUALIFY; i++) {
		if(disqualified[id][i]) {
			return i
		}
	}

	return -1
}
