--Creamos nuestra tabla temporal donde se insertan los datos de las inserciones, modificaciones y eliminacion
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_REGISTRO_LOG' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_REGISTRO_LOG (
	Id int IDENTITY(1,1)  PRIMARY KEY,
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
	Id int IDENTITY(1,1)  PRIMARY KEY,
	Nombre_Tabla varchar(max) ,
	Id_Fila varchar(max)  ,
	Accion varchar(max) ,
	Script varchar(max),
	Fecha_Reg datetime ,
	Fecha_Reg_Insercion datetime)
END
GO



--PROCEDIMIENTO DE GUARDADO
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_REGISTRO_LOG_G' 
	 AND type = 'P'
)
DROP PROCEDURE USP_TMP_REGISTRO_LOG_G
GO
CREATE  PROCEDURE USP_TMP_REGISTRO_LOG_G 
	@NombreTabla varchar(MAX), 
	@Id_Fila varchar(max),
	@Accion	varchar(max), 
	@Script varchar(max), 
	@Fecha_Reg	datetime
WITH ENCRYPTION
AS
BEGIN
	INSERT dbo.TMP_REGISTRO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Fila,
	    Accion,
	    Script,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    @NombreTabla, -- Nombre_Tabla - varchar
	    @Id_Fila, -- Id_Fila - varchar
	    @Accion, -- Accion - varchar
		@Script, -- Script - varchar
	    @Fecha_Reg -- Fecha_Reg - datetime
	)
END
GO



--Creacion USP_CrearLinkedServerSQLtoSQL
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CrearLinkedServerSQLtoSQL' 
	 AND type = 'P'
)
DROP PROCEDURE USP_CrearLinkedServerSQLtoSQL
GO
CREATE PROCEDURE USP_CrearLinkedServerSQLtoSQL
	@Nombre nvarchar(4000),
	@Servidor nvarchar(4000),
	@BaseDatos nvarchar(4000),
	@Usuario nvarchar(4000),
	@Contraseña nvarchar(4000)
AS 
BEGIN
	IF  exists(select * from sys.servers where name = @Nombre)
	BEGIN
		execute sp_dropserver @Nombre, 'droplogins';
	END
	-- Crear linked server
	EXEC master.dbo.sp_addlinkedserver @server = @Nombre,
	@srvproduct=N'SQL',
	@provider=N'SQLNCLI11', 
	@datasrc=@Servidor, 
	@catalog=@BaseDatos
	-- Usuario y contraseña
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=@Nombre,
	@useself=N'False',
	@locallogin=NULL,
	@rmtuser=@Usuario,
	@rmtpassword=@Contraseña
	-- Propiedades de conexion
	EXEC MASTER.dbo.sp_serveroption @server = @Nombre
	,@optname = 'data access'
	,@optvalue = 'true'
	EXEC MASTER.dbo.sp_serveroption @server = @Nombre
	,@optname = 'use remote collation'
	,@optvalue = 'true'
	EXEC MASTER.dbo.sp_serveroption @server = @Nombre
	,@optname = 'rpc'
	,@optvalue = 'true'
	EXEC MASTER.dbo.sp_serveroption @server = @Nombre
	,@optname = 'rpc out'
	,@optvalue = 'true'

END
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE

GO

 --Linked SERVER LOcal
 DECLARE @NombreLinkedServer varchar(max)= N'PALERregistro' --Por defecto
 DECLARE @ServidorLinkedServer varchar(max)= N'.\PALEHOST2' --Nombre del servidor remoto
 DECLARE @NombreBaseDeDatos varchar(max)= (SELECT DB_NAME() AS [Base de datos actual]) --Nombre de la base de datos actual, cambiar si es otro nombre
 DECLARE @NombreUsuarioServidor varchar(max)= N'sa' --Por defecto
 DECLARE @NombrePassServidor varchar(max)= N'paleC0nsult0res' --Por defecto
 exec USP_CrearLinkedServerSQLtoSQL @NombreLinkedServer,@ServidorLinkedServer,@NombreBaseDeDatos,@NombreUsuarioServidor,@NombrePassServidor

 --Linked server al servidor remoto
 SET @NombreLinkedServer = N'PALERPlink' --Por defecto
 SET @ServidorLinkedServer = N'192.168.1.100\PALEHOST' --Nombre del servidor remoto
 SET @NombreBaseDeDatos = (SELECT DB_NAME() AS [Base de datos actual]) --Nombre de la base de datos actual, cambiar si es otro nombre
 SET @NombreUsuarioServidor = N'sa' --Por defecto
 SET @NombrePassServidor = N'paleC0nsult0res' --Por defecto
 exec USP_CrearLinkedServerSQLtoSQL @NombreLinkedServer,@ServidorLinkedServer,@NombreBaseDeDatos,@NombreUsuarioServidor,@NombrePassServidor

 GO


--TRIGGERS
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_PRI_SUCURSAL_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.PRI_SUCURSAL
AFTER INSERT,UPDATE
AS 
BEGIN
	DECLARE	@Cod_Sucursal varchar(32) 
	DECLARE	@Nom_Sucursal varchar(32) 
	DECLARE	@Dir_Sucursal varchar(512) 
	DECLARE	@Por_UtilidadMax numeric(5,2)
	DECLARE	@Por_UtilidadMin numeric(5,2)
	DECLARE	@Cod_UsuarioAdm varchar(32) 
	DECLARE	@Cabecera_Pagina varchar(1024) 
	DECLARE	@Pie_Pagina varchar(1024) 
	DECLARE	@Flag_Activo bit
	DECLARE	@Cod_Ubigeo varchar(32) 
	DECLARE	@Cod_UsuarioReg varchar(32) 
	DECLARE	@Fecha_Reg datetime
	DECLARE	@Cod_UsuarioAct varchar(32) 
	DECLARE	@Fecha_Act datetime
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	DECLARE   @Sentencia varchar(max)

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
		i.Nom_Sucursal, 
		i.Dir_Sucursal, 
		i.Por_UtilidadMax, 
		i.Por_UtilidadMin, 
		i.Cod_UsuarioAdm, 
		i.Cabecera_Pagina, 
		i.Pie_Pagina, 
		i.Flag_Activo, 
		i.Cod_Ubigeo, 
		i.Cod_UsuarioReg, 
		i.Fecha_Reg, 
		i.Cod_UsuarioAct, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
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
		@Cod_UsuarioReg, 
		@Fecha_Reg, 
		@Cod_UsuarioAct, 
		@Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SET @Script = 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
		--''''+@Cod_Sucursal+''','+
		--CASE WHEN @Nom_Sucursal IS NULL THEN 'NULL,' ELSE ''''+@Nom_Sucursal +''','END+
		--CASE WHEN @Dir_Sucursal IS NULL THEN 'NULL,' ELSE ''''+@Dir_Sucursal +''','END+
		--CASE WHEN @Por_UtilidadMax IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), @Por_UtilidadMax) +','END+
		--CASE WHEN @Por_UtilidadMin IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), @Por_UtilidadMin) +','END+
		--CASE WHEN @Cod_UsuarioAdm IS NULL THEN 'NULL,' ELSE ''''+@Cod_UsuarioAdm +''','END+
		--CASE WHEN @Cabecera_Pagina IS NULL THEN 'NULL,' ELSE ''''+@Cabecera_Pagina +''','END+
		--CASE WHEN @Pie_Pagina IS NULL THEN 'NULL,' ELSE ''''+@Pie_Pagina +''','END+
		--convert(varchar(max),@Flag_Activo)+','+
		--CASE WHEN @Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+@Cod_Ubigeo +''','END+
		--''''+COALESCE(@Cod_UsuarioAct,@Cod_UsuarioReg)   +''';' 
		SET @Script =
		@Cod_Sucursal+'|'+
		CASE WHEN @Nom_Sucursal IS NULL THEN 'NULL|' ELSE @Nom_Sucursal +'|'END+
		CASE WHEN @Dir_Sucursal IS NULL THEN 'NULL|' ELSE REPLACE(@Dir_Sucursal,'''','') +'|'END+
		CASE WHEN @Por_UtilidadMax IS NULL THEN 'NULL|' ELSE CONVERT(varchar(max), @Por_UtilidadMax) +'|'END+
		CASE WHEN @Por_UtilidadMin IS NULL THEN 'NULL|' ELSE CONVERT(varchar(max), @Por_UtilidadMin) +'|'END+
		CASE WHEN @Cod_UsuarioAdm IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_UsuarioAdm,'''','') +'|'END+
		CASE WHEN @Cabecera_Pagina IS NULL THEN 'NULL|' ELSE REPLACE(@Cabecera_Pagina,'''','') +'|'END+
		CASE WHEN @Pie_Pagina IS NULL THEN 'NULL,' ELSE REPLACE(@Pie_Pagina,'''','') +'|'END+
		convert(varchar(max),@Flag_Activo)+'|'+
		CASE WHEN @Cod_Ubigeo IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_Ubigeo,'''','') +'|'END+
		REPLACE(COALESCE(@Cod_UsuarioAct,@Cod_UsuarioReg),'''','') 
		SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())

		SET @Sentencia = 'PALERregistro.'+@NombreBD+'.dbo.USP_TMP_REGISTRO_LOG_G '+
		''''+'PRI_SUCURSAL'+''''+','+
		''''+@Cod_Sucursal+''''+','+
		''''+@Accion+''''+','+
		''''+@Script+''''+','+
		''''+CONVERT(varchar(max),@Fecha,121)+''''
		EXECUTE (@Sentencia)

		--EXEC PALERregistro.PALERPpuquin.dbo.USP_TMP_REGISTRO_LOG_G 'PRI_SUCURSAL',@Cod_Sucursal,@Accion,@Script,@Fecha
		FETCH NEXT FROM cursorbd INTO 
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
		@Cod_UsuarioReg, 
		@Fecha_Reg, 
		@Cod_UsuarioAct, 
		@Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_PRI_ESTABLECIMIENTOS_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.PRI_ESTABLECIMIENTOS
AFTER INSERT,UPDATE
AS 
BEGIN
	--Variables de tabla
	DECLARE @Cod_Establecimientos varchar(32)
	DECLARE @Id_ClienteProveedor int 
	DECLARE @Des_Establecimiento varchar(512)
     DECLARE @Cod_TipoEstablecimiento varchar(5)
     DECLARE @Direccion varchar(1024)
     DECLARE @Telefono varchar(102)
     DECLARE @Obs_Establecimiento varchar(1024)
     DECLARE @Cod_Ubigeo varchar(32)
     DECLARE @Cod_UsuarioReg varchar(32)
     DECLARE @Fecha_Reg datetime
     DECLARE @Cod_UsuarioAct varchar(32)
     DECLARE @Fecha_Act datetime

	--Variables generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	DECLARE   @Sentencia varchar(max)

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
		    i.Des_Establecimiento, 
		    i.Cod_TipoEstablecimiento, 
		    i.Direccion, 
		    i.Telefono, 
		    i.Obs_Establecimiento, 
		    i.Cod_Ubigeo, 
		    i.Cod_UsuarioReg, 
		    i.Fecha_Reg, 
		    i.Cod_UsuarioAct, 
		    i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
	    @Cod_Establecimientos, 
	    @Id_ClienteProveedor, 
	    @Des_Establecimiento, 
	    @Cod_TipoEstablecimiento,
	    @Direccion, 
	    @Telefono, 
	    @Obs_Establecimiento,
	    @Cod_Ubigeo, 
	    @Cod_UsuarioReg, 
	    @Fecha_Reg, 
	    @Cod_UsuarioAct, 
	    @Fecha_Act
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @Script =
		@Cod_Establecimientos+'|'+
		CONVERT(varchar(max),@Id_ClienteProveedor)+'|'+
		CASE WHEN @Des_Establecimiento IS NULL THEN 'NULL|' ELSE REPLACE(@Des_Establecimiento,'''','') +'|'END+
		CASE WHEN @Cod_TipoEstablecimiento IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_TipoEstablecimiento,'''','') +'|'END+
		CASE WHEN @Direccion IS NULL THEN 'NULL|' ELSE REPLACE(@Direccion,'''','') +'|'END+
		CASE WHEN @Telefono IS NULL THEN 'NULL|' ELSE REPLACE(@Telefono,'''','') +'|'END+
		CASE WHEN @Obs_Establecimiento IS NULL THEN 'NULL|' ELSE REPLACE(@Obs_Establecimiento,'''','') +'|'END+
		CASE WHEN @Cod_Ubigeo IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_Ubigeo,'''','') +'|'END+
		REPLACE(COALESCE(@Cod_UsuarioAct,@Cod_UsuarioReg),'''','') 
		SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())

		SET @Sentencia = 'PALERregistro.'+@NombreBD+'.dbo.USP_TMP_REGISTRO_LOG_G '+
		''''+'PRI_ESTABLECIMIENTOS'+''''+','+
		''''+@Cod_Establecimientos+'-'+@Id_ClienteProveedor+''''+','+
		''''+@Accion+''''+','+
		''''+@Script+''''+','+
		''''+CONVERT(varchar(max),@Fecha,121)+''''
		EXECUTE (@Sentencia)

		--EXEC PALERregistro.PALERPpuquin.dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G 'PRI_SUCURSAL',@Cod_Sucursal,@Accion,@Script,@Fecha
		FETCH NEXT FROM cursorbd INTO 
		@Cod_Establecimientos, 
		@Id_ClienteProveedor, 
		@Des_Establecimiento, 
		@Cod_TipoEstablecimiento,
		@Direccion, 
		@Telefono, 
		@Obs_Establecimiento,
		@Cod_Ubigeo, 
		@Cod_UsuarioReg, 
		@Fecha_Reg, 
		@Cod_UsuarioAct, 
		@Fecha_Act
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_ALM_ALMACEN_FOR_INSERT_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.ALM_ALMACEN
AFTER INSERT,UPDATE
AS 
BEGIN
	--Variables de tabla
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Des_Almacen varchar(512)
	DECLARE @Des_CortaAlmacen varchar(64)
	DECLARE @Cod_TipoAlmacen varchar(5)
	DECLARE @Flag_Principal bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Cod_UsuarioAct varchar(32)
	DECLARE @Fecha_Act datetime

	--Variables generales
	DECLARE   @Script varchar(max)
	DECLARE   @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE   @Fecha datetime
	DECLARE   @Accion varchar(MAX) 
	DECLARE   @Sentencia varchar(max)

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
		i.Des_Almacen, 
		i.Des_CortaAlmacen, 
		i.Cod_TipoAlmacen, 
		i.Flag_Principal, 
		i.Cod_UsuarioReg, 
		i.Fecha_Reg, 
		i.Cod_UsuarioAct, 
		i.Fecha_Act 
		FROM INSERTED i
	OPEN cursorbd 
	FETCH NEXT FROM cursorbd INTO 
	    @Cod_Almacen,
	    @Des_Almacen, 
	    @Des_CortaAlmacen, 
	    @Cod_TipoAlmacen, 
	    @Flag_Principal, 
	    @Cod_UsuarioReg, 
	    @Fecha_Reg, 
	    @Cod_UsuarioAct, 
	    @Fecha_Act 
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @Script =
		@Cod_Almacen+'|'+
		CASE WHEN @Des_Almacen IS NULL THEN 'NULL|' ELSE REPLACE(@Des_Almacen,'''','') +'|'END+
		CASE WHEN @Des_CortaAlmacen IS NULL THEN 'NULL|' ELSE REPLACE(@Des_CortaAlmacen,'''','') +'|'END+
		CASE WHEN @Cod_TipoAlmacen IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_TipoAlmacen,'''','') +'|'END+
		CASE WHEN @Cod_TipoAlmacen IS NULL THEN 'NULL|' ELSE REPLACE(@Cod_TipoAlmacen,'''','') +'|'END+
		CONVERT(varchar(max),@Flag_Principal)+'|'+
		REPLACE(COALESCE(@Cod_UsuarioAct,@Cod_UsuarioReg),'''','') 
		SET @Fecha= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())

		SET @Sentencia = 'PALERregistro.'+@NombreBD+'.dbo.USP_TMP_REGISTRO_LOG_G '+
		''''+'PRI_ESTABLECIMIENTOS'+''''+','+
		''''+@Cod_Almacen+','+
		''''+@Accion+''''+','+
		''''+@Script+''''+','+
		''''+CONVERT(varchar(max),@Fecha,121)+''''
		EXECUTE (@Sentencia)

		--EXEC PALERregistro.PALERPpuquin.dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G 'PRI_SUCURSAL',@Cod_Sucursal,@Accion,@Script,@Fecha
		FETCH NEXT FROM cursorbd INTO 
		   @Cod_Almacen,
		   @Des_Almacen, 
		   @Des_CortaAlmacen, 
		   @Cod_TipoAlmacen, 
		   @Flag_Principal, 
		   @Cod_UsuarioReg, 
		   @Fecha_Reg, 
		   @Cod_UsuarioAct, 
		   @Fecha_Act 
	END
	CLOSE cursorbd;
	DEALLOCATE cursorbd
END
GO



 
 --procedimento de guardado
 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_TMP_REGISTRO_LOG_ExportarPrimerElemento' AND type = 'P')
DROP PROCEDURE USP_TMP_REGISTRO_LOG_ExportarPrimerElemento
go
CREATE PROCEDURE USP_TMP_REGISTRO_LOG_ExportarPrimerElemento
AS
BEGIN
	
	--Variables generales
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	--Recuperamos las variables principales
	DECLARE @Id int
	DECLARE @Nombre_Tabla varchar(max) 
	DECLARE @Id_Fila varchar(max)
	DECLARE @Variables varchar(max)
	DECLARE @Sentencia varchar(max) ='SELECT'
	DECLARE @Accion varchar(max) 
	DECLARE @Fecha_Reg datetime 
	--Recuperamos el primer objeto de la cola y almacenamos en las variables
	SELECT TOP 1  
		@Id=tcrl.id,
		@Nombre_Tabla=tcrl.Nombre_Tabla,
		@Id_Fila=tcrl.Id_Fila,
		@Accion=tcrl.Accion,
		@Variables = tcrl.Script,
		@Fecha_Reg = tcrl.Fecha_Reg
	FROM dbo.TMP_REGISTRO_LOG_H tcrl

	IF @Id IS NOT NULL
	BEGIN
	   IF @Nombre_Tabla = 'PRI_SUCURSAL'
	   BEGIN
		  SET @Sentencia= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_SUCURSAL_I ' +
		  ''''+dbo.UFN_Split(@Variables,'|',0)+''','+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',1) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',1) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',2) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',2) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',3) = '' THEN 'NULL,' ELSE dbo.UFN_Split(@Variables,'|',3) +','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',4) = '' THEN 'NULL,' ELSE dbo.UFN_Split(@Variables,'|',4) +','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',5) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',5) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',6) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',6) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',7) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',7) +''','END+
		  dbo.UFN_Split(@Variables,'|',8)+','+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',9) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',9) +''','END+
		  ''''+dbo.UFN_Split(@Variables,'|',10)   +''';' 
	   END

	   IF @Nombre_Tabla = 'PRI_ESTABLECIMIENTOS'
	   BEGIN
		  SET @Sentencia= SELECT TOP 1 'PALERPlink.'+@NombreBD+'.dbo.PRI_ESTABLECIMIENTOS_I ' +
		  ''''+dbo.UFN_Split(@Variables,'|',0)+''','+
		  CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Cod_TipoDocumento+''','END+
		  CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ pcp.Nro_Documento+''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',2) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',2) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',3) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',3) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',4) = '' THEN 'NULL,' ELSE dbo.UFN_Split(@Variables,'|',4) +','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',5) = '' THEN 'NULL,' ELSE dbo.UFN_Split(@Variables,'|',5) +','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',6) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',6) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',7) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',7) +''','END+
		  CASE WHEN dbo.UFN_Split(@Variables,'|',8) = '' THEN 'NULL,' ELSE ''''+dbo.UFN_Split(@Variables,'|',8) +''';'END+
		  FROM dbo.PRI_CLIENTE_PROVEEDOR pcp 
		  WHERE pcp.Id_ClienteProveedor=dbo.UFN_Split(@Variables,'|',1)
	   END
	   

		--Ejecutamos la sentencia
		BEGIN TRY
			EXECUTE(@Sentencia)
			--Si es exitosa entonces procedemos a eliminar el registro y almacenarlo en la tabla de historial
			BEGIN TRANSACTION 
				BEGIN TRY
					INSERT dbo.TMP_REGISTRO_LOG_H
					(
					    --Id - this column value is auto-generated
					    Nombre_Tabla,
					    Id_Fila,
					    Accion,
					    Script,
					    Fecha_Reg,
					    Fecha_Reg_Insercion
					)
					VALUES
					(
					    -- Id - int
					    @NombreBD, -- Nombre_Tabla - varchar
					    @Id_Fila, -- Id_Fila - varchar
					    @Accion, -- Accion - varchar
					    @Variables, -- Script - varchar
					    @Fecha_Reg, -- Fecha_Reg - datetime
					    GETDATE() -- Fecha_Reg_Insercion - datetime
					)

					DELETE dbo.TMP_REGISTRO_LOG_H WHERE @Id=dbo.TMP_REGISTRO_LOG_H.Id

					COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
				END CATCH
				
		END TRY
		BEGIN CATCH
			SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
			DECLARE @Resultado varchar(max) = 'master..xp_cmdshell ' +''''+
			REPLACE(REPLACE('echo ERROR DURANTE LA EJECUCION DEL USP : '+ERROR_MESSAGE()+' Fecha: '+CONVERT(varchar(max),GETDATE(),121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
			EXECUTE(@Resultado)
		END CATCH
	END
END
GO  