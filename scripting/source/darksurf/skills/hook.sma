#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fun>
#include <darksurf.inc>
#include <sub_handler>

new gHookLocation[33][3]
new bool:gIsHooked[33]
new Float:gBeamIsCreated[33]
new beam

#define TE_BEAMPOINTS 0
#define TE_BEAMENTPOINT 1
#define TE_KILLBEAM 99
#define BEAMLIFE 100		// deciseconds
#define REELSPEED 300		// units per second

public plugin_init() {
	register_plugin("DARKSURF - *Hook","T9k","Team9000")
	register_clcmd("+hook", "hook_on")
	register_clcmd("-hook", "hook_off")
}

public surf_register_fw() {
	surf_registerskill("Hook", "hook", 5000, 1)
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

	new skill = surf_getskill(id, "hook") && surf_getskillon(id, "hook")

	if(!is_user_alive(id) || handle_getspeed(id) <= 1.0 || !skill) {
		RopeRelease(id)
		return
	}

	if(gBeamIsCreated[id] + BEAMLIFE/10 <= get_gametime()) {
		beamentpoint(id)
	}

	get_user_origin(id, user_origin) 
	new distance = get_distance(gHookLocation[id], user_origin)
	if(distance > 0) { 
		velocity[0] = (gHookLocation[id][0] - user_origin[0]) * (REELSPEED * (1+0.5*5)) / distance
		velocity[1] = (gHookLocation[id][1] - user_origin[1]) * (REELSPEED * (1+0.5*5)) / distance
		velocity[2] = (gHookLocation[id][2] - user_origin[2]) * (REELSPEED * (1+0.5*5)) / distance
	} else {
		velocity[0] = 0.0
		velocity[1] = 0.0
		velocity[2] = 0.0
	}

	entity_set_vector(id, EV_VEC_velocity, velocity)
} 

public hook_on(id) {
	if(!gIsHooked[id] && is_user_alive(id) && handle_getspeed(id) > 1.0) {
		new skill = surf_getskill(id, "hook") && surf_getskillon(id, "hook")
		if(skill) {
			RopeAttach(id)
		}
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
	emit_sound(id, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
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

	if(get_user_team(id)==1) {	// Terrorist
		write_byte( 255 )	// r, g, b
		write_byte( 0 )		// r, g, b
		write_byte( 0 )		// r, g, b
	} else {			// Counter-Terrorist
		write_byte( 0 )		// r, g, b
		write_byte( 0 )		// r, g, b
		write_byte( 255 )	// r, g, b
	}
	write_byte( 150 )		// brightness
	write_byte( 0 )			// speed
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
