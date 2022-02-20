#if defined _sub_votes_included
  #endinput
#endif
#define _sub_votes_included

#pragma reqlib sub_votes
// showmode
// 0 = dont show ANY results
// 1 = show after voted
// 2 = show after and during vote
native vote_new(callback[], duration, title[], showmode);
native vote_addoption(option[]);
native vote_addoption_hud(option[], option_hud[]);
native vote_setvotecallback(callback[]);