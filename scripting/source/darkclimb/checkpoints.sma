#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <darkclimb.inc>
#include <settings>
#include <sub_damage>

new totalchecks[33]
new storedchecks[33]
new Float:checks[33][5][3]

public plugin_init() {
	register_plugin("DARKCLIMB - CHECKPOINTS","T9k","Team9000")

	register_clcmd("restart","restart")
	register_clcmd("say /restart","restart")

	register_clcmd("cp","checkpoint")
	register_clcmd("check","checkpoint")
	register_clcmd("checkpoint","checkpoint")
	register_clcmd("say /cp","checkpoint")
	register_clcmd("say /check","checkpoint")
	register_clcmd("say /checkpoint","checkpoint")

	register_clcmd("go","gocheck")
	register_clcmd("gocheck","gocheck")
	register_clcmd("say /go","gocheck")
	register_clcmd("say /gocheck","gocheck")

	register_clcmd("stuck","stuck")
	register_clcmd("unstuck","stuck")
	register_clcmd("destuck","stuck")
	register_clcmd("say /stuck","stuck")
	register_clcmd("say /unstuck","stuck")
	register_clcmd("say /destuck","stuck")
}

public plugin_natives() {
	register_library("darkclimb_checkpoints")
	register_native("climb_getchecks", "climb_getchecks_impl")
	register_native("climb_cpstart", "climb_cpstart_impl")
}

public client_connect(id) {
	totalchecks[id] = 0
	storedchecks[id] = 0
}

public climb_cpstart_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	new id = get_param(1)

	totalchecks[id] = 0
	storedchecks[id] = 0

	return 1
}

public restart(id) {
	if(!is_user_alive(id) || (get_user_team(id) != 1 && get_user_team(id) != 2)) {
		alertmessage_v(id,3,"[DARKCLIMB] You must be alive to restart!")
		return PLUGIN_HANDLED
	}

	climb_cpstart(id)
	climb_setclimbing(id, 0)
	alertmessage_v(id,3,"[DARKCLIMB] Climb Timer Stopped")
	dam_dealdamage(id, id, 100000, "respawn", 0, 1, 0, 0, 0)
	return PLUGIN_HANDLED
}

public checkpoint(id) {
	if(!is_user_alive(id) || (get_user_team(id) != 1 && get_user_team(id) != 2)) {
		alertmessage_v(id,3,"[DARKCLIMB] You must be alive to place a checkpoint!")
		return PLUGIN_HANDLED
	}
	if(climb_getfeature(4) == -1) {
		alertmessage_v(id,3,"[DARKCLIMB] Checkpoints cannot be used on this map!")
		return PLUGIN_HANDLED
	}

	if(climb_getclimbing(id) != 2) {
		new limit
		if(climb_getfeature(4) == 0) {
			limit = 999999
		} else {
			limit = climb_getfeature(4)
		}

		if(totalchecks[id] >= limit) {
			alertmessage_v(id,3,"[DARKCLIMB] You have used up all your checkpoints!")
			return PLUGIN_HANDLED
		}
	}

	if(get_user_button(id) & IN_DUCK) {
		alertmessage_v(id,3,"[DARKCLIMB] You cannot place a checkpoint while ducking!")
		return PLUGIN_HANDLED
	}

	new Float:origin[3]
	entity_get_vector(id, EV_VEC_origin, origin)

	if(vector_distance(origin, checks[id][0]) < 10 && origin[2] > checks[id][0][2]) {
		alertmessage_v(id,3,"[DARKCLIMB] Too close to your old checkpoint!")
		return PLUGIN_HANDLED
	}

	alertmessage_v(id,3,"[DARKCLIMB] Saved A Checkpoint") 

	if(climb_getclimbing(id) != 2) {
		totalchecks[id]++
	}

	for(new i = storedchecks[id]-1; i >= 0; i--) {
		if(i == 4) continue
		checks[id][i+1][0] = checks[id][i][0]
		checks[id][i+1][1] = checks[id][i][1]
		checks[id][i+1][2] = checks[id][i][2]
	}

	entity_get_vector(id, EV_VEC_origin, checks[id][0])

	if(storedchecks[id] < 5) {
		storedchecks[id]++
	}

	return PLUGIN_HANDLED
}

public gocheck(id) {
	if(!is_user_alive(id) || (get_user_team(id) != 1 && get_user_team(id) != 2)) {
		alertmessage_v(id,3,"[DARKCLIMB] You must be alive to go to a checkpoint!")
		return PLUGIN_HANDLED
	}
	if(climb_getfeature(4) == -1) {
		alertmessage_v(id,3,"[DARKCLIMB] Checkpoints cannot be used on this map!")
		return PLUGIN_HANDLED
	}

	if(!storedchecks[id]) {
		alertmessage_v(id,3,"[DARKCLIMB] You dont have a checkpoint to go to!")
		return PLUGIN_HANDLED
	}

	alertmessage_v(id,3,"[DARKCLIMB] Went To A Previous Checkpoint")

	move_to_check(id, 0)

	return PLUGIN_HANDLED
}

public dam_respawn_postmove(id) {
	if(!is_user_alive(id) || (get_user_team(id) != 1 && get_user_team(id) != 2)) {
		return 0
	}
	if(climb_getfeature(4) == -1) {
		return 0
	}

	if(!storedchecks[id]) {
		return 0
	}

	move_to_check(id, 1)

	return 1
}

public climb_getchecks_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	id = get_param(1)

	return totalchecks[id]
}

public stuck(id) {
	if(!is_user_alive(id) || (get_user_team(id) != 1 && get_user_team(id) != 2)) {
		alertmessage_v(id,3,"[DARKCLIMB] You must be alive to revert to a checkpoint!")
		return PLUGIN_HANDLED
	}
	if(climb_getfeature(4) == -1) {
		alertmessage_v(id,3,"[DARKCLIMB] Checkpoints cannot be used on this map!")
		return PLUGIN_HANDLED
	}

	if(storedchecks[id] <= 1) {
		alertmessage_v(id,3,"[DARKCLIMB] You dont have a checkpoint to revert back to!")
		return PLUGIN_HANDLED
	}

	alertmessage_v(id,3,"[DARKCLIMB] Reverted To A Previous Checkpoint") 

	totalchecks[id]--
	storedchecks[id]--

	for(new i = 1; i < storedchecks[id]; i++) {
		checks[id][i-1][0] = checks[id][i][0]
		checks[id][i-1][1] = checks[id][i][1]
		checks[id][i-1][2] = checks[id][i][2]
	}

	move_to_check(id, 0)

	return PLUGIN_HANDLED
}

public move_to_check(id, wasdead) {
	new origin[3], Float:check[3]
	get_user_origin(id,origin)
	check[0] = checks[id][0][0]
	check[1] = checks[id][0][1]
	check[2] = checks[id][0][2]
	check[2] += 5

	if(!wasdead) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(11) 
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		message_end() 
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(11) 
	write_coord(floatround(check[0]))
	write_coord(floatround(check[1]))
	write_coord(floatround(check[2]))
	message_end() 

	entity_set_vector(id, EV_VEC_origin, check)

	new Float:angle[3] = {0.0,0.0,0.0}
	entity_set_vector(id, EV_VEC_velocity, angle)
}
