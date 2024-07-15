-- Active: 1720920106670@@127.0.0.1@5432@claudia444

-- Requerimientos rubrica
-- 1_Las consultas para completar el setup de acuerdo a lo pedido.

CREATE DATABASE CLAUDIA444;
CREATE TABLE USUARIOS (
    id SERIAL PRIMARY KEY,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('admin', 'user')),
    titulo VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL
);


INSERT INTO USUARIOS (rol, titulo, email, nombre, apellido)
VALUES 
('admin', 'Familiares de aquel lado nos esperan', 'mariasanchez@gmail.com', 'Maria', 'Sanchez'),
('user', 'Dilema de escoger un nuevo destino', 'eperez@gmail.com', 'Eduardo', 'Perez'),
('user', 'Migrantes en la Gran Manzana', 'bramirez@gmail.com', 'Beruska', 'Ramirez'),
('user', 'El sueño americano no existe', 'lramirez@gmail.com', 'Lorena', 'Ramirez'),
('user', 'Resistir en la ciudad más cara de EE.UU.', 'sfernandez@gmail.com', 'Sofia', 'Fernandez');

CREATE TABLE POST (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    destacado BOOLEAN NOT NULL DEFAULT FALSE,
    usuario_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES USUARIOS(id)
);


INSERT INTO POST (titulo, contenido, usuario_id)
VALUES
('En el hotel estoy bien', 'Tengo comida y un lugar donde dormir', 1),
('La Morada', 'un restaurante familiar de comida mexicana en El Bronx', 1),
('Recibimos donaciones', 'Desde abril que ayudamos a la gente que llega a Nueva York', 2),
('Sara de 17 años', 'Este país no puede existir sin los migrantes', 2),
('Aquí podré lograr mi meta', 'Busco trabajo de cualquier cosa, de limpieza, lo que sea', NULL);

CREATE TABLE COMENTARIOS (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (post_id) REFERENCES POST(id)
);
INSERT INTO COMENTARIOS (contenido, usuario_id, post_id)
VALUES
    ('Espero que se encuentren bien', 1, 1),
    ('Hay que dar apoyo a todos', 2, 1),
    ('No se debe ingresar a un país ilegal', 3, 1),
    ('Aquí han dado ayuda a muchos inmigrantes', 1, 2),
    ('Si, donan alimentos siempre que pueden', 2, 2);


-- 2_Muestra el nombre y email del usuario junto al título y contenido del post.
SELECT
  u.nombre,
  u.email,
  p.titulo,
  p.contenido
FROM
  usuarios AS u
  INNER JOIN post AS p ON u.id = p.usuario_id;

--3_Muestra el id, título y contenido de los posts de los administradores
SELECT
  p.id,
  p.titulo,
  p.contenido
FROM
  POST AS p
  INNER JOIN usuarios AS u ON u.id = p.usuario_id
WHERE
  u.rol = 'admin'; 

--4_Cuenta la cantidad de posts de cada usuario
--La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.
SELECT
  u.id,
  u.email,
  COUNT(p.id) AS cantidad_posts
FROM
  usuarios AS u
  LEFT JOIN post AS p ON u.id = p.usuario_id
  GROUP BY
  u.id, u.email;
;

--5. Muestra el email del usuario que ha creado más posts.
--a. Aquí la tabla resultante tiene un único registro y muestra solo el email.
SELECT
  u.email
FROM usuarios AS u
  INNER JOIN (
    SELECT p.usuario_id, COUNT(p.id) AS post_cantidad
    FROM POST AS p 
    GROUP BY p.usuario_id
    ) AS post_por_usuario ON u.id = post_por_usuario.usuario_id
ORDER BY post_por_usuario.post_cantidad DESC
LIMIT 1;

-- 6_Muestra la fecha del último post de cada usuario
SELECT 
p.usuario_id AS id_usuario_post,
MAX(p.fecha_creacion) AS ultima_fecha
FROM usuarios AS u
LEFT JOIN post AS p ON u.id = p.usuario_id
GROUP BY usuario_id;

--7_Muestra el título y contenido del post (artículo) con más comentarios.

SELECT
    p.titulo,
    p.contenido
FROM POST AS p
INNER JOIN (
    SELECT post_id, COUNT(*) AS cant_post FROM COMENTARIOS
    GROUP BY post_id
    ORDER BY cant_post DESC
    LIMIT 1
) AS post_mas_comentarios ON p.id = post_mas_comentarios.post_id;

--8_Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.

SELECT 
    p.titulo,
    p.contenido,
    c.contenido AS comentario,
    u.email
FROM POST AS p
INNER JOIN COMENTARIOS AS c ON c.post_id = p.id
INNER JOIN usuarios AS u ON c.usuario_id = u.id;

--9_Muestra el contenido del último comentario de cada usuario
SELECT
  u.id,
  u.nombre,
  c.contenido AS ultimo_comentario
FROM
  usuarios AS u
  JOIN comentarios AS c ON u.id = c.usuario_id
WHERE
  c.fecha_creacion = (
    SELECT
      MAX(sub_consulta.fecha_creacion)
    FROM comentarios sub_consulta
    WHERE sub_consulta.usuario_id = u.id
  )
ORDER BY u.id;


--10_Muestra los emails de los usuarios que no han escrito ningún comentario.

SELECT u.email
FROM usuarios AS u
INNER JOIN comentarios c ON u.id = c.usuario_id 
GROUP BY u.id;




SELECT * FROM usuarios;
SELECT * FROM POST;
SELECT * FROM COMENTARIOS;

