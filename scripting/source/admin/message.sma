#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <sub_storage>

#define NEED_COLORNAMES
#define NEED_COLORRGBS
#include <sub_const>

new adcolors[33]

new aiSayType[33] = { 0, ... }
new room[33] = { 0, ... }

public plugin_init() { 
	register_plugin("Admin Message", "T9k", "Team9000") 

	register_clcmd("allsaymode",	"admin_saymode",	LVL_ALLSAY,	"<message> - Allows you to adminchat while in-game")
	register_clcmd("adminsaymode",	"admin_saymode",	LVL_ADMINSAY,	"<message> - Allows you to adminchat while in-game") 
	register_clcmd("psaymode",	"admin_saymode",	LVL_PSAY,	"<user> <message> - Allows you to adminchat while in-game") 
	register_clcmd("tsaymode",	"admin_saymode",	LVL_TSAY,	"[color] <message> - Allows you to adminchat while in-game") 
	register_clcmd("csaymode",	"admin_saymode",	LVL_CSAY,	"[color] <message> - Allows you to adminchat while in-game") 
	register_clcmd("tsayymode",	"admin_saymode",	LVL_TSAY,	"[color] <message> - Allows you to adminchat while in-game") 
	register_clcmd("csayymode",	"admin_saymode",	LVL_CSAY,	"[color] <message> - Allows you to adminchat while in-game") 
	register_clcmd("say",		"handle_say")
	register_clcmd("say_team",	"handle_teamsay")

	register_clcmd("allsay",	"admin_allsay",		LVL_ALLSAY,	"<message> - Send a message to everyone")
	register_clcmd("adminsay",	"admin_adminsay",	LVL_ADMINSAY,	"<message> - Send a message to all admins") 
	register_clcmd("psay",		"admin_psay",		LVL_PSAY,	"<user> <message> - Send a message to one player") 
	register_clcmd("tsay",		"admin_tsay",		LVL_TSAY,	"[color] <message> - Put a HUD message near chat") 
	register_clcmd("csay",		"admin_tsay",		LVL_CSAY,	"[color] <message> - Put a HUD message in the middle") 
	register_clcmd("tsayy",		"admin_tsay",		LVL_TSAY,	"[color] <message> - tsay without name") 
	register_clcmd("csayy",		"admin_tsay",		LVL_CSAY,	"[color] <message> - csay without name") 

	register_clcmd("amx_setcolor",	"admin_setcolor",	LVL_HUDCOLOR,	"<color> - Set your default hud color") 
	register_clcmd("hudnow",	"admin_hud",		LVL_HUDNOW) 
	register_clcmd("amx_chatroom",	"admin_chatroom",	LVL_CHATROOM, 	"<user> [room#]") 
	register_clcmd("amx_emptyroom",	"admin_emptyroom",	LVL_CHATROOM, 	"[room#]") 

	return PLUGIN_CONTINUE 
} 

public client_connect(id) {
	adcolors[id] = 0
	aiSayType[id] = 0
	room[id] = 0
}

public storage_register_fw() {
	storage_reg_playerfield("hudcolor")
}

public storage_loadplayer_fw(id, status) {
	new value[32]

	if(id > 0) {
		new result = get_playervalue(id, "hudcolor", value, 31)
		if(result != 0) {
			for(new i = 0; i < NUM_COLORS; i++) {
				if(equal(value, colornames[i])) {
					adcolors[id] = i
					break
				}
			}
		}
	}

	return
}

public client_disconnect(id) {
	room[id] = 0
	return PLUGIN_CONTINUE
}

public admin_adminsay(id,level,cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new message[512]
	read_args(message,511)
	new name[32]
	get_user_name(id,name,31)

	printmessage(id, message, 3, -4)

	return PLUGIN_HANDLED 
} 

public admin_allsay(id,level,cid){ 
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new message[512]
	read_args(message,511)
	new name[32]
	get_user_name(id,name,31)

	printmessage(id, message, 3, -3)

	return PLUGIN_HANDLED 
} 

public admin_psay(id,level,cid){
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new message[512]
	read_args(message,511)
	new name[32]
	get_user_name(id,name,31)

	new target[32]
	read_argv(1,target,31)
	new length = strlen(target) + 1

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 0|16|32, targetname, 32)) {
		while((targetindex = cmd_target())) {
			printmessage(id, message[length], 3, targetindex)
		}
	}

	return PLUGIN_HANDLED
}

public admin_setcolor(id, level, cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new color[32] 
	read_argv(1,color,31) 

	new found = 0
	for(new i = 0; i < NUM_COLORS; i++) {
		if(equal(color, colornames[i])) {
			adcolors[id] = i
			found = 1
			set_playervalue(id, "hudcolor", colornames[i])
			storage_saveplayer(id)

			break
		}
	}

	if(!found) {
		client_print(id, print_console, "Color not found!")
		return PLUGIN_HANDLED
	}

	new name[32]
	get_user_name(id,name,31) 
	new steamid[32]
	get_user_authid(id,steamid,31) 
	client_print(id,print_console,"You set your default hudmessage color")
	admin_log_v("ADMIN %s<%s> set his default hudmessage color to %s",name,steamid,colornames[adcolors[id]])

	return PLUGIN_HANDLED 
} 

public admin_tsay(id,level,cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new cmd[32]
	read_argv(0,cmd,31)
	new message[512]
	read_args(message,511)
	new name[32]
	get_user_name(id,name,31)
	new steamid[32]
	get_user_authid(id,steamid,31)

	new color[32], colori
	parse(message,color,31) 
	new found = 0, i = 0

	for(i = 0; i < NUM_COLORS; i++) { 
		if(equal(color,colornames[i])) {
			found = 1
			break 
		}
	}

	if(found) {
		colori = i
	} else {
		colori = adcolors[id]
	}

	new length = found ? strlen(color) : 0

	while(contain(message, "^^n") != -1) {	
		replace(message,511,"^^n","^n")
	}

	new formatted[512]
	if(equali(cmd[4],"y",1) || id == 0)
		format(formatted, 511, "%s", message[length])
	else
		format(formatted, 511, "%s : %s", name, message[length])

	if(equal(cmd[0],"c",1)) {
		myhud_large(formatted, 0, 6.0, 4, colorrgbs[colori][0], colorrgbs[colori][1], colorrgbs[colori][2], 2, -1.0, 0.30, 0.7, 0.02, 0.5)
		admin_log_v("ADMIN %s<%s> csay ^"%s^"", name, steamid, message[length])
	} else {
		myhud_large(formatted, 0, 6.0, 4, colorrgbs[colori][0], colorrgbs[colori][1], colorrgbs[colori][2], 2, 0.05, 0.65, 0.7, 0.02, 0.5)
		admin_log_v("ADMIN %s<%s> tsay ^"%s^"", name, steamid, message[length])
	}

	return PLUGIN_HANDLED 
}

public admin_hud(id,level,cid){
	if (!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	new arg1[128], arg2[128], arg3[128], arg4[128], arg5[128], arg6[128], arg7[128], arg8[128], arg9[128], arg10[128], arg11[128], arg12[128], arg13[128]
	read_argv(1, arg1, 127)
	read_argv(2, arg2, 127)
	read_argv(3, arg3, 127)
	read_argv(4, arg4, 127)
	read_argv(5, arg5, 127)
	read_argv(6, arg6, 127)
	read_argv(7, arg7, 127)
	read_argv(8, arg8, 127)
	read_argv(9, arg9, 127)
	read_argv(10, arg10, 127)
	read_argv(11, arg11, 127)
	read_argv(12, arg12, 127)
	read_argv(13, arg13, 127)

	replace_all(arg1, 127, "^^n", "^n")

	myhud_large(arg1, str_to_num(arg2), str_to_float(arg3), str_to_num(arg4), str_to_num(arg5), str_to_num(arg6), str_to_num(arg7), str_to_num(arg8), str_to_float(arg9), str_to_float(arg10), str_to_float(arg11), str_to_float(arg12), str_to_float(arg13))

	return PLUGIN_HANDLED 
}

// Array for Say-Commands 
new asSayCmd[7][] = {
	"allsay", 
	"adminsay", 
	"psay", 
	"tsay", 
	"csay", 
	"tsayy", 
	"csayy"
}

public admin_saymode(id,level,cid) { 
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	new cmd[32]
	read_argv(0,cmd,31)

	if(equal(cmd, "allsay", 6)) {
		aiSayType[id]=1
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "adminsay", 8)) {
		aiSayType[id]=2
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "psay", 4)) {
		aiSayType[id]=3
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "tsay", 4)) {
		aiSayType[id]=4
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "csay", 4)) {
		aiSayType[id]=5
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "tsayy", 5)) {
		aiSayType[id]=6
		client_cmd(id, "messagemode")
	} else if(equal(cmd, "csayy", 5)) {
		aiSayType[id]=7
		client_cmd(id, "messagemode")
	}
	return PLUGIN_HANDLED
}

public admin_chatroom(id,level,cid) { 
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 0, targetname, 32)) {
		if((targetindex = cmd_target())) {
			new setroom = 0
			if(read_argc() > 2) {
				new setroom_s[32]
				read_argv(2,setroom_s,31) 
				setroom = str_to_num(setroom_s)
			}

			new name[32]
			get_user_name(targetindex, name, 32)

			if(room[targetindex] != 0) {
				for(new i = 0; i < 33; i++) {
					if(room[i] == room[targetindex] && i != targetindex) {
						alertmessage_v(i, 3, "%s has left the room", name)
					}
				}
			}

			if(setroom == 0) {
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "You have entered Public Chat Area")
				room[targetindex] = 0
			} else {
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "")
				alertmessage_v(targetindex, 3, "You have entered Chat Room #%d", setroom)
				room[targetindex] = setroom

				for(new i = 0; i < 33; i++) {
					if(room[i] == room[targetindex] && i != targetindex) {
						alertmessage_v(i, 3, "%s has entered the room", name)
					}
				}
			}
		}
	}

	return PLUGIN_HANDLED 
} 

public admin_emptyroom(id,level,cid) { 
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED 

	new setroom = 0
	if(read_argc() > 2) {
		new setroom_s[32]
		read_argv(2,setroom_s,31) 
		setroom = str_to_num(setroom_s)
	}

	for(new i = 0; i < 33; i++) {
		if((setroom == 0 && room[i] != 0) || (setroom != 0 && setroom == room[i])) {
			alertmessage_v(i, 3, "")
			alertmessage_v(i, 3, "")
			alertmessage_v(i, 3, "")
			alertmessage_v(i, 3, "")
			alertmessage_v(i, 3, "You have entered Public Chat Area")
			room[i] = 0
		}
	}

	return PLUGIN_HANDLED 
} 

public handle_say(id) { 
	new message[512]
	read_args(message, 511)
	remove_quotes(message)

	if(!equal(message, "")) {
		if(aiSayType[id]) {
			client_cmd(id, "%s %s", asSayCmd[aiSayType[id]-1], message)
			aiSayType[id] = 0
		} else if(room[id] != 0) {
			if(get_user_flags(id) & LVL_ADMINSAY) {
				printmessage(id, message, 3, 100+room[id])
			} else {
				printmessage(id, message, 2, 100+room[id])
			}
		} else {
			if(get_user_flags(id) & LVL_ADMINSAY) {
				printmessage(id, message, 3, -1)
			} else {
				printmessage(id, message, 2, -1)
			}
		}
	} else {
		aiSayType[id] = 0
	}

	return PLUGIN_HANDLED
} 

public handle_teamsay(id) {
	new message[512]
	read_args(message, 511)
	remove_quotes(message)

	if(!equal(message, "")) {
		if(room[id] != 0) {
			if(get_user_flags(id) & LVL_ADMINSAY) {
				printmessage(id, message, 3, 100+room[id])
			} else {
				printmessage(id, message, 2, 100+room[id])
			}
		} else {
			if(get_user_flags(id) & LVL_ADMINSAY) {
				printmessage(id, message, 3, -2)
			} else {
				printmessage(id, message, 2, -2)
			}
		}
	}

	return PLUGIN_HANDLED
}

// color
// 1 = normal
// 2 = team
// 3 = green
// mode
// ? = playerid
// >100 = room#+100
// -1 = all
// -2 = team
// -3 = cross-dead
// -4 = admins
printmessage(id, message[], color, mode) {
	new name[32], team, alive
	get_user_name(id,name,31)
	team = get_user_team(id)
	alive = is_user_alive(id)

	new space[3]
	format(space, 2, "")

	new prename[32]
	if(team != 1 && team != 2) {
		if(mode != -2) {
			format(prename, 31, "*SPEC*")
			format(space, 2, " ")
		}
	} else if(!alive) {
		format(prename, 31, "*DEAD*")
		format(space, 2, " ")
	} else if(get_user_flags(id) & LEVEL_9) {
		format(prename, 31, "*S*")
		format(space, 2, " ")
	} else if(get_user_flags(id) & LEVEL_3) {
		format(prename, 31, "*P*")
		format(space, 2, " ")
	} else if(get_user_flags(id) & LEVEL_2) {
		format(prename, 31, "*G*")
		format(space, 2, " ")
	} else {
		format(prename, 31, "")
	}

	new teamname[32]
	if(mode == -1) {
		format(teamname, 31, "")
	} else if(mode == -2) {
		if(team == 1) {
			format(teamname, 31, "(Terrorist)")
			format(space, 2, " ")
		} else if(team == 2) {
			format(teamname, 31, "(Counter-Terrorist)")
			format(space, 2, " ")
		} else {
			format(teamname, 31, "(Spectator)")
			format(space, 2, " ")
		}
	} else if(mode == -3) {
		format(teamname, 31, "(ALL)")
		format(space, 2, " ")
	} else if(mode == -4) {
		format(teamname, 31, "(ADMINS)")
		format(space, 2, " ")
	} else if(mode > 100) {
		format(teamname, 31, "(ROOM #%d)", mode-100)
		format(space, 2, " ")
	} else {
		new targetname[32]
		get_user_name(mode,targetname,31)
		format(teamname, 31, "(%s)", targetname)
		format(space, 2, " ")
	}

	new colorname[32]
	if(color == 1) {
		format(colorname, 31, "^x01")
	} else if(color == 2) {
		format(colorname, 31, "^x03")
	} else {
		format(colorname, 31, "^x04")
	}

	new steamid[32]
	get_user_authid(id, steamid, 31)

	new formatted[512]
	format(formatted, 511, "^x01%s%s%s%s%s^x01 :  %s", prename, teamname, space, colorname, name, message)
	new nocolor[512]
	format(nocolor, 511, "%s%s%s%s<%s>: %s", prename, teamname, space, name, steamid, message)

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			new sayto = 0
			if(mode == -1 && room[targetindex] == 0) {
				if(alive == is_user_alive(targetindex) || get_user_flags(targetindex) & LVL_ADMINSAY_LISTEN) {
					sayto = 1
				}
			} else if(mode == -2 && room[targetindex] == 0) {
				if((alive == is_user_alive(targetindex) && team == get_user_team(targetindex)) || get_user_flags(targetindex) & LVL_ADMINSAY_LISTEN) {
					sayto = 1
				}
			} else if(mode == -3) {
				sayto = 1
			} else if(mode == -4) {
				if(get_user_flags(targetindex) & LVL_ADMINSAY_LISTEN) {
					sayto = 1
				}
			} else if(mode > 100) {
				if(mode-100 == room[targetindex]) {
					sayto = 1
				}
			} else {
				if(targetindex == id || targetindex == mode) {
					sayto = 1
				}
			}

			if(sayto) {
				message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, targetindex)
				write_byte(id)
				write_string(formatted)
				message_end()
			}
		}
	}

	game_log_v(nocolor)
}
