#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <settings>
#include <sub_storage>

new loaded[33]

public plugin_init() {
	register_plugin("DARKSURF - STORAGE","T9k","Team9000")
}

public surf_register_post_fw() {
	for(new i = 0; i < surf_get_numskills(); i++) {
		new shortname[32]
		surf_get_skillshort(i, shortname, 31)
		new key[32]
		format(key, 31, "surf_skill_%s", shortname)
		storage_reg_playerfield(key)
	}

	storage_reg_playerfield("surf_points")
}

public plugin_natives() {
	register_library("darksurf_storage")
	register_native("surf_playerloaded","surf_playerloaded_impl")
}

public surf_playerloaded_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return loaded[get_param(1)]
}

public storage_presaveplayer_fw(id) {
	if(!loaded[id]) {
		return
	}

	new textline[128]
	format(textline, 127, "%d", surf_getpoints(id))
	set_playervalue(id, "surf_points", textline)

	for(new i = 0; i < surf_get_numskills(); i++) {
		new shortname[32], key[32]
		surf_get_skillshort(i, shortname, 31)
		format(key, 31, "surf_skill_%s", shortname)

		format(textline, 127, "%d", surf_getskill(id, shortname))
		set_playervalue(id, key, textline)
	}
}

public surf_getfield(id, key[], value[], len, defaultval[]) {
	new result = get_playervalue(id, key, value, len)
	if(result == 0) {
		format(value, len, "%s", defaultval)
		return 0
	} else {
		return 1
	}

	return 0
}

public client_connect(id) {
	loaded[id] = 0
}

public storage_loadplayer_fw(id, status) {
	new value[128]

	if(id > 0) {
		loaded[id] = 1

		loaded[id] &= surf_getfield(id, "surf_points", value, 127, "0")
		surf_setpoints(id, str_to_num(value))

		for(new i = 0; i < surf_get_numskills(); i++) {
			new shortname[32], key[32]
			surf_get_skillshort(i, shortname, 31)
			format(key, 31, "surf_skill_%s", shortname)

			loaded[id] &= surf_getfield(id, key, value, 127, "0")
			surf_setskill(id, shortname, str_to_num(value))
		}

		surf_updatepointshud(id)
	}

	return
}
