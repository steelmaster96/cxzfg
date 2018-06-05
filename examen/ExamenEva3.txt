--SUBPARTE 1

set SERVEROUT ON;

/*1. Crea un procedimiento anonimo para probar el procedimiento almacenado que encontraras 
en ikas dentro del fichero
haz la prueba para la jornada 1
En la solucion debe aparecer el resultado de la ejecucion del procedimiento anonimo*/

DECLARE
    V_JORNADA INTEGER;
    C_PARTIDOS SYS_REFCURSOR;
    V_COD PARTIDOS.COD%TYPE;
    V_FECHA PARTIDOS.FECHA%TYPE;
    V_EQUIPO_LOCAL PARTIDOS.CODEQUIPO_LOCAL%TYPE;
    V_EQUIPO_VISITANTE PARTIDOS.CODEQUIPO_VISITANTE%TYPE;
BEGIN
    ResulPartidosPorJornada(0, C_PARTIDOS);
    LOOP
        FETCH C_PARTIDOS INTO V_COD, V_FECHA, V_EQUIPO_LOCAL, V_EQUIPO_VISITANTE;
            EXIT WHEN C_PARTIDOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(V_COD||' '||V_FECHA||' '||V_EQUIPO_LOCAL||' '||V_EQUIPO_VISITANTE);
    END LOOP;
END;

/*2. Modifica el procedimiento almacenado resulpartidosporjornada anterior para que se denomine
resulpartidosporjornada_yy y devuelva, ademas de los datos actuales, los nombres de los equipos
local y visitante, asi como los puntos obtenidos en cada partido jugado*/

CREATE OR REPLACE PROCEDURE ResulPartidosPorJornada_07
(P_COD_JOR INTEGER, C_PARTIDOS OUT SYS_REFCURSOR) AS
BEGIN
OPEN C_PARTIDOS FOR
    SELECT P.COD, P.FECHA,
            P.CODEQUIPO_LOCAL, EL.NOMBRE, P.RESULTADOEL,
            P.CODEQUIPO_VISITANTE, EV.NOMBRE, P.RESULTADOEV
    FROM JORNADAS J, PARTIDOS P, EQUIPOS EL, EQUIPOS EV
    WHERE P.JORNADA_COD = J.COD
    AND J.COD=P_COD_JOR
    AND P.JUGADO= 'S'
    AND EV.COD = P.CODEQUIPO_VISITANTE
    AND EL.COD = P.CODEQUIPO_LOCAL;
END;
--LLENARLO
DECLARE
    V_JORNADA INTEGER;
    C_PARTIDOS SYS_REFCURSOR;
    V_COD PARTIDOS.COD%TYPE;    
    V_FECHA PARTIDOS.FECHA%TYPE;
    V_EQUIPO_LOCAL PARTIDOS.CODEQUIPO_LOCAL%TYPE;
    V_EQUIPO_VISITANTE PARTIDOS.CODEQUIPO_VISITANTE%TYPE;
BEGIN
    ResulPartidosPorJornada_07(1, C_PARTIDOS);
    LOOP
        FETCH C_PARTIDOS INTO V_COD, V_FECHA, V_EQUIPO_LOCAL, V_EQUIPO_VISITANTE;
            EXIT WHEN C_PARTIDOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(V_COD||' '||V_FECHA||' '||V_EQUIPO_LOCAL||' '||V_EQUIPO_VISITANTE);
    END LOOP;
END;

--SUBPARTE 2

/*3. Codifica el trigger llamado maximo_num_jugador_yy 
El trigger debe garantizar que un equipo no puede tener mas de 5 jugadores. tener en cuenta que un 
jugador puede cambiar de equipo durante la temporada
prueba el trigger:
cambia el jugador jug15 del equipo 2 al equipo 1. Adjunta pant
inserta un jugador nuevo. adjunta pant*/

CREATE OR REPLACE PACKAGE PAQUETE_TRIGGER AS
    NEW_JUG JUGADORES%ROWTYPE:=NULL;
END;
/
CREATE OR REPLACE TRIGGER MUTANTE 
    AFTER INSERT OR UPDATE
    OF EQUIPO_COD ON JUGADORES FOR EACH ROW
BEGIN
    IF INSERTING THEN
        PAQUETE_TRIGGER.NEW_JUG.NOMBRE:= :NEW.NOMBRE;
        PAQUETE_TRIGGER.NEW_JUG.APELLIDO:= :NEW.APELLIDO;
        PAQUETE_TRIGGER.NEW_JUG.NICKNAME:= :NEW.NICKNAME;
        PAQUETE_TRIGGER.NEW_JUG.SUELDO:= :NEW.SUELDO;
        PAQUETE_TRIGGER.NEW_JUG.EQUIPO_COD:= :NEW.EQUIPO_COD;
    END IF;
    IF UPDATING THEN
        PAQUETE_TRIGGER.NEW_JUG.EQUIPO_COD:= :NEW.EQUIPO_COD;
    END IF;
END;
/
CREATE OR REPLACE TRIGGER MAXIMO_JUGADORES
    AFTER INSERT OR UPDATE
    OF EQUIPO_COD ON JUGADORES
DECLARE
    V_CAN INTEGER;
    MAX_JUG EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO V_CAN FROM JUGADORES
    WHERE EQUIPO_COD = PAQUETE_TRIGGER.NEW_JUG.EQUIPO_COD;
    IF (V_CAN > 5) THEN
        RAISE MAX_JUG;
    END IF;
EXCEPTION
    WHEN MAX_JUG THEN
        DBMS_OUTPUT.PUT_LINE('LIMITE DE JUGADORES ALCANZADO');
END;