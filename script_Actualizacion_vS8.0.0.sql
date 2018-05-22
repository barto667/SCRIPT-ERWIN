-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_G
go	
CREATE PROCEDURE USP_PRI_EMPRESA_G 
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

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_E' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_E
go
CREATE PROCEDURE USP_PRI_EMPRESA_E 
	@Cod_Empresa	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DELETE FROM PRI_EMPRESA	
	WHERE (Cod_Empresa = @Cod_Empresa)	
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_TT
go
CREATE PROCEDURE USP_PRI_EMPRESA_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Empresa , RUC , Nom_Comercial , RazonSocial , Direccion , Telefonos , Web , Imagen_H , Imagen_V , Flag_ExoneradoImpuesto , Des_Impuesto , Por_Impuesto , EstructuraContable , Version , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_EMPRESA
END
go

-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_TP
go
CREATE PROCEDURE USP_PRI_EMPRESA_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Empresa , RUC , Nom_Comercial , RazonSocial , Direccion , Telefonos , Web , Imagen_H , Imagen_V , Flag_ExoneradoImpuesto , Des_Impuesto , Por_Impuesto , EstructuraContable , Version , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Empresa , RUC , Nom_Comercial , RazonSocial , Direccion , Telefonos , Web , Imagen_H , Imagen_V , Flag_ExoneradoImpuesto , Des_Impuesto , Por_Impuesto , EstructuraContable , Version , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_EMPRESA '+@ScripWhere+') aPRI_EMPRESA
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_TXPK
go
CREATE PROCEDURE USP_PRI_EMPRESA_TXPK 
	@Cod_Empresa	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Empresa, RUC, Nom_Comercial, RazonSocial, Direccion, Telefonos, Web, Imagen_H, Imagen_V, Flag_ExoneradoImpuesto, Des_Impuesto, Por_Impuesto, EstructuraContable, Version, Cod_Ubigeo, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_EMPRESA
	WHERE (Cod_Empresa = @Cod_Empresa)	
END
go

-- Traer Auditoria
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_Auditoria' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_Auditoria
go
CREATE PROCEDURE USP_PRI_EMPRESA_Auditoria 
	@Cod_Empresa	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_EMPRESA
	WHERE (Cod_Empresa = @Cod_Empresa)	
END
go

-- Traer Número de Filas
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_TNF' AND type = 'P')
	DROP PROCEDURE USP_PRI_EMPRESA_TNF
go
CREATE PROCEDURE USP_PRI_EMPRESA_TNF
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION	
AS
BEGIN
	EXECUTE('SELECT COUNT(*) AS NroFilas  FROM PRI_EMPRESA ' + @ScripWhere)	
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_G
go
CREATE PROCEDURE USP_PRI_SUCURSAL_G 
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

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_E' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_E
go
CREATE PROCEDURE USP_PRI_SUCURSAL_E 
	@Cod_Sucursal	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DELETE FROM PRI_SUCURSAL	
	WHERE (Cod_Sucursal = @Cod_Sucursal)	
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_TT
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Sucursal , Nom_Sucursal , Dir_Sucursal , Por_UtilidadMax , Por_UtilidadMin , Cod_UsuarioAdm , Cabecera_Pagina , Pie_Pagina , Flag_Activo , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_SUCURSAL
END
go

-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_TP
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Sucursal , Nom_Sucursal , Dir_Sucursal , Por_UtilidadMax , Por_UtilidadMin , Cod_UsuarioAdm , Cabecera_Pagina , Pie_Pagina , Flag_Activo , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Sucursal , Nom_Sucursal , Dir_Sucursal , Por_UtilidadMax , Por_UtilidadMin , Cod_UsuarioAdm , Cabecera_Pagina , Pie_Pagina , Flag_Activo , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_SUCURSAL '+@ScripWhere+') aPRI_SUCURSAL
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_TXPK
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TXPK 
	@Cod_Sucursal	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Sucursal, Nom_Sucursal, Dir_Sucursal, Por_UtilidadMax, Por_UtilidadMin, Cod_UsuarioAdm, Cabecera_Pagina, Pie_Pagina, Flag_Activo, Cod_Ubigeo, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_SUCURSAL
	WHERE (Cod_Sucursal = @Cod_Sucursal)	
END
go

-- Traer Auditoria
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_Auditoria' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_Auditoria
go
CREATE PROCEDURE USP_PRI_SUCURSAL_Auditoria 
	@Cod_Sucursal	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_SUCURSAL
	WHERE (Cod_Sucursal = @Cod_Sucursal)	
END
go

-- Traer Número de Filas
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_TNF' AND type = 'P')
	DROP PROCEDURE USP_PRI_SUCURSAL_TNF
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TNF
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION	
AS
BEGIN
	EXECUTE('SELECT COUNT(*) AS NroFilas  FROM PRI_SUCURSAL ' + @ScripWhere)	
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_G' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_DOC_G
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_G 
	@Cod_Caja  varchar(32), 
	@Item  int, 
	@Cod_TipoComprobante  varchar(5), 
	@Serie  varchar(5), 
	@Impresora  varchar(512), 
	@Flag_Imprimir  bit, 
	@Flag_FacRapida  bit, 
	@Nom_Archivo  varchar(1024), 
	@Nro_SerieTicketera  varchar(64),
	@Nom_ArchivoPublicar	varchar(512), 
	@Limite	int,
	@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Caja, @Item FROM CAJ_CAJAS_DOC WHERE  (Cod_Caja = @Cod_Caja) AND (Item = @Item))
BEGIN
SET @Item = (SELECT ISNULL(MAX(Item)+1,1) FROM CAJ_CAJAS_DOC WHERE Cod_Caja = @Cod_Caja );
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

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TT' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_TT
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Caja , Item , Cod_TipoComprobante , Serie , Impresora , Flag_Imprimir , Flag_FacRapida , Nom_Archivo , Nro_SerieTicketera , Nom_ArchivoPublicar , Limite , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM CAJ_CAJAS_DOC
END
go

-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TP' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_TP
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Caja , Item , Cod_TipoComprobante , Serie , Impresora , Flag_Imprimir , Flag_FacRapida , Nom_Archivo , Nro_SerieTicketera , Nom_ArchivoPublicar , Limite , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Caja , Item , Cod_TipoComprobante , Serie , Impresora , Flag_Imprimir , Flag_FacRapida , Nom_Archivo , Nro_SerieTicketera , Nom_ArchivoPublicar , Limite , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM CAJ_CAJAS_DOC '+@ScripWhere+') aCAJ_CAJAS_DOC
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TXPK' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_TXPK
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TXPK 
	@Cod_Caja	varchar(32), 
	@Item	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Caja, Item, Cod_TipoComprobante, Serie, Impresora, Flag_Imprimir, Flag_FacRapida, Nom_Archivo, Nro_SerieTicketera, Nom_ArchivoPublicar, Limite, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM CAJ_CAJAS_DOC
	WHERE (Cod_Caja = @Cod_Caja) AND (Item = @Item)	
END
go

-- Traer Auditoria
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_Auditoria' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_Auditoria
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_Auditoria 
	@Cod_Caja	varchar(32), 
	@Item	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM CAJ_CAJAS_DOC
	WHERE (Cod_Caja = @Cod_Caja) AND (Item = @Item)	
END
go

-- Traer Número de Filas
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TNF' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJAS_DOC_TNF
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TNF
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION	
AS
BEGIN
	EXECUTE('SELECT COUNT(*) AS NroFilas  FROM CAJ_CAJAS_DOC ' + @ScripWhere)	
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_G
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_G 
	@Cod_Establecimientos	varchar(32), 
	@Id_ClienteProveedor	int, 
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
IF NOT EXISTS (SELECT @Cod_Establecimientos, @Id_ClienteProveedor FROM PRI_ESTABLECIMIENTOS WHERE  (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor))
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

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_E' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_E
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_E 
	@Cod_Establecimientos	varchar(32), 
	@Id_ClienteProveedor	int
WITH ENCRYPTION
AS
BEGIN
	DELETE FROM PRI_ESTABLECIMIENTOS	
	WHERE (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_TT
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Establecimientos , Id_ClienteProveedor , Des_Establecimiento , Cod_TipoEstablecimiento , Direccion , Telefono , Obs_Establecimiento , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_ESTABLECIMIENTOS
END
go

-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_TP
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Establecimientos , Id_ClienteProveedor , Des_Establecimiento , Cod_TipoEstablecimiento , Direccion , Telefono , Obs_Establecimiento , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Establecimientos , Id_ClienteProveedor , Des_Establecimiento , Cod_TipoEstablecimiento , Direccion , Telefono , Obs_Establecimiento , Cod_Ubigeo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_ESTABLECIMIENTOS '+@ScripWhere+') aPRI_ESTABLECIMIENTOS
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_TXPK
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_TXPK 
	@Cod_Establecimientos	varchar(32), 
	@Id_ClienteProveedor	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Establecimientos, Id_ClienteProveedor, Des_Establecimiento, Cod_TipoEstablecimiento, Direccion, Telefono, Obs_Establecimiento, Cod_Ubigeo, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_ESTABLECIMIENTOS
	WHERE (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
END
go

-- Traer Auditoria
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_Auditoria' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_Auditoria
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_Auditoria 
	@Cod_Establecimientos	varchar(32), 
	@Id_ClienteProveedor	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_ESTABLECIMIENTOS
	WHERE (Cod_Establecimientos = @Cod_Establecimientos) AND (Id_ClienteProveedor = @Id_ClienteProveedor)	
END
go

-- Traer Número de Filas
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_TNF' AND type = 'P')
	DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_TNF
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_TNF
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION	
AS
BEGIN
	EXECUTE('SELECT COUNT(*) AS NroFilas  FROM PRI_ESTABLECIMIENTOS ' + @ScripWhere)	
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_G' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G 
@Id_ClienteProveedor int out, 
@Cod_TipoDocumento varchar(3), 
@Nro_Documento varchar(32), 
@Cliente varchar(512), 
@Ap_Paterno varchar(128), 
@Ap_Materno varchar(128), 
@Nombres varchar(128), 
@DireccioN varchar(512), 
@Cod_EstadoCliente varchar(3), 
@Cod_CondicionCliente varchar(3), 
@Cod_TipoCliente varchar(3), 
@RUC_Natural varchar(32), 
@Foto varbinary(MAX), 
@Firma varbinary(MAX), 
@Cod_TipoComprobante varchar(5) out, 
@Cod_Nacionalidad varchar(8), 
@Fecha_Nacimiento datetime, 
@Cod_Sexo varchar(3), 
@Email1 varchar(1024), 
@Email2 varchar(1024), 
@Telefono1 varchar(512), 
@Telefono2 varchar(512), 
@Fax varchar(512), 
@PaginaWeb varchar(512), 
@Cod_Ubigeo varchar(8), 
@Cod_FormaPago varchar(3), 
@Limite_Credito numeric(38,2), 
@Obs_Cliente xml,
@Num_DiaCredito	int,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF CONVERT(NVARCHAR(MAX),ISNULL(@Obs_Cliente,'')) = ''
BEGIN
	SET @Obs_Cliente = dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('PRI_CLIENTE_PROVEEDOR');
END	
	if (@Cod_TipoDocumento = '99')
	BEGIN
		SET @Nro_Documento = (SELECT RIGHT('00000000'+CONVERT( varchar(32),ISNULL( MAX(CONVERT( int,Nro_Documento))+1,1)),8) AS Siguiente
		FROM PRI_CLIENTE_PROVEEDOR
		where Cod_TipoDocumento = 99)
	END
	IF (@Cod_TipoComprobante='')
	BEGIN
		SET @Cod_TipoComprobante = (SELECT TOP 1 [Cod_TipoComprobante] 
			FROM VIS_COMPROBANTE_PREDETERMINADO WHERE @Cod_TipoDocumento = [Cod_TipoDocumento])
	END
	
	IF EXISTS (SELECT Id_ClienteProveedor 
	FROM PRI_CLIENTE_PROVEEDOR WHERE Cod_TipoDocumento= @Cod_TipoDocumento AND Nro_Documento= @Nro_Documento )
	BEGIN
		SET @Id_ClienteProveedor = (SELECT TOP 1 Id_ClienteProveedor 
		FROM PRI_CLIENTE_PROVEEDOR WHERE Cod_TipoDocumento= @Cod_TipoDocumento AND Nro_Documento= @Nro_Documento )
	END
	
	IF NOT EXISTS (SELECT @Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor))
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

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_ClienteProveedor , Cod_TipoDocumento , Nro_Documento , Cliente , Ap_Paterno , Ap_Materno , Nombres , Direccion , Cod_EstadoCliente , Cod_CondicionCliente , Cod_TipoCliente , RUC_Natural , Foto , Firma , Cod_TipoComprobante , Cod_Nacionalidad , Fecha_Nacimiento , Cod_Sexo , Email1 , Email2 , Telefono1 , Telefono2 , Fax , PaginaWeb , Cod_Ubigeo , Cod_FormaPago , Limite_Credito , Obs_Cliente , Num_DiaCredito , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_CLIENTE_PROVEEDOR
END
go
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK 
	@Id_ClienteProveedor	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_ClienteProveedor, Cod_TipoDocumento, Nro_Documento, Cliente, Ap_Paterno, Ap_Materno, Nombres, Direccion, Cod_EstadoCliente, Cod_CondicionCliente, Cod_TipoCliente, RUC_Natural, Foto, Firma, Cod_TipoComprobante, Cod_Nacionalidad, Fecha_Nacimiento, Cod_Sexo, Email1, Email2, Telefono1, Telefono2, Fax, PaginaWeb, Cod_Ubigeo, Cod_FormaPago, Limite_Credito, Obs_Cliente, Num_DiaCredito, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_CLIENTE_PROVEEDOR
	WHERE (Id_ClienteProveedor = @Id_ClienteProveedor)	
END
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_G' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G 
	@id_ComprobantePago	int output, 
	@Cod_Libro	varchar(2), 
	@Cod_Periodo	varchar(8), 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_TipoOperacion	varchar(5), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30), 
	@Id_Cliente	int, 
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
IF CONVERT(NVARCHAR(MAX),ISNULL(@Obs_Comprobante,'')) = ''
BEGIN
	SET @Obs_Comprobante = dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('CAJ_COMPROBANTE_PAGO');
END
	IF NOT EXISTS (SELECT @id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  (id_ComprobantePago = @id_ComprobantePago))
	BEGIN
		-- asignar un numero cuando este este en blanco
		if (@Numero = '' and @Cod_Libro = '14')
		  begin
			set @Numero = (SELECT RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(Numero)),0)+1), 8) FROM CAJ_COMPROBANTE_PAGO 
			WHERE Cod_TipoComprobante = @Cod_TipoComprobante and Serie=@Serie);
		  end
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

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TT' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TT
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT id_ComprobantePago , Cod_Libro , Cod_Periodo , Cod_Caja , Cod_Turno , Cod_TipoOperacion , Cod_TipoComprobante , Serie , Numero , Id_Cliente , Cod_TipoDoc , Doc_Cliente , Nom_Cliente , Direccion_Cliente , FechaEmision , FechaVencimiento , FechaCancelacion , Glosa , TipoCambio , Flag_Anulado , Flag_Despachado , Cod_FormaPago , Descuento_Total , Cod_Moneda , Impuesto , Total , Obs_Comprobante , Id_GuiaRemision , GuiaRemision , id_ComprobanteRef , Cod_Plantilla , Nro_Ticketera , Cod_UsuarioVendedor , Cod_RegimenPercepcion , Tasa_Percepcion , Placa_Vehiculo , Cod_TipoDocReferencia , Nro_DocReferencia , Valor_Resumen , Valor_Firma , Cod_EstadoComprobante , MotivoAnulacion , Otros_Cargos , Otros_Tributos , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM CAJ_COMPROBANTE_PAGO
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TXPK' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXPK
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXPK 
	@id_ComprobantePago	int
WITH ENCRYPTION
AS
BEGIN
	SELECT id_ComprobantePago, Cod_Libro, Cod_Periodo, Cod_Caja, Cod_Turno, Cod_TipoOperacion, Cod_TipoComprobante, Serie, Numero, Id_Cliente, Cod_TipoDoc, Doc_Cliente, Nom_Cliente, Direccion_Cliente, FechaEmision, FechaVencimiento, FechaCancelacion, Glosa, TipoCambio, Flag_Anulado, Flag_Despachado, Cod_FormaPago, Descuento_Total, Cod_Moneda, Impuesto, Total, Obs_Comprobante, Id_GuiaRemision, GuiaRemision, id_ComprobanteRef, Cod_Plantilla, Nro_Ticketera, Cod_UsuarioVendedor, Cod_RegimenPercepcion, Tasa_Percepcion, Placa_Vehiculo, Cod_TipoDocReferencia, Nro_DocReferencia, Valor_Resumen, Valor_Firma, Cod_EstadoComprobante, MotivoAnulacion, Otros_Cargos, Otros_Tributos, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM CAJ_COMPROBANTE_PAGO
	WHERE (id_ComprobantePago = @id_ComprobantePago)	
END
go


---- Guadar
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_I' AND type = 'P')
--DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I
--go
--CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_I 
--	@Cod_Libro	varchar(2), 
--	@Cod_Periodo	varchar(8), 
--	@Cod_Caja	varchar(32), 
--	@Cod_Turno	varchar(32), 
--	@Cod_TipoOperacion	varchar(5), 
--	@Cod_TipoComprobante	varchar(5), 
--	@Serie	varchar(5), 
--	@Numero	varchar(30), 
--	@Id_Cliente	int, 
--	@Cod_TipoDoc	varchar(2), 
--	@Doc_Cliente	varchar(20), 
--	@Nom_Cliente	varchar(512), 
--	@Direccion_Cliente	varchar(512), 
--	@FechaEmision	datetime, 
--	@FechaVencimiento	datetime, 
--	@FechaCancelacion	datetime, 
--	@Glosa	varchar(512), 
--	@TipoCambio	numeric(10,4), 
--	@Flag_Anulado	bit, 
--	@Flag_Despachado	bit, 
--	@Cod_FormaPago	varchar(5), 
--	@Descuento_Total	numeric(38,2), 
--	@Cod_Moneda	varchar(3), 
--	@Impuesto	numeric(38,6), 
--	@Total	numeric(38,2), 
--	@Obs_Comprobante	xml, 
--	@Id_GuiaRemision	int, 
--	@GuiaRemision	varchar(50), 
--	@id_ComprobanteRef	int, 
--	@Cod_Plantilla	varchar(32), 
--	@Nro_Ticketera	varchar(64), 
--	@Cod_UsuarioVendedor	varchar(32), 
--	@Cod_RegimenPercepcion	varchar(8), 
--	@Tasa_Percepcion	numeric(38,2), 
--	@Placa_Vehiculo	varchar(64), 
--	@Cod_TipoDocReferencia	varchar(8), 
--	@Nro_DocReferencia	varchar(64), 
--	@Valor_Resumen	varchar(1024), 
--	@Valor_Firma	varchar(2048), 
--	@Cod_EstadoComprobante	varchar(8), 
--	@MotivoAnulacion	varchar(512), 
--	@Otros_Cargos	numeric(38,2), 
--	@Otros_Tributos	numeric(38,2),
--	@Cod_Usuario Varchar(32)
--WITH ENCRYPTION
--AS
--BEGIN
--SET DATEFORMAT dmy;
--DECLARE @id_ComprobantePago INT = 0;--, @Id_Cliente int = 0;
--SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
--WHERE Cod_Libro = @Cod_Libro
--AND Cod_TipoComprobante = @Cod_TipoComprobante
--AND Serie = @Serie
--AND Numero= @Numero
--AND Cod_TipoDoc = @Cod_TipoDoc
--AND Doc_Cliente = @Doc_Cliente);

--set @Id_Cliente = (SELECT top 1 ISNULL(Id_ClienteProveedor,0) FROM PRI_CLIENTE_PROVEEDOR 
--WHERE  (Cod_TipoDocumento = @Cod_TipoDoc
--AND Nro_Documento = @Doc_Cliente));

----DECLARE @id_ComprobanteRef INT=0;
--if (@id_ComprobanteRef <> '0')
--BEGIN
--	SET @id_ComprobanteRef = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
--	WHERE Cod_Libro = dbo.UFN_Split(@Cod_ComprobanteRef,'|',0)
--	AND Cod_TipoComprobante = dbo.UFN_Split(@Cod_ComprobanteRef,'|',1)
--	AND Serie = dbo.UFN_Split(@Cod_ComprobanteRef,'|',2)
--	AND Numero= dbo.UFN_Split(@Cod_ComprobanteRef,'|',3)
--	AND Cod_TipoDoc = dbo.UFN_Split(@Cod_ComprobanteRef,'|',4)
--	AND Doc_Cliente = dbo.UFN_Split(@Cod_ComprobanteRef,'|',5));
--END

--IF (@Id_Cliente <> 0)
--BEGIN
--IF NOT EXISTS (SELECT @id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  (id_ComprobantePago = @id_ComprobantePago))
--BEGIN
--INSERT INTO CAJ_COMPROBANTE_PAGO  VALUES (
--		@Cod_Libro,
--		@Cod_Periodo,
--		@Cod_Caja,
--		@Cod_Turno,
--		@Cod_TipoOperacion,
--		@Cod_TipoComprobante,
--		@Serie,
--		@Numero,
--		@Id_Cliente,
--		@Cod_TipoDoc,
--		@Doc_Cliente,
--		@Nom_Cliente,
--		@Direccion_Cliente,
--		@FechaEmision,
--		@FechaVencimiento,
--		@FechaCancelacion,
--		@Glosa,
--		@TipoCambio,
--		@Flag_Anulado,
--		@Flag_Despachado,
--		@Cod_FormaPago,
--		@Descuento_Total,
--		@Cod_Moneda,
--		@Impuesto,
--		@Total,
--		@Obs_Comprobante,
--		@Id_GuiaRemision,
--		@GuiaRemision,
--		@id_ComprobanteRef,
--		@Cod_Plantilla,
--		@Nro_Ticketera,
--		@Cod_UsuarioVendedor,
--		@Cod_RegimenPercepcion,
--		@Tasa_Percepcion,
--		@Placa_Vehiculo,
--		@Cod_TipoDocReferencia,
--		@Nro_DocReferencia,
--		@Valor_Resumen,
--		@Valor_Firma,
--		@Cod_EstadoComprobante,
--		@MotivoAnulacion,
--		@Otros_Cargos,
--		@Otros_Tributos,
--		@Cod_Usuario,GETDATE(),NULL,NULL)
--		SET @id_ComprobantePago = @@IDENTITY 
--	END
--	ELSE
--	BEGIN
--		UPDATE CAJ_COMPROBANTE_PAGO
--		SET	
--			Cod_Libro = @Cod_Libro, 
--			Cod_Periodo = @Cod_Periodo, 
--			Cod_Caja = @Cod_Caja, 
--			Cod_Turno = @Cod_Turno, 
--			Cod_TipoOperacion = @Cod_TipoOperacion, 
--			Cod_TipoComprobante = @Cod_TipoComprobante, 
--			Serie = @Serie, 
--			Numero = @Numero, 
--			Id_Cliente = @Id_Cliente, 
--			Cod_TipoDoc = @Cod_TipoDoc, 
--			Doc_Cliente = @Doc_Cliente, 
--			Nom_Cliente = @Nom_Cliente, 
--			Direccion_Cliente = @Direccion_Cliente, 
--			FechaEmision = @FechaEmision, 
--			FechaVencimiento = @FechaVencimiento, 
--			FechaCancelacion = @FechaCancelacion, 
--			Glosa = @Glosa, 
--			TipoCambio = @TipoCambio, 
--			Flag_Anulado = @Flag_Anulado, 
--			Flag_Despachado = @Flag_Despachado, 
--			Cod_FormaPago = @Cod_FormaPago, 
--			Descuento_Total = @Descuento_Total, 
--			Cod_Moneda = @Cod_Moneda, 
--			Impuesto = @Impuesto, 
--			Total = @Total, 
--			Obs_Comprobante = @Obs_Comprobante, 
--			Id_GuiaRemision = @Id_GuiaRemision, 
--			GuiaRemision = @GuiaRemision, 
--			id_ComprobanteRef = @id_ComprobanteRef, 
--			Cod_Plantilla = @Cod_Plantilla, 
--			Nro_Ticketera = @Nro_Ticketera, 
--			Cod_UsuarioVendedor = @Cod_UsuarioVendedor, 
--			Cod_RegimenPercepcion = @Cod_RegimenPercepcion, 
--			Tasa_Percepcion = @Tasa_Percepcion, 
--			Placa_Vehiculo = @Placa_Vehiculo, 
--			Cod_TipoDocReferencia = @Cod_TipoDocReferencia, 
--			Nro_DocReferencia = @Nro_DocReferencia, 
--			Valor_Resumen = @Valor_Resumen, 
--			Valor_Firma = @Valor_Firma, 
--			Cod_EstadoComprobante = @Cod_EstadoComprobante, 
--			MotivoAnulacion = @MotivoAnulacion, 
--			Otros_Cargos = @Otros_Cargos, 
--			Otros_Tributos = @Otros_Tributos,
--			Cod_UsuarioAct = @Cod_Usuario, 
--			Fecha_Act = GETDATE()
--		WHERE (id_ComprobantePago = @id_ComprobantePago)	
--	END
--END
--END
--go


--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 31/07/2015
-- OBJETIVO: Extorna el Movimiento hecho en ComprobantePago
-- exec USP_CAJ_COMPROBANTE_PAGO_EXTORNAR 115102,'601','D30/03/2016','31/03/2016','LIDIA'
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_EXTORNAR' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_EXTORNAR
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_EXTORNAR
@id_ComprobantePago int OUTPUT,
@Cod_Caja  varchar(32), 
@Cod_Turno  varchar(32), 
@Fecha  datetime,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Id_Producto  int, @Signo  int, 
	@Cod_Almacen  varchar(32), 
	@Cod_UnidadMedida  varchar(5), 
	@Despachado  numeric(38,6),
	@Cod_TipoComprobante  varchar(5),
	@Serie  varchar(5),
	@Numero  varchar(15);

	UPDATE CAJ_COMPROBANTE_PAGO
	SET
	Glosa = 'ANULADO', 
	Flag_Anulado = 1, 
	Descuento_Total = 0, 
	Impuesto = 0, 
	Total = 0, 
	Cod_UsuarioAct = @Cod_Usuario, 
	Fecha_Act = GETDATE()
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	UPDATE ALM_ALMACEN_MOV_D
	SET
	Precio_Unitario = 0, 
	Cantidad = 0, 
	Cod_UsuarioAct = @Cod_Usuario, 
	Fecha_Act = GETDATE()
	WHERE (Id_AlmacenMov IN (SELECT Id_AlmacenMov  FROM ALM_ALMACEN_MOV WHERE Id_ComprobantePago = @Id_ComprobantePago))

	UPDATE ALM_ALMACEN_MOV
	SET 
	Motivo = 'ANULADO', 
	Flag_Anulado = 1,
	Cod_UsuarioAct = @Cod_Usuario, 
	Fecha_Act = GETDATE()
	WHERE Id_ComprobantePago = @Id_ComprobantePago

	UPDATE CAJ_COMPROBANTE_D
	SET
	Cantidad = 0, 
	Despachado = 0, 
	PrecioUnitario = 0, 
	Sub_Total = 0, 
	Formalizado = 0,
	Cod_UsuarioAct = @Cod_Usuario, 
	Fecha_Act = GETDATE()
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	UPDATE CAJ_FORMA_PAGO
	SET
	Monto = 0, 
	Cod_UsuarioAct = @Cod_Usuario, 
	Fecha_Act = GETDATE()
	WHERE (id_ComprobantePago = @id_ComprobantePago) 

	-- ELIMINAR ELEMENTOS IMPORTANTES QUE NO TIENEN ESTADO O CONDICION
	DELETE FROM PRI_LICITACIONES_M
	WHERE (id_ComprobantePago = @id_ComprobantePago) 

	-- REVERTIR LA ENTRADA ANTES DE ELIMINAR
	UPDATE CAJ_COMPROBANTE_D
	SET Formalizado -= CR.Valor
	FROM CAJ_COMPROBANTE_D CD INNER JOIN CAJ_COMPROBANTE_RELACION CR
	ON CD.id_ComprobantePago = CR.id_ComprobantePago AND CD.id_Detalle = CR.id_Detalle
	WHERE CR.Id_ComprobanteRelacion = @id_ComprobantePago

	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (Id_ComprobanteRelacion = @id_ComprobantePago)

	DELETE FROM CAJ_SERIES
	WHERE (Id_Tabla = @id_ComprobantePago AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')

	-- INSERTAR SI EN EL CASO QUE FUERA UNA 
	IF EXISTS(SELECT       id_ComprobantePago
	FROM CAJ_COMPROBANTE_PAGO 
	WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Libro = '14')
	 AND (Cod_TipoComprobante= 'TKB' OR Cod_TipoComprobante= 'TKF') )
	BEGIN
	SELECT @Cod_TipoComprobante=Cod_TipoComprobante , @Serie=Serie
	FROM CAJ_COMPROBANTE_PAGO
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	set @Numero = (SELECT RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(Numero)),0)+1), 8) FROM CAJ_COMPROBANTE_PAGO 
	WHERE Cod_TipoComprobante = @Cod_TipoComprobante and Serie=@Serie AND Cod_Libro = '14');

	INSERT INTO CAJ_COMPROBANTE_PAGO
	SELECT Cod_Libro , Cod_Periodo , @Cod_Caja , @Cod_Turno , Cod_TipoOperacion , 
	Cod_TipoComprobante , Serie , @Numero , Id_Cliente , Cod_TipoDoc , Doc_Cliente , Nom_Cliente , 
	Direccion_Cliente , GETDATE() , GETDATE() , GETDATE() , 'POR LA ANULACION DE: '+ Cod_TipoComprobante + ': ' +Serie +' - '+Numero  , TipoCambio , 
	Flag_Anulado , Flag_Despachado , Cod_FormaPago , Descuento_Total , Cod_Moneda , Impuesto , 
	Total , Obs_Comprobante , Id_GuiaRemision , GuiaRemision , id_ComprobantePago , Cod_Plantilla , 
	Nro_Ticketera , Cod_UsuarioVendedor , Cod_RegimenPercepcion , Tasa_Percepcion , Placa_Vehiculo , 
	Cod_TipoDocReferencia , Nro_DocReferencia , Valor_Resumen , Valor_Firma , Cod_EstadoComprobante , 
	MotivoAnulacion , Otros_Cargos , Otros_Tributos ,
	@Cod_Usuario , GETDATE() , NULL , NULL 
	FROM CAJ_COMPROBANTE_PAGO
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	SELECT @@IDENTITY

	INSERT INTO CAJ_FORMA_PAGO
	SELECT @@IDENTITY , Item , Des_FormaPago , Cod_TipoFormaPago , Cuenta_CajaBanco , Id_Movimiento , 
	TipoCambio , Cod_Moneda , Monto , @Cod_Caja , @Cod_Turno , Cod_Plantilla , Obs_FormaPago , GETDATE() , 
	@Cod_Usuario , GETDATE() , NULL , NULL 
	FROM CAJ_FORMA_PAGO
	WHERE (id_ComprobantePago = @id_ComprobantePago) 

	END
	ELSE
	SELECT 0

END
GO
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_D_G' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_D_G
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_G 
	@id_ComprobantePago	int, 
	@id_Detalle	int out, 
	@Id_Producto	int, 
	@Cod_Almacen	varchar(32), 
	@Cantidad	numeric(38,6), 
	@Cod_UnidadMedida	varchar(5), 
	@Despachado	numeric(38,6), 
	@Descripcion	varchar(MAX), 
	@PrecioUnitario	numeric(38,6), 
	@Descuento	numeric(38,2), 
	@Sub_Total	numeric(38,2), 
	@Tipo	varchar(256), 
	@Obs_ComprobanteD	varchar(1024), 
	@Cod_Manguera	varchar(32), 
	@Flag_AplicaImpuesto	bit, 
	@Formalizado	numeric(38,6), 
	@Valor_NoOneroso	numeric(38,2), 
	@Cod_TipoISC	varchar(8), 
	@Porcentaje_ISC	numeric(38,2), 
	@ISC	numeric(38,2), 
	@Cod_TipoIGV	varchar(8), 
	@Porcentaje_IGV	numeric(38,2), 
	@IGV	numeric(38,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @id_ComprobantePago, @id_Detalle FROM CAJ_COMPROBANTE_D WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle))
BEGIN
	SET @id_Detalle = (SELECT isnull(max(id_Detalle),0)+1 FROM CAJ_COMPROBANTE_D WHERE  (id_ComprobantePago = @id_ComprobantePago))
	IF (EXISTS(SELECT CP.id_ComprobantePago 
	FROM  CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
	 WHERE (VTC.Flag_RegistroVentas = 1 OR VTC.Flag_RegistroCompras = 1) AND CP.id_ComprobantePago = @id_ComprobantePago))
	BEGIN
		SET @Formalizado = @Cantidad
	END
	ELSE
	BEGIN
		SET @Formalizado = 0.00
	END	
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

-- Actualizar el Servidor
UPDATE PRI_EMPRESA SET version = 'S|8.0.0';
go


