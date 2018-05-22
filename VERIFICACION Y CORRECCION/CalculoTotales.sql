
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



--Prueba, falta verificar

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
	(SELECT 'OTROS' as Motivo,CONVERT(VARCHAR(10), @Fecha, 126) as Fecha,
	'TICKET DE MAQUINA REGISTRADORA' as NomComprobante
	, CP.Serie, 
	MIN(CP.Numero) AS NumeroComprobante,
	MAX(CP.Numero) AS FinalTicketera,
	'SIN DOCUMENTO' as TipoDocumento,
	'' as NumeroDocumento,
	'' as RazonSocial, 
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
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Cod_TipoComprobante like 'TKB%'
	and CP.Flag_Anulado=0
	GROUP BY VTC.Cod_Sunat, CP.Serie
	union 
	SELECT 'OTROS' as Motivo,CONVERT(VARCHAR(10), @Fecha, 126) as Fecha,
	'TICKET DE MAQUINA REGISTRADORA' as NomComprobante,
	CP.Serie,
	CP.Numero AS NumeroComprobante,
	'' AS FinalTicketera,
	'RUC' as TipoDocumento,
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
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Cod_TipoComprobante like 'TKF%'
	and CP.Flag_Anulado=0
	GROUP BY CP.Numero, CP.Serie,Cp.Doc_Cliente,CP.Nom_Cliente) Res1
	UNION
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
	GROUP BY CP.Numero, CP.Serie,Cp.Doc_Cliente,CP.Nom_Cliente,CP.Cod_TipoComprobante,CP.Cod_TipoDoc) RES2
END
go