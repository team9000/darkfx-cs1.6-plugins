#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <csx>
#include <sub_lowresources>

new trail

public plugin_init() {
	register_plugin("Effect - Grenade Trails","T9k","Team9000")
}

public plugin_precache() { 
	if(!is_lowresources()) {
		trail = precache_model("sprites/zbeam3.spr")
	}
} 

public grenade_throw(index, greindex, wId) {
	if(!is_lowresources()) {
		new color[3]
		if(get_user_team(index) == 1) {
			color[0] = 254
			color[1] = 0
			color[2] = 0
		} else {
			color[0] = 0
			color[1] = 0
			color[2] = 254
		}
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(22) 
		write_short(greindex)
		write_short(trail)
		write_byte(10)
		write_byte(5)
		write_byte(color[0])
		write_byte(color[1])
		write_byte(color[2])
		write_byte(200)
		message_end()
	
		if(wId == CSW_HEGRENADE) {
			set_rendering(greindex, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 225);
		} else if(wId == CSW_SMOKEGRENADE) {
			set_rendering(greindex, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 225);
		} else {
			set_rendering(greindex, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 225);
		}
	}

	return PLUGIN_CONTINUE
}
