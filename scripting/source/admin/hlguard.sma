#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

public plugin_init() {
	register_plugin("Admin HLGuard","T9k","Team9000")
	register_srvcmd("amx_hlguard_kick","admin_hlguard_kick",0,"<#userid> <reason>")
	register_srvcmd("amx_hlguard_ban","admin_hlguard_ban",0,"<#userid> <minutes> <reason>")
	return PLUGIN_CONTINUE
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public admin_hlguard_kick() {
	new target[32]
	read_argv(1,target,31)

	new reason[128]
	read_args(reason,127)
	copy(reason, 127, reason[strlen(target)+1])

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new targetindex, targetname[33], steamid[32]
	if(cmd_targetset(-1, target, 0|16|32, targetname, 32)) {
		if((targetindex = cmd_target())) {
			get_user_authid(targetindex, steamid, 31)

			new query[1024]
			format(query, 1023, "UPDATE storage_players SET")
			format(query, 1023, "%s history=CONCAT(history, '%d^nKicked by HLGuard^nReason: %s^n^n')", query, time_time(), reason_striped)
			format(query, 1023, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

			server_cmd("kick #%d  Reason: %s", get_user_userid(targetindex), reason_striped)

			alertmessage_v(0, 3, "HLGuard kicked %s", targetname)
			alertmessage_v(0, 3, "Reason: %s", reason)
		}
	}

	return PLUGIN_HANDLED
}

public admin_hlguard_ban(id,level,cid) {
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new minutes[32]
	read_argv(2,minutes,31)

	new reason[128]
	read_args(reason,127)
	copy(reason, 127, reason[strlen(target)+1+strlen(minutes)+1])

	new reason_striped[128]
	mysql_strip(reason, reason_striped, 127)

	new temp[64]
	if(str_to_num(minutes))
		format(temp,63,"for %d minutes",str_to_num(minutes))
	else
		copy(temp,63,"permanently")

	new targetindex, targetname[33], steamid[32]
	if(cmd_targetset(-1, target, 0|16|32, targetname, 32)) {
		if((targetindex = cmd_target())) {
			get_user_authid(targetindex, steamid, 31)

			new query[1024]
			format(query, 1023, "UPDATE storage_players SET")
			if(str_to_num(minutes) == 0) {
				format(query, 1023, "%s banned='-1',", query)
			} else {
				format(query, 1023, "%s banned='%d',", query, time_time()+(str_to_num(minutes)*60))
			}
			format(query, 1023, "%s banned_reason='%s',", query, reason)
			format(query, 1023, "%s history=CONCAT(history, '%d^nBanned by HLGuard %s^nReason: %s^n^n')", query, time_time(), temp, reason_striped)
			format(query, 1023, "%s WHERE steamid='%s'", query, steamid)
			SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)

			alertmessage_v(0, 3, "HLGuard banned %s %s", targetname, temp)
			alertmessage_v(0, 3, "Reason: %s", reason)
		}
	}

	return PLUGIN_HANDLED
}
