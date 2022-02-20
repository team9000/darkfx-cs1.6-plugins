#include <amxmodx>
#include <sub_stocks>

public plugin_init() {
	register_plugin("Effect - Radio","T9k","Team9000")
	register_clcmd("say /radio", "play")
	register_clcmd("say /stop", "stop")

	return PLUGIN_CONTINUE
}

public play(id, level, cid) {
	new message[2048]
	format(message, 2047, "<html><body bgcolor=^"000000^"><font color=^"FFFF00^"><center>You are listening to SLAYRadio<br>(You can close this window once it loads)<br>")
	format(message, 2047, "%s<object id=^"MediaPlayer1^" classid=^"CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95^" standby=^"Loading SLAYRadio...^">", message)
	format(message, 2047, "%s<param name=^"Filename^" value=^"http://relay.slayradio.org:8000/^">", message)
	format(message, 2047, "%s<param name=^"AnimationAtStart^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"TransparentAtStart^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"ShowControls^" value=^"true^">", message)
	format(message, 2047, "%s<param name=^"PlayCount^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"AutoPlay^" value=^"true^">", message)
	format(message, 2047, "%s</object></center></body></html>", message)
	show_motd(id, message, "SLAYRadio")

	return PLUGIN_CONTINUE
}

public stop(id, level, cid) {
	new message[2048]
	format(message, 2047, "<html><body bgcolor=^"000000^"><font color=^"FFFF00^"><center>You are listening to SLAYRadio<br>(You can close this window once it loads)<br>")
	format(message, 2047, "%s<object id=^"MediaPlayer1^" classid=^"CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95^" standby=^"Loading SLAYRadio...^">", message)
	format(message, 2047, "%s<param name=^"Filename^" value=^"http://relay.slayradio.org:8000/^">", message)
	format(message, 2047, "%s<param name=^"AnimationAtStart^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"TransparentAtStart^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"ShowControls^" value=^"true^">", message)
	format(message, 2047, "%s<param name=^"PlayCount^" value=^"false^">", message)
	format(message, 2047, "%s<param name=^"AutoPlay^" value=^"false^">", message)
	format(message, 2047, "%s</object></center></body></html>", message)
	show_motd(id, message, "SLAYRadio")

	return PLUGIN_CONTINUE
}
