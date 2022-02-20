#if defined _sub_damage_included
  #endinput
#endif
#define _sub_damage_included

#pragma reqlib sub_damage

native dam_dealdamage(victim, attacker, damage, weapon[], headshot, ignoregod, originx, originy, originz);
native dam_fakedeath(victim, attacker, weapon[], headshot);
native dam_fakedeath_postmove(victim, attacker, weapon[], headshot);

native dam_set_autoheal(id, onoff);
native dam_get_autoheal(id);
native dam_set_semigodmode(id, onoff);
native dam_get_semigodmode(id);
native dam_set_blanks(id, onoff);
native dam_get_blanks(id);

forward dam_death(victim, attacker, weapon[], headshot);
forward dam_damage(victim, attacker, weapon[], headshot, damage, private);
forward dam_respawn(id);
forward dam_respawn_postmove(id);