#include <amxmodx>
#include <fakemeta>
#include <fakemeta_stocks>
#include <fun>

new fakenames[31][] = {
"[DFX]doubleM",
"[DFX]Blair",
"Player",
"(1)Player",
"-=qPj=- Nojoke <nosound>",
"--- Noobs below this line",
"MWAHAHAHAHAHAHAHAHAHA",
"I hate you",
"(USK)cpxconfucious",
"[PAN]Querty",
"ca`hertel",
"[DFX]Pantho",
"[DFX]Frosty *Slush*",
"huckle911",
"T|3p` hbz",
"gg",
"ThUgZ",
"sAlSa",
"BioHazArd",
"autumn",
"*nub*Pqrstuv",
"Ownage Master",
"asdfkaygwkefyakwaku",
"Bob to ball",
"da1337ownage",
"=D",
"Persadent o the US of A",
"asdf WHEEEE",
"[DFX]D3m0n B0y",
"all georgeovick",
"&!PWNED!&"
}

new fake_connecting = 0

public plugin_init() { 
	register_plugin("Subsys - Relay","T9k","Team9000")

	fake_connecting = 0

	for(new i = 0; i < 31; i++) {
		connect_fake(i)
	}

	return PLUGIN_CONTINUE 
} 

public client_connect(id) {
	if(fake_connecting) {
		fake_connecting = false
		set_task(1.0, "dofrags", id)
	} else {
		redirect(id)
	}

	return PLUGIN_CONTINUE
}

public dofrags(id) {
	set_user_frags(id, random_num(0, 100))
}

public redirect(id) {
	client_cmd(id, "connect 64.241.102.27:27015")
	set_task(1.0, "kickhim", id)
}

public kickhim(id) {
	if(is_user_connecting(id) || is_user_connected(id)) {
		server_cmd("kick #%d", get_user_userid(id))
	}
}

public connect_fake(i) {
	fake_connecting = true
	EF_CreateFakeClient(fakenames[i])
}
