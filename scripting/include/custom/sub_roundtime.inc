#if defined _sub_roundtime_included
  #endinput
#endif
#define _sub_roundtime_included

#pragma reqlib sub_roundtime

native round_mode();
forward round_freezestart_e(); //early
forward round_freezestart();
forward round_roundstart();
forward round_roundend();
forward round_gamerestart();
