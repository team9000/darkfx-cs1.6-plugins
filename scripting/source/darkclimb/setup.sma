#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_setup>
#include <sub_storage>
#include <darkclimb.inc>
#include <settings>
#include <sub_hud>
#include <effect_semiclip>

new beam

#define OPTIONS_PER_PAGE 7
new setup_page[33]
new setup_mode[33]
new setup_origin[33][3]
new setup_waitingfor[33]
new changed

public plugin_init() {
	register_plugin("DARKCLIMB - SETUP","T9k","Team9000")

	changed = 0

	for(new i = 0; i < 33; i++) {
		setup_waitingfor[i] = 0
	}

	register_clcmd("say","handle_say")
	register_menucmd(register_menuid("Team9000 Setup - DARKCLIMB"),1023,"setup_menu")

	set_task(5.0, "drawboxes", 0, "", 0, "b")
}

public plugin_precache() {
	beam = precache_model("sprites/zbeam4.spr")
}

public client_connect(id) {
	setup_waitingfor[id] = 0
}

public plugin_natives() {
	register_library("darkclimb_setup")
}

public setup_register_fw() {
	setup_registeroption("DARKCLIMB", 1)

	new key[32]
	for(new i = 0; i < climb_get_numskills(); i++) {
		new skillshort[32]
		climb_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_climb_skill_%s", skillshort)
		setup_registerfield(key)
	}

	setup_registerfield("setup_climb_waypoints")
}

public setup_loaded_fw(Handle:query) {
	new key[32], value[4096]
	for(new i = 0; i < climb_get_numskills(); i++) {
		new skillshort[32]
		climb_get_skillshort(i, skillshort, 31)
		format(key, 31, "setup_climb_skill_%s", skillshort)

		new colnum = SQL_FieldNameToNum(query, key)
		if(colnum != -1) {
			SQL_ReadResult(query, colnum, value, 63)
			climb_set_skillactive(i, str_to_num(value))
		}
	}

	climb_clearlocations()

	new left[32], right[4096]
	new colnum = SQL_FieldNameToNum(query, "setup_climb_waypoints")
	if(colnum != -1) {
		SQL_ReadResult(query, colnum, value, 4095)

		if(!equal(value, "")) {
			for(new i = 0; i < 10; i++) {
				new temp[7]
				for(new j = 0; j < 7; j++) {
					strtok(value, left, 31, right, 4095, ' ')
					temp[j] = str_to_num(left)
					copy(value, 4095, right)
				}
				climb_setarea(i, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6])
			}
			for(new i = 0; i < 5; i++) {
				new temp[4]
				for(new j = 0; j < 4; j++) {
					strtok(value, left, 31, right, 4095, ' ')
					temp[j] = str_to_num(left)
					copy(value, 4095, right)
				}
				climb_setbutton(i, temp[0], temp[1], temp[2], temp[3])
			}
			for(new i = 0; i < 7; i++) {
				strtok(value, left, 31, right, 4095, ' ')
				climb_setfeature(i, str_to_num(left))
				copy(value, 4095, right)
			}
		}
	}
}

public setup_menu_fw(id) {
	setup_page[id] = 1
	setup_mode[id] = 1
	setup_waitingfor[id] = 0
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
	for(new i = 0; i < climb_get_numskills(); i++) {
		new skillshort[32]
		climb_get_skillshort(i, skillshort, 31)
		format(query, 4095, "%ssetup_climb_skill_%s='%d', ", query, skillshort, climb_get_skillactive(i))
	}

	format(query, 4095, "%ssetup_climb_waypoints='", query)

	for(new i = 0; i < 10; i++) {
		new temp[7]
		climb_getarea(i, temp)
		for(new j = 0; j < 7; j++) {
			if(!(i == 0 && j == 0)) {
				format(query, 4095, "%s ", query)
			}
			format(query, 4095, "%s%d", query, temp[j])
		}
	}
	for(new i = 0; i < 5; i++) {
		new temp[4]
		climb_getbutton(i, temp)
		for(new j = 0; j < 4; j++) {
			format(query, 4095, "%s %d", query, temp[j])
		}
	}

	for(new i = 0; i < 7; i++) {
		new temp = climb_getfeature(i)
		format(query, 4095, "%s %d", query, temp)
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
	if(setup_waitingfor[id] == 0) {
		set_menuopen(id, 0)
	}

	setup_waitingfor[id] = 0

	if(setup_mode[id] == 1) {
		if(key == 0) {
			setup_page[id] = 1
			setup_mode[id] = 2
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 1) {
			climb_clearlocations()
			changed = 1
		}
		if(key == 2) {
			get_user_origin(id, setup_origin[id])
			setup_mode[id] = 3
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 3) {
			setup_mode[id] = 4
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 4) {
			setup_mode[id] = 6
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 0
			setup_save()
			setup_showmain(id)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DARKCLIMB^n")

		new flags = 0

		format(menuBody,2047,"%s\w1. Skills^n^n", menuBody)
		flags |= (1<<0)

		format(menuBody,2047,"%s\w2. \rClear All^n", menuBody)
		flags |= (1<<1)
		format(menuBody,2047,"%s\w3. Set Area^n", menuBody)
		flags |= (1<<2)
		format(menuBody,2047,"%s\w4. Set Button^n^n", menuBody)
		flags |= (1<<3)

		format(menuBody,2047,"%s5. Features^n", menuBody)
		flags |= (1<<4)

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 2) {
		new max_page = floatround(float(climb_get_numskills()) / OPTIONS_PER_PAGE, floatround_ceil)

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

		if(item != -1 && item < climb_get_numskills()) {
			climb_set_skillactive(item, climb_get_skillactive(item)+1)
			if(climb_get_skillactive(item) > 1) {
				climb_set_skillactive(item, -1)
			}
			changed = 1
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DARKCLIMB^n")
		format(menuBody,2047,"%s\dSkills^n", menuBody)

		new flags = 0

		for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < climb_get_numskills() && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
			new skillname[32]
			climb_get_skillname(i, skillname, 31)
			format(menuBody,2047,"%s\w%d. %s ", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, skillname)
			if(climb_get_skillactive(i) == -1) {
				format(menuBody,2047,"%s(\dDefault\w)^n", menuBody)
			} else if(climb_get_skillactive(i) == 0) {
				format(menuBody,2047,"%s(\rDisabled\w)^n", menuBody)
			} else {
				format(menuBody,2047,"%s(\yEnabled\w)^n", menuBody)
			}

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
		if(key >= 0 && key <= 3) {
			new origin[3]
			get_user_origin(id, origin)
			new temp[7]
			for(new i = 0; i < 10; i++) {
				climb_getarea(i, temp)
				if(temp[0] == 0) {
					temp[0] = key+1
					temp[1] = min(origin[0], setup_origin[id][0])
					temp[2] = min(origin[1], setup_origin[id][1])
					temp[3] = min(origin[2], setup_origin[id][2])
					temp[4] = max(origin[0], setup_origin[id][0])
					temp[5] = max(origin[1], setup_origin[id][1])
					temp[6] = max(origin[2], setup_origin[id][2])
					climb_setarea(i, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6])
					break
				}
			}

			changed = 1

			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DARKCLIMB^n")
		format(menuBody,2047,"%s\dSet Area^n^n", menuBody)

		new flags = 0

		format(menuBody,2047,"%s\w1. Entrance^n", menuBody)
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Exit^n", menuBody)
		flags |= (1<<1)
		format(menuBody,2047,"%s\w3. Finish^n", menuBody)
		flags |= (1<<2)
		format(menuBody,2047,"%s\w4. Shortcut^n^n", menuBody)
		flags |= (1<<3)

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Cancel", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 4) {
		if(key >= 0 && key <= 3) {
			new button = -1, found = 0, Float:buttonorigf[3], buttonorig[3], origin[3]
			get_user_origin(id, origin)

			for(;;) {
				button = find_ent_by_class(button, "func_button")
				if(!button) {
					break
				}

				get_brush_entity_origin(button, buttonorigf)
				buttonorig[0] = floatround(buttonorigf[0])
				buttonorig[1] = floatround(buttonorigf[1])
				buttonorig[2] = floatround(buttonorigf[2])
				if(origin[0] > buttonorig[0] - BUTTON_DISTANCE &&
				origin[1] > buttonorig[1] - BUTTON_DISTANCE &&
				origin[2] > buttonorig[2] - BUTTON_DISTANCE &&
				origin[0] < buttonorig[0] + BUTTON_DISTANCE &&
				origin[1] < buttonorig[1] + BUTTON_DISTANCE &&
				origin[2] < buttonorig[2] + BUTTON_DISTANCE) {
					found = 1
					break
				}
			}

			if(found) {
				new temp[4]
				for(new i = 0; i < 5; i++) {
					climb_getbutton(i, temp)
					if(temp[0] == 0) {
						temp[0] = key+1
						temp[1] = buttonorig[0]
						temp[2] = buttonorig[1]
						temp[3] = buttonorig[2]
						climb_setbutton(i, temp[0], temp[1], temp[2], temp[3])
						break
					}
				}
			} else {
				alertmessage_v(id,3,"[DARKCLIMB SETUP] BUTTON NOT FOUND")
			}

			changed = 1

			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DARKCLIMB^n")
		format(menuBody,2047,"%s\dSet Button^n^n", menuBody)

		new flags = 0

		format(menuBody,2047,"%s\w1. Entrance^n", menuBody)
		flags |= (1<<0)
		format(menuBody,2047,"%s\w2. Exit^n", menuBody)
		flags |= (1<<1)
		format(menuBody,2047,"%s\w3. Finish^n", menuBody)
		flags |= (1<<2)
		format(menuBody,2047,"%s\w4. Shortcut^n^n", menuBody)
		flags |= (1<<3)

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Cancel", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	} else if(setup_mode[id] == 5) {
		new temp[128]
		read_args(temp, 127)
		remove_quotes(temp)
		climb_setfeature(4, str_to_num(temp))

		changed = 1

		setup_waitingfor[id] = 0
		setup_mode[id] = 6
		setup_menu(id, -1)
		return PLUGIN_HANDLED
	} else if(setup_mode[id] == 6) {
		if(key == 0) {
			if(climb_getfeature(0)) {
				climb_setfeature(0,0)
			} else {
				climb_setfeature(0,1)
				climb_setfeature(1,0)
			}
			changed = 1
		}
		if(key == 1) {
			if(climb_getfeature(1)) {
				climb_setfeature(1,0)
			} else {
				climb_setfeature(1,1)
				climb_setfeature(0,0)
			}
			changed = 1
		}
		if(key == 2) {
			climb_setfeature(2, !climb_getfeature(2))
			changed = 1
		}
		if(key == 3) {
			climb_setfeature(3, !climb_getfeature(3))
			changed = 1
		}
		if(key == 4) {
			client_cmd(id, "messagemode")
			setup_mode[id] = 5
			setup_waitingfor[id] = 1
		}
		if(key == 5) {
			climb_setfeature(5, !climb_getfeature(5))
			changed = 1
		}
		if(key == 6) {
			climb_setfeature(6, !climb_getfeature(6))
			changed = 1
			set_semiclip(climb_getfeature(6))
		}
		if(key == 9) {
			setup_mode[id] = 1
			setup_menu(id, -1)
			return PLUGIN_HANDLED
		}

		new menuBody[2048]
		format(menuBody,2047,"\yTeam9000 Setup - DARKCLIMB\w^n")

		new flags = 0

		format(menuBody,2047,"%s1. Autoheal (\y%s\w)^n", menuBody, climb_getfeature(0) ? "YES" : "NO")
		flags |= (1<<0)
		format(menuBody,2047,"%s2. Godmode (\y%s\w)^n", menuBody, climb_getfeature(1) ? "YES" : "NO")
		flags |= (1<<1)
		format(menuBody,2047,"%s3. Scout (\y%s\w)^n", menuBody, climb_getfeature(2) ? "YES" : "NO")
		flags |= (1<<2)
		format(menuBody,2047,"%s4. Nightvision (\y%s\w)^n", menuBody, climb_getfeature(3) ? "YES" : "NO")
		flags |= (1<<3)
		new checklimit[16]
		if(climb_getfeature(4) == -1)
			format(checklimit,15,"OFF")
		else if(climb_getfeature(4) == 0)
			format(checklimit,15,"UNLIMITED")
		else
			format(checklimit,15,"%d",climb_getfeature(4))
		format(menuBody,2047,"%s5. Checkpoint Limit (\y%s\w)^n", menuBody, checklimit)
		flags |= (1<<4)

		format(menuBody,2047,"%s6. Auto-Bunnyhop (\y%s\w)^n", menuBody, climb_getfeature(5) ? "YES" : "NO")
		flags |= (1<<5)

		format(menuBody,2047,"%s7. Semiclip (\y%s\w)^n", menuBody, climb_getfeature(6) ? "YES" : "NO")
		flags |= (1<<6)

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}

	return PLUGIN_HANDLED
}

public drawboxes() {
	new params[10]
	for(new i = 0; i < 10; i++) {
		new temp[7]
		climb_getarea(i, temp)
		if(temp[0]) {
			params[0] = temp[1]
			params[1] = temp[2]
			params[2] = temp[3]
			params[3] = temp[4]
			params[4] = temp[5]
			params[5] = temp[6]
			params[9] = 20
			if(temp[0] == 1) {
				params[6] = 0
				params[7] = 0
				params[8] = 255
			}
			if(temp[0] == 2) {
				params[6] = 255
				params[7] = 0
				params[8] = 0
			}
			if(temp[0] == 3) {
				params[6] = 0
				params[7] = 255
				params[8] = 0
			}
			if(temp[0] == 4) {
				params[6] = 255
				params[7] = 128
				params[8] = 0
			}
			drawbox(params)
		}
	}
	for(new i = 0; i < 5; i++) {
		new temp[4]
		climb_getbutton(i, temp)
		if(temp[0]) {
			params[0] = temp[1] - ADMIN_SETUP_BUTTON_BOX
			params[1] = temp[2] - ADMIN_SETUP_BUTTON_BOX
			params[2] = temp[3] - ADMIN_SETUP_BUTTON_BOX
			params[3] = temp[1] + ADMIN_SETUP_BUTTON_BOX
			params[4] = temp[2] + ADMIN_SETUP_BUTTON_BOX
			params[5] = temp[3] + ADMIN_SETUP_BUTTON_BOX
			params[9] = 20
			if(temp[0] == 1) {
				params[6] = 0
				params[7] = 0
				params[8] = 255
			}
			if(temp[0] == 2) {
				params[6] = 255
				params[7] = 0
				params[8] = 0
			}
			if(temp[0] == 3) {
				params[6] = 0
				params[7] = 255
				params[8] = 0
			}
			if(temp[0] == 4) {
				params[6] = 255
				params[7] = 128
				params[8] = 0
			}
			drawbox(params)
		}
	}
}

public drawbox(params[]) {
//	drawline(params, 0, 1, 2,    3, 1, 2)
//	drawline(params, 0, 1, 2,    0, 4, 2)
//	drawline(params, 0, 1, 2,    0, 1, 5)
	drawline(params, 0, 1, 2,    3, 4, 5)
//	drawline(params, 3, 4, 2,    0, 4, 2)
//	drawline(params, 3, 4, 2,    3, 4, 5)
//	drawline(params, 3, 4, 2,    3, 1, 2)
	drawline(params, 3, 4, 2,    0, 1, 5)
//	drawline(params, 3, 1, 5,    0, 1, 5)
//	drawline(params, 3, 1, 5,    3, 1, 2)
//	drawline(params, 3, 1, 5,    3, 4, 5)
	drawline(params, 3, 1, 5,    0, 4, 2)
//	drawline(params, 0, 4, 5,    0, 1, 5)
//	drawline(params, 0, 4, 5,    3, 4, 5)
//	drawline(params, 0, 4, 5,    0, 4, 2)
	drawline(params, 0, 4, 5,    3, 1, 2)
}

public drawline(params[], x1, y1, z1, x2, y2, z2) {
	for(new i = 0; i < 33; i++) {
		if(setup_mode[i] && is_user_connected(i) && (get_user_team(i) == 1 || get_user_team(i) == 2)) {
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY,{0,0,0},i)
			write_byte(TE_BEAMPOINTS)

			write_coord(params[x1])
			write_coord(params[y1])
			write_coord(params[z1])
			write_coord(params[x2])
			write_coord(params[y2])
			write_coord(params[z2])

			write_short(beam)	// sprite index
			write_byte(0)		// start frame
			write_byte(0)		// framerate
			write_byte(params[9]*100)	// life
			write_byte(10)		// width
			write_byte(0)		// noise

			write_byte(params[6])	// r, g, b
			write_byte(params[7])	// r, g, b
			write_byte(params[8])	// r, g, b

			write_byte(255)		// brightness
			write_byte(0)		// speed
			message_end()
		}
	}
}
