
--Trae los tipos de comprobante y sus series en base a los existentes,
--Toma paramnetros de entrada si incluye los anulados,
--el digito de la serie (F= facturas y b=boletas)
-- y el tipo de comprobante FE,BE,NCE,NDE
-- exec USP_CAJ_COMPROBANTE_PAGO_TraerTipoSerieComprobante 0,'BE','B'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerTipoSerieComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerTipoSerieComprobante
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerTipoSerieComprobante 
@FlagIncluirAnulados bit,
@TipoComprobante varchar(10),
@SerieInicio varchar(1)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @FlagAux bit=1
	if(@FlagIncluirAnulados=1)
	BEGIN
		SELECT   DISTINCT    ccp.Cod_TipoComprobante, ccp.Serie, @FlagAux AS Mostrar
		FROM            CAJ_COMPROBANTE_PAGO ccp
		where ccp.Cod_Libro = 14 AND Cod_TipoComprobante =@TipoComprobante AND ccp.Serie LIKE @SerieInicio+'%' 
		group by  ccp.Cod_TipoComprobante, ccp.Serie
		order by  ccp.Cod_TipoComprobante, ccp.Serie
	END
	ELSE
	BEGIN
		SELECT   DISTINCT    ccp.Cod_TipoComprobante, ccp.Serie, @FlagAux AS Mostrar
		FROM            CAJ_COMPROBANTE_PAGO ccp
		where ccp.Cod_Libro = 14 AND Cod_TipoComprobante =@TipoComprobante AND ccp.Serie LIKE @SerieInicio+'%' AND ccp.Flag_Anulado=0
		group by  ccp.Cod_TipoComprobante, ccp.Serie
		order by  ccp.Cod_TipoComprobante, ccp.Serie 
	END
	
END
go


--Trae una lisat de comprobantes con sus respectivo dato
--Toma paramnetros de entrada si incluye los anulados,
-- La serie del comprobante
-- y el tipo de comprobante FE,BE,NCE,NDE
-- exec USP_CAJ_COMPROBANTE_PAGO_TraerDatosComprobanteXSerieyTipo 'F001','FE',1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerDatosComprobanteXSerieyTipo' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerDatosComprobanteXSerieyTipo
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerDatosComprobanteXSerieyTipo 
@Serie varchar(10),
@TipoComprobante varchar(10),
@IncluirAnulados bit
WITH ENCRYPTION
AS
BEGIN
	DECLARE @FlagPDF bit=0;
	IF(@IncluirAnulados=1)
	BEGIN
		
		SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie+'-'+ccp.Numero as SerieNumero,ccp.Doc_Cliente,
		ccp.Nom_Cliente,ISNULL(pcp.Email1,'')+','+ISNULL(pcp.Email2,'') AS Correo,ccp.Total,@FlagPDF AS PDF
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor 
		WHERE ccp.Serie=@Serie AND ccp.Cod_TipoComprobante=@TipoComprobante AND ccp.Cod_Libro=14
	END
	ELSE
	BEGIN
		SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie+'-'+ccp.Numero as SerieNumero,ccp.Doc_Cliente,
		ccp.Nom_Cliente,ISNULL(pcp.Email1,'')+','+ISNULL(pcp.Email2,'') AS Correo,ccp.Total,@FlagPDF AS PDF
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor 
		WHERE ccp.Serie=@Serie AND ccp.Cod_TipoComprobante=@TipoComprobante AND ccp.Cod_Libro=14 AND ccp.Flag_Anulado=0;
	END
END
go




--Trae todos los comprobantes, filtrando por compra o por venta (14-8)
--exec URP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro 14
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro' AND type = 'P')
DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro
go
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro 
@Cod_Libro int
WITH ENCRYPTION
AS
BEGIN
    SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante+':'+ccp.Serie+'-'+ccp.Numero Documento,ccp.FechaEmision,ccp.Doc_Cliente+':'+ccp.Nom_Cliente Cliente,
    ccd.Descripcion,ccd.Cantidad,ccd.PrecioUnitario,ccd.Descuento DescuentoItem,ccp.Descuento_Total DescuentoGlobal,ccd.Sub_Total SubTotal,ccp.Total
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
    WHERE ccp.Cod_Libro=@Cod_Libro AND ccp.Cod_TipoComprobante IN ('FE','BE','TKF','TKB','BO','FA') AND ccp.Flag_Anulado=0
    ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero
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


--Funcional
DECLARE @IdCliente int=2072
DECLARE @CodLibro varchar(10)='14'
DECLARE @CodMoneda varchar(10)='PEN'
DECLARE @FechaInicio datetime ='01-01-1990'
DECLARE @FechaFin datetime = getdate()

SELECT DISTINCT   CP.id_ComprobantePago,CONVERT (date,CP.FechaEmision) Fecha,CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero SerieNumero, SUM(CP.Total) AS Total, SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, SUM(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible
FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
AND CP.Flag_Anulado	 = 0 
AND CP.Cod_Libro = @CodLibro 
AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
AND CP.Id_Cliente = @IdCliente
AND CP.FechaEmision>@FechaInicio 
AND CP.FechaEmision<@FechaFin
GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero
HAVING SUM(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0


--Beta
DECLARE @IdCliente int=1
DECLARE @CodLibro varchar(10)='14'
DECLARE @CodMoneda varchar(10)='PEN'
DECLARE @FechaInicio datetime ='01-01-1990'
DECLARE @FechaFin datetime = getdate()

--Devuelve una lista de comprobantes afectados


SELECT DISTINCT ccp.id_ComprobanteRef,ABS(sum(ccp.Total)) TotalNota INTO #Temp1 FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Cod_TipoComprobante IN ('NCE','NC') AND ccp.Cod_Libro=@CodLibro AND ccp.Id_Cliente=@IdCliente
AND ccp.Flag_Anulado=0 AND ccp.id_ComprobanteRef IN (SELECT ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE  ccp.Cod_Libro=@CodLibro AND ccp.Cod_Moneda=@CodMoneda
AND ccp.Cod_TipoComprobante IN ('FE','BE','TKF','TKB','BO','FA') AND ccp.Flag_Anulado=0
AND ccp.FechaEmision>=@FechaInicio AND  ccp.FechaEmision<=@FechaFin
AND ccp.Id_Cliente=@IdCliente) GROUP BY ccp.id_ComprobanteRef

SELECT DISTINCT ccp.id_ComprobantePago,ccp.Total INTO #Temp2 FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Id_Cliente=@IdCliente AND ccp.Cod_Libro=@CodLibro AND ccp.Cod_Moneda=@CodMoneda
AND ccp.Cod_TipoComprobante IN ('FE','BE','TKF','TKB','BO','FA') AND ccp.Flag_Anulado=0
AND ccp.FechaEmision>=@FechaInicio AND  ccp.FechaEmision<=@FechaFin
