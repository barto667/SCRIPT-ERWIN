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
	@Fecha_Incorporacion	datetime,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoP and Nro_Documento=@Nro_DocumentoP)
DECLARE @Id_ClienteContacto	int = (SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumentoC and Nro_Documento=@Nro_DocumentoC)
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
		@Fecha_Incorporacion,
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
			Fecha_Incorporacion = @Fecha_Incorporacion,
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
	@Fecha_Ingreso	datetime, 
	@Fecha_Nacimiento	datetime, 
	@Cod_Cargo	varchar(32), 
	@Cod_Estado	varchar(32), 
	@Cod_Area	varchar(32), 
	@Cod_Local	varchar(16), 
	@Cod_CentroCostos	varchar(16), 
	@Cod_EstadoCivil	varchar(32), 
	@Fecha_InsESSALUD	datetime, 
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
		@Fecha_Ingreso,
		@Fecha_Nacimiento,
		@Cod_Cargo,
		@Cod_Estado,
		@Cod_Area,
		@Cod_Local,
		@Cod_CentroCostos,
		@Cod_EstadoCivil,
		@Fecha_InsESSALUD,
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
			Fecha_Ingreso = @Fecha_Ingreso, 
			Fecha_Nacimiento = @Fecha_Nacimiento, 
			Cod_Cargo = @Cod_Cargo, 
			Cod_Estado = @Cod_Estado, 
			Cod_Area = @Cod_Area, 
			Cod_Local = @Cod_Local, 
			Cod_CentroCostos = @Cod_CentroCostos, 
			Cod_EstadoCivil = @Cod_EstadoCivil, 
			Fecha_InsESSALUD = @Fecha_InsESSALUD, 
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
	@Fecha_Inicio	datetime, 
	@Fecha_Fin	datetime, 
	@Nro_Resolucion	varchar(64),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
							WHERE  (Cod_TipoDocumento = @Cod_TipoDocumento
							AND Nro_Documento = @Nro_Documento));
IF NOT EXISTS (SELECT * FROM PRI_PADRONES WHERE  (Cod_Padron = @Cod_Padron) AND (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_PADRONES  VALUES (
		@Cod_Padron,
		@Id_ClienteProveedor,
		@Cod_TipoPadron,
		@Des_Padron,
		@Fecha_Inicio,
		@Fecha_Fin,
		@Nro_Resolucion,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_PADRONES
		SET	
			Cod_TipoPadron = @Cod_TipoPadron, 
			Des_Padron = @Des_Padron, 
			Fecha_Inicio = @Fecha_Inicio, 
			Fecha_Fin = @Fecha_Fin, 
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
	@Fecha_Remite	datetime, 
	@Mensaje	varchar(1024), 
	@Flag_Leido	bit, 
	@Cod_UsuarioRecibe	varchar(32), 
	@Fecha_Recibe	datetime,
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
		@Fecha_Remite,
		@Mensaje,
		@Flag_Leido,
		@Cod_UsuarioRecibe,
		@Fecha_Recibe,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE PRI_MENSAJES
		SET	
			Cod_UsuarioRemite = @Cod_UsuarioRemite, 
			Fecha_Remite = @Fecha_Remite, 
			Mensaje = @Mensaje, 
			Flag_Leido = @Flag_Leido, 
			Cod_UsuarioRecibe = @Cod_UsuarioRecibe, 
			Fecha_Recibe = @Fecha_Recibe,
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
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
	@Fecha_Inicia	datetime, 
	@Fecha_Fin	datetime, 
	@Obs_Descuento	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
		@Fecha_Inicia,
		@Fecha_Fin,
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
			Fecha_Inicia = @Fecha_Inicia, 
			Fecha_Fin = @Fecha_Fin, 
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
	@Fecha_HoraVisita	datetime, 
	@Comentarios	varchar(1024), 
	@Flag_Compromiso	bit, 
	@Fecha_HoraCompromiso	datetime, 
	@Cod_UsuarioResponsable	varchar(8), 
	@Des_Compromiso	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor INT;
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
		@Fecha_HoraVisita,
		@Comentarios,
		@Flag_Compromiso,
		@Fecha_HoraCompromiso,
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
			Fecha_HoraVisita = @Fecha_HoraVisita, 
			Comentarios = @Comentarios, 
			Flag_Compromiso = @Flag_Compromiso, 
			Fecha_HoraCompromiso = @Fecha_HoraCompromiso, 
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
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
DECLARE @Id_ClienteProveedor	int=(SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
	@FechaHora	datetime, 
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
		@FechaHora,
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
			FechaHora = @FechaHora, 
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
@Fecha_Nacimiento  datetime, 
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
SET @Id_ClienteProveedor = (SELECT ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
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
		@Fecha_Nacimiento,
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
			Fecha_Nacimiento = @Fecha_Nacimiento, 
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
	@Fecha_Inicio	datetime, 
	@Fecha_Fin	datetime, 
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
		@Fecha_Inicio,
		@Fecha_Fin,
		@Flag_Cerrado,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_TURNO_ATENCION
		SET	
			Des_Turno = @Des_Turno, 
			Fecha_Inicio = @Fecha_Inicio, 
			Fecha_Fin = @Fecha_Fin, 
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
	@Fecha_Medicion	datetime, 
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
		@Fecha_Medicion,
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
			Fecha_Medicion = @Fecha_Medicion, 
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
	@Fecha	datetime, 
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
		@Fecha,
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
			Fecha = @Fecha, 
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
	@Fecha_Inicio	datetime, 
	@Fecha_Facturacion	datetime, 
	@Flag_AlFinal	bit, 
	@Cod_TipoComprobante	varchar(5),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
IF NOT EXISTS (SELECT * FROM PRI_LICITACIONES WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion))
	BEGIN
		INSERT INTO PRI_LICITACIONES  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Des_Licitacion,
		@Cod_TipoLicitacion,
		@Nro_Licitacion,
		@Fecha_Inicio,
		@Fecha_Facturacion,
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
			Fecha_Inicio = @Fecha_Inicio, 
			Fecha_Facturacion = @Fecha_Facturacion, 
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
DECLARE @Id_ClienteProveedor	int=(SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
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
	@Fecha	datetime, 
	@Tipo_Cambio	numeric(10,4), 
	@Ingreso	numeric(38,2), 
	@Cod_MonedaIng	varchar(3), 
	@Egreso	numeric(38,2), 
	@Cod_MonedaEgr	varchar(3), 
	@Flag_Extornado	bit, 
	@Cod_UsuarioAut	varchar(32), 
	@Fecha_Aut	datetime, 
	@Obs_Movimiento	xml, 
	@Id_MovimientoRef	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor int= (select Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento AND Nro_Documento=@DocCliente)
DECLARE @Nom_Cliente varchar(MAX)= (select Nombres FROM PRI_CLIENTE_PROVEEDOR where Id_ClienteProveedor=@Id_ClienteProveedor)
DECLARE @id_Movimiento	int =(SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS where Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie and Numero=@Numero) 
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
		@Fecha,
		@Tipo_Cambio,
		@Ingreso,
		@Cod_MonedaIng,
		@Egreso,
		@Cod_MonedaEgr,
		@Flag_Extornado,
		@Cod_UsuarioAut,
		@Fecha_Aut,
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
			Fecha = @Fecha, 
			Tipo_Cambio = @Tipo_Cambio, 
			Ingreso = @Ingreso, 
			Cod_MonedaIng = @Cod_MonedaIng, 
			Egreso = @Egreso, 
			Cod_MonedaEgr = @Cod_MonedaEgr, 
			Flag_Extornado = @Flag_Extornado, 
			Cod_UsuarioAut = @Cod_UsuarioAut, 
			Fecha_Aut = @Fecha_Aut, 
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
	@FechaEmision	datetime, 
	@FechaVencimiento	datetime, 
	@FechaCancelacion	datetime, 
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
	@id_ComprobanteRef	int, 
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
DECLARE @Id_Cliente int =(SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc and Nro_Documento=@Doc_Cliente)
DECLARE @id_ComprobantePago	int =(SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_Libro AND Cod_Periodo=@Cod_Periodo AND 
Cod_Caja=@Cod_Caja AND Cod_Turno=@Cod_Turno AND Cod_TipoOperacion=@Cod_TipoOperacion AND Cod_TipoComprobante=@Cod_TipoComprobante AND Serie=@Serie
AND Numero=@Numero AND Id_Cliente=@Id_Cliente)

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
		@FechaEmision,
		@FechaVencimiento,
		@FechaCancelacion,
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
			FechaEmision = @FechaEmision, 
			FechaVencimiento = @FechaVencimiento, 
			FechaCancelacion = @FechaCancelacion, 
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
			Valor_Resumen = @Valor_Resumen, 
			Valor_Firma = @Valor_Firma, 
			Cod_EstadoComprobante = @Cod_EstadoComprobante, 
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
	AND Numero= @Numero
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente);

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
	@FechaVencimiento datetime,
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
		@FechaVencimiento,
		@Obs_Series,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_SERIES
		SET	
			Serie=@Serie,
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
	@FechaVencimiento datetime,
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
		@FechaVencimiento,
		@Obs_Series,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_SERIES
		SET	
			Serie=@Serie,
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
	AND Numero= @Numero
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente)

DECLARE @id_ComprobanteRelacion INT=0;
	SET @id_ComprobanteRelacion = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_LibroR
	AND Cod_TipoComprobante = @Cod_TipoComprobanteR
	AND Serie = @SerieR
	AND Numero= @NumeroR
	AND Cod_TipoDoc = @Cod_TipoDocR
	AND Doc_Cliente = @Doc_ClienteR)

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
DECLARE @Id_ClienteProveedor	int = (SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocC AND @Doc_ClienteC=Nro_Documento )
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
DECLARE @Id_ClienteProveedor	int = (SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
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
	@Fecha	datetime, 
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
		@Fecha,
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
			Fecha = @Fecha, 
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
	@Fecha	datetime, 
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
	AND Cod_TipoComprobante = @Cod_TipoComprobante
	AND Serie = @Serie
	AND Numero= @Numero
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente)
DECLARE @Id_AlmacenMov	int =(SELECT Id_AlmacenMov FROM ALM_ALMACEN_MOV WHERE Cod_Almacen=@Cod_Almacen AND Cod_TipoOperacion=@Cod_TipoOperacion AND Cod_Turno=@Cod_Turno
AND Cod_TipoComprobante=@Cod_TipoComprobanteM AND Serie=@SerieM AND Numero=@NumeroM)
IF NOT EXISTS (SELECT * FROM ALM_ALMACEN_MOV WHERE  (Id_AlmacenMov = @Id_AlmacenMov))
	BEGIN
		INSERT INTO ALM_ALMACEN_MOV  VALUES (
		@Cod_Almacen,
		@Cod_TipoOperacion,
		@Cod_Turno,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		@Fecha,
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
			Fecha = @Fecha, 
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
DECLARE @Id_ClienteProveedor	int = (SELECT Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDoc AND @Doc_Cliente=Nro_Documento )
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
	@Fecha	datetime,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago int = (SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE Cod_Libro=@Cod_Libro AND Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie AND Numero=@Numero
AND Cod_TipoDoc=@Cod_TipoDoc and Doc_Cliente=@Doc_Cliente)

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
		@Fecha,
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
			Fecha = @Fecha,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Item = @Item)	
	END
END
go

--SET DATEFORMAT DMY;
--EXEC USP_ExportarDatos 

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ExportarDatos' AND type = 'P')
DROP PROCEDURE USP_ExportarDatos
go
CREATE PROCEDURE USP_ExportarDatos
WITH ENCRYPTION
AS
BEGIN
BEGIN TRY   

	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaInicio DATETIME=(select Top 1 Fecha_Act from PRI_EMPRESA)
    	DECLARE @FechaFin DATETIME=(GETDATE())
	
	SELECT *  into #exportar FROM (
	
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_EMPRESA_I ' +
	''''+ pe.Cod_Empresa +''','+
	CASE WHEN  pe.RUC IS NULL  THEN 'NULL,'    ELSE ''''+ pe.RUC+''','END+
	CASE WHEN  pe.Nom_Comercial IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Nom_Comercial+''','END+
	CASE WHEN  pe.RazonSocial IS NULL  THEN 'NULL,'    ELSE ''''+ pe.RazonSocial+''','END+
	CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Direccion+''','END+
	CASE WHEN  pe.Telefonos IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Telefonos+''','END+
	CASE WHEN  pe.Web IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Web+''','END+
	'NULL,'+
	'NULL,'+
	convert(varchar(max),pe.Flag_ExoneradoImpuesto)+','+
	CASE WHEN  pe.Des_Impuesto IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Des_Impuesto+''','END+
	CASE WHEN  pe.Por_Impuesto IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pe.Por_Impuesto)+''','END+
	CASE WHEN  pe.EstructuraContable IS NULL  THEN 'NULL,'    ELSE '''' +pe.EstructuraContable+''','END+
	CASE WHEN  pe.Version IS NULL  THEN 'NULL,'    ELSE '''' +pe.Version+''','END+
	CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE '''' +pe.Cod_Ubigeo+''','END+
	''''+COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 1 as Orden, COALESCE(pe.Fecha_Act,pe.Fecha_Reg) as Fecha
	FROM dbo.PRI_EMPRESA pe
	WHERE 
			(pe.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pe.Fecha_Act IS NULL) 
			OR (pe.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION 
 

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
	''''+ps.Cod_Sucursal+''','+
	CASE WHEN ps.Nom_Sucursal IS NULL THEN 'NULL,' ELSE ''''+ps.Nom_Sucursal +''','END+
	CASE WHEN ps.Dir_Sucursal IS NULL THEN 'NULL,' ELSE ''''+ps.Dir_Sucursal +''','END+
	CASE WHEN ps.Por_UtilidadMax IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), ps.Por_UtilidadMax) +','END+
	CASE WHEN ps.Por_UtilidadMin IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), ps.Por_UtilidadMin) +','END+
	CASE WHEN ps.Cod_UsuarioAdm IS NULL THEN 'NULL,' ELSE ''''+ps.Cod_UsuarioAdm +''','END+
	CASE WHEN ps.Cabecera_Pagina IS NULL THEN 'NULL,' ELSE ''''+ps.Cabecera_Pagina +''','END+
	CASE WHEN ps.Pie_Pagina IS NULL THEN 'NULL,' ELSE ''''+ps.Pie_Pagina +''','END+
	convert(varchar(max),ps.Flag_Activo)+','+
	CASE WHEN ps.Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+ps.Cod_Ubigeo +''','END+
	''''+COALESCE(ps.Cod_UsuarioAct,ps.Cod_UsuarioReg)   +''';' 
		AS Scripsxportar, 2 as Orden, COALESCE(ps.Fecha_Act,ps.Fecha_Reg) as Fecha
	FROM dbo.PRI_SUCURSAL ps
	WHERE 
			(ps.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ps.Fecha_Act IS NULL) 
			OR (ps.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_ESTABLECIMIENTOS_I ' +
	''''+ pe.Cod_Establecimientos +''','+
	CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Cod_TipoDocumento+''','END+
	CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Nro_Documento+''','END+
	CASE WHEN  pe.Des_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Des_Establecimiento+''','END+
	CASE WHEN  pe.Cod_TipoEstablecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Cod_TipoEstablecimiento+''','END+
	CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Direccion+''','END+
	CASE WHEN  pe.Telefono IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Telefono+''','END+
	CASE WHEN  pe.Obs_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Obs_Establecimiento+''','END+
	CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Cod_Ubigeo+''','END+
	''''+COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 3 as Orden, COALESCE(pe.Fecha_Act,pe.Fecha_Reg) as Fecha
	FROM dbo.PRI_ESTABLECIMIENTOS pe INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pe.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	WHERE 
			(pe.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pe.Fecha_Act IS NULL) 
			OR (pe.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_ALMACEN_I ''' +
	aa.Cod_Almacen+''','+
	CASE WHEN aa.Des_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ aa.Des_Almacen+''','END+
	CASE WHEN aa.Des_CortaAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ aa.Des_CortaAlmacen+''','END+
	CASE WHEN aa.Cod_TipoAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ aa.Cod_TipoAlmacen+''','END+
	CONVERT(VARCHAR(MAX),aa.Flag_Principal)+','+
	''''+ COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+''';' 
	AS ScripExportar, 4 as Orden, COALESCE(aa.Fecha_Act,aa.Fecha_Reg) as Fecha
	FROM dbo.ALM_ALMACEN aa
	WHERE (aa.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND aa.Fecha_Act IS NULL) 
	OR (aa.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)



	UNION

	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJAS_DOC_I ' + 
	''''+ccd.Cod_Caja+''','+
	CONVERT (VARCHAR(MAX),ccd.Item)+ ','+
	CASE WHEN ccd.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ ccd.Cod_TipoComprobante+''','END+
	CASE WHEN ccd.Serie IS NULL THEN 'NULL,' ELSE ''''+ ccd.Serie+''','END+
	CASE WHEN ccd.Impresora IS NULL THEN 'NULL,' ELSE ''''+ ccd.Impresora+''','END+
	CONVERT (VARCHAR(MAX),ccd.Flag_Imprimir)+ ','+
	CONVERT (VARCHAR(MAX),ccd.Flag_FacRapida)+ ','+
	CASE WHEN ccd.Nom_Archivo IS NULL THEN 'NULL,' ELSE ''''+ ccd.Nom_Archivo+''','END+
	CASE WHEN ccd.Nro_SerieTicketera IS NULL THEN 'NULL,' ELSE ''''+ ccd.Nro_SerieTicketera+''','END+
	CASE WHEN ccd.Nom_ArchivoPublicar IS NULL THEN 'NULL,' ELSE ''''+ ccd.Nom_ArchivoPublicar+''','END+
	CASE WHEN ccd.Limite IS NULL THEN 'NULL,' ELSE CONVERT (VARCHAR(MAX),ccd.Limite)+ ','END+
	''''+COALESCE(ccd.Cod_UsuarioAct,ccd.Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 5 as Orden, COALESCE(ccd.Fecha_Act,ccd.Fecha_Reg) as Fecha
	FROM dbo.CAJ_CAJAS_DOC ccd
	WHERE 
	(ccd.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ccd.Fecha_Act IS NULL) 
	OR (ccd.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJA_ALMACEN_I ' + 
	''''+cca.Cod_Caja+''','+
	''''+cca.Cod_Almacen+''','+
	CONVERT (VARCHAR(MAX),cca.Flag_Principal)+ ','+
	''''+COALESCE(cca.Cod_UsuarioAct,cca.Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 6 as Orden, COALESCE(cca.Fecha_Act,cca.Fecha_Reg) as Fecha
	FROM dbo.CAJ_CAJA_ALMACEN cca
	WHERE 
	(cca.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND cca.Fecha_Act IS NULL) 
	OR (cca.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION 

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CATEGORIA_I ' +
	''''+pc.Cod_Categoria+''','+
	CASE WHEN  pc.Des_Categoria IS NULL  THEN 'NULL,'    ELSE ''''+pc.Des_Categoria+''','END+
	'NULL,'+
	CASE WHEN  pc.Cod_CategoriaPadre IS NULL  THEN 'NULL,'    ELSE ''''+pc.Cod_CategoriaPadre+''','END+
	''''+COALESCE(pc.Cod_UsuarioAct,pc.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 7 as Orden, COALESCE(pc.Fecha_Act,pc.Fecha_Reg) as Fecha
	FROM dbo.PRI_CATEGORIA pc 
	WHERE 
			(pc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pc.Fecha_Act IS NULL) 
			OR (pc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION
	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_INVENTARIO_I ' + 
	CASE WHEN Des_Inventario IS NULL THEN 'NULL,' ELSE ''''+ Des_Inventario+''','END+
 	CASE WHEN Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoInventario+''','END+
	CASE WHEN Obs_Inventario IS NULL THEN 'NULL,' ELSE ''''+ Obs_Inventario+''','END+
	CASE WHEN Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ Cod_Almacen+''','END+
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 8 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM ALM_INVENTARIO
	WHERE 
	(Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
	

	UNION

	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_INVENTARIO_D_I ' + 
	CASE WHEN I.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ I.Cod_TipoInventario+''','END+
	CASE WHEN ID.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ ID.Cod_Almacen+''','END+
	''''+ ID.Item+''','+
	''''+ P.Cod_Producto+''','+
	CASE WHEN ID.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ ID.Cod_UnidadMedida+''','END+
	CASE WHEN ID.Cantidad_Sistema IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Sistema)+','END+
	CASE WHEN ID.Cantidad_Encontrada IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Encontrada)+','END+
	CASE WHEN ID.Obs_InventarioD IS NULL THEN 'NULL'  ELSE ''''+ ID.Obs_InventarioD+''','END+
	''''+COALESCE(ID.Cod_UsuarioAct,ID.Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 9 as Orden, COALESCE(ID.Fecha_Act,ID.Fecha_Reg) as Fecha
	FROM ALM_INVENTARIO_D ID INNER JOIN PRI_PRODUCTOS P ON ID.Id_Producto=P.Id_Producto
	INNER JOIN ALM_INVENTARIO I ON I.Id_Inventario=ID.Id_Inventario
	WHERE 
	(ID.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ID.Fecha_Act IS NULL) 
	OR (ID.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION
	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJAS_I ' +
	''''+cc.Cod_Caja+ ''','+
	CASE WHEN cc.Des_Caja IS NULL THEN 'NULL,' ELSE ''''+cc.Des_Caja+''','END +
	CASE WHEN cc.Cod_Sucursal IS NULL THEN 'NULL,' ELSE ''''+cc.Cod_Sucursal+''','END +
	CASE WHEN cc.Cod_UsuarioCajero IS NULL THEN 'NULL,' ELSE ''''+cc.Cod_UsuarioCajero+''','END +
	CASE WHEN cc.Cod_CuentaContable IS NULL THEN 'NULL,' ELSE ''''+cc.Cod_CuentaContable+''','END +
	CONVERT(varchar(MAX),cc.Flag_Activo)+','+
	''''+COALESCE(cc.Cod_UsuarioAct,cc.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 10 as Orden, COALESCE(cc.Fecha_Act,cc.Fecha_Reg) as Fecha
	FROM dbo.CAJ_CAJAS cc
	WHERE 
	(cc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND cc.Fecha_Act IS NULL) 
	OR (cc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION 

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTOS_I ''' +
   	Cod_Producto+''','+ 
	CASE WHEN Cod_Categoria  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Categoria+''','END+
	CASE WHEN Cod_Marca  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Marca+''','END+
    CASE WHEN Cod_TipoProducto  IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoProducto+''','END+
	CASE WHEN Nom_Producto  IS NULL THEN 'NULL,' ELSE ''''+ Nom_Producto+''','END+
	CASE WHEN Des_CortaProducto  IS NULL THEN 'NULL,' ELSE ''''+ Des_CortaProducto+''','END+
	CASE WHEN Des_LargaProducto  IS NULL THEN 'NULL,' ELSE ''''+ Des_LargaProducto+''','END+
	CASE WHEN Caracteristicas  IS NULL THEN 'NULL,' ELSE ''''+ Caracteristicas+''','END+
	CASE WHEN Porcentaje_Utilidad  IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), Porcentaje_Utilidad)+','END+
	CASE WHEN Cuenta_Contable  IS NULL THEN 'NULL,' ELSE ''''+ Cuenta_Contable+''','END+
	CASE WHEN Contra_Cuenta  IS NULL THEN 'NULL,' ELSE ''''+ Contra_Cuenta+''','END+
	CASE WHEN Cod_Garantia  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Garantia+''','END+
	CASE WHEN Cod_TipoExistencia  IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoExistencia+''','END+
	CASE WHEN Cod_TipoOperatividad  IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoOperatividad+''','END+
	CONVERT(VARCHAR(MAX),Flag_Activo)+','+
	CONVERT(VARCHAR(MAX),Flag_Stock)+','+
	CASE WHEN Cod_Fabricante IS NULL THEN 'NULL,' ELSE ''''+ Cod_Fabricante+''','END+
	CASE WHEN Obs_Producto IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),Obs_Producto)+''','END+
	''''+ COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+''';' 
	AS ScripExportar, 11 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM            PRI_PRODUCTOS
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_STOCK_I ''' +
	P.Cod_Producto+''', '''+ 
	S.Cod_UnidadMedida+''', '''+ 
	S.Cod_Almacen+''','+ 
	CASE WHEN S.Cod_Moneda  IS NULL THEN 'NULL,' ELSE ''''+ S.Cod_Moneda+''','END+
	CASE WHEN S.Precio_Compra  IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Precio_Compra)+','END+
	CASE WHEN S.Precio_Venta IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Precio_Venta)+','END+
	CASE WHEN S.Stock_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Min)+','END+
	CASE WHEN S.Stock_Max IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Max)+','END+
	CASE WHEN S.Stock_Act IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Stock_Act)+','END+
	CASE WHEN S.Cod_UnidadMedidaMin IS NULL THEN 'NULL,' ELSE ''''+ S.Cod_UnidadMedidaMin+''','END+
	CASE WHEN S.Cantidad_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Cantidad_Min)+','END+
    ''''+ COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg)+''';' 
	AS ScripExportar, 12 as Orden, COALESCE(S.Fecha_Act,S.Fecha_Reg) as Fecha
	FROM PRI_PRODUCTO_STOCK AS S INNER JOIN
		 PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
	WHERE (S.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND S.Fecha_Act IS NULL) 
	OR (S.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_PRECIO_I ''' + 
	P.Cod_Producto+''', '''+ 
	PP.Cod_UnidadMedida+''', '''+ 
	PP.Cod_Almacen+''', '''+ 
	PP.Cod_TipoPrecio+''','+ 
 	CASE WHEN PP.Valor IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),PP.Valor)+',' END+ 
	''''+COALESCE(PP.Cod_UsuarioAct,PP.Cod_UsuarioReg)+''';'
	AS ScripExportar, 13 as Orden, COALESCE(PP.Fecha_Act,PP.Fecha_Reg) as Fecha
	FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
							 PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto
	WHERE (PP.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND PP.Fecha_Act IS NULL) 
		OR (PP.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_DETALLE_I ''' + 
	P.Cod_Producto+''','+ 
	CONVERT(VARCHAR(MAX),D.Item_Detalle)+','''+ 
	PD.Cod_Producto +''','+  
	CASE WHEN D.Cod_TipoDetalle IS NULL THEN 'NULL,' ELSE ''''+  D.Cod_TipoDetalle+''','END+
	CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), D.Cantidad)+','END+
	CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ D.Cod_UnidadMedida+''','END+
	''''+COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg)+''';' 
	AS ScripExportar, 14 as Orden, COALESCE(D.Fecha_Act,D.Fecha_Reg) as Fecha
	FROM PRI_PRODUCTO_DETALLE AS D INNER JOIN
		PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto INNER JOIN
		PRI_PRODUCTOS AS PD ON D.Id_ProductoDetalle = PD.Id_Producto
	WHERE (D.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND D.Fecha_Act IS NULL) 
		OR (D.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_TASA_I ''' +
	T.Cod_Tasa+''', '''+ 
	P.Cod_Producto+''','+ 
	CASE WHEN T.Cod_Libro  IS NULL THEN 'NULL,' ELSE ''''+ T.Cod_Libro +''','END+
	CASE WHEN T.Des_Tasa IS NULL THEN 'NULL,' ELSE ''''+ T.Des_Tasa+''','END+
	CASE WHEN T.Por_Tasa IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Por_Tasa)+','END+
	CASE WHEN T.Cod_TipoTasa IS NULL THEN 'NULL,' ELSE ''''+  T.Cod_TipoTasa+''','END+
	CASE WHEN T.Flag_Activo IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Flag_Activo)+','END+
	CASE WHEN T.Obs_Tasa IS NULL THEN 'NULL,' ELSE ''''+  T.Obs_Tasa+''','END+
	''''+COALESCE(T.Cod_UsuarioAct,T.Cod_UsuarioReg)+''';'
	AS ScripExportar, 15 as Orden, COALESCE(T.Fecha_Act,T.Fecha_Reg) as Fecha
	FROM  PRI_PRODUCTO_TASA AS T INNER JOIN
		  PRI_PRODUCTOS AS P ON T.Id_Producto = P.Id_Producto
	WHERE (T.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND T.Fecha_Act IS NULL) 
		OR (T.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT DISTINCT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_PROVEEDOR_I ' + 
	CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoDocumento+''','END+
	CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ Nro_Documento+''','END+
	CASE WHEN Cliente IS NULL THEN 'NULL,' ELSE ''''+ Cliente+''','END+
	CASE WHEN Ap_Paterno IS NULL THEN 'NULL,' ELSE ''''+ Ap_Paterno+''','END+
	CASE WHEN Ap_Materno IS NULL THEN 'NULL,' ELSE ''''+ Ap_Materno+''','END+
	CASE WHEN Nombres IS NULL THEN 'NULL,' ELSE ''''+ Nombres+''','END+
	CASE WHEN Direccion IS NULL THEN 'NULL,' ELSE ''''+ Direccion+''','END+
	CASE WHEN Cod_EstadoCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_EstadoCliente+''','END+
	CASE WHEN Cod_CondicionCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_CondicionCliente+''','END+
	CASE WHEN Cod_TipoCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoCliente+''','END+
	CASE WHEN RUC_Natural IS NULL THEN 'NULL,' ELSE ''''+ RUC_Natural+''','END+
	'NULL,
	NULL, '+ 
	CASE WHEN Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoComprobante+''','END+
	CASE WHEN Cod_Nacionalidad IS NULL THEN 'NULL,' ELSE ''''+ Cod_Nacionalidad+''','END+
	CASE WHEN Fecha_Nacimiento IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Nacimiento)+''','END+
	CASE WHEN Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+ Cod_Sexo+''','END+
	CASE WHEN Email1 IS NULL THEN 'NULL,' ELSE ''''+ Email1+''','END+
	CASE WHEN Email2 IS NULL THEN 'NULL,' ELSE ''''+ Email2+''','END+
	CASE WHEN Telefono1 IS NULL THEN 'NULL,' ELSE ''''+ Telefono1+''','END+
	CASE WHEN Telefono2 IS NULL THEN 'NULL,' ELSE ''''+ Telefono2+''','END+
	CASE WHEN Fax IS NULL THEN 'NULL,' ELSE ''''+ Fax+''','END+
	CASE WHEN PaginaWeb IS NULL THEN 'NULL,' ELSE ''''+ PaginaWeb+''','END+
	CASE WHEN Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+ Cod_Ubigeo+''','END+
	CASE WHEN Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ Cod_FormaPago+''','END+
	CASE WHEN Limite_Credito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Limite_Credito)+','END+
	CASE WHEN Obs_Cliente IS NULL THEN 'NULL,' ELSE ''''+  CONVERT(VARCHAR(MAX),Obs_Cliente)+''','END+
	CASE WHEN Num_DiaCredito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Num_DiaCredito)+','END+
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg) +''';' 
	AS ScripExportar, 16 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM PRI_CLIENTE_PROVEEDOR    
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_TURNO_ATENCION_I ''' + 
	Cod_Turno+''','+ 
	CASE WHEN Des_Turno IS NULL THEN 'NULL,' ELSE ''''+ Des_Turno+''','END+
	CASE WHEN Fecha_Inicio IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Inicio)+''','END+
	CASE WHEN Fecha_Fin IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Fin)+''','END+
	 CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+
	''''+ COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+''';' AS ScripExportar , 17 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM CAJ_TURNO_ATENCION
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)


UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_I ' + 
	CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ Cod_Caja+''','END+
	CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ Cod_Turno+''','END+
	CONVERT(VARCHAR(MAX),Numero) +','+ 
	CASE WHEN Des_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+ Des_ArqueoFisico+''','END+
	CASE WHEN Obs_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+ Obs_ArqueoFisico+''','END+
	''''+CONVERT(VARCHAR(MAX),Fecha) +''','+ 
	CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+ 
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg) +''';' 
	AS ScripExportar , 18 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha 
	FROM CAJ_ARQUEOFISICO
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_D_I ' + 
	CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ AF.Cod_Caja+''','END+
	CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ AF.Cod_Turno+''','END+
	''''+AD.Cod_Billete+''', '+ 
	CASE WHEN AD.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),AD.Cantidad)+',' END +
	+ ''''+COALESCE(AD.Cod_UsuarioAct,AD.Cod_UsuarioReg)+''';' AS ScripExportar, 19 as Orden, COALESCE(AD.Fecha_Act,AD.Fecha_Reg) as Fecha
	FROM            CAJ_ARQUEOFISICO_D AS AD INNER JOIN
							 CAJ_ARQUEOFISICO AS AF ON AD.id_ArqueoFisico = AF.id_ArqueoFisico
	WHERE AD.Cantidad <> 0 AND (AD.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND AD.Fecha_Act IS NULL) 
	OR (AD.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_SALDO_I ' + 
	CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ AF.Cod_Caja+''','END+
	CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ AF.Cod_Turno+''','END+
	''''+ASA.Cod_Moneda+''','+ 
	''''+ASA.Tipo+''','+ 
	CASE WHEN ASA.Monto IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR(MAX),ASA.Monto)+',' END+ 
	+''''+COALESCE(ASA.Cod_UsuarioAct,ASA.Cod_UsuarioReg)+''';' AS ScripExportar, 20 as Orden, COALESCE(ASA.Fecha_Act,ASA.Fecha_Reg) as Fecha 
	FROM            CAJ_ARQUEOFISICO_SALDO AS ASA INNER JOIN
							 CAJ_ARQUEOFISICO AS AF ON ASA.id_ArqueoFisico = AF.id_ArqueoFisico
	WHERE (ASA.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ASA.Fecha_Act IS NULL) 
	OR (ASA.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_LICITACIONES_I ' + 
	CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ CP.Cod_TipoDocumento+''','END+
	CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ CP.Nro_Documento+''','END+ 
	''''+L.Cod_Licitacion+''', '''+ 
	CASE WHEN L.Des_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Des_Licitacion+''','END+
	CASE WHEN L.Cod_TipoLicitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Cod_Licitacion+''','END+
	CASE WHEN L.Nro_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Nro_Licitacion+''','END+
	CASE WHEN L.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Inicio)+''','END+ 
	CASE WHEN L.Fecha_Facturacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Facturacion)+''','END+ 
	CONVERT(VARCHAR(MAX),L.Flag_AlFinal)+','+ 
	CASE WHEN L.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ L.Cod_TipoComprobante+''','END+
	''''+COALESCE(L.Cod_UsuarioAct,L.Cod_UsuarioReg)+''';' 
	AS ScripExportar, 21 as Orden, COALESCE(L.Fecha_Act,L.Fecha_Reg) as Fecha 
	FROM            PRI_LICITACIONES AS L INNER JOIN
							 PRI_CLIENTE_PROVEEDOR AS CP ON L.Id_ClienteProveedor = CP.Id_ClienteProveedor
	WHERE (L.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND L.Fecha_Act IS NULL) 
	OR (L.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_LICITACIONES_D_I ' + 
	CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ CP.Cod_TipoDocumento+''','END+
	CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ CP.Nro_Documento+''','END+
	''''+LD.Cod_Licitacion+''','+ 
	CONVERT(VARCHAR(MAX),LD.Nro_Detalle)+','+ 
	''''+P.Cod_Producto+''','+ 
	CASE WHEN LD.Cantidad IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Cantidad)+','END+ 
	CASE WHEN LD.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ LD.Cod_UnidadMedida+''','END+
	CASE WHEN LD.Descripcion IS NULL THEN 'NULL,' ELSE ''''+ LD.Descripcion+''','END+
	CASE WHEN LD.Precio_Unitario IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Precio_Unitario)+','END+ 
	CASE WHEN LD.Por_Descuento IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Por_Descuento)+','END+ 
	''''+COALESCE(LD.Cod_UsuarioAct,LD.Cod_UsuarioReg)+''';' 
	AS ScripExportar, 22 as Orden, COALESCE(LD.Fecha_Act,LD.Fecha_Reg) as Fecha 
	FROM            PRI_LICITACIONES_D AS LD INNER JOIN
	 PRI_CLIENTE_PROVEEDOR AS CP ON LD.Id_ClienteProveedor = CP.Id_ClienteProveedor INNER JOIN
	 PRI_PRODUCTOS AS P ON LD.Id_Producto = P.Id_Producto
	WHERE (LD.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND LD.Fecha_Act IS NULL) 
	OR (LD.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CONCEPTO_I ' + 
	CONVERT(VARCHAR(MAX),Id_Concepto)+','+  
	''''+Des_Concepto+''','+  
	''''+Cod_ClaseConcepto+''','+  
	CONVERT(VARCHAR(MAX),Flag_Activo)+','+
	CASE WHEN Id_ConceptoPadre IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Id_ConceptoPadre)+','END+ 
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+''';' 
	AS ScripExportar, 23 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM            CAJ_CONCEPTO
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
		OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

UNION
	SELECT  'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJA_MOVIMIENTOS_I ' +
	CASE WHEN CM.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_Caja+''','END+
	CASE WHEN CM.Cod_Turno  IS NULL THEN 'NULL,' ELSE '''' +CM.Cod_Turno+ ''',' END+ 
    CASE WHEN CM.Id_Concepto IS NULL THEN 'NULL,' ELSE	CONVERT(VARCHAR(MAX),CM.Id_Concepto)+',' END+ 
	CASE WHEN CP.Cod_TipoDocumento  IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoDocumento+''','END+
	CASE WHEN CP.Nro_Documento  IS NULL THEN 'NULL,' ELSE ''''+CP.Nro_Documento+''','END+
	CASE WHEN CM.Des_Movimiento  IS NULL THEN 'NULL,' ELSE ''''+CM.Des_Movimiento+''','END+
	CASE WHEN CM.Cod_TipoComprobante  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_TipoComprobante+''','END+
	CASE WHEN CM.Serie  IS NULL THEN 'NULL,' ELSE ''''+CM.Serie+''','END+
	CASE WHEN CM.Numero  IS NULL THEN 'NULL,' ELSE ''''+CM.Numero+''','END+
	CASE WHEN CM.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha)+''',' END+ 
	CASE WHEN CM.Tipo_Cambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Tipo_Cambio)+',' END+ 
	CASE WHEN CM.Ingreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Ingreso)+',' END+ 
	CASE WHEN CM.Cod_MonedaIng  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_MonedaIng+''','END+
	CASE WHEN CM.Egreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Egreso)+',' END+ 
	CASE WHEN CM.Cod_MonedaEgr  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_MonedaEgr+''','END+
	CONVERT(VARCHAR(MAX),CM.Flag_Extornado)+','+
	CASE WHEN CM.Cod_UsuarioAut  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_UsuarioAut+''','END+
	CASE WHEN CM.Fecha_Aut IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha_Aut)+''','END+ 
	CASE WHEN CM.Obs_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Obs_Movimiento)+''','END+ 
	CASE WHEN CM.Id_MovimientoRef IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Id_MovimientoRef)+','END+ 
	''''+COALESCE(CM.Cod_UsuarioAct,CM.Cod_UsuarioReg) + ''';' 
	AS ScripExportar, 24 as Orden, COALESCE(CM.Fecha_Act,CM.Fecha_Reg) as Fecha
		FROM            CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
								 PRI_CLIENTE_PROVEEDOR AS CP ON CM.Id_ClienteProveedor = CP.Id_ClienteProveedor LEFT OUTER JOIN
								 CAJ_CAJA_MOVIMIENTOS AS CMR ON CM.Id_MovimientoRef = CMR.id_Movimiento

	WHERE (CM.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND CM.Fecha_Act IS NULL) 
	OR (CM.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_PAGO_I '+ 
	CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Libro+''',' END +
	CASE WHEN CP.Cod_Periodo IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Periodo+''',' END +
	CASE WHEN CP.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Caja+''',' END +
	CASE WHEN CP.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Turno+''',' END +
	CASE WHEN CP.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoOperacion+''',' END +
	CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoComprobante+''',' END +
	CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+CP.Serie+''',' END +
	CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+CP.Numero+''',' END +	
	CASE WHEN CP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoDoc+''',' END +
    CASE WHEN CP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+CP.Doc_Cliente+''',' END +
	CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+CP.Nom_Cliente+''',' END +
	CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+CP.Direccion_Cliente+''',' END +
	CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision)+''','END+ 
	CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento)+''','END+ 
	CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion)+''','END+ 
	CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+CP.Glosa+''',' END +
	CASE WHEN CP.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.TipoCambio)+','END+
	CONVERT(VARCHAR(MAX),CP.Flag_Anulado)+','+ 
	CONVERT(VARCHAR(MAX),CP.Flag_Despachado)+','+ 
	CASE WHEN CP.Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_FormaPago+''',' END +
	CASE WHEN CP.Descuento_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Descuento_Total)+','END+
	CASE WHEN CP.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Moneda+''',' END +
	CASE WHEN CP.Impuesto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Impuesto)+','END+
	CASE WHEN CP.Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Total)+','END+
	CASE WHEN CP.Obs_Comprobante IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.Obs_Comprobante)+''','END+
	CASE WHEN CP.Id_GuiaRemision IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Id_GuiaRemision)+','END+
	CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.GuiaRemision)+''','END+
	CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.id_ComprobanteRef)+','END+
	CASE WHEN CP.Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Plantilla+''',' END +
	CASE WHEN CP.Nro_Ticketera IS NULL THEN 'NULL,' ELSE ''''+CP.Nro_Ticketera+''',' END +
	CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_UsuarioVendedor+''',' END +
	CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_RegimenPercepcion+''',' END +
	CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
	CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+CP.Placa_Vehiculo+''',' END +
	CASE WHEN CP.Cod_TipoDocReferencia IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoDocReferencia+''',' END +
	CASE WHEN CP.Nro_DocReferencia IS NULL THEN 'NULL,' ELSE ''''+CP.Nro_DocReferencia+''',' END +
	CASE WHEN CP.Valor_Resumen IS NULL THEN 'NULL,' ELSE ''''+CP.Valor_Resumen+''',' END +
	CASE WHEN CP.Valor_Firma IS NULL THEN 'NULL,' ELSE ''''+CP.Valor_Firma+''',' END +
	CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_EstadoComprobante+''',' END +
	CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+CP.MotivoAnulacion+''',' END +
	CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
	CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
	''''+COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg)+ ''';' 
	AS ScripExportar, 25 as Orden, COALESCE(CP.Fecha_Act,CP.Fecha_Reg) as Fecha 	 
	FROM            CAJ_COMPROBANTE_PAGO AS CP LEFT JOIN
							 CAJ_COMPROBANTE_PAGO AS CPR ON CP.id_ComprobantePago = CPR.id_ComprobantePago
	WHERE (CP.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND CP.Fecha_Act IS NULL) 
	OR (CP.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION  
  SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_D_I '+ 
	CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+P.Cod_Libro+''',' END +
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),D.id_Detalle)+','+ 
	''''+PP.Cod_Producto +''','+  
	CASE WHEN D.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+D.Cod_Almacen+''',' END +
	CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Cantidad)+','END+
	CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+D.Cod_UnidadMedida+''',' END +
	CASE WHEN D.Despachado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Despachado)+','END+
	CASE WHEN D.Descripcion IS NULL THEN 'NULL,' ELSE ''''+D.Descripcion+''',' END +
	CASE WHEN D.PrecioUnitario IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.PrecioUnitario)+','END+ 
	CASE WHEN D.Descuento IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Descuento)+','END+
	CASE WHEN D.Sub_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Sub_Total)+','END+ 
	CASE WHEN D.Tipo IS NULL THEN 'NULL,' ELSE ''''+D.Tipo+''',' END +
	CASE WHEN D.Obs_ComprobanteD IS NULL THEN 'NULL,' ELSE ''''+D.Obs_ComprobanteD+''',' END +
	CASE WHEN D.Cod_Manguera IS NULL THEN 'NULL,' ELSE ''''+D.Cod_Manguera+''',' END + 
	CONVERT(VARCHAR(MAX),D.Flag_AplicaImpuesto)+','+ 
	CASE WHEN D.Formalizado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Formalizado)+','END+ 
	CASE WHEN D.Valor_NoOneroso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Valor_NoOneroso)+','END+ 
	CASE WHEN D.Cod_TipoISC IS NULL THEN 'NULL,' ELSE ''''+D.Cod_TipoISC+''',' END +
	CASE WHEN D.Porcentaje_ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_ISC)+','END+ 
	CASE WHEN D.ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.ISC)+','END+ 
	CASE WHEN D.Cod_TipoIGV IS NULL THEN 'NULL,' ELSE ''''+D.Cod_TipoIGV+''',' END +
	CASE WHEN D.Porcentaje_IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_IGV)+','END+ 
	CASE WHEN D.IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.IGV)+','END+ 
	''''+COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg)+''';' 
	AS ScripExportar, 26 as Orden, COALESCE(D.Fecha_Act,D.Fecha_Reg) as Fecha
	FROM CAJ_COMPROBANTE_D AS D INNER JOIN
		 CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
		 PRI_PRODUCTOS AS PP ON D.Id_Producto = PP.Id_Producto
	WHERE (D.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND D.Fecha_Act IS NULL) 
	OR (D.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_SERIES_PAGO_I '+
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),S.Item)+','+ 
	''''+S.Serie+''','+
	CASE WHEN S.Fecha_Vencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),S.Fecha_Vencimiento)+''','END+ 
	CASE WHEN S.Obs_Serie IS NULL THEN 'NULL,' ELSE ''''+S.Obs_Serie+''',' END +
	''''+COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg)+ ''';' AS ScripExportar, 27 as Orden, COALESCE(S.Fecha_Act,S.Fecha_Reg) as Fecha
	FROM CAJ_SERIES AS S INNER JOIN
			 CAJ_COMPROBANTE_PAGO AS P ON S.Id_Tabla = P.id_ComprobantePago
	WHERE S.Cod_Tabla='CAJ_COMPROBANTE_PAGO'
	AND ((S.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND S.Fecha_Act IS NULL) 
	OR (S.Fecha_Act BETWEEN @FechaInicio AND @FechaFin))
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_SERIES_MOVIMIENTO_I '+
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CONVERT(VARCHAR(MAX),S.Item)+','+ 
	''''+S.Serie+''','+
	CASE WHEN S.Fecha_Vencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),S.Fecha_Vencimiento)+''','END+ 
	CASE WHEN S.Obs_Serie IS NULL THEN 'NULL,' ELSE ''''+S.Obs_Serie+''',' END +
	''''+COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg)+ ''';' AS ScripExportar, 28 as Orden, COALESCE(S.Fecha_Act,S.Fecha_Reg) as Fecha
	FROM CAJ_SERIES AS S INNER JOIN
		 CAJ_CAJA_MOVIMIENTOS AS P ON S.Id_Tabla = P.id_Movimiento
	WHERE S.Cod_Tabla='ALM_ALMACEN_MOV'
	AND ((S.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND S.Fecha_Act IS NULL) 
	OR (S.Fecha_Act BETWEEN @FechaInicio AND @FechaFin))
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_RELACION_I '+ 
	CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+P.Cod_Libro+''',' END +
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),R.id_Detalle)+','+ 
	CONVERT(VARCHAR(MAX),R.Item) +','+ 
	CASE WHEN PP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+PP.Cod_Libro+''',' END +
	CASE WHEN PP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+PP.Cod_TipoComprobante+''',' END +
	CASE WHEN PP.Serie IS NULL THEN 'NULL,' ELSE ''''+PP.Serie+''',' END +
	CASE WHEN PP.Numero IS NULL THEN 'NULL,' ELSE ''''+PP.Numero+''',' END +	
	CASE WHEN PP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+PP.Cod_TipoDoc+''',' END +
    CASE WHEN PP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+PP.Doc_Cliente+''',' END +
	CASE WHEN R.Cod_TipoRelacion IS NULL THEN 'NULL,' ELSE ''''+R.Cod_TipoRelacion+''',' END +	
	CASE WHEN R.Valor IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),R.VALOR)+','END+ 
	CASE WHEN R.Obs_Relacion IS NULL THEN 'NULL,' ELSE ''''+R.Obs_Relacion+''',' END +	
	CASE WHEN R.Id_DetalleRelacion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),R.Id_DetalleRelacion)+','END+ 
	''''+COALESCE(R.Cod_UsuarioAct,R.Cod_UsuarioReg)+ ''';' AS ScripExportar, 29 as Orden, COALESCE(R.Fecha_Act,R.Fecha_Reg) as Fecha
	FROM  CAJ_COMPROBANTE_RELACION AS R INNER JOIN
		 CAJ_COMPROBANTE_PAGO AS P ON R.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
		 CAJ_COMPROBANTE_PAGO AS PP ON R.Id_ComprobanteRelacion = PP.id_ComprobantePago
	WHERE (R.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND R.Fecha_Act IS NULL) 
	OR (R.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_LICITACIONES_M_I '+ 
	CASE WHEN C.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ C.Cod_TipoDocumento +''',' END +
	CASE WHEN C.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ C.Nro_Documento +''',' END +
	CASE WHEN M.Cod_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_Licitacion +''',' END +
	CASE WHEN M.Nro_Detalle IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),M.Nro_Detalle)+','END+ 
	CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+P.Cod_Libro+''',' END +
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),M.Flag_Cancelado)	+','+ 
	CASE WHEN M.Obs_LicitacionesM IS NULL THEN 'NULL,' ELSE ''''+M.Obs_LicitacionesM+''',' END +	
	''''+COALESCE(M.Cod_UsuarioAct,M.Cod_UsuarioReg)+ ''';' AS ScripExportar, 30 as Orden, COALESCE(M.Fecha_Act,M.Fecha_Reg) as Fecha
	FROM  PRI_LICITACIONES_M AS M INNER JOIN
		PRI_CLIENTE_PROVEEDOR AS C ON M.Id_ClienteProveedor = C.Id_ClienteProveedor INNER JOIN
		CAJ_COMPROBANTE_PAGO AS P ON M.id_ComprobantePago = P.id_ComprobantePago
	WHERE (M.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND M.Fecha_Act IS NULL) 
	OR (M.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_VEHICULOS_I '+
	CASE WHEN P.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ P.Cod_TipoDocumento +''',' END +
	CASE WHEN P.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ P.Nro_Documento +''',' END +
	''''+V.Cod_Placa+''', '''+
	CASE WHEN V.Color IS NULL THEN 'NULL,' ELSE ''''+ V.Color +''',' END +
	CASE WHEN V.Marca IS NULL THEN 'NULL,' ELSE ''''+ V.Marca +''',' END +
	CASE WHEN V.Modelo IS NULL THEN 'NULL,' ELSE ''''+ V.Modelo +''',' END +
	CASE WHEN V.Propiestarios IS NULL THEN 'NULL,' ELSE ''''+ V.Propiestarios +''',' END +
	CASE WHEN V.Sede IS NULL THEN 'NULL,' ELSE ''''+ V.Sede +''',' END +
	CASE WHEN V.Placa_Vigente IS NULL THEN 'NULL,' ELSE ''''+ V.Placa_Vigente +''',' END +
	''''+COALESCE(V.Cod_UsuarioAct,V.Cod_UsuarioReg)+ ''';' AS ScripExportar, 31 as Orden, COALESCE(V.Fecha_Act,V.Fecha_Reg) as Fecha
	FROM PRI_CLIENTE_VEHICULOS AS V INNER JOIN
		 PRI_CLIENTE_PROVEEDOR AS P ON V.Id_ClienteProveedor = P.Id_ClienteProveedor
	WHERE (V.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND V.Fecha_Act IS NULL) 
		OR (V.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION 
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_BAN_CUENTA_BANCARIA_I '+
	''''+Cod_CuentaBancaria+ ''','+
	CASE WHEN Cod_Sucursal IS NULL THEN 'NULL,' ELSE ''''+Cod_Sucursal+''','  END+ 
	CASE WHEN Cod_EntidadFinanciera IS NULL THEN 'NULL,' ELSE ''''+Cod_EntidadFinanciera+''','  END+ 
	CASE WHEN Des_CuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+Des_CuentaBancaria+''','  END+ 
	CASE WHEN Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+Cod_Moneda+''','  END+ 
	CONVERT(VARCHAR(MAX),Flag_Activo)+','+ 
	CASE WHEN Saldo_Disponible IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Saldo_Disponible)+','END+ 
	CASE WHEN Cod_CuentaContable IS NULL THEN 'NULL,' ELSE ''''+Cod_CuentaContable+''','  END+ 
	CASE WHEN Cod_TipoCuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+Cod_TipoCuentaBancaria+''','  END+ 
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+ ''';'
	AS ScripExportar, 32 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM            BAN_CUENTA_BANCARIA
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
			OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_BAN_CUENTA_M_I '+ 
	CASE WHEN Cod_CuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+ Cod_CuentaBancaria +''',' END +
	CASE WHEN Nro_Operacion IS NULL THEN 'NULL,' ELSE ''''+ Nro_Operacion +''',' END +
	CASE WHEN Des_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ Des_Movimiento +''',' END +
	CASE WHEN Cod_TipoOperacionBancaria IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoOperacionBancaria +''',' END +
	CASE WHEN Fecha IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Fecha)+','END+ 
	CASE WHEN Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Monto)+','END+ 
	CASE WHEN TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),TipoCambio)+','END+ 
	CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ Cod_Caja +''',' END +
	CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ Cod_Turno +''',' END +
	CASE WHEN Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+ Cod_Plantilla +''',' END +
	CASE WHEN Nro_Cheque IS NULL THEN 'NULL,' ELSE ''''+ Nro_Cheque +''',' END +
	CASE WHEN Beneficiario IS NULL THEN 'NULL,' ELSE ''''+ Beneficiario +''',' END +
	CASE WHEN Id_ComprobantePago IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Id_ComprobantePago)+','END+ 
	CASE WHEN Obs_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ Obs_Movimiento +''',' END +
    COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+ ''';' AS ScripExportar, 33 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM            BAN_CUENTA_M
	WHERE (Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
			OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_ALMACEN_MOV_I '+ 
	CASE WHEN M.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_Almacen +''',' END +
	CASE WHEN M.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_TipoOperacion +''',' END +
	CASE WHEN M.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_Turno +''',' END +
	CASE WHEN M.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_TipoComprobante +''',' END +
	CASE WHEN M.Serie IS NULL THEN 'NULL,' ELSE ''''+ M.Serie +''',' END +
	CASE WHEN M.Numero IS NULL THEN 'NULL,' ELSE ''''+ M.Numero +''',' END +
	CASE WHEN M.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),M.Fecha)+''','END+ 
	CASE WHEN M.Motivo IS NULL THEN 'NULL,' ELSE ''''+ M.Motivo +''',' END +
	CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+P.Cod_Libro+''',' END +
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),M.Flag_Anulado)+','+
	CASE WHEN M.Obs_AlmacenMov IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),M.Obs_AlmacenMov)+''','END+ 
	''''+COALESCE(M.Cod_UsuarioAct,M.Cod_UsuarioReg)+ ''';' AS ScripExportar, 34 as Orden, COALESCE(M.Fecha_Act,M.Fecha_Reg) as Fecha
	FROM            ALM_ALMACEN_MOV AS M LEFT JOIN
								CAJ_COMPROBANTE_PAGO AS P ON M.Id_ComprobantePago = P.id_ComprobantePago
	WHERE (M.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND M.Fecha_Act IS NULL) 
			OR (M.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_ALMACEN_MOV_D_I '+ 
	CASE WHEN M.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ M.Cod_TipoComprobante +''',' END +
	CASE WHEN M.Serie IS NULL THEN 'NULL,' ELSE ''''+ M.Serie +''',' END +
	CASE WHEN M.Numero IS NULL THEN 'NULL,' ELSE ''''+ M.Numero +''',' END +
	CONVERT(VARCHAR(MAX),D.Item)+','+ 
	''''+P.Cod_Producto+''','+ 
	CASE WHEN D.Des_Producto IS NULL THEN 'NULL,' ELSE ''''+ D.Des_Producto +''',' END +
	CASE WHEN D.Precio_Unitario IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Precio_Unitario)+','END+ 
	CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Cantidad)+','END+ 
	CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ D.Cod_UnidadMedida +''',' END +
	CASE WHEN D.Obs_AlmacenMovD IS NULL THEN 'NULL,' ELSE ''''+ D.Obs_AlmacenMovD +''',' END +
	''''+COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg)+ ''';' AS ScripExportar, 35 as Orden, COALESCE(D.Fecha_Act,D.Fecha_Reg) as Fecha
	FROM  ALM_ALMACEN_MOV_D AS D INNER JOIN
		ALM_ALMACEN_MOV AS M ON D.Id_AlmacenMov = M.Id_AlmacenMov INNER JOIN
		PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto
	WHERE (D.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND D.Fecha_Act IS NULL) 
				OR (D.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_PRODUCTO_I '+
	CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ CP.Cod_TipoDocumento+''','END+
	CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ CP.Nro_Documento+''','END+ 
	''''+P.Cod_Producto	+''','+ 
	CASE WHEN C.Cod_TipoDescuento IS NULL THEN 'NULL,' ELSE ''''+ C.Cod_TipoDescuento+''','END+ 
	CASE WHEN C.Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),C.Monto)+','END+ 
	CASE WHEN C.Obs_ClienteProducto IS NULL THEN 'NULL,' ELSE ''''+ C.Obs_ClienteProducto+''','END+ 
	''''+COALESCE(C.Cod_UsuarioAct,C.Cod_UsuarioReg)+ ''';' AS ScripExportar, 36 as Orden, COALESCE(C.Fecha_Act,C.Fecha_Reg) as Fecha
	FROM            PRI_CLIENTE_PRODUCTO AS C INNER JOIN
							 PRI_PRODUCTOS AS P ON C.Id_Producto = P.Id_Producto INNER JOIN
							 PRI_CLIENTE_PROVEEDOR AS CP ON C.Id_ClienteProveedor = CP.Id_ClienteProveedor
	WHERE (C.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND C.Fecha_Act IS NULL) 
					OR (C.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
UNION
	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_FORMA_PAGO_I '+ 
	CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+P.Cod_Libro+''',' END +
	CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoComprobante+''',' END +
	CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+P.Serie+''',' END +
	CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+P.Numero+''',' END +	
	CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+P.Cod_TipoDoc+''',' END +
    CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+P.Doc_Cliente+''',' END +
	CONVERT(VARCHAR(MAX),F.Item)+','+ 
	CASE WHEN F.Des_FormaPago IS NULL THEN 'NULL,' ELSE  ''''+F.Des_FormaPago+''','END+ 
	CASE WHEN F.Cod_TipoFormaPago IS NULL THEN 'NULL,' ELSE  ''''+F.Cod_TipoFormaPago+''','END+ 
	CASE WHEN F.Cuenta_CajaBanco IS NULL THEN 'NULL,' ELSE ''''+F.Cuenta_CajaBanco+''',' END +	
	CASE WHEN F.Id_Movimiento IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.Id_Movimiento)+','END+ 
	CASE WHEN F.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.TipoCambio)+','END+ 
	CASE WHEN F.Cod_Moneda IS NULL THEN 'NULL,' ELSE  ''''+F.Cod_Moneda+''','END+ 
	CASE WHEN F.Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.Monto)+','END+ 
	CASE WHEN F.Cod_Caja IS NULL THEN 'NULL,' ELSE  ''''+F.Cod_Caja +''','END+ 
	CASE WHEN F.Cod_Turno IS NULL THEN 'NULL,' ELSE  ''''+F.Cod_Turno +''','END+ 
	CASE WHEN F.Cod_Plantilla IS NULL THEN 'NULL,' ELSE  ''''+F.Cod_Plantilla +''','END+ 
	CASE WHEN F.Obs_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),F.Obs_FormaPago)+''','END+ 
	CASE WHEN F.Fecha IS NULL THEN 'NULL,' ELSE '''' +CONVERT(VARCHAR(MAX),F.Fecha)+''','END+ 
	''''+COALESCE(F.Cod_UsuarioAct,F.Cod_UsuarioReg)+ ''';' 
	AS ScripExportar, 37 as Orden, COALESCE(F.Fecha_Act,F.Fecha_Reg) as Fecha
	FROM  CAJ_FORMA_PAGO AS F INNER JOIN
	   CAJ_COMPROBANTE_PAGO AS P ON F.id_ComprobantePago = P.id_ComprobantePago
	WHERE (F.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND F.Fecha_Act IS NULL) 
						OR (F.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)
  
  	UNION
	SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_MEDICION_VC_I ' + 
	CASE WHEN Cod_AMedir IS NULL THEN 'NULL,' ELSE ''''+ Cod_AMedir+''','END+
 	CASE WHEN Medio_AMedir IS NULL THEN 'NULL,' ELSE ''''+ Medio_AMedir+''','END+
	CASE WHEN Medida_Anterior IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Medida_Anterior)+','END+
	CASE WHEN Medida_Actual IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Medida_Actual)+','END+
	CASE WHEN Fecha_Medicion IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Medicion)+''','END+
	CASE WHEN Cod_Turno  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Turno+''','END+
	CASE WHEN Cod_UsuarioMedicion  IS NULL THEN 'NULL,' ELSE ''''+ Cod_UsuarioMedicion+''','END+
	''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 38 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
	FROM CAJ_MEDICION_VC
	WHERE Medida_Anterior <> 0 AND
	(Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND Fecha_Act IS NULL) 
	OR (Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION
	

	

	-- SELECT   'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_GUIA_I ' +
	-- CONVERT (VARCHAR(MAX),ccp.id_ComprobantePago)+ ','+
	-- CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+ ccp.Serie+''','END+ 
	-- CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+ ccp.Numero+''','END+ 
	-- CONVERT (VARCHAR(MAX),ccp2.id_ComprobantePago)+ ','+
	-- CASE WHEN ccp2.Serie IS NULL THEN 'NULL,' ELSE ''''+ ccp2.Serie+''','END+ 
	-- CASE WHEN ccp2.Numero IS NULL THEN 'NULL,' ELSE ''''+ ccp2.Numero+''','END+ 
	-- CONVERT (VARCHAR(MAX),ccg.Flag_Relacion)+ ','+
	-- ''''+COALESCE(ccg.Cod_UsuarioAct,ccg.Cod_UsuarioReg)   +''';' 
	-- AS ScripExportar, 39 as Orden, COALESCE(ccg.Fecha_Act,ccg.Fecha_Reg) as Fecha
	-- FROM dbo.CAJ_COMPROBANTE_GUIA ccg INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.Id_GuiaRemision =ccg.id_ComprobantePago
	-- INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccg.id_ComprobantePago=ccp2.id_ComprobantePago
	-- WHERE 
	-- (ccg.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ccg.Fecha_Act IS NULL) 
	-- OR (ccg.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	-- UNION


	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_LOG_I ' +
	CASE WHEN ccp.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ccp.Cod_TipoComprobante+''','END +
	CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+ccp.Serie+''','END +
	CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+ccp.Numero+''','END +
	CONVERT(varchar(max),ccl.Item)+','+
	CASE WHEN ccl.Cod_Estado IS NULL THEN 'NULL,' ELSE ''''+ccl.Cod_Estado+''','END +
	CASE WHEN ccl.Cod_Mensaje IS NULL THEN 'NULL,' ELSE ''''+ccl.Cod_Mensaje+''','END +
	CASE WHEN ccl.Mensaje IS NULL THEN 'NULL,' ELSE ''''+ccl.Mensaje+''','END +
	''''+COALESCE(ccl.Cod_UsuarioAct,ccl.Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 39 as Orden, COALESCE(ccl.Fecha_Act,ccl.Fecha_Reg) as Fecha
	FROM dbo.CAJ_COMPROBANTE_LOG ccl INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp 
	ON ccl.id_ComprobantePago = ccp.id_ComprobantePago
	WHERE 
		(ccl.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ccl.Fecha_Act IS NULL) 
		OR (ccl.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION 

	-- SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_IMPUESTOS_I ' +
	-- CASE WHEN ccp.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ccp.Cod_TipoComprobante+''','END +
	-- CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+ccp.Serie+''','END +
	-- CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+ccp.Numero+''','END +
	-- ''''+ci.Cod_Impuesto +''','+
	-- CONVERT(varchar(max),ci.Porcentaje)+','+
	-- CASE WHEN ci.Monto IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max),ci.Monto)+','END+
	-- CASE WHEN ci.Obs_Impuesto IS NULL THEN 'NULL,' ELSE ''''+ci.Obs_Impuesto+''','END +
	-- ''''+COALESCE(ci.Cod_UsuarioAct,ci.Cod_UsuarioReg)   +''';' 
	-- AS ScripExportar, 40 as Orden, COALESCE(ci.Fecha_Act,ci.Fecha_Reg) as Fecha
	-- FROM dbo.CAJ_IMPUESTOS ci  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp 
	-- ON ci.id_ComprobantePago = ccp.id_ComprobantePago
	-- WHERE 
	-- 	(ci.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ci.Fecha_Act IS NULL) 
	-- 	OR (ci.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	-- UNION 

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_TIPOCAMBIO_I ' +
	CASE WHEN ct.FechaHora IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max),ct.FechaHora)+''','END +
	CASE WHEN ct.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+ct.Cod_Moneda+''','END +
	CASE WHEN ct.SunatCompra IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.SunatCompra)+','END +
	CASE WHEN ct.SunatVenta IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.SunatVenta)+','END +
	CASE WHEN ct.Compra IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.Compra)+','END +
	CASE WHEN ct.Venta IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.Venta)+','END +
	''''+COALESCE(ct.Cod_UsuarioAct,ct.Cod_UsuarioReg)   +''';' 
	AS ScripExportar, 41 as Orden, COALESCE(ct.Fecha_Act,ct.Fecha_Reg) as Fecha
	FROM dbo.CAJ_TIPOCAMBIO ct
	WHERE 
		(ct.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ct.Fecha_Act IS NULL) 
		OR (ct.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_TIPOCAMBIO_I ' +
	''''+pae.Cod_ActividadEconomica+''','+
	CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+pcp.Cod_TipoDocumento+''','END+
	CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+pcp.Nro_Documento+''','END+
	CASE WHEN  pae.CIIU IS NULL  THEN 'NULL,'    ELSE ''''+pae.CIIU+''','END+
	CASE WHEN  pae.Escala IS NULL  THEN 'NULL,'    ELSE ''''+pae.Escala+''','END+
	CASE WHEN  pae.Des_ActividadEconomica IS NULL  THEN 'NULL,'    ELSE ''''+pae.Des_ActividadEconomica+''','END+
	CONVERT(varchar(max), pae.Flag_Activo)+','+
	''''+COALESCE(pae.Cod_UsuarioAct,pae.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 42 as Orden, COALESCE(pae.Fecha_Act,pae.Fecha_Reg) as Fecha
	FROM dbo.PRI_ACTIVIDADES_ECONOMICAS pae INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pae.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	WHERE 
			(pae.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pae.Fecha_Act IS NULL) 
			OR (pae.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION 

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_AREAS_I ' +
	''''+pa.Cod_Area+''','+
	CASE WHEN  pa.Cod_Sucursal IS NULL  THEN 'NULL,'    ELSE ''''+pa.Cod_Sucursal+''','END+
	CASE WHEN  pa.Des_Area IS NULL  THEN 'NULL,'    ELSE ''''+pa.Des_Area+''','END+
	CASE WHEN  pa.Numero IS NULL  THEN 'NULL,'    ELSE ''''+pa.Numero+''','END+
	CASE WHEN  pa.Cod_AreaPadre IS NULL  THEN 'NULL,'    ELSE ''''+pa.Cod_AreaPadre+''','END+
	''''+COALESCE(pa.Cod_UsuarioAct,pa.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 43 as Orden, COALESCE(pa.Fecha_Act,pa.Fecha_Reg) as Fecha
	FROM dbo.PRI_AREAS pa 
	WHERE 
			(pa.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pa.Fecha_Act IS NULL) 
			OR (pa.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION



	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_CUENTABANCARIA_I ' +
	CASE WHEN  pccp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ pccp.Cod_TipoDocumento+''','END+
	CASE WHEN  pccp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ pccp.Nro_Documento+''','END+
	CASE WHEN  pccc.NroCuenta_Bancaria IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.NroCuenta_Bancaria+''','END+
	CASE WHEN  pccc.Cod_EntidadFinanciera IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.Cod_EntidadFinanciera+''','END+
	CASE WHEN  pccc.Cod_TipoCuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.Cod_TipoCuentaBancaria+''','END+
	CASE WHEN  pccc.Des_CuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.Des_CuentaBancaria+''','END+
	CONVERT(varchar(max),pccc.Flag_Principal)+','+
	CASE WHEN  pccc.Cuenta_Interbancaria IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.Cuenta_Interbancaria+''','END+
	CASE WHEN  pccc.Obs_CuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ pccc.Obs_CuentaBancaria+''','END+
	''''+COALESCE(pccc.Cod_UsuarioAct,pccc.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 44 as Orden, COALESCE(pccc.Fecha_Act,pccc.Fecha_Reg) as Fecha
	FROM dbo.PRI_CLIENTE_CUENTABANCARIA pccc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pccp 
	ON pccc.Id_ClienteProveedor = pccp.Id_ClienteProveedor
	WHERE 
			(pccc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pccc.Fecha_Act IS NULL) 
			OR (pccc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_VISITAS_I ' +
	''''+pcv.Cod_ClienteVisita +''','+
	CASE WHEN  pcv.Cod_UsuarioVendedor IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Cod_UsuarioVendedor+''','END+
	CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Cod_TipoDocumento+''','END+
	CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Nro_Documento+''','END+
	CASE WHEN  pcv.Ruta IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Ruta+''','END+
	CASE WHEN  pcv.Cod_TipoVisita IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Cod_TipoVisita+''','END+
	CASE WHEN  pcv.Cod_Resultado IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Cod_Resultado+''','END+
	CASE WHEN  pcv.Fecha_HoraVisita IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraVisita)+''','END+
	CASE WHEN  pcv.Comentarios IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Comentarios+''','END+
	CONVERT(varchar(max),pcv.Flag_Compromiso)+','+
	CASE WHEN  pcv.Fecha_HoraCompromiso IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraCompromiso)+''','END+
	CASE WHEN  pcv.Cod_UsuarioResponsable IS NULL  THEN 'NULL,'    ELSE ''''+  pcv.Cod_UsuarioResponsable+''','END+
	CASE WHEN  pcv.Des_Compromiso IS NULL  THEN 'NULL,'    ELSE ''''+  pcv.Des_Compromiso+''','END+
	''''+COALESCE(pcv.Cod_UsuarioAct,pcv.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 45 as Orden, COALESCE(pcv.Fecha_Act,pcv.Fecha_Reg) as Fecha
	FROM dbo.PRI_CLIENTE_VISITAS pcv INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pcv.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	WHERE 
			(pcv.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pcv.Fecha_Act IS NULL) 
			OR (pcv.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CUENTA_CONTABLE_I ' +
	''''+pcc.Cod_CuentaContable +''','+
	CASE WHEN  pcc.Des_CuentaContable IS NULL  THEN 'NULL,'    ELSE ''''+ pcc.Des_CuentaContable+''','END+
	CASE WHEN  pcc.Tipo_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ pcc.Tipo_Cuenta+''','END+
	CASE WHEN  pcc.Cod_Moneda IS NULL  THEN 'NULL,'    ELSE ''''+ pcc.Cod_Moneda+''','END+
	CONVERT(varchar(max),pcc.Flag_CuentaAnalitica)+','+
	CONVERT(varchar(max),pcc.Flag_CentroCostos)+','+
	CONVERT(varchar(max),pcc.Flag_CuentaBancaria)+','+
	CASE WHEN  pcc.Numero_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ pcc.Numero_Cuenta+''','END+
	CASE WHEN  pcc.Clase_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ pcc.Clase_Cuenta+''','END+
	''''+COALESCE(pcc.Cod_UsuarioAct,pcc.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 46 as Orden, COALESCE(pcc.Fecha_Act,pcc.Fecha_Reg) as Fecha
	FROM dbo.PRI_CUENTA_CONTABLE pcc
	WHERE 
			(pcc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pcc.Fecha_Act IS NULL) 
			OR (pcc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_DESCUENTOS_I ' +
	CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Cod_TipoDocumento+''','END+
	CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Nro_Documento+''','END+
	CASE WHEN  pd.Cod_TipoDescuento IS NULL  THEN 'NULL,'    ELSE ''''+ pd.Cod_TipoDescuento+''','END+
	CASE WHEN  pd.Aplica IS NULL  THEN 'NULL,'    ELSE ''''+ pd.Aplica+''','END+
	CASE WHEN  pd.Cod_Aplica IS NULL  THEN 'NULL,'    ELSE ''''+ pd.Cod_Aplica+''','END+
	CASE WHEN  pd.Cod_TipoCliente IS NULL  THEN 'NULL,'    ELSE ''''+ pd.Cod_TipoCliente+''','END+
	CASE WHEN  pd.Cod_TipoPrecio IS NULL  THEN 'NULL,'    ELSE ''''+ pd.Cod_TipoPrecio+''','END+
	CASE WHEN  pd.Monto_Precio IS NULL  THEN 'NULL,'    ELSE  CONVERT(varchar(max),pd.Monto_Precio)+','END+
	CASE WHEN  pd.Fecha_Inicia IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Inicia)+''','END+
	CASE WHEN  pd.Fecha_Fin IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Fin)+''','END+
	CASE WHEN  pd.Obs_Descuento IS NULL  THEN 'NULL,'    ELSE '''' +pd.Obs_Descuento+''','END+
	''''+COALESCE(pd.Cod_UsuarioAct,pd.Cod_UsuarioReg)   +''';' 
		AS ScripExportar, 47 as Orden, COALESCE(pd.Fecha_Act,pd.Fecha_Reg) as Fecha
	FROM dbo.PRI_DESCUENTOS pd INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pd.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	WHERE 
			(pd.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pd.Fecha_Act IS NULL) 
			OR (pd.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_MENSAJES_I ' +
	''''+pm.Cod_UsuarioRemite+''','+
	''''+CONVERT(varchar(max), pm.Fecha_Remite)+''',' +
	''''+pm.Mensaje+''','+
	CONVERT(varchar(max),pm.Flag_Leido)+','+
	''''+pm.Cod_UsuarioRecibe+''','+
	''''+CONVERT(varchar(max), pm.Fecha_Recibe)+''',' +
	''''+COALESCE(pm.Cod_UsuarioAct,pm.Cod_UsuarioReg)   +''';' 
		AS Scripmxportar, 48 as Orden, COALESCE(pm.Fecha_Act,pm.Fecha_Reg) as Fecha
	FROM dbo.PRI_MENSAJES pm 
	WHERE 
			(pm.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pm.Fecha_Act IS NULL) 
			OR (pm.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PADRONES_I ' +
	''''+pp.Cod_Padron+''','+
	CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+pcp.Cod_TipoDocumento+''','END+
	CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+pcp.Nro_Documento+''','END+
	CASE WHEN pp.Cod_TipoPadron IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_TipoPadron +''','END+
	CASE WHEN pp.Des_Padron IS NULL THEN 'NULL,' ELSE ''''+pp.Des_Padron +''','END+
	CASE WHEN pp.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pp.Fecha_Inicio) +''','END+
	CASE WHEN pp.Fecha_Fin IS NULL THEN 'NULL,' ELSE ''''+ convert(varchar(max),pp.Fecha_Fin) +''','END+
	CASE WHEN pp.Nro_Resolucion IS NULL THEN 'NULL,' ELSE ''''+pp.Nro_Resolucion +''','END+

	''''+COALESCE(pp.Cod_UsuarioAct,pp.Cod_UsuarioReg)   +''';' 
		AS Scrippxportar, 49 as Orden, COALESCE(pp.Fecha_Act,pp.Fecha_Reg) as Fecha
	FROM dbo.PRI_PADRONES pp INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pp.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	WHERE 
			(pp.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pp.Fecha_Act IS NULL) 
			OR (pp.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION


	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PERSONAL_I ' +
	''''+pp.Cod_Personal+''','+
	CASE WHEN pp.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_TipoDoc +''','END+
	CASE WHEN pp.Num_Doc IS NULL THEN 'NULL,' ELSE ''''+pp.Num_Doc +''','END+
	CASE WHEN pp.ApellidoPaterno IS NULL THEN 'NULL,' ELSE ''''+pp.ApellidoPaterno +''','END+
	CASE WHEN pp.ApellidoMaterno IS NULL THEN 'NULL,' ELSE ''''+pp.ApellidoMaterno +''','END+
	CASE WHEN pp.PrimeroNombre IS NULL THEN 'NULL,' ELSE ''''+pp.PrimeroNombre +''','END+
	CASE WHEN pp.SegundoNombre IS NULL THEN 'NULL,' ELSE ''''+pp.SegundoNombre +''','END+
	CASE WHEN pp.Direccion IS NULL THEN 'NULL,' ELSE ''''+pp.Direccion +''','END+
	CASE WHEN pp.Ref_Direccion IS NULL THEN 'NULL,' ELSE ''''+pp.Ref_Direccion +''','END+
	CASE WHEN pp.Telefono IS NULL THEN 'NULL,' ELSE ''''+pp.Telefono +''','END+
	CASE WHEN pp.Email IS NULL THEN 'NULL,' ELSE ''''+pp.Email +''','END+
	CASE WHEN pp.Fecha_Ingreso IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Ingreso) +''','END+
	CASE WHEN pp.Fecha_Nacimiento IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Nacimiento) +''','END+
	CASE WHEN pp.Cod_Cargo IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Cargo +''','END+
	CASE WHEN pp.Cod_Estado IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Estado +''','END+
	CASE WHEN pp.Cod_Area IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Area +''','END+
	CASE WHEN pp.Cod_Local IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Local +''','END+
	CASE WHEN pp.Cod_CentroCostos IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_CentroCostos +''','END+
	CASE WHEN pp.Cod_EstadoCivil IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_EstadoCivil +''','END+
	CASE WHEN pp.Fecha_InsESSALUD IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_InsESSALUD) +''','END+
	CASE WHEN pp.AutoGeneradoEsSalud IS NULL THEN 'NULL,' ELSE ''''+pp.AutoGeneradoEsSalud +''','END+
	CASE WHEN pp.Cod_CuentaCTS IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_CuentaCTS +''','END+
	CASE WHEN pp.Num_CuentaCTS IS NULL THEN 'NULL,' ELSE ''''+pp.Num_CuentaCTS +''','END+
	CASE WHEN pp.Cod_BancoRemuneracion IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_BancoRemuneracion +''','END+
	CASE WHEN pp.Num_CuentaRemuneracion IS NULL THEN 'NULL,' ELSE ''''+pp.Num_CuentaRemuneracion +''','END+
	CASE WHEN pp.Grupo_Sanguinio IS NULL THEN 'NULL,' ELSE ''''+pp.Grupo_Sanguinio +''','END+
	CASE WHEN pp.Cod_AFP IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_AFP +''','END+
	CASE WHEN pp.AutoGeneradoAFP IS NULL THEN 'NULL,' ELSE ''''+pp.AutoGeneradoAFP +''','END+
	convert (varchar(max),pp.Flag_CertificadoSalud)+','+
	convert (varchar(max),pp.Flag_CertificadoAntPoliciales)+','+
	convert (varchar(max),pp.Flag_CertificadorAntJudiciales)+','+
	convert (varchar(max),pp.Flag_DeclaracionBienes)+','+
	convert (varchar(max),pp.Flag_OtrosDocumentos)+','+
	CASE WHEN pp.Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Sexo +''','END+
	CASE WHEN pp.Cod_UsuarioLogin IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_UsuarioLogin +''','END+
	CASE WHEN pp.Obs_Personal IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Obs_Personal) +''','END+
	''''+COALESCE(pp.Cod_UsuarioAct,pp.Cod_UsuarioReg)   +''';' 
		AS Scrippxportar, 50 as Orden, COALESCE(pp.Fecha_Act,pp.Fecha_Reg) as Fecha
	FROM dbo.PRI_PERSONAL pp
	WHERE 
			(pp.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pp.Fecha_Act IS NULL) 
			OR (pp.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	UNION

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PERSONAL_PARENTESCO_I ' +
	''''+ppp.Cod_Personal+''','+
	CONVERT(varchar(max),ppp.Item_Parentesco)+','+
	CASE WHEN ppp.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+ppp.Cod_TipoDoc +''','END+
	CASE WHEN ppp.Num_Doc IS NULL THEN 'NULL,' ELSE ''''+ppp.Num_Doc +''','END+
	CASE WHEN ppp.ApellidoPaterno IS NULL THEN 'NULL,' ELSE ''''+ppp.ApellidoPaterno +''','END+
	CASE WHEN ppp.ApellidoMaterno IS NULL THEN 'NULL,' ELSE ''''+ppp.ApellidoMaterno +''','END+
	CASE WHEN ppp.Nombres IS NULL THEN 'NULL,' ELSE ''''+ppp.Nombres +''','END+
	CASE WHEN ppp.Cod_TipoParentesco IS NULL THEN 'NULL,' ELSE ''''+ppp.Cod_TipoParentesco +''','END+
	CASE WHEN ppp.Obs_Parentesco IS NULL THEN 'NULL,' ELSE ''''+ppp.Obs_Parentesco +''','END+
	''''+COALESCE(ppp.Cod_UsuarioAct,ppp.Cod_UsuarioReg)   +''';' 
		AS Scripppxportar, 51 as Orden, COALESCE(ppp.Fecha_Act,ppp.Fecha_Reg) as Fecha
	FROM dbo.PRI_PERSONAL_PARENTESCO ppp
	WHERE 
			(ppp.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND ppp.Fecha_Act IS NULL) 
			OR (ppp.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)


	UNION

	

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_CONTACTO_I ' +
	CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+pcp.Cod_TipoDocumento +''','END+
	CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+pcp.Nro_Documento +''','END+
	CASE WHEN pcp2.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+pcp2.Cod_TipoDocumento +''','END+
	CASE WHEN pcp2.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+pcp2.Nro_Documento +''','END+
	CASE WHEN pcc.Ap_Paterno IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), pcc.Ap_Paterno) +','END+
	CASE WHEN pcc.Ap_Materno IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), pcc.Ap_Materno) +','END+
	CASE WHEN pcc.Nombres IS NULL THEN 'NULL,' ELSE ''''+pcc.Nombres +''','END+
	CASE WHEN pcc.Cod_Telefono IS NULL THEN 'NULL,' ELSE ''''+pcc.Cod_Telefono +''','END+
	CASE WHEN pcc.Nro_Telefono IS NULL THEN 'NULL,' ELSE ''''+pcc.Nro_Telefono +''','END+
	CASE WHEN pcc.Anexo IS NULL THEN 'NULL,' ELSE ''''+pcc.Anexo +''','END+
	CASE WHEN pcc.Email_Empresarial IS NULL THEN 'NULL,' ELSE ''''+pcc.Email_Empresarial +''','END+
	CASE WHEN pcc.Email_Personal IS NULL THEN 'NULL,' ELSE ''''+pcc.Email_Personal +''','END+
	CASE WHEN pcc.Celular IS NULL THEN 'NULL,' ELSE ''''+pcc.Celular +''','END+
	CASE WHEN pcc.Cod_TipoRelacion IS NULL THEN 'NULL,' ELSE ''''+pcc.Cod_TipoRelacion +''','END+
	CASE WHEN pcc.Fecha_Incorporacion IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pcc.Fecha_Incorporacion) +''','END+
	''''+COALESCE(pcc.Cod_UsuarioAct,pcc.Cod_UsuarioReg)   +''';' 
		AS Scripccxportar, 52 as Orden, COALESCE(pcc.Fecha_Act,pcc.Fecha_Reg) as Fecha
	FROM dbo.PRI_CLIENTE_CONTACTO pcc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pcc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp2 ON pcc.Id_ClienteContacto=pcp2.Id_ClienteProveedor
	WHERE 
			(pcc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pcc.Fecha_Act IS NULL) 
			OR (pcc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

  ) as Exportar ORDER BY Exportar.Orden,Exportar.Fecha

	DECLARE @Linea varchar(max)
	DECLARE  RecorrerScript CURSOR FOR SELECT e.ScripExportar FROM #exportar e
	OPEN RecorrerScript
	FETCH NEXT FROM RecorrerScript 
	INTO @Linea
	WHILE @@FETCH_STATUS = 0
	BEGIN   
		print @Linea
		EXECUTE(@Linea)

	FETCH NEXT FROM RecorrerScript 
	INTO @Linea
	END 
	CLOSE RecorrerScript;
	DEALLOCATE RecorrerScript	
	
	UPDATE PRI_EMPRESA SET Fecha_Act = @FechaFin;

	DROP TABLE #exportar;
END TRY  
BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
		UPDATE PRI_EMPRESA SET Fecha_Act = @FechaInicio;
END CATCH;  
END
go 


--EXEC USP_ExportarDatos 


