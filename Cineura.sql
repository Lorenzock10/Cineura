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

-- 11. USUARIOS DE PRUEBA
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE NombreUsuario = 'admin')
BEGIN
    INSERT INTO Usuarios (Nombre, Apellido, NombreUsuario, Contraseña)
    VALUES ('Admin', 'Cineura', 'admin', '123456');
END

IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE NombreUsuario = 'cinemaniaco')
BEGIN
    INSERT INTO Usuarios (Nombre, Apellido, NombreUsuario, Contraseña)
    VALUES ('Juan', 'Pérez', 'cinemaniaco', '123456');
END
GO


-- 13. TENDENCIAS DE PRUEBA
IF NOT EXISTS (
    SELECT 1 FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'Dune: Part Two'
)
BEGIN
    INSERT INTO Tendencias (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT IdPelicula, 1000, SYSDATETIME() FROM Peliculas WHERE Titulo = 'Dune: Part Two';
END

IF NOT EXISTS (
    SELECT 1 FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'The Substance'
)
BEGIN
    INSERT INTO Tendencias (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT IdPelicula, 800, SYSDATETIME() FROM Peliculas WHERE Titulo = 'The Substance';
END
GO

-- 14. FAVORITOS DE PRUEBA
IF NOT EXISTS (
    SELECT 1 FROM Favoritos F
    INNER JOIN Usuarios U ON F.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON F.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'The Dark Knight'
)
BEGIN
    INSERT INTO Favoritos (IdUsuario, IdPelicula, Fecha)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'The Dark Knight';
END

IF NOT EXISTS (
    SELECT 1 FROM Favoritos F
    INNER JOIN Usuarios U ON F.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON F.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Inception'
)
BEGIN
    INSERT INTO Favoritos (IdUsuario, IdPelicula, Fecha)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Inception';
END
GO

-- 15. WATCHLIST DE PRUEBA
IF NOT EXISTS (
    SELECT 1 FROM Watchlist W
    INNER JOIN Usuarios U ON W.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON W.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Oppenheimer'
)
BEGIN
    INSERT INTO Watchlist (IdUsuario, IdPelicula, FechaAgregado)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Oppenheimer';
END

IF NOT EXISTS (
    SELECT 1 FROM Watchlist W
    INNER JOIN Usuarios U ON W.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON W.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Poor Things'
)
BEGIN
    INSERT INTO Watchlist (IdUsuario, IdPelicula, FechaAgregado)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin' AND P.Titulo = 'Poor Things';
END
GO
USE Cineura;
GO

-- ACTUALIZACIÓN DE POSTERS PARA LAS 21 PELÍCULAS AFECTADAS

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Toy Story')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/1/13/Toy_Story.jpg' WHERE Titulo = 'Toy Story';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Toy Story', 'Una aventura entre juguetes.', 'Animacion', 81, 1995, 'Alegre', 'https://upload.wikimedia.org/wikipedia/en/1/13/Toy_Story.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Shrek')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/iB64vpL3dIObOtMZgX3RqdVdQDc.jpg' WHERE Titulo = 'Shrek';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Shrek', 'Un ogro emprende una aventura inesperada.', 'Comedia', 90, 2001, 'Divertido', 'https://image.tmdb.org/t/p/w500/iB64vpL3dIObOtMZgX3RqdVdQDc.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Truman Show')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/vuza0WqY239yBXOadKlGwJsZJFE.jpg' WHERE Titulo = 'The Truman Show';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Truman Show', 'Un hombre descubre secretos sobre su vida.', 'Drama', 103, 1998, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/vuza0WqY239yBXOadKlGwJsZJFE.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'En busca de la felicidad')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/lBYOKAMcxIvuk9s9hMuecB9dPBV.jpg' WHERE Titulo = 'En busca de la felicidad';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('En busca de la felicidad', 'Un padre lucha por salir adelante.', 'Drama', 117, 2006, 'Inspirador', 'https://image.tmdb.org/t/p/w500/lBYOKAMcxIvuk9s9hMuecB9dPBV.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Superbad')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg' WHERE Titulo = 'Superbad';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Superbad', 'Dos amigos viven una noche inolvidable.', 'Comedia', 113, 2007, 'Divertido', 'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Coco')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg' WHERE Titulo = 'Coco';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Coco', 'Un chico descubre la historia de su familia.', 'Animacion', 105, 2017, 'Emotivo', 'https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Intensamente')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4Tl5A.jpg' WHERE Titulo = 'Intensamente';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Intensamente', 'Las emociones acompañan a una chica en su vida.', 'Animacion', 95, 2015, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4Tl5A.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Jumanji')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/vgpXmVaVyUL7GGiDeiK1mKEKzcX.jpg' WHERE Titulo = 'Jumanji';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Jumanji', 'Un juego transforma una aventura en realidad.', 'Aventura', 104, 1995, 'Emocionante', 'https://image.tmdb.org/t/p/w500/vgpXmVaVyUL7GGiDeiK1mKEKzcX.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Dune: Part Two')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg' WHERE Titulo = 'Dune: Part Two';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Dune: Part Two', 'Paul Atreides se une a Chani y los Fremen en una aventura por el destino de Arrakis.', 'Ciencia ficción', 166, 2024, 'Emocionante', 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Poor Things')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg' WHERE Titulo = 'Poor Things';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Poor Things', 'Bella Baxter descubre el mundo y su propia libertad en una historia fantástica.', 'Fantasía', 141, 2023, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Substance')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/lqoMzCcZYEFK729d6qzt349fB4o.jpg' WHERE Titulo = 'The Substance';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Substance', 'Una celebridad recurre a un tratamiento extraordinario que cambiará su vida.', 'Terror', 141, 2024, 'Intenso', 'https://image.tmdb.org/t/p/w500/lqoMzCcZYEFK729d6qzt349fB4o.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Anatomy of a Fall')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/kQs6keheMwCxJxrzV83VUwFtHkB.jpg' WHERE Titulo = 'Anatomy of a Fall';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Anatomy of a Fall', 'Una mujer es juzgada tras la muerte de su esposo y las pruebas dejan dudas sobre lo ocurrido.', 'Drama', 151, 2023, 'Intrigante', 'https://image.tmdb.org/t/p/w500/kQs6keheMwCxJxrzV83VUwFtHkB.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Dark Knight')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg' WHERE Titulo = 'The Dark Knight';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Dark Knight', 'Un héroe de la noche enfrenta al caos y a la anarquía en la ciudad de Gotham.', 'Acción', 152, 2008, 'Intenso', 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Inception')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg' WHERE Titulo = 'Inception';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Inception', 'Un ladrón que roba secretos a través del sueño profundo debe cumplir una misión imposible.', 'Ciencia ficción', 148, 2010, 'Intrigante', 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Interstellar')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg' WHERE Titulo = 'Interstellar';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Interstellar', 'Un grupo de exploradores viaja a través de un agujero de gusano para salvar a la humanidad.', 'Ciencia ficción', 169, 2014, 'Inspirador', 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Pulp Fiction')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg' WHERE Titulo = 'Pulp Fiction';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Pulp Fiction', 'Las vidas de varios criminales en Los Ángeles se entrelazan de forma inesperada.', 'Crimen', 154, 1994, 'Intenso', 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Forrest Gump')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg' WHERE Titulo = 'Forrest Gump';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Forrest Gump', 'La historia de un hombre bondadoso que presenciará eventos históricos clave.', 'Drama', 142, 1994, 'Emotivo', 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg');
IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Fight Club')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg' WHERE Titulo = 'Fight Club';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Fight Club', 'Un hombre aburrido funda un club clandestino que se transforma en algo más grande.', 'Drama', 139, 1999, 'Intenso', 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El viaje de Chihiro')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg' WHERE Titulo = 'El viaje de Chihiro';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El viaje de Chihiro', 'Una niña entra a un mundo mágico repleto de dioses y espíritus para rescatar a sus padres.', 'Animación', 125, 2001, 'Mágico', 'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Gladiator')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/f/fb/Gladiator_%282000_film_poster%29.png' WHERE Titulo = 'Gladiator';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Gladiator', 'Un antiguo general romano busca venganza contra el corrupto emperador que masacró a su familia.', 'Acción', 155, 2000, 'Épico', 'https://upload.wikimedia.org/wikipedia/en/f/fb/Gladiator_%282000_film_poster%29.png');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Parasite')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/ku1UvTWYvhFQbSesOD6zteY7bXT.jpg' WHERE Titulo = 'Parasite';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Parasite', 'Una familia humilde se infiltra en la vida de una adinerada familia con oscuras consecuencias.', 'Suspenso', 132, 2019, 'Intrigante', 'https://image.tmdb.org/t/p/w500/ku1UvTWYvhFQbSesOD6zteY7bXT.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'La La Land')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/a/ab/La_La_Land_%28film%29.png' WHERE Titulo = 'La La Land';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('La La Land', 'Un pianista de jazz y una aspirante a actriz persiguen sus sueños en la ciudad de las estrellas.', 'Romance', 128, 2016, 'Melancólico', 'https://upload.wikimedia.org/wikipedia/en/a/ab/La_La_Land_%28film%29.png');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Avengers: Endgame')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg' WHERE Titulo = 'Avengers: Endgame';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Avengers: Endgame', 'Los Vengadores restantes se unen en un intento final por revertir las acciones de Thanos.', 'Acción', 181, 2019, 'Épico', 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Oppenheimer')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/4/4a/Oppenheimer_%28film%29.jpg' WHERE Titulo = 'Oppenheimer';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Oppenheimer', 'La vida y conflictos de J. Robert Oppenheimer durante el desarrollo de la bomba atómica.', 'Biografía', 180, 2023, 'Reflexivo', 'https://upload.wikimedia.org/wikipedia/en/4/4a/Oppenheimer_%28film%29.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El Rey León')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/3/3d/The_Lion_King_poster.jpg' WHERE Titulo = 'El Rey León';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El Rey León', 'Un joven león debe superar la tragedia y asumir su lugar legítimo como rey.', 'Animación', 88, 1994, 'Inspirador', 'https://upload.wikimedia.org/wikipedia/en/3/3d/The_Lion_King_poster.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Jurassic Park')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/e/e7/Jurassic_Park_poster.jpg' WHERE Titulo = 'Jurassic Park';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Jurassic Park', 'Un parque temático con dinosaurios genéticamente clonados sufre una falla catastrófica.', 'Aventura', 127, 1993, 'Emocionante', 'https://upload.wikimedia.org/wikipedia/en/e/e7/Jurassic_Park_poster.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El silencio de los inocentes')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/7OFxU0bBO0HDL4klXmM1ahJPbv8.jpg' WHERE Titulo = 'El silencio de los inocentes';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El silencio de los inocentes', 'Una novata del FBI busca la ayuda de un brillante asesino caníbal para capturar a otro criminal.', 'Suspenso', 118, 1991, 'Tenebroso', 'https://image.tmdb.org/t/p/w500/7OFxU0bBO0HDL4klXmM1ahJPbv8.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Volver al Futuro')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/d/d2/Back_to_the_Future.jpg' WHERE Titulo = 'Volver al Futuro';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Volver al Futuro', 'Un joven es enviado accidentalmente 30 años al pasado en una máquina del tiempo.', 'Aventura', 116, 1985, 'Divertido', 'https://upload.wikimedia.org/wikipedia/en/d/d2/Back_to_the_Future.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Se7en')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/6/68/Seven_%28movie%29_poster.jpg' WHERE Titulo = 'Se7en';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Se7en', 'Dos detectives investigan una serie de crueles asesinatos basados en los siete pecados capitales.', 'Crimen', 127, 1995, 'Oscuro', 'https://upload.wikimedia.org/wikipedia/en/6/68/Seven_%28movie%29_poster.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El Padrino')
    UPDATE Peliculas SET PosterUrl = 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg' WHERE Titulo = 'El Padrino';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El Padrino', 'El envejecido patriarca de una dinastía del crimen organizado transfiere el control a su hijo.', 'Crimen', 175, 1972, 'Intenso', 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Everything Everywhere All at Once')
    UPDATE Peliculas SET PosterUrl = 'https://upload.wikimedia.org/wikipedia/en/1/1e/Everything_Everywhere_All_at_Once.jpg' WHERE Titulo = 'Everything Everywhere All at Once';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Everything Everywhere All at Once', 'Una mujer de mediana edad descubre que debe conectarse con versiones suyas en universos paralelos.', 'Ciencia ficción', 139, 2022, 'Inspirador', 'https://upload.wikimedia.org/wikipedia/en/1/1e/Everything_Everywhere_All_at_Once.jpg');

-- AMELIE
IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Amélie')
    UPDATE Peliculas
    SET PosterUrl = 'https://image.tmdb.org/t/p/w500/oTKduWL2tpIKEmkAqF4mFEAWAsv.jpg'
    WHERE Titulo = 'Amélie';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Amélie', 'Una joven camarera parisina decide mejorar de forma orquestada la vida de quienes la rodean.', 'Comedia', 122, 2001, 'Alegre', 'https://image.tmdb.org/t/p/w500/oTKduWL2tpIKEmkAqF4mFEAWAsv.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Psicosis')
    UPDATE Peliculas
    SET PosterUrl = 'https://commons.wikimedia.org/wiki/Special:FilePath/Psycho_(1960)_theatrical_poster.jpg'
    WHERE Titulo = 'Psicosis';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Psicosis', 'Una secretaria en fuga se hospeda en un siniestro motel regentado por Norman Bates.', 'Terror', 109, 1960, 'Tenebroso', 'https://commons.wikimedia.org/wiki/Special:FilePath/Psycho_(1960)_theatrical_poster.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Spider-Man: Into the Spider-Verse')
    UPDATE Peliculas
    SET PosterUrl = 'https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg'
    WHERE Titulo = 'Spider-Man: Into the Spider-Verse';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Spider-Man: Into the Spider-Verse', 'El joven Miles Morales aprende a ser Spider-Man cruzándose con héroes de otros universos.', 'Animación', 117, 2018, 'Emocionante', 'https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Matrix')
    UPDATE Peliculas
    SET PosterUrl = 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg'
    WHERE Titulo = 'The Matrix';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Matrix', 'Un programador descubre que la realidad es una simulación controlada por máquinas.', 'Ciencia ficción', 136, 1999, 'Emocionante', 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'WALL-E')
    UPDATE Peliculas
    SET PosterUrl = 'https://image.tmdb.org/t/p/w500/hbhFnRzzg6ZDmm8YAmxBnQpQIPh.jpg'
    WHERE Titulo = 'WALL-E';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('WALL-E', 'Un pequeño robot compactador de basura en una Tierra abandonada emprende un viaje espacial.', 'Animación', 98, 2008, 'Tierno', 'https://image.tmdb.org/t/p/w500/hbhFnRzzg6ZDmm8YAmxBnQpQIPh.jpg');

IF EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Whiplash')
    UPDATE Peliculas
    SET PosterUrl = 'https://image.tmdb.org/t/p/w500/7fn624j5lj3xTme2SgiLCeuedmO.jpg'
    WHERE Titulo = 'Whiplash';
ELSE
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Whiplash', 'Un joven e intempestivo baterista desafía sus límites con un profesor despiadado.', 'Drama', 106, 2014, 'Intenso', 'https://image.tmdb.org/t/p/w500/7fn624j5lj3xTme2SgiLCeuedmO.jpg');
GO

USE Cineura;
GO

-- 1. AGREGAR LOS ACTORES PRINCIPALES DE CADA PELÍCULA
DECLARE @Relaciones TABLE (
    Titulo NVARCHAR(200),
    Actor NVARCHAR(150)
);

INSERT INTO @Relaciones (Titulo, Actor)
VALUES
-- Toy Story
('Toy Story', 'Tom Hanks'),
('Toy Story', 'Tim Allen'),
('Toy Story', 'Don Rickles'),

-- Shrek
('Shrek', 'Mike Myers'),
('Shrek', 'Eddie Murphy'),
('Shrek', 'Cameron Diaz'),

-- The Truman Show
('The Truman Show', 'Jim Carrey'),
('The Truman Show', 'Laura Linney'),
('The Truman Show', 'Noah Emmerich'),

-- En busca de la felicidad
('En busca de la felicidad', 'Will Smith'),
('En busca de la felicidad', 'Jaden Smith'),
('En busca de la felicidad', 'Thandiwe Newton'),

-- Superbad
('Superbad', 'Jonah Hill'),
('Superbad', 'Michael Cera'),
('Superbad', 'Christopher Mintz-Plasse'),

-- Coco
('Coco', 'Anthony Gonzalez'),
('Coco', 'Gael García Bernal'),
('Coco', 'Benjamin Bratt'),

-- Intensamente
('Intensamente', 'Amy Poehler'),
('Intensamente', 'Phyllis Smith'),
('Intensamente', 'Bill Hader'),

-- Jumanji
('Jumanji', 'Robin Williams'),
('Jumanji', 'Kirsten Dunst'),
('Jumanji', 'Bonnie Hunt'),

-- Dune: Part Two
('Dune: Part Two', 'Timothée Chalamet'),
('Dune: Part Two', 'Zendaya'),
('Dune: Part Two', 'Rebecca Ferguson'),

-- Poor Things
('Poor Things', 'Emma Stone'),
('Poor Things', 'Mark Ruffalo'),
('Poor Things', 'Willem Dafoe'),

-- The Substance
('The Substance', 'Demi Moore'),
('The Substance', 'Margaret Qualley'),
('The Substance', 'Dennis Quaid'),

-- Anatomy of a Fall
('Anatomy of a Fall', 'Sandra Hüller'),
('Anatomy of a Fall', 'Swann Arlaud'),
('Anatomy of a Fall', 'Milo Machado-Graner'),

-- The Dark Knight
('The Dark Knight', 'Christian Bale'),
('The Dark Knight', 'Heath Ledger'),
('The Dark Knight', 'Aaron Eckhart'),

-- Inception
('Inception', 'Leonardo DiCaprio'),
('Inception', 'Joseph Gordon-Levitt'),
('Inception', 'Elliot Page'),

-- Interstellar
('Interstellar', 'Matthew McConaughey'),
('Interstellar', 'Anne Hathaway'),
('Interstellar', 'Jessica Chastain'),

-- Pulp Fiction
('Pulp Fiction', 'John Travolta'),
('Pulp Fiction', 'Samuel L. Jackson'),
('Pulp Fiction', 'Uma Thurman'),

-- Forrest Gump
('Forrest Gump', 'Tom Hanks'),
('Forrest Gump', 'Robin Wright'),
('Forrest Gump', 'Gary Sinise'),

-- Fight Club
('Fight Club', 'Brad Pitt'),
('Fight Club', 'Edward Norton'),
('Fight Club', 'Helena Bonham Carter'),

-- El viaje de Chihiro
('El viaje de Chihiro', 'Rumi Hiiragi'),
('El viaje de Chihiro', 'Miyu Irino'),
('El viaje de Chihiro', 'Mari Natsuki'),

-- Gladiator
('Gladiator', 'Russell Crowe'),
('Gladiator', 'Joaquin Phoenix'),
('Gladiator', 'Connie Nielsen'),

-- Parasite
('Parasite', 'Song Kang-ho'),
('Parasite', 'Lee Sun-kyun'),
('Parasite', 'Cho Yeo-jeong'),

-- La La Land
('La La Land', 'Ryan Gosling'),
('La La Land', 'Emma Stone'),
('La La Land', 'John Legend'),

-- Avengers: Endgame
('Avengers: Endgame', 'Robert Downey Jr.'),
('Avengers: Endgame', 'Chris Evans'),
('Avengers: Endgame', 'Mark Ruffalo'),

-- Oppenheimer
('Oppenheimer', 'Cillian Murphy'),
('Oppenheimer', 'Emily Blunt'),
('Oppenheimer', 'Robert Downey Jr.'),

-- El Rey León
('El Rey León', 'Matthew Broderick'),
('El Rey León', 'Jeremy Irons'),
('El Rey León', 'James Earl Jones'),

-- Jurassic Park
('Jurassic Park', 'Sam Neill'),
('Jurassic Park', 'Laura Dern'),
('Jurassic Park', 'Jeff Goldblum'),

-- El silencio de los inocentes
('El silencio de los inocentes', 'Jodie Foster'),
('El silencio de los inocentes', 'Anthony Hopkins'),
('El silencio de los inocentes', 'Scott Glenn'),

-- Volver al Futuro
('Volver al Futuro', 'Michael J. Fox'),
('Volver al Futuro', 'Christopher Lloyd'),
('Volver al Futuro', 'Lea Thompson'),

-- Se7en
('Se7en', 'Brad Pitt'),
('Se7en', 'Morgan Freeman'),
('Se7en', 'Gwyneth Paltrow'),

-- El Padrino
('El Padrino', 'Marlon Brando'),
('El Padrino', 'Al Pacino'),
('El Padrino', 'James Caan'),

-- Everything Everywhere All at Once
('Everything Everywhere All at Once', 'Michelle Yeoh'),
('Everything Everywhere All at Once', 'Stephanie Hsu'),
('Everything Everywhere All at Once', 'Ke Huy Quan'),

-- Amélie
('Amélie', 'Audrey Tautou'),
('Amélie', 'Mathieu Kassovitz'),
('Amélie', 'Rufus'),

-- Psicosis
('Psicosis', 'Anthony Perkins'),
('Psicosis', 'Janet Leigh'),
('Psicosis', 'Vera Miles'),

-- Spider-Man: Into the Spider-Verse
('Spider-Man: Into the Spider-Verse', 'Shameik Moore'),
('Spider-Man: Into the Spider-Verse', 'Hailee Steinfeld'),
('Spider-Man: Into the Spider-Verse', 'Jake Johnson'),

-- The Matrix
('The Matrix', 'Keanu Reeves'),
('The Matrix', 'Laurence Fishburne'),
('The Matrix', 'Carrie-Anne Moss'),

-- WALL-E
('WALL-E', 'Ben Burtt'),
('WALL-E', 'Elissa Knight'),
('WALL-E', 'Jeff Garlin'),

-- Whiplash
('Whiplash', 'Miles Teller'),
('Whiplash', 'J.K. Simmons'),
('Whiplash', 'Paul Reiser');


-- 2. INSERTAR LOS ACTORES QUE TODAVÍA NO EXISTEN
INSERT INTO Actores (Nombre)
SELECT DISTINCT R.Actor
FROM @Relaciones R
WHERE NOT EXISTS (
    SELECT 1
    FROM Actores A
    WHERE A.Nombre = R.Actor
);


-- 3. VINCULAR CADA ACTOR CON SU PELÍCULA
-- No se repiten relaciones que ya existen.
INSERT INTO PeliculaActor (IdPelicula, IdActor)
SELECT P.IdPelicula, A.IdActor
FROM @Relaciones R
INNER JOIN Peliculas P
    ON P.Titulo = R.Titulo
INNER JOIN Actores A
    ON A.Nombre = R.Actor
WHERE NOT EXISTS (
    SELECT 1
    FROM PeliculaActor PA
    WHERE PA.IdPelicula = P.IdPelicula
      AND PA.IdActor = A.IdActor
);
GO
