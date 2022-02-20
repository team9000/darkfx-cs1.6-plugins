#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fun>
#include <dfx>
#include <dfx-hook>
#include <dfx-stealth>
#include <sub_handler>

new gHookLocation[33][3]
new bool:gIsHooked[33]
new Float:gBeamIsCreated[33]
new beam

#define TE_BEAMPOINTS 0
#define TE_BEAMENTPOINT 1
#define TE_KILLBEAM 99
#define BEAMLIFE 100		// deciseconds
#define REELSPEED 200		// units per second

public plugin_init() {
	register_plugin("DFX-MOD - Hook","MM","doubleM")
	register_clcmd("+hook", "hook_on")
	register_clcmd("-hook", "hook_off")
}

public darkfx_register_fw() {
	dfx_registerskill("Hook Upgrade", "hook")
}

public plugin_natives() {
	register_library("dfx-mod-hook")

	register_native("is_hooking","is_hooking_impl")
}

public is_hooking_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return gIsHooked[get_param(1)]
}

public plugin_precache() {
	precache_sound("weapons/xbow_hit2.wav")
	beam = precache_model("sprites/zbeam4.spr")
}

public client_PreThink(id) { 
	if(!id || !is_user_connected(id) || !gIsHooked[id]) {
		return
	}

	new user_origin[3], Float:velocity[3]

	if(!is_user_alive(id) || handle_getspeed(id) <= 1.0) {
		RopeRelease(id)
		return
	}

	if(gBeamIsCreated[id] + BEAMLIFE/10 <= get_gametime()) {
		beamentpoint(id)
	}

	new skill = dfx_getskill(id, "hook")

	get_user_origin(id, user_origin) 
	new distance = get_distance(gHookLocation[id], user_origin)
	if(distance > 0) { 
		velocity[0] = (gHookLocation[id][0] - user_origin[0]) * (REELSPEED * (1+0.5*skill)) / distance
		velocity[1] = (gHookLocation[id][1] - user_origin[1]) * (REELSPEED * (1+0.5*skill)) / distance
		velocity[2] = (gHookLocation[id][2] - user_origin[2]) * (REELSPEED * (1+0.5*skill)) / distance
	} else {
		velocity[0] = 0.0
		velocity[1] = 0.0
		velocity[2] = 0.0
	}

	entity_set_vector(id, EV_VEC_velocity, velocity)
} 

public hook_on(id) {
	if(!gIsHooked[id] && is_user_alive(id) && handle_getspeed(id) > 1.0) {
		new skill = dfx_getskill(id, "hook")
		if(skill == -1) {
			alertmessage(id,3,"Hook is restricted on this map")
			return PLUGIN_HANDLED
		} 		RopeAttach(id)
	}
	return PLUGIN_HANDLED
}

public hook_off(id) {
	if(gIsHooked[id]) {
		RopeRelease(id)
	}
	return PLUGIN_HANDLED
}

public RopeAttach(id) {
	new user_origin[3]

	gIsHooked[id] = true
	get_user_origin(id,user_origin)
	get_user_origin(id,gHookLocation[id], 3)
	handle_gravity(2, id, 0.00001)
	beamentpoint(id)
	new skill = dfx_getskill(id, "hook")
	if(skill != 4)
		emit_sound(id, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0-(0.25 * (skill)), ATTN_NORM, 0, PITCH_NORM)
}

public RopeRelease(id) {
	gIsHooked[id] = false
	killbeam(id)
	handle_gravity_off(2, id)
}

public beamentpoint(id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(id)
	write_coord(gHookLocation[id][0])
	write_coord(gHookLocation[id][1])
	write_coord(gHookLocation[id][2])
	write_short(beam)	// sprite index
	write_byte(0)		// start frame
	write_byte(0)		// framerate
	write_byte(BEAMLIFE)	// life
	write_byte(10)	// width
	write_byte(0)		// noise
	new skill = dfx_getskill(id, "hook")

	if(get_user_team(id)==2 && cs_get_user_vip(id)) {
		write_byte( 0 )					// r, g, b
		write_byte( 255 )				// r, g, b
		write_byte( 0 )					// r, g, b
	} else if(is_stealth(id)) {
		write_byte( 255-(40 * (skill)) )		// r, g, b
		write_byte( 250-(40 * (skill)) )		// r, g, b
		write_byte( 250-(40 * (skill)) )		// r, g, b
	} else {
		if(get_user_team(id)==1) {			// Terrorist
			write_byte( 255-(40 * (skill)) )	// r, g, b
			write_byte( 0 )				// r, g, b
			write_byte( 0 )				// r, g, b
		} else {					// Counter-Terrorist
			write_byte( 0 )				// r, g, b
			write_byte( 0 )				// r, g, b
			write_byte( 255-(40 * (skill)) )	// r, g, b
		}
	}
	write_byte( 150-(30 * (skill)) )			// brightness
	write_byte( 0 )						// speed
	message_end( )
	gBeamIsCreated[id] = get_gametime()
}

public killbeam(id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(id)
	message_end()
}
