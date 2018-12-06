--Script para los servidores
--Ejcuta procedimeintos de guardado para los scripts
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CONTACTO_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_CONTACTO_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_I 
	@Cod_TipoDocumentoP	varchar(5), 
	@Nro_DocumentoP	varchar(20), 
	@Cod_TipoDocumentoC	varchar(5), 
	@Nro_DocumentoC	varchar(20), 
	@Ap_Paterno	varchar(128), 
	@Ap_Materno	varchar(128), 
	@Nombres	varchar(128), 
	@Cod_Telefono	varchar(5), 
	@Nro_Telefono	varchar(64), 
	@Anexo	varchar(32), 
	@Email_Empresarial	varchar(512), 
	@Email_Personal	varchar(512), 
	@Celular	varchar(64), 
	@Cod_TipoRelacion	varchar(8), 
	@Fecha_Incorporacion	VARCHAR(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoP and Nro_Documento=@Nro_DocumentoP)
DECLARE @Id_ClienteContacto	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoC and Nro_Documento=@Nro_DocumentoC)
IF NOT EXISTS (SELECT * FROM PRI_CLIENTE_CONTACTO WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Id_ClienteContacto = @Id_ClienteContacto))
	BEGIN
		INSERT INTO PRI_CLIENTE_CONTACTO  VALUES (
		@Id_ClienteProveedor,
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
		CONVERT(DATETIME, @Fecha_Incorporacion,121),
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
			Fecha_Incorporacion = CONVERT(DATETIME,@Fecha_Incorporacion,121),
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Id_ClienteContacto = @Id_ClienteContacto)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_I
go
CREATE PROCEDURE USP_PRI_SUCURSAL_I 
	@Cod_Sucursal	varchar(32), 
	@Nom_Sucursal	varchar(32), 
	@Dir_Sucursal	varchar(512), 
	@Por_UtilidadMax	numeric(5,2), 
	@Por_UtilidadMin	numeric(5,2), 
	@Cod_UsuarioAdm	varchar(32), 
	@Cabecera_Pagina	varchar(1024), 
	@Pie_Pagina	varchar(1024), 
	@Flag_Activo	bit, 
	@Cod_Ubigeo	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Sucursal FROM PRI_SUCURSAL WHERE  (Cod_Sucursal = @Cod_Sucursal))
	BEGIN
		INSERT INTO PRI_SUCURSAL  VALUES (
		@Cod_Sucursal,
		@Nom_Sucursal,
		@Dir_Sucursal,
		@Por_UtilidadMax,
		@Por_UtilidadMin,
		@Cod_UsuarioAdm,
		@Cabecera_Pagina,
		@Pie_Pagina,
		@Flag_Activo,
		@Cod_Ubigeo,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Sucursal = @Cod_Sucursal)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PERSONAL_PARENTESCO_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PERSONAL_PARENTESCO_I
go
CREATE PROCEDURE USP_PRI_PERSONAL_PARENTESCO_I 
	@Cod_Personal	varchar(32), 
	@Item_Parentesco	int, 
	@Cod_TipoDoc	varchar(5), 
	@Num_Doc	varchar(20), 
	@ApellidoPaterno	varchar(124), 
	@ApellidoMaterno	varchar(124), 
	@Nombres	varchar(124), 
	@Cod_TipoParentesco	varchar(5), 
	@Obs_Parentesco	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Personal, @Item_Parentesco FROM PRI_PERSONAL_PARENTESCO WHERE  (Cod_Personal = @Cod_Personal) AND (Item_Parentesco = @Item_Parentesco))
	BEGIN
		INSERT INTO PRI_PERSONAL_PARENTESCO  VALUES (
		@Cod_Personal,
		@Item_Parentesco,
		@Cod_TipoDoc,
		@Num_Doc,
		@ApellidoPaterno,
		@ApellidoMaterno,
		@Nombres,
		@Cod_TipoParentesco,
		@Obs_Parentesco,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Personal = @Cod_Personal) AND (Item_Parentesco = @Item_Parentesco)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PERSONAL_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PERSONAL_I
go
CREATE PROCEDURE USP_PRI_PERSONAL_I 
	@Cod_Personal	varchar(32), 
	@Cod_TipoDoc	varchar(3), 
	@Num_Doc	varchar(20), 
	@ApellidoPaterno	varchar(64), 
	@ApellidoMaterno	varchar(64), 
	@PrimeroNombre	varchar(64), 
	@SegundoNombre	varchar(64), 
	@Direccion	varchar(128), 
	@Ref_Direccion	varchar(256), 
	@Telefono	varchar(256), 
	@Email	varchar(256), 
	@Fecha_Ingreso	varchar(32), 
	@Fecha_Nacimiento	varchar(32), 
	@Cod_Cargo	varchar(32), 
	@Cod_Estado	varchar(32), 
	@Cod_Area	varchar(32), 
	@Cod_Local	varchar(16), 
	@Cod_CentroCostos	varchar(16), 
	@Cod_EstadoCivil	varchar(32), 
	@Fecha_InsESSALUD	varchar(32), 
	@AutoGeneradoEsSalud	varchar(64), 
	@Cod_CuentaCTS	varchar(5), 
	@Num_CuentaCTS	varchar(128), 
	@Cod_BancoRemuneracion	varchar(5), 
	@Num_CuentaRemuneracion	varchar(128), 
	@Grupo_Sanguinio	varchar(64), 
	@Cod_AFP	varchar(32), 
	@AutoGeneradoAFP	varchar(32), 
	@Flag_CertificadoSalud	bit, 
	@Flag_CertificadoAntPoliciales	bit, 
	@Flag_CertificadorAntJudiciales	bit, 
	@Flag_DeclaracionBienes	bit, 
	@Flag_OtrosDocumentos	bit, 
	@Cod_Sexo	varchar(32), 
	@Cod_UsuarioLogin	varchar(32), 
	@Obs_Personal	xml,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Personal FROM PRI_PERSONAL WHERE  (Cod_Personal = @Cod_Personal))
	BEGIN
		INSERT INTO PRI_PERSONAL  VALUES (
		@Cod_Personal,
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
		convert(datetime,@Fecha_Ingreso,121),
		convert(datetime,@Fecha_Nacimiento,121),
		@Cod_Cargo,
		@Cod_Estado,
		@Cod_Area,
		@Cod_Local,
		@Cod_CentroCostos,
		@Cod_EstadoCivil,
		convert(datetime,@Fecha_InsESSALUD,121),
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
			Fecha_Ingreso = convert(datetime,@Fecha_Ingreso,121),
			Fecha_Nacimiento = convert(datetime,@Fecha_Nacimiento,121),
			Cod_Cargo = @Cod_Cargo, 
			Cod_Estado = @Cod_Estado, 
			Cod_Area = @Cod_Area, 
			Cod_Local = @Cod_Local, 
			Cod_CentroCostos = @Cod_CentroCostos, 
			Cod_EstadoCivil = @Cod_EstadoCivil, 
			Fecha_InsESSALUD = convert(datetime,@Fecha_InsESSALUD,121),
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
		WHERE (Cod_Personal = @Cod_Personal)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PADRONES_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PADRONES_I
go
CREATE PROCEDURE USP_PRI_PADRONES_I 
	@Cod_Padron	varchar(32), 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Cod_TipoPadron	varchar(32), 
	@Des_Padron	varchar(32), 
	@Fecha_Inicio	varchar(32), 
	@Fecha_Fin	varchar(32), 
	@Nro_Resolucion	varchar(64),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT * FROM PRI_PADRONES WHERE  (Cod_Padron = @Cod_Padron) AND (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_PADRONES  VALUES (
		@Cod_Padron,
		@Id_ClienteProveedor,
		@Cod_TipoPadron,
		@Des_Padron,
		CONVERT(DATETIME, @Fecha_Inicio,121),
		CONVERT(datetime, @Fecha_Fin, 121),
		@Nro_Resolucion,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_PADRONES
		SET	
			Cod_TipoPadron = @Cod_TipoPadron, 
			Des_Padron = @Des_Padron, 
			Fecha_Inicio = CONVERT(DATETIME, @Fecha_Inicio,121),
			Fecha_Fin = CONVERT(datetime, @Fecha_Fin, 121),
			Nro_Resolucion = @Nro_Resolucion,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Padron = @Cod_Padron) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_MENSAJES_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_MENSAJES_I
go
CREATE PROCEDURE USP_PRI_MENSAJES_I  
	@Cod_UsuarioRemite	varchar(32), 
	@Fecha_Remite	VARCHAR(32), 
	@Mensaje	varchar(1024), 
	@Flag_Leido	bit, 
	@Cod_UsuarioRecibe	varchar(32), 
	@Fecha_Recibe	VARCHAR(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Mensaje	int =(SELECT pm.Id_Mensaje FROM dbo.PRI_MENSAJES pm WHERE pm.Cod_UsuarioRemite=@Cod_UsuarioRemite 
AND pm.Fecha_Remite=@Fecha_Remite AND pm.Cod_UsuarioRecibe=@Cod_UsuarioRecibe AND pm.Fecha_Recibe=@Fecha_Recibe)
IF NOT EXISTS (SELECT @Id_Mensaje FROM PRI_MENSAJES WHERE  (Id_Mensaje = @Id_Mensaje))
	BEGIN
		INSERT INTO PRI_MENSAJES  VALUES (
		@Cod_UsuarioRemite,
		CONVERT(datetime, @Fecha_Remite,121),
		@Mensaje,
		@Flag_Leido,
		@Cod_UsuarioRecibe,
		CONVERT(DATETIME, @Fecha_Recibe ,121),
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE PRI_MENSAJES
		SET	
			Cod_UsuarioRemite = @Cod_UsuarioRemite, 
			Fecha_Remite = CONVERT(datetime, @Fecha_Remite,121),
			Mensaje = @Mensaje, 
			Flag_Leido = @Flag_Leido, 
			Cod_UsuarioRecibe = @Cod_UsuarioRecibe, 
			Fecha_Recibe = CONVERT(DATETIME, @Fecha_Recibe ,121),
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Mensaje = @Id_Mensaje)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_I
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_I 
	@Cod_Establecimientos	varchar(32), 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Des_Establecimiento	varchar(512), 
	@Cod_TipoEstablecimiento	varchar(5), 
	@Direccion	varchar(1024), 
	@Telefono	varchar(1024), 
	@Obs_Establecimiento	varchar(1024), 
	@Cod_Ubigeo	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT * FROM PRI_ESTABLECIMIENTOS WHERE  (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_ESTABLECIMIENTOS  VALUES (
		@Cod_Establecimientos,
		@Id_ClienteProveedor,
		@Des_Establecimiento,
		@Cod_TipoEstablecimiento,
		@Direccion,
		@Telefono,
		@Obs_Establecimiento,
		@Cod_Ubigeo,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_I
go
CREATE PROCEDURE USP_PRI_EMPRESA_I 
	@Cod_Empresa	varchar(32), 
	@RUC	varchar(32), 
	@Nom_Comercial	varchar(1024), 
	@RazonSocial	varchar(1024), 
	@Direccion	varchar(1024), 
	@Telefonos	varchar(512), 
	@Web	varchar(512), 
	@Imagen_H	binary, 
	@Imagen_V	binary, 
	@Flag_ExoneradoImpuesto	bit, 
	@Des_Impuesto	varchar(16), 
	@Por_Impuesto	numeric(5,2), 
	@EstructuraContable	varchar(32), 
	@Version	varchar(32), 
	@Cod_Ubigeo	varchar(8),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Empresa FROM PRI_EMPRESA WHERE  (Cod_Empresa = @Cod_Empresa))
	BEGIN
		INSERT INTO PRI_EMPRESA  VALUES (
		@Cod_Empresa,
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Empresa = @Cod_Empresa)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_DESCUENTOS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_DESCUENTOS_I
go
CREATE PROCEDURE USP_PRI_DESCUENTOS_I 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Cod_TipoDescuento	varchar(32), 
	@Aplica	varchar(64), 
	@Cod_Aplica	varchar(32), 
	@Cod_TipoCliente	varchar(32), 
	@Cod_TipoPrecio	varchar(5), 
	@Monto_Precio	numeric(38,6), 
	@Fecha_Inicia	VARCHAR(32), 
	@Fecha_Fin	VARCHAR(32), 
	@Obs_Descuento	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
DECLARE @Id_Descuento	int = (SELECT pd.Id_Descuento FROM dbo.PRI_DESCUENTOS pd WHERE pd.Cod_TipoDescuento=@Cod_TipoDescuento AND pd.Id_ClienteProveedor=@Id_ClienteProveedor)
IF NOT EXISTS (SELECT * FROM PRI_DESCUENTOS WHERE  (Id_Descuento = @Id_Descuento))
	BEGIN
		INSERT INTO PRI_DESCUENTOS  VALUES (
		@Id_ClienteProveedor,
		@Cod_TipoDescuento,
		@Aplica,
		@Cod_Aplica,
		@Cod_TipoCliente,
		@Cod_TipoPrecio,
		@Monto_Precio,
		CONVERT(datetime, @Fecha_Inicia,121),
		CONVERT(DATETIME, @Fecha_Fin,121),
		@Obs_Descuento,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
			Fecha_Inicia = CONVERT(datetime, @Fecha_Inicia,121),
			Fecha_Fin = CONVERT(DATETIME, @Fecha_Fin,121),
			Obs_Descuento = @Obs_Descuento,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Descuento = @Id_Descuento)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CUENTA_CONTABLE_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CUENTA_CONTABLE_I
go
CREATE PROCEDURE USP_PRI_CUENTA_CONTABLE_I 
	@Cod_CuentaContable	varchar(16), 
	@Des_CuentaContable	varchar(128), 
	@Tipo_Cuenta	varchar(32), 
	@Cod_Moneda	varchar(5), 
	@Flag_CuentaAnalitica	bit, 
	@Flag_CentroCostos	bit, 
	@Flag_CuentaBancaria	bit, 
	@Cod_EntidadBancaria	varchar(5), 
	@Numero_Cuenta	varchar(64), 
	@Clase_Cuenta	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_CuentaContable FROM PRI_CUENTA_CONTABLE WHERE  (Cod_CuentaContable = @Cod_CuentaContable))
	BEGIN
		INSERT INTO PRI_CUENTA_CONTABLE  VALUES (
		@Cod_CuentaContable,
		@Des_CuentaContable,
		@Tipo_Cuenta,
		@Cod_Moneda,
		@Flag_CuentaAnalitica,
		@Flag_CentroCostos,
		@Flag_CuentaBancaria,
		@Cod_EntidadBancaria,
		@Numero_Cuenta,
		@Clase_Cuenta,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_CuentaContable = @Cod_CuentaContable)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_VISITAS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_VISITAS_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_VISITAS_I 
	@Cod_ClienteVisita	varchar(32), 
	@Cod_UsuarioVendedor	varchar(8), 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Ruta	varchar(64), 
	@Cod_TipoVisita	varchar(5), 
	@Cod_Resultado	varchar(5), 
	@Fecha_HoraVisita	VARCHAR(32), 
	@Comentarios	varchar(1024), 
	@Flag_Compromiso	bit, 
	@Fecha_HoraCompromiso	VARCHAR(32), 
	@Cod_UsuarioResponsable	varchar(8), 
	@Des_Compromiso	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT @Cod_ClienteVisita FROM PRI_CLIENTE_VISITAS WHERE  (Cod_ClienteVisita = @Cod_ClienteVisita))
	BEGIN
		INSERT INTO PRI_CLIENTE_VISITAS  VALUES (
		@Cod_ClienteVisita,
		@Cod_UsuarioVendedor,
		@Id_ClienteProveedor,
		@Ruta,
		@Cod_TipoVisita,
		@Cod_Resultado,
		CONVERT(datetime, @Fecha_HoraVisita,121),
		@Comentarios,
		@Flag_Compromiso,
		CONVERT (datetime,@Fecha_HoraCompromiso,121),
		@Cod_UsuarioResponsable,
		@Des_Compromiso,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_CLIENTE_VISITAS
		SET	
			Cod_UsuarioVendedor = @Cod_UsuarioVendedor, 
			Id_ClienteProveedor = @Id_ClienteProveedor, 
			Ruta = @Ruta, 
			Cod_TipoVisita = @Cod_TipoVisita, 
			Cod_Resultado = @Cod_Resultado, 
			Fecha_HoraVisita = CONVERT(datetime, @Fecha_HoraVisita,121),
			Comentarios = @Comentarios, 
			Flag_Compromiso = @Flag_Compromiso, 
			Fecha_HoraCompromiso = CONVERT (datetime,@Fecha_HoraCompromiso,121),
			Cod_UsuarioResponsable = @Cod_UsuarioResponsable, 
			Des_Compromiso = @Des_Compromiso,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_ClienteVisita = @Cod_ClienteVisita)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CUENTABANCARIA_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_I 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@NroCuenta_Bancaria	varchar(32), 
	@Cod_EntidadFinanciera	varchar(5), 
	@Cod_TipoCuentaBancaria	varchar(8), 
	@Des_CuentaBancaria	varchar(512), 
	@Flag_Principal	bit, 
	@Cuenta_Interbancaria	varchar(64), 
	@Obs_CuentaBancaria	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT * FROM PRI_CLIENTE_CUENTABANCARIA WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (NroCuenta_Bancaria = @NroCuenta_Bancaria))
	BEGIN
		INSERT INTO PRI_CLIENTE_CUENTABANCARIA  VALUES (
		@Id_ClienteProveedor,
		@NroCuenta_Bancaria,
		@Cod_EntidadFinanciera,
		@Cod_TipoCuentaBancaria,
		@Des_CuentaBancaria,
		@Flag_Principal,
		@Cuenta_Interbancaria,
		@Obs_CuentaBancaria,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (NroCuenta_Bancaria = @NroCuenta_Bancaria)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CATEGORIA_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CATEGORIA_I
go
CREATE PROCEDURE USP_PRI_CATEGORIA_I 
	@Cod_Categoria	varchar(32), 
	@Des_Categoria	varchar(64), 
	@Foto	binary, 
	@Cod_CategoriaPadre	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Categoria FROM PRI_CATEGORIA WHERE  (Cod_Categoria = @Cod_Categoria))
	BEGIN
		INSERT INTO PRI_CATEGORIA  VALUES (
		@Cod_Categoria,
		@Des_Categoria,
		@Foto,
		@Cod_CategoriaPadre,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_CATEGORIA
		SET	
			Des_Categoria = @Des_Categoria, 
			Foto = @Foto, 
			Cod_CategoriaPadre = @Cod_CategoriaPadre,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Categoria = @Cod_Categoria)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_AREAS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_AREAS_I
go
CREATE PROCEDURE USP_PRI_AREAS_I 
	@Cod_Area	varchar(32), 
	@Cod_Sucursal	varchar(32), 
	@Des_Area	varchar(512), 
	@Numero	varchar(512), 
	@Cod_AreaPadre	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Area FROM PRI_AREAS WHERE  (Cod_Area = @Cod_Area))
	BEGIN
		INSERT INTO PRI_AREAS  VALUES (
		@Cod_Area,
		@Cod_Sucursal,
		@Des_Area,
		@Numero,
		@Cod_AreaPadre,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Area = @Cod_Area)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ACTIVIDADES_ECONOMICAS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_I
go
CREATE PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_I 
	@Cod_ActividadEconomica	varchar(32), 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@CIIU	varchar(32), 
	@Escala	varchar(64), 
	@Des_ActividadEconomica	varchar(512), 
	@Flag_Activo	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT @Cod_ActividadEconomica, @Id_ClienteProveedor FROM PRI_ACTIVIDADES_ECONOMICAS WHERE  (Cod_ActividadEconomica = @Cod_ActividadEconomica) AND (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_ACTIVIDADES_ECONOMICAS  VALUES (
		@Cod_ActividadEconomica,
		@Id_ClienteProveedor,
		@CIIU,
		@Escala,
		@Des_ActividadEconomica,
		@Flag_Activo,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_ActividadEconomica = @Cod_ActividadEconomica) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TIPOCAMBIO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_TIPOCAMBIO_I
go
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_I 
	@FechaHora	VARCHAR(32), 
	@Cod_Moneda	varchar(3), 
	@SunatCompra	numeric(38,4), 
	@SunatVenta	numeric(38,4), 
	@Compra	numeric(38,4), 
	@Venta	numeric(38,4),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_TipoCambio	int = (SELECT ct.Id_TipoCambio FROM dbo.CAJ_TIPOCAMBIO ct WHERE ct.FechaHora=@FechaHora AND ct.Cod_Moneda=@Cod_Moneda)
IF NOT EXISTS (SELECT @Id_TipoCambio FROM CAJ_TIPOCAMBIO WHERE  (Id_TipoCambio = @Id_TipoCambio))
	BEGIN
		INSERT INTO CAJ_TIPOCAMBIO  VALUES (
	    CONVERT(DATETIME, @FechaHora,121),
		@Cod_Moneda,
		@SunatCompra,
		@SunatVenta,
		@Compra,
		@Venta,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_TIPOCAMBIO
		SET	
			FechaHora = CONVERT(DATETIME, @FechaHora,121),
			Cod_Moneda = @Cod_Moneda, 
			SunatCompra = @SunatCompra, 
			SunatVenta = @SunatVenta, 
			Compra = @Compra, 
			Venta = @Venta,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_TipoCambio = @Id_TipoCambio)	
	END
END
go

-- -- Guadar
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_IMPUESTOS_I' AND type = 'P')
-- 	DROP PROCEDURE USP_CAJ_IMPUESTOS_I
-- go
-- CREATE PROCEDURE USP_CAJ_IMPUESTOS_I 
-- 	@Cod_TipoComprobante	varchar(5), 
-- 	@Serie varchar(4), 
-- 	@Numero	varchar(20), 
-- 	@Cod_Impuesto	varchar(32), 
-- 	@Porcentaje	numeric(5,2), 
-- 	@Monto	numeric(38,2), 
-- 	@Obs_Impuesto	varchar(1024),
-- 	@Cod_Usuario Varchar(32)
-- WITH ENCRYPTION
-- AS
-- BEGIN
-- DECLARE @id_ComprobantePago int = (SELECT TOP 1 ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Numero=@Numero)
-- IF NOT EXISTS (SELECT * FROM CAJ_IMPUESTOS WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Impuesto = @Cod_Impuesto))
-- 	BEGIN
-- 		INSERT INTO CAJ_IMPUESTOS  VALUES (
-- 		@id_ComprobantePago,
-- 		@Cod_Impuesto,
-- 		@Porcentaje,
-- 		@Monto,
-- 		@Obs_Impuesto,
-- 		@Cod_Usuario,GETDATE(),NULL,NULL)
		
-- 	END
-- 	ELSE
-- 	BEGIN
-- 		UPDATE CAJ_IMPUESTOS
-- 		SET	
-- 			Porcentaje = @Porcentaje, 
-- 			Monto = @Monto, 
-- 			Obs_Impuesto = @Obs_Impuesto,
-- 			Cod_UsuarioAct = @Cod_Usuario, 
-- 			Fecha_Act = GETDATE()
-- 		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Impuesto = @Cod_Impuesto)	
-- 	END
-- END
-- go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_LOG_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_LOG_I
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_I 
	@Cod_TipoComprobante	varchar(5), 
	@Serie varchar(4), 
	@Numero	varchar(20), 
	@Item	int, 
	@Cod_Estado	varchar(32), 
	@Cod_Mensaje	varchar(32), 
	@Mensaje	varchar(512),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago int = (SELECT TOP 1 ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Numero=@Numero)
IF NOT EXISTS (SELECT @id_ComprobantePago, @Item FROM CAJ_COMPROBANTE_LOG WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (Item = @Item))
	BEGIN
		INSERT INTO CAJ_COMPROBANTE_LOG  VALUES (
		@id_ComprobantePago,
		@Item,
		@Cod_Estado,
		@Cod_Mensaje,
		@Mensaje,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_COMPROBANTE_LOG
		SET	
			Cod_Estado = @Cod_Estado, 
			Cod_Mensaje = @Cod_Mensaje, 
			Mensaje = @Mensaje,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Item = @Item)	
	END
END
go


-- -- Guadar
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_GUIA_I' AND type = 'P')
-- 	DROP PROCEDURE USP_CAJ_COMPROBANTE_GUIA_I
-- go
-- CREATE PROCEDURE USP_CAJ_COMPROBANTE_GUIA_I
-- 	@Cod_TipoComprobanteGuia	varchar(5), 
-- 	@SerieGuia	varchar(4), 
-- 	@NumeroGuia	varchar(20), 
-- 	@Cod_TipoComprobanteComprobante	varchar(5), 
-- 	@SerieComprobante	varchar(4), 
-- 	@NumeroComprobante	varchar(20), 
-- 	@Flag_Relacion	bit,
-- 	@Cod_Usuario Varchar(32)
-- WITH ENCRYPTION
-- AS
-- BEGIN
-- DECLARE @Id_GuiaRemision	int = (SELECT TOP 1 ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobanteGuia AND ccp.Serie=@SerieGuia AND ccp.Numero=@NumeroGuia)
-- DECLARE @id_ComprobantePago	int=(SELECT TOP 1 ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobanteComprobante AND ccp.Serie=@SerieComprobante AND ccp.Numero=@NumeroComprobante)
-- IF NOT EXISTS (SELECT * FROM CAJ_COMPROBANTE_GUIA WHERE  (Id_GuiaRemision = @Id_GuiaRemision) AND (id_ComprobantePago = @id_ComprobantePago))
-- 	BEGIN
-- 		INSERT INTO CAJ_COMPROBANTE_GUIA  VALUES (
-- 		@Id_GuiaRemision,
-- 		@Flag_Relacion,
-- 		@Cod_Usuario,GETDATE(),NULL,NULL)
-- 	END
-- 	ELSE
-- 	BEGIN
-- 		UPDATE CAJ_COMPROBANTE_GUIA
-- 		SET	
-- 			Flag_Relacion = @Flag_Relacion,
-- 			Cod_UsuarioAct = @Cod_Usuario, 
-- 			Fecha_Act = GETDATE()
-- 		WHERE (Id_GuiaRemision = @Id_GuiaRemision) AND (id_ComprobantePago = @id_ComprobantePago)	
-- 	END
-- END
-- go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_ALMACEN_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_I
go
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_I 
	@Cod_Caja	varchar(32), 
	@Cod_Almacen	varchar(32), 
	@Flag_Principal	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Caja, @Cod_Almacen FROM CAJ_CAJA_ALMACEN WHERE  (Cod_Caja = @Cod_Caja) AND (Cod_Almacen = @Cod_Almacen))
	BEGIN
		INSERT INTO CAJ_CAJA_ALMACEN  VALUES (
		@Cod_Caja,
		@Cod_Almacen,
		@Flag_Principal,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_CAJA_ALMACEN
		SET	
			Flag_Principal = @Flag_Principal,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Caja = @Cod_Caja) AND (Cod_Almacen = @Cod_Almacen)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_I
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_I 
	@Cod_Caja	varchar(32), 
	@Item	int, 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Impresora	varchar(512), 
	@Flag_Imprimir	bit, 
	@Flag_FacRapida	bit, 
	@Nom_Archivo	varchar(1024), 
	@Nro_SerieTicketera	varchar(64), 
	@Nom_ArchivoPublicar	varchar(512), 
	@Limite	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Caja, @Item FROM CAJ_CAJAS_DOC WHERE  (Cod_Caja = @Cod_Caja) AND (Item = @Item))
	BEGIN
		INSERT INTO CAJ_CAJAS_DOC  VALUES (
		@Cod_Caja,
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Caja = @Cod_Caja) AND (Item = @Item)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_INVENTARIO_I' AND type = 'P')
	DROP PROCEDURE USP_ALM_INVENTARIO_I
go
CREATE PROCEDURE USP_ALM_INVENTARIO_I 
	@Des_Inventario	varchar(512), 
	@Cod_TipoInventario	varchar(5), 
	@Obs_Inventario	varchar(1024), 
	@Cod_Almacen	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Inventario	int =(SELECT TOP 1 Id_Inventario FROM ALM_INVENTARIO WHERE Cod_TipoInventario=@Cod_TipoInventario and Cod_Almacen=@Cod_Almacen)
IF NOT EXISTS (SELECT * FROM ALM_INVENTARIO WHERE  (Id_Inventario = @Id_Inventario))
	BEGIN
		INSERT INTO ALM_INVENTARIO  VALUES (
		@Des_Inventario,
		@Cod_TipoInventario,
		@Obs_Inventario,
		@Cod_Almacen,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_Inventario = @@IDENTITY 
	END
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
		WHERE (Id_Inventario = @Id_Inventario)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_INVENTARIO_D_I' AND type = 'P')
	DROP PROCEDURE USP_ALM_INVENTARIO_D_I
go
CREATE PROCEDURE USP_ALM_INVENTARIO_D_I 
	@Cod_TipoInventario	varchar(5), 
	@Cod_Almacen	varchar(32),
	@Item	varchar(32), 
	@Cod_Producto	varchar(15), 
	@Cod_UnidadMedida	varchar(5), 
	@Cantidad_Sistema	numeric(38,6), 
	@Cantidad_Encontrada	numeric(38,6), 
	@Obs_InventarioD	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN

DECLARE @Id_Inventario	int =(SELECT TOP 1 Id_Inventario FROM ALM_INVENTARIO WHERE Cod_TipoInventario=@Cod_TipoInventario and Cod_Almacen=@Cod_Almacen)
DECLARE @Id_Producto int =  (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT * FROM ALM_INVENTARIO_D WHERE  (Id_Inventario = @Id_Inventario) AND (Item = @Item))
	BEGIN
		INSERT INTO ALM_INVENTARIO_D  VALUES (
		@Id_Inventario,
		@Item,
		@Id_Producto,
		@Cod_UnidadMedida,
		@Cod_Almacen,
		@Cantidad_Sistema,
		@Cantidad_Encontrada,
		@Obs_InventarioD,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_Inventario = @Id_Inventario) AND (Item = @Item)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_I
go
CREATE PROCEDURE USP_CAJ_CAJAS_I 
	@Cod_Caja	varchar(32), 
	@Des_Caja	varchar(512), 
	@Cod_Sucursal	varchar(32), 
	@Cod_UsuarioCajero	varchar(32), 
	@Cod_CuentaContable	varchar(16), 
	@Flag_Activo	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Caja FROM CAJ_CAJAS WHERE  (Cod_Caja = @Cod_Caja))
	BEGIN
		INSERT INTO CAJ_CAJAS  VALUES (
		@Cod_Caja,
		@Des_Caja,
		@Cod_Sucursal,
		@Cod_UsuarioCajero,
		@Cod_CuentaContable,
		@Flag_Activo,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Caja = @Cod_Caja)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_I' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_I
go
CREATE PROCEDURE USP_ALM_ALMACEN_I
	@Cod_Almacen	varchar(32), 
	@Des_Almacen	varchar(512), 
	@Des_CortaAlmacen	varchar(64), 
	@Cod_TipoAlmacen	varchar(5), 
	@Flag_Principal	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM ALM_ALMACEN WHERE  (Cod_Almacen = @Cod_Almacen))
	BEGIN
		INSERT INTO ALM_ALMACEN  VALUES (
		@Cod_Almacen,
		@Des_Almacen,
		@Des_CortaAlmacen,
		@Cod_TipoAlmacen,
		@Flag_Principal,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_Almacen = @Cod_Almacen)	
	END
END
go

-- Importar Productos
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_I
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_I 
	@Cod_Producto	varchar(64), 
	@Cod_Categoria	varchar(32), 
	@Cod_Marca	varchar(32), 
	@Cod_TipoProducto	varchar(5), 
	@Nom_Producto	varchar(512), 
	@Des_CortaProducto	varchar(512), 
	@Des_LargaProducto	varchar(1024), 
	@Caracteristicas	varchar(MAX), 
	@Porcentaje_Utilidad	numeric(5,2), 
	@Cuenta_Contable	varchar(16), 
	@Contra_Cuenta	varchar(16), 
	@Cod_Garantia	varchar(5), 
	@Cod_TipoExistencia	varchar(5), 
	@Cod_TipoOperatividad	varchar(5), 
	@Flag_Activo	bit, 
	@Flag_Stock	bit, 
	@Cod_Fabricante	varchar(64), 
	@Obs_Producto	xml,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTOS WHERE  (Cod_Producto = @Cod_Producto))
	BEGIN
		INSERT INTO PRI_PRODUCTOS  VALUES (
		@Cod_Producto,
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
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
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Producto = @Cod_Producto)	
	END
END
go

-- Importar producto stock
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_I 
	@Cod_Producto	varchar(64), 
	@Cod_UnidadMedida	varchar(5), 
	@Cod_Almacen	varchar(32), 
	@Cod_Moneda	varchar(5), 
	@Precio_Compra	numeric(38,6), 
	@Precio_Venta	numeric(38,6), 
	@Stock_Min	numeric(38,6), 
	@Stock_Max	numeric(38,6), 
	@Stock_Act	numeric(38,6), 
	@Cod_UnidadMedidaMin	varchar(5), 
	@Cantidad_Min	numeric(38,6),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto int =  (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_STOCK WHERE  (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen))
	BEGIN
		INSERT INTO PRI_PRODUCTO_STOCK  VALUES (
		@Id_Producto,
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)	
	END
END
go

-- Importar producto precio
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_I
	@Cod_Producto	varchar(64), 
	@Cod_UnidadMedida	varchar(5), 
	@Cod_Almacen	varchar(32), 
	@Cod_TipoPrecio	varchar(5), 
	@Valor	numeric(38,6),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto int = (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS where Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_PRECIO WHERE  (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen) AND (Cod_TipoPrecio = @Cod_TipoPrecio))
	BEGIN
		INSERT INTO PRI_PRODUCTO_PRECIO  VALUES (
		@Id_Producto,
		@Cod_UnidadMedida,
		@Cod_Almacen,
		@Cod_TipoPrecio,
		@Valor,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_PRODUCTO_PRECIO
		SET	
			Valor = @Valor,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen) AND (Cod_TipoPrecio = @Cod_TipoPrecio)	
	END
END
go

-- Importar producto detalle
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_DETALLE_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_I 
	@Cod_Producto	int, 
	@Item_Detalle	int, 
	@Cod_TipoDetalle	varchar(5), 
	@Cantidad	numeric(38,6), 
	@Cod_UnidadMedida	varchar(5),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto int =  (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
DECLARE @Id_ProductoDetalle	int=(SELECT Id_ProductoDetalle FROM PRI_PRODUCTO_DETALLE WHERE Id_Producto=@Id_Producto AND Item_Detalle=@Item_Detalle )
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_DETALLE WHERE  (Id_Producto = @Id_Producto) AND (Item_Detalle = @Item_Detalle))
	BEGIN
		INSERT INTO PRI_PRODUCTO_DETALLE  VALUES (
		@Id_Producto,
		@Item_Detalle,
		@Id_ProductoDetalle,
		@Cod_TipoDetalle,
		@Cantidad,
		@Cod_UnidadMedida,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
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
		WHERE (Id_Producto = @Id_Producto) AND (Item_Detalle = @Item_Detalle)	
	END
END
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_TASA_I' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_TASA_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_I 
	@Cod_Tasa varchar(32), 
	@Cod_Producto varchar(32), 
	@Cod_Libro	varchar(2), 
	@Des_Tasa	varchar(512), 
	@Por_Tasa	numeric(10,4), 
	@Cod_TipoTasa	varchar(8), 
	@Flag_Activo	bit, 
	@Obs_Tasa	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto INT;
SET @Id_Producto= (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE  Cod_Producto = @Cod_Producto);
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_TASA WHERE  (Id_Producto = @Id_Producto) AND (Cod_Tasa = @Cod_Tasa))
	BEGIN
		INSERT INTO PRI_PRODUCTO_TASA  VALUES (
		@Id_Producto,
		@Cod_Tasa,
		@Cod_Libro,
		@Des_Tasa,
		@Por_Tasa,
		@Cod_TipoTasa,
		@Flag_Activo,
		@Obs_Tasa,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_Producto = @Id_Producto) AND (Cod_Tasa = @Cod_Tasa)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_I' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_I
@Cod_TipoDocumento  varchar(3), 
@Nro_Documento  varchar(32), 
@Cliente  varchar(512), 
@Ap_Paterno  varchar(128), 
@Ap_Materno  varchar(128), 
@Nombres  varchar(128), 
@Direccion  varchar(512), 
@Cod_EstadoCliente  varchar(3), 
@Cod_CondicionCliente  varchar(3), 
@Cod_TipoCliente  varchar(3), 
@RUC_Natural  varchar(32), 
@Foto varbinary(MAX), 
@Firma varbinary(MAX), 
@Cod_TipoComprobante  varchar(5), 
@Cod_Nacionalidad  varchar(8), 
@Fecha_Nacimiento  VARCHAR(32), 
@Cod_Sexo  varchar(3), 
@Email1  varchar(1024), 
@Email2  varchar(1024), 
@Telefono1  varchar(512), 
@Telefono2  varchar(512), 
@Fax  varchar(512), 
@PaginaWeb  varchar(512), 
@Cod_Ubigeo  varchar(8), 
@Cod_FormaPago  varchar(3), 
@Limite_Credito  numeric(38,2), 
@Obs_Cliente xml,
@Num_DiaCredito	int,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));

IF NOT EXISTS (SELECT * FROM PRI_CLIENTE_PROVEEDOR WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_CLIENTE_PROVEEDOR  VALUES (
		@Cod_TipoDocumento,
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
		CONVERT(datetime,@Fecha_Nacimiento,121),
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_ClienteProveedor = @@IDENTITY 
	END
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
			Fecha_Nacimiento = CONVERT(datetime,@Fecha_Nacimiento,121),
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
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor)	
	END
END
go



-- Importar turno atencioon
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TURNO_ATENCION_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_TURNO_ATENCION_I
go
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_I 
	@Cod_Turno	varchar(32), 
	@Des_Turno	varchar(512), 
	@Fecha_Inicio	VARCHAR(32), 
	@Fecha_Fin	VARCHAR(32), 
	@Flag_Cerrado	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM CAJ_TURNO_ATENCION WHERE  (Cod_Turno = @Cod_Turno))
	BEGIN
		INSERT INTO CAJ_TURNO_ATENCION  VALUES (
		@Cod_Turno,
		@Des_Turno,
		CONVERT(datetime,@Fecha_Inicio,121),
		CONVERT(datetime,@Fecha_Fin,121),
		@Flag_Cerrado,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_TURNO_ATENCION
		SET	
			Des_Turno = @Des_Turno, 
			Fecha_Inicio = CONVERT(datetime,@Fecha_Inicio,121),
			Fecha_Fin = CONVERT(datetime,@Fecha_Fin,121),
			Flag_Cerrado = @Flag_Cerrado,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Turno = @Cod_Turno)	
	END
END
go

-- Importar caj_medicion_vc
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_VC_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_MEDICION_VC_I
go
CREATE PROCEDURE USP_CAJ_MEDICION_VC_I 
	@Cod_AMedir	varchar(32), 
	@Medio_AMedir	varchar(32), 
	@Medida_Anterior	numeric(38,4), 
	@Medida_Actual	numeric(38,4), 
	@Fecha_Medicion	VARCHAR(32), 
	@Cod_Turno	varchar(32), 
	@Cod_UsuarioMedicion	varchar(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM CAJ_MEDICION_VC WHERE  (Cod_AMedir = @Cod_AMedir) AND (Medio_AMedir=@Medio_AMedir) and Cod_Turno = @Cod_Turno)
	BEGIN
		INSERT INTO CAJ_MEDICION_VC  VALUES (
		@Cod_AMedir,
		@Medio_AMedir,
		@Medida_Anterior,
		@Medida_Actual,
		CONVERT (DATETIME, @Fecha_Medicion,121),
		@Cod_Turno,
		@Cod_UsuarioMedicion,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_MEDICION_VC
		SET	
			Cod_AMedir = @Cod_AMedir, 
			Medio_AMedir = @Medio_AMedir, 
			Medida_Anterior = @Medida_Anterior, 
			Medida_Actual = @Medida_Actual, 
			Fecha_Medicion = CONVERT (DATETIME,@Fecha_Medicion,121),
			Cod_Turno = @Cod_Turno, 
			Cod_UsuarioMedicion = @Cod_UsuarioMedicion,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_AMedir = @Cod_AMedir) AND (Medio_AMedir=@Medio_AMedir) AND Cod_Turno = @Cod_Turno
	END
END
go


-- Importar arqueo fisico
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_I
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_I  
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Numero	int, 
	@Des_ArqueoFisico	varchar(512), 
	@Obs_ArqueoFisico	varchar(1024), 
	@Fecha	VARCHAR(32), 
	@Flag_Cerrado	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ArqueoFisico int = (SELECT id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
IF NOT EXISTS (SELECT * FROM CAJ_ARQUEOFISICO WHERE  (id_ArqueoFisico = @id_ArqueoFisico))
	BEGIN
		INSERT INTO CAJ_ARQUEOFISICO  VALUES (
		@Cod_Caja,
		@Cod_Turno,
		@Numero,
		@Des_ArqueoFisico,
		@Obs_ArqueoFisico,
		CONVERT(datetime,@Fecha,121),
		@Flag_Cerrado,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_ARQUEOFISICO
		SET	
			Cod_Caja = @Cod_Caja, 
			Cod_Turno = @Cod_Turno, 
			Numero = @Numero, 
			Des_ArqueoFisico = @Des_ArqueoFisico, 
			Obs_ArqueoFisico = @Obs_ArqueoFisico, 
			Fecha = CONVERT(datetime,@Fecha,121),
			Flag_Cerrado = @Flag_Cerrado,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ArqueoFisico = @id_ArqueoFisico)	
	END
END
go


-- importar Arqueo fisico Detalle
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_D_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D_I
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D_I 
    @Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Billete varchar(3), 
	@Cantidad	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ArqueoFisico int = (SELECT id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
IF NOT EXISTS (SELECT * FROM CAJ_ARQUEOFISICO_D WHERE  (id_ArqueoFisico = @id_ArqueoFisico) AND (Cod_Billete = @Cod_Billete))
	BEGIN
		INSERT INTO CAJ_ARQUEOFISICO_D  VALUES (
		@id_ArqueoFisico,
		@Cod_Billete,
		@Cantidad,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_ARQUEOFISICO_D
		SET	
			Cantidad = @Cantidad,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ArqueoFisico = @id_ArqueoFisico) AND (Cod_Billete = @Cod_Billete)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_SALDO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_I
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_I 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Moneda	varchar(3), 
	@Tipo	varchar(32), 
	@Monto	numeric(38,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ArqueoFisico int = (SELECT TOP 1 id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
IF NOT EXISTS (SELECT * FROM CAJ_ARQUEOFISICO_SALDO WHERE  (id_ArqueoFisico = @id_ArqueoFisico) AND (Cod_Moneda = @Cod_Moneda) AND (Tipo = @Tipo))
	BEGIN
		INSERT INTO CAJ_ARQUEOFISICO_SALDO  VALUES (
		@id_ArqueoFisico,
		@Cod_Moneda,
		@Tipo,
		@Monto,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_ARQUEOFISICO_SALDO
		SET	
			Monto = @Monto,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ArqueoFisico = @id_ArqueoFisico) AND (Cod_Moneda = @Cod_Moneda) AND (Tipo = @Tipo)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_I 
	@Cod_TipoDocumento int,
	@Nro_Documento varchar(32), 
	@Cod_Licitacion	varchar(32), 
	@Des_Licitacion	varchar(512), 
	@Cod_TipoLicitacion	varchar(5), 
	@Nro_Licitacion	varchar(16), 
    @Fecha_Inicio	VARCHAR(32), 
	@Fecha_Facturacion	varchar(32), 
	@Flag_AlFinal	bit, 
	@Cod_TipoComprobante	varchar(5),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
IF NOT EXISTS (SELECT * FROM PRI_LICITACIONES WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion))
	BEGIN
		INSERT INTO PRI_LICITACIONES  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Des_Licitacion,
		@Cod_TipoLicitacion,
		@Nro_Licitacion,
		CONVERT(datetime,@Fecha_Inicio,121),
		CONVERT(datetime,@Fecha_Facturacion,121),
		@Flag_AlFinal,
		@Cod_TipoComprobante,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE PRI_LICITACIONES
		SET	
			Des_Licitacion = @Des_Licitacion, 
			Cod_TipoLicitacion = @Cod_TipoLicitacion, 
			Nro_Licitacion = @Nro_Licitacion, 
			Fecha_Inicio = CONVERT(datetime,@Fecha_Inicio,121),
			Fecha_Facturacion = CONVERT(datetime,@Fecha_Facturacion,121),
			Flag_AlFinal = @Flag_AlFinal, 
			Cod_TipoComprobante = @Cod_TipoComprobante,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_D_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_D_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_D_I 
	@Cod_TipoDocumento int,
	@Nro_Documento varchar(32), 
	@Cod_Licitacion	varchar(32), 
	@Nro_Detalle	int, 
	@Cod_Producto	varchar(32), 
	@Cantidad	numeric(38,2), 
	@Cod_UnidadMedida	varchar(5), 
	@Descripcion	varchar(512), 
	@Precio_Unitario	numeric(38,6), 
	@Por_Descuento	numeric(5,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
DECLARE @Id_Producto	int = (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT @Id_ClienteProveedor, @Cod_Licitacion, @Nro_Detalle FROM PRI_LICITACIONES_D WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle))
	BEGIN
		INSERT INTO PRI_LICITACIONES_D  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Nro_Detalle,
		@Id_Producto,
		@Cantidad,
		@Cod_UnidadMedida,
		@Descripcion,
		@Precio_Unitario,
		@Por_Descuento,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CONCEPTO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CONCEPTO_I
go
CREATE PROCEDURE USP_CAJ_CONCEPTO_I 
	@Id_Concepto	int, 
	@Des_Concepto	varchar(512), 
	@Cod_ClaseConcepto	varchar(3), 
	@Flag_Activo	bit, 
	@Id_ConceptoPadre	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Id_Concepto FROM CAJ_CONCEPTO WHERE  (Id_Concepto = @Id_Concepto))
	BEGIN
		INSERT INTO CAJ_CONCEPTO  VALUES (
		@Id_Concepto,
		@Des_Concepto,
		@Cod_ClaseConcepto,
		@Flag_Activo,
		@Id_ConceptoPadre,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_Concepto = @Id_Concepto)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Id_Concepto	int, 
	@Cod_TipoDocumento	varchar (10), 
	@DocCliente	varchar(512), 
	@Des_Movimiento	varchar(512), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(4), 
	@Numero	varchar(20), 
	@Fecha	varchar(32), 
	@Tipo_Cambio	numeric(10,4), 
	@Ingreso	numeric(38,2), 
	@Cod_MonedaIng	varchar(3), 
	@Egreso	numeric(38,2), 
	@Cod_MonedaEgr	varchar(3), 
	@Flag_Extornado	bit, 
	@Cod_UsuarioAut	varchar(32), 
	@Fecha_Aut	varchar(32), 
	@Obs_Movimiento	xml, 
	@Id_MovimientoRef	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor int= (select TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento AND Nro_Documento=@DocCliente)
DECLARE @Nom_Cliente varchar(MAX)= (select Nombres FROM PRI_CLIENTE_PROVEEDOR where Id_ClienteProveedor=@Id_ClienteProveedor)
DECLARE @id_Movimiento	int =(SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS where Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie and Numero=@Numero
and Cod_Caja=@Cod_Caja and Cod_Turno =@Cod_Turno) 
IF NOT EXISTS (SELECT * FROM CAJ_CAJA_MOVIMIENTOS WHERE  (id_Movimiento = @id_Movimiento))
	BEGIN
		INSERT INTO CAJ_CAJA_MOVIMIENTOS  VALUES (
		@Cod_Caja,
		@Cod_Turno,
		@Id_Concepto,
		@Id_ClienteProveedor,
		@Nom_Cliente,
		@Des_Movimiento,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		CONVERT(datetime,@Fecha,121),
		@Tipo_Cambio,
		@Ingreso,
		@Cod_MonedaIng,
		@Egreso,
		@Cod_MonedaEgr,
		@Flag_Extornado,
		@Cod_UsuarioAut,
		CONVERT(datetime,@Fecha_Aut,121),
		@Obs_Movimiento,
		@Id_MovimientoRef,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
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
			Fecha = CONVERT(datetime,@Fecha,121), 
			Tipo_Cambio = @Tipo_Cambio, 
			Ingreso = @Ingreso, 
			Cod_MonedaIng = @Cod_MonedaIng, 
			Egreso = @Egreso, 
			Cod_MonedaEgr = @Cod_MonedaEgr, 
			Flag_Extornado = @Flag_Extornado, 
			Cod_UsuarioAut = @Cod_UsuarioAut, 
			Fecha_Aut = CONVERT(datetime,@Fecha_Aut,121),
			Obs_Movimiento = @Obs_Movimiento, 
			Id_MovimientoRef = @Id_MovimientoRef,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_Movimiento = @id_Movimiento)	
	END
END
go



-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I 
	@Cod_Libro	varchar(2), 
	@Cod_Periodo	varchar(8), 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_TipoOperacion	varchar(5), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30), 
	@Cod_TipoDoc	varchar(2), 
	@Doc_Cliente	varchar(20), 
	@Nom_Cliente	varchar(512), 
	@Direccion_Cliente	varchar(512), 
	@FechaEmision	VARCHAR(32), 
	@FechaVencimiento	VARCHAR(32), 
	@FechaCancelacion	VARCHAR(32), 
	@Glosa	varchar(512), 
	@TipoCambio	numeric(10,4), 
	@Flag_Anulado	bit, 
	@Flag_Despachado	bit, 
	@Cod_FormaPago	varchar(5), 
	@Descuento_Total	numeric(38,2), 
	@Cod_Moneda	varchar(3), 
	@Impuesto	numeric(38,6), 
	@Total	numeric(38,2), 
	@Obs_Comprobante	xml, 
	@Id_GuiaRemision	int, 
	@GuiaRemision	varchar(50), 
	@Cod_LibroRef varchar(2),
	@Cod_TipoComprobanteRef varchar(5),
	@SerieRef varchar(5),
	@NumeroRef varchar(30),
	@Cod_Plantilla	varchar(32), 
	@Nro_Ticketera	varchar(64), 
	@Cod_UsuarioVendedor	varchar(32), 
	@Cod_RegimenPercepcion	varchar(8), 
	@Tasa_Percepcion	numeric(38,2), 
	@Placa_Vehiculo	varchar(64), 
	@Cod_TipoDocReferencia	varchar(8), 
	@Nro_DocReferencia	varchar(64), 
	@Valor_Resumen	varchar(1024), 
	@Valor_Firma	varchar(2048), 
	@Cod_EstadoComprobante	varchar(8), 
	@MotivoAnulacion	varchar(512), 
	@Otros_Cargos	numeric(38,2), 
	@Otros_Tributos	numeric(38,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Cliente int =(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc and Nro_Documento=@Doc_Cliente)
DECLARE @id_ComprobantePago	int =(SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_Libro AND Cod_TipoComprobante=@Cod_TipoComprobante AND Serie=@Serie
AND Numero=@Numero)

DECLARE @id_ComprobanteRef int = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_LibroRef AND Cod_TipoComprobante=@Cod_TipoComprobanteRef AND Serie=@SerieRef
AND Numero=@NumeroRef)

IF NOT EXISTS (SELECT * FROM CAJ_COMPROBANTE_PAGO WHERE  (id_ComprobantePago = @id_ComprobantePago))
	BEGIN
		INSERT INTO CAJ_COMPROBANTE_PAGO  VALUES (
		@Cod_Libro,
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
		CONVERT(datetime,@FechaEmision,121),
		CONVERT(datetime,@FechaVencimiento,121),
		CONVERT(datetime,@FechaCancelacion,121),
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @id_ComprobantePago = @@IDENTITY 
	END
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
			FechaEmision = CONVERT(datetime,@FechaEmision,121),
			FechaVencimiento = CONVERT(datetime,@FechaVencimiento,121), 
			FechaCancelacion = CONVERT(datetime,@FechaCancelacion,121),
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
		WHERE (id_ComprobantePago = @id_ComprobantePago)	
	END
END
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_D_I' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_D_I
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_I 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@id_Detalle  int, 
	@Cod_Producto varchar(32), 
	@Cod_AlmaceN varchar(32), 
	@Cantidad numeric(38,6), 
	@Cod_UnidadMedida varchar(5), 
	@Despachado numeric(38,6), 
	@DescripcioN varchar(MAX), 
	@PrecioUnitario numeric(38,6), 
	@Descuento numeric(38,2), 
	@Sub_Total numeric(38,2), 
	@Tipo varchar(256), 
	@Obs_ComprobanteD varchar(1024), 
	@Cod_Manguera varchar(32), 
	@Flag_AplicaImpuesto  bit, 
	@Formalizado numeric(38,6),
	@Valor_NoOneroso	numeric(38,2), 
	@Cod_TipoISC	varchar(8), 
	@Porcentaje_ISC	numeric(38,2), 
	@ISC	numeric(38,2), 
	@Cod_TipoIGV	varchar(8), 
	@Porcentaje_IGV	numeric(38,2), 
	@IGV	numeric(38,2),
	@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @id_ComprobantePago INT=0,@Id_Producto int;
	SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_Libro
	AND Cod_TipoComprobante = @Cod_TipoComprobante
	AND Serie = @Serie
	AND Numero= @Numero);

	set @Id_Producto = (select top 1 Id_Producto from pri_productos where Cod_Producto = @Cod_Producto);

IF NOT EXISTS (SELECT @id_ComprobantePago, @id_Detalle FROM CAJ_COMPROBANTE_D WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle))
	BEGIN
		INSERT INTO CAJ_COMPROBANTE_D  VALUES (
		@id_ComprobantePago,
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle)	
	END
END
go

-- Guadar
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_PAGO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_PAGO_I
go
CREATE PROCEDURE USP_CAJ_SERIES_PAGO_I 
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@id_Detalle	int, 
	@Nro_Serie	varchar(512), 
	@FechaVencimiento VARCHAR(32),
	@Obs_Series	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN

DECLARE @id_ComprobantePago	int = (SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie AND Numero=@Numero
AND Cod_TipoDoc=@Cod_TipoDoc and Doc_Cliente=@Doc_Cliente)
IF NOT EXISTS (SELECT * FROM CAJ_SERIES WHERE  (Id_Tabla = @id_ComprobantePago) AND (Item = @id_Detalle))
	BEGIN
		INSERT INTO CAJ_SERIES  VALUES (
		'CAJ_COMPROBANTE_PAGO',
		@id_ComprobantePago,
		@id_Detalle,
		@Nro_Serie,
		CONVERT(datetime,@FechaVencimiento,121),
		@Obs_Series,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_SERIES
		SET	
			Serie=@Serie,
			Fecha_Vencimiento = CONVERT(datetime,@FechaVencimiento,121),
			Obs_Serie = @Obs_Series,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Tabla = @id_ComprobantePago) AND (Item = @id_Detalle) 
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_MOVIMIENTO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_MOVIMIENTO_I
go
CREATE PROCEDURE USP_CAJ_SERIES_MOVIMIENTO_I 
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@id_Detalle	int, 
	@Nro_Serie	varchar(512), 
	@FechaVencimiento VARCHAR(32),
	@Obs_Series	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN

DECLARE @id_ComprobantePago	int = (SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS WHERE  Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie AND Numero=@Numero)
IF NOT EXISTS (SELECT * FROM CAJ_SERIES WHERE  (Id_Tabla = @id_ComprobantePago) AND (Item = @id_Detalle))
	BEGIN
		INSERT INTO CAJ_SERIES  VALUES (
		'ALM_ALMACEN_MOV',
		@id_ComprobantePago,
		@id_Detalle,
		@Nro_Serie,
		CONVERT(datetime,@FechaVencimiento,121),
		@Obs_Series,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_SERIES
		SET	
			Serie=@Serie,
			Fecha_Vencimiento = CONVERT(datetime,@FechaVencimiento,121),
			Obs_Serie = @Obs_Series,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Tabla = @id_ComprobantePago) AND (Item = @id_Detalle) 
	END
END
go



-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_I
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_I 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@id_Detalle	int, 
	@Item	int, 
	@Cod_LibroR varchar(4),
	@Cod_TipoComprobanteR varchar(4),
	@SerieR varchar(5),
	@NumeroR  varchar(32),
	@Cod_TipoDocR   varchar(4),
	@Doc_ClienteR   varchar(32),
	@Cod_TipoRelacion	varchar(8), 
	@Valor	numeric(38,6), 
	@Obs_Relacion	varchar(1024),
	@Id_DetalleRelacion	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago INT=0;
	SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_Libro
	AND Cod_TipoComprobante = @Cod_TipoComprobante
	AND Serie = @Serie
	AND Numero= @Numero)

DECLARE @id_ComprobanteRelacion INT=0;
	SET @id_ComprobanteRelacion = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_LibroR
	AND Cod_TipoComprobante = @Cod_TipoComprobanteR
	AND Serie = @SerieR
	AND Numero= @NumeroR)

IF NOT EXISTS (SELECT @id_ComprobantePago, @id_Detalle, @Item FROM CAJ_COMPROBANTE_RELACION WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle) AND (Item = @Item))
	BEGIN
		INSERT INTO CAJ_COMPROBANTE_RELACION  VALUES (
		@id_ComprobantePago,
		@id_Detalle,
		@Item,
		@Id_ComprobanteRelacion,
		@Cod_TipoRelacion,
		@Valor,
		@Obs_Relacion,
		@Id_DetalleRelacion,
		@Cod_Usuario,GETDATE(),NULL,NULL)

		UPDATE CAJ_COMPROBANTE_PAGO set id_ComprobanteRef=@id_ComprobanteRelacion
		WHERE id_ComprobantePago=@id_ComprobantePago

	END
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
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle) AND (Item = @Item)	

		UPDATE CAJ_COMPROBANTE_PAGO set id_ComprobanteRef=@id_ComprobanteRelacion
		WHERE id_ComprobantePago=@id_ComprobantePago

	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_M_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_M_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_M_I 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Licitacion	varchar(32), 
	@Nro_Detalle	int, 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDocC  varchar(4),
	@Doc_ClienteC   varchar(32),
	@Flag_Cancelado	bit, 
	@Obs_LicitacionesM	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago INT=0;
	SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_Libro
	AND Cod_TipoComprobante = @Cod_TipoComprobante
	AND Serie = @Serie
	AND Numero= @Numero
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente)
DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocC AND @Doc_ClienteC=Nro_Documento )
DECLARE @Id_Movimiento	int =(SELECT Id_Movimiento FROM PRI_LICITACIONES_M where Cod_Licitacion=@Cod_Licitacion and Nro_Detalle=@Nro_Detalle AND id_ComprobantePago=@id_ComprobantePago)
IF NOT EXISTS (SELECT @Id_Movimiento FROM PRI_LICITACIONES_M WHERE  (Id_Movimiento = @Id_Movimiento))
	BEGIN
		INSERT INTO PRI_LICITACIONES_M  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Nro_Detalle,
		@id_ComprobantePago,
		@Flag_Cancelado,
		@Obs_LicitacionesM,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_Movimiento = @@IDENTITY 
	END
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
		WHERE (Id_Movimiento = @Id_Movimiento)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_VEHICULOS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_VEHICULOS_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_VEHICULOS_I 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Placa	varchar(32), 
	@Color	varchar(128), 
	@Marca	varchar(128), 
	@Modelo	varchar(128), 
	@Propiestarios	varchar(512), 
	@Sede	varchar(128), 
	@Placa_Vigente	varchar(64),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
IF NOT EXISTS (SELECT * FROM PRI_CLIENTE_VEHICULOS WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Placa = @Cod_Placa))
	BEGIN
		INSERT INTO PRI_CLIENTE_VEHICULOS  VALUES (
		@Id_ClienteProveedor,
		@Cod_Placa,
		@Color,
		@Marca,
		@Modelo,
		@Propiestarios,
		@Sede,
		@Placa_Vigente,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Placa = @Cod_Placa)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_I' AND type = 'P')
	DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_I
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_I 
	@Cod_CuentaBancaria	varchar(32), 
	@Cod_Sucursal	varchar(32), 
	@Cod_EntidadFinanciera	varchar(8), 
	@Des_CuentaBancaria	varchar(512), 
	@Cod_Moneda	varchar(5), 
	@Flag_Activo	bit, 
	@Saldo_Disponible	numeric(38,2), 
	@Cod_CuentaContable	varchar(16), 
	@Cod_TipoCuentaBancaria	varchar(8),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_CuentaBancaria FROM BAN_CUENTA_BANCARIA WHERE  (Cod_CuentaBancaria = @Cod_CuentaBancaria))
	BEGIN
		INSERT INTO BAN_CUENTA_BANCARIA  VALUES (
		@Cod_CuentaBancaria,
		@Cod_Sucursal,
		@Cod_EntidadFinanciera,
		@Des_CuentaBancaria,
		@Cod_Moneda,
		@Flag_Activo,
		@Saldo_Disponible,
		@Cod_CuentaContable,
		@Cod_TipoCuentaBancaria,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Cod_CuentaBancaria = @Cod_CuentaBancaria)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_M_i' AND type = 'P')
	DROP PROCEDURE USP_BAN_CUENTA_M_I
go
CREATE PROCEDURE USP_BAN_CUENTA_M_I 
	@Cod_CuentaBancaria	varchar(32), 
	@Nro_Operacion	varchar(32), 
	@Des_Movimiento	varchar(512), 
	@Cod_TipoOperacionBancaria	varchar(8), 
	@Fecha	VARCHAR(32), 
	@Monto	numeric(38,2), 
	@TipoCambio	numeric(10,4), 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Plantilla	varchar(32), 
	@Nro_Cheque	varchar(32), 
	@Beneficiario	varchar(512), 
	@Id_ComprobantePago	int, 
	@Obs_Movimiento	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_MovimientoCuenta	int = (SELECT Id_MovimientoCuenta FROM BAN_CUENTA_M WHERE Cod_CuentaBancaria=@Cod_CuentaBancaria)
IF NOT EXISTS (SELECT * FROM BAN_CUENTA_M WHERE  (Id_MovimientoCuenta = @Id_MovimientoCuenta))
	BEGIN
		INSERT INTO BAN_CUENTA_M  VALUES (
		@Cod_CuentaBancaria,
		@Nro_Operacion,
		@Des_Movimiento,
		@Cod_TipoOperacionBancaria,
		CONVERT(datetime,@Fecha,121),
		@Monto,
		@TipoCambio,
		@Cod_Caja,
		@Cod_Turno,
		@Cod_Plantilla,
		@Nro_Cheque,
		@Beneficiario,
		@Id_ComprobantePago,
		@Obs_Movimiento,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE BAN_CUENTA_M
		SET	
			Cod_CuentaBancaria = @Cod_CuentaBancaria, 
			Nro_Operacion = @Nro_Operacion, 
			Des_Movimiento = @Des_Movimiento, 
			Cod_TipoOperacionBancaria = @Cod_TipoOperacionBancaria, 
			Fecha = CONVERT(datetime,@Fecha,121), 
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
		WHERE (Id_MovimientoCuenta = @Id_MovimientoCuenta)	
	END
END
go



-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_I' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_MOV_I
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_I 
	@Cod_Almacen	varchar(32), 
	@Cod_TipoOperacion	varchar(5), 
	@Cod_Turno	varchar(32), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(32), 
	@Fecha	VARCHAR(32),
	@Motivo	varchar(512), 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobanteM varchar(4),
	@SerieM varchar(5),
	@NumeroM  varchar(32),
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Flag_Anulado	bit, 
	@Obs_AlmacenMov	xml,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago INT=0;
	SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_Libro
	AND Cod_TipoComprobante = @Cod_TipoComprobanteM
	AND Serie = @SerieM
	AND Numero= @NumeroM
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente)
DECLARE @Id_AlmacenMov	int =(SELECT Id_AlmacenMov FROM ALM_ALMACEN_MOV WHERE 
Cod_TipoComprobante=@Cod_TipoComprobante AND Serie=@Serie AND Numero=@Numero)
IF NOT EXISTS (SELECT * FROM ALM_ALMACEN_MOV WHERE  (Id_AlmacenMov = @Id_AlmacenMov))
	BEGIN
		INSERT INTO ALM_ALMACEN_MOV  VALUES (
		@Cod_Almacen,
		@Cod_TipoOperacion,
		@Cod_Turno,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		CONVERT(datetime,@Fecha,121),
		@Motivo,
		@Id_ComprobantePago,
		@Flag_Anulado,
		@Obs_AlmacenMov,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
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
			Fecha = CONVERT(datetime,@Fecha,121), 
			Motivo = @Motivo, 
			Id_ComprobantePago = @Id_ComprobantePago, 
			Flag_Anulado = @Flag_Anulado, 
			Obs_AlmacenMov = @Obs_AlmacenMov,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_AlmacenMov = @Id_AlmacenMov)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_D_I' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_MOV_D_I
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D_I  
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(32), 
	@Item	int, 
	@Cod_Producto varchar(5), 
	@Des_Producto	varchar(128), 
	@Precio_Unitario	numeric(38,6), 
	@Cantidad	numeric(38,6), 
	@Cod_UnidadMedida	varchar(5), 
	@Obs_AlmacenMovD	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_AlmacenMov	int = (SELECT Id_AlmacenMov FROM ALM_ALMACEN_MOV WHERE Cod_TipoComprobante=@Cod_TipoComprobante AND Serie=@Serie AND Numero=@Numero)
DECLARE @Id_Producto	int = (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)

IF NOT EXISTS (SELECT * FROM ALM_ALMACEN_MOV_D WHERE  (Id_AlmacenMov = @Id_AlmacenMov) AND (Item = @Item))
	BEGIN
		INSERT INTO ALM_ALMACEN_MOV_D  VALUES (
		@Id_AlmacenMov,
		@Item,
		@Id_Producto,
		@Des_Producto,
		@Precio_Unitario,
		@Cantidad,
		@Cod_UnidadMedida,
		@Obs_AlmacenMovD,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
		WHERE (Id_AlmacenMov = @Id_AlmacenMov) AND (Item = @Item)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PRODUCTO_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PRODUCTO_I
go
CREATE PROCEDURE USP_PRI_CLIENTE_PRODUCTO_I 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Producto  varchar(5),
	@Cod_TipoDescuento	varchar(8), 
	@Monto	numeric(38,6), 
	@Obs_ClienteProducto	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
DECLARE @Id_Producto	int = (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT @Id_ClienteProveedor, @Id_Producto FROM PRI_CLIENTE_PRODUCTO WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Id_Producto = @Id_Producto))
	BEGIN
		INSERT INTO PRI_CLIENTE_PRODUCTO  VALUES (
		@Id_ClienteProveedor,
		@Id_Producto,
		@Cod_TipoDescuento,
		@Monto,
		@Obs_ClienteProducto,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_CLIENTE_PRODUCTO
		SET	
			Cod_TipoDescuento = @Cod_TipoDescuento, 
			Monto = @Monto, 
			Obs_ClienteProducto = @Obs_ClienteProducto,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Id_Producto = @Id_Producto)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_FORMA_PAGO_I
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_I 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Item	int, 
	@Des_FormaPago	varchar(512), 
	@Cod_TipoFormaPago	varchar(3), 
	@Cuenta_CajaBanco	varchar(64), 
	@Id_Movimiento	int, 
	@TipoCambio	numeric(10,4), 
	@Cod_Moneda	varchar(3), 
	@Monto	numeric(38,2), 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Plantilla	varchar(32), 
	@Obs_FormaPago	xml, 
	@Fecha	VARCHAR(32),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago int = (SELECT  id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_Libro AND Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie AND Numero=@Numero)

IF NOT EXISTS (SELECT @id_ComprobantePago, @Item FROM CAJ_FORMA_PAGO WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (Item = @Item))
	BEGIN
		INSERT INTO CAJ_FORMA_PAGO  VALUES (
		@id_ComprobantePago,
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
		CONVERT(datetime,@Fecha,121),
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
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
			Fecha = CONVERT(datetime,@Fecha,121),
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Item = @Item)	
	END
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_COLUMNA_I' AND type = 'P')
DROP PROCEDURE USP_PAR_COLUMNA_I
go
CREATE PROCEDURE USP_PAR_COLUMNA_I
@Cod_Tabla varchar(3),
@Cod_Columna varchar(3),
@Columna varchar(512),
@Des_Columna varchar(1024),
@Tipo varchar(64),
@Flag_NULL bit,
@Tamano int,
@Predeterminado varchar(max),
@Flag_PK bit,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN

IF NOT EXISTS (SELECT * FROM PAR_COLUMNA  WHERE  (Cod_Tabla = @Cod_Tabla) AND (Cod_Columna=@Cod_Columna))
	BEGIN
	   INSERT dbo.PAR_COLUMNA
	   VALUES
	   (
	       @Cod_Tabla, -- Cod_Tabla - varchar
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
	   )
	END
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
	   WHERE dbo.PAR_COLUMNA.Cod_Tabla=@Cod_Tabla AND dbo.PAR_COLUMNA.Cod_Columna=@Cod_Columna
	END
END
GO

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_FILA_I' AND type = 'P')
DROP PROCEDURE USP_PAR_FILA_I
go
CREATE PROCEDURE USP_PAR_FILA_I
    @Cod_Tabla varchar(3),
    @Cod_Columna varchar(3),
    @Cod_Fila int,
    @Cadena nvarchar(max),
    @Numero numeric(38,8),
    @Entero float,
    @FechaHora VARCHAR(32),
    @Boleano bit,
    @Flag_Creacion bit,
    @Cod_Usuario varchar(32)
WITH ENCRYPTION
AS
BEGIN

IF NOT EXISTS (SELECT * FROM dbo.PAR_FILA pf  WHERE  pf.Cod_Tabla=@Cod_Tabla AND pf.Cod_Columna=@Cod_Columna AND pf.Cod_Fila=@Cod_Fila)
	BEGIN
	   INSERT dbo.PAR_FILA
	   VALUES
	   (
	       @Cod_Tabla, -- Cod_Tabla - varchar
	       @Cod_Columna, -- Cod_Columna - varchar
	       @Cod_Fila, -- Cod_Fila - int
	       @Cadena, -- Cadena - nvarchar
	       @Numero, -- Numero - numeric
	       @Entero, -- Entero - float
	       CONVERT(datetime,@FechaHora,121), -- FechaHora - datetime
	       @Boleano, -- Boleano - bit
	       @Flag_Creacion, -- Flag_Creacion - bit
	       @Cod_Usuario, -- Cod_UsuarioReg - varchar
	       GETDATE(), -- Fecha_Reg - datetime
	       NULL, -- Cod_UsuarioAct - varchar
	       NULL -- Fecha_Act - datetime
	   )
	END
	ELSE
	BEGIN
	   UPDATE dbo.PAR_FILA
	   SET
	       dbo.PAR_FILA.Cadena = @Cadena, -- nvarchar
	       dbo.PAR_FILA.Numero = @Numero, -- numeric
	       dbo.PAR_FILA.Entero = @Entero, -- float
	       dbo.PAR_FILA.FechaHora = CONVERT(datetime,@FechaHora,121), -- datetime
	       dbo.PAR_FILA.Boleano = @Boleano, -- bit
	       dbo.PAR_FILA.Flag_Creacion = @Flag_Creacion, -- bit
	       dbo.PAR_FILA.Cod_UsuarioReg = @Cod_Usuario, -- varchar
	       dbo.PAR_FILA.Fecha_Act = GETDATE() -- datetime
	   WHERE dbo.PAR_FILA.Cod_Tabla=@Cod_Tabla AND dbo.PAR_FILA.Cod_Columna=@Cod_Columna AND dbo.PAR_FILA.Cod_Fila=@Cod_Fila
    END
END
GO



--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_GUIA_REMISION_I' AND type = 'P')
--	DROP PROCEDURE USP_CAJ_GUIA_REMISION_I
--go
--CREATE PROCEDURE USP_CAJ_GUIA_REMISION_I 
--	@Cod_Caja varchar(32),
--	@Cod_Turno varchar(32),
--	@Cod_TipoComprobante varchar(5),
--	@Serie varchar(5),
--	@Numero varchar(32),
--	@Punto_Partida varchar(512),
--	@Origen varchar(512),
--	@Nro_Partida varchar(64),
--	@Fecha_Traslado datetime,
--	@Certificado_Inscripcion varchar(512),
--	@Certificado_Habilitacion varchar(512),
--	@Num_Placa varchar(32),
--	@Licencia_Conductor varchar(32),
--	@Punto_Llegada varchar(512),
--	@Destino varchar(512),
--	@Nro_Llegada varchar(64),
--	@Id_ClienteProveedor int,
--	@Id_Transportista int,
--	@Cod_MotivoTraslado varchar(5),
--	@Motivo_Traslado varchar(512),
--	@Obs_GuiaRemision varchar(1024),
--	@Flag_Anulado bit,
--	@Cod_EstadoGuia varchar(3),
--	@Cod_Usuario varchar(32)
--WITH ENCRYPTION
--AS
--BEGIN
--DECLARE @Id_GuiaRemision	int =(SELECT ISNULL(Id_GuiaRemision,0) FROM dbo.CAJ_GUIA_REMISION  WHERE Cod_Caja=@Cod_Caja AND @Cod_Turno=Cod_Turno AND @Cod_TipoComprobante=Cod_TipoComprobante
--AND Serie=@Serie AND @Numero=Numero)

--IF NOT EXISTS (SELECT * FROM dbo.CAJ_GUIA_REMISION cgr WHERE  (cgr.Id_GuiaRemision = @Id_GuiaRemision))
--	BEGIN
--	    INSERT dbo.CAJ_GUIA_REMISION
--	    VALUES
--	    (
--	        @Cod_Caja, -- Cod_Caja - varchar
--	        @Cod_Turno, -- Cod_Turno - varchar
--	        @Cod_TipoComprobante, -- Cod_TipoComprobante - varchar
--	        @Serie, -- Serie - varchar
--	        @Numero, -- Numero - varchar
--	        @Punto_Partida, -- Punto_Partida - varchar
--	        @Origen, -- Origen - varchar
--	        @Nro_Partida, -- Nro_Partida - varchar
--	        @Fecha_Traslado, -- Fecha_Traslado - datetime
--	        @Certificado_Inscripcion, -- Certificado_Inscripcion - varchar
--	        @Certificado_Habilitacion, -- Certificado_Habilitacion - varchar
--	        @Num_Placa, -- Num_Placa - varchar
--	        @Licencia_Conductor, -- Licencia_Conductor - varchar
--	        @Punto_Llegada, -- Punto_Llegada - varchar
--	        @Destino, -- Destino - varchar
--	        @Nro_Llegada, -- Nro_Llegada - varchar
--	        @Id_ClienteProveedor, -- Id_ClienteProveedor - int
--	        @Id_Transportista, -- Id_Transportista - int
--	        @Cod_MotivoTraslado, -- Cod_MotivoTraslado - varchar
--	        @Motivo_Traslado, -- Motivo_Traslado - varchar
--	        @Obs_GuiaRemision, -- Obs_GuiaRemision - varchar
--	        @Flag_Anulado, -- Flag_Anulado - bit
--	        @Cod_EstadoGuia, -- Cod_EstadoGuia - varchar
--	        @Cod_Usuario, -- Cod_UsuarioReg - varchar
--	        GETDATE(), -- Fecha_Reg - datetime
--	        NULL, -- Cod_UsuarioAct - varchar
--	        NULL -- Fecha_Act - datetime
--	    )SET @Id_GuiaRemision = @@IDENTITY 
--	END
--	ELSE
--	BEGIN
--	   UPDATE dbo.CAJ_GUIA_REMISION
--	   SET
--	       --Id_GuiaRemision - this column value is auto-generated
--	       dbo.CAJ_GUIA_REMISION.Cod_Caja = @Cod_Caja, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Cod_Turno = @Cod_Turno, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Cod_TipoComprobante = @Cod_TipoComprobante, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Serie = @Serie, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Numero = @Numero, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Punto_Partida = @Punto_Partida, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Origen = @Origen, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Nro_Partida = @Nro_Partida, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Fecha_Traslado = @Fecha_Traslado, -- datetime
--	       dbo.CAJ_GUIA_REMISION.Certificado_Inscripcion = @Certificado_Inscripcion, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Certificado_Habilitacion = @Certificado_Habilitacion, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Num_Placa = @Num_Placa, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Licencia_Conductor = @Licencia_Conductor, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Punto_Llegada = @Punto_Llegada, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Destino = @Destino, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Nro_Llegada = @Nro_Llegada, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Id_ClienteProveedor = @Id_ClienteProveedor, -- int
--	       dbo.CAJ_GUIA_REMISION.Id_Transportista = @Id_Transportista, -- int
--	       dbo.CAJ_GUIA_REMISION.Cod_MotivoTraslado = @Cod_MotivoTraslado, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Motivo_Traslado =@Motivo_Traslado, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Obs_GuiaRemision = @Obs_GuiaRemision, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Flag_Anulado = @Flag_Anulado, -- bit
--	       dbo.CAJ_GUIA_REMISION.Cod_EstadoGuia = @Cod_EstadoGuia, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Cod_UsuarioAct = @Cod_Usuario, -- varchar
--	       dbo.CAJ_GUIA_REMISION.Fecha_Act = GETDATE() -- datetime
--	   WHERE dbo.CAJ_GUIA_REMISION.Id_GuiaRemision=@Id_GuiaRemision
--	END
--END
--go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_TABLA_I' AND type = 'P')
DROP PROCEDURE USP_PAR_TABLA_I
go
CREATE PROCEDURE USP_PAR_TABLA_I
    @Cod_Tabla varchar(3),
	@Tabla varchar(512),
	@Des_Tabla varchar(1024),
	@Cod_Sistema varchar(3),
	@Flag_Acceso bit,
	@Cod_Usuario varchar(32)
WITH ENCRYPTION
AS
BEGIN

IF NOT EXISTS (SELECT * FROM dbo.PAR_TABLA pt WHERE pt.Cod_Tabla=@Cod_Tabla)
	BEGIN
	   INSERT dbo.PAR_TABLA
	   VALUES
	   (
	       @Cod_Tabla, -- Cod_Tabla - varchar
	       @Tabla, -- Tabla - varchar
	       @Des_Tabla, -- Des_Tabla - varchar
	       @Cod_Sistema, -- Cod_Sistema - varchar
	       @Flag_Acceso, -- Flag_Acceso - bit
	       @Cod_Usuario, -- Cod_UsuarioReg - varchar
	       GETDATE(), -- Fecha_Reg - datetime
	       NULL, -- Cod_UsuarioAct - varchar
	       NULL -- Fecha_Act - datetime
	   )
	END
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
	   WHERE dbo.PAR_TABLA.Cod_Tabla=@Cod_Tabla
    END
END
GO


-- metodo que marca un comprobante como recibido correctamente
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarComprobante
@Cod_Libro varchar(max),
@Cod_Tipo_Comprobante varchar(max),
@Serie varchar(max),
@Numero varchar(max)
AS
BEGIN

    UPDATE dbo.CAJ_COMPROBANTE_PAGO
    SET
        dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante='INI'
    WHERE dbo.CAJ_COMPROBANTE_PAGO.Cod_Libro=@Cod_Libro AND dbo.CAJ_COMPROBANTE_PAGO.Cod_TipoComprobante=@Cod_Tipo_Comprobante
    AND dbo.CAJ_COMPROBANTE_PAGO.Serie=@Serie AND dbo.CAJ_COMPROBANTE_PAGO.Numero=@Numero AND 
    (dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante IS NULL OR REPLACE(dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante,' ','')='')
END 
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
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_SubirComprobantes' AND type = 'P')
DROP PROCEDURE USP_SubirComprobantes
go
CREATE PROCEDURE USP_SubirComprobantes
WITH ENCRYPTION
AS
BEGIN
    DECLARE @NombreBD varchar(max) = (SELECT DB_NAME() AS [Base de datos actual])
    DECLARE @FechaHoraInicio datetime = GETDATE()
    DECLARE @Resultado varchar(max)
    DECLARE @Linea nvarchar(max)
    DECLARE @IdComprobante int 
    DECLARE  RecorrerScriptComprobantes CURSOR FOR 
    SELECT TOP 1000
    ccp.id_ComprobantePago,'PALERPcomprobantes.PALERPcomprobantes.dbo.USP_CAJ_COMPROBANTE_PAGO_G ' +
    CASE WHEN  pe.RUC IS NULL THEN 'NULL,' ELSE ''''+pe.RUC+''','END+
    CASE WHEN ccp.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ccp.Cod_TipoComprobante+''','END+
    CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+ccp.Serie+''','END+
    CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+ccp.Numero+''','END+
    CASE WHEN ccp.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Cod_TipoDoc,'''','')+''','END+
    CASE WHEN ccp.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Doc_Cliente,'''','')+''','END+
    CASE WHEN ccp.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Nom_Cliente,'''','')+''','END+
    CASE WHEN ccp.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max),ccp.FechaEmision,121)+''','END+
    CONVERT(varchar(max),ccp.Flag_Anulado)+','+
    CASE WHEN ccp.Impuesto IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max),ccp.Impuesto)+','END+
    CASE WHEN ccp.Total IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max),ccp.Total)+','END+
    CASE WHEN vfp.Nom_FormaPago IS NULL THEN 'NULL,' ELSE ''''+vfp.Nom_FormaPago+''','END+
    CASE WHEN vm.Nom_Moneda IS NULL THEN 'NULL,' ELSE ''''+vm.Nom_Moneda+''','END+
    CASE WHEN ccp.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Cod_EstadoComprobante,'''','')+''','END+
    ''''+COALESCE(ccp.Cod_UsuarioReg,ccp.Cod_UsuarioAct)   +''';' 
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
    INNER JOIN dbo.VIS_FORMAS_PAGO vfp ON ccp.Cod_FormaPago = vfp.Cod_FormaPago
    INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
    CROSS JOIN dbo.PRI_EMPRESA pe
    WHERE 
    (((ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_EstadoComprobante IN ('FIN','REC')) OR (ccp.Cod_TipoComprobante IN ('TKB','TKF')))
    AND ccp.Id_GuiaRemision=0 AND ccp.Cod_Libro='14'
    )
    OPEN RecorrerScriptComprobantes
    FETCH NEXT FROM RecorrerScriptComprobantes 
    INTO @IdComprobante,@Linea
    WHILE @@FETCH_STATUS = 0
    BEGIN   
	   --DECLARE @Resultado varchar(max) ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo LINEA A EJECUTAR: '+@Linea+'>> C:\APLICACIONES\LOG\log_exportacion.txt','''',' '),'|',' ')+''''
	   EXECUTE(@Resultado)
	   BEGIN TRY
		  EXECUTE(@Linea)
		  UPDATE dbo.CAJ_COMPROBANTE_PAGO
		  SET dbo.CAJ_COMPROBANTE_PAGO.Id_GuiaRemision=1
		  WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobante
	   END TRY
	   BEGIN CATCH
		  SELECT   
		  ERROR_NUMBER() AS ErrorNumber  
		  ,ERROR_SEVERITY() AS ErrorSeverity  
		  ,ERROR_STATE() AS ErrorState  
		  ,ERROR_PROCEDURE() AS ErrorProcedure  
		  ,ERROR_LINE() AS ErrorLine  
		  ,ERROR_MESSAGE() AS ErrorMessage;  
		  SET @Resultado  = 'master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo ERROR DURANTE LA EJECUCION DEL USP : '+ERROR_MESSAGE()+CONVERT(varchar(max),GETDATE(),121)+'>> C:\APLICACIONES\TEMP\log_Comprobantes_Subidos_Detalle_'+@NombreBD+'.txt','''',' '),'|',' ')+''''
		  EXECUTE(@Resultado)
	   END CATCH
    FETCH NEXT FROM RecorrerScriptComprobantes 
    INTO @IdComprobante,@Linea
    END 
    SET @Resultado  ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo INICIO DE SUBIDA DE DATOS : '+CONVERT(varchar(max),@FechaHoraInicio,121) + ' FIN DE SUBIDA DE DATOS : '+CONVERT(varchar(max),GETDATE(),121) +'>> C:\APLICACIONES\TEMP\log_Comprobantes_Subidos_'+@NombreBD+'.txt','''',' '),'|',' ')+''''
    EXECUTE(@Resultado)
    CLOSE RecorrerScriptComprobantes;
    DEALLOCATE RecorrerScriptComprobantes	
END
go 
--Creacion de la tarea
--Crea la tarea de exportacion que nse inicia desde las 00:00:00 horas hasta la 23:59:59
--Se necesita que exista la carpeta LOG en C:\APLICACIONES
--NumeroIntentos entero el nuemro de intentos , si es 0 sin reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--@RepetirCada el lapso de tiempo en el que se repite la tarea en minutos, por defecto 60
--Ruta de guradado Path absoluto de la ruta del archivo a guardar
--exec USP_CrearTareaAgente N'Tarea exportacion',N'USP_ExportarDatos',N'C:\APLICACIONES\TEMP\log_exportacion.txt'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaAgente' AND type = 'P')
DROP PROCEDURE USP_CrearTareaAgente
GO
CREATE PROCEDURE USP_CrearTareaAgente
@NombreTarea varchar(max),
@Nom_Procedimiento varchar(max),
@RutaGuardado varchar(max)=N'C:\APLICACIONES\TEMP\log_Agente.txt',
@NumeroIntentos int = 2,
@IntervaloMinutos int = 20,
@RepetirCada int = 60
WITH ENCRYPTION
AS
BEGIN
	--Borramnos la tare si existia anteriormente
	DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = @NombreTarea))
	IF (@jobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @jobId
	END

	SET @jobId=null
	--Agregamos la tarea
	EXEC msdb.dbo.sp_add_job @job_name=@NombreTarea, @enabled=1, @owner_login_name=N'sa', @job_id = @jobId OUTPUT
	--Agregamos el paso COPIA DE SEGURIDAD
	DECLARE @BDActual varchar(512) =(SELECT DB_NAME() AS [Base de datos actual])
	DECLARE @Comando varchar(MAX)= 'EXEC ' + @Nom_Procedimiento
	EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TAREA', 
			@step_id=1, 
			@retry_attempts=@NumeroIntentos, 
			@retry_interval=@IntervaloMinutos, 
			@os_run_priority=1, @subsystem=N'TSQL', 
			@command=@Comando, 
			@database_name=@BDActual, 
			@output_file_name=@RutaGuardado,
			@flags=2

	--Agregamos las frecuencias Diario a una hora predeterminada
	DECLARE @FechaHora DATETIME=GETDATE()
	DECLARE @FechaActual int = CONVERT(int, CONCAT(YEAR(@FechaHora),FORMAT(MONTH(@FechaHora),'00'),FORMAT(DAY(@FechaHora),'00')))
	DECLARE @HoraInicio int= CONVERT(int, CONCAT('00',DATEPART(MINUTE, @FechaHora),'00')) 
	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'TAREAS', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=4, 
			@freq_subday_interval=@RepetirCada, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_start_time=@HoraInicio,
			@active_end_date=99991231, 
			@schedule_id=1
	--Agregamos el jobserver
	EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
END

GO

 --Tarea de exportacion
 DECLARE @NombreTarea varchar(max)= N'Tarea Subida Comprobantes_'+(SELECT DB_NAME() AS [Base de datos actual]) 
 DECLARE @NombreUSPexportacion varchar(max)= N'USP_SubirComprobantes' --Por defecto
 DECLARE @RutaGuardadoLOG varchar(max)= ''
 exec USP_CrearTareaAgente @NombreTarea,@NombreUSPexportacion,@RutaGuardadoLOG,@NumeroIntentos= 0,@IntervaloMinutos  = 0,@RepetirCada  = 10

GO

 --METODO QUE DA DE BAJA UN COMPROBANTE POR ID
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_DarBaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja 
@id_ComprobantePago int,
@CodUsuario varchar(32),
@Justificacion varchar(MAX)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Id_Producto  int, @Signo  int, 
	@Cod_Almacen  varchar(32), 
	@Cod_UnidadMedida  varchar(5), 
	@Despachado  numeric(38,6),
	@Documento varchar(128),
	@Proveedor varchar(1024),
	@Detalle varchar(MAX),
	@FechaEmision datetime,
	@FechaActual datetime,
	@id_Fila int;

	SET @FechaActual =GETDATE();

	SELECT @Documento = Cod_Libro +'-'+ Cod_TipoComprobante+':'+Serie+'-'+Numero,
	@Proveedor = Cod_TipoDoc +':'+ Doc_Cliente+'-'+ Nom_Cliente,
	@FechaEmision = FechaEmision
	FROM CAJ_COMPROBANTE_PAGO WHERE id_ComprobantePago = @id_ComprobantePago

	-- RECUPERAR LOS DETALLES
	SET @Detalle = STUFF(( SELECT distinct ' ; ' + convert(varchar,D.Id_Producto) +'|'+d.Descripcion +'|'+convert(varchar,d.Cantidad)
                                     FROM   CAJ_COMPROBANTE_D D
                                     WHERE  D.id_ComprobantePago = @id_ComprobantePago
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ''

	set @Signo = (select case Cod_Libro when '08' then -1 when '14' then 1 else 0 end from CAJ_COMPROBANTE_PAGO 
	where id_ComprobantePago = @id_ComprobantePago);

	DECLARE ComprobanteD CURSOR FOR
		SELECT Id_Producto,Cod_UnidadMedida,Cod_Almacen,Despachado
		from CAJ_COMPROBANTE_D
		WHERE id_ComprobantePago = @id_ComprobantePago and Id_Producto <> 0
		OPEN ComprobanteD;
	FETCH NEXT FROM ComprobanteD INTO @Id_Producto,@Cod_UnidadMedida,@Cod_Almacen,@Despachado;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE PRI_PRODUCTO_STOCK 
		SET Stock_Act = Stock_Act+@Signo * @Despachado
		WHERE Id_Producto = @Id_Producto and Cod_UnidadMedida = @Cod_UnidadMedida and Cod_Almacen = @Cod_Almacen
	FETCH NEXT FROM ComprobanteD INTO @Id_Producto,@Cod_UnidadMedida,@Cod_Almacen,@Despachado;
	END;
	CLOSE ComprobanteD;
	DEALLOCATE ComprobanteD;

	--Actualizamos la informacion en comprobante pago
	UPDATE dbo.CAJ_COMPROBANTE_PAGO
	SET	
	dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado=1,
	dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante='REC',
	dbo.CAJ_COMPROBANTE_PAGO.Impuesto=0,
	dbo.CAJ_COMPROBANTE_PAGO.Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos=0,
	dbo.CAJ_COMPROBANTE_PAGO.MotivoAnulacion=@Justificacion,
	dbo.CAJ_COMPROBANTE_PAGO.Id_GuiaRemision=0
	WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@id_ComprobantePago

    --Actualizamos la informacion de los detalles
	UPDATE dbo.CAJ_COMPROBANTE_D
	SET	
	dbo.CAJ_COMPROBANTE_D.Cantidad=0,
	dbo.CAJ_COMPROBANTE_D.Despachado=0,
	dbo.CAJ_COMPROBANTE_D.Formalizado=0,
	dbo.CAJ_COMPROBANTE_D.Descuento=0,
	dbo.CAJ_COMPROBANTE_D.Sub_Total=0,
	dbo.CAJ_COMPROBANTE_D.IGV=0,
	dbo.CAJ_COMPROBANTE_D.ISC=0
	WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@id_ComprobantePago

	--Actualizamos la informacion de la forma de pago
	UPDATE dbo.CAJ_FORMA_PAGO
	SET
	dbo.CAJ_FORMA_PAGO.Monto = 0
	WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@id_ComprobantePago

	--Eliminamos todas las relaciones
	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (Id_ComprobanteRelacion = @id_ComprobantePago)
	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	--Eliminamos las licitaciones
	DELETE FROM PRI_LICITACIONES_M
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	-- Eliminar las Serie que se colocaron
	DELETE FROM CAJ_SERIES
	WHERE (Id_Tabla = @id_ComprobantePago AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')

	-- insertar elementos en un datos a ver que pasa
	SET @id_Fila = (SELECT ISNULL(COUNT(*)/9,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '079')
	EXEC USP_PAR_FILA_G '079','001',@id_Fila,@Documento,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','002',@id_Fila,'CAJ_COMPROBANTE_PAGO',NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','003',@id_Fila,@Proveedor,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','004',@id_Fila,@Detalle,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','005',@id_Fila,NULL,NULL,NULL,@FechaEmision,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','006',@id_Fila,NULL,NULL,NULL,@FechaActual,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','007',@id_Fila,@CodUsuario,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','008',@id_Fila,@Justificacion,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','009',@id_Fila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';	
END
go



----------------------------------------------------------------------------------------
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_REGISTRO_LOG_TraerTodo' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo
GO

CREATE PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo
WITH ENCRYPTION
AS
BEGIN
	SELECT trl.* FROM dbo.TMP_REGISTRO_LOG trl ORDER BY trl.Id
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_REGISTRO_LOG_MoverUno' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno
GO

CREATE PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno
@Id varchar(max)
WITH ENCRYPTION
AS
BEGIN
    --Exporta una fila a un archivo de texto
    --Variables generales 
	DECLARE @cmd varchar(max)
	DECLARE @Nombre_Tabla varchar(max) 
	DECLARE @Id_Fila varchar(max) 
	DECLARE @Accion varchar(max) 
	DECLARE @Script varchar(max) 
	DECLARE @Fecha_Reg datetime 
	--Recuperamos el y almacenamos en las variables
	SELECT 
	    @Id=trl.Id, 
	    @Nombre_Tabla=trl.Nombre_Tabla, 
	    @Id_Fila=trl.Id_Fila, 
	    @Accion=trl.Accion, 
	    @Script=trl.Script, 
	    @Fecha_Reg=trl.Fecha_Reg 
	FROM dbo.TMP_REGISTRO_LOG trl
	WHERE trl.Id=@Id

	IF @Id IS NOT NULL
	BEGIN
		  
		      SET XACT_ABORT ON;  
			 BEGIN TRY  
			 BEGIN TRANSACTION;  
			 INSERT dbo.TMP_REGISTRO_LOG_H
			 (
				Nombre_Tabla,
				Id_Fila,
				Accion,
				Script,
				Fecha_Reg,
				Fecha_Reg_Insercion
			 )
			 VALUES
			 (
				@Nombre_Tabla, -- Nombre_Tabla - varchar
				@Id_Fila, -- Id_Fila - varchar
				@Accion, -- Accion - varchar
				@Script, -- Script - varchar
				@Fecha_Reg, -- Fecha_Reg - datetime
				GETDATE() -- Fecha_Reg_Insercion - datetime
			 )
			 DELETE dbo.TMP_REGISTRO_LOG WHERE @Id=dbo.TMP_REGISTRO_LOG.Id

			 COMMIT TRANSACTION;
		  END TRY  
      
		  BEGIN CATCH  
			 IF (XACT_STATE()) = -1  
			 BEGIN  
				ROLLBACK TRANSACTION; 
			 END;  
			 IF (XACT_STATE()) = 1  
			 BEGIN  
				COMMIT TRANSACTION;    
			 END;  
			 THROW;
		  END CATCH;  
	END
END

GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ObtenerDatos_Servidor' AND type = 'P')
DROP PROCEDURE USP_ObtenerDatos_Servidor
go
CREATE PROCEDURE USP_ObtenerDatos_Servidor

WITH ENCRYPTION
AS
BEGIN
    SELECT @@SERVERNAME AS 'SERVIDOR',@@SPID AS 'ID',SYSTEM_USER AS 'LOGIN',USER AS 'USER', @@LANGUAGE AS 'LENGUAJE',@@REMSERVER  AS 'SERVIDOR_BASE',@@VERSION AS 'VERSION_SQL',DB_NAME() AS 'NOMBRE_BD'
END
GO

--Añadidos para borrar los datos

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_D' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_D
go
CREATE PROCEDURE USP_ALM_ALMACEN_D 
	@Cod_Almacen	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.ALM_ALMACEN WHERE dbo.ALM_ALMACEN.Cod_Almacen=@Cod_Almacen
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_D' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_MOV_D
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(32),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @Id_AlmacenMov	int =(SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Cod_TipoComprobante=@Cod_TipoComprobante AND aam.Serie=@Serie AND aam.Numero=@Numero)
		DELETE dbo.ALM_ALMACEN_MOV WHERE dbo.ALM_ALMACEN_MOV.Id_AlmacenMov=@Id_AlmacenMov
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_D_D' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_MOV_D_D
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D_D 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(32), 
	@Item	int, 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @Id_AlmacenMov	int =(SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Cod_TipoComprobante=@Cod_TipoComprobante AND aam.Serie=@Serie AND aam.Numero=@Numero)
		DELETE dbo.ALM_ALMACEN_MOV_D WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov=@Id_AlmacenMov AND dbo.ALM_ALMACEN_MOV_D.Item=@Item
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_INVENTARIO_D' AND type = 'P')
	DROP PROCEDURE USP_ALM_INVENTARIO_D
go
CREATE PROCEDURE USP_ALM_INVENTARIO_D 
	@Cod_TipoInventario	varchar(5), 
	@Cod_Almacen	varchar(32),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @Id_Inventario int = (SELECT ai.Id_Inventario FROM dbo.ALM_INVENTARIO ai WHERE ai.Cod_TipoInventario=@Cod_TipoInventario AND ai.Cod_Almacen=@Cod_Almacen)
		DELETE dbo.ALM_INVENTARIO WHERE dbo.ALM_INVENTARIO.Id_Inventario=@Id_Inventario
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_INVENTARIO_D_D' AND type = 'P')
	DROP PROCEDURE USP_ALM_INVENTARIO_D_D
go
CREATE PROCEDURE USP_ALM_INVENTARIO_D_D 
	@Cod_TipoInventario	varchar(5), 
	@Cod_Almacen	varchar(32),
	@Item int,
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @Id_Inventario int = (SELECT ai.Id_Inventario FROM dbo.ALM_INVENTARIO ai WHERE ai.Cod_TipoInventario=@Cod_TipoInventario AND ai.Cod_Almacen=@Cod_Almacen)
		DELETE dbo.ALM_INVENTARIO WHERE dbo.ALM_INVENTARIO.Id_Inventario=@Id_Inventario
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_D' AND type = 'P')
	DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_D
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_D 
	@Cod_CuentaBancaria	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.BAN_CUENTA_BANCARIA WHERE dbo.BAN_CUENTA_BANCARIA.Cod_CuentaBancaria=@Cod_CuentaBancaria
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_M_D' AND type = 'P')
	DROP PROCEDURE USP_BAN_CUENTA_M_D
go
CREATE PROCEDURE USP_BAN_CUENTA_M_D 
	@Cod_CuentaBancaria	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.BAN_CUENTA_BANCARIA WHERE dbo.BAN_CUENTA_BANCARIA.Cod_CuentaBancaria=@Cod_CuentaBancaria
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @id_ArqueoFisico int = (SELECT TOP 1 id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
		DELETE dbo.CAJ_ARQUEOFISICO WHERE dbo.CAJ_ARQUEOFISICO.id_ArqueoFisico=@id_ArqueoFisico
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_D_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D_D
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D_D 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Billete varchar(3),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @id_ArqueoFisico int = (SELECT id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
		DELETE dbo.CAJ_ARQUEOFISICO_D WHERE dbo.CAJ_ARQUEOFISICO_D.id_ArqueoFisico=@id_ArqueoFisico AND dbo.CAJ_ARQUEOFISICO_D.Cod_Billete=@Cod_Billete
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_SALDO_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_D
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_D 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Moneda	varchar(3), 
	@Tipo	varchar(32),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @id_ArqueoFisico int = (SELECT TOP 1 id_ArqueoFisico FROM CAJ_ARQUEOFISICO WHERE (Cod_Caja=@Cod_Caja) and (Cod_Turno=@Cod_Turno))
		DELETE dbo.CAJ_ARQUEOFISICO_SALDO WHERE dbo.CAJ_ARQUEOFISICO_SALDO.id_ArqueoFisico = @id_ArqueoFisico AND  dbo.CAJ_ARQUEOFISICO_SALDO.Cod_Moneda=@Cod_Moneda AND dbo.CAJ_ARQUEOFISICO_SALDO.Tipo=@Tipo
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_ALMACEN_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_D
go
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_D 
	@Cod_Caja	varchar(32), 
	@Cod_Almacen	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.CAJ_CAJA_ALMACEN WHERE dbo.CAJ_CAJA_ALMACEN.Cod_Caja=@Cod_Caja AND dbo.CAJ_CAJA_ALMACEN.Cod_Almacen=@Cod_Almacen
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_D
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_D 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(4), 
	@Numero	varchar(20), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DECLARE @id_Movimiento	int =(SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS where Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie and Numero=@Numero)
		DELETE dbo.CAJ_CAJA_MOVIMIENTOS WHERE dbo.CAJ_CAJA_MOVIMIENTOS.id_Movimiento=@id_Movimiento
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_D
go
CREATE PROCEDURE USP_CAJ_CAJAS_D 
	@Cod_Caja	varchar(32),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.CAJ_CAJAS WHERE dbo.CAJ_CAJAS.Cod_Caja=@Cod_Caja
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_D' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_D
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_D 
	@Cod_Caja	varchar(32),  
	@Item	int,
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY;
		DELETE dbo.CAJ_CAJAS_DOC WHERE dbo.CAJ_CAJAS_DOC.Cod_Caja=@Cod_Caja AND dbo.CAJ_CAJAS_DOC.Item=@Item
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_D_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_D_D
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_D 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@id_Detalle  int, 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @id_ComprobantePago INT=(SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
		WHERE Cod_Libro = @Cod_Libro
		AND Cod_TipoComprobante = @Cod_TipoComprobante
		AND Serie = @Serie
		AND Numero= @Numero)
		DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@id_Detalle
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_LOG_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_LOG_D
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_D 
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Itemn int,
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @id_ComprobantePago int = (SELECT TOP 1 ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Numero=@Numero)
		DELETE dbo.CAJ_COMPROBANTE_LOG WHERE dbo.CAJ_COMPROBANTE_LOG.id_ComprobantePago=@id_ComprobantePago AND dbo.CAJ_COMPROBANTE_LOG.Item=@Itemn
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_LOG_D
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_LOG_D 
	@Cod_Libro	varchar(2), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ComprobantePago int = (SELECT ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_Libro=@Cod_Libro AND ccp.Cod_TipoComprobante=@Cod_TipoComprobante
		AND ccp.Serie=@Serie AND ccp.Numero=@Numero)
		DELETE dbo.CAJ_COMPROBANTE_PAGO WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_ComprobantePago
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_COMPROBANTE_RELACION_D
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_D 
	@Cod_Libro	varchar(2), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30),
	@Id_Detalle int,
	@Item int, 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ComprobantePago int = (SELECT ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_Libro=@Cod_Libro AND ccp.Cod_TipoComprobante=@Cod_TipoComprobante
		AND ccp.Serie=@Serie AND ccp.Numero=@Numero)
		DELETE dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_RELACION.id_Detalle=@Id_Detalle AND dbo.CAJ_COMPROBANTE_RELACION.Item=@Item
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CONCEPTO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_CONCEPTO_D
go
CREATE PROCEDURE USP_CAJ_CONCEPTO_D 
	@Id_Concepto int,
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.CAJ_CONCEPTO WHERE dbo.CAJ_CONCEPTO.Id_Concepto=@Id_Concepto
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_FORMA_PAGO_D
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_D 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Item	int, 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @id_ComprobantePago int = (SELECT  id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_Libro AND Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie AND Numero=@Numero)
		DELETE dbo.CAJ_FORMA_PAGO WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@id_ComprobantePago AND dbo.CAJ_FORMA_PAGO.Item=@Item
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_VC_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_MEDICION_VC_D
go
CREATE PROCEDURE USP_CAJ_MEDICION_VC_D 
	@Cod_AMedir	varchar(32), 
	@Medio_AMedir	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.CAJ_MEDICION_VC WHERE dbo.CAJ_MEDICION_VC.Cod_AMedir=@Cod_AMedir AND dbo.CAJ_MEDICION_VC.Medio_AMedir=@Medio_AMedir AND dbo.CAJ_MEDICION_VC.Cod_Turno=@Cod_Turno
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TIPOCAMBIO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_TIPOCAMBIO_D
go
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_D 
	@FechaHora	VARCHAR(32), 
	@Cod_Moneda	varchar(3), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_TipoCambio	int = (SELECT ct.Id_TipoCambio FROM dbo.CAJ_TIPOCAMBIO ct WHERE ct.FechaHora=@FechaHora AND ct.Cod_Moneda=@Cod_Moneda)
		DELETE dbo.CAJ_TIPOCAMBIO WHERE dbo.CAJ_TIPOCAMBIO.Id_TipoCambio=@Id_TipoCambio
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TURNO_ATENCION_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_CAJ_TURNO_ATENCION_D
go
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_D 
	@Cod_Turno	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.CAJ_TURNO_ATENCION WHERE dbo.CAJ_TURNO_ATENCION.Cod_Turno=@Cod_Turno
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_COLUMNA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PAR_COLUMNA_D
go
CREATE PROCEDURE USP_PAR_COLUMNA_D 
	@Cod_Tabla varchar(3),
	@Cod_Columna varchar(3), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PAR_COLUMNA WHERE dbo.PAR_COLUMNA.Cod_Tabla=@Cod_Tabla AND dbo.PAR_COLUMNA.Cod_Columna=@Cod_Columna
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_FILA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PAR_FILA_D
go
CREATE PROCEDURE USP_PAR_FILA_D 
	@Cod_Tabla varchar(3),
    @Cod_Columna varchar(3),
    @Cod_Fila int, 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PAR_FILA WHERE dbo.PAR_FILA.Cod_Tabla=@Cod_Tabla AND dbo.PAR_FILA.Cod_Columna=@Cod_Columna AND dbo.PAR_FILA.Cod_Fila=@Cod_Fila
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAR_TABLA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PAR_TABLA_D
go
CREATE PROCEDURE USP_PAR_TABLA_D 
	@Cod_Tabla varchar(3),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PAR_TABLA WHERE dbo.PAR_TABLA.Cod_Tabla=@Cod_Tabla
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ACTIVIDADES_ECONOMICAS_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_ACTIVIDADES_ECONOMICAS_D
go
CREATE PROCEDURE USP_PRI_ACTIVIDADES_ECONOMICAS_D 
	@Cod_ActividadEconomica	varchar(32), 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
		DELETE dbo.PRI_ACTIVIDADES_ECONOMICAS WHERE dbo.PRI_ACTIVIDADES_ECONOMICAS.Cod_ActividadEconomica=@Cod_ActividadEconomica AND dbo.PRI_ACTIVIDADES_ECONOMICAS.Id_ClienteProveedor=@Id_ClienteProveedor
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_AREAS_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_AREAS_D
go
CREATE PROCEDURE USP_PRI_AREAS_D 
	@Cod_Area	varchar(32),  
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PRI_AREAS WHERE dbo.PRI_AREAS.Cod_Area=@Cod_Area
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CATEGORIA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CATEGORIA_D
go
CREATE PROCEDURE USP_PRI_CATEGORIA_D 
	@Cod_Categoria	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PRI_CATEGORIA WHERE dbo.PRI_CATEGORIA.Cod_Categoria=@Cod_Categoria
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CONTACTO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_CONTACTO_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_D 
	@Cod_TipoDocumentoP	varchar(5), 
	@Nro_DocumentoP	varchar(20), 
	@Cod_TipoDocumentoC	varchar(5), 
	@Nro_DocumentoC	varchar(20),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoP and Nro_Documento=@Nro_DocumentoP)
		DECLARE @Id_ClienteContacto	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoC and Nro_Documento=@Nro_DocumentoC)
		DELETE dbo.PRI_CLIENTE_CONTACTO WHERE dbo.PRI_CLIENTE_CONTACTO.Id_ClienteProveedor=@Id_ClienteProveedor AND dbo.PRI_CLIENTE_CONTACTO.Id_ClienteContacto=@Id_ClienteContacto
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CUENTABANCARIA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_CUENTABANCARIA_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_D 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@NroCuenta_Bancaria	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor INT = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
		DELETE dbo.PRI_CLIENTE_CUENTABANCARIA WHERE dbo.PRI_CLIENTE_CUENTABANCARIA.Id_ClienteProveedor=@Id_ClienteProveedor AND dbo.PRI_CLIENTE_CUENTABANCARIA.NroCuenta_Bancaria=@NroCuenta_Bancaria
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PRODUCTO_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_PRODUCTO_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_PRODUCTO_D 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Producto  varchar(5),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
		DECLARE @Id_Producto	int = (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
		DELETE dbo.PRI_CLIENTE_PRODUCTO WHERE dbo.PRI_CLIENTE_PRODUCTO.Id_ClienteProveedor=@Id_ClienteProveedor AND dbo.PRI_CLIENTE_PRODUCTO.Id_Producto=@Id_Producto
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_PROVEEDOR_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_D 
	@Cod_TipoDocumento  varchar(3),
	@Nro_Documento  varchar(32),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor INT = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
		DELETE dbo.PRI_CLIENTE_PROVEEDOR WHERE dbo.PRI_CLIENTE_PROVEEDOR.Id_ClienteProveedor=@Id_ClienteProveedor
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_VEHICULOS_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_VEHICULOS_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_VEHICULOS_D 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Placa	varchar(32),
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
		DELETE dbo.PRI_CLIENTE_VEHICULOS WHERE dbo.PRI_CLIENTE_VEHICULOS.Id_ClienteProveedor=@Id_ClienteProveedor AND dbo.PRI_CLIENTE_VEHICULOS.Cod_Placa=@Cod_Placa
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_VISITAS_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CLIENTE_VISITAS_D
go
CREATE PROCEDURE USP_PRI_CLIENTE_VISITAS_D 
	@Cod_ClienteVisita	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PRI_CLIENTE_VISITAS WHERE dbo.PRI_CLIENTE_VISITAS.Cod_ClienteVisita=@Cod_ClienteVisita
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CUENTA_CONTABLE_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_CUENTA_CONTABLE_D
go
CREATE PROCEDURE USP_PRI_CUENTA_CONTABLE_D 
	@Cod_CuentaContable	varchar(16), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PRI_CUENTA_CONTABLE WHERE dbo.PRI_CUENTA_CONTABLE.Cod_CuentaContable=@Cod_CuentaContable
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_DESCUENTOS_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_DESCUENTOS_D
go
CREATE PROCEDURE USP_PRI_DESCUENTOS_D 
	@Cod_TipoDocumento  varchar(3), 
	@Nro_Documento  varchar(32), 
	@Cod_TipoDescuento	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DECLARE @Id_ClienteProveedor INT = (SELECT TOP 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
		DECLARE @Id_Descuento	int = (SELECT pd.Id_Descuento FROM dbo.PRI_DESCUENTOS pd WHERE pd.Cod_TipoDescuento=@Cod_TipoDescuento AND pd.Id_ClienteProveedor=@Id_ClienteProveedor)
		DELETE dbo.PRI_DESCUENTOS WHERE dbo.PRI_DESCUENTOS.Id_Descuento=@Id_Descuento
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_D' AND type = 'P')
	DROP PROCEDURE dbo.USP_PRI_EMPRESA_D
go
CREATE PROCEDURE USP_PRI_EMPRESA_D 
	@Cod_Empresa	varchar(32), 
	@Cod_Usuario Varchar(32),
	@Motivo varchar(max)
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRANSACTION;  
	BEGIN TRY
		DELETE dbo.PRI_EMPRESA WHERE dbo.PRI_EMPRESA.Cod_Empresa=@Cod_Empresa
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
  
	IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION;  
	END CATCH;  
		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  
END
GO

