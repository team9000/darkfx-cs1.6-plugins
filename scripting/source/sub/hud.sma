#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <sub_options>
#include <sub_storage>

#define SMALL_HUD_NUM 12
#define LARGE_HUD_NUM 3
#define LARGE_HUD_NUMx3 9

new smallhud[33][SMALL_HUD_NUM][512]
new Float:smallhudstart[33][SMALL_HUD_NUM]
new Float:smallhuddur[33][SMALL_HUD_NUM]

new largehud[33][LARGE_HUD_NUMx3][512]
new largehudcolor[33][LARGE_HUD_NUMx3][3]
new Float:largehudpos[33][LARGE_HUD_NUMx3][2]
new largehudeffects[33][LARGE_HUD_NUMx3]
new Float:largefxtime[33][LARGE_HUD_NUMx3][3]

new Float:largehuddur[33][LARGE_HUD_NUMx3]
new Float:largehudadded[33][LARGE_HUD_NUMx3]
new Float:largehudstart[33][5]
new largehudshowing[33][5]

/*
LARGE HUD LIST

MOTD
ADMIN MESSAGE
DARKMOD XP
NUKEM
*/

/*
SMALL HUD LIST

0 = XP/POINTS
1 = KAMIKAZE
2 = NUKEM
3 = VOTING
4 = TIMELEFT
5 = HOLIDAY
6 = AUTHENTICATE
7 = NEXTMAP
8 = EVENT
9 = DARKSURF SPEEDS/CLIMB TIMER
10 = CAMERA EXIT
11 = GODMODE WARNING
*/

new smallhud_order[SMALL_HUD_NUM] = {
6, 5, 4, 7, 0, 9, 1, 2, 3, 8, 10, 11
}

new hudcolors[7][3] = {
{60, 0, 0},
{60, 5, 0},
{40, 40, 0},
{0, 60, 0},
{20, 20, 80},
{30, 0, 30},
{30, 30, 30}
}

new menuopen[33]

public plugin_init() {
	register_plugin("Subsys - HUD","T9k","Team9000")
	set_task(0.3,"update_hud_small",0,"",0,"b")
	set_task(1.0,"update_hud_large",0,"",0,"b")

	register_cvar("amx_hudtitle","DARKMOD")
	register_cvar("amx_showhud","1")

	register_menucmd(register_menuid("DarkMod Options - On-Screen HUD"),1023,"setup_menu")

	return PLUGIN_CONTINUE
}

public options_register_fw() {
	options_registeroption("On-Screen HUD")
	options_registerfield("showhud")
	options_registerfield("hudcolor")
}

public options_menu_fw(id) {
	setup_menu(id, -1)
}

public setup_menu(id, key) {
	set_menuopen(id, 0)

	if(key == 0) {
		new value[32]
		new result = get_playervalue(id, "option_showhud", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei = !valuei
			format(value, 31, "%d", valuei)
			set_playervalue(id, "option_showhud", value)
		}
	}
	if(key == 1) {
		new value[32]
		new result = get_playervalue(id, "option_hudcolor", value, 31)
		if(result != 0) {
			new valuei = str_to_num(value)
			valuei++
			if(valuei > 6) {
				valuei = 0
			}
			format(value, 31, "%d", valuei)
			set_playervalue(id, "option_hudcolor", value)
		}
	}
	if(key == 9) {
		options_showmain(id)
		return PLUGIN_HANDLED
	}

	new value[32], showhud, hudcolor
	if(get_playervalue(id, "option_showhud", value, 31) == 0) {
		return PLUGIN_HANDLED
	}
	showhud = str_to_num(value)

	if(get_playervalue(id, "option_hudcolor", value, 31) == 0) {
		return PLUGIN_HANDLED
	}
	hudcolor = str_to_num(value)

	new menuBody[2048]
	format(menuBody,2047,"\yDarkMod Options - On-Screen HUD^n")

	new flags = 0

	format(menuBody,2047,"%s\w1. Toggle HUD ", menuBody)
	if(showhud) {
		format(menuBody,2047,"%s(\yOn\w)^n", menuBody)
	} else {
		format(menuBody,2047,"%s(\rOff\w)^n", menuBody)
	}
	flags |= (1<<0)

	format(menuBody,2047,"%s\w2. HUD Color ", menuBody)
	if(hudcolor == 0) {
		format(menuBody,2047,"%s(\rRed\w)^n", menuBody)
	} else if(hudcolor == 1) {
		format(menuBody,2047,"%s(\rOrange\w)^n", menuBody)
	} else if(hudcolor == 2) {
		format(menuBody,2047,"%s(\rYellow\w)^n", menuBody)
	} else if(hudcolor == 3) {
		format(menuBody,2047,"%s(\rGreen\w)^n", menuBody)
	} else if(hudcolor == 4) {
		format(menuBody,2047,"%s(\rBlue\w)^n", menuBody)
	} else if(hudcolor == 5) {
		format(menuBody,2047,"%s(\rPurple\w)^n", menuBody)
	} else {
		format(menuBody,2047,"%s(\rWhite\w)^n", menuBody)
	}
	flags |= (1<<1)

	format(menuBody,2047,"%s^n", menuBody)

	format(menuBody,2047,"%s\r0. Back", menuBody)
	flags |= (1<<9)

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}

public plugin_natives() {
	register_library("sub_hud")

	register_native("myhud_small","myhud_small_impl")
	register_native("myhud_large","myhud_large_impl")
	register_native("set_menuopen","set_menuopen_impl")
}

public get_hudnum(channel, num) {
	return (channel-2)*LARGE_HUD_NUM+num
}

public client_connect(id) {
	for(new i = 2; i <= 4; i++) {
		largehudshowing[id][i] = -1
		for(new j = 0; j < LARGE_HUD_NUM; j++) {
			largehuddur[id][get_hudnum(i, j)] = 0.0
		}
	}
	for(new i = 0; i < LARGE_HUD_NUM; i++) {
		smallhuddur[id][i] = 0.0
	}
	menuopen[id] = 0
}

public myhud_small_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")

	if(get_param(2) == 0) {
		for(new i = 1; i < 33; i++) {
			get_string(3, smallhud[i][get_param(1)], 511)
			smallhuddur[i][get_param(1)] = get_param_f(4)
			smallhudstart[i][get_param(1)] = get_gametime()
		}
	} else {
		get_string(3, smallhud[get_param(2)][get_param(1)], 511)
		smallhuddur[get_param(2)][get_param(1)] = get_param_f(4)
		smallhudstart[get_param(2)][get_param(1)] = get_gametime()
	}

	return 1
}

public myhud_large_impl(id, numparams) {
	if(numparams != 13)
		return log_error(10, "Bad native parameters")

	new message[512]
	get_string(1, message, 511)

	new pid = get_param(2)
	new Float:holdtime = get_param_f(3)
	new channel = get_param(4)
	new colorr = get_param(5)
	new colorg = get_param(6)
	new colorb = get_param(7)
	new effects = get_param(8)
	new Float:posx = get_param_f(9)
	new Float:posy = get_param_f(10)
	new Float:fxhold = get_param_f(11)
	new Float:fadein = get_param_f(12)
	new Float:fadeout = get_param_f(13)

	if(pid == 0) {
		for(new i = 0; i < 33; i++) {
			for(new j = 0; j < LARGE_HUD_NUM; j++) {
				new hudnum = get_hudnum(channel, j)
				if(largehuddur[i][hudnum] == 0) {
					copy(largehud[i][hudnum], 511, message)

					largehudcolor[i][hudnum][0] = colorr
					largehudcolor[i][hudnum][1] = colorg
					largehudcolor[i][hudnum][2] = colorb
					largehudpos[i][hudnum][0] = posx
					largehudpos[i][hudnum][1] = posy
					largehudeffects[i][hudnum] = effects
					largefxtime[i][hudnum][0] = fxhold
					largefxtime[i][hudnum][1] = fadein
					largefxtime[i][hudnum][2] = fadeout

					largehuddur[i][hudnum] = holdtime
					largehudadded[i][hudnum] = get_gametime()

					break
				}
			}
		}
	} else {
		for(new i = 0; i < LARGE_HUD_NUM; i++) {
			new hudnum = get_hudnum(channel, i)
			if(largehuddur[pid][hudnum] == 0) {
				copy(largehud[pid][hudnum], 511, message)

				largehudcolor[pid][hudnum][0] = colorr
				largehudcolor[pid][hudnum][1] = colorg
				largehudcolor[pid][hudnum][2] = colorb
				largehudpos[pid][hudnum][0] = posx
				largehudpos[pid][hudnum][1] = posy
				largehudeffects[pid][hudnum] = effects
				largefxtime[pid][hudnum][0] = fxhold
				largefxtime[pid][hudnum][1] = fadein
				largefxtime[pid][hudnum][2] = fadeout

				largehuddur[pid][hudnum] = holdtime
				largehudadded[pid][hudnum] = get_gametime()

				break
			}
		}
	}

	return 1
}

public set_menuopen_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new onoff = get_param(2)

	menuopen[id] = onoff

	return onoff
}

public update_hud_large() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(is_user_bot(targetindex) || is_user_hltv(targetindex)) {
				continue
			}
			for(new i = 2; i <= 4; i++) {
				if(largehudshowing[targetindex][i] != -1) {
					if(largehudstart[targetindex][i]+largehuddur[targetindex][largehudshowing[targetindex][i]] <= get_gametime()) {
						largehuddur[targetindex][largehudshowing[targetindex][i]] = 0.0
						largehudshowing[targetindex][i] = -1
					}
				}

				if(largehudshowing[targetindex][i] == -1) {
					new toppriority = -1
					for(new j = 0; j < LARGE_HUD_NUM; j++) {
						new hudnum = get_hudnum(i, j)
						if(largehuddur[targetindex][hudnum] > 0) {
							if(toppriority == -1) {
								toppriority = hudnum
							} else if(largehudadded[targetindex][hudnum] < largehudadded[targetindex][toppriority]) {
								toppriority = hudnum
							}
						}
					}

					if(toppriority != -1) {
						largehudstart[targetindex][i] = get_gametime()
						largehudshowing[targetindex][i] = toppriority

						set_hudmessage(largehudcolor[targetindex][toppriority][0], largehudcolor[targetindex][toppriority][1], largehudcolor[targetindex][toppriority][2], largehudpos[targetindex][toppriority][0], largehudpos[targetindex][toppriority][1], largehudeffects[targetindex][toppriority], largefxtime[targetindex][toppriority][0], largehuddur[targetindex][toppriority], largefxtime[targetindex][toppriority][1], largefxtime[targetindex][toppriority][2], i)
						show_hudmessage(targetindex,largehud[targetindex][toppriority])
					}
				}
			}
		}
	}
}

public update_hud_small() {
	new message[2048] = ""

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(is_user_bot(targetindex)) {
				continue
			}

			new value[32], showhud = 1, hudcolor = 0
			if(get_playervalue(targetindex, "option_showhud", value, 31) != 0) {
				showhud = str_to_num(value)
			}

			if(get_playervalue(targetindex, "option_hudcolor", value, 31) != 0) {
				hudcolor = str_to_num(value)
			}

			if(showhud && get_cvar_num("amx_showhud")) {
				if(menuopen[targetindex]) {
					set_hudmessage(hudcolors[hudcolor][0], hudcolors[hudcolor][1], hudcolors[hudcolor][2], 0.05, 0.20, 0, 0.0, 2.0, 0.0, 0.0, 2)
					show_hudmessage(targetindex,"")
				} else {
					new hudtitle[64]
					get_cvar_string("amx_hudtitle", hudtitle, 63)
					format(message, 2047, "%s STATUS^n--------------^n", hudtitle)
					for(new i = 0; i < SMALL_HUD_NUM; i++) {
						new hudnum = smallhud_order[i]
						if((smallhudstart[targetindex][hudnum]+smallhuddur[targetindex][hudnum] > get_gametime() || smallhuddur[targetindex][hudnum] == -1) && !equal(smallhud[targetindex][hudnum], "")) {
							format(message, 2047, "%s%s", message, smallhud[targetindex][hudnum])
						}
					}

					set_hudmessage(hudcolors[hudcolor][0], hudcolors[hudcolor][1], hudcolors[hudcolor][2], 0.05, 0.20, 0, 0.0, 2.0, 0.0, 0.0, 2)
					show_hudmessage(targetindex,message)
				}
			}
		}
	}
}
