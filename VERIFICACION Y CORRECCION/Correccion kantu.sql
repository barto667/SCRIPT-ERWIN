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
	AND (ccd.Sub_Total<> CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND(ccd.Cantidad * ccd.PrecioUnitario,2) ELSE 0 END 
	OR ccd.IGV <>  CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND((ccd.Cantidad * ccd.PrecioUnitario/1.18*0.18),2) ELSE 0 END)

-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,6), @CTotal AS NUMERIC(38,6)
DECLARE product_cursor CURSOR FOR   
(
SELECT ccp.id_ComprobantePago,CASE WHEN ccp2.IGV<>0 then ccp2.IGV-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)* ccp.Descuento_Total*18/118 ELSE 0 END AS IGV,
ccp2.Total-(CASE WHEN ccp.Cod_TipoComprobante ='NCE' THEN -1 ELSE 1 END)*ccp.Descuento_Total AS Total
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN (SELECT ccd.id_ComprobantePago,
SUM(CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND(ccd.Cantidad*ccd.PrecioUnitario,6)*18/118  ELSE 0 END) AS IGV,
SUM(CASE WHEN ccd.Cod_TipoIGV=10 THEN ROUND(ccd.Cantidad*ccd.PrecioUnitario,6)  ELSE 0 END) AS Total
 FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE  (ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE'))  AND (ccp.Cod_Libro = 14) AND (ccp.Cod_EstadoComprobante  IN ('INI','EMI'))
GROUP BY ccd.id_ComprobantePago ) ccp2 
ON ccp2.id_ComprobantePago=ccp.id_ComprobantePago
GROUP BY ccp.id_ComprobantePago, ccp2.Total,ccp2.IGV, ccp.Total,ccp.Impuesto,ccp.Descuento_Total,ccp.Cod_TipoComprobante
HAVING AVG(ccp.Total) <> ROUND(ccp2.Total,2) OR AVG(ccp.Impuesto) <> ccp2.IGV)


OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago, @IGV, @CTotal
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
   -- Actualizar los totaltes y el igv
	update CAJ_COMPROBANTE_PAGO set Total = ROUND(@CTotal,2), Impuesto = @IGV
	where id_ComprobantePago =   @id_ComprobantePago        
	 -- actualizar las formas de pago
	 update CAJ_FORMA_PAGO SET Monto = ROUND(@CTotal,2)
	 where id_ComprobantePago =   @id_ComprobantePago and Cod_TipoFormaPago IN ('008','005','006')
      
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal  
END  
  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO
