--PRI_PRODUCTOS
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'Cod_ProductoSunat'
          AND TABLE_NAME = 'PRI_PRODUCTOS'
)
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX);
        SELECT @Sentencia = COALESCE(@Sentencia + ';' + CHAR(13) + CHAR(10), '') + CONCAT('ALTER TABLE ', tables.name, ' DROP CONSTRAINT ', default_constraints.name)
        FROM sys.all_columns
             INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
             INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
             INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
        WHERE schemas.name = 'dbo'
              AND tables.name = 'PRI_PRODUCTOS';
        EXEC (@Sentencia);
        ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTOS SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_PRODUCTOS ADD Cod_ProductoSunat VARCHAR(64);
        ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioReg VARCHAR(32) NOT NULL DEFAULT('''');
        ALTER TABLE PRI_PRODUCTOS ADD Fecha_Reg DATETIME NOT NULL DEFAULT(GETDATE());
        ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTOS SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Cod_ProductoSunat = ''''');
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Acth;
END;
GO
--PRI_PRODUCTO_STOCK
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME IN('Precio_Flete','Peso')
          AND TABLE_NAME = 'PRI_PRODUCTO_STOCK'
)
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX);
        SELECT @Sentencia = COALESCE(@Sentencia + ';' + CHAR(13) + CHAR(10), '') + CONCAT('ALTER TABLE ', tables.name, ' DROP CONSTRAINT ', default_constraints.name)
        FROM sys.all_columns
             INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
             INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
             INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
        WHERE schemas.name = 'dbo' AND tables.name = 'PRI_PRODUCTO_STOCK';
        EXEC (@Sentencia);
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Acth DATETIME NULL;
		    EXEC('UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioRegh = Cod_UsuarioReg, Fecha_Regh = Fecha_Reg, Cod_UsuarioActh = Cod_UsuarioAct, Fecha_Acth = Fecha_Act')
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Precio_Flete NUMERIC(38, 6);
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Peso NUMERIC(38, 6);
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioReg VARCHAR(32) NOT NULL DEFAULT('');
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Reg DATETIME NOT NULL DEFAULT(GETDATE());
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Act DATETIME NULL;
        EXEC('UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioReg = Cod_UsuarioRegh,Fecha_Reg = Fecha_Regh,Cod_UsuarioAct = Cod_UsuarioActh,Fecha_Act = Fecha_Acth,Precio_Flete = 0,Peso = 0')
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Acth;
END;
GO
--CAJ_SERIES
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'Cantidad'
          AND TABLE_NAME = 'CAJ_SERIES'
)
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX);
        SELECT @Sentencia = COALESCE(@Sentencia + ';' + CHAR(13) + CHAR(10), '') + CONCAT('ALTER TABLE ', tables.name, ' DROP CONSTRAINT ', default_constraints.name)
        FROM sys.all_columns
             INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
             INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
             INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
        WHERE schemas.name = 'dbo' AND tables.name = 'CAJ_SERIES';
        EXEC (@Sentencia);
        ALTER TABLE CAJ_SERIES ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE CAJ_SERIES ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE CAJ_SERIES ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE CAJ_SERIES ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE CAJ_SERIES SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Reg;
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Act;
        ALTER TABLE CAJ_SERIES ADD Cantidad numeric(38,6);
        ALTER TABLE CAJ_SERIES ADD Cod_UsuarioReg VARCHAR(32) NOT NULL DEFAULT('''');
        ALTER TABLE CAJ_SERIES ADD Fecha_Reg DATETIME NOT NULL DEFAULT(GETDATE());
        ALTER TABLE CAJ_SERIES ADD Cod_UsuarioAct VARCHAR(32) NULL;
		    ALTER TABLE CAJ_SERIES ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE CAJ_SERIES SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Cantidad = 0');
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Regh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Acth;
END;
GO
--PRI_CLIENTE_PROVEEDOR
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME IN ('Ubicacion_EjeX','Ubicacion_EjeY','Ruta')
          AND TABLE_NAME = 'PRI_CLIENTE_PROVEEDOR'
)
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX);
        SELECT @Sentencia = COALESCE(@Sentencia + ';' + CHAR(13) + CHAR(10), '') + CONCAT('ALTER TABLE ', tables.name, ' DROP CONSTRAINT ', default_constraints.name)
        FROM sys.all_columns
             INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
             INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
             INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
        WHERE schemas.name = 'dbo'
              AND tables.name = 'PRI_CLIENTE_PROVEEDOR';
        EXEC (@Sentencia);
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Ubicacion_EjeX numeric(38,6);
		    ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Ubicacion_EjeY numeric(38,6);
		    ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Ruta VARCHAR(2048);
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioReg VARCHAR(32) NOT NULL DEFAULT('''');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Reg DATETIME NOT NULL DEFAULT(GETDATE());
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth,Ubicacion_EjeX=0,Ubicacion_EjeY=0, Ruta = ''''');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Acth;
END;
GO

--CRUD BASICO

--PRI_PRODUCTOS
-- Guardar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_G
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_G 
	@Id_Producto	int output, 
	@Cod_Producto	varchar(64), 
	@Cod_Categoria	varchar(32), 
	@Cod_Marca	varchar(32), 
	@Cod_TipoProducto	varchar(5), 
	@Nom_Producto	varchar(512), 
	@Des_CortaProducto	varchar(512), 
	@Des_LargaProducto	varchar(1024), 
	@Caracteristicas	varchar(MAX), 
	@Porcentaje_Utilidad	numeric(5,2), 
	@Cuenta_Contable	varchar(16), 
	@Contra_Cuenta	varchar(16), 
	@Cod_Garantia	varchar(5), 
	@Cod_TipoExistencia	varchar(5), 
	@Cod_TipoOperatividad	varchar(5), 
	@Flag_Activo	bit, 
	@Flag_Stock	bit, 
	@Cod_Fabricante	varchar(64), 
	@Obs_Producto	xml,
	@Cod_ProductoSunat varchar(64),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Id_Producto FROM PRI_PRODUCTOS WHERE  (Id_Producto = @Id_Producto))
	BEGIN
		INSERT INTO PRI_PRODUCTOS  VALUES (
		@Cod_Producto,
		@Cod_Categoria,
		@Cod_Marca,
		@Cod_TipoProducto,
		@Nom_Producto,
		@Des_CortaProducto,
		@Des_LargaProducto,
		@Caracteristicas,
		@Porcentaje_Utilidad,
		@Cuenta_Contable,
		@Contra_Cuenta,
		@Cod_Garantia,
		@Cod_TipoExistencia,
		@Cod_TipoOperatividad,
		@Flag_Activo,
		@Flag_Stock,
		@Cod_Fabricante,
		@Obs_Producto,
		@Cod_ProductoSunat,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_Producto = @@IDENTITY 
	END
	ELSE
	BEGIN
		UPDATE PRI_PRODUCTOS
		SET	
			Cod_Producto = @Cod_Producto, 
			Cod_Categoria = @Cod_Categoria, 
			Cod_Marca = @Cod_Marca, 
			Cod_TipoProducto = @Cod_TipoProducto, 
			Nom_Producto = @Nom_Producto, 
			Des_CortaProducto = @Des_CortaProducto, 
			Des_LargaProducto = @Des_LargaProducto, 
			Caracteristicas = @Caracteristicas, 
			Porcentaje_Utilidad = @Porcentaje_Utilidad, 
			Cuenta_Contable = @Cuenta_Contable, 
			Contra_Cuenta = @Contra_Cuenta, 
			Cod_Garantia = @Cod_Garantia, 
			Cod_TipoExistencia = @Cod_TipoExistencia, 
			Cod_TipoOperatividad = @Cod_TipoOperatividad, 
			Flag_Activo = @Flag_Activo, 
			Flag_Stock = @Flag_Stock, 
			Cod_Fabricante = @Cod_Fabricante, 
			Obs_Producto = @Obs_Producto,
			Cod_ProductoSunat = @Cod_ProductoSunat,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto)	
	END
END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_TT
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_Producto , Cod_Producto , Cod_Categoria , Cod_Marca , Cod_TipoProducto , Nom_Producto , Des_CortaProducto , Des_LargaProducto , Caracteristicas , Porcentaje_Utilidad , Cuenta_Contable , Contra_Cuenta , Cod_Garantia , Cod_TipoExistencia , Cod_TipoOperatividad , Flag_Activo , Flag_Stock , Cod_Fabricante , Obs_Producto, Cod_ProductoSunat , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_PRODUCTOS
END
go
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_TP
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Id_Producto , Cod_Producto , Cod_Categoria , Cod_Marca , Cod_TipoProducto , Nom_Producto , Des_CortaProducto , Des_LargaProducto , Caracteristicas , Porcentaje_Utilidad , Cuenta_Contable , Contra_Cuenta , Cod_Garantia , Cod_TipoExistencia , Cod_TipoOperatividad , Flag_Activo , Flag_Stock , Cod_Fabricante , Obs_Producto , Cod_ProductoSunat , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Producto , Cod_Producto , Cod_Categoria , Cod_Marca , Cod_TipoProducto , Nom_Producto , Des_CortaProducto , Des_LargaProducto , Caracteristicas , Porcentaje_Utilidad , Cuenta_Contable , Contra_Cuenta , Cod_Garantia , Cod_TipoExistencia , Cod_TipoOperatividad , Flag_Activo , Flag_Stock , Cod_Fabricante , Obs_Producto, Cod_ProductoSunat , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_PRODUCTOS '+@ScripWhere+') aPRI_PRODUCTOS
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
GO
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_TXPK
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_TXPK 
	@Id_Producto	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_Producto, Cod_Producto, Cod_Categoria, Cod_Marca, Cod_TipoProducto, Nom_Producto, Des_CortaProducto, Des_LargaProducto, Caracteristicas, Porcentaje_Utilidad, Cuenta_Contable, Contra_Cuenta, Cod_Garantia, Cod_TipoExistencia, Cod_TipoOperatividad, Flag_Activo, Flag_Stock, Cod_Fabricante, Obs_Producto, Cod_ProductoSunat , Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_PRODUCTOS
	WHERE (Id_Producto = @Id_Producto)	
END
GO

--PRI_PRODUCTO_STOCK
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_G
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_G 
	@Id_Producto	int, 
	@Cod_UnidadMedida	varchar(5), 
	@Cod_Almacen	varchar(32), 
	@Cod_Moneda	varchar(5), 
	@Precio_Compra	numeric(38,6), 
	@Precio_Venta	numeric(38,6), 
	@Stock_Min	numeric(38,6), 
	@Stock_Max	numeric(38,6), 
	@Stock_Act	numeric(38,6), 
	@Cod_UnidadMedidaMin	varchar(5), 
	@Cantidad_Min	numeric(38,6),
	@Precio_Flete numeric(38,6),
	@Peso numeric(38,6),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen FROM PRI_PRODUCTO_STOCK WHERE  (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen))
	BEGIN
		INSERT INTO PRI_PRODUCTO_STOCK  VALUES (
		@Id_Producto,
		@Cod_UnidadMedida,
		@Cod_Almacen,
		@Cod_Moneda,
		@Precio_Compra,
		@Precio_Venta,
		@Stock_Min,
		@Stock_Max,
		@Stock_Act,
		@Cod_UnidadMedidaMin,
		@Cantidad_Min,
		@Precio_Flete,
		@Peso,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_PRODUCTO_STOCK
		SET	
			Cod_Moneda = @Cod_Moneda, 
			Precio_Compra = @Precio_Compra, 
			Precio_Venta = @Precio_Venta, 
			Stock_Min = @Stock_Min, 
			Stock_Max = @Stock_Max, 
			Stock_Act = @Stock_Act, 
			Cod_UnidadMedidaMin = @Cod_UnidadMedidaMin, 
			Cantidad_Min = @Cantidad_Min,
			Precio_Flete = @Precio_Flete,
			Peso = @Peso,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)	
	END
END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TT
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_Producto , Cod_UnidadMedida , Cod_Almacen , Cod_Moneda , Precio_Compra , Precio_Venta , Stock_Min , Stock_Max , Stock_Act , Cod_UnidadMedidaMin , Cantidad_Min , Precio_Flete, Peso , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_PRODUCTO_STOCK
END
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TP
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Id_Producto , Cod_UnidadMedida , Cod_Almacen , Cod_Moneda , Precio_Compra , Precio_Venta , Stock_Min , Stock_Max , Stock_Act , Cod_UnidadMedidaMin , Cantidad_Min, Precio_Flete, Peso , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_Producto , Cod_UnidadMedida , Cod_Almacen , Cod_Moneda , Precio_Compra , Precio_Venta , Stock_Min , Stock_Max , Stock_Act , Cod_UnidadMedidaMin , Cantidad_Min, Precio_Flete, Peso , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_PRODUCTO_STOCK '+@ScripWhere+') aPRI_PRODUCTO_STOCK
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
GO
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TXPK
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TXPK 
	@Id_Producto	int, 
	@Cod_UnidadMedida	varchar(5), 
	@Cod_Almacen	varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_Producto, Cod_UnidadMedida, Cod_Almacen, Cod_Moneda, Precio_Compra, Precio_Venta, Stock_Min, Stock_Max, Stock_Act, Cod_UnidadMedidaMin, Cantidad_Min, Precio_Flete, Peso , Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_PRODUCTO_STOCK
	WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)	
END
GO

--CAJ_SERIES
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_G' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_G
go
CREATE PROCEDURE USP_CAJ_SERIES_G 
	@Cod_Tabla	varchar(64), 
	@Id_Tabla	int, 
	@Item	int, 
	@Serie	varchar(512), 
	@Fecha_Vencimiento	datetime, 
	@Obs_Serie	varchar(1024),
	@Cantidad numeric(38,6),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Tabla, @Id_Tabla, @Item, @Serie FROM CAJ_SERIES WHERE  (Cod_Tabla = @Cod_Tabla) AND (Id_Tabla = @Id_Tabla) AND (Item = @Item) AND (Serie = @Serie))
	BEGIN
		INSERT INTO CAJ_SERIES  VALUES (
		@Cod_Tabla,
		@Id_Tabla,
		@Item,
		@Serie,
		@Fecha_Vencimiento,
		@Obs_Serie,
		@Cantidad,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_SERIES
		SET	
			Fecha_Vencimiento = @Fecha_Vencimiento, 
			Obs_Serie = @Obs_Serie,
			Cantidad = @Cantidad,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Tabla = @Cod_Tabla) AND (Id_Tabla = @Id_Tabla) AND (Item = @Item) AND (Serie = @Serie)	
	END
END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_TT' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_TT
go
CREATE PROCEDURE USP_CAJ_SERIES_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Tabla , Id_Tabla , Item , Serie , Fecha_Vencimiento , Obs_Serie , Cantidad , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM CAJ_SERIES
END
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_TP' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_TP
go
CREATE PROCEDURE USP_CAJ_SERIES_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Cod_Tabla , Id_Tabla , Item , Serie , Fecha_Vencimiento , Obs_Serie , Cantidad , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Cod_Tabla , Id_Tabla , Item , Serie , Fecha_Vencimiento , Obs_Serie, Cantidad , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM CAJ_SERIES '+@ScripWhere+') aCAJ_SERIES
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
GO
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_SERIES_TXPK' AND type = 'P')
	DROP PROCEDURE USP_CAJ_SERIES_TXPK
go
CREATE PROCEDURE USP_CAJ_SERIES_TXPK 
	@Cod_Tabla	varchar(64), 
	@Id_Tabla	int, 
	@Item	int, 
	@Serie	varchar(512)
WITH ENCRYPTION
AS
BEGIN
	SELECT Cod_Tabla, Id_Tabla, Item, Serie, Fecha_Vencimiento, Obs_Serie, Cantidad , Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM CAJ_SERIES
	WHERE (Cod_Tabla = @Cod_Tabla) AND (Id_Tabla = @Id_Tabla) AND (Item = @Item) AND (Serie = @Serie)	
END
GO

--PRI_CLIENTE_PROVEEDOR
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_G' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G 
	@Id_ClienteProveedor	int output, 
	@Cod_TipoDocumento	varchar(3), 
	@Nro_Documento	varchar(32), 
	@Cliente	varchar(512), 
	@Ap_Paterno	varchar(128), 
	@Ap_Materno	varchar(128), 
	@Nombres	varchar(128), 
	@Direccion	varchar(512), 
	@Cod_EstadoCliente	varchar(3), 
	@Cod_CondicionCliente	varchar(3), 
	@Cod_TipoCliente	varchar(3), 
	@RUC_Natural	varchar(32), 
	@Foto	binary, 
	@Firma	binary, 
	@Cod_TipoComprobante	varchar(5), 
	@Cod_Nacionalidad	varchar(8), 
	@Fecha_Nacimiento	datetime, 
	@Cod_Sexo	varchar(3), 
	@Email1	varchar(1024), 
	@Email2	varchar(1024), 
	@Telefono1	varchar(512), 
	@Telefono2	varchar(512), 
	@Fax	varchar(512), 
	@PaginaWeb	varchar(512), 
	@Cod_Ubigeo	varchar(8), 
	@Cod_FormaPago	varchar(3), 
	@Limite_Credito	numeric(38,2), 
	@Obs_Cliente	xml, 
	@Num_DiaCredito	int,
	@Ubicacion_EjeX numeric(38,6),
	@Ubicacion_EjeY numeric(38,6),
	@Ruta varchar(2048),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor))
	BEGIN
		INSERT INTO PRI_CLIENTE_PROVEEDOR  VALUES (
		@Cod_TipoDocumento,
		@Nro_Documento,
		@Cliente,
		@Ap_Paterno,
		@Ap_Materno,
		@Nombres,
		@Direccion,
		@Cod_EstadoCliente,
		@Cod_CondicionCliente,
		@Cod_TipoCliente,
		@RUC_Natural,
		@Foto,
		@Firma,
		@Cod_TipoComprobante,
		@Cod_Nacionalidad,
		@Fecha_Nacimiento,
		@Cod_Sexo,
		@Email1,
		@Email2,
		@Telefono1,
		@Telefono2,
		@Fax,
		@PaginaWeb,
		@Cod_Ubigeo,
		@Cod_FormaPago,
		@Limite_Credito,
		@Obs_Cliente,
		@Num_DiaCredito,
		@Ubicacion_EjeX,
		@Ubicacion_EjeY,
		@Ruta,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_ClienteProveedor = @@IDENTITY 
	END
	ELSE
	BEGIN
		UPDATE PRI_CLIENTE_PROVEEDOR
		SET	
			Cod_TipoDocumento = @Cod_TipoDocumento, 
			Nro_Documento = @Nro_Documento, 
			Cliente = @Cliente, 
			Ap_Paterno = @Ap_Paterno, 
			Ap_Materno = @Ap_Materno, 
			Nombres = @Nombres, 
			Direccion = @Direccion, 
			Cod_EstadoCliente = @Cod_EstadoCliente, 
			Cod_CondicionCliente = @Cod_CondicionCliente, 
			Cod_TipoCliente = @Cod_TipoCliente, 
			RUC_Natural = @RUC_Natural, 
			Foto = @Foto, 
			Firma = @Firma, 
			Cod_TipoComprobante = @Cod_TipoComprobante, 
			Cod_Nacionalidad = @Cod_Nacionalidad, 
			Fecha_Nacimiento = @Fecha_Nacimiento, 
			Cod_Sexo = @Cod_Sexo, 
			Email1 = @Email1, 
			Email2 = @Email2, 
			Telefono1 = @Telefono1, 
			Telefono2 = @Telefono2, 
			Fax = @Fax, 
			PaginaWeb = @PaginaWeb, 
			Cod_Ubigeo = @Cod_Ubigeo, 
			Cod_FormaPago = @Cod_FormaPago, 
			Limite_Credito = @Limite_Credito, 
			Obs_Cliente = @Obs_Cliente, 
			Num_DiaCredito = @Num_DiaCredito,
			Ubicacion_EjeX = @Ubicacion_EjeX,
			Ubicacion_EjeY = @Ubicacion_EjeY,
			Ruta = @Ruta,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor)	
	END
END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TT' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_ClienteProveedor , Cod_TipoDocumento , Nro_Documento , Cliente , Ap_Paterno , Ap_Materno , Nombres , Direccion , Cod_EstadoCliente , Cod_CondicionCliente , Cod_TipoCliente , RUC_Natural , Foto , Firma , Cod_TipoComprobante , Cod_Nacionalidad , Fecha_Nacimiento , Cod_Sexo , Email1 , Email2 , Telefono1 , Telefono2 , Fax , PaginaWeb , Cod_Ubigeo , Cod_FormaPago , Limite_Credito , Obs_Cliente , Num_DiaCredito , Ubicacion_EjeX, Ubicacion_EjeY, Ruta , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM PRI_CLIENTE_PROVEEDOR
END
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TP' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Id_ClienteProveedor , Cod_TipoDocumento , Nro_Documento , Cliente , Ap_Paterno , Ap_Materno , Nombres , Direccion , Cod_EstadoCliente , Cod_CondicionCliente , Cod_TipoCliente , RUC_Natural , Foto , Firma , Cod_TipoComprobante , Cod_Nacionalidad , Fecha_Nacimiento , Cod_Sexo , Email1 , Email2 , Telefono1 , Telefono2 , Fax , PaginaWeb , Cod_Ubigeo , Cod_FormaPago , Limite_Credito , Obs_Cliente , Num_DiaCredito , Ubicacion_EjeX, Ubicacion_EjeY, Ruta , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
	FROM (SELECT TOP 100 PERCENT Id_ClienteProveedor , Cod_TipoDocumento , Nro_Documento , Cliente , Ap_Paterno , Ap_Materno , Nombres , Direccion , Cod_EstadoCliente , Cod_CondicionCliente , Cod_TipoCliente , RUC_Natural , Foto , Firma , Cod_TipoComprobante , Cod_Nacionalidad , Fecha_Nacimiento , Cod_Sexo , Email1 , Email2 , Telefono1 , Telefono2 , Fax , PaginaWeb , Cod_Ubigeo , Cod_FormaPago , Limite_Credito , Obs_Cliente , Num_DiaCredito , Ubicacion_EjeX, Ubicacion_EjeY, Ruta , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM PRI_CLIENTE_PROVEEDOR '+@ScripWhere+') aPRI_CLIENTE_PROVEEDOR
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
GO
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TXPK' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK 
	@Id_ClienteProveedor	int
WITH ENCRYPTION
AS
BEGIN
	SELECT Id_ClienteProveedor, Cod_TipoDocumento, Nro_Documento, Cliente, Ap_Paterno, Ap_Materno, Nombres, Direccion, Cod_EstadoCliente, Cod_CondicionCliente, Cod_TipoCliente, RUC_Natural, Foto, Firma, Cod_TipoComprobante, Cod_Nacionalidad, Fecha_Nacimiento, Cod_Sexo, Email1, Email2, Telefono1, Telefono2, Fax, PaginaWeb, Cod_Ubigeo, Cod_FormaPago, Limite_Credito, Obs_Cliente, Num_DiaCredito , Ubicacion_EjeX, Ubicacion_EjeY, Ruta , Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act 
	FROM PRI_CLIENTE_PROVEEDOR
	WHERE (Id_ClienteProveedor = @Id_ClienteProveedor)	
END
GO

--TRIGGERS
--PRI_PRODUCTOS
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTOS_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTOS_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTOS_IUD
ON dbo.PRI_PRODUCTOS
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTOS'
	--Variables de tabla secundarias
	DECLARE @Cod_Producto varchar(64)
	DECLARE @Cod_Categoria varchar(32)
	DECLARE @Cod_Marca varchar(32)
	DECLARE @Cod_TipoProducto varchar(5)
	DECLARE @Nom_Producto varchar(512)
	DECLARE @Des_CortaProducto varchar(512)
	DECLARE @Des_LargaProducto varchar(1024)
	DECLARE @Caracteristicas varchar(max)
	DECLARE @Porcentaje_Utilidad numeric(5,2)
	DECLARE @Cuenta_Contable varchar(16)
	DECLARE @Contra_Cuenta varchar(16)
	DECLARE @Cod_Garantia varchar(5)
	DECLARE @Cod_TipoExistencia varchar(5)
	DECLARE @Cod_TipoOperatividad varchar(5)
	DECLARE @Flag_Activo bit
	DECLARE @Flag_Stock bit
	DECLARE @Cod_Fabricante varchar(64)
	DECLARE @Obs_Producto XML
	DECLARE @Cod_ProductoSunat varchar(64)
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
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Producto,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_PRODUCTOS_I ' +
			  CASE WHEN Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Producto,'''','')+''','END+
			  CASE WHEN Cod_Categoria  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Categoria,'''','')+''','END+
			  CASE WHEN Cod_Marca  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Marca,'''','')+''','END+
			  CASE WHEN Cod_TipoProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoProducto,'''','')+''','END+
			  CASE WHEN Nom_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nom_Producto,'''','')+''','END+
			  CASE WHEN Des_CortaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_CortaProducto,'''','')+''','END+
			  CASE WHEN Des_LargaProducto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Des_LargaProducto,'''','')+''','END+
			  CASE WHEN Caracteristicas  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Caracteristicas,'''','')+''','END+
			  CASE WHEN Porcentaje_Utilidad  IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), Porcentaje_Utilidad)+','END+
			  CASE WHEN Cuenta_Contable  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cuenta_Contable,'''','')+''','END+
			  CASE WHEN Contra_Cuenta  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Contra_Cuenta,'''','')+''','END+
			  CASE WHEN Cod_Garantia  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Garantia,'''','')+''','END+
			  CASE WHEN Cod_TipoExistencia  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoExistencia,'''','')+''','END+
			  CASE WHEN Cod_TipoOperatividad  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoOperatividad,'''','')+''','END+
			  CONVERT(VARCHAR(MAX),Flag_Activo)+','+
			  CONVERT(VARCHAR(MAX),Flag_Stock)+','+
			  CASE WHEN Cod_Fabricante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Fabricante,'''','')+''','END+
			  CASE WHEN Obs_Producto IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(VARCHAR(MAX),Obs_Producto),'''','')+''','END+
			  CASE WHEN Cod_ProductoSunat  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_ProductoSunat,'''','')+''','END+
			  ''''+ REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','')+''';' 
			  FROM            INSERTED
			  WHERE INSERTED.Id_Producto=@Id_Producto
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
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
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
		    d.Id_Producto,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_PRODUCTOS_D ' +
			  CASE WHEN Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Producto,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED 
			  WHERE Id_Producto=@Id_Producto

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
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
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
			 i.Id_Producto,
			 i.Cod_Producto,
			 i.Cod_Categoria,
			 i.Cod_Marca,
			 i.Cod_TipoProducto,
			 i.Nom_Producto,
			 i.Des_CortaProducto,
			 i.Des_LargaProducto,
			 i.Caracteristicas,
			 i.Porcentaje_Utilidad,
			 i.Cuenta_Contable,
			 i.Contra_Cuenta,
			 i.Cod_Garantia,
			 i.Cod_TipoExistencia,
			 i.Cod_TipoOperatividad,
			 i.Flag_Activo,
			 i.Flag_Stock,
			 i.Cod_Fabricante,
			 i.Obs_Producto,
			 i.Cod_ProductoSunat,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_Producto,
			 @Cod_Categoria,
			 @Cod_Marca,
			 @Cod_TipoProducto,
			 @Nom_Producto,
			 @Des_CortaProducto,
			 @Des_LargaProducto,
			 @Caracteristicas,
			 @Porcentaje_Utilidad,
			 @Cuenta_Contable,
			 @Contra_Cuenta,
			 @Cod_Garantia,
			 @Cod_TipoExistencia,
			 @Cod_TipoOperatividad,
			 @Flag_Activo,
			 @Flag_Stock,
			 @Cod_Fabricante,
			 @Obs_Producto,
			 @Cod_ProductoSunat,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Producto,'|' ,
			 @Cod_Categoria,'|' ,
			 @Cod_Marca,'|' ,
			 @Cod_TipoProducto,'|' ,
			 @Nom_Producto,'|' ,
			 @Des_CortaProducto,'|' ,
			 @Des_LargaProducto,'|' ,
			 @Caracteristicas,'|' ,
			 @Porcentaje_Utilidad,'|' ,
			 @Cuenta_Contable,'|' ,
			 @Contra_Cuenta,'|' ,
			 @Cod_Garantia,'|' ,
			 @Cod_TipoExistencia,'|' ,
			 @Cod_TipoOperatividad,'|' ,
			 @Flag_Activo,'|' ,
			 @Flag_Stock,'|' ,
			 @Cod_Fabricante,'|' ,
			 CONVERT(varchar(max),@Obs_Producto),'|' ,
			 @Cod_ProductoSunat,'|',
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
			  CONCAT('',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )
		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_Producto,
			 @Cod_Categoria,
			 @Cod_Marca,
			 @Cod_TipoProducto,
			 @Nom_Producto,
			 @Des_CortaProducto,
			 @Des_LargaProducto,
			 @Caracteristicas,
			 @Porcentaje_Utilidad,
			 @Cuenta_Contable,
			 @Contra_Cuenta,
			 @Cod_Garantia,
			 @Cod_TipoExistencia,
			 @Cod_TipoOperatividad,
			 @Flag_Activo,
			 @Flag_Stock,
			 @Cod_Fabricante,
			 @Obs_Producto,
			 @Cod_ProductoSunat,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END
    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_Producto,
			 d.Cod_Categoria,
			 d.Cod_Marca,
			 d.Cod_TipoProducto,
			 d.Nom_Producto,
			 d.Des_CortaProducto,
			 d.Des_LargaProducto,
			 d.Caracteristicas,
			 d.Porcentaje_Utilidad,
			 d.Cuenta_Contable,
			 d.Contra_Cuenta,
			 d.Cod_Garantia,
			 d.Cod_TipoExistencia,
			 d.Cod_TipoOperatividad,
			 d.Flag_Activo,
			 d.Flag_Stock,
			 d.Cod_Fabricante,
			 d.Obs_Producto,
			 d.Cod_ProductoSunat,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_Producto,
			 @Cod_Categoria,
			 @Cod_Marca,
			 @Cod_TipoProducto,
			 @Nom_Producto,
			 @Des_CortaProducto,
			 @Des_LargaProducto,
			 @Caracteristicas,
			 @Porcentaje_Utilidad,
			 @Cuenta_Contable,
			 @Contra_Cuenta,
			 @Cod_Garantia,
			 @Cod_TipoExistencia,
			 @Cod_TipoOperatividad,
			 @Flag_Activo,
			 @Flag_Stock,
			 @Cod_Fabricante,
			 @Obs_Producto,
			 @Cod_ProductoSunat,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_Producto,'|' ,
			 @Cod_Categoria,'|' ,
			 @Cod_Marca,'|' ,
			 @Cod_TipoProducto,'|' ,
			 @Nom_Producto,'|' ,
			 @Des_CortaProducto,'|' ,
			 @Des_LargaProducto,'|' ,
			 @Caracteristicas,'|' ,
			 @Porcentaje_Utilidad,'|' ,
			 @Cuenta_Contable,'|' ,
			 @Contra_Cuenta,'|' ,
			 @Cod_Garantia,'|' ,
			 @Cod_TipoExistencia,'|' ,
			 @Cod_TipoOperatividad,'|' ,
			 @Flag_Activo,'|' ,
			 @Flag_Stock,'|' ,
			 @Cod_Fabricante,'|' ,
			 CONVERT(varchar(max),@Obs_Producto),'|' ,
			 @Cod_ProductoSunat, '|',
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
			   CONCAT('',@Id_Producto), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )
		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_Producto,
			 @Cod_Categoria,
			 @Cod_Marca,
			 @Cod_TipoProducto,
			 @Nom_Producto,
			 @Des_CortaProducto,
			 @Des_LargaProducto,
			 @Caracteristicas,
			 @Porcentaje_Utilidad,
			 @Cuenta_Contable,
			 @Contra_Cuenta,
			 @Cod_Garantia,
			 @Cod_TipoExistencia,
			 @Cod_TipoOperatividad,
			 @Flag_Activo,
			 @Flag_Stock,
			 @Cod_Fabricante,
			 @Obs_Producto,
			 @Cod_ProductoSunat,
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

--PRI_PRODUCTO_STOCK
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_PRODUCTO_STOCK_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
GO

CREATE TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
ON dbo.PRI_PRODUCTO_STOCK
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Id_Producto int
	DECLARE @Cod_UnidadMedida varchar(5)
	DECLARE @Cod_Almacen varchar(32)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='PRI_PRODUCTO_STOCK'
	--Variables de tabla secundarias
	DECLARE @Cod_Moneda varchar(5)
	DECLARE @Precio_Compra numeric(38,6)
	DECLARE @Precio_Venta numeric(38,6)
	DECLARE @Stock_Min numeric(38,6)
	DECLARE @Stock_Max numeric(38,6)
	DECLARE @Stock_Act numeric(38,6)
	DECLARE @Cod_UnidadMedidaMin varchar(5)
	DECLARE @Cantidad_Min numeric(38,6)
	DECLARE @Precio_Flete numeric(38,6)
	DECLARE @Peso numeric(38,6)
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
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_Producto,
		    i.Cod_UnidadMedida,
		    i.Cod_Almacen,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_STOCK_I ' +
				 CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+
				 CASE WHEN S.Cod_UnidadMedida  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedida,'''','')+''','END+
				 CASE WHEN S.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Almacen,'''','')+''','END+
				 CASE WHEN S.Cod_Moneda  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Moneda,'''','')+''','END+
				 CASE WHEN S.Precio_Compra  IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Precio_Compra)+','END+
				 CASE WHEN S.Precio_Venta IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Precio_Venta)+','END+
				 CASE WHEN S.Stock_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Min)+','END+
				 CASE WHEN S.Stock_Max IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Stock_Max)+','END+
				 CASE WHEN S.Stock_Act IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX), S.Stock_Act)+','END+
				 CASE WHEN S.Cod_UnidadMedidaMin IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedidaMin,'''','')+''','END+
				 CASE WHEN S.Cantidad_Min IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Cantidad_Min)+','END+
				 CASE WHEN S.Precio_Flete IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Precio_Flete)+','END+
				 CASE WHEN S.Peso IS NULL THEN 'NULL,' ELSE CONVERT(VARCHAR(MAX), S.Peso)+','END+
				 ''''+ REPLACE(COALESCE(S.Cod_UsuarioAct,S.Cod_UsuarioReg),'''','')+''';' 
				 FROM INSERTED AS S INNER JOIN
					  PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
				 WHERE S.Id_Producto=@Id_Producto AND S.Cod_UnidadMedida=@Cod_UnidadMedida AND S.Cod_Almacen=@Cod_Almacen

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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
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
		    d.Id_Producto,
		    d.Cod_UnidadMedida,
		    d.Cod_Almacen,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
				 SELECT @Script= 'USP_PRI_PRODUCTO_STOCK_D ' +
				 CASE WHEN P.Cod_Producto  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(P.Cod_Producto,'''','')+''','END+
				 CASE WHEN S.Cod_UnidadMedida  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_UnidadMedida,'''','')+''','END+
				 CASE WHEN S.Cod_Almacen  IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(S.Cod_Almacen,'''','')+''','END+
				 ''''+'TRIGGER'+''',' +
			     ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
				 FROM DELETED S INNER JOIN
					  PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
				 WHERE S.Id_Producto=@Id_Producto AND S.Cod_UnidadMedida=@Cod_UnidadMedida AND S.Cod_Almacen=@Cod_Almacen

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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @Id_Producto,
		    @Cod_UnidadMedida,
		    @Cod_Almacen,
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
			 i.Id_Producto,
			 i.Cod_UnidadMedida,
			 i.Cod_Almacen,
			 i.Cod_Moneda,
			 i.Precio_Compra,
			 i.Precio_Venta,
			 i.Stock_Min,
			 i.Stock_Max,
			 i.Stock_Act,
			 i.Cod_UnidadMedidaMin,
			 i.Cantidad_Min,
			 i.Precio_Flete,
			 i.Peso,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_Moneda,
			 @Precio_Compra,
			 @Precio_Venta,
			 @Stock_Min,
			 @Stock_Max,
			 @Stock_Act,
			 @Cod_UnidadMedidaMin,
			 @Cantidad_Min,
			 @Precio_Flete,
			 @Peso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_Moneda,'|' ,
			 @Precio_Compra,'|' ,
			 @Precio_Venta,'|' ,
			 @Stock_Min,'|' ,
			 @Stock_Max,'|' ,
			 @Stock_Act,'|' ,
			 @Cod_UnidadMedidaMin,'|' ,
			 @Cantidad_Min,'|' ,
			 @Precio_Flete,'|' ,
			 @Peso,'|' ,
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
			  CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_Moneda,
			 @Precio_Compra,
			 @Precio_Venta,
			 @Stock_Min,
			 @Stock_Max,
			 @Stock_Act,
			 @Cod_UnidadMedidaMin,
			 @Cantidad_Min,
			 @Precio_Flete,
			 @Peso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_Producto,
			 d.Cod_UnidadMedida,
			 d.Cod_Almacen,
			 d.Cod_Moneda,
			 d.Precio_Compra,
			 d.Precio_Venta,
			 d.Stock_Min,
			 d.Stock_Max,
			 d.Stock_Act,
			 d.Cod_UnidadMedidaMin,
			 d.Cantidad_Min,
			 d.Precio_Flete,
			 d.Peso,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_Moneda,
			 @Precio_Compra,
			 @Precio_Venta,
			 @Stock_Min,
			 @Stock_Max,
			 @Stock_Act,
			 @Cod_UnidadMedidaMin,
			 @Cantidad_Min,
			 @Precio_Flete,
			 @Peso,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_Producto,'|' ,
			 @Cod_UnidadMedida,'|' ,
			 @Cod_Almacen,'|' ,
			 @Cod_Moneda,'|' ,
			 @Precio_Compra,'|' ,
			 @Precio_Venta,'|' ,
			 @Stock_Min,'|' ,
			 @Stock_Max,'|' ,
			 @Stock_Act,'|' ,
			 @Cod_UnidadMedidaMin,'|' ,
			 @Cantidad_Min,'|' ,
			 @Precio_Flete,'|' ,
			 @Peso,'|' ,
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
			   CONCAT(@Id_Producto,'|',@Cod_UnidadMedida,'|',@Cod_Almacen), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_Producto,
			 @Cod_UnidadMedida,
			 @Cod_Almacen,
			 @Cod_Moneda,
			 @Precio_Compra,
			 @Precio_Venta,
			 @Stock_Min,
			 @Stock_Max,
			 @Stock_Act,
			 @Cod_UnidadMedidaMin,
			 @Cantidad_Min,
			 @Precio_Flete,
			 @Peso,
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
--CAJ_SERIES
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_SERIES_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_SERIES_IUD
GO

CREATE TRIGGER UTR_CAJ_SERIES_IUD
ON dbo.CAJ_SERIES
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Cod_Tabla varchar(64)
	DECLARE @Id_Tabla int
	DECLARE @Item int
	DECLARE @Serie varchar(512)
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_SERIES'
	--Variables de tabla secundarias
	DECLARE @Fecha_Vencimiento datetime
	DECLARE @Obs_Serie varchar(1024)
	DECLARE @Cantidad numeric(38,6)
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

	----Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	--IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	--BEGIN
	--    DECLARE cursorbd CURSOR LOCAL FOR
	--	    SELECT
	--	    i.Cod_Tabla,
	--	    i.Id_Tabla,
	--	    i.Item,
	--	    i.Serie,
	--	    i.Fecha_Reg,
	--	    i.Fecha_Act
	--	    FROM INSERTED i
	--    OPEN cursorbd 
	--    FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tabla,
	--	    @Id_Tabla,
	--	    @Item,
	--	    @Serie,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--    WHILE @@FETCH_STATUS = 0
	--    BEGIN
	--		--Si esta habilitada la exportacion para almacenar en la tabla de
	--		--exportaciones





	--	   	SET @FechaReg= GETDATE()
	--		INSERT dbo.TMP_REGISTRO_LOG
	--		(
	--		   --Id,
	--		   Nombre_Tabla,
	--		   Id_Fila,
	--		   Accion,
	--		   Script,
	--		   Fecha_Reg
	--	     )
	--	    VALUES
	--		(
	--		   --NULL, -- Id - uniqueidentifier
	--		   @NombreTabla, -- Nombre_Tabla - varchar
	--		   CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
	--		   @Accion, -- Accion - varchar
	--		   @Script, -- Script - varchar
	--		   @FechaReg -- Fecha_Reg - datetime
	--	     )
	--	  FETCH NEXT FROM cursorbd INTO
	--	    @Cod_Tabla,
	--	    @Id_Tabla,
	--	    @Item,
	--	    @Serie,
	--	    @Fecha_Reg,
	--	    @Fecha_Act
	--	END
	--	CLOSE cursorbd;
 --   	DEALLOCATE cursorbd
 --   END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.Cod_Tabla,
			 i.Id_Tabla,
			 i.Item,
			 i.Serie,
			 i.Fecha_Vencimiento,
			 i.Obs_Serie,
			 i.Cantidad,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Id_Tabla,'|' ,
			 @Item,'|' ,
			 @Serie,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Obs_Serie,'|' ,
			 @Cantidad,'|',
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
			  CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Cod_Tabla,
			 d.Id_Tabla,
			 d.Item,
			 d.Serie,
			 d.Fecha_Vencimiento,
			 d.Obs_Serie,
			 d.Cantidad,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cantidad,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Cod_Tabla,'|' ,
			 @Id_Tabla,'|' ,
			 @Item,'|' ,
			 @Serie,'|' ,
			 CONVERT(varchar,@Fecha_Vencimiento,121), '|' ,
			 @Obs_Serie,'|' ,
			 @Cantidad,'|',
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
			 CONCAT(@Cod_Tabla,'|',@Id_Tabla,'|',@Item,'|',@Serie), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Cod_Tabla,
			 @Id_Tabla,
			 @Item,
			 @Serie,
			 @Fecha_Vencimiento,
			 @Obs_Serie,
			 @Cantidad,
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
--PRI_CLIENTE_PROVEEDOR
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_PRI_CLIENTE_PROVEEDOR_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
GO

CREATE TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
ON dbo.PRI_CLIENTE_PROVEEDOR
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @Id_ClienteProveedor int
	DECLARE @NombreTabla varchar(max)='PRI_CLIENTE_PROVEEDOR'
	--Variables de tabla secundarias
	
	DECLARE @Cod_TipoDocumento varchar(3)
	DECLARE @Nro_Documento varchar(32)
	DECLARE @Cliente varchar(512)
	DECLARE @Ap_Paterno varchar(128)
	DECLARE @Ap_Materno varchar(128)
	DECLARE @Nombres varchar(128)
	DECLARE @Direccion varchar(512)
	DECLARE @Cod_EstadoCliente varchar(3)
	DECLARE @Cod_CondicionCliente varchar(3)
	DECLARE @Cod_TipoCliente varchar(3)
	DECLARE @RUC_Natural varchar(32)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Cod_Nacionalidad varchar(8)
	DECLARE @Fecha_Nacimiento datetime
	DECLARE @Cod_Sexo varchar(3)
	DECLARE @Email1 varchar(1024)
	DECLARE @Email2 varchar(1024)
	DECLARE @Telefono1 varchar(512)
	DECLARE @Telefono2 varchar(512)
	DECLARE @Fax varchar(512)
	DECLARE @PaginaWeb varchar(512)
	DECLARE @Cod_Ubigeo varchar(8)
	DECLARE @Cod_FormaPago varchar(3)
	DECLARE @Limite_Credito numeric(38,2)
	DECLARE @Obs_Cliente xml
	DECLARE @Num_DiaCredito int
	DECLARE @Ubicacion_EjeX numeric(38,6)
	DECLARE @Ubicacion_EjeY numeric(38,6)
	DECLARE @Ruta varchar(2048)
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
	IF @Exportacion=1 AND @Accion IN ('ACTUALIZAR','INSERTAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.Id_ClienteProveedor,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PROVEEDOR_I ' + 
			  CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
			  CASE WHEN Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cliente,'''','')+''','END+
			  CASE WHEN Ap_Paterno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Paterno,'''','')+''','END+
			  CASE WHEN Ap_Materno IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ap_Materno,'''','')+''','END+
			  CASE WHEN Nombres IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nombres,'''','')+''','END+
			  CASE WHEN Direccion IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Direccion,'''','')+''','END+
			  CASE WHEN Cod_EstadoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_EstadoCliente,'''','')+''','END+
			  CASE WHEN Cod_CondicionCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_CondicionCliente,'''','')+''','END+
			  CASE WHEN Cod_TipoCliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoCliente,'''','')+''','END+
			  CASE WHEN RUC_Natural IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(RUC_Natural,'''','')+''','END+
			  'NULL,
			  NULL, '+ 
			  CASE WHEN Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoComprobante,'''','')+''','END+
			  CASE WHEN Cod_Nacionalidad IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Nacionalidad,'''','')+''','END+
			  CASE WHEN Fecha_Nacimiento IS NULL THEN 'NULL' ELSE ''''+ CONVERT(VARCHAR(MAX),Fecha_Nacimiento,121)+''','END+
			  CASE WHEN Cod_Sexo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Sexo,'''','')+''','END+
			  CASE WHEN Email1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email1,'''','')+''','END+
			  CASE WHEN Email2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Email2,'''','')+''','END+
			  CASE WHEN Telefono1 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono1,'''','')+''','END+
			  CASE WHEN Telefono2 IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Telefono2,'''','')+''','END+
			  CASE WHEN Fax IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Fax,'''','')+''','END+
			  CASE WHEN PaginaWeb IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(PaginaWeb,'''','')+''','END+
			  CASE WHEN Cod_Ubigeo IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_Ubigeo,'''','')+''','END+
			  CASE WHEN Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_FormaPago,'''','')+''','END+
			  CASE WHEN Limite_Credito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Limite_Credito)+','END+
			  CASE WHEN Obs_Cliente IS NULL THEN 'NULL,' ELSE ''''+ REPLACE( CONVERT(VARCHAR(MAX),Obs_Cliente),'''','')+''','END+
			  CASE WHEN Num_DiaCredito IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Num_DiaCredito)+','END+
			  CASE WHEN Ubicacion_EjeX IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Ubicacion_EjeX)+','END+
			  CASE WHEN Ubicacion_EjeY IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),Ubicacion_EjeY)+','END+
			  CASE WHEN Ruta IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Ruta,'''','')+''','END+
			  ''''+REPLACE(COALESCE(Cod_UsuarioAct,Cod_UsuarioReg),'''','') +''';' 
			  FROM INSERTED 
			  WHERE Id_ClienteProveedor=@Id_ClienteProveedor

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
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		   @Id_ClienteProveedor,
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
		    d.Id_ClienteProveedor,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @Id_ClienteProveedor,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			  SELECT @Script='USP_PRI_CLIENTE_PROVEEDOR_D ' + 
			  CASE WHEN Cod_TipoDocumento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Cod_TipoDocumento,'''','')+''','END+
			  CASE WHEN Nro_Documento IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(Nro_Documento,'''','')+''','END+
			  ''''+'TRIGGER'+''',' +
			  ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 
			  FROM DELETED  
			  WHERE Id_ClienteProveedor=@Id_ClienteProveedor

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
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		   @Id_ClienteProveedor,
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
			 i.Id_ClienteProveedor,
			 i.Cod_TipoDocumento,
			 i.Nro_Documento,
			 i.Cliente,
			 i.Ap_Paterno,
			 i.Ap_Materno,
			 i.Nombres,
			 i.Direccion,
			 i.Cod_EstadoCliente,
			 i.Cod_CondicionCliente,
			 i.Cod_TipoCliente,
			 i.RUC_Natural,
			 i.Cod_TipoComprobante,
			 i.Cod_Nacionalidad,
			 i.Fecha_Nacimiento,
			 i.Cod_Sexo,
			 i.Email1,
			 i.Email2,
			 i.Telefono1,
			 i.Telefono2,
			 i.Fax,
			 i.PaginaWeb,
			 i.Cod_Ubigeo,
			 i.Cod_FormaPago,
			 i.Limite_Credito,
			 i.Obs_Cliente,
			 i.Num_DiaCredito,
			 i.Ubicacion_EjeX,
			 i.Ubicacion_EjeY,
			 i.Ruta,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
			 @Cliente,
			 @Ap_Paterno,
			 @Ap_Materno,
			 @Nombres,
			 @Direccion,
			 @Cod_EstadoCliente,
			 @Cod_CondicionCliente,
			 @Cod_TipoCliente,
			 @RUC_Natural,
			 @Cod_TipoComprobante,
			 @Cod_Nacionalidad,
			 @Fecha_Nacimiento,
			 @Cod_Sexo,
			 @Email1,
			 @Email2,
			 @Telefono1,
			 @Telefono2,
			 @Fax,
			 @PaginaWeb,
			 @Cod_Ubigeo,
			 @Cod_FormaPago,
			 @Limite_Credito,
			 @Obs_Cliente,
			 @Num_DiaCredito,
			 @Ubicacion_EjeX,
			 @Ubicacion_EjeY,
			 @Ruta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Cliente,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Direccion,'|' ,
			 @Cod_EstadoCliente,'|' ,
			 @Cod_CondicionCliente,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @RUC_Natural,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_Nacionalidad,'|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Sexo,'|' ,
			 @Email1,'|' ,
			 @Email2,'|' ,
			 @Telefono1,'|' ,
			 @Telefono2,'|' ,
			 @Fax,'|' ,
			 @PaginaWeb,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Limite_Credito,'|' ,
			 CONVERT(varchar(max),@Obs_Cliente),'|' ,
			 @Num_DiaCredito,'|' ,
			 @Ubicacion_EjeX,'|',
			 @Ubicacion_EjeY,'|',
			 @Ruta,'|',
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
			  CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
			 @Cliente,
			 @Ap_Paterno,
			 @Ap_Materno,
			 @Nombres,
			 @Direccion,
			 @Cod_EstadoCliente,
			 @Cod_CondicionCliente,
			 @Cod_TipoCliente,
			 @RUC_Natural,
			 @Cod_TipoComprobante,
			 @Cod_Nacionalidad,
			 @Fecha_Nacimiento,
			 @Cod_Sexo,
			 @Email1,
			 @Email2,
			 @Telefono1,
			 @Telefono2,
			 @Fax,
			 @PaginaWeb,
			 @Cod_Ubigeo,
			 @Cod_FormaPago,
			 @Limite_Credito,
			 @Obs_Cliente,
			 @Num_DiaCredito,
			 @Ubicacion_EjeX,
			 @Ubicacion_EjeY,
			 @Ruta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.Id_ClienteProveedor,
			 d.Cod_TipoDocumento,
			 d.Nro_Documento,
			 d.Cliente,
			 d.Ap_Paterno,
			 d.Ap_Materno,
			 d.Nombres,
			 d.Direccion,
			 d.Cod_EstadoCliente,
			 d.Cod_CondicionCliente,
			 d.Cod_TipoCliente,
			 d.RUC_Natural,
			 d.Cod_TipoComprobante,
			 d.Cod_Nacionalidad,
			 d.Fecha_Nacimiento,
			 d.Cod_Sexo,
			 d.Email1,
			 d.Email2,
			 d.Telefono1,
			 d.Telefono2,
			 d.Fax,
			 d.PaginaWeb,
			 d.Cod_Ubigeo,
			 d.Cod_FormaPago,
			 d.Limite_Credito,
			 d.Obs_Cliente,
			 d.Num_DiaCredito,
			 d.Ubicacion_EjeX,
			 d.Ubicacion_EjeY,
			 d.Ruta,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @Id_ClienteProveedor,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
			 @Cliente,
			 @Ap_Paterno,
			 @Ap_Materno,
			 @Nombres,
			 @Direccion,
			 @Cod_EstadoCliente,
			 @Cod_CondicionCliente,
			 @Cod_TipoCliente,
			 @RUC_Natural,
			 @Cod_TipoComprobante,
			 @Cod_Nacionalidad,
			 @Fecha_Nacimiento,
			 @Cod_Sexo,
			 @Email1,
			 @Email2,
			 @Telefono1,
			 @Telefono2,
			 @Fax,
			 @PaginaWeb,
			 @Cod_Ubigeo,
			 @Cod_FormaPago,
			 @Limite_Credito,
			 @Obs_Cliente,
			 @Num_DiaCredito,
			 @Ubicacion_EjeX,
			 @Ubicacion_EjeY,
			 @Ruta,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @Id_ClienteProveedor,'|' ,
			 @Cod_TipoDocumento,'|' ,
			 @Nro_Documento,'|' ,
			 @Cliente,'|' ,
			 @Ap_Paterno,'|' ,
			 @Ap_Materno,'|' ,
			 @Nombres,'|' ,
			 @Direccion,'|' ,
			 @Cod_EstadoCliente,'|' ,
			 @Cod_CondicionCliente,'|' ,
			 @Cod_TipoCliente,'|' ,
			 @RUC_Natural,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Cod_Nacionalidad,'|' ,
			 CONVERT(varchar,@Fecha_Nacimiento,121), '|' ,
			 @Cod_Sexo,'|' ,
			 @Email1,'|' ,
			 @Email2,'|' ,
			 @Telefono1,'|' ,
			 @Telefono2,'|' ,
			 @Fax,'|' ,
			 @PaginaWeb,'|' ,
			 @Cod_Ubigeo,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Limite_Credito,'|' ,
			 CONVERT(varchar(max),@Obs_Cliente),'|' ,
			 @Num_DiaCredito,'|' ,
			 @Ubicacion_EjeX,'|' ,
			 @Ubicacion_EjeY,'|' ,
			 @Ruta,'|' ,
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
			   CONCAT('',@Id_ClienteProveedor), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @Id_ClienteProveedor,
			 @Cod_TipoDocumento,
			 @Nro_Documento,
			 @Cliente,
			 @Ap_Paterno,
			 @Ap_Materno,
			 @Nombres,
			 @Direccion,
			 @Cod_EstadoCliente,
			 @Cod_CondicionCliente,
			 @Cod_TipoCliente,
			 @RUC_Natural,
			 @Cod_TipoComprobante,
			 @Cod_Nacionalidad,
			 @Fecha_Nacimiento,
			 @Cod_Sexo,
			 @Email1,
			 @Email2,
			 @Telefono1,
			 @Telefono2,
			 @Fax,
			 @PaginaWeb,
			 @Cod_Ubigeo,
			 @Cod_FormaPago,
			 @Limite_Credito,
			 @Obs_Cliente,
			 @Num_DiaCredito,
			 @Ubicacion_EjeX,
			 @Ubicacion_EjeY,
			 @Ruta,
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

--PROCEDMIENTOS MODIFICADOS
--Se añadio el peso
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOS_Buscar' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar
GO

CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar
@Cod_Caja as  varchar(32)=null,
@Buscar  varchar(512),
@CodTipoProducto as  varchar(8) = NULL,
@Cod_Categoria as  varchar(32) = NULL,
@Cod_Precio as  varchar(32) = NULL,
@Flag_RequiereStock as bit = 0
WITH ENCRYPTION
AS
BEGIN

SET DATEFORMAT dmy;	
--SET @Buscar = REPLACE(@Buscar,'%',' ');
		SELECT        P.Id_Producto, P.Nom_Producto AS Nom_Producto, P.Cod_Producto, PS.Stock_Act, PS.Precio_Venta, 
						M.Nom_Moneda as Nom_Moneda, PS.Cod_Almacen, 0 AS Descuento,
						'NINGUNO' AS TipoDescuento, A.Des_CortaAlmacen as Des_Almacen, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida,P.Flag_Stock,PS.Precio_Compra, 
					case when @Cod_Precio is null then 0 else dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto,PS.Cod_UnidadMedida,PS.Cod_Almacen, @Cod_Precio)
					end as Precio,
					P.Cod_TipoOperatividad,M.Cod_Moneda,Cod_TipoProducto,PS.Peso
		FROM            PRI_PRODUCTOS AS P INNER JOIN
						PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
						VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda INNER JOIN
						ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
						VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
						CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
		WHERE  (P.Cod_TipoProducto = @CodTipoProducto OR @CodTipoProducto IS NULL) 
		AND ( (P.Cod_Producto LIKE @Buscar) OR (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
		AND (P.Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria))  OR @Cod_Categoria IS NULL) 
		AND  (ca.Cod_Caja = @Cod_Caja or @Cod_Caja is null)
		AND (P.Flag_Activo = 1)
		--AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
		order by  Nom_Producto	
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor
GO

CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor
@Cod_Caja as  varchar(32) = null,
@Buscar  varchar(512),
@IdClienteProveedor  int,
@Cod_Categoria as  varchar(32) = NULL
WITH ENCRYPTION
AS
BEGIN
SELECT        P.Id_Producto, P.Des_LargaProducto AS Nom_Producto, P.Cod_Producto, PS.Cod_Almacen, PS.Stock_Act, PS.Precio_Venta as Precio, ISNULL(PP.Nom_TipoPrecio, 
                         'NINGUNO') AS TipoDescuento, CASE PP.Cod_TipoPrecio WHEN '01' THEN 0 WHEN '02' THEN ISNULL(CP.Monto, 0) 
                         WHEN '03' THEN PS.Precio_Venta - ISNULL(CP.Monto, 0) WHEN '04' THEN PS.Precio_Venta * ISNULL(CP.Monto, 0) 
                         / 100 ELSE 0 END AS Descuento, M.Nom_Moneda, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida, A.Des_Almacen,P.Flag_Stock,
                         P.Cod_TipoOperatividad,M.Cod_Moneda,PS.Precio_Compra,PS.Peso
FROM            VIS_MONEDAS AS M INNER JOIN
                         PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto ON M.Cod_Moneda = PS.Cod_Moneda INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
                         ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen LEFT OUTER JOIN
                         VIS_TIPO_PRECIOS AS PP INNER JOIN
                         PRI_CLIENTE_PRODUCTO AS CP ON PP.Cod_TipoPrecio = CP.Cod_TipoDescuento ON P.Id_Producto = CP.Id_Producto
WHERE     (CP.Id_ClienteProveedor = @IdClienteProveedor) OR    (P.Nom_Producto LIKE '%' + @Buscar + '%') AND (P.Flag_Activo = 1) OR
                      (P.Flag_Activo = 1) AND (P.Cod_Producto LIKE @Buscar + '%') OR
                      (P.Flag_Activo = 1) AND (PS.Cod_Almacen = @Buscar)
					   and
                      (@Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)) OR @Cod_Categoria IS NULL) and
  (CA.Cod_Caja=@Cod_Caja or @Cod_Caja is null)
order by Cod_Producto
END
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_TXDocumento'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_TXDocumento;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_TXDocumento @Cod_TipoCliente AS     VARCHAR(32) = NULL, 
                                             @Nro_Documento AS       VARCHAR(32), 
                                             @Cod_TipoDocumento AS   VARCHAR(3), 
                                             @Cod_TipoComprobante AS VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Nro_Documento = @Nro_Documento
        )
            BEGIN
                SELECT CP.Id_ClienteProveedor, 
                       CP.Cod_TipoDocumento, 
                       CP.Nro_Documento, 
                       CP.Cliente, 
                       CP.Direccion, 
                       CP.Telefono1, 
                       CP.Email1, 
                       CP.Cod_EstadoCliente, 
                       CP.Ap_Paterno, 
                       CP.Ap_Materno, 
                       CP.Nombres, 
                       CP.Cod_CondicionCliente, 
                       CP.Cod_TipoCliente, 
                       CP.RUC_Natural, 
                       CP.Cod_TipoComprobante, 
                       CP.Cod_Nacionalidad, 
                       CP.Fecha_Nacimiento, 
                       CP.Cod_Sexo, 
                       CP.Email2, 
                       CP.Telefono2, 
                       CP.Fax, 
                       CP.PaginaWeb, 
                       CP.Cod_Ubigeo, 
                       CP.Cod_FormaPago, 
                       CP.Limite_Credito, 
                       TD.Nom_TipoDoc AS Nom_TipoDocumento
                FROM PRI_CLIENTE_PROVEEDOR AS CP
                     INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc
                WHERE(Nro_Documento = @Nro_Documento);
        END;
            ELSE
            BEGIN
                IF EXISTS
                (
                    SELECT Id_ClienteProveedor
                    FROM PALERPdata.dbo.PRI_CLIENTE_PROVEEDOR
                    WHERE Nro_Documento = @Nro_Documento
                )
                    BEGIN
                        -- INSERTAR EN LA BASE DE DATOS ACTUAL
                        INSERT INTO PRI_CLIENTE_PROVEEDOR
                               SELECT TOP 1 Cod_TipoDocumento, 
                                            Nro_Documento, 
                                            Cliente, 
                                            Ap_Paterno, 
                                            Ap_Materno, 
                                            Nombres, 
                                            Direccion, 
                                            Cod_EstadoCliente, 
                                            Cod_CondicionCliente, 
                                            Cod_TipoCliente, 
                                            RUC_Natural, 
                                            Foto, 
                                            Firma, 
                                            Cod_TipoComprobante, 
                                            Cod_Nacionalidad, 
                                            Fecha_Nacimiento, 
                                            Cod_Sexo, 
                                            Email1, 
                                            Email2, 
                                            Telefono1, 
                                            Telefono2, 
                                            Fax, 
                                            PaginaWeb, 
                                            Cod_Ubigeo, 
                                            Cod_FormaPago, 
                                            Limite_Credito, 
                                            Obs_Cliente, 
                                            0, 
											0,
											0,
											'',
                                            'MIGRACION', 
                                            GETDATE(), 
                                            NULL, 
                                            NULL
                               FROM PALERPdata.dbo.PRI_CLIENTE_PROVEEDOR
                               WHERE Nro_Documento = @Nro_Documento;
                        SELECT CP.Id_ClienteProveedor, 
                               CP.Cod_TipoDocumento, 
                               CP.Nro_Documento, 
                               CP.Cliente, 
                               CP.Direccion, 
                               CP.Telefono1, 
                               CP.Email1, 
                               CP.Cod_EstadoCliente, 
                               CP.Ap_Paterno, 
                               CP.Ap_Materno, 
                               CP.Nombres, 
                               CP.Cod_CondicionCliente, 
                               CP.Cod_TipoCliente, 
                               CP.RUC_Natural, 
                               CP.Cod_TipoComprobante, 
                               CP.Cod_Nacionalidad, 
                               CP.Fecha_Nacimiento, 
                               CP.Cod_Sexo, 
                               CP.Email2, 
                               CP.Telefono2, 
                               CP.Fax, 
                               CP.PaginaWeb, 
                               CP.Cod_Ubigeo, 
                               CP.Cod_FormaPago, 
                               CP.Limite_Credito, 
                               TD.Nom_TipoDoc AS Nom_TipoDocumento
                        FROM PRI_CLIENTE_PROVEEDOR AS CP
                             INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc
                        WHERE(Nro_Documento = @Nro_Documento);
                END;
                    ELSE
                    BEGIN
                        SELECT TOP 0 CP.Id_ClienteProveedor, 
                                     CP.Cod_TipoDocumento, 
                                     CP.Nro_Documento, 
                                     CP.Cliente, 
                                     CP.Direccion, 
                                     CP.Telefono1, 
                                     CP.Email1, 
                                     CP.Cod_EstadoCliente, 
                                     CP.Ap_Paterno, 
                                     CP.Ap_Materno, 
                                     CP.Nombres, 
                                     CP.Cod_CondicionCliente, 
                                     CP.Cod_TipoCliente, 
                                     CP.RUC_Natural, 
                                     CP.Cod_TipoComprobante, 
                                     CP.Cod_Nacionalidad, 
                                     CP.Fecha_Nacimiento, 
                                     CP.Cod_Sexo, 
                                     CP.Email2, 
                                     CP.Telefono2, 
                                     CP.Fax, 
                                     CP.PaginaWeb, 
                                     CP.Cod_Ubigeo, 
                                     CP.Cod_FormaPago, 
                                     CP.Limite_Credito, 
                                     TD.Nom_TipoDoc AS Nom_TipoDocumento
                        FROM PRI_CLIENTE_PROVEEDOR AS CP
                             INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc;
                END;
        END;
    END;
GO