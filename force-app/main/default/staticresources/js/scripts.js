function copyrightYear() {
    const current = document.getElementById("date");
    const date = new Date();
    if (current) {
        current.innerHTML = date.getFullYear();
    }
}

window.onload = () => {
    copyrightYear();
};