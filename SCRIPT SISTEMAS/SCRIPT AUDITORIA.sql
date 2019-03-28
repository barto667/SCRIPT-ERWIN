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