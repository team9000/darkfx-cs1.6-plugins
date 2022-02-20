#include <amxmodx>
#include <sub_stocks>
//#include <sub_maps>
#include <sub_votes>
#include <sub_hud>
#include <sub_time>
#include <sub_timeleft>

new last_time
new start_time
new timeleftoffset

public plugin_init() {
	register_plugin("Subsys - Timeleft","T9k","Team9000")

	register_concmd("say /timeleft","say_timeleft",0,"Displays the timeleft")
	register_concmd("say timeleft","say_timeleft",0,"Displays the timeleft")
	register_concmd("say /thetime","say_thetime",0,"Displays the current time")
	register_concmd("say thetime","say_thetime",0,"Displays the current time")

	register_concmd("amx_changetimeleft","chcvartimeleft",LVL_TIMELEFT,"<minutes> - Changes the timeleft")

	register_cvar("amx_timelimit", "30")
	register_cvar("amx_timeleft","00:00",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	start_time = 0
	last_time = 999999
	timeleftoffset = 0

	set_task(1.0,"init_countdown")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_timeleft")

	register_native("get_thetimeleft","get_thetimeleft_impl")
	register_native("set_thetimeleft","set_thetimeleft_impl")
}

public get_thetimeleft_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	new tmlf = (get_cvar_num("amx_timelimit") * 60) - (time_time() - start_time) + timeleftoffset
	tmlf = max(0, tmlf)
	return tmlf
}

public set_thetimeleft_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new target = get_param(1)

	new gmtm = (get_cvar_num("amx_timelimit") * 60) - (time_time() - start_time)

	timeleftoffset = (target*60) - gmtm

	return 1
}

public say_thetime(id) {
	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, Float:timezone, is_dst)

	new ctime[64]
	format(ctime, 63, "%d/%d/%d - %02d:%02d:%02d", month, day, year, hour, minute, second)

	new name[32]
	get_user_name(id,name,31)
	alertmessage_v(0,3,"(%s) thetime - The Time: %s", name, ctime)

	new whour[32], wminute[32], wpm[6]
	if(minute) {
		num_to_word(minute,wminute,31)
	} else {
		wminute[0] = 0
	}
	if(hour < 12) {
		copy(wpm,5,"am ")
	} else {
		hour -= 12
		copy(wpm,5,"pm ")
	}
	if(hour) {
		num_to_word(hour,whour,31)
	} else {
		copy(whour,31,"twelve ")
	}
	client_cmd(id, "spk ^"fvox/time_is_now %s_period %s%s^"",whour,wminute,wpm)

	return PLUGIN_HANDLED
}

public say_timeleft(id) {
	new tmlf = (get_cvar_num("amx_timelimit") * 60) - (time_time() - start_time) + timeleftoffset
	tmlf = max(0, tmlf)

	new name[32]
	get_user_name(id,name,31)
	alertmessage_v(0,3,"(%s) timeleft - Time Remaining: %d:%02d", name, tmlf / 60, tmlf % 60)

	set_time_voice(id, tmlf, 1)

	return PLUGIN_HANDLED
}


set_time_voice(id, tmlf, remaining = 0) {
	new temp[5][32]
	new secs = tmlf % 60
	new mins = tmlf / 60
	for(new a = 0; a < 5; a++)
		temp[a][0] = 0
	if(mins) {
		num_to_word(mins, temp[0], 31)
		copy(temp[1],31, "minutes ")
	}
	if(secs) {
		num_to_word(secs, temp[2], 31)
		if(tmlf >= 15 || remaining) {
			copy(temp[3],31, "seconds ")
		}
	}
	if(tmlf >= 15 || remaining) {
		copy(temp[4],31,"remaining ")
	}
	client_cmd(id, "spk ^"vox/%s%s%s%s%s^"", temp[0], temp[1], temp[2], temp[3], temp[4])
}

public time_remaining(param[]) {
	new tmlf = (get_cvar_num("amx_timelimit") * 60) - (time_time() - start_time) + timeleftoffset
	tmlf = max(0, tmlf)

	new stimel[12]
	format(stimel, 11, "%d:%02d", tmlf / 60, tmlf % 60)
	set_cvar_string("amx_timeleft", stimel)

	if (((tmlf > 0 && tmlf <= 10) || tmlf == 60 || tmlf == 300 || tmlf == 600) && last_time < tmlf) {
		last_time = 999999
	}

	if (((tmlf > 0 && tmlf <= 10) || tmlf == 60 || tmlf == 300 || tmlf == 600) && last_time > tmlf) {
		last_time = tmlf
		set_time_voice(0, tmlf)
	}

	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, Float:timezone, is_dst)

	new ctime[64]
	format(ctime, 63, "%d:%02d", hour, minute)

	new message[128]
	format(message, 127, "Clock: %s^nTimeleft: %d:%02d^n", ctime, tmlf / 60, tmlf % 60)
	myhud_small(4, 0, message, -1.0)
}

public init_countdown() {
	start_time = time_time()
	set_task(0.3,"time_remaining",0,"",0,"b")
	set_cvar_num("mp_timelimit", 0) // amx_timelimit should be where you set your timelimit!
}

public chcvartimeleft(id,level,cid) {
	if(!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new arg[32], target
	read_argv(1,arg,31)
	target = str_to_num(arg)

	if(target > 30) {
		console_print(id,"Timeleft cannot be set to more than 30 minutes!")
		return PLUGIN_HANDLED
	}
	if(target < 0) {
		console_print(id,"Timeleft cannot be set to less than 0 minutes!")
		return PLUGIN_HANDLED
	}

	set_thetimeleft(target)

	adminalert_v(id, "", "changed the timeleft to %d minutes", target)

	return PLUGIN_HANDLED
}
