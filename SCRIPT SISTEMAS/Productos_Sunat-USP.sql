--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- CREACION: 07/08/2019
-- OBJETIVOS: Verifica la cantidad de elementos de las tablas PRI_SUNAT_SEGMENTO,PRI_SUNAT_FAMILIA,PRI_SUNAT_CLASE,
-- PRI_SUNAT_PRODUCTOS, si la cantidad de elemntos de cualquiera de ellos no coincide, elimina todos los elementos 
-- de las tablas y los vuelve a insertar ejecutando el archivo especificado en la ruta(*)
-- (*)La ruta no debe contener espacios
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_VerificarTablasProductoSUNAT
--	@NroSegmentos = 1000,
--	@NroFamilias = 1000,
--	@NroClases = 1000,
--	@NroProductos = 1000,
--	@RutaArchivoScript = 'G:\Productos_Sunat-Productos.sql'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VerificarTablasProductoSUNAT'
          AND type = 'P'
)
    DROP PROCEDURE USP_VerificarTablasProductoSUNAT;
GO
CREATE PROCEDURE USP_VerificarTablasProductoSUNAT @NroSegmentos INT, 
                                                  @NroFamilias  INT, 
                                                  @NroClases    INT, 
                                                  @NroProductos INT, 
                                                  @RutaArchivoScript   VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        --Ejecutamos los scripts previamente
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_SEGMENTO''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_SEGMENTO
        (Cod_Segmento   VARCHAR(5)
         PRIMARY KEY, 
         Des_Segmento   VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_FAMILIA''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_FAMILIA
        (Cod_Familia    VARCHAR(10)
         PRIMARY KEY, 
         Cod_Segmento   VARCHAR(5) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_SEGMENTO(Cod_Segmento) NOT NULL, 
         Des_Familia    VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_CLASE''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_CLASE
        (Cod_Clase      VARCHAR(20)
         PRIMARY KEY, 
         Cod_Familia    VARCHAR(10) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_FAMILIA(Cod_Familia) NOT NULL, 
         Des_Clase      VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_PRODUCTOS''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_PRODUCTOS
        (Cod_Producto   VARCHAR(32)
         PRIMARY KEY, 
         Cod_Segmento   VARCHAR(5) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_SEGMENTO(Cod_Segmento) NOT NULL, 
         Cod_Familia    VARCHAR(10) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_FAMILIA(Cod_Familia) NOT NULL, 
         Cod_Clase      VARCHAR(20) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_CLASE(Cod_Clase) NOT NULL, 
         Des_Producto   VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_G @Cod_Segmento VARCHAR(5), 
                                          @Des_Segmento VARCHAR(MAX), 
                                          @Estado       BIT, 
                                          @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT pss.*
            FROM dbo.PRI_SUNAT_SEGMENTO pss
            WHERE pss.Cod_Segmento = @Cod_Segmento
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_SEGMENTO
                VALUES
                (@Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Des_Segmento, -- Des_Segmento - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_SEGMENTO
                  SET 
                      dbo.PRI_SUNAT_SEGMENTO.Des_Segmento = @Des_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_SEGMENTO.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_SEGMENTO.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_SEGMENTO.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_SEGMENTO.Cod_Segmento = @Cod_Segmento;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_E @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_SEGMENTO
        WHERE dbo.PRI_SUNAT_SEGMENTO.Cod_Segmento = @Cod_Segmento;
	END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.*
        FROM dbo.PRI_SUNAT_SEGMENTO pss;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TXPK @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.*
        FROM dbo.PRI_SUNAT_SEGMENTO pss
        WHERE pss.Cod_Segmento = @Cod_Segmento;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.Cod_UsuarioReg, 
               pss.Fecha_Reg, 
               pss.Cod_UsuarioAct, 
               pss.Fecha_Act
        FROM dbo.PRI_SUNAT_SEGMENTO pss
        WHERE pss.Cod_Segmento = @Cod_Segmento;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_SEGMENTO ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TP @TamañoPagina VARCHAR(16), 
                                           @NumeroPagina VARCHAR(16), 
                                           @ScripOrden   VARCHAR(MAX) = NULL, 
                                           @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Segmento,Des_Segmento,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act 
			FROM (SELECT TOP 100 PERCENT Cod_Segmento,Des_Segmento,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_SEGMENTO '' + @ScripWhere + '') aPRI_SUNAT_SEGMENTO
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_G @Cod_Familia  VARCHAR(10), 
                                         @Cod_Segmento VARCHAR(5), 
                                         @Des_Familia  VARCHAR(MAX), 
                                         @Estado       BIT, 
                                         @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psf.*
            FROM dbo.PRI_SUNAT_FAMILIA psf
            WHERE  psf.Cod_Familia = @Cod_Familia
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_FAMILIA
                VALUES
                (@Cod_Familia, -- Cod_Familia - VARCHAR
                 @Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Des_Familia, -- Des_Familia - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_FAMILIA
                  SET 
                      dbo.PRI_SUNAT_FAMILIA.Cod_Segmento = @Cod_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Des_Familia = @Des_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_FAMILIA.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_FAMILIA.Cod_Familia = @Cod_Familia;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_E @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_FAMILIA
        WHERE dbo.PRI_SUNAT_FAMILIA.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.*
        FROM dbo.PRI_SUNAT_FAMILIA psf;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TXPK @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.*
        FROM dbo.PRI_SUNAT_FAMILIA psf
        WHERE psf.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.Cod_UsuarioReg, 
               psf.Fecha_Reg, 
               psf.Cod_UsuarioAct, 
               psf.Fecha_Act
        FROM dbo.PRI_SUNAT_FAMILIA psf
        WHERE psf.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_FAMILIA ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TP @TamañoPagina VARCHAR(16), 
                                          @NumeroPagina VARCHAR(16), 
                                          @ScripOrden   VARCHAR(MAX) = NULL, 
                                          @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Familia,Cod_Segmento,Des_Familia,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Familia,Cod_Segmento,Des_Familia,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_FAMILIA '' + @ScripWhere + '') aPRI_SUNAT_FAMILIA
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_G @Cod_Clase   VARCHAR(20), 
                                           @Cod_Familia VARCHAR(10), 
                                           @Des_Clase   VARCHAR(MAX), 
                                           @Estado      BIT, 
                                           @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psc.*
            FROM dbo.PRI_SUNAT_CLASE psc
            WHERE psc.Cod_Clase = @Cod_Clase
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_CLASE
                VALUES
                (@Cod_Clase, -- Cod_Clase - VARCHAR
                 @Cod_Familia, -- Cod_Familia - VARCHAR
                 @Des_Clase, -- Des_Clase - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_CLASE
                  SET 
                      dbo.PRI_SUNAT_CLASE.Cod_Familia = @Cod_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Des_Clase = @Des_Clase, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_CLASE.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_CLASE.Cod_Clase = @Cod_Clase;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_E @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_CLASE
        WHERE dbo.PRI_SUNAT_CLASE.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.*
        FROM dbo.PRI_SUNAT_CLASE psc;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TXPK @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.*
        FROM dbo.PRI_SUNAT_CLASE psc
        WHERE psc.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_Auditoria @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.Cod_UsuarioReg, 
               psc.Fecha_Reg, 
               psc.Cod_UsuarioAct, 
               psc.Fecha_Act
        FROM dbo.PRI_SUNAT_CLASE psc
        WHERE psc.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_CLASE ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TP @TamañoPagina VARCHAR(16), 
                                        @NumeroPagina VARCHAR(16), 
                                        @ScripOrden   VARCHAR(MAX) = NULL, 
                                        @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Clase,Cod_Familia,Des_Clase,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Clase,Cod_Familia,Des_Clase,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_CLASE '' + @ScripWhere + '') aPRI_SUNAT_CLASE
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_G @Cod_Producto VARCHAR(32), 
                                               @Cod_Segmento VARCHAR(5), 
                                               @Cod_Familia  VARCHAR(10), 
                                               @Cod_Clase    VARCHAR(20), 
                                               @Des_Producto VARCHAR(MAX), 
                                               @Estado       BIT, 
                                               @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psp.*
            FROM dbo.PRI_SUNAT_PRODUCTOS psp
            WHERE psp.Cod_Producto = @Cod_Producto
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_PRODUCTOS
                VALUES
                (@Cod_Producto, -- Cod_Producto - VARCHAR
                 @Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Cod_Familia, -- Cod_Familia - VARCHAR
                 @Cod_Clase, -- Cod_Clase - VARCHAR
                 @Des_Producto, -- Des_Producto - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_PRODUCTOS
                  SET 
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Segmento = @Cod_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Familia = @Cod_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Clase = @Cod_Clase, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Des_Producto = @Des_Producto, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_PRODUCTOS.Cod_Producto = @Cod_Producto;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_E @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_PRODUCTOS
        WHERE dbo.PRI_SUNAT_PRODUCTOS.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.*
        FROM dbo.PRI_SUNAT_PRODUCTOS psp;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TXPK @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.*
        FROM dbo.PRI_SUNAT_PRODUCTOS psp
        WHERE psp.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_Auditoria @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.Cod_UsuarioReg, 
               psp.Fecha_Reg, 
               psp.Cod_UsuarioAct, 
               psp.Fecha_Act
        FROM dbo.PRI_SUNAT_PRODUCTOS psp
        WHERE psp.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_PRODUCTOS ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TP @TamañoPagina VARCHAR(16), 
                                            @NumeroPagina VARCHAR(16), 
                                            @ScripOrden   VARCHAR(MAX) = NULL, 
                                            @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Producto,Cod_Segmento,Cod_Familia,Cod_Clase,Des_Producto,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Producto,Cod_Segmento,Cod_Familia,Cod_Clase,Des_Producto,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_PRODUCTOS '' + @ScripWhere + '') aPRI_SUNAT_PRODUCTOS
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        IF @NroSegmentos <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_SEGMENTO pss
        )
           OR @NroFamilias <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_FAMILIA psf
        )
           OR @NroClases <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_CLASE psc
        )
           OR @NroProductos <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_PRODUCTOS psp
        )
            BEGIN
                --Borramos el contenido previamente almacenado
                DELETE dbo.PRI_SUNAT_PRODUCTOS;
                DELETE dbo.PRI_SUNAT_CLASE;
                DELETE dbo.PRI_SUNAT_FAMILIA;
                DELETE dbo.PRI_SUNAT_SEGMENTO;
                --Ejecutamos el script de productos de acuerdo a la ruta 
                DECLARE @NombreBD VARCHAR(MAX)=
                (
                    SELECT DB_NAME()
                );
                EXEC ('master..xp_cmdshell  ''Sqlcmd -S .\PALEHOST -d '+@NombreBD+' -i  '+@RutaArchivoScript+'''');
        END;
    END;
GO