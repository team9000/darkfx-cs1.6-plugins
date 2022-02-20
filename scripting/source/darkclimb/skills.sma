#include <amxmodx>
#include <sub_stocks>
#include <darkclimb.inc>
#include <settings>
#include <sub_storage>
#include <sub_hud>
#include <sub_disqualify>

new player_page[33]

public plugin_init() {
	register_plugin("DARKCLIMB - SKILLS","T9k","Team9000")

	register_concmd("skills","Skills")
	register_concmd("say /skills","Skills")

	register_menucmd(register_menuid("DARKCLIMB Skills"),1023,"SkillsMenu")
}

public plugin_natives() {
	register_library("darkclimb_skills")
}

public Skills(id) {
	if(!climb_playerloaded(id)) {
		alertmessage(id,3,"Your skills are not yet loaded!")
		return PLUGIN_CONTINUE
	}

	player_page[id] = 1
	SkillsMenu(id, -1)

	return PLUGIN_CONTINUE
}

public SkillsMenu(id, key) {
	set_menuopen(id, 0)

	new max_page = floatround(float(climb_get_numskills()) / SKILLO_PER_PAGE, floatround_ceil)

	new item=-1
	if(key >= 0 && key < SKILLO_PER_PAGE) {
		item = ((player_page[id]-1)*SKILLO_PER_PAGE)+key
	}
	if(key == 6) {
		for(new i = 0; i < climb_get_numskills(); i++) {
			new shortname[32]
			climb_get_skillshort(i, shortname, 31)
			if(climb_getskill(id,shortname) >= 1) {
				climb_setskillon(id, shortname, 0)
			}
		}

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("climb_change_skill", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(id)
					callfunc_end()
				}
			}
		}

		disqualify_stop(id, 1)

		for(new i = 0; i < climb_get_numskills(); i++) {
			if(!climb_get_skilldisq(i)) {
				continue
			}
			new shortname[32]
			climb_get_skillshort(i, shortname, 31)
			if(climb_getskillon(id,shortname)) {
				disqualify_start(id, 1)
			}
		}
	}
	if(key == 7 && player_page[id] > 1) {
		player_page[id] -= 1
	}
	if(key == 8 && player_page[id] < max_page) {
		player_page[id] += 1
	}
	if(key == 9) {
		return PLUGIN_HANDLED
	}

	if(item != -1 && item < climb_get_numskills()) {
		new shortname[32]
		climb_get_skillshort(item, shortname, 31)
		if(climb_getskill(id,shortname) >= 1) {
			climb_setskillon(id, shortname, !climb_getskillon(id, shortname))

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("climb_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(id)
						callfunc_end()
					}
				}
			}

			disqualify_stop(id, 1)

			for(new i = 0; i < climb_get_numskills(); i++) {
				if(!climb_get_skilldisq(i)) {
					continue
				}
				new shortname[32]
				climb_get_skillshort(i, shortname, 31)
				if(climb_getskillon(id,shortname)) {
					disqualify_start(id, 1)
				}
			}
		}
	}

	new flags = (1<<9)

	new menuBody[512]
	format(menuBody,511,"\yDARKCLIMB Skills^n")
	for(new i = (player_page[id]-1)*SKILLO_PER_PAGE; i < climb_get_numskills() && i < (player_page[id]-1)*SKILLO_PER_PAGE+SKILLO_PER_PAGE; i++) {
		new shortname[32]
		climb_get_skillshort(i, shortname, 31)
		new longname[32]
		climb_get_skillname(i, longname, 31)

		if(climb_get_skilldisq(i)) {
			format(menuBody,511,"%s\r%d. ", menuBody, i-(player_page[id]-1)*SKILLO_PER_PAGE+1)
		} else {
			format(menuBody,511,"%s\w%d. ", menuBody, i-(player_page[id]-1)*SKILLO_PER_PAGE+1)
		}

		if(climb_getskill(id,shortname)) {
			if(climb_getskillon(id, shortname)) {
				format(menuBody,511,"%s%s \w(\yON\w)^n", menuBody, longname)
			} else {
				format(menuBody,511,"%s%s \w(\dOFF\w)^n", menuBody, longname)
			}
			flags |= (1<<((i-(player_page[id]-1)*SKILLO_PER_PAGE+1)-1))
		} else {
			format(menuBody,511,"%s\d%s (\dNOT OWNED)\w^n", menuBody, longname)
		}
	}

	format(menuBody,511,"%s^n", menuBody)

	format(menuBody,511,"%s\y7. All Skills Off^n^n", menuBody)
	flags |= (1<<6)

	if(player_page[id] > 1) {
		format(menuBody,511,"%s\y8. Back^n", menuBody)
		flags |= (1<<7)
	}

	if(player_page[id] < max_page) {
		format(menuBody,511,"%s\y9. More^n", menuBody)
		flags |= (1<<8)
	}

	format(menuBody,511,"%s\r0. Exit^n^n", menuBody)

	format(menuBody,511,"%s\yALERT: \rRED \ySKILLS DISQUALIFY YOU FROM^nCOMPETING FOR RECORDS WHEN ENABLED!^n^n", menuBody)
	format(menuBody,511,"%s\yTYPE \r/shop \yTO PURCHASE NEW SKILLS", menuBody)

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}
