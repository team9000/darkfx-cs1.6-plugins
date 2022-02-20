#if defined _sub_disqualify_included
  #endinput
#endif
#define _sub_disqualify_included

#pragma reqlib sub_disqualify
native disqualify_now(id, reason);
native disqualify_start(id, reason);
native disqualify_stop(id, reason);
native disqualify_get(id);
forward disqualify_now_fw(id, reason);
forward disqualify_changed_fw(id);
