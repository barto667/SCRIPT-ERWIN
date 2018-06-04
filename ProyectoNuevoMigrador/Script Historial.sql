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
WITH ENCRYPTION
AS
BEGIN
--Se identifica la orden de comanda CO cuando no esta tendida, es decir no tiene cod_caja (null) ni cod_turno(null)
    SELECT * FROM (SELECT DISTINCT vm.Cod_Mesa,vm.Nom_Mesa,
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
    ORDER BY a.Nom_Mesa,a.Fecha_Reg
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