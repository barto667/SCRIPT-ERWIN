SELECT        S.Cod_Tabla, S.Id_Tabla, S.Item, S.Serie, S.Fecha_Vencimiento, S.Obs_Serie, P.Cod_Producto, MD.Des_Producto, A.Des_Almacen, AM.Cod_TipoComprobante + ' : ' + AM.Serie + ' - ' + AM.Numero AS Comprobante,
                          AM.Fecha, AM.Motivo, AM.Flag_Anulado, CASE AM.Cod_TipoComprobante WHEN 'NE' THEN 'ENTRADA' WHEN 'NS' THEN 'SALIDA' ELSE '' END AS Estado,CASE AM.Cod_Turno WHEN null THEN 'PENDIENTE' ELSE 'CORRECTO' END AS Pendiente, CASE WHEN AM.Cod_TipoComprobante = 'NE' AND 
                         Flag_Anulado = 0 THEN 1 WHEN AM.Cod_TipoComprobante = 'NS' AND Flag_Anulado = 0 THEN - 1 ELSE 0 END AS Stock, P.Id_Producto, A.Cod_Almacen, PS.Cod_UnidadMedida, AM.Fecha_Reg, PS.Precio_Venta, 
                         PS.Precio_Compra, VU.Nom_UnidadMedida
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto INNER JOIN
                         ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov INNER JOIN
                         ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto AND AM.Cod_Almacen = PS.Cod_Almacen INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida RIGHT OUTER JOIN
                         CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla AND MD.Item = S.Item
						 
WHERE        (S.Cod_Tabla = 'ALM_ALMACEN_MOV')  and S.Serie='351591076990533'
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
WHERE        (S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')	and S.Serie='351591076990533'


select * from ALM_ALMACEN_MOV where Cod_TipoComprobante='NE' and Serie='0001' and Numero='00000318'

select * from VIS_SERIES where Estado='PENDIENTE'
select * from VIS_SERIES where Serie='351591076990533' order by Fecha_Vencimiento ASC

select * from VIS_SERIES as T1 inner join ALM_ALMACEN_MOV as T2 on T1.Cod_Almacen=T2.Cod_Almacen and T2.Cod_Turno is null and T1.Serie='351591076990533'
and T1.Estado='ENTRADA' and T1.Comprobante='NE : 0001 - 00000318'

select * from VIS_SERIES where Serie='351591076990533'  order by Cod_Tabla ASC

select DISTINCT Cod_Almacen from VIS_SERIES where Serie='351591076990533'

if (select *  from VIS_SERIES where Serie='351591076990533' and Despacho!='CORRECTO')>0
begin
	select * from VIS_PRECIOS
end
else
begin
	select * from VIS_SERIES
end
	declare @CodAlmacen varchar(10)-- = (select Top(1) Cod_Almacen from VIS_SERIES where Serie='351591076990533' order by Fecha_Vencimiento DESC)
	declare Cursor_Almacenes cursor for select Cod_Almacen from VIS_SERIES where Serie='351591076990533' order by Fecha_Vencimiento DESC
	open Cursor_Almacenes
	fetch @CodAlmacen into @fila;
	WHILE (@@FETCH_STATUS = 0 )
	begin;
		
	fetch cursor_fila1 into @fila;
	end;
	close Cursor_Almacenes;
	deallocate Cursor_Almacenes;


	select * from VIS_SERIES where Serie='351591076990533' and Cod_Almacen='A0011'
	declare Cursor_Almacenes cursor for select DISTINCT Cod_Almacen from #Temp1 

	SELECT Cod_Almacen, Motivo, Estado
	FROM VIS_SERIES
	WHERE    (Serie LIKE '%' + '895110143000217149')

	(SELECT TOP(1) Cod_Almacen
		FROM VIS_SERIES
		WHERE    (Serie LIKE '%' + '895110143000217149'))


select * from VIS_SERIES where Serie='358718068394738'

SELECT Cod_Tabla,Cod_Almacen, Id_Tabla, Item, Serie, Fecha_Vencimiento, Obs_Serie, Cod_Producto, Des_Producto, Des_Almacen, Comprobante, Fecha, Motivo, Flag_Anulado, Estado, Stock
	FROM VIS_SERIES
	WHERE        (Serie LIKE '%' + '000151020000695')

exec USP_VIS_PRECIOS_SePuedeVender '351591076990533','A0011'

(SELECT SUM(Stock)
		FROM VIS_SERIES WHERE (Serie LIKE '%' + '1243906276'))


declare @Stock int =(SELECT SUM(Stock)
		FROM VIS_SERIES WHERE Serie = '351591076990533')
		print @Stock
		if(@Stock=0)
		BEGIN
			drop table #Resultado
			create table #Resultado(Cod_Observacion int,Cod_Almacen varchar(10),Observacion varchar(100))
			insert into #Resultado values(1,'','El producto solicitado no contiene stock en ningun almacen')
			select * from #Resultado 
		END

