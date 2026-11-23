
document.addEventListener("DOMContentLoaded", function () {
    const elementos = document.querySelectorAll(
        ".landing-problema, .landing-ia, .landing-feature, .landing-paso, .landing-final"
    );

    if ("IntersectionObserver" in window) {
        const observador = new IntersectionObserver(function (entradas) {
            entradas.forEach(function (entrada) {
                if (entrada.isIntersecting) {
                    entrada.target.classList.add("landing-visible");
                    observador.unobserve(entrada.target);
                }
            });
        }, { threshold: 0.12 });

        elementos.forEach(function (elemento) {
            elemento.classList.add("landing-reveal");
            observador.observe(elemento);
        });
    }
});
