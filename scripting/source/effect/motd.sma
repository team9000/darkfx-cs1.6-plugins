#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>

#define SPEED 60*2
#define MESSAGES 3
new messages[MESSAGES][] = {
	"all 200 0 0 ^"Welcome to motdname^nJoin our community at www.team9000.net!^"",
	"all 0 175 0 ^"Did you know Team9000 runs tons of different servers?^nSurf, Fun, KZ, Pub, L4d2, and More!^nCheck out www.team9000.net for details!^"",
	"all 200 120 0 ^"We give away free schwag every week in the Team9000 Contest!^nFind out more at http://team9000.net/contest^""
}

new usedmessages[MESSAGES]
new totalused

public plugin_init() {
	register_plugin("Effect - MOTD","T9k","Team9000")
	set_task(float(SPEED),"motd_msg",0,"",0,"b") 

	register_cvar("amx_motdname", "DarkMod")
	for(new i = 0; i < MESSAGES; i++) {
		usedmessages[i] = 0
	}
	totalused = 0

	return PLUGIN_CONTINUE
}

public motd_msg() {
	new show = 0

	new always = 1
	while(always) {
		if(totalused == MESSAGES) {
			for(new i = 0; i < MESSAGES; i++) {
				usedmessages[i] = 0
			}
			totalused = 0
		}

		do {
			show = random_num(0, MESSAGES-1)
		} while(usedmessages[show])
		totalused++
		usedmessages[show] = 1

		new ident[16], sred[8], sgreen[8], sblue[8], message[512]
		parse(messages[show], ident, 15, sred, 7, sgreen, 7, sblue, 7, message, 511)

		new server_ident[16], motdname[64]
		get_cvar_string("amx_server_ident_motdset", server_ident, 15)
		get_cvar_string("amx_motdname", motdname, 63)
		if(equal(ident, "all") || equal(ident, server_ident)) {
			new ired = str_to_num(sred)
			new igreen = str_to_num(sgreen)
			new iblue = str_to_num(sblue)
			replace_all(message, 511, "motdname", motdname)
			myhud_large(message, 0, 10.0, 3, ired, igreen, iblue, 2, -1.0, 0.30, 0.7, 0.03, 0.5)
			break
		}
	}
}
