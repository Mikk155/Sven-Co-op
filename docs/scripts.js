var lastTableID = '';

function toggleTable( tableID )
{
    var table = document.getElementById( tableID );

//    var lastTable = document.getElementById( lastTableID );

    if( table.classList.contains( "hidden" ) )
    {
        table.classList.remove( "hidden" );

        /*if( lastTable && lastTable !== table )
        {
            lastTable.classList.add( "hidden" );
        }*/
    }
    else
    {
        table.classList.add( "hidden" );
    }

    //lastTableID = tableID;
}
