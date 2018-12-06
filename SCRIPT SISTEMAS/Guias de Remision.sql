
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

IF OBJECT_ID('CAJ_GUIA_REMISION_D','U') IS NOT NULL
BEGIN
	DROP TABLE CAJ_GUIA_REMISION_D
END
GO
IF OBJECT_ID('CAJ_GUIA_REMISION','U') IS NOT NULL
BEGIN
	DROP TABLE CAJ_GUIA_REMISION
END
GO


--Creamos las tablas
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE', 'U') IS  NULL
BEGIN
	CREATE TABLE CAJ_GUIA_REMISION_REMITENTE
	(
		Id_GuiaRemisionRemitente int IDENTITY(1,1) PRIMARY KEY,
		Cod_Caja varchar(32) FOREIGN KEY REFERENCES dbo.CAJ_CAJAS(Cod_Caja),
		Cod_Turno varchar(32) FOREIGN KEY REFERENCES dbo.CAJ_TURNO_ATENCION(Cod_Turno),
		Cod_TipoComprobante varchar(5) NOT NULL,
		Cod_Libro varchar(2) NOT NULL, --Indica si la guia es para emitir o para registrar (similar a venta-compra)
		Serie varchar(5) NOT NULL,
		Numero varchar(30) NOT NULL,
		Fecha_Emision datetime NOT NULL,
		Fecha_TrasladoBienes datetime NOT NULL,
		Fecha_EntregaBienes datetime,
		Cod_MotivoTraslado varchar(5) NOT NULL,
		Cod_ModalidadTraslado varchar(5),
		Cod_UnidadMedida varchar(5) NOT NULL,
		Id_ClienteDestinatario int FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor),
		Cod_UbigeoPartida varchar(8) NOT NULL,
		Direccion_Partida varchar(max) NOT NULL,
		Cod_UbigeoLlegada varchar(8) NOT NULL,
		Direccion_LLegada varchar(max) NOT NULL,
		Documentos_Relacionados varchar(max),
		Flag_Transbordo bit,
		Peso_Bruto numeric(38,6) NOT NULL,
		Id_ClienteTransportistaPublico int FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor),
		Num_PlacaTransportePrivado varchar(max),
		Conductor_TransportePrivado varchar(max),
		Obs_Transportista varchar(max),
		Nro_Contenedor varchar(64),
		Cod_Puerto varchar(64),
		Nro_Bulltos int, --O pallets, numerico 12 segun sunat
		Certificado_Inscripcion varchar(max),
		Certificado_Habilitacion varchar(max),
		Cod_EstadoGuia varchar(8) NOT NULL,
		Obs_GuiaRemisionRemitente varchar(max),
		Id_GuiaRemisionRemitenteBaja int NULL,
		Flag_Anulado bit,
		Cod_UsuarioReg varchar(32) NOT NULL,
		Fecha_Reg datetime NOT NULL,
		Cod_UsuarioAct varchar(32),
		Fecha_Act datetime
	)
END
GO
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_D', 'U') IS  NULL
BEGIN
	CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_D
	(
		Id_GuiaRemisionRemitente int NOT NULL FOREIGN KEY (Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente),
		Id_Detalle int NOT NULL,
		Cod_Almacen varchar(32),
		Cod_UnidadMedida varchar(5),
		Id_Producto int FOREIGN KEY REFERENCES dbo.PRI_PRODUCTOS(Id_Producto),
		Cantidad numeric(38,10) NOT NULL,
		Descripcion varchar(max) NOT NULL,
		Peso numeric(38,6) NOT NULL,
		Obs_Detalle varchar(max),
		Cod_ProductoSunat varchar(32),
		Cod_UsuarioReg varchar(32) NOT NULL,
		Fecha_Reg datetime NOT NULL,
		Cod_UsuarioAct varchar(32),
		Fecha_Act datetime
	)
	ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_D ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_D PRIMARY KEY (Id_GuiaRemisionRemitente, Id_Detalle)
END
GO
 

--Metodos CRUD
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G
	@Id_GuiaRemisionRemitente int output,
	@Cod_Caja varchar(32),
	@Cod_Turno varchar(32),
	@Cod_TipoComprobante varchar(5) ,
	@Cod_Libro varchar(2),
	@Serie varchar(5) ,
	@Numero varchar(30) ,
	@Fecha_Emision datetime ,
	@Fecha_TrasladoBienes datetime,
	@Fecha_EntregaBienes datetime,
	@Cod_MotivoTraslado varchar(5),
	@Cod_ModalidadTraslado varchar(5),
	@Cod_UnidadMedida varchar(5),
	@Id_ClienteDestinatario int,
	@Cod_UbigeoPartida varchar(8),
	@Direccion_Partida varchar(max),
	@Cod_UbigeoLlegada varchar(8),
	@Direccion_LLegada varchar(max),
	@Documentos_Relacionados varchar(max),
	@Flag_Transbordo bit,
	@Peso_Bruto numeric(16,6),
	@Id_ClienteTransportistaPublico int,
	@Num_PlacaTransportePrivado varchar(max),
	@Conductor_TransportePrivado varchar(max),
	@Obs_Transportista varchar(max),
	@Nro_Contenedor varchar(64),
	@Cod_Puerto varchar(64),
	@Nro_Bulltos int,
	@Certificado_Inscripcion varchar(max),
	@Certificado_Habilitacion varchar(max),
	@Cod_EstadoGuia varchar(8),
	@Obs_GuiaRemisionRemitente varchar(max),
	@Id_GuiaRemisionRemitenteBaja int,
	@Flag_Anulado bit,
	@Cod_Usuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT ymd;
	IF @Id_ClienteTransportistaPublico =0
	BEGIN
		SET @Id_ClienteTransportistaPublico =NULL
	END
	IF (@Numero='' AND @Cod_Libro='14')
	BEGIN
		SET @Numero = (SELECT RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(cgrr.Numero)),0)+1), 8) 
		FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr 
		WHERE cgrr.Cod_TipoComprobante=@Cod_TipoComprobante AND cgrr.Serie=@Serie)
	END
	SET @Id_GuiaRemisionRemitente = (ISNULL((SELECT TOP 1 cgrr.Id_GuiaRemisionRemitente FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
	WHERE cgrr.Cod_TipoComprobante=@Cod_TipoComprobante AND cgrr.Serie=@Serie AND cgrr.Numero=@Numero),0))
	IF	@Id_GuiaRemisionRemitente = 0 
	BEGIN
		INSERT dbo.CAJ_GUIA_REMISION_REMITENTE
		VALUES
		(
		    -- Id_GuiaRemisionRemitente - int
		    @Cod_Caja, -- Cod_Caja - varchar
		    @Cod_Turno, -- Cod_Turno - varchar
		    @Cod_TipoComprobante, -- Cod_TipoComprobante - varchar
		    @Cod_Libro, -- Cod_Libro - varchar
		    @Serie, -- Serie - varchar
		    @Numero, -- Numero - varchar
		    CONVERT(DATETIME, @Fecha_Emision,121), -- Fecha_Emision - datetime
		    CONVERT(DATETIME, @Fecha_TrasladoBienes,121), -- Fecha_TrasladoBienes - datetime
		    CONVERT(DATETIME, @Fecha_EntregaBienes,121), -- Fecha_EntregaBienes - datetime
		    @Cod_MotivoTraslado, -- Cod_MotivoTraslado - varchar
		    @Cod_ModalidadTraslado, -- Cod_ModalidadTraslado - varchar
		    @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
		    @Id_ClienteDestinatario, -- Id_ClienteDestinatario - int
		    @Cod_UbigeoPartida, -- Cod_UbigeoPartida - varchar
		    @Direccion_Partida, -- Direccion_Partida - varchar
		    @Cod_UbigeoLlegada, -- Cod_UbigeoLlegada - varchar
		    @Direccion_LLegada, -- Direccion_LLegada - varchar
		    @Documentos_Relacionados, -- Documentos_Relacionados - varchar
		    @Flag_Transbordo, -- Flag_Transbordo - bit
		    @Peso_Bruto, -- Peso_Bruto - numeric
		    @Id_ClienteTransportistaPublico, -- Id_ClienteTransportistaPublico - int
		    @Num_PlacaTransportePrivado, -- Num_PlacaTransportePrivado - varchar
		    @Conductor_TransportePrivado, -- Conductor_TransportePrivado - varchar
		    @Obs_Transportista, -- Obs_Transportista - varchar
		    @Nro_Contenedor, -- Nro_Contenedor - varchar
		    @Cod_Puerto, -- Cod_Puerto - varchar
		    @Nro_Bulltos, -- Nro_Bulltos - int
		    @Certificado_Inscripcion, -- Certificado_Inscripcion - varchar
		    @Certificado_Habilitacion, -- Certificado_Habilitacion - varchar
		    @Cod_EstadoGuia, -- Cod_EstadoGuia - varchar
		    @Obs_GuiaRemisionRemitente, -- Obs_GuiaRemisionRemitente - varchar
		    @Id_GuiaRemisionRemitenteBaja, -- Id_GuiaRemisionRemitenteBaja - int
		    @Flag_Anulado, -- Flag_Anulado - bit
		    @Cod_Usuario, -- Cod_UsuarioReg - varchar
		    GETDATE(), -- Fecha_Reg - datetime
		    NULL, -- Cod_UsuarioAct - varchar
		    NULL -- Fecha_Act - datetime
		)
		SET @Id_GuiaRemisionRemitente = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE
		SET
			--Id_GuiaRemisionRemitente - this column value is auto-generated
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Caja = @Cod_Caja, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Turno = @Cod_Turno, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_TipoComprobante = @Cod_TipoComprobante, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Libro = @Cod_Libro, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Serie = @Serie, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Numero = @Numero, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Emision = @Fecha_Emision, -- datetime
			dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_TrasladoBienes = @Fecha_TrasladoBienes, -- datetime
			dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_EntregaBienes = @Fecha_EntregaBienes, -- datetime
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_MotivoTraslado = @Cod_MotivoTraslado, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_ModalidadTraslado = @Cod_ModalidadTraslado, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UnidadMedida = @Cod_UnidadMedida, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Id_ClienteDestinatario = @Id_ClienteDestinatario, -- int
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoPartida = @Cod_UbigeoPartida, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_Partida = @Direccion_Partida, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoLlegada = @Cod_UbigeoLlegada, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_LLegada = @Direccion_LLegada, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Documentos_Relacionados = @Documentos_Relacionados, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Transbordo = @Flag_Transbordo, -- bit
			dbo.CAJ_GUIA_REMISION_REMITENTE.Peso_Bruto = @Peso_Bruto, -- numeric
			dbo.CAJ_GUIA_REMISION_REMITENTE.Id_ClienteTransportistaPublico = @Id_ClienteTransportistaPublico, -- int
			dbo.CAJ_GUIA_REMISION_REMITENTE.Num_PlacaTransportePrivado = @Num_PlacaTransportePrivado, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Conductor_TransportePrivado = @Conductor_TransportePrivado, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Obs_Transportista = @Obs_Transportista, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Contenedor = @Nro_Contenedor, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Puerto = @Cod_Puerto, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Bulltos = @Nro_Bulltos, -- int
			dbo.CAJ_GUIA_REMISION_REMITENTE.Certificado_Inscripcion = @Certificado_Inscripcion, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Certificado_Habilitacion = @Certificado_Habilitacion, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_EstadoGuia = @Cod_EstadoGuia, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Obs_GuiaRemisionRemitente = @Obs_GuiaRemisionRemitente, -- varchar
			dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitenteBaja = @Id_GuiaRemisionRemitenteBaja, -- int
			dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Anulado = @Flag_Anulado, -- bit
			dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UsuarioAct = @Cod_Usuario, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Act = GETDATE() -- datetime
		WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
	END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_E' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_E
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_E
	@Id_GuiaRemisionRemitente int,
	@Cod_Usuario varchar(32),
	@Justificacion varchar(max)
WITH ENCRYPTION
AS
BEGIN
	SET XACT_ABORT ON;  
	BEGIN TRY  
		BEGIN TRANSACTION;
		--Verificar que no existan un iyem superior 
		IF EXISTS(SELECT cgrr.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr WHERE cgrr.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND cgrr.Cod_EstadoGuia NOT IN ('INI','EMI')
			AND cgrr.Cod_Libro='14')
		BEGIN
			RAISERROR('No se puede Eliminar Dicho comprombprobante porque ya fue notificado a SUNAT',16,1)
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT cgrr.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr WHERE cgrr.Cod_Libro='14' AND cgrr.Cod_TipoComprobante+cgrr.Serie=
			(SELECT cgrr2.Cod_TipoComprobante+cgrr2.Serie FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr2 WHERE cgrr2.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
			AND cgrr2.Cod_Libro='14') AND cgrr.Numero>(SELECT CONVERT(bigint,cgrr2.Numero) FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr2 WHERE cgrr2.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
			AND cgrr2.Cod_Libro='14'))
			BEGIN
				RAISERROR('No se puede Eliminar Dicho Comprobante porque existe un Numero Superior que lo precede.',16,1)
			END
			ELSE
			BEGIN
				--Variables para almacenar en la vista
				DECLARE @Documento varchar(max)
				DECLARE @Cliente varchar(max)
				DECLARE @Fecha_Emision datetime
				SELECT @Documento=cgrr.Cod_Libro+'|'+cgrr.Cod_TipoComprobante+':'+ cgrr.Serie+'-'+cgrr.Numero+'|'+cgrr.Cod_UnidadMedida,
					   @Cliente = CONVERT(varchar,cgrr.Id_ClienteDestinatario)+'|'+cgrr.Direccion_Partida+'|'+cgrr.Direccion_LLegada,
					   @Fecha_Emision=cgrr.Fecha_Emision
					   FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr WHERE cgrr.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente

				DECLARE @Detalles varchar(max) = STUFF((SELECT ';'+ CONCAT( CONVERT(varchar(32),cgrrd.Id_Producto),'|', CONVERT(varchar(54),cgrrd.Cantidad),'|', cgrrd.Descripcion) 
														FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
														WHERE cgrrd.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
													   FOR
														 XML PATH('')
													   ), 1, 2, '') + ''
				--Eliminamos los detalles
				DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
				--Eliminamnos la cabezera
				DELETE dbo.CAJ_GUIA_REMISION_REMITENTE WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
				--Guardamos el comprobante en la vista eliminados
				DECLARE @id_Fila int = (SELECT ISNULL(COUNT(*)/9,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '079')
				DECLARE @Fecha_Actual datetime =GETDATE()
				EXEC USP_PAR_FILA_G '079','001',@id_Fila,@Documento,NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','002',@id_Fila,'CAJ_GUIA_REMISION_REMITENTE',NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','003',@id_Fila,@Cliente,NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','004',@id_Fila,@Detalles,NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','005',@id_Fila,NULL,NULL,NULL,@Fecha_Emision,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','006',@id_Fila,NULL,NULL,NULL,@Fecha_Actual,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','007',@id_Fila,@Cod_Usuario,NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','008',@id_Fila,@Justificacion,NULL,NULL,NULL,NULL,1,'MIGRACION';
				EXEC USP_PAR_FILA_G '079','009',@id_Fila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';	
			END
		END
		COMMIT TRANSACTION;
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage NVARCHAR(4000);  
		SELECT  @ErrorMessage = ERROR_MESSAGE() 
		RAISERROR(@ErrorMessage,16,1)
		IF (XACT_STATE()) = -1  
		BEGIN  
			ROLLBACK TRANSACTION; 
		END;  
		IF (XACT_STATE()) = 1  
		BEGIN  
			COMMIT TRANSACTION;    
		END;  
		THROW;
	END CATCH;   
	IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_G
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_G
	@Id_GuiaRemisionRemitente int,
	@Id_Detalle int,
	@Cod_Almacen varchar(32),
	@Cod_UnidadMedida varchar(5),
	@Id_Producto int,
	@Cantidad numeric(38,10),
	@Descripcion varchar(max),
	@Peso numeric(38,6),
	@Obs_Detalle varchar(max),
	@Cod_ProductoSunat varchar(32),
	@Cod_USuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
	IF @Id_Producto = 0 
	BEGIN
		SET @Id_Producto = NULL
	END 
	IF @Id_Detalle = 0 
	BEGIN
		SET @Id_Detalle = (SELECT ISNULL(MAX(cgrrd.Id_Detalle),0) + 1 
		FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd 
		WHERE cgrrd.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente)
	END 
	IF NOT EXISTS (SELECT cgrrd.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd WHERE cgrrd.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND cgrrd.Id_Detalle=@Id_Detalle)
	BEGIN
		INSERT dbo.CAJ_GUIA_REMISION_REMITENTE_D
		VALUES
		(
		    @Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
		    @Id_Detalle, -- Id_Detalle - int
		    @Cod_Almacen, -- Cod_Almacen - varchar
		    @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
		    @Id_Producto, -- Id_Producto - int
		    @Cantidad, -- Cantidad - numeric
		    @Descripcion, -- Descripcion - varchar
		    @Peso, -- Peso - numeric
		    @Obs_Detalle, -- Obs_Detalle - varchar
		    @Cod_ProductoSunat, -- Cod_ProductoSunat - varchar
		    @Cod_USuario, -- Cod_UsuarioReg - varchar
		    GETDATE(), -- Fecha_Reg - datetime
		    NULL, -- Cod_UsuarioAct - varchar
		    NULL -- Fecha_Act - datetime
		)
	END
	ELSE
	BEGIN
		UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_D
		SET
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_Almacen = @Cod_Almacen, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UnidadMedida = @Cod_UnidadMedida, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Producto = @Id_Producto, -- int
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cantidad = @Cantidad, -- numeric
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Descripcion = @Descripcion, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Peso = @Peso, -- numeric
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Obs_Detalle = @Obs_Detalle, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_ProductoSunat = @Cod_ProductoSunat, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UsuarioAct = @Cod_USuario, -- varchar
		    dbo.CAJ_GUIA_REMISION_REMITENTE_D.Fecha_Act = GETDATE() -- datetime
		WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle=@Id_Detalle
	END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_E' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_E
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_E
	@Id_GuiaRemisionRemitente int,
	@Id_Detalle int
WITH ENCRYPTION
AS
BEGIN
	--Eliminamos el detalle
	DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D 
	WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle=@Id_Detalle
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TT' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TT
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrr.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TT' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TT
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrrd.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrrr.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACION cgrrr
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TXPK' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXPK
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXPK
	@Id_GuiaRemisionRemitente int
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrr.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr WHERE cgrr.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK
	@Id_GuiaRemisionRemitente int,
	@Id_Detalle int
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrrd.* FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd 
	WHERE cgrrd.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND cgrrd.Id_Detalle=@Id_Detalle
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA
	@Id_GuiaRemisionRemitente int
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrr.Cod_UsuarioReg, cgrr.Fecha_Reg, cgrr.Cod_UsuarioAct, cgrr.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr WHERE cgrr.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA
	@Id_GuiaRemisionRemitente int,
	@Id_Detalle int
WITH ENCRYPTION
AS
BEGIN
	SELECT cgrrd.Cod_UsuarioReg, cgrrd.Fecha_Reg, cgrrd.Cod_UsuarioAct, cgrrd.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd 
	WHERE cgrrd.Id_GuiaRemisionRemitente=@Id_GuiaRemisionRemitente AND cgrrd.Id_Detalle=@Id_Detalle
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TNF' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TNF
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TNF
	@ScripWhere varchar(max)
WITH ENCRYPTION
AS
BEGIN
	EXECUTE('SELECT cgrr.Cod_UsuarioReg, cgrr.Fecha_Reg, cgrr.Cod_UsuarioAct, cgrr.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr '+@ScripWhere)
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF
GO

CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF
	@ScripWhere varchar(max)
WITH ENCRYPTION
AS
BEGIN
	EXECUTE('SELECT cgrrd.Cod_UsuarioReg, cgrrd.Fecha_Reg, cgrrd.Cod_UsuarioAct, cgrrd.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd '+@ScripWhere)
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TXPK' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK
GO

CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK
	@IdGuiaRemisionRemitente int
WITH ENCRYPTION
AS
BEGIN
	SELECT 
	@IdGuiaRemisionRemitente,
	cgrr.Cod_TipoComprobante,
	vtc.Nom_TipoComprobante,
	cgrr.Serie,	
	cgrr.Numero,
	cgrr.Fecha_Emision, 
	cgrr.Fecha_TrasladoBienes, 
	cgrr.Fecha_EntregaBienes,
	cgrr.Direccion_Partida, 
	cgrr.Direccion_LLegada,
	cgrrd.Id_Detalle, 
	cgrrd.Cod_Almacen, 
	cgrrd.Cod_UnidadMedida, 
	cgrrd.Id_Producto, 
	cgrrd.Cantidad, 
	cgrrd.Descripcion, 
	cgrrd.Peso, 
	cgrrd.Obs_Detalle, 
	cgrr.Cod_MotivoTraslado,
	CASE WHEN cgrr.Cod_MotivoTraslado = '01' THEN 'VENTA' 
	 WHEN cgrr.Cod_MotivoTraslado = '14' THEN 'VENTA SUJETA A CONFIRMACION DEL COMPRADOR' 
	 WHEN cgrr.Cod_MotivoTraslado = '02' THEN 'COMPRA' 
	 WHEN cgrr.Cod_MotivoTraslado = '04' THEN 'TRASLADO ENTRE ESTABLECIMIENTOS DE LA MISMA EMPRESA' 
	 WHEN cgrr.Cod_MotivoTraslado = '18' THEN 'TRASLADO EMISOR ITINERANTE CP' 
	 WHEN cgrr.Cod_MotivoTraslado = '08' THEN 'IMPORTACION' 
	 WHEN cgrr.Cod_MotivoTraslado = '09' THEN 'EXPORTACION' 
	 WHEN cgrr.Cod_MotivoTraslado = '19' THEN 'TRASLADO A ZONA PRIMARIA'
	ELSE 'OTROS' END Nom_MotivoTraslado,
	cgrr.Flag_Anulado,
	cgrr.Id_ClienteTransportistaPublico,
	cgrr.Num_PlacaTransportePrivado
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd ON cgrr.Id_GuiaRemisionRemitente = cgrrd.Id_GuiaRemisionRemitente
	INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
	WHERE cgrr.Id_GuiaRemisionRemitente=@IdGuiaRemisionRemitente
END
GO

-- USP_CAJ_COMPROBANTE_RELACION_TXIdComprobante 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante
@id_ComprobantePago as int
WITH ENCRYPTION
AS
BEGIN
SET DATEFORMAT dmy;
	SELECT DISTINCT vtc.Cod_Sunat Cod_TipoComprobante,cgrr.Serie+'-'+cgrr.Numero Comprobante
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACION cgrrr INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE cgrr ON cgrrr.Id_GuiaRemisionRemitente = cgrr.Id_GuiaRemisionRemitente
	INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
	WHERE cgrrr.Cod_TipoRelacion = 'GRR' AND cgrrr.Id_ComprobantePago = @id_ComprobantePago
END
GO