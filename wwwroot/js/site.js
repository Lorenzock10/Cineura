// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

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

if (formulario) {
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

        } catch (error) {
            console.error(error);
            resultado.textContent =
                "No pudimos obtener las recomendaciones. Revisá el servidor e intentá nuevamente.";
        } finally {
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
