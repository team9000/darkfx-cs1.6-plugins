#include <amxmodx>
#include <sub_stocks>
#include <sub_damage>
#include <sub_respawn>
#include <sub_lowresources>

#define TE_BLOODSPRITE		115
#define	TE_BLOODSTREAM		101
#define TE_MODEL		106
#define TE_WORLDDECAL		116
/*
//new mdl_gib_flesh
new mdl_gib_head
//new mdl_gib_legbone
new mdl_gib_lung
new mdl_gib_meat
//new mdl_gib_spine
*/
new spr_blood_drop
new spr_blood_spray

public plugin_init() {
	register_plugin("Effect - Gore","T9k","Team9000")

	set_task(1.0,"event_blood",0,"",0,"b")

	return PLUGIN_CONTINUE
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(is_user_bot(victim)) return PLUGIN_CONTINUE

	new origin[3]
	get_user_origin(victim,origin)
	fx_blood(origin)
	fx_blood_small(origin,10)

	return PLUGIN_CONTINUE
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(is_user_bot(victim)) return

	new origin[3]
	get_user_origin(victim,origin)
	
	if(headshot) {
		fx_headshot(origin)
	} else if(get_upperhealth() || containi(weapon, "gren") != -1 || containi(weapon, "awp") != -1) {
		fx_gib_explode(origin,5)
		fx_blood_large(origin,3)
		fx_blood_small(origin,20)
	}
}

public event_blood() {
	new targetindex, targetname[33], origin[3]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(is_user_bot(targetindex)) continue
			if(get_user_health(targetindex) < 20 || (get_upperhealth() && get_user_health(targetindex) < 256020)) {
				get_user_origin(targetindex,origin)
				fx_bleed(origin)
				fx_blood_small(origin,5)
			}
		}
	}
}

public fx_blood(origin[3]) {
	if(!is_lowresources()) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSPRITE)
		write_coord(origin[0]+random_num(-20,20))
		write_coord(origin[1]+random_num(-20,20))
		write_coord(origin[2]+random_num(-20,20))
		write_short(spr_blood_spray)
		write_short(spr_blood_drop)
		write_byte(248) // color index
		write_byte(10) // size
		message_end()
	}
}

public fx_bleed(origin[3]) {
	if(!is_lowresources()) {
		// Blood spray
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+10)
		write_coord(random_num(-100,100)) // x
		write_coord(random_num(-100,100)) // y
		write_coord(random_num(-10,10)) // z
		write_byte(70) // color
		write_byte(random_num(50,100)) // speed
		message_end()
	}
}

static fx_blood_small(origin[3],num) {
	if(!is_lowresources()) {
		// Blood decals
		static const blood_small[7] = {190,191,192,193,194,195,197}
		
		// Small splash
		for (new j = 0; j < num; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(origin[0]+random_num(-100,100))
			write_coord(origin[1]+random_num(-100,100))
			write_coord(origin[2]-36)
			write_byte(blood_small[random_num(0,6)]) // index
			message_end()
		}
	}
}

static fx_blood_large(origin[3],num) {
	if(!is_lowresources()) {
		// Blood decals
		static const blood_large[2] = {204,205}
	
		// Large splash
		for (new i = 0; i < num; i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(origin[0]+random_num(-50,50))
			write_coord(origin[1]+random_num(-50,50))
			write_coord(origin[2]-36)
			write_byte(blood_large[random_num(0,1)]) // index
			message_end()
		}
	}
}

static fx_gib_explode(origin[3],num) {
/*	if(!is_lowresources()) {
		new x, y, z
	
		// Gib explosion
		// Head
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_head)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
		
		// Spine
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
		
		// Lung
		for(new i = 0; i < random_num(1,2); i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_MODEL)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_coord(random_num(-100,100))
			write_coord(random_num(-100,100))
			write_coord(random_num(100,200))
			write_angle(random_num(0,360))
			write_short(mdl_gib_lung)
			write_byte(0) // bounce
			write_byte(500) // life
			message_end()
		}
		
		// Parts, 5 times
		for(new i = 0; i < 5; i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_MODEL)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_coord(random_num(-100,100))
			write_coord(random_num(-100,100))
			write_coord(random_num(100,200))
			write_angle(random_num(0,360))
			write_short(mdl_gib_meat)
			write_byte(0) // bounce
			write_byte(500) // life
			message_end()
		}
		
		// Blood
		for(new i = 0; i < num; i++) {
			x = random_num(-100,100)
			y = random_num(-100,100)
			z = random_num(0,100)
			for(new j = 0; j < 5; j++) {
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_BLOODSPRITE)
				write_coord(origin[0]+(x*j))
				write_coord(origin[1]+(y*j))
				write_coord(origin[2]+(z*j))
				write_short(spr_blood_spray)
				write_short(spr_blood_drop)
				write_byte(248) // color index
				write_byte(15) // size
				message_end()
			}
		}
	}*/
}

public fx_headshot(origin[3]) {
	if(!is_lowresources()) {
		// Blood spevent_bloodray, 5 times
		for (new i = 0; i < 5; i++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(101)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2]+30)
			write_coord(random_num(-20,20)) // x
			write_coord(random_num(-20,20)) // y
			write_coord(random_num(50,300)) // z
			write_byte(70) // color
			write_byte(random_num(100,200)) // speed
			message_end()
		}
	}
}

public plugin_precache() {
	if(!is_lowresources()) {
		spr_blood_drop = precache_model("sprites/blood.spr")
		spr_blood_spray = precache_model("sprites/bloodspray.spr")
/*
//		mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
		mdl_gib_head = precache_model("models/GIB_Skull.mdl")
//		mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
		mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
		mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
//		mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")*/
	}
}
