#include <amxmodx>
#include <sub_stocks>
#include <sub_hud>
#include <engine>
#include <sub_time>
#include <cstrike>
#include <fun>
#include <darksurf.inc>

new lastgive[33]

new weapmodels[32][] = {
"",
"models/w_p228.mdl",
"",
"models/w_scout.mdl",
"models/w_hegrenade.mdl",
"models/w_xm1014.mdl",
"",
"models/w_mac10.mdl",
"models/w_aug.mdl",
"models/w_smokegrenade.mdl",
"models/w_elite.mdl",
"models/w_fiveseven.mdl",
"models/w_ump45.mdl",
"models/w_sg550.mdl",
"models/w_galil.mdl",
"models/w_famas.mdl",
"models/w_usp.mdl",
"models/w_glock18.mdl",
"models/w_awp.mdl",
"models/w_mp5.mdl",
"models/w_m249.mdl",
"models/w_m3.mdl",
"models/w_m4a1.mdl",
"models/w_tmp.mdl",
"models/w_g3sg1.mdl",
"models/w_flashbang.mdl",
"models/w_deagle.mdl",
"models/w_sg552.mdl",
"models/w_ak47.mdl",
"models/w_knife.mdl",
"models/w_p90.mdl",
""
}

new weaponclass[32] = {
0,
2,
0,
1,
3,
1,
0,
1,
1,
4,
2,
2,
1,
1,
1,
1,
2,
2,
1,
1,
1,
1,
1,
1,
1,
5,
2,
1,
1,
6,
1,
0
}

public plugin_init() {
   	register_plugin("DARKSURF - WEAPONS","T9k","Team9000")

	set_task(0.2, "check_weapons", 9999, "", 0, "b")

	return PLUGIN_CONTINUE
}

public client_connect(id) {
	lastgive[id] = 0
}

public check_weapons() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			new Float:origin[3], Float:origin2[3]
			entity_get_vector(targetindex, EV_VEC_origin, origin)

			new ent = -1
			while((ent = find_ent_by_class(ent, "weaponbox"))) {
				entity_get_vector(ent, EV_VEC_origin, origin2)

				if(origin[0] > origin2[0] - 20 &&
				   origin[1] > origin2[1] - 20 &&
				   origin[2] > origin2[2] - 40 &&
				   origin[0] < origin2[0] + 20 &&
				   origin[1] < origin2[1] + 20 &&
				   origin[2] < origin2[2] + 40) {
					pfn_touch(ent, targetindex)
				}
			}
			ent = -1
			while((ent = find_ent_by_class(ent, "armoury_entity"))) {
				entity_get_vector(ent, EV_VEC_origin, origin2)

				if(origin[0] > origin2[0] - 20 &&
				   origin[1] > origin2[1] - 20 &&
				   origin[2] > origin2[2] - 40 &&
				   origin[0] < origin2[0] + 20 &&
				   origin[1] < origin2[1] + 20 &&
				   origin[2] < origin2[2] + 40) {
					pfn_touch(ent, targetindex)
				}
			}
		}
	}
}

public pfn_touch(ptr,ptd) {
	if(!ptr || !ptd) {
		return PLUGIN_CONTINUE
	}

	new toucherclass[32], touchedclass[32]
	entity_get_string(ptr, EV_SZ_classname, toucherclass, 31)
	entity_get_string(ptd, EV_SZ_classname, touchedclass, 31)

	if(!equal(touchedclass, "player")) {
		return PLUGIN_CONTINUE
	}

	new touchermodel[32]
	entity_get_string(ptr, EV_SZ_model, touchermodel, 31)

	if(equal(touchermodel, "models/w_backpack.mdl")) {
		return PLUGIN_CONTINUE
	}

	new id = ptd

	new weapid = -1
	if((equal(toucherclass, "weaponbox") && entity_get_int(ptr,EV_ENT_owner) > 32) || equal(toucherclass, "armoury_entity")) {
		for(new i = 0; i < 32; i++) {
			if(equal(weapmodels[i], "")) {
				continue
			}

			if(equal(touchermodel, weapmodels[i])) {
				weapid = i
				break
			}
		}

		if(weapid == -1) {
			return PLUGIN_CONTINUE
		}

		if(user_has_weapon(id, weapid)) {
			if(time_time() > lastgive[id]) {
				lastgive[id] = time_time()
				new weapon[32]
				get_weaponname(weapid, weapon, 31)
				give_item(id, weapon)
				give_item(id, weapon)
			}

			return PLUGIN_HANDLED
		}

		for(new i = 0; i < 32; i++) {
			if(weaponclass[weapid] == weaponclass[i]) {
				if(user_has_weapon(id, i)) {
					return PLUGIN_HANDLED
				}
			}
		}

		lastgive[id] = time_time()
		new weapon[32]
		get_weaponname(weapid, weapon, 31)
		for(new i = 0; i < 10; i++) {
			give_item(id, weapon)
		}
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
