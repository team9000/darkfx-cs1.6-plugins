#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <fun>
#include <engine>
#include <sub_handler>
#include <sub_roundtime>
#include <sub_damage>
#include <sub_respawn>
#include <sub_lowresources>

#define NEED_COLORRGBS
#include <sub_const>

new Float:defspeed[32] = {
0.0,	//
250.0,	// P228
0.0,	//
260.0,	// Scout
250.0,	// HE Grenade
240.0,	// Auto Shotgun
250.0,	// C4
250.0,	// MAC-10
240.0,	// AUG (CT Semi-Sniper)
250.0,	// Smoke Grenade
250.0,	// Dual Elites
250.0,	// Five-Seven
250.0,	// UMP45
210.0,	// SG550 (CT Auto-Sniper)
240.0,	// Defender
240.0,	// Clarion
250.0,	// USP
250.0,	// Glock
210.0,	// AWP
250.0,	// MP5 Navy
220.0,	// M249
250.0,	// 12 Gauge
230.0,	// M4
250.0,	// TMP
210.0,	// G3SG1 (T Auto-Sniper)
250.0,	// Flashbang
250.0,	// Deagle
235.0,	// SG552 (T Semi-Sniper)
221.0,	// AK47
250.0,	// Knife
245.0,	// P90
0.0	//
}

#define RENDERING_PLUGINS 8
/* RENDERING PLUGINS
0 = DARKMOD
1 = MUTANT
2 = CRAZY
3 = CHICKEN
4 = GLOW
5 = HOLIDAY
6 = BOTS
7 = SURF GODMODE
*/
new rendering[33][RENDERING_PLUGINS]
new render[33][RENDERING_PLUGINS][6]
new rendering_priority[RENDERING_PLUGINS] = {
6, 4, 3, 7, 1, 5, 2, 0
}
new renderingchanged[33]

#define MODELING_PLUGINS 3
/* MODELING PLUGINS
0 = CHICKEN
1 = HOLIDAY
2 = ADMIN
*/
new modeling[33][MODELING_PLUGINS]
new model[33][MODELING_PLUGINS][128]
new modeling_priority[MODELING_PLUGINS] = {
0, 2, 1
}
new lastmodel[33]

#define HEALTHING_PLUGINS 1
/* MODELING PLUGINS
0 = DARKMOD
*/
new healthing[33][HEALTHING_PLUGINS]
new health[33][HEALTHING_PLUGINS]
new healthing_priority[HEALTHING_PLUGINS] = {
0
}

#define SPEEDING_PLUGINS 5
/* SPEEDING PLUGINS
0 = SPEEDKNIFE
1 = CHICKEN
2 = ROCKET
3 = UBERSLAP
4 = CAMERA
*/
new speeding[33][SPEEDING_PLUGINS]
new Float:speed[33][SPEEDING_PLUGINS]
new speedsetmult[33][SPEEDING_PLUGINS]
new speeding_priority[SPEEDING_PLUGINS] = {
4, 3, 2, 1, 0
}
new Float:speedset[33]

#define GRAVITYING_PLUGINS 4
/* GRAVITYING PLUGINS
0 = LOW GRAVITY SKILL
1 = CHICKEN
2 = HOOK OVERRIDE
3 = ROCKET
*/
new gravitying[33][GRAVITYING_PLUGINS]
new Float:gravity[33][GRAVITYING_PLUGINS]
new gravitying_priority[GRAVITYING_PLUGINS] = {
3, 2, 1, 0
}
new Float:gravityset[33]

#define TRAILING_PLUGINS 1
/* TRAILING PLUGINS
0 = ADMIN TRAIL
*/
new trailing[33][TRAILING_PLUGINS]
new trail[33][TRAILING_PLUGINS]
new trailcolor[33][TRAILING_PLUGINS]
new trailing_priority[TRAILING_PLUGINS] = {
0
}
new trailchanged[33]
new traillastpos[33][3]
new traillasttime[33]
new traillastspeeding[33]
new traillaststopped[33]

#define TRAIL_LIFE 3

#define NUM_SPRITES 4
new trail_sprites[NUM_SPRITES][] = {
"sprites/dot.spr",
"sprites/xenobeam.spr",
"sprites/zbeam3.spr",
"sprites/zbeam2.spr"
}
new trail_sizes[NUM_SPRITES] = {
4, 15, 15, 20
}
new trail_brightnesses[NUM_SPRITES] = {
200, 240, 200, 200
}
new trail_precache[NUM_SPRITES]

public plugin_init() {
	register_plugin("Subsys - Handler","T9k","Team9000")

	for(new i = 0; i < 33; i++) {
		for(new j = 0; j < RENDERING_PLUGINS; j++) {
			rendering[i][j] = 0
		}
		renderingchanged[i] = 0
		for(new j = 0; j < MODELING_PLUGINS; j++) {
			modeling[i][j] = 0
		}
		lastmodel[i] = -1
		for(new j = 0; j < SPEEDING_PLUGINS; j++) {
			speeding[i][j] = 0
		}
		speedset[i] = 0.0
		for(new j = 0; j < GRAVITYING_PLUGINS; j++) {
			gravitying[i][j] = 0
		}
		for(new j = 0; j < TRAILING_PLUGINS; j++) {
			trailing[i][j] = 0
		}
		trailchanged[i] = 0
		traillastpos[i][0] = 0
		traillastpos[i][1] = 0
		traillastpos[i][2] = 0
		traillasttime[i] = 0
		traillastspeeding[i] = 0
		traillaststopped[i] = 0
	}

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_handler")

	register_native("handle_rendering","handle_rendering_impl")
	register_native("handle_rendering_off","handle_rendering_off_impl")
	register_native("handle_model","handle_model_impl")
	register_native("handle_model_off","handle_model_off_impl")
	register_native("handle_maxhp","handle_maxhp_impl")
	register_native("handle_maxhp_off","handle_maxhp_off_impl")
	register_native("handle_speed","handle_speed_impl")
	register_native("handle_speed_off","handle_speed_off_impl")
	register_native("handle_getspeed","handle_getspeed_impl")
	register_native("handle_gravity","handle_gravity_impl")
	register_native("handle_gravity_off","handle_gravity_off_impl")
	register_native("handle_getgravity","handle_getgravity_impl")
	register_native("handle_trail","handle_trail_impl")
	register_native("handle_trail_off","handle_trail_off_impl")
}

public client_connect(id) {
	new i = id
	for(new j = 0; j < RENDERING_PLUGINS; j++) {
		rendering[i][j] = 0
	}
	renderingchanged[i] = 0
	for(new j = 0; j < MODELING_PLUGINS; j++) {
		modeling[i][j] = 0
	}
	lastmodel[i] = -1
	for(new j = 0; j < SPEEDING_PLUGINS; j++) {
		speeding[i][j] = 0
	}
	speedset[i] = 0.0
	for(new j = 0; j < GRAVITYING_PLUGINS; j++) {
		gravitying[i][j] = 0
	}
	for(new j = 0; j < TRAILING_PLUGINS; j++) {
		trailing[i][j] = 0
	}
	trailchanged[i] = 0
	traillastpos[i][0] = 0
	traillastpos[i][1] = 0
	traillastpos[i][2] = 0
	traillasttime[i] = 0
	traillastspeeding[i] = 0
	traillaststopped[i] = 0
}

public handle_rendering_impl(id, numparams) {
	if(numparams != 3)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	get_array(3, render[playerid][pluginid], 6)
	rendering[playerid][pluginid] = 1

	return 1
}

public handle_rendering_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	rendering[playerid][pluginid] = 0

	return 1
}

public handle_model_impl(id, numparams) {
	if(numparams != 3)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	new newmodel[128]
	get_string(3, newmodel, 127)
	if(!equal(newmodel, model[playerid][pluginid])) {
		if(lastmodel[playerid] == pluginid) {
			lastmodel[playerid] = -1
		}
		get_string(3, model[playerid][pluginid], 127)
	}
	modeling[playerid][pluginid] = 1

	return 1
}

public handle_model_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	modeling[playerid][pluginid] = 0

	return 1
}

public handle_maxhp_impl(id, numparams) {
	if(numparams != 3)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	health[playerid][pluginid] = get_param(3)
	healthing[playerid][pluginid] = 1

	if(lastmodel[playerid] == pluginid) {
		lastmodel[playerid] = -1
	}

	return 1
}

public handle_maxhp_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	healthing[playerid][pluginid] = 0

	return 1
}

public handle_speed_impl(id, numparams) {
	if(numparams != 4)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)

	speed[playerid][pluginid] = get_param_f(3)
	speedsetmult[playerid][pluginid] = get_param(4)
	speeding[playerid][pluginid] = 1

	return 1
}

public handle_speed_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	speeding[playerid][pluginid] = 0

	return 1
}

public Float:handle_getspeed_impl(id, numparams) {
	if(numparams != 1)	
		return float(log_error(10, "Bad native parameters"))

	new id = get_param(1)

	if(speedset[id] == 1.1 || speedset[id] == 1.2 || get_user_maxspeed(id) <= 1.0) {
		return 0.0
	}
	return speedset[id]
}

public handle_gravity_impl(id, numparams) {
	if(numparams != 3)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)

	gravity[playerid][pluginid] = get_param_f(3)
	gravitying[playerid][pluginid] = 1

	return 1
}

public handle_gravity_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	gravitying[playerid][pluginid] = 0

	return 1
}

public Float:handle_getgravity_impl(id, numparams) {
	if(numparams != 1)	
		return float(log_error(10, "Bad native parameters"))

	new id = get_param(1)
	return gravityset[id]
}

public handle_trail_impl(id, numparams) {
	if(numparams != 4)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)

	if(get_param(3) >= NUM_SPRITES || get_param(3) < 0) {
		return 1
	}

	trail[playerid][pluginid] = get_param(3)
	trailcolor[playerid][pluginid] = get_param(4)
	trailing[playerid][pluginid] = 1
	trailchanged[playerid] = 1

	return 1
}

public handle_trail_off_impl(id, numparams) {
	if(numparams != 2)	
		return log_error(10, "Bad native parameters")

	new pluginid = get_param(1)
	new playerid = get_param(2)
	trailing[playerid][pluginid] = 0
	trailchanged[playerid] = 1

	return 1
}

public client_PreThink(id) {
	if(id && is_user_connected(id)) {
		update_render(id)
		update_model(id)
		update_speed(id)
		update_gravity(id)
		update_trail(id)
	}
}

public update_render(id) {
	for(new i = 0; i < RENDERING_PLUGINS; i++) {
		new pluginid = rendering_priority[i]
		if(rendering[id][pluginid]) {
			set_user_rendering(id,render[id][pluginid][0],render[id][pluginid][1],render[id][pluginid][2],render[id][pluginid][3],render[id][pluginid][4],render[id][pluginid][5])
			renderingchanged[id] = 1
			return
		}
	}

	if(renderingchanged[id]) {
		renderingchanged[id] = 0
		set_user_rendering(id)
	}
}

public update_model(id) {
	for(new i = 0; i < MODELING_PLUGINS; i++) {
		new pluginid = modeling_priority[i]
		if(modeling[id][pluginid]) {
			if(lastmodel[id] != pluginid) {
				cs_set_user_model(id,model[id][pluginid])
				lastmodel[id] = pluginid
			}
			return
		}
	}

	if(lastmodel[id] != -1) {
		lastmodel[id] = -1
		cs_reset_user_model(id)
	}
}


// speedset 1.2 = dont mess with it
// speedset 1.1 = set it to no speed
public update_speed(id) {
	new clip, ammo
	new wid = get_user_weapon(id, clip, ammo)

	if(get_user_maxspeed(id) <= 1.0) {
		speedset[id] = 1.2
	} else {
		if(defspeed[wid] == 0.0 || wid < 0 || wid > 31) {
			speedset[id] = 1.1
		} else {
			speedset[id] = defspeed[wid]

			for(new i = 0; i < SPEEDING_PLUGINS; i++) {
				new pluginid = speeding_priority[i]
				if(speeding[id][pluginid]) {
					if(speed[id][pluginid] == 0.0) {
						speedset[id] = 1.1
					} else {
						if(!speedsetmult[id][pluginid]) {
							speedset[id] = speed[id][pluginid]
						} else {
							speedset[id] = defspeed[wid]*speed[id][pluginid]
						}
					}
					break
				}
			}
		}
	}

	if(speedset[id] != 1.2) {
		set_user_maxspeed(id, speedset[id])
	}
}

public update_gravity(id) {
	gravityset[id] = 1.0

	for(new i = 0; i < GRAVITYING_PLUGINS; i++) {
		new pluginid = gravitying_priority[i]
		if(gravitying[id][pluginid]) {
			gravityset[id] = gravity[id][pluginid]
			break
		}
	}

//	set_user_gravity(id,gravityset[id])
}

public plugin_precache() {
	if(is_lowresources()) return;
	for(new i = 0; i < NUM_SPRITES; i++) {
		trail_precache[i] = precache_model(trail_sprites[i])
	}
}

public update_trail(id) {
	for(new i = 0; i < TRAILING_PLUGINS; i++) {
		new pluginid = trailing_priority[i]
		if(trailing[id][pluginid]) {
			new origin[3]
			get_user_origin(id, origin)
			new reset = 0
			if(trailchanged[id]) {
				reset = 1
			}

			if(!reset) {
				if(traillastpos[id][0] != origin[0] || traillastpos[id][1] != origin[1] || traillastpos[id][2] != origin[2]) {
					if(get_distance(origin, traillastpos[id]) > 50 || time_time() > traillasttime[id] + 1) {
						reset = 1
					}	
				}
			}

			if(!reset) {
				if(get_speed(id) < 500 && traillastspeeding[id]) {
					reset = 1
				}
			}

			if(!reset) {
				if(get_speed(id) > 5 && traillaststopped[id]) {
					reset = 1
				}
			}

			if(reset) {
				kill_trail(id)
				start_trail(id, trail[id][pluginid], trailcolor[id][pluginid])
			}

			traillaststopped[id] = (get_speed(id) <= 5)
			traillastspeeding[id] = (get_speed(id) >= 500)

			traillastpos[id][0] = origin[0]
			traillastpos[id][1] = origin[1]
			traillastpos[id][2] = origin[2]
			traillasttime[id] = time_time()
			trailchanged[id] = 0
			return
		}
	}

	if(trailchanged[id]) {
		kill_trail(id)
	}
}

public kill_trail(id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)
	write_short(id)
	message_end()
}

public start_trail(id, sprite, color) {
	if(!is_user_alive(id)) {
		return
	}
	if(is_lowresources()) return;

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)
	write_short(id)
	write_short(trail_precache[sprite])
	write_byte(TRAIL_LIFE*10)
	write_byte(trail_sizes[sprite])
	write_byte(colorrgbs[color][0])
	write_byte(colorrgbs[color][1])
	write_byte(colorrgbs[color][2])
	write_byte(trail_brightnesses[sprite])
	message_end()
}

public round_freezestart() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			maxhp_increase(targetindex)
			set_task(0.5, "maxhp_increase", targetindex)
		}
	}
}

public round_roundstart() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			maxhp_increase(targetindex)
			set_task(0.5, "maxhp_increase", targetindex)
		}
	}
}

public dam_respawn(id) {
	maxhp_increase(id)
}

public maxhp_increase(id) {
	for(new i = 0; i < HEALTHING_PLUGINS; i++) {
		new pluginid = healthing_priority[i]
		if(healthing[id][pluginid]) {
			if(get_upperhealth()) {
				if(get_user_health(id) < 256000+health[id][pluginid]) {
					set_user_health(id, 256000+health[id][pluginid])
				}
			} else {
				if(get_user_health(id) < health[id][pluginid]) {
					set_user_health(id, health[id][pluginid])
				}
			}
			return
		}
	}

	if(get_upperhealth()) {
		if(get_user_health(id) < 256000+100) {
			set_user_health(id, 256000+100)
		}
	} else {
		if(get_user_health(id) < 100) {
			set_user_health(id, 100)
		}
	}
}
