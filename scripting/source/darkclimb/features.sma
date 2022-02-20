#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <darkclimb.inc>
#include <settings>
#include <sub_damage>
#include <sub_weapons>
#include <sub_respawn>
#include <effect_semiclip>

new nvgon[33]

public plugin_init() {
	register_plugin("DARKCLIMB - FEATURES","T9k","Team9000")

	register_clcmd("nightvision","nightvision")

	set_task(2.0, "update")
	set_task(60.0,"update",0,"",0,"b")
	set_task(10.0,"update_freq",0,"",0,"b")
}

public plugin_natives() {
	register_library("darkclimb_features")
}

public plugin_precache() {
	precache_sound("items/nvg_on.wav") 
	precache_sound("items/nvg_off.wav")
}

public client_connect(id) {
	nvgon[id] = 0
}

public update() {
	respawn_auto(0, 0, 1)

	new reload[32] = {0,...}
	reload[CSW_KNIFE] = 1
	if(climb_getfeature(2)) {
		reload[CSW_SCOUT] = 10
		weap_reload(2, 0, reload, CSW_SCOUT)
	} else {
		weap_reload(2, 0, reload, CSW_KNIFE)
	}
	weap_removedrop(2, 1)
}

public update_freq() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(climb_getfeature(0)) {
				dam_set_autoheal(targetindex, 1)
			}
			if(climb_getfeature(1)) {
				set_user_godmode(targetindex, 1)
			}
		}
	}
}

public client_putinserver(id) {
	if(climb_getfeature(0)) {
		dam_set_autoheal(id, 1)
	}
	if(climb_getfeature(5)) {
		climb_setskillon(id, "bhop", 1)
	}
	set_semiclip(climb_getfeature(6))
}

public dam_respawn_postmove(id) {
	if(climb_getfeature(1)) {
		set_user_godmode(id, 1)
	}
}

public donvg(id, sound) {
	if(is_user_connected(id) && !is_user_connecting(id)) {
		if((get_user_team(id) == 1 || get_user_team(id) == 2) && is_user_alive(id)) {
			if(nvgon[id]) {
				message_begin(MSG_ONE, get_user_msgid("NVGToggle"), {0,0,0}, id) 
				write_byte(1) 
				message_end()
				if(sound) {
					emit_sound(id, CHAN_ITEM, "items/nvg_on.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			} else {
				message_begin(MSG_ONE, get_user_msgid("NVGToggle"), {0,0,0}, id) 
				write_byte(0) 
				message_end()
				if(sound) {
					emit_sound(id, CHAN_ITEM, "items/nvg_off.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
	}
}

public nightvision(id) {
	if(nvgon[id]) {
		nvgon[id] = 0
		donvg(id, 1)
	} else if(climb_getfeature(3)) {
		nvgon[id] = 1
		donvg(id, 1)
	}
}
