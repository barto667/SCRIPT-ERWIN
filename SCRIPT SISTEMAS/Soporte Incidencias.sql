--Creacion de tablas SQL para soporte
--23/04/2019
IF NOT EXISTS
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SOP_SERVICIOS'
)
    BEGIN
        CREATE TABLE SOP_SERVICIOS
        (Id_Servicio         INT IDENTITY(1, 1), 
         Id_ClienteProveedor INT NOT NULL, 
         Id_Producto         INT NOT NULL, 
         Id_ComprobantePago  INT NULL, 
         Fecha_Inicio        DATETIME NOT NULL, 
         Fecha_Fin           DATETIME NOT NULL, 
         Monto               DECIMAL(38, 6) NULL, 
         Cod_EstadoServicio  VARCHAR(32) NOT NULL, 
         Cod_Usuario         VARCHAR(32) NOT NULL, 
         Cod_Servicio        VARCHAR(64) NOT NULL, 
         Password            VARCHAR(128) NULL, 
         Obs_Servicio        VARCHAR(1024) NULL, 
         Cod_UsuarioReg      VARCHAR(32) NOT NULL, 
         Fecha_Reg           DATETIME NOT NULL, 
         Cod_UsuarioAct      VARCHAR(32) NULL, 
         Fecha_Act           DATETIME NULL, 
         PRIMARY KEY NONCLUSTERED(Id_Servicio), 
         FOREIGN KEY(Id_Producto) REFERENCES PRI_PRODUCTOS, 
         FOREIGN KEY(Id_ClienteProveedor) REFERENCES PRI_CLIENTE_PROVEEDOR
        );
END;
GO
IF NOT EXISTS
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SOP_TERMINALES'
)
    BEGIN
        CREATE TABLE SOP_TERMINALES
        (Id_Terminal         INT IDENTITY(1, 1), 
         Id_ClienteProveedor INT NULL, 
         Des_Terminal        VARCHAR(1024) NOT NULL, 
         MAC_Terminal        VARCHAR(16) NULL, 
         Id_Sistema          VARCHAR(8) NULL, 
         Serie_Sistema       VARCHAR(32) NULL, 
         Fecha_Creacion      DATETIME NULL, 
         Id_TeamViewer       VARCHAR(16) NULL, 
         Pass_Teamviewer     VARCHAR(128) NULL, 
         Id_AnyDesk          VARCHAR(512) NULL, 
         Pass_AnyDesk        VARCHAR(128) NULL, 
         Id_Otros            VARCHAR(512) NULL, 
         Pass_Otros          VARCHAR(128) NULL, 
         Flag_Estado         BIT NOT NULL, 
         Cod_Estado          VARCHAR(8) NOT NULL, 
         Obs_Terminal        VARCHAR(1024) NULL, 
         Cod_UsuarioReg      VARCHAR(32) NOT NULL, 
         Fecha_Reg           DATETIME NOT NULL, 
         Cod_UsuarioAct      VARCHAR(32) NULL, 
         Fecha_Act           DATETIME NULL, 
         PRIMARY KEY NONCLUSTERED(Id_Terminal), 
         FOREIGN KEY(Id_ClienteProveedor) REFERENCES PRI_CLIENTE_PROVEEDOR
        );
END;
GO
IF NOT EXISTS
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SOP_INCIDENCIAS'
)
    BEGIN
        CREATE TABLE SOP_INCIDENCIAS
        (Id_Incidencia         INT, 
         Id_Terminal           INT NULL, 
         Cod_TipoIncidencia    VARCHAR(32) NOT NULL, 
         Cod_Prioridad         VARCHAR(8) NULL, 
         Detalle               VARCHAR(1024) NOT NULL, 
         Respuesta             VARCHAR(1024) NULL, 
         Cod_MedioOrigen       VARCHAR(8) NOT NULL, 
         Obs_Incidencia        VARCHAR(1024) NULL, 
         Cod_Estado            VARCHAR(32) NOT NULL, 
         Cod_UsuarioIncidencia VARCHAR(32) NULL, 
         Pregunta1             INT NULL, 
         Pregunta2             INT NULL, 
         Pregunta3             VARCHAR(128) NULL, 
         Cod_UsuarioReg        VARCHAR(32) NOT NULL, 
         Fecha_Reg             DATETIME NOT NULL, 
         Cod_UsuarioAct        VARCHAR(32) NULL, 
         Fecha_Act             DATETIME NULL, 
         PRIMARY KEY NONCLUSTERED(Id_Incidencia), 
         FOREIGN KEY(Id_Terminal) REFERENCES SOP_TERMINALES
        );
END;
GO
IF NOT EXISTS
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SOP_ASISTENCIAS'
)
    BEGIN
        CREATE TABLE SOP_ASISTENCIAS
        (Id_Incidencia         INT NOT NULL, 
         Item                  INT NOT NULL, 
         Fecha_Inicio          DATETIME NOT NULL, 
         Fecha_Fin             DATETIME NOT NULL, 
         Tiempo                BIGINT NOT NULL, 
         Cod_UsuarioAsistencia VARCHAR(32) NOT NULL, 
         Obs_Asistencia        VARCHAR(1024) NULL, 
         Cod_UsuarioReg        VARCHAR(32) NOT NULL, 
         Fecha_Reg             DATETIME NOT NULL, 
         Cod_UsuarioAct        VARCHAR(32) NULL, 
         Fecha_Act             DATETIME NULL, 
         PRIMARY KEY NONCLUSTERED(Id_Incidencia, Item), 
         FOREIGN KEY(Id_Incidencia) REFERENCES SOP_INCIDENCIAS
        );
END;
GO

--Archivo: USP_SOP_ASISTENCIAS.sql
-- Guardar

IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_G;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_G @Id_Incidencia         INT, 
                                       @Item                  INT OUTPUT, 
                                       @Fecha_Inicio          DATETIME, 
                                       @Fecha_Fin             DATETIME, 
                                       @Tiempo                BIGINT, 
                                       @Cod_UsuarioAsistencia VARCHAR(32), 
                                       @Obs_Asistencia        VARCHAR(1024), 
                                       @Cod_Usuario           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Item = 0
            BEGIN
                SET @Item = ISNULL(
                (
                    SELECT MAX(sa.Item)
                    FROM dbo.SOP_ASISTENCIAS sa
                    WHERE sa.Id_Incidencia = @Id_Incidencia
                ), 0) + 1;
                INSERT INTO SOP_ASISTENCIAS
                VALUES
                (@Id_Incidencia, 
                 @Item, 
                 @Fecha_Inicio, 
                 @Fecha_Fin, 
                 @Tiempo, 
                 @Cod_UsuarioAsistencia, 
                 @Obs_Asistencia, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                IF NOT EXISTS
                (
                    SELECT @Id_Incidencia, 
                           @Item
                    FROM SOP_ASISTENCIAS
                    WHERE(Id_Incidencia = @Id_Incidencia)
                         AND (Item = @Item)
                )
                    BEGIN
                        INSERT INTO SOP_ASISTENCIAS
                        VALUES
                        (@Id_Incidencia, 
                         @Item, 
                         @Fecha_Inicio, 
                         @Fecha_Fin, 
                         @Tiempo, 
                         @Cod_UsuarioAsistencia, 
                         @Obs_Asistencia, 
                         @Cod_Usuario, 
                         GETDATE(), 
                         NULL, 
                         NULL
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE SOP_ASISTENCIAS
                          SET 
                              Fecha_Inicio = @Fecha_Inicio, 
                              Fecha_Fin = @Fecha_Fin, 
                              Tiempo = @Tiempo, 
                              Cod_UsuarioAsistencia = @Cod_UsuarioAsistencia, 
                              Obs_Asistencia = @Obs_Asistencia, 
                              Cod_UsuarioAct = @Cod_Usuario, 
                              Fecha_Act = GETDATE()
                        WHERE(Id_Incidencia = @Id_Incidencia)
                             AND (Item = @Item);
                END;
        END;
    END;
GO
-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_E;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_E @Id_Incidencia INT, 
                                       @Item          INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM SOP_ASISTENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia)
             AND (Item = @Item);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_TT;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Incidencia, 
               Item, 
               Fecha_Inicio, 
               Fecha_Fin, 
               Cod_UsuarioAsistencia, 
               Obs_Asistencia, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_ASISTENCIAS;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_TP;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_TP @TamañoPagina VARCHAR(16), 
                                        @NumeroPagina VARCHAR(16), 
                                        @ScripOrden   VARCHAR(MAX) = NULL, 
                                        @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Incidencia , Item , Fecha_Inicio , Fecha_Fin, Tiempo , Cod_UsuarioAsistencia , Obs_Asistencia , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Incidencia , Item , Fecha_Inicio , Fecha_Fin, Tiempo, Cod_UsuarioAsistencia , Obs_Asistencia , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
		  FROM SOP_ASISTENCIAS ' + @ScripWhere + ') aSOP_ASISTENCIAS
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_TXPK;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_TXPK @Id_Incidencia INT, 
                                          @Item          INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Incidencia, 
               Item, 
               Fecha_Inicio, 
               Fecha_Fin, 
               Tiempo, 
               Cod_UsuarioAsistencia, 
               Obs_Asistencia, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_ASISTENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia)
             AND (Item = @Item);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_Auditoria;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_Auditoria @Id_Incidencia INT, 
                                               @Item          INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_ASISTENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia)
             AND (Item = @Item);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_ASISTENCIAS_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_TNF;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM SOP_ASISTENCIAS '+@ScripWhere);
    END;
GO

--Archiv : USP_SOP_INCIDENCIAS.sql
--Guardar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_G;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_G @Id_Incidencia         INT OUTPUT, 
                                       @Id_Terminal           INT, 
                                       @Cod_TipoIncidencia    VARCHAR(32), 
                                       @Cod_Prioridad         VARCHAR(8), 
                                       @Detalle               VARCHAR(1024), 
                                       @Respuesta             VARCHAR(1024), 
                                       @Cod_MedioOrigen       VARCHAR(32), 
                                       @Obs_Incidencia        VARCHAR(1024), 
                                       @Cod_Estado            VARCHAR(32), 
                                       @Cod_UsuarioIncidencia VARCHAR(32), 
                                       @Pregunta1             INT, 
                                       @Pregunta2             INT, 
                                       @Pregunta3             VARCHAR(128), 
                                       @Cod_Usuario           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Id_Incidencia = 0
            BEGIN
                --Insertamos la incidencia con un nuevo numero
                SET @Id_Incidencia = ISNULL(
                (
                    SELECT MAX(si.Id_Incidencia)
                    FROM dbo.SOP_INCIDENCIAS si
                ), 0) + 1;
                INSERT INTO SOP_INCIDENCIAS
                VALUES
                (@Id_Incidencia, 
                 @Id_Terminal, 
                 @Cod_TipoIncidencia, 
                 @Cod_Prioridad, 
                 @Detalle, 
                 @Respuesta, 
                 @Cod_MedioOrigen, 
                 @Obs_Incidencia, 
                 @Cod_Estado, 
                 @Cod_UsuarioIncidencia, 
                 @Pregunta1, 
                 @Pregunta2, 
                 @Pregunta3, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                IF NOT EXISTS
                (
                    SELECT @Id_Incidencia
                    FROM SOP_INCIDENCIAS
                    WHERE(Id_Incidencia = @Id_Incidencia)
                )
                    BEGIN
                        INSERT INTO SOP_INCIDENCIAS
                        VALUES
                        (@Id_Incidencia, 
                         @Id_Terminal, 
                         @Cod_TipoIncidencia, 
                         @Cod_Prioridad, 
                         @Detalle, 
                         @Respuesta, 
                         @Cod_MedioOrigen, 
                         @Obs_Incidencia, 
                         @Cod_Estado, 
                         @Cod_UsuarioIncidencia, 
                         @Pregunta1, 
                         @Pregunta2, 
                         @Pregunta3, 
                         @Cod_Usuario, 
                         GETDATE(), 
                         NULL, 
                         NULL
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE SOP_INCIDENCIAS
                          SET 
                              Id_Terminal = @Id_Terminal, 
                              Cod_TipoIncidencia = @Cod_TipoIncidencia, 
                              Cod_Prioridad = @Cod_Prioridad, 
                              Detalle = @Detalle, 
                              Respuesta = @Respuesta, 
                              Cod_MedioOrigen = @Cod_MedioOrigen, 
                              Obs_Incidencia = @Obs_Incidencia, 
                              Cod_Estado = @Cod_Estado, 
                              Cod_UsuarioIncidencia = @Cod_UsuarioIncidencia, 
                              Pregunta1 = @Pregunta1, 
                              Pregunta2 = @Pregunta2, 
                              Pregunta3 = @Pregunta3, 
                              Cod_UsuarioAct = @Cod_Usuario, 
                              Fecha_Act = GETDATE()
                        WHERE(Id_Incidencia = @Id_Incidencia);
                END;
        END;
    END;
GO

-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_E;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_E @Id_Incidencia INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM SOP_INCIDENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TT;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Incidencia, 
               Id_Terminal, 
               Cod_TipoIncidencia, 
               Cod_Prioridad, 
               Detalle, 
               Respuesta, 
               Cod_MedioOrigen, 
               Obs_Incidencia, 
               Cod_Estado, 
               Cod_UsuarioIncidencia, 
               Pregunta1, 
               Pregunta2, 
               Pregunta3, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_INCIDENCIAS;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TP;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TP @TamañoPagina VARCHAR(16), 
                                        @NumeroPagina VARCHAR(16), 
                                        @ScripOrden   VARCHAR(MAX) = NULL, 
                                        @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Incidencia , Id_Terminal , Cod_TipoIncidencia,Cod_Prioridad , Detalle , Respuesta , Cod_MedioOrigen , Obs_Incidencia , Cod_Estado , Cod_UsuarioIncidencia, Pregunta1,Pregunta2,Pregunta3 , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Incidencia , Id_Terminal , Cod_TipoIncidencia , Detalle , Respuesta , Cod_MedioAtencion , Obs_Incidencia , Cod_Estado , Cod_UsuarioIncidencia , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
		  FROM SOP_INCIDENCIAS ' + @ScripWhere + ') aSOP_INCIDENCIAS
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TXPK;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TXPK @Id_Incidencia INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Incidencia, 
               Id_Terminal, 
               Cod_TipoIncidencia, 
               Cod_Prioridad, 
               Detalle, 
               Respuesta, 
               Cod_MedioOrigen, 
               Obs_Incidencia, 
               Cod_Estado, 
               Cod_UsuarioIncidencia, 
               Pregunta1, 
               Pregunta2, 
               Pregunta3, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_INCIDENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_Auditoria;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_Auditoria @Id_Incidencia INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_INCIDENCIAS
        WHERE(Id_Incidencia = @Id_Incidencia);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_INCIDENCIAS_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TNF;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM SOP_INCIDENCIAS '+@ScripWhere);
    END;
GO

--Archivo: USP_SOP_SERVICIOS.sql
--Guardar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_G;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_G @Id_Servicio         INT OUTPUT, 
                                     @Id_ClienteProveedor INT, 
                                     @Id_Producto         INT, 
                                     @Id_ComprobantePago  INT, 
                                     @Fecha_Inicio        DATETIME, 
                                     @Fecha_Fin           DATETIME, 
                                     @Monto               DECIMAL(38, 6), 
                                     @Cod_EstadoServicio  VARCHAR(32), 
                                     @Cod_UsuarioServicio VARCHAR(32), 
                                     @Cod_Servicio        VARCHAR(64), 
                                     @Password            VARCHAR(128), 
                                     @Obs_Servicio        VARCHAR(1024), 
                                     @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Servicio
            FROM SOP_SERVICIOS
            WHERE(Id_Servicio = @Id_Servicio)
        )
            BEGIN
                INSERT INTO SOP_SERVICIOS
                VALUES
                (@Id_ClienteProveedor, 
                 @Id_Producto, 
                 @Id_ComprobantePago, 
                 @Fecha_Inicio, 
                 @Fecha_Fin, 
                 @Monto, 
                 @Cod_EstadoServicio, 
                 @Cod_UsuarioServicio, 
                 @Cod_Servicio, 
                 @Password, 
                 @Obs_Servicio, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_Servicio = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE SOP_SERVICIOS
                  SET 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Id_Producto = @Id_Producto, 
                      Id_ComprobantePago = @Id_ComprobantePago, 
                      Fecha_Inicio = @Fecha_Inicio, 
                      Fecha_Fin = @Fecha_Fin, 
                      Monto = @Monto, 
                      Cod_EstadoServicio = @Cod_EstadoServicio, 
                      Cod_Usuario = @Cod_UsuarioServicio, 
                      Cod_Servicio = @Cod_Servicio, 
                      Password = @Password, 
                      Obs_Servicio = @Obs_Servicio, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Servicio = @Id_Servicio);
        END;
    END;
GO

-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_E;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_E @Id_Servicio INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM SOP_SERVICIOS
        WHERE(Id_Servicio = @Id_Servicio);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_TT;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Servicio, 
               Id_ClienteProveedor, 
               Id_Producto, 
               Id_ComprobantePago, 
               Fecha_Inicio, 
               Fecha_Fin, 
               Monto, 
               Cod_EstadoServicio, 
               Cod_Usuario, 
               Cod_Servicio, 
               Password, 
               Obs_Servicio, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_SERVICIOS;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_TP;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_TP @TamañoPagina VARCHAR(16), 
                                      @NumeroPagina VARCHAR(16), 
                                      @ScripOrden   VARCHAR(MAX) = NULL, 
                                      @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Servicio , Id_ClienteProveedor , Id_Producto , Id_ComprobantePago , Fecha_Inicio , Fecha_Fin , Monto , Cod_EstadoServicio , Cod_Usuario , Cod_Servicio , Password , Obs_Servicio , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Servicio , Id_ClienteProveedor , Id_Producto , Id_ComprobantePago , Fecha_Inicio , Fecha_Fin , Monto , Cod_EstadoServicio , Cod_Usuario , Cod_Servicio , Password , Obs_Servicio , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
		  FROM SOP_SERVICIOS ' + @ScripWhere + ') aSOP_SERVICIOS
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_TXPK;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_TXPK @Id_Servicio INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Servicio, 
               Id_ClienteProveedor, 
               Id_Producto, 
               Id_ComprobantePago, 
               Fecha_Inicio, 
               Fecha_Fin, 
               Monto, 
               Cod_EstadoServicio, 
               Cod_Usuario, 
               Cod_Servicio, 
               Password, 
               Obs_Servicio, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_SERVICIOS
        WHERE(Id_Servicio = @Id_Servicio);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_Auditoria;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_Auditoria @Id_Servicio INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_SERVICIOS
        WHERE(Id_Servicio = @Id_Servicio);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_SERVICIOS_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_SERVICIOS_TNF;
GO
CREATE PROCEDURE USP_SOP_SERVICIOS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM SOP_SERVICIOS '+@ScripWhere);
    END;
GO

--Archivo: USP_SOP_TERMINALES.sql
--Guardar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_G;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_G @Id_Terminal         INT OUTPUT, 
                                      @Id_ClienteProveedor INT, 
                                      @Des_Terminal        VARCHAR(1024), 
                                      @MAC_Terminal        VARCHAR(16), 
                                      @Id_Sistema          VARCHAR(8), 
                                      @Serie_Sistema       VARCHAR(32), 
                                      @Fecha_Creacion      DATETIME, 
                                      @Id_TeamViewer       VARCHAR(16), 
                                      @Pass_Teamviewer     VARCHAR(128), 
                                      @Id_AnyDesk          VARCHAR(512), 
                                      @Pass_AnyDesk        VARCHAR(128), 
                                      @Id_Otros            VARCHAR(512), 
                                      @Pass_Otros          VARCHAR(128), 
                                      @Flag_Estado         BIT, 
                                      @Cod_Estado          VARCHAR(8), 
                                      @Obs_Terminal        VARCHAR(1024), 
                                      @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Terminal
            FROM SOP_TERMINALES
            WHERE(Id_Terminal = @Id_Terminal)
        )
            BEGIN
                INSERT INTO SOP_TERMINALES
                VALUES
                (@Id_ClienteProveedor, 
                 @Des_Terminal, 
                 @MAC_Terminal, 
                 @Id_Sistema, 
                 @Serie_Sistema, 
                 @Fecha_Creacion, 
                 @Id_TeamViewer, 
                 @Pass_Teamviewer, 
                 @Id_AnyDesk, 
                 @Pass_AnyDesk, 
                 @Id_Otros, 
                 @Pass_Otros, 
                 @Flag_Estado, 
                 @Cod_Estado, 
                 @Obs_Terminal, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_Terminal = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE SOP_TERMINALES
                  SET 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Des_Terminal = @Des_Terminal, 
                      MAC_Terminal = @MAC_Terminal, 
                      Id_Sistema = @Id_Sistema, 
                      Serie_Sistema = @Serie_Sistema, 
                      Fecha_Creacion = @Fecha_Creacion, 
                      Id_TeamViewer = @Id_TeamViewer, 
                      Pass_Teamviewer = @Pass_Teamviewer, 
                      Id_AnyDesk = @Id_AnyDesk, 
                      Pass_AnyDesk = @Pass_AnyDesk, 
                      Id_Otros = @Id_Otros, 
                      Pass_Otros = @Pass_Otros, 
                      Flag_Estado = @Flag_Estado, 
                      Cod_Estado = @Cod_Estado, 
                      Obs_Terminal = @Obs_Terminal, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Terminal = @Id_Terminal);
        END;
    END;
GO

-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_E;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_E @Id_Terminal INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM SOP_TERMINALES
        WHERE(Id_Terminal = @Id_Terminal);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Terminal, 
               Id_ClienteProveedor, 
               Des_Terminal, 
               MAC_Terminal, 
               Id_Sistema, 
               Serie_Sistema, 
               Fecha_Creacion, 
               Id_TeamViewer, 
               Pass_Teamviewer, 
               Id_AnyDesk, 
               Pass_AnyDesk, 
               Id_Otros, 
               Pass_Otros, 
               Flag_Estado, 
               Cod_Estado, 
               Obs_Terminal, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_TERMINALES;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TP;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TP @TamañoPagina VARCHAR(16), 
                                       @NumeroPagina VARCHAR(16), 
                                       @ScripOrden   VARCHAR(MAX) = NULL, 
                                       @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Terminal , Id_ClienteProveedor , Des_Terminal , MAC_Terminal , Id_Sistema , Serie_Sistema , Fecha_Creacion , Id_TeamViewer , Pass_Teamviewer , Id_AnyDesk , Pass_AnyDesk , Id_Otros , Pass_Otros , Flag_Estado , Cod_Estado , Obs_Terminal , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Terminal , Id_ClienteProveedor , Des_Terminal , MAC_Terminal , Id_Sistema , Serie_Sistema , Fecha_Creacion , Id_TeamViewer , Pass_Teamviewer , Id_AnyDesk , Pass_AnyDesk , Id_Otros , Pass_Otros , Flag_Estado , Cod_Estado , Obs_Terminal , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
		  FROM SOP_TERMINALES ' + @ScripWhere + ') aSOP_TERMINALES
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TXPK;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TXPK @Id_Terminal INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Terminal, 
               Id_ClienteProveedor, 
               Des_Terminal, 
               MAC_Terminal, 
               Id_Sistema, 
               Serie_Sistema, 
               Fecha_Creacion, 
               Id_TeamViewer, 
               Pass_Teamviewer, 
               Id_AnyDesk, 
               Pass_AnyDesk, 
               Id_Otros, 
               Pass_Otros, 
               Flag_Estado, 
               Cod_Estado, 
               Obs_Terminal, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_TERMINALES
        WHERE(Id_Terminal = @Id_Terminal);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_Auditoria;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_Auditoria @Id_Terminal INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM SOP_TERMINALES
        WHERE(Id_Terminal = @Id_Terminal);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SOP_TERMINALES_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TNF;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM SOP_TERMINALES '+@ScripWhere);
    END;
GO

--Estado terminal
EXEC dbo.USP_PAR_TABLA_G '130', 'ESTADOS_TERMINAL', 'Almacena los estados de una terminal', '001', 1, 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '130', '001', 'Cod_Estado', 'Almacena el codigo del estado', 'CADENA', 0, 32, '', 1, 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '130', '002', 'Des_Estado', 'Almacena la descripcion del estado', 'CADENA', 0, 1024, '', 0, 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '130', '003', 'Estado', 'Estado', 'BOLEANO', 0, 64, '', 0, 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '130';
GO
EXEC USP_PAR_FILA_G '130', '001', 1, '001', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '002', 1, 'ACTIVO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '003', 1, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '001', 2, '002', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '002', 2, 'INACTIVO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '003', 2, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '001', 3, '003', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '002', 3, 'BAJA', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '003', 3, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '001', 4, '004', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '002', 4, 'INOPERATIVO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '003', 4, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '001', 5, '005', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '002', 5, 'EN MANTENIMIENTO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
EXEC USP_PAR_FILA_G '130', '003', 5, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
GO

--Procedimientos adicionales
--Trae las terminales activas o desactivas por codigo de ubigeo
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TERMINALES_TraerXCodUbigeoFlagActivo'
          AND type = 'P'
)
    DROP PROCEDURE USP_TERMINALES_TraerXCodUbigeoFlagActivo;
GO
CREATE PROCEDURE USP_TERMINALES_TraerXCodUbigeoFlagActivo @CodUbigeo  VARCHAR(6) = NULL, 
                                                          @FlagActivo BIT        = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               st.Id_Terminal, 
               st.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               st.Des_Terminal, 
               st.MAC_Terminal, 
               st.Id_Sistema, 
               st.Serie_Sistema, 
               st.Fecha_Creacion, 
               st.Id_TeamViewer, 
               st.Pass_Teamviewer, 
               st.Id_AnyDesk, 
               st.Pass_AnyDesk, 
               st.Id_Otros, 
               st.Pass_Otros, 
               st.Flag_Estado, 
               st.Cod_Estado, 
               st.Obs_Terminal, 
               st.Cod_UsuarioReg, 
               st.Fecha_Reg, 
               st.Cod_UsuarioAct, 
               st.Fecha_Act
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
        WHERE(@FlagActivo IS NULL
              OR st.Flag_Estado = @FlagActivo)
             AND (@CodUbigeo IS NULL
                  OR pcp.Cod_Ubigeo = @CodUbigeo)
        ORDER BY st.Des_Terminal;
    END;
GO

--Trae las terminales activas o desactivas por codigo de ubigeo e id cliente
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TERMINALES_TraerXCodUbigeoIdClienteFlagActivo'
          AND type = 'P'
)
    DROP PROCEDURE USP_TERMINALES_TraerXCodUbigeoIdClienteFlagActivo;
GO
CREATE PROCEDURE USP_TERMINALES_TraerXCodUbigeoIdClienteFlagActivo @CodUbigeo  VARCHAR(6), 
                                                                   @IdCliente  INT, 
                                                                   @FlagActivo BIT        = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               st.Id_Terminal, 
               st.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               st.Des_Terminal, 
               st.MAC_Terminal, 
               st.Id_Sistema, 
               st.Serie_Sistema, 
               st.Fecha_Creacion, 
               st.Id_TeamViewer, 
               st.Pass_Teamviewer, 
               st.Id_AnyDesk, 
               st.Pass_AnyDesk, 
               st.Id_Otros, 
               st.Pass_Otros, 
               st.Flag_Estado, 
               st.Cod_Estado, 
               st.Obs_Terminal, 
               st.Cod_UsuarioReg, 
               st.Fecha_Reg, 
               st.Cod_UsuarioAct, 
               st.Fecha_Act
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
        WHERE(@FlagActivo IS NULL
              OR st.Flag_Estado = @FlagActivo)
             AND pcp.Cod_Ubigeo = @CodUbigeo
             AND st.Id_ClienteProveedor = @IdCliente
        ORDER BY st.Des_Terminal;
    END;
GO

--Metodo que trae  solo los departamento que tienen terminales
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_TraerDepartamentos'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TraerDepartamentos;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TraerDepartamentos @Flag_Activo BIT = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vd2.Cod_Departamento, 
               vd2.Nom_Departamento
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_DEPARTAMENTOS vd2 ON vd.Cod_Departamento = vd2.Cod_Departamento
        WHERE @Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo
        ORDER BY vd2.Nom_Departamento;
    END;
GO

--Metodo que trae  solo los provincias que tienen terminales x cod_departamento
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_TraerProvincias'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TraerProvincias;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TraerProvincias @Cod_Departamento VARCHAR(2), 
                                                    @Flag_Activo      BIT        = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vp.Cod_Departamento, 
               vp.Cod_Provincia, 
               vp.Nom_Provincia
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                 AND vd.Cod_Provincia = vp.Cod_Provincia
        WHERE(@Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo)
             AND (vp.Cod_Departamento = @Cod_Departamento)
        ORDER BY vp.Nom_Provincia;
    END;
GO

--Metodo que trae  solo los distritos que tienen terminales x cod_departamento y cod_provincia
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_TraerDistritos'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TraerDistritos;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TraerDistritos @Cod_Departamento VARCHAR(2), 
                                                   @Cod_Provincia    VARCHAR(2), 
                                                   @Flag_Activo      BIT        = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vd.Cod_Ubigeo, 
               vd.Cod_Departamento, 
               vd.Cod_Provincia, 
               vd.Cod_Distrito, 
               vd.Nom_Distrito
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                 AND vd.Cod_Provincia = vp.Cod_Provincia
        WHERE(@Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo)
             AND (vp.Cod_Departamento = @Cod_Departamento)
             AND (vp.Cod_Provincia = @Cod_Provincia)
        ORDER BY vd.Nom_Distrito;
    END;
GO

--Trae las empresas con terminales activas o desactivas por codigo de ubigeo
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TERMINALES_TraerEmpresas'
          AND type = 'P'
)
    DROP PROCEDURE USP_TERMINALES_TraerEmpresas;
GO
CREATE PROCEDURE USP_TERMINALES_TraerEmpresas @CodUbigeo  VARCHAR(6), 
                                              @FlagActivo BIT        = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               pcp.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               pcp.Ap_Paterno, 
               pcp.Ap_Materno, 
               pcp.Nombres, 
               pcp.Direccion, 
               pcp.Cod_EstadoCliente, 
               pcp.Cod_CondicionCliente, 
               pcp.Cod_TipoCliente, 
               pcp.RUC_Natural, 
               pcp.Cod_TipoComprobante, 
               pcp.Cod_Nacionalidad, 
               pcp.Fecha_Nacimiento, 
               pcp.Cod_Sexo, 
               pcp.Email1, 
               pcp.Email2, 
               pcp.Telefono1, 
               pcp.Telefono2, 
               pcp.Fax, 
               pcp.PaginaWeb, 
               pcp.Cod_Ubigeo, 
               pcp.Cod_FormaPago, 
               pcp.Limite_Credito, 
               pcp.Num_DiaCredito
        FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
             INNER JOIN dbo.SOP_TERMINALES st ON pcp.Id_ClienteProveedor = st.Id_ClienteProveedor
        WHERE pcp.Cod_Ubigeo = @CodUbigeo
              AND (@FlagActivo IS NULL
                   OR st.Flag_Estado = @FlagActivo)
        ORDER BY pcp.Cliente;
    END;
GO

--Categorias incidencias
EXEC dbo.USP_PAR_TABLA_G '131','CATEGORIAS_INCIDENCIAS','Almacena las distintas categorias de las incidencias','001',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '131','001','Cod_Categoria','Almacena el codigo de la categoria','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '131','002','Des_Categoria','Almacena la descripcion de la categoria','CADENA',0,1024,'',0,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '131','003','Estado','Estado','BOLEANO',0,64,'',0,'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '131';
GO
EXEC USP_PAR_FILA_G '131','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',2,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',3,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',4,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',5,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',6,'006',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',7,'007',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',8,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',9,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',10,'010',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',11,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',12,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',13,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',14,'014',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',15,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',16,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',17,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',18,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',19,'019',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','001',20,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',1,'USUARIO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',2,'HARDWARE-PERIFERICOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',3,'HARDWARE-CPU',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',4,'HARDWARE-IMPRESORAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',5,'HARDWARE-FUENTES DE ALIMENTACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',6,'HARDWARE-DISCO DURO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',7,'HARDWARE-MISCELANEOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',8,'SISTEMA OPERATIVO-WINDOWS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',9,'SISTEMA OPERATIVO-DRIVERS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',10,'SISTEMA OPERATIVO-PROGRAMAS TERCEROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',11,'SISTEMA OPERATIVO-CONFIGURACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',12,'SISTEMA OPERATIVO-REDES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',13,'SISTEMA OPERATIVO-SEGURIDAD',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',14,'SISTEMA OPERATIVO-MISCELANEOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',15,'CONEXIONES DE RED',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',16,'SOFTWARE-REQUISITOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',17,'SOFTWARE-VENTAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',18,'SOFTWARE-ADMINISTRACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',19,'MISCELANEOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','002',20,'SIN DEFINIR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',11,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',12,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',13,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',14,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',15,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',16,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',17,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',18,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',19,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '131','003',20,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
GO
--Prioridad Incidencias 
EXEC dbo.USP_PAR_TABLA_G '132','PRIORIDADES_INCIDENCIAS','Almacena las prioridades de incidencias','001',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '132','001','Cod_Prioridad','Almacena el codigo de las prioridades de incidencias','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '132','002','Des_Prioridad','Almacena la descripcion de las prioridades de incidencias','CADENA',0,1024,'',0,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '132','003','Estado','Estado','BOLEANO',0,64,'',0,'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '132';
GO
EXEC USP_PAR_FILA_G '132','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','001',2,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','001',3,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','001',4,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','001',5,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','001',6,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',1,'MUY BAJA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',2,'BAJA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',3,'REGULAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',4,'ALTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',5,'MUY ALTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','002',6,'SIN DEFINIR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '132','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
GO
--Tipos de incidencia
EXEC dbo.USP_PAR_TABLA_G '133','TIPOS_INCIDENCIAS','Almacena los tipos de incidencias','001',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '133','001','Cod_Tipo','Almacena el codigo del tipo incidencia','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '133','002','Cod_Categoria','Almacena el codigo de la categoria de incidencias','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '133','003','Des_Tipo','Almacena la descripcion del tipo de incidencias','CADENA',0,1024,'',0,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '133','004','Estado','Estado','BOLEANO',0,64,'',0,'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '133';
GO
EXEC USP_PAR_FILA_G '133','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',2,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',3,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',4,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',5,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',6,'006',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',7,'007',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',8,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',9,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',10,'010',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',11,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',12,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',13,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',14,'014',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',15,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',16,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',17,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',18,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',19,'019',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',20,'020',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',21,'021',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',22,'022',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',23,'023',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',24,'024',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',25,'025',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',26,'026',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',27,'027',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',28,'028',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',29,'029',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',30,'030',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',31,'031',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',32,'032',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',33,'033',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',34,'034',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',35,'035',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',36,'036',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',37,'037',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',38,'038',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',39,'039',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',40,'040',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',41,'041',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',42,'042',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',43,'043',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',44,'044',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',45,'045',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',46,'046',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',47,'047',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',48,'048',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',49,'049',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',50,'050',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',51,'051',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',52,'052',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',53,'053',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',54,'054',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',55,'055',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',56,'056',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',57,'057',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',58,'058',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',59,'059',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',60,'060',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',61,'061',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',62,'062',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',63,'063',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',64,'064',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',65,'065',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',66,'066',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',67,'067',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',68,'068',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',69,'069',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',70,'070',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',71,'071',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',72,'072',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',73,'073',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',74,'074',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',75,'075',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',76,'076',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',77,'077',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',78,'078',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',79,'079',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',80,'080',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',81,'081',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',82,'082',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',83,'083',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',84,'084',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',85,'085',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',86,'086',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',87,'087',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',88,'088',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',89,'089',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',90,'090',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',91,'091',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',92,'092',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',93,'093',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',94,'094',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',95,'095',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',96,'096',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',97,'097',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',98,'098',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',99,'099',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',100,'100',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',101,'101',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',102,'102',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',103,'103',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',104,'104',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',105,'105',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',106,'106',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',107,'107',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',108,'108',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',109,'109',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',110,'110',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',111,'111',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',112,'112',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',113,'113',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',114,'114',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',115,'115',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',116,'116',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',117,'117',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',118,'118',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','001',119,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',2,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',3,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',4,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',5,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',6,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',7,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',8,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',9,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',10,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',11,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',12,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',13,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',14,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',15,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',16,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',17,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',18,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',19,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',20,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',21,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',22,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',23,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',24,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',25,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',26,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',27,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',28,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',29,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',30,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',31,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',32,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',33,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',34,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',35,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',36,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',37,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',38,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',39,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',40,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',41,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',42,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',43,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',44,'006',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',45,'006',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',46,'007',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',47,'007',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',48,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',49,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',50,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',51,'008',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',52,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',53,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',54,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',55,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',56,'010',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',57,'010',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',58,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',59,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',60,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',61,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',62,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',63,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',64,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',65,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',66,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',67,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',68,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',69,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',70,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',71,'013',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',72,'014',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',73,'014',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',74,'014',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',75,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',76,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',77,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',78,'015',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',79,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',80,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',81,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',82,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',83,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',84,'016',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',85,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',86,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',87,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',88,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',89,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',90,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',91,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',92,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',93,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',94,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',95,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',96,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',97,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',98,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',99,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',100,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',101,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',102,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',103,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',104,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',105,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',106,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',107,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',108,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',109,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',110,'017',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',111,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',112,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',113,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',114,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',115,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',116,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',117,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',118,'018',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','002',119,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',1,'PROBLEMAS DE CAPACITACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',2,'PROBLEMAS AL FACTURAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',3,'PROBLEMAS AL OBTENER REPORTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',4,'PROBLEMAS EN CAMBIO DE TURNOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',5,'PROBLEMAS EN MEDICION DE CONTOMETROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',6,'PROBLEMAS DE ARQUEO TURNOS/CAJAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',7,'PROBLEMAS DE ASIGNACION DE PERMISOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',8,'PROBLEMAS DE CONFIGURAR CAJAS/ISLAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',9,'PROBLEMAS DE ACCESO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',10,'PROBLEMAS DE INGRESO/MODIFICACION DE CLIENTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',11,'PROBLEMAS AL REGISTRAR COMPROBANTES/DOCUMENTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',12,'PROBLEMAS DE CAMBIO DE PRECIOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',13,'PROBLEMAS DE INGRESO/MODIFICACION DE PRODUCTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',14,'USUARIO-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',15,'MONITOR NO ENCIENDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',16,'MONITOR CON IMAGEN DISTORSIONADA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',17,'MONITOR CON IMAGEN EN NEGRO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',18,'MONITOR-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',19,'TECLADO NO ENCIENDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',20,'TECLADO NO ESCRIBE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',21,'TECLADO DESCONFIGURADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',22,'TECLADO-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',23,'MOUSE NO ENCIENDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',24,'MOUSE ENCENDIDO PERO NO RESPONDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',25,'MOUSE-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',26,'PUERTOS NO RECONOCE DISPOSITIVOS EXTERNOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',27,'PUERTOS -OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',28,'HARDWARE-PERIFERICOS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',29,'CPU NO ENCIENDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',30,'CPU RUIDOS ANOMALOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',31,'CPU OLORES ANOMALOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',32,'CPU-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',33,'IMPRESORA NO ENCIENDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',34,'CAMBIO DE ROLLO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',35,'ATASCAMIENTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',36,'CAMBIO DE TINTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',37,'PROBLEMAS CON CABLE DE CONEXIÓN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',38,'PROBLEMAS CON FUENTE DE ALIMENTACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',39,'HARDWARE-IMPRESORAS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',40,'PROBLEMAS CON EL ESTABILIZADOR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',41,'OLORES/SONIDOS ANOMALOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',42,'PROBLEMAS CON UPS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',43,'HARDWARE-FUENTES DE ALIMENTACION-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',44,'CAPACIDAD DE DISCO DURO EXCEDIDA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',45,'HARDWARE-DISCO DURO-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',46,'EQUIPO DEMASIADO LENTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',47,'HARDWARE-MISCELANEOS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',48,'PROBLEMAS DE ARRANQUE DE WINDOWS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',49,'PROBLEMAS DE INICIO DE SESION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',50,'PROBLEMAS DE BOOT DE WINDOWS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',51,'SISTEMA OPERATIVO-WINDOWS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',52,'FALTA DRIVERS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',53,'INSTALACION/DESINSTALACION DRIVERS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',54,'ACTUALIZACION DE DRIVERS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',55,'SISTEMA OPERATIVO-DRIVERS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',56,'INSTALACION/DESINSTALACION PROGRAMAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',57,'SISTEMA OPERATIVO-PROGRAMAS TERCEROS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',58,'PROBLEMAS DE CONFIGURACION REGIONAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',59,'PROBLEMAS DE CONFIGURACION DE FECHA/HORA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',60,'PROBLEMAS DE CONFIGURACION DE IDIOMA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',61,'PROBLEMAS DE CONFIGURACION DE ESCRITORIO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',62,'SISTEMA OPERATIVO-CONFIGURACION-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',63,'PROBLEMAS DE CONECTIVIDAD A INTERNET',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',64,'PROBLEMAS DE CONFIGURACION DE RED',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',65,'PROBLEMAS DE DETECCION DE EQUIPOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',66,'PROBLEMAS DE FIREWALL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',67,'SISTEMA OPERATIVO-REDES-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',68,'PROBLEMAS CON MALWARE/VIRUS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',69,'RESTAURACION DE WINDOWS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',70,'PROBLEMAS CON ANTIVIRUS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',71,'SISTEMA OPERATIVO-SEGURIDAD-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',72,'RECUPERACION DE ARCHIVOS ELIMINADOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',73,'PERMISOS DE LECTURA/ESCRITURA DE CARPETAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',74,'SISTEMA OPERATIVO-MISCELANEOS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',75,'PROBLEMAS DE ROUTER/MODEN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',76,'PROBLEMAS DE CABLEADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',77,'PROBLEMAS DEL PROVEEDOR DE INTERNET',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',78,'CONEXIONES DE RED-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',79,'INSTALACION/REINSTALACION DE COMPONENTES PALERP',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',80,'INSTALACION/REINSTALACION DE FRAMEWORK',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',81,'INSTALACION/REINSTALACION DE CRYSTRAL REPORT SERVIDORES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',82,'INSTALACION/REINSTALACION DE CRYSTRAL REPORT CLIENTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',83,'INSTALACION/CONFIGURACION/REINSTALACION DE SQL SERVER',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',84,'SOFTWARE-REQUISITOS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',85,'INSTALACION/REINSTALACION SOFTWARE IFACTURACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',86,'PROBLEMAS DE FACTURACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',87,'PROBLEMAS AL OBTENER REPORTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',88,'PROBLEMAS EN CAMBIO DE TURNOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',89,'PROBLEMAS EN MEDICION DE CONTOMETROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',90,'PROBLEMAS DE ARQUEO TURNOS/CAJAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',91,'PROBLEMAS DE ASIGNACION DE PERMISOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',92,'PROBLEMAS DE CONFIGURAR CAJAS/ISLAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',93,'PROBLEMAS DE ACCESO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',94,'PROBLEMAS DE INGRESO/MODIFICACION DE CLIENTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',95,'PROBLEMAS AL REGISTRAR COMPROBANTES/DOCUMENTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',96,'PROBLEMAS DE CAMBIO DE PRECIOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',97,'PROBLEMAS DE INGRESO/MODIFICACION DE PRODUCTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',98,'MODIFICACION DE DOCUMENTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',99,'MODIFICACION DE REPORTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',100,'MODIFICACION DE COMPROBANTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',101,'MODIFICACION DE MEDICIONES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',102,'MODIFICACION DE ARQUEOS/CIERRES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',103,'MODIFICACION DE CAJAS/ISLAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',104,'MODIFICACION DE PRECIOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',105,'ELIMINACION DE COMPROBANTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',106,'ELIMINACION DE DOCUMENTOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',107,'PROBLEMAS DE CONEXIÓN CON SQL SERVER',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',108,'ENVIO DE REPORTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',109,'ENVIO DE REPORTES DETALLADOS/PERSONALIZADOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',110,'SOFTWARE-VENTAS-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',111,'PROBLEMAS DE CONFIGURACION DE EMPRESA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',112,'PROBLEMAS DE CONFIGURACION DE CAJAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',113,'PROBLEMAS DE CONFIGURACION DE CUENTAS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',114,'PROBLEMAS DE CONFIGURACION CLIENTES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',115,'PROBLEMAS DE CONFIGURACION PERMISOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',116,'PROBLEMAS DE CONFIGURACION USUARIOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',117,'PROBLEMAS DE CONFIGURACON PARAMETROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',118,'SOFTWARE-ADMINISTRACION-OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','003',119,'SIN DEFINIR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',11,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',12,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',13,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',14,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',15,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',16,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',17,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',18,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',19,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',20,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',21,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',22,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',23,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',24,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',25,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',26,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',27,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',28,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',29,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',30,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',31,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',32,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',33,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',34,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',35,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',36,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',37,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',38,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',39,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',40,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',45,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',46,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',47,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',48,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',49,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',50,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',51,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',52,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',53,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',54,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',55,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',56,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',57,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',58,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',59,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',60,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',61,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',62,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',63,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',64,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',65,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',66,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',67,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',68,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',69,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',70,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',71,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',72,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',73,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',74,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',75,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',76,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',77,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',78,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',79,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',80,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',81,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',82,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',83,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',84,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',85,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',86,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',87,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',88,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',89,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',90,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',91,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',92,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',93,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',94,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',95,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',96,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',97,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',98,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',99,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',100,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',101,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',102,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',103,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',104,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',105,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',106,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',107,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',108,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',109,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',110,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',111,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',112,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',113,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',114,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',115,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',116,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',117,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',118,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '133','004',119,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
--Origen de las incidencias
EXEC dbo.USP_PAR_TABLA_G '134','ORIGENES_INCIDENCIAS','Almacena los origenes de las incidencias','001',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '134','001','Cod_Origen','Almacena el codigo de la categoria','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '134','002','Des_Origen','Almacena la descripcion de la categoria','CADENA',0,1024,'',0,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '134','003','Estado','Estado','BOLEANO',0,64,'',0,'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '134';
GO
EXEC USP_PAR_FILA_G '134','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',2,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',3,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',4,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',5,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',6,'006',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',7,'007',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','001',8,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',1,'CELULAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',2,'TELEFONO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',3,'CORREO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',4,'WHATSAPP',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',5,'FACEBOOK',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',6,'DIRECTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',7,'OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','002',8,'SIN DEFINIR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '134','003',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
GO

--Estados de las incidencias
EXEC dbo.USP_PAR_TABLA_G '135','ESTADOS_INCIDENCIAS','Almacena los estados de las incidencias','001',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '135','001','Cod_Estado','Almacena el codigo del estado','CADENA',0, 32,'',1,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '135','002','Des_Estado','Almacena la descripcion del estado','CADENA',0,1024,'',0,'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '135','003','Estado','Estado','BOLEANO',0,64,'',0,'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '135';
GO
EXEC USP_PAR_FILA_G '135','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','001',2,'002',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','001',3,'003',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','001',4,'004',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','001',5,'005',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','002',1,'EN ATENCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','002',2,'PAUSADO MANUAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','002',3,'PAUSADO AUTOMATICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','002',4,'FINALIZADO SIN ENCUESTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','002',5,'FINALIZADO CON ENCUESTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '135','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
GO


IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_TraerTerminalesXIDClienteFlagEstado'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TraerTerminalesXIDClienteFlagEstado;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TraerTerminalesXIDClienteFlagEstado @Id_ClienteProveedor INT, 
                                                                        @FlagActivo          BIT = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               st.Id_Terminal, 
               st.Id_ClienteProveedor, 
               st.Des_Terminal, 
               st.MAC_Terminal, 
               st.Id_Sistema, 
               st.Serie_Sistema, 
               st.Fecha_Creacion,
               CASE
                   WHEN st.Id_TeamViewer IS NULL
                        OR LEN(RTRIM(LTRIM(st.Id_TeamViewer))) = 0
                   THEN NULL
                   ELSE st.Id_TeamViewer
               END Id_TeamViewer,
               CASE
                   WHEN st.Pass_Teamviewer IS NULL
                        OR LEN(RTRIM(LTRIM(st.Pass_Teamviewer))) = 0
                   THEN NULL
                   ELSE st.Pass_Teamviewer
               END Pass_Teamviewer,
               CASE
                   WHEN st.Id_AnyDesk IS NULL
                        OR LEN(RTRIM(LTRIM(st.Id_AnyDesk))) = 0
                   THEN NULL
                   ELSE st.Id_AnyDesk
               END Id_AnyDesk,
               CASE
                   WHEN st.Pass_AnyDesk IS NULL
                        OR LEN(RTRIM(LTRIM(st.Pass_AnyDesk))) = 0
                   THEN NULL
                   ELSE st.Pass_AnyDesk
               END Pass_AnyDesk, 
               st.Id_Otros, 
               st.Pass_Otros, 
               st.Flag_Estado, 
               st.Cod_Estado, 
               st.Obs_Terminal
        FROM dbo.SOP_TERMINALES st
        WHERE st.Id_ClienteProveedor = @Id_ClienteProveedor
              AND (@FlagActivo IS NULL
                   OR st.Flag_Estado = @FlagActivo)
        ORDER BY st.Des_Terminal;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_CONTACTO_TraerXIdClienteProveedor'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_CONTACTO_TraerXIdClienteProveedor;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_TraerXIdClienteProveedor @Id_ClienteProveedor INT
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            pcc.Id_ClienteProveedor, 
            pcc.Id_ClienteContacto, 
            pcc.Cod_TipoDocumento, 
            pcc.Nro_Documento, 
            pcc.Ap_Paterno, 
            pcc.Ap_Materno, 
            pcc.Nombres, 
            CONCAT(pcc.Nombres, ' ', pcc.Ap_Paterno, ' ', pcc.Ap_Materno) Nombres_Completo, 
            pcc.Cod_Telefono, 
            pcc.Nro_Telefono, 
            pcc.Anexo, 
            pcc.Email_Empresarial, 
            pcc.Email_Personal, 
            pcc.Celular, 
            pcc.Cod_TipoRelacion, 
            vtr.Nom_TipoRelacion, 
            pcc.Fecha_Incorporacion
     FROM dbo.PRI_CLIENTE_CONTACTO pcc
          INNER JOIN dbo.VIS_TIPO_RELACION vtr ON pcc.Cod_TipoRelacion = vtr.Cod_TipoRelacion
     WHERE pcc.Id_ClienteProveedor = @Id_ClienteProveedor
     ORDER BY CONCAT(pcc.Nombres, ' ', pcc.Ap_Paterno, ' ', pcc.Ap_Materno);
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_INCIDENCIAS_TraerPENDIENTESPAUSADOS'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TraerPENDIENTESPAUSADOS;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TraerPENDIENTESPAUSADOS @Cod_TipoIncidencia VARCHAR(32) = NULL, 
                                                             @Cod_Prioridad      VARCHAR(8)  = NULL, 
                                                             @Cod_MedioOrigen    VARCHAR(8)  = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT T1.*, 
               CAST(NULL AS IMAGE) Imagen_Estado
        FROM
        (
            SELECT DISTINCT 
                   si.Id_Incidencia, 
                   si.Id_Terminal, 
                   st.Des_Terminal, 
                   st.Id_ClienteProveedor, 
                   pcp.Cod_TipoDocumento, 
                   pcp.Nro_Documento, 
                   pcp.Cliente, 
                   si.Cod_TipoIncidencia, 
                   vti.Des_Tipo, 
                   si.Cod_Prioridad, 
                   vpi.Des_Prioridad, 
                   si.Detalle, 
                   si.Respuesta, 
                   si.Cod_MedioOrigen, 
                   voi.Des_Origen, 
                   si.Obs_Incidencia, 
                   si.Cod_Estado, 
                   vei.Des_Estado, 
                   si.Cod_UsuarioIncidencia
            FROM dbo.SOP_INCIDENCIAS si
                 INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
                 INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
                 LEFT JOIN dbo.VIS_TIPOS_INCIDENCIAS vti ON si.Cod_TipoIncidencia = vti.Cod_Tipo
                 LEFT JOIN dbo.VIS_PRIORIDADES_INCIDENCIAS vpi ON si.Cod_Prioridad = vpi.Cod_Prioridad
                 LEFT JOIN dbo.VIS_ORIGENES_INCIDENCIAS voi ON si.Cod_MedioOrigen = voi.Cod_Origen
                 LEFT JOIN dbo.VIS_ESTADOS_INCIDENCIAS vei ON si.Cod_Estado = vei.Cod_Estado
            WHERE(@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
                 AND (@Cod_Prioridad IS NULL
                      OR si.Cod_Prioridad = @Cod_Prioridad)
                 AND (@Cod_MedioOrigen IS NULL
                      OR si.Cod_MedioOrigen = @Cod_MedioOrigen)
                 AND si.Cod_Estado IN('001', '002', '003')
        ) T1
        ORDER BY T1.Id_Incidencia, 
                 T1.Des_Terminal, 
                 T1.Cliente;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_ASISTENCIAS_TraerXIdIncidencia'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_ASISTENCIAS_TraerXIdIncidencia;
GO
CREATE PROCEDURE USP_SOP_ASISTENCIAS_TraerXIdIncidencia @Id_Incidencia INT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               sa.Id_Incidencia, 
               sa.Item, 
               sa.Fecha_Inicio, 
               sa.Fecha_Fin, 
               sa.Tiempo, 
               sa.Cod_UsuarioAsistencia, 
               sa.Obs_Asistencia
        FROM dbo.SOP_ASISTENCIAS sa
        WHERE(@Id_Incidencia IS NULL
              OR sa.Id_Incidencia = @Id_Incidencia)
    END;
GO

--Traer ultimas incidencias resueltas sin encuesta ordenadas por la ultima fecha de asistencia
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_INCIDENCIAS_TopIncidenciasResueltasSINENCUESTA'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_INCIDENCIAS_TopIncidenciasResueltasSINENCUESTA;
GO
CREATE PROCEDURE USP_SOP_INCIDENCIAS_TopIncidenciasResueltasSINENCUESTA @NroFilas INT = 10
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT TOP (@NroFilas) si.Id_Incidencia, 
                                        st.Id_ClienteProveedor, 
                                        pcp.Cod_TipoDocumento, 
                                        pcp.Nro_Documento, 
                                        pcp.Cliente, 
                                        si.Id_Terminal, 
                                        st.Des_Terminal, 
                                        si.Cod_Estado, 
                                        vei.Des_Estado, 
                                        si.Cod_TipoIncidencia, 
                                        vti.Des_Tipo, 
                                        si.Cod_Prioridad, 
                                        vpi.Des_Prioridad, 
                                        SUM(sa.Tiempo) Sumatoria_TiempoAsistencia, 
                                        MIN(sa.Fecha_Inicio) Min_FechaInicioAsistencia, 
                                        MAX(sa.Fecha_Fin) Max_FechaFinAsistencia, 
                                        COUNT(sa.Item) Intervalos_Asistencias, 
                                        si.Cod_UsuarioIncidencia
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_ESTADOS_INCIDENCIAS vei ON vei.Cod_Estado = si.Cod_Estado
             INNER JOIN dbo.VIS_TIPOS_INCIDENCIAS vti ON si.Cod_TipoIncidencia = vti.Cod_Tipo
             INNER JOIN dbo.VIS_PRIORIDADES_INCIDENCIAS vpi ON si.Cod_Prioridad = vpi.Cod_Prioridad
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
        WHERE si.Cod_Estado = '004'
              AND st.Flag_Estado = 1
        GROUP BY si.Id_Incidencia, 
                 st.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente, 
                 si.Id_Terminal, 
                 st.Des_Terminal, 
                 si.Cod_Estado, 
                 vei.Des_Estado, 
                 si.Cod_TipoIncidencia, 
                 vti.Des_Tipo, 
                 si.Cod_Prioridad, 
                 vpi.Des_Prioridad, 
                 si.Cod_UsuarioIncidencia
        ORDER BY MAX(sa.Fecha_Fin) DESC;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_AsistenciasPendientesXIdTerminal'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_AsistenciasPendientesXIdTerminal;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_AsistenciasPendientesXIdTerminal @Id_Terminal INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT st.Id_Terminal, 
               st.Des_Terminal, 
               COUNT(si.Id_Incidencia) Asistencias_Pendientes
        FROM dbo.SOP_TERMINALES st
             LEFT JOIN dbo.SOP_INCIDENCIAS si ON st.Id_Terminal = si.Id_Terminal
                                                 AND si.Cod_Estado IN('001', '002', '003')
        WHERE st.Id_Terminal = @Id_Terminal
        GROUP BY st.Id_Terminal, 
                 st.Des_Terminal
        ORDER BY st.Des_Terminal;
    END;
GO

--Obtiene el reporte de incidencias por dia agrupado por estado
--DECLARE @Fecha datetime = GETDATE()
--EXEC URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorEstado @Fecha
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorEstado'
          AND type = 'P'
)
    DROP PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorEstado;
GO
CREATE PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorEstado @Fecha                   DATETIME, 
                                                                  @Cod_EstadoIncidencia    VARCHAR(32) = NULL, 
                                                                  @Cod_OrigenIncidencia    VARCHAR(8)  = NULL, 
                                                                  @Cod_PrioridadIncidencia VARCHAR(8)  = NULL, 
                                                                  @Cod_TipoIncidencia      VARCHAR(32) = NULL, 
                                                                  @Cod_Usuario             VARCHAR(32) = NULL, 
                                                                  @Id_Cliente              INT         = NULL, 
                                                                  @Id_Terminal             INT         = NULL
AS
    BEGIN
        --REPORTE DEL DIA AGRUPADO POR ESTADO
        SELECT DISTINCT 
               vei.Cod_Estado, 
               vei.Des_Estado, 
               ISNULL(COUNT(si.Id_Incidencia), 0) Total_Incidencias, 
               ISNULL(COUNT(sa.Item), 0) Total_Asistencias, 
               ISNULL(SUM(sa.Tiempo), 0) Tiempo_TotalSegundos,
               CASE
                   WHEN ISNULL(COUNT(si.Id_Incidencia), 0.00) = 0.00
                   THEN 0.00
                   ELSE ISNULL(SUM(sa.Tiempo), 0.00) / ISNULL(COUNT(si.Id_Incidencia), 0.00)
               END Promedio_SegundosIncidencias,
               CASE
                   WHEN ISNULL(COUNT(sa.Item), 0.00) = 0.00
                   THEN 0.00
                   ELSE CAST(ISNULL(SUM(sa.Tiempo), 0.00) AS NUMERIC(38, 2)) / ISNULL(COUNT(sa.Item), 0.00)
               END Promedio_SegundosAsistencias
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
             INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
             RIGHT JOIN dbo.VIS_ESTADOS_INCIDENCIAS vei ON si.Cod_Estado = vei.Cod_Estado
                                                           AND CONVERT(DATE, si.Fecha_Reg) = CONVERT(DATE, @Fecha)
        WHERE(@Cod_EstadoIncidencia IS NULL
              OR si.Cod_Estado = @Cod_EstadoIncidencia)
             AND (@Cod_OrigenIncidencia IS NULL
                  OR si.Cod_MedioOrigen = @Cod_OrigenIncidencia)
             AND (@Cod_PrioridadIncidencia IS NULL
                  OR si.Cod_Prioridad = @Cod_PrioridadIncidencia)
             AND (@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
             AND (@Cod_Usuario IS NULL
                  OR si.Cod_UsuarioIncidencia = @Cod_Usuario)
             AND (@Id_Cliente IS NULL
                  OR st.Id_ClienteProveedor = @Id_Cliente)
             AND (@Id_Terminal IS NULL
                  OR si.Id_Terminal = @Id_Terminal)
             AND vei.Estado = 1
        GROUP BY vei.Cod_Estado, 
                 vei.Des_Estado
        ORDER BY vei.Cod_Estado;
    END;
GO

--Obtiene el reporte de incidencias por dia agrupado por terminal
--DECLARE @Fecha datetime = GETDATE()
--EXEC URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorTerminal @Fecha
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorTerminal'
          AND type = 'P'
)
    DROP PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorTerminal;
GO
CREATE PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorTerminal @Fecha                   DATETIME, 
                                                                    @Cod_EstadoIncidencia    VARCHAR(32) = NULL, 
                                                                    @Cod_OrigenIncidencia    VARCHAR(8)  = NULL, 
                                                                    @Cod_PrioridadIncidencia VARCHAR(8)  = NULL, 
                                                                    @Cod_TipoIncidencia      VARCHAR(32) = NULL, 
                                                                    @Cod_Usuario             VARCHAR(32) = NULL, 
                                                                    @Id_Cliente              INT         = NULL, 
                                                                    @Id_Terminal             INT         = NULL
AS
    BEGIN
        --REPORTE DEL DIA AGRUPADO POR TERMINAL
        SELECT DISTINCT 
               st.Id_Terminal, 
               st.Des_Terminal, 
               pcp.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               ISNULL(COUNT(si.Id_Incidencia), 0) Total_Incidencias, 
               ISNULL(COUNT(sa.Item), 0) Total_Asistencias, 
               ISNULL(SUM(sa.Tiempo), 0) Tiempo_TotalSegundos,
               CASE
                   WHEN ISNULL(COUNT(si.Id_Incidencia), 0.00) = 0.00
                   THEN 0.00
                   ELSE ISNULL(SUM(sa.Tiempo), 0.00) / ISNULL(COUNT(si.Id_Incidencia), 0.00)
               END Promedio_SegundosIncidencias,
               CASE
                   WHEN ISNULL(COUNT(sa.Item), 0.00) = 0.00
                   THEN 0.00
                   ELSE CAST(ISNULL(SUM(sa.Tiempo), 0.00) AS NUMERIC(38, 2)) / ISNULL(COUNT(sa.Item), 0.00)
               END Promedio_SegundosAsistencias
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
             RIGHT JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
                                                 AND CONVERT(DATE, si.Fecha_Reg) = CONVERT(DATE, @Fecha)
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
        WHERE(@Cod_EstadoIncidencia IS NULL
              OR si.Cod_Estado = @Cod_EstadoIncidencia)
             AND (@Cod_OrigenIncidencia IS NULL
                  OR si.Cod_MedioOrigen = @Cod_OrigenIncidencia)
             AND (@Cod_PrioridadIncidencia IS NULL
                  OR si.Cod_Prioridad = @Cod_PrioridadIncidencia)
             AND (@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
             AND (@Cod_Usuario IS NULL
                  OR si.Cod_UsuarioIncidencia = @Cod_Usuario)
             AND (@Id_Cliente IS NULL
                  OR st.Id_ClienteProveedor = @Id_Cliente)
             AND (@Id_Terminal IS NULL
                  OR si.Id_Terminal = @Id_Terminal)
             AND st.Flag_Estado = 1
        GROUP BY st.Id_Terminal, 
                 st.Des_Terminal, 
                 pcp.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente
        ORDER BY st.Des_Terminal;
    END;
GO

--Obtiene el reporte de incidencias por dia agrupado por Cliente
--DECLARE @Fecha datetime = GETDATE()
--EXEC URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorCliente @Fecha
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorCliente'
          AND type = 'P'
)
    DROP PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorCliente;
GO
CREATE PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorCliente @Fecha                   DATETIME, 
                                                                   @Cod_EstadoIncidencia    VARCHAR(32) = NULL, 
                                                                   @Cod_OrigenIncidencia    VARCHAR(8)  = NULL, 
                                                                   @Cod_PrioridadIncidencia VARCHAR(8)  = NULL, 
                                                                   @Cod_TipoIncidencia      VARCHAR(32) = NULL, 
                                                                   @Cod_Usuario             VARCHAR(32) = NULL, 
                                                                   @Id_Cliente              INT         = NULL, 
                                                                   @Id_Terminal             INT         = NULL
AS
    BEGIN
        --REPORTE DEL DIA AGRUPADO POR CLIENTE
        SELECT DISTINCT 
               pcp.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               ISNULL(COUNT(si.Id_Incidencia), 0) Total_Incidencias, 
               ISNULL(COUNT(sa.Item), 0) Total_Asistencias, 
               ISNULL(SUM(sa.Tiempo), 0) Tiempo_TotalSegundos,
               CASE
                   WHEN ISNULL(COUNT(si.Id_Incidencia), 0.00) = 0.00
                   THEN 0.00
                   ELSE ISNULL(SUM(sa.Tiempo), 0.00) / ISNULL(COUNT(si.Id_Incidencia), 0.00)
               END Promedio_SegundosIncidencias,
               CASE
                   WHEN ISNULL(COUNT(sa.Item), 0.00) = 0.00
                   THEN 0.00
                   ELSE CAST(ISNULL(SUM(sa.Tiempo), 0.00) AS NUMERIC(38, 2)) / ISNULL(COUNT(sa.Item), 0.00)
               END Promedio_SegundosAsistencias
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
             INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
                                                 AND CONVERT(DATE, si.Fecha_Reg) = CONVERT(DATE, @Fecha)
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
        WHERE(@Cod_EstadoIncidencia IS NULL
              OR si.Cod_Estado = @Cod_EstadoIncidencia)
             AND (@Cod_OrigenIncidencia IS NULL
                  OR si.Cod_MedioOrigen = @Cod_OrigenIncidencia)
             AND (@Cod_PrioridadIncidencia IS NULL
                  OR si.Cod_Prioridad = @Cod_PrioridadIncidencia)
             AND (@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
             AND (@Cod_Usuario IS NULL
                  OR si.Cod_UsuarioIncidencia = @Cod_Usuario)
             AND (@Id_Cliente IS NULL
                  OR st.Id_ClienteProveedor = @Id_Cliente)
             AND (@Id_Terminal IS NULL
                  OR si.Id_Terminal = @Id_Terminal)
             AND st.Flag_Estado = 1
        GROUP BY pcp.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente
        ORDER BY pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente;
    END;
GO

--Obtiene el reporte de incidencias por dia agrupado por Uusarios
--DECLARE @Fecha datetime = GETDATE()
--EXEC URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorUsuario @Fecha
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorUsuario'
          AND type = 'P'
)
    DROP PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorUsuario;
GO
CREATE PROCEDURE URP_SOP_INCIDENCIAS_ReporteXDiaAgrupadoPorUsuario @Fecha                   DATETIME, 
                                                                   @Cod_EstadoIncidencia    VARCHAR(32) = NULL, 
                                                                   @Cod_OrigenIncidencia    VARCHAR(8)  = NULL, 
                                                                   @Cod_PrioridadIncidencia VARCHAR(8)  = NULL, 
                                                                   @Cod_TipoIncidencia      VARCHAR(32) = NULL, 
                                                                   @Cod_Usuario             VARCHAR(32) = NULL, 
                                                                   @Id_Cliente              INT         = NULL, 
                                                                   @Id_Terminal             INT         = NULL
AS
    BEGIN
        --REPORTE DEL DIA AGRUPADO POR USUARIOS
        SELECT DISTINCT 
               pu.Cod_Usuarios, 
               pu.Nick, 
               ISNULL(COUNT(si.Id_Incidencia), 0) Total_Incidencias, 
               ISNULL(COUNT(sa.Item), 0) Total_Asistencias, 
               ISNULL(SUM(sa.Tiempo), 0) Tiempo_TotalSegundos,
               CASE
                   WHEN ISNULL(COUNT(si.Id_Incidencia), 0.00) = 0.00
                   THEN 0.00
                   ELSE ISNULL(SUM(sa.Tiempo), 0.00) / ISNULL(COUNT(si.Id_Incidencia), 0.00)
               END Promedio_SegundosIncidencias,
               CASE
                   WHEN ISNULL(COUNT(sa.Item), 0.00) = 0.00
                   THEN 0.00
                   ELSE CAST(ISNULL(SUM(sa.Tiempo), 0.00) AS NUMERIC(38, 2)) / ISNULL(COUNT(sa.Item), 0.00)
               END Promedio_SegundosAsistencias
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
             INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
             INNER JOIN dbo.VIS_ESTADOS_INCIDENCIAS vei ON si.Cod_Estado = vei.Cod_Estado
                                                           AND CONVERT(DATE, si.Fecha_Reg) = CONVERT(DATE, @Fecha)
             INNER JOIN dbo.PRI_USUARIO pu ON si.Cod_UsuarioIncidencia = pu.Cod_Usuarios
        WHERE(@Cod_EstadoIncidencia IS NULL
              OR si.Cod_Estado = @Cod_EstadoIncidencia)
             AND (@Cod_OrigenIncidencia IS NULL
                  OR si.Cod_MedioOrigen = @Cod_OrigenIncidencia)
             AND (@Cod_PrioridadIncidencia IS NULL
                  OR si.Cod_Prioridad = @Cod_PrioridadIncidencia)
             AND (@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
             AND (@Cod_Usuario IS NULL
                  OR si.Cod_UsuarioIncidencia = @Cod_Usuario)
             AND (@Id_Cliente IS NULL
                  OR st.Id_ClienteProveedor = @Id_Cliente)
             AND (@Id_Terminal IS NULL
                  OR si.Id_Terminal = @Id_Terminal)
             AND vei.Estado = 1
        GROUP BY pu.Cod_Usuarios, 
                 pu.Nick
        ORDER BY pu.Cod_Usuarios;
    END;
GO

--Obtiene el reporte de incidencias y los tiempos usados para un usuario en un rango de fechas exactas(incluido horas)
--DECLARE @Fecha_Fin DATETIME= GETDATE();
--DECLARE @Fecha_Inicio DATETIME= DATEADD(dd, -1, @Fecha_Fin);
--EXEC URP_SOP_INCIDENCIAS_ReporteIncidenciasXRangoFechaHoraCodUsuario @Fecha_Inicio,@Fecha_Fin, 'MIGRACION';
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_SOP_INCIDENCIAS_ReporteIncidenciasXRangoFechaHoraCodUsuario'
          AND type = 'P'
)
    DROP PROCEDURE URP_SOP_INCIDENCIAS_ReporteIncidenciasXRangoFechaHoraCodUsuario;
GO
CREATE PROCEDURE URP_SOP_INCIDENCIAS_ReporteIncidenciasXRangoFechaHoraCodUsuario @Fecha_Inicio            DATETIME, 
                                                                                 @Fecha_Fin               DATETIME, 
                                                                                 @Cod_Usuario             VARCHAR(32), 
                                                                                 @Cod_EstadoIncidencia    VARCHAR(32) = NULL, 
                                                                                 @Cod_OrigenIncidencia    VARCHAR(8)  = NULL, 
                                                                                 @Cod_PrioridadIncidencia VARCHAR(8)  = NULL, 
                                                                                 @Cod_TipoIncidencia      VARCHAR(32) = NULL, 
                                                                                 @Id_Cliente              INT         = NULL, 
                                                                                 @Id_Terminal             INT         = NULL
AS
    BEGIN
        SELECT DISTINCT 
               si.Id_Terminal, 
               st.Des_Terminal, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               si.Id_Incidencia, 
               si.Detalle, 
               si.Respuesta, 
               si.Cod_Estado, 
               vei.Des_Estado, 
               si.Pregunta1, 
               si.Pregunta2, 
               si.Pregunta3, 
               ISNULL(COUNT(sa.Item), 0) Total_Asistencias, 
               ISNULL(SUM(sa.Tiempo), 0) Tiempo_TotalSegundos,
               CASE
                   WHEN ISNULL(COUNT(sa.Item), 0.00) != 0.00
                   THEN CAST(ISNULL(SUM(sa.Tiempo), 0.00) AS NUMERIC(38, 2)) / ISNULL(COUNT(sa.Item), 0)
                   ELSE 0.00
               END Tiempo_PromedioAsistencias
        FROM dbo.SOP_INCIDENCIAS si
             INNER JOIN dbo.SOP_ASISTENCIAS sa ON si.Id_Incidencia = sa.Id_Incidencia
             INNER JOIN dbo.SOP_TERMINALES st ON si.Id_Terminal = st.Id_Terminal
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_ESTADOS_INCIDENCIAS vei ON si.Cod_Estado = vei.Cod_Estado
                                                           AND ((@Fecha_Inicio IS NULL
                                                                 AND @Fecha_Fin IS NULL)
                                                                OR (si.Fecha_Reg >= @Fecha_Inicio
                                                                    AND si.Fecha_Reg <= @Fecha_Fin))
             INNER JOIN dbo.PRI_USUARIO pu ON si.Cod_UsuarioIncidencia = pu.Cod_Usuarios
        WHERE(@Cod_EstadoIncidencia IS NULL
              OR si.Cod_Estado = @Cod_EstadoIncidencia)
             AND (@Cod_OrigenIncidencia IS NULL
                  OR si.Cod_MedioOrigen = @Cod_OrigenIncidencia)
             AND (@Cod_PrioridadIncidencia IS NULL
                  OR si.Cod_Prioridad = @Cod_PrioridadIncidencia)
             AND (@Cod_TipoIncidencia IS NULL
                  OR si.Cod_TipoIncidencia = @Cod_TipoIncidencia)
             AND si.Cod_UsuarioIncidencia = @Cod_Usuario
             AND (@Id_Cliente IS NULL
                  OR st.Id_ClienteProveedor = @Id_Cliente)
             AND (@Id_Terminal IS NULL
                  OR si.Id_Terminal = @Id_Terminal)
             AND vei.Estado = 1
        GROUP BY si.Id_Incidencia, 
                 si.Detalle, 
                 si.Cod_Estado, 
                 vei.Des_Estado, 
                 si.Id_Terminal, 
                 st.Des_Terminal, 
                 pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente, 
                 si.Pregunta1, 
                 si.Pregunta2, 
                 si.Pregunta3, 
                 si.Respuesta
        ORDER BY st.Des_Terminal;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_DepartamentosTT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_DepartamentosTT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_DepartamentosTT @Flag_Activo BIT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               vd2.Cod_Departamento, 
               vd2.Nom_Departamento
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_DEPARTAMENTOS vd2 ON vd.Cod_Departamento = vd2.Cod_Departamento
        WHERE @Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo
        ORDER BY vd2.Nom_Departamento;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_ProvinciasTT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_ProvinciasTT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_ProvinciasTT @Flag_Activo BIT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               vp.Cod_Departamento, 
               vp.Cod_Provincia, 
               vp.Nom_Provincia
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                 AND vd.Cod_Provincia = vp.Cod_Provincia
        WHERE(@Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo)
        ORDER BY vp.Nom_Provincia;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_DistritosTT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_DistritosTT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_DistritosTT @Flag_Activo BIT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               vd.Cod_Ubigeo, 
               vd.Cod_Departamento, 
               vd.Cod_Provincia, 
               vd.Cod_Distrito, 
               vd.Nom_Distrito
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                 AND vd.Cod_Provincia = vp.Cod_Provincia
        WHERE(@Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo)
        ORDER BY vd.Nom_Distrito;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_EmpresasTT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_EmpresasTT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_EmpresasTT @Flag_Activo BIT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               pcp.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               replace(replace(pcp.Cliente, '&amp;', '&'), CHAR(13) + CHAR(10), ' ') Cliente, 
               pcp.Ap_Paterno, 
               pcp.Ap_Materno, 
               pcp.Nombres, 
               pcp.Direccion, 
               pcp.Cod_EstadoCliente, 
               pcp.Cod_CondicionCliente, 
               pcp.Cod_TipoCliente, 
               pcp.RUC_Natural, 
               pcp.Cod_TipoComprobante, 
               pcp.Cod_Nacionalidad, 
               pcp.Fecha_Nacimiento, 
               pcp.Cod_Sexo, 
               pcp.Email1, 
               pcp.Email2, 
               pcp.Telefono1, 
               pcp.Telefono2, 
               pcp.Fax, 
               pcp.PaginaWeb, 
               pcp.Cod_Ubigeo, 
               pcp.Cod_FormaPago, 
               pcp.Limite_Credito, 
               pcp.Num_DiaCredito
        FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
             INNER JOIN dbo.SOP_TERMINALES st ON pcp.Id_ClienteProveedor = st.Id_ClienteProveedor
        WHERE @Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo
        ORDER BY replace(replace(pcp.Cliente, '&amp;', '&'), CHAR(13) + CHAR(10), ' ');
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_SOP_TERMINALES_TerminalesTT'
          AND type = 'P'
)
    DROP PROCEDURE USP_SOP_TERMINALES_TerminalesTT;
GO
CREATE PROCEDURE USP_SOP_TERMINALES_TerminalesTT @Flag_Activo BIT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               st.Id_Terminal, 
               st.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               replace(replace(pcp.Cliente, '&amp;', '&'), CHAR(13) + CHAR(10), ' ') Cliente, 
               pcp.Cod_Ubigeo, 
               st.Des_Terminal, 
               st.MAC_Terminal, 
               st.Id_Sistema, 
               st.Serie_Sistema, 
               st.Fecha_Creacion, 
               st.Id_TeamViewer, 
               st.Pass_Teamviewer, 
               st.Id_AnyDesk, 
               st.Pass_AnyDesk, 
               st.Id_Otros, 
               st.Pass_Otros, 
               st.Flag_Estado, 
               st.Cod_Estado, 
               st.Obs_Terminal
        FROM dbo.SOP_TERMINALES st
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON st.Id_ClienteProveedor = pcp.Id_ClienteProveedor
        WHERE(@Flag_Activo IS NULL
              OR st.Flag_Estado = @Flag_Activo)
        ORDER BY st.Des_Terminal;
    END;
GO

-- --Creacion de terminales demo
--   SELECT DISTINCT  CONCAT(
--  	'EXEC USP_SOP_TERMINALES_G ', 
--  	0,',',
--  	pcp.Id_ClienteProveedor,',',
--  	'''TERMINAL ',vd.Nom_Distrito,''',',
--  	'''',pcp.Id_ClienteProveedor,''',',
--  	'''',pcp.Id_ClienteProveedor,''',',
--  	'''',pcp.Id_ClienteProveedor,''',',
--  	'@Fecha,',
--  	'''',ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)),''',',
--  	'''123456'',',
--  	'''',ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)),''',',
--  	'''paleC0nsult0res'',',
--  	''''',',
--  	''''',',
--  	'1,',
--  	'''001'',',
--  	''''',',
--  	'''MIGRACION'''
--  	) script
--  FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
--  INNER JOIN dbo.VIS_DISTRITOS vd ON pcp.Cod_Ubigeo = vd.Cod_Ubigeo