#pragma dynamic 65536

#include <amxmodx>
#include <sub_stocks>
#include <sub_setup>
#include <sub_storage>
#include <sub_hud>
#include <engine>
#include <sub_disqualify>
#include <sub_lowresources>
#include <admin_teleport>

#define OPTIONS_PER_PAGE 7
#define MAX_TELEPORTS 21
new telename[MAX_TELEPORTS][128]
new Float:telepos[MAX_TELEPORTS][3]
new Float:teleangle[MAX_TELEPORTS][3]
new setup_mode[33]
new setup_page[33]
new setup_select[33]
new setup_waitingfor[33]
new menutable[33][33]
new menutable_num[33]

new changed

new m_iSpriteTexture

public plugin_init() {
	register_plugin("Admin - Teleport","T9k","Team9000")

	for(new i = 0; i < MAX_TELEPORTS; i++) {
		copy(telename[i], 127, "")
		telepos[i][0] = 0.0
		telepos[i][1] = 0.0
		telepos[i][2] = 0.0
		teleangle[i][0] = 0.0
		teleangle[i][1] = 0.0
		teleangle[i][2] = 0.0
	}

	for(new i = 0; i < 33; i++) {
		setup_waitingfor[i] = 0
	}

	changed = 0
	register_menucmd(register_menuid("DarkMod Setup - Teleports"),1023,"setup_menu")
	register_clcmd("say","handle_say")

	register_clcmd("amx_teleport","teleport",LVL_TELEPORT,"Displays the teleport menu")
	register_clcmd("amx_teleportme","teleportme",LVL_TELEPORTATION,"Displays the teleport menu for yourself")
	register_menucmd(register_menuid("Teleport Menu"),1023,"tele_menu")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("admin_teleport")

	register_native("teleport_playermenu","teleport_playermenu_impl")
}

public teleport_playermenu_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new player = get_param(1)

	if(!(get_user_flags(player) & LVL_TELEPORTATION) && !(get_user_flags(player) & LVL_TELEPORT)) {
		return PLUGIN_HANDLED
	}

	setup_page[player] = 1
	setup_mode[player] = 2
	setup_select[player] = player
	tele_menu(player, -1)

	return 1
}

public client_connect(id) {
	setup_waitingfor[id] = 0
}

public plugin_precache() {
	if(!is_lowresources()) {
		m_iSpriteTexture = precache_model("sprites/shockwave.spr")
		precache_sound("team9000/teleport.wav")
	}
}

public setup_register_fw() {
	setup_registeroption("Teleports", 1)

	setup_registerfield("setup_teleports")
}

public setup_loaded_fw(Handle:query) {
	new value[4096]
	new left[32], right[4096]

	new colnum = SQL_FieldNameToNum(query, "setup_teleports")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 4095)

		for(new i = 0; i < MAX_TELEPORTS; i++) {
			if(equal(value, "")) {
				break
			}

			strtok(value, left, 31, right, 4095, ' ')
			telepos[i][0] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			telepos[i][1] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			telepos[i][2] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			teleangle[i][0] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			teleangle[i][1] = str_to_float(left)
			copy(value, 4095, right)

			strtok(value, left, 31, right, 4095, ' ')
			teleangle[i][2] = str_to_float(left)
			copy(value, 4095, right)

			strbreak(value, telename[i], 127, right, 4095)
			copy(value, 4095, right)
		}
	}
}

public setup_menu_fw(id) {
	setup_waitingfor[id] = 0
	setup_page[id] = 1
	setup_mode[id] = 1
	setup_menu(id, -1)
}

public setup_save() {
	if(!changed) {
		return
	}
	changed = 0

	new current_map[32], current_map_striped[32]
	get_mapname(current_map,31)
	mysql_strip(current_map, current_map_striped, 31)

	new query[4096]
	format(query, 4095, "UPDATE storage_maps SET ")
	format(query, 4095, "%ssetup_teleports='", query)

	for(new i = 0; i < MAX_TELEPORTS; i++) {
		if(i != 0) {
			format(query, 4095, "%s ", query)
		}
		new telename_striped[128]
		mysql_strip(telename[i], telename_striped, 127)

		format(query, 4095, "%s%f %f %f %f %f %f ^"%s^"", query, telepos[i][0], telepos[i][1], telepos[i][2], teleangle[i][0], teleangle[i][1], teleangle[i][2], telename_striped)
	}
	format(query, 4095, "%s'", query)
	format(query, 4095, "%s WHERE name='%s'", query, current_map_striped)

	SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", query)
}

public QueryResend(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, error, errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryResend", queryran, data, size)
	}
}

public handle_say(id) {
	if(setup_waitingfor[id] == 1) {
		setup_menu(id, -1)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public setup_menu(id, key) {
	set_menuopen(id, 0)
	if(setup_mode[id] == 1) {
		if(key == 0) {
			setup_page[id] = 1
			setup_mode[id] = 2
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 1) {
			setup_page[id] = 1
			setup_mode[id] = 3
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_save()
			setup_showmain(id)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Teleports^n")

		new flags = 0

		format(menuBody,2047,"%s\w1. Set Locations^n", menuBody)
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Remove Locations^n", menuBody)
		flags |= (1<<1)
		format(menuBody,511,"%s^n", menuBody)
		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)
		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		new max_page = floatround(float(MAX_TELEPORTS) / OPTIONS_PER_PAGE, floatround_ceil)

		if(setup_waitingfor[id] == 1) {
			new temp[128]
			read_args(temp, 127)
			remove_quotes(temp)
			copy(telename[setup_select[id]], 127, temp)

			entity_get_vector(id, EV_VEC_origin, telepos[setup_select[id]])
			entity_get_vector(id, EV_VEC_v_angle, teleangle[setup_select[id]])

			changed = 1
			setup_waitingfor[id] = 0
		} else {
			new item=-1
			if(key >= 0 && key < OPTIONS_PER_PAGE) {
				item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
			}
			if(key == 7 && setup_page[id] > 1) {
				setup_page[id] -= 1
			}
			if(key == 8 && setup_page[id] < max_page) {
				setup_page[id] += 1
			}
			if(key == 9) {
				setup_mode[id] = 1
				setup_menu(id, -1)
				return PLUGIN_HANDLED
			}

			if(item != -1 && item < MAX_TELEPORTS) {
				setup_select[id] = item
				setup_waitingfor[id] = 1
				client_cmd(id, "messagemode")
				return PLUGIN_HANDLED
			}
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Teleports^n")
		format(menuBody,2047,"%s\dSet Locations^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < MAX_TELEPORTS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			format(menuBody,2047,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, telename[i])

			flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
		}

		format(menuBody,511,"%s^n", menuBody)

		if(setup_page[id] > 1) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < max_page) {
			format(menuBody,511,"%s\y9. More^n", menuBody)
			flags |= (1<<8)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 3) {
		new max_page = floatround(float(MAX_TELEPORTS) / OPTIONS_PER_PAGE, floatround_ceil)

		new item=-1
		if(key >= 0 && key < OPTIONS_PER_PAGE) {
			item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
		}
		if(key == 7 && setup_page[id] > 1) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < max_page) {
			setup_page[id] += 1
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		if(item != -1 && item < MAX_TELEPORTS) {
			copy(telename[item], 127, "")
			changed = 1
		}

		new menuBody[2048]
		format(menuBody,2047,"\yDarkMod Setup - Teleports^n")
		format(menuBody,2047,"%s\dRemove Locations^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < MAX_TELEPORTS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			if(equal(telename[i], "")) {
				format(menuBody,2047,"%s\d%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, telename[i])
			} else {
				format(menuBody,2047,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, telename[i])

				flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		if(setup_page[id] > 1) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < max_page) {
			format(menuBody,511,"%s\y9. More^n", menuBody)
			flags |= (1<<8)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}

	return PLUGIN_HANDLED
}

public teleport(id, level, cid) {
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED
	setup_page[id] = 1
	setup_mode[id] = 1
	generate_menutable(id)
	tele_menu(id, -1)
	return PLUGIN_HANDLED
}

public teleportme(id, level, cid) {
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED
	setup_page[id] = 1
	setup_mode[id] = 2
	setup_select[id] = id
	tele_menu(id, -1)
	return PLUGIN_HANDLED
}

public generate_menutable(id) {
	new targetindex, targetname[33]
	new i = 0
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			menutable[id][i] = targetindex
			i++
		}
	}
	menutable_num[id] = i
}

public tele_menu(id, key) {
	set_menuopen(id, 0)

	if(setup_mode[id] == 1) {
		new max_page = floatround(float(menutable_num[id]) / OPTIONS_PER_PAGE, floatround_ceil)

		new item=-1
		if(key >= 0 && key < OPTIONS_PER_PAGE) {
			item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
		}
		if(key == 7 && setup_page[id] > 1) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < max_page) {
			setup_page[id] += 1
		}
		if(key == 9) {
			return PLUGIN_HANDLED
		}

		if(item != -1 && item < menutable_num[id]) {
			setup_page[id] = 1
			setup_mode[id] = 2
			setup_select[id] = menutable[id][item]
			tele_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeleport Menu^n")
		format(menuBody,2047,"%s\dSelect Player^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < menutable_num[id] && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			if(!is_user_connected(menutable[id][i]) || is_user_connecting(menutable[id][i]) || !is_user_alive(menutable[id][i])) {
				format(menuBody,2047,"%s\d%d.^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)
			} else {
				new name[64]
				get_user_name(menutable[id][i], name, 63)
				format(menuBody,2047,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, name)

				flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		if(setup_page[id] > 1) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < max_page) {
			format(menuBody,511,"%s\y9. More^n", menuBody)
			flags |= (1<<8)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		if(!is_user_connected(setup_select[id]) || is_user_connecting(setup_select[id]) || !is_user_alive(setup_select[id])) {
			if(get_user_flags(id) & LVL_TELEPORT) {
				setup_page[id] = 1
				setup_mode[id] = 1
				generate_menutable(id)
				tele_menu(id, -1)
				return PLUGIN_HANDLED
			} else {
				return PLUGIN_HANDLED
			}
		}

		new max_page = floatround(float(MAX_TELEPORTS) / OPTIONS_PER_PAGE, floatround_ceil)

		new item=-1
		if(key >= 0 && key < OPTIONS_PER_PAGE) {
			item = ((setup_page[id]-1)*OPTIONS_PER_PAGE)+key
		}
		if(key == 7 && setup_page[id] > 1) {
			setup_page[id] -= 1
		}
		if(key == 8 && setup_page[id] < max_page) {
			setup_page[id] += 1
		}
		if(key == 9) {
			if(get_user_flags(id) & LVL_TELEPORT) {
				setup_page[id] = 1
				setup_mode[id] = 1
				generate_menutable(id)
				tele_menu(id, -1)
				return PLUGIN_HANDLED
			} else {
				return PLUGIN_HANDLED
			}
		}

		if(item != -1 && item < MAX_TELEPORTS) {
			new origin[3]
			get_user_origin(setup_select[id], origin)

			if(!is_lowresources()) {
				message_begin( MSG_PAS, SVC_TEMPENTITY, origin )
				write_byte( 21 )
				write_coord( origin[0])
				write_coord( origin[1])
				write_coord( origin[2] + 10)
				write_coord( origin[0])
				write_coord( origin[1])
				write_coord( origin[2] + 60)
				write_short( m_iSpriteTexture )
				write_byte( 0 ) // startframe
				write_byte( 0 ) // framerate
				write_byte( 3 ) // life
				write_byte( 60 )  // width
				write_byte( 0 )	// noise
				write_byte( 255 )  // red
				write_byte( 255 )  // green
				write_byte( 255 )  // blue
				write_byte( 255 ) //brightness
				write_byte( 0 ) // speed
				message_end()
			}

			new Float:angle[3] = {0.0,0.0,0.0}
			entity_set_vector(setup_select[id], EV_VEC_origin, telepos[item])
			entity_set_vector(setup_select[id], EV_VEC_angles, teleangle[item])
			entity_set_int(setup_select[id], EV_INT_fixangle, 1)
			entity_set_vector(setup_select[id], EV_VEC_velocity, angle)
			disqualify_now(setup_select[id], 8)

			if(!is_lowresources()) {
				emit_sound(setup_select[id],CHAN_STATIC, "team9000/teleport.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				message_begin( MSG_PAS, SVC_TEMPENTITY, origin )
				write_byte( 21 )
				write_coord( floatround(telepos[item][0]))
				write_coord( floatround(telepos[item][1]))
				write_coord( floatround(telepos[item][2]) + 10)
				write_coord( floatround(telepos[item][0]))
				write_coord( floatround(telepos[item][1]))
				write_coord( floatround(telepos[item][2]) + 60)
				write_short( m_iSpriteTexture )
				write_byte( 0 ) // startframe
				write_byte( 0 ) // framerate
				write_byte( 3 ) // life
				write_byte( 60 )  // width
				write_byte( 0 )	// noise
				write_byte( 255 )  // red
				write_byte( 255 )  // green
				write_byte( 255 )  // blue
				write_byte( 255 ) //brightness
				write_byte( 0 ) // speed
				message_end()
			}

			if(get_user_flags(id) & LVL_TELEPORT) {
				new name[64]
				get_user_name(setup_select[id], name, 63)
				adminalert_v(id, "", "teleported %s to ^"%s^"", name, telename[item])
			}

			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeleport Menu^n")
		format(menuBody,2047,"%s\dSelect Location^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < MAX_TELEPORTS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			if(equal(telename[i], "")) {
				format(menuBody,2047,"%s\d%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, telename[i])
			} else {
				format(menuBody,2047,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, telename[i])

				flags |= (1<<((i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1)-1))
			}
		}

		format(menuBody,511,"%s^n", menuBody)

		if(setup_page[id] > 1) {
			format(menuBody,511,"%s\y8. Back^n", menuBody)
			flags |= (1<<7)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		if(setup_page[id] < max_page) {
			format(menuBody,511,"%s\y9. More^n", menuBody)
			flags |= (1<<8)
		} else {
			format(menuBody,511,"%s^n", menuBody)
		}

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}

	return PLUGIN_HANDLED
}
