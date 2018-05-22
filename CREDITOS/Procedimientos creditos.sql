--Eliminar tablas
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'CUE_CLIENTE_CUENTA_M' 
	  AND 	 type = 'U')
    DROP TABLE CUE_CLIENTE_CUENTA_M
GO

IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'CUE_CLIENTE_CUENTA_D' 
	  AND 	 type = 'U')
    DROP TABLE CUE_CLIENTE_CUENTA_D
GO

IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'CUE_CLIENTE_CUENTA' 
	  AND 	 type = 'U')
    DROP TABLE CUE_CLIENTE_CUENTA
GO

--Crear las nuevas tablas
--y modificar USPs

--CUE_CLIENTE_CUENTA
CREATE TABLE CUE_CLIENTE_CUENTA(
	[Cod_Cuenta] [varchar](32) NOT NULL,
	[Id_ClienteProveedor] [int] NOT NULL,
	[Fecha_Credito] [datetime] NOT NULL,
	[Dia_Pago] [int] NOT NULL,
	[Monto_Mora] [numeric] (38,2) NOT NULL,
	[Des_Cuenta] [varchar](512) NULL,
	[Cod_TipoCuenta] [varchar](3) NOT NULL,
	[Monto_Deposito] [numeric](38, 2) NOT NULL,
	[Interes] [numeric](38, 4)NOT NULL,
	[MesesMax] [int] NOT NULL,
	[MesesGracia] [int] NOT NULL,
	[Limite_Max] [numeric](38, 2) NULL,
	[Flag_ITF] [bit] NOT NULL,
	[Cod_Moneda] [varchar](3) NOT NULL,
	[Cod_EstadoCuenta] [varchar](3) NULL,
	[Saldo_Contable] [numeric](38, 2) NULL,
	[Saldo_Disponible] [numeric](38, 2) NULL,
	[Cod_UsuarioReg] [varchar](32) NOT NULL,
	[Fecha_Reg] [datetime] NOT NULL,
	[Cod_UsuarioAct] [varchar](32) NULL,
	[Fecha_Act] [datetime] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Cod_Cuenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[CUE_CLIENTE_CUENTA]  WITH CHECK ADD FOREIGN KEY([Id_ClienteProveedor])
REFERENCES [dbo].[PRI_CLIENTE_PROVEEDOR] ([Id_ClienteProveedor])
GO


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_G' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_G
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_G 
	@Cod_Cuenta	varchar(32), 
	@Id_ClienteProveedor	int, 
	@Fecha_Credito datetime,
	@Dia_Pago int,
	@Monto_mora numeric(38,2),
	@Des_Cuenta	varchar(512), 
	@Cod_TipoCuenta	varchar(3), 
	@Monto_Deposito	numeric(38,2), 
	@Interes	numeric(38,4), 
	@MesesMax	int, 
	@MesesGracia	int, 
	@Limite_Max	numeric(38,2), 
	@Flag_ITF	bit, 
	@Cod_Moneda	varchar(3), 
	@Cod_EstadoCuenta	varchar(3), 
	@Saldo_Contable	numeric(38,2), 
	@Saldo_Disponible	numeric(38,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Cuenta FROM CUE_CLIENTE_CUENTA WHERE  (Cod_Cuenta = @Cod_Cuenta))
	BEGIN
		INSERT INTO CUE_CLIENTE_CUENTA  VALUES (
		@Cod_Cuenta,
		@Id_ClienteProveedor,
		@Fecha_Credito,
		@Dia_Pago,
		@Monto_mora,
		@Des_Cuenta,
		@Cod_TipoCuenta,
		@Monto_Deposito,
		@Interes,
		@MesesMax,
		@MesesGracia,
		@Limite_Max,
		@Flag_ITF,
		@Cod_Moneda,
		@Cod_EstadoCuenta,
		@Saldo_Contable,
		@Saldo_Disponible,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CUE_CLIENTE_CUENTA
		SET	
			Id_ClienteProveedor = @Id_ClienteProveedor, 
			Fecha_Credito=@Fecha_Credito,
			Dia_Pago=@Dia_Pago,
			Monto_Mora=@Monto_Mora,
			Des_Cuenta = @Des_Cuenta, 
			Cod_TipoCuenta = @Cod_TipoCuenta, 
			Monto_Deposito = @Monto_Deposito, 
			Interes = @Interes, 
			MesesMax = @MesesMax, 
			MesesGracia=@MesesGracia,
			Limite_Max = @Limite_Max, 
			Flag_ITF = @Flag_ITF, 
			Cod_Moneda = @Cod_Moneda, 
			Cod_EstadoCuenta = @Cod_EstadoCuenta, 
			Saldo_Contable = @Saldo_Contable, 
			Saldo_Disponible = @Saldo_Disponible,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Cuenta = @Cod_Cuenta)	
	END
END
go

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_E' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_E
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_E 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DELETE FROM CUE_CLIENTE_CUENTA	
	WHERE (Cod_Cuenta = @Cod_Cuenta)	
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TT' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TT
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT ccc.Cod_Cuenta, ccc.Id_ClienteProveedor, ccc.Fecha_Credito, ccc.Dia_Pago, ccc.Monto_Mora, ccc.Des_Cuenta, ccc.Cod_TipoCuenta, ccc.Monto_Deposito, ccc.Interes, ccc.MesesMax,ccc.MesesGracia, ccc.Limite_Max, ccc.Flag_ITF, ccc.Cod_Moneda, ccc.Cod_EstadoCuenta, ccc.Saldo_Contable, ccc.Saldo_Disponible, ccc.Cod_UsuarioReg, ccc.Fecha_Reg, ccc.Cod_UsuarioAct, ccc.Fecha_Act 
	FROM dbo.CUE_CLIENTE_CUENTA ccc
END
go

--Traer paginado
IF EXISTS(SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TP' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TP
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TP
@TamañoPagina varchar(16),
@NumeroPagina varchar(16),
@ScripOrden varchar(MAX) = NULL,
@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
    DECLARE @ScripSQL varchar(MAX)
    SET @ScripSQL = 'SELECT NumeroFila,Cod_Cuenta, Id_ClienteProveedor,Nro_Documento,Nom_Cliente,Fecha_Credito,Dia_Pago ,Monto_Mora, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , MesesMax ,MesesGracia, Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	   FROM(SELECT TOP 100 PERCENT Cod_Cuenta, ccc.Id_ClienteProveedor, pcp.Cliente as Nom_Cliente ,pcp.Nro_Documento ,Fecha_Credito,Dia_Pago ,Monto_Mora, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , MesesMax ,MesesGracia, Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , ccc.Cod_UsuarioReg , ccc.Fecha_Reg , ccc.Cod_UsuarioAct , ccc.Fecha_Act ,
	   ROW_NUMBER() OVER('+@ScripOrden+') AS NumeroFila
	   FROM CUE_CLIENTE_CUENTA ccc INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp on ccc.Id_ClienteProveedor= pcp.Id_ClienteProveedor '+@ScripWhere+') aCUE_CLIENTE_CUENTA
	   WHERE NumeroFila BETWEEN('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
    EXECUTE(@ScripSQL);
END
GO



-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TXPK' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TXPK
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TXPK 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT ccc.Cod_Cuenta, ccc.Id_ClienteProveedor, ccc.Fecha_Credito, ccc.Dia_Pago, ccc.Monto_Mora, ccc.Des_Cuenta, ccc.Cod_TipoCuenta, ccc.Monto_Deposito, ccc.Interes, ccc.MesesMax,ccc.MesesGracia, ccc.Limite_Max, ccc.Flag_ITF, ccc.Cod_Moneda, ccc.Cod_EstadoCuenta, ccc.Saldo_Contable, ccc.Saldo_Disponible, ccc.Cod_UsuarioReg, ccc.Fecha_Reg, ccc.Cod_UsuarioAct, ccc.Fecha_Act 
	FROM CUE_CLIENTE_CUENTA ccc
	WHERE (ccc.Cod_Cuenta = @Cod_Cuenta)	
END
go

-- Traer Auditoria
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_Auditoria' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_Auditoria
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_Auditoria 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM CUE_CLIENTE_CUENTA
	WHERE (Cod_Cuenta = @Cod_Cuenta)	
END
go

-- Traer Número de Filas
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TNF' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TNF
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TNF
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION	
AS
BEGIN
	EXECUTE('SELECT COUNT(*) AS NroFilas  FROM CUE_CLIENTE_CUENTA ' + @ScripWhere)	
END
go



--Cuenta cliente detalle


CREATE TABLE [dbo].[CUE_CLIENTE_CUENTA_D](
	[Cod_Cuenta] [varchar](32) NOT NULL,
	[item] [int] NOT NULL,
	[Des_CuentaD] [varchar](512) NOT NULL,
	[Saldo] [numeric](38, 2) NOT NULL,--El saldo que tenemos
	[Capital_Amortizado] [numeric](38, 2) NULL, --El capital amortizado
	[Monto] [numeric](38, 2) NULL, --Lo que se debe de pagar  (cuota mensual)
	[Cancelado] [numeric](38, 2) NULL, --Lo que cancelamos
	[Interes] [numeric](38, 2) NULL, --El monto del interes
	[Mora] [numeric](38, 2) NULL, --El monto de la mora
	[Fecha_Emision] [datetime] NULL,--Fecha del pago de la cuota
	[Fecha_Vencimiento] [datetime] NULL,
	[Cod_EstadoDCuenta] [varchar](3) NULL,
	[Cod_UsuarioReg] [varchar](32) NOT NULL,
	[Fecha_Reg] [datetime] NOT NULL,
	[Cod_UsuarioAct] [varchar](32) NULL,
	[Fecha_Act] [datetime] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Cod_Cuenta] ASC,
	[item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[CUE_CLIENTE_CUENTA_D]  WITH CHECK ADD FOREIGN KEY([Cod_Cuenta])
REFERENCES [dbo].[CUE_CLIENTE_CUENTA] ([Cod_Cuenta])
GO



--Guardar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_D_G' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_G
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_G 
	@Cod_Cuenta	varchar(32), 
	@item	int, 
	@Des_CuentaD	varchar(512), 
	@Saldo numeric (38,2),
	@Capital_Amortizado numeric (38,2),
	@Monto numeric(38,2), 
	@Cancelado numeric(38,2),
	@Interes numeric (38,2),
	@Mora numeric (38,2), 
	@Fecha_Emision	datetime, 
	@Fecha_Vencimiento	datetime, 
	@Cod_EstadoDCuenta	varchar(3),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Cuenta, @item FROM CUE_CLIENTE_CUENTA_D WHERE  (Cod_Cuenta = @Cod_Cuenta) AND (item = @item))
	BEGIN
		INSERT INTO CUE_CLIENTE_CUENTA_D  VALUES (
		@Cod_Cuenta,
		@item,
		@Des_CuentaD,
		@Saldo,
		@Capital_Amortizado,
		@Monto,
		@Cancelado,
		@Interes,
		@Mora,
		@Fecha_Emision,
		@Fecha_Vencimiento,
		@Cod_EstadoDCuenta,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CUE_CLIENTE_CUENTA_D
		SET	
			Des_CuentaD = @Des_CuentaD, 
			Saldo = @Saldo,
			Capital_Amortizado = @Capital_Amortizado,
			Monto = @Monto, 
			Cancelado=@Cancelado,
			Interes = @Interes,
			Mora = @Mora,
			Fecha_Emision = @Fecha_Emision, 
			Fecha_Vencimiento = @Fecha_Vencimiento, 
			Cod_EstadoDCuenta = @Cod_EstadoDCuenta,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Cuenta = @Cod_Cuenta) AND (item = @item)	
	END
END
go


--Eliminar todos los detalles por codigo de cuenta 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_D_EliminarXCodigo' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_EliminarXCodigo
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_EliminarXCodigo 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
    DELETE dbo.CUE_CLIENTE_CUENTA_D WHERE dbo.CUE_CLIENTE_CUENTA_D.Cod_Cuenta=@Cod_Cuenta
END
go

--trae un datatable con los detalles del credito por codigo de cuenta
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TraerDatatableXCodCuenta' AND type = 'P')
	DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TraerDatatableXCodCuenta
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TraerDatatableXCodCuenta 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
    SELECT cccd.* FROM dbo.CUE_CLIENTE_CUENTA_D cccd WHERE cccd.Cod_Cuenta=@Cod_Cuenta ORDER BY cccd.item ASC
END
go


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
go


--trae un datatable con los datos de un credito basicos
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CUENTA_CLIENTE_TraerResumenCreditoXCodCuenta' AND type = 'P')
	DROP PROCEDURE URP_CUENTA_CLIENTE_TraerResumenCreditoXCodCuenta
go
CREATE PROCEDURE URP_CUENTA_CLIENTE_TraerResumenCreditoXCodCuenta 
	@Cod_Cuenta	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT DISTINCT ccc.Cod_Cuenta,vtd.Nom_TipoDoc,pcp.Nro_Documento,pcp.Cliente,CONVERT(VARCHAR(10), ccc.Fecha_Credito, 103) Fecha_Credito,
	ccc.Dia_Pago,
	ccc.Des_Cuenta,ccc.Cod_UsuarioReg,ccc.MesesMax,ccc.MesesGracia,ccc.Monto_Deposito, ccc.Interes,vm.Nom_Moneda,ccc.Monto_Mora,cccd.item, 
	cccd.Saldo,
	cccd.Capital_Amortizado, cccd.Monto, cccd.Cancelado, cccd.Interes InteresDetalle, CONVERT(VARCHAR(10), cccd.Fecha_Emision, 103) Fecha_Pago
	FROM dbo.CUE_CLIENTE_CUENTA ccc 
	INNER JOIN dbo.CUE_CLIENTE_CUENTA_D cccd ON ccc.Cod_Cuenta=cccd.Cod_Cuenta
	INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
	INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON pcp.Cod_TipoDocumento=vtd.Cod_TipoDoc
	INNER JOIN dbo.VIS_MONEDAS vm ON ccc.Cod_Moneda = vm.Cod_Moneda
	WHERE ccc.Cod_Cuenta = @Cod_Cuenta
END
GO

--Metodo que traes los creditos a desembolsar por un nombre de cliente
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CUE_CLIENTE_TraerXDesembolsarXNombreCliente'
          AND type = 'P'
)
    DROP PROCEDURE USP_CUE_CLIENTE_TraerXDesembolsarXNombreCliente;
GO
CREATE PROCEDURE USP_CUE_CLIENTE_TraerXDesembolsarXNombreCliente @NonCliente VARCHAR(MAX)
WITH ENCRYPTION
AS
         BEGIN
             IF @NonCliente IS NOT NULL
                AND LEN(REPLACE(@NonCliente, ' ', '')) <> 0
                AND @NonCliente <> ''
                 BEGIN
                     SELECT ccc.Cod_Cuenta,
                            ccc.Fecha_Credito,
                            ccc.Dia_Pago,
                            ccc.Monto_Mora,
                            ccc.Des_Cuenta,
                            ccc.Cod_TipoCuenta,
                            ccc.Monto_Deposito,
                            ccc.Interes,
                            ccc.MesesMax,
                            ccc.MesesGracia,
                            ccc.Cod_Moneda,
					   vm.Nom_Moneda,
                            ccc.Cod_EstadoCuenta,
                            ccc.Saldo_Contable,
                            ccc.Saldo_Disponible,
                            ccc.Fecha_Reg,
                            ccc.Cod_UsuarioReg,
                            pcp.Id_ClienteProveedor,
                            pcp.Cod_TipoDocumento,
                            vtd.Nom_TipoDoc,
                            pcp.Nro_Documento,
                            pcp.Cliente,
                            pcp.Direccion,
                            pcp.Email1,
                            pcp.Email2
                     FROM dbo.CUE_CLIENTE_CUENTA ccc
                          INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
                          INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON vtd.Cod_TipoDoc = pcp.Cod_TipoDocumento
					      INNER JOIN dbo.VIS_MONEDAS vm ON ccc.Cod_Moneda=vm.Cod_Moneda
                     WHERE ccc.Saldo_Contable <> 0
                           AND ccc.Cod_EstadoCuenta = 'INI'
                           AND (pcp.Cliente LIKE '%'+@NonCliente+'%')
                           AND ccc.Cod_TipoCuenta = 'CRE';
                 END;
                 ELSE
                 BEGIN
                     SELECT ccc.Cod_Cuenta,
                            ccc.Fecha_Credito,
                            ccc.Dia_Pago,
                            ccc.Monto_Mora,
                            ccc.Des_Cuenta,
                            ccc.Cod_TipoCuenta,
                            ccc.Monto_Deposito,
                            ccc.Interes,
                            ccc.MesesMax,
                            ccc.MesesGracia,
                            ccc.Cod_Moneda,
					   vm.Nom_Moneda,
                            ccc.Cod_EstadoCuenta,
                            ccc.Saldo_Contable,
                            ccc.Saldo_Disponible,
                            ccc.Fecha_Reg,
                            ccc.Cod_UsuarioReg,
                            pcp.Id_ClienteProveedor,
                            pcp.Cod_TipoDocumento,
                            vtd.Nom_TipoDoc,
                            pcp.Nro_Documento,
                            pcp.Cliente,
                            pcp.Direccion,
                            pcp.Email1,
                            pcp.Email2
                     FROM dbo.CUE_CLIENTE_CUENTA ccc
                          INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
                          INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON vtd.Cod_TipoDoc = pcp.Cod_TipoDocumento
					      INNER JOIN dbo.VIS_MONEDAS vm ON ccc.Cod_Moneda=vm.Cod_Moneda
                     WHERE ccc.Saldo_Contable <> 0
                           AND ccc.Cod_EstadoCuenta = 'INI'
                           AND ccc.Cod_TipoCuenta = 'CRE'
                 END;
         END;
GO

--Metodo que traes los creditos a desembolsar por un documento de cliente
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CUE_CLIENTE_TraerXDesembolsarXDocCliente'
          AND type = 'P'
)
    DROP PROCEDURE USP_CUE_CLIENTE_TraerXDesembolsarXDocCliente;
GO
CREATE PROCEDURE USP_CUE_CLIENTE_TraerXDesembolsarXDocCliente @NroDocumento VARCHAR(MAX)
AS
         BEGIN
             IF @NroDocumento IS NOT NULL
                AND LEN(REPLACE(@NroDocumento, ' ', '')) <> 0
                AND @NroDocumento <> ''
                 BEGIN
                     SELECT ccc.Cod_Cuenta,
                            ccc.Fecha_Credito,
                            ccc.Dia_Pago,
                            ccc.Monto_Mora,
                            ccc.Des_Cuenta,
                            ccc.Cod_TipoCuenta,
                            ccc.Monto_Deposito,
                            ccc.Interes,
                            ccc.MesesMax,
                            ccc.MesesGracia,
                            ccc.Cod_Moneda,
					   vm.Nom_Moneda,
                            ccc.Cod_EstadoCuenta,
                            ccc.Saldo_Contable,
                            ccc.Saldo_Disponible,
                            ccc.Fecha_Reg,
                            ccc.Cod_UsuarioReg,
                            pcp.Id_ClienteProveedor,
                            pcp.Cod_TipoDocumento,
                            vtd.Nom_TipoDoc,
                            pcp.Nro_Documento,
                            pcp.Cliente,
                            pcp.Direccion,
                            pcp.Email1,
                            pcp.Email2
                     FROM dbo.CUE_CLIENTE_CUENTA ccc
                          INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
                          INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON vtd.Cod_TipoDoc = pcp.Cod_TipoDocumento
					      INNER JOIN dbo.VIS_MONEDAS vm ON ccc.Cod_Moneda=vm.Cod_Moneda
                     WHERE ccc.Saldo_Contable <> 0
                           AND ccc.Cod_EstadoCuenta = 'INI'
                           AND ccc.Cod_TipoCuenta = 'CRE'
                           AND (pcp.Nro_Documento = @NroDocumento);
                 END;
                 ELSE
                 BEGIN
                     SELECT ccc.Cod_Cuenta,
                            ccc.Fecha_Credito,
                            ccc.Dia_Pago,
                            ccc.Monto_Mora,
                            ccc.Des_Cuenta,
                            ccc.Cod_TipoCuenta,
                            ccc.Monto_Deposito,
                            ccc.Interes,
                            ccc.MesesMax,
                            ccc.MesesGracia,
                            ccc.Cod_Moneda,
					   		vm.Nom_Moneda,
                            ccc.Cod_EstadoCuenta,
                            ccc.Saldo_Contable,
                            ccc.Saldo_Disponible,
                            ccc.Fecha_Reg,
                            ccc.Cod_UsuarioReg,
                            pcp.Id_ClienteProveedor,
                            pcp.Cod_TipoDocumento,
                            vtd.Nom_TipoDoc,
                            pcp.Nro_Documento,
                            pcp.Cliente,
                            pcp.Direccion,
                            pcp.Email1,
                            pcp.Email2
                     FROM dbo.CUE_CLIENTE_CUENTA ccc
                          INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccc.Id_ClienteProveedor = pcp.Id_ClienteProveedor
                          INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON vtd.Cod_TipoDoc = pcp.Cod_TipoDocumento
					 	  INNER JOIN dbo.VIS_MONEDAS vm ON ccc.Cod_Moneda=vm.Cod_Moneda
                     WHERE ccc.Saldo_Contable <> 0
                           AND ccc.Cod_TipoCuenta = 'CRE'
                           AND ccc.Cod_EstadoCuenta = 'INI'
                 END;
         END;
GO

