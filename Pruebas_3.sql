declare @Cod_Producto varchar(500)='70003180'
declare @Cod_Almacen varchar(50)='A0010'
declare @Idproducto varchar(50)=(select top(1) Id_Producto from VIS_PRODUCTOS where Cod_Producto=@Cod_Producto)
select * from PRI_PRODUCTO_PRECIO where Id_Producto=@Idproducto
declare @Cod_TipoPrecio varchar (10) =(select top 1  Cod_TipoPrecio from PRI_PRODUCTO_PRECIO where Id_Producto=@Idproducto)
select * from PRI_PRODUCTO_PRECIO where Id_Producto=@Idproducto and Cod_TipoPrecio=@Cod_TipoPrecio and Cod_Almacen=@Cod_Almacen
select * from PRI_PRODUCTOS where Cod_Producto=@Cod_Producto
