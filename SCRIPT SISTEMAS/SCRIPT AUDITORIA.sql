IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_AUDITORIA_ObtenerTablas'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_AUDITORIA_ObtenerTablas;
GO
CREATE PROCEDURE USP_PRI_AUDITORIA_ObtenerTablas
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            t.*
     FROM INFORMATION_SCHEMA.TABLES t
     WHERE t.TABLE_TYPE = 'BASE TABLE';
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_AUDITORIA_ObtenerColumnasXNomTabla'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_AUDITORIA_ObtenerColumnasXNomTabla;
GO
CREATE PROCEDURE USP_PRI_AUDITORIA_ObtenerColumnasXNomTabla
@Nom_Tabla varchar(max)
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            c.*
     FROM INFORMATION_SCHEMA.COLUMNS c
     WHERE TABLE_NAME = @Nom_Tabla;
GO

--Temporal


IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_AUDITORIA_TraerXNomBDNomTablaAccionFechaInicioFechaFin'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_AUDITORIA_TraerXNomBDNomTablaAccionFechaInicioFechaFin;
GO
CREATE PROCEDURE USP_PRI_AUDITORIA_TraerXNomBDNomTablaAccionFechaInicioFechaFin @Nombre_BD     VARCHAR(MAX), 
                                                                                @Nombre_Tabla  VARCHAR(MAX), 
                                                                                @Accion        VARCHAR(32)  = 'TODO', 
                                                                                @Fecha_Inicio  DATETIME     = NULL, 
                                                                                @Fecha_Final   DATETIME     = NULL, 
                                                                                @Pagina        INT, 
                                                                                @Total_XPagina INT          = 1000
WITH ENCRYPTION
AS
    BEGIN
        SELECT pa.Id, 
               pa.Id_Fila, 
               pa.Accion, 
               pa.Valor, 
               pa.Fecha_Reg
        FROM dbo.PRI_AUDITORIA pa
        WHERE pa.Nombre_BD = @Nombre_BD
              AND pa.Nombre_Tabla = @Nombre_Tabla
              AND (pa.Accion = @Accion
                   OR @Accion = 'TODO')
              AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), pa.Fecha_Reg, 103)) BETWEEN CONVERT(DATETIME, @Fecha_Inicio) AND CONVERT(DATETIME, @Fecha_Final)
                   OR @Fecha_Inicio IS NULL)
        ORDER BY pa.Id
        OFFSET @Total_XPagina * (@Pagina - 1) ROWS FETCH NEXT @Total_XPagina ROWS ONLY;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_AUDITORIA_TNFXNomBDNomTablaAccionFechaInicioFechaFin'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_AUDITORIA_TNFXNomBDNomTablaAccionFechaInicioFechaFin;
GO
CREATE PROCEDURE USP_PRI_AUDITORIA_TNFXNomBDNomTablaAccionFechaInicioFechaFin @Nombre_BD    VARCHAR(MAX), 
                                                                              @Nombre_Tabla VARCHAR(MAX), 
                                                                              @Accion       VARCHAR(32)  = 'TODO', 
                                                                              @Fecha_Inicio DATETIME     = NULL, 
                                                                              @Fecha_Final  DATETIME     = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT COUNT(*) Nro_Filas
        FROM dbo.PRI_AUDITORIA pa
        WHERE pa.Nombre_BD = @Nombre_BD
              AND pa.Nombre_Tabla = @Nombre_Tabla
              AND (pa.Accion = @Accion
                   OR @Accion = 'TODO')
              AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), pa.Fecha_Reg, 103)) BETWEEN CONVERT(DATETIME, @Fecha_Inicio) AND CONVERT(DATETIME, @Fecha_Final)
                   OR @Fecha_Inicio IS NULL);
    END;
GO