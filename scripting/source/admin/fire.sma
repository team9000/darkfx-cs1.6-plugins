#include <amxmodx>
#include <sub_stocks>
#include <sub_roundtime>
#include <sub_damage>
#include <sub_lowresources>

new smoke, mflash
new bool:onfire[33]

public plugin_init() {  
	register_plugin("Admin Fire","T9k","Team9000")  
	register_concmd("amx_fire", "fire_player", LVL_FIRE, "<authid, nick, #userid, @team or *> - Sets a player on fire")  

	register_concmd("amx_beam", "beamnow", LVL_FIRE)
	return PLUGIN_CONTINUE  
} 

public plugin_precache() {
	if(!is_lowresources()) {
		mflash = precache_model("sprites/muzzleflash.spr") 
		smoke = precache_model("sprites/steam1.spr")
		precache_sound("ambience/flameburst1.wav")
		precache_sound("scientist/scream21.wav")
		precache_sound("scientist/scream07.wav")
	}
	
	return PLUGIN_CONTINUE 
} 

public beamnow(id) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(24)
	write_short(id)		// start entity
	write_short(2)		// end entity
	write_short(smoke)	// sprite index
	write_byte(0)		// starting frame 
	write_byte(10)		// framerate in 0.1's
	write_byte(1000)		// life in 0.1's
	write_byte(1000)		// line width in 0.1's
	write_byte(0)		// noise  amplitude in 0.01's
	write_byte(240)		// r
	write_byte(0)		// g
	write_byte(0)		// b
	write_byte(255)		// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()

	return PLUGIN_HANDLED
}

public round_freezestart() {
	for(new i = 0; i < 33; i++) { 
		onfire[i] = false
	}

	return PLUGIN_CONTINUE 
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(onfire[victim]) {
		emit_sound(victim, CHAN_AUTO, "scientist/scream21.wav", 0.6, ATTN_NORM, 0, PITCH_HIGH)
		onfire[victim] = false
	}
}

public ignite_effects(id) {
	if(onfire[id]) {
		new origin[3] 
		get_user_origin(id,origin)
				
		//TE_SPRITE - additive sprite, plays 1 cycle
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte( 17 ) 
		write_coord(origin[0])  // coord, coord, coord (position) 
		write_coord(origin[1])  
		write_coord(origin[2]) 
		write_short( mflash ) // short (sprite index) 
		write_byte( 20 ) // byte (scale in 0.1's)  
		write_byte( 200 ) // byte (brightness)
		message_end()
		
		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(origin[0] - 20)// coord coord coord (position) 
		write_coord(origin[1] + 5)
		write_coord(origin[2] + 30)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(origin[0] + 5)// coord coord coord (position) 
		write_coord(origin[1] - 10)
		write_coord(origin[2] - 40)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(origin[0] - 15)// coord coord coord (position) 
		write_coord(origin[1] + 20)
		write_coord(origin[2] - 10)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		set_task(0.5, "ignite_effects", id)
	}	

	return PLUGIN_CONTINUE
}

public ignite_player(id) {
	if(onfire[id]) {
		new origin[3]
		get_user_origin(id,origin)

		dam_dealdamage(id, id, 3, "fire", 0, 0, origin[0], origin[1], origin[2])

		emit_sound(id, CHAN_AUTO, "ambience/flameburst1.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)

		set_task(0.3, "ignite_player", id)
	}

	return PLUGIN_CONTINUE
}

public fire_player(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 

	if(is_lowresources()) {
		client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
		return PLUGIN_HANDLED
	}

	new target[32]
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			onfire[targetindex] = true
			ignite_effects(targetindex)
			ignite_player(targetindex)
		}

		adminalert_v(id, "", "set fire to %s", targetname)
	}

	return PLUGIN_HANDLED 
}
