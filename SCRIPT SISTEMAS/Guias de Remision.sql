IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_SUCURSAL_TraerSucursalesActivas' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas
GO

CREATE PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas
WITH ENCRYPTION
AS
BEGIN
	SELECT ps.Cod_Sucursal, ps.Nom_Sucursal, ps.Dir_Sucursal, ps.Por_UtilidadMax, ps.Por_UtilidadMin, ps.Cod_UsuarioAdm, ps.Cabecera_Pagina, ps.Pie_Pagina, ps.Cod_Ubigeo,COALESCE(ps.Cod_UsuarioAct,ps.Cod_UsuarioReg) Cod_Usuario,COALESCE(ps.Fecha_Act,ps.Fecha_Reg) Fecha_UltimaModificacion FROM dbo.PRI_SUCURSAL ps WHERE ps.Flag_Activo = 1
END
GO


--trae un datatable con todos los comprobante por numero de documento y cod libro
--genera un campo extra FechaEmisionAbsoluta que es la fecha de emision absoluta
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro 
	@NumeroDocumento	varchar(32),
	@CodLibro	varchar(4)
WITH ENCRYPTION
AS
BEGIN
	IF @CodLibro<>''
	BEGIN
		SELECT DISTINCT 
			 ccp.id_ComprobantePago,
			 ISNULL(ccp.Cod_Libro,'') Cod_Libro,
			 ISNULL(ccp.Cod_Periodo,'') Cod_Periodo,
			 ISNULL(ccp.Cod_Caja,'') Cod_Caja,
			 ISNULL(cc.Des_Caja,'') Des_Caja,
			 ISNULL(ccp.Cod_Turno,'') Cod_Turno,
			 ISNULL(ccp.Cod_TipoComprobante,'') Cod_TipoComprobante,
			 ISNULL(vtc.Nom_TipoComprobante,'') Nom_TipoComprobante,
			 ISNULL(ccp.Cod_TipoComprobante+':','') + ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') CodSerieNumero,
			 ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') SerieNumero,
			 ISNULL(ccp.Serie,'') Serie,
			 ISNULL(ccp.Numero,'') Numero,
			 ISNULL(ccp.Id_Cliente,0) Id_Cliente,
			 ISNULL(ccp.Cod_TipoDoc,'') Cod_TipoDoc,
			 ISNULL(vtd.Nom_TipoDoc,'') Nom_TipoDoc,
			 ISNULL(ccp.Doc_Cliente,'') Doc_Cliente,
			 ISNULL(ccp.Nom_Cliente,'') Nom_Cliente,
			 ISNULL(ccp.Direccion_Cliente,'') Direccion_Cliente,
			 convert(datetime,convert(date,ccp.FechaEmision)) FechaEmision,
			 ccp.Flag_Anulado,
			 ISNULL(ccp.Cod_Moneda,'') Cod_Moneda,
			 ISNULL(vm.Nom_Moneda,'') Nom_Moneda,
			 ISNULL(ccp.Impuesto,0) Impuesto,
			 ISNULL(ccp.Total,0) Total,
			 ISNULL( ccp.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,
			 ISNULL(ccp.Cod_EstadoComprobante,'') Cod_EstadoComprobante,
			 ISNULL(ccp.MotivoAnulacion,'') MotivoAnulacion,
			 ISNULL(ccp.Otros_Cargos,0) Otros_Cargos,
			 ISNULL(ccp.Otros_Tributos,0) Otros_Tributos
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_CAJAS cc
		ON cc.Cod_Caja=ccp.Cod_Caja INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc
		ON ccp.Cod_TipoComprobante=vtc.Cod_TipoComprobante INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd
		ON ccp.Cod_TipoDoc=vtd.Cod_TipoDoc INNER JOIN dbo.VIS_MONEDAS vm
		ON ccp.Cod_Moneda = vm.Cod_Moneda
		WHERE ccp.Doc_Cliente=@NumeroDocumento AND ccp.Cod_Libro=@CodLibro 
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END
	ELSE
	BEGIN
		SELECT DISTINCT 
			 ccp.id_ComprobantePago,
			 ISNULL(ccp.Cod_Libro,'') Cod_Libro,
			 ISNULL(ccp.Cod_Periodo,'') Cod_Periodo,
			 ISNULL(ccp.Cod_Caja,'') Cod_Caja,
			 ISNULL(cc.Des_Caja,'') Des_Caja,
			 ISNULL(ccp.Cod_Turno,'') Cod_Turno,
			 ISNULL(ccp.Cod_TipoComprobante,'') Cod_TipoComprobante,
			 ISNULL(vtc.Nom_TipoComprobante,'') Nom_TipoComprobante,
			 ISNULL(ccp.Cod_TipoComprobante+':','') + ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') CodSerieNumero,
			 ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') SerieNumero,
			 ISNULL(ccp.Serie,'') Serie,
			 ISNULL(ccp.Numero,'') Numero,
			 ISNULL(ccp.Id_Cliente,0) Id_Cliente,
			 ISNULL(ccp.Cod_TipoDoc,'') Cod_TipoDoc,
			 ISNULL(vtd.Nom_TipoDoc,'') Nom_TipoDoc,
			 ISNULL(ccp.Doc_Cliente,'') Doc_Cliente,
			 ISNULL(ccp.Nom_Cliente,'') Nom_Cliente,
			 ISNULL(ccp.Direccion_Cliente,'') Direccion_Cliente,
			 convert(datetime,convert(date,ccp.FechaEmision)) FechaEmision,
			 ccp.Flag_Anulado,
			 ISNULL(ccp.Cod_Moneda,'') Cod_Moneda,
			 ISNULL(vm.Nom_Moneda,'') Nom_Moneda,
			 ISNULL(ccp.Impuesto,0) Impuesto,
			 ISNULL(ccp.Total,0) Total,
			 ISNULL( ccp.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,
			 ISNULL(ccp.Cod_EstadoComprobante,'') Cod_EstadoComprobante,
			 ISNULL(ccp.MotivoAnulacion,'') MotivoAnulacion,
			 ISNULL(ccp.Otros_Cargos,0) Otros_Cargos,
			 ISNULL(ccp.Otros_Tributos,0) Otros_Tributos
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_CAJAS cc
		ON cc.Cod_Caja=ccp.Cod_Caja INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc
		ON ccp.Cod_TipoComprobante=vtc.Cod_TipoComprobante INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd
		ON ccp.Cod_TipoDoc=vtd.Cod_TipoDoc INNER JOIN dbo.VIS_MONEDAS vm
		ON ccp.Cod_Moneda = vm.Cod_Moneda
		WHERE ccp.Doc_Cliente=@NumeroDocumento
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END

END
GO

--trae un datatable con todos los comprobante por nombre de cliente y cod libro
--genera un campo extra FechaEmisionAbsoluta que es la fecha de emision absoluta
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro 
	@NombreCliente	varchar(250),
	@CodLibro	varchar(4)
WITH ENCRYPTION
AS
BEGIN
	IF @CodLibro <> ''
	BEGIN
		SELECT DISTINCT 
			 ccp.id_ComprobantePago,
			 ISNULL(ccp.Cod_Libro,'') Cod_Libro,
			 ISNULL(ccp.Cod_Periodo,'') Cod_Periodo,
			 ISNULL(ccp.Cod_Caja,'') Cod_Caja,
			 ISNULL(cc.Des_Caja,'') Des_Caja,
			 ISNULL(ccp.Cod_Turno,'') Cod_Turno,
			 ISNULL(ccp.Cod_TipoComprobante,'') Cod_TipoComprobante,
			 ISNULL(vtc.Nom_TipoComprobante,'') Nom_TipoComprobante,
			 ISNULL(ccp.Cod_TipoComprobante+':','') + ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') CodSerieNumero,
			 ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') SerieNumero,
			 ISNULL(ccp.Serie,'') Serie,
			 ISNULL(ccp.Numero,'') Numero,
			 ISNULL(ccp.Id_Cliente,0) Id_Cliente,
			 ISNULL(ccp.Cod_TipoDoc,'') Cod_TipoDoc,
			 ISNULL(vtd.Nom_TipoDoc,'') Nom_TipoDoc,
			 ISNULL(ccp.Doc_Cliente,'') Doc_Cliente,
			 ISNULL(ccp.Nom_Cliente,'') Nom_Cliente,
			 ISNULL(ccp.Direccion_Cliente,'') Direccion_Cliente,
			 convert(datetime,convert(date,ccp.FechaEmision)) FechaEmision,
			 ccp.Flag_Anulado,
			 ISNULL(ccp.Cod_Moneda,'') Cod_Moneda,
			 ISNULL(vm.Nom_Moneda,'') Nom_Moneda,
			 ISNULL(ccp.Impuesto,0) Impuesto,
			 ISNULL(ccp.Total,0) Total,
			 ISNULL( ccp.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,
			 ISNULL(ccp.Cod_EstadoComprobante,'') Cod_EstadoComprobante,
			 ISNULL(ccp.MotivoAnulacion,'') MotivoAnulacion,
			 ISNULL(ccp.Otros_Cargos,0) Otros_Cargos,
			 ISNULL(ccp.Otros_Tributos,0) Otros_Tributos
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_CAJAS cc
		ON cc.Cod_Caja=ccp.Cod_Caja INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc
		ON ccp.Cod_TipoComprobante=vtc.Cod_TipoComprobante INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd
		ON ccp.Cod_TipoDoc=vtd.Cod_TipoDoc INNER JOIN dbo.VIS_MONEDAS vm
		ON ccp.Cod_Moneda = vm.Cod_Moneda
		WHERE ccp.Nom_Cliente like '%'+@NombreCliente+'%' AND ccp.Cod_Libro=@CodLibro 
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END
	ELSE
	BEGIN
		SELECT DISTINCT 
			 ccp.id_ComprobantePago,
			 ISNULL(ccp.Cod_Libro,'') Cod_Libro,
			 ISNULL(ccp.Cod_Periodo,'') Cod_Periodo,
			 ISNULL(ccp.Cod_Caja,'') Cod_Caja,
			 ISNULL(cc.Des_Caja,'') Des_Caja,
			 ISNULL(ccp.Cod_Turno,'') Cod_Turno,
			 ISNULL(ccp.Cod_TipoComprobante,'') Cod_TipoComprobante,
			 ISNULL(vtc.Nom_TipoComprobante,'') Nom_TipoComprobante,
			 ISNULL(ccp.Cod_TipoComprobante+':','') + ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') CodSerieNumero,
			 ISNULL(ccp.Serie,'')+'-'+ ISNULL(ccp.Numero,'') SerieNumero,
			 ISNULL(ccp.Serie,'') Serie,
			 ISNULL(ccp.Numero,'') Numero,
			 ISNULL(ccp.Id_Cliente,0) Id_Cliente,
			 ISNULL(ccp.Cod_TipoDoc,'') Cod_TipoDoc,
			 ISNULL(vtd.Nom_TipoDoc,'') Nom_TipoDoc,
			 ISNULL(ccp.Doc_Cliente,'') Doc_Cliente,
			 ISNULL(ccp.Nom_Cliente,'') Nom_Cliente,
			 ISNULL(ccp.Direccion_Cliente,'') Direccion_Cliente,
			 convert(datetime,convert(date,ccp.FechaEmision)) FechaEmision,
			 ccp.Flag_Anulado,
			 ISNULL(ccp.Cod_Moneda,'') Cod_Moneda,
			 ISNULL(vm.Nom_Moneda,'') Nom_Moneda,
			 ISNULL(ccp.Impuesto,0) Impuesto,
			 ISNULL(ccp.Total,0) Total,
			 ISNULL( ccp.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,
			 ISNULL(ccp.Cod_EstadoComprobante,'') Cod_EstadoComprobante,
			 ISNULL(ccp.MotivoAnulacion,'') MotivoAnulacion,
			 ISNULL(ccp.Otros_Cargos,0) Otros_Cargos,
			 ISNULL(ccp.Otros_Tributos,0) Otros_Tributos
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_CAJAS cc
		ON cc.Cod_Caja=ccp.Cod_Caja INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc
		ON ccp.Cod_TipoComprobante=vtc.Cod_TipoComprobante INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd
		ON ccp.Cod_TipoDoc=vtd.Cod_TipoDoc INNER JOIN dbo.VIS_MONEDAS vm
		ON ccp.Cod_Moneda = vm.Cod_Moneda
		WHERE ccp.Nom_Cliente like '%'+@NombreCliente+'%' 
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END
END
go