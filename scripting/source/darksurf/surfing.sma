#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <darksurf.inc>
#include <sub_roundtime>
#include <sub_storage>
#include <sub_disqualify>
#include <fun>
#include <sub_damage>
#include <sub_respawn>

// 0 = SPAWNING
// 1 = HASNT LEFT PLATFORM
// 2 = SURFING
// 3 = FINISHED
// 4 = RESULTS ARE IN
new surfmode[33]

new Float:top_hangtime[33]
new Float:top_speed[33]
new Float:top_dist[33]
new Float:top_height[33]

new Float:surf_time[33]
new Float:surf_hangtime[33]
new Float:surf_speed[33]
new Float:surf_dist[33]
new Float:surf_height[33]

new record_time[33]
new record_hangtime[33]
new record_speed[33]
new record_dist[33]
new record_height[33]

new offtillrespawn[33]
new oldinair[33]
new Float:leftramp[33]
new Float:leftramppos[33][3]
new Float:spawntime[33]
new Float:leftplatform[33]
new Float:oldvelocity[33][3]
new Float:safetytime[33];

public plugin_init() {
   	register_plugin("DARKSURF - SURFING","T9k","Team9000")

	register_touch("trigger_teleport", "player", "touch_teleport")
	register_touch("player", "worldspawn", "touch_world")
	register_touch("player", "func_water", "touch_world")
	register_touch("player", "func_wall", "touch_world")
	register_touch("player", "func_breakable", "touch_world")

	set_task(0.04, "check_players", 0, "", 0, "b")

	return PLUGIN_CONTINUE
}
public plugin_natives() {
	register_library("darksurf_surfing")
}

public dam_respawn(id) {
	offtillrespawn[id] = 0;
	if(disqualify_get(id) != -1) {
		if(disqualify_get(id) != 1) {
			offtillrespawn[id] = 2;
		} else {
			offtillrespawn[id] = 1;
		}
	}

	spawntime[id] = get_gametime();
	safetytime[id] = get_gametime();
	surfmode[id] = 0;
	leftramp[id] = 0.0;
	leftplatform[id] = 0.0;
	oldinair[id] = 0;

	surf_time[id] = 0.0
	surf_hangtime[id] = top_hangtime[id] = 0.0
	surf_dist[id] = top_dist[id] = 0.0
	surf_height[id] = top_height[id] = 0.0
	surf_speed[id] = top_speed[id] = 0.0

	record_time[id] = 0
	record_hangtime[id] = 0
	record_dist[id] = 0
	record_height[id] = 0
	record_speed[id] = 0
}

public on_platform(id) {
	// 0 means they left the platform
	new flags = entity_get_int(id, EV_INT_flags)
	new movetype = entity_get_int(id,EV_INT_movetype)

	if(movetype != MOVETYPE_WALK)
		return 0;
	if(flags & FL_ONGROUND || flags & FL_PARTIALGROUND || flags & FL_INWATER)
		return 1;

	return 0;
}
public in_air(id) {
	// 1 means they are in the air and eligable for trick points
	new flags = entity_get_int(id, EV_INT_flags)
	new movetype = entity_get_int(id,EV_INT_movetype)

	new Float:thisoldvelocity[3];
	thisoldvelocity[0] = oldvelocity[id][0];
	thisoldvelocity[1] = oldvelocity[id][1];
	thisoldvelocity[2] = oldvelocity[id][2];
	entity_get_vector(id,EV_VEC_velocity,oldvelocity[id]);

	if(safetytime[id] > get_gametime()-0.1) return 0;
	if(movetype != MOVETYPE_WALK)
		return 0;
	if(flags & FL_ONGROUND || flags & FL_PARTIALGROUND || 
		flags & FL_INWATER || flags & FL_CONVEYOR || flags & FL_FLOAT)
			return 0;
	if(flags & FL_BASEVELOCITY) // prevent hovering on a trigger_push
		return 0;

	new Float:newvelocity[3]
	entity_get_vector(id,EV_VEC_velocity,newvelocity)
	if(get_speed(id) < 1980) {
		if(newvelocity[2] >= thisoldvelocity[2])
			return 0;
	}

	//check for a serious ladder exploit
	// only applies to old spawn system
	new Float:origin[3]
	entity_get_vector(id, EV_VEC_origin, origin)
	new startEnt = -1, cn[64]
	while((startEnt = find_ent_in_sphere(startEnt,origin,45.0)) != 0)  {
		if(is_user_connected(startEnt) || !is_valid_ent(startEnt)) continue

		entity_get_string(startEnt,EV_SZ_classname,cn,63)
		if(equal(cn,"func_ladder") || equal(cn,"func_pushable")) {
			return 0
		}
	}

	return 1
}
public touch_teleport(teleport, id) {
	safetytime[id] = get_gametime()
}
public touch_world(id, world) {
	safetytime[id] = get_gametime()
}

public disqualify_now_fw(id, reason) {
	if(reason != 0) {
		offtillrespawn[id] = 2
	} else if(!offtillrespawn[id]) {
		offtillrespawn[id] = 1
	}
}

public disqualify_changed_fw(id) {
	if(disqualify_get(id) != -1) {
		if(disqualify_get(id) != 1) {
			offtillrespawn[id] = 2
		} else if(!offtillrespawn[id]) {
			offtillrespawn[id] = 1
		}
	}
}

public placetext(place,name[],len) {
	if(place == 1)
		format(name, len, "1st")
	else if(place == 2)
		format(name, len, "2nd")
	else if(place == 3)
		format(name, len, "3rd")
	else
		format(name, len, "%dth", place)
}
public check_player(id) {
	if((cs_get_user_team(id) != CS_TEAM_T && cs_get_user_team(id) != CS_TEAM_CT) || !is_user_alive(id)) {
		myhud_small(9, id, "", -1.0)
		return
	}

	update_stats(id);
	if(disqualify_get(id) != -1) {
		if(disqualify_get(id) != 1) {
			offtillrespawn[id] = 2;
		} else if(!offtillrespawn[id]) {
			offtillrespawn[id] = 1;
		}
	}
	if(surfmode[id] == 0 && spawntime[id] < get_gametime()-0.5) {
		surfmode[id] = 1;
	} else if(surfmode[id] == 1 && !on_platform(id)) {
		surfmode[id] = 2;
		leftplatform[id] = get_gametime();
	}

	new message[512]
	format(message, 511, "")
	if(offtillrespawn[id] == 1) {
		if(disqualify_get(id) == -1) {
			format(message, 511, "%sDISQUALIFIED UNTIL RESPAWN^n", message)
		} else {
			format(message, 511, "%sDISQUALIFIED DUE TO SKILLS^n", message)
		}
	} else if(offtillrespawn[id] == 2) {
		format(message, 511, "%sDISQUALIFIED DUE TO ADMIN COMMAND^n", message)
	} else {
		format(message, 511, "%sTYPE /skills TO USE SKILLS^n", message)
	}
	
	if(!surf_get_finishon()) {
		format(message, 511, "%sWARNING! NO FINISH SET!^n", message);
	}
	if(surfmode[id] == 3) {
		format(message, 511, "%sSUBMITTING RESULTS...^n", message, surf_time[id])
	}

	if(surfmode[id] <= 2) {
		format(message, 511, "%sTime Elapsed: %.2f^n", message, surf_time[id])
	} else if(surfmode[id] == 4) {
		if(record_time[id] > 0) {
			new place[16]
			placetext(record_time[id], place, 16);
			format(message, 511, "%sCompleted Map: %.2f - NEW RECORD! %s PLACE!^n", message, surf_time[id], place)
		} else {
			format(message, 511, "%sCompleted Map: %.2f^n", message, surf_time[id])
		}
	}

	if(surfmode[id] < 2) {
		format(message, 511, "%sSpeed: %.2f MPH^n", message, surf_speed[id])
	} else if(surfmode[id] == 2) {
		format(message, 511, "%sSpeed: %.2f/%.2f MPH^n", message, surf_speed[id], top_speed[id])
	} else if(surfmode[id] == 4) {
		if(record_speed[id] > 0) {
			new place[16]
			placetext(record_speed[id], place, 16);
			format(message, 511, "%sMax Speed: %.2f MPH - NEW RECORD! %s PLACE!^n", message, top_speed[id], place)
		} else {
			format(message, 511, "%sMax Speed: %.2f MPH^n", message, top_speed[id])
		}
	}

	if(surfmode[id] < 2) {
		format(message, 511, "%sDistance: %.2f FT^n", message, surf_dist[id])
	} else if(surfmode[id] == 2) {
		format(message, 511, "%sDistance: %.2f/%.2f FT^n", message, surf_dist[id], top_dist[id])
	} else if(surfmode[id] == 4) {
		if(record_dist[id] > 0) {
			new place[16]
			placetext(record_dist[id], place, 16);
			format(message, 511, "%sMax Distance: %.2f FT - NEW RECORD! %s PLACE!^n", message, top_dist[id], place)
		} else {
			format(message, 511, "%sMax Distance: %.2f FT^n", message, top_dist[id])
		}
	}

	if(surfmode[id] < 2) {
		format(message, 511, "%sHeight: %.2f FT^n", message, surf_height[id])
	} else if(surfmode[id] == 2) {
		format(message, 511, "%sHeight: %.2f/%.2f FT^n", message, surf_height[id], top_height[id])
	} else if(surfmode[id] == 4) {
		if(record_height[id] > 0) {
			new place[16]
			placetext(record_height[id], place, 16);
			format(message, 511, "%sMax Height: %.2f FT - NEW RECORD! %s PLACE!^n", message, top_height[id], place)
		} else {
			format(message, 511, "%sMax Height: %.2f FT^n", message, top_height[id])
		}
	}

	if(surfmode[id] < 2) {
		format(message, 511, "%sHangtime: %.2f^n", message, surf_hangtime[id])
	} else if(surfmode[id] == 2) {
		format(message, 511, "%sHangtime: %.2f/%.2f^n", message, surf_hangtime[id], top_hangtime[id])
	} else if(surfmode[id] == 4) {
		if(record_hangtime[id] > 0) {
			new place[16]
			placetext(record_hangtime[id], place, 16);
			format(message, 511, "%sMax Hangtime: %.2f - NEW RECORD! %s PLACE!^n", message, top_hangtime[id], place)
		} else {
			format(message, 511, "%sMax Hangtime: %.2f^n", message, top_hangtime[id])
		}
	}

	myhud_small(9, id, message, -1.0)
}
public check_players() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(is_user_bot(targetindex) || is_user_hltv(targetindex)) {
				continue
			}

			check_player(targetindex)
		}
	}
}

public update_stats(id) {
	new inair = in_air(id)
	if(inair && !oldinair[id]) {
		leftramp[id] = get_gametime()
		entity_get_vector(id, EV_VEC_origin, leftramppos[id])
	}
	oldinair[id] = inair;

	if(!inair) {
		surf_hangtime[id] = 0.0;
		surf_speed[id] = 0.0;
		surf_dist[id] = 0.0;
		surf_height[id] = 0.0;
	} else {
		// hangtime
		surf_hangtime[id] = get_gametime() - leftramp[id]
		
		// speed
		surf_speed[id] = float(get_speed(id)) / 18.0

		// distance
		new Float:currentpos[3]
		entity_get_vector(id, EV_VEC_origin, currentpos)
		currentpos[2] = 0.0
		new Float:startpos[3]
		startpos[0] = leftramppos[id][0]
		startpos[1] = leftramppos[id][1]
		startpos[2] = 0.0
		surf_dist[id] = vector_distance(startpos, currentpos) / 16.5

		// height
		entity_get_vector(id, EV_VEC_origin, currentpos)
		surf_height[id] = (currentpos[2] - leftramppos[id][2]) / 8.0
		if(surf_height[id] < 0.0)
			surf_height[id] = 0.0
	}

	if(surfmode[id] < 2) {
		top_hangtime[id] = 0.0;
		top_speed[id] = 0.0;
		top_dist[id] = 0.0;
		top_height[id] = 0.0;
		surf_time[id] = 0.0;
	} else if(surfmode[id] == 2) {
		top_hangtime[id] = floatmax(top_hangtime[id], surf_hangtime[id]);
		top_speed[id] = floatmax(top_speed[id], surf_speed[id]);
		top_dist[id] = floatmax(top_dist[id], surf_dist[id]);
		top_height[id] = floatmax(top_height[id], surf_height[id]);
		surf_time[id] = get_gametime() - leftplatform[id];
	}
}

public surf_finished(id) {
	if(surfmode[id] >= 3) return;
	if(surfmode[id] != 2 || surf_time[id] < 3) {
		surfmode[id] = 4;
		return;
	}
	update_stats(id);
	surfmode[id] = 3;

	// Reset player position
	new Float:finishorigin[3]
	surf_get_finish(finishorigin)
	new Float:angle[3] = {0.0,0.0,0.0}
	entity_set_vector(id, EV_VEC_velocity, angle)
	new Float:neworigin[3]
	neworigin[0] = finishorigin[0]
	neworigin[1] = finishorigin[1]
	neworigin[2] = finishorigin[2]+5
	entity_set_vector(id, EV_VEC_origin, neworigin)

	// Fetch and update map worth
	new mapworth = surf_mapworth_get();
	if(mapworth <= 0) mapworth = max(100,floatround(surf_time[id]));
	if(!offtillrespawn[id])
		surf_mapworth_add(surf_time[id]);

	// Print message and give points
	new rating[32], points = 0
	if(surf_time[id] > mapworth*3) {
		rating = "EXTREMELY SLOW"
	} else if(surf_time[id] > mapworth*2) {
		rating = "VERY SLOW"
	} else if(surf_time[id] > mapworth*1.5) {
		rating = "SLOW"
	} else if(surf_time[id] > mapworth*0.8) {
		rating = "AVERAGE"
	} else if(surf_time[id] > mapworth*0.6) {
		rating = "VERY FAST"
	} else {
		rating = "EXTREMELY FAST"
	}
	new message[512]
	format(message, 511, "CONGRATULATIONS - You have completed the map in %.2f seconds^n", surf_time[id])
	if(mapworth > 0) {
		format(message, 511, "%sCompared to average, your completion time is %s^n", message, rating)
	}
	format(message, 511, "%s^n", message)

	if(offtillrespawn[id]) {
		if(surf_time[id] > mapworth) {
			points = floatround(mapworth / 2.0)
		} else {
			if(offtillrespawn[id] == 1) {
				points = floatround(surf_time[id] / 2.0)
			} else {
				points = floatround(surf_time[id] / 4.0)
			}
		}
		if(offtillrespawn[id] == 1) {
			format(message, 511, "%sBecause you used RED skills, you only get %d points!", message, points)
		} else {
			format(message, 511, "%sBecause you were disqualified, you only get %d points!", message, points)
		}
	} else {
		points = mapworth
		format(message, 511, "%sYou got %d points!^n", message, points)
	}

	myhud_large(message, id, 10.0, 3, 0, 200, 0, 2, -1.0, 0.30, 0.7, 0.02, 0.5)

	surf_setpoints(id, surf_getpoints(id) + points)
	surf_updatepointshud(id)

	// RECORD TIME!
	// Ridiculous mysql query - here we go!!!
	if(offtillrespawn[id]) return;

	new steamid[32], steamid_safe[32]
	get_user_authid(id, steamid, 31)
	mysql_strip(steamid, steamid_safe, 31)
	new map[32], map_safe[32]
	get_mapname(map,31)
	mysql_strip(map, map_safe, 31)
	
/*

SELECT addRecord('surf_time', 1, 'test', 'surf_water-run', 8.7);

DELIMITER //
DROP FUNCTION IF EXISTS addRecord//
CREATE FUNCTION addRecord (in_type VARCHAR(32), smallerIsBetter INTEGER, in_steamid VARCHAR(32), in_map VARCHAR(32), in_value FLOAT)
	RETURNS INT

	BEGIN
		DECLARE oldrecordid INT;
		DECLARE oldvalue FLOAT;
		SELECT recordid, value INTO oldrecordid, oldvalue FROM map_records WHERE `steamid`=in_steamid AND `type`=in_type AND `map`=in_map LIMIT 1;
		IF oldrecordid IS NULL
		THEN
			INSERT INTO map_records SET `steamid`=in_steamid, `type`=in_type, `map`=in_map, `value`=in_value;
		ELSE
			IF (smallerIsBetter <> 0 AND in_value < oldvalue) OR (smallerIsBetter = 0 AND in_value > oldvalue)
			THEN
				UPDATE map_records SET `value`=in_value WHERE `recordid`=oldrecordid;
			ELSE
				RETURN 0;
			END IF;
		END IF;

		IF smallerIsBetter <> 0
		THEN
			RETURN (SELECT COUNT(*)+1 FROM map_records WHERE `type`=in_type AND `map`=in_map AND `value` < in_value);
		ELSE
			RETURN (SELECT COUNT(*)+1 FROM map_records WHERE `type`=in_type AND `map`=in_map AND `value` > in_value);
		END IF;
	END //
DELIMITER ;
*/

	new query[2048];
	format(query, 2047, "SELECT ");
	format(query, 2047, "%s addRecord('surf_time', 1, '%s', '%s', '%f') as rank_time, ", query, steamid_safe, map_safe, surf_time[id]);
	format(query, 2047, "%s addRecord('surf_speed', 0, '%s', '%s', '%f') as rank_speed, ", query, steamid_safe, map_safe, top_speed[id]);
	format(query, 2047, "%s addRecord('surf_dist', 0, '%s', '%s', '%f') as rank_dist, ", query, steamid_safe, map_safe, top_dist[id]);
	format(query, 2047, "%s addRecord('surf_height', 0, '%s', '%s', '%f') as rank_height, ", query, steamid_safe, map_safe, top_height[id]);
	format(query, 2047, "%s addRecord('surf_hangtime', 0, '%s', '%s', '%f') as rank_hangtime", query, steamid_safe, map_safe, top_hangtime[id]);

	new data[1];
	data[0] = id;
	admin_log(query);
	SQL_ThreadQuery(storage_get_dbinfo(), "RecordAdded", query, data, 1);
}

public RecordAdded(failstate, Handle:query, error[], errnum, data[], size) {
	new id = data[0];
	if(surfmode[id] != 3) return;
	surfmode[id] = 4;

	if(!mysql_check(failstate, query, error, errnum, storage_get_debug()))
		return;

	if(SQL_NumResults(query) <= 0)
		return;
		
	new colnum;

	colnum = SQL_FieldNameToNum(query, "rank_time")
	if(colnum == -1) return;
	record_time[id]  = SQL_ReadResult(query, colnum)

	colnum = SQL_FieldNameToNum(query, "rank_speed")
	if(colnum == -1) return;
	record_speed[id]  = SQL_ReadResult(query, colnum)
	
	colnum = SQL_FieldNameToNum(query, "rank_dist")
	if(colnum == -1) return;
	record_dist[id]  = SQL_ReadResult(query, colnum)
	
	colnum = SQL_FieldNameToNum(query, "rank_height")
	if(colnum == -1) return;
	record_height[id]  = SQL_ReadResult(query, colnum)
	
	colnum = SQL_FieldNameToNum(query, "rank_hangtime")
	if(colnum == -1) return;
	record_hangtime[id]  = SQL_ReadResult(query, colnum)
}
