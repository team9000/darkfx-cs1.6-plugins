#include <amxmodx>
#include <sub_stocks>
#include <sub_damage>
#include <sub_lowresources>

#define TE_BEAMPOINTS 0

new m_spriteTexture

public plugin_init() {
	register_plugin("Effect - Death Beams","T9k","Team9000")
}

public plugin_precache() {
	if(is_lowresources()) return;
	m_spriteTexture = precache_model("sprites/zbeam4.spr")
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(is_lowresources()) return;
	if(victim != attacker && victim && attacker) {
		new a_origin[3]
		get_user_origin(attacker,a_origin)
		new v_origin[3]
		get_user_origin(victim,v_origin)

		new attacker_team = get_user_team(attacker)

		new players[32], inum
		get_players(players, inum, "b")
		for(new i = 0; i < inum; i++) {
			message_begin(MSG_ONE, SVC_TEMPENTITY,{0,0,0},players[i])
			write_byte(TE_BEAMPOINTS)
			write_coord(a_origin[0])
			write_coord(a_origin[1])
			write_coord(a_origin[2])
			write_coord(v_origin[0])
			write_coord(v_origin[1])
			write_coord(v_origin[2])
			write_short(m_spriteTexture)
			write_byte(1)   // framestart
			write_byte(1)   // framerate
			write_byte(100) // life in 0.1's
			write_byte(10)  // width
			write_byte(0)   // noise

			if(attacker_team == 1) {		// Terrorist
				write_byte( 255 )	// red
				write_byte( 0 )		// green
				write_byte( 0 )		// blue
			} else {			// Counter-terrorist
				write_byte( 0 )		// red
				write_byte( 0 )		// green
				write_byte( 255 )	// blue
			}

			write_byte(130) // brightness
			write_byte(0)   // speed
			message_end()
		}
	}
}
