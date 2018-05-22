SELECT        P.Des_CortaProducto, A.Cod_Almacen, P.Id_Producto
FROM            ALM_ALMACEN AS A CROSS JOIN
                         PRI_PRODUCTOS AS P
where p.Des_CortaProducto = 'Alcatel OT5050 POP S3'