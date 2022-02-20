#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <sub_handler>
#include <sub_lowresources>

public plugin_init() {
	register_plugin("Effect - Admin Model","T9k","Team9000")

	set_task(2.0, "update", 0, "", 0, "b")

	return PLUGIN_CONTINUE
}

public plugin_precache() {
	if(is_lowresources()) return PLUGIN_CONTINUE;
	precache_model("models/player/team9000adminct/team9000adminct.mdl")
	precache_model("models/player/team9000admint/team9000admint.mdl")

	return PLUGIN_CONTINUE
}

public update() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(get_user_flags(targetindex) & LVL_ADMINMODEL) {
				modelnow(targetindex)
			} else {
				model_off(targetindex)
			}
		}
	}
}

public modelnow(id) {
	if(is_lowresources()) return;
	if(cs_get_user_team(id) == CS_TEAM_T) {
		handle_model(2, id, "team9000admint")
	} else {
		handle_model(2, id, "team9000adminct")
	}
}

public model_off(id) {
	handle_model_off(2, id)
}

