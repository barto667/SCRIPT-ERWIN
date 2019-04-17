--CREACION DE TABLAS
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
--CAJ_GUIA_REMISION_REMITENTE
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE', 'U') IS NULL
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
         Des_MotivoTraslado           VARCHAR(MAX) NOT NULL, 
         Cod_ModalidadTraslado        VARCHAR(5), 
         Cod_UnidadMedida             VARCHAR(5) NOT NULL, 
         Id_ClienteDestinatario       INT FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor), 
         Cod_UbigeoPartida            VARCHAR(8) NOT NULL, 
         Direccion_Partida            VARCHAR(MAX) NOT NULL, 
         Cod_UbigeoLlegada            VARCHAR(8) NOT NULL, 
         Direccion_LLegada            VARCHAR(MAX) NOT NULL, 
         Flag_Transbordo              BIT, 
         Peso_Bruto                   NUMERIC(38, 6) NOT NULL, 
         Nro_Contenedor               VARCHAR(64), 
         Cod_Puerto                   VARCHAR(64), 
         Nro_Bulltos                  INT, --O pallets, numerico 12 segun sunat
         Cod_EstadoGuia               VARCHAR(8) NOT NULL, 
         Obs_GuiaRemisionRemitente    VARCHAR(MAX), 
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
--CAJ_GUIA_REMISION_REMITENTE_D
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_D', 'U') IS NULL
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_D
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Id_Detalle               INT NOT NULL, 
         Cod_Almacen              VARCHAR(32), 
         Cod_UnidadMedida         VARCHAR(5), 
         Id_Producto              INT FOREIGN KEY REFERENCES dbo.PRI_PRODUCTOS(Id_Producto), 
         Cantidad                 NUMERIC(38, 10) NOT NULL, 
         Descripcion              VARCHAR(MAX) NOT NULL, 
         Peso                     NUMERIC(38, 6) NOT NULL, 
         Obs_Detalle              VARCHAR(MAX), 
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

--CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'U') IS NULL
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
         Observacion              VARCHAR(MAX), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO

--CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'U') IS NULL
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Item                     INT NOT NULL, 
         Cod_TipoDocumento        VARCHAR(5), 
         Numero_Documento         VARCHAR(64), 
         Nombres                  VARCHAR(MAX), 
         Direccion                VARCHAR(MAX), 
         Cod_ModalidadTransporte  VARCHAR(5), 
         Licencia                 VARCHAR(64), 
         Observaciones            VARCHAR(MAX), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO
--CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'U') IS NULL
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
        (Id_GuiaRemisionRemitente INT NOT NULL
                                      FOREIGN KEY(Id_GuiaRemisionRemitente) REFERENCES dbo.CAJ_GUIA_REMISION_REMITENTE(Id_GuiaRemisionRemitente), 
         Item                     INT NOT NULL, 
         Placa                    VARCHAR(64), 
         Certificado_Inscripcion  VARCHAR(1024), 
         Certificado_Habilitacion VARCHAR(1024), 
         Observaciones            VARCHAR(MAX), 
         Cod_UsuarioReg           VARCHAR(32) NOT NULL, 
         Fecha_Reg                DATETIME NOT NULL, 
         Cod_UsuarioAct           VARCHAR(32), 
         Fecha_Act                DATETIME
        );
        ALTER TABLE CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
        ADD CONSTRAINT PK_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS PRIMARY KEY(Id_GuiaRemisionRemitente, Item);
END;
GO

--Creamos la vista de motivos guias de remsion
EXEC dbo.USP_PAR_TABLA_G 
     @Cod_Tabla = '128', 
     @Tabla = 'GUIA_REMISION_REMITENTE_MOTIVOS', 
     @Des_Tabla = 'Almacena los motivos de traslado de guia', 
     @Cod_Sistema = '001', 
     @Flag_Acceso = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Columna = 'Cod_Motivo', 
     @Des_Columna = 'Codigo SUNAT del motivo de la nota', 
     @Tipo = 'CADENA', 
     @Flag_NULL = 0, 
     @Tamano = 32, 
     @Predeterminado = '', 
     @Flag_PK = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Columna = 'Des_Motivo', 
     @Des_Columna = 'Descripcion del motivo de la nota', 
     @Tipo = 'CADENA', 
     @Flag_NULL = 0, 
     @Tamano = 1024, 
     @Predeterminado = '', 
     @Flag_PK = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Columna = 'Estado', 
     @Des_Columna = 'Estado', 
     @Tipo = 'BOLEANO', 
     @Flag_NULL = 0, 
     @Tamano = 64, 
     @Predeterminado = '', 
     @Flag_PK = 0, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS 
     @Cod_Tabla = '128';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 1, 
     @Cadena = N'01', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 1, 
     @Cadena = N'VENTA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 1, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 2, 
     @Cadena = N'02', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 2, 
     @Cadena = N'COMPRA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 2, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 3, 
     @Cadena = N'04', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 3, 
     @Cadena = N'TRASLADO ENTRE ESTABLECIMIENTOS DE LA MISMA EMPRESA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 3, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 4, 
     @Cadena = N'08', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 4, 
     @Cadena = N'IMPORTACION', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 4, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 5, 
     @Cadena = N'09', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 5, 
     @Cadena = N'EXPORTACION', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 5, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 6, 
     @Cadena = N'13', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 6, 
     @Cadena = N'OTROS', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 6, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 7, 
     @Cadena = N'14', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 7, 
     @Cadena = N'VENTA SUJETA A CONFIRMACION DEL COMPRADOR', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 7, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 8, 
     @Cadena = N'18', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 8, 
     @Cadena = N'TRASLADO EMISOR ITINERANTE CP', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 8, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '001', 
     @Cod_Fila = 9, 
     @Cadena = N'19', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '002', 
     @Cod_Fila = 9, 
     @Cadena = N'TRASLADO A ZONA PRIMARIA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '128', 
     @Cod_Columna = '003', 
     @Cod_Fila = 9, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
GO
EXEC dbo.USP_PAR_TABLA_G 
     @Cod_Tabla = '129', 
     @Tabla = 'GUIA_REMISION_REMITENTE_DOCUMENTOS_RELACIONADOS', 
     @Des_Tabla = 'Almacena los distintos tipos de documentos relacionados ', 
     @Cod_Sistema = '001', 
     @Flag_Acceso = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Columna = 'Cod_Relacionado', 
     @Des_Columna = 'Codigo SUNAT del documento relacionado', 
     @Tipo = 'CADENA', 
     @Flag_NULL = 0, 
     @Tamano = 32, 
     @Predeterminado = '', 
     @Flag_PK = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Columna = 'Des_Relacionado', 
     @Des_Columna = 'Descripcion del documento relacionado', 
     @Tipo = 'CADENA', 
     @Flag_NULL = 0, 
     @Tamano = 1024, 
     @Predeterminado = '', 
     @Flag_PK = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_COLUMNA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Columna = 'Estado', 
     @Des_Columna = 'Estado', 
     @Tipo = 'BOLEANO', 
     @Flag_NULL = 0, 
     @Tamano = 64, 
     @Predeterminado = '', 
     @Flag_PK = 0, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_TABLA_GENERADOR_VISTAS 
     @Cod_Tabla = '129';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 1, 
     @Cadena = N'01', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 1, 
     @Cadena = N'NUMERO DAM', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 1, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 2, 
     @Cadena = N'02', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 2, 
     @Cadena = N'NUMERO DE ORDEN DE ENTREGA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 2, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 3, 
     @Cadena = N'03', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 3, 
     @Cadena = N'NUMERO SCOP', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 3, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 4, 
     @Cadena = N'04', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 4, 
     @Cadena = N'NUMERO DE MANIFIESTO DE CARGA', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 4, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 5, 
     @Cadena = N'05', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 5, 
     @Cadena = N'NUMERO DE CONSTANCIA DE DETRACCION', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 5, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '001', 
     @Cod_Fila = 6, 
     @Cadena = N'06', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '002', 
     @Cod_Fila = 6, 
     @Cadena = N'OTROS', 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 0, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
EXEC dbo.USP_PAR_FILA_G 
     @Cod_Tabla = '129', 
     @Cod_Columna = '003', 
     @Cod_Fila = 6, 
     @Cadena = NULL, 
     @Numero = NULL, 
     @Entero = NULL, 
     @FechaHora = NULL, 
     @Boleano = 1, 
     @Flag_Creacion = 1, 
     @Cod_Usuario = 'MIGRACION';
GO

--Metodos CRUD
--CAJ_GUIA_REMISION_REMITENTE
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G @Id_GuiaRemisionRemitente     INT OUTPUT, 
                                                   @Cod_Caja                     VARCHAR(32), 
                                                   @Cod_Turno                    VARCHAR(32), 
                                                   @Cod_TipoComprobante          VARCHAR(5), 
                                                   @Cod_Libro                    VARCHAR(2), 
                                                   @Cod_Periodo                  VARCHAR(8), 
                                                   @Serie                        VARCHAR(5), 
                                                   @Numero                       VARCHAR(30), 
                                                   @Fecha_Emision                DATETIME, 
                                                   @Fecha_TrasladoBienes         DATETIME, 
                                                   @Fecha_EntregaBienes          DATETIME, 
                                                   @Cod_MotivoTraslado           VARCHAR(5), 
                                                   @Des_MotivoTraslado           VARCHAR(MAX), 
                                                   @Cod_ModalidadTraslado        VARCHAR(5), 
                                                   @Cod_UnidadMedida             VARCHAR(5), 
                                                   @Id_ClienteDestinatario       INT, 
                                                   @Cod_UbigeoPartida            VARCHAR(8), 
                                                   @Direccion_Partida            VARCHAR(MAX), 
                                                   @Cod_UbigeoLlegada            VARCHAR(8), 
                                                   @Direccion_LLegada            VARCHAR(MAX), 
                                                   @Flag_Transbordo              BIT, 
                                                   @Peso_Bruto                   NUMERIC(38, 6), 
                                                   @Nro_Contenedor               VARCHAR(64), 
                                                   @Cod_Puerto                   VARCHAR(64), 
                                                   @Nro_Bulltos                  INT, 
                                                   @Cod_EstadoGuia               VARCHAR(8), 
                                                   @Obs_GuiaRemisionRemitente    VARCHAR(MAX), 
                                                   @Id_GuiaRemisionRemitenteBaja INT, 
                                                   @Flag_Anulado                 BIT, 
                                                   @Valor_Resumen                VARCHAR(1024), 
                                                   @Valor_Firma                  VARCHAR(2048), 
                                                   @Cod_Usuario                  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF @Cod_TipoComprobante != 'FE'
            BEGIN
                IF(@Numero = ''
                   AND @Cod_Libro = '14')
                    BEGIN
                        SET @Numero =
                        (
                            SELECT RIGHT('00000000' + CONVERT(VARCHAR(38), ISNULL(CONVERT(BIGINT, MAX(cgrr.Numero)), 0) + 1), 8)
                            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                            WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                                  AND cgrr.Serie = @Serie
                                  AND cgrr.Cod_Libro = @Cod_Libro
                        );
                END;
        END;
        IF @Cod_Libro = '14'
            BEGIN
                SET @Id_GuiaRemisionRemitente = (ISNULL(
                (
                    SELECT TOP 1 cgrr.Id_GuiaRemisionRemitente
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                    WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                          AND cgrr.Serie = @Serie
                          AND cgrr.Numero = @Numero
                          AND cgrr.Cod_Libro = @Cod_Libro
                ), 0));
        END;
        IF @Id_GuiaRemisionRemitente = 0
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE
                VALUES
                (
                -- Id_GuiaRemisionRemitente - INT
                @Cod_Caja, -- Cod_Caja - VARCHAR
                @Cod_Turno, -- Cod_Turno - VARCHAR
                @Cod_TipoComprobante, -- Cod_TipoComprobante - VARCHAR
                @Cod_Libro, -- Cod_Libro - VARCHAR
                @Cod_Periodo, 
                @Serie, -- Serie - VARCHAR
                @Numero, -- Numero - VARCHAR
                @Fecha_Emision, -- Fecha_Emision - DATETIME
                @Fecha_TrasladoBienes, -- Fecha_TrasladoBienes - DATETIME
                @Fecha_EntregaBienes, -- Fecha_EntregaBienes - DATETIME
                @Cod_MotivoTraslado, -- Cod_MotivoTraslado - VARCHAR
                @Des_MotivoTraslado, -- Des_MotivoTraslado - VARCHAR
                @Cod_ModalidadTraslado, -- Cod_ModalidadTraslado - VARCHAR
                @Cod_UnidadMedida, -- Cod_UnidadMedida - VARCHAR
                @Id_ClienteDestinatario, -- Id_ClienteDestinatario - INT
                @Cod_UbigeoPartida, -- Cod_UbigeoPartida - VARCHAR
                @Direccion_Partida, -- Direccion_Partida - VARCHAR
                @Cod_UbigeoLlegada, -- Cod_UbigeoLlegada - VARCHAR
                @Direccion_LLegada, -- Direccion_LLegada - VARCHAR
                @Flag_Transbordo, -- Flag_Transbordo - BIT
                @Peso_Bruto, -- Peso_Bruto - NUMERIC
                @Nro_Contenedor, -- Nro_Contenedor - VARCHAR
                @Cod_Puerto, -- Cod_Puerto - VARCHAR
                @Nro_Bulltos, -- Nro_Bulltos - INT
                @Cod_EstadoGuia, -- Cod_EstadoGuia - VARCHAR
                @Obs_GuiaRemisionRemitente, -- Obs_GuiaRemisionRemitente - VARCHAR
                @Id_GuiaRemisionRemitenteBaja, -- Id_GuiaRemisionRemitenteBaja - INT
                @Flag_Anulado, -- Flag_Anulado - BIT
                @Valor_Resumen, -- Valor_Resumen - VARCHAR
                @Valor_Firma, -- Valor_Firma - VARCHAR
                @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                GETDATE(), -- Fecha_Reg - DATETIME
                NULL, -- Cod_UsuarioAct - VARCHAR
                NULL -- Fecha_Act - DATETIME
                );
                SET @Id_GuiaRemisionRemitente = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE
                  SET
                --Id_GuiaRemisionRemitente - column value is auto-generated
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Caja = @Cod_Caja, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Turno = @Cod_Turno, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_TipoComprobante = @Cod_TipoComprobante, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Libro = @Cod_Libro, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Periodo = @Cod_Periodo, --VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Serie = @Serie, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Numero = @Numero, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Emision = @Fecha_Emision, -- DATETIME
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_TrasladoBienes = @Fecha_TrasladoBienes, -- DATETIME
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_EntregaBienes = @Fecha_EntregaBienes, -- DATETIME
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_MotivoTraslado = @Cod_MotivoTraslado, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Des_MotivoTraslado = @Des_MotivoTraslado, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_ModalidadTraslado = @Cod_ModalidadTraslado, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UnidadMedida = @Cod_UnidadMedida, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Id_ClienteDestinatario = @Id_ClienteDestinatario, -- INT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoPartida = @Cod_UbigeoPartida, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_Partida = @Direccion_Partida, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UbigeoLlegada = @Cod_UbigeoLlegada, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Direccion_LLegada = @Direccion_LLegada, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Transbordo = @Flag_Transbordo, -- BIT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Peso_Bruto = @Peso_Bruto, -- NUMERIC
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Contenedor = @Nro_Contenedor, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Puerto = @Cod_Puerto, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Bulltos = @Nro_Bulltos, -- INT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_EstadoGuia = @Cod_EstadoGuia, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Obs_GuiaRemisionRemitente = @Obs_GuiaRemisionRemitente, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitenteBaja = @Id_GuiaRemisionRemitenteBaja, -- INT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Anulado = @Flag_Anulado, -- BIT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Valor_Resumen = @Valor_Resumen, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Valor_Firma = @Valor_Firma, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_E;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_E @Id_GuiaRemisionRemitente INT, 
                                                   @Cod_Usuario              VARCHAR(32), 
                                                   @Justificacion            VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @Cod_TipoComprobante VARCHAR(5);
            DECLARE @Serie VARCHAR(5);
            DECLARE @Numero VARCHAR(30);
            DECLARE @Cod_Libro VARCHAR(2);
            DECLARE @Id_ClienteDestinatario INT;
            DECLARE @Fecha_Emision DATETIME;
            SELECT @Cod_TipoComprobante = cgrr.Cod_TipoComprobante, 
                   @Serie = cgrr.Serie, 
                   @Numero = cgrr.Numero, 
                   @Cod_Libro = cgrr.Cod_Libro, 
                   @Id_ClienteDestinatario = cgrr.Id_ClienteDestinatario, 
                   @Fecha_Emision = cgrr.Fecha_Emision
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
            WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            IF @Cod_TipoComprobante = 'GRRE'
               AND @Cod_Libro = '14'
               AND EXISTS
            (
                SELECT cgrr.*
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE CAST(cgrr.Numero AS INT) > CAST(@Numero AS INT)
                      AND cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
                      AND cgrr.Serie = @Serie
                      AND cgrr.Cod_Libro = @Cod_Libro
            ) --Electronico y de venta
                BEGIN
                    RAISERROR('No se puede Eliminar Dicho comprombprobante porque ya fue notificado a SUNAT', 16, 1);
            END;
            --Eliminamos normal
            --Almacenamos los vehiculos
            DECLARE @Vehiculos VARCHAR(MAX)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrv.Placa, '|', cgrrv.Certificado_Inscripcion, '|', cgrrv.Certificado_Habilitacion)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
                WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los conductores
            DECLARE @Conductores VARCHAR(MAX)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrt.Cod_TipoDocumento, '|', cgrrt.Numero_Documento, '|', cgrrt.Numero_Documento, '|', cgrrt.Licencia, '|', cgrrt.Cod_ModalidadTransporte)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
                WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los detalles
            DECLARE @Detalles VARCHAR(MAX)= STUFF(
            (
                SELECT ';' + CONCAT(CONVERT(VARCHAR(32), cgrrd.Id_Producto), '|', CONVERT(VARCHAR(54), cgrrd.Cantidad), '|', cgrrd.Descripcion)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
                WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los relacionados
            DECLARE @Relacionados VARCHAR(MAX)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrr.Cod_TipoDocumento, '|', cgrrr.Serie, '|', cgrrr.Numero)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
                WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos la cabezera
            DECLARE @Cod_Eliminado VARCHAR(MAX)= @Cod_Libro + '-' + @Cod_TipoComprobante + ':' + @Serie + '-' + @Numero;
            DECLARE @Cliente VARCHAR(MAX)=
            (
                SELECT CONCAT(pcp.Cod_TipoComprobante, ':', pcp.Nro_Documento, '-', pcp.Cliente)
                FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
                WHERE pcp.Id_ClienteProveedor = @Id_ClienteDestinatario
            );
            --Concatenamos la Guia
            DECLARE @Detalle_Guia VARCHAR(MAX)= @Detalles + ' # ' + @Conductores + ' # ' + @Vehiculos + ' # ' + @Relacionados;

            --Eliminamos
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE
            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
            DELETE dbo.CAJ_COMPROBANTE_RELACION
            WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = @Id_GuiaRemisionRemitente
                  AND dbo.CAJ_COMPROBANTE_RELACION.Cod_TipoRelacion = 'GRR';
            --Almacenamos los eliminados
            DECLARE @id_Fila INT=
            (
                SELECT ISNULL(COUNT(*) / 9, 1) + 1
                FROM PAR_FILA
                WHERE Cod_Tabla = '079'
            );
            DECLARE @Fecha_Actual DATETIME= GETDATE();
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '001', 
                 @id_Fila, 
                 @Cod_Eliminado, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '002', 
                 @id_Fila, 
                 'CAJ_GUIA_REMISION_REMITENTE', 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '003', 
                 @id_Fila, 
                 @Cliente, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '004', 
                 @id_Fila, 
                 @Detalle_Guia, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '005', 
                 @id_Fila, 
                 NULL, 
                 NULL, 
                 NULL, 
                 @Fecha_Emision, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '006', 
                 @id_Fila, 
                 NULL, 
                 NULL, 
                 NULL, 
                 @Fecha_Actual, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '007', 
                 @id_Fila, 
                 @Cod_Usuario, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '008', 
                 @id_Fila, 
                 @Justificacion, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 'MIGRACION';
            EXEC USP_PAR_FILA_G 
                 '079', 
                 '009', 
                 @id_Fila, 
                 NULL, 
                 NULL, 
                 NULL, 
                 NULL, 
                 1, 
                 1, 
                 'MIGRACION';
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(4000);
            SELECT @ErrorMessage = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
            IF(XACT_STATE()) = -1
                BEGIN
                    ROLLBACK TRANSACTION;
            END;
            IF(XACT_STATE()) = 1
                BEGIN
                    COMMIT TRANSACTION;
            END;
            THROW;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXPK;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrr.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
        WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
    END;
GO

--CAJ_GUIA_REMISION_REMITENTE_D
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_G @Id_GuiaRemisionRemitente INT, 
                                                     @Id_Detalle               INT, 
                                                     @Cod_Almacen              VARCHAR(32), 
                                                     @Cod_UnidadMedida         VARCHAR(5), 
                                                     @Id_Producto              INT, 
                                                     @Cantidad                 NUMERIC(38, 10), 
                                                     @Descripcion              VARCHAR(MAX), 
                                                     @Peso                     NUMERIC(38, 6), 
                                                     @Obs_Detalle              VARCHAR(MAX), 
                                                     @Cod_ProductoSunat        VARCHAR(32), 
                                                     @Cod_Usuario              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Id_Producto = 0
            BEGIN
                SET @Id_Producto = NULL;
        END;
        IF @Id_Detalle = 0
            BEGIN
                SET @Id_Detalle =
                (
                    SELECT ISNULL(MAX(cgrrd.Id_Detalle), 0) + 1
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
                    WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                );
        END;
        IF NOT EXISTS
        (
            SELECT cgrrd.*
            FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
            WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                  AND cgrrd.Id_Detalle = @Id_Detalle
        )
            BEGIN
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_D
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Id_Detalle, -- Id_Detalle - int
                 @Cod_Almacen, -- Cod_Almacen - varchar
                 @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
                 @Id_Producto, -- Id_Producto - int
                 @Cantidad, -- Cantidad - numeric
                 @Descripcion, -- Descripcion - varchar
                 @Peso, -- Peso - numeric
                 @Obs_Detalle, -- Obs_Detalle - varchar
                 @Cod_ProductoSunat, -- Cod_ProductoSunat - varchar
                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_D
                  SET 
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_Almacen = @Cod_Almacen, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UnidadMedida = @Cod_UnidadMedida, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Producto = @Id_Producto, -- int
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cantidad = @Cantidad, -- numeric
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Descripcion = @Descripcion, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Peso = @Peso, -- numeric
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Obs_Detalle = @Obs_Detalle, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_ProductoSunat = @Cod_ProductoSunat, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UsuarioAct = @Cod_Usuario, -- varchar
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Fecha_Act = GETDATE() -- datetime
                WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle = @Id_Detalle;
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_E;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_E @Id_GuiaRemisionRemitente INT, 
                                                     @Id_Detalle               INT
WITH ENCRYPTION
AS
    BEGIN
        --Eliminamos el detalle
        DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D
        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_Detalle = @Id_Detalle;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK @Id_GuiaRemisionRemitente INT, 
                                                        @Id_Detalle               INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrd.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
        WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrd.Id_Detalle = @Id_Detalle;
    END;
GO

--CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_G @Id_GuiaRemisionRemitente INT, 
                                                                @Item                     INT, 
                                                                @Cod_TipoDocumento        VARCHAR(5), 
                                                                @Id_DocRelacionado        INT, 
                                                                @Serie                    VARCHAR(32), 
                                                                @Numero                   VARCHAR(128), 
                                                                @Cod_TipoRelacion         VARCHAR(8), 
                                                                @Observacion              VARCHAR(MAX), 
                                                                @Cod_Usuario              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Item <> 0
            BEGIN
                IF NOT EXISTS
                (
                    SELECT cgrrr.*
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
                    WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                          AND cgrrr.Item = @Item
                )
                    BEGIN
                        INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                        VALUES
                        (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                         @Item, -- Item - int
                         @Cod_TipoDocumento, -- Cod_TipoDocumento - varchar
                         @Id_DocRelacionado, -- Id_DocRelacionado - int
                         @Serie, -- Serie - varchar
                         @Numero, -- Numero - varchar
                         @Cod_TipoRelacion, -- Cod_TipoRelacion - varchar
                         @Observacion, -- Observacion - varchar
                         @Cod_Usuario, -- Cod_UsuarioReg - varchar
                         GETDATE(), -- Fecha_Reg - datetime
                         NULL, -- Cod_UsuarioAct - varchar
                         NULL -- Fecha_Act - datetime
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                          SET 
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Cod_TipoDocumento = @Cod_TipoDocumento, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_DocRelacionado = @Id_DocRelacionado, -- int
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Serie = @Serie, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Numero = @Numero, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Cod_TipoRelacion = @Cod_TipoRelacion, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Observacion = @Observacion, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Cod_UsuarioAct = @Cod_Usuario, -- varchar
                              dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Fecha_Act = GETDATE() -- datetime
                        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                              AND dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Item = @Item;
                END;
        END;
            ELSE
            BEGIN
                --Insertamos en una nueva posicion
                SET @Item = ISNULL(
                (
                    SELECT MAX(cgrrr.Item)
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
                    WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                ), 0) + 1;
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - int
                 @Item, -- Item - int
                 @Cod_TipoDocumento, -- Cod_TipoDocumento - varchar
                 @Id_DocRelacionado, -- Id_DocRelacionado - int
                 @Serie, -- Serie - varchar
                 @Numero, -- Numero - varchar
                 @Cod_TipoRelacion, -- Cod_TipoRelacion - varchar
                 @Observacion, -- Observacion - varchar
                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                 GETDATE(), -- Fecha_Reg - datetime
                 NULL, -- Cod_UsuarioAct - varchar
                 NULL -- Fecha_Act - datetime
                );
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_E;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_E @Id_GuiaRemisionRemitente INT, 
                                                                @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS.Item = @Item;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_TXPK;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_TXPK @Id_GuiaRemisionRemitente INT, 
                                                                   @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrr.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
        WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrr.Item = @Item;
    END;
GO

--CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_G @Id_GuiaRemisionRemitente INT, 
                                                                  @Item                     INT, 
                                                                  @Cod_TipoDocumento        VARCHAR(5), 
                                                                  @Numero                   VARCHAR(64), 
                                                                  @Nombres                  VARCHAR(MAX), 
                                                                  @Direccion                VARCHAR(MAX), 
                                                                  @Cod_ModalidadTransporte  VARCHAR(5), 
                                                                  @Licencia                 VARCHAR(64), 
                                                                  @Observaciones            VARCHAR(MAX), 
                                                                  @Cod_Usuario              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Item <> 0
            BEGIN
                IF NOT EXISTS
                (
                    SELECT cgrrt.*
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
                    WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                          AND cgrrt.Item = @Item
                )
                    BEGIN
                        INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                        VALUES
                        (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - INT
                         @Item, -- Item - INT
                         @Cod_TipoDocumento, -- Cod_TipoDocumento - VARCHAR
                         @Numero, -- Numero_Documento - VARCHAR
                         @Nombres, -- Nombres - VARCHAR
                         @Direccion, --Direccion - VARCHAR
                         @Cod_ModalidadTransporte, -- Cod_ModalidadTransporte - VARCHAR
                         @Licencia, --Licencia - VARCHAR
                         @Observaciones, -- Observaciones - VARCHAR
                         @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                         GETDATE(), -- Fecha_Reg - DATETIME
                         NULL, -- Cod_UsuarioAct - VARCHAR
                         NULL -- Fecha_Act - DATETIME
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                          SET 
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_TipoDocumento = @Cod_TipoDocumento, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Numero_Documento = @Numero, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Nombres = @Nombres, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Direccion = @Direccion, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_ModalidadTransporte = @Cod_ModalidadTransporte, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Licencia = @Licencia, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Observaciones = @Observaciones, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Fecha_Act = GETDATE() -- DATETIME
                        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                              AND dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Item = @Item;
                END;
        END;
            ELSE
            BEGIN
                SET @Item = ISNULL(
                (
                    SELECT MAX(cgrrt.Item)
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
                    WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                ), 0) + 1;
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - INT
                 @Item, -- Item - INT
                 @Cod_TipoDocumento, -- Cod_TipoDocumento - VARCHAR
                 @Numero, -- Numero_Documento - VARCHAR
                 @Nombres, -- Nombres - VARCHAR
                 @Direccion, --Direccion - VARCHAR
                 @Cod_ModalidadTransporte, -- Cod_ModalidadTransporte - VARCHAR
                 @Licencia, --Licencia - VARCHAR
                 @Observaciones, -- Observaciones - VARCHAR
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_E;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_E @Id_GuiaRemisionRemitente INT, 
                                                                  @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS.Item = @Item;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_TXPK;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_TXPK @Id_GuiaRemisionRemitente INT, 
                                                                     @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrt.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
        WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrt.Item = @Item;
    END;
GO

--CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_G @Id_GuiaRemisionRemitente INT, 
                                                             @Item                     INT, 
                                                             @Placa                    VARCHAR(64), 
                                                             @Certificado_Inscripcion  VARCHAR(1024), 
                                                             @Certificado_Habilitacion VARCHAR(1024), 
                                                             @Observaciones            VARCHAR(MAX), 
                                                             @Cod_Usuario              VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Item <> 0
            BEGIN
                IF NOT EXISTS
                (
                    SELECT cgrrv.*
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
                    WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                          AND cgrrv.Item = @Item
                )
                    BEGIN
                        INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                        VALUES
                        (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - INT
                         @Item, -- Item - INT
                         @Placa, -- Placa - VARCHAR
                         @Certificado_Inscripcion, -- Certificado_Inscripcion - VARCHAR
                         @Certificado_Habilitacion, -- Certificado_Habilitacion - VARCHAR
                         @Observaciones, -- Observaciones - VARCHAR
                         @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                         GETDATE(), -- Fecha_Reg - DATETIME
                         NULL, -- Cod_UsuarioAct - VARCHAR
                         NULL -- Fecha_Act - DATETIME
                        );
                END;
                    ELSE
                    BEGIN
                        UPDATE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                          SET 
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente, -- INT
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Item = @Item, -- INT
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Placa = @Placa, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Certificado_Inscripcion = @Certificado_Inscripcion, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Certificado_Habilitacion = @Certificado_Habilitacion, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Observaciones = @Observaciones, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                              dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Fecha_Act = GETDATE() -- DATETIME
                        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                              AND dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Item = @Item;
                END;
        END;
            ELSE
            BEGIN
                SET @Item = ISNULL(
                (
                    SELECT MAX(cgrrv.Item)
                    FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
                    WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                ), 0) + 1;
                INSERT INTO dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                VALUES
                (@Id_GuiaRemisionRemitente, -- Id_GuiaRemisionRemitente - INT
                 @Item, -- Item - INT
                 @Placa, -- Placa - VARCHAR
                 @Certificado_Inscripcion, -- Certificado_Inscripcion - VARCHAR
                 @Certificado_Habilitacion, -- Certificado_Habilitacion - VARCHAR
                 @Observaciones, -- Observaciones - VARCHAR
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_E;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_E @Id_GuiaRemisionRemitente INT, 
                                                             @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
        WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS.Item = @Item;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_TXPK;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_TXPK @Id_GuiaRemisionRemitente INT, 
                                                                @Item                     INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrv.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
        WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrv.Item = @Item;
    END;
GO

--Metodo para traer datos principales de guia (ni transportista, vehiculos, relacionados)

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               cgrr.Serie, 
               cgrr.Numero, 
               vtc.Nom_TipoComprobante, 
               cgrr.Direccion_Partida, 
               cgrr.Fecha_Emision, 
               cgrr.Fecha_TrasladoBienes, 
               cgrr.Fecha_EntregaBienes, 
               pcp.Cliente Nom_Destinatario, 
               pcp.Nro_Documento Doc_Destinatario, 
               cgrr.Direccion_LLegada, 
               cgrr.Cod_MotivoTraslado, 
               vgrrm.Des_Motivo, 
               cgrr.Des_MotivoTraslado, 
               cgrrd.Id_Producto, 
        (
            SELECT pp.Cod_Producto
            FROM dbo.PRI_PRODUCTOS pp
            WHERE pp.Id_Producto = cgrrd.Id_Producto
        ) Cod_Producto, 
               cgrrd.Cantidad, 
               cgrrd.Cod_UnidadMedida, 
               cgrrd.Descripcion, 
               cgrrd.Peso, 
               cgrr.Peso_Bruto
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd ON cgrr.Id_GuiaRemisionRemitente = cgrrd.Id_GuiaRemisionRemitente
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON cgrr.Id_ClienteDestinatario = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_GUIA_REMISION_REMITENTE_MOTIVOS vgrrm ON cgrr.Cod_MotivoTraslado = vgrrm.Cod_Motivo
        WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
    END;
GO

--Metodo que trae los comprobantes realcionados

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_ComprobantesRelacionados_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_ComprobantesRelacionados_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_ComprobantesRelacionados_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vtc.Nom_TipoComprobante, 
               ccp.Serie + '-' + ccp.Numero Comprobante
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrrr.Cod_TipoDocumento = vtc.Cod_TipoComprobante
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON cgrrr.Id_DocRelacionado = ccp.id_ComprobantePago
        WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrr.Cod_TipoRelacion = 'GRR'; --Comprobantes

    END;
GO

--Metodo que trae los vehiculos

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_Relacionados_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_Relacionados_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_Relacionados_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               cgrrv.Placa, 
               cgrrv.Certificado_Inscripcion, 
               cgrrv.Certificado_Habilitacion
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
        WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
    END;
GO

--Metodo que trae los conductores

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_Conductores_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_Conductores_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_Conductores_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               cgrr.Cod_ModalidadTraslado,
               CASE
                   WHEN cgrrt.Cod_ModalidadTransporte = '01'
                   THEN 'TRANSPORTE PUBLICO'
                   WHEN cgrrt.Cod_ModalidadTransporte = '02'
                   THEN 'TRANSPORTE PRIVADO'
                   ELSE ''
               END Des_ModalidadTraslado, 
               cgrrt.Cod_TipoDocumento, 
               vtd.Nom_TipoDoc, 
               cgrrt.Numero_Documento, 
               cgrrt.Nombres, 
               cgrrt.Direccion, 
               cgrrt.Licencia
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE cgrr ON cgrrt.Id_GuiaRemisionRemitente = cgrr.Id_GuiaRemisionRemitente
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON cgrrt.Cod_TipoDocumento = vtd.Cod_TipoDoc
        WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
    END;
GO

--Obtiene los docuemntos relacionados

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_Documentos_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_Documentos_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_Documentos_TXPK @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               cgrrr.Cod_TipoDocumento, 
               vgrrdr.Des_Relacionado, 
               cgrrr.Serie, 
               cgrrr.Numero
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
             INNER JOIN dbo.VIS_GUIA_REMISION_REMITENTE_DOCUMENTOS_RELACIONADOS vgrrdr ON cgrrr.Cod_TipoDocumento = vgrrdr.Cod_Relacionado
        WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrr.Cod_TipoRelacion = 'COM';
    END;
GO

--Obtiene las guias de remision en base al cod_libro,Cod_tipo,Serie y Numero

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TXCodLibro_CodTipoComprobante_Serie_Numero'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXCodLibro_CodTipoComprobante_Serie_Numero;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TXCodLibro_CodTipoComprobante_Serie_Numero @Cod_Libro           VARCHAR(2), 
                                                                                            @Cod_TipoComprobante VARCHAR(5), 
                                                                                            @Serie               VARCHAR(5), 
                                                                                            @Numero              VARCHAR(30)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               cgrr.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
        WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
              AND cgrr.Cod_Libro = @Cod_Libro
              AND cgrr.Serie = @Serie
              AND cgrr.Numero = @Numero;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXCodLibroCodCaja'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXCodLibroCodCaja;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXCodLibroCodCaja @Cod_Libro VARCHAR(2), 
                                                                                   @Cod_Caja  VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        IF @Cod_Libro = '08'
            BEGIN
                --Traemos todos los tipos de comprobantes
                SELECT DISTINCT 
                       vtc.Cod_TipoComprobante, 
                       vtc.Nom_TipoComprobante
                FROM dbo.VIS_TIPO_COMPROBANTES vtc
                WHERE vtc.Estado = 1
                      AND vtc.Cod_TipoComprobante IN('GR', 'GRE');
        END;
            ELSE
            BEGIN
                SELECT DISTINCT 
                       vtc.Cod_TipoComprobante, 
                       vtc.Nom_TipoComprobante, 
                       ccd.Serie, 
                       ccd.Flag_Imprimir, 
                       ccd.Nom_Archivo,
					   ccd.Impresora
                FROM dbo.CAJ_CAJAS_DOC ccd
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccd.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                WHERE ccd.Cod_Caja = @Cod_Caja
                      AND vtc.Cod_TipoComprobante IN('GR', 'GRE')
                     AND vtc.Estado = 1;
        END;
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TraerGuias'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TraerGuias;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TraerGuias @Cod_Caja            VARCHAR(32) = NULL, 
                                                            @Cod_Turno           VARCHAR(32) = NULL, 
                                                            @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                            @Cod_Libro           VARCHAR(2)  = NULL, 
                                                            @Cod_Periodo         VARCHAR(8)  = NULL, 
                                                            @Serie               VARCHAR(5)  = NULL, 
                                                            @Cod_EstadoGuia      VARCHAR(8)  = NULL, 
                                                            @Flag_Anulado        BIT         = NULL, 
                                                            @Fecha_Inicio        DATETIME    = NULL, 
                                                            @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrr.Serie, 
               cgrr.Numero, 
               vtc.Nom_TipoComprobante, 
               cgrr.Direccion_Partida, 
               cgrr.Fecha_Emision, 
               cgrr.Fecha_TrasladoBienes, 
               cgrr.Fecha_EntregaBienes, 
               pcp.Cliente Nom_Destinatario, 
               pcp.Nro_Documento Doc_Destinatario, 
               cgrr.Direccion_LLegada, 
               cgrr.Cod_MotivoTraslado, 
               vgrrm.Des_Motivo, 
               cgrr.Des_MotivoTraslado, 
               cgrrd.Id_Producto, 
        (
            SELECT pp.Cod_Producto
            FROM dbo.PRI_PRODUCTOS pp
            WHERE pp.Id_Producto = cgrrd.Id_Producto
        ) Cod_Producto, 
               cgrrd.Cantidad, 
               cgrrd.Cod_UnidadMedida, 
               cgrrd.Descripcion, 
               cgrrd.Peso, 
               cgrr.Peso_Bruto
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd ON cgrr.Id_GuiaRemisionRemitente = cgrrd.Id_GuiaRemisionRemitente
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON cgrr.Id_ClienteDestinatario = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_GUIA_REMISION_REMITENTE_MOTIVOS vgrrm ON cgrr.Cod_MotivoTraslado = vgrrm.Cod_Motivo
        WHERE(@Cod_Caja IS NULL
              OR cgrr.Cod_Caja = @Cod_Caja)
             AND (@Cod_Turno IS NULL
                  OR cgrr.Cod_Turno = @Cod_Turno)
             AND (@Cod_TipoComprobante IS NULL
                  OR cgrr.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND (@Cod_Libro IS NULL
                  OR cgrr.Cod_Libro = @Cod_Libro)
             AND (@Cod_Periodo IS NULL
                  OR cgrr.Cod_Periodo = @Cod_Periodo)
             AND (@Serie IS NULL
                  OR cgrr.Serie = @Serie)
             AND (@Cod_EstadoGuia IS NULL
                  OR cgrr.Cod_EstadoGuia = @Cod_EstadoGuia)
             AND (@Flag_Anulado IS NULL
                  OR cgrr.Flag_Anulado = @Flag_Anulado)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (cgrr.Fecha_Emision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND cgrr.Fecha_Emision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))));
    END;
GO

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_NumeroXTipoSerieLibro'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_NumeroXTipoSerieLibro;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_NumeroXTipoSerieLibro @Cod_TipoComprobante VARCHAR(5), 
                                                                       @Serie               VARCHAR(4), 
                                                                       @Cod_Libro           VARCHAR(4)
WITH ENCRYPTION
AS
    BEGIN
        SELECT ISNULL(MAX(CONVERT(INT, Numero)) + 1, 1) Numero_Siguiente
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
        WHERE cgrr.Cod_TipoComprobante = @Cod_TipoComprobante
              AND cgrr.Serie = @Serie
              AND cgrr.Cod_Libro = @Cod_Libro;
    END;
GO