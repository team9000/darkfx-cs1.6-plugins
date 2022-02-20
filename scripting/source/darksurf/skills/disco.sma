#include <amxmodx>
#include <sub_stocks>
#include <darksurf.inc>
#include <sub_handler>

public plugin_init() {
	register_plugin("DARKSURF - *Disco Vision","T9k","Team9000")
	set_task(0.5, "update_disco", 0, "", 0, "b")
}

public surf_register_fw() {
	surf_registerskill("Disco Vision", "disco", 30)
}

public update_disco() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 0, targetname, 32)) {
		while((targetindex = cmd_target())) {
			if(surf_getskill(targetindex, "disco") && surf_getskillon(targetindex, "disco")) {
				new num1 = random_num(0,255)
				new num2 = random_num(0,255)
				new num3 = random_num(0,255)
				new alpha = random_num(70,200)
				message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},targetindex)
				write_short(~0)
				write_short(~0)
				write_short(1<<12)
				write_byte(num1)
				write_byte(num2)
				write_byte(num3)
				write_byte(alpha)
				message_end()
			}
		}
	}
}
