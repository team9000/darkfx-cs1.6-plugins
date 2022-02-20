#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <darksurf.inc>
#include <sub_hud>
#include <sub_damage>
#include <sub_handler>
#include <sub_lowresources>

#define CAMERA_SPEED 3

// 1 = Invincible
#define CAMERA_HEALTH 1.0

new camera[33]
new Float:origin[33][3]
new bool:in_camera[33]
new fire

public plugin_init() {
	register_plugin("DARKSURF - *Camera","T9k","Team9000")
	register_menucmd(register_menuid("Camera Menu"), 1023, "menuProc")
}

public surf_register_fw() {
	surf_registerskill("Portable Camera", "camera", 2000)
}

public surf_change_skill(id) {
	if(surf_getskill(id, "camera") && surf_getskillon(id, "camera")) {
		if(is_user_alive(id)) {
			set_task(0.01, "menu", id)
		}
		surf_setskillon(id, "camera", 0)
	}
}

public client_PreThink(id) {
	if(!id || !is_user_connected(id)) {
		return
	}

	if(camera[id] && !is_valid_ent(camera[id])) {
		if(in_camera[id]) {
			view_camera(id)
		}
		camera[id] = 0
		create_explosion(origin[id],5,4)
		alertmessage(id,3,"Someone blew up your camera!")
	} else if(in_camera[id]) {
		new buttons = get_user_button(id)

		if(buttons & IN_USE) {
			view_camera(id)
		}
	}

	if(camera[id]) {
		new Float:v_angle[3]
		entity_get_vector(id,EV_VEC_v_angle,v_angle)
		entity_set_vector(camera[id],EV_VEC_angles,v_angle)
	}
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(in_camera[victim]) {
		view_camera(victim)
	}
}

public plugin_precache() {
	if(is_lowresources()) return;
	fire = precache_model("sprites/explode1.spr")
	precache_model("models/team9000/camera.mdl")
}

public menu(id) {
	new content[192]
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3
	format(content, 191, "\yCamera Menu^n")
	format(content, 191, "%s\w1. Create Camera^n", content)
	format(content, 191, "%s2. Delete Camera^n^n", content)
	if(in_camera[id]) {
		format(content, 191, "%s\y3. Stop Viewing Camera^n^n", content)
	} else {
		format(content, 191, "%s\y3. View Camera^n^n", content)
	}
	format(content, 191, "%s\r0. Exit", content)
	show_menu(id,keys,content)
	set_menuopen(id, 1)
}

public menuProc(id,key) {
	set_menuopen(id, 0)

	if(surf_getskill(id, "camera")) {
		if(key == 0) {
			create_camera(id)
			menu(id)
		} else if(key == 1) {
			delete_camera(id)
			menu(id)
		} else if(key == 2) {
			view_camera(id)
			menu(id)
		}
	}

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	delete_camera(id)
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	delete_camera(id)
	return PLUGIN_CONTINUE
}

public create_camera(id) {
	if(is_lowresources()){
		alertmessage(id,3,"You can't use cameras on this map!")
		return 0
	}

	if(!is_user_alive(id)) {
		alertmessage(id,3,"You can't create a camera while you are dead!")
		return 0
	}

	if(camera[id] && delete_camera(id)) {
		alertmessage(id,3,"Your old camera was deleted and new camera spawned!")
	}

	new Float:v_angle[3], Float:angles[3]
	entity_get_vector(id,EV_VEC_origin,origin[id])
	entity_get_vector(id,EV_VEC_v_angle,v_angle)
	entity_get_vector(id,EV_VEC_angles,angles)

	new ent = create_entity("info_target")

	entity_set_string(ent,EV_SZ_classname,"darksurf_camera")

	if(CAMERA_HEALTH == 1)
		entity_set_int(ent,EV_INT_solid,SOLID_NOT)
	else
		entity_set_int(ent,EV_INT_solid,SOLID_BBOX)
	entity_set_int(ent,EV_INT_movetype,MOVETYPE_FLY)
	entity_set_edict(ent,EV_ENT_owner,id)
	entity_set_model(ent,"models/team9000/camera.mdl")
	entity_set_float(ent,EV_FL_health,CAMERA_HEALTH)
	if(CAMERA_HEALTH == 1)
		entity_set_float(ent,EV_FL_takedamage,0.0)
	else
		entity_set_float(ent,EV_FL_takedamage,1.0)

	new Float:mins[3]
	mins[0] = -5.0
	mins[1] = -10.0
	mins[2] = -5.0

	new Float:maxs[3]
	maxs[0] = 5.0
	maxs[1] = 10.0
	maxs[2] = 5.0

	entity_set_size(ent,mins,maxs)

	entity_set_origin(ent,origin[id])
	entity_set_vector(ent,EV_VEC_v_angle,v_angle)
	entity_set_vector(ent,EV_VEC_angles,angles)

	camera[id] = ent

	return 1
}


public view_camera(id) {
	if(in_camera[id]) {
		in_camera[id] = false
		attach_view(id,id)
		myhud_small(10, id, "", 0.0)
		handle_speed_off(4, id)
		return 1
	} else {
		if(is_valid_ent(camera[id])) {
			attach_view(id,camera[id])
			in_camera[id] = true
			myhud_small(10, id, "PRESS USE KEY TO EXIT CAMERA", -1.0)
			handle_speed(4, id, 0.0, 0)
			return 1
		}
	}

	return 0
}

public delete_camera(id) {
	if(is_valid_ent(camera[id])) {
		if(in_camera[id]) {
			view_camera(id)
		}
		create_explosion(origin[id],5,4)
		remove_entity(camera[id])
		camera[id] = 0
		return 1
	}
	camera[id] = 0
	return 0
}

public create_explosion(Float:origin[3],size,flags) {
	new origina[3]
	origina[0] = floatround(origin[0])
	origina[1] = floatround(origin[1])
	origina[2] = floatround(origin[2])

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origina) 
	write_byte( 3 ) 
	write_coord(origina[0])	// start position
	write_coord(origina[1])
	write_coord(origina[2])
	write_short( fire )
	write_byte( size ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	write_byte( flags ) // byte flags (4 = no explode sound)
	message_end()
}
