IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_SERIES' ) 
    DROP VIEW VIS_SERIES
go
CREATE VIEW VIS_SERIES
WITH ENCRYPTION
AS
	SELECT        S.Cod_Tabla, S.Id_Tabla, S.Item, S.Serie, S.Fecha_Vencimiento, S.Obs_Serie, P.Cod_Producto, MD.Des_Producto, A.Des_Almacen, AM.Cod_TipoComprobante + ' : ' + AM.Serie + ' - ' + AM.Numero AS Comprobante,
                          AM.Fecha, AM.Motivo, AM.Flag_Anulado, 
						  CASE WHEN AM.Cod_Turno is NULL THEN 'PENDIENTE' ELSE
						  CASE AM.Cod_TipoComprobante WHEN 'NE' THEN 'ENTRADA' WHEN 'NS' THEN 'SALIDA' ELSE '' END END AS Estado,
						  CASE WHEN AM.Cod_Turno is NULL AND Flag_Anulado=0 THEN 0 else 
						  CASE WHEN AM.Cod_TipoComprobante = 'NE' AND 
                          Flag_Anulado = 0 THEN 1 WHEN AM.Cod_TipoComprobante = 'NS' AND Flag_Anulado = 0 THEN - 1 ELSE 0 END END AS Stock,
						  P.Id_Producto, A.Cod_Almacen, PS.Cod_UnidadMedida, AM.Fecha_Reg, PS.Precio_Venta, 
                          PS.Precio_Compra, VU.Nom_UnidadMedida
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto INNER JOIN
                         ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov INNER JOIN
                         ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto AND AM.Cod_Almacen = PS.Cod_Almacen INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida RIGHT OUTER JOIN
                         CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla AND MD.Item = S.Item
						 
WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV')
	UNION
		SELECT        S.Cod_Tabla, S.Id_Tabla, S.Item, S.Serie, S.Fecha_Vencimiento, S.Obs_Serie, P.Cod_Producto, CD.Descripcion AS Des_Producto, A.Des_Almacen, 
                         CP.Cod_TipoComprobante + ' : ' + CP.Serie + ' - ' + CP.Numero AS Comprobante, CP.FechaEmision, CP.Glosa, CP.Flag_Anulado, 
                         CASE cp.Cod_Libro WHEN '08' THEN 'ENTRADA' WHEN '14' THEN 'SALIDA' ELSE '' END AS Estado, CASE WHEN cp.Cod_Libro = '08' AND Flag_Anulado = 0 THEN 1 WHEN cp.Cod_Libro = '14' AND 
                         Flag_Anulado = 0 THEN - 1 ELSE 0 END AS Stock, P.Id_Producto, A.Cod_Almacen, PS.Cod_UnidadMedida, CP.Fecha_Reg, PS.Precio_Venta, PS.Precio_Compra, VU.Nom_UnidadMedida
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago INNER JOIN
                         ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto AND CD.Cod_Almacen = PS.Cod_Almacen INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VU ON CD.Cod_UnidadMedida = VU.Cod_UnidadMedida RIGHT OUTER JOIN
                         CAJ_SERIES AS S ON CD.id_ComprobantePago = S.Id_Tabla AND CD.id_Detalle = S.Item
WHERE        (S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')	
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ValidarTrazabilidad' AND type = 'P')
DROP FUNCTION UFN_PRI_SERIES_ValidarTrazabilidad
go
	CREATE FUNCTION UFN_PRI_SERIES_ValidarTrazabilidad(@Serie VARCHAR(20)) RETURNS INT
	AS
    BEGIN
		declare @StockP int;
		declare @StockS int;
		declare @Siguiente int;
		declare @Error int = 0
		declare cursor_fila  cursor local scroll for SELECT Stock FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie)
		open cursor_fila
		fetch NEXT FROM cursor_fila into @StockP
		fetch NEXT FROM cursor_fila into @StockS
		
			WHILE (@@FETCH_STATUS = 0 )
			begin	
				if (@StockP=1)
						if(@StockS=0)
						begin
							set @Error+=1
							break
						end
				if(@StockP=-1)
					if(@StockS=-1)
					begin
							set @Error+=1
							break
					end
				if (@StockP=0)
					if(@StockS is not null)
					begin
							set @Error+=1
							break
					end
				if(@StockP is null)
					if(@StockS is not null)
					begin
							set @Error+=1
							break
					end
				set @StockP=@StockS
				fetch NEXT FROM cursor_fila into @StockS
			end
			close cursor_fila
			deallocate cursor_fila
		return @Error
    END
go



CREATE FUNCTION UFN_PRI_SERIES_ContarPendientes(@Serie VARCHAR(20)) RETURNS INT
	AS
    BEGIN
		return (SELECT COUNT(*) FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie) and Estado='PENDIENTE')
    END
go


CREATE FUNCTION UFN_PRI_SERIES_ContarStock(@Serie VARCHAR(20)) RETURNS INT
	AS
    BEGIN
		declare @stock int =(SELECT SUM(Stock) FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie))
		if (@stock is null)
			set @stock =0
		return @stock
    END
go

CREATE FUNCTION UFN_PRI_SERIES_UltimoAlmacen(@Serie VARCHAR(20)) RETURNS Varchar(20)
	AS
    BEGIN
		return (SELECT TOP 1 Cod_Almacen FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie) order by Fecha_Reg DESC)
    END
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SERIES_ValidarEntrada' AND type = 'P')
DROP PROCEDURE USP_PRI_SERIES_ValidarEntrada
go
CREATE PROCEDURE USP_PRI_SERIES_ValidarEntrada
@Serie VARCHAR(20)
WITH ENCRYPTION
AS
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#ResultadoTemp')
	BEGIN
		drop table #ResultadoTemp
	END
	create table #ResultadoTemp (Cod_Almacen Varchar(50),Cod_Error int,Observacion Varchar(50))
	if(dbo.UFN_PRI_SERIES_ValidarTrazabilidad(@Serie)=0)
	begin
		declare @UltimoAlmacen varchar(20)=dbo.UFN_PRI_SERIES_UltimoAlmacen(@Serie)
		if(@UltimoAlmacen is null)
			set @UltimoAlmacen=''
		if(dbo.UFN_PRI_SERIES_ContarStock(@Serie)=0)
		begin
			if(dbo.UFN_PRI_SERIES_ContarPendientes(@Serie)=0)
			begin
				insert into #ResultadoTemp values(@UltimoAlmacen,4,'Todo correcto')
			end
			else
			begin
				insert into #ResultadoTemp values(@UltimoAlmacen,3,'La serie tiene estados pendientes')
			end
		end
		else
		begin
			insert into #ResultadoTemp values(@UltimoAlmacen,2,'La serie tiene stock')
		end
	end
	else
	begin
		insert into #ResultadoTemp values(@UltimoAlmacen,1,'Error de trazabilidad')
	end
	select * from #ResultadoTemp
END
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SERIES_ValidarSalida' AND type = 'P')
DROP PROCEDURE USP_PRI_SERIES_ValidarSalida
go
CREATE PROCEDURE USP_PRI_SERIES_ValidarSalida
@Serie VARCHAR(20)
WITH ENCRYPTION
AS
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#ResultadoTemp')
	BEGIN
		drop table #ResultadoTemp
	END
	create table #ResultadoTemp (Cod_Almacen Varchar(50),Cod_Error int,Observacion Varchar(50))
	if(dbo.UFN_PRI_SERIES_ValidarTrazabilidad(@Serie)=0)
	begin
		declare @UltimoAlmacen varchar(20)=dbo.UFN_PRI_SERIES_UltimoAlmacen(@Serie)
		if(@UltimoAlmacen is null)
			set @UltimoAlmacen=''
		if(dbo.UFN_PRI_SERIES_ContarStock(@Serie)>0)
		begin
			if(dbo.UFN_PRI_SERIES_ContarPendientes(@Serie)=0)
			begin
				insert into #ResultadoTemp values(@UltimoAlmacen,4,'Todo correcto')
			end
			else
			begin
				insert into #ResultadoTemp values(@UltimoAlmacen,3,'La serie tiene estados pendientes')
			end
		end
		else
		begin
			insert into #ResultadoTemp values(@UltimoAlmacen,2,'La serie no tiene stock')
		end
	end
	else
	begin
		insert into #ResultadoTemp values(@UltimoAlmacen,1,'Error de trazabilidad')
	end
	select * from #ResultadoTemp
END
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_VIS_SERIES_StockAlmacen')
DROP FUNCTION UFN_VIS_SERIES_StockAlmacen
go
CREATE FUNCTION UFN_VIS_SERIES_StockAlmacen(@Serie as varchar(512), @Cod_Almacen as varchar(32))
RETURNS int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Stock as int;
	SET @Stock = (SELECT isnull(sum(stock),0) FROM  VIS_SERIES where serie = @Serie AND Cod_Almacen = @Cod_Almacen);
	RETURN @Stock;
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_Buscar' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar
@Cod_Caja as  varchar(32)=null,
@Buscar  varchar(512),
@CodTipoProducto as  varchar(8) = NULL,
@Cod_Categoria as  varchar(32) = NULL,
@Cod_Precio as  varchar(32) = NULL,
@Flag_Stock AS BIT = 1,
@Flag_RequiereStock as bit = 1
WITH ENCRYPTION
AS
BEGIN

SET DATEFORMAT dmy;

	SELECT        P.Id_Producto, P.Des_LargaProducto AS Nom_Producto, P.Cod_Producto, PS.Stock_Act, PS.Precio_Venta, 
					M.Nom_Moneda, PS.Cod_Almacen, 0 AS Descuento,
					'NINGUNO' AS TipoDescuento, A.Des_Almacen, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida,P.Flag_Stock,PS.Precio_Compra, 
				case when @Cod_Precio is null then 0 else dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto,PS.Cod_UnidadMedida,PS.Cod_Almacen,@Cod_Precio) end as Precio,
				P.Cod_TipoOperatividad
	FROM            PRI_PRODUCTOS AS P INNER JOIN
							 PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
							 VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda INNER JOIN
							 ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
							 VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
							 CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
	WHERE  (P.Cod_TipoProducto = @CodTipoProducto OR @CodTipoProducto IS NULL) 
	AND ( (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Producto LIKE @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
	AND (P.Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria))  OR @Cod_Categoria IS NULL) 
	AND  (ca.Cod_Caja = @Cod_Caja or @Cod_Caja is null)
	AND (P.Flag_Activo = 1)
	AND (@Flag_RequiereStock = 1 OR PS.Stock_Act <> 0)	
	order by Cod_Producto
END
go
SELECT * FROM VIS_SERIES WHERE Serie = '356656075499987'
select * from PRI_PRODUCTOS where Cod_Producto='70003180'
select * from ALM_ALMACEN where Cod_Almacen='A0006'
--  USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','356656075499987'
--  USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','895110641000125038'
--  USP_VIS_PRECIOS_xCategoriayCod_Precio '01','CPRAA'

--  select * from Vis_PRECIOS
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
@Cod_Almacen as  varchar(32) ,
@Buscar  varchar(512)
WITH ENCRYPTION
AS
BEGIN
SELECT DISTINCT Cod_Producto,Nom_Producto,Serie
FROM
	(SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie 
	FROM            CAJ_SERIES AS S INNER JOIN
							 ALM_ALMACEN_MOV_D AS MD ON S.Item = MD.Item AND S.Id_Tabla = MD.Id_AlmacenMov INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto INNER JOIN
							 ALM_ALMACEN_MOV AS M ON M.Id_AlmacenMov = MD.Id_AlmacenMov
	WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV') AND M.Cod_Almacen = @Cod_Almacen AND M.Cod_Turno IS NOT NULL AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
	AND ( S.Serie LIKE '%'+ @Buscar )
	UNION
	SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie 
	FROM            CAJ_SERIES AS S INNER JOIN
							  CAJ_COMPROBANTE_D AS MD ON S.Item = MD.id_Detalle AND S.Id_Tabla = MD.id_ComprobantePago INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto
	WHERE        (S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO') AND MD.Cod_Almacen = @Cod_Almacen AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
	AND  ( S.Serie LIKE '%'+  @Buscar)) AS S

END
go


-- execute USP_VIS_PRECIOS_xCategoriayCod_Precio 01,'CPRAA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_xCategoriayCod_Precio' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_xCategoriayCod_Precio
go
CREATE PROCEDURE USP_VIS_PRECIOS_xCategoriayCod_Precio
@Cod_Categoria int,
@Cod_precio varchar(10)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Precio,Nom_Precio,Cod_PrecioPadre
	FROM  VIS_PRECIOS where Cod_Categoria=@Cod_Categoria and Cod_Precio=@Cod_precio and Estado=1
END
go

---Recupera una lista de tipos de precio en base a un nombre de producto (el nombre debe ser identico)
-- USP_PRI_PRODUCTOPRECIO_TPreciosXNombre 'AZUMI L2Z NEGRO PB'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOPRECIO_TPreciosXNombre' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOPRECIO_TPreciosXNombre
go
CREATE PROCEDURE USP_PRI_PRODUCTOPRECIO_TPreciosXNombre
@Nombre varchar(500)
WITH ENCRYPTION
AS
BEGIN
	declare @Idproducto varchar(50)=(select top(1) Id_Producto from VIS_PRODUCTOS where Nom_Producto=@Nombre)
	select DISTINCT  Cod_TipoPrecio from PRI_PRODUCTO_PRECIO where Id_Producto=@Idproducto
END
go

---Recupera los detalles de un producto en base a su codigo de producto y el almacen asociado
-- USP_PRI_PRODUCTOPRECIO_TPreciosXCodProdyAlmacen '70003180','A0010','CPRAA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOPRECIO_TPreciosXCodProdyAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOPRECIO_TPreciosXCodProdyAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTOPRECIO_TPreciosXCodProdyAlmacen
@Cod_Producto varchar(50),
@Cod_Almacen varchar(10),
@Cod_Precio varchar(10)
WITH ENCRYPTION
AS
BEGIN
	declare @Idproducto varchar(50)=(select top(1) Id_Producto from VIS_PRODUCTOS where Cod_Producto=@Cod_Producto)
	select Top 1 * from PRI_PRODUCTO_PRECIO where Id_Producto=@Idproducto and Cod_TipoPrecio=@Cod_Precio and Cod_Almacen=@Cod_Almacen
END
go

---Recupera los detalles de un producto en base a su codigo de producto, usado para recuperar la categoria
-- USP_PRI_PRODUCTO_TPreciosXCodProd '70001526'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_TPreciosXCodProd' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_TPreciosXCodProd
go
CREATE PROCEDURE USP_PRI_PRODUCTO_TPreciosXCodProd
@Cod_Producto varchar(50)
WITH ENCRYPTION
AS
BEGIN
	select Top 1 * from PRI_PRODUCTOS where Cod_Producto=@Cod_Producto
END
go


