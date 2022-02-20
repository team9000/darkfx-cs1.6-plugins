#define DFX_NEEDSKILLMINLEVEL

#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <settings>
#include <sub_auth>
#include <sub_storage>
#include <sub_hud>

new player_page[33]

public plugin_init() {
	register_plugin("DFX-MOD - SHOP","MM","doubleM")

	register_concmd("shop","Shop")
	register_concmd("shopmenu","Shop")
	register_concmd("store","Shop")
	register_concmd("buymenu","Shop")
	register_concmd("buyskill","Shop")
	register_concmd("buyskills","Shop")
	register_concmd("say /buy","Shop")
	register_concmd("say /shop","Shop")
	register_concmd("say /shopmenu","Shop")
	register_concmd("say /store","Shop")
	register_concmd("say /buymenu","Shop")
	register_concmd("say /buyskill","Shop")
	register_concmd("say /buyskills","Shop")

	register_concmd("shop2","Shop2")
	register_concmd("say /shop2","Shop2")

	register_concmd("reset","Reset")
	register_concmd("resetskills","Reset")
	register_concmd("resetxp","Reset")
	register_concmd("skillreset","Reset")
	register_concmd("clearskills","Reset")
	register_concmd("clearxp","Reset")
	register_concmd("say /reset","Reset")
	register_concmd("say /resetskills","Reset")
	register_concmd("say /resetxp","Reset")
	register_concmd("say /skillreset","Reset")
	register_concmd("say /clearskills","Reset")
	register_concmd("say /clearxp","Reset")

	register_menucmd(register_menuid("DFX-MOD Shop"),1023,"ShopMenu")
	register_menucmd(register_menuid("DFX-MOD Deluxe Shop"),1023,"ShopMenu2")
	register_menucmd(register_menuid("DFX-MOD Skills Reload"),1023,"ResetMenu")
}

public plugin_natives() {
	register_library("dfx-mod-shop")
}

public Shop(id) {
	if(!get_authed(id)) {
		alertmessage(id,3,"You are not authed!")
		return PLUGIN_CONTINUE
	}
	if(!dfx_playerloaded(id)) {
		alertmessage(id,3,"Your XP is not yet loaded!")
		return PLUGIN_CONTINUE
	}

	player_page[id] = 1
	ShopMenu(id, -1)

	return PLUGIN_CONTINUE
}

public ShopMenu(id, key) {
	set_menuopen(id, 0)

	new max_page = floatround(float(dfx_get_numskills()) / SKILLS_PER_PAGE, floatround_ceil)

	new item=-1
	if(key >= 0 && key < SKILLS_PER_PAGE) {
		item = ((player_page[id]-1)*SKILLS_PER_PAGE)+key
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

	if(item != -1 && item < dfx_get_numskills() && dfx_gettokens(id) >= 1) {
		new shortname[32]
		dfx_get_skillshort(item, shortname, 31)
		if(dfx_getactualskill(id,shortname) < MAX_SKILL_LEVEL && dfx_getlevel(id) >= skillsMinLevel[dfx_getactualskill(id,shortname)]) {
			dfx_setskill(id, shortname, dfx_getactualskill(id, shortname)+1)
			dfx_settokens(id, dfx_gettokens(id)-1)
			storage_saveplayer(id)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("darkfx_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(id)
						callfunc_end()
					}
				}
			}
		}
	}

	new flags = (1<<9)

	new menuBody[512], curlvlstr[6]
	format(menuBody,511,"\yDFX-MOD Shop^n")
	for(new i = (player_page[id]-1)*SKILLS_PER_PAGE; i < dfx_get_numskills() && i < (player_page[id]-1)*SKILLS_PER_PAGE+SKILLS_PER_PAGE; i++) {
		new shortname[32]
		dfx_get_skillshort(i, shortname, 31)
		new longname[32]
		dfx_get_skillname(i, longname, 31)

		format(curlvlstr,5,"%d", dfx_getactualskill(id, shortname))
		format(menuBody,511,"%s\w%d. %s^t(Currently: %s", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname, dfx_getactualskill(id, shortname) < MAX_SKILL_LEVEL ? curlvlstr : "MAX")
		if(dfx_getactualskill(id, shortname) < MAX_SKILL_LEVEL)
			 format(menuBody,511,"%s | Min Lvl: %s%d", menuBody, dfx_getlevel(id) >= skillsMinLevel[dfx_getactualskill(id, shortname)] ? "\g" : "\r", skillsMinLevel[dfx_getactualskill(id, shortname)])
		format(menuBody,511,"%s\w)^n", menuBody)
		flags |= (1<<((i-(player_page[id]-1)*SKILLS_PER_PAGE+1)-1))
	}

	format(menuBody,511,"%s^n", menuBody)

	if(player_page[id] > 1) {
		format(menuBody,511,"%s\y8. Back^n", menuBody)
		flags |= (1<<7)
	}

	format(menuBody,511,"%s^n", menuBody)

	if(player_page[id] < max_page) {
		format(menuBody,511,"%s\y9. More^n", menuBody)
		flags |= (1<<8)
	}

	format(menuBody,511,"%s^n", menuBody)

	format(menuBody,511,"%s\r0. Exit^n^n", menuBody)
	format(menuBody,511,"%s\yTokens: %d^n", menuBody, dfx_gettokens(id))

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}

public Shop2(id) {
	if(!get_authed(id)) {
		alertmessage(id,3,"You are not authed!")
		return PLUGIN_CONTINUE
	}
	if(!dfx_playerloaded(id)) {
		alertmessage(id,3,"Your XP is not yet loaded!")
		return PLUGIN_CONTINUE
	}

	player_page[id] = 1
	ShopMenu2(id, -1)

	return PLUGIN_CONTINUE
}

public ShopMenu2(id, key) {
	set_menuopen(id, 0)

	new max_page = floatround(float(dfx_get_numskills2()) / SKILLS_PER_PAGE, floatround_ceil)

	new item=-1
	if(key >= 0 && key < SKILLS_PER_PAGE) {
		item = ((player_page[id]-1)*SKILLS_PER_PAGE)+key
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

	if(item != -1 && item < dfx_get_numskills2() && dfx_gettokens2(id) >= 1) {
		new shortname[32]
		dfx_get_skillshort2(item, shortname, 31)
		if(dfx_getactualskill2(id,shortname) < MAX_SKILL2_LEVEL) {
			dfx_setskill2(id, shortname, dfx_getskill2(id, shortname)+1)
			dfx_settokens2(id, dfx_gettokens2(id)-1)
			storage_saveplayer(id)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("darkfx_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(id)
						callfunc_end()
					}
				}
			}
		}
	}

	new flags = (1<<9)

	new menuBody[512], curlvlstr[6]
	format(menuBody,511,"\yDFX-MOD Deluxe Shop^n")
	for(new i = (player_page[id]-1)*SKILLS_PER_PAGE; i < dfx_get_numskills2() && i < (player_page[id]-1)*SKILLS_PER_PAGE+SKILLS_PER_PAGE; i++) {
		new shortname[32]
		dfx_get_skillshort2(i, shortname, 31)
		new longname[32]
		dfx_get_skillname2(i, longname, 31)

		format(curlvlstr,5,"%d", dfx_getskill2(id, shortname))
		format(menuBody,511,"%s\w%d. %s^t(Currently: %s", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname, dfx_getskill2(id, shortname) < MAX_SKILL2_LEVEL ? curlvlstr : "MAX")
		format(menuBody,511,"%s\w)^n", menuBody)
		flags |= (1<<((i-(player_page[id]-1)*SKILLS_PER_PAGE+1)-1))
	}

	format(menuBody,511,"%s^n", menuBody)

	if(player_page[id] > 1) {
		format(menuBody,511,"%s\y8. Back^n", menuBody)
		flags |= (1<<7)
	}

	format(menuBody,511,"%s^n", menuBody)

	if(player_page[id] < max_page) {
		format(menuBody,511,"%s\y9. More^n", menuBody)
		flags |= (1<<8)
	}

	format(menuBody,511,"%s^n", menuBody)

	format(menuBody,511,"%s\r0. Exit^n^n", menuBody)
	format(menuBody,511,"%s\yDeluxe Tokens: %d^n", menuBody, dfx_gettokens2(id))

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}

public Reset(id) {
	if(!get_authed(id)) {
		alertmessage(id,3,"You are not authed!")
		return PLUGIN_CONTINUE
	}
	if(!dfx_playerloaded(id)) {
		alertmessage(id,3,"Your XP is not yet loaded!")
		return PLUGIN_CONTINUE
	}

	new menuBody[512]
	format(menuBody,511,"\rDFX-MOD Skills Reload^n", menuBody)

	new flags = ((1<<1))
	format(menuBody,511,"%s\yReload Skills?^n", menuBody)
	if(dfx_getlevel(id) < 20 || dfx_getreloads(id) > 0) {
		format(menuBody,511,"%s\w1. Yes^n", menuBody)
		flags |= (1<<0)
	} else {
		format(menuBody,511,"%s\d1. Yes^n", menuBody)
	}
	format(menuBody,511,"%s\w2. No^n", menuBody)

	if(dfx_getlevel(id) >= 20) {
		if(dfx_getreloads(id) > 0) {
			format(menuBody,511,"%s^n\rALERT: \yONLY \r%d\y FREE RELOAD%s REMAINING^n", menuBody, dfx_getreloads(id), dfx_getreloads(id) == 1 ? "" : "S")
			format(menuBody,511,"%s\yADDITIONAL RELOADS COST $4.99!^n", menuBody)
		} else {
			format(menuBody,511,"%s^n\rYOU ARE OUT OF FREE RELOADS!^n", menuBody)
			format(menuBody,511,"%s^nADDITIONAL RELOADS CAN BE PURCHASED FOR $4.99^nSEE DARKFX.NET FOR DETAILS^n", menuBody)
		}
	}

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_CONTINUE
}

public ResetMenu(id, key) {
	set_menuopen(id, 0)

	if(!get_authed(id)) {
		alertmessage(id,3,"You are not authed!")
		return PLUGIN_HANDLED
	}
	if(!dfx_playerloaded(id)) {
		alertmessage(id,3,"Your XP is not yet loaded!")
		return PLUGIN_HANDLED
	}
	if(dfx_getlevel(id) >= 20 && dfx_getreloads(id) <= 0) {
		return PLUGIN_HANDLED
	}

	if(key == 0) {
		for(new i = 0; i < dfx_get_numskills(); i++) {
			new skillshort[32]
			dfx_get_skillshort(i, skillshort, 31)
			dfx_setskill(id, skillshort, 1)
		}
		for(new i = 0; i < dfx_get_numskills2(); i++) {
			new skillshort[32]
			dfx_get_skillshort2(i, skillshort, 31)
			dfx_setskill2(id, skillshort, 0)
		}
		dfx_settokens(id, dfx_getlevel(id)-1)
		if(dfx_getlevel(id) >= 20) {
			dfx_settokens2(id, dfx_getlevel(id)-19)
		} else {
			dfx_settokens2(id, 0)
		}

		if(dfx_getlevel(id) >= 20) {
			dfx_setreloads(id, dfx_getreloads(id)-1)
		}

		storage_saveplayer(id)

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("darkfx_change_skill", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(id)
					callfunc_end()
				}
			}
		}

		alertmessage(id,3,"Your skills have been reset!")
	}

	return PLUGIN_HANDLED
}
