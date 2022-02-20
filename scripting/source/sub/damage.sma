#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fun>
#include <sub_damage>
#include <sub_roundtime>
#include <sub_respawn>

new killing = 0
new bool:lastalive[33]

new bool:semigodmode[33]
new bool:blanks[33]
new bool:autoheal[33]

public plugin_init() {
	register_plugin("Subsys - Damage","T9k","Team9000")

	register_event("Damage","damage","b","2!0")
	register_event("DeathMsg","death","a")

	killing = 0

	for(new i = 0; i < 33; i++) {
		lastalive[i] = false
		semigodmode[i] = false
		blanks[i] = false
	}

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_damage")

	register_native("dam_dealdamage","dam_dealdamage_impl")
	register_native("dam_fakedeath","dam_fakedeath_impl")
	register_native("dam_fakedeath_postmove","dam_fakedeath_postmove_impl")

	register_native("dam_set_semigodmode","dam_set_semigodmode_impl")
	register_native("dam_get_semigodmode","dam_get_semigodmode_impl")
	register_native("dam_set_blanks","dam_set_blanks_impl")
	register_native("dam_get_blanks","dam_get_blanks_impl")
	register_native("dam_set_autoheal","dam_set_autoheal_impl")
	register_native("dam_get_autoheal","dam_get_autoheal_impl")
}

public client_connect(id) {
	lastalive[id] = false
	semigodmode[id] = false
	blanks[id] = false
	autoheal[id] = false
}

public client_PreThink(id) {
	if(!lastalive[id] && is_user_alive(id)) {
		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_respawn", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(id)
					callfunc_end()
				}
			}
		}
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_respawn_postmove", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(id)
					callfunc_end()
				}
			}
		}
	}

	lastalive[id] = (is_user_alive(id) != 0)
}

public dam_dealdamage_impl(id, numparams) {
	if(numparams != 9)
		return log_error(10, "Bad native parameters")

	new victim = get_param(1)
	if(victim && is_user_connected(victim)) {
		new attacker = get_param(2)
		new damage = get_param(3)
		new weapon[33]
		get_string(4, weapon, 32)
		new headshot = get_param(5)
		new ignoregod = get_param(6)
		new origin[3]
		origin[0] = get_param(7)
		origin[1] = get_param(8)
		origin[2] = get_param(9)

		replace_all(weapon, 31, "weapon_", "")
		replace_all(weapon, 31, "hegrenade", "grenade")

		if(contain(weapon, "grenade") != -1) {
			headshot = 0
		}

		if(attacker < 1 || attacker > 32 || !is_user_connected(attacker) || !is_user_alive(attacker)) {
			attacker = victim
		}

		if(checkattack(victim, attacker)) {
			return 0
		}

		if(is_user_alive(victim) && (!get_user_godmode(victim) || ignoregod)) {
			new oldgodmode = get_user_godmode(victim)
			if(oldgodmode && ignoregod) {
				set_user_godmode(victim, 0)
			}

			killing = 1
			set_msg_block(get_user_msgid("Damage"), BLOCK_SET)
			set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
			set_msg_block(get_user_msgid("ScoreInfo"), BLOCK_SET)
			fakedamage(victim, weapon, float(damage), DMG_GENERIC)
			set_msg_block(get_user_msgid("Damage"), BLOCK_NOT)
			set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
			set_msg_block(get_user_msgid("ScoreInfo"), BLOCK_NOT)
			killing = 0

			new funcid = 0
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("dam_damage", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(victim)
						callfunc_push_int(attacker)
						callfunc_push_str(weapon)
						callfunc_push_int(headshot)
						callfunc_push_int(damage)
						callfunc_push_int(1)
						callfunc_end()
					}
				}
			}

			if(!is_user_alive(victim)) {
				message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"), {0,0,0}, 0)
				write_byte(attacker)
				write_byte(victim)
				write_byte(headshot)
				write_string(weapon)
				message_end()

				new funcid = 0
				for(new i = 0; i < get_pluginsnum(); i++) {
					if((funcid = get_func_id("dam_death", i)) != -1) {
						if(callfunc_begin_i(funcid, i) == 1) {
							callfunc_push_int(victim)
							callfunc_push_int(attacker)
							callfunc_push_str(weapon)
							callfunc_push_int(headshot)
							callfunc_end()
						}
					}
				}

				new namea[32], authida[32], teama[32], namev[32], authidv[32], teamv[32]
				get_user_name(attacker, namea, 31)
				get_user_authid(attacker, authida, 31)
				get_user_team(attacker, teama, 31)
				get_user_name(victim, namev, 31)
				get_user_authid(victim, authidv, 31)
				get_user_team(victim, teamv, 31)
				if(attacker == victim) {
					log_message("^"%s<%d><%s><%s>^" committed suicide", namea, get_user_userid(attacker), authida, teama)
				} else {
					if(get_user_team(attacker) != get_user_team(victim)) {
						set_user_frags(attacker, get_user_frags(attacker)+1)
						cs_set_user_money(attacker, min(cs_get_user_money(attacker)+300, 16000))

						message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
						write_byte(attacker)
						write_short(get_user_frags(attacker))
						write_short(cs_get_user_deaths(attacker))
						write_short(0)
						write_short(get_user_team(attacker))
						message_end()
					} else {
						set_user_frags(attacker, get_user_frags(attacker)-1)
						cs_set_user_deaths(victim, cs_get_user_deaths(victim)-1)

						message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
						write_byte(attacker)
						write_short(get_user_frags(attacker))
						write_short(cs_get_user_deaths(attacker))
						write_short(0)
						write_short(get_user_team(attacker))
						message_end()

						message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
						write_byte(victim)
						write_short(get_user_frags(victim))
						write_short(cs_get_user_deaths(victim))
						write_short(0)
						write_short(get_user_team(victim))
						message_end()
					}
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", namea, get_user_userid(attacker), authida, teama, namev, get_user_userid(victim), authidv, teamv, weapon)
				}
				return 1
			} else {
				if(autoheal[victim]) {
					if(get_upperhealth()) {
						set_user_health(victim,100+256000) 
					} else {
						set_user_health(victim,100) 
					}
				}

				set_user_godmode(victim, oldgodmode)
			}
		}
	}
	return 0
}

public dam_set_semigodmode_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	semigodmode[get_param(1)] = (get_param(2) != 0)
	return get_param(2)
}

public dam_get_semigodmode_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return semigodmode[get_param(1)]
}

public dam_set_blanks_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	blanks[get_param(1)] = (get_param(2) != 0)
	return get_param(2)
}

public dam_get_blanks_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return blanks[get_param(1)]
}

public dam_set_autoheal_impl(id, numparams) {
	if(numparams != 2)
		return log_error(10, "Bad native parameters")

	autoheal[get_param(1)] = (get_param(2) != 0)
	return get_param(2)
}

public dam_get_autoheal_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	return autoheal[get_param(1)]
}

public dam_fakedeath_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")

	new victim = get_param(1)
	if(victim && is_user_connected(victim)) {
		new attacker = get_param(2)
		new weapon[33]
		get_string(3, weapon, 32)
		new headshot = get_param(4)

		if(attacker < 1 || attacker > 32 || !is_user_connected(attacker) || !is_user_alive(attacker)) {
			attacker = victim
		}

		message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
		write_byte(attacker)
		write_byte(victim)
		write_byte(headshot)
		write_string(weapon)
		message_end()

		// DeathMsg marks them as dead? why? remove it
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
		write_byte(victim)
		write_byte(0)
		message_end()

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_death", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(victim)
					callfunc_push_int(attacker)
					callfunc_push_str(weapon)
					callfunc_push_int(headshot)
					callfunc_end()
				}
			}
		}

		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_respawn", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(victim)
					callfunc_end()
				}
			}
		}

		new namea[32], authida[32], teama[32], namev[32], authidv[32], teamv[32]
		get_user_name(attacker, namea, 31)
		get_user_authid(attacker, authida, 31)
		get_user_team(attacker, teama, 31)
		get_user_name(victim, namev, 31)
		get_user_authid(victim, authidv, 31)
		get_user_team(victim, teamv, 31)
		if(attacker == victim) {
			log_message("^"%s<%d><%s><%s>^" committed suicide", namea, get_user_userid(attacker), authida, teama)
		} else {
			if(get_user_team(attacker) != get_user_team(victim)) {
				set_user_frags(attacker, get_user_frags(attacker)+1)
				cs_set_user_deaths(victim, cs_get_user_deaths(victim)+1)
				cs_set_user_money(attacker, min(cs_get_user_money(attacker)+300, 16000))

				message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
				write_byte(attacker)
				write_short(get_user_frags(attacker))
				write_short(cs_get_user_deaths(attacker))
				write_short(0)
				write_short(get_user_team(attacker))
				message_end()

				message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
				write_byte(victim)
				write_short(get_user_frags(victim))
				write_short(cs_get_user_deaths(victim))
				write_short(0)
				write_short(get_user_team(victim))
				message_end()
			} else {
				set_user_frags(attacker, get_user_frags(attacker)-1)

				message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
				write_byte(attacker)
				write_short(get_user_frags(attacker))
				write_short(cs_get_user_deaths(attacker))
				write_short(0)
				write_short(get_user_team(attacker))
				message_end()
			}
			log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", namea, get_user_userid(attacker), authida, teama, namev, get_user_userid(victim), authidv, teamv, weapon)
		}
	}

	return 1
}

public dam_fakedeath_postmove_impl(id, numparams) {
	if(numparams != 4)
		return log_error(10, "Bad native parameters")

	new victim = get_param(1)
	if(victim && is_user_connected(victim)) {
//		new attacker = get_param(2)
//		new weapon[33]
//		get_string(3, weapon, 32)
//		new headshot = get_param(4)

//		if(attacker < 1 || attacker > 32 || !is_user_connected(attacker) || !is_user_alive(attacker)) {
//			attacker = victim
//		}

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_respawn_postmove", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(victim)
					callfunc_end()
				}
			}
		}
	}

	return 1
}

public damage(victim) {
	if(victim && !killing && is_user_connected(victim)) {
		new weaponid, bhit, attacker
		attacker = get_user_attacker(victim, weaponid, bhit)
		new headshot = (bhit == 1 ? 1 : 0)
		new weapon[33]
		if(weaponid) {
			get_weaponname(weaponid, weapon, 32)
		} else {
			format(weapon, 32, "")
		}
		new damage = read_data(2)

		if(attacker < 1 || attacker > 32 || !is_user_connected(attacker) || !is_user_alive(attacker)) {
			attacker = victim
		}

		replace_all(weapon, 31, "weapon_", "")
		replace_all(weapon, 31, "hegrenade", "grenade")

		if(contain(weapon, "grenade") != -1) {
			headshot = 0
		}

		if(checkattack(victim, attacker)) {
			set_user_health(victim, get_user_health(victim)+damage)
			return
		}

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_damage", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(victim)
					callfunc_push_int(attacker)
					callfunc_push_str(weapon)
					callfunc_push_int(headshot)
					callfunc_push_int(damage)
					callfunc_push_int(0)
					callfunc_end()
				}
			}
		}

		if(is_user_alive(victim)) {
			if(autoheal[victim]) {
				if(get_upperhealth()) {
					set_user_health(victim,100+256000) 
				} else {
					set_user_health(victim,100) 
				}
			}
		}
	}
}

public checkattack(victim, attacker) {
	if(attacker == victim) {
		return 0
	}
	if(blanks[attacker]) {
		alertmessage_v(attacker,3,"You have Godmode/Blanks enabled! You cannot attack other players!")
		return 1
	}
	if(semigodmode[victim]) {
		alertmessage_v(attacker,3,"The person you are attacking has on Godmode/Blanks in /skills! You cannot hurt them!")
		return 1
	}
	return 0
}

public death() {
	new victim = read_data(2)
	if(victim && !killing && is_user_connected(victim)) {
		new attacker = read_data(1)
		new headshot = read_data(3)
		new weapon[33]
		read_data(4, weapon, 32)

		if(attacker < 1 || attacker > 32 || !is_user_connected(attacker) || !is_user_alive(attacker)) {
			attacker = victim
		}

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("dam_death", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_push_int(victim)
					callfunc_push_int(attacker)
					callfunc_push_str(weapon)
					callfunc_push_int(headshot)
					callfunc_end()
				}
			}
		}
	}
}

public round_gamerestart() {
	new targetindex, targetname[33]
	if(cmd_targetset(-1, "*", 4, targetname, 32)) {
		while((targetindex = cmd_target())) {
			new funcid
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("dam_respawn", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(targetindex)
						callfunc_end()
					}
				}
			}
			for(new i = 0; i < get_pluginsnum(); i++) {
				if((funcid = get_func_id("dam_respawn_postmove", i)) != -1) {
					if(callfunc_begin_i(funcid, i) == 1) {
						callfunc_push_int(targetindex)
						callfunc_end()
					}
				}
			}
		}
	}
}
