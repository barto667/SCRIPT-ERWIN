--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Añadir el campo Cod_Producto_Sunat a PRI_PRODUCTOS
--------------------------------------------------------------------------------------------------------------
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
        ALTER TABLE PRI_PRODUCTOS
        ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS
        ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_PRODUCTOS
        ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS
        ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTOS SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_PRODUCTOS
        ADD Cod_ProductoSunat VARCHAR(64);
        ALTER TABLE PRI_PRODUCTOS
        ADD Cod_UsuarioReg VARCHAR(32) NOT NULL
                                       DEFAULT('''');
        ALTER TABLE PRI_PRODUCTOS
        ADD Fecha_Reg DATETIME NOT NULL
                               DEFAULT(GETDATE());
        ALTER TABLE PRI_PRODUCTOS
        ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTOS
        ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTOS SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Cod_ProductoSunat = ''''');
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Acth;
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Añadir el campo Precio_Flete y Peso a PRI_PRODUCTO_STOCK
--------------------------------------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME IN('Precio_Flete', 'Peso')
    AND TABLE_NAME = 'PRI_PRODUCTO_STOCK'
)
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX);
        SELECT @Sentencia = COALESCE(@Sentencia + ';' + CHAR(13) + CHAR(10), '') + CONCAT('ALTER TABLE ', tables.name, ' DROP CONSTRAINT ', default_constraints.name)
        FROM sys.all_columns
             INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
             INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
             INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
        WHERE schemas.name = 'dbo'
              AND tables.name = 'PRI_PRODUCTO_STOCK';
        EXEC (@Sentencia);
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioRegh = Cod_UsuarioReg, Fecha_Regh = Fecha_Reg, Cod_UsuarioActh = Cod_UsuarioAct, Fecha_Acth = Fecha_Act');
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Precio_Flete NUMERIC(38, 6);
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Peso NUMERIC(38, 6);
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Cod_UsuarioReg VARCHAR(32) NOT NULL
                                       DEFAULT('');
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Fecha_Reg DATETIME NOT NULL
                               DEFAULT(GETDATE());
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_PRODUCTO_STOCK
        ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioReg = Cod_UsuarioRegh,Fecha_Reg = Fecha_Regh,Cod_UsuarioAct = Cod_UsuarioActh,Fecha_Act = Fecha_Acth,Precio_Flete = 0,Peso = 0');
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Acth;
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Añadir el campo Cantidad a CAJ_SERIES
--------------------------------------------------------------------------------------------------------------
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
        WHERE schemas.name = 'dbo'
              AND tables.name = 'CAJ_SERIES';
        EXEC (@Sentencia);
        ALTER TABLE CAJ_SERIES
        ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE CAJ_SERIES
        ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE CAJ_SERIES
        ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE CAJ_SERIES
        ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE CAJ_SERIES SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Reg;
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Act;
        ALTER TABLE CAJ_SERIES
        ADD Cantidad NUMERIC(38, 6);
        ALTER TABLE CAJ_SERIES
        ADD Cod_UsuarioReg VARCHAR(32) NOT NULL
                                       DEFAULT('''');
        ALTER TABLE CAJ_SERIES
        ADD Fecha_Reg DATETIME NOT NULL
                               DEFAULT(GETDATE());
        ALTER TABLE CAJ_SERIES
        ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE CAJ_SERIES
        ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE CAJ_SERIES SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Cantidad = 0');
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Regh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE CAJ_SERIES DROP COLUMN Fecha_Acth;
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Añadir el campo Ubicacion_EjeX,Ubicacion_EjeY y Ruta a PRI_CLIENTE_PROVEEDOR
--------------------------------------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME IN('Ubicacion_EjeX', 'Ubicacion_EjeY', 'Ruta')
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
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Cod_UsuarioRegh VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Fecha_Regh DATETIME NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Cod_UsuarioActh VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Fecha_Acth DATETIME NULL;
        EXEC ('UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioReg;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Reg;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioAct;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Act;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Ubicacion_EjeX NUMERIC(38, 8);
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Ubicacion_EjeY NUMERIC(38, 8);
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Ruta VARCHAR(2048);
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Cod_UsuarioReg VARCHAR(32) NOT NULL
                                       DEFAULT('''');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Fecha_Reg DATETIME NOT NULL
                               DEFAULT(GETDATE());
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Cod_UsuarioAct VARCHAR(32) NULL;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR
        ADD Fecha_Act DATETIME NULL;
        EXEC ('UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth,Ubicacion_EjeX=0,Ubicacion_EjeY=0, Ruta = ''''');
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioRegh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Regh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Cod_UsuarioActh;
        ALTER TABLE PRI_CLIENTE_PROVEEDOR DROP COLUMN Fecha_Acth;
END;
GO

--PRESTAMO Y DEVOLUCION DE ENVASES
EXEC dbo.USP_CAJ_CONCEPTO_G @Id_Concepto = 70001, @Des_Concepto = 'GARANTIA PRESTAMO DE ENVASES', @Cod_ClaseConcepto = '007', @Flag_Activo = 1, @Id_ConceptoPadre = 0, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_CAJ_CONCEPTO_G @Id_Concepto = 70002, @Des_Concepto = 'GARANTIA DEVOLUCION DE ENVASES', @Cod_ClaseConcepto = '006', @Flag_Activo = 1, @Id_ConceptoPadre = 0, @Cod_Usuario = 'MIGRACION';
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Creacion de vistas necesarias para guias de remision remitente
--------------------------------------------------------------------------------------------------------------
EXEC dbo.USP_PAR_TABLA_G @Cod_Tabla = '128', @Tabla = 'GUIA_REMISION_REMITENTE_MOTIVOS', @Des_Tabla = 'Almacena los motivos de traslado de guia', @Cod_Sistema = '001', @Flag_Acceso = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Columna = 'Cod_Motivo',@Des_Columna = 'Codigo SUNAT del motivo de la nota', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 32, @Predeterminado = '', @Flag_PK = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Columna = 'Des_Motivo', @Des_Columna = 'Descripcion del motivo de la nota', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 1024, @Predeterminado = '', @Flag_PK = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Columna = 'Estado', @Des_Columna = 'Estado', @Tipo = 'BOLEANO', @Flag_NULL = 0, @Tamano = 64, @Predeterminado = '', @Flag_PK = 0, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS @Cod_Tabla = '128';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 1, @Cadena = N'01', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 1, @Cadena = N'VENTA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 1, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 2, @Cadena = N'02', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 2, @Cadena = N'COMPRA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 2, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 3, @Cadena = N'04', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 3, @Cadena = N'TRASLADO ENTRE ESTABLECIMIENTOS DE LA MISMA EMPRESA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 3, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 4, @Cadena = N'08', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 4, @Cadena = N'IMPORTACION', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 4, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 5, @Cadena = N'09', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 5, @Cadena = N'EXPORTACION', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 5, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 6, @Cadena = N'13', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 6, @Cadena = N'OTROS', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 6, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 7, @Cadena = N'14', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 7, @Cadena = N'VENTA SUJETA A CONFIRMACION DEL COMPRADOR', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 7, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 8, @Cadena = N'18', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 8, @Cadena = N'TRASLADO EMISOR ITINERANTE CP', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 8, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '001', @Cod_Fila = 9, @Cadena = N'19', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '002', @Cod_Fila = 9, @Cadena = N'TRASLADO A ZONA PRIMARIA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '128', @Cod_Columna = '003', @Cod_Fila = 9, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
GO
EXEC dbo.USP_PAR_TABLA_G @Cod_Tabla = '129', @Tabla = 'GUIA_REMISION_REMITENTE_DOCUMENTOS_RELACIONADOS', @Des_Tabla = 'Almacena los distintos tipos de documentos relacionados ', @Cod_Sistema = '001', @Flag_Acceso = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Columna = 'Cod_Relacionado', @Des_Columna = 'Codigo SUNAT del documento relacionado', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 32, @Predeterminado = '', @Flag_PK = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Columna = 'Des_Relacionado', @Des_Columna = 'Descripcion del documento relacionado', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 1024, @Predeterminado = '', @Flag_PK = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Columna = 'Estado', @Des_Columna = 'Estado', @Tipo = 'BOLEANO', @Flag_NULL = 0, @Tamano = 64, @Predeterminado = '', @Flag_PK = 0, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS @Cod_Tabla = '129';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 1, @Cadena = N'01', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 1, @Cadena = N'NUMERO DAM', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 1, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 2, @Cadena = N'02', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 2, @Cadena = N'NUMERO DE ORDEN DE ENTREGA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 2, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 3, @Cadena = N'03', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 3, @Cadena = N'NUMERO SCOP', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 3, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 4, @Cadena = N'04', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 4, @Cadena = N'NUMERO DE MANIFIESTO DE CARGA', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 4, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 5, @Cadena = N'05', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 5, @Cadena = N'NUMERO DE CONSTANCIA DE DETRACCION', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 5, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '001', @Cod_Fila = 6, @Cadena = N'06', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '002', @Cod_Fila = 6, @Cadena = N'OTROS', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '129', @Cod_Columna = '003', @Cod_Fila = 6, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Creacion de tablas necesarias para la emision de guias remision remitente, si no existe informacion de guias borra todas las tablas, caso contrario no realiza la eliminacion ni insercion
--------------------------------------------------------------------------------------------------------------
-- Temporales
IF OBJECT_ID('CAJ_GUIA_REMISION_D', 'U') IS NOT NULL
    BEGIN
        DROP TABLE CAJ_GUIA_REMISION_D;
END;
GO
IF OBJECT_ID('CAJ_GUIA_REMISION', 'U') IS NOT NULL
    BEGIN
        DROP TABLE CAJ_GUIA_REMISION;
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Crear la tabla CAJ_GUIA_REMISION_REMITENTE
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
        )
            BEGIN
                --Eliminamos primero las las referencias
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_D;
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS;
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS;
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS;
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE;
                --Volvemos a crear
                CREATE TABLE CAJ_GUIA_REMISION_REMITENTE
                (Id_GuiaRemisionRemitente     INT IDENTITY(1, 1) PRIMARY KEY, 
                 Cod_Caja                     VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_CAJAS(Cod_Caja), 
                 Cod_Turno                    VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_TURNO_ATENCION(Cod_Turno), 
                 Cod_TipoComprobante          VARCHAR(5) NOT NULL, 
                 Cod_Libro                    VARCHAR(2) NOT NULL, --Indica si la guia es para emitir o para registrar (similar a venta-compra)
                 Cod_Periodo                  VARCHAR(8) NOT NULL, 
                 Serie                        VARCHAR(5) NOT NULL, 
                 Numero                       VARCHAR(30) NOT NULL, 
                 Fecha_Emision                DATETIME NOT NULL, 
                 Fecha_TrasladoBienes         DATETIME NOT NULL, 
                 Fecha_EntregaBienes          DATETIME NOT NULL, 
                 Cod_MotivoTraslado           VARCHAR(5) NOT NULL, 
                 Des_MotivoTraslado           VARCHAR(2048) NOT NULL, 
                 Cod_ModalidadTraslado        VARCHAR(5), 
                 Cod_UnidadMedida             VARCHAR(5) NOT NULL, 
                 Id_ClienteDestinatario       INT FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor), 
                 Cod_UbigeoPartida            VARCHAR(8) NOT NULL, 
                 Direccion_Partida            VARCHAR(2048) NOT NULL, 
                 Cod_UbigeoLlegada            VARCHAR(8) NOT NULL, 
                 Direccion_LLegada            VARCHAR(2048) NOT NULL, 
                 Flag_Transbordo              BIT, 
                 Peso_Bruto                   NUMERIC(38, 6) NOT NULL, 
                 Nro_Contenedor               VARCHAR(64), 
                 Cod_Puerto                   VARCHAR(64), 
                 Nro_Bulltos                  INT, --O pallets, numerico 12 segun sunat
                 Cod_EstadoGuia               VARCHAR(8) NOT NULL, 
                 Obs_GuiaRemisionRemitente    VARCHAR(2048), 
                 Id_GuiaRemisionRemitenteBaja INT NULL, 
                 Flag_Anulado                 BIT, 
                 Valor_Resumen                VARCHAR(1024), 
                 Valor_Firma                  VARCHAR(2048), 
                 Cod_UsuarioReg               VARCHAR(32) NOT NULL, 
                 Fecha_Reg                    DATETIME NOT NULL, 
                 Cod_UsuarioAct               VARCHAR(32), 
                 Fecha_Act                    DATETIME
                );
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE
        (Id_GuiaRemisionRemitente     INT IDENTITY(1, 1) PRIMARY KEY, 
         Cod_Caja                     VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_CAJAS(Cod_Caja), 
         Cod_Turno                    VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_TURNO_ATENCION(Cod_Turno), 
         Cod_TipoComprobante          VARCHAR(5) NOT NULL, 
         Cod_Libro                    VARCHAR(2) NOT NULL, --Indica si la guia es para emitir o para registrar (similar a venta-compra)
         Cod_Periodo                  VARCHAR(8) NOT NULL, 
         Serie                        VARCHAR(5) NOT NULL, 
         Numero                       VARCHAR(30) NOT NULL, 
         Fecha_Emision                DATETIME NOT NULL, 
         Fecha_TrasladoBienes         DATETIME NOT NULL, 
         Fecha_EntregaBienes          DATETIME NOT NULL, 
         Cod_MotivoTraslado           VARCHAR(5) NOT NULL, 
         Des_MotivoTraslado           VARCHAR(2048) NOT NULL, 
         Cod_ModalidadTraslado        VARCHAR(5), 
         Cod_UnidadMedida             VARCHAR(5) NOT NULL, 
         Id_ClienteDestinatario       INT FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor), 
         Cod_UbigeoPartida            VARCHAR(8) NOT NULL, 
         Direccion_Partida            VARCHAR(2048) NOT NULL, 
         Cod_UbigeoLlegada            VARCHAR(8) NOT NULL, 
         Direccion_LLegada            VARCHAR(2048) NOT NULL, 
         Flag_Transbordo              BIT, 
         Peso_Bruto                   NUMERIC(38, 6) NOT NULL, 
         Nro_Contenedor               VARCHAR(64), 
         Cod_Puerto                   VARCHAR(64), 
         Nro_Bulltos                  INT, --O pallets, numerico 12 segun sunat
         Cod_EstadoGuia               VARCHAR(8) NOT NULL, 
         Obs_GuiaRemisionRemitente    VARCHAR(2048), 
         Id_GuiaRemisionRemitenteBaja INT NULL, 
         Flag_Anulado                 BIT, 
         Valor_Resumen                VARCHAR(1024), 
         Valor_Firma                  VARCHAR(2048), 
         Cod_UsuarioReg               VARCHAR(32) NOT NULL, 
         Fecha_Reg                    DATETIME NOT NULL, 
         Cod_UsuarioAct               VARCHAR(32), 
         Fecha_Act                    DATETIME
        );
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Crear la tabla CAJ_GUIA_REMISION_REMITENTE_D
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_D', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrr
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_D;
                --Volvemos a crear
                CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_D
                (Id_GuiaRemisionRemitente INT NOT NULL
                                              FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
                 Id_Detalle               INT NOT NULL, 
                 Cod_Almacen              VARCHAR(32), 
                 Cod_UnidadMedida         VARCHAR(5), 
                 Id_Producto              INT FOREIGN KEY REFERENCES dbo.PRI_PRODUCTOS(Id_Producto), 
                 Cantidad                 NUMERIC(38, 10) NOT NULL, 
                 Descripcion              VARCHAR(2048) NOT NULL, 
                 Peso                     NUMERIC(38, 6) NOT NULL, 
                 Obs_Detalle              VARCHAR(2048), 
                 Cod_ProductoSunat        VARCHAR(32), 
                 Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
                 Fecha_Reg                DATETIME NOT NULL, 
                 Cod_UsuarioAct           VARCHAR(32), 
                 Fecha_Act                DATETIME
                );
                ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_D
                ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_D PRIMARY KEY(Id_GuiaRemisionRemitente, Id_Detalle);
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_D
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Id_Detalle               INT NOT NULL, 
         Cod_Almacen              VARCHAR(32), 
         Cod_UnidadMedida         VARCHAR(5), 
         Id_Producto              INT FOREIGN KEY REFERENCES dbo.PRI_PRODUCTOS(Id_Producto), 
         Cantidad                 NUMERIC(38, 10) NOT NULL, 
         Descripcion              VARCHAR(2048) NOT NULL, 
         Peso                     NUMERIC(38, 6) NOT NULL, 
         Obs_Detalle              VARCHAR(2048), 
         Cod_ProductoSunat        VARCHAR(32), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_D
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_D PRIMARY KEY(Id_GuiaRemisionRemitente, Id_Detalle);
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Crear la tabla CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrr
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS;
                --Volvemos a crear
                CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                (Id_GuiaRemisionRemitente INT NOT NULL
                                              FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
                 Item                     INT NOT NULL, 
                 Cod_TipoDocumento        VARCHAR(5) NOT NULL, 
                 Id_DocRelacionado        INT NOT NULL, 
                 Serie                    VARCHAR(32), 
                 Numero                   VARCHAR(128) NOT NULL, 
                 Cod_TipoRelacion         VARCHAR(8), 
                 Observacion              VARCHAR(2048), 
                 Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
                 Fecha_Reg                DATETIME NOT NULL, 
                 Cod_UsuarioAct           VARCHAR(32), 
                 Fecha_Act                DATETIME
                );
                ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Item                     INT NOT NULL, 
         Cod_TipoDocumento        VARCHAR(5) NOT NULL, 
         Id_DocRelacionado        INT NOT NULL, 
         Serie                    VARCHAR(32), 
         Numero                   VARCHAR(128) NOT NULL, 
         Cod_TipoRelacion         VARCHAR(8), 
         Observacion              VARCHAR(2048), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Crear la tabla CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrr
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS;
                --Volvemos a crear
                CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                (Id_GuiaRemisionRemitente INT NOT NULL
                                              FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
                 Item                     INT NOT NULL, 
                 Cod_TipoDocumento        VARCHAR(5), 
                 Numero_Documento         VARCHAR(64), 
                 Nombres                  VARCHAR(2048), 
                 Direccion                VARCHAR(2048), 
                 Cod_ModalidadTransporte  VARCHAR(5), 
                 Licencia                 VARCHAR(64), 
                 Observaciones            VARCHAR(2048), 
                 Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
                 Fecha_Reg                DATETIME NOT NULL, 
                 Cod_UsuarioAct           VARCHAR(32), 
                 Fecha_Act                DATETIME
                );
                ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Item                     INT NOT NULL, 
         Cod_TipoDocumento        VARCHAR(5), 
         Numero_Documento         VARCHAR(64), 
         Nombres                  VARCHAR(2048), 
         Direccion                VARCHAR(2048), 
         Cod_ModalidadTransporte  VARCHAR(5), 
         Licencia                 VARCHAR(64), 
         Observaciones            VARCHAR(2048), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Crear la tabla CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT cgrr.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrr
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS;
                --Volvemos a crear
                CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                (Id_GuiaRemisionRemitente INT NOT NULL
                                              FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
                 Item                     INT NOT NULL, 
                 Placa                    VARCHAR(64), 
                 Certificado_Inscripcion  VARCHAR(1024), 
                 Certificado_Habilitacion VARCHAR(1024), 
                 Observaciones            VARCHAR(2048), 
                 Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
                 Fecha_Reg                DATETIME NOT NULL, 
                 Cod_UsuarioAct           VARCHAR(32), 
                 Fecha_Act                DATETIME
                );
                ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Item                     INT NOT NULL, 
         Placa                    VARCHAR(64), 
         Certificado_Inscripcion  VARCHAR(1024), 
         Certificado_Habilitacion VARCHAR(1024), 
         Observaciones            VARCHAR(2048), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO
IF OBJECT_ID('ALM_INVENTARIO', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT ai.*
            FROM dbo.ALM_INVENTARIO ai
        )
            BEGIN
                --Eliminamos las referencias
                DROP TABLE dbo.ALM_INVENTARIO_D;
                --Eliminamos la tabla
                DROP TABLE dbo.ALM_INVENTARIO;
                --Volvemos a crear
                CREATE TABLE ALM_INVENTARIO
                (Id_Inventario        INT IDENTITY(1, 1), --
                 Des_Inventario       VARCHAR(512) NULL, --
                 Cod_TipoInventario   VARCHAR(5) NULL, --
                 Cod_Almacen          VARCHAR(32) NULL, --
                 Cod_EstadoInventario VARCHAR(32) NULL, 
                 Fecha_Inventario     DATETIME NULL, 
                 Fecha_Fin            DATETIME NULL, 
                 Obs_Inventario       VARCHAR(1024) NULL, --
                 Cod_UsuarioReg       VARCHAR(32) NOT NULL, --
                 Fecha_Reg            DATETIME NOT NULL, --
                 Cod_UsuarioAct       VARCHAR(32) NULL, --
                 Fecha_Act            DATETIME NULL, --
                 PRIMARY KEY NONCLUSTERED(Id_Inventario), 
                 FOREIGN KEY(Cod_Almacen) REFERENCES ALM_ALMACEN
                );
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE ALM_INVENTARIO
        (Id_Inventario        INT IDENTITY(1, 1), --
         Des_Inventario       VARCHAR(512) NULL, --
         Cod_TipoInventario   VARCHAR(5) NULL, --
         Cod_Almacen          VARCHAR(32) NULL, --
         Cod_EstadoInventario VARCHAR(32) NULL, 
         Fecha_Inventario     DATETIME NULL, 
         Fecha_Fin            DATETIME NULL, 
         Obs_Inventario       VARCHAR(1024) NULL, --
         Cod_UsuarioReg       VARCHAR(32) NOT NULL, --
         Fecha_Reg            DATETIME NOT NULL, --
         Cod_UsuarioAct       VARCHAR(32) NULL, --
         Fecha_Act            DATETIME NULL, --
         PRIMARY KEY NONCLUSTERED(Id_Inventario), 
         FOREIGN KEY(Cod_Almacen) REFERENCES ALM_ALMACEN
        );
END;
GO
IF OBJECT_ID('ALM_INVENTARIO_D', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT aid.*
            FROM dbo.ALM_INVENTARIO_D aid
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.ALM_INVENTARIO_D;
                --Volvemos a crear
                CREATE TABLE ALM_INVENTARIO_D
                (Id_Inventario       INT NOT NULL, 
                 Item                VARCHAR(32) NOT NULL, 
                 Id_Producto         INT NULL, 
                 Cod_UnidadMedida    VARCHAR(5) NULL, 
                 Cod_Almacen         VARCHAR(32) NULL, 
                 Cantidad_Sistema    NUMERIC(38, 6) NULL, 
                 Precio_Unitario     NUMERIC(38, 6) NULL, 
                 Cantidad_Encontrada NUMERIC(38, 6) NULL, 
                 Obs_InventarioD     VARCHAR(1024) NULL, 
                 Cod_UsuarioReg      VARCHAR(32) NOT NULL, 
                 Fecha_Reg           DATETIME NOT NULL, 
                 Cod_UsuarioAct      VARCHAR(32) NULL, 
                 Fecha_Act           DATETIME NULL, 
                 PRIMARY KEY NONCLUSTERED(Id_Inventario, Item), 
                 FOREIGN KEY(Id_Producto, Cod_UnidadMedida, Cod_Almacen) REFERENCES PRI_PRODUCTO_STOCK, 
                 FOREIGN KEY(Id_Inventario) REFERENCES ALM_INVENTARIO
                );
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE ALM_INVENTARIO_D
        (Id_Inventario       INT NOT NULL, 
         Item                VARCHAR(32) NOT NULL, 
         Id_Producto         INT NULL, 
         Cod_UnidadMedida    VARCHAR(5) NULL, 
         Cod_Almacen         VARCHAR(32) NULL, 
         Cantidad_Sistema    NUMERIC(38, 6) NULL, 
         Precio_Unitario     NUMERIC(38, 6) NULL, 
         Cantidad_Encontrada NUMERIC(38, 6) NULL, 
         Obs_InventarioD     VARCHAR(1024) NULL, 
         Cod_UsuarioReg      VARCHAR(32) NOT NULL, 
         Fecha_Reg           DATETIME NOT NULL, 
         Cod_UsuarioAct      VARCHAR(32) NULL, 
         Fecha_Act           DATETIME NULL, 
         PRIMARY KEY NONCLUSTERED(Id_Inventario, Item), 
         FOREIGN KEY(Id_Producto, Cod_UnidadMedida, Cod_Almacen) REFERENCES PRI_PRODUCTO_STOCK, 
         FOREIGN KEY(Id_Inventario) REFERENCES ALM_INVENTARIO
        );
END;
GO
--Creamos la vista estado de letra
IF
(
    SELECT pt.Tabla
    FROM dbo.PAR_TABLA pt
    WHERE pt.Cod_Tabla = '127'
) = 'LETRAS_CAMBIO'
    BEGIN
        --Borramos la vista
        DELETE dbo.PAR_FILA
        WHERE dbo.PAR_FILA.Cod_Tabla = '127';
        DELETE dbo.PAR_COLUMNA
        WHERE dbo.PAR_COLUMNA.Cod_Tabla = '127';
        EXEC dbo.USP_PAR_TABLA_E 
             @Cod_Tabla = '127';
        --Cambiamos el codigo de la vista ESTADO_LETRA
        DELETE dbo.PAR_FILA
        WHERE dbo.PAR_FILA.Cod_Tabla = '128';
        DELETE dbo.PAR_COLUMNA
        WHERE dbo.PAR_COLUMNA.Cod_Tabla = '128';
        EXEC dbo.USP_PAR_TABLA_E @Cod_Tabla = '128';
        EXEC dbo.USP_PAR_TABLA_G @Cod_Tabla = '127', @Tabla = 'ESTADOS_LETRA', @Des_Tabla = 'Almacena los estados de las letras', @Cod_Sistema = '001', @Flag_Acceso = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127', @Cod_Columna = '001', @Columna = 'Cod_Estado', @Des_Columna = 'Codigo del estado de la letra', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 32, @Predeterminado = '', @Flag_PK = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127', @Cod_Columna = '002', @Columna = 'Des_Estado', @Des_Columna = 'Descripcion del estado de la letra', @Tipo = 'CADENA', @Flag_NULL = 0, @Tamano = 1024, @Predeterminado = '', @Flag_PK = 0, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G @Cod_Tabla = '127', @Cod_Columna = '003', @Columna = 'Estado', @Des_Columna = 'Estado', @Tipo = 'BOLEANO', @Flag_NULL = 0, @Tamano = 64, @Predeterminado = '', @Flag_PK = 0, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS @Cod_Tabla = '127';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '001', @Cod_Fila = 1, @Cadena = N'001', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '002', @Cod_Fila = 1, @Cadena = N'EMITIDO', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '003', @Cod_Fila = 1, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '001', @Cod_Fila = 2, @Cadena = N'002', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '002', @Cod_Fila = 2, @Cadena = N'PAGADO', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '003', @Cod_Fila = 2, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '001', @Cod_Fila = 3, @Cadena = N'003', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '002', @Cod_Fila = 3, @Cadena = N'PROTESTO', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '003', @Cod_Fila = 3, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '001', @Cod_Fila = 4, @Cadena = N'004', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '002', @Cod_Fila = 4, @Cadena = N'ANULADO', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 0, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '127', @Cod_Columna = '003', @Cod_Fila = 4, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
END;
GO
IF OBJECT_ID('CAJ_LETRA_CAMBIO', 'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT clc.*
            FROM dbo.CAJ_LETRA_CAMBIO clc
        )
            BEGIN
                --Eliminamos la tabla
                DROP TABLE dbo.CAJ_LETRA_CAMBIO;
                --Volvemos a crear
                CREATE TABLE CAJ_LETRA_CAMBIO
                (Id                INT IDENTITY(1, 1) NOT NULL, 
                 Id_Letra          INT NOT NULL, 
                 Nro_Letra         VARCHAR(32) NOT NULL, 
                 Cod_Libro         VARCHAR(2) NOT NULL, 
                 Ref_Girador       VARCHAR(1024) NOT NULL, 
                 Fecha_Girado      DATETIME NOT NULL, 
                 Fecha_Vencimiento DATETIME NOT NULL, 
                 Fecha_Pago        DATETIME NOT NULL, 
                 Cod_Cuenta        VARCHAR(64) NOT NULL, 
                 Nro_Operacion     VARCHAR(32) NOT NULL, 
                 Cod_Moneda        VARCHAR(5), 
                 Id_Comprobante    INT NOT NULL, 
                 Cod_Estado        VARCHAR(32) NOT NULL, 
                 Nro_Referencia    VARCHAR(32) NOT NULL, 
                 Monto_Base        NUMERIC(32, 3) NOT NULL, 
                 Monto_Real        NUMERIC(32, 3) NOT NULL, 
                 Observaciones     VARCHAR(MAX) NOT NULL, 
                 Cod_UsuarioReg    VARCHAR(32) NOT NULL, 
                 Fecha_Reg         DATETIME NOT NULL, 
                 Cod_UsuarioAct    VARCHAR(32), 
                 Fecha_Act         DATETIME, 
                 PRIMARY KEY(Id, Id_Letra, Nro_Letra, Cod_Libro, Cod_Cuenta, Cod_Moneda)
                );
        END;
END;
    ELSE
    BEGIN
        CREATE TABLE CAJ_LETRA_CAMBIO
        (Id                INT IDENTITY(1, 1) NOT NULL, 
         Id_Letra          INT NOT NULL, 
         Nro_Letra         VARCHAR(32) NOT NULL, 
         Cod_Libro         VARCHAR(2) NOT NULL, 
         Ref_Girador       VARCHAR(1024) NOT NULL, 
         Fecha_Girado      DATETIME NOT NULL, 
         Fecha_Vencimiento DATETIME NOT NULL, 
         Fecha_Pago        DATETIME NOT NULL, 
         Cod_Cuenta        VARCHAR(64) NOT NULL, 
         Nro_Operacion     VARCHAR(32) NOT NULL, 
         Cod_Moneda        VARCHAR(5), 
         Id_Comprobante    INT NOT NULL, 
         Cod_Estado        VARCHAR(32) NOT NULL, 
         Nro_Referencia    VARCHAR(32) NOT NULL, 
         Monto_Base        NUMERIC(32, 3) NOT NULL, 
         Monto_Real        NUMERIC(32, 3) NOT NULL, 
         Observaciones     VARCHAR(MAX) NOT NULL, 
         Cod_UsuarioReg    VARCHAR(32) NOT NULL, 
         Fecha_Reg         DATETIME NOT NULL, 
         Cod_UsuarioAct    VARCHAR(32), 
         Fecha_Act         DATETIME, 
         PRIMARY KEY(Id, Id_Letra, Nro_Letra, Cod_Libro, Cod_Cuenta, Cod_Moneda)
        );
END;
GO

IF OBJECT_ID('PRI_PRODUCTO_TASA', 'U') IS NOT NULL
    BEGIN
        --Si no hay datos creamos la tabla nuevamnete
        IF NOT EXISTS
        (
            SELECT ppt.*
            FROM dbo.PRI_PRODUCTO_TASA ppt
        )
            BEGIN
                DROP TABLE dbo.PRI_PRODUCTO_TASA;
                --Creamos la tabla
                CREATE TABLE PRI_PRODUCTO_TASA
                (Id_Producto    INT NOT NULL, 
                 Cod_Tasa       VARCHAR(32) NOT NULL, 
                 Cod_Libro      VARCHAR(2), 
                 Des_Tasa       VARCHAR(512), 
                 Por_Tasa       NUMERIC(10, 4), 
                 Cod_TipoTasa   VARCHAR(64), 
                 Cod_Aplicacion VARCHAR(64), 
                 Flag_Activo    BIT, 
                 Obs_Tasa       VARCHAR(1024), 
                 Cod_UsuarioReg VARCHAR(32) NOT NULL, 
                 Fecha_Reg      DATETIME NOT NULL, 
                 Cod_UsuarioAct VARCHAR(32), 
                 Fecha_Act      DATETIME, 
                 PRIMARY KEY(Id_Producto, Cod_Tasa), 
                 FOREIGN KEY(Id_Producto) REFERENCES PRI_PRODUCTOS(Id_Producto)
                );
        END;
END;
    ELSE
    BEGIN
        --Creamos la tabla
        CREATE TABLE PRI_PRODUCTO_TASA
        (Id_Producto    INT NOT NULL, 
         Cod_Tasa       VARCHAR(32) NOT NULL, 
         Cod_Libro      VARCHAR(2), 
         Des_Tasa       VARCHAR(512), 
         Por_Tasa       NUMERIC(10, 4), 
         Cod_TipoTasa   VARCHAR(8), 
         Cod_Aplicacion VARCHAR(8), 
         Flag_Activo    BIT, 
         Obs_Tasa       VARCHAR(1024), 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME, 
         PRIMARY KEY(Id_Producto, Cod_Tasa), 
         FOREIGN KEY(Id_Producto) REFERENCES PRI_PRODUCTOS(Id_Producto)
        );
END;
GO
IF NOT EXISTS
(
    SELECT vdx.*
    FROM dbo.VIS_DIAGRAMAS_XML vdx
    WHERE vdx.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
          AND vdx.Cod_Elemento = 'PUNTOS_BONUS'
          AND vdx.Estado = 1
)
    BEGIN
        DECLARE @Fila INT= ISNULL(
        (
            SELECT COUNT(*)
            FROM dbo.VIS_DIAGRAMAS_XML vdx
        ), 0) + 1;
        EXEC USP_PAR_FILA_G '093', '001', @Fila, 'CAJ_COMPROBANTE_PAGO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '002', @Fila, 'PUNTOS_BONUS', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '003', @Fila, 'Total Puntos:', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '004', @Fila, 'CADENA', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '005', @Fila, NULL, 32, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '006', @Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
END;
GO
--Fecha Creacion: 25/07/2019
--Autor ERWIN MIULLER RAYME CHAMBI
--Creacion de la vista
EXEC dbo.USP_PAR_TABLA_G '139', 'CONFIGURACION_BONUS', 'Almacena la configuracion de bonos', '001', 1, 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '139', '001', 'Cod_Comercio', 'Almacena el codigo comercio', 'CADENA', 0, 32, '', 1, 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G '139', '002', 'Estado', 'Estado', 'BOLEANO', 0, 64, '', 0, 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS '139';
GO
IF NOT EXISTS
(
    SELECT vdx.*
    FROM dbo.VIS_DIAGRAMAS_XML vdx
    WHERE vdx.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
          AND vdx.Cod_Elemento = 'TARJETA_BONUS'
          AND vdx.Estado = 1
)
    BEGIN
        DECLARE @Fila INT= ISNULL(
        (
            SELECT COUNT(*)
            FROM dbo.VIS_DIAGRAMAS_XML vdx
        ), 0) + 1;
        EXEC USP_PAR_FILA_G '093', '001', @Fila, 'CAJ_COMPROBANTE_PAGO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '002', @Fila, 'TARJETA_BONUS', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '003', @Fila, 'Nro. Bonus:', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '004', @Fila, 'CADENA', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '005', @Fila, NULL, 32, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '093', '006', @Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
END;
GO
--Agregamos el nuevo impuesto de bolsas de plastico
IF NOT EXISTS
(
    SELECT vt.*
    FROM dbo.VIS_TASAS vt
    WHERE vt.Cod_Tasa = 'ICBPER'
)
    BEGIN
        DECLARE @Fila INT= (ISNULL(
        (
            SELECT MAX(vt.Nro)
            FROM dbo.VIS_TASAS vt
        ), 0) + 1);
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '001', @Cod_Fila = @Fila, @Cadena = N'ICBPER', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '002', @Cod_Fila = @Fila, @Cadena = N'IMPUESTO AL CONSUMO DE BOLSAS DE PLASTICO', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '003', @Cod_Fila = @Fila, @Cadena = N'OTROS IMPUESTOS', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '004', @Cod_Fila = @Fila, @Cadena = NULL, @Numero = 0.1, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '005', @Cod_Fila = @Fila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = '2019-01-08', @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '006', @Cod_Fila = @Fila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = '2050-01-01', @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '013', @Cod_Columna = '007', @Cod_Fila = @Fila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = 'MIGRACION';
END;