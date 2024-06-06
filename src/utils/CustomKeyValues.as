const string ArrayPrefix = ";";

CustomKeyValueData ckvd;
class CustomKeyValueData
{
    EHandle hEnt;
    CBaseEntity@ entity() const { return hEnt.GetEntity(); }
    string name;
    protected string value;

    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, string szValue = String::EMPTY_STRING )
    {
        if( szKey[0] != '$' )
        {
            szKey = '$s_' + szKey;
        }

        // We only use string in here.
        if( !szKey.StartsWith( "$s_" ) )
        {
            array<string> sTypes = { "s", "f", "v", "i" };

            for( uint ui = 0; ui < sTypes.length(); ui++ )
            {
                szKey = szKey.Replace( "$" + sTypes[ui] + "_", "$s_" );
            }
        }

        hEnt = EHandle( pEntity );
        name = szKey;
        value = String::EMPTY_STRING;

        if( pEntity !is null )
        {
            if( szValue != String::EMPTY_STRING )
            {
                g_EntityFuncs.DispatchKeyValue( pEntity.edict(), szKey, szValue );
            }

            value = pEntity.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
        }

        return this;
    }

    // opConv
    string          opConv() const{ return this.value; }
    int             opConv() const{ return atoi( this.value ); }
    bool            opConv() const{ return atob( this.value ); }
    double          opConv() const{ return atod( this.value ); }
    float           opConv() const{ return atof( this.value ); }
    Vector          opConv() const{ return atov( this.value ); }
    uint            opConv() const{ return atoui( this.value ); }
    RGBA            opConv() const{ return atorgba( this.value ); }
    string_t        opConv() const{ return string_t( this.value ); }
    array<string>   opConv() const{ return this.value.Split( ArrayPrefix ); }
    Vector2D        opConv() const{ return atov( this.value ).Make2D(); }

    // zzzzz code but hey, this doesn't kill anybody and is useful

    // string
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, string szValue = String::EMPTY_STRING ) { return this[ pPlayer.edict(), szKey, szValue ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, string szValue = String::EMPTY_STRING ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, szValue ]; }

    // int
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, int szValue ) { return this[ pPlayer.edict(), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, int szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, int szValue ) { return this[ pEntity, szKey, string(szValue) ]; }

    // uint
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, uint szValue ) { return this[ pPlayer.edict(), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, uint szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, uint szValue ) { return this[ pEntity, szKey, string(szValue) ]; }

    // Vector
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, Vector szValue ) { return this[ pPlayer.edict(), szKey, szValue.ToString() ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, Vector szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, szValue.ToString() ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, Vector szValue ) { return this[ pEntity, szKey, szValue.ToString() ]; }

    // Vector2D
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, Vector2D szValue ) { return this[ pPlayer.edict(), szKey, szValue.ToString() ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, Vector2D szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, szValue.ToString() ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, Vector2D szValue ) { return this[ pEntity, szKey, szValue.ToString() ]; }

    // RGBA
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, RGBA szValue ) { return this[ pPlayer.edict(), szKey, fft::to_string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, RGBA szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, fft::to_string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, RGBA szValue ) { return this[ pEntity, szKey, fft::to_string(szValue) ]; }

    // float
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, float szValue ) { return this[ pPlayer.edict(), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, float szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, float szValue ) { return this[ pEntity, szKey, string(szValue) ]; }

    // float
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, double szValue ) { return this[ pPlayer.edict(), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, double szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, double szValue ) { return this[ pEntity, szKey, string(szValue) ]; }

    // array<string>
    protected string ArrayToString( array<string> szIn )
    {
        string szOut;
        for( uint ui = 0; ui < szIn.length(); ui++ )
        {
            szOut += ( ui == 0 ? '' : ArrayPrefix ) + szIn[ui];
        }
        g_Game.AlertMessage( at_console, szOut + "\n" );
        return szOut;
    }
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, array<string> szValue ) { return this[ pPlayer.edict(), szKey, ArrayToString(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, array<string> szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, ArrayToString(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, array<string> szValue ) { return this[ pEntity, szKey, ArrayToString(szValue) ]; }

    // bool
    CustomKeyValueData@ opIndex( CBasePlayer@ pPlayer, string szKey, bool szValue ) { return this[ pPlayer.edict(), szKey, fft::to_string(szValue) ]; }
    CustomKeyValueData@ opIndex( edict_t@ pEdict, string szKey, bool szValue ) { return this[ g_EntityFuncs.Instance( pEdict ), szKey, fft::to_string(szValue) ]; }
    CustomKeyValueData@ opIndex( CBaseEntity@ pEntity, string szKey, bool szValue ) { return this[ pEntity, szKey, fft::to_string(szValue) ]; }
}
