--Obtiene toda la informacion necesaria de las cajas y su relacion con el usuario
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_CAJAS_TraerCajasXCodUsuario' 
	 AND type = 'P'
)
DROP PROCEDURE USP_CAJ_CAJAS_TraerCajasXCodUsuario
GO
CREATE PROCEDURE USP_CAJ_CAJAS_TraerCajasXCodUsuario
@Cod_usuario varchar(max)
WITH ENCRYPTION
AS 
BEGIN
    --SELECT DISTINCT A.Cod_Caja,A.Des_Caja,CONVERT(bit,CASE WHEN A.Cod_Usuario IS NULL THEN 0 ELSE 1 END) Relacion FROM 
    --(SELECT cc.Cod_Caja,cc.Des_Caja,vuc.Cod_Usuario FROM dbo.CAJ_CAJAS cc LEFT JOIN dbo.VIS_USUARIOS_CAJA vuc ON cc.Cod_Caja = vuc.Cod_Caja
    --WHERE cc.Flag_Activo=1 ) as A
    --WHERE A.Cod_Usuario=@Cod_usuario
    --OR A.Cod_Usuario IS NULL
    --ORDER BY A.Cod_Caja
    DECLARE @Cod_Caja varchar(max)
    DECLARE @Des_Caja varchar(max)
    DECLARE @Estado bit
    IF OBJECT_ID('tempdb..#tempTablaResultado') IS NOT NULL
    BEGIN
	   DROP TABLE dbo.#tempTablaResultado;
    END
    CREATE TABLE #tempTablaResultado
    (
	   Cod_Caja   VARCHAR(MAX),
	   Des_Caja   VARCHAR(MAX),
	   Relacion bit
    )
    DECLARE  RecorrerScript CURSOR FOR (SELECT cc.Cod_Caja,cc.Des_Caja FROM dbo.CAJ_CAJAS cc WHERE cc.Flag_Activo=1)
    OPEN RecorrerScript
    FETCH NEXT FROM RecorrerScript 
    INTO @Cod_Caja,@Des_Caja
    WHILE @@FETCH_STATUS = 0
    BEGIN   
	   IF  EXISTS (SELECT vuc.* FROM dbo.VIS_USUARIOS_CAJA vuc WHERE vuc.Cod_Usuario=@Cod_usuario AND vuc.Cod_Caja=@Cod_Caja)
	   BEGIN
		  INSERT #tempTablaResultado
		  VALUES
		  (
			 @Cod_Caja, -- Cod_Caja - VARCHAR
			 @Des_Caja, -- Des_Caja - VARCHAR
			 1 -- Estado - bit
		  )
	   END
	   ELSE
	   BEGIN
		  INSERT #tempTablaResultado
		  VALUES
		  (
			 @Cod_Caja, -- Cod_Caja - VARCHAR
			 @Des_Caja, -- Des_Caja - VARCHAR
			 0 -- Estado - bit
		  )
	   END
	   FETCH NEXT FROM RecorrerScript 
	   INTO @Cod_Caja,@Des_Caja
    END 
    CLOSE RecorrerScript;
    DEALLOCATE RecorrerScript	

    SELECT ttr.* FROM #tempTablaResultado ttr
END
GO 

--Modificamos el tipo de dato para que funcionen las fotos
ALTER TABLE dbo.PRI_USUARIO 
ALTER COLUMN Foto varbinary(max)
GO

--Guarda, modifica o elimina las relaciones entre cajas y usuarios
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_USUARIOS_CAJA_G' 
	 AND type = 'P'
)
DROP PROCEDURE USP_VIS_USUARIOS_CAJA_G
GO
CREATE PROCEDURE USP_VIS_USUARIOS_CAJA_G
@Cod_usuario varchar(max),
@Cod_Caja varchar(max),
@Flag bit
WITH ENCRYPTION
AS 
BEGIN
    --Dos posibles opciones, si es 0 sifnifica borrar 1 agregar
    IF  @Flag = 0
    BEGIN
	   --Debemos eliminar la informacion de dicho usuario para dicha caja, sin importar su estado
	   DELETE dbo.PAR_FILA WHERE dbo.PAR_FILA.Cod_Tabla=98 AND dbo.PAR_FILA.Cod_Fila IN 
	   (SELECT vuc.Nro FROM dbo.VIS_USUARIOS_CAJA vuc WHERE vuc.Cod_Caja=@Cod_Caja AND vuc.Cod_Usuario=@Cod_usuario)
    END
    ELSE
    BEGIN
	   --Se debe agregar la informacion del usaurio de caja solo si no existe, si existe no se hace nada
	   IF NOT EXISTS(SELECT vuc.* FROM dbo.VIS_USUARIOS_CAJA vuc WHERE vuc.Cod_Caja=@Cod_Caja AND vuc.Cod_Usuario=@Cod_usuario)
	   BEGIN
		  DECLARE @Max int = (SELECT MAX(vuc.Nro) FROM dbo.VIS_USUARIOS_CAJA vuc) +1 
		  --Insertamos
		  EXEC USP_PAR_FILA_G '098','001',@Max,@Cod_Caja,NULL,NULL,NULL,NULL,1,@Cod_usuario
		  EXEC USP_PAR_FILA_G '098','002',@Max,@Cod_usuario,NULL,NULL,NULL,NULL,1,@Cod_usuario
		  EXEC USP_PAR_FILA_G '098','003',@Max,NULL,NULL,NULL,NULL,1,1,@Cod_usuario
	   END
    END
END
GO 


----------------------------------------------------------------------------------------------------------
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_CONFIGURACION_TraerXGrupo' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_CONFIGURACION_TraerXGrupo
GO

CREATE PROCEDURE USP_PRI_CONFIGURACION_TraerXGrupo
	@Grupo varchar(3) = NULL
AS
BEGIN
	IF @Grupo IS NULL 
	BEGIN
	   SELECT pc.* FROM dbo.PRI_CONFIGURACION pc
	END
	ELSE
	BEGIN
	   SELECT pc.* FROM dbo.PRI_CONFIGURACION pc WHERE pc.Grupo=@Grupo
	END
END
	
GO
--EXECUTE USP_PRI_CONFIGURACION_TraerXGrupo
--GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_CONFIGURACION_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_CONFIGURACION_G
GO

CREATE PROCEDURE USP_PRI_CONFIGURACION_G
	@Grupo varchar(3) ,
	@Inicio varchar(5) ,
	@Fin varchar(5) ,
	@Actual varchar(8),
	@Ruta_Diccionario varchar(max),
	@Idioma_Diccionario varchar(5),
	@Ruta_Ejecutable varchar(max)
AS
BEGIN
	IF NOT EXISTS(SELECT pc.* FROM dbo.PRI_CONFIGURACION pc WHERE pc.Grupo=@Grupo)
	BEGIN
	   INSERT dbo.PRI_CONFIGURACION
	   (
	       Grupo,
	       Inicio,
	       Fin,
	       Actual,
	       Ruta_Diccionario,
	       Idioma_Diccionario,
		  Ruta_Ejecutable
	   )
	   VALUES
	   (
	       @Grupo, -- Grupo - varchar
	       @Inicio, -- Inicio - varchar
	       @Fin, -- Fin - varchar
	       @Actual, -- Actual - varchar
	       @Ruta_Diccionario, -- Ruta_Diccionario - varchar
	       @Idioma_Diccionario, -- Idioma_Diccionario - varchar
		  @Ruta_Ejecutable
	   )
	END
	ELSE
	BEGIN
	   UPDATE dbo.PRI_CONFIGURACION
	   SET
	       dbo.PRI_CONFIGURACION.Inicio = @Inicio, -- varchar
	       dbo.PRI_CONFIGURACION.Fin = @Fin, -- varchar
	       dbo.PRI_CONFIGURACION.Actual = @Actual, -- varchar
	       dbo.PRI_CONFIGURACION.Ruta_Diccionario = @Ruta_Diccionario, -- varchar
	       dbo.PRI_CONFIGURACION.Idioma_Diccionario = @Idioma_Diccionario, -- varchar
		  dbo.PRI_CONFIGURACION.Ruta_Ejecutable = @Ruta_Ejecutable  -- varchar
	   WHERE dbo.PRI_CONFIGURACION.Grupo=@Grupo
	END
END	
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_CONFIGURACION_E' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_CONFIGURACION_E
GO

CREATE PROCEDURE USP_PRI_CONFIGURACION_E
	@Grupo varchar(3) 
AS
BEGIN
	DELETE dbo.PRI_CONFIGURACION WHERE dbo.PRI_CONFIGURACION.Grupo=@Grupo
END



----------------------------------------------------------------------------------------
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_REGISTRO_LOG_TraerTodo' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo
GO

CREATE PROCEDURE USP_TMP_REGISTRO_LOG_TraerTodo
WITH ENCRYPTION
AS
BEGIN
	SELECT trl.* FROM dbo.TMP_REGISTRO_LOG trl ORDER BY trl.Id
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_TMP_REGISTRO_LOG_MoverUno' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno
GO

CREATE PROCEDURE USP_TMP_REGISTRO_LOG_MoverUno
@Id varchar(max)
WITH ENCRYPTION
AS
BEGIN
    --Exporta una fila a un archivo de texto
    --Variables generales 
	DECLARE @cmd varchar(max)
	DECLARE @Nombre_Tabla varchar(max) 
	DECLARE @Id_Fila varchar(max) 
	DECLARE @Accion varchar(max) 
	DECLARE @Script varchar(max) 
	DECLARE @Fecha_Reg datetime 
	--Recuperamos el y almacenamos en las variables
	SELECT 
	    @Id=trl.Id, 
	    @Nombre_Tabla=trl.Nombre_Tabla, 
	    @Id_Fila=trl.Id_Fila, 
	    @Accion=trl.Accion, 
	    @Script=trl.Script, 
	    @Fecha_Reg=trl.Fecha_Reg 
	FROM dbo.TMP_REGISTRO_LOG trl
	WHERE trl.Id=@Id

	IF @Id IS NOT NULL
	BEGIN
		  
		      SET XACT_ABORT ON;  
			 BEGIN TRY  
			 BEGIN TRANSACTION;  
			 INSERT dbo.TMP_REGISTRO_LOG_H
			 (
				Nombre_Tabla,
				Id_Fila,
				Accion,
				Script,
				Fecha_Reg,
				Fecha_Reg_Insercion
			 )
			 VALUES
			 (
				@Nombre_Tabla, -- Nombre_Tabla - varchar
				@Id_Fila, -- Id_Fila - varchar
				@Accion, -- Accion - varchar
				@Script, -- Script - varchar
				@Fecha_Reg, -- Fecha_Reg - datetime
				GETDATE() -- Fecha_Reg_Insercion - datetime
			 )
			 DELETE dbo.TMP_REGISTRO_LOG WHERE @Id=dbo.TMP_REGISTRO_LOG.Id

			 COMMIT TRANSACTION;
		  END TRY  
      
		  BEGIN CATCH  
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
	END
END

GO


--Actualizacion de tipos de datos
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_ActualizacionesCriticas' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_ActualizacionesCriticas
GO

CREATE PROCEDURE USP_ActualizacionesCriticas
AS
BEGIN
    --Actualizacion de la tabla CAJ_COMPROBANTE_D, 
    --campo 
    --Descuento:  numeric(38,2)==>numeric(38,6)
    --Sub Total:  numeric(38,2)==>numeric(38,6)
    --IGV :	   numeric(38,2)==>numeric(38,6)
    --ISC :	   numeric(38,2)==>numeric(38,6)

    --Columna descuento
    DECLARE @PrecisionDescuento int
    DECLARE @EscalaDescuento int
    SELECT @PrecisionDescuento=precision,@EscalaDescuento=scale
    FROM sys.columns
    WHERE OBJECT_ID IN (SELECT OBJECT_ID
    FROM sys.objects
    WHERE type = 'U'
    AND name = 'CAJ_COMPROBANTE_D')
    AND name = 'Descuento'

    --Columna Sub_total
    DECLARE @PrecisionSubTotal int
    DECLARE @EscalaSubTotal int
    SELECT @PrecisionSubTotal=precision,@EscalaSubTotal=scale
    FROM sys.columns
    WHERE OBJECT_ID IN (SELECT OBJECT_ID
    FROM sys.objects
    WHERE type = 'U'
    AND name = 'CAJ_COMPROBANTE_D')
    AND name = 'Sub_Total'
    --Columna IGV
    DECLARE @PrecisionIGV int
    DECLARE @EscalaIGV int
    SELECT @PrecisionIGV=precision,@EscalaIGV=scale
    FROM sys.columns
    WHERE OBJECT_ID IN (SELECT OBJECT_ID
    FROM sys.objects
    WHERE type = 'U'
    AND name = 'CAJ_COMPROBANTE_D')
    AND name = 'IGV'
    --Columna ISC
    DECLARE @PrecisionISC int
    DECLARE @EscalaISC int
    SELECT @PrecisionISC=precision,@EscalaISC=scale
    FROM sys.columns
    WHERE OBJECT_ID IN (SELECT OBJECT_ID
    FROM sys.objects
    WHERE type = 'U'
    AND name = 'CAJ_COMPROBANTE_D')
    AND name = 'ISC'

    IF @PrecisionDescuento!= 38 
    OR @PrecisionSubTotal!=38
    OR @PrecisionISC!=38
    OR @PrecisionIGV!=38
    OR @EscalaDescuento!=6 
    OR @EscalaSubTotal!=6 
    OR @EscalaIGV!=6 
    OR @EscalaISC!=6 
    BEGIN
    --Agregamos columnas temporales
    ALTER TABLE dbo.CAJ_COMPROBANTE_D 
    ADD  DescuentoT numeric(38,6)
    ALTER TABLE dbo.CAJ_COMPROBANTE_D 
    ADD  Sub_TotalT numeric(38,6)
    ALTER TABLE dbo.CAJ_COMPROBANTE_D 
    ADD  IGVT numeric(38,6)
    ALTER TABLE dbo.CAJ_COMPROBANTE_D 
    ADD  ISCT numeric(38,6)
    EXEC(
	   '--Importamos los datos a nuestros temporales
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	       dbo.CAJ_COMPROBANTE_D.DescuentoT=dbo.CAJ_COMPROBANTE_D.Descuento,
		  dbo.CAJ_COMPROBANTE_D.Sub_TotalT=dbo.CAJ_COMPROBANTE_D.Sub_Total,
		  dbo.CAJ_COMPROBANTE_D.IGVT=dbo.CAJ_COMPROBANTE_D.IGV,
		  dbo.CAJ_COMPROBANTE_D.ISCT=dbo.CAJ_COMPROBANTE_D.ISC,
		  dbo.CAJ_COMPROBANTE_D.Descuento=NULL,
		  dbo.CAJ_COMPROBANTE_D.Sub_Total=NULL,
		  dbo.CAJ_COMPROBANTE_D.IGV=NULL,
		  dbo.CAJ_COMPROBANTE_D.ISC=NULL
	   --Modificamos los tipos de datos
	   ALTER TABLE dbo.CAJ_COMPROBANTE_D ALTER COLUMN Descuento numeric(38,6)
	   ALTER TABLE dbo.CAJ_COMPROBANTE_D ALTER COLUMN Sub_Total numeric(38,6)
	   ALTER TABLE dbo.CAJ_COMPROBANTE_D ALTER COLUMN IGV numeric(38,6)
	   ALTER TABLE dbo.CAJ_COMPROBANTE_D ALTER COLUMN ISC numeric(38,6)
	   --Movemos nuestros datos
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	       dbo.CAJ_COMPROBANTE_D.Descuento=dbo.CAJ_COMPROBANTE_D.DescuentoT,
		  dbo.CAJ_COMPROBANTE_D.Sub_Total=dbo.CAJ_COMPROBANTE_D.Sub_TotalT,
		  dbo.CAJ_COMPROBANTE_D.IGV=dbo.CAJ_COMPROBANTE_D.IGVT,
		  dbo.CAJ_COMPROBANTE_D.ISC=dbo.CAJ_COMPROBANTE_D.ISCT')
    --Eliminamos nuestras columnas temporales
    ALTER TABLE dbo.CAJ_COMPROBANTE_D DROP COLUMN DescuentoT 
    ALTER TABLE dbo.CAJ_COMPROBANTE_D DROP COLUMN Sub_TotalT
    ALTER TABLE dbo.CAJ_COMPROBANTE_D DROP COLUMN IGVT
    ALTER TABLE dbo.CAJ_COMPROBANTE_D DROP COLUMN ISCT
    END
END
GO







-- DECLARE @FechaInicio datetime = '2018-08-06 11:08:15.423'
-- DECLARE @FechaFin datetime =  '2018-08-06 11:08:15.423'
-- DECLARE @Motivo varchar(max) = 'OTROS'


-- SET DATEFORMAT ymd;
-- SET @Motivo = UPPER(@Motivo)
-- SELECT DISTINCT
-- ccp.id_ComprobantePago,
-- CASE WHEN @Motivo='CONEXION INTERNET' THEN '1' WHEN @Motivo='FALLAS FLUIDO ELECTRICO' THEN '2' WHEN @Motivo='DESASTRES NATURALES' THEN '3' WHEN @Motivo='ROBO' THEN '4' WHEN @Motivo='FALLAS EN EL SISTEMA DE EMISION ELECTRONICA' THEN '5' WHEN @Motivo='VENTAS POR EMISORES ITINERANTES' THEN '6' ELSE '7' END Motivo, 
-- ccp.Cod_TipoOperacion Tipo_Operacion,
-- ccp.FechaEmision Fecha_Emision,
-- CASE WHEN ccp.Cod_TipoComprobante = 'FA' THEN '01' WHEN ccp.Cod_TipoComprobante = 'BO' THEN '03' WHEN ccp.Cod_TipoComprobante = 'NC' THEN '07' WHEN ccp.Cod_TipoComprobante = 'ND' THEN '08' WHEN ccp.Cod_TipoComprobante IN ('TKB','TKF') THEN '12' END Tipo_Comprobante,
-- ccp.Serie,
-- ccp.Numero,
-- '' Rango_Final_Ticket,
-- CASE WHEN ccp.Cod_TipoDoc IN ('1','4','6','7','A') THEN ccp.Cod_TipoDoc ELSE '0' END Tipo_Documento,
-- ccp.Doc_Cliente,
-- SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(ccp.Nom_Cliente),CHAR(10),''),CHAR(13),''),CHAR(239),''),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'&','Y'),'Ñ','NI'),0,60) Nom_Cliente,
-- ccp.Cod_Moneda,
-- 0.00 Suma_Gravadas,
-- 0.00 Suma_Exoneradas,
-- 0.00 Suma_Inafectas,
-- 0.00 Suma_Exportacion,
-- 0.00 Suma_ISC,
-- 0.00 Suma_IGV,
-- ccp.Otros_Cargos+ccp.Otros_Tributos Suma_Otros_Cargos,
-- 0.00 Importe
-- FROM dbo.CAJ_COMPROBANTE_D ccd
-- INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
-- WHERE 
-- ccp.Cod_TipoComprobante IN ('BO','FA','TKF','TKB')
-- AND ccp.Cod_Libro=14
-- AND ccp.FechaEmision BETWEEN  
-- CONVERT(datetime, CONVERT(varchar(max), @FechaInicio,103))  AND DATEADD(second,-1,DATEADD(day,1, CONVERT(datetime, CONVERT(varchar(max), @FechaFin,103))))
-- ORDER BY Fecha_Emision


--Resumen de contingencia


--EXEC USP_CAJ_COMPROBANTE_PAGO_TraerComprobanteManualesXRango '2018-05-12 11:08:15.423','2018-06-12 11:08:15.423'
--Trae un conjunto de comprobantes manuales sin los totales acumulados
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_TraerComprobanteManualesXRango' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerComprobanteManualesXRango
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerComprobanteManualesXRango
 @FechaInicio datetime,
 @FechaFin datetime ,
 @Motivo varchar(max) = 'OTROS'
AS
BEGIN
    SET DATEFORMAT dmy;
    SET @Motivo = UPPER(@Motivo)
    SELECT DISTINCT
    ccp.id_ComprobantePago,
    ccp.Descuento_Total,
    @Motivo Motivo, 
    CASE WHEN ccp.Cod_TipoOperacion ='01' THEN 'VENTA INTERNA' WHEN ccp.Cod_TipoOperacion ='02' THEN 'EXPORTACION' END Tipo_Operacion,
    ccp.FechaEmision Fecha_Emision,
    CASE WHEN ccp.Cod_TipoComprobante='BO' THEN 'BOLETA' WHEN ccp.Cod_TipoComprobante='FA' THEN 'FACTURA' WHEN ccp.Cod_TipoComprobante='NC' THEN 'NOTA DE CREDITO' WHEN ccp.Cod_TipoComprobante='ND' THEN 'NOTA DE DEBITO' WHEN ccp.Cod_TipoComprobante IN ('TKB','TKF') THEN 'TICKET DE MAQUINA REGISTRADORA' END Tipo_Comprobante,
    ccp.Serie,
    ccp.Numero,
    '' Rango_Final_Ticket,
    CASE WHEN ccp.Cod_TipoDoc IN ('0','99') THEN 'SIN DOCUMENTO' WHEN ccp.Cod_TipoDoc='1' THEN 'DNI' WHEN ccp.Cod_TipoDoc='4' THEN 'CARNET DE EXTRANJERIA' WHEN ccp.Cod_TipoDoc='6' THEN 'RUC' WHEN ccp.Cod_TipoDoc='7' THEN 'PASAPORTE' WHEN ccp.Cod_TipoDoc='A' THEN 'CEDULA DIPLOMATICA DE IDENTIDAD' ELSE 'SIN DOCUMENTO' END Tipo_Documento,
    ccp.Doc_Cliente,
    SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(ccp.Nom_Cliente),CHAR(10),''),CHAR(13),''),CHAR(239),''),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'&','Y'),'Ñ','NI'),0,60) Nom_Cliente,
    ccp.Cod_Moneda,
    0.00 Suma_Gravadas,
    0.00 Suma_Exoneradas,
    0.00 Suma_Inafectas,
    0.00 Suma_Exportacion,
    0.00 Suma_ISC,
    0.00 Suma_IGV,
    ABS(ccp.Otros_Cargos)+ABS(ccp.Otros_Tributos) Suma_Otros_Cargos,
    0.00 Importe,
    CASE WHEN ccp.Cod_TipoComprobante IN ('NC','ND') THEN (SELECT CASE WHEN ccp2.Cod_TipoComprobante='BO' THEN 'BOLETA' WHEN ccp2.Cod_TipoComprobante='FA' THEN 'FACTURA' WHEN ccp2.Cod_TipoComprobante='NC' THEN 'NOTA DE CREDITO' WHEN ccp2.Cod_TipoComprobante='ND' THEN 'NOTA DE DEBITO' WHEN ccp2.Cod_TipoComprobante IN ('TKB','TKF') THEN 'TICKET DE MAQUINA REGISTRADORA' END FROM dbo.CAJ_COMPROBANTE_PAGO ccp2 WHERE ccp2.id_ComprobanteRef=ccp.id_ComprobantePago) ELSE '' END Tipo_Comprobante_Afectado,  --Traemos el tipo del comprobante afectado
    CASE WHEN ccp.Cod_TipoComprobante IN ('NC','ND') THEN (SELECT ccp2.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp2 WHERE ccp2.id_ComprobanteRef=ccp.id_ComprobantePago) ELSE '' END Serie_Afectado,  --Traemos el tipo del comprobante afectado
    CASE WHEN ccp.Cod_TipoComprobante IN ('NC','ND') THEN (SELECT ccp2.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp2 WHERE ccp2.id_ComprobanteRef=ccp.id_ComprobantePago) ELSE '' END Numero_Afectado,  --Traemos el tipo del comprobante afectado
    '' Regimen_Percepcion,
    0.00 Base_Imponible_Percepcion,
    0.00 Monto_Percepcion,
    0.00 Monto_Total_Percepcion
    FROM dbo.CAJ_COMPROBANTE_D ccd
    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
    WHERE 
    ccp.Cod_TipoComprobante IN ('BO','FA','TKF','TKB')
    AND ccp.Cod_Libro=14
    AND ccp.FechaEmision BETWEEN  
    CONVERT(datetime, CONVERT(varchar(max), @FechaInicio,103))  AND DATEADD(second,-1,DATEADD(day,1, CONVERT(datetime, CONVERT(varchar(max), @FechaFin,103))))
    ORDER BY Fecha_Emision
END
GO

--Creditos
--ALTER TABLE dbo.CUE_CLIENTE_CUENTA DROP COLUMN Des_Cuenta, Cod_TipoCuenta, Monto_Deposito, Interes, MesesMax, Limite_Max, Flag_ITF, Cod_Moneda, Cod_EstadoCuenta, Saldo_Contable, Saldo_Disponible, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act;
--GO
--ALTER TABLE dbo.CUE_CLIENTE_CUENTA
--ADD Fecha_Credito    DATETIME NOT NULL,
--    Dia_Pago         INT NOT NULL,
--    Monto_Mora       NUMERIC(38, 6) NOT NULL,
--    Des_Cuenta       VARCHAR(512) NULL,
--    Cod_TipoCuenta   VARCHAR(3) NOT NULL,
--    Monto_Deposito   NUMERIC(38, 2) NOT NULL,
--    Interes          NUMERIC(38, 4) NOT NULL,
--    Meses_Max        INT NOT NULL,
--    Meses_Gracia     INT NOT NULL,
--    Limite_Max       NUMERIC(38, 2) NULL,
--    Flag_ITF         BIT NOT NULL,
--    Cod_Moneda       VARCHAR(3) NOT NULL,
--    Cod_EstadoCuenta VARCHAR(3) NOT NULL,
--    Saldo_Contable   NUMERIC(38, 2) NOT NULL,
--    Saldo_Disponible NUMERIC(38, 2) NULL,
--    Cod_UsuarioReg   VARCHAR(32) NOT NULL,
--    Fecha_Reg        DATETIME NOT NULL,
--    Cod_UsuarioAct   VARCHAR(32) NULL,
--    Fecha_Act        DATETIME NULL;
--GO



-- IF EXISTS(SELECT name 
-- 	  FROM 	 sysobjects 
-- 	  WHERE  name = N'CUE_CLIENTE_CUENTA' 
-- 	  AND 	 type = 'U')
--     DROP TABLE CUE_CLIENTE_CUENTA
-- GO

-- CREATE TABLE CUE_CLIENTE_CUENTA(
-- 	Cod_Cuenta varchar(32) NOT NULL,
-- 	Id_ClienteProveedor int NULL,
-- 	Cod_Libro varchar(5) NOT NULL,
-- 	Fecha_Credito datetime NOT NULL,
-- 	Dia_Pago int NOT NULL,
-- 	Monto_Mora numeric(38, 6) NOT NULL,
-- 	Des_Cuenta varchar(512) NULL,
-- 	Cod_TipoCuenta varchar(3) NOT NULL,
-- 	Monto_Deposito numeric(38, 2) NOT NULL,
-- 	Interes numeric(38, 4) NOT NULL,
-- 	Meses_Max int NOT NULL,
-- 	Meses_Gracia int NOT NULL,
-- 	Limite_Max numeric(38, 2) NULL,
-- 	Flag_ITF bit NOT NULL,
-- 	Cod_Moneda varchar(3) NOT NULL,
-- 	Cod_EstadoCuenta varchar(3) NOT NULL,
-- 	Saldo_Contable numeric(38, 2) NOT NULL,
-- 	Saldo_Disponible numeric(38, 2) NULL,
-- 	Cod_UsuarioReg varchar(32) NOT NULL,
-- 	Fecha_Reg datetime NOT NULL,
-- 	Cod_UsuarioAct varchar(32) NULL,
-- 	Fecha_Act datetime NULL,
-- PRIMARY KEY NONCLUSTERED 
-- (
-- 	Cod_Cuenta ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
-- ) ON [PRIMARY]
-- GO

-- ALTER TABLE CUE_CLIENTE_CUENTA  WITH CHECK ADD FOREIGN KEY(Id_ClienteProveedor)
-- REFERENCES PRI_CLIENTE_PROVEEDOR (Id_ClienteProveedor)
-- GO

-- IF EXISTS(SELECT name 
-- 	  FROM 	 sysobjects 
-- 	  WHERE  name = N'CUE_CLIENTE_CUENTA_D' 
-- 	  AND 	 type = 'U')
--     DROP TABLE CUE_CLIENTE_CUENTA_D
-- GO

-- CREATE TABLE CUE_CLIENTE_CUENTA_D(
-- 	Cod_Cuenta varchar (32) NOT NULL,
-- 	item int NOT NULL,
-- 	Des_CuentaD varchar(512) NOT NULL,
-- 	Saldo numeric(38,6) NOT NULL,
-- 	Capital_Amortizado numeric(38,6) NOT NULL,
-- 	Monto numeric(38, 6) NOT NULL,
-- 	Cancelado numeric(38, 6) NOT NULL,
-- 	Interes numeric(38, 6) NOT NULL,
-- 	Mora numeric(38, 6) NOT NULL,
-- 	Fecha_Emision datetime NOT NULL ,
-- 	Fecha_Vencimiento datetime NOT NULL,
-- 	Cod_EstadoDCuenta varchar(3) NULL,
-- 	Cod_UsuarioReg varchar(32) NOT NULL,
-- 	Fecha_Reg datetime NOT NULL,
-- 	Cod_UsuarioAct varchar(32) NULL,
-- 	Fecha_Act datetime NULL,
-- PRIMARY KEY NONCLUSTERED 
-- (
-- 	Cod_Cuenta ASC,
-- 	item ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
-- ) ON [PRIMARY]
-- GO

-- ALTER TABLE CUE_CLIENTE_CUENTA_D  WITH CHECK ADD FOREIGN KEY(Cod_Cuenta)
-- REFERENCES CUE_CLIENTE_CUENTA (Cod_Cuenta)
-- GO

-- IF EXISTS(SELECT name 
-- 	  FROM 	 sysobjects 
-- 	  WHERE  name = N'CUE_CLIENTE_CUENTA_M' 
-- 	  AND 	 type = 'U')
--     DROP TABLE CUE_CLIENTE_CUENTA_M
-- GO

-- CREATE TABLE CUE_CLIENTE_CUENTA_M(
-- 	Id_ClienteCuentaMov int IDENTITY(100000,1) NOT NULL,
-- 	Cod_Cuenta varchar(32) NULL,
-- 	Cod_TipoMovimiento varchar(16) NULL,
-- 	Id_Movimiento int NULL,
-- 	Des_Movimiento varchar(512) NULL,
-- 	Cod_MonedaIng varchar(5) NULL,
-- 	Ingreso numeric(38, 2) NULL,
-- 	Cod_MonedaEgr varchar(5) NULL,
-- 	Egreso numeric(38, 2) NULL,
-- 	Tipo_Cambio numeric(10, 4) NULL,
-- 	Fecha datetime NULL,
-- 	Flag_Extorno bit NOT NULL,
-- 	id_MovimientoCaja int NULL,
-- 	Cod_UsuarioReg varchar(32) NOT NULL,
-- 	Fecha_Reg datetime NOT NULL,
-- 	Cod_UsuarioAct varchar(32) NULL,
-- 	Fecha_Act datetime NULL,
-- PRIMARY KEY NONCLUSTERED 
-- (
-- 	Id_ClienteCuentaMov ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
-- ) ON [PRIMARY]
-- GO

-- ALTER TABLE CUE_CLIENTE_CUENTA_M  WITH CHECK ADD FOREIGN KEY(Cod_Cuenta)
-- REFERENCES CUE_CLIENTE_CUENTA (Cod_Cuenta)
-- GO




IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CUE_CLIENTE_CUENTA_TP' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TP
GO

CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Cuenta , Id_ClienteProveedor,
	CASE WHEN Cod_Libro=''14'' THEN ''VENTA'' ELSE ''COMPRA'' END Tipo_Cuenta, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max , Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Cuenta , Id_ClienteProveedor ,Cod_Libro, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max , Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM CUE_CLIENTE_CUENTA '+@ScripWhere+') aCUE_CLIENTE_CUENTA
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CUE_CLIENTE_CUENTA_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_G
GO

CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_G 
	@Cod_Cuenta	varchar(32), 
	@Id_ClienteProveedor	int, 
	@Cod_Libro varchar(5),
	@Fecha_Credito datetime,
	@Dia_Pago int,
	@Monto_Mora numeric(38,6),
	@Des_Cuenta	varchar(512), 
	@Cod_TipoCuenta	varchar(3), 
	@Monto_Deposito	numeric(38,2), 
	@Interes	numeric(38,4), 
	@Meses_Max	int, 
	@Meses_Gracia int,
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
		@Cod_Libro,
		@Fecha_Credito,
		@Dia_Pago,
		@Monto_Mora,
		@Des_Cuenta,
		@Cod_TipoCuenta,
		@Monto_Deposito,
		@Interes,
		@Meses_Max,
		@Meses_Gracia,
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
			Cod_Libro=@Cod_Libro,
			Fecha_Credito=@Fecha_Credito,
			Dia_Pago=@Dia_Pago,
			Monto_Mora=@Monto_Mora,
			Des_Cuenta = @Des_Cuenta, 
			Cod_TipoCuenta = @Cod_TipoCuenta, 
			Monto_Deposito = @Monto_Deposito, 
			Interes = @Interes, 
			Meses_Max = @Meses_Max, 
			Meses_Gracia=@Meses_Gracia,
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
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CUE_CLIENTE_CUENTA_D_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_G
GO

CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_G 
	@Cod_Cuenta	varchar(32), 
	@item	int, 
	@Des_CuentaD	varchar(512), 
	@Saldo numeric(38,6),
	@Capital_Amortizado numeric(38,6),
	@Monto	numeric(38,6), 
	@Cancelado numeric(38,6),
	@Interes numeric(38,6),
	@Mora numeric(38,6),
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
			Saldo=@Saldo,
			Capital_Amortizado=@Capital_Amortizado,
			Monto = @Monto, 
			Cancelado=@Cancelado,
			Interes=@Interes,
			Mora=@Mora,
			Fecha_Emision = @Fecha_Emision, 
			Fecha_Vencimiento = @Fecha_Vencimiento, 
			Cod_EstadoDCuenta = @Cod_EstadoDCuenta,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Cuenta = @Cod_Cuenta) AND (item = @item)	
	END
END
GO

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
    SET @ScripSQL = 'SELECT NumeroFila,Cod_Cuenta, Id_ClienteProveedor,Nro_Documento,Nom_Cliente,Fecha_Credito,Dia_Pago ,Monto_Mora, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max ,Meses_Gracia, Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	   FROM(SELECT TOP 100 PERCENT Cod_Cuenta, ccc.Id_ClienteProveedor, pcp.Cliente as Nom_Cliente ,pcp.Nro_Documento ,Fecha_Credito,Dia_Pago ,Monto_Mora, Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max ,Meses_Gracia, Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , ccc.Cod_UsuarioReg , ccc.Fecha_Reg , ccc.Cod_UsuarioAct , ccc.Fecha_Act ,
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
	SELECT ccc.*
	FROM CUE_CLIENTE_CUENTA ccc
	WHERE (ccc.Cod_Cuenta = @Cod_Cuenta)	
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