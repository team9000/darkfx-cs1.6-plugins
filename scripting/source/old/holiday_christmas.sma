#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_hud>
#include <surf>
#include <sub_time>
#include <sub_handler>

new starttime, stoptime, started

public plugin_init() {
	register_plugin("Holiday - Christmas","MM","doubleM")

	if(time_time() < starttime) {
		started = 0
	} else if(time_time() >= starttime && time_time() < stoptime) {
		started = 1
		set_task(20.0,"dohud")
	} else {
		started = 0
	}

	if(time_time() > starttime - 60*60*24*5 && time_time() < stoptime) {
		set_task(0.3,"countdown",0,"",0,"b")
	}

	return PLUGIN_CONTINUE
}

public plugin_precache() {
	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, Float:timezone, is_dst)

	hour = 0
	minute = 0
	second = 0
	month = 12
	day = 25
//	year = year
	starttime = time_mktime(hour, minute, second, month, day, year, timezone, -1)

	day = 26
	stoptime = time_mktime(hour, minute, second, month, day, year, timezone, -1)

	if(time_time() > starttime - 60*60*24 && time_time() < stoptime) {
//		server_print("ASFDOUHASDOFUASODUFHOASUDFH")
		precache_model("models/player/xmasct/xmasct.mdl")
		precache_model("models/player/xmast/xmast.mdl")
	}

	return PLUGIN_CONTINUE
}

public countdown() {
	if(time_time() < starttime) {
		started = 0
		new timeleft = starttime - time_time()
		new days = timeleft / (60*60*24)
		timeleft -= days * (60*60*24)
		new hours = timeleft / (60*60)
		timeleft -= hours * (60*60)
		new minutes = timeleft / (60)
		timeleft -= minutes * (60)
		new seconds = timeleft

		new message[128]
		if(days > 0) {
			format(message, 127, "Christmas Point Bonus STARTS: %d Days %02d:%02d:%02d^n", days, hours, minutes, seconds)
		} else {
			format(message, 127, "Christmas Point Bonus STARTS: %02d:%02d:%02d^n", hours, minutes, seconds)
		}
		myhud_small(5, 0, message, -1.0)
	} else if(time_time() >= starttime && time_time() < stoptime - 60*60) {
		if(!started) {
			started = 1
			dohud()
		}
		new message[128]
		format(message, 127, "Christmas Point Bonus: NOW ACTIVE^n")
		myhud_small(5, 0, message, -1.0)

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				modelnow(targetindex)
			}
		}
	} else if(time_time() >= stoptime - 60*60 && time_time() < stoptime) {
		if(!started) {
			started = 1
			dohud()
		}
		new timeleft = stoptime - time_time()
		new hours = timeleft / (60*60)
		timeleft -= hours * (60*60)
		new minutes = timeleft / (60)
		timeleft -= minutes * (60)
		new seconds = timeleft

		new message[128]
		format(message, 127, "Christmas Point Bonus ENDS: %02d:%02d:%02d^n", hours, minutes, seconds)
		myhud_small(5, 0, message, -1.0)

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				modelnow(targetindex)
			}
		}
	} else if(time_time() >= stoptime && time_time() < stoptime + 60*5) {
		started = 0
		new message[128]
		format(message, 127, "Christmas Point Bonus HAS ENDED^n")
		myhud_small(5, 0, message, 10.0)

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				model_off(targetindex)
			}
		}
	}
}

public modelnow(id) {
	if(cs_get_user_team(id) == CS_TEAM_T) {
		handle_model(1, id, "xmast")
	} else {
		handle_model(1, id, "xmasct")
	}
}

public model_off(id) {
	handle_model_off(1, id)
}

public dohud() {
	if(started) {
		new color[3]
		new randnum = random_num(0,1)
		if(randnum == 0) {
			color[0] = 220
			color[1] = 0
			color[2] = 0
		} else if(randnum == 1) {
			color[0] = 0
			color[1] = 220
			color[2] = 0
		}

		myhud_large("Merry Christmas from Team9000!", 0, 10.0, 3, color[0], color[1], color[2], 2, -1.0, 0.30, 0.7, 0.03, 0.5)
		set_task(60.0*3, "dohud")

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				if(cs_get_user_team(targetindex) != CS_TEAM_T && cs_get_user_team(targetindex) != CS_TEAM_CT) {
					continue
				}

				alertmessage_v(targetindex,3,"[DFX-MOD]Merry Christmas - Gained 100 Points")
				surf_setpoints(targetindex, surf_getpoints(targetindex) + 100)

				surf_updatepointshud(targetindex)
			}
		}
	}
}
