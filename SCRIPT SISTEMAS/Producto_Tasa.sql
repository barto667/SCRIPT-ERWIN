
IF OBJECT_ID('PRI_PRODUCTO_TASA', 'U') IS NOT NULL
    BEGIN
        --Si no hay datos creamos la tabla nuevamnete
        IF NOT EXISTS
        (
            SELECT ppt.*
            FROM dbo.PRI_PRODUCTO_TASA ppt
        )
            BEGIN
                DROP TABLE dbo.PRI_PRODUCTO_TASA;
                --Creamos la tabla
                CREATE TABLE PRI_PRODUCTO_TASA
                (Id_Producto    INT NOT NULL, 
                 Cod_Tasa       VARCHAR(32) NOT NULL, 
                 Cod_Libro      VARCHAR(2), 
                 Des_Tasa       VARCHAR(512), 
                 Por_Tasa       NUMERIC(10, 4), 
                 Cod_TipoTasa   VARCHAR(64), 
                 Cod_Aplicacion VARCHAR(64), 
                 Flag_Activo    BIT, 
                 Obs_Tasa       VARCHAR(1024), 
                 Cod_UsuarioReg VARCHAR(32) NOT NULL, 
                 Fecha_Reg      DATETIME NOT NULL, 
                 Cod_UsuarioAct VARCHAR(32), 
                 Fecha_Act      DATETIME, 
                 PRIMARY KEY(Id_Producto, Cod_Tasa), 
                 FOREIGN KEY(Id_Producto) REFERENCES PRI_PRODUCTOS(Id_Producto)
                );
        END;
END;
    ELSE
    BEGIN
        --Creamos la tabla
        CREATE TABLE PRI_PRODUCTO_TASA
        (Id_Producto    INT NOT NULL, 
         Cod_Tasa       VARCHAR(32) NOT NULL, 
         Cod_Libro      VARCHAR(2), 
         Des_Tasa       VARCHAR(512), 
         Por_Tasa       NUMERIC(10, 4), 
         Cod_TipoTasa   VARCHAR(8), 
         Cod_Aplicacion VARCHAR(8), 
         Flag_Activo    BIT, 
         Obs_Tasa       VARCHAR(1024), 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME, 
         PRIMARY KEY(Id_Producto, Cod_Tasa), 
         FOREIGN KEY(Id_Producto) REFERENCES PRI_PRODUCTOS(Id_Producto)
        );
END;
--	 Archivo: USP_PRI_PRODUCTO_TASA.sql
--
--	 Versión: v2.1.10
--
--	 Autor(es): Reyber Yuri Palma Quispe  y Laura Yanina Alegria Amudio
--
--	 Fecha de Creación:  Thu Aug 08 18:47:23 2019
--
--	 Copyright  Pale Consultores EIRL Peru	2013
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_G;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_G @Id_Producto    INT, 
                                         @Cod_Tasa       VARCHAR(32), 
                                         @Cod_Libro      VARCHAR(2), 
                                         @Des_Tasa       VARCHAR(512), 
                                         @Por_Tasa       NUMERIC(10, 4), 
                                         @Cod_TipoTasa   VARCHAR(64), 
                                         @Cod_Aplicacion VARCHAR(64), 
                                         @Flag_Activo    BIT, 
                                         @Obs_Tasa       VARCHAR(1024), 
                                         @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Producto, 
                   @Cod_Tasa
            FROM PRI_PRODUCTO_TASA
            WHERE(Id_Producto = @Id_Producto)
                 AND (Cod_Tasa = @Cod_Tasa)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_TASA
                VALUES
                (@Id_Producto, 
                 @Cod_Tasa, 
                 @Cod_Libro, 
                 @Des_Tasa, 
                 @Por_Tasa, 
                 @Cod_TipoTasa, 
                 @Cod_Aplicacion, 
                 @Flag_Activo, 
                 @Obs_Tasa, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTO_TASA
                  SET 
                      Cod_Libro = @Cod_Libro, 
                      Des_Tasa = @Des_Tasa, 
                      Por_Tasa = @Por_Tasa, 
                      Cod_TipoTasa = @Cod_TipoTasa, 
                      Cod_Aplicacion = @Cod_Aplicacion, 
                      Flag_Activo = @Flag_Activo, 
                      Obs_Tasa = @Obs_Tasa, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_Tasa = @Cod_Tasa);
        END;
    END;
GO

-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_E;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_E @Id_Producto INT, 
                                         @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TT;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Producto, 
               Cod_Tasa, 
               Cod_Libro, 
               Des_Tasa, 
               Por_Tasa, 
               Cod_TipoTasa, 
               Cod_Aplicacion, 
               Flag_Activo, 
               Obs_Tasa, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TP;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TP @TamañoPagina VARCHAR(16), 
                                          @NumeroPagina VARCHAR(16), 
                                          @ScripOrden   VARCHAR(MAX) = NULL, 
                                          @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Producto , Cod_Tasa , Cod_Libro , Des_Tasa , Por_Tasa , Cod_TipoTasa , Cod_Aplicacion , Flag_Activo , Obs_Tasa , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Producto , Cod_Tasa , Cod_Libro , Des_Tasa , Por_Tasa , Cod_TipoTasa , Cod_Aplicacion , Flag_Activo , Obs_Tasa , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
		  FROM PRI_PRODUCTO_TASA ' + @ScripWhere + ') aPRI_PRODUCTO_TASA
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TXPK;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TXPK @Id_Producto INT, 
                                            @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Producto, 
               Cod_Tasa, 
               Cod_Libro, 
               Des_Tasa, 
               Por_Tasa, 
               Cod_TipoTasa, 
               Cod_Aplicacion, 
               Flag_Activo, 
               Obs_Tasa, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_Auditoria;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_Auditoria @Id_Producto INT, 
                                                 @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TNF;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM PRI_PRODUCTO_TASA '+@ScripWhere);
    END;
GO

--------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYEM CHAMBI
-- CREACION: 13/08/2019
-- OBJETIVO : Trae las tasas en base a un id de producto
-- EXEC USP_PRI_PRODUCTO_TASA_TraerXIdProducto 1000
--------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_TASA_TraerXIdProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TraerXIdProducto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TraerXIdProducto @Id_Producto INT
AS
    BEGIN
        SELECT DISTINCT ppt.Cod_Tasa,
               CASE
                   WHEN ppt.Cod_Libro = '14'
                   THEN 'VENTA'
                   ELSE 'COMPRA'
               END Libro, 
               ppt.Des_Tasa, 
               ppt.Cod_Aplicacion, 
               ppt.Por_Tasa, 
               ppt.Flag_Activo
        FROM dbo.PRI_PRODUCTO_TASA ppt
        WHERE ppt.Id_Producto = @Id_Producto;
    END;
GO

--Agregamos el nuevo impeusto de bolsas de plastico
IF NOT EXISTS
(
    SELECT vt.*
    FROM dbo.VIS_TASAS vt
    WHERE vt.Cod_Tasa = 'ICBPER'
)
    BEGIN
        DECLARE @Fila INT= (ISNULL(
        (
            SELECT MAX(vt.Nro)
            FROM dbo.VIS_TASAS vt
        ), 0) + 1);
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='001',@Cod_Fila=@Fila,@Cadena=N'ICBPER',@Numero=NULL,@Entero=NULL,@FechaHora=NULL,@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='002',@Cod_Fila=@Fila,@Cadena=N'IMPUESTO AL CONSUMO DE BOLSAS DE PLASTICO',@Numero=NULL,@Entero=NULL,@FechaHora=NULL,@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='003',@Cod_Fila=@Fila,@Cadena=N'OTROS IMPUESTOS',@Numero=NULL,@Entero=NULL,@FechaHora=NULL,@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='004',@Cod_Fila=@Fila,@Cadena=NULL,@Numero=0.1,@Entero=NULL,@FechaHora=NULL,@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='005',@Cod_Fila=@Fila,@Cadena=NULL,@Numero=NULL,@Entero=NULL,@FechaHora='2019-01-08',@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='006',@Cod_Fila=@Fila,@Cadena=NULL,@Numero=NULL,@Entero=NULL,@FechaHora='2050-01-01',@Boleano=NULL,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla='013',@Cod_Columna='007',@Cod_Fila=@Fila,@Cadena=NULL,@Numero=NULL,@Entero=NULL,@FechaHora=NULL,@Boleano=1,@Flag_Creacion=1,@Cod_Usuario='MIGRACION'
END;

-----------------------------------------------------------------------------------------------
-- CREACION : 16/08/2019
-- AUTOR: ERWIN M. RAYME CHAMBI
-- OBJETIVO : Obtener las tasa especificada de un detalle de comprobante por id_comprobantepago, id_detalle, Cod_tasa y Cod_libro
-- SELECT dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(8477,1,'ICBPER','14')
------------------------------------------------------------------------------------------------ 
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro'
)
    BEGIN
        DROP FUNCTION UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro;
END;
GO
CREATE FUNCTION UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro
(@Id_ComprobantePago INT, 
 @Id_Detalle         INT, 
 @Cod_Tasa           VARCHAR(32), 
 @Cod_Libro          VARCHAR(2)
)
RETURNS NUMERIC(38, 6)
AS
     BEGIN
         RETURN
         ISNULL((
             SELECT CASE
                        WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                        THEN ccd.Cantidad * (CAST(ppt.Por_Tasa AS NUMERIC(38, 6)) / 100) * (100 - CASE
                                                                                                      WHEN ccd.Cod_TipoIGV = 10
                                                                                                      THEN CAST(ccd.Porcentaje_IGV AS NUMERIC(38, 6))
                                                                                                      ELSE 0
                                                                                                  END - CASE
                                                                                                            WHEN ccd.Cod_TipoIGV != NULL
                                                                                                            THEN CAST(ccd.Porcentaje_ISC AS NUMERIC(38, 6))
                                                                                                            ELSE 0
                                                                                                        END) * ((ccd.PrecioUnitario - (CAST(ccd.Descuento AS NUMERIC(38, 6)) / ccd.Cantidad)) / 100)
                        WHEN ppt.Cod_Aplicacion = 'MONTO'
                        THEN ccd.Cantidad * CAST(ppt.Por_Tasa AS NUMERIC(38, 6))
                        ELSE 0
                    END
             FROM dbo.PRI_PRODUCTO_TASA ppt
                  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.id_ComprobantePago = @Id_ComprobantePago
                                                          AND ccd.id_Detalle = @Id_Detalle
                                                          AND ppt.Id_Producto = ccd.Id_Producto
                                                          AND ppt.Cod_Tasa = @Cod_Tasa
                                                          AND ppt.Cod_Libro = @Cod_Libro
         ),0);
     END;
GO

------------------------------------------------------------------------------------------------------------
-- FECHA: 19/08/2019
-- AUTOR: ERWIN M. RAYME CHAMBI
-- OBJECTIVO: Obtiene la tasa de un producto en base al id_comprobante, id_detalle y cod_tasa
-- EXEC USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle 1900,0,'ICBPER'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle @Id_ComprobantePago INT, 
                                                                        @Id_Detalle         INT, 
                                                                        @Cod_Tasa           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT ppt.*
        FROM dbo.CAJ_COMPROBANTE_D ccd
             INNER JOIN dbo.PRI_PRODUCTO_TASA ppt ON ccd.id_ComprobantePago = @Id_ComprobantePago
                                                     AND ccd.id_Detalle = @Id_Detalle
                                                     AND ppt.Cod_Tasa = @Cod_Tasa
                                                     AND ppt.Flag_Activo = 1
                                                     AND ccd.Id_Producto = ppt.Id_Producto;
    END;
GO