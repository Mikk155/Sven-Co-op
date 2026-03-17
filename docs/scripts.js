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

function delay( ms )
{
    return new Promise( resolve => setTimeout( resolve, ms ) );
}

function buildRawURL( relative )
{
    return `https://raw.githubusercontent.com/Mikk155/Sven-Co-op/main/${relative}`;
}

async function downloadAssets( button, files )
{
    try
    {
        button.textContent = "Downloading...";
        button.disabled = true;

        const zip = new JSZip();

        for( const file of files )
        {
            const url = buildRawURL( file );

            const res = await fetch( url );

            if( !res.ok )
            {
                throw new Error( "Failed to fetch " + url );
            }

            const blob = await res.blob();

            zip.file( file, blob );
        }

        const content = await zip.generateAsync( { type: "blob" } );

        const link = document.createElement( "a" );
        link.href = URL.createObjectURL( content );
        link.download = "svencoop.zip";
        link.click();
    }
    catch( err )
    {
        console.error( err );
        alert( "Download failed. Check console." );
    }

    button.textContent = "Downloaded";

    await delay(3000);

    button.textContent = "Download";
    button.disabled = false;
}
