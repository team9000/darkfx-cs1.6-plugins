#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_damage>
#include <sub_hud>
#include <sub_storage>

new quickkill[33]
new quickkilltime[33]

new killsincedeath[33]

new combo[33]
new streak[33]

public plugin_init() {
	register_plugin("Effect - Event Sounds","T9k","Team9000")

	set_task(2.0,"update_hud",0,"",0,"b")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	combo[id] = 0
	streak[id] = 0
}

public storage_register_fw() {
	storage_reg_playerfield("combo")
	storage_reg_playerfield("streak")
}

public storage_presaveplayer_fw(id) {
	new value[32]

	if(id > 0) {
		new result = get_playervalue(id, "combo", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			if(combo[id] > valuei) {
				format(value, 31, "%d", combo[id])
				set_playervalue(id, "combo", value)
			}
			combo[id] = 0
		}

		result = get_playervalue(id, "streak", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			if(streak[id] > valuei) {
				format(value, 31, "%d", streak[id])
				set_playervalue(id, "streak", value)
			}
			streak[id] = 0
		}
	}
}

public plugin_precache() {
	precache_generic("sound/team9000/event/humiliation.mp3")
	precache_generic("sound/team9000/event/perfect.mp3")

	precache_generic("sound/team9000/event/doublekill.mp3")
	precache_generic("sound/team9000/event/multikill.mp3")
	precache_generic("sound/team9000/event/megakill.mp3")
	precache_generic("sound/team9000/event/ultrakill.mp3")
	precache_generic("sound/team9000/event/ludacrouskill.mp3")
	precache_generic("sound/team9000/event/monsterkill.mp3")

	precache_generic("sound/team9000/event/killingspree.mp3")
	precache_generic("sound/team9000/event/unstoppable.mp3")
	precache_generic("sound/team9000/event/rampage.mp3")
	precache_generic("sound/team9000/event/holyshit.mp3")
	precache_generic("sound/team9000/event/godlike.mp3")
}

public play_sound(sound[]) {
	new cmd[129]
	format(cmd, 128, "mp3 play sound/team9000/%s.mp3", sound)

	client_cmd(0, cmd)
}

public client_disconnect(id) {
	killsincedeath[id] = 0
	quickkill[id] = 0
}

public dam_death(victim, attacker, weapon[], headshot) {
	killsincedeath[victim] = 0
	quickkill[victim] = 0

	if(attacker == victim || attacker == 0) {
		return
	}

	if(quickkilltime[attacker] < time_time() - 7) {
		quickkill[attacker] = 0
	}
	quickkilltime[attacker] = time_time()
	quickkill[attacker]++
	killsincedeath[attacker]++

	new handled = 0

	if(quickkill[attacker] == 2) {
		play_sound("event/doublekill")
		handled = 1
	} else if(quickkill[attacker] == 3) {
		play_sound("event/multikill")
		handled = 1
	} else if(quickkill[attacker] == 4) {
		play_sound("event/megakill")
		handled = 1
	} else if(quickkill[attacker] == 5) {
		play_sound("event/ultrakill")
		handled = 1
	} else if(quickkill[attacker] == 6) {
		play_sound("event/ludacrouskill")
		handled = 1
	} else if(quickkill[attacker] == 7) {
		play_sound("event/monsterkill")
		handled = 1
	}

	if(!handled) {
		if(killsincedeath[attacker] == 3) {
			play_sound("event/killingspree")
		} else if(killsincedeath[attacker] == 4) {
			play_sound("event/unstoppable")
		} else if(killsincedeath[attacker] == 6) {
			play_sound("event/rampage")
		} else if(killsincedeath[attacker] == 8) {
			play_sound("event/holyshit")
		} else if(killsincedeath[attacker] == 10) {
			play_sound("event/godlike")
		} else if(containi(weapon, "kni") != -1) {
			play_sound("event/humiliation")
		} else if(containi(weapon, "gren") != -1) {
			play_sound("event/perfect")
		}
	}

	if(quickkill[attacker] > combo[attacker]) {
		combo[attacker] = quickkill[attacker]
	}
	if(killsincedeath[attacker] > streak[attacker]) {
		streak[attacker] = killsincedeath[attacker]
	}

	update_hud()
}

public update_hud() {
	new message[512]
	format(message, 511, "")

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(quickkill[targetindex] >= 2 || killsincedeath[targetindex] >= 3) {
				new name[33]
				get_user_name(targetindex, name, 32)

				if(quickkilltime[targetindex] < time_time() - 7) {
					quickkill[targetindex] = 0
				}

				if(killsincedeath[targetindex] >= 10) {
					format(message, 511, "%s%s: %s (%d Kills)^n", message, name, "GODLIKE!", killsincedeath[targetindex])
				} else if(killsincedeath[targetindex] >= 8) {
					format(message, 511, "%s%s: %s (%d Kills)^n", message, name, "Holy Shit!", killsincedeath[targetindex])
				} else if(killsincedeath[targetindex] >= 6) {
					format(message, 511, "%s%s: %s (%d Kills)^n", message, name, "Rampage", killsincedeath[targetindex])
				} else if(killsincedeath[targetindex] >= 4) {
					format(message, 511, "%s%s: %s (%d Kills)^n", message, name, "Unstoppable", killsincedeath[targetindex])
				} else if(killsincedeath[targetindex] >= 3) {
					format(message, 511, "%s%s: %s (%d Kills)^n", message, name, "Killing Spree", killsincedeath[targetindex])
				}

				if(quickkill[targetindex] >= 7) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "MONSTER KILL!", quickkill[targetindex])
				} else if(quickkill[targetindex] >= 6) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "Ludacrous Kill!", quickkill[targetindex])
				} else if(quickkill[targetindex] >= 5) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "Ultra Kill!", quickkill[targetindex])
				} else if(quickkill[targetindex] >= 4) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "Mega Kill", quickkill[targetindex])
				} else if(quickkill[targetindex] >= 3) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "Multi Kill", quickkill[targetindex])
				} else if(quickkill[targetindex] >= 2) {
					format(message, 511, "%s%s: %s (%d Combo)^n", message, name, "Double Kill", quickkill[targetindex])
				}
			}
		}
	}
	if(!equal(message, "")) {
		format(message, 511, "%s^n", message)
	}

	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
//			if(options_get_combotext(targetindex)) {
//				myhud_small(8, targetindex, message, -1.0)
//			} else {
				myhud_small(8, targetindex, "", -1.0)
//			}
		}
	}
}
