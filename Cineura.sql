
IF DB_ID('Cineura') IS NULL
BEGIN
    CREATE DATABASE Cineura;
END
GO

USE Cineura;
GO

-- 1. USUARIOS
IF OBJECT_ID('Usuarios', 'U') IS NULL
BEGIN
    CREATE TABLE Usuarios (
        IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Apellido NVARCHAR(100) NOT NULL,
        NombreUsuario NVARCHAR(50) NOT NULL UNIQUE,
        Contraseña NVARCHAR(255) NOT NULL
    );
END
GO

-- 2. DIRECTORES
IF OBJECT_ID('Directores', 'U') IS NULL
BEGIN
    CREATE TABLE Directores (
        IdDirector INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(150) NOT NULL
    );
END
GO

-- 3. ACTORES
IF OBJECT_ID('Actores', 'U') IS NULL
BEGIN
    CREATE TABLE Actores (
        IdActor INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(150) NOT NULL
    );
END
GO

-- 4. PELICULAS
IF OBJECT_ID('Peliculas', 'U') IS NULL
BEGIN
    CREATE TABLE Peliculas (
        IdPelicula INT IDENTITY(1,1) PRIMARY KEY,
        Titulo NVARCHAR(200) NOT NULL,
        Sinopsis NVARCHAR(MAX),
        Genero NVARCHAR(100),
        DuracionMinutos INT,
        Anio INT,
        Animo NVARCHAR(100),
        IdDirector INT NULL,
        PosterUrl NVARCHAR(500),
        FOREIGN KEY (IdDirector) REFERENCES Directores(IdDirector)
    );
END
GO

-- 5. RELACION ENTRE PELICULAS Y ACTORES
IF OBJECT_ID('PeliculaActor', 'U') IS NULL
BEGIN
    CREATE TABLE PeliculaActor (
        IdPelicula INT NOT NULL,
        IdActor INT NOT NULL,
        PRIMARY KEY (IdPelicula, IdActor),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula),
        FOREIGN KEY (IdActor) REFERENCES Actores(IdActor)
    );
END
GO

-- 6. COMENTARIOS
IF OBJECT_ID('Comentarios', 'U') IS NULL
BEGIN
    CREATE TABLE Comentarios (
        IdComentario INT IDENTITY(1,1) PRIMARY KEY,
        IdUsuario INT NOT NULL,
        IdPelicula INT NOT NULL,
        Texto NVARCHAR(1000) NOT NULL,
        Fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula)
    );
END
GO

-- 7. VALORACIONES
IF OBJECT_ID('Valoraciones', 'U') IS NULL
BEGIN
    CREATE TABLE Valoraciones (
        IdValoracion INT IDENTITY(1,1) PRIMARY KEY,
        IdUsuario INT NOT NULL,
        IdPelicula INT NOT NULL,
        Puntuacion INT NOT NULL CHECK (Puntuacion BETWEEN 1 AND 5),
        UNIQUE (IdUsuario, IdPelicula),
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula)
    );
END
GO

-- 8. FAVORITOS
IF OBJECT_ID('Favoritos', 'U') IS NULL
BEGIN
    CREATE TABLE Favoritos (
        IdUsuario INT NOT NULL,
        IdPelicula INT NOT NULL,
        Fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        PRIMARY KEY (IdUsuario, IdPelicula),
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula)
    );
END
GO

-- 9. WATCHLIST
IF OBJECT_ID('Watchlist', 'U') IS NULL
BEGIN
    CREATE TABLE Watchlist (
        IdUsuario INT NOT NULL,
        IdPelicula INT NOT NULL,
        FechaAgregado DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        PRIMARY KEY (IdUsuario, IdPelicula),
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula)
    );
END
GO

-- 10. TENDENCIAS
IF OBJECT_ID('Tendencias', 'U') IS NULL
BEGIN
    CREATE TABLE Tendencias (
        IdTendencia INT IDENTITY(1,1) PRIMARY KEY,
        IdPelicula INT NOT NULL,
        CantidadInteracciones INT NOT NULL DEFAULT 0,
        FechaActualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        FOREIGN KEY (IdPelicula) REFERENCES Peliculas(IdPelicula)
    );
END
GO





USE Cineura;
GO

IF NOT EXISTS (SELECT 1 FROM Peliculas)
BEGIN
    INSERT INTO Peliculas
        (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES
        (
            'Toy Story',
            'Una aventura entre juguetes.',
            'Animacion',
            81,
            1995,
            'Alegre',
            'https://image.tmdb.org/t/p/w500/4Z2h4D7f3Q1bQ1a0jW2h7v9K2.jpg'
        ),
        (
            'Shrek',
            'Un ogro emprende una aventura inesperada.',
            'Comedia',
            90,
            2001,
            'Divertido',
            'https://image.tmdb.org/t/p/w500/iB64vpL3dIObOtMZgX3RqdVdQDc.jpg'
        ),
        (
            'The Truman Show',
            'Un hombre descubre secretos sobre su vida.',
            'Drama',
            103,
            1998,
            'Reflexivo',
            'https://image.tmdb.org/t/p/w500/vuza0WqY239yBXOadKlGwJsZJFE.jpg'
        ),
        (
            'En busca de la felicidad',
            'Un padre lucha por salir adelante.',
            'Drama',
            117,
            2006,
            'Inspirador',
            'https://image.tmdb.org/t/p/w500/lBYOKAMcxIvuk9s9hMuecB9dPBV.jpg'
        ),
        (
            'Superbad',
            'Dos amigos viven una noche inolvidable.',
            'Comedia',
            113,
            2007,
            'Divertido',
            'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg'
        ),
        (
            'Coco',
            'Un chico descubre la historia de su familia.',
            'Animacion',
            105,
            2017,
            'Emotivo',
            'https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg'
        ),
        (
            'Intensamente',
            'Las emociones acompañan a una chica en su vida.',
            'Animacion',
            95,
            2015,
            'Reflexivo',
            'https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4Tl5A.jpg'
        ),
        (
            'Jumanji',
            'Un juego transforma una aventura en realidad.',
            'Aventura',
            104,
            1995,
            'Emocionante',
            'https://image.tmdb.org/t/p/w500/vgpXmVaVyUL7GGiDeiK1mKEKzcX.jpg'
        );
END
GO
USE Cineura;
GO

-- 11. AGREGAR LAS PELICULAS DESTACADAS

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Dune: Part Two')
BEGIN
    INSERT INTO Peliculas
        (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES
        (
            'Dune: Part Two',
            'Paul Atreides se une a Chani y los Fremen en una aventura por el destino de Arrakis.',
            'Ciencia ficción',
            166,
            2024,
            'Emocionante',
            'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Poor Things')
BEGIN
    INSERT INTO Peliculas
        (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES
        (
            'Poor Things',
            'Bella Baxter descubre el mundo y su propia libertad en una historia fantástica.',
            'Fantasía',
            141,
            2023,
            'Reflexivo',
            'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Substance')
BEGIN
    INSERT INTO Peliculas
        (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES
        (
            'The Substance',
            'Una celebridad recurre a un tratamiento extraordinario que cambiará su vida.',
            'Terror',
            141,
            2024,
            'Intenso',
            'https://image.tmdb.org/t/p/w500/lqoMzCcZYEFK729d6qzt349fB4o.jpg'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Anatomy of a Fall')
BEGIN
    INSERT INTO Peliculas
        (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES
        (
            'Anatomy of a Fall',
            'Una mujer es juzgada tras la muerte de su esposo y las pruebas dejan dudas sobre lo ocurrido.',
            'Drama',
            151,
            2023,
            'Intrigante',
            'https://image.tmdb.org/t/p/w500/kQs6keheMwCxJxrzV83VUwFtHkB.jpg'
        );
END
GO
-- 12. AGREGAR LAS PELICULAS A TENDENCIAS

IF NOT EXISTS (
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'Dune: Part Two'
)
BEGIN
    INSERT INTO Tendencias
        (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT
        IdPelicula,
        1000,
        SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'Dune: Part Two';
END

IF NOT EXISTS (
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'Poor Things'
)
BEGIN
    INSERT INTO Tendencias
        (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT
        IdPelicula,
        900,
        SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'Poor Things';
END

IF NOT EXISTS (
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'The Substance'
)
BEGIN
    INSERT INTO Tendencias
        (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT
        IdPelicula,
        800,
        SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'The Substance';
END

IF NOT EXISTS (
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'Anatomy of a Fall'
)
BEGIN
    INSERT INTO Tendencias
        (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT
        IdPelicula,
        700,
        SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'Anatomy of a Fall';
END
GO