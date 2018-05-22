--Procedimiento que trae todas las series electronicas del objeto CAJ_COMPROBANTE_PAGO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerTodasLasSeriesElectronicas' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerTodasLasSeriesElectronicas
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerTodasLasSeriesElectronicas
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT ccp.Cod_TipoComprobante,ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp
    WHERE ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
    AND ccp.Cod_Libro=14 AND (ccp.Serie LIKE ('B%') OR ccp.Serie LIKE ('F%'))
    ORDER BY ccp.Cod_TipoComprobante,ccp.Serie
END
GO

--Procedimiento que trae todos los comprobantes en base a su serie, codtipo comprobante y su cod libro
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerComprobantesXCodTipoComprobante_Serie_CodLibro' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerComprobantesXCodTipoComprobante_Serie_CodLibro
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerComprobantesXCodTipoComprobante_Serie_CodLibro
	@Cod_TipoComprobante varchar(5),
	@Serie varchar(5),
	@Cod_Libro varchar(2)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @Ruc varchar(max)=(SELECT pe.RUC FROM dbo.PRI_EMPRESA pe)
    SELECT CONCAT(@Ruc,'-',vtc.Cod_Sunat,'-',ccp.Serie,'-',ccp.Numero) as Nombre_Concatenado,ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,vtc.Cod_Sunat,ccp.Serie+'-'+ccp.Numero Serie_Numero, 
    ccp.Doc_Cliente,ccp.Nom_Cliente,ccp.Total,
    CONVERT(bit,0) XML, CONVERT(bit,0) PDF, CONVERT(bit,0) CDR FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
    INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
    WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Cod_Libro=@Cod_Libro
    ORDER BY ccp.Cod_TipoComprobante,Serie_Numero
END
GO

-- Traer Paginado de comprobantes
-- exec USP_CAJ_COMPROBANTE_PAGO_FTP_TraerComprobantesElectronicos_TP 1000,1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_FTP_TraerComprobantesElectronicos_TP' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FTP_TraerComprobantesElectronicos_TP
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FTP_TraerComprobantesElectronicos_TP
	@TamañoPagina int,
	@NumeroPagina int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @RUC  varchar(11) =(SELECT TOP 1 pe.RUC FROM dbo.PRI_EMPRESA pe)
	SELECT aComprobante.NumeroFila,aComprobante.id_ComprobantePago,@RUC RUC,aComprobante.Cod_TipoComprobante,aComprobante.Serie,aComprobante.NombreArchivo 
    FROM (SELECT ROW_NUMBER() OVER (ORDER BY ccp.id_ComprobantePago) NumeroFila, ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,CONCAT (@RUC,'-',vtc.Cod_Sunat,'-',ccp.Serie,'-',ccp.Numero) NombreArchivo  
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
    INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante 
    WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') 
    AND ccp.Id_GuiaRemision<>3 AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')) aComprobante
    WHERE aComprobante.NumeroFila BETWEEN ((@TamañoPagina*@NumeroPagina)+1) AND (@TamañoPagina*(@NumeroPagina+1))

END
go


-- Actualzia el estado de un comprobante
-- exec USP_CAJ_COMPROBANTE_PAGO_MarcarEstado 1000,1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_MarcarEstado' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarEstado
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_MarcarEstado
	@id_ComprobantePago int,
	@Estado int
WITH ENCRYPTION
AS
BEGIN
    UPDATE dbo.CAJ_COMPROBANTE_PAGO
    SET
        dbo.CAJ_COMPROBANTE_PAGO.Id_GuiaRemision = @Estado -- int
    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@id_ComprobantePago
        
END
go




