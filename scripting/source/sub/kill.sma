#include <amxmodx>
#include <sub_stocks>
#include <sub_damage>
#include <sub_respawn>
#include <fun>

#define FLOOD_CONTROL 3.0

new Float:lastkill[33]

public plugin_init() {
	register_plugin("Subsys - Kill","T9k","Team9000")

	register_concmd("respawn","client_kill_c")
	register_concmd("say /respawn","client_kill_s")
}

public client_connect(id) {
	lastkill[id] = 0.0
}

public suicide(id) {
	if(lastkill[id] < get_gametime()-FLOOD_CONTROL) {
		if(get_upperhealth()) {
			set_user_health(id, 1+256000)
		} else {
			set_user_health(id, 1)
		}

		dam_dealdamage(id, id, 100000, "suicide", 0, 1, 0, 0, 0)
		lastkill[id] = get_gametime()
		return
	}

	return
}

public client_kill_s(id) {
	if(get_upperhealth()) {
		suicide(id)
	}
	return PLUGIN_CONTINUE
}

public client_kill_c(id) {
	if(get_upperhealth()) {
		suicide(id)
	}
	return PLUGIN_HANDLED
}

public client_kill(id) {
	if(get_upperhealth()) {
		suicide(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
