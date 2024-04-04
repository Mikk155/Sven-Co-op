document.addEventListener("DOMContentLoaded", function() {
    var backButton = document.createElement("button");
    backButton.innerHTML = "Back to Main Page";
    backButton.onclick = function()
    {
        window.location.href = "../index.html";
    };

    var footer = document.createElement("footer");
    footer.appendChild(backButton);
    document.body.appendChild(footer);
});
