#if defined _darkmod_included
  #endinput
#endif
#define _darkmod_included

#pragma reqlib darkmod_admin

#pragma reqlib darkmod_globals
native darkmod_setmutantmode(onoff);
native darkmod_getmutantmode();
native darkmod_setmutant(id,onoff);
native darkmod_getmutant(id);
native darkmod_setctfmode(onoff);
native darkmod_getctfmode();

native darkmod_getcrazymode();
native darkmod_setcrazymode(onoff);
native darkmod_getxp(id);
native darkmod_setxp(id, xp);
native darkmod_getlevel(id);
native darkmod_setlevel(id, level);
native darkmod_gettokens(id);
native darkmod_settokens(id, tokens);
native darkmod_gettokens2(id);
native darkmod_settokens2(id, tokens);
native darkmod_getskill(id, skill[]);
native darkmod_getactualskill(id, skill[]);
native darkmod_setskill(id, skill[], level);
native darkmod_getskill2(id, skill[]);
native darkmod_getactualskill2(id, skill[]);
native darkmod_setskill2(id, skill[], level);
native darkmod_getreloads(id);
native darkmod_setreloads(id, reloads);

native darkmod_registerskill(name[], shortname[]);
native darkmod_registerskill2(name[], shortname[]);
native darkmod_get_numskills();
native darkmod_get_skillname(skillid, name[], len);
native darkmod_get_skillshort(skillid, short[], len);
native darkmod_get_skillactive(skillid);
native darkmod_set_skillactive(skillid, active);
native darkmod_get_numskills2();
native darkmod_get_skillname2(skillid, name[], len);
native darkmod_get_skillshort2(skillid, short[], len);
native darkmod_get_skillactive2(skillid);
native darkmod_set_skillactive2(skillid, active);

forward darkfx_register_fw();
forward darkfx_register_post_fw();
forward darkfx_change_skill(id);

#pragma reqlib darkmod_setup

#pragma reqlib darkmod_shop

#pragma reqlib darkmod_storage
native darkmod_playerloaded(id);

#pragma reqlib darkmod_xp
native darkmod_updatexphud(id);
