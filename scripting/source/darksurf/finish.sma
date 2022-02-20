#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <cstrike>
#include <darksurf.inc>

new finishent = -1
new finishon = 0
new g_fxBeamSprite, sprFlare6, sprLightning

public plugin_init() {
   	register_plugin("DARKSURF - FINISH","T9k","Team9000")

	finishon = 0
	finishent = createfinish(0.0, 0.0, 0.0)

	set_task(0.5,"effects",0,"",0,"b")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("darksurf_finish")

	register_native("surf_set_finish","surf_set_finish_impl")
	register_native("surf_get_finish","surf_get_finish_impl")
	register_native("surf_get_finishon","surf_get_finishon_impl")
}

public plugin_precache() {
	g_fxBeamSprite = precache_model("sprites/lgtning.spr")
	sprFlare6 = precache_model("sprites/Flare6.spr")
	sprLightning = g_fxBeamSprite
}

public surf_set_finish_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new Float:pos[3]
	get_array_f(1, pos, 3)

	remove_entity(finishent)
	finishent = createfinish(pos[0], pos[1], pos[2])

	if(pos[0] != 0.0 || pos[1] != 0.0 || pos[2] != 0.0) {
		finishon = 1
	} else {
		finishon = 0
	}

	return 1
}

public surf_get_finish_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new Float:pos[3]
	entity_get_vector(finishent, EV_VEC_origin, pos)

	set_array_f(1, pos, 3)

	return 1
}

public surf_get_finishon_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return finishon
}

public createfinish(Float:x, Float:y, Float:z) {
	new ent = create_entity("info_target")
	entity_set_string(ent, EV_SZ_classname, "surf_finish")

	new Float:origin[3]
	origin[0] = x
	origin[1] = y
	origin[2] = z
	entity_set_vector(ent, EV_VEC_origin, origin)

	new Float:minbox[3] = {-50.0,-50.0,-50.0}
	new Float:maxbox[3] = {50.0,50.0,50.0}
	new Float:angles[3] = {0.0,0.0,0.0}
	entity_set_vector(ent, EV_VEC_mins, minbox)
	entity_set_vector(ent, EV_VEC_maxs, maxbox)
	entity_set_vector(ent, EV_VEC_angles, angles)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY)

	return ent
}

public effects() {
	if(finishon) {
		new Float:origin[3]
		entity_get_vector(finishent, EV_VEC_origin, origin)

		for(new i=0;i<10;i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(20)					// TE_BEAMDISK
			write_coord(floatround(origin[0]))		// coord coord coord (center position)
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]-35.0))
			write_coord(floatround(origin[0]))		// coord coord coord (axis and radius)
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]+random_float(150.0,200.0)))
			switch(random_num(0,1)) {
				case 0: write_short(sprFlare6)		// short (sprite index)
				case 1: write_short(sprLightning)	// short (sprite index)
			}
			write_byte(0)					// byte (starting frame)
			write_byte(0)					// byte (frame rate in 0.1's)
			write_byte(5)					// byte (life in 0.1's)
			write_byte(10)					// byte (line width in 0.1's)
			write_byte(0)					// byte (noise amplitude in 0.01's)
			write_byte(217)					// byte,byte,byte (color)
			write_byte(49)
			write_byte(43)
			write_byte(200)					// byte (brightness)
			write_byte(0)					// byte (scroll speed in 0.1's)
			message_end()
		}

		new points[4][3]
		points[0][2] = points[1][2] = points[2][2] = points[3][2] = floatround(origin[2])-32;
		points[0][0] = points[1][0] = floatround(origin[0])-50
		points[2][0] = points[3][0] = floatround(origin[0])+50
		points[1][1] = points[2][1] = floatround(origin[1])-50
		points[0][1] = points[3][1] = floatround(origin[1])+50

		drawline(240, 20, 20, 230, points[0], points[1], 5, 20, 20)
		drawline(240, 20, 20, 230, points[1], points[2], 5, 20, 20)
		drawline(240, 20, 20, 230, points[2], points[3], 5, 20, 20)
		drawline(240, 20, 20, 230, points[3], points[0], 5, 20, 20)
	}
}

public drawline(red, green, blue, brightness, point1[3], point2[3], life, width, noise) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0)			// TE_BEAMPOINTS

	write_coord(point1[0])
	write_coord(point1[1])
	write_coord(point1[2])
	write_coord(point2[0])
	write_coord(point2[1])
	write_coord(point2[2])

	write_short(g_fxBeamSprite)	// sprite index
	write_byte(0)		// start frame
	write_byte(0)		// framerate
	write_byte(life)	// life
	write_byte(width)		// width
	write_byte(noise)		// noise

	write_byte(red)		// r, g, b
	write_byte(green)		// r, g, b
	write_byte(blue)		// r, g, b

	write_byte(brightness)		// brightness
	write_byte(0)		// speed
	message_end()
}

public client_PreThink(id) {
	if(!finishon) {
		return
	}
	if(id && is_user_connected(id) && is_user_alive(id)) {
		new Float:origin[3]
		entity_get_vector(id, EV_VEC_origin, origin)
		new Float:finishorigin[3]
		entity_get_vector(finishent, EV_VEC_origin, finishorigin)

		if(vector_distance(origin, finishorigin) < 50) {
			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("surf_finished", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(id)
						callfunc_end()
					}
				}
			}
		}
	}
}
