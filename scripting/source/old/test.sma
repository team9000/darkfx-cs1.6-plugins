#include <amxmodx>
#include <sqlx>

#define MYSQL_HOST "70.98.54.116"
#define MYSQL_USER "darkfxne_hlds"
#define MYSQL_PASS "174285396"
#define MYSQL_DB "darkfxne_hlds"

//#define MYSQL_HOST "69.91.103.164:27050"
//#define MYSQL_USER "root"
//#define MYSQL_PASS "59632147"
//#define MYSQL_DB "hlds"

new Handle:g_DbInfo

public plugin_init() {
	register_plugin("Subsys - Test","MM","doubleM")

	g_DbInfo = SQL_MakeDbTuple(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB)
	SQL_ThreadQuery(g_DbInfo, "QueryHandled", "SELECT UNIX_TIMESTAMP() as time")

	return PLUGIN_CONTINUE
}

public QueryHandled(failstate, Handle:query, error[], errnum, data[], size) {
	if(failstate) {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(g_DbInfo, "QueryHandled", queryran, data, size)
	} else {
		new queryran[4096]
		SQL_GetQueryString(query, queryran, 4095)
		SQL_ThreadQuery(g_DbInfo, "QueryHandled", queryran, data, size)

		if(SQL_NumResults(query) > 0) {
			new value[33] = ""
			new colnum = SQL_FieldNameToNum(query, "time")
			if(colnum != -1) {
				SQL_ReadResult(query, colnum, value, 32)
				client_print(0, print_console, value)
			}
		}
	}
}
