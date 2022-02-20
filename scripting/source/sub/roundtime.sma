#include <amxmodx>
#include <sub_stocks>
#include <sub_roundtime>

new roundmode, commencing, restarting

public plugin_init() {
	register_plugin("Subsys - Roundtime","T9k","Team9000")

	roundmode = 1
	commencing = 0
	restarting = 0

	register_logevent("event", 2, "0=World triggered")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_roundtime")

	register_native("round_mode","round_mode_impl")
}

public freeze_e() {
	if(roundmode == 3) {
		roundmode = 1
		commencing = 0
		freezestart_e()
	}
}

public freeze() {
	if(roundmode == 1) {
		freezestart()
		if(restarting) {
			gamerestart()
		}
		restarting = 0
	}
}

public event() {
	new arg[32]
	read_logargv(1, arg, 31)
	if(containi(arg, "restart_round") != -1) {
		if(get_cvar_float("sv_restartround")) {
			while(task_exists(1986)) {
				remove_task(1986)
			}
			set_task(get_cvar_float("sv_restartround")-0.3, "freeze_e", 1986)
			set_task(get_cvar_float("sv_restartround")+0.3, "freeze", 1986)
			roundmode = 3
			restarting = 1
			roundend()
		} else if(get_cvar_float("sv_restart")) {
			while(task_exists(1986)) {
				remove_task(1986)
			}
			set_task(get_cvar_float("sv_restart")-0.3, "freeze_e", 1986)
			set_task(get_cvar_float("sv_restart")+0.3, "freeze", 1986)
			roundmode = 3
			restarting = 1
			roundend()
		}
	}

	if(containi(arg, "round_end") != -1 && !commencing) {
		while(task_exists(1986)) {
			remove_task(1986)
		}
		set_task(4.7, "freeze_e", 1986)
		set_task(5.3, "freeze", 1986)
		roundmode = 3
		restarting = 0
		roundend()
	}

	if(containi(arg, "game_commencing") != -1) {
		while(task_exists(1986)) {
			remove_task(1986)
		}
		set_task(2.7, "freeze_e", 1986)
		set_task(3.3, "freeze", 1986)
		roundmode = 3
		restarting = 1
		roundend()
		commencing = 1
	}

	if(containi(arg, "round_start") != -1 && roundmode != 3) {
		while(task_exists(1986)) {
			remove_task(1986)
		}
		roundmode = 2
		roundstart()
	}

	return PLUGIN_CONTINUE 
}

public freezestart_e() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("round_freezestart_e", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1)
				callfunc_end()
		}
	}
}

public freezestart() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("round_freezestart", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1)
				callfunc_end()
		}
	}
}

public roundstart() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("round_roundstart", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1)
				callfunc_end()
		}
	}
}

public roundend() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("round_roundend", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1)
				callfunc_end()
		}
	}
}

public gamerestart() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("round_gamerestart", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1)
				callfunc_end()
		}
	}
}

public round_mode_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return roundmode
}
