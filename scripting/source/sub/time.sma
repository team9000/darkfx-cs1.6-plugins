#include <amxmodx>
#include <sub_stocks>
#include <sub_time>
#include <sub_storage>

#define DEFAULT_TIMEZONE -6.0
new localoffset = 0, init = 0

public plugin_precache() {
	init = 0
/*	localoffset = 0
	if(file_exists("addons/amxmodx/configs/time.cfg")) {
		new value[33], txtlen
		read_file("addons/amxmodx/configs/time.cfg", 0, value, 32, txtlen)
		localoffset = str_to_num(value)
	}*/
}

public plugin_init() {
	register_plugin("Subsys - Time","T9k","Team9000")

	init = 1

	register_cvar("amx_timezone", "-6.0")
//	register_cvar("amx_mysqltimeoffset", "0")

//	SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", "SELECT UNIX_TIMESTAMP() as time")

	return PLUGIN_CONTINUE
}
/*
public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(!mysql_check(failstate, query, "asdf", errnum, storage_get_debug())) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(storage_get_dbinfo(), "QueryHandled", queryran, data, size)
	} else {
		if(SQL_NumResults(query) > 0) {
			new value[33] = ""
			new colnum = SQL_FieldNameToNum(query, "time")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 32)
			}

			new mysqloffset = get_cvar_num("amx_mysqltimeoffset")

			new mysqltime = str_to_num(value)
			new storedtime = get_systime()
			new newtime = mysqltime-storedtime+mysqloffset
			format(value, 32, "%d", newtime)

			write_file("addons/amxmodx/configs/time.cfg", value, 0)
		}
	}
}
*/
public plugin_natives() {
	register_library("sub_time")

	register_native("time_time","time_time_impl")
	register_native("time_mktime","time_mktime_impl")
	register_native("time_get","time_get_impl")
	register_native("time_server_zone","time_server_zone_impl")
	register_native("time_is_dst","time_is_dst_impl")
}

public time_time_impl(id, numparams) {
	if(numparams != 0)
		return log_error(10, "Bad native parameters")

	new time = get_systime()
	time += localoffset

	return time
}

public time_mktime_impl(id, numparams) {
	if(numparams != 8)
		return log_error(10, "Bad native parameters")

	new hour = get_param(1)
	new minute = get_param(2)
	new second = get_param(3)
	new month = get_param(4)
	new day = get_param(5)
	new year = get_param(6)
	new Float:usetimezone = get_param_f(7)
	new is_dst = get_param(8)

	new time[64]

	format(time, 63, "%d %d %d %d %d %d", month, day, year, hour, minute, second)
	new result = parse_time(time, "%m %d %Y %H %M %S")

	new Float:timezonediff = usetimezone - time_server_zone()
	result -= floatround(timezonediff*60.0*60.0)

	if(is_dst == 0 && time_is_dst(result)) {
		result += 60*60
	} else if(is_dst == 1 && !time_is_dst(result)) {
		result -= 60*60
	}

/*		new dst_start, dst_stop
		if(year >= 2007) {
			format(time, 63, "%d/%d/%d %d:%d:%d", 3, 14-(1+floatround(year*(5.0/4.0), floatround_floor)%7), year, 2, 0, 0)
			dst_start = parse_time(time, "%m/%d/%Y %H:%M:%S")
			format(time, 63, "%d/%d/%d %d:%d:%d", 11, 7-(1+floatround(year*(5.0/4.0), floatround_floor)%7), year, 2, 0, 0)
			dst_stop = parse_time(time, "%m/%d/%Y %H:%M:%S")
		} else {
			format(time, 63, "%d/%d/%d %d:%d:%d", 4, ((2+6*year-floatround(year/4.0, floatround_floor))%7)+1, year, 2, 0, 0)
			dst_start = parse_time(time, "%m/%d/%Y %H:%M:%S")
			format(time, 63, "%d/%d/%d %d:%d:%d", 10, 31-(floatround(year*(5.0/4.0), floatround_floor)+1)%7, year, 2, 0, 0)
			dst_stop = parse_time(time, "%m/%d/%Y %H:%M:%S")
		}

		if(result > dst_start && result < dst_stop) {
			is_dst = 1
		}*/

	return result
}

public time_get_impl(id, numparams) {
	if(numparams != 9)
		return log_error(10, "Bad native parameters")

	new timestamp = get_param(1)

	new Float:timezone
	if(init) {
		timezone = get_cvar_float("amx_timezone")
	} else {
		timezone = DEFAULT_TIMEZONE
	}

	new Float:timezonediff = timezone - time_server_zone()
	timestamp += floatround(timezonediff*60.0*60.0)

	new time[64]
	format_time(time, 63, "%m %d %Y %H %M %S", timestamp)

	new month_s[6], day_s[6], year_s[6], hour_s[6], minute_s[6], second_s[6]
	parse(time, month_s, 5, day_s, 5, year_s, 5, hour_s, 5, minute_s, 5, second_s, 5)
	new month = str_to_num(month_s)
	new day = str_to_num(day_s)
	new year = str_to_num(year_s)
	new hour = str_to_num(hour_s)
	new minute = str_to_num(minute_s)
	new second = str_to_num(second_s)

	set_param_byref(2, hour)
	set_param_byref(3, minute)
	set_param_byref(4, second)
	set_param_byref(5, month)
	set_param_byref(6, day)
	set_param_byref(7, year)
	set_float_byref(8, timezone)
	set_param_byref(9, time_is_dst(timestamp))

	return 1
}

public Float:time_server_zone_impl(id, numparams) {
	if(numparams != 0)
		return float(log_error(10, "Bad native parameters"))

	new zonecode_s[64]
	format_time(zonecode_s, 63, "%z")

	new zonecode = str_to_num(zonecode_s)
	new Float:zone = float(zonecode / 100)
	zone += (zonecode % 100)*(5.0/3.0)

	if(time_is_dst(time_time())) {
		zone -= 1.0
	}

	return zone
}

public time_is_dst_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new timestamp = get_param(1)

	new time[64]
	format_time(time, 63, "%m %d %Y %H %M %S", timestamp)

	new month_s[6], day_s[6], year_s[6], hour_s[6], minute_s[6], second_s[6]
	parse(time, month_s, 5, day_s, 5, year_s, 5, hour_s, 5, minute_s, 5, second_s, 5)
	new month = str_to_num(month_s)
//	new day = str_to_num(day_s)
//	new year = str_to_num(year_s)
	new hour = str_to_num(hour_s)
//	new minute = str_to_num(minute_s)
//	new second = str_to_num(second_s)

	timestamp = timestamp - month*30*24*60*60 // Get timestamp to same time of day in january

	format_time(time, 63, "%m %d %Y %H %M %S", timestamp)
	parse(time, month_s, 5, day_s, 5, year_s, 5, hour_s, 5, minute_s, 5, second_s, 5)
//	new month2 = str_to_num(month_s)
//	new day2 = str_to_num(day_s)
//	new year2 = str_to_num(year_s)
	new hour2 = str_to_num(hour_s)
//	new minute2 = str_to_num(minute_s)
//	new second2 = str_to_num(second_s)

	if(hour != hour2) {
		return 1
	}

	return 0
}
