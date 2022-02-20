#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_storage>

new gamelog[64]
new adminlog[64]
new heavylog[64]

public plugin_init() {
	register_plugin("Subsys - Stocks","T9k","Team9000")

	new mapname[64]
	get_mapname(mapname, 63)

	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, timezone, is_dst)

	new file[64]
	format(file, 63, "mylogs/")
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/game/")
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/game/%d-%02d/", year, month)
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/game/%d-%02d/%02d/", year, month, day)
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/admin/")
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/admin/%d-%02d/", year, month)
	if(!dir_exists(file)) {
		mkdir(file)
	}
	format(file, 63, "mylogs/heavy/")
	if(!dir_exists(file)) {
		mkdir(file)
	}

	format(gamelog, 63, "mylogs/game/%d-%02d/%02d/%02d-%02d-%02d (%s).log", year, month, day, hour, minute, second, mapname)
	format(adminlog, 63, "mylogs/admin/%d-%02d/%02d.log", year, month, day)
	format(heavylog, 63, "mylogs/heavy/%d-%02d.log", year, month)

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_stocks")

	register_native("num_apponents","num_apponents_impl")
	register_native("num_onteam","num_onteam_impl")
	register_native("alertmessage","alertmessage_impl")
	register_native("adminalert","adminalert_impl")
	register_native("playeralert","playeralert_impl")
	register_native("access","access_impl")
	register_native("cmd_access","cmd_access_impl")
	register_native("cmd_targetset","cmd_targetset_impl")
	register_native("cmd_target","cmd_target_impl")
	register_native("is_running","is_running_impl")
	register_native("get_basedir","get_basedir_impl")
	register_native("admin_log","admin_log_impl")
	register_native("game_log","game_log_impl")
	register_native("mysql_strip","mysql_strip_impl")
	register_native("mysql_check","mysql_check_impl")
}

public num_apponents_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)

	new inum = 0

	if(cs_get_user_team(id) == CS_TEAM_T) {
		new targetname[33]
		if(cmd_targetset(-1, "@CT", 0, targetname, 32, 1)) {
			while(cmd_target(1)) {
				inum++
			}
		}
	} else if(cs_get_user_team(id) == CS_TEAM_CT) {
		new targetname[33]
		if(cmd_targetset(-1, "@T", 0, targetname, 32, 1)) {
			while(cmd_target(1)) {
				inum++
			}
		}
	}

	return inum
}

public num_onteam_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new team = get_param(1)

	new inum = 0

	if(CsTeams:team == CS_TEAM_CT) {
		new targetname[33]
		if(cmd_targetset(-1, "@CT", 0, targetname, 32, 1)) {
			while(cmd_target(1)) {
				inum++
			}
		}
	} else if(CsTeams:team == CS_TEAM_T) {
		new targetname[33]
		if(cmd_targetset(-1, "@T", 0, targetname, 32, 1)) {
			while(cmd_target(1)) {
				inum++
			}
		}
	}

	return inum
}

// color
// 1 = normal
// 2 = team
// 3 = green
public alertmessage_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new color = get_param(2)
	new message[512]
	get_string(3, message, 511)

	new colorname[32]
	if(color == 1) {
		format(colorname, 31, "^x01")
	} else if(color == 2) {
		format(colorname, 31, "^x03")
	} else {
		format(colorname, 31, "^x04")
	}

	new formatted[512]
	format(formatted, 511, "%s%s^x01", colorname, message)

	if(id == 0) {
		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, targetindex)
				write_byte(targetindex)
				write_string(formatted)
				message_end()
			}
		}
		server_print(message)
	} else {
		message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id)
		write_byte(id)
		write_string(formatted)
		message_end()
	}

	return 1
}

public adminalert_impl(id, numparams) {
	if(numparams < 2 || numparams > 4)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new message[512]
	get_string(2, message, 511)
	new reason[512]
	if(numparams >= 3) {
		get_string(3, reason, 511)
	} else {
		copy(reason, 511, "")
	}

	new heavy = 0
	if(numparams >= 4) {
		heavy = get_param(4)
	}

	new name[33]
	get_user_name(id,name,31)
	switch(get_cvar_num("amx_show_activity")) {
      		case 1:	alertmessage_v(0,3,"An admin %s", message)
      		case 2:	alertmessage_v(0,3,"ADMIN %s %s", name, message)
     	}
	console_print(id,"You %s", message)

	if(!equal(reason, "")) {
		switch(get_cvar_num("amx_show_activity")) {
      			case 1:	alertmessage_v(0,3,"Reason: %s", reason)
      			case 2:	alertmessage_v(0,3,"Reason: %s", reason)
     		}
		console_print(id,"Reason: %s", reason)
	}

	new steamid[32]
	get_user_authid(id,steamid,31)

	if(equal(reason, "")) {
		if(heavy) {
			admin_logh_v("ADMIN %s<%s> %s", name, steamid, message)
		} else {
			admin_log_v("ADMIN %s<%s> %s", name, steamid, message)
		}
	} else {
		if(heavy) {
			admin_logh_v("ADMIN %s<%s> %s (Reason: %s)", name, steamid, message, reason)
		} else {
			admin_log_v("ADMIN %s<%s> %s (Reason: %s)", name, steamid, message, reason)
		}
	}

	return 1
}

public playeralert_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new message[512]
	get_string(2, message, 511)

	new name[33]
	get_user_name(id,name,31)
	new steamid[32]
	get_user_authid(id,steamid,31)

	game_log_v("%s<%s> %s", name, steamid, message)

	return 1
}

public access_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new level = get_param(2)
	return (get_user_flags(id) & level) ? true : false
}

public cmd_access_impl(id, numparams) {
	if(numparams < 3 || numparams > 4)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new level = get_param(2)
	new command = get_param(3)
	new minargs = 0
	if(numparams == 4) {
		minargs = get_param(4)
	}

	if(!(access(id,level)) && level) {
		console_print(id,"You have no access to that command")
		return false
	}
	if(numparams != 0 && read_argc() < minargs) {
		new hcmd[32], hinfo[128], hflag
		get_concmd(command,hcmd,31,hflag,hinfo,127,level)
		console_print(id,"Usage:  %s %s",hcmd,hinfo)
		return false
	}
	return true
}

/* Flags:
*  1 - obey immunity
*  2 - allow yourself
*  4 - must be alive
*  8 - can't be bot

*  16 - can't be everyone
*  32 - can't be a team
*  64 - can't be one player
*/

new cmd_targetval_id[10]
new cmd_targetval_num[10]
new cmd_targetval_find[10][33]
new cmd_targetval_flags[10]
new cmd_targetval_single[10]

public cmd_targetset_impl(id, numparams) {
	if(numparams < 5 || numparams > 6)
		return log_error(10, "Bad native parameters")

	new id = get_param(1)
	new arg[33]
	get_string(2, arg, 32)
	new flags = get_param(3)
	new searchid = 0
	if(numparams == 6) {
		searchid = get_param(6)
	}

	cmd_targetval_num[searchid] = 0
	cmd_targetval_id[searchid] = id
	cmd_targetval_find[searchid][0] = 0
	cmd_targetval_flags[searchid] = flags
	cmd_targetval_single[searchid] = 0
	set_string(4, "", get_param(5))

	if(arg[0]=='*') {
		if(flags & 16) {
			if(id != -1) {
				console_print(id,"You cannot target everyone for this command")
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}

		new inum = 0
		for(new i = 1; i < 33; i++) {
			if(is_user_connected(i)) {
				cmd_targetval_find[searchid][inum] = i
				inum++
			}
		}
		cmd_targetval_find[searchid][inum] = 0
		cmd_targetval_single[searchid] = 0
		if(inum == 0) {
			if(id != -1) {
				console_print(id,"There are no players!")
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}
		set_string(4, "everyone", get_param(5))
	} else if(arg[0]=='@' && arg[1]) {
		if(flags & 32) {
			if(id != -1) {
				console_print(id,"You cannot target a team for this command")
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}

		new CsTeams:teamid
		if(arg[1] == 'T') {
			teamid = CS_TEAM_T
		} else if(arg[1] == 'C') {
			teamid = CS_TEAM_CT
		} else if(arg[1] == 'S') {
			teamid = CS_TEAM_SPECTATOR
		} else {
			if(id != -1) {
				console_print(id,"Invalid Team") 
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}

		new inum
		for(new i = 1; i < 33; i++) {
			if(is_user_connected(i) && cs_get_user_team(i) == teamid) {
				cmd_targetval_find[searchid][inum] = i
				inum++
			}
		}
		cmd_targetval_find[searchid][inum] = 0
		cmd_targetval_single[searchid] = 0
		if(inum == 0) {
			if(id != -1) {
				console_print(id,"There are no players on that team") 
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}
		if(teamid == CS_TEAM_T) {
			set_string(4, "the Terrorists", get_param(5))
		} else if(teamid == CS_TEAM_CT) {
			set_string(4, "the CTs", get_param(5))
		} else if(teamid == CS_TEAM_SPECTATOR) {
			set_string(4, "the Spectators", get_param(5))
		}
	} else {
		if(flags & 64) {
			if(id != -1) {
				console_print(id,"You cannot target a single player for this command")
			}
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			cmd_targetval_single[searchid] = 0
			return 0
		}

		new player

		if(arg[0]=='#' && arg[1]) {
			player = find_player("k",str_to_num(arg[1]))
			if(!player) {
				if(id != -1) {
					console_print(id,"Client with that userid not found")
				}
				cmd_targetval_num[searchid] = 0
				cmd_targetval_id[searchid] = 0
				cmd_targetval_find[searchid][0] = 0
				cmd_targetval_flags[searchid] = 0
				cmd_targetval_single[searchid] = 0
				return 0
			}
		} else if(containi(arg, "STEAM_0:") == 0) {
			player = find_player("c",arg)
			if(!player) {
				if(id != -1) {
					console_print(id,"Client with that steamid not found")
				}
				cmd_targetval_num[searchid] = 0
				cmd_targetval_id[searchid] = 0
				cmd_targetval_find[searchid][0] = 0
				cmd_targetval_flags[searchid] = 0
				cmd_targetval_single[searchid] = 0
				return 0
			}
		} else {
			player = find_player("bl",arg)
			if(!player) {
				if(id != -1) {
					console_print(id,"Client with that nick not found")
				}
				cmd_targetval_num[searchid] = 0
				cmd_targetval_id[searchid] = 0
				cmd_targetval_find[searchid][0] = 0
				cmd_targetval_flags[searchid] = 0
				cmd_targetval_single[searchid] = 0
				return 0
			} else {
				new player2 = find_player("blj",arg)
				if(player != player2) {
					if(id != -1) {
						console_print(id,"There are more than one clients matching your argument")
					}
					cmd_targetval_num[searchid] = 0
					cmd_targetval_id[searchid] = 0
					cmd_targetval_find[searchid][0] = 0
					cmd_targetval_flags[searchid] = 0
					cmd_targetval_single[searchid] = 0
					return 0		
				}
			}
		}

		cmd_targetval_find[searchid][0] = player
		cmd_targetval_find[searchid][1] = 0
		cmd_targetval_single[searchid] = 1

		new playername[32]
		get_user_name(player,playername,31)
		set_string(4, playername, get_param(5))
	}

	// Check to see if there is anyone applicable for the target
	cmd_targetval_id[8] = cmd_targetval_id[searchid]
	cmd_targetval_num[8] = 0
	for(new i = 0; i < 32; i++) {
		cmd_targetval_find[8][i] = cmd_targetval_find[searchid][i]
	}
	cmd_targetval_flags[8] = cmd_targetval_flags[searchid]
	cmd_targetval_single[8] = cmd_targetval_single[searchid]

	if(cmd_target(8,1) == 0) { // Show user all the messages
		cmd_targetval_id[8] = cmd_targetval_id[searchid]
		cmd_targetval_num[8] = 0
		for(new i = 0; i < 32; i++) {
			cmd_targetval_find[8][i] = cmd_targetval_find[searchid][i]
		}
		cmd_targetval_flags[8] = cmd_targetval_flags[searchid]
		cmd_targetval_single[8] = cmd_targetval_single[searchid]

		cmd_target(8)
		return 0
	}

	return 1
}

public cmd_target_impl(id, numparams) {
	if(numparams < 0 || numparams > 2)
		return log_error(10, "Bad native parameters")

	new searchid = 0
	if(numparams >= 1) {
		searchid = get_param(1)
	}

	new dontprint = 0
	if(numparams >= 2) {
		dontprint = get_param(2)
	}

	new always = 1
	while(always) {
		new player = cmd_targetval_find[searchid][cmd_targetval_num[searchid]]
		cmd_targetval_num[searchid]++

		if(player == 0) {
			cmd_targetval_num[searchid] = 0
			cmd_targetval_id[searchid] = 0
			cmd_targetval_find[searchid][0] = 0
			cmd_targetval_flags[searchid] = 0
			return 0
		}

		new playername[32]
		get_user_name(player,playername,31)

		if(cmd_targetval_flags[searchid] & 1 && !get_cvar_num("amx_ignore_immunity")) {
			if(access(player,LVL_LOWIMMUNITY) || access(player,LVL_HIGHIMMUNITY)) {
				if((cmd_targetval_flags[searchid] & 2) ? (cmd_targetval_id[searchid]!=player) : true) {
					if(
					cmd_targetval_id[searchid] == -1 ||
					access(player,LVL_HIGHIMMUNITY) ||
					(!access(player,LVL_HIGHIMMUNITY) && !access(cmd_targetval_id[searchid],LVL_LOWIMMUNITY_OVERRIDE)) ||
					(!access(player,LVL_HIGHIMMUNITY) && access(cmd_targetval_id[searchid],LVL_LOWIMMUNITY_OVERRIDE) && !cmd_targetval_single[searchid])
					) {
						if(cmd_targetval_id[searchid] != -1 && !dontprint) {
							console_print(cmd_targetval_id[searchid],"Skipping ^"%s^" because client has immunity",playername)
						}
						continue
					}
				}
			}
		}

		if(cmd_targetval_flags[searchid] & 4) {
			if(!is_user_alive(player)) {
				if(cmd_targetval_id[searchid] != -1 && !dontprint) {	
					console_print(cmd_targetval_id[searchid],"Skipping dead client ^"%s^"",playername)
				}
				continue
			}
		}

		if(cmd_targetval_flags[searchid] & 8) {
			if(is_user_bot(player)) {	
				if(cmd_targetval_id[searchid] != -1 && !dontprint) {
					console_print(cmd_targetval_id[searchid],"Skipping bot ^"%s^"",playername)
				}
				continue
			}
		}
		return player
	}
	return 0
}

public is_running_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new arg[33]
	get_string(1, arg, 32)

	new mod_name[33]
	get_modname(mod_name,32)

	return equal(mod_name,arg)
}

public get_basedir_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new basedir[64]
	new result = get_localinfo("amx_basedir", basedir, 63)
	set_string(1, basedir, get_param(2))
	return result
}

public admin_log_impl(id, numparams) {
	if(numparams < 1 || numparams > 2)
		return log_error(10, "Bad native parameters")

	new buffer[512]
	get_string(1, buffer, 511)

	new heavy = 0
	if(numparams >= 2) {
		heavy = get_param(2)
	}

	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, timezone, is_dst)

	new timed[1024]
	format(timed, 1023, "L %02d/%02d/%d - %02d:%02d:%02d: %s", month, day, year, hour, minute, second, buffer)

	if(heavy) {
		write_file(heavylog, timed)
	}
	write_file(adminlog, timed)
	write_file(gamelog, timed)

	return 1
}

public game_log_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new buffer[512]
	get_string(1, buffer, 511)

	new hour, minute, second, month, day, year, Float:timezone, is_dst
	time_get(time_time(), hour, minute, second, month, day, year, timezone, is_dst)

	new timed[1024]
	format(timed, 1023, "L %02d/%02d/%d - %02d:%02d:%02d: %s", month, day, year, hour, minute, second, buffer)

	write_file(gamelog, timed)

	return 1
}

new mysqlcharsallowed[] = "!@#$&*()_-+={[}]|:<,>.?/ "

public mysql_strip_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new input[256]
	get_string(1, input, 255)

	for(new i = 0; i < strlen(input); i++) {
		new allowchar = 0
		if((input[i] >= 'a' && input[i] <= 'z') || (input[i] >= 'A' && input[i] <= 'Z') || (input[i] >= '0' && input[i] <= '9')) {
			allowchar = 1
		} else {
			for(new j = 0; j < strlen(mysqlcharsallowed); j++) {
				if(input[i] == mysqlcharsallowed[j]) {
					allowchar = 1
				}
			}
		}
		if(!allowchar) {
			input[i] = ' '
		}
	}

	set_string(2, input, get_param(3))
	return 1
}

public debug_print(fmt[], {Float,_}:...) {
	new message[512]
	vformat(message, 511, fmt, 2)
	client_print(0, print_console, message)
	server_print(message)
}

public mysql_check_impl(id, numparams) {
	if(numparams != 5)
		return log_error(10, "Bad native parameters")

	new failstate = get_param(1)
//	new Handle:query = Handle:get_param(2)
	new error[256]
	get_string(3, error, 255)
	new errnum = get_param(4)
	new debugprint = get_param(5)
	if(failstate) {
		if(failstate == TQUERY_CONNECT_FAILED) {
			log_message("MYSQL CONNECTION ERROR (%d - %s)", errnum, error)
			if(debugprint) {
				debug_print("MYSQL CONNECTION ERROR (%d - %s)", errnum, error)
			}
		} else if(failstate == TQUERY_QUERY_FAILED) {
			log_message("MYSQL QUERY ERROR (%d - %s)", errnum, error)
			if(debugprint) {
				debug_print("MYSQL QUERY ERROR (%d - %s)", errnum, error)
			}
		} else {
			log_message("MYSQL UNKNOWN ERROR (%d - %s)", errnum, error)
			if(debugprint) {
				debug_print("MYSQL UNKNOWN ERROR (%d %d - %s)", failstate, errnum, error)
			}
		}

		return 0
	}

	return 1
}
