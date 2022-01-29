--Generar una consulta para devolver el correo electrónico, el nombre, el apellido y el género, nombre del artista, 
--titulo del almbum y el pais de todos los oyentes de música jazz.
-- Devolver una lista ordenada alfabéticamente por dirección de correo electrónico comenzando con A.SELECT DISTINCT C.EMAIL,

SELECT  C.EMAIL,
  	C.FIRSTNAME AS [Nombre Cliente],
  	C.LASTNAME AS [Apellido Cliente],
  	G.NAME AS [Nombre Género],
             AR.Name AS [Nombre del Artista],
             A.Title AS [Titulo Album],
             C.Country AS [País]
             
  FROM customers C
  INNER JOIN invoices I ON C.CUSTOMERID = I.CUSTOMERID
  INNER JOIN invoice_items IL ON IL.InvoiceLineId = I.InvoiceId
  INNER JOIN tracks T ON IL.TrackId = T.TrackId
  INNER JOIN genres G ON T.GenreId = G.GenreId
  INNER JOIN albums A ON T.AlbumId = A.AlbumId
  INNER JOIN artists AR ON A.ArtistId = AR.ArtistId
  WHERE G.NAME Like 'Jazz'
  ORDER BY 1;

DROP TABLE Consulta1;
--2 Ahora que sabemos que a nuestros clientes les encanta la música jazz, podemos decidir a qué músicos invitar a tocar en el concierto.
--Se invitarán los artistas que han escrito la mayor cantidad de música jazz en nuestro conjunto de datos. 
--Proporcionar una consulta que devuelva el nombre del artista y el recuento total de pistas de las 10 mejores bandas de jazz.

  SELECT AR.NAME AS [Nombre del Artista],
  	COUNT(T.NAME) AS [Recuento Total]
  FROM tracks T
  INNER JOIN playlist_track PT ON T.TrackId = PT.TrackId
  INNER JOIN playlists PL ON PT.PlaylistId = PT.PlaylistId
  INNER JOIN genres G ON T.GENREID = G.GENREID
  INNER JOIN media_types mt ON t.MediaTypeId = mt.MediaTypeId
  INNER JOIN albums AL ON AL.ALBUMID = T.ALBUMID
  INNER JOIN artists AR ON AR.ARTISTID = AL.ARTISTID
  WHERE G.NAME IN ('Jazz' , 'Rock')
  GROUP BY 1
  ORDER BY 2 DESC;
  
Select * from artists;
DROP TABLE Consulta2;
--3 Primero, encuentrar los artistas ha ganado más según las Líneas de Facturación.

SELECT a.Name, SUM(il.Quantity * il.UnitPrice) AS [Cantidad ganada]
FROM artists a
	 INNER JOIN albums al ON a.ArtistId = al.ArtistId
            INNER JOIN genres G ON t.GENREID = G.GENREID
            INNER JOIN tracks t  ON t.AlbumId = AL.AlbumId 
            INNER JOIN invoice_items il ON t.TrackId = il.Trackid
            INNER JOIN invoices i ON il.InvoiceId = i.InvoiceId
            INNER JOIN customers c ON c.CustomerId = i.CustomerId
GROUP BY a.Name
ORDER BY [Cantidad ganada] DESC;


--4 Ahora en base al artista es necesario encontrar los clientes que más han gastado en ese artista.

SELECT AR.NAME AS [Nombre del Artista],
       SUM(il.UnitPrice * il.Quantity)   AS [Cantidad gastada],
       c.CustomerId    AS [Id Cliente],
       c.FirstName     AS [Nombre Cliente],
       c.LastName      AS [Apellido Cliente]
  FROM artists AR 
  INNER JOIN albums AL ON AR.ArtistId = AL.ArtistId 
  INNER JOIN genres G ON T.GENREID = G.GENREID
  INNER JOIN tracks t  ON t.AlbumId = AL.AlbumId 
  INNER JOIN invoice_items il ON t.TrackId = il.Trackid 
  INNER JOIN invoices i ON il.InvoiceId = i.InvoiceId
  INNER JOIN customers c ON c.CustomerId = i.CustomerId 
 WHERE AR.NAME = 'Iron Maiden' 
 GROUP BY c.CustomerId 
 ORDER BY [Cantidad gastada] DESC;



--5 ¿Qué género musical es el más popular entre los clientes?

SELECT g.Name AS [Nombre del Género],

  SUM(il.UnitPrice * il.Quantity) AS [Cantidad gastada]
FROM genres g 
INNER JOIN artists AR 
INNER JOIN tracks t ON g.GenreId = t.GenreId
INNER JOIN playlist_track PT ON T.TrackId = PT.TrackId
INNER JOIN media_types mt ON t.MediaTypeId = mt.MediaTypeId 
INNER JOIN albums AL ON AR.ArtistId = AL.ArtistId 
INNER JOIN invoice_items il ON t.TrackId = il.TrackId
GROUP BY 1
ORDER BY [Cantidad gastada] DESC;

--6 ¿Qué nivel de importe total en dólares ha ganado cada artista?

SELECT a.Name AS [Nombre del Artista], g.Name AS [Nombre del Género],
  SUM(il.UnitPrice * il.Quantity) AS [Cantidad ganada],
  CASE
    WHEN SUM(il.UnitPrice * il.Quantity) > 50 THEN 'Alto'
    WHEN SUM(il.UnitPrice * il.Quantity) > 20 THEN 'Medio'
    ELSE 'Bajo'
  END AS Nivel
FROM artists a
INNER JOIN albums al ON a.ArtistId = al.ArtistId
INNER JOIN tracks t ON t.AlbumId = al.AlbumId
INNER JOIN genres g ON g.GenreId = t.GenreId
INNER JOIN invoice_items il ON il.TrackId = t.TrackId
INNER JOIN invoices i ON i.InvoiceId = il.InvoiceId
GROUP BY 1
ORDER BY [Cantidad ganada] DESC;



-- 7 ¿Quiénes son los 3 clientes que más han gastado en Apocalyptica?

SELECT
  a.Name AS [Nombre del Artista],
  c.CustomerId AS  [Id Cliente],
  c.FirstName AS [Nombre Cliente],
  c.LastName  AS [Apellido Cliente],
  SUM(il.UnitPrice * il.Quantity) AS [Cantidad gastada]
FROM artists a
INNER JOIN albums al ON a.ArtistId = al.ArtistId
INNER JOIN tracks t ON t.AlbumId = al.AlbumId
INNER JOIN invoice_items il ON il.TrackId = t.TrackId
INNER JOIN invoices i ON i.InvoiceId = il.InvoiceId
INNER JOIN customers c ON c.CustomerId = i.CustomerId
WHERE a.Name = 'Apocalyptica'
GROUP BY c.CustomerId
ORDER BY [Cantidad gastada] DESC
LIMIT 3;
 
select * from invoices;
--8 ¿Quiénes son los 10 clientes que más han gastado en Antônio Carlos Jobim?

SELECT
  a.Name AS [Nombre del Artista],
  c.CustomerId AS [Id Cliente],
  c.FirstName  AS [Nombre Cliente],
  c.LastName   AS [Apellido Cliente],
  SUM(il.UnitPrice * il.Quantity) AS [Cantidad gastada]

FROM artists a
INNER JOIN albums al ON a.ArtistId = al.ArtistId
INNER JOIN tracks t ON t.AlbumId = al.AlbumId
INNER JOIN invoice_items il ON il.TrackId = t.TrackId
INNER JOIN invoices i ON i.InvoiceId = il.InvoiceId
INNER JOIN customers c ON c.CustomerId = i.CustomerId
WHERE a.Name = 'Antônio Carlos Jobim'
GROUP BY c.CustomerId
ORDER BY [Cantidad gastada] DESC
LIMIT 10;

--9 Se necesita premiar al empleado que mas pistas, generos y artistas vendido en estados unidos en el 2009

SELECT E.FirstName AS [NOMBRE],
       substr(I.InvoiceDate,1,4) AS [AÑOS],
       I.BillingCountry AS [PAIS],
       T.Name AS [PISTA],
       G.Name AS [GENERO],
       AR.Name AS [ARTISTA],
       SUM(I.Total) AS [TOTAL DE VENTAS]
  FROM employees E
       INNER JOIN customers C ON C.SupportRepId = E.EmployeeId
       INNER JOIN invoices I ON I.CustomerId = C.CustomerId
       INNER JOIN invoice_items IV ON IV.InvoiceId = I.InvoiceId
       INNER JOIN tracks T ON T.TrackId = IV.TrackId
       INNER JOIN genres G ON G.GenreId = T.GenreId
       INNER JOIN albums A ON A.AlbumId = T.AlbumId
       INNER JOIN artists AR ON AR.ArtistId = A.ArtistId
WHERE substr(I.InvoiceDate,1,4) LIKE '2009' AND I.BillingCountry LIKE 'USA'
GROUP BY 1
ORDER BY SUM(I.Total)  DESC
LIMIT 1;

--10 Los 5 clientes que mas han comprado por artista y genero en todos los años 

SELECT C.FirstName AS [NOMBRE],
       substr(I.InvoiceDate,1,4) AS [AÑOS],
       G.Name AS [GENERO],
       AR.Name AS [ARTISTA],
       SUM(I.Total) AS [TOTAL DE VENTAS]
  FROM employees E
       INNER JOIN customers C ON C.SupportRepId = E.EmployeeId
       INNER JOIN invoices I ON I.CustomerId = C.CustomerId
       INNER JOIN invoice_items IV ON IV.InvoiceId = I.InvoiceId
       INNER JOIN tracks T ON T.TrackId = IV.TrackId
       INNER JOIN genres G ON G.GenreId = T.GenreId
       INNER JOIN albums A ON A.AlbumId = T.AlbumId
       INNER JOIN artists AR ON AR.ArtistId = A.ArtistId
GROUP BY 1
ORDER BY SUM(I.Total)  DESC
LIMIT 5;


 
Select * from customers;
Select * from genres;
Select * from albums;
Select * from artists;
Select * from playlist_track;
Select * from invoice_items;
