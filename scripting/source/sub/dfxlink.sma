#include <amxmodx>
#include <sub_stocks>
#include <sub_storage>

new setpass[33]
new confirming[33]
new confirm[33][33]

public plugin_init() {
	register_plugin("Subsys - DFX-LINK","T9k","Team9000")

	register_clcmd("say","handlesay")
}

public client_connect(id) {
	setpass[id] = 0
	confirming[id] = 0
	confirm[id] = ""
}

public storage_register_fw() {
	storage_reg_playerfield("dfxlink")
}

public handlesay(id) {
	new Speech[256]
	read_args(Speech,256)
	remove_quotes(Speech)

	if(containi(Speech, "/dfxlink") == 0) {
		alertmessage(id,3,"PLEASE SAY NEW DFX-LINK KEY IN CHAT NOW")
		setpass[id] = 1
		return PLUGIN_HANDLED
	}

	if(setpass[id]) {
		if(!confirming[id]) {
			if(strlen(Speech) < 4) {
				alertmessage(id,3,"YOUR NEW DFX-LINK KEY MUST CONTAIN AT LEAST 4 CHARACTERS - PLEASE TRY AGAIN")
				return PLUGIN_HANDLED
			}
			if(strlen(Speech) > 16) {
				alertmessage(id,3,"YOUR NEW DFX-LINK KEY MUST CONTAIN UNDER 16 CHARACTERS - PLEASE TRY AGAIN")
				return PLUGIN_HANDLED
			}
			if(contain(Speech, " ") != -1) {
				alertmessage(id,3,"YOUR NEW DFX-LINK KEY CANNOT CONTAIN A SPACE - PLEASE TRY AGAIN")
				return PLUGIN_HANDLED
			}
			for(new i = 0; i < strlen(Speech); i++) {
				if((Speech[i] < 'a' || Speech[i] > 'z') && (Speech[i] < 'A' || Speech[i] > 'Z') && (Speech[i] < '0' || Speech[i] > '9')) {
					alertmessage(id,3,"YOUR NEW DFX-LINK KEY CANNOT CONTAIN CHARACTERS - PLEASE TRY AGAIN")
					return PLUGIN_HANDLED
				}
			}

			copy(confirm[id], 32, Speech)
			confirming[id] = 1
			alertmessage(id,3,"PLEASE TYPE YOUR NEW DFX-LINK KEY AGAIN TO CONFIRM")
			return PLUGIN_HANDLED
		} else {
			if(!equal(Speech, confirm[id])) {
				alertmessage(id,3,"KEYS DID NOT MATCH - PLEASE TRY AGAIN")
				confirm[id] = ""
				confirming[id] = 0
				return PLUGIN_HANDLED
			} else {
				alertmessage(id,3,"DFX-LINK KEY SET! CONTINUE TO THE NEXT STEP ON team9000.net!")
				setpass[id] = 0
				confirming[id] = 0
				confirm[id] = ""

				set_playervalue(id, "dfxlink", Speech)
				storage_saveplayer(id)

				return PLUGIN_HANDLED
			}
		}
	}

	return PLUGIN_CONTINUE
}
