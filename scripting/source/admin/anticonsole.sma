#include <amxmodx>
#include <sub_stocks>

new anticonsoleit[33] = {0, ... }

public admin_anticonsole(id,level,cid) { 
	if(!cmd_access(id,level,cid))
		return PLUGIN_HANDLED

	anticonsoleit[id] = 1
	client_cmd(id, "messagemode")

	return PLUGIN_HANDLED 
} 

public handle_say(id) {
	if(anticonsoleit[id] == 1) {
		new command[512]
  		read_args(command, 511)
		remove_quotes(command)
		client_cmd(id, command)
		anticonsoleit[id] = 0
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_plugin("Admin AntiConsole","T9k","Team9000")
	register_clcmd("amx_anticonsole","admin_anticonsole",LVL_ANTICONSOLE,"Make a chat prompt that will act as a console")
	register_clcmd("say","handle_say")
	return PLUGIN_CONTINUE
}
