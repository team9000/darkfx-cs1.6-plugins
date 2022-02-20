#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <darksurf.inc>
#include <sub_handler>
#include <sub_hud>

#define NEED_COLORRGBS
#define NEED_COLORNAMES
#include <sub_const>

new colorlist[9][] = {"Red", "Orange", "Yellow", "Green", "Blue", "Pink", "Cyan", "Silver", "White"}
new colorcode[9][] = {"red", "orange", "yellow", "green", "blue", "pink", "cyan", "silver", "white"}
new stylelist[4][] = {"Dotted", "Thick", "Foggy", "Spiked"}

new glow_on[33]
new glow_color[33]

new trail_on[33]
new trail_color[33]
new trail_style[33]
new setup_mode[33]

public plugin_init() {
	register_plugin("DARKSURF - *Glow/Trail","T9k","Team9000")
	register_menucmd(register_menuid("Glow/Trail Menu"), 1023, "menuProc")
}

public client_connect(id) {
	glow_on[id] = 0
	glow_color[id] = 0

	trail_on[id] = 0
	trail_color[id] = 0
	trail_style[id] = 0
}

public surf_register_fw() {
	surf_registerskill("Glow / Trail", "glowtrail", 999999, 0)
}

public surf_change_skill(id) {
	if(get_user_flags(id) & LVL_GLOWTRAIL && surf_getskillon(id, "glowtrail")) {
		if(is_user_alive(id)) {
			setup_mode[id] = 1
			set_task(0.01, "menu", id)
		}
		surf_setskillon(id, "glowtrail", 0)
	}
}

public menu(id) {
	setup_mode[id] = 1
	menuProc(id, -1)
}

public update_glow(id) {
	if(glow_on[id]) {
		new colorid = 0
		for(new i = 0; i < NUM_COLORS; i++) {
			if(equal(colorcode[glow_color[id]], colornames[i])) {
				colorid = i
				break
			}
		}

		new params[6]
		params[0] = kRenderFxGlowShell
		params[1] = colorrgbs[colorid][0]
		params[2] = colorrgbs[colorid][1]
		params[3] = colorrgbs[colorid][2]
		params[4] = kRenderNormal
		params[5] = 15
		handle_rendering(4, id, params)
	} else {
		handle_rendering_off(4, id)
	}
}

public update_trail(id) {
	if(trail_on[id]) {
		new colorid = 0
		for(new i = 0; i < NUM_COLORS; i++) {
			if(equal(colorcode[trail_color[id]], colornames[i])) {
				colorid = i
				break
			}
		}

		handle_trail(0, id, trail_style[id], colorid)
	} else {
		handle_trail_off(0, id)
	}
}

public menuProc(id, key) {
	set_menuopen(id, 0)

	if(setup_mode[id] == 1) {
		if(key == 0) {
			glow_on[id] = !glow_on[id]
			update_glow(id)
		}
		if(key == 1) {
			setup_mode[id] = 2
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 2) {
			trail_on[id] = !trail_on[id]
			update_trail(id)
		}
		if(key == 3) {
			setup_mode[id] = 3
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 4) {
			setup_mode[id] = 4
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}

		if(key == 9) {
			return PLUGIN_HANDLED
		}

		new flags = 0

		new menuBody[2048]
		format(menuBody,2047,"\yGlow/Trail Menu^n")
		format(menuBody,2047,"%s\w1. Enable Glow: ", menuBody)
		if(glow_on[id]) {
			format(menuBody,2047,"%s\yON^n", menuBody)
		} else {
			format(menuBody,2047,"%s\rOFF^n", menuBody)
		}
		flags |= (1<<0)

		if(glow_on[id]) {
			format(menuBody,2047,"%s\w", menuBody)
			flags |= (1<<1)
		} else {
			format(menuBody,2047,"%s\d", menuBody)
		}

		format(menuBody,2047,"%s2. Change Glow Color: %s^n^n", menuBody, colorlist[glow_color[id]])

		format(menuBody,2047,"%s\w3. Enable Trail: ", menuBody)
		if(trail_on[id]) {
			format(menuBody,2047,"%s\yON^n", menuBody)
		} else {
			format(menuBody,2047,"%s\rOFF^n", menuBody)
		}
		flags |= (1<<2)

		if(trail_on[id]) {
			format(menuBody,2047,"%s\w", menuBody)
			flags |= (1<<3)|(1<<4)
		} else {
			format(menuBody,2047,"%s\d", menuBody)
		}

		format(menuBody,2047,"%s4. Change Trail Color: %s^n", menuBody, colorlist[trail_color[id]])
		format(menuBody,2047,"%s5. Change Trail Style: %s^n", menuBody, stylelist[trail_style[id]])

		format(menuBody,511,"%s^n", menuBody)

		format(menuBody,511,"%s\r0. Exit", menuBody)
		flags |= (1<<9)

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}
	if(setup_mode[id] == 2) {
		if(key >= 0 && key < 9) {
			glow_color[id] = key
			update_glow(id)
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}

		new flags = 0

		new menuBody[2048]
		format(menuBody,2047,"\yGlow/Trail Menu^n")
		format(menuBody,2047,"%s\rGlow Color^n", menuBody)
		for(new i = 0; i < 9; i++) {
			format(menuBody,2047,"%s\w%d. %s^n", menuBody, i+1, colorlist[i])
			flags |= (1<<i)
		}

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}
	if(setup_mode[id] == 3) {
		if(key >= 0 && key < 9) {
			trail_color[id] = key
			update_trail(id)
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}

		new flags = 0

		new menuBody[2048]
		format(menuBody,2047,"\yGlow/Trail Menu^n")
		format(menuBody,2047,"%s\rTrail Color^n", menuBody)
		for(new i = 0; i < 9; i++) {
			format(menuBody,2047,"%s\w%d. %s^n", menuBody, i+1, colorlist[i])
			flags |= (1<<i)
		}

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}
	if(setup_mode[id] == 4) {
		if(key >= 0 && key < 4) {
			trail_style[id] = key
			update_trail(id)
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}
		if(key == 9) {
			setup_mode[id] = 1
			menuProc(id, -1)
			return PLUGIN_HANDLED
		}

		new flags = 0

		new menuBody[2048]
		format(menuBody,2047,"\yGlow/Trail Menu^n")
		format(menuBody,2047,"%s\rTrail Style^n", menuBody)
		for(new i = 0; i < 4; i++) {
			format(menuBody,2047,"%s\w%d. %s^n", menuBody, i+1, stylelist[i])
			flags |= (1<<i)
		}

		show_menu(id,flags,menuBody)
		set_menuopen(id, 1)
	}

	return PLUGIN_HANDLED
}
