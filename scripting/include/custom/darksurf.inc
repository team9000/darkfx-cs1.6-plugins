#if defined _darksurf_included
  #endinput
#endif
#define _darksurf_included

#pragma reqlib darksurf_respawn

#pragma reqlib darksurf_finish
native surf_set_finish(Float:pos[3]);
native surf_get_finish(Float:pos[3]);
forward surf_finished(id);
native surf_get_finishon();

#pragma reqlib darksurf_admin

#pragma reqlib darksurf_globals
native surf_getpoints(id);
native surf_setpoints(id, points);
native surf_getskill(id, skill[]);
native surf_setskill(id, skill[], level);
native surf_getskillon(id, skill[]);
native surf_setskillon(id, skill[], onoff);

native surf_registerskill(name[], shortname[], cost, disqualifies=0);
native surf_get_numskills();
native surf_get_skillname(skillid, name[], len);
native surf_get_skillshort(skillid, short[], len);
native surf_get_skillcost(skillid);
native surf_get_skilldisq(skillid);
native surf_get_skillactive(skillid);
native surf_set_skillactive(skillid, active);

forward surf_register_fw();
forward surf_register_post_fw();
forward surf_change_skill(id);

#pragma reqlib darksurf_shop

#pragma reqlib darksurf_storage
native surf_playerloaded(id);

#pragma reqlib darksurf_points
native surf_updatepointshud(id);

#pragma reqlib darksurf_setup

#pragma reqlib darksurf_skills

#pragma reqlib darksurf_surfing

#pragma reqlib darksurf_mapworth
native surf_mapworth_add(Float:time);
native surf_mapworth_get();

//#pragma reqlib darksurf_records
// 1 = Time
// 2 = Hangtime
// 3 = Speed
// 4 = Distance
// 5 = Height

//higher
//1 = higher is better
//2 = lower is better
native surf_checkrecord(id, Float:amount, record, higher);
native surf_get_numrecords(record);
