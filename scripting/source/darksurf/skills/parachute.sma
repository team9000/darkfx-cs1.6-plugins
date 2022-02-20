#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <darksurf.inc>
#include <sub_hud>
#include <sub_damage>
#include <sub_lowresources>

new para_ent[33]
new lowres = 0

public plugin_init() {
	register_plugin("DARKSURF - *Parachute","T9k","Team9000")
}

public surf_register_fw() {
	surf_registerskill("Parachute", "parachute", 0, 1)
}

public plugin_precache() {
	lowres = 0
	if(is_lowresources()) {
		lowres = 1;
		return;
	}
	precache_model("models/team9000/parachute.mdl")
}

public client_connect(id) {
	para_ent[id] = 0
}

public client_disconnect(id) {
	if(para_ent[id] > 0) {
		remove_entity(para_ent[id])
		para_ent[id] = 0
	}
}

public dam_respawn(id) {
	if(para_ent[id] > 0) {
		remove_entity(para_ent[id])
		para_ent[id] = 0
	}
}
public client_PreThink(id) {
	if(lowres) return PLUGIN_CONTINUE;

	new skill = surf_getskill(id, "parachute") && surf_getskillon(id, "parachute")

	if(!skill) {
		if(para_ent[id] > 0) {
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
		return PLUGIN_CONTINUE
	}

	if(!is_user_alive(id)) {
		if(para_ent[id] > 0) {
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
		return PLUGIN_CONTINUE
	}

	if(get_user_button(id) & IN_USE) {
		if(!( get_entity_flags(id) & FL_ONGROUND)) {
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			if(velocity[2] < -100) {
				if(para_ent[id] == 0) {
					para_ent[id] = create_entity("info_target")
					if(para_ent[id] > 0) {
						entity_set_model(para_ent[id], "models/team9000/parachute.mdl")
						entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
						entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					}
				}
				if(para_ent[id] > 0) {
					velocity[2] = (velocity[2] + 20.0 < -100) ? velocity[2] + 20.0 : -100.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
					if(entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0) {
						if(entity_get_int(para_ent[id], EV_INT_sequence) != 1) {
							entity_set_int(para_ent[id], EV_INT_sequence, 1)
						}
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					} else {
						entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0)
					}
				}
			} else {
				if(para_ent[id] > 0) {
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			}
		} else {
			if(para_ent[id] > 0) {
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	} else if(get_user_oldbutton(id) & IN_USE) {
		if(para_ent[id] > 0) {
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}

	return PLUGIN_CONTINUE
}
