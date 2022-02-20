#include <amxmodx>
//#include <sub_stocks>  // INITS BEFORE STOCKS!
#include <sub_time>

public plugin_init() {
	register_plugin("Subsys - Config","T9k","Team9000")
	register_cvar("amx_mode","1")
	register_cvar("amx_password_field","_pw")
	register_cvar("amx_default_access","z")
	register_cvar("amx_show_activity","1")
	register_cvar("amx_ignore_immunity","0")
	register_cvar("amx_voting","0")
	register_cvar("amx_last_vote","0")
	register_cvar("amx_vote_delay","300")
	register_cvar("amx_server_ident","darkmod")
	register_cvar("amx_server_ident_mapset","darkmod")
	register_cvar("amx_server_ident_motdset","darkmod")
	register_cvar("amx_server_ident_status","darkmod")
	register_cvar("amx_server_ident_center","darkmod")

// can't call this here, because it segfaults the server during bootup :(
//	execcfg()
	set_task(0.1, "vote_time")
	set_task(0.1, "execcfg")
	set_task(0.5, "execcfg")
	set_task(1.0, "delayrestart")
}

public execcfg() {
	new servercfg[128]
	get_cvar_string("servercfgfile", servercfg, 128)
	server_cmd("exec %s", servercfg)
	server_exec()
}

public vote_time() {
	set_cvar_num("amx_last_vote", time_time())
}

public delayrestart() {
	set_cvar_num("sv_restartround", 1)
}
