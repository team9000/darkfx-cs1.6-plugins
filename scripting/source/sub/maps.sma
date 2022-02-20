#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <sub_maps>
#include <sub_votes>
#include <sub_hud>
#include <sub_storage>
#include <sub_timeleft>

#define RECENT_TIME 6*60*60

#define MAPS_TO_PULL 20
#define MAPS_TO_SELECT 5
#define MAPS_TO_NOMINATE 5
#define MAP_VOTE_TIMELEFT (2*60)
#define ROCKVOTE_RATIO 0.5
#define MAX_EXTEND 3

new start_time
new checkingnom[33]
new Float:nominations_rat[MAPS_TO_NOMINATE]
new nominations[MAPS_TO_NOMINATE][64]
new nominated[33]
new sorted[MAPS_TO_SELECT]
new Float:votelist_rat[MAPS_TO_SELECT]
new votelist[MAPS_TO_SELECT][64]
new next_map[64]
new votemode = 0 // 0 = Not Finished, 1 = Started, 2 = Finished
new rocked[33]
new rocknum
new endsaved = 0
new extendnum = 0

public plugin_init() {
	register_plugin("Subsys - Maps","T9k","Team9000")

	register_concmd("say /rockthevote","say_rockthevote",0,"Votes to rockthevote")
	register_concmd("say rockthevote","say_rockthevote",0,"Votes to rockthevote")
	register_concmd("say rtv","say_rockthevote",0,"Votes to rockthevote")
	register_concmd("say /nextmap","say_nextmap",0,"Displays the nextmap")
	register_concmd("say nextmap","say_nextmap",0,"Displays the nextmap")
	register_concmd("say nominations","say_nominations",0,"Displays the current map nominations")
	register_concmd("say /nominations","say_nominations",0,"Displays the current map nominations")

	register_concmd("say","handle_say")

	votemode = 0
	for(new i = 0; i < 33; i++)
		rocked[i] = 0
	rocknum = 0
	endsaved = 0

	for(new i = 0; i < 33; i++) {
		checkingnom[i] = 0
	}

	set_task(1.0,"maps_query")

	set_task(1.0,"init_countdown")

	for(new i = 0; i < MAPS_TO_SELECT; i++) {
		copy(votelist[i], 63, "de_dust")
		votelist_rat[i] = -1.0
	}

	extendnum = 0

	return PLUGIN_CONTINUE
}

public maps_query() {
	new ident[32]
	get_cvar_string("amx_server_ident_mapset", ident, 31)

	new extrawhere[128] = ""
	if(equal(ident, "climb")) {
		format(extrawhere, 128, " AND setup_climb_waypoints != ''")
	}

	new query[512]
	format(query, 511,
		"SELECT storage_maps.name, AVG(map_ratings.rating)*2 as rating \
		FROM storage_maps LEFT JOIN map_ratings ON storage_maps.name=map_ratings.map \
		WHERE storage_maps.allow='1' AND storage_maps.server_%s='1' AND storage_maps.lasttime<'%d' \
		GROUP BY storage_maps.name \
		ORDER BY RAND() LIMIT %d \
		",
		ident, time_time()-RECENT_TIME, MAPS_TO_PULL);

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_maps", query)
}

public QueryHandled_maps(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_maps", queryran, data, size)
	} else {
		new current_map[64]
		get_mapname(current_map,63)

		new mappos = 0
		for(new i = 0; i < SQL_NumResults(query); i++) {
			new mapname[64] = ""
			new colnum = SQL_FieldNameToNum(query, "name")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, mapname, 63)
			}
			if(!equali(mapname, current_map) && is_map_valid(mapname)) {
				copy(votelist[mappos], 63, mapname)

				new Float:rating;
				colnum = SQL_FieldNameToNum(query, "rating");
				if(colnum != -1) {
					SQL_ReadResult(query, colnum, rating);
					if(rating == 0)
						rating = -1.0;
					votelist_rat[mappos] = rating;
				}
				mappos++;
				if(mappos >= MAPS_TO_SELECT) break;
			}
			SQL_NextRow(query)
		}
	}

	new current_map[64]
	get_mapname(current_map,63)
	if(equal(current_map, "de_dust") || equal(current_map, "de_dust2")) {
		if(!equal(votelist[0], "de_dust")) {
			copy(next_map, 63, votelist[0])
			set_task(2.8,"delayed_showscores")
			set_task(3.0,"delayed_changemap")
		}
	}
}

public plugin_natives() {
	register_library("sub_maps")
}

public client_disconnect(id) {
	if(rocked[id]) rocknum--
	rocked[id] = 0
	checkingnom[id] = 0
	if(nominated[id] != -1) {
		new name[32]
		get_user_name(id,name,31)
		alertmessage_v(0,3,"%s has left, %s is no longer nominated", name, nominations[nominated[id]])
		nominated[id] = -1
	}
}

public client_connect(id) {
	rocked[id] = 0
	nominated[id] = -1
	checkingnom[id] = 0
}

public handle_say(id) {
	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	new name[32]
	get_user_name(id,name,31)

	if(containi(Speech, "nominate ") == 0 && strlen(Speech) > 9) {
		if(votemode == 1) {
			alertmessage_v(id,3,"* Voting is already in progress!") 
			return PLUGIN_HANDLED
		}
		if(votemode == 2) {
			alertmessage_v(id,3,"* Voting has already occured!") 
			return PLUGIN_HANDLED
		}

		new mapname[64], mapname_stripped[64]
		copy(mapname, 63, Speech[9])
		mysql_strip(mapname, mapname_stripped, 63)

		if(isinnominationslist(mapname_stripped)) {
			alertmessage_v(id,3,"That map is already in the nominations list!")
			return PLUGIN_HANDLED
		}
		if(checkingnom[id]) {
			alertmessage_v(id,3,"Please wait until previous nomination is completed")
			return PLUGIN_HANDLED
		}
		checkingnom[id] = 1

		new ident[32]
		get_cvar_string("amx_server_ident_mapset", ident, 31)

		new extrawhere[128] = ""
		if(equal(ident, "climb")) {
			format(extrawhere, 128, " AND setup_climb_waypoints != ''")
		}
	
		new query[512]
		format(query, 511,
			"SELECT storage_maps.name, storage_maps.lasttime, AVG(map_ratings.rating)*2 as rating \
			FROM storage_maps LEFT JOIN map_ratings ON storage_maps.name=map_ratings.map \
			WHERE storage_maps.allow='1' AND storage_maps.server_%s='1' AND storage_maps.name='%s' \
			GROUP BY storage_maps.name \
			ORDER BY RAND() LIMIT %d \
			",
			ident, mapname_stripped, MAPS_TO_PULL);
		new data[1]
		data[0] = id
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled_nominate", query, data, 1)

		alertmessage_v(id,3,"Checking Database...")
		return PLUGIN_HANDLED
	}

	if(containi(Speech, "de_") != -1 || containi(Speech, "cs_") != -1 || containi(Speech, "as_") != -1 || containi(Speech, "fy_") != -1 || containi(Speech, "awp_") != -1 || containi(Speech, "ka_") != -1 || containi(Speech, "he_") != -1 || containi(Speech, "kz_") != -1 || containi(Speech, "surf_") != -1) {
		alertmessage_v(id,3,"If you are attmepting to nominate a map,")
		alertmessage_v(id,3,"you must type the word nominate before the map name")
	}

	return PLUGIN_CONTINUE
}

public QueryHandled_nominate(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
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
			new mapname[64] = "", lasttime_s[32] = "0", lasttime
			new colnum = SQL_FieldNameToNum(query, "name")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, mapname, 63)
			}
			colnum = SQL_FieldNameToNum(query, "lasttime")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, lasttime_s, 31)
			}
			lasttime = str_to_num(lasttime_s)

			if(!is_map_valid(mapname)) {
				alertmessage_v(id,3,"Sorry, that map does not exist on this server") 
				return
			}
			if(lasttime >= time_time()-RECENT_TIME) {
				alertmessage_v(id,3,"%s has been played recently", mapname)
				return
			}

			new empty = -1
			if(nominated[id] != -1) {
				empty = nominated[id]
			} else {
				for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
					if(equal(nominations[i], "")) {
						empty = i
					}
				}
			}
			if(empty == -1) {
				alertmessage_v(id,3,"The nominations list is full!")
				return
			}

			new name[32]
			get_user_name(id,name,31)

			new Float:rating = 0.0;
			colnum = SQL_FieldNameToNum(query, "rating");
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, rating);
				if(rating == 0)
					rating = -1.0;
			}

			if(nominated[id] != -1) {
				new oldmapname[64]
				copy(oldmapname, 63, nominations[nominated[id]])
				alertmessage_v(0,3,"(%s) nominate %s", name, mapname)
				if(rating == -1.0) {
					alertmessage_v(0,3,"%s has replaced his nomination %s with %s (Unknown Rating)", name, oldmapname, mapname)
				} else {
					alertmessage_v(0,3,"%s has replaced his nomination %s with %s (Rated %.1f/10)", name, oldmapname, mapname, rating)
				}
				copy(nominations[nominated[id]], 63, "")
				copy(nominations[empty], 63, mapname)
				nominations_rat[empty] = rating
				nominated[id] = empty
			} else {
				alertmessage_v(0,3,"(%s) nominate %s", name, mapname)
				if(rating == -1.0) {
					alertmessage_v(0,3,"%s has nominated %s (Unknown Rating)", name, mapname)
				} else {
					alertmessage_v(0,3,"%s has nominated %s (Rated %.1f/10)", name, mapname, rating)
				}
				copy(nominations[empty], 63, mapname)
				nominations_rat[empty] = rating
				nominated[id] = empty
			}
		} else {
			alertmessage_v(id,3,"Sorry, that map does not exist on this server") 
		}
	}
}

public say_nextmap(id) {
	new name[32]
	get_user_name(id,name,31)
	alertmessage_v(0,3,"(%s) nextmap", name) 

	if(votemode == 2) {
		alertmessage_v(0,3,"The next map will be %s",next_map) 
	} else {
		alertmessage_v(0,3,"The next map has not yet been voted for") 
	}

	return PLUGIN_HANDLED
}

public delayed_changemap() {
	server_cmd("changelevel %s",next_map)
}

public delayed_showscores() {
	new targetindex, targetname[32]
	if(cmd_targetset(-1, "*", 0, targetname, 31)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex,"+showscores")
		}
	}
}

bool:isinnominationslist(mapname[]) {
	for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
		if(equal(nominations[i], mapname)) {
			return true
		}
	}
	return false 
}

public numrealplayers() {
	new total = 0;
	for(new id = 1; id <= 32; id++)
	{
		if(is_user_connected(id) && !is_user_connecting(id) && !is_user_bot(id))
			total++;
	}
	return total;
}

public say_rockthevote(id) {
	new currentmap[32]
	get_mapname(currentmap, 31)
	if(equal(currentmap, "dfx_newyears_v2")) {
		alertmessage_v(id,3,"* You can't rock newyears! ;)") 
		return PLUGIN_HANDLED
	}

	new maptime = time_time() - start_time
	if(votemode == 1) {
		alertmessage_v(id,3,"* Voting is already in progress!") 
		return PLUGIN_HANDLED
	}
	if(votemode == 2) {
		alertmessage_v(id,3,"* Voting has already occured!") 
		return PLUGIN_HANDLED
	}
	if(maptime < 60*5) {
		alertmessage_v(id,3,"* You cant rockthevote for another %d minutes!", floatround(((60*5) - maptime) / 60.0, floatround_ceil)) 
		return PLUGIN_HANDLED
	}
	if(rocked[id]) {
		alertmessage_v(id,3,"* You cant rockthevote more than once!") 
		return PLUGIN_HANDLED
	}
	new name[32]
	get_user_name(id,name,31)
	rocked[id] = 1
	rocknum++
	new needed = floatround(numrealplayers() * ROCKVOTE_RATIO,floatround_ceil)
	if(rocknum >= needed) {
		alertmessage_v(0,3,"(%s) rockthevote - The vote has been rocked!", name)
		set_thetimeleft(2)
		askfornextmap()
		return PLUGIN_HANDLED
	}
	alertmessage_v(0,3,"(%s) rockthevote - %d more players must rockthevote!", name, needed - rocknum)

	return PLUGIN_HANDLED
}

public say_nominations(id) {
	new message[512]
	format(message, 511, "Current Map Nominations:^n")
	for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
		if(!equal(nominations[i], "")) {
			new playerid = -1
			for(new j = 0; j < 33; j++) {
				if(nominated[j] == i) {
					playerid = j
				}
			}
			if(playerid != -1) {
				new name[32]
				get_user_name(playerid, name, 31)
				format(message, 511, "%s%s, by %s^n", message, nominations[i], name)
			}
		}
	}
	myhud_large(message, id, 10.0, 3, 200, 0, 0, 2, -1.0, 0.30, 0.7, 0.03, 0.5)
}

public askfornextmap() { 
	votemode = 1

	if(get_cvar_num("amx_voting")) {
		set_task(1.0, "askfornextmap")
		return PLUGIN_HANDLED
	}

	new usedrandoms[MAPS_TO_NOMINATE]
	for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
		usedrandoms[i] = -1
	}

	for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
		for(new j = 0; j < MAPS_TO_SELECT; j++) {
			if(equal(nominations[i], votelist[j])) {
				usedrandoms[i] = j
				copy(votelist[j], 63, nominations[i])
			}
		}
	}

	for(new i = 0; i < MAPS_TO_NOMINATE; i++) {
		if(equal(nominations[i], "") || usedrandoms[i] != -1) {
			continue
		}
		new a = 0
		for(;;) {
			a = random_num(0, MAPS_TO_SELECT-1)
			new tryagain = 0
			for(new j = 0; j < MAPS_TO_NOMINATE; j++) {
				if(a == usedrandoms[j]) {
					tryagain = 1
				}
			}
			if(!tryagain) {
				break
			}
		}

		usedrandoms[i] = a
		copy(votelist[a], 63, nominations[i])
		votelist_rat[a] = nominations_rat[i]
	}

	new usedtosort[MAPS_TO_SELECT]
	for(new i = 0; i < MAPS_TO_SELECT; i++) {
		usedtosort[i] = 0
	}

	for(new i = 0; i < MAPS_TO_SELECT; i++) {
		new max = -1
		for(new j = 0; j < MAPS_TO_SELECT; j++) {
			if(usedtosort[j]) {
				continue
			}
			if(votelist_rat[j] < 0.0) {
				max = j
				break
			}
			if(max == -1 || votelist_rat[j] > votelist_rat[max]) {
				max = j
			}
		}
		usedtosort[max] = 1
		sorted[i] = max
	}

	vote_new("analyze_vote", 30, "Choose nextmap:", 2)

	for(new i = 0; i < MAPS_TO_SELECT; i++) {
		new text[128]
		if(votelist_rat[sorted[i]] == -2.0) {
			format(text, 127, "%s \d(Unrated)\w", votelist[sorted[i]])
		} else if(votelist_rat[sorted[i]] == -1.0) {
			format(text, 127, "%s \d(Rating Unknown)\w", votelist[sorted[i]])
		} else {
			format(text, 127, "%s \y(Rated %.1f/10)\w", votelist[sorted[i]], votelist_rat[sorted[i]])
		}
		vote_addoption_hud(text, votelist[sorted[i]])
	}

	if(extendnum < MAX_EXTEND) {
		new current_map[64]
		get_mapname(current_map,63)

		new temp[256]
		format(temp, 255, "Extend 10 minutes \d(\r%d\d Remaining)\w", MAX_EXTEND-extendnum)
		new text[128]
		format(text, 127, "Extend 10 minutes (%d Remaining)", MAX_EXTEND-extendnum)
		vote_addoption_hud(temp, text)
	}

	for(new i = 0; i < 33; i++)
		rocked[i] = 0
	rocknum = 0

	set_cvar_string("amx_voting","1")

	return PLUGIN_HANDLED
} 

public analyze_vote(votes[], results[]) { 
	if(results[0] == MAPS_TO_SELECT) {
		votemode = 0
		set_thetimeleft(10)
		alertmessage_v(0,3,"* The current map will be extended for 10 minutes - %d extends remaining", MAX_EXTEND-extendnum-1) 
		extendnum++

		set_task(0.1, "maps_query")

		for(new i = 0; i < MAPS_TO_SELECT; i++) {
			copy(votelist[i], 63, "de_dust")
			votelist_rat[i] = -1.0
		}
	} else {
		votemode = 2

		copy(next_map, 63, votelist[sorted[results[0]]])
		alertmessage_v(0,3,"* The nextmap will be %s", next_map)
	}

	set_cvar_string("amx_voting","0")
	return PLUGIN_HANDLED
}

public time_remaining(param[]) {
	new tmlf = get_thetimeleft()

	if(votemode == 2) {
		new message[128]
		format(message, 127, "Nextmap: %s^n^n", next_map)
		myhud_small(7, 0, message, -1.0)
	} else {
		new message[128]
		format(message, 127, "Nextmap: Not Voted^n^n")
		myhud_small(7, 0, message, -1.0)
	}

	if(tmlf <= MAP_VOTE_TIMELEFT && votemode == 0) {
		askfornextmap()
	}
	if(tmlf <= 3 && votemode == 2 && !endsaved) {
		endsaved = 1

		set_task(2.8,"delayed_showscores")
		set_task(3.0,"delayed_changemap")
	}
}

public init_countdown() {
	start_time = time_time()
	set_task(0.3,"time_remaining",0,"",0,"b")
}
