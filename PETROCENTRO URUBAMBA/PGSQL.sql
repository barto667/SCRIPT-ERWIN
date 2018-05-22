--GENERALES PARA TODOS
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
     "temp_fecha" timestamp,
     
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



--Tabla temporal de productos
CREATE TABLE public."tempaproductos"
 (
     "temp_id" bigserial,
     "temp_codproducto" character varying(6),
     "temp_precio1" numeric(20, 3),
     "temp_precio2" numeric(20, 3),
     PRIMARY KEY ("temp_id"),
     UNIQUE ("temp_id")
 )
 WITH (
     OIDS = FALSE
 );

 ALTER TABLE public."tempaproductos"
     OWNER to postgres;


--Funcion que inserta valores en la tabla temporal (solo sobre update)
CREATE OR REPLACE FUNCTION fn_InsertarDatosTempAProductos() RETURNS TRIGGER AS
$BODY$
BEGIN
        --Insertamos el nuevo campo, despues ya se eliminara
        INSERT INTO tempaproductos(temp_codproducto,temp_precio1,temp_precio2)
        VALUES(NEW."pdCodigo",NEW."pdPrecio1",NEW."pdPrecio2");
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigger
CREATE TRIGGER "trig_aProducto"
    AFTER UPDATE
    ON public."aProductos"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAProductos();




--Procedimientos por cada sucursal

-- 1 PUCKUIRA
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
    aux_FechaHora timestamp;

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
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();



-- 2 ANTA
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
    aux_FechaHora timestamp;

BEGIN
    --Numeracion sucursal
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='31';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='32';
    WHEN NEW."thCara" IN (4,5) then
        aux_CodSucursal:='33';
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
        WHEN NEW."thCara" = 4 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
            END CASE;
        WHEN NEW."thCara" = 5 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='F';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='D';
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
        aux_CodCaja:='301';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodCaja:='302';
    WHEN NEW."thCara" IN (4,5) then
        aux_CodCaja:='303';
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
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();




-- 3 Yanahuara
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
    aux_FechaHora timestamp;

BEGIN
    --Numeracion sucursal
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='51';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='52';
    END CASE;

     --Numeracion manguera
    CASE 
        WHEN NEW."thCara" = 0 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
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
        aux_CodCaja:='501';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodCaja:='502';
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
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();



-- 4 URUBAMBA
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
    aux_FechaHora timestamp;

BEGIN
    --Numeracion sucursal
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='41';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='42';
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
        aux_CodProducto:='G84';
    WHEN NEW."thManguera"=2 then
        aux_CodProducto:='G90';
    END CASE;

    --Cod de caja
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodCaja:='401';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodCaja:='402';
    END CASE;

    --Definimos final de la cadena
    CASE WHEN NEW."thManguera"=0 then
        aux_FinProducto:='B5';
    WHEN NEW."thManguera"=1 then
        aux_FinProducto:='84';
    WHEN NEW."thManguera"=2 then
        aux_FinProducto:='90';
    END CASE;

    
    --Codigo manguera
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||aux_FinProducto;

    --Necesitamos recuperar el PU, cantidad, id venta
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();





-- 5 ARCOPATA
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
    aux_FechaHora timestamp;

BEGIN
    --Numeracion sucursal
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='61';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='62';
    END CASE;

     --Numeracion manguera
    CASE 
        WHEN NEW."thCara" = 0 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='C';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='B';
            END CASE;
        WHEN NEW."thCara" = 1 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='F';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='D';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='E';
            END CASE;
        WHEN NEW."thCara" = 2 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
                WHEN NEW."thManguera" = 3 then
                    aux_CodAlfManguera:='D';
            END CASE;
        WHEN NEW."thCara" = 3 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='H';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='G';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='F';
                WHEN NEW."thManguera" = 3 then
                    aux_CodAlfManguera:='E';
            END CASE;        
    END CASE;

    --Cod producto
    CASE WHEN NEW."thCara" IN (0,1) then
        CASE WHEN NEW."thManguera"=0 then
            aux_CodProducto:='G90';
        WHEN NEW."thManguera"=1 then
            aux_CodProducto:='B5';
        WHEN NEW."thManguera"=2 then
            aux_CodProducto:='G84';
        END CASE;
    WHEN NEW."thCara" IN (2,3) then
        CASE WHEN NEW."thManguera"=0 then
        aux_CodProducto:='G90';
        WHEN NEW."thManguera"=1 then
            aux_CodProducto:='B5';
        WHEN NEW."thManguera"=2 then
            aux_CodProducto:='G95';
        WHEN NEW."thManguera"=3 then
            aux_CodProducto:='G84';
        END CASE;
    END CASE;    


    --Cod de caja
    CASE WHEN NEW."thCara" IN (0,1) then
        aux_CodCaja:='601';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodCaja:='602';
    END CASE;

    --Definimos final de la cadena
    CASE WHEN NEW."thCara" IN (0,1) then
        CASE WHEN NEW."thManguera"=0 then
            aux_FinProducto:='90';
        WHEN NEW."thManguera"=1 then
            aux_FinProducto:='B5';
        WHEN NEW."thManguera"=2 then
            aux_FinProducto:='84';
        END CASE;
    WHEN NEW."thCara" IN (2,3) then
        CASE WHEN NEW."thManguera"=0 then
            aux_FinProducto:='90';
        WHEN NEW."thManguera"=1 then
            aux_FinProducto:='B5';
        WHEN NEW."thManguera"=2 then
            aux_FinProducto:='95';
        WHEN NEW."thManguera"=3 then
            aux_FinProducto:='84';
        END CASE;
    END CASE;    

    
    --Codigo manguera
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||aux_FinProducto;

    --Necesitamos recuperar el PU, cantidad, id venta
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();



-- 6 POROY
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
    aux_FechaHora timestamp;

BEGIN
    --Numeracion sucursal
    CASE 
    WHEN NEW."thCara" IN (0,1) then
        aux_CodSucursal:='12';
    WHEN NEW."thCara" IN (2,3) then
        aux_CodSucursal:='13';
    WHEN NEW."thCara" IN (4,5) then
        aux_CodSucursal:='14';
    WHEN NEW."thCara" IN (6,7) then
        aux_CodSucursal:='11';
    WHEN NEW."thCara" IN (8,9) then
        aux_CodSucursal:='15';
    WHEN NEW."thCara" IN (10,11) then
        aux_CodSucursal:='16';
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
        WHEN NEW."thCara" = 4 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
            END CASE; 
        WHEN NEW."thCara" = 5 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='D';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='F';
            END CASE;
        WHEN NEW."thCara" = 6 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='C';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='A';
            END CASE;
        WHEN NEW."thCara" = 7 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='F';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='D';
            END CASE; 
        WHEN NEW."thCara" = 8 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='B';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='C';
            END CASE;       
        WHEN NEW."thCara" = 9 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='D';
                WHEN NEW."thManguera" = 1 then
                    aux_CodAlfManguera:='E';
                WHEN NEW."thManguera" = 2 then
                    aux_CodAlfManguera:='F';
            END CASE; 
        WHEN NEW."thCara" = 10 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='A';
            END CASE; 
        WHEN NEW."thCara" = 11 then
            CASE 
                WHEN NEW."thManguera" = 0 then
                    aux_CodAlfManguera:='B';
            END CASE; 
    END CASE;

    --Cod producto
    CASE 
    WHEN NEW."thCara" IN (0,1,2,3,4,5) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_CodProducto:='B5';
            WHEN NEW."thManguera"=1 then
                aux_CodProducto:='G95';
            WHEN NEW."thManguera"=2 then
                aux_CodProducto:='G90';
        END CASE;

    WHEN NEW."thCara" IN (6,7,8,9) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_CodProducto:='B5';
            WHEN NEW."thManguera"=1 then
                aux_CodProducto:='G84';
            WHEN NEW."thManguera"=2 then
                aux_CodProducto:='G90';
        END CASE;  
    WHEN NEW."thCara" IN (10,11) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_CodProducto:='B5';
        END CASE;
    END CASE;


    --Cod de caja
    CASE 
    WHEN NEW."thCara" IN (0,1) then
        aux_CodCaja:='102';
    WHEN NEW."thCara" IN (2,3,4,5) then
        aux_CodCaja:='103';
    WHEN NEW."thCara" IN (6,7) then
        aux_CodCaja:='101';
    WHEN NEW."thCara" IN (8,9,10,11) then
        aux_CodCaja:='104';
    END CASE;

    --Definimos final de la cadena
    CASE 
    WHEN NEW."thCara" IN (0,1,2,3,4,5) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_FinProducto:='B5';
            WHEN NEW."thManguera"=1 then
                aux_FinProducto:='95';
            WHEN NEW."thManguera"=2 then
                aux_FinProducto:='90';
        END CASE;
    WHEN NEW."thCara" IN (6,7,8,9) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_FinProducto:='B5';
            WHEN NEW."thManguera"=1 then
                aux_FinProducto:='84';
            WHEN NEW."thManguera"=2 then
                aux_FinProducto:='90';
        END CASE;
    WHEN NEW."thCara" IN (10,11) then
        CASE 
            WHEN NEW."thManguera"=0 then
                aux_FinProducto:='B5';
        END CASE;
    END CASE;    

    
    --Codigo manguera
    aux_CodManguera:=aux_CodSucursal||aux_CodAlfManguera||aux_FinProducto;

    --Necesitamos recuperar el PU, cantidad, id venta
    SELECT "vePrecio","veVolumen", "veImporte","veID","veHoraPC" INTO aux_PrecioUnitario,aux_Cantidad,aux_Importe,aux_IdVenta,aux_FechaHora FROM "aVenta" as AV INNER JOIN "aTotalizadorH" as ATH
    ON AV."veManguera"=ATH."thManguera" AND AV."veCara"= ATH."thCara"
    AND ATH."thHora"=AV."veHoraPC"
    WHERE ATH."thID"=NEW."thID" order by ATH."thHora" desc limit 1;

    IF (aux_IdVenta IS NOT NULL AND aux_IdVenta>0) THEN
        --Insercion en la temporal
        INSERT INTO
            tempaventas(temp_codcaja,temp_codmanguera,temp_codproducto,temp_preciounitario,temp_cantidad,temp_importe,temp_contometro,temp_idventa,temp_fecha)
            VALUES(aux_CodCaja,aux_CodManguera,aux_CodProducto,aux_PrecioUnitario,aux_Cantidad,aux_Importe,NEW."thVolumen",aux_IdVenta,aux_FechaHora);
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;

--Trigrer
CREATE TRIGGER "trig_aVenta"
    AFTER INSERT
    ON public."aTotalizadorH"
    FOR EACH ROW
    EXECUTE PROCEDURE public.fn_InsertarDatosTempAVentas();




