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
IF OBJECT_ID('PreferenciasUsuario', 'U') IS NULL
BEGIN
    CREATE TABLE PreferenciasUsuario (
        IdPreferencia INT IDENTITY(1,1) PRIMARY KEY,
        IdUsuario INT NOT NULL,
        NumeroPregunta INT NOT NULL,
        Respuesta NVARCHAR(100) NOT NULL,

        FOREIGN KEY (IdUsuario)
        REFERENCES Usuarios(IdUsuario),

        CONSTRAINT UQ_PreferenciaUsuario
        UNIQUE (IdUsuario, NumeroPregunta, Respuesta)
    );
END
GO

-- Registra quién terminó el cuestionario
IF OBJECT_ID('CuestionariosUsuario', 'U') IS NULL
BEGIN
    CREATE TABLE CuestionariosUsuario (
        IdUsuario INT PRIMARY KEY,
        Completado BIT NOT NULL DEFAULT 0,

        FOREIGN KEY (IdUsuario)
        REFERENCES Usuarios(IdUsuario)
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
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'Dune: Part Two'
)
BEGIN
    INSERT INTO Tendencias (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT IdPelicula, 1000, SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'Dune: Part Two';
END

IF NOT EXISTS (
    SELECT 1
    FROM Tendencias T
    INNER JOIN Peliculas P ON T.IdPelicula = P.IdPelicula
    WHERE P.Titulo = 'The Substance'
)
BEGIN
    INSERT INTO Tendencias (IdPelicula, CantidadInteracciones, FechaActualizacion)
    SELECT IdPelicula, 800, SYSDATETIME()
    FROM Peliculas
    WHERE Titulo = 'The Substance';
END
GO

-- 14. FAVORITOS DE PRUEBA
IF NOT EXISTS (
    SELECT 1
    FROM Favoritos F
    INNER JOIN Usuarios U ON F.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON F.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'The Dark Knight'
)
BEGIN
    INSERT INTO Favoritos (IdUsuario, IdPelicula, Fecha)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'The Dark Knight';
END

IF NOT EXISTS (
    SELECT 1
    FROM Favoritos F
    INNER JOIN Usuarios U ON F.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON F.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Inception'
)
BEGIN
    INSERT INTO Favoritos (IdUsuario, IdPelicula, Fecha)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Inception';
END
GO

-- 15. WATCHLIST DE PRUEBA
IF NOT EXISTS (
    SELECT 1
    FROM Watchlist W
    INNER JOIN Usuarios U ON W.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON W.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Oppenheimer'
)
BEGIN
    INSERT INTO Watchlist (IdUsuario, IdPelicula, FechaAgregado)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Oppenheimer';
END

IF NOT EXISTS (
    SELECT 1
    FROM Watchlist W
    INNER JOIN Usuarios U ON W.IdUsuario = U.IdUsuario
    INNER JOIN Peliculas P ON W.IdPelicula = P.IdPelicula
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Poor Things'
)
BEGIN
    INSERT INTO Watchlist (IdUsuario, IdPelicula, FechaAgregado)
    SELECT U.IdUsuario, P.IdPelicula, SYSDATETIME()
    FROM Usuarios U, Peliculas P
    WHERE U.NombreUsuario = 'admin'
      AND P.Titulo = 'Poor Things';
END
GO

USE Cineura;
GO

-- ACTUALIZACIÓN DE POSTERS PARA LAS 37 PELÍCULAS

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

-- 16. ASIGNAR UN DIRECTOR A CADA PELÍCULA
-- Un director puede estar asociado a varias películas.
-- Cada película queda asociada a un único director.

DECLARE @DirectoresPeliculas TABLE (
    Titulo NVARCHAR(200),
    Director NVARCHAR(150)
);

INSERT INTO @DirectoresPeliculas (Titulo, Director)
VALUES
('Toy Story', 'John Lasseter'),
('Shrek', 'Andrew Adamson'),
('The Truman Show', 'Peter Weir'),
('En busca de la felicidad', 'Gabriele Muccino'),
('Superbad', 'Greg Mottola'),
('Coco', 'Lee Unkrich'),
('Intensamente', 'Pete Docter'),
('Jumanji', 'Joe Johnston'),
('Dune: Part Two', 'Denis Villeneuve'),
('Poor Things', 'Yorgos Lanthimos'),
('The Substance', 'Coralie Fargeat'),
('Anatomy of a Fall', 'Justine Triet'),
('The Dark Knight', 'Christopher Nolan'),
('Inception', 'Christopher Nolan'),
('Interstellar', 'Christopher Nolan'),
('Pulp Fiction', 'Quentin Tarantino'),
('Forrest Gump', 'Robert Zemeckis'),
('Fight Club', 'David Fincher'),
('El viaje de Chihiro', 'Hayao Miyazaki'),
('Gladiator', 'Ridley Scott'),
('Parasite', 'Bong Joon-ho'),
('La La Land', 'Damien Chazelle'),
('Avengers: Endgame', 'Anthony Russo'),
('Oppenheimer', 'Christopher Nolan'),
('El Rey León', 'Roger Allers'),
('Jurassic Park', 'Steven Spielberg'),
('El silencio de los inocentes', 'Jonathan Demme'),
('Volver al Futuro', 'Robert Zemeckis'),
('Se7en', 'David Fincher'),
('El Padrino', 'Francis Ford Coppola'),
('Everything Everywhere All at Once', 'Daniel Kwan'),
('Amélie', 'Jean-Pierre Jeunet'),
('Psicosis', 'Alfred Hitchcock'),
('Spider-Man: Into the Spider-Verse', 'Bob Persichetti'),
('The Matrix', 'Lana Wachowski'),
('WALL-E', 'Andrew Stanton'),
('Whiplash', 'Damien Chazelle');

-- 16.1. INSERTAR LOS DIRECTORES QUE TODAVÍA NO EXISTEN
INSERT INTO Directores (Nombre)
SELECT DISTINCT DP.Director
FROM @DirectoresPeliculas DP
WHERE NOT EXISTS (
    SELECT 1
    FROM Directores D
    WHERE D.Nombre = DP.Director
);

-- 16.2. ASIGNAR EL DIRECTOR CORRESPONDIENTE A CADA PELÍCULA
UPDATE P
SET P.IdDirector = D.IdDirector
FROM Peliculas P
INNER JOIN @DirectoresPeliculas DP
    ON DP.Titulo = P.Titulo
INNER JOIN Directores D
    ON D.Nombre = DP.Director;

-- 16.3. VERIFICAR QUE TODAS LAS PELÍCULAS TENGAN DIRECTOR
IF EXISTS (
    SELECT 1
    FROM Peliculas
    WHERE IdDirector IS NULL
)
BEGIN
    PRINT 'ATENCIÓN: Hay películas sin director asignado. No se puede establecer NOT NULL hasta asignarles un director.';
END
ELSE
BEGIN
    ALTER TABLE Peliculas
    ALTER COLUMN IdDirector INT NOT NULL;

    PRINT 'Todos los registros tienen director asignado.';
END
GO

-- 17. AGREGAR LOS ACTORES PRINCIPALES DE CADA PELÍCULA
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

-- 18. INSERTAR LOS ACTORES QUE TODAVÍA NO EXISTEN
INSERT INTO Actores (Nombre)
SELECT DISTINCT R.Actor
FROM @Relaciones R
WHERE NOT EXISTS (
    SELECT 1
    FROM Actores A
    WHERE A.Nombre = R.Actor
);

-- 19. VINCULAR CADA ACTOR CON SU PELÍCULA
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

-- 20. COMPROBAR LOS ACTORES ASIGNADOS
SELECT
    P.Titulo AS Pelicula,
    A.Nombre AS Actor
FROM PeliculaActor PA
INNER JOIN Peliculas P
    ON P.IdPelicula = PA.IdPelicula
INNER JOIN Actores A
    ON A.IdActor = PA.IdActor
ORDER BY P.Titulo, A.Nombre;
GO

-- 21. COMPROBAR LOS DIRECTORES ASIGNADOS
SELECT
    P.Titulo AS Pelicula,
    D.Nombre AS Director
FROM Peliculas P
INNER JOIN Directores D
    ON P.IdDirector = D.IdDirector
ORDER BY D.Nombre, P.Titulo;
GO
INSERT INTO Tendencias (IdPelicula, CantidadInteracciones)
SELECT P.IdPelicula, 1000
FROM Peliculas P
WHERE P.Titulo = 'Dune: Part Two'
AND NOT EXISTS (
    SELECT 1 FROM Tendencias T
    WHERE T.IdPelicula = P.IdPelicula
);

INSERT INTO Tendencias (IdPelicula, CantidadInteracciones)
SELECT P.IdPelicula, 900
FROM Peliculas P
WHERE P.Titulo = 'Poor Things'
AND NOT EXISTS (
    SELECT 1 FROM Tendencias T
    WHERE T.IdPelicula = P.IdPelicula
);

INSERT INTO Tendencias (IdPelicula, CantidadInteracciones)
SELECT P.IdPelicula, 800
FROM Peliculas P
WHERE P.Titulo = 'The Substance'
AND NOT EXISTS (
    SELECT 1 FROM Tendencias T
    WHERE T.IdPelicula = P.IdPelicula
);

INSERT INTO Tendencias (IdPelicula, CantidadInteracciones)
SELECT P.IdPelicula, 700
FROM Peliculas P
WHERE P.Titulo = 'Anatomy of a Fall'
AND NOT EXISTS (
    SELECT 1 FROM Tendencias T
    WHERE T.IdPelicula = P.IdPelicula
);

USE Cineura;
GO

-- ============================================
-- 22. CREAR TABLA DE ETIQUETAS
-- ============================================

IF OBJECT_ID('Etiquetas', 'U') IS NULL
BEGIN
    CREATE TABLE Etiquetas (
        IdEtiqueta INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Tipo NVARCHAR(30) NOT NULL,

        CONSTRAINT UQ_Etiquetas_Nombre_Tipo
            UNIQUE (Nombre, Tipo),

        CONSTRAINT CK_Etiquetas_Tipo
            CHECK (Tipo IN (
                'Tematica',
                'Estilo',
                'Emocion',
                'Ritmo'
            ))
    );
END
GO


-- ============================================
-- 23. CREAR RELACIÓN PELÍCULA - ETIQUETA
-- ============================================

IF OBJECT_ID('PeliculaEtiquetas', 'U') IS NULL
BEGIN
    CREATE TABLE PeliculaEtiquetas (
        IdPelicula INT NOT NULL,
        IdEtiqueta INT NOT NULL,

        PRIMARY KEY (IdPelicula, IdEtiqueta),

        FOREIGN KEY (IdPelicula)
            REFERENCES Peliculas(IdPelicula),

        FOREIGN KEY (IdEtiqueta)
            REFERENCES Etiquetas(IdEtiqueta)
    );
END
GO


-- DIRECTORES DE LAS NUEVAS PELÍCULAS
INSERT INTO Directores (Nombre)
SELECT DISTINCT V.Director
FROM (VALUES
(N'Alien', 1979, 117, N'Terror', N'Tenebroso', N'Ridley Scott', N'Sigourney Weaver', N'Tom Skerritt', N'John Hurt', N'Una tripulación espacial encuentra una amenaza desconocida.'),
(N'Aliens', 1986, 137, N'Ciencia ficción', N'Intenso', N'James Cameron', N'Sigourney Weaver', N'Michael Biehn', N'Bill Paxton', N'Ripley regresa a un planeta ocupado por criaturas peligrosas.'),
(N'The Thing', 1982, 109, N'Terror', N'Tenebroso', N'John Carpenter', N'Kurt Russell', N'Keith David', N'Wilford Brimley', N'Un equipo aislado enfrenta una criatura capaz de imitar personas.'),
(N'Halloween', 1978, 91, N'Terror', N'Tenebroso', N'John Carpenter', N'Jamie Lee Curtis', N'Donald Pleasence', N'Nancy Kyes', N'Una comunidad vive una noche de miedo ante un asesino enmascarado.'),
(N'Scream', 1996, 111, N'Terror', N'Intrigante', N'Wes Craven', N'Neve Campbell', N'Courteney Cox', N'David Arquette', N'Una adolescente intenta descubrir quién aterroriza su pueblo.'),
(N'The Conjuring', 2013, 112, N'Terror', N'Tenebroso', N'James Wan', N'Vera Farmiga', N'Patrick Wilson', N'Lili Taylor', N'Dos investigadores estudian sucesos extraños en una casa.'),
(N'Insidious', 2010, 103, N'Terror', N'Tenebroso', N'James Wan', N'Patrick Wilson', N'Rose Byrne', N'Lin Shaye', N'Una familia busca respuestas a fenómenos inexplicables.'),
(N'Get Out', 2017, 104, N'Terror', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Allison Williams', N'Bradley Whitford', N'Un joven descubre inquietantes secretos durante una visita familiar.'),
(N'Us', 2019, 116, N'Terror', N'Tenebroso', N'Jordan Peele', N'Lupita Nyong''o', N'Winston Duke', N'Elisabeth Moss', N'Una familia se enfrenta a visitantes idénticos a ellos.'),
(N'Nope', 2022, 130, N'Ciencia ficción', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Keke Palmer', N'Steven Yeun', N'Dos hermanos investigan un fenómeno extraño en el cielo.'),
(N'Hereditary', 2018, 127, N'Terror', N'Tenebroso', N'Ari Aster', N'Toni Collette', N'Alex Wolff', N'Gabriel Byrne', N'Una familia descubre secretos perturbadores de su pasado.'),
(N'Midsommar', 2019, 148, N'Terror', N'Inquietante', N'Ari Aster', N'Florence Pugh', N'Jack Reynor', N'William Jackson Harper', N'Un viaje a un festival remoto toma un giro inquietante.'),
(N'The Witch', 2015, 92, N'Terror', N'Tenebroso', N'Robert Eggers', N'Anya Taylor-Joy', N'Ralph Ineson', N'Kate Dickie', N'Una familia puritana enfrenta sucesos misteriosos.'),
(N'The Lighthouse', 2019, 109, N'Drama', N'Oscuro', N'Robert Eggers', N'Robert Pattinson', N'Willem Dafoe', N'Valeriia Karaman', N'Dos fareros aislados empiezan a desconfiar entre sí.'),
(N'The Babadook', 2014, 94, N'Terror', N'Tenebroso', N'Jennifer Kent', N'Essie Davis', N'Noah Wiseman', N'Daniel Henshall', N'Una madre y su hijo temen a una presencia misteriosa.'),
(N'A Quiet Place', 2018, 90, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'John Krasinski', N'Millicent Simmonds', N'Una familia debe vivir en silencio para sobrevivir.'),
(N'A Quiet Place Part II', 2020, 97, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'Cillian Murphy', N'Millicent Simmonds', N'Una familia continúa su camino por un mundo peligroso.'),
(N'It', 2017, 135, N'Terror', N'Tenebroso', N'Andy Muschietti', N'Jaeden Martell', N'Sophia Lillis', N'Bill Skarsgård', N'Un grupo de amigos investiga desapariciones en su pueblo.'),
(N'The Ring', 2002, 115, N'Terror', N'Tenebroso', N'Gore Verbinski', N'Naomi Watts', N'Martin Henderson', N'David Dorfman', N'Una periodista investiga una misteriosa grabación.'),
(N'The Others', 2001, 104, N'Terror', N'Intrigante', N'Alejandro Amenábar', N'Nicole Kidman', N'Fionnula Flanagan', N'Christopher Eccleston', N'Una madre percibe sucesos inexplicables en su mansión.'),
(N'The Blair Witch Project', 1999, 81, N'Terror', N'Tenebroso', N'Daniel Myrick', N'Heather Donahue', N'Michael C. Williams', N'Joshua Leonard', N'Tres estudiantes se pierden mientras filman un documental.'),
(N'Paranormal Activity', 2007, 86, N'Terror', N'Tenebroso', N'Oren Peli', N'Katie Featherston', N'Micah Sloat', N'Mark Fredrichs', N'Una pareja registra extraños sucesos en su hogar.'),
(N'The Descent', 2005, 99, N'Terror', N'Tenso', N'Neil Marshall', N'Shauna Macdonald', N'Natalie Mendoza', N'Alex Reid', N'Un grupo de amigas queda atrapado en unas cuevas.'),
(N'Saw', 2004, 103, N'Terror', N'Intrigante', N'James Wan', N'Cary Elwes', N'Leigh Whannell', N'Danny Glover', N'Dos desconocidos deben resolver un misterio para escapar.'),
(N'Final Destination', 2000, 98, N'Terror', N'Tenso', N'James Wong', N'Devon Sawa', N'Ali Larter', N'Kerr Smith', N'Un joven presiente un accidente y altera un destino.'),
(N'The Sixth Sense', 1999, 107, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bruce Willis', N'Haley Joel Osment', N'Toni Collette', N'Un psicólogo intenta ayudar a un niño con un secreto.'),
(N'Split', 2016, 117, N'Suspenso', N'Tenso', N'M. Night Shyamalan', N'James McAvoy', N'Anya Taylor-Joy', N'Betty Buckley', N'Tres jóvenes intentan comprender a su captor.'),
(N'Signs', 2002, 106, N'Ciencia ficción', N'Intrigante', N'M. Night Shyamalan', N'Mel Gibson', N'Joaquin Phoenix', N'Rory Culkin', N'Una familia descubre marcas inexplicables en sus cultivos.'),
(N'The Village', 2004, 108, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bryce Dallas Howard', N'Joaquin Phoenix', N'Adrien Brody', N'Una comunidad aislada teme lo que habita el bosque.'),
(N'The Shining', 1980, 146, N'Terror', N'Tenebroso', N'Stanley Kubrick', N'Jack Nicholson', N'Shelley Duvall', N'Danny Lloyd', N'Un cuidador y su familia pasan el invierno en un hotel aislado.'),
(N'Doctor Sleep', 2019, 152, N'Terror', N'Tenebroso', N'Mike Flanagan', N'Ewan McGregor', N'Rebecca Ferguson', N'Kyliegh Curran', N'Un hombre con habilidades especiales ayuda a una niña.'),
(N'Carrie', 1976, 98, N'Terror', N'Intenso', N'Brian De Palma', N'Sissy Spacek', N'Piper Laurie', N'Amy Irving', N'Una adolescente descubre un poder que no comprende.'),
(N'Rosemary''s Baby', 1968, 137, N'Terror', N'Inquietante', N'Roman Polanski', N'Mia Farrow', N'John Cassavetes', N'Ruth Gordon', N'Una mujer sospecha de sus nuevos vecinos.'),
(N'The Exorcist', 1973, 122, N'Terror', N'Tenebroso', N'William Friedkin', N'Ellen Burstyn', N'Linda Blair', N'Max von Sydow', N'Una madre busca ayuda ante sucesos extraños con su hija.'),
(N'The Texas Chain Saw Massacre', 1974, 83, N'Terror', N'Tenso', N'Tobe Hooper', N'Marilyn Burns', N'Paul A. Partain', N'Edwin Neal', N'Un grupo de viajeros se encuentra con una familia aterradora.'),
(N'The Nightmare Before Christmas', 1993, 76, N'Animación', N'Mágico', N'Henry Selick', N'Chris Sarandon', N'Catherine O''Hara', N'Danny Elfman', N'El rey de Halloween descubre la celebración navideña.'),
(N'Coraline', 2009, 100, N'Animación', N'Tenebroso', N'Henry Selick', N'Dakota Fanning', N'Teri Hatcher', N'John Hodgman', N'Una niña encuentra una puerta hacia un mundo alternativo.'),
(N'Corpse Bride', 2005, 77, N'Animación', N'Melancólico', N'Tim Burton', N'Johnny Depp', N'Helena Bonham Carter', N'Emily Watson', N'Un joven entra accidentalmente en el mundo de los muertos.'),
(N'Frankenweenie', 2012, 87, N'Animación', N'Emotivo', N'Tim Burton', N'Charlie Tahan', N'Catherine O''Hara', N'Martin Short', N'Un niño intenta recuperar a su querido perro.'),
(N'ParaNorman', 2012, 92, N'Animación', N'Divertido', N'Chris Butler', N'Kodi Smit-McPhee', N'Anna Kendrick', N'Christopher Mintz-Plasse', N'Un chico capaz de hablar con fantasmas salva su pueblo.'),
(N'Monster House', 2006, 91, N'Animación', N'Intrigante', N'Gil Kenan', N'Mitchel Musso', N'Sam Lerner', N'Spencer Locke', N'Tres amigos descubren que una casa esconde un secreto.'),
(N'Hotel Transylvania', 2012, 91, N'Animación', N'Divertido', N'Genndy Tartakovsky', N'Adam Sandler', N'Selena Gomez', N'Andy Samberg', N'Drácula administra un hotel para monstruos.'),
(N'Monsters Inc.', 2001, 92, N'Animación', N'Divertido', N'Pete Docter', N'John Goodman', N'Billy Crystal', N'Mary Gibbs', N'Dos monstruos descubren una nueva forma de generar energía.'),
(N'Monsters University', 2013, 104, N'Animación', N'Divertido', N'Dan Scanlon', N'Billy Crystal', N'John Goodman', N'Steve Buscemi', N'Dos estudiantes aprenden a trabajar juntos en la universidad.'),
(N'Finding Nemo', 2003, 100, N'Animación', N'Emotivo', N'Andrew Stanton', N'Albert Brooks', N'Ellen DeGeneres', N'Alexander Gould', N'Un pez recorre el océano buscando a su hijo.'),
(N'Finding Dory', 2016, 97, N'Animación', N'Emotivo', N'Andrew Stanton', N'Ellen DeGeneres', N'Albert Brooks', N'Ed O''Neill', N'Dory emprende una búsqueda para reencontrar a su familia.'),
(N'Ratatouille', 2007, 111, N'Animación', N'Inspirador', N'Brad Bird', N'Patton Oswalt', N'Ian Holm', N'Lou Romano', N'Una rata sueña con convertirse en chef en París.'),
(N'The Incredibles', 2004, 115, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Samuel L. Jackson', N'Una familia de superhéroes vuelve a la acción.'),
(N'Incredibles 2', 2018, 118, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Sarah Vowell', N'La familia de héroes enfrenta una nueva amenaza.'),
(N'Up', 2009, 96, N'Animación', N'Emotivo', N'Pete Docter', N'Ed Asner', N'Jordan Nagai', N'Christopher Plummer', N'Un anciano viaja en una casa impulsada por globos.'),
(N'Soul', 2020, 100, N'Animación', N'Reflexivo', N'Pete Docter', N'Jamie Foxx', N'Tina Fey', N'Graham Norton', N'Un músico descubre nuevas perspectivas sobre la vida.'),
(N'Turning Red', 2022, 100, N'Animación', N'Divertido', N'Domee Shi', N'Rosalie Chiang', N'Sandra Oh', N'Ava Morse', N'Una adolescente experimenta cambios familiares inesperados.'),
(N'Luca', 2021, 95, N'Animación', N'Alegre', N'Enrico Casarosa', N'Jacob Tremblay', N'Jack Dylan Grazer', N'Emma Berman', N'Dos amigos viven un verano inolvidable en Italia.'),
(N'Encanto', 2021, 102, N'Animación', N'Emotivo', N'Jared Bush', N'Stephanie Beatriz', N'María Cecilia Botero', N'John Leguizamo', N'Una joven busca su lugar en una familia extraordinaria.'),
(N'Moana', 2016, 107, N'Animación', N'Inspirador', N'Ron Clements', N'Auli''i Cravalho', N'Dwayne Johnson', N'Rachel House', N'Una joven navega para salvar a su isla.'),
(N'Frozen', 2013, 102, N'Animación', N'Emotivo', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Jonathan Groff', N'Dos hermanas buscan recuperar su vínculo.'),
(N'Frozen II', 2019, 103, N'Animación', N'Mágico', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Josh Gad', N'Dos hermanas exploran el origen de sus poderes.'),
(N'Tangled', 2010, 100, N'Animación', N'Divertido', N'Nathan Greno', N'Mandy Moore', N'Zachary Levi', N'Donna Murphy', N'Una princesa sale de su torre para descubrir el mundo.'),
(N'Zootopia', 2016, 108, N'Animación', N'Divertido', N'Byron Howard', N'Ginnifer Goodwin', N'Jason Bateman', N'Idris Elba', N'Una coneja policía investiga un caso junto a un zorro.'),
(N'Big Hero 6', 2014, 102, N'Animación', N'Emotivo', N'Don Hall', N'Ryan Potter', N'Scott Adsit', N'Jamie Chung', N'Un joven inventor y un robot forman un equipo de héroes.'),
(N'Wreck-It Ralph', 2012, 101, N'Animación', N'Divertido', N'Rich Moore', N'John C. Reilly', N'Sarah Silverman', N'Jack McBrayer', N'Un villano de videojuego quiere cambiar su historia.'),
(N'The Lego Movie', 2014, 100, N'Animación', N'Divertido', N'Phil Lord', N'Chris Pratt', N'Elizabeth Banks', N'Will Arnett', N'Un trabajador común termina en una gran aventura.'),
(N'Kung Fu Panda', 2008, 92, N'Animación', N'Inspirador', N'Mark Osborne', N'Jack Black', N'Dustin Hoffman', N'Angelina Jolie', N'Un panda aprende artes marciales para proteger su valle.'),
(N'How to Train Your Dragon', 2010, 98, N'Animación', N'Emotivo', N'Chris Sanders', N'Jay Baruchel', N'Gerard Butler', N'America Ferrera', N'Un joven vikingo entabla amistad con un dragón.'),
(N'How to Train Your Dragon 2', 2014, 102, N'Animación', N'Emocionante', N'Dean DeBlois', N'Jay Baruchel', N'Cate Blanchett', N'Gerard Butler', N'Hipo y Chimuelo descubren nuevos dragones y peligros.'),
(N'Puss in Boots: The Last Wish', 2022, 102, N'Animación', N'Emotivo', N'Joel Crawford', N'Antonio Banderas', N'Salma Hayek', N'Harvey Guillén', N'El Gato con Botas busca recuperar sus vidas perdidas.'),
(N'Shrek 2', 2004, 93, N'Animación', N'Divertido', N'Andrew Adamson', N'Mike Myers', N'Eddie Murphy', N'Cameron Diaz', N'Shrek conoce a la familia de Fiona.'),
(N'Madagascar', 2005, 86, N'Animación', N'Divertido', N'Eric Darnell', N'Ben Stiller', N'Chris Rock', N'David Schwimmer', N'Un grupo de animales del zoológico llega a una isla.'),
(N'Despicable Me', 2010, 95, N'Animación', N'Divertido', N'Pierre Coffin', N'Steve Carell', N'Jason Segel', N'Miranda Cosgrove', N'Un villano conoce a tres niñas que cambian sus planes.'),
(N'Minions', 2015, 91, N'Animación', N'Divertido', N'Pierre Coffin', N'Sandra Bullock', N'Jon Hamm', N'Michael Keaton', N'Los minions buscan a un nuevo jefe.'),
(N'The Iron Giant', 1999, 86, N'Animación', N'Emotivo', N'Brad Bird', N'Eli Marienthal', N'Vin Diesel', N'Jennifer Aniston', N'Un niño se hace amigo de un robot gigante.'),
(N'Klaus', 2019, 96, N'Animación', N'Emotivo', N'Sergio Pablos', N'Jason Schwartzman', N'J.K. Simmons', N'Rashida Jones', N'Un cartero transforma un pueblo con ayuda de un juguetero.'),
(N'The Mitchells vs. the Machines', 2021, 114, N'Animación', N'Divertido', N'Mike Rianda', N'Abbi Jacobson', N'Danny McBride', N'Maya Rudolph', N'Una familia debe salvar el mundo de una rebelión tecnológica.'),
(N'Your Name', 2016, 106, N'Animación', N'Melancólico', N'Makoto Shinkai', N'Ryunosuke Kamiki', N'Mone Kamishiraishi', N'Ryo Narita', N'Dos adolescentes descubren una conexión extraordinaria.'),
(N'Weathering with You', 2019, 112, N'Animación', N'Emotivo', N'Makoto Shinkai', N'Kotaro Daigo', N'Nana Mori', N'Shun Oguri', N'Un joven conoce a una chica capaz de cambiar el clima.'),
(N'Suzume', 2022, 122, N'Animación', N'Mágico', N'Makoto Shinkai', N'Nanoka Hara', N'Hokuto Matsumura', N'Eri Fukatsu', N'Una joven emprende un viaje para cerrar puertas misteriosas.'),
(N'Princess Mononoke', 1997, 134, N'Animación', N'Épico', N'Hayao Miyazaki', N'Yoji Matsuda', N'Yuriko Ishida', N'Yuko Tanaka', N'Un príncipe se involucra en un conflicto entre naturaleza y humanos.'),
(N'My Neighbor Totoro', 1988, 86, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Noriko Hidaka', N'Chika Sakamoto', N'Hitoshi Takagi', N'Dos hermanas descubren criaturas mágicas en el bosque.'),
(N'Kiki''s Delivery Service', 1989, 103, N'Animación', N'Alegre', N'Hayao Miyazaki', N'Minami Takayama', N'Rei Sakuma', N'Kappei Yamaguchi', N'Una joven bruja comienza a vivir por su cuenta.'),
(N'Howl''s Moving Castle', 2004, 119, N'Animación', N'Mágico', N'Hayao Miyazaki', N'Chieko Baisho', N'Takuya Kimura', N'Akihiro Miwa', N'Una joven encuentra refugio en un castillo ambulante.'),
(N'Ponyo', 2008, 101, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Yuria Nara', N'Hiroki Doi', N'Tomoko Yamaguchi', N'Una criatura marina quiere vivir entre humanos.'),
(N'The Boy and the Heron', 2023, 124, N'Animación', N'Reflexivo', N'Hayao Miyazaki', N'Soma Santoki', N'Masaki Suda', N'Ko Shibasaki', N'Un joven entra en un mundo fantástico tras una pérdida.'),
(N'The Wind Rises', 2013, 126, N'Animación', N'Melancólico', N'Hayao Miyazaki', N'Hideaki Anno', N'Miori Takimoto', N'Hidetoshi Nishijima', N'Un diseñador de aviones persigue sus sueños.'),
(N'The Tale of the Princess Kaguya', 2013, 137, N'Animación', N'Melancólico', N'Isao Takahata', N'Aki Asakura', N'Kengo Kora', N'Takeo Chii', N'Una niña misteriosa crece en una familia campesina.'),
(N'Grave of the Fireflies', 1988, 89, N'Animación', N'Triste', N'Isao Takahata', N'Tsutomu Tatsumi', N'Ayano Shiraishi', N'Yoshiko Shinohara', N'Dos hermanos intentan sobrevivir durante la guerra.'),
(N'The Grand Budapest Hotel', 2014, 99, N'Comedia', N'Divertido', N'Wes Anderson', N'Ralph Fiennes', N'Tony Revolori', N'Saoirse Ronan', N'Un conserje y su aprendiz viven una aventura extravagante.'),
(N'Fantastic Mr. Fox', 2009, 87, N'Animación', N'Divertido', N'Wes Anderson', N'George Clooney', N'Meryl Streep', N'Jason Schwartzman', N'Un zorro ingenioso desafía a tres granjeros.'),
(N'Isle of Dogs', 2018, 101, N'Animación', N'Emotivo', N'Wes Anderson', N'Bryan Cranston', N'Koyu Rankin', N'Edward Norton', N'Un niño busca a su perro en una isla remota.'),
(N'Moonrise Kingdom', 2012, 94, N'Romance', N'Tierno', N'Wes Anderson', N'Jared Gilman', N'Kara Hayward', N'Bruce Willis', N'Dos jóvenes se escapan juntos y movilizan a su comunidad.'),
(N'The Royal Tenenbaums', 2001, 110, N'Comedia', N'Melancólico', N'Wes Anderson', N'Gene Hackman', N'Gwyneth Paltrow', N'Ben Stiller', N'Una familia excéntrica se reúne después de años.'),
(N'Little Miss Sunshine', 2006, 101, N'Comedia', N'Inspirador', N'Jonathan Dayton', N'Abigail Breslin', N'Greg Kinnear', N'Toni Collette', N'Una familia viaja para acompañar a una niña a un concurso.'),
(N'Juno', 2007, 96, N'Comedia', N'Reflexivo', N'Jason Reitman', N'Elliot Page', N'Michael Cera', N'Jennifer Garner', N'Una adolescente afronta decisiones importantes con humor.'),
(N'Lady Bird', 2017, 94, N'Drama', N'Reflexivo', N'Greta Gerwig', N'Saoirse Ronan', N'Laurie Metcalf', N'Timothée Chalamet', N'Una joven busca independencia durante su último año escolar.'),
(N'Barbie', 2023, 114, N'Comedia', N'Reflexivo', N'Greta Gerwig', N'Margot Robbie', N'Ryan Gosling', N'America Ferrera', N'Barbie explora el mundo real y cuestiona su identidad.'),
(N'Little Women', 2019, 135, N'Drama', N'Emotivo', N'Greta Gerwig', N'Saoirse Ronan', N'Florence Pugh', N'Emma Watson', N'Cuatro hermanas persiguen sus sueños y crecen juntas.'),
(N'Pride & Prejudice', 2005, 129, N'Romance', N'Romántico', N'Joe Wright', N'Keira Knightley', N'Matthew Macfadyen', N'Rosamund Pike', N'Una joven desafía las convenciones sociales y se enamora.'),
(N'Atonement', 2007, 123, N'Romance', N'Melancólico', N'Joe Wright', N'Keira Knightley', N'James McAvoy', N'Saoirse Ronan', N'Una acusación altera el destino de dos enamorados.'),
(N'The Notebook', 2004, 123, N'Romance', N'Romántico', N'Nick Cassavetes', N'Ryan Gosling', N'Rachel McAdams', N'James Garner', N'Una pareja vive una historia de amor a través de los años.'),
(N'About Time', 2013, 123, N'Romance', N'Emotivo', N'Richard Curtis', N'Domhnall Gleeson', N'Rachel McAdams', N'Bill Nighy', N'Un joven usa un don familiar para comprender el amor y la vida.'),
(N'Notting Hill', 1999, 124, N'Romance', N'Romántico', N'Roger Michell', N'Julia Roberts', N'Hugh Grant', N'Rhys Ifans', N'Un librero conoce a una estrella de cine.'),
(N'Love Actually', 2003, 135, N'Romance', N'Emotivo', N'Richard Curtis', N'Hugh Grant', N'Emma Thompson', N'Liam Neeson', N'Varias historias de amor se cruzan durante las fiestas.'),
(N'10 Things I Hate About You', 1999, 97, N'Romance', N'Divertido', N'Gil Junger', N'Heath Ledger', N'Julia Stiles', N'Joseph Gordon-Levitt', N'Dos hermanas viven enredos románticos en la escuela.'),
(N'Crazy Rich Asians', 2018, 120, N'Romance', N'Divertido', N'Jon M. Chu', N'Constance Wu', N'Henry Golding', N'Michelle Yeoh', N'Una mujer conoce a la adinerada familia de su pareja.'),
(N'500 Days of Summer', 2009, 95, N'Romance', N'Melancólico', N'Marc Webb', N'Joseph Gordon-Levitt', N'Zooey Deschanel', N'Geoffrey Arend', N'Un joven recuerda una relación que cambió su vida.'),
(N'Eternal Sunshine of the Spotless Mind', 2004, 108, N'Romance', N'Melancólico', N'Michel Gondry', N'Jim Carrey', N'Kate Winslet', N'Kirsten Dunst', N'Una pareja reflexiona sobre recuerdos y relaciones.'),
(N'Her', 2013, 126, N'Romance', N'Melancólico', N'Spike Jonze', N'Joaquin Phoenix', N'Scarlett Johansson', N'Amy Adams', N'Un hombre desarrolla un vínculo inesperado con una inteligencia artificial.'),
(N'Before Sunrise', 1995, 101, N'Romance', N'Romántico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Andrea Eckert', N'Dos viajeros se conocen y pasan una noche conversando.'),
(N'Before Sunset', 2004, 80, N'Romance', N'Melancólico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Vernon Dobtcheff', N'Dos antiguos conocidos vuelven a encontrarse en París.'),
(N'Before Midnight', 2013, 109, N'Romance', N'Reflexivo', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Seamus Davey-Fitzpatrick', N'Una pareja reflexiona sobre el paso del tiempo.'),
(N'The Fault in Our Stars', 2014, 126, N'Romance', N'Emotivo', N'Josh Boone', N'Shailene Woodley', N'Ansel Elgort', N'Nat Wolff', N'Dos adolescentes comparten una historia de amor y esperanza.'),
(N'Me Before You', 2016, 110, N'Romance', N'Emotivo', N'Thea Sharrock', N'Emilia Clarke', N'Sam Claflin', N'Janet McTeer', N'Una cuidadora establece una conexión especial con un joven.'),
(N'Titanic', 1997, 194, N'Romance', N'Emotivo', N'James Cameron', N'Leonardo DiCaprio', N'Kate Winslet', N'Billy Zane', N'Dos jóvenes de clases diferentes se enamoran durante un viaje.'),
(N'Romeo + Juliet', 1996, 120, N'Romance', N'Romántico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Claire Danes', N'John Leguizamo', N'Dos jóvenes enamorados pertenecen a familias enfrentadas.'),
(N'Moulin Rouge!', 2001, 127, N'Romance', N'Melancólico', N'Baz Luhrmann', N'Nicole Kidman', N'Ewan McGregor', N'Jim Broadbent', N'Un escritor se enamora de una artista en París.'),
(N'The Great Gatsby', 2013, 143, N'Drama', N'Melancólico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Carey Mulligan', N'Tobey Maguire', N'Un millonario organiza fiestas mientras persigue un amor pasado.'),
(N'The Holiday', 2006, 136, N'Romance', N'Alegre', N'Nancy Meyers', N'Cameron Diaz', N'Kate Winslet', N'Jude Law', N'Dos mujeres intercambian casas y encuentran nuevas oportunidades.'),
(N'Pretty Woman', 1990, 119, N'Romance', N'Romántico', N'Garry Marshall', N'Julia Roberts', N'Richard Gere', N'Hector Elizondo', N'Dos personas de mundos distintos se conocen en Los Ángeles.'),
(N'When Harry Met Sally...', 1989, 96, N'Romance', N'Divertido', N'Rob Reiner', N'Billy Crystal', N'Meg Ryan', N'Carrie Fisher', N'Dos amigos se preguntan si la amistad puede convertirse en amor.'),
(N'Sleepless in Seattle', 1993, 105, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Ross Malinger', N'Una periodista se interesa por la historia de un padre viudo.'),
(N'You''ve Got Mail', 1998, 119, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Greg Kinnear', N'Dos rivales comerciales se conocen por mensajes anónimos.'),
(N'The Proposal', 2009, 108, N'Romance', N'Divertido', N'Anne Fletcher', N'Sandra Bullock', N'Ryan Reynolds', N'Betty White', N'Una editora y su asistente simulan una relación.'),
(N'Crazy Stupid Love', 2011, 118, N'Romance', N'Divertido', N'Glenn Ficarra', N'Steve Carell', N'Ryan Gosling', N'Julianne Moore', N'Varias historias sentimentales se cruzan de manera inesperada.'),
(N'The Devil Wears Prada', 2006, 109, N'Comedia', N'Divertido', N'David Frankel', N'Meryl Streep', N'Anne Hathaway', N'Emily Blunt', N'Una joven empieza a trabajar para una exigente editora.'),
(N'Mean Girls', 2004, 97, N'Comedia', N'Divertido', N'Mark Waters', N'Lindsay Lohan', N'Rachel McAdams', N'Tina Fey', N'Una estudiante nueva aprende las reglas sociales de su escuela.'),
(N'Clueless', 1995, 97, N'Comedia', N'Divertido', N'Amy Heckerling', N'Alicia Silverstone', N'Stacey Dash', N'Brittany Murphy', N'Una adolescente intenta organizar la vida amorosa de sus amigos.'),
(N'Legally Blonde', 2001, 96, N'Comedia', N'Inspirador', N'Robert Luketic', N'Reese Witherspoon', N'Luke Wilson', N'Selma Blair', N'Una joven desafía prejuicios al ingresar a Derecho.'),
(N'The Intern', 2015, 121, N'Comedia', N'Inspirador', N'Nancy Meyers', N'Robert De Niro', N'Anne Hathaway', N'Rene Russo', N'Un jubilado comienza una pasantía en una empresa moderna.'),
(N'The Hangover', 2009, 100, N'Comedia', N'Divertido', N'Todd Phillips', N'Bradley Cooper', N'Ed Helms', N'Zach Galifianakis', N'Tres amigos intentan reconstruir una noche en Las Vegas.'),
(N'21 Jump Street', 2012, 109, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Brie Larson', N'Dos policías se infiltran en una escuela secundaria.'),
(N'22 Jump Street', 2014, 112, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Ice Cube', N'Dos agentes se infiltran en una universidad.'),
(N'The 40-Year-Old Virgin', 2005, 116, N'Comedia', N'Divertido', N'Judd Apatow', N'Steve Carell', N'Catherine Keener', N'Paul Rudd', N'Los amigos de un hombre intentan ayudarlo a encontrar pareja.'),
(N'Bridesmaids', 2011, 125, N'Comedia', N'Divertido', N'Paul Feig', N'Kristen Wiig', N'Maya Rudolph', N'Rose Byrne', N'Una mujer organiza la boda de su mejor amiga.'),
(N'Game Night', 2018, 100, N'Comedia', N'Intrigante', N'John Francis Daley', N'Jason Bateman', N'Rachel McAdams', N'Kyle Chandler', N'Una noche de juegos se convierte en un misterio real.'),
(N'Knives Out', 2019, 130, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Ana de Armas', N'Chris Evans', N'Un detective investiga una muerte en una familia adinerada.'),
(N'Glass Onion: A Knives Out Mystery', 2022, 139, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Janelle Monáe', N'Edward Norton', N'Un detective resuelve un misterio en una isla privada.'),
(N'Gone Girl', 2014, 149, N'Suspenso', N'Intrigante', N'David Fincher', N'Ben Affleck', N'Rosamund Pike', N'Neil Patrick Harris', N'La desaparición de una mujer pone a su esposo bajo sospecha.'),
(N'Zodiac', 2007, 157, N'Suspenso', N'Intrigante', N'David Fincher', N'Jake Gyllenhaal', N'Mark Ruffalo', N'Robert Downey Jr.', N'Unos investigadores intentan descubrir la identidad de un criminal.'),
(N'The Social Network', 2010, 120, N'Drama', N'Reflexivo', N'David Fincher', N'Jesse Eisenberg', N'Andrew Garfield', N'Justin Timberlake', N'Un estudiante crea una red social que cambia su vida.'),
(N'The Girl with the Dragon Tattoo', 2011, 158, N'Suspenso', N'Oscuro', N'David Fincher', N'Daniel Craig', N'Rooney Mara', N'Christopher Plummer', N'Un periodista investiga un caso antiguo con una hacker.'),
(N'Prisoners', 2013, 153, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Hugh Jackman', N'Jake Gyllenhaal', N'Viola Davis', N'Un padre busca respuestas sobre la desaparición de su hija.'),
(N'Sicario', 2015, 121, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Emily Blunt', N'Benicio del Toro', N'Josh Brolin', N'Una agente participa en una operación contra el narcotráfico.'),
(N'Arrival', 2016, 116, N'Ciencia ficción', N'Reflexivo', N'Denis Villeneuve', N'Amy Adams', N'Jeremy Renner', N'Forest Whitaker', N'Una lingüista intenta comunicarse con visitantes extraterrestres.'),
(N'Blade Runner 2049', 2017, 164, N'Ciencia ficción', N'Melancólico', N'Denis Villeneuve', N'Ryan Gosling', N'Harrison Ford', N'Ana de Armas', N'Un agente descubre un secreto que podría cambiar la sociedad.'),
(N'Blade Runner', 1982, 117, N'Ciencia ficción', N'Reflexivo', N'Ridley Scott', N'Harrison Ford', N'Rutger Hauer', N'Sean Young', N'Un investigador persigue androides en una ciudad futurista.'),
(N'Ex Machina', 2014, 108, N'Ciencia ficción', N'Intrigante', N'Alex Garland', N'Domhnall Gleeson', N'Alicia Vikander', N'Oscar Isaac', N'Un programador evalúa una inteligencia artificial avanzada.'),
(N'Annihilation', 2018, 115, N'Ciencia ficción', N'Inquietante', N'Alex Garland', N'Natalie Portman', N'Jennifer Jason Leigh', N'Tessa Thompson', N'Un equipo explora una zona de extrañas transformaciones.'),
(N'District 9', 2009, 112, N'Ciencia ficción', N'Intenso', N'Neill Blomkamp', N'Sharlto Copley', N'Jason Cope', N'David James', N'Un funcionario se involucra en un conflicto con extraterrestres.'),
(N'Elysium', 2013, 109, N'Ciencia ficción', N'Emocionante', N'Neill Blomkamp', N'Matt Damon', N'Jodie Foster', N'Sharlto Copley', N'Un trabajador intenta llegar a una estación espacial exclusiva.'),
(N'Edge of Tomorrow', 2014, 113, N'Ciencia ficción', N'Emocionante', N'Doug Liman', N'Tom Cruise', N'Emily Blunt', N'Bill Paxton', N'Un soldado revive el mismo día durante una invasión.'),
(N'Source Code', 2011, 93, N'Ciencia ficción', N'Intrigante', N'Duncan Jones', N'Jake Gyllenhaal', N'Michelle Monaghan', N'Vera Farmiga', N'Un soldado revive minutos de un viaje para resolver un misterio.'),
(N'Moon', 2009, 97, N'Ciencia ficción', N'Reflexivo', N'Duncan Jones', N'Sam Rockwell', N'Kevin Spacey', N'Dominique McElligott', N'Un astronauta descubre secretos durante una misión lunar.'),
(N'Looper', 2012, 119, N'Ciencia ficción', N'Intrigante', N'Rian Johnson', N'Joseph Gordon-Levitt', N'Bruce Willis', N'Emily Blunt', N'Un hombre se enfrenta a una versión futura de sí mismo.'),
(N'Minority Report', 2002, 145, N'Ciencia ficción', N'Intrigante', N'Steven Spielberg', N'Tom Cruise', N'Colin Farrell', N'Samantha Morton', N'Un policía investiga delitos antes de que ocurran.'),
(N'Ready Player One', 2018, 140, N'Ciencia ficción', N'Emocionante', N'Steven Spielberg', N'Tye Sheridan', N'Olivia Cooke', N'Ben Mendelsohn', N'Un joven compite por un premio en un universo virtual.'),
(N'A.I. Artificial Intelligence', 2001, 146, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Haley Joel Osment', N'Jude Law', N'Frances O''Connor', N'Un niño robot busca encontrar su lugar en el mundo.'),
(N'E.T. the Extra-Terrestrial', 1982, 115, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Henry Thomas', N'Drew Barrymore', N'Dee Wallace', N'Un niño ayuda a un extraterrestre a regresar a casa.'),
(N'Close Encounters of the Third Kind', 1977, 138, N'Ciencia ficción', N'Mágico', N'Steven Spielberg', N'Richard Dreyfuss', N'François Truffaut', N'Teri Garr', N'Un hombre se obsesiona con extraños encuentros en el cielo.'),
(N'War of the Worlds', 2005, 116, N'Ciencia ficción', N'Tenso', N'Steven Spielberg', N'Tom Cruise', N'Dakota Fanning', N'Tim Robbins', N'Un padre protege a sus hijos durante una invasión.'),
(N'The Martian', 2015, 144, N'Ciencia ficción', N'Inspirador', N'Ridley Scott', N'Matt Damon', N'Jessica Chastain', N'Chiwetel Ejiofor', N'Un astronauta intenta sobrevivir solo en Marte.'),
(N'Gravity', 2013, 91, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Sandra Bullock', N'George Clooney', N'Ed Harris', N'Dos astronautas enfrentan una emergencia en órbita.'),
(N'Children of Men', 2006, 109, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Clive Owen', N'Julianne Moore', N'Michael Caine', N'Un hombre protege a una joven en un futuro incierto.'),
(N'Pacific Rim', 2013, 131, N'Ciencia ficción', N'Épico', N'Guillermo del Toro', N'Charlie Hunnam', N'Idris Elba', N'Rinko Kikuchi', N'Pilotos de robots gigantes defienden la Tierra.'),
(N'The Shape of Water', 2017, 123, N'Fantasía', N'Romántico', N'Guillermo del Toro', N'Sally Hawkins', N'Michael Shannon', N'Richard Jenkins', N'Una mujer descubre una criatura extraordinaria en un laboratorio.')
) AS V(Titulo, Anio, DuracionMinutos, Genero, Animo, Director, Actor1, Actor2, Actor3, Sinopsis)
WHERE NOT EXISTS (SELECT 1 FROM Directores D WHERE D.Nombre = V.Director);

-- PELÍCULAS NUEVAS
INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, IdDirector, PosterUrl)
SELECT V.Titulo, V.Sinopsis, V.Genero, V.DuracionMinutos, V.Anio, V.Animo,
       (SELECT TOP 1 D.IdDirector FROM Directores D WHERE D.Nombre = V.Director ORDER BY D.IdDirector), NULL
FROM (VALUES
(N'Alien', 1979, 117, N'Terror', N'Tenebroso', N'Ridley Scott', N'Sigourney Weaver', N'Tom Skerritt', N'John Hurt', N'Una tripulación espacial encuentra una amenaza desconocida.'),
(N'Aliens', 1986, 137, N'Ciencia ficción', N'Intenso', N'James Cameron', N'Sigourney Weaver', N'Michael Biehn', N'Bill Paxton', N'Ripley regresa a un planeta ocupado por criaturas peligrosas.'),
(N'The Thing', 1982, 109, N'Terror', N'Tenebroso', N'John Carpenter', N'Kurt Russell', N'Keith David', N'Wilford Brimley', N'Un equipo aislado enfrenta una criatura capaz de imitar personas.'),
(N'Halloween', 1978, 91, N'Terror', N'Tenebroso', N'John Carpenter', N'Jamie Lee Curtis', N'Donald Pleasence', N'Nancy Kyes', N'Una comunidad vive una noche de miedo ante un asesino enmascarado.'),
(N'Scream', 1996, 111, N'Terror', N'Intrigante', N'Wes Craven', N'Neve Campbell', N'Courteney Cox', N'David Arquette', N'Una adolescente intenta descubrir quién aterroriza su pueblo.'),
(N'The Conjuring', 2013, 112, N'Terror', N'Tenebroso', N'James Wan', N'Vera Farmiga', N'Patrick Wilson', N'Lili Taylor', N'Dos investigadores estudian sucesos extraños en una casa.'),
(N'Insidious', 2010, 103, N'Terror', N'Tenebroso', N'James Wan', N'Patrick Wilson', N'Rose Byrne', N'Lin Shaye', N'Una familia busca respuestas a fenómenos inexplicables.'),
(N'Get Out', 2017, 104, N'Terror', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Allison Williams', N'Bradley Whitford', N'Un joven descubre inquietantes secretos durante una visita familiar.'),
(N'Us', 2019, 116, N'Terror', N'Tenebroso', N'Jordan Peele', N'Lupita Nyong''o', N'Winston Duke', N'Elisabeth Moss', N'Una familia se enfrenta a visitantes idénticos a ellos.'),
(N'Nope', 2022, 130, N'Ciencia ficción', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Keke Palmer', N'Steven Yeun', N'Dos hermanos investigan un fenómeno extraño en el cielo.'),
(N'Hereditary', 2018, 127, N'Terror', N'Tenebroso', N'Ari Aster', N'Toni Collette', N'Alex Wolff', N'Gabriel Byrne', N'Una familia descubre secretos perturbadores de su pasado.'),
(N'Midsommar', 2019, 148, N'Terror', N'Inquietante', N'Ari Aster', N'Florence Pugh', N'Jack Reynor', N'William Jackson Harper', N'Un viaje a un festival remoto toma un giro inquietante.'),
(N'The Witch', 2015, 92, N'Terror', N'Tenebroso', N'Robert Eggers', N'Anya Taylor-Joy', N'Ralph Ineson', N'Kate Dickie', N'Una familia puritana enfrenta sucesos misteriosos.'),
(N'The Lighthouse', 2019, 109, N'Drama', N'Oscuro', N'Robert Eggers', N'Robert Pattinson', N'Willem Dafoe', N'Valeriia Karaman', N'Dos fareros aislados empiezan a desconfiar entre sí.'),
(N'The Babadook', 2014, 94, N'Terror', N'Tenebroso', N'Jennifer Kent', N'Essie Davis', N'Noah Wiseman', N'Daniel Henshall', N'Una madre y su hijo temen a una presencia misteriosa.'),
(N'A Quiet Place', 2018, 90, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'John Krasinski', N'Millicent Simmonds', N'Una familia debe vivir en silencio para sobrevivir.'),
(N'A Quiet Place Part II', 2020, 97, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'Cillian Murphy', N'Millicent Simmonds', N'Una familia continúa su camino por un mundo peligroso.'),
(N'It', 2017, 135, N'Terror', N'Tenebroso', N'Andy Muschietti', N'Jaeden Martell', N'Sophia Lillis', N'Bill Skarsgård', N'Un grupo de amigos investiga desapariciones en su pueblo.'),
(N'The Ring', 2002, 115, N'Terror', N'Tenebroso', N'Gore Verbinski', N'Naomi Watts', N'Martin Henderson', N'David Dorfman', N'Una periodista investiga una misteriosa grabación.'),
(N'The Others', 2001, 104, N'Terror', N'Intrigante', N'Alejandro Amenábar', N'Nicole Kidman', N'Fionnula Flanagan', N'Christopher Eccleston', N'Una madre percibe sucesos inexplicables en su mansión.'),
(N'The Blair Witch Project', 1999, 81, N'Terror', N'Tenebroso', N'Daniel Myrick', N'Heather Donahue', N'Michael C. Williams', N'Joshua Leonard', N'Tres estudiantes se pierden mientras filman un documental.'),
(N'Paranormal Activity', 2007, 86, N'Terror', N'Tenebroso', N'Oren Peli', N'Katie Featherston', N'Micah Sloat', N'Mark Fredrichs', N'Una pareja registra extraños sucesos en su hogar.'),
(N'The Descent', 2005, 99, N'Terror', N'Tenso', N'Neil Marshall', N'Shauna Macdonald', N'Natalie Mendoza', N'Alex Reid', N'Un grupo de amigas queda atrapado en unas cuevas.'),
(N'Saw', 2004, 103, N'Terror', N'Intrigante', N'James Wan', N'Cary Elwes', N'Leigh Whannell', N'Danny Glover', N'Dos desconocidos deben resolver un misterio para escapar.'),
(N'Final Destination', 2000, 98, N'Terror', N'Tenso', N'James Wong', N'Devon Sawa', N'Ali Larter', N'Kerr Smith', N'Un joven presiente un accidente y altera un destino.'),
(N'The Sixth Sense', 1999, 107, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bruce Willis', N'Haley Joel Osment', N'Toni Collette', N'Un psicólogo intenta ayudar a un niño con un secreto.'),
(N'Split', 2016, 117, N'Suspenso', N'Tenso', N'M. Night Shyamalan', N'James McAvoy', N'Anya Taylor-Joy', N'Betty Buckley', N'Tres jóvenes intentan comprender a su captor.'),
(N'Signs', 2002, 106, N'Ciencia ficción', N'Intrigante', N'M. Night Shyamalan', N'Mel Gibson', N'Joaquin Phoenix', N'Rory Culkin', N'Una familia descubre marcas inexplicables en sus cultivos.'),
(N'The Village', 2004, 108, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bryce Dallas Howard', N'Joaquin Phoenix', N'Adrien Brody', N'Una comunidad aislada teme lo que habita el bosque.'),
(N'The Shining', 1980, 146, N'Terror', N'Tenebroso', N'Stanley Kubrick', N'Jack Nicholson', N'Shelley Duvall', N'Danny Lloyd', N'Un cuidador y su familia pasan el invierno en un hotel aislado.'),
(N'Doctor Sleep', 2019, 152, N'Terror', N'Tenebroso', N'Mike Flanagan', N'Ewan McGregor', N'Rebecca Ferguson', N'Kyliegh Curran', N'Un hombre con habilidades especiales ayuda a una niña.'),
(N'Carrie', 1976, 98, N'Terror', N'Intenso', N'Brian De Palma', N'Sissy Spacek', N'Piper Laurie', N'Amy Irving', N'Una adolescente descubre un poder que no comprende.'),
(N'Rosemary''s Baby', 1968, 137, N'Terror', N'Inquietante', N'Roman Polanski', N'Mia Farrow', N'John Cassavetes', N'Ruth Gordon', N'Una mujer sospecha de sus nuevos vecinos.'),
(N'The Exorcist', 1973, 122, N'Terror', N'Tenebroso', N'William Friedkin', N'Ellen Burstyn', N'Linda Blair', N'Max von Sydow', N'Una madre busca ayuda ante sucesos extraños con su hija.'),
(N'The Texas Chain Saw Massacre', 1974, 83, N'Terror', N'Tenso', N'Tobe Hooper', N'Marilyn Burns', N'Paul A. Partain', N'Edwin Neal', N'Un grupo de viajeros se encuentra con una familia aterradora.'),
(N'The Nightmare Before Christmas', 1993, 76, N'Animación', N'Mágico', N'Henry Selick', N'Chris Sarandon', N'Catherine O''Hara', N'Danny Elfman', N'El rey de Halloween descubre la celebración navideña.'),
(N'Coraline', 2009, 100, N'Animación', N'Tenebroso', N'Henry Selick', N'Dakota Fanning', N'Teri Hatcher', N'John Hodgman', N'Una niña encuentra una puerta hacia un mundo alternativo.'),
(N'Corpse Bride', 2005, 77, N'Animación', N'Melancólico', N'Tim Burton', N'Johnny Depp', N'Helena Bonham Carter', N'Emily Watson', N'Un joven entra accidentalmente en el mundo de los muertos.'),
(N'Frankenweenie', 2012, 87, N'Animación', N'Emotivo', N'Tim Burton', N'Charlie Tahan', N'Catherine O''Hara', N'Martin Short', N'Un niño intenta recuperar a su querido perro.'),
(N'ParaNorman', 2012, 92, N'Animación', N'Divertido', N'Chris Butler', N'Kodi Smit-McPhee', N'Anna Kendrick', N'Christopher Mintz-Plasse', N'Un chico capaz de hablar con fantasmas salva su pueblo.'),
(N'Monster House', 2006, 91, N'Animación', N'Intrigante', N'Gil Kenan', N'Mitchel Musso', N'Sam Lerner', N'Spencer Locke', N'Tres amigos descubren que una casa esconde un secreto.'),
(N'Hotel Transylvania', 2012, 91, N'Animación', N'Divertido', N'Genndy Tartakovsky', N'Adam Sandler', N'Selena Gomez', N'Andy Samberg', N'Drácula administra un hotel para monstruos.'),
(N'Monsters Inc.', 2001, 92, N'Animación', N'Divertido', N'Pete Docter', N'John Goodman', N'Billy Crystal', N'Mary Gibbs', N'Dos monstruos descubren una nueva forma de generar energía.'),
(N'Monsters University', 2013, 104, N'Animación', N'Divertido', N'Dan Scanlon', N'Billy Crystal', N'John Goodman', N'Steve Buscemi', N'Dos estudiantes aprenden a trabajar juntos en la universidad.'),
(N'Finding Nemo', 2003, 100, N'Animación', N'Emotivo', N'Andrew Stanton', N'Albert Brooks', N'Ellen DeGeneres', N'Alexander Gould', N'Un pez recorre el océano buscando a su hijo.'),
(N'Finding Dory', 2016, 97, N'Animación', N'Emotivo', N'Andrew Stanton', N'Ellen DeGeneres', N'Albert Brooks', N'Ed O''Neill', N'Dory emprende una búsqueda para reencontrar a su familia.'),
(N'Ratatouille', 2007, 111, N'Animación', N'Inspirador', N'Brad Bird', N'Patton Oswalt', N'Ian Holm', N'Lou Romano', N'Una rata sueña con convertirse en chef en París.'),
(N'The Incredibles', 2004, 115, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Samuel L. Jackson', N'Una familia de superhéroes vuelve a la acción.'),
(N'Incredibles 2', 2018, 118, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Sarah Vowell', N'La familia de héroes enfrenta una nueva amenaza.'),
(N'Up', 2009, 96, N'Animación', N'Emotivo', N'Pete Docter', N'Ed Asner', N'Jordan Nagai', N'Christopher Plummer', N'Un anciano viaja en una casa impulsada por globos.'),
(N'Soul', 2020, 100, N'Animación', N'Reflexivo', N'Pete Docter', N'Jamie Foxx', N'Tina Fey', N'Graham Norton', N'Un músico descubre nuevas perspectivas sobre la vida.'),
(N'Turning Red', 2022, 100, N'Animación', N'Divertido', N'Domee Shi', N'Rosalie Chiang', N'Sandra Oh', N'Ava Morse', N'Una adolescente experimenta cambios familiares inesperados.'),
(N'Luca', 2021, 95, N'Animación', N'Alegre', N'Enrico Casarosa', N'Jacob Tremblay', N'Jack Dylan Grazer', N'Emma Berman', N'Dos amigos viven un verano inolvidable en Italia.'),
(N'Encanto', 2021, 102, N'Animación', N'Emotivo', N'Jared Bush', N'Stephanie Beatriz', N'María Cecilia Botero', N'John Leguizamo', N'Una joven busca su lugar en una familia extraordinaria.'),
(N'Moana', 2016, 107, N'Animación', N'Inspirador', N'Ron Clements', N'Auli''i Cravalho', N'Dwayne Johnson', N'Rachel House', N'Una joven navega para salvar a su isla.'),
(N'Frozen', 2013, 102, N'Animación', N'Emotivo', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Jonathan Groff', N'Dos hermanas buscan recuperar su vínculo.'),
(N'Frozen II', 2019, 103, N'Animación', N'Mágico', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Josh Gad', N'Dos hermanas exploran el origen de sus poderes.'),
(N'Tangled', 2010, 100, N'Animación', N'Divertido', N'Nathan Greno', N'Mandy Moore', N'Zachary Levi', N'Donna Murphy', N'Una princesa sale de su torre para descubrir el mundo.'),
(N'Zootopia', 2016, 108, N'Animación', N'Divertido', N'Byron Howard', N'Ginnifer Goodwin', N'Jason Bateman', N'Idris Elba', N'Una coneja policía investiga un caso junto a un zorro.'),
(N'Big Hero 6', 2014, 102, N'Animación', N'Emotivo', N'Don Hall', N'Ryan Potter', N'Scott Adsit', N'Jamie Chung', N'Un joven inventor y un robot forman un equipo de héroes.'),
(N'Wreck-It Ralph', 2012, 101, N'Animación', N'Divertido', N'Rich Moore', N'John C. Reilly', N'Sarah Silverman', N'Jack McBrayer', N'Un villano de videojuego quiere cambiar su historia.'),
(N'The Lego Movie', 2014, 100, N'Animación', N'Divertido', N'Phil Lord', N'Chris Pratt', N'Elizabeth Banks', N'Will Arnett', N'Un trabajador común termina en una gran aventura.'),
(N'Kung Fu Panda', 2008, 92, N'Animación', N'Inspirador', N'Mark Osborne', N'Jack Black', N'Dustin Hoffman', N'Angelina Jolie', N'Un panda aprende artes marciales para proteger su valle.'),
(N'How to Train Your Dragon', 2010, 98, N'Animación', N'Emotivo', N'Chris Sanders', N'Jay Baruchel', N'Gerard Butler', N'America Ferrera', N'Un joven vikingo entabla amistad con un dragón.'),
(N'How to Train Your Dragon 2', 2014, 102, N'Animación', N'Emocionante', N'Dean DeBlois', N'Jay Baruchel', N'Cate Blanchett', N'Gerard Butler', N'Hipo y Chimuelo descubren nuevos dragones y peligros.'),
(N'Puss in Boots: The Last Wish', 2022, 102, N'Animación', N'Emotivo', N'Joel Crawford', N'Antonio Banderas', N'Salma Hayek', N'Harvey Guillén', N'El Gato con Botas busca recuperar sus vidas perdidas.'),
(N'Shrek 2', 2004, 93, N'Animación', N'Divertido', N'Andrew Adamson', N'Mike Myers', N'Eddie Murphy', N'Cameron Diaz', N'Shrek conoce a la familia de Fiona.'),
(N'Madagascar', 2005, 86, N'Animación', N'Divertido', N'Eric Darnell', N'Ben Stiller', N'Chris Rock', N'David Schwimmer', N'Un grupo de animales del zoológico llega a una isla.'),
(N'Despicable Me', 2010, 95, N'Animación', N'Divertido', N'Pierre Coffin', N'Steve Carell', N'Jason Segel', N'Miranda Cosgrove', N'Un villano conoce a tres niñas que cambian sus planes.'),
(N'Minions', 2015, 91, N'Animación', N'Divertido', N'Pierre Coffin', N'Sandra Bullock', N'Jon Hamm', N'Michael Keaton', N'Los minions buscan a un nuevo jefe.'),
(N'The Iron Giant', 1999, 86, N'Animación', N'Emotivo', N'Brad Bird', N'Eli Marienthal', N'Vin Diesel', N'Jennifer Aniston', N'Un niño se hace amigo de un robot gigante.'),
(N'Klaus', 2019, 96, N'Animación', N'Emotivo', N'Sergio Pablos', N'Jason Schwartzman', N'J.K. Simmons', N'Rashida Jones', N'Un cartero transforma un pueblo con ayuda de un juguetero.'),
(N'The Mitchells vs. the Machines', 2021, 114, N'Animación', N'Divertido', N'Mike Rianda', N'Abbi Jacobson', N'Danny McBride', N'Maya Rudolph', N'Una familia debe salvar el mundo de una rebelión tecnológica.'),
(N'Your Name', 2016, 106, N'Animación', N'Melancólico', N'Makoto Shinkai', N'Ryunosuke Kamiki', N'Mone Kamishiraishi', N'Ryo Narita', N'Dos adolescentes descubren una conexión extraordinaria.'),
(N'Weathering with You', 2019, 112, N'Animación', N'Emotivo', N'Makoto Shinkai', N'Kotaro Daigo', N'Nana Mori', N'Shun Oguri', N'Un joven conoce a una chica capaz de cambiar el clima.'),
(N'Suzume', 2022, 122, N'Animación', N'Mágico', N'Makoto Shinkai', N'Nanoka Hara', N'Hokuto Matsumura', N'Eri Fukatsu', N'Una joven emprende un viaje para cerrar puertas misteriosas.'),
(N'Princess Mononoke', 1997, 134, N'Animación', N'Épico', N'Hayao Miyazaki', N'Yoji Matsuda', N'Yuriko Ishida', N'Yuko Tanaka', N'Un príncipe se involucra en un conflicto entre naturaleza y humanos.'),
(N'My Neighbor Totoro', 1988, 86, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Noriko Hidaka', N'Chika Sakamoto', N'Hitoshi Takagi', N'Dos hermanas descubren criaturas mágicas en el bosque.'),
(N'Kiki''s Delivery Service', 1989, 103, N'Animación', N'Alegre', N'Hayao Miyazaki', N'Minami Takayama', N'Rei Sakuma', N'Kappei Yamaguchi', N'Una joven bruja comienza a vivir por su cuenta.'),
(N'Howl''s Moving Castle', 2004, 119, N'Animación', N'Mágico', N'Hayao Miyazaki', N'Chieko Baisho', N'Takuya Kimura', N'Akihiro Miwa', N'Una joven encuentra refugio en un castillo ambulante.'),
(N'Ponyo', 2008, 101, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Yuria Nara', N'Hiroki Doi', N'Tomoko Yamaguchi', N'Una criatura marina quiere vivir entre humanos.'),
(N'The Boy and the Heron', 2023, 124, N'Animación', N'Reflexivo', N'Hayao Miyazaki', N'Soma Santoki', N'Masaki Suda', N'Ko Shibasaki', N'Un joven entra en un mundo fantástico tras una pérdida.'),
(N'The Wind Rises', 2013, 126, N'Animación', N'Melancólico', N'Hayao Miyazaki', N'Hideaki Anno', N'Miori Takimoto', N'Hidetoshi Nishijima', N'Un diseñador de aviones persigue sus sueños.'),
(N'The Tale of the Princess Kaguya', 2013, 137, N'Animación', N'Melancólico', N'Isao Takahata', N'Aki Asakura', N'Kengo Kora', N'Takeo Chii', N'Una niña misteriosa crece en una familia campesina.'),
(N'Grave of the Fireflies', 1988, 89, N'Animación', N'Triste', N'Isao Takahata', N'Tsutomu Tatsumi', N'Ayano Shiraishi', N'Yoshiko Shinohara', N'Dos hermanos intentan sobrevivir durante la guerra.'),
(N'The Grand Budapest Hotel', 2014, 99, N'Comedia', N'Divertido', N'Wes Anderson', N'Ralph Fiennes', N'Tony Revolori', N'Saoirse Ronan', N'Un conserje y su aprendiz viven una aventura extravagante.'),
(N'Fantastic Mr. Fox', 2009, 87, N'Animación', N'Divertido', N'Wes Anderson', N'George Clooney', N'Meryl Streep', N'Jason Schwartzman', N'Un zorro ingenioso desafía a tres granjeros.'),
(N'Isle of Dogs', 2018, 101, N'Animación', N'Emotivo', N'Wes Anderson', N'Bryan Cranston', N'Koyu Rankin', N'Edward Norton', N'Un niño busca a su perro en una isla remota.'),
(N'Moonrise Kingdom', 2012, 94, N'Romance', N'Tierno', N'Wes Anderson', N'Jared Gilman', N'Kara Hayward', N'Bruce Willis', N'Dos jóvenes se escapan juntos y movilizan a su comunidad.'),
(N'The Royal Tenenbaums', 2001, 110, N'Comedia', N'Melancólico', N'Wes Anderson', N'Gene Hackman', N'Gwyneth Paltrow', N'Ben Stiller', N'Una familia excéntrica se reúne después de años.'),
(N'Little Miss Sunshine', 2006, 101, N'Comedia', N'Inspirador', N'Jonathan Dayton', N'Abigail Breslin', N'Greg Kinnear', N'Toni Collette', N'Una familia viaja para acompañar a una niña a un concurso.'),
(N'Juno', 2007, 96, N'Comedia', N'Reflexivo', N'Jason Reitman', N'Elliot Page', N'Michael Cera', N'Jennifer Garner', N'Una adolescente afronta decisiones importantes con humor.'),
(N'Lady Bird', 2017, 94, N'Drama', N'Reflexivo', N'Greta Gerwig', N'Saoirse Ronan', N'Laurie Metcalf', N'Timothée Chalamet', N'Una joven busca independencia durante su último año escolar.'),
(N'Barbie', 2023, 114, N'Comedia', N'Reflexivo', N'Greta Gerwig', N'Margot Robbie', N'Ryan Gosling', N'America Ferrera', N'Barbie explora el mundo real y cuestiona su identidad.'),
(N'Little Women', 2019, 135, N'Drama', N'Emotivo', N'Greta Gerwig', N'Saoirse Ronan', N'Florence Pugh', N'Emma Watson', N'Cuatro hermanas persiguen sus sueños y crecen juntas.'),
(N'Pride & Prejudice', 2005, 129, N'Romance', N'Romántico', N'Joe Wright', N'Keira Knightley', N'Matthew Macfadyen', N'Rosamund Pike', N'Una joven desafía las convenciones sociales y se enamora.'),
(N'Atonement', 2007, 123, N'Romance', N'Melancólico', N'Joe Wright', N'Keira Knightley', N'James McAvoy', N'Saoirse Ronan', N'Una acusación altera el destino de dos enamorados.'),
(N'The Notebook', 2004, 123, N'Romance', N'Romántico', N'Nick Cassavetes', N'Ryan Gosling', N'Rachel McAdams', N'James Garner', N'Una pareja vive una historia de amor a través de los años.'),
(N'About Time', 2013, 123, N'Romance', N'Emotivo', N'Richard Curtis', N'Domhnall Gleeson', N'Rachel McAdams', N'Bill Nighy', N'Un joven usa un don familiar para comprender el amor y la vida.'),
(N'Notting Hill', 1999, 124, N'Romance', N'Romántico', N'Roger Michell', N'Julia Roberts', N'Hugh Grant', N'Rhys Ifans', N'Un librero conoce a una estrella de cine.'),
(N'Love Actually', 2003, 135, N'Romance', N'Emotivo', N'Richard Curtis', N'Hugh Grant', N'Emma Thompson', N'Liam Neeson', N'Varias historias de amor se cruzan durante las fiestas.'),
(N'10 Things I Hate About You', 1999, 97, N'Romance', N'Divertido', N'Gil Junger', N'Heath Ledger', N'Julia Stiles', N'Joseph Gordon-Levitt', N'Dos hermanas viven enredos románticos en la escuela.'),
(N'Crazy Rich Asians', 2018, 120, N'Romance', N'Divertido', N'Jon M. Chu', N'Constance Wu', N'Henry Golding', N'Michelle Yeoh', N'Una mujer conoce a la adinerada familia de su pareja.'),
(N'500 Days of Summer', 2009, 95, N'Romance', N'Melancólico', N'Marc Webb', N'Joseph Gordon-Levitt', N'Zooey Deschanel', N'Geoffrey Arend', N'Un joven recuerda una relación que cambió su vida.'),
(N'Eternal Sunshine of the Spotless Mind', 2004, 108, N'Romance', N'Melancólico', N'Michel Gondry', N'Jim Carrey', N'Kate Winslet', N'Kirsten Dunst', N'Una pareja reflexiona sobre recuerdos y relaciones.'),
(N'Her', 2013, 126, N'Romance', N'Melancólico', N'Spike Jonze', N'Joaquin Phoenix', N'Scarlett Johansson', N'Amy Adams', N'Un hombre desarrolla un vínculo inesperado con una inteligencia artificial.'),
(N'Before Sunrise', 1995, 101, N'Romance', N'Romántico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Andrea Eckert', N'Dos viajeros se conocen y pasan una noche conversando.'),
(N'Before Sunset', 2004, 80, N'Romance', N'Melancólico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Vernon Dobtcheff', N'Dos antiguos conocidos vuelven a encontrarse en París.'),
(N'Before Midnight', 2013, 109, N'Romance', N'Reflexivo', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Seamus Davey-Fitzpatrick', N'Una pareja reflexiona sobre el paso del tiempo.'),
(N'The Fault in Our Stars', 2014, 126, N'Romance', N'Emotivo', N'Josh Boone', N'Shailene Woodley', N'Ansel Elgort', N'Nat Wolff', N'Dos adolescentes comparten una historia de amor y esperanza.'),
(N'Me Before You', 2016, 110, N'Romance', N'Emotivo', N'Thea Sharrock', N'Emilia Clarke', N'Sam Claflin', N'Janet McTeer', N'Una cuidadora establece una conexión especial con un joven.'),
(N'Titanic', 1997, 194, N'Romance', N'Emotivo', N'James Cameron', N'Leonardo DiCaprio', N'Kate Winslet', N'Billy Zane', N'Dos jóvenes de clases diferentes se enamoran durante un viaje.'),
(N'Romeo + Juliet', 1996, 120, N'Romance', N'Romántico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Claire Danes', N'John Leguizamo', N'Dos jóvenes enamorados pertenecen a familias enfrentadas.'),
(N'Moulin Rouge!', 2001, 127, N'Romance', N'Melancólico', N'Baz Luhrmann', N'Nicole Kidman', N'Ewan McGregor', N'Jim Broadbent', N'Un escritor se enamora de una artista en París.'),
(N'The Great Gatsby', 2013, 143, N'Drama', N'Melancólico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Carey Mulligan', N'Tobey Maguire', N'Un millonario organiza fiestas mientras persigue un amor pasado.'),
(N'The Holiday', 2006, 136, N'Romance', N'Alegre', N'Nancy Meyers', N'Cameron Diaz', N'Kate Winslet', N'Jude Law', N'Dos mujeres intercambian casas y encuentran nuevas oportunidades.'),
(N'Pretty Woman', 1990, 119, N'Romance', N'Romántico', N'Garry Marshall', N'Julia Roberts', N'Richard Gere', N'Hector Elizondo', N'Dos personas de mundos distintos se conocen en Los Ángeles.'),
(N'When Harry Met Sally...', 1989, 96, N'Romance', N'Divertido', N'Rob Reiner', N'Billy Crystal', N'Meg Ryan', N'Carrie Fisher', N'Dos amigos se preguntan si la amistad puede convertirse en amor.'),
(N'Sleepless in Seattle', 1993, 105, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Ross Malinger', N'Una periodista se interesa por la historia de un padre viudo.'),
(N'You''ve Got Mail', 1998, 119, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Greg Kinnear', N'Dos rivales comerciales se conocen por mensajes anónimos.'),
(N'The Proposal', 2009, 108, N'Romance', N'Divertido', N'Anne Fletcher', N'Sandra Bullock', N'Ryan Reynolds', N'Betty White', N'Una editora y su asistente simulan una relación.'),
(N'Crazy Stupid Love', 2011, 118, N'Romance', N'Divertido', N'Glenn Ficarra', N'Steve Carell', N'Ryan Gosling', N'Julianne Moore', N'Varias historias sentimentales se cruzan de manera inesperada.'),
(N'The Devil Wears Prada', 2006, 109, N'Comedia', N'Divertido', N'David Frankel', N'Meryl Streep', N'Anne Hathaway', N'Emily Blunt', N'Una joven empieza a trabajar para una exigente editora.'),
(N'Mean Girls', 2004, 97, N'Comedia', N'Divertido', N'Mark Waters', N'Lindsay Lohan', N'Rachel McAdams', N'Tina Fey', N'Una estudiante nueva aprende las reglas sociales de su escuela.'),
(N'Clueless', 1995, 97, N'Comedia', N'Divertido', N'Amy Heckerling', N'Alicia Silverstone', N'Stacey Dash', N'Brittany Murphy', N'Una adolescente intenta organizar la vida amorosa de sus amigos.'),
(N'Legally Blonde', 2001, 96, N'Comedia', N'Inspirador', N'Robert Luketic', N'Reese Witherspoon', N'Luke Wilson', N'Selma Blair', N'Una joven desafía prejuicios al ingresar a Derecho.'),
(N'The Intern', 2015, 121, N'Comedia', N'Inspirador', N'Nancy Meyers', N'Robert De Niro', N'Anne Hathaway', N'Rene Russo', N'Un jubilado comienza una pasantía en una empresa moderna.'),
(N'The Hangover', 2009, 100, N'Comedia', N'Divertido', N'Todd Phillips', N'Bradley Cooper', N'Ed Helms', N'Zach Galifianakis', N'Tres amigos intentan reconstruir una noche en Las Vegas.'),
(N'21 Jump Street', 2012, 109, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Brie Larson', N'Dos policías se infiltran en una escuela secundaria.'),
(N'22 Jump Street', 2014, 112, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Ice Cube', N'Dos agentes se infiltran en una universidad.'),
(N'The 40-Year-Old Virgin', 2005, 116, N'Comedia', N'Divertido', N'Judd Apatow', N'Steve Carell', N'Catherine Keener', N'Paul Rudd', N'Los amigos de un hombre intentan ayudarlo a encontrar pareja.'),
(N'Bridesmaids', 2011, 125, N'Comedia', N'Divertido', N'Paul Feig', N'Kristen Wiig', N'Maya Rudolph', N'Rose Byrne', N'Una mujer organiza la boda de su mejor amiga.'),
(N'Game Night', 2018, 100, N'Comedia', N'Intrigante', N'John Francis Daley', N'Jason Bateman', N'Rachel McAdams', N'Kyle Chandler', N'Una noche de juegos se convierte en un misterio real.'),
(N'Knives Out', 2019, 130, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Ana de Armas', N'Chris Evans', N'Un detective investiga una muerte en una familia adinerada.'),
(N'Glass Onion: A Knives Out Mystery', 2022, 139, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Janelle Monáe', N'Edward Norton', N'Un detective resuelve un misterio en una isla privada.'),
(N'Gone Girl', 2014, 149, N'Suspenso', N'Intrigante', N'David Fincher', N'Ben Affleck', N'Rosamund Pike', N'Neil Patrick Harris', N'La desaparición de una mujer pone a su esposo bajo sospecha.'),
(N'Zodiac', 2007, 157, N'Suspenso', N'Intrigante', N'David Fincher', N'Jake Gyllenhaal', N'Mark Ruffalo', N'Robert Downey Jr.', N'Unos investigadores intentan descubrir la identidad de un criminal.'),
(N'The Social Network', 2010, 120, N'Drama', N'Reflexivo', N'David Fincher', N'Jesse Eisenberg', N'Andrew Garfield', N'Justin Timberlake', N'Un estudiante crea una red social que cambia su vida.'),
(N'The Girl with the Dragon Tattoo', 2011, 158, N'Suspenso', N'Oscuro', N'David Fincher', N'Daniel Craig', N'Rooney Mara', N'Christopher Plummer', N'Un periodista investiga un caso antiguo con una hacker.'),
(N'Prisoners', 2013, 153, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Hugh Jackman', N'Jake Gyllenhaal', N'Viola Davis', N'Un padre busca respuestas sobre la desaparición de su hija.'),
(N'Sicario', 2015, 121, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Emily Blunt', N'Benicio del Toro', N'Josh Brolin', N'Una agente participa en una operación contra el narcotráfico.'),
(N'Arrival', 2016, 116, N'Ciencia ficción', N'Reflexivo', N'Denis Villeneuve', N'Amy Adams', N'Jeremy Renner', N'Forest Whitaker', N'Una lingüista intenta comunicarse con visitantes extraterrestres.'),
(N'Blade Runner 2049', 2017, 164, N'Ciencia ficción', N'Melancólico', N'Denis Villeneuve', N'Ryan Gosling', N'Harrison Ford', N'Ana de Armas', N'Un agente descubre un secreto que podría cambiar la sociedad.'),
(N'Blade Runner', 1982, 117, N'Ciencia ficción', N'Reflexivo', N'Ridley Scott', N'Harrison Ford', N'Rutger Hauer', N'Sean Young', N'Un investigador persigue androides en una ciudad futurista.'),
(N'Ex Machina', 2014, 108, N'Ciencia ficción', N'Intrigante', N'Alex Garland', N'Domhnall Gleeson', N'Alicia Vikander', N'Oscar Isaac', N'Un programador evalúa una inteligencia artificial avanzada.'),
(N'Annihilation', 2018, 115, N'Ciencia ficción', N'Inquietante', N'Alex Garland', N'Natalie Portman', N'Jennifer Jason Leigh', N'Tessa Thompson', N'Un equipo explora una zona de extrañas transformaciones.'),
(N'District 9', 2009, 112, N'Ciencia ficción', N'Intenso', N'Neill Blomkamp', N'Sharlto Copley', N'Jason Cope', N'David James', N'Un funcionario se involucra en un conflicto con extraterrestres.'),
(N'Elysium', 2013, 109, N'Ciencia ficción', N'Emocionante', N'Neill Blomkamp', N'Matt Damon', N'Jodie Foster', N'Sharlto Copley', N'Un trabajador intenta llegar a una estación espacial exclusiva.'),
(N'Edge of Tomorrow', 2014, 113, N'Ciencia ficción', N'Emocionante', N'Doug Liman', N'Tom Cruise', N'Emily Blunt', N'Bill Paxton', N'Un soldado revive el mismo día durante una invasión.'),
(N'Source Code', 2011, 93, N'Ciencia ficción', N'Intrigante', N'Duncan Jones', N'Jake Gyllenhaal', N'Michelle Monaghan', N'Vera Farmiga', N'Un soldado revive minutos de un viaje para resolver un misterio.'),
(N'Moon', 2009, 97, N'Ciencia ficción', N'Reflexivo', N'Duncan Jones', N'Sam Rockwell', N'Kevin Spacey', N'Dominique McElligott', N'Un astronauta descubre secretos durante una misión lunar.'),
(N'Looper', 2012, 119, N'Ciencia ficción', N'Intrigante', N'Rian Johnson', N'Joseph Gordon-Levitt', N'Bruce Willis', N'Emily Blunt', N'Un hombre se enfrenta a una versión futura de sí mismo.'),
(N'Minority Report', 2002, 145, N'Ciencia ficción', N'Intrigante', N'Steven Spielberg', N'Tom Cruise', N'Colin Farrell', N'Samantha Morton', N'Un policía investiga delitos antes de que ocurran.'),
(N'Ready Player One', 2018, 140, N'Ciencia ficción', N'Emocionante', N'Steven Spielberg', N'Tye Sheridan', N'Olivia Cooke', N'Ben Mendelsohn', N'Un joven compite por un premio en un universo virtual.'),
(N'A.I. Artificial Intelligence', 2001, 146, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Haley Joel Osment', N'Jude Law', N'Frances O''Connor', N'Un niño robot busca encontrar su lugar en el mundo.'),
(N'E.T. the Extra-Terrestrial', 1982, 115, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Henry Thomas', N'Drew Barrymore', N'Dee Wallace', N'Un niño ayuda a un extraterrestre a regresar a casa.'),
(N'Close Encounters of the Third Kind', 1977, 138, N'Ciencia ficción', N'Mágico', N'Steven Spielberg', N'Richard Dreyfuss', N'François Truffaut', N'Teri Garr', N'Un hombre se obsesiona con extraños encuentros en el cielo.'),
(N'War of the Worlds', 2005, 116, N'Ciencia ficción', N'Tenso', N'Steven Spielberg', N'Tom Cruise', N'Dakota Fanning', N'Tim Robbins', N'Un padre protege a sus hijos durante una invasión.'),
(N'The Martian', 2015, 144, N'Ciencia ficción', N'Inspirador', N'Ridley Scott', N'Matt Damon', N'Jessica Chastain', N'Chiwetel Ejiofor', N'Un astronauta intenta sobrevivir solo en Marte.'),
(N'Gravity', 2013, 91, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Sandra Bullock', N'George Clooney', N'Ed Harris', N'Dos astronautas enfrentan una emergencia en órbita.'),
(N'Children of Men', 2006, 109, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Clive Owen', N'Julianne Moore', N'Michael Caine', N'Un hombre protege a una joven en un futuro incierto.'),
(N'Pacific Rim', 2013, 131, N'Ciencia ficción', N'Épico', N'Guillermo del Toro', N'Charlie Hunnam', N'Idris Elba', N'Rinko Kikuchi', N'Pilotos de robots gigantes defienden la Tierra.'),
(N'The Shape of Water', 2017, 123, N'Fantasía', N'Romántico', N'Guillermo del Toro', N'Sally Hawkins', N'Michael Shannon', N'Richard Jenkins', N'Una mujer descubre una criatura extraordinaria en un laboratorio.')
) AS V(Titulo, Anio, DuracionMinutos, Genero, Animo, Director, Actor1, Actor2, Actor3, Sinopsis)
WHERE NOT EXISTS (SELECT 1 FROM Peliculas P WHERE P.Titulo = V.Titulo);

-- ACTORES NUEVOS
INSERT INTO Actores (Nombre)
SELECT DISTINCT X.Actor
FROM (VALUES
(N'Alien', 1979, 117, N'Terror', N'Tenebroso', N'Ridley Scott', N'Sigourney Weaver', N'Tom Skerritt', N'John Hurt', N'Una tripulación espacial encuentra una amenaza desconocida.'),
(N'Aliens', 1986, 137, N'Ciencia ficción', N'Intenso', N'James Cameron', N'Sigourney Weaver', N'Michael Biehn', N'Bill Paxton', N'Ripley regresa a un planeta ocupado por criaturas peligrosas.'),
(N'The Thing', 1982, 109, N'Terror', N'Tenebroso', N'John Carpenter', N'Kurt Russell', N'Keith David', N'Wilford Brimley', N'Un equipo aislado enfrenta una criatura capaz de imitar personas.'),
(N'Halloween', 1978, 91, N'Terror', N'Tenebroso', N'John Carpenter', N'Jamie Lee Curtis', N'Donald Pleasence', N'Nancy Kyes', N'Una comunidad vive una noche de miedo ante un asesino enmascarado.'),
(N'Scream', 1996, 111, N'Terror', N'Intrigante', N'Wes Craven', N'Neve Campbell', N'Courteney Cox', N'David Arquette', N'Una adolescente intenta descubrir quién aterroriza su pueblo.'),
(N'The Conjuring', 2013, 112, N'Terror', N'Tenebroso', N'James Wan', N'Vera Farmiga', N'Patrick Wilson', N'Lili Taylor', N'Dos investigadores estudian sucesos extraños en una casa.'),
(N'Insidious', 2010, 103, N'Terror', N'Tenebroso', N'James Wan', N'Patrick Wilson', N'Rose Byrne', N'Lin Shaye', N'Una familia busca respuestas a fenómenos inexplicables.'),
(N'Get Out', 2017, 104, N'Terror', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Allison Williams', N'Bradley Whitford', N'Un joven descubre inquietantes secretos durante una visita familiar.'),
(N'Us', 2019, 116, N'Terror', N'Tenebroso', N'Jordan Peele', N'Lupita Nyong''o', N'Winston Duke', N'Elisabeth Moss', N'Una familia se enfrenta a visitantes idénticos a ellos.'),
(N'Nope', 2022, 130, N'Ciencia ficción', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Keke Palmer', N'Steven Yeun', N'Dos hermanos investigan un fenómeno extraño en el cielo.'),
(N'Hereditary', 2018, 127, N'Terror', N'Tenebroso', N'Ari Aster', N'Toni Collette', N'Alex Wolff', N'Gabriel Byrne', N'Una familia descubre secretos perturbadores de su pasado.'),
(N'Midsommar', 2019, 148, N'Terror', N'Inquietante', N'Ari Aster', N'Florence Pugh', N'Jack Reynor', N'William Jackson Harper', N'Un viaje a un festival remoto toma un giro inquietante.'),
(N'The Witch', 2015, 92, N'Terror', N'Tenebroso', N'Robert Eggers', N'Anya Taylor-Joy', N'Ralph Ineson', N'Kate Dickie', N'Una familia puritana enfrenta sucesos misteriosos.'),
(N'The Lighthouse', 2019, 109, N'Drama', N'Oscuro', N'Robert Eggers', N'Robert Pattinson', N'Willem Dafoe', N'Valeriia Karaman', N'Dos fareros aislados empiezan a desconfiar entre sí.'),
(N'The Babadook', 2014, 94, N'Terror', N'Tenebroso', N'Jennifer Kent', N'Essie Davis', N'Noah Wiseman', N'Daniel Henshall', N'Una madre y su hijo temen a una presencia misteriosa.'),
(N'A Quiet Place', 2018, 90, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'John Krasinski', N'Millicent Simmonds', N'Una familia debe vivir en silencio para sobrevivir.'),
(N'A Quiet Place Part II', 2020, 97, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'Cillian Murphy', N'Millicent Simmonds', N'Una familia continúa su camino por un mundo peligroso.'),
(N'It', 2017, 135, N'Terror', N'Tenebroso', N'Andy Muschietti', N'Jaeden Martell', N'Sophia Lillis', N'Bill Skarsgård', N'Un grupo de amigos investiga desapariciones en su pueblo.'),
(N'The Ring', 2002, 115, N'Terror', N'Tenebroso', N'Gore Verbinski', N'Naomi Watts', N'Martin Henderson', N'David Dorfman', N'Una periodista investiga una misteriosa grabación.'),
(N'The Others', 2001, 104, N'Terror', N'Intrigante', N'Alejandro Amenábar', N'Nicole Kidman', N'Fionnula Flanagan', N'Christopher Eccleston', N'Una madre percibe sucesos inexplicables en su mansión.'),
(N'The Blair Witch Project', 1999, 81, N'Terror', N'Tenebroso', N'Daniel Myrick', N'Heather Donahue', N'Michael C. Williams', N'Joshua Leonard', N'Tres estudiantes se pierden mientras filman un documental.'),
(N'Paranormal Activity', 2007, 86, N'Terror', N'Tenebroso', N'Oren Peli', N'Katie Featherston', N'Micah Sloat', N'Mark Fredrichs', N'Una pareja registra extraños sucesos en su hogar.'),
(N'The Descent', 2005, 99, N'Terror', N'Tenso', N'Neil Marshall', N'Shauna Macdonald', N'Natalie Mendoza', N'Alex Reid', N'Un grupo de amigas queda atrapado en unas cuevas.'),
(N'Saw', 2004, 103, N'Terror', N'Intrigante', N'James Wan', N'Cary Elwes', N'Leigh Whannell', N'Danny Glover', N'Dos desconocidos deben resolver un misterio para escapar.'),
(N'Final Destination', 2000, 98, N'Terror', N'Tenso', N'James Wong', N'Devon Sawa', N'Ali Larter', N'Kerr Smith', N'Un joven presiente un accidente y altera un destino.'),
(N'The Sixth Sense', 1999, 107, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bruce Willis', N'Haley Joel Osment', N'Toni Collette', N'Un psicólogo intenta ayudar a un niño con un secreto.'),
(N'Split', 2016, 117, N'Suspenso', N'Tenso', N'M. Night Shyamalan', N'James McAvoy', N'Anya Taylor-Joy', N'Betty Buckley', N'Tres jóvenes intentan comprender a su captor.'),
(N'Signs', 2002, 106, N'Ciencia ficción', N'Intrigante', N'M. Night Shyamalan', N'Mel Gibson', N'Joaquin Phoenix', N'Rory Culkin', N'Una familia descubre marcas inexplicables en sus cultivos.'),
(N'The Village', 2004, 108, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bryce Dallas Howard', N'Joaquin Phoenix', N'Adrien Brody', N'Una comunidad aislada teme lo que habita el bosque.'),
(N'The Shining', 1980, 146, N'Terror', N'Tenebroso', N'Stanley Kubrick', N'Jack Nicholson', N'Shelley Duvall', N'Danny Lloyd', N'Un cuidador y su familia pasan el invierno en un hotel aislado.'),
(N'Doctor Sleep', 2019, 152, N'Terror', N'Tenebroso', N'Mike Flanagan', N'Ewan McGregor', N'Rebecca Ferguson', N'Kyliegh Curran', N'Un hombre con habilidades especiales ayuda a una niña.'),
(N'Carrie', 1976, 98, N'Terror', N'Intenso', N'Brian De Palma', N'Sissy Spacek', N'Piper Laurie', N'Amy Irving', N'Una adolescente descubre un poder que no comprende.'),
(N'Rosemary''s Baby', 1968, 137, N'Terror', N'Inquietante', N'Roman Polanski', N'Mia Farrow', N'John Cassavetes', N'Ruth Gordon', N'Una mujer sospecha de sus nuevos vecinos.'),
(N'The Exorcist', 1973, 122, N'Terror', N'Tenebroso', N'William Friedkin', N'Ellen Burstyn', N'Linda Blair', N'Max von Sydow', N'Una madre busca ayuda ante sucesos extraños con su hija.'),
(N'The Texas Chain Saw Massacre', 1974, 83, N'Terror', N'Tenso', N'Tobe Hooper', N'Marilyn Burns', N'Paul A. Partain', N'Edwin Neal', N'Un grupo de viajeros se encuentra con una familia aterradora.'),
(N'The Nightmare Before Christmas', 1993, 76, N'Animación', N'Mágico', N'Henry Selick', N'Chris Sarandon', N'Catherine O''Hara', N'Danny Elfman', N'El rey de Halloween descubre la celebración navideña.'),
(N'Coraline', 2009, 100, N'Animación', N'Tenebroso', N'Henry Selick', N'Dakota Fanning', N'Teri Hatcher', N'John Hodgman', N'Una niña encuentra una puerta hacia un mundo alternativo.'),
(N'Corpse Bride', 2005, 77, N'Animación', N'Melancólico', N'Tim Burton', N'Johnny Depp', N'Helena Bonham Carter', N'Emily Watson', N'Un joven entra accidentalmente en el mundo de los muertos.'),
(N'Frankenweenie', 2012, 87, N'Animación', N'Emotivo', N'Tim Burton', N'Charlie Tahan', N'Catherine O''Hara', N'Martin Short', N'Un niño intenta recuperar a su querido perro.'),
(N'ParaNorman', 2012, 92, N'Animación', N'Divertido', N'Chris Butler', N'Kodi Smit-McPhee', N'Anna Kendrick', N'Christopher Mintz-Plasse', N'Un chico capaz de hablar con fantasmas salva su pueblo.'),
(N'Monster House', 2006, 91, N'Animación', N'Intrigante', N'Gil Kenan', N'Mitchel Musso', N'Sam Lerner', N'Spencer Locke', N'Tres amigos descubren que una casa esconde un secreto.'),
(N'Hotel Transylvania', 2012, 91, N'Animación', N'Divertido', N'Genndy Tartakovsky', N'Adam Sandler', N'Selena Gomez', N'Andy Samberg', N'Drácula administra un hotel para monstruos.'),
(N'Monsters Inc.', 2001, 92, N'Animación', N'Divertido', N'Pete Docter', N'John Goodman', N'Billy Crystal', N'Mary Gibbs', N'Dos monstruos descubren una nueva forma de generar energía.'),
(N'Monsters University', 2013, 104, N'Animación', N'Divertido', N'Dan Scanlon', N'Billy Crystal', N'John Goodman', N'Steve Buscemi', N'Dos estudiantes aprenden a trabajar juntos en la universidad.'),
(N'Finding Nemo', 2003, 100, N'Animación', N'Emotivo', N'Andrew Stanton', N'Albert Brooks', N'Ellen DeGeneres', N'Alexander Gould', N'Un pez recorre el océano buscando a su hijo.'),
(N'Finding Dory', 2016, 97, N'Animación', N'Emotivo', N'Andrew Stanton', N'Ellen DeGeneres', N'Albert Brooks', N'Ed O''Neill', N'Dory emprende una búsqueda para reencontrar a su familia.'),
(N'Ratatouille', 2007, 111, N'Animación', N'Inspirador', N'Brad Bird', N'Patton Oswalt', N'Ian Holm', N'Lou Romano', N'Una rata sueña con convertirse en chef en París.'),
(N'The Incredibles', 2004, 115, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Samuel L. Jackson', N'Una familia de superhéroes vuelve a la acción.'),
(N'Incredibles 2', 2018, 118, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Sarah Vowell', N'La familia de héroes enfrenta una nueva amenaza.'),
(N'Up', 2009, 96, N'Animación', N'Emotivo', N'Pete Docter', N'Ed Asner', N'Jordan Nagai', N'Christopher Plummer', N'Un anciano viaja en una casa impulsada por globos.'),
(N'Soul', 2020, 100, N'Animación', N'Reflexivo', N'Pete Docter', N'Jamie Foxx', N'Tina Fey', N'Graham Norton', N'Un músico descubre nuevas perspectivas sobre la vida.'),
(N'Turning Red', 2022, 100, N'Animación', N'Divertido', N'Domee Shi', N'Rosalie Chiang', N'Sandra Oh', N'Ava Morse', N'Una adolescente experimenta cambios familiares inesperados.'),
(N'Luca', 2021, 95, N'Animación', N'Alegre', N'Enrico Casarosa', N'Jacob Tremblay', N'Jack Dylan Grazer', N'Emma Berman', N'Dos amigos viven un verano inolvidable en Italia.'),
(N'Encanto', 2021, 102, N'Animación', N'Emotivo', N'Jared Bush', N'Stephanie Beatriz', N'María Cecilia Botero', N'John Leguizamo', N'Una joven busca su lugar en una familia extraordinaria.'),
(N'Moana', 2016, 107, N'Animación', N'Inspirador', N'Ron Clements', N'Auli''i Cravalho', N'Dwayne Johnson', N'Rachel House', N'Una joven navega para salvar a su isla.'),
(N'Frozen', 2013, 102, N'Animación', N'Emotivo', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Jonathan Groff', N'Dos hermanas buscan recuperar su vínculo.'),
(N'Frozen II', 2019, 103, N'Animación', N'Mágico', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Josh Gad', N'Dos hermanas exploran el origen de sus poderes.'),
(N'Tangled', 2010, 100, N'Animación', N'Divertido', N'Nathan Greno', N'Mandy Moore', N'Zachary Levi', N'Donna Murphy', N'Una princesa sale de su torre para descubrir el mundo.'),
(N'Zootopia', 2016, 108, N'Animación', N'Divertido', N'Byron Howard', N'Ginnifer Goodwin', N'Jason Bateman', N'Idris Elba', N'Una coneja policía investiga un caso junto a un zorro.'),
(N'Big Hero 6', 2014, 102, N'Animación', N'Emotivo', N'Don Hall', N'Ryan Potter', N'Scott Adsit', N'Jamie Chung', N'Un joven inventor y un robot forman un equipo de héroes.'),
(N'Wreck-It Ralph', 2012, 101, N'Animación', N'Divertido', N'Rich Moore', N'John C. Reilly', N'Sarah Silverman', N'Jack McBrayer', N'Un villano de videojuego quiere cambiar su historia.'),
(N'The Lego Movie', 2014, 100, N'Animación', N'Divertido', N'Phil Lord', N'Chris Pratt', N'Elizabeth Banks', N'Will Arnett', N'Un trabajador común termina en una gran aventura.'),
(N'Kung Fu Panda', 2008, 92, N'Animación', N'Inspirador', N'Mark Osborne', N'Jack Black', N'Dustin Hoffman', N'Angelina Jolie', N'Un panda aprende artes marciales para proteger su valle.'),
(N'How to Train Your Dragon', 2010, 98, N'Animación', N'Emotivo', N'Chris Sanders', N'Jay Baruchel', N'Gerard Butler', N'America Ferrera', N'Un joven vikingo entabla amistad con un dragón.'),
(N'How to Train Your Dragon 2', 2014, 102, N'Animación', N'Emocionante', N'Dean DeBlois', N'Jay Baruchel', N'Cate Blanchett', N'Gerard Butler', N'Hipo y Chimuelo descubren nuevos dragones y peligros.'),
(N'Puss in Boots: The Last Wish', 2022, 102, N'Animación', N'Emotivo', N'Joel Crawford', N'Antonio Banderas', N'Salma Hayek', N'Harvey Guillén', N'El Gato con Botas busca recuperar sus vidas perdidas.'),
(N'Shrek 2', 2004, 93, N'Animación', N'Divertido', N'Andrew Adamson', N'Mike Myers', N'Eddie Murphy', N'Cameron Diaz', N'Shrek conoce a la familia de Fiona.'),
(N'Madagascar', 2005, 86, N'Animación', N'Divertido', N'Eric Darnell', N'Ben Stiller', N'Chris Rock', N'David Schwimmer', N'Un grupo de animales del zoológico llega a una isla.'),
(N'Despicable Me', 2010, 95, N'Animación', N'Divertido', N'Pierre Coffin', N'Steve Carell', N'Jason Segel', N'Miranda Cosgrove', N'Un villano conoce a tres niñas que cambian sus planes.'),
(N'Minions', 2015, 91, N'Animación', N'Divertido', N'Pierre Coffin', N'Sandra Bullock', N'Jon Hamm', N'Michael Keaton', N'Los minions buscan a un nuevo jefe.'),
(N'The Iron Giant', 1999, 86, N'Animación', N'Emotivo', N'Brad Bird', N'Eli Marienthal', N'Vin Diesel', N'Jennifer Aniston', N'Un niño se hace amigo de un robot gigante.'),
(N'Klaus', 2019, 96, N'Animación', N'Emotivo', N'Sergio Pablos', N'Jason Schwartzman', N'J.K. Simmons', N'Rashida Jones', N'Un cartero transforma un pueblo con ayuda de un juguetero.'),
(N'The Mitchells vs. the Machines', 2021, 114, N'Animación', N'Divertido', N'Mike Rianda', N'Abbi Jacobson', N'Danny McBride', N'Maya Rudolph', N'Una familia debe salvar el mundo de una rebelión tecnológica.'),
(N'Your Name', 2016, 106, N'Animación', N'Melancólico', N'Makoto Shinkai', N'Ryunosuke Kamiki', N'Mone Kamishiraishi', N'Ryo Narita', N'Dos adolescentes descubren una conexión extraordinaria.'),
(N'Weathering with You', 2019, 112, N'Animación', N'Emotivo', N'Makoto Shinkai', N'Kotaro Daigo', N'Nana Mori', N'Shun Oguri', N'Un joven conoce a una chica capaz de cambiar el clima.'),
(N'Suzume', 2022, 122, N'Animación', N'Mágico', N'Makoto Shinkai', N'Nanoka Hara', N'Hokuto Matsumura', N'Eri Fukatsu', N'Una joven emprende un viaje para cerrar puertas misteriosas.'),
(N'Princess Mononoke', 1997, 134, N'Animación', N'Épico', N'Hayao Miyazaki', N'Yoji Matsuda', N'Yuriko Ishida', N'Yuko Tanaka', N'Un príncipe se involucra en un conflicto entre naturaleza y humanos.'),
(N'My Neighbor Totoro', 1988, 86, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Noriko Hidaka', N'Chika Sakamoto', N'Hitoshi Takagi', N'Dos hermanas descubren criaturas mágicas en el bosque.'),
(N'Kiki''s Delivery Service', 1989, 103, N'Animación', N'Alegre', N'Hayao Miyazaki', N'Minami Takayama', N'Rei Sakuma', N'Kappei Yamaguchi', N'Una joven bruja comienza a vivir por su cuenta.'),
(N'Howl''s Moving Castle', 2004, 119, N'Animación', N'Mágico', N'Hayao Miyazaki', N'Chieko Baisho', N'Takuya Kimura', N'Akihiro Miwa', N'Una joven encuentra refugio en un castillo ambulante.'),
(N'Ponyo', 2008, 101, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Yuria Nara', N'Hiroki Doi', N'Tomoko Yamaguchi', N'Una criatura marina quiere vivir entre humanos.'),
(N'The Boy and the Heron', 2023, 124, N'Animación', N'Reflexivo', N'Hayao Miyazaki', N'Soma Santoki', N'Masaki Suda', N'Ko Shibasaki', N'Un joven entra en un mundo fantástico tras una pérdida.'),
(N'The Wind Rises', 2013, 126, N'Animación', N'Melancólico', N'Hayao Miyazaki', N'Hideaki Anno', N'Miori Takimoto', N'Hidetoshi Nishijima', N'Un diseñador de aviones persigue sus sueños.'),
(N'The Tale of the Princess Kaguya', 2013, 137, N'Animación', N'Melancólico', N'Isao Takahata', N'Aki Asakura', N'Kengo Kora', N'Takeo Chii', N'Una niña misteriosa crece en una familia campesina.'),
(N'Grave of the Fireflies', 1988, 89, N'Animación', N'Triste', N'Isao Takahata', N'Tsutomu Tatsumi', N'Ayano Shiraishi', N'Yoshiko Shinohara', N'Dos hermanos intentan sobrevivir durante la guerra.'),
(N'The Grand Budapest Hotel', 2014, 99, N'Comedia', N'Divertido', N'Wes Anderson', N'Ralph Fiennes', N'Tony Revolori', N'Saoirse Ronan', N'Un conserje y su aprendiz viven una aventura extravagante.'),
(N'Fantastic Mr. Fox', 2009, 87, N'Animación', N'Divertido', N'Wes Anderson', N'George Clooney', N'Meryl Streep', N'Jason Schwartzman', N'Un zorro ingenioso desafía a tres granjeros.'),
(N'Isle of Dogs', 2018, 101, N'Animación', N'Emotivo', N'Wes Anderson', N'Bryan Cranston', N'Koyu Rankin', N'Edward Norton', N'Un niño busca a su perro en una isla remota.'),
(N'Moonrise Kingdom', 2012, 94, N'Romance', N'Tierno', N'Wes Anderson', N'Jared Gilman', N'Kara Hayward', N'Bruce Willis', N'Dos jóvenes se escapan juntos y movilizan a su comunidad.'),
(N'The Royal Tenenbaums', 2001, 110, N'Comedia', N'Melancólico', N'Wes Anderson', N'Gene Hackman', N'Gwyneth Paltrow', N'Ben Stiller', N'Una familia excéntrica se reúne después de años.'),
(N'Little Miss Sunshine', 2006, 101, N'Comedia', N'Inspirador', N'Jonathan Dayton', N'Abigail Breslin', N'Greg Kinnear', N'Toni Collette', N'Una familia viaja para acompañar a una niña a un concurso.'),
(N'Juno', 2007, 96, N'Comedia', N'Reflexivo', N'Jason Reitman', N'Elliot Page', N'Michael Cera', N'Jennifer Garner', N'Una adolescente afronta decisiones importantes con humor.'),
(N'Lady Bird', 2017, 94, N'Drama', N'Reflexivo', N'Greta Gerwig', N'Saoirse Ronan', N'Laurie Metcalf', N'Timothée Chalamet', N'Una joven busca independencia durante su último año escolar.'),
(N'Barbie', 2023, 114, N'Comedia', N'Reflexivo', N'Greta Gerwig', N'Margot Robbie', N'Ryan Gosling', N'America Ferrera', N'Barbie explora el mundo real y cuestiona su identidad.'),
(N'Little Women', 2019, 135, N'Drama', N'Emotivo', N'Greta Gerwig', N'Saoirse Ronan', N'Florence Pugh', N'Emma Watson', N'Cuatro hermanas persiguen sus sueños y crecen juntas.'),
(N'Pride & Prejudice', 2005, 129, N'Romance', N'Romántico', N'Joe Wright', N'Keira Knightley', N'Matthew Macfadyen', N'Rosamund Pike', N'Una joven desafía las convenciones sociales y se enamora.'),
(N'Atonement', 2007, 123, N'Romance', N'Melancólico', N'Joe Wright', N'Keira Knightley', N'James McAvoy', N'Saoirse Ronan', N'Una acusación altera el destino de dos enamorados.'),
(N'The Notebook', 2004, 123, N'Romance', N'Romántico', N'Nick Cassavetes', N'Ryan Gosling', N'Rachel McAdams', N'James Garner', N'Una pareja vive una historia de amor a través de los años.'),
(N'About Time', 2013, 123, N'Romance', N'Emotivo', N'Richard Curtis', N'Domhnall Gleeson', N'Rachel McAdams', N'Bill Nighy', N'Un joven usa un don familiar para comprender el amor y la vida.'),
(N'Notting Hill', 1999, 124, N'Romance', N'Romántico', N'Roger Michell', N'Julia Roberts', N'Hugh Grant', N'Rhys Ifans', N'Un librero conoce a una estrella de cine.'),
(N'Love Actually', 2003, 135, N'Romance', N'Emotivo', N'Richard Curtis', N'Hugh Grant', N'Emma Thompson', N'Liam Neeson', N'Varias historias de amor se cruzan durante las fiestas.'),
(N'10 Things I Hate About You', 1999, 97, N'Romance', N'Divertido', N'Gil Junger', N'Heath Ledger', N'Julia Stiles', N'Joseph Gordon-Levitt', N'Dos hermanas viven enredos románticos en la escuela.'),
(N'Crazy Rich Asians', 2018, 120, N'Romance', N'Divertido', N'Jon M. Chu', N'Constance Wu', N'Henry Golding', N'Michelle Yeoh', N'Una mujer conoce a la adinerada familia de su pareja.'),
(N'500 Days of Summer', 2009, 95, N'Romance', N'Melancólico', N'Marc Webb', N'Joseph Gordon-Levitt', N'Zooey Deschanel', N'Geoffrey Arend', N'Un joven recuerda una relación que cambió su vida.'),
(N'Eternal Sunshine of the Spotless Mind', 2004, 108, N'Romance', N'Melancólico', N'Michel Gondry', N'Jim Carrey', N'Kate Winslet', N'Kirsten Dunst', N'Una pareja reflexiona sobre recuerdos y relaciones.'),
(N'Her', 2013, 126, N'Romance', N'Melancólico', N'Spike Jonze', N'Joaquin Phoenix', N'Scarlett Johansson', N'Amy Adams', N'Un hombre desarrolla un vínculo inesperado con una inteligencia artificial.'),
(N'Before Sunrise', 1995, 101, N'Romance', N'Romántico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Andrea Eckert', N'Dos viajeros se conocen y pasan una noche conversando.'),
(N'Before Sunset', 2004, 80, N'Romance', N'Melancólico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Vernon Dobtcheff', N'Dos antiguos conocidos vuelven a encontrarse en París.'),
(N'Before Midnight', 2013, 109, N'Romance', N'Reflexivo', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Seamus Davey-Fitzpatrick', N'Una pareja reflexiona sobre el paso del tiempo.'),
(N'The Fault in Our Stars', 2014, 126, N'Romance', N'Emotivo', N'Josh Boone', N'Shailene Woodley', N'Ansel Elgort', N'Nat Wolff', N'Dos adolescentes comparten una historia de amor y esperanza.'),
(N'Me Before You', 2016, 110, N'Romance', N'Emotivo', N'Thea Sharrock', N'Emilia Clarke', N'Sam Claflin', N'Janet McTeer', N'Una cuidadora establece una conexión especial con un joven.'),
(N'Titanic', 1997, 194, N'Romance', N'Emotivo', N'James Cameron', N'Leonardo DiCaprio', N'Kate Winslet', N'Billy Zane', N'Dos jóvenes de clases diferentes se enamoran durante un viaje.'),
(N'Romeo + Juliet', 1996, 120, N'Romance', N'Romántico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Claire Danes', N'John Leguizamo', N'Dos jóvenes enamorados pertenecen a familias enfrentadas.'),
(N'Moulin Rouge!', 2001, 127, N'Romance', N'Melancólico', N'Baz Luhrmann', N'Nicole Kidman', N'Ewan McGregor', N'Jim Broadbent', N'Un escritor se enamora de una artista en París.'),
(N'The Great Gatsby', 2013, 143, N'Drama', N'Melancólico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Carey Mulligan', N'Tobey Maguire', N'Un millonario organiza fiestas mientras persigue un amor pasado.'),
(N'The Holiday', 2006, 136, N'Romance', N'Alegre', N'Nancy Meyers', N'Cameron Diaz', N'Kate Winslet', N'Jude Law', N'Dos mujeres intercambian casas y encuentran nuevas oportunidades.'),
(N'Pretty Woman', 1990, 119, N'Romance', N'Romántico', N'Garry Marshall', N'Julia Roberts', N'Richard Gere', N'Hector Elizondo', N'Dos personas de mundos distintos se conocen en Los Ángeles.'),
(N'When Harry Met Sally...', 1989, 96, N'Romance', N'Divertido', N'Rob Reiner', N'Billy Crystal', N'Meg Ryan', N'Carrie Fisher', N'Dos amigos se preguntan si la amistad puede convertirse en amor.'),
(N'Sleepless in Seattle', 1993, 105, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Ross Malinger', N'Una periodista se interesa por la historia de un padre viudo.'),
(N'You''ve Got Mail', 1998, 119, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Greg Kinnear', N'Dos rivales comerciales se conocen por mensajes anónimos.'),
(N'The Proposal', 2009, 108, N'Romance', N'Divertido', N'Anne Fletcher', N'Sandra Bullock', N'Ryan Reynolds', N'Betty White', N'Una editora y su asistente simulan una relación.'),
(N'Crazy Stupid Love', 2011, 118, N'Romance', N'Divertido', N'Glenn Ficarra', N'Steve Carell', N'Ryan Gosling', N'Julianne Moore', N'Varias historias sentimentales se cruzan de manera inesperada.'),
(N'The Devil Wears Prada', 2006, 109, N'Comedia', N'Divertido', N'David Frankel', N'Meryl Streep', N'Anne Hathaway', N'Emily Blunt', N'Una joven empieza a trabajar para una exigente editora.'),
(N'Mean Girls', 2004, 97, N'Comedia', N'Divertido', N'Mark Waters', N'Lindsay Lohan', N'Rachel McAdams', N'Tina Fey', N'Una estudiante nueva aprende las reglas sociales de su escuela.'),
(N'Clueless', 1995, 97, N'Comedia', N'Divertido', N'Amy Heckerling', N'Alicia Silverstone', N'Stacey Dash', N'Brittany Murphy', N'Una adolescente intenta organizar la vida amorosa de sus amigos.'),
(N'Legally Blonde', 2001, 96, N'Comedia', N'Inspirador', N'Robert Luketic', N'Reese Witherspoon', N'Luke Wilson', N'Selma Blair', N'Una joven desafía prejuicios al ingresar a Derecho.'),
(N'The Intern', 2015, 121, N'Comedia', N'Inspirador', N'Nancy Meyers', N'Robert De Niro', N'Anne Hathaway', N'Rene Russo', N'Un jubilado comienza una pasantía en una empresa moderna.'),
(N'The Hangover', 2009, 100, N'Comedia', N'Divertido', N'Todd Phillips', N'Bradley Cooper', N'Ed Helms', N'Zach Galifianakis', N'Tres amigos intentan reconstruir una noche en Las Vegas.'),
(N'21 Jump Street', 2012, 109, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Brie Larson', N'Dos policías se infiltran en una escuela secundaria.'),
(N'22 Jump Street', 2014, 112, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Ice Cube', N'Dos agentes se infiltran en una universidad.'),
(N'The 40-Year-Old Virgin', 2005, 116, N'Comedia', N'Divertido', N'Judd Apatow', N'Steve Carell', N'Catherine Keener', N'Paul Rudd', N'Los amigos de un hombre intentan ayudarlo a encontrar pareja.'),
(N'Bridesmaids', 2011, 125, N'Comedia', N'Divertido', N'Paul Feig', N'Kristen Wiig', N'Maya Rudolph', N'Rose Byrne', N'Una mujer organiza la boda de su mejor amiga.'),
(N'Game Night', 2018, 100, N'Comedia', N'Intrigante', N'John Francis Daley', N'Jason Bateman', N'Rachel McAdams', N'Kyle Chandler', N'Una noche de juegos se convierte en un misterio real.'),
(N'Knives Out', 2019, 130, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Ana de Armas', N'Chris Evans', N'Un detective investiga una muerte en una familia adinerada.'),
(N'Glass Onion: A Knives Out Mystery', 2022, 139, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Janelle Monáe', N'Edward Norton', N'Un detective resuelve un misterio en una isla privada.'),
(N'Gone Girl', 2014, 149, N'Suspenso', N'Intrigante', N'David Fincher', N'Ben Affleck', N'Rosamund Pike', N'Neil Patrick Harris', N'La desaparición de una mujer pone a su esposo bajo sospecha.'),
(N'Zodiac', 2007, 157, N'Suspenso', N'Intrigante', N'David Fincher', N'Jake Gyllenhaal', N'Mark Ruffalo', N'Robert Downey Jr.', N'Unos investigadores intentan descubrir la identidad de un criminal.'),
(N'The Social Network', 2010, 120, N'Drama', N'Reflexivo', N'David Fincher', N'Jesse Eisenberg', N'Andrew Garfield', N'Justin Timberlake', N'Un estudiante crea una red social que cambia su vida.'),
(N'The Girl with the Dragon Tattoo', 2011, 158, N'Suspenso', N'Oscuro', N'David Fincher', N'Daniel Craig', N'Rooney Mara', N'Christopher Plummer', N'Un periodista investiga un caso antiguo con una hacker.'),
(N'Prisoners', 2013, 153, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Hugh Jackman', N'Jake Gyllenhaal', N'Viola Davis', N'Un padre busca respuestas sobre la desaparición de su hija.'),
(N'Sicario', 2015, 121, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Emily Blunt', N'Benicio del Toro', N'Josh Brolin', N'Una agente participa en una operación contra el narcotráfico.'),
(N'Arrival', 2016, 116, N'Ciencia ficción', N'Reflexivo', N'Denis Villeneuve', N'Amy Adams', N'Jeremy Renner', N'Forest Whitaker', N'Una lingüista intenta comunicarse con visitantes extraterrestres.'),
(N'Blade Runner 2049', 2017, 164, N'Ciencia ficción', N'Melancólico', N'Denis Villeneuve', N'Ryan Gosling', N'Harrison Ford', N'Ana de Armas', N'Un agente descubre un secreto que podría cambiar la sociedad.'),
(N'Blade Runner', 1982, 117, N'Ciencia ficción', N'Reflexivo', N'Ridley Scott', N'Harrison Ford', N'Rutger Hauer', N'Sean Young', N'Un investigador persigue androides en una ciudad futurista.'),
(N'Ex Machina', 2014, 108, N'Ciencia ficción', N'Intrigante', N'Alex Garland', N'Domhnall Gleeson', N'Alicia Vikander', N'Oscar Isaac', N'Un programador evalúa una inteligencia artificial avanzada.'),
(N'Annihilation', 2018, 115, N'Ciencia ficción', N'Inquietante', N'Alex Garland', N'Natalie Portman', N'Jennifer Jason Leigh', N'Tessa Thompson', N'Un equipo explora una zona de extrañas transformaciones.'),
(N'District 9', 2009, 112, N'Ciencia ficción', N'Intenso', N'Neill Blomkamp', N'Sharlto Copley', N'Jason Cope', N'David James', N'Un funcionario se involucra en un conflicto con extraterrestres.'),
(N'Elysium', 2013, 109, N'Ciencia ficción', N'Emocionante', N'Neill Blomkamp', N'Matt Damon', N'Jodie Foster', N'Sharlto Copley', N'Un trabajador intenta llegar a una estación espacial exclusiva.'),
(N'Edge of Tomorrow', 2014, 113, N'Ciencia ficción', N'Emocionante', N'Doug Liman', N'Tom Cruise', N'Emily Blunt', N'Bill Paxton', N'Un soldado revive el mismo día durante una invasión.'),
(N'Source Code', 2011, 93, N'Ciencia ficción', N'Intrigante', N'Duncan Jones', N'Jake Gyllenhaal', N'Michelle Monaghan', N'Vera Farmiga', N'Un soldado revive minutos de un viaje para resolver un misterio.'),
(N'Moon', 2009, 97, N'Ciencia ficción', N'Reflexivo', N'Duncan Jones', N'Sam Rockwell', N'Kevin Spacey', N'Dominique McElligott', N'Un astronauta descubre secretos durante una misión lunar.'),
(N'Looper', 2012, 119, N'Ciencia ficción', N'Intrigante', N'Rian Johnson', N'Joseph Gordon-Levitt', N'Bruce Willis', N'Emily Blunt', N'Un hombre se enfrenta a una versión futura de sí mismo.'),
(N'Minority Report', 2002, 145, N'Ciencia ficción', N'Intrigante', N'Steven Spielberg', N'Tom Cruise', N'Colin Farrell', N'Samantha Morton', N'Un policía investiga delitos antes de que ocurran.'),
(N'Ready Player One', 2018, 140, N'Ciencia ficción', N'Emocionante', N'Steven Spielberg', N'Tye Sheridan', N'Olivia Cooke', N'Ben Mendelsohn', N'Un joven compite por un premio en un universo virtual.'),
(N'A.I. Artificial Intelligence', 2001, 146, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Haley Joel Osment', N'Jude Law', N'Frances O''Connor', N'Un niño robot busca encontrar su lugar en el mundo.'),
(N'E.T. the Extra-Terrestrial', 1982, 115, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Henry Thomas', N'Drew Barrymore', N'Dee Wallace', N'Un niño ayuda a un extraterrestre a regresar a casa.'),
(N'Close Encounters of the Third Kind', 1977, 138, N'Ciencia ficción', N'Mágico', N'Steven Spielberg', N'Richard Dreyfuss', N'François Truffaut', N'Teri Garr', N'Un hombre se obsesiona con extraños encuentros en el cielo.'),
(N'War of the Worlds', 2005, 116, N'Ciencia ficción', N'Tenso', N'Steven Spielberg', N'Tom Cruise', N'Dakota Fanning', N'Tim Robbins', N'Un padre protege a sus hijos durante una invasión.'),
(N'The Martian', 2015, 144, N'Ciencia ficción', N'Inspirador', N'Ridley Scott', N'Matt Damon', N'Jessica Chastain', N'Chiwetel Ejiofor', N'Un astronauta intenta sobrevivir solo en Marte.'),
(N'Gravity', 2013, 91, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Sandra Bullock', N'George Clooney', N'Ed Harris', N'Dos astronautas enfrentan una emergencia en órbita.'),
(N'Children of Men', 2006, 109, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Clive Owen', N'Julianne Moore', N'Michael Caine', N'Un hombre protege a una joven en un futuro incierto.'),
(N'Pacific Rim', 2013, 131, N'Ciencia ficción', N'Épico', N'Guillermo del Toro', N'Charlie Hunnam', N'Idris Elba', N'Rinko Kikuchi', N'Pilotos de robots gigantes defienden la Tierra.'),
(N'The Shape of Water', 2017, 123, N'Fantasía', N'Romántico', N'Guillermo del Toro', N'Sally Hawkins', N'Michael Shannon', N'Richard Jenkins', N'Una mujer descubre una criatura extraordinaria en un laboratorio.')
) AS V(Titulo, Anio, DuracionMinutos, Genero, Animo, Director, Actor1, Actor2, Actor3, Sinopsis)
CROSS APPLY (VALUES (V.Actor1), (V.Actor2), (V.Actor3)) AS X(Actor)
WHERE NOT EXISTS (SELECT 1 FROM Actores A WHERE A.Nombre = X.Actor);

-- RELACIONES ENTRE PELÍCULAS Y ACTORES
INSERT INTO PeliculaActor (IdPelicula, IdActor)
SELECT DISTINCT P.IdPelicula, A.IdActor
FROM (VALUES
(N'Alien', 1979, 117, N'Terror', N'Tenebroso', N'Ridley Scott', N'Sigourney Weaver', N'Tom Skerritt', N'John Hurt', N'Una tripulación espacial encuentra una amenaza desconocida.'),
(N'Aliens', 1986, 137, N'Ciencia ficción', N'Intenso', N'James Cameron', N'Sigourney Weaver', N'Michael Biehn', N'Bill Paxton', N'Ripley regresa a un planeta ocupado por criaturas peligrosas.'),
(N'The Thing', 1982, 109, N'Terror', N'Tenebroso', N'John Carpenter', N'Kurt Russell', N'Keith David', N'Wilford Brimley', N'Un equipo aislado enfrenta una criatura capaz de imitar personas.'),
(N'Halloween', 1978, 91, N'Terror', N'Tenebroso', N'John Carpenter', N'Jamie Lee Curtis', N'Donald Pleasence', N'Nancy Kyes', N'Una comunidad vive una noche de miedo ante un asesino enmascarado.'),
(N'Scream', 1996, 111, N'Terror', N'Intrigante', N'Wes Craven', N'Neve Campbell', N'Courteney Cox', N'David Arquette', N'Una adolescente intenta descubrir quién aterroriza su pueblo.'),
(N'The Conjuring', 2013, 112, N'Terror', N'Tenebroso', N'James Wan', N'Vera Farmiga', N'Patrick Wilson', N'Lili Taylor', N'Dos investigadores estudian sucesos extraños en una casa.'),
(N'Insidious', 2010, 103, N'Terror', N'Tenebroso', N'James Wan', N'Patrick Wilson', N'Rose Byrne', N'Lin Shaye', N'Una familia busca respuestas a fenómenos inexplicables.'),
(N'Get Out', 2017, 104, N'Terror', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Allison Williams', N'Bradley Whitford', N'Un joven descubre inquietantes secretos durante una visita familiar.'),
(N'Us', 2019, 116, N'Terror', N'Tenebroso', N'Jordan Peele', N'Lupita Nyong''o', N'Winston Duke', N'Elisabeth Moss', N'Una familia se enfrenta a visitantes idénticos a ellos.'),
(N'Nope', 2022, 130, N'Ciencia ficción', N'Intrigante', N'Jordan Peele', N'Daniel Kaluuya', N'Keke Palmer', N'Steven Yeun', N'Dos hermanos investigan un fenómeno extraño en el cielo.'),
(N'Hereditary', 2018, 127, N'Terror', N'Tenebroso', N'Ari Aster', N'Toni Collette', N'Alex Wolff', N'Gabriel Byrne', N'Una familia descubre secretos perturbadores de su pasado.'),
(N'Midsommar', 2019, 148, N'Terror', N'Inquietante', N'Ari Aster', N'Florence Pugh', N'Jack Reynor', N'William Jackson Harper', N'Un viaje a un festival remoto toma un giro inquietante.'),
(N'The Witch', 2015, 92, N'Terror', N'Tenebroso', N'Robert Eggers', N'Anya Taylor-Joy', N'Ralph Ineson', N'Kate Dickie', N'Una familia puritana enfrenta sucesos misteriosos.'),
(N'The Lighthouse', 2019, 109, N'Drama', N'Oscuro', N'Robert Eggers', N'Robert Pattinson', N'Willem Dafoe', N'Valeriia Karaman', N'Dos fareros aislados empiezan a desconfiar entre sí.'),
(N'The Babadook', 2014, 94, N'Terror', N'Tenebroso', N'Jennifer Kent', N'Essie Davis', N'Noah Wiseman', N'Daniel Henshall', N'Una madre y su hijo temen a una presencia misteriosa.'),
(N'A Quiet Place', 2018, 90, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'John Krasinski', N'Millicent Simmonds', N'Una familia debe vivir en silencio para sobrevivir.'),
(N'A Quiet Place Part II', 2020, 97, N'Terror', N'Tenso', N'John Krasinski', N'Emily Blunt', N'Cillian Murphy', N'Millicent Simmonds', N'Una familia continúa su camino por un mundo peligroso.'),
(N'It', 2017, 135, N'Terror', N'Tenebroso', N'Andy Muschietti', N'Jaeden Martell', N'Sophia Lillis', N'Bill Skarsgård', N'Un grupo de amigos investiga desapariciones en su pueblo.'),
(N'The Ring', 2002, 115, N'Terror', N'Tenebroso', N'Gore Verbinski', N'Naomi Watts', N'Martin Henderson', N'David Dorfman', N'Una periodista investiga una misteriosa grabación.'),
(N'The Others', 2001, 104, N'Terror', N'Intrigante', N'Alejandro Amenábar', N'Nicole Kidman', N'Fionnula Flanagan', N'Christopher Eccleston', N'Una madre percibe sucesos inexplicables en su mansión.'),
(N'The Blair Witch Project', 1999, 81, N'Terror', N'Tenebroso', N'Daniel Myrick', N'Heather Donahue', N'Michael C. Williams', N'Joshua Leonard', N'Tres estudiantes se pierden mientras filman un documental.'),
(N'Paranormal Activity', 2007, 86, N'Terror', N'Tenebroso', N'Oren Peli', N'Katie Featherston', N'Micah Sloat', N'Mark Fredrichs', N'Una pareja registra extraños sucesos en su hogar.'),
(N'The Descent', 2005, 99, N'Terror', N'Tenso', N'Neil Marshall', N'Shauna Macdonald', N'Natalie Mendoza', N'Alex Reid', N'Un grupo de amigas queda atrapado en unas cuevas.'),
(N'Saw', 2004, 103, N'Terror', N'Intrigante', N'James Wan', N'Cary Elwes', N'Leigh Whannell', N'Danny Glover', N'Dos desconocidos deben resolver un misterio para escapar.'),
(N'Final Destination', 2000, 98, N'Terror', N'Tenso', N'James Wong', N'Devon Sawa', N'Ali Larter', N'Kerr Smith', N'Un joven presiente un accidente y altera un destino.'),
(N'The Sixth Sense', 1999, 107, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bruce Willis', N'Haley Joel Osment', N'Toni Collette', N'Un psicólogo intenta ayudar a un niño con un secreto.'),
(N'Split', 2016, 117, N'Suspenso', N'Tenso', N'M. Night Shyamalan', N'James McAvoy', N'Anya Taylor-Joy', N'Betty Buckley', N'Tres jóvenes intentan comprender a su captor.'),
(N'Signs', 2002, 106, N'Ciencia ficción', N'Intrigante', N'M. Night Shyamalan', N'Mel Gibson', N'Joaquin Phoenix', N'Rory Culkin', N'Una familia descubre marcas inexplicables en sus cultivos.'),
(N'The Village', 2004, 108, N'Suspenso', N'Intrigante', N'M. Night Shyamalan', N'Bryce Dallas Howard', N'Joaquin Phoenix', N'Adrien Brody', N'Una comunidad aislada teme lo que habita el bosque.'),
(N'The Shining', 1980, 146, N'Terror', N'Tenebroso', N'Stanley Kubrick', N'Jack Nicholson', N'Shelley Duvall', N'Danny Lloyd', N'Un cuidador y su familia pasan el invierno en un hotel aislado.'),
(N'Doctor Sleep', 2019, 152, N'Terror', N'Tenebroso', N'Mike Flanagan', N'Ewan McGregor', N'Rebecca Ferguson', N'Kyliegh Curran', N'Un hombre con habilidades especiales ayuda a una niña.'),
(N'Carrie', 1976, 98, N'Terror', N'Intenso', N'Brian De Palma', N'Sissy Spacek', N'Piper Laurie', N'Amy Irving', N'Una adolescente descubre un poder que no comprende.'),
(N'Rosemary''s Baby', 1968, 137, N'Terror', N'Inquietante', N'Roman Polanski', N'Mia Farrow', N'John Cassavetes', N'Ruth Gordon', N'Una mujer sospecha de sus nuevos vecinos.'),
(N'The Exorcist', 1973, 122, N'Terror', N'Tenebroso', N'William Friedkin', N'Ellen Burstyn', N'Linda Blair', N'Max von Sydow', N'Una madre busca ayuda ante sucesos extraños con su hija.'),
(N'The Texas Chain Saw Massacre', 1974, 83, N'Terror', N'Tenso', N'Tobe Hooper', N'Marilyn Burns', N'Paul A. Partain', N'Edwin Neal', N'Un grupo de viajeros se encuentra con una familia aterradora.'),
(N'The Nightmare Before Christmas', 1993, 76, N'Animación', N'Mágico', N'Henry Selick', N'Chris Sarandon', N'Catherine O''Hara', N'Danny Elfman', N'El rey de Halloween descubre la celebración navideña.'),
(N'Coraline', 2009, 100, N'Animación', N'Tenebroso', N'Henry Selick', N'Dakota Fanning', N'Teri Hatcher', N'John Hodgman', N'Una niña encuentra una puerta hacia un mundo alternativo.'),
(N'Corpse Bride', 2005, 77, N'Animación', N'Melancólico', N'Tim Burton', N'Johnny Depp', N'Helena Bonham Carter', N'Emily Watson', N'Un joven entra accidentalmente en el mundo de los muertos.'),
(N'Frankenweenie', 2012, 87, N'Animación', N'Emotivo', N'Tim Burton', N'Charlie Tahan', N'Catherine O''Hara', N'Martin Short', N'Un niño intenta recuperar a su querido perro.'),
(N'ParaNorman', 2012, 92, N'Animación', N'Divertido', N'Chris Butler', N'Kodi Smit-McPhee', N'Anna Kendrick', N'Christopher Mintz-Plasse', N'Un chico capaz de hablar con fantasmas salva su pueblo.'),
(N'Monster House', 2006, 91, N'Animación', N'Intrigante', N'Gil Kenan', N'Mitchel Musso', N'Sam Lerner', N'Spencer Locke', N'Tres amigos descubren que una casa esconde un secreto.'),
(N'Hotel Transylvania', 2012, 91, N'Animación', N'Divertido', N'Genndy Tartakovsky', N'Adam Sandler', N'Selena Gomez', N'Andy Samberg', N'Drácula administra un hotel para monstruos.'),
(N'Monsters Inc.', 2001, 92, N'Animación', N'Divertido', N'Pete Docter', N'John Goodman', N'Billy Crystal', N'Mary Gibbs', N'Dos monstruos descubren una nueva forma de generar energía.'),
(N'Monsters University', 2013, 104, N'Animación', N'Divertido', N'Dan Scanlon', N'Billy Crystal', N'John Goodman', N'Steve Buscemi', N'Dos estudiantes aprenden a trabajar juntos en la universidad.'),
(N'Finding Nemo', 2003, 100, N'Animación', N'Emotivo', N'Andrew Stanton', N'Albert Brooks', N'Ellen DeGeneres', N'Alexander Gould', N'Un pez recorre el océano buscando a su hijo.'),
(N'Finding Dory', 2016, 97, N'Animación', N'Emotivo', N'Andrew Stanton', N'Ellen DeGeneres', N'Albert Brooks', N'Ed O''Neill', N'Dory emprende una búsqueda para reencontrar a su familia.'),
(N'Ratatouille', 2007, 111, N'Animación', N'Inspirador', N'Brad Bird', N'Patton Oswalt', N'Ian Holm', N'Lou Romano', N'Una rata sueña con convertirse en chef en París.'),
(N'The Incredibles', 2004, 115, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Samuel L. Jackson', N'Una familia de superhéroes vuelve a la acción.'),
(N'Incredibles 2', 2018, 118, N'Animación', N'Emocionante', N'Brad Bird', N'Craig T. Nelson', N'Holly Hunter', N'Sarah Vowell', N'La familia de héroes enfrenta una nueva amenaza.'),
(N'Up', 2009, 96, N'Animación', N'Emotivo', N'Pete Docter', N'Ed Asner', N'Jordan Nagai', N'Christopher Plummer', N'Un anciano viaja en una casa impulsada por globos.'),
(N'Soul', 2020, 100, N'Animación', N'Reflexivo', N'Pete Docter', N'Jamie Foxx', N'Tina Fey', N'Graham Norton', N'Un músico descubre nuevas perspectivas sobre la vida.'),
(N'Turning Red', 2022, 100, N'Animación', N'Divertido', N'Domee Shi', N'Rosalie Chiang', N'Sandra Oh', N'Ava Morse', N'Una adolescente experimenta cambios familiares inesperados.'),
(N'Luca', 2021, 95, N'Animación', N'Alegre', N'Enrico Casarosa', N'Jacob Tremblay', N'Jack Dylan Grazer', N'Emma Berman', N'Dos amigos viven un verano inolvidable en Italia.'),
(N'Encanto', 2021, 102, N'Animación', N'Emotivo', N'Jared Bush', N'Stephanie Beatriz', N'María Cecilia Botero', N'John Leguizamo', N'Una joven busca su lugar en una familia extraordinaria.'),
(N'Moana', 2016, 107, N'Animación', N'Inspirador', N'Ron Clements', N'Auli''i Cravalho', N'Dwayne Johnson', N'Rachel House', N'Una joven navega para salvar a su isla.'),
(N'Frozen', 2013, 102, N'Animación', N'Emotivo', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Jonathan Groff', N'Dos hermanas buscan recuperar su vínculo.'),
(N'Frozen II', 2019, 103, N'Animación', N'Mágico', N'Chris Buck', N'Kristen Bell', N'Idina Menzel', N'Josh Gad', N'Dos hermanas exploran el origen de sus poderes.'),
(N'Tangled', 2010, 100, N'Animación', N'Divertido', N'Nathan Greno', N'Mandy Moore', N'Zachary Levi', N'Donna Murphy', N'Una princesa sale de su torre para descubrir el mundo.'),
(N'Zootopia', 2016, 108, N'Animación', N'Divertido', N'Byron Howard', N'Ginnifer Goodwin', N'Jason Bateman', N'Idris Elba', N'Una coneja policía investiga un caso junto a un zorro.'),
(N'Big Hero 6', 2014, 102, N'Animación', N'Emotivo', N'Don Hall', N'Ryan Potter', N'Scott Adsit', N'Jamie Chung', N'Un joven inventor y un robot forman un equipo de héroes.'),
(N'Wreck-It Ralph', 2012, 101, N'Animación', N'Divertido', N'Rich Moore', N'John C. Reilly', N'Sarah Silverman', N'Jack McBrayer', N'Un villano de videojuego quiere cambiar su historia.'),
(N'The Lego Movie', 2014, 100, N'Animación', N'Divertido', N'Phil Lord', N'Chris Pratt', N'Elizabeth Banks', N'Will Arnett', N'Un trabajador común termina en una gran aventura.'),
(N'Kung Fu Panda', 2008, 92, N'Animación', N'Inspirador', N'Mark Osborne', N'Jack Black', N'Dustin Hoffman', N'Angelina Jolie', N'Un panda aprende artes marciales para proteger su valle.'),
(N'How to Train Your Dragon', 2010, 98, N'Animación', N'Emotivo', N'Chris Sanders', N'Jay Baruchel', N'Gerard Butler', N'America Ferrera', N'Un joven vikingo entabla amistad con un dragón.'),
(N'How to Train Your Dragon 2', 2014, 102, N'Animación', N'Emocionante', N'Dean DeBlois', N'Jay Baruchel', N'Cate Blanchett', N'Gerard Butler', N'Hipo y Chimuelo descubren nuevos dragones y peligros.'),
(N'Puss in Boots: The Last Wish', 2022, 102, N'Animación', N'Emotivo', N'Joel Crawford', N'Antonio Banderas', N'Salma Hayek', N'Harvey Guillén', N'El Gato con Botas busca recuperar sus vidas perdidas.'),
(N'Shrek 2', 2004, 93, N'Animación', N'Divertido', N'Andrew Adamson', N'Mike Myers', N'Eddie Murphy', N'Cameron Diaz', N'Shrek conoce a la familia de Fiona.'),
(N'Madagascar', 2005, 86, N'Animación', N'Divertido', N'Eric Darnell', N'Ben Stiller', N'Chris Rock', N'David Schwimmer', N'Un grupo de animales del zoológico llega a una isla.'),
(N'Despicable Me', 2010, 95, N'Animación', N'Divertido', N'Pierre Coffin', N'Steve Carell', N'Jason Segel', N'Miranda Cosgrove', N'Un villano conoce a tres niñas que cambian sus planes.'),
(N'Minions', 2015, 91, N'Animación', N'Divertido', N'Pierre Coffin', N'Sandra Bullock', N'Jon Hamm', N'Michael Keaton', N'Los minions buscan a un nuevo jefe.'),
(N'The Iron Giant', 1999, 86, N'Animación', N'Emotivo', N'Brad Bird', N'Eli Marienthal', N'Vin Diesel', N'Jennifer Aniston', N'Un niño se hace amigo de un robot gigante.'),
(N'Klaus', 2019, 96, N'Animación', N'Emotivo', N'Sergio Pablos', N'Jason Schwartzman', N'J.K. Simmons', N'Rashida Jones', N'Un cartero transforma un pueblo con ayuda de un juguetero.'),
(N'The Mitchells vs. the Machines', 2021, 114, N'Animación', N'Divertido', N'Mike Rianda', N'Abbi Jacobson', N'Danny McBride', N'Maya Rudolph', N'Una familia debe salvar el mundo de una rebelión tecnológica.'),
(N'Your Name', 2016, 106, N'Animación', N'Melancólico', N'Makoto Shinkai', N'Ryunosuke Kamiki', N'Mone Kamishiraishi', N'Ryo Narita', N'Dos adolescentes descubren una conexión extraordinaria.'),
(N'Weathering with You', 2019, 112, N'Animación', N'Emotivo', N'Makoto Shinkai', N'Kotaro Daigo', N'Nana Mori', N'Shun Oguri', N'Un joven conoce a una chica capaz de cambiar el clima.'),
(N'Suzume', 2022, 122, N'Animación', N'Mágico', N'Makoto Shinkai', N'Nanoka Hara', N'Hokuto Matsumura', N'Eri Fukatsu', N'Una joven emprende un viaje para cerrar puertas misteriosas.'),
(N'Princess Mononoke', 1997, 134, N'Animación', N'Épico', N'Hayao Miyazaki', N'Yoji Matsuda', N'Yuriko Ishida', N'Yuko Tanaka', N'Un príncipe se involucra en un conflicto entre naturaleza y humanos.'),
(N'My Neighbor Totoro', 1988, 86, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Noriko Hidaka', N'Chika Sakamoto', N'Hitoshi Takagi', N'Dos hermanas descubren criaturas mágicas en el bosque.'),
(N'Kiki''s Delivery Service', 1989, 103, N'Animación', N'Alegre', N'Hayao Miyazaki', N'Minami Takayama', N'Rei Sakuma', N'Kappei Yamaguchi', N'Una joven bruja comienza a vivir por su cuenta.'),
(N'Howl''s Moving Castle', 2004, 119, N'Animación', N'Mágico', N'Hayao Miyazaki', N'Chieko Baisho', N'Takuya Kimura', N'Akihiro Miwa', N'Una joven encuentra refugio en un castillo ambulante.'),
(N'Ponyo', 2008, 101, N'Animación', N'Tierno', N'Hayao Miyazaki', N'Yuria Nara', N'Hiroki Doi', N'Tomoko Yamaguchi', N'Una criatura marina quiere vivir entre humanos.'),
(N'The Boy and the Heron', 2023, 124, N'Animación', N'Reflexivo', N'Hayao Miyazaki', N'Soma Santoki', N'Masaki Suda', N'Ko Shibasaki', N'Un joven entra en un mundo fantástico tras una pérdida.'),
(N'The Wind Rises', 2013, 126, N'Animación', N'Melancólico', N'Hayao Miyazaki', N'Hideaki Anno', N'Miori Takimoto', N'Hidetoshi Nishijima', N'Un diseñador de aviones persigue sus sueños.'),
(N'The Tale of the Princess Kaguya', 2013, 137, N'Animación', N'Melancólico', N'Isao Takahata', N'Aki Asakura', N'Kengo Kora', N'Takeo Chii', N'Una niña misteriosa crece en una familia campesina.'),
(N'Grave of the Fireflies', 1988, 89, N'Animación', N'Triste', N'Isao Takahata', N'Tsutomu Tatsumi', N'Ayano Shiraishi', N'Yoshiko Shinohara', N'Dos hermanos intentan sobrevivir durante la guerra.'),
(N'The Grand Budapest Hotel', 2014, 99, N'Comedia', N'Divertido', N'Wes Anderson', N'Ralph Fiennes', N'Tony Revolori', N'Saoirse Ronan', N'Un conserje y su aprendiz viven una aventura extravagante.'),
(N'Fantastic Mr. Fox', 2009, 87, N'Animación', N'Divertido', N'Wes Anderson', N'George Clooney', N'Meryl Streep', N'Jason Schwartzman', N'Un zorro ingenioso desafía a tres granjeros.'),
(N'Isle of Dogs', 2018, 101, N'Animación', N'Emotivo', N'Wes Anderson', N'Bryan Cranston', N'Koyu Rankin', N'Edward Norton', N'Un niño busca a su perro en una isla remota.'),
(N'Moonrise Kingdom', 2012, 94, N'Romance', N'Tierno', N'Wes Anderson', N'Jared Gilman', N'Kara Hayward', N'Bruce Willis', N'Dos jóvenes se escapan juntos y movilizan a su comunidad.'),
(N'The Royal Tenenbaums', 2001, 110, N'Comedia', N'Melancólico', N'Wes Anderson', N'Gene Hackman', N'Gwyneth Paltrow', N'Ben Stiller', N'Una familia excéntrica se reúne después de años.'),
(N'Little Miss Sunshine', 2006, 101, N'Comedia', N'Inspirador', N'Jonathan Dayton', N'Abigail Breslin', N'Greg Kinnear', N'Toni Collette', N'Una familia viaja para acompañar a una niña a un concurso.'),
(N'Juno', 2007, 96, N'Comedia', N'Reflexivo', N'Jason Reitman', N'Elliot Page', N'Michael Cera', N'Jennifer Garner', N'Una adolescente afronta decisiones importantes con humor.'),
(N'Lady Bird', 2017, 94, N'Drama', N'Reflexivo', N'Greta Gerwig', N'Saoirse Ronan', N'Laurie Metcalf', N'Timothée Chalamet', N'Una joven busca independencia durante su último año escolar.'),
(N'Barbie', 2023, 114, N'Comedia', N'Reflexivo', N'Greta Gerwig', N'Margot Robbie', N'Ryan Gosling', N'America Ferrera', N'Barbie explora el mundo real y cuestiona su identidad.'),
(N'Little Women', 2019, 135, N'Drama', N'Emotivo', N'Greta Gerwig', N'Saoirse Ronan', N'Florence Pugh', N'Emma Watson', N'Cuatro hermanas persiguen sus sueños y crecen juntas.'),
(N'Pride & Prejudice', 2005, 129, N'Romance', N'Romántico', N'Joe Wright', N'Keira Knightley', N'Matthew Macfadyen', N'Rosamund Pike', N'Una joven desafía las convenciones sociales y se enamora.'),
(N'Atonement', 2007, 123, N'Romance', N'Melancólico', N'Joe Wright', N'Keira Knightley', N'James McAvoy', N'Saoirse Ronan', N'Una acusación altera el destino de dos enamorados.'),
(N'The Notebook', 2004, 123, N'Romance', N'Romántico', N'Nick Cassavetes', N'Ryan Gosling', N'Rachel McAdams', N'James Garner', N'Una pareja vive una historia de amor a través de los años.'),
(N'About Time', 2013, 123, N'Romance', N'Emotivo', N'Richard Curtis', N'Domhnall Gleeson', N'Rachel McAdams', N'Bill Nighy', N'Un joven usa un don familiar para comprender el amor y la vida.'),
(N'Notting Hill', 1999, 124, N'Romance', N'Romántico', N'Roger Michell', N'Julia Roberts', N'Hugh Grant', N'Rhys Ifans', N'Un librero conoce a una estrella de cine.'),
(N'Love Actually', 2003, 135, N'Romance', N'Emotivo', N'Richard Curtis', N'Hugh Grant', N'Emma Thompson', N'Liam Neeson', N'Varias historias de amor se cruzan durante las fiestas.'),
(N'10 Things I Hate About You', 1999, 97, N'Romance', N'Divertido', N'Gil Junger', N'Heath Ledger', N'Julia Stiles', N'Joseph Gordon-Levitt', N'Dos hermanas viven enredos románticos en la escuela.'),
(N'Crazy Rich Asians', 2018, 120, N'Romance', N'Divertido', N'Jon M. Chu', N'Constance Wu', N'Henry Golding', N'Michelle Yeoh', N'Una mujer conoce a la adinerada familia de su pareja.'),
(N'500 Days of Summer', 2009, 95, N'Romance', N'Melancólico', N'Marc Webb', N'Joseph Gordon-Levitt', N'Zooey Deschanel', N'Geoffrey Arend', N'Un joven recuerda una relación que cambió su vida.'),
(N'Eternal Sunshine of the Spotless Mind', 2004, 108, N'Romance', N'Melancólico', N'Michel Gondry', N'Jim Carrey', N'Kate Winslet', N'Kirsten Dunst', N'Una pareja reflexiona sobre recuerdos y relaciones.'),
(N'Her', 2013, 126, N'Romance', N'Melancólico', N'Spike Jonze', N'Joaquin Phoenix', N'Scarlett Johansson', N'Amy Adams', N'Un hombre desarrolla un vínculo inesperado con una inteligencia artificial.'),
(N'Before Sunrise', 1995, 101, N'Romance', N'Romántico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Andrea Eckert', N'Dos viajeros se conocen y pasan una noche conversando.'),
(N'Before Sunset', 2004, 80, N'Romance', N'Melancólico', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Vernon Dobtcheff', N'Dos antiguos conocidos vuelven a encontrarse en París.'),
(N'Before Midnight', 2013, 109, N'Romance', N'Reflexivo', N'Richard Linklater', N'Ethan Hawke', N'Julie Delpy', N'Seamus Davey-Fitzpatrick', N'Una pareja reflexiona sobre el paso del tiempo.'),
(N'The Fault in Our Stars', 2014, 126, N'Romance', N'Emotivo', N'Josh Boone', N'Shailene Woodley', N'Ansel Elgort', N'Nat Wolff', N'Dos adolescentes comparten una historia de amor y esperanza.'),
(N'Me Before You', 2016, 110, N'Romance', N'Emotivo', N'Thea Sharrock', N'Emilia Clarke', N'Sam Claflin', N'Janet McTeer', N'Una cuidadora establece una conexión especial con un joven.'),
(N'Titanic', 1997, 194, N'Romance', N'Emotivo', N'James Cameron', N'Leonardo DiCaprio', N'Kate Winslet', N'Billy Zane', N'Dos jóvenes de clases diferentes se enamoran durante un viaje.'),
(N'Romeo + Juliet', 1996, 120, N'Romance', N'Romántico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Claire Danes', N'John Leguizamo', N'Dos jóvenes enamorados pertenecen a familias enfrentadas.'),
(N'Moulin Rouge!', 2001, 127, N'Romance', N'Melancólico', N'Baz Luhrmann', N'Nicole Kidman', N'Ewan McGregor', N'Jim Broadbent', N'Un escritor se enamora de una artista en París.'),
(N'The Great Gatsby', 2013, 143, N'Drama', N'Melancólico', N'Baz Luhrmann', N'Leonardo DiCaprio', N'Carey Mulligan', N'Tobey Maguire', N'Un millonario organiza fiestas mientras persigue un amor pasado.'),
(N'The Holiday', 2006, 136, N'Romance', N'Alegre', N'Nancy Meyers', N'Cameron Diaz', N'Kate Winslet', N'Jude Law', N'Dos mujeres intercambian casas y encuentran nuevas oportunidades.'),
(N'Pretty Woman', 1990, 119, N'Romance', N'Romántico', N'Garry Marshall', N'Julia Roberts', N'Richard Gere', N'Hector Elizondo', N'Dos personas de mundos distintos se conocen en Los Ángeles.'),
(N'When Harry Met Sally...', 1989, 96, N'Romance', N'Divertido', N'Rob Reiner', N'Billy Crystal', N'Meg Ryan', N'Carrie Fisher', N'Dos amigos se preguntan si la amistad puede convertirse en amor.'),
(N'Sleepless in Seattle', 1993, 105, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Ross Malinger', N'Una periodista se interesa por la historia de un padre viudo.'),
(N'You''ve Got Mail', 1998, 119, N'Romance', N'Romántico', N'Nora Ephron', N'Tom Hanks', N'Meg Ryan', N'Greg Kinnear', N'Dos rivales comerciales se conocen por mensajes anónimos.'),
(N'The Proposal', 2009, 108, N'Romance', N'Divertido', N'Anne Fletcher', N'Sandra Bullock', N'Ryan Reynolds', N'Betty White', N'Una editora y su asistente simulan una relación.'),
(N'Crazy Stupid Love', 2011, 118, N'Romance', N'Divertido', N'Glenn Ficarra', N'Steve Carell', N'Ryan Gosling', N'Julianne Moore', N'Varias historias sentimentales se cruzan de manera inesperada.'),
(N'The Devil Wears Prada', 2006, 109, N'Comedia', N'Divertido', N'David Frankel', N'Meryl Streep', N'Anne Hathaway', N'Emily Blunt', N'Una joven empieza a trabajar para una exigente editora.'),
(N'Mean Girls', 2004, 97, N'Comedia', N'Divertido', N'Mark Waters', N'Lindsay Lohan', N'Rachel McAdams', N'Tina Fey', N'Una estudiante nueva aprende las reglas sociales de su escuela.'),
(N'Clueless', 1995, 97, N'Comedia', N'Divertido', N'Amy Heckerling', N'Alicia Silverstone', N'Stacey Dash', N'Brittany Murphy', N'Una adolescente intenta organizar la vida amorosa de sus amigos.'),
(N'Legally Blonde', 2001, 96, N'Comedia', N'Inspirador', N'Robert Luketic', N'Reese Witherspoon', N'Luke Wilson', N'Selma Blair', N'Una joven desafía prejuicios al ingresar a Derecho.'),
(N'The Intern', 2015, 121, N'Comedia', N'Inspirador', N'Nancy Meyers', N'Robert De Niro', N'Anne Hathaway', N'Rene Russo', N'Un jubilado comienza una pasantía en una empresa moderna.'),
(N'The Hangover', 2009, 100, N'Comedia', N'Divertido', N'Todd Phillips', N'Bradley Cooper', N'Ed Helms', N'Zach Galifianakis', N'Tres amigos intentan reconstruir una noche en Las Vegas.'),
(N'21 Jump Street', 2012, 109, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Brie Larson', N'Dos policías se infiltran en una escuela secundaria.'),
(N'22 Jump Street', 2014, 112, N'Comedia', N'Divertido', N'Phil Lord', N'Jonah Hill', N'Channing Tatum', N'Ice Cube', N'Dos agentes se infiltran en una universidad.'),
(N'The 40-Year-Old Virgin', 2005, 116, N'Comedia', N'Divertido', N'Judd Apatow', N'Steve Carell', N'Catherine Keener', N'Paul Rudd', N'Los amigos de un hombre intentan ayudarlo a encontrar pareja.'),
(N'Bridesmaids', 2011, 125, N'Comedia', N'Divertido', N'Paul Feig', N'Kristen Wiig', N'Maya Rudolph', N'Rose Byrne', N'Una mujer organiza la boda de su mejor amiga.'),
(N'Game Night', 2018, 100, N'Comedia', N'Intrigante', N'John Francis Daley', N'Jason Bateman', N'Rachel McAdams', N'Kyle Chandler', N'Una noche de juegos se convierte en un misterio real.'),
(N'Knives Out', 2019, 130, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Ana de Armas', N'Chris Evans', N'Un detective investiga una muerte en una familia adinerada.'),
(N'Glass Onion: A Knives Out Mystery', 2022, 139, N'Suspenso', N'Intrigante', N'Rian Johnson', N'Daniel Craig', N'Janelle Monáe', N'Edward Norton', N'Un detective resuelve un misterio en una isla privada.'),
(N'Gone Girl', 2014, 149, N'Suspenso', N'Intrigante', N'David Fincher', N'Ben Affleck', N'Rosamund Pike', N'Neil Patrick Harris', N'La desaparición de una mujer pone a su esposo bajo sospecha.'),
(N'Zodiac', 2007, 157, N'Suspenso', N'Intrigante', N'David Fincher', N'Jake Gyllenhaal', N'Mark Ruffalo', N'Robert Downey Jr.', N'Unos investigadores intentan descubrir la identidad de un criminal.'),
(N'The Social Network', 2010, 120, N'Drama', N'Reflexivo', N'David Fincher', N'Jesse Eisenberg', N'Andrew Garfield', N'Justin Timberlake', N'Un estudiante crea una red social que cambia su vida.'),
(N'The Girl with the Dragon Tattoo', 2011, 158, N'Suspenso', N'Oscuro', N'David Fincher', N'Daniel Craig', N'Rooney Mara', N'Christopher Plummer', N'Un periodista investiga un caso antiguo con una hacker.'),
(N'Prisoners', 2013, 153, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Hugh Jackman', N'Jake Gyllenhaal', N'Viola Davis', N'Un padre busca respuestas sobre la desaparición de su hija.'),
(N'Sicario', 2015, 121, N'Suspenso', N'Tenso', N'Denis Villeneuve', N'Emily Blunt', N'Benicio del Toro', N'Josh Brolin', N'Una agente participa en una operación contra el narcotráfico.'),
(N'Arrival', 2016, 116, N'Ciencia ficción', N'Reflexivo', N'Denis Villeneuve', N'Amy Adams', N'Jeremy Renner', N'Forest Whitaker', N'Una lingüista intenta comunicarse con visitantes extraterrestres.'),
(N'Blade Runner 2049', 2017, 164, N'Ciencia ficción', N'Melancólico', N'Denis Villeneuve', N'Ryan Gosling', N'Harrison Ford', N'Ana de Armas', N'Un agente descubre un secreto que podría cambiar la sociedad.'),
(N'Blade Runner', 1982, 117, N'Ciencia ficción', N'Reflexivo', N'Ridley Scott', N'Harrison Ford', N'Rutger Hauer', N'Sean Young', N'Un investigador persigue androides en una ciudad futurista.'),
(N'Ex Machina', 2014, 108, N'Ciencia ficción', N'Intrigante', N'Alex Garland', N'Domhnall Gleeson', N'Alicia Vikander', N'Oscar Isaac', N'Un programador evalúa una inteligencia artificial avanzada.'),
(N'Annihilation', 2018, 115, N'Ciencia ficción', N'Inquietante', N'Alex Garland', N'Natalie Portman', N'Jennifer Jason Leigh', N'Tessa Thompson', N'Un equipo explora una zona de extrañas transformaciones.'),
(N'District 9', 2009, 112, N'Ciencia ficción', N'Intenso', N'Neill Blomkamp', N'Sharlto Copley', N'Jason Cope', N'David James', N'Un funcionario se involucra en un conflicto con extraterrestres.'),
(N'Elysium', 2013, 109, N'Ciencia ficción', N'Emocionante', N'Neill Blomkamp', N'Matt Damon', N'Jodie Foster', N'Sharlto Copley', N'Un trabajador intenta llegar a una estación espacial exclusiva.'),
(N'Edge of Tomorrow', 2014, 113, N'Ciencia ficción', N'Emocionante', N'Doug Liman', N'Tom Cruise', N'Emily Blunt', N'Bill Paxton', N'Un soldado revive el mismo día durante una invasión.'),
(N'Source Code', 2011, 93, N'Ciencia ficción', N'Intrigante', N'Duncan Jones', N'Jake Gyllenhaal', N'Michelle Monaghan', N'Vera Farmiga', N'Un soldado revive minutos de un viaje para resolver un misterio.'),
(N'Moon', 2009, 97, N'Ciencia ficción', N'Reflexivo', N'Duncan Jones', N'Sam Rockwell', N'Kevin Spacey', N'Dominique McElligott', N'Un astronauta descubre secretos durante una misión lunar.'),
(N'Looper', 2012, 119, N'Ciencia ficción', N'Intrigante', N'Rian Johnson', N'Joseph Gordon-Levitt', N'Bruce Willis', N'Emily Blunt', N'Un hombre se enfrenta a una versión futura de sí mismo.'),
(N'Minority Report', 2002, 145, N'Ciencia ficción', N'Intrigante', N'Steven Spielberg', N'Tom Cruise', N'Colin Farrell', N'Samantha Morton', N'Un policía investiga delitos antes de que ocurran.'),
(N'Ready Player One', 2018, 140, N'Ciencia ficción', N'Emocionante', N'Steven Spielberg', N'Tye Sheridan', N'Olivia Cooke', N'Ben Mendelsohn', N'Un joven compite por un premio en un universo virtual.'),
(N'A.I. Artificial Intelligence', 2001, 146, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Haley Joel Osment', N'Jude Law', N'Frances O''Connor', N'Un niño robot busca encontrar su lugar en el mundo.'),
(N'E.T. the Extra-Terrestrial', 1982, 115, N'Ciencia ficción', N'Emotivo', N'Steven Spielberg', N'Henry Thomas', N'Drew Barrymore', N'Dee Wallace', N'Un niño ayuda a un extraterrestre a regresar a casa.'),
(N'Close Encounters of the Third Kind', 1977, 138, N'Ciencia ficción', N'Mágico', N'Steven Spielberg', N'Richard Dreyfuss', N'François Truffaut', N'Teri Garr', N'Un hombre se obsesiona con extraños encuentros en el cielo.'),
(N'War of the Worlds', 2005, 116, N'Ciencia ficción', N'Tenso', N'Steven Spielberg', N'Tom Cruise', N'Dakota Fanning', N'Tim Robbins', N'Un padre protege a sus hijos durante una invasión.'),
(N'The Martian', 2015, 144, N'Ciencia ficción', N'Inspirador', N'Ridley Scott', N'Matt Damon', N'Jessica Chastain', N'Chiwetel Ejiofor', N'Un astronauta intenta sobrevivir solo en Marte.'),
(N'Gravity', 2013, 91, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Sandra Bullock', N'George Clooney', N'Ed Harris', N'Dos astronautas enfrentan una emergencia en órbita.'),
(N'Children of Men', 2006, 109, N'Ciencia ficción', N'Tenso', N'Alfonso Cuarón', N'Clive Owen', N'Julianne Moore', N'Michael Caine', N'Un hombre protege a una joven en un futuro incierto.'),
(N'Pacific Rim', 2013, 131, N'Ciencia ficción', N'Épico', N'Guillermo del Toro', N'Charlie Hunnam', N'Idris Elba', N'Rinko Kikuchi', N'Pilotos de robots gigantes defienden la Tierra.'),
(N'The Shape of Water', 2017, 123, N'Fantasía', N'Romántico', N'Guillermo del Toro', N'Sally Hawkins', N'Michael Shannon', N'Richard Jenkins', N'Una mujer descubre una criatura extraordinaria en un laboratorio.')
) AS V(Titulo, Anio, DuracionMinutos, Genero, Animo, Director, Actor1, Actor2, Actor3, Sinopsis)
CROSS APPLY (VALUES (V.Actor1), (V.Actor2), (V.Actor3)) AS X(Actor)
JOIN Peliculas P ON P.Titulo = V.Titulo
JOIN Actores A ON A.Nombre = X.Actor
WHERE NOT EXISTS (SELECT 1 FROM PeliculaActor PA WHERE PA.IdPelicula = P.IdPelicula AND PA.IdActor = A.IdActor);
GO

-- ============================================
-- 24. CARGAR TEMÁTICAS
-- ============================================

INSERT INTO Etiquetas (Nombre, Tipo)
SELECT DISTINCT
    CASE
        WHEN P.Genero IN (N'Animacion', N'Animación')
            THEN N'Animación'
        ELSE P.Genero
    END,
    'Tematica'
FROM Peliculas P
WHERE P.Genero IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM Etiquetas E
    WHERE E.Tipo = 'Tematica'
    AND E.Nombre =
        CASE
            WHEN P.Genero IN (N'Animacion', N'Animación')
                THEN N'Animación'
            ELSE P.Genero
        END
);
GO


-- ============================================
-- 25. CARGAR EMOCIONES
-- ============================================

INSERT INTO Etiquetas (Nombre, Tipo)
SELECT DISTINCT
    P.Animo,
    'Emocion'
FROM Peliculas P
WHERE P.Animo IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM Etiquetas E
    WHERE E.Tipo = 'Emocion'
      AND E.Nombre = P.Animo
);
GO


-- ============================================
-- 26. RELACIONAR TEMÁTICAS CON PELÍCULAS
-- ============================================

INSERT INTO PeliculaEtiquetas (
    IdPelicula,
    IdEtiqueta
)
SELECT
    P.IdPelicula,
    E.IdEtiqueta
FROM Peliculas P
INNER JOIN Etiquetas E
    ON E.Tipo = 'Tematica'
    AND E.Nombre =
        CASE
            WHEN P.Genero IN (N'Animacion', N'Animación')
                THEN N'Animación'
            ELSE P.Genero
        END
WHERE NOT EXISTS (
    SELECT 1
    FROM PeliculaEtiquetas PE
    WHERE PE.IdPelicula = P.IdPelicula
      AND PE.IdEtiqueta = E.IdEtiqueta
);
GO


-- ============================================
-- 27. RELACIONAR EMOCIONES CON PELÍCULAS
-- ============================================

INSERT INTO PeliculaEtiquetas (
    IdPelicula,
    IdEtiqueta
)
SELECT
    P.IdPelicula,
    E.IdEtiqueta
FROM Peliculas P
INNER JOIN Etiquetas E
    ON E.Tipo = 'Emocion'
    AND E.Nombre = P.Animo
WHERE NOT EXISTS (
    SELECT 1
    FROM PeliculaEtiquetas PE
    WHERE PE.IdPelicula = P.IdPelicula
      AND PE.IdEtiqueta = E.IdEtiqueta
);
GO


-- ============================================
-- 28. COMPROBAR ETIQUETAS
-- ============================================

SELECT
    IdEtiqueta,
    Nombre,
    Tipo
FROM Etiquetas
ORDER BY Tipo, Nombre;
GO


-- ============================================
-- 29. COMPROBAR ETIQUETAS DE CADA PELÍCULA
-- ============================================

SELECT
    P.Titulo,
    E.Nombre AS Etiqueta,
    E.Tipo
FROM PeliculaEtiquetas PE
INNER JOIN Peliculas P
    ON P.IdPelicula = PE.IdPelicula
INNER JOIN Etiquetas E
    ON E.IdEtiqueta = PE.IdEtiqueta
ORDER BY P.Titulo, E.Tipo;
GO
