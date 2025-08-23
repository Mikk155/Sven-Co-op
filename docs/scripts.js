document.addEventListener( "DOMContentLoaded", () =>
{
    UpdateElementWithTemplate( "header", "templates/header.html" );
    UpdateElementWithTemplate( "footer", "templates/footer.html" );
} );

async function UpdateElementWithTemplate( tag, file )
{
    let element = document.querySelector( tag );

    if( !element )
    {
        element = document.createElement( tag );

        if( tag == "header" )
        {
            document.body[ "prepend" ](element);
        }
        else
        {
            document.body[ "append" ](element);
        }
    }

    try
    {
        const response = await fetch( file );

        if( !response.ok )
        {
            throw new Error( response.statusText );
        }

        element.innerHTML = await response.text();
    }
    catch( exception )
    {
        console.error( "Couldn't load ${file}:", exception );
    }
}
