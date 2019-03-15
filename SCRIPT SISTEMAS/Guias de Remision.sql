
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_SUCURSAL_TraerSucursalesActivas'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas;
GO
CREATE PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas
WITH ENCRYPTION
AS
    BEGIN
        SELECT ps.Cod_Sucursal, 
               ps.Nom_Sucursal, 
               ps.Dir_Sucursal, 
               ps.Por_UtilidadMax, 
               ps.Por_UtilidadMin, 
               ps.Cod_UsuarioAdm, 
               ps.Cabecera_Pagina, 
               ps.Pie_Pagina, 
               ps.Cod_Ubigeo, 
               COALESCE(ps.Cod_UsuarioAct, ps.Cod_UsuarioReg) Cod_Usuario, 
               COALESCE(ps.Fecha_Act, ps.Fecha_Reg) Fecha_UltimaModificacion
        FROM dbo.PRI_SUCURSAL ps
        WHERE ps.Flag_Activo = 1;
    END;
GO

--trae un datatable con todos los comprobante por numero de documento y cod libro
--genera un campo extra FechaEmisionAbsoluta que es la fecha de emision absoluta
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro @NumeroDocumento VARCHAR(32), 
                                                                @CodLibro        VARCHAR(4)
WITH ENCRYPTION
AS
    BEGIN
        IF @CodLibro <> ''
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago, 
                       ISNULL(ccp.Cod_Libro, '') Cod_Libro, 
                       ISNULL(ccp.Cod_Periodo, '') Cod_Periodo, 
                       ISNULL(ccp.Cod_Caja, '') Cod_Caja, 
                       ISNULL(cc.Des_Caja, '') Des_Caja, 
                       ISNULL(ccp.Cod_Turno, '') Cod_Turno, 
                       ISNULL(ccp.Cod_TipoComprobante, '') Cod_TipoComprobante, 
                       ISNULL(vtc.Nom_TipoComprobante, '') Nom_TipoComprobante, 
                       ISNULL(ccp.Cod_TipoComprobante + ':', '') + ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') CodSerieNumero, 
                       ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') SerieNumero, 
                       ISNULL(ccp.Serie, '') Serie, 
                       ISNULL(ccp.Numero, '') Numero, 
                       ISNULL(ccp.Id_Cliente, 0) Id_Cliente, 
                       ISNULL(ccp.Cod_TipoDoc, '') Cod_TipoDoc, 
                       ISNULL(vtd.Nom_TipoDoc, '') Nom_TipoDoc, 
                       ISNULL(ccp.Doc_Cliente, '') Doc_Cliente, 
                       ISNULL(ccp.Nom_Cliente, '') Nom_Cliente, 
                       ISNULL(ccp.Direccion_Cliente, '') Direccion_Cliente, 
                       CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) FechaEmision, 
                       ccp.Flag_Anulado, 
                       ISNULL(ccp.Cod_Moneda, '') Cod_Moneda, 
                       ISNULL(vm.Nom_Moneda, '') Nom_Moneda, 
                       ISNULL(ccp.Impuesto, 0) Impuesto, 
                       ISNULL(ccp.Total, 0) Total, 
                       ISNULL(ccp.Cod_UsuarioVendedor, '') Cod_UsuarioVendedor, 
                       ISNULL(ccp.Cod_EstadoComprobante, '') Cod_EstadoComprobante, 
                       ISNULL(ccp.MotivoAnulacion, '') MotivoAnulacion, 
                       ISNULL(ccp.Otros_Cargos, 0) Otros_Cargos, 
                       ISNULL(ccp.Otros_Tributos, 0) Otros_Tributos
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_CAJAS cc ON cc.Cod_Caja = ccp.Cod_Caja
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                     INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
                     INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
                WHERE ccp.Doc_Cliente = @NumeroDocumento
                      AND ccp.Cod_Libro = @CodLibro
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
            ELSE
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago, 
                       ISNULL(ccp.Cod_Libro, '') Cod_Libro, 
                       ISNULL(ccp.Cod_Periodo, '') Cod_Periodo, 
                       ISNULL(ccp.Cod_Caja, '') Cod_Caja, 
                       ISNULL(cc.Des_Caja, '') Des_Caja, 
                       ISNULL(ccp.Cod_Turno, '') Cod_Turno, 
                       ISNULL(ccp.Cod_TipoComprobante, '') Cod_TipoComprobante, 
                       ISNULL(vtc.Nom_TipoComprobante, '') Nom_TipoComprobante, 
                       ISNULL(ccp.Cod_TipoComprobante + ':', '') + ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') CodSerieNumero, 
                       ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') SerieNumero, 
                       ISNULL(ccp.Serie, '') Serie, 
                       ISNULL(ccp.Numero, '') Numero, 
                       ISNULL(ccp.Id_Cliente, 0) Id_Cliente, 
                       ISNULL(ccp.Cod_TipoDoc, '') Cod_TipoDoc, 
                       ISNULL(vtd.Nom_TipoDoc, '') Nom_TipoDoc, 
                       ISNULL(ccp.Doc_Cliente, '') Doc_Cliente, 
                       ISNULL(ccp.Nom_Cliente, '') Nom_Cliente, 
                       ISNULL(ccp.Direccion_Cliente, '') Direccion_Cliente, 
                       CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) FechaEmision, 
                       ccp.Flag_Anulado, 
                       ISNULL(ccp.Cod_Moneda, '') Cod_Moneda, 
                       ISNULL(vm.Nom_Moneda, '') Nom_Moneda, 
                       ISNULL(ccp.Impuesto, 0) Impuesto, 
                       ISNULL(ccp.Total, 0) Total, 
                       ISNULL(ccp.Cod_UsuarioVendedor, '') Cod_UsuarioVendedor, 
                       ISNULL(ccp.Cod_EstadoComprobante, '') Cod_EstadoComprobante, 
                       ISNULL(ccp.MotivoAnulacion, '') MotivoAnulacion, 
                       ISNULL(ccp.Otros_Cargos, 0) Otros_Cargos, 
                       ISNULL(ccp.Otros_Tributos, 0) Otros_Tributos
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_CAJAS cc ON cc.Cod_Caja = ccp.Cod_Caja
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                     INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
                     INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
                WHERE ccp.Doc_Cliente = @NumeroDocumento
                      AND ccp.Cod_Libro <> ''
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
    END;
GO

--trae un datatable con todos los comprobante por nombre de cliente y cod libro
--genera un campo extra FechaEmisionAbsoluta que es la fecha de emision absoluta
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro @NombreCliente VARCHAR(250), 
                                                                    @CodLibro      VARCHAR(4)
WITH ENCRYPTION
AS
    BEGIN
        IF @CodLibro <> ''
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago, 
                       ISNULL(ccp.Cod_Libro, '') Cod_Libro, 
                       ISNULL(ccp.Cod_Periodo, '') Cod_Periodo, 
                       ISNULL(ccp.Cod_Caja, '') Cod_Caja, 
                       ISNULL(cc.Des_Caja, '') Des_Caja, 
                       ISNULL(ccp.Cod_Turno, '') Cod_Turno, 
                       ISNULL(ccp.Cod_TipoComprobante, '') Cod_TipoComprobante, 
                       ISNULL(vtc.Nom_TipoComprobante, '') Nom_TipoComprobante, 
                       ISNULL(ccp.Cod_TipoComprobante + ':', '') + ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') CodSerieNumero, 
                       ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') SerieNumero, 
                       ISNULL(ccp.Serie, '') Serie, 
                       ISNULL(ccp.Numero, '') Numero, 
                       ISNULL(ccp.Id_Cliente, 0) Id_Cliente, 
                       ISNULL(ccp.Cod_TipoDoc, '') Cod_TipoDoc, 
                       ISNULL(vtd.Nom_TipoDoc, '') Nom_TipoDoc, 
                       ISNULL(ccp.Doc_Cliente, '') Doc_Cliente, 
                       ISNULL(ccp.Nom_Cliente, '') Nom_Cliente, 
                       ISNULL(ccp.Direccion_Cliente, '') Direccion_Cliente, 
                       CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) FechaEmision, 
                       ccp.Flag_Anulado, 
                       ISNULL(ccp.Cod_Moneda, '') Cod_Moneda, 
                       ISNULL(vm.Nom_Moneda, '') Nom_Moneda, 
                       ISNULL(ccp.Impuesto, 0) Impuesto, 
                       ISNULL(ccp.Total, 0) Total, 
                       ISNULL(ccp.Cod_UsuarioVendedor, '') Cod_UsuarioVendedor, 
                       ISNULL(ccp.Cod_EstadoComprobante, '') Cod_EstadoComprobante, 
                       ISNULL(ccp.MotivoAnulacion, '') MotivoAnulacion, 
                       ISNULL(ccp.Otros_Cargos, 0) Otros_Cargos, 
                       ISNULL(ccp.Otros_Tributos, 0) Otros_Tributos
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_CAJAS cc ON cc.Cod_Caja = ccp.Cod_Caja
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                     INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
                     INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
                WHERE ccp.Nom_Cliente LIKE '%' + @NombreCliente + '%'
                      AND ccp.Cod_Libro = @CodLibro
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
            ELSE
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago, 
                       ISNULL(ccp.Cod_Libro, '') Cod_Libro, 
                       ISNULL(ccp.Cod_Periodo, '') Cod_Periodo, 
                       ISNULL(ccp.Cod_Caja, '') Cod_Caja, 
                       ISNULL(cc.Des_Caja, '') Des_Caja, 
                       ISNULL(ccp.Cod_Turno, '') Cod_Turno, 
                       ISNULL(ccp.Cod_TipoComprobante, '') Cod_TipoComprobante, 
                       ISNULL(vtc.Nom_TipoComprobante, '') Nom_TipoComprobante, 
                       ISNULL(ccp.Cod_TipoComprobante + ':', '') + ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') CodSerieNumero, 
                       ISNULL(ccp.Serie, '') + '-' + ISNULL(ccp.Numero, '') SerieNumero, 
                       ISNULL(ccp.Serie, '') Serie, 
                       ISNULL(ccp.Numero, '') Numero, 
                       ISNULL(ccp.Id_Cliente, 0) Id_Cliente, 
                       ISNULL(ccp.Cod_TipoDoc, '') Cod_TipoDoc, 
                       ISNULL(vtd.Nom_TipoDoc, '') Nom_TipoDoc, 
                       ISNULL(ccp.Doc_Cliente, '') Doc_Cliente, 
                       ISNULL(ccp.Nom_Cliente, '') Nom_Cliente, 
                       ISNULL(ccp.Direccion_Cliente, '') Direccion_Cliente, 
                       CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) FechaEmision, 
                       ccp.Flag_Anulado, 
                       ISNULL(ccp.Cod_Moneda, '') Cod_Moneda, 
                       ISNULL(vm.Nom_Moneda, '') Nom_Moneda, 
                       ISNULL(ccp.Impuesto, 0) Impuesto, 
                       ISNULL(ccp.Total, 0) Total, 
                       ISNULL(ccp.Cod_UsuarioVendedor, '') Cod_UsuarioVendedor, 
                       ISNULL(ccp.Cod_EstadoComprobante, '') Cod_EstadoComprobante, 
                       ISNULL(ccp.MotivoAnulacion, '') MotivoAnulacion, 
                       ISNULL(ccp.Otros_Cargos, 0) Otros_Cargos, 
                       ISNULL(ccp.Otros_Tributos, 0) Otros_Tributos
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_CAJAS cc ON cc.Cod_Caja = ccp.Cod_Caja
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                     INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
                     INNER JOIN dbo.VIS_MONEDAS vm ON ccp.Cod_Moneda = vm.Cod_Moneda
                WHERE ccp.Nom_Cliente LIKE '%' + @NombreCliente + '%'
                      AND ccp.Cod_Libro <> ''
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
    END;
GO
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

--Creamos las tablas
IF OBJECT_ID('CAJ_GUIA_REMISION_REMITENTE', 'U') IS NULL
    BEGIN
        CREATE TABLE CAJ_GUIA_REMISION_REMITENTE
        (Id_GuiaRemisionRemitente       INT IDENTITY(1, 1) PRIMARY KEY, 
         Cod_Caja                       VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_CAJAS(Cod_Caja), 
         Cod_Turno                      VARCHAR(32) FOREIGN KEY REFERENCES dbo.CAJ_TURNO_ATENCION(Cod_Turno), 
         Cod_TipoComprobante            VARCHAR(5) NOT NULL, 
         Cod_Libro                      VARCHAR(2) NOT NULL, --Indica si la guia es para emitir o para registrar (similar a venta-compra)
         Serie                          VARCHAR(5) NOT NULL, 
         Numero                         VARCHAR(30) NOT NULL, 
         Fecha_Emision                  DATETIME NOT NULL, 
         Fecha_TrasladoBienes           DATETIME NOT NULL, 
         Fecha_EntregaBienes            DATETIME, 
         Cod_MotivoTraslado             VARCHAR(5) NOT NULL, 
         Des_MotivoTraslado             VARCHAR(MAX) NOT NULL, 
         Cod_ModalidadTraslado          VARCHAR(5), 
         Cod_UnidadMedida               VARCHAR(5) NOT NULL, 
         Id_ClienteDestinatario         INT FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor), 
         Cod_UbigeoPartida              VARCHAR(8) NOT NULL, 
         Direccion_Partida              VARCHAR(MAX) NOT NULL, 
         Cod_UbigeoLlegada              VARCHAR(8) NOT NULL, 
         Direccion_LLegada              VARCHAR(MAX) NOT NULL, 
         Documentos_Relacionados        VARCHAR(MAX), 
         Comprobantes_Relacionados      VARCHAR(MAX), 
         Num_ManifiestoCarga            VARCHAR(MAX), 
         Num_DAM                        VARCHAR(MAX), 
         Flag_Transbordo                BIT, 
         Peso_Bruto                     NUMERIC(38, 6) NOT NULL, 
         Id_ClienteTransportistaPublico INT FOREIGN KEY REFERENCES dbo.PRI_CLIENTE_PROVEEDOR(Id_ClienteProveedor), 
         Num_PlacaTransportePrivado     VARCHAR(MAX), 
         Conductor_TransportePrivado    VARCHAR(MAX), 
         Licencia_Conductor             VARCHAR(MAX), 
         Obs_Transportista              VARCHAR(MAX), 
         Nro_Contenedor                 VARCHAR(64), 
         Cod_Puerto                     VARCHAR(64), 
         Nro_Bulltos                    INT, --O pallets, numerico 12 segun sunat
         Certificado_Inscripcion        VARCHAR(MAX), 
         Certificado_Habilitacion       VARCHAR(MAX), 
         Cod_EstadoGuia                 VARCHAR(8) NOT NULL, 
         Obs_GuiaRemisionRemitente      VARCHAR(MAX), 
         Id_GuiaRemisionRemitenteBaja   INT NULL, 
         Flag_Anulado                   BIT, 
         Valor_Resumen                  VARCHAR(1024), 
         Valor_Firma                    VARCHAR(2048), 
         Cod_UsuarioReg                 VARCHAR(32) NOT NULL, 
         Fecha_Reg                      DATETIME NOT NULL, 
         Cod_UsuarioAct                 VARCHAR(32), 
         Fecha_Act                      DATETIME
        );
END;
GO
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

--Metodos CRUD
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_G @Id_GuiaRemisionRemitente       INT OUTPUT, 
                                                   @Cod_Caja                       VARCHAR(32), 
                                                   @Cod_Turno                      VARCHAR(32), 
                                                   @Cod_TipoComprobante            VARCHAR(5), 
                                                   @Cod_Libro                      VARCHAR(2), 
                                                   @Serie                          VARCHAR(5), 
                                                   @Numero                         VARCHAR(30), 
                                                   @Fecha_Emision                  DATETIME, 
                                                   @Fecha_TrasladoBienes           DATETIME, 
                                                   @Fecha_EntregaBienes            DATETIME, 
                                                   @Cod_MotivoTraslado             VARCHAR(5), 
                                                   @Des_MotivoTraslado             VARCHAR(MAX), 
                                                   @Cod_ModalidadTraslado          VARCHAR(5), 
                                                   @Cod_UnidadMedida               VARCHAR(5), 
                                                   @Id_ClienteDestinatario         INT, 
                                                   @Cod_UbigeoPartida              VARCHAR(8), 
                                                   @Direccion_Partida              VARCHAR(MAX), 
                                                   @Cod_UbigeoLlegada              VARCHAR(8), 
                                                   @Direccion_LLegada              VARCHAR(MAX), 
                                                   @Documentos_Relacionados        VARCHAR(MAX), 
                                                   @Comprobantes_Relacionados      VARCHAR(MAX), 
                                                   @Num_ManifiestoCarga            VARCHAR(MAX), 
                                                   @Num_DAM                        VARCHAR(MAX), 
                                                   @Flag_Transbordo                BIT, 
                                                   @Peso_Bruto                     NUMERIC(38, 6), 
                                                   @Id_ClienteTransportistaPublico INT, 
                                                   @Num_PlacaTransportePrivado     VARCHAR(MAX), 
                                                   @Conductor_TransportePrivado    VARCHAR(MAX), 
                                                   @Licencia_Conductor             VARCHAR(MAX), 
                                                   @Obs_Transportista              VARCHAR(MAX), 
                                                   @Nro_Contenedor                 VARCHAR(64), 
                                                   @Cod_Puerto                     VARCHAR(64), 
                                                   @Nro_Bulltos                    INT, 
                                                   @Certificado_Inscripcion        VARCHAR(MAX), 
                                                   @Certificado_Habilitacion       VARCHAR(MAX), 
                                                   @Cod_EstadoGuia                 VARCHAR(8), 
                                                   @Obs_GuiaRemisionRemitente      VARCHAR(MAX), 
                                                   @Id_GuiaRemisionRemitenteBaja   INT, 
                                                   @Flag_Anulado                   BIT, 
                                                   @Valor_Resumen                  VARCHAR(1024), 
                                                   @Valor_Firma                    VARCHAR(2048), 
                                                   @Cod_Usuario                    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        IF @Id_ClienteTransportistaPublico = 0
            BEGIN
                SET @Id_ClienteTransportistaPublico = NULL;
        END;
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
                @Documentos_Relacionados, -- Documentos_Relacionados - VARCHAR
                @Comprobantes_Relacionados, -- Comprobantes_Relacionados - VARCHAR
                @Num_ManifiestoCarga, -- Num_ManifiestoCarga - VARCHAR
                @Num_DAM, -- Num_DAM - VARCHAR
                @Flag_Transbordo, -- Flag_Transbordo - BIT
                @Peso_Bruto, -- Peso_Bruto - NUMERIC
                @Id_ClienteTransportistaPublico, -- Id_ClienteTransportistaPublico - INT
                @Num_PlacaTransportePrivado, -- Num_PlacaTransportePrivado - VARCHAR
                @Conductor_TransportePrivado, -- Conductor_TransportePrivado - VARCHAR
                @Licencia_Conductor, -- Licencia_Conductor - VARCHAR
                @Obs_Transportista, -- Obs_Transportista - VARCHAR
                @Nro_Contenedor, -- Nro_Contenedor - VARCHAR
                @Cod_Puerto, -- Cod_Puerto - VARCHAR
                @Nro_Bulltos, -- Nro_Bulltos - INT
                @Certificado_Inscripcion, -- Certificado_Inscripcion - VARCHAR
                @Certificado_Habilitacion, -- Certificado_Habilitacion - VARCHAR
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
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Documentos_Relacionados = @Documentos_Relacionados, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Comprobantes_Relacionados = @Comprobantes_Relacionados, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Num_ManifiestoCarga = @Num_ManifiestoCarga, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Num_DAM = @Num_DAM, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Flag_Transbordo = @Flag_Transbordo, -- BIT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Peso_Bruto = @Peso_Bruto, -- NUMERIC
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Id_ClienteTransportistaPublico = @Id_ClienteTransportistaPublico, -- INT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Num_PlacaTransportePrivado = @Num_PlacaTransportePrivado, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Conductor_TransportePrivado = @Conductor_TransportePrivado, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Licencia_Conductor = @Licencia_Conductor, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Obs_Transportista = @Obs_Transportista, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Contenedor = @Nro_Contenedor, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Cod_Puerto = @Cod_Puerto, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Nro_Bulltos = @Nro_Bulltos, -- INT
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Certificado_Inscripcion = @Certificado_Inscripcion, -- VARCHAR
                      dbo.CAJ_GUIA_REMISION_REMITENTE.Certificado_Habilitacion = @Certificado_Habilitacion, -- VARCHAR
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
            --Verificar que no existan un item superior 
            IF EXISTS
            (
                SELECT cgrr.*
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                      AND cgrr.Cod_EstadoGuia NOT IN('INI', 'EMI')
                AND cgrr.Cod_Libro = '14'
            )
                BEGIN
                    RAISERROR('No se puede Eliminar Dicho comprombprobante porque ya fue notificado a SUNAT', 16, 1);
            END;
                ELSE
                BEGIN
                    IF EXISTS
                    (
                        SELECT cgrr.*
                        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                        WHERE cgrr.Cod_Libro = '14'
                              AND cgrr.Cod_TipoComprobante + cgrr.Serie =
                        (
                            SELECT cgrr2.Cod_TipoComprobante + cgrr2.Serie
                            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr2
                            WHERE cgrr2.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                                  AND cgrr2.Cod_Libro = '14'
                        )
                              AND cgrr.Numero >
                        (
                            SELECT CONVERT(BIGINT, cgrr2.Numero)
                            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr2
                            WHERE cgrr2.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
                                  AND cgrr2.Cod_Libro = '14'
                        )
                    )
                        BEGIN
                            RAISERROR('No se puede Eliminar Dicho Comprobante porque existe un Numero Superior que lo precede.', 16, 1);
                    END;
                        ELSE
                        BEGIN
                            --Variables para almacenar en la vista
                            DECLARE @Documento VARCHAR(MAX);
                            DECLARE @Cliente VARCHAR(MAX);
                            DECLARE @Fecha_Emision DATETIME;
                            SELECT @Documento = cgrr.Cod_Libro + '|' + cgrr.Cod_TipoComprobante + ':' + cgrr.Serie + '-' + cgrr.Numero + '|' + cgrr.Cod_UnidadMedida, 
                                   @Cliente = CONVERT(VARCHAR, cgrr.Id_ClienteDestinatario) + '|' + cgrr.Direccion_Partida + '|' + cgrr.Direccion_LLegada, 
                                   @Fecha_Emision = cgrr.Fecha_Emision
                            FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
                            WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
                            DECLARE @Detalles VARCHAR(MAX)= STUFF(
                            (
                                SELECT ';' + CONCAT(CONVERT(VARCHAR(32), cgrrd.Id_Producto), '|', CONVERT(VARCHAR(54), cgrrd.Cantidad), '|', cgrrd.Descripcion)
                                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
                                WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
                            ), 1, 2, '') + '';
                            --Eliminamos los detalles
                            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE_D
                            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE_D.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
                            --Eliminamnos la cabezera
                            DELETE dbo.CAJ_GUIA_REMISION_REMITENTE
                            WHERE dbo.CAJ_GUIA_REMISION_REMITENTE.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
                            --Guardamos el comprobante en la vista eliminados
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
                                 @Documento, 
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
                                 @Detalles, 
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
                    END;
            END;
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
                                                     @Cod_USuario              VARCHAR(32)
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
                 @Cod_USuario, -- Cod_UsuarioReg - varchar
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
                      dbo.CAJ_GUIA_REMISION_REMITENTE_D.Cod_UsuarioAct = @Cod_USuario, -- varchar
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
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TT;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrr.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TT;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrd.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_RELACION_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrr.*
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACION cgrrr;
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
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_AUDITORIA @Id_GuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrr.Cod_UsuarioReg, 
               cgrr.Fecha_Reg, 
               cgrr.Cod_UsuarioAct, 
               cgrr.Fecha_Act
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
        WHERE cgrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_AUDITORIA @Id_GuiaRemisionRemitente INT, 
                                                             @Id_Detalle               INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrrd.Cod_UsuarioReg, 
               cgrrd.Fecha_Reg, 
               cgrrd.Cod_UsuarioAct, 
               cgrrd.Fecha_Act
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
        WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente
              AND cgrrd.Id_Detalle = @Id_Detalle;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TNF;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TNF @ScripWhere VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT cgrr.Cod_UsuarioReg, cgrr.Fecha_Reg, cgrr.Cod_UsuarioAct, cgrr.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr '+@ScripWhere);
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_D_TNF @ScripWhere VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT cgrrd.Cod_UsuarioReg, cgrrd.Fecha_Reg, cgrrd.Cod_UsuarioAct, cgrrd.Fecha_Act 
	FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd '+@ScripWhere);
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TXPK @IdGuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT @IdGuiaRemisionRemitente Id_GuiaRemisionRemitente, 
               cgrr.Cod_TipoComprobante, 
               vtc.Nom_TipoComprobante, 
               cgrr.Serie, 
               cgrr.Numero, 
               cgrr.Fecha_Emision, 
               cgrr.Fecha_TrasladoBienes, 
               cgrr.Fecha_EntregaBienes, 
               cgrr.Direccion_Partida, 
               vd2.Nom_Departamento Departamento_Partida, 
               vp.Nom_Provincia Provincia_Partida, 
               vd.Nom_Distrito Distrito_Partida, 
               cgrr.Direccion_LLegada, 
               vd4.Nom_Departamento Departamento_Llegada, 
               vp2.Nom_Provincia Provincia_Llegada, 
               vd3.Nom_Distrito Distrito_Llegada, 
               cgrrd.Id_Detalle, 
               cgrrd.Cod_Almacen, 
               cgrrd.Cod_UnidadMedida, 
               cgrrd.Id_Producto, 
               cgrrd.Cantidad, 
               cgrrd.Descripcion, 
               cgrrd.Peso, 
               cgrrd.Obs_Detalle, 
               cgrr.Cod_MotivoTraslado, 
               cgrr.Obs_GuiaRemisionRemitente,
               CASE
                   WHEN cgrr.Cod_MotivoTraslado = '01'
                   THEN 'VENTA'
                   WHEN cgrr.Cod_MotivoTraslado = '14'
                   THEN 'VENTA SUJETA A CONFIRMACION DEL COMPRADOR'
                   WHEN cgrr.Cod_MotivoTraslado = '02'
                   THEN 'COMPRA'
                   WHEN cgrr.Cod_MotivoTraslado = '04'
                   THEN 'TRASLADO ENTRE ESTABLECIMIENTOS DE LA MISMA EMPRESA'
                   WHEN cgrr.Cod_MotivoTraslado = '18'
                   THEN 'TRASLADO EMISOR ITINERANTE CP'
                   WHEN cgrr.Cod_MotivoTraslado = '08'
                   THEN 'IMPORTACION'
                   WHEN cgrr.Cod_MotivoTraslado = '09'
                   THEN 'EXPORTACION'
                   WHEN cgrr.Cod_MotivoTraslado = '19'
                   THEN 'TRASLADO A ZONA PRIMARIA'
                   ELSE 'OTROS'
               END Nom_MotivoTraslado, 
               cgrr.Flag_Anulado, 
               cgrr.Valor_Resumen, 
               cgrr.Valor_Firma, 
               cgrr.Id_ClienteTransportistaPublico, 
               pcp.Cliente, 
               pcp.Cod_TipoDocumento, 
               vtd.Nom_TipoDoc, 
               pcp.Nro_Documento
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd ON cgrr.Id_GuiaRemisionRemitente = cgrrd.Id_GuiaRemisionRemitente
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
             INNER JOIN dbo.VIS_DISTRITOS vd ON cgrr.Cod_UbigeoPartida = vd.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp ON vd.Cod_Departamento = vp.Cod_Departamento
                                                 AND vd.Cod_Provincia = vp.Cod_Provincia
             INNER JOIN dbo.VIS_DEPARTAMENTOS vd2 ON vd.Cod_Departamento = vd2.Cod_Departamento
             INNER JOIN dbo.VIS_DISTRITOS vd3 ON cgrr.Cod_UbigeoLlegada = vd3.Cod_Ubigeo
             INNER JOIN dbo.VIS_PROVINCIAS vp2 ON vd3.Cod_Departamento = vp2.Cod_Departamento
                                                  AND vd3.Cod_Provincia = vp2.Cod_Provincia
             INNER JOIN dbo.VIS_DEPARTAMENTOS vd4 ON vd3.Cod_Departamento = vd4.Cod_Departamento
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON cgrr.Id_ClienteDestinatario = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON pcp.Cod_TipoDocumento = vtd.Cod_TipoDoc
        WHERE cgrr.Id_GuiaRemisionRemitente = @IdGuiaRemisionRemitente;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_InformacionTransportistaPublico'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_InformacionTransportistaPublico;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_InformacionTransportistaPublico @IdGuiaRemisionRemitente INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pcp.*, 
               cgrr.Obs_Transportista
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON cgrr.Id_ClienteTransportistaPublico = pcp.Id_ClienteProveedor
        WHERE cgrr.Id_GuiaRemisionRemitente = @IdGuiaRemisionRemitente;
    END;
GO

-- USP_CAJ_COMPROBANTE_RELACION_TXIdComprobante 
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TGuiasXIdComprobante @id_ComprobantePago AS INT
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT DISTINCT 
               vtc.Cod_Sunat Cod_TipoComprobante, 
               cgrr.Serie + '-' + cgrr.Numero Comprobante
        FROM dbo.CAJ_COMPROBANTE_RELACION ccr
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE cgrr ON ccr.Id_ComprobanteRelacion = cgrr.Id_GuiaRemisionRemitente
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON cgrr.Cod_TipoComprobante = vtc.Cod_TipoComprobante
        WHERE ccr.Cod_TipoRelacion = 'GR'
              AND ccr.Id_ComprobantePago = @id_ComprobantePago;
    END;
GO

--Relleno
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_PlacasTransportistaPublico'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_PlacasTransportistaPublico;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_PlacasTransportistaPublico @IdGuiaRemisionRemitente INT
AS
     DECLARE @Placa VARCHAR(20)= 'X3U-466';
     SELECT @Placa Placa;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_GUIA_REMISION_REMITENTE_TransportistaPublico'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TransportistaPublico;
GO
CREATE PROCEDURE URP_CAJ_GUIA_REMISION_REMITENTE_TransportistaPublico @IdGuiaRemisionRemitente INT
AS
     SELECT TOP 10 pcp.Id_ClienteProveedor, 
                   pcp.Nro_Documento, 
                   pcp.Cod_TipoDocumento, 
                   vtd.Nom_TipoDoc, 
                   pcp.Cliente
     FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
          INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON pcp.Cod_TipoDocumento = vtd.Cod_TipoDoc;
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