#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <darkclimb.inc>
#include <settings>
#include <sub_frozen>

new playerPoints[33]

#define MAX_SKILLS 50
new NUM_SKILLS = 0
new skillsName[MAX_SKILLS][32]
new skillsShort[MAX_SKILLS][32]
new skillsCost[MAX_SKILLS]
new skillsDisq[MAX_SKILLS]
new skillsActive[MAX_SKILLS]
new playerSkills[33][MAX_SKILLS]
new playerSkillOn[33][MAX_SKILLS]

public plugin_init() {
	register_plugin("DARKCLIMB - GLOBALS","T9k","Team9000")

	NUM_SKILLS = 0
}

public plugin_natives() {
	register_library("darkclimb_globals")

	register_native("climb_getpoints","climb_getpoints_impl")
	register_native("climb_setpoints","climb_setpoints_impl")

	register_native("climb_getskill","climb_getskill_impl")
	register_native("climb_setskill","climb_setskill_impl")
	register_native("climb_getskillon","climb_getskillon_impl")
	register_native("climb_setskillon","climb_setskillon_impl")

	register_native("climb_registerskill","climb_registerskill_impl")
	register_native("climb_get_numskills","climb_get_numskills_impl")
	register_native("climb_get_skillname","climb_get_skillname_impl")
	register_native("climb_get_skillshort","climb_get_skillshort_impl")
	register_native("climb_get_skillcost","climb_get_skillcost_impl")
	register_native("climb_get_skilldisq","climb_get_skilldisq_impl")
	register_native("climb_get_skillactive","climb_get_skillactive_impl")
	register_native("climb_set_skillactive","climb_set_skillactive_impl")
}

public client_connect(id) {
	for(new i = 0; i < MAX_SKILLS; i++) {
		playerSkillOn[id][i] = 0
	}
}

public storage_register_fw() {
	new funcid = 0
	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("climb_register_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}

	for(new i = 0; i < get_pluginsnum(); i++) {
		if((funcid = get_func_id("climb_register_post_fw", i)) != -1) {
			if(callfunc_begin_i(funcid, i) == 1) {
				callfunc_end()
			}
		}
	}

	sort_skills()
}

public sort_skills() {
	new skillsName2[MAX_SKILLS][32]
	new skillsShort2[MAX_SKILLS][32]
	new skillsCost2[MAX_SKILLS]
	new skillsDisq2[MAX_SKILLS]
	new skillsActive2[MAX_SKILLS]

	for(new i = 0; i < NUM_SKILLS; i++) {
		copy(skillsName2[i], 31, skillsName[i])
		copy(skillsShort2[i], 31, skillsShort[i])
		skillsCost2[i] = skillsCost[i]
		skillsDisq2[i] = skillsDisq[i]
		skillsActive2[i] = skillsActive[i]
	}

	new min
	for(new i = 0; i < NUM_SKILLS; i++) {
		min = -1
		for(new j = 0; j < NUM_SKILLS; j++) {
			if(equal(skillsName2[j], "")) {
				continue
			}
			if(min == -1 || skillsCost2[j] < skillsCost2[min]) {
				min = j
			}
		}

		copy(skillsName[i], 31, skillsName2[min])
		copy(skillsShort[i], 31, skillsShort2[min])
		skillsCost[i] = skillsCost2[min]
		skillsDisq[i] = skillsDisq2[min]
		skillsActive[i] = skillsActive2[min]
		copy(skillsName2[min], 31, "")
	}
}

public climb_registerskill_impl(id, numparams) {
	if(numparams < 3 || numparams > 4)
		return log_error(10, "Bad native parameters")

	if(NUM_SKILLS >= MAX_SKILLS) {
		log_message("Over max skills!")
		return 0
	}

	get_string(1, skillsName[NUM_SKILLS], 31)
	get_string(2, skillsShort[NUM_SKILLS], 31)
	skillsCost[NUM_SKILLS] = get_param(3)

	skillsDisq[NUM_SKILLS] = 0
	if(numparams >= 4) {
		skillsDisq[NUM_SKILLS] = get_param(4)
	}

	NUM_SKILLS++

	return 1
}

public climb_get_numskills_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	return NUM_SKILLS
}

public climb_get_skillname_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	set_string(2, skillsName[get_param(1)], get_param(3))
	return 1
}

public climb_get_skillshort_impl(id, numparams) {
	if(numparams != 3)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	set_string(2, skillsShort[get_param(1)], get_param(3))
	return 1
}

public climb_get_skillcost_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	return skillsCost[get_param(1)]
}

public climb_get_skilldisq_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	return skillsDisq[get_param(1)]
}

public climb_get_skillactive_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	return skillsActive[get_param(1)]
}

public climb_set_skillactive_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	if(get_param(1) < 0 || get_param(1) >= NUM_SKILLS) {
		return 0
	}

	skillsActive[get_param(1)] = get_param(2)
	return 1
}

public climb_getpoints_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	if(climb_playerloaded(get_param(1))) {
		return playerPoints[get_param(1)]
	}

	return 0
}

public climb_setpoints_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	playerPoints[get_param(1)] = get_param(2)
	return get_param(2)
}

public climb_getskillon_impl(id, numparams) {
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

	if(climb_playerloaded(get_param(1))) {
		return playerSkills[get_param(1)][skillid] &
			playerSkillOn[get_param(1)][skillid] &
			climb_get_skillactive(skillid)
	}

	return 0
}

public climb_setskillon_impl(id, numparams) {
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

	playerSkillOn[get_param(1)][skillid] = get_param(3)
	return get_param(3)
}

public climb_getskill_impl(id, numparams) {
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

	if(climb_playerloaded(get_param(1))) {
		return playerSkills[get_param(1)][skillid]
	}

	return 0
}

public climb_setskill_impl(id, numparams) {
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

	if(climb_get_skillcost(skillid) == 0) {
		playerSkills[get_param(1)][skillid] = 1
	} else {
		playerSkills[get_param(1)][skillid] = get_param(3)
	}
	return get_param(3)
}
