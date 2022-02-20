#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

#define DARKMOD_URL "http://ingame.dark.team9000.net/"

public showstatus(id, link[]) {
	new rand = random(99999);
	new url[128];
	format(url, 127, "%s%s?%d", DARKMOD_URL, link, rand);
/*
	new mapid[32]
	if(get_playervalue(0, "id", mapid, 32))
		format(url, 127, "%s&mapid=%s", url, mapid)
	new ident[32]
	get_cvar_string("amx_server_ident_center", ident, 32)
	format(url, 127, "%s&server=%s", url, ident)
*/
	show_motd(id, url, "DarkMod Status Center")
	return PLUGIN_CONTINUE
}

public server_status(id, level, cid) {
	showstatus(id, "")
	return PLUGIN_CONTINUE
}

public server_help(id, level, cid) {
	showstatus(id, "help")
	return PLUGIN_CONTINUE
}

public server_hook(id, level, cid) {
	showstatus(id, "help/hook")
	return PLUGIN_CONTINUE
}

public server_records(id, level, cid) {
	new map[32], map_encoded[32]
	get_mapname(map,31)
	urlencode(map, map_encoded, 31)
	
	new link[64]
	format(link, 63, "maps/%s", map_encoded)
	showstatus(id, link)
	return PLUGIN_CONTINUE
}

public server_maps(id, level, cid) {
	showstatus(id, "maps")
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_plugin("Effect - Server Help","T9k","Team9000")
	register_clcmd("say /status", "server_status")
	register_clcmd("say /help", "server_help")
	register_clcmd("say /wc3help", "server_help")
	register_clcmd("say /hook", "server_hook")
	register_clcmd("say /top3", "server_records")
	register_clcmd("say /top10", "server_records")
	register_clcmd("say /top15", "server_records")
	register_clcmd("say /top20", "server_records")
	register_clcmd("say /records", "server_records")
	register_concmd("say listmaps","server_maps")
	register_concmd("say /listmaps","server_maps")
	register_concmd("say maplist","server_maps")
	register_concmd("say /maplist","server_maps")

	return PLUGIN_CONTINUE
}
