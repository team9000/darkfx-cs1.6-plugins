#include <amxmodx>
#include <sub_stocks>
#include <dfx>
#include <settings>
#include <sub_auth>
#include <sub_storage>

public plugin_init() {
	register_plugin("DFX-MOD - ADMIN","MM","doubleM")

	register_concmd("amx_dfx_crazymode","AdminCrazyMode",LVL_DFXMOD,"<0,1>")

	register_concmd("amx_dfx_xp","AdminXP",LVL_DFXMOD,"<authid, nick, @team or #userid> [xp]")
	register_concmd("amx_dfx_level","AdminLevel",LVL_DFXMOD,"<authid, nick, @team or #userid> [level]")
	register_concmd("amx_dfx_token","AdminToken",LVL_DFXMOD,"<authid, nick, @team or #userid> [tokens]")
	register_concmd("amx_dfx_skill","AdminSkill",LVL_DFXMOD,"<authid, nick, @team or #userid> <skill> [level]")

	register_concmd("amx_dfx_reload","AdminReload",LVL_DFXMOD,"<authid, nick, @team or #userid>")
}

public plugin_natives() {
	register_library("dfx-mod-admin")
}

public AdminCrazyMode(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 

	new onoff[32]
	read_argv(1,onoff,31)

	dfx_setcrazymode(str_to_num(onoff))

	new name[32]
	get_user_name(id,name,31)
	if(str_to_num(onoff)) {
		adminalert_v(id, "", "activated DFX-MOD EXTREME!!!")
	} else {
		adminalert_v(id, "", "deactivated DFX-MOD EXTREME!!!")
	}

	return PLUGIN_HANDLED
}

public AdminXP(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)

	if(read_argc() < 3) {
		new targetindex, targetname[33], name[33]
		if(cmd_targetset(id, target, 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				get_user_name(targetindex,name,32)

				if(!dfx_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}
				if(!get_authed(targetindex)) {
					console_print(id,"%s is not authenticated", name)
					continue
				}

				console_print(id,"%s has %d XP", name, dfx_getxp(targetindex))
			}
		}
		return PLUGIN_HANDLED
	}

	new sxp[8]
	read_argv(2,sxp,7)
	new ixp = str_to_num(sxp)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!dfx_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}
			if(!get_authed(targetindex)) {
				console_print(id,"%s is not authenticated", name)
				continue
			}

			dfx_setxp(targetindex, ixp)
			dfx_updatexphud(targetindex)
			storage_saveplayer(targetindex)
		}

		adminalert_v(id, "", "set the XP of %s to %s", targetname, sxp)
	}

	return PLUGIN_HANDLED
}

public AdminLevel(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)

	if(read_argc() < 3) {
		new targetindex, targetname[33], name[33]
		if(cmd_targetset(id, target, 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				get_user_name(targetindex,name,32)

				if(!dfx_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}
				if(!get_authed(targetindex)) {
					console_print(id,"%s is not authenticated", name)
					continue
				}

				console_print(id,"%s is level %d", name, dfx_getlevel(targetindex))
			}
		}
		return PLUGIN_HANDLED
	}

	new slevel[8]
	read_argv(2,slevel,7)
	new ilevel = str_to_num(slevel)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!dfx_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}
			if(!get_authed(targetindex)) {
				console_print(id,"%s is not authenticated", name)
				continue
			}

			dfx_setlevel(targetindex, ilevel)
			dfx_updatexphud(targetindex)
			storage_saveplayer(targetindex)
		}

		adminalert_v(id, "", "set the level of %s to %s", targetname, slevel)
	}

	return PLUGIN_HANDLED
}

public AdminToken(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)

	if(read_argc() < 3) {
		new targetindex, targetname[33], name[33]
		if(cmd_targetset(id, target, 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				get_user_name(targetindex,name,32)

				if(!dfx_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}
				if(!get_authed(targetindex)) {
					console_print(id,"%s is not authenticated", name)
					continue
				}

				console_print(id,"%s has %d tokens", name, dfx_gettokens(targetindex))
			}
		}
		return PLUGIN_HANDLED
	}

	new stokens[8]
	read_argv(2,stokens,7)
	new itokens = str_to_num(stokens)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!dfx_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}
			if(!get_authed(targetindex)) {
				console_print(id,"%s is not authenticated", name)
				continue
			}

			dfx_settokens(targetindex, itokens)
			storage_saveplayer(targetindex)
		}

		adminalert_v(id, "", "set the tokens of %s to %s", targetname, stokens)
	}

	return PLUGIN_HANDLED
}

public AdminSkill(id,level,cid) { 
	if (!cmd_access(id,level,cid,3)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new sskill[8]
	read_argv(2,sskill,7)
	new iskill = str_to_num(sskill)

	if(read_argc() < 4) {
		new targetindex, targetname[33], name[33]
		if(cmd_targetset(id, target, 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				get_user_name(targetindex,name,32)

				if(!dfx_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}
				if(!get_authed(targetindex)) {
					console_print(id,"%s is not authenticated", name)
					continue
				}

				new skillname[32]
				dfx_get_skillname(iskill, skillname, 31)
				new skillshort[32]
				dfx_get_skillshort(iskill, skillshort, 31)
				console_print(id,"%s has a %s level of %d", name, skillname, dfx_getactualskill(targetindex, skillshort))
			}
		}
		return PLUGIN_HANDLED
	}

	new slevel[8]
	read_argv(3,slevel,7)
	new ilevel = str_to_num(slevel)

	new skillshort[32]
	dfx_get_skillshort(iskill, skillshort, 31)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!dfx_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}
			if(!get_authed(targetindex)) {
				console_print(id,"%s is not authenticated", name)
				continue
			}

			dfx_setskill(targetindex, skillshort, ilevel)
			storage_saveplayer(targetindex)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("darkfx_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(targetindex)
						callfunc_end()
					}
				}
			}
		}


		new skillname[32]
		dfx_get_skillname(iskill, skillname, 31)
		adminalert_v(id, "", "set the ^"%s^" level of %s to %d", skillname, targetname, ilevel)
	}

	return PLUGIN_HANDLED
}

public AdminReload(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!dfx_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}
			if(!get_authed(targetindex)) {
				console_print(id,"%s is not authenticated", name)
				continue
			}

			for(new i = 0; i < dfx_get_numskills(); i++) {
				new skillshort[32]
				dfx_get_skillshort(i, skillshort, 31)
				dfx_setskill(targetindex, skillshort, 1)
			}
			for(new i = 0; i < dfx_get_numskills2(); i++) {
				new skillshort[32]
				dfx_get_skillshort(i, skillshort, 31)
				dfx_setskill2(targetindex, skillshort, 0)
			}
			dfx_settokens(targetindex, dfx_getlevel(targetindex)-1)
			if(dfx_getlevel(targetindex) >= 20) {
				dfx_settokens2(targetindex, dfx_getlevel(targetindex)-19)
			} else {
				dfx_settokens2(targetindex, 0)
			}

			storage_saveplayer(targetindex)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("darkfx_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(targetindex)
						callfunc_end()
					}
				}
			}
		}

		adminalert_v(id, "", "reset the skills for %s", targetname)
	}

	return PLUGIN_HANDLED
}
