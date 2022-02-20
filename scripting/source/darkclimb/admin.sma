#include <amxmodx>
#include <sub_stocks>
#include <darkclimb.inc>
#include <settings>
#include <sub_storage>

public plugin_init() {
	register_plugin("DARKCLIMB - ADMIN","T9k","Team9000")

	register_concmd("amx_climb_points","AdminPoints",LVL_DARKCLIMB,"<authid, nick, @team or #userid> [points]")
	register_concmd("amx_climb_skill","AdminSkill",LVL_DARKCLIMB,"<authid, nick, @team or #userid> <skill> [level]")
}

public plugin_natives() {
	register_library("darkclimb_admin")
}

public AdminPoints(id,level,cid) { 
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1,target,31)

	if(read_argc() < 3) {
		new targetindex, targetname[33], name[33]
		if(cmd_targetset(id, target, 0, targetname, 32)) {
			while((targetindex = cmd_target())) {
				get_user_name(targetindex,name,32)

				if(!climb_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}

				console_print(id,"%s has %d Points", name, climb_getpoints(targetindex))
			}
		}
		return PLUGIN_HANDLED
	}

	new spoints[8]
	read_argv(2,spoints,7)
	new ipoints = str_to_num(spoints)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!climb_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}

			climb_setpoints(targetindex, ipoints)
			climb_updatepointshud(targetindex)
			storage_saveplayer(targetindex)
		}

		adminalert_v(id, "", "set the points of %s to %s", targetname, spoints)
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

				if(!climb_playerloaded(targetindex)) {
					console_print(id,"%s is not loaded", name)
					continue
				}

				new skillname[32]
				climb_get_skillname(iskill, skillname, 31)
				new skillshort[32]
				climb_get_skillshort(iskill, skillshort, 31)
				console_print(id,"%s has a %s level of %d", name, skillname, climb_getskill(targetindex, skillshort))
			}
		}
		return PLUGIN_HANDLED
	}

	new slevel[8]
	read_argv(3,slevel,7)
	new ilevel = str_to_num(slevel)

	new skillshort[32]
	climb_get_skillshort(iskill, skillshort, 31)

	new targetindex, targetname[33], name[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			get_user_name(targetindex,name,32)

			if(!climb_playerloaded(targetindex)) {
				console_print(id,"%s is not loaded", name)
				continue
			}

			climb_setskill(targetindex, skillshort, ilevel)
			storage_saveplayer(targetindex)

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("climb_change_skill", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(targetindex)
						callfunc_end()
					}
				}
			}
		}


		new skillname[32]
		climb_get_skillname(iskill, skillname, 31)
		adminalert_v(id, "", "set the ^"%s^" level of %s to %d", skillname, targetname, ilevel)
	}

	return PLUGIN_HANDLED
}
