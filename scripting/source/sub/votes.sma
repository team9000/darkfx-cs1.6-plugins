#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_votes>
#include <sub_hud>

new votetitle[128]
new optionname[10][512]
new optionname_hud[10][512]
new showresults
new votes[10] = {0, ...}
new options = 0
new bool:votemode = false
new bool:voted[33] = {false, ...}
new callerid = 0
new callercallback[128] = ""
new callercallbackvote[128] = ""
new starttime = 0
new votedur = 0

public plugin_init() {
	register_plugin("Subsys - Votes","T9k","Team9000")

	register_menucmd(register_menuid("\rDarkMod Vote"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"vote_count")

	return PLUGIN_CONTINUE
}

public plugin_precache() {
	precache_generic("sound/team9000/vote.mp3")
}

public play_sound(sound[]) {
	new cmd[129]
	format(cmd, 128, "mp3 play sound/team9000/%s.mp3", sound)

	client_cmd(0, cmd)
}

public plugin_natives() {
	register_library("sub_votes")

	register_native("vote_new","mymenu_new_impl")
	register_native("vote_addoption","mymenu_addoption_impl")
	register_native("vote_addoption_hud","mymenu_addoption_hud_impl")
	register_native("vote_getresults","mymenu_getresults_impl")
	register_native("vote_setvotecallback","vote_setvotecallback_impl")
}

public check_vote() { 
	if(votemode) {
		for(new i = 0; i < 33; i++) {
			if(!voted[i]) {
				set_menuopen(i, 0)
			}
		}

		callfunc_begin_i(get_func_id(callercallback, callerid), callerid)
		callfunc_push_array(votes, 10)

		new ordered[10] = {-1, ...}
		new best = -1
		for(new i = 0; i < options; i++) {
			best = -1
			for(new j = 0; j < options; j++) {
				if(best == -1 || votes[j] > votes[best]) {
					best = j
				}
			}
			ordered[i] = best
			votes[best] = -1
		}

		callfunc_push_array(ordered, 10)
		callfunc_end()

		votemode = false

		if(showresults != 0) {
			play_sound("vote")
		}
	}
} 

public mymenu_getresults_impl(id, numparams) {
	set_string(1, votes, 10)
	return options
}

public client_connect(id) {
	voted[id] = true
}

public client_putinserver(id) {
	voted[id] = true
}

public mymenu_new_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")
	if(votemode)
		return -1

	callerid = id
	get_string(1, callercallback, 127)
	callercallbackvote = "";

	get_string(3, votetitle, 127)

	options = 0

	for(new i = 0; i < 33; i++) {
//		if(options_get_dovotes(i)) {
			voted[i] = false
//		} else {
//			voted[i] = true
//		}
	}

	votemode = true

	votedur = get_param(2)
	showresults = get_param(4)
	set_task(0.5,"update_menu",9999,"",0,"b")
	starttime = time_time()

	play_sound("vote")

	return 1
}

public vote_setvotecallback_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	get_string(1, callercallbackvote, 127)

	return 1
}

public mymenu_addoption_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	if(!votemode)
		return -1
	if(options >= 10)
		return -1

	get_string(1, optionname[options], 511)
	copy(optionname_hud[options], 511, optionname[options])
	votes[options] = 0
	options++

	return 1
}

public mymenu_addoption_hud_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")
	if(!votemode)
		return -1
	if(options >= 10)
		return -1

	get_string(1, optionname[options], 511)
	get_string(2, optionname_hud[options], 511)
	votes[options] = 0
	options++

	return 1
}

public update_menu() {
	new message[2048] = ""
	new votetime = votedur - (time_time() - starttime)
	if(votetime < 0)
		votetime = 0

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(votetime > 0) {
				if(voted[targetindex]) {
					if(showresults == 1 || showresults == 2) {
						format(message, 2047, "VOTING RESULTS^n%s^n", votetitle)

						for(new i = 0; i < options; i++) {
							format(message, 2047, "%s%d <= %s^n", message, votes[i], optionname_hud[i])
						}
						format(message, 2047, "%sVOTE TIME REMAINING: %d^n^n", message, votetime)

						myhud_small(3, targetindex, message, 3.0)
					}
				} else {
					format(message, 2047, "\rDarkMod Vote^n\y%s^n", votetitle)

					new keys
					for(new i = 0; i < options; i++) {
						if(showresults == 2) {
							format(message, 2047, "%s\w%d. %s (\r%d\w votes)^n", message, i+1, optionname[i], votes[i])
						} else {
							format(message, 2047, "%s\w%d. %s^n", message, i+1, optionname[i])
						}
						keys |= (1<<i)
					}
					if(votetime > 10 || votetime % 2 == 0) {
						format(message, 2047, "%s^n\rVOTING TIME REMAINING: \w%d", message, votetime)
					} else {
						format(message, 2047, "%s^n\rVOTING TIME REMAINING: \r%d", message, votetime)
					}

					show_menu(targetindex, keys, message, 1)
					set_menuopen(targetindex, 1)
				}
			} else {
				myhud_small(3, targetindex, "", 0.0)
			}
		}
	}

	if(votetime <= 0) {
		remove_task(9999)
		check_vote()
	}
}

public vote_count(id, key) {
	if(!voted[id]) {
		votes[key]++
	}
	voted[id] = true

	if(!equal(callercallbackvote, "")) {
		callfunc_begin_i(get_func_id(callercallbackvote, callerid), callerid)
		callfunc_push_int(id)
		callfunc_push_int(key)
		callfunc_end()
	}

	set_menuopen(id, 0)
	show_menu(id, 0, " ", 1)
	update_menu()

	return PLUGIN_HANDLED 
}
