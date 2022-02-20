#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <darksurf.inc>
#include <sub_hud>

public plugin_init() {
	register_plugin("DARKSURF - *Radio","T9k","Team9000")
	register_menucmd(register_menuid("Radio Misc"),1023,"radio4cmd")
}

public surf_register_fw() {
	surf_registerskill("Extra Radio Commands", "radio", 50)
}

// Radio4 wav files 
stock const radio4_spk[9][] ={   
	"spk radio/ct_point.wav", 
	"spk radio/com_followcom.wav", 
	"spk radio/meetme.wav", 
	"spk radio/moveout.wav", 
	"spk radio/getout.wav", 
	"spk radio/ct_imhit.wav", 
	"spk radio/hitassist.wav", 
	"spk radio/circleback.wav", 
	"spk radio/locknload.wav" 
} 

// Eng 'saychats' when using Radio4 
stock const radio4_say[9][] = {    
	"I'll take the point.", 
	"Ok team, follow my command.", 
	"Meet at the rendezvous point.", 
	"Alright, lets move out.", 
	"Team, lets get out of here!", 
	"I'm Hit!", 
	"I'm Hit, Need Assistance!", 
	"Circle around back!", 
	"Lock n' Load." 
} 

public plugin_precache() {
	precache_sound(radio4_spk[0][4])
	precache_sound(radio4_spk[1][4])
	precache_sound(radio4_spk[2][4])
	precache_sound(radio4_spk[3][4])
	precache_sound(radio4_spk[4][4])
	precache_sound(radio4_spk[5][4])
	precache_sound(radio4_spk[6][4])
	precache_sound(radio4_spk[7][4])
	precache_sound(radio4_spk[8][4])
	return PLUGIN_CONTINUE 
}

public surf_change_skill(id) {
	if(surf_getskill(id, "radio") && surf_getskillon(id, "radio")) {
		if(is_user_alive(id)) {
			set_task(0.01, "radio4", id)
		}
		surf_setskillon(id, "radio", 0)
	}
}

public radio4(id) {
	new menu_body[] = "\yRadio Misc\w^n\
	^n\
	1. ^"I'll Take Point^"^n\
	2. ^"Follow my Command^"^n\
	3. ^"Meet at Rendezvous^"^n\
	4. ^"Move Out^"^n\
	5. ^"Lets get Out!^"^n\
	6. ^"I'm Hit!^"^n\
	7. ^"Hit/Assist!^"^n\
	8. ^"Circle Back^"^n\
	9. ^"Lock n Load^"^n\
	^n\
	0. Exit"
	show_menu(id,1023,menu_body) // Show the above menu on screen 
	set_menuopen(id, 1)
	return PLUGIN_HANDLED 
} 

public radio4cmd(id, key) {
	set_menuopen(id, 0)

	if(surf_getskill(id, "radio")) {
		new name[32]
		get_user_name(id,name,31)

		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				if(cs_get_user_team(targetindex) == cs_get_user_team(id)) {
					client_cmd(targetindex, radio4_spk[key])
					client_print(targetindex, print_chat, "%s (RADIO): %s",name,radio4_say[key])
				}
			}
		}
	}

	return PLUGIN_HANDLED 
} 
