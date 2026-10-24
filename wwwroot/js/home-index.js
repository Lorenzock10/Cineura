function cerrarDetallesCineura(id) {
    var modal = document.getElementById("detalle-cineura-" + id);

    if (modal) {
        modal.style.display = "none";
    }
}

document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape") {
        document.querySelectorAll(".modal-cineura").forEach(function (modal) {
            modal.style.display = "none";
        });
    }
});

function agregarTexto(texto) {
    const campo = document.getElementById("busqueda");

    if (campo.value.trim() !== "") {
        campo.value += ", " + texto;
    } else {
        campo.value = texto;
    }

    campo.focus();
}

document.getElementById("formBusqueda").addEventListener("submit", async function (e) {
    e.preventDefault();

    const campo = document.getElementById("busqueda");
    const boton = document.getElementById("botonBuscar");
    const mensaje = document.getElementById("resultado");
    const contenedor = document.getElementById("resultadosBusqueda");

    mensaje.textContent = "Nova está buscando películas para vos...";
    contenedor.innerHTML = "";
    boton.disabled = true;

    try {
        const datos = new FormData();
        datos.append("busqueda", campo.value);

        const respuesta = await fetch("/Home/BuscarPeliculas", {
            method: "POST",
            body: datos
        });

        if (!respuesta.ok) {
            const error = await respuesta.text();
            throw new Error(error || "No se pudo realizar la búsqueda.");
        }

        const peliculas = await respuesta.json();

        if (!peliculas.length) {
            mensaje.textContent = "No encontramos películas con esos filtros. Probá describirlo de otra manera.";
            return;
        }

        mensaje.textContent = "Encontramos estas películas para vos:";

        peliculas.forEach(function (pelicula) {
            const columna = document.createElement("div");
            columna.className = "col";

            const tarjeta = document.createElement("div");
            tarjeta.className = "card-pelicula h-100";
            tarjeta.dataset.id = pelicula.idPelicula;
            tarjeta.dataset.titulo = pelicula.titulo || "Sin título";

            tarjeta.addEventListener("click", function (event) {
                if (event.target.closest("button")) {
                    return;
                }
                if (pelicula.idPelicula) {
                    window.location.href = "/Home/Detalles/" + pelicula.idPelicula;
                }
            });

            if (pelicula.posterUrl) {
                const imagen = document.createElement("img");
                imagen.src = pelicula.posterUrl;
                imagen.alt = "Póster de " + pelicula.titulo;
                imagen.className = "card-poster-img";
                imagen.loading = "lazy";
                tarjeta.appendChild(imagen);
            }

            const info = document.createElement("div");
            info.className = "card-info";

            const titulo = document.createElement("h4");
            titulo.className = "card-titulo";
            titulo.textContent = pelicula.titulo || "Sin título";

            const meta = document.createElement("p");
            meta.className = "card-meta";
            meta.textContent =
                (pelicula.anio || "") + " • " +
                (pelicula.duracionMinutos || "?") + " minutos";

            const genero = document.createElement("p");
            genero.textContent = pelicula.genero || "";

            const sinopsis = document.createElement("p");
            sinopsis.className = "card-sinopsis";
            sinopsis.textContent = pelicula.sinopsis || "Sin sinopsis disponible.";

            info.appendChild(titulo);
            info.appendChild(meta);
            info.appendChild(genero);
            info.appendChild(sinopsis);
            tarjeta.appendChild(info);
            columna.appendChild(tarjeta);
            contenedor.appendChild(columna);
        });
    } catch (error) {
        mensaje.textContent = error.message || "Ocurrió un error al buscar películas.";
    } finally {
        boton.disabled = false;
    }
});

function configurarAccionesCineura() {
    document.querySelectorAll("[data-busqueda]").forEach(function (boton) {
        boton.addEventListener("click", function () {
            agregarTexto(boton.dataset.busqueda);
        });
    });

    document.querySelectorAll("[data-modal-id]").forEach(function (modal) {
        modal.addEventListener("click", function (evento) {
            if (evento.target === modal) {
                cerrarDetallesCineura(modal.dataset.modalId);
            }
        });
    });

    document.querySelectorAll("[data-cerrar-modal]").forEach(function (boton) {
        boton.addEventListener("click", function () {
            cerrarDetallesCineura(boton.dataset.cerrarModal);
        });
    });

    document.querySelectorAll(".card-pelicula").forEach(function (card) {
        card.addEventListener("click", function (event) {
            if (event.target.closest("button")) {
                return;
            }

            const id = card.dataset.id || "";

            if (id) {
                window.location.href = "/Home/Detalles/" + id;
            }
        });
    });

    document.querySelectorAll(".favorite-toggle").forEach(function (boton) {
        boton.addEventListener("click", async function (event) {
            event.stopPropagation();
            const id = boton.dataset.id;
            const activo = boton.dataset.active === "true";

            try {
                const respuesta = await fetch("/Home/ToggleFavorito", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
                    body: "idPelicula=" + encodeURIComponent(id)
                });

                const data = await respuesta.json();

                if (!respuesta.ok || !data.ok) {
                    if (data.redirectUrl) {
                        window.location.href = data.redirectUrl;
                        return;
                    }
                    throw new Error(data.message || "No se pudo actualizar favoritos.");
                }

                boton.dataset.active = String(!activo);
                boton.classList.toggle("active", !activo);
                const icono = boton.querySelector(".favorito-icon");
                if (icono) {
                    icono.textContent = (!activo) ? "♥" : "♥";
                }
            } catch (error) {
                console.error(error);
                alert(error.message || "No se pudo actualizar favoritos.");
            }
        });
    });

    document.querySelectorAll(".watchlist-toggle").forEach(function (boton) {
        boton.addEventListener("click", async function (event) {
            event.stopPropagation();
            const id = boton.dataset.id;
            const activo = boton.dataset.active === "true";

            try {
                const respuesta = await fetch("/Home/ToggleWatchlist", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
                    body: "idPelicula=" + encodeURIComponent(id)
                });

                const data = await respuesta.json();

                if (!respuesta.ok || !data.ok) {
                    if (data.redirectUrl) {
                        window.location.href = data.redirectUrl;
                        return;
                    }
                    throw new Error(data.message || "No se pudo actualizar watchlist.");
                }

                boton.dataset.active = String(!activo);
                boton.classList.toggle("active", !activo);
                const icono = boton.querySelector(".watchlist-icon");
                if (icono) {
                    icono.textContent = (!activo) ? "✓" : "+";
                }
            } catch (error) {
                console.error(error);
                alert(error.message || "No se pudo actualizar watchlist.");
            }
        });
    });
}

document.addEventListener("DOMContentLoaded", configurarAccionesCineura);
