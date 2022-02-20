#if defined _sub_handler_included
  #endinput
#endif
#define _sub_handler_included

#pragma reqlib sub_handler

native handle_rendering(pluginid, playerid, params[6]);
native handle_rendering_off(pluginid, playerid);

native handle_model(pluginid, playerid, model[]);
native handle_model_off(pluginid, playerid);

native handle_maxhp(pluginid, playerid, health);
native handle_maxhp_off(pluginid, playerid);

native handle_speed(pluginid, playerid, Float:param, setmult);
native handle_speed_off(pluginid, playerid);
native Float:handle_getspeed(id);

native handle_gravity(pluginid, playerid, Float:gravity);
native handle_gravity_off(pluginid, playerid);
native Float:handle_getgravity(id);

native handle_trail(pluginid, playerid, sprite, color);
native handle_trail_off(pluginid, playerid);
