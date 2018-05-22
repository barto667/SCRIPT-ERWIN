use PALERPmelqui
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

--Intercambiar orden de 2 precios, no verifica que tengan el mismo padre
--teniendo como variable el Cod_Precio de dichos planes 
-- execute USP_VIS_PRECIOS_IntercambiarOrden 'PNSC','PNSD'
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
	declare @Orden_1 int =   (select top(1)Entero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila1)
	--Recuperamos el valor de orden de la segunda fila
	declare @Orden_2 int =   (select top(1)Entero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila2)
	--Actualizamos los valores de la fila 1
	update PAR_FILA set Entero=@Orden_2 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila1
	--Actualizamos los valores de la fila 2
	update PAR_FILA set Entero=@Orden_1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila2
	end
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
	/*IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#aux1')
	BEGIN
		drop table #aux1
	END
	select * into #aux1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=3 and Cadena=@Cod_Categoria
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'U' AND name = '#aux2')
	BEGIN
		drop table #aux2
	END
	select * into #aux2 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=1 and Cadena=@Cod_Precio*/

	declare @Id_Fila int = (select Top(1)Cod_Fila from PAR_FILA  where Cod_Tabla=83 and Cod_Fila=(select top(1) Cod_Fila from PAR_FILA where Cod_Tabla=83 and Cadena=@Cod_Precio and Cod_Columna=1))
	--declare @Id_Fila int=(select TOP(1) T1.Cod_Fila from #aux1 as T1 inner join #aux2 as T2 on T1.Cod_Fila=T2.Cod_Fila)
	declare @Cod_Padre varchar(10) = (select top(1) Cadena from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cod_Fila=@Id_Fila)
	declare @Orden int =   (select top(1)Entero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila)

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
	declare cursor_fila1 cursor for select T2.Cod_Fila from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T2.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila and T2.Entero>@Orden
	open cursor_fila1;
	fetch cursor_fila1 into @fila;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
	update PAR_FILA set Entero=Entero-1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila= @fila;
	fetch cursor_fila1 into @fila;
	end;
	close cursor_fila1;
	deallocate cursor_fila1;
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
	EXEC USP_PAR_FILA_G '083','005',@numero_fila,NULL,NULL,@Orden2,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '083','006',@numero_fila,NULL,NULL,NULL,NULL,@Estado,1,'MIGRACION';

	declare @fila int;
	declare cursor_fila2 cursor for select T2.Cod_Fila from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T2.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila and T2.Entero>@Orden
	open cursor_fila2;
	fetch cursor_fila2 into @fila;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
		update PAR_FILA set Entero=Entero+1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila= @fila;
	fetch cursor_fila2 into @fila;
	end;
	close cursor_fila2;
	deallocate cursor_fila2;
END
go


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
	declare @Orden int= (select MAX(T1.Entero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
	if (@Orden is null)
	begin
		set @Orden=0
	end
	else
	begin
		set @Orden= (select MAX(T1.Entero)  from PAR_FILA as T1 inner join #temp1 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila )
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


-- Crea la vista series , añadiendo el campo o estado pendiente
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016

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

-- Valida la trazabilidad de una serie, retorna 0  si no hay errores.
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- select dbo.UFN_PRI_SERIES_ValidarTrazabilidad('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ValidarTrazabilidad' AND type = 'P')
begin
	DROP FUNCTION UFN_PRI_SERIES_ValidarTrazabilidad
end
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


-- Cuenta los estados pendientes de un producto en base  a su serie, 0 indica que no tiene pendientes
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- select dbo.UFN_PRI_SERIES_ContarPendientes('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ContarPendientes' AND type = 'P')
begin
	DROP FUNCTION UFN_PRI_SERIES_ContarPendientes
end
go

CREATE FUNCTION UFN_PRI_SERIES_ContarPendientes(@Serie VARCHAR(20)) RETURNS INT
	AS
    BEGIN
		return (SELECT COUNT(*) FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie) and Estado='PENDIENTE')
    END
go



-- Cuenta el stock de un producto en base a su serie, 0 indica que no tiene stock
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- select dbo.UFN_PRI_SERIES_ContarPendientes('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ContarStock' AND type = 'P')
begin
	DROP FUNCTION UFN_PRI_SERIES_ContarStock
end
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


-- Cuenta el codigo del ultimo almacen de un producto en base a su serie
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- select dbo.UFN_PRI_SERIES_UltimoAlmacen('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_UltimoAlmacen' AND type = 'P')
begin
	DROP FUNCTION UFN_PRI_SERIES_UltimoAlmacen
end
go
CREATE FUNCTION UFN_PRI_SERIES_UltimoAlmacen(@Serie VARCHAR(20)) RETURNS Varchar(20)
	AS
    BEGIN
		return (SELECT TOP 1 Cod_Almacen FROM VIS_SERIES WHERE (Serie LIKE '%' + @Serie) order by Fecha_Reg DESC)
    END
go


-- Valida que un producto pueda agregarse, cumpliendo que no tenga pendientes, que este sin stock y que no contenga errores de trazabilidad
-- Retorna el ultimo almacen, el codigo de error y un mensaje
-- 1 Error de trazabilidad
-- 2 Serie con stock
-- 3 Serie con estados pendientes
-- 4 Correcto
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- USP_PRI_SERIES_ValidarEntrada '356656075499987'
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

-- Valida que un producto pueda venderse, cumpliendo que no tenga pendientes, que este sin stock y que no contenga errores de trazabilidad
-- Retorna el ultimo almacen, el codigo de error y un mensaje
-- 1 Error de trazabilidad
-- 2 Serie con stock
-- 3 Serie con estados pendientes
-- 4 Correcto
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- USP_PRI_SERIES_ValidarSalida '356656075499987'
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
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen
@Cod_Almacen as  varchar(32) ,
@Buscar  varchar(512)
WITH ENCRYPTION
AS
BEGIN
SELECT DISTINCT Cod_Producto,Nom_Producto,Serie,Id_Producto
FROM
	(SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto
	FROM            CAJ_SERIES AS S INNER JOIN
							 ALM_ALMACEN_MOV_D AS MD ON S.Item = MD.Item AND S.Id_Tabla = MD.Id_AlmacenMov INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto INNER JOIN
							 ALM_ALMACEN_MOV AS M ON M.Id_AlmacenMov = MD.Id_AlmacenMov
	WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV') AND M.Cod_Almacen = @Cod_Almacen AND M.Cod_Turno IS NOT NULL AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie,@Cod_Almacen) = 1
	AND ( S.Serie LIKE '%'+ @Buscar )
	UNION
	SELECT        P.Cod_Producto, P.Nom_Producto, S.Serie ,P.Id_Producto
	FROM            CAJ_SERIES AS S INNER JOIN
							  CAJ_COMPROBANTE_D AS MD ON S.Item = MD.id_Detalle AND S.Id_Tabla = MD.id_ComprobantePago INNER JOIN
							 PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto
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




