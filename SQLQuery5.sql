USE [PALERPmelqui]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_PRI_CATEGORIA_TArbol]

SELECT	'Return Value' = @return_value

GO

select DISTINCT(P.Id_Producto),P.Cod_Producto,P.Nom_Producto,PS.Stock_Act from PRI_PRODUCTOS  as P inner join PRI_PRODUCTO_STOCK as PS inner join PRI_PRODUCTO_PRECIO as PP on P.Cod_Categoria='01' and PS.Stock_Act>0 and PS.Cod_Almacen='A0006' and PP.Id_Producto=P.I order by P.Cod_Producto ASC

SELECT    P.Cod_Producto, P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto, PP.Valor, PS.Stock_Act, PP.Id_Producto
FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_Almacen = PS.Cod_Almacen AND P.Id_Producto = PS.Id_Producto
WHERE        (P.Cod_Categoria = '01') AND (PS.Stock_Act > 0) AND (PS.Cod_Almacen = 'A0006') AND PP.Cod_TipoPrecio='CPRAA'

select * from PRI_PRODUCTOS where Cod_Producto='70003180'

select * from ALM_ALMACEN

select Cod_Producto, count(Cod_Producto)
from dbo.PRI_PRODUCTOS
group by Cod_Producto
having count(Cod_Producto) > 1

select * from VIS_SERIES where Id_Producto='92' and Cod_Almacen='A00143'


select * from PRI_PRODUCTO_STOCK where Cod_Almacen='A00143'  and Stock_Act>0 and Id_Producto='92'

select * from PRI_PRODUCTO_PRECIO where Id_Producto='704' or Id_Producto='652'
select * from VIS_PRECIOS 