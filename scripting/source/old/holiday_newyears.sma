#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <cstrike>
#include <fun>
#include <sub_hud>
#include <sub_time>
#include <sub_storage>
#include <surf>

new targettime, trigger1, trigger2, trigger3, trigger4, triggerxp, lasttime, thismap, saychange

public plugin_init() {
	register_plugin("Holiday - New Years","MM","doubleM")

	thismap = 0
	trigger1 = 0
	trigger2 = 0
	trigger3 = 0
	trigger4 = 0
	triggerxp = 0
	lasttime = 9999999
	saychange = 0

	new currentmap[32]
	get_mapname(currentmap, 31)

	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, Float:timezone, is_dst)

	hour = 0
	minute = 0
	second = 0
	month = 1
	day = 1
	year = year+1

	targettime = time_mktime(hour, minute, second, month, day, year, timezone, -1)

	new now = time_time()
	new timeleft = targettime - now;

	if(timeleft > 0 && timeleft < 60*60*24*5+60*60*12) {
		set_task(0.1,"countdown",0,"",0,"b")
		set_task(120.0,"motd",0,"",0,"b")
	}

	if(equal(currentmap, "dfx_newyears_v2")) {
		if(timeleft < 0) {
			trigger1 = 1
			trigger2 = 1
			trigger3 = 1
			trigger4 = 1
			triggerxp = 1
		}

		thismap = 1
		set_task(5.0,"set_cvars")
		set_task(10.0,"allgodmode",0,"",0,"b")
	}

	return PLUGIN_CONTINUE
}

public plugin_precache() {
	new currentmap[32]
	get_mapname(currentmap, 31)

	if(equal(currentmap, "dfx_newyears_v2")) {
		precache_generic("sound/misc/auldlangsyne.mp3")
	}
}

public set_cvars() {
	set_cvar_num("mp_limitteams", 0)
	set_cvar_num("mp_autoteambalance", 0)
	set_cvar_num("sv_restartround", 1)

	pause("ac","holiday_christmas.amxx")
	pause("ac","surf-s-bhop.amxx")
	pause("ac","surf-s-camera.amxx")
	pause("ac","surf-s-disco.amxx")
	pause("ac","surf-s-godmodeblanks.amxx")
	pause("ac","surf-s-hook.amxx")
	pause("ac","surf-s-invisibility.amxx")
	pause("ac","surf-s-lowgrav.amxx")
	pause("ac","surf-s-maxhp.amxx")
	pause("ac","surf-s-multijump.amxx")
	pause("ac","surf-s-parachute.amxx")
	pause("ac","surf-s-radio.amxx")
	pause("ac","surf-s-speed.amxx")
//	pause("ac","surf-admin.amxx")
	pause("ac","surf-bots.amxx")
	pause("ac","surf-finish.amxx")
//	pause("ac","surf-globals.amxx")
//	pause("ac","surf-points.amxx")
	pause("ac","surf-records.amxx")
//	pause("ac","surf-respawn.amxx")
//	pause("ac","surf-semiclip.amxx")
	pause("ac","surf-setup.amxx")
	pause("ac","surf-shop.amxx")
	pause("ac","surf-skills.amxx")
//	pause("ac","surf-storage-vault.amxx")
	pause("ac","surf-surfing.amxx")
	pause("ac","surf-weapons.amxx")
	pause("ac","effect_c4timer.amxx")
	pause("ac","effect_deathbeams.amxx")
	pause("ac","effect_gore.amxx")
	pause("ac","effect_maprating.amxx")
	pause("ac","effect_motd.amxx")
	pause("ac","effect_nadetrails.amxx")
	pause("ac","effect_removevip.amxx")
	pause("ac","effect_tracers.amxx")
	pause("ac","admin_reservation.amxx")
}

public client_putinserver(id) {
	if(thismap) {
		set_task(1.0, "checkclient", id)
	}
}

public checkclient(id) {
	if(is_user_connected(id) && !is_user_connecting(id)) {
		set_user_godmode(id, 1)
	}
	if(!(get_user_flags(id) & LEVEL_9)) {
		remove_user_flags(id, read_flags("abcdefghijklmnopqrstuvwxyz"))
	}

	new now = time_time()
	new timeleft = targettime - now;
	if(timeleft < 0) {
		client_cmd(id,"mp3 play sound/misc/AuldLangSyne")
	}
}

public allgodmode() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			set_user_godmode(targetindex, 1)
		}
	}
}

set_time_voice(id, timeleft) {
	new temp[10][32]

	new temptimeleft = timeleft
	new days = timeleft / (60*60*24)
	timeleft -= days * (60*60*24)
	new hours = timeleft / (60*60)
	timeleft -= hours * (60*60)
	new minutes = timeleft / (60)
	timeleft -= minutes * (60)
	new seconds = timeleft
	timeleft = temptimeleft

	for(new a = 0; a < 10; a++)
		temp[a][0] = 0
	if(days) {
		num_to_word(days, temp[0], 31)
		copy(temp[1],31, "day ")
	}
	if(hours) {
		num_to_word(hours, temp[2], 31)
		if(hours == 1) {
			copy(temp[3],31, "hour ")
		} else {
			copy(temp[3],31, "hours ")
		}
	}
	if(minutes) {
		num_to_word(minutes, temp[4], 31)
		copy(temp[5],31, "minutes ")
	}
	if(seconds) {
		num_to_word(seconds, temp[6], 31)
		if(timeleft >= 15) {
			copy(temp[7],31, "seconds ")
		}
	}
	if(timeleft >= 15) {
		copy(temp[8],31,"remaining ")
	}
	if(timeleft >= 60) {
		copy(temp[9],31,"until termination of year ")
	}
	client_cmd(id, "spk ^"vox/%s%s%s%s%s%s%s%s%s%s^"", temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9])
}

public motd() {
	new currentmap[32]
	get_mapname(currentmap, 31)

	new now = time_time()
	new timeleft = targettime - now;

	if(!equal(currentmap, "dfx_newyears_v2") && timeleft > 0 && timeleft < 60*60*24*5+60*60*12) {
		new days = timeleft / (60*60*24)
		timeleft -= days * (60*60*24)
		new hours = timeleft / (60*60)
		timeleft -= hours * (60*60)
		new minutes = timeleft / (60)
		timeleft -= minutes * (60)
		new seconds = timeleft

		new message[512]
		if(days > 0) {
			format(message, 127, "BE HERE FOR THE NEWYEARS COUNTDOWN^nAND RECEIVE 8,000 POINTS AT MIDNIGHT!^n%d Days %02d:%02d:%02d Remaining", days, hours, minutes, seconds)
		} else {
			format(message, 127, "BE HERE FOR THE NEWYEARS COUNTDOWN^nAND RECEIVE 8,000 POINTS AT MIDNIGHT!^n%02d:%02d:%02d Remaining", hours, minutes, seconds)
		}

		myhud_large(message, 0, 8.0, 3, 255, 255, 255, 2, -1.0, 0.35, 0.7, 0.03, 0.5)
	}
}

public countdown() {
	new now = time_time()
	new timeleft = targettime - now;

	if(thismap) {
		if(timeleft <= 60*5 && !trigger1) {
			trigger1 = 1
			pushit("thetrigger2")
		}
		if(timeleft <= 20 && !trigger2) {
			trigger2 = 1
			pushit("thetrigger3")
		}
		if(timeleft <= 16 && !trigger3) {
			trigger3 = 1
			pushit("thetrigger4")
		}
		if(timeleft <= 0 && !triggerxp) {
			myhud_large("HAPPY NEW YEARS FROM Team9000!!!^nGAINED 8,000 POINTS!!!", 0, 20.0, 3, 255, 255, 255, 2, -1.0, 0.35, 0.7, 0.03, 0.5)
			triggerxp = 1

			new targetindex, targetname[33]
			if(cmd_targetset(-1, "*", 0, targetname, 32)) {
				while((targetindex = cmd_target())) {
					if(cs_get_user_team(targetindex) != CS_TEAM_T && cs_get_user_team(targetindex) != CS_TEAM_CT) {
						continue
					}

					alertmessage_v(targetindex,3,"[DFX-MOD]HAPPY NEW YEARS!!!!! - Gained 8,000 Points")
					surf_setpoints(targetindex, surf_getpoints(targetindex) + 8000)

					surf_updatepointshud(targetindex)
				}
			}

			client_cmd(0,"mp3 play sound/misc/auldlangsyne")
		}
		if(timeleft <= -15 && !trigger4) {
			trigger4 = 1
			pushit("thetrigger1")
		}
	}

	if((timeleft > 0 && timeleft <= 10) ||
		timeleft == 20 ||
		timeleft == 30 ||
		timeleft == 40 ||
		timeleft == 50 ||
		timeleft == 60 ||
		timeleft == 60*1.5 ||
		timeleft == 60*2 ||
		timeleft == 60*2.5 ||
		timeleft == 60*3 ||
		timeleft == 60*3.5 ||
		timeleft == 60*4 ||
		timeleft == 60*4.5 ||
		timeleft == 60*5 ||
		timeleft == 60*5.5 ||
		timeleft == 60*6 ||
		timeleft == 60*6.5 ||
		timeleft == 60*7 ||
		timeleft == 60*7.5 ||
		timeleft == 60*8 ||
		timeleft == 60*8.5 ||
		timeleft == 60*9 ||
		timeleft == 60*9.5 ||
		timeleft == 60*10 ||
		timeleft == 60*11 ||
		timeleft == 60*12 ||
		timeleft == 60*13 ||
		timeleft == 60*14 ||
		timeleft == 60*15 ||
		timeleft == 60*20 ||
		timeleft == 60*25 ||
		timeleft == 60*30 ||
		timeleft == 60*40 ||
		timeleft == 60*50 ||
		timeleft == 60*60 ||
		timeleft == 60*60*1.25 ||
		timeleft == 60*60*1.5 ||
		timeleft == 60*60*1.75 ||
		timeleft == 60*60*2 ||
		timeleft == 60*60*2.25 ||
		timeleft == 60*60*2.5 ||
		timeleft == 60*60*2.75 ||
		timeleft == 60*60*3 ||
		timeleft == 60*60*3.25 ||
		timeleft == 60*60*3.5 ||
		timeleft == 60*60*3.75 ||
		timeleft == 60*60*4 ||
		timeleft == 60*60*4.25 ||
		timeleft == 60*60*4.5 ||
		timeleft == 60*60*4.75 ||
		timeleft == 60*60*5 ||
		timeleft == 60*60*5.5 ||
		timeleft == 60*60*6 ||
		timeleft == 60*60*6.5 ||
		timeleft == 60*60*7 ||
		timeleft == 60*60*7.5 ||
		timeleft == 60*60*8 ||
		timeleft == 60*60*8.5 ||
		timeleft == 60*60*9 ||
		timeleft == 60*60*9.5 ||
		timeleft == 60*60*10 ||
		timeleft == 60*60*10.5 ||
		timeleft == 60*60*11 ||
		timeleft == 60*60*11.5 ||
		timeleft == 60*60*12) {
			if(lasttime < timeleft) {
				lasttime = 999999
			} else if(lasttime > timeleft) {
				lasttime = timeleft
				set_time_voice(0, timeleft)
			}
	}

	if(timeleft <= 60*10 && timeleft >= 0 && !thismap && !saychange) {
		saychange = 1
		alertmessage(0,3,"CHANGING TO NEW YEARS MAP!!!")
		alertmessage(0,3,"CHANGING TO NEW YEARS MAP!!!")
		alertmessage(0,3,"CHANGING TO NEW YEARS MAP!!!")
	}
	if(timeleft <= (60*10)-2 && timeleft >= 0 && !thismap) {
		set_task(4.8,"delayed_showscores")
		set_task(5.0,"delayed_changemap")
	}

	if(timeleft <= 0)
		timeleft = 0

	new days = timeleft / (60*60*24)
	timeleft -= days * (60*60*24)
	new hours = timeleft / (60*60)
	timeleft -= hours * (60*60)
	new minutes = timeleft / (60)
	timeleft -= minutes * (60)
	new seconds = timeleft

	new message[128]
	if(days > 0) {
		format(message, 127, "New Years: %d Days %02d:%02d:%02d^n", days, hours, minutes, seconds)
	} else {
		format(message, 127, "New Years: %02d:%02d:%02d^n", hours, minutes, seconds)
	}
	myhud_small(5, 0, message, -1.0)
}

public delayed_changemap(mapname[]) {
	server_cmd("changelevel dfx_newyears_v2")
}

public delayed_showscores() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex,"+showscores")
		}
	}
}

public pushit(matchname[]) {
	new button = find_ent_by_class(-1, "func_button")
	new buttonname[32]

	while(button > 0) {
		entity_get_string(button, EV_SZ_targetname, buttonname, 31)
		if(equal(buttonname, matchname)) {
			new targetindex, targetname[33]
			if(cmd_targetset(-1, "*", 4, targetname, 32)) {
				while((targetindex = cmd_target())) {
					force_use(targetindex, button)
					break
				}
			}
			break
		}
		button = find_ent_by_class(button, "func_button")
	}
}
