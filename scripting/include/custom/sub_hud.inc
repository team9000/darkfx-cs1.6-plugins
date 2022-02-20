#if defined _sub_hud_included
  #endinput
#endif
#define _sub_hud_included

#pragma reqlib sub_hud

native myhud_small(mid, pid, message[], Float:time);
native myhud_large(message[], pid, Float:holdtime, channel, colorr, colorg, colorb, effects, Float:posx, Float:posy, Float:fxhold, Float:fadein, Float:fadeout);
native set_menuopen(id, onoff);
