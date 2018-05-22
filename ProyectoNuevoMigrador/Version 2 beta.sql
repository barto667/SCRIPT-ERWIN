
--Activar

-- 1 go to Services. (START > SETTINGS > CONTROL PANEL > ADMINISTRATIVE TOOLS > SERVICES)
-- 2 Find the service called 'Distributed Transaction Coordinator' and RIGHT CLICK (on it and select) > Start.
-- 3 make this service to run Automatically for solving this issue permanently
-- https://stackoverflow.com/questions/29414250/msdtc-on-server-server-is-unavailable
-- opcion 2
-- REG QUERY "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccess
-- REG QUERY "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessTransactions
-- REG QUERY "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessInbound
-- REG QUERY "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessOutbound
-- PAUSE

-- REG ADD "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccess /t REG_DWORD /d 1
-- REG ADD "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessTransactions /t REG_DWORD /d 1
-- REG ADD "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessInbound /t REG_DWORD /d 1
-- REG ADD "HKLM\Software\Microsoft\MSDTC\Security" /v NetworkDtcAccessOutbound /t REG_DWORD /d 1
-- PAUSE

-- net stop MSDTC
-- net start MSDTC
-- PAUSE



--Creamos nuestra tabla temporal donde se insertan los datos de las inserciones, modificaciones y eliminacion
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_COMPROBANTE_REGISTRO_LOG' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_COMPROBANTE_REGISTRO_LOG (
	Id int IDENTITY(1,1)  PRIMARY KEY,
	Nombre_Tabla varchar(max) ,
	Id_Compropante_Pago int , 
	Id_Item int ,
	Accion varchar(max) ,
	Fecha_Reg datetime )
END
GO

--Creamos nuestra tabla temporal donde se almacenen el historial de los datos
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_COMPROBANTE_REGISTRO_LOG_H' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_COMPROBANTE_REGISTRO_LOG_H (
	Id int IDENTITY(1,1)  PRIMARY KEY,
	Nombre_Tabla varchar(max) ,
	Id_Compropante_Pago int , 
	Id_Item int ,
	Accion varchar(max) ,
	Fecha_Reg datetime ,
	Fecha_Reg_Insercion datetime)
END
GO

--PROCEDIMIENTO DE GUARDADO
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_COMPROBANTE_REGISTRO_LOG_G' 
	 AND type = 'P'
)
DROP PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_G
GO
CREATE  PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_G 
	@NombreTabla varchar(MAX), 
	@Id_Compropante_Pago	int, 
	@Id_Item int,
	@Accion	varchar(max), 
	@Fecha_Reg	datetime
WITH ENCRYPTION
AS
BEGIN
	INSERT dbo.TMP_COMPROBANTE_REGISTRO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    @NombreTabla, -- Nombre_Tabla - varchar
	    @Id_Compropante_Pago, -- Id_Compropante_Pago - int
	    @Id_Item, -- Id_Item - int
	    @Accion, -- Accion - varchar
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

--Creamos los triggers

--PRI_CLIENTE_PROVEEDOR

--Creamos el trigger despues del insert sobre PRI_CLIENTE_PROVEEDOR para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_CAJ_COMPROBANTE_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.PRI_CLIENTE_PROVEEDOR
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int = 0
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.Id_ClienteProveedor,@FechaAux=i.Fecha_Reg FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'PRI_CLIENTE_PROVEEDOR'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'INSERTAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO
 
--Creamos el trigger despues del update sobre caj_comprobante_pago para 
--Actualizar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PROVEEDOR_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_UPDATE_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.PRI_CLIENTE_PROVEEDOR
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int = 0
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.Id_ClienteProveedor,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'PRI_CLIENTE_PROVEEDOR'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'ACTUALIZAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO



--PRI_PRODUCTOS

--Creamos el trigger despues del insert sobre PRI_PRODUCTOS para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTOS_FOR_INSERT_CAJ_COMPROBANTE_LOG'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTOS_FOR_INSERT_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_PRI_PRODUCTOS_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.PRI_PRODUCTOS
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int = 0
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.Id_Producto,@FechaAux=i.Fecha_Reg FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'PRI_PRODUCTOS'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'INSERTAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO
 
--Creamos el trigger despues del update sobre caj_comprobante_pago para 
--Actualizar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTOS_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTOS_FOR_UPDATE_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_PRI_PRODUCTOS_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.PRI_PRODUCTOS
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int = 0
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.Id_Producto,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'PRI_PRODUCTOS'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'ACTUALIZAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO



--CAJ_COMPROBANTE_PAGO

--Creamos el trigger despues del insert sobre caj_comprobante_pago para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_PAGO
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.Id_Cliente,@FechaAux=i.Fecha_Reg FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_PAGO'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'INSERTAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO
 
--Creamos el trigger despues del update sobre caj_comprobante_pago para 
--Actualizar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_PAGO
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.Id_Cliente,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_PAGO'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'ACTUALIZAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO


--CAJ_COMPROBANTE_D

--Creamos el trigger despues del insert sobre caj_comprobante_d para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_D
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.id_Detalle,@FechaAux=i.Fecha_Reg FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_D'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'INSERTAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO
 
--Creamos el trigger despues del update sobre caj_comprobante_D para 
--Actualizar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_D
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.id_Detalle,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_D'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'ACTUALIZAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO


--CAJ_COMPROBANTE_RELACION

--Creamos el trigger despues del insert sobre caj_comprobante_d para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_RELACION
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.id_Detalle,@FechaAux=i.Fecha_Reg FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_RELACION'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'INSERTAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO
 
--Creamos el trigger despues del update sobre caj_comprobante_pago para 
--Actualizar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG

GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_RELACION
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Id_secundario int
	DECLARE @FechaAux datetime
 	SELECT  @id_aux=i.id_ComprobantePago,@Id_secundario=i.id_Detalle,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	DECLARE @Sentencia varchar(max)='[PALERregistro].[PALERPpuquin].dbo.USP_TMP_COMPROBANTE_REGISTRO_LOG_G '+
	''''+'CAJ_COMPROBANTE_RELACION'+''''+','+
	CONVERT(varchar(max),@id_aux)+','+
	CONVERT(varchar(max),@Id_secundario)+','+
	''''+'ACTUALIZAR'+''''+','+
	''''+CONVERT(varchar(max),@FechaAux,121)+''''+';'
	EXECUTE(@Sentencia)
END
GO


----Creamos procedimiento almacenado para recuperar el primer objeto
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_TMP_COMPROBANTE_REGISTRO_LOG_RecuperarPrimerElemento' AND type = 'P')
--DROP PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_RecuperarPrimerElemento
--go
--CREATE PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_RecuperarPrimerElemento
--AS
--BEGIN
--	--Recuperamos las variables principales
--	DECLARE @Id int
--	DECLARE @Nombre_Tabla varchar(max) 
--	DECLARE @Id_Compropante_Pago int 
--	DECLARE @Id_Item int 
--	DECLARE @Accion varchar(max) 
--	DECLARE @Fecha_Reg datetime 
--	--Recuperamos el primer objeto de la cola y almacenamos en las variables
--	SELECT TOP 1 @Id=tcrl.Id,@Nombre_Tabla=tcrl.Nombre_Tabla,
--	@Id_Compropante_Pago=tcrl.Id_Compropante_Pago,@Id_Item=tcrl.Id_Item,
--	@Accion=tcrl.Accion,@Fecha_Reg=tcrl.Fecha_Reg
--	FROM dbo.TMP_COMPROBANTE_REGISTRO_LOG tcrl
--	ORDER BY tcrl.Id

--	--De acuerdo al elemento que queremos recuperar mostramos una tabla
--	--Recuperar elemento tipo CAJ_COMPROBANTE_PAGO


--END
--GO


--Actualizar metodo para registrar inserciones en comporobante_relacion

--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 31/07/2015
-- OBJETIVO: Extorna el Movimiento hecho en ComprobantePago
-- exec USP_CAJ_COMPROBANTE_PAGO_EXTORNAR 511135,'102','02/01/2017','2017-01-03','RPALMA','ERROR EN EL MONTO'
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_EXTORNAR' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_EXTORNAR
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_EXTORNAR
@id_ComprobantePago int OUTPUT,
@Cod_Caja  varchar(32), 
@Cod_Turno  varchar(32), 
@Fecha  datetime,
@Cod_Usuario  varchar(32),
@MotivoAnulacion varchar(512)
WITH ENCRYPTION
AS
BEGIN

BEGIN TRANSACTION;  
  
BEGIN TRY      
	DECLARE @Id_Producto  int, @Signo  int, 
	@Cod_Almacen  varchar(32), 
	@Cod_UnidadMedida  varchar(5), 
	@Despachado  numeric(38,6),
	@Cod_TipoComprobante  varchar(5),
	@Serie  varchar(5),
	@Numero  varchar(15),
	@id_ComprobantePagoAnulado as int;

IF EXISTS(SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_RELACION
							 WHERE (Id_ComprobanteRelacion = @id_ComprobantePago) AND Cod_TipoRelacion = 'CRE' )
begin
	RAISERROR ('Este Comprobante ya Tiene una Nota de Credito.',16,1);  
	--SELECT 0
end
else
IF NOT EXISTS(SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Libro = '14') 
			AND (Cod_TipoComprobante IN ('NCE','NDE')) )
BEGIN
	-- SI O SI SE EJECUTA PARA TODOS LOS CASOS
	UPDATE CAJ_FORMA_PAGO
	SET Monto = 0, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
	WHERE (id_ComprobantePago = @id_ComprobantePago) 

	UPDATE ALM_ALMACEN_MOV_D
	SET Precio_Unitario = 0, Cantidad = 0, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
	WHERE (Id_AlmacenMov IN (SELECT Id_AlmacenMov  FROM ALM_ALMACEN_MOV WHERE Id_ComprobantePago = @Id_ComprobantePago))

	UPDATE ALM_ALMACEN_MOV
	SET Motivo = 'ANULADO', Flag_Anulado = 1, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
	WHERE Id_ComprobantePago = @Id_ComprobantePago

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


	IF NOT EXISTS(SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Libro = '14') 
				AND (Cod_TipoComprobante IN ('FE','BE')) )
	BEGIN
		-- en el caso de TKB O TKF O DEMAS DOCUMENTOS
		UPDATE CAJ_COMPROBANTE_PAGO SET Glosa = 'ANULADO', Flag_Anulado = 1, Descuento_Total = 0, Impuesto = 0, Total = 0, 
		Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE(), MotivoAnulacion = @MotivoAnulacion
		WHERE (id_ComprobantePago = @id_ComprobantePago)
	
		UPDATE CAJ_COMPROBANTE_D
		SET Cantidad = 0, Despachado = 0, PrecioUnitario = 0, Sub_Total = 0, Formalizado = 0, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago)
	END
	-- INSERTAR SI EN EL CASO QUE FUERA UNA 
	IF EXISTS(SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Libro = '14') 
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
		@MotivoAnulacion , Otros_Cargos , Otros_Tributos ,
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

		IF EXISTS(SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE (id_ComprobantePago = @id_ComprobantePago) AND (Cod_Libro = '14') 
					AND (Cod_TipoComprobante in('FE', 'BE')) )
		BEGIN			
			UPDATE CAJ_COMPROBANTE_PAGO SET Glosa = 'ANULADO',Cod_FormaPago = '004' ,
			Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE(), MotivoAnulacion = @MotivoAnulacion
			WHERE (id_ComprobantePago = @id_ComprobantePago)

			SELECT @Cod_TipoComprobante=Cod_TipoComprobante , @Serie=Serie
			FROM CAJ_COMPROBANTE_PAGO
			WHERE (id_ComprobantePago = @id_ComprobantePago)

			set @Numero = (SELECT RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(Numero)),0)+1), 8) FROM CAJ_COMPROBANTE_PAGO 
			WHERE Cod_TipoComprobante = 'NCE' and Serie=@Serie AND Cod_Libro = '14');

			INSERT INTO CAJ_COMPROBANTE_PAGO
			SELECT Cod_Libro , Cod_Periodo , @Cod_Caja , @Cod_Turno , '01' , 
			'NCE' , Serie , @Numero , Id_Cliente , Cod_TipoDoc , Doc_Cliente , Nom_Cliente , 
			Direccion_Cliente , GETDATE() , GETDATE() , GETDATE() , 'POR LA ANULACION DE: '+ Cod_TipoComprobante + ': ' +Serie +' - '+Numero  , TipoCambio , 
			Flag_Anulado , Flag_Despachado , '004' , Descuento_Total , Cod_Moneda , -1*Impuesto , 
			-1*Total , Obs_Comprobante , Id_GuiaRemision , GuiaRemision , id_ComprobantePago , Cod_Plantilla , 
			Nro_Ticketera , Cod_UsuarioVendedor , Cod_RegimenPercepcion , Tasa_Percepcion , Placa_Vehiculo , 
			Cod_TipoDocReferencia , Nro_DocReferencia , '' , '' , 'INI' , 
			@MotivoAnulacion , Otros_Cargos , Otros_Tributos ,
			@Cod_Usuario , GETDATE() , NULL , NULL 
			FROM CAJ_COMPROBANTE_PAGO
			WHERE (id_ComprobantePago = @id_ComprobantePago)

			SET @id_ComprobantePagoAnulado = @@IDENTITY;

			SELECT @id_ComprobantePagoAnulado

			SET NOCOUNT ON;  
  
			DECLARE @id_Detalle int
  
			DECLARE Detalles_cursor CURSOR FOR   
			SELECT id_Detalle FROM CAJ_COMPROBANTE_D WHERE id_ComprobantePago = @id_ComprobantePago
  
			OPEN Detalles_cursor  
  
			FETCH NEXT FROM Detalles_cursor   
			INTO @id_Detalle  
  
			WHILE @@FETCH_STATUS = 0  
			BEGIN  
				INSERT INTO CAJ_COMPROBANTE_D
				SELECT @id_ComprobantePagoAnulado , id_Detalle , Id_Producto , Cod_Almacen , -1*Cantidad , Cod_UnidadMedida , -1*Despachado , 
				Descripcion , PrecioUnitario , Descuento , -1*Sub_Total , Tipo , Obs_ComprobanteD , Cod_Manguera , Flag_AplicaImpuesto , 
				-1*Formalizado , Valor_NoOneroso , Cod_TipoISC , Porcentaje_ISC , ISC , Cod_TipoIGV , Porcentaje_IGV , -1*IGV , 
				@Cod_Usuario , GETDATE() , NULL , NULL  
				FROM CAJ_COMPROBANTE_D
				WHERE (id_ComprobantePago = @id_ComprobantePago) AND id_Detalle = @id_Detalle

        -- INSERTAR EN COMPROBANTE RELACION
        INSERT INTO CAJ_COMPROBANTE_RELACION  
        SELECT @id_ComprobantePagoAnulado, id_Detalle,id_Detalle,@id_ComprobantePago,'CRE',Despachado,@MotivoAnulacion,id_Detalle, @Cod_Usuario,GETDATE(),NULL,NULL
        FROM CAJ_COMPROBANTE_D
        WHERE (id_ComprobantePago = @id_ComprobantePago)  AND id_Detalle=@id_Detalle

				FETCH NEXT FROM Detalles_cursor   
				INTO @id_Detalle
			END   
			CLOSE Detalles_cursor;  
			DEALLOCATE Detalles_cursor; 
								
											
			END
		ELSE SELECT 0
END
ELSE
BEGIN
	RAISERROR ('No se pueden Anular Notas de Credito y Debito Electronicas.',16,1);  
	--SELECT 0
END

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


--Prueba de probar intentar subir los comprobantes mediante el agente con un USP

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento' AND type = 'P')
DROP PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento
go
CREATE PROCEDURE USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento
AS
BEGIN
	--Variables generales
	DECLARE @cmd sysname
	DECLARE @Sentencia varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	--Recuperamos las variables principales
	DECLARE @Id int
	DECLARE @Nombre_Tabla varchar(max) 
	DECLARE @Id_Compropante_Pago int 
	DECLARE @Id_Item int 
	DECLARE @Accion varchar(max) 
	DECLARE @Fecha_Reg datetime 
	--Recuperamos el primer objeto de la cola y almacenamos en las variables
	SELECT TOP 1 @Id=tcrl.Id,@Nombre_Tabla=tcrl.Nombre_Tabla,
	@Id_Compropante_Pago=tcrl.Id_Compropante_Pago,@Id_Item=tcrl.Id_Item,
	@Accion=tcrl.Accion,@Fecha_Reg=tcrl.Fecha_Reg
	FROM dbo.TMP_COMPROBANTE_REGISTRO_LOG tcrl
	ORDER BY tcrl.Id

	IF @Id IS NOT NULL
	BEGIN
		--De acuerdo al elemento que queremos ejecutamos el USP necesario
		--Recuperar elemento tipo PRI_PRODUCTOS
		IF @Nombre_Tabla = 'PRI_PRODUCTOS'
		BEGIN
			SELECT TOP 1 @Sentencia='PALERPlink.'+@NombreBD+'.dbo.USP_PRI_PRODUCTOS_I ''' +
   			Cod_Producto+''','+ 
			CASE WHEN Cod_Categoria  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Categoria+''','END+
			CASE WHEN Cod_Marca  IS NULL THEN 'NULL,' ELSE ''''+ Cod_Marca+''','END+
			CASE WHEN Cod_TipoProducto  IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoProducto+''','END+
			CASE WHEN Nom_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nom_Producto,'''','')+''','END+
			CASE WHEN Des_CortaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_CortaProducto,'''','')+''','END+
			CASE WHEN Des_LargaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_LargaProducto,'''','')+''','END+
			CASE WHEN Caracteristicas  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Caracteristicas,'''','')+''','END+
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
			FROM            PRI_PRODUCTOS
			WHERE dbo.PRI_PRODUCTOS.Id_Producto=@Id_Compropante_Pago
		END

		--Recuperar elemento tipo PRI_CLIENTE_PROVEEDOR
		IF @Nombre_Tabla = 'PRI_CLIENTE_PROVEEDOR'
		BEGIN
			SELECT TOP 1 @Sentencia= 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_CLIENTE_PROVEEDOR_I ' + 
			CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoDocumento+''','END+
			CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
			CASE WHEN Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cliente,'''','')+''','END+
			CASE WHEN Ap_Paterno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Paterno,'''','')+''','END+
			CASE WHEN Ap_Materno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Materno,'''','')+''','END+
			CASE WHEN Nombres IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nombres,'''','')+''','END+
			CASE WHEN Direccion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Direccion,'''','')+''','END+
			CASE WHEN Cod_EstadoCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_EstadoCliente+''','END+
			CASE WHEN Cod_CondicionCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_CondicionCliente+''','END+
			CASE WHEN Cod_TipoCliente IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoCliente+''','END+
			CASE WHEN RUC_Natural IS NULL THEN 'NULL,' ELSE ''''+ RUC_Natural+''','END+
			'NULL,
			NULL, '+ 
			CASE WHEN Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ Cod_TipoComprobante+''','END+
			CASE WHEN Cod_Nacionalidad IS NULL THEN 'NULL,' ELSE ''''+ Cod_Nacionalidad+''','END+
			CASE WHEN Fecha_Nacimiento IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Nacimiento,121)+''','END+
			CASE WHEN Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+ Cod_Sexo+''','END+
			CASE WHEN Email1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email1,'''','')+''','END+
			CASE WHEN Email2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email2,'''','')+''','END+
			CASE WHEN Telefono1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono1,'''','')+''','END+
			CASE WHEN Telefono2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono2,'''','')+''','END+
			CASE WHEN Fax IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Fax,'''','')+''','END+
			CASE WHEN PaginaWeb IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(PaginaWeb,'''','')+''','END+
			CASE WHEN Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+ Cod_Ubigeo+''','END+
			CASE WHEN Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ Cod_FormaPago+''','END+
			CASE WHEN Limite_Credito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Limite_Credito)+','END+
			CASE WHEN Obs_Cliente IS NULL THEN 'NULL,' ELSE ''''+  CONVERT(VARCHAR(MAX),Obs_Cliente)+''','END+
			CASE WHEN Num_DiaCredito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Num_DiaCredito)+','END+
			''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg) +''';' 
			FROM PRI_CLIENTE_PROVEEDOR    
			WHERE dbo.PRI_CLIENTE_PROVEEDOR.Id_ClienteProveedor=@Id_Compropante_Pago
		END

		--Recuperar elemento tipo CAJ_COMPROBANTE_PAGO
		IF @Nombre_Tabla = 'CAJ_COMPROBANTE_PAGO'
		BEGIN
			SELECT DISTINCT @Sentencia='PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_PAGO_I '+ 
			CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Libro+''',' END +
			CASE WHEN CP.Cod_Periodo IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Periodo+''',' END +
			CASE WHEN CP.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Caja+''',' END +
			CASE WHEN CP.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Turno+''',' END +
			CASE WHEN CP.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoOperacion+''',' END +
			CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoComprobante+''',' END +
			CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+CP.Serie+''',' END +
			CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+CP.Numero+''',' END +	
			CASE WHEN CP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoDoc+''',' END +
			CASE WHEN CP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Doc_Cliente,'''','')+''',' END +
			CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nom_Cliente,'''','')+''',' END +
			CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Direccion_Cliente,'''','')+''',' END +
			CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision,121)+''','END+ 
			CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento,121)+''','END+ 
			CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion,121)+''','END+ 
			CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Glosa,'''','')+''',' END +
			CASE WHEN CP.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.TipoCambio)+','END+
			CONVERT(VARCHAR(MAX),CP.Flag_Anulado)+','+ 
			CONVERT(VARCHAR(MAX),CP.Flag_Despachado)+','+ 
			CASE WHEN CP.Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_FormaPago+''',' END +
			CASE WHEN CP.Descuento_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Descuento_Total)+','END+
			CASE WHEN CP.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Moneda+''',' END +
			CASE WHEN CP.Impuesto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Impuesto)+','END+
			CASE WHEN CP.Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Total)+','END+
			CASE WHEN CP.Obs_Comprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),CP.Obs_Comprobante),'''','')+''','END+
			CASE WHEN CP.Id_GuiaRemision IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Id_GuiaRemision)+','END+
			CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),CP.GuiaRemision),'''','')+''','END+

			CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+CONVERT(VARCHAR(MAX),
			(CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE (SELECT TOP 1 ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef) END ))+''',' END+
			CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+CONVERT(VARCHAR(MAX),
			(CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE (SELECT TOP 1 ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef) END ))+''',' END+
			CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+CONVERT(VARCHAR(MAX),
			(CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE (SELECT TOP 1 ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef) END ))+''',' END+
			CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+CONVERT(VARCHAR(MAX),
			(CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE (SELECT TOP 1 ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef) END ))+''',' END+

			CASE WHEN CP.Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_Plantilla+''',' END +
			CASE WHEN CP.Nro_Ticketera IS NULL THEN 'NULL,' ELSE ''''+CP.Nro_Ticketera+''',' END +
			CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.Cod_UsuarioVendedor,'''','')+''',' END +
			CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_RegimenPercepcion+''',' END +
			CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
			CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( CP.Placa_Vehiculo,'''','')+''',' END +
			CASE WHEN CP.Cod_TipoDocReferencia IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_TipoDocReferencia+''',' END +
			CASE WHEN CP.Nro_DocReferencia IS NULL THEN 'NULL,' ELSE ''''+CP.Nro_DocReferencia+''',' END +
			CASE WHEN CP.Valor_Resumen IS NULL THEN 'NULL,' ELSE ''''+CP.Valor_Resumen+''',' END +
			CASE WHEN CP.Valor_Firma IS NULL THEN 'NULL,' ELSE ''''+CP.Valor_Firma+''',' END +
			CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_EstadoComprobante+''',' END +
			CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.MotivoAnulacion,'''','')+''',' END +
			CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
			CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
			''''+COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg)+ ''';' 	 
			FROM            CAJ_COMPROBANTE_PAGO AS CP LEFT JOIN
									 CAJ_COMPROBANTE_PAGO AS CPR ON CP.id_ComprobantePago = CPR.id_ComprobantePago
			WHERE CP.id_ComprobantePago=@Id_Compropante_Pago
		END

		--Tabla CAJ_COMPROBANTE_D
		IF @Nombre_Tabla = 'CAJ_COMPROBANTE_D'
		BEGIN
			SELECT DISTINCT @Sentencia='PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_D_I '+ 
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
			CASE WHEN D.Obs_ComprobanteD IS NULL THEN 'NULL,' ELSE ''''+Replace(D.Obs_ComprobanteD,'''','')+''',' END +
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
			FROM CAJ_COMPROBANTE_D AS D INNER JOIN
				 CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
				 PRI_PRODUCTOS AS PP ON D.Id_Producto = PP.Id_Producto
			WHERE P.id_ComprobantePago=@Id_Compropante_Pago AND D.id_Detalle=@Id_Item
		END


		--Tabla CAJ_COMPROBANTE_RELACION
		IF @Nombre_Tabla = 'CAJ_COMPROBANTE_RELACION'
		BEGIN
			SELECT DISTINCT @Sentencia='PALERPlink.'+@NombreBD+'.dbo.USP_CAJ_COMPROBANTE_RELACION_I '+ 
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
			''''+COALESCE(R.Cod_UsuarioAct,R.Cod_UsuarioReg)+ ''';' 
			FROM  CAJ_COMPROBANTE_RELACION AS R INNER JOIN
				 CAJ_COMPROBANTE_PAGO AS P ON R.id_ComprobantePago = P.id_ComprobantePago INNER JOIN
				 CAJ_COMPROBANTE_PAGO AS PP ON R.Id_ComprobanteRelacion = PP.id_ComprobantePago
			WHERE P.id_ComprobantePago=@Id_Compropante_Pago AND R.id_Detalle=@Id_Item
		END

		--Ejecutamos la sentencia
		BEGIN TRY
			
			EXECUTE(@Sentencia)
			--Si es exitosa entonces procedemos a eliminar el registro y almacenarlo en la tabla de historial
			BEGIN TRANSACTION 
				BEGIN TRY
					DELETE dbo.TMP_COMPROBANTE_REGISTRO_LOG WHERE @Id=dbo.TMP_COMPROBANTE_REGISTRO_LOG.Id
					INSERT dbo.TMP_COMPROBANTE_REGISTRO_LOG_H
					VALUES
					(
						@Nombre_Tabla, -- Nombre_Tabla - varchar
						@Id_Compropante_Pago, -- Id_Compropante_Pago - int
						@Id_Item, -- Id_Item - int
						@Accion, -- Accion - varchar
						@Fecha_Reg, -- Fecha_Reg - datetime
						GETDATE() -- Fecha_Reg_Insercion - datetime
					)
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


--Crea la tarea de exportacion que nse inicia desde las 00:00:00 horas hasta la 23:59:59
--Se necesita que exista la carpeta LOG en C:\APLICACIONES
--NumeroIntentos entero el nuemro de intentos , si es 0 sin reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--@RepetirCada el lapso de tiempo en el que se repite la tarea en minutos, por defecto 60
--Ruta de guradado Path absoluto de la ruta del archivo a guardar
--exec USP_CrearTareaAgente N'Tarea exportacion',N'USP_ExportarDatos',N'C:\APLICACIONES\TEMP\log_exportacion.txt'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaAgenteSegundos' AND type = 'P')
DROP PROCEDURE USP_CrearTareaAgenteSegundos
GO
CREATE PROCEDURE USP_CrearTareaAgenteSegundos
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
			@freq_subday_type=2, 
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


----- Tarea de exportacion
-- DECLARE @NombreTarea varchar(max)= N'Tarea exportacion2' --Por defecto
-- DECLARE @NombreUSPexportacion varchar(max)= N'USP_TMP_COMPROBANTE_REGISTRO_LOG_ExportarPrimerElemento' --Por defecto
-- DECLARE @RutaGuardadoLOG varchar(max)= N'C:\APLICACIONES\TEMP\log_exportacion.txt' --Por defecto

-- exec USP_CrearTareaAgenteSegundos @NombreTarea,@NombreUSPexportacion,@RutaGuardadoLOG,0,0,10
