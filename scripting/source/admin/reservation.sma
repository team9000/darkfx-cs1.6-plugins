#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

public plugin_init() {
	register_plugin("Admin Slot Reservation","T9k","Team9000")

	return PLUGIN_CONTINUE
}

public storage_loadplayer_fw(id, status) {
	if(!status) {
		return
	}

	if(get_playersnum(1) > get_maxplayers()-1) {
		if(get_user_flags(id) & LVL_RESERVATION) {
			new ping, loss, maxping=-1, maxpingplayer=-1
			new targetindex, targetname[33]
			if(cmd_targetset(-1, "*", 0, targetname, 32)) {
				while((targetindex = cmd_target())) {
					get_user_ping(targetindex, ping, loss)
					if(ping > maxping && !(get_user_flags(targetindex) & LVL_LOWIMMUNITY) && !(get_user_flags(targetindex) & LVL_RESERVATION)) {
						maxping = ping
						maxpingplayer = targetindex
					}
				}
			}
			if(maxpingplayer != -1) {
				server_cmd("kick #%d  %s", get_user_userid(maxpingplayer), "Slot Reservation")
			}
		} else {
			server_cmd("kick #%d  %s", get_user_userid(id), "Slot Reservation")
		}
	}
}
