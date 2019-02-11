--Autor Erwin M. Rayme Chambi
--09-03-2018 version 5

--Base de datos de auditoria y tabla
--Funciona siempre activandose despues de cada accion
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'remote query timeout', 0 ;  
GO
RECONFIGURE
GO

IF NOT EXISTS (SELECT * 
	   FROM   master..sysdatabases 
	   WHERE  name = N'PALERP_Auditoria')
	   CREATE DATABASE PALERP_Auditoria
GO

--Tabla auditoria
IF NOT EXISTS(SELECT name 
	  FROM 	PALERP_Auditoria.dbo.sysobjects 
	  WHERE  name = N'PRI_AUDITORIA' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE  PALERP_Auditoria.dbo.PRI_AUDITORIA (
	Id uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Nombre_BD varchar(max),
	Nombre_Tabla varchar(max) ,
	Id_Fila varchar(max)  ,
	Accion varchar(max) ,
	Valor varchar(max),
	Fecha_Reg datetime )
END
GO

EXEC USP_PAR_TABLA_G '118','CORREOS','Almacena las configuracion de los correo electronicos.','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '118','001','Tipo_Correo','El tipo de Correo se refiere al proveedor: GMAIL, HOTMAIL, ...','CADENA',0,11,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '118','002','Correo','Correo del usuario','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '118','003','Contraseña','Contraseña del usuario','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '118','004','Tipo_Uso','Tipo de Uso: COMPROBANTE, ENVIO, ERROR, NOTIFICACION','CADENA',0,16,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '118','005','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '118';
GO


--Crea un linked server sql a sql con el proveedor SQLNCL11 por defecto
--exec USP_CrearLinkedServerSQLtoSQL N'PALERPlink',N'97.74.237.236\PALEHOST',N'PALERPseminario',N'sa',N'paleC0nsult0res'
--exec USP_CrearLinkedServerSQLtoSQL N'PALERPlink',N'petrourubamba.sytes.net',N'PALERPurubamba',N'sa',N'paleC0nsult0res'
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

--Creamos nuestra tabla para para alamacenar la informacion de la exportacion
--SOlo puede existir una configuracion habilitada, si hay dos dara error
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ExportarDatos' AND type = 'P')
DROP PROCEDURE USP_ExportarDatos
GO
DECLARE @Nombre_BD varchar(max)=(SELECT DB_NAME())
DECLARE @NombreEmpresa VARCHAR(max)=(SELECT pe.RUC+'-'+pe.RazonSocial IdentificadorEmpresa FROM dbo.PRI_EMPRESA pe)
EXEC USP_PAR_TABLA_G '120','CONFIGURACION_EXPORTACION','Almacena la configuracion necesaria para realizar la exportacion de datos a servidores remotos','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','001','Estado','Indica si esta habilitada o no la opcionde exportacion de datos para la empresa','BOLEANO',0,1,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','002','Identificador_Empresa','Identificador de nombre de la empresa y sucursal','CADENA',0,128,@NombreEmpresa,0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','003','Linked_Server','Indica el nombre del linked server a usar','CADENA',0,128,@Nombre_BD,0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','004','BD_Remota','Nombre de la base de datos destino del linked server','CADENA',0,128,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','005','Correo_Recepcion','Indica el correo donde se reciben las notificaciones','CADENA',0,128,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','006','Ip_Remota','Almacena la direccion de ip remota a ejecutar para el PING','CADENA',0,128,'www.google.com',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','007','Intentos','Numero de intentos antes de enviar una notificacion de correo','ENTERO',0,5,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '120','008','Habilitado','Indica si la configuracion esta habilitada','BOLEANO',0,1,'',1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '120';

IF NOT EXISTS (SELECT vce.* FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
BEGIN
    EXEC USP_PAR_FILA_G '120','001',1,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','002',1,@NombreEmpresa,NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','003',1,'PALERPlink',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','004',1,@Nombre_BD,NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','005',1,'soporte@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','006',1,'www.google.com',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','007',1,NULL,NULL,100,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','008',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
GO

IF NOT EXISTS (SELECT vc.* FROM dbo.VIS_CORREOS vc WHERE vc.Tipo_Uso='EXPORTACION' AND vc.Estado=1)
BEGIN
    DECLARE @maxFila int 
    IF EXISTS (SELECT * FROM dbo.PAR_FILA pf WHERE pf.Cod_Tabla='118')
    BEGIN
	   SET @maxFila=(SELECT max(pf.Cod_Fila) FROM dbo.PAR_FILA pf WHERE pf.Cod_Tabla='118')+1
    END
    ELSE
    BEGIN
	   SET @maxFila=1
    END
    EXEC USP_PAR_FILA_G '118','001',@maxFila,'PALERP',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','002',@maxFila,'soporte@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','003',@maxFila,'soporte321',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','004',@maxFila,'EXPORTACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','005',@maxFila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
GO


--Metodo que trae la conficguracion de la exportacion
--Deberia de botar solo uno por tipo
--la configuracion de la exportacion debe ser 1 fila con todos los datos necesarios
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_Exportacion_TraerConfiguracion' 
	 AND type = 'P'
)
DROP PROCEDURE USP_Exportacion_TraerConfiguracion
GO
CREATE PROCEDURE USP_Exportacion_TraerConfiguracion
WITH ENCRYPTION
AS 
BEGIN
	SELECT DISTINCT a.Identificador_Empresa,a.Estado,a.Linked_Server,a.BD_Remota,a.Ip_Remota,a.Intentos,a.Correo_Recepcion,b.Tipo_Correo Servidor_CorreoEnvio,b.Correo Correo_Envio,b.Contraseña Pass_CorreoEnvio,
    b.Correo 
    FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY vce.Nro ASC) AS id, vce.*
    FROM VIS_CONFIGURACION_EXPORTACION vce WHERE vce.Habilitado=1
    ) a
    FULL OUTER JOIN
    (
    SELECT ROW_NUMBER() OVER (ORDER BY vc.Nro ASC) AS id, vc.*
    FROM VIS_CORREOS vc WHERE vc.Tipo_Uso='EXPORTACION' and vc.Estado=1
    ) b ON b.id=a.id
END
GO 

GO


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

--TRIGGERS
--ALM_ALMACEN
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_IUD
GO

CREATE TRIGGER UTR_ALM_ALMACEN_IUD
ON dbo.ALM_ALMACEN
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='ALM_ALMACEN'
	--Variables de tabla secundarias
	DECLARE @Des_Almacen varchar(512)
	DECLARE @Des_CortaAlmacen varchar(64)
	DECLARE @Cod_TipoAlmacen varchar(5)
	DECLARE @Flag_Principal bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @Fecha datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			 SELECT @Script='USP_ALM_ALMACEN_I ' +
			 CASE WHEN aa.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Cod_Almacen,'''','')+''','END+
			 CASE WHEN aa.Des_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Des_Almacen,'''','')+''','END+
			 CASE WHEN aa.Des_CortaAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Des_CortaAlmacen,'''','')+''','END+
			 CASE WHEN aa.Cod_TipoAlmacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(aa.Cod_TipoAlmacen,'''','')+''','END+
			 CONVERT(VARCHAR(MAX),aa.Flag_Principal)+','+
			 ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
			 FROM INSERTED aa WHERE @Cod_Almacen=aa.Cod_Almacen

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
			   CONCAT('',@Cod_Almacen), -- Id_Fila - varchar
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

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
		DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Almacen,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN

			 SELECT @Script='USP_ALM_ALMACEN_D ' +
			 CASE WHEN d.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Cod_Almacen,'''','')+''','END+
			 ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			 FROM DELETED d WHERE @Cod_Almacen=d.Cod_Almacen

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
			   CONCAT('',@Cod_Almacen), -- Id_Fila - varchar
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

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Almacen,'|' ,
			 @Des_Almacen,'|' ,
			 @Des_CortaAlmacen,'|' ,
			 @Cod_TipoAlmacen,'|' ,
			 @Flag_Principal,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Almacen,
			 d.Des_Almacen,
			 d.Des_CortaAlmacen,
			 d.Cod_TipoAlmacen,
			 d.Flag_Principal,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Almacen,'|' ,
			 @Des_Almacen,'|' ,
			 @Des_CortaAlmacen,'|' ,
			 @Cod_TipoAlmacen,'|' ,
			 @Flag_Principal,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

END
GO

--ALM_ALMACEN_MOV
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_MOV_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_MOV_IUD
GO

CREATE TRIGGER UTR_ALM_ALMACEN_MOV_IUD
ON dbo.ALM_ALMACEN_MOV
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_AlmacenMov int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='ALM_ALMACEN_MOV'
	--Variables de tabla secundarias
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cod_TipoOperacion varchar(5)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(5)
	DECLARE @Numero varchar(32)
	DECLARE @Fecha datetime
	DECLARE @Motivo varchar(512)
	DECLARE @Id_ComprobantePago int
	DECLARE @Flag_Anulado bit
	DECLARE @Obs_AlmacenMov xml
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_AlmacenMov,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_ALM_ALMACEN_MOV_I '+ 
			  CASE WHEN M.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_Almacen,'''','') +''',' END +
			  CASE WHEN M.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_TipoOperacion,'''','') +''',' END +
			  CASE WHEN M.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_Turno,'''','') +''',' END +
			  CASE WHEN M.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_TipoComprobante,'''','') +''',' END +
			  CASE WHEN M.Serie IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Serie,'''','') +''',' END +
			  CASE WHEN M.Numero IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Numero,'''','') +''',' END +
			  CASE WHEN M.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),M.Fecha,121)+''','END+ 
			  CASE WHEN M.Motivo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Motivo,'''','') +''',' END +
			  CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			  CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			  CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			  CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Doc_Cliente,'''','')+''',' END +
			  CONVERT(VARCHAR(MAX),M.Flag_Anulado)+','+
			  CASE WHEN M.Obs_AlmacenMov IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),M.Obs_AlmacenMov),'''','')+''','END+ 
			  ''''+REPLACE(COALESCE(M.Cod_UsuarioAct,M.Cod_UsuarioReg),'''','')+ ''';'
			  FROM INSERTED M LEFT JOIN
			  CAJ_COMPROBANTE_PAGO P ON M.Id_ComprobantePago = P.id_ComprobantePago
			  WHERE @Id_AlmacenMov=M.Id_AlmacenMov

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_AlmacenMov), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_AlmacenMov,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_ALM_ALMACEN_MOV_D '+ 
			  CASE WHEN d.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Cod_TipoComprobante,'''','') +''',' END +
			  CASE WHEN d.Serie IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Serie,'''','') +''',' END +
			  CASE WHEN d.Numero IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Numero,'''','') +''',' END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED d  LEFT JOIN
			  CAJ_COMPROBANTE_PAGO P ON d.Id_ComprobantePago = P.id_ComprobantePago
			  WHERE @Id_AlmacenMov=d.Id_AlmacenMov

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_AlmacenMov), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_AlmacenMov,
			 i.Cod_Almacen,
			 i.Cod_TipoOperacion,
			 i.Cod_Turno,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Numero,
			 i.Fecha,
			 i.Motivo,
			 i.Id_ComprobantePago,
			 i.Flag_Anulado,
			 i.Obs_AlmacenMov,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_AlmacenMov,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Motivo,'|' ,
			 @Id_ComprobantePago,'|' ,
			 @Flag_Anulado,'|' ,
			 CONVERT(varchar(max),@Obs_AlmacenMov),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_AlmacenMov), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_AlmacenMov,
			 d.Cod_Almacen,
			 d.Cod_TipoOperacion,
			 d.Cod_Turno,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Numero,
			 d.Fecha,
			 d.Motivo,
			 d.Id_ComprobantePago,
			 d.Flag_Anulado,
			 d.Obs_AlmacenMov,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_AlmacenMov,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Motivo,'|' ,
			 @Id_ComprobantePago,'|' ,
			 @Flag_Anulado,'|' ,
			 CONVERT(varchar(max),@Obs_AlmacenMov),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA 
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Id_AlmacenMov), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--ALM_ALMACEN_MOV_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_MOV_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_MOV_D_IUD
GO

CREATE TRIGGER UTR_ALM_ALMACEN_MOV_D_IUD
ON dbo.ALM_ALMACEN_MOV_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_AlmacenMov int
	DECLARE @Item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='ALM_ALMACEN_MOV_D'
	--Variables de tabla secundarias
	DECLARE @Id_Producto int
	DECLARE @Des_Producto varchar(128)
	DECLARE @Precio_Unitario numeric(38,6)
	DECLARE @Cantidad numeric(38,6)
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Obs_AlmacenMovD varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @Fecha datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_AlmacenMov,
		    i.Item,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_ALM_ALMACEN_MOV_D_I '+ 
			CASE WHEN M.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_TipoComprobante,'''','') +''',' END +
			CASE WHEN M.Serie IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Serie,'''','') +''',' END +
			CASE WHEN M.Numero IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Numero,'''','') +''',' END + 
			CONVERT(VARCHAR(MAX),D.Item)+','+ 
			CASE WHEN D.Id_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pp.Cod_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Id_Producto=D.Id_Producto),''),'''','') +''',' END +
			CASE WHEN D.Des_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(D.Des_Producto,'''','') +''',' END +
			CASE WHEN D.Precio_Unitario IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Precio_Unitario)+','END+ 
			CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Cantidad)+','END+ 
			CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(D.Cod_UnidadMedida,'''','') +''',' END +
			CASE WHEN D.Obs_AlmacenMovD IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(D.Obs_AlmacenMovD,'''','') +''',' END +
			''''+REPLACE(COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg),'''','')+ ''';'
			FROM INSERTED   D INNER JOIN
				ALM_ALMACEN_MOV  M ON D.Id_AlmacenMov = M.Id_AlmacenMov 
			WHERE D.Id_AlmacenMov=@Id_AlmacenMov AND D.Item=@Item

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
			   CONCAT(@Id_AlmacenMov,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @Fecha -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_AlmacenMov,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_ALM_ALMACEN_MOV_D_D '+ 
			CASE WHEN M.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_TipoComprobante,'''','') +''',' END +
			CASE WHEN M.Serie IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Serie,'''','') +''',' END +
			CASE WHEN M.Numero IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Numero,'''','') +''',' END + 
			CONVERT(VARCHAR(MAX),D.Item)+','+ 
			''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM INSERTED   D INNER JOIN
				ALM_ALMACEN_MOV  M ON D.Id_AlmacenMov = M.Id_AlmacenMov 
			WHERE D.Id_AlmacenMov=@Id_AlmacenMov AND D.Item=@Item

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
			   CONCAT(@Id_AlmacenMov,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @Fecha -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_AlmacenMov,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_AlmacenMov,
			 i.Item,
			 i.Id_Producto,
			 i.Des_Producto,
			 i.Precio_Unitario,
			 i.Cantidad,
			 i.Cod_UnidadMedida,
			 i.Obs_AlmacenMovD,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Des_Producto,
			 @Precio_Unitario,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Obs_AlmacenMovD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
		      @Id_AlmacenMov,'|',
			 @Item,'|' ,
			 @Id_Producto,'|' ,
			 @Des_Producto,'|' ,
			 @Precio_Unitario,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Obs_AlmacenMovD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_AlmacenMov,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Des_Producto,
			 @Precio_Unitario,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Obs_AlmacenMovD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_AlmacenMov,
			 d.Item,
			 d.Id_Producto,
			 d.Des_Producto,
			 d.Precio_Unitario,
			 d.Cantidad,
			 d.Cod_UnidadMedida,
			 d.Obs_AlmacenMovD,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Des_Producto,
			 @Precio_Unitario,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Obs_AlmacenMovD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
		      @Id_AlmacenMov,'|',
			 @Item,'|' ,
			 @Id_Producto,'|' ,
			 @Des_Producto,'|' ,
			 @Precio_Unitario,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Obs_AlmacenMovD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Id_AlmacenMov,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Des_Producto,
			 @Precio_Unitario,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Obs_AlmacenMovD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--ALM_INVENTARIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_INVENTARIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_INVENTARIO_IUD
GO

CREATE TRIGGER UTR_ALM_INVENTARIO_IUD
ON dbo.ALM_INVENTARIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Inventario int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='ALM_INVENTARIO'
	--Variables de tabla secundarias
	DECLARE @Des_Inventario varchar(512)
	DECLARE @Cod_TipoInventario varchar(5)
	DECLARE @Obs_Inventario varchar(1024)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @Fecha datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_ALM_INVENTARIO_I ' + 
			  CASE WHEN ai.Des_Inventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ai.Des_Inventario,'''','')+''','END+
 			  CASE WHEN ai.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ai.Cod_TipoInventario,'''','')+''','END+
			  CASE WHEN ai.Obs_Inventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ai.Obs_Inventario,'''','')+''','END+
			  CASE WHEN ai.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ai.Cod_Almacen,'''','')+''','END+
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED ai
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
			   @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Inventario), -- Id_Fila - varchar
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

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Inventario,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Inventario,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_ALM_INVENTARIO_D ' + 
 			  CASE WHEN d.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Cod_TipoInventario,'''','')+''','END+
			  CASE WHEN d.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Cod_Almacen,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED d 
			  WHERE d.Id_Inventario=@Id_Inventario

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
			   CONCAT('',@Id_Inventario), -- Id_Fila - varchar
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

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Inventario,
			 i.Des_Inventario,
			 i.Cod_TipoInventario,
			 i.Obs_Inventario,
			 i.Cod_Almacen,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Inventario,
			 @Des_Inventario,
			 @Cod_TipoInventario,
			 @Obs_Inventario,
			 @Cod_Almacen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Inventario,'|' ,
			 @Des_Inventario,'|' ,
			 @Cod_TipoInventario,'|' ,
			 @Obs_Inventario,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Inventario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Inventario,
			 @Des_Inventario,
			 @Cod_TipoInventario,
			 @Obs_Inventario,
			 @Cod_Almacen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Inventario,
			 d.Des_Inventario,
			 d.Cod_TipoInventario,
			 d.Obs_Inventario,
			 d.Cod_Almacen,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Inventario,
			 @Des_Inventario,
			 @Cod_TipoInventario,
			 @Obs_Inventario,
			 @Cod_Almacen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Inventario,'|' ,
			 @Des_Inventario,'|' ,
			 @Cod_TipoInventario,'|' ,
			 @Obs_Inventario,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Inventario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Inventario,
			 @Des_Inventario,
			 @Cod_TipoInventario,
			 @Obs_Inventario,
			 @Cod_Almacen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--ALM_INVENTARIO_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_INVENTARIO_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_INVENTARIO_D_IUD
GO

CREATE TRIGGER UTR_ALM_INVENTARIO_D_IUD
ON dbo.ALM_INVENTARIO_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Inventario int
	DECLARE @Item varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='ALM_INVENTARIO_D'
	--Variables de tabla secundarias
	DECLARE @Id_Producto int
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cantidad_Sistema numeric(38,6)
	DECLARE @Cantidad_Encontrada numeric(38,6)
	DECLARE @Obs_InventarioD varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @Fecha datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_ALM_INVENTARIO_D_I ' + 
			  CASE WHEN I.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(I.Cod_TipoInventario,'''','')+''','END+
			  CASE WHEN ID.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Cod_Almacen,'''','')+''','END+
			  CASE WHEN ID.Item IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Item,'''','')+''','END+
			  CASE WHEN ID.Id_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pp.Cod_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Id_Producto=ID.Id_Producto),''),'''','') +''',' END +
			  CASE WHEN ID.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Cod_UnidadMedida,'''','')+''','END+
			  CASE WHEN ID.Cantidad_Sistema IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Sistema)+','END+
			  CASE WHEN ID.Cantidad_Encontrada IS NULL THEN 'NULL' ELSE  CONVERT(VARCHAR(MAX),ID.Cantidad_Encontrada)+','END+
			  CASE WHEN ID.Obs_InventarioD IS NULL THEN 'NULL'  ELSE ''''+ REPLACE(ID.Obs_InventarioD,'''','')+''','END+
			  ''''+REPLACE(COALESCE(ID.Cod_UsuarioAct,ID.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED ID INNER JOIN ALM_INVENTARIO I ON I.Id_Inventario=ID.Id_Inventario
			  WHERE ID.Id_Inventario=@Id_Inventario AND ID.Item=@Item

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
			   CONCAT(@Id_Inventario,'|',@Item), -- Id_Fila - varchar
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
	
	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Inventario,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Inventario,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_ALM_INVENTARIO_D_D ' + 
			  CASE WHEN I.Cod_TipoInventario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(I.Cod_TipoInventario,'''','')+''','END+
			  CASE WHEN ID.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Cod_Almacen,'''','')+''','END+
			  CASE WHEN ID.Item IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ID.Item,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  ID INNER JOIN ALM_INVENTARIO I ON I.Id_Inventario=ID.Id_Inventario
			  WHERE ID.Id_Inventario=@Id_Inventario AND ID.Item=@Item

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
			   CONCAT(@Id_Inventario,'|',@Item), -- Id_Fila - varchar
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

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Inventario,
			 i.Item,
			 i.Id_Producto,
			 i.Cod_UnidadMedida,
			 i.Cod_Almacen,
			 i.Cantidad_Sistema,
			 i.Cantidad_Encontrada,
			 i.Obs_InventarioD,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Inventario,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cantidad_Sistema,
			 @Cantidad_Encontrada,
			 @Obs_InventarioD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Inventario,'|' ,
			 @Item,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cantidad_Sistema,'|' ,
			 @Cantidad_Encontrada,'|' ,
			 @Obs_InventarioD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Inventario,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Inventario,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cantidad_Sistema,
			 @Cantidad_Encontrada,
			 @Obs_InventarioD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Inventario,
			 d.Item,
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 d.Cod_Almacen,
			 d.Cantidad_Sistema,
			 d.Cantidad_Encontrada,
			 d.Obs_InventarioD,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Inventario,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cantidad_Sistema,
			 @Cantidad_Encontrada,
			 @Obs_InventarioD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Inventario,'|' ,
			 @Item,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cantidad_Sistema,'|' ,
			 @Cantidad_Encontrada,'|' ,
			 @Obs_InventarioD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_Inventario,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Inventario,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cantidad_Sistema,
			 @Cantidad_Encontrada,
			 @Obs_InventarioD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--BAN_CUENTA_BANCARIA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_BAN_CUENTA_BANCARIA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_BAN_CUENTA_BANCARIA_IUD
GO

CREATE TRIGGER UTR_BAN_CUENTA_BANCARIA_IUD
ON dbo.BAN_CUENTA_BANCARIA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_CuentaBancaria varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='BAN_CUENTA_BANCARIA'
	--Variables de tabla secundarias
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Cod_EntidadFinanciera varchar(8)
	DECLARE @Des_CuentaBancaria varchar(512)
	DECLARE @Cod_Moneda varchar(5)
	DECLARE @Flag_Activo bit
	DECLARE @Saldo_Disponible numeric(38,2)
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Cod_TipoCuentaBancaria varchar(8)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @Fecha datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_CuentaBancaria,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaBancaria,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_BAN_CUENTA_BANCARIA_I '+
			  ''''+REPLACE(bcb.Cod_CuentaBancaria,'''','')+ ''','+
			  CASE WHEN bcb.Cod_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Cod_Sucursal,'''','')+''','  END+ 
			  CASE WHEN bcb.Cod_EntidadFinanciera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Cod_EntidadFinanciera,'''','')+''','  END+ 
			  CASE WHEN bcb.Des_CuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Des_CuentaBancaria,'''','')+''','  END+ 
			  CASE WHEN bcb.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Cod_Moneda,'''','')+''','  END+ 
			  CONVERT(VARCHAR(MAX),bcb.Flag_Activo)+','+ 
			  CASE WHEN bcb.Saldo_Disponible IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),bcb.Saldo_Disponible)+','END+ 
			  CASE WHEN bcb.Cod_CuentaContable IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Cod_CuentaContable,'''','')+''','  END+ 
			  CASE WHEN bcb.Cod_TipoCuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+REPLACE(bcb.Cod_TipoCuentaBancaria,'''','')+''','  END+ 
			  ''''+REPLACE(COALESCE(bcb.Cod_UsuarioAct,bcb.Cod_UsuarioReg),'''','')+ ''';'
			  FROM  INSERTED bcb WHERE
			  bcb.Cod_CuentaBancaria=@Cod_CuentaBancaria

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
			   @Cod_CuentaBancaria, -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @Fecha -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaBancaria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_CuentaBancaria,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaBancaria,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_BAN_CUENTA_BANCARIA_D '+
			  ''''+REPLACE(bcb.Cod_CuentaBancaria,'''','')+ ''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM  DELETED  bcb WHERE
			  bcb.Cod_CuentaBancaria=@Cod_CuentaBancaria

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
			   @Cod_CuentaBancaria, -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @Fecha -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaBancaria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_CuentaBancaria,
			 i.Cod_Sucursal,
			 i.Cod_EntidadFinanciera,
			 i.Des_CuentaBancaria,
			 i.Cod_Moneda,
			 i.Flag_Activo,
			 i.Saldo_Disponible,
			 i.Cod_CuentaContable,
			 i.Cod_TipoCuentaBancaria,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_CuentaBancaria,
			 @Cod_Sucursal,
			 @Cod_EntidadFinanciera,
			 @Des_CuentaBancaria,
			 @Cod_Moneda,
			 @Flag_Activo,
			 @Saldo_Disponible,
			 @Cod_CuentaContable,
			 @Cod_TipoCuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_CuentaBancaria,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Cod_EntidadFinanciera,'|' ,
			 @Des_CuentaBancaria,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_Activo,'|' ,
			 @Saldo_Disponible,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_TipoCuentaBancaria,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 @Cod_CuentaBancaria, -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_CuentaBancaria,
			 @Cod_Sucursal,
			 @Cod_EntidadFinanciera,
			 @Des_CuentaBancaria,
			 @Cod_Moneda,
			 @Flag_Activo,
			 @Saldo_Disponible,
			 @Cod_CuentaContable,
			 @Cod_TipoCuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_CuentaBancaria,
			 d.Cod_Sucursal,
			 d.Cod_EntidadFinanciera,
			 d.Des_CuentaBancaria,
			 d.Cod_Moneda,
			 d.Flag_Activo,
			 d.Saldo_Disponible,
			 d.Cod_CuentaContable,
			 d.Cod_TipoCuentaBancaria,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_CuentaBancaria,
			 @Cod_Sucursal,
			 @Cod_EntidadFinanciera,
			 @Des_CuentaBancaria,
			 @Cod_Moneda,
			 @Flag_Activo,
			 @Saldo_Disponible,
			 @Cod_CuentaContable,
			 @Cod_TipoCuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_CuentaBancaria,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Cod_EntidadFinanciera,'|' ,
			 @Des_CuentaBancaria,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_Activo,'|' ,
			 @Saldo_Disponible,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_TipoCuentaBancaria,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 @Cod_CuentaBancaria, -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_CuentaBancaria,
			 @Cod_Sucursal,
			 @Cod_EntidadFinanciera,
			 @Des_CuentaBancaria,
			 @Cod_Moneda,
			 @Flag_Activo,
			 @Saldo_Disponible,
			 @Cod_CuentaContable,
			 @Cod_TipoCuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--BAN_CUENTA_M
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_BAN_CUENTA_M_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_BAN_CUENTA_M_IUD
GO

CREATE TRIGGER UTR_BAN_CUENTA_M_IUD
ON dbo.BAN_CUENTA_M
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_MovimientoCuenta int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='BAN_CUENTA_M'
	--Variables de tabla secundarias
	DECLARE @Cod_CuentaBancaria varchar(32)
	DECLARE @Nro_Operacion varchar(32)
	DECLARE @Des_Movimiento varchar(512)
	DECLARE @Cod_TipoOperacionBancaria varchar(8)
	DECLARE @Fecha datetime
	DECLARE @Monto numeric(38,2)
	DECLARE @TipoCambio numeric(10,4)
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Nro_Cheque varchar(32)
	DECLARE @Beneficiario varchar(512)
	DECLARE @Id_ComprobantePago int
	DECLARE @Obs_Movimiento varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_MovimientoCuenta,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_MovimientoCuenta,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_BAN_CUENTA_M_I '+ 
			  CASE WHEN Cod_CuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_CuentaBancaria,'''','') +''',' END +
			  CASE WHEN Nro_Operacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Operacion,'''','') +''',' END +
			  CASE WHEN Des_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_Movimiento,'''','') +''',' END +
			  CASE WHEN Cod_TipoOperacionBancaria IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoOperacionBancaria,'''','') +''',' END +
			  CASE WHEN Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha,121)+''','END+ 
			  CASE WHEN Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Monto)+','END+ 
			  CASE WHEN TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),TipoCambio)+','END+ 
			  CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Caja,'''','') +''',' END +
			  CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','') +''',' END +
			  CASE WHEN Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Plantilla,'''','') +''',' END +
			  CASE WHEN Nro_Cheque IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Cheque,'''','') +''',' END +
			  CASE WHEN Beneficiario IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Beneficiario,'''','') +''',' END +
			  CASE WHEN Id_ComprobantePago IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Id_ComprobantePago)+','END+ 
			  CASE WHEN Obs_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Obs_Movimiento,'''','') +''',' END +
			  ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+ ''';' 
			  FROM            INSERTED WHERE INSERTED.Id_MovimientoCuenta=@Id_MovimientoCuenta

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_MovimientoCuenta), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_MovimientoCuenta,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_MovimientoCuenta,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_MovimientoCuenta,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_BAN_CUENTA_M_D '+ 
			  CASE WHEN d.Cod_CuentaBancaria IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(d.Cod_CuentaBancaria,'''','') +''',' END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM            DELETED d WHERE d.Id_MovimientoCuenta=@Id_MovimientoCuenta

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_MovimientoCuenta), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_MovimientoCuenta,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_MovimientoCuenta,
			 i.Cod_CuentaBancaria,
			 i.Nro_Operacion,
			 i.Des_Movimiento,
			 i.Cod_TipoOperacionBancaria,
			 i.Fecha,
			 i.Monto,
			 i.TipoCambio,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Cod_Plantilla,
			 i.Nro_Cheque,
			 i.Beneficiario,
			 i.Id_ComprobantePago,
			 i.Obs_Movimiento,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_MovimientoCuenta,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_MovimientoCuenta,'|' ,
			 @Cod_CuentaBancaria,'|' ,
			 @Nro_Operacion,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoOperacionBancaria,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Monto,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Cheque,'|' ,
			 @Beneficiario,'|' ,
			 @Id_ComprobantePago,'|' ,
			 @Obs_Movimiento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_MovimientoCuenta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_MovimientoCuenta,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_MovimientoCuenta,
			 d.Cod_CuentaBancaria,
			 d.Nro_Operacion,
			 d.Des_Movimiento,
			 d.Cod_TipoOperacionBancaria,
			 d.Fecha,
			 d.Monto,
			 d.TipoCambio,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Cod_Plantilla,
			 d.Nro_Cheque,
			 d.Beneficiario,
			 d.Id_ComprobantePago,
			 d.Obs_Movimiento,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_MovimientoCuenta,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_MovimientoCuenta,'|' ,
			 @Cod_CuentaBancaria,'|' ,
			 @Nro_Operacion,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoOperacionBancaria,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Monto,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Cheque,'|' ,
			 @Beneficiario,'|' ,
			 @Id_ComprobantePago,'|' ,
			 @Obs_Movimiento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Id_MovimientoCuenta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_MovimientoCuenta,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_ARQUEOFISICO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_IUD
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_IUD
ON dbo.CAJ_ARQUEOFISICO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ArqueoFisico int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_ARQUEOFISICO'
	--Variables de tabla secundarias
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Numero int
	DECLARE @Des_ArqueoFisico varchar(512)
	DECLARE @Obs_ArqueoFisico varchar(1024)
	DECLARE @Fecha datetime
	DECLARE @Flag_Cerrado bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ArqueoFisico,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_I ' + 
			  CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Caja,'''','')+''','END+
			  CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','')+''','END+
			  CONVERT(VARCHAR(MAX),Numero) +','+ 
			  CASE WHEN Des_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_ArqueoFisico,'''','')+''','END+
			  CASE WHEN Obs_ArqueoFisico IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Obs_ArqueoFisico,'''','')+''','END+
			  ''''+CONVERT(VARCHAR(MAX),Fecha,121) +''','+ 
			  CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+ 
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','') +''';' 
			  FROM INSERTED  WHERE INSERTED.id_ArqueoFisico=@id_ArqueoFisico

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@id_ArqueoFisico), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ArqueoFisico,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_D ' + 
			  CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Caja,'''','')+''','END+
			  CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED d  WHERE d.id_ArqueoFisico=@id_ArqueoFisico

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@id_ArqueoFisico), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ArqueoFisico,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Numero,
			 i.Des_ArqueoFisico,
			 i.Obs_ArqueoFisico,
			 i.Fecha,
			 i.Flag_Cerrado,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Numero,
			 @Des_ArqueoFisico,
			 @Obs_ArqueoFisico,
			 @Fecha,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Numero,'|' ,
			 @Des_ArqueoFisico,'|' ,
			 @Obs_ArqueoFisico,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Flag_Cerrado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@id_ArqueoFisico), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Numero,
			 @Des_ArqueoFisico,
			 @Obs_ArqueoFisico,
			 @Fecha,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ArqueoFisico,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Numero,
			 d.Des_ArqueoFisico,
			 d.Obs_ArqueoFisico,
			 d.Fecha,
			 d.Flag_Cerrado,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Numero,
			 @Des_ArqueoFisico,
			 @Obs_ArqueoFisico,
			 @Fecha,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Numero,'|' ,
			 @Des_ArqueoFisico,'|' ,
			 @Obs_ArqueoFisico,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Flag_Cerrado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@id_ArqueoFisico), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Numero,
			 @Des_ArqueoFisico,
			 @Obs_ArqueoFisico,
			 @Fecha,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_ARQUEOFISICO_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_D_IUD
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_D_IUD
ON dbo.CAJ_ARQUEOFISICO_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ArqueoFisico int
	DECLARE @Cod_Billete varchar(3)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_ARQUEOFISICO_D'
	--Variables de tabla secundarias
	DECLARE @Cantidad int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ArqueoFisico,
		    i.Cod_Billete,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Billete,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_D_I ' + 
			  CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
			  CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Turno,'''','')+''','END+
			  CASE WHEN AD.Cod_Billete IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AD.Cod_Billete,'''','')+''','END+
			  CASE WHEN AD.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),AD.Cantidad)+',' END +
			  + ''''+REPLACE(COALESCE(AD.Cod_UsuarioAct,AD.Cod_UsuarioReg),'''','')+''';'
			  FROM            INSERTED  AD INNER JOIN
									   CAJ_ARQUEOFISICO  AF ON AD.id_ArqueoFisico = AF.id_ArqueoFisico
			  WHERE AD.id_ArqueoFisico=@id_ArqueoFisico AND AD.Cod_Billete=@Cod_Billete

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ArqueoFisico,'|',@Cod_Billete), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Billete,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ArqueoFisico,
		    d.Cod_Billete,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Billete,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_D_D ' + 
			  CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
			  CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Turno,'''','')+''','END+
			  CASE WHEN AD.Cod_Billete IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AD.Cod_Billete,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM            INSERTED  AD INNER JOIN
									   CAJ_ARQUEOFISICO  AF ON AD.id_ArqueoFisico = AF.id_ArqueoFisico
			  WHERE AD.id_ArqueoFisico=@id_ArqueoFisico AND AD.Cod_Billete=@Cod_Billete

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ArqueoFisico,'|',@Cod_Billete), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Billete,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ArqueoFisico,
			 i.Cod_Billete,
			 i.Cantidad,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Billete,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Billete,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ArqueoFisico,'|',@Cod_Billete), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Billete,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ArqueoFisico,
			 d.Cod_Billete,
			 d.Cantidad,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Billete,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Billete,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@id_ArqueoFisico,'|',@Cod_Billete), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Billete,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
END
GO

--CAJ_ARQUEOFISICO_SALDO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_ARQUEOFISICO_SALDO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_IUD
GO

CREATE TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_IUD
ON dbo.CAJ_ARQUEOFISICO_SALDO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ArqueoFisico int
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Tipo varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_ARQUEOFISICO_SALDO'
	--Variables de tabla secundarias
	DECLARE @Monto numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
		    @id_ArqueoFisico,
		    @Cod_Moneda,
		    @Tipo,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_SALDO_I ' + 
			  CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
			  CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Turno,'''','')+''','END+
			  CASE WHEN ASA.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ASA.Cod_Moneda,'''','')+''','END+
			  CASE WHEN ASA.Tipo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ASA.Tipo,'''','')+''','END+
			  CASE WHEN ASA.Monto IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR(MAX),ASA.Monto)+',' END+ 
			  +''''+REPLACE(COALESCE(ASA.Cod_UsuarioAct,ASA.Cod_UsuarioReg),'''','')+''';' 
			  FROM            INSERTED  ASA INNER JOIN
									   CAJ_ARQUEOFISICO AF ON ASA.id_ArqueoFisico = AF.id_ArqueoFisico
			  WHERE ASA.id_ArqueoFisico=@id_ArqueoFisico AND ASA.Cod_Moneda=@Cod_Moneda AND  ASA.Tipo=@Tipo

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ArqueoFisico,'|',@Cod_Moneda,'|',@Tipo), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Moneda,
		    @Tipo,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ArqueoFisico,
		    d.Cod_Moneda,
		    d.Tipo,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Moneda,
		    @Tipo,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_ARQUEOFISICO_SALDO_D ' + 
			  CASE WHEN AF.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Caja,'''','')+''','END+
			  CASE WHEN AF.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(AF.Cod_Turno,'''','')+''','END+
			  CASE WHEN ASA.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ASA.Cod_Moneda,'''','')+''','END+
			  CASE WHEN ASA.Tipo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ASA.Tipo,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM            DELETED   ASA INNER JOIN
									   CAJ_ARQUEOFISICO AF ON ASA.id_ArqueoFisico = AF.id_ArqueoFisico
			  WHERE ASA.id_ArqueoFisico=@id_ArqueoFisico AND ASA.Cod_Moneda=@Cod_Moneda AND  ASA.Tipo=@Tipo

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ArqueoFisico,'|',@Cod_Moneda,'|',@Tipo), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ArqueoFisico,
		    @Cod_Moneda,
		    @Tipo,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ArqueoFisico,
			 i.Cod_Moneda,
			 i.Tipo,
			 i.Monto,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Moneda,
			 @Tipo,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Moneda,'|' ,
			 @Tipo,'|' ,
			 @Monto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ArqueoFisico,'|',@Cod_Moneda,'|',@Tipo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Moneda,
			 @Tipo,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ArqueoFisico,
			 d.Cod_Moneda,
			 d.Tipo,
			 d.Monto,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ArqueoFisico,
			 @Cod_Moneda,
			 @Tipo,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ArqueoFisico,'|' ,
			 @Cod_Moneda,'|' ,
			 @Tipo,'|' ,
			 @Monto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@id_ArqueoFisico,'|',@Cod_Moneda,'|',@Tipo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ArqueoFisico,
			 @Cod_Moneda,
			 @Tipo,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_CAJA_ALMACEN
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJA_ALMACEN_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJA_ALMACEN_IUD
GO

CREATE TRIGGER UTR_CAJ_CAJA_ALMACEN_IUD
ON dbo.CAJ_CAJA_ALMACEN
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_CAJA_ALMACEN'
	--Variables de tabla secundarias
	DECLARE @Flag_Principal bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce) 
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_CAJA_ALMACEN_I ' + 
			  CASE WHEN cca.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cca.Cod_Caja,'''','')+''',' END +
			  CASE WHEN cca.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cca.Cod_Almacen,'''','')+''',' END +
			  CONVERT (VARCHAR(MAX),cca.Flag_Principal)+ ','+
			  ''''+REPLACE(COALESCE(cca.Cod_UsuarioAct,cca.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  cca
			  WHERE cca.Cod_Caja=@Cod_Caja AND cca.Cod_Almacen=@Cod_Almacen

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Caja,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Caja,
		    d.Cod_Almacen,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Caja,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_CAJA_ALMACEN_D ' + 
			  CASE WHEN cca.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cca.Cod_Caja,'''','')+''',' END +
			  CASE WHEN cca.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cca.Cod_Almacen,'''','')+''',' END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  cca
			  WHERE cca.Cod_Caja=@Cod_Caja AND cca.Cod_Almacen=@Cod_Almacen

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Caja,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Caja,
			 i.Cod_Almacen,
			 i.Flag_Principal,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Caja,
			 @Cod_Almacen,
			 @Flag_Principal,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Cod_Almacen,'|' ,
			 @Flag_Principal,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Caja,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Caja,
			 @Cod_Almacen,
			 @Flag_Principal,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Caja,
			 d.Cod_Almacen,
			 d.Flag_Principal,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Caja,
			 @Cod_Almacen,
			 @Flag_Principal,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Cod_Almacen,'|' ,
			 @Flag_Principal,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Caja,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Caja,
			 @Cod_Almacen,
			 @Flag_Principal,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_CAJA_MOVIMIENTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJA_MOVIMIENTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJA_MOVIMIENTOS_IUD
GO

CREATE TRIGGER UTR_CAJ_CAJA_MOVIMIENTOS_IUD
ON dbo.CAJ_CAJA_MOVIMIENTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_Movimiento int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_CAJA_MOVIMIENTOS'
	--Variables de tabla secundarias
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Id_Concepto int
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cliente varchar(512)
	DECLARE @Des_Movimiento varchar(512)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(4)
	DECLARE @Numero varchar(20)
	DECLARE @Fecha datetime
	DECLARE @Tipo_Cambio numeric(10,4)
	DECLARE @Ingreso numeric(38,2)
	DECLARE @Cod_MonedaIng varchar(3)
	DECLARE @Egreso numeric(38,2)
	DECLARE @Cod_MonedaEgr varchar(3)
	DECLARE @Flag_Extornado bit
	DECLARE @Cod_UsuarioAut varchar(32)
	DECLARE @Fecha_Aut datetime
	DECLARE @Obs_Movimiento xml
	DECLARE @Id_MovimientoRef int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_Movimiento,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				SELECT @Script= 'USP_CAJ_CAJA_MOVIMIENTOS_I ' +
				CASE WHEN CM.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_Caja,'''','')+''','END+
				CASE WHEN CM.Cod_Turno  IS NULL THEN 'NULL,' ELSE '''' +REPLACE(CM.Cod_Turno,'''','')+ ''',' END+ 
				CASE WHEN CM.Id_Concepto IS NULL THEN 'NULL,' ELSE	CONVERT(VARCHAR(MAX),CM.Id_Concepto)+',' END+ 
				CASE WHEN CP.Cod_TipoDocumento  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
				CASE WHEN CP.Nro_Documento  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_Documento,'''','')+''','END+
				CASE WHEN CM.Des_Movimiento  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Des_Movimiento,'''','')+''','END+
				CASE WHEN CM.Cod_TipoComprobante  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_TipoComprobante,'''','')+''','END+
				CASE WHEN CM.Serie  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Serie,'''','')+''','END+
				CASE WHEN CM.Numero  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Numero,'''','')+''','END+
				CASE WHEN CM.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha,121)+''',' END+ 
				CASE WHEN CM.Tipo_Cambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Tipo_Cambio)+',' END+ 
				CASE WHEN CM.Ingreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Ingreso)+',' END+ 
				CASE WHEN CM.Cod_MonedaIng  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_MonedaIng,'''','')+''','END+
				CASE WHEN CM.Egreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Egreso)+',' END+ 
				CASE WHEN CM.Cod_MonedaEgr  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_MonedaEgr,'''','')+''','END+
				CONVERT(VARCHAR(MAX),CM.Flag_Extornado)+','+
				CASE WHEN CM.Cod_UsuarioAut  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_UsuarioAut,'''','')+''','END+
				CASE WHEN CM.Fecha_Aut IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha_Aut,121)+''','END+ 
				CASE WHEN CM.Obs_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),CM.Obs_Movimiento),'''','')+''','END+ 
				CASE WHEN CM.Id_MovimientoRef IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Id_MovimientoRef)+','END+ 
				''''+REPLACE(COALESCE(CM.Cod_UsuarioAct,CM.Cod_UsuarioReg),'''','') + ''';' 
				FROM  INSERTED  CM LEFT JOIN 
				PRI_CLIENTE_PROVEEDOR AS CP ON CM.Id_ClienteProveedor = CP.Id_ClienteProveedor 
				WHERE CM.id_Movimiento=@id_Movimiento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@id_Movimiento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_Movimiento,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				SELECT @Script= 'USP_CAJ_CAJA_MOVIMIENTOS_D ' +
				CASE WHEN CM.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_Caja,'''','')+''','END+
				CASE WHEN CM.Cod_Turno  IS NULL THEN 'NULL,' ELSE '''' +REPLACE(CM.Cod_Turno,'''','')+ ''',' END+ 
				CASE WHEN CM.Cod_TipoComprobante  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Cod_TipoComprobante,'''','')+''','END+
				CASE WHEN CM.Serie  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Serie,'''','')+''','END+
				CASE WHEN CM.Numero  IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CM.Numero,'''','')+''','END+
				''''+'TRIGGER'+''',' +
				''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				FROM DELETED   CM LEFT JOIN 
				PRI_CLIENTE_PROVEEDOR AS CP ON CM.Id_ClienteProveedor = CP.Id_ClienteProveedor 
				WHERE CM.id_Movimiento=@id_Movimiento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@id_Movimiento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_Movimiento,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Id_Concepto,
			 i.Id_ClienteProveedor,
			 i.Cliente,
			 i.Des_Movimiento,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Numero,
			 i.Fecha,
			 i.Tipo_Cambio,
			 i.Ingreso,
			 i.Cod_MonedaIng,
			 i.Egreso,
			 i.Cod_MonedaEgr,
			 i.Flag_Extornado,
			 i.Cod_UsuarioAut,
			 i.Fecha_Aut,
			 i.Obs_Movimiento,
			 i.Id_MovimientoRef,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_Movimiento,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Id_Concepto,
			 @Id_ClienteProveedor,
			 @Cliente,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_Movimiento,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Id_Concepto,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cliente,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Tipo_Cambio,'|' ,
			 @Ingreso,'|' ,
			 @Cod_MonedaIng,'|' ,
			 @Egreso,'|' ,
			 @Cod_MonedaEgr,'|' ,
			 @Flag_Extornado,'|' ,
			 @Cod_UsuarioAut,'|' ,
			 CONVERT(varchar,@Fecha_Aut,121), '|' ,
			 CONVERT(varchar(max),@Obs_Movimiento),'|' ,
			 @Id_MovimientoRef,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@id_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_Movimiento,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Id_Concepto,
			 @Id_ClienteProveedor,
			 @Cliente,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_Movimiento,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Id_Concepto,
			 d.Id_ClienteProveedor,
			 d.Cliente,
			 d.Des_Movimiento,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Numero,
			 d.Fecha,
			 d.Tipo_Cambio,
			 d.Ingreso,
			 d.Cod_MonedaIng,
			 d.Egreso,
			 d.Cod_MonedaEgr,
			 d.Flag_Extornado,
			 d.Cod_UsuarioAut,
			 d.Fecha_Aut,
			 d.Obs_Movimiento,
			 d.Id_MovimientoRef,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_Movimiento,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Id_Concepto,
			 @Id_ClienteProveedor,
			 @Cliente,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_Movimiento,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Id_Concepto,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cliente,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Tipo_Cambio,'|' ,
			 @Ingreso,'|' ,
			 @Cod_MonedaIng,'|' ,
			 @Egreso,'|' ,
			 @Cod_MonedaEgr,'|' ,
			 @Flag_Extornado,'|' ,
			 @Cod_UsuarioAut,'|' ,
			 CONVERT(varchar,@Fecha_Aut,121), '|' ,
			 CONVERT(varchar(max),@Obs_Movimiento),'|' ,
			 @Id_MovimientoRef,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_Movimiento,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Id_Concepto,
			 @Id_ClienteProveedor,
			 @Cliente,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
END
GO

--CAJ_CAJAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJAS_IUD
GO

CREATE TRIGGER UTR_CAJ_CAJAS_IUD
ON dbo.CAJ_CAJAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_CAJAS'
	--Variables de tabla secundarias
	DECLARE @Des_Caja varchar(512)
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Cod_UsuarioCajero varchar(32)
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_CAJAS_I ' +
			  CASE WHEN cc.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_Caja,'''','')+''','END +
			  CASE WHEN cc.Des_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Des_Caja,'''','')+''','END +
			  CASE WHEN cc.Cod_Sucursal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_Sucursal,'''','')+''','END +
			  CASE WHEN cc.Cod_UsuarioCajero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_UsuarioCajero,'''','')+''','END +
			  CASE WHEN cc.Cod_CuentaContable IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_CuentaContable,'''','')+''','END +
			  CONVERT(varchar(MAX),cc.Flag_Activo)+','+
			  ''''+REPLACE(COALESCE(cc.Cod_UsuarioAct,cc.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  cc
			  WHERE cc.Cod_Caja=@Cod_Caja

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Caja), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Caja,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Caja,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Caja,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_CAJAS_D ' +
			  CASE WHEN cc.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(cc.Cod_Caja,'''','')+''','END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED cc
			  WHERE cc.Cod_Caja=@Cod_Caja

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Caja), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Caja,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Caja,
			 i.Des_Caja,
			 i.Cod_Sucursal,
			 i.Cod_UsuarioCajero,
			 i.Cod_CuentaContable,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Caja,
			 @Des_Caja,
			 @Cod_Sucursal,
			 @Cod_UsuarioCajero,
			 @Cod_CuentaContable,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Des_Caja,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Cod_UsuarioCajero,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Caja), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Caja,
			 @Des_Caja,
			 @Cod_Sucursal,
			 @Cod_UsuarioCajero,
			 @Cod_CuentaContable,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Caja,
			 d.Des_Caja,
			 d.Cod_Sucursal,
			 d.Cod_UsuarioCajero,
			 d.Cod_CuentaContable,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Caja,
			 @Des_Caja,
			 @Cod_Sucursal,
			 @Cod_UsuarioCajero,
			 @Cod_CuentaContable,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Des_Caja,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Cod_UsuarioCajero,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Caja), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Caja,
			 @Des_Caja,
			 @Cod_Sucursal,
			 @Cod_UsuarioCajero,
			 @Cod_CuentaContable,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_CAJAS_DOC
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CAJAS_DOC_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CAJAS_DOC_IUD
GO

CREATE TRIGGER UTR_CAJ_CAJAS_DOC_IUD
ON dbo.CAJ_CAJAS_DOC
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_CAJAS_DOC'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(5)
	DECLARE @Impresora varchar(512)
	DECLARE @Flag_Imprimir bit
	DECLARE @Flag_FacRapida bit
	DECLARE @Nom_Archivo varchar(1024)
	DECLARE @Nro_SerieTicketera varchar(64)
	DECLARE @Nom_ArchivoPublicar varchar(512)
	DECLARE @Limite int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script=  'USP_CAJ_CAJAS_DOC_I ' + 
			  CASE WHEN ccd.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Cod_Caja,'''','')+''','END+
			  CASE WHEN ccd.Item IS NULL THEN 'NULL,' ELSE  CONVERT(varchar(max),ccd.Item)+','END+
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
			  FROM INSERTED  ccd
			  WHERE ccd.Cod_Caja=@Cod_Caja AND ccd.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Caja,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Caja,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Caja,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script=  'USP_CAJ_CAJAS_DOC_D ' + 
			  CASE WHEN ccd.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ccd.Cod_Caja,'''','')+''','END+
			  CASE WHEN ccd.Item IS NULL THEN 'NULL,' ELSE  CONVERT(varchar(max),ccd.Item)+','END+
			  ''''+'TRIGGER'+''',' +
				''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED ccd
			  WHERE ccd.Cod_Caja=@Cod_Caja AND ccd.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Caja,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Caja,
			 i.Item,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Impresora,
			 i.Flag_Imprimir,
			 i.Flag_FacRapida,
			 i.Nom_Archivo,
			 i.Nro_SerieTicketera,
			 i.Nom_ArchivoPublicar,
			 i.Limite,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Item,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Impresora,'|' ,
			 @Flag_Imprimir,'|' ,
			 @Flag_FacRapida,'|' ,
			 @Nom_Archivo,'|' ,
			 @Nro_SerieTicketera,'|' ,
			 @Nom_ArchivoPublicar,'|' ,
			 @Limite,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Caja,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Caja,
			 d.Item,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Impresora,
			 d.Flag_Imprimir,
			 d.Flag_FacRapida,
			 d.Nom_Archivo,
			 d.Nro_SerieTicketera,
			 d.Nom_ArchivoPublicar,
			 d.Limite,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Caja,'|' ,
			 @Item,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Impresora,'|' ,
			 @Flag_Imprimir,'|' ,
			 @Flag_FacRapida,'|' ,
			 @Nom_Archivo,'|' ,
			 @Nro_SerieTicketera,'|' ,
			 @Nom_ArchivoPublicar,'|' ,
			 @Limite,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Caja,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_COMPROBANTE_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_IUD
ON dbo.CAJ_COMPROBANTE_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @id_Detalle int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_D'
	--Variables de tabla secundarias
	DECLARE @Id_Producto int
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cantidad numeric(38,6)
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Despachado numeric(38,6)
	DECLARE @Descripcion varchar(max)
	DECLARE @PrecioUnitario numeric(38,6)
	DECLARE @Descuento numeric(38,2)
	DECLARE @Sub_Total numeric(38,2)
	DECLARE @Tipo varchar(256)
	DECLARE @Obs_ComprobanteD varchar(1024)
	DECLARE @Cod_Manguera varchar(32)
	DECLARE @Flag_AplicaImpuesto bit
	DECLARE @Formalizado numeric(38,6)
	DECLARE @Valor_NoOneroso numeric(38,2)
	DECLARE @Cod_TipoISC varchar(8)
	DECLARE @Porcentaje_ISC numeric(38,2)
	DECLARE @ISC numeric(38,2)
	DECLARE @Cod_TipoIGV varchar(8)
	DECLARE @Porcentaje_IGV numeric(38,2)
	DECLARE @IGV numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.id_Detalle,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script='USP_CAJ_COMPROBANTE_D_I '+ 
			CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoDoc,'''','')+''',' END +
			CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Doc_Cliente,'''','')+''',' END +
			CONVERT(VARCHAR(MAX),D.id_Detalle)+','+ 
			CASE WHEN D.Id_Producto IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT pp.Cod_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Id_Producto=D.Id_Producto),''),'''','')+''',' END +
			CASE WHEN D.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_Almacen,'''','')+''',' END +
			CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Cantidad)+','END+
			CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_UnidadMedida,'''','')+''',' END +
			CASE WHEN D.Despachado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Despachado)+','END+
			CASE WHEN D.Descripcion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Descripcion,'''','')+''',' END +
			CASE WHEN D.PrecioUnitario IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.PrecioUnitario)+','END+ 
			CASE WHEN D.Descuento IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Descuento)+','END+
			CASE WHEN D.Sub_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Sub_Total)+','END+ 
			CASE WHEN D.Tipo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Tipo,'''','')+''',' END +
			CASE WHEN D.Obs_ComprobanteD IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Obs_ComprobanteD,'''','')+''',' END +
			CASE WHEN D.Cod_Manguera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_Manguera,'''','')+''',' END + 
			CONVERT(VARCHAR(MAX),D.Flag_AplicaImpuesto)+','+ 
			CASE WHEN D.Formalizado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Formalizado)+','END+ 
			CASE WHEN D.Valor_NoOneroso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Valor_NoOneroso)+','END+ 
			CASE WHEN D.Cod_TipoISC IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_TipoISC,'''','')+''',' END +
			CASE WHEN D.Porcentaje_ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_ISC)+','END+ 
			CASE WHEN D.ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.ISC)+','END+ 
			CASE WHEN D.Cod_TipoIGV IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_TipoIGV,'''','')+''',' END +
			CASE WHEN D.Porcentaje_IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_IGV)+','END+ 
			CASE WHEN D.IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.IGV)+','END+ 
			''''+REPLACE(COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg),'''','')+''';' 
			FROM INSERTED D INNER JOIN
			   CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago 
			WHERE D.id_ComprobantePago=@id_ComprobantePago AND D.id_Detalle=@id_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.id_Detalle,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script='USP_CAJ_COMPROBANTE_D_D '+ 
			CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			CONVERT(VARCHAR(MAX),D.id_Detalle)+','+ 
			''''+'TRIGGER'+''',' +
			''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM DELETED D INNER JOIN
			   CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago 
			WHERE D.id_ComprobantePago=@id_ComprobantePago AND D.id_Detalle=@id_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.id_Detalle,
			 i.Id_Producto,
			 i.Cod_Almacen,
			 i.Cantidad,
			 i.Cod_UnidadMedida,
			 i.Despachado,
			 i.Descripcion,
			 i.PrecioUnitario,
			 i.Descuento,
			 i.Sub_Total,
			 i.Tipo,
			 i.Obs_ComprobanteD,
			 i.Cod_Manguera,
			 i.Flag_AplicaImpuesto,
			 i.Formalizado,
			 i.Valor_NoOneroso,
			 i.Cod_TipoISC,
			 i.Porcentaje_ISC,
			 i.ISC,
			 i.Cod_TipoIGV,
			 i.Porcentaje_IGV,
			 i.IGV,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @id_Detalle,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Despachado,'|' ,
			 @Descripcion,'|' ,
			 @PrecioUnitario,'|' ,
			 @Descuento,'|' ,
			 @Sub_Total,'|' ,
			 @Tipo,'|' ,
			 @Obs_ComprobanteD,'|' ,
			 @Cod_Manguera,'|' ,
			 @Flag_AplicaImpuesto,'|' ,
			 @Formalizado,'|' ,
			 @Valor_NoOneroso,'|' ,
			 @Cod_TipoISC,'|' ,
			 @Porcentaje_ISC,'|' ,
			 @ISC,'|' ,
			 @Cod_TipoIGV,'|' ,
			 @Porcentaje_IGV,'|' ,
			 @IGV,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ComprobantePago,'|',@id_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.id_Detalle,
			 d.Id_Producto,
			 d.Cod_Almacen,
			 d.Cantidad,
			 d.Cod_UnidadMedida,
			 d.Despachado,
			 d.Descripcion,
			 d.PrecioUnitario,
			 d.Descuento,
			 d.Sub_Total,
			 d.Tipo,
			 d.Obs_ComprobanteD,
			 d.Cod_Manguera,
			 d.Flag_AplicaImpuesto,
			 d.Formalizado,
			 d.Valor_NoOneroso,
			 d.Cod_TipoISC,
			 d.Porcentaje_ISC,
			 d.ISC,
			 d.Cod_TipoIGV,
			 d.Porcentaje_IGV,
			 d.IGV,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @id_Detalle,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Despachado,'|' ,
			 @Descripcion,'|' ,
			 @PrecioUnitario,'|' ,
			 @Descuento,'|' ,
			 @Sub_Total,'|' ,
			 @Tipo,'|' ,
			 @Obs_ComprobanteD,'|' ,
			 @Cod_Manguera,'|' ,
			 @Flag_AplicaImpuesto,'|' ,
			 @Formalizado,'|' ,
			 @Valor_NoOneroso,'|' ,
			 @Cod_TipoISC,'|' ,
			 @Porcentaje_ISC,'|' ,
			 @ISC,'|' ,
			 @Cod_TipoIGV,'|' ,
			 @Porcentaje_IGV,'|' ,
			 @IGV,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_COMPROBANTE_LOG
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_LOG_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_LOG_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_LOG_IUD
ON dbo.CAJ_COMPROBANTE_LOG
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @Item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_LOG'
	--Variables de tabla secundarias
	DECLARE @Cod_Estado varchar(32)
	DECLARE @Cod_Mensaje varchar(32)
	DECLARE @Mensaje varchar(512)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.Item,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_CAJ_COMPROBANTE_LOG_I ' +
				 CASE WHEN ccp.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Cod_TipoComprobante,'''','')+''','END +
				 CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Serie,'''','')+''','END +
				 CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Numero,'''','')+''','END +
				 CONVERT(varchar(max),ccl.Item)+','+
				 CASE WHEN ccl.Cod_Estado IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccl.Cod_Estado,'''','')+''','END +
				 CASE WHEN ccl.Cod_Mensaje IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccl.Cod_Mensaje,'''','')+''','END +
				 CASE WHEN ccl.Mensaje IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccl.Mensaje,'''','')+''','END +
				 ''''+REPLACE(COALESCE(ccl.Cod_UsuarioAct,ccl.Cod_UsuarioReg),'''','')   +''';' 
				 FROM INSERTED ccl INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp 
				 ON ccp.id_ComprobantePago=ccl.id_ComprobantePago
				 WHERE ccl.id_ComprobantePago=@id_ComprobantePago AND ccl.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_CAJ_COMPROBANTE_LOG_D ' +
				 CASE WHEN ccp.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Cod_TipoComprobante,'''','')+''','END +
				 CASE WHEN ccp.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Serie,'''','')+''','END +
				 CASE WHEN ccp.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ccp.Numero,'''','')+''','END +
				 CONVERT(varchar(max),ccl.Item)+','+
				 ''''+'TRIGGER'+''',' +
				 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM DELETED ccl INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp 
				 ON ccp.id_ComprobantePago=ccl.id_ComprobantePago
				 WHERE ccl.id_ComprobantePago=@id_ComprobantePago AND ccl.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.Item,
			 i.Cod_Estado,
			 i.Cod_Mensaje,
			 i.Mensaje,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Item,
			 @Cod_Estado,
			 @Cod_Mensaje,
			 @Mensaje,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Item,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Mensaje,'|' ,
			 @Mensaje,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Item,
			 @Cod_Estado,
			 @Cod_Mensaje,
			 @Mensaje,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.Item,
			 d.Cod_Estado,
			 d.Cod_Mensaje,
			 d.Mensaje,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Item,
			 @Cod_Estado,
			 @Cod_Mensaje,
			 @Mensaje,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Item,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Mensaje,'|' ,
			 @Mensaje,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Item,
			 @Cod_Estado,
			 @Cod_Mensaje,
			 @Mensaje,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_COMPROBANTE_PAGO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
ON dbo.CAJ_COMPROBANTE_PAGO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_PAGO'
	--Variables de tabla secundarias
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Cod_Periodo varchar(8)
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_TipoOperacion varchar(5)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(5)
	DECLARE @Numero varchar(30)
	DECLARE @Id_Cliente int
	DECLARE @Cod_TipoDoc varchar(2)
	DECLARE @Doc_Cliente varchar(20)
	DECLARE @Nom_Cliente varchar(512)
	DECLARE @Direccion_Cliente varchar(512)
	DECLARE @FechaEmision datetime
	DECLARE @FechaVencimiento datetime
	DECLARE @FechaCancelacion datetime
	DECLARE @Glosa varchar(512)
	DECLARE @TipoCambio numeric(10,4)
	DECLARE @Flag_Anulado bit
	DECLARE @Flag_Despachado bit
	DECLARE @Cod_FormaPago varchar(5)
	DECLARE @Descuento_Total numeric(38,2)
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Impuesto numeric(38,6)
	DECLARE @Total numeric(38,2)
	DECLARE @Obs_Comprobante xml
	DECLARE @Id_GuiaRemision int
	DECLARE @GuiaRemision varchar(50)
	DECLARE @id_ComprobanteRef int
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Nro_Ticketera varchar(64)
	DECLARE @Cod_UsuarioVendedor varchar(32)
	DECLARE @Cod_RegimenPercepcion varchar(8)
	DECLARE @Tasa_Percepcion numeric(38,2)
	DECLARE @Placa_Vehiculo varchar(64)
	DECLARE @Cod_TipoDocReferencia varchar(8)
	DECLARE @Nro_DocReferencia varchar(64)
	DECLARE @Valor_Resumen varchar(1024)
	DECLARE @Valor_Firma varchar(2048)
	DECLARE @Cod_EstadoComprobante varchar(8)
	DECLARE @MotivoAnulacion varchar(512)
	DECLARE @Otros_Cargos numeric(38,2)
	DECLARE @Otros_Tributos numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF ((@Exportacion=1 AND @Accion='INSERTAR') 
	OR (@Exportacion=1 AND @Accion='ACTUALIZAR' AND 
	NOT UPDATE(Valor_Resumen) AND
	NOT UPDATE(Valor_Firma) AND
	NOT UPDATE(Cod_EstadoComprobante) AND
    NOT UPDATE(Id_Cliente)
	))
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_I '+ 
			  CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			  CASE WHEN CP.Cod_Periodo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Periodo,'''','')+''',' END +
			  CASE WHEN CP.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Caja,'''','')+''',' END +
			  CASE WHEN CP.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Turno,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoOperacion,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			  CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			  CASE WHEN CP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN CP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Doc_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nom_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Direccion_Cliente,'''','')+''',' END +
			  CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision,121)+''','END+ 
			  CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento,121)+''','END+ 
			  CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion,121)+''','END+ 
			  CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Glosa,'''','')+''',' END +
			  CASE WHEN CP.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.TipoCambio)+','END+
			  CONVERT(VARCHAR(MAX),CP.Flag_Anulado)+','+ 
			  CONVERT(VARCHAR(MAX),CP.Flag_Despachado)+','+ 
			  CASE WHEN CP.Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_FormaPago,'''','')+''',' END +
			  CASE WHEN CP.Descuento_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Descuento_Total)+','END+
			  CASE WHEN CP.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Moneda,'''','')+''',' END +
			  CASE WHEN CP.Impuesto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Impuesto)+','END+
			  CASE WHEN CP.Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Total)+','END+
			  CASE WHEN CP.Obs_Comprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),CP.Obs_Comprobante),'''','')+''','END+
			  CASE WHEN CP.Id_GuiaRemision IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Id_GuiaRemision)+','END+
			  CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.GuiaRemision,'''','')+''','END+

			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+

			  CASE WHEN CP.Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Plantilla,'''','')+''',' END +
			  CASE WHEN CP.Nro_Ticketera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_Ticketera,'''','')+''',' END +
			  CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_UsuarioVendedor,'''','')+''',' END +
			  CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_RegimenPercepcion,'''','')+''',' END +
			  CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
			  CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( CP.Placa_Vehiculo,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoDocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDocReferencia,'''','')+''',' END +
			  CASE WHEN CP.Nro_DocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_DocReferencia,'''','')+''',' END +
			  'NULL,'+
			  'NULL,'+
			  CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_EstadoComprobante,'''','')+''',' END +
			  CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.MotivoAnulacion,'''','')+''',' END +
			  CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
			  CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
			  ''''+REPLACE(COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg),'''','')+ ''';' 	 
			  FROM            INSERTED   CP 
			  WHERE CP.id_ComprobantePago=@id_ComprobantePago


		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END 

    IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			 SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_D '+ 
			 CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			 CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			 CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			 CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			 ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 	 
			 FROM            DELETED  CP 
			 WHERE CP.id_ComprobantePago=@id_ComprobantePago

		   	    SET @FechaReg= GETDATE()
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
				  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
				  @Accion, -- Accion - varchar
				  @Script, -- Script - varchar
				  @FechaReg -- Fecha_Reg - datetime
			    )
			 FETCH NEXT FROM cursorbd INTO
			   @id_ComprobantePago,
			   @Fecha_Reg,
			   @Fecha_Act
		    END
		    CLOSE cursorbd;
    		DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.Cod_Libro,
			 i.Cod_Periodo,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Cod_TipoOperacion,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Numero,
			 i.Id_Cliente,
			 i.Cod_TipoDoc,
			 i.Doc_Cliente,
			 i.Nom_Cliente,
			 i.Direccion_Cliente,
			 i.FechaEmision,
			 i.FechaVencimiento,
			 i.FechaCancelacion,
			 i.Glosa,
			 i.TipoCambio,
			 i.Flag_Anulado,
			 i.Flag_Despachado,
			 i.Cod_FormaPago,
			 i.Descuento_Total,
			 i.Cod_Moneda,
			 i.Impuesto,
			 i.Total,
			 i.Obs_Comprobante,
			 i.Id_GuiaRemision,
			 i.GuiaRemision,
			 i.id_ComprobanteRef,
			 i.Cod_Plantilla,
			 i.Nro_Ticketera,
			 i.Cod_UsuarioVendedor,
			 i.Cod_RegimenPercepcion,
			 i.Tasa_Percepcion,
			 i.Placa_Vehiculo,
			 i.Cod_TipoDocReferencia,
			 i.Nro_DocReferencia,
			 i.Valor_Resumen,
			 i.Valor_Firma,
			 i.Cod_EstadoComprobante,
			 i.MotivoAnulacion,
			 i.Otros_Cargos,
			 i.Otros_Tributos,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(varchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.Cod_Libro,
			 d.Cod_Periodo,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Cod_TipoOperacion,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Numero,
			 d.Id_Cliente,
			 d.Cod_TipoDoc,
			 d.Doc_Cliente,
			 d.Nom_Cliente,
			 d.Direccion_Cliente,
			 d.FechaEmision,
			 d.FechaVencimiento,
			 d.FechaCancelacion,
			 d.Glosa,
			 d.TipoCambio,
			 d.Flag_Anulado,
			 d.Flag_Despachado,
			 d.Cod_FormaPago,
			 d.Descuento_Total,
			 d.Cod_Moneda,
			 d.Impuesto,
			 d.Total,
			 d.Obs_Comprobante,
			 d.Id_GuiaRemision,
			 d.GuiaRemision,
			 d.id_ComprobanteRef,
			 d.Cod_Plantilla,
			 d.Nro_Ticketera,
			 d.Cod_UsuarioVendedor,
			 d.Cod_RegimenPercepcion,
			 d.Tasa_Percepcion,
			 d.Placa_Vehiculo,
			 d.Cod_TipoDocReferencia,
			 d.Nro_DocReferencia,
			 d.Valor_Resumen,
			 d.Valor_Firma,
			 d.Cod_EstadoComprobante,
			 d.MotivoAnulacion,
			 d.Otros_Cargos,
			 d.Otros_Tributos,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(varchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_COMPROBANTE_RELACION
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_IUD
ON dbo.CAJ_COMPROBANTE_RELACION
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @id_Detalle int
	DECLARE @Item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_RELACION'
	--Variables de tabla secundarias
	DECLARE @Id_ComprobanteRelacion int
	DECLARE @Cod_TipoRelacion varchar(8)
	DECLARE @Valor numeric(38,6)
	DECLARE @Obs_Relacion varchar(1024)
	DECLARE @Id_DetalleRelacion int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.id_Detalle,
		    i.Item,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_CAJ_COMPROBANTE_RELACION_I '+ 
			  CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			  CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			  CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			  CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Doc_Cliente,'''','')+''',' END +
			  CONVERT(VARCHAR(MAX),R.id_Detalle)+','+ 
			  CONVERT(VARCHAR(MAX),R.Item) +','+ 
			  CASE WHEN PP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_Libro,'''','')+''',' END +
			  CASE WHEN PP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN PP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Serie,'''','')+''',' END +
			  CASE WHEN PP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Numero,'''','')+''',' END +	
			  CASE WHEN PP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN PP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Doc_Cliente,'''','')+''',' END +
			  CASE WHEN R.Cod_TipoRelacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(R.Cod_TipoRelacion,'''','')+''',' END +	
			  CASE WHEN R.Valor IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),R.VALOR)+','END+ 
			  CASE WHEN R.Obs_Relacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(R.Obs_Relacion,'''','')+''',' END +	
			  CASE WHEN R.Id_DetalleRelacion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),R.Id_DetalleRelacion)+','END+ 
			  ''''+REPLACE(COALESCE(R.Cod_UsuarioAct,R.Cod_UsuarioReg),'''','')+ ''';' 
			  FROM  INSERTED  R INNER JOIN
				   CAJ_COMPROBANTE_PAGO AS P ON R.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
				   CAJ_COMPROBANTE_PAGO AS PP ON R.Id_ComprobanteRelacion = PP.id_ComprobantePago
			 WHERE 
				R.id_ComprobantePago=@id_ComprobantePago AND R.id_Detalle=@id_Detalle AND R.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.id_Detalle,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_CAJ_COMPROBANTE_RELACION_D'+ 
			  CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			  CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			  CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			  CONVERT(VARCHAR(MAX),R.id_Detalle)+','+ 
			  CONVERT(VARCHAR(MAX),R.Item) +','+ 
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  R INNER JOIN
				   CAJ_COMPROBANTE_PAGO AS P ON R.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
				   CAJ_COMPROBANTE_PAGO AS PP ON R.Id_ComprobanteRelacion = PP.id_ComprobantePago
			 WHERE 
				R.id_ComprobantePago=@id_ComprobantePago AND R.id_Detalle=@id_Detalle AND R.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @id_Detalle,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.id_Detalle,
			 i.Item,
			 i.Id_ComprobanteRelacion,
			 i.Cod_TipoRelacion,
			 i.Valor,
			 i.Obs_Relacion,
			 i.Id_DetalleRelacion,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @id_Detalle,
			 @Item,
			 @Id_ComprobanteRelacion,
			 @Cod_TipoRelacion,
			 @Valor,
			 @Obs_Relacion,
			 @Id_DetalleRelacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @id_Detalle,'|' ,
			 @Item,'|' ,
			 @Id_ComprobanteRelacion,'|' ,
			 @Cod_TipoRelacion,'|' ,
			 @Valor,'|' ,
			 @Obs_Relacion,'|' ,
			 @Id_DetalleRelacion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ComprobantePago,'|',@id_Detalle,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @id_Detalle,
			 @Item,
			 @Id_ComprobanteRelacion,
			 @Cod_TipoRelacion,
			 @Valor,
			 @Obs_Relacion,
			 @Id_DetalleRelacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.id_Detalle,
			 d.Item,
			 d.Id_ComprobanteRelacion,
			 d.Cod_TipoRelacion,
			 d.Valor,
			 d.Obs_Relacion,
			 d.Id_DetalleRelacion,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @id_Detalle,
			 @Item,
			 @Id_ComprobanteRelacion,
			 @Cod_TipoRelacion,
			 @Valor,
			 @Obs_Relacion,
			 @Id_DetalleRelacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @id_Detalle,'|' ,
			 @Item,'|' ,
			 @Id_ComprobanteRelacion,'|' ,
			 @Cod_TipoRelacion,'|' ,
			 @Valor,'|' ,
			 @Obs_Relacion,'|' ,
			 @Id_DetalleRelacion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@id_ComprobantePago,'|',@id_Detalle,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @id_Detalle,
			 @Item,
			 @Id_ComprobanteRelacion,
			 @Cod_TipoRelacion,
			 @Valor,
			 @Obs_Relacion,
			 @Id_DetalleRelacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_CONCEPTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_CONCEPTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_CONCEPTO_IUD
GO

CREATE TRIGGER UTR_CAJ_CONCEPTO_IUD
ON dbo.CAJ_CONCEPTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Concepto int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_CONCEPTO'
	--Variables de tabla secundarias
	DECLARE @Des_Concepto varchar(512)
	DECLARE @Cod_ClaseConcepto varchar(3)
	DECLARE @Flag_Activo bit
	DECLARE @Id_ConceptoPadre int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Concepto,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Concepto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_CONCEPTO_I ' + 
			  CONVERT(VARCHAR(MAX),Id_Concepto)+','+  
			  ''''+REPLACE(Des_Concepto,'''','')+''','+  
			  ''''+REPLACE(Cod_ClaseConcepto,'''','')+''','+  
			  CONVERT(VARCHAR(MAX),Flag_Activo)+','+
			  CASE WHEN Id_ConceptoPadre IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Id_ConceptoPadre)+','END+ 
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
			  FROM            INSERTED
			  WHERE INSERTED.Id_Concepto=@Id_Concepto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Concepto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Concepto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Concepto,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Concepto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_CONCEPTO_D ' + 
			  CONVERT(VARCHAR(MAX),d.Id_Concepto)+','+  
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED d
			  WHERE d.Id_Concepto=@Id_Concepto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Concepto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Concepto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Concepto,
			 i.Des_Concepto,
			 i.Cod_ClaseConcepto,
			 i.Flag_Activo,
			 i.Id_ConceptoPadre,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Concepto,
			 @Des_Concepto,
			 @Cod_ClaseConcepto,
			 @Flag_Activo,
			 @Id_ConceptoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Concepto,'|' ,
			 @Des_Concepto,'|' ,
			 @Cod_ClaseConcepto,'|' ,
			 @Flag_Activo,'|' ,
			 @Id_ConceptoPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Concepto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Concepto,
			 @Des_Concepto,
			 @Cod_ClaseConcepto,
			 @Flag_Activo,
			 @Id_ConceptoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Concepto,
			 d.Des_Concepto,
			 d.Cod_ClaseConcepto,
			 d.Flag_Activo,
			 d.Id_ConceptoPadre,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Concepto,
			 @Des_Concepto,
			 @Cod_ClaseConcepto,
			 @Flag_Activo,
			 @Id_ConceptoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Concepto,'|' ,
			 @Des_Concepto,'|' ,
			 @Cod_ClaseConcepto,'|' ,
			 @Flag_Activo,'|' ,
			 @Id_ConceptoPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Concepto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Concepto,
			 @Des_Concepto,
			 @Cod_ClaseConcepto,
			 @Flag_Activo,
			 @Id_ConceptoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_FORMA_PAGO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_FORMA_PAGO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_FORMA_PAGO_IUD
GO

CREATE TRIGGER UTR_CAJ_FORMA_PAGO_IUD
ON dbo.CAJ_FORMA_PAGO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @Item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_FORMA_PAGO'
	--Variables de tabla secundarias
	DECLARE @Des_FormaPago varchar(512)
	DECLARE @Cod_TipoFormaPago varchar(3)
	DECLARE @Cuenta_CajaBanco varchar(64)
	DECLARE @Id_Movimiento int
	DECLARE @TipoCambio numeric(10,4)
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Monto numeric(38,2)
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Obs_FormaPago xml
	DECLARE @Fecha datetime
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce) 
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.Item,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_CAJ_FORMA_PAGO_I '+ 
				 CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
				 CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
				 CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
				 CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
				 CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoDoc,'''','')+''',' END +
				 CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Doc_Cliente,'''','')+''',' END +
				 CONVERT(VARCHAR(MAX),F.Item)+','+ 
				 CASE WHEN F.Des_FormaPago IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Des_FormaPago,'''','')+''','END+ 
				 CASE WHEN F.Cod_TipoFormaPago IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Cod_TipoFormaPago,'''','')+''','END+ 
				 CASE WHEN F.Cuenta_CajaBanco IS NULL THEN 'NULL,' ELSE ''''+REPLACE(F.Cuenta_CajaBanco,'''','')+''',' END +	
				 CASE WHEN F.Id_Movimiento IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.Id_Movimiento)+','END+ 
				 CASE WHEN F.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.TipoCambio)+','END+ 
				 CASE WHEN F.Cod_Moneda IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Cod_Moneda,'''','')+''','END+ 
				 CASE WHEN F.Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),F.Monto)+','END+ 
				 CASE WHEN F.Cod_Caja IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Cod_Caja,'''','') +''','END+ 
				 CASE WHEN F.Cod_Turno IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Cod_Turno,'''','') +''','END+ 
				 CASE WHEN F.Cod_Plantilla IS NULL THEN 'NULL,' ELSE  ''''+REPLACE(F.Cod_Plantilla,'''','') +''','END+ 
				 CASE WHEN F.Obs_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),F.Obs_FormaPago),'''','')+''','END+ 
				 CASE WHEN F.Fecha IS NULL THEN 'NULL,' ELSE '''' +CONVERT(VARCHAR(MAX),F.Fecha,121)+''','END+ 
				 ''''+REPLACE(COALESCE(F.Cod_UsuarioAct,F.Cod_UsuarioReg),'''','')+ ''';' 
				 FROM  INSERTED  F INNER JOIN
				    CAJ_COMPROBANTE_PAGO AS P ON F.id_ComprobantePago = P.id_ComprobantePago
				 WHERE F.id_ComprobantePago=@id_ComprobantePago AND F.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.Item,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_CAJ_FORMA_PAGO_D '+ 
				 CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
				 CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
				 CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
				 CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
				 CONVERT(VARCHAR(MAX),F.Item)+','+ 
				 ''''+'TRIGGER'+''',' +
				 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM  DELETED  F INNER JOIN
				    CAJ_COMPROBANTE_PAGO AS P ON F.id_ComprobantePago = P.id_ComprobantePago
				 WHERE F.id_ComprobantePago=@id_ComprobantePago AND F.Item=@Item

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Item,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.Item,
			 i.Des_FormaPago,
			 i.Cod_TipoFormaPago,
			 i.Cuenta_CajaBanco,
			 i.Id_Movimiento,
			 i.TipoCambio,
			 i.Cod_Moneda,
			 i.Monto,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Cod_Plantilla,
			 i.Obs_FormaPago,
			 i.Fecha,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Item,'|' ,
			 @Des_FormaPago,'|' ,
			 @Cod_TipoFormaPago,'|' ,
			 @Cuenta_CajaBanco,'|' ,
			 @Id_Movimiento,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_Moneda,'|' ,
			 @Monto,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_Plantilla,'|' ,
			 CONVERT(varchar(max),@Obs_FormaPago),'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.Item,
			 d.Des_FormaPago,
			 d.Cod_TipoFormaPago,
			 d.Cuenta_CajaBanco,
			 d.Id_Movimiento,
			 d.TipoCambio,
			 d.Cod_Moneda,
			 d.Monto,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Cod_Plantilla,
			 d.Obs_FormaPago,
			 d.Fecha,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Item,'|' ,
			 @Des_FormaPago,'|' ,
			 @Cod_TipoFormaPago,'|' ,
			 @Cuenta_CajaBanco,'|' ,
			 @Id_Movimiento,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_Moneda,'|' ,
			 @Monto,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_Plantilla,'|' ,
			 CONVERT(varchar(max),@Obs_FormaPago),'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@id_ComprobantePago,'|',@Item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_MEDICION_VC
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_MEDICION_VC_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_MEDICION_VC_IUD
GO

CREATE TRIGGER UTR_CAJ_MEDICION_VC_IUD
ON dbo.CAJ_MEDICION_VC
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Medicion int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_MEDICION_VC'
	--Variables de tabla secundarias
	DECLARE @Cod_AMedir varchar(32)
	DECLARE @Medio_AMedir varchar(32)
	DECLARE @Medida_Anterior numeric(38,4)
	DECLARE @Medida_Actual numeric(38,4)
	DECLARE @Fecha_Medicion datetime
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_UsuarioMedicion varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Medicion,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Medicion,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_MEDICION_VC_I ' + 
			  CASE WHEN Cod_AMedir IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_AMedir,'''','')+''','END+
 			  CASE WHEN Medio_AMedir IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Medio_AMedir,'''','')+''','END+
			  CASE WHEN Medida_Anterior IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Medida_Anterior)+','END+
			  CASE WHEN Medida_Actual IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),Medida_Actual)+','END+
			  CASE WHEN Fecha_Medicion IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Medicion,121)+''','END+
			  CASE WHEN Cod_Turno  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','')+''','END+
			  CASE WHEN Cod_UsuarioMedicion  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_UsuarioMedicion,'''','')+''','END+
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED 
			  WHERE @Id_Medicion=Id_Medicion

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Medicion), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Medicion,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Medicion,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Medicion,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT  @Script= 'USP_CAJ_MEDICION_VC_D ' + 
			  CASE WHEN Cod_AMedir IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_AMedir,'''','')+''','END+
 			  CASE WHEN Medio_AMedir IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Medio_AMedir,'''','')+''','END+
			  CASE WHEN Cod_Turno  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Turno,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  
			  WHERE @Id_Medicion=Id_Medicion

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Medicion), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Medicion,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Medicion,
			 i.Cod_AMedir,
			 i.Medio_AMedir,
			 i.Medida_Anterior,
			 i.Medida_Actual,
			 i.Fecha_Medicion,
			 i.Cod_Turno,
			 i.Cod_UsuarioMedicion,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Medicion,
			 @Cod_AMedir,
			 @Medio_AMedir,
			 @Medida_Anterior,
			 @Medida_Actual,
			 @Fecha_Medicion,
			 @Cod_Turno,
			 @Cod_UsuarioMedicion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Medicion,'|' ,
			 @Cod_AMedir,'|' ,
			 @Medio_AMedir,'|' ,
			 @Medida_Anterior,'|' ,
			 @Medida_Actual,'|' ,
			 CONVERT(varchar,@Fecha_Medicion,121), '|' ,
			 @Cod_Turno,'|' ,
			 @Cod_UsuarioMedicion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Medicion), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Medicion,
			 @Cod_AMedir,
			 @Medio_AMedir,
			 @Medida_Anterior,
			 @Medida_Actual,
			 @Fecha_Medicion,
			 @Cod_Turno,
			 @Cod_UsuarioMedicion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Medicion,
			 d.Cod_AMedir,
			 d.Medio_AMedir,
			 d.Medida_Anterior,
			 d.Medida_Actual,
			 d.Fecha_Medicion,
			 d.Cod_Turno,
			 d.Cod_UsuarioMedicion,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Medicion,
			 @Cod_AMedir,
			 @Medio_AMedir,
			 @Medida_Anterior,
			 @Medida_Actual,
			 @Fecha_Medicion,
			 @Cod_Turno,
			 @Cod_UsuarioMedicion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Medicion,'|' ,
			 @Cod_AMedir,'|' ,
			 @Medio_AMedir,'|' ,
			 @Medida_Anterior,'|' ,
			 @Medida_Actual,'|' ,
			 CONVERT(varchar,@Fecha_Medicion,121), '|' ,
			 @Cod_Turno,'|' ,
			 @Cod_UsuarioMedicion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Medicion), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Medicion,
			 @Cod_AMedir,
			 @Medio_AMedir,
			 @Medida_Anterior,
			 @Medida_Actual,
			 @Fecha_Medicion,
			 @Cod_Turno,
			 @Cod_UsuarioMedicion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_SERIES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_SERIES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_SERIES_IUD
GO

CREATE TRIGGER UTR_CAJ_SERIES_IUD
ON dbo.CAJ_SERIES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tabla varchar(64)
	DECLARE @Id_Tabla int
	DECLARE @Item int
	DECLARE @Serie varchar(512)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_SERIES'
	--Variables de tabla secundarias
	DECLARE @Fecha_Vencimiento datetime
	DECLARE @Obs_Serie varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Tabla,
	--	    i.Id_Tabla,
	--	    i.Item,
	--	    i.Serie,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tabla,
	--	    @Id_Tabla,
	--	    @Item,
	--	    @Serie,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tabla,
	--	    @Id_Tabla,
	--	    @Item,
	--	    @Serie,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tabla,
			 i.Id_Tabla,
			 i.Item,
			 i.Serie,
			 i.Fecha_Vencimiento,
			 i.Obs_Serie,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Id_Tabla,'|' ,
			 @Item,'|' ,
			 @Serie,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Obs_Serie,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tabla,
			 d.Id_Tabla,
			 d.Item,
			 d.Serie,
			 d.Fecha_Vencimiento,
			 d.Obs_Serie,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Id_Tabla,'|' ,
			 @Item,'|' ,
			 @Serie,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Obs_Serie,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_TIPOCAMBIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_TIPOCAMBIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_TIPOCAMBIO_IUD
GO

CREATE TRIGGER UTR_CAJ_TIPOCAMBIO_IUD
ON dbo.CAJ_TIPOCAMBIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_TipoCambio int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_TIPOCAMBIO'
	--Variables de tabla secundarias
	DECLARE @FechaHora datetime
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @SunatCompra numeric(38,4)
	DECLARE @SunatVenta numeric(38,4)
	DECLARE @Compra numeric(38,4)
	DECLARE @Venta numeric(38,4)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_TipoCambio,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_TipoCambio,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_TIPOCAMBIO_I ' +
			  CASE WHEN ct.FechaHora IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max),ct.FechaHora,121)+''','END +
			  CASE WHEN ct.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ct.Cod_Moneda,'''','')+''','END +
			  CASE WHEN ct.SunatCompra IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.SunatCompra)+','END +
			  CASE WHEN ct.SunatVenta IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.SunatVenta)+','END +
			  CASE WHEN ct.Compra IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.Compra)+','END +
			  CASE WHEN ct.Venta IS NULL THEN 'NULL,' ELSE convert(varchar(max),ct.Venta)+','END +
			  ''''+REPLACE(COALESCE(ct.Cod_UsuarioAct,ct.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  ct
			  WHERE ct.Id_TipoCambio=@Id_TipoCambio

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_TipoCambio), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_TipoCambio,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_TipoCambio,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_TipoCambio,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_CAJ_TIPOCAMBIO_D ' +
			  CASE WHEN ct.FechaHora IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max),ct.FechaHora,121)+''','END +
			  CASE WHEN ct.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ct.Cod_Moneda,'''','')+''','END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  ct
			  WHERE ct.Id_TipoCambio=@Id_TipoCambio

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_TipoCambio), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_TipoCambio,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_TipoCambio,
			 i.FechaHora,
			 i.Cod_Moneda,
			 i.SunatCompra,
			 i.SunatVenta,
			 i.Compra,
			 i.Venta,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_TipoCambio,
			 @FechaHora,
			 @Cod_Moneda,
			 @SunatCompra,
			 @SunatVenta,
			 @Compra,
			 @Venta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_TipoCambio,'|' ,
			 CONVERT(varchar,@FechaHora,121), '|' ,
			 @Cod_Moneda,'|' ,
			 @SunatCompra,'|' ,
			 @SunatVenta,'|' ,
			 @Compra,'|' ,
			 @Venta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_TipoCambio), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_TipoCambio,
			 @FechaHora,
			 @Cod_Moneda,
			 @SunatCompra,
			 @SunatVenta,
			 @Compra,
			 @Venta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_TipoCambio,
			 d.FechaHora,
			 d.Cod_Moneda,
			 d.SunatCompra,
			 d.SunatVenta,
			 d.Compra,
			 d.Venta,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_TipoCambio,
			 @FechaHora,
			 @Cod_Moneda,
			 @SunatCompra,
			 @SunatVenta,
			 @Compra,
			 @Venta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_TipoCambio,'|' ,
			 CONVERT(varchar,@FechaHora,121), '|' ,
			 @Cod_Moneda,'|' ,
			 @SunatCompra,'|' ,
			 @SunatVenta,'|' ,
			 @Compra,'|' ,
			 @Venta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_TipoCambio), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_TipoCambio,
			 @FechaHora,
			 @Cod_Moneda,
			 @SunatCompra,
			 @SunatVenta,
			 @Compra,
			 @Venta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAJ_TRANSFERENCIAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_TRANSFERENCIAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_TRANSFERENCIAS_IUD
GO

CREATE TRIGGER UTR_CAJ_TRANSFERENCIAS_IUD
ON dbo.CAJ_TRANSFERENCIAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Transferencia int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_TRANSFERENCIAS'
	--Variables de tabla secundarias
	DECLARE @Fecha_Emision datetime
	DECLARE @Cod_UsuarioEmision varchar(32)
	DECLARE @Fecha_Pago datetime
	DECLARE @Cod_UsuarioPago varchar(32)
	DECLARE @id_ClienteEmisor int
	DECLARE @id_ClienteBeneficiarioP int
	DECLARE @id_ClienteBeneficiarioS int
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Monto numeric(38,4)
	DECLARE @Comision numeric(38,2)
	DECLARE @Otros numeric(38,2)
	DECLARE @Cod_Origen varchar(32)
	DECLARE @Cod_Destino varchar(32)
	DECLARE @Cod_Banco varchar(3)
	DECLARE @Num_Cuenta varchar(512)
	DECLARE @Cod_EstadoTransferencia varchar(3)
	DECLARE @Flag_Leido bit
	DECLARE @Id_MovimientoSolicitud int
	DECLARE @Id_MovimientoComision int
	DECLARE @Id_MovimientoOtros int
	DECLARE @Id_MovimientoPago int
	DECLARE @Id_ComprobanteSolicitud int
	DECLARE @Obs_Tranferencia varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Transferencia,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Transferencia,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Transferencia), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Transferencia,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Transferencia,
			 i.Fecha_Emision,
			 i.Cod_UsuarioEmision,
			 i.Fecha_Pago,
			 i.Cod_UsuarioPago,
			 i.id_ClienteEmisor,
			 i.id_ClienteBeneficiarioP,
			 i.id_ClienteBeneficiarioS,
			 i.Cod_Moneda,
			 i.Monto,
			 i.Comision,
			 i.Otros,
			 i.Cod_Origen,
			 i.Cod_Destino,
			 i.Cod_Banco,
			 i.Num_Cuenta,
			 i.Cod_EstadoTransferencia,
			 i.Flag_Leido,
			 i.Id_MovimientoSolicitud,
			 i.Id_MovimientoComision,
			 i.Id_MovimientoOtros,
			 i.Id_MovimientoPago,
			 i.Id_ComprobanteSolicitud,
			 i.Obs_Tranferencia,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Transferencia,
			 @Fecha_Emision,
			 @Cod_UsuarioEmision,
			 @Fecha_Pago,
			 @Cod_UsuarioPago,
			 @id_ClienteEmisor,
			 @id_ClienteBeneficiarioP,
			 @id_ClienteBeneficiarioS,
			 @Cod_Moneda,
			 @Monto,
			 @Comision,
			 @Otros,
			 @Cod_Origen,
			 @Cod_Destino,
			 @Cod_Banco,
			 @Num_Cuenta,
			 @Cod_EstadoTransferencia,
			 @Flag_Leido,
			 @Id_MovimientoSolicitud,
			 @Id_MovimientoComision,
			 @Id_MovimientoOtros,
			 @Id_MovimientoPago,
			 @Id_ComprobanteSolicitud,
			 @Obs_Tranferencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Transferencia,'|' ,
			 CONVERT(varchar,@Fecha_Emision,121), '|' ,
			 @Cod_UsuarioEmision,'|' ,
			 CONVERT(varchar,@Fecha_Pago,121), '|' ,
			 @Cod_UsuarioPago,'|' ,
			 @id_ClienteEmisor,'|' ,
			 @id_ClienteBeneficiarioP,'|' ,
			 @id_ClienteBeneficiarioS,'|' ,
			 @Cod_Moneda,'|' ,
			 @Monto,'|' ,
			 @Comision,'|' ,
			 @Otros,'|' ,
			 @Cod_Origen,'|' ,
			 @Cod_Destino,'|' ,
			 @Cod_Banco,'|' ,
			 @Num_Cuenta,'|' ,
			 @Cod_EstadoTransferencia,'|' ,
			 @Flag_Leido,'|' ,
			 @Id_MovimientoSolicitud,'|' ,
			 @Id_MovimientoComision,'|' ,
			 @Id_MovimientoOtros,'|' ,
			 @Id_MovimientoPago,'|' ,
			 @Id_ComprobanteSolicitud,'|' ,
			 @Obs_Tranferencia,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Transferencia), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Transferencia,
			 @Fecha_Emision,
			 @Cod_UsuarioEmision,
			 @Fecha_Pago,
			 @Cod_UsuarioPago,
			 @id_ClienteEmisor,
			 @id_ClienteBeneficiarioP,
			 @id_ClienteBeneficiarioS,
			 @Cod_Moneda,
			 @Monto,
			 @Comision,
			 @Otros,
			 @Cod_Origen,
			 @Cod_Destino,
			 @Cod_Banco,
			 @Num_Cuenta,
			 @Cod_EstadoTransferencia,
			 @Flag_Leido,
			 @Id_MovimientoSolicitud,
			 @Id_MovimientoComision,
			 @Id_MovimientoOtros,
			 @Id_MovimientoPago,
			 @Id_ComprobanteSolicitud,
			 @Obs_Tranferencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Transferencia,
			 d.Fecha_Emision,
			 d.Cod_UsuarioEmision,
			 d.Fecha_Pago,
			 d.Cod_UsuarioPago,
			 d.id_ClienteEmisor,
			 d.id_ClienteBeneficiarioP,
			 d.id_ClienteBeneficiarioS,
			 d.Cod_Moneda,
			 d.Monto,
			 d.Comision,
			 d.Otros,
			 d.Cod_Origen,
			 d.Cod_Destino,
			 d.Cod_Banco,
			 d.Num_Cuenta,
			 d.Cod_EstadoTransferencia,
			 d.Flag_Leido,
			 d.Id_MovimientoSolicitud,
			 d.Id_MovimientoComision,
			 d.Id_MovimientoOtros,
			 d.Id_MovimientoPago,
			 d.Id_ComprobanteSolicitud,
			 d.Obs_Tranferencia,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Transferencia,
			 @Fecha_Emision,
			 @Cod_UsuarioEmision,
			 @Fecha_Pago,
			 @Cod_UsuarioPago,
			 @id_ClienteEmisor,
			 @id_ClienteBeneficiarioP,
			 @id_ClienteBeneficiarioS,
			 @Cod_Moneda,
			 @Monto,
			 @Comision,
			 @Otros,
			 @Cod_Origen,
			 @Cod_Destino,
			 @Cod_Banco,
			 @Num_Cuenta,
			 @Cod_EstadoTransferencia,
			 @Flag_Leido,
			 @Id_MovimientoSolicitud,
			 @Id_MovimientoComision,
			 @Id_MovimientoOtros,
			 @Id_MovimientoPago,
			 @Id_ComprobanteSolicitud,
			 @Obs_Tranferencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Transferencia,'|' ,
			 CONVERT(varchar,@Fecha_Emision,121), '|' ,
			 @Cod_UsuarioEmision,'|' ,
			 CONVERT(varchar,@Fecha_Pago,121), '|' ,
			 @Cod_UsuarioPago,'|' ,
			 @id_ClienteEmisor,'|' ,
			 @id_ClienteBeneficiarioP,'|' ,
			 @id_ClienteBeneficiarioS,'|' ,
			 @Cod_Moneda,'|' ,
			 @Monto,'|' ,
			 @Comision,'|' ,
			 @Otros,'|' ,
			 @Cod_Origen,'|' ,
			 @Cod_Destino,'|' ,
			 @Cod_Banco,'|' ,
			 @Num_Cuenta,'|' ,
			 @Cod_EstadoTransferencia,'|' ,
			 @Flag_Leido,'|' ,
			 @Id_MovimientoSolicitud,'|' ,
			 @Id_MovimientoComision,'|' ,
			 @Id_MovimientoOtros,'|' ,
			 @Id_MovimientoPago,'|' ,
			 @Id_ComprobanteSolicitud,'|' ,
			 @Obs_Tranferencia,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Transferencia), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Transferencia,
			 @Fecha_Emision,
			 @Cod_UsuarioEmision,
			 @Fecha_Pago,
			 @Cod_UsuarioPago,
			 @id_ClienteEmisor,
			 @id_ClienteBeneficiarioP,
			 @id_ClienteBeneficiarioS,
			 @Cod_Moneda,
			 @Monto,
			 @Comision,
			 @Otros,
			 @Cod_Origen,
			 @Cod_Destino,
			 @Cod_Banco,
			 @Num_Cuenta,
			 @Cod_EstadoTransferencia,
			 @Flag_Leido,
			 @Id_MovimientoSolicitud,
			 @Id_MovimientoComision,
			 @Id_MovimientoOtros,
			 @Id_MovimientoPago,
			 @Id_ComprobanteSolicitud,
			 @Obs_Tranferencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--CAJ_TURNO_ATENCION
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_TURNO_ATENCION_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_TURNO_ATENCION_IUD
GO

CREATE TRIGGER UTR_CAJ_TURNO_ATENCION_IUD
ON dbo.CAJ_TURNO_ATENCION
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_TURNO_ATENCION'
	--Variables de tabla secundarias
	DECLARE @Des_Turno varchar(512)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Flag_Cerrado bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Turno,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Turno,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @script='USP_CAJ_TURNO_ATENCION_I ' + 
			  ''''+REPLACE(Cod_Turno,'''','')+''','+ 
			  CASE WHEN Des_Turno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_Turno,'''','')+''','END+
			  CASE WHEN Fecha_Inicio IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Inicio,121)+''','END+
			  CASE WHEN Fecha_Fin IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Fin,121)+''','END+
			   CONVERT(VARCHAR(MAX),Flag_Cerrado)+','+
			  ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
			  FROM INSERTED 
			  WHERE 
			  Cod_Turno=@Cod_Turno

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Turno), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Turno,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Turno,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Turno,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @script='USP_CAJ_TURNO_ATENCION_D ' + 
			  ''''+REPLACE(Cod_Turno,'''','')+''','+ 
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED 	
			  WHERE 
			  Cod_Turno=@Cod_Turno

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Turno), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Turno,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Turno,
			 i.Des_Turno,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Flag_Cerrado,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Turno,
			 @Des_Turno,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Turno,'|' ,
			 @Des_Turno,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Flag_Cerrado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Turno), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Turno,
			 @Des_Turno,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Turno,
			 d.Des_Turno,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Flag_Cerrado,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Turno,
			 @Des_Turno,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Turno,'|' ,
			 @Des_Turno,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Flag_Cerrado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Turno), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Turno,
			 @Des_Turno,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Cerrado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CAL_CALENDARIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAL_CALENDARIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAL_CALENDARIO_IUD
GO

CREATE TRIGGER UTR_CAL_CALENDARIO_IUD
ON dbo.CAL_CALENDARIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Calendario int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAL_CALENDARIO'
	--Variables de tabla secundarias
	DECLARE @Asunto varchar(124)
	DECLARE @Ubicacion varchar(124)
	DECLARE @Flag_DiaEntero bit
	DECLARE @Fecha_Comienza datetime
	DECLARE @Fecha_Finaliza datetime
	DECLARE @Detalles varchar(max)
	DECLARE @MostrarComo varchar(64)
	DECLARE @Aviso int
	DECLARE @Flag_Prioridad bit
	DECLARE @Flag_Importante bit
	DECLARE @Flag_Privado bit
	DECLARE @Cod_UsuarioCreador varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Calendario,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Calendario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Calendario), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Calendario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Calendario,
			 i.Asunto,
			 i.Ubicacion,
			 i.Flag_DiaEntero,
			 i.Fecha_Comienza,
			 i.Fecha_Finaliza,
			 i.Detalles,
			 i.MostrarComo,
			 i.Aviso,
			 i.Flag_Prioridad,
			 i.Flag_Importante,
			 i.Flag_Privado,
			 i.Cod_UsuarioCreador,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Calendario,
			 @Asunto,
			 @Ubicacion,
			 @Flag_DiaEntero,
			 @Fecha_Comienza,
			 @Fecha_Finaliza,
			 @Detalles,
			 @MostrarComo,
			 @Aviso,
			 @Flag_Prioridad,
			 @Flag_Importante,
			 @Flag_Privado,
			 @Cod_UsuarioCreador,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Calendario,'|' ,
			 @Asunto,'|' ,
			 @Ubicacion,'|' ,
			 @Flag_DiaEntero,'|' ,
			 CONVERT(varchar,@Fecha_Comienza,121), '|' ,
			 CONVERT(varchar,@Fecha_Finaliza,121), '|' ,
			 @Detalles,'|' ,
			 @MostrarComo,'|' ,
			 @Aviso,'|' ,
			 @Flag_Prioridad,'|' ,
			 @Flag_Importante,'|' ,
			 @Flag_Privado,'|' ,
			 @Cod_UsuarioCreador,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Calendario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Calendario,
			 @Asunto,
			 @Ubicacion,
			 @Flag_DiaEntero,
			 @Fecha_Comienza,
			 @Fecha_Finaliza,
			 @Detalles,
			 @MostrarComo,
			 @Aviso,
			 @Flag_Prioridad,
			 @Flag_Importante,
			 @Flag_Privado,
			 @Cod_UsuarioCreador,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Calendario,
			 d.Asunto,
			 d.Ubicacion,
			 d.Flag_DiaEntero,
			 d.Fecha_Comienza,
			 d.Fecha_Finaliza,
			 d.Detalles,
			 d.MostrarComo,
			 d.Aviso,
			 d.Flag_Prioridad,
			 d.Flag_Importante,
			 d.Flag_Privado,
			 d.Cod_UsuarioCreador,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Calendario,
			 @Asunto,
			 @Ubicacion,
			 @Flag_DiaEntero,
			 @Fecha_Comienza,
			 @Fecha_Finaliza,
			 @Detalles,
			 @MostrarComo,
			 @Aviso,
			 @Flag_Prioridad,
			 @Flag_Importante,
			 @Flag_Privado,
			 @Cod_UsuarioCreador,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Calendario,'|' ,
			 @Asunto,'|' ,
			 @Ubicacion,'|' ,
			 @Flag_DiaEntero,'|' ,
			 CONVERT(varchar,@Fecha_Comienza,121), '|' ,
			 CONVERT(varchar,@Fecha_Finaliza,121), '|' ,
			 @Detalles,'|' ,
			 @MostrarComo,'|' ,
			 @Aviso,'|' ,
			 @Flag_Prioridad,'|' ,
			 @Flag_Importante,'|' ,
			 @Flag_Privado,'|' ,
			 @Cod_UsuarioCreador,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Calendario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Calendario,
			 @Asunto,
			 @Ubicacion,
			 @Flag_DiaEntero,
			 @Fecha_Comienza,
			 @Fecha_Finaliza,
			 @Detalles,
			 @MostrarComo,
			 @Aviso,
			 @Flag_Prioridad,
			 @Flag_Importante,
			 @Flag_Privado,
			 @Cod_UsuarioCreador,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CON_ASIENTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CON_ASIENTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CON_ASIENTO_IUD
GO

CREATE TRIGGER UTR_CON_ASIENTO_IUD
ON dbo.CON_ASIENTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Nro_Asiento varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CON_ASIENTO'
	--Variables de tabla secundarias
	DECLARE @Id_Comprobante int
	DECLARE @Cod_Periodo varchar(8)
	DECLARE @RUC varchar(32)
	DECLARE @RazonSocial varchar(512)
	DECLARE @Cod_TipoCom varchar(5)
	DECLARE @Serie_Com varchar(4)
	DECLARE @Num_Com varchar(16)
	DECLARE @Fecha_Com datetime
	DECLARE @Cod_TipoComRef varchar(5)
	DECLARE @Serie_ComRef varchar(4)
	DECLARE @Num_ComRef varchar(16)
	DECLARE @Fecha_ComRef datetime
	DECLARE @Cod_ComSunat varchar(64)
	DECLARE @Cod_TasaSunat varchar(5)
	DECLARE @Num_ComSunat varchar(32)
	DECLARE @Glosa_Asiento varchar(1024)
	DECLARE @Obs_Asiento varchar(1024)
	DECLARE @Tipo_Cambio numeric(10,4)
	DECLARE @Cod_Moneda varchar(4)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Sucursal,
	--	    i.Cod_Libro,
	--	    i.Nro_Asiento,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Sucursal,
	--	    @Cod_Libro,
	--	    @Nro_Asiento,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Sucursal,
	--	    @Cod_Libro,
	--	    @Nro_Asiento,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Sucursal,
			 i.Cod_Libro,
			 i.Nro_Asiento,
			 i.Id_Comprobante,
			 i.Cod_Periodo,
			 i.RUC,
			 i.RazonSocial,
			 i.Cod_TipoCom,
			 i.Serie_Com,
			 i.Num_Com,
			 i.Fecha_Com,
			 i.Cod_TipoComRef,
			 i.Serie_ComRef,
			 i.Num_ComRef,
			 i.Fecha_ComRef,
			 i.Cod_ComSunat,
			 i.Cod_TasaSunat,
			 i.Num_ComSunat,
			 i.Glosa_Asiento,
			 i.Obs_Asiento,
			 i.Tipo_Cambio,
			 i.Cod_Moneda,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Id_Comprobante,
			 @Cod_Periodo,
			 @RUC,
			 @RazonSocial,
			 @Cod_TipoCom,
			 @Serie_Com,
			 @Num_Com,
			 @Fecha_Com,
			 @Cod_TipoComRef,
			 @Serie_ComRef,
			 @Num_ComRef,
			 @Fecha_ComRef,
			 @Cod_ComSunat,
			 @Cod_TasaSunat,
			 @Num_ComSunat,
			 @Glosa_Asiento,
			 @Obs_Asiento,
			 @Tipo_Cambio,
			 @Cod_Moneda,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Asiento,'|' ,
			 @Id_Comprobante,'|' ,
			 @Cod_Periodo,'|' ,
			 @RUC,'|' ,
			 @RazonSocial,'|' ,
			 @Cod_TipoCom,'|' ,
			 @Serie_Com,'|' ,
			 @Num_Com,'|' ,
			 CONVERT(varchar,@Fecha_Com,121), '|' ,
			 @Cod_TipoComRef,'|' ,
			 @Serie_ComRef,'|' ,
			 @Num_ComRef,'|' ,
			 CONVERT(varchar,@Fecha_ComRef,121), '|' ,
			 @Cod_ComSunat,'|' ,
			 @Cod_TasaSunat,'|' ,
			 @Num_ComSunat,'|' ,
			 @Glosa_Asiento,'|' ,
			 @Obs_Asiento,'|' ,
			 @Tipo_Cambio,'|' ,
			 @Cod_Moneda,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Id_Comprobante,
			 @Cod_Periodo,
			 @RUC,
			 @RazonSocial,
			 @Cod_TipoCom,
			 @Serie_Com,
			 @Num_Com,
			 @Fecha_Com,
			 @Cod_TipoComRef,
			 @Serie_ComRef,
			 @Num_ComRef,
			 @Fecha_ComRef,
			 @Cod_ComSunat,
			 @Cod_TasaSunat,
			 @Num_ComSunat,
			 @Glosa_Asiento,
			 @Obs_Asiento,
			 @Tipo_Cambio,
			 @Cod_Moneda,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Sucursal,
			 d.Cod_Libro,
			 d.Nro_Asiento,
			 d.Id_Comprobante,
			 d.Cod_Periodo,
			 d.RUC,
			 d.RazonSocial,
			 d.Cod_TipoCom,
			 d.Serie_Com,
			 d.Num_Com,
			 d.Fecha_Com,
			 d.Cod_TipoComRef,
			 d.Serie_ComRef,
			 d.Num_ComRef,
			 d.Fecha_ComRef,
			 d.Cod_ComSunat,
			 d.Cod_TasaSunat,
			 d.Num_ComSunat,
			 d.Glosa_Asiento,
			 d.Obs_Asiento,
			 d.Tipo_Cambio,
			 d.Cod_Moneda,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Id_Comprobante,
			 @Cod_Periodo,
			 @RUC,
			 @RazonSocial,
			 @Cod_TipoCom,
			 @Serie_Com,
			 @Num_Com,
			 @Fecha_Com,
			 @Cod_TipoComRef,
			 @Serie_ComRef,
			 @Num_ComRef,
			 @Fecha_ComRef,
			 @Cod_ComSunat,
			 @Cod_TasaSunat,
			 @Num_ComSunat,
			 @Glosa_Asiento,
			 @Obs_Asiento,
			 @Tipo_Cambio,
			 @Cod_Moneda,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Asiento,'|' ,
			 @Id_Comprobante,'|' ,
			 @Cod_Periodo,'|' ,
			 @RUC,'|' ,
			 @RazonSocial,'|' ,
			 @Cod_TipoCom,'|' ,
			 @Serie_Com,'|' ,
			 @Num_Com,'|' ,
			 CONVERT(varchar,@Fecha_Com,121), '|' ,
			 @Cod_TipoComRef,'|' ,
			 @Serie_ComRef,'|' ,
			 @Num_ComRef,'|' ,
			 CONVERT(varchar,@Fecha_ComRef,121), '|' ,
			 @Cod_ComSunat,'|' ,
			 @Cod_TasaSunat,'|' ,
			 @Num_ComSunat,'|' ,
			 @Glosa_Asiento,'|' ,
			 @Obs_Asiento,'|' ,
			 @Tipo_Cambio,'|' ,
			 @Cod_Moneda,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Id_Comprobante,
			 @Cod_Periodo,
			 @RUC,
			 @RazonSocial,
			 @Cod_TipoCom,
			 @Serie_Com,
			 @Num_Com,
			 @Fecha_Com,
			 @Cod_TipoComRef,
			 @Serie_ComRef,
			 @Num_ComRef,
			 @Fecha_ComRef,
			 @Cod_ComSunat,
			 @Cod_TasaSunat,
			 @Num_ComSunat,
			 @Glosa_Asiento,
			 @Obs_Asiento,
			 @Tipo_Cambio,
			 @Cod_Moneda,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CON_ASIENTO_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CON_ASIENTO_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CON_ASIENTO_D_IUD
GO

CREATE TRIGGER UTR_CON_ASIENTO_D_IUD
ON dbo.CON_ASIENTO_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Nro_Asiento varchar(32)
	DECLARE @Nro_Detalle int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CON_ASIENTO_D'
	--Variables de tabla secundarias
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Cod_CuentaAnalitica varchar(64)
	DECLARE @Doc_CuentaAnalitica varchar(128)
	DECLARE @Debe_MN numeric(38,2)
	DECLARE @Haber_MN numeric(38,2)
	DECLARE @Debe_ME numeric(38,2)
	DECLARE @Haber_ME numeric(38,2)
	DECLARE @Cod_TipoOperacionAsiento varchar(5)
	DECLARE @Obs_AsientoD varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Sucursal,
	--	    i.Cod_Libro,
	--	    i.Nro_Asiento,
	--	    i.Nro_Detalle,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Sucursal,
	--	    @Cod_Libro,
	--	    @Nro_Asiento,
	--	    @Nro_Detalle,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento,'|',@Nro_Detalle,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Sucursal,
	--	    @Cod_Libro,
	--	    @Nro_Asiento,
	--	    @Nro_Detalle,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Sucursal,
			 i.Cod_Libro,
			 i.Nro_Asiento,
			 i.Nro_Detalle,
			 i.Cod_CuentaContable,
			 i.Cod_CuentaAnalitica,
			 i.Doc_CuentaAnalitica,
			 i.Debe_MN,
			 i.Haber_MN,
			 i.Debe_ME,
			 i.Haber_ME,
			 i.Cod_TipoOperacionAsiento,
			 i.Obs_AsientoD,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Nro_Detalle,
			 @Cod_CuentaContable,
			 @Cod_CuentaAnalitica,
			 @Doc_CuentaAnalitica,
			 @Debe_MN,
			 @Haber_MN,
			 @Debe_ME,
			 @Haber_ME,
			 @Cod_TipoOperacionAsiento,
			 @Obs_AsientoD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Asiento,'|' ,
			 @Nro_Detalle,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_CuentaAnalitica,'|' ,
			 @Doc_CuentaAnalitica,'|' ,
			 @Debe_MN,'|' ,
			 @Haber_MN,'|' ,
			 @Debe_ME,'|' ,
			 @Haber_ME,'|' ,
			 @Cod_TipoOperacionAsiento,'|' ,
			 @Obs_AsientoD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento,'|',@Nro_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Nro_Detalle,
			 @Cod_CuentaContable,
			 @Cod_CuentaAnalitica,
			 @Doc_CuentaAnalitica,
			 @Debe_MN,
			 @Haber_MN,
			 @Debe_ME,
			 @Haber_ME,
			 @Cod_TipoOperacionAsiento,
			 @Obs_AsientoD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Sucursal,
			 d.Cod_Libro,
			 d.Nro_Asiento,
			 d.Nro_Detalle,
			 d.Cod_CuentaContable,
			 d.Cod_CuentaAnalitica,
			 d.Doc_CuentaAnalitica,
			 d.Debe_MN,
			 d.Haber_MN,
			 d.Debe_ME,
			 d.Haber_ME,
			 d.Cod_TipoOperacionAsiento,
			 d.Obs_AsientoD,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Nro_Detalle,
			 @Cod_CuentaContable,
			 @Cod_CuentaAnalitica,
			 @Doc_CuentaAnalitica,
			 @Debe_MN,
			 @Haber_MN,
			 @Debe_ME,
			 @Haber_ME,
			 @Cod_TipoOperacionAsiento,
			 @Obs_AsientoD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Asiento,'|' ,
			 @Nro_Detalle,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_CuentaAnalitica,'|' ,
			 @Doc_CuentaAnalitica,'|' ,
			 @Debe_MN,'|' ,
			 @Haber_MN,'|' ,
			 @Debe_ME,'|' ,
			 @Haber_ME,'|' ,
			 @Cod_TipoOperacionAsiento,'|' ,
			 @Obs_AsientoD,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Sucursal,'|',@Cod_Libro,'|',@Nro_Asiento,'|',@Nro_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Sucursal,
			 @Cod_Libro,
			 @Nro_Asiento,
			 @Nro_Detalle,
			 @Cod_CuentaContable,
			 @Cod_CuentaAnalitica,
			 @Doc_CuentaAnalitica,
			 @Debe_MN,
			 @Haber_MN,
			 @Debe_ME,
			 @Haber_ME,
			 @Cod_TipoOperacionAsiento,
			 @Obs_AsientoD,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CON_PLANTILLA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CON_PLANTILLA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CON_PLANTILLA_IUD
GO

CREATE TRIGGER UTR_CON_PLANTILLA_IUD
ON dbo.CON_PLANTILLA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CON_PLANTILLA'
	--Variables de tabla secundarias
	DECLARE @Des_Plantilla varchar(512)
	DECLARE @Cod_Modulo varchar(8)
	DECLARE @Cod_TipoDoc varchar(5)
	DECLARE @SerieDoc varchar(4)
	DECLARE @Cod_TipoFormaPago varchar(5)
	DECLARE @Cod_Moneda varchar(5)
	DECLARE @Flag_EsModelo bit
	DECLARE @Flag_Exonerada bit
	DECLARE @Flag_Activa bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Plantilla,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Plantilla), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Plantilla,
			 i.Des_Plantilla,
			 i.Cod_Modulo,
			 i.Cod_TipoDoc,
			 i.SerieDoc,
			 i.Cod_TipoFormaPago,
			 i.Cod_Moneda,
			 i.Flag_EsModelo,
			 i.Flag_Exonerada,
			 i.Flag_Activa,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Des_Plantilla,
			 @Cod_Modulo,
			 @Cod_TipoDoc,
			 @SerieDoc,
			 @Cod_TipoFormaPago,
			 @Cod_Moneda,
			 @Flag_EsModelo,
			 @Flag_Exonerada,
			 @Flag_Activa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Des_Plantilla,'|' ,
			 @Cod_Modulo,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @SerieDoc,'|' ,
			 @Cod_TipoFormaPago,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_EsModelo,'|' ,
			 @Flag_Exonerada,'|' ,
			 @Flag_Activa,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Plantilla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Des_Plantilla,
			 @Cod_Modulo,
			 @Cod_TipoDoc,
			 @SerieDoc,
			 @Cod_TipoFormaPago,
			 @Cod_Moneda,
			 @Flag_EsModelo,
			 @Flag_Exonerada,
			 @Flag_Activa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Plantilla,
			 d.Des_Plantilla,
			 d.Cod_Modulo,
			 d.Cod_TipoDoc,
			 d.SerieDoc,
			 d.Cod_TipoFormaPago,
			 d.Cod_Moneda,
			 d.Flag_EsModelo,
			 d.Flag_Exonerada,
			 d.Flag_Activa,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Des_Plantilla,
			 @Cod_Modulo,
			 @Cod_TipoDoc,
			 @SerieDoc,
			 @Cod_TipoFormaPago,
			 @Cod_Moneda,
			 @Flag_EsModelo,
			 @Flag_Exonerada,
			 @Flag_Activa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Des_Plantilla,'|' ,
			 @Cod_Modulo,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @SerieDoc,'|' ,
			 @Cod_TipoFormaPago,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_EsModelo,'|' ,
			 @Flag_Exonerada,'|' ,
			 @Flag_Activa,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Plantilla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Des_Plantilla,
			 @Cod_Modulo,
			 @Cod_TipoDoc,
			 @SerieDoc,
			 @Cod_TipoFormaPago,
			 @Cod_Moneda,
			 @Flag_EsModelo,
			 @Flag_Exonerada,
			 @Flag_Activa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--CON_PLANTILLA_ASIENTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CON_PLANTILLA_ASIENTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_IUD
GO

CREATE TRIGGER UTR_CON_PLANTILLA_ASIENTO_IUD
ON dbo.CON_PLANTILLA_ASIENTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CON_PLANTILLA_ASIENTO'
	--Variables de tabla secundarias
	DECLARE @TipoCambio varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Plantilla,
	--	    i.Cod_Libro,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Cod_Libro,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Plantilla,'|',@Cod_Libro,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Cod_Libro,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Plantilla,
			 i.Cod_Libro,
			 i.TipoCambio,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @TipoCambio,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Cod_Libro,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Plantilla,'|',@Cod_Libro), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @TipoCambio,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Plantilla,
			 d.Cod_Libro,
			 d.TipoCambio,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @TipoCambio,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Cod_Libro,'|' ,
			 @TipoCambio,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Plantilla,'|',@Cod_Libro), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @TipoCambio,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CON_PLANTILLA_ASIENTO_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CON_PLANTILLA_ASIENTO_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_D_IUD
GO

CREATE TRIGGER UTR_CON_PLANTILLA_ASIENTO_D_IUD
ON dbo.CON_PLANTILLA_ASIENTO_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Nro_Linea int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CON_PLANTILLA_ASIENTO_D'
	--Variables de tabla secundarias
	DECLARE @Formula_CuentaContable varchar(1024)
	DECLARE @Formula_Debe varchar(1024)
	DECLARE @Formula_Haber varchar(1024)
	DECLARE @Formula_CodCuentaAnalitica varchar(1024)
	DECLARE @Formula_DocCuentaAnalitica varchar(1024)
	DECLARE @Cod_TipoOperacionAsiento varchar(5)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Plantilla,
	--	    i.Cod_Libro,
	--	    i.Nro_Linea,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Cod_Libro,
	--	    @Nro_Linea,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Plantilla,'|',@Cod_Libro,'|',@Nro_Linea,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Plantilla,
	--	    @Cod_Libro,
	--	    @Nro_Linea,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Plantilla,
			 i.Cod_Libro,
			 i.Nro_Linea,
			 i.Formula_CuentaContable,
			 i.Formula_Debe,
			 i.Formula_Haber,
			 i.Formula_CodCuentaAnalitica,
			 i.Formula_DocCuentaAnalitica,
			 i.Cod_TipoOperacionAsiento,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @Nro_Linea,
			 @Formula_CuentaContable,
			 @Formula_Debe,
			 @Formula_Haber,
			 @Formula_CodCuentaAnalitica,
			 @Formula_DocCuentaAnalitica,
			 @Cod_TipoOperacionAsiento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Linea,'|' ,
			 @Formula_CuentaContable,'|' ,
			 @Formula_Debe,'|' ,
			 @Formula_Haber,'|' ,
			 @Formula_CodCuentaAnalitica,'|' ,
			 @Formula_DocCuentaAnalitica,'|' ,
			 @Cod_TipoOperacionAsiento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Plantilla,'|',@Cod_Libro,'|',@Nro_Linea), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @Nro_Linea,
			 @Formula_CuentaContable,
			 @Formula_Debe,
			 @Formula_Haber,
			 @Formula_CodCuentaAnalitica,
			 @Formula_DocCuentaAnalitica,
			 @Cod_TipoOperacionAsiento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Plantilla,
			 d.Cod_Libro,
			 d.Nro_Linea,
			 d.Formula_CuentaContable,
			 d.Formula_Debe,
			 d.Formula_Haber,
			 d.Formula_CodCuentaAnalitica,
			 d.Formula_DocCuentaAnalitica,
			 d.Cod_TipoOperacionAsiento,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @Nro_Linea,
			 @Formula_CuentaContable,
			 @Formula_Debe,
			 @Formula_Haber,
			 @Formula_CodCuentaAnalitica,
			 @Formula_DocCuentaAnalitica,
			 @Cod_TipoOperacionAsiento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Plantilla,'|' ,
			 @Cod_Libro,'|' ,
			 @Nro_Linea,'|' ,
			 @Formula_CuentaContable,'|' ,
			 @Formula_Debe,'|' ,
			 @Formula_Haber,'|' ,
			 @Formula_CodCuentaAnalitica,'|' ,
			 @Formula_DocCuentaAnalitica,'|' ,
			 @Cod_TipoOperacionAsiento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Plantilla,'|',@Cod_Libro,'|',@Nro_Linea), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Plantilla,
			 @Cod_Libro,
			 @Nro_Linea,
			 @Formula_CuentaContable,
			 @Formula_Debe,
			 @Formula_Haber,
			 @Formula_CodCuentaAnalitica,
			 @Formula_DocCuentaAnalitica,
			 @Cod_TipoOperacionAsiento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--CUE_CLIENTE_CUENTA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CUE_CLIENTE_CUENTA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_IUD
GO

CREATE TRIGGER UTR_CUE_CLIENTE_CUENTA_IUD
ON dbo.CUE_CLIENTE_CUENTA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Cuenta varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CUE_CLIENTE_CUENTA'
	--Variables de tabla secundarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Des_Cuenta varchar(512)
	DECLARE @Cod_TipoCuenta varchar(3)
	DECLARE @Monto_Deposito numeric(38,2)
	DECLARE @Interes numeric(38,4)
	DECLARE @MesesMax int
	DECLARE @Limite_Max numeric(38,2)
	DECLARE @Flag_ITF bit
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Cod_EstadoCuenta varchar(3)
	DECLARE @Saldo_Contable numeric(38,2)
	DECLARE @Saldo_Disponible numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Cuenta,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Cuenta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Cuenta), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Cuenta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Cuenta,
			 i.Id_ClienteProveedor,
			 i.Des_Cuenta,
			 i.Cod_TipoCuenta,
			 i.Monto_Deposito,
			 i.Interes,
			 i.MesesMax,
			 i.Limite_Max,
			 i.Flag_ITF,
			 i.Cod_Moneda,
			 i.Cod_EstadoCuenta,
			 i.Saldo_Contable,
			 i.Saldo_Disponible,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Cuenta,
			 @Id_ClienteProveedor,
			 @Des_Cuenta,
			 @Cod_TipoCuenta,
			 @Monto_Deposito,
			 @Interes,
			 @MesesMax,
			 @Limite_Max,
			 @Flag_ITF,
			 @Cod_Moneda,
			 @Cod_EstadoCuenta,
			 @Saldo_Contable,
			 @Saldo_Disponible,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Cuenta,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Des_Cuenta,'|' ,
			 @Cod_TipoCuenta,'|' ,
			 @Monto_Deposito,'|' ,
			 @Interes,'|' ,
			 @MesesMax,'|' ,
			 @Limite_Max,'|' ,
			 @Flag_ITF,'|' ,
			 @Cod_Moneda,'|' ,
			 @Cod_EstadoCuenta,'|' ,
			 @Saldo_Contable,'|' ,
			 @Saldo_Disponible,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Cuenta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Cuenta,
			 @Id_ClienteProveedor,
			 @Des_Cuenta,
			 @Cod_TipoCuenta,
			 @Monto_Deposito,
			 @Interes,
			 @MesesMax,
			 @Limite_Max,
			 @Flag_ITF,
			 @Cod_Moneda,
			 @Cod_EstadoCuenta,
			 @Saldo_Contable,
			 @Saldo_Disponible,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Cuenta,
			 d.Id_ClienteProveedor,
			 d.Des_Cuenta,
			 d.Cod_TipoCuenta,
			 d.Monto_Deposito,
			 d.Interes,
			 d.MesesMax,
			 d.Limite_Max,
			 d.Flag_ITF,
			 d.Cod_Moneda,
			 d.Cod_EstadoCuenta,
			 d.Saldo_Contable,
			 d.Saldo_Disponible,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Cuenta,
			 @Id_ClienteProveedor,
			 @Des_Cuenta,
			 @Cod_TipoCuenta,
			 @Monto_Deposito,
			 @Interes,
			 @MesesMax,
			 @Limite_Max,
			 @Flag_ITF,
			 @Cod_Moneda,
			 @Cod_EstadoCuenta,
			 @Saldo_Contable,
			 @Saldo_Disponible,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Cuenta,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Des_Cuenta,'|' ,
			 @Cod_TipoCuenta,'|' ,
			 @Monto_Deposito,'|' ,
			 @Interes,'|' ,
			 @MesesMax,'|' ,
			 @Limite_Max,'|' ,
			 @Flag_ITF,'|' ,
			 @Cod_Moneda,'|' ,
			 @Cod_EstadoCuenta,'|' ,
			 @Saldo_Contable,'|' ,
			 @Saldo_Disponible,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Cuenta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Cuenta,
			 @Id_ClienteProveedor,
			 @Des_Cuenta,
			 @Cod_TipoCuenta,
			 @Monto_Deposito,
			 @Interes,
			 @MesesMax,
			 @Limite_Max,
			 @Flag_ITF,
			 @Cod_Moneda,
			 @Cod_EstadoCuenta,
			 @Saldo_Contable,
			 @Saldo_Disponible,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CUE_CLIENTE_CUENTA_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CUE_CLIENTE_CUENTA_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_D_IUD
GO

CREATE TRIGGER UTR_CUE_CLIENTE_CUENTA_D_IUD
ON dbo.CUE_CLIENTE_CUENTA_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Cuenta varchar(32)
	DECLARE @item int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CUE_CLIENTE_CUENTA_D'
	--Variables de tabla secundarias
	DECLARE @Des_CuentaD varchar(512)
	DECLARE @Monto numeric(38,2)
	DECLARE @Fecha_Emision datetime
	DECLARE @Fecha_Vencimiento datetime
	DECLARE @Cod_EstadoDCuenta varchar(3)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Cuenta,
	--	    i.item,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Cuenta,
	--	    @item,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Cuenta,'|',@item,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Cuenta,
	--	    @item,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Cuenta,
			 i.item,
			 i.Des_CuentaD,
			 i.Monto,
			 i.Fecha_Emision,
			 i.Fecha_Vencimiento,
			 i.Cod_EstadoDCuenta,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Cuenta,
			 @item,
			 @Des_CuentaD,
			 @Monto,
			 @Fecha_Emision,
			 @Fecha_Vencimiento,
			 @Cod_EstadoDCuenta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Cuenta,'|' ,
			 @item,'|' ,
			 @Des_CuentaD,'|' ,
			 @Monto,'|' ,
			 CONVERT(varchar,@Fecha_Emision,121), '|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Cod_EstadoDCuenta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Cuenta,'|',@item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Cuenta,
			 @item,
			 @Des_CuentaD,
			 @Monto,
			 @Fecha_Emision,
			 @Fecha_Vencimiento,
			 @Cod_EstadoDCuenta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Cuenta,
			 d.item,
			 d.Des_CuentaD,
			 d.Monto,
			 d.Fecha_Emision,
			 d.Fecha_Vencimiento,
			 d.Cod_EstadoDCuenta,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Cuenta,
			 @item,
			 @Des_CuentaD,
			 @Monto,
			 @Fecha_Emision,
			 @Fecha_Vencimiento,
			 @Cod_EstadoDCuenta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Cuenta,'|' ,
			 @item,'|' ,
			 @Des_CuentaD,'|' ,
			 @Monto,'|' ,
			 CONVERT(varchar,@Fecha_Emision,121), '|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Cod_EstadoDCuenta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Cuenta,'|',@item), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Cuenta,
			 @item,
			 @Des_CuentaD,
			 @Monto,
			 @Fecha_Emision,
			 @Fecha_Vencimiento,
			 @Cod_EstadoDCuenta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CUE_CLIENTE_CUENTA_M
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CUE_CLIENTE_CUENTA_M_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_M_IUD
GO

CREATE TRIGGER UTR_CUE_CLIENTE_CUENTA_M_IUD
ON dbo.CUE_CLIENTE_CUENTA_M
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteCuentaMov int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CUE_CLIENTE_CUENTA_M'
	--Variables de tabla secundarias
	DECLARE @Cod_Cuenta varchar(32)
	DECLARE @Cod_TipoMovimiento varchar(16)
	DECLARE @Id_Movimiento int
	DECLARE @Des_Movimiento varchar(512)
	DECLARE @Cod_MonedaIng varchar(5)
	DECLARE @Ingreso numeric(38,2)
	DECLARE @Cod_MonedaEgr varchar(5)
	DECLARE @Egreso numeric(38,2)
	DECLARE @Tipo_Cambio numeric(10,4)
	DECLARE @Fecha datetime
	DECLARE @Flag_Extorno bit
	DECLARE @id_MovimientoCaja int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_ClienteCuentaMov,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_ClienteCuentaMov,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_ClienteCuentaMov), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_ClienteCuentaMov,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteCuentaMov,
			 i.Cod_Cuenta,
			 i.Cod_TipoMovimiento,
			 i.Id_Movimiento,
			 i.Des_Movimiento,
			 i.Cod_MonedaIng,
			 i.Ingreso,
			 i.Cod_MonedaEgr,
			 i.Egreso,
			 i.Tipo_Cambio,
			 i.Fecha,
			 i.Flag_Extorno,
			 i.id_MovimientoCaja,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteCuentaMov,
			 @Cod_Cuenta,
			 @Cod_TipoMovimiento,
			 @Id_Movimiento,
			 @Des_Movimiento,
			 @Cod_MonedaIng,
			 @Ingreso,
			 @Cod_MonedaEgr,
			 @Egreso,
			 @Tipo_Cambio,
			 @Fecha,
			 @Flag_Extorno,
			 @id_MovimientoCaja,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteCuentaMov,'|' ,
			 @Cod_Cuenta,'|' ,
			 @Cod_TipoMovimiento,'|' ,
			 @Id_Movimiento,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_MonedaIng,'|' ,
			 @Ingreso,'|' ,
			 @Cod_MonedaEgr,'|' ,
			 @Egreso,'|' ,
			 @Tipo_Cambio,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Flag_Extorno,'|' ,
			 @id_MovimientoCaja,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_ClienteCuentaMov), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteCuentaMov,
			 @Cod_Cuenta,
			 @Cod_TipoMovimiento,
			 @Id_Movimiento,
			 @Des_Movimiento,
			 @Cod_MonedaIng,
			 @Ingreso,
			 @Cod_MonedaEgr,
			 @Egreso,
			 @Tipo_Cambio,
			 @Fecha,
			 @Flag_Extorno,
			 @id_MovimientoCaja,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteCuentaMov,
			 d.Cod_Cuenta,
			 d.Cod_TipoMovimiento,
			 d.Id_Movimiento,
			 d.Des_Movimiento,
			 d.Cod_MonedaIng,
			 d.Ingreso,
			 d.Cod_MonedaEgr,
			 d.Egreso,
			 d.Tipo_Cambio,
			 d.Fecha,
			 d.Flag_Extorno,
			 d.id_MovimientoCaja,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteCuentaMov,
			 @Cod_Cuenta,
			 @Cod_TipoMovimiento,
			 @Id_Movimiento,
			 @Des_Movimiento,
			 @Cod_MonedaIng,
			 @Ingreso,
			 @Cod_MonedaEgr,
			 @Egreso,
			 @Tipo_Cambio,
			 @Fecha,
			 @Flag_Extorno,
			 @id_MovimientoCaja,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteCuentaMov,'|' ,
			 @Cod_Cuenta,'|' ,
			 @Cod_TipoMovimiento,'|' ,
			 @Id_Movimiento,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_MonedaIng,'|' ,
			 @Ingreso,'|' ,
			 @Cod_MonedaEgr,'|' ,
			 @Egreso,'|' ,
			 @Tipo_Cambio,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 @Flag_Extorno,'|' ,
			 @id_MovimientoCaja,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_ClienteCuentaMov), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteCuentaMov,
			 @Cod_Cuenta,
			 @Cod_TipoMovimiento,
			 @Id_Movimiento,
			 @Des_Movimiento,
			 @Cod_MonedaIng,
			 @Ingreso,
			 @Cod_MonedaEgr,
			 @Egreso,
			 @Tipo_Cambio,
			 @Fecha,
			 @Flag_Extorno,
			 @id_MovimientoCaja,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--CUE_TARJETAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CUE_TARJETAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CUE_TARJETAS_IUD
GO

CREATE TRIGGER UTR_CUE_TARJETAS_IUD
ON dbo.CUE_TARJETAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tarjeta varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CUE_TARJETAS'
	--Variables de tabla secundarias
	DECLARE @Nombre_Cliente varchar(64)
	DECLARE @CCV varchar(5)
	DECLARE @Fecha_Vencimiento datetime
	DECLARE @Contraseña varchar(512)
	DECLARE @Flag_Entregado bit
	DECLARE @Flag_Activo bit
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Tarjeta,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tarjeta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Tarjeta), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tarjeta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tarjeta,
			 i.Nombre_Cliente,
			 i.CCV,
			 i.Fecha_Vencimiento,
			 i.Contraseña,
			 i.Flag_Entregado,
			 i.Flag_Activo,
			 i.Id_ClienteProveedor,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tarjeta,
			 @Nombre_Cliente,
			 @CCV,
			 @Fecha_Vencimiento,
			 @Contraseña,
			 @Flag_Entregado,
			 @Flag_Activo,
			 @Id_ClienteProveedor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tarjeta,'|' ,
			 @Nombre_Cliente,'|' ,
			 @CCV,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Contraseña,'|' ,
			 @Flag_Entregado,'|' ,
			 @Flag_Activo,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Tarjeta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tarjeta,
			 @Nombre_Cliente,
			 @CCV,
			 @Fecha_Vencimiento,
			 @Contraseña,
			 @Flag_Entregado,
			 @Flag_Activo,
			 @Id_ClienteProveedor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tarjeta,
			 d.Nombre_Cliente,
			 d.CCV,
			 d.Fecha_Vencimiento,
			 d.Contraseña,
			 d.Flag_Entregado,
			 d.Flag_Activo,
			 d.Id_ClienteProveedor,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tarjeta,
			 @Nombre_Cliente,
			 @CCV,
			 @Fecha_Vencimiento,
			 @Contraseña,
			 @Flag_Entregado,
			 @Flag_Activo,
			 @Id_ClienteProveedor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tarjeta,'|' ,
			 @Nombre_Cliente,'|' ,
			 @CCV,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Contraseña,'|' ,
			 @Flag_Entregado,'|' ,
			 @Flag_Activo,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Tarjeta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tarjeta,
			 @Nombre_Cliente,
			 @CCV,
			 @Fecha_Vencimiento,
			 @Contraseña,
			 @Flag_Entregado,
			 @Flag_Activo,
			 @Id_ClienteProveedor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PAR_COLUMNA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAR_COLUMNA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAR_COLUMNA_IUD
GO

CREATE TRIGGER UTR_PAR_COLUMNA_IUD
ON dbo.PAR_COLUMNA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tabla varchar(3)
	DECLARE @Cod_Columna varchar(3)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAR_COLUMNA'
	--Variables de tabla secundarias
	DECLARE @Columna varchar(512)
	DECLARE @Des_Columna varchar(1024)
	DECLARE @Tipo varchar(64)
	DECLARE @Flag_NULL bit
	DECLARE @Tamano int
	DECLARE @Predeterminado varchar(max)
	DECLARE @Flag_PK bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
     --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Tabla,
		    i.Cod_Columna,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PAR_COLUMNA_I ' +
			  CASE WHEN  Cod_Tabla IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Cod_Tabla,'''','')+''','END+
			  CASE WHEN  Cod_Columna IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Cod_Columna,'''','')+''','END+
			  CASE WHEN  Columna IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Columna,'''','')+''','END+
			  CASE WHEN  Des_Columna IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Des_Columna,'''','')+''','END+
			  CASE WHEN  Tipo IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Tipo,'''','')+''','END+
			  CONVERT(varchar(max),Flag_NULL)+','+
			  CASE WHEN  Tamano IS NULL  THEN 'NULL,'    ELSE  CONVERT(varchar(max),Tamano)+','END+
			  CASE WHEN  Predeterminado IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Predeterminado,'''','')+''','END+
			  CONVERT(varchar(max),Flag_PK)+','+
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED 
			  WHERE Cod_Tabla=@Cod_Tabla AND Cod_Columna=@Cod_Columna

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Tabla,
		    d.Cod_Columna,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
		OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PAR_COLUMNA_D ' +
			  CASE WHEN  Cod_Tabla IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Cod_Tabla,'''','')+''','END+
			  CASE WHEN  Cod_Columna IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(Cod_Columna,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  
			  WHERE Cod_Tabla=@Cod_Tabla AND Cod_Columna=@Cod_Columna

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tabla,
			 i.Cod_Columna,
			 i.Columna,
			 i.Des_Columna,
			 i.Tipo,
			 i.Flag_NULL,
			 i.Tamano,
			 i.Predeterminado,
			 i.Flag_PK,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Columna,
			 @Des_Columna,
			 @Tipo,
			 @Flag_NULL,
			 @Tamano,
			 @Predeterminado,
			 @Flag_PK,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Cod_Columna,'|' ,
			 @Columna,'|' ,
			 @Des_Columna,'|' ,
			 @Tipo,'|' ,
			 @Flag_NULL,'|' ,
			 @Tamano,'|' ,
			 @Predeterminado,'|' ,
			 @Flag_PK,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Tabla,'|',@Cod_Columna), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Columna,
			 @Des_Columna,
			 @Tipo,
			 @Flag_NULL,
			 @Tamano,
			 @Predeterminado,
			 @Flag_PK,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tabla,
			 d.Cod_Columna,
			 d.Columna,
			 d.Des_Columna,
			 d.Tipo,
			 d.Flag_NULL,
			 d.Tamano,
			 d.Predeterminado,
			 d.Flag_PK,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Columna,
			 @Des_Columna,
			 @Tipo,
			 @Flag_NULL,
			 @Tamano,
			 @Predeterminado,
			 @Flag_PK,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Cod_Columna,'|' ,
			 @Columna,'|' ,
			 @Des_Columna,'|' ,
			 @Tipo,'|' ,
			 @Flag_NULL,'|' ,
			 @Tamano,'|' ,
			 @Predeterminado,'|' ,
			 @Flag_PK,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Columna,
			 @Des_Columna,
			 @Tipo,
			 @Flag_NULL,
			 @Tamano,
			 @Predeterminado,
			 @Flag_PK,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PAR_FILA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAR_FILA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAR_FILA_IUD
GO

CREATE TRIGGER UTR_PAR_FILA_IUD
ON dbo.PAR_FILA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tabla varchar(3)
	DECLARE @Cod_Columna varchar(3)
	DECLARE @Cod_Fila int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAR_FILA'
	--Variables de tabla secundarias
	DECLARE @Cadena nvarchar(max)
	DECLARE @Numero numeric(38,8)
	DECLARE @Entero float 
	DECLARE @FechaHora datetime
	DECLARE @Boleano bit
	DECLARE @Flag_Creacion bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Tabla,
		    i.Cod_Columna,
		    i.Cod_Fila,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Cod_Fila,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script='USP_PAR_FILA_I ' +
				CASE WHEN i.Cod_Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_Tabla,'''','')+''',' END +
			     CASE WHEN i.Cod_Columna IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(i.Cod_Columna,'''','')+''',' END +
			     CASE WHEN i.Cod_Columna IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Cod_Fila) +',' END +
				CASE WHEN i.Cadena IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cadena,'''','')+''','END +
				CASE WHEN i.Numero IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max),i.Numero) +',' END +
				CASE WHEN i.Entero IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max),i.Entero) +',' END +
				CASE WHEN i.FechaHora IS NULL THEN 'NULL,' ELSE  ''''+CONVERT(varchar(max),i.FechaHora,121) +''',' END +
				CASE WHEN i.Boleano IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Boleano) +',' END +
				CASE WHEN i.Flag_Creacion IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Flag_Creacion) +',' END +
				''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')   +''';'  
			FROM INSERTED i 
			WHERE i.Cod_Tabla=@Cod_Tabla AND i.Cod_Columna=@Cod_Columna AND i.Cod_Fila=@Cod_Fila

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna,'|',@Cod_Fila), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Cod_Fila,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Tabla,
		    d.Cod_Columna,
		    d.Cod_Fila,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Cod_Fila,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script='USP_PAR_FILA_D ' +
				CASE WHEN i.Cod_Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_Tabla,'''','')+''',' END +
			    CASE WHEN i.Cod_Columna IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(i.Cod_Columna,'''','')+''',' END +
			    CASE WHEN i.Cod_Fila IS NULL THEN 'NULL,' ELSE CONVERT(varchar(max), i.Cod_Fila) +',' END +
				''''+'TRIGGER'+''',' +
				''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM DELETED i 
			WHERE i.Cod_Tabla=@Cod_Tabla AND i.Cod_Columna=@Cod_Columna AND i.Cod_Fila=@Cod_Fila

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna,'|',@Cod_Fila), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Cod_Columna,
		    @Cod_Fila,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tabla,
			 i.Cod_Columna,
			 i.Cod_Fila,
			 i.Cadena,
			 i.Numero,
			 i.Entero,
			 i.FechaHora,
			 i.Boleano,
			 i.Flag_Creacion,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Cod_Fila,
			 @Cadena,
			 @Numero,
			 @Entero,
			 @FechaHora,
			 @Boleano,
			 @Flag_Creacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Cod_Columna,'|' ,
			 @Cod_Fila,'|' ,
			 @Cadena,'|',
			 @Numero,'|' ,
			 @Entero,'|',
			 CONVERT(varchar,@FechaHora,121), '|' ,
			 @Boleano,'|' ,
			 @Flag_Creacion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Tabla,'|',@Cod_Columna,'|',@Cod_Fila), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Cod_Fila,
			 @Cadena,
			 @Numero,
			 @Entero,
			 @FechaHora,
			 @Boleano,
			 @Flag_Creacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tabla,
			 d.Cod_Columna,
			 d.Cod_Fila,
			 d.Cadena,
			 d.Numero,
			 d.Entero,
			 d.FechaHora,
			 d.Boleano,
			 d.Flag_Creacion,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Cod_Fila,
			 @Cadena,
			 @Numero,
			 @Entero,
			 @FechaHora,
			 @Boleano,
			 @Flag_Creacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Cod_Columna,'|' ,
			 @Cod_Fila,'|' ,
			 @Cadena,'|',
			 @Numero,'|' ,
			 @Entero,'|',
			 CONVERT(varchar,@FechaHora,121), '|' ,
			 @Boleano,'|' ,
			 @Flag_Creacion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Tabla,'|',@Cod_Columna,'|',@Cod_Fila), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Cod_Columna,
			 @Cod_Fila,
			 @Cadena,
			 @Numero,
			 @Entero,
			 @FechaHora,
			 @Boleano,
			 @Flag_Creacion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PAR_TABLA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAR_TABLA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAR_TABLA_IUD
GO

CREATE TRIGGER UTR_PAR_TABLA_IUD
ON dbo.PAR_TABLA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tabla varchar(3)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAR_TABLA'
	--Variables de tabla secundarias
	DECLARE @Tabla varchar(512)
	DECLARE @Des_Tabla varchar(1024)
	DECLARE @Cod_Sistema varchar(3)
	DECLARE @Flag_Acceso bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Tabla,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT  @Script='USP_PAR_TABLA_I ' +
			    CASE WHEN  i.Cod_Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_tabla,'''','')+''',' END +
			    CASE WHEN  i.Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Tabla,'''','')+''',' END +
			    CASE WHEN  i.Des_Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Des_Tabla,'''','')+''',' END +
			    CASE WHEN  i.Cod_Sistema IS NULL THEN 'NULL,' ELSE ''''+REPLACE(i.Cod_Sistema,'''','')+''',' END +
			    CASE WHEN  i.Flag_Acceso IS NULL THEN 'NULL,' ELSE CONVERT(varchar,i.Flag_Acceso)+','END+
			    ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')  +''';'  
			FROM INSERTED i

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Tabla), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Tabla,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
		OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT  @Script='USP_PAR_TABLA_D ' +
			    CASE WHEN  d.Cod_Tabla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(d.Cod_tabla,'''','')+''',' END +
			    ''''+'TRIGGER'+''',' +
				''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';'
			FROM DELETED d
		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Tabla), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Tabla,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tabla,
			 i.Tabla,
			 i.Des_Tabla,
			 i.Cod_Sistema,
			 i.Flag_Acceso,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Tabla,
			 @Des_Tabla,
			 @Cod_Sistema,
			 @Flag_Acceso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Tabla,'|' ,
			 @Des_Tabla,'|' ,
			 @Cod_Sistema,'|' ,
			 @Flag_Acceso,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Cod_Tabla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Tabla,
			 @Des_Tabla,
			 @Cod_Sistema,
			 @Flag_Acceso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tabla,
			 d.Tabla,
			 d.Des_Tabla,
			 d.Cod_Sistema,
			 d.Flag_Acceso,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Tabla,
			 @Des_Tabla,
			 @Cod_Sistema,
			 @Flag_Acceso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Tabla,'|' ,
			 @Des_Tabla,'|' ,
			 @Cod_Sistema,'|' ,
			 @Flag_Acceso,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Cod_Tabla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Tabla,
			 @Des_Tabla,
			 @Cod_Sistema,
			 @Flag_Acceso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PAT_BIENES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAT_BIENES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAT_BIENES_IUD
GO

CREATE TRIGGER UTR_PAT_BIENES_IUD
ON dbo.PAT_BIENES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Bien varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAT_BIENES'
	--Variables de tabla secundarias
	DECLARE @Cod_Grupo varchar(32)
	DECLARE @Des_Bien varchar(1024)
	DECLARE @Valor_Historico numeric(38,2)
	DECLARE @Fecha_Ingreso datetime
	DECLARE @Valor_Libros numeric(38,2)
	DECLARE @Fecha_Deprecesacion datetime
	DECLARE @Valor_Tasacion numeric(38,2)
	DECLARE @Valor_Residual numeric(38,2)
	DECLARE @Valor_Reposicion numeric(38,2)
	DECLARE @Factor_Depreciacion int
	DECLARE @Vida_Util int
	DECLARE @Cod_EstadoBien varchar(5)
	DECLARE @Cod_PersonalResponsable varchar(8)
	DECLARE @Cod_BienPadre varchar(32)
	DECLARE @Cod_Condicion varchar(5)
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Flag_Asegurado bit
	DECLARE @Obs_Bien varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Bien,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Bien), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Bien,
			 i.Cod_Grupo,
			 i.Des_Bien,
			 i.Valor_Historico,
			 i.Fecha_Ingreso,
			 i.Valor_Libros,
			 i.Fecha_Deprecesacion,
			 i.Valor_Tasacion,
			 i.Valor_Residual,
			 i.Valor_Reposicion,
			 i.Factor_Depreciacion,
			 i.Vida_Util,
			 i.Cod_EstadoBien,
			 i.Cod_PersonalResponsable,
			 i.Cod_BienPadre,
			 i.Cod_Condicion,
			 i.Cod_CuentaContable,
			 i.Flag_Asegurado,
			 i.Obs_Bien,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Cod_Grupo,
			 @Des_Bien,
			 @Valor_Historico,
			 @Fecha_Ingreso,
			 @Valor_Libros,
			 @Fecha_Deprecesacion,
			 @Valor_Tasacion,
			 @Valor_Residual,
			 @Valor_Reposicion,
			 @Factor_Depreciacion,
			 @Vida_Util,
			 @Cod_EstadoBien,
			 @Cod_PersonalResponsable,
			 @Cod_BienPadre,
			 @Cod_Condicion,
			 @Cod_CuentaContable,
			 @Flag_Asegurado,
			 @Obs_Bien,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Cod_Grupo,'|' ,
			 @Des_Bien,'|' ,
			 @Valor_Historico,'|' ,
			 CONVERT(varchar,@Fecha_Ingreso,121), '|' ,
			 @Valor_Libros,'|' ,
			 CONVERT(varchar,@Fecha_Deprecesacion,121), '|' ,
			 @Valor_Tasacion,'|' ,
			 @Valor_Residual,'|' ,
			 @Valor_Reposicion,'|' ,
			 @Factor_Depreciacion,'|' ,
			 @Vida_Util,'|' ,
			 @Cod_EstadoBien,'|' ,
			 @Cod_PersonalResponsable,'|' ,
			 @Cod_BienPadre,'|' ,
			 @Cod_Condicion,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Flag_Asegurado,'|' ,
			 @Obs_Bien,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Bien), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Cod_Grupo,
			 @Des_Bien,
			 @Valor_Historico,
			 @Fecha_Ingreso,
			 @Valor_Libros,
			 @Fecha_Deprecesacion,
			 @Valor_Tasacion,
			 @Valor_Residual,
			 @Valor_Reposicion,
			 @Factor_Depreciacion,
			 @Vida_Util,
			 @Cod_EstadoBien,
			 @Cod_PersonalResponsable,
			 @Cod_BienPadre,
			 @Cod_Condicion,
			 @Cod_CuentaContable,
			 @Flag_Asegurado,
			 @Obs_Bien,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Bien,
			 d.Cod_Grupo,
			 d.Des_Bien,
			 d.Valor_Historico,
			 d.Fecha_Ingreso,
			 d.Valor_Libros,
			 d.Fecha_Deprecesacion,
			 d.Valor_Tasacion,
			 d.Valor_Residual,
			 d.Valor_Reposicion,
			 d.Factor_Depreciacion,
			 d.Vida_Util,
			 d.Cod_EstadoBien,
			 d.Cod_PersonalResponsable,
			 d.Cod_BienPadre,
			 d.Cod_Condicion,
			 d.Cod_CuentaContable,
			 d.Flag_Asegurado,
			 d.Obs_Bien,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Cod_Grupo,
			 @Des_Bien,
			 @Valor_Historico,
			 @Fecha_Ingreso,
			 @Valor_Libros,
			 @Fecha_Deprecesacion,
			 @Valor_Tasacion,
			 @Valor_Residual,
			 @Valor_Reposicion,
			 @Factor_Depreciacion,
			 @Vida_Util,
			 @Cod_EstadoBien,
			 @Cod_PersonalResponsable,
			 @Cod_BienPadre,
			 @Cod_Condicion,
			 @Cod_CuentaContable,
			 @Flag_Asegurado,
			 @Obs_Bien,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Cod_Grupo,'|' ,
			 @Des_Bien,'|' ,
			 @Valor_Historico,'|' ,
			 CONVERT(varchar,@Fecha_Ingreso,121), '|' ,
			 @Valor_Libros,'|' ,
			 CONVERT(varchar,@Fecha_Deprecesacion,121), '|' ,
			 @Valor_Tasacion,'|' ,
			 @Valor_Residual,'|' ,
			 @Valor_Reposicion,'|' ,
			 @Factor_Depreciacion,'|' ,
			 @Vida_Util,'|' ,
			 @Cod_EstadoBien,'|' ,
			 @Cod_PersonalResponsable,'|' ,
			 @Cod_BienPadre,'|' ,
			 @Cod_Condicion,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Flag_Asegurado,'|' ,
			 @Obs_Bien,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Bien), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Cod_Grupo,
			 @Des_Bien,
			 @Valor_Historico,
			 @Fecha_Ingreso,
			 @Valor_Libros,
			 @Fecha_Deprecesacion,
			 @Valor_Tasacion,
			 @Valor_Residual,
			 @Valor_Reposicion,
			 @Factor_Depreciacion,
			 @Vida_Util,
			 @Cod_EstadoBien,
			 @Cod_PersonalResponsable,
			 @Cod_BienPadre,
			 @Cod_Condicion,
			 @Cod_CuentaContable,
			 @Flag_Asegurado,
			 @Obs_Bien,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PAT_BIENES_CARACTERISTICAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAT_BIENES_CARACTERISTICAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAT_BIENES_CARACTERISTICAS_IUD
GO

CREATE TRIGGER UTR_PAT_BIENES_CARACTERISTICAS_IUD
ON dbo.PAT_BIENES_CARACTERISTICAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Bien varchar(32)
	DECLARE @Cod_Caracteristica varchar(5)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAT_BIENES_CARACTERISTICAS'
	--Variables de tabla secundarias
	DECLARE @Caracteristica varchar(512)
	DECLARE @Valor varchar(512)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Bien,
	--	    i.Cod_Caracteristica,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Cod_Caracteristica,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Bien,'|',@Cod_Caracteristica,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Cod_Caracteristica,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Bien,
			 i.Cod_Caracteristica,
			 i.Caracteristica,
			 i.Valor,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Cod_Caracteristica,'|' ,
			 @Caracteristica,'|' ,
			 @Valor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Bien,'|',@Cod_Caracteristica), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Bien,
			 d.Cod_Caracteristica,
			 d.Caracteristica,
			 d.Valor,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Cod_Caracteristica,'|' ,
			 @Caracteristica,'|' ,
			 @Valor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Bien,'|',@Cod_Caracteristica), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PAT_BIENES_MOVIMIENTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAT_BIENES_MOVIMIENTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAT_BIENES_MOVIMIENTO_IUD
GO

CREATE TRIGGER UTR_PAT_BIENES_MOVIMIENTO_IUD
ON dbo.PAT_BIENES_MOVIMIENTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Bien varchar(32)
	DECLARE @Nro_Movimiento int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAT_BIENES_MOVIMIENTO'
	--Variables de tabla secundarias
	DECLARE @Des_Movimiento varchar(512)
	DECLARE @Cod_TipoBienMov varchar(5)
	DECLARE @Cod_TipoDocMov varchar(5)
	DECLARE @Doc_Movimiento varchar(32)
	DECLARE @Monto numeric(38,2)
	DECLARE @Fecha_Movimiento datetime
	DECLARE @Cod_TrabajadorOrigen varchar(8)
	DECLARE @Cod_TrabajadorDestino varchar(8)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Bien,
	--	    i.Nro_Movimiento,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Nro_Movimiento,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Bien,'|',@Nro_Movimiento,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Bien,
	--	    @Nro_Movimiento,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Bien,
			 i.Nro_Movimiento,
			 i.Des_Movimiento,
			 i.Cod_TipoBienMov,
			 i.Cod_TipoDocMov,
			 i.Doc_Movimiento,
			 i.Monto,
			 i.Fecha_Movimiento,
			 i.Cod_TrabajadorOrigen,
			 i.Cod_TrabajadorDestino,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Nro_Movimiento,
			 @Des_Movimiento,
			 @Cod_TipoBienMov,
			 @Cod_TipoDocMov,
			 @Doc_Movimiento,
			 @Monto,
			 @Fecha_Movimiento,
			 @Cod_TrabajadorOrigen,
			 @Cod_TrabajadorDestino,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Nro_Movimiento,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoBienMov,'|' ,
			 @Cod_TipoDocMov,'|' ,
			 @Doc_Movimiento,'|' ,
			 @Monto,'|' ,
			 CONVERT(varchar,@Fecha_Movimiento,121), '|' ,
			 @Cod_TrabajadorOrigen,'|' ,
			 @Cod_TrabajadorDestino,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Bien,'|',@Nro_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Nro_Movimiento,
			 @Des_Movimiento,
			 @Cod_TipoBienMov,
			 @Cod_TipoDocMov,
			 @Doc_Movimiento,
			 @Monto,
			 @Fecha_Movimiento,
			 @Cod_TrabajadorOrigen,
			 @Cod_TrabajadorDestino,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Bien,
			 d.Nro_Movimiento,
			 d.Des_Movimiento,
			 d.Cod_TipoBienMov,
			 d.Cod_TipoDocMov,
			 d.Doc_Movimiento,
			 d.Monto,
			 d.Fecha_Movimiento,
			 d.Cod_TrabajadorOrigen,
			 d.Cod_TrabajadorDestino,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Bien,
			 @Nro_Movimiento,
			 @Des_Movimiento,
			 @Cod_TipoBienMov,
			 @Cod_TipoDocMov,
			 @Doc_Movimiento,
			 @Monto,
			 @Fecha_Movimiento,
			 @Cod_TrabajadorOrigen,
			 @Cod_TrabajadorDestino,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Bien,'|' ,
			 @Nro_Movimiento,'|' ,
			 @Des_Movimiento,'|' ,
			 @Cod_TipoBienMov,'|' ,
			 @Cod_TipoDocMov,'|' ,
			 @Doc_Movimiento,'|' ,
			 @Monto,'|' ,
			 CONVERT(varchar,@Fecha_Movimiento,121), '|' ,
			 @Cod_TrabajadorOrigen,'|' ,
			 @Cod_TrabajadorDestino,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Bien,'|',@Nro_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Bien,
			 @Nro_Movimiento,
			 @Des_Movimiento,
			 @Cod_TipoBienMov,
			 @Cod_TipoDocMov,
			 @Doc_Movimiento,
			 @Monto,
			 @Fecha_Movimiento,
			 @Cod_TrabajadorOrigen,
			 @Cod_TrabajadorDestino,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PAT_GRUPOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAT_GRUPOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAT_GRUPOS_IUD
GO

CREATE TRIGGER UTR_PAT_GRUPOS_IUD
ON dbo.PAT_GRUPOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Grupo varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAT_GRUPOS'
	--Variables de tabla secundarias
	DECLARE @Des_Grupo varchar(1024)
	DECLARE @Vida_Util int
	DECLARE @Factor_Depreciacion numeric(5,2)
	DECLARE @Cod_CuentaDebe varchar(16)
	DECLARE @Cod_CuentaHaber varchar(16)
	DECLARE @Cod_GrupoPadre varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Grupo,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Grupo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Grupo), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Grupo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Grupo,
			 i.Des_Grupo,
			 i.Vida_Util,
			 i.Factor_Depreciacion,
			 i.Cod_CuentaDebe,
			 i.Cod_CuentaHaber,
			 i.Cod_GrupoPadre,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Grupo,
			 @Des_Grupo,
			 @Vida_Util,
			 @Factor_Depreciacion,
			 @Cod_CuentaDebe,
			 @Cod_CuentaHaber,
			 @Cod_GrupoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Grupo,'|' ,
			 @Des_Grupo,'|' ,
			 @Vida_Util,'|' ,
			 @Factor_Depreciacion,'|' ,
			 @Cod_CuentaDebe,'|' ,
			 @Cod_CuentaHaber,'|' ,
			 @Cod_GrupoPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Grupo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Grupo,
			 @Des_Grupo,
			 @Vida_Util,
			 @Factor_Depreciacion,
			 @Cod_CuentaDebe,
			 @Cod_CuentaHaber,
			 @Cod_GrupoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Grupo,
			 d.Des_Grupo,
			 d.Vida_Util,
			 d.Factor_Depreciacion,
			 d.Cod_CuentaDebe,
			 d.Cod_CuentaHaber,
			 d.Cod_GrupoPadre,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Grupo,
			 @Des_Grupo,
			 @Vida_Util,
			 @Factor_Depreciacion,
			 @Cod_CuentaDebe,
			 @Cod_CuentaHaber,
			 @Cod_GrupoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Grupo,'|' ,
			 @Des_Grupo,'|' ,
			 @Vida_Util,'|' ,
			 @Factor_Depreciacion,'|' ,
			 @Cod_CuentaDebe,'|' ,
			 @Cod_CuentaHaber,'|' ,
			 @Cod_GrupoPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Grupo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Grupo,
			 @Des_Grupo,
			 @Vida_Util,
			 @Factor_Depreciacion,
			 @Cod_CuentaDebe,
			 @Cod_CuentaHaber,
			 @Cod_GrupoPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PAT_GRUPOS_CARACTERISTICAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PAT_GRUPOS_CARACTERISTICAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PAT_GRUPOS_CARACTERISTICAS_IUD
GO

CREATE TRIGGER UTR_PAT_GRUPOS_CARACTERISTICAS_IUD
ON dbo.PAT_GRUPOS_CARACTERISTICAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Grupo varchar(32)
	DECLARE @Cod_Caracteristica varchar(5)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PAT_GRUPOS_CARACTERISTICAS'
	--Variables de tabla secundarias
	DECLARE @Caracteristica varchar(512)
	DECLARE @Predeterminado varchar(512)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Grupo,
	--	    i.Cod_Caracteristica,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Grupo,
	--	    @Cod_Caracteristica,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Grupo,'|',@Cod_Caracteristica,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Grupo,
	--	    @Cod_Caracteristica,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Grupo,
			 i.Cod_Caracteristica,
			 i.Caracteristica,
			 i.Predeterminado,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Grupo,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Predeterminado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Grupo,'|' ,
			 @Cod_Caracteristica,'|' ,
			 @Caracteristica,'|' ,
			 @Predeterminado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Grupo,'|',@Cod_Caracteristica), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Grupo,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Predeterminado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Grupo,
			 d.Cod_Caracteristica,
			 d.Caracteristica,
			 d.Predeterminado,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Grupo,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Predeterminado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Grupo,'|' ,
			 @Cod_Caracteristica,'|' ,
			 @Caracteristica,'|' ,
			 @Predeterminado,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Grupo,'|',@Cod_Caracteristica), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Grupo,
			 @Cod_Caracteristica,
			 @Caracteristica,
			 @Predeterminado,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_AFP_PRIMA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_AFP_PRIMA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_AFP_PRIMA_IUD
GO

CREATE TRIGGER UTR_PLA_AFP_PRIMA_IUD
ON dbo.PLA_AFP_PRIMA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_AFP varchar(5)
	DECLARE @Cod_Periodo varchar(5)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_AFP_PRIMA'
	--Variables de tabla secundarias
	DECLARE @Por_Comision numeric(5,2)
	DECLARE @Por_Aporte numeric(5,2)
	DECLARE @Por_Prima numeric(5,2)
	DECLARE @Monto_Max numeric(38,2)
	DECLARE @Monto_Min numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_AFP,
	--	    i.Cod_Periodo,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_AFP,
	--	    @Cod_Periodo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_AFP,'|',@Cod_Periodo,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_AFP,
	--	    @Cod_Periodo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_AFP,
			 i.Cod_Periodo,
			 i.Por_Comision,
			 i.Por_Aporte,
			 i.Por_Prima,
			 i.Monto_Max,
			 i.Monto_Min,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_AFP,
			 @Cod_Periodo,
			 @Por_Comision,
			 @Por_Aporte,
			 @Por_Prima,
			 @Monto_Max,
			 @Monto_Min,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_AFP,'|' ,
			 @Cod_Periodo,'|' ,
			 @Por_Comision,'|' ,
			 @Por_Aporte,'|' ,
			 @Por_Prima,'|' ,
			 @Monto_Max,'|' ,
			 @Monto_Min,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_AFP,'|',@Cod_Periodo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_AFP,
			 @Cod_Periodo,
			 @Por_Comision,
			 @Por_Aporte,
			 @Por_Prima,
			 @Monto_Max,
			 @Monto_Min,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_AFP,
			 d.Cod_Periodo,
			 d.Por_Comision,
			 d.Por_Aporte,
			 d.Por_Prima,
			 d.Monto_Max,
			 d.Monto_Min,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_AFP,
			 @Cod_Periodo,
			 @Por_Comision,
			 @Por_Aporte,
			 @Por_Prima,
			 @Monto_Max,
			 @Monto_Min,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_AFP,'|' ,
			 @Cod_Periodo,'|' ,
			 @Por_Comision,'|' ,
			 @Por_Aporte,'|' ,
			 @Por_Prima,'|' ,
			 @Monto_Max,'|' ,
			 @Monto_Min,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_AFP,'|',@Cod_Periodo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_AFP,
			 @Cod_Periodo,
			 @Por_Comision,
			 @Por_Aporte,
			 @Por_Prima,
			 @Monto_Max,
			 @Monto_Min,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PLA_ASISTENCIA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_ASISTENCIA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_ASISTENCIA_IUD
GO

CREATE TRIGGER UTR_PLA_ASISTENCIA_IUD
ON dbo.PLA_ASISTENCIA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Asistencia int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_ASISTENCIA'
	--Variables de tabla secundarias
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Id_Horario int
	DECLARE @Cod_Estado varchar(5)
	DECLARE @Turno varchar(32)
	DECLARE @Fecha datetime
	DECLARE @HoraEntrada datetime
	DECLARE @HoraSalida datetime
	DECLARE @Entro datetime
	DECLARE @Salio datetime
	DECLARE @Cod_Incidencia varchar(5)
	DECLARE @Cod_Proceso varchar(5)
	DECLARE @Obs_Asistencia varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Asistencia,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Asistencia,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Asistencia), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Asistencia,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Asistencia,
			 i.Cod_Personal,
			 i.Id_Horario,
			 i.Cod_Estado,
			 i.Turno,
			 i.Fecha,
			 i.HoraEntrada,
			 i.HoraSalida,
			 i.Entro,
			 i.Salio,
			 i.Cod_Incidencia,
			 i.Cod_Proceso,
			 i.Obs_Asistencia,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Asistencia,
			 @Cod_Personal,
			 @Id_Horario,
			 @Cod_Estado,
			 @Turno,
			 @Fecha,
			 @HoraEntrada,
			 @HoraSalida,
			 @Entro,
			 @Salio,
			 @Cod_Incidencia,
			 @Cod_Proceso,
			 @Obs_Asistencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Asistencia,'|' ,
			 @Cod_Personal,'|' ,
			 @Id_Horario,'|' ,
			 @Cod_Estado,'|' ,
			 @Turno,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 CONVERT(varchar,@HoraEntrada,121), '|' ,
			 CONVERT(varchar,@HoraSalida,121), '|' ,
			 CONVERT(varchar,@Entro,121), '|' ,
			 CONVERT(varchar,@Salio,121), '|' ,
			 @Cod_Incidencia,'|' ,
			 @Cod_Proceso,'|' ,
			 @Obs_Asistencia,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Id_Asistencia), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Asistencia,
			 @Cod_Personal,
			 @Id_Horario,
			 @Cod_Estado,
			 @Turno,
			 @Fecha,
			 @HoraEntrada,
			 @HoraSalida,
			 @Entro,
			 @Salio,
			 @Cod_Incidencia,
			 @Cod_Proceso,
			 @Obs_Asistencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Asistencia,
			 d.Cod_Personal,
			 d.Id_Horario,
			 d.Cod_Estado,
			 d.Turno,
			 d.Fecha,
			 d.HoraEntrada,
			 d.HoraSalida,
			 d.Entro,
			 d.Salio,
			 d.Cod_Incidencia,
			 d.Cod_Proceso,
			 d.Obs_Asistencia,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Asistencia,
			 @Cod_Personal,
			 @Id_Horario,
			 @Cod_Estado,
			 @Turno,
			 @Fecha,
			 @HoraEntrada,
			 @HoraSalida,
			 @Entro,
			 @Salio,
			 @Cod_Incidencia,
			 @Cod_Proceso,
			 @Obs_Asistencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Asistencia,'|' ,
			 @Cod_Personal,'|' ,
			 @Id_Horario,'|' ,
			 @Cod_Estado,'|' ,
			 @Turno,'|' ,
			 CONVERT(varchar,@Fecha,121), '|' ,
			 CONVERT(varchar,@HoraEntrada,121), '|' ,
			 CONVERT(varchar,@HoraSalida,121), '|' ,
			 CONVERT(varchar,@Entro,121), '|' ,
			 CONVERT(varchar,@Salio,121), '|' ,
			 @Cod_Incidencia,'|' ,
			 @Cod_Proceso,'|' ,
			 @Obs_Asistencia,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT('',@Id_Asistencia), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Asistencia,
			 @Cod_Personal,
			 @Id_Horario,
			 @Cod_Estado,
			 @Turno,
			 @Fecha,
			 @HoraEntrada,
			 @HoraSalida,
			 @Entro,
			 @Salio,
			 @Cod_Incidencia,
			 @Cod_Proceso,
			 @Obs_Asistencia,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_BIOMETRICO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_BIOMETRICO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_BIOMETRICO_IUD
GO

CREATE TRIGGER UTR_PLA_BIOMETRICO_IUD
ON dbo.PLA_BIOMETRICO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Biometrico int
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_BIOMETRICO'
	--Variables de tabla secundarias
	DECLARE @Des_Biometrico varchar(512)
	DECLARE @HashHuella10 varchar(max)
	DECLARE @Obs_Biometrico varchar(max)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Biometrico,
	--	    i.Cod_Personal,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Biometrico,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Biometrico,'|',@Cod_Personal,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Biometrico,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Biometrico,
			 i.Cod_Personal,
			 i.Des_Biometrico,
			 i.HashHuella10,
			 i.Obs_Biometrico,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Biometrico,
			 @Cod_Personal,
			 @Des_Biometrico,
			 @HashHuella10,
			 @Obs_Biometrico,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Biometrico,'|' ,
			 @Cod_Personal,'|' ,
			 @Des_Biometrico,'|' ,
			 @HashHuella10,'|' ,
			 @Obs_Biometrico,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Id_Biometrico,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Biometrico,
			 @Cod_Personal,
			 @Des_Biometrico,
			 @HashHuella10,
			 @Obs_Biometrico,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Biometrico,
			 d.Cod_Personal,
			 d.Des_Biometrico,
			 d.HashHuella10,
			 d.Obs_Biometrico,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Biometrico,
			 @Cod_Personal,
			 @Des_Biometrico,
			 @HashHuella10,
			 @Obs_Biometrico,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Biometrico,'|' ,
			 @Cod_Personal,'|' ,
			 @Des_Biometrico,'|' ,
			 @HashHuella10,'|' ,
			 @Obs_Biometrico,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Id_Biometrico,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Biometrico,
			 @Cod_Personal,
			 @Des_Biometrico,
			 @HashHuella10,
			 @Obs_Biometrico,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_BOLETA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_BOLETA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_BOLETA_IUD
GO

CREATE TRIGGER UTR_PLA_BOLETA_IUD
ON dbo.PLA_BOLETA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Planilla varchar(32)
	DECLARE @NroColumna int
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_BOLETA'
	--Variables de tabla secundarias
	DECLARE @Cod_Concepto varchar(32)
	DECLARE @Des_Boleta varchar(128)
	DECLARE @Cod_ContraCuenta varchar(16)
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Monto numeric(38,4)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Planilla,
	--	    i.NroColumna,
	--	    i.Cod_Personal,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Planilla,
	--	    @NroColumna,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Planilla,'|',@NroColumna,'|',@Cod_Personal,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Planilla,
	--	    @NroColumna,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Planilla,
			 i.NroColumna,
			 i.Cod_Personal,
			 i.Cod_Concepto,
			 i.Des_Boleta,
			 i.Cod_ContraCuenta,
			 i.Cod_CuentaContable,
			 i.Monto,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Planilla,
			 @NroColumna,
			 @Cod_Personal,
			 @Cod_Concepto,
			 @Des_Boleta,
			 @Cod_ContraCuenta,
			 @Cod_CuentaContable,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Planilla,'|' ,
			 @NroColumna,'|' ,
			 @Cod_Personal,'|' ,
			 @Cod_Concepto,'|' ,
			 @Des_Boleta,'|' ,
			 @Cod_ContraCuenta,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Monto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Planilla,'|',@NroColumna,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Planilla,
			 @NroColumna,
			 @Cod_Personal,
			 @Cod_Concepto,
			 @Des_Boleta,
			 @Cod_ContraCuenta,
			 @Cod_CuentaContable,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Planilla,
			 d.NroColumna,
			 d.Cod_Personal,
			 d.Cod_Concepto,
			 d.Des_Boleta,
			 d.Cod_ContraCuenta,
			 d.Cod_CuentaContable,
			 d.Monto,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Planilla,
			 @NroColumna,
			 @Cod_Personal,
			 @Cod_Concepto,
			 @Des_Boleta,
			 @Cod_ContraCuenta,
			 @Cod_CuentaContable,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Planilla,'|' ,
			 @NroColumna,'|' ,
			 @Cod_Personal,'|' ,
			 @Cod_Concepto,'|' ,
			 @Des_Boleta,'|' ,
			 @Cod_ContraCuenta,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Monto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Planilla,'|',@NroColumna,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Planilla,
			 @NroColumna,
			 @Cod_Personal,
			 @Cod_Concepto,
			 @Des_Boleta,
			 @Cod_ContraCuenta,
			 @Cod_CuentaContable,
			 @Monto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_CONCEPTOS_PLANILLA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_CONCEPTOS_PLANILLA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_CONCEPTOS_PLANILLA_IUD
GO

CREATE TRIGGER UTR_PLA_CONCEPTOS_PLANILLA_IUD
ON dbo.PLA_CONCEPTOS_PLANILLA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Concepto varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_CONCEPTOS_PLANILLA'
	--Variables de tabla secundarias
	DECLARE @Des_Concepto varchar(128)
	DECLARE @Des_Boleta varchar(128)
	DECLARE @Cod_TipoConcepto varchar(5)
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Cod_ContraCuenta varchar(16)
	DECLARE @Cod_ConceptoPDT varchar(5)
	DECLARE @Flag_EsQuintaCat bit
	DECLARE @Flag_AfectoQuinta bit
	DECLARE @Flag_AfectoCTS bit
	DECLARE @Flag_AfectoSENATI bit
	DECLARE @Flag_AfectoESSALUD bit
	DECLARE @Flag_AfectoAFP bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Concepto,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Concepto,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Concepto), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Concepto,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Concepto,
			 i.Des_Concepto,
			 i.Des_Boleta,
			 i.Cod_TipoConcepto,
			 i.Cod_CuentaContable,
			 i.Cod_ContraCuenta,
			 i.Cod_ConceptoPDT,
			 i.Flag_EsQuintaCat,
			 i.Flag_AfectoQuinta,
			 i.Flag_AfectoCTS,
			 i.Flag_AfectoSENATI,
			 i.Flag_AfectoESSALUD,
			 i.Flag_AfectoAFP,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Concepto,
			 @Des_Concepto,
			 @Des_Boleta,
			 @Cod_TipoConcepto,
			 @Cod_CuentaContable,
			 @Cod_ContraCuenta,
			 @Cod_ConceptoPDT,
			 @Flag_EsQuintaCat,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Flag_AfectoSENATI,
			 @Flag_AfectoESSALUD,
			 @Flag_AfectoAFP,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Concepto,'|' ,
			 @Des_Concepto,'|' ,
			 @Des_Boleta,'|' ,
			 @Cod_TipoConcepto,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_ContraCuenta,'|' ,
			 @Cod_ConceptoPDT,'|' ,
			 @Flag_EsQuintaCat,'|' ,
			 @Flag_AfectoQuinta,'|' ,
			 @Flag_AfectoCTS,'|' ,
			 @Flag_AfectoSENATI,'|' ,
			 @Flag_AfectoESSALUD,'|' ,
			 @Flag_AfectoAFP,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Concepto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Concepto,
			 @Des_Concepto,
			 @Des_Boleta,
			 @Cod_TipoConcepto,
			 @Cod_CuentaContable,
			 @Cod_ContraCuenta,
			 @Cod_ConceptoPDT,
			 @Flag_EsQuintaCat,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Flag_AfectoSENATI,
			 @Flag_AfectoESSALUD,
			 @Flag_AfectoAFP,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Concepto,
			 d.Des_Concepto,
			 d.Des_Boleta,
			 d.Cod_TipoConcepto,
			 d.Cod_CuentaContable,
			 d.Cod_ContraCuenta,
			 d.Cod_ConceptoPDT,
			 d.Flag_EsQuintaCat,
			 d.Flag_AfectoQuinta,
			 d.Flag_AfectoCTS,
			 d.Flag_AfectoSENATI,
			 d.Flag_AfectoESSALUD,
			 d.Flag_AfectoAFP,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Concepto,
			 @Des_Concepto,
			 @Des_Boleta,
			 @Cod_TipoConcepto,
			 @Cod_CuentaContable,
			 @Cod_ContraCuenta,
			 @Cod_ConceptoPDT,
			 @Flag_EsQuintaCat,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Flag_AfectoSENATI,
			 @Flag_AfectoESSALUD,
			 @Flag_AfectoAFP,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Concepto,'|' ,
			 @Des_Concepto,'|' ,
			 @Des_Boleta,'|' ,
			 @Cod_TipoConcepto,'|' ,
			 @Cod_CuentaContable,'|' ,
			 @Cod_ContraCuenta,'|' ,
			 @Cod_ConceptoPDT,'|' ,
			 @Flag_EsQuintaCat,'|' ,
			 @Flag_AfectoQuinta,'|' ,
			 @Flag_AfectoCTS,'|' ,
			 @Flag_AfectoSENATI,'|' ,
			 @Flag_AfectoESSALUD,'|' ,
			 @Flag_AfectoAFP,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Concepto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Concepto,
			 @Des_Concepto,
			 @Des_Boleta,
			 @Cod_TipoConcepto,
			 @Cod_CuentaContable,
			 @Cod_ContraCuenta,
			 @Cod_ConceptoPDT,
			 @Flag_EsQuintaCat,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Flag_AfectoSENATI,
			 @Flag_AfectoESSALUD,
			 @Flag_AfectoAFP,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_CONTRATOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_CONTRATOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_CONTRATOS_IUD
GO

CREATE TRIGGER UTR_PLA_CONTRATOS_IUD
ON dbo.PLA_CONTRATOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Nro_Contrato int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_CONTRATOS'
	--Variables de tabla secundarias
	DECLARE @Des_Contrato varchar(32)
	DECLARE @Cod_Area varchar(32)
	DECLARE @Cod_TipoContrato varchar(5)
	DECLARE @Fecha_Firma datetime
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Cod_Cargo varchar(5)
	DECLARE @Monto_Base numeric(38,2)
	DECLARE @Obs_Contrato varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Personal,
	--	    i.Nro_Contrato,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Personal,
	--	    @Nro_Contrato,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Personal,'|',@Nro_Contrato,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Personal,
	--	    @Nro_Contrato,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Personal,
			 i.Nro_Contrato,
			 i.Des_Contrato,
			 i.Cod_Area,
			 i.Cod_TipoContrato,
			 i.Fecha_Firma,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Cod_Cargo,
			 i.Monto_Base,
			 i.Obs_Contrato,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Personal,
			 @Nro_Contrato,
			 @Des_Contrato,
			 @Cod_Area,
			 @Cod_TipoContrato,
			 @Fecha_Firma,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_Cargo,
			 @Monto_Base,
			 @Obs_Contrato,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Nro_Contrato,'|' ,
			 @Des_Contrato,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_TipoContrato,'|' ,
			 CONVERT(varchar,@Fecha_Firma,121), '|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Cod_Cargo,'|' ,
			 @Monto_Base,'|' ,
			 @Obs_Contrato,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Personal,'|',@Nro_Contrato), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Personal,
			 @Nro_Contrato,
			 @Des_Contrato,
			 @Cod_Area,
			 @Cod_TipoContrato,
			 @Fecha_Firma,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_Cargo,
			 @Monto_Base,
			 @Obs_Contrato,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Personal,
			 d.Nro_Contrato,
			 d.Des_Contrato,
			 d.Cod_Area,
			 d.Cod_TipoContrato,
			 d.Fecha_Firma,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Cod_Cargo,
			 d.Monto_Base,
			 d.Obs_Contrato,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Personal,
			 @Nro_Contrato,
			 @Des_Contrato,
			 @Cod_Area,
			 @Cod_TipoContrato,
			 @Fecha_Firma,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_Cargo,
			 @Monto_Base,
			 @Obs_Contrato,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Nro_Contrato,'|' ,
			 @Des_Contrato,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_TipoContrato,'|' ,
			 CONVERT(varchar,@Fecha_Firma,121), '|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Cod_Cargo,'|' ,
			 @Monto_Base,'|' ,
			 @Obs_Contrato,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_Personal,'|',@Nro_Contrato), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Personal,
			 @Nro_Contrato,
			 @Des_Contrato,
			 @Cod_Area,
			 @Cod_TipoContrato,
			 @Fecha_Firma,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_Cargo,
			 @Monto_Base,
			 @Obs_Contrato,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_HORARIOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_HORARIOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_HORARIOS_IUD
GO

CREATE TRIGGER UTR_PLA_HORARIOS_IUD
ON dbo.PLA_HORARIOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Horario int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_HORARIOS'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoHorario varchar(8)
	DECLARE @Turno varchar(32)
	DECLARE @HoraEntrada datetime
	DECLARE @HoraSalida datetime
	DECLARE @Dias varchar(7)
	DECLARE @Tiempo int
	DECLARE @Flag_Corrido bit
	DECLARE @Flag_ContemplaDias bit
	DECLARE @Id_HorarioPadre int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Horario,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Horario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Horario), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Horario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Horario,
			 i.Cod_TipoHorario,
			 i.Turno,
			 i.HoraEntrada,
			 i.HoraSalida,
			 i.Dias,
			 i.Tiempo,
			 i.Flag_Corrido,
			 i.Flag_ContemplaDias,
			 i.Id_HorarioPadre,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Horario,
			 @Cod_TipoHorario,
			 @Turno,
			 @HoraEntrada,
			 @HoraSalida,
			 @Dias,
			 @Tiempo,
			 @Flag_Corrido,
			 @Flag_ContemplaDias,
			 @Id_HorarioPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Horario,'|' ,
			 @Cod_TipoHorario,'|' ,
			 @Turno,'|' ,
			 CONVERT(varchar,@HoraEntrada,121), '|' ,
			 CONVERT(varchar,@HoraSalida,121), '|' ,
			 @Dias,'|' ,
			 @Tiempo,'|' ,
			 @Flag_Corrido,'|' ,
			 @Flag_ContemplaDias,'|' ,
			 @Id_HorarioPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Horario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Horario,
			 @Cod_TipoHorario,
			 @Turno,
			 @HoraEntrada,
			 @HoraSalida,
			 @Dias,
			 @Tiempo,
			 @Flag_Corrido,
			 @Flag_ContemplaDias,
			 @Id_HorarioPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Horario,
			 d.Cod_TipoHorario,
			 d.Turno,
			 d.HoraEntrada,
			 d.HoraSalida,
			 d.Dias,
			 d.Tiempo,
			 d.Flag_Corrido,
			 d.Flag_ContemplaDias,
			 d.Id_HorarioPadre,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Horario,
			 @Cod_TipoHorario,
			 @Turno,
			 @HoraEntrada,
			 @HoraSalida,
			 @Dias,
			 @Tiempo,
			 @Flag_Corrido,
			 @Flag_ContemplaDias,
			 @Id_HorarioPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Horario,'|' ,
			 @Cod_TipoHorario,'|' ,
			 @Turno,'|' ,
			 CONVERT(varchar,@HoraEntrada,121), '|' ,
			 CONVERT(varchar,@HoraSalida,121), '|' ,
			 @Dias,'|' ,
			 @Tiempo,'|' ,
			 @Flag_Corrido,'|' ,
			 @Flag_ContemplaDias,'|' ,
			 @Id_HorarioPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Horario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Horario,
			 @Cod_TipoHorario,
			 @Turno,
			 @HoraEntrada,
			 @HoraSalida,
			 @Dias,
			 @Tiempo,
			 @Flag_Corrido,
			 @Flag_ContemplaDias,
			 @Id_HorarioPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_PERSONAL_HORARIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_PERSONAL_HORARIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_PERSONAL_HORARIO_IUD
GO

CREATE TRIGGER UTR_PLA_PERSONAL_HORARIO_IUD
ON dbo.PLA_PERSONAL_HORARIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_PersonalHorario int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_PERSONAL_HORARIO'
	--Variables de tabla secundarias
	DECLARE @Id_Horario int
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_PersonalHorario,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_PersonalHorario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_PersonalHorario), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_PersonalHorario,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_PersonalHorario,
			 i.Id_Horario,
			 i.Cod_Personal,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_PersonalHorario,
			 @Id_Horario,
			 @Cod_Personal,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_PersonalHorario,'|' ,
			 @Id_Horario,'|' ,
			 @Cod_Personal,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_PersonalHorario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_PersonalHorario,
			 @Id_Horario,
			 @Cod_Personal,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_PersonalHorario,
			 d.Id_Horario,
			 d.Cod_Personal,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_PersonalHorario,
			 @Id_Horario,
			 @Cod_Personal,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_PersonalHorario,'|' ,
			 @Id_Horario,'|' ,
			 @Cod_Personal,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_PersonalHorario), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_PersonalHorario,
			 @Id_Horario,
			 @Cod_Personal,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_PLANILLA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_PLANILLA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_PLANILLA_IUD
GO

CREATE TRIGGER UTR_PLA_PLANILLA_IUD
ON dbo.PLA_PLANILLA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Planilla varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_PLANILLA'
	--Variables de tabla secundarias
	DECLARE @Cod_PlanillaTipo varchar(32)
	DECLARE @Des_Planilla varchar(128)
	DECLARE @Cod_Periodo varchar(8)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Fecha_Pago datetime
	DECLARE @Fecha_Cierre datetime
	DECLARE @Flag_Cierre bit
	DECLARE @Flag_AfectoQuinta bit
	DECLARE @Flag_AfectoCTS bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Planilla,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Planilla,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Planilla), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Planilla,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Planilla,
			 i.Cod_PlanillaTipo,
			 i.Des_Planilla,
			 i.Cod_Periodo,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Fecha_Pago,
			 i.Fecha_Cierre,
			 i.Flag_Cierre,
			 i.Flag_AfectoQuinta,
			 i.Flag_AfectoCTS,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Planilla,
			 @Cod_PlanillaTipo,
			 @Des_Planilla,
			 @Cod_Periodo,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Fecha_Pago,
			 @Fecha_Cierre,
			 @Flag_Cierre,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Planilla,'|' ,
			 @Cod_PlanillaTipo,'|' ,
			 @Des_Planilla,'|' ,
			 @Cod_Periodo,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 CONVERT(varchar,@Fecha_Pago,121), '|' ,
			 CONVERT(varchar,@Fecha_Cierre,121), '|' ,
			 @Flag_Cierre,'|' ,
			 @Flag_AfectoQuinta,'|' ,
			 @Flag_AfectoCTS,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Planilla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Planilla,
			 @Cod_PlanillaTipo,
			 @Des_Planilla,
			 @Cod_Periodo,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Fecha_Pago,
			 @Fecha_Cierre,
			 @Flag_Cierre,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Planilla,
			 d.Cod_PlanillaTipo,
			 d.Des_Planilla,
			 d.Cod_Periodo,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Fecha_Pago,
			 d.Fecha_Cierre,
			 d.Flag_Cierre,
			 d.Flag_AfectoQuinta,
			 d.Flag_AfectoCTS,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Planilla,
			 @Cod_PlanillaTipo,
			 @Des_Planilla,
			 @Cod_Periodo,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Fecha_Pago,
			 @Fecha_Cierre,
			 @Flag_Cierre,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Planilla,'|' ,
			 @Cod_PlanillaTipo,'|' ,
			 @Des_Planilla,'|' ,
			 @Cod_Periodo,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 CONVERT(varchar,@Fecha_Pago,121), '|' ,
			 CONVERT(varchar,@Fecha_Cierre,121), '|' ,
			 @Flag_Cierre,'|' ,
			 @Flag_AfectoQuinta,'|' ,
			 @Flag_AfectoCTS,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Planilla), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Planilla,
			 @Cod_PlanillaTipo,
			 @Des_Planilla,
			 @Cod_Periodo,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Fecha_Pago,
			 @Fecha_Cierre,
			 @Flag_Cierre,
			 @Flag_AfectoQuinta,
			 @Flag_AfectoCTS,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_PLANILLA_TIPO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_PLANILLA_TIPO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_PLANILLA_TIPO_IUD
GO

CREATE TRIGGER UTR_PLA_PLANILLA_TIPO_IUD
ON dbo.PLA_PLANILLA_TIPO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_PlanillaTipo varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_PLANILLA_TIPO'
	--Variables de tabla secundarias
	DECLARE @Des_PlanillaTipo varchar(128)
	DECLARE @Cod_TipoImresionBoleta varchar(5)
	DECLARE @Obs_PlanillaTipo varchar(1024)
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_PlanillaTipo,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_PlanillaTipo), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_PlanillaTipo,
			 i.Des_PlanillaTipo,
			 i.Cod_TipoImresionBoleta,
			 i.Obs_PlanillaTipo,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @Des_PlanillaTipo,
			 @Cod_TipoImresionBoleta,
			 @Obs_PlanillaTipo,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @Des_PlanillaTipo,'|' ,
			 @Cod_TipoImresionBoleta,'|' ,
			 @Obs_PlanillaTipo,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_PlanillaTipo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @Des_PlanillaTipo,
			 @Cod_TipoImresionBoleta,
			 @Obs_PlanillaTipo,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_PlanillaTipo,
			 d.Des_PlanillaTipo,
			 d.Cod_TipoImresionBoleta,
			 d.Obs_PlanillaTipo,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @Des_PlanillaTipo,
			 @Cod_TipoImresionBoleta,
			 @Obs_PlanillaTipo,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @Des_PlanillaTipo,'|' ,
			 @Cod_TipoImresionBoleta,'|' ,
			 @Obs_PlanillaTipo,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_PlanillaTipo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @Des_PlanillaTipo,
			 @Cod_TipoImresionBoleta,
			 @Obs_PlanillaTipo,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_PLANILLA_TIPO_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_PLANILLA_TIPO_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_PLANILLA_TIPO_D_IUD
GO

CREATE TRIGGER UTR_PLA_PLANILLA_TIPO_D_IUD
ON dbo.PLA_PLANILLA_TIPO_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_PlanillaTipo varchar(32)
	DECLARE @NroColumna int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_PLANILLA_TIPO_D'
	--Variables de tabla secundarias
	DECLARE @Cod_Concepto varchar(32)
	DECLARE @Rotulo1 varchar(20)
	DECLARE @Rotulo2 varchar(20)
	DECLARE @Formula varchar(1024)
	DECLARE @Obs_Detalle varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_PlanillaTipo,
	--	    i.NroColumna,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @NroColumna,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_PlanillaTipo,'|',@NroColumna,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @NroColumna,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_PlanillaTipo,
			 i.NroColumna,
			 i.Cod_Concepto,
			 i.Rotulo1,
			 i.Rotulo2,
			 i.Formula,
			 i.Obs_Detalle,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @NroColumna,
			 @Cod_Concepto,
			 @Rotulo1,
			 @Rotulo2,
			 @Formula,
			 @Obs_Detalle,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @NroColumna,'|' ,
			 @Cod_Concepto,'|' ,
			 @Rotulo1,'|' ,
			 @Rotulo2,'|' ,
			 @Formula,'|' ,
			 @Obs_Detalle,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_PlanillaTipo,'|',@NroColumna), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @NroColumna,
			 @Cod_Concepto,
			 @Rotulo1,
			 @Rotulo2,
			 @Formula,
			 @Obs_Detalle,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_PlanillaTipo,
			 d.NroColumna,
			 d.Cod_Concepto,
			 d.Rotulo1,
			 d.Rotulo2,
			 d.Formula,
			 d.Obs_Detalle,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @NroColumna,
			 @Cod_Concepto,
			 @Rotulo1,
			 @Rotulo2,
			 @Formula,
			 @Obs_Detalle,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @NroColumna,'|' ,
			 @Cod_Concepto,'|' ,
			 @Rotulo1,'|' ,
			 @Rotulo2,'|' ,
			 @Formula,'|' ,
			 @Obs_Detalle,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_PlanillaTipo,'|',@NroColumna), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @NroColumna,
			 @Cod_Concepto,
			 @Rotulo1,
			 @Rotulo2,
			 @Formula,
			 @Obs_Detalle,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PLA_PLANILLA_TIPO_PERSONAL
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD
GO

CREATE TRIGGER UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD
ON dbo.PLA_PLANILLA_TIPO_PERSONAL
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_PlanillaTipo varchar(32)
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PLA_PLANILLA_TIPO_PERSONAL'
	--Variables de tabla secundarias
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_PlanillaTipo,
	--	    i.Cod_Personal,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_PlanillaTipo,'|',@Cod_Personal,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_PlanillaTipo,
	--	    @Cod_Personal,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_PlanillaTipo,
			 i.Cod_Personal,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @Cod_Personal,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @Cod_Personal,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_PlanillaTipo,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @Cod_Personal,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_PlanillaTipo,
			 d.Cod_Personal,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_PlanillaTipo,
			 @Cod_Personal,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_PlanillaTipo,'|' ,
			 @Cod_Personal,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Cod_PlanillaTipo,'|',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_PlanillaTipo,
			 @Cod_Personal,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_ACTIVIDADES_ECONOMICAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD
GO

CREATE TRIGGER UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD
ON dbo.PRI_ACTIVIDADES_ECONOMICAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_ActividadEconomica varchar(32)
	DECLARE @Id_ClienteProveedor int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_ACTIVIDADES_ECONOMICAS'
	--Variables de tabla secundarias
	DECLARE @CIIU varchar(32)
	DECLARE @Escala varchar(64)
	DECLARE @Des_ActividadEconomica varchar(512)
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_ActividadEconomica,
		    i.Id_ClienteProveedor,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_ActividadEconomica,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_ACTIVIDADES_ECONOMICAS_I ' +
			  ''''+pae.Cod_ActividadEconomica+''','+
			  CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  CASE WHEN  pae.CIIU IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pae.CIIU,'''','')+''','END+
			  CASE WHEN  pae.Escala IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pae.Escala,'''','')+''','END+
			  CASE WHEN  pae.Des_ActividadEconomica IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pae.Des_ActividadEconomica,'''','')+''','END+
			  CONVERT(varchar(max), pae.Flag_Activo)+','+
			  ''''+REPLACE(COALESCE(pae.Cod_UsuarioAct,pae.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  pae INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pae.Id_ClienteProveedor=pcp.Id_ClienteProveedor
			  WHERE pae.Cod_ActividadEconomica=@Cod_ActividadEconomica AND pae.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_ActividadEconomica,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_ActividadEconomica,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_ActividadEconomica,
		    d.Id_ClienteProveedor,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_ActividadEconomica,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_ACTIVIDADES_ECONOMICAS_D ' +
			  ''''+pae.Cod_ActividadEconomica+''','+
			  CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pae INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pae.Id_ClienteProveedor=pcp.Id_ClienteProveedor
			  WHERE pae.Cod_ActividadEconomica=@Cod_ActividadEconomica AND pae.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_ActividadEconomica,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_ActividadEconomica,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_ActividadEconomica,
			 i.Id_ClienteProveedor,
			 i.CIIU,
			 i.Escala,
			 i.Des_ActividadEconomica,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_ActividadEconomica,
			 @Id_ClienteProveedor,
			 @CIIU,
			 @Escala,
			 @Des_ActividadEconomica,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_ActividadEconomica,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @CIIU,'|' ,
			 @Escala,'|' ,
			 @Des_ActividadEconomica,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_ActividadEconomica,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_ActividadEconomica,
			 @Id_ClienteProveedor,
			 @CIIU,
			 @Escala,
			 @Des_ActividadEconomica,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_ActividadEconomica,
			 d.Id_ClienteProveedor,
			 d.CIIU,
			 d.Escala,
			 d.Des_ActividadEconomica,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_ActividadEconomica,
			 @Id_ClienteProveedor,
			 @CIIU,
			 @Escala,
			 @Des_ActividadEconomica,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_ActividadEconomica,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @CIIU,'|' ,
			 @Escala,'|' ,
			 @Des_ActividadEconomica,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_ActividadEconomica,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_ActividadEconomica,
			 @Id_ClienteProveedor,
			 @CIIU,
			 @Escala,
			 @Des_ActividadEconomica,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_AREAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_AREAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_AREAS_IUD
GO

CREATE TRIGGER UTR_PRI_AREAS_IUD
ON dbo.PRI_AREAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Area varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_AREAS'
	--Variables de tabla secundarias
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Des_Area varchar(512)
	DECLARE @Numero varchar(512)
	DECLARE @Cod_AreaPadre varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Area,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Area,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_AREAS_I ' +
			  ''''+REPLACE(pa.Cod_Area,'''','')+''','+
			  CASE WHEN  pa.Cod_Sucursal IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pa.Cod_Sucursal,'''','')+''','END+
			  CASE WHEN  pa.Des_Area IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pa.Des_Area,'''','')+''','END+
			  CASE WHEN  pa.Numero IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pa.Numero,'''','')+''','END+
			  CASE WHEN  pa.Cod_AreaPadre IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pa.Cod_AreaPadre,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pa.Cod_UsuarioAct,pa.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  pa 
			  WHERE pa.Cod_Area=@Cod_Area

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Area), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Area,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Area,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Area,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_AREAS_D ' +
			  ''''+REPLACE(pa.Cod_Area,'''','')+''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  pa 
			  WHERE pa.Cod_Area=@Cod_Area

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Area), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Area,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Area,
			 i.Cod_Sucursal,
			 i.Des_Area,
			 i.Numero,
			 i.Cod_AreaPadre,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Area,
			 @Cod_Sucursal,
			 @Des_Area,
			 @Numero,
			 @Cod_AreaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Area,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Des_Area,'|' ,
			 @Numero,'|' ,
			 @Cod_AreaPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Area), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Area,
			 @Cod_Sucursal,
			 @Des_Area,
			 @Numero,
			 @Cod_AreaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Area,
			 d.Cod_Sucursal,
			 d.Des_Area,
			 d.Numero,
			 d.Cod_AreaPadre,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Area,
			 @Cod_Sucursal,
			 @Des_Area,
			 @Numero,
			 @Cod_AreaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Area,'|' ,
			 @Cod_Sucursal,'|' ,
			 @Des_Area,'|' ,
			 @Numero,'|' ,
			 @Cod_AreaPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Area), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Area,
			 @Cod_Sucursal,
			 @Des_Area,
			 @Numero,
			 @Cod_AreaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CATEGORIA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CATEGORIA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CATEGORIA_IUD
GO

CREATE TRIGGER UTR_PRI_CATEGORIA_IUD
ON dbo.PRI_CATEGORIA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Categoria varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CATEGORIA'
	--Variables de tabla secundarias
	DECLARE @Des_Categoria varchar(64)
	DECLARE @Cod_CategoriaPadre varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CATEGORIA_I ' +
			  ''''+REPLACE(pc.Cod_Categoria,'''','')+''','+
			  CASE WHEN  pc.Des_Categoria IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pc.Des_Categoria,'''','')+''','END+
			  'NULL,'+
			  CASE WHEN  pc.Cod_CategoriaPadre IS NULL  THEN 'NULL,'    ELSE ''''+REPLACE(pc.Cod_CategoriaPadre,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pc.Cod_UsuarioAct,pc.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  pc 
			  WHERE pc.Cod_Categoria=@Cod_Categoria

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Categoria), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Categoria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Categoria,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Categoria,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CATEGORIA_D ' +
			  ''''+REPLACE(pc.Cod_Categoria,'''','')+''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  pc 
			  WHERE pc.Cod_Categoria=@Cod_Categoria

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Categoria), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Categoria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Categoria,
			 i.Des_Categoria,
			 i.Cod_CategoriaPadre,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Categoria,
			 @Des_Categoria,
			 @Cod_CategoriaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Categoria,'|' ,
			 @Des_Categoria,'|' ,
			 @Cod_CategoriaPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Categoria), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Categoria,
			 @Des_Categoria,
			 @Cod_CategoriaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Categoria,
			 d.Des_Categoria,
			 d.Cod_CategoriaPadre,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Categoria,
			 @Des_Categoria,
			 @Cod_CategoriaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Categoria,'|' ,
			 @Des_Categoria,'|' ,
			 @Cod_CategoriaPadre,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Categoria), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Categoria,
			 @Des_Categoria,
			 @Cod_CategoriaPadre,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CLIENTE_CONTACTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_CONTACTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_CONTACTO_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_CONTACTO_IUD
ON dbo.PRI_CLIENTE_CONTACTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Id_ClienteContacto int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_CONTACTO'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoDocumento varchar(5)
	DECLARE @Nro_Documento varchar(20)
	DECLARE @Ap_Paterno varchar(128)
	DECLARE @Ap_Materno varchar(128)
	DECLARE @Nombres varchar(128)
	DECLARE @Cod_Telefono varchar(5)
	DECLARE @Nro_Telefono varchar(64)
	DECLARE @Anexo varchar(32)
	DECLARE @Email_Empresarial varchar(512)
	DECLARE @Email_Personal varchar(512)
	DECLARE @Celular varchar(64)
	DECLARE @Cod_TipoRelacion varchar(8)
	DECLARE @Fecha_Incorporacion datetime
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Id_ClienteContacto,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_ClienteContacto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_CONTACTO_I ' +
			  CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','') +''','END+
			  CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Nro_Documento,'''','') +''','END+
			  CASE WHEN pcp2.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp2.Cod_TipoDocumento,'''','''') +''','END+
			  CASE WHEN pcp2.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp2.Nro_Documento,'''','') +''','END+
			  CASE WHEN pcc.Ap_Paterno IS NULL THEN 'NULL,' ELSE '''' + REPLACE(CONVERT(varchar(max), pcc.Ap_Paterno),'''','') +''','END+
			  CASE WHEN pcc.Ap_Materno IS NULL THEN 'NULL,' ELSE '''' + REPLACE(CONVERT(varchar(max), pcc.Ap_Materno),'''','') +''','END+
			  CASE WHEN pcc.Nombres IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Nombres,'''','') +''','END+
			  CASE WHEN pcc.Cod_Telefono IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Cod_Telefono,'''','') +''','END+
			  CASE WHEN pcc.Nro_Telefono IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Nro_Telefono,'''','') +''','END+
			  CASE WHEN pcc.Anexo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Anexo,'''','') +''','END+
			  CASE WHEN pcc.Email_Empresarial IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Email_Empresarial,'''','') +''','END+
			  CASE WHEN pcc.Email_Personal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Email_Personal,'''','') +''','END+
			  CASE WHEN pcc.Celular IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Celular,'''','') +''','END+
			  CASE WHEN pcc.Cod_TipoRelacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcc.Cod_TipoRelacion,'''','') +''','END+
			  CASE WHEN pcc.Fecha_Incorporacion IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pcc.Fecha_Incorporacion,121) +''','END+
			  ''''+REPLACE(COALESCE(pcc.Cod_UsuarioAct,pcc.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pcc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pcc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp2 ON pcc.Id_ClienteContacto=pcp2.Id_ClienteProveedor
			  WHERE pcc.Id_ClienteProveedor=@Id_ClienteProveedor AND pcc.Id_ClienteContacto=@Id_ClienteContacto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Id_ClienteContacto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_ClienteContacto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Id_ClienteContacto,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_ClienteContacto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_CONTACTO_D ' +
			  CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','') +''','END+
			  CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Nro_Documento,'''','') +''','END+
			  CASE WHEN pcp2.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp2.Cod_TipoDocumento,'''','''') +''','END+
			  CASE WHEN pcp2.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp2.Nro_Documento,'''','') +''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pcc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pcc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp2 ON pcc.Id_ClienteContacto=pcp2.Id_ClienteProveedor
			  WHERE pcc.Id_ClienteProveedor=@Id_ClienteProveedor AND pcc.Id_ClienteContacto=@Id_ClienteContacto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Id_ClienteContacto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_ClienteContacto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Id_ClienteContacto,
			 i.Cod_TipoDocumento,
			 i.Nro_Documento,
			 i.Ap_Paterno,
			 i.Ap_Materno,
			 i.Nombres,
			 i.Cod_Telefono,
			 i.Nro_Telefono,
			 i.Anexo,
			 i.Email_Empresarial,
			 i.Email_Personal,
			 i.Celular,
			 i.Cod_TipoRelacion,
			 i.Fecha_Incorporacion,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Id_ClienteContacto,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Id_ClienteContacto,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Cod_Telefono,'|' ,
			 @Nro_Telefono,'|' ,
			 @Anexo,'|' ,
			 @Email_Empresarial,'|' ,
			 @Email_Personal,'|' ,
			 @Celular,'|' ,
			 @Cod_TipoRelacion,'|' ,
			 CONVERT(varchar,@Fecha_Incorporacion,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@Id_ClienteContacto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Id_ClienteContacto,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Id_ClienteContacto,
			 d.Cod_TipoDocumento,
			 d.Nro_Documento,
			 d.Ap_Paterno,
			 d.Ap_Materno,
			 d.Nombres,
			 d.Cod_Telefono,
			 d.Nro_Telefono,
			 d.Anexo,
			 d.Email_Empresarial,
			 d.Email_Personal,
			 d.Celular,
			 d.Cod_TipoRelacion,
			 d.Fecha_Incorporacion,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Id_ClienteContacto,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Id_ClienteContacto,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Cod_Telefono,'|' ,
			 @Nro_Telefono,'|' ,
			 @Anexo,'|' ,
			 @Email_Empresarial,'|' ,
			 @Email_Personal,'|' ,
			 @Celular,'|' ,
			 @Cod_TipoRelacion,'|' ,
			 CONVERT(varchar,@Fecha_Incorporacion,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@Id_ClienteContacto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Id_ClienteContacto,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CLIENTE_CUENTABANCARIA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_CUENTABANCARIA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_CUENTABANCARIA_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_CUENTABANCARIA_IUD
ON dbo.PRI_CLIENTE_CUENTABANCARIA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @NroCuenta_Bancaria varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_CUENTABANCARIA'
	--Variables de tabla secundarias
	DECLARE @Cod_EntidadFinanciera varchar(5)
	DECLARE @Cod_TipoCuentaBancaria varchar(8)
	DECLARE @Des_CuentaBancaria varchar(512)
	DECLARE @Flag_Principal bit
	DECLARE @Cuenta_Interbancaria varchar(64)
	DECLARE @Obs_CuentaBancaria varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.NroCuenta_Bancaria,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @NroCuenta_Bancaria,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_CUENTABANCARIA_I ' +
			  CASE WHEN  pccp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pccp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccp.Nro_Documento,'''','')+''','END+
			  CASE WHEN  pccc.NroCuenta_Bancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.NroCuenta_Bancaria,'''','')+''','END+
			  CASE WHEN  pccc.Cod_EntidadFinanciera IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.Cod_EntidadFinanciera,'''','')+''','END+
			  CASE WHEN  pccc.Cod_TipoCuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.Cod_TipoCuentaBancaria,'''','')+''','END+
			  CASE WHEN  pccc.Des_CuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.Des_CuentaBancaria,'''','')+''','END+
			  CONVERT(varchar(max),pccc.Flag_Principal)+','+
			  CASE WHEN  pccc.Cuenta_Interbancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.Cuenta_Interbancaria,'''','')+''','END+
			  CASE WHEN  pccc.Obs_CuentaBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.Obs_CuentaBancaria,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pccc.Cod_UsuarioAct,pccc.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pccc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pccp 
			  ON pccc.Id_ClienteProveedor = pccp.Id_ClienteProveedor
			  WHERE pccc.Id_ClienteProveedor=@Id_ClienteProveedor AND pccc.NroCuenta_Bancaria=@NroCuenta_Bancaria

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@NroCuenta_Bancaria), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @NroCuenta_Bancaria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.NroCuenta_Bancaria,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
		OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @NroCuenta_Bancaria,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_CUENTABANCARIA_D ' +
			  CASE WHEN  pccp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pccp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccp.Nro_Documento,'''','')+''','END+
			  CASE WHEN  pccc.NroCuenta_Bancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pccc.NroCuenta_Bancaria,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pccc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pccp 
			  ON pccc.Id_ClienteProveedor = pccp.Id_ClienteProveedor
			  WHERE pccc.Id_ClienteProveedor=@Id_ClienteProveedor AND pccc.NroCuenta_Bancaria=@NroCuenta_Bancaria

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@NroCuenta_Bancaria), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @NroCuenta_Bancaria,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.NroCuenta_Bancaria,
			 i.Cod_EntidadFinanciera,
			 i.Cod_TipoCuentaBancaria,
			 i.Des_CuentaBancaria,
			 i.Flag_Principal,
			 i.Cuenta_Interbancaria,
			 i.Obs_CuentaBancaria,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @NroCuenta_Bancaria,
			 @Cod_EntidadFinanciera,
			 @Cod_TipoCuentaBancaria,
			 @Des_CuentaBancaria,
			 @Flag_Principal,
			 @Cuenta_Interbancaria,
			 @Obs_CuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @NroCuenta_Bancaria,'|' ,
			 @Cod_EntidadFinanciera,'|' ,
			 @Cod_TipoCuentaBancaria,'|' ,
			 @Des_CuentaBancaria,'|' ,
			 @Flag_Principal,'|' ,
			 @Cuenta_Interbancaria,'|' ,
			 @Obs_CuentaBancaria,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@NroCuenta_Bancaria), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @NroCuenta_Bancaria,
			 @Cod_EntidadFinanciera,
			 @Cod_TipoCuentaBancaria,
			 @Des_CuentaBancaria,
			 @Flag_Principal,
			 @Cuenta_Interbancaria,
			 @Obs_CuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.NroCuenta_Bancaria,
			 d.Cod_EntidadFinanciera,
			 d.Cod_TipoCuentaBancaria,
			 d.Des_CuentaBancaria,
			 d.Flag_Principal,
			 d.Cuenta_Interbancaria,
			 d.Obs_CuentaBancaria,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @NroCuenta_Bancaria,
			 @Cod_EntidadFinanciera,
			 @Cod_TipoCuentaBancaria,
			 @Des_CuentaBancaria,
			 @Flag_Principal,
			 @Cuenta_Interbancaria,
			 @Obs_CuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @NroCuenta_Bancaria,'|' ,
			 @Cod_EntidadFinanciera,'|' ,
			 @Cod_TipoCuentaBancaria,'|' ,
			 @Des_CuentaBancaria,'|' ,
			 @Flag_Principal,'|' ,
			 @Cuenta_Interbancaria,'|' ,
			 @Obs_CuentaBancaria,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@NroCuenta_Bancaria), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @NroCuenta_Bancaria,
			 @Cod_EntidadFinanciera,
			 @Cod_TipoCuentaBancaria,
			 @Des_CuentaBancaria,
			 @Flag_Principal,
			 @Cuenta_Interbancaria,
			 @Obs_CuentaBancaria,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CLIENTE_PRODUCTO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PRODUCTO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PRODUCTO_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_PRODUCTO_IUD
ON dbo.PRI_CLIENTE_PRODUCTO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Id_Producto int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_PRODUCTO'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoDescuento varchar(8)
	DECLARE @Monto numeric(38,6)
	DECLARE @Obs_ClienteProducto varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Id_Producto,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PRODUCTO_I '+
			  CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+ 
			  CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+ 
			  CASE WHEN C.Cod_TipoDescuento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(C.Cod_TipoDescuento,'''','')+''','END+ 
			  CASE WHEN C.Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),C.Monto)+','END+ 
			  CASE WHEN C.Obs_ClienteProducto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(C.Obs_ClienteProducto,'''','')+''','END+ 
			  ''''+COALESCE(C.Cod_UsuarioAct,C.Cod_UsuarioReg)+ ''';' 
			  FROM            INSERTED  AS C INNER JOIN
									   PRI_PRODUCTOS AS P ON C.Id_Producto = P.Id_Producto INNER JOIN
									   PRI_CLIENTE_PROVEEDOR AS CP ON C.Id_ClienteProveedor = CP.Id_ClienteProveedor
			  WHERE C.Id_ClienteProveedor=@Id_ClienteProveedor AND C.Id_Producto=@Id_Producto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Id_Producto,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PRODUCTO_D '+
				  CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
				  CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+ 
				  CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+ 
				  ''''+'TRIGGER'+''',' +
				  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM            DELETED   AS C INNER JOIN
									   PRI_PRODUCTOS AS P ON C.Id_Producto = P.Id_Producto INNER JOIN
									   PRI_CLIENTE_PROVEEDOR AS CP ON C.Id_ClienteProveedor = CP.Id_ClienteProveedor
			  WHERE C.Id_ClienteProveedor=@Id_ClienteProveedor AND C.Id_Producto=@Id_Producto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Id_Producto,
			 i.Cod_TipoDescuento,
			 i.Monto,
			 i.Obs_ClienteProducto,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Id_Producto,
			 @Cod_TipoDescuento,
			 @Monto,
			 @Obs_ClienteProducto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_TipoDescuento,'|' ,
			 @Monto,'|' ,
			 @Obs_ClienteProducto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Id_Producto,
			 @Cod_TipoDescuento,
			 @Monto,
			 @Obs_ClienteProducto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Id_Producto,
			 d.Cod_TipoDescuento,
			 d.Monto,
			 d.Obs_ClienteProducto,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Id_Producto,
			 @Cod_TipoDescuento,
			 @Monto,
			 @Obs_ClienteProducto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Id_Producto,'|' ,
			 @Cod_TipoDescuento,'|' ,
			 @Monto,'|' ,
			 @Obs_ClienteProducto,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Id_Producto,
			 @Cod_TipoDescuento,
			 @Monto,
			 @Obs_ClienteProducto,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CLIENTE_PROVEEDOR
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PROVEEDOR_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
ON dbo.PRI_CLIENTE_PROVEEDOR
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @Id_ClienteProveedor int
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_PROVEEDOR'
	--Variables de tabla secundarias
	
	DECLARE @Cod_TipoDocumento varchar(3)
	DECLARE @Nro_Documento varchar(32)
	DECLARE @Cliente varchar(512)
	DECLARE @Ap_Paterno varchar(128)
	DECLARE @Ap_Materno varchar(128)
	DECLARE @Nombres varchar(128)
	DECLARE @Direccion varchar(512)
	DECLARE @Cod_EstadoCliente varchar(3)
	DECLARE @Cod_CondicionCliente varchar(3)
	DECLARE @Cod_TipoCliente varchar(3)
	DECLARE @RUC_Natural varchar(32)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Cod_Nacionalidad varchar(8)
	DECLARE @Fecha_Nacimiento datetime
	DECLARE @Cod_Sexo varchar(3)
	DECLARE @Email1 varchar(1024)
	DECLARE @Email2 varchar(1024)
	DECLARE @Telefono1 varchar(512)
	DECLARE @Telefono2 varchar(512)
	DECLARE @Fax varchar(512)
	DECLARE @PaginaWeb varchar(512)
	DECLARE @Cod_Ubigeo varchar(8)
	DECLARE @Cod_FormaPago varchar(3)
	DECLARE @Limite_Credito numeric(38,2)
	DECLARE @Obs_Cliente xml
	DECLARE @Num_DiaCredito int
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PROVEEDOR_I ' + 
			  CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
			  CASE WHEN Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cliente,'''','')+''','END+
			  CASE WHEN Ap_Paterno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Paterno,'''','')+''','END+
			  CASE WHEN Ap_Materno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Materno,'''','')+''','END+
			  CASE WHEN Nombres IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nombres,'''','')+''','END+
			  CASE WHEN Direccion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Direccion,'''','')+''','END+
			  CASE WHEN Cod_EstadoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_EstadoCliente,'''','')+''','END+
			  CASE WHEN Cod_CondicionCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_CondicionCliente,'''','')+''','END+
			  CASE WHEN Cod_TipoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoCliente,'''','')+''','END+
			  CASE WHEN RUC_Natural IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(RUC_Natural,'''','')+''','END+
			  'NULL,
			  NULL, '+ 
			  CASE WHEN Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoComprobante,'''','')+''','END+
			  CASE WHEN Cod_Nacionalidad IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Nacionalidad,'''','')+''','END+
			  CASE WHEN Fecha_Nacimiento IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Nacimiento,121)+''','END+
			  CASE WHEN Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Sexo,'''','')+''','END+
			  CASE WHEN Email1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email1,'''','')+''','END+
			  CASE WHEN Email2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email2,'''','')+''','END+
			  CASE WHEN Telefono1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono1,'''','')+''','END+
			  CASE WHEN Telefono2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono2,'''','')+''','END+
			  CASE WHEN Fax IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Fax,'''','')+''','END+
			  CASE WHEN PaginaWeb IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(PaginaWeb,'''','')+''','END+
			  CASE WHEN Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Ubigeo,'''','')+''','END+
			  CASE WHEN Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_FormaPago,'''','')+''','END+
			  CASE WHEN Limite_Credito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Limite_Credito)+','END+
			  CASE WHEN Obs_Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE( CONVERT(VARCHAR(MAX),Obs_Cliente),'''','')+''','END+
			  CASE WHEN Num_DiaCredito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Num_DiaCredito)+','END+
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','') +''';' 
			  FROM INSERTED 
			  WHERE Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		   @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PROVEEDOR_D ' + 
			  CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  
			  WHERE Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		   @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Cod_TipoDocumento,
			 i.Nro_Documento,
			 i.Cliente,
			 i.Ap_Paterno,
			 i.Ap_Materno,
			 i.Nombres,
			 i.Direccion,
			 i.Cod_EstadoCliente,
			 i.Cod_CondicionCliente,
			 i.Cod_TipoCliente,
			 i.RUC_Natural,
			 i.Cod_TipoComprobante,
			 i.Cod_Nacionalidad,
			 i.Fecha_Nacimiento,
			 i.Cod_Sexo,
			 i.Email1,
			 i.Email2,
			 i.Telefono1,
			 i.Telefono2,
			 i.Fax,
			 i.PaginaWeb,
			 i.Cod_Ubigeo,
			 i.Cod_FormaPago,
			 i.Limite_Credito,
			 i.Obs_Cliente,
			 i.Num_DiaCredito,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Cliente,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Direccion,'|' ,
			 @Cod_EstadoCliente,'|' ,
			 @Cod_CondicionCliente,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @RUC_Natural,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_Nacionalidad,'|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Sexo,'|' ,
			 @Email1,'|' ,
			 @Email2,'|' ,
			 @Telefono1,'|' ,
			 @Telefono2,'|' ,
			 @Fax,'|' ,
			 @PaginaWeb,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Limite_Credito,'|' ,
			 CONVERT(varchar(max),@Obs_Cliente),'|' ,
			 @Num_DiaCredito,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Cod_TipoDocumento,
			 d.Nro_Documento,
			 d.Cliente,
			 d.Ap_Paterno,
			 d.Ap_Materno,
			 d.Nombres,
			 d.Direccion,
			 d.Cod_EstadoCliente,
			 d.Cod_CondicionCliente,
			 d.Cod_TipoCliente,
			 d.RUC_Natural,
			 d.Cod_TipoComprobante,
			 d.Cod_Nacionalidad,
			 d.Fecha_Nacimiento,
			 d.Cod_Sexo,
			 d.Email1,
			 d.Email2,
			 d.Telefono1,
			 d.Telefono2,
			 d.Fax,
			 d.PaginaWeb,
			 d.Cod_Ubigeo,
			 d.Cod_FormaPago,
			 d.Limite_Credito,
			 d.Obs_Cliente,
			 d.Num_DiaCredito,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Cliente,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Direccion,'|' ,
			 @Cod_EstadoCliente,'|' ,
			 @Cod_CondicionCliente,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @RUC_Natural,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_Nacionalidad,'|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Sexo,'|' ,
			 @Email1,'|' ,
			 @Email2,'|' ,
			 @Telefono1,'|' ,
			 @Telefono2,'|' ,
			 @Fax,'|' ,
			 @PaginaWeb,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Limite_Credito,'|' ,
			 CONVERT(varchar(max),@Obs_Cliente),'|' ,
			 @Num_DiaCredito,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
END
GO

--PRI_CLIENTE_VEHICULOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_VEHICULOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_VEHICULOS_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_VEHICULOS_IUD
ON dbo.PRI_CLIENTE_VEHICULOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_Placa varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_VEHICULOS'
	--Variables de tabla secundarias
	DECLARE @Color varchar(128)
	DECLARE @Marca varchar(128)
	DECLARE @Modelo varchar(128)
	DECLARE @Propiestarios varchar(512)
	DECLARE @Sede varchar(128)
	DECLARE @Placa_Vigente varchar(64)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Cod_Placa,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Placa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_VEHICULOS_I '+
			  CASE WHEN P.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_TipoDocumento,'''','') +''',' END +
			  CASE WHEN P.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Nro_Documento,'''','') +''',' END +
			  ''''+REPLACE(V.Cod_Placa,'''','')+''','+
			  CASE WHEN V.Color IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Color,'''','') +''',' END +
			  CASE WHEN V.Marca IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Marca,'''','') +''',' END +
			  CASE WHEN V.Modelo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Modelo,'''','') +''',' END +
			  CASE WHEN V.Propiestarios IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Propiestarios,'''','') +''',' END +
			  CASE WHEN V.Sede IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Sede,'''','') +''',' END +
			  CASE WHEN V.Placa_Vigente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(V.Placa_Vigente,'''','') +''',' END +
			  ''''+REPLACE(COALESCE(V.Cod_UsuarioAct,V.Cod_UsuarioReg),'''','')+ ''';' 
			  FROM INSERTED  AS V INNER JOIN
				   PRI_CLIENTE_PROVEEDOR AS P ON V.Id_ClienteProveedor = P.Id_ClienteProveedor
			  WHERE V.Id_ClienteProveedor=@Id_ClienteProveedor AND V.Cod_Placa=@Cod_Placa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Placa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Placa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Cod_Placa,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Placa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_CLIENTE_VEHICULOS_D '+
				  CASE WHEN P.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_TipoDocumento,'''','') +''',' END +
				  CASE WHEN P.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Nro_Documento,'''','') +''',' END +
				  ''''+REPLACE(V.Cod_Placa,'''','')+''','+
				  ''''+'TRIGGER'+''',' +
				  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED AS V INNER JOIN
				   PRI_CLIENTE_PROVEEDOR AS P ON V.Id_ClienteProveedor = P.Id_ClienteProveedor
			  WHERE V.Id_ClienteProveedor=@Id_ClienteProveedor AND V.Cod_Placa=@Cod_Placa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Placa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Placa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Cod_Placa,
			 i.Color,
			 i.Marca,
			 i.Modelo,
			 i.Propiestarios,
			 i.Sede,
			 i.Placa_Vigente,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Placa,
			 @Color,
			 @Marca,
			 @Modelo,
			 @Propiestarios,
			 @Sede,
			 @Placa_Vigente,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Placa,'|' ,
			 @Color,'|' ,
			 @Marca,'|' ,
			 @Modelo,'|' ,
			 @Propiestarios,'|' ,
			 @Sede,'|' ,
			 @Placa_Vigente,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@Cod_Placa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Placa,
			 @Color,
			 @Marca,
			 @Modelo,
			 @Propiestarios,
			 @Sede,
			 @Placa_Vigente,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Cod_Placa,
			 d.Color,
			 d.Marca,
			 d.Modelo,
			 d.Propiestarios,
			 d.Sede,
			 d.Placa_Vigente,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Placa,
			 @Color,
			 @Marca,
			 @Modelo,
			 @Propiestarios,
			 @Sede,
			 @Placa_Vigente,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Placa,'|' ,
			 @Color,'|' ,
			 @Marca,'|' ,
			 @Modelo,'|' ,
			 @Propiestarios,'|' ,
			 @Sede,'|' ,
			 @Placa_Vigente,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Placa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Placa,
			 @Color,
			 @Marca,
			 @Modelo,
			 @Propiestarios,
			 @Sede,
			 @Placa_Vigente,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CLIENTE_VISITAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_VISITAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_VISITAS_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_VISITAS_IUD
ON dbo.PRI_CLIENTE_VISITAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_ClienteVisita varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_VISITAS'
	--Variables de tabla secundarias
	DECLARE @Cod_UsuarioVendedor varchar(8)
	DECLARE @Id_ClienteProveedor int
	DECLARE @Ruta varchar(64)
	DECLARE @Cod_TipoVisita varchar(5)
	DECLARE @Cod_Resultado varchar(5)
	DECLARE @Fecha_HoraVisita datetime
	DECLARE @Comentarios varchar(1024)
	DECLARE @Flag_Compromiso bit
	DECLARE @Fecha_HoraCompromiso datetime
	DECLARE @Cod_UsuarioResponsable varchar(8)
	DECLARE @Des_Compromiso varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_ClienteVisita,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_ClienteVisita,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_CLIENTE_VISITAS_I ' +
			  ''''+REPLACE(pcv.Cod_ClienteVisita,'''','') +''','+
			  CASE WHEN  pcv.Cod_UsuarioVendedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcv.Cod_UsuarioVendedor,'''','')+''','END+
			  CASE WHEN  pcv.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Cod_TipoDocumento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pcv.Id_ClienteProveedor),''),'''','')+''','END+
			  CASE WHEN  pcv.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Nro_Documento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pcv.Id_ClienteProveedor),''),'''','')+''','END+
			  CASE WHEN  pcv.Ruta IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcv.Ruta,'''','')+''','END+
			  CASE WHEN  pcv.Cod_TipoVisita IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcv.Cod_TipoVisita,'''','')+''','END+
			  CASE WHEN  pcv.Cod_Resultado IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcv.Cod_Resultado,'''','')+''','END+
			  CASE WHEN  pcv.Fecha_HoraVisita IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraVisita,121)+''','END+
			  CASE WHEN  pcv.Comentarios IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcv.Comentarios,'''','')+''','END+
			  CONVERT(varchar(max),pcv.Flag_Compromiso)+','+
			  CASE WHEN  pcv.Fecha_HoraCompromiso IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraCompromiso,121)+''','END+
			  CASE WHEN  pcv.Cod_UsuarioResponsable IS NULL  THEN 'NULL,'    ELSE ''''+  REPLACE(pcv.Cod_UsuarioResponsable,'''','')+''','END+
			  CASE WHEN  pcv.Des_Compromiso IS NULL  THEN 'NULL,'    ELSE ''''+  REPLACE(pcv.Des_Compromiso,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pcv.Cod_UsuarioAct,pcv.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED  pcv 
			  WHERE pcv.Cod_ClienteVisita=@Cod_ClienteVisita

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_ClienteVisita), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_ClienteVisita,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_ClienteVisita,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_ClienteVisita,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_CLIENTE_VISITAS_D ' +
			  ''''+REPLACE(pcv.Cod_ClienteVisita,'''','') +''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  pcv 
			  WHERE pcv.Cod_ClienteVisita=@Cod_ClienteVisita

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_ClienteVisita), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_ClienteVisita,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_ClienteVisita,
			 i.Cod_UsuarioVendedor,
			 i.Id_ClienteProveedor,
			 i.Ruta,
			 i.Cod_TipoVisita,
			 i.Cod_Resultado,
			 i.Fecha_HoraVisita,
			 i.Comentarios,
			 i.Flag_Compromiso,
			 i.Fecha_HoraCompromiso,
			 i.Cod_UsuarioResponsable,
			 i.Des_Compromiso,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_ClienteVisita,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Ruta,'|' ,
			 @Cod_TipoVisita,'|' ,
			 @Cod_Resultado,'|' ,
			 CONVERT(varchar,@Fecha_HoraVisita,121), '|' ,
			 @Comentarios,'|' ,
			 @Flag_Compromiso,'|' ,
			 CONVERT(varchar,@Fecha_HoraCompromiso,121), '|' ,
			 @Cod_UsuarioResponsable,'|' ,
			 @Des_Compromiso,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_ClienteVisita), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_ClienteVisita,
			 d.Cod_UsuarioVendedor,
			 d.Id_ClienteProveedor,
			 d.Ruta,
			 d.Cod_TipoVisita,
			 d.Cod_Resultado,
			 d.Fecha_HoraVisita,
			 d.Comentarios,
			 d.Flag_Compromiso,
			 d.Fecha_HoraCompromiso,
			 d.Cod_UsuarioResponsable,
			 d.Des_Compromiso,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_ClienteVisita,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Ruta,'|' ,
			 @Cod_TipoVisita,'|' ,
			 @Cod_Resultado,'|' ,
			 CONVERT(varchar,@Fecha_HoraVisita,121), '|' ,
			 @Comentarios,'|' ,
			 @Flag_Compromiso,'|' ,
			 CONVERT(varchar,@Fecha_HoraCompromiso,121), '|' ,
			 @Cod_UsuarioResponsable,'|' ,
			 @Des_Compromiso,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_ClienteVisita), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_CUENTA_CONTABLE
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CUENTA_CONTABLE_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CUENTA_CONTABLE_IUD
GO

CREATE TRIGGER UTR_PRI_CUENTA_CONTABLE_IUD
ON dbo.PRI_CUENTA_CONTABLE
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_CuentaContable varchar(16)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_CUENTA_CONTABLE'
	--Variables de tabla secundarias
	DECLARE @Des_CuentaContable varchar(128)
	DECLARE @Tipo_Cuenta varchar(32)
	DECLARE @Cod_Moneda varchar(5)
	DECLARE @Flag_CuentaAnalitica bit
	DECLARE @Flag_CentroCostos bit
	DECLARE @Flag_CuentaBancaria bit
	DECLARE @Cod_EntidadBancaria varchar(5)
	DECLARE @Numero_Cuenta varchar(64)
	DECLARE @Clase_Cuenta varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_CuentaContable,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaContable,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CUENTA_CONTABLE_I ' +
			  ''''+REPLACE(pcc.Cod_CuentaContable,'''','') +''','+
			  CASE WHEN  pcc.Des_CuentaContable IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Des_CuentaContable,'''','')+''','END+
			  CASE WHEN  pcc.Tipo_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Tipo_Cuenta,'''','')+''','END+
			  CASE WHEN  pcc.Cod_Moneda IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Cod_Moneda,'''','')+''','END+
			  CONVERT(varchar(max),pcc.Flag_CuentaAnalitica)+','+
			  CONVERT(varchar(max),pcc.Flag_CentroCostos)+','+
			  CONVERT(varchar(max),pcc.Flag_CuentaBancaria)+','+
			  CASE WHEN  pcc.Cod_EntidadBancaria IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Cod_EntidadBancaria,'''','')+''','END+
			  CASE WHEN  pcc.Numero_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Numero_Cuenta,'''','')+''','END+
			  CASE WHEN  pcc.Clase_Cuenta IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcc.Clase_Cuenta,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pcc.Cod_UsuarioAct,pcc.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pcc
			  WHERE pcc.Cod_CuentaContable=@Cod_CuentaContable
		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_CuentaContable), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaContable,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_CuentaContable,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaContable,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CUENTA_CONTABLE_D ' +
			  ''''+REPLACE(pcc.Cod_CuentaContable,'''','') +''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pcc
			  WHERE pcc.Cod_CuentaContable=@Cod_CuentaContable
		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_CuentaContable), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_CuentaContable,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_CuentaContable,
			 i.Des_CuentaContable,
			 i.Tipo_Cuenta,
			 i.Cod_Moneda,
			 i.Flag_CuentaAnalitica,
			 i.Flag_CentroCostos,
			 i.Flag_CuentaBancaria,
			 i.Cod_EntidadBancaria,
			 i.Numero_Cuenta,
			 i.Clase_Cuenta,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_CuentaContable,'|' ,
			 @Des_CuentaContable,'|' ,
			 @Tipo_Cuenta,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_CuentaAnalitica,'|' ,
			 @Flag_CentroCostos,'|' ,
			 @Flag_CuentaBancaria,'|' ,
			 @Cod_EntidadBancaria,'|' ,
			 @Numero_Cuenta,'|' ,
			 @Clase_Cuenta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_CuentaContable), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_CuentaContable,
			 d.Des_CuentaContable,
			 d.Tipo_Cuenta,
			 d.Cod_Moneda,
			 d.Flag_CuentaAnalitica,
			 d.Flag_CentroCostos,
			 d.Flag_CuentaBancaria,
			 d.Cod_EntidadBancaria,
			 d.Numero_Cuenta,
			 d.Clase_Cuenta,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_CuentaContable,'|' ,
			 @Des_CuentaContable,'|' ,
			 @Tipo_Cuenta,'|' ,
			 @Cod_Moneda,'|' ,
			 @Flag_CuentaAnalitica,'|' ,
			 @Flag_CentroCostos,'|' ,
			 @Flag_CuentaBancaria,'|' ,
			 @Cod_EntidadBancaria,'|' ,
			 @Numero_Cuenta,'|' ,
			 @Clase_Cuenta,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_CuentaContable), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_DESCUENTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_DESCUENTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_DESCUENTOS_IUD
GO

CREATE TRIGGER UTR_PRI_DESCUENTOS_IUD
ON dbo.PRI_DESCUENTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Descuento int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_DESCUENTOS'
	--Variables de tabla secundarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_TipoDescuento varchar(32)
	DECLARE @Aplica varchar(64)
	DECLARE @Cod_Aplica varchar(32)
	DECLARE @Cod_TipoCliente varchar(32)
	DECLARE @Cod_TipoPrecio varchar(5)
	DECLARE @Monto_Precio numeric(38,6)
	DECLARE @Fecha_Inicia datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Obs_Descuento varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Descuento,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Descuento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_DESCUENTOS_I ' +
			CASE WHEN  pd.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Cod_TipoDocumento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pd.Id_ClienteProveedor),''),'''','')+''','END+
			CASE WHEN  pd.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Nro_Documento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pd.Id_ClienteProveedor),''),'''','')+''','END+
			CASE WHEN  pd.Cod_TipoDescuento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Cod_TipoDescuento,'''','')+''','END+
			CASE WHEN  pd.Aplica IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Aplica,'''','')+''','END+
			CASE WHEN  pd.Cod_Aplica IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Cod_Aplica,'''','')+''','END+
			CASE WHEN  pd.Cod_TipoCliente IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Cod_TipoCliente,'''','')+''','END+
			CASE WHEN  pd.Cod_TipoPrecio IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Cod_TipoPrecio,'''','')+''','END+
			CASE WHEN  pd.Monto_Precio IS NULL  THEN 'NULL,'    ELSE  CONVERT(varchar(max),pd.Monto_Precio)+','END+
			CASE WHEN  pd.Fecha_Inicia IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Inicia,121)+''','END+
			CASE WHEN  pd.Fecha_Fin IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Fin,121)+''','END+
			CASE WHEN  pd.Obs_Descuento IS NULL  THEN 'NULL,'    ELSE '''' +REPLACE(pd.Obs_Descuento,'''','')+''','END+
			''''+REPLACE(COALESCE(pd.Cod_UsuarioAct,pd.Cod_UsuarioReg),'''','')   +''';' 
			FROM INSERTED  pd 
			WHERE pd.Id_Descuento=@Id_Descuento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Descuento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Descuento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Descuento,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Descuento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_DESCUENTOS_D ' +
			CASE WHEN  pd.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Cod_TipoDocumento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pd.Id_ClienteProveedor),''),'''','')+''','END+
			CASE WHEN  pd.Id_ClienteProveedor IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Nro_Documento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=pd.Id_ClienteProveedor),''),'''','')+''','END+
			CASE WHEN  pd.Cod_TipoDescuento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pd.Cod_TipoDescuento,'''','')+''','END+
			''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM DELETED  pd 
			WHERE pd.Id_Descuento=@Id_Descuento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Descuento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Descuento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Descuento,
			 i.Id_ClienteProveedor,
			 i.Cod_TipoDescuento,
			 i.Aplica,
			 i.Cod_Aplica,
			 i.Cod_TipoCliente,
			 i.Cod_TipoPrecio,
			 i.Monto_Precio,
			 i.Fecha_Inicia,
			 i.Fecha_Fin,
			 i.Obs_Descuento,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Descuento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Descuento,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDescuento,'|' ,
			 @Aplica,'|' ,
			 @Cod_Aplica,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @Cod_TipoPrecio,'|' ,
			 @Monto_Precio,'|' ,
			 CONVERT(varchar,@Fecha_Inicia,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Obs_Descuento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Descuento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Descuento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Descuento,
			 d.Id_ClienteProveedor,
			 d.Cod_TipoDescuento,
			 d.Aplica,
			 d.Cod_Aplica,
			 d.Cod_TipoCliente,
			 d.Cod_TipoPrecio,
			 d.Monto_Precio,
			 d.Fecha_Inicia,
			 d.Fecha_Fin,
			 d.Obs_Descuento,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Descuento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Descuento,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDescuento,'|' ,
			 @Aplica,'|' ,
			 @Cod_Aplica,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @Cod_TipoPrecio,'|' ,
			 @Monto_Precio,'|' ,
			 CONVERT(varchar,@Fecha_Inicia,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Obs_Descuento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Descuento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Descuento,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_EMPRESA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_EMPRESA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_EMPRESA_IUD
GO

CREATE TRIGGER UTR_PRI_EMPRESA_IUD
ON dbo.PRI_EMPRESA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Empresa varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_EMPRESA'
	--Variables de tabla secundarias
	DECLARE @RUC varchar(32)
	DECLARE @Nom_Comercial varchar(1024)
	DECLARE @RazonSocial varchar(1024)
	DECLARE @Direccion varchar(1024)
	DECLARE @Telefonos varchar(512)
	DECLARE @Web varchar(512)
	DECLARE @Flag_ExoneradoImpuesto bit
	DECLARE @Des_Impuesto varchar(16)
	DECLARE @Por_Impuesto numeric(5,2)
	DECLARE @EstructuraContable varchar(32)
	DECLARE @Version varchar(32)
	DECLARE @Cod_Ubigeo varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Empresa,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Empresa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_EMPRESA_I ' +
			  ''''+ REPLACE(pe.Cod_Empresa,'''','') +''','+
			  CASE WHEN  pe.RUC IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.RUC,'''','')+''','END+
			  CASE WHEN  pe.Nom_Comercial IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Nom_Comercial,'''','')+''','END+
			  CASE WHEN  pe.RazonSocial IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.RazonSocial,'''','')+''','END+
			  CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Direccion,'''','')+''','END+
			  CASE WHEN  pe.Telefonos IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Telefonos,'''','')+''','END+
			  CASE WHEN  pe.Web IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Web,'''','')+''','END+
			  'NULL,'+
			  'NULL,'+
			  convert(varchar(max),pe.Flag_ExoneradoImpuesto)+','+
			  CASE WHEN  pe.Des_Impuesto IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Des_Impuesto,'''','')+''','END+
			  CASE WHEN  pe.Por_Impuesto IS NULL  THEN 'NULL,'    ELSE +CONVERT(varchar(max),pe.Por_Impuesto)+','END+
			  CASE WHEN  pe.EstructuraContable IS NULL  THEN 'NULL,'    ELSE '''' +REPLACE(pe.EstructuraContable,'''','')+''','END+
			  CASE WHEN  pe.Version IS NULL  THEN 'NULL,'    ELSE '''' +REPLACE(pe.Version,'''','')+''','END+
			  CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE '''' +REPLACE(pe.Cod_Ubigeo,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pe
			  WHERE pe.Cod_Empresa=@Cod_Empresa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Empresa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Empresa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Empresa,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Empresa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_EMPRESA_D ' +
			  ''''+ REPLACE(pe.Cod_Empresa,'''','') +''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pe
			  WHERE pe.Cod_Empresa=@Cod_Empresa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Empresa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Empresa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Empresa,
			 i.RUC,
			 i.Nom_Comercial,
			 i.RazonSocial,
			 i.Direccion,
			 i.Telefonos,
			 i.Web,
			 i.Flag_ExoneradoImpuesto,
			 i.Des_Impuesto,
			 i.Por_Impuesto,
			 i.EstructuraContable,
			 i.Version,
			 i.Cod_Ubigeo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Empresa,
			 @RUC,
			 @Nom_Comercial,
			 @RazonSocial,
			 @Direccion,
			 @Telefonos,
			 @Web,
			 @Flag_ExoneradoImpuesto,
			 @Des_Impuesto,
			 @Por_Impuesto,
			 @EstructuraContable,
			 @Version,
			 @Cod_Ubigeo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Empresa,'|' ,
			 @RUC,'|' ,
			 @Nom_Comercial,'|' ,
			 @RazonSocial,'|' ,
			 @Direccion,'|' ,
			 @Telefonos,'|' ,
			 @Web,'|' ,
			 @Flag_ExoneradoImpuesto,'|' ,
			 @Des_Impuesto,'|' ,
			 @Por_Impuesto,'|' ,
			 @EstructuraContable,'|' ,
			 @Version,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Empresa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Empresa,
			 @RUC,
			 @Nom_Comercial,
			 @RazonSocial,
			 @Direccion,
			 @Telefonos,
			 @Web,
			 @Flag_ExoneradoImpuesto,
			 @Des_Impuesto,
			 @Por_Impuesto,
			 @EstructuraContable,
			 @Version,
			 @Cod_Ubigeo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Empresa,
			 d.RUC,
			 d.Nom_Comercial,
			 d.RazonSocial,
			 d.Direccion,
			 d.Telefonos,
			 d.Web,
			 d.Flag_ExoneradoImpuesto,
			 d.Des_Impuesto,
			 d.Por_Impuesto,
			 d.EstructuraContable,
			 d.Version,
			 d.Cod_Ubigeo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Empresa,
			 @RUC,
			 @Nom_Comercial,
			 @RazonSocial,
			 @Direccion,
			 @Telefonos,
			 @Web,
			 @Flag_ExoneradoImpuesto,
			 @Des_Impuesto,
			 @Por_Impuesto,
			 @EstructuraContable,
			 @Version,
			 @Cod_Ubigeo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Empresa,'|' ,
			 @RUC,'|' ,
			 @Nom_Comercial,'|' ,
			 @RazonSocial,'|' ,
			 @Direccion,'|' ,
			 @Telefonos,'|' ,
			 @Web,'|' ,
			 @Flag_ExoneradoImpuesto,'|' ,
			 @Des_Impuesto,'|' ,
			 @Por_Impuesto,'|' ,
			 @EstructuraContable,'|' ,
			 @Version,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Empresa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Empresa,
			 @RUC,
			 @Nom_Comercial,
			 @RazonSocial,
			 @Direccion,
			 @Telefonos,
			 @Web,
			 @Flag_ExoneradoImpuesto,
			 @Des_Impuesto,
			 @Por_Impuesto,
			 @EstructuraContable,
			 @Version,
			 @Cod_Ubigeo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_ESTABLECIMIENTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_ESTABLECIMIENTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_ESTABLECIMIENTOS_IUD
GO

CREATE TRIGGER UTR_PRI_ESTABLECIMIENTOS_IUD
ON dbo.PRI_ESTABLECIMIENTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Establecimientos varchar(32)
	DECLARE @Id_ClienteProveedor int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_ESTABLECIMIENTOS'
	--Variables de tabla secundarias
	DECLARE @Des_Establecimiento varchar(512)
	DECLARE @Cod_TipoEstablecimiento varchar(5)
	DECLARE @Direccion varchar(1024)
	DECLARE @Telefono varchar(1024)
	DECLARE @Obs_Establecimiento varchar(1024)
	DECLARE @Cod_Ubigeo varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_ESTABLECIMIENTOS_I ' +
			  ''''+ REPLACE(pe.Cod_Establecimientos,'''','') +''','+
			  CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  CASE WHEN  pe.Des_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Des_Establecimiento,'''','')+''','END+
			  CASE WHEN  pe.Cod_TipoEstablecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Cod_TipoEstablecimiento,'''','')+''','END+
			  CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Direccion,'''','')+''','END+
			  CASE WHEN  pe.Telefono IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Telefono,'''','')+''','END+
			  CASE WHEN  pe.Obs_Establecimiento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Obs_Establecimiento,'''','')+''','END+
			  CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pe.Cod_Ubigeo,'''','')+''','END+
			  ''''+REPLACE(COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pe INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pe.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  WHERE pe.Cod_Establecimientos=@Cod_Establecimientos AND pe.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Establecimientos,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Establecimientos,
		    d.Id_ClienteProveedor,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Establecimientos,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_ESTABLECIMIENTOS_D ' +
			  ''''+ REPLACE(pe.Cod_Establecimientos,'''','') +''','+
			  CASE WHEN  pcp.Cod_TipoDocumento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN  pcp.Nro_Documento IS NULL  THEN 'NULL,'    ELSE ''''+ REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pe INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pe.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  WHERE pe.Cod_Establecimientos=@Cod_Establecimientos AND pe.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Establecimientos,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
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

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Establecimientos,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Des_Establecimiento,'|' ,
			 @Cod_TipoEstablecimiento,'|' ,
			 @Direccion,'|' ,
			 @Telefono,'|' ,
			 @Obs_Establecimiento,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Establecimientos,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Establecimientos,
			 d.Id_ClienteProveedor,
			 d.Des_Establecimiento,
			 d.Cod_TipoEstablecimiento,
			 d.Direccion,
			 d.Telefono,
			 d.Obs_Establecimiento,
			 d.Cod_Ubigeo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Establecimientos,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Des_Establecimiento,'|' ,
			 @Cod_TipoEstablecimiento,'|' ,
			 @Direccion,'|' ,
			 @Telefono,'|' ,
			 @Obs_Establecimiento,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Establecimientos,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

END
GO

--PRI_LICITACIONES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_LICITACIONES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_LICITACIONES_IUD
GO

CREATE TRIGGER UTR_PRI_LICITACIONES_IUD
ON dbo.PRI_LICITACIONES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_Licitacion varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_LICITACIONES'
	--Variables de tabla secundarias
	DECLARE @Des_Licitacion varchar(512)
	DECLARE @Cod_TipoLicitacion varchar(5)
	DECLARE @Nro_Licitacion varchar(16)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Facturacion datetime
	DECLARE @Flag_AlFinal bit
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Cod_Licitacion,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_LICITACIONES_I ' + 
			  CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+ 
			  ''''+REPLACE(L.Cod_Licitacion,'''','')+''','+ 
			  CASE WHEN L.Des_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(L.Des_Licitacion,'''','')+''','END+
			  CASE WHEN L.Cod_TipoLicitacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(L.Cod_Licitacion,'''','')+''','END+
			  CASE WHEN L.Nro_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(L.Nro_Licitacion,'''','')+''','END+
			  CASE WHEN L.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Inicio,121)+''','END+ 
			  CASE WHEN L.Fecha_Facturacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Facturacion,121)+''','END+ 
			  CONVERT(VARCHAR(MAX),L.Flag_AlFinal)+','+ 
			  CASE WHEN L.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(L.Cod_TipoComprobante,'''','')+''','END+
			  ''''+REPLACE(COALESCE(L.Cod_UsuarioAct,L.Cod_UsuarioReg),'''','')+''';' 
			  FROM            INSERTED AS L INNER JOIN
									   PRI_CLIENTE_PROVEEDOR AS CP ON L.Id_ClienteProveedor = CP.Id_ClienteProveedor
			  WHERE L.Id_ClienteProveedor=@Id_ClienteProveedor AND L.Cod_Licitacion=@Cod_Licitacion

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Cod_Licitacion,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_LICITACIONES_D ' + 
			  CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+ 
			  ''''+REPLACE(L.Cod_Licitacion,'''','')+''','+ 
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM  DELETED L INNER JOIN
									   PRI_CLIENTE_PROVEEDOR AS CP ON L.Id_ClienteProveedor = CP.Id_ClienteProveedor
			  WHERE L.Id_ClienteProveedor=@Id_ClienteProveedor AND L.Cod_Licitacion=@Cod_Licitacion

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Cod_Licitacion,
			 i.Des_Licitacion,
			 i.Cod_TipoLicitacion,
			 i.Nro_Licitacion,
			 i.Fecha_Inicio,
			 i.Fecha_Facturacion,
			 i.Flag_AlFinal,
			 i.Cod_TipoComprobante,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Des_Licitacion,
			 @Cod_TipoLicitacion,
			 @Nro_Licitacion,
			 @Fecha_Inicio,
			 @Fecha_Facturacion,
			 @Flag_AlFinal,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Des_Licitacion,'|' ,
			 @Cod_TipoLicitacion,'|' ,
			 @Nro_Licitacion,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Facturacion,121), '|' ,
			 @Flag_AlFinal,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Des_Licitacion,
			 @Cod_TipoLicitacion,
			 @Nro_Licitacion,
			 @Fecha_Inicio,
			 @Fecha_Facturacion,
			 @Flag_AlFinal,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Cod_Licitacion,
			 d.Des_Licitacion,
			 d.Cod_TipoLicitacion,
			 d.Nro_Licitacion,
			 d.Fecha_Inicio,
			 d.Fecha_Facturacion,
			 d.Flag_AlFinal,
			 d.Cod_TipoComprobante,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Des_Licitacion,
			 @Cod_TipoLicitacion,
			 @Nro_Licitacion,
			 @Fecha_Inicio,
			 @Fecha_Facturacion,
			 @Flag_AlFinal,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Des_Licitacion,'|' ,
			 @Cod_TipoLicitacion,'|' ,
			 @Nro_Licitacion,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Facturacion,121), '|' ,
			 @Flag_AlFinal,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Des_Licitacion,
			 @Cod_TipoLicitacion,
			 @Nro_Licitacion,
			 @Fecha_Inicio,
			 @Fecha_Facturacion,
			 @Flag_AlFinal,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_LICITACIONES_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_LICITACIONES_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_LICITACIONES_D_IUD
GO

CREATE TRIGGER UTR_PRI_LICITACIONES_D_IUD
ON dbo.PRI_LICITACIONES_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_Licitacion varchar(32)
	DECLARE @Nro_Detalle int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_LICITACIONES_D'
	--Variables de tabla secundarias
	DECLARE @Id_Producto int
	DECLARE @Cantidad numeric(38,2)
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Descripcion varchar(512)
	DECLARE @Precio_Unitario numeric(38,6)
	DECLARE @Por_Descuento numeric(5,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Cod_Licitacion,
		    i.Nro_Detalle,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Nro_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_LICITACIONES_D_I ' + 
			CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
			CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+
			''''+REPLACE(LD.Cod_Licitacion,'''','')+''','+ 
			CONVERT(VARCHAR(MAX),LD.Nro_Detalle)+','+
			CASE WHEN LD.Id_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pp.Cod_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Id_Producto=LD.Id_Producto),''),'''','')+''','END+ 
			CASE WHEN LD.Cantidad IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Cantidad)+','END+ 
			CASE WHEN LD.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(LD.Cod_UnidadMedida,'''','')+''','END+
			CASE WHEN LD.Descripcion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(LD.Descripcion,'''','')+''','END+
			CASE WHEN LD.Precio_Unitario IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Precio_Unitario)+','END+ 
			CASE WHEN LD.Por_Descuento IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),LD.Por_Descuento)+','END+ 
			''''+REPLACE(COALESCE(LD.Cod_UsuarioAct,LD.Cod_UsuarioReg),'''','')+''';' 
			FROM            INSERTED AS LD INNER JOIN
			PRI_CLIENTE_PROVEEDOR AS CP ON LD.Id_ClienteProveedor = CP.Id_ClienteProveedor 
			WHERE LD.Id_ClienteProveedor=@Id_ClienteProveedor AND LD.Cod_Licitacion=@Cod_Licitacion
			AND LD.Nro_Detalle =@Nro_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion,'|',@Nro_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Nro_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_ClienteProveedor,
		    d.Cod_Licitacion,
		    d.Nro_Detalle,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Nro_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_LICITACIONES_D_D ' + 
			CASE WHEN CP.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_TipoDocumento,'''','')+''','END+
			CASE WHEN CP.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Nro_Documento,'''','')+''','END+
			''''+REPLACE(LD.Cod_Licitacion,'''','')+''','+ 
			CONVERT(VARCHAR(MAX),LD.Nro_Detalle)+','+
			''''+'TRIGGER'+''',' +
			''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM  DELETED LD INNER JOIN
			PRI_CLIENTE_PROVEEDOR AS CP ON LD.Id_ClienteProveedor = CP.Id_ClienteProveedor 
			WHERE LD.Id_ClienteProveedor=@Id_ClienteProveedor AND LD.Cod_Licitacion=@Cod_Licitacion
			AND LD.Nro_Detalle =@Nro_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion,'|',@Nro_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Cod_Licitacion,
		    @Nro_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_ClienteProveedor,
			 i.Cod_Licitacion,
			 i.Nro_Detalle,
			 i.Id_Producto,
			 i.Cantidad,
			 i.Cod_UnidadMedida,
			 i.Descripcion,
			 i.Precio_Unitario,
			 i.Por_Descuento,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @Id_Producto,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Descripcion,
			 @Precio_Unitario,
			 @Por_Descuento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Nro_Detalle,'|' ,
			 @Id_Producto,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Descripcion,'|' ,
			 @Precio_Unitario,'|' ,
			 @Por_Descuento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion,'|',@Nro_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @Id_Producto,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Descripcion,
			 @Precio_Unitario,
			 @Por_Descuento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Cod_Licitacion,
			 d.Nro_Detalle,
			 d.Id_Producto,
			 d.Cantidad,
			 d.Cod_UnidadMedida,
			 d.Descripcion,
			 d.Precio_Unitario,
			 d.Por_Descuento,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @Id_Producto,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Descripcion,
			 @Precio_Unitario,
			 @Por_Descuento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Nro_Detalle,'|' ,
			 @Id_Producto,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Descripcion,'|' ,
			 @Precio_Unitario,'|' ,
			 @Por_Descuento,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_ClienteProveedor,'|',@Cod_Licitacion,'|',@Nro_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @Id_Producto,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Descripcion,
			 @Precio_Unitario,
			 @Por_Descuento,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_LICITACIONES_M
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_LICITACIONES_M_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_LICITACIONES_M_IUD
GO

CREATE TRIGGER UTR_PRI_LICITACIONES_M_IUD
ON dbo.PRI_LICITACIONES_M
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Movimiento int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_LICITACIONES_M'
	--Variables de tabla secundarias
	DECLARE @Id_ClienteProveedor int
	DECLARE @Cod_Licitacion varchar(32)
	DECLARE @Nro_Detalle int
	DECLARE @id_ComprobantePago int
	DECLARE @Flag_Cancelado bit
	DECLARE @Obs_LicitacionesM varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Movimiento,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_LICITACIONES_M_I '+ 
			CASE WHEN M.Id_ClienteProveedor IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Cod_TipoDocumento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=M.Id_ClienteProveedor),''),'''','') +''',' END +
			CASE WHEN M.Id_ClienteProveedor IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Nro_Documento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=M.Id_ClienteProveedor),''),'''','') +''',' END +
			CASE WHEN M.Cod_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_Licitacion,'''','') +''',' END +
			CASE WHEN M.Nro_Detalle IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),M.Nro_Detalle)+','END+ 
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +	
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Cod_TipoDoc FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Doc_Cliente FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CONVERT(VARCHAR(MAX),M.Flag_Cancelado)	+','+ 
			CASE WHEN M.Obs_LicitacionesM IS NULL THEN 'NULL,' ELSE ''''+REPLACE(M.Obs_LicitacionesM,'''','')+''',' END +	
			''''+REPLACE(COALESCE(M.Cod_UsuarioAct,M.Cod_UsuarioReg),'''','')+ ''';'
			FROM  INSERTED AS M
			WHERE M.Id_Movimiento=@Id_Movimiento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Movimiento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Movimiento,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_PRI_LICITACIONES_M_D '+ 
			CASE WHEN M.Id_ClienteProveedor IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Cod_TipoDocumento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=M.Id_ClienteProveedor),''),'''','') +''',' END +
			CASE WHEN M.Id_ClienteProveedor IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(ISNULL((SELECT pcp.Nro_Documento FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Id_ClienteProveedor=M.Id_ClienteProveedor),''),'''','') +''',' END +
			CASE WHEN M.Cod_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(M.Cod_Licitacion,'''','') +''',' END +
			CASE WHEN M.Nro_Detalle IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),M.Nro_Detalle)+','END+ 
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +
			CASE WHEN M.id_ComprobantePago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ISNULL((SELECT ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=M.id_ComprobantePago),''),'''','')+''',' END +	
			''''+'TRIGGER'+''',' +
			''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			FROM DELETED  M
			WHERE M.Id_Movimiento=@Id_Movimiento

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Movimiento), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Movimiento,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Movimiento,
			 i.Id_ClienteProveedor,
			 i.Cod_Licitacion,
			 i.Nro_Detalle,
			 i.id_ComprobantePago,
			 i.Flag_Cancelado,
			 i.Obs_LicitacionesM,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Movimiento,
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @id_ComprobantePago,
			 @Flag_Cancelado,
			 @Obs_LicitacionesM,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Movimiento,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Nro_Detalle,'|' ,
			 @id_ComprobantePago,'|' ,
			 @Flag_Cancelado,'|' ,
			 @Obs_LicitacionesM,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Movimiento,
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @id_ComprobantePago,
			 @Flag_Cancelado,
			 @Obs_LicitacionesM,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Movimiento,
			 d.Id_ClienteProveedor,
			 d.Cod_Licitacion,
			 d.Nro_Detalle,
			 d.id_ComprobantePago,
			 d.Flag_Cancelado,
			 d.Obs_LicitacionesM,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Movimiento,
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @id_ComprobantePago,
			 @Flag_Cancelado,
			 @Obs_LicitacionesM,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Movimiento,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_Licitacion,'|' ,
			 @Nro_Detalle,'|' ,
			 @id_ComprobantePago,'|' ,
			 @Flag_Cancelado,'|' ,
			 @Obs_LicitacionesM,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Movimiento), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Movimiento,
			 @Id_ClienteProveedor,
			 @Cod_Licitacion,
			 @Nro_Detalle,
			 @id_ComprobantePago,
			 @Flag_Cancelado,
			 @Obs_LicitacionesM,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_MENSAJES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_MENSAJES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_MENSAJES_IUD
GO

CREATE TRIGGER UTR_PRI_MENSAJES_IUD
ON dbo.PRI_MENSAJES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Mensaje int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_MENSAJES'
	--Variables de tabla secundarias
	DECLARE @Cod_UsuarioRemite varchar(32)
	DECLARE @Fecha_Remite datetime
	DECLARE @Mensaje varchar(1024)
	DECLARE @Flag_Leido bit
	DECLARE @Cod_UsuarioRecibe varchar(32)
	DECLARE @Fecha_Recibe datetime
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Mensaje,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Mensaje,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_MENSAJES_I ' +
			  ''''+REPLACE(pm.Cod_UsuarioRemite,'''','')+''','+
			  ''''+CONVERT(varchar(max), pm.Fecha_Remite,121)+''',' +
			  ''''+REPLACE(pm.Mensaje,'''','')+''','+
			  CONVERT(varchar(max),pm.Flag_Leido)+','+
			  ''''+REPLACE(pm.Cod_UsuarioRecibe,'''','')+''','+
			  CASE WHEN pm.Fecha_Recibe IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max), pm.Fecha_Recibe,121)+''',' END +
			  ''''+REPLACE(COALESCE(pm.Cod_UsuarioAct,pm.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pm 
			  WHERE pm.Id_Mensaje=@Id_Mensaje
		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Mensaje), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Mensaje,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Mensaje,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Mensaje,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_MENSAJES_D ' +
			  ''''+REPLACE(pm.Cod_UsuarioRemite,'''','')+''','+
			  ''''+CONVERT(varchar(max), pm.Fecha_Remite,121)+''',' +
			  ''''+REPLACE(pm.Cod_UsuarioRecibe,'''','')+''','+
			  CASE WHEN pm.Fecha_Recibe IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max), pm.Fecha_Recibe,121)+''',' END +
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pm 
			  WHERE pm.Id_Mensaje=@Id_Mensaje
		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Mensaje), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Mensaje,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Mensaje,
			 i.Cod_UsuarioRemite,
			 i.Fecha_Remite,
			 i.Mensaje,
			 i.Flag_Leido,
			 i.Cod_UsuarioRecibe,
			 i.Fecha_Recibe,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Mensaje,
			 @Cod_UsuarioRemite,
			 @Fecha_Remite,
			 @Mensaje,
			 @Flag_Leido,
			 @Cod_UsuarioRecibe,
			 @Fecha_Recibe,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Mensaje,'|' ,
			 @Cod_UsuarioRemite,'|' ,
			 CONVERT(varchar,@Fecha_Remite,121), '|' ,
			 @Mensaje,'|' ,
			 @Flag_Leido,'|' ,
			 @Cod_UsuarioRecibe,'|' ,
			 CONVERT(varchar,@Fecha_Recibe,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Mensaje), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Mensaje,
			 @Cod_UsuarioRemite,
			 @Fecha_Remite,
			 @Mensaje,
			 @Flag_Leido,
			 @Cod_UsuarioRecibe,
			 @Fecha_Recibe,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Mensaje,
			 d.Cod_UsuarioRemite,
			 d.Fecha_Remite,
			 d.Mensaje,
			 d.Flag_Leido,
			 d.Cod_UsuarioRecibe,
			 d.Fecha_Recibe,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Mensaje,
			 @Cod_UsuarioRemite,
			 @Fecha_Remite,
			 @Mensaje,
			 @Flag_Leido,
			 @Cod_UsuarioRecibe,
			 @Fecha_Recibe,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Mensaje,'|' ,
			 @Cod_UsuarioRemite,'|' ,
			 CONVERT(varchar,@Fecha_Remite,121), '|' ,
			 @Mensaje,'|' ,
			 @Flag_Leido,'|' ,
			 @Cod_UsuarioRecibe,'|' ,
			 CONVERT(varchar,@Fecha_Recibe,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Mensaje), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Mensaje,
			 @Cod_UsuarioRemite,
			 @Fecha_Remite,
			 @Mensaje,
			 @Flag_Leido,
			 @Cod_UsuarioRecibe,
			 @Fecha_Recibe,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_MODULO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_MODULO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_MODULO_IUD
GO

CREATE TRIGGER UTR_PRI_MODULO_IUD
ON dbo.PRI_MODULO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Modulo varchar(8)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_MODULO'
	--Variables de tabla secundarias
	DECLARE @Des_Modulo varchar(64)
	DECLARE @Padre_Modulo varchar(8)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Modulo,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Modulo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Modulo), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Modulo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Modulo,
			 i.Des_Modulo,
			 i.Padre_Modulo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Modulo,
			 @Des_Modulo,
			 @Padre_Modulo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Modulo,'|' ,
			 @Des_Modulo,'|' ,
			 @Padre_Modulo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Modulo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Modulo,
			 @Des_Modulo,
			 @Padre_Modulo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Modulo,
			 d.Des_Modulo,
			 d.Padre_Modulo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Modulo,
			 @Des_Modulo,
			 @Padre_Modulo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Modulo,'|' ,
			 @Des_Modulo,'|' ,
			 @Padre_Modulo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Modulo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Modulo,
			 @Des_Modulo,
			 @Padre_Modulo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PADRONES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PADRONES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PADRONES_IUD
GO

CREATE TRIGGER UTR_PRI_PADRONES_IUD
ON dbo.PRI_PADRONES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Padron varchar(32)
	DECLARE @Id_ClienteProveedor int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PADRONES'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoPadron varchar(32)
	DECLARE @Des_Padron varchar(32)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Nro_Resolucion varchar(64)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Padron,
		    i.Id_ClienteProveedor,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Padron,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_PADRONES_I ' +
			  ''''+REPLACE(pp.Cod_Padron,'''','')+''','+
			  CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  CASE WHEN pp.Cod_TipoPadron IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_TipoPadron,'''','') +''','END+
			  CASE WHEN pp.Des_Padron IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Des_Padron,'''','') +''','END+
			  CASE WHEN pp.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pp.Fecha_Inicio,121) +''','END+
			  CASE WHEN pp.Fecha_Fin IS NULL THEN 'NULL,' ELSE ''''+ convert(varchar(max),pp.Fecha_Fin,121) +''','END+
			  CASE WHEN pp.Nro_Resolucion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Nro_Resolucion,'''','') +''','END+
			  ''''+REPLACE(COALESCE(pp.Cod_UsuarioAct,pp.Cod_UsuarioReg),'''','')   +''';' 
			  FROM INSERTED pp INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pp.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  WHERE pp.Cod_Padron=@Cod_Padron AND pp.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Padron,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Padron,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Padron,
		    d.Id_ClienteProveedor,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Padron,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_PADRONES_D ' +
			  ''''+REPLACE(pp.Cod_Padron,'''','')+''','+
			  CASE WHEN pcp.Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN pcp.Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pcp.Nro_Documento,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pp INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
			  ON pp.Id_ClienteProveedor = pcp.Id_ClienteProveedor
			  WHERE pp.Cod_Padron=@Cod_Padron AND pp.Id_ClienteProveedor=@Id_ClienteProveedor

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Padron,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Padron,
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Padron,
			 i.Id_ClienteProveedor,
			 i.Cod_TipoPadron,
			 i.Des_Padron,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Nro_Resolucion,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Padron,
			 @Id_ClienteProveedor,
			 @Cod_TipoPadron,
			 @Des_Padron,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Nro_Resolucion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Padron,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoPadron,'|' ,
			 @Des_Padron,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Nro_Resolucion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Padron,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Padron,
			 @Id_ClienteProveedor,
			 @Cod_TipoPadron,
			 @Des_Padron,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Nro_Resolucion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Padron,
			 d.Id_ClienteProveedor,
			 d.Cod_TipoPadron,
			 d.Des_Padron,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Nro_Resolucion,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Padron,
			 @Id_ClienteProveedor,
			 @Cod_TipoPadron,
			 @Des_Padron,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Nro_Resolucion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Padron,'|' ,
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoPadron,'|' ,
			 @Des_Padron,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Nro_Resolucion,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Padron,'|',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Padron,
			 @Id_ClienteProveedor,
			 @Cod_TipoPadron,
			 @Des_Padron,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Nro_Resolucion,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PERFIL
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PERFIL_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PERFIL_IUD
GO

CREATE TRIGGER UTR_PRI_PERFIL_IUD
ON dbo.PRI_PERFIL
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Perfil varchar(8)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PERFIL'
	--Variables de tabla secundarias
	DECLARE @Des_Perfil varchar(64)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Perfil,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Perfil,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Perfil), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Perfil,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Perfil,
			 i.Des_Perfil,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Perfil,
			 @Des_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Perfil,'|' ,
			 @Des_Perfil,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Perfil), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Perfil,
			 @Des_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Perfil,
			 d.Des_Perfil,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Perfil,
			 @Des_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Perfil,'|' ,
			 @Des_Perfil,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Perfil), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Perfil,
			 @Des_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--PRI_PERFIL_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PERFIL_D_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PERFIL_D_IUD
GO

CREATE TRIGGER UTR_PRI_PERFIL_D_IUD
ON dbo.PRI_PERFIL_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Perfil varchar(8)
	DECLARE @Cod_Modulo varchar(8)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PERFIL_D'
	--Variables de tabla secundarias
	DECLARE @Acceso varchar(32)
	DECLARE @Escritura bit
	DECLARE @Lectura bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Perfil,
	--	    i.Cod_Modulo,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Perfil,
	--	    @Cod_Modulo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Perfil,'|',@Cod_Modulo,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Perfil,
	--	    @Cod_Modulo,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Perfil,
			 i.Cod_Modulo,
			 i.Acceso,
			 i.Escritura,
			 i.Lectura,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Perfil,
			 @Cod_Modulo,
			 @Acceso,
			 @Escritura,
			 @Lectura,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Perfil,'|' ,
			 @Cod_Modulo,'|' ,
			 @Acceso,'|' ,
			 @Escritura,'|' ,
			 @Lectura,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Perfil,'|',@Cod_Modulo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Perfil,
			 @Cod_Modulo,
			 @Acceso,
			 @Escritura,
			 @Lectura,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Perfil,
			 d.Cod_Modulo,
			 d.Acceso,
			 d.Escritura,
			 d.Lectura,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Perfil,
			 @Cod_Modulo,
			 @Acceso,
			 @Escritura,
			 @Lectura,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Perfil,'|' ,
			 @Cod_Modulo,'|' ,
			 @Acceso,'|' ,
			 @Escritura,'|' ,
			 @Lectura,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Perfil,'|',@Cod_Modulo), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Perfil,
			 @Cod_Modulo,
			 @Acceso,
			 @Escritura,
			 @Lectura,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PERSONAL
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PERSONAL_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PERSONAL_IUD
GO

CREATE TRIGGER UTR_PRI_PERSONAL_IUD
ON dbo.PRI_PERSONAL
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PERSONAL'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoDoc varchar(3)
	DECLARE @Num_Doc varchar(20)
	DECLARE @ApellidoPaterno varchar(64)
	DECLARE @ApellidoMaterno varchar(64)
	DECLARE @PrimeroNombre varchar(64)
	DECLARE @SegundoNombre varchar(64)
	DECLARE @Direccion varchar(128)
	DECLARE @Ref_Direccion varchar(256)
	DECLARE @Telefono varchar(256)
	DECLARE @Email varchar(256)
	DECLARE @Fecha_Ingreso datetime
	DECLARE @Fecha_Nacimiento datetime
	DECLARE @Cod_Cargo varchar(32)
	DECLARE @Cod_Estado varchar(32)
	DECLARE @Cod_Area varchar(32)
	DECLARE @Cod_Local varchar(16)
	DECLARE @Cod_CentroCostos varchar(16)
	DECLARE @Cod_EstadoCivil varchar(32)
	DECLARE @Fecha_InsESSALUD datetime
	DECLARE @AutoGeneradoEsSalud varchar(64)
	DECLARE @Cod_CuentaCTS varchar(5)
	DECLARE @Num_CuentaCTS varchar(128)
	DECLARE @Cod_BancoRemuneracion varchar(5)
	DECLARE @Num_CuentaRemuneracion varchar(128)
	DECLARE @Grupo_Sanguinio varchar(64)
	DECLARE @Cod_AFP varchar(32)
	DECLARE @AutoGeneradoAFP varchar(32)
	DECLARE @Flag_CertificadoSalud bit
	DECLARE @Flag_CertificadoAntPoliciales bit
	DECLARE @Flag_CertificadorAntJudiciales bit
	DECLARE @Flag_DeclaracionBienes bit
	DECLARE @Flag_OtrosDocumentos bit
	DECLARE @Cod_Sexo varchar(32)
	DECLARE @Cod_UsuarioLogin varchar(32)
	DECLARE @Obs_Personal xml
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Personal,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_PERSONAL_I ' +
			  ''''+REPLACE(pp.Cod_Personal,'''','')+''','+
			  CASE WHEN pp.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_TipoDoc,'''','') +''','END+
			  CASE WHEN pp.Num_Doc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Num_Doc,'''','') +''','END+
			  CASE WHEN pp.ApellidoPaterno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.ApellidoPaterno,'''','') +''','END+
			  CASE WHEN pp.ApellidoMaterno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.ApellidoMaterno,'''','') +''','END+
			  CASE WHEN pp.PrimeroNombre IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.PrimeroNombre,'''','') +''','END+
			  CASE WHEN pp.SegundoNombre IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.SegundoNombre,'''','') +''','END+
			  CASE WHEN pp.Direccion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Direccion,'''','') +''','END+
			  CASE WHEN pp.Ref_Direccion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Ref_Direccion,'''','') +''','END+
			  CASE WHEN pp.Telefono IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Telefono,'''','') +''','END+
			  CASE WHEN pp.Email IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Email,'''','') +''','END+
			  CASE WHEN pp.Fecha_Ingreso IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Ingreso,121) +''','END+
			  CASE WHEN pp.Fecha_Nacimiento IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Nacimiento,121) +''','END+
			  CASE WHEN pp.Cod_Cargo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_Cargo,'''','') +''','END+
			  CASE WHEN pp.Cod_Estado IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_Estado,'''','') +''','END+
			  CASE WHEN pp.Cod_Area IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_Area,'''','') +''','END+
			  CASE WHEN pp.Cod_Local IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_Local,'''','') +''','END+
			  CASE WHEN pp.Cod_CentroCostos IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_CentroCostos,'''','') +''','END+
			  CASE WHEN pp.Cod_EstadoCivil IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_EstadoCivil,'''','') +''','END+
			  CASE WHEN pp.Fecha_InsESSALUD IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_InsESSALUD,121) +''','END+
			  CASE WHEN pp.AutoGeneradoEsSalud IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.AutoGeneradoEsSalud,'''','') +''','END+
			  CASE WHEN pp.Cod_CuentaCTS IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_CuentaCTS,'''','') +''','END+
			  CASE WHEN pp.Num_CuentaCTS IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Num_CuentaCTS,'''','') +''','END+
			  CASE WHEN pp.Cod_BancoRemuneracion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_BancoRemuneracion,'''','') +''','END+
			  CASE WHEN pp.Num_CuentaRemuneracion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Num_CuentaRemuneracion,'''','') +''','END+
			  CASE WHEN pp.Grupo_Sanguinio IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Grupo_Sanguinio,'''','') +''','END+
			  CASE WHEN pp.Cod_AFP IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_AFP,'''','') +''','END+
			  CASE WHEN pp.AutoGeneradoAFP IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.AutoGeneradoAFP,'''','') +''','END+
			  convert (varchar(max),pp.Flag_CertificadoSalud)+','+
			  convert (varchar(max),pp.Flag_CertificadoAntPoliciales)+','+
			  convert (varchar(max),pp.Flag_CertificadorAntJudiciales)+','+
			  convert (varchar(max),pp.Flag_DeclaracionBienes)+','+
			  convert (varchar(max),pp.Flag_OtrosDocumentos)+','+
			  CASE WHEN pp.Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_Sexo,'''','') +''','END+
			  CASE WHEN pp.Cod_UsuarioLogin IS NULL THEN 'NULL,' ELSE ''''+REPLACE(pp.Cod_UsuarioLogin,'''','') +''','END+
			  CASE WHEN pp.Obs_Personal IS NULL THEN 'NULL,' ELSE ''''+REPLACE(convert(varchar(max),pp.Obs_Personal),'''','') +''','END+
			  ''''+REPLACE(COALESCE(pp.Cod_UsuarioAct,pp.Cod_UsuarioReg),'''','') +''';' 
			  FROM INSERTED pp
			  WHERE pp.Cod_Personal=@Cod_Personal

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Personal), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Personal,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script = 'USP_PRI_PERSONAL_D ' +
			  ''''+REPLACE(pp.Cod_Personal,'''','')+''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED pp
			  WHERE pp.Cod_Personal=@Cod_Personal

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Personal), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Personal,
			 i.Cod_TipoDoc,
			 i.Num_Doc,
			 i.ApellidoPaterno,
			 i.ApellidoMaterno,
			 i.PrimeroNombre,
			 i.SegundoNombre,
			 i.Direccion,
			 i.Ref_Direccion,
			 i.Telefono,
			 i.Email,
			 i.Fecha_Ingreso,
			 i.Fecha_Nacimiento,
			 i.Cod_Cargo,
			 i.Cod_Estado,
			 i.Cod_Area,
			 i.Cod_Local,
			 i.Cod_CentroCostos,
			 i.Cod_EstadoCivil,
			 i.Fecha_InsESSALUD,
			 i.AutoGeneradoEsSalud,
			 i.Cod_CuentaCTS,
			 i.Num_CuentaCTS,
			 i.Cod_BancoRemuneracion,
			 i.Num_CuentaRemuneracion,
			 i.Grupo_Sanguinio,
			 i.Cod_AFP,
			 i.AutoGeneradoAFP,
			 i.Flag_CertificadoSalud,
			 i.Flag_CertificadoAntPoliciales,
			 i.Flag_CertificadorAntJudiciales,
			 i.Flag_DeclaracionBienes,
			 i.Flag_OtrosDocumentos,
			 i.Cod_Sexo,
			 i.Cod_UsuarioLogin,
			 i.Obs_Personal,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Num_Doc,'|' ,
			 @ApellidoPaterno,'|' ,
			 @ApellidoMaterno,'|' ,
			 @PrimeroNombre,'|' ,
			 @SegundoNombre,'|' ,
			 @Direccion,'|' ,
			 @Ref_Direccion,'|' ,
			 @Telefono,'|' ,
			 @Email,'|' ,
			 CONVERT(varchar,@Fecha_Ingreso,121), '|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Cargo,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_Local,'|' ,
			 @Cod_CentroCostos,'|' ,
			 @Cod_EstadoCivil,'|' ,
			 CONVERT(varchar,@Fecha_InsESSALUD,121), '|' ,
			 @AutoGeneradoEsSalud,'|' ,
			 @Cod_CuentaCTS,'|' ,
			 @Num_CuentaCTS,'|' ,
			 @Cod_BancoRemuneracion,'|' ,
			 @Num_CuentaRemuneracion,'|' ,
			 @Grupo_Sanguinio,'|' ,
			 @Cod_AFP,'|' ,
			 @AutoGeneradoAFP,'|' ,
			 @Flag_CertificadoSalud,'|' ,
			 @Flag_CertificadoAntPoliciales,'|' ,
			 @Flag_CertificadorAntJudiciales,'|' ,
			 @Flag_DeclaracionBienes,'|' ,
			 @Flag_OtrosDocumentos,'|' ,
			 @Cod_Sexo,'|' ,
			 @Cod_UsuarioLogin,'|' ,
			 CONVERT(varchar(max),@Obs_Personal),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Personal,
			 d.Cod_TipoDoc,
			 d.Num_Doc,
			 d.ApellidoPaterno,
			 d.ApellidoMaterno,
			 d.PrimeroNombre,
			 d.SegundoNombre,
			 d.Direccion,
			 d.Ref_Direccion,
			 d.Telefono,
			 d.Email,
			 d.Fecha_Ingreso,
			 d.Fecha_Nacimiento,
			 d.Cod_Cargo,
			 d.Cod_Estado,
			 d.Cod_Area,
			 d.Cod_Local,
			 d.Cod_CentroCostos,
			 d.Cod_EstadoCivil,
			 d.Fecha_InsESSALUD,
			 d.AutoGeneradoEsSalud,
			 d.Cod_CuentaCTS,
			 d.Num_CuentaCTS,
			 d.Cod_BancoRemuneracion,
			 d.Num_CuentaRemuneracion,
			 d.Grupo_Sanguinio,
			 d.Cod_AFP,
			 d.AutoGeneradoAFP,
			 d.Flag_CertificadoSalud,
			 d.Flag_CertificadoAntPoliciales,
			 d.Flag_CertificadorAntJudiciales,
			 d.Flag_DeclaracionBienes,
			 d.Flag_OtrosDocumentos,
			 d.Cod_Sexo,
			 d.Cod_UsuarioLogin,
			 d.Obs_Personal,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Num_Doc,'|' ,
			 @ApellidoPaterno,'|' ,
			 @ApellidoMaterno,'|' ,
			 @PrimeroNombre,'|' ,
			 @SegundoNombre,'|' ,
			 @Direccion,'|' ,
			 @Ref_Direccion,'|' ,
			 @Telefono,'|' ,
			 @Email,'|' ,
			 CONVERT(varchar,@Fecha_Ingreso,121), '|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Cargo,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_Local,'|' ,
			 @Cod_CentroCostos,'|' ,
			 @Cod_EstadoCivil,'|' ,
			 CONVERT(varchar,@Fecha_InsESSALUD,121), '|' ,
			 @AutoGeneradoEsSalud,'|' ,
			 @Cod_CuentaCTS,'|' ,
			 @Num_CuentaCTS,'|' ,
			 @Cod_BancoRemuneracion,'|' ,
			 @Num_CuentaRemuneracion,'|' ,
			 @Grupo_Sanguinio,'|' ,
			 @Cod_AFP,'|' ,
			 @AutoGeneradoAFP,'|' ,
			 @Flag_CertificadoSalud,'|' ,
			 @Flag_CertificadoAntPoliciales,'|' ,
			 @Flag_CertificadorAntJudiciales,'|' ,
			 @Flag_DeclaracionBienes,'|' ,
			 @Flag_OtrosDocumentos,'|' ,
			 @Cod_Sexo,'|' ,
			 @Cod_UsuarioLogin,'|' ,
			 CONVERT(varchar(max),@Obs_Personal),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Personal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PERSONAL_PARENTESCO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PERSONAL_PARENTESCO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PERSONAL_PARENTESCO_IUD
GO

CREATE TRIGGER UTR_PRI_PERSONAL_PARENTESCO_IUD
ON dbo.PRI_PERSONAL_PARENTESCO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Personal varchar(32)
	DECLARE @Item_Parentesco int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PERSONAL_PARENTESCO'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoDoc varchar(5)
	DECLARE @Num_Doc varchar(20)
	DECLARE @ApellidoPaterno varchar(124)
	DECLARE @ApellidoMaterno varchar(124)
	DECLARE @Nombres varchar(124)
	DECLARE @Cod_TipoParentesco varchar(5)
	DECLARE @Obs_Parentesco varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Cod_Personal,
		    i.Item_Parentesco,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Item_Parentesco,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PERSONAL_PARENTESCO_I ' +
				 ''''+REPLACE(ppp.Cod_Personal,'''','')+''','+
				 CONVERT(varchar(max),ppp.Item_Parentesco)+','+
				 CASE WHEN ppp.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.Cod_TipoDoc,'''','') +''','END+
				 CASE WHEN ppp.Num_Doc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.Num_Doc,'''','') +''','END+
				 CASE WHEN ppp.ApellidoPaterno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.ApellidoPaterno,'''','') +''','END+
				 CASE WHEN ppp.ApellidoMaterno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.ApellidoMaterno,'''','') +''','END+
				 CASE WHEN ppp.Nombres IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.Nombres,'''','') +''','END+
				 CASE WHEN ppp.Cod_TipoParentesco IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.Cod_TipoParentesco,'''','') +''','END+
				 CASE WHEN ppp.Obs_Parentesco IS NULL THEN 'NULL,' ELSE ''''+REPLACE(ppp.Obs_Parentesco,'''','') +''','END+
				 ''''+REPLACE(COALESCE(ppp.Cod_UsuarioAct,ppp.Cod_UsuarioReg),'''','')   +''';' 
				 FROM INSERTED  ppp
				 WHERE ppp.Cod_Personal=@Cod_Personal AND ppp.Item_Parentesco=@Item_Parentesco

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Personal,'|',@Item_Parentesco), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Item_Parentesco,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Personal,
		    d.Item_Parentesco,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Item_Parentesco,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PERSONAL_PARENTESCO_D ' +
				 ''''+REPLACE(ppp.Cod_Personal,'''','')+''','+
				 CONVERT(varchar(max),ppp.Item_Parentesco)+','+
				 ''''+'TRIGGER'+''',' +
				 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM DELETED ppp
				 WHERE ppp.Cod_Personal=@Cod_Personal AND ppp.Item_Parentesco=@Item_Parentesco

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Cod_Personal,'|',@Item_Parentesco), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Personal,
		    @Item_Parentesco,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Personal,
			 i.Item_Parentesco,
			 i.Cod_TipoDoc,
			 i.Num_Doc,
			 i.ApellidoPaterno,
			 i.ApellidoMaterno,
			 i.Nombres,
			 i.Cod_TipoParentesco,
			 i.Obs_Parentesco,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Personal,
			 @Item_Parentesco,
			 @Cod_TipoDoc,
			 @Num_Doc,
			 @ApellidoPaterno,
			 @ApellidoMaterno,
			 @Nombres,
			 @Cod_TipoParentesco,
			 @Obs_Parentesco,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Item_Parentesco,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Num_Doc,'|' ,
			 @ApellidoPaterno,'|' ,
			 @ApellidoMaterno,'|' ,
			 @Nombres,'|' ,
			 @Cod_TipoParentesco,'|' ,
			 @Obs_Parentesco,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Personal,'|',@Item_Parentesco), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Personal,
			 @Item_Parentesco,
			 @Cod_TipoDoc,
			 @Num_Doc,
			 @ApellidoPaterno,
			 @ApellidoMaterno,
			 @Nombres,
			 @Cod_TipoParentesco,
			 @Obs_Parentesco,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Personal,
			 d.Item_Parentesco,
			 d.Cod_TipoDoc,
			 d.Num_Doc,
			 d.ApellidoPaterno,
			 d.ApellidoMaterno,
			 d.Nombres,
			 d.Cod_TipoParentesco,
			 d.Obs_Parentesco,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Personal,
			 @Item_Parentesco,
			 @Cod_TipoDoc,
			 @Num_Doc,
			 @ApellidoPaterno,
			 @ApellidoMaterno,
			 @Nombres,
			 @Cod_TipoParentesco,
			 @Obs_Parentesco,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Personal,'|' ,
			 @Item_Parentesco,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Num_Doc,'|' ,
			 @ApellidoPaterno,'|' ,
			 @ApellidoMaterno,'|' ,
			 @Nombres,'|' ,
			 @Cod_TipoParentesco,'|' ,
			 @Obs_Parentesco,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Personal,'|',@Item_Parentesco), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Personal,
			 @Item_Parentesco,
			 @Cod_TipoDoc,
			 @Num_Doc,
			 @ApellidoPaterno,
			 @ApellidoMaterno,
			 @Nombres,
			 @Cod_TipoParentesco,
			 @Obs_Parentesco,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
END
GO

--PRI_PRODUCTO_DETALLE
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_DETALLE_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_DETALLE_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_DETALLE_IUD
ON dbo.PRI_PRODUCTO_DETALLE
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Item_Detalle int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_DETALLE'
	--Variables de tabla secundarias
	DECLARE @Id_ProductoDetalle int
	DECLARE @Cod_TipoDetalle varchar(5)
	DECLARE @Cantidad numeric(38,6)
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Producto,
		    i.Item_Detalle,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Item_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_DETALLE_I ''' + 
				 CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(P.Cod_Producto,'''','')+''','END+
				 CONVERT(VARCHAR(MAX),D.Item_Detalle)+','''+ 
				 CASE WHEN PD.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(PD.Cod_Producto,'''','')+''','END+
				 CASE WHEN D.Cod_TipoDetalle IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(D.Cod_TipoDetalle,'''','')+''','END+
				 CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), D.Cantidad)+','END+
				 CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(D.Cod_UnidadMedida,'''','')+''','END+
				 ''''+REPLACE(COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg),'''','')+''';' 
				 FROM INSERTED AS D INNER JOIN
					 PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto INNER JOIN
					 PRI_PRODUCTOS AS PD ON D.Id_ProductoDetalle = PD.Id_Producto
				 WHERE D.Id_Producto=@Id_Producto AND D.Item_Detalle=@Item_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Item_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Item_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Producto,
		    d.Item_Detalle,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Item_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_DETALLE_D ''' + 
				 CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(P.Cod_Producto,'''','')+''','END+
				 CONVERT(VARCHAR(MAX),D.Item_Detalle)+','''+ 
				 ''''+'TRIGGER'+''',' +
				 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM DELETED D INNER JOIN
					 PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto INNER JOIN
					 PRI_PRODUCTOS AS PD ON D.Id_ProductoDetalle = PD.Id_Producto
				 WHERE D.Id_Producto=@Id_Producto AND D.Item_Detalle=@Item_Detalle

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Item_Detalle), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Item_Detalle,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Item_Detalle,
			 i.Id_ProductoDetalle,
			 i.Cod_TipoDetalle,
			 i.Cantidad,
			 i.Cod_UnidadMedida,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Item_Detalle,
			 @Id_ProductoDetalle,
			 @Cod_TipoDetalle,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Item_Detalle,'|' ,
			 @Id_ProductoDetalle,'|' ,
			 @Cod_TipoDetalle,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Producto,'|',@Item_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Item_Detalle,
			 @Id_ProductoDetalle,
			 @Cod_TipoDetalle,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Item_Detalle,
			 d.Id_ProductoDetalle,
			 d.Cod_TipoDetalle,
			 d.Cantidad,
			 d.Cod_UnidadMedida,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Item_Detalle,
			 @Id_ProductoDetalle,
			 @Cod_TipoDetalle,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Item_Detalle,'|' ,
			 @Id_ProductoDetalle,'|' ,
			 @Cod_TipoDetalle,'|' ,
			 @Cantidad,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_Producto,'|',@Item_Detalle), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Item_Detalle,
			 @Id_ProductoDetalle,
			 @Cod_TipoDetalle,
			 @Cantidad,
			 @Cod_UnidadMedida,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PRODUCTO_IMAGEN
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_IMAGEN_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_IMAGEN_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_IMAGEN_IUD
ON dbo.PRI_PRODUCTO_IMAGEN
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Item_Imagen int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_IMAGEN'
	--Variables de tabla secundarias
	DECLARE @Cod_TipoImagen varchar(5)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Producto,
	--	    i.Item_Imagen,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Producto,
	--	    @Item_Imagen,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Producto,'|',@Item_Imagen,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Producto,
	--	    @Item_Imagen,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Item_Imagen,
			 i.Cod_TipoImagen,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Item_Imagen,
			 @Cod_TipoImagen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Item_Imagen,'|' ,
			 @Cod_TipoImagen,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Producto,'|',@Item_Imagen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Item_Imagen,
			 @Cod_TipoImagen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Item_Imagen,
			 d.Cod_TipoImagen,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Item_Imagen,
			 @Cod_TipoImagen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Item_Imagen,'|' ,
			 @Cod_TipoImagen,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_Producto,'|',@Item_Imagen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Item_Imagen,
			 @Cod_TipoImagen,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PRODUCTO_PRECIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_PRECIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_PRECIO_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_PRECIO_IUD
ON dbo.PRI_PRODUCTO_PRECIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cod_TipoPrecio varchar(5)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_PRECIO'
	--Variables de tabla secundarias
	DECLARE @Valor numeric(38,6)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Cod_TipoPrecio,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_PRODUCTO_PRECIO_I ' + 
			  CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Producto,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_UnidadMedida,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_Almacen,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_TipoPrecio IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_TipoPrecio,'''','')+''',' END+ 
 			  CASE WHEN PP.Valor IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX),PP.Valor)+',' END+ 
			  ''''+REPLACE(COALESCE(PP.Cod_UsuarioAct,PP.Cod_UsuarioReg),'''','')+''';'
			  FROM            INSERTED AS PP INNER JOIN
									   PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto
			  WHERE PP.Id_Producto=@Id_Producto AND PP.Cod_UnidadMedida=@Cod_UnidadMedida AND PP.Cod_Almacen=@Cod_Almacen AND PP.Cod_TipoPrecio=@Cod_TipoPrecio

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen,'|',@Cod_TipoPrecio), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Cod_TipoPrecio,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Producto,
		    d.Cod_UnidadMedida,
		    d.Cod_Almacen,
		    d.Cod_TipoPrecio,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Cod_TipoPrecio,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_PRODUCTO_PRECIO_D ' + 
			  CASE WHEN P.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Producto,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_UnidadMedida,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_Almacen,'''','')+''',' END+ 
			  CASE WHEN PP.Cod_TipoPrecio IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_TipoPrecio,'''','')+''',' END+ 
 			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED PP INNER JOIN
									   PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto
			  WHERE PP.Id_Producto=@Id_Producto AND PP.Cod_UnidadMedida=@Cod_UnidadMedida AND PP.Cod_Almacen=@Cod_Almacen AND PP.Cod_TipoPrecio=@Cod_TipoPrecio

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen,'|',@Cod_TipoPrecio), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Cod_TipoPrecio,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Cod_UnidadMedida,
			 i.Cod_Almacen,
			 i.Cod_TipoPrecio,
			 i.Valor,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_TipoPrecio,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_TipoPrecio,'|' ,
			 @Valor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen,'|',@Cod_TipoPrecio), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_TipoPrecio,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 d.Cod_Almacen,
			 d.Cod_TipoPrecio,
			 d.Valor,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_TipoPrecio,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_TipoPrecio,'|' ,
			 @Valor,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen,'|',@Cod_TipoPrecio), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_TipoPrecio,
			 @Valor,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PRODUCTO_STOCK
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_STOCK_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
ON dbo.PRI_PRODUCTO_STOCK
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_STOCK'
	--Variables de tabla secundarias
	DECLARE @Cod_Moneda varchar(5)
	DECLARE @Precio_Compra numeric(38,6)
	DECLARE @Precio_Venta numeric(38,6)
	DECLARE @Stock_Min numeric(38,6)
	DECLARE @Stock_Max numeric(38,6)
	DECLARE @Stock_Act numeric(38,6)
	DECLARE @Cod_UnidadMedidaMin varchar(5)
	DECLARE @Cantidad_Min numeric(38,6)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_STOCK_I ' +
				 CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+
				 CASE WHEN S.Cod_UnidadMedida  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedida,'''','')+''','END+
				 CASE WHEN S.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Almacen,'''','')+''','END+
				 CASE WHEN S.Cod_Moneda  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Moneda,'''','')+''','END+
				 CASE WHEN S.Precio_Compra  IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Precio_Compra)+','END+
				 CASE WHEN S.Precio_Venta IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Precio_Venta)+','END+
				 CASE WHEN S.Stock_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Min)+','END+
				 CASE WHEN S.Stock_Max IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Max)+','END+
				 CASE WHEN S.Stock_Act IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Stock_Act)+','END+
				 CASE WHEN S.Cod_UnidadMedidaMin IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedidaMin,'''','')+''','END+
				 CASE WHEN S.Cantidad_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Cantidad_Min)+','END+
				 ''''+ REPLACE(COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg),'''','')+''';' 
				 FROM INSERTED AS S INNER JOIN
					  PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
				 WHERE S.Id_Producto=@Id_Producto AND S.Cod_UnidadMedida=@Cod_UnidadMedida AND S.Cod_Almacen=@Cod_Almacen

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Producto,
		    d.Cod_UnidadMedida,
		    d.Cod_Almacen,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_STOCK_D ' +
				 CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+
				 CASE WHEN S.Cod_UnidadMedida  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedida,'''','')+''','END+
				 CASE WHEN S.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Almacen,'''','')+''','END+
				 ''''+'TRIGGER'+''',' +
			     ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM DELETED S INNER JOIN
					  PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
				 WHERE S.Id_Producto=@Id_Producto AND S.Cod_UnidadMedida=@Cod_UnidadMedida AND S.Cod_Almacen=@Cod_Almacen

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Cod_UnidadMedida,
			 i.Cod_Almacen,
			 i.Cod_Moneda,
			 i.Precio_Compra,
			 i.Precio_Venta,
			 i.Stock_Min,
			 i.Stock_Max,
			 i.Stock_Act,
			 i.Cod_UnidadMedidaMin,
			 i.Cantidad_Min,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_Moneda,'|' ,
			 @Precio_Compra,'|' ,
			 @Precio_Venta,'|' ,
			 @Stock_Min,'|' ,
			 @Stock_Max,'|' ,
			 @Stock_Act,'|' ,
			 @Cod_UnidadMedidaMin,'|' ,
			 @Cantidad_Min,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 d.Cod_Almacen,
			 d.Cod_Moneda,
			 d.Precio_Compra,
			 d.Precio_Venta,
			 d.Stock_Min,
			 d.Stock_Max,
			 d.Stock_Act,
			 d.Cod_UnidadMedidaMin,
			 d.Cantidad_Min,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_Moneda,'|' ,
			 @Precio_Compra,'|' ,
			 @Precio_Venta,'|' ,
			 @Stock_Min,'|' ,
			 @Stock_Max,'|' ,
			 @Stock_Act,'|' ,
			 @Cod_UnidadMedidaMin,'|' ,
			 @Cantidad_Min,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
END
GO

--PRI_PRODUCTO_TASA
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_TASA_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_TASA_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_TASA_IUD
ON dbo.PRI_PRODUCTO_TASA
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Cod_Tasa varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_TASA'
	--Variables de tabla secundarias
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Des_Tasa varchar(512)
	DECLARE @Por_Tasa numeric(10,4)
	DECLARE @Cod_TipoTasa varchar(8)
	DECLARE @Flag_Activo bit
	DECLARE @Obs_Tasa varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Producto,
		    i.Cod_Tasa,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_Tasa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_PRODUCTO_TASA_I ' +
			  CASE WHEN T.Cod_Tasa  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Cod_Tasa,'''','') +''','END+
			  CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','') +''','END+
			  CASE WHEN T.Cod_Libro  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Cod_Libro,'''','') +''','END+
			  CASE WHEN T.Des_Tasa IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Des_Tasa,'''','')+''','END+
			  CASE WHEN T.Por_Tasa IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Por_Tasa)+','END+
			  CASE WHEN T.Cod_TipoTasa IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(T.Cod_TipoTasa,'''','')+''','END+
			  CASE WHEN T.Flag_Activo IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), T.Flag_Activo)+','END+
			  CASE WHEN T.Obs_Tasa IS NULL THEN 'NULL,' ELSE ''''+  REPLACE(T.Obs_Tasa,'''','')+''','END+
			  ''''+COALESCE(T.Cod_UsuarioAct,T.Cod_UsuarioReg)+''';'
			  FROM  INSERTED AS T INNER JOIN
				    PRI_PRODUCTOS AS P ON T.Id_Producto = P.Id_Producto
			  WHERE T.Id_Producto=@Id_Producto AND T.Cod_Tasa=@Cod_Tasa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_Tasa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_Tasa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Producto,
		    d.Cod_Tasa,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_Tasa,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_PRODUCTO_TASA_D ' +
			  CASE WHEN T.Cod_Tasa  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(T.Cod_Tasa,'''','') +''','END+
			  CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','') +''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED T INNER JOIN
				    PRI_PRODUCTOS AS P ON T.Id_Producto = P.Id_Producto
			  WHERE T.Id_Producto=@Id_Producto AND T.Cod_Tasa=@Cod_Tasa

		   	SET @FechaReg= GETDATE()
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
			   CONCAT(@Id_Producto,'|',@Cod_Tasa), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_Tasa,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Cod_Tasa,
			 i.Cod_Libro,
			 i.Des_Tasa,
			 i.Por_Tasa,
			 i.Cod_TipoTasa,
			 i.Flag_Activo,
			 i.Obs_Tasa,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_Tasa,
			 @Cod_Libro,
			 @Des_Tasa,
			 @Por_Tasa,
			 @Cod_TipoTasa,
			 @Flag_Activo,
			 @Obs_Tasa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Tasa,'|' ,
			 @Cod_Libro,'|' ,
			 @Des_Tasa,'|' ,
			 @Por_Tasa,'|' ,
			 @Cod_TipoTasa,'|' ,
			 @Flag_Activo,'|' ,
			 @Obs_Tasa,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Id_Producto,'|',@Cod_Tasa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_Tasa,
			 @Cod_Libro,
			 @Des_Tasa,
			 @Por_Tasa,
			 @Cod_TipoTasa,
			 @Flag_Activo,
			 @Obs_Tasa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_Tasa,
			 d.Cod_Libro,
			 d.Des_Tasa,
			 d.Por_Tasa,
			 d.Cod_TipoTasa,
			 d.Flag_Activo,
			 d.Obs_Tasa,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_Tasa,
			 @Cod_Libro,
			 @Des_Tasa,
			 @Por_Tasa,
			 @Cod_TipoTasa,
			 @Flag_Activo,
			 @Obs_Tasa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Tasa,'|' ,
			 @Cod_Libro,'|' ,
			 @Des_Tasa,'|' ,
			 @Por_Tasa,'|' ,
			 @Cod_TipoTasa,'|' ,
			 @Flag_Activo,'|' ,
			 @Obs_Tasa,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			 CONCAT(@Id_Producto,'|',@Cod_Tasa), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_Tasa,
			 @Cod_Libro,
			 @Des_Tasa,
			 @Por_Tasa,
			 @Cod_TipoTasa,
			 @Flag_Activo,
			 @Obs_Tasa,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO

--PRI_PRODUCTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTOS_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTOS_IUD
ON dbo.PRI_PRODUCTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTOS'
	--Variables de tabla secundarias
	DECLARE @Cod_Producto varchar(64)
	DECLARE @Cod_Categoria varchar(32)
	DECLARE @Cod_Marca varchar(32)
	DECLARE @Cod_TipoProducto varchar(5)
	DECLARE @Nom_Producto varchar(512)
	DECLARE @Des_CortaProducto varchar(512)
	DECLARE @Des_LargaProducto varchar(1024)
	DECLARE @Caracteristicas varchar(max)
	DECLARE @Porcentaje_Utilidad numeric(5,2)
	DECLARE @Cuenta_Contable varchar(16)
	DECLARE @Contra_Cuenta varchar(16)
	DECLARE @Cod_Garantia varchar(5)
	DECLARE @Cod_TipoExistencia varchar(5)
	DECLARE @Cod_TipoOperatividad varchar(5)
	DECLARE @Flag_Activo bit
	DECLARE @Flag_Stock bit
	DECLARE @Cod_Fabricante varchar(64)
	DECLARE @Obs_Producto xml
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_PRODUCTOS_I ' +
			  CASE WHEN Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Producto,'''','')+''','END+
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
			  FROM            INSERTED
			  WHERE INSERTED.Id_Producto=@Id_Producto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Id_Producto,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_PRODUCTOS_D ' +
			  CASE WHEN Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Producto,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED 
			  WHERE Id_Producto=@Id_Producto

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Producto,
			 i.Cod_Producto,
			 i.Cod_Categoria,
			 i.Cod_Marca,
			 i.Cod_TipoProducto,
			 i.Nom_Producto,
			 i.Des_CortaProducto,
			 i.Des_LargaProducto,
			 i.Caracteristicas,
			 i.Porcentaje_Utilidad,
			 i.Cuenta_Contable,
			 i.Contra_Cuenta,
			 i.Cod_Garantia,
			 i.Cod_TipoExistencia,
			 i.Cod_TipoOperatividad,
			 i.Flag_Activo,
			 i.Flag_Stock,
			 i.Cod_Fabricante,
			 i.Obs_Producto,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Producto,'|' ,
			 @Cod_Categoria,'|' ,
			 @Cod_Marca,'|' ,
			 @Cod_TipoProducto,'|' ,
			 @Nom_Producto,'|' ,
			 @Des_CortaProducto,'|' ,
			 @Des_LargaProducto,'|' ,
			 @Caracteristicas,'|' ,
			 @Porcentaje_Utilidad,'|' ,
			 @Cuenta_Contable,'|' ,
			 @Contra_Cuenta,'|' ,
			 @Cod_Garantia,'|' ,
			 @Cod_TipoExistencia,'|' ,
			 @Cod_TipoOperatividad,'|' ,
			 @Flag_Activo,'|' ,
			 @Flag_Stock,'|' ,
			 @Cod_Fabricante,'|' ,
			 CONVERT(varchar(max),@Obs_Producto),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_Producto,
			 d.Cod_Categoria,
			 d.Cod_Marca,
			 d.Cod_TipoProducto,
			 d.Nom_Producto,
			 d.Des_CortaProducto,
			 d.Des_LargaProducto,
			 d.Caracteristicas,
			 d.Porcentaje_Utilidad,
			 d.Cuenta_Contable,
			 d.Contra_Cuenta,
			 d.Cod_Garantia,
			 d.Cod_TipoExistencia,
			 d.Cod_TipoOperatividad,
			 d.Flag_Activo,
			 d.Flag_Stock,
			 d.Cod_Fabricante,
			 d.Obs_Producto,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Producto,'|' ,
			 @Cod_Categoria,'|' ,
			 @Cod_Marca,'|' ,
			 @Cod_TipoProducto,'|' ,
			 @Nom_Producto,'|' ,
			 @Des_CortaProducto,'|' ,
			 @Des_LargaProducto,'|' ,
			 @Caracteristicas,'|' ,
			 @Porcentaje_Utilidad,'|' ,
			 @Cuenta_Contable,'|' ,
			 @Contra_Cuenta,'|' ,
			 @Cod_Garantia,'|' ,
			 @Cod_TipoExistencia,'|' ,
			 @Cod_TipoOperatividad,'|' ,
			 @Flag_Activo,'|' ,
			 @Flag_Stock,'|' ,
			 @Cod_Fabricante,'|' ,
			 CONVERT(varchar(max),@Obs_Producto),'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
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
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

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
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Sucursal varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_SUCURSAL'
	--Variables de tabla secundarias
	DECLARE @Nom_Sucursal varchar(32)
	DECLARE @Dir_Sucursal varchar(512)
	DECLARE @Por_UtilidadMax numeric(5,2)
	DECLARE @Por_UtilidadMin numeric(5,2)
	DECLARE @Cod_UsuarioAdm varchar(32)
	DECLARE @Cabecera_Pagina varchar(1024)
	DECLARE @Pie_Pagina varchar(1024)
	DECLARE @Flag_Activo bit
	DECLARE @Cod_Ubigeo varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
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
			  SELECT @Script= 'USP_PRI_SUCURSAL_I ' +
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
			  FROM INSERTED ps
			  WHERE ps.Cod_Sucursal = @Cod_Sucursal

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Sucursal), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Sucursal,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

	IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.Cod_Sucursal,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Cod_Sucursal,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script= 'USP_PRI_SUCURSAL_D ' +
			  ''''+REPLACE(ps.Cod_Sucursal,'''','')+''','+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED ps
			  WHERE ps.Cod_Sucursal = @Cod_Sucursal

		   	SET @FechaReg= GETDATE()
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
			   CONCAT('',@Cod_Sucursal), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Cod_Sucursal,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Nom_Sucursal,'|' ,
			 @Dir_Sucursal,'|' ,
			 @Por_UtilidadMax,'|' ,
			 @Por_UtilidadMin,'|' ,
			 @Cod_UsuarioAdm,'|' ,
			 @Cabecera_Pagina,'|' ,
			 @Pie_Pagina,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Sucursal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Sucursal,
			 d.Nom_Sucursal,
			 d.Dir_Sucursal,
			 d.Por_UtilidadMax,
			 d.Por_UtilidadMin,
			 d.Cod_UsuarioAdm,
			 d.Cabecera_Pagina,
			 d.Pie_Pagina,
			 d.Flag_Activo,
			 d.Cod_Ubigeo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
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
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Sucursal,'|' ,
			 @Nom_Sucursal,'|' ,
			 @Dir_Sucursal,'|' ,
			 @Por_UtilidadMax,'|' ,
			 @Por_UtilidadMin,'|' ,
			 @Cod_UsuarioAdm,'|' ,
			 @Cabecera_Pagina,'|' ,
			 @Pie_Pagina,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Sucursal), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

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

END
GO

--PRI_USUARIO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_USUARIO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_USUARIO_IUD
GO

CREATE TRIGGER UTR_PRI_USUARIO_IUD
ON dbo.PRI_USUARIO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Usuarios varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_USUARIO'
	--Variables de tabla secundarias
	DECLARE @Nick varchar(64)
	DECLARE @Contrasena varchar(512)
	DECLARE @Pregunta varchar(512)
	DECLARE @Respuesta varchar(128)
	DECLARE @Cod_Estado varchar(3)
	DECLARE @Cod_Perfil varchar(8)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Usuarios,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Usuarios,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Usuarios), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Usuarios,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Usuarios,
			 i.Nick,
			 i.Contrasena,
			 i.Pregunta,
			 i.Respuesta,
			 i.Cod_Estado,
			 i.Cod_Perfil,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Usuarios,
			 @Nick,
			 @Contrasena,
			 @Pregunta,
			 @Respuesta,
			 @Cod_Estado,
			 @Cod_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Usuarios,'|' ,
			 @Nick,'|' ,
			 @Contrasena,'|' ,
			 @Pregunta,'|' ,
			 @Respuesta,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Perfil,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Usuarios), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Usuarios,
			 @Nick,
			 @Contrasena,
			 @Pregunta,
			 @Respuesta,
			 @Cod_Estado,
			 @Cod_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Usuarios,
			 d.Nick,
			 d.Contrasena,
			 d.Pregunta,
			 d.Respuesta,
			 d.Cod_Estado,
			 d.Cod_Perfil,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Usuarios,
			 @Nick,
			 @Contrasena,
			 @Pregunta,
			 @Respuesta,
			 @Cod_Estado,
			 @Cod_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Usuarios,'|' ,
			 @Nick,'|' ,
			 @Contrasena,'|' ,
			 @Pregunta,'|' ,
			 @Respuesta,'|' ,
			 @Cod_Estado,'|' ,
			 @Cod_Perfil,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Usuarios), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Usuarios,
			 @Nick,
			 @Contrasena,
			 @Pregunta,
			 @Respuesta,
			 @Cod_Estado,
			 @Cod_Perfil,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--TAR_ACTIVIDADES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_TAR_ACTIVIDADES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_TAR_ACTIVIDADES_IUD
GO

CREATE TRIGGER UTR_TAR_ACTIVIDADES_IUD
ON dbo.TAR_ACTIVIDADES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Proyecto varchar(32)
	DECLARE @Cod_Actividad varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='TAR_ACTIVIDADES'
	--Variables de tabla secundarias
	DECLARE @Nom_Actividad varchar(512)
	DECLARE @Cod_ActividadPadre varchar(32)
	DECLARE @Cod_EstadoActividad varchar(32)
	DECLARE @Obs_Actividad varchar(1024)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Proyecto,
	--	    i.Cod_Actividad,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Proyecto,
	--	    @Cod_Actividad,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Proyecto,'|',@Cod_Actividad,'|',), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Proyecto,
	--	    @Cod_Actividad,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Proyecto,
			 i.Cod_Actividad,
			 i.Nom_Actividad,
			 i.Cod_ActividadPadre,
			 i.Cod_EstadoActividad,
			 i.Obs_Actividad,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Nom_Actividad,
			 @Cod_ActividadPadre,
			 @Cod_EstadoActividad,
			 @Obs_Actividad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Proyecto,'|' ,
			 @Cod_Actividad,'|' ,
			 @Nom_Actividad,'|' ,
			 @Cod_ActividadPadre,'|' ,
			 @Cod_EstadoActividad,'|' ,
			 @Obs_Actividad,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT(@Cod_Proyecto,'|',@Cod_Actividad), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Nom_Actividad,
			 @Cod_ActividadPadre,
			 @Cod_EstadoActividad,
			 @Obs_Actividad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Proyecto,
			 d.Cod_Actividad,
			 d.Nom_Actividad,
			 d.Cod_ActividadPadre,
			 d.Cod_EstadoActividad,
			 d.Obs_Actividad,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Nom_Actividad,
			 @Cod_ActividadPadre,
			 @Cod_EstadoActividad,
			 @Obs_Actividad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Proyecto,'|' ,
			 @Cod_Actividad,'|' ,
			 @Nom_Actividad,'|' ,
			 @Cod_ActividadPadre,'|' ,
			 @Cod_EstadoActividad,'|' ,
			 @Obs_Actividad,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT(@Cod_Proyecto,'|',@Cod_Actividad), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Nom_Actividad,
			 @Cod_ActividadPadre,
			 @Cod_EstadoActividad,
			 @Obs_Actividad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--TAR_ALERTAS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_TAR_ALERTAS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_TAR_ALERTAS_IUD
GO

CREATE TRIGGER UTR_TAR_ALERTAS_IUD
ON dbo.TAR_ALERTAS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Alerta varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='TAR_ALERTAS'
	--Variables de tabla secundarias
	DECLARE @Fecha_Hora datetime
	DECLARE @Fecha_Alerta datetime
	DECLARE @Titulo varchar(128)
	DECLARE @Des_Alerta varchar(1024)
	DECLARE @Cod_Area varchar(32)
	DECLARE @Flag_Activo bit
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Alerta,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Alerta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Alerta), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Alerta,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Alerta,
			 i.Fecha_Hora,
			 i.Fecha_Alerta,
			 i.Titulo,
			 i.Des_Alerta,
			 i.Cod_Area,
			 i.Flag_Activo,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Alerta,
			 @Fecha_Hora,
			 @Fecha_Alerta,
			 @Titulo,
			 @Des_Alerta,
			 @Cod_Area,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Alerta,'|' ,
			 CONVERT(varchar,@Fecha_Hora,121), '|' ,
			 CONVERT(varchar,@Fecha_Alerta,121), '|' ,
			 @Titulo,'|' ,
			 @Des_Alerta,'|' ,
			 @Cod_Area,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Alerta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Alerta,
			 @Fecha_Hora,
			 @Fecha_Alerta,
			 @Titulo,
			 @Des_Alerta,
			 @Cod_Area,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Alerta,
			 d.Fecha_Hora,
			 d.Fecha_Alerta,
			 d.Titulo,
			 d.Des_Alerta,
			 d.Cod_Area,
			 d.Flag_Activo,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Alerta,
			 @Fecha_Hora,
			 @Fecha_Alerta,
			 @Titulo,
			 @Des_Alerta,
			 @Cod_Area,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Alerta,'|' ,
			 CONVERT(varchar,@Fecha_Hora,121), '|' ,
			 CONVERT(varchar,@Fecha_Alerta,121), '|' ,
			 @Titulo,'|' ,
			 @Des_Alerta,'|' ,
			 @Cod_Area,'|' ,
			 @Flag_Activo,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Alerta), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Alerta,
			 @Fecha_Hora,
			 @Fecha_Alerta,
			 @Titulo,
			 @Des_Alerta,
			 @Cod_Area,
			 @Flag_Activo,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--TAR_CRONOMETROS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_TAR_CRONOMETROS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_TAR_CRONOMETROS_IUD
GO

CREATE TRIGGER UTR_TAR_CRONOMETROS_IUD
ON dbo.TAR_CRONOMETROS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Cronometro int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='TAR_CRONOMETROS'
	--Variables de tabla secundarias
	DECLARE @Cod_Proyecto varchar(32)
	DECLARE @Cod_Actividad varchar(32)
	DECLARE @Notas varchar(512)
	DECLARE @Fecha_Inicio datetime
	DECLARE @Fecha_Fin datetime
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Id_Cronometro,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Id_Cronometro,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Id_Cronometro), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Id_Cronometro,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Id_Cronometro,
			 i.Cod_Proyecto,
			 i.Cod_Actividad,
			 i.Notas,
			 i.Fecha_Inicio,
			 i.Fecha_Fin,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Cronometro,
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Notas,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Cronometro,'|' ,
			 @Cod_Proyecto,'|' ,
			 @Cod_Actividad,'|' ,
			 @Notas,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Id_Cronometro), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Cronometro,
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Notas,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Cronometro,
			 d.Cod_Proyecto,
			 d.Cod_Actividad,
			 d.Notas,
			 d.Fecha_Inicio,
			 d.Fecha_Fin,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Cronometro,
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Notas,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Cronometro,'|' ,
			 @Cod_Proyecto,'|' ,
			 @Cod_Actividad,'|' ,
			 @Notas,'|' ,
			 CONVERT(varchar,@Fecha_Inicio,121), '|' ,
			 CONVERT(varchar,@Fecha_Fin,121), '|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Id_Cronometro), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Cronometro,
			 @Cod_Proyecto,
			 @Cod_Actividad,
			 @Notas,
			 @Fecha_Inicio,
			 @Fecha_Fin,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--TAR_PROYECTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_TAR_PROYECTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_TAR_PROYECTOS_IUD
GO

CREATE TRIGGER UTR_TAR_PROYECTOS_IUD
ON dbo.TAR_PROYECTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Proyecto varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='TAR_PROYECTOS'
	--Variables de tabla secundarias
	DECLARE @Nom_Proyecto varchar(512)
	DECLARE @Cod_Area varchar(32)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Proyecto,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Proyecto,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT('',@Cod_Proyecto), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Proyecto,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Proyecto,
			 i.Nom_Proyecto,
			 i.Cod_Area,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Proyecto,
			 @Nom_Proyecto,
			 @Cod_Area,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Proyecto,'|' ,
			 @Nom_Proyecto,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@Cod_Proyecto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Proyecto,
			 @Nom_Proyecto,
			 @Cod_Area,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Proyecto,
			 d.Nom_Proyecto,
			 d.Cod_Area,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Proyecto,
			 @Nom_Proyecto,
			 @Cod_Area,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Proyecto,'|' ,
			 @Nom_Proyecto,'|' ,
			 @Cod_Area,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@Cod_Proyecto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Proyecto,
			 @Nom_Proyecto,
			 @Cod_Area,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO


--Metodo de exportacion
--exec USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento 'PALERPpuquin','PALERPlink'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento' AND type = 'P')
DROP PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento
GO
CREATE PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento
@NombreBD varchar(max),
@LinkedServer varchar(max)
AS
BEGIN
	--Variables generales 
	DECLARE @cmd sysname
	--DECLARE @NombreBD VARCHAR(MAX)=(SELECT DISTINCT vce.BD_Remota FROM dbo.VIS_CONFIGURACION_EXPORTACION vce WHERE vce.Habilitado=1)
	--DECLARE @LinkedServer varchar(max)=(SELECT DISTINCT vce.Linked_Server FROM dbo.VIS_CONFIGURACION_EXPORTACION vce WHERE vce.Habilitado=1)
	--Recuperamos las variables principales
	DECLARE @Id varchar(max)
	DECLARE @Nombre_Tabla varchar(max) 
	DECLARE @Id_Fila varchar(max) 
	DECLARE @Accion varchar(max) 
	DECLARE @Script varchar(max) 
	DECLARE @Fecha_Reg datetime 
	--Recuperamos el primer objeto de la cola y almacenamos en las variables
	SELECT TOP 1
	    @Id=trl.Id, 
	    @Nombre_Tabla=trl.Nombre_Tabla, 
	    @Id_Fila=trl.Id_Fila, 
	    @Accion=trl.Accion, 
	    @Script=trl.Script, 
	    @Fecha_Reg=trl.Fecha_Reg 
	FROM dbo.TMP_REGISTRO_LOG trl
	ORDER BY trl.Id

	IF @Id IS NOT NULL
	BEGIN
	    BEGIN TRY  
			 SET @Script=@LinkedServer+'.'+@NombreBD+'.dbo.'+@Script
			 EXECUTE(@Script) ;
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
			 DECLARE @ErrorMessage NVARCHAR(4000);  
			 SELECT  @ErrorMessage = CONCAT('Ocurrio un error en : ', @Nombre_Tabla,CHAR(13),CHAR(10) )  + ERROR_MESSAGE() 
			 RAISERROR(@ErrorMessage,16,1)
		END CATCH;  
	END
END
GO
 
--Modificamos los datos de los correos de exportacion
IF EXISTS (SELECT vc.* FROM dbo.VIS_CORREOS vc WHERE vc.Tipo_Uso='EXPORTACION' AND vc.Estado=1)
BEGIN
    --DECLARE @maxFila int 
    --IF EXISTS (SELECT * FROM dbo.PAR_FILA pf WHERE pf.Cod_Tabla='118' AND pf.Cod_Columna='004' AND pf.Cadena='EXPORTACION')
    --BEGIN
    DECLARE @maxFila int =(SELECT max(pf.Cod_Fila) FROM dbo.PAR_FILA pf WHERE pf.Cod_Tabla='118' AND pf.Cod_Columna='004' AND pf.Cadena='EXPORTACION')
    --END
    --ELSE
    --BEGIN
	   --SET @maxFila=1
    --END
    EXEC USP_PAR_FILA_G '118','001',@maxFila,'PALERP',NULL,NULL,NULL,NULL,1,'MIGRACION';--Nuevo servidor de correo
    EXEC USP_PAR_FILA_G '118','002',@maxFila,'reg-errores@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';--Nuevo correo e
    EXEC USP_PAR_FILA_G '118','003',@maxFila,'reg-errores321',NULL,NULL,NULL,NULL,1,'MIGRACION'; --Paswword del nuevo correo
END
GO
IF EXISTS (SELECT vce.* FROM dbo.VIS_CONFIGURACION_EXPORTACION vce WHERE vce.Habilitado=1)
BEGIN
    EXEC USP_PAR_FILA_G '120','005',1,'reg-errores@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';--Nuevo correo de recepcion
END
GO

--Creamos un procedimiento de mantenimiento para las tablas de auditoria
--Se borran automaticamente todos los registros con una difernecia de 1 año
--ademas de borrar el log de transacciones,
--Ademas crea o modifica los procedimientos de triggers sobre auditoria
--Tiene una frecuencia de cada 1 dia
--Borramnos la tare si existia anteriormente
DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = 'Mantenimiento Auditoria'))
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END

SET @jobId=null
--Agregamos la tarea
EXEC msdb.dbo.sp_add_job @job_name='Mantenimiento Auditoria', @enabled=1, @owner_login_name=N'sa', @job_id = @jobId OUTPUT
--Agregamos el paso 
DECLARE @BDActual varchar(512) ='PALERP_Auditoria'
DECLARE @Comando varchar(MAX)= '
ALTER DATABASE PALERP_Auditoria
SET RECOVERY SIMPLE;
GO
--Reducimos el log de transacciones a  1 MB.
DBCC SHRINKFILE(PALERP_Auditoria, 1);
GO
--Cambiamos nuevamente el modelo de recuperación a Completo.
ALTER DATABASE PALERP_Auditoria
SET RECOVERY FULL;
GO
IF EXISTS (SELECT name
 	   FROM   sysobjects 
 	   WHERE  name = N'+''''+'UTR_Auditoria_UD'+''''+'
 	   AND 	  type = '+''''+'TR'+''''+')
     BEGIN
	   DROP TRIGGER UTR_Auditoria_UD
	   DELETE dbo.PRI_AUDITORIA WHERE DATEDIFF(year,dbo.PRI_AUDITORIA.Fecha_Reg, getdate())>1
     END
GO
CREATE TRIGGER  UTR_Auditoria_UD 
ON PRI_AUDITORIA 
WITH ENCRYPTION
INSTEAD OF UPDATE,DELETE 
AS 
BEGIN 
    RAISERROR ('+''''+'Edicion y eliminacion no estan permitidos'+''''+', 16, 1)   
END 
'

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mantenimiento Auditoria', 
	   @step_id=1, 
	   @retry_attempts=10, 
	   @retry_interval=1, 
	   @os_run_priority=1, @subsystem=N'TSQL', 
	   @command=@Comando, 
	   @database_name=@BDActual, 
	   @output_file_name=N'C:\APLICACIONES\TEMP\log_mantenimiento.txt',
	   @flags=2

--Agregamos las frecuencias Diario a una hora predeterminada
DECLARE @FechaActual varchar(20) = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Mantenimiento', 
	   @enabled=1, 
	   @freq_type=4, 
	   @freq_interval=1, 
	   @freq_subday_type=1, 
	   @freq_subday_interval=0, 
	   @freq_relative_interval=0, 
	   @freq_recurrence_factor=0, 
	   @active_start_date=@FechaActual, 
	   @active_end_date=99991231, 
	   @active_start_time=120000,
	   @schedule_id=1

--Agregamos el jobserver
EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
--Ejecutamos el job
EXEC msdb.dbo.sp_start_job N'Mantenimiento Auditoria'  
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


----Actualziamos todos las tablas en orden relacional, solo para servidores nuevos que
----necesitan ser replicados en uno principal
--UPDATE dbo.PRI_MENSAJES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.TAR_ALERTAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_DESCUENTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_AFP_PRIMA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_TIPOCAMBIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_TRANSFERENCIAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_SERIES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAL_CALENDARIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAL_DOCUMENTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_MODULO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PERFIL
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PERFIL_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_USUARIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAR_TABLA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAR_COLUMNA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAR_FILA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CON_PLANTILLA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CON_PLANTILLA_ASIENTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CON_PLANTILLA_ASIENTO_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.TAR_PROYECTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.TAR_ACTIVIDADES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.TAR_CRONOMETROS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_GUIA_REMISION
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_GUIA_REMISION_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_PROVEEDOR
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_ACTIVIDADES_ECONOMICAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_VEHICULOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CUE_TARJETAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_CUENTABANCARIA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_ESTABLECIMIENTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PADRONES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CUE_CLIENTE_CUENTA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CUE_CLIENTE_CUENTA_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--UPDATE dbo.CUE_CLIENTE_CUENTA_M
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_CONTACTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_VISITAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_CONCEPTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CON_ASIENTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CUENTA_CONTABLE
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CON_ASIENTO_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAT_GRUPOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAT_GRUPOS_CARACTERISTICAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAT_BIENES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAT_BIENES_CARACTERISTICAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PAT_BIENES_MOVIMIENTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_SUCURSAL
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO

--UPDATE dbo.PRI_AREAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO

--UPDATE dbo.PRI_PERSONAL
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PERSONAL_PARENTESCO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_BIOMETRICO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_HORARIOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_ASISTENCIA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_PERSONAL_HORARIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO 
--UPDATE dbo.PLA_CONCEPTOS_PLANILLA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_PLANILLA_TIPO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_PLANILLA_TIPO_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_PLANILLA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_PLANILLA_TIPO_PERSONAL
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_BOLETA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PLA_CONTRATOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.BAN_CUENTA_BANCARIA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_CAJAS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_CAJAS_DOC
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_TURNO_ATENCION
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.BAN_CUENTA_M
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_ARQUEOFISICO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_ARQUEOFISICO_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_ARQUEOFISICO_SALDO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_CAJA_MOVIMIENTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_MEDICION_VC
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CATEGORIA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTOS
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.ALM_ALMACEN
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTO_STOCK
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_CAJA_ALMACEN
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.ALM_ALMACEN_MOV
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.ALM_ALMACEN_MOV_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTO_PRECIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.ALM_INVENTARIO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.ALM_INVENTARIO_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTO_DETALLE
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTO_TASA
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_CLIENTE_PRODUCTO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_PRODUCTO_IMAGEN
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_COMPROBANTE_PAGO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_FORMA_PAGO
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_COMPROBANTE_LOG
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_COMPROBANTE_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.CAJ_COMPROBANTE_RELACION
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_LICITACIONES
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_LICITACIONES_D
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO
--UPDATE dbo.PRI_LICITACIONES_M
--SET
--    Cod_UsuarioAct = 'MIGRACION', 
--    Fecha_Act = GETDATE()
--GO

--Scripts de emergencia en caso de error
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_ALMACEN_MOV_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_ALMACEN_MOV_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_INVENTARIO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_INVENTARIO_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_INVENTARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_INVENTARIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_BAN_CUENTA_BANCARIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_BAN_CUENTA_BANCARIA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_BAN_CUENTA_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_BAN_CUENTA_M_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_SALDO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJA_ALMACEN_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJA_ALMACEN_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJA_MOVIMIENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJA_MOVIMIENTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJAS_DOC_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJAS_DOC_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_LOG_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_LOG_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_PAGO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_RELACION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CONCEPTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CONCEPTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_FORMA_PAGO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_FORMA_PAGO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_GUIA_REMISION_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_GUIA_REMISION_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_GUIA_REMISION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_GUIA_REMISION_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_IMPUESTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_IMPUESTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_MEDICION_VC_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_MEDICION_VC_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_SERIES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_SERIES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TIPOCAMBIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TIPOCAMBIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TRANSFERENCIAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TRANSFERENCIAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TURNO_ATENCION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TURNO_ATENCION_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAL_CALENDARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAL_CALENDARIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAL_DOCUMENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAL_DOCUMENTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_ASIENTO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_ASIENTO_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_ASIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_ASIENTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_ASIENTO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_ASIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_M_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_TARJETAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_TARJETAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_COLUMNA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_COLUMNA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_FILA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_FILA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_TABLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_TABLA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_CARACTERISTICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_CARACTERISTICAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_MOVIMIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_MOVIMIENTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_GRUPOS_CARACTERISTICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_GRUPOS_CARACTERISTICAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_GRUPOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_GRUPOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_AFP_PRIMA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_AFP_PRIMA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_ASISTENCIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_ASISTENCIA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_BIOMETRICO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_BIOMETRICO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_BOLETA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_BOLETA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_CONCEPTOS_PLANILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_CONCEPTOS_PLANILLA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_CONTRATOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_CONTRATOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_HORARIOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_HORARIOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PERSONAL_HORARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PERSONAL_HORARIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_AREAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_AREAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CATEGORIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CATEGORIA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_CONTACTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_CONTACTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_CUENTABANCARIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_CUENTABANCARIA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_PRODUCTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_PRODUCTO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_PROVEEDOR_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_VEHICULOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_VEHICULOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_VISITAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_VISITAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CUENTA_CONTABLE_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CUENTA_CONTABLE_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_DESCUENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_DESCUENTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_EMPRESA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_EMPRESA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_ESTABLECIMIENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_ESTABLECIMIENTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_M_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_MENSAJES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_MENSAJES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_MODULO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_MODULO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PADRONES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PADRONES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERFIL_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERFIL_D_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERFIL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERFIL_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERSONAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERSONAL_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERSONAL_PARENTESCO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERSONAL_PARENTESCO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_DETALLE_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_DETALLE_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_IMAGEN_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_IMAGEN_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_PRECIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_PRECIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_STOCK_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_TASA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_TASA_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTOS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_SUCURSAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_SUCURSAL_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_USUARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_USUARIO_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_ACTIVIDADES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_ACTIVIDADES_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_ALERTAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_ALERTAS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_CRONOMETROS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_CRONOMETROS_IUD
--IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_PROYECTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_PROYECTOS_I