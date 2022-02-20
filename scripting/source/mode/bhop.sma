#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_modes>

#define	FL_WATERJUMP	(1<<11)	// player jumping out of water
#define	FL_ONGROUND	(1<<9)	// At rest / on the ground

new bhopmode

public plugin_init() {
   	register_plugin("Mode - Bunny Hop","T9k","Team9000")

	bhopmode = 0

	return PLUGIN_CONTINUE
}

public mode_init() {
	register_mode("bhop", "bhopmode", "Bunny Hop Mode", 1, LVL_BHOPMODE)
}

public mode_activate() {
	bhopmode = 1
}

public mode_deactivate_e() {
	bhopmode = 0
}

public client_PreThink(id) {
	if(!bhopmode)
		return PLUGIN_CONTINUE

	entity_set_float(id, EV_FL_fuser2, 0.0)	// Disable slow down after jumping

//	if(entity_get_int(id, EV_INT_button) & 2) {	// If holding jump
		new flags = entity_get_int(id, EV_INT_flags)

		if(flags & FL_WATERJUMP)
			return PLUGIN_CONTINUE
		if(entity_get_int(id, EV_INT_waterlevel) >= 2)
			return PLUGIN_CONTINUE
		if (!(flags & FL_ONGROUND))
			return PLUGIN_CONTINUE

		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		velocity[2] += 250.0
		entity_set_vector(id, EV_VEC_velocity, velocity)

		entity_set_int(id, EV_INT_gaitsequence, 6)	// Play the Jump Animation
//	}
	return PLUGIN_CONTINUE
}
