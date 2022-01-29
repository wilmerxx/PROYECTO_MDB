import sqlite3
import numpy
import glob
from datetime import datetime
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt


'''Procesos de ETL'''
count =0

def extraer_database(path):

    motorDB = sqlalchemy.create_engine(path)
    conectarDB = motorDB.connect()

    return motorDB, conectarDB

def extraer_tabla_a_pandas(conectarDB):

    query = '''SELECT C.FirstName AS [NOMBRE CLIENTE],
                MAX(T.Name) AS [PISTA],
                MAX(G.Name) AS [GENERO],
                MIN(PL.Name) AS [LISTA DE REPRODUCIÓN MENOS ESCUCHADA],
                COUNT(I.InvoiceId) AS [CANTIDAD DE FACTURAS],
                AVG(I.InvoiceId) AS [PROMEDIO DE FACTURAS],
                SUM(I.Total) AS TOTAL
            FROM employees E
                INNER JOIN customers C ON C.SupportRepId = E.EmployeeId
                INNER JOIN invoices I ON I.CustomerId = C.CustomerId
                INNER JOIN invoice_items IV ON IV.InvoiceId = I.InvoiceId
                INNER JOIN tracks T ON T.TrackId = IV.TrackId
                INNER JOIN media_types M ON M.MediaTypeId = T.MediaTypeId
                INNER JOIN genres G ON G.GenreId = T.GenreId
                INNER JOIN albums A ON A.AlbumId = T.AlbumId
                INNER JOIN artists AR ON AR.ArtistId = A.ArtistId
                INNER JOIN playlist_track P ON P.TrackId = T.TrackId
                INNER JOIN playlists PL ON PL.PlaylistId = P.PlaylistId
            GROUP BY 1
            ORDER BY SUM(I.Total)  DESC
            LIMIT 5;'''
    result = conectarDB.execute(query)

    df = pd.DataFrame(result.fetchall())
    df.columns = result.keys()

    return df

def transformar_facturacion_promedio(datos):

    # Cálculo de promedio por País
    df_g = datos.groupby(['BillingCountry'])[['Total']].mean()
    df_g = df_g.reset_index()
    df_g.rename(columns={"Total": "Promedio"}, inplace=True)

    df = datos.merge(df_g, how="left", left_on="BillingCountry",
                     right_on="BillingCountry")

    return df

def transformar_rellenar_nulo(datos):

    # Procesamiento de completar los valores faltantes
    datos = datos.fillna({"BillingState": "NA", "BillingPostalCode": "99999"})

    return datos

def transformar_formato(datos):
    #df = pd.DataFrame({'InvoiceDate': '%d-%m-%Y'})

    datetime.strftime(datos.InvoiceDate, format='%d-%m-%Y')
    return datos

def exportar_csv(archivo_de_destino,df):
  df.to_csv(archivo_de_destino)

def cargar_a_sql(datos, connectar, tabla_sqlite):

    # Procesamiento de completar los valores faltantes

    datos.to_sql(tabla_sqlite, connectar, if_exists='fail')
    connectar.close()
    return 'La carga ha terminado'

if __name__ == '__main__':
    path = "sqlite:///chinook.db"
    #ruta_destino = r'C:\Users\Usuario\Desktop\PROYECTO_MDB\consulta1.csv'
    # Extracción
    extraerBD = extraer_database(path)

    #nombre_de_tabla = 'Invoices'
    engine = extraerBD[0]
    extraer = extraer_tabla_a_pandas(engine)

    # Transformación
    #transformar = transformar_facturacion_promedio(extraer)
    #transformar = transformar_rellenar_nulo(transformar)

    # carga de los datos
    datos = extraer
    conectar = extraerBD[1]
    tabla_sqlite = "ETL"
    nombre_tabla = "ETL.csv"
    exportar_csv(nombre_tabla,datos)
    cargar_a_sql(datos, conectar, tabla_sqlite)
    print(extraer)
