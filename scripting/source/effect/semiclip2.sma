#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_damage>
#include <effect_semiclip>

new onoff

public plugin_init() {
	register_plugin("Effect - Semiclip","T9k","Team9000")
	onoff = 1
}

public plugin_natives() {
	register_library("effect_semiclip")
	register_native("set_semiclip", "set_semiclip_impl")
}

public set_semiclip_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
	onoff = get_param(1)

	return 1
}

public client_PreThink(id) {
	if(is_user_connected(id) && !is_user_connecting(id)) {
		if((get_user_team(id) == 1 || get_user_team(id) == 2) && is_user_alive(id)) {
			if(!onoff) {
				entity_set_int(id, EV_INT_solid, SOLID_BBOX)
				return
			}

			new ent = -1, Float:max[3], Float:min[3], origin[3], origin2[3], telenear = 0, pushnear = 0, playernear = 0
			entity_set_int(id, EV_INT_solid, SOLID_NOT)
			get_user_origin(id, origin)

			ent = -1
			for(;;) {
				ent = find_ent_by_class(ent, "trigger_teleport")
				if(!ent) {
					break
				}

				entity_get_vector(ent, EV_VEC_absmax, max)
				entity_get_vector(ent, EV_VEC_absmin, min)

				if(origin[0] > min[0] - 30 &&
				   origin[1] > min[1] - 30 &&
				   origin[2] > min[2] - 60 &&
				   origin[0] < max[0] + 30 &&
				   origin[1] < max[1] + 30 &&
				   origin[2] < max[2] + 60) {
					telenear = 1
					break
				}
			}

			ent = -1
			for(;;) {
				ent = find_ent_by_class(ent, "trigger_push")
				if(!ent) {
					break
				}

				entity_get_vector(ent, EV_VEC_absmax, max)
				entity_get_vector(ent, EV_VEC_absmin, min)

				if(origin[0] > min[0] - 50 &&
				   origin[1] > min[1] - 50 &&
				   origin[2] > min[2] - 50 &&
				   origin[0] < max[0] + 50 &&
				   origin[1] < max[1] + 50 &&
				   origin[2] < max[2] + 50) {
					pushnear = 1
					break
				}
			}

			new targetindex, targetname[33]
			if(cmd_targetset(-1, "*", 4, targetname, 32)) {
				while((targetindex = cmd_target())) {
					if((get_user_team(targetindex) == 1 || get_user_team(targetindex) == 2) && is_user_alive(targetindex) && id != targetindex) {
						get_user_origin(targetindex, origin2)
						new Float:semidist = (get_speed(id)+get_speed(targetindex) / 2.0)+75.0

						if(get_distance(origin, origin2) <= semidist) {
							playernear = 1
							break
						}
					}
				}
			}

			new mapname[32]
			get_mapname(mapname,31)

			if(telenear) {
				entity_set_int(id, EV_INT_solid, SOLID_BBOX)
			} else if(pushnear/* && !equali(mapname, "surf_mindspin")*/) {
				entity_set_int(id, EV_INT_solid, SOLID_BBOX)
			} else if(playernear) {
				entity_set_int(id, EV_INT_solid, SOLID_NOT)
			} else {
				entity_set_int(id, EV_INT_solid, SOLID_BBOX)
			}
		}
	}
}
