#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <settings>
#include <sub_storage>
#include <sub_auth>

new loaded[33]

public plugin_init() {
	register_plugin("DFX-MOD - STORAGE","MM","doubleM")
}

public darkfx_register_post_fw() {
	for(new i = 0; i < dfx_get_numskills(); i++) {
		new shortname[32]
		dfx_get_skillshort(i, shortname, 31)
		new key[32]
		format(key, 31, "skill_%s", shortname)
		storage_reg_playerfield(key)
	}
	for(new i = 0; i < dfx_get_numskills2(); i++) {
		new shortname[32]
		dfx_get_skillshort2(i, shortname, 31)
		new key[32]
		format(key, 31, "skill2_%s", shortname)
		storage_reg_playerfield(key)
	}

	storage_reg_playerfield("dfx_xp")
	storage_reg_playerfield("dfx_level")
	storage_reg_playerfield("dfx_tokens")
	storage_reg_playerfield("dfx_tokens2")
	storage_reg_playerfield("dfx_reloads")
}

public plugin_natives() {
	register_library("dfx-mod-storage")
	register_native("dfx_playerloaded","dfx_playerloaded_impl")
}

public dfx_playerloaded_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return loaded[get_param(1)]
}

public storage_presaveplayer_fw(id) {
	if(!get_authed(id) || !dfx_getlevel(id) || (!dfx_getxp(id) && dfx_getlevel(id) > 10) || !loaded[id]) {
		return
	}

	new textline[128]
	format(textline, 127, "%d", dfx_getxp(id))
	set_playervalue(id, "dfx_xp", textline)

	format(textline, 127, "%d", dfx_getlevel(id))
	set_playervalue(id, "dfx_level", textline)

	format(textline, 127, "%d", dfx_gettokens(id))
	set_playervalue(id, "dfx_tokens", textline)

	format(textline, 127, "%d", dfx_gettokens2(id))
	set_playervalue(id, "dfx_tokens2", textline)

	for(new i = 0; i < dfx_get_numskills(); i++) {
		new shortname[32], key[32]
		dfx_get_skillshort(i, shortname, 31)
		format(key, 31, "skill_%s", shortname)

		format(textline, 127, "%d", dfx_getactualskill(id, shortname))
		set_playervalue(id, key, textline)
	}

	for(new i = 0; i < dfx_get_numskills2(); i++) {
		new shortname[32], key[32]
		dfx_get_skillshort2(i, shortname, 31)
		format(key, 31, "skill2_%s", shortname)

		format(textline, 127, "%d", dfx_getactualskill2(id, shortname))
		set_playervalue(id, key, textline)
	}

	format(textline, 127, "%d", dfx_getreloads(id))
	set_playervalue(id, "dfx_reloads", textline)
}

public dfx_getfield(id, key[], value[], len, defaultval[]) {
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

		loaded[id] &= dfx_getfield(id, "dfx_xp", value, 127, "0")
		dfx_setxp(id, str_to_num(value))

		loaded[id] &= dfx_getfield(id, "dfx_level", value, 127, "1")
		dfx_setlevel(id, str_to_num(value))

		loaded[id] &= dfx_getfield(id, "dfx_tokens", value, 127, "0")
		dfx_settokens(id, str_to_num(value))

		loaded[id] &= dfx_getfield(id, "dfx_tokens2", value, 127, "0")
		dfx_settokens2(id, str_to_num(value))

		for(new i = 0; i < dfx_get_numskills(); i++) {
			new shortname[32], key[32]
			dfx_get_skillshort(i, shortname, 31)
			format(key, 31, "skill_%s", shortname)

			loaded[id] &= dfx_getfield(id, key, value, 127, "1")
			dfx_setskill(id, shortname, str_to_num(value))
		}

		for(new i = 0; i < dfx_get_numskills2(); i++) {
			new shortname[32], key[32]
			dfx_get_skillshort2(i, shortname, 31)
			format(key, 31, "skill2_%s", shortname)

			loaded[id] &= dfx_getfield(id, key, value, 127, "0")
			dfx_setskill2(id, shortname, str_to_num(value))
		}

		loaded[id] &= dfx_getfield(id, "dfx_reloads", value, 127, "0")
		dfx_setreloads(id, str_to_num(value))

		dfx_updatexphud(id)
	}

	return
}
