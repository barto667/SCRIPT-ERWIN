--Borramos la vista mesas

-- DELETE dbo.PAR_FILA WHERE dbo.PAR_FILA.Cod_Tabla='103'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '001'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '002'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '003'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '004'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '005'
-- EXEC dbo.USP_PAR_COLUMNA_E
-- 	@Cod_Tabla = '103',
-- 	@Cod_Columna = '006'
-- EXEC dbo.USP_PAR_TABLA_E
-- 	@Cod_Tabla = '103'

--Creacion de vistas
--VIS AMBIENTES
EXEC USP_PAR_TABLA_G'126','AMBIENTES','Almacena informacion de los ambientes','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'126','001','Cod_Ambiente','Codigo del ambiente','CADENA',0,5,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'126','002','Nom_Ambiente','Nombre a mostrar del ambiente','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'126','003','Nom_Impresora','Impreosra asignada al ambiente','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'126','004','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'126';
GO

--VIS MESAS 

EXEC USP_PAR_TABLA_G'103','MESAS','Almacena informacion de las mesas','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','001','Cod_Mesa','Código de Mesa','CADENA',0,8,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','002','Nom_Mesa','Nombre de Mesa','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','003','Estado_Mesa','Estado de la Mesa','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','004','Cod_Ambiente','Código del ambiente donde se ubica la mesa','CADENA',0,5,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','005','Flag_Delivery','Indica si la mesa es delivery o no','BOLEANO',0,1,0,0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'103','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'103';
GO

--Procedimientos

--Obtiene los ambientes activos
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_AMBIENTES_TraerAmbientesActivos'  
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_AMBIENTES_TraerAmbientesActivos
GO

CREATE PROCEDURE USP_VIS_AMBIENTES_TraerAmbientesActivos
WITH ENCRYPTION
AS
BEGIN
    SELECT va.* FROM dbo.VIS_AMBIENTES va WHERE va.Estado=1
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
	AND ccd.Cantidad-ccd.Formalizado>0
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
	@CantidadAEliminar numeric(38,6),
	@Cod_Usuario varchar(max)
  WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Recuperamos algunos campos
	   DECLARE @Documento varchar(max) = '14-'+'CO:0000-'+ (SELECT ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)
	   DECLARE @Proveedor varchar(max) = (SELECT TOP 1 ccp.Cod_TipoDoc+':'+ccp.Doc_Cliente+'-'+ccp.Nom_Cliente FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)
	   DECLARE @Detalle varchar(max) = STUFF(( SELECT distinct ' ; ' + convert(varchar,D.Id_Producto) +'|'+d.Descripcion +'|'+convert(varchar,d.Cantidad)
                                     FROM   CAJ_COMPROBANTE_D D
                                     WHERE  D.id_ComprobantePago = @Id_ComprobantePago AND D.id_Detalle=@Id_Detalle 
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ''
	   DECLARE @FechaEmision datetime = (SELECT ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)
	   --Recuperamos el total de dicha item, el impuesto 
	   DECLARE @TotalItem numeric(38,6)=(SELECT ccd.Cantidad * ccd.PrecioUnitario FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@Id_Detalle)
	   DECLARE @CodMesa varchar(max)=(SELECT TOP 1 ccd.Cod_Manguera FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.Id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@Id_Detalle)

	   
	   --Actualizamos las cantidades en 0 de sus partes
	   --Para no tener problemas con la eliminacion de items
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET 
	   dbo.CAJ_COMPROBANTE_D.Cantidad = CASE WHEN @CantidadAEliminar> 0 THEN  dbo.CAJ_COMPROBANTE_D.Cantidad-@CantidadAEliminar ELSE 0 END,
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@Cod_Usuario,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_Detalle

	   --DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@Id_Detalle
	   --DELETE dbo.CAJ_COMPROBANTE_D WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.IGV=@Id_Detalle
	   --Restamos al total de la comanda el total del item
	   --UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   --SET
	   --dbo.CAJ_COMPROBANTE_PAGO.Total=dbo.CAJ_COMPROBANTE_PAGO.Total-@TotalItem
	   --WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_ComprobantePago
	   --Verificamos que dicha comanda tenga items, si los tiene no hacemos nada, caso contraio eliminamos la comanda
	   IF NOT EXISTS(SELECT * FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=6819 AND ccd.Cantidad-ccd.Formalizado>0 AND ccd.IGV=0) 
	   BEGIN 
		  ----Eliminamos la comanda
		  --DELETE dbo.CAJ_COMPROBANTE_PAGO WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_ComprobantePago
		  --Si eliminamos la comanda, entonces verificamos que la mesa aun este ocupada, si no es asi liberamos la mesa
		  DECLARE @IdMesaComanda int
		  SELECT  @IdMesaComanda=a.id_ComprobantePago FROM (SELECT  Mesas.Cod_Mesa,Mesas.Nom_Mesa,ISNULL(Ocupados.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,ISNULL(Ocupados.id_ComprobantePago,0) id_ComprobantePago,Ocupados.Fecha_Reg FROM 
		  (SELECT vm.Cod_Mesa ,vm.Nom_Mesa,NULL Cod_UsuarioVendedor,NULL id_ComprobantePago,NULL Fecha_Reg
		  FROM dbo.VIS_MESAS vm WHERE vm.Estado=1 ) Mesas LEFT JOIN 
		  (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
		  COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
		  ccp.id_ComprobantePago,ccp.Fecha_Reg
		  FROM dbo.VIS_MESAS vm
		  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
		  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		  WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad-ccd.Formalizado>0
		  UNION
		  SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
		  COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
		  ccp.id_ComprobantePago,ccp.Fecha_Reg
		  FROM dbo.VIS_MESAS vm
		  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
		  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		  WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO'  AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0) Ocupados
		  ON Mesas.Cod_Mesa=Ocupados.Cod_Mesa
		  ) a
		  WHERE a.Cod_Mesa=@CodMesa					 

		  IF	@IdMesaComanda = 0
		  BEGIN
			 --Liberamos la mesa
			 EXEC USP_VIS_MESAS_GXEstado @CodMesa,'LIBRE',@Cod_usuario
		  END

	   END

	   DECLARE @FechaActual datetime =GETDATE()
	   --Introducimos la justificacion
	    DECLARE  @id_Fila int  = (SELECT ISNULL(COUNT(*)/9,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '079')
	    EXEC USP_PAR_FILA_G '079','001',@id_Fila,@Documento,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','002',@id_Fila,'CAJ_COMPROBANTE_PAGO_COMANDA',NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','003',@id_Fila,@Proveedor,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','004',@id_Fila,@Detalle,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','005',@id_Fila,NULL,NULL,NULL,@FechaEmision,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','006',@id_Fila,NULL,NULL,NULL,@FechaActual,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','007',@id_Fila,@Cod_Usuario,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','008',@id_Fila,@Justificacion,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','009',@id_Fila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';	
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
	@Justificacion varchar(max),
	@Cod_Usuario varchar(max)
  WITH ENCRYPTION
AS
BEGIN
    SET XACT_ABORT ON;  
    BEGIN TRY  
	   BEGIN TRANSACTION;  
	   --Recuepramos algunos datos
	   DECLARE @Documento varchar(max) = '14-'+'CO:0000-'+ (SELECT ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)
	   DECLARE @Proveedor varchar(max) = (SELECT TOP 1 ccp.Cod_TipoDoc+':'+ccp.Doc_Cliente+'-'+ccp.Nom_Cliente FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)
	   DECLARE @Detalle varchar(max) = STUFF(( SELECT distinct ' ; ' + convert(varchar,D.Id_Producto) +'|'+d.Descripcion +'|'+convert(varchar,d.Cantidad)
                                     FROM   CAJ_COMPROBANTE_D D
                                     WHERE  D.id_ComprobantePago = @Id_ComprobantePago AND D.id_Detalle=@Id_Detalle 
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ''
	   DECLARE @FechaEmision datetime = (SELECT ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@Id_ComprobantePago)

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

	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
	       dbo.CAJ_COMPROBANTE_PAGO.Total= dbo.CAJ_COMPROBANTE_PAGO.Total + (@Valor*@PU)
	   WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_ComprobantePago

	   DECLARE @FechaActual datetime =GETDATE()
	   DECLARE @Accion varchar(max) = CONCAT('CAJ_COMPROBANTE_PAGO_COMANDA_MODIFICACION_',@Valor)
	   --Introducimos la justificacion
	    DECLARE  @id_Fila int  = (SELECT ISNULL(COUNT(*)/9,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '079')
	    EXEC USP_PAR_FILA_G '079','001',@id_Fila,@Documento,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','002',@id_Fila,@Accion,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','003',@id_Fila,@Proveedor,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','004',@id_Fila,@Detalle,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','005',@id_Fila,NULL,NULL,NULL,@FechaEmision,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','006',@id_Fila,NULL,NULL,NULL,@FechaActual,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','007',@id_Fila,@Cod_Usuario,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','008',@id_Fila,@Justificacion,NULL,NULL,NULL,NULL,1,'MIGRACION';
	    EXEC USP_PAR_FILA_G '079','009',@id_Fila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';	

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
	   IF NOT  EXISTS ( SELECT DISTINCT ccd.* FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobantePago AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado > 0 )
	   BEGIN
		  --Debemos verificar que la mesa no tenga otras comanda
		  DECLARE @IdMesaComanda int
		  SELECT  @IdMesaComanda=a.id_ComprobantePago FROM (SELECT  Mesas.Cod_Mesa,Mesas.Nom_Mesa,ISNULL(Ocupados.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,ISNULL(Ocupados.id_ComprobantePago,0) id_ComprobantePago,Ocupados.Fecha_Reg FROM 
		  (SELECT vm.Cod_Mesa ,vm.Nom_Mesa,NULL Cod_UsuarioVendedor,NULL id_ComprobantePago,NULL Fecha_Reg
		  FROM dbo.VIS_MESAS vm WHERE vm.Estado=1 ) Mesas LEFT JOIN 
		  (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
		  COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
		  ccp.id_ComprobantePago,ccp.Fecha_Reg
		  FROM dbo.VIS_MESAS vm
		  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
		  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		  WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad-ccd.Formalizado>0
		  UNION
		  SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
		  COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
		  ccp.id_ComprobantePago,ccp.Fecha_Reg
		  FROM dbo.VIS_MESAS vm
		  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
		  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		  WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO'  AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0) Ocupados
		  ON Mesas.Cod_Mesa=Ocupados.Cod_Mesa
		  ) a
		  WHERE a.Cod_Mesa=@CodMesa

		  IF @IdMesaComanda = 0
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


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios
GO

CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios
WITH ENCRYPTION
AS
BEGIN
	IF NOT EXISTS (SELECT pcp.* FROM dbo.PRI_CLIENTE_PROVEEDOR pcp WHERE pcp.Cliente='CLIENTES VARIOS' AND pcp.Cod_TipoDocumento='99' AND pcp.Nro_Documento='00000001' AND pcp.Cod_TipoComprobante='BE')
	BEGIN
	   DECLARE @FECHA DATETIME = GETDATE()
	   DECLARE @Lugar varchar(max) = (SELECT vd.Nom_Distrito FROM dbo.VIS_DISTRITOS vd INNER JOIN dbo.PRI_EMPRESA pe ON vd.Cod_Ubigeo = pe.Cod_Ubigeo)
       EXEC USP_PRI_CLIENTE_PROVEEDOR_G 0,'0','00000001','CLIENTES VARIOS','','','',@Lugar,'001','01','002','',NULL,NULL,'BE','156',@FECHA,'01','','','','','','','080101','008',0,'CREADO POR SCRIPT',0,'SCRIPT'
	END
END
GO

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
	    EXEC dbo.USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios
     END
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
	--Debemos verificar que no existan elementos por formalizar para realizar la modificacion
	IF NOT EXISTS(SELECT ccd.* FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago = @Id_Comprobante_Pago AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0)
	BEGIN
         UPDATE dbo.CAJ_COMPROBANTE_PAGO
           SET
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Periodo = @CodPeriodo,
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Caja = @CodCaja,
               dbo.CAJ_COMPROBANTE_PAGO.Cod_Turno = @CodTurno
         WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_Comprobante_Pago;
	END
	
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
	SELECT ccp.* FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_Libro=@Cod_Libro AND ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@Serie AND ccp.Numero=@Numero ORDER BY ccp.Fecha_Reg DESC
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
@Cod_Libro	varchar(2) = '',  
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

IF (@Numero = '' and @Cod_Libro = '')
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

--Exec URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda 6553
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
    DECLARE @TotalComanda numeric(38,2) = (SELECT SUM((ccd.Cantidad- ccd.Formalizado)*ccd.PrecioUnitario) FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobanteComanda AND ccd.IGV=0);

    WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Nivel)
    AS 
    (
	   SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,ccd.Descripcion, 0 Nivel
	   FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
	   WHERE (ccp.id_ComprobantePago=@Id_ComprobanteComanda
	   AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0 )
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
    p.Descripcion,ccd.PrecioUnitario,(ccd.Cantidad- ccd.Formalizado)*ccd.PrecioUnitario Sub_Total,
    @TotalComanda Total,
    ccp.Cod_UsuarioVendedor, p.Nivel 
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
	   --Actualzamos las mesas
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
		 dbo.CAJ_COMPROBANTE_D.Cod_Manguera= @CodMesaCambio,
		 dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
		 dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComanda
	   --Verificamos el estado de la mesa
	    --Verificamos el estado de la mesa 
	   DECLARE @IdMesaComanda int
	   SELECT  @IdMesaComanda=a.id_ComprobantePago FROM (SELECT  Mesas.Cod_Mesa,Mesas.Nom_Mesa,ISNULL(Ocupados.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,ISNULL(Ocupados.id_ComprobantePago,0) id_ComprobantePago,Ocupados.Fecha_Reg FROM 
	   (SELECT vm.Cod_Mesa ,vm.Nom_Mesa,NULL Cod_UsuarioVendedor,NULL id_ComprobantePago,NULL Fecha_Reg
	   FROM dbo.VIS_MESAS vm WHERE vm.Estado=1 ) Mesas LEFT JOIN 
	   (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad-ccd.Formalizado>0
	   UNION
	   SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
	   COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
	   ccp.id_ComprobantePago,ccp.Fecha_Reg
	   FROM dbo.VIS_MESAS vm
	   INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
	   INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	   WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO'  AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0) Ocupados
	   ON Mesas.Cod_Mesa=Ocupados.Cod_Mesa
	   ) a
	   WHERE a.Cod_Mesa=@CodMesaComanda 

	   IF(@IdMesaComanda=0)
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
				dbo.CAJ_COMPROBANTE_D.Sub_Total=0,
				dbo.CAJ_COMPROBANTE_D.Formalizado=0,
				dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct =@CodUsuario,
				dbo.CAJ_COMPROBANTE_D.Fecha_Act=getdate()
				WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComandaOrigen

				--Se procede a liberar la mesa de origen
				IF @CodMesaOrigen<>@CodMesaDestino
				BEGIN

				    DECLARE @IdMesaComanda int
				    SELECT  @IdMesaComanda=a.id_ComprobantePago FROM (SELECT  Mesas.Cod_Mesa,Mesas.Nom_Mesa,ISNULL(Ocupados.Cod_UsuarioVendedor,'') Cod_UsuarioVendedor,ISNULL(Ocupados.id_ComprobantePago,0) id_ComprobantePago,Ocupados.Fecha_Reg FROM 
				    (SELECT vm.Cod_Mesa ,vm.Nom_Mesa,NULL Cod_UsuarioVendedor,NULL id_ComprobantePago,NULL Fecha_Reg
				    FROM dbo.VIS_MESAS vm WHERE vm.Estado=1 ) Mesas LEFT JOIN 
				    (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
				    COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
				    ccp.id_ComprobantePago,ccp.Fecha_Reg
				    FROM dbo.VIS_MESAS vm
				    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
				    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
				    WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO' AND ccp.Cod_Caja IS NULL AND ccp.Cod_Turno IS NULL AND ccd.Cantidad-ccd.Formalizado>0
				    UNION
				    SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
				    COALESCE(CASE WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor,' ',''))=0 THEN NULL ELSE ccp.Cod_UsuarioVendedor END,ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
				    ccp.id_ComprobantePago,ccp.Fecha_Reg
				    FROM dbo.VIS_MESAS vm
				    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa=ccd.Cod_Manguera
				    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
				    WHERE vm.Estado_Mesa='OCUPADO' AND vm.Estado=1 AND ccp.Cod_TipoComprobante='CO'  AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0) Ocupados
				    ON Mesas.Cod_Mesa=Ocupados.Cod_Mesa
				    ) a
				    WHERE a.Cod_Mesa=@CodMesaOrigen 

				    IF @IdMesaComanda=0
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

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_D_MoverDetalleXOrigenDestino' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_D_MoverDetalleXOrigenDestino
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_MoverDetalleXOrigenDestino
 @IdComprobanteComandaOrigen int ,
 @IdDetalleComandaOrigen int ,
 @IdComprobanteComandaDestino int ,
 @CantidadDestino numeric(38,6),
 @CodUsuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
    --Obtenemos la cantidad del origen
    DECLARE @CantidadOrigen numeric(38,6) = (SELECT ccd.Cantidad FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobanteComandaOrigen AND ccd.id_Detalle=@IdDetalleComandaOrigen)

    IF @CantidadOrigen=@CantidadDestino
    BEGIN
	   --Cambiamos el id_comprobantePago ademas del usuario de registro y la fecha,
	   --Tanto a la cabezera como a los hijos
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	   dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @IdComprobanteComandaDestino,
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioReg=@CodUsuario,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Reg = GETDATE(),
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct =NULL,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Act = NULL
	   WHERE (dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComprobanteComandaOrigen AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@IdDetalleComandaOrigen AND dbo.CAJ_COMPROBANTE_D.IGV=0)
	   OR (dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComprobanteComandaOrigen AND dbo.CAJ_COMPROBANTE_D.IGV = @IdDetalleComandaOrigen)
    END
    ELSE
    BEGIN
	   --se debe crear un detalle duplicado con los mismos campos del detalle origen 
	   INSERT  dbo.CAJ_COMPROBANTE_D
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
	   SELECT 
		 @IdComprobanteComandaDestino,
		 ccd.id_Detalle,
		 ccd.Id_Producto,
		 ccd.Cod_Almacen,
		 CASE WHEN ccd.IGV = 0 THEN @CantidadDestino ELSE ccd.Cantidad END,
		 ccd.Cod_UnidadMedida,
		 ccd.Despachado,
		 ccd.Descripcion,
		 ccd.PrecioUnitario,
		 ccd.Descuento,
		 CASE WHEN ccd.IGV = 0 THEN @CantidadDestino*ccd.PrecioUnitario ELSE ccd.Cantidad END,
		 ccd.Tipo,
		 ccd.Obs_ComprobanteD,
		 ccd.Cod_Manguera,
		 ccd.Flag_AplicaImpuesto,
		 0,
		 ccd.Valor_NoOneroso,
		 ccd.Cod_TipoISC,
		 ccd.Porcentaje_ISC,
		 ccd.ISC,
		 ccd.Cod_TipoIGV,
		 ccd.Porcentaje_IGV,
		 ccd.IGV,
		 @CodUsuario,
		 GETDATE(),
		 NULL,
		 NULL
	   FROM dbo.CAJ_COMPROBANTE_D ccd
	   WHERE(ccd.id_ComprobantePago = @IdComprobanteComandaOrigen
		    AND ccd.id_Detalle = @IdDetalleComandaOrigen
		    AND ccd.IGV = 0) OR
		   (ccd.id_ComprobantePago = @IdComprobanteComandaOrigen
		    AND ccd.IGV = @IdDetalleComandaOrigen) 
	   
	   --Actualziamos el origen
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET

	       dbo.CAJ_COMPROBANTE_D.Cantidad = dbo.CAJ_COMPROBANTE_D.Cantidad-@CantidadDestino, -- numeric
		   dbo.CAJ_COMPROBANTE_D.Sub_Total = (dbo.CAJ_COMPROBANTE_D.Cantidad-@CantidadDestino-dbo.CAJ_COMPROBANTE_D.Formalizado)*dbo.CAJ_COMPROBANTE_D.PrecioUnitario,
	       dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @CodUsuario, -- varchar
	       dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE() -- datetime
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@IdComprobanteComandaOrigen
	   AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@IdDetalleComandaOrigen
    END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda
@IdComprobanteComanda int,
@CodUsuario varchar(32)
WITH ENCRYPTION
AS
BEGIN
    UPDATE dbo.CAJ_COMPROBANTE_PAGO
    SET
	  dbo.CAJ_COMPROBANTE_PAGO.Total = (SELECT SUM((ccd.Cantidad-ccd.Formalizado)*ccd.PrecioUnitario) FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobanteComanda AND ccd.IGV=0), 
	  dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, 
	  dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE()
    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobanteComanda
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_USUARIO_TraerUsuarioXPIN' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_USUARIO_TraerUsuarioXPIN
GO

CREATE PROCEDURE USP_PRI_USUARIO_TraerUsuarioXPIN
	@PIN varchar(4)
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT pu.*
    FROM dbo.PRI_USUARIO pu 
    WHERE pu.Pregunta='PIN' AND pu.Respuesta=@PIN 
END
GO



--CONDICIONES PREVIA:
--Si la mesa no tiene el flag delivery, se trae solo las mesas con su codigo
--Si tiene el flag existen dos opciones:
--Si el campo ambiente es vacio entonces esa mesa delkivery es disponible para cualqueir ambiente
--Caso contrario se respeta el ambiente al que pertenece
--EXEC dbo.USP_VIS_MESAS_ObtenerMesasXCodAmbiente 'PISO 1'

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_ObtenerMesasXCodAmbiente' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_ObtenerMesasXCodAmbiente
GO

CREATE PROCEDURE USP_VIS_MESAS_ObtenerMesasXCodAmbiente
@Cod_Ambiente varchar(32)
WITH ENCRYPTION
AS
BEGIN
    
    SELECT DISTINCT
       Mesas.Cod_Mesa,
       COUNT(Ocupadas.id_ComprobantePago) Total_Ordenes,
       MAX(Mesas.Nom_Mesa) Nom_Mesa,
       MAX(Ocupadas.id_ComprobantePago) Id_Comanda,
       CAST(ROUND(SUM(Ocupadas.Total),2) AS numeric(38,2)) Total,
       MAX(Ocupadas.Cod_UsuarioVendedor) Cod_UsuarioVendedor,
	  Mesas.Flag_Delivery
	FROM
	(
		SELECT vm.Cod_Mesa,
			vm.Nom_Mesa,
			NULL id_ComprobantePago,
			NULL Total,
			NULL Cod_UsuarioVendedor,
			vm.Flag_Delivery
		FROM dbo.VIS_MESAS vm
		WHERE 
		(vm.Cod_Ambiente = @Cod_Ambiente AND (vm.Flag_Delivery = 0 or vm.Flag_Delivery IS NULL)) OR
		(vm.Flag_Delivery = 1 AND 
			(
				(vm.Cod_Ambiente IS NULL OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '') OR (vm.Cod_Ambiente = @Cod_Ambiente)
			)
		)
		AND vm.Estado = 1
	) Mesas
	LEFT JOIN
	(
		SELECT DISTINCT
			vm.Cod_Mesa,
			vm.Nom_Mesa,
			ccd.id_ComprobantePago,
		 	SUM(CASE WHEN ccd.IGV= 0 THEN ROUND((ccd.Cantidad - ccd.Formalizado )*ccd.PrecioUnitario,2) ELSE 0 END) Total,
			COALESCE(ccp.Cod_UsuarioVendedor,ccp.Cod_UsuarioAct, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
			vm.Flag_Delivery
		FROM dbo.VIS_MESAS vm
			INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.Cod_Manguera = vm.Cod_Mesa 
			INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
		WHERE((vm.Cod_Ambiente = @Cod_Ambiente
			AND (vm.Flag_Delivery = 0 OR vm.Flag_Delivery IS NULL))
			OR (vm.Flag_Delivery = 1
				AND ((vm.Cod_Ambiente IS NULL
						OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '')
					OR (vm.Cod_Ambiente = @Cod_Ambiente))))
			AND vm.Estado = 1
			AND vm.Estado_Mesa = 'OCUPADO'
			AND ccp.Cod_TipoComprobante = 'CO'
			AND ccd.Cantidad > 0
			--AND ((ccp.Cod_Caja IS NULL
			--	AND ccp.Cod_Turno IS NULL)
			--	OR (ccd.Cantidad - ccd.Formalizado > 0
			--		AND ccd.IGV = 0))
			AND (ccd.Cantidad - ccd.Formalizado > 0
					AND ccd.IGV = 0)
					GROUP BY vm.Cod_Mesa,vm.Nom_Mesa,ccd.id_ComprobantePago,ccp.Cod_UsuarioAct,ccp.Cod_UsuarioReg,ccp.Cod_UsuarioVendedor,vm.Flag_Delivery
	) Ocupadas ON Mesas.Cod_Mesa = Ocupadas.Cod_Mesa
	GROUP BY Mesas.Cod_Mesa,Mesas.Flag_Delivery
	ORDER BY Mesas.Cod_Mesa;
END
GO

 IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa
GO

CREATE PROCEDURE USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa
@Cod_Ambiente varchar(32),
@Cod_Mesa varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT DISTINCT
		vm.Cod_Mesa,
		1 Total_Ordenes,
		vm.Nom_Mesa,
		ccp.id_ComprobantePago Id_Comanda,
	     CAST( SUM(CASE WHEN ccd.IGV= 0 THEN ROUND((ccd.Cantidad - ccd.Formalizado )*ccd.PrecioUnitario,2) ELSE 0 END) AS numeric(38,2)) Total,
		COALESCE(ccp.Cod_UsuarioVendedor,ccp.Cod_UsuarioAct, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor,
		vm.Flag_Delivery
	FROM dbo.VIS_MESAS vm
		INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.Cod_Manguera = vm.Cod_Mesa
		INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
	WHERE((vm.Cod_Ambiente = @Cod_Ambiente
		AND (vm.Flag_Delivery = 0 or vm.Flag_Delivery IS NULL))
		OR (vm.Flag_Delivery = 1
			AND ((vm.Cod_Ambiente IS NULL
					OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '')
				OR (vm.Cod_Ambiente = @Cod_Ambiente))))
		AND vm.Estado = 1
		AND vm.Estado_Mesa = 'OCUPADO'
		AND ccp.Cod_TipoComprobante = 'CO'
		AND ccd.Cantidad > 0
		AND ((ccp.Cod_Caja IS NULL
			AND ccp.Cod_Turno IS NULL)
			OR ( ccd.Cantidad -ccd.Formalizado>0
				AND ccd.IGV = 0))
		AND vm.Cod_Mesa = @Cod_Mesa
		GROUP BY vm.Cod_Mesa,vm.Nom_Mesa,ccp.id_ComprobantePago,ccp.Cod_UsuarioReg,ccp.Cod_UsuarioVendedor,ccp.Cod_UsuarioAct,vm.Flag_Delivery
        HAVING CAST( SUM(CASE WHEN ccd.IGV= 0 THEN ROUND((ccd.Cantidad - ccd.Formalizado )*ccd.PrecioUnitario,2) ELSE 0 END) AS numeric(38,2))>0
	ORDER BY vm.Cod_Mesa;
END
GO


--Obtiene todas las mesas delivery de un ambiente 
--Si una mesa delivery no tiene ambiente, se asume que es acceible por cualquier ambientes
--asi que tambien se trae
--EXEC USP_VIS_MESAS_ObtenerMesasDeliveryXCodAmbiente 'PISO 1'
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESAS_ObtenerMesasDeliveryXCodAmbiente' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESAS_ObtenerMesasDeliveryXCodAmbiente
GO

CREATE PROCEDURE USP_VIS_MESAS_ObtenerMesasDeliveryXCodAmbiente
@CodAmbiente varchar(32)
WITH ENCRYPTION
AS
BEGIN
    SELECT vm.Cod_Mesa, vm.Nom_Mesa, vm.Estado_Mesa, vm.Estado, vm.Cod_Ambiente 
    FROM dbo.VIS_MESAS vm WHERE vm.Flag_Delivery = 1 AND vm.Estado=1 
    AND (vm.Cod_Ambiente=@CodAmbiente OR RTRIM(LTRIM(vm.Cod_Ambiente))='' OR vm.Cod_Ambiente IS NULL)
END
GO



IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_Comanda_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_Comanda_G
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_Comanda_G
@Id_Comanda int OUTPUT, 
@Id_Cliente int, 
@Cod_TipoDoc varchar(2), 
@Doc_Cliente varchar(20), 
@Nom_Cliente varchar(512),	
@Dir_Cliente varchar(max),
@Cod_Moneda varchar(3), 	
@Total numeric(38,2),
@Cod_UsuarioVendedor varchar(32) ,
@Cod_Usuario varchar(32) 

WITH ENCRYPTION
AS
BEGIN
    IF @Id_Comanda=0 --Nueva comanda
    BEGIN
	   INSERT dbo.CAJ_COMPROBANTE_PAGO
	   VALUES
	   (
	       -- id_ComprobantePago - int
	       '', -- Cod_Libro - varchar
	       '', -- Cod_Periodo - varchar
	       NULL, -- Cod_Caja - varchar
	       NULL, -- Cod_Turno - varchar
	       '01', -- Cod_TipoOperacion - varchar
	       'CO', -- Cod_TipoComprobante - varchar
	       '0000', -- Serie - varchar
	       (SELECT RIGHT('00000000'+CONVERT( varchar(8), ISNULL(CONVERT(bigint,MAX(Numero)),0)+1), 8) FROM CAJ_COMPROBANTE_PAGO WHERE Cod_TipoComprobante = 'CO' and Serie='0000' and Cod_Libro = '' ), -- Numero - varchar
	       @Id_Cliente, -- Id_Cliente - int
	       @Cod_TipoDoc, -- Cod_TipoDoc - varchar
	       @Doc_Cliente, -- Doc_Cliente - varchar
	       @Nom_Cliente, -- Nom_Cliente - varchar
	       @Dir_Cliente, -- Direccion_Cliente - varchar
	       GETDATE(), -- FechaEmision - datetime
	       GETDATE(), -- FechaVencimiento - datetime
	       GETDATE(), -- FechaCancelacion - datetime
	       'COMANDA', -- Glosa - varchar
	       1, -- TipoCambio - numeric
	       0, -- Flag_Anulado - bit
	       0, -- Flag_Despachado - bit
	       '004', -- Cod_FormaPago - varchar
	       0, -- Descuento_Total - numeric
	       @Cod_Moneda, -- Cod_Moneda - varchar
	       0, -- Impuesto - numeric
	       @Total, -- Total - numeric
	       dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('CAJ_COMPROBANTE_PAGO'), -- Obs_Comprobante - xml
	       0, -- Id_GuiaRemision - int
	       'AUTOMATICO', -- GuiaRemision - varchar
	       0, -- id_ComprobanteRef - int
	       '', -- Cod_Plantilla - varchar
	       '', -- Nro_Ticketera - varchar
	       @Cod_UsuarioVendedor, -- Cod_UsuarioVendedor - varchar
	       NULL, -- Cod_RegimenPercepcion - varchar
	       0, -- Tasa_Percepcion - numeric
	       '', -- Placa_Vehiculo - varchar
	       NULL, -- Cod_TipoDocReferencia - varchar
	       '', -- Nro_DocReferencia - varchar
	       NULL, -- Valor_Resumen - varchar
	       NULL, -- Valor_Firma - varchar
	       'INI', -- Cod_EstadoComprobante - varchar
	       '', -- MotivoAnulacion - varchar
	       0, -- Otros_Cargos - numeric
	       0, -- Otros_Tributos - numeric
	       @Cod_Usuario, -- Cod_UsuarioReg - varchar
	       GETDATE(), -- Fecha_Reg - datetime
	       NULL, -- Cod_UsuarioAct - varchar
	       NULL -- Fecha_Act - datetime
	   )
	   SET @Id_Comanda = @@IDENTITY 
    END
    ELSE
    BEGIN
	   UPDATE dbo.CAJ_COMPROBANTE_PAGO
	   SET
	       dbo.CAJ_COMPROBANTE_PAGO.Id_Cliente = @Id_Cliente, -- int
	       dbo.CAJ_COMPROBANTE_PAGO.Cod_TipoDoc = @Cod_TipoDoc, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Doc_Cliente = @Doc_Cliente, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Nom_Cliente = @Nom_Cliente, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Direccion_Cliente = @Dir_Cliente, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Cod_Moneda = @Cod_Moneda, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Total = @Total, -- numeric
	       dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioVendedor = @Cod_UsuarioVendedor, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @Cod_Usuario, -- varchar
	       dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
		  WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@Id_Comanda
    END
    END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_D_ComandaDetalle_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_D_ComandaDetalle_G
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_ComandaDetalle_G
@Id_ComprobantePago	int,
@id_Detalle int, 
@Id_Producto int, 
@Cod_Almacen varchar(32), 
@Cantidad	numeric(38,6), 	 
@Descripcion varchar(MAX), 
@PrecioUnitario numeric(38,6), 	 
@Sub_Total numeric(38,2), 
@Tipo varchar(256), 	
@Obs_ComprobanteD varchar(1024),
@Cod_Mesa	varchar(32),
@Id_Referencia	numeric(38,2),
@Estado_Item varchar(8),
@Estado_Pedido varchar(8),
@FlagLLevar bit,
@Cod_Usuario Varchar(32) = 'COMANDERO'
WITH ENCRYPTION
AS
BEGIN
     IF NOT EXISTS (SELECT ccd.id_ComprobantePago,ccd.id_Detalle FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@Id_ComprobantePago AND ccd.id_Detalle=@id_Detalle)
	BEGIN
	   INSERT dbo.CAJ_COMPROBANTE_D
	   VALUES
	   (
	       @Id_ComprobantePago, -- id_ComprobantePago - int
	       @id_Detalle, -- id_Detalle - int
	       @Id_Producto, -- Id_Producto - int
	       @Cod_Almacen, -- Cod_Almacen - varchar
	       @Cantidad, -- Cantidad - numeric
	       'NIU', -- Cod_UnidadMedida - varchar
	       0, -- Despachado - numeric
	       @Descripcion, -- Descripcion - varchar
	       @PrecioUnitario, -- PrecioUnitario - numeric
	       0, -- Descuento - numeric
	       @Sub_Total, -- Sub_Total - numeric
	       @Tipo, -- Tipo - varchar
	       @Obs_ComprobanteD, -- Obs_ComprobanteD - varchar
	       @Cod_Mesa, -- Cod_Manguera - varchar
	       @FlagLLevar, -- Flag_AplicaImpuesto - bit
	       0, -- Formalizado - numeric
	       0, -- Valor_NoOneroso - numeric
	       @Estado_Pedido, -- Cod_TipoISC - varchar
	       0, -- Porcentaje_ISC - numeric
	       0, -- ISC - numeric
	       @Estado_Item, -- Cod_TipoIGV - varchar
	       0, -- Porcentaje_IGV - numeric
	       @Id_Referencia, -- IGV - numeric
	       @Cod_Usuario, -- Cod_UsuarioReg - varchar
	       GETDATE(), -- Fecha_Reg - datetime
		  NULL, -- Cod_UsuarioAct - varchar
	       NULL -- Fecha_Act - datetime
	   )
	END
	ELSE
	BEGIN
	   UPDATE dbo.CAJ_COMPROBANTE_D
	   SET
	       dbo.CAJ_COMPROBANTE_D.Id_Producto = @Id_Producto, -- int
	       dbo.CAJ_COMPROBANTE_D.Cod_Almacen = @Cod_Almacen, -- varchar
	       dbo.CAJ_COMPROBANTE_D.Cantidad = @Cantidad, -- numeric
	       dbo.CAJ_COMPROBANTE_D.Descripcion = @Descripcion, -- varchar
	       dbo.CAJ_COMPROBANTE_D.PrecioUnitario = @PrecioUnitario, -- numeric
	       dbo.CAJ_COMPROBANTE_D.Sub_Total = @Sub_Total, -- numeric
	       dbo.CAJ_COMPROBANTE_D.Obs_ComprobanteD = @Obs_ComprobanteD, -- varchar
	       dbo.CAJ_COMPROBANTE_D.Cod_Manguera = @Cod_Mesa, -- varchar
	       dbo.CAJ_COMPROBANTE_D.Flag_AplicaImpuesto = @FlagLLevar, -- bit
		   dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV = @Estado_Item, --varchar
	       dbo.CAJ_COMPROBANTE_D.Cod_TipoISC = @Estado_Pedido, -- varchar
		   dbo.CAJ_COMPROBANTE_D.IGV = @Id_Referencia,
	       dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @Cod_Usuario, -- varchar
	       dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE() -- datetime
	   WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@Id_ComprobantePago AND dbo.CAJ_COMPROBANTE_D.id_Detalle=@id_Detalle
	END
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOSxTodos' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOSxTodos
GO

CREATE PROCEDURE USP_PRI_PRODUCTOSxTodos
WITH ENCRYPTION
AS
BEGIN
SELECT        P.Id_Producto, VM.Cod_Marca, VM.Nom_Marca, P.Cod_TipoProducto, P.Nom_Producto, P.Des_CortaProducto, P.Des_LargaProducto, P.Cod_TipoOperatividad, PS.Cod_Almacen,aa.Des_CortaAlmacen, PP.Cod_TipoPrecio, PP.Valor AS PrecioUnitario,
                         VP.Nom_Precio, PS.Cod_Moneda, VMO.Nom_Moneda, VMO.Simbolo, VMO.Definicion
						 ,p.Cod_Categoria
						 ,(SELECT isnull(COUNT(Id_Producto),0) from VIS_PRODUCTO_MODIFICADOR where Id_Producto=P.Id_Producto) as DETALLES
						,(SELECT isnull(COUNT(Id_Producto),0) from PRI_PRODUCTO_PRECIO where Id_Producto=P.Id_Producto) as PRECIOS
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON PS.Id_Producto = PP.Id_Producto AND PS.Cod_UnidadMedida = PP.Cod_UnidadMedida AND PS.Cod_Almacen = PP.Cod_Almacen INNER JOIN
                         VIS_MARCA AS VM ON P.Cod_Marca = VM.Cod_Marca INNER JOIN
                         VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio AND VP.Cod_Precio = '001' INNER JOIN
                         VIS_MONEDAS AS VMO ON PS.Cod_Moneda = VMO.Cod_Moneda
					INNER JOIN dbo.ALM_ALMACEN aa ON PS.Cod_Almacen = aa.Cod_Almacen
where   p.Flag_Activo = 1 and Cod_TipoProducto = 'PRO'
END
GO
  
  
--EXEC URP_CAJ_COMPROBANTEPAGO_TraerOrdenComandaImpresion 6767,'A103'
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_VIS_MESA_TraerOrdenXIdComanda_CodAlmacen' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_VIS_MESA_TraerOrdenXIdComanda_CodAlmacen
GO

CREATE PROCEDURE URP_VIS_MESA_TraerOrdenXIdComanda_CodAlmacen
	@Id_ComprobantePago int,
	@CodAlmacen  varchar(5)
AS
BEGIN
WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Observacion,Nivel)
	   AS 
	   (
		  SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad- ccd.Formalizado Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0 THEN  ccd.Descripcion ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+' (PARA LLEVAR) ' ELSE ccd.Descripcion END END  Descripcion,ccd.Obs_ComprobanteD, 0 Nivel
		  FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
		  WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
		  AND ccd.Cod_Almacen=@CodAlmacen AND ccd.IGV=0 AND ccd.Cantidad-ccd.Formalizado>0)
		  UNION ALL
		  SELECT ccd.id_Detalle, CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,res.Numero,res.Cod_UsuarioReg,res.FechaEmision,ccd.Cantidad,
		  CASE WHEN ccd.Flag_AplicaImpuesto = 0 THEN  ccd.Descripcion ELSE CASE WHEN ccd.IGV = 0 THEN ccd.Descripcion+' (PARA LLEVAR) ' ELSE ccd.Descripcion END END  Descripcion,NULL, Nivel + 1  Nivel
		  FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
		  WHERE ccd.id_ComprobantePago=@Id_ComprobantePago
	   )
	   SELECT pe.RUC,pe.RazonSocial,pe.Nom_Comercial, 
	   CAST( CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,RIGHT(p.id_Detalle,1)) END AS int) Orden, 
	   p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa,aa.Cod_Almacen,aa.Des_CortaAlmacen, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
	   CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE 0 END Cantidad_Principal, 
	   CASE WHEN p.Nivel=0 THEN 0 ELSE p.Cantidad END Cantidad_Auxiliar,
	   p.Descripcion,p.Observacion, p.Nivel 
	   FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
	   INNER JOIN dbo.ALM_ALMACEN aa ON aa.Cod_Almacen=@CodAlmacen
	   CROSS JOIN dbo.PRI_EMPRESA pe
	   ORDER BY Orden
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_VIS_MESA_ResumenCaja' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_VIS_MESA_ResumenCaja
GO

CREATE PROCEDURE USP_VIS_MESA_ResumenCaja
	@Cod_Caja varchar(5)
WITH ENCRYPTION
AS
    SELECT  TOP 1 pe.RUC,COALESCE(pe.Nom_Comercial,pe.RazonSocial) Nom_Empresa,GETDATE() Fecha_Servidor , ccd.Cod_Caja,cc.Des_Caja,ccd.Impresora,(SELECT COUNT(*) FROM dbo.VIS_MESAS vm WHERE vm.Estado=1) Total_Mesas FROM dbo.CAJ_CAJAS_DOC ccd 
    INNER JOIN dbo.CAJ_CAJAS cc ON ccd.Cod_Caja = cc.Cod_Caja
    CROSS JOIN dbo.PRI_EMPRESA pe
    WHERE ccd.Cod_Caja=@Cod_Caja AND ccd.Flag_Imprimir=1 AND ccd.Cod_TipoComprobante IN ('FE','BE','NCE','NDE','CO')
    AND ccd.Nom_Archivo IS NOT NULL AND LEN(RTRIM(LTRIM(ccd.Nom_Archivo)))>0 AND ccd.Impresora IS NOT NULL AND LEN(RTRIM(LTRIM(ccd.Impresora)))>0
GO



IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_COMPROBANTE_PAGO_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK @id_ComprobantePago INT
WITH ENCRYPTION
AS
     BEGIN
         
    SELECT 
           @id_ComprobantePago id_ComprobantePago,
           CASE
               WHEN ccp.Cod_TipoComprobante = 'BE'
               THEN 'BOLETA ELECTRONICA'
               WHEN ccp.Cod_TipoComprobante = 'FE'
               THEN 'FACTURA ELECTRONICA'
               WHEN ccp.Cod_TipoComprobante = 'NCE'
               THEN 'NOTA DE CREDITO ELECTRONICA ELECTRONICA'
               WHEN ccp.Cod_TipoComprobante = 'NDE'
               THEN 'NOTA DE CREDITO ELECTRONICA'
               WHEN ccp.Cod_TipoComprobante = 'BO'
               THEN 'BOLETA'
               WHEN ccp.Cod_TipoComprobante = 'FA'
               THEN 'FACTURA'
               WHEN ccp.Cod_TipoComprobante = 'NC'
               THEN 'NOTA DE CREDITO'
               WHEN ccp.Cod_TipoComprobante = 'ND'
               THEN 'NOTA DE DEBITO'
               WHEN ccp.Cod_TipoComprobante = 'TKB'
               THEN 'TICKET BOLETA'
               WHEN ccp.Cod_TipoComprobante = 'TKF'
               THEN 'TICKET FACTURA'
               ELSE ''
           END Nom_TipoComprobante,
           ccp.Serie,
           ccp.Numero,
           CASE
               WHEN ccp.Cod_TipoDoc = '0'
                    OR ccp.Cod_TipoDoc = '99'
               THEN 'SIN'
               WHEN ccp.Cod_TipoDoc = '6'
               THEN 'RUC'
               WHEN ccp.Cod_TipoDoc = '7'
               THEN 'PASAPORTE'
               WHEN ccp.Cod_TipoDoc = '4'
               THEN 'CARNET DE EXTRANJERIA'
               WHEN ccp.Cod_TipoDoc = 'A'
               THEN 'CÉDULA DIPLOMÁTICA DE IDENTIDAD'
               WHEN ccp.Cod_TipoDoc = '1'
               THEN 'DNI'
               ELSE 'SIN'
           END Nom_TipoDoc,
           ccp.Doc_Cliente,
           ccp.Nom_Cliente,
           ccp.Direccion_Cliente,
           ccp.FechaEmision,
           ccp.FechaVencimiento,
           ccp.FechaCancelacion,
           ccp.Glosa,
           ccp.TipoCambio,
           ccp.Flag_Anulado,
           CASE
               WHEN ccp.Cod_FormaPago = '008'
               THEN 'EFECTIVO'
               WHEN ccp.Cod_FormaPago = '007'
               THEN 'CHEQUES'
               WHEN ccp.Cod_FormaPago = '011'
               THEN 'DEPOSITO EN CUENTA'
               WHEN ccp.Cod_FormaPago = '005'
                    OR ccp.Cod_FormaPago = '006'
               THEN 'TARJETA DE CREDITO/DEBITO'
               WHEN ccp.Cod_FormaPago = '002'
               THEN 'GIRO'
               WHEN ccp.Cod_FormaPago = '998'
               THEN 'PAGO ADELANTADO'
               WHEN ccp.Cod_FormaPago = '999'
               THEN 'CREDITO'
               ELSE 'OTROS TIPOS DE PAGO'
           END Nom_FormaPago,
           ccp.Descuento_Total,
           CASE
               WHEN ccp.Cod_Moneda = 'PEN'
               THEN 'SOLES'
               WHEN ccp.Cod_Moneda = 'USD'
               THEN 'DOLARES'
               WHEN ccp.Cod_Moneda = 'EUR'
               THEN 'EUROS'
               ELSE 'OTRAS MONEDAS'
           END Nom_Moneda,
           CASE
               WHEN ccp.Cod_Moneda = 'PEN'
               THEN 'S/'
               WHEN ccp.Cod_Moneda = 'USD'
               THEN '$'
               WHEN ccp.Cod_Moneda = '€'
               THEN 'EUROS'
               ELSE ''
           END Simbolo,
           CASE
               WHEN ccp.Cod_Moneda = 'PEN'
               THEN 'SOLES'
               WHEN ccp.Cod_Moneda = 'USD'
               THEN 'DOLARES'
               WHEN ccp.Cod_Moneda = 'EUR'
               THEN 'EUROS'
               ELSE 'OTRAS MONEDAS'
           END Definicion,
           ccp.Impuesto,
           ccp.Total,
           CONVERT(varchar(255), CASE ccp.Cod_TipoComprobante
               WHEN 'NCE'
               THEN dbo.UFN_CAJ_COMPROBANTE_RELACION_TConcatenado(ccp.id_ComprobantePago, 'CRE')
               WHEN 'NDE'
               THEN dbo.UFN_CAJ_COMPROBANTE_RELACION_TConcatenado(ccp.id_ComprobantePago, 'DEB')
               ELSE ''
           END ) Obs_Comprobante,
           ccp.GuiaRemision,
           ccp.Nro_Ticketera,
           ccp.Cod_UsuarioVendedor,
           ccp.Cod_RegimenPercepcion,
           ccp.Tasa_Percepcion,
           ccp.Placa_Vehiculo,
           ccp.Cod_TipoDocReferencia,
           ccp.Nro_DocReferencia,
           ccp.Valor_Resumen,
           ccp.Valor_Firma,
           ccp.MotivoAnulacion,
           ccp.Otros_Cargos,
           ccp.Otros_Tributos,
           pp.Cod_Producto,
           aa.Des_Almacen,
           aa.Des_CortaAlmacen,
           ccd.Cantidad,
           vudm.Nom_UnidadMedida,
           CONVERT(varchar(max), ccd.Descripcion) Descripcion,
		 ccd.PrecioUnitario,
           ccd.Descuento,
           ccd.Sub_Total,
           CASE
               WHEN pp.Cod_TipoOperatividad = 'GRT'
               THEN 'GRATUITAS'
               WHEN pp.Cod_TipoOperatividad = 'GRA'
               THEN 'GRAVADAS'
               WHEN pp.Cod_TipoOperatividad = 'INA'
               THEN 'INAFECTAS'
               WHEN pp.Cod_TipoOperatividad = 'EXO'
               THEN 'EXONERADAS'
               WHEN pp.Cod_TipoOperatividad = 'DES'
               THEN 'DESCUENTOS'
               WHEN pp.Cod_TipoOperatividad = 'PER'
               THEN 'PERCECPION'
               WHEN pp.Cod_TipoOperatividad = 'NGR'
               THEN 'NO GRAVADAS'
               ELSE 'OTROS'
           END Nom_TipoOperatividad,
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
           NULL Foto,
           dbo.UFN_ConvertirNumeroLetra(ccp.Total)+' '+CASE
                                                           WHEN ccp.Cod_Moneda = 'PEN'
                                                           THEN 'SOLES'
                                                           WHEN ccp.Cod_Moneda = 'USD'
                                                           THEN 'DOLARES'
                                                           WHEN ccp.Cod_Moneda = 'EUR'
                                                           THEN 'EUROS'
                                                           ELSE 'OTRAS MONEDAS'
                                                       END Monto_Letras
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
         LEFT JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
         INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
         INNER JOIN dbo.ALM_ALMACEN aa ON ccd.Cod_Almacen = aa.Cod_Almacen
         INNER JOIN dbo.VIS_UNIDADES_DE_MEDIDA vudm ON ccd.Cod_UnidadMedida = vudm.Cod_UnidadMedida
         INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
    WHERE ccp.id_ComprobantePago = @id_ComprobantePago
     END;
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'URP_CAJ_FORMA_PAGO_TXIdComprobantePago' 
	 AND type = 'P'
)
  DROP PROCEDURE URP_CAJ_FORMA_PAGO_TXIdComprobantePago
GO

CREATE PROCEDURE URP_CAJ_FORMA_PAGO_TXIdComprobantePago
	@Id_ComprobantePago int
WITH ENCRYPTION
AS
BEGIN
    IF  (SELECT COUNT(*) FROM dbo.CAJ_FORMA_PAGO cfp WHERE cfp.id_ComprobantePago=@Id_ComprobantePago)>=1
	BEGIN
	SELECT cfp.Item,
		cfp.Des_FormaPago,
		cfp.Cod_TipoFormaPago,
		cfp.Cuenta_CajaBanco,
		cfp.Id_Movimiento,
		cfp.TipoCambio,
		cfp.Cod_Moneda,
		vm.Nom_Moneda,
		cfp.Monto,
		cfp.Obs_FormaPago.value('(/Observacion/Recibido/node())[1]', 'numeric(38,2)') Recibido,
		cfp.Obs_FormaPago.value('(/Observacion/Vuelto/node())[1]', 'numeric(38,2)') Vuelto,
		cfp.Cod_Caja,
		cfp.Cod_Turno,
		cfp.Cod_Plantilla,
		cfp.Fecha,
		cfp.Obs_FormaPago
		FROM dbo.CAJ_FORMA_PAGO cfp
		INNER JOIN dbo.VIS_MONEDAS vm ON cfp.Cod_Moneda = vm.Cod_Moneda
		WHERE cfp.id_ComprobantePago = @Id_ComprobantePago
	END
	ELSE
	BEGIN
		--Esta a credito
		SELECT 1 Item,'CREDITO' Des_FormaPago,'999' Cod_TipoFormaPago,'' Cuenta_CajaBanco,0 Id_Movimiento, 1 TipoCambio,'PEN' Cod_Moneda,'SOLES' Nom_Moneda, 0 Monto , 0 Recibido, 0 Vuelto,'' Cod_Caja,'' Cod_Turno,'' Cod_Plantilla ,GETDATE() Fecha,NULL Obs_FormaPago
	END

END
GO

