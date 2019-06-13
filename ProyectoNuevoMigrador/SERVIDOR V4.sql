--Script para los servidores
--Ejcuta procedimeintos de guardado para los scripts
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_CONTACTO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_CONTACTO_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_I @Cod_TipoDocumentoP  VARCHAR(5), 
                                            @Nro_DocumentoP      VARCHAR(20), 
                                            @Cod_TipoDocumentoC  VARCHAR(5), 
                                            @Nro_DocumentoC      VARCHAR(20), 
                                            @Ap_Paterno          VARCHAR(128), 
                                            @Ap_Materno          VARCHAR(128), 
                                            @Nombres             VARCHAR(128), 
                                            @Cod_Telefono        VARCHAR(5), 
                                            @Nro_Telefono        VARCHAR(64), 
                                            @Anexo               VARCHAR(32), 
                                            @Email_Empresarial   VARCHAR(512), 
                                            @Email_Personal      VARCHAR(512), 
                                            @Celular             VARCHAR(64), 
                                            @Cod_TipoRelacion    VARCHAR(8), 
                                            @Fecha_Incorporacion VARCHAR(32), 
                                            @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocumentoP
                  AND Nro_Documento = @Nro_DocumentoP
        );
        DECLARE @Id_ClienteContacto INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocumentoC
                  AND Nro_Documento = @Nro_DocumentoC
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_CLIENTE_CONTACTO
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (Id_ClienteContacto = @Id_ClienteContacto)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_CONTACTO
                VALUES
                (@Id_ClienteProveedor, 
                 @Id_ClienteContacto, 
                 @Cod_TipoDocumentoC, 
                 @Nro_DocumentoC, 
                 @Ap_Paterno, 
                 @Ap_Materno, 
                 @Nombres, 
                 @Cod_Telefono, 
                 @Nro_Telefono, 
                 @Anexo, 
                 @Email_Empresarial, 
                 @Email_Personal, 
                 @Celular, 
                 @Cod_TipoRelacion, 
                 CONVERT(DATETIME, @Fecha_Incorporacion, 121), 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_CONTACTO
                  SET 
                      Cod_TipoDocumento = @Cod_TipoDocumentoC, 
                      Nro_Documento = @Nro_DocumentoC, 
                      Ap_Paterno = @Ap_Paterno, 
                      Ap_Materno = @Ap_Materno, 
                      Nombres = @Nombres, 
                      Cod_Telefono = @Cod_Telefono, 
                      Nro_Telefono = @Nro_Telefono, 
                      Anexo = @Anexo, 
                      Email_Empresarial = @Email_Empresarial, 
                      Email_Personal = @Email_Personal, 
                      Celular = @Celular, 
                      Cod_TipoRelacion = @Cod_TipoRelacion, 
                      Fecha_Incorporacion = CONVERT(DATETIME, @Fecha_Incorporacion, 121), 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (Id_ClienteContacto = @Id_ClienteContacto);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_SUCURSAL_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_SUCURSAL_I;
GO
CREATE PROCEDURE USP_PRI_SUCURSAL_I @Cod_Sucursal    VARCHAR(32), 
                                    @Nom_Sucursal    VARCHAR(32), 
                                    @Dir_Sucursal    VARCHAR(512), 
                                    @Por_UtilidadMax NUMERIC(5, 2), 
                                    @Por_UtilidadMin NUMERIC(5, 2), 
                                    @Cod_UsuarioAdm  VARCHAR(32), 
                                    @Cabecera_Pagina VARCHAR(1024), 
                                    @Pie_Pagina      VARCHAR(1024), 
                                    @Flag_Activo     BIT, 
                                    @Cod_Ubigeo      VARCHAR(32), 
                                    @Cod_Usuario     VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Sucursal
            FROM PRI_SUCURSAL
            WHERE(Cod_Sucursal = @Cod_Sucursal)
        )
            BEGIN
                INSERT INTO PRI_SUCURSAL
                VALUES
                (@Cod_Sucursal, 
                 @Nom_Sucursal, 
                 @Dir_Sucursal, 
                 @Por_UtilidadMax, 
                 @Por_UtilidadMin, 
                 @Cod_UsuarioAdm, 
                 @Cabecera_Pagina, 
                 @Pie_Pagina, 
                 @Flag_Activo, 
                 @Cod_Ubigeo, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_SUCURSAL
                  SET 
                      Nom_Sucursal = @Nom_Sucursal, 
                      Dir_Sucursal = @Dir_Sucursal, 
                      Por_UtilidadMax = @Por_UtilidadMax, 
                      Por_UtilidadMin = @Por_UtilidadMin, 
                      Cod_UsuarioAdm = @Cod_UsuarioAdm, 
                      Cabecera_Pagina = @Cabecera_Pagina, 
                      Pie_Pagina = @Pie_Pagina, 
                      Flag_Activo = @Flag_Activo, 
                      Cod_Ubigeo = @Cod_Ubigeo, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Sucursal = @Cod_Sucursal);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PERSONAL_PARENTESCO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PERSONAL_PARENTESCO_I;
GO
CREATE PROCEDURE USP_PRI_PERSONAL_PARENTESCO_I @Cod_Personal       VARCHAR(32), 
                                               @Item_Parentesco    INT, 
                                               @Cod_TipoDoc        VARCHAR(5), 
                                               @Num_Doc            VARCHAR(20), 
                                               @ApellidoPaterno    VARCHAR(124), 
                                               @ApellidoMaterno    VARCHAR(124), 
                                               @Nombres            VARCHAR(124), 
                                               @Cod_TipoParentesco VARCHAR(5), 
                                               @Obs_Parentesco     VARCHAR(1024), 
                                               @Cod_Usuario        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Personal, 
                   @Item_Parentesco
            FROM PRI_PERSONAL_PARENTESCO
            WHERE(Cod_Personal = @Cod_Personal)
                 AND (Item_Parentesco = @Item_Parentesco)
        )
            BEGIN
                INSERT INTO PRI_PERSONAL_PARENTESCO
                VALUES
                (@Cod_Personal, 
                 @Item_Parentesco, 
                 @Cod_TipoDoc, 
                 @Num_Doc, 
                 @ApellidoPaterno, 
                 @ApellidoMaterno, 
                 @Nombres, 
                 @Cod_TipoParentesco, 
                 @Obs_Parentesco, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PERSONAL_PARENTESCO
                  SET 
                      Cod_TipoDoc = @Cod_TipoDoc, 
                      Num_Doc = @Num_Doc, 
                      ApellidoPaterno = @ApellidoPaterno, 
                      ApellidoMaterno = @ApellidoMaterno, 
                      Nombres = @Nombres, 
                      Cod_TipoParentesco = @Cod_TipoParentesco, 
                      Obs_Parentesco = @Obs_Parentesco, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Personal = @Cod_Personal)
                     AND (Item_Parentesco = @Item_Parentesco);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PERSONAL_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PERSONAL_I;
GO
CREATE PROCEDURE USP_PRI_PERSONAL_I @Cod_Personal                   VARCHAR(32), 
                                    @Cod_TipoDoc                    VARCHAR(3), 
                                    @Num_Doc                        VARCHAR(20), 
                                    @ApellidoPaterno                VARCHAR(64), 
                                    @ApellidoMaterno                VARCHAR(64), 
                                    @PrimeroNombre                  VARCHAR(64), 
                                    @SegundoNombre                  VARCHAR(64), 
                                    @Direccion                      VARCHAR(128), 
                                    @Ref_Direccion                  VARCHAR(256), 
                                    @Telefono                       VARCHAR(256), 
                                    @Email                          VARCHAR(256), 
                                    @Fecha_Ingreso                  VARCHAR(32), 
                                    @Fecha_Nacimiento               VARCHAR(32), 
                                    @Cod_Cargo                      VARCHAR(32), 
                                    @Cod_Estado                     VARCHAR(32), 
                                    @Cod_Area                       VARCHAR(32), 
                                    @Cod_Local                      VARCHAR(16), 
                                    @Cod_CentroCostos               VARCHAR(16), 
                                    @Cod_EstadoCivil                VARCHAR(32), 
                                    @Fecha_InsESSALUD               VARCHAR(32), 
                                    @AutoGeneradoEsSalud            VARCHAR(64), 
                                    @Cod_CuentaCTS                  VARCHAR(5), 
                                    @Num_CuentaCTS                  VARCHAR(128), 
                                    @Cod_BancoRemuneracion          VARCHAR(5), 
                                    @Num_CuentaRemuneracion         VARCHAR(128), 
                                    @Grupo_Sanguinio                VARCHAR(64), 
                                    @Cod_AFP                        VARCHAR(32), 
                                    @AutoGeneradoAFP                VARCHAR(32), 
                                    @Flag_CertificadoSalud          BIT, 
                                    @Flag_CertificadoAntPoliciales  BIT, 
                                    @Flag_CertificadorAntJudiciales BIT, 
                                    @Flag_DeclaracionBienes         BIT, 
                                    @Flag_OtrosDocumentos           BIT, 
                                    @Cod_Sexo                       VARCHAR(32), 
                                    @Cod_UsuarioLogin               VARCHAR(32), 
                                    @Obs_Personal                   XML, 
                                    @Cod_Usuario                    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Personal
            FROM PRI_PERSONAL
            WHERE(Cod_Personal = @Cod_Personal)
        )
            BEGIN
                INSERT INTO PRI_PERSONAL
                VALUES
                (@Cod_Personal, 
                 @Cod_TipoDoc, 
                 @Num_Doc, 
                 @ApellidoPaterno, 
                 @ApellidoMaterno, 
                 @PrimeroNombre, 
                 @SegundoNombre, 
                 @Direccion, 
                 @Ref_Direccion, 
                 @Telefono, 
                 @Email, 
                 CONVERT(DATETIME, @Fecha_Ingreso, 121), 
                 CONVERT(DATETIME, @Fecha_Nacimiento, 121), 
                 @Cod_Cargo, 
                 @Cod_Estado, 
                 @Cod_Area, 
                 @Cod_Local, 
                 @Cod_CentroCostos, 
                 @Cod_EstadoCivil, 
                 CONVERT(DATETIME, @Fecha_InsESSALUD, 121), 
                 @AutoGeneradoEsSalud, 
                 @Cod_CuentaCTS, 
                 @Num_CuentaCTS, 
                 @Cod_BancoRemuneracion, 
                 @Num_CuentaRemuneracion, 
                 @Grupo_Sanguinio, 
                 @Cod_AFP, 
                 @AutoGeneradoAFP, 
                 @Flag_CertificadoSalud, 
                 @Flag_CertificadoAntPoliciales, 
                 @Flag_CertificadorAntJudiciales, 
                 @Flag_DeclaracionBienes, 
                 @Flag_OtrosDocumentos, 
                 @Cod_Sexo, 
                 @Cod_UsuarioLogin, 
                 @Obs_Personal, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PERSONAL
                  SET 
                      Cod_TipoDoc = @Cod_TipoDoc, 
                      Num_Doc = @Num_Doc, 
                      ApellidoPaterno = @ApellidoPaterno, 
                      ApellidoMaterno = @ApellidoMaterno, 
                      PrimeroNombre = @PrimeroNombre, 
                      SegundoNombre = @SegundoNombre, 
                      Direccion = @Direccion, 
                      Ref_Direccion = @Ref_Direccion, 
                      Telefono = @Telefono, 
                      Email = @Email, 
                      Fecha_Ingreso = CONVERT(DATETIME, @Fecha_Ingreso, 121), 
                      Fecha_Nacimiento = CONVERT(DATETIME, @Fecha_Nacimiento, 121), 
                      Cod_Cargo = @Cod_Cargo, 
                      Cod_Estado = @Cod_Estado, 
                      Cod_Area = @Cod_Area, 
                      Cod_Local = @Cod_Local, 
                      Cod_CentroCostos = @Cod_CentroCostos, 
                      Cod_EstadoCivil = @Cod_EstadoCivil, 
                      Fecha_InsESSALUD = CONVERT(DATETIME, @Fecha_InsESSALUD, 121), 
                      AutoGeneradoEsSalud = @AutoGeneradoEsSalud, 
                      Cod_CuentaCTS = @Cod_CuentaCTS, 
                      Num_CuentaCTS = @Num_CuentaCTS, 
                      Cod_BancoRemuneracion = @Cod_BancoRemuneracion, 
                      Num_CuentaRemuneracion = @Num_CuentaRemuneracion, 
                      Grupo_Sanguinio = @Grupo_Sanguinio, 
                      Cod_AFP = @Cod_AFP, 
                      AutoGeneradoAFP = @AutoGeneradoAFP, 
                      Flag_CertificadoSalud = @Flag_CertificadoSalud, 
                      Flag_CertificadoAntPoliciales = @Flag_CertificadoAntPoliciales, 
                      Flag_CertificadorAntJudiciales = @Flag_CertificadorAntJudiciales, 
                      Flag_DeclaracionBienes = @Flag_DeclaracionBienes, 
                      Flag_OtrosDocumentos = @Flag_OtrosDocumentos, 
                      Cod_Sexo = @Cod_Sexo, 
                      Cod_UsuarioLogin = @Cod_UsuarioLogin, 
                      Obs_Personal = @Obs_Personal, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Personal = @Cod_Personal);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PADRONES_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PADRONES_I;
GO
CREATE PROCEDURE USP_PRI_PADRONES_I @Cod_Padron        VARCHAR(32), 
                                    @Cod_TipoDocumento VARCHAR(3), 
                                    @Nro_Documento     VARCHAR(32), 
                                    @Cod_TipoPadron    VARCHAR(32), 
                                    @Des_Padron        VARCHAR(32), 
                                    @Fecha_Inicio      VARCHAR(32), 
                                    @Fecha_Fin         VARCHAR(32), 
                                    @Nro_Resolucion    VARCHAR(64), 
                                    @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_PADRONES
            WHERE(Cod_Padron = @Cod_Padron)
                 AND (Id_ClienteProveedor = @Id_ClienteProveedor)
        )
            BEGIN
                INSERT INTO PRI_PADRONES
                VALUES
                (@Cod_Padron, 
                 @Id_ClienteProveedor, 
                 @Cod_TipoPadron, 
                 @Des_Padron, 
                 CONVERT(DATETIME, @Fecha_Inicio, 121), 
                 CONVERT(DATETIME, @Fecha_Fin, 121), 
                 @Nro_Resolucion, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PADRONES
                  SET 
                      Cod_TipoPadron = @Cod_TipoPadron, 
                      Des_Padron = @Des_Padron, 
                      Fecha_Inicio = CONVERT(DATETIME, @Fecha_Inicio, 121), 
                      Fecha_Fin = CONVERT(DATETIME, @Fecha_Fin, 121), 
                      Nro_Resolucion = @Nro_Resolucion, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Padron = @Cod_Padron)
                     AND (Id_ClienteProveedor = @Id_ClienteProveedor);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_MENSAJES_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_MENSAJES_I;
GO
CREATE PROCEDURE USP_PRI_MENSAJES_I @Cod_UsuarioRemite VARCHAR(32), 
                                    @Fecha_Remite      VARCHAR(32), 
                                    @Mensaje           VARCHAR(1024), 
                                    @Flag_Leido        BIT, 
                                    @Cod_UsuarioRecibe VARCHAR(32), 
                                    @Fecha_Recibe      VARCHAR(32), 
                                    @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Mensaje INT=
        (
            SELECT pm.Id_Mensaje
            FROM dbo.PRI_MENSAJES pm
            WHERE pm.Cod_UsuarioRemite = @Cod_UsuarioRemite
                  AND pm.Fecha_Remite = @Fecha_Remite
                  AND pm.Cod_UsuarioRecibe = @Cod_UsuarioRecibe
                  AND pm.Fecha_Recibe = @Fecha_Recibe
        );
        IF NOT EXISTS
        (
            SELECT @Id_Mensaje
            FROM PRI_MENSAJES
            WHERE(Id_Mensaje = @Id_Mensaje)
        )
            BEGIN
                INSERT INTO PRI_MENSAJES
                VALUES
                (@Cod_UsuarioRemite, 
                 CONVERT(DATETIME, @Fecha_Remite, 121), 
                 @Mensaje, 
                 @Flag_Leido, 
                 @Cod_UsuarioRecibe, 
                 CONVERT(DATETIME, @Fecha_Recibe, 121), 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_MENSAJES
                  SET 
                      Cod_UsuarioRemite = @Cod_UsuarioRemite, 
                      Fecha_Remite = CONVERT(DATETIME, @Fecha_Remite, 121), 
                      Mensaje = @Mensaje, 
                      Flag_Leido = @Flag_Leido, 
                      Cod_UsuarioRecibe = @Cod_UsuarioRecibe, 
                      Fecha_Recibe = CONVERT(DATETIME, @Fecha_Recibe, 121), 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Mensaje = @Id_Mensaje);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_ESTABLECIMIENTOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_I;
GO
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_I @Cod_Establecimientos    VARCHAR(32), 
                                            @Cod_TipoDocumento       VARCHAR(3), 
                                            @Nro_Documento           VARCHAR(32), 
                                            @Des_Establecimiento     VARCHAR(512), 
                                            @Cod_TipoEstablecimiento VARCHAR(5), 
                                            @Direccion               VARCHAR(1024), 
                                            @Telefono                VARCHAR(1024), 
                                            @Obs_Establecimiento     VARCHAR(1024), 
                                            @Cod_Ubigeo              VARCHAR(32), 
                                            @Cod_Usuario             VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_ESTABLECIMIENTOS
            WHERE(Cod_Establecimientos = @Cod_Establecimientos)
                 AND (Id_ClienteProveedor = @Id_ClienteProveedor)
        )
            BEGIN
                INSERT INTO PRI_ESTABLECIMIENTOS
                VALUES
                (@Cod_Establecimientos, 
                 @Id_ClienteProveedor, 
                 @Des_Establecimiento, 
                 @Cod_TipoEstablecimiento, 
                 @Direccion, 
                 @Telefono, 
                 @Obs_Establecimiento, 
                 @Cod_Ubigeo, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_ESTABLECIMIENTOS
                  SET 
                      Des_Establecimiento = @Des_Establecimiento, 
                      Cod_TipoEstablecimiento = @Cod_TipoEstablecimiento, 
                      Direccion = @Direccion, 
                      Telefono = @Telefono, 
                      Obs_Establecimiento = @Obs_Establecimiento, 
                      Cod_Ubigeo = @Cod_Ubigeo, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Establecimientos = @Cod_Establecimientos)
                     AND (Id_ClienteProveedor = @Id_ClienteProveedor);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_EMPRESA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_EMPRESA_I;
GO
CREATE PROCEDURE USP_PRI_EMPRESA_I @Cod_Empresa            VARCHAR(32), 
                                   @RUC                    VARCHAR(32), 
                                   @Nom_Comercial          VARCHAR(1024), 
                                   @RazonSocial            VARCHAR(1024), 
                                   @Direccion              VARCHAR(1024), 
                                   @Telefonos              VARCHAR(512), 
                                   @Web                    VARCHAR(512), 
                                   @Imagen_H               BINARY, 
                                   @Imagen_V               BINARY, 
                                   @Flag_ExoneradoImpuesto BIT, 
                                   @Des_Impuesto           VARCHAR(16), 
                                   @Por_Impuesto           NUMERIC(5, 2), 
                                   @EstructuraContable     VARCHAR(32), 
                                   @Version                VARCHAR(32), 
                                   @Cod_Ubigeo             VARCHAR(8), 
                                   @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Empresa
            FROM PRI_EMPRESA
            WHERE(Cod_Empresa = @Cod_Empresa)
        )
            BEGIN
                INSERT INTO PRI_EMPRESA
                VALUES
                (@Cod_Empresa, 
                 @RUC, 
                 @Nom_Comercial, 
                 @RazonSocial, 
                 @Direccion, 
                 @Telefonos, 
                 @Web, 
                 @Imagen_H, 
                 @Imagen_V, 
                 @Flag_ExoneradoImpuesto, 
                 @Des_Impuesto, 
                 @Por_Impuesto, 
                 @EstructuraContable, 
                 @Version, 
                 @Cod_Ubigeo, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_EMPRESA
                  SET 
                      RUC = @RUC, 
                      Nom_Comercial = @Nom_Comercial, 
                      RazonSocial = @RazonSocial, 
                      Direccion = @Direccion, 
                      Telefonos = @Telefonos, 
                      Web = @Web, 
                      Imagen_H = @Imagen_H, 
                      Imagen_V = @Imagen_V, 
                      Flag_ExoneradoImpuesto = @Flag_ExoneradoImpuesto, 
                      Des_Impuesto = @Des_Impuesto, 
                      Por_Impuesto = @Por_Impuesto, 
                      EstructuraContable = @EstructuraContable, 
                      Version = @Version, 
                      Cod_Ubigeo = @Cod_Ubigeo, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Empresa = @Cod_Empresa);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_DESCUENTOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_DESCUENTOS_I;
GO
CREATE PROCEDURE USP_PRI_DESCUENTOS_I @Cod_TipoDocumento VARCHAR(3), 
                                      @Nro_Documento     VARCHAR(32), 
                                      @Cod_TipoDescuento VARCHAR(32), 
                                      @Aplica            VARCHAR(64), 
                                      @Cod_Aplica        VARCHAR(32), 
                                      @Cod_TipoCliente   VARCHAR(32), 
                                      @Cod_TipoPrecio    VARCHAR(5), 
                                      @Monto_Precio      NUMERIC(38, 6), 
                                      @Fecha_Inicia      VARCHAR(32), 
                                      @Fecha_Fin         VARCHAR(32), 
                                      @Obs_Descuento     VARCHAR(1024), 
                                      @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        DECLARE @Id_Descuento INT=
        (
            SELECT pd.Id_Descuento
            FROM dbo.PRI_DESCUENTOS pd
            WHERE pd.Cod_TipoDescuento = @Cod_TipoDescuento
                  AND pd.Id_ClienteProveedor = @Id_ClienteProveedor
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_DESCUENTOS
            WHERE(Id_Descuento = @Id_Descuento)
        )
            BEGIN
                INSERT INTO PRI_DESCUENTOS
                VALUES
                (@Id_ClienteProveedor, 
                 @Cod_TipoDescuento, 
                 @Aplica, 
                 @Cod_Aplica, 
                 @Cod_TipoCliente, 
                 @Cod_TipoPrecio, 
                 @Monto_Precio, 
                 CONVERT(DATETIME, @Fecha_Inicia, 121), 
                 CONVERT(DATETIME, @Fecha_Fin, 121), 
                 @Obs_Descuento, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_DESCUENTOS
                  SET 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Cod_TipoDescuento = @Cod_TipoDescuento, 
                      Aplica = @Aplica, 
                      Cod_Aplica = @Cod_Aplica, 
                      Cod_TipoCliente = @Cod_TipoCliente, 
                      Cod_TipoPrecio = @Cod_TipoPrecio, 
                      Monto_Precio = @Monto_Precio, 
                      Fecha_Inicia = CONVERT(DATETIME, @Fecha_Inicia, 121), 
                      Fecha_Fin = CONVERT(DATETIME, @Fecha_Fin, 121), 
                      Obs_Descuento = @Obs_Descuento, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Descuento = @Id_Descuento);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CUENTA_CONTABLE_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CUENTA_CONTABLE_I;
GO
CREATE PROCEDURE USP_PRI_CUENTA_CONTABLE_I @Cod_CuentaContable   VARCHAR(16), 
                                           @Des_CuentaContable   VARCHAR(128), 
                                           @Tipo_Cuenta          VARCHAR(32), 
                                           @Cod_Moneda           VARCHAR(5), 
                                           @Flag_CuentaAnalitica BIT, 
                                           @Flag_CentroCostos    BIT, 
                                           @Flag_CuentaBancaria  BIT, 
                                           @Cod_EntidadBancaria  VARCHAR(5), 
                                           @Numero_Cuenta        VARCHAR(64), 
                                           @Clase_Cuenta         VARCHAR(32), 
                                           @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_CuentaContable
            FROM PRI_CUENTA_CONTABLE
            WHERE(Cod_CuentaContable = @Cod_CuentaContable)
        )
            BEGIN
                INSERT INTO PRI_CUENTA_CONTABLE
                VALUES
                (@Cod_CuentaContable, 
                 @Des_CuentaContable, 
                 @Tipo_Cuenta, 
                 @Cod_Moneda, 
                 @Flag_CuentaAnalitica, 
                 @Flag_CentroCostos, 
                 @Flag_CuentaBancaria, 
                 @Cod_EntidadBancaria, 
                 @Numero_Cuenta, 
                 @Clase_Cuenta, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CUENTA_CONTABLE
                  SET 
                      Des_CuentaContable = @Des_CuentaContable, 
                      Tipo_Cuenta = @Tipo_Cuenta, 
                      Cod_Moneda = @Cod_Moneda, 
                      Flag_CuentaAnalitica = @Flag_CuentaAnalitica, 
                      Flag_CentroCostos = @Flag_CentroCostos, 
                      Flag_CuentaBancaria = @Flag_CuentaBancaria, 
                      Cod_EntidadBancaria = @Cod_EntidadBancaria, 
                      Numero_Cuenta = @Numero_Cuenta, 
                      Clase_Cuenta = @Clase_Cuenta, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_CuentaContable = @Cod_CuentaContable);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_VISITAS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_VISITAS_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_VISITAS_I @Cod_ClienteVisita      VARCHAR(32), 
                                           @Cod_UsuarioVendedor    VARCHAR(8), 
                                           @Cod_TipoDocumento      VARCHAR(3), 
                                           @Nro_Documento          VARCHAR(32), 
                                           @Ruta                   VARCHAR(64), 
                                           @Cod_TipoVisita         VARCHAR(5), 
                                           @Cod_Resultado          VARCHAR(5), 
                                           @Fecha_HoraVisita       VARCHAR(32), 
                                           @Comentarios            VARCHAR(1024), 
                                           @Flag_Compromiso        BIT, 
                                           @Fecha_HoraCompromiso   VARCHAR(32), 
                                           @Cod_UsuarioResponsable VARCHAR(8), 
                                           @Des_Compromiso         VARCHAR(1024), 
                                           @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT @Cod_ClienteVisita
            FROM PRI_CLIENTE_VISITAS
            WHERE(Cod_ClienteVisita = @Cod_ClienteVisita)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_VISITAS
                VALUES
                (@Cod_ClienteVisita, 
                 @Cod_UsuarioVendedor, 
                 @Id_ClienteProveedor, 
                 @Ruta, 
                 @Cod_TipoVisita, 
                 @Cod_Resultado, 
                 CONVERT(DATETIME, @Fecha_HoraVisita, 121), 
                 @Comentarios, 
                 @Flag_Compromiso, 
                 CONVERT(DATETIME, @Fecha_HoraCompromiso, 121), 
                 @Cod_UsuarioResponsable, 
                 @Des_Compromiso, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_VISITAS
                  SET 
                      Cod_UsuarioVendedor = @Cod_UsuarioVendedor, 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Ruta = @Ruta, 
                      Cod_TipoVisita = @Cod_TipoVisita, 
                      Cod_Resultado = @Cod_Resultado, 
                      Fecha_HoraVisita = CONVERT(DATETIME, @Fecha_HoraVisita, 121), 
                      Comentarios = @Comentarios, 
                      Flag_Compromiso = @Flag_Compromiso, 
                      Fecha_HoraCompromiso = CONVERT(DATETIME, @Fecha_HoraCompromiso, 121), 
                      Cod_UsuarioResponsable = @Cod_UsuarioResponsable, 
                      Des_Compromiso = @Des_Compromiso, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_ClienteVisita = @Cod_ClienteVisita);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_CUENTABANCARIA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_I @Cod_TipoDocumento      VARCHAR(3), 
                                                  @Nro_Documento          VARCHAR(32), 
                                                  @NroCuenta_Bancaria     VARCHAR(32), 
                                                  @Cod_EntidadFinanciera  VARCHAR(5), 
                                                  @Cod_TipoCuentaBancaria VARCHAR(8), 
                                                  @Des_CuentaBancaria     VARCHAR(512), 
                                                  @Flag_Principal         BIT, 
                                                  @Cuenta_Interbancaria   VARCHAR(64), 
                                                  @Obs_CuentaBancaria     VARCHAR(1024), 
                                                  @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_CLIENTE_CUENTABANCARIA
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (NroCuenta_Bancaria = @NroCuenta_Bancaria)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_CUENTABANCARIA
                VALUES
                (@Id_ClienteProveedor, 
                 @NroCuenta_Bancaria, 
                 @Cod_EntidadFinanciera, 
                 @Cod_TipoCuentaBancaria, 
                 @Des_CuentaBancaria, 
                 @Flag_Principal, 
                 @Cuenta_Interbancaria, 
                 @Obs_CuentaBancaria, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_CUENTABANCARIA
                  SET 
                      Cod_EntidadFinanciera = @Cod_EntidadFinanciera, 
                      Cod_TipoCuentaBancaria = @Cod_TipoCuentaBancaria, 
                      Des_CuentaBancaria = @Des_CuentaBancaria, 
                      Flag_Principal = @Flag_Principal, 
                      Cuenta_Interbancaria = @Cuenta_Interbancaria, 
                      Obs_CuentaBancaria = @Obs_CuentaBancaria, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (NroCuenta_Bancaria = @NroCuenta_Bancaria);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CATEGORIA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CATEGORIA_I;
GO
CREATE PROCEDURE USP_PRI_CATEGORIA_I @Cod_Categoria      VARCHAR(32), 
                                     @Des_Categoria      VARCHAR(64), 
                                     @Foto               BINARY, 
                                     @Cod_CategoriaPadre VARCHAR(32), 
                                     @Cod_Usuario        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Categoria
            FROM PRI_CATEGORIA
            WHERE(Cod_Categoria = @Cod_Categoria)
        )
            BEGIN
                INSERT INTO PRI_CATEGORIA
                VALUES
                (@Cod_Categoria, 
                 @Des_Categoria, 
                 @Foto, 
                 @Cod_CategoriaPadre, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CATEGORIA
                  SET 
                      Des_Categoria = @Des_Categoria, 
                      Foto = @Foto, 
                      Cod_CategoriaPadre = @Cod_CategoriaPadre, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Categoria = @Cod_Categoria);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_AREAS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_AREAS_I;
GO
CREATE PROCEDURE USP_PRI_AREAS_I @Cod_Area      VARCHAR(32), 
                                 @Cod_Sucursal  VARCHAR(32), 
                                 @Des_Area      VARCHAR(512), 
                                 @Numero        VARCHAR(512), 
                                 @Cod_AreaPadre VARCHAR(32), 
                                 @Cod_Usuario   VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Area
            FROM PRI_AREAS
            WHERE(Cod_Area = @Cod_Area)
        )
            BEGIN
                INSERT INTO PRI_AREAS
                VALUES
                (@Cod_Area, 
                 @Cod_Sucursal, 
                 @Des_Area, 
                 @Numero, 
                 @Cod_AreaPadre, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_AREAS
                  SET 
                      Cod_Sucursal = @Cod_Sucursal, 
                      Des_Area = @Des_Area, 
                      Numero = @Numero, 
                      Cod_AreaPadre = @Cod_AreaPadre, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Area = @Cod_Area);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_ACTIVIDADES_ECONOMICAS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_I;
GO
CREATE PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_I @Cod_ActividadEconomica VARCHAR(32), 
                                                  @Cod_TipoDocumento      VARCHAR(3), 
                                                  @Nro_Documento          VARCHAR(32), 
                                                  @CIIU                   VARCHAR(32), 
                                                  @Escala                 VARCHAR(64), 
                                                  @Des_ActividadEconomica VARCHAR(512), 
                                                  @Flag_Activo            BIT, 
                                                  @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT @Cod_ActividadEconomica, 
                   @Id_ClienteProveedor
            FROM PRI_ACTIVIDADES_ECONOMICAS
            WHERE(Cod_ActividadEconomica = @Cod_ActividadEconomica)
                 AND (Id_ClienteProveedor = @Id_ClienteProveedor)
        )
            BEGIN
                INSERT INTO PRI_ACTIVIDADES_ECONOMICAS
                VALUES
                (@Cod_ActividadEconomica, 
                 @Id_ClienteProveedor, 
                 @CIIU, 
                 @Escala, 
                 @Des_ActividadEconomica, 
                 @Flag_Activo, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_ACTIVIDADES_ECONOMICAS
                  SET 
                      CIIU = @CIIU, 
                      Escala = @Escala, 
                      Des_ActividadEconomica = @Des_ActividadEconomica, 
                      Flag_Activo = @Flag_Activo, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_ActividadEconomica = @Cod_ActividadEconomica)
                     AND (Id_ClienteProveedor = @Id_ClienteProveedor);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_TIPOCAMBIO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_TIPOCAMBIO_I;
GO
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_I @FechaHora   VARCHAR(32), 
                                      @Cod_Moneda  VARCHAR(3), 
                                      @SunatCompra NUMERIC(38, 4), 
                                      @SunatVenta  NUMERIC(38, 4), 
                                      @Compra      NUMERIC(38, 4), 
                                      @Venta       NUMERIC(38, 4), 
                                      @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_TipoCambio INT=
        (
            SELECT ct.Id_TipoCambio
            FROM dbo.CAJ_TIPOCAMBIO ct
            WHERE ct.FechaHora = CONVERT(DATETIME, @FechaHora, 121)
                  AND ct.Cod_Moneda = @Cod_Moneda
        );
        IF NOT EXISTS
        (
            SELECT @Id_TipoCambio
            FROM CAJ_TIPOCAMBIO
            WHERE(Id_TipoCambio = @Id_TipoCambio)
        )
            BEGIN
                INSERT INTO CAJ_TIPOCAMBIO
                VALUES
                (CONVERT(DATETIME, @FechaHora, 121), 
                 @Cod_Moneda, 
                 @SunatCompra, 
                 @SunatVenta, 
                 @Compra, 
                 @Venta, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_TIPOCAMBIO
                  SET 
                      FechaHora = CONVERT(DATETIME, @FechaHora, 121), 
                      Cod_Moneda = @Cod_Moneda, 
                      SunatCompra = @SunatCompra, 
                      SunatVenta = @SunatVenta, 
                      Compra = @Compra, 
                      Venta = @Venta, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_TipoCambio = @Id_TipoCambio);
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_LOG_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_LOG_I;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_I @Cod_TipoComprobante VARCHAR(5), 
                                           @Serie               VARCHAR(4), 
                                           @Numero              VARCHAR(20), 
                                           @Item                INT, 
                                           @Cod_Estado          VARCHAR(32), 
                                           @Cod_Mensaje         VARCHAR(32), 
                                           @Mensaje             VARCHAR(512), 
                                           @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT=
        (
            SELECT TOP 1 ccp.id_ComprobantePago
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND ccp.Serie = @Serie
                  AND ccp.Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT @id_ComprobantePago, 
                   @Item
            FROM CAJ_COMPROBANTE_LOG
            WHERE(id_ComprobantePago = @id_ComprobantePago)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_LOG
                VALUES
                (@id_ComprobantePago, 
                 @Item, 
                 @Cod_Estado, 
                 @Cod_Mensaje, 
                 @Mensaje, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_COMPROBANTE_LOG
                  SET 
                      Cod_Estado = @Cod_Estado, 
                      Cod_Mensaje = @Cod_Mensaje, 
                      Mensaje = @Mensaje, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago)
                     AND (Item = @Item);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJA_ALMACEN_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_I;
GO
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_I @Cod_Caja       VARCHAR(32), 
                                        @Cod_Almacen    VARCHAR(32), 
                                        @Flag_Principal BIT, 
                                        @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Caja, 
                   @Cod_Almacen
            FROM CAJ_CAJA_ALMACEN
            WHERE(Cod_Caja = @Cod_Caja)
                 AND (Cod_Almacen = @Cod_Almacen)
        )
            BEGIN
                INSERT INTO CAJ_CAJA_ALMACEN
                VALUES
                (@Cod_Caja, 
                 @Cod_Almacen, 
                 @Flag_Principal, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_CAJA_ALMACEN
                  SET 
                      Flag_Principal = @Flag_Principal, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Caja = @Cod_Caja)
                     AND (Cod_Almacen = @Cod_Almacen);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJAS_DOC_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJAS_DOC_I;
GO
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_I @Cod_Caja            VARCHAR(32), 
                                     @Item                INT, 
                                     @Cod_TipoComprobante VARCHAR(5), 
                                     @Serie               VARCHAR(5), 
                                     @Impresora           VARCHAR(512), 
                                     @Flag_Imprimir       BIT, 
                                     @Flag_FacRapida      BIT, 
                                     @Nom_Archivo         VARCHAR(1024), 
                                     @Nro_SerieTicketera  VARCHAR(64), 
                                     @Nom_ArchivoPublicar VARCHAR(512), 
                                     @Limite              INT, 
                                     @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Caja, 
                   @Item
            FROM CAJ_CAJAS_DOC
            WHERE(Cod_Caja = @Cod_Caja)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO CAJ_CAJAS_DOC
                VALUES
                (@Cod_Caja, 
                 @Item, 
                 @Cod_TipoComprobante, 
                 @Serie, 
                 @Impresora, 
                 @Flag_Imprimir, 
                 @Flag_FacRapida, 
                 @Nom_Archivo, 
                 @Nro_SerieTicketera, 
                 @Nom_ArchivoPublicar, 
                 @Limite, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_CAJAS_DOC
                  SET 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Serie = @Serie, 
                      Impresora = @Impresora, 
                      Flag_Imprimir = @Flag_Imprimir, 
                      Flag_FacRapida = @Flag_FacRapida, 
                      Nom_Archivo = @Nom_Archivo, 
                      Nro_SerieTicketera = @Nro_SerieTicketera, 
                      Nom_ArchivoPublicar = @Nom_ArchivoPublicar, 
                      Limite = @Limite, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Caja = @Cod_Caja)
                     AND (Item = @Item);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_I;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_I @Des_Inventario     VARCHAR(512), 
                                      @Cod_TipoInventario VARCHAR(5), 
                                      @Obs_Inventario     VARCHAR(1024), 
                                      @Cod_Almacen        VARCHAR(32), 
                                      @Cod_Usuario        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Inventario INT=
        (
            SELECT TOP 1 Id_Inventario
            FROM ALM_INVENTARIO
            WHERE Cod_TipoInventario = @Cod_TipoInventario
                  AND Cod_Almacen = @Cod_Almacen
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM ALM_INVENTARIO
            WHERE(Id_Inventario = @Id_Inventario)
        )
            BEGIN
                INSERT INTO ALM_INVENTARIO
                VALUES
                (@Des_Inventario, 
                 @Cod_TipoInventario, 
                 @Obs_Inventario, 
                 @Cod_Almacen, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_Inventario = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE ALM_INVENTARIO
                  SET 
                      Des_Inventario = @Des_Inventario, 
                      Cod_TipoInventario = @Cod_TipoInventario, 
                      Obs_Inventario = @Obs_Inventario, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Inventario = @Id_Inventario);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_D_I;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_D_I @Cod_TipoInventario  VARCHAR(5), 
                                        @Cod_Almacen         VARCHAR(32), 
                                        @Item                VARCHAR(32), 
                                        @Cod_Producto        VARCHAR(15), 
                                        @Cod_UnidadMedida    VARCHAR(5), 
                                        @Cantidad_Sistema    NUMERIC(38, 6), 
                                        @Cantidad_Encontrada NUMERIC(38, 6), 
                                        @Obs_InventarioD     VARCHAR(1024), 
                                        @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Inventario INT=
        (
            SELECT TOP 1 Id_Inventario
            FROM ALM_INVENTARIO
            WHERE Cod_TipoInventario = @Cod_TipoInventario
                  AND Cod_Almacen = @Cod_Almacen
        );
        DECLARE @Id_Producto INT=
        (
            SELECT TOP 1 Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM ALM_INVENTARIO_D
            WHERE(Id_Inventario = @Id_Inventario)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO ALM_INVENTARIO_D
                VALUES
                (@Id_Inventario, 
                 @Item, 
                 @Id_Producto, 
                 @Cod_UnidadMedida, 
                 @Cod_Almacen, 
                 @Cantidad_Sistema, 
                 @Cantidad_Encontrada, 
                 @Obs_InventarioD, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE ALM_INVENTARIO_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cantidad_Sistema = @Cantidad_Sistema, 
                      Cantidad_Encontrada = @Cantidad_Encontrada, 
                      Obs_InventarioD = @Obs_InventarioD, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Inventario = @Id_Inventario)
                     AND (Item = @Item);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJAS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJAS_I;
GO
CREATE PROCEDURE USP_CAJ_CAJAS_I @Cod_Caja           VARCHAR(32), 
                                 @Des_Caja           VARCHAR(512), 
                                 @Cod_Sucursal       VARCHAR(32), 
                                 @Cod_UsuarioCajero  VARCHAR(32), 
                                 @Cod_CuentaContable VARCHAR(16), 
                                 @Flag_Activo        BIT, 
                                 @Cod_Usuario        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_Caja
            FROM CAJ_CAJAS
            WHERE(Cod_Caja = @Cod_Caja)
        )
            BEGIN
                INSERT INTO CAJ_CAJAS
                VALUES
                (@Cod_Caja, 
                 @Des_Caja, 
                 @Cod_Sucursal, 
                 @Cod_UsuarioCajero, 
                 @Cod_CuentaContable, 
                 @Flag_Activo, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_CAJAS
                  SET 
                      Des_Caja = @Des_Caja, 
                      Cod_Sucursal = @Cod_Sucursal, 
                      Cod_UsuarioCajero = @Cod_UsuarioCajero, 
                      Cod_CuentaContable = @Cod_CuentaContable, 
                      Flag_Activo = @Flag_Activo, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Caja = @Cod_Caja);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_I;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_I @Cod_Almacen      VARCHAR(32), 
                                   @Des_Almacen      VARCHAR(512), 
                                   @Des_CortaAlmacen VARCHAR(64), 
                                   @Cod_TipoAlmacen  VARCHAR(5), 
                                   @Flag_Principal   BIT, 
                                   @Cod_Usuario      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM ALM_ALMACEN
            WHERE(Cod_Almacen = @Cod_Almacen)
        )
            BEGIN
                INSERT INTO ALM_ALMACEN
                VALUES
                (@Cod_Almacen, 
                 @Des_Almacen, 
                 @Des_CortaAlmacen, 
                 @Cod_TipoAlmacen, 
                 @Flag_Principal, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE ALM_ALMACEN
                  SET 
                      Des_Almacen = @Des_Almacen, 
                      Des_CortaAlmacen = @Des_CortaAlmacen, 
                      Cod_TipoAlmacen = @Cod_TipoAlmacen, 
                      Flag_Principal = @Flag_Principal, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Almacen = @Cod_Almacen);
        END;
    END;
GO

-- Importar Productos
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_I;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_I @Cod_Producto         VARCHAR(64), 
                                     @Cod_Categoria        VARCHAR(32), 
                                     @Cod_Marca            VARCHAR(32), 
                                     @Cod_TipoProducto     VARCHAR(5), 
                                     @Nom_Producto         VARCHAR(512), 
                                     @Des_CortaProducto    VARCHAR(512), 
                                     @Des_LargaProducto    VARCHAR(1024), 
                                     @Caracteristicas      VARCHAR(MAX), 
                                     @Porcentaje_Utilidad  NUMERIC(5, 2), 
                                     @Cuenta_Contable      VARCHAR(16), 
                                     @Contra_Cuenta        VARCHAR(16), 
                                     @Cod_Garantia         VARCHAR(5), 
                                     @Cod_TipoExistencia   VARCHAR(5), 
                                     @Cod_TipoOperatividad VARCHAR(5), 
                                     @Flag_Activo          BIT, 
                                     @Flag_Stock           BIT, 
                                     @Cod_Fabricante       VARCHAR(64), 
                                     @Obs_Producto         XML, 
                                     @Cod_ProductoSunat    VARCHAR(64), 
                                     @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_PRODUCTOS
            WHERE(Cod_Producto = @Cod_Producto)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTOS
                VALUES
                (@Cod_Producto, 
                 @Cod_Categoria, 
                 @Cod_Marca, 
                 @Cod_TipoProducto, 
                 @Nom_Producto, 
                 @Des_CortaProducto, 
                 @Des_LargaProducto, 
                 @Caracteristicas, 
                 @Porcentaje_Utilidad, 
                 @Cuenta_Contable, 
                 @Contra_Cuenta, 
                 @Cod_Garantia, 
                 @Cod_TipoExistencia, 
                 @Cod_TipoOperatividad, 
                 @Flag_Activo, 
                 @Flag_Stock, 
                 @Cod_Fabricante, 
                 @Obs_Producto, 
				 @Cod_ProductoSunat,
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTOS
                  SET 
                      Cod_Producto = @Cod_Producto, 
                      Cod_Categoria = @Cod_Categoria, 
                      Cod_Marca = @Cod_Marca, 
                      Cod_TipoProducto = @Cod_TipoProducto, 
                      Nom_Producto = @Nom_Producto, 
                      Des_CortaProducto = @Des_CortaProducto, 
                      Des_LargaProducto = @Des_LargaProducto, 
                      Caracteristicas = @Caracteristicas, 
                      Porcentaje_Utilidad = @Porcentaje_Utilidad, 
                      Cuenta_Contable = @Cuenta_Contable, 
                      Contra_Cuenta = @Contra_Cuenta, 
                      Cod_Garantia = @Cod_Garantia, 
                      Cod_TipoExistencia = @Cod_TipoExistencia, 
                      Cod_TipoOperatividad = @Cod_TipoOperatividad, 
                      Flag_Activo = @Flag_Activo, 
                      Flag_Stock = @Flag_Stock, 
                      Cod_Fabricante = @Cod_Fabricante, 
                      Obs_Producto = @Obs_Producto, 
					  Cod_ProductoSunat = @Cod_ProductoSunat,
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Producto = @Cod_Producto);
        END;
    END;
GO

-- Importar producto stock
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_I;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_I @Cod_Producto        VARCHAR(64), 
                                          @Cod_UnidadMedida    VARCHAR(5), 
                                          @Cod_Almacen         VARCHAR(32), 
                                          @Cod_Moneda          VARCHAR(5), 
                                          @Precio_Compra       NUMERIC(38, 6), 
                                          @Precio_Venta        NUMERIC(38, 6), 
                                          @Stock_Min           NUMERIC(38, 6), 
                                          @Stock_Max           NUMERIC(38, 6), 
                                          @Stock_Act           NUMERIC(38, 6), 
                                          @Cod_UnidadMedidaMin VARCHAR(5), 
                                          @Precio_Flete        NUMERIC(38, 6), 
                                          @Peso                NUMERIC(38, 6), 
                                          @Cantidad_Min        NUMERIC(38, 6), 
                                          @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Producto INT=
        (
            SELECT TOP 1 Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_PRODUCTO_STOCK
            WHERE(Id_Producto = @Id_Producto)
                 AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                 AND (Cod_Almacen = @Cod_Almacen)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_STOCK
                VALUES
                (@Id_Producto, 
                 @Cod_UnidadMedida, 
                 @Cod_Almacen, 
                 @Cod_Moneda, 
                 @Precio_Compra, 
                 @Precio_Venta, 
                 @Stock_Min, 
                 @Stock_Max, 
                 @Stock_Act, 
                 @Cod_UnidadMedidaMin, 
                 @Cantidad_Min, 
                 @Precio_Flete, 
                 @Peso, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTO_STOCK
                  SET 
                      Cod_Moneda = @Cod_Moneda, 
                      Precio_Compra = @Precio_Compra, 
                      Precio_Venta = @Precio_Venta, 
                      Stock_Min = @Stock_Min, 
                      Stock_Max = @Stock_Max, 
                      Stock_Act = @Stock_Act, 
                      Cod_UnidadMedidaMin = @Cod_UnidadMedidaMin, 
                      Cantidad_Min = @Cantidad_Min, 
                      Precio_Flete = @Precio_Flete, 
                      Peso = @Peso, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                     AND (Cod_Almacen = @Cod_Almacen);
        END;
    END;
GO

-- Importar producto precio
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_PRECIO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_I;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_I @Cod_Producto     VARCHAR(64), 
                                           @Cod_UnidadMedida VARCHAR(5), 
                                           @Cod_Almacen      VARCHAR(32), 
                                           @Cod_TipoPrecio   VARCHAR(5), 
                                           @Valor            NUMERIC(38, 6), 
                                           @Cod_Usuario      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Producto INT=
        (
            SELECT TOP 1 Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_PRODUCTO_PRECIO
            WHERE(Id_Producto = @Id_Producto)
                 AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                 AND (Cod_Almacen = @Cod_Almacen)
                 AND (Cod_TipoPrecio = @Cod_TipoPrecio)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_PRECIO
                VALUES
                (@Id_Producto, 
                 @Cod_UnidadMedida, 
                 @Cod_Almacen, 
                 @Cod_TipoPrecio, 
                 @Valor, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTO_PRECIO
                  SET 
                      Valor = @Valor, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                     AND (Cod_Almacen = @Cod_Almacen)
                     AND (Cod_TipoPrecio = @Cod_TipoPrecio);
        END;
    END;
GO

-- Importar producto detalle
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_DETALLE_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_I;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_I @Cod_Producto     INT, 
                                            @Item_Detalle     INT, 
                                            @Cod_TipoDetalle  VARCHAR(5), 
                                            @Cantidad         NUMERIC(38, 6), 
                                            @Cod_UnidadMedida VARCHAR(5), 
                                            @Cod_Usuario      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Producto INT=
        (
            SELECT TOP 1 Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        DECLARE @Id_ProductoDetalle INT=
        (
            SELECT Id_ProductoDetalle
            FROM PRI_PRODUCTO_DETALLE
            WHERE Id_Producto = @Id_Producto
                  AND Item_Detalle = @Item_Detalle
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_PRODUCTO_DETALLE
            WHERE(Id_Producto = @Id_Producto)
                 AND (Item_Detalle = @Item_Detalle)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_DETALLE
                VALUES
                (@Id_Producto, 
                 @Item_Detalle, 
                 @Id_ProductoDetalle, 
                 @Cod_TipoDetalle, 
                 @Cantidad, 
                 @Cod_UnidadMedida, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTO_DETALLE
                  SET 
                      Id_ProductoDetalle = @Id_ProductoDetalle, 
                      Cod_TipoDetalle = @Cod_TipoDetalle, 
                      Cantidad = @Cantidad, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Item_Detalle = @Item_Detalle);
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_I;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_I @Cod_Tasa     VARCHAR(32), 
                                         @Cod_Producto VARCHAR(32), 
                                         @Cod_Libro    VARCHAR(2), 
                                         @Des_Tasa     VARCHAR(512), 
                                         @Por_Tasa     NUMERIC(10, 4), 
                                         @Cod_TipoTasa VARCHAR(8), 
                                         @Flag_Activo  BIT, 
                                         @Obs_Tasa     VARCHAR(1024), 
                                         @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Producto INT;
        SET @Id_Producto =
        (
            SELECT Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT *
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
                      Flag_Activo = @Flag_Activo, 
                      Obs_Tasa = @Obs_Tasa, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_Tasa = @Cod_Tasa);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_I @Cod_TipoDocumento    VARCHAR(3), 
                                             @Nro_Documento        VARCHAR(32), 
                                             @Cliente              VARCHAR(512), 
                                             @Ap_Paterno           VARCHAR(128), 
                                             @Ap_Materno           VARCHAR(128), 
                                             @Nombres              VARCHAR(128), 
                                             @Direccion            VARCHAR(512), 
                                             @Cod_EstadoCliente    VARCHAR(3), 
                                             @Cod_CondicionCliente VARCHAR(3), 
                                             @Cod_TipoCliente      VARCHAR(3), 
                                             @RUC_Natural          VARCHAR(32), 
                                             @Foto                 VARBINARY(MAX), 
                                             @Firma                VARBINARY(MAX), 
                                             @Cod_TipoComprobante  VARCHAR(5), 
                                             @Cod_Nacionalidad     VARCHAR(8), 
                                             @Fecha_Nacimiento     VARCHAR(32), 
                                             @Cod_Sexo             VARCHAR(3), 
                                             @Email1               VARCHAR(1024), 
                                             @Email2               VARCHAR(1024), 
                                             @Telefono1            VARCHAR(512), 
                                             @Telefono2            VARCHAR(512), 
                                             @Fax                  VARCHAR(512), 
                                             @PaginaWeb            VARCHAR(512), 
                                             @Cod_Ubigeo           VARCHAR(8), 
                                             @Cod_FormaPago        VARCHAR(3), 
                                             @Limite_Credito       NUMERIC(38, 2), 
                                             @Obs_Cliente          XML, 
                                             @Num_DiaCredito       INT, 
                                             @Ubicacion_EjeX       NUMERIC(38, 6), 
                                             @Ubicacion_EjeY       NUMERIC(38, 6), 
                                             @Ruta                 VARCHAR(2048), 
                                             @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT;
        SET @Id_ClienteProveedor =
        (
            SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_PROVEEDOR
                VALUES
                (@Cod_TipoDocumento, 
                 @Nro_Documento, 
                 @Cliente, 
                 @Ap_Paterno, 
                 @Ap_Materno, 
                 @Nombres, 
                 @Direccion, 
                 @Cod_EstadoCliente, 
                 @Cod_CondicionCliente, 
                 @Cod_TipoCliente, 
                 @RUC_Natural, 
                 @Foto, 
                 @Firma, 
                 @Cod_TipoComprobante, 
                 @Cod_Nacionalidad, 
                 CONVERT(DATETIME, @Fecha_Nacimiento, 121), 
                 @Cod_Sexo, 
                 @Email1, 
                 @Email2, 
                 @Telefono1, 
                 @Telefono2, 
                 @Fax, 
                 @PaginaWeb, 
                 @Cod_Ubigeo, 
                 @Cod_FormaPago, 
                 @Limite_Credito, 
                 @Obs_Cliente, 
                 @Num_DiaCredito, 
				 @Ubicacion_EjeX,
				 @Ubicacion_EjeY,
				 @Ruta,
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_ClienteProveedor = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_PROVEEDOR
                  SET 
                      Cod_TipoDocumento = @Cod_TipoDocumento, 
                      Nro_Documento = @Nro_Documento, 
                      Cliente = @Cliente, 
                      Ap_Paterno = @Ap_Paterno, 
                      Ap_Materno = @Ap_Materno, 
                      Nombres = @Nombres, 
                      Direccion = @Direccion, 
                      Cod_EstadoCliente = @Cod_EstadoCliente, 
                      Cod_CondicionCliente = @Cod_CondicionCliente, 
                      Cod_TipoCliente = @Cod_TipoCliente, 
                      RUC_Natural = @RUC_Natural, 
                      Foto = @Foto, 
                      Firma = @Firma, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Cod_Nacionalidad = @Cod_Nacionalidad, 
                      Fecha_Nacimiento = CONVERT(DATETIME, @Fecha_Nacimiento, 121), 
                      Cod_Sexo = @Cod_Sexo, 
                      Email1 = @Email1, 
                      Email2 = @Email2, 
                      Telefono1 = @Telefono1, 
                      Telefono2 = @Telefono2, 
                      Fax = @Fax, 
                      PaginaWeb = @PaginaWeb, 
                      Cod_Ubigeo = @Cod_Ubigeo, 
                      Cod_FormaPago = @Cod_FormaPago, 
                      Limite_Credito = @Limite_Credito, 
                      Obs_Cliente = @Obs_Cliente, 
                      Num_DiaCredito = @Num_DiaCredito, 
					  Ubicacion_EjeX = @Ubicacion_EjeX,
					  Ubicacion_EjeY = @Ubicacion_EjeY,
					  Ruta = @Ruta,
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor);
        END;
    END;
GO

-- Importar turno atencioon
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_TURNO_ATENCION_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_TURNO_ATENCION_I;
GO
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_I @Cod_Turno    VARCHAR(32), 
                                          @Des_Turno    VARCHAR(512), 
                                          @Fecha_Inicio VARCHAR(32), 
                                          @Fecha_Fin    VARCHAR(32), 
                                          @Flag_Cerrado BIT, 
                                          @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_TURNO_ATENCION
            WHERE(Cod_Turno = @Cod_Turno)
        )
            BEGIN
                INSERT INTO CAJ_TURNO_ATENCION
                VALUES
                (@Cod_Turno, 
                 @Des_Turno, 
                 CONVERT(DATETIME, @Fecha_Inicio, 121), 
                 CONVERT(DATETIME, @Fecha_Fin, 121), 
                 @Flag_Cerrado, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_TURNO_ATENCION
                  SET 
                      Des_Turno = @Des_Turno, 
                      Fecha_Inicio = CONVERT(DATETIME, @Fecha_Inicio, 121), 
                      Fecha_Fin = CONVERT(DATETIME, @Fecha_Fin, 121), 
                      Flag_Cerrado = @Flag_Cerrado, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Turno = @Cod_Turno);
        END;
    END;
GO

-- Importar caj_medicion_vc
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_MEDICION_VC_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_MEDICION_VC_I;
GO
CREATE PROCEDURE USP_CAJ_MEDICION_VC_I @Cod_AMedir          VARCHAR(32), 
                                       @Medio_AMedir        VARCHAR(32), 
                                       @Medida_Anterior     NUMERIC(38, 4), 
                                       @Medida_Actual       NUMERIC(38, 4), 
                                       @Fecha_Medicion      VARCHAR(32), 
                                       @Cod_Turno           VARCHAR(32), 
                                       @Cod_UsuarioMedicion VARCHAR(32), 
                                       @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_MEDICION_VC
            WHERE(Cod_AMedir = @Cod_AMedir)
                 AND (Medio_AMedir = @Medio_AMedir)
                 AND Cod_Turno = @Cod_Turno
        )
            BEGIN
                INSERT INTO CAJ_MEDICION_VC
                VALUES
                (@Cod_AMedir, 
                 @Medio_AMedir, 
                 @Medida_Anterior, 
                 @Medida_Actual, 
                 CONVERT(DATETIME, @Fecha_Medicion, 121), 
                 @Cod_Turno, 
                 @Cod_UsuarioMedicion, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_MEDICION_VC
                  SET 
                      Cod_AMedir = @Cod_AMedir, 
                      Medio_AMedir = @Medio_AMedir, 
                      Medida_Anterior = @Medida_Anterior, 
                      Medida_Actual = @Medida_Actual, 
                      Fecha_Medicion = CONVERT(DATETIME, @Fecha_Medicion, 121), 
                      Cod_Turno = @Cod_Turno, 
                      Cod_UsuarioMedicion = @Cod_UsuarioMedicion, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_AMedir = @Cod_AMedir)
                     AND (Medio_AMedir = @Medio_AMedir)
                     AND Cod_Turno = @Cod_Turno;
        END;
    END;
GO

-- Importar arqueo fisico
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_I;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_I @Cod_Caja         VARCHAR(32), 
                                        @Cod_Turno        VARCHAR(32), 
                                        @Numero           INT, 
                                        @Des_ArqueoFisico VARCHAR(512), 
                                        @Obs_ArqueoFisico VARCHAR(1024), 
                                        @Fecha            VARCHAR(32), 
                                        @Flag_Cerrado     BIT, 
                                        @Cod_Usuario      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ArqueoFisico INT=
        (
            SELECT id_ArqueoFisico
            FROM CAJ_ARQUEOFISICO
            WHERE(Cod_Caja = @Cod_Caja)
                 AND (Cod_Turno = @Cod_Turno)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_ARQUEOFISICO
            WHERE(id_ArqueoFisico = @id_ArqueoFisico)
        )
            BEGIN
                INSERT INTO CAJ_ARQUEOFISICO
                VALUES
                (@Cod_Caja, 
                 @Cod_Turno, 
                 @Numero, 
                 @Des_ArqueoFisico, 
                 @Obs_ArqueoFisico, 
                 CONVERT(DATETIME, @Fecha, 121), 
                 @Flag_Cerrado, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_ARQUEOFISICO
                  SET 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Numero = @Numero, 
                      Des_ArqueoFisico = @Des_ArqueoFisico, 
                      Obs_ArqueoFisico = @Obs_ArqueoFisico, 
                      Fecha = CONVERT(DATETIME, @Fecha, 121), 
                      Flag_Cerrado = @Flag_Cerrado, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ArqueoFisico = @id_ArqueoFisico);
        END;
    END;
GO

-- importar Arqueo fisico Detalle
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D_I;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D_I @Cod_Caja    VARCHAR(32), 
                                          @Cod_Turno   VARCHAR(32), 
                                          @Cod_Billete VARCHAR(3), 
                                          @Cantidad    INT, 
                                          @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ArqueoFisico INT=
        (
            SELECT id_ArqueoFisico
            FROM CAJ_ARQUEOFISICO
            WHERE(Cod_Caja = @Cod_Caja)
                 AND (Cod_Turno = @Cod_Turno)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_ARQUEOFISICO_D
            WHERE(id_ArqueoFisico = @id_ArqueoFisico)
                 AND (Cod_Billete = @Cod_Billete)
        )
            BEGIN
                INSERT INTO CAJ_ARQUEOFISICO_D
                VALUES
                (@id_ArqueoFisico, 
                 @Cod_Billete, 
                 @Cantidad, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_ARQUEOFISICO_D
                  SET 
                      Cantidad = @Cantidad, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ArqueoFisico = @id_ArqueoFisico)
                     AND (Cod_Billete = @Cod_Billete);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_SALDO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_I;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_I @Cod_Caja    VARCHAR(32), 
                                              @Cod_Turno   VARCHAR(32), 
                                              @Cod_Moneda  VARCHAR(3), 
                                              @Tipo        VARCHAR(32), 
                                              @Monto       NUMERIC(38, 2), 
                                              @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ArqueoFisico INT=
        (
            SELECT TOP 1 id_ArqueoFisico
            FROM CAJ_ARQUEOFISICO
            WHERE(Cod_Caja = @Cod_Caja)
                 AND (Cod_Turno = @Cod_Turno)
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_ARQUEOFISICO_SALDO
            WHERE(id_ArqueoFisico = @id_ArqueoFisico)
                 AND (Cod_Moneda = @Cod_Moneda)
                 AND (Tipo = @Tipo)
        )
            BEGIN
                INSERT INTO CAJ_ARQUEOFISICO_SALDO
                VALUES
                (@id_ArqueoFisico, 
                 @Cod_Moneda, 
                 @Tipo, 
                 @Monto, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_ARQUEOFISICO_SALDO
                  SET 
                      Monto = @Monto, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ArqueoFisico = @id_ArqueoFisico)
                     AND (Cod_Moneda = @Cod_Moneda)
                     AND (Tipo = @Tipo);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_LICITACIONES_I;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_I @Cod_TipoDocumento   INT, 
                                        @Nro_Documento       VARCHAR(32), 
                                        @Cod_Licitacion      VARCHAR(32), 
                                        @Des_Licitacion      VARCHAR(512), 
                                        @Cod_TipoLicitacion  VARCHAR(5), 
                                        @Nro_Licitacion      VARCHAR(16), 
                                        @Fecha_Inicio        VARCHAR(32), 
                                        @Fecha_Facturacion   VARCHAR(32), 
                                        @Flag_AlFinal        BIT, 
                                        @Cod_TipoComprobante VARCHAR(5), 
                                        @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_LICITACIONES
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (Cod_Licitacion = @Cod_Licitacion)
        )
            BEGIN
                INSERT INTO PRI_LICITACIONES
                VALUES
                (@Id_ClienteProveedor, 
                 @Cod_Licitacion, 
                 @Des_Licitacion, 
                 @Cod_TipoLicitacion, 
                 @Nro_Licitacion, 
                 CONVERT(DATETIME, @Fecha_Inicio, 121), 
                 CONVERT(DATETIME, @Fecha_Facturacion, 121), 
                 @Flag_AlFinal, 
                 @Cod_TipoComprobante, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_LICITACIONES
                  SET 
                      Des_Licitacion = @Des_Licitacion, 
                      Cod_TipoLicitacion = @Cod_TipoLicitacion, 
                      Nro_Licitacion = @Nro_Licitacion, 
                      Fecha_Inicio = CONVERT(DATETIME, @Fecha_Inicio, 121), 
                      Fecha_Facturacion = CONVERT(DATETIME, @Fecha_Facturacion, 121), 
                      Flag_AlFinal = @Flag_AlFinal, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (Cod_Licitacion = @Cod_Licitacion);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_LICITACIONES_D_I;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_D_I @Cod_TipoDocumento INT, 
                                          @Nro_Documento     VARCHAR(32), 
                                          @Cod_Licitacion    VARCHAR(32), 
                                          @Nro_Detalle       INT, 
                                          @Cod_Producto      VARCHAR(32), 
                                          @Cantidad          NUMERIC(38, 2), 
                                          @Cod_UnidadMedida  VARCHAR(5), 
                                          @Descripcion       VARCHAR(512), 
                                          @Precio_Unitario   NUMERIC(38, 6), 
                                          @Por_Descuento     NUMERIC(5, 2), 
                                          @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @Nro_Documento
        );
        DECLARE @Id_Producto INT=
        (
            SELECT Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT @Id_ClienteProveedor, 
                   @Cod_Licitacion, 
                   @Nro_Detalle
            FROM PRI_LICITACIONES_D
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (Cod_Licitacion = @Cod_Licitacion)
                 AND (Nro_Detalle = @Nro_Detalle)
        )
            BEGIN
                INSERT INTO PRI_LICITACIONES_D
                VALUES
                (@Id_ClienteProveedor, 
                 @Cod_Licitacion, 
                 @Nro_Detalle, 
                 @Id_Producto, 
                 @Cantidad, 
                 @Cod_UnidadMedida, 
                 @Descripcion, 
                 @Precio_Unitario, 
                 @Por_Descuento, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_LICITACIONES_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Cantidad = @Cantidad, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Descripcion = @Descripcion, 
                      Precio_Unitario = @Precio_Unitario, 
                      Por_Descuento = @Por_Descuento, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (Cod_Licitacion = @Cod_Licitacion)
                     AND (Nro_Detalle = @Nro_Detalle);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CONCEPTO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CONCEPTO_I;
GO
CREATE PROCEDURE USP_CAJ_CONCEPTO_I @Id_Concepto       INT, 
                                    @Des_Concepto      VARCHAR(512), 
                                    @Cod_ClaseConcepto VARCHAR(3), 
                                    @Flag_Activo       BIT, 
                                    @Id_ConceptoPadre  INT, 
                                    @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Id_Concepto
            FROM CAJ_CONCEPTO
            WHERE(Id_Concepto = @Id_Concepto)
        )
            BEGIN
                INSERT INTO CAJ_CONCEPTO
                VALUES
                (@Id_Concepto, 
                 @Des_Concepto, 
                 @Cod_ClaseConcepto, 
                 @Flag_Activo, 
                 @Id_ConceptoPadre, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_CONCEPTO
                  SET 
                      Des_Concepto = @Des_Concepto, 
                      Cod_ClaseConcepto = @Cod_ClaseConcepto, 
                      Flag_Activo = @Flag_Activo, 
                      Id_ConceptoPadre = @Id_ConceptoPadre, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Concepto = @Id_Concepto);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I;
GO
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I @Cod_Caja            VARCHAR(32), 
                                            @Cod_Turno           VARCHAR(32), 
                                            @Id_Concepto         INT, 
                                            @Cod_TipoDocumento   VARCHAR(10), 
                                            @DocCliente          VARCHAR(512), 
                                            @Des_Movimiento      VARCHAR(512), 
                                            @Cod_TipoComprobante VARCHAR(5), 
                                            @Serie               VARCHAR(4), 
                                            @Numero              VARCHAR(20), 
                                            @Fecha               VARCHAR(32), 
                                            @Tipo_Cambio         NUMERIC(10, 4), 
                                            @Ingreso             NUMERIC(38, 2), 
                                            @Cod_MonedaIng       VARCHAR(3), 
                                            @Egreso              NUMERIC(38, 2), 
                                            @Cod_MonedaEgr       VARCHAR(3), 
                                            @Flag_Extornado      BIT, 
                                            @Cod_UsuarioAut      VARCHAR(32), 
                                            @Fecha_Aut           VARCHAR(32), 
                                            @Obs_Movimiento      XML, 
                                            @Id_MovimientoRef    INT, 
                                            @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocumento
                  AND Nro_Documento = @DocCliente
        );
        DECLARE @Nom_Cliente VARCHAR(MAX)=
        (
            SELECT Nombres
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Id_ClienteProveedor = @Id_ClienteProveedor
        );
        DECLARE @id_Movimiento INT=
        (
            SELECT id_Movimiento
            FROM CAJ_CAJA_MOVIMIENTOS
            WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
                  AND Cod_Caja = @Cod_Caja
                  AND Cod_Turno = @Cod_Turno
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_CAJA_MOVIMIENTOS
            WHERE(id_Movimiento = @id_Movimiento)
        )
            BEGIN
                INSERT INTO CAJ_CAJA_MOVIMIENTOS
                VALUES
                (@Cod_Caja, 
                 @Cod_Turno, 
                 @Id_Concepto, 
                 @Id_ClienteProveedor, 
                 @Nom_Cliente, 
                 @Des_Movimiento, 
                 @Cod_TipoComprobante, 
                 @Serie, 
                 @Numero, 
                 CONVERT(DATETIME, @Fecha, 121), 
                 @Tipo_Cambio, 
                 @Ingreso, 
                 @Cod_MonedaIng, 
                 @Egreso, 
                 @Cod_MonedaEgr, 
                 @Flag_Extornado, 
                 @Cod_UsuarioAut, 
                 CONVERT(DATETIME, @Fecha_Aut, 121), 
                 @Obs_Movimiento, 
                 @Id_MovimientoRef, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_CAJA_MOVIMIENTOS
                  SET 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Id_Concepto = @Id_Concepto, 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Cliente = @Nom_Cliente, 
                      Des_Movimiento = @Des_Movimiento, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Serie = @Serie, 
                      Numero = @Numero, 
                      Fecha = CONVERT(DATETIME, @Fecha, 121), 
                      Tipo_Cambio = @Tipo_Cambio, 
                      Ingreso = @Ingreso, 
                      Cod_MonedaIng = @Cod_MonedaIng, 
                      Egreso = @Egreso, 
                      Cod_MonedaEgr = @Cod_MonedaEgr, 
                      Flag_Extornado = @Flag_Extornado, 
                      Cod_UsuarioAut = @Cod_UsuarioAut, 
                      Fecha_Aut = CONVERT(DATETIME, @Fecha_Aut, 121), 
                      Obs_Movimiento = @Obs_Movimiento, 
                      Id_MovimientoRef = @Id_MovimientoRef, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_Movimiento = @id_Movimiento);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I @Cod_Libro              VARCHAR(2), 
                                            @Cod_Periodo            VARCHAR(8), 
                                            @Cod_Caja               VARCHAR(32), 
                                            @Cod_Turno              VARCHAR(32), 
                                            @Cod_TipoOperacion      VARCHAR(5), 
                                            @Cod_TipoComprobante    VARCHAR(5), 
                                            @Serie                  VARCHAR(5), 
                                            @Numero                 VARCHAR(30), 
                                            @Cod_TipoDoc            VARCHAR(2), 
                                            @Doc_Cliente            VARCHAR(20), 
                                            @Nom_Cliente            VARCHAR(512), 
                                            @Direccion_Cliente      VARCHAR(512), 
                                            @FechaEmision           VARCHAR(32), 
                                            @FechaVencimiento       VARCHAR(32), 
                                            @FechaCancelacion       VARCHAR(32), 
                                            @Glosa                  VARCHAR(512), 
                                            @TipoCambio             NUMERIC(10, 4), 
                                            @Flag_Anulado           BIT, 
                                            @Flag_Despachado        BIT, 
                                            @Cod_FormaPago          VARCHAR(5), 
                                            @Descuento_Total        NUMERIC(38, 2), 
                                            @Cod_Moneda             VARCHAR(3), 
                                            @Impuesto               NUMERIC(38, 6), 
                                            @Total                  NUMERIC(38, 2), 
                                            @Obs_Comprobante        XML, 
                                            @Id_GuiaRemision        INT, 
                                            @GuiaRemision           VARCHAR(50), 
                                            @Cod_LibroRef           VARCHAR(2), 
                                            @Cod_TipoComprobanteRef VARCHAR(5), 
                                            @SerieRef               VARCHAR(5), 
                                            @NumeroRef              VARCHAR(30), 
                                            @Cod_Plantilla          VARCHAR(32), 
                                            @Nro_Ticketera          VARCHAR(64), 
                                            @Cod_UsuarioVendedor    VARCHAR(32), 
                                            @Cod_RegimenPercepcion  VARCHAR(8), 
                                            @Tasa_Percepcion        NUMERIC(38, 2), 
                                            @Placa_Vehiculo         VARCHAR(64), 
                                            @Cod_TipoDocReferencia  VARCHAR(8), 
                                            @Nro_DocReferencia      VARCHAR(64), 
                                            @Valor_Resumen          VARCHAR(1024), 
                                            @Valor_Firma            VARCHAR(2048), 
                                            @Cod_EstadoComprobante  VARCHAR(8), 
                                            @MotivoAnulacion        VARCHAR(512), 
                                            @Otros_Cargos           NUMERIC(38, 2), 
                                            @Otros_Tributos         NUMERIC(38, 2), 
                                            @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_Cliente INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDoc
                  AND Nro_Documento = @Doc_Cliente
        );
        DECLARE @id_ComprobantePago INT=
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        DECLARE @id_ComprobanteRef INT=
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_LibroRef
                  AND Cod_TipoComprobante = @Cod_TipoComprobanteRef
                  AND Serie = @SerieRef
                  AND Numero = @NumeroRef
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE(id_ComprobantePago = @id_ComprobantePago)
        )
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_PAGO
                VALUES
                (@Cod_Libro, 
                 @Cod_Periodo, 
                 @Cod_Caja, 
                 @Cod_Turno, 
                 @Cod_TipoOperacion, 
                 @Cod_TipoComprobante, 
                 @Serie, 
                 @Numero, 
                 @Id_Cliente, 
                 @Cod_TipoDoc, 
                 @Doc_Cliente, 
                 @Nom_Cliente, 
                 @Direccion_Cliente, 
                 CONVERT(DATETIME, @FechaEmision, 121), 
                 CONVERT(DATETIME, @FechaVencimiento, 121), 
                 CONVERT(DATETIME, @FechaCancelacion, 121), 
                 @Glosa, 
                 @TipoCambio, 
                 @Flag_Anulado, 
                 @Flag_Despachado, 
                 @Cod_FormaPago, 
                 @Descuento_Total, 
                 @Cod_Moneda, 
                 @Impuesto, 
                 @Total, 
                 @Obs_Comprobante, 
                 @Id_GuiaRemision, 
                 @GuiaRemision, 
                 @id_ComprobanteRef, 
                 @Cod_Plantilla, 
                 @Nro_Ticketera, 
                 @Cod_UsuarioVendedor, 
                 @Cod_RegimenPercepcion, 
                 @Tasa_Percepcion, 
                 @Placa_Vehiculo, 
                 @Cod_TipoDocReferencia, 
                 @Nro_DocReferencia, 
                 @Valor_Resumen, 
                 @Valor_Firma, 
                 @Cod_EstadoComprobante, 
                 @MotivoAnulacion, 
                 @Otros_Cargos, 
                 @Otros_Tributos, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @id_ComprobantePago = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE CAJ_COMPROBANTE_PAGO
                  SET 
                      Cod_Libro = @Cod_Libro, 
                      Cod_Periodo = @Cod_Periodo, 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Cod_TipoOperacion = @Cod_TipoOperacion, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Serie = @Serie, 
                      Numero = @Numero, 
                      Id_Cliente = @Id_Cliente, 
                      Cod_TipoDoc = @Cod_TipoDoc, 
                      Doc_Cliente = @Doc_Cliente, 
                      Nom_Cliente = @Nom_Cliente, 
                      Direccion_Cliente = @Direccion_Cliente, 
                      FechaEmision = CONVERT(DATETIME, @FechaEmision, 121), 
                      FechaVencimiento = CONVERT(DATETIME, @FechaVencimiento, 121), 
                      FechaCancelacion = CONVERT(DATETIME, @FechaCancelacion, 121), 
                      Glosa = @Glosa, 
                      TipoCambio = @TipoCambio, 
                      Flag_Anulado = @Flag_Anulado, 
                      Flag_Despachado = @Flag_Despachado, 
                      Cod_FormaPago = @Cod_FormaPago, 
                      Descuento_Total = @Descuento_Total, 
                      Cod_Moneda = @Cod_Moneda, 
                      Impuesto = @Impuesto, 
                      Total = @Total, 
                      Obs_Comprobante = @Obs_Comprobante, 
                      Id_GuiaRemision = @Id_GuiaRemision, 
                      GuiaRemision = @GuiaRemision, 
                      id_ComprobanteRef = @id_ComprobanteRef, 
                      Cod_Plantilla = @Cod_Plantilla, 
                      Nro_Ticketera = @Nro_Ticketera, 
                      Cod_UsuarioVendedor = @Cod_UsuarioVendedor, 
                      Cod_RegimenPercepcion = @Cod_RegimenPercepcion, 
                      Tasa_Percepcion = @Tasa_Percepcion, 
                      Placa_Vehiculo = @Placa_Vehiculo, 
                      Cod_TipoDocReferencia = @Cod_TipoDocReferencia, 
                      Nro_DocReferencia = @Nro_DocReferencia, 
                      --Valor_Resumen = @Valor_Resumen, 
                      --Valor_Firma = @Valor_Firma, 
                      --Cod_EstadoComprobante = @Cod_EstadoComprobante, 
                      MotivoAnulacion = @MotivoAnulacion, 
                      Otros_Cargos = @Otros_Cargos, 
                      Otros_Tributos = @Otros_Tributos, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago);
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_I;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_I @Cod_Libro           VARCHAR(4), 
                                         @Cod_TipoComprobante VARCHAR(4), 
                                         @Serie               VARCHAR(5), 
                                         @Numero              VARCHAR(32), 
                                         @Cod_TipoDoc         VARCHAR(4), 
                                         @Doc_Cliente         VARCHAR(32), 
                                         @id_Detalle          INT, 
                                         @Cod_Producto        VARCHAR(32), 
                                         @Cod_AlmaceN         VARCHAR(32), 
                                         @Cantidad            NUMERIC(38, 6), 
                                         @Cod_UnidadMedida    VARCHAR(5), 
                                         @Despachado          NUMERIC(38, 6), 
                                         @DescripcioN         VARCHAR(MAX), 
                                         @PrecioUnitario      NUMERIC(38, 6), 
                                         @Descuento           NUMERIC(38, 2), 
                                         @Sub_Total           NUMERIC(38, 2), 
                                         @Tipo                VARCHAR(256), 
                                         @Obs_ComprobanteD    VARCHAR(1024), 
                                         @Cod_Manguera        VARCHAR(32), 
                                         @Flag_AplicaImpuesto BIT, 
                                         @Formalizado         NUMERIC(38, 6), 
                                         @Valor_NoOneroso     NUMERIC(38, 2), 
                                         @Cod_TipoISC         VARCHAR(8), 
                                         @Porcentaje_ISC      NUMERIC(38, 2), 
                                         @ISC                 NUMERIC(38, 2), 
                                         @Cod_TipoIGV         VARCHAR(8), 
                                         @Porcentaje_IGV      NUMERIC(38, 2), 
                                         @IGV                 NUMERIC(38, 2), 
                                         @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT= 0, @Id_Producto INT;
        SET @id_ComprobantePago =
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        SET @Id_Producto =
        (
            SELECT TOP 1 Id_Producto
            FROM pri_productos
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT @id_ComprobantePago, 
                   @id_Detalle
            FROM CAJ_COMPROBANTE_D
            WHERE(id_ComprobantePago = @id_ComprobantePago)
                 AND (id_Detalle = @id_Detalle)
        )
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_D
                VALUES
                (@id_ComprobantePago, 
                 @id_Detalle, 
                 @Id_Producto, 
                 @Cod_Almacen, 
                 @Cantidad, 
                 @Cod_UnidadMedida, 
                 @Despachado, 
                 @Descripcion, 
                 @PrecioUnitario, 
                 @Descuento, 
                 @Sub_Total, 
                 @Tipo, 
                 @Obs_ComprobanteD, 
                 @Cod_Manguera, 
                 @Flag_AplicaImpuesto, 
                 @Formalizado, 
                 @Valor_NoOneroso, 
                 @Cod_TipoISC, 
                 @Porcentaje_ISC, 
                 @ISC, 
                 @Cod_TipoIGV, 
                 @Porcentaje_IGV, 
                 @IGV, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_COMPROBANTE_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cantidad = @Cantidad, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Despachado = @Despachado, 
                      Descripcion = @Descripcion, 
                      PrecioUnitario = @PrecioUnitario, 
                      Descuento = @Descuento, 
                      Sub_Total = @Sub_Total, 
                      Tipo = @Tipo, 
                      Obs_ComprobanteD = @Obs_ComprobanteD, 
                      Cod_Manguera = @Cod_Manguera, 
                      Flag_AplicaImpuesto = @Flag_AplicaImpuesto, 
                      Formalizado = @Formalizado, 
                      Valor_NoOneroso = @Valor_NoOneroso, 
                      Cod_TipoISC = @Cod_TipoISC, 
                      Porcentaje_ISC = @Porcentaje_ISC, 
                      ISC = @ISC, 
                      Cod_TipoIGV = @Cod_TipoIGV, 
                      Porcentaje_IGV = @Porcentaje_IGV, 
                      IGV = @IGV, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago)
                     AND (id_Detalle = @id_Detalle);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_PAGO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_PAGO_I;
GO
CREATE PROCEDURE USP_CAJ_SERIES_PAGO_I @Cod_TipoComprobante VARCHAR(4), 
                                       @Serie               VARCHAR(5), 
                                       @Numero              VARCHAR(32), 
                                       @Cod_TipoDoc         VARCHAR(4), 
                                       @Doc_Cliente         VARCHAR(32), 
                                       @id_Detalle          INT, 
                                       @Nro_Serie           VARCHAR(512), 
                                       @FechaVencimiento    VARCHAR(32), 
                                       @Obs_Series          VARCHAR(1024), 
                                       @Cantidad            NUMERIC(38, 6), 
                                       @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT=
        (
            SELECT id_ComprobantePago
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
                  AND Cod_TipoDoc = @Cod_TipoDoc
                  AND Doc_Cliente = @Doc_Cliente
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_SERIES
            WHERE(Id_Tabla = @id_ComprobantePago)
                 AND (Item = @id_Detalle)
        )
            BEGIN
                INSERT INTO CAJ_SERIES
                VALUES
                ('CAJ_COMPROBANTE_PAGO', 
                 @id_ComprobantePago, 
                 @id_Detalle, 
                 @Nro_Serie, 
                 CONVERT(DATETIME, @FechaVencimiento, 121), 
                 @Obs_Series, 
                 @Cantidad, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_SERIES
                  SET 
                      Serie = @Serie, 
                      Fecha_Vencimiento = CONVERT(DATETIME, @FechaVencimiento, 121), 
                      Obs_Serie = @Obs_Series, 
                      Cantidad = @Cantidad, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Tabla = @id_ComprobantePago)
                     AND (Item = @id_Detalle);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_MOVIMIENTO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_MOVIMIENTO_I;
GO
CREATE PROCEDURE USP_CAJ_SERIES_MOVIMIENTO_I @Cod_TipoComprobante VARCHAR(4), 
                                             @Serie               VARCHAR(5), 
                                             @Numero              VARCHAR(32), 
                                             @id_Detalle          INT, 
                                             @Nro_Serie           VARCHAR(512), 
                                             @FechaVencimiento    VARCHAR(32), 
                                             @Obs_Series          VARCHAR(1024), 
                                             @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT=
        (
            SELECT id_Movimiento
            FROM CAJ_CAJA_MOVIMIENTOS
            WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM CAJ_SERIES
            WHERE(Id_Tabla = @id_ComprobantePago)
                 AND (Item = @id_Detalle)
        )
            BEGIN
                INSERT INTO CAJ_SERIES
                VALUES
                ('ALM_ALMACEN_MOV', 
                 @id_ComprobantePago, 
                 @id_Detalle, 
                 @Nro_Serie, 
                 CONVERT(DATETIME, @FechaVencimiento, 121), 
                 @Obs_Series, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_SERIES
                  SET 
                      Serie = @Serie, 
                      Fecha_Vencimiento = CONVERT(DATETIME, @FechaVencimiento, 121), 
                      Obs_Serie = @Obs_Series, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Tabla = @id_ComprobantePago)
                     AND (Item = @id_Detalle);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_I;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_I @Cod_Libro            VARCHAR(4), 
                                                @Cod_TipoComprobante  VARCHAR(4), 
                                                @Serie                VARCHAR(5), 
                                                @Numero               VARCHAR(32), 
                                                @Cod_TipoDoc          VARCHAR(4), 
                                                @Doc_Cliente          VARCHAR(32), 
                                                @id_Detalle           INT, 
                                                @Item                 INT, 
                                                @Cod_LibroR           VARCHAR(4), 
                                                @Cod_TipoComprobanteR VARCHAR(4), 
                                                @SerieR               VARCHAR(5), 
                                                @NumeroR              VARCHAR(32), 
                                                @Cod_TipoDocR         VARCHAR(4), 
                                                @Doc_ClienteR         VARCHAR(32), 
                                                @Cod_TipoRelacion     VARCHAR(8), 
                                                @Valor                NUMERIC(38, 6), 
                                                @Obs_Relacion         VARCHAR(1024), 
                                                @Id_DetalleRelacion   INT, 
                                                @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT= 0;
        SET @id_ComprobantePago =
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        DECLARE @id_ComprobanteRelacion INT= 0;
        SET @id_ComprobanteRelacion =
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_LibroR
                  AND Cod_TipoComprobante = @Cod_TipoComprobanteR
                  AND Serie = @SerieR
                  AND Numero = @NumeroR
        );
        IF NOT EXISTS
        (
            SELECT @id_ComprobantePago, 
                   @id_Detalle, 
                   @Item
            FROM CAJ_COMPROBANTE_RELACION
            WHERE(id_ComprobantePago = @id_ComprobantePago)
                 AND (id_Detalle = @id_Detalle)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_RELACION
                VALUES
                (@id_ComprobantePago, 
                 @id_Detalle, 
                 @Item, 
                 @Id_ComprobanteRelacion, 
                 @Cod_TipoRelacion, 
                 @Valor, 
                 @Obs_Relacion, 
                 @Id_DetalleRelacion, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                UPDATE CAJ_COMPROBANTE_PAGO
                  SET 
                      id_ComprobanteRef = @id_ComprobanteRelacion
                WHERE id_ComprobantePago = @id_ComprobantePago;
        END;
            ELSE
            BEGIN
                UPDATE CAJ_COMPROBANTE_RELACION
                  SET 
                      Id_ComprobanteRelacion = @Id_ComprobanteRelacion, 
                      Cod_TipoRelacion = @Cod_TipoRelacion, 
                      Valor = @Valor, 
                      Obs_Relacion = @Obs_Relacion, 
                      Id_DetalleRelacion = @Id_DetalleRelacion, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago)
                     AND (id_Detalle = @id_Detalle)
                     AND (Item = @Item);
                UPDATE CAJ_COMPROBANTE_PAGO
                  SET 
                      id_ComprobanteRef = @id_ComprobanteRelacion
                WHERE id_ComprobantePago = @id_ComprobantePago;
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_M_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_LICITACIONES_M_I;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_M_I @Cod_TipoDoc         VARCHAR(4), 
                                          @Doc_Cliente         VARCHAR(32), 
                                          @Cod_Licitacion      VARCHAR(32), 
                                          @Nro_Detalle         INT, 
                                          @Cod_Libro           VARCHAR(4), 
                                          @Cod_TipoComprobante VARCHAR(4), 
                                          @Serie               VARCHAR(5), 
                                          @Numero              VARCHAR(32), 
                                          @Cod_TipoDocC        VARCHAR(4), 
                                          @Doc_ClienteC        VARCHAR(32), 
                                          @Flag_Cancelado      BIT, 
                                          @Obs_LicitacionesM   VARCHAR(1024), 
                                          @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT= 0;
        SET @id_ComprobantePago =
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
                  AND Cod_TipoDoc = @Cod_TipoDoc
                  AND Doc_Cliente = @Doc_Cliente
        );
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDocC
                  AND @Doc_ClienteC = Nro_Documento
        );
        DECLARE @Id_Movimiento INT=
        (
            SELECT ISNULL(Id_Movimiento,0)
            FROM PRI_LICITACIONES_M
            WHERE Cod_Licitacion = @Cod_Licitacion
                  AND Nro_Detalle = @Nro_Detalle
                  AND id_ComprobantePago = @id_ComprobantePago
        );
        IF NOT EXISTS
        (
            SELECT @Id_Movimiento
            FROM PRI_LICITACIONES_M
            WHERE(Id_Movimiento = @Id_Movimiento)
        )
            BEGIN
                INSERT INTO PRI_LICITACIONES_M
                VALUES
                (@Id_ClienteProveedor, 
                 @Cod_Licitacion, 
                 @Nro_Detalle, 
                 @id_ComprobantePago, 
                 @Flag_Cancelado, 
                 @Obs_LicitacionesM, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_Movimiento = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE PRI_LICITACIONES_M
                  SET 
                      Id_ClienteProveedor = @Id_ClienteProveedor, 
                      Cod_Licitacion = @Cod_Licitacion, 
                      Nro_Detalle = @Nro_Detalle, 
                      id_ComprobantePago = @id_ComprobantePago, 
                      Flag_Cancelado = @Flag_Cancelado, 
                      Obs_LicitacionesM = @Obs_LicitacionesM, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Movimiento = @Id_Movimiento);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_VEHICULOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_VEHICULOS_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_VEHICULOS_I @Cod_TipoDoc   VARCHAR(4), 
                                             @Doc_Cliente   VARCHAR(32), 
                                             @Cod_Placa     VARCHAR(32), 
                                             @Color         VARCHAR(128), 
                                             @Marca         VARCHAR(128), 
                                             @Modelo        VARCHAR(128), 
                                             @Propiestarios VARCHAR(512), 
                                             @Sede          VARCHAR(128), 
                                             @Placa_Vigente VARCHAR(64), 
                                             @Cod_Usuario   VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDoc
                  AND @Doc_Cliente = Nro_Documento
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM PRI_CLIENTE_VEHICULOS
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (Cod_Placa = @Cod_Placa)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_VEHICULOS
                VALUES
                (@Id_ClienteProveedor, 
                 @Cod_Placa, 
                 @Color, 
                 @Marca, 
                 @Modelo, 
                 @Propiestarios, 
                 @Sede, 
                 @Placa_Vigente, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_VEHICULOS
                  SET 
                      Color = @Color, 
                      Marca = @Marca, 
                      Modelo = @Modelo, 
                      Propiestarios = @Propiestarios, 
                      Sede = @Sede, 
                      Placa_Vigente = @Placa_Vigente, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (Cod_Placa = @Cod_Placa);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_BAN_CUENTA_BANCARIA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_I;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_I @Cod_CuentaBancaria     VARCHAR(32), 
                                           @Cod_Sucursal           VARCHAR(32), 
                                           @Cod_EntidadFinanciera  VARCHAR(8), 
                                           @Des_CuentaBancaria     VARCHAR(512), 
                                           @Cod_Moneda             VARCHAR(5), 
                                           @Flag_Activo            BIT, 
                                           @Saldo_Disponible       NUMERIC(38, 2), 
                                           @Cod_CuentaContable     VARCHAR(16), 
                                           @Cod_TipoCuentaBancaria VARCHAR(8), 
                                           @Cod_Usuario            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT @Cod_CuentaBancaria
            FROM BAN_CUENTA_BANCARIA
            WHERE(Cod_CuentaBancaria = @Cod_CuentaBancaria)
        )
            BEGIN
                INSERT INTO BAN_CUENTA_BANCARIA
                VALUES
                (@Cod_CuentaBancaria, 
                 @Cod_Sucursal, 
                 @Cod_EntidadFinanciera, 
                 @Des_CuentaBancaria, 
                 @Cod_Moneda, 
                 @Flag_Activo, 
                 @Saldo_Disponible, 
                 @Cod_CuentaContable, 
                 @Cod_TipoCuentaBancaria, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE BAN_CUENTA_BANCARIA
                  SET 
                      Cod_Sucursal = @Cod_Sucursal, 
                      Cod_EntidadFinanciera = @Cod_EntidadFinanciera, 
                      Des_CuentaBancaria = @Des_CuentaBancaria, 
                      Cod_Moneda = @Cod_Moneda, 
                      Flag_Activo = @Flag_Activo, 
                      Saldo_Disponible = @Saldo_Disponible, 
                      Cod_CuentaContable = @Cod_CuentaContable, 
                      Cod_TipoCuentaBancaria = @Cod_TipoCuentaBancaria, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_CuentaBancaria = @Cod_CuentaBancaria);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_BAN_CUENTA_M_i'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_M_I;
GO
CREATE PROCEDURE USP_BAN_CUENTA_M_I @Cod_CuentaBancaria        VARCHAR(32), 
                                    @Nro_Operacion             VARCHAR(32), 
                                    @Des_Movimiento            VARCHAR(512), 
                                    @Cod_TipoOperacionBancaria VARCHAR(8), 
                                    @Fecha                     VARCHAR(32), 
                                    @Monto                     NUMERIC(38, 2), 
                                    @TipoCambio                NUMERIC(10, 4), 
                                    @Cod_Caja                  VARCHAR(32), 
                                    @Cod_Turno                 VARCHAR(32), 
                                    @Cod_Plantilla             VARCHAR(32), 
                                    @Nro_Cheque                VARCHAR(32), 
                                    @Beneficiario              VARCHAR(512), 
                                    @Id_ComprobantePago        INT, 
                                    @Obs_Movimiento            VARCHAR(1024), 
                                    @Cod_Usuario               VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_MovimientoCuenta INT=
        (
            SELECT Id_MovimientoCuenta
            FROM BAN_CUENTA_M
            WHERE Cod_CuentaBancaria = @Cod_CuentaBancaria
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM BAN_CUENTA_M
            WHERE(Id_MovimientoCuenta = @Id_MovimientoCuenta)
        )
            BEGIN
                INSERT INTO BAN_CUENTA_M
                VALUES
                (@Cod_CuentaBancaria, 
                 @Nro_Operacion, 
                 @Des_Movimiento, 
                 @Cod_TipoOperacionBancaria, 
                 CONVERT(DATETIME, @Fecha, 121), 
                 @Monto, 
                 @TipoCambio, 
                 @Cod_Caja, 
                 @Cod_Turno, 
                 @Cod_Plantilla, 
                 @Nro_Cheque, 
                 @Beneficiario, 
                 @Id_ComprobantePago, 
                 @Obs_Movimiento, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE BAN_CUENTA_M
                  SET 
                      Cod_CuentaBancaria = @Cod_CuentaBancaria, 
                      Nro_Operacion = @Nro_Operacion, 
                      Des_Movimiento = @Des_Movimiento, 
                      Cod_TipoOperacionBancaria = @Cod_TipoOperacionBancaria, 
                      Fecha = CONVERT(DATETIME, @Fecha, 121), 
                      Monto = @Monto, 
                      TipoCambio = @TipoCambio, 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Cod_Plantilla = @Cod_Plantilla, 
                      Nro_Cheque = @Nro_Cheque, 
                      Beneficiario = @Beneficiario, 
                      Id_ComprobantePago = @Id_ComprobantePago, 
                      Obs_Movimiento = @Obs_Movimiento, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_MovimientoCuenta = @Id_MovimientoCuenta);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_MOV_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_I;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_I @Cod_Almacen          VARCHAR(32), 
                                       @Cod_TipoOperacion    VARCHAR(5), 
                                       @Cod_Turno            VARCHAR(32), 
                                       @Cod_TipoComprobante  VARCHAR(5), 
                                       @Serie                VARCHAR(5), 
                                       @Numero               VARCHAR(32), 
                                       @Fecha                VARCHAR(32), 
                                       @Motivo               VARCHAR(512), 
                                       @Cod_Libro            VARCHAR(4), 
                                       @Cod_TipoComprobanteM VARCHAR(4), 
                                       @SerieM               VARCHAR(5), 
                                       @NumeroM              VARCHAR(32), 
                                       @Cod_TipoDoc          VARCHAR(4), 
                                       @Doc_Cliente          VARCHAR(32), 
                                       @Flag_Anulado         BIT, 
                                       @Obs_AlmacenMov       XML, 
                                       @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT= 0;
        SET @id_ComprobantePago =
        (
            SELECT ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobanteM
                  AND Serie = @SerieM
                  AND Numero = @NumeroM
                  AND Cod_TipoDoc = @Cod_TipoDoc
                  AND Doc_Cliente = @Doc_Cliente
        );
        DECLARE @Id_AlmacenMov INT=
        (
            SELECT Id_AlmacenMov
            FROM ALM_ALMACEN_MOV
            WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM ALM_ALMACEN_MOV
            WHERE(Id_AlmacenMov = @Id_AlmacenMov)
        )
            BEGIN
                INSERT INTO ALM_ALMACEN_MOV
                VALUES
                (@Cod_Almacen, 
                 @Cod_TipoOperacion, 
                 @Cod_Turno, 
                 @Cod_TipoComprobante, 
                 @Serie, 
                 @Numero, 
                 CONVERT(DATETIME, @Fecha, 121), 
                 @Motivo, 
                 @Id_ComprobantePago, 
                 @Flag_Anulado, 
                 @Obs_AlmacenMov, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE ALM_ALMACEN_MOV
                  SET 
                      Cod_Almacen = @Cod_Almacen, 
                      Cod_TipoOperacion = @Cod_TipoOperacion, 
                      Cod_Turno = @Cod_Turno, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Serie = @Serie, 
                      Numero = @Numero, 
                      Fecha = CONVERT(DATETIME, @Fecha, 121), 
                      Motivo = @Motivo, 
                      Id_ComprobantePago = @Id_ComprobantePago, 
                      Flag_Anulado = @Flag_Anulado, 
                      Obs_AlmacenMov = @Obs_AlmacenMov, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_AlmacenMov = @Id_AlmacenMov);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_MOV_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_D_I;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D_I @Cod_TipoComprobante VARCHAR(5), 
                                         @Serie               VARCHAR(5), 
                                         @Numero              VARCHAR(32), 
                                         @Item                INT, 
                                         @Cod_Producto        VARCHAR(5), 
                                         @Des_Producto        VARCHAR(128), 
                                         @Precio_Unitario     NUMERIC(38, 6), 
                                         @Cantidad            NUMERIC(38, 6), 
                                         @Cod_UnidadMedida    VARCHAR(5), 
                                         @Obs_AlmacenMovD     VARCHAR(1024), 
                                         @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_AlmacenMov INT=
        (
            SELECT Id_AlmacenMov
            FROM ALM_ALMACEN_MOV
            WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        DECLARE @Id_Producto INT=
        (
            SELECT Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT *
            FROM ALM_ALMACEN_MOV_D
            WHERE(Id_AlmacenMov = @Id_AlmacenMov)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO ALM_ALMACEN_MOV_D
                VALUES
                (@Id_AlmacenMov, 
                 @Item, 
                 @Id_Producto, 
                 @Des_Producto, 
                 @Precio_Unitario, 
                 @Cantidad, 
                 @Cod_UnidadMedida, 
                 @Obs_AlmacenMovD, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE ALM_ALMACEN_MOV_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Des_Producto = @Des_Producto, 
                      Precio_Unitario = @Precio_Unitario, 
                      Cantidad = @Cantidad, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Obs_AlmacenMovD = @Obs_AlmacenMovD, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_AlmacenMov = @Id_AlmacenMov)
                     AND (Item = @Item);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PRODUCTO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PRODUCTO_I;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PRODUCTO_I @Cod_TipoDoc         VARCHAR(4), 
                                            @Doc_Cliente         VARCHAR(32), 
                                            @Cod_Producto        VARCHAR(5), 
                                            @Cod_TipoDescuento   VARCHAR(8), 
                                            @Monto               NUMERIC(38, 6), 
                                            @Obs_ClienteProducto VARCHAR(1024), 
                                            @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_ClienteProveedor INT=
        (
            SELECT TOP 1 Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Cod_TipoDocumento = @Cod_TipoDoc
                  AND @Doc_Cliente = Nro_Documento
        );
        DECLARE @Id_Producto INT=
        (
            SELECT Id_Producto
            FROM PRI_PRODUCTOS
            WHERE Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT @Id_ClienteProveedor, 
                   @Id_Producto
            FROM PRI_CLIENTE_PRODUCTO
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                 AND (Id_Producto = @Id_Producto)
        )
            BEGIN
                INSERT INTO PRI_CLIENTE_PRODUCTO
                VALUES
                (@Id_ClienteProveedor, 
                 @Id_Producto, 
                 @Cod_TipoDescuento, 
                 @Monto, 
                 @Obs_ClienteProducto, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_PRODUCTO
                  SET 
                      Cod_TipoDescuento = @Cod_TipoDescuento, 
                      Monto = @Monto, 
                      Obs_ClienteProducto = @Obs_ClienteProducto, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
                     AND (Id_Producto = @Id_Producto);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_FORMA_PAGO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_FORMA_PAGO_I;
GO
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_I @Cod_Libro           VARCHAR(4), 
                                      @Cod_TipoComprobante VARCHAR(4), 
                                      @Serie               VARCHAR(5), 
                                      @Numero              VARCHAR(32), 
                                      @Cod_TipoDoc         VARCHAR(4), 
                                      @Doc_Cliente         VARCHAR(32), 
                                      @Item                INT, 
                                      @Des_FormaPago       VARCHAR(512), 
                                      @Cod_TipoFormaPago   VARCHAR(3), 
                                      @Cuenta_CajaBanco    VARCHAR(64), 
                                      @Id_Movimiento       INT, 
                                      @TipoCambio          NUMERIC(10, 4), 
                                      @Cod_Moneda          VARCHAR(3), 
                                      @Monto               NUMERIC(38, 2), 
                                      @Cod_Caja            VARCHAR(32), 
                                      @Cod_Turno           VARCHAR(32), 
                                      @Cod_Plantilla       VARCHAR(32), 
                                      @Obs_FormaPago       XML, 
                                      @Fecha               VARCHAR(32), 
                                      @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @id_ComprobantePago INT=
        (
            SELECT id_ComprobantePago
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = @Cod_Libro
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
                  AND Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT @id_ComprobantePago, 
                   @Item
            FROM CAJ_FORMA_PAGO
            WHERE(id_ComprobantePago = @id_ComprobantePago)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO CAJ_FORMA_PAGO
                VALUES
                (@id_ComprobantePago, 
                 @Item, 
                 @Des_FormaPago, 
                 @Cod_TipoFormaPago, 
                 @Cuenta_CajaBanco, 
                 @Id_Movimiento, 
                 @TipoCambio, 
                 @Cod_Moneda, 
                 @Monto, 
                 @Cod_Caja, 
                 @Cod_Turno, 
                 @Cod_Plantilla, 
                 @Obs_FormaPago, 
                 CONVERT(DATETIME, @Fecha, 121), 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_FORMA_PAGO
                  SET 
                      Des_FormaPago = @Des_FormaPago, 
                      Cod_TipoFormaPago = @Cod_TipoFormaPago, 
                      Cuenta_CajaBanco = @Cuenta_CajaBanco, 
                      Id_Movimiento = @Id_Movimiento, 
                      TipoCambio = @TipoCambio, 
                      Cod_Moneda = @Cod_Moneda, 
                      Monto = @Monto, 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Cod_Plantilla = @Cod_Plantilla, 
                      Obs_FormaPago = @Obs_FormaPago, 
                      Fecha = CONVERT(DATETIME, @Fecha, 121), 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago)
                     AND (Item = @Item);
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_COLUMNA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PAR_COLUMNA_I;
GO
CREATE PROCEDURE USP_PAR_COLUMNA_I @Cod_Tabla      VARCHAR(3), 
                                   @Cod_Columna    VARCHAR(3), 
                                   @Columna        VARCHAR(512), 
                                   @Des_Columna    VARCHAR(1024), 
                                   @Tipo           VARCHAR(64), 
                                   @Flag_NULL      BIT, 
                                   @Tamano         INT, 
                                   @Predeterminado VARCHAR(MAX), 
                                   @Flag_PK        BIT, 
                                   @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM PAR_COLUMNA
            WHERE(Cod_Tabla = @Cod_Tabla)
                 AND (Cod_Columna = @Cod_Columna)
        )
            BEGIN
                INSERT INTO dbo.PAR_COLUMNA
                VALUES
                (@Cod_Tabla, -- Cod_Tabla - varchar
                 @Cod_Columna, -- Cod_Columna - varchar
                 @Columna, -- Columna - varchar
                 @Des_Columna, -- Des_Columna - varchar
                 @Tipo, -- Tipo - varchar
                 @Flag_NULL, -- Flag_NULL - bit
                 @Tamano, -- Tamano - int
                 @Predeterminado, -- Predeterminado - varchar
                 @Flag_PK, -- Flag_PK - bit
                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PAR_COLUMNA
                  SET 
                      dbo.PAR_COLUMNA.Columna = @Columna, -- varchar
                      dbo.PAR_COLUMNA.Des_Columna = @Des_Columna, -- varchar
                      dbo.PAR_COLUMNA.Tipo = @Tipo, -- varchar
                      dbo.PAR_COLUMNA.Flag_NULL = @Flag_NULL, -- bit
                      dbo.PAR_COLUMNA.Tamano = @Tamano, -- int
                      dbo.PAR_COLUMNA.Predeterminado = @Predeterminado, -- varchar
                      dbo.PAR_COLUMNA.Flag_PK = @Flag_PK, -- bit
                      dbo.PAR_COLUMNA.Cod_UsuarioAct = @Cod_Usuario, -- varchar
                      dbo.PAR_COLUMNA.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.PAR_COLUMNA.Cod_Tabla = @Cod_Tabla
                      AND dbo.PAR_COLUMNA.Cod_Columna = @Cod_Columna;
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_FILA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PAR_FILA_I;
GO
CREATE PROCEDURE USP_PAR_FILA_I @Cod_Tabla     VARCHAR(3), 
                                @Cod_Columna   VARCHAR(3), 
                                @Cod_Fila      INT, 
                                @Cadena        NVARCHAR(MAX), 
                                @Numero        NUMERIC(38, 8), 
                                @Entero        FLOAT, 
                                @FechaHora     VARCHAR(32), 
                                @Boleano       BIT, 
                                @Flag_Creacion BIT, 
                                @Cod_Usuario   VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.PAR_FILA pf
            WHERE pf.Cod_Tabla = @Cod_Tabla
                  AND pf.Cod_Columna = @Cod_Columna
                  AND pf.Cod_Fila = @Cod_Fila
        )
            BEGIN
                INSERT INTO dbo.PAR_FILA
                VALUES
                (@Cod_Tabla, -- Cod_Tabla - varchar
                 @Cod_Columna, -- Cod_Columna - varchar
                 @Cod_Fila, -- Cod_Fila - int
                 @Cadena, -- Cadena - nvarchar
                 @Numero, -- Numero - numeric
                 @Entero, -- Entero - float
                 CONVERT(DATETIME, @FechaHora, 121), -- FechaHora - datetime
                 @Boleano, -- Boleano - bit
                 @Flag_Creacion, -- Flag_Creacion - bit
                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PAR_FILA
                  SET 
                      dbo.PAR_FILA.Cadena = @Cadena, -- nvarchar
                      dbo.PAR_FILA.Numero = @Numero, -- numeric
                      dbo.PAR_FILA.Entero = @Entero, -- float
                      dbo.PAR_FILA.FechaHora = CONVERT(DATETIME, @FechaHora, 121), -- datetime
                      dbo.PAR_FILA.Boleano = @Boleano, -- bit
                      dbo.PAR_FILA.Flag_Creacion = @Flag_Creacion, -- bit
                      dbo.PAR_FILA.Cod_UsuarioReg = @Cod_Usuario, -- varchar
                      dbo.PAR_FILA.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.PAR_FILA.Cod_Tabla = @Cod_Tabla
                      AND dbo.PAR_FILA.Cod_Columna = @Cod_Columna
                      AND dbo.PAR_FILA.Cod_Fila = @Cod_Fila;
        END;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_TABLA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_PAR_TABLA_I;
GO
CREATE PROCEDURE USP_PAR_TABLA_I @Cod_Tabla   VARCHAR(3), 
                                 @Tabla       VARCHAR(512), 
                                 @Des_Tabla   VARCHAR(1024), 
                                 @Cod_Sistema VARCHAR(3), 
                                 @Flag_Acceso BIT, 
                                 @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.PAR_TABLA pt
            WHERE pt.Cod_Tabla = @Cod_Tabla
        )
            BEGIN
                INSERT INTO dbo.PAR_TABLA
                VALUES
                (@Cod_Tabla, -- Cod_Tabla - varchar
                 @Tabla, -- Tabla - varchar
                 @Des_Tabla, -- Des_Tabla - varchar
                 @Cod_Sistema, -- Cod_Sistema - varchar
                 @Flag_Acceso, -- Flag_Acceso - bit
                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PAR_TABLA
                  SET 
                      dbo.PAR_TABLA.Tabla = @Tabla, -- varchar
                      dbo.PAR_TABLA.Des_Tabla = @Des_Tabla, -- varchar
                      dbo.PAR_TABLA.Cod_Sistema = @Cod_Sistema, -- varchar
                      dbo.PAR_TABLA.Flag_Acceso = @Flag_Acceso, -- bit
                      dbo.PAR_TABLA.Cod_UsuarioAct = @Cod_Usuario, -- varchar
                      dbo.PAR_TABLA.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.PAR_TABLA.Cod_Tabla = @Cod_Tabla;
        END;
    END;
GO

-- metodo que marca un comprobante como recibido correctamente
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante @Cod_Libro            VARCHAR(MAX), 
                                                            @Cod_Tipo_Comprobante VARCHAR(MAX), 
                                                            @Serie                VARCHAR(MAX), 
                                                            @Numero               VARCHAR(MAX)
AS
    BEGIN
        UPDATE dbo.CAJ_COMPROBANTE_PAGO
          SET 
              dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante = 'INI'
        WHERE dbo.CAJ_COMPROBANTE_PAGO.Cod_Libro = @Cod_Libro
              AND dbo.CAJ_COMPROBANTE_PAGO.Cod_TipoComprobante = @Cod_Tipo_Comprobante
              AND dbo.CAJ_COMPROBANTE_PAGO.Serie = @Serie
              AND dbo.CAJ_COMPROBANTE_PAGO.Numero = @Numero
              AND (dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante IS NULL
                   OR REPLACE(dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante, ' ', '') = '');
    END; 
GO

--Creacion del linked server
-- DECLARE @NombreLinkedServer varchar(max)= N'PALERPcomprobantes' --Por defecto
-- DECLARE @ServidorLinkedServer varchar(max)= N'reyberpalma.hopto.org' --Nombre del servidor remoto
-- DECLARE @NombreBaseDeDatos varchar(max)= 'PALERPcomprobantes' --Nombre de la base de datos actual, cambiar si es otro nombre
-- DECLARE @NombreUsuarioServidor varchar(max)= N'sa' --Por defecto
-- DECLARE @NombrePassServidor varchar(max)= N'paleC0nsult0res' --Por defecto
-- exec USP_CrearLinkedServerSQLtoSQL @NombreLinkedServer,@ServidorLinkedServer,@NombreBaseDeDatos,@NombreUsuarioServidor,@NombrePassServidor
-- GO
--Procedimiento que realzia la subida de comprobantes al servidor PALERP
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_SubirComprobantes'
          AND type = 'P'
)
    DROP PROCEDURE USP_SubirComprobantes;
GO
CREATE PROCEDURE USP_SubirComprobantes
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @NombreBD VARCHAR(MAX)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @FechaHoraInicio DATETIME= GETDATE();
        DECLARE @Resultado VARCHAR(MAX);
        DECLARE @Linea NVARCHAR(MAX);
        DECLARE @IdComprobante INT;
        DECLARE RecorrerScriptComprobantes CURSOR
        FOR SELECT TOP 1000 ccp.id_ComprobantePago, 
                            'PALERPcomprobantes.PALERPcomprobantes.dbo.USP_CAJ_COMPROBANTE_PAGO_G ' + CASE
                                                                                                          WHEN pe.RUC IS NULL
                                                                                                          THEN 'NULL,'
                                                                                                          ELSE '''' + pe.RUC + ''','
                                                                                                      END + CASE
                                                                                                                WHEN ccp.Cod_TipoComprobante IS NULL
                                                                                                                THEN 'NULL,'
                                                                                                                ELSE '''' + ccp.Cod_TipoComprobante + ''','
                                                                                                            END + CASE
                                                                                                                      WHEN ccp.Serie IS NULL
                                                                                                                      THEN 'NULL,'
                                                                                                                      ELSE '''' + ccp.Serie + ''','
                                                                                                                  END + CASE
                                                                                                                            WHEN ccp.Numero IS NULL
                                                                                                                            THEN 'NULL,'
                                                                                                                            ELSE '''' + ccp.Numero + ''','
                                                                                                                        END + CASE
                                                                                                                                  WHEN ccp.Cod_TipoDoc IS NULL
                                                                                                                                  THEN 'NULL,'
                                                                                                                                  ELSE '''' + REPLACE(ccp.Cod_TipoDoc, '''', '') + ''','
                                                                                                                              END + CASE
                                                                                                                                        WHEN ccp.Doc_Cliente IS NULL
                                                                                                                                        THEN 'NULL,'
                                                                                                                                        ELSE '''' + REPLACE(ccp.Doc_Cliente, '''', '') + ''','
                                                                                                                                    END + CASE
                                                                                                                                              WHEN ccp.Nom_Cliente IS NULL
                                                                                                                                              THEN 'NULL,'
                                                                                                                                              ELSE '''' + REPLACE(ccp.Nom_Cliente, '''', '') + ''','
                                                                                                                                          END + CASE
                                                                                                                                                    WHEN ccp.FechaEmision IS NULL
                                                                                                                                                    THEN 'NULL,'
                                                                                                                                                    ELSE '''' + CONVERT(VARCHAR(MAX), ccp.FechaEmision, 121) + ''','
                                                                                                                                                END + CONVERT(VARCHAR(MAX), ccp.Flag_Anulado) + ',' + CASE
                                                                                                                                                                                                          WHEN ccp.Impuesto IS NULL
                                                                                                                                                                                                          THEN 'NULL,'
                                                                                                                                                                                                          ELSE CONVERT(VARCHAR(MAX), ccp.Impuesto) + ','
                                                                                                                                                                                                      END + CASE
                                                                                                                                                                                                                WHEN ccp.Total IS NULL
                                                                                                                                                                                                                THEN 'NULL,'
                                                                                                                                                                                                                ELSE CONVERT(VARCHAR(MAX), ccp.Total) + ','
                                                                                                                                                                                                            END + CASE
                                                                                                                                                                                                                      WHEN vfp.Nom_FormaPago IS NULL
                                                                                                                                                                                                                      THEN 'NULL,'
                                                                                                                                                                                                                      ELSE '''' + vfp.Nom_FormaPago + ''','
                                                                                                                                                                                                                  END + CASE
                                                                                                                                                                                                                            WHEN vm.Nom_Moneda IS NULL
                                                                                                                                                                                                                            THEN 'NULL,'
                                                                                                                                                                                                                            ELSE '''' + vm.Nom_Moneda + ''','
                                                                                                                                                                                                                        END + CASE
                                                                                                                                                                                                                                  WHEN ccp.Cod_EstadoComprobante IS NULL
                                                                                                                                                                                                                                  THEN 'NULL,'
                                                                                                                                                                                                                                  ELSE '''' + REPLACE(ccp.Cod_EstadoComprobante, '''', '') + ''','
                                                                                                                                                                                                                              END + '''' + COALESCE(ccp.Cod_UsuarioReg, ccp.Cod_UsuarioAct) + ''';'
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_FORMAS_PAGO vfp ON ccp.Cod_FormaPago = vfp.Cod_FormaPago
                 INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
                 CROSS JOIN dbo.PRI_EMPRESA pe
            WHERE(((ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
                  AND ccp.Cod_EstadoComprobante IN('FIN', 'REC'))
            OR (ccp.Cod_TipoComprobante IN('TKB', 'TKF')))
        AND ccp.Id_GuiaRemision = 0
        AND ccp.Cod_Libro = '14');
        OPEN RecorrerScriptComprobantes;
        FETCH NEXT FROM RecorrerScriptComprobantes INTO @IdComprobante, @Linea;
        WHILE @@FETCH_STATUS = 0
            BEGIN   
                --DECLARE @Resultado varchar(max) ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo LINEA A EJECUTAR: '+@Linea+'>> C:\APLICACIONES\LOG\log_exportacion.txt','''',' '),'|',' ')+''''
                EXECUTE (@Resultado);
                BEGIN TRY
                    EXECUTE (@Linea);
                    UPDATE dbo.CAJ_COMPROBANTE_PAGO
                      SET 
                          dbo.CAJ_COMPROBANTE_PAGO.Id_GuiaRemision = 1
                    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @IdComprobante;
                END TRY
                BEGIN CATCH
                    SELECT ERROR_NUMBER() AS ErrorNumber, 
                           ERROR_SEVERITY() AS ErrorSeverity, 
                           ERROR_STATE() AS ErrorState, 
                           ERROR_PROCEDURE() AS ErrorProcedure, 
                           ERROR_LINE() AS ErrorLine, 
                           ERROR_MESSAGE() AS ErrorMessage;
                    SET @Resultado = 'master..xp_cmdshell ' + '''' + REPLACE(REPLACE('echo ERROR DURANTE LA EJECUCION DEL USP : ' + ERROR_MESSAGE() + CONVERT(VARCHAR(MAX), GETDATE(), 121) + '>> C:\APLICACIONES\TEMP\log_Comprobantes_Subidos_Detalle_' + @NombreBD + '.txt', '''', ' '), '|', ' ') + '''';
                    EXECUTE (@Resultado);
                END CATCH;
                FETCH NEXT FROM RecorrerScriptComprobantes INTO @IdComprobante, @Linea;
            END;
        SET @Resultado = 'master..xp_cmdshell ' + '''' + REPLACE(REPLACE('echo INICIO DE SUBIDA DE DATOS : ' + CONVERT(VARCHAR(MAX), @FechaHoraInicio, 121) + ' FIN DE SUBIDA DE DATOS : ' + CONVERT(VARCHAR(MAX), GETDATE(), 121) + '>> C:\APLICACIONES\TEMP\log_Comprobantes_Subidos_' + @NombreBD + '.txt', '''', ' '), '|', ' ') + '''';
        EXECUTE (@Resultado);
        CLOSE RecorrerScriptComprobantes;
        DEALLOCATE RecorrerScriptComprobantes;
    END;
GO 
--Creacion de la tarea
--Crea la tarea de exportacion que nse inicia desde las 00:00:00 horas hasta la 23:59:59
--Se necesita que exista la carpeta LOG en C:\APLICACIONES
--NumeroIntentos entero el nuemro de intentos , si es 0 sin reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--@RepetirCada el lapso de tiempo en el que se repite la tarea en minutos, por defecto 60
--Ruta de guradado Path absoluto de la ruta del archivo a guardar
--exec USP_CrearTareaAgente N'Tarea exportacion',N'USP_ExportarDatos',N'C:\APLICACIONES\TEMP\log_exportacion.txt'
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaAgente'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaAgente;
GO
CREATE PROCEDURE USP_CrearTareaAgente @NombreTarea       VARCHAR(MAX), 
                                      @Nom_Procedimiento VARCHAR(MAX), 
                                      @RutaGuardado      VARCHAR(MAX) = N'C:\APLICACIONES\TEMP\log_Agente.txt', 
                                      @NumeroIntentos    INT          = 2, 
                                      @IntervaloMinutos  INT          = 20, 
                                      @RepetirCada       INT          = 60
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= 'EXEC ' + @Nom_Procedimiento;
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'TAREA', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = @RutaGuardado, 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaHora DATETIME= GETDATE();
        DECLARE @FechaActual INT= CONVERT(INT, CONCAT(YEAR(@FechaHora), FORMAT(MONTH(@FechaHora), '00'), FORMAT(DAY(@FechaHora), '00')));
        DECLARE @HoraInicio INT= CONVERT(INT, CONCAT('00', DATEPART(MINUTE, @FechaHora), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'TAREAS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 4, 
             @freq_subday_interval = @RepetirCada, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 0, 
             @active_start_date = @FechaActual, 
             @active_start_time = @HoraInicio, 
             @active_end_date = 99991231, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO

--Tarea de exportacion
--  DECLARE @NombreTarea varchar(max)= N'Tarea Subida Comprobantes_'+(SELECT DB_NAME() AS [Base de datos actual]) 
--  DECLARE @NombreUSPexportacion varchar(max)= N'USP_SubirComprobantes' --Por defecto
--  DECLARE @RutaGuardadoLOG varchar(max)= ''
--  exec USP_CrearTareaAgente @NombreTarea,@NombreUSPexportacion,@RutaGuardadoLOG,@NumeroIntentos= 0,@IntervaloMinutos  = 0,@RepetirCada  = 10

GO

--METODO QUE DA DE BAJA UN COMPROBANTE POR ID
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_DarBaja'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja @id_ComprobantePago INT, 
                                                  @CodUsuario         VARCHAR(32), 
                                                  @Justificacion      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Id_Producto INT, @Signo INT, @Cod_Almacen VARCHAR(32), @Cod_UnidadMedida VARCHAR(5), @Despachado NUMERIC(38, 6), @Documento VARCHAR(128), @Proveedor VARCHAR(1024), @Detalle VARCHAR(MAX), @FechaEmision DATETIME, @FechaActual DATETIME, @id_Fila INT;
        SET @FechaActual = GETDATE();
        SELECT @Documento = Cod_Libro + '-' + Cod_TipoComprobante + ':' + Serie + '-' + Numero, 
               @Proveedor = Cod_TipoDoc + ':' + Doc_Cliente + '-' + Nom_Cliente, 
               @FechaEmision = FechaEmision
        FROM CAJ_COMPROBANTE_PAGO
        WHERE id_ComprobantePago = @id_ComprobantePago;

        -- RECUPERAR LOS DETALLES
        SET @Detalle = STUFF(
        (
            SELECT DISTINCT 
                   ' ; ' + CONVERT(VARCHAR, D.Id_Producto) + '|' + d.Descripcion + '|' + CONVERT(VARCHAR, d.Cantidad)
            FROM CAJ_COMPROBANTE_D D
            WHERE D.id_ComprobantePago = @id_ComprobantePago FOR XML PATH('')
        ), 1, 2, '') + '';
        SET @Signo =
        (
            SELECT CASE Cod_Libro
                       WHEN '08'
                       THEN-1
                       WHEN '14'
                       THEN 1
                       ELSE 0
                   END
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @id_ComprobantePago
        );
        DECLARE ComprobanteD CURSOR
        FOR SELECT Id_Producto, 
                   Cod_UnidadMedida, 
                   Cod_Almacen, 
                   Despachado
            FROM CAJ_COMPROBANTE_D
            WHERE id_ComprobantePago = @id_ComprobantePago
                  AND Id_Producto <> 0;
        OPEN ComprobanteD;
        FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE PRI_PRODUCTO_STOCK
                  SET 
                      Stock_Act = Stock_Act + @Signo * @Despachado
                WHERE Id_Producto = @Id_Producto
                      AND Cod_UnidadMedida = @Cod_UnidadMedida
                      AND Cod_Almacen = @Cod_Almacen;
                FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
            END;
        CLOSE ComprobanteD;
        DEALLOCATE ComprobanteD;

        --Actualizamos la informacion en comprobante pago
        UPDATE dbo.CAJ_COMPROBANTE_PAGO
          SET 
              dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado = 1, 
              dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante = 'REC', 
              dbo.CAJ_COMPROBANTE_PAGO.Impuesto = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.MotivoAnulacion = @Justificacion
        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de los detalles
        UPDATE dbo.CAJ_COMPROBANTE_D
          SET 
              dbo.CAJ_COMPROBANTE_D.Cantidad = 0, 
              dbo.CAJ_COMPROBANTE_D.Despachado = 0, 
              dbo.CAJ_COMPROBANTE_D.Formalizado = 0, 
              dbo.CAJ_COMPROBANTE_D.Descuento = 0, 
              dbo.CAJ_COMPROBANTE_D.Sub_Total = 0, 
              dbo.CAJ_COMPROBANTE_D.IGV = 0, 
              dbo.CAJ_COMPROBANTE_D.ISC = 0
        WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de la forma de pago
        UPDATE dbo.CAJ_FORMA_PAGO
          SET 
              dbo.CAJ_FORMA_PAGO.Monto = 0
        WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Eliminamos todas las relaciones
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(Id_ComprobanteRelacion = @id_ComprobantePago);
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        --Eliminamos las licitaciones
        DELETE FROM PRI_LICITACIONES_M
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        -- Eliminar las Serie que se colocaron
        DELETE FROM CAJ_SERIES
        WHERE(Id_Tabla = @id_ComprobantePago
              AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO');
        EXEC dbo.USP_HIS_ELIMINADOS_G 
             @Id = NULL, 
             @Cod_Eliminado = @Documento, 
             @Tabla = 'CAJ_COMPROBANTE_PAGO', 
             @Cliente = @Proveedor, 
             @Detalle = @Detalle, 
             @Fecha_Emision = @FechaEmision, 
             @Fecha_Eliminacion = @FechaActual, 
             @Responsable = @CodUsuario, 
             @Justificacion = @Justificacion, 
             @Cod_Usuario = @CodUsuario;
    END;
GO

----------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TMP_REGISTRO_LOG_TraerTodo'
          AND type = 'P'
)
    DROP PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo;
GO
CREATE PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo
WITH ENCRYPTION
AS
    BEGIN
        SELECT trl.*
        FROM dbo.TMP_REGISTRO_LOG trl
        ORDER BY trl.Id;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TMP_REGISTRO_LOG_MoverUno'
          AND type = 'P'
)
    DROP PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno;
GO
CREATE PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno @Id VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        --Exporta una fila a un archivo de texto
        --Variables generales 
        DECLARE @cmd VARCHAR(MAX);
        DECLARE @Nombre_Tabla VARCHAR(MAX);
        DECLARE @Id_Fila VARCHAR(MAX);
        DECLARE @Accion VARCHAR(MAX);
        DECLARE @Script VARCHAR(MAX);
        DECLARE @Fecha_Reg DATETIME; 
        --Recuperamos el y almacenamos en las variables
        SELECT @Id = trl.Id, 
               @Nombre_Tabla = trl.Nombre_Tabla, 
               @Id_Fila = trl.Id_Fila, 
               @Accion = trl.Accion, 
               @Script = trl.Script, 
               @Fecha_Reg = trl.Fecha_Reg
        FROM dbo.TMP_REGISTRO_LOG trl
        WHERE trl.Id = @Id;
        IF @Id IS NOT NULL
            BEGIN
                SET XACT_ABORT ON;
                BEGIN TRY
                    BEGIN TRANSACTION;
                    INSERT INTO dbo.TMP_REGISTRO_LOG_H
                    (Nombre_Tabla, 
                     Id_Fila, 
                     Accion, 
                     Script, 
                     Fecha_Reg, 
                     Fecha_Reg_Insercion
                    )
                    VALUES
                    (@Nombre_Tabla, -- Nombre_Tabla - varchar
                     @Id_Fila, -- Id_Fila - varchar
                     @Accion, -- Accion - varchar
                     @Script, -- Script - varchar
                     @Fecha_Reg, -- Fecha_Reg - datetime
                     GETDATE() -- Fecha_Reg_Insercion - datetime
                    );
                    DELETE dbo.TMP_REGISTRO_LOG
                    WHERE @Id = dbo.TMP_REGISTRO_LOG.Id;
                    COMMIT TRANSACTION;
        END TRY
                BEGIN CATCH
                    IF(XACT_STATE()) = -1
                        BEGIN
                            ROLLBACK TRANSACTION;
                    END;
                    IF(XACT_STATE()) = 1
                        BEGIN
                            COMMIT TRANSACTION;
                    END;
                    THROW;
        END CATCH;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ObtenerDatos_Servidor'
          AND type = 'P'
)
    DROP PROCEDURE USP_ObtenerDatos_Servidor;
GO
CREATE PROCEDURE USP_ObtenerDatos_Servidor
WITH ENCRYPTION
AS
    BEGIN
        SELECT @@SERVERNAME AS 'SERVIDOR', 
               @@SPID AS 'ID', 
               SYSTEM_USER AS 'LOGIN', 
               USER AS 'USER', 
               @@LANGUAGE AS 'LENGUAJE', 
               @@REMSERVER AS 'SERVIDOR_BASE', 
               @@VERSION AS 'VERSION_SQL', 
               DB_NAME() AS 'NOMBRE_BD';
    END;
GO

--Añadidos para borrar los datos
--MEtodos de eliminacion
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_D;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_D @Cod_Almacen VARCHAR(32), 
                                   @Cod_Usuario VARCHAR(32), 
                                   @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.ALM_ALMACEN
            WHERE dbo.ALM_ALMACEN.Cod_Almacen = @Cod_Almacen;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_MOV_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_D;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D @Cod_TipoComprobante VARCHAR(5), 
                                       @Serie               VARCHAR(5), 
                                       @Numero              VARCHAR(32), 
                                       @Cod_Usuario         VARCHAR(32), 
                                       @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_AlmacenMov INT=
            (
                SELECT aam.Id_AlmacenMov
                FROM dbo.ALM_ALMACEN_MOV aam
                WHERE aam.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND aam.Serie = @Serie
                      AND aam.Numero = @Numero
            );
            DELETE dbo.ALM_ALMACEN_MOV
            WHERE dbo.ALM_ALMACEN_MOV.Id_AlmacenMov = @Id_AlmacenMov;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_MOV_D_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_D_D;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D_D @Cod_TipoComprobante VARCHAR(5), 
                                         @Serie               VARCHAR(5), 
                                         @Numero              VARCHAR(32), 
                                         @Item                INT, 
                                         @Cod_Usuario         VARCHAR(32), 
                                         @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_AlmacenMov INT=
            (
                SELECT aam.Id_AlmacenMov
                FROM dbo.ALM_ALMACEN_MOV aam
                WHERE aam.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND aam.Serie = @Serie
                      AND aam.Numero = @Numero
            );
            DELETE dbo.ALM_ALMACEN_MOV_D
            WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov = @Id_AlmacenMov
                  AND dbo.ALM_ALMACEN_MOV_D.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_D;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_D @Cod_TipoInventario VARCHAR(5), 
                                      @Cod_Almacen        VARCHAR(32), 
                                      @Cod_Usuario        VARCHAR(32), 
                                      @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Inventario INT=
            (
                SELECT ai.Id_Inventario
                FROM dbo.ALM_INVENTARIO ai
                WHERE ai.Cod_TipoInventario = @Cod_TipoInventario
                      AND ai.Cod_Almacen = @Cod_Almacen
            );
            DELETE dbo.ALM_INVENTARIO
            WHERE dbo.ALM_INVENTARIO.Id_Inventario = @Id_Inventario;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_D_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_D_D;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_D_D @Cod_TipoInventario VARCHAR(5), 
                                        @Cod_Almacen        VARCHAR(32), 
                                        @Item               INT, 
                                        @Cod_Usuario        VARCHAR(32), 
                                        @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Inventario INT=
            (
                SELECT ai.Id_Inventario
                FROM dbo.ALM_INVENTARIO ai
                WHERE ai.Cod_TipoInventario = @Cod_TipoInventario
                      AND ai.Cod_Almacen = @Cod_Almacen
            );
            DELETE dbo.ALM_INVENTARIO
            WHERE dbo.ALM_INVENTARIO.Id_Inventario = @Id_Inventario;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_BAN_CUENTA_BANCARIA_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_D;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_D @Cod_CuentaBancaria VARCHAR(32), 
                                           @Cod_Usuario        VARCHAR(32), 
                                           @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.BAN_CUENTA_BANCARIA
            WHERE dbo.BAN_CUENTA_BANCARIA.Cod_CuentaBancaria = @Cod_CuentaBancaria;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_BAN_CUENTA_M_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_M_D;
GO
CREATE PROCEDURE USP_BAN_CUENTA_M_D @Cod_CuentaBancaria VARCHAR(32), 
                                    @Cod_Usuario        VARCHAR(32), 
                                    @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.BAN_CUENTA_BANCARIA
            WHERE dbo.BAN_CUENTA_BANCARIA.Cod_CuentaBancaria = @Cod_CuentaBancaria;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D @Cod_Caja    VARCHAR(32), 
                                        @Cod_Turno   VARCHAR(32), 
                                        @Cod_Usuario VARCHAR(32), 
                                        @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ArqueoFisico INT=
            (
                SELECT TOP 1 id_ArqueoFisico
                FROM CAJ_ARQUEOFISICO
                WHERE(Cod_Caja = @Cod_Caja)
                     AND (Cod_Turno = @Cod_Turno)
            );
            DELETE dbo.CAJ_ARQUEOFISICO
            WHERE dbo.CAJ_ARQUEOFISICO.id_ArqueoFisico = @id_ArqueoFisico;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_D_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D_D;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D_D @Cod_Caja    VARCHAR(32), 
                                          @Cod_Turno   VARCHAR(32), 
                                          @Cod_Billete VARCHAR(3), 
                                          @Cod_Usuario VARCHAR(32), 
                                          @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ArqueoFisico INT=
            (
                SELECT id_ArqueoFisico
                FROM CAJ_ARQUEOFISICO
                WHERE(Cod_Caja = @Cod_Caja)
                     AND (Cod_Turno = @Cod_Turno)
            );
            DELETE dbo.CAJ_ARQUEOFISICO_D
            WHERE dbo.CAJ_ARQUEOFISICO_D.id_ArqueoFisico = @id_ArqueoFisico
                  AND dbo.CAJ_ARQUEOFISICO_D.Cod_Billete = @Cod_Billete;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_ARQUEOFISICO_SALDO_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_D;
GO
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_D @Cod_Caja    VARCHAR(32), 
                                              @Cod_Turno   VARCHAR(32), 
                                              @Cod_Moneda  VARCHAR(3), 
                                              @Tipo        VARCHAR(32), 
                                              @Cod_Usuario VARCHAR(32), 
                                              @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ArqueoFisico INT=
            (
                SELECT TOP 1 id_ArqueoFisico
                FROM CAJ_ARQUEOFISICO
                WHERE(Cod_Caja = @Cod_Caja)
                     AND (Cod_Turno = @Cod_Turno)
            );
            DELETE dbo.CAJ_ARQUEOFISICO_SALDO
            WHERE dbo.CAJ_ARQUEOFISICO_SALDO.id_ArqueoFisico = @id_ArqueoFisico
                  AND dbo.CAJ_ARQUEOFISICO_SALDO.Cod_Moneda = @Cod_Moneda
                  AND dbo.CAJ_ARQUEOFISICO_SALDO.Tipo = @Tipo;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJA_ALMACEN_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_D;
GO
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_D @Cod_Caja    VARCHAR(32), 
                                        @Cod_Almacen VARCHAR(32), 
                                        @Cod_Usuario VARCHAR(32), 
                                        @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_CAJA_ALMACEN
            WHERE dbo.CAJ_CAJA_ALMACEN.Cod_Caja = @Cod_Caja
                  AND dbo.CAJ_CAJA_ALMACEN.Cod_Almacen = @Cod_Almacen;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_D;
GO
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_D @Cod_Caja            VARCHAR(32), 
                                            @Cod_Turno           VARCHAR(32), 
                                            @Cod_TipoComprobante VARCHAR(5), 
                                            @Serie               VARCHAR(4), 
                                            @Numero              VARCHAR(20), 
                                            @Cod_Usuario         VARCHAR(32), 
                                            @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_Movimiento INT=
            (
                SELECT id_Movimiento
                FROM CAJ_CAJA_MOVIMIENTOS
                WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                      AND Serie = @Serie
                      AND Numero = @Numero
            );
            DELETE dbo.CAJ_CAJA_MOVIMIENTOS
            WHERE dbo.CAJ_CAJA_MOVIMIENTOS.id_Movimiento = @id_Movimiento;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJAS_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJAS_D;
GO
CREATE PROCEDURE USP_CAJ_CAJAS_D @Cod_Caja    VARCHAR(32), 
                                 @Cod_Usuario VARCHAR(32), 
                                 @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_CAJAS
            WHERE dbo.CAJ_CAJAS.Cod_Caja = @Cod_Caja;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CAJAS_DOC_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_CAJAS_DOC_D;
GO
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_D @Cod_Caja    VARCHAR(32), 
                                     @Item        INT, 
                                     @Cod_Usuario VARCHAR(32), 
                                     @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_CAJAS_DOC
            WHERE dbo.CAJ_CAJAS_DOC.Cod_Caja = @Cod_Caja
                  AND dbo.CAJ_CAJAS_DOC.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_D_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_D_D;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_D @Cod_Libro           VARCHAR(4), 
                                         @Cod_TipoComprobante VARCHAR(4), 
                                         @Serie               VARCHAR(5), 
                                         @Numero              VARCHAR(32), 
                                         @id_Detalle          INT, 
                                         @Cod_Usuario         VARCHAR(32), 
                                         @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ComprobantePago INT=
            (
                SELECT ISNULL(id_ComprobantePago, 0)
                FROM CAJ_COMPROBANTE_PAGO
                WHERE Cod_Libro = @Cod_Libro
                      AND Cod_TipoComprobante = @Cod_TipoComprobante
                      AND Serie = @Serie
                      AND Numero = @Numero
            );
            DELETE dbo.CAJ_COMPROBANTE_D
            WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @id_ComprobantePago
                  AND dbo.CAJ_COMPROBANTE_D.id_Detalle = @id_Detalle;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_LOG_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_LOG_D;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_D @Cod_TipoComprobante VARCHAR(4), 
                                           @Serie               VARCHAR(5), 
                                           @Numero              VARCHAR(32), 
                                           @Itemn               INT, 
                                           @Cod_Usuario         VARCHAR(32), 
                                           @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ComprobantePago INT=
            (
                SELECT TOP 1 ccp.id_ComprobantePago
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND ccp.Serie = @Serie
                      AND ccp.Numero = @Numero
            );
            DELETE dbo.CAJ_COMPROBANTE_LOG
            WHERE dbo.CAJ_COMPROBANTE_LOG.id_ComprobantePago = @id_ComprobantePago
                  AND dbo.CAJ_COMPROBANTE_LOG.Item = @Itemn;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_LOG_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_LOG_D;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_D @Cod_Libro           VARCHAR(2), 
                                           @Cod_TipoComprobante VARCHAR(5), 
                                           @Serie               VARCHAR(5), 
                                           @Numero              VARCHAR(30), 
                                           @Cod_Usuario         VARCHAR(32), 
                                           @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ComprobantePago INT=
            (
                SELECT ccp.id_ComprobantePago
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Cod_Libro = @Cod_Libro
                      AND ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND ccp.Serie = @Serie
                      AND ccp.Numero = @Numero
            );
            DELETE dbo.CAJ_COMPROBANTE_PAGO
            WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_ComprobantePago;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_RELACION_D;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_D @Cod_Libro           VARCHAR(2), 
                                                @Cod_TipoComprobante VARCHAR(5), 
                                                @Serie               VARCHAR(5), 
                                                @Numero              VARCHAR(30), 
                                                @Id_Detalle          INT, 
                                                @Item                INT, 
                                                @Cod_Usuario         VARCHAR(32), 
                                                @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ComprobantePago INT=
            (
                SELECT ccp.id_ComprobantePago
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Cod_Libro = @Cod_Libro
                      AND ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND ccp.Serie = @Serie
                      AND ccp.Numero = @Numero
            );
            DELETE dbo.CAJ_COMPROBANTE_RELACION
            WHERE dbo.CAJ_COMPROBANTE_RELACION.id_ComprobantePago = @Id_ComprobantePago
                  AND dbo.CAJ_COMPROBANTE_RELACION.id_Detalle = @Id_Detalle
                  AND dbo.CAJ_COMPROBANTE_RELACION.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_CONCEPTO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_CONCEPTO_D;
GO
CREATE PROCEDURE USP_CAJ_CONCEPTO_D @Id_Concepto INT, 
                                    @Cod_Usuario VARCHAR(32), 
                                    @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_CONCEPTO
            WHERE dbo.CAJ_CONCEPTO.Id_Concepto = @Id_Concepto;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_FORMA_PAGO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_FORMA_PAGO_D;
GO
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_D @Cod_Libro           VARCHAR(4), 
                                      @Cod_TipoComprobante VARCHAR(4), 
                                      @Serie               VARCHAR(5), 
                                      @Numero              VARCHAR(32), 
                                      @Item                INT, 
                                      @Cod_Usuario         VARCHAR(32), 
                                      @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ComprobantePago INT=
            (
                SELECT id_ComprobantePago
                FROM CAJ_COMPROBANTE_PAGO
                WHERE Cod_Libro = @Cod_Libro
                      AND Cod_TipoComprobante = @Cod_TipoComprobante
                      AND Serie = @Serie
                      AND Numero = @Numero
            );
            DELETE dbo.CAJ_FORMA_PAGO
            WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @id_ComprobantePago
                  AND dbo.CAJ_FORMA_PAGO.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_MEDICION_VC_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_MEDICION_VC_D;
GO
CREATE PROCEDURE USP_CAJ_MEDICION_VC_D @Cod_AMedir   VARCHAR(32), 
                                       @Medio_AMedir VARCHAR(32), 
                                       @Cod_Turno    VARCHAR(32), 
                                       @Cod_Usuario  VARCHAR(32), 
                                       @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_MEDICION_VC
            WHERE dbo.CAJ_MEDICION_VC.Cod_AMedir = @Cod_AMedir
                  AND dbo.CAJ_MEDICION_VC.Medio_AMedir = @Medio_AMedir
                  AND dbo.CAJ_MEDICION_VC.Cod_Turno = @Cod_Turno;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_TIPOCAMBIO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_TIPOCAMBIO_D;
GO
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_D @FechaHora   VARCHAR(32), 
                                      @Cod_Moneda  VARCHAR(3), 
                                      @Cod_Usuario VARCHAR(32), 
                                      @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_TipoCambio INT=
            (
                SELECT ct.Id_TipoCambio
                FROM dbo.CAJ_TIPOCAMBIO ct
                WHERE ct.FechaHora = @FechaHora
                      AND ct.Cod_Moneda = @Cod_Moneda
            );
            DELETE dbo.CAJ_TIPOCAMBIO
            WHERE dbo.CAJ_TIPOCAMBIO.Id_TipoCambio = @Id_TipoCambio;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_TURNO_ATENCION_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_TURNO_ATENCION_D;
GO
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_D @Cod_Turno   VARCHAR(32), 
                                          @Cod_Usuario VARCHAR(32), 
                                          @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_TURNO_ATENCION
            WHERE dbo.CAJ_TURNO_ATENCION.Cod_Turno = @Cod_Turno;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_COLUMNA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PAR_COLUMNA_D;
GO
CREATE PROCEDURE USP_PAR_COLUMNA_D @Cod_Tabla   VARCHAR(3), 
                                   @Cod_Columna VARCHAR(3), 
                                   @Cod_Usuario VARCHAR(32), 
                                   @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PAR_COLUMNA
            WHERE dbo.PAR_COLUMNA.Cod_Tabla = @Cod_Tabla
                  AND dbo.PAR_COLUMNA.Cod_Columna = @Cod_Columna;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_FILA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PAR_FILA_D;
GO
CREATE PROCEDURE USP_PAR_FILA_D @Cod_Tabla   VARCHAR(3), 
                                @Cod_Columna VARCHAR(3), 
                                @Cod_Fila    INT, 
                                @Cod_Usuario VARCHAR(32), 
                                @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PAR_FILA
            WHERE dbo.PAR_FILA.Cod_Tabla = @Cod_Tabla
                  AND dbo.PAR_FILA.Cod_Columna = @Cod_Columna
                  AND dbo.PAR_FILA.Cod_Fila = @Cod_Fila;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PAR_TABLA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PAR_TABLA_D;
GO
CREATE PROCEDURE USP_PAR_TABLA_D @Cod_Tabla   VARCHAR(3), 
                                 @Cod_Usuario VARCHAR(32), 
                                 @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PAR_TABLA
            WHERE dbo.PAR_TABLA.Cod_Tabla = @Cod_Tabla;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_ACTIVIDADES_ECONOMICAS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_ACTIVIDADES_ECONOMICAS_D;
GO
CREATE PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_D @Cod_ActividadEconomica VARCHAR(32), 
                                                  @Cod_TipoDocumento      VARCHAR(3), 
                                                  @Nro_Documento          VARCHAR(32), 
                                                  @Cod_Usuario            VARCHAR(32), 
                                                  @Motivo                 VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DELETE dbo.PRI_ACTIVIDADES_ECONOMICAS
            WHERE dbo.PRI_ACTIVIDADES_ECONOMICAS.Cod_ActividadEconomica = @Cod_ActividadEconomica
                  AND dbo.PRI_ACTIVIDADES_ECONOMICAS.Id_ClienteProveedor = @Id_ClienteProveedor;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_AREAS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_AREAS_D;
GO
CREATE PROCEDURE USP_PRI_AREAS_D @Cod_Area    VARCHAR(32), 
                                 @Cod_Usuario VARCHAR(32), 
                                 @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_AREAS
            WHERE dbo.PRI_AREAS.Cod_Area = @Cod_Area;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CATEGORIA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CATEGORIA_D;
GO
CREATE PROCEDURE USP_PRI_CATEGORIA_D @Cod_Categoria VARCHAR(32), 
                                     @Cod_Usuario   VARCHAR(32), 
                                     @Motivo        VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_CATEGORIA
            WHERE dbo.PRI_CATEGORIA.Cod_Categoria = @Cod_Categoria;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_CONTACTO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_CONTACTO_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_D @Cod_TipoDocumentoP VARCHAR(5), 
                                            @Nro_DocumentoP     VARCHAR(20), 
                                            @Cod_TipoDocumentoC VARCHAR(5), 
                                            @Nro_DocumentoC     VARCHAR(20), 
                                            @Cod_Usuario        VARCHAR(32), 
                                            @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDocumentoP
                      AND Nro_Documento = @Nro_DocumentoP
            );
            DECLARE @Id_ClienteContacto INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDocumentoC
                      AND Nro_Documento = @Nro_DocumentoC
            );
            DELETE dbo.PRI_CLIENTE_CONTACTO
            WHERE dbo.PRI_CLIENTE_CONTACTO.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_CLIENTE_CONTACTO.Id_ClienteContacto = @Id_ClienteContacto;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_CUENTABANCARIA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_CUENTABANCARIA_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_D @Cod_TipoDocumento  VARCHAR(3), 
                                                  @Nro_Documento      VARCHAR(32), 
                                                  @NroCuenta_Bancaria VARCHAR(32), 
                                                  @Cod_Usuario        VARCHAR(32), 
                                                  @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DELETE dbo.PRI_CLIENTE_CUENTABANCARIA
            WHERE dbo.PRI_CLIENTE_CUENTABANCARIA.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_CLIENTE_CUENTABANCARIA.NroCuenta_Bancaria = @NroCuenta_Bancaria;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PRODUCTO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_PRODUCTO_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PRODUCTO_D @Cod_TipoDoc  VARCHAR(4), 
                                            @Doc_Cliente  VARCHAR(32), 
                                            @Cod_Producto VARCHAR(5), 
                                            @Cod_Usuario  VARCHAR(32), 
                                            @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDoc
                      AND @Doc_Cliente = Nro_Documento
            );
            DECLARE @Id_Producto INT=
            (
                SELECT Id_Producto
                FROM PRI_PRODUCTOS
                WHERE Cod_Producto = @Cod_Producto
            );
            DELETE dbo.PRI_CLIENTE_PRODUCTO
            WHERE dbo.PRI_CLIENTE_PRODUCTO.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_CLIENTE_PRODUCTO.Id_Producto = @Id_Producto;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_PROVEEDOR_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_D @Cod_TipoDocumento VARCHAR(3), 
                                             @Nro_Documento     VARCHAR(32), 
                                             @Cod_Usuario       VARCHAR(32), 
                                             @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DELETE dbo.PRI_CLIENTE_PROVEEDOR
            WHERE dbo.PRI_CLIENTE_PROVEEDOR.Id_ClienteProveedor = @Id_ClienteProveedor;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_VEHICULOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_VEHICULOS_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_VEHICULOS_D @Cod_TipoDoc VARCHAR(4), 
                                             @Doc_Cliente VARCHAR(32), 
                                             @Cod_Placa   VARCHAR(32), 
                                             @Cod_Usuario VARCHAR(32), 
                                             @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDoc
                      AND @Doc_Cliente = Nro_Documento
            );
            DELETE dbo.PRI_CLIENTE_VEHICULOS
            WHERE dbo.PRI_CLIENTE_VEHICULOS.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_CLIENTE_VEHICULOS.Cod_Placa = @Cod_Placa;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_VISITAS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CLIENTE_VISITAS_D;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_VISITAS_D @Cod_ClienteVisita VARCHAR(32), 
                                           @Cod_Usuario       VARCHAR(32), 
                                           @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_CLIENTE_VISITAS
            WHERE dbo.PRI_CLIENTE_VISITAS.Cod_ClienteVisita = @Cod_ClienteVisita;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CUENTA_CONTABLE_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_CUENTA_CONTABLE_D;
GO
CREATE PROCEDURE USP_PRI_CUENTA_CONTABLE_D @Cod_CuentaContable VARCHAR(16), 
                                           @Cod_Usuario        VARCHAR(32), 
                                           @Motivo             VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_CUENTA_CONTABLE
            WHERE dbo.PRI_CUENTA_CONTABLE.Cod_CuentaContable = @Cod_CuentaContable;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_DESCUENTOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_DESCUENTOS_D;
GO
CREATE PROCEDURE USP_PRI_DESCUENTOS_D @Cod_TipoDocumento VARCHAR(3), 
                                      @Nro_Documento     VARCHAR(32), 
                                      @Cod_TipoDescuento VARCHAR(32), 
                                      @Cod_Usuario       VARCHAR(32), 
                                      @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DECLARE @Id_Descuento INT=
            (
                SELECT pd.Id_Descuento
                FROM dbo.PRI_DESCUENTOS pd
                WHERE pd.Cod_TipoDescuento = @Cod_TipoDescuento
                      AND pd.Id_ClienteProveedor = @Id_ClienteProveedor
            );
            DELETE dbo.PRI_DESCUENTOS
            WHERE dbo.PRI_DESCUENTOS.Id_Descuento = @Id_Descuento;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_EMPRESA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_EMPRESA_D;
GO
CREATE PROCEDURE USP_PRI_EMPRESA_D @Cod_Empresa VARCHAR(32), 
                                   @Cod_Usuario VARCHAR(32), 
                                   @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_EMPRESA
            WHERE dbo.PRI_EMPRESA.Cod_Empresa = @Cod_Empresa;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_ESTABLECIMIENTOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_ESTABLECIMIENTOS_D;
GO
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_D @Cod_Establecimientos VARCHAR(32), 
                                            @Cod_TipoDocumento    VARCHAR(3), 
                                            @Nro_Documento        VARCHAR(32), 
                                            @Cod_Usuario          VARCHAR(32), 
                                            @Motivo               VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DELETE dbo.PRI_ESTABLECIMIENTOS
            WHERE dbo.PRI_ESTABLECIMIENTOS.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_ESTABLECIMIENTOS.Cod_Establecimientos = @Cod_Establecimientos;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_LICITACIONES_D;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_D @Cod_TipoDocumento INT, 
                                        @Nro_Documento     VARCHAR(32), 
                                        @Cod_Licitacion    VARCHAR(32), 
                                        @Cod_Usuario       VARCHAR(32), 
                                        @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento
            );
            DELETE dbo.PRI_LICITACIONES
            WHERE dbo.PRI_LICITACIONES.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_LICITACIONES.Cod_Licitacion = @Cod_Licitacion;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_D_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_LICITACIONES_D_D;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_D_D @Cod_TipoDocumento INT, 
                                          @Nro_Documento     VARCHAR(32), 
                                          @Cod_Licitacion    VARCHAR(32), 
                                          @Nro_Detalle       INT, 
                                          @Cod_Usuario       VARCHAR(32), 
                                          @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 Id_ClienteProveedor
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento
            );
            DELETE dbo.PRI_LICITACIONES_D
            WHERE dbo.PRI_LICITACIONES_D.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_LICITACIONES_D.Cod_Licitacion = @Cod_Licitacion
                  AND dbo.PRI_LICITACIONES_D.Nro_Detalle = @Nro_Detalle;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_LICITACIONES_M_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_LICITACIONES_M_D;
GO
CREATE PROCEDURE USP_PRI_LICITACIONES_M_D @Cod_TipoDoc         VARCHAR(4), 
                                          @Doc_Cliente         VARCHAR(32), 
                                          @Cod_Licitacion      VARCHAR(32), 
                                          @Nro_Detalle         INT, 
                                          @Cod_Libro           VARCHAR(4), 
                                          @Cod_TipoComprobante VARCHAR(4), 
                                          @Serie               VARCHAR(5), 
                                          @Numero              VARCHAR(32), 
                                          @Cod_Usuario         VARCHAR(32), 
                                          @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @id_ComprobantePago INT=
            (
                SELECT ISNULL(id_ComprobantePago, 0)
                FROM CAJ_COMPROBANTE_PAGO
                WHERE Cod_Libro = @Cod_Libro
                      AND Cod_TipoComprobante = @Cod_TipoComprobante
                      AND Serie = @Serie
                      AND Numero = @Numero
                      AND Cod_TipoDoc = @Cod_TipoDoc
                      AND Doc_Cliente = @Doc_Cliente
            );
            DECLARE @Id_Movimiento INT=
            (
                SELECT Id_Movimiento
                FROM PRI_LICITACIONES_M
                WHERE Cod_Licitacion = @Cod_Licitacion
                      AND Nro_Detalle = @Nro_Detalle
                      AND id_ComprobantePago = @id_ComprobantePago
            );
            DELETE dbo.PRI_LICITACIONES_M
            WHERE dbo.PRI_LICITACIONES_M.Id_Movimiento = @Id_Movimiento;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_MENSAJES_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_MENSAJES_D;
GO
CREATE PROCEDURE USP_PRI_MENSAJES_D @Cod_UsuarioRemite VARCHAR(32), 
                                    @Fecha_Remite      VARCHAR(32), 
                                    @Cod_UsuarioRecibe VARCHAR(32), 
                                    @Fecha_Recibe      VARCHAR(32), 
                                    @Cod_Usuario       VARCHAR(32), 
                                    @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Mensaje INT=
            (
                SELECT pm.Id_Mensaje
                FROM dbo.PRI_MENSAJES pm
                WHERE pm.Cod_UsuarioRemite = @Cod_UsuarioRemite
                      AND pm.Fecha_Remite = @Fecha_Remite
                      AND pm.Cod_UsuarioRecibe = @Cod_UsuarioRecibe
                      AND pm.Fecha_Recibe = @Fecha_Recibe
            );
            DELETE dbo.PRI_MENSAJES
            WHERE dbo.PRI_MENSAJES.Id_Mensaje = @Id_Mensaje;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PADRONES_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PADRONES_D;
GO
CREATE PROCEDURE USP_PRI_PADRONES_D @Cod_Padron        VARCHAR(32), 
                                    @Cod_TipoDocumento VARCHAR(3), 
                                    @Nro_Documento     VARCHAR(32), 
                                    @Cod_Usuario       VARCHAR(32), 
                                    @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_ClienteProveedor INT=
            (
                SELECT TOP 1 ISNULL(Id_ClienteProveedor, 0)
                FROM PRI_CLIENTE_PROVEEDOR
                WHERE(Cod_TipoDocumento = @Cod_TipoDocumento
                      AND Nro_Documento = @Nro_Documento)
            );
            DELETE dbo.PRI_PADRONES
            WHERE dbo.PRI_PADRONES.Id_ClienteProveedor = @Id_ClienteProveedor
                  AND dbo.PRI_PADRONES.Cod_Padron = @Cod_Padron;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PERSONAL_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PERSONAL_D;
GO
CREATE PROCEDURE USP_PRI_PERSONAL_D @Cod_Personal VARCHAR(32), 
                                    @Cod_Usuario  VARCHAR(32), 
                                    @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_PERSONAL
            WHERE dbo.PRI_PERSONAL.Cod_Personal = @Cod_Personal;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PERSONAL_PARENTESCO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PERSONAL_PARENTESCO_D;
GO
CREATE PROCEDURE USP_PRI_PERSONAL_PARENTESCO_D @Cod_Personal    VARCHAR(32), 
                                               @Item_Parentesco INT, 
                                               @Cod_Usuario     VARCHAR(32), 
                                               @Motivo          VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_PERSONAL_PARENTESCO
            WHERE dbo.PRI_PERSONAL_PARENTESCO.Cod_Personal = @Cod_Personal
                  AND dbo.PRI_PERSONAL_PARENTESCO.Item_Parentesco = @Item_Parentesco;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_DETALLE_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PRODUCTO_DETALLE_D;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_D @Cod_Producto INT, 
                                            @Item_Detalle INT, 
                                            @Cod_Usuario  VARCHAR(32), 
                                            @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Producto INT=
            (
                SELECT TOP 1 Id_Producto
                FROM PRI_PRODUCTOS
                WHERE Cod_Producto = @Cod_Producto
            );
            DELETE dbo.PRI_PRODUCTO_DETALLE
            WHERE dbo.PRI_PRODUCTO_DETALLE.Id_Producto = @Id_Producto
                  AND dbo.PRI_PRODUCTO_DETALLE.Item_Detalle = @Item_Detalle;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_PRECIO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PRODUCTO_PRECIO_D;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_D @Cod_Producto     VARCHAR(64), 
                                           @Cod_UnidadMedida VARCHAR(5), 
                                           @Cod_Almacen      VARCHAR(32), 
                                           @Cod_TipoPrecio   VARCHAR(5), 
                                           @Cod_Usuario      VARCHAR(32), 
                                           @Motivo           VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Producto INT=
            (
                SELECT TOP 1 Id_Producto
                FROM PRI_PRODUCTOS
                WHERE Cod_Producto = @Cod_Producto
            );
            DELETE dbo.PRI_PRODUCTO_PRECIO
            WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto = @Id_Producto
                  AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida = @Cod_UnidadMedida
                  AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen = @Cod_Almacen
                  AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio = @Cod_TipoPrecio;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PRODUCTO_STOCK_D;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_D @Cod_Producto     VARCHAR(64), 
                                          @Cod_UnidadMedida VARCHAR(5), 
                                          @Cod_Almacen      VARCHAR(32), 
                                          @Cod_Usuario      VARCHAR(32), 
                                          @Motivo           VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Producto INT=
            (
                SELECT TOP 1 Id_Producto
                FROM PRI_PRODUCTOS
                WHERE Cod_Producto = @Cod_Producto
            );
            DELETE dbo.PRI_PRODUCTO_STOCK
            WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto = @Id_Producto
                  AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida = @Cod_UnidadMedida
                  AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen = @Cod_Almacen;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PRODUCTO_TASA_D;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_D @Cod_Tasa     VARCHAR(32), 
                                         @Cod_Producto VARCHAR(32), 
                                         @Cod_Usuario  VARCHAR(32), 
                                         @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_Producto INT=
            (
                SELECT Id_Producto
                FROM PRI_PRODUCTOS
                WHERE Cod_Producto = @Cod_Producto
            );
            DELETE dbo.PRI_PRODUCTO_TASA
            WHERE dbo.PRI_PRODUCTO_TASA.Cod_Tasa = @Cod_Tasa
                  AND dbo.PRI_PRODUCTO_TASA.Id_Producto = @Id_Producto;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_PRODUCTOS_D;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_D @Cod_Producto VARCHAR(32), 
                                     @Cod_Usuario  VARCHAR(32), 
                                     @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_PRODUCTOS
            WHERE dbo.PRI_PRODUCTOS.Cod_Producto = @Cod_Producto;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_SUCURSAL_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_PRI_SUCURSAL_D;
GO
CREATE PROCEDURE USP_PRI_SUCURSAL_D @Cod_Sucursal VARCHAR(32), 
                                    @Cod_Usuario  VARCHAR(32), 
                                    @Motivo       VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.PRI_SUCURSAL
            WHERE dbo.PRI_SUCURSAL.Cod_Sucursal = @Cod_Sucursal;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_I;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_I @Cod_Caja                  VARCHAR(32), 
                                                   @Cod_Turno                 VARCHAR(32), 
                                                   @Cod_TipoComprobante       VARCHAR(5), 
                                                   @Cod_Libro                 VARCHAR(2), 
                                                   @Cod_Periodo               VARCHAR(8), 
                                                   @Serie                     VARCHAR(5), 
                                                   @Numero                    VARCHAR(30), 
                                                   @Fecha_Emision             VARCHAR(32), 
                                                   @Fecha_TrasladoBienes      VARCHAR(32), 
                                                   @Fecha_EntregaBienes       VARCHAR(32), 
                                                   @Cod_MotivoTraslado        VARCHAR(5), 
                                                   @Des_MotivoTraslado        VARCHAR(MAX), 
                                                   @Cod_ModalidadTraslado     VARCHAR(5), 
                                                   @Cod_UnidadMedida          VARCHAR(5), 
                                                   @Cod_TipoDocumento         VARCHAR(3), 
                                                   @Nro_Documento             VARCHAR(32), 
                                                   @Cod_UbigeoPartida         VARCHAR(8), 
                                                   @Direccion_Partida         VARCHAR(MAX), 
                                                   @Cod_UbigeoLlegada         VARCHAR(8), 
                                                   @Direccion_LLegada         VARCHAR(MAX), 
                                                   @Flag_Transbordo           BIT, 
                                                   @Peso_Bruto                NUMERIC(38, 6), 
                                                   @Nro_Contenedor            VARCHAR(64), 
                                                   @Cod_Puerto                VARCHAR(64), 
                                                   @Nro_Bulltos               INT, 
                                                   @Cod_EstadoGuia            VARCHAR(8), 
                                                   @Obs_GuiaRemisionRemitente VARCHAR(MAX), 
                                                   @Cod_TipoComprobanteBaja   VARCHAR(5), 
                                                   @Cod_LibroBaja             VARCHAR(2), 
                                                   @SerieBaja                 VARCHAR(5), 
                                                   @NumeroBaja                VARCHAR(30), 
                                                   @Flag_Anulado              BIT, 
                                                   @Valor_Resumen             VARCHAR(1024), 
                                                   @Valor_Firma               VARCHAR(2048), 
                                                   @Cod_UsuarioReg            VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_GuiaRemisionRemitente INT=
        (
            SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND cgrr.Cod_Libro = @Cod_Libro
                  AND cgrr.Serie = @Serie
                  AND cgrr.Numero = @Numero
        );
        DECLARE @Id_ClienteDestinatario INT=
        (
            SELECT TOP 1 pcp.Id_ClienteProveedor
            FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
            WHERE pcp.Cod_TipoDocumento = @Cod_TipoDocumento
                  AND pcp.Nro_Documento = @Nro_Documento
        );
        DECLARE @Id_GuiaRemisionRemitenteBaja INT=
        (
            SELECT TOP 1 cgrr.Id_GuiaRemisionRemitente
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobanteBaja
                  AND cgrr.Cod_Libro = @Cod_LibroBaja
                  AND cgrr.Serie = @SerieBaja
                  AND cgrr.Numero = @NumeroBaja
        );
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE
                VALUES
                (
                -- Id_GuiaRemisionRemitente - int
                @Cod_Caja, -- Cod_Caja - varchar
                @Cod_Turno, -- Cod_Turno - varchar
                @Cod_TipoComprobante, -- Cod_TipoComprobante - varchar
                @Cod_Libro, -- Cod_Libro - varchar
                @Cod_Periodo, -- Cod_Periodo - varchar
                @Serie, -- Serie - varchar
                @Numero, -- Numero - varchar
                CONVERT(DATETIME, @Fecha_Emision, 121), -- Fecha_Emision - datetime
                CONVERT(DATETIME, @Fecha_TrasladoBienes, 121), -- Fecha_TrasladoBienes - datetime
                CONVERT(DATETIME, @Fecha_EntregaBienes, 121), -- Fecha_EntregaBienes - datetime
                @Cod_MotivoTraslado, -- Cod_MotivoTraslado - varchar
                @Des_MotivoTraslado, -- Des_MotivoTraslado - varchar
                @Cod_ModalidadTraslado, -- Cod_ModalidadTraslado - varchar
                @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
                @Id_ClienteDestinatario, -- Id_ClienteDestinatario - int
                @Cod_UbigeoPartida, -- Cod_UbigeoPartida - varchar
                @Direccion_Partida, -- Direccion_Partida - varchar
                @Cod_UbigeoLlegada, -- Cod_UbigeoLlegada - varchar
                @Direccion_LLegada, -- Direccion_LLegada - varchar
                @Flag_Transbordo, -- Flag_Transbordo - bit
                @Peso_Bruto, -- Peso_Bruto - numeric
                @Nro_Contenedor, -- Nro_Contenedor - varchar
                @Cod_Puerto, -- Cod_Puerto - varchar
                @Nro_Bulltos, -- Nro_Bulltos - int
                @Cod_EstadoGuia, -- Cod_EstadoGuia - varchar
                @Obs_GuiaRemisionRemitente, -- Obs_GuiaRemisionRemitente - varchar
                @Id_GuiaRemisionRemitenteBaja, -- Id_GuiaRemisionRemitenteBaja - int
                @Flag_Anulado, -- Flag_Anulado - bit
                @Valor_Resumen, -- Valor_Resumen - varchar
                @Valor_Firma, -- Valor_Firma - varchar
                @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                GETDATE(), -- Fecha_Reg - datetime
                NULL, -- Cod_UsuarioAct - varchar
                NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE
                  SET
                --Id_GuiaRemisionRemitente - column value is auto-generated
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Caja = @Cod_Caja, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Turno = @Cod_Turno, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_TipoComprobante = @Cod_TipoComprobante, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Libro = @Cod_Libro, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Periodo = @Cod_Periodo, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Serie = @Serie, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Numero = @Numero, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121), -- datetime
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_TrasladoBienes = CONVERT(DATETIME, @Fecha_TrasladoBienes, 121), -- datetime
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_EntregaBienes = CONVERT(DATETIME, @Fecha_EntregaBienes, 121), -- datetime
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_MotivoTraslado = @Cod_MotivoTraslado, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Des_MotivoTraslado = @Des_MotivoTraslado, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_ModalidadTraslado = @Cod_ModalidadTraslado, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UnidadMedida = @Cod_UnidadMedida, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Id_ClienteDestinatario = @Id_ClienteDestinatario, -- int
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoPartida = @Cod_UbigeoPartida, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_Partida = @Direccion_Partida, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoLlegada = @Cod_UbigeoLlegada, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_LLegada = @Direccion_LLegada, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Transbordo = @Flag_Transbordo, -- bit
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Peso_Bruto = @Peso_Bruto, -- numeric
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Contenedor = @Nro_Contenedor, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Puerto = @Cod_Puerto, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Bulltos = @Nro_Bulltos, -- int
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_EstadoGuia = @Cod_EstadoGuia, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Obs_GuiaRemisionRemitente = @Obs_GuiaRemisionRemitente, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitenteBaja = @Id_GuiaRemisionRemitenteBaja, -- int
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Anulado = @Flag_Anulado, -- bit
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Valor_Resumen = @Valor_Resumen, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Valor_Firma = @Valor_Firma, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_GUIA_REMISION_REMITENTE_D;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D @Cod_Libro           VARCHAR(8), 
                                                   @Cod_TipoComprobante VARCHAR(8), 
                                                   @Serie               VARCHAR(5), 
                                                   @Numero              VARCHAR(32), 
                                                   @Cod_Usuario         VARCHAR(32), 
                                                   @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Libro = @Cod_Libro
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE.Serie = @Serie
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE.Numero = @Numero;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_D_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_I;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_I @Cod_TipoComprobante VARCHAR(5), 
                                                     @Cod_Libro           VARCHAR(2), 
                                                     @Serie               VARCHAR(5), 
                                                     @Numero              VARCHAR(30), 
                                                     @Id_Detalle          INT, 
                                                     @Cod_Almacen         VARCHAR(32), 
                                                     @Cod_UnidadMedida    VARCHAR(5), 
                                                     @Cod_Producto        VARCHAR(64), 
                                                     @Cantidad            NUMERIC(38, 10), 
                                                     @Descripcion         VARCHAR(MAX), 
                                                     @Peso                NUMERIC(38, 6), 
                                                     @Obs_Detalle         VARCHAR(MAX), 
                                                     @Cod_ProductoSunat   VARCHAR(32), 
                                                     @Cod_UsuarioReg      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_GuiaRemisionRemitente INT=
        (
            SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND cgrr.Cod_Libro = @Cod_Libro
                  AND cgrr.Serie = @Serie
                  AND cgrr.Numero = @Numero
        );
        DECLARE @Id_Producto INT=
        (
            SELECT  pp.Id_Producto
            FROM dbo.PRI_PRODUCTOS pp
            WHERE pp.Cod_Producto = @Cod_Producto
        );
        IF NOT EXISTS
        (
            SELECT cgrrd.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
            WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND cgrrd.Id_Detalle = @Id_Detalle
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_D
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Id_Detalle, -- Id_Detalle - int
                 @Cod_Almacen, -- Cod_Almacen - varchar
                 @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
                 @Id_Producto, -- Id_Producto - int
                 @Cantidad, -- Cantidad - numeric
                 @Descripcion, -- Descripcion - varchar
                 @Peso, -- Peso - numeric
                 @Obs_Detalle, -- Obs_Detalle - varchar
                 @Cod_ProductoSunat, -- Cod_ProductoSunat - varchar
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_D
                  SET 
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_Almacen = @Cod_Almacen, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UnidadMedida = @Cod_UnidadMedida, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Producto = @Id_Producto, -- int
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cantidad = @Cantidad, -- numeric
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Descripcion = @Descripcion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Peso = @Peso, -- numeric
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Obs_Detalle = @Obs_Detalle, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_ProductoSunat = @Cod_ProductoSunat, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle = @Id_Detalle;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_D_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_GUIA_REMISION_REMITENTE_D_D;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_D @Cod_TipoComprobante VARCHAR(8), 
                                                     @Cod_Libro           VARCHAR(2), 
                                                     @Serie               VARCHAR(5), 
                                                     @Numero              VARCHAR(32), 
                                                     @Id_Detalle          INT, 
                                                     @Cod_Usuario         VARCHAR(32), 
                                                     @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_GuiaRemisionRemitente INT=
            (
                SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND cgrr.Cod_Libro = @Cod_Libro
                      AND cgrr.Serie = @Serie
                      AND cgrr.Numero = @Numero
            );
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle = @Id_Detalle;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_I;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_I @Cod_TipoComprobante VARCHAR(5), 
                                                                @Cod_Libro           VARCHAR(2), 
                                                                @Serie               VARCHAR(5), 
                                                                @Numero              VARCHAR(30), 
                                                                @Item                INT, 
                                                                @Cod_TipoDocumento   VARCHAR(5), 
                                                                @SerieRelacionado               VARCHAR(32), 
                                                                @NumeroRelacionado            VARCHAR(128), 
                                                                @Observacion         VARCHAR(MAX), 
                                                                @Cod_UsuarioReg      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_GuiaRemisionRemitente INT=
        (
            SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND cgrr.Cod_Libro = @Cod_Libro
                  AND cgrr.Serie = @Serie
                  AND cgrr.Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT cgrrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
            WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND cgrrr.Item = @Item
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Item, -- Item - int
                 @Cod_TipoDocumento, -- Cod_TipoDocumento - varchar
                 @SerieRelacionado, -- Serie - varchar
                 @NumeroRelacionado, -- Numero - varchar
                 @Observacion, -- Observacion - varchar
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                  SET 
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Cod_TipoDocumento = @Cod_TipoDocumento, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Serie = @SerieRelacionado, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Numero = @NumeroRelacionado, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Observacion = @Observacion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Item;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_D;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_D @Cod_TipoComprobante VARCHAR(8), 
                                                                @Cod_Libro           VARCHAR(2), 
                                                                @Serie               VARCHAR(5), 
                                                                @Numero              VARCHAR(32), 
                                                                @Item                INT, 
                                                                @Cod_Usuario         VARCHAR(32), 
                                                                @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_GuiaRemisionRemitente INT=
            (
                SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND cgrr.Cod_Libro = @Cod_Libro
                      AND cgrr.Serie = @Serie
                      AND cgrr.Numero = @Numero
            );
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_I;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_I @Cod_TipoComprobante     VARCHAR(5), 
                                                                  @Cod_Libro               VARCHAR(2), 
                                                                  @Serie                   VARCHAR(5), 
                                                                  @Numero                  VARCHAR(30), 
                                                                  @Item                    INT, 
                                                                  @Cod_TipoDocumento       VARCHAR(5), 
                                                                  @Numero_Documento        VARCHAR(64), 
                                                                  @Nombres                 VARCHAR(MAX), 
                                                                  @Direccion               VARCHAR(MAX), 
                                                                  @Cod_ModalidadTransporte VARCHAR(5), 
                                                                  @Licencia                VARCHAR(64), 
                                                                  @Observaciones           VARCHAR(MAX), 
                                                                  @Cod_UsuarioReg          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_GuiaRemisionRemitente INT=
        (
            SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND cgrr.Cod_Libro = @Cod_Libro
                  AND cgrr.Serie = @Serie
                  AND cgrr.Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT cgrrt.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
            WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND cgrrt.Item = @Item
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Item, -- Item - int
                 @Cod_TipoDocumento, -- Cod_TipoDocumento - varchar
                 @Numero_Documento, -- Numero_Documento - varchar
                 @Nombres, -- Nombres - varchar
                 @Direccion, -- Direccion - varchar
                 @Cod_ModalidadTransporte, -- Cod_ModalidadTransporte - varchar
                 @Licencia, -- Licencia - varchar
                 @Observaciones, -- Observaciones - varchar
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                  SET 
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_TipoDocumento = @Cod_TipoDocumento, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Numero_Documento = @Numero_Documento, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Nombres = @Nombres, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Direccion = @Direccion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_ModalidadTransporte = @Cod_ModalidadTransporte, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Licencia = @Licencia, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Observaciones = @Observaciones, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Item = @Item;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_D;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_D @Cod_TipoComprobante VARCHAR(8), 
                                                                  @Cod_Libro           VARCHAR(2), 
                                                                  @Serie               VARCHAR(5), 
                                                                  @Numero              VARCHAR(32), 
                                                                  @Item                INT, 
                                                                  @Cod_Usuario         VARCHAR(32), 
                                                                  @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_GuiaRemisionRemitente INT=
            (
                SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND cgrr.Cod_Libro = @Cod_Libro
                      AND cgrr.Serie = @Serie
                      AND cgrr.Numero = @Numero
            );
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_I;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_I @Cod_TipoComprobante      VARCHAR(5), 
                                                             @Cod_Libro                VARCHAR(2), 
                                                             @Serie                    VARCHAR(5), 
                                                             @Numero                   VARCHAR(30), 
                                                             @Item                     INT, 
                                                             @Placa                    VARCHAR(64), 
                                                             @Certificado_Inscripcion  VARCHAR(1024), 
                                                             @Certificado_Habilitacion VARCHAR(1024), 
                                                             @Observaciones            VARCHAR(MAX), 
                                                             @Cod_UsuarioReg           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id_GuiaRemisionRemitente INT=
        (
            SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND cgrr.Cod_Libro = @Cod_Libro
                  AND cgrr.Serie = @Serie
                  AND cgrr.Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT cgrrv.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
            WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND cgrrv.Item = @Item
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Item, -- Item - int
                 @Placa, -- Placa - varchar
                 @Certificado_Inscripcion, -- Certificado_Inscripcion - varchar
                 @Certificado_Habilitacion, -- Certificado_Habilitacion - varchar
                 @Observaciones, -- Observaciones - varchar
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                  SET 
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Placa = @Placa, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Certificado_Inscripcion = @Certificado_Inscripcion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Certificado_Habilitacion = @Certificado_Habilitacion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Observaciones = @Observaciones, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Item = @Item;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_D;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_D @Cod_TipoComprobante VARCHAR(8), 
                                                             @Cod_Libro           VARCHAR(2), 
                                                             @Serie               VARCHAR(5), 
                                                             @Numero              VARCHAR(32), 
                                                             @Item                INT, 
                                                             @Cod_Usuario         VARCHAR(32), 
                                                             @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @Id_GuiaRemisionRemitente INT=
            (
                SELECT ISNULL(cgrr.Id_GuiaRemisionRemitente, 0)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND cgrr.Cod_Libro = @Cod_Libro
                      AND cgrr.Serie = @Serie
                      AND cgrr.Numero = @Numero
            );
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Item = @Item;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_LETRA_CAMBIO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_I;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_I @Id_Letra             INT, 
                                        @Nro_Letra            VARCHAR(32), 
                                        @Cod_Libro            VARCHAR(2), 
                                        @Ref_Girador          VARCHAR(1024), 
                                        @Fecha_Girado         VARCHAR(32), 
                                        @Fecha_Vencimiento    VARCHAR(32), 
                                        @Fecha_Pago           VARCHAR(32), 
                                        @Cod_Cuenta           VARCHAR(64), 
                                        @Nro_Operacion        VARCHAR(32), 
                                        @Cod_Moneda           VARCHAR(5), 
                                        @Cod_LibroComprobante VARCHAR(2), 
                                        @Cod_TipoComprobante  VARCHAR(5), 
                                        @Serie                VARCHAR(5), 
                                        @Numero               VARCHAR(30), 
                                        @Cod_Estado           VARCHAR(32), 
                                        @Nro_Referencia       VARCHAR(32), 
                                        @Monto_Base           NUMERIC(32, 3), 
                                        @Monto_Real           NUMERIC(32, 3), 
                                        @Observaciones        VARCHAR(MAX), 
                                        @Cod_UsuarioReg       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @Id INT=
        (
            SELECT clc.Id
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Nro_Letra = @Nro_Letra
                  AND clc.Cod_Libro = @Cod_Libro
                  AND clc.Cod_Cuenta = @Cod_Cuenta
                  AND clc.Cod_Moneda = @Cod_Moneda
        );
        DECLARE @Id_Comprobante INT=
        (
            SELECT ISNULL(ccp.id_ComprobantePago, 0)
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND ccp.Cod_Libro = @Cod_LibroComprobante
                  AND ccp.Serie = @Serie
                  AND ccp.Numero = @Numero
        );
        IF NOT EXISTS
        (
            SELECT clc.*
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        )
            BEGIN
                INSERT INTO dbo.CAJ_LETRA_CAMBIO
                VALUES
                (
                -- Id - int
                @Id_Letra, -- Id_Letra - int
                @Nro_Letra, -- Nro_Letra - varchar
                @Cod_Libro, -- Cod_Libro - varchar
                @Ref_Girador, -- Ref_Girador - varchar
                CONVERT(DATETIME, @Fecha_Girado, 121), -- Fecha_Girado - datetime
                CONVERT(DATETIME, @Fecha_Vencimiento, 121), -- Fecha_Vencimiento - datetime
                CONVERT(DATETIME, @Fecha_Pago, 121), -- Fecha_Pago - datetime
                @Cod_Cuenta, -- Cod_Cuenta - varchar
                @Nro_Operacion, -- Nro_Operacion - varchar
                @Cod_Moneda, -- Cod_Moneda - varchar
                @Id_Comprobante, -- Id_Comprobante - int
                @Cod_Estado, -- Cod_Estado - varchar
                @Nro_Referencia, -- Nro_Referencia - varchar
                @Monto_Base, -- Monto_Base - numeric
                @Monto_Real, -- Monto_Real - numeric
                @Observaciones, -- Observaciones - varchar
                @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                GETDATE(), -- Fecha_Reg - datetime
                NULL, -- Cod_UsuarioAct - varchar
                NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_LETRA_CAMBIO
                  SET
                --Id - column value is auto-generated
                      dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra, -- int
                      dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Ref_Girador = @Ref_Girador, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Fecha_Girado = CONVERT(DATETIME, @Fecha_Girado, 121), -- datetime
                      dbo.CAJ_LETRA_CAMBIO.Fecha_Vencimiento = CONVERT(DATETIME, @Fecha_Vencimiento, 121), -- datetime
                      dbo.CAJ_LETRA_CAMBIO.Fecha_Pago = CONVERT(DATETIME, @Fecha_Pago, 121), -- datetime
                      dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Nro_Operacion = @Nro_Operacion, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Id_Comprobante = @Id_Comprobante, -- int
                      dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @Cod_Estado, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Nro_Referencia = @Nro_Referencia, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Monto_Base = @Monto_Base, -- numeric
                      dbo.CAJ_LETRA_CAMBIO.Monto_Real = @Monto_Real, -- numeric
                      dbo.CAJ_LETRA_CAMBIO.Observaciones = @Observaciones, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_LETRA_CAMBIO.Id = @Id;
        END;
    END;
GO

IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_LETRA_CAMBIO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_LETRA_CAMBIO_D;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_D @Id_Letra    INT, 
                                        @Nro_Letra   VARCHAR(32), 
                                        @Cod_Libro   VARCHAR(2), 
                                        @Cod_Cuenta  VARCHAR(64), 
                                        @Cod_Moneda  VARCHAR(5), 
                                        @Cod_Usuario VARCHAR(32), 
                                        @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_LETRA_CAMBIO
            WHERE dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra
                  AND dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra
                  AND dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro
                  AND dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_RESUMEN_DIARIO_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_RESUMEN_DIARIO_I;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_I @Fecha_Serie    VARCHAR(16), 
                                          @Numero         VARCHAR(8), 
                                          @Ticket         VARCHAR(64), 
                                          @Nom_Estado     VARCHAR(64), 
                                          @Fecha_Envio    DATETIME, 
                                          @Total_Resumen  NUMERIC(38, 4), 
                                          @Cod_UsuarioReg VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
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
                (@Fecha_Serie, -- Fecha_Serie - varchar
                 @Numero, -- Numero - varchar
                 @Ticket, -- Ticket - varchar
                 @Nom_Estado, -- Nom_Estado - varchar
                 CONVERT(DATETIME, @Fecha_Envio, 121), -- Fecha_Envio - datetime
                 @Total_Resumen, -- Total_Resumen - numeric
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_RESUMEN_DIARIO
                  SET 
                      dbo.CAJ_RESUMEN_DIARIO.Ticket = @Ticket, -- varchar
                      dbo.CAJ_RESUMEN_DIARIO.Nom_Estado = @Nom_Estado, -- varchar
                      dbo.CAJ_RESUMEN_DIARIO.Fecha_Envio = CONVERT(DATETIME, @Fecha_Envio, 121), -- datetime
                      dbo.CAJ_RESUMEN_DIARIO.Total_Resumen = @Total_Resumen, -- numeric
                      dbo.CAJ_RESUMEN_DIARIO.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_RESUMEN_DIARIO.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_RESUMEN_DIARIO.Fecha_Serie = @Fecha_Serie
                      AND dbo.CAJ_RESUMEN_DIARIO.Numero = @Numero;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_RESUMEN_DIARIO_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_RESUMEN_DIARIO_D;
GO
CREATE PROCEDURE USP_CAJ_RESUMEN_DIARIO_D @Fecha_Serie VARCHAR(16), 
                                          @Numero      VARCHAR(8), 
                                          @Cod_Usuario VARCHAR(32), 
                                          @Motivo      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_RESUMEN_DIARIO
            WHERE dbo.CAJ_RESUMEN_DIARIO.Fecha_Serie = @Fecha_Serie
                  AND dbo.CAJ_RESUMEN_DIARIO.Numero = @Numero;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMUNICACION_BAJA_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMUNICACION_BAJA_I;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_I @Cod_TipoComprobante VARCHAR(8), 
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
        SET DATEFORMAT YMD;
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
                (@Cod_TipoComprobante, -- Cod_TipoComprobante - varchar
                 @Serie, -- Serie - varchar
                 @Numero, -- Numero - varchar
                 CONVERT(DATETIME, @Fecha_Emision, 121), -- Fecha_Emision - datetime
                 @Numero_Comunicado, -- Numero_Comunicado - varchar
                 @Justificacion, -- Justificacion - varchar
                 CONVERT(DATETIME, @Fecha_Comunicacion, 121), -- Fecha_Comunicacion - datetime
                 @Ticket, -- Ticket - varchar
                 @Mensaje_Respuesta, -- Mensaje_Respuesta - varchar
                 @Cod_Estado, -- Cod_Estado - varchar
                 @Cod_Usuario, -- Cod_Usuario - varchar
                 @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_COMUNICACION_BAJA
                  SET 
                      dbo.CAJ_COMUNICACION_BAJA.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121), -- datetime
                      dbo.CAJ_COMUNICACION_BAJA.Numero_Comunicado = @Numero_Comunicado, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Justificacion = @Justificacion, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Fecha_Comunicacion = CONVERT(DATETIME, @Fecha_Comunicacion, 121), -- datetime
                      dbo.CAJ_COMUNICACION_BAJA.Ticket = @Ticket, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Mensaje_Respuesta = @Mensaje_Respuesta, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Cod_Estado = @Cod_Estado, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Cod_Usuario = @Cod_Usuario, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.CAJ_COMUNICACION_BAJA.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_COMUNICACION_BAJA.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND dbo.CAJ_COMUNICACION_BAJA.Serie = @Serie
                      AND dbo.CAJ_COMUNICACION_BAJA.Numero = @Numero;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMUNICACION_BAJA_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_CAJ_COMUNICACION_BAJA_D;
GO
CREATE PROCEDURE USP_CAJ_COMUNICACION_BAJA_D @Cod_TipoComprobante VARCHAR(8), 
                                             @Serie               VARCHAR(5), 
                                             @Numero              VARCHAR(32), 
                                             @Cod_Usuario         VARCHAR(32), 
                                             @Motivo              VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.CAJ_COMUNICACION_BAJA
            WHERE dbo.CAJ_COMUNICACION_BAJA.Cod_TipoComprobante = @Cod_TipoComprobante
                  AND dbo.CAJ_COMUNICACION_BAJA.Serie = @Serie
                  AND dbo.CAJ_COMUNICACION_BAJA.Numero = @Numero;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO

-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_HIS_ELIMINADOS_I'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_I;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_I @Cod_Eliminado     VARCHAR(128), 
                                      @Tabla             VARCHAR(256), 
                                      @Cliente           VARCHAR(MAX), 
                                      @Detalle           VARCHAR(MAX), 
                                      @Fecha_Emision     VARCHAR(32), 
                                      @Fecha_Eliminacion VARCHAR(32), 
                                      @Responsable       VARCHAR(64), 
                                      @Justificacion     VARCHAR(MAX), 
                                      @Cod_UsuarioReg    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF NOT EXISTS
        (
            SELECT he.*
            FROM dbo.HIS_ELIMINADOS he
            WHERE he.Cod_Eliminado = @Cod_Eliminado
                  AND he.Tabla = @Tabla
                  AND he.Cliente = @Cliente
                  AND he.Detalle = @Detalle
                  AND he.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121)
                  AND he.Fecha_Eliminacion = CONVERT(DATETIME, @Fecha_Eliminacion, 121)
                  AND he.Responsable = @Responsable
                  AND he.Justificacion = @Justificacion
        )
            BEGIN
                INSERT INTO dbo.HIS_ELIMINADOS
                VALUES
                (
                -- Id - int
                @Cod_Eliminado, -- Cod_Eliminado - varchar
                @Tabla, -- Tabla - varchar
                @Cliente, -- Cliente - varchar
                @Detalle, -- Detalle - varchar
                CONVERT(DATETIME, @Fecha_Emision, 121), -- Fecha_Emision - datetime
                CONVERT(DATETIME, @Fecha_Eliminacion, 121), -- Fecha_Eliminacion - datetime
                @Responsable, -- Responsable - varchar
                @Justificacion, -- Justificacion - varchar
                @Cod_UsuarioReg, -- Cod_UsuarioReg - varchar
                GETDATE(), -- Fecha_Reg - datetime
                NULL, -- Cod_UsuarioAct - varchar
                NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.HIS_ELIMINADOS
                  SET
                --Id - column value is auto-generated
                      dbo.HIS_ELIMINADOS.Cod_Eliminado = @Cod_Eliminado, -- varchar
                      dbo.HIS_ELIMINADOS.Tabla = @Tabla, -- varchar
                      dbo.HIS_ELIMINADOS.Cliente = @Cliente, -- varchar
                      dbo.HIS_ELIMINADOS.Detalle = @Detalle, -- varchar
                      dbo.HIS_ELIMINADOS.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121), -- datetime
                      dbo.HIS_ELIMINADOS.Fecha_Eliminacion = CONVERT(DATETIME, @Fecha_Eliminacion, 121), -- datetime
                      dbo.HIS_ELIMINADOS.Responsable = @Responsable, -- varchar
                      dbo.HIS_ELIMINADOS.Justificacion = @Justificacion, -- varchar
                      dbo.HIS_ELIMINADOS.Cod_UsuarioAct = @Cod_UsuarioReg, -- varchar
                      dbo.HIS_ELIMINADOS.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.HIS_ELIMINADOS.Cod_Eliminado = @Cod_Eliminado
                      AND dbo.HIS_ELIMINADOS.Tabla = @Tabla
                      AND dbo.HIS_ELIMINADOS.Cliente = @Cliente
                      AND dbo.HIS_ELIMINADOS.Detalle = @Detalle
                      AND dbo.HIS_ELIMINADOS.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121)
                      AND dbo.HIS_ELIMINADOS.Fecha_Eliminacion = CONVERT(DATETIME, @Fecha_Eliminacion, 121)
                      AND dbo.HIS_ELIMINADOS.Responsable = @Responsable
                      AND dbo.HIS_ELIMINADOS.Justificacion = @Justificacion;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_HIS_ELIMINADOS_D'
          AND type = 'P'
)
    DROP PROCEDURE dbo.USP_HIS_ELIMINADOS_D;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_D @Cod_Eliminado     VARCHAR(128), 
                                      @Tabla             VARCHAR(256), 
                                      @Cliente           VARCHAR(MAX), 
                                      @Detalle           VARCHAR(MAX), 
                                      @Fecha_Emision     VARCHAR(32), 
                                      @Fecha_Eliminacion VARCHAR(32), 
                                      @Responsable       VARCHAR(64), 
                                      @Justificacion     VARCHAR(MAX), 
                                      @Cod_Usuario       VARCHAR(32), 
                                      @Motivo            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DELETE dbo.HIS_ELIMINADOS
            WHERE dbo.HIS_ELIMINADOS.Cod_Eliminado = @Cod_Eliminado
                  AND dbo.HIS_ELIMINADOS.Tabla = @Tabla
                  AND dbo.HIS_ELIMINADOS.Cliente = @Cliente
                  AND dbo.HIS_ELIMINADOS.Detalle = @Detalle
                  AND dbo.HIS_ELIMINADOS.Fecha_Emision = CONVERT(DATETIME, @Fecha_Emision, 121)
                  AND dbo.HIS_ELIMINADOS.Fecha_Eliminacion = CONVERT(DATETIME, @Fecha_Eliminacion, 121)
                  AND dbo.HIS_ELIMINADOS.Responsable = @Responsable
                  AND dbo.HIS_ELIMINADOS.Justificacion = @Justificacion;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO