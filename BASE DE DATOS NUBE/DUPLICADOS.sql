SELECT Serie,Numero, COUNT(*) AS contador 
	FROM CAJ_COMPROBANTE_PAGO 
	where cod_tipoComprobante = 'BE' and Cod_Libro = '14'
	GROUP BY Serie,Numero HAVING COUNT(*) > 1 

SELECT Serie,Numero, COUNT(*) AS contador 
	FROM CAJ_COMPROBANTE_PAGO 
	where cod_tipoComprobante = 'FE' and Cod_Libro = '14'
	GROUP BY Serie,Numero HAVING COUNT(*) > 1 


update CAJ_COMPROBANTE_D set Sub_Total = ROUND(Cantidad * PrecioUnitario, 2),
IGV = round(ROUND(Cantidad * PrecioUnitario, 2)/1.18*0.18,2)
where Sub_Total <> ROUND(Cantidad * PrecioUnitario, 2)
-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,2), @CTotal AS NUMERIC(38,2)
DECLARE product_cursor CURSOR FOR   
SELECT        p.id_ComprobantePago, SUM(d.IGV) AS IGV, SUM(d.Sub_Total) AS CTotal--, p.Cod_EstadoComprobante, p.Cod_TipoComprobante, p.Serie, p.Numero, AVG(p.Total) AS Expr1, p.Nom_Cliente
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

