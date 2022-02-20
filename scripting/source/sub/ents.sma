#include <amxmodx>
#include <sub_stocks>
#include <cstrike>
#include <engine>
#include <sub_ents>

#define MAX_CLASSES 10
#define MAX_INSTANCES 20
#define MAX_VALUES 10

new registered = 0

new removeclasslistnum
new removeclasslist[MAX_CLASSES][33]

new removenum
new removeclassname[MAX_INSTANCES][33]
new removeent[MAX_INSTANCES]
new removekeysnum[MAX_INSTANCES]
new removekeys[MAX_INSTANCES][MAX_VALUES][33]
new removevalues[MAX_INSTANCES][MAX_VALUES][33]

public plugin_init() {
	register_plugin("Subsys - Ents","T9k","Team9000")

	return PLUGIN_CONTINUE
}

public plugin_natives() {
	register_library("sub_ents")

	register_native("ent_registerremove","ent_registerremove_impl")
	register_native("ent_remove","ent_remove_impl")
	register_native("ent_restore","ent_restore_impl")
	register_native("ent_remove2","ent_remove2_impl")
	register_native("ent_restore2","ent_restore2_impl")
}

public pfn_keyvalue(entid) {
	new classname[33], keyname[33], keyvalue[33]
	copy_keyvalue(classname, 32, keyname, 32, keyvalue, 32)

	if(!registered) {
		removeclasslistnum = 0
		removenum = 0

		new funcid = 0
		for(new i = 0; i < get_pluginsnum(); i++) {
			if((funcid = get_func_id("ent_registerremove_fw", i)) != -1) {
				if(callfunc_begin_i(funcid, i) == 1) {
					callfunc_end()
				}
			}
		}

		registered = 1
	}

	new found = -1
	for(new i = 0; i < removeclasslistnum; i++) {
		if(equal(classname, removeclasslist[i])) {
			found = i
			break
		}
	}

	if(found != -1) {
		new found2 = -1
		for(new i = 0; i < removenum; i++) {
			if(entid == removeent[i]) {
				found2 = i
				break
			}
		}
		if(found2 == -1 && removenum < MAX_INSTANCES) {
			removenum++
			found2 = removenum-1
			copy(removeclassname[found2], 32, classname)
			removeent[found2] = entid
			removekeysnum[found2] = 0
		}
		if(found2 != -1) {
			new found3 = -1
			for(new i = 0; i < removekeysnum[found2]; i++) {
				if(equal(keyname, removekeys[found2][i])) {
					found3 = i
					break
				}
			}
			if(found3 == -1 && removekeysnum[found2] < MAX_VALUES) {
				removekeysnum[found2]++
				found3 = removekeysnum[found2]-1
			}
			if(found3 != -1) {
				copy(removekeys[found2][found3], 32, keyname)
				copy(removevalues[found2][found3], 32, keyvalue)
			}
		}
	}
}

public ent_registerremove_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new classname[33]
	get_string(1, classname, 32)

	new found = -1
	for(new i = 0; i < removeclasslistnum; i++) {
		if(equal(classname, removeclasslist[i])) {
			found = i
			break
		}
	}

	if(found == -1 && removeclasslistnum < MAX_CLASSES) {
		removeclasslistnum++
		found = removeclasslistnum-1
	}
	if(found != -1) {
		copy(removeclasslist[found], 32, classname)
	}

	return 1
}

public ent_remove_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new classname[33]
	get_string(1, classname, 32)

	new found = -1
	for(new i = 0; i < removeclasslistnum; i++) {
		if(equal(classname, removeclasslist[i])) {
			found = i
			break
		}
	}
	if(found == -1) {
		return 0
	}

	new ent = find_ent_by_class(-1, classname)
	new temp

	while(ent) {
		if(equal(classname, "hostage_entity") && !entity_get_int(ent, EV_INT_deadflag)) {
			message_begin(MSG_BROADCAST, get_user_msgid("HostageK"))
			write_byte(cs_get_hostage_id(ent))
			message_end()
		}
		temp = find_ent_by_class(ent, classname)
		remove_entity(ent)
		ent = temp
	}

	return 1
}

public ent_restore_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new classname[33]
	get_string(1, classname, 32)

	for(new i = 0; i < removenum; i++) {
		if(equal(classname, removeclassname[i])) {
			new ent = create_entity(classname)
			if(ent) {
				removeent[i] = ent
				for(new j = 0; j < removekeysnum[i]; j++) {
					DispatchKeyValue(ent, removekeys[i][j], removevalues[i][j])
				}
				entity_set_string(ent, EV_SZ_classname, removeclassname[i])
				DispatchSpawn(ent)
			}
		}
	}

	return 1
}

public ent_remove2_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new classname[33]
	get_string(1, classname, 32)

	new classname2[32]
	format(classname2, 31, "%s_temp", classname)

	new ent = find_ent_by_class(-1, classname)
	new temp

	while(ent) {
		temp = find_ent_by_class(ent, classname)
		DispatchKeyValue(ent, "classname", classname2)
		entity_set_string(ent, EV_SZ_classname, classname2)
		DispatchSpawn(ent)
		ent = temp
	}

	return 1
}

public ent_restore2_impl(id, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")

	new classname[33]
	get_string(1, classname, 32)

	new classname2[32]
	format(classname2, 31, "%s_temp", classname)

	new ent = find_ent_by_class(-1, classname2)
	new temp

	while(ent) {
		temp = find_ent_by_class(ent, classname2)
		DispatchKeyValue(ent, "classname", classname)
		entity_set_string(ent, EV_SZ_classname, classname)
		DispatchSpawn(ent)
		ent = temp
	}

	return 1
}
