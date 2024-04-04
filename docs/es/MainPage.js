document.addEventListener("DOMContentLoaded", function() {
    var backButton = document.createElement("button");
    backButton.innerHTML = "Volver a la Pagina Principal";
    backButton.onclick = function() {
        window.location.href = "/docs/index.html"; // Cambia "/docs/index.html" a la ruta absoluta correcta de tu página principal
    };

    var footer = document.createElement("footer");
    footer.appendChild(backButton);
    document.body.appendChild(footer);
});
