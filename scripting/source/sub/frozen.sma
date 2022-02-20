#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>
#include <sub_frozen>

new frozen[33]

public plugin_init() {
	register_plugin("Subsys - Frozen","T9k","Team9000")

	set_task(10.0,"message",0,"",0,"b")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_frozen")

	register_native("get_frozen","get_frozen_impl")
}

public get_frozen_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return frozen[get_param(1)]
}

public client_connect(id) {
	frozen[id] = 0
}

public storage_register_fw() {
	storage_reg_playerfield("frozen")
}

public storage_loadplayer_fw(id, status) {
	new value[32]

	if(id > 0) {
		new result = get_playervalue(id, "frozen", value, 31)
		if(result != 0) {
			if(equal(value, "1")) {
				frozen[id] = 1
			}
		}
	}

	return
}

public message() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(frozen[targetindex]) {
				alertmessage(targetindex,3,"YOUR ACCOUNT HAS BEEN FROZEN DUE TO A PAYPAL FRAUD ALERT FOR YOUR ACCOUNT")
				alertmessage(targetindex,3,"PLEASE CONTACT doubleM FOR MORE INFORMATION")
			}
		}
	}
}
