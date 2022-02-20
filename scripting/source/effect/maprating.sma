#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>
#include <sub_votes>
#include <sub_timeleft>

#define MAP_VOTE_TIMELEFT (3*60)

new votemode = 0

public plugin_init() {
	register_plugin("Effect - Map Rating","T9k","Team9000")

	set_task(1.0,"init_countdown")
	votemode = 0
}

public storage_register_fw() {
	storage_reg_mapfield("vote_yes")
	storage_reg_mapfield("vote_no")
}

public init_countdown() {
	set_task(5.0,"time_remaining",0,"",0,"b")
}

public time_remaining(param[]) {
	new tmlf = get_thetimeleft()

	if(tmlf <= MAP_VOTE_TIMELEFT && votemode == 0) {
		ratingvote()
	}
}

public ratingvote() {
	votemode = 1

	if(get_cvar_num("amx_voting")) {
		set_task(1.0, "ratingvote")
		return PLUGIN_HANDLED
	}

	vote_new("analyze_results", 30, "Please rate this map", 0)
	vote_setvotecallback("analyze_vote")
	vote_addoption("I HATE THIS MAP!")
	vote_addoption("It's pretty terrible")
	vote_addoption("Meh")
	vote_addoption("I like it")
	vote_addoption("OMG AWESOME!")

	set_cvar_string("amx_voting","1")

	return PLUGIN_HANDLED
}

public analyze_vote(id, key) { 
	if(key < 0 || key > 4) return;
	new vote = key+1;

	new steamid[32]
	get_user_authid(id, steamid, 32)

	if(	equal(steamid, "") ||
		equal(steamid, "STEAM_ID_PENDING") ||
		equal(steamid, "STEAM_ID_LAN") ||
		equal(steamid, "HLTV") ||
		equal(steamid, "BOT")
	) {
		return
	}
	if(is_user_bot(id) || is_user_hltv(id)) {
		return
	}

	new mapname[32], mapname_striped[32]
	get_mapname(mapname,31)
	mysql_strip(mapname, mapname_striped, 31)

	new server_ident[16]
	get_cvar_string("amx_server_ident", server_ident, 15)

	new query[512]
	format(query, 511, "INSERT INTO map_ratings SET steamid='%s', rating='%d', map='%s', server='%s'", steamid, vote, mapname_striped, server_ident)
	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", query)
}

public analyze_results(votes[], results[]) {  
	set_cvar_string("amx_voting","0")
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
}
