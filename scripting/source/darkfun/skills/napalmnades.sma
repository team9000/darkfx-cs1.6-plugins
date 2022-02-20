#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <sub_roundtime>
#include <sub_damage>

new smoke, mflash
new bool:onfire[33]
new fireattacker[33]

public plugin_init() {
	register_plugin("DFX-MOD - Napalm Nades","MM","doubleM")
	register_event("Damage","damage","b","0!0","2!0")
}

public darkfx_register_fw() {
	dfx_registerskill("Napalm Granades", "napalm")
}

public plugin_precache() {
	mflash = precache_model("sprites/muzzleflash.spr") 
	smoke = precache_model("sprites/steam1.spr")
	precache_sound("ambience/flameburst1.wav")
	precache_sound("scientist/scream21.wav")
	precache_sound("scientist/scream07.wav")
}

public damage() {
	new weapon, bhit
	new iVictim = read_data(0)
	if(iVictim && is_user_connected(iVictim)) {
		new iAttacker = get_user_attacker(iVictim, weapon, bhit)
		if(iAttacker && is_user_connected(iAttacker)) {
			new iDamage = read_data(2)

			if(weapon == CSW_HEGRENADE) {
				new skill = dfx_getskill(iAttacker, "napalm")
				if(random_num(1, 4) < skill) {
					if(iDamage > 80)
						fire_player(iVictim, iAttacker, 10.0)
					else if(iDamage > 50)
						fire_player(iVictim, iAttacker, 4.0)
					else if(iDamage > 30)
						fire_player(iVictim, iAttacker, 2.5)
				}
			}
		}
	}
}

public fire_player(id, attacker, Float:time) {
	set_task(time, "unfire_player", id)

	onfire[id] = true
	fireattacker[id] = attacker
	ignite_effects(id)
	ignite_player(id)
}

public unfire_player(id) {
	onfire[id] = false
	fireattacker[id] = 0
}


public ignite_effects(kIndex) {
	if (onfire[kIndex]) {
		new korigin[3] 
		get_user_origin(kIndex,korigin)
				
		//TE_SPRITE - additive sprite, plays 1 cycle
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(17) 
		write_coord(korigin[0])  // coord, coord, coord (position) 
		write_coord(korigin[1])  
		write_coord(korigin[2]) 
		write_short( mflash ) // short (sprite index) 
		write_byte( 20 ) // byte (scale in 0.1's)  
		write_byte( smoke ) // byte (brightness)
		message_end()
		
		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(korigin[0] - 20)// coord coord coord (position) 
		write_coord(korigin[1] + 5)
		write_coord(korigin[2] + 30)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(korigin[0] + 5)// coord coord coord (position) 
		write_coord(korigin[1] - 10)
		write_coord(korigin[2] - 40)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		//Smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte( 5 )
		write_coord(korigin[0] - 15)// coord coord coord (position) 
		write_coord(korigin[1] + 20)
		write_coord(korigin[2] - 10)
		write_short( smoke )// short (sprite index)
		write_byte( 20 ) // byte (scale in 0.1's)
		write_byte( 15 ) // byte (framerate)
		message_end()

		if(is_user_alive(kIndex)) {
			set_task(0.2, "ignite_effects", kIndex)		
		} else {
			emit_sound(kIndex,CHAN_AUTO, "scientist/scream21.wav", 0.6, ATTN_NORM, 0, PITCH_HIGH)
			onfire[kIndex] = false
		}
	}	
	return PLUGIN_CONTINUE
}

public ignite_player(kIndex) {	
	if (is_user_alive(kIndex) && onfire[kIndex]) {
		new korigin[3] 
		new players[32], inum = 0
		new pOrigin[3]
		get_user_origin(kIndex,korigin)
		
		dam_dealdamage(kIndex, fireattacker[kIndex], 2, "napalm_grenade", 0, 0, korigin[0], korigin[1], korigin[2])

		message_begin(MSG_ONE, get_user_msgid("Damage"), {0,0,0}, kIndex) 
		write_byte(30) // dmg_save
		write_byte(30) // dmg_take 
		write_long(1<<21) // visibleDamageBits 
		write_coord(korigin[0]) // damageOrigin.x 
		write_coord(korigin[1]) // damageOrigin.y
		write_coord(korigin[2]) // damageOrigin.z 
		message_end()
				
		//create some sound
		emit_sound(kIndex,CHAN_ITEM, "ambience/flameburst1.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)
				
		//Ignite Others				
		get_players(players,inum,"a")
		for(new i = 0 ;i < inum; ++i) {									
			get_user_origin(players[i],pOrigin)				
			if(get_distance(korigin,pOrigin) < 100) {
				if(!onfire[players[i]]) {			
					emit_sound(players[i],CHAN_WEAPON ,"scientist/scream07.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
					fire_player(players[i], fireattacker[kIndex], 4.0)
				}					
			}
		}			
		
		set_task(0.3, "ignite_player", kIndex)		
	}	
		
	return PLUGIN_CONTINUE
}

public round_freezestart() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			unfire_player(targetindex)
		}
	}
}
