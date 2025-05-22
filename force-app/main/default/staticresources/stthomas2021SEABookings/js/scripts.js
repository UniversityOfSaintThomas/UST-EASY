function copyrightYear() {
    const current = document.getElementById("date");
    const date = new Date();
    if (current) {
        current.innerHTML = date.getFullYear();
    }
}

//onload of dom
document.addEventListener("DOMContentLoaded", function () {
    //get links with id that ends with submitOptions
    const submitOptions = document.querySelectorAll("a[id$='submitOptions'], a[id$='submitReg1'], a[id$='submitReg2']");;
    //Change the value in the link from Register to Submit
    submitOptions.forEach((element) => {
        element.innerHTML = "Submit";
    });

    copyrightYear();
});