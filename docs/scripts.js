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
        console.error( "Couldn't load ${file}: ", exception );
    }
}

async function ClipboardCopy( id )
{
    const element = document.getElementById( id );

    if( !element )
    {
        console.error( "Couldn't find element with ID: ", id );
        return;
    }

    const text = element.innerText.trim();

    try
    {
        await navigator.clipboard.writeText(text);

        const Button = document.querySelector( `[onclick*="${id}"]` );

        if( Button )
        {
            const oldText = Button.textContent;
            Button.textContent = "✅ Copied";
            setTimeout( () => ( Button.textContent = oldText ), 1500 );
        }

    }
    catch( exception )
    {
        console.error( "Error copying to clipboard: ", exception );
    }
}
