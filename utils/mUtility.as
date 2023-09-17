
mUtility m_Utility;

final class mUtility
{
    string StringReplace( string FullSentence, dictionary@ pArgs )
    {
        array<string> Arguments = pArgs.getKeys();

        for (uint i = 0; i < Arguments.length(); i++)
        {
            string Value = string( pArgs[ Arguments[i] ] );

            if( Value != '' && FullSentence.Find( Value ) != Math.SIZE_MAX )
            {
                FullSentence.Replace( Arguments[i], Value );
                m_Debug.Server( "[mUtility::StringReplace] Replaced string '" + Arguments[i] + "' -> '" + Value + "'");
            }
        }
        return FullSentence;
    }
}