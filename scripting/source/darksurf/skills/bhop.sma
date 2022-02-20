#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <darksurf.inc>

#define	FL_WATERJUMP	(1<<11)	// player jumping out of water
#define	FL_ONGROUND	(1<<9)	// At rest / on the ground

public plugin_init() {
	register_plugin("DARKSURF - *Bunnyhop","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Bunnyhop", "bhop", 0, 1)
}

public client_PreThink(id) {
	new skill = surf_getskill(id, "bhop") && surf_getskillon(id, "bhop")
	if(!skill) {
		return PLUGIN_CONTINUE
	}

	entity_set_float(id, EV_FL_fuser2, 0.0)	// Disable slow down after jumping

	if(entity_get_int(id, EV_INT_button) & 2) {	// If holding jump
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
	}
	return PLUGIN_CONTINUE
}
