#include <amxmodx>
#include <sub_stocks>
#include <engine>
#include <sub_damage>
#include <effect_semiclip>
#include < fakemeta >
#include < hamsandwich >

#define IsPlayer(%1) ( 1 <= %1 <= g_iMaxPlayers )
new const g_szAliveFlags[ ] = "a";
new g_iPlayers[ 32 ], g_iNum, g_iPlayer, g_iMaxPlayers, i;

//new onoff

public plugin_init() {
	register_plugin("Effect - Semiclip","T9k","Team9000")
//	onoff = 1

    register_forward( FM_ShouldCollide, "FwdShouldCollide" );
    register_forward( FM_AddToFullPack, "FwdAddToFullPack", true );
    
    RegisterHam( Ham_Player_PreThink, "player", "FwdHamPlayerPreThink", true );
    RegisterHam( Ham_Killed,          "player", "FwdHamPlayerKilled",   true );
    
    g_iMaxPlayers = get_maxplayers( );
}

public plugin_natives() {
	register_library("effect_semiclip")
	register_native("set_semiclip", "set_semiclip_impl")
}

public set_semiclip_impl(pid, numparams) {
	if(numparams != 1)
		return log_error(10, "Bad native parameters")
//	onoff = get_param(1)

	return 1
}

public FwdAddToFullPack( es, e, iEnt, id, hostflags, player, pSet )
{
    if( player && id != iEnt && get_orig_retval( ) )
    {
        set_es( es, ES_Solid, SOLID_NOT );
        
        static Float:flDistance;
        flDistance = entity_range( id, iEnt );
		static Float:fadeDistance = 256.0;
        
        if( flDistance <= fadeDistance )
        {
            set_es( es, ES_RenderMode, kRenderTransAlpha )
            set_es( es, ES_RenderAmt, floatround( flDistance / fadeDistance * 256.0 ) );
        }
    }
}

public FwdShouldCollide( const iTouched, const iOther )
{/*
    if( IsPlayer( iTouched ) && IsPlayer( iOther ) )
    {
        forward_return( FMV_CELL, 0 );
        return FMRES_SUPERCEDE;
    }
*/
    return FMRES_IGNORED;
}

public FwdHamPlayerKilled( )
{
    get_players( g_iPlayers, g_iNum, g_szAliveFlags );
    
    for( i = 0; i < g_iNum; i++ )
    {
        entity_set_int( g_iPlayers[ i ], EV_INT_solid, SOLID_SLIDEBOX );
    }
}

public FwdHamPlayerPreThink( const id )
    Semiclip( id, SOLID_NOT );

public client_PostThink( id )
    Semiclip( id, SOLID_SLIDEBOX );

Semiclip( const id, const iSolid )
{
    if( !is_user_alive( id ) )
        return;
    
    get_players( g_iPlayers, g_iNum, g_szAliveFlags );
    
    for( i = 0; i < g_iNum; i++ )
    {
        g_iPlayer = g_iPlayers[ i ];
        
        if( id != g_iPlayer )
            entity_set_int( g_iPlayer, EV_INT_solid, iSolid );
    }
}
