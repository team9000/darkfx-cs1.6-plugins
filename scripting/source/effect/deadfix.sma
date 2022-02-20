#include <amxmodx>
#include <sub_stocks>

public plugin_init() {
	register_plugin("Effect - Dead Fix","T9k","Team9000")

	return PLUGIN_CONTINUE
}

public client_putinserver(id) {
	set_task(0.1, "specall", id)
}

public specall(id) {
	if(!is_user_connected(id) || is_user_connecting(id)) {
		return
	}

	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(is_user_connecting(targetindex) || !is_user_connected(targetindex)) {
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("TeamInfo"), {0,0,0}, id)
				write_byte(targetindex)
				write_string("SPECTATOR")
				message_end()
			}
		}
	}
}

public client_connect(id) {


	if(!is_user_bot(id)) {
		message_begin(MSG_BROADCAST, get_user_msgid("TeamInfo"))
		write_byte(id)
		write_string("SPECTATOR")
		message_end()
	}

	return PLUGIN_CONTINUE
}
