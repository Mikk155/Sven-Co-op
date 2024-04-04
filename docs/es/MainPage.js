document.addEventListener("DOMContentLoaded", function() {
    var backButton = document.createElement("button");
    backButton.innerHTML = "Volver a la Pagina Principal";
    backButton.onclick = function()
    {
        window.location.href = "../index.html";
    };

    var footer = document.createElement("footer");
    footer.appendChild(backButton);
    document.body.appendChild(footer);
});
