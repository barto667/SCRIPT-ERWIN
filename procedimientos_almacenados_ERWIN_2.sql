IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_CATEGORIA_TArbol'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_CATEGORIA_TArbol
go
CREATE PROCEDURE USP_PRI_CATEGORIA_TArbol
    WITH ENCRYPTION
AS 
BEGIN
WITH CATEGORIAS (Cod_Categoria, Des_Categoria, Level, Ordenar,Cod_Padre)
AS
(
select Cod_Categoria,CONVERT( varchar(1024),Des_Categoria), 0 as Level,CONVERT( varchar(1024),Cod_Categoria),Cod_CategoriaPadre
from PRI_CATEGORIA
where Cod_CategoriaPadre is null OR Cod_CategoriaPadre=''
UNION ALL
select c.Cod_Categoria,
CONVERT( varchar(1024),REPLICATE('',level+1)+'-->'+c.Des_Categoria), 
Level + 1, CONVERT( varchar(1024),Ordenar+c.Cod_Categoria),Cod_CategoriaPadre
from PRI_CATEGORIA AS C INNER JOIN CATEGORIAS AS CA
on  Cod_CategoriaPadre = ca.Cod_Categoria 
)
select Cod_Categoria,Des_Categoria, Level,Cod_Padre
from CATEGORIAS
ORDER BY Ordenar
END
go

--Autor Erwin M. Rayme Chambi,23/11/2016
--Metodo que trae los productos con stock >0 por codigo de categoria, un codigo de almacen y un codigo de precio
--Devuelve el codigo de producto, sus nombres  y precio de venta
--USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock '01','A0006','CPRAA'
IF EXISTS ( SELECT  name FROM    sysobjects WHERE   name = 'USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock' AND type = 'P' ) 
   DROP PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
go
CREATE PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
@CodCategoria varchar(10),
@CodAlmacen varchar(10),
@CodPrecio varchar(10)
WITH ENCRYPTION
AS 
BEGIN
	SELECT  DISTINCT   P.Cod_Producto, P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto, PP.Valor, PS.Stock_Act, PP.Id_Producto
	FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_Almacen = PS.Cod_Almacen AND P.Id_Producto = PS.Id_Producto
	WHERE        (P.Cod_Categoria = @CodCategoria) AND (PS.Stock_Act > 0) AND (PS.Cod_Almacen = @CodAlmacen) AND (PP.Cod_TipoPrecio=@CodPrecio)
END
go

select * from CAJ_CAJAS
-- USP_PRI_PRODUCTOS_Buscar '0006','00',NULL,'01','001',null,0
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
	AND (@Flag_RequiereStock = 0 OR PS.Stock_Act >= 0)	
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
	AND (@Flag_RequiereStock = 1 AND PS.Stock_Act > 0)
	order by Cod_Producto
	end
END
go

---Recupera los detalles de un producto en base a su codigo de producto, usado para recuperar la categoria
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
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

---Recupera los detalles de un producto y precios en base a un codigo de producto
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  24/11/2016
-- USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre '70003180','A0006','CPRAA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
@Cod_Producto varchar(50),
@Cod_Almacen varchar(50),
@Cod_TipoPrecio varchar(50)
WITH ENCRYPTION
AS
BEGIN
	SELECT  *
	FROM            PRI_PRODUCTOS as P INNER JOIN
							 PRI_PRODUCTO_PRECIO as PP ON P.Id_Producto =PP.Id_Producto
	where P.Cod_Producto=@Cod_Producto and Cod_Almacen=@Cod_Almacen and Cod_TipoPrecio=@Cod_TipoPrecio
END
go