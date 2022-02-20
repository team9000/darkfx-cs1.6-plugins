#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <settings>
#include <sub_storage>
#include <sub_hud>

new player_page[33]

public plugin_init() {
	register_plugin("DARKSURF - SHOP","T9k","Team9000")

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

	register_menucmd(register_menuid("DARKSURF Shop"),1023,"ShopMenu")
}

public plugin_natives() {
	register_library("darksurf_shop")
}

public Shop(id) {
	if(!surf_playerloaded(id)) {
		alertmessage(id,3,"Your points are not yet loaded!")
		return PLUGIN_CONTINUE
	}

	player_page[id] = 1
	ShopMenu(id, -1)

	return PLUGIN_CONTINUE
}

public ShopMenu(id, key) {
	set_menuopen(id, 0)

	new max_page = floatround(float(surf_get_numskills()) / SKILLS_PER_PAGE, floatround_ceil)

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

	if(item != -1 && item < surf_get_numskills()) {
		new shortname[32]
		surf_get_skillshort(item, shortname, 31)
		if(surf_getskill(id,shortname) < 1 && surf_getpoints(id) >= surf_get_skillcost(item) && surf_get_skillcost(item) != 999999) {
			surf_setskill(id, shortname, surf_getskill(id, shortname)+1)
			surf_setpoints(id, surf_getpoints(id) - surf_get_skillcost(item))
			surf_updatepointshud(id)
			storage_saveplayer(id)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("surf_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(id)
						callfunc_end()
					}
				}
			}
		}
	}

	new flags = (1<<9)

	new menuBody[512]
	format(menuBody,511,"\yDARKSURF Shop^n")
	for(new i = (player_page[id]-1)*SKILLS_PER_PAGE; i < surf_get_numskills() && i < (player_page[id]-1)*SKILLS_PER_PAGE+SKILLS_PER_PAGE; i++) {
		new shortname[32]
		surf_get_skillshort(i, shortname, 31)
		new longname[32]
		surf_get_skillname(i, longname, 31)

		if(surf_getskill(id,shortname)) {
			if(surf_get_skillcost(i) == 0) {
				format(menuBody,511,"%s\d%d. %s (FREE)^n", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname)
			} else {
				format(menuBody,511,"%s\d%d. %s (OWNED)^n", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname)
			}
		} else {
			if(surf_get_skillcost(i) == 999999) {
				format(menuBody,511,"%s\r%d. %s (MEMBERS ONLY)^n", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname)
			} else if(surf_getpoints(id) >= surf_get_skillcost(i)) {
				format(menuBody,511,"%s\w%d. %s (Cost: %d)^n", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname, surf_get_skillcost(i))
				flags |= (1<<((i-(player_page[id]-1)*SKILLS_PER_PAGE+1)-1))
			} else {
				format(menuBody,511,"%s\r%d. %s (Cost: %d)^n", menuBody, i-(player_page[id]-1)*SKILLS_PER_PAGE+1, longname, surf_get_skillcost(i))
			}
		}
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
	format(menuBody,511,"%s\yPoints: %d^n", menuBody, surf_getpoints(id))

	show_menu(id,flags,menuBody)
	set_menuopen(id, 1)

	return PLUGIN_HANDLED
}
