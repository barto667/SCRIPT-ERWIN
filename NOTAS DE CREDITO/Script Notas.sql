-- --Trae todos los comprobantes que se pueden afectar por una nota
-- --exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 2072,'CRE','14','PEN','2017-04-29 00:00:00:000','2017-05-29 00:00:00:000'
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota' AND type = 'P')
-- DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota
-- go
-- CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 
-- @IdCliente int,
-- @CodTipoRelacion varchar(10),
-- @CodLibro varchar(10),
-- @CodMoneda varchar(10),
-- @FechaInicio datetime,
-- @FechaFin datetime 
-- WITH ENCRYPTION
-- AS
-- BEGIN
--     SET DATEFORMAT ymd;
--     IF(@CodTipoRelacion='CRE')
--     BEGIN
-- 	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,
-- 	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, SUM(CP.Total) AS Total,
-- 	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, SUM(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible
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
-- 	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente
-- 	   HAVING SUM(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
--     END
--     ELSE IF(@CodTipoRelacion='DEB')
--     BEGIN
-- 	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,
-- 	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, SUM(CP.Total) AS Total,
-- 	    SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, SUM(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible
-- 	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
-- 	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
-- 	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
-- 	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
-- 	   AND CP.Flag_Anulado	 = 0 
-- 	   AND CP.Cod_Libro = @CodLibro
-- 	   AND CP.Id_Cliente = @IdCliente
-- 	   AND CP.FechaEmision>=@FechaInicio 
-- 	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
-- 	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente
--     END	   
-- END
-- go

--Trae todos los comprobantes que se pueden afectar por una nota
--exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 2072,'CRE','14','PEN','2017-04-29 00:00:00:000','2017-06-07 00:00:00:000'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota' AND type = 'P')
DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota
go
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 
@IdCliente int,
@CodTipoRelacion varchar(10),
@CodLibro varchar(10),
@CodMoneda varchar(10),
@FechaInicio datetime,
@FechaFin datetime 
WITH ENCRYPTION
AS
BEGIN
    SET DATEFORMAT ymd;
    IF(@CodTipoRelacion='CRE')
    BEGIN
	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,
	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible
	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
	   AND CP.Flag_Anulado	 = 0 
	   AND CP.Cod_Libro = @CodLibro 
	   AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
	   AND CP.Id_Cliente = @IdCliente
	   AND CP.FechaEmision>=@FechaInicio 
	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente
	   HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
    END
    ELSE IF(@CodTipoRelacion='DEB')
    BEGIN
	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,
	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
	    SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible
	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
	   AND CP.Flag_Anulado	 = 0 
	   AND CP.Cod_Libro = @CodLibro
	   AND CP.Id_Cliente = @IdCliente
	   AND CP.FechaEmision>=@FechaInicio 
	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente
    END	   
END
go


--Trae todos los deatlles de un comprobante por  el id del comprobante de pago
--exec USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante 14
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante 
@Id_Comprobante_D int
WITH ENCRYPTION
AS
BEGIN
    select * from dbo.CAJ_COMPROBANTE_D ccd 
    WHERE ccd.id_ComprobantePago=@Id_Comprobante_D ORDER BY ccd.id_Detalle
END
go