#include <amxmodx>
#include <sub_stocks>
#include <fun>
#include <dfx>
#include <sub_damage>
#include <sub_respawn>

public plugin_init() {
	register_plugin("DFX-MOD - HP Regenerate","MM","doubleM")
	set_task(2.5, "hpregen_heal", 0, "", 0, "b")
}

public darkfx_register_fw() {
	dfx_registerskill("HP Regeneration", "hpregen")
}

public hpregen_heal() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			new skill = dfx_getskill(targetindex, "hpregen")
			new skill2 = dfx_getskill(targetindex, "maxhp")

			new addhp
			if(dfx_getmutantmode() && dfx_getmutant(targetindex)) {
				addhp = -2
			} else {
				addhp = 2*(skill)
			}
			new maxhp = 100+35*(skill2)

			if(get_upperhealth()) {
				if(get_user_health(targetindex) < maxhp+256000 || addhp < 0) {
					if(get_user_health(targetindex) + addhp < maxhp+256000) {
						set_user_health(targetindex, get_user_health(targetindex)+addhp)
					} else {
						set_user_health(targetindex, maxhp+256000)
					}
				}
			} else {
				if(get_user_health(targetindex) < maxhp || addhp < 0) {
					if(get_user_health(targetindex) + addhp < maxhp) {
						set_user_health(targetindex, get_user_health(targetindex)+addhp)
					} else {
						set_user_health(targetindex, maxhp)
					}
				}
			}
		}
	}
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(dfx_getmutantmode()) {
		if(attacker && dfx_getmutant(attacker) && victim != attacker) {
			new addhp
			addhp = 10
			new skill2 = dfx_getskill(attacker, "maxhp")
			new maxhp = 100+35*(skill2)
			if(get_upperhealth()) {
				if(get_user_health(attacker) + addhp < maxhp+256000) {
					set_user_health(attacker, get_user_health(attacker)+addhp)
				} else {
					set_user_health(attacker, maxhp+256000)
				}
			} else {
				if(get_user_health(attacker) + addhp < maxhp) {
					set_user_health(attacker, get_user_health(attacker)+addhp)
				} else {
					set_user_health(attacker, maxhp)
				}
			}
		}
	}
}
