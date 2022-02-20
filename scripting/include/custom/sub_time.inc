#if defined _sub_time_included
  #endinput
#endif
#define _sub_time_included

#pragma reqlib sub_time

// Gets current real timestamp, adjusted for errors
// GMT - NO DST
native time_time();

// Makes a timestamp based on info given
// is_dst will be automatic if set to -1
native time_mktime(hour, minute, second, month, day, year, Float:timezone, is_dst);

// Returns time in a seporated format for CURRENT time zone and dst
native time_get(timestamp, &hour, &minute, &second, &month, &day, &year, &Float:timezone, &is_dst);

// Returns the time zone that the server machine is running on
// SHOULD NOT BE USED IN MODS
native Float:time_server_zone();

// Returns if a timestamp falls in DST
native time_is_dst(timestamp);
