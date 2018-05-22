-- ----Creamos un archivo de texto para realizar el volcado de datos C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp
-- ----Para ellos habilitamos permisos sql server
-- --EXEC sp_configure 'show advanced options', 1
-- --RECONFIGURE
-- --EXEC sp_configure 'xp_cmdshell', 1
-- --RECONFIGURE
-- --GO
-- ----Triggers sobre CAJ_COMPROBANTE_PAGO

-- ----Creamos el trigger despues del insert sobre caj_comprobante_pago para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 0 = insertar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT
-- --ON dbo.CAJ_COMPROBANTE_PAGO
-- --FOR INSERT,UPDATE
-- --AS 
-- --BEGIN
-- --	--IF NOT UPDATE(Valor_Resumen) AND NOT UPDATE(Valor_Firma)
-- --	--BEGIN
-- --		DECLARE @id_aux int
-- --		DECLARE @FechaAux datetime
-- -- 		SELECT  @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg FROM inserted i
-- --		DECLARE @cmd sysname
-- --		SET @cmd = 'echo '+
-- --		'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- --		CONVERT(varchar(max), @id_aux)+'@'+
-- --		'NULL'+'@'+
-- --		'0'+'@' +
-- --		CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --		EXEC master..xp_cmdshell @cmd 
-- --	--END
-- --END
-- --GO

-- ------Creamos el trigger despues del update sobre caj_comprobante_pago para 
-- ------Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- ----IF EXISTS (SELECT name 
-- ----	   FROM   sysobjects 
-- ----	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE' 
-- ----	   AND 	  type = 'TR')
-- ----    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE
-- ----GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_PAGO
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----		DECLARE @id_aux int
-- ----		DECLARE @FechaAux datetime
-- ---- 		SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux= ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
-- ----		--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----		DECLARE @cmd sysname
-- ----		SET @cmd = 'echo '+
-- ----		'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- ----		CONVERT(varchar(max), @id_aux)+'@'+
-- ----		'NULL'+'@'+
-- ----		'1'+'@' +
-- ----		CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----		EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre caj_comprobante_pago para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_PAGO
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- -- 	SELECT TOP 1 @id_aux=d.id_ComprobantePago FROM DELETED d 
-- --	--WHERE d.Cod_Libro=14 AND d.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	'NULL'+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO

-- ----Triggers sobre CAJ_COMPROBANTE_D

-- ----Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_D para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 0 = insertar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_INSERT' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT
-- --ON dbo.CAJ_COMPROBANTE_D
-- --FOR INSERT,UPDATE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- --	DECLARE @FechaAux datetime
-- -- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.id_Detalle FROM inserted i
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_D'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'0'+'@' +
-- --	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO

-- ------Creamos el trigger despues del update sobre CAJ_COMPROBANTE_D para 
-- ------Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- ----IF EXISTS (SELECT name 
-- ----	   FROM   sysobjects 
-- ----	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_UPDATE' 
-- ----	   AND 	  type = 'TR')
-- ----    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE
-- ----GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_D
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----	DECLARE @id_aux int
-- ----	DECLARE @Item_Aux int
-- ----	DECLARE @FechaAux datetime
-- ---- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.id_Detalle FROM inserted i
-- ----	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- ----	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----	DECLARE @cmd sysname
-- ----	SET @cmd = 'echo '+
-- ----	'CAJ_COMPROBANTE_D'+'@'+ 
-- ----	CONVERT(varchar(max), @id_aux)+'@'+
-- ----	CONVERT(varchar(max), @Item_Aux)+'@'+
-- ----	'1'+'@' +
-- ----	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----	EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_D para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_D
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- -- 	SELECT  @id_aux=d.id_ComprobantePago,@Item_Aux=d.id_Detalle FROM DELETED d 
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=d.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_D'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO



-- ----Triggers sobre CAJ_COMPROBANTE_RELACION

-- ----Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_RELACION para 
-- ----Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT
-- --ON dbo.CAJ_COMPROBANTE_RELACION
-- --FOR INSERT,UPDATE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- --	DECLARE @FechaAux datetime
-- -- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.Item FROM inserted i
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'0'+'@' +
-- --	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO

-- ------Creamos el trigger despues del update sobre CAJ_COMPROBANTE_RELACION para 
-- ------Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- ----IF EXISTS (SELECT name 
-- ----	   FROM   sysobjects 
-- ----	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE' 
-- ----	   AND 	  type = 'TR')
-- ----    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE
-- ----GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_RELACION
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----	DECLARE @id_aux int
-- ----	DECLARE @Item_Aux int
-- ----	DECLARE @FechaAux datetime
-- ---- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.Item FROM inserted i
-- ----	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- ----	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----	DECLARE @cmd sysname
-- ----	SET @cmd = 'echo '+
-- ----	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- ----	CONVERT(varchar(max), @id_aux)+'@'+
-- ----	CONVERT(varchar(max), @Item_Aux)+'@'+
-- ----	'1'+'@' +
-- ----	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----	EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_RELACION para 
-- ----Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_RELACION
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- -- 	SELECT TOP 1 @id_aux=d.id_ComprobantePago,@Item_Aux=d.Item FROM DELETED d 
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=d.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --

-- --Creamos un archivo de texto para realizar el volcado de datos C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp
-- --Para ellos habilitamos permisos sql server
-- EXEC sp_configure 'show advanced options', 1
-- RECONFIGURE
-- EXEC sp_configure 'xp_cmdshell', 1
-- RECONFIGURE
-- GO
-- --Triggers sobre CAJ_COMPROBANTE_PAGO

-- --Creamos el trigger despues del insert sobre caj_comprobante_pago para 
-- --Insertar dicha informacion sobre el archivo con codigo de accion 0 = insertar
-- IF EXISTS (SELECT name 
-- 	   FROM   sysobjects 
-- 	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT' 
-- 	   AND 	  type = 'TR')
--     DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT
-- GO

-- CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT
-- ON dbo.CAJ_COMPROBANTE_PAGO
-- FOR INSERT
-- AS 
-- BEGIN
-- 	--IF NOT UPDATE(Valor_Resumen) AND NOT UPDATE(Valor_Firma)
-- 	--BEGIN
-- 		DECLARE @id_aux int
-- 		DECLARE @FechaAux datetime
--  		SELECT  @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg FROM inserted i
-- 		DECLARE @cmd sysname
-- 		SET @cmd = 'echo '+
-- 		'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- 		CONVERT(varchar(max), @id_aux)+'@'+
-- 		'NULL'+'@'+
-- 		'0'+'@' +
-- 		CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- 		EXEC master..xp_cmdshell @cmd 
-- 	--END
-- END
-- GO

-- ------Creamos el trigger despues del update sobre caj_comprobante_pago para 
-- ------Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- ----IF EXISTS (SELECT name 
-- ----	   FROM   sysobjects 
-- ----	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE' 
-- ----	   AND 	  type = 'TR')
-- ----    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE
-- ----GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_PAGO
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----		DECLARE @id_aux int
-- ----		DECLARE @FechaAux datetime
-- ---- 		SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux= ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
-- ----		--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----		DECLARE @cmd sysname
-- ----		SET @cmd = 'echo '+
-- ----		'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- ----		CONVERT(varchar(max), @id_aux)+'@'+
-- ----		'NULL'+'@'+
-- ----		'1'+'@' +
-- ----		CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----		EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre caj_comprobante_pago para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_PAGO
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- -- 	SELECT TOP 1 @id_aux=d.id_ComprobantePago FROM DELETED d 
-- --	--WHERE d.Cod_Libro=14 AND d.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_PAGO'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	'NULL'+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO

-- --Triggers sobre CAJ_COMPROBANTE_D

-- --Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_D para 
-- --Insertar dicha informacion sobre el archivo con codigo de accion 0 = insertar
-- IF EXISTS (SELECT name 
-- 	   FROM   sysobjects 
-- 	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_INSERT' 
-- 	   AND 	  type = 'TR')
--     DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT
-- GO

-- CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT
-- ON dbo.CAJ_COMPROBANTE_D
-- FOR INSERT
-- AS 
-- BEGIN
-- 	DECLARE @id_aux int
-- 	DECLARE @Item_Aux int
-- 	DECLARE @FechaAux datetime
--  	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.id_Detalle FROM inserted i
-- 	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- 	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- 	DECLARE @cmd sysname
-- 	SET @cmd = 'echo '+
-- 	'CAJ_COMPROBANTE_D'+'@'+ 
-- 	CONVERT(varchar(max), @id_aux)+'@'+
-- 	CONVERT(varchar(max), @Item_Aux)+'@'+
-- 	'0'+'@' +
-- 	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- 	EXEC master..xp_cmdshell @cmd 
-- END
-- GO

-- ----Creamos el trigger despues del update sobre CAJ_COMPROBANTE_D para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_UPDATE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE
-- --GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_D
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----	DECLARE @id_aux int
-- ----	DECLARE @Item_Aux int
-- ----	DECLARE @FechaAux datetime
-- ---- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.id_Detalle FROM inserted i
-- ----	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- ----	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----	DECLARE @cmd sysname
-- ----	SET @cmd = 'echo '+
-- ----	'CAJ_COMPROBANTE_D'+'@'+ 
-- ----	CONVERT(varchar(max), @id_aux)+'@'+
-- ----	CONVERT(varchar(max), @Item_Aux)+'@'+
-- ----	'1'+'@' +
-- ----	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----	EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_D para 
-- ----Insertar dicha informacion sobre el archivo con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_D
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- -- 	SELECT  @id_aux=d.id_ComprobantePago,@Item_Aux=d.id_Detalle FROM DELETED d 
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=d.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_D'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO



-- ----Triggers sobre CAJ_COMPROBANTE_RELACION

-- --Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_RELACION para 
-- --Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
-- IF EXISTS (SELECT name 
-- 	   FROM   sysobjects 
-- 	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT' 
-- 	   AND 	  type = 'TR')
--     DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT
-- GO

-- CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT
-- ON dbo.CAJ_COMPROBANTE_RELACION
-- FOR INSERT
-- AS 
-- BEGIN
-- 	DECLARE @id_aux int
-- 	DECLARE @Item_Aux int
-- 	DECLARE @FechaAux datetime
--  	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.Item FROM inserted i
-- 	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- 	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- 	DECLARE @cmd sysname
-- 	SET @cmd = 'echo '+
-- 	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- 	CONVERT(varchar(max), @id_aux)+'@'+
-- 	CONVERT(varchar(max), @Item_Aux)+'@'+
-- 	'0'+'@' +
-- 	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- 	EXEC master..xp_cmdshell @cmd 
-- END
-- GO

-- ------Creamos el trigger despues del update sobre CAJ_COMPROBANTE_RELACION para 
-- ------Insertar dicha informacion sobre el archivo con codigo de accion 1 = actualizar
-- ----IF EXISTS (SELECT name 
-- ----	   FROM   sysobjects 
-- ----	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE' 
-- ----	   AND 	  type = 'TR')
-- ----    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE
-- ----GO

-- ----CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE
-- ----ON dbo.CAJ_COMPROBANTE_RELACION
-- ----FOR UPDATE
-- ----AS 
-- ----BEGIN
-- ----	DECLARE @id_aux int
-- ----	DECLARE @Item_Aux int
-- ----	DECLARE @FechaAux datetime
-- ---- 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.Item FROM inserted i
-- ----	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=i.id_ComprobantePago
-- ----	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- ----	DECLARE @cmd sysname
-- ----	SET @cmd = 'echo '+
-- ----	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- ----	CONVERT(varchar(max), @id_aux)+'@'+
-- ----	CONVERT(varchar(max), @Item_Aux)+'@'+
-- ----	'1'+'@' +
-- ----	CONVERT(varchar(max),@FechaAux,121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- ----	EXEC master..xp_cmdshell @cmd 
-- ----END
-- ----GO


-- ----Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_RELACION para 
-- ----Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 2 = eliminar
-- --IF EXISTS (SELECT name 
-- --	   FROM   sysobjects 
-- --	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE' 
-- --	   AND 	  type = 'TR')
-- --    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE
-- --GO

-- --CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE
-- --ON dbo.CAJ_COMPROBANTE_RELACION
-- --FOR DELETE
-- --AS 
-- --BEGIN
-- --	DECLARE @id_aux int
-- --	DECLARE @Item_Aux int
-- -- 	SELECT TOP 1 @id_aux=d.id_ComprobantePago,@Item_Aux=d.Item FROM DELETED d 
-- --	--INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago=d.id_ComprobantePago
-- --	--WHERE ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
-- --	DECLARE @cmd sysname
-- --	SET @cmd = 'echo '+
-- --	'CAJ_COMPROBANTE_RELACION'+'@'+ 
-- --	CONVERT(varchar(max), @id_aux)+'@'+
-- --	CONVERT(varchar(max), @Item_Aux)+'@'+
-- --	'2'+'@' +
-- --	CONVERT(varchar(max),GETDATE(),121) + ' >> C:\APLICACIONES\TEMP\log_ExportarREG_auxiliar.palerp'
-- --	EXEC master..xp_cmdshell @cmd 
-- --END
-- --GO





--Creamos nuestra tabla temporal donde se insertan los datos de las inserciones, modificaciones y eliminacion
IF NOT EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'TMP_COMPROBANTE_PAGO_LOG' 
	  AND 	 type = 'U')
BEGIN
    CREATE TABLE TMP_COMPROBANTE_PAGO_LOG (
	Id int IDENTITY(1,1)  PRIMARY KEY,
	Nombre_Tabla varchar(max) ,
	Id_Compropante_Pago int , 
	Id_Item int ,
	Accion int ,
	Fecha_Reg datetime )
END
GO


--Triggers sobre CAJ_COMPROBANTE_PAGO

--Creamos el trigger despues del insert sobre caj_comprobante_pago para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_PAGO
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    NULL, -- Id_Item - int
	    0, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO

--Creamos el trigger despues del update sobre caj_comprobante_pago para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 1 = actualizar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_PAGO
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux= ISNULL(i.Fecha_Act,GETDATE()) FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    NULL, -- Id_Item - int
	    1, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO


--Creamos el trigger despues del delete sobre caj_comprobante_pago para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 2 = eliminar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_FOR_DELETE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_PAGO
FOR DELETE
AS 
BEGIN
	DECLARE @id_aux int
 	SELECT TOP 1 @id_aux=d.id_ComprobantePago FROM DELETED d 
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    NULL, -- Id_Item - int
	    2, -- Accion - int
	    GETDATE() -- Fecha_Reg - datetime
	)
	END
END
GO

--Triggers sobre CAJ_COMPROBANTE_D

--Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_D para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_D
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.id_Detalle FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_D', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    0, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO

--Creamos el trigger despues del update sobre CAJ_COMPROBANTE_D para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 1 = actualizar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_D
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.id_Detalle FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_D', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    1, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO


--Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_D para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 2 = eliminar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_FOR_DELETE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_FOR_DELETE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_D
FOR DELETE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
 	SELECT TOP 1 @id_aux=d.id_ComprobantePago,@Item_Aux=d.id_Detalle FROM DELETED d 
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_D', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    2, -- Accion - int
	    GETDATE() -- Fecha_Reg - datetime
	)
	END
END
GO



--Triggers sobre CAJ_COMPROBANTE_RELACION

--Creamos el trigger despues del insert sobre CAJ_COMPROBANTE_RELACION para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 0 = insertar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_INSERT_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_RELACION
FOR INSERT
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=i.Fecha_Reg,@Item_Aux=i.Item FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    0, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO

--Creamos el trigger despues del update sobre CAJ_COMPROBANTE_RELACION para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 1 = actualizar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_UPDATE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_RELACION
FOR UPDATE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
	DECLARE @FechaAux datetime
 	SELECT TOP 1 @id_aux=i.id_ComprobantePago,@FechaAux=ISNULL(i.Fecha_Act,GETDATE()),@Item_Aux=i.Item FROM inserted i
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    1, -- Accion - int
	    @FechaAux -- Fecha_Reg - datetime
	)
	END
END
GO


--Creamos el trigger despues del delete sobre CAJ_COMPROBANTE_RELACION para 
--Insertar dicha informacion sobre TMP_COMPROBANTE_PAGO_LOG con codigo de accion 2 = eliminar
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE_CAJ_COMPROBANTE_LOG' 
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE_CAJ_COMPROBANTE_LOG
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_RELACION_FOR_DELETE_CAJ_COMPROBANTE_LOG
ON dbo.CAJ_COMPROBANTE_RELACION
FOR DELETE
AS 
BEGIN
	DECLARE @id_aux int
	DECLARE @Item_Aux int
 	SELECT TOP 1 @id_aux=d.id_ComprobantePago,@Item_Aux=d.Item FROM DELETED d 
	--WHERE i.Cod_Libro=14 AND i.Cod_TipoComprobante IN ('FE','BE','NCE','NDE')
	IF (@id_aux IS NOT NULL)
	BEGIN
	INSERT dbo.TMP_COMPROBANTE_PAGO_LOG
	(
	    --Id - this column value is auto-generated
	    Nombre_Tabla,
	    Id_Compropante_Pago,
	    Id_Item,
	    Accion,
	    Fecha_Reg
	)
	VALUES
	(
	    -- Id - int
	    'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - varchar
	    @id_aux, -- Id_Compropante_Pago - int
	    @Item_Aux, -- Id_Item - int
	    2, -- Accion - int
	    GETDATE() -- Fecha_Reg - datetime
	)
	END
END
GO