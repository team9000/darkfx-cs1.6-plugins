#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fun>
#include <sub_respawn>
#include <sub_damage>
#include <sub_setup>
#include <sub_storage>
#include <sub_hud>
#include <sub_lowresources>

new autorespawn_godmode = 0
new autorespawn_mode = 0
// 0 = off
// 1 = team bases
// 2 = near to team, far from enemy
// 3 = far from all

new lastctspawn
new lasttspawn

new sprFlare6, sprLightning, beam

#define MAX_SPAWNPOINTS 80
new Float:spawnpoints[MAX_SPAWNPOINTS][3]
new NUM_SPAWNPOINTS = 0

new changed

public plugin_init() {
	register_plugin("Subsys - Respawn","T9k","Team9000")

	autorespawn_mode = 0

	lastctspawn = 0
	lasttspawn = 0

	NUM_SPAWNPOINTS = 0

	changed = 0
	register_menucmd(register_menuid("DarkMod Setup - Respawn Points"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_respawn")

	register_native("respawn_auto","respawn_auto_impl")
	register_native("respawn_auto_off","respawn_auto_off_impl")
	register_native("respawn_now","respawn_now_impl")
	register_native("get_upperhealth","get_upperhealth_impl")
}

public plugin_precache() {
	if(!is_lowresources()) {
		sprFlare6 = precache_model("sprites/Flare6.spr")
		sprLightning = precache_model("sprites/lgtning.spr")
	}
	beam = precache_model("sprites/zbeam4.spr")
}

public respawn_auto_impl(id, numparams) {
	if(numparams != 3)	
		return log_error(10, "Bad native parameters")

//	autorespawn_delay = get_param(1)
	autorespawn_godmode = get_param(2)
	autorespawn_mode = get_param(3)
	set_task(2.0,"check_respawn",100,"",0,"b")
	return 1
}

public respawn_auto_off_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(get_user_health(targetindex) > 200000) {
				set_user_health(targetindex, get_user_health(targetindex)-256000)
			}
		}
	}

	autorespawn_mode = 0
	remove_task(100)
	return 1
}

public respawn_now_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	if((cs_get_user_team(id) != CS_TEAM_T && cs_get_user_team(id) != CS_TEAM_CT) || is_user_alive(id)) {
		return 0
	}

	dorespawn(id)
	return 1
}

public get_upperhealth_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	if(autorespawn_mode != 0) { 
		return 1
	}

	return 0
}

public dam_death(victim, attacker, weapon[], headshot) {
/*	if(autorespawn_mode != 0) { 
		while(task_exists(victim)) {
			remove_task(victim)
		}
		dorespawn(victim)
	}*/
// THIS PLUGIN FAKES THE DEATH!
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(autorespawn_mode != 0) { 
		if(get_user_health(victim) <= 256000) {
			dam_fakedeath(victim, attacker, weapon, headshot)
			dorespawn2(victim)
			dam_fakedeath_postmove(victim, attacker, weapon, headshot)
		}
	}
}

public check_respawn() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(cs_get_user_team(targetindex) == CS_TEAM_T || cs_get_user_team(targetindex) == CS_TEAM_CT) {
				if(autorespawn_mode != 0 && !is_user_alive(targetindex) && !task_exists(targetindex)) {
					dorespawn(targetindex)
				}
			} else {
				user_kill(targetindex)
			}
		}
	}
}

public dorespawn(id) {
	set_task(0.5, "respawn", id)
	set_task(0.7, "respawn", id)
	set_task(0.9, "respawn", id)
	set_task(1.0, "movetolocation", id)
	set_task(1.0, "unzoom", id)
	set_task(1.0, "respawncall", id)
	set_task(1.1, "spawn_effect", id)
	if(autorespawn_godmode) {
		set_task(1.0, "godmode_on", id)
		set_task(1.0+autorespawn_godmode, "godmode_off", id)
	}
}

public respawncall(id) {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("dam_respawn", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}
}

public dorespawn2(id) {
	movetolocation(id)
	unzoom(id)
	new Float:angle[3] = {0.0,0.0,0.0}
	entity_set_vector(id, EV_VEC_angles, angle)
	entity_set_int(id, EV_INT_fixangle, 1)
	entity_set_vector(id, EV_VEC_velocity, angle)
	set_user_godmode(id,0)
	set_user_noclip(id,0)
	set_user_armor(id,0)
	set_user_gravity(id,1.0)
	set_task(0.001, "vel_off", id)
	set_task(0.001, "movetolocation", id)

	client_cmd(id, "-attack")
	client_cmd(id, "-attack2")
	client_cmd(id, "-reload")
	client_cmd(id, "-hook")
	if(autorespawn_godmode) {
		godmode_on(id)
		set_task(float(autorespawn_godmode), "godmode_off", id)
	}

	spawn_effect(id)
}

public unzoom(id) {
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	write_byte(0)
	message_end()
}

public respawn(id) {
	if(is_user_connected(id) && (cs_get_user_team(id) == CS_TEAM_T || cs_get_user_team(id) == CS_TEAM_CT)) {
		spawn(id)
	}
}

public godmode_on(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		set_user_godmode(id, 1)
	}
}

public vel_off(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		new Float:angle[3] = {0.0,0.0,0.0}
		entity_set_vector(id, EV_VEC_velocity, angle)
	}
}

public godmode_off(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		set_user_godmode(id, 0)
	}
}

public movetolocation(id) {
	if(autorespawn_mode == 0)
		return

	new bestsafety = -1
	new Float:bestsafetynum = 0.0

	if(autorespawn_mode == 1) {
		new classname[33], lastspawn
		if(cs_get_user_team(id) == CS_TEAM_T) {
			copy(classname, 32, "info_player_deathmatch")
			lastspawn = lasttspawn
		} else {
			copy(classname, 32, "info_player_start")
			lastspawn = lastctspawn
		}

		new ent = -1, found = 0, handled = 0
		while((ent = find_ent_by_class(ent, classname))) {
			if(ent == lastspawn) {
				found = 1
				continue
			}
			if(found || lastspawn == 0) {
				if(canmovesp(id,ent)) {
					new Float:spawnpoint[3]
					entity_get_vector(ent, EV_VEC_origin, spawnpoint)
					entity_set_vector(id, EV_VEC_origin, spawnpoint)
					handled = 1
					if(cs_get_user_team(id) == CS_TEAM_T) {
						lasttspawn = ent
					} else {
						lastctspawn = ent
					}
					break
				}
			}
		}
		if(!found || !handled) {
			if(lastspawn != 0) {
				if(cs_get_user_team(id) == CS_TEAM_T) {
					lasttspawn = 0
				} else {
					lastctspawn = 0
				}
				movetolocation(id)
			} else {
				ent = find_ent_by_class(-1, classname)
				new Float:spawnpoint[3]
				entity_get_vector(ent, EV_VEC_origin, spawnpoint)
				entity_set_vector(id, EV_VEC_origin, spawnpoint)
			}
		}
	} else {
		for(new i = 0; i < NUM_SPAWNPOINTS; i++) {
			new Float:spawnpoint[3]
			spawnpoint[0] = spawnpoints[i][0]
			spawnpoint[1] = spawnpoints[i][1]
			spawnpoint[2] = spawnpoints[i][2]

			new Float:safety = 0.0
			if(autorespawn_mode == 2) {
				new Float:closestfriend = 0.0
				new Float:closestenemy = 0.0

				new targetindex, targetname[33]
				if(cmd_targetset(-1, "*", 4, targetname, 32)) {
					while((targetindex = cmd_target())) {
						if(id != targetindex) {
							new Float:origin[3]
							entity_get_vector(targetindex, EV_VEC_origin, origin)
							if(cs_get_user_team(id) == cs_get_user_team(targetindex)) {
								if(closestfriend == 0 || vector_distance(spawnpoint, origin) < closestfriend) {
									closestfriend = vector_distance(spawnpoint, origin)
								}
							} else {
								if(closestenemy == 0 || vector_distance(spawnpoint, origin) < closestenemy) {
									closestenemy = vector_distance(spawnpoint, origin)
								}
							}
						}
					}
				}
				safety = closestenemy - closestfriend
			} else {
				new Float:closest = 0.0

				new targetindex, targetname[33]
				if(cmd_targetset(-1, "*", 4, targetname, 32)) {
					while((targetindex = cmd_target())) {
						if(id != targetindex) {
							new Float:origin[3]
							entity_get_vector(targetindex, EV_VEC_origin, origin)
							if(closest == 0 || vector_distance(spawnpoint, origin) < closest) {
								closest = vector_distance(spawnpoint, origin)
							}
						}
					}
				}
				safety = -1*closest
			}

			if(bestsafety == -1 || safety > bestsafetynum) {
				if(canmove(id, i)) {
					bestsafety = i
					bestsafetynum = safety
				}
			}
		}

		if(bestsafety != -1) {
			entity_set_vector(id, EV_VEC_origin, spawnpoints[bestsafety])
		} else {
			new temp = autorespawn_mode
			autorespawn_mode = 1
			movetolocation(id)
			autorespawn_mode = temp
		}
	}
}

public canmove(id, spawnpointnum) {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(id != targetindex) {
				new Float:origin[3]
				entity_get_vector(targetindex, EV_VEC_origin, origin)
				if(vector_distance(spawnpoints[spawnpointnum], origin) < 150) {
					return 0
				}
			}
		}
	}

	return 1
}

public canmovesp(id, ent) {
	new Float:spawnpoint[3]
	entity_get_vector(ent, EV_VEC_origin, spawnpoint)

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(id != targetindex) {
				new Float:origin[3]
				entity_get_vector(targetindex, EV_VEC_origin, origin)
				if(vector_distance(spawnpoint, origin) < 150) {
					return 0
				}
			}
		}
	}

	return 1
}

public spawn_effect(id) {
	if(!is_lowresources()) {
		new Float:origin[3]
		entity_get_vector(id, EV_VEC_origin, origin)
	
		for(new i=0;i<10;i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(20)					// TE_BEAMDISK
			write_coord(floatround(origin[0]))		// coord coord coord (center position)
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]-35.0))
			write_coord(floatround(origin[0]))		// coord coord coord (axis and radius)
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]+random_float(200.0,350.0)))
			switch(random_num(0,1)) {
				case 0: write_short(sprFlare6)		// short (sprite index)
				case 1: write_short(sprLightning)	// short (sprite index)
			}
			write_byte(0)					// byte (starting frame)
			write_byte(0)					// byte (frame rate in 0.1's)
			write_byte(5)					// byte (life in 0.1's)
			write_byte(10)					// byte (line width in 0.1's)
			write_byte(0)					// byte (noise amplitude in 0.01's)
			write_byte(43)					// byte,byte,byte (color)
			write_byte(49)
			write_byte(217)
			write_byte(200)					// byte (brightness)
			write_byte(0)					// byte (scroll speed in 0.1's)
			message_end()
		}
	}

	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id) 
	write_short( 1<<11 ) // fade lasts this long furation 
	write_short( 1<<10 ) // fade lasts this long hold time 
	write_short( 1<<12 ) // fade type (in / out) 
	write_byte( 255 ) // fade red 
	write_byte( 0 ) // fade green 
	write_byte( 0 ) // fade blue 
	write_byte( 255 ) // fade alpha 
	message_end()

	return 1
}

public setup_register_fw() {
	setup_registeroption("Respawn Points", 1)

	setup_registerfield("setup_spawnpoints")
}

public setup_loaded_fw(Handle:query) {
	new value[4096]
	new left[32], right[4096]

	new colnum = SQL_FieldNameToNum(query, "setup_spawnpoints")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 4095)

		new always = 1
		NUM_SPAWNPOINTS = 0
		while(always) {
			if(equal(value, "")) {
				break
			}

			strtok(value, left, 31, right, 4095, ' ')
			spawnpoints[NUM_SPAWNPOINTS][0] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			spawnpoints[NUM_SPAWNPOINTS][1] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			spawnpoints[NUM_SPAWNPOINTS][2] = str_to_float(left)
			copy(value, 4095, right)
			NUM_SPAWNPOINTS++
		}
	}
}

public setup_menu_fw(id) {
	setup_menu(id, -1)
}

public setup_save() {
	if(!changed) {
		return
	}
	changed = 0

	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[4096]
	format(query, 4095, "UPDATE storage_maps SET ")
	format(query, 4095, "%ssetup_spawnpoints='", query)

	for(new i = 0; i < NUM_SPAWNPOINTS; i++) {
		if(i != 0) {
			format(query, 4095, "%s ", query)
		}
		format(query, 4095, "%s%f %f %f", query, spawnpoints[i][0], spawnpoints[i][1], spawnpoints[i][2])
	}
	format(query, 4095, "%s'", query)
	format(query, 4095, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public setup_clear_fw(id) {
	while(task_exists(9999+id)) {
		remove_task(9999+id)
	}
}

public setup_menu(id, key) {
	set_menuopen(id, 0)

	if(key == 0) {
		if(NUM_SPAWNPOINTS < MAX_SPAWNPOINTS) {
			entity_get_vector(id, EV_VEC_origin, spawnpoints[NUM_SPAWNPOINTS])
			spawnpoints[NUM_SPAWNPOINTS][2] += 10
			NUM_SPAWNPOINTS++
		}
		changed = 1
	}
	if(key == 1) {
		new Float:origin[3], closest = -1, Float:closestdist
		entity_get_vector(id, EV_VEC_origin, origin)
		for(new i = 0; i < NUM_SPAWNPOINTS; i++) {
			if(vector_distance(spawnpoints[i], origin) < 100) {
				if(closest == -1 || vector_distance(spawnpoints[i], origin) < closestdist) {
					closest = i
					closestdist = vector_distance(spawnpoints[i], origin)
				}
			}
		}
		if(closest != -1) {
			for(new i = closest+1; i < NUM_SPAWNPOINTS; i++) {
				spawnpoints[i-1][0] = spawnpoints[i][0]
				spawnpoints[i-1][1] = spawnpoints[i][1]
				spawnpoints[i-1][2] = spawnpoints[i][2]
			}
			NUM_SPAWNPOINTS--
		}
		changed = 1
	}
	if(key == 9) {
		setup_save()
		setup_showmain(id)
		return PLUGIN_HANDLED
	}

	new menuBody[2048]
	format(menuBody,2047,"\yDarkMod Setup - Respawn Points^n")
	format(menuBody,2047,"%s\d%d Spawnpoints Remaining^n", menuBody, MAX_SPAWNPOINTS-NUM_SPAWNPOINTS)

	new flags = 0

	if(NUM_SPAWNPOINTS < MAX_SPAWNPOINTS) {
		format(menuBody,2047,"%s\w1. Add Spawnpoint^n", menuBody)
		flags |= (1<<0)
	} else {
		format(menuBody,2047,"%s\d1. Add Spawnpoint^n", menuBody)
	}

	if(NUM_SPAWNPOINTS > 0) {
		format(menuBody,2047,"%s\w2. Remove Spawnpoint^n", menuBody)
		flags |= (1<<1)
	} else {
		format(menuBody,2047,"%s\d2. Remove Spawnpoint^n", menuBody)
	}

	format(menuBody,511,"%s^n", menuBody)

	format(menuBody,511,"%s\r0. Exit", menuBody)
	flags |= (1<<9)

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	if(!task_exists(9999+id)) {
		set_task(1.0, "drawlines", 9999+id, "", 0, "b")
	}

	return PLUGIN_HANDLED
}

public drawlines(id) {
	id = id - 9999
	for(new i = 0; i < NUM_SPAWNPOINTS; i++) {
		drawline(id, spawnpoints[i], 0, 255, 0)
	}
}

public drawline(id, Float:pos[3], red, green, blue) {
	message_begin(MSG_ONE, SVC_TEMPENTITY,{0,0,0},id)

	#define TE_BEAMPOINTS 0
	write_byte(TE_BEAMPOINTS)

	write_coord(floatround(pos[0]))
	write_coord(floatround(pos[1]))
	write_coord(floatround(pos[2])-32)
	write_coord(floatround(pos[0]))
	write_coord(floatround(pos[1]))
	write_coord(floatround(pos[2])+32)

	write_short(beam)	// sprite index
	write_byte(0)		// start frame
	write_byte(0)		// framerate
	write_byte(10)		// life
	write_byte(20)		// width
	write_byte(3)		// noise

	write_byte(red)		// r, g, b
	write_byte(green)	// r, g, b
	write_byte(blue)	// r, g, b

	write_byte(230)		// brightness
	write_byte(0)		// speed
	message_end()
}
