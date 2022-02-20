#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <dfx>

new lastweap[33]
new reloading[33]

new giveammo[32] = {
0,	//
13,	// P228
0,	//
10,	// Scout
0,	// HE Grenade
7,	// Auto Shotgun
0,	// C4
30,	// MAC-10
30,	// AUG (CT Semi-Sniper)
0,	// Smoke Grenade
30,	// Dual Elites
20,	// Five-Seven
25,	// UMP45
30,	// SG550 (CT Auto-Sniper)
35,	// Defender
25,	// Clarion
12,	// USP
20,	// Glock
10,	// AWP
30,	// MP5 Navy
100,	// M249
8,	// 12 Gauge
30,	// M4
30,	// TMP
20,	// G3SG1 (T Auto-Sniper)
0,	// Flashbang
7,	// Deagle
30,	// SG552 (T Semi-Sniper)
30,	// AK47
0,	// Knife
50,	// P90
0	//
}

public plugin_init() {
	register_plugin("DFX-MOD - *Ammo","MM","doubleM")
}

public darkfx_register_fw() {
	dfx_registerskill2("Deluxe Ammo", "ammo")
}

public client_connect(id) {
	reloading[id] = 0
	lastweap[id] = 0
}

public client_disconnect(id) {
	reloading[id] = 0
	lastweap[id] = 0
}

public cs_set_user_ammo(id, amount) {
	new ent = -1, weapon[32], clip, ammo
	new wid = get_user_weapon(id, clip, ammo)
	get_weaponname(wid, weapon, 31)
	while((ent = find_ent_by_class(ent, weapon)) != 0) {
		if(id == entity_get_edict(ent, EV_ENT_owner)) {
			cs_set_weapon_ammo(ent, amount)
			break
		}
	}
}

public get_extammo(wepi) {
	return floatround(giveammo[wepi]*1.5)
}

public get_normammo(wepi) {
	return giveammo[wepi]
}

public client_PreThink(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		new clip, ammo
		new wepi = get_user_weapon(id,clip,ammo)

		if(wepi != lastweap[id]) {
			reloading[id] = 0
		}

		lastweap[id] = wepi

		if(dfx_getskill2(id, "ammo") && get_normammo(wepi) != 0) {
			if(clip != get_extammo(wepi)) {
				if(!reloading[id]) {
					if(!(get_user_button(id) & IN_ATTACK) && (clip == 0 || get_user_button(id) & IN_RELOAD)) {
						cs_set_user_bpammo(id,wepi,1)
						cs_set_user_ammo(id,0)
						reloading[id] = 1
						do_attackcmd(id)
						set_task(0.2, "do_attackcmd", id)
						set_task(0.4, "do_attackcmd", id)
						set_task(0.6, "do_attackcmd", id)
					} else {
						cs_set_user_bpammo(id,wepi,0)
					}
				}

				if(cs_get_user_bpammo(id,wepi) != 1 && reloading[id]) {
					reloading[id] = 0
					cs_set_user_ammo(id,get_extammo(wepi))
				}
			} else {
				cs_set_user_bpammo(id,wepi,0)
			}
		}
	}
}

public do_attackcmd(id) {
	if(reloading[id]) {
		client_cmd(id, "+attack;wait;-attack")
	}
}
