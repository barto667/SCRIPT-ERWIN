--Creamos nuestra tabla temporal donde se insertan los datos de las inserciones, modificaciones y eliminacion
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_REGISTRO_LOG' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_REGISTRO_LOG (
	Id uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Nombre_Tabla varchar(max) ,
	Id_Fila varchar(max)  ,
	Accion varchar(max) ,
	Script varchar(max),
	Fecha_Reg datetime )
END
GO

--Creamos nuestra tabla temporal donde se almacenen el historial de los datos
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_REGISTRO_LOG_H' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_REGISTRO_LOG_H (
	Id uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Nombre_Tabla varchar(max) ,
	Id_Fila varchar(max)  ,
	Accion varchar(max) ,
	Script varchar(max),
	Fecha_Reg datetime ,
	Fecha_Reg_Insercion datetime)
END
GO


--Base de datos de auditoria y tabla
IF NOT EXISTS (SELECT * 
	   FROM   master..sysdatabases 
	   WHERE  name = N'PALERP_Auditoria')
	   CREATE DATABASE PALERP_Auditoria
GO

--Tabla
IF NOT EXISTS(SELECT name 
	  FROM 	PALERP_Auditoria.dbo.sysobjects 
	  WHERE  name = N'PRI_AUDITORIA' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE  PALERP_Auditoria.dbo.PRI_AUDITORIA (
	Id uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Nombre_Tabla varchar(max) ,
	Id_Fila varchar(max)  ,
	Accion varchar(max) ,
	Valor varchar(max),
	Fecha_Reg datetime )
END
GO

--TRIGGERS
--PRI_SUCURSAL
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_SUCURSAL
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Sucursal varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Sucursal, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
	    ''''+REPLACE(ps.Cod_Sucursal,'''','')+''','+
	    CASE WHEN ps.Nom_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Nom_Sucursal,'''','') +''','END+
	    CASE WHEN ps.Dir_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Dir_Sucursal,'''','') +''','END+
	    CASE WHEN ps.Por_UtilidadMax IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), ps.Por_UtilidadMax) +','END+
	    CASE WHEN ps.Por_UtilidadMin IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), ps.Por_UtilidadMin) +','END+
	    CASE WHEN ps.Cod_UsuarioAdm IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Cod_UsuarioAdm,'''','') +''','END+
	    CASE WHEN ps.Cabecera_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Cabecera_Pagina,'''','') +''','END+
	    CASE WHEN ps.Pie_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Pie_Pagina,'''','') +''','END+
	    convert(varchar(max),ps.Flag_Activo)+','+
	    CASE WHEN ps.Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ps.Cod_Ubigeo,'''','') +''','END+
	    ''''+REPLACE(COALESCE(ps.Cod_UsuarioAct,ps.Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.PRI_SUCURSAL ps
	    WHERE ps.Cod_Sucursal=@Cod_Sucursal

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())

		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_SUCURSAL', -- Nombre_Tabla - varchar
		    @Cod_Sucursal, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO

--PRI_ESTABLECIMIENTOS
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_ESTABLECIMIENTOS
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Establecimientos varchar(32) 
	DECLARE   @Id_ClienteProveedor int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Establecimientos, 
		i.Id_ClienteProveedor,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Establecimientos, 
		@Id_ClienteProveedor,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_ESTABLECIMIENTOS_I ' +
	    ''''+ REPLACE(pe.Cod_Establecimientos,'''','') +''','+
	    CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
	    CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Nro_Documento,'''','')+''','END+
	    CASE WHEN  pe.Des_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Des_Establecimiento,'''','')+''','END+
	    CASE WHEN  pe.Cod_TipoEstablecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Cod_TipoEstablecimiento,'''','')+''','END+
	    CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Direccion,'''','')+''','END+
	    CASE WHEN  pe.Telefono IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Telefono,'''','')+''','END+
	    CASE WHEN  pe.Obs_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Obs_Establecimiento,'''','')+''','END+
	    CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Cod_Ubigeo,'''','')+''','END+
	    ''''+REPLACE(COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg) ,'''','')  +''';' 
	    FROM dbo.PRI_ESTABLECIMIENTOS pe INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	    ON pe.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	    WHERE pe.Cod_Establecimientos=@Cod_Establecimientos AND pe.Id_ClienteProveedor=@Id_ClienteProveedor

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - varchar
		    @Cod_Establecimientos+'|'+CONVERT(varchar(max),@Id_ClienteProveedor), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Establecimientos, 
		@Id_ClienteProveedor,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO

--ALM_ALMACEN
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.ALM_ALMACEN
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Almacen varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Almacen, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Almacen, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_ALMACEN_I ''' +
	    REPLACE(aa.Cod_Almacen,'''','')+''','+
	    CASE WHEN aa.Des_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Des_Almacen,'''','')+''','END+
	    CASE WHEN aa.Des_CortaAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Des_CortaAlmacen,'''','')+''','END+
	    CASE WHEN aa.Cod_TipoAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Cod_TipoAlmacen,'''','')+''','END+
	    CONVERT(VARCHAR(MAX),aa.Flag_Principal)+','+
	    ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
	    FROM dbo.ALM_ALMACEN aa
	    WHERE aa.Cod_Almacen=@Cod_Almacen

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'ALM_ALMACEN', -- Nombre_Tabla - varchar
		    @Cod_Almacen, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Almacen, 
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO

--CAJ_CAJAS
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJAS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJAS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_CAJAS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_CAJAS
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Caja varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Caja, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJAS_I ' +
	    ''''+REPLACE(cc.Cod_Caja,'''','')+ ''','+
	    CASE WHEN cc.Des_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Des_Caja,'''','')+''','END +
	    CASE WHEN cc.Cod_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_Sucursal,'''','')+''','END +
	    CASE WHEN cc.Cod_UsuarioCajero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_UsuarioCajero,'''','')+''','END +
	    CASE WHEN cc.Cod_CuentaContable IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_CuentaContable,'''','')+''','END +
	    CONVERT(varchar(MAX),cc.Flag_Activo)+','+
	    ''''+REPLACE(COALESCE(cc.Cod_UsuarioAct,cc.Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.CAJ_CAJAS cc
	    WHERE cc.Cod_Caja=@Cod_Caja

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_CAJAS', -- Nombre_Tabla - varchar
		    @Cod_Caja, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO

--ALM_ALMACEN
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJAS_DOC_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJAS_DOC_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_CAJAS_DOC_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_CAJAS_DOC
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Caja varchar(32) 
	DECLARE	@Item int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Caja, 
		i.Item,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Item,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJAS_DOC_I ' + 
	    ''''+REPLACE(ccd.Cod_Caja,'''','')+''','+
	    CONVERT (VARCHAR(MAX),ccd.Item)+ ','+
	    CASE WHEN ccd.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Cod_TipoComprobante,'''','')+''','END+
	    CASE WHEN ccd.Serie IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Serie,'''','')+''','END+
	    CASE WHEN ccd.Impresora IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Impresora,'''','')+''','END+
	    CONVERT (VARCHAR(MAX),ccd.Flag_Imprimir)+ ','+
	    CONVERT (VARCHAR(MAX),ccd.Flag_FacRapida)+ ','+
	    CASE WHEN ccd.Nom_Archivo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Nom_Archivo,'''','')+''','END+
	    CASE WHEN ccd.Nro_SerieTicketera IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Nro_SerieTicketera,'''','')+''','END+
	    CASE WHEN ccd.Nom_ArchivoPublicar IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Nom_ArchivoPublicar,'''','')+''','END+
	    CASE WHEN ccd.Limite IS NULL THEN 'NULL,' ELSE CONVERT (VARCHAR(MAX),ccd.Limite)+ ','END+
	    ''''+REPLACE(COALESCE(ccd.Cod_UsuarioAct,ccd.Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.CAJ_CAJAS_DOC ccd
	    WHERE ccd.Cod_Caja=@Cod_Caja AND ccd.Item=@Item

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_CAJAS_DOC', -- Nombre_Tabla - varchar
		    @Cod_Caja+'|'+CONVERT(varchar(max),@Item), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Item,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--CAJ_CAJA_ALMACEN
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJA_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJA_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_CAJA_ALMACEN_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_CAJA_ALMACEN
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Caja varchar(32) 
	DECLARE   @Cod_Almacen varchar(32)
	DECLARE	@Item int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Caja, 
		i.Cod_Almacen,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Cod_Almacen,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_CAJA_ALMACEN_I ' + 
	    ''''+REPLACE(cca.Cod_Caja,'''','')+''','+
	    ''''+REPLACE(cca.Cod_Almacen,'''','')+''','+
	    CONVERT (VARCHAR(MAX),cca.Flag_Principal)+ ','+
	    ''''+REPLACE(COALESCE(cca.Cod_UsuarioAct,cca.Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.CAJ_CAJA_ALMACEN cca
	    WHERE cca.Cod_Caja=@Cod_Caja AND cca.Cod_Almacen=@Cod_Almacen

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - varchar
		    @Cod_Caja+'|'+@Cod_Almacen, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Caja, 
		@Cod_Almacen,
		@Fecha_Reg, 
		@Fecha_Act  
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO




--PRI_CATEGORIA
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CATEGORIA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CATEGORIA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_CATEGORIA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_CATEGORIA
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Categoria varchar(32) 
	DECLARE	@Item int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Categoria, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Categoria, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CATEGORIA_I ' +
	    ''''+REPLACE(pc.Cod_Categoria,'''','')+''','+
	    CASE WHEN  pc.Des_Categoria IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pc.Des_Categoria,'''','')+''','END+
	    'NULL,'+
	    CASE WHEN  pc.Cod_CategoriaPadre IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pc.Cod_CategoriaPadre,'''','')+''','END+
	    ''''+REPLACE(COALESCE(pc.Cod_UsuarioAct,pc.Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.PRI_CATEGORIA pc 
	    WHERE pc.Cod_Categoria=@Cod_Categoria

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_CATEGORIA', -- Nombre_Tabla - varchar
		    @Cod_Categoria, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Categoria, 
		@Fecha_Reg, 
		@Fecha_Act  
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--ALM_INVENTARIO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_INVENTARIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_INVENTARIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_ALM_INVENTARIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.ALM_INVENTARIO
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Inventario int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Inventario, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Inventario, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_INVENTARIO_I ' + 
	    CASE WHEN Des_Inventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_Inventario,'''','')+''','END+
 	    CASE WHEN Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoInventario,'''','')+''','END+
	    CASE WHEN Obs_Inventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Obs_Inventario,'''','')+''','END+
	    CASE WHEN Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Almacen,'''','')+''','END+
	    ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')   +''';' 
	    FROM dbo.ALM_INVENTARIO ai
	    WHERE ai.Id_Inventario=@Id_Inventario

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'ALM_INVENTARIO', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Inventario), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Inventario, 
		@Fecha_Reg, 
		@Fecha_Act  
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--ALM_INVENTARIO_D
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_INVENTARIO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_INVENTARIO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_ALM_INVENTARIO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.ALM_INVENTARIO_D
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Inventario int
	DECLARE   @Item varchar(32)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Inventario, 
		i.Item,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Inventario, 
		@Item,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_ALM_INVENTARIO_D_I ' + 
	    CASE WHEN I.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(I.Cod_TipoInventario,'''','')+''','END+
	    CASE WHEN ID.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Cod_Almacen,'''','')+''','END+
	    ''''+ REPLACE(ID.Item,'''','')+''','+
	    ''''+ REPLACE(P.Cod_Producto,'''','')+''','+
	    CASE WHEN ID.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Cod_UnidadMedida,'''','')+''','END+
	    CASE WHEN ID.Cantidad_Sistema IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Sistema)+','END+
	    CASE WHEN ID.Cantidad_Encontrada IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Encontrada)+','END+
	    CASE WHEN ID.Obs_InventarioD IS NULL THEN 'NULL'  ELSE ''''+REPLACE( ID.Obs_InventarioD,'''','')+''','END+
	    ''''+REPLACE(COALESCE(ID.Cod_UsuarioAct,ID.Cod_UsuarioReg),'''','')   +''';' 
	    FROM ALM_INVENTARIO_D ID INNER JOIN PRI_PRODUCTOS P ON ID.Id_Producto=P.Id_Producto
	    INNER JOIN ALM_INVENTARIO I ON I.Id_Inventario=ID.Id_Inventario
	    WHERE ID.Id_Inventario = @Id_Inventario AND ID.Item = @Item

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'ALM_INVENTARIO_D', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Inventario)+'|'+@Item, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Inventario, 
		@Item,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--PRI_PRODUCTOS
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_PRODUCTOS_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_PRODUCTOS
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Producto int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Producto, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Producto, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTOS_I ''' +
   	    REPLACE(Cod_Producto,'''','')+''','+ 
	    CASE WHEN Cod_Categoria  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Categoria,'''','')+''','END+
	    CASE WHEN Cod_Marca  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Marca,'''','')+''','END+
	    CASE WHEN Cod_TipoProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoProducto,'''','')+''','END+
	    CASE WHEN Nom_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nom_Producto,'''','')+''','END+
	    CASE WHEN Des_CortaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_CortaProducto,'''','')+''','END+
	    CASE WHEN Des_LargaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_LargaProducto,'''','')+''','END+
	    CASE WHEN Caracteristicas  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Caracteristicas,'''','')+''','END+
	    CASE WHEN Porcentaje_Utilidad  IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), Porcentaje_Utilidad)+','END+
	    CASE WHEN Cuenta_Contable  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cuenta_Contable,'''','')+''','END+
	    CASE WHEN Contra_Cuenta  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Contra_Cuenta,'''','')+''','END+
	    CASE WHEN Cod_Garantia  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Garantia,'''','')+''','END+
	    CASE WHEN Cod_TipoExistencia  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoExistencia,'''','')+''','END+
	    CASE WHEN Cod_TipoOperatividad  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoOperatividad,'''','')+''','END+
	    CONVERT(VARCHAR(MAX),Flag_Activo)+','+
	    CONVERT(VARCHAR(MAX),Flag_Stock)+','+
	    CASE WHEN Cod_Fabricante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Fabricante,'''','')+''','END+
	    CASE WHEN Obs_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),Obs_Producto),'''','')+''','END+
	    ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
	    FROM            dbo.PRI_PRODUCTOS pp
	    WHERE pp.Id_Producto=@Id_Producto

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_PRODUCTOS', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Producto), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Producto, 
		@Fecha_Reg, 
		@Fecha_Act  
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--PRI_PRODUCTO_STOCK
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_STOCK_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_STOCK_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_STOCK_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_PRODUCTO_STOCK
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Producto int
	DECLARE   @Cod_UnidadMedida varchar(5)
	DECLARE   @Cod_Almacen varchar(32)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Producto, 
		i.Cod_UnidadMedida,
		i.Cod_Almacen,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_UnidadMedida ,
	     @Cod_Almacen ,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_STOCK_I ''' +
	    REPLACE(P.Cod_Producto,'''','')+''', '''+ 
	    REPLACE(S.Cod_UnidadMedida,'''','')+''', '''+ 
	    REPLACE(S.Cod_Almacen,'''','')+''','+ 
	    CASE WHEN S.Cod_Moneda  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Moneda,'''','')+''','END+
	    CASE WHEN S.Precio_Compra  IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Precio_Compra)+','END+
	    CASE WHEN S.Precio_Venta IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Precio_Venta)+','END+
	    CASE WHEN S.Stock_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Min)+','END+
	    CASE WHEN S.Stock_Max IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Max)+','END+
	    CASE WHEN S.Stock_Act IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Stock_Act)+','END+
	    CASE WHEN S.Cod_UnidadMedidaMin IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedidaMin,'''','')+''','END+
	    CASE WHEN S.Cantidad_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Cantidad_Min)+','END+
	    ''''+ REPLACE(COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg),'''','')+''';' 
	    FROM PRI_PRODUCTO_STOCK AS S INNER JOIN
			PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
	    WHERE S.Id_Producto=@Id_Producto AND S.Cod_UnidadMedida=@Cod_UnidadMedida AND S.Cod_Almacen=@Cod_Almacen

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Producto)+'|'+@Cod_UnidadMedida+'|'+@Cod_Almacen, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_UnidadMedida ,
	     @Cod_Almacen ,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--PRI_PRODUCTO_PRECIO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_PRECIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_PRECIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_PRECIO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_PRODUCTO_PRECIO
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Producto int
	DECLARE   @Cod_UnidadMedida varchar(5)
	DECLARE   @Cod_Almacen varchar(32)
	DECLARE   @Cod_TipoPrecio varchar(5)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Producto, 
		i.Cod_UnidadMedida,
		i.Cod_Almacen,
		i.Cod_TipoPrecio,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_UnidadMedida ,
	     @Cod_Almacen ,
		@Cod_TipoPrecio,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_PRECIO_I ''' + 
	    REPLACE(P.Cod_Producto,'''','')+''', '''+ 
	    REPLACE(PP.Cod_UnidadMedida,'''','')+''', '''+ 
	    REPLACE(PP.Cod_Almacen,'''','')+''', '''+ 
	    REPLACE(PP.Cod_TipoPrecio,'''','')+''','+ 
 	    CASE WHEN PP.Valor IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),PP.Valor)+',' END+ 
	    ''''+REPLACE(COALESCE(PP.Cod_UsuarioAct,PP.Cod_UsuarioReg),'''','')+''';'
	    FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
								PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto
	    WHERE PP.Id_Producto=@Id_Producto AND PP.Cod_UnidadMedida=@Cod_UnidadMedida
	    AND PP.Cod_Almacen=@Cod_Almacen AND PP.Cod_TipoPrecio=@Cod_TipoPrecio

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Producto)+'|'+@Cod_UnidadMedida+'|'+@Cod_Almacen+'|'+@Cod_TipoPrecio, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_UnidadMedida ,
	     @Cod_Almacen ,
		@Cod_TipoPrecio,
		@Fecha_Reg, 
		@Fecha_Act  
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--PRI_PRODUCTO_DETALLE
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_DETALLE_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_DETALLE_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_DETALLE_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_PRODUCTO_DETALLE
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Producto int
	DECLARE   @Item_Detalle int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Producto, 
		i.Item_Detalle,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Item_Detalle,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_DETALLE_I ''' + 
	    REPLACE(P.Cod_Producto,'''','')+''','+ 
	    CONVERT(VARCHAR(MAX),D.Item_Detalle)+','''+ 
	    REPLACE(PD.Cod_Producto,'''','') +''','+  
	    CASE WHEN D.Cod_TipoDetalle IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(D.Cod_TipoDetalle,'''','')+''','END+
	    CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), D.Cantidad)+','END+
	    CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(D.Cod_UnidadMedida,'''','')+''','END+
	    ''''+REPLACE(COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg),'''','')+''';' 
	    FROM PRI_PRODUCTO_DETALLE AS D INNER JOIN
		    PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto INNER JOIN
		    PRI_PRODUCTOS AS PD ON D.Id_ProductoDetalle = PD.Id_Producto
	    WHERE D.Id_Producto=@Id_Producto AND D.Item_Detalle=@Item_Detalle

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Producto)+'|'+CONVERT(varchar(max),@Item_Detalle), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Item_Detalle,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--PRI_PRODUCTO_TASA
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_TASA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_TASA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_TASA_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_PRODUCTO_TASA
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_Producto int
	DECLARE   @Cod_Tasa varchar(32)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_Producto, 
		i.Cod_Tasa,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_Tasa,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTO_TASA_I ''' +
	    REPLACE(T.Cod_Tasa,'''','')+''', '''+ 
	    REPLACE(P.Cod_Producto,'''','')+''','+ 
	    CASE WHEN T.Cod_Libro  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Cod_Libro,'''','') +''','END+
	    CASE WHEN T.Des_Tasa IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Des_Tasa,'''','')+''','END+
	    CASE WHEN T.Por_Tasa IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Por_Tasa)+','END+
	    CASE WHEN T.Cod_TipoTasa IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(T.Cod_TipoTasa,'''','')+''','END+
	    CASE WHEN T.Flag_Activo IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Flag_Activo)+','END+
	    CASE WHEN T.Obs_Tasa IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(T.Obs_Tasa,'''','')+''','END+
	    ''''+REPLACE(COALESCE(T.Cod_UsuarioAct,T.Cod_UsuarioReg),'''','')+''';'
	    FROM  PRI_PRODUCTO_TASA AS T INNER JOIN
			 PRI_PRODUCTOS AS P ON T.Id_Producto = P.Id_Producto
	    WHERE T.Id_Producto=@Id_Producto AND T.Cod_Tasa=@Cod_Tasa

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_PRODUCTO_TASA', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_Producto)+'|'+@Cod_Tasa, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_Producto ,
		@Cod_Tasa,
		@Fecha_Reg, 
		@Fecha_Act
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--PRI_CLIENTE_PROVEEDOR
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.PRI_CLIENTE_PROVEEDOR
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Id_ClienteProveedor int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Id_ClienteProveedor, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Id_ClienteProveedor ,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_PROVEEDOR_I ' + 
	    CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoDocumento,'''','')+''','END+
	    CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
	    CASE WHEN Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cliente,'''','')+''','END+
	    CASE WHEN Ap_Paterno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Paterno,'''','')+''','END+
	    CASE WHEN Ap_Materno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Materno,'''','')+''','END+
	    CASE WHEN Nombres IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nombres,'''','')+''','END+
	    CASE WHEN Direccion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Direccion,'''','')+''','END+
	    CASE WHEN Cod_EstadoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_EstadoCliente,'''','')+''','END+
	    CASE WHEN Cod_CondicionCliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Cod_CondicionCliente,'''','')+''','END+
	    CASE WHEN Cod_TipoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoCliente,'''','')+''','END+
	    CASE WHEN RUC_Natural IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(RUC_Natural,'''','')+''','END+
	    'NULL,
	    NULL, '+ 
	    CASE WHEN Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoComprobante,'''','')+''','END+
	    CASE WHEN Cod_Nacionalidad IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Nacionalidad,'''','')+''','END+
	    CASE WHEN Fecha_Nacimiento IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Nacimiento,121)+''','END+
	    CASE WHEN Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Sexo,'''','')+''','END+
	    CASE WHEN Email1 IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Email1,'''','')+''','END+
	    CASE WHEN Email2 IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Email2,'''','')+''','END+
	    CASE WHEN Telefono1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono1,'''','')+''','END+
	    CASE WHEN Telefono2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono2,'''','')+''','END+
	    CASE WHEN Fax IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Fax,'''','')+''','END+
	    CASE WHEN PaginaWeb IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(PaginaWeb,'''','')+''','END+
	    CASE WHEN Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Cod_Ubigeo,'''','')+''','END+
	    CASE WHEN Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_FormaPago,'''','')+''','END+
	    CASE WHEN Limite_Credito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Limite_Credito)+','END+
	    CASE WHEN Obs_Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE( CONVERT(VARCHAR(MAX),Obs_Cliente),'''','')+''','END+
	    CASE WHEN Num_DiaCredito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Num_DiaCredito)+','END+
	    ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','') +''';' 
	    FROM dbo.PRI_CLIENTE_PROVEEDOR   pcp  
	    WHERE pcp.Id_ClienteProveedor=@Id_ClienteProveedor

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@Id_ClienteProveedor), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Id_ClienteProveedor ,
		@Fecha_Reg, 
		@Fecha_Act
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--CAJ_TURNO_ATENCION
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_TURNO_ATENCION_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_TURNO_ATENCION_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_TURNO_ATENCION_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_TURNO_ATENCION
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Turno varchar(32)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Turno, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Turno ,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_TURNO_ATENCION_I ''' + 
	    REPLACE(Cod_Turno,'''','')+''','+ 
	    CASE WHEN Des_Turno IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Des_Turno,'''','')+''','END+
	    CASE WHEN Fecha_Inicio IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Inicio,121)+''','END+
	    CASE WHEN Fecha_Fin IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Fin,121)+''','END+
		CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+
	    ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
	    FROM CAJ_TURNO_ATENCION
	    WHERE Cod_Turno=@Cod_Turno

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_TURNO_ATENCION', -- Nombre_Tabla - varchar
		    @Cod_Turno, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Turno ,
		@Fecha_Reg, 
		@Fecha_Act
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--CAJ_ARQUEOFISICO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_ARQUEOFISICO
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@id_ArqueoFisico int
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.id_ArqueoFisico, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_I ' + 
	    CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Caja,'''','')+''','END+
	    CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','')+''','END+
	    CONVERT(VARCHAR(MAX),Numero) +','+ 
	    CASE WHEN Des_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_ArqueoFisico,'''','')+''','END+
	    CASE WHEN Obs_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+REPLACE( Obs_ArqueoFisico,'''','')+''','END+
	    ''''+CONVERT(VARCHAR(MAX),Fecha,121) +''','+ 
	    CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+ 
	    ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','') +''';' 
	    FROM CAJ_ARQUEOFISICO
	    WHERE id_ArqueoFisico=@id_ArqueoFisico

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_ARQUEOFISICO', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@id_ArqueoFisico), -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Fecha_Reg, 
		@Fecha_Act
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--CAJ_ARQUEOFISICO_D
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_D_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_ARQUEOFISICO_D
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@id_ArqueoFisico int
	DECLARE   @Cod_Billete varchar(3)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.id_ArqueoFisico, 
		i.Cod_Billete,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Cod_Billete,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_D_I ' + 
	    CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
	    CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+REPLACE( AF.Cod_Turno,'''','')+''','END+
	    ''''+REPLACE(AD.Cod_Billete,'''','')+''', '+ 
	    CASE WHEN AD.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),AD.Cantidad)+',' END +
	    + ''''+REPLACE(COALESCE(AD.Cod_UsuarioAct,AD.Cod_UsuarioReg),'''','')+''';'
	    FROM            CAJ_ARQUEOFISICO_D AS AD INNER JOIN
								CAJ_ARQUEOFISICO AS AF ON AD.id_ArqueoFisico = AF.id_ArqueoFisico
	    WHERE AD.Cantidad <> 0 AND AD.id_ArqueoFisico=@id_ArqueoFisico AND AD.Cod_Billete=@Cod_Billete

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@id_ArqueoFisico)+'|'+@Cod_Billete, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Cod_Billete,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



--CAJ_ARQUEOFISICO_SALDO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_SALDO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_FOR_INSERT_UPDATE_TMP_REGISTRO_LOG
ON dbo.CAJ_ARQUEOFISICO_SALDO
AFTER INSERT,UPDATE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@id_ArqueoFisico int
	DECLARE   @Cod_Moneda varchar(3)
	DECLARE   @Tipo varchar(32)
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.id_ArqueoFisico, 
		i.Cod_Moneda,
		i.Tipo,
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Cod_Moneda,
		@Tipo,
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_ARQUEOFISICO_SALDO_I ' + 
	    CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
	    CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Turno,'''','')+''','END+
	    ''''+REPLACE(ASA.Cod_Moneda,'''','')+''','+ 
	    ''''+REPLACE(ASA.Tipo,'''','')+''','+ 
	    CASE WHEN ASA.Monto IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR(MAX),ASA.Monto)+',' END+ 
	    +''''+REPLACE(COALESCE(ASA.Cod_UsuarioAct,ASA.Cod_UsuarioReg),'''','')+''';'
	    FROM            CAJ_ARQUEOFISICO_SALDO AS ASA INNER JOIN
								CAJ_ARQUEOFISICO AS AF ON ASA.id_ArqueoFisico = AF.id_ArqueoFisico
	    WHERE ASA.id_ArqueoFisico=@id_ArqueoFisico AND ASA.Cod_Moneda=@Cod_Moneda AND ASA.Tipo=@Tipo

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - varchar
		    CONVERT(varchar(max),@id_ArqueoFisico)+'|'+@Cod_Moneda+'|'+@Tipo, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)

		FETCH NEXT FROM cursorbd INTO 
		@id_ArqueoFisico ,
		@Cod_Moneda,
		@Tipo,
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


--PRUEBAS

DECLARE @Sentencia VARCHAR(MAX)


SELECT @Sentencia= COALESCE(@Sentencia + ',CONVERT,', '')+ SC.NAME
FROM sys.objects SO INNER JOIN sys.columns SC
ON SO.OBJECT_ID = SC.OBJECT_ID
WHERE SO.TYPE = 'U' AND SO.NAME='CAJ_COMPROBANTE_PAGO'

SET @Sentencia='SELECT '+@Sentencia+' FROM CAJ_COMPROBANTE_PAGO where id_ComprobantePago=218842'
select @Sentencia as Sentencia


EXECUTE (@Sentencia)

SELECT id_ComprobantePago,Cod_Libro,Cod_Periodo,Cod_Caja,Cod_Turno,Cod_TipoOperacion,Cod_TipoComprobante,Serie,Numero,Id_Cliente,Cod_TipoDoc,Doc_Cliente,Nom_Cliente,Direccion_Cliente,FechaEmision,FechaVencimiento,FechaCancelacion,Glosa,TipoCambio,Flag_Anulado,Flag_Despachado,Cod_FormaPago,Descuento_Total,Cod_Moneda,Impuesto,Total,Obs_Comprobante,Id_GuiaRemision,GuiaRemision,id_ComprobanteRef,Cod_Plantilla,Nro_Ticketera,Cod_UsuarioVendedor,Cod_RegimenPercepcion,Tasa_Percepcion,Placa_Vehiculo,Cod_TipoDocReferencia,Nro_DocReferencia,Valor_Resumen,Valor_Firma,Cod_EstadoComprobante,MotivoAnulacion,Otros_Cargos,Otros_Tributos,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act FROM CAJ_COMPROBANTE_PAGO where id_ComprobantePago=218842


DECLARE @Sentencia VARCHAR(MAX)
SET @Sentencia='SELECT '
SELECT @Sentencia=  COALESCE(@Sentencia + 'CONVERT(varchar(max),', '') + col.NAME+')+''|''+' FROM (
SELECT  SC.NAME
FROM sys.objects SO INNER JOIN sys.columns SC
ON SO.OBJECT_ID = SC.OBJECT_ID
WHERE SO.TYPE = 'U' AND SO.NAME='CAJ_COMPROBANTE_PAGO') col 

SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1 )
SET @Sentencia=@Sentencia+' FROM CAJ_COMPROBANTE_PAGO'

select @Sentencia as Sentencia


DECLARE @Sentencia VARCHAR(MAX)
SET @Sentencia='SELECT '
SELECT @Sentencia=  COALESCE(@Sentencia + 'ISNULL(CONVERT(varchar(max),', '') + col.NAME+'),''NULL'')+''|''+' FROM (
SELECT  SC.NAME
FROM sys.objects SO INNER JOIN sys.columns SC
ON SO.OBJECT_ID = SC.OBJECT_ID
WHERE SO.TYPE = 'U' AND SO.NAME='CAJ_COMPROBANTE_PAGO') col 

SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1)
SET @Sentencia=@Sentencia+' FROM CAJ_COMPROBANTE_PAGO'

select @Sentencia as Sentencia



--PRI_SUCURSAL
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_SUCURSAL_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_SUCURSAL_IUD
GO

CREATE TRIGGER UTR_PRI_SUCURSAL_IUD
ON dbo.PRI_SUCURSAL
AFTER INSERT,UPDATE,DELETE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Sucursal varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime
	DECLARE   @NombreTabla varchar(max)='PRI_SUCURSAL'
	

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	DECLARE   @Exportacion bit = 0
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Sucursal, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN

	--Si esta habilitada la exportacion para almacenar en la tabla de 
	--exportaciones
	IF @Exportacion=1
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
	    ''''+REPLACE(i.Cod_Sucursal,'''','')+''','+
	    CASE WHEN i.Nom_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Nom_Sucursal,'''','') +''','END+
	    CASE WHEN i.Dir_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Dir_Sucursal,'''','') +''','END+
	    CASE WHEN i.Por_UtilidadMax IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Por_UtilidadMax) +','END+
	    CASE WHEN i.Por_UtilidadMin IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Por_UtilidadMin) +','END+
	    CASE WHEN i.Cod_UsuarioAdm IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_UsuarioAdm,'''','') +''','END+
	    CASE WHEN i.Cabecera_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cabecera_Pagina,'''','') +''','END+
	    CASE WHEN i.Pie_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Pie_Pagina,'''','') +''','END+
	    convert(varchar(max),i.Flag_Activo)+','+
	    CASE WHEN i.Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_Ubigeo,'''','') +''','END+
	    ''''+REPLACE(COALESCE(i.Cod_UsuarioAct,i.Cod_UsuarioReg),'''','')   +''';' 
	    FROM INSERTED i
	    WHERE i.Cod_Sucursal=@Cod_Sucursal

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    @NombreTabla, -- Nombre_Tabla - varchar
		    @Cod_Sucursal, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)
    END

    --Creamos la sentencia para insertar en nuestra BD de auditoria
    --De acuerdo a la accion varia el log
    DECLARE @Sentencia VARCHAR(MAX)
    DECLARE @SentenciaWhere varchar(max)=''
    --Insertar
    IF @Accion='INSERTAR'
    BEGIN
	   
	   SET @Sentencia='SELECT '
	   SELECT @Sentencia=  COALESCE(@Sentencia + 'ISNULL(CONVERT(varchar(max),', '') + col.NAME+'),''NULL'')+''|''+' FROM (
	   SELECT  SC.NAME
	   FROM sys.objects SO INNER JOIN sys.columns SC
	   ON SO.OBJECT_ID = SC.OBJECT_ID
	   WHERE SO.TYPE = 'U' AND SO.NAME=@NombreTabla) col 
	   SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1)
	   SET @Sentencia=@Sentencia+' FROM INSERTED '+@SentenciaWhere

	   EXECUTE (
	   'INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
	   (
		  Nombre_Tabla,
		  Id_Fila,
		  Accion,
		  Valor,
		  Fecha_Reg
	   )
	   VALUES
	   (
		  '+@NombreTabla+', -- Nombre_Tabla - varchar
		  '+@Cod_Sucursal+', -- Id_Fila - varchar
		  '+@Accion+', -- Accion - varchar
		  ''''+''(''+'''''+@Sentencia+'''''+'')''+'''', -- Valor - varchar
		  '+@Fecha+' -- Fecha_Reg - datetime
	   )'
	   )
    END

    IF @Accion='ACTUALIZAR'
    BEGIN
	   
	   SET @Sentencia='SELECT '
	   SELECT @Sentencia=  COALESCE(@Sentencia + 'ISNULL(CONVERT(varchar(max),', '') + col.NAME+'),''NULL'')+''|''+' FROM (
	   SELECT  SC.NAME
	   FROM sys.objects SO INNER JOIN sys.columns SC
	   ON SO.OBJECT_ID = SC.OBJECT_ID
	   WHERE SO.TYPE = 'U' AND SO.NAME=@NombreTabla) col 
	   SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1)
	   SET @Sentencia=@Sentencia+' FROM INSERTED '+@SentenciaWhere

	   EXECUTE (
	   'INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
	   (
		  Nombre_Tabla,
		  Id_Fila,
		  Accion,
		  Valor,
		  Fecha_Reg
	   )
	   VALUES
	   (
		  '+@NombreTabla+', -- Nombre_Tabla - varchar
		  '+@Cod_Sucursal+', -- Id_Fila - varchar
		  '+@Accion+', -- Accion - varchar
		  ''''+''('''+@Sentencia+''')''+'''', -- Valor - varchar
		  '+@Fecha+' -- Fecha_Reg - datetime
	   )'
	   )
    END
    --Actualizar
    --Eliminar

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO 


--PRI_SUCURSAL
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_SUCURSAL_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_SUCURSAL_IUD
GO

CREATE TRIGGER UTR_PRI_SUCURSAL_IUD
ON dbo.PRI_SUCURSAL
AFTER INSERT,UPDATE,DELETE
AS 
BEGIN
	
	--Variables de tabla
	DECLARE	@Cod_Sucursal varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Fecha_Act datetime
	DECLARE   @NombreTabla varchar(max)='PRI_SUCURSAL'
	

	--Variables Generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	DECLARE   @Exportacion bit = 0
	

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	DECLARE cursorbd CURSOR LOCAL FOR
		SELECT 
		i.Cod_Sucursal, 
		i.Fecha_Reg, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN

	--Si esta habilitada la exportacion para almacenar en la tabla de 
	--exportaciones
	IF @Exportacion=1
	BEGIN
	    SELECT @Script= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
	    ''''+REPLACE(i.Cod_Sucursal,'''','')+''','+
	    CASE WHEN i.Nom_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Nom_Sucursal,'''','') +''','END+
	    CASE WHEN i.Dir_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Dir_Sucursal,'''','') +''','END+
	    CASE WHEN i.Por_UtilidadMax IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Por_UtilidadMax) +','END+
	    CASE WHEN i.Por_UtilidadMin IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Por_UtilidadMin) +','END+
	    CASE WHEN i.Cod_UsuarioAdm IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_UsuarioAdm,'''','') +''','END+
	    CASE WHEN i.Cabecera_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cabecera_Pagina,'''','') +''','END+
	    CASE WHEN i.Pie_Pagina IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Pie_Pagina,'''','') +''','END+
	    convert(varchar(max),i.Flag_Activo)+','+
	    CASE WHEN i.Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_Ubigeo,'''','') +''','END+
	    ''''+REPLACE(COALESCE(i.Cod_UsuarioAct,i.Cod_UsuarioReg),'''','')   +''';' 
	    FROM INSERTED i
	    WHERE i.Cod_Sucursal=@Cod_Sucursal

	    SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
		INSERT dbo.TMP_REGISTRO_LOG
		(
		    --Id,
		    Nombre_Tabla,
		    Id_Fila,
		    Accion,
		    Script,
		    Fecha_Reg
		)
		VALUES
		(
		    --NULL, -- Id - uniqueidentifier
		    @NombreTabla, -- Nombre_Tabla - varchar
		    @Cod_Sucursal, -- Id_Fila - varchar
		    @Accion, -- Accion - varchar
		    @Script, -- Script - varchar
		    @Fecha -- Fecha_Reg - datetime
		)
    END

    --Creamos la sentencia para insertar en nuestra BD de auditoria
    --De acuerdo a la accion varia el log
    DECLARE @Sentencia nvarchar(MAX)
    DECLARE @SentenciaWhere varchar(max)='WHERE Cod_Sucursal='+''''+@Cod_Sucursal+''''
    DECLARE @Salida NVARCHAR(max)
    DECLARE @Parametros NVARCHAR(max)= N'@Salida NVARCHAR(MAX) OUTPUT';
    --Insertar
    IF @Accion='INSERTAR'
    BEGIN
	   
	   SET @Sentencia='SELECT @Salida='
	   SELECT @Sentencia=  COALESCE(@Sentencia + 'ISNULL(CONVERT(varchar(max),', '') + col.NAME+'),''NULL'')+''|''+' FROM (
	   SELECT  SC.NAME
	   FROM sys.objects SO INNER JOIN sys.columns SC
	   ON SO.OBJECT_ID = SC.OBJECT_ID
	   WHERE SO.TYPE = 'U' AND SO.NAME=@NombreTabla) col 
	   SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1)
	   SET @Sentencia=@Sentencia+' FROM PRI_SUCURSAL '+@SentenciaWhere

	   EXECUTE SP_EXECUTESQL @Sentencia, @Parametros, @Salida = @Salida OUTPUT;
	   

    END

    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
    BEGIN
	   SET @Sentencia='SELECT @Salida='
	   SELECT @Sentencia=  COALESCE(@Sentencia + 'ISNULL(CONVERT(varchar(max),', '') + col.NAME+'),''NULL'')+''|''+' FROM (
	   SELECT  SC.NAME
	   FROM sys.objects SO INNER JOIN sys.columns SC
	   ON SO.OBJECT_ID = SC.OBJECT_ID
	   WHERE SO.TYPE = 'U' AND SO.NAME=@NombreTabla) col 
	   SET @Sentencia=SUBSTRING (@Sentencia, 1, Len(@Sentencia) - 1)
	   SET @Sentencia=@Sentencia+' FROM PRI_SUCURSAL '+@SentenciaWhere

	   EXECUTE SP_EXECUTESQL @Sentencia, @Parametros, @Salida = @Salida OUTPUT;


    END

    INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
	   (
	       Nombre_Tabla,
	       Id_Fila,
	       Accion,
	       Valor,
	       Fecha_Reg
	   )
	   VALUES
	   (
	       @NombreTabla, -- Nombre_Tabla - varchar
	       @Cod_Sucursal, -- Id_Fila - varchar
	       @Accion, -- Accion - varchar
	       @Salida, -- Valor - varchar
	       @Fecha -- Fecha_Reg - datetime
	   )

		FETCH NEXT FROM cursorbd INTO 
		@Cod_Sucursal, 
		@Fecha_Reg, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO 