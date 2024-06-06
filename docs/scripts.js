// Display the given element
function OpenElement( id )
{
    var vElement = document.getElementById( id );

    if( vElement )
    {
        vElement.style.display = "block";
    }
}

// Hidde the given element
function CloseElement( id )
{
    var vElement = document.getElementById( id );

    if( vElement )
    {
        vElement.style.display = "none";
    }
}

// Languages. made by GPT, feel free to point out what's wrong
document.addEventListener( 'DOMContentLoaded', (event) =>
{
    let translations = {};

    fetch( 'translations.json' )
        .then(response => response.json())
        .then(data => {
            translations = data;
            const userLang = navigator.language || navigator.userLanguage;
            const defaultLang = translations[userLang] ? userLang : 'english';
            applyTranslations(defaultLang);
            reemplazarPalabrasConEnlaces();
            document.getElementById('languageDropdown').value = defaultLang;
        })
        .catch(error => console.error('Error al cargar las traducciones:', error));

    function applyTranslations(language) {
        document.querySelectorAll("[pkvd]").forEach(element => {
            const key = element.getAttribute("pkvd");
            element.innerText = translations[language][key];
        });
    }

    // -TODO This function should be called every time applyTranslations is called.
    // Tried calling this within it but bad things happened
    function reemplazarPalabrasConEnlaces() {
        fetch('ExternalLinks.json')
            .then(response => response.json())
            .then(data => {
                let bodyElement = document.body;
                let bodyHTML = bodyElement.innerHTML;

                for (let palabra in data) {
                    let enlace = data[palabra];
                    let regex = new RegExp(`#${palabra}\\b`, 'g');
                    bodyHTML = bodyHTML.replace(regex, `<a href="${enlace}" target="_blank">${palabra}</a>`);
                }

                bodyElement.innerHTML = bodyHTML;
            })
            .catch(error => console.error('Error al cargar el JSON:', error));
    }

    window.changeLanguage = function(event) {
        const selectedLanguage = event.target.value;
        applyTranslations(selectedLanguage);
    };

    window.openElement = function(id) {
        document.getElementById(id).style.display = "block";
    };

    window.closeElement = function(id) {
        document.getElementById(id).style.display = "none";
    };

    window.onclick = function(event) {
        if (event.target.classList.contains("emergent-window")) {
            event.target.style.display = "none";
        }
    };
});
