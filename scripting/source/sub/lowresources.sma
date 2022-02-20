#include <amxmodx>
#include <sub_stocks>
#include <sub_lowresources>
#include <sub_storage>

new currentmap_old[32] = ""
new lowresources = 0

public plugin_init() {
	register_plugin("Subsys - Low Resources","T9k","Team9000")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_lowresources")

	register_native("is_lowresources","is_lowresources_impl")
}

public plugin_precache() {
	currentmap_old = ""
	lowresources = 0
}

public is_lowresources_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	new currentmap[32]
	get_mapname(currentmap, 31)
	if(!equal(currentmap_old, currentmap)) {
		get_mapname(currentmap_old, 31)
		lowresources = 0
		new configdir[128]
		get_configsdir(configdir, 127)
		new lowresourcescfg[128]
		format(lowresourcescfg, 127, "%s/lowresources.cfg", configdir)
		if(file_exists(lowresourcescfg)) {
			new line = 0, textline[32], len
			while((line = read_file(lowresourcescfg, line, textline, 31, len))) {
				if(len == 0 || equal(textline, ";", 1))
					continue

				if(equali(textline, currentmap)) {
					server_print("LOW RESOURCE MAP DETECTED")
					lowresources = 1
					break
				}
			}
		}
	}

	return lowresources
}