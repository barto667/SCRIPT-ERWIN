Habiliotar conexiones remotas postgres
 Ve a la siguiente ruta y abre el archivo pg_hba.conf :
 C:\Program Files\PostgreSQL\9.6\data
 Encuentra la siguiente línea:
 host    all             all             127.0.0.1/32            md5
 Abajo de la línea anterior agrega lo siguiente:
 host all all x.x.x.1/24 md5

 Bases de datos de prueba
 CREATE DATABASE "dbInterface"
     WITH 
     OWNER = postgres
     ENCODING = 'UTF8'
     CONNECTION LIMIT = -1;

 CREATE TABLE public."aVenta"
 (
     "veID" bigserial,
     "veCara" integer,
     "veManguera" integer,
     "veProducto" text,
     "vePago" numeric(10, 6),
     "vePrecio" numeric(10, 6),
     "veVolumen" numeric(10, 6),
     "veImporte" numeric(10, 6),
     "veHoraPC" date,
     "veHoraCS" date,
     "veEstado" integer,
     PRIMARY KEY ("veID")
 )
 WITH (
     OIDS = FALSE
 );

 ALTER TABLE public."aVenta"
     OWNER to postgres;

 CREATE TABLE public."aComandos"
 (
     "cmID" bigserial,
     "cmNumero" integer,
     "cmValor" integer,
     PRIMARY KEY ("cmID")
 )
 WITH (
     OIDS = FALSE
 );

 ALTER TABLE public."aComandos"
     OWNER to postgres;

 CREATE TABLE public."aProductos"
 (
     "pdID" bigserial,
     "pdCodigo" text,
     "pdPrecio1" numeric(10, 6),
     "pdPrecio2" numeric(10, 6),
     PRIMARY KEY ("pdID")
 )
 WITH (
     OIDS = FALSE
 );

 CREATE TABLE public."aTotalizadorH"
 (
     "thID" bigserial,
     "thHora" date,
     "thTipo" integer,
     "thCara" integer,
     "thManguera" integer,
     "thImporte" numeric(10, 6),
     "thVolumen" numeric(10, 6),
     PRIMARY KEY ("thID")
 )
 WITH (
     OIDS = FALSE
 );

 CREATE TABLE public."aTurno"
 (
     "tnID" bigserial,
     "tnHora" date,
     "tnTipo" integer,
     "tnveID" integer,
     "tnthID" integer,
     PRIMARY KEY ("tnID")
 )
 WITH (
     OIDS = FALSE
 );

 --Trabajo
 --Crear tabla temporal
 CREATE TABLE public."tempaventas"
 (
     "temp_id" bigserial,
     "temp_codcaja" character varying(6),
     "temp_codmanguera" character varying(6),
     "temp_codproducto" character varying(6),
     "temp_preciounitario" numeric(20, 6),
     "temp_cantidad" numeric(20, 6),
     "temp_importe" numeric(20, 6),
     "temp_contometro" numeric(20, 6),
     "temp_idventa" bigint,
     PRIMARY KEY ("temp_id"),
     UNIQUE ("temp_id"),
     FOREIGN KEY ("temp_idventa")
         REFERENCES public."aVenta" ("veID") MATCH SIMPLE
         ON UPDATE NO ACTION
         ON DELETE NO ACTION
 )
 WITH (
     OIDS = FALSE
 );

 ALTER TABLE public."tempaventas"
     OWNER to postgres;


/*
Funcion que inserta valores en la tabla temporal
CREATE OR REPLACE FUNCTION fn_InsertarDatosTempAVentas() RETURNS TRIGGER AS
$BODY$
DECLARE
    aux_CodManguera character varying(6):='';
    aux_CodSucursal character varying(2):='';
    aux_CodAlfManguera character varying(2):='';
BEGIN
    IF (NEW."veManguera" = 0)  then
        aux_CodAlfManguera:='A';
        END IF;
    IF (NEW."veManguera" = 1) then
        aux_CodAlfManguera:='B';
        END IF;
    IF (NEW."veManguera" = 2 ) then
        aux_CodAlfManguera:='C';
        END IF;
    IF (NEW."veManguera" = 3) then
        aux_CodAlfManguera:='D';
        END IF;
    IF (NEW."veManguera" = 4 ) then
        aux_CodAlfManguera:='E';
        END IF;
    IF (NEW."veManguera" = 5) then
        aux_CodAlfManguera:='F';
        END IF;
    IF (NEW."veCara" IN (0,1)) then
        aux_CodSucursal:='1';
        END IF;
    IF (NEW."veCara" IN (2,3)) then
        aux_CodSucursal:='2';
        END IF;
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||NEW."veProducto";
    INSERT INTO
        tempaventas(temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_horapc,temp_horacs,temp_idventa)
        VALUES(aux_CodManguera,NEW."veProducto",NEW."vePrecio",NEW."veVolumen",NEW."veImporte",NEW."veHoraPC",NEW."veHoraCS",NEW."veID");
    RETURN NEW;
END;
$BODY$
language plpgsql;*/


--Funcion que inserta valores en la tabla temporal
CREATE OR REPLACE FUNCTION fn_InsertarDatosTempAVentas() RETURNS TRIGGER AS
$BODY$
DECLARE
    aux_CodManguera character varying(6):='';
    aux_CodSucursal character varying(2):='';
    aux_CodAlfManguera character varying(2):='';
    aux_CodCaja character varying(3):='101';
    aux_CodProducto character varying(5):='';
BEGIN
    --Numeracion amnguera
    CASE WHEN NEW."veManguera" = 0  then
        aux_CodAlfManguera:='A';
    WHEN NEW."veManguera" = 1 then
        aux_CodAlfManguera:='B';
    WHEN NEW."veManguera" = 2 then
        aux_CodAlfManguera:='C';
    WHEN NEW."veManguera" = 3 then
        aux_CodAlfManguera:='D';
    WHEN NEW."veManguera" = 4 then
        aux_CodAlfManguera:='E';
    WHEN NEW."veManguera" = 5 then
        aux_CodAlfManguera:='F';
    END CASE;
    
    --Numeracion sucursal
    CASE WHEN NEW."veCara" IN (0,1) then
        aux_CodSucursal:='1';
    WHEN NEW."veCara" IN (2,3) then
        aux_CodSucursal:='2';
    END CASE;
    
     CodTiposProductos, por definir
    CASE WHEN NEW."veProducto"='B5' then
        aux_CodProducto:='B5';
    WHEN NEW."veProducto"='G84' then
        aux_CodProducto:='G84';
    WHEN NEW."veProducto"='G90' then
        aux_CodProducto:='G90';
    WHEN NEW."veProducto"='G95' then
        aux_CodProducto:='G95';
    WHEN NEW."veProducto"='G98' then
        aux_CodProducto:='G98';
    WHEN NEW."veProducto"='GLP' then
        aux_CodProducto:='GLP';
    END CASE;
    
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||NEW."veProducto";
    --Insercion en la temporal
    INSERT INTO
        tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa)
        VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,NEW."vePrecio",NEW."veVolumen",NEW."veImporte",0,NEW."veID");
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aVenta"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_insertardatostempaventas();

--INSERCION PRUEBA
INSERT INTO public."aVenta"(
    "veCara", "veManguera", "veProducto", "vePago", "vePrecio", "veVolumen", "veImporte", "veHoraPC", "veHoraCS", "veEstado")
    VALUES ( 0, 0, 'B5', 1, 10, 10, 100, current_date, current_date, 0);

/*
Recuperar primer registro de la cola de la tabla temporal
CREATE OR REPLACE FUNCTION usp_recuperarprimerregistro()
RETURNS SETOF tempaventas AS
$BODY$
BEGIN
    RETURN query
        select * from tempaventas order by temp_id asc limit 1 offset 0;
END;
$BODY$
LANGUAGE plpgsql */



--Funcion que inserta valores en la tabla temporal
-- CREATE OR REPLACE FUNCTION fn_InsertarDatosTempAVentas() RETURNS TRIGGER AS
-- $BODY$
-- DECLARE
--     aux_CodManguera character varying(6):='';
--     aux_CodSucursal character varying(2):='';
--     aux_CodAlfManguera character varying(2):='';
--     aux_CodCaja character varying(3):='';
--     aux_CodProducto character varying(5):='';
--     aux_FinProducto character varying(5):='';
--     aux_MedicionContometro numeric(32, 3):=0;

-- BEGIN
--     --Numeracion sucursal
--     CASE WHEN NEW."veCara" IN (0,1) then
--         aux_CodSucursal:='21';
--     WHEN NEW."veCara" IN (2,3) then
--         aux_CodSucursal:='22';
--     END CASE;

--      --Numeracion manguera
--     CASE 
--         WHEN NEW."veCara" = 0 then
--             CASE 
--                 WHEN NEW."veManguera" = 0 then
--                     aux_CodAlfManguera:='C';
--                 WHEN NEW."veManguera" = 1 then
--                     aux_CodAlfManguera:='B';
--                 WHEN NEW."veManguera" = 2 then
--                     aux_CodAlfManguera:='A';
--             END CASE;
--         WHEN NEW."veCara" = 1 then
--             CASE 
--                 WHEN NEW."veManguera" = 0 then
--                     aux_CodAlfManguera:='F';
--                 WHEN NEW."veManguera" = 1 then
--                     aux_CodAlfManguera:='E';
--                 WHEN NEW."veManguera" = 2 then
--                     aux_CodAlfManguera:='D';
--             END CASE;
--         WHEN NEW."veCara" = 2 then
--             CASE 
--                 WHEN NEW."veManguera" = 0 then
--                     aux_CodAlfManguera:='A';
--                 WHEN NEW."veManguera" = 1 then
--                     aux_CodAlfManguera:='B';
--                 WHEN NEW."veManguera" = 2 then
--                     aux_CodAlfManguera:='C';
--             END CASE;
--         WHEN NEW."veCara" = 3 then
--             CASE 
--                 WHEN NEW."veManguera" = 0 then
--                     aux_CodAlfManguera:='D';
--                 WHEN NEW."veManguera" = 1 then
--                     aux_CodAlfManguera:='E';
--                 WHEN NEW."veManguera" = 2 then
--                     aux_CodAlfManguera:='F';
--             END CASE;
--     END CASE;
    

--     --CodTiposProductos
--     CASE WHEN NEW."veManguera"=0 then
--         aux_CodProducto:='B5';
--     WHEN NEW."veManguera"=1 then
--         aux_CodProducto:='G90';
--     WHEN NEW."veManguera"=2 then
--         aux_CodProducto:='G84';
--     END CASE;

--     --Cod de caja
--     CASE WHEN NEW."veCara" IN (0,1) then
--         aux_CodCaja:='201';
--     WHEN NEW."veCara" IN (2,3) then
--         aux_CodCaja:='202';
--     END CASE;

--     --Definimos final de la cadena
--     CASE WHEN NEW."veManguera"=0 then
--         aux_FinProducto:='B5';
--     WHEN NEW."veManguera"=1 then
--         aux_FinProducto:='90';
--     WHEN NEW."veManguera"=2 then
--         aux_FinProducto:='84';
--     END CASE;

    
--     --Codigo manguera
--     aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||aux_FinProducto;

--     --Recuperamos el dato de medicion del contometro
--     aux_MedicionContometro:= (SELECT  "thVolumen" FROM "aTotalizadorH" as th INNER JOIN "aVenta" as av ON th."thHora"=av."veHoraPC"
--     WHERE av."veID"=NEW."veID"
--     order by th."thHora" desc
--     limit 1
--     );

--     --Insercion en la temporal
--     INSERT INTO
--         tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa)
--         VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,NEW."vePrecio",NEW."veVolumen",NEW."veImporte",aux_MedicionContometro,NEW."veID");
--     RETURN NEW;
-- END;
-- $BODY$
-- language plpgsql;


-- --Trigger
-- CREATE TRIGGER "trig_aVenta"
--     AFTER INSERT
--     ON public."aVenta"
--     FOR EACH ROW
--     EXECUTE PROCEDURE public.fn_insertardatostempaventas();







--PUCKUIRA

 CREATE TABLE public."tempaventas"
 (
     "temp_id" bigserial,
     "temp_codcaja" character varying(6),
     "temp_codmanguera" character varying(6),
     "temp_codproducto" character varying(6),
     "temp_preciounitario" numeric(20, 3),
     "temp_cantidad" numeric(20, 3),
     "temp_importe" numeric(20, 2),
     "temp_contometro" numeric(32, 3),
     "temp_idventa" bigint,
     
     PRIMARY KEY ("temp_id"),
     UNIQUE ("temp_id"),
     FOREIGN KEY ("temp_idventa")
         REFERENCES public."aVenta" ("veID") MATCH SIMPLE
         ON UPDATE NO ACTION
         ON DELETE NO ACTION
 )
 WITH (
     OIDS = FALSE
 );

 ALTER TABLE public."tempaventas"
     OWNER to postgres;





--Funcion que inserta valores en la tabla temporal
CREATE OR REPLACE FUNCTION fn_InsertarDatosTempAVentas() RETURNS TRIGGER AS
$BODY$
DECLARE
    aux_CodManguera character varying(6):='';
    aux_CodSucursal character varying(2):='';
    aux_CodAlfManguera character varying(2):='';
    aux_CodCaja character varying(3):='';
    aux_CodProducto character varying(5):='';
    aux_FinProducto character varying(5):='';
    aux_PrecioUnitario numeric(20,3):=0;
    aux_Cantidad numeric(20, 3):=0;
    aux_IdVenta bigint:=0;
    aux_Importe numeric(20, 3):=0;

BEGIN
    --Numeracion sucursal
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='21';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='22';
    END CASE;

     --Numeracion manguera
    CASE 
        WHEN NEW."thCara" = 0 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='C';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='A';
            END CASE;
        WHEN NEW."thCara" = 1 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='F';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='D';
            END CASE;
        WHEN NEW."thCara" = 2 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
            END CASE;
        WHEN NEW."thCara" = 3 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='D';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='F';
            END CASE;
    END CASE;
    

    --CodTiposProductos
    CASE WHEN NEW."thManguera"=0 then
        aux_CodProducto:='B5';
    WHEN NEW."thManguera"=1 then
        aux_CodProducto:='G90';
    WHEN NEW."thManguera"=2 then
        aux_CodProducto:='G84';
    END CASE;

    --Cod de caja
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodCaja:='201';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodCaja:='202';
    END CASE;

    --Definimos final de la cadena
    CASE WHEN NEW."thManguera"=0 then
        aux_FinProducto:='B5';
    WHEN NEW."thManguera"=1 then
        aux_FinProducto:='90';
    WHEN NEW."thManguera"=2 then
        aux_FinProducto:='84';
    END CASE;

    
    --Codigo manguera
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||aux_FinProducto;

    --Necesitamos recuperar el PU, cantidad, id venta
    SELECT "vePrecio","veVolumen", "veImporte","veID" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta<>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;


--Trigger
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_insertardatostempaventas();


--SELECT * FROM "tempaventas"
--DROP TABLE "tempaventas"
--DROP TRIGGER "trig_aVenta" ON public."aTotalizadorH"
--SELECT * from "aVenta" where "veID"=2045
--select * from "aTotalizadorH"





