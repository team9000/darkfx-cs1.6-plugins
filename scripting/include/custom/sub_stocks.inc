#if defined _sub_stocks_included
  #endinput
#endif
#define _sub_stocks_included

#pragma dynamic 65536
#pragma tabsize 0

#pragma reqlib sub_stocks

#include <sub_time>
#include <permissions>

native num_apponents(id);
native num_onteam(CsTeams:team);
native alertmessage(id, color, message[]);
native adminalert(id, message[], reason[] = "", heavy = 0);
native playeralert(id, message[]);
native access(id, level);
native cmd_access(id, level, cmd, minargs = 0);
native cmd_targetset(id, arg[], flags, foundname[], len, searchid = 0);
native cmd_target(searchid = 0, dontprint = 0);
native is_running(mod[]);
native get_basedir(dir[], len);
native admin_log(message[], heavy=0);
native game_log(message[]);
native mysql_strip(input[], output[], len);
native mysql_check(failstate, Handle:query, error[], errnum, debugprint);

stock get_configsdir(name[],len)
{
	return get_localinfo("amxx_configsdir",name,len);
}

stock alertmessage_v(id, color, format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 4)
	alertmessage(id, color, message)
}

stock adminalerth_v(id, reason[], format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 4)
	adminalert(id, message, reason, 1)
}

stock adminalert_v(id, reason[], format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 4)
	adminalert(id, message, reason)
}

stock playeralert_v(id, format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 3)
	playeralert(id, message)
}

stock admin_logh_v(format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 2)
	admin_log(message, 1)
}

stock admin_log_v(format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 2)
	admin_log(message)
}

stock game_log_v(format[], {Float,_}:...) {
	new message[1024]
	vformat(message, 1023, format, 2)
	game_log(message)
}

new const sHexTable[] = "0123456789abcdef"
stock urlencode(const sString[], sResult[], len)
{
    new from, c
    new to

    while(from < len)
    {
        c = sString[from++]
        if(c == 0)
        {
            sResult[to++] = c
            break
        }
        else if(c == ' ')
        {
            sResult[to++] = '+'
        }
        else if((c < '0' && c != '-' && c != '.') ||
                (c < 'A' && c > '9') ||
                (c > 'Z' && c < 'a' && c != '_') ||
                (c > 'z'))
        {
            if((to + 3) > len)
            {
                sResult[to] = 0
                break
            }
            sResult[to++] = '%'
            sResult[to++] = sHexTable[c >> 4]
            sResult[to++] = sHexTable[c & 15]
        }
        else
        {
            sResult[to++] = c
        }
    }
}  
