document.addEventListener("DOMContentLoaded", function() {
    var backButton = document.createElement("button");
    backButton.innerHTML = "Back to Main Page";
    backButton.onclick = function() {
        window.location.href = "/docs/index.html"; // Cambia "/docs/index.html" a la ruta absoluta correcta de tu página principal
    };

    var footer = document.createElement("footer");
    footer.appendChild(backButton);
    document.body.appendChild(footer);
});
