
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
    EXEC USP_PAR_FILA_G '120','001',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','002',1,@NombreEmpresa,NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','003',1,'PALERPlink',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','004',1,@Nombre_BD,NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '120','005',1,'reg-errores@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';
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
    EXEC USP_PAR_FILA_G '118','002',@maxFila,'reg-errores@palerp.com',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','003',@maxFila,'reg-errores321',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','004',@maxFila,'EXPORTACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
    EXEC USP_PAR_FILA_G '118','005',@maxFila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END

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


--Triggers

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
AFTER INSERT,UPDATE
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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
	DECLARE @Foto binary
	DECLARE @Firma binary
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
END
GO

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
AFTER INSERT,UPDATE
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
AFTER INSERT,UPDATE
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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
			--   SELECT @Script='USP_CAJ_COMPROBANTE_D_I '+ 
			--   CASE WHEN P.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_Libro,'''','')+''',' END +
			--   CASE WHEN P.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoComprobante,'''','')+''',' END +
			--   CASE WHEN P.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Serie,'''','')+''',' END +
			--   CASE WHEN P.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Numero,'''','')+''',' END +	
			--   CASE WHEN P.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Cod_TipoDoc,'''','')+''',' END +
			--   CASE WHEN P.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(P.Doc_Cliente,'''','')+''',' END +
			--   CONVERT(VARCHAR(MAX),D.id_Detalle)+','+ 
			--   CASE WHEN PP.Cod_Producto IS NULL THEN 'NULL,' ELSE ''''+REPLACE(PP.Cod_Producto,'''','')+''',' END +
			--   CASE WHEN D.Cod_Almacen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_Almacen,'''','')+''',' END +
			--   CASE WHEN D.Cantidad IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Cantidad)+','END+
			--   CASE WHEN D.Cod_UnidadMedida IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_UnidadMedida,'''','')+''',' END +
			--   CASE WHEN D.Despachado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Despachado)+','END+
			--   CASE WHEN D.Descripcion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Descripcion,'''','')+''',' END +
			--   CASE WHEN D.PrecioUnitario IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.PrecioUnitario)+','END+ 
			--   CASE WHEN D.Descuento IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Descuento)+','END+
			--   CASE WHEN D.Sub_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Sub_Total)+','END+ 
			--   CASE WHEN D.Tipo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Tipo,'''','')+''',' END +
			--   CASE WHEN D.Obs_ComprobanteD IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Obs_ComprobanteD,'''','')+''',' END +
			--   CASE WHEN D.Cod_Manguera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_Manguera,'''','')+''',' END + 
			--   CONVERT(VARCHAR(MAX),D.Flag_AplicaImpuesto)+','+ 
			--   CASE WHEN D.Formalizado IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Formalizado)+','END+ 
			--   CASE WHEN D.Valor_NoOneroso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Valor_NoOneroso)+','END+ 
			--   CASE WHEN D.Cod_TipoISC IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_TipoISC,'''','')+''',' END +
			--   CASE WHEN D.Porcentaje_ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_ISC)+','END+ 
			--   CASE WHEN D.ISC IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.ISC)+','END+ 
			--   CASE WHEN D.Cod_TipoIGV IS NULL THEN 'NULL,' ELSE ''''+REPLACE(D.Cod_TipoIGV,'''','')+''',' END +
			--   CASE WHEN D.Porcentaje_IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.Porcentaje_IGV)+','END+ 
			--   CASE WHEN D.IGV IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),D.IGV)+','END+ 
			--   ''''+REPLACE(COALESCE(D.Cod_UsuarioAct,D.Cod_UsuarioReg),'''','')+''';' 
			--   FROM INSERTED D INNER JOIN
			-- 	   CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
			-- 	   PRI_PRODUCTOS AS PP ON D.Id_Producto = PP.Id_Producto
			--   WHERE D.id_ComprobantePago=@id_ComprobantePago AND D.id_Detalle=@id_Detalle

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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
AFTER INSERT,UPDATE
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
			  CASE WHEN CP.Valor_Resumen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Resumen,'''','')+''',' END +
			  CASE WHEN CP.Valor_Firma IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Firma,'''','')+''',' END +
			  CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_EstadoComprobante,'''','')+''',' END +
			  CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.MotivoAnulacion,'''','')+''',' END +
			  CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
			  CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
			  ''''+REPLACE(COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg),'''','')+ ''';' 	 
			  FROM            INSERTED   CP 
			  WHERE CP.id_ComprobantePago=@id_ComprobantePago


		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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

		   	SET @FechaReg= COALESCE(@Fecha_Act,@Fecha_Reg,GETDATE())
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
END
GO



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

--Crear mantenimientos programados automaticamente

--Crea una copia de seguridad de una BD determinada
--exec USP_Crear_CopiaSeguridad PALERPquillabamba,N'D:\COPIA_SEGURIDAD','bak'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_Crear_CopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_Crear_CopiaSeguridad
go
CREATE PROCEDURE USP_Crear_CopiaSeguridad
@BDActual varchar(MAX),
@RutaBackup varchar(MAX),
@Extension varchar(MAX)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @NombreArchivo as Varchar(MAX)= CONCAT( @RutaBackup,CHAR(92),@BDActual,'_',replace(CONVERT(VARCHAR,GETDATE(),103),'/','') ,'_',replace(CONVERT(VARCHAR,GETDATE(),108),':',''),'.',@Extension)
	DECLARE @NombreCopia varchar(MAX)=CONCAT(@BDActual,'-Completa Base de datos Copia de seguridad')
	BACKUP DATABASE @BDActual
	TO  DISK = @NombreArchivo
	WITH NOFORMAT, NOINIT,  NAME = @NombreCopia, SKIP, 
	NOREWIND, NOUNLOAD,  STATS = 10, COMPRESSION
END
go

-- --Crea una copia de seguridad de la BD donde se ejecuta
-- --exec USP_Crear_CopiaSeguridadPorDefecto N'D:\COPIA_SEGURIDAD','bak'
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_Crear_CopiaSeguridadPorDefecto' AND type = 'P')
-- DROP PROCEDURE USP_Crear_CopiaSeguridadPorDefecto
-- go
-- CREATE PROCEDURE USP_Crear_CopiaSeguridadPorDefecto
-- @RutaBackup varchar(MAX),
-- @Extension varchar(MAX)
-- WITH ENCRYPTION
-- AS
-- BEGIN
--     DECLARE @BDActual varchar(MAX)=(SELECT DB_NAME() AS [Base de datos actual])
--     DECLARE @NombreArchivo as Varchar(MAX)= CONCAT( @RutaBackup,CHAR(92),@BDActual,'_',replace(CONVERT(VARCHAR,GETDATE(),103),'/','') ,'_',replace(CONVERT(VARCHAR,GETDATE(),108),':',''),'.',@Extension)
--     DECLARE @NombreCopia varchar(MAX)=CONCAT(@BDActual,'-Completa Base de datos Copia de seguridad')
--     BACKUP DATABASE @BDActual
--     TO  DISK = @NombreArchivo
--     WITH NOFORMAT, NOINIT,  NAME = @NombreCopia, SKIP, 
--     NOREWIND, NOUNLOAD,  STATS = 10, COMPRESSION
-- END
-- go

--Obtiene la informacion del servidor actual, incluida el nombre de la bd desde donde se ejecuta
--exec USP_ObtenerDatos_Servidor
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



--Crea un procedimiento por el cual se pueden crear tareas programadas, ejecutar sobre la bd destino
--En la ruta C:\APLICACIONES\TEMP y con extension palerp
--Crea dos copias, por defecto a las 0 y a las 12 horas 
--NumeroIntentos entero el nuemro de intentos , si es 0 si reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--HoraPrimeraCopia,HoraSegundaCopia entero que indica la hora en que sucede la copia
--tiene el formato de 24 horas de la siguiente forma HHMMSS (ej 235958- Copia a las 23 horas 59 minutos 58 segundos)
--exec USP_CrearTareaCopiaSeguridad N'COPIA 1',2,60,0,235959
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaCopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_CrearTareaCopiaSeguridad
go
CREATE PROCEDURE USP_CrearTareaCopiaSeguridad
@NombreTarea varchar(max)=N'COPIA DE SEGURIDAD',
@NumeroIntentos int = 0,
@IntervaloMinutos int = 0,
@HoraPrimeraCopia int = 0,
@HoraSegundaCopia int = 235959
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
	DECLARE @Comando varchar(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ',@BDActual,N',N''C:\APLICACIONES\TEMP''',',palerp')
	EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COPIA DE SEGURIDAD', 
			@step_id=1, 
			@retry_attempts=@NumeroIntentos, 
			@retry_interval=@IntervaloMinutos, 
			@os_run_priority=1, @subsystem=N'TSQL', 
			@command=@Comando, 
			@database_name=@BDActual, 
			@output_file_name=N'C:\APLICACIONES\TEMP\log_mantenimiento.txt',
			@flags=2

	--Agregamos las frecuencias Diario a una hora predeterminada
	DECLARE @FechaActual varchar(20) = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'PRIMERA COPIA', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@HoraPrimeraCopia,
			@schedule_id=1

	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SEGUNDA COPIA', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@HoraSegundaCopia,
			@schedule_id=1

	--Agregamos el jobserver
	EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
END
go



--Procedimiento que elimina una tarea copia de seguridad
--exec USP_EliminarTareaCopiaSeguridad N'COPIA 1'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_EliminarTareaCopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_EliminarTareaCopiaSeguridad
go
CREATE PROCEDURE USP_EliminarTareaCopiaSeguridad
@NombreTarea varchar(max)
WITH ENCRYPTION
AS
BEGIN
	--Borramnos la tare si existia anteriormente
	DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = @NombreTarea))
	IF (@jobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @jobId
	END
END
go


--Procedimiento que elimina los bakups antiguos
--Path = ruta donde estan los bakups
--Extension= extension de los archivo sin punto
--Tiempo en horas par aeliminar los backups antiguos
--exec USP_EliminarBackupsAntiguos N'C:\APLICACIONES\TEMP',bak,720
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_EliminarBackupsAntiguos' AND type = 'P')
DROP PROCEDURE USP_EliminarBackupsAntiguos
go
CREATE PROCEDURE USP_EliminarBackupsAntiguos
	@path NVARCHAR(256),
	@Extension NVARCHAR(10),
	@TiempoHoras INT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @DeleteDate NVARCHAR(50)
	DECLARE @DeleteDateTime DATETIME
	SET @DeleteDateTime = DateAdd(hh, - @TiempoHoras, GetDate())
	SET @DeleteDate = (Select Replace(Convert(nvarchar, @DeleteDateTime, 111), '/', '-') + 'T' + Convert(nvarchar, @DeleteDateTime, 108))
	EXECUTE master.dbo.xp_delete_file 0,
		@path,
		@extension,
		@DeleteDate,
		1
END
go


--Crea un procedimiento por el cual se pueden eliminar copias de seguridad en una tarea, ejecutar sobre la bd destino
--En la ruta C:\APLICACIONES\TEMP y con extension palerp
--Crea una copias, por defecto las 12 horas 
--NumeroIntentos entero el numero de intentos , si es 0 sin reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--Hora entero que indica la hora en que sucede la copia
--tiene el formato de 24 horas de la siguiente forma HHMMSS (ej 235958- Copia a las 23 horas 59 minutos 58 segundos)
--exec USP_CrearTareaEliminarCopiasSeguridad N'ELIMINAR COPIA DE SEGURIDAD',0,0,120000
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaEliminarCopiasSeguridad' AND type = 'P')
DROP PROCEDURE USP_CrearTareaEliminarCopiasSeguridad
go
CREATE PROCEDURE USP_CrearTareaEliminarCopiasSeguridad
@NombreTarea varchar(max)=N'ELIMINAR COPIA DE SEGURIDAD',
@NumeroIntentos int = 0,
@IntervaloMinutos int = 0,
@Hora int = 12000
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
	DECLARE @Comando varchar(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos ',N'N''C:\APLICACIONES\TEMP''',',palerp,720')
	EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ELIMINAR COPIAS', 
			@step_id=1, 
			@retry_attempts=@NumeroIntentos, 
			@retry_interval=@IntervaloMinutos, 
			@os_run_priority=1, @subsystem=N'TSQL', 
			@command=@Comando, 
			@database_name=@BDActual, 
			@output_file_name=N'C:\APLICACIONES\TEMP\log_mantenimiento.txt',
			@flags=2

	--Agregamos las frecuencias Diario a una hora predeterminada
	DECLARE @FechaActual varchar(20) = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ELIMINAR', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@Hora,
			@schedule_id=1

	--Agregamos el jobserver
	EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
END
go

--Ejecutamos los procedimientos
exec USP_CrearTareaCopiaSeguridad N'COPIA DE SEGURIDAD',2,60,080000,200000
exec USP_CrearTareaEliminarCopiasSeguridad N'ELIMINAR COPIA DE SEGURIDAD',0,0,120000


--Script de prueba
--SELECT  DISTINCT CONCAT((FORMAT(datepart(hour, DATEADD(hour,-1,cta.Fecha_Inicio)),'00')),(FORMAT(datepart(Minute, cta.Fecha_Inicio),'00')),(FORMAT(datepart(second, cta.Fecha_Inicio),'00'))) AS Hora FROM dbo.CAJ_TURNO_ATENCION cta

--SELECT  DISTINCT CONCAT((FORMAT(datepart(hour, DATEADD(hour,-1,cta.Fecha_Inicio)),'00')),'00','00') AS Hora FROM dbo.CAJ_TURNO_ATENCION cta
--where Des_Turno not like '%CIERRE%' and Cod_Turno not LIke 'C%'
