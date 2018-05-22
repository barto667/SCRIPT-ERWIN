--Creacion del linked server
-- Configuracion proveedor: Allow In Procees = true / DynamicParameters = true
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP'  ,N'AllowInProcess',1
GO
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP'  ,N'DynamicParameters',1
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


/****** Object:  Table [dbo].[tempaventas]    Script Date: 26/06/2017 11:41:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE tempaventas(
	temp_id bigint IDENTITY NOT NULL,
	temp_codcaja nchar(10) NOT NULL,
	temp_codmanguera nchar(10) NOT NULL,
	temp_codproducto nchar(10) NOT NULL,
	temp_preciounitario numeric(10, 6) NOT NULL,
	temp_cantidad numeric(10, 6) NOT NULL,
	temp_importe numeric(10, 6) NOT NULL,
	temp_contometro numeric(10, 6) NOT NULL,
	temp_idventa bigint NOT NULL,
 CONSTRAINT [PK_tempaventas] PRIMARY KEY CLUSTERED 
(
	[temp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO





--script auxiliar
-- declare @temp_id bigint 
-- declare @temp_codcaja nchar(10)
-- declare @temp_codmanguera nchar(10)
-- declare @temp_codproducto nchar(10) 
-- declare @temp_preciounitario numeric(10, 6)
-- declare @temp_cantidad numeric(10, 6)
-- declare @temp_importe numeric(10, 6)
-- declare @temp_idventa bigint

-- SELECT TOP 1 @temp_id=[temp_id],@temp_codcaja=[temp_codcaja],@temp_codmanguera=[temp_codmanguera],
-- @temp_codproducto=[temp_codproducto],@temp_preciounitario=[temp_preciounitario],@temp_cantidad=[temp_cantidad],
-- @temp_importe=[temp_importe],@temp_idventa=[temp_idventa]
-- FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaventas] order by [temp_id] asc limit 1 offset 0


-- Procedimiento que realiza el volcado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_Volcado' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_Volcado
go
CREATE PROCEDURE USP_PGSQL_MSSQL_Volcado
WITH ENCRYPTION
AS
BEGIN
    declare @temp_id bigint 
    declare @temp_codcaja nchar(10)
    declare @temp_codmanguera nchar(10)
    declare @temp_codproducto nchar(10) 
    declare @temp_preciounitario numeric(10, 6)
    declare @temp_cantidad numeric(10, 6)
    declare @temp_importe numeric(10, 6)
    declare @temp_contometro numeric(10, 6)
    declare @temp_idventa bigint
	--Recuperamos el primer registro del PGSQL
	SELECT TOP 1 @temp_id=[temp_id],@temp_codcaja=[temp_codcaja],@temp_codmanguera=[temp_codmanguera],
	@temp_codproducto=[temp_codproducto],@temp_preciounitario=[temp_preciounitario],@temp_cantidad=[temp_cantidad],
	@temp_importe=[temp_importe],@temp_contometro=[temp_contometro],@temp_idventa=[temp_idventa]
	FROM   [PSSQL_Conexion].[dbInterface].[public].[tempaventas] order by [temp_id]

	IF(@temp_id is not null)
	BEGIN
		--Insertamos los datos en MSSQL
		INSERT INTO dbo.tempaventas
		(
			--temp_id - this column value is auto-generated
			temp_codcaja,
			temp_codmanguera,
			temp_codproducto,
			temp_preciounitario,
			temp_cantidad,
			temp_importe,
			temp_contometro,
			temp_idventa
		)
		VALUES
		(
			-- temp_id - bigint
			@temp_codcaja, -- temp_codcaja - nchar
			@temp_codmanguera, -- temp_codmanguera - nchar
			@temp_codproducto, -- temp_codproducto - nchar
			@temp_preciounitario, -- temp_preciounitario - numeric
			@temp_cantidad, -- temp_cantidad - numeric
			@temp_importe, -- temp_importe - numeric
			@temp_contometro, -- temp_contometro - numeric
			@temp_idventa -- temp_idventa - bigint
		)
		--Eliminamos los datos del registro en PGSQL
		DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaventas] where [temp_id]=@temp_id
		--Mostramos el resultado
		SELECT  @temp_id as temp_id,@temp_codcaja as temp_codcaja,@temp_codmanguera as temp_codmanguera,
		@temp_codproducto as temp_codproducto,@temp_preciounitario as temp_preciounitario,@temp_cantidad as temp_cantidad,
		@temp_importe as temp_importe,@temp_contometro as temp_contometro,@temp_idventa as temp_idventa
	END
	
END
go




C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe G:\ERWIN\D\Proyecto\PALERPservicio\PALERPservicio\bin\Debug\PALERPservicio.exe

C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe D:\PALERP\Servicio\ServicioPuente.exe
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /u D:\PALERP\Servicio\ServicioPuente.exe

C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /u G:\ERWIN\D\Proyecto\PALERPservicio\PALERPservicio\bin\Debug\PALERPservicio.exe

C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe G:\ERWIN\D\Proyecto\ServicioPuente\ServicioPuente\bin\Debug\ServicioPuente.exe
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /u G:\ERWIN\D\Proyecto\ServicioPuente\ServicioPuente\bin\Debug\ServicioPuente.exe


G:\ERWIN\D\Proyecto\Prueba\iFacturacionGetway.exe




-- VERSION FINAL

--Creacion del linked server
-- Configuracion proveedor: Allow In Procees = true / DynamicParameters = true
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP'  ,N'AllowInProcess',1
GO
EXEC MASTER.dbo.sp_MSset_oledb_prop N'PGNP'  ,N'DynamicParameters',1
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
       PRIMARY KEY NONCLUSTERED (id_ComprobantePago, id_Detalle)       
)
go

-- PROCEDIMIENTO GUARDADO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PGSQL_MSSQL_Volcado' AND type = 'P')
DROP PROCEDURE USP_PGSQL_MSSQL_Volcado
go
CREATE PROCEDURE USP_PGSQL_MSSQL_Volcado
WITH ENCRYPTION
AS
BEGIN
    declare @temp_id bigint 
    declare @temp_codcaja nchar(10)
    declare @temp_codmanguera nchar(10)
    declare @temp_codproducto nchar(10) 
    declare @temp_preciounitario numeric(38, 6)
    declare @temp_cantidad numeric(38, 6)
    declare @temp_importe numeric(38, 6)
    declare @temp_contometro numeric(32, 6)
    declare @temp_idventa bigint
	--Recuperamos el primer registro del PGSQL
	SELECT TOP 1 @temp_id=[temp_id],@temp_codcaja=[temp_codcaja],@temp_codmanguera=[temp_codmanguera],
	@temp_codproducto=[temp_codproducto],@temp_preciounitario=[temp_preciounitario],@temp_cantidad=[temp_cantidad],
	@temp_importe=[temp_importe],@temp_contometro=[temp_contometro],@temp_idventa=[temp_idventa]
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
		    Cod_Caja
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
		    @temp_codcaja -- Cod_Caja - varchar
		)
		--Eliminamos los datos del registro en PGSQL
		DELETE FROM [PSSQL_Conexion].[dbInterface].[public].[tempaventas] where [temp_id]=@temp_id
		--Mostramos el resultado
		SELECT  @temp_id as temp_id,@temp_codcaja as temp_codcaja,@temp_codmanguera as temp_codmanguera,@temp_idproducto as temp_idproducto,
		@temp_codproducto as temp_codproducto,@temp_preciounitario as temp_preciounitario,@temp_cantidad as temp_cantidad,
		@temp_importe as temp_importe,@temp_contometro as temp_contometro,@temp_idventa as temp_idventa
	END
	
END
go

