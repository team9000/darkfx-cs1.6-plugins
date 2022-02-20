#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>
#include <sub_options>
#include <sub_hud>

new loaded[33]

new setup_page[33] = 0

#define OPTIONS_PER_PAGE 7

#define MAX_OPTIONS 50
new NUM_OPTIONS
new options[MAX_OPTIONS][64]
new optionplugin[MAX_OPTIONS]

public plugin_init() {
	register_plugin("Subsys - Options","T9k","Team9000")

	register_clcmd("say /options","options_cmd")
	register_menucmd(register_menuid("DarkMod Options - Main"),1023,"setup_menu")

	for(new i = 0; i < 33; i++) {
		loaded[i] = 0
	}
}

public plugin_natives() {
	register_library("sub_options")

	register_native("options_registeroption","options_registeroption_impl")
	register_native("options_registerfield","options_registerfield_impl")
	register_native("options_showmain","options_showmain_impl")
}

public options_registeroption_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(NUM_OPTIONS >= MAX_OPTIONS) {
		log_message("Over max player options!")
		return 0
	}

	get_string(1, options[NUM_OPTIONS], 63)
	optionplugin[NUM_OPTIONS] = id
	NUM_OPTIONS++

	return 1
}

public options_registerfield_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new temp[64], key[64]
	get_string(1, temp, 63)
	format(key, 63, "option_%s", temp)
	storage_reg_playerfield(key)

	return 1
}

public options_showmain_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	setup_page[get_param(1)] = 1
	setup_menu(get_param(1), -1)

	return 1
}

public client_connect(id) {
	loaded[id] = 0
}

public client_disconnect(id) {
	loaded[id] = 0
}

public storage_register_fw() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("options_register_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}
}

public storage_loadplayer_fw(id, status) {
	if(id > 0) {
		loaded[id] = status
	}
}

public options_cmd(id,level,cid) { 
	if(!loaded[id]) {
		alertmessage(id,3,"Your account is not yet loaded!")
		return PLUGIN_HANDLED
	}

	setup_page[id] = 1
	setup_menu(id, -1)

	return PLUGIN_CONTINUE
}

public setup_menu(id, key) {
	set_menuopen(id, 0)

	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("options_clear_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}

	new max_page = floatround(float(NUM_OPTIONS) / OPTIONS_PER_PAGE, floatround_ceil)

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

	if(item != -1 && item < NUM_OPTIONS) {
		new funcid = 0
		if((funcid = get_func_id("options_menu_fw", optionplugin[item])) != -1) {
			if(callfunc_begin_i(funcid, optionplugin[item]) == 1) {
				callfunc_push_int(id)
				callfunc_end()
			}
		}
		return PLUGIN_HANDLED
	}

	new menuBody[512]
	format(menuBody,511,"\yDarkMod Options - Main^n")

	new flags = 0

	for(new i = (setup_page[id]-1)*OPTIONS_PER_PAGE; i < NUM_OPTIONS && i < (setup_page[id]-1)*OPTIONS_PER_PAGE+OPTIONS_PER_PAGE; i++) {
		format(menuBody,511,"%s\w%d. %s^n", menuBody, i-(setup_page[id]-1)*OPTIONS_PER_PAGE+1, options[i])
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

	return PLUGIN_HANDLED
}
