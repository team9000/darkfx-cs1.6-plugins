#if defined _sub_weapons_included
  #endinput
#endif
#define _sub_weapons_included

#pragma reqlib sub_weapons

// TARGET
// -1 = TERRORIST
// -2 = CT
// 0 = ALL
// id = PLAYER

native weap_reload(plugin,target,reload[32],weapdefault);
native weap_reload_off(plugin,target);
native weap_force(plugin,target,forcerules[32],forcereload[32],weapdefault);
native weap_force_off(plugin,target);

// STATUS
// -1 = DEFAULT
// 0 = OFF
// 1 = ON

native weap_allowbuy(plugin,target,status);
native weap_allowpickup_ground(plugin,target,status);
native weap_allowpickup_drop(plugin,target,status);
native weap_allowdrop(plugin,target,status);
native weap_hideground(plugin,status);
native weap_removedrop(plugin,status);
native weap_blockfirein(plugin,status);
native weap_forcedefault(target);
