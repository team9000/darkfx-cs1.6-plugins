#include <amxmodx> 
#include <sub_stocks> 
#include <cstrike>
#include <fun>
#include <sub_respawn>
#include <sub_handler>
#include <sub_disqualify>

#define NEED_COLORRGBS
#define NEED_COLORNAMES
#include <sub_const>

public plugin_init() { 
	register_plugin("Admin Players", "T9k", "Team9000") 
	register_concmd("amx_armor", "admin_armor", LVL_ARMOR, "<target> <amount> - Sets the armor of a player")
	register_concmd("amx_health", "admin_health", LVL_HEALTH, "<target> <amount> - Sets the health of a player")
	register_concmd("amx_clexec","admin_clexec",LVL_CLEXEC,"<target> <command> - Executes a command in a players console")
	register_concmd("amx_godmode", "admin_godmode", LVL_GODMODE, "<target> <0,1> - Sets godmode on a player")
	register_concmd("amx_noclip","admin_noclip",LVL_NOCLIP,"<target> <0,1> - Sets noclip on a player")
	register_concmd("amx_money","admin_money",LVL_MONEY,"<target> <amount> - Sets the money of a player")
	register_concmd("amx_give","admin_give",LVL_GIVE,"<target> <item> - Gives an item to a player")
	register_concmd("amx_glow","admin_glow",LVL_GLOW,"<target> [color] - Sets a player to glow")
	register_concmd("amx_trail","admin_trail",LVL_TRAIL,"<target> [color] [type(1-4)] - Gives a trail to a player")
	return PLUGIN_CONTINUE
}

public admin_armor(id, level, cid) { 
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31) 
	new amount[32]
	read_argv(2,amount,31)

	if(str_to_num(amount) < 0) {
		client_print(id,print_console,"Clients cannot be given less than 0 armor")
		return PLUGIN_HANDLED
	}
	if(str_to_num(amount) > 999) {
		client_print(id,print_console,"Clients cannot be given more than 999 armor")
		return PLUGIN_HANDLED
	}


	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			set_user_armor(targetindex,str_to_num(amount)) 
			disqualify_now(targetindex, 1)
		}

		adminalert_v(id, "", "set the armor of %s to %d", targetname, str_to_num(amount))
	}

	return PLUGIN_HANDLED
}

public admin_health(id, level, cid) { 
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new target[32] 
	read_argv(1,target,31) 
	new amount[32]
	read_argv(2,amount,31)

	if (str_to_num(amount) < 0) {
		client_print(id,print_console,"Clients cannot be given less than 0 health")
		return PLUGIN_HANDLED
	}
	if (str_to_num(amount) > 100000) {
		client_print(id,print_console,"Clients cannot be given more than 100000 health")
		return PLUGIN_HANDLED
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(get_upperhealth()) {
				set_user_health(targetindex,str_to_num(amount)+256000) 
			} else {
				set_user_health(targetindex,str_to_num(amount)) 
			}
			disqualify_now(targetindex, 2)
		}

		adminalert_v(id, "", "set the health of %s to %d", targetname, str_to_num(amount))
	}

	return PLUGIN_HANDLED
}

public client_PreThink(id) {
	if(id && is_user_connected(id) && is_user_alive(id)) {
		if(get_user_health(id) > 1 && get_user_health(id) % 256 <= 1 || get_user_health(id) % 256 >= 255) {
			set_user_health(id, get_user_health(id)+1)
		}
	}
}
		

public admin_clexec(id, level, cid) { 
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 
	new command[128] 
	read_argv(2,command,127) 

	while(contain(command, "'") != -1) {	
		replace(command,127,"'","^"")
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			client_cmd(targetindex, command)
		}

		adminalert_v(id, "", "executed a command on %s", targetname)
	}

	return PLUGIN_HANDLED 
} 

public admin_godmode(id,level,cid) { 
	if (!cmd_access(id,level,cid,3)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new arg2[32]
	read_argv(2,arg2,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			set_user_godmode(targetindex,str_to_num(arg2))

			if(str_to_num(arg2) == 0) {
				disqualify_stop(targetindex, 2)
			} else {
				disqualify_start(targetindex, 2)
			}
		}

		if(str_to_num(arg2) == 0) {
			adminalert_v(id, "", "turned OFF godmode for %s", targetname)
		} else {
			adminalert_v(id, "", "turned ON godmode for %s", targetname)
		}
	}

	return PLUGIN_HANDLED  
} 

public admin_noclip(id,level,cid) { 
	if (!cmd_access(id,level,cid,3)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31)
	new arg2[32]
	read_argv(2,arg2,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			set_user_noclip(targetindex,str_to_num(arg2))

			if(str_to_num(arg2) == 0) {
				disqualify_stop(targetindex, 2)
			} else {
				disqualify_start(targetindex, 2)
			}
		}

		if(str_to_num(arg2) == 0) {
			adminalert_v(id, "", "turned OFF noclip for %s", targetname)
		} else {
			adminalert_v(id, "", "turned ON noclip for %s", targetname)
		}
	}

	return PLUGIN_HANDLED  
} 

public admin_money(id,level,cid) { 
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED 

	new target[32] 
	read_argv(1,target,31) 
	new amount[32]
	read_argv(2,amount,31) 

	if(str_to_num(amount) < 0) {
		client_print(id,print_console,"Clients cannot be given less than 0 dollars")
		return PLUGIN_HANDLED
	}
	if(str_to_num(amount) > 999999) {
		client_print(id,print_console,"Clients cannot be given greater than 999999 dollars")
		return PLUGIN_HANDLED
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			cs_set_user_money(targetindex,str_to_num(amount),1) 
		}

		adminalert_v(id, "", "set the money of %s to %d", targetname, str_to_num(amount))
	}

	return PLUGIN_HANDLED  
} 

public admin_give(id,level,cid){  
	if (!cmd_access(id,level,cid,3)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 
	new item[32]
	read_argv(2,item,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 7, targetname, 32)) {
		while((targetindex = cmd_target())) {
			give_item(targetindex, item) 
			disqualify_now(targetindex, 3)
		}

		adminalert_v(id, "", "gave %s a %s", targetname, item)
	}

	return PLUGIN_HANDLED  
}

public admin_glow(id,level,cid){  
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 

	new colori = -1
	new color[32]
	if(read_argc() >= 3) {
		read_argv(2,color,31)

		for(new i = 0; i < NUM_COLORS; i++) {
			if(equal(color, colornames[i])) {
				colori = i
				break
			}
		}

		if(colori == -1) {
			client_print(id, print_console, "%s is not a valid color!", color)
			return PLUGIN_HANDLED
		}
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(colori == -1) {
				handle_rendering_off(4, targetindex)
			} else {
				new params[6]
				params[0] = kRenderFxGlowShell
				params[1] = colorrgbs[colori][0]
				params[2] = colorrgbs[colori][1]
				params[3] = colorrgbs[colori][2]
				params[4] = kRenderTransAlpha
				params[5] = 255
				handle_rendering(4, targetindex, params)
			}
		}

		if(colori == -1) {
			adminalert_v(id, "", "removed the glow from %s", targetname)
		} else {
			adminalert_v(id, "", "made %s glow %s", targetname, colornames[colori])
		}
	}

	return PLUGIN_HANDLED  
}

public admin_trail(id,level,cid){  
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 

	new target[32]
	read_argv(1,target,31) 

	new colori = -1
	new color[32]
	if(read_argc() >= 3) {
		read_argv(2,color,31)

		for(new i = 0; i < NUM_COLORS; i++) {
			if(equal(color, colornames[i])) {
				colori = i
				break
			}
		}

		if(colori == -1) {
			client_print(id, print_console, "%s is not a valid color!", color)
			return PLUGIN_HANDLED
		}
	}

	new typei = 0
	new type[32]
	if(read_argc() >= 4) {
		read_argv(3,type,31)
		if(str_to_num(type) >= 1 && str_to_num(type) <= 4) {
			typei = str_to_num(type)-1
		}
	}

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(colori == -1) {
				handle_trail_off(0, targetindex)
			} else {
				handle_trail(0, targetindex, typei, colori)
			}
		}

		if(colori == -1) {
			adminalert_v(id, "", "removed the trail from %s", targetname)
		} else {
			if(typei == 0) {
				adminalert_v(id, "", "gave %s a %s trail", targetname, colornames[colori])
			} else {
				adminalert_v(id, "", "gave %s a %s trail (type %d)", targetname, colornames[colori], typei+1)
			}
		}
	}

	return PLUGIN_HANDLED  
}
