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
	@CodAlmacen  varchar(5)
AS
BEGIN
    WITH	 PRIMERORDEN(id_Detalle,Padre,Cod_Manguera,Numero,Cod_UsuarioReg,FechaEmision,Cantidad,Descripcion,Nivel)
    AS 
    (
	   SELECT ccd.id_Detalle,CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,ccp.Numero,ccp.Cod_UsuarioReg,ccp.FechaEmision,ccd.Cantidad,ccd.Descripcion, 0 Nivel
	   FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
	   WHERE (ccp.id_ComprobantePago=@Id_ComprobantePago
	   AND ccd.Cod_Almacen=@CodAlmacen AND ccd.IGV=0)
	   UNION ALL
	   SELECT ccd.id_Detalle, CONVERT(int,ccd.IGV) Grupo,ccd.Cod_Manguera,res.Numero,res.Cod_UsuarioReg,res.FechaEmision,ccd.Cantidad,ccd.Descripcion, Nivel + 1  Nivel
	   FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
	   WHERE ccd.id_ComprobantePago=@Id_ComprobantePago
    )
    SELECT CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,p.id_Detalle) END Orden, p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
    CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE NULL END Cantidad_Principal, 
    CASE WHEN p.Nivel=0 THEN NULL ELSE p.Cantidad END Cantidad_Auxiliar,
    p.Descripcion, p.Nivel 
    FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
    ORDER BY Orden
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
    vtc.Nom_TipoComprobante,
    CASE WHEN p.Padre=0 THEN CONCAT(p.id_Detalle,'0') ELSE CONCAT(p.Padre,p.id_Detalle) END Orden, 
    p.id_Detalle, p.Padre, p.Cod_Manguera Cod_Mesa,vm.Nom_Mesa, p.Numero, p.Cod_UsuarioReg, p.FechaEmision, 
    CASE WHEN p.Nivel=0 THEN p.Cantidad ELSE NULL END Cantidad_Principal, 
    CASE WHEN p.Nivel=0 THEN NULL ELSE p.Cantidad END Cantidad_Auxiliar,
    p.Descripcion,ccd.PrecioUnitario,ccd.Sub_Total,ccp.Total,ccp.Cod_UsuarioVendedor, p.Nivel 
    FROM PRIMERORDEN p INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera=vm.Cod_Mesa
    INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON @Id_ComprobanteComanda=ccp.id_ComprobantePago
    INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago AND p.id_Detalle=ccd.id_Detalle
    CROSS JOIN dbo.PRI_EMPRESA pe
    ORDER BY Orden
END
GO

--
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

--NOTAS DE CREDITO
--exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 26127,'NC','14','B101','PEN','2016-04-29 00:00:00:000','2018-06-08 00:00:00:000'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota' AND type = 'P')
DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota
go
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 
@IdCliente int,
@CodTipoComprobanteNota varchar(10),
@CodLibro varchar(10),
@Serie varchar(10),
@CodMoneda varchar(10) = NULL,
@FechaInicio datetime,
@FechaFin datetime 
WITH ENCRYPTION
AS
BEGIN
    SET DATEFORMAT ymd;
    --NC : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
    IF(@CodTipoComprobanteNota='NC') 
    BEGIN
	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
	   CP.Cod_Turno,
	   CP.Glosa
	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
	   AND CP.Flag_Anulado	 = 0 
	   AND CP.Cod_Libro = @CodLibro 
	   AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
	   AND CP.Id_Cliente = @IdCliente
	   AND CP.FechaEmision>=@FechaInicio 
	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
	   AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
	   HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
    END
    --NCE : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
    IF(@CodTipoComprobanteNota='NCE') 
    BEGIN
	   IF(LEFT(@Serie,1) ='F')
	   BEGIN
		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
		  CP.Cod_Turno,
		  CP.Glosa
		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
		  WHERE   
		  cp.Cod_TipoComprobante   IN ('FE') 
		  AND CP.Serie LIKE 'F%'
		  AND CP.Flag_Anulado	 = 0 
		  AND CP.Cod_Libro = @CodLibro 
		  AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
		  AND CP.Id_Cliente = @IdCliente
		  AND CP.FechaEmision>=@FechaInicio 
		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
		  HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
	   END
	   IF(LEFT(@Serie,1) ='B')
	   BEGIN
		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
		  CP.Cod_Turno,
		  CP.Glosa
		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
		  WHERE   
		  cp.Cod_TipoComprobante   IN ('BE') 
		  AND CP.Serie LIKE 'B%'
		  AND CP.Flag_Anulado	 = 0 
		  AND CP.Cod_Libro = @CodLibro 
		  AND (CR.Cod_TipoRelacion = 'CRE' OR CR.Cod_TipoRelacion IS NULL)
		  AND CP.Id_Cliente = @IdCliente
		  AND CP.FechaEmision>=@FechaInicio 
		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
		  HAVING AVG(CP.Total)-SUM(ISNULL(abs(CN.Total), 0)) > 0
	   END
    END
    --ND : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
    IF(@CodTipoComprobanteNota='ND')
    BEGIN
	   SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
	   CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
	   SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
	   CP.Cod_Turno,
	   CP.Glosa
	   FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
	   CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
	   LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
	   WHERE   cp.Cod_TipoComprobante   IN ('FE','BE','TKB','TKF','FA','BO') 
	   AND CP.Flag_Anulado	 = 0 
	   AND CP.Cod_Libro = @CodLibro
	   AND CP.Id_Cliente = @IdCliente
	   AND CP.FechaEmision>=@FechaInicio 
	   AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
	   AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
	   GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
    END	
    --NDE : : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
    IF(@CodTipoComprobanteNota='NDE') 
    BEGIN
	   IF(LEFT(@Serie,1) ='F')
	   BEGIN
		 SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
		  CP.Cod_Turno,
		  CP.Glosa
		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
		  WHERE   
		  cp.Cod_TipoComprobante   IN ('FE') 
		  AND cp.Serie LIKE 'F%'
		  AND CP.Flag_Anulado	 = 0 
		  AND CP.Cod_Libro = @CodLibro
		  AND CP.Id_Cliente = @IdCliente
		  AND CP.FechaEmision>=@FechaInicio 
		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
	   END
	   IF(LEFT(@Serie,1) ='B')
	   BEGIN
		  SELECT DISTINCT   CP.id_ComprobantePago,CP.FechaEmision,CP.Cod_Moneda,
		  CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+CP.Numero Documento ,CP.Doc_Cliente+':'+CP.Nom_Cliente Cliente, AVG(CP.Total) AS Total,
		  SUM(ISNULL(abs(CN.Total), 0)) AS TotalNotas, AVG(CP.Total)- SUM(ISNULL(abs(CN.Total), 0)) AS Disponible,
		  CP.Cod_Turno,
		  CP.Glosa
		  FROM   CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
		  CAJ_COMPROBANTE_RELACION AS CR ON CR.Id_ComprobanteRelacion = CP.id_ComprobantePago					 
		  LEFT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CN  ON CN.id_ComprobantePago = CR.id_ComprobantePago
		  WHERE   
		  cp.Cod_TipoComprobante   IN ('BE') 
		  AND cp.Serie LIKE 'B%'
		  AND CP.Flag_Anulado	 = 0 
		  AND CP.Cod_Libro = @CodLibro
		  AND CP.Id_Cliente = @IdCliente
		  AND CP.FechaEmision>=@FechaInicio 
		  AND CP.FechaEmision< DATEADD(day,1, @FechaFin)
		  AND ((@CodMoneda IS NULL AND CP.Cod_Moneda<>'') OR (CP.Cod_Moneda = @CodMoneda))
		  GROUP BY CP.id_ComprobantePago, CP.FechaEmision,CP.Cod_TipoComprobante,CP.Serie,CP.Numero,CP.Doc_Cliente,CP.Nom_Cliente,CP.Cod_Turno,CP.Glosa,CP.Cod_Moneda
	   END
    END
END
go


-- IF EXISTS
-- (
--     SELECT *
--     FROM sysobjects
--     WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante;
-- GO
-- CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante @IdComprobantePago INT
-- AS
--      BEGIN
--          SELECT DISTINCT
--                 a.id_ComprobantePago,
--                 a.id_Detalle,
--                 a.Id_Producto,
--                 a.Cod_Almacen,
--                 a.Cantidad,
--                 a.Cod_UnidadMedida,
--                 a.Despachado,
--                 a.Descripcion,
--                 a.PrecioUnitario,
--                 a.Descuento,
--                 a.Sub_Total,
--                 a.Tipo,
--                 a.Obs_ComprobanteD,
--                 a.Cod_Manguera,
--                 a.Flag_AplicaImpuesto,
--                 a.Formalizado,
--                 a.Valor_NoOneroso,
--                 a.Cod_TipoISC,
--                 a.Porcentaje_ISC,
--                 a.ISC,
--                 a.Cod_TipoIGV,
--                 a.Porcentaje_IGV,
--                 a.IGV,
--                 a.Cod_UsuarioReg,
--                 a.Fecha_Reg,
--                 a.Cod_UsuarioAct,
--                 a.Fecha_Act,
--                 a.Cod_TipoComprobante,
--                 a.Serie SerieComprobante,
--                 a.Numero,
--                 a.FechaEmision,
--                 a.Cod_FormaPago,
--                 a.Cod_Moneda,
--                 a.Otros_Cargos,
--                 a.Otros_Tributos,
--                 b.Serie,
--                 a.TipoCambio
--          FROM
-- (
--     SELECT ROW_NUMBER() OVER(ORDER BY ccd.id_ComprobantePago,
--                                       ccd.id_Detalle ASC) Id,
--            ccd.*,
--            ccp.Cod_TipoComprobante,
--            ccp.Serie,
--            ccp.Numero,
--            ccp.FechaEmision,
--            ccp.Cod_FormaPago,
--            ccp.Cod_Moneda,
-- 		 ccp.TipoCambio,
--            ccp.Otros_Cargos,
--            ccp.Otros_Tributos
--     FROM dbo.CAJ_COMPROBANTE_D ccd
--          INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
--     WHERE ccd.id_ComprobantePago = @IdComprobantePago
-- ) a
-- FULL OUTER JOIN
-- (
--     SELECT ROW_NUMBER() OVER(ORDER BY cs.Id_Tabla,
--                                       cs.Item ASC) Id,
--            cs.*
--     FROM dbo.CAJ_SERIES cs
--     WHERE cs.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
--           AND cs.Id_Tabla = @IdComprobantePago
-- ) b ON a.Id = b.Id
--        AND a.id_Detalle = b.Item;
--      END;
-- GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante @IdComprobantePago INT
AS
BEGIN
         SELECT DISTINCT
       ccd.id_ComprobantePago,
       ccd.id_Detalle,
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
       ccp.Cod_Libro,
       ccp.Cod_Periodo,
       ccp.Cod_Caja,
       ccp.Cod_Turno,
       ccp.Cod_TipoOperacion,
       ccp.Cod_TipoComprobante,
       ccp.Serie SerieComprobante,
       ccp.Numero,
       ccp.Id_Cliente,
       ccp.Cod_TipoDoc,
       ccp.Doc_Cliente,
       ccp.Nom_Cliente,
       ccp.Direccion_Cliente,
       ccp.FechaEmision,
       ccp.FechaVencimiento,
       ccp.FechaCancelacion,
       ccp.Glosa,
       ccp.TipoCambio,
       ccp.Flag_Anulado,
       ccp.Flag_Despachado,
       ccp.Cod_FormaPago,
       ccp.Descuento_Total,
       ccp.Cod_Moneda,
       ccp.Impuesto,
       ccp.Total,
       ccp.Id_GuiaRemision,
       ccp.GuiaRemision,
       ccp.id_ComprobanteRef,
       ccp.Cod_Plantilla,
       ccp.Nro_Ticketera,
       ccp.Cod_UsuarioVendedor,
       ccp.Cod_RegimenPercepcion,
       ccp.Tasa_Percepcion,
       ccp.Placa_Vehiculo,
       ccp.Cod_TipoDocReferencia,
       ccp.Nro_DocReferencia,
       ccp.Cod_EstadoComprobante,
       ccp.MotivoAnulacion,
       ccp.Otros_Cargos,
       ccp.Otros_Tributos,
       dbo.UFN_CAJ_COMPROBANTE_D_Serie(ccp.id_ComprobantePago, ccd.id_Detalle) Serie
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
     INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE ccp.id_ComprobantePago = @IdComprobantePago
END
GO



IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante
@id_ComprobantePago as int
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT vtc.Cod_Sunat as Cod_TipoComprobante, ccp2.Serie+'-'+ ccp2.Numero as Comprobante
    FROM dbo.CAJ_COMPROBANTE_RELACION ccr INNER JOIN 
    dbo.CAJ_COMPROBANTE_PAGO ccp ON ccr.Id_ComprobanteRelacion = ccp.id_ComprobantePago INNER JOIN
    dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccr.id_ComprobantePago = ccp2.id_ComprobantePago INNER JOIN
    dbo.VIS_TIPO_COMPROBANTES vtc ON ccp2.Cod_TipoComprobante = vtc.Cod_TipoComprobante
    WHERE ccr.Cod_TipoRelacion IN ('CRE','DEB') AND
    ccp.id_ComprobantePago=@id_ComprobantePago
END
GO


IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta
GO

CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta
	@IdComprobantePago int, 
	@IdComprobanteNota int,
	@CodTiponota varchar(max),
	@Justificacion varchar(max),
	@CodUsuario varchar(max)
WITH ENCRYPTION
AS
BEGIN
    --ANULACION COMPLETA
    IF(@CodTiponota IN ('01','02'))
    BEGIN
    --Editamos CAJ_FORMA_PAGO
    UPDATE dbo.CAJ_FORMA_PAGO
    SET
        dbo.CAJ_FORMA_PAGO.Monto=0,
	   dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario,
	   dbo.CAJ_FORMA_PAGO.Fecha_Act=GETDATE()
    WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
    --Editamos ALMACEN_MOV
    UPDATE dbo.ALM_ALMACEN_MOV
    SET
        dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO',
	   dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct=@CodUsuario,
	   dbo.ALM_ALMACEN_MOV.Fecha_Act=GETDATE()
    WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago
    --Editamos ALMACEN_MOV_D
    UPDATE dbo.ALM_ALMACEN_MOV_D
    SET
	   dbo.ALM_ALMACEN_MOV_D.Precio_Unitario=0,
	   dbo.ALM_ALMACEN_MOV_D.Cantidad=0,
	   dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct=@CodUsuario,
	   dbo.ALM_ALMACEN_MOV_D.Fecha_Act=GETDATE()
    WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov = (SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Id_ComprobantePago=@IdComprobantePago)
    --Editamos PRI_LICITACIONES_M
    DELETE dbo.PRI_LICITACIONES_M WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago=@IdComprobantePago
    --Editamos CAJ_COMPROBANTE_D
    UPDATE dbo.CAJ_COMPROBANTE_D
    SET
        dbo.CAJ_COMPROBANTE_D.Formalizado -= ccr.Valor,
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
    FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago AND ccd.id_Detalle = ccr.id_Detalle
    WHERE ccr.Id_ComprobanteRelacion=@IdComprobantePago
    --Editamos CAJ_SERIES
    DELETE FROM dbo.CAJ_SERIES
    WHERE (dbo.CAJ_SERIES.Id_Tabla = @IdComprobantePago AND dbo.CAJ_SERIES.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
    --Editamos CAJ_COMPROBANTE_RELACION
    DELETE dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion=@IdComprobantePago
    --Editamos CAJ_COMPROBANTE_PAGO
    UPDATE dbo.CAJ_COMPROBANTE_PAGO
    SET
        dbo.CAJ_COMPROBANTE_PAGO.Glosa='ANULADO',
	   dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago='004',
        dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
        dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobantePago
    END

    --CORECCION POR ERROR EN LA DESCRIPCION
    --No se hace nada

    ----DESCUENTO GLOBAL,DESCUENTO POR ITEM,BONIFICACION,DISMINUCION EN EL VALOR,OTROS CONCEPTOS
    --IF(@CodTiponota IN ('04','05','08','09','10'))
    --BEGIN
    ----Editamos CAJ_FORMA_PAGO
    ----Debemos obtener el total de la nota de credito, luego debemos de obtener la razon entre el total de la nota y el total del comprobante y multiplicar por ese valor 
    ----Todos los items de la forma de pago
    --DECLARE @TotalNota numeric(38,6) = (SELECT ccp.Total FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago = @IdComprobanteNota)
    --DECLARE @TotalComprobante numeric(38,6) = (SELECT ISNULL(SUM(cfp.Monto),0) FROM dbo.CAJ_FORMA_PAGO cfp WHERE cfp.id_ComprobantePago = @IdComprobantePago)
    --DECLARE @Factor numeric(38,6) = (1 - (@TotalNota/@TotalComprobante))
    --UPDATE dbo.CAJ_FORMA_PAGO
    --SET
    --    dbo.CAJ_FORMA_PAGO.Monto=dbo.CAJ_FORMA_PAGO.Monto*@Factor
    --WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
    --END

    --DEVOLUCION TOTAL
    IF(@CodTiponota IN ('06'))
    BEGIN
    --Editamos CAJ_FORMA_PAGO
    UPDATE dbo.CAJ_FORMA_PAGO
    SET
        dbo.CAJ_FORMA_PAGO.Monto=0,
	   dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario,
	   dbo.CAJ_FORMA_PAGO.Fecha_Act=GETDATE()
    WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
    --Editamos ALMACEN_MOV
    UPDATE dbo.ALM_ALMACEN_MOV
    SET
        dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO',
	   dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct=@CodUsuario,
	   dbo.ALM_ALMACEN_MOV.Fecha_Act=GETDATE()
    WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago
    --Editamos ALMACEN_MOV_D
    UPDATE dbo.ALM_ALMACEN_MOV_D
    SET
	   dbo.ALM_ALMACEN_MOV_D.Precio_Unitario=0,
	   dbo.ALM_ALMACEN_MOV_D.Cantidad=0,
	   dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct=@CodUsuario,
	   dbo.ALM_ALMACEN_MOV_D.Fecha_Act=GETDATE()
    WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov = (SELECT aam.Id_AlmacenMov FROM dbo.ALM_ALMACEN_MOV aam WHERE aam.Id_ComprobantePago=@IdComprobantePago)
    --Editamos PRI_LICITACIONES_M
    DELETE dbo.PRI_LICITACIONES_M WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago=@IdComprobantePago
    --Editamos CAJ_COMPROBANTE_D
    UPDATE dbo.CAJ_COMPROBANTE_D
    SET
        dbo.CAJ_COMPROBANTE_D.Formalizado -= ccr.Valor,
	   dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct=@CodUsuario,
	   dbo.CAJ_COMPROBANTE_D.Fecha_Act=GETDATE()
    FROM dbo.CAJ_COMPROBANTE_D ccd INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago AND ccd.id_Detalle = ccr.id_Detalle
    WHERE ccr.Id_ComprobanteRelacion=@IdComprobantePago
    --Insertamos CAJ_SERIES
    INSERT dbo.CAJ_SERIES
    (
        Cod_Tabla,
        Id_Tabla,
        Item,
        Serie,
        Fecha_Vencimiento,
        Obs_Serie,
        Cod_UsuarioReg,
        Fecha_Reg,
        Cod_UsuarioAct,
        Fecha_Act
    )
    SELECT 
    'CAJ_COMPROBANTE_PAGO',
    @IdComprobanteNota,
    cs.Item,
    cs.Serie,
    cs.Fecha_Vencimiento,
    cs.Obs_Serie,
    @CodUsuario,
    GETDATE(),
    NULL,
    NULL
    FROM dbo.CAJ_SERIES cs
    WHERE cs.Id_Tabla = @IdComprobantePago
    AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO'
    --Editamos CAJ_COMPROBANTE_RELACION
    DELETE dbo.CAJ_COMPROBANTE_RELACION WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion=@IdComprobantePago
    --Editamos CAJ_COMPROBANTE_PAGO
    UPDATE dbo.CAJ_COMPROBANTE_PAGO
    SET
        dbo.CAJ_COMPROBANTE_PAGO.Glosa='ANULADO',
	   dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago='004',
        dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
        dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdComprobantePago
    END

    --DEVOLUCION POR ITEM
    IF(@CodTiponota IN ('07'))
    BEGIN
    --Editamos CAJ_FORMA_PAGO

    --Insertamos CAJ_SERIES
    INSERT dbo.CAJ_SERIES
    (
        Cod_Tabla,
        Id_Tabla,
        Item,
        Serie,
        Fecha_Vencimiento,
        Obs_Serie,
        Cod_UsuarioReg,
        Fecha_Reg,
        Cod_UsuarioAct,
        Fecha_Act
    )
    SELECT 
    'CAJ_COMPROBANTE_PAGO',
    @IdComprobanteNota,
    cs.Item,
    cs.Serie,
    cs.Fecha_Vencimiento,
    cs.Obs_Serie,
    @CodUsuario,
    GETDATE(),
    NULL,
    NULL
    FROM dbo.CAJ_SERIES cs
    WHERE cs.Id_Tabla = @IdComprobantePago
    AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO'

    END
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
	SET @ScripSQL='SELECT NumeroFila,Cod_Cuenta , Id_ClienteProveedor , Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max , Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Cuenta , Id_ClienteProveedor , Des_Cuenta , Cod_TipoCuenta , Monto_Deposito , Interes , Meses_Max , Limite_Max , Flag_ITF , Cod_Moneda , Cod_EstadoCuenta , Saldo_Contable , Saldo_Disponible , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
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
 
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'CUE_CLIENTE_CUENTA_D' 
	  AND 	 type = 'U')
    DROP TABLE CUE_CLIENTE_CUENTA_D
GO

CREATE TABLE CUE_CLIENTE_CUENTA_D(
	Cod_Cuenta varchar (32) NOT NULL,
	item int NOT NULL,
	Des_CuentaD varchar(512) NOT NULL,
	Saldo numeric(38,6) NOT NULL,
	Capital_Amortizado numeric(38,6) NOT NULL,
	Monto numeric(38, 6) NOT NULL,
	Cancelado numeric(38, 6) NOT NULL,
	Interes numeric(38, 6) NOT NULL,
	Mora numeric(38, 6) NOT NULL,
	Fecha_Emision datetime NOT NULL ,
	Fecha_Vencimiento datetime NOT NULL,
	Cod_EstadoDCuenta varchar(3) NULL,
	Cod_UsuarioReg varchar(32) NOT NULL,
	Fecha_Reg datetime NOT NULL,
	Cod_UsuarioAct varchar(32) NULL,
	Fecha_Act datetime NULL,
PRIMARY KEY NONCLUSTERED 
(
	Cod_Cuenta ASC,
	item ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE CUE_CLIENTE_CUENTA_D  WITH CHECK ADD FOREIGN KEY(Cod_Cuenta)
REFERENCES CUE_CLIENTE_CUENTA (Cod_Cuenta)
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