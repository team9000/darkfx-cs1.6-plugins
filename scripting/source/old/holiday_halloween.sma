#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <cstrike>
#include <sub_hud>
#include <surf>
#include <sub_time>
#include <sub_handler>

#define NEED_COLORNAMES
#include <sub_const>

new starttime, stoptime, started
new trail

public plugin_init() {
	register_plugin("Holiday - Halloween","MM","doubleM")

	if(time_time() < starttime) {
		started = 0
	} else if(time_time() >= starttime && time_time() < stoptime) {
		started = 1
		set_task(20.0,"dohud")
		set_task(0.5, "docvars")
	} else {
		started = 0
	}

	if(time_time() > starttime - 60*60*24*5 && time_time() < stoptime) {
		set_task(0.3,"countdown",0,"",0,"b")
	}

	return PLUGIN_CONTINUE
}

public docvars() {
	set_cvar_string("sv_skyname", "backalley")
}

public plugin_precache() {
	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, Float:timezone, is_dst)

	hour = 0
	minute = 0
	second = 0
	month = 10
	day = 31
//	year = year
	starttime = time_mktime(hour, minute, second, month, day, year, timezone, -1)

	month = 11
	day = 1
	stoptime = time_mktime(hour, minute, second, month, day, year, timezone, -1)

	if(time_time() > starttime - 60*60*24 && time_time() < stoptime) {
//		server_print("ASFDOUHASDOFUASODUFHOASUDFH")
	}

	trail = precache_model("sprites/smoke.spr") 

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
			format(message, 127, "Halloween Point Bonus STARTS: %d Days %02d:%02d:%02d^n", days, hours, minutes, seconds)
		} else {
			format(message, 127, "Halloween Point Bonus STARTS: %02d:%02d:%02d^n", hours, minutes, seconds)
		}
		myhud_small(5, 0, message, -1.0)
	} else if(time_time() >= starttime && time_time() < stoptime - 60*60) {
		if(!started) {
			started = 1
			dohud()
		}
		new message[128]
		format(message, 127, "Halloween Point Bonus: NOW ACTIVE^n")
		myhud_small(5, 0, message, -1.0)

		dolights()
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
		format(message, 127, "Halloween Point Bonus ENDS: %02d:%02d:%02d^n", hours, minutes, seconds)
		myhud_small(5, 0, message, -1.0)

		dolights()
	} else if(time_time() >= stoptime && time_time() < stoptime + 60*5) {
		started = 0
		new message[128]
		format(message, 127, "Halloween Point Bonus HAS ENDED^n")
		myhud_small(5, 0, message, 10.0)

		lightsoff()
	}
}

public dolights() {
	set_lights("g")

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			new params[6]
			params[0] = kRenderFxGlowShell
			params[1] = 255
			params[2] = 110
			params[3] = 0
			params[4] = kRenderNormal
			params[5] = 15
			handle_rendering(5, targetindex, params)
		new colorid = 0
		for(new i = 0; i < NUM_COLORS; i++) {
			if(equal("orangered", colornames[i])) {
				colorid = i
				break
			}
		}
			handle_trail(0, targetindex, 2, colorid)
		}
	}
}

public lightsoff() {
	set_lights("#OFF")

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			handle_rendering_off(5, targetindex)
		}
	}
}

public grenade_throw(index, greindex, wId) {
	if(time_time() >= stoptime && time_time() < stoptime) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(22) 
		write_short(greindex)
		write_short(trail)
		write_byte(10)
		write_byte(5)
		write_byte(255)
		write_byte(119)
		write_byte(0)
		write_byte(200)
		message_end()

		set_rendering(greindex, kRenderFxGlowShell, 255, 119, 0, kRenderNormal, 225);
	}

	return PLUGIN_CONTINUE
}

public dohud() {
	if(started) {
		new color[3]
		color[0] = 220
		color[1] = 110
		color[2] = 0

		myhud_large("Happy Halloween from Team9000!", 0, 10.0, 3, color[0], color[1], color[2], 2, -1.0, 0.30, 0.7, 0.03, 0.5)
		set_task(60.0*3, "dohud")

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				if(cs_get_user_team(targetindex) != CS_TEAM_T && cs_get_user_team(targetindex) != CS_TEAM_CT) {
					continue
				}

				alertmessage_v(targetindex,3,"[DFX-MOD]Happy Halloween - Gained 40 Points")
				surf_setpoints(targetindex, surf_getpoints(targetindex) + 40)

				surf_updatepointshud(targetindex)
			}
		}
	}
}
