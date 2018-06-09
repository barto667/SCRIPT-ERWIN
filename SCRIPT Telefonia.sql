go
-- Archivo: ProcedimientosERWIN.sql
-- Versión: v1.0.0
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  10/10/2016
-- Copyright R&L Consultores Peru2014
-- execute USP_PRI_CATEGORIASPADRE
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CATEGORIASPADRE' AND type = 'P')
DROP PROCEDURE USP_PRI_CATEGORIASPADRE
go
CREATE PROCEDURE USP_PRI_CATEGORIASPADRE
WITH ENCRYPTION
AS
BEGIN
	SELECT        Cod_Categoria,Des_Categoria,Cod_UsuarioReg
	FROM            PRI_CATEGORIA where  Cod_CategoriaPadre='' or Cod_CategoriaPadre is null
END

go

-- execute USP_VIS_PRECIOS_xCategoria 01
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_xCategoria' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_xCategoria
go
CREATE PROCEDURE USP_VIS_PRECIOS_xCategoria
@Cod_Categoria int
WITH ENCRYPTION
AS
BEGIN
	SELECT [Cod_Precio]
      ,[Nom_Precio]
      ,[Cod_Categoria]
      ,[Cod_PrecioPadre]
      ,[Orden]
      ,[Estado]
	FROM            VIS_PRECIOS where Cod_Categoria=@Cod_Categoria
END
go

--Eliminar un plan precio en base al codigo y desplaza los ordenes segun sea necesario
--No elimina los hijos recursivamente
--exec USP_VIS_PRECIOS_EliminarPlan 'P',11
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_EliminarPlan' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_EliminarPlan

go

CREATE PROCEDURE USP_VIS_PRECIOS_EliminarPlan
@Cod_Precio varchar(10),
@Cod_Categoria int
WITH ENCRYPTION
AS
BEGIN
	--IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#aux1')
	--BEGIN
	--	drop table #aux1
	--END
	--select * into #aux1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=3 and Cadena=@Cod_Categoria
	--IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#aux2')
	--BEGIN
	--	drop table #aux2
	--END
	--select * into #aux2 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=1 and Cadena=@Cod_Precio

	declare @Id_Fila int = (select Top(1)Cod_Fila from PAR_FILA  where Cod_Tabla=83 and Cod_Fila=(select top(1) Cod_Fila from PAR_FILA where Cod_Tabla=83 and Cadena=@Cod_Precio and Cod_Columna=1))
	--declare @Id_Fila int=(select TOP(1) T1.Cod_Fila from #aux1 as T1 inner join #aux2 as T2 on T1.Cod_Fila=T2.Cod_Fila)
	declare @Cod_Padre varchar(10) = (select top(1) Cadena from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cod_Fila=@Id_Fila)
	declare @Orden int =   (select top(1)Numero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila)

	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp1')
	BEGIN
		drop table #temp1
	END
	select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4

	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp2')
	BEGIN
		drop table #temp2
	END
	select Cod_Fila into #temp2 from #temp1  where Cadena=@Cod_Padre

	declare @fila int;
	declare cursor_fila1 cursor for select T2.Cod_Fila from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T2.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila and T2.Numero>@Orden
	open cursor_fila1
	fetch cursor_fila1 into @fila
	WHILE (@@FETCH_STATUS = 0 )
	begin
	update PAR_FILA set Numero=Numero-1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila= @fila;
	fetch cursor_fila1 into @fila;
	end
	close cursor_fila1
	deallocate cursor_fila1
	--Eliminar tabla
	delete from PAR_FILA where Cod_Tabla=83 and Cod_Fila=@Id_Fila
END

go


--Insertar un plan en la tabla de los precios con un orden especificado
--EXEC USP_VIS_PRECIOS_InsertarPlan 'P','POSTPAGO','01','',0,1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_InsertarPlan' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_InsertarPlan

go

CREATE PROCEDURE USP_VIS_PRECIOS_InsertarPlan
@Cod_Precio varchar(10),
@Nom_Precio varchar(50),
@Cod_Categoria varchar(10),
@Cod_PrecioPadre varchar(10),
@Orden int,
@Estado bit

WITH ENCRYPTION
AS
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp1')
	BEGIN
		drop table #temp1
	END
	select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp2')

	BEGIN
		drop table #temp2
	END
	select Cod_Fila into #temp2 from #temp1  where Cadena=@Cod_PrecioPadre

	declare @Orden2 int = @Orden +1;

	declare @numero_fila int = (select MAX(Cod_Fila)+1 from PAR_FILA where Cod_Tabla=83)
	if (@numero_fila is null)
	begin
		set @numero_fila=1
	end
	else
	begin
		set @numero_fila= (select MAX(Cod_Fila)+1 from PAR_FILA where Cod_Tabla=83)
	end

	EXEC USP_PAR_FILA_G '083','001',@numero_fila,@Cod_Precio,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','002',@numero_fila,@Nom_Precio,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','003',@numero_fila,@Cod_Categoria,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','004',@numero_fila,@Cod_PrecioPadre,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','005',@numero_fila,NULL,@Orden2,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','006',@numero_fila,NULL,NULL,NULL,NULL,@Estado,1,'MIGRACION';

	declare @fila int;
	declare cursor_fila2 cursor for select T2.Cod_Fila from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T2.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila and T2.Entero>@Orden
	open cursor_fila2;
	fetch cursor_fila2 into @fila;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
		update PAR_FILA set Numero=Numero+1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila= @fila;
	fetch cursor_fila2 into @fila;
	end;
	close cursor_fila2;
	deallocate cursor_fila2;
END

go



--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_InsertarPlanU' AND type = 'P')
--DROP PROCEDURE USP_VIS_PRECIOS_InsertarPlanU
--go
--CREATE PROCEDURE USP_VIS_PRECIOS_InsertarPlanU
--@Cod_Precio varchar(10),
--@Nom_Precio varchar(50),
--@Cod_Categoria varchar(10),
--@Cod_PrecioPadre varchar(10),
--@Estado bit

--WITH ENCRYPTION
--AS
--BEGIN
--	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp1')
--	BEGIN
--		drop table #temp1
--	END
--	select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cadena=@Cod_PrecioPadre
--	declare @Orden int= (select MAX(T1.Entero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
--	if (@Orden is null)
--	begin
--		set @Orden=0
--	end
--	else
--	begin
--		set @Orden= (select MAX(T1.Entero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
--	end
--	Exec USP_VIS_PRECIOS_InsertarPlan @Cod_Precio,@Nom_Precio,@Cod_Categoria,@Cod_PrecioPadre,@Orden,@Estado
--END
--go

--Insertar un plan en la tabla de los precios sin un orden especificado
--insertandolo al final de los planes
--EXEC USP_VIS_PRECIOS_InsertarPlanU 'P10','POSTPAGO 10','01','P',1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_InsertarPlanU' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_InsertarPlanU
go

CREATE PROCEDURE USP_VIS_PRECIOS_InsertarPlanU
@Cod_Precio varchar(10),
@Nom_Precio varchar(50),
@Cod_Categoria varchar(10),
@Cod_PrecioPadre varchar(10),
@Estado bit

WITH ENCRYPTION
AS
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp1')
	BEGIN
		drop table #temp1
	END
	select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cadena=@Cod_PrecioPadre
	declare @Orden int= (select MAX(T1.Numero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
	if (@Orden is null)
	begin
		set @Orden=0
	end
	else
	begin
		set @Orden= (select MAX(T1.Numero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
	end
	Exec USP_VIS_PRECIOS_InsertarPlan @Cod_Precio,@Nom_Precio,@Cod_Categoria,@Cod_PrecioPadre,@Orden,@Estado
END

go

--Actualizar los estados de un plan y sus hijos
--EXEC USP_VIS_PRECIOS_ActualizarEstados 'P',1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_ActualizarEstados' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_ActualizarEstados

go
CREATE PROCEDURE USP_VIS_PRECIOS_ActualizarEstados
@Cod_Precio varchar(10),
@Estado bit
WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Fila int= (select MAX(Cod_Fila) from PAR_FILA where Cod_Tabla=83 and Cod_Columna=1 and Cadena =@Cod_Precio)
	update PAR_FILA set Boleano=@Estado where Cod_Tabla=83 and Cod_Columna=6 and Cod_Fila=@Cod_Fila
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#temp1')
	BEGIN
		drop table #temp1
	END
	select Cod_Fila into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cadena=@Cod_Precio

	if(@Estado=0)
	begin
	declare @fila varchar(10);
	declare cursor_fila3 cursor for select Cadena from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=1  and T1.Cod_Fila=T2.Cod_Fila
	open cursor_fila3;
	fetch cursor_fila3 into @fila;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
	EXEC USP_VIS_PRECIOS_ActualizarEstados @fila,@Estado
	fetch cursor_fila3 into @fila
	end;
	close cursor_fila3;
	deallocate cursor_fila3;
	end
END

go

--Modifica un plan
--EXEC USP_VIS_PRECIOS_ModificarPlan 'POSTPAGO CONEXION','POSTPAGO RECONECTA',0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_ModificarPlan' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_ModificarPlan

go
CREATE PROCEDURE USP_VIS_PRECIOS_ModificarPlan
@Cod_Precio varchar(10),
@Nom_Precio varchar(50),
@Estado bit

WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Fila int= (select MAX(Cod_Fila) from PAR_FILA where Cod_Tabla=83 and Cod_Columna=1 and Cadena =@Cod_Precio)
	update PAR_FILA set Cadena=@Nom_Precio where Cod_Tabla=83 and Cod_Columna=2 and Cod_Fila=@Cod_Fila
	EXEC USP_VIS_PRECIOS_ActualizarEstados @Cod_Precio,@Estado
END

go


--Recupera los datos de un plan en base a su codigo 
--EXEC USP_VIS_PRECIOS_RecuperarDatos 'PRE'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_RecuperarDatos' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_RecuperarDatos
go
CREATE PROCEDURE USP_VIS_PRECIOS_RecuperarDatos
@Cod_Precio varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select * from VIS_PRECIOS where Cod_Precio=@Cod_Precio
END
go


--Recupera los planes activos en base a un codigo de categoria
--EXEC USP_VIS_PRECIOS_RecuperarPlanesActivos '14'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_RecuperarPlanesActivos' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_RecuperarPlanesActivos
go
CREATE PROCEDURE USP_VIS_PRECIOS_RecuperarPlanesActivos
@Cod_Categoria varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select * from VIS_PRECIOS where Cod_Categoria=@Cod_Categoria and Estado=1
END
go

--Recupera los planes que tienen por padre el codigo del producto
--EXEC USP_VIS_PRECIOS_RecuperarPlanesXCodPadre 'PP'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_RecuperarPlanesXCodPadre' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_RecuperarPlanesXCodPadre
go
CREATE PROCEDURE USP_VIS_PRECIOS_RecuperarPlanesXCodPadre
@Cod_PrecioPadre varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select * from VIS_PRECIOS where Cod_PrecioPadre=@Cod_PrecioPadre
END
go


--Recupera los productos en base a una descripcion corta de un producto de la tabla PRI_PRODUCTOS
--EXEC USP_PRI_PRODUCTO_TXNombreCorto 'Alcatel 3075'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_TXNombreCorto' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_TXNombreCorto
go
CREATE PROCEDURE USP_PRI_PRODUCTO_TXNombreCorto
@Desc_Corta varchar(200)
WITH ENCRYPTION
AS
BEGIN
	select * from PRI_PRODUCTOS where Des_CortaProducto=@Desc_Corta
END
go

--Recupera una lista de precios y valores en base a la descripcion corta de un producto
--Exec USP_PRI_PRODUCTO_PRECIO_TXDesCorta 'Apple IPHONE 4S 32GB','CPRAA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TXDesCorta' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXDesCorta
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXDesCorta
@Des_Corta varchar(200),
@Cod_TipoPrecio varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select P.Id_Producto,P.Cod_Producto,P.Cod_Categoria,P.Cod_Marca,P.Cod_TipoProducto,P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto,PP.Cod_UsuarioReg,PP.Valor,PP.Cod_UnidadMedida 
	,PP.Cod_TipoPrecio
	from PRI_PRODUCTOS as P inner join PRI_PRODUCTO_PRECIO as PP on P.Des_CortaProducto=@Des_Corta and P.Id_Producto=PP.Id_Producto and PP.Cod_TipoPrecio=@Cod_TipoPrecio
END
go



--Guardar los precios en base a una Desc_Corta y un codigo de almacen
--exec USP_PRI_PRODUCTO_PRECIO_GXDesCortayAlmacen 'Apple IPHONE 4S 32GB','UNI','A00142','CPRAA',3399,'ADMINISTRADOR'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_GXDesCortayAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXDesCortayAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXDesCortayAlmacen
@Des_Corta varchar(200),
@Cod_Medida varchar(5),
@Cod_Almacen varchar(32),
@Cod_TipoPrecio varchar(5),
@Valor numeric(38,6),
@Cod_Usuario varchar(32)

WITH ENCRYPTION
AS
BEGIN 
	--Recuperamos todos los productos con la misma descripcion  y codigo de precio
	declare @Id_Producto int;
	declare cursor_fila4  cursor for select Id_Producto from PRI_PRODUCTOS where Des_CortaProducto=@Des_Corta
	open cursor_fila4;
	fetch cursor_fila4 into @Id_Producto;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
		exec USP_PRI_PRODUCTO_PRECIO_G @Id_Producto,@Cod_Medida,@Cod_Almacen,@Cod_TipoPrecio,@Valor,@Cod_Usuario
	fetch cursor_fila4 into @Id_Producto;
	end;
	close cursor_fila4;
	deallocate cursor_fila4;
END
go

--Guarda un precio de producto en base solo a la descripcion corta (en todos los almacenes)
-- exec USP_PRI_PRODUCTO_PRECIO_GXDesCorta 'Apple IPHONE 4S 32GB','UNI','CPRAA',149,'ADMINISTRADOR'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_GXDesCorta' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXDesCorta
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXDesCorta
@Des_Corta varchar(200),
@Cod_Medida varchar(5),
@Cod_TipoPrecio varchar(5),
@Valor numeric(38,6),
@Cod_Usuario varchar(32)

WITH ENCRYPTION
AS
BEGIN 
	--Recuperamos todos los productos con la misma descripcion  y codigo de precio
	declare @Cod_Almacen varchar(32);
	declare cursor_fila5 cursor for SELECT Cod_Almacen FROM ALM_ALMACEN 
	open cursor_fila5;
	fetch cursor_fila5 into @Cod_Almacen;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
		exec USP_PRI_PRODUCTO_PRECIO_GXDesCortayAlmacen @Des_Corta,@Cod_Medida,@Cod_Almacen,@Cod_TipoPrecio,@Valor,@Cod_Usuario
	fetch cursor_fila5 into @Cod_Almacen;
	end;
	close cursor_fila5;
	deallocate cursor_fila5;
END
go

-- Cuenta el stock de un producto en base a su serie y un codigo de almacen, 
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- select dbo.UFN_VIS_SERIES_StockAlmacen('356656075499987','A0006')
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

-- Recupera el codigo(s) de un producto(s), nombre(s) y  serie(s) en base a un codigo de almacen y los ultimos 6 digitos de la serie 
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','356656075499987'
-- USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','895110641000125038'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
--go
--CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
--@Cod_Almacen as  varchar(32) ,
--@Buscar  varchar(512)
--WITH ENCRYPTION
--AS
--BEGIN
--SELECT DISTINCT Cod_Producto,Nom_Producto,Serie,Id_Producto
--FROM
--	(SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto
--	FROM            CAJ_SERIES AS S INNER JOIN
--							 ALM_ALMACEN_MOV_D AS MD ON S.Item = MD.Item AND S.Id_Tabla = MD.Id_AlmacenMov INNER JOIN
--							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto INNER JOIN
--							 ALM_ALMACEN_MOV AS M ON M.Id_AlmacenMov = MD.Id_AlmacenMov
--	WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV') AND M.Cod_Almacen = @Cod_Almacen AND M.Cod_Turno IS NOT NULL AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
--	AND ( S.Serie LIKE '%'+ @Buscar )
--	UNION
--	SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto
--	FROM            CAJ_SERIES AS S INNER JOIN
--							  CAJ_COMPROBANTE_D AS MD ON S.Item = MD.id_Detalle AND S.Id_Tabla = MD.id_ComprobantePago INNER JOIN
--							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto
--	WHERE        (S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO') AND MD.Cod_Almacen = @Cod_Almacen AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
--	AND  ( S.Serie LIKE '%'+  @Buscar)) AS S

--END
--go

-- Recupera el codigo(s) de un producto(s), nombre(s) y  serie(s) en base a un codigo de almacen y los ultimos 6 digitos de la serie 
-- Modificado para agregar mas detalles a la consulta
-- Autor(es): Rayme Chambi Erwin Miuller,Erwin
-- Fecha de Creación:  04/11/2016,28/11/2016
-- USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','356656075499987'
-- USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','895110641000125038'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
@Cod_Almacen as  varchar(32) ,
@Buscar  varchar(512)
WITH ENCRYPTION
AS
BEGIN
SELECT DISTINCT Cod_Producto,Nom_Producto,Serie,Id_Producto,Cod_UnidadMedida,Cod_TipoOperatividad
FROM
	(SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto,PP.Cod_UnidadMedida,P.Cod_TipoOperatividad
	FROM            CAJ_SERIES AS S INNER JOIN
							 ALM_ALMACEN_MOV_D AS MD ON S.Item = MD.Item AND S.Id_Tabla = MD.Id_AlmacenMov INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto INNER JOIN
							 ALM_ALMACEN_MOV AS M ON M.Id_AlmacenMov = MD.Id_AlmacenMov INNER JOIN
							 PRI_PRODUCTO_PRECIO as PP ON PP.Id_Producto=P.Id_Producto AND PP.Cod_Almacen=@Cod_Almacen
	WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV') AND M.Cod_Almacen = @Cod_Almacen AND M.Cod_Turno IS NOT NULL AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
	AND ( S.Serie LIKE '%'+ @Buscar )
	UNION
	SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto,PP.Cod_UnidadMedida,P.Cod_TipoOperatividad
	FROM            CAJ_SERIES AS S INNER JOIN
							  CAJ_COMPROBANTE_D AS MD ON S.Item = MD.id_Detalle AND S.Id_Tabla = MD.id_ComprobantePago INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto INNER JOIN
							 PRI_PRODUCTO_PRECIO as PP ON PP.Id_Producto=P.Id_Producto AND PP.Cod_Almacen=@Cod_Almacen
	WHERE        (S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO') AND MD.Cod_Almacen = @Cod_Almacen AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
	AND  ( S.Serie LIKE '%'+  @Buscar)) AS S

END
go

-- Recupera los detalles de un precio activo en base a un codigo de categoria   y a un codigo de precio
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
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
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
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
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
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


---- USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen 11,'A0014'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen
--@id_Producto int,
--@Cod_Almacen varchar(32)
--WITH ENCRYPTION
--AS
--BEGIN
--SELECT P.Cod_Precio, P.Nom_Precio + ' [' +CONVERT(VARCHAR,ISNULL(convert(varchar,convert(decimal(8,2),F.Valor)), 0))+']' as Nom_Precio, P.Cod_PrecioPadre,ISNULL(F.Valor, 0) AS Precio FROM
--(SELECT        VP.Cod_Precio, VP.Cod_PrecioPadre, VP.Nom_Precio, VP.Orden
--FROM            VIS_PRECIOS AS VP INNER JOIN
--PRI_PRODUCTOS AS P ON VP.Cod_Categoria = P.Cod_Categoria
--WHERE P.Id_Producto = @id_Producto) AS P
--LEFT OUTER JOIN
--(SELECT        V.Cod_Precio, PP.Valor
--FROM            VIS_PRECIOS AS V INNER JOIN
--PRI_PRODUCTOS AS P ON V.Cod_Categoria = P.Cod_Categoria INNER JOIN
--PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto AND V.Cod_Precio = PP.Cod_TipoPrecio
--WHERE        (V.Estado = 1) AND (P.Id_Producto = @id_Producto) and PP.Cod_Almacen = @Cod_Almacen) AS F
--ON P.Cod_Precio = F.Cod_Precio
--ORDER BY P.Orden
--END
--go

-- Modificado para no mostrar precios en cero si es que no tienen un precio
-- USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen 92,'A0006'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacen
@id_Producto int,
@Cod_Almacen varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT P.Cod_Precio, P.Nom_Precio + CASE WHEN F.Valor is NOT NULL THEN  ' [' +CONVERT(VARCHAR,convert(decimal(8,2),F.Valor), 0)+']' else '' end  as Nom_Precio, P.Cod_PrecioPadre,ISNULL(F.Valor, 0) AS Precio FROM
(SELECT        VP.Cod_Precio, VP.Cod_PrecioPadre, VP.Nom_Precio, VP.Orden
FROM            VIS_PRECIOS AS VP INNER JOIN
PRI_PRODUCTOS AS P ON VP.Cod_Categoria = P.Cod_Categoria
WHERE P.Id_Producto = @id_Producto) AS P
LEFT OUTER JOIN
(SELECT        V.Cod_Precio, PP.Valor
FROM            VIS_PRECIOS AS V INNER JOIN
PRI_PRODUCTOS AS P ON V.Cod_Categoria = P.Cod_Categoria INNER JOIN
PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto AND V.Cod_Precio = PP.Cod_TipoPrecio
WHERE        (V.Estado = 1) AND (P.Id_Producto = @id_Producto) and PP.Cod_Almacen = @Cod_Almacen) AS F
ON P.Cod_Precio = F.Cod_Precio
ORDER BY P.Orden
END
go 







-- 29/12/2016



IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen
@Id_Producto int,
@Cod_Almacen varchar(10)
WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Categoria varchar(10) =(select Top 1 Cod_Categoria from PRI_PRODUCTOS where Id_Producto=@Id_Producto)
	declare @Cod_Precio varchar(10)
	DECLARE cCod_Precio CURSOR LOCAL FOR select Cod_Precio from VIS_PRECIOS where Cod_Categoria=@Cod_Categoria
	--Abrimos el cursor de los precios
	open cCod_Precio
	FETCH NEXT FROM cCod_Precio INTO @Cod_Precio
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		exec USP_PRI_PRODUCTO_PRECIO_G @Id_Producto,'NIU',@Cod_Almacen,@Cod_Precio,0,'MIGRACION'
		FETCH NEXT FROM cCod_Precio INTO @Cod_Precio
	END
	CLOSE cCod_Precio
	DEALLOCATE cCod_Precio
END
go


---- Procedimiento que inserta valores un producto realizando las permutaciones para un producto
---- El producto debe de existir y estar en la base de datos
---- USP_PRI_PRODUCTO_PermutarProducto 1632
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarProducto' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PermutarProducto
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarProducto
--@Id_Producto int
--WITH ENCRYPTION
--AS
--BEGIN
--	--Recorremos todos los almacenes
--	--Agregamos o modificamos en PRI_PRODUCTOSTOCK por cada alamcen
--	declare @Cod_Almacen varchar(10)
--	DECLARE cCod_Almacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'


--	open cCod_Almacen
--	FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
--		FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
--	END
--	CLOSE cCod_Almacen
--	DEALLOCATE cCod_Almacen

--	--Generar los campos en PRI_Producto_Precio
--	--Generamos una fila por cada combiunacion entre un almacen y un precio,
--	-- es decir combinar almacenes de pri_producto_stock por los precios
--	-- Recuperamos primero el codigo de categoria del producto
	
--	declare @Cod_Almacen2 varchar(10)

--	DECLARE cCod_Almacen2 CURSOR LOCAL FOR select Cod_Almacen from PRI_PRODUCTO_STOCK where Id_Producto=@Id_Producto 
	

--	open cCod_Almacen2
--	FETCH NEXT FROM cCod_Almacen2 INTO @Cod_Almacen2
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto,@Cod_Almacen2
--		FETCH NEXT FROM cCod_Almacen2 INTO @Cod_Almacen2
--	END
--	CLOSE cCod_Almacen2
--	DEALLOCATE cCod_Almacen2

--END
--go



	-- Procedimiento que inserta valores un producto realizando las permutaciones para un producto
-- El producto debe de existir y estar en la base de datos, si el flag es 0 entonces no sobrescribe si existe, si es uno lo 
-- sobrescribe
-- USP_PRI_PRODUCTO_PermutarProducto 1632,0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarProducto' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarProducto
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarProducto
@Id_Producto int,
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	--Recorremos todos los almacenes
	--Agregamos o modificamos en PRI_PRODUCTOSTOCK por cada alamcen
	declare @Cod_Almacen varchar(10)
	DECLARE cCod_Almacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'


	open cCod_Almacen
	FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		if(@FlagInicializar=1) --Limpiar e inicializar en cero el stock, si existe lo pone en cero, si no lo agrega con cero
		begin
			exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
		end
		else
		begin
			IF NOT EXISTS (select * from PRI_PRODUCTO_STOCK where Id_Producto=@Id_Producto and Cod_Almacen=@Cod_Almacen) --Prueba logica, solo si no existe los agrega
			begin
				exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
			end
		end

		FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
	END
	CLOSE cCod_Almacen
	DEALLOCATE cCod_Almacen
	--Generar los campos en PRI_Producto_Precio
	--Generamos una fila por cada combiunacion entre un almacen y un precio,
	-- es decir combinar almacenes de pri_producto_stock por los precios
	-- Recuperamos primero el codigo de categoria del producto
	
	declare @Cod_Almacen2 varchar(10)

	DECLARE cCod_Almacen2 CURSOR LOCAL FOR select Cod_Almacen from PRI_PRODUCTO_STOCK where Id_Producto=@Id_Producto 
	

	open cCod_Almacen2
	FETCH NEXT FROM cCod_Almacen2 INTO @Cod_Almacen2
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		if(@FlagInicializar=1) --Limpiar e inicializar en cero el stock, si existe lo pone en cero, si no lo agrega con cero
		begin
			exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto,@Cod_Almacen2
		end
		else
		begin
			IF NOT EXISTS (select * from PRI_PRODUCTO_PRECIO where Id_Producto=@Id_Producto and Cod_Almacen=@Cod_Almacen2) --Prueba logica, solo si no existe los agrega
			begin
				exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto,@Cod_Almacen2
			end
		end
		FETCH NEXT FROM cCod_Almacen2 INTO @Cod_Almacen2
	END
	CLOSE cCod_Almacen2
	DEALLOCATE cCod_Almacen2

END
go


-- USP_PRI_PRODUCTO_PermutarTodosProductos '01'

--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarTodosProductos' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PermutarTodosProductos
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarTodosProductos
--@Cod_Categoria varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	declare @Id_Producto varchar(10)
--	DECLARE cIdProducto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS where Cod_Categoria=@Cod_Categoria
--	--Abrimos el cursor de los precios
--	open cIdProducto
--	FETCH NEXT FROM cIdProducto INTO @Id_Producto
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		--Guardamos los datos en el pri_producto_precio
--		exec USP_PRI_PRODUCTO_PermutarProducto @Id_Producto
--		FETCH NEXT FROM cIdProducto INTO @Id_Producto
--	END
--	CLOSE cIdProducto
--	DEALLOCATE cIdProducto
--END
--go

-- USP_PRI_PRODUCTO_PermutarTodosProductos '01',0

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarTodosProductos' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarTodosProductos
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarTodosProductos
@Cod_Categoria varchar(10),
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	declare @Id_Producto int
	DECLARE cIdProducto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS where Cod_Categoria=@Cod_Categoria
	--Abrimos el cursor de los precios
	open cIdProducto
	FETCH NEXT FROM cIdProducto INTO @Id_Producto
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		exec USP_PRI_PRODUCTO_PermutarProducto @Id_Producto,@FlagInicializar
		FETCH NEXT FROM cIdProducto INTO @Id_Producto
	END
	CLOSE cIdProducto
	DEALLOCATE cIdProducto
END
go



---- Procedimiento que inserta valores un producto realizando las permutaciones para un almacen
---- El almacen debe de existir y estar en la base de datos
---- USP_PRI_PRODUCTO_PermutarAlmacen 'A003'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarAlmacen' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PermutarAlmacen
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarAlmacen
--@Cod_Almacen varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	--Recorremos todos los productos
--	--Agregamos o modificamos en PRI_PRODUCTOSTOCK por cada producto
--	declare @Id_Producto int
--	DECLARE cId_Producto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS
--	open cId_Producto
--	FETCH NEXT FROM cId_Producto INTO @Id_Producto
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
--		FETCH NEXT FROM cId_Producto INTO @Id_Producto
--	END
--	CLOSE cId_Producto
--	DEALLOCATE cId_Producto

--	--Generar los campos en PRI_Producto_Precio
--	--Generamos una fila por cada combiunacion entre un id y un precio,
--	--es decir combinar productos de pri_producto_stock por los precios
	
--	declare @Id_Producto2 int

--	DECLARE cId_Producto2 CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTO_STOCK where Cod_Almacen=@Cod_Almacen

--	open cId_Producto2
--	FETCH NEXT FROM cId_Producto2 INTO @Id_Producto2
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto2,@Cod_Almacen
--		FETCH NEXT FROM cId_Producto2 INTO @Id_Producto2
--	END
--	CLOSE cId_Producto2
--	DEALLOCATE cId_Producto2

--END
--go

-- Procedimiento que inserta valores un producto realizando las permutaciones para un almacen
-- El almacen debe de existir y estar en la base de datos
-- USP_PRI_PRODUCTO_PermutarAlmacen 'A003',0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarAlmacen
@Cod_Almacen varchar(10),
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	--Recorremos todos los productos
	--Agregamos o modificamos en PRI_PRODUCTOSTOCK por cada producto
	declare @Id_Producto int
	DECLARE cId_Producto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS
	open cId_Producto
	FETCH NEXT FROM cId_Producto INTO @Id_Producto
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		if(@FlagInicializar=1) --Limpiar e inicializar en cero el stock, si existe lo pone en cero, si no lo agrega con cero
		begin
			exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
		end
		else
		begin
			IF NOT EXISTS (select * from PRI_PRODUCTO_PRECIO where Id_Producto=@Id_Producto and Cod_Almacen=@Cod_Almacen) --Prueba logica, solo si no existe los agrega
			begin
					exec USP_PRI_PRODUCTO_STOCK_G @Id_Producto,'NIU',@Cod_Almacen,'PEN',0,0,10,100,0,'NIU',1,'MIGRACION'
			end
		end
		FETCH NEXT FROM cId_Producto INTO @Id_Producto
	END
	CLOSE cId_Producto
	DEALLOCATE cId_Producto

	--Generar los campos en PRI_Producto_Precio
	--Generamos una fila por cada combiunacion entre un id y un precio,
	--es decir combinar productos de pri_producto_stock por los precios
	
	declare @Id_Producto2 int

	DECLARE cId_Producto2 CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTO_STOCK where Cod_Almacen=@Cod_Almacen

	open cId_Producto2
	FETCH NEXT FROM cId_Producto2 INTO @Id_Producto2
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		
		if(@FlagInicializar=1) --Limpiar e inicializar en cero el stock, si existe lo pone en cero, si no lo agrega con cero
		begin
			exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto2,@Cod_Almacen
		end
		else
		begin
			IF NOT EXISTS (select * from PRI_PRODUCTO_PRECIO where Id_Producto=@Id_Producto2 and Cod_Almacen=@Cod_Almacen) --Prueba logica, solo si no existe los agrega
			begin
				exec USP_PRI_PRODUCTO_PRECIO_GXIdProductoyCodAlmacen @Id_producto2,@Cod_Almacen
			end
		end

		FETCH NEXT FROM cId_Producto2 INTO @Id_Producto2
	END
	CLOSE cId_Producto2
	DEALLOCATE cId_Producto2
END
go


---- USP_PRI_PRODUCTO_PermutarTodosAlmacenes

--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarTodosAlmacenes' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PermutarTodosAlmacenes
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarTodosAlmacenes
--WITH ENCRYPTION
--AS
--BEGIN
--	declare @Cod_Almacen varchar(10)
--	DECLARE cCod_Almacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'
--	--Abrimos el cursor de los precios
--	open cCod_Almacen
--	FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		--Guardamos los datos en el pri_producto_precio
--		exec USP_PRI_PRODUCTO_PermutarAlmacen @Cod_Almacen
--		FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
--	END
--	CLOSE cCod_Almacen
--	DEALLOCATE cCod_Almacen
--END
--go

-- USP_PRI_PRODUCTO_PermutarTodosAlmacenes 0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarTodosAlmacenes' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarTodosAlmacenes
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarTodosAlmacenes
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Almacen varchar(10)
	DECLARE cCod_Almacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'
	--Abrimos el cursor de los precios
	open cCod_Almacen
	FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		exec USP_PRI_PRODUCTO_PermutarAlmacen @Cod_Almacen,@FlagInicializar
		FETCH NEXT FROM cCod_Almacen INTO @Cod_Almacen
	END
	CLOSE cCod_Almacen
	DEALLOCATE cCod_Almacen
END
go





--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio
--@Cod_Almacen varchar(10),
--@Cod_Categoria varchar(10),
--@Cod_Precio varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	--Recorremos todos los almacenes
--	--Recorremos todos los productos con la categoria del plan
--	--Agregamos por cada almacen y cada producto
--	declare @idProducto int
--	DECLARE cIdProducto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS where Cod_Categoria=@Cod_Categoria
--	open cIdProducto
--	FETCH NEXT FROM cIdProducto INTO @idProducto
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_PRECIO_G @IdProducto,'NIU',@Cod_Almacen,@Cod_Precio,0,'MIGRACION'
--		FETCH NEXT FROM cIdProducto INTO @idProducto
--	END
--	CLOSE cIdProducto
--	DEALLOCATE cIdProducto

--END
--go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio
@Cod_Almacen varchar(10),
@Cod_Categoria varchar(10),
@Cod_Precio varchar(10),
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	--Recorremos todos los almacenes
	--Recorremos todos los productos con la categoria del plan
	--Agregamos por cada almacen y cada producto
	declare @idProducto int
	DECLARE cIdProducto CURSOR LOCAL FOR select Id_Producto from PRI_PRODUCTOS where Cod_Categoria=@Cod_Categoria
	open cIdProducto
	FETCH NEXT FROM cIdProducto INTO @idProducto
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN

		if(@FlagInicializar=1)
		begin
			exec USP_PRI_PRODUCTO_PRECIO_G @IdProducto,'NIU',@Cod_Almacen,@Cod_Precio,0,'MIGRACION'
		end
		else
		begin
			if not exists(select * from PRI_PRODUCTO_PRECIO where Id_Producto=@idProducto and Cod_Almacen=@Cod_Almacen and Cod_TipoPrecio=@Cod_Precio)
			begin
				--select @idProducto,@Cod_Almacen,@Cod_Precio
				 exec USP_PRI_PRODUCTO_PRECIO_G @IdProducto,'NIU',@Cod_Almacen,@Cod_Precio,0,'MIGRACION'
			end 
		end
		FETCH NEXT FROM cIdProducto INTO @idProducto
	END
	CLOSE cIdProducto
	DEALLOCATE cIdProducto

END
go

---- Procedimiento que inserta valores un producto realizando las permutaciones para un plan
---- El plan debe de existir y estar en la base de datos
---- USP_PRI_PRODUCTO_PermutarPrecio 'PREN'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarPrecio' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PermutarPrecio
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarPrecio
--@Cod_Precio varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	--Recorremos todos los almacenes
--	--Recorremos todos los productos con la categoria del plan
--	--Agregamos por cada almacen y cada producto
--	declare @CodAlmacen varchar(10)
--	declare @CodCategoria varchar(10)=(select TOP 1 Cod_Categoria from VIS_PRECIOS where Cod_Precio=@Cod_Precio)
--	DECLARE cCodAlmacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'
--	open cCodAlmacen
--	FETCH NEXT FROM cCodAlmacen INTO @CodAlmacen
--	WHILE (@@FETCH_STATUS = 0 )
--	BEGIN
--		exec USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio @CodAlmacen,@CodCategoria,@Cod_Precio
--		FETCH NEXT FROM cCodAlmacen INTO @CodAlmacen
--	END
--	CLOSE cCodAlmacen
--	DEALLOCATE cCodAlmacen

--END
--go
-- Procedimiento que inserta valores un producto realizando las permutaciones para un plan
-- El plan debe de existir y estar en la base de datos
-- USP_PRI_PRODUCTO_PermutarPrecio 'PREN',0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarPrecio' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarPrecio
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarPrecio
@Cod_Precio varchar(10),
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	--Recorremos todos los almacenes
	--Recorremos todos los productos con la categoria del plan
	--Agregamos por cada almacen y cada producto
	declare @CodAlmacen varchar(10)
	declare @CodCategoria varchar(10)=(select TOP 1 Cod_Categoria from VIS_PRECIOS where Cod_Precio=@Cod_Precio)
	DECLARE cCodAlmacen CURSOR LOCAL FOR select Cod_Almacen from ALM_ALMACEN where Cod_TipoAlmacen <>'03'
	open cCodAlmacen
	FETCH NEXT FROM cCodAlmacen INTO @CodAlmacen
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		exec USP_PRI_PRODUCTO_PRECIO_GXCodAlmacenyCodCategoriayCodPrecio @CodAlmacen,@CodCategoria,@Cod_Precio,@FlagInicializar
		FETCH NEXT FROM cCodAlmacen INTO @CodAlmacen
	END
	CLOSE cCodAlmacen
	DEALLOCATE cCodAlmacen

END
go


-- USP_PRI_PRODUCTO_PermutarTodosPrecios '01',0

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PermutarTodosPrecios' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PermutarTodosPrecios
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PermutarTodosPrecios
@Cod_Categoria varchar(10),
@FlagInicializar bit
WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Precio varchar(10)
	DECLARE cCod_Precio CURSOR LOCAL FOR select Cod_Precio from VIS_PRECIOS where Cod_Categoria=@Cod_Categoria
	--Abrimos el cursor de los precios
	open cCod_Precio
	FETCH NEXT FROM cCod_Precio INTO @Cod_Precio
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		exec USP_PRI_PRODUCTO_PermutarPrecio @Cod_Precio,@FlagInicializar
		FETCH NEXT FROM cCod_Precio INTO @Cod_Precio
	END
	CLOSE cCod_Precio
	DEALLOCATE cCod_Precio
END
go

--Intercambiar orden de 2 precios, no verifica que tengan el mismo padre
--teniendo como variable el Cod_Precio de dichos planes 
-- execute USP_VIS_PRECIOS_IntercambiarOrden 'PRE','P'
-- Modificacod campo entero por campo numero
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRECIOS_IntercambiarOrden' AND type = 'P')
DROP PROCEDURE USP_VIS_PRECIOS_IntercambiarOrden
go
CREATE PROCEDURE USP_VIS_PRECIOS_IntercambiarOrden
@Cod_Precio1 varchar(10),
@Cod_Precio2 varchar(10)
WITH ENCRYPTION
AS
BEGIN
	if(@Cod_Precio1 is not null and @Cod_Precio2 is not null and @Cod_Precio1!='' and @Cod_Precio2!='' )
	begin
	--Recuperamos el id de la fila del primer precio
	declare @Id_Fila1 int = (select Top(1)Cod_Fila from PAR_FILA  where Cod_Tabla=83 and Cod_Fila=(select top(1) Cod_Fila from PAR_FILA where Cod_Tabla=83 and Cadena=@Cod_Precio1 and Cod_Columna=1))
	--Recuperamos el id de la fila del segundo precio
	declare @Id_Fila2 int = (select Top(1)Cod_Fila from PAR_FILA  where Cod_Tabla=83 and Cod_Fila=(select top(1) Cod_Fila from PAR_FILA where Cod_Tabla=83 and Cadena=@Cod_Precio2 and Cod_Columna=1))
	--Recuperamos el valor de orden de la primera fila
	declare @Orden_1 int =   (select top(1)Numero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila1)
	--Recuperamos el valor de orden de la segunda fila
	declare @Orden_2 int =   (select top(1)Numero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila2)
	--Actualizamos los valores de la fila 1
	update PAR_FILA set Numero=@Orden_2 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila1
	--Actualizamos los valores de la fila 2
	update PAR_FILA set Numero=@Orden_1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila2
	end
END
go


-- Realiza el resumen de contingencia para el excel SOLO PARA TKB Y TKF
-- Modificado para optimizar la consulta y reducirla
-- La fecha debe entrar en formato DD-MM-AAA
-- Autor(es): Rayme Chambi Erwin Miuller,Erwin
-- Fecha de Creación:  06/01/2017

--exec USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF '01-06-2017'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF
@Fecha datetime
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT dmy;
	select Motivo,Fecha,NomComprobante,Serie,NumeroComprobante,FinalTicketera,TipoDocumento,NumeroDocumento,RazonSocial,SumaGravadas,SumaExoneradas,SumaInafectas,
	SumatoriaISC,SumatoriaIGV,SumOtrosTribCarg,Importe_Total,ComprobanteAfectado,SerieAfectado,NumeroAfectado from
	( 
	SELECT 'OTROS' as Motivo,CONVERT(VARCHAR(10), @Fecha, 126) as Fecha,
	case when CP.Cod_TipoComprobante ='FA' then 'FACTURA'
	when CP.Cod_TipoComprobante ='BO' then 'BOLETA'
	when CP.Cod_TipoComprobante='TKF' then 'TICKET DE MAQUINA REGISTRADORA' end as NomComprobante,
	CP.Serie,
	CP.Numero AS NumeroComprobante,
	'' AS FinalTicketera,
	case when CP.Cod_TipoDoc ='1' then 'DNI'
	when CP.Cod_TipoDoc ='6' then 'RUC'
	when CP.Cod_TipoDoc='7' then 'PASAPORTE'
	when CP.Cod_TipoDoc='4' then 'CARNET DE EXTRANJERIA'
	when CP.Cod_TipoDoc='A' then 'PASAPORTE' 
	when CP.Cod_TipoDoc='99' or CP.Cod_TipoDoc='0' then 'SIN DOCUMENTO' end as TipoDocumento,
	CP.Doc_Cliente as NumeroDocumento,
	CP.Nom_Cliente as RazonSocial, 
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('10','17') THEN CD.Sub_Total-CD.IGV-CD.ISC ELSE 0 END)) AS SumaGravadas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('20') THEN CD.Sub_Total ELSE 0 END)) AS SumaExoneradas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('30') THEN CD.Sub_Total ELSE 0 END)) AS SumaInafectas,
	ABS(SUM(CD.ISC)) AS SumatoriaISC,
	ABS(SUM(CD.IGV)) AS SumatoriaIGV,
	ABS(AVG(CP.Otros_Tributos+Cp.Otros_Cargos)) AS SumOtrosTribCarg,
	ABS(SUM(CD.Sub_Total)) AS Importe_Total,
	'' as ComprobanteAfectado,
	'' as SerieAfectado,
	'' as NumeroAfectado
	FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
							 VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Cod_TipoComprobante in ('FA','BO','TKF') 
	and CP.Flag_Anulado=0
	GROUP BY CP.Numero, CP.Serie,Cp.Doc_Cliente,CP.Nom_Cliente,CP.Cod_TipoComprobante,CP.Cod_TipoDoc) RES
	order by NumeroComprobante
END
go

-- DECLARE @Id_ComprobantePago int = 4161
-- DECLARE @CodAlmacen varchar(5)='A103'
-- --Traemos los maestros
-- SELECT ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,ccd.Descripcion,
-- CONVERT(bit, 1) Maestro FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
-- INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
-- WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
-- AND ccd.Cod_Almacen=@CodAlmacen)
-- UNION
-- --Trameos los detalles 
-- SELECT ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,ccd.Descripcion,
-- CONVERT(bit, 1) Maestro FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
-- INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
-- WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
-- AND ccd.Cod_Almacen=@CodAlmacen)





-- DECLARE @FechaEmision datetime=GETDATE()
-- DECLARE @CodLibro varchar(3) = '14'
-- DECLARE @Motivo varchar(max) = 'OTROS'

-- --Motivos
-- --CONEXIÓN INTERNET 1
-- --FALLAS FLUIDO ELECTRICO 2
-- --DESASTRES NATURALES 3
-- --ROBO 4
-- --FALLAS EN EL SISTEMA DE EMISION ELECTRONICA 5
-- --VENTAS POR EMISORES ITINERANTES 6
-- --OTROS 7

-- SET @Motivo = UPPER(@Motivo)
-- SELECT 
-- CASE WHEN @Motivo='CONEXIÓN INTERNET' OR @Motivo='CONEXION INTERNET' THEN 1
-- WHEN @Motivo='FALLAS FLUIDO ELECTRICO' THEN 2
-- WHEN @Motivo='DESASTRES NATURALES' THEN 3
-- WHEN @Motivo='ROBO' THEN 4
-- WHEN @Motivo='FALLAS EN EL SISTEMA DE EMISION ELECTRONICA' THEN 5
-- WHEN @Motivo='VENTAS POR EMISORES ITINERANTES' THEN 6
-- ELSE '7' END Motivo,
-- CASE WHEN ccp.Cod_TipoOperacion = '01' THEN '01'
-- WHEN ccp.Cod_TipoOperacion = '04' THEN '02' END TipoOperacion, --Venta/interna exportacion
-- CONVERT(VARCHAR(10), ccp.FechaEmision, 103) FechaEmision,
-- CASE WHEN ccp.Cod_TipoComprobante = 'FA' THEN '01'
-- WHEN ccp.Cod_TipoComprobante = 'BO' THEN '03'
-- WHEN ccp.Cod_TipoComprobante = 'NC' THEN '07'
-- WHEN ccp.Cod_TipoComprobante = 'ND' THEN '08'
-- WHEN ccp.Cod_TipoComprobante = 'TKB' OR ccp.Cod_TipoComprobante = 'TKF' THEN '12' END TipoComprobante,
-- ccp.Serie,
-- ccp.Numero,
-- '' FinalRango,--Final rango ticket
-- CASE WHEN ccp.Cod_TipoDoc='99' THEN '0'
-- ELSE ccp.Cod_TipoDoc END CodTipoDocumento,--Tipo de documento del cliente
-- RIGHT('00000000' + LTRIM(RTRIM(ccp.Doc_Cliente)),8) DocCliente,
-- SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(ccp.Nom_Cliente),CHAR(39),''),CHAR(10),''),CHAR(13),''), 'Á' , 'A') , 'É','E') ,'Í','I') ,'Ó','O' ) ,'Ú','U'),'Ñ','NI'),'Ü','U'),0,60) NomCliente,
-- ccp.Cod_Moneda,
-- ROUND(ABS(SUM(CASE WHEN ccd.Cod_TipoIGV IN ('10','17') THEN (ccd.Cantidad*ccd.PrecioUnitario)-((ccd.Cantidad*ccd.PrecioUnitario*ccd.Porcentaje_IGV)/(ccd.Porcentaje_IGV+100))-((ccd.Cantidad*ccd.PrecioUnitario*ccd.Porcentaje_ISC)/(ccd.Porcentaje_ISC+100)) ELSE 0 END)),2) AS SumaGravadas,
-- ROUND(ABS(SUM(CASE WHEN ccd.Cod_TipoIGV IN ('20') THEN (ccd.Cantidad*ccd.PrecioUnitario) ELSE 0 END)),2) AS SumaExoneradas

-- FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
-- INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
-- GROUP BY ccp.Cod_TipoOperacion,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.Cod_TipoDoc,ccp.Doc_Cliente,ccp.Nom_Cliente,ccp.Cod_Moneda,ccp.FechaEmision
-- --WHERE 
-- --CONVERT(VARCHAR(10), ccp.FechaEmision, 103)=CONVERT(VARCHAR(10), @FechaEmision, 103)
-- --AND ccp.Cod_Libro=@CodLibro
-- --AND ccp.Flag_Anulado=0
-- --AND ccp.Cod_TipoComprobante IN ('BO','FA','TKB','TKF','NC','NDE')



