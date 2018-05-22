--Genericos para todas las empresas
--Creacion del linked server
-- Configuracion proveedor: Allow In Procees = true / DynamicParameters = true
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP',N'AllowInProcess',1
GO
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP',N'DynamicParameters',1
GO
DECLARE @name NVARCHAR(4000);
DECLARE @provider NVARCHAR(4000);
DECLARE @servername NVARCHAR(4000);
DECLARE @port NVARCHAR(4000);
DECLARE @db_name NVARCHAR(4000)
-- DB origen
SET @name = N'PSSQL_Conexion';
SET @provider = N'PGNP';
SET @servername = N'localhost';
SET @port = 'PORT=5432;'
SET @db_name = N'dbInterface';
-- Crear linked server
EXEC MASTER.dbo.sp_addlinkedserver @server = @name
,@srvproduct = N'PGNP'
,@provider = N'PGNP'
,@datasrc = @servername
,@provstr = @port
,@catalog = @db_name
-- Usuario y contraseña
EXEC MASTER.dbo.sp_addlinkedsrvlogin @rmtsrvname = @name
,@useself = N'False'
,@locallogin = NULL
,@rmtuser = N'postgres'
,@rmtpassword = '07931269'
-- Propiedades de conexion
EXEC MASTER.dbo.sp_serveroption @server = @name
,@optname = 'data access'
,@optvalue = 'true'
EXEC MASTER.dbo.sp_serveroption @server = @name
,@optname = 'use remote collation'
,@optvalue = 'true'
EXEC MASTER.dbo.sp_serveroption @server = @name
,@optname = 'rpc'
,@optvalue = 'true'
EXEC MASTER.dbo.sp_serveroption @server = @name
,@optname = 'rpc out'
,@optvalue = 'true'
GO


--Creamos o reemplazamos la tabla comprobante D
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TMP_COMPROBANTE_D')
	DROP TABLE TMP_COMPROBANTE_D
go
CREATE TABLE TMP_COMPROBANTE_D (
       id_ComprobantePago   bigint NOT NULL,
       id_Detalle           bigint IDENTITY(1,1),
       Id_Producto          int NULL,       
       Cantidad             numeric(38,6) NULL,              
       PrecioUnitario       numeric(38,6) NULL,       
       Sub_Total            numeric(38,2) NULL,
       Cod_Manguera         varchar(32) NULL,      
	   MedicionActual       numeric(38,4) NULL,
	   Cod_Caja             varchar(32) NULL, 
	   FechaHora_Sistema    datetime NULL,
	   FechaHora_Actual     datetime NULL,
       PRIMARY KEY NONCLUSTERED (id_ComprobantePago, id_Detalle)       
)
go

--Actualizamos tmp_comprobante_H con dos nuevas columnas
ALTER TABLE TMP_COMPROBANTE_H ADD FechaHora_Sistema    datetime NULL;
ALTER TABLE TMP_COMPROBANTE_H ADD FechaHora_Actual     datetime NULL;


-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_Volcado' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_Volcado
go
CREATE PROCEDURE USP_PGSQL_MSSQL_Volcado
WITH ENCRYPTION
AS
BEGIN
    declare @temp_id bigint 
    declare @temp_codcaja varchar(32)
    declare @temp_codmanguera varchar(32)
    declare @temp_codproducto varchar(32) 
    declare @temp_preciounitario numeric(38, 6)
    declare @temp_cantidad numeric(38, 6)
    declare @temp_importe numeric(38, 6)
    declare @temp_contometro numeric(32, 6)
    declare @temp_idventa bigint
    declare @temp_fechahora datetime
	--Recuperamos el primer registro del PGSQL
	SELECT TOP 1 @temp_id=[temp_id],@temp_codcaja=[temp_codcaja],@temp_codmanguera=[temp_codmanguera],
	@temp_codproducto=[temp_codproducto],@temp_preciounitario=[temp_preciounitario],@temp_cantidad=[temp_cantidad],
	@temp_importe=[temp_importe],@temp_contometro=[temp_contometro],@temp_idventa=[temp_idventa],@temp_fechahora=[temp_fecha]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaventas] order by [temp_id]

	declare @temp_idproducto int=(SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@temp_codproducto)

	IF(@temp_id is not null)
	BEGIN
		--Insertamos los datos en MSSQL
		INSERT INTO dbo.TMP_COMPROBANTE_D
		(
		    id_ComprobantePago,
		    --id_Detalle - this column value is auto-generated
		    Id_Producto,
		    Cantidad,
		    PrecioUnitario,
		    Sub_Total,
		    Cod_Manguera,
		    MedicionActual,
		    Cod_Caja,
		    FechaHora_Sistema,
		    FechaHora_Actual
		)
		VALUES
		(
			@temp_idventa, -- id_ComprobantePago - bigint
		    -- id_Detalle - bigint
		    @temp_idproducto,-- Id_Producto - int
		    @temp_cantidad, -- Cantidad - numeric
		    @temp_preciounitario, -- PrecioUnitario - numeric
		    @temp_importe, -- Sub_Total - numeric
		    @temp_codmanguera, -- Cod_Manguera - varchar
		    @temp_contometro, -- MedicionActual - numeric
		    @temp_codcaja, -- Cod_Caja - varchar
		    @temp_fechahora,
		    getdate()
		)
		--Eliminamos los datos del registro en PGSQL
		DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaventas] where [temp_id]=@temp_id
		--Mostramos el resultado
		SELECT  @temp_id as temp_id,@temp_codcaja as temp_codcaja,@temp_codmanguera as temp_codmanguera,@temp_idproducto as temp_idproducto,
		@temp_codproducto as temp_codproducto,@temp_preciounitario as temp_preciounitario,@temp_cantidad as temp_cantidad,
		@temp_importe as temp_importe,@temp_contometro as temp_contometro,@temp_idventa as temp_idventa, @temp_fechahora as FechaHora_Sistema
	END
	
END
go


-- 1 PUCKUIRA
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T2B5'
			WHEN 'G84' THEN 'T284'
			WHEN 'G90' THEN 'T290'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO


-- 2 ANTA
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T3B5'
			WHEN 'G84' THEN 'T384'
			WHEN 'G90' THEN 'T390'
			WHEN 'G95' THEN 'T395'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO

-- 3 Yanahuara
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T5B5'
			WHEN 'G84' THEN 'T584'
			WHEN 'G90' THEN 'T590'
			WHEN 'G95' THEN 'T595'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO


-- 4 URUBAMBA
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T4B5'
			WHEN 'G84' THEN 'T484'
			WHEN 'G90' THEN 'T490'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO



-- 5 ARCOPATA
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T6B5'
			WHEN 'G84' THEN 'T684'
			WHEN 'G90' THEN 'T690'
			WHEN 'G95' THEN 'T695'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO


-- 6 POROY
-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_ActualizacionPrecio' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
go
CREATE PROCEDURE USP_PGSQL_MSSQL_ActualizacionPrecio
WITH ENCRYPTION
AS
BEGIN
	DECLARE @temp_IDproducto bigint
	DECLARE @temp_CodProducto varchar(32)
	DECLARE @temp_Precio numeric(38, 6)
	--Recuperamos el primer dato del producto insertado
	SELECT TOP 1 @temp_IDproducto=[temp_id],@temp_CodProducto=[temp_codproducto],@temp_Precio=[temp_precio1]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] order by [temp_id]

	IF(@temp_IDproducto IS NOT NULL)
	BEGIN
	--Obtenemos el cod del producto para actualizar los tanques
		DECLARE @CodProducto varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'B5'
			WHEN 'G84' THEN 'G84'
			WHEN 'G90' THEN 'G90'
			WHEN 'G95' THEN 'G95'
		END

		--Recuperamos el cod de almacen
		DECLARE @CodAlmacen varchar(32)=CASE @temp_CodProducto
			WHEN 'DB5' THEN 'T1B5'
			WHEN 'G84' THEN 'T184'
			WHEN 'G90' THEN 'T190'
			WHEN 'G95' THEN 'T195'
		END
		
		--Recuperamos el Id del producto
		DECLARE @IDProducto bigint = (SELECT pp.Id_Producto FROM dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto=@CodProducto)
		IF(@IDProducto IS NOT NULL)
		BEGIN
			DECLARE @PrecioAnterior numeric(30,6) = (SELECT ppp.Valor FROM dbo.PRI_PRODUCTO_PRECIO ppp WHERE ppp.Id_Producto=@IDProducto AND ppp.Cod_TipoPrecio='001')
			--Actualizamos todos los tanque que contienen dicho id producto, solo el campo de contado
			UPDATE dbo.PRI_PRODUCTO_PRECIO
			SET
				dbo.PRI_PRODUCTO_PRECIO.Valor=@temp_Precio,dbo.PRI_PRODUCTO_PRECIO.Cod_UsuarioAct='TRIGGER',dbo.PRI_PRODUCTO_PRECIO.Fecha_Act=getdate()
			WHERE dbo.PRI_PRODUCTO_PRECIO.Id_Producto=@IDProducto AND dbo.PRI_PRODUCTO_PRECIO.Cod_TipoPrecio='001'
			AND dbo.PRI_PRODUCTO_PRECIO.Cod_UnidadMedida='GLL' AND dbo.PRI_PRODUCTO_PRECIO.Cod_Almacen=@CodAlmacen
			--Eliminamos la consulta
			DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaproductos] where [temp_id]=@temp_IDproducto
			--Salida 
			SELECT @IDProducto AS IDProducto,@CodProducto AS CodProducto,@PrecioAnterior AS PrecioAnterior,@temp_Precio AS NuevoPrecio
		END
	END
END
GO






--Crea un linked server sql a sql con el proveedor SQLNCL11 por defecto
--exec USP_CrearLinkedServerSQLtoSQL N'Conexion',N'97.74.237.236\PALEHOST',N'PALERPseminario',N'sa',N'paleC0nsult0res'
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

