/*
Aww fuck
*/

mixin class CBaseInheritCustomEntity
{
    private string szThinkFunction;

    protected edict_t@ edict() const {
        return self.edict();
    }

    protected void SetThink( const string &in szFunction = String::EMPTY_STRING )
    {
        szThinkFunction = szFunction;
    }

    void Think()
    {
        g_Scheduler.SetTimeout( @this, szThinkFunction, 0.0 );
    }

    void test()
    {
        print('ThinkTest');
    }
}