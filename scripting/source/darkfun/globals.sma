#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <dfx>
#include <settings>
#include <sub_auth>
#include <sub_setup>
#include <sub_frozen>

new crazymode = 0

new playerXP[33]
new playerLevel[33]
new playerTokens[33]

#define MAX_SKILLS 50
new NUM_SKILLS = 0
new skillsName[MAX_SKILLS][32]
new skillsShort[MAX_SKILLS][32]
new skillsActive[MAX_SKILLS]
new playerSkills[33][MAX_SKILLS]
new playerSkillOn[33][MAX_SKILLS]

public plugin_init() {
	register_plugin("DFX-MOD - GLOBALS","MM","doubleM")

	crazymode = 0
	NUM_SKILLS = 0
}

public plugin_natives() {
	register_library("dfx-mod-globals")

	register_native("dfx_getcrazymode","dfx_getcrazymode_impl")
	register_native("dfx_setcrazymode","dfx_setcrazymode_impl")

	register_native("dfx_getxp","dfx_getxp_impl")
	register_native("dfx_setxp","dfx_setxp_impl")
	register_native("dfx_getlevel","dfx_getlevel_impl")
	register_native("dfx_setlevel","dfx_setlevel_impl")
	register_native("dfx_gettokens","dfx_gettokens_impl")
	register_native("dfx_settokens","dfx_settokens_impl")

	register_native("dfx_getskill","dfx_getskill_impl")
	register_native("dfx_setskill","dfx_setskill_impl")
	register_native("dfx_getskillon","dfx_getskillon_impl")
	register_native("dfx_setskillon","dfx_setskillon_impl")

	register_native("dfx_registerskill","dfx_registerskill_impl")
	register_native("dfx_get_numskills","dfx_get_numskills_impl")
	register_native("dfx_get_skillname","dfx_get_skillname_impl")
	register_native("dfx_get_skillshort","dfx_get_skillshort_impl")
	register_native("dfx_get_skillactive","dfx_get_skillactive_impl")
	register_native("dfx_set_skillactive","dfx_set_skillactive_impl")
}

public client_connect(id) {
	for(new i = 0; i < MAX_SKILLS; i++) {
		playerSkillOn[id][i] = 1
	}
}

public storage_register_fw() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("darkfx_register_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}

	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("darkfx_register_post_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}
}

public dfx_registerskill_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(NUM_SKILLS >= MAX_SKILLS) {
		log_message("Over max skills!")
		return 0
	}

	get_string(1, skillsName[NUM_SKILLS], 31)
	get_string(2, skillsShort[NUM_SKILLS], 31)
	skillsActive[NUM_SKILLS] = -1
	NUM_SKILLS++

	return 1
}

public dfx_registerskill2_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(NUM_SKILLS2 >= MAX_SKILLS2) {
		log_message("Over max skills2!")
		return 0
	}

	get_string(1, skillsName2[NUM_SKILLS2], 31)
	get_string(2, skillsShort2[NUM_SKILLS2], 31)
	skillsActive2[NUM_SKILLS2] = -1
	NUM_SKILLS2++

	return 1
}

public dfx_get_numskills_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return NUM_SKILLS
}

public dfx_get_skillname_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	set_string(2, skillsName[get_param(1)], get_param(3))
	return 1
}

public dfx_get_skillshort_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	set_string(2, skillsShort[get_param(1)], get_param(3))
	return 1
}

public dfx_get_skillactive_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	return skillsActive[get_param(1)]
}

public dfx_set_skillactive_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	skillsActive[get_param(1)] = get_param(2)
	return 1
}


public dfx_get_numskills2_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return NUM_SKILLS2
}

public dfx_get_skillname2_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS2) {
		return 0
	}

	set_string(2, skillsName2[get_param(1)], get_param(3))
	return 1
}

public dfx_get_skillshort2_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS2) {
		return 0
	}

	set_string(2, skillsShort2[get_param(1)], get_param(3))
	return 1
}

public dfx_get_skillactive2_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS2) {
		return 0
	}

	return skillsActive2[get_param(1)]
}

public dfx_set_skillactive2_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS2) {
		return 0
	}

	skillsActive2[get_param(1)] = get_param(2)
	return 1
}

public dfx_getcrazymode_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return crazymode
}

public dfx_setcrazymode_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	crazymode = get_param(1)
	return get_param(1)
}

public dfx_getxp_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerXP[get_param(1)]
	}

	return 0
}

public dfx_setxp_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	playerXP[get_param(1)] = get_param(2)
	return get_param(2)
}

public dfx_getlevel_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerLevel[get_param(1)]
	}

	return 1
}

public dfx_setlevel_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(get_param(2) > 0)
		playerLevel[get_param(1)] = get_param(2)
	return get_param(2)
}

public dfx_gettokens_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerTokens[get_param(1)]
	}

	return 0

}

public dfx_settokens_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	playerTokens[get_param(1)] = get_param(2)
	return get_param(2)
}

public dfx_gettokens2_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerTokens2[get_param(1)]
	}

	return 0

}

public dfx_settokens2_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	playerTokens2[get_param(1)] = get_param(2)
	return get_param(2)
}

public dfx_getskill_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS; i++) {
		if(equal(skillsShort[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return 0
	}

	if(get_frozen(get_param(1))) {
		return 0
	}
	if(skillsActive[skillid] == 0) {
		if(equal(skillname, "hook")) {
			return -1
		}
		return 0
	}
	if(cs_get_user_vip(get_param(1))) {
		return 0
	}
	if(crazymode) {
		return 4
	}

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerSkills[get_param(1)][skillid]-1
	}

	return 0
}

public dfx_getactualskill_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS; i++) {
		if(equal(skillsShort2[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return 1
	}

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerSkills[get_param(1)][skillid]
	}

	return 1
}

public dfx_setskill_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS; i++) {
		if(equal(skillsShort[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return get_param(3)
	}

	if(get_param(3) > 0)
		playerSkills[get_param(1)][skillid] = get_param(3)
	return get_param(3)
}

public dfx_getskill2_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS2; i++) {
		if(equal(skillsShort2[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return get_param(3)
	}

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerSkills2[get_param(1)][skillid]
	}

	return 0
}

public dfx_getactualskill2_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS; i++) {
		if(equal(skillsShort2[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return 1
	}

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerSkills2[get_param(1)][skillid]
	}

	return 1
}

public dfx_setskill2_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	new skillname[32]
	get_string(2, skillname, 31)

	new skillid = -1
	for(new i = 0; i < NUM_SKILLS; i++) {
		if(equal(skillsShort2[i], skillname)) {
			skillid = i
			break
		}
	}
	if(skillid == -1) {
		return get_param(3)
	}

	playerSkills2[get_param(1)][skillid] = get_param(3)
	return get_param(3)
}

public dfx_getreloads_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(dfx_playerloaded(get_param(1)) && get_authed(get_param(1))) {
		return playerReloads[get_param(1)]
	}

	return 0

}

public dfx_setreloads_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	playerReloads[get_param(1)] = get_param(2)
	return get_param(2)
}
