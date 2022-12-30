----------->>>>>>>>> //      RETO  1       ///  -----------
---- Crear tabla clientes
create table Clientes (
ID_CLI NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
COD_CLIE VARCHAR(10) ,
VAL_APE1 VARCHAR(50),
VAL_APE2 VARCHAR(50),
VAL_NOM1 VARCHAR(50),
VAL_NOM2 VARCHAR(50),
COD_SEXO VARCHAR(5),
FEC_CREA TIMESTAMP,
SAL_DEUD_ANTE DECIMAL(10,2),
FEC_NAC DATE
)

---- Crear tabla pedidos
create table Pedidos (
ID_CLI NUMBER,
FEC_SOLI DATE,
COD_PERI INT,
VAL_NUME_SOLI INT,
FEC_FACT DATE,
VAL_ORIG VARCHAR(20),
COD_CLIE INT ,
COD_REGI INT ,
COD_ZONA INT ,
COD_SEEC VARCHAR(5) ,
SAL_DEUD_ANTE DECIMAL(10,2),
VAL_MONT_ESTI DECIMAL(10,2),
VAL_MONT_SOLI DECIMAL(10,2),    
VAL_ESTA_PEDI VARCHAR(20),
MOT_RECH VARCHAR(20),
VAL_MONT_FLET DECIMAL(10,2),
VAL_UNID_LBEL INT ,
VAL_UNID_CYZO INT ,
VAL_UNID_ESIK INT 
)


------ RELACION (PK-FK)
ALTER TABLE Pedidos ADD FOREIGN KEY (ID_CLI) REFERENCES Clientes (ID_CLI);

----- IMPORTAR EXCEL A TABLAS
----- Realizado mediante csv (importación)

SELECT * FROM CLIENTES WHERE COD_CLIE='6254055';
SELECT * FROM Pedidos WHERE ID_CLI IS NOT NULL;

UPDATE (SELECT P.ID_CLI , C.ID_CLI AS CLIENTE  FROM Pedidos P
INNER JOIN Clientes c on c.COD_CLIE = P.COD_CLIE
) T SET T.ID_CLI = T.CLIENTE;

 
--------------------> ESTRUCTURAS DE CONTROL


----------->>>>>>>>> //      RETO  2       ///   -----------
----- AGREGANDO NUEVOS CAMPOS
ALTER TABLE Clientes add NOM_CORTO VARCHAR(100)
ALTER TABLE Clientes add EDAD NUMBER(3,0)


----- insertando data en NOM_CORTO 
----- CONSIDRACIÓN; la primera letra de cada atributo se conserve en Mayúscula y el resto en minúscula.
 

CREATE OR REPLACE PROCEDURE nom_union (client_id IN NUMBER)
 AS
 BEGIN
   
   
  UPDATE clientes
  SET NOM_CORTO = INITCAP(VAL_NOM1) || ' ' || INITCAP(VAL_APE1);
   
 END;

 EXEC nom_union(255)


---- Calcular la edad 

CREATE OR REPLACE PROCEDURE update_age (client_id IN NUMBER)

AS
 BEGIN

  UPDATE Clientes
  SET EDAD =  TRUNC(MONTHS_BETWEEN(SYSDATE, FEC_NAC) / 12);
 

END;

EXEC update_age(255)


---------------- sentencia que reemplace la letra “Ñ” por la letra “N” en los atributos VAL_APE1 y VAL_APE2 de la tabla Clientes
--------VAL_APE1 
CREATE OR REPLACE PROCEDURE change_ape1 (client_id IN NUMBER)
AS
  
BEGIN
   
  UPDATE Clientes
  SET VAL_APE1 = REPLACE(VAL_APE1, 'Ñ', 'N');
   
END;
EXEC change_ape1(255)

--------VAL_APE2

CREATE OR REPLACE PROCEDURE change_ape2 (client_id IN NUMBER)
 AS
 BEGIN
      
  UPDATE Clientes
  SET  VAL_APE2 = REPLACE(VAL_APE2, 'Ñ', 'N');
   
 END;

EXEC change_ape2(255)


----------->>>>>>>>> //      RETO  3       ///   ----------- 
------INNER JOIN crear vistas que generen:
------- Clientes que no tienen pedido facturado
------- Pedidos cuyo cliente no existe en la tabla Clientes

CREATE VIEW Vista as (SELECT P.COD_CLIE, P.VAL_ESTA_PEDI
FROM PEDIDOS P 
LEFT JOIN CLIENTES c on c.COD_CLIE = P.COD_CLIE
WHERE P.ID_CLI IS NULL AND P.VAL_ESTA_PEDI LIKE '%RECHAZADO%' );

SELECT*FROM VISTA;



----------- 	Crear vistas para mostrar:
----------- Acumulado de atributo VAL_MONT_SOLI agrupado por estado de Pedido, 
----------- Región de aquellos pedidos facturados en junio, considerar para ello que el codigo de cliente exista en la tabla Cliente

CREATE VIEW  MonTotal as (SELECT SUM( VAL_MONT_SOLI)AS MONTO_T,  VAL_ESTA_PEDI 
FROM PEDIDOS   
GROUP BY  VAL_ESTA_PEDI );

SELECT*FROM MonTotal ;



SELECT*FROM V_Pedido;
CREATE VIEW  V_Pedido as (SELECT SUM(P.VAL_MONT_SOLI)AS MONTO_T, P.VAL_ESTA_PEDI,P.COD_REGI, P.FEC_FACT,P.COD_CLIE 
FROM PEDIDOS P
LEFT JOIN CLIENTES c on c.COD_CLIE = P.COD_CLIE
WHERE P.VAL_ESTA_PEDI like '%FACTURADO%' AND  extract(month from P.FEC_FACT) = 6 and P.ID_CLI IS NOT NULL
GROUP BY P.VAL_ESTA_PEDI,P.COD_REGI,P.FEC_FACT,P.COD_CLIE);

SELECT*FROM V_Pedido;
 


----------- En base a la consulta anterior, mostrar una columna adicional que contenga el total de registros por cada agrupación y 
----------- condicionar a que se muestre solo aquellos que tengan más de 500 registros agrupados
  
  
 SELECT MONTO_T,VAL_ESTA_PEDI,COD_REGI, FEC_FACT, COD_CLIE , COUNT(*) AS total_can
FROM V_Pedido
GROUP BY MONTO_T,VAL_ESTA_PEDI,COD_REGI, FEC_FACT, COD_CLIE 
HAVING COUNT(*) > 500





