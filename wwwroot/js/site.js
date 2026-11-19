
// ============================================
// NOVA - BUSCADOR DE RECOMENDACIONES CON IA
// ============================================

let ultimaBusqueda = "";
let ultimaLista = [];
let indiceActual = 0;

const formulario = document.getElementById("formBusqueda");
const campoBusqueda = document.getElementById("busqueda");
const resultado = document.getElementById("resultado");
const recomendacion = document.getElementById("recomendacion");
const botonBuscar = document.getElementById("botonBuscar");

function agregarTexto(texto) {

    if (campoBusqueda && campoBusqueda.value.trim() === "") {
        campoBusqueda.value = texto;
    } else if (campoBusqueda) {
        campoBusqueda.value += ", " + texto;
    }

    if (campoBusqueda) {
        campoBusqueda.focus();
    }
}

if (formulario && campoBusqueda && resultado && recomendacion && botonBuscar) {

    formulario.addEventListener("submit", async function (e) {

        e.preventDefault();

        ultimaBusqueda = campoBusqueda.value.trim();

        if (!ultimaBusqueda) {
            resultado.textContent = "Escribí qué tipo de película querés ver.";
            return;
        }

        resultado.textContent = "✦ Buscando recomendaciones...";
        recomendacion.style.display = "none";
        botonBuscar.disabled = true;

        try {

            const respuesta = await fetch('/Home/BuscarPeliculas', {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: new URLSearchParams({
                    busqueda: ultimaBusqueda
                })
            });

            if (!respuesta.ok) {
                throw new Error("Error del servidor: " + respuesta.status);
            }

            const data = await respuesta.json();

            if (!data || (Array.isArray(data) && data.length === 0)) {
                resultado.textContent =
                    "No encontramos películas para esa búsqueda. Probá con otra descripción.";
                return;
            }

            ultimaLista = Array.isArray(data) ? data : [data];
            indiceActual = 0;

            mostrarPelicula(ultimaLista[indiceActual]);

            resultado.textContent =
                "✦ Encontramos " + ultimaLista.length +
                (ultimaLista.length === 1
                    ? " película para vos."
                    : " películas para vos.");

            recomendacion.style.display = "block";

            recomendacion.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });

        }
        catch (error) {

            console.error(error);

            resultado.textContent =
                "No pudimos obtener las recomendaciones. Revisá el servidor e intentá nuevamente.";

        }
        finally {
            botonBuscar.disabled = false;
        }

    });
}

function mostrarPelicula(p) {

    if (!p) return;

    document.getElementById("tituloPelicula").textContent =
        p.titulo || "Sin título";

    document.getElementById("descripcionPelicula").textContent =
        p.sinopsis || "No hay una sinopsis disponible.";

    document.getElementById("datosPelicula").textContent =
        p.duracionMinutos ? p.duracionMinutos + " min" : "Información no disponible";

    const etiquetas = document.getElementById("etiquetasPelicula");

    etiquetas.replaceChildren();

    [p.genero, p.animo].filter(Boolean).forEach(function (texto) {

        const etiqueta = document.createElement("span");

        etiqueta.className = "cineura-etiqueta";
        etiqueta.textContent = texto;

        etiquetas.appendChild(etiqueta);

    });

    document.getElementById("motivoPelicula").textContent =
        'Esta película coincide con tu búsqueda: "' + ultimaBusqueda + '".';

    const zonaPoster = document.getElementById("zonaPoster");

    zonaPoster.replaceChildren();

    if (p.posterUrl) {

        const imagen = document.createElement("img");

        imagen.src = p.posterUrl;
        imagen.alt = p.titulo || "Póster";
        imagen.className = "cineura-poster";

        imagen.onerror = function () {
            mostrarPosterVacio(p.titulo);
        };

        zonaPoster.appendChild(imagen);

    } else {

        mostrarPosterVacio(p.titulo);

    }

    document.getElementById("botonDetalles").onclick = function () {

        if (!p.idPelicula) {
            alert("No se encontró el ID de esta película en la base de datos.");
            return;
        }

        window.location.href =
            "/Home/Detalles?id=" + encodeURIComponent(p.idPelicula);

    };
}

function mostrarPosterVacio(titulo) {

    const zonaPoster = document.getElementById("zonaPoster");

    zonaPoster.replaceChildren();

    const espacio = document.createElement("div");
    espacio.className = "cineura-poster-vacio";

    const texto = document.createElement("span");
    texto.textContent = titulo || "✦ CINEURA";

    espacio.appendChild(texto);
    zonaPoster.appendChild(espacio);

}

// Botón para ver otra recomendación.

const botonOtra = document.getElementById("botonOtra");

if (botonOtra) {

    botonOtra.addEventListener("click", function () {

        if (ultimaLista.length <= 1) {

            resultado.textContent =
                "No hay otra película para esta búsqueda. Probá con otra descripción.";

            return;
        }

        indiceActual = (indiceActual + 1) % ultimaLista.length;

        mostrarPelicula(ultimaLista[indiceActual]);

        resultado.textContent =
            "Recomendación " + (indiceActual + 1) +
            " de " + ultimaLista.length;

    });
}

window.agregarTexto = agregarTexto;


// ============================================
// CALIFICACIONES Y REVIEWS
// ============================================

document.addEventListener("DOMContentLoaded", function () {

    // CALIFICACIÓN CON ESTRELLAS

    const calificacion = document.querySelector(".cine-calificacion");

    if (calificacion) {

        const estrellas = calificacion.querySelectorAll(".cine-estrella");
        const formularioPuntuacion = document.getElementById("form-puntuacion");
        const puntuacion = document.getElementById("puntuacion-seleccionada");
        const textos = calificacion.querySelectorAll(".cine-calificacion-texto");

        if (formularioPuntuacion && puntuacion) {

            function actualizarEstrellas(valor) {

                estrellas.forEach(function (estrella) {

                    const numero = Number(estrella.dataset.valor);

                    if (numero <= valor) {
                        estrella.classList.add("activa");
                    } else {
                        estrella.classList.remove("activa");
                    }

                    if (numero === valor) {
                        estrella.setAttribute("aria-pressed", "true");
                    } else {
                        estrella.setAttribute("aria-pressed", "false");
                    }

                });
            }

            const inicial = Number(puntuacion.value);

            actualizarEstrellas(inicial);

            if (inicial > 0 && textos.length > 0) {
                textos[0].textContent = "Tu puntuación: " + inicial + " de 5";
            }

            estrellas.forEach(function (estrella) {

                estrella.addEventListener("click", function () {

                    const valor = Number(estrella.dataset.valor);

                    puntuacion.value = valor;

                    actualizarEstrellas(valor);

                   formularioPuntuacion.requestSubmit();

                });

            });

        }
    }


    // LEER MÁS / LEER MENOS EN REVIEWS

    const botonesLeerMas = document.querySelectorAll(".cine-review-leer-mas");

    botonesLeerMas.forEach(function (boton) {

        boton.addEventListener("click", function () {

            const texto = boton.previousElementSibling;

            texto.classList.toggle("expandido");

            if (texto.classList.contains("expandido")) {
                boton.textContent = "Leer menos";
            } else {
                boton.textContent = "Leer más";
            }

        });

    });

});


// ============================================
// EXPLORADOR - FILTROS CON FETCH
// ============================================

document.addEventListener("DOMContentLoaded", function () {

    const formularioExplorador =
        document.querySelector(".explorador-buscador");

    if (!formularioExplorador) return;

    async function aplicarFiltros() {

        const datos = new FormData(formularioExplorador);
        const parametros = new URLSearchParams(datos);

        try {

            const respuesta = await fetch(
                formularioExplorador.action + "?" + parametros.toString(),
                {
                    method: "GET",
                    headers: {
                        "X-Requested-With": "XMLHttpRequest"
                    }
                }
            );

            if (!respuesta.ok) {
                throw new Error("Error del servidor: " + respuesta.status);
            }

            const tipoContenido = respuesta.headers.get("content-type");

            if (tipoContenido && tipoContenido.includes("application/json")) {

                const resultadoFetch = await respuesta.json();

                if (resultadoFetch.redirectUrl) {
                    window.location.href = resultadoFetch.redirectUrl;
                }

                return;
            }

            const html = await respuesta.text();

            const contenedorResultados =
                document.getElementById("peliculas");

            if (contenedorResultados) {
                contenedorResultados.outerHTML = html;
            }

        }
        catch (error) {

            console.error("Error al aplicar filtros:", error);

        }
    }

    // Buscar al enviar el formulario.

    formularioExplorador.addEventListener("submit", function (e) {

        e.preventDefault();

        aplicarFiltros();

    });

    // Aplicar filtros automáticamente.

    ["genero", "anio", "duracionMaxima", "ordenar"].forEach(function (id) {

        const campo = document.getElementById(id);

        if (campo) {
            campo.addEventListener("change", aplicarFiltros);
        }

    });

    // Limpiar filtros.

    const botonLimpiar =
        document.querySelector(".explorador-limpiar");

    if (botonLimpiar) {

        botonLimpiar.addEventListener("click", function (e) {

            e.preventDefault();

            formularioExplorador.reset();

            aplicarFiltros();

        });

    }

});

// ============================================
// FAVORITOS, WATCHLIST Y PUNTUACIONES CON FETCH
// ============================================

document.addEventListener("DOMContentLoaded", function () {

    // Enviar formularios sin recargar la página.
    async function enviarFormularioFetch(formulario) {

        const boton = formulario.querySelector("button[type='submit']");

        if (!boton) return;

        const accionOriginal = formulario.action;
        const textoOriginal = boton.innerHTML;

        boton.disabled = true;

        try {

            const datos = new FormData(formulario);

            const respuesta = await fetch(formulario.action, {
                method: "POST",
                body: datos,
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            });

            // Si el servidor redirige al login, ir al login.
            if (respuesta.redirected &&
                respuesta.url.toLowerCase().includes("/login")) {

                window.location.href = respuesta.url;
                return;
            }

            if (!respuesta.ok) {
                throw new Error("Error al guardar: " + respuesta.status);
            }

            // ==================================
            // PUNTUACIONES
            // ==================================

            if (formulario.id === "form-puntuacion") {

                const puntuacion = Number(
                    formulario.querySelector("#puntuacion-seleccionada").value
                );

                const estrellas = formulario.querySelectorAll(".cine-estrella");

                estrellas.forEach(function (estrella) {

                    const valor = Number(estrella.dataset.valor);

                    estrella.classList.toggle("activa", valor <= puntuacion);

                });

                const texto = document.querySelector(
                    ".cine-calificacion-texto"
                );

                if (texto) {
                    texto.textContent = "Tu puntuación: " + puntuacion + " de 5";
                }

            }

            // ==================================
            // FAVORITOS
            // ==================================

            else if (accionOriginal.includes("AgregarFavorito")) {

                const nuevaAccion = new URL(accionOriginal);
                nuevaAccion.pathname = nuevaAccion.pathname.replace(
                    "AgregarFavorito",
                    "QuitarFavorito"
                );

                formulario.action = nuevaAccion.toString();

                boton.className = "cine-boton cine-boton-favorito-activo";
                boton.innerHTML = '<span aria-hidden="true">♥</span> En Favoritas';

            }

            else if (accionOriginal.includes("QuitarFavorito")) {

                const nuevaAccion = new URL(accionOriginal);
                nuevaAccion.pathname = nuevaAccion.pathname.replace(
                    "QuitarFavorito",
                    "AgregarFavorito"
                );

                formulario.action = nuevaAccion.toString();

                boton.className = "cine-boton cine-boton-principal";
                boton.innerHTML = '<span aria-hidden="true">♥</span> Agregar a Favoritas';

            }

            // ==================================
            // WATCHLIST
            // ==================================

            else if (accionOriginal.includes("AgregarWatchlist")) {

                const nuevaAccion = new URL(accionOriginal);
                nuevaAccion.pathname = nuevaAccion.pathname.replace(
                    "AgregarWatchlist",
                    "QuitarWatchlist"
                );

                formulario.action = nuevaAccion.toString();

                boton.className = "cine-boton cine-boton-secundario";
                boton.innerHTML = '<span aria-hidden="true">✓</span> En Watchlist';

            }

            else if (accionOriginal.includes("QuitarWatchlist")) {

                const nuevaAccion = new URL(accionOriginal);
                nuevaAccion.pathname = nuevaAccion.pathname.replace(
                    "QuitarWatchlist",
                    "AgregarWatchlist"
                );

                formulario.action = nuevaAccion.toString();

                boton.className = "cine-boton cine-boton-secundario";
                boton.innerHTML = '<span aria-hidden="true">＋</span> Agregar a Watchlist';

            }

        }
        catch (error) {

            console.error("Error en la operación:", error);

            alert("No se pudo guardar el cambio. Intentá nuevamente.");

            boton.innerHTML = textoOriginal;

        }
        finally {

            boton.disabled = false;

        }
    }


    // Interceptar únicamente los formularios indicados.

    const formularios = document.querySelectorAll(
        "#form-puntuacion, .cine-formulario-accion"
    );

    formularios.forEach(function (formulario) {

        formulario.addEventListener("submit", function (e) {

            e.preventDefault();

            enviarFormularioFetch(formulario);

        });

    });

});

document.addEventListener("DOMContentLoaded", function () {

    const formulario = document.getElementById("formCuestionario");

    // Solo ejecutar en la página del cuestionario
    if (formulario === null) {
        return;
    }

    let pasoActual = 0;

    const preguntas = document.querySelectorAll(".cine-pregunta");
    const progreso = document.querySelectorAll(".cine-cuestionario-progreso span");

    const titulo = document.getElementById("tituloPregunta");
    const subtitulo = document.getElementById("subtituloPregunta");
    const botonContinuar = document.getElementById("botonContinuar");
    const botonVolver = document.getElementById("botonVolver");
    const errorPregunta = document.getElementById("errorPregunta");

    const titulos = [
        "¡Empecemos por tus gustos!",
        "Busquemos tu tipo de historia",
        "Una más para conocerte",
        "¿Qué querés sentir hoy?",
        "Descubrí algo diferente"
    ];

    const subtitulos = [
        "Personalizá tu experiencia en Cineura.",
        "Queremos descubrir qué te atrapa de una película.",
        "Así podemos recomendarte algo para cada momento.",
        "A veces elegimos una película por cómo queremos sentirnos.",
        "Queremos saber qué lugar le das a las películas menos conocidas."
    ];

    function mostrarPregunta() {

        for (let i = 0; i < preguntas.length; i++) {
            preguntas[i].classList.toggle("activa", i === pasoActual);
            progreso[i].classList.toggle("activo", i <= pasoActual);
        }

        titulo.textContent = titulos[pasoActual];
        subtitulo.textContent = subtitulos[pasoActual];

        botonVolver.style.visibility =
            pasoActual === 0 ? "hidden" : "visible";

        botonContinuar.textContent =
            pasoActual === 4 ? "Finalizar" : "Continuar";

        errorPregunta.textContent = "";
    }

    botonContinuar.addEventListener("click", function () {

        const pregunta = preguntas[pasoActual];
        const seleccionadas = pregunta.querySelectorAll("input:checked");

        if (seleccionadas.length === 0) {
            errorPregunta.textContent = "Seleccioná al menos una opción.";
            return;
        }

        if (pasoActual < preguntas.length - 1) {
            pasoActual++;
            mostrarPregunta();
        }
        else {
            botonContinuar.disabled = true;
            formulario.submit();
        }
    });

    botonVolver.addEventListener("click", function () {

        if (pasoActual > 0) {
            pasoActual--;
            mostrarPregunta();
        }
    });

    mostrarPregunta();
});
