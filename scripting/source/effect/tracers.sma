#include <amxmodx> 
#include <sub_stocks> 

new lastammo[33]
new lastweapon[33]

public plugin_init() {
	register_plugin("Effect - Tracers","T9k","Team9000") 
	register_event("CurWeapon","make_tracer","b")
	return PLUGIN_CONTINUE
}

public make_tracer(id) {
	new wepi = read_data(2)
	new ammo = read_data(3)

	if(ammo < lastammo[id] && lastweapon[id] == wepi) {
		new vec1[3], vec2[3]
		get_user_origin(id,vec1,1)
		get_user_origin(id,vec2,3)

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(6)
		write_coord(vec1[0]) 
		write_coord(vec1[1]) 
		write_coord(vec1[2]) 
		write_coord(vec2[0]) 
		write_coord(vec2[1]) 
		write_coord(vec2[2]) 
		message_end()
	}

	lastammo[id] = ammo
	lastweapon[id] = wepi
}
