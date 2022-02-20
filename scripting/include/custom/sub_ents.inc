#if defined _sub_ents_included
  #endinput
#endif
#define _sub_ents_included

#pragma reqlib sub_ents

native ent_registerremove(classname[]);
native ent_remove(classname[]);
native ent_restore(classname[]);
native ent_remove2(classname[]);
native ent_restore2(classname[]);
forward ent_registerremove_fw();
