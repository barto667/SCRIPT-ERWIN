--LADO CLIENTE
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
GO


--UspExportar datos

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
	
	--SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_EMPRESA_I ' +
	--''''+ pe.Cod_Empresa +''','+
	--CASE WHEN  pe.RUC IS NULL  THEN 'NULL,'    ELSE ''''+ pe.RUC+''','END+
	--CASE WHEN  pe.Nom_Comercial IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Nom_Comercial+''','END+
	--CASE WHEN  pe.RazonSocial IS NULL  THEN 'NULL,'    ELSE ''''+ pe.RazonSocial+''','END+
	--CASE WHEN  pe.Direccion IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Direccion+''','END+
	--CASE WHEN  pe.Telefonos IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Telefonos+''','END+
	--CASE WHEN  pe.Web IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Web+''','END+
	--'NULL,'+
	--'NULL,'+
	--convert(varchar(max),pe.Flag_ExoneradoImpuesto)+','+
	--CASE WHEN  pe.Des_Impuesto IS NULL  THEN 'NULL,'    ELSE ''''+ pe.Des_Impuesto+''','END+
	--CASE WHEN  pe.Por_Impuesto IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pe.Por_Impuesto)+''','END+
	--CASE WHEN  pe.EstructuraContable IS NULL  THEN 'NULL,'    ELSE '''' +pe.EstructuraContable+''','END+
	--CASE WHEN  pe.Version IS NULL  THEN 'NULL,'    ELSE '''' +pe.Version+''','END+
	--CASE WHEN  pe.Cod_Ubigeo IS NULL  THEN 'NULL,'    ELSE '''' +pe.Cod_Ubigeo+''','END+
	--''''+COALESCE(pe.Cod_UsuarioAct,pe.Cod_UsuarioReg)   +''';' 
	--	AS ScripExportar, 1 as Orden, COALESCE(pe.Fecha_Act,pe.Fecha_Reg) as Fecha
	--FROM dbo.PRI_EMPRESA pe
	--WHERE 
	--		(pe.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pe.Fecha_Act IS NULL) 
	--		OR (pe.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

	--UNION 
 

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
		AS ScripExportar, 2 as Orden, COALESCE(ps.Fecha_Act,ps.Fecha_Reg) as Fecha
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
	CASE WHEN Fecha_Inicio IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Inicio,121)+''','END+
	CASE WHEN Fecha_Fin IS NULL THEN 'NULL,' ELSE  ''''+  CONVERT(VARCHAR(MAX),Fecha_Fin,121)+''','END+
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
	''''+CONVERT(VARCHAR(MAX),Fecha,121) +''','+ 
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
	''''+L.Cod_Licitacion+''', '+ 
	CASE WHEN L.Des_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Des_Licitacion+''','END+
	CASE WHEN L.Cod_TipoLicitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Cod_Licitacion+''','END+
	CASE WHEN L.Nro_Licitacion IS NULL THEN 'NULL,' ELSE ''''+ L.Nro_Licitacion+''','END+
	CASE WHEN L.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Inicio,121)+''','END+ 
	CASE WHEN L.Fecha_Facturacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),L.Fecha_Facturacion,121)+''','END+ 
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
	CASE WHEN CM.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha,121)+''',' END+ 
	CASE WHEN CM.Tipo_Cambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Tipo_Cambio)+',' END+ 
	CASE WHEN CM.Ingreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Ingreso)+',' END+  
	CASE WHEN CM.Cod_MonedaIng  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_MonedaIng+''','END+
	CASE WHEN CM.Egreso IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CM.Egreso)+',' END+ 
	CASE WHEN CM.Cod_MonedaEgr  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_MonedaEgr+''','END+
	CONVERT(VARCHAR(MAX),CM.Flag_Extornado)+','+
	CASE WHEN CM.Cod_UsuarioAut  IS NULL THEN 'NULL,' ELSE ''''+CM.Cod_UsuarioAut+''','END+
	CASE WHEN CM.Fecha_Aut IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CM.Fecha_Aut,121)+''','END+ 
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
	CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nom_Cliente,'''','')+''',' END +
	CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Direccion_Cliente,'''','')+''',' END +
	CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision,121)+''','END+ 
	CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento,121)+''','END+ 
	CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion,121)+''','END+ 
	CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+CP.Glosa+''',' END +
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
	CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.GuiaRemision)+''','END+

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
	CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_UsuarioVendedor+''',' END +
	CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+CP.Cod_RegimenPercepcion+''',' END +
	CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
	CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( CP.Placa_Vehiculo,'''','')+''',' END +
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
	CASE WHEN S.Fecha_Vencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),S.Fecha_Vencimiento,121)+''','END+ 
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
	CASE WHEN S.Fecha_Vencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),S.Fecha_Vencimiento,121)+''','END+ 
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
	CASE WHEN Fecha IS NULL THEN 'NULL,' ELSE ''''+  CONVERT(VARCHAR(MAX),Fecha,121)+''','END+ 
	CASE WHEN Monto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Monto)+','END+ 
	CASE WHEN TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),TipoCambio)+','END+ 
	CASE WHEN Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+ Cod_Caja +''',' END +
	CASE WHEN Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+ Cod_Turno +''',' END +
	CASE WHEN Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+ Cod_Plantilla +''',' END +
	CASE WHEN Nro_Cheque IS NULL THEN 'NULL,' ELSE ''''+ Nro_Cheque +''',' END +
	CASE WHEN Beneficiario IS NULL THEN 'NULL,' ELSE ''''+ Beneficiario +''',' END +
	CASE WHEN Id_ComprobantePago IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Id_ComprobantePago)+','END+ 
	CASE WHEN Obs_Movimiento IS NULL THEN 'NULL,' ELSE ''''+ Obs_Movimiento +''',' END +
    ''''+COALESCE(Cod_UsuarioAct,Cod_UsuarioReg)+ ''';' AS ScripExportar, 33 as Orden, COALESCE(Fecha_Act,Fecha_Reg) as Fecha
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
	CASE WHEN M.Fecha IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),M.Fecha,121)+''','END+ 
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
	CASE WHEN F.Fecha IS NULL THEN 'NULL,' ELSE '''' +CONVERT(VARCHAR(MAX),F.Fecha,121)+''','END+ 
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
	CASE WHEN Fecha_Medicion IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Medicion,121)+''','END+
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
	CASE WHEN ct.FechaHora IS NULL THEN 'NULL,' ELSE ''''+CONVERT(varchar(max),ct.FechaHora,121)+''','END +
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

	SELECT 'PALERPlink.'+@NombreBD+'.dbo.USP_PRI_ACTIVIDADES_ECONOMICAS_I ' +
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
	CASE WHEN  pcv.Fecha_HoraVisita IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraVisita,121)+''','END+
	CASE WHEN  pcv.Comentarios IS NULL  THEN 'NULL,'    ELSE ''''+ pcv.Comentarios+''','END+
	CONVERT(varchar(max),pcv.Flag_Compromiso)+','+
	CASE WHEN  pcv.Fecha_HoraCompromiso IS NULL  THEN 'NULL,'    ELSE ''''+ CONVERT(varchar(max), pcv.Fecha_HoraCompromiso,121)+''','END+
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
	CASE WHEN  pd.Fecha_Inicia IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Inicia,121)+''','END+
	CASE WHEN  pd.Fecha_Fin IS NULL  THEN 'NULL,'    ELSE '''' +CONVERT(varchar(max),pd.Fecha_Fin,121)+''','END+
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
	''''+CONVERT(varchar(max), pm.Fecha_Remite,121)+''',' +
	''''+pm.Mensaje+''','+
	CONVERT(varchar(max),pm.Flag_Leido)+','+
	''''+pm.Cod_UsuarioRecibe+''','+
	''''+CONVERT(varchar(max), pm.Fecha_Recibe,121)+''',' +
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
	CASE WHEN pp.Fecha_Inicio IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pp.Fecha_Inicio,121) +''','END+
	CASE WHEN pp.Fecha_Fin IS NULL THEN 'NULL,' ELSE ''''+ convert(varchar(max),pp.Fecha_Fin,121) +''','END+
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
	CASE WHEN pp.Fecha_Ingreso IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Ingreso,121) +''','END+
	CASE WHEN pp.Fecha_Nacimiento IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_Nacimiento,121) +''','END+
	CASE WHEN pp.Cod_Cargo IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Cargo +''','END+
	CASE WHEN pp.Cod_Estado IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Estado +''','END+
	CASE WHEN pp.Cod_Area IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Area +''','END+
	CASE WHEN pp.Cod_Local IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_Local +''','END+
	CASE WHEN pp.Cod_CentroCostos IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_CentroCostos +''','END+
	CASE WHEN pp.Cod_EstadoCivil IS NULL THEN 'NULL,' ELSE ''''+pp.Cod_EstadoCivil +''','END+
	CASE WHEN pp.Fecha_InsESSALUD IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max),pp.Fecha_InsESSALUD,121) +''','END+
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
	CASE WHEN pcc.Fecha_Incorporacion IS NULL THEN 'NULL,' ELSE ''''+convert(varchar(max), pcc.Fecha_Incorporacion,121) +''','END+
	''''+COALESCE(pcc.Cod_UsuarioAct,pcc.Cod_UsuarioReg)   +''';' 
		AS Scripccxportar, 52 as Orden, COALESCE(pcc.Fecha_Act,pcc.Fecha_Reg) as Fecha
	FROM dbo.PRI_CLIENTE_CONTACTO pcc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp 
	ON pcc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp2 ON pcc.Id_ClienteContacto=pcp2.Id_ClienteProveedor
	WHERE 
			(pcc.Fecha_Reg BETWEEN @FechaInicio AND @FechaFin AND pcc.Fecha_Act IS NULL) 
			OR (pcc.Fecha_Act BETWEEN @FechaInicio AND @FechaFin)

  ) as Exportar ORDER BY Exportar.Orden,Exportar.Fecha
--  -- select * from #exportar
-- 	DECLARE @Resultado varchar(max)
-- 	DECLARE @Linea varchar(max)
	
-- 	DECLARE  RecorrerScript CURSOR FOR 
-- 	SELECT e.ScripExportar FROM #exportar e 
-- 	ORDER BY Orden,Fecha
	
-- 	OPEN RecorrerScript
-- 	FETCH NEXT FROM RecorrerScript 
-- 	INTO @Linea
-- 	WHILE @@FETCH_STATUS = 0
-- 	BEGIN   
-- 		print @Linea
-- 		--DECLARE @Resultado varchar(max) ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo LINEA A EJECUTAR: '+@Linea+'>> C:\APLICACIONES\LOG\log_exportacion.txt','''',' '),'|',' ')+''''
-- 		--EXECUTE(@Resultado)
-- 		BEGIN TRY
-- 			EXECUTE(@Linea)
-- 		END TRY
-- 		BEGIN CATCH
-- 			SELECT   
-- 			ERROR_NUMBER() AS ErrorNumber  
-- 			,ERROR_SEVERITY() AS ErrorSeverity  
-- 			,ERROR_STATE() AS ErrorState  
-- 			,ERROR_PROCEDURE() AS ErrorProcedure  
-- 			,ERROR_LINE() AS ErrorLine  
-- 			,ERROR_MESSAGE() AS ErrorMessage;  
-- 			SET @Resultado  = 'master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo ERROR DURANTE LA EJECUCION DEL USP : '+ERROR_MESSAGE()+CONVERT(varchar(max),@FechaInicio,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
-- 			EXECUTE(@Resultado)
-- 		END CATCH

-- 		FETCH NEXT FROM RecorrerScript 
-- 		INTO @Linea
-- 	END 	
-- 		UPDATE PRI_EMPRESA SET Fecha_Act = @FechaFin;

-- 		SET @Resultado  ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo EXITO EN LA EXPORTACION HASTA: '+CONVERT(varchar(max),@FechaFin,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
-- 		EXECUTE(@Resultado)
-- 		DROP TABLE #exportar;
-- 		CLOSE RecorrerScript;
-- 		DEALLOCATE RecorrerScript;
-- 	END TRY  
-- 	BEGIN CATCH  
-- 		SELECT   
-- 					ERROR_NUMBER() AS ErrorNumber  
-- 					,ERROR_SEVERITY() AS ErrorSeverity  
-- 					,ERROR_STATE() AS ErrorState  
-- 					,ERROR_PROCEDURE() AS ErrorProcedure  
-- 					,ERROR_LINE() AS ErrorLine  
-- 					,ERROR_MESSAGE() AS ErrorMessage;  
-- 				SET @Resultado  = 'master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo IMPOSIBLE EJECUTAR LA EXPORTACION, ERROR GRAVE: '+ERROR_MESSAGE()+' No se puede realizar la exportacion del: '+CONVERT(varchar(max),@FechaInicio,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
-- 				EXECUTE(@Resultado)
-- 				UPDATE PRI_EMPRESA SET Fecha_Act = @FechaInicio;
-- 	END CATCH;  		

-- 	END
-- GO

 -- select * from #exportar
	DECLARE @Resultado varchar(max)
	DECLARE @Linea varchar(max)
	DECLARE @flagExito bit=1
	
	DECLARE  RecorrerScript CURSOR FOR 
	SELECT e.ScripExportar FROM #exportar e 
	ORDER BY Orden,Fecha
	
	OPEN RecorrerScript
	FETCH NEXT FROM RecorrerScript 
	INTO @Linea
	WHILE @@FETCH_STATUS = 0 AND @flagExito=1
	BEGIN   
		print @Linea
		--DECLARE @Resultado varchar(max) ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo LINEA A EJECUTAR: '+@Linea+'>> C:\APLICACIONES\LOG\log_exportacion.txt','''',' '),'|',' ')+''''
		--EXECUTE(@Resultado)
		BEGIN TRY
			EXECUTE(@Linea)
		END TRY
		BEGIN CATCH
			SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  
			SET @Resultado  = 'master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo ERROR DURANTE LA EJECUCION DEL USP : '+ERROR_MESSAGE()+CONVERT(varchar(max),@FechaInicio,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
			EXECUTE(@Resultado)
			set @flagExito=0
		END CATCH

		FETCH NEXT FROM RecorrerScript 
		INTO @Linea
	END 	
	IF (@flagExito = 1)
	BEGIN
		UPDATE PRI_EMPRESA SET Fecha_Act = @FechaFin;

		SET @Resultado  ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo EXITO EN LA EXPORTACION HASTA: '+CONVERT(varchar(max),@FechaFin,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
		EXECUTE(@Resultado)
		DROP TABLE #exportar;
	END
	ELSE
	BEGIN
		UPDATE PRI_EMPRESA SET Fecha_Act = @FechaInicio;
	     SET @Resultado  ='master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo NO SE PUEDE CONTINUAR LA EXPORTACION, REINTENTANDO EN EL SIGUIENTE INICIO: '+CONVERT(varchar(max),@FechaFin,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
		EXECUTE(@Resultado)
		DROP TABLE #exportar;
	END

		CLOSE RecorrerScript;
		DEALLOCATE RecorrerScript;
	END TRY  
	BEGIN CATCH  
		SELECT   
					ERROR_NUMBER() AS ErrorNumber  
					,ERROR_SEVERITY() AS ErrorSeverity  
					,ERROR_STATE() AS ErrorState  
					,ERROR_PROCEDURE() AS ErrorProcedure  
					,ERROR_LINE() AS ErrorLine  
					,ERROR_MESSAGE() AS ErrorMessage;  
				SET @Resultado  = 'master..xp_cmdshell ' +''''+ REPLACE(REPLACE('echo IMPOSIBLE EJECUTAR LA EXPORTACION, ERROR GRAVE: '+ERROR_MESSAGE()+' No se puede realizar la exportacion del: '+CONVERT(varchar(max),@FechaInicio,121)+'>> C:\APLICACIONES\TEMP\log_exportacion_auxiliar.txt','''',' '),'|',' ')+''''
				EXECUTE(@Resultado)
				UPDATE PRI_EMPRESA SET Fecha_Act = @FechaInicio;
	END CATCH;  		

	END
GO


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


-- --Introducir variables
-- --Linked SERVER
-- DECLARE @NombreLinkedServer varchar(max)= N'PALERPlink' --Por defecto
-- DECLARE @ServidorLinkedServer varchar(max)= N'reyberpalma.hopto.org' --Nombre del servidor remoto
-- DECLARE @NombreBaseDeDatos varchar(max)= (SELECT DB_NAME() AS [Base de datos actual]) --Nombre de la base de datos actual, cambiar si es otro nombre
-- DECLARE @NombreUsuarioServidor varchar(max)= N'sa' --Por defecto
-- DECLARE @NombrePassServidor varchar(max)= N'paleC0nsult0res' --Por defecto
-- exec USP_CrearLinkedServerSQLtoSQL @NombreLinkedServer,@ServidorLinkedServer,@NombreBaseDeDatos,@NombreUsuarioServidor,@NombrePassServidor

-- --Tarea de exportacion
-- DECLARE @NombreTarea varchar(max)= N'Tarea exportacion' --Por defecto
-- DECLARE @NombreUSPexportacion varchar(max)= N'USP_ExportarDatos' --Por defecto
-- DECLARE @RutaGuardadoLOG varchar(max)= N'C:\APLICACIONES\TEMP\log_exportacion.txt' --Por defecto

-- exec USP_CrearTareaAgente @NombreTarea,@NombreUSPexportacion,@RutaGuardadoLOG


--SELECT * from PRI_EMPRESA