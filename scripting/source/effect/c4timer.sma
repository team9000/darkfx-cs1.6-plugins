#include <amxmodx>
#include <sub_stocks>
#include <sub_roundtime>

new plant_time = 0
new last_time = 0

public plugin_init() {
	register_plugin("Effect - C4 Timer","T9k","Team9000")

	register_logevent("player_event",3, "1=triggered")

	plant_time = 0
	last_time = 999999
}

public round_freezestart() {
	plant_time = 0
	last_time = 999999
}

public player_event() {
	new sAction[256]

	read_logargv(2, sAction, 255)
	if(equal(sAction, "Planted_The_Bomb")) {
		set_task(0.2,"time_remaining",1,"",0,"b")
		plant_time = time_time()-1
		last_time = 999999
	} else if(equal(sAction, "Defused_The_Bomb")) {
		remove_task(1)
		plant_time = 0
		last_time = 999999
	}
}

public time_remaining(param[]) {
	if(plant_time) {
		new tmlf = get_cvar_num("mp_c4timer") - (time_time() - plant_time)

		if(tmlf < last_time) {
			if((tmlf > 0 && tmlf <= 10) || tmlf == 15 || tmlf == 20) {
				last_time = tmlf
				set_time_voice(0, tmlf, 0)
			}
			if(tmlf < -1) {
				remove_task(1)
			}
		}
	}
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
		if(remaining) {
			copy(temp[3],31, "seconds ")
		}
	}
	if(tmlf >= 15 || remaining) {
		copy(temp[4],31,"remaining ")
	}
	client_cmd(id, "spk ^"vox/%s%s%s%s%s^"", temp[0], temp[1], temp[2], temp[3], temp[4])
}
