#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <darkclimb.inc>
#include <settings>
#include <sub_hud>
#include <sub_disqualify>
#include <sub_storage>

new Float:timer[33]
new offtillrespawn[33]

new loaded, trying
new times_sum, times_num

public plugin_init() {
	register_plugin("DARKCLIMB - TIMER","T9k","Team9000")
	set_task(1.0,"init_countdown")

	loaded = 0
	trying = 0
	times_sum = 0
	times_num = 0

	register_clcmd("climbstatus","climbstatus")
	register_clcmd("climbstat","climbstatus")
	register_clcmd("climb","climbstatus")
	register_clcmd("say /climbstatus","climbstatus")
	register_clcmd("say /climbstat","climbstatus")
	register_clcmd("say /climb","climbstatus")
}

public climbstatus(id) {
	new temp[1025], name[33], Float:elapsed, statuscolor[33], status[65]
	format(temp, 1024, "<html><body bgcolor=^"000000^" text=^"FFFFFF^"><table border=^"1^" cellspacing=^"0^" bordercolor=^"FFFFFF^" bgcolor=^"000000^">")
	format(temp, 1024, "%s<tr><td>Player Name</td><td>Climb Timer</td><td>Checkpoints</td><td>Status</td></tr>", temp)

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex, name, 32)
			if(climb_getclimbing(targetindex) == 0) {
				elapsed = 0.0
				status = "Starting"
				statuscolor = "660000"
			} else if(climb_getclimbing(targetindex) == 1) {
				elapsed = get_gametime() - timer[targetindex]
				format(status, 64, "Climbing")
				statuscolor = "000066"
			} else {
				elapsed = timer[targetindex]
				format(status, 64, "Finished")
				statuscolor = "006600"
			}

			format(temp, 1024, "%s<tr><td>%s</td><td>%d:%02d</td><td>%s</td><td bgcolor=^"%s^">%s</td></tr>", temp, name, floatround(elapsed, floatround_floor) / 60, floatround(elapsed, floatround_floor) % 60, climb_getchecks(targetindex) ? "Yes" : "No", statuscolor, status)
		}
	}
	format(temp, 1024, "%s</table></body></html>", temp)
	show_motd(id,temp,"Climb Status")
	return PLUGIN_HANDLED
}

public storage_loadplayer_fw(id, status) {
	if(id == 0 && status && !loaded && !trying) {
		trying = 1
		set_task(0.5, "average_query")
	}
}

public average_query() {
	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new query[512]
	format(query, 511, "SELECT climb_times_sum, climb_times_num FROM storage_maps where name='%s'", mapname_striped)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", query)
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", queryran, data, size)
	} else {
		if(SQL_NumResults(query) > 0) {
			loaded = 1
			new value[128]

			new colnum = SQL_FieldNameToNum(query, "climb_times_sum")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 127)
				times_sum = str_to_num(value)
			} else {
				loaded = 0
			}

			colnum = SQL_FieldNameToNum(query, "climb_times_num")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 127)
				times_num = str_to_num(value)
			} else {
				loaded = 0
			}
		}
	}
}

public save_average() {
	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[4096]
	format(query, 4095, "UPDATE storage_maps SET ")

	format(query, 4095, "%sclimb_times_sum='%d', ", query, times_sum)
	format(query, 4095, "%sclimb_times_num='%d' ", query, times_num)
	format(query, 4095, "%sWHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public init_countdown() {
	set_task(0.2,"time_remaining",0,"",0,"b")
}

public plugin_natives() {
	register_library("darkclimb_timer")
	register_native("climb_timerstart", "climb_timerstart_impl")
	register_native("climb_timerstop", "climb_timerstop_impl")
	register_native("climb_timerfinish", "climb_timerfinish_impl")
}

public client_connect(id) {
	offtillrespawn[id] = 0
	timer[id] = -1.0
}

public time_remaining() {
	new targetindex, targetname[33], message[256] = ""
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(climb_getclimbing(targetindex) == 0) {
				format(message, 255, "Climb Status: Stopped^n^n")
			} else if(climb_getclimbing(targetindex) == 1) {
				new Float:elapsed
				elapsed = get_gametime() - timer[targetindex]

				if(offtillrespawn[targetindex] == 1) {
					format(message, 255, "Climb Status: DISQUALIFIED DUE TO SKILLS^n")
				} else if(offtillrespawn[targetindex]) {
					format(message, 255, "Climb Status: DISQUALIFIED DUE TO ADMIN COMMANDS^n")
				} else {
					format(message, 255, "Climb Status: In Progress^n")
				}
				format(message, 255, "%sClimb Timer: %d:%02d^n", message, floatround(elapsed, floatround_floor) / 60, floatround(elapsed, floatround_floor) % 60)
				if(climb_getfeature(4) == 0) {
					format(message, 255, "%sCheckpoints: %d^n", message, climb_getchecks(targetindex))
				}
				format(message, 255, "%s^n", message)
			} else {
				new Float:elapsed
				elapsed = timer[targetindex]

				format(message, 255, "Climb Status: Complete^n")
				format(message, 255, "%sClimb Timer: %d:%02d^n", message, floatround(elapsed, floatround_floor) / 60, floatround(elapsed, floatround_floor) % 60)
				if(climb_getfeature(4) == 0) {
					format(message, 255, "%sCheckpoints: %d^n", message, climb_getchecks(targetindex))
				}
				format(message, 255, "%s^n", message)
			}

			myhud_small(9, targetindex, message, -1.0)
		}
	}
}

public disqualify_now_fw(id, reason) {
	if(reason != 0) {
		offtillrespawn[id] = 2
	} else {
		offtillrespawn[id] = 1
	}
}

public disqualify_changed_fw(id) {
	if(disqualify_get(id) != -1) {
		if(disqualify_get(id) != 1) {
			offtillrespawn[id] = 2
		} else {
			offtillrespawn[id] = 1
		}
	}
}

public climb_timerstart_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	new id = get_param(1)
	timer[id] = get_gametime()

	offtillrespawn[id] = 0
	if(disqualify_get(id) != -1) {
		if(disqualify_get(id) != 1) {
			offtillrespawn[id] = 2
		} else {
			offtillrespawn[id] = 1
		}
	}

	return 1
}

public climb_timerstop_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	new id = get_param(1)
	timer[id] = -1.0

	return 1
}

public climb_timerfinish_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	new id = get_param(1)
	timer[id] = get_gametime() - timer[id]

	if(!loaded) {
		return 0
	}

	new Float:old_average
	if(times_num == 0) {
		old_average = 0.0
	} else {
		old_average = float(times_sum) / float(times_num)
	}

	if(!offtillrespawn[id] && (timer[id] < old_average * 5 || times_num < 20)) {
		times_sum += floatround(timer[id])
		times_num++
		save_average()
	}

	new Float:time_average
	if(times_num == 0) {
		time_average = 0.0
	} else {
		time_average = float(times_sum) / float(times_num)
	}

	new place = 0
	if(!offtillrespawn[id]) {
		place = climb_checkrecord(id, timer[id], climb_getchecks(id))
	}

	new Float:time = timer[id]

	new rating[32], points = 0
	if(time > time_average*3) {
		rating = "EXTREMELY SLOW"
	} else if(time > time_average*2) {
		rating = "VERY SLOW"
	} else if(time > time_average*1.5) {
		rating = "SLOW"
	} else if(time > time_average*0.8) {
		rating = "AVERAGE"
	} else if(time > time_average*0.6) {
		rating = "VERY FAST"
	} else {
		rating = "EXTREMELY FAST"
	}

	new message[512]
	format(message, 511, "CONGRATULATIONS - You have completed the map in %d:%02d^n", floatround(timer[id], floatround_floor) / 60, floatround(timer[id], floatround_floor) % 60)

	if(times_num > 0) {
		format(message, 511, "%sCompared to average, your completion time is %s^n", message, rating)
	}
	format(message, 511, "%s^n", message)

	if(offtillrespawn[id]) {
		points = 0
		if(offtillrespawn[id] == 1) {
			format(message, 511, "%sBecause you used RED skills, you do not get any points!", message)
		} else {
			format(message, 511, "%sBecause you were disqualified, you do not get any points!", message)
		}
	} else {
		points = floatround(time_average)
		format(message, 511, "%sYou got %d points!^n", message, points)
		if(place != 0) {
			new ending[16]
			if(place == 1) {
				format(ending, 15, "st")
			} else if(place == 2) {
				format(ending, 15, "nd")
			} else if(place == 3) {
				format(ending, 15, "rd")
			} else {
				format(ending, 15, "th")
			}
			if(climb_get_numrecords() == 15) {
				points += floatround(time_average/2.0)
				format(message, 511, "%sNEW COURSE RECORD! YOU GOT %d%s PLACE^nAND EARNED %d BONUS POINTS!^n", message, place, ending, floatround(time_average/2.0))
			} else {
				format(message, 511, "%sNEW COURSE RECORD! YOU GOT %d%s PLACE!^n", message, place, ending)
			}
		}
		if(climb_getchecks(id) == 0) {
			points += floatround(time_average*2.0)
			format(message, 511, "%sBECAUSE YOU USED NO CHECKPOINTS, YOU ALSO EARNED %d BONUS POINTS!^n", message, floatround(time_average*2.0))
		}

		new name[64]
		get_user_name(id, name, 63)
		new cpstr[33] = "with checkpoints"
		if(climb_getchecks(id) == 0) {
			format(cpstr, 32, "WITHOUT CHECKPOINTS!")
		}
		alertmessage_v(0,3,"[DARKCLIMB] CONGRATULATIONS TO %s! He or she completed the map in %d:%02d %s", name, floatround(timer[id], floatround_floor) / 60, floatround(timer[id], floatround_floor) % 60, cpstr)
	}

	myhud_large(message, id, 15.0, 3, 0, 200, 0, 2, -1.0, 0.30, 0.7, 0.02, 0.5)

	format(message, 511, "YOU NOW HAVE HOOK!^nFOR HOOK HELP, TYPE /hook IN CHAT")
	myhud_large(message, id, 8.0, 3, 0, 200, 0, 2, -1.0, 0.30, 0.7, 0.02, 0.5)

	climb_setpoints(id, climb_getpoints(id) + points)
	climb_updatepointshud(id)

	return 1
}
