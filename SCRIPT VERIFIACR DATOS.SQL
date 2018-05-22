--Verificar que no existan campos null en cod_IGV o tipo
SELECT distinct ccp.id_ComprobantePago,ccd.id_Detalle,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.Cod_TipoIGV,ccd.Tipo,ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='' OR ccd.Tipo IS NULL OR ccd.Tipo='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE')
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,FechaEmision


--Para empresdas gravadas
--Actualiza el campo de detalles del tipo de IGV con 10 en ccualquier comprobante 
--UPDATE dbo.CAJ_COMPROBANTE_D
--SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=10 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
--WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRA'
----Actualiza el campo de detalles del tipo de IGV con 13 en ccualquier comprobante 
--UPDATE dbo.CAJ_COMPROBANTE_D
--SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=13 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
--WHERE  (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRT'

--Para empresdas exoneradas
--Actualiza el campo de detalles del tipo de IGV con 20 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=20 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRA'
--Actualiza el campo de detalles del tipo de IGV con 13 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=21 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE  (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRT'



----Actualizamos el SUBTOTAL y el IGV
--UPDATE dbo.CAJ_COMPROBANTE_D SET 
--	dbo.CAJ_COMPROBANTE_D.Sub_Total=ROUND(ccd.Cantidad*ccd.PrecioUnitario,2),
--	dbo.CAJ_COMPROBANTE_D.IGV=CASE WHEN ccd.Cod_TipoIGV=10 THEN round(ROUND(ccd.Cantidad * ccd.PrecioUnitario, 2)/1.18*0.18,2) ELSE 0 END
--FROM 
--	dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago=ccd.id_ComprobantePago
--WHERE
--	ccp.Cod_TipoComprobante IN ('FE','NCE','BE') 
--	AND ccp.Cod_Libro=14 
--	AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
--	AND (ccd.Sub_Total<>ROUND(ccd.Cantidad*ccd.PrecioUnitario,2) 
--	OR ccd.IGV <>  CASE WHEN ccd.Cod_TipoIGV=10 THEN round(ROUND(ccd.Cantidad * ccd.PrecioUnitario, 2)/1.18*0.18,2) ELSE 0 END)

---- recorrer todos los comprobantes con errores y corregir
--GO
--DECLARE @id_ComprobantePago INT, @IGV numeric(38,2), @CTotal AS NUMERIC(38,2)
--DECLARE product_cursor CURSOR FOR   
--SELECT        p.id_ComprobantePago, SUM(d.IGV) AS IGV, SUM(d.Sub_Total) AS CTotal
--FROM            CAJ_COMPROBANTE_D AS d INNER JOIN
--                         CAJ_COMPROBANTE_PAGO AS p ON d.id_ComprobantePago = p.id_ComprobantePago
--WHERE        (p.Cod_TipoComprobante IN ('FE', 'BE', 'NCE')) AND (p.Cod_EstadoComprobante  IN ('INI', 'EMI')) AND (p.Cod_Libro = '14')
--GROUP BY p.id_ComprobantePago, p.Cod_EstadoComprobante, p.Cod_TipoComprobante, p.Serie, p.Numero, p.Nom_Cliente
--HAVING        (AVG(p.Total) <> ROUND(SUM(d.Sub_Total), 2))
--OPEN product_cursor  
--FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal
 
--WHILE @@FETCH_STATUS = 0  
--BEGIN  
  
--   -- Actualizar los totaltes y el igv
--	update CAJ_COMPROBANTE_PAGO set Total = @CTotal, Impuesto = @IGV
--	where id_ComprobantePago =   @id_ComprobantePago        
--  -- actualizar las formas de pago
--  update CAJ_FORMA_PAGO SET Monto = @CTotal
--  where id_ComprobantePago =   @id_ComprobantePago and Cod_TipoFormaPago IN ('008','005','006')
      
--FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal  
--END  
  
--CLOSE product_cursor  
--DEALLOCATE product_cursor  
--GO


--Actualizamos el SUBTOTAL y el IGV
UPDATE dbo.CAJ_COMPROBANTE_D SET 
	dbo.CAJ_COMPROBANTE_D.Sub_Total=ROUND(ccd.Cantidad*ccd.PrecioUnitario,2),
	dbo.CAJ_COMPROBANTE_D.IGV=CASE WHEN ccd.Cod_TipoIGV=10 THEN  ROUND((ccd.Cantidad * ccd.PrecioUnitario/1.18*0.18),2) ELSE 0 END
FROM 
	dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago=ccd.id_ComprobantePago
WHERE
	ccp.Cod_TipoComprobante IN ('FE','NCE','BE','NDE') 
	AND ccp.Cod_Libro=14 
	AND ccp.Cod_EstadoComprobante IN ('INI','EMI')
	AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
	AND (ccd.Sub_Total<>ROUND(ccd.Cantidad*ccd.PrecioUnitario,2) 
	OR ccd.IGV <>  CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND((ccd.Cantidad * ccd.PrecioUnitario/1.18*0.18),2) ELSE 0 END)

-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,6), @CTotal AS NUMERIC(38,2)
DECLARE product_cursor CURSOR FOR   
(
SELECT ccp.id_ComprobantePago,CASE WHEN ccp2.IGV<>0 then ccp2.IGV-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)* ccp.Descuento_Total*18/118 ELSE 0 END AS IGV,
ccp2.Total-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)*ccp.Descuento_Total AS Total
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN (SELECT ccd.id_ComprobantePago,
SUM(CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND(ccd.Cantidad*ccd.PrecioUnitario,2)*18/118  ELSE 0 END) AS IGV,
SUM(ROUND(ccd.Cantidad*ccd.PrecioUnitario,2)) AS Total
 FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE  (ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE'))  AND (ccp.Cod_Libro = 14) AND (ccp.Cod_EstadoComprobante  IN ('INI','EMI'))
GROUP BY ccd.id_ComprobantePago ) ccp2 
ON ccp2.id_ComprobantePago=ccp.id_ComprobantePago
GROUP BY ccp.id_ComprobantePago, ccp2.Total,ccp2.IGV, ccp.Total,ccp.Impuesto,ccp.Descuento_Total,ccp.Cod_TipoComprobante
HAVING AVG(ccp.Total) <> ccp2.Total OR AVG(ccp.Impuesto) <> ccp2.IGV)


OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago, @IGV, @CTotal
 
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



--V2
--Actualizamos el SUBTOTAL y el IGV
UPDATE dbo.CAJ_COMPROBANTE_D SET 
	dbo.CAJ_COMPROBANTE_D.Sub_Total=ROUND(ccd.Cantidad*ccd.PrecioUnitario,2),
	dbo.CAJ_COMPROBANTE_D.IGV=CASE WHEN ccd.Cod_TipoIGV=10 THEN  ROUND((ccd.Cantidad * ccd.PrecioUnitario/1.18*0.18),2) ELSE 0 END
FROM 
	dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago=ccd.id_ComprobantePago
WHERE
	ccp.Cod_TipoComprobante IN ('FE','NCE','BE','NDE') 
	AND ccp.Cod_Libro=14 
	AND ccp.Cod_EstadoComprobante IN ('INI','EMI')
	AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
	AND (ccd.Sub_Total<>ROUND(ccd.Cantidad*ccd.PrecioUnitario,2) 
	OR ccd.IGV <>  CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND((ccd.Cantidad * ccd.PrecioUnitario/1.18*0.18),2) ELSE 0 END)

-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,6), @CTotal AS NUMERIC(38,2)
DECLARE product_cursor CURSOR FOR   
(
SELECT ccp.id_ComprobantePago,CASE WHEN ccp2.IGV<>0 then ccp2.IGV-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)* ccp.Descuento_Total*18/118 ELSE 0 END AS IGV,
ccp2.Total-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)*ccp.Descuento_Total AS Total
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN (SELECT ccd.id_ComprobantePago,
SUM(CASE WHEN ccd.Cod_TipoIGV=10 THEN ccd.Cantidad*ccd.PrecioUnitario*18/118  ELSE 0 END) AS IGV,
ROUND(SUM(ccd.Cantidad*ccd.PrecioUnitario),2) AS Total
 FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE  (ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE'))  AND (ccp.Cod_Libro = 14) AND (ccp.Cod_EstadoComprobante  IN ('INI','EMI'))
GROUP BY ccd.id_ComprobantePago) ccp2 
ON ccp2.id_ComprobantePago=ccp.id_ComprobantePago
GROUP BY ccp.id_ComprobantePago, ccp2.Total,ccp2.IGV, ccp.Total,ccp.Impuesto,ccp.Descuento_Total,ccp.Cod_TipoComprobante
HAVING AVG(ccp.Total) <> ccp2.Total OR AVG(ccp.Impuesto) <> ccp2.IGV
)
OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago, @IGV, @CTotal
 
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



--Verifica valore spara intercambia,en caso de querer intercambiar montos en emisiones con monto cero
SELECT ccp.id_ComprobantePago,ccp.Cod_Turno,ccd.Cod_Almacen,ccd.Cod_Manguera,ccp.Nom_Cliente,ccd.Id_Producto,ccd.Cantidad,ccd.PrecioUnitario,ccd.Sub_Total,ccd.IGV
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE ccp.Cod_Turno='D28/01/2017' 
AND ccp.Cod_TipoComprobante='BE' 
AND ccd.Cod_Almacen='T84' 
AND ccp.Cod_Caja='101' 
AND ccd.Cod_Manguera='1A84'

--Intercambia subtotales, restando  el monto al detalle del comprobante mayor y dandoselo al otro
-- solo hacer con detalles del mismo turno, caja y cod manguera con el msimo prrecio unitario
DECLARE @IdComprobanteMayor int=1
DECLARE @IdDetalleMayor int=1
DECLARE @IdComprobanteMenor int=2
DECLARE @Id_DetalleMenor int=1
DECLARE @Monto numeric(38,2)=1

--Recuperamos el subtotal del mayor
DECLARE @MontoMayor numeric(38,2)=(SELECT ccd.Sub_Total from dbo.CAJ_COMPROBANTE_D ccd 
WHERE @IdComprobanteMayor=ccd.id_ComprobantePago AND ccd.id_Detalle=@IdDetalleMayor)
DECLARE @MontoMenor numeric(38,2)=(SELECT ccd.Sub_Total from dbo.CAJ_COMPROBANTE_D ccd 
WHERE @IdComprobanteMenor=ccd.id_ComprobantePago AND ccd.id_Detalle=@Id_DetalleMenor)
DECLARE @NuevoMontoMayor numeric(38,2)= Round(@MontoMayor-@Monto,2)
DECLARE @NuevoMontoMenor numeric(38,2)= Round(@MontoMenor+@Monto,2)
IF (@NuevoMontoMayor>0) --Es valido
BEGIN
	--Para el mayor
	DECLARE @PrecioUnitarioMayor numeric (38,6)=(SELECT ccd.PrecioUnitario from dbo.CAJ_COMPROBANTE_D ccd 
	WHERE @IdComprobanteMayor=ccd.id_ComprobantePago AND ccd.id_Detalle=@IdDetalleMayor)
	DECLARE @NuevocantidadMayor numeric (38,6) = @NuevoMontoMayor/@PrecioUnitarioMayor
	UPDATE dbo.CAJ_COMPROBANTE_D SET 
	dbo.CAJ_COMPROBANTE_D.Cantidad=@NuevocantidadMayor,dbo.CAJ_COMPROBANTE_D.Despachado=@NuevocantidadMayor,
	dbo.CAJ_COMPROBANTE_D.Formalizado=@NuevocantidadMayor,dbo.CAJ_COMPROBANTE_D.Sub_Total=@NuevoMontoMayor
	WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComprobanteMayor AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@IdDetalleMayor

	--Para el menor
	DECLARE @PrecioUnitarioMenor numeric (38,6)=(SELECT ccd.PrecioUnitario from dbo.CAJ_COMPROBANTE_D ccd 
	WHERE @IdComprobanteMenor=ccd.id_ComprobantePago AND ccd.id_Detalle=@Id_DetalleMenor)
	DECLARE @Nuevocantidadmenor numeric (38,6) = @NuevoMontoMenor/@PrecioUnitarioMenor
	UPDATE dbo.CAJ_COMPROBANTE_D SET 
	dbo.CAJ_COMPROBANTE_D.Cantidad=@Nuevocantidadmenor,dbo.CAJ_COMPROBANTE_D.Despachado=@Nuevocantidadmenor,
	dbo.CAJ_COMPROBANTE_D.Formalizado=@Nuevocantidadmenor,Sub_Total=@NuevoMontoMenor
	WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComprobanteMenor AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_DetalleMenor
END
ELSE
BEGIN
	PRINT 'No se puede completar la operacion, el monto a restar supera al actual'
END


--Metodo que convierte una NCE de anulacion a una de descuento conociendo el id de la nota y el id del comprobante a afectar
--Asegurarse de que contienen el mismo mnumero de detalles
--No modifica cantidades
DECLARE @IdNotaCredito int =0
DECLARE @IdComprobanteAfectado int=0

--Modificamos tabla comprobantepago de la nota, el afectado no se toca
    --Obtenemos la nueva glosa
	DECLARE @NuevaGlosa varchar(MAX)= (SELECT 'POR DESCUENTO POR ITEM DE: '+ccp.Cod_TipoComprobante+': '+ccp.Serie+' - '+ccp.Numero
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	DECLARE @idCliente int =(SELECT ccp.Id_Cliente
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	DECLARE @NombreCliente varchar(MAX)=(SELECT ccp.Nom_Cliente
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	DECLARE @DireccionCliente varchar(MAX)=(SELECT ccp.Direccion_Cliente
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	DECLARE @ObsComprobante XML= (SELECT ccp.Obs_Comprobante
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	DECLARE @Placa varchar(MAX) = (SELECT ccp.Placa_Vehiculo
	FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteAfectado)
	--Modificamos cPAgo
	UPDATE dbo.CAJ_COMPROBANTE_PAGO
	SET dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef=@IdComprobanteAfectado,
	dbo.CAJ_COMPROBANTE_PAGO.Glosa=@NuevaGlosa,
	dbo.CAJ_COMPROBANTE_PAGO.Cod_TipoOperacion='05',--Descuento por item
	dbo.CAJ_COMPROBANTE_PAGO.Id_Cliente=@idCliente,
	dbo.CAJ_COMPROBANTE_PAGO.Nom_Cliente=@NombreCliente,
	dbo.CAJ_COMPROBANTE_PAGO.Direccion_Cliente=@DireccionCliente,
	dbo.CAJ_COMPROBANTE_PAGO.Obs_Comprobante=@ObsComprobante,
	dbo.CAJ_COMPROBANTE_PAGO.Placa_Vehiculo=@Placa
	WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdNotaCredito
	--Modificamos CRelacion
	UPDATE dbo.CAJ_COMPROBANTE_RELACION
	SET	dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = @IdComprobanteAfectado,
	dbo.CAJ_COMPROBANTE_RELACION.Obs_Relacion='DESCUENTO POR ITEM'
	WHERE dbo.CAJ_COMPROBANTE_RELACION.id_ComprobantePago=@IdNotaCredito


--Para empresas afectadas por IGV
--Verificar los codigos de afecatcaion de igv de los comprobantes corresponden a los de los comprobantes,
--si los Tipos son gravados entonces solo pueden ser codigo 10 
-- si son gartuitas solo pueden ser codigos de 13 
--SELECT distinct ccd.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,
--pp.Nom_Producto,pp.Cod_TipoOperatividad,ccd.Tipo,ccd.Cod_TipoIGV,ccd.Sub_Total,ccd.IGV,ccp.FechaEmision
-- FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto 
--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
--WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14
-- AND ccp.Flag_Anulado = 0 AND
--(
--(pp.Cod_TipoOperatividad='GRA' AND (ccd.Cod_TipoIGV<>10 OR ccd.IGV=0  OR Sub_Total=0)) OR
--(pp.Cod_TipoOperatividad='GRT' AND (ccd.Cod_TipoIGV<>13 OR ccd.IGV<>0 OR ccd.Sub_Total<>0))
--)
--ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,ccd.id_ComprobantePago


--Para empresas exoneradas  del IGV
--Verificar los codigos de afecatcaion de igv de los comprobantes corresponden a los de los comprobantes,
--si los Tipos son gravados entonces solo pueden ser codigo 20
-- si son gartuitas solo pueden ser codigos de 21

SELECT distinct ccd.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,
pp.Nom_Producto,pp.Cod_TipoOperatividad,ccd.Tipo,ccd.Cod_TipoIGV,ccd.Sub_Total,ccd.IGV,ccp.FechaEmision
 FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto 
INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14
 AND ccp.Flag_Anulado = 0 AND
(
(pp.Cod_TipoOperatividad='GRA' AND (ccd.Cod_TipoIGV<>20 OR ccd.IGV<>0 OR Sub_Total=0)) OR
(pp.Cod_TipoOperatividad='GRT' AND (ccd.Cod_TipoIGV<>21 OR ccd.IGV<>0 OR ccd.Sub_Total<>0))
)
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,ccd.id_ComprobantePago




--Verificar los duplicados de las series
SELECT DISTINCT id_ComprobantePago,cod_tipoComprobante ,Serie,Numero, COUNT(*) AS Duplicados 
	FROM CAJ_COMPROBANTE_PAGO 
	WHERE cod_tipoComprobante IN ('BE','FE','NCE','NDE') and Cod_Libro = 14
	GROUP BY id_ComprobantePago,Serie,Numero,cod_tipoComprobante 
	HAVING COUNT(*) > 1 
	ORDER BY cod_tipoComprobante, Serie,Numero,id_ComprobantePago



--Verifica los posibles errores en nuemrcacion que puede haber
SELECT        Cod_Libro, Cod_TipoComprobante, Serie, Min(Numero) as Minimo, Max(convert(int,numero)) as Maximo, count(*) as Total, 
count(*) - (Max(convert(int,numero)) - Min(convert(int,Numero)) + 1)  as Error
FROM            CAJ_COMPROBANTE_PAGO
where Cod_Libro = '14' AND Cod_TipoComprobante IN ('BE','FE','NCE','NDE')
group by Cod_Libro, Cod_TipoComprobante, Serie
order by Cod_Libro, Cod_TipoComprobante, Serie

--Verifica que las glosas correspondan a los documentos
--Detecta las serie y numeros de NCE que afectan a FE y BE
SELECT        P.Cod_TipoComprobante, P.Serie, P.Numero, F.Cod_TipoComprobante AS Expr1, F.Serie AS Expr2, F.Numero AS Expr3, P.GLOSA
FROM            CAJ_COMPROBANTE_PAGO AS P INNER JOIN
                         CAJ_COMPROBANTE_RELACION AS R ON P.id_ComprobantePago = R.id_ComprobantePago INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS F ON R.Id_ComprobanteRelacion = F.id_ComprobantePago
WHERE COD_TIPORELACION = 'CRE' AND F.SERIE LIKE 'B%' 

--Corrige las glosas
GO

	DECLARE @IdNota int
	declare @id_referencia int
	DECLARE @TipoRef varchar(10)
	DECLARE @SerieRef varchar(10)
	DECLARE @NumeroRef varchar(10)

	DECLARE Cursorfila CURSOR LOCAL FOR 
	SELECT        P.id_ComprobantePago,F.Cod_TipoComprobante, F.Serie AS Serie, F.Numero AS Numero
	FROM            CAJ_COMPROBANTE_PAGO AS P INNER JOIN
							 CAJ_COMPROBANTE_RELACION AS R ON P.id_ComprobantePago = R.id_ComprobantePago INNER JOIN
							 CAJ_COMPROBANTE_PAGO AS F ON R.Id_ComprobanteRelacion = F.id_ComprobantePago
	WHERE COD_TIPORELACION = 'CRE' AND F.SERIE LIKE 'B%'

	--Abrimos el cursor de los precios
	open Cursorfila
	FETCH NEXT FROM Cursorfila INTO @IdNota,@TipoRef,@SerieRef,@NumeroRef
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		UPDATE CAJ_COMPROBANTE_PAGO SET Glosa='POR LA ANULACION DE: '+@TipoRef+': '+@SerieRef+' - '+@NumeroRef
		WHERE CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdNota

		FETCH NEXT FROM Cursorfila INTO @IdNota,@TipoRef,@SerieRef,@NumeroRef
	END
	CLOSE Cursorfila
	DEALLOCATE Cursorfila
go



	UPDATE ALM_ALMACEN_MOV_D
	SET Precio_Unitario = 0, Cantidad = 0, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
	WHERE (Id_AlmacenMov IN (SELECT Id_AlmacenMov  FROM ALM_ALMACEN_MOV WHERE Id_ComprobantePago = @Id_ComprobantePago))

	UPDATE ALM_ALMACEN_MOV
	SET Motivo = 'ANULADO', Flag_Anulado = 1, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
	WHERE Id_ComprobantePago = @Id_ComprobantePago

	-- ELIMINAR ELEMENTOS IMPORTANTES QUE NO TIENEN ESTADO O CONDICION
	DELETE FROM PRI_LICITACIONES_M
	WHERE (id_ComprobantePago = @id_ComprobantePago) 

	-- REVERTIR LA ENTRADA ANTES DE ELIMINAR
	UPDATE CAJ_COMPROBANTE_D
	SET Formalizado -= CR.Valor
	FROM CAJ_COMPROBANTE_D CD INNER JOIN CAJ_COMPROBANTE_RELACION CR
	ON CD.id_ComprobantePago = CR.id_ComprobantePago AND CD.id_Detalle = CR.id_Detalle
	WHERE CR.Id_ComprobanteRelacion = @id_ComprobantePago

	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (Id_ComprobanteRelacion = @id_ComprobantePago)

	DELETE FROM CAJ_SERIES
	WHERE (Id_Tabla = @id_ComprobantePago AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')

	-- recorrer todos los comprobantes rechazados y actualizar los campos
GO


DECLARE @id_ComprobantePago INT, @Cod_tipoComprobante varchar(10)

DECLARE product_cursor CURSOR FOR   
SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Cod_EstadoComprobante='REC' AND ccp.Cod_Libro=14

OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @Cod_tipoComprobante
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
	--Actualizamos la informacione en comprobante pago
	UPDATE dbo.CAJ_COMPROBANTE_PAGO
	SET	
	dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado=1,
	dbo.CAJ_COMPROBANTE_PAGO.Impuesto=0,
	dbo.CAJ_COMPROBANTE_PAGO.Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos=0
	WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@id_ComprobantePago
    --Actualizamos la informacion de los detalles
	UPDATE dbo.CAJ_COMPROBANTE_D
	SET	
	dbo.CAJ_COMPROBANTE_D.Cantidad=0,
	dbo.CAJ_COMPROBANTE_D.Despachado=0,
	dbo.CAJ_COMPROBANTE_D.Formalizado=0,
	dbo.CAJ_COMPROBANTE_D.Descuento=0,
	dbo.CAJ_COMPROBANTE_D.Sub_Total=0,
	dbo.CAJ_COMPROBANTE_D.IGV=0,
	dbo.CAJ_COMPROBANTE_D.ISC=0
	WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@id_ComprobantePago
	--Actualizamos la informacion de la forma de pago
	UPDATE dbo.CAJ_FORMA_PAGO
	SET
	dbo.CAJ_FORMA_PAGO.Monto = 0
	WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@id_ComprobantePago
	--Eliminamos la relacion si es una NCE
	if(@Cod_tipoComprobante='NCE')
	BEGIN
		DELETE FROM dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.id_ComprobantePago=@id_ComprobantePago
	END

FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @Cod_tipoComprobante
END  
  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE #temp1
END

SET DATEFORMAT dmy;
DECLARE @CodTipoComprobante varchar(10)
DECLARE @SerieComprobante varchar(10)

DECLARE @FechaAnterior date ='01-01-1990 00:00:00:000';

DECLARE @IdComprobantePAgo int
DECLARE @CodAux varchar(10)
DECLARE @SerieAux varchar(10)
DECLARE @NumeroAux varchar(10)
DECLARE @FechaActual date

CREATE TABLE #temp1(id_Comprobante int,CodTipoComprobante varchar(10), Serie varchar(10),Numero varchar(10),FechaAnterior_FechaActual varchar(MAX))

DECLARE CURSORCOMPROBANTES CURSOR LOCAL FOR
SELECT DISTINCT ccp.Cod_TipoComprobante,ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE') AND ccp.Cod_Libro=14 
AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie
OPEN CURSORCOMPROBANTES
FETCH NEXT FROM CURSORCOMPROBANTES 
INTO @CodTipoComprobante,@SerieComprobante
WHILE @@FETCH_STATUS = 0
BEGIN   
	   
	   DECLARE CURSORCOMPROBANTES2 CURSOR LOCAL FOR
	   SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
	   WHERE ccp.Cod_TipoComprobante =@CodTipoComprobante AND ccp.Serie=@SerieComprobante
	   AND ccp.Cod_Libro=14 ORDER BY ccp.Numero
	   OPEN CURSORCOMPROBANTES2
	   FETCH NEXT FROM CURSORCOMPROBANTES2
	   INTO @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaActual
	   WHILE @@FETCH_STATUS = 0
	   BEGIN   
		   IF (@FechaAnterior> @FechaActual)
			 BEGIN
				INSERT #temp1
				VALUES
				(
				    @IdComprobantePAgo, -- id_Comprobante - int
				    @CodAux, -- CodTipoComprobante - varchar
				    @SerieAux, -- Serie - varchar
				    @NumeroAux, -- Numero - varchar
				    CONVERT(varchar,@FechaAnterior) + ' - '+CONVERT(varchar,@FechaActual)
				)
				--BREAK;
				SET  @FechaAnterior  ='01-01-1990 00:00:00:000';
			 END
			 ELSE
			 BEGIN
				SET @FechaAnterior=@FechaActual
			 END

		   FETCH NEXT FROM CURSORCOMPROBANTES2 
		   INTO  @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaActual
	   END 
	   CLOSE CURSORCOMPROBANTES2
	   DEALLOCATE CURSORCOMPROBANTES2

	SET  @FechaAnterior  ='01-01-1990 00:00:00:000';
	FETCH NEXT FROM CURSORCOMPROBANTES 
	INTO @CodTipoComprobante,@SerieComprobante
END 
CLOSE CURSORCOMPROBANTES;
DEALLOCATE CURSORCOMPROBANTES	


SELECT * FROM #temp1 t

SET DATEFORMAT dmy;

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE #temp1
END

DECLARE @CodTipoComprobante varchar(10)='FE'
DECLARE @SerieComprobante varchar(10)='F003'

DECLARE @FechaAnterior datetime ='01-01-1900 00:00:00:000';


DECLARE @IdComprobantePAgo int
DECLARE @CodAux varchar(10)
DECLARE @SerieAux varchar(10)
DECLARE @NumeroAux varchar(10)
DECLARE @FechaAux datetime

CREATE TABLE #temp1(id_Comprobante int,CodTipoComprobante varchar(10), Serie varchar(10),Numero varchar(10),FechaAnterior_FechaActual varchar(MAX))

DECLARE CURSORCOMPROBANTES2 CURSOR LOCAL FOR
SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Cod_TipoComprobante =@CodTipoComprobante AND ccp.Serie=@SerieComprobante
AND ccp.Cod_Libro=14 ORDER BY ccp.Numero
OPEN CURSORCOMPROBANTES2
FETCH NEXT FROM CURSORCOMPROBANTES2
INTO @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaAux
WHILE @@FETCH_STATUS = 0
BEGIN   
	IF (convert(datetime,CONVERT(VARCHAR,@FechaAnterior,103)) >convert(datetime,CONVERT(VARCHAR,@FechaAux,103)))
	   BEGIN
		  INSERT #temp1
		  (
		      id_Comprobante,
		      CodTipoComprobante,
		      Serie,
		      Numero,
		      Fecha
		  )
		  VALUES
		  (
		      @IdComprobantePAgo, -- id_Comprobante - int
		      @CodAux, -- CodTipoComprobante - varchar
		      @SerieAux, -- Serie - varchar
		      @NumeroAux, -- Numero - varchar
		      CONVERT(varchar,@FechaAnterior) + ' - '+CONVERT(varchar,@FechaAux)
		  )
		  --BREAK;
		  
	   END
	   ELSE
	   BEGIN
		  SET @FechaAnterior=@FechaAux
	   END

	FETCH NEXT FROM CURSORCOMPROBANTES2 
	INTO  @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaAux
END 
CLOSE CURSORCOMPROBANTES2
DEALLOCATE CURSORCOMPROBANTES2

SELECT* FROM #temp1 t



DECLARE @id_ComprobantePago as int, @id_Cliente as int, @Nom_Cliente as varchar(512), @Direccion as varchar(512),
    @Nro_Documento as varchar(32), @Cod_TipoDocumento as varchar(32);
DECLARE vendor_cursor CURSOR FOR   
SELECT id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO
WHERE        (Nom_Cliente = 'CLIENTES VARIOS') AND (Cod_TipoComprobante = 'BE') AND (Total >= 700)
OPEN vendor_cursor  
FETCH NEXT FROM vendor_cursor   
INTO @id_ComprobantePago
WHILE @@FETCH_STATUS = 0  
BEGIN  
    IF OBJECT_ID('tempdb..#TemporalClientes') IS NOT NULL
    BEGIN
	    DROP TABLE dbo.#TemporalClientes
    END

    SELECT        TOP (100) Id_ClienteProveedor INTO dbo.#TemporalClientes
        FROM            PRI_CLIENTE_PROVEEDOR 
        WHERE Cod_TipoCliente = '002' AND
        Cod_TipoDocumento = '1' and LEN(Nro_Documento) = 8 AND LEN(Ap_Paterno)<>0 AND LEN(Ap_Materno)<>0 AND LEN(Nombres)<>0
	   AND Direccion IS NULL AND RUC_Natural IS NULL AND Foto IS NULL AND Foto IS NULL AND  Firma IS NULL AND Email1 IS NULL
	   AND Email2 IS NULL AND Telefono1 IS NULL AND Telefono2 IS NULL AND Fax IS NULL AND PaginaWeb IS NULL

    IF((SELECT COUNT(*) FROM #TemporalClientes tc) > 0)
    BEGIN
    -- traer cliente aleatorio
    SELECT TOP 1 @id_Cliente=T.Id_ClienteProveedor,@Nom_Cliente = Cliente,@Direccion = Direccion,@Nro_Documento = Nro_Documento, @Cod_TipoDocumento = Cod_TipoDocumento
        FROM
        (select * from dbo.#TemporalClientes
        EXCEPT
        SELECT distinct Id_Cliente FROM CAJ_COMPROBANTE_PAGO
        WHERE CONVERT(DATETIME,CONVERT(VARCHAR(20),FechaEmision,103)) = CONVERT(DATETIME,CONVERT(VARCHAR(20),GETDATE(),103))
        ) AS T inner join PRI_CLIENTE_PROVEEDOR as CP
        on t.Id_ClienteProveedor = cp.Id_ClienteProveedor
        ORDER BY NEWID()
    -- actualizar la tabla
    update CAJ_COMPROBANTE_PAGO
    set Id_Cliente = @id_Cliente, Nom_Cliente = @Nom_Cliente, Cod_TipoDoc = @Cod_TipoDocumento, Doc_Cliente = @Nro_Documento,Direccion_Cliente = @Direccion
    where @id_ComprobantePago = id_ComprobantePago
    END

FETCH NEXT FROM vendor_cursor   
INTO @id_ComprobantePago
END   
CLOSE vendor_cursor;  
DEALLOCATE vendor_cursor;  



EXEC USP_CAJ_COMPROBANTE_D_I '14','BE','B016','00005589','0','00001056',1,'7002333','A0016',600.000000,'NIU',600.000000,'RECARGA VIRTUAL',0.955000,0.00,573.00,'GRA','','001',0,0.000000,0.00,'',0.00,0.00,'20',18.00,0.00,'CLINARES';