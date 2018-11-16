
--NOTAS DE CREDITO
--exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 26127,'NC','14','B101','PEN','2016-04-29 00:00:00:000','2018-06-08 00:00:00:000'
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota' AND type = 'P')
-- DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota
-- go
-- CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 
-- @IdCliente int,
-- @CodTipoComprobanteNota varchar(10),
-- @CodLibro varchar(10),
-- @Serie varchar(10),
-- @CodMoneda varchar(10) = NULL,
-- @FechaInicio datetime,
-- @FechaFin datetime 
-- WITH ENCRYPTION
-- AS
-- BEGIN
--     SET DATEFORMAT ymd;
--     --NC : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
--     IF(@CodTipoComprobanteNota='NC') 
--     BEGIN
-- 	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 	   CP.Cod_Turno,
-- 	   CP.Glosa
-- 	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
-- 	   AND CP.Flag_Anulado	 = 0 
-- 	   AND CP.Cod_Libro = @CodLibro 
-- 	   AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
-- 	   AND CP.Id_Cliente = @IdCliente
-- 	   AND CP.FechaEmision>=@FechaInicio 
-- 	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 	   AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
-- 	   HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
--     END
--     --NCE : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
--     IF(@CodTipoComprobanteNota='NCE') 
--     BEGIN
-- 	   IF(LEFT(@Serie,1) ='F')
-- 	   BEGIN
-- 		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 		  CP.Cod_Turno,
-- 		  CP.Glosa
-- 		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 		  WHERE   
-- 		  cp.Cod_TipoComprobante   IN ('FE') 
-- 		  AND CP.Serie LIKE 'F%'
-- 		  AND CP.Flag_Anulado	 = 0 
-- 		  AND CP.Cod_Libro = @CodLibro 
-- 		  AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
-- 		  AND CP.Id_Cliente = @IdCliente
-- 		  AND CP.FechaEmision>=@FechaInicio 
-- 		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
-- 		  HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
-- 	   END
-- 	   IF(LEFT(@Serie,1) ='B')
-- 	   BEGIN
-- 		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 		  CP.Cod_Turno,
-- 		  CP.Glosa
-- 		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 		  WHERE   
-- 		  cp.Cod_TipoComprobante   IN ('BE') 
-- 		  AND CP.Serie LIKE 'B%'
-- 		  AND CP.Flag_Anulado	 = 0 
-- 		  AND CP.Cod_Libro = @CodLibro 
-- 		  AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
-- 		  AND CP.Id_Cliente = @IdCliente
-- 		  AND CP.FechaEmision>=@FechaInicio 
-- 		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
-- 		  HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
-- 	   END
--     END
--     --ND : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
--     IF(@CodTipoComprobanteNota='ND')
--     BEGIN
-- 	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 	   CP.Cod_Turno,
-- 	   CP.Glosa
-- 	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
-- 	   AND CP.Flag_Anulado	 = 0 
-- 	   AND CP.Cod_Libro = @CodLibro
-- 	   AND CP.Id_Cliente = @IdCliente
-- 	   AND CP.FechaEmision>=@FechaInicio 
-- 	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 	   AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
--     END	
--     --NDE : : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
--     IF(@CodTipoComprobanteNota='NDE') 
--     BEGIN
-- 	   IF(LEFT(@Serie,1) ='F')
-- 	   BEGIN
-- 		 SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 		  CP.Cod_Turno,
-- 		  CP.Glosa
-- 		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 		  WHERE   
-- 		  cp.Cod_TipoComprobante   IN ('FE') 
-- 		  AND cp.Serie LIKE 'F%'
-- 		  AND CP.Flag_Anulado	 = 0 
-- 		  AND CP.Cod_Libro = @CodLibro
-- 		  AND CP.Id_Cliente = @IdCliente
-- 		  AND CP.FechaEmision>=@FechaInicio 
-- 		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
-- 	   END
-- 	   IF(LEFT(@Serie,1) ='B')
-- 	   BEGIN
-- 		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
-- 		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
-- 		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
-- 		  CP.Cod_Turno,
-- 		  CP.Glosa
-- 		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 		  WHERE   
-- 		  cp.Cod_TipoComprobante   IN ('BE') 
-- 		  AND cp.Serie LIKE 'B%'
-- 		  AND CP.Flag_Anulado	 = 0 
-- 		  AND CP.Cod_Libro = @CodLibro
-- 		  AND CP.Id_Cliente = @IdCliente
-- 		  AND CP.FechaEmision>=@FechaInicio 
-- 		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
-- 		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
-- 	   END
--     END
-- END
-- go

--exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 26127,'NC','14','B101','PEN','2016-04-29 00:00:00:000','2018-06-08 00:00:00:000'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota' AND type = 'P')
DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota
go
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 
@IdCliente int,
@CodTipoComprobanteNota varchar(10),
@CodLibro varchar(10),
@Serie varchar(10),
@CodMoneda varchar(10) = NULL,
@FechaInicio datetime,
@FechaFin datetime 
WITH ENCRYPTION
AS
BEGIN
    SET DATEFORMAT ymd;
    --NC : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
    IF(@CodTipoComprobanteNota='NC') 
    BEGIN
	  SELECT Res.id_ComprobantePago,
       Res.FechaEmision,
       Res.Cod_Moneda,
       Res.Documento,
       Res.Cliente,
       CAST(Res.Total AS NUMERIC(38, 6)) Total,
	  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
	  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
       Res.Cod_Turno,
       Res.Glosa
	  FROM
	   (
		  SELECT ccp.id_ComprobantePago,
			    ccp.FechaEmision,
			    ccp.Cod_Moneda,
			    ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
			    ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
			    ccp.Total,
			    ISNULL(
			    (
				    SELECT SUM(ABS(ISNULL(ccp2.Total,0)))
				    FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
					    INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp2.id_ComprobantePago = ccr.id_ComprobantePago
				    WHERE ccr.Cod_TipoRelacion = 'CRE'
						AND ccr.Id_ComprobanteRelacion = ccp.id_ComprobantePago
			    ), 0) TotalNotas,
			    ccp.Cod_Turno,
			    ccp.Glosa
		  FROM dbo.CAJ_COMPROBANTE_PAGO ccp
		  WHERE ccp.Cod_TipoComprobante IN ('FE','BE','TKB','TKF','FA','BO') 
			    AND ccp.Flag_Anulado = 0
			    AND ccp.Cod_Libro = @CodLibro
			    AND (@CodMoneda IS NULL
				    OR @CodMoneda = ccp.Cod_Moneda)
			    AND ccp.Id_Cliente=@IdCliente
	   ) Res
	   WHERE 
	   --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
	   Res.FechaEmision >= @FechaInicio
	   AND Res.FechaEmision<DATEADD(day,1,@FechaFin)
	   ORDER BY Res.FechaEmision


    END
    --NCE : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
    IF(@CodTipoComprobanteNota='NCE') 
    BEGIN
	   IF(@Serie LIKE 'F%')
	   BEGIN
		  SELECT Res.id_ComprobantePago,
		  Res.FechaEmision,
		  Res.Cod_Moneda,
		  Res.Documento,
		  Res.Cliente,
		  CAST(Res.Total AS NUMERIC(38, 6)) Total,
		  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
		  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
		  Res.Cod_Turno,
		  Res.Glosa
		  FROM
		  (
			 SELECT ccp.id_ComprobantePago,
				   ccp.FechaEmision,
				   ccp.Cod_Moneda,
				   ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
				   ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
				   ccp.Total,
				   ISNULL(
				   (
					   SELECT SUM(ABS(ccp2.Total))
					   FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
					   WHERE ccp2.id_ComprobanteRef = ccp.id_ComprobantePago
						    AND ccp2.Cod_Libro = @CodLibro
						    AND ccp2.Flag_Anulado = 0
				   ), 0) TotalNotas,
				   ccp.Cod_Turno,
				   ccp.Glosa
			 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			 WHERE ccp.Cod_TipoComprobante IN('FE')
				   AND ccp.Serie LIKE 'F%'
				   AND ccp.Flag_Anulado = 0
				   AND ccp.Cod_Libro = @CodLibro
				   AND (@CodMoneda IS NULL
					   OR @CodMoneda = ccp.Cod_Moneda)
				   AND ccp.Id_Cliente=@IdCliente
		  ) Res
		  WHERE
		  --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
		  Res.FechaEmision >= @FechaInicio
		  AND Res.FechaEmision<DATEADD(day,1,@FechaFin) 
		  ORDER BY Res.FechaEmision

	   END
	   IF(@Serie LIKE 'B%')
	   BEGIN
		  SELECT Res.id_ComprobantePago,
		  Res.FechaEmision,
		  Res.Cod_Moneda,
		  Res.Documento,
		  Res.Cliente,
		  CAST(Res.Total AS NUMERIC(38, 6)) Total,
		  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
		  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
		  Res.Cod_Turno,
		  Res.Glosa
		  FROM
		  (
			 SELECT ccp.id_ComprobantePago,
				   ccp.FechaEmision,
				   ccp.Cod_Moneda,
				   ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
				   ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
				   ccp.Total,
				   ISNULL(
				   (
					   SELECT SUM(ABS(ccp2.Total))
					   FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
					   WHERE ccp2.id_ComprobanteRef = ccp.id_ComprobantePago
						    AND ccp2.Cod_Libro = @CodLibro
						    AND ccp2.Flag_Anulado = 0
				   ), 0) TotalNotas,
				   ccp.Cod_Turno,
				   ccp.Glosa
			 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			 WHERE ccp.Cod_TipoComprobante IN('BE')
				   AND ccp.Serie LIKE 'B%'
				   AND ccp.Flag_Anulado = 0
				   AND ccp.Cod_Libro = @CodLibro
				   AND (@CodMoneda IS NULL
					   OR @CodMoneda = ccp.Cod_Moneda)
				   AND ccp.Id_Cliente=@IdCliente
		  ) Res
		  WHERE --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
		  Res.FechaEmision >= @FechaInicio
		  AND Res.FechaEmision<DATEADD(day,1,@FechaFin) 
		  ORDER BY Res.FechaEmision
	   END
    END

    --ND : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
    IF(@CodTipoComprobanteNota='ND')
    BEGIN
	  SELECT Res.id_ComprobantePago,
       Res.FechaEmision,
       Res.Cod_Moneda,
       Res.Documento,
       Res.Cliente,
       CAST(Res.Total AS NUMERIC(38, 6)) Total,
	  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
	  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
       Res.Cod_Turno,
       Res.Glosa
	  FROM
	   (
		  SELECT ccp.id_ComprobantePago,
			    ccp.FechaEmision,
			    ccp.Cod_Moneda,
			    ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
			    ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
			    ccp.Total,
			    0 TotalNotas,
			    ccp.Cod_Turno,
			    ccp.Glosa
		  FROM dbo.CAJ_COMPROBANTE_PAGO ccp
		  WHERE ccp.Cod_TipoComprobante IN ('FE','BE','TKB','TKF','FA','BO') 
			    AND ccp.Flag_Anulado = 0
			    AND ccp.Cod_Libro = @CodLibro
			    AND (@CodMoneda IS NULL
				    OR @CodMoneda = ccp.Cod_Moneda)
			    AND ccp.Id_Cliente=@IdCliente
	   ) Res
	   WHERE Res.FechaEmision >= @FechaInicio
	   AND Res.FechaEmision<DATEADD(day,1,@FechaFin)
	   ORDER BY Res.FechaEmision
    END	
    --NDE : : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
    IF(@CodTipoComprobanteNota='NDE') 
    BEGIN
	   IF(@Serie LIKE 'F%')
	   BEGIN
		 SELECT Res.id_ComprobantePago,
		  Res.FechaEmision,
		  Res.Cod_Moneda,
		  Res.Documento,
		  Res.Cliente,
		  CAST(Res.Total AS NUMERIC(38, 6)) Total,
		  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
		  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
		  Res.Cod_Turno,
		  Res.Glosa
		  FROM
		  (
			 SELECT ccp.id_ComprobantePago,
				   ccp.FechaEmision,
				   ccp.Cod_Moneda,
				   ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
				   ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
				   ccp.Total,
				   0 TotalNotas,
				   ccp.Cod_Turno,
				   ccp.Glosa
			 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			 WHERE ccp.Cod_TipoComprobante IN('FE')
				   AND ccp.Serie LIKE 'F%'
				   AND ccp.Flag_Anulado = 0
				   AND ccp.Cod_Libro = @CodLibro
				   AND (@CodMoneda IS NULL
					   OR @CodMoneda = ccp.Cod_Moneda)
				   AND ccp.Id_Cliente=@IdCliente
		  ) Res
		  WHERE Res.FechaEmision >= @FechaInicio
		  AND Res.FechaEmision<DATEADD(day,1,@FechaFin) 
		  ORDER BY Res.FechaEmision

	   END
	   IF(@Serie LIKE 'B%')
	   BEGIN
		  SELECT Res.id_ComprobantePago,
		  Res.FechaEmision,
		  Res.Cod_Moneda,
		  Res.Documento,
		  Res.Cliente,
		  CAST(Res.Total AS NUMERIC(38, 6)) Total,
		  CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas,
		  CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible,
		  Res.Cod_Turno,
		  Res.Glosa
		  FROM
		  (
			 SELECT ccp.id_ComprobantePago,
				   ccp.FechaEmision,
				   ccp.Cod_Moneda,
				   ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,
				   ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
				   ccp.Total,
				   0 TotalNotas,
				   ccp.Cod_Turno,
				   ccp.Glosa
			 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			 WHERE ccp.Cod_TipoComprobante IN('BE')
				   AND ccp.Serie LIKE 'B%'
				   AND ccp.Flag_Anulado = 0
				   AND ccp.Cod_Libro = @CodLibro
				   AND (@CodMoneda IS NULL
					   OR @CodMoneda = ccp.Cod_Moneda)
				   AND ccp.Id_Cliente=@IdCliente
		  ) Res
		  WHERE Res.FechaEmision >= @FechaInicio
		  AND Res.FechaEmision<DATEADD(day,1,@FechaFin) 
		  ORDER BY Res.FechaEmision
	   END
    END
END
go




-- IF EXISTS
-- (
--     SELECT *
--     FROM sysobjects
--     WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante;
-- GO
-- CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante @IdComprobantePago INT
-- AS
--      BEGIN
--          SELECT DISTINCT
--                 a.id_ComprobantePago,
--                 a.id_Detalle,
--                 a.Id_Producto,
--                 a.Cod_Almacen,
--                 a.Cantidad,
--                 a.Cod_UnidadMedida,
--                 a.Despachado,
--                 a.Descripcion,
--                 a.PrecioUnitario,
--                 a.Descuento,
--                 a.Sub_Total,
--                 a.Tipo,
--                 a.Obs_ComprobanteD,
--                 a.Cod_Manguera,
--                 a.Flag_AplicaImpuesto,
--                 a.Formalizado,
--                 a.Valor_NoOneroso,
--                 a.Cod_TipoISC,
--                 a.Porcentaje_ISC,
--                 a.ISC,
--                 a.Cod_TipoIGV,
--                 a.Porcentaje_IGV,
--                 a.IGV,
--                 a.Cod_UsuarioReg,
--                 a.Fecha_Reg,
--                 a.Cod_UsuarioAct,
--                 a.Fecha_Act,
--                 a.Cod_TipoComprobante,
--                 a.Serie SerieComprobante,
--                 a.Numero,
--                 a.FechaEmision,
--                 a.Cod_FormaPago,
--                 a.Cod_Moneda,
--                 a.Otros_Cargos,
--                 a.Otros_Tributos,
--                 b.Serie,
--                 a.TipoCambio
--          FROM
-- (
--     SELECT ROW_NUMBER() OVER(ORDER BY ccd.id_ComprobantePago,
--                                       ccd.id_Detalle ASC) Id,
--            ccd.*,
--            ccp.Cod_TipoComprobante,
--            ccp.Serie,
--            ccp.Numero,
--            ccp.FechaEmision,
--            ccp.Cod_FormaPago,
--            ccp.Cod_Moneda,
-- 		 ccp.TipoCambio,
--            ccp.Otros_Cargos,
--            ccp.Otros_Tributos
--     FROM dbo.CAJ_COMPROBANTE_D ccd
--          INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
--     WHERE ccd.id_ComprobantePago = @IdComprobantePago
-- ) a
-- FULL OUTER JOIN
-- (
--     SELECT ROW_NUMBER() OVER(ORDER BY cs.Id_Tabla,
--                                       cs.Item ASC) Id,
--            cs.*
--     FROM dbo.CAJ_SERIES cs
--     WHERE cs.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
--           AND cs.Id_Tabla = @IdComprobantePago
-- ) b ON a.Id = b.Id
--        AND a.id_Detalle = b.Item;
--      END;
-- GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante @IdComprobantePago INT
AS
BEGIN
         SELECT DISTINCT
       ccd.id_ComprobantePago,
       ccd.id_Detalle,
       ccd.Id_Producto,
       ccd.Cod_Almacen,
       ccd.Cantidad,
       ccd.Cod_UnidadMedida,
       ccd.Despachado,
       ccd.Descripcion,
       ccd.PrecioUnitario,
       ccd.Descuento,
       ccd.Sub_Total,
       ccd.Tipo,
       ccd.Obs_ComprobanteD,
       ccd.Cod_Manguera,
       ccd.Flag_AplicaImpuesto,
       ccd.Formalizado,
       ccd.Valor_NoOneroso,
       ccd.Cod_TipoISC,
       ccd.Porcentaje_ISC,
       ccd.ISC,
       ccd.Cod_TipoIGV,
       ccd.Porcentaje_IGV,
       ccd.IGV,
       ccp.Cod_Libro,
       ccp.Cod_Periodo,
       ccp.Cod_Caja,
       ccp.Cod_Turno,
       ccp.Cod_TipoOperacion,
       ccp.Cod_TipoComprobante,
       ccp.Serie SerieComprobante,
       ccp.Numero,
       ccp.Id_Cliente,
       ccp.Cod_TipoDoc,
       ccp.Doc_Cliente,
       ccp.Nom_Cliente,
       ccp.Direccion_Cliente,
       ccp.FechaEmision,
       ccp.FechaVencimiento,
       ccp.FechaCancelacion,
       ccp.Glosa,
       ccp.TipoCambio,
       ccp.Flag_Anulado,
       ccp.Flag_Despachado,
       ccp.Cod_FormaPago,
       ccp.Descuento_Total,
       ccp.Cod_Moneda,
       ccp.Impuesto,
       ccp.Total,
       ccp.Id_GuiaRemision,
       ccp.GuiaRemision,
       ccp.id_ComprobanteRef,
       ccp.Cod_Plantilla,
       ccp.Nro_Ticketera,
       ccp.Cod_UsuarioVendedor,
       ccp.Cod_RegimenPercepcion,
       ccp.Tasa_Percepcion,
       ccp.Placa_Vehiculo,
       ccp.Cod_TipoDocReferencia,
       ccp.Nro_DocReferencia,
       ccp.Cod_EstadoComprobante,
       ccp.MotivoAnulacion,
       ccp.Otros_Cargos,
       ccp.Otros_Tributos,
       dbo.UFN_CAJ_COMPROBANTE_D_Serie(ccp.id_ComprobantePago, ccd.id_Detalle) Serie
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
     INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE ccp.id_ComprobantePago = @IdComprobantePago
END
GO



IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante
@id_ComprobantePago as int
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT vtc.Cod_Sunat as Cod_TipoComprobante, ccp2.Serie+'-'+ ccp2.Numero as Comprobante
    FROM dbo.CAJ_COMPROBANTE_RELACION ccr INNER JOIN 
    dbo.CAJ_COMPROBANTE_PAGO ccp ON ccr.Id_ComprobanteRelacion = ccp.id_ComprobantePago INNER JOIN
    dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccr.id_ComprobantePago = ccp2.id_ComprobantePago INNER JOIN
    dbo.VIS_TIPO_COMPROBANTES vtc ON ccp2.Cod_TipoComprobante = vtc.Cod_TipoComprobante
    WHERE ccr.Cod_TipoRelacion IN ('CRE','DEB') AND
    ccr.id_ComprobantePago=@id_ComprobantePago
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta
	@IdComprobantePago int, 
	@IdComprobanteNota int,
	@CodTiponota varchar(max),
	@Justificacion varchar(max),
	@CodUsuario varchar(max)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @CodTipoCOmprobante varchar(5) = (SELECT ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobanteNota)
    IF @CodTipoCOmprobante IN ('NC','NCE')
    BEGIN
	   --ANULACION COMPLETA
	   IF(@CodTiponota IN ('01','02'))
	   BEGIN
	   --Editamos CAJ_FORMA_PAGO
	   UPDATE dbo.CAJ_FORMA_PAGO
	   SET
		  dbo.CAJ_FORMA_PAGO.Monto=0,
		  dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario,
		  dbo.CAJ_FORMA_PAGO.Fecha_Act=GETDATE()
	   WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
	   --Editamos ALMACEN_MOV
	   UPDATE dbo.ALM_ALMACEN_MOV
	   SET
		  dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO',
		  dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct=@CodUsuario,
		  dbo.ALM_ALMACEN_MOV.Fecha_Act=GETDATE()
	   WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago
	   --Editamos ALMACEN_MOV_D
	   UPDATE dbo.ALM_ALMACEN_MOV_D
	   SET
		  dbo.ALM_ALMACEN_MOV_D.Precio_Unitario=0,
		  dbo.ALM_ALMACEN_MOV_D.Cantidad=0,
		  dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct=@CodUsuario,
		  dbo.ALM_ALMACEN_MOV_D.Fecha_Act=GETDATE()
	   WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov = (SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Id_ComprobantePago=@IdComprobantePago)
	   --Editamos PRI_LICITACIONES_M
	   DELETE dbo.PRI_LICITACIONES_M WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago=@IdComprobantePago
	   --Editamos CAJ_COMPROBANTE_D
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
		  dbo.CAJ_COMPROBANTE_D.Formalizado -= ccr.Valor,
		  dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
		  dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
	   FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago AND ccd.id_Detalle = ccr.id_Detalle
	   WHERE ccr.Id_ComprobanteRelacion=@IdComprobantePago
	   --Editamos CAJ_SERIES
	   DELETE FROM dbo.CAJ_SERIES
	   WHERE (dbo.CAJ_SERIES.Id_Tabla = @IdComprobantePago AND dbo.CAJ_SERIES.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
	   --Editamos CAJ_COMPROBANTE_RELACION
	   DELETE dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion=@IdComprobantePago
	   --Editamos CAJ_COMPROBANTE_PAGO
	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
		  dbo.CAJ_COMPROBANTE_PAGO.Glosa='ANULADO',
		  dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago='004',
		  dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
		  dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
	   WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobantePago
	   END

	   --CORECCION POR ERROR EN LA DESCRIPCION
	   --No se hace nada

	   ----DESCUENTO GLOBAL,DESCUENTO POR ITEM,BONIFICACION,DISMINUCION EN EL VALOR,OTROS CONCEPTOS
	   --IF(@CodTiponota IN ('04','05','08','09','10'))
	   --BEGIN
	   ----Editamos CAJ_FORMA_PAGO
	   ----Debemos obtener el total de la nota de credito, luego debemos de obtener la razon entre el total de la nota y el total del comprobante y multiplicar por ese valor 
	   ----Todos los items de la forma de pago
	   --DECLARE @TotalNota numeric(38,6) = (SELECT ccp.Total FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago = @IdComprobanteNota)
	   --DECLARE @TotalComprobante numeric(38,6) = (SELECT ISNULL(SUM(cfp.Monto),0) FROM dbo.CAJ_FORMA_PAGO cfp WHERE cfp.id_ComprobantePago = @IdComprobantePago)
	   --DECLARE @Factor numeric(38,6) = (1 - (@TotalNota/@TotalComprobante))
	   --UPDATE dbo.CAJ_FORMA_PAGO
	   --SET
	   --    dbo.CAJ_FORMA_PAGO.Monto=dbo.CAJ_FORMA_PAGO.Monto*@Factor
	   --WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
	   --END

	   --DEVOLUCION TOTAL
	   IF(@CodTiponota IN ('06'))
	   BEGIN
	   --Editamos CAJ_FORMA_PAGO
	   UPDATE dbo.CAJ_FORMA_PAGO
	   SET
		  dbo.CAJ_FORMA_PAGO.Monto=0,
		  dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario,
		  dbo.CAJ_FORMA_PAGO.Fecha_Act=GETDATE()
	   WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
	   --Editamos ALMACEN_MOV
	   UPDATE dbo.ALM_ALMACEN_MOV
	   SET
		  dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO',
		  dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct=@CodUsuario,
		  dbo.ALM_ALMACEN_MOV.Fecha_Act=GETDATE()
	   WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago
	   --Editamos ALMACEN_MOV_D
	   UPDATE dbo.ALM_ALMACEN_MOV_D
	   SET
		  dbo.ALM_ALMACEN_MOV_D.Precio_Unitario=0,
		  dbo.ALM_ALMACEN_MOV_D.Cantidad=0,
		  dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct=@CodUsuario,
		  dbo.ALM_ALMACEN_MOV_D.Fecha_Act=GETDATE()
	   WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov = (SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Id_ComprobantePago=@IdComprobantePago)
	   --Editamos PRI_LICITACIONES_M
	   DELETE dbo.PRI_LICITACIONES_M WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago=@IdComprobantePago
	   --Editamos CAJ_COMPROBANTE_D
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
		  dbo.CAJ_COMPROBANTE_D.Formalizado -= ccr.Valor,
		  dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
		  dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
	   FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago AND ccd.id_Detalle = ccr.id_Detalle
	   WHERE ccr.Id_ComprobanteRelacion=@IdComprobantePago
	   --Insertamos CAJ_SERIES
	   INSERT dbo.CAJ_SERIES
	   (
		  Cod_Tabla,
		  Id_Tabla,
		  Item,
		  Serie,
		  Fecha_Vencimiento,
		  Obs_Serie,
		  Cod_UsuarioReg,
		  Fecha_Reg,
		  Cod_UsuarioAct,
		  Fecha_Act
	   )
	   SELECT 
	   'CAJ_COMPROBANTE_PAGO',
	   @IdComprobanteNota,
	   cs.Item,
	   cs.Serie,
	   cs.Fecha_Vencimiento,
	   cs.Obs_Serie,
	   @CodUsuario,
	   GETDATE(),
	   NULL,
	   NULL
	   FROM dbo.CAJ_SERIES cs
	   WHERE cs.Id_Tabla = @IdComprobantePago
	   AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO'
	   --Editamos CAJ_COMPROBANTE_RELACION
	   DELETE dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion=@IdComprobantePago
	   --Editamos CAJ_COMPROBANTE_PAGO
	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
		  dbo.CAJ_COMPROBANTE_PAGO.Glosa='ANULADO',
		  dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago='004',
		  dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
		  dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
	   WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobantePago
	   END

	   --DEVOLUCION POR ITEM
	   IF(@CodTiponota IN ('07'))
	   BEGIN
	   --Editamos CAJ_FORMA_PAGO

	   --Insertamos CAJ_SERIES
	   INSERT dbo.CAJ_SERIES
	   (
		  Cod_Tabla,
		  Id_Tabla,
		  Item,
		  Serie,
		  Fecha_Vencimiento,
		  Obs_Serie,
		  Cod_UsuarioReg,
		  Fecha_Reg,
		  Cod_UsuarioAct,
		  Fecha_Act
	   )
	   SELECT 
	   'CAJ_COMPROBANTE_PAGO',
	   @IdComprobanteNota,
	   cs.Item,
	   cs.Serie,
	   cs.Fecha_Vencimiento,
	   cs.Obs_Serie,
	   @CodUsuario,
	   GETDATE(),
	   NULL,
	   NULL
	   FROM dbo.CAJ_SERIES cs
	   WHERE cs.Id_Tabla = @IdComprobantePago
	   AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO'

	   END
    END
END
GO

--EXEC USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago 17784
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago
	@Id_Comprobante int
WITH ENCRYPTION
AS
BEGIN
    SELECT COUNT(ccp.id_ComprobantePago) Conteo,ISNULL(SUM(ABS(ISNULL(ccp.Total,0))),0) Sumatoria_Notas FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago 
    WHERE ccr.Id_ComprobanteRelacion = @Id_Comprobante AND ccr.Cod_TipoRelacion='CRE'
END
GO

--EXEC USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago 17784
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago
	@Id_Comprobante int
WITH ENCRYPTION
AS
BEGIN
    SELECT ccp.* FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
    WHERE ccr.Id_ComprobanteRelacion = @Id_Comprobante  AND ccr.Cod_TipoRelacion='CRE'
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro
	@Id_ComprobantePago int,
	@Cod_Libro varchar(5)
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT ccp.id_ComprobantePago,ccp.Cod_Libro,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.Id_Cliente, ccp.Cod_TipoDoc, ccp.Doc_Cliente, ccp.Nom_Cliente, ccp.Direccion_Cliente, ccp.FechaEmision, ccp.Total, ccp.Impuesto FROM dbo.CAJ_COMPROBANTE_RELACION ccr 
    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccr.id_ComprobantePago = ccp.id_ComprobantePago
    WHERE ccr.Cod_TipoRelacion IN ('CRE','DEB')
    AND ccp.Flag_Anulado = 0
    AND ((ccr.Cod_TipoRelacion <>'07' AND ccr.Cod_TipoRelacion='CRE') OR (ccr.Cod_TipoRelacion='DEB'))
    AND ccr.Id_ComprobanteRelacion = @Id_ComprobantePago
    AND ccp.Cod_Libro=@Cod_Libro
END
GO



--Temporal cajcomprobante
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TAlmacenXCajaProducto' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TAlmacenXCajaProducto
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TAlmacenXCajaProducto
@CodCaja as varchar(32),
@Id_Producto AS INT
WITH ENCRYPTION
AS
BEGIN
	SELECT DISTINCT PS.Cod_Almacen, A.Des_Almacen
FROM     PRI_PRODUCTO_STOCK AS PS INNER JOIN
                  ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
                  CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
WHERE  (PS.Id_Producto = @Id_Producto) and ca.Cod_Caja = @CodCaja
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen @IdProducto INT,
                                                                              @CodAlmacen VARCHAR(32),
                                                                              @CodMoneda  VARCHAR(32)
WITH ENCRYPTION
AS
     BEGIN
         SELECT DISTINCT
                pps.Id_Producto,
                pps.Cod_UnidadMedida,
                pps.Cod_Almacen,
                vudm.Nom_UnidadMedida,
                vudm.Tipo
         FROM dbo.PRI_PRODUCTO_STOCK pps
              INNER JOIN dbo.VIS_UNIDADES_DE_MEDIDA vudm ON pps.Cod_UnidadMedida = vudm.Cod_UnidadMedida
         WHERE pps.Id_Producto = @IdProducto
               AND pps.Cod_Almacen = @CodAlmacen
               AND pps.Cod_Moneda = @CodMoneda;
     END;
GO




--EXEC dbo.USP_CAJ_COMPROBANTE_D_TraerHistorial
--	@CodLibro = '14',
--	@IdProducto = 16,
--	@IdCliente = 2,
--	@CodAlmacen = 'A101',
--	@CodUnidadMedida = 'NIU',
--	@CodMoneda = 'PEN',
--	@NroFilas = 100

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerHistorial' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerHistorial
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerHistorial
 @CodLibro varchar(5),
 @IdProducto int,
 @IdCliente int,
 @CodAlmacen varchar(32),
 @CodUnidadMedida varchar(32),
 @CodMoneda varchar(5),
 @NroFilas int =100
WITH ENCRYPTION
AS
BEGIN
    DECLARE @Sentencia varchar(max) = 'SELECT DISTINCT TOP '+ CONVERT(varchar(32),@NroFilas)+ ' ccp.FechaEmision,ccp.id_ComprobantePago,ccp.Cod_TipoComprobante+'':''+ccp.Serie+''-''+ccp.Numero Comprobante,ROUND(ccd.Cantidad,2) Cantidad,
    ROUND(ccd.PrecioUnitario,2) PrecioUnitario, pps.Precio_Venta Flete,ROUND(ccd.Cantidad,2)*ROUND(ccd.PrecioUnitario,2) Total
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
    INNER JOIN dbo.PRI_PRODUCTO_STOCK pps  ON ccd.Id_Producto = pps.Id_Producto AND ccd.Cod_Almacen = pps.Cod_Almacen AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
    WHERE ccp.Cod_Libro=''' +@CodLibro+''' AND ccd.Id_Producto='+CONVERT(varchar(32),@IdProducto)+' AND ccd.Cod_Almacen='''+@CodAlmacen+''' AND ccd.Cod_UnidadMedida='''+@CodUnidadMedida+'''
    AND ccp.Cod_Moneda='''+@CodMoneda+''' AND ccp.Id_Cliente='+CONVERT(varchar(32),@IdCliente) +' AND  ccp.Cod_Caja IS NOT NULL AND RTRIM(LTRIM(ccp.Cod_Caja))!='''' AND ccp.Cod_Turno IS NOT NULL AND RTRIM(LTRIM(ccp.Cod_Turno))!=''''
    AND ccp.Cod_TipoComprobante IN (''FE'',''BE'',''FA'',''BO'',''TKF'',''TKB'') AND ccp.Flag_Anulado=0
    ORDER BY ccp.FechaEmision  ASC'
   
    EXECUTE(@Sentencia)
END
GO


--PRESTAMO Y DEVOLUCION DE ENVASES
EXEC dbo.USP_CAJ_CONCEPTO_G
	@Id_Concepto = 70001,
	@Des_Concepto = 'GARANTIA PRESTAMO DE ENVASES',
	@Cod_ClaseConcepto = '007',
	@Flag_Activo = 1,
	@Id_ConceptoPadre = 0,
	@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_CAJ_CONCEPTO_G
	@Id_Concepto = 70002,
	@Des_Concepto = 'GARANTIA DEVOLUCION DE ENVASES',
	@Cod_ClaseConcepto = '006',
	@Flag_Activo = 1,
	@Id_ConceptoPadre = 0,
	@Cod_Usuario = 'MIGRACION'
GO

--Recuepra poroductos activos de un almacen y un tipo de existencia
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen
    @CodTipoExistencia varchar(32),
    @CodAlmacen varchar(32)
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT
       pp.Id_Producto,
       pp.Cod_Producto,
       pp.Cod_Categoria,
       pp.Cod_Marca,
       pp.Cod_TipoProducto,
       pp.Nom_Producto,
       pp.Des_CortaProducto,
       pp.Des_LargaProducto,
       pp.Caracteristicas,
       pp.Porcentaje_Utilidad,
       pp.Cuenta_Contable,
       pp.Contra_Cuenta,
       pp.Cod_Garantia,
       pp.Cod_TipoOperatividad,
       pp.Flag_Activo,
       pp.Flag_Stock,
       pp.Cod_Fabricante,
       pp.Cod_UsuarioReg
    FROM dbo.PRI_PRODUCTOS pp
	    INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
    WHERE pps.Cod_Almacen = @CodAlmacen
		AND pp.Cod_TipoExistencia = @CodTipoExistencia
		AND pp.Flag_Activo = 1;
END
GO



--Temporal de devolucion de prestamo de envases

--EXEC dbo.USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion
--	@Id_ClienteProveedor = 2
IF EXISTS
(
  SELECT *
  FROM sysobjects
  WHERE name=N'USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion'
        AND type='P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion;
GO

CREATE PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion
  @Id_ClienteProveedor INT,
  @Cod_tipoOperacionNS varchar(32) = '30',
  @Cod_tipoOperacionNE varchar(32) = '29'
WITH ENCRYPTION
AS
BEGIN
SELECT DISTINCT
       T1.Id_AlmacenMov,
       T1.Id_ComprobantePago,
	   T1.Fecha,
       T1.SerieNumero,
       T1.Id_Producto,
       T1.Des_Producto,
       T1.Cantidad-ISNULL( T2.Cantidad, 0 ) Cantidad
FROM
(
  SELECT DISTINCT
         aam.Id_AlmacenMov,
         aam.Id_ComprobantePago,
		 aam.Fecha,
         aam.Cod_TipoComprobante+':'+aam.Serie+'-'+aam.Numero SerieNumero,
         aamd.Id_Producto,
         aamd.Des_Producto,
         SUM( aamd.Cantidad )                                 Cantidad
  FROM dbo.ALM_ALMACEN_MOV aam
  INNER JOIN
  dbo.ALM_ALMACEN_MOV_D aamd
  ON aam.Id_AlmacenMov=aamd.Id_AlmacenMov
      INNER JOIN
      dbo.CAJ_COMPROBANTE_PAGO ccp
      ON ccp.id_ComprobantePago=aam.Id_ComprobantePago
  WHERE aam.Cod_TipoComprobante='NS'
        AND ccp.Id_Cliente=@Id_ClienteProveedor
        AND aam.Flag_Anulado=0
        AND ccp.Flag_Anulado=0
	   AND aam.Cod_TipoOperacion=@Cod_tipoOperacionNS
  GROUP BY aam.Id_ComprobantePago,
           aamd.Id_Producto,
           aam.Id_AlmacenMov,
           aam.Cod_TipoComprobante,
		   aam.Fecha,
           aam.Serie,
           aam.Numero,
           aamd.Des_Producto
) T1
LEFT JOIN
(
  SELECT DISTINCT
         aam.Id_ComprobantePago,
         aamd.Id_Producto,
         SUM( aamd.Cantidad ) Cantidad
  FROM dbo.ALM_ALMACEN_MOV aam
  INNER JOIN
  dbo.ALM_ALMACEN_MOV_D aamd
  ON aam.Id_AlmacenMov=aamd.Id_AlmacenMov
      INNER JOIN
      dbo.CAJ_COMPROBANTE_PAGO ccp
      ON ccp.id_ComprobantePago=aam.Id_ComprobantePago
  WHERE aam.Cod_TipoComprobante='NE'
        AND ccp.Id_Cliente=@Id_ClienteProveedor
        AND aam.Flag_Anulado=0
        AND ccp.Flag_Anulado=0
	   AND aam.Cod_TipoOperacion=@Cod_tipoOperacionNE
  GROUP BY aam.Id_ComprobantePago,
           aamd.Id_Producto
) T2
ON T1.Id_ComprobantePago=T2.Id_ComprobantePago
   AND T1.Id_Producto=T2.Id_Producto
WHERE T1.Cantidad-ISNULL( T2.Cantidad, 0 )>0
ORDER BY T1.SerieNumero
END;

GO
--EXEC dbo.USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto
--	@Id_Cliente = 2,
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto
GO

CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto
 @Id_Cliente int,
 @Id_ConceptoRI int = 70001,
 @Id_ConceptoRE int = 70002,
 @Cod_MonedaIngreso varchar(32)='PEN'
 WITH ENCRYPTION
AS
BEGIN
SELECT 'RI' TipoComprobante,(T1.SumIngreso- T2.SumEgreso) SumIngreso FROM (
    SELECT DISTINCT 'RI' TipoComprobante, ISNULL(SUM(ISNULL(ccm.Ingreso,0)),0) SumIngreso,@Id_Cliente Id_ClienteProveedor
    FROM dbo.CAJ_CAJA_MOVIMIENTOS ccm
    WHERE ccm.Id_ClienteProveedor=@Id_Cliente
    AND ccm.Cod_MonedaIng= @Cod_MonedaIngreso
    AND ccm.Id_Concepto=@Id_ConceptoRI
    AND ccm.Id_MovimientoRef <> 0 
    AND ccm.Cod_TipoComprobante='RI' 
    AND ccm.Flag_Extornado=0) T1
    LEFT JOIN
    (SELECT DISTINCT 'RE' TipoComprobante, ISNULL(SUM(ccm.Egreso),0) SumEgreso,@Id_Cliente Id_ClienteProveedor
    FROM dbo.CAJ_CAJA_MOVIMIENTOS ccm
    WHERE ccm.Id_ClienteProveedor=@Id_Cliente
    AND ccm.Cod_MonedaEgr= @Cod_MonedaIngreso
    AND ccm.Id_Concepto=@Id_ConceptoRE
    AND ccm.Cod_TipoComprobante='RE' 
    AND ccm.Flag_Extornado=0) T2
    ON T1.Id_ClienteProveedor=T2.Id_ClienteProveedor
END
GO