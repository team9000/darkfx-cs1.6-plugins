#if defined _sub_respawn_included
  #endinput
#endif
#define _sub_respawn_included

#pragma reqlib sub_respawn

native respawn_auto(spawn_delay, spawn_godmode, spawn_mode);
// 1 = team bases
// 2 = near to team, far from enemy
// 3 = far from all

native respawn_auto_off();

native respawn_now(player);
native get_upperhealth();
