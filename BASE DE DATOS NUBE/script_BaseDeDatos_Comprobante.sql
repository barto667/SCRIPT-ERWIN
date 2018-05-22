--	 Archivo: script_tablas_PALERP.sql
--
--	 Versión: v3.1.0
--
--	 Autor(es): Reyber Yuri Palma Quispe y Laura Yanina Alegria Amudio
--
--	 Fecha de Creación: Tue Feb 09 04:56:26 2016
--
--	 Copyright Pale Consultores EIRL Peru 2013

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
	SET @FechaEmision= CONVERT(VARCHAR(10), @FechaEmision, 126)
	SELECT        iu_ComprobantePago, Cod_TipoComprobante, Serie, Numero, Cod_TipoDoc, Doc_Cliente, Nom_Cliente, FechaEmision, Flag_Anulado, Total, Dir_XML, Dir_CDR, 
							 Dir_PDF
	FROM            CAJ_COMPROBANTE_PAGO
	where Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and CONVERT(BIGINT,Numero) = CONVERT(BIGINT,@Numero)
	and FechaEmision = @FechaEmision and Total = @Total
END
GO


--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 06/02/2017
-- OBJETIVO: Guardar los datos de un comprobante web
-- exec USP_CAJ_COMPROBANTE_PAGO_G 
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_G' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G 
	@iu_ComprobantePago   UNIQUEIDENTIFIER output, 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30), 
	@Cod_TipoDoc	varchar(2), 
	@Doc_Cliente	varchar(20), 
	@Nom_Cliente	varchar(512), 
	@FechaEmision	datetime, 
	@Flag_Anulado	bit, 
	@Total	numeric(38,2), 
	@Dir_XML varchar(1024),
	@Dir_CDR varchar(1024),
	@Dir_PDF varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
SET DATEFORMAT dmy;
SET @FechaEmision= CONVERT(VARCHAR(10), @FechaEmision, 126)
IF NOT EXISTS (SELECT iu_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  (Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and Numero = @Numero 
	and FechaEmision = @FechaEmision and Total = @Total))
	BEGIN
		SET @iu_ComprobantePago  = NEWID();
		SET @Dir_XML = replace(@Dir_XML,'{ARCHIVO}',@iu_ComprobantePago)
		SET @Dir_CDR = replace(@Dir_CDR,'{ARCHIVO}',@iu_ComprobantePago)
		SET @Dir_PDF = replace(@Dir_PDF,'{ARCHIVO}',@iu_ComprobantePago)

		INSERT INTO CAJ_COMPROBANTE_PAGO  VALUES (
		@iu_ComprobantePago,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		@Cod_TipoDoc,
		@Doc_Cliente,
		@Nom_Cliente,
		@FechaEmision,
		@Flag_Anulado,
		@Total,
		@Dir_XML,
		@Dir_CDR,
		@Dir_PDF,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_COMPROBANTE_PAGO
		SET	
			Cod_TipoComprobante = @Cod_TipoComprobante, 
			Serie = @Serie, 
			Numero = @Numero, 
			Cod_TipoDoc = @Cod_TipoDoc, 
			Doc_Cliente = @Doc_Cliente, 
			Nom_Cliente = @Nom_Cliente, 
			FechaEmision = @FechaEmision, 
			Flag_Anulado = @Flag_Anulado, 
			Total = @Total, 
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and Numero = @Numero 
	and FechaEmision = @FechaEmision and Total = @Total)	
	END
END
go
--	 Archivo: script_tablas_PALERP.sql
--
--	 Versión: v3.1.0
--
--	 Autor(es): Reyber Yuri Palma Quispe y Laura Yanina Alegria Amudio
--
--	 Fecha de Creación: Tue Feb 09 04:56:26 2016
--
--	 Copyright Pale Consultores EIRL Peru 2013

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
	SET @FechaEmision= CONVERT(VARCHAR(10), @FechaEmision, 126)
	SELECT        iu_ComprobantePago, Cod_TipoComprobante, Serie, Numero, Cod_TipoDoc, Doc_Cliente, Nom_Cliente, FechaEmision, Flag_Anulado, Total, Dir_XML, Dir_CDR, 
							 Dir_PDF
	FROM            CAJ_COMPROBANTE_PAGO
	where Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and CONVERT(BIGINT,Numero) = CONVERT(BIGINT,@Numero)
	and FechaEmision = @FechaEmision and Total = @Total
END
GO


--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 06/02/2017
-- OBJETIVO: Guardar los datos de un comprobante web
-- exec USP_CAJ_COMPROBANTE_PAGO_G 
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_G' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G 
	@iu_ComprobantePago   UNIQUEIDENTIFIER output, 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(5), 
	@Numero	varchar(30), 
	@Cod_TipoDoc	varchar(2), 
	@Doc_Cliente	varchar(20), 
	@Nom_Cliente	varchar(512), 
	@FechaEmision	datetime, 
	@Flag_Anulado	bit, 
	@Total	numeric(38,2), 
	@Dir_XML varchar(1024),
	@Dir_CDR varchar(1024),
	@Dir_PDF varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
SET DATEFORMAT dmy;
SET @FechaEmision= CONVERT(VARCHAR(10), @FechaEmision, 126)
IF NOT EXISTS (SELECT iu_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  (Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and Numero = @Numero 
	and FechaEmision = @FechaEmision and Total = @Total))
	BEGIN
		SET @iu_ComprobantePago  = NEWID();
		SET @Dir_XML = replace(@Dir_XML,'{ARCHIVO}',@iu_ComprobantePago)
		SET @Dir_CDR = replace(@Dir_CDR,'{ARCHIVO}',@iu_ComprobantePago)
		SET @Dir_PDF = replace(@Dir_PDF,'{ARCHIVO}',@iu_ComprobantePago)

		INSERT INTO CAJ_COMPROBANTE_PAGO  VALUES (
		@iu_ComprobantePago,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		@Cod_TipoDoc,
		@Doc_Cliente,
		@Nom_Cliente,
		@FechaEmision,
		@Flag_Anulado,
		@Total,
		@Dir_XML,
		@Dir_CDR,
		@Dir_PDF,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_COMPROBANTE_PAGO
		SET	
			Cod_TipoComprobante = @Cod_TipoComprobante, 
			Serie = @Serie, 
			Numero = @Numero, 
			Cod_TipoDoc = @Cod_TipoDoc, 
			Doc_Cliente = @Doc_Cliente, 
			Nom_Cliente = @Nom_Cliente, 
			FechaEmision = @FechaEmision, 
			Flag_Anulado = @Flag_Anulado, 
			Total = @Total, 
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie and Numero = @Numero 
	and FechaEmision = @FechaEmision and Total = @Total)	
	END
END
go
