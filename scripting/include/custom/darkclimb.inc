#if defined _darkclimb_included
  #endinput
#endif
#define _darkclimb_included

#pragma reqlib darkclimb_admin

#pragma reqlib darkclimb_checkpoints
native climb_getchecks(id);
native climb_cpstart(id);

#pragma reqlib darkclimb_features

#pragma reqlib darkclimb_globals
native climb_getpoints(id);
native climb_setpoints(id, points);
native climb_getskill(id, skill[]);
native climb_setskill(id, skill[], level);
native climb_getskillon(id, skill[]);
native climb_setskillon(id, skill[], onoff);

native climb_registerskill(name[], shortname[], cost, disqualifies=0);
native climb_get_numskills();
native climb_get_skillname(skillid, name[], len);
native climb_get_skillshort(skillid, short[], len);
native climb_get_skillcost(skillid);
native climb_get_skilldisq(skillid);
native climb_get_skillactive(skillid);
native climb_set_skillactive(skillid, active);

forward climb_register_fw();
forward climb_register_post_fw();
forward climb_change_skill(id);

#pragma reqlib darkclimb_location
native climb_setclimbing(id, action);
native climb_getclimbing(id);
// 0 = No
// 1 = Climbing
// 2 = Finished

native climb_setfeature(featureid, setting);
native climb_getfeature(featureid);
//0 = Autoheal
//1 = Godmode
//2 = Scout
//3 = Nightvision
//4 = Checkpoint Limit (-1 = OFF|0 = UNLIMITED)

native climb_clearlocations();

native climb_setarea(areaid, type, minx, miny, minz, maxx, maxy, maxz);
native climb_getarea(areaid, data[7]);

native climb_setbutton(buttonid, type, x, y, z);
native climb_getbutton(buttonid, data[4]);

#pragma reqlib darkclimb_points
native climb_updatepointshud(id);

#pragma reqlib darkclimb_records
native climb_checkrecord(id, Float:timer, checkpoints);
native climb_get_numrecords();

#pragma reqlib darkclimb_setup

#pragma reqlib darkclimb_storage
native climb_playerloaded(id);

#pragma reqlib darkclimb_timer
native climb_timerstart(id);
native climb_timerstop(id);
native climb_timerfinish(id);

#pragma reqlib darkclimb_shop

#pragma reqlib darkclimb_skills
