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
        EXEC dbo.USP_PAR_TABLA_E 
             @Cod_Tabla = '128';
        EXEC dbo.USP_PAR_TABLA_G 
             @Cod_Tabla = '127', 
             @Tabla = 'ESTADOS_LETRA', 
             @Des_Tabla = 'Almacena los estados de las letras', 
             @Cod_Sistema = '001', 
             @Flag_Acceso = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '001', 
             @Columna = 'Cod_Estado', 
             @Des_Columna = 'Codigo del estado de la letra', 
             @Tipo = 'CADENA', 
             @Flag_NULL = 0, 
             @Tamano = 32, 
             @Predeterminado = '', 
             @Flag_PK = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '002', 
             @Columna = 'Des_Estado', 
             @Des_Columna = 'Descripcion del estado de la letra', 
             @Tipo = 'CADENA', 
             @Flag_NULL = 0, 
             @Tamano = 1024, 
             @Predeterminado = '', 
             @Flag_PK = 0, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_COLUMNA_G 
             @Cod_Tabla = '127', 
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
             @Cod_Tabla = '127';
END;
GO

--Creacion de la tabla
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'CAJ_LETRA_CAMBIO'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE CAJ_LETRA_CAMBIO
        (Id_Letra          INT NOT NULL IDENTITY(1, 1) PRIMARY KEY, 
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
         Fecha_Act         DATETIME
        );
END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXCodSucursalCodMoneda @Cod_Sucursal VARCHAR(32), 
                                                                    @Cod_Moneda   VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT bcb.Cod_CuentaBancaria, 
               bcb.Cod_EntidadFinanciera, 
               bcb.Des_CuentaBancaria, 
               bcb.Saldo_Disponible, 
               bcb.Cod_CuentaContable, 
               bcb.Cod_TipoCuentaBancaria
        FROM dbo.BAN_CUENTA_BANCARIA bcb
        WHERE bcb.Cod_Moneda = @Cod_Moneda
              AND bcb.Cod_Sucursal = @Cod_Sucursal;
    END;
GO
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_TraerXCodLibroCodMonedaCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_TraerXCodLibroCodMonedaCodCuenta;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_TraerXCodLibroCodMonedaCodCuenta @Cod_Libro  VARCHAR(32), 
                                                                       @Cod_Moneda VARCHAR(32), 
                                                                       @Cod_Cuenta VARCHAR(128)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               clc.*
        FROM dbo.CAJ_LETRA_CAMBIO clc
        WHERE clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Moneda = @Cod_Moneda
              AND clc.Cod_Cuenta = @Cod_Cuenta;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNumDoc_CodLibro_CodMoneda @NumeroDocumento VARCHAR(32), 
                                                                          @CodLibro        VARCHAR(4), 
                                                                          @CodMoneda       VARCHAR(5)
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
                      AND ccp.Cod_Moneda = @CodMoneda
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
                      AND ccp.Cod_Moneda = @CodMoneda
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXNomCliente_CodLibro_CodMoneda @NombreCliente VARCHAR(250), 
                                                                              @CodLibro      VARCHAR(4), 
                                                                              @CodMoneda     VARCHAR(5)
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
                      AND ccp.Cod_Moneda = @CodMoneda
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
                      AND ccp.Cod_Moneda = @CodMoneda
                ORDER BY CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) DESC;
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_G;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_G @Id_Letra          INT, --PK 0 si no se sabe
                                        @Nro_Letra         VARCHAR(128), --PK  opcional, si es '' o NULL se genera uno nuevo
                                        @Cod_Libro         VARCHAR(32), --PK Obligatorio
                                        @Ref_Girador       VARCHAR(1024), 
                                        @Fecha_Girado      DATETIME, 
                                        @Fecha_Vencimiento DATETIME, 
                                        @Fecha_Pago        DATETIME, 
                                        @Cod_Cuenta        VARCHAR(128), --PK Obligatorio
                                        @Nro_Operacion     VARCHAR(128), 
                                        @Cod_Moneda        VARCHAR(32), --PK Obligatorio
                                        @Id_Comprobante    INT, 
                                        @Cod_Estado        VARCHAR(64), 
                                        @Nro_Referencia    VARCHAR(128), 
                                        @Monto_Base        NUMERIC(38, 2), 
                                        @Monto_Real        NUMERIC(38, 2), 
                                        @Observaciones     VARCHAR(1024), 
                                        @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Id_Letra = 0
            BEGIN
                IF @Nro_Letra = ''
                   OR @Nro_Letra IS NULL
                    BEGIN
                        --Obtenemos la letra en base a la moneda,libro y cuenta
                        SET @Nro_Letra =
                        (
                            SELECT CAST((ISNULL(MAX(CAST(vlc.Nro_Letra AS BIGINT)), 0) + 1) AS VARCHAR(128))
                            FROM dbo.VIS_LETRAS_CAMBIO vlc
                            WHERE vlc.Cod_Moneda = @Cod_Moneda
                                  AND vlc.Cod_Libro = @Cod_Libro
                                  AND vlc.Cod_Cuenta = @Cod_Cuenta
                        );
                        INSERT INTO dbo.CAJ_LETRA_CAMBIO
                        VALUES
                        (@Nro_Letra, -- Nro_Letra - VARCHAR
                         @Cod_Libro, -- Cod_Libro - VARCHAR
                         @Ref_Girador, -- Ref_Girador - VARCHAR
                         @Fecha_Girado, -- Fecha_Girado - DATETIME
                         @Fecha_Vencimiento, -- Fecha_Vencimiento - DATETIME
                         @Fecha_Pago, -- Fecha_Pago - DATETIME
                         @Cod_Cuenta, -- Cod_Cuenta - VARCHAR
                         @Nro_Operacion, -- Nro_Operacion - VARCHAR
                         @Cod_Moneda, -- Cod_Moneda - VARCHAR
                         @Id_Comprobante, -- Id_Comprobante - INT
                         @Cod_Estado, -- Cod_Estado - VARCHAR
                         @Nro_Referencia, -- Nro_Referencia - VARCHAR
                         @Monto_Base, -- Monto_Base - NUMERIC
                         @Monto_Real, -- Monto_Real - NUMERIC
                         @Observaciones, -- Observaciones - VARCHAR
                         @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                         GETDATE(), -- Fecha_Reg - DATETIME
                         NULL, -- Cod_UsuarioAct - VARCHAR
                         NULL -- Fecha_Act - DATETIME
                        );
                END;
                    ELSE
                    BEGIN
                        --Puede ser que se dee guardar o actualizar
                        IF NOT EXISTS
                        (
                            SELECT clc.*
                            FROM dbo.CAJ_LETRA_CAMBIO clc
                            WHERE clc.Nro_Letra = @Nro_Letra
                                  AND clc.Cod_Libro = @Cod_Libro
                                  AND clc.Cod_Cuenta = @Cod_Cuenta
                                  AND clc.Cod_Moneda = @Cod_Moneda
                        )
                            BEGIN
                                INSERT INTO dbo.CAJ_LETRA_CAMBIO
                                VALUES
                                (@Nro_Letra, -- Nro_Letra - VARCHAR
                                 @Cod_Libro, -- Cod_Libro - VARCHAR
                                 @Ref_Girador, -- Ref_Girador - VARCHAR
                                 @Fecha_Girado, -- Fecha_Girado - DATETIME
                                 @Fecha_Vencimiento, -- Fecha_Vencimiento - DATETIME
                                 @Fecha_Pago, -- Fecha_Pago - DATETIME
                                 @Cod_Cuenta, -- Cod_Cuenta - VARCHAR
                                 @Nro_Operacion, -- Nro_Operacion - VARCHAR
                                 @Cod_Moneda, -- Cod_Moneda - VARCHAR
                                 @Id_Comprobante, -- Id_Comprobante - INT
                                 @Cod_Estado, -- Cod_Estado - VARCHAR
                                 @Nro_Referencia, -- Nro_Referencia - VARCHAR
                                 @Monto_Base, -- Monto_Base - NUMERIC
                                 @Monto_Real, -- Monto_Real - NUMERIC
                                 @Observaciones, -- Observaciones - VARCHAR
                                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                                 GETDATE(), -- Fecha_Reg - DATETIME
                                 NULL, -- Cod_UsuarioAct - VARCHAR
                                 NULL -- Fecha_Act - DATETIME
                                );
                        END;
                            ELSE
                            BEGIN
                                --Actualizamos
                                UPDATE dbo.CAJ_LETRA_CAMBIO
                                  SET
                                --Id_Letra - column value is auto-generated
                                      dbo.CAJ_LETRA_CAMBIO.Ref_Girador = @Ref_Girador, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Fecha_Girado = @Fecha_Girado, -- DATETIME
                                      dbo.CAJ_LETRA_CAMBIO.Fecha_Vencimiento = @Fecha_Vencimiento, -- DATETIME
                                      dbo.CAJ_LETRA_CAMBIO.Fecha_Pago = @Fecha_Pago, -- DATETIME
                                      dbo.CAJ_LETRA_CAMBIO.Nro_Operacion = @Nro_Operacion, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Id_Comprobante = @Id_Comprobante, -- INT
                                      dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @Cod_Estado, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Nro_Referencia = @Nro_Referencia, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Monto_Base = @Monto_Base, -- NUMERIC
                                      dbo.CAJ_LETRA_CAMBIO.Monto_Real = @Monto_Real, -- NUMERIC
                                      dbo.CAJ_LETRA_CAMBIO.Observaciones = @Observaciones, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                                      dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE() -- DATETIME
                                WHERE dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda;
                        END;
                END;
        END;
            ELSE
            BEGIN
                IF NOT EXISTS
                (
                    SELECT clc.*
                    FROM dbo.CAJ_LETRA_CAMBIO clc
                    WHERE clc.Id_Letra = @Id_Letra
                )
                    BEGIN
                        --Actualizamos
                        UPDATE dbo.CAJ_LETRA_CAMBIO
                          SET
                        --Id_Letra - column value is auto-generated
                              dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Ref_Girador = @Ref_Girador, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Fecha_Girado = @Fecha_Girado, -- DATETIME
                              dbo.CAJ_LETRA_CAMBIO.Fecha_Vencimiento = @Fecha_Vencimiento, -- DATETIME
                              dbo.CAJ_LETRA_CAMBIO.Fecha_Pago = @Fecha_Pago, -- DATETIME
                              dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Nro_Operacion = @Nro_Operacion, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Id_Comprobante = @Id_Comprobante, -- INT
                              dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @Cod_Estado, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Nro_Referencia = @Nro_Referencia, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Monto_Base = @Monto_Base, -- NUMERIC
                              dbo.CAJ_LETRA_CAMBIO.Monto_Real = @Monto_Real, -- NUMERIC
                              dbo.CAJ_LETRA_CAMBIO.Observaciones = @Observaciones, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                              dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE() -- DATETIME
                        WHERE dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra;
                END;
                    ELSE
                    BEGIN
                        --Insertamos
                        INSERT INTO dbo.CAJ_LETRA_CAMBIO
                        VALUES
                        (@Nro_Letra, -- Nro_Letra - VARCHAR
                         @Cod_Libro, -- Cod_Libro - VARCHAR
                         @Ref_Girador, -- Ref_Girador - VARCHAR
                         @Fecha_Girado, -- Fecha_Girado - DATETIME
                         @Fecha_Vencimiento, -- Fecha_Vencimiento - DATETIME
                         @Fecha_Pago, -- Fecha_Pago - DATETIME
                         @Cod_Cuenta, -- Cod_Cuenta - VARCHAR
                         @Nro_Operacion, -- Nro_Operacion - VARCHAR
                         @Cod_Moneda, -- Cod_Moneda - VARCHAR
                         @Id_Comprobante, -- Id_Comprobante - INT
                         @Cod_Estado, -- Cod_Estado - VARCHAR
                         @Nro_Referencia, -- Nro_Referencia - VARCHAR
                         @Monto_Base, -- Monto_Base - NUMERIC
                         @Monto_Real, -- Monto_Real - NUMERIC
                         @Observaciones, -- Observaciones - VARCHAR
                         @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                         GETDATE(), -- Fecha_Reg - DATETIME
                         NULL, -- Cod_UsuarioAct - VARCHAR
                         NULL -- Fecha_Act - DATETIME
                        );
                END;
        END;
    END;