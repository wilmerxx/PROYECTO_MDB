--Generar una consulta para devolver el correo electrónico, el nombre, el apellido y el género de todos los oyentes de música jazz.
-- Devolver una lista ordenada alfabéticamente por dirección de correo electrónico comenzando con A.SELECT DISTINCT C.EMAIL,

SELECT DISTINCT C.EMAIL,
  	C.FIRSTNAME as Nombre_Cliente,
  	C.LASTNAME as Apellido_Cliente,
  	G.NAME as Nombre_Género,
             AR.Name as Nombre_Artista,
             A.Title as Titulo_Album,
             C.Country as País
             
  FROM customers C
  JOIN invoices I ON C.CUSTOMERID = I.CUSTOMERID
  JOIN invoice_items IL ON IL.InvoiceLineId = I.InvoiceId
  JOIN tracks T ON IL.TrackId = T.TrackId
  JOIN genres G ON T.GenreId = G.GenreId
  JOIN albums A ON T.AlbumId = A.AlbumId
  JOIN artists AR ON A.ArtistId = AR.ArtistId
  WHERE G.NAME Like 'Jazz'
  ORDER BY 1;


--Ahora que sabemos que a nuestros clientes les encanta la música jazz, podemos decidir a qué músicos invitar a tocar en el concierto.
--Se invitarán los artistas que han escrito la mayor cantidad de música jazz en nuestro conjunto de datos. 
--Proporcionar una consulta que devuelva el nombre del artista y el recuento total de pistas de las 10 mejores bandas de jazz.

  SELECT AR.NAME AS Nombre_del_Artista,
  	COUNT(T.NAME) as Recuento_Total
  FROM tracks T
  JOIN playlist_track PT ON T.TrackId = PT.TrackId
  JOIN playlists PL ON PT.PlaylistId = PT.PlaylistId
  JOIN genres G ON T.GENREID = G.GENREID
  JOIN media_types mt ON t.MediaTypeId = mt.MediaTypeId
  JOIN albums AL ON AL.ALBUMID = T.ALBUMID
  JOIN artists AR ON AR.ARTISTID = AL.ARTISTID
  WHERE G.NAME = 'Jazz'
  GROUP BY 1
  ORDER BY 2 DESC;


--Primero, encuentrar qué artista ha ganado más según las Líneas de Facturación.

 SELECT Y.NAME AS Nombre_Artista,
  SUM(TOTAL) AS Ganancia_Total
  FROM
  (SELECT  X.NAME, X.UNITPRICE * X.QUANTITY AS TOTAL
   FROM
    (SELECT   AR.NAME,
     IL.UnitPrice,
     IL.Quantity
   FROM artists AR
   JOIN albums AL ON AR.ArtistId = AL.ArtistId
   JOIN tracks T ON AL.AlbumId = T.AlbumId
   JOIN invoice_items IL ON T.TrackId = IL.TrackId
   ORDER BY 1 DESC) AS X) AS Y
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1;
  
--Ahora en base al artista es necesario encontrar los clientes que más han gastado en ese artista.

SELECT AR.NAME AS Nombre_del_Artista,
       SUM(il.UnitPrice * il.Quantity)   AS cantidad_gastada,
       c.CustomerId    AS Id_Cliente,
       c.FirstName     AS Nombre_Cliente,
       c.LastName      AS Apellido_Cliente
  FROM artists AR 
  JOIN albums AL ON AR.ArtistId = AL.ArtistId 
  JOIN genres G ON T.GENREID = G.GENREID
  JOIN tracks t  ON t.AlbumId = AL.AlbumId 
  JOIN invoice_items il ON t.TrackId = il.Trackid 
  JOIN invoices i ON il.InvoiceId = i.InvoiceId
  JOIN customers c ON c.CustomerId = i.CustomerId 
 WHERE AR.NAME = 'Iron Maiden' 
 GROUP BY c.CustomerId 
 ORDER BY cantidad_gastada DESC;



--¿Qué género musical es el más popular entre los clientes?

SELECT g.Name Nombre_del_Genero,

  SUM(il.UnitPrice * il.Quantity) cantidad_gastada

FROM genres g 
JOIN artists AR 
JOIN tracks t ON g.GenreId = t.GenreId
JOIN playlist_track PT ON T.TrackId = PT.TrackId
JOIN media_types mt ON t.MediaTypeId = mt.MediaTypeId 
JOIN albums AL ON AR.ArtistId = AL.ArtistId 
JOIN invoice_items il ON t.TrackId = il.TrackId
GROUP BY 1
ORDER BY cantidad_gastada DESC;

--¿Qué nivel de importe total en dólares ha ganado cada artista?

SELECT a.Name Nombre_del_Artista, g.Name Nombre_del_Genero,
  SUM(il.UnitPrice * il.Quantity) cantidad__ganada,
  CASE
    WHEN SUM(il.UnitPrice * il.Quantity) > 50 THEN 'Alto'
    WHEN SUM(il.UnitPrice * il.Quantity) > 20 THEN 'Medio'
    ELSE 'Bajo'
  END AS Nivel
FROM artists a
JOIN albums al ON a.ArtistId = al.ArtistId
JOIN media_types mt ON t.MediaTypeId = mt.MediaTypeId 
JOIN tracks t ON t.AlbumId = al.AlbumId
JOIN genres g ON g.GenreId = t.GenreId
JOIN invoice_items il ON il.TrackId = t.TrackId
JOIN invoices i ON i.InvoiceId = il.InvoiceId
GROUP BY 1
ORDER BY cantidad__ganada DESC;



--¿Quiénes son los 10 clientes que más han gastado en Antônio Carlos Jobim?

SELECT
  a.Name Nombre_del_Artista,
  c.CustomerId,
  c.FirstName,
  c.LastName,
  SUM(il.UnitPrice * il.Quantity) cantidad_gastada

FROM artists a
JOIN albums al ON a.ArtistId = al.ArtistId
JOIN tracks t ON t.AlbumId = al.AlbumId
JOIN invoice_items il ON il.TrackId = t.TrackId
JOIN invoices i ON i.InvoiceId = il.InvoiceId
JOIN customers c
  ON c.CustomerId = i.CustomerId
WHERE a.Name = 'Antônio Carlos Jobim'
GROUP BY c.CustomerId
ORDER BY cantidad_gastada DESC
LIMIT 10;
 

Select * from artists
--
select t.TrackId, t.AlbumId
from tracks t
group by t.AlbumId
having COUNT(DISTINCT t.TrackId) >= 12;

--Se necesita premiar al empleado que mas pistas, generos y artistas vendido en estados unidos en el 2009

SELECT C.FirstName AS [NOMBRE],
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
 
Select * from customers
Select * from genres
Select * from albums
Select * from artists
Select * from playlist_track
