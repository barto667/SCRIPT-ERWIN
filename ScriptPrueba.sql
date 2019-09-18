--CAJ_COMPROBANTE_PAGO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
ON dbo.CAJ_COMPROBANTE_PAGO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_PAGO'
	--Variables de tabla secundarias
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Cod_Periodo varchar(8)
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_TipoOperacion varchar(5)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(5)
	DECLARE @Numero varchar(30)
	DECLARE @Id_Cliente int
	DECLARE @Cod_TipoDoc varchar(2)
	DECLARE @Doc_Cliente varchar(20)
	DECLARE @Nom_Cliente varchar(512)
	DECLARE @Direccion_Cliente varchar(512)
	DECLARE @FechaEmision datetime
	DECLARE @FechaVencimiento datetime
	DECLARE @FechaCancelacion datetime
	DECLARE @Glosa varchar(512)
	DECLARE @TipoCambio numeric(10,4)
	DECLARE @Flag_Anulado bit
	DECLARE @Flag_Despachado bit
	DECLARE @Cod_FormaPago varchar(5)
	DECLARE @Descuento_Total numeric(38,2)
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Impuesto numeric(38,6)
	DECLARE @Total numeric(38,2)
	DECLARE @Obs_Comprobante xml
	DECLARE @Id_GuiaRemision int
	DECLARE @GuiaRemision varchar(50)
	DECLARE @id_ComprobanteRef int
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Nro_Ticketera varchar(64)
	DECLARE @Cod_UsuarioVendedor varchar(32)
	DECLARE @Cod_RegimenPercepcion varchar(8)
	DECLARE @Tasa_Percepcion numeric(38,2)
	DECLARE @Placa_Vehiculo varchar(64)
	DECLARE @Cod_TipoDocReferencia varchar(8)
	DECLARE @Nro_DocReferencia varchar(64)
	DECLARE @Valor_Resumen varchar(1024)
	DECLARE @Valor_Firma varchar(2048)
	DECLARE @Cod_EstadoComprobante varchar(8)
	DECLARE @MotivoAnulacion varchar(512)
	DECLARE @Otros_Cargos numeric(38,2)
	DECLARE @Otros_Tributos numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF ((@Exportacion=1 AND @Accion='INSERTAR') 
	OR (@Exportacion=1 AND @Accion='ACTUALIZAR' AND 
	NOT UPDATE(Valor_Resumen) AND
	NOT UPDATE(Valor_Firma) AND
	NOT UPDATE(Cod_EstadoComprobante) AND
    NOT UPDATE(Id_Cliente) AND
	NOT UPDATE(Id_GuiaRemision)
	))
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_I '+ 
			  CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			  CASE WHEN CP.Cod_Periodo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Periodo,'''','')+''',' END +
			  CASE WHEN CP.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Caja,'''','')+''',' END +
			  CASE WHEN CP.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Turno,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoOperacion,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			  CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			  CASE WHEN CP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN CP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Doc_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nom_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Direccion_Cliente,'''','')+''',' END +
			  CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision,121)+''','END+ 
			  CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento,121)+''','END+ 
			  CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion,121)+''','END+ 
			  CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Glosa,'''','')+''',' END +
			  CASE WHEN CP.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.TipoCambio)+','END+
			  CONVERT(VARCHAR(MAX),CP.Flag_Anulado)+','+ 
			  CONVERT(VARCHAR(MAX),CP.Flag_Despachado)+','+ 
			  CASE WHEN CP.Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_FormaPago,'''','')+''',' END +
			  CASE WHEN CP.Descuento_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Descuento_Total)+','END+
			  CASE WHEN CP.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Moneda,'''','')+''',' END +
			  CASE WHEN CP.Impuesto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Impuesto)+','END+
			  CASE WHEN CP.Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Total)+','END+
			  CASE WHEN CP.Obs_Comprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(NVARCHAR(MAX),CP.Obs_Comprobante),'''','')+''','END+
			  CASE WHEN CP.Id_GuiaRemision IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Id_GuiaRemision)+','END+
			  CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.GuiaRemision,'''','')+''','END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Plantilla,'''','')+''',' END +
			  CASE WHEN CP.Nro_Ticketera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_Ticketera,'''','')+''',' END +
			  CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_UsuarioVendedor,'''','')+''',' END +
			  CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_RegimenPercepcion,'''','')+''',' END +
			  CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
			  CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( CP.Placa_Vehiculo,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoDocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDocReferencia,'''','')+''',' END +
			  CASE WHEN CP.Nro_DocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_DocReferencia,'''','')+''',' END +
			  CASE WHEN CP.Valor_Resumen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Resumen,'''','')+''',' END +
			  CASE WHEN CP.Valor_Firma IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Firma,'''','')+''',' END +
			  CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_EstadoComprobante,'''','')+''',' END +
			  CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.MotivoAnulacion,'''','')+''',' END +
			  CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
			  CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
			  ''''+REPLACE(COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg),'''','')+ ''';' 	 
			  FROM            INSERTED   CP 
			  WHERE CP.id_ComprobantePago=@id_ComprobantePago


		   	SET @FechaReg= GETDATE()
			INSERT dbo.TMP_REGISTRO_LOG
			(
			   --Id,
			   Nombre_Tabla,
			   Id_Fila,
			   Accion,
			   Script,
			   Fecha_Reg
		     )
		    VALUES
			(
			   --NULL, -- Id - uniqueidentifier
			   @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END 

    IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			 SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_D '+ 
			 CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			 CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			 CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			 CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			 ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 	 
			 FROM            DELETED  CP 
			 WHERE CP.id_ComprobantePago=@id_ComprobantePago
		   	    SET @FechaReg= GETDATE()
			    INSERT dbo.TMP_REGISTRO_LOG
			    (
				  --Id,
				  Nombre_Tabla,
				  Id_Fila,
				  Accion,
				  Script,
				  Fecha_Reg
			    )
			   VALUES
			    (
				  --NULL, -- Id - uniqueidentifier
				  @NombreTabla, -- Nombre_Tabla - varchar
				  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
				  @Accion, -- Accion - varchar
				  @Script, -- Script - varchar
				  @FechaReg -- Fecha_Reg - datetime
			    )
			 FETCH NEXT FROM cursorbd INTO
			   @id_ComprobantePago,
			   @Fecha_Reg,
			   @Fecha_Act
		    END
		    CLOSE cursorbd;
    		DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.Cod_Libro,
			 i.Cod_Periodo,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Cod_TipoOperacion,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Numero,
			 i.Id_Cliente,
			 i.Cod_TipoDoc,
			 i.Doc_Cliente,
			 i.Nom_Cliente,
			 i.Direccion_Cliente,
			 i.FechaEmision,
			 i.FechaVencimiento,
			 i.FechaCancelacion,
			 i.Glosa,
			 i.TipoCambio,
			 i.Flag_Anulado,
			 i.Flag_Despachado,
			 i.Cod_FormaPago,
			 i.Descuento_Total,
			 i.Cod_Moneda,
			 i.Impuesto,
			 i.Total,
			 i.Obs_Comprobante,
			 i.Id_GuiaRemision,
			 i.GuiaRemision,
			 i.id_ComprobanteRef,
			 i.Cod_Plantilla,
			 i.Nro_Ticketera,
			 i.Cod_UsuarioVendedor,
			 i.Cod_RegimenPercepcion,
			 i.Tasa_Percepcion,
			 i.Placa_Vehiculo,
			 i.Cod_TipoDocReferencia,
			 i.Nro_DocReferencia,
			 i.Valor_Resumen,
			 i.Valor_Firma,
			 i.Cod_EstadoComprobante,
			 i.MotivoAnulacion,
			 i.Otros_Cargos,
			 i.Otros_Tributos,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(nvarchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Actualizacion y eliminacion
    IF  @Accion = 'ELIMINAR' OR
		(@Accion =  'ACTUALIZAR' AND 
		NOT UPDATE(Valor_Resumen) AND
		NOT UPDATE(Valor_Firma) AND
		NOT UPDATE(Cod_EstadoComprobante) AND
		NOT UPDATE(Id_Cliente) AND
		NOT UPDATE(Id_GuiaRemision))
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.Cod_Libro,
			 d.Cod_Periodo,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Cod_TipoOperacion,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Numero,
			 d.Id_Cliente,
			 d.Cod_TipoDoc,
			 d.Doc_Cliente,
			 d.Nom_Cliente,
			 d.Direccion_Cliente,
			 d.FechaEmision,
			 d.FechaVencimiento,
			 d.FechaCancelacion,
			 d.Glosa,
			 d.TipoCambio,
			 d.Flag_Anulado,
			 d.Flag_Despachado,
			 d.Cod_FormaPago,
			 d.Descuento_Total,
			 d.Cod_Moneda,
			 d.Impuesto,
			 d.Total,
			 d.Obs_Comprobante,
			 d.Id_GuiaRemision,
			 d.GuiaRemision,
			 d.id_ComprobanteRef,
			 d.Cod_Plantilla,
			 d.Nro_Ticketera,
			 d.Cod_UsuarioVendedor,
			 d.Cod_RegimenPercepcion,
			 d.Tasa_Percepcion,
			 d.Placa_Vehiculo,
			 d.Cod_TipoDocReferencia,
			 d.Nro_DocReferencia,
			 d.Valor_Resumen,
			 d.Valor_Firma,
			 d.Cod_EstadoComprobante,
			 d.MotivoAnulacion,
			 d.Otros_Cargos,
			 d.Otros_Tributos,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(nvarchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO