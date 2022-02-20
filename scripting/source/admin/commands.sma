#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

new next_map[33]

new checkingnom[32]

public plugin_init() {
	register_plugin("Admin Commands","T9k","Team9000")
	register_concmd("amx_kick","admin_kick",LVL_KICK,"<authid, nick, #userid, @team or *> [reason] - Kicks a player")
	register_concmd("amx_ban","admin_ban",LVL_BAN,"<authid, nick, #userid, @team or *> <minutes> <reason> - Bans a player")
	register_concmd("amx_banid","admin_banid",LVL_BANID,"<steamid> <minutes> <reason> - Bans a player")
	register_concmd("amx_unban","admin_unban",LVL_UNBAN,"<steamid> <reason> - Unbans a player")
	register_concmd("amx_mapnow","admin_mapnow",LVL_MAPNOW,"<mapname> - Changes the map without access check")
	register_concmd("amx_map","admin_map",LVL_MAP,"<mapname> - Changes the map")
	register_concmd("amx_cvar","admin_cvar",LVL_CVAR,"<cvar> [value] - Displays or alters a cvar")
	register_concmd("amx_cfg","admin_cfg",LVL_CFG,"<fliename> - Executes a configuration file")
	register_concmd("amx_rcon","admin_rcon",LVL_RCON,"<command> - Sends a command to the server console")
	register_concmd("amx_who","admin_who",LVL_WHO,"Displays information about who is on the server")
	register_concmd("amx_speak","admin_speak",LVL_SPEAK,"<target> <text> - Says text on everyones computers")
	return PLUGIN_CONTINUE
}

public client_connect(id) {
	checkingnom[id] = 0;
}

public admin_kick(id,level,cid) {
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)
	new reason[128]
	read_argv(2,reason,127)

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(read_argc() < 3) {
				server_cmd("kick #%d", get_user_userid(targetindex))
			} else {
				server_cmd("kick #%d  %s", get_user_userid(targetindex), reason_striped)
			}
		}

		adminalert_v(id, reason, "kicked %s", targetname)
	}

	return PLUGIN_HANDLED
}

public storage_register_fw() {
	storage_reg_playerfield("banned", 1)
	storage_reg_playerfield("banned_reason", 1)
}

public storage_loadplayer_fw(id, status) {
	new banned_s[32]

	if(id > 0) {
		new result = get_playervalue(id, "banned", banned_s, 31)
		if(result != 0) {
			new banned_reason[128]
			result = get_playervalue(id, "banned_reason", banned_reason, 127)
			if(result != 0) {
				new banned = str_to_num(banned_s)
				if(banned == -1) {
					server_cmd("kick #%d  You are banned permanently! Reason: %s", get_user_userid(id), banned_reason)
				} else if(banned != 0 && time_time() < banned) {
					server_cmd("kick #%d  You are still banned for %d minutes! Reason: %s", get_user_userid(id), floatround((banned-time_time()) / 60.0, floatround_ceil), banned_reason)
				}

				if(banned > 0 && time_time() >= banned) {
					new name[33]
					get_user_name(id, name, 32)
					new steamid[32]
					get_user_authid(id, steamid, 31)

					alertmessage_v(0,3,"* The timed ban on %s has now expired", name)

					new query[1024]
					format(query, 1023, "UPDATE storage_players SET")
					format(query, 1023, "%s banned='0',", query)
					format(query, 1023, "%s banned_reason='',", query)
					format(query, 1023, "%s history=CONCAT(history, '%d^nUnbanned by System^nReason: Time Expired^n^n')", query, time_time())
					format(query, 1023, "%s WHERE steamid='%s'", query, steamid)
					SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
				}
			}
		}
	}

	return
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[1024]
		SQL_GetQueryString(query, queryran, 1023)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public admin_ban(id,level,cid) {
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new minutes[32]
	read_argv(2,minutes,31)
	new reason[128]
	read_argv(3,reason,127)

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new temp[64]
	if(str_to_num(minutes))
		format(temp,63,"for %d minutes",str_to_num(minutes))
	else
		copy(temp,63,"permanently")

	new adminsteamid[32], adminname[33], adminname_striped[33]
	get_user_authid(id, adminsteamid, 31)
	get_user_name(id, adminname, 32)
	mysql_strip(adminname, adminname_striped, 32)

	new targetindex, targetname[33], steamid[32]
	if(cmd_targetset(id, target, 3|16|32, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_authid(targetindex, steamid, 31)

			new query[1024]
			format(query, 1023, "UPDATE storage_players SET")
			if(str_to_num(minutes) == 0) {
				format(query, 1023, "%s banned='-1',", query)
			} else {
				format(query, 1023, "%s banned='%d',", query, time_time()+(str_to_num(minutes)*60))
			}
			format(query, 1023, "%s banned_reason='%s',", query, reason_striped)
			format(query, 1023, "%s history=CONCAT(history, '%d^nBanned by %s<%s> %s^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, temp, reason_striped)
			format(query, 1023, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

			server_cmd("kick #%d  Banned %s - Reason: %s", get_user_userid(targetindex), temp, reason)
			server_cmd("banid 0.5 %s;wait;writeid", steamid)
		}

		adminalerth_v(id, reason, "banned %s %s", targetname, temp)
	}

	return PLUGIN_HANDLED
}

public admin_banid(id,level,cid) {
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED 

	new steamid[32]
	read_argv(1,steamid,31)
	new minutes[32]
	read_argv(2,minutes,31)
	new reason[128]
	read_argv(3,reason,127)

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new temp[64]
	if(str_to_num(minutes))
		format(temp,63,"for %d minutes",str_to_num(minutes))
	else
		copy(temp,63,"permanently")

	new adminsteamid[32], adminname[33], adminname_striped[33]
	get_user_authid(id, adminsteamid, 31)
	get_user_name(id, adminname, 32)
	mysql_strip(adminname, adminname_striped, 32)

	new query[1024]
	format(query, 1023, "UPDATE storage_players SET")
	if(str_to_num(minutes) == 0) {
		format(query, 1023, "%s banned='-1',", query)
	} else {
		format(query, 1023, "%s banned='%d',", query, time_time()+(str_to_num(minutes)*60))
	}
	format(query, 1023, "%s banned_reason='%s',", query, reason_striped)
	format(query, 1023, "%s history=CONCAT(history, '%d^nBanned by %s<%s> %s^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, temp, reason_striped)
	format(query, 1023, "%s WHERE steamid='%s'", query, steamid)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

	server_cmd("banid 0.5 %s;wait;writeid", steamid)

	adminalerth_v(id, reason, "banned the SteamID %s %s", steamid, temp)

	return PLUGIN_HANDLED
}

public admin_unban(id,level,cid) {
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new reason[128]
	read_argv(2,reason,127)

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new adminsteamid[32], adminname[33], adminname_striped[33]
	get_user_authid(id, adminsteamid, 31)
	get_user_name(id, adminname, 32)
	mysql_strip(adminname, adminname_striped, 32)

	new query[1024]
	format(query, 1023, "UPDATE storage_players SET")
	format(query, 1023, "%s banned='0',", query)
	format(query, 1023, "%s history=CONCAT(history, '%d^nUnbanned by %s<%s>^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, reason_striped)
	format(query, 1023, "%s WHERE steamid='%s'", query, target)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

	adminalerth_v(id, reason, "unbanned the SteamID %s", target)

	return PLUGIN_HANDLED
}

public delayed_changemap(mapname[]) {
	server_cmd("changelevel %s",next_map)
}

public delayed_showscores() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex,"+showscores")
		}
	}
}

public admin_mapnow(id,level,cid){
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new mapname[32]
	read_argv(1,mapname,31)

	if(!is_map_valid(mapname)) {
		console_print(id,"Sorry, that map does not exist on this server") 
		return PLUGIN_HANDLED
	}

	copy(next_map, 32, mapname)

	set_task(2.8,"delayed_showscores")
	set_task(3.0,"delayed_changemap")

	adminalert_v(id, "", "changed the level to %s", mapname)
	return PLUGIN_HANDLED
}

public admin_map(id,level,cid){
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new mapname[32]
	read_argv(1,mapname,31)

	if(checkingnom[id]) {
		console_print(id,"Please wait until previous change is completed")
		return PLUGIN_HANDLED
	}
	checkingnom[id] = 1

	new ident[32]
	get_cvar_string("amx_server_ident_mapset", ident, 31)

	new mapname_stripped[64]
	mysql_strip(mapname, mapname_stripped, 63)

	new query[512]
	format(query, 511, "SELECT id, name FROM storage_maps WHERE name LIKE '%s' AND allow='1' AND server_%s='1' LIMIT 1", mapname_stripped, ident)
	new data[1]
	data[0] = id
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_nominate", query, data, 1)

	console_print(id,"Checking Database...")
	return PLUGIN_HANDLED
}

public QueryHandled_nominate(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[512]
		SQL_GetQueryString(query, queryran, 511)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_nominate", queryran, data, size)
	} else {
		new id = 0
		if(size > 0) {
			id = data[0]
		}
		if(!checkingnom[id]) {
			return
		}
		checkingnom[id] = 0

		if(SQL_NumResults(query) > 0) {
			new mapname[64] = ""
			new colnum = SQL_FieldNameToNum(query, "name")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, mapname, 63)
			}

			if(!is_map_valid(mapname)) {
				console_print(id,"Sorry, that map does not exist on this server") 
				return
			}

			copy(next_map, 32, mapname)

			set_task(2.8,"delayed_showscores")
			set_task(3.0,"delayed_changemap")

			adminalert_v(id, "", "changed the level to %s", mapname)
		} else {
			console_print(id,"Sorry, that map does not exist on this server") 
		}
	}
}

public admin_cvar(id,level,cid) {
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new cvar[32]
	read_argv(1,cvar,31)
	new value[64]
	read_argv(2,value,63)

	if (!cvar_exists(cvar)) {
		console_print(id,"Unknown cvar")
		return PLUGIN_HANDLED
	} else if(read_argc() < 3) {
		get_cvar_string(cvar, value, 63)
		console_print(id, "Cvar ^"%s^" is ^"%s^"", cvar, value)
		return PLUGIN_HANDLED
	} else {
		set_cvar_string(cvar,value)
		console_print(id, "Cvar ^"%s^" is now ^"%s^"", cvar, value)

		new name[33]
		get_user_name(id,name,32)
		new steamid[33]
		get_user_authid(id,steamid,32)
		admin_log_v("ADMIN %s<%s> set cvar ^"%s^" to ^"%s^"", name, steamid, cvar, value)
	}

	return PLUGIN_HANDLED
}

public admin_rcon(id,level,cid) {
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new args[512]
	read_args(args, 511)

	server_cmd(args)

	console_print(id,"Commmand line ^"%s^" sent to server console", args)

	new name[33]
	get_user_name(id,name,31)
	new steamid[33]
	get_user_authid(id,steamid,32)
	admin_log_v("ADMIN %s<%s> rcon ^"%s^"", name, steamid, args)

	return PLUGIN_HANDLED
}

public admin_cfg(id,level,cid) {
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED 

	new filename[128]
	read_argv(1,filename,127)

	if(!file_exists(filename)){
		console_print(id,"File ^"%s^" not found", filename)
		return PLUGIN_HANDLED	
	}

	server_cmd("exec %s",filename)

	new name[33]
	get_user_name(id,name,31)
	new steamid[33]
	get_user_authid(id,steamid,32)
	admin_log_v("ADMIN %s<%s> executed config ^"%s^"", name, steamid, filename)
	
	return PLUGIN_HANDLED
}

public admin_who(id,level,cid) {
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	new authid[32], name[32], flags, sflags[32], inum = 0
	console_print(id,"^nClients on server:^n %2s %32s %32s %8s %s", "#", "nick","authid","userid","access")

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_authid(targetindex,authid,31)
			get_user_name(targetindex,name,31)
			flags = get_user_flags(targetindex)
			get_flags(flags,sflags,31)
			console_print(id," %2d %32s %32s %8d %s", targetindex, name, authid, get_user_userid(targetindex), sflags)
			inum++
		}
	}
	console_print(id,"Total %d",inum)
	return PLUGIN_HANDLED
}

public admin_speak(id,level,cid) {
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)
	new text[256]
	read_argv(2,text,255)

	new cmd[256]
	format(cmd, 255, "speak ^"%s^"", text)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex, cmd)
		}

		adminalert_v(id, "", "spoke to %s", targetname)
	}

	return PLUGIN_HANDLED
}
