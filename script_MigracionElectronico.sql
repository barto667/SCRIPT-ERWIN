---------------------------------------------------------------------------------------------------------------------------------
-- Actualizado campos para la factura electronica
---------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE PRI_EMPRESA ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_EMPRESA ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_EMPRESA ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_EMPRESA ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_EMPRESA SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,
Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act;
GO
ALTER TABLE PRI_EMPRESA DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_EMPRESA DROP COLUMN Fecha_Reg
ALTER TABLE PRI_EMPRESA DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_EMPRESA DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_EMPRESA ADD Cod_Ubigeo varchar(32) NULL;
GO
ALTER TABLE PRI_EMPRESA ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_EMPRESA ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_EMPRESA ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_EMPRESA ADD Fecha_Act datetime NULL
GO
UPDATE PRI_EMPRESA SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth;
GO
ALTER TABLE PRI_EMPRESA DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_EMPRESA DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_EMPRESA DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_EMPRESA DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
-- PRI_SUCURSAL
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE PRI_SUCURSAL ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_SUCURSAL ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_SUCURSAL ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_SUCURSAL ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_SUCURSAL SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE PRI_SUCURSAL DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_SUCURSAL DROP COLUMN Fecha_Reg
ALTER TABLE PRI_SUCURSAL DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_SUCURSAL DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_SUCURSAL ADD Cod_Ubigeo varchar(32) NULL;
GO
ALTER TABLE PRI_SUCURSAL ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_SUCURSAL ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_SUCURSAL ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_SUCURSAL ADD Fecha_Act datetime NULL
GO
UPDATE PRI_SUCURSAL SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth
GO
ALTER TABLE PRI_SUCURSAL DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_SUCURSAL DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_SUCURSAL DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_SUCURSAL DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
-- CAJ_CAJAS_DOC
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE CAJ_CAJAS_DOC ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE CAJ_CAJAS_DOC ADD Fecha_Regh datetime NULL
ALTER TABLE CAJ_CAJAS_DOC ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE CAJ_CAJAS_DOC ADD Fecha_Acth datetime NULL
GO
UPDATE CAJ_CAJAS_DOC SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Cod_UsuarioReg
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Fecha_Reg
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Cod_UsuarioAct
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Fecha_Act
GO
ALTER TABLE CAJ_CAJAS_DOC ADD Nom_ArchivoPublicar varchar(512) NULL;
ALTER TABLE CAJ_CAJAS_DOC ADD Limite int NULL;
GO
ALTER TABLE CAJ_CAJAS_DOC ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE CAJ_CAJAS_DOC ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE CAJ_CAJAS_DOC ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE CAJ_CAJAS_DOC ADD Fecha_Act datetime NULL
GO
UPDATE CAJ_CAJAS_DOC SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Nom_ArchivoPublicar = '', Limite = 0
GO
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Fecha_Regh;
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Cod_UsuarioActh;
ALTER TABLE CAJ_CAJAS_DOC DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
-- PRI_ESTABLECIMIENTOS
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_ESTABLECIMIENTOS SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Fecha_Reg
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Cod_Ubigeo varchar(32) NULL;
GO
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_ESTABLECIMIENTOS ADD Fecha_Act datetime NULL
GO
UPDATE PRI_ESTABLECIMIENTOS SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth
GO
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_ESTABLECIMIENTOS DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
--PRI_CLIENTE_PROVEEDOR
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Reg
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Num_DiaCredito INT NULL;
GO
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Act datetime NULL
GO
UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Num_DiaCredito = 0
GO
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
--CAJ_COMPROBANTE_PAGO
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Fecha_Regh datetime NULL
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Fecha_Acth datetime NULL
GO
UPDATE CAJ_COMPROBANTE_PAGO SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Cod_UsuarioReg
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Fecha_Reg
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Cod_UsuarioAct
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_UsuarioVendedor varchar(32) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_RegimenPercepcion varchar(8) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Tasa_Percepcion numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Placa_Vehiculo varchar(64) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_TipoDocReferencia varchar(8) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Nro_DocReferencia varchar(64) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Valor_Resumen varchar(1024) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Valor_Firma varchar(2048) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_EstadoComprobante varchar(8) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD MotivoAnulacion varchar(512) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Otros_Cargos numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Otros_Tributos numeric(38,2) NULL;
GO
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_PAGO ADD Fecha_Act datetime NULL
GO
UPDATE CAJ_COMPROBANTE_PAGO SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, 
Cod_UsuarioVendedor = Cod_UsuarioReg,
Tasa_Percepcion = 0,
Cod_EstadoComprobante = 'FIN',
Otros_Cargos = 0.00,
Otros_Tributos = 0.00
GO
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Fecha_Regh;
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Cod_UsuarioActh;
ALTER TABLE CAJ_COMPROBANTE_PAGO DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
--CAJ_COMPROBANTE_D
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_D ADD Fecha_Regh datetime NULL
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_D ADD Fecha_Acth datetime NULL
GO
UPDATE CAJ_COMPROBANTE_D SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Cod_UsuarioReg
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Fecha_Reg
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Cod_UsuarioAct
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_D ADD Valor_NoOneroso numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_TipoISC varchar(8) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD Porcentaje_ISC numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD ISC numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_TipoIGV varchar(8) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD Porcentaje_IGV numeric(38,2) NULL;
ALTER TABLE CAJ_COMPROBANTE_D ADD IGV numeric(38,2) NULL;
GO
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE CAJ_COMPROBANTE_D ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE CAJ_COMPROBANTE_D ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_D ADD Fecha_Act datetime NULL
GO
UPDATE CAJ_COMPROBANTE_D SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth,
Valor_NoOneroso = 0.00,
Cod_TipoISC = '',
Porcentaje_ISC = 0.00,
ISC = 0.00,
Cod_TipoIGV = '10',
Porcentaje_IGV = 18.00,
IGV = ROUND(Sub_Total / 1.18 * 0.18,2)
GO
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Fecha_Regh;
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Cod_UsuarioActh;
ALTER TABLE CAJ_COMPROBANTE_D DROP COLUMN Fecha_Acth;
GO
---------------------------------------------------------------------------------------------------------------------------------
--CAJ_COMPROBANTE_RELACION
---------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Fecha_Regh datetime NULL
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Fecha_Acth datetime NULL
GO
UPDATE CAJ_COMPROBANTE_RELACION SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Cod_UsuarioReg
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Fecha_Reg
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Cod_UsuarioAct
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Fecha_Act
GO
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Id_DetalleRelacion INT NULL;
GO
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE CAJ_COMPROBANTE_RELACION ADD Fecha_Act datetime NULL
GO
UPDATE CAJ_COMPROBANTE_RELACION SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth
GO
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Fecha_Regh;
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Cod_UsuarioActh;
ALTER TABLE CAJ_COMPROBANTE_RELACION DROP COLUMN Fecha_Acth;
GO
-- nuevas tablas

IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CAJ_COMPROBANTE_LOG')
	DROP TABLE CAJ_COMPROBANTE_LOG
go


CREATE TABLE CAJ_COMPROBANTE_LOG (
       id_ComprobantePago   int NOT NULL,
       Item                 int NOT NULL,
       Cod_Estado           varchar(32) NULL,
       Cod_Mensaje          varchar(32) NULL,
       Mensaje              varchar(512) NULL,
       Cod_UsuarioReg       varchar(32) NOT NULL,
       Fecha_Reg            datetime NOT NULL,
       Cod_UsuarioAct       varchar(32) NULL,
       Fecha_Act            datetime NULL,
       PRIMARY KEY NONCLUSTERED (id_ComprobantePago, Item), 
       FOREIGN KEY (id_ComprobantePago)
                             REFERENCES CAJ_COMPROBANTE_PAGO
)
go


IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PRI_DESCUENTOS')
	DROP TABLE PRI_DESCUENTOS
go


CREATE TABLE PRI_DESCUENTOS (
       Id_Descuento         int IDENTITY(1,1),
       Id_ClienteProveedor  int NULL,
       Cod_TipoDescuento    varchar(32) NULL,
       Aplica               varchar(64) NULL,
       Cod_Aplica           varchar(32) NULL,
       Cod_TipoCliente      varchar(32) NULL,
       Cod_TipoPrecio       varchar(5) NULL,
       Monto_Precio         numeric(38,6) NULL,
       Fecha_Inicia         datetime NULL,
       Fecha_Fin            datetime NULL,
       Obs_Descuento        varchar(1024) NULL,
       Cod_UsuarioReg       varchar(32) NOT NULL,
       Fecha_Reg            datetime NOT NULL,
       Cod_UsuarioAct       varchar(32) NULL,
       Fecha_Act            datetime NULL,
       PRIMARY KEY NONCLUSTERED (Id_Descuento)
)
go


IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PRI_PRODUCTO_TASA')
	DROP TABLE PRI_PRODUCTO_TASA
go


CREATE TABLE PRI_PRODUCTO_TASA (
       Id_Producto          int NOT NULL,
       Cod_Tasa             varchar(32) NOT NULL,
       Cod_Libro            varchar(2) NULL,
       Des_Tasa             varchar(512) NULL,
       Por_Tasa             numeric(10,4) NULL,
       Cod_TipoTasa         varchar(8) NULL,
       Flag_Activo          bit NULL,
       Obs_Tasa             varchar(1024) NULL,
       Cod_UsuarioReg       varchar(32) NOT NULL,
       Fecha_Reg            datetime NOT NULL,
       Cod_UsuarioAct       varchar(32) NULL,
       Fecha_Act            datetime NULL,
       PRIMARY KEY NONCLUSTERED (Id_Producto, Cod_Tasa), 
       FOREIGN KEY (Id_Producto)
                             REFERENCES PRI_PRODUCTOS
)
go



