-- Crea la vista series , añadiendo el campo o estado pendiente
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  13/12/2016

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
-- Fecha de Creación:  13/12/2016
-- select dbo.UFN_PRI_SERIES_ValidarTrazabilidad('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ValidarTrazabilidad')
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
-- Fecha de Creación:  13/12/2016
-- select dbo.UFN_PRI_SERIES_ContarPendientes('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ContarPendientes' )
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
-- Fecha de Creación:  13/12/2016
-- select dbo.UFN_PRI_SERIES_ContarStock('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_ContarStock' )
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
-- Fecha de Creación:  13/12/2016
-- select dbo.UFN_PRI_SERIES_UltimoAlmacen('356656075499987')

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_SERIES_UltimoAlmacen' )
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
-- Fecha de Creación:  13/12/2016
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
-- Fecha de Creación:  13/12/2016
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
