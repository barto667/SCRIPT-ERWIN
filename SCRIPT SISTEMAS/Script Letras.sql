EXEC dbo.USP_PAR_TABLA_G @Cod_Tabla = '127',@Tabla = 'LETRAS_CAMBIO',@Des_Tabla = 'Almacena las letras giradas para Compras y Ventas',@Cod_Sistema = '001',@Flag_Acceso = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '001',@Columna = 'Id_Letra',@Des_Columna = 'Id numerico de la letra',@Tipo = 'ENTERO',@Flag_NULL = 0,@Tamano = 64,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '002',@Columna = 'Nro_Letra',@Des_Columna = 'Nro de Letra Girada',@Tipo = 'ENTERO',@Flag_NULL = 0,@Tamano = 128,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '003',@Columna = 'Cod_Libro',@Des_Columna = 'Cod. libro de la letra : 14 venta-08 compra',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '004',@Columna = 'Ref_Girador',@Des_Columna = 'Documento al que hace Referencia',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 1024,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '005',@Columna = 'Fecha_Girado',@Des_Columna = 'Fecha de emision de la Letra',@Tipo = 'FECHAHORA',@Flag_NULL = 0,@Tamano = 0,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '006',@Columna = 'Fecha_Vencimiento',@Des_Columna = 'Fecha de vencimiento de la Letra',@Tipo = 'FECHAHORA',@Flag_NULL = 0,@Tamano = 0,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '007',@Columna = 'Fecha_Pago',@Des_Columna = 'Fecha de pago de la Letra',@Tipo = 'FECHAHORA',@Flag_NULL = 0,@Tamano = 0,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '008',@Columna = 'Cod_Cuenta',@Des_Columna = 'Cod. cuenta de la letra asociada',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 128,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '009',@Columna = 'Nro_Operacion',@Des_Columna = 'Nro. de operacion de la letra asociada',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 128,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '010',@Columna = 'Cod_Moneda',@Des_Columna = 'Cod. moneda de la letra',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '011',@Columna = 'Id_Comprobante',@Des_Columna = 'ID del comprobante al cual afecta dicha letra',@Tipo = 'ENTERO',@Flag_NULL = 0,@Tamano = 64,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '012',@Columna = 'Cod_Estado',@Des_Columna = 'Estados de la Letra: GIRADO, VENCIDO, PAGADO, ANULADO',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 64,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '013',@Columna = 'Nro_Referencia',@Des_Columna = 'Nro de Referencia del Pago',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 128,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '014',@Columna = 'Monto_Base',@Des_Columna = 'Monto base de la letra',@Tipo = 'NUMERO',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '015',@Columna = 'Monto_Real',@Des_Columna = 'Monto real cancelado de la letra',@Tipo = 'NUMERO',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '016',@Columna = 'Observaciones',@Des_Columna = 'Observaciones adicionales de la letra',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 1024,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '017',@Columna = 'Cod_UsuarioReg',@Des_Columna = 'Codigo de usuario registrado',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '018',@Columna = 'Fecha_Reg',@Des_Columna = 'Fecha de registro',@Tipo = 'FECHAHORA',@Flag_NULL = 0,@Tamano = 0,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '019',@Columna = 'Cod_UsuarioAct',@Des_Columna = 'Codigo de usuario actualziacion',@Tipo = 'CADENA',@Flag_NULL = 1,@Tamano = 32,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '020',@Columna = 'Fecha_Act',@Des_Columna = 'Fecha de actualizacion',@Tipo = 'FECHAHORA',@Flag_NULL = 1,@Tamano = 0,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127',@Cod_Columna = '021',@Columna = 'Estado',@Des_Columna = 'Estado',@Tipo = 'BOLEANO',@Flag_NULL = 0,@Tamano = 64,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS @Cod_Tabla = '127'


GO 

EXEC dbo.USP_PAR_TABLA_G @Cod_Tabla = '128',@Tabla = 'ESTADOS_LETRA',@Des_Tabla = 'Almacena los estados de las letras',@Cod_Sistema = '001',@Flag_Acceso = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128',@Cod_Columna = '001',@Columna = 'Cod_Estado',@Des_Columna = 'Codigo del estado de la letra',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 32,@Predeterminado = '',@Flag_PK = 1,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128',@Cod_Columna = '002',@Columna = 'Des_Estado',@Des_Columna = 'Descripcion del estado de la letra',@Tipo = 'CADENA',@Flag_NULL = 0,@Tamano = 1024,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128',@Cod_Columna = '003',@Columna = 'Estado',@Des_Columna = 'Estado',@Tipo = 'BOLEANO',@Flag_NULL = 0,@Tamano = 64,@Predeterminado = '',@Flag_PK = 0,@Cod_Usuario = 'MIGRACION'
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS @Cod_Tabla = '128' 

GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda @Cod_Sucursal VARCHAR(32),
                                                                    @Cod_Moneda   VARCHAR(5)
WITH ENCRYPTION
AS
     BEGIN
         SELECT bcb.Cod_CuentaBancaria,
                bcb.Cod_EntidadFinanciera,
                bcb.Des_CuentaBancaria,
                bcb.Saldo_Disponible,
                bcb.Cod_CuentaContable,
                bcb.Cod_TipoCuentaBancaria
         FROM dbo.BAN_CUENTA_BANCARIA bcb
         WHERE bcb.Cod_Moneda = @Cod_Moneda
               AND bcb.Cod_Sucursal = @Cod_Sucursal;
     END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_LETRAS_CAMBIO_TraerXCodLibroCodMonedaCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_LETRAS_CAMBIO_TraerXCodLibroCodMonedaCodCuenta;
GO
CREATE PROCEDURE USP_VIS_LETRAS_CAMBIO_TraerXCodLibroCodMonedaCodCuenta @Cod_Libro  VARCHAR(32),
                                                                        @Cod_Moneda VARCHAR(32),
                                                                        @Cod_Cuenta VARCHAR(128)
WITH ENCRYPTION
AS
     BEGIN
         SELECT DISTINCT vlc.Id_Letra,
                vlc.Nro_Letra,
                vlc.Cod_Libro,
                vlc.Ref_Girador,
                vlc.Fecha_Girado,
                vlc.Fecha_Vencimiento,
                vlc.Fecha_Pago,
                vlc.Cod_Cuenta,
                vlc.Nro_Operacion,
                vlc.Cod_Moneda,
                vlc.Id_Comprobante,
                vlc.Cod_Estado,
                vlc.Nro_Referencia,
                CAST(vlc.Monto_Base AS numeric(38,2)) Monto_Base,
                CAST(vlc.Monto_Real AS numeric(38,2)) Monto_Real,
                vlc.Observaciones,
				vlc.Cod_UsuarioReg, 
				vlc.Fecha_Reg, 
				vlc.Cod_UsuarioAct, 
				vlc.Fecha_Act,
                vlc.Estado
         FROM dbo.VIS_LETRAS_CAMBIO vlc
         WHERE vlc.Cod_Libro = @Cod_Libro
               AND vlc.Cod_Moneda = @Cod_Moneda
               AND vlc.Cod_Cuenta = @Cod_Cuenta;
     END;
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda
	@NumeroDocumento	varchar(32),
	@CodLibro	varchar(4),
	@CodMoneda varchar(5)
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
		WHERE ccp.Doc_Cliente=@NumeroDocumento AND ccp.Cod_Libro=@CodLibro  AND ccp.Cod_Moneda=@CodMoneda
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
		WHERE ccp.Doc_Cliente=@NumeroDocumento AND ccp.Cod_Moneda=@CodMoneda
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END

END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda 
	@NombreCliente	varchar(250),
	@CodLibro	varchar(4),
	@CodMoneda varchar(5)
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
		WHERE ccp.Nom_Cliente like '%'+@NombreCliente+'%' AND ccp.Cod_Libro=@CodLibro  AND ccp.Cod_Moneda=@CodMoneda
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
		WHERE ccp.Nom_Cliente like '%'+@NombreCliente+'%'   AND ccp.Cod_Moneda=@CodMoneda
		ORDER BY convert(datetime,convert(date,ccp.FechaEmision)) DESC
	END
END
go




IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_LETRAS_CAMBIO_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_LETRAS_CAMBIO_G
GO

CREATE PROCEDURE USP_VIS_LETRAS_CAMBIO_G
    @Id_Letra int, --PK 0 si no se sabe
    @Nro_Letra varchar(128),  --PK  opcional, si es '' o NULL se genera uno nuevo
    @Cod_Libro varchar(32), --PK Obligatorio
    @Ref_Girador varchar(1024),
	@Fecha_Girado datetime,
	@Fecha_Vencimiento datetime,
	@Fecha_Pago datetime,
	@Cod_Cuenta varchar(128), --PK Obligatorio
	@Nro_Operacion varchar(128),
	@Cod_Moneda varchar(32), --PK Obligatorio
	@Id_Comprobante int, 
	@Cod_Estado varchar(64),
	@Nro_Referencia varchar(128),
	@Monto_Base numeric(38,2),
	@Monto_Real numeric(38,2),
	@Observaciones varchar(1024),
	@Cod_Usuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Fecha_Actual datetime
	DECLARE @id_Fila int
	IF	@Id_Letra = 0 
	BEGIN
		--Determinamos el id de letra como el max + 1 de todos
		SET @Id_Letra = (SELECT ISNULL(MAX(vlc.Id_Letra),0)+1  FROM dbo.VIS_LETRAS_CAMBIO vlc)
	END 
	--Procedemos a guardar
	IF @Nro_Letra = '' OR @Nro_Letra IS NULL
	BEGIN
		--Obtenemos la letra en base a la moneda,libro y cuenta
		SET @Nro_Letra = (SELECT CAST((ISNULL(MAX(CAST(vlc.Nro_Letra AS bigint)),0) + 1) AS varchar(128)) FROM dbo.VIS_LETRAS_CAMBIO vlc 
		WHERE vlc.Cod_Moneda=@Cod_Moneda AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta=@Cod_Cuenta)
		--Guardamos
		SET @id_Fila = (SELECT ISNULL(COUNT(*)/21,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '127')
		SET @Fecha_Actual = GETDATE()
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '001',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Letra,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '002',@Cod_Fila = @id_Fila,@Cadena = @Nro_Letra,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '003',@Cod_Fila = @id_Fila,@Cadena = @Cod_Libro,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '004',@Cod_Fila = @id_Fila,@Cadena = @Ref_Girador,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '005',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Girado,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '006',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Vencimiento,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '007',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Pago,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '008',@Cod_Fila = @id_Fila,@Cadena = @Cod_Cuenta,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '009',@Cod_Fila = @id_Fila,@Cadena = @Nro_Operacion,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '010',@Cod_Fila = @id_Fila,@Cadena = @Cod_Moneda,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '011',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Comprobante,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '012',@Cod_Fila = @id_Fila,@Cadena = @Cod_Estado,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '013',@Cod_Fila = @id_Fila,@Cadena = @Nro_Referencia,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '014',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Base,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '015',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Real,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '016',@Cod_Fila = @id_Fila,@Cadena = @Observaciones,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '017',@Cod_Fila = @id_Fila,@Cadena = @Cod_Usuario,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '018',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Actual,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '019',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '020',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '021',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = 1,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
	END
	ELSE
	BEGIN
		--Significa que se desea guardar o actualizar
		IF NOT EXISTS (SELECT vlc.* FROM dbo.VIS_LETRAS_CAMBIO vlc 
		WHERE vlc.Id_Letra = @Id_Letra AND vlc.Nro_Letra = @Nro_Letra AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta = @Cod_Cuenta AND vlc.Cod_Moneda = @Cod_Moneda )
		BEGIN
			--Insertar
			SET @id_Fila = (SELECT ISNULL(COUNT(*)/21,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '127')
			SET @Fecha_Actual = GETDATE()
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '001',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Letra,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '002',@Cod_Fila = @id_Fila,@Cadena = @Nro_Letra,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '003',@Cod_Fila = @id_Fila,@Cadena = @Cod_Libro,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '004',@Cod_Fila = @id_Fila,@Cadena = @Ref_Girador,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '005',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Girado,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '006',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Vencimiento,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '007',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Pago,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '008',@Cod_Fila = @id_Fila,@Cadena = @Cod_Cuenta,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '009',@Cod_Fila = @id_Fila,@Cadena = @Nro_Operacion,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '010',@Cod_Fila = @id_Fila,@Cadena = @Cod_Moneda,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '011',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Comprobante,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '012',@Cod_Fila = @id_Fila,@Cadena = @Cod_Estado,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '013',@Cod_Fila = @id_Fila,@Cadena = @Nro_Referencia,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '014',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Base,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '015',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Real,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '016',@Cod_Fila = @id_Fila,@Cadena = @Observaciones,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '017',@Cod_Fila = @id_Fila,@Cadena = @Cod_Usuario,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '018',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Actual,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '019',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '020',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '021',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = 1,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
		END
		ELSE
		BEGIN
			--Actualizar
			SET @id_Fila = (SELECT vlc.Nro FROM dbo.VIS_LETRAS_CAMBIO vlc 
			WHERE vlc.Id_Letra = @Id_Letra AND vlc.Nro_Letra = @Nro_Letra AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta = @Cod_Cuenta AND vlc.Cod_Moneda = @Cod_Moneda )
			SET @Fecha_Actual = GETDATE()
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '001',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Letra,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '002',@Cod_Fila = @id_Fila,@Cadena = @Nro_Letra,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '003',@Cod_Fila = @id_Fila,@Cadena = @Cod_Libro,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '004',@Cod_Fila = @id_Fila,@Cadena = @Ref_Girador,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '005',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Girado,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '006',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Vencimiento,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '007',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Pago,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '008',@Cod_Fila = @id_Fila,@Cadena = @Cod_Cuenta,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '009',@Cod_Fila = @id_Fila,@Cadena = @Nro_Operacion,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '010',@Cod_Fila = @id_Fila,@Cadena = @Cod_Moneda,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '011',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = @Id_Comprobante,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '012',@Cod_Fila = @id_Fila,@Cadena = @Cod_Estado,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '013',@Cod_Fila = @id_Fila,@Cadena = @Nro_Referencia,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '014',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Base,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '015',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = @Monto_Real,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '016',@Cod_Fila = @id_Fila,@Cadena = @Observaciones,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '019',@Cod_Fila = @id_Fila,@Cadena = @Cod_Usuario,@Numero = NULL,@Entero = NULL,@FechaHora = NULL,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127',@Cod_Columna = '020',@Cod_Fila = @id_Fila,@Cadena = NULL,@Numero = NULL,@Entero = NULL,@FechaHora = @Fecha_Actual,@Boleano = NULL,@Flag_Creacion = 1,@Cod_Usuario = @Cod_Usuario
			
		END
	END
	SELECT 
	@Id_Letra Id_Letra,
    @Nro_Letra Nro_Letra,
    @Cod_Libro Cod_Libro,
    @Ref_Girador Ref_Girador,
	@Fecha_Girado Fecha_Girado,
	@Fecha_Vencimiento Fecha_Vencimiento,
	@Fecha_Pago Fecha_Pago,
	@Cod_Cuenta Cod_Cuenta,
	@Nro_Operacion Nro_Operacion,
	@Cod_Moneda Cod_Moneda,
	@Id_Comprobante Id_Comprobante, 
	@Cod_Estado Cod_Estado,
	@Nro_Referencia Nro_Referencia,
	@Monto_Base Monto_Base,
	@Monto_Real Monto_Real,
	@Observaciones Observaciones
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_LETRAS_CAMBIO_GuardarRelacion' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_LETRAS_CAMBIO_GuardarRelacion
GO

CREATE PROCEDURE USP_VIS_LETRAS_CAMBIO_GuardarRelacion
	@Id_Comprobante int,
	@Item int,
	@Id_Referencia int,
	@Valor numeric(38,6),
	@Cod_Usuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Id_Detalle int =(SELECT TOP 1 ccd.id_Detalle FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_Comprobante)
	INSERT dbo.CAJ_COMPROBANTE_RELACION
	VALUES
	(
	    @Id_Comprobante, -- id_ComprobantePago - int
	    @Id_Detalle, -- id_Detalle - int
	    @Item, -- Item - int
	    @Id_Referencia, -- Id_ComprobanteRelacion - int
	    'LET', -- Cod_TipoRelacion - varchar
	    @Valor, -- Valor - numeric
	    '', -- Obs_Relacion - varchar
	    1, -- Id_DetalleRelacion - int
	    @Cod_Usuario, -- Cod_UsuarioReg - varchar
	    GETDATE(), -- Fecha_Reg - datetime
	    NULL, -- Cod_UsuarioAct - varchar
	    NULL -- Fecha_Act - datetime
	)
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_VIS_LETRAS_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta
GO

CREATE PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta
	@Id_Letra int,
	@Cod_Moneda varchar(32),
	@Cod_Libro varchar(32),
	@Cod_Cuenta varchar(128)
WITH ENCRYPTION
AS
BEGIN
	SELECT vlc.Nro, vlc.Id_Letra, vlc.Nro_Letra, vlc.Cod_Libro, vlc.Ref_Girador, vlc.Fecha_Girado, vlc.Fecha_Vencimiento, 
	vlc.Fecha_Pago, vlc.Cod_Cuenta,bcb.Des_CuentaBancaria, vlc.Nro_Operacion, vlc.Cod_Moneda,vm.Nom_Moneda, vlc.Id_Comprobante, vlc.Cod_Estado, vlc.Nro_Referencia, 
	CAST(vlc.Monto_Base AS numeric(38,2)), CAST(vlc.Monto_Real AS numeric(38,2)),dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Base AS numeric(38,2))) Letra_MontoBase,dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Real AS numeric(38,2))) Letra_MontoReal, vlc.Observaciones, vlc.Estado 
	FROM dbo.VIS_LETRAS_CAMBIO vlc
	INNER JOIN dbo.VIS_MONEDAS vm ON vlc.Cod_Moneda = vm.Cod_Moneda
	INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON bcb.Cod_CuentaBancaria=vlc.Cod_Cuenta
	WHERE vlc.Id_Letra=@Id_Letra AND vlc.Cod_Moneda=@Cod_Moneda AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta=@Cod_Cuenta
END
GO
-- IF EXISTS (
--   SELECT * 
--     FROM sysobjects 
--    WHERE name = N'URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta' 
-- 	 AND type = 'P'
-- )
--   DROP PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta
-- GO

-- CREATE PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta
-- 	@Id_Letra int,
-- 	@Nro_Letra varchar(128),
-- 	@Cod_Moneda varchar(32),
-- 	@Cod_Libro varchar(32),
-- 	@Cod_Cuenta varchar(128)
-- WITH ENCRYPTION
-- AS
-- BEGIN
-- 	SELECT vlc.Nro, vlc.Id_Letra, vlc.Nro_Letra, vlc.Cod_Libro, vlc.Ref_Girador, vlc.Fecha_Girado, vlc.Fecha_Vencimiento, 
-- 	vlc.Fecha_Pago, vlc.Cod_Cuenta, vlc.Nro_Operacion, vlc.Cod_Moneda, vlc.Id_Comprobante, vlc.Cod_Estado, vlc.Nro_Referencia, 
-- 	vlc.Monto_Base, vlc.Monto_Real, vlc.Observaciones, vlc.Estado 
-- 	FROM dbo.VIS_LETRAS_CAMBIO vlc
-- 	WHERE vlc.Id_Letra=@Id_Letra AND vlc.Nro_Letra=@Nro_Letra AND vlc.Cod_Moneda=@Cod_Moneda AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta=@Cod_Cuenta
-- END
-- GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_VIS_LETRAS_TraerLetrasXCodMonedaCodLibroCodCuenta' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_VIS_LETRAS_TraerLetrasXCodMonedaCodLibroCodCuenta
GO

CREATE PROCEDURE URP_VIS_LETRAS_TraerLetrasXCodMonedaCodLibroCodCuenta
	@Cod_Moneda varchar(32),
	@Cod_Libro varchar(32),
	@Cod_Cuenta varchar(128)
WITH ENCRYPTION
AS
BEGIN
	SELECT vlc.Nro, vlc.Id_Letra, vlc.Nro_Letra, vlc.Cod_Libro, vlc.Ref_Girador, vlc.Fecha_Girado, vlc.Fecha_Vencimiento, 
	vlc.Fecha_Pago, vlc.Cod_Cuenta,bcb.Des_CuentaBancaria, vlc.Nro_Operacion, vlc.Cod_Moneda,vm.Nom_Moneda, vlc.Id_Comprobante, vlc.Cod_Estado, vlc.Nro_Referencia, 
	CAST(vlc.Monto_Base AS numeric(38,2)), CAST(vlc.Monto_Real AS numeric(38,2)),dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Base AS numeric(38,2))) Letra_MontoBase,dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Real AS numeric(38,2))) Letra_MontoReal, vlc.Observaciones, vlc.Estado 
	FROM dbo.VIS_LETRAS_CAMBIO vlc 
	INNER JOIN dbo.VIS_MONEDAS vm ON vlc.Cod_Moneda = vm.Cod_Moneda
	INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON bcb.Cod_CuentaBancaria=vlc.Cod_Cuenta
	WHERE vlc.Cod_Moneda=@Cod_Moneda AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta=@Cod_Cuenta
END
GO

 IF EXISTS (
   SELECT * 
     FROM sysobjects 
    WHERE name = N'URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta' 
 	 AND type = 'P'
 )
   DROP PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta
 GO

 CREATE PROCEDURE URP_VIS_LETRAS_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta
 	@Id_Letra int,
 	@Nro_Letra varchar(128),
 	@Cod_Moneda varchar(32),
 	@Cod_Libro varchar(32),
 	@Cod_Cuenta varchar(128)
 WITH ENCRYPTION
 AS
 BEGIN
 	SELECT vlc.Nro, vlc.Id_Letra, vlc.Nro_Letra, vlc.Cod_Libro, vlc.Ref_Girador, vlc.Fecha_Girado, vlc.Fecha_Vencimiento, 
	vlc.Fecha_Pago, vlc.Cod_Cuenta,bcb.Des_CuentaBancaria, vlc.Nro_Operacion, vlc.Cod_Moneda,vm.Nom_Moneda, vlc.Id_Comprobante, vlc.Cod_Estado, vlc.Nro_Referencia, 
	CAST(vlc.Monto_Base AS numeric(38,2)) Monto_Base, CAST(vlc.Monto_Real AS numeric(38,2)) Monto_Real,dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Base AS numeric(38,2))) Letra_MontoBase,dbo.UFN_ConvertirNumeroLetra(CAST(vlc.Monto_Real AS numeric(38,2))) Letra_MontoReal, vlc.Observaciones,
	pcp.Cliente,ccp.Direccion_Cliente,pcp.Nro_Documento,pcp.Telefono1,pcp.Telefono2,
	vlc.Estado 
 	FROM dbo.VIS_LETRAS_CAMBIO vlc
	INNER JOIN dbo.VIS_MONEDAS vm ON vlc.Cod_Moneda = vm.Cod_Moneda
	INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON bcb.Cod_CuentaBancaria=vlc.Cod_Cuenta
	INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON vlc.Id_Comprobante = ccp.id_ComprobantePago 
	INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
 	WHERE vlc.Id_Letra=@Id_Letra AND vlc.Nro_Letra=@Nro_Letra AND vlc.Cod_Moneda=@Cod_Moneda AND vlc.Cod_Libro=@Cod_Libro AND vlc.Cod_Cuenta=@Cod_Cuenta
 END
 GO