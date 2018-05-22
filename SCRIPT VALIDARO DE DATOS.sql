--Cambiar null por 10 o 13 en codIGV
update CAJ_COMPROBANTE_D set Cod_TipoIGV=13 from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where cd.Cod_TipoIGV is null and CP.Cod_Libro=14 and CD.IGV=0
update CAJ_COMPROBANTE_D set Cod_TipoIGV=10 from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where cd.Cod_TipoIGV is null and CP.Cod_Libro=14 and CD.IGV>0


--Cambiar los tipo a GRA o GRT segun codigo de afectacion
update CAJ_COMPROBANTE_D set Tipo='GRT' from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where  CP.Cod_Libro=14 and CD.Cod_TipoIGV=13 and CD.Tipo is null 
update CAJ_COMPROBANTE_D set Tipo='GRA' from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where  CP.Cod_Libro=14 and CD.Cod_TipoIGV=10 and CD.Tipo is null 


--Cambiar 0 en cantidad por 1 en gratuitas
update CAJ_COMPROBANTE_D set Cantidad=1 from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where (cd.Cantidad is null or cd.Cantidad=0) and CP.Cod_Libro=14 and CD.IGV=0 and CD.Cod_TipoIGV=13


--Cambiar a el valor no oneroso a 1 si es null o 0
update CAJ_COMPROBANTE_D set Valor_NoOneroso=1 from CAJ_COMPROBANTE_PAGO as CP inner join CAJ_COMPROBANTE_D as CD 
on CP.id_ComprobantePago=CD.id_ComprobantePago where (cd.Valor_NoOneroso is null or cd.Valor_NoOneroso=0) and CP.Cod_Libro=14 and CD.IGV=0 and CD.Cod_TipoIGV=13



go


/*--Para San martin
declare @idComprobante int
declare @total numeric(38,2)
declare @IGV numeric(38,2)
DECLARE cursor_fila CURSOR LOCAL FOR 
SELECT        p.id_ComprobantePago AS ID, SUM(D.Cantidad * D.PrecioUnitario) AS Total, SUM(D.IGV) AS IGV
FROM            CAJ_COMPROBANTE_D AS D INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
group by p.id_ComprobantePago,  P.Total
having P.Total <> SUM(D.Cantidad * D.PrecioUnitario)
order by p.id_ComprobantePago

--Abrimos el cursor de los precios
open cursor_fila
FETCH NEXT FROM cursor_fila INTO @idComprobante,@total,@IGV
WHILE (@@FETCH_STATUS = 0 )
BEGIN
	--Guardamos los datos en el pri_producto_precio
	update CAJ_COMPROBANTE_PAGO set Total=@total,Impuesto =@IGV where id_ComprobantePago=@idComprobante and Total <> @total
	FETCH NEXT FROM cursor_fila INTO @idComprobante,@total,@IGV
END
CLOSE cursor_fila
DEALLOCATE cursor_fila*/


---Recupera los totales de un comprobante en base a su serie, el tipo de comp y un rango de fechas
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación: 06/02/2017
-- USP_CAJ_COMPROBANTE_PAGO_FiltrarXFechaySerie 'BE','B001','01/01/2017','01/02/2017'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_FiltrarXFechaySerie' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FiltrarXFechaySerie
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FiltrarXFechaySerie
@TipoComprobante varchar(4),
@Serie varchar(10),
@FechaMin datetime,
@FechaMax datetime
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT dmy;
	SELECT ccp.id_ComprobantePago,ccp.Serie,ccp.Numero,CONVERT(numeric(38,2),ccp.Impuesto) AS Impuestoccp ,CONVERT(numeric(38,2),ccp.Total) AS Totalccp,
	CONVERT(numeric(38,2),(SUM(ccd.Sub_Total))) AS Totalccd FROM dbo.CAJ_COMPROBANTE_PAGO ccp
	 INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
	WHERE ccp.FechaEmision >=@FechaMin AND ccp.FechaEmision<=@FechaMax AND @Serie=ccp.Serie AND ccp.Cod_TipoComprobante=@TipoComprobante
	GROUP BY ccd.Sub_Total,ccp.id_ComprobantePago,ccp.Serie,ccp.Numero,ccp.Impuesto,ccp.Total
END
go


/*DECLARE @ID_Comprobante int,
@Total numeric(38,2),
@impuesto  numeric(38,2),
@Detalle int;
IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE #temp1
END
SELECT        id_ComprobantePago,id_Detalle, CONVERT(numeric(38,2),(PrecioUnitario*Cantidad)) AS SubTotal, CONVERT(numeric(38,2),(PrecioUnitario*Cantidad*18/118)) AS IGV
INTO #temp1
FROM            CAJ_COMPROBANTE_D 
GROUP BY id_ComprobantePago,id_Detalle,PrecioUnitario,Cantidad
ORDER BY dbo.CAJ_COMPROBANTE_D.id_ComprobantePago,dbo.CAJ_COMPROBANTE_D.id_Detalle

DECLARE product_cursor CURSOR FOR   
SELECT   * FROM #Temp1 
    OPEN product_cursor  
    FETCH NEXT FROM product_cursor INTO @ID_Comprobante,@Detalle, @Total,@impuesto
	WHILE @@FETCH_STATUS = 0  
    BEGIN  

		--Actualizamos los detalles de cada comprobante
		update CAJ_COMPROBANTE_D set CAJ_COMPROBANTE_D.Sub_Total = @Total, CAJ_COMPROBANTE_D.IGV = @impuesto
		where id_ComprobantePago = @ID_Comprobante 
		
		--actualizamos los detalles de caja comprobante pago
		SET @Total=(SELECT SUM(t.SubTotal) AS SubTotal FROM #temp1 t WHERE t.id_ComprobantePago=@ID_Comprobante)
		SET @impuesto=(SELECT SUM(t.IGV) AS SubTotal FROM #temp1 t WHERE t.id_ComprobantePago=@ID_Comprobante)
		update CAJ_COMPROBANTE_PAGO set Total = @Total, Impuesto = @impuesto
		where id_ComprobantePago = @ID_Comprobante

		--Actualizamos las formas de pago
		-- solo efectivo, si existe 
		if((SELECT ccp.Cod_FormaPago from dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@ID_Comprobante)='008')
		BEGIN
			update CAJ_FORMA_PAGO set CAJ_FORMA_PAGO.Monto = @Total
			where id_ComprobantePago = @ID_Comprobante
		END
		FETCH NEXT FROM product_cursor INTO @ID_Comprobante,@Detalle, @Total,@impuesto
    END  
    CLOSE product_cursor  
    DEALLOCATE product_cursor  */


--Actualizamos nuestros detalles, si varian en algo
/*UPDATE CAJ_COMPROBANTE_D 
SET Sub_Total=ROUND(Cantidad*PrecioUnitario,2),
IGV=ROUND(Cantidad*PrecioUnitario*18/118,2)
WHERE Sub_Total<>ROUND(Cantidad*PrecioUnitario,2) OR IGV<>ROUND(Cantidad*PrecioUnitario*18/118,2)

GO

DECLARE cursor_fila CURSOR LOCAL FOR SELECT ccd.id_ComprobantePago,ROUND(SUM(ccd.Sub_Total),2) AS Total,
ROUND(SUM(IGV),2) AS IGV
FROM dbo.CAJ_COMPROBANTE_D ccd 
GROUP BY ccd.id_ComprobantePago

--Actualiza los campos
declare @ID int
declare @SubTotal numeric(38,2)
declare @Impuesto numeric(38,2)
--Abrimos el cursor de los precios
open cursor_fila
FETCH NEXT FROM cursor_fila INTO @ID,@SubTotal,@Impuesto
WHILE (@@FETCH_STATUS = 0 )
BEGIN
	--Guardamos los datos en Ccp
	UPDATE CAJ_COMPROBANTE_PAGO
	SET Total=@SubTotal,Impuesto=@Impuesto
	WHERE id_ComprobantePago=@ID AND (Total<>@SubTotal OR Impuesto<>@Impuesto)

	--Guardamos en cfp
	UPDATE CAJ_FORMA_PAGO
	SET Monto = @SubTotal
	WHERE id_ComprobantePago=@ID AND Monto<>@SubTotal AND Cod_TipoFormaPago='008';

	FETCH NEXT FROM cursor_fila INTO @ID,@SubTotal,@Impuesto;
END
CLOSE cursor_fila
DEALLOCATE cursor_fila
GO
*/

update CAJ_COMPROBANTE_D set Sub_Total = ROUND(Cantidad * PrecioUnitario, 2),
IGV = round(ROUND(Cantidad * PrecioUnitario, 2)/1.18*0.18,2)
where Sub_Total <> ROUND(Cantidad * PrecioUnitario, 2)
-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,2), @CTotal AS NUMERIC(38,2)
DECLARE product_cursor CURSOR FOR   
SELECT        p.id_ComprobantePago, SUM(d.IGV) AS IGV, SUM(d.Sub_Total) AS CTotal, p.Cod_EstadoComprobante, p.Cod_TipoComprobante, p.Serie, p.Numero, AVG(p.Total) AS Expr1, p.Nom_Cliente
FROM            CAJ_COMPROBANTE_D AS d INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS p ON d.id_ComprobantePago = p.id_ComprobantePago
WHERE        (p.Cod_TipoComprobante IN ('FE', 'BE', 'NCE')) AND (p.Cod_EstadoComprobante  IN ('INI', 'EMI')) AND (p.Cod_Libro = '14')
GROUP BY p.id_ComprobantePago, p.Cod_EstadoComprobante, p.Cod_TipoComprobante, p.Serie, p.Numero, p.Nom_Cliente
HAVING        (AVG(p.Total) <> ROUND(SUM(d.Sub_Total), 2))
OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
   -- Actualizar los totaltes y el igv
	update CAJ_COMPROBANTE_PAGO set Total = @CTotal, Impuesto = @IGV
	where id_ComprobantePago =   @id_ComprobantePago        
  -- actualizar las formas de pago
  update CAJ_FORMA_PAGO SET Monto = @CTotal
  where id_ComprobantePago =   @id_ComprobantePago and Cod_TipoFormaPago IN ('008','005','006')
      
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal  
END  
  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO

