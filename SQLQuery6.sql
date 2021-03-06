-- USP_PRI_PRODUCTOS_Buscar '0006','',NULL,'01','001',1,1
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
	if(@Flag_RequiereStock=0)
	begin
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
	end
	else
	begin
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
	AND  PS.Stock_Act > 0
	order by Cod_Producto
	end
END
go
