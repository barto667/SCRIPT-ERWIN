--CAJ_RESUMEN_DIARIO
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'CAJ_RESUMEN_DIARIO'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE CAJ_RESUMEN_DIARIO
        (Fecha_Serie    VARCHAR(16) NOT NULL, 
         Numero         VARCHAR(8) NOT NULL, 
         Ticket         VARCHAR(64) NULL, 
         Nom_Estado     VARCHAR(64) NOT NULL, 
         Fecha_Envio    DATETIME NULL, 
         Total_Resumen  NUMERIC(38, 4) NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME, 
         PRIMARY KEY(Fecha_Serie, Numero)
        );
END;
GO

--Guardar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_RESUMEN_DIARIO_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_RESUMEN_DIARIO_G;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_G @Fecha_Serie   VARCHAR(16), 
                                          @Numero        VARCHAR(8), 
                                          @Ticket        VARCHAR(64), 
                                          @Nom_Estado    VARCHAR(64), 
                                          @Fecha_Envio   DATETIME, 
                                          @Total_Resumen NUMERIC(38, 4), 
                                          @Cod_Usuario   VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT crd.*
            FROM dbo.CAJ_RESUMEN_DIARIO crd
            WHERE crd.Fecha_Serie = @Fecha_Serie
                  AND crd.Numero = @Numero
        )
            BEGIN
                INSERT INTO dbo.CAJ_RESUMEN_DIARIO
                VALUES
                (@Fecha_Serie, -- Fecha_Serie - VARCHAR
                 @Numero, -- Numero - VARCHAR
                 @Ticket, -- Ticket - VARCHAR
                 @Nom_Estado, -- Nom_Estado - VARCHAR
                 @Fecha_Envio, -- Fecha_Envio - DATETIME
                 @Total_Resumen, -- Total_Resumen - NUMERIC
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_RESUMEN_DIARIO
                  SET 
                      dbo.CAJ_RESUMEN_DIARIO.Ticket = @Ticket, -- VARCHAR
                      dbo.CAJ_RESUMEN_DIARIO.Nom_Estado = @Nom_Estado, -- VARCHAR
                      dbo.CAJ_RESUMEN_DIARIO.Fecha_Envio = @Fecha_Envio, -- DATETIME
                      dbo.CAJ_RESUMEN_DIARIO.Total_Resumen = @Total_Resumen, -- NUMERIC
                      dbo.CAJ_RESUMEN_DIARIO.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.CAJ_RESUMEN_DIARIO.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.CAJ_RESUMEN_DIARIO.Fecha_Serie = @Fecha_Serie
                      AND dbo.CAJ_RESUMEN_DIARIO.Numero = @Numero;
        END;
    END;
GO

--Eliminar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_RESUMEN_DIARIO_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_RESUMEN_DIARIO_E;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_E @Fecha_Serie VARCHAR(16), 
                                          @Numero      VARCHAR(8)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.CAJ_RESUMEN_DIARIO
        WHERE dbo.CAJ_RESUMEN_DIARIO.Fecha_Serie = @Fecha_Serie
              AND dbo.CAJ_RESUMEN_DIARIO.Numero = @Numero;
    END;
GO

--Traer datos del resumen diario
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_RESUMEN_DIARIO_TXFechaSerieNumero'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_RESUMEN_DIARIO_TXFechaSerieNumero;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_TXFechaSerieNumero @Fecha_Serie VARCHAR(16), 
                                                           @Numero      VARCHAR(8)
WITH ENCRYPTION
AS
    BEGIN
        SELECT crd.*
        FROM dbo.CAJ_RESUMEN_DIARIO crd
        WHERE crd.Fecha_Serie = @Fecha_Serie
              AND crd.Numero = @Numero;
    END;
GO

--Tarer todo
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_RESUMEN_DIARIO_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_RESUMEN_DIARIO_TT;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT crd.*
        FROM dbo.CAJ_RESUMEN_DIARIO crd;
    END;
GO

--CAJ_COMUNICACION_BAJA
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'CAJ_COMUNICACION_BAJA'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE CAJ_COMUNICACION_BAJA
        (Cod_TipoComprobante VARCHAR(8) NOT NULL, 
         Serie               VARCHAR(5) NOT NULL, 
         Numero              VARCHAR(32) NOT NULL, 
         Fecha_Emision       DATETIME NOT NULL, 
         Numero_Comunicado   VARCHAR(16) NULL, 
         Justificacion       VARCHAR(MAX) NOT NULL, 
         Fecha_Comunicacion  DATETIME NULL, 
         Ticket              VARCHAR(64) NULL, 
         Mensaje_Respuesta   VARCHAR(MAX) NULL, 
         Cod_Estado          VARCHAR(32) NOT NULL, 
         Cod_Usuario         VARCHAR(64) NOT NULL, 
         Cod_UsuarioReg      VARCHAR(32) NOT NULL, 
         Fecha_Reg           DATETIME NOT NULL, 
         Cod_UsuarioAct      VARCHAR(32), 
         Fecha_Act           DATETIME, 
         PRIMARY KEY(Cod_TipoComprobante, Serie, Numero)
        );
END;
GO

--Guardar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMUNICACION_BAJA_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMUNICACION_BAJA_G;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_G @Cod_TipoComprobante VARCHAR(8), 
                                             @Serie               VARCHAR(5), 
                                             @Numero              VARCHAR(32), 
                                             @Fecha_Emision       DATETIME, 
                                             @Numero_Comunicado   VARCHAR(16), 
                                             @Justificacion       VARCHAR(MAX), 
                                             @Fecha_Comunicacion  DATETIME, 
                                             @Ticket              VARCHAR(64), 
                                             @Mensaje_Respuesta   VARCHAR(MAX), 
                                             @Cod_Estado          VARCHAR(32), 
                                             @Cod_Usuario         VARCHAR(64), 
                                             @Cod_UsuarioReg      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT ccp.*
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_Libro = '14'
                  AND ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND ccp.Serie = @Serie
                  AND ccp.Numero = @Numero
        )
            BEGIN
                IF NOT EXISTS
                (
                    SELECT ccb.*
                    FROM dbo.CAJ_COMUNICACION_BAJA ccb
                    WHERE ccb.Cod_TipoComprobante = @Cod_TipoComprobante
                          AND ccb.Serie = @Serie
                          AND ccb.Numero = @Numero
                )
                    BEGIN
                        INSERT INTO dbo.CAJ_COMUNICACION_BAJA
                        VALUES
                        (@Cod_TipoComprobante, -- Cod_TipoComprobante - VARCHAR
                         @Serie, -- Serie - VARCHAR
                         @Numero, -- Numero - VARCHAR
                         @Fecha_Emision, -- Fecha_Emision - DATETIME
                         @Numero_Comunicado, -- Numero_Comunicado - VARCHAR
                         @Justificacion, -- Justificacion - VARCHAR
                         @Fecha_Comunicacion, -- Fecha_Comunicacion - DATETIME
                         @Ticket, -- Ticket - VARCHAR
                         @Mensaje_Respuesta, -- Mensaje_Respuesta - VARCHAR
                         @Cod_Estado, -- Cod_Estado - VARCHAR
                         @Cod_Usuario, -- Cod_Usuario - VARCHAR
                         @Cod_UsuarioReg, -- Cod_UsuarioReg - VARCHAR
                         GETDATE(), -- Fecha_Reg - DATETIME
                         NULL, -- Cod_UsuarioAct - VARCHAR
                         NULL -- Fecha_Act - DATETIME
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE dbo.CAJ_COMUNICACION_BAJA
                          SET 
                              dbo.CAJ_COMUNICACION_BAJA.Fecha_Emision = @Fecha_Emision, -- DATETIME
                              dbo.CAJ_COMUNICACION_BAJA.Numero_Comunicado = @Numero_Comunicado, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Justificacion = @Justificacion, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Fecha_Comunicacion = @Fecha_Comunicacion, -- DATETIME
                              dbo.CAJ_COMUNICACION_BAJA.Ticket = @Ticket, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Mensaje_Respuesta = @Mensaje_Respuesta, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Cod_Estado = @Cod_Estado, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Cod_Usuario = @Cod_Usuario, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Cod_UsuarioAct = @Cod_UsuarioReg, -- VARCHAR
                              dbo.CAJ_COMUNICACION_BAJA.Fecha_Act = GETDATE() -- DATETIME
                        WHERE dbo.CAJ_COMUNICACION_BAJA.Cod_TipoComprobante = @Cod_TipoComprobante
                              AND dbo.CAJ_COMUNICACION_BAJA.Serie = @Serie
                              AND dbo.CAJ_COMUNICACION_BAJA.Numero = @Numero;
                END;
        END;
            ELSE
            BEGIN
                RAISERROR('El comprobante a dar de baja, no existe en la base de datos.', -- Message text.
                16, -- Severity.
                1 -- State.
                );
        END;
    END;
GO

--Eliminar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMUNICACION_BAJA_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMUNICACION_BAJA_E;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_E @Cod_TipoComprobante VARCHAR(8), 
                                             @Serie               VARCHAR(5), 
                                             @Numero              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT ccp.*
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_Libro = '14'
                  AND ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND ccp.Serie = @Serie
                  AND ccp.Numero = @Numero
        )
            BEGIN
                IF EXISTS
                (
                    SELECT ccb.*
                    FROM dbo.CAJ_COMUNICACION_BAJA ccb
                    WHERE ccb.Cod_TipoComprobante = @Cod_TipoComprobante
                          AND ccb.Serie = @Serie
                          AND ccb.Numero = @Numero
                )
                    BEGIN
                        DELETE dbo.CAJ_COMUNICACION_BAJA
                        WHERE dbo.CAJ_COMUNICACION_BAJA.Cod_TipoComprobante = @Cod_TipoComprobante
                              AND dbo.CAJ_COMUNICACION_BAJA.Serie = @Serie
                              AND dbo.CAJ_COMUNICACION_BAJA.Numero = @Numero;
                END;
                    ELSE
                    BEGIN
                        RAISERROR('El comprobante a eliminar de la tabla de comunicados de baja , no existe en la tabla de comunicados de baja.', -- Message text.
                        16, -- Severity.
                        1 -- State.
                        );
                END;
        END;
            ELSE
            BEGIN
                RAISERROR('El comprobante a eliminar de la tabla de comunicados de baja, no existe en la base de datos.', -- Message text.
                16, -- Severity.
                1 -- State.
                );
        END;
    END;
GO

--Traer datos de la comunicacion de baja
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMUNICACION_BAJA_TraerX_CodTipo_Serie_Numero'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMUNICACION_BAJA_TraerX_CodTipo_Serie_Numero;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_TraerX_CodTipo_Serie_Numero @Cod_TipoComprobante VARCHAR(8), 
                                                                       @Serie               VARCHAR(5), 
                                                                       @Numero              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT ccb.*
        FROM dbo.CAJ_COMUNICACION_BAJA ccb
        WHERE ccb.Cod_TipoComprobante = @Cod_TipoComprobante
              AND ccb.Serie = @Serie
              AND ccb.Numero = @Numero;
    END;
GO

--Tarer todo
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMUNICACION_BAJA_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMUNICACION_BAJA_TT;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT ccb.*
        FROM dbo.CAJ_COMUNICACION_BAJA ccb;
    END;
GO

--Importar la vista resumen a la tabla resumen
SET DATEFORMAT dmy
INSERT dbo.CAJ_RESUMEN_DIARIO
(
    Fecha_Serie,
    Numero,
    Ticket,
    Nom_Estado,
    Fecha_Envio,
    Total_Resumen,
    Cod_UsuarioReg,
    Fecha_Reg,
    Cod_UsuarioAct,
    Fecha_Act
)
SELECT vrd.Fecha_Serie, vrd.Numero, vrd.Ticket, vrd.Nom_Estado, CASE WHEN vrd.Fecha_Envio='1' THEN NULL ELSE CONVERT(datetime, SUBSTRING(vrd.Fecha_Envio,0,11)) END, vrd.Total_Resumen,'PRUEBA',GETDATE(),null,null FROM dbo.VIS_RESUMEN_DIARIO vrd
LEFT JOIN dbo.CAJ_RESUMEN_DIARIO crd ON vrd.Fecha_Serie = crd.Fecha_Serie AND vrd.Numero = crd.Numero
WHERE crd.Fecha_Serie IS NULL AND crd.Numero IS NULL
GO