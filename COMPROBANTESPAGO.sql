IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CAJ_COMPROBANTE_PAGO')
	DROP TABLE CAJ_COMPROBANTE_PAGO
go


CREATE TABLE CAJ_COMPROBANTE_PAGO (
       iu_ComprobantePago   UNIQUEIDENTIFIER      DEFAULT NEWID(),      
       Cod_TipoComprobante  varchar(5) NOT NULL,
       Serie                varchar(5) NOT NULL,
       Numero               varchar(30) NOT NULL,       
       Cod_TipoDoc          varchar(2) NULL,
       Doc_Cliente          varchar(20) NULL,
       Nom_Cliente          varchar(512) NULL,       
       FechaEmision         datetime NOT NULL,      
       Flag_Anulado         bit NOT NULL,       
       Total                numeric(38,2) NOT NULL,       
	  Dir_XML				varchar(1024) NULL,
	  Dir_CDR				varchar(1024) NULL,
	  Dir_PDF				varchar(1024) NULL,
       Cod_UsuarioReg       varchar(32) NOT NULL,
       Fecha_Reg            datetime NOT NULL,
       Cod_UsuarioAct       varchar(32) NULL,
       Fecha_Act            datetime NULL,
       PRIMARY KEY NONCLUSTERED (iu_ComprobantePago)        
)
go

CREATE INDEX IX_CAJ_COMPROBANTE_PAGO_Consulta
    ON CAJ_COMPROBANTE_PAGO (Cod_TipoComprobante,Serie,Numero,FechaEmision,Total); 
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 15/11/2016
-- OBJETIVO: selecionar comprobantes de pago
-- exec USP_CAJ_COMPROBANTE_PAGO_ConsultaWeb 
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ConsultaWeb' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ConsultaWeb
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ConsultaWeb
	@Cod_TipoComprobante  varchar(5),
    @Serie                varchar(5),
    @Numero               varchar(30),       
    @FechaEmision         datetime,      
    @Total                numeric(38,2)
WITH ENCRYPTION
AS
BEGIN
	SELECT        iu_ComprobantePago, Cod_TipoComprobante, Serie, Numero, Cod_TipoDoc, Doc_Cliente, Nom_Cliente, FechaEmision, Flag_Anulado, Total, Dir_XML, Dir_CDR, 
							Dir_PDF
	FROM            CAJ_COMPROBANTE_PAGO
	where Cod_TipoComprobante = Cod_TipoComprobante and Serie = @Serie and Numero = @Numero 
	and FechaEmision = @FechaEmision and Total = @Total
END
GO