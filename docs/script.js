const LinkedWords =
{
        // Users
        "Zode": "https://github.com/Zode",
        "hzqst": "https://github.com/hzqst",
        "Rick": "https://github.com/RedSprend",
        "Wootguy": "https://github.com/wootguy",
        "Giegue": "https://github.com/JulianR0",
        "Cubemath": "https://github.com/CubeMath",
        "Kezaeiv": "https://github.com/KEZAEIV3255",
        "Kerncore": "https://github.com/KernCore91",
        "Gaftherman": "https://github.com/Gaftherman",

        // Extern links
        "Discord": "https://discord.gg/THDKrgBEny",
        "metamod": "https://github.com/Mikk155/metamod-limitless-potential",
        "snippets": "https://github.com/Mikk155/Sven-Co-op/blob/main/.vscode/shared.code-snippets",
};

// Change languages
function changeLanguage( language )
{
        const translations = jsonData[ language ];

        for( let key in translations )
        {
            if( translations.hasOwnProperty( key ) )
            {
                const titleElement = document.getElementById( key );

                let translatedText = translations[key];
                titleElement.innerText = translations[ key ];

                const regex = new RegExp("\\b(" + Object.keys( LinkedWords ).join("|") + ")\\b", "gi");

                translatedText = translatedText.replace( regex, function( match )
                {
                        return `<a href="${LinkedWords[ match ]}" class="custom-link">${match}</a>`;
                } );

                const regex2 = /#(\w+)/g;
                translatedText = translatedText.replace(regex2, function (match, p1) {
                    const translation = jsonData[language][p1];
                        return `<a href="#${p1}" class="own-link">${p1}</a>`;
                });

                titleElement.innerHTML = translatedText;
            }
        }
}

// Sandwitch
function sandwitchButtonClick( element )
{
        if( element == null )
        {
                element = document.getElementById( "side-menu-button" );
        }

        var menu_bar = document.getElementById("side-menu");
        menu_bar.classList.toggle("open");

        var elements = document.getElementById("side-menu-elements");
        elements.classList.toggle("show");
}