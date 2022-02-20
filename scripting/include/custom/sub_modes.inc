#if defined _sub_modes_included
  #endinput
#endif
#define _sub_modes_included

#pragma reqlib sub_modes
forward mode_init();
forward mode_activate();
forward mode_activate_e();
forward mode_deactivate();
forward mode_deactivate_e();
native register_mode(chat[], admincmd[], name[], type, admin);
