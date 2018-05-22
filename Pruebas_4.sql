--SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,CASE when PP.Cod_TipoPrecio IS NULL then NULL else PP.Cod_TipoPrecio  end as Cod_TipoPrecio,
--					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
--					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
--FROM            PRI_PRODUCTOS AS P INNER JOIN
--                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
--                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
--                         VIS_PRECIOS AS VP 
--WHERE        (VS.Serie = '356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01'

--VERSION ESTABLE con duplicados pero diferenciables
--SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,
--					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
--					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
--FROM            PRI_PRODUCTOS AS P INNER JOIN
--                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
--                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
--                         VIS_PRECIOS AS VP 
--WHERE        (VS.Serie LIKE '%'+'356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01' 
--order by VP.Cod_Precio

SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,
					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
                         VIS_PRECIOS AS VP 
WHERE        (VS.Serie LIKE '%'+'356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01' 
--order by VP.Cod_Precio
--and VP.Cod_Precio='CPA8Ñ'
--and VP.Cod_Precio='1'
--and PP.Cod_TipoPrecio=VP.Cod_Precio
--select * from PRI_CATEGORIA
--select * from VIS_PRECIOS
--select * from PRI_PRODUCTOS where Id_Producto=92
--select * from VIS_PRECIOS where Cod_Precio='CPRAA' 
--select * from PRI_PRODUCTO_PRECIO as PP inner join VIS_PRECIOS as VP on PP.Cod_TipoPrecio=VP.Cod_Precio  where Id_Producto=92 and Cod_Almacen='A0006' order by Cod_TipoPrecio
SELECT        VS.Serie, VS.Cod_Producto, VS.Des_Producto, VS.Des_Almacen, VS.Stock, VS.Estado, PP.Id_Producto, PP.Cod_UnidadMedida, PP.Cod_Almacen, PP.Cod_TipoPrecio, PP.Valor, P.Id_Producto AS Expr1, 
                         P.Cod_Producto AS Expr2, P.Cod_Marca, P.Des_CortaProducto, P.Nom_Producto, P.Des_LargaProducto, P.Cod_TipoProducto, P.Cod_Categoria, VIS_PRECIOS.Nom_Precio, VIS_PRECIOS.Estado AS Expr3, 
                         VP.Orden
FROM            VIS_SERIES AS VS INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON VS.Id_Producto = PP.Id_Producto INNER JOIN
                         PRI_PRODUCTOS AS P ON VS.Id_Producto = P.Id_Producto INNER JOIN
                         VIS_PRECIOS as VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
WHERE        (VS.Serie LIKE '%' + '75499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006')
select * from VIS_PRECIOS
select * from PRI_PRODUCTO_PRECIO
select * from PRI_PRODUCTOS
select * from VIS_SERIES 

SELECT        PP.Cod_TipoPrecio, VS.Cod_Producto, P.Id_Producto, PP.Valor, PP.Cod_Almacen, PP.Cod_UnidadMedida, PP.Id_Producto AS Expr1, VP.Nom_Precio, VP.Cod_Precio, VS.Serie, VS.Des_Almacen, 
                         P.Des_CortaProducto, P.Des_LargaProducto, P.Nom_Producto
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto AND P.Cod_Producto = VS.Cod_Producto INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
                         VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
where (VS.Serie LIKE '%' + '75499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006')

