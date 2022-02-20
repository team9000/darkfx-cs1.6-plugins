#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_storage>

new gagged[33]
new gagged_reason[33][128]
new gagmode[33] // 0 = OFF | 1 = MUTE | 2 = GAG
new lastgagmode[33]

public plugin_init() {
	register_plugin("Admin Gag","T9k","Team9000")
	register_clcmd("say","block_gagged_text")
	register_clcmd("say_team","block_gagged_text")
	register_concmd("amx_gag","admin_gag",LVL_GAG,"<target> <reason>")
	register_concmd("amx_ungag","admin_ungag",LVL_UNGAG,"<target> <reason>")
	register_concmd("amx_mute","admin_gag",LVL_MUTE,"<target> <reason>")
	register_concmd("amx_unmute","admin_ungag",LVL_UNMUTE,"<target> <reason>")

	set_task(20.0, "update_speak", 0, "", 0, "b")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	gagged[id] = 0
	gagmode[id] = 0
	lastgagmode[id] = 0
}

public client_putinserver(id) {
	set_task(0.2, "update_speak", id)
	set_task(0.2, "fix_name", id)
}

public storage_register_fw() {
	storage_reg_playerfield("gagged", 1)
	storage_reg_playerfield("gagged_reason", 1)
	storage_reg_playerfield("gagmode", 1)
}

public storage_loadplayer_fw(id, status) {
	if(id > 0) {
		new gagged_s[32]
		new result = get_playervalue(id, "gagged", gagged_s, 31)
		if(result != 0) {
			new gagmode_s[32]
			new result = get_playervalue(id, "gagmode", gagmode_s, 31)
			if(result != 0) {
				new reason_s[128]
				result = get_playervalue(id, "gagged_reason", reason_s, 127)
				if(result != 0) {
					gagged[id] = str_to_num(gagged_s)
					copy(gagged_reason[id], 127, reason_s)
					gagmode[id] = str_to_num(gagmode_s)
					if(!is_user_connecting(id)) {
						update_speak(id)
						fix_name(id)
					}
				}
			}
		}
	}

	return
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[512]
		SQL_GetQueryString(query, queryran, 511)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public update_speak(id) {
	if(id == 0) {
		new targetindex, targetname[33]
		if(cmd_targetset(-1, "*", 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				update_speak(targetindex)
			}
		}
	}

	if(is_user_connecting(id)) {
		return
	}

	if(gagmode[id] != lastgagmode[id]) {
		if(gagmode[id]) {
			set_speak(id, SPEAK_MUTED)
		} else if(get_cvar_num("sv_alltalk")) {
			set_speak(id, SPEAK_ALL)
		} else {
			set_speak(id, SPEAK_NORMAL)
		}
	}
	lastgagmode[id] = gagmode[id]

	if(gagmode[id] && gagged[id] > 0 && time_time() >= gagged[id]) {
		new name[33]
		get_user_name(id, name, 32)
		new steamid[32]
		get_user_authid(id, steamid, 31)

		if(gagmode[id] == 1) {
			alertmessage_v(0,3,"* The timed mute on %s has now expired", name)

			gagged[id] = 0
			gagmode[id] = 0
			fix_name(id)

			new query[512]
			format(query, 511, "UPDATE storage_players SET")
			format(query, 511, "%s gagged='0',", query)
			format(query, 511, "%s gagged_reason='',", query)
			format(query, 511, "%s gagmode='0',", query)
			format(query, 511, "%s history=CONCAT(history, '%d^nUnmuted by System^nReason: Time Expired^n^n')", query, time_time())
			format(query, 511, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
		} else if(gagmode[id] == 2) {
			alertmessage_v(0,3,"* The timed gag on %s has now expired", name)

			gagged[id] = 0
			gagmode[id] = 0
			fix_name(id)

			new query[512]
			format(query, 511, "UPDATE storage_players SET")
			format(query, 511, "%s gagged='0',", query)
			format(query, 511, "%s gagged_reason='',", query)
			format(query, 511, "%s gagmode='0',", query)
			format(query, 511, "%s history=CONCAT(history, '%d^nUngagged by System^nReason: Time Expired^n^n')", query, time_time())
			format(query, 511, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
		}
	}
}

public block_gagged_text(id) {
	if(gagmode[id] == 2) {
		if(gagged[id] == -1) {
			alertmessage_v(id,3,"* You are still gagged permanently! Reason: %s", gagged_reason[id])
			return PLUGIN_HANDLED
		} else if(gagged[id] != 0 && time_time() < gagged[id]) {
			alertmessage_v(id,3,"* You are still gagged for %d minutes! Reason: %s", floatround((gagged[id]-time_time()) / 60.0, floatround_ceil), gagged_reason[id])
			return PLUGIN_HANDLED
		}
	}

	return PLUGIN_CONTINUE
}

public client_infochanged(id) {
	new newname[32], oldname[32]
	get_user_info(id, "name", newname, 31)
	get_user_name(id, oldname, 31)
	if(!equal(oldname, newname)) {
		fix_name(id)
	}

	return PLUGIN_CONTINUE
}

public fix_name(id) {
	if(is_user_connecting(id)) {
		return PLUGIN_CONTINUE
	}

	new name[33], original[33]
	get_user_info(id, "name", original, 31)
	get_user_info(id, "name", name, 31)

	replace(name,32,"*gag*","")
	replace(name,32,"*mute*","")
	if(gagmode[id] == 1) {
		format(name, 32, "*mute*%s", name)
	} else if(gagmode[id] == 2) {
		format(name, 32, "*gag*%s", name)
	}

	if(!equal(original, name)) {
		set_user_info(id,"name", name)
	}

	return PLUGIN_CONTINUE
}

public admin_gag(id,level,cid) {
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED

	new command[32]
	read_argv(0,command,31)
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
			if(gagmode[targetindex] == 2 && equal(command, "amx_gag")) {
				client_print(id, print_console, "Client is already gagged!")
				return PLUGIN_HANDLED
			}
			if(gagmode[targetindex] == 1 && equal(command, "amx_mute")) {
				client_print(id, print_console, "Client is already muted!")
				return PLUGIN_HANDLED
			}

			get_user_authid(targetindex, steamid, 31)

			new query[512]
			format(query, 511, "UPDATE storage_players SET")
			if(str_to_num(minutes) == 0) {
				format(query, 511, "%s gagged='-1',", query)
			} else {
				format(query, 511, "%s gagged='%d',", query, time_time()+(str_to_num(minutes)*60))
			}
			format(query, 511, "%s gagged_reason='%s',", query, reason_striped)
			if(equal(command, "amx_gag")) {
				format(query, 511, "%s gagmode='2',", query)
				format(query, 511, "%s history=CONCAT(history, '%d^nGagged by %s<%s> %s^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, temp, reason_striped)
			} else {
				format(query, 511, "%s gagmode='1',", query)
				format(query, 511, "%s history=CONCAT(history, '%d^nMuted by %s<%s> %s^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, temp, reason_striped)
			}
			format(query, 511, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

			if(str_to_num(minutes) == 0) {
				gagged[targetindex] = -1
			} else {
				gagged[targetindex] = time_time()+(str_to_num(minutes)*60)
			}
			copy(gagged_reason[targetindex], 127, reason)
			if(equal(command, "amx_gag")) {
				gagmode[targetindex] = 2
			} else {
				gagmode[targetindex] = 1
			}

			fix_name(targetindex)
			update_speak(targetindex)
		}

		if(equal(command, "amx_gag")) {
			adminalerth_v(id, reason, "gagged %s %s", targetname, temp)
		} else {
			adminalerth_v(id, reason, "muted %s %s", targetname, temp)
		}
	}

	return PLUGIN_HANDLED
}

public admin_ungag(id,level,cid) {
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new command[32]
	read_argv(0,command,31)
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

	new targetindex, targetname[33], steamid[32]
	if(cmd_targetset(id, target, 3|16|32, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(gagmode[targetindex] != 2 && equal(command, "amx_ungag")) {
				client_print(id, print_console, "Client is not gagged!")
				return PLUGIN_HANDLED
			}
			if(gagmode[targetindex] != 1 && equal(command, "amx_unmute")) {
				client_print(id, print_console, "Client is not muted!")
				return PLUGIN_HANDLED
			}

			get_user_authid(targetindex, steamid, 31)

			new query[512]
			format(query, 511, "UPDATE storage_players SET")
			format(query, 511, "%s gagged='0',", query)
			format(query, 511, "%s gagged_reason='',", query)
			format(query, 511, "%s gagmode='0',", query)
			if(equal(command, "amx_ungag")) {
				format(query, 511, "%s history=CONCAT(history, '%d^nUngagged by %s<%s>^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, reason_striped)
			} else {
				format(query, 511, "%s history=CONCAT(history, '%d^nUnmuted by %s<%s>^nReason: %s^n^n')", query, time_time(), adminname_striped, adminsteamid, reason_striped)
			}
			format(query, 511, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

			gagged[targetindex] = 0
			gagged_reason[targetindex] = ""
			gagmode[targetindex] = 0

			fix_name(targetindex)
			update_speak(targetindex)
		}

		if(equal(command, "amx_ungag")) {
			adminalerth_v(id, reason, "ungagged %s", targetname)
		} else {
			adminalerth_v(id, reason, "unmuted %s", targetname)
		}
	}

	return PLUGIN_HANDLED
}
