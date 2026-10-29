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

-- 12. INSERCION DE PELICULAS CON POSTERURL

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Toy Story')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Toy Story', 'Una aventura entre juguetes.', 'Animacion', 81, 1995, 'Alegre', 'https://image.tmdb.org/t/p/w500/uXD11I321B3yA283.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Shrek')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Shrek', 'Un ogro emprende una aventura inesperada.', 'Comedia', 90, 2001, 'Divertido', 'https://image.tmdb.org/t/p/w500/iB64vpL3dIObOtMZgX3RqdVdQDc.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Truman Show')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Truman Show', 'Un hombre descubre secretos sobre su vida.', 'Drama', 103, 1998, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/vuza0WqY239yBXOadKlGwJsZJFE.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'En busca de la felicidad')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('En busca de la felicidad', 'Un padre lucha por salir adelante.', 'Drama', 117, 2006, 'Inspirador', 'https://image.tmdb.org/t/p/w500/lBYOKAMcxIvuk9s9hMuecB9dPBV.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Superbad')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Superbad', 'Dos amigos viven una noche inolvidable.', 'Comedia', 113, 2007, 'Divertido', 'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Coco')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Coco', 'Un chico descubre la historia de su familia.', 'Animacion', 105, 2017, 'Emotivo', 'https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Intensamente')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Intensamente', 'Las emociones acompañan a una chica en su vida.', 'Animacion', 95, 2015, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4Tl5A.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Jumanji')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Jumanji', 'Un juego transforma una aventura en realidad.', 'Aventura', 104, 1995, 'Emocionante', 'https://image.tmdb.org/t/p/w500/vgpXmVaVyUL7GGiDeiK1mKEKzcX.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Dune: Part Two')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Dune: Part Two', 'Paul Atreides se une a Chani y los Fremen en una aventura por el destino de Arrakis.', 'Ciencia ficción', 166, 2024, 'Emocionante', 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Poor Things')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Poor Things', 'Bella Baxter descubre el mundo y su propia libertad en una historia fantástica.', 'Fantasía', 141, 2023, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Substance')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Substance', 'Una celebridad recurre a un tratamiento extraordinario que cambiará su vida.', 'Terror', 141, 2024, 'Intenso', 'https://image.tmdb.org/t/p/w500/lqoMzCcZYEFK729d6qzt349fB4o.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Anatomy of a Fall')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Anatomy of a Fall', 'Una mujer es juzgada tras la muerte de su esposo y las pruebas dejan dudas sobre lo ocurrido.', 'Drama', 151, 2023, 'Intrigante', 'https://image.tmdb.org/t/p/w500/kQs6keheMwCxJxrzV83VUwFtHkB.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Dark Knight')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Dark Knight', 'Un héroe de la noche enfrenta al caos y a la anarquía en la ciudad de Gotham.', 'Acción', 152, 2008, 'Intenso', 'https://image.tmdb.org/t/p/w500/qJ2tW6WM2f8L3A3M32K3x83K3.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Inception')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Inception', 'Un ladrón que roba secretos a través del sueño profundo debe cumplir una misión imposible.', 'Ciencia ficción', 148, 2010, 'Intrigante', 'https://image.tmdb.org/t/p/w500/xYGkdhOEVoFrLNUotuTXemtQAWd.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Interstellar')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Interstellar', 'Un grupo de exploradores viaja a través de un agujero de gusano para salvar a la humanidad.', 'Ciencia ficción', 169, 2014, 'Inspirador', 'https://image.tmdb.org/t/p/w500/nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Pulp Fiction')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Pulp Fiction', 'Las vidas de varios criminales en Los Ángeles se entrelazan de forma inesperada.', 'Crimen', 154, 1994, 'Intenso', 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Forrest Gump')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Forrest Gump', 'La historia de un hombre bondadoso que presenciará eventos históricos clave.', 'Drama', 142, 1994, 'Emotivo', 'https://image.tmdb.org/t/p/w500/arw232Gl1318622Q9x93527k2.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'The Matrix')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('The Matrix', 'Un programador descubre que la realidad es una simulación controlada por máquinas.', 'Ciencia ficción', 136, 1999, 'Emocionante', 'https://image.tmdb.org/t/p/w500/f89U3w9322384732.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Fight Club')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Fight Club', 'Un hombre aburrido funda un club clandestino que se transforma en algo más grande.', 'Drama', 139, 1999, 'Intenso', 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B65e932.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El viaje de Chihiro')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El viaje de Chihiro', 'Una niña entra a un mundo mágico repleto de dioses y espíritus para rescatar a sus padres.', 'Animación', 125, 2001, 'Mágico', 'https://image.tmdb.org/t/p/w500/3931847128.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Gladiator')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Gladiator', 'Un antiguo general romano busca venganza contra el corrupto emperador que masacró a su familia.', 'Acción', 155, 2000, 'Épico', 'https://image.tmdb.org/t/p/w500/ty83921.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Parasite')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Parasite', 'Una familia humilde se infiltra en la vida de una adinerada familia con oscuras consecuencias.', 'Suspenso', 132, 2019, 'Intrigante', 'https://image.tmdb.org/t/p/w500/dsVdT6XbOpzkpag4GbFQv9n7nWy.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Whiplash')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Whiplash', 'Un joven e intempestivo baterista desafía sus límites con un profesor despiadado.', 'Drama', 106, 2014, 'Intenso', 'https://image.tmdb.org/t/p/w500/whiplash.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'La La Land')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('La La Land', 'Un pianista de jazz y una aspirante a actriz persiguen sus sueños en la ciudad de las estrellas.', 'Romance', 128, 2016, 'Melancólico', 'https://image.tmdb.org/t/p/w500/lalaland.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Spider-Man: Into the Spider-Verse')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Spider-Man: Into the Spider-Verse', 'El joven Miles Morales aprende a ser Spider-Man cruzándose con héroes de otros universos.', 'Animación', 117, 2018, 'Emocionante', 'https://image.tmdb.org/t/p/w500/spiderman.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Avengers: Endgame')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Avengers: Endgame', 'Los Vengadores restantes se unen en un intento final por revertir las acciones de Thanos.', 'Acción', 181, 2019, 'Épico', 'https://image.tmdb.org/t/p/w500/endgame.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Oppenheimer')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Oppenheimer', 'La vida y conflictos de J. Robert Oppenheimer durante el desarrollo de la bomba atómica.', 'Biografía', 180, 2023, 'Reflexivo', 'https://image.tmdb.org/t/p/w500/oppenheimer.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El Rey León')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El Rey León', 'Un joven león debe superar la tragedia y asumir su lugar legítimo como rey.', 'Animación', 88, 1994, 'Inspirador', 'https://image.tmdb.org/t/p/w500/lionking.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Jurassic Park')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Jurassic Park', 'Un parque temático con dinosaurios genéticamente clonados sufre una falla catastrófica.', 'Aventura', 127, 1993, 'Emocionante', 'https://image.tmdb.org/t/p/w500/jurassicpark.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El silencio de los inocentes')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El silencio de los inocentes', 'Una novata del FBI busca la ayuda de un brillante asesino caníbal para capturar a otro criminal.', 'Suspenso', 118, 1991, 'Tenebroso', 'https://image.tmdb.org/t/p/w500/silence.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Volver al Futuro')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Volver al Futuro', 'Un joven es enviado accidentalmente 30 años al pasado en una máquina del tiempo.', 'Aventura', 116, 1985, 'Divertido', 'https://image.tmdb.org/t/p/w500/backto.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'WALL-E')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('WALL-E', 'Un pequeño robot compactador de basura en una Tierra abandonada emprende un viaje espacial.', 'Animación', 98, 2008, 'Tierno', 'https://image.tmdb.org/t/p/w500/walle.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Psicosis')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Psicosis', 'Una secretaria en fuga se hospeda en un siniestro motel regentado por Norman Bates.', 'Terror', 109, 1960, 'Tenebroso', 'https://image.tmdb.org/t/p/w500/psycho.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Se7en')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Se7en', 'Dos detectives investigan una serie de crueles asesinatos basados en los siete pecados capitales.', 'Crimen', 127, 1995, 'Oscuro', 'https://image.tmdb.org/t/p/w500/se7en.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Amélie')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Amélie', 'Una joven camarera parisina decide mejorar de forma orquestada la vida de quienes la rodean.', 'Comedia', 122, 2001, 'Alegre', 'https://image.tmdb.org/t/p/w500/amelie.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'El Padrino')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('El Padrino', 'El envejecido patriarca de una dinastía del crimen organizado transfiere el control a su hijo.', 'Crimen', 175, 1972, 'Intenso', 'https://image.tmdb.org/t/p/w500/godfather.jpg');

IF NOT EXISTS (SELECT 1 FROM Peliculas WHERE Titulo = 'Everything Everywhere All at Once')
    INSERT INTO Peliculas (Titulo, Sinopsis, Genero, DuracionMinutos, Anio, Animo, PosterUrl)
    VALUES ('Everything Everywhere All at Once', 'Una mujer de mediana edad descubre que debe conectarse con versiones suyas en universos paralelos.', 'Ciencia ficción', 139, 2022, 'Inspirador', 'https://image.tmdb.org/t/p/w500/eeaao.jpg');
GO

-- 13. TENDENCIAS
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