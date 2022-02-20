#include <amxmodx>
#include <sub_stocks>
#include <engine>

public plugin_init(){
	register_plugin("Admin Settings","T9k","Team9000")
	register_concmd("amx_gravity","admin_gravity",LVL_GRAVITY,"[gravity] - Displays or alters gravity")
	register_concmd("amx_restart","admin_restart",LVL_RESTART,"Restarts the game")
	register_concmd("amx_rr","admin_rr",LVL_RR,"Restarts the round")
	register_concmd("amx_light","admin_light",LVL_LIGHT,"<a-z | #OFF> - Sets the ambient light level")
	register_concmd("amx_alltalk","admin_alltalk",LVL_ALLTALK,"<1,0> - Enables or disables alltalk")
	return PLUGIN_CONTINUE
}

public admin_gravity(id,level, cid){
	if (!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	if (read_argc() < 2) {
		    console_print(id,"The gravity is currently ^"%d^"", get_cvar_num("sv_gravity"))
		    return PLUGIN_HANDLED
	}

	new gravity[12]
	read_argv(1,gravity,11)
	set_cvar_num("sv_gravity", str_to_num(gravity))

	adminalert_v(id, "", "set the gravity to %s", gravity)

	return PLUGIN_HANDLED
}

public admin_restart(id, level, cid) { 
	if (!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	set_cvar_string("sv_restart", "1")

	adminalert_v(id, "", "restarted the game")

	return PLUGIN_HANDLED 
}

public admin_rr(id, level, cid) { 
	if (!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	set_cvar_string("sv_restartround", "1")

	adminalert_v(id, "", "restarted the round")

	return PLUGIN_HANDLED 
}

public admin_light(id,level,cid) {  
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31) 
	set_lights(arg)

	adminalert_v(id, "", "set the level brightness")

	return PLUGIN_HANDLED
}

public admin_alltalk(id,level,cid) {  
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31) 
	if(str_to_num(arg) == 1) {
		set_cvar_num("sv_alltalk", 1)
		adminalert_v(id, "", "ENABLED alltalk")
	} else {
		set_cvar_num("sv_alltalk", 0)
		adminalert_v(id, "", "DISABLED alltalk")
	}

	return PLUGIN_HANDLED
}
