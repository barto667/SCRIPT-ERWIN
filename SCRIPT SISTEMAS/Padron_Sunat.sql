CREATE INDEX IDX_PRI_CLIENTE_PROVEEDOR_Nro_Documento
ON dbo.PRI_CLIENTE_PROVEEDOR (Nro_Documento);


EXEC USP_PAR_FILA_G '006','001',9,'009',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','002',9,'ANULACION PROVICIONAL ACTOS ILICITOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','003',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '006','001',10,'010',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','002',10,'ANULACION ERROR SU.',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','003',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '006','001',11,'011',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','002',11,'INHABILITADO VENTA UN.',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','003',11,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '006','001',12,'012',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','002',12,'NUM. INTERNO IDENTIF.',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','003',12,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '006','001',13,'999',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','002',13,'INDETERMINADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '006','003',13,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',5,'05',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',5,'NO APLICABLE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',6,'06',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',6,'NO HALLADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',7,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',7,'NO HALLADO CERRADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',8,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',8,'NO HALLADO DESTINATA.',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',9,'09',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',9,'NO HALLADO FALLECIO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',10,'10',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',10,'NO HALLADO NRO. PUERTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',11,'11',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',11,'NO HALLADO OTROS MOTIVOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',11,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',12,'12',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',12,'NO HALLADO RECHAZADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',12,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',13,'13',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',13,'NO HALLADO SE MUDO D.',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',13,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',14,'14',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',14,'PENDIENTE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',14,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_FILA_G '038','001',15,'15',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','002',15,'POR VERIFICAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '038','003',15,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_PROVEEDOR_InsertarDePadronSUNAT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_InsertarDePadronSUNAT;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_InsertarDePadronSUNAT @RUC           VARCHAR(11), 
                                                                 @Nombre        VARCHAR(5120), 
                                                                 @Cod_Estado    VARCHAR(1024), 
                                                                 @Cod_Condicion VARCHAR(1024), 
                                                                 @Ubigeo        VARCHAR(12), 
                                                                 @Direccion     VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        SET @Direccion = RTRIM(CONCAT(@Direccion, ' ', ISNULL(
        (
            SELECT vd2.Nom_Departamento + ' - ' + vp.Nom_Provincia + ' - ' + vd.Nom_Distrito
            FROM dbo.VIS_DISTRITOS vd
                 INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                     AND vd.Cod_Provincia = vp.Cod_Provincia
                 INNER JOIN dbo.VIS_DEPARTAMENTOS vd2 ON vd.Cod_Departamento = vd2.Cod_Departamento
            WHERE vd.Cod_Ubigeo = @Ubigeo
        ), '')));
        IF NOT EXISTS
        (
            SELECT pcp.Id_ClienteProveedor
            FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
            WHERE pcp.Nro_Documento = @RUC
                  AND pcp.Cod_TipoDocumento = '6'
        )
            BEGIN
                --Se inserta
                INSERT INTO dbo.PRI_CLIENTE_PROVEEDOR
                VALUES
                (
                -- Id_ClienteProveedor - int
                '6', -- Cod_TipoDocumento - varchar
                @RUC, -- Nro_Documento - varchar
                @Nombre, -- Cliente - varchar
                NULL, -- Ap_Paterno - varchar
                NULL, -- Ap_Materno - varchar
                NULL, -- Nombres - varchar
                @Direccion, -- Direccion - varchar
                @Cod_Estado, -- Cod_EstadoCliente - varchar
                @Cod_Condicion, -- Cod_CondicionCliente - varchar
                '002', -- Cod_TipoCliente - varchar
                NULL, -- RUC_Natural - varchar
                NULL, -- Foto - binary
                NULL, -- Firma - binary
                'FE', -- Cod_TipoComprobante - varchar
                '156', -- Cod_Nacionalidad - varchar
                NULL, -- Fecha_Nacimiento - datetime
                '01', -- Cod_Sexo - varchar
                NULL, -- Email1 - varchar
                NULL, -- Email2 - varchar
                NULL, -- Telefono1 - varchar
                NULL, -- Telefono2 - varchar
                NULL, -- Fax - varchar
                NULL, -- PaginaWeb - varchar
                @Ubigeo, -- Cod_Ubigeo - varchar
                '008', -- Cod_FormaPago - varchar
                0, -- Limite_Credito - numeric
                NULL, -- Obs_Cliente - xml
                0, -- Num_DiaCredito - int
                'PADRON', -- Cod_UsuarioReg - varchar
                GETDATE(), -- Fecha_Reg - datetime
                NULL, -- Cod_UsuarioAct - varchar
                NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                --Se actualiza
                UPDATE dbo.PRI_CLIENTE_PROVEEDOR
                  SET
                --Id_ClienteProveedor - column value is auto-generated
                      dbo.PRI_CLIENTE_PROVEEDOR.Cliente = @Nombre, -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Direccion = @Direccion, -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Cod_EstadoCliente = @Cod_Estado, -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Cod_CondicionCliente = @Cod_Condicion, -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Cod_Ubigeo = @Ubigeo, -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Cod_UsuarioAct = 'PADRON', -- varchar
                      dbo.PRI_CLIENTE_PROVEEDOR.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.PRI_CLIENTE_PROVEEDOR.Nro_Documento = @RUC
                      AND dbo.PRI_CLIENTE_PROVEEDOR.Cod_TipoDocumento = '6';
        END;
    END;
GO




--GENERACION SEMI-AUTOMATICA
--Verifcar las rutas de almacenamiento

--Creamos la base de datos
USE master;
GO
IF NOT EXISTS
(
    SELECT name
    FROM sys.databases
    WHERE name = N'PALERPsunat'
)
    BEGIN
        CREATE DATABASE PALERPsunat CONTAINMENT = NONE ON PRIMARY
        (
                                                                  NAME = N'PALERPsunat', 
                                                                  FILENAME = N'F:\BASE DE DATOS\PALERPsunat.mdf', 
                                                                  SIZE = 8192 KB, 
                                                                  FILEGROWTH = 65536 KB
        ) LOG ON
        (
                                                                  NAME = N'PALERPsunat_log', 
                                                                  FILENAME = N'F:\BASE DE DATOS\PALERPsunat_log.ldf', 
                                                                  SIZE = 8192 KB, 
                                                                  FILEGROWTH = 0
        ) COLLATE Modern_Spanish_CI_AS;
END;
GO
IF NOT EXISTS
(
    SELECT name
    FROM sys.databases
    WHERE name = N'PALERPtemp_sunat'
)
    BEGIN
        CREATE DATABASE PALERPtemp_sunat CONTAINMENT = NONE ON PRIMARY
        (
                                                                       NAME = N'PALERPtemp_sunat', 
                                                                       FILENAME = N'F:\BASE DE DATOS\PALERPtemp_sunat.mdf', 
                                                                       SIZE = 8192 KB, 
                                                                       FILEGROWTH = 65536 KB
        ) LOG ON
        (
                                                                       NAME = N'PALERPtemp_sunat_log', 
                                                                       FILENAME = N'F:\BASE DE DATOS\PALERPtemp_sunat.ldf', 
                                                                       SIZE = 8192 KB, 
                                                                       FILEGROWTH = 0
        ) COLLATE Modern_Spanish_CI_AS;
END;
GO
USE PALERPtemp_sunat;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'padron_reducido_ruc'
          AND type = 'U'
)
    BEGIN
        DROP TABLE padron_reducido_ruc;
END;
GO
--Creamos la tabla
USE PALERPsunat;
GO
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'PRI_CLIENTE_PROVEEDOR'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE PRI_CLIENTE_PROVEEDOR
        (Cod_TipoDocumento    VARCHAR(3) NULL, 
         Nro_Documento        VARCHAR(32)
         PRIMARY KEY, 
         Cliente              VARCHAR(512) NULL, 
         Ap_Paterno           VARCHAR(128) NULL, 
         Ap_Materno           VARCHAR(128) NULL, 
         Nombres              VARCHAR(128) NULL, 
         Direccion            VARCHAR(512) NULL, 
         Cod_EstadoCliente    VARCHAR(3) NULL, 
         Cod_CondicionCliente VARCHAR(3) NULL, 
         Cod_TipoCliente      VARCHAR(3) NULL, 
         RUC_Natural          VARCHAR(32) NULL, 
         Foto                 BINARY NULL, 
         Firma                BINARY NULL, 
         Cod_TipoComprobante  VARCHAR(5) NULL, 
         Cod_Nacionalidad     VARCHAR(8) NULL, 
         Fecha_Nacimiento     DATETIME NULL, 
         Cod_Sexo             VARCHAR(3) NULL, 
         Email1               VARCHAR(1024) NULL, 
         Email2               VARCHAR(1024) NULL, 
         Telefono1            VARCHAR(512) NULL, 
         Telefono2            VARCHAR(512) NULL, 
         Fax                  VARCHAR(512) NULL, 
         PaginaWeb            VARCHAR(512) NULL, 
         Cod_Ubigeo           VARCHAR(8) NULL, 
         Cod_FormaPago        VARCHAR(3) NULL, 
         Limite_Credito       NUMERIC(38, 2) NULL, 
         Obs_Cliente          XML NULL, 
         Num_DiaCredito       INT NULL, 
         Ubicacion_EjeX       NUMERIC(38, 6), 
         Ubicacion_EjeY       NUMERIC(38, 6), 
         Ruta                 VARCHAR(2048), 
         Cod_UsuarioReg       VARCHAR(32) NOT NULL, 
         Fecha_Reg            DATETIME NOT NULL, 
         Cod_UsuarioAct       VARCHAR(32) NULL, 
         Fecha_Act            DATETIME NULL,
        );
END;
GO

USE PALERPsunat;
GO

IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'PRI_CLIENTE_PROVEEDOR'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE PRI_CLIENTE_PROVEEDOR
        (Nro_Documento        VARCHAR(32), 
         Cod_TipoDocumento    VARCHAR(3) NOT NULL, 
         Cliente              VARCHAR(2048) NULL, 
         Ap_Paterno           VARCHAR(128) NULL, 
         Ap_Materno           VARCHAR(128) NULL, 
         Nombres              VARCHAR(128) NULL, 
         Direccion            VARCHAR(2048) NULL, 
         Cod_EstadoCliente    VARCHAR(3) NULL, 
         Cod_CondicionCliente VARCHAR(3) NULL, 
         Cod_TipoCliente      VARCHAR(3) NULL, 
         RUC_Natural          VARCHAR(32) NULL, 
         Foto                 BINARY NULL, 
         Firma                BINARY NULL, 
         Cod_TipoComprobante  VARCHAR(5) NULL, 
         Cod_Nacionalidad     VARCHAR(8) NULL, 
         Fecha_Nacimiento     DATETIME NULL, 
         Cod_Sexo             VARCHAR(3) NULL, 
         Email1               VARCHAR(1024) NULL, 
         Email2               VARCHAR(1024) NULL, 
         Telefono1            VARCHAR(512) NULL, 
         Telefono2            VARCHAR(512) NULL, 
         Fax                  VARCHAR(512) NULL, 
         PaginaWeb            VARCHAR(512) NULL, 
         Cod_Ubigeo           VARCHAR(8) NULL, 
         Cod_FormaPago        VARCHAR(3) NULL, 
         Limite_Credito       NUMERIC(38, 2) NULL, 
         Obs_Cliente          XML NULL, 
         Num_DiaCredito       INT NULL, 
         Ubicacion_EjeX       NUMERIC(38, 6), 
         Ubicacion_EjeY       NUMERIC(38, 6), 
         Ruta                 VARCHAR(2048), 
         Cod_UsuarioReg       VARCHAR(32) NOT NULL, 
         Fecha_Reg            DATETIME NOT NULL, 
         Cod_UsuarioAct       VARCHAR(32) NULL, 
         Fecha_Act            DATETIME NULL, 
         PRIMARY KEY(Nro_Documento, Cod_TipoDocumento)
        );
END;
GO

--EXEC USP_Crear_CopiaSeguridadCompleta PALERPsunat, N'C:\APLICACIONES\VOLCADO\BAK','bak';
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Crear_CopiaSeguridadCompleta'
          AND type = 'P'
)
    DROP PROCEDURE USP_Crear_CopiaSeguridadCompleta;
GO
CREATE PROCEDURE USP_Crear_CopiaSeguridadCompleta @BDActual   VARCHAR(MAX), 
                                                  @RutaBackup VARCHAR(MAX), 
                                                  @Extension  VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @NombreArchivo AS VARCHAR(MAX)= CONCAT(@RutaBackup, CHAR(92), @BDActual, @Extension);
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa: Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
    END;
GO
--EXEC USP_Crear_CopiaSeguridadDiferencial PALERPsunat, N'C:\APLICACIONES\VOLCADO\BAK','bak';
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Crear_CopiaSeguridadDiferencial'
          AND type = 'P'
)
    DROP PROCEDURE USP_Crear_CopiaSeguridadDiferencial;
GO
CREATE PROCEDURE USP_Crear_CopiaSeguridadDiferencial @BDActual   VARCHAR(MAX), 
                                                     @RutaBackup VARCHAR(MAX), 
                                                     @Extension  VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @NombreArchivo AS VARCHAR(MAX)= CONCAT(@RutaBackup, CHAR(92), @BDActual, @Extension);
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Diferencial: Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION, DIFFERENTIAL;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_PROVEEDOR_volcardatos'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_volcardatos;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_volcardatos
WITH ENCRYPTION
AS
    BEGIN
        --Insercion
        DECLARE @Fecha DATETIME= GETDATE();
        INSERT INTO dbo.PRI_CLIENTE_PROVEEDOR
        (Nro_Documento, 
         Cod_TipoDocumento, 
         Cliente, 
         Ap_Paterno, 
         Ap_Materno, 
         Nombres, 
         Direccion, 
         Cod_EstadoCliente, 
         Cod_CondicionCliente, 
         Cod_TipoCliente, 
         RUC_Natural, 
         Foto, 
         Firma, 
         Cod_TipoComprobante, 
         Cod_Nacionalidad, 
         Fecha_Nacimiento, 
         Cod_Sexo, 
         Email1, 
         Email2, 
         Telefono1, 
         Telefono2, 
         Fax, 
         PaginaWeb, 
         Cod_Ubigeo, 
         Cod_FormaPago, 
         Limite_Credito, 
         Obs_Cliente, 
         Num_DiaCredito, 
         Ubicacion_EjeX, 
         Ubicacion_EjeY, 
         Ruta, 
         Cod_UsuarioReg, 
         Fecha_Reg, 
         Cod_UsuarioAct, 
         Fecha_Act
        )
               SELECT UPPER(LTRIM(RTRIM(prr.RUC))) Nro_Documento, -- Nro_Documento - varchar
                      '6' Cod_TipoDocumento, -- Cod_TipoDocumento - varchar
                      UPPER(LTRIM(RTRIM(prr.[NOMBRE O RAZÓN SOCIAL]))) Cliente, -- Cliente - varchar
                      '' Ap_Paterno, -- Ap_Paterno - varchar
                      '' Ap_Materno, -- Ap_Materno - varchar
                      '' Nombres, -- Nombres - varchar
                      UPPER(LTRIM(RTRIM(CONCAT(CASE
                                                   WHEN prr.[TIPO DE VÍA] IS NULL
                                                        OR prr.[TIPO DE VÍA] = ''
                                                        OR prr.[TIPO DE VÍA] = '-'
                                                        OR prr.[TIPO DE VÍA] = '--'
                                                        OR prr.[TIPO DE VÍA] = '---'
                                                        OR prr.[TIPO DE VÍA] = '----'
                                                        OR prr.[TIPO DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[TIPO DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[NOMBRE DE VÍA] IS NULL
                                                        OR prr.[NOMBRE DE VÍA] = ''
                                                        OR prr.[NOMBRE DE VÍA] = '-'
                                                        OR prr.[NOMBRE DE VÍA] = '--'
                                                        OR prr.[NOMBRE DE VÍA] = '---'
                                                        OR prr.[NOMBRE DE VÍA] = '----'
                                                        OR prr.[NOMBRE DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[NOMBRE DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[CÓDIGO DE ZONA] IS NULL
                                                        OR prr.[CÓDIGO DE ZONA] = ''
                                                        OR prr.[CÓDIGO DE ZONA] = '-'
                                                        OR prr.[CÓDIGO DE ZONA] = '--'
                                                        OR prr.[CÓDIGO DE ZONA] = '---'
                                                        OR prr.[CÓDIGO DE ZONA] = '----'
                                                        OR prr.[CÓDIGO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[CÓDIGO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[TIPO DE ZONA] IS NULL
                                                        OR prr.[TIPO DE ZONA] = ''
                                                        OR prr.[TIPO DE ZONA] = '-'
                                                        OR prr.[TIPO DE ZONA] = '--'
                                                        OR prr.[TIPO DE ZONA] = '---'
                                                        OR prr.[TIPO DE ZONA] = '----'
                                                        OR prr.[TIPO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[TIPO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[NÚMERO] IS NULL
                                                        OR prr.[NÚMERO] = ''
                                                        OR prr.[NÚMERO] = '-'
                                                        OR prr.[NÚMERO] = '--'
                                                        OR prr.[NÚMERO] = '---'
                                                        OR prr.[NÚMERO] = '----'
                                                        OR prr.[NÚMERO] = '-----'
                                                   THEN ''
                                                   ELSE prr.[NÚMERO] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[INTERIOR] IS NULL
                                                        OR prr.[INTERIOR] = ''
                                                        OR prr.[INTERIOR] = '-'
                                                        OR prr.[INTERIOR] = '--'
                                                        OR prr.[INTERIOR] = '---'
                                                        OR prr.[INTERIOR] = '----'
                                                        OR prr.[INTERIOR] = '-----'
                                                   THEN ''
                                                   ELSE 'INTERIOR: ' + prr.[INTERIOR] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[LOTE] IS NULL
                                                        OR prr.[LOTE] = ''
                                                        OR prr.[LOTE] = '-'
                                                        OR prr.[LOTE] = '--'
                                                        OR prr.[LOTE] = '---'
                                                        OR prr.[LOTE] = '----'
                                                        OR prr.[LOTE] = '-----'
                                                   THEN ''
                                                   ELSE 'LOTE: ' + prr.[LOTE] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[DEPARTAMENTO] IS NULL
                                                        OR prr.[DEPARTAMENTO] = ''
                                                        OR prr.[DEPARTAMENTO] = '-'
                                                        OR prr.[DEPARTAMENTO] = '--'
                                                        OR prr.[DEPARTAMENTO] = '---'
                                                        OR prr.[DEPARTAMENTO] = '----'
                                                        OR prr.[DEPARTAMENTO] = '-----'
                                                   THEN ''
                                                   ELSE 'DEPARTAMENTO: ' + prr.[DEPARTAMENTO] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[MANZANA] IS NULL
                                                        OR prr.[MANZANA] = ''
                                                        OR prr.[MANZANA] = '-'
                                                        OR prr.[MANZANA] = '--'
                                                        OR prr.[MANZANA] = '---'
                                                        OR prr.[MANZANA] = '----'
                                                        OR prr.[MANZANA] = '-----'
                                                   THEN ''
                                                   ELSE 'MANZANA: ' + prr.[MANZANA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[KILÓMETRO] IS NULL
                                                        OR prr.[KILÓMETRO] = ''
                                                        OR prr.[KILÓMETRO] = '-'
                                                        OR prr.[KILÓMETRO] = '--'
                                                        OR prr.[KILÓMETRO] = '---'
                                                        OR prr.[KILÓMETRO] = '----'
                                                        OR prr.[KILÓMETRO] = '-----'
                                                   THEN ''
                                                   ELSE 'KILOMETRO: ' + prr.[KILÓMETRO] + ' '
                                               END)))) + CASE
                                                             WHEN pu.Cod_Ubigeo IS NULL
                                                             THEN ''
                                                             ELSE ' ' + pu.Departamento_Provincia_Distrito
                                                         END Direccion, -- Direccion - varchar,
                      CASE
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ACTIVO'
                          THEN '001'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANUL.PROVI.-ACTO ILI'
                          THEN '009'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANULACION - ERROR SU'
                          THEN '010'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DE OFICIO'
                          THEN '002'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DEFINITIVA'
                          THEN '003'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA MULT.INSCR. Y O'
                          THEN '004'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROV. POR OFICI'
                          THEN '005'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROVISIONAL'
                          THEN '006'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'INHABILITADO-VENT.UN'
                          THEN '011'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'NUM. INTERNO IDENTIF'
                          THEN '012'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'OTROS OBLIGADOS'
                          THEN '007'
                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'SUSPENSION TEMPORAL'
                          THEN '008'
                          ELSE '002'
                      END Cod_EstadoCliente, -- Cod_EstadoCliente - varchar
                      CASE
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'HABIDO'
                          THEN '01'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO APLICABLE'
                          THEN '05'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HABIDO'
                          THEN '02'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO'
                          THEN '06'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO CERRADO'
                          THEN '07'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO DESTINATA'
                          THEN '08'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO FALLECIO'
                          THEN '09'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NO EXISTE'
                          THEN '04'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NRO.PUERT'
                          THEN '10'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO OTROS MOT'
                          THEN '11'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO RECHAZADO'
                          THEN '12'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO SE MUDO D'
                          THEN '13'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'PENDIENTE'
                          THEN '14'
                          WHEN prr.[CONDICIÓN DE DOMICILIO] = 'POR VERIFICAR'
                          THEN '15'
                          ELSE '02'
                      END Cod_CondicionCliente, -- Cod_CondicionCliente - varchar
                      '002' Cod_TipoCliente, -- Cod_TipoCliente - varchar
                      '' RUC_Natural, -- RUC_Natural - varchar
                      NULL Foto, -- Foto - binary
                      NULL Firma, -- Firma - binary
                      'FE' Cod_TipoComprobante, -- Cod_TipoComprobante - varchar
                      '156' Cod_Nacionalidad, -- Cod_Nacionalidad - varchar
                      GETDATE() Fecha_Nacimiento, -- Fecha_Nacimiento - datetime
                      '01' Cod_Sexo, -- Cod_Sexo - varchar
                      '' Email1, -- Email1 - varchar
                      '' Email2, -- Email2 - varchar
                      '' Telefono1, -- Telefono1 - varchar
                      '' Telefono2, -- Telefono2 - varchar
                      '' Fax, -- Fax - varchar
                      '' PaginaWeb, -- PaginaWeb - varchar
                      CASE
                          WHEN LTRIM(RTRIM(prr.UBIGEO)) = '-'
                          THEN ''
                          ELSE LTRIM(RTRIM(prr.UBIGEO))
                      END Cod_Ubigeo, -- Cod_Ubigeo - varchar
                      '008' Cod_FormaPago, -- Cod_FormaPago - varchar
                      0 Limite_Credito, -- Limite_Credito - numeric
                      NULL Obs_Cliente, -- Obs_Cliente - xml
                      0 Num_DiaCredito, -- Num_DiaCredito - int
                      0 Ubicacion_EjeX, -- Ubicacion_EjeX - numeric
                      0 Ubicacion_EjeY, -- Ubicacion_EjeY - numeric
                      '' Ruta, -- Ruta - varchar
                      'MIGRACION' Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                      @Fecha Fecha_Reg, -- Fecha_Reg - datetime
                      NULL Cod_UsuarioAct, -- Cod_UsuarioAct - varchar
                      NULL Fecha_Act -- Fecha_Act - datetime
               FROM PALERPtemp_sunat.dbo.padron_reducido_ruc prr
                    LEFT JOIN dbo.PRI_UBIGEOS pu ON CASE
                                                        WHEN LTRIM(RTRIM(prr.UBIGEO)) = '-'
                                                        THEN ''
                                                        ELSE LTRIM(RTRIM(prr.UBIGEO))
                                                    END = pu.Cod_Ubigeo
               WHERE UPPER(LTRIM(RTRIM(prr.RUC))) IN
               (
                   SELECT UPPER(LTRIM(RTRIM(prr.RUC))) Nro_Documento -- Nro_Documento - varchar
                   FROM PALERPtemp_sunat.dbo.padron_reducido_ruc prr
                   EXCEPT
                   SELECT pcp.Nro_Documento
                   FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
                   WHERE pcp.Cod_TipoDocumento = '6'
               );
        --Actualizacion
        UPDATE pcp
          SET 
              pcp.Cliente = UPPER(LTRIM(RTRIM(prr.[NOMBRE O RAZÓN SOCIAL]))), 
              pcp.Direccion = UPPER(LTRIM(RTRIM(CONCAT(CASE
                                                           WHEN prr.[TIPO DE VÍA] IS NULL
                                                                OR prr.[TIPO DE VÍA] = ''
                                                                OR prr.[TIPO DE VÍA] = '-'
                                                                OR prr.[TIPO DE VÍA] = '--'
                                                                OR prr.[TIPO DE VÍA] = '---'
                                                                OR prr.[TIPO DE VÍA] = '----'
                                                                OR prr.[TIPO DE VÍA] = '-----'
                                                           THEN ''
                                                           ELSE prr.[TIPO DE VÍA] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[NOMBRE DE VÍA] IS NULL
                                                                OR prr.[NOMBRE DE VÍA] = ''
                                                                OR prr.[NOMBRE DE VÍA] = '-'
                                                                OR prr.[NOMBRE DE VÍA] = '--'
                                                                OR prr.[NOMBRE DE VÍA] = '---'
                                                                OR prr.[NOMBRE DE VÍA] = '----'
                                                                OR prr.[NOMBRE DE VÍA] = '-----'
                                                           THEN ''
                                                           ELSE prr.[NOMBRE DE VÍA] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[CÓDIGO DE ZONA] IS NULL
                                                                OR prr.[CÓDIGO DE ZONA] = ''
                                                                OR prr.[CÓDIGO DE ZONA] = '-'
                                                                OR prr.[CÓDIGO DE ZONA] = '--'
                                                                OR prr.[CÓDIGO DE ZONA] = '---'
                                                                OR prr.[CÓDIGO DE ZONA] = '----'
                                                                OR prr.[CÓDIGO DE ZONA] = '-----'
                                                           THEN ''
                                                           ELSE prr.[CÓDIGO DE ZONA] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[TIPO DE ZONA] IS NULL
                                                                OR prr.[TIPO DE ZONA] = ''
                                                                OR prr.[TIPO DE ZONA] = '-'
                                                                OR prr.[TIPO DE ZONA] = '--'
                                                                OR prr.[TIPO DE ZONA] = '---'
                                                                OR prr.[TIPO DE ZONA] = '----'
                                                                OR prr.[TIPO DE ZONA] = '-----'
                                                           THEN ''
                                                           ELSE prr.[TIPO DE ZONA] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[NÚMERO] IS NULL
                                                                OR prr.[NÚMERO] = ''
                                                                OR prr.[NÚMERO] = '-'
                                                                OR prr.[NÚMERO] = '--'
                                                                OR prr.[NÚMERO] = '---'
                                                                OR prr.[NÚMERO] = '----'
                                                                OR prr.[NÚMERO] = '-----'
                                                           THEN ''
                                                           ELSE prr.[NÚMERO] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[INTERIOR] IS NULL
                                                                OR prr.[INTERIOR] = ''
                                                                OR prr.[INTERIOR] = '-'
                                                                OR prr.[INTERIOR] = '--'
                                                                OR prr.[INTERIOR] = '---'
                                                                OR prr.[INTERIOR] = '----'
                                                                OR prr.[INTERIOR] = '-----'
                                                           THEN ''
                                                           ELSE 'INTERIOR: ' + prr.[INTERIOR] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[LOTE] IS NULL
                                                                OR prr.[LOTE] = ''
                                                                OR prr.[LOTE] = '-'
                                                                OR prr.[LOTE] = '--'
                                                                OR prr.[LOTE] = '---'
                                                                OR prr.[LOTE] = '----'
                                                                OR prr.[LOTE] = '-----'
                                                           THEN ''
                                                           ELSE 'LOTE: ' + prr.[LOTE] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[DEPARTAMENTO] IS NULL
                                                                OR prr.[DEPARTAMENTO] = ''
                                                                OR prr.[DEPARTAMENTO] = '-'
                                                                OR prr.[DEPARTAMENTO] = '--'
                                                                OR prr.[DEPARTAMENTO] = '---'
                                                                OR prr.[DEPARTAMENTO] = '----'
                                                                OR prr.[DEPARTAMENTO] = '-----'
                                                           THEN ''
                                                           ELSE 'DEPARTAMENTO: ' + prr.[DEPARTAMENTO] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[MANZANA] IS NULL
                                                                OR prr.[MANZANA] = ''
                                                                OR prr.[MANZANA] = '-'
                                                                OR prr.[MANZANA] = '--'
                                                                OR prr.[MANZANA] = '---'
                                                                OR prr.[MANZANA] = '----'
                                                                OR prr.[MANZANA] = '-----'
                                                           THEN ''
                                                           ELSE 'MANZANA: ' + prr.[MANZANA] + ' '
                                                       END,
                                                       CASE
                                                           WHEN prr.[KILÓMETRO] IS NULL
                                                                OR prr.[KILÓMETRO] = ''
                                                                OR prr.[KILÓMETRO] = '-'
                                                                OR prr.[KILÓMETRO] = '--'
                                                                OR prr.[KILÓMETRO] = '---'
                                                                OR prr.[KILÓMETRO] = '----'
                                                                OR prr.[KILÓMETRO] = '-----'
                                                           THEN ''
                                                           ELSE 'KILOMETRO: ' + prr.[KILÓMETRO] + ' '
                                                       END)))) + CASE
                                                                     WHEN pu.Cod_Ubigeo IS NULL
                                                                     THEN ''
                                                                     ELSE ' ' + pu.Departamento_Provincia_Distrito
                                                                 END, 
              pcp.Cod_EstadoCliente = CASE
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ACTIVO'
                                          THEN '001'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANUL.PROVI.-ACTO ILI'
                                          THEN '009'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANULACION - ERROR SU'
                                          THEN '010'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DE OFICIO'
                                          THEN '002'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DEFINITIVA'
                                          THEN '003'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA MULT.INSCR. Y O'
                                          THEN '004'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROV. POR OFICI'
                                          THEN '005'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROVISIONAL'
                                          THEN '006'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'INHABILITADO-VENT.UN'
                                          THEN '011'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'NUM. INTERNO IDENTIF'
                                          THEN '012'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'OTROS OBLIGADOS'
                                          THEN '007'
                                          WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'SUSPENSION TEMPORAL'
                                          THEN '008'
                                          ELSE '002'
                                      END, 
              pcp.Cod_CondicionCliente = CASE
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'HABIDO'
                                             THEN '01'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO APLICABLE'
                                             THEN '05'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HABIDO'
                                             THEN '02'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO'
                                             THEN '06'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO CERRADO'
                                             THEN '07'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO DESTINATA'
                                             THEN '08'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO FALLECIO'
                                             THEN '09'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NO EXISTE'
                                             THEN '04'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NRO.PUERT'
                                             THEN '10'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO OTROS MOT'
                                             THEN '11'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO RECHAZADO'
                                             THEN '12'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO SE MUDO D'
                                             THEN '13'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'PENDIENTE'
                                             THEN '14'
                                             WHEN prr.[CONDICIÓN DE DOMICILIO] = 'POR VERIFICAR'
                                             THEN '15'
                                             ELSE '02'
                                         END, 
              pcp.Cod_Ubigeo = CASE
                                   WHEN LTRIM(RTRIM(prr.UBIGEO)) = '-'
                                   THEN ''
                                   ELSE LTRIM(RTRIM(prr.UBIGEO))
                               END, 
              pcp.Cod_UsuarioAct = 'MIGRACION', 
              pcp.Fecha_Act = @Fecha
        FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
             INNER JOIN PALERPtemp_sunat.dbo.padron_reducido_ruc prr ON pcp.Nro_Documento = UPPER(LTRIM(RTRIM(prr.RUC)))
             LEFT JOIN dbo.PRI_UBIGEOS pu ON CASE
                                                 WHEN LTRIM(RTRIM(prr.UBIGEO)) = '-'
                                                 THEN ''
                                                 ELSE LTRIM(RTRIM(prr.UBIGEO))
                                             END = pu.Cod_Ubigeo
        WHERE pcp.Cod_TipoDocumento = '6'
              AND (UPPER(LTRIM(RTRIM(prr.[NOMBRE O RAZÓN SOCIAL]))) != pcp.Cliente
                   OR UPPER(LTRIM(RTRIM(CONCAT(CASE
                                                   WHEN prr.[TIPO DE VÍA] IS NULL
                                                        OR prr.[TIPO DE VÍA] = ''
                                                        OR prr.[TIPO DE VÍA] = '-'
                                                        OR prr.[TIPO DE VÍA] = '--'
                                                        OR prr.[TIPO DE VÍA] = '---'
                                                        OR prr.[TIPO DE VÍA] = '----'
                                                        OR prr.[TIPO DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[TIPO DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[NOMBRE DE VÍA] IS NULL
                                                        OR prr.[NOMBRE DE VÍA] = ''
                                                        OR prr.[NOMBRE DE VÍA] = '-'
                                                        OR prr.[NOMBRE DE VÍA] = '--'
                                                        OR prr.[NOMBRE DE VÍA] = '---'
                                                        OR prr.[NOMBRE DE VÍA] = '----'
                                                        OR prr.[NOMBRE DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[NOMBRE DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[CÓDIGO DE ZONA] IS NULL
                                                        OR prr.[CÓDIGO DE ZONA] = ''
                                                        OR prr.[CÓDIGO DE ZONA] = '-'
                                                        OR prr.[CÓDIGO DE ZONA] = '--'
                                                        OR prr.[CÓDIGO DE ZONA] = '---'
                                                        OR prr.[CÓDIGO DE ZONA] = '----'
                                                        OR prr.[CÓDIGO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[CÓDIGO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[TIPO DE ZONA] IS NULL
                                                        OR prr.[TIPO DE ZONA] = ''
                                                        OR prr.[TIPO DE ZONA] = '-'
                                                        OR prr.[TIPO DE ZONA] = '--'
                                                        OR prr.[TIPO DE ZONA] = '---'
                                                        OR prr.[TIPO DE ZONA] = '----'
                                                        OR prr.[TIPO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prr.[TIPO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[NÚMERO] IS NULL
                                                        OR prr.[NÚMERO] = ''
                                                        OR prr.[NÚMERO] = '-'
                                                        OR prr.[NÚMERO] = '--'
                                                        OR prr.[NÚMERO] = '---'
                                                        OR prr.[NÚMERO] = '----'
                                                        OR prr.[NÚMERO] = '-----'
                                                   THEN ''
                                                   ELSE prr.[NÚMERO] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[INTERIOR] IS NULL
                                                        OR prr.[INTERIOR] = ''
                                                        OR prr.[INTERIOR] = '-'
                                                        OR prr.[INTERIOR] = '--'
                                                        OR prr.[INTERIOR] = '---'
                                                        OR prr.[INTERIOR] = '----'
                                                        OR prr.[INTERIOR] = '-----'
                                                   THEN ''
                                                   ELSE 'INTERIOR: ' + prr.[INTERIOR] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[LOTE] IS NULL
                                                        OR prr.[LOTE] = ''
                                                        OR prr.[LOTE] = '-'
                                                        OR prr.[LOTE] = '--'
                                                        OR prr.[LOTE] = '---'
                                                        OR prr.[LOTE] = '----'
                                                        OR prr.[LOTE] = '-----'
                                                   THEN ''
                                                   ELSE 'LOTE: ' + prr.[LOTE] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[DEPARTAMENTO] IS NULL
                                                        OR prr.[DEPARTAMENTO] = ''
                                                        OR prr.[DEPARTAMENTO] = '-'
                                                        OR prr.[DEPARTAMENTO] = '--'
                                                        OR prr.[DEPARTAMENTO] = '---'
                                                        OR prr.[DEPARTAMENTO] = '----'
                                                        OR prr.[DEPARTAMENTO] = '-----'
                                                   THEN ''
                                                   ELSE 'DEPARTAMENTO: ' + prr.[DEPARTAMENTO] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[MANZANA] IS NULL
                                                        OR prr.[MANZANA] = ''
                                                        OR prr.[MANZANA] = '-'
                                                        OR prr.[MANZANA] = '--'
                                                        OR prr.[MANZANA] = '---'
                                                        OR prr.[MANZANA] = '----'
                                                        OR prr.[MANZANA] = '-----'
                                                   THEN ''
                                                   ELSE 'MANZANA: ' + prr.[MANZANA] + ' '
                                               END,
                                               CASE
                                                   WHEN prr.[KILÓMETRO] IS NULL
                                                        OR prr.[KILÓMETRO] = ''
                                                        OR prr.[KILÓMETRO] = '-'
                                                        OR prr.[KILÓMETRO] = '--'
                                                        OR prr.[KILÓMETRO] = '---'
                                                        OR prr.[KILÓMETRO] = '----'
                                                        OR prr.[KILÓMETRO] = '-----'
                                                   THEN ''
                                                   ELSE 'KILOMETRO: ' + prr.[KILÓMETRO] + ' '
                                               END)))) + CASE
                                                             WHEN pu.Cod_Ubigeo IS NULL
                                                             THEN ''
                                                             ELSE ' ' + pu.Departamento_Provincia_Distrito
                                                         END != pcp.Direccion
                   OR pcp.Cod_EstadoCliente != CASE
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ACTIVO'
                                                   THEN '001'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANUL.PROVI.-ACTO ILI'
                                                   THEN '009'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'ANULACION - ERROR SU'
                                                   THEN '010'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DE OFICIO'
                                                   THEN '002'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA DEFINITIVA'
                                                   THEN '003'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA MULT.INSCR. Y O'
                                                   THEN '004'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROV. POR OFICI'
                                                   THEN '005'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'BAJA PROVISIONAL'
                                                   THEN '006'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'INHABILITADO-VENT.UN'
                                                   THEN '011'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'NUM. INTERNO IDENTIF'
                                                   THEN '012'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'OTROS OBLIGADOS'
                                                   THEN '007'
                                                   WHEN prr.[ESTADO DEL CONTRIBUYENTE] = 'SUSPENSION TEMPORAL'
                                                   THEN '008'
                                                   ELSE '002'
                                               END
                   OR pcp.Cod_CondicionCliente != CASE
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'HABIDO'
                                                      THEN '01'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO APLICABLE'
                                                      THEN '05'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HABIDO'
                                                      THEN '02'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO'
                                                      THEN '06'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO CERRADO'
                                                      THEN '07'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO DESTINATA'
                                                      THEN '08'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO FALLECIO'
                                                      THEN '09'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NO EXISTE'
                                                      THEN '04'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO NRO.PUERT'
                                                      THEN '10'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO OTROS MOT'
                                                      THEN '11'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO RECHAZADO'
                                                      THEN '12'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'NO HALLADO SE MUDO D'
                                                      THEN '13'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'PENDIENTE'
                                                      THEN '14'
                                                      WHEN prr.[CONDICIÓN DE DOMICILIO] = 'POR VERIFICAR'
                                                      THEN '15'
                                                      ELSE '02'
                                                  END
                   OR pcp.Cod_Ubigeo != CASE
                                            WHEN LTRIM(RTRIM(prr.UBIGEO)) = '-'
                                            THEN ''
                                            ELSE LTRIM(RTRIM(prr.UBIGEO))
                                        END);
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_ESTABLECIMIENTOS_volcardatos'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_volcardatos;
GO
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_volcardatos
WITH ENCRYPTION
AS
    BEGIN
        --Eliminamos los duplicados de los anexos
        --Creamos una tabla temporal
        IF EXISTS
        (
            SELECT *
            FROM sysobjects
            WHERE type = 'U'
                  AND name = '#Temporal'
        )
            BEGIN
                DROP TABLE #Temporal;
        END;
        SELECT DISTINCT 
               prla.[ RUC], 
               prla.UBIGEO, 
               prla.[TIPO DE VÍA], 
               prla.[NOMBRE DE VÍA], 
               prla.[CÓDIGO DE ZONA], 
               prla.[TIPO DE ZONA], 
               prla.NÚMERO, 
               prla.KILÓMETRO, 
               prla.INTERIOR, 
               prla.LOTE, 
               prla.DEPARTAMENTO, 
               prla.MANZANA
        INTO #Temporal
        FROM PALERPtemp_sunat.dbo.padron_reducido_local_anexo prla
        ORDER BY prla.[ RUC];
        --Borramos todo los datos de la tabla
        DELETE PALERPtemp_sunat.dbo.padron_reducido_local_anexo;
        --Insertamos los nuevos datos
        INSERT INTO PALERPtemp_sunat.dbo.padron_reducido_local_anexo
        ([ RUC], 
         UBIGEO, 
         [TIPO DE VÍA], 
         [NOMBRE DE VÍA], 
         [CÓDIGO DE ZONA], 
         [TIPO DE ZONA], 
         NÚMERO, 
         KILÓMETRO, 
         INTERIOR, 
         LOTE, 
         DEPARTAMENTO, 
         MANZANA, 
         [Columna 12]
        )
               SELECT t.[ RUC], 
                      t.UBIGEO, 
                      t.[TIPO DE VÍA], 
                      t.[NOMBRE DE VÍA], 
                      t.[CÓDIGO DE ZONA], 
                      t.[TIPO DE ZONA], 
                      t.NÚMERO, 
                      t.KILÓMETRO, 
                      t.INTERIOR, 
                      t.LOTE, 
                      t.DEPARTAMENTO, 
                      t.MANZANA, 
                      ''
               FROM #Temporal t;
        DROP TABLE #Temporal;
        INSERT INTO dbo.PRI_ESTABLECIMIENTOS
        (Nro_Documento, 
         Item, 
         Des_Establecimiento, 
         Cod_TipoEstablecimiento, 
         Direccion, 
         Telefono, 
         Obs_Establecimiento, 
         Cod_Ubigeo, 
         Cod_UsuarioReg, 
         Fecha_Reg, 
         Cod_UsuarioAct, 
         Fecha_Act
        )
               SELECT prla.[ RUC], -- Nro_Documento - varchar
                      ROW_NUMBER() OVER(
                      ORDER BY prla.[ RUC] ASC), -- Item - int
                      'DOMICILIO FISCAL', -- Des_Establecimiento - varchar
                      '02', -- Cod_TipoEstablecimiento - varchar
                      UPPER(RTRIM(LTRIM(CONCAT(CASE
                                                   WHEN prla.[TIPO DE VÍA] IS NULL
                                                        OR prla.[TIPO DE VÍA] = ''
                                                        OR prla.[TIPO DE VÍA] = '-'
                                                        OR prla.[TIPO DE VÍA] = '--'
                                                        OR prla.[TIPO DE VÍA] = '---'
                                                        OR prla.[TIPO DE VÍA] = '----'
                                                        OR prla.[TIPO DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prla.[TIPO DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prla.[NOMBRE DE VÍA] IS NULL
                                                        OR prla.[NOMBRE DE VÍA] = ''
                                                        OR prla.[NOMBRE DE VÍA] = '-'
                                                        OR prla.[NOMBRE DE VÍA] = '--'
                                                        OR prla.[NOMBRE DE VÍA] = '---'
                                                        OR prla.[NOMBRE DE VÍA] = '----'
                                                        OR prla.[NOMBRE DE VÍA] = '-----'
                                                   THEN ''
                                                   ELSE prla.[NOMBRE DE VÍA] + ' '
                                               END,
                                               CASE
                                                   WHEN prla.[CÓDIGO DE ZONA] IS NULL
                                                        OR prla.[CÓDIGO DE ZONA] = ''
                                                        OR prla.[CÓDIGO DE ZONA] = '-'
                                                        OR prla.[CÓDIGO DE ZONA] = '--'
                                                        OR prla.[CÓDIGO DE ZONA] = '---'
                                                        OR prla.[CÓDIGO DE ZONA] = '----'
                                                        OR prla.[CÓDIGO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prla.[CÓDIGO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prla.[TIPO DE ZONA] IS NULL
                                                        OR prla.[TIPO DE ZONA] = ''
                                                        OR prla.[TIPO DE ZONA] = '-'
                                                        OR prla.[TIPO DE ZONA] = '--'
                                                        OR prla.[TIPO DE ZONA] = '---'
                                                        OR prla.[TIPO DE ZONA] = '----'
                                                        OR prla.[TIPO DE ZONA] = '-----'
                                                   THEN ''
                                                   ELSE prla.[TIPO DE ZONA] + ' '
                                               END,
                                               CASE
                                                   WHEN prla.NÚMERO IS NULL
                                                        OR prla.NÚMERO = ''
                                                        OR prla.NÚMERO = '-'
                                                        OR prla.NÚMERO = '--'
                                                        OR prla.NÚMERO = '---'
                                                        OR prla.NÚMERO = '----'
                                                        OR prla.NÚMERO = '-----'
                                                   THEN ''
                                                   ELSE prla.NÚMERO + ' '
                                               END,
                                               CASE
                                                   WHEN prla.KILÓMETRO IS NULL
                                                        OR prla.KILÓMETRO = ''
                                                        OR prla.KILÓMETRO = '-'
                                                        OR prla.KILÓMETRO = '--'
                                                        OR prla.KILÓMETRO = '---'
                                                        OR prla.KILÓMETRO = '----'
                                                        OR prla.KILÓMETRO = '-----'
                                                   THEN ''
                                                   ELSE 'KILOMETRO: ' + prla.KILÓMETRO + ' '
                                               END,
                                               CASE
                                                   WHEN prla.INTERIOR IS NULL
                                                        OR prla.INTERIOR = ''
                                                        OR prla.INTERIOR = '-'
                                                        OR prla.INTERIOR = '--'
                                                        OR prla.INTERIOR = '---'
                                                        OR prla.INTERIOR = '----'
                                                        OR prla.INTERIOR = '-----'
                                                   THEN ''
                                                   ELSE 'INTERIOR: ' + prla.INTERIOR + ' '
                                               END,
                                               CASE
                                                   WHEN prla.LOTE IS NULL
                                                        OR prla.LOTE = ''
                                                        OR prla.LOTE = '-'
                                                        OR prla.LOTE = '--'
                                                        OR prla.LOTE = '---'
                                                        OR prla.LOTE = '----'
                                                        OR prla.LOTE = '-----'
                                                   THEN ''
                                                   ELSE 'LOTE: ' + prla.LOTE + ' '
                                               END,
                                               CASE
                                                   WHEN prla.DEPARTAMENTO IS NULL
                                                        OR prla.DEPARTAMENTO = ''
                                                        OR prla.DEPARTAMENTO = '-'
                                                        OR prla.DEPARTAMENTO = '--'
                                                        OR prla.DEPARTAMENTO = '---'
                                                        OR prla.DEPARTAMENTO = '----'
                                                        OR prla.DEPARTAMENTO = '-----'
                                                   THEN ''
                                                   ELSE 'DEPARTAMENTO: ' + prla.DEPARTAMENTO + ' '
                                               END,
                                               CASE
                                                   WHEN prla.MANZANA IS NULL
                                                        OR prla.MANZANA = ''
                                                        OR prla.MANZANA = '-'
                                                        OR prla.MANZANA = '--'
                                                        OR prla.MANZANA = '---'
                                                        OR prla.MANZANA = '----'
                                                        OR prla.MANZANA = '-----'
                                                   THEN ''
                                                   ELSE 'MANZANA: ' + prla.MANZANA + ' '
                                               END)))), -- Direccion - varchar
                      NULL, -- Telefono - varchar
                      NULL, -- Obs_Establecimiento - varchar
                      prla.UBIGEO, -- Cod_Ubigeo - varchar
                      'MIGRACION', -- Cod_UsuarioReg - varchar
                      GETDATE(), -- Fecha_Reg - datetime
                      NULL, -- Cod_UsuarioAct - varchar
                      NULL -- Fecha_Act - datetime
               FROM PALERPtemp_sunat.dbo.padron_reducido_local_anexo prla;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_UBIGEOS_ActualizarDirecciones'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_UBIGEOS_ActualizarDirecciones;
GO
CREATE PROCEDURE USP_PRI_UBIGEOS_ActualizarDirecciones
WITH ENCRYPTION
AS
    BEGIN
        --UPDATE pcp
        --  SET 
        --      pcp.Direccion = CASE
        --                          WHEN pu.Cod_Ubigeo IS NULL
        --                          THEN pcp.Direccion
        --                          ELSE CASE
        --                                   WHEN pcp.Direccion = ''
        --                                   THEN pu.Departamento_Provincia_Distrito
        --                                   ELSE pcp.Direccion + ' ' + pu.Departamento_Provincia_Distrito
        --                               END
        --                      END
        --FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
        --     LEFT JOIN dbo.PRI_UBIGEOS pu ON pcp.Cod_Ubigeo = pu.Cod_Ubigeo;
        UPDATE pe
          SET 
              pe.Direccion = CASE
                                 WHEN pe.Cod_Ubigeo IS NULL
                                 THEN pe.Direccion
                                 ELSE CASE
                                          WHEN pe.Direccion = ''
                                          THEN pu.Departamento_Provincia_Distrito
                                          ELSE pe.Direccion + ' ' + pu.Departamento_Provincia_Distrito
                                      END
                             END
        FROM dbo.PRI_ESTABLECIMIENTOS pe
             LEFT JOIN dbo.PRI_UBIGEOS pu ON pe.Cod_Ubigeo = pu.Cod_Ubigeo;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_ESTABLECIMIENTOS_ReordenarIndices'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_ReordenarIndices;
GO
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_ReordenarIndices
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Nro_DocumentoAnterior VARCHAR(32)= '';
        DECLARE @Item INT= 1;
        UPDATE dbo.PRI_ESTABLECIMIENTOS
          SET 
              @Item = CASE
                          WHEN dbo.PRI_ESTABLECIMIENTOS.Nro_Documento = @Nro_DocumentoAnterior
                          THEN @Item + 1
                          ELSE 1
                      END, 
              dbo.PRI_ESTABLECIMIENTOS.Item = @Item, 
              @Nro_DocumentoAnterior = dbo.PRI_ESTABLECIMIENTOS.Nro_Documento;
    END;
GO




IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_PROVEEDOR_TraerRUCXNumero'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TraerRUCXNumero;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TraerRUCXNumero @Nro_Documento VARCHAR(11)
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT pcp.*
            FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
            WHERE pcp.Nro_Documento = @Nro_Documento
                  AND pcp.Cod_TipoDocumento = '6'
        )
            BEGIN
                SELECT 'EXISTE' Respuesta, 
                       pcp.Nro_Documento, 
                       pcp.Cod_TipoDocumento, 
                       ptd.Nom_TipoDoc, 
                       ISNULL(pcp.Cliente, '') Cliente, 
                       ISNULL(pcp.Direccion, '') Direccion, 
                       ISNULL(pcp.Cod_EstadoCliente, '002') Cod_EstadoCliente, 
                       ISNULL(pec.Nom_EstadoCliente, 'BAJA DE OFICIO') Nom_EstadoCliente, 
                       ISNULL(pcp.Cod_CondicionCliente, '02') Cod_CondicionCliente, 
                       ISNULL(pcc.Nom_CondicionCliente, 'NO HABIDO') Nom_CondicionCliente, 
                       ISNULL(pcp.Cod_Ubigeo, '') Cod_Ubigeo
                FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
                     RIGHT JOIN dbo.PRI_ESTADO_CLIENTE pec ON pcp.Cod_EstadoCliente = pec.Cod_EstadoCliente
                     RIGHT JOIN dbo.PRI_CONDICION_CLIENTE pcc ON pcp.Cod_CondicionCliente = pcc.Cod_CondicionCliente
                     RIGHT JOIN dbo.PRI_TIPO_DOCUMENTO ptd ON pcp.Cod_TipoDocumento = ptd.Cod_TipoDoc
                WHERE pcp.Nro_Documento = @Nro_Documento
                      AND pcp.Cod_TipoDocumento = '6';
        END;
            ELSE
            BEGIN
                SELECT 'NO ENCONTRADO' Respuesta;
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_ESTABLECIMIENTO_TraerAnexosXNumeroRUC'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_ESTABLECIMIENTO_TraerAnexosXNumeroRUC;
GO
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTO_TraerAnexosXNumeroRUC @Nro_Documento VARCHAR(11)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               pe.Nro_Documento, 
               pe.Item, 
               ISNULL(pe.Des_Establecimiento, 'DOMICILIO FISCAL') Des_Establecimiento, 
               ISNULL(pe.Cod_TipoEstablecimiento, '02') Cod_TipoEstablecimiento, 
               ISNULL(pe.Direccion, '') Direccion, 
               ISNULL(pe.Cod_Ubigeo, '') Cod_Ubigeo
        FROM dbo.PRI_ESTABLECIMIENTOS pe
        WHERE pe.Nro_Documento = @Nro_Documento;
    END;
GO


-- --Insertar
-- DECLARE @Fecha DATETIME= GETDATE();
-- INSERT INTO dbo.PRI_ESTABLECIMIENTOS
-- (Nro_Documento, 
--  Item, 
--  Des_Establecimiento, 
--  Cod_TipoEstablecimiento, 
--  Direccion, 
--  Telefono, 
--  Obs_Establecimiento, 
--  Cod_Ubigeo, 
--  Cod_UsuarioReg, 
--  Fecha_Reg, 
--  Cod_UsuarioAct, 
--  Fecha_Act
-- )
--        SELECT UPPER(LTRIM(RTRIM(prla.[ RUC]))), -- Nro_Documento - varchar
--               ROW_NUMBER() OVER(
--               ORDER BY prla.[ RUC] ASC), -- Item - int
--               'DOMICILIO FISCAL', -- Des_Establecimiento - varchar
--               '02', -- Cod_TipoEstablecimiento - varchar
--               UPPER(RTRIM(LTRIM(CONCAT(CASE
--                                            WHEN prla.[TIPO DE VÍA] IS NULL
--                                                 OR prla.[TIPO DE VÍA] = ''
--                                                 OR prla.[TIPO DE VÍA] = '-'
--                                                 OR prla.[TIPO DE VÍA] = '--'
--                                                 OR prla.[TIPO DE VÍA] = '---'
--                                                 OR prla.[TIPO DE VÍA] = '----'
--                                                 OR prla.[TIPO DE VÍA] = '-----'
--                                            THEN ''
--                                            ELSE prla.[TIPO DE VÍA] + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.[NOMBRE DE VÍA] IS NULL
--                                                 OR prla.[NOMBRE DE VÍA] = ''
--                                                 OR prla.[NOMBRE DE VÍA] = '-'
--                                                 OR prla.[NOMBRE DE VÍA] = '--'
--                                                 OR prla.[NOMBRE DE VÍA] = '---'
--                                                 OR prla.[NOMBRE DE VÍA] = '----'
--                                                 OR prla.[NOMBRE DE VÍA] = '-----'
--                                            THEN ''
--                                            ELSE prla.[NOMBRE DE VÍA] + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.[CÓDIGO DE ZONA] IS NULL
--                                                 OR prla.[CÓDIGO DE ZONA] = ''
--                                                 OR prla.[CÓDIGO DE ZONA] = '-'
--                                                 OR prla.[CÓDIGO DE ZONA] = '--'
--                                                 OR prla.[CÓDIGO DE ZONA] = '---'
--                                                 OR prla.[CÓDIGO DE ZONA] = '----'
--                                                 OR prla.[CÓDIGO DE ZONA] = '-----'
--                                            THEN ''
--                                            ELSE prla.[CÓDIGO DE ZONA] + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.[TIPO DE ZONA] IS NULL
--                                                 OR prla.[TIPO DE ZONA] = ''
--                                                 OR prla.[TIPO DE ZONA] = '-'
--                                                 OR prla.[TIPO DE ZONA] = '--'
--                                                 OR prla.[TIPO DE ZONA] = '---'
--                                                 OR prla.[TIPO DE ZONA] = '----'
--                                                 OR prla.[TIPO DE ZONA] = '-----'
--                                            THEN ''
--                                            ELSE prla.[TIPO DE ZONA] + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.NÚMERO IS NULL
--                                                 OR prla.NÚMERO = ''
--                                                 OR prla.NÚMERO = '-'
--                                                 OR prla.NÚMERO = '--'
--                                                 OR prla.NÚMERO = '---'
--                                                 OR prla.NÚMERO = '----'
--                                                 OR prla.NÚMERO = '-----'
--                                            THEN ''
--                                            ELSE prla.NÚMERO + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.KILÓMETRO IS NULL
--                                                 OR prla.KILÓMETRO = ''
--                                                 OR prla.KILÓMETRO = '-'
--                                                 OR prla.KILÓMETRO = '--'
--                                                 OR prla.KILÓMETRO = '---'
--                                                 OR prla.KILÓMETRO = '----'
--                                                 OR prla.KILÓMETRO = '-----'
--                                            THEN ''
--                                            ELSE 'KILOMETRO: ' + prla.KILÓMETRO + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.INTERIOR IS NULL
--                                                 OR prla.INTERIOR = ''
--                                                 OR prla.INTERIOR = '-'
--                                                 OR prla.INTERIOR = '--'
--                                                 OR prla.INTERIOR = '---'
--                                                 OR prla.INTERIOR = '----'
--                                                 OR prla.INTERIOR = '-----'
--                                            THEN ''
--                                            ELSE 'INTERIOR: ' + prla.INTERIOR + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.LOTE IS NULL
--                                                 OR prla.LOTE = ''
--                                                 OR prla.LOTE = '-'
--                                                 OR prla.LOTE = '--'
--                                                 OR prla.LOTE = '---'
--                                                 OR prla.LOTE = '----'
--                                                 OR prla.LOTE = '-----'
--                                            THEN ''
--                                            ELSE 'LOTE: ' + prla.LOTE + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.DEPARTAMENTO IS NULL
--                                                 OR prla.DEPARTAMENTO = ''
--                                                 OR prla.DEPARTAMENTO = '-'
--                                                 OR prla.DEPARTAMENTO = '--'
--                                                 OR prla.DEPARTAMENTO = '---'
--                                                 OR prla.DEPARTAMENTO = '----'
--                                                 OR prla.DEPARTAMENTO = '-----'
--                                            THEN ''
--                                            ELSE 'DEPARTAMENTO: ' + prla.DEPARTAMENTO + ' '
--                                        END,
--                                        CASE
--                                            WHEN prla.MANZANA IS NULL
--                                                 OR prla.MANZANA = ''
--                                                 OR prla.MANZANA = '-'
--                                                 OR prla.MANZANA = '--'
--                                                 OR prla.MANZANA = '---'
--                                                 OR prla.MANZANA = '----'
--                                                 OR prla.MANZANA = '-----'
--                                            THEN ''
--                                            ELSE 'MANZANA: ' + prla.MANZANA + ' '
--                                        END)))), -- Direccion - varchar
--               NULL, -- Telefono - varchar
--               NULL, -- Obs_Establecimiento - varchar
--               prla.UBIGEO, -- Cod_Ubigeo - varchar
--               'MIGRACION', -- Cod_UsuarioReg - varchar
--               @Fecha, -- Fecha_Reg - datetime
--               NULL, -- Cod_UsuarioAct - varchar
--               NULL -- Fecha_Act - datetime
--        FROM PALERPtemp_sunat.dbo.padron_reducido_local_anexo prla
--        WHERE UPPER(LTRIM(RTRIM(prla.[ RUC]))) IN
--        (
--            SELECT UPPER(LTRIM(RTRIM(prla.[ RUC])))
--            FROM PALERPtemp_sunat.dbo.padron_reducido_local_anexo prla
--            EXCEPT
--            SELECT pe.Nro_Documento
--            FROM dbo.PRI_ESTABLECIMIENTOS pe
--        );

DECLARE @Nombre_BD VARCHAR(MAX);
DECLARE @Nombre_Logico VARCHAR(MAX);
DECLARE @Ruta_Fisica VARCHAR(MAX);
DECLARE @Tipo_Archivo VARCHAR(MAX);
DECLARE @Script VARCHAR(MAX);
DECLARE Cursorfila CURSOR LOCAL
FOR SELECT DISTINCT 
           d.name Nombre_BD, 
           mf.name Nombre_Logico, 
           mf.physical_name Ruta_Fisica, 
           mf.type_desc Tipo_Archivo
    FROM sys.master_files mf
         INNER JOIN sys.databases d ON mf.database_id = d.database_id
    WHERE mf.name LIKE 'PALERP%'
          AND mf.type_desc = 'LOG';
OPEN Cursorfila;
FETCH NEXT FROM Cursorfila INTO @Nombre_BD, @Nombre_Logico, @Ruta_Fisica, @Tipo_Archivo;
WHILE(@@FETCH_STATUS = 0)
    BEGIN
        SET @Script = 'USE ' + @Nombre_BD + '
		ALTER DATABASE ' + @Nombre_BD + '
		SET RECOVERY SIMPLE;
		DBCC SHRINKFILE(' + @Nombre_Logico + ', 1);
		ALTER DATABASE ' + @Nombre_BD + '
		SET RECOVERY FULL;';
        EXEC (@Script);
        FETCH NEXT FROM Cursorfila INTO @Nombre_BD, @Nombre_Logico, @Ruta_Fisica, @Tipo_Archivo;
    END;
CLOSE Cursorfila;
DEALLOCATE Cursorfila;