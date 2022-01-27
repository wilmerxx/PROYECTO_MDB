import sqlite3 
import numpy
import glob 
from datetime import datetime
import pandas as pd
import sqlalchemy

'''Procesos de ETL'''

def extraer_database(path):

    motorDB = sqlalchemy.create_engine(path)
    conectarDB = motorDB.connect()
    
    return motorDB, conectarDB

def extraer_tabla_a_pandas(nombreTabla, conectarDB):
  
    query = "SELECT * FROM {}".format(nombreTabla)
    result = conectarDB.execute(query)

    df = pd.DataFrame(result.fetchall())
    df.columns = result.keys()
    
    return df

def transformar_facturacion_promedio(datos):

    # Cálculo de promedio por País
    df_g = datos.groupby(['BillingCountry'])[['Total']].mean()
    df_g = df_g.reset_index()
    df_g.rename(columns = {"Total":"Promedio"}, inplace=True)
    
    df = datos.merge(df_g, how="left", left_on = "BillingCountry", right_on = "BillingCountry")

    return df

def transformar_rellenar_nulo(datos):
 
    # Procesamiento de completar los valores faltantes
    datos = datos.fillna({"BillingState": "nada", "BillingPostalCode":"99999"})

    return datos  

def transformar_formato(datos):
     #df = pd.DataFrame({'InvoiceDate': '%d-%m-%Y'})
     
     datetime.strftime(datos.InvoiceDate, format = '%d-%m-%Y')
     return datos


def cargar_a_sql(datos, connectar, tabla_sqlite):
  
    # Procesamiento de completar los valores faltantes
   
    datos.to_sql(tabla_sqlite, connectar, if_exists='fail')
    connectar.close()
    return 'La carga ha terminado'
    
if __name__ == '__main__':
 path = "sqlite:///chinook.db"

 # Extracción
 extraerBD = extraer_database(path)

 nombre_de_tabla = 'Invoices'
 engine = extraerBD[0]
 extraer = extraer_tabla_a_pandas(nombre_de_tabla, engine)

 # Transformación
 transformar = transformar_facturacion_promedio(extraer)
 transformar = transformar_rellenar_nulo(transformar)

 # carga de los datos
 datos = transformar
 conectar = extraerBD[1]
 tabla_sqlite = "invoiceNueva"
 cargar_a_sql(datos, conectar, tabla_sqlite)
 print(transformar)
