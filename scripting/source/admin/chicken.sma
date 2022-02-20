#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <sub_damage>
#include <sub_handler>
#include <sub_disqualify>
#include <sub_lowresources>

new bool:ischicken[33]
new bool:playsound[33]
new feather
new Float:cView[3] = {0.0, 0.0, 0.0}
new Float:nView[3] = {0.0, 0.0, 17.0}

public plugin_init() {
	register_plugin("Admin Chicken", "T9k", "Team9000")

	register_event("CurWeapon", "get_weapon", "b")

	register_concmd("amx_chicken", "admin_chicken", LVL_CHICKEN, "<authid, nick, #userid, @team or *>")
	register_concmd("amx_unchicken", "admin_unchicken", LVL_CHICKEN, "<authid, nick, #userid, @team or *>")

	register_forward(FM_EmitSound, "emitsound")
	register_forward(FM_TraceLine, "forward_traceline", 1)
}

public plugin_precache() {
	if(!is_lowresources()) {
		// Models
		precache_model("models/player/team9000chicken/team9000chicken.mdl")
		feather = precache_model("models/team9000/feather.mdl")
		// Sounds
		precache_sound("team9000/chicken/chicken0.wav")
		precache_sound("team9000/chicken/chicken1.wav")
		precache_sound("team9000/chicken/chicken2.wav")
		precache_sound("team9000/chicken/chicken3.wav")
		precache_sound("team9000/chicken/chicken4.wav")
		precache_sound("misc/cow.wav")
		precache_sound("misc/killChicken.wav")
		precache_sound("weapons/knife_hit1.wav")
		precache_sound("weapons/knife_hit3.wav")
	}
}

public admin_chicken(id, level, cid) {
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	if(is_lowresources()) {
		client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
		return PLUGIN_HANDLED
	}

	new target[32]
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			chicken_user(targetindex)
		}

		client_cmd(0, "speak sound/misc/chicken0")

		adminalert_v(id, "", "chickenized %s", targetname)
	}

	return PLUGIN_HANDLED
}

public admin_unchicken(id, level, cid) {
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	if(is_lowresources()) {
		client_print(id, print_console, "Sorry, this map is set to low-resource mode!")
		return PLUGIN_HANDLED
	}

	new target[32]
	read_argv(1,target,31)

	new targetindex, targetname[33]
	if(cmd_targetset(id, target, 3, targetname, 32)) {
		while((targetindex = cmd_target())) {
			unchicken_user(targetindex)
		}

		client_cmd(targetindex, "speak sound/misc/cow")

		adminalert_v(id, "", "unchickenized %s", targetname)
	}

	return PLUGIN_HANDLED
}

public chicken_user(id) {
	if(!ischicken[id]) {
		disqualify_start(id, 0)
		ischicken[id] = true

		new origin[3]
		get_user_origin(id, origin)
		transform(origin)

		set_task(5.0, "blankweapon", id+100, "", 0, "b")

		new params[6]
		params[0] = kRenderFxGlowShell
		params[1] = cs_get_user_team(id) == CS_TEAM_T ? 250 : 0
		params[2] = 0
		params[3] = cs_get_user_team(id) == CS_TEAM_CT ? 250 : 0
		params[4] = kRenderTransAlpha
		params[5] = 255
		handle_rendering(3, id, params)

		handle_speed(1, id, 650.0, 0)
		handle_gravity(1, id, 0.3)
		handle_model(0, id, "team9000chicken")

		engclient_cmd(id, "weapon_knife")
		entity_set_string(id, EV_SZ_viewmodel, "")
		entity_set_string(id, EV_SZ_weaponmodel, "")
	}
	return PLUGIN_HANDLED
}

public client_disconnect(id) {
	if(ischicken[id]) {
		ischicken[id] = false

		remove_task(id+100)

		handle_rendering_off(3, id)
		handle_speed_off(1, id)
		handle_gravity_off(1, id)
		handle_model_off(0, id)
		entity_set_vector(id, EV_VEC_view_ofs, nView)
	}
}

public unchicken_user(id) {
	if(ischicken[id]) {
		disqualify_stop(id, 0)

		ischicken[id] = false

		new origin[3]
		get_user_origin(id, origin)
		transform(origin)

		handle_rendering_off(3, id)
		handle_speed_off(1, id)
		handle_gravity_off(1, id)
		handle_model_off(0, id)
		entity_set_vector(id, EV_VEC_view_ofs, nView)

		engclient_cmd(id, "weapon_knife")
		entity_set_string(id, EV_SZ_viewmodel, "models/v_knife.mdl")
		entity_set_string(id, EV_SZ_weaponmodel, "models/p_knife.mdl")

		remove_task(id+100)
	}
	return PLUGIN_HANDLED
}

public dam_respawn(id) {
	if(ischicken[id]) {
		new params[6]
		params[0] = kRenderFxGlowShell
		params[1] = cs_get_user_team(id) == CS_TEAM_T ? 250 : 0
		params[2] = 0
		params[3] = cs_get_user_team(id) == CS_TEAM_CT ? 250 : 0
		params[4] = kRenderTransAlpha
		params[5] = 255
		handle_rendering(3, id, params)
	}
}

public get_weapon(id) {
	if(ischicken[id]) {
		new ammo, clip, wid
		wid = get_user_weapon(id, clip, ammo)
		if(wid != CSW_KNIFE) {
			engclient_cmd(id, "weapon_knife")
			entity_set_string(id, EV_SZ_viewmodel, "")
			entity_set_string(id, EV_SZ_weaponmodel, "")
		}
	}
}

public blankweapon(id) {
	new targetindex = id - 100
	if(ischicken[targetindex]) {
		engclient_cmd(targetindex, "weapon_knife")
		entity_set_string(targetindex, EV_SZ_viewmodel, "")
		entity_set_string(targetindex, EV_SZ_weaponmodel, "")
	}
}

public dam_damage(victim, attacker, weapon[], headshot, damage, private) {
	if(ischicken[victim]) {
		new orig[3]
		get_user_origin(victim, orig)
		create_gibs(victim, orig, 5, 10, 5)
	}
}

public dam_death(victim, attacker, weapon[], headshot) {
	if(ischicken[victim]) {
		new params[6]
		params[0] = kRenderFxNone
		params[1] = 0
		params[2] = 0
		params[3] = 0
		params[4] = kRenderTransAdd
		params[5] = 0
		handle_rendering(3, victim, params)

		new orig[3]
		get_user_origin(victim, orig)
		create_gibs(victim, orig, 5, 30, 30)
	}
}

public client_PreThink(id) {
	if(id && is_user_connected(id)) {
		if(ischicken[id] && is_user_alive(id)) {
			new Float:pView[3]
			entity_get_vector(id, EV_VEC_view_ofs, pView)

			if(pView[2] != cView[2]) {
				entity_set_vector(id, EV_VEC_view_ofs, cView)
			}
		}
	}
}

public emitsound(entity, channel, const sample[]) {
	if(entity > 32 || entity < 1)
		return FMRES_IGNORED

	if(ischicken[entity]) {
		if(contain(sample, "weapons/knife") == 0) {
			if(sample[14] == 'd') {
				return FMRES_SUPERCEDE
			}
			switch(sample[15]) {
				case 'l': { //slash
					if(!playsound[entity]) {
						new iPitch = random_num(100, 120)
						switch(random_num(0, 3)) {
							case 0: emit_sound(entity, CHAN_VOICE, "misc/chicken1.wav", 1.0, ATTN_NORM, 0, iPitch)
							case 1: emit_sound(entity, CHAN_VOICE, "misc/chicken2.wav", 1.0, ATTN_NORM, 0, iPitch)
							case 2: emit_sound(entity, CHAN_VOICE, "misc/chicken3.wav", 1.0, ATTN_NORM, 0, iPitch)
							case 3: emit_sound(entity, CHAN_VOICE, "misc/chicken4.wav", 1.0, ATTN_NORM, 0, iPitch)
						}
						playsound[entity] = true
						set_task(0.8, "reset_sound", entity)
					}
					return FMRES_SUPERCEDE
				}
				case 't': { //stab
					emit_sound(entity, CHAN_WEAPON, "weapons/knife_hit3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
			}
			switch(sample[17]) {
				case '2': {
					emit_sound(entity, CHAN_WEAPON, "weapons/knife_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				case '4': {
					emit_sound(entity, CHAN_WEAPON, "weapons/knife_hit3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				case 'w': {
					return FMRES_SUPERCEDE
				}
			}
		} else if(contain(sample, "player/bhit") == 0) {
			new orig[3]
			get_user_origin(entity, orig)
			create_gibs(entity, orig, 5, 10, 5)
			return FMRES_SUPERCEDE
		} else if(contain(sample, "player/d") == 0) {
			emit_sound(entity, CHAN_VOICE, "misc/killChicken.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public reset_sound(id) {
	playsound[id] = false
}

public create_gibs(id, vec[3], velocity, random, amount) {
	// gibs
	new Float:size[3]
	entity_get_vector(id, EV_VEC_size, size)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec)
	write_byte(108) // TE_BREAKMODEL
	// position
	write_coord(vec[0])
	write_coord(vec[1])
	write_coord(vec[2])
	// size
	write_coord(floatround(size[0]))
	write_coord(floatround(size[1]))
	write_coord(floatround(size[2]))
	// velocity
	write_coord(0)
	write_coord(0)
	write_coord(velocity) //10
	// randomization
	write_byte(random) //30
	// Model
	write_short(feather)	//model id#
	// # of shards
	write_byte(amount) //30
	// duration
	write_byte(300);// 15.0 seconds
	// flags
	write_byte(0x04) // BREAK_FLESH
	message_end()
}

public forward_traceline(Float:v1[3], Float:v2[3], noMonsters, pentToSkip) {
	new entity1 = pentToSkip
	new entity2 = get_tr(TR_pHit) // victim
	new hitzone = (1<<get_tr(TR_iHitgroup))

	if(!is_valid_ent(entity1) || !is_valid_ent(entity2)) {
		return FMRES_IGNORED
	}
	if(entity1 != entity2 && is_user_alive(entity1) && is_user_alive(entity2)) {
    		if(ischicken[entity2]) {
			if(hitzone != 64 && hitzone != 128) {
				set_tr(TR_flFraction,1.0)
				return FMRES_SUPERCEDE
			}
		}
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}

public transform(vec[3]) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec)
	write_byte(11) // TE_TELEPORT
	write_coord(vec[0])
	write_coord(vec[1])
	write_coord(vec[2])
	message_end()
}
