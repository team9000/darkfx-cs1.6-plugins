#if defined _settings_included
  #endinput
#endif
#define _settings_included

#define TE_BEAMPOINTS 0
#define TE_BEAMENTPOINT 1
#define TE_KILLBEAM 99
#define DELTA_T 0.1		// seconds
#define BEAMLIFE 100		// deciseconds
#define MOVEACCELERATION 150	// units per second^2
#define REELSPEED 100		// units per second

#define MYSQL_HOST "mysql4.opentransfer.com"
#define MYSQL_USER "doubleM_servers"
#define MYSQL_PASS "174285396"
#define MYSQL_DB "doubleM_servers"

/* XP Earning Definitions */

#if defined DFX_NEEDEARNINGNAME
new earningName[][] = {
	"Killed an Enemy",
	"Planted the Bomb",
	"Diffused the Bomb",
	"Bombed the Target",
	"Won the Round",
	"Touched a Hostage",
	"Rescued a Hostage",
	"Escaped as the VIP",
	"Assassinated the VIP"
}
#endif

#if defined DFX_NEEDEARNINGXP
new earningXP[] = {
	500,
	300,
	1000,
	700,
	100,
	50,
	200,
	800,
	800
}
#endif

#define FIRST_LEVEL 400
#define LEVEL_MULTIPLIER 1.5

/* Skill Definitions */

#define SKILLS_PER_PAGE 7

#define MAX_SKILL_LEVEL 5

#if defined DFX_NEEDSKILLMINLEVEL
new skillsMinLevel[] = {
	0,
	1,
	4,
	10,
	20
}
#endif

#define MAX_SKILL2_LEVEL 1

/*
new skillsName2[][] = {
	"Ultra Stealth",
	"Ammo Upgrade"
}
new skillsName[][] = {
	"Hook Upgrade",
	"Invisibility",
	"Knife/Speed Upgrade",
	"Max HP Upgrade",
	"Low Gravity",
	"HP Regeneration",
	"Critical Damage",
	"Napalm Granades",
	"Equipment Recovery"
}
*/
