#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <darksurf.inc>

#define MAX_JUMPS 3
new jumpnum[33] = 0
new bool:dojump[33] = false

public plugin_init() {
	register_plugin("DARKSURF - *MultiJump","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("MultiJump", "multijump", 100, 1)
}

public client_putinserver(id)
{
	jumpnum[id] = 0
	dojump[id] = false
}

public client_disconnect(id)
{
	jumpnum[id] = 0
	dojump[id] = false
}

public client_PreThink(id) {
	if(!is_user_alive(id)) {
		return PLUGIN_CONTINUE
	}

	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	if(button & IN_JUMP) {
		if(!(get_entity_flags(id) & FL_ONGROUND) && !(oldbutton & IN_JUMP)) {
			new skill = surf_getskill(id, "multijump") && surf_getskillon(id, "multijump")
			if(jumpnum[id] < MAX_JUMPS && skill) {
				dojump[id] = true
				jumpnum[id]++
			}
		} else if(get_entity_flags(id) & FL_ONGROUND) {
			jumpnum[id] = 0
		}
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id) {
	if(is_user_alive(id) && dojump[id] == true) {
		new Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = 250.0
		entity_set_vector(id,EV_VEC_velocity,velocity)
	}
	dojump[id] = false

	return PLUGIN_CONTINUE
}
