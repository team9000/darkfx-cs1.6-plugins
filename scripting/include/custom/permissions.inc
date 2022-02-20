#if defined _permissions_included
  #endinput
#endif
#define _permissions_included

#define LEVEL_1		(1<<0)	/* flag "a" */
#define LEVEL_2		(1<<1)	/* flag "b" */
#define LEVEL_3		(1<<2)	/* flag "c" */
#define LEVEL_4		(1<<3)	/* flag "d" */
#define LEVEL_5		(1<<4)	/* flag "e" */
#define LEVEL_6		(1<<5)	/* flag "f" */
#define LEVEL_7		(1<<6)	/* flag "g" */
#define LEVEL_8		(1<<7)	/* flag "h" */
#define LEVEL_9		(1<<8)	/* flag "i" */
#define LEVEL_10	(1<<9)	/* flag "j" */
#define LEVEL_11	(1<<10)	/* flag "k" */
#define LEVEL_12	(1<<11)	/* flag "l" */
#define LEVEL_13	(1<<12)	/* flag "m" */
#define LEVEL_14	(1<<13)	/* flag "n" */
#define LEVEL_15	(1<<14)	/* flag "o" */
#define LEVEL_16	(1<<15)	/* flag "p" */
#define LEVEL_17	(1<<16)	/* flag "q" */
#define LEVEL_18	(1<<17)	/* flag "r" */
#define LEVEL_19	(1<<18)	/* flag "s" */
#define LEVEL_20	(1<<19)	/* flag "t" */
#define LEVEL_21	(1<<20)	/* flag "u" */
#define LEVEL_22	(1<<24)	/* flag "v" */
#define LEVEL_23	(1<<25)	/* flag "w" */
#define LEVEL_24	(1<<24)	/* flag "x" */
#define LEVEL_25	(1<<24)	/* flag "y" */
#define LEVEL_26	(1<<25)	/* flag "z" */

#define LVL_LOWIMMUNITY		LEVEL_1
#define LVL_RESERVATION		LEVEL_1
#define LVL_ADMINSAY		LEVEL_1
#define LVL_ADMINSAY_LISTEN	LEVEL_1
#define LVL_TELEPORTATION	LEVEL_1
#define LVL_GLOWTRAIL		LEVEL_1
#define LVL_WHO			LEVEL_1

#define LVL_VOTE		LEVEL_2
#define LVL_VOTEMAP		LEVEL_9
#define LVL_ALLSAY		LEVEL_2
#define LVL_PSAY		LEVEL_2
#define LVL_TSAY		LEVEL_2
#define LVL_CSAY		LEVEL_2
#define LVL_HUDCOLOR		LEVEL_2
#define LVL_MAP			LEVEL_2
#define LVL_MAPNOW		LEVEL_9
#define LVL_KICK		LEVEL_2
#define LVL_SLAY		LEVEL_2
#define LVL_SLAP		LEVEL_2
#define LVL_DISARM		LEVEL_2
#define LVL_TEAM		LEVEL_2
#define LVL_TIMELEFT		LEVEL_2
#define LVL_FIRE		LEVEL_2
#define LVL_UBERSLAP		LEVEL_2
#define LVL_ROCKET		LEVEL_2
#define LVL_ARMOR		LEVEL_2
#define LVL_HEALTH		LEVEL_2
#define LVL_GODMODE		LEVEL_2
#define LVL_NOCLIP		LEVEL_2
#define LVL_MONEY		LEVEL_2
#define LVL_FLASH		LEVEL_2
#define LVL_CHICKEN		LEVEL_2

#define LVL_QUIT		LEVEL_3
#define LVL_GAG			LEVEL_3
#define LVL_UNGAG		LEVEL_3
#define LVL_MUTE		LEVEL_3
#define LVL_UNMUTE		LEVEL_3
#define LVL_BAN			LEVEL_3
#define LVL_LLAMA		LEVEL_3
#define LVL_MODEL		LEVEL_3
#define LVL_ADMINMODEL		LEVEL_3

#define LVL_ANTICONSOLE		LEVEL_9
#define LVL_ADMINHELP		LEVEL_9
#define LVL_RESTART		LEVEL_9
#define LVL_RR			LEVEL_9
#define LVL_WARN		LEVEL_9
#define LVL_ALLTALK		LEVEL_9
#define LVL_SPEAK		LEVEL_9
#define LVL_KAMIKAZE		LEVEL_9
#define LVL_GLOW		LEVEL_9
#define LVL_TRAIL		LEVEL_9
#define LVL_TELEPORT		LEVEL_9
#define LVL_FORCEGUN		LEVEL_9
#define LVL_RESPAWN		LEVEL_9
#define LVL_STACK		LEVEL_9
#define LVL_CLEXEC		LEVEL_9
#define LVL_GIVE		LEVEL_9
#define LVL_HIGHIMMUNITY	LEVEL_9
#define LVL_LOWIMMUNITY_OVERRIDE	LEVEL_9
#define LVL_LIGHT		LEVEL_9
#define LVL_GRAVITY		LEVEL_9
#define LVL_CVAR		LEVEL_9
#define LVL_CFG			LEVEL_9
#define LVL_RCON		LEVEL_9
#define LVL_HUDNOW		LEVEL_9
#define LVL_BANID		LEVEL_9
#define LVL_UNBAN		LEVEL_9
#define LVL_DARKMOD		LEVEL_9
#define LVL_DARKSURF		LEVEL_9
#define LVL_DARKCLIMB		LEVEL_9
#define LVL_SETUP		LEVEL_9
#define LVL_CHATROOM		LEVEL_9
#define LVL_CLANMATCH		LEVEL_9
#define LVL_GRENADEMODE		LEVEL_9
#define LVL_RESPAWNMODE		LEVEL_9
#define LVL_GOLDENGUNMODE	LEVEL_9
#define LVL_ROCKETMODE		LEVEL_9
#define LVL_KNIFEMODE		LEVEL_9
#define LVL_MUTANTMODE		LEVEL_9
#define LVL_CTFMODE		LEVEL_9
#define LVL_CRAZYMODE		LEVEL_9
#define LVL_BHOPMODE		LEVEL_9
