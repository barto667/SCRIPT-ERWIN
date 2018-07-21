

-- RESTAURANTE

--MODIFICADORES

EXEC USP_PAR_TABLA_G'122','MODIFICADORES','Almacena los modificadores de los productos','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','001','Nom_Modificador','Nombre del Modificador','CADENA',0,64,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','002','Id_Producto','Id de Producto','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','003','Nom_Producto','Nombre del Producto','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','004','Precio','Precio adicional si se necesita','NUMERO',0,2,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','005','Cod_UnidadMedida','Codigo de unidad de medida','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'122','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'122';
GO
EXEC USP_PAR_TABLA_G'123','PRODUCTO_MODIFICADOR','Almacena los productos de un modificadores','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','001','Nom_Modificador','Nombre del Modificador','CADENA',0,64,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','002','Id_Producto','Id de Producto','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','003','Nom_Etiqueta','Nombre de la etiqueta','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','004','Valor_Minimo','Valor Minimo que se requiere','NUMERO',0,0,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','005','Valor_Maximo','Valor solicitado: 0 es obligatorio, 1 es opcional, mayor a 1 cantidad a escojer','NUMERO',0,0,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'123','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'123';
GO

--MODIFICADORES
--VIS_MODIFICADORES
-- GUARDAR 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_MODIFICADORES_G' AND type = 'P')
DROP PROCEDURE USP_VIS_MODIFICADORES_G
go
CREATE PROCEDURE USP_VIS_MODIFICADORES_G 
@Nom_Modificador varchar(64), 
@Id_Producto int, 
@Nom_Producto varchar(512), 
@Precio numeric(38,2),
@Cod_UnidadMedida varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro AS INT;

IF NOT EXISTS (SELECT Nro FROM VIS_MODIFICADORES WHERE  (Nom_Modificador = @Nom_Modificador AND Nom_Producto=@Nom_Producto))
BEGIN
-- Calcular el ultimo el elemento ingresado para este tabla
SET @Nro = (SELECT ISNULL(MAX(Nro),0) + 1 FROM VIS_MODIFICADORES)
EXEC USP_PAR_FILA_G '122','001',@Nro,@Nom_Modificador,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','002',@Nro,@Id_Producto,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','003',@Nro,@Nom_Producto,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','004',@Nro,NULL,@Precio,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','005',@Nro,@Cod_UnidadMedida,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
ELSE
BEGIN
SET @Nro = (SELECT Nro FROM VIS_MODIFICADORES WHERE  (Nom_Modificador = @Nom_Modificador AND Nom_Producto=@Nom_Producto))
EXEC USP_PAR_FILA_G '122','001',@Nro,@Nom_Modificador,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','002',@Nro,@Id_Producto,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','003',@Nro,@Nom_Producto,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','004',@Nro,NULL,@Precio,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','005',@Nro,@Cod_UnidadMedida,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '122','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
END
GO

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_MODIFICADORES_E' AND type = 'P')
DROP PROCEDURE USP_VIS_MODIFICADORES_E
go
CREATE PROCEDURE USP_VIS_MODIFICADORES_E 
@Nom_Modificador varchar(max),
@Nom_Producto varchar(512) 
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro int
IF  EXISTS (SELECT Nro FROM VIS_MODIFICADORES WHERE (Nom_Modificador = @Nom_Modificador AND Nom_Producto=@Nom_Producto))
BEGIN
    SET @Nro = (SELECT DISTINCT Nro FROM VIS_MODIFICADORES WHERE  (Nom_Modificador = @Nom_Modificador AND Nom_Producto=@Nom_Producto))
    EXEC USP_PAR_FILA_E '122','001',@Nro;
    EXEC USP_PAR_FILA_E '122','002',@Nro;
    EXEC USP_PAR_FILA_E '122','003',@Nro;
    EXEC USP_PAR_FILA_E '122','004',@Nro;
    EXEC USP_PAR_FILA_E '122','005',@Nro;
    EXEC USP_PAR_FILA_E '122','006',@Nro;
END
END
go

--VIS_PRODUCTO_MODIFICADOR
-- GUARDAR 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PRODUCTO_MODIFICADOR_G' AND type = 'P')
DROP PROCEDURE USP_VIS_PRODUCTO_MODIFICADOR_G
go
CREATE PROCEDURE USP_VIS_PRODUCTO_MODIFICADOR_G 
@Nom_Modificador varchar(64), 
@Id_Producto int, 
@Nom_Etiqueta varchar(max),
@Valor_Minimo numeric(38,6),
@Valor_Maximo numeric(38,6)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro AS INT;

IF NOT EXISTS (SELECT Nro FROM VIS_PRODUCTO_MODIFICADOR WHERE  (Nom_Modificador = @Nom_Modificador AND @Id_Producto=Id_Producto))
BEGIN
-- Calcular el ultimo el elemento ingresado para este tabla
SET @Nro = (SELECT ISNULL(MAX(Nro),0) + 1 FROM VIS_PRODUCTO_MODIFICADOR)
EXEC USP_PAR_FILA_G '123','001',@Nro,@Nom_Modificador,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','002',@Nro,@Id_Producto,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','003',@Nro,@Nom_Etiqueta,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','004',@Nro,NULL,@Valor_Minimo,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','005',@Nro,NULL,@Valor_Maximo,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
ELSE
BEGIN
SET @Nro = (SELECT Nro FROM VIS_PRODUCTO_MODIFICADOR WHERE  (Nom_Modificador = @Nom_Modificador AND @Id_Producto=Id_Producto))
EXEC USP_PAR_FILA_G '123','003',@Nro,@Nom_Etiqueta,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','004',@Nro,NULL,@Valor_Minimo,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','005',@Nro,NULL,@Valor_Maximo,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '123','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
END
GO

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'VIS_PRODUCTO_MODIFICADOR_E' AND type = 'P')
DROP PROCEDURE VIS_PRODUCTO_MODIFICADOR_E
go
CREATE PROCEDURE VIS_PRODUCTO_MODIFICADOR_E 
@Nom_Modificador varchar(64), 
@Id_Producto int
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro int
IF  EXISTS (SELECT Nro FROM VIS_PRODUCTO_MODIFICADOR  WHERE  (Nom_Modificador = @Nom_Modificador AND @Id_Producto=Id_Producto))
BEGIN
    SET @Nro = (SELECT DISTINCT Nro FROM VIS_PRODUCTO_MODIFICADOR WHERE (Nom_Modificador = @Nom_Modificador AND @Id_Producto=Id_Producto))
    EXEC USP_PAR_FILA_E '123','001',@Nro;
    EXEC USP_PAR_FILA_E '123','002',@Nro;
    EXEC USP_PAR_FILA_E '123','003',@Nro;
    EXEC USP_PAR_FILA_E '123','004',@Nro;
    EXEC USP_PAR_FILA_E '123','005',@Nro;
    EXEC USP_PAR_FILA_E '123','006',@Nro;
END
END
GO


--Obtiene las mesas ocupadas y sus comandas relacionadas
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_ObtenerMesasOcupadas' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_ObtenerMesasOcupadas
GO

CREATE PROCEDURE USP_VIS_MESAS_ObtenerMesasOcupadas
@Modo int = 0
WITH ENCRYPTION
AS
BEGIN
    --Por el momento dos modos: 
    --"0" modo normal
    --"1" modo comandero
    IF(@Modo=0)
    BEGIN
	   --Se identifica la orden de comanda CO cuando no esta tendida, es decir no tiene cod_caja (null) ni cod_turno(null)
	   SELECT * FROM (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad>0
	   UNION
	   SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND  ccd.Formalizado!=ccd.Cantidad AND ccd.IGV=0
	   AND ccd.Cantidad>0
	   ) a
	   ORDER BY a.Nom_Mesa,a.Fecha_Reg
    END
    IF(@Modo=1)
    BEGIN
	   SELECT  Mesas.Cod_Mesa,Mesas.Nom_Mesa,ISNULL(Ocupados.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,ISNULL(Ocupados.id_ComprobantePago,0) id_ComprobantePago,Ocupados.Fecha_Reg FROM 
	   (SELECT vm.Cod_Mesa ,vm.Nom_Mesa,NULL Cod_UsuarioVendedor,NULL id_ComprobantePago,NULL Fecha_Reg
	   FROM dbo.VIS_MESAS vm ) Mesas LEFT JOIN 
	   (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad>0
	   UNION
	   SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND  ccd.Formalizado!=ccd.Cantidad AND ccd.IGV=0 AND ccd.Cantidad>0) Ocupados
	   ON Mesas.Cod_Mesa=Ocupados.Cod_Mesa
	   ORDER BY Mesas.Cod_Mesa,Mesas.Fecha_Reg
    END
END
GO

--Obtiene los items de un comprobante por id
--solo aquellos que no son componentes, sino productos
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_ObtenerDetallesComprobante' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_ObtenerDetallesComprobante
GO

CREATE PROCEDURE USP_VIS_MESAS_ObtenerDetallesComprobante
	@Id_ComprobantePago int
  WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT
       ccd.id_ComprobantePago,
       ccd.id_Detalle,
       ccd.Id_Producto,
       ccd.Cod_Almacen,
       (ccd.Cantidad - ccd.Formalizado) Cantidad,
       ccd.Cod_UnidadMedida,
       ccd.Despachado,
       ccd.Descripcion,
       ccd.PrecioUnitario,
       ccd.Descuento,
       ccd.Sub_Total,
       ccd.Tipo,
       ccd.Obs_ComprobanteD,
       ccd.Cod_Manguera,
       ccd.Flag_AplicaImpuesto,
       ccd.Formalizado,
       ccd.Valor_NoOneroso,
       ccd.Cod_TipoISC,
       ccd.Porcentaje_ISC,
       ccd.ISC,
       ccd.Cod_TipoIGV,
       ccd.Porcentaje_IGV,
       ccd.IGV,
       ccd.Cod_UsuarioReg,
       ccd.Fecha_Reg,
       ccd.Cod_UsuarioAct,
       ccd.Fecha_Act
	FROM dbo.CAJ_COMPROBANTE_D ccd 
	WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.IGV=0
	AND ccd.Cantidad>ccd.Formalizado
	ORDER BY ccd.Descripcion
END
GO


--Elimina un item de la comanda
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESA_EliminarItemComanda' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESA_EliminarItemComanda
GO

CREATE PROCEDURE USP_VIS_MESA_EliminarItemComanda
	@Id_ComprobantePago int,
	@Id_Detalle int,
	@Justificacion varchar(max),
	@Cod_Usuario varchar(max)
  WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Recuperamos el total de dicha item, el impuesto 
	   DECLARE @TotalItem numeric(38,6)=(SELECT ccd.Cantidad * ccd.PrecioUnitario FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@Id_Detalle)
	   DECLARE @CodMesa varchar(max)=(SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE @Id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@Id_Detalle)
	   --ELiminamos el detalle y sus detalles hijos
	   DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_Detalle
	   DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.IGV=@Id_Detalle
	   --Restamos al total de la comanda el total del item y su impuesto
	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
	   dbo.CAJ_COMPROBANTE_PAGO.Total=dbo.CAJ_COMPROBANTE_PAGO.Total-@TotalItem
	   --Verificamos que dicha comanda tenga items, si los tiene no hacemos nada, caso contraio eliminamos la comanda
	   IF NOT EXISTS(SELECT ccd.* FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobantePago) 
	   BEGIN 
		  --Eliminamos la comanda
		  DELETE dbo.CAJ_COMPROBANTE_PAGO WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_ComprobantePago
		  --Si eliminamos la comanda, entonces verificamos que la mesa aun este ocupada, si no es asi liberamos la mesa
		  IF	NOT EXISTS(SELECT DISTINCT ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
		  WHERE ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccp.Cod_TipoComprobante='CO' AND ccd.Cod_Manguera=@CodMesa)
		  BEGIN
			 --Liberamos la mesa
			 EXEC USP_VIS_MESAS_GXEstado @CodMesa,'LIBRE',@Cod_usuario
		  END

	   END
	   --Introducimos la justificacion

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
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESA_IncrementarDisminuirCantidadItemComanda' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESA_IncrementarDisminuirCantidadItemComanda
GO

CREATE PROCEDURE USP_VIS_MESA_IncrementarDisminuirCantidadItemComanda
	@Id_ComprobantePago int,
	@Id_Detalle int,
	@Valor numeric(38,6),
	@Cod_Usuario varchar(max)
  WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Agregamos o disminuimos de acuerdo a la cantidad un determiando valor al detalle
	   DECLARE @Cantidad numeric(38,6)
	   DECLARE @PU numeric(38,6)
	   SELECT @Cantidad=ccd.Cantidad,@PU=ccd.PrecioUnitario FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@Id_Detalle
	   --Actualizamos la cabezera, si tiene referencia tambien se tienen que actualziar

	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	       dbo.CAJ_COMPROBANTE_D.Cantidad=dbo.CAJ_COMPROBANTE_D.Cantidad+@Valor,
		  dbo.CAJ_COMPROBANTE_D.Sub_Total=(dbo.CAJ_COMPROBANTE_D.Cantidad+@Valor)*dbo.CAJ_COMPROBANTE_D.PrecioUnitario
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_Detalle

	   --Actualizamos los subdetalles si lo tuviera
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	       dbo.CAJ_COMPROBANTE_D.Cantidad=dbo.CAJ_COMPROBANTE_D.Cantidad+@Valor,
		  dbo.CAJ_COMPROBANTE_D.Sub_Total=(dbo.CAJ_COMPROBANTE_D.Cantidad+@Valor)*dbo.CAJ_COMPROBANTE_D.PrecioUnitario
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.IGV=@Id_Detalle

	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
	       dbo.CAJ_COMPROBANTE_PAGO.Total= dbo.CAJ_COMPROBANTE_PAGO.Total + (@Valor*@PU)
	   WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_ComprobantePago
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
GO


--Trae los modificadores disponibles por producto
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerMdificadoresXIdProducto' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerMdificadoresXIdProducto
  
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerMdificadoresXIdProducto
	@Id_Producto int
 WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT vpm.Nom_Modificador,vpm.Nom_Etiqueta,vpm.Valor_Minimo,vpm.Valor_Maximo FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.VIS_PRODUCTO_MODIFICADOR vpm 
    ON pp.Id_Producto = vpm.Id_Producto WHERE vpm.Estado=1
    AND pp.Id_Producto=@Id_Producto
END
GO
--Trae una lista de nombres disponibles
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerNombresModificadores' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerNombresModificadores
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerNombresModificadores
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT vm.Nom_Modificador FROM dbo.VIS_MODIFICADORES vm
END

GO

--Obtiene el detalle de la recaion entre un producto y un modificador
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerRelacionModificadorXIdProducto_NomModificador' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerRelacionModificadorXIdProducto_NomModificador
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerRelacionModificadorXIdProducto_NomModificador
@Id_Producto int,
@Nom_Modificador varchar(max)
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT vpm.* FROM dbo.VIS_PRODUCTO_MODIFICADOR vpm
    WHERE vpm.Nom_Modificador=@Nom_Modificador AND vpm.Id_Producto=@Id_Producto
END

GO
--Trae todos los detalles de un modificador
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerModificadorXNombre' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerModificadorXNombre
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerModificadorXNombre
@Nom_Modificador varchar(max)
WITH ENCRYPTION
AS
BEGIN
    SELECT vm.* FROM dbo.VIS_MODIFICADORES vm WHERE vm.Nom_Modificador=@Nom_Modificador
END

GO
--Trae los productos que tienen relacion con el modificador predeterminado
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTO_TraerProductosXModificador' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTO_TraerProductosXModificador
GO

CREATE PROCEDURE USP_PRI_PRODUCTO_TraerProductosXModificador
@Nom_Modificador varchar(max)
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT pp.Id_Producto, pp.Cod_Producto, pp.Cod_Categoria, pp.Cod_Marca, 
    pp.Cod_TipoProducto, pp.Nom_Producto, pp.Des_CortaProducto, pp.Des_LargaProducto, 
    pp.Caracteristicas, pp.Porcentaje_Utilidad, pp.Cuenta_Contable, pp.Contra_Cuenta, 
    pp.Cod_Garantia, pp.Cod_TipoExistencia, pp.Cod_TipoOperatividad, pp.Flag_Activo, 
    pp.Flag_Stock, pp.Cod_Fabricante,CAST(pp.Obs_Producto AS varchar(max)) AS Obs_Producto, pp.Cod_UsuarioReg, pp.Fecha_Reg, 
    pp.Cod_UsuarioAct, pp.Fecha_Act 
    FROM dbo.VIS_PRODUCTO_MODIFICADOR vpm INNER JOIN dbo.PRI_PRODUCTOS pp 
    ON vpm.Id_Producto = pp.Id_Producto WHERE vpm.Nom_Modificador=@Nom_Modificador
END

GO

-- OBJETIVO: Recuperar los detalles de un producto
-- EXEC USP_PRI_PRODUCTO_DETALLE 254
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_DETALLE' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE
go
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE
@Id_Producto int
WITH ENCRYPTION
AS
BEGIN

SELECT 
vpm.Id_Producto Id_Producto_Padre,
ROW_NUMBER() OVER (ORDER BY vpm.Nom_Modificador) Item_Detalle,
ISNULL(vm.Id_Producto,0),
vpm.Nom_Etiqueta Cod_TipoProducto,
vpm.Nom_Modificador Cod_TipoDetalle,
vm.Nom_Producto Nom_Producto,
vpm.Valor_Maximo CantidadMax_Grupo,
vm.Precio PrecioUnitario,
vpm.Valor_Minimo ValorMinimo,
pp.Cod_TipoOperatividad,
pp.Cod_Categoria,
pps.Cod_Almacen,
vm2.Cod_Moneda,
vm2.Nom_Moneda,
vm2.Simbolo,
vm2.Definicion
FROM dbo.VIS_PRODUCTO_MODIFICADOR vpm 
INNER JOIN dbo.VIS_MODIFICADORES vm ON vpm.Nom_Modificador = vm.Nom_Modificador
INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Id_Producto = pp.Id_Producto 
INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
INNER JOIN dbo.VIS_MONEDAS vm2 ON pps.Cod_Moneda = vm2.Cod_Moneda
WHERE vpm.Id_Producto=@Id_Producto

UNION 

SELECT 
pp.Id_Producto Id_Producto_Padre,
ROW_NUMBER() OVER (ORDER BY vpm.Nom_Modificador) Item_Detalle,
vm.Id_Producto,
vpm.Nom_Etiqueta Cod_TipoProducto,
vpm.Nom_Modificador Cod_TipoDetalle,
vm.Nom_Producto Nom_Producto,
vpm.Valor_Maximo CantidadMax_Grupo,
vm.Precio PrecioUnitario,
vpm.Valor_Minimo ValorMinimo,
pp.Cod_TipoOperatividad,
pp.Cod_Categoria,
pps.Cod_Almacen,
vm2.Cod_Moneda,
vm2.Nom_Moneda,
vm2.Simbolo,
vm2.Definicion
FROM dbo.PRI_PRODUCTOS pp 
INNER JOIN dbo.VIS_PRODUCTO_MODIFICADOR vpm ON pp.Id_Producto = vpm.Id_Producto
INNER JOIN dbo.VIS_MODIFICADORES vm ON vpm.Nom_Modificador = vm.Nom_Modificador
INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
INNER JOIN dbo.VIS_MONEDAS vm2 ON pps.Cod_Moneda = vm2.Cod_Moneda
WHERE pp.Id_Producto=@Id_Producto

END
GO



--Formaliza un detalle de un comprobante por la cantidad descrita
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_D_FormalizarDetalle' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_D_FormalizarDetalle
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_FormalizarDetalle
@Id_ComprobantePagoInicial int,
@Id_DetalleInicial int,
@Valor numeric(38,6),
@Id_ComprobantePagoFormalizado int,
@Id_DetalleFormalizado int,
@Cod_Usuario varchar(max)
WITH ENCRYPTION
AS
BEGIN
    --Editamos el fromalizado
    UPDATE dbo.CAJ_COMPROBANTE_D
    SET
        dbo.CAJ_COMPROBANTE_D.Formalizado = CASE WHEN @Valor<=(dbo.CAJ_COMPROBANTE_D.Cantidad-dbo.CAJ_COMPROBANTE_D.Formalizado) THEN @Valor + dbo.CAJ_COMPROBANTE_D.Formalizado  ELSE dbo.CAJ_COMPROBANTE_D.Cantidad END,
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@Cod_Usuario,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
    WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComprobantePagoInicial AND
    dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_DetalleInicial
    --Agregamos la formalizacion
    DECLARE @Item int = (SELECT ISNULL(MAX(ccr.Item),0) + 1 FROM dbo.CAJ_COMPROBANTE_RELACION ccr WHERE ccr.id_ComprobantePago=@Id_ComprobantePagoInicial AND ccr.id_Detalle= @Id_DetalleInicial AND ccr.Cod_TipoRelacion='FOR')
    INSERT dbo.CAJ_COMPROBANTE_RELACION
    (
        id_ComprobantePago,
        id_Detalle,
        Item,
        Id_ComprobanteRelacion,
        Cod_TipoRelacion,
        Valor,
        Obs_Relacion,
        Id_DetalleRelacion,
        Cod_UsuarioReg,
        Fecha_Reg
    )

    VALUES
    (
        @Id_ComprobantePagoInicial, -- id_ComprobantePago - int
        @Id_DetalleInicial, -- id_Detalle - int
        @Item, -- Item - int
        @Id_ComprobantePagoFormalizado, -- Id_ComprobanteRelacion - int
        'FOR', -- Cod_TipoRelacion - varchar
        @Valor, -- Valor - numeric
        '', -- Obs_Relacion - varchar
        @Id_DetalleFormalizado, -- Id_DetalleRelacion - int
        @Cod_Usuario, -- Cod_UsuarioAct - varchar
        GETDATE() -- Fecha_Act - datetime
    )
END
GO


--Libera la mesa realcionada al comprobante
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_LiberarMesaXidComanda' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_LiberarMesaXidComanda
GO

CREATE PROCEDURE USP_VIS_MESAS_LiberarMesaXidComanda
	@IdComprobantePago int,
	@CodUsuario varchar(max)
WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Recuperamos la mesa vinculada
	    DECLARE @CodMesa varchar(max)=(SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobantePago )
	   --Verificamos que el comprobante no tenga items por formalizar, si los tiene no hacemos nada
	   IF NOT  EXISTS ( SELECT DISTINCT ccd.* FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobantePago AND ccd.IGV=0 AND ccd.Formalizado!=ccd.Cantidad)
	   BEGIN
		  --Debemos verificar que la mesa no tenga otras comanda
		  IF NOT EXISTS (SELECT DISTINCT ccp.id_ComprobantePago FROM dbo.VIS_MESAS vm INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
		  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		  WHERE ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND vm.Cod_Mesa=@CodMesa AND ccd.id_ComprobantePago!=@IdComprobantePago)
		  BEGIN
			 	--Cambiamos el estado de la mesa a ocupado
				EXEC USP_VIS_MESAS_GXEstado @CodMesa,'LIBRE',@CodUsuario
				UPDATE dbo.CAJ_COMPROBANTE_PAGO
					SET
						dbo.CAJ_COMPROBANTE_PAGO.Flag_Despachado=1 
						WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobantePago
		  END
	   END
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
GO



-- EXEC USP_VIS_MESAS_GXEstado 'M01','OCUPADO','ADMIN'
-- DELETE dbo.CAJ_COMPROBANTE_RELACION
-- DELETE dbo.CAJ_FORMA_PAGO
-- DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago!=1067
-- UPDATE dbo.CAJ_COMPROBANTE_D
-- SET
--    dbo.CAJ_COMPROBANTE_D.Formalizado = 0
--    WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=1067
-- DELETE dbo.CAJ_COMPROBANTE_PAGO WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago!=1067


--Actualzia la informacion del cliente de un comprobante determinado
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosCliente'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosCliente;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosCliente @Id_Comprobante_Pago INT,
                                                                 @Id_ClienteProveedor INT,
                                                                 @Cod_TipoDOcumento   VARCHAR(MAX),
                                                                 @Num_Documento       VARCHAR(MAX),
                                                                 @Nom_Cliente         VARCHAR(MAX),
                                                                 @Direccion           VARCHAR(MAX)
WITH ENCRYPTION
AS
     BEGIN
         UPDATE dbo.CAJ_COMPROBANTE_PAGO
           SET
               dbo.CAJ_COMPROBANTE_PAGO.Id_Cliente = @Id_ClienteProveedor,
               dbo.CAJ_COMPROBANTE_PAGO.Cod_TipoDoc = @Cod_TipoDOcumento,
               dbo.CAJ_COMPROBANTE_PAGO.Doc_Cliente = @Num_Documento,
               dbo.CAJ_COMPROBANTE_PAGO.Nom_Cliente = @Nom_Cliente,
               dbo.CAJ_COMPROBANTE_PAGO.Direccion_Cliente = @Direccion
         WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_Comprobante_Pago;
     END;
GO

--Actualzia la informacion de la comanda como son la caja y el turno
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosComanda'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosComanda;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarDatosComanda @Id_Comprobante_Pago INT,
                                                                 @CodPeriodo   VARCHAR(MAX),
                                                                 @CodCaja       VARCHAR(MAX),
                                                                 @CodTurno         VARCHAR(MAX)
WITH ENCRYPTION
AS
     BEGIN
         UPDATE dbo.CAJ_COMPROBANTE_PAGO
           SET
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Periodo = @CodPeriodo,
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Caja = @CodCaja,
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Turno = @CodTurno
         WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_Comprobante_Pago;
     END;
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOS_TraerAlmacenesXId' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOS_TraerAlmacenesXId
GO

CREATE PROCEDURE USP_PRI_PRODUCTOS_TraerAlmacenesXId
	@Id_Producto int
WITH ENCRYPTION
AS
	SELECT pps.Cod_Almacen,pp.Cod_TipoOperatividad,pps.Cod_UnidadMedida FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
	WHERE pps.Id_Producto=@Id_Producto
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro_CodTipo_Serie_Numero' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro_CodTipo_Serie_Numero
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXCodLibro_CodTipo_Serie_Numero
@Cod_Libro varchar(10),
@Cod_TipoComprobante varchar(10),
@Serie varchar(10),
@Numero varchar(10)
WITH ENCRYPTION
AS
BEGIN
	SELECT ccp.* FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_Libro=@Cod_Libro AND ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Numero=@Numero
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_G_Comanda' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G_Comanda
GO

CREATE PROCEDURE [dbo].[USP_CAJ_COMPROBANTE_PAGO_G_Comanda] 
@Numero	varchar(30), 
@Nom_Cliente	varchar(512), 	
@Cod_Moneda	varchar(3), 	
@Total	numeric(38,2),
@Cod_Usuario Varchar(32) = 'COMANDERO'	

WITH ENCRYPTION
AS
BEGIN

DECLARE @id_ComprobantePago int = 0,
@Cod_Libro	varchar(2) = '14',  
@FechaEmision	datetime = getdate(), 
@Cod_Periodo	varchar =  '', 
@Cod_Caja	varchar(32) = NULL, 
@Cod_Turno	varchar(32) = NULL, 
@Cod_TipoOperacion	varchar(5) = '01', 
@Cod_TipoComprobante	varchar(5) = 'CO', 
@Serie	varchar(5) = '0000', 	 
@Id_Cliente	int = 0, 
@Cod_TipoDoc	varchar(2) = '0', 
@Doc_Cliente	varchar(20) = '', 
@Direccion_Cliente	varchar(512) = '', 	
@FechaVencimiento	datetime = getdate(), 
@FechaCancelacion	datetime = getdate(), 
@Glosa	varchar(512) = 'COMANDA', 
@TipoCambio	numeric(10,4) = 1, 
@Flag_Anulado	bit = 0, 
@Flag_Despachado	bit = 0, 
@Cod_FormaPago	varchar(5) = '004', 
@Descuento_Total	numeric(38,2) = 0.00, 
@Impuesto	numeric(38,6) = 0.00, 
@Obs_Comprobante	xml = NULL, 
@Id_GuiaRemision	int = 0, 
@GuiaRemision	varchar(50) = '', 
@id_ComprobanteRef	int = 0, 
@Cod_Plantilla	varchar(32) = '', 
@Nro_Ticketera	varchar(64) = '', 
@Cod_UsuarioVendedor	varchar(32) = '', 
@Cod_RegimenPercepcion	varchar = NULL, 
@Tasa_Percepcion	numeric(38,2) = 0.00, 
@Placa_Vehiculo	varchar(64) = '', 
@Cod_TipoDocReferencia	varchar = NULL, 
@Nro_DocReferencia	varchar(64) = '', 
@Valor_Resumen	varchar(1024) = NULL, 
@Valor_Firma	varchar(2048) = NULL, 
@Cod_EstadoComprobante	varchar = 'INI', 
@MotivoAnulacion	varchar(512) = '', 
@Otros_Cargos	numeric(38,2) = 0.00, 
@Otros_Tributos	numeric(38,2) = 0.00

-- recuperar el cliente
IF @Nom_Cliente = ''
BEGIN
-- SELECIONAR CLIENTES VARIOS
SET @Id_Cliente = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = 'CLIENTES VARIOS')
SET @Doc_Cliente = (SELECT TOP 1 Nro_Documento FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = 'CLIENTES VARIOS')
SET @Direccion_Cliente = (SELECT TOP 1 Direccion FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = 'CLIENTES VARIOS')
SET @Nom_Cliente = 'CLIENTES VARIOS'
SET @GuiaRemision = 'MANUAL'
END
ELSE
BEGIN	
IF (EXISTS(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = @Nom_Cliente))
BEGIN
SET @Id_Cliente = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = @Nom_Cliente)
SET @Doc_Cliente = (SELECT TOP 1 Nro_Documento FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = @Nom_Cliente)
SET @Direccion_Cliente = (SELECT TOP 1 Direccion FROM PRI_CLIENTE_PROVEEDOR WHERE Cliente = @Nom_Cliente)	
SET @GuiaRemision = 'AUTOMATICO'
END	
END

IF CONVERT(NVARCHAR(MAX),ISNULL(@Obs_Comprobante,'')) = ''
BEGIN
SET @Obs_Comprobante = dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('CAJ_COMPROBANTE_PAGO');
END

IF (@Numero = '' and @Cod_Libro = '14')
begin
set @Numero = (SELECT RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(Numero)),0)+1), 8) 
FROM CAJ_COMPROBANTE_PAGO 
WHERE Cod_TipoComprobante = @Cod_TipoComprobante and Serie=@Serie and Cod_Libro = @Cod_Libro );
end

SET @id_ComprobantePago = 0;

SET @id_ComprobantePago =isnull(( SELECT top 1 ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO WHERE  (Cod_Libro = @Cod_Libro 
AND Cod_TipoComprobante = @Cod_TipoComprobante AND Serie = @Serie AND Numero = @Numero)),0)

IF @id_ComprobantePago = 0
BEGIN	
INSERT INTO CAJ_COMPROBANTE_PAGO  VALUES (
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
@Cod_Usuario,GETDATE(),@Cod_Usuario,NULL)
SET @id_ComprobantePago = @@IDENTITY 
END
ELSE
BEGIN

DELETE FROM CAJ_COMPROBANTE_D WHERE @id_ComprobantePago = @id_ComprobantePago AND Cod_TipoISC = 'PENDI'

UPDATE CAJ_COMPROBANTE_PAGO
SET	
Cod_Libro = @Cod_Libro, 
Cod_Periodo = @Cod_Periodo, 
Cod_Caja = @Cod_Caja, 
Cod_Turno = @Cod_Turno, 
Cod_TipoOperacion = @Cod_TipoOperacion, 
Cod_TipoComprobante = @Cod_TipoComprobante, 
Serie = @Serie, 
Numero = @Numero, 
Id_Cliente = @Id_Cliente, 
Cod_TipoDoc = @Cod_TipoDoc, 
Doc_Cliente = @Doc_Cliente, 
Nom_Cliente = @Nom_Cliente, 
Direccion_Cliente = @Direccion_Cliente, 
FechaEmision = @FechaEmision, 
FechaVencimiento = @FechaVencimiento, 
FechaCancelacion = @FechaCancelacion, 
Glosa = @Glosa, 
TipoCambio = @TipoCambio, 
Flag_Anulado = @Flag_Anulado, 
Flag_Despachado = @Flag_Despachado, 
Cod_FormaPago = @Cod_FormaPago, 
Descuento_Total = @Descuento_Total, 
Cod_Moneda = @Cod_Moneda, 
Impuesto = @Impuesto, 
Total = @Total, 
Obs_Comprobante = @Obs_Comprobante, 
Id_GuiaRemision = @Id_GuiaRemision, 
GuiaRemision = @GuiaRemision, 
id_ComprobanteRef = @id_ComprobanteRef, 
Cod_Plantilla = @Cod_Plantilla, 
Nro_Ticketera = @Nro_Ticketera, 	
Cod_RegimenPercepcion = @Cod_RegimenPercepcion, 
Tasa_Percepcion = @Tasa_Percepcion, 
Placa_Vehiculo = @Placa_Vehiculo, 
Cod_TipoDocReferencia = @Cod_TipoDocReferencia, 
Nro_DocReferencia = @Nro_DocReferencia, 
Valor_Resumen = @Valor_Resumen, 
Valor_Firma = @Valor_Firma, 
Cod_EstadoComprobante = @Cod_EstadoComprobante, 
MotivoAnulacion = @MotivoAnulacion, 
Otros_Cargos = @Otros_Cargos, 
Otros_Tributos = @Otros_Tributos,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (id_ComprobantePago = @id_ComprobantePago)	
END
SELECT @Numero as Numero
END

GO


--URP_CAJ_COMPROBANTEPAGO_TraerOrdenComandaImpresion 6337,'A103'
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_CAJ_COMPROBANTEPAGO_TraerOrdenComandaImpresion' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_CAJ_COMPROBANTEPAGO_TraerOrdenComandaImpresion
GO

CREATE PROCEDURE URP_CAJ_COMPROBANTEPAGO_TraerOrdenComandaImpresion
	@Id_ComprobantePago int,
	@CodAlmacen  varchar(5),
	@Nuevo bit = 0
AS
BEGIN
    IF  @Nuevo = 0 
    BEGIN
	   WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Nivel)
	   AS 
	   (
		  SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0 THEN  ccd.Descripcion ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+'(PARA LLEVAR)' ELSE ccd.Descripcion END END  Descripcion, 0 Nivel
		  FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
		  WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
		  AND ccd.Cod_Almacen=@CodAlmacen AND ccd.IGV=0)
		  UNION ALL
		  SELECT ccd.id_Detalle, CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,res.Numero,res.Cod_UsuarioReg,res.FechaEmision,ccd.Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0 THEN  ccd.Descripcion ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+'(PARA LLEVAR)' ELSE ccd.Descripcion END END  Descripcion, Nivel + 1  Nivel
		  FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
		  WHERE ccd.id_ComprobantePago=@Id_ComprobantePago
	   )
	   SELECT pe.RUC,pe.RazonSocial,pe.Nom_Comercial, 
	   CAST( CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,RIGHT(p.id_Detalle,1)) END AS int) Orden, 
	   p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa,aa.Cod_Almacen,aa.Des_CortaAlmacen, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
	   CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE 0 END Cantidad_Principal, 
	   CASE WHEN p.Nivel=0 THEN 0 ELSE p.Cantidad END Cantidad_Auxiliar,
	   p.Descripcion, p.Nivel 
	   FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
	   INNER JOIN dbo.ALM_ALMACEN aa ON @CodAlmacen=aa.Cod_Almacen
	   CROSS JOIN dbo.PRI_EMPRESA pe
	   ORDER BY Orden
    END
    ELSE
    BEGIN
	   WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Nivel)
	   AS 
	   (
		  SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0  THEN  ccd.Descripcion  ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+'(PARA LLEVAR)' ELSE ccd.Descripcion END END  Descripcion, 0 Nivel
		  FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
		  WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
		  AND ccd.Cod_Almacen=@CodAlmacen AND ccd.IGV=0 AND ccd.Obs_ComprobanteD='NUEVO')
		  UNION ALL
		  SELECT ccd.id_Detalle, CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,res.Numero,res.Cod_UsuarioReg,res.FechaEmision,ccd.Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0 THEN  ccd.Descripcion  ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+'(PARA LLEVAR)' ELSE ccd.Descripcion END END  Descripcion, Nivel + 1  Nivel
		  FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
		  WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.Obs_ComprobanteD='NUEVO'
	   )
	   SELECT pe.RUC,pe.RazonSocial,pe.Nom_Comercial, 
	   CAST( CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,RIGHT(p.id_Detalle,1)) END AS int) Orden, 
	   p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa,aa.Cod_Almacen,aa.Des_CortaAlmacen, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
	   CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE 0 END Cantidad_Principal, 
	   CASE WHEN p.Nivel=0 THEN 0 ELSE p.Cantidad END Cantidad_Auxiliar,
	   p.Descripcion, p.Nivel INTO #Temporal
	   FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
	   INNER JOIN dbo.ALM_ALMACEN aa ON @CodAlmacen=aa.Cod_Almacen
	   CROSS JOIN dbo.PRI_EMPRESA pe

	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET dbo.CAJ_COMPROBANTE_D.Obs_ComprobanteD='' WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.Obs_ComprobanteD='NUEVO'
	   AND dbo.CAJ_COMPROBANTE_D.id_Detalle IN (SELECT DISTINCT t.id_Detalle FROM #Temporal t)

	   SELECT t.* FROM #Temporal t ORDER BY t.Orden
    END
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_TraerImpresorasDeAlmacenes' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_TraerImpresorasDeAlmacenes
GO

CREATE PROCEDURE USP_VIS_MESAS_TraerImpresorasDeAlmacenes
WITH ENCRYPTION
AS
	SELECT DISTINCT vai.* FROM dbo.VIS_ALMACEN_IMPRESORA vai WHERE vai.Estado=1
GO

--Exec URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda 4170
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda
GO

CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda
	@Id_ComprobanteComanda int
WITH ENCRYPTION
AS
BEGIN
    WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Nivel)
    AS 
    (
	   SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,ccd.Descripcion, 0 Nivel
	   FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
	   WHERE (ccp.id_ComprobantePago=@Id_ComprobanteComanda
	   AND ccd.IGV=0)
	   UNION ALL
	   SELECT ccd.id_Detalle, CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,res.Numero,res.Cod_UsuarioReg,res.FechaEmision,ccd.Cantidad,ccd.Descripcion, Nivel + 1  Nivel
	   FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
	   WHERE ccd.id_ComprobantePago=@Id_ComprobanteComanda
    )
    SELECT pe.RUC,pe.Nom_Comercial,pe.RazonSocial,pe.Direccion, pe.Web,
    vtc.Cod_TipoComprobante,
    vtc.Nom_TipoComprobante,
    CAST( CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,RIGHT(p.id_Detalle,1)) END AS int) Orden, 
    p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
    CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE 0 END Cantidad_Principal, 
    CASE WHEN p.Nivel=0 THEN 0 ELSE p.Cantidad END Cantidad_Auxiliar,
    p.Descripcion,ccd.PrecioUnitario,ccd.Sub_Total,ccp.Total,ccp.Cod_UsuarioVendedor, p.Nivel 
    FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON @Id_ComprobanteComanda=ccp.id_ComprobantePago
    INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago AND p.id_Detalle=ccd.id_Detalle
    CROSS JOIN dbo.PRI_EMPRESA pe
    ORDER BY Orden
END
GO

IF object_id('UFN_QuitarCaracteresRaros') IS NOT NULL
BEGIN 
	PRINT 'Dropping function'
	DROP FUNCTION UFN_QuitarCaracteresRaros
	IF @@ERROR = 0 PRINT 'Function dropped'
END
go

CREATE FUNCTION UFN_QuitarCaracteresRaros
(
@Cadena as varchar(max),@Caracteres as varchar(max)
)
RETURNS varchar(max)
AS
BEGIN
--Quitar Caracteres
WHILE @Cadena LIKE '%[' + @Caracteres + ']%'
BEGIN
SELECT @Cadena = REPLACE(@Cadena
, SUBSTRING(@Cadena
, PATINDEX('%[' + @Caracteres + ']%'
, @Cadena)
, 1)
,'')
END
return @Cadena
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_CambiarMesa' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CambiarMesa
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CambiarMesa
	@IdComanda int, 
	@CodMesaCambio varchar(5),
	@CodUsuario varchar(max)
WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Recupera el codigo de la mesa de la comanda
	   DECLARE @CodMesaComanda varchar(max) = (SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComanda)
	   DECLARE @ConteoMesaComanda int  = (SELECT COUNT(*) FROM (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL
	   UNION
	   SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND  ccd.Formalizado!=ccd.Cantidad AND ccd.IGV=0
	   ) a
	   WHERE a.Cod_Mesa=@CodMesaComanda)
	   --Actualzamos las mesas
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
		 dbo.CAJ_COMPROBANTE_D.Cod_Manguera= @CodMesaCambio,
		 dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
		 dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComanda
	   --Verificamos el estado de la mesa
	   IF(@ConteoMesaComanda=1)
	   BEGIN
	   --Se procede a liberar la mesa 
	   EXEC dbo.USP_VIS_MESAS_GXEstado
	   @Cod_Mesa = @CodMesaComanda,
	   @Estado_Mesa = 'LIBRE',
	   @Cod_Vendedor = @CodUsuario
	   END
	   --Procedemos a actualizar el estado de la mesa destino
	   EXEC dbo.USP_VIS_MESAS_GXEstado
	   @Cod_Mesa = @CodMesaCambio,
	   @Estado_Mesa = 'OCUPADO',
	   @Cod_Vendedor = @CodUsuario
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
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_FusionarComandas' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FusionarComandas
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FusionarComandas
    @IdComandaDestino int,--Donde se volcaran los datos del origen
    @IdComandaOrigen int, --De donde se copiaran los datos
    @CodUsuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
    --Reglas
    --Escenarios: 
    --1. Ambas variables con datos, ninguna es null o con id=0
    --Se realiza el cambio normal
    --2. El destino es null y el origen tiene valor
    --No se realizan acciones, esto corresponde a un cambio de mesa
    --3. el destino tiene valor y el origen no
    --No se puede realziar acciones
    --4. Ambas variables con valores nulos o 0
    --No se puede realizar ninguna accion
    --SOLO SE USA EL ESCENARIO 1, con los otros escenarios no realiza nada
    IF  @IdComandaDestino IS NOT NULL AND @IdComandaDestino > 0 AND @IdComandaOrigen IS NOT NULL AND @IdComandaOrigen > 0
    BEGIN
	IF @IdComandaDestino<>@IdComandaOrigen
	BEGIN
			SET XACT_ABORT ON;  
			BEGIN TRY  
				BEGIN TRANSACTION;  
				--Se obtiene el id_detalle maximo de destino para continuar la numeracion en el destino
				DECLARE @IdDetalleMaximoDestino int =(SELECT MAX (ccd.id_Detalle) FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComandaDestino)
				--Obtenemos la mesa del destino
				DECLARE @CodMesaDestino varchar(5) = (SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComandaDestino )
				--Obtenemos la mesa del origen
				DECLARE @CodMesaOrigen varchar(5) = (SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComandaOrigen)
				--Se procede insertar los detalles  del origen en el destino
				INSERT INTO dbo.CAJ_COMPROBANTE_D
				(
					id_ComprobantePago,
					id_Detalle,
					Id_Producto,
					Cod_Almacen,
					Cantidad,
					Cod_UnidadMedida,
					Despachado,
					Descripcion,
					PrecioUnitario,
					Descuento,
					Sub_Total,
					Tipo,
					Obs_ComprobanteD,
					Cod_Manguera,
					Flag_AplicaImpuesto,
					Formalizado,
					Valor_NoOneroso,
					Cod_TipoISC,
					Porcentaje_ISC,
					ISC,
					Cod_TipoIGV,
					Porcentaje_IGV,
					IGV,
					Cod_UsuarioReg,
					Fecha_Reg,
					Cod_UsuarioAct,
					Fecha_Act
				)
				SELECT @IdComandaDestino,
						ccd.id_Detalle+@IdDetalleMaximoDestino,
						ccd.Id_Producto,
						ccd.Cod_Almacen,
						ccd.Cantidad,
						ccd.Cod_UnidadMedida,
						ccd.Despachado,
						ccd.Descripcion,
						ccd.PrecioUnitario,
						ccd.Descuento,
						ccd.Sub_Total,
						ccd.Tipo,
						ccd.Obs_ComprobanteD,
						@CodMesaDestino,
						ccd.Flag_AplicaImpuesto,
						ccd.Formalizado,
						ccd.Valor_NoOneroso,
						ccd.Cod_TipoISC,
						ccd.Porcentaje_ISC,
						ccd.ISC,
						ccd.Cod_TipoIGV,
						ccd.Porcentaje_IGV,
						CASE WHEN ccd.IGV IS NULL OR ccd.IGV=0 THEN 0 ELSE ccd.IGV+@IdDetalleMaximoDestino END,
						@CodUsuario,
						GETDATE(),
						NULL,
						NULL
				FROM dbo.CAJ_COMPROBANTE_D ccd
				WHERE ccd.id_ComprobantePago = @IdComandaOrigen
				--Actualizamos el total de la comanda de destino
				UPDATE dbo.CAJ_COMPROBANTE_PAGO
				SET
				dbo.CAJ_COMPROBANTE_PAGO.Total += (SELECT ccp.Total FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComandaOrigen),
				dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario,
				dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act=GETDATE()
				WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComandaDestino
				--Actualizamos el total de la comanda de origen
				UPDATE dbo.CAJ_COMPROBANTE_PAGO
				SET
				dbo.CAJ_COMPROBANTE_PAGO.Total = 0,
				dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario,
				dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act=GETDATE()
				WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComandaOrigen
				--Actualziamos los detalles del origen 
				UPDATE dbo.CAJ_COMPROBANTE_D
				SET
				dbo.CAJ_COMPROBANTE_D.Cantidad=0,
				dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct =@CodUsuario,
				dbo.CAJ_COMPROBANTE_D.Fecha_Act=getdate()
				WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComandaOrigen

				--Se procede a liberar la mesa de origen
				IF @CodMesaOrigen<>@CodMesaDestino
				BEGIN
				    IF NOT EXISTS (SELECT DISTINCT ccp.id_ComprobantePago FROM dbo.VIS_MESAS vm INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
				    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
				    WHERE ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND vm.Cod_Mesa=@CodMesaOrigen AND ccd.id_ComprobantePago!=@IdComandaOrigen)
				    BEGIN
					   EXEC dbo.USP_VIS_MESAS_GXEstado
					   @Cod_Mesa = @CodMesaOrigen,
					   @Estado_Mesa = 'LIBRE',
					   @Cod_Vendedor = @CodUsuario
				    END
				END
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
END
GO

