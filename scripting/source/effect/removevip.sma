#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>

public plugin_init() {
	register_plugin("Effect - Remove VIP","T9k","Team9000")
	set_task(1.0, "remove_ents")
	set_task(1.0,"check_vip",0,"",0,"b")

	return PLUGIN_CONTINUE
}

public check_vip() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(cs_get_user_vip(targetindex)) {
				cs_set_user_vip(targetindex,0)
			}
		}
	}
}

public remove_ents() {
	remove_ent("info_vip_start")
	remove_ent("info_vip_safetyzone")
	remove_ent("func_vip_safetyzone")
}

public remove_ent(classname[]) {
	new ent = find_ent_by_class(-1, classname)
	new temp

	while(ent) {
		temp = find_ent_by_class(ent, classname)
		remove_entity(ent)
		ent = temp
	}
}
