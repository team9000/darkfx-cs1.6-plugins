#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <fun>
#include <sub_handler>
#include <sub_damage>
#include <sub_roundtime>
#include <sub_respawn>
#include <sub_disqualify>
#include <sub_lowresources>

new bloodspray, blooddrop
new light, smoke, white
new m_blueflare2, mflash
new isrocket[33], rocket_z[33], slapping[33]
new llama[33]

#define NUM_LLAMAWORDS 4
new llamawords[NUM_LLAMAWORDS][] = {
	"Ooorgle!",
	"Bleeeat!",
	"Brawwrr!",
	"Muuuuuh!"
}
new llamasound[NUM_LLAMAWORDS][] = {
	"team9000/llama/ooorgle.wav",
	"team9000/llama/bleeeat.wav",
	"team9000/llama/brawwrr.wav",
	"misc/cow.wav"
}

public plugin_init() {
	register_plugin("Admin Punish","T9k","Team9000")
	register_concmd("amx_slay","admin_slay",LVL_SLAY,"<target> [1=normal|2=lightning|3=bloody|4=explosion] - Slays a player")
	register_concmd("amx_slap","admin_slap",LVL_SLAP,"<target> [damage=0] [1=normal|2=bloody] - Slaps a player")
	register_concmd("amx_disarm","admin_disarm",LVL_DISARM,"<target> - Disarms a player of all weapons (except knife)")
	register_concmd("amx_flash","admin_flash",LVL_FLASH,"<target> - Flashes a players screen")
	register_concmd("amx_stack","admin_stack",LVL_STACK,"<target> [1=on|2=under|3=beside|4=around] - Stacks everyone on a player")
	register_concmd("amx_rocket","admin_rocket",LVL_ROCKET,"<target> - Rockets a player")
	register_concmd("amx_uberslap","admin_uberslap",LVL_UBERSLAP,"<target> - Uberslaps a player")
	register_concmd("amx_quit","admin_quit",LVL_QUIT,"<target> - Forces a player to quit CS")
	register_concmd("amx_llama","admin_llama",LVL_LLAMA,"<target> <1,0> - Forces a player to talk like a llama")

	register_clcmd("say","handle_say")
	register_clcmd("say_team","handle_say")
	return PLUGIN_CONTINUE
}

public plugin_precache() {
	if(!is_lowresources()) {
		bloodspray = precache_model("sprites/bloodspray.spr")
		blooddrop = precache_model("sprites/blood.spr")
		light = precache_model("sprites/lgtning.spr")
		smoke = precache_model("sprites/steam1.spr")
		white = precache_model("sprites/white.spr")
		m_blueflare2 = precache_model("sprites/blueflare2.spr")
		mflash = precache_model("sprites/muzzleflash.spr")
		precache_sound("team9000/thunder.wav")
		precache_sound("team9000/headshot.wav")
		precache_sound("weapons/rocketfire1.wav")
		precache_sound("weapons/rocket1.wav")
		for(new i = 0; i < NUM_LLAMAWORDS; i++)
			precache_sound(llamasound[i])
	}

	return PLUGIN_CONTINUE
} 

public admin_slay(id,level,cid) {
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new mode[32]
	read_argv(2,mode,31)

	if(str_to_num(mode) != 1) {
		if(is_lowresources()) {
			client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
			return PLUGIN_HANDLED
		}
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(get_upperhealth()) {
				set_user_health(targetindex, 1+256000)
			} else {
				set_user_health(targetindex, 1)
			}
			dam_dealdamage(targetindex, targetindex, 100000, "slay", 0, 1, 0, 0, 0)

			new origin[3]
			get_user_origin(targetindex,origin)
			if(str_to_num(mode) == 2) {
				new srco[3]
				srco[0]=origin[0]+150
				srco[1]=origin[1]+150
				srco[2]=origin[2]+400

				//Lightning 
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 0 ) 
				write_coord(srco[0]) 
				write_coord(srco[1]) 
				write_coord(srco[2]) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2]) 
				write_short( light ) 
				write_byte( 1 ) // framestart 
				write_byte( 5 ) // framerate 
				write_byte( 2 ) // life 
				write_byte( 20 ) // width 
				write_byte( 30 ) // noise 
				write_byte( 200 ) // r, g, b 
				write_byte( 200 ) // r, g, b 
				write_byte( 200 ) // r, g, b 
				write_byte( 200 ) // brightness 
				write_byte( 200 ) // speed 
				message_end()

				//Sparks 
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
				write_byte( 9 ) 
				write_coord( origin[0] ) 
				write_coord( origin[1] ) 
				write_coord( origin[2] ) 
				message_end()

				//Smoke     
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 5 ) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2]) 
				write_short( smoke ) 
				write_byte( 10 )  
				write_byte( 10 )  
				message_end()

				emit_sound(targetindex,CHAN_ITEM, "team9000/thunder.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			} else if(str_to_num(mode) == 3) {
				//LAVASPLASH 
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 10 ) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2]) 
				message_end() 

				emit_sound(targetindex,CHAN_ITEM, "team9000/headshot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			} else if(str_to_num(mode) == 4) {
				// blast circles 
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 21 ) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2] + 16) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2] + 1936) 
				write_short( white ) 
				write_byte( 0 ) // startframe 
				write_byte( 0 ) // framerate 
				write_byte( 2 ) // life 
				write_byte( 16 ) // width 
				write_byte( 0 ) // noise 
				write_byte( 188 ) // r 
				write_byte( 220 ) // g 
				write_byte( 255 ) // b 
				write_byte( 255 ) //brightness 
				write_byte( 0 ) // speed 
				message_end()

				//Explosion2 
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 12 ) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2]) 
				write_byte( 188 ) // byte (scale in 0.1's) 
				write_byte( 10 ) // byte (framerate) 
				message_end()

				//Smoke 
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte( 5 ) 
				write_coord(origin[0]) 
				write_coord(origin[1]) 
				write_coord(origin[2]) 
				write_short( smoke ) 
				write_byte( 2 )  
				write_byte( 10 )  
				message_end()
			}
		}

		adminalert_v(id, "", "slayed %s", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_slap(id,level,cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)
	new damage[32]
	read_argv(2,damage,31)
	new mode[32]
	read_argv(3,mode,31)

	if(str_to_num(mode) == 2) {
		if(is_lowresources()) {
			client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
			return PLUGIN_HANDLED
		}
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			user_slap(targetindex, 0)
			dam_dealdamage(targetindex, targetindex, str_to_num(damage), "slap", 0, 1, 0, 0, 0)

			disqualify_now(targetindex, 4)

			if(str_to_num(mode) == 2) {
				new origin[3]
				get_user_origin(targetindex,origin)
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte(115) 
				write_coord(origin[0])
				write_coord(origin[1]) 
				write_coord(origin[2] +25) 
				write_short(bloodspray) 
				write_short(blooddrop) 
				write_byte(70) // color index 
				write_byte(15) // size 
				message_end()
			} 
		}

		new damagetext[32] = ""
		if(str_to_num(damage)) {
			format(damagetext, 31, " with %d damage", str_to_num(damage))
		}
		adminalert_v(id, "", "slapped %s%s", targetname, damagetext)
	}

	return PLUGIN_HANDLED
}

public admin_disarm(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			strip_user_weapons(targetindex)
		}

		adminalert_v(id, "", "disarmed %s", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_flash(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},targetindex) 
			write_short( 1<<15 ) 
			write_short( 1<<10 )
			write_short( 1<<12 )
			write_byte( 255 ) 
			write_byte( 255 ) 
			write_byte( 255 ) 
			write_byte( 255 ) 
			message_end()
		}

		adminalert_v(id, "", "sent a flashbang to %s", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_stack(id,level,cid){ 
	if(!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 
    
	new target[32]
	read_argv(1,target,31)
	new arg2[32]
	read_argv(2,arg2,1)

	new player, targetname[33]
	if(cmd_targetset(id, target, 7|16|32, targetname, 32)) {
		player = cmd_target()

		new origin[3]
		get_user_origin(player, origin)

		new offsetx, offsety, offsetz, originalx, num = 0
		switch(str_to_num(arg2)) {
			case 2: offsetz = -100
			case 3: offsety = 40
			case 4: {
					offsetx = 40
					offsety = 40
					originalx = origin[0]
				}
			default: offsetz = 100
		}

		new targetindex, targetname2[33]
		if(cmd_targetset(id, "*", 7, targetname2, 32)) {
			while((targetindex = cmd_target())) {
				if(targetindex == player)
					continue

				if(str_to_num(arg2) != 4) {
					origin[1] += offsety
					origin[2] += offsetz
				} else {
					if(num == 4) {
						origin[0] = originalx
						origin[1] += offsety
					} else {
						origin[0] += offsetx
					}
					num++
				}
				set_user_origin(targetindex, origin)
				disqualify_now(targetindex, 5)
			}

			switch(str_to_num(arg2)){ 
				case 2: adminalert_v(id, "", "stacked all players under %s", targetname)
				case 3: adminalert_v(id, "", "stacked all players beside %s", targetname)
				case 4: adminalert_v(id, "", "stacked all players around %s", targetname)
				default: adminalert_v(id, "", "stacked all players on %s", targetname)
			}
		}
	}

	return PLUGIN_HANDLED  
}

public rocket_liftoff(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		handle_gravity(3, id, -0.5)

		new Float:velocity[3] = {0.0, 0.0, 250.0}
		entity_set_vector(id, EV_VEC_velocity, velocity)

		emit_sound(id, CHAN_VOICE, "weapons/rocket1.wav", 1.0, 0.5, 0, PITCH_NORM)
		rocket_effects(id)
		set_task(0.2, "start_detect", id)
	}
	
	return PLUGIN_CONTINUE
}

public start_detect(id) {
	isrocket[id] = 1
}

public rocket_effects(id) {
	if(is_user_connected(id) && is_user_alive(id) && isrocket[id]) {
		new vorigin[3]
		get_user_origin(id,vorigin)

		//Draw Trail and effects
		
		//TE_SPRITETRAIL - line of moving glow sprites with gravity, fadeout, and collisions
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(15)
		write_coord(vorigin[0]) // coord, coord, coord (start)
		write_coord(vorigin[1])
		write_coord(vorigin[2])
		write_coord(vorigin[0]) // coord, coord, coord (end)
		write_coord(vorigin[1])
		write_coord(vorigin[2] - 30)
		write_short(m_blueflare2) // short (sprite index)
		write_byte(5) // byte (count)
		write_byte(1) // byte (life in 0.1's)
		write_byte(1)  // byte (scale in 0.1's)
		write_byte(10) // byte (velocity along vector in 10's)
		write_byte(5)  // byte (randomness of velocity in 10's)
		message_end()
		
		//TE_SPRITE - additive sprite, plays 1 cycle
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(17)
		write_coord(vorigin[0])  // coord, coord, coord (position)
		write_coord(vorigin[1])
		write_coord(vorigin[2] - 30)
		write_short(mflash) // short (sprite index)
		write_byte(15) // byte (scale in 0.1's)
		write_byte(255) // byte (brightness)
		message_end()
		
		set_task(0.2, "rocket_effects" , id)
	}
	
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	if(isrocket[id]) {
		rocket_explode(id)
	}
	handle_gravity_off(3, id)
	handle_speed_off(2, id)
	handle_speed_off(3, id)
	slapping[id] = 0
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(isrocket[victim]) {
		rocket_explode(victim)
	}
	handle_gravity_off(3, victim)
	handle_speed_off(2, victim)
	handle_speed_off(3, victim)
	slapping[victim] = 0
}

public client_PreThink(id) {
	if(id && is_user_connected(id)) {
		if(isrocket[id]) {
			new vorigin[3]
			get_user_origin(id,vorigin)

			if(vorigin[2] == rocket_z[id]) {
				rocket_explode(id)
			}

			rocket_z[id] = vorigin[2]
		}
	}
}

public round_freezestart_e() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(isrocket[targetindex]) {
				rocket_explode(targetindex)
			}
			handle_speed_off(3, targetindex)
			slapping[targetindex] = 0
		}
	}
}

public rocket_explode(id) {
	new vec1[3]
	get_user_origin(id,vec1)

	isrocket[id] = 0

	// blast circles
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte(21)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] - 10)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1910)
	write_short(white)
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(2) // life
	write_byte(16) // width
	write_byte(0 ) // noise
	write_byte(188) // r
	write_byte(220) // g
	write_byte(255) // b
	write_byte(255) //brightness
	write_byte(0) // speed
	message_end()

	//Explosion2
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(12)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte(188) // byte (scale in 0.1's)
	write_byte(10) // byte (framerate)
	message_end()

	//rsmoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte(5)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(smoke)
	write_byte(2)
	write_byte(10)
	message_end()

	if(get_upperhealth()) {
		set_user_health(id, 1+256000)
	} else {
		set_user_health(id, 1)
	}

	dam_dealdamage(id, id, 100000, "rocket", 1, 0, vec1[0], vec1[1], vec1[2])

	//stop_sound
	emit_sound(id, CHAN_VOICE, "weapons/rocket1.wav", 0.0, 0.0, (1<<5), PITCH_NORM)

	handle_gravity_off(3, id)
	handle_speed_off(2, id)
	
	return PLUGIN_CONTINUE
}

public admin_rocket(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	if(is_lowresources()) {
		client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
		return PLUGIN_HANDLED
	}

	new target[32] 
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			emit_sound(targetindex,CHAN_WEAPON ,"weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			handle_speed(2, targetindex, 0.0, 0)
			set_task(1.2, "rocket_liftoff", targetindex)
			disqualify_now(targetindex, 6)
		}

		adminalert_v(id, "", "turned %s into a rocket!", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_uberslap(id,level,cid){
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			strip_user_weapons(targetindex)
			set_task(0.1, "slap_player", targetindex)
			handle_speed(3, targetindex, 0.0, 0)
			slapping[targetindex] = 1
			disqualify_now(targetindex, 7)
		}

		adminalert_v(id, "", "uberslapped %s", targetname)
	}

	return PLUGIN_HANDLED
}

public slap_player(id) {
	if(is_user_connected(id) && slapping[id]) {
		if((get_upperhealth() && get_user_health(id) > 256003) || (!get_upperhealth() && get_user_health(id) > 1)) {
			user_slap(id, 0)
			dam_dealdamage(id, id, 2, "uberslap", 0, 1, 0, 0, 0)
			set_task(0.1, "slap_player", id)
		} else {
			slapping[id] = 0
		}
	}

	return PLUGIN_CONTINUE
}

public admin_quit(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex, "quit")
		}

		adminalert_v(id, "", "made %s quit CS", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_llama(id,level,cid){
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31)
	new arg[32] 
	read_argv(2,arg,31)

	new argi = (str_to_num(arg) == 1 ? 1 : 0)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			llama[targetindex] = argi
		}

		if(argi) {
			adminalert_v(id, "", "llamaized %s", targetname)
		} else {
			adminalert_v(id, "", "unllamaized %s", targetname)
		}
	}

	return PLUGIN_HANDLED
}

public handle_say(id) {
	if(!llama[id]) {
		return PLUGIN_CONTINUE
	}

	new Speech[256]
	read_args(Speech,256)
	remove_quotes(Speech)

	for(new i = 0; i < NUM_LLAMAWORDS; i++) {
		if(equal(Speech, llamawords[i])) {
			return PLUGIN_CONTINUE
		}
	}

	new randnum = random_num(0, NUM_LLAMAWORDS-1)
	client_cmd(id, "say %s", llamawords[randnum])
	if(!is_lowresources()) {
		client_cmd(id, "spk %s", llamasound[randnum])
	}
	return PLUGIN_HANDLED
}
