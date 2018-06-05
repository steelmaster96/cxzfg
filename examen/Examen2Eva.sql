--Sergio Zulueta

--SUBPARTE 1
/*1. Obtener la relacion de trabajos que se estan realizando en la localidad de Arganda. 
Se sacara el codigo del proyecto, con la cabecera del proyecto, la descripcion del proyecto
y el identificador del trabajo, saldra ordenado por proyecto*/

SELECT T.COD_P PROYECTO, P.DESCRIPCION, T.ID_TRABAJOS
FROM PROYECTOS P, TRABAJOS T
WHERE T.COD_P = P.COD_P
AND P.LOCALIDAD = 'Arganda'
ORDER BY T.COD_P;

/*2. Obtener el nombre de los conductores que hayan trabajado con una Hormigonera,
ordenados por descendente*/

SELECT DISTINCT C.NOMBRE AS "NOMBRE CONDUCTOR"
FROM CONDUCTORES C, TRABAJOS T, MAQUINAS M
WHERE C.COD_C = T.COD_C AND T.COD_M = M.COD_M
AND LOWER(M.NOMBRE) = 'hormigonera'
ORDER BY C.NOMBRE DESC;
--
SELECT NOMBRE
FROM CONDUCTORES
WHERE COD_C IN
    (SELECT COD_C
        FROM TRABAJOS
        WHERE COD_M IN (SELECT COD_M
                        FROM MAQUINAS
                        WHERE Initcap(nombre)='Hormigonera'))
ORDER BY NOMBRE DESC;

/*3. Obtener los conductores que habiendo trabajado en algun proyecto figuren sin horas
trabajadas, es decir no han destinado ningun tiempo al trabajo*/

SELECT DISTINCT CONDUCTORES.*
FROM CONDUCTORES, TRABAJOS
WHERE TRABAJOS.COD_C = CONDUCTORES.COD_C AND
TIEMPO IS NULL;

/*4. Obtener el nombre de los conductores, el nombre de los clientes y la localidad del/los
proyectos, en los que se haya utilizado la maquina con precio hora mas elevado*/

SELECT C.NOMBRE, P.CLIENTE, P.LOCALIDAD AS LOCALIDADPROYECTO
FROM CONDUCTORES C, PROYECTOS P, TRABAJOS T, MAQUINAS M
WHERE C.COD_C = T.COD_C AND
    P.COD_P=T.COD_P AND
    M.COD_M=T.COD_M AND
    M.PRECIOHORA = (SELECT MAX(PRECIOHORA)
                    FROM MAQUINAS);

/*5. Obtener el numero de partes de trabajo (con la cabecera numero de trabajos); el codigo
del proyecto, la descripcion y el cliente para aquel proyecto que figure con mas partes de trabajo*/

SELECT PROYECTOS.COD_P, DESCRIPCION, CLIENTE, COUNT(*) AS "NUMERO DE TRABAJOS"
FROM PROYECTOS, TRABAJOS
WHERE PROYECTOS.COD_P = TRABAJOS.COD_P
GROUP BY PROYECTOS.COD_P, DESCRIPCION, CLIENTE
HAVING COUNT(*) >=ALL (SELECT COUNT(*)
                        FROM TRABAJOS
                        GROUP BY COD_P);

/*6. Obtener los codigos de los conductores que hayan utilizado las maquinas M04 y la maquina M03*/

SELECT COD_C
FROM TRABAJOS WHERE COD_M = 'M03'
INTERSECT
SELECT COD_C 
FROM TRABAJOS WHERE COD_M = 'M04';

--SUBPARTE 2

/*7. Subir el precio por hora en un 10% del precio por hora mas bajo para todas las maquinas.
Tras la comprobacion deshaces la transaccion*/

UPDATE MAQUINAS
SET PRECIOHORA = PRECIOHORA + (SELECT MIN(PRECIOHORA)*0.1
FROM MAQUINAS);

ROLLBACK MAQUINAS;

/*8. Elimina el proyecto de nombre Solado de Jose Perez. Tras la comprobacion deshaces la transaccion*/

DELETE
FROM PROYECTOS
WHERE INITCAP(DESCRIPCION) = 'Solado' AND
INITCAP(cliente) = 'Jose Perez';

DELETE FROM TRABAJOS
WHERE COD_P = (SELECT COD_P
                FROM PROYECTOS
                WHERE UPPER(DESCRIPCION)='SOLADO' AND UPPER(CLIENTE)='JOSE PEREZ');

DELETE FROM PROYECTOS 
WHERE UPPER(DESCRIPCION)='SOLADO' AND UPPER(CLIENTE)='JOSE PEREZ';

ROLLBACK PROYECTOS;

/*9. Modificar la estructura de la tabla para añadir a la tabla conductores una columna denominada
Formacion, en la cual solo se podra almacenar la cadena s o n, dependiendo de si ha cursado el curso
de prevencion de riesgos o no*/

ALTER TABLE CONDUCTORES ADD(
    FORMACION VARCHAR(1) ,
    CONSTRAINT F_CH CHECK(FORMACION IN ('S','N')));

/*10. Elimina este nuevo campo*/

ALTER TABLE CONDUCTORES DROP (FORMACION);

--SUBPARTE 3

/*11. Crear una vista, llamada v_trab_sep_2002, sobre la tabla trabajos, para los trabajos realizados
despues del 15 de septiembre de 2002. Los nombres de las columnas seran conductor, maquina, proyecto,
fecha, tiempo La vista nos permitira hacer inserciones en su dominio
Inserta utilizanco la vista 'C01','M01','P01','03/sep/02',10. Razona*/

CREATE VIEW V_TRAB_SEP_2002 (CONDUCTOR, MAQUINA, PROYECTO, FECHA, TIEMPO)
AS SELECT COD_C, COD_M, COD_P, FECHA, TIEMPO
FROM TRABAJOS
WHERE FECHA > TO_DATE('15/SEP/2002','DD/MM/YYYY')
WITH CHECK OPTION;

INSERT INTO V_TRAB_SEP_2002
VALUES ('C01','M01','P01',TO_DATE('03/SEP/02','DD/MM/YYYY'),10);

/*12. Crea un sinonimo para la vista creada en el apartado anterior para que todos los usuarios
puedan acceder a ella con el nombre trab_sep*/

CREATE PUBLIC SYNONYM TRAB_SEP FOR V_TRAB_SEP_2002;
