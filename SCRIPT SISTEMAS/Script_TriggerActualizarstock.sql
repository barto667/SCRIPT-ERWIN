--CAJ_COMPROBANTE_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_D_IUD_ActualizarStock'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_D_IUD_ActualizarStock
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_D_IUD_ActualizarStock
ON dbo.CAJ_COMPROBANTE_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @id_Detalle int
	DECLARE @Id_Producto int
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Despachado numeric(38,6)
	--Variable extra de caj_comprobante
	DECLARE @Cod_Libro varchar(5)
	--Variables generales
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Fecha_Reg datetime

	--Variables generales
	DECLARE @Accion varchar(MAX)
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
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT DISTINCT
			 i.id_ComprobantePago,
			 i.id_Detalle,
			 i.Id_Producto,
			 i.Cod_Almacen,
			 i.Cod_UnidadMedida,
			 i.Despachado,
			 ccp.Cod_Libro,
			 i.Cod_UsuarioReg
		  FROM INSERTED i INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON i.id_ComprobantePago = ccp.id_ComprobantePago
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @id_Detalle,
			 @Id_Producto,
			 @Cod_Almacen,
			 @Cod_UnidadMedida,
			 @Despachado,
			 @Cod_Libro,
			 @Cod_UsuarioReg
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  UPDATE dbo.PRI_PRODUCTO_STOCK
		  SET
			  dbo.PRI_PRODUCTO_STOCK.Stock_Act +=  CASE WHEN @Cod_Libro='14' THEN (-1)*@Despachado WHEN @Cod_Libro='08' THEN @Despachado ELSE 0 END,
			  dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = @Cod_UsuarioReg,dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
		  WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto = @Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen

		FETCH NEXT FROM cursorbd INTO 
			@id_ComprobantePago,
			@id_Detalle,
			@Id_Producto,
			@Cod_Almacen,
			@Cod_UnidadMedida,
			@Despachado,
			@Cod_Libro,
			@Cod_UsuarioReg
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Eliminacion
    IF @Accion ='ELIMINAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT DISTINCT
			 d.id_ComprobantePago,
			 d.id_Detalle,
			 d.Id_Producto,
			 d.Cod_Almacen,
			 d.Cod_UnidadMedida,
			 d.Despachado,
			 ccp.Cod_Libro
		  FROM DELETED d INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON d.id_ComprobantePago = ccp.id_ComprobantePago
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			@id_ComprobantePago,
			@id_Detalle,
			@Id_Producto,
			@Cod_Almacen,
			@Cod_UnidadMedida,
			@Despachado,
			@Cod_Libro
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  UPDATE dbo.PRI_PRODUCTO_STOCK
		  SET
			  dbo.PRI_PRODUCTO_STOCK.Stock_Act += CASE WHEN @Cod_Libro='14' THEN @Despachado WHEN @Cod_Libro='08' THEN (-1)*@Despachado ELSE 0 END,
			  dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = 'TRIGGER',dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
		  WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto = @Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen
		  FETCH NEXT FROM cursorbd INTO
			@id_ComprobantePago,
			@id_Detalle,
			@Id_Producto,
			@Cod_Almacen,
			@Cod_UnidadMedida,
			@Despachado,
			@Cod_Libro
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
	--Actualziacion
	IF @Accion ='ACTUALIZAR'
		BEGIN
			IF UPDATE(Despachado)
			BEGIN
				DECLARE cursorbd CURSOR LOCAL FOR
				SELECT DISTINCT
				 d.id_ComprobantePago,
				 d.id_Detalle,
				 d.Id_Producto,
				 d.Cod_Almacen,
				 d.Cod_UnidadMedida,
				 d.Despachado-i.Despachado,
				 ccp.Cod_Libro,
				 i.Cod_UsuarioAct
				FROM DELETED d INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON d.id_ComprobantePago = ccp.id_ComprobantePago
				INNER JOIN INSERTED i ON i.id_ComprobantePago=d.id_ComprobantePago AND i.id_Detalle=d.id_Detalle
				OPEN cursorbd 
				FETCH NEXT FROM cursorbd INTO 
					@id_ComprobantePago,
					@id_Detalle,
					@Id_Producto,
					@Cod_Almacen,
					@Cod_UnidadMedida,
					@Despachado,
					@Cod_Libro,
					@Cod_UsuarioReg
				WHILE @@FETCH_STATUS = 0
				BEGIN
				  UPDATE dbo.PRI_PRODUCTO_STOCK
				  SET
					  dbo.PRI_PRODUCTO_STOCK.Stock_Act +=  CASE WHEN @Cod_Libro='14' THEN @Despachado WHEN @Cod_Libro='08' THEN (-1)*@Despachado ELSE 0 END,
					  dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = @Cod_UsuarioReg,dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
				  WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto = @Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen
				  FETCH NEXT FROM cursorbd INTO
					@id_ComprobantePago,
					@id_Detalle,
					@Id_Producto,
					@Cod_Almacen,
					@Cod_UnidadMedida,
					@Despachado,
					@Cod_Libro,
					@Cod_UsuarioReg
				END
				CLOSE cursorbd;
    			DEALLOCATE cursorbd	
			END
		END
END
GO
--ALM_ALMACEN_MOV_D
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_ALM_ALMACEN_MOV_D_IUD_ActualizarStock'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_ALM_ALMACEN_MOV_D_IUD_ActualizarStock
GO

CREATE TRIGGER UTR_ALM_ALMACEN_MOV_D_IUD_ActualizarStock
ON dbo.ALM_ALMACEN_MOV_D
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_AlmacenMov int
	DECLARE @Item int
	DECLARE @Id_Producto int
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cantidad numeric(38,6)
	--Variables auxiliares de alm_almacen_mov
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Cod_UsuarioReg varchar(32)
	--Variables Generales
	
	DECLARE @Accion varchar(MAX)

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

    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT DISTINCT
			 i.Id_AlmacenMov,
			 i.Item,
			 i.Id_Producto,
			 i.Cod_UnidadMedida,
			 i.Cantidad,
			 aam.Cod_Almacen,
			 aam.Cod_TipoComprobante,
			 i.Cod_UsuarioReg
		  FROM INSERTED i INNER JOIN dbo.ALM_ALMACEN_MOV aam ON aam.Id_AlmacenMov=i.Id_AlmacenMov
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cantidad,
			 @Cod_Almacen,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			 UPDATE dbo.PRI_PRODUCTO_STOCK
			 SET
				dbo.PRI_PRODUCTO_STOCK.Stock_Act += CASE WHEN @Cod_TipoComprobante='NS' THEN (-1)*@Cantidad WHEN @Cod_TipoComprobante='NE' THEN @Cantidad ELSE 0 END ,
				dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = @Cod_UsuarioReg, dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
			 WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto=@Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen
		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cantidad,
			 @Cod_Almacen,
			 @Cod_TipoComprobante,
			 @Cod_UsuarioReg
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Eliminar
    IF @Accion = 'ELIMINAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_AlmacenMov,
			 d.Item,
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 d.Cantidad,
			 aam.Cod_Almacen,
			 aam.Cod_TipoComprobante
		  FROM DELETED d INNER JOIN dbo.ALM_ALMACEN_MOV aam ON aam.Id_AlmacenMov=d.Id_AlmacenMov
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cantidad,
			 @Cod_Almacen,
			 @Cod_TipoComprobante
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  UPDATE dbo.PRI_PRODUCTO_STOCK
			 SET
				dbo.PRI_PRODUCTO_STOCK.Stock_Act += CASE WHEN @Cod_TipoComprobante='NS' THEN @Cantidad WHEN @Cod_TipoComprobante='NE' THEN (-1)*@Cantidad ELSE 0 END ,
				dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = 'TRIGGER', dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
			 WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto=@Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen
		  FETCH NEXT FROM cursorbd INTO
			 @Id_AlmacenMov,
			 @Item,
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cantidad,
			 @Cod_Almacen,
			 @Cod_TipoComprobante
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
	--Actualizar
    IF @Accion = 'ACTUALIZAR'
	 BEGIN
	    IF UPDATE(Cantidad)
		BEGIN
			DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_AlmacenMov,
			 d.Item,
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 i.Cantidad-d.Cantidad,
			 aam.Cod_Almacen,
			 aam.Cod_TipoComprobante,
			 i.Cod_UsuarioAct
		  FROM DELETED d INNER JOIN dbo.ALM_ALMACEN_MOV aam ON aam.Id_AlmacenMov=d.Id_AlmacenMov
		  INNER JOIN INSERTED i ON i.Id_AlmacenMov=d.Id_AlmacenMov AND i.Item=d.Item
			OPEN cursorbd 
			FETCH NEXT FROM cursorbd INTO 
				 @Id_AlmacenMov,
				 @Item,
				 @Id_Producto,
				 @Cod_UnidadMedida,
				 @Cantidad,
				 @Cod_Almacen,
				 @Cod_TipoComprobante,
				 @Cod_UsuarioReg
			WHILE @@FETCH_STATUS = 0
			BEGIN
			  UPDATE dbo.PRI_PRODUCTO_STOCK
				 SET
					dbo.PRI_PRODUCTO_STOCK.Stock_Act += CASE WHEN @Cod_TipoComprobante='NS' THEN @Cantidad WHEN @Cod_TipoComprobante='NE' THEN (-1)*@Cantidad ELSE 0 END ,
					dbo.PRI_PRODUCTO_STOCK.Cod_UsuarioAct = @Cod_UsuarioReg, dbo.PRI_PRODUCTO_STOCK.Fecha_Act=GETDATE()
				 WHERE dbo.PRI_PRODUCTO_STOCK.Id_Producto=@Id_Producto AND dbo.PRI_PRODUCTO_STOCK.Cod_UnidadMedida=@Cod_UnidadMedida AND dbo.PRI_PRODUCTO_STOCK.Cod_Almacen=@Cod_Almacen
			  FETCH NEXT FROM cursorbd INTO
				 @Id_AlmacenMov,
				 @Item,
				 @Id_Producto,
				 @Cod_UnidadMedida,
				 @Cantidad,
				 @Cod_Almacen,
				 @Cod_TipoComprobante,
				 @Cod_UsuarioReg
			END
			CLOSE cursorbd;
    		DEALLOCATE cursorbd
		END
     END
END
GO