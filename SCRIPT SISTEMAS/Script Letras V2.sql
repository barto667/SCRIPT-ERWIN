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
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '001', 
             @Cod_Fila = 1, 
             @Cadena = N'001', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '002', 
             @Cod_Fila = 1, 
             @Cadena = N'EMITIDO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
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
             @Cod_Tabla = '127', 
             @Cod_Columna = '001', 
             @Cod_Fila = 2, 
             @Cadena = N'002', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '002', 
             @Cod_Fila = 2, 
             @Cadena = N'PAGADO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
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
             @Cod_Tabla = '127', 
             @Cod_Columna = '001', 
             @Cod_Fila = 3, 
             @Cadena = N'003', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '002', 
             @Cod_Fila = 3, 
             @Cadena = N'PROTESTO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
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
             @Cod_Tabla = '127', 
             @Cod_Columna = '001', 
             @Cod_Fila = 4, 
             @Cadena = N'004', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '002', 
             @Cod_Fila = 4, 
             @Cadena = N'ANULADO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 0, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '127', 
             @Cod_Columna = '003', 
             @Cod_Fila = 4, 
             @Cadena = NULL, 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 1, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
END;
GO

--Creamos las tabla letras
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'CAJ_LETRA_CAMBIO'
          AND type = 'U'
)
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

--Traer cuentas bancarias
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

--Obtener letras por libro,moneda y cuenta
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
               clc.Id, 
               clc.Id_Letra, 
               CAST(clc.Nro_Letra AS BIGINT) AS Nro_Letra, 
               clc.Cod_Libro, 
               clc.Ref_Girador, 
               clc.Fecha_Girado, 
               clc.Fecha_Vencimiento, 
               clc.Fecha_Pago, 
               clc.Cod_Cuenta, 
               clc.Nro_Operacion, 
               clc.Cod_Moneda, 
               clc.Id_Comprobante, 
               clc.Cod_Estado, 
               clc.Nro_Referencia, 
               clc.Monto_Base, 
               clc.Monto_Real, 
               clc.Observaciones, 
               clc.Cod_UsuarioReg, 
               clc.Fecha_Reg, 
               clc.Cod_UsuarioAct, 
               clc.Fecha_Act
        FROM dbo.CAJ_LETRA_CAMBIO clc
        WHERE clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Moneda = @Cod_Moneda
              AND clc.Cod_Cuenta = @Cod_Cuenta
        ORDER BY clc.Id_Letra, 
                 CAST(clc.Nro_Letra AS BIGINT);
    END;
GO

--Obtener letras por id_letra,libro,moneda y cuenta
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_TraerXIdLetraCodLibroCodMonedaCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_TraerXIdLetraCodLibroCodMonedaCodCuenta;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_TraerXIdLetraCodLibroCodMonedaCodCuenta @Id_letra   INT, 
                                                                              @Cod_Libro  VARCHAR(32), 
                                                                              @Cod_Moneda VARCHAR(32), 
                                                                              @Cod_Cuenta VARCHAR(128)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               clc.*
        FROM dbo.CAJ_LETRA_CAMBIO clc
        WHERE clc.Id_Letra = @Id_Letra
              AND clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Moneda = @Cod_Moneda
              AND clc.Cod_Cuenta = @Cod_Cuenta;
    END;
GO

--Traer comprobantes por nuemro de docuemnto, libro y moneda
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

--Traer comprobantes por nombre de cliente, libro y moneda
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

--Guardar 
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_G;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_G @Id                INT, 
                                        @Id_Letra          INT, --PK 0 si no se sabe
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
                SET @Id_Letra = ISNULL(
                (
                    SELECT MAX(clc.Id_Letra)
                    FROM dbo.CAJ_LETRA_CAMBIO clc
                ), 0) + 1;
                IF @Nro_Letra = ''
                   OR @Nro_Letra IS NULL
                    BEGIN
                        --Obtenemos la letra en base a la moneda,libro y cuenta
                        SET @Nro_Letra =
                        (
                            SELECT CAST((ISNULL(MAX(CAST(clc.Nro_Letra AS BIGINT)), 0) + 1) AS VARCHAR(128))
                            FROM dbo.CAJ_LETRA_CAMBIO clc
                            WHERE clc.Cod_Moneda = @Cod_Moneda
                                  AND clc.Cod_Libro = @Cod_Libro
                                  AND clc.Cod_Cuenta = @Cod_Cuenta
                        );
                        INSERT INTO dbo.CAJ_LETRA_CAMBIO
                        VALUES
                        (@Id_Letra, --Id_Letra - int
                         @Nro_Letra, -- Nro_Letra - VARCHAR
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
                        SET @Id = @@IDENTITY;
                END;
                    ELSE
                    BEGIN
                        --Puede ser que se dee guardar o actualizar
                        IF NOT EXISTS
                        (
                            SELECT clc.*
                            FROM dbo.CAJ_LETRA_CAMBIO clc
                            WHERE clc.Id_Letra = @Id_Letra
                                  AND clc.Nro_Letra = @Nro_Letra
                                  AND clc.Cod_Libro = @Cod_Libro
                                  AND clc.Cod_Cuenta = @Cod_Cuenta
                                  AND clc.Cod_Moneda = @Cod_Moneda
                        )
                            BEGIN
                                INSERT INTO dbo.CAJ_LETRA_CAMBIO
                                VALUES
                                (@Id_Letra, --Id_Letra - int
                                 @Nro_Letra, -- Nro_Letra - VARCHAR
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
                                SET @Id = @@IDENTITY;
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
                                WHERE dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra
                                      AND dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda;
                                SET @Id =
                                (
                                    SELECT clc.Id
                                    FROM dbo.CAJ_LETRA_CAMBIO clc
                                    WHERE clc.Id_Letra = @Id_Letra
                                          AND clc.Nro_Letra = @Nro_Letra
                                          AND clc.Cod_Libro = @Cod_Libro
                                          AND clc.Cod_Cuenta = @Cod_Cuenta
                                          AND clc.Cod_Moneda = @Cod_Moneda
                                );
                        END;
                END;
        END;
            ELSE
            BEGIN
                IF @Nro_Letra = ''
                   OR @Nro_Letra IS NULL
                    BEGIN
                        --Se le genera una letra
                        SET @Nro_Letra =
                        (
                            SELECT CAST((ISNULL(MAX(CAST(clc.Nro_Letra AS BIGINT)), 0) + 1) AS VARCHAR(128))
                            FROM dbo.CAJ_LETRA_CAMBIO clc
                            WHERE clc.Id_Letra = @Id_Letra
                                  AND clc.Cod_Moneda = @Cod_Moneda
                                  AND clc.Cod_Libro = @Cod_Libro
                                  AND clc.Cod_Cuenta = @Cod_Cuenta
                        );
                        INSERT INTO dbo.CAJ_LETRA_CAMBIO
                        VALUES
                        (@Id_Letra, --Id_Letra - int
                         @Nro_Letra, -- Nro_Letra - VARCHAR
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
                        SET @Id = @@IDENTITY;
                END;
                    ELSE
                    BEGIN
                        --Puede ser que se dee guardar o actualizar
                        IF NOT EXISTS
                        (
                            SELECT clc.*
                            FROM dbo.CAJ_LETRA_CAMBIO clc
                            WHERE clc.Id_Letra = @Id_Letra
                                  AND clc.Nro_Letra = @Nro_Letra
                                  AND clc.Cod_Libro = @Cod_Libro
                                  AND clc.Cod_Cuenta = @Cod_Cuenta
                                  AND clc.Cod_Moneda = @Cod_Moneda
                        )
                            BEGIN
                                INSERT INTO dbo.CAJ_LETRA_CAMBIO
                                VALUES
                                (@Id_Letra, --Id_Letra - int
                                 @Nro_Letra, -- Nro_Letra - VARCHAR
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
                                SET @Id = @@IDENTITY;
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
                                WHERE dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra
                                      AND dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_Letra
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta
                                      AND dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda;
                                SET @Id =
                                (
                                    SELECT clc.Id
                                    FROM dbo.CAJ_LETRA_CAMBIO clc
                                    WHERE clc.Id_Letra = @Id_Letra
                                          AND clc.Nro_Letra = @Nro_Letra
                                          AND clc.Cod_Libro = @Cod_Libro
                                          AND clc.Cod_Cuenta = @Cod_Cuenta
                                          AND clc.Cod_Moneda = @Cod_Moneda
                                );
                        END;
                END;
        END;
        SELECT @Id Id, 
               @Id_Letra Id_Letra, 
               @Nro_Letra Nro_Letra, 
               @Cod_Libro Cod_Libro, 
               @Ref_Girador Ref_Girador, 
               @Fecha_Girado Fecha_Girado, 
               @Fecha_Vencimiento Fecha_Vencimiento, 
               @Fecha_Pago Fecha_Pago, 
               @Cod_Cuenta Cod_Cuenta, 
               @Nro_Operacion Nro_Operacion, 
               @Cod_Moneda Cod_Moneda, 
               @Id_Comprobante Id_Comprobante, 
               @Cod_Estado Cod_Estado, 
               @Nro_Referencia Nro_Referencia, 
               @Monto_Base Monto_Base, 
               @Monto_Real Monto_Real, 
               @Observaciones Observaciones, 
               @Cod_Usuario Cod_Usuario;
    END;
GO

--Obtiene las letras por id_letra
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta;
GO
CREATE PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraCodMonedaCodLibroCodCuenta @Id_Letra INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT clc.Id_Letra, 
               clc.Nro_Letra, 
               clc.Cod_Libro, 
               clc.Ref_Girador, 
               clc.Fecha_Girado, 
               clc.Fecha_Vencimiento, 
               clc.Fecha_Pago, 
               clc.Cod_Cuenta, 
               bcb.Des_CuentaBancaria, 
               clc.Nro_Operacion, 
               clc.Cod_Moneda, 
               vm.Nom_Moneda, 
               clc.Id_Comprobante, 
               clc.Cod_Estado, 
               clc.Nro_Referencia, 
               clc.Monto_Base, 
               clc.Monto_Real, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Base) Letra_MontoBase, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Real) Letra_MontoReal, 
               clc.Observaciones
        FROM dbo.CAJ_LETRA_CAMBIO clc
             INNER JOIN dbo.VIS_MONEDAS vm ON clc.Cod_Moneda = vm.Cod_Moneda
             INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON vm.Cod_Moneda = bcb.Cod_Moneda
        WHERE clc.Id_Letra = @Id_Letra;
    END;
GO
--
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_E;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_E @Id_Letra   INT, --PK 0 si no se sabe
                                        @Nro_Letra  VARCHAR(128), --PK  opcional, si es '' o NULL se genera uno nuevo
                                        @Cod_Libro  VARCHAR(32), --PK Obligatorio
                                        @Cod_Cuenta VARCHAR(128) OUTPUT, --PK Obligatorio
                                        @Cod_Moneda VARCHAR(32) OUTPUT --PK Obligatorio
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.CAJ_LETRA_CAMBIO
        WHERE dbo.CAJ_LETRA_CAMBIO.Id_Letra = @Id_Letra
              AND dbo.CAJ_LETRA_CAMBIO.Nro_Letra = @Nro_letra
              AND dbo.CAJ_LETRA_CAMBIO.Cod_Libro = @Cod_Libro
              AND dbo.CAJ_LETRA_CAMBIO.Cod_Cuenta = @Cod_Cuenta
              AND dbo.CAJ_LETRA_CAMBIO.Cod_Moneda = @Cod_Moneda;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_TXPK;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_TXPK @Id_Letra   INT, --PK 0 si no se sabe
                                           @Nro_Letra  VARCHAR(128), --PK  opcional, si es '' o NULL se genera uno nuevo
                                           @Cod_Libro  VARCHAR(32), --PK Obligatorio
                                           @Cod_Cuenta VARCHAR(128) OUTPUT, --PK Obligatorio
                                           @Cod_Moneda VARCHAR(32) OUTPUT --PK Obligatorio
WITH ENCRYPTION
AS
    BEGIN
        SELECT clc.*
        FROM dbo.CAJ_LETRA_CAMBIO clc
        WHERE clc.Id_Letra = @Id_Letra
              AND clc.Nro_Letra = @Nro_Letra
              AND clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Cuenta = @Cod_Cuenta
              AND clc.Cod_Moneda = @Cod_Moneda;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta;
GO
CREATE PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXIdLetraNroLetraCodMonedaCodLibroCodCuenta @Id_Letra   INT, 
                                                                                            @Nro_Letra  VARCHAR(128), 
                                                                                            @Cod_Moneda VARCHAR(32), 
                                                                                            @Cod_Libro  VARCHAR(32), 
                                                                                            @Cod_Cuenta VARCHAR(128)
WITH ENCRYPTION
AS
    BEGIN
        SELECT clc.Id_Letra, 
               clc.Nro_Letra, 
               clc.Cod_Libro, 
               clc.Ref_Girador, 
               clc.Fecha_Girado, 
               clc.Fecha_Vencimiento, 
               clc.Fecha_Pago, 
               clc.Cod_Cuenta, 
               bcb.Des_CuentaBancaria, 
               clc.Nro_Operacion, 
               clc.Cod_Moneda, 
               vm.Nom_Moneda, 
               clc.Id_Comprobante, 
               clc.Cod_Estado, 
               clc.Nro_Referencia, 
               clc.Monto_Base, 
               clc.Monto_Real, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Base) Letra_MontoBase, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Real) Letra_MontoReal, 
               clc.Observaciones, 
               pcp.Cliente, 
               ccp.Direccion_Cliente, 
               pcp.Nro_Documento, 
               pcp.Telefono1, 
               pcp.Telefono2
        FROM dbo.CAJ_LETRA_CAMBIO clc
             INNER JOIN dbo.VIS_MONEDAS vm ON clc.Cod_Moneda = vm.Cod_Moneda
             INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON bcb.Cod_CuentaBancaria = clc.Cod_Cuenta
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON clc.Id_Comprobante = ccp.id_ComprobantePago
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
        WHERE clc.Id_Letra = @Id_Letra
              AND clc.Nro_Letra = @Nro_Letra
              AND clc.Cod_Moneda = @Cod_Moneda
              AND clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Cuenta = @Cod_Cuenta;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_LETRA_CAMBIO_TraerLetrasXCodMonedaCodLibroCodCuenta'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXCodMonedaCodLibroCodCuenta;
GO
CREATE PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetrasXCodMonedaCodLibroCodCuenta @Cod_Moneda VARCHAR(32), 
                                                                             @Cod_Libro  VARCHAR(32), 
                                                                             @Cod_Cuenta VARCHAR(128)
WITH ENCRYPTION
AS
    BEGIN
        SELECT clc.Id_Letra, 
               clc.Nro_Letra, 
               clc.Cod_Libro, 
               clc.Ref_Girador, 
               clc.Fecha_Girado, 
               clc.Fecha_Vencimiento, 
               clc.Fecha_Pago, 
               clc.Cod_Cuenta, 
               bcb.Des_CuentaBancaria, 
               clc.Nro_Operacion, 
               clc.Cod_Moneda, 
               vm.Nom_Moneda, 
               clc.Id_Comprobante, 
               clc.Cod_Estado, 
               clc.Nro_Referencia, 
               clc.Monto_Base, 
               clc.Monto_Real, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Base) Letra_MontoBase, 
               dbo.UFN_ConvertirNumeroLetra(clc.Monto_Real) Letra_MontoReal, 
               clc.Observaciones
        FROM dbo.CAJ_LETRA_CAMBIO clc
             INNER JOIN dbo.VIS_MONEDAS vm ON clc.Cod_Moneda = vm.Cod_Moneda
             INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON bcb.Cod_CuentaBancaria = clc.Cod_Cuenta
        WHERE clc.Cod_Moneda = @Cod_Moneda
              AND clc.Cod_Libro = @Cod_Libro
              AND clc.Cod_Cuenta = @Cod_Cuenta;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_GuardarRelacion'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_GuardarRelacion;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_GuardarRelacion @Id_Comprobante INT, 
                                                      @Item           INT, 
                                                      @Id_Referencia  INT, 
                                                      @Valor          NUMERIC(38, 6), 
                                                      @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Id_Detalle INT=
        (
            SELECT TOP 1 ccd.id_Detalle
            FROM dbo.CAJ_COMPROBANTE_D ccd
            WHERE ccd.id_ComprobantePago = @Id_Comprobante
        );
        IF(@Item = 0)
            BEGIN
                SET @Item =
                (
                    SELECT ISNULL(MAX(Item), 0) + 1
                    FROM CAJ_COMPROBANTE_RELACION
                    WHERE id_ComprobantePago = @Id_Comprobante
                          AND id_Detalle = @Id_Detalle
                );
        END;
        INSERT INTO dbo.CAJ_COMPROBANTE_RELACION
        VALUES
        (@Id_Comprobante, -- id_ComprobantePago - int
         @Id_Detalle, -- id_Detalle - int
         @Item, -- Item - int
         @Id_Referencia, -- Id_ComprobanteRelacion - int
         'LET', -- Cod_TipoRelacion - varchar
         @Valor, -- Valor - numeric
         '', -- Obs_Relacion - varchar
         1, -- Id_DetalleRelacion - int
         @Cod_Usuario, -- Cod_UsuarioReg - varchar
         GETDATE(), -- Fecha_Reg - datetime
         NULL, -- Cod_UsuarioAct - varchar
         NULL -- Fecha_Act - datetime
        );
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_GuardarFormaPago'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_GuardarFormaPago;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_GuardarFormaPago @Id_Comprobante INT, 
                                                       @Cod_Cuenta     VARCHAR(128), 
                                                       @Id_Referencia  INT, 
                                                       @Cod_Moneda     VARCHAR(5), 
                                                       @Monto          NUMERIC(38, 2), 
                                                       @Cod_Caja       VARCHAR(5), 
                                                       @Cod_Turno      VARCHAR(32), 
                                                       @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Item INT=
        (
            SELECT ISNULL(MAX(cfp.Item), 0) + 1
            FROM dbo.CAJ_FORMA_PAGO cfp
            WHERE cfp.id_ComprobantePago = @Id_Comprobante
        );
        INSERT INTO dbo.CAJ_FORMA_PAGO
        VALUES
        (@Id_Comprobante, -- id_ComprobantePago - int
         @Item, -- Item - int
         'LETRA DE CAMBIO', -- Des_FormaPago - varchar
         '001', -- Cod_TipoFormaPago - varchar
         @Cod_Cuenta, -- Cuenta_CajaBanco - varchar
         @Id_Referencia, -- Id_Movimiento - int
         1, -- TipoCambio - numeric
         @Cod_Moneda, -- Cod_Moneda - varchar
         @Monto, -- Monto - numeric
         @Cod_Caja, -- Cod_Caja - varchar
         @Cod_Turno, -- Cod_Turno - varchar
         '', -- Cod_Plantilla - varchar
         NULL, -- Obs_FormaPago - xml
         GETDATE(), -- Fecha - datetime
         @Cod_Usuario, -- Cod_UsuarioReg - varchar
         GETDATE(), -- Fecha_Reg - datetime
         NULL, -- Cod_UsuarioAct - varchar
         NULL -- Fecha_Act - datetime
        );
    END;
GO
--Metodo que trae las letras usando los filtros requeridos
--  EXEC dbo.URP_CAJ_LETRA_CAMBIO_TraerLetraXCodMonedaCodCuentaIdClienteFechasCodEstadoCodLibro
-- 	@CodMoneda = NULL,
-- 	@CodCuenta = NULL,
-- 	@IdCliente = NULL,
-- 	@FechaInicio = NULL,
-- 	@FechaFin = NULL,
-- 	@CodEstado = NULL,
-- 	@CodLibro = NULL 

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_LETRA_CAMBIO_TraerLetraXCodMonedaCodCuentaIdClienteFechasCodEstadoCodLibro'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetraXCodMonedaCodCuentaIdClienteFechasCodEstadoCodLibro;
GO
CREATE PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetraXCodMonedaCodCuentaIdClienteFechasCodEstadoCodLibro @CodMoneda   VARCHAR(5)   = NULL, 
                                                                                                    @CodCuenta   VARCHAR(128) = NULL, 
                                                                                                    @IdCliente   INT          = NULL, 
                                                                                                    @FechaInicio DATETIME     = NULL, 
                                                                                                    @FechaFin    DATETIME     = NULL, 
                                                                                                    @CodEstado   VARCHAR(10)  = NULL, 
                                                                                                    @CodLibro    VARCHAR(10)  = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               clc.Id, 
               clc.Id_Letra, 
               CAST(clc.Nro_Letra AS BIGINT) Nro_Letra, 
               clc.Cod_Libro, 
               clc.Ref_Girador, 
               clc.Fecha_Girado, 
               clc.Fecha_Vencimiento,
               CASE
                   WHEN clc.Cod_Estado = '001'
                   THEN DATEDIFF(dd, GETDATE(), clc.Fecha_Vencimiento)
                   ELSE 0
               END Diferencia, 
               clc.Fecha_Pago,
               CASE
                   WHEN clc.Cod_Estado = '001'
                   THEN clc.Monto_Base
                   ELSE 0
               END Monto_Base, 
               clc.Cod_Cuenta, 
               bcb.Des_CuentaBancaria, 
               clc.Nro_Operacion, 
               clc.Cod_Moneda, 
               vm.Nom_Moneda, 
               clc.Id_Comprobante, 
               clc.Cod_Estado, 
               vel.Des_Estado, 
               clc.Nro_Referencia, 
               clc.Monto_Base, 
               clc.Monto_Real, 
               clc.Observaciones, 
               ccp.Id_Cliente, 
               vtd.Nom_TipoDoc, 
               ccp.Cod_TipoDoc, 
               ccp.Doc_Cliente, 
               ccp.Nom_Cliente, 
               ccp.Cod_TipoComprobante, 
               vtc.Nom_TipoComprobante, 
               ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero SerieNumero
        FROM dbo.CAJ_LETRA_CAMBIO clc
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago = clc.Id_Comprobante
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
             INNER JOIN dbo.VIS_MONEDAS vm ON clc.Cod_Moneda = vm.Cod_Moneda
             INNER JOIN dbo.VIS_ESTADOS_LETRA vel ON clc.Cod_Estado = vel.Cod_Estado
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON clc.Cod_Cuenta = bcb.Cod_CuentaBancaria
        WHERE(@CodMoneda IS NULL
              OR clc.Cod_Moneda = @CodMoneda)
             AND (@CodCuenta IS NULL
                  OR clc.Cod_Cuenta = @CodCuenta)
             AND (@IdCliente IS NULL
                  OR ccp.Id_Cliente = @IdCliente)
             AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), clc.Fecha_Girado, 103)) BETWEEN CONVERT(DATETIME, @FechaInicio) AND CONVERT(DATETIME, @FechaFin)
                  OR @FechaInicio IS NULL)
             AND (@CodEstado IS NULL
                  OR clc.Cod_Estado = @CodEstado)
             AND (@CodLibro IS NULL
                  OR clc.Cod_Libro = @CodLibro)
        ORDER BY clc.Id_Letra, 
                 CAST(clc.Nro_Letra AS BIGINT), 
                 clc.Fecha_Girado;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_ModificarMontoRealFechaPagoEstadoXId'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_ModificarMontoRealFechaPagoEstadoXId;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_ModificarMontoRealFechaPagoEstadoXId @Id         INT, 
                                                                           @MontoReal  NUMERIC(38, 3), 
                                                                           @FechaPago  DATETIME, 
                                                                           @CodEstado  VARCHAR(5), 
                                                                           @CodUsuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        UPDATE dbo.CAJ_LETRA_CAMBIO
          SET 
              dbo.CAJ_LETRA_CAMBIO.Monto_Real = @MontoReal, 
              dbo.CAJ_LETRA_CAMBIO.Fecha_Pago = @FechaPago, 
              dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @CodEstado, 
              dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @CodUsuario, 
              dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE()
        WHERE dbo.CAJ_LETRA_CAMBIO.Id = @Id;
    END;
	GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_ModificarEstadoXId'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_ModificarEstadoXId;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_ModificarEstadoXId @Id            INT, 
                                                         @CodEstado     VARCHAR(5), 
                                                         @Justificacion VARCHAR(250), 
                                                         @CodUsuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Documento VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Libro, '-', clc.Nro_Letra)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @Proveedor VARCHAR(MAX)=
        (
            SELECT CONCAT(ccp.Cod_TipoDoc, ':', ccp.Doc_Cliente, '-', ccp.Nom_Cliente)
            FROM dbo.CAJ_LETRA_CAMBIO clc
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON clc.Id_Comprobante = ccp.id_ComprobantePago
            WHERE clc.Id = @Id
        );
        DECLARE @Detalle VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Estado, '|', clc.Monto_Base, '|', clc.Monto_Real)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @FechaEmision DATETIME=
        (
            SELECT clc.Fecha_Reg
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        UPDATE dbo.CAJ_LETRA_CAMBIO
          SET 
              dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @CodEstado, 
              dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @CodUsuario, 
              dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE()
        WHERE dbo.CAJ_LETRA_CAMBIO.Id = @Id;

        --Editamos la forma de pago en 0
        UPDATE cfp
          SET 
              cfp.Monto = 0
        FROM dbo.CAJ_FORMA_PAGO cfp
             INNER JOIN dbo.CAJ_LETRA_CAMBIO clc ON cfp.id_ComprobantePago = clc.Id_Comprobante
        WHERE clc.Id = @Id;

        --Guardamos la jsutificacion

        DECLARE @FechaActual DATETIME= GETDATE();
        DECLARE @id_Fila INT=
        (
            SELECT ISNULL(COUNT(*) / 9, 1) + 1
            FROM PAR_FILA
            WHERE Cod_Tabla = '079'
        );
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
             'CAJ_LETRA_CAMBIO', 
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
             @Proveedor, 
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
             @Detalle, 
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
             @FechaEmision, 
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
             @FechaActual, 
             NULL, 
             1, 
             'MIGRACION';
        EXEC USP_PAR_FILA_G 
             '079', 
             '007', 
             @id_Fila, 
             @CodUsuario, 
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
GO


IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_AnularLetra'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_AnularLetra;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_AnularLetra @Id            INT, 
                                                  @Cod_Estado    VARCHAR(32), 
                                                  @Justificacion VARCHAR(MAX), 
                                                  @Cod_Usuario   VARCHAR(32)
AS
    BEGIN
        --Variables de justificacion
        DECLARE @Documento VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Libro, '-', clc.Nro_Letra)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @Proveedor VARCHAR(MAX)=
        (
            SELECT CONCAT(ccp.Cod_TipoDoc, ':', ccp.Doc_Cliente, '-', ccp.Nom_Cliente)
            FROM dbo.CAJ_LETRA_CAMBIO clc
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON clc.Id_Comprobante = ccp.id_ComprobantePago
            WHERE clc.Id = @Id
        );
        DECLARE @Detalle VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Estado, '|', clc.Monto_Base, '|', clc.Monto_Real)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @FechaEmision DATETIME=
        (
            SELECT clc.Fecha_Reg
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );

        --Cambiamos el estado de la letra, montos = 0
        UPDATE dbo.CAJ_LETRA_CAMBIO
          SET 
              dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @Cod_Estado, -- varchar
              dbo.CAJ_LETRA_CAMBIO.Monto_Base = 0, -- numeric
              dbo.CAJ_LETRA_CAMBIO.Monto_Real = 0, -- numeric
              dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @Cod_Usuario, -- varchar
              dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE() -- datetime
        WHERE dbo.CAJ_LETRA_CAMBIO.Id = @Id;
        --Eliminamos las formas de pago relacionadas
        DELETE dbo.CAJ_FORMA_PAGO
        WHERE dbo.CAJ_FORMA_PAGO.Id_Movimiento = @Id
              AND dbo.CAJ_FORMA_PAGO.Cod_TipoFormaPago = '001';
        --Eliminamos las relaciones
        DELETE dbo.CAJ_COMPROBANTE_RELACION
        WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = (SELECT clc.Id_Letra FROM dbo.CAJ_LETRA_CAMBIO clc WHERE clc.Id=@Id)
              AND dbo.CAJ_COMPROBANTE_RELACION.Cod_TipoRelacion = 'LET';

        --Guardamos la jsutificacion

        DECLARE @FechaActual DATETIME= GETDATE();
        DECLARE @id_Fila INT=
        (
            SELECT ISNULL(COUNT(*) / 9, 1) + 1
            FROM PAR_FILA
            WHERE Cod_Tabla = '079'
        );
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
             'CAJ_LETRA_CAMBIO', 
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
             @Proveedor, 
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
             @Detalle, 
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
             @FechaEmision, 
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
             @FechaActual, 
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
GO


IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_LETRA_CAMBIO_ProtestarLetra'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LETRA_CAMBIO_ProtestarLetra;
GO
CREATE PROCEDURE USP_CAJ_LETRA_CAMBIO_ProtestarLetra @Id            INT, 
                                                     @Cod_Estado    VARCHAR(32), 
                                                     @Monto         NUMERIC(32, 3), 
                                                     @Justificacion VARCHAR(MAX), 
                                                     @Cod_Usuario   VARCHAR(32)
AS
    BEGIN
        --Variables de justificacion
        DECLARE @Documento VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Libro, '-', clc.Nro_Letra)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @Proveedor VARCHAR(MAX)=
        (
            SELECT CONCAT(ccp.Cod_TipoDoc, ':', ccp.Doc_Cliente, '-', ccp.Nom_Cliente)
            FROM dbo.CAJ_LETRA_CAMBIO clc
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON clc.Id_Comprobante = ccp.id_ComprobantePago
            WHERE clc.Id = @Id
        );
        DECLARE @Detalle VARCHAR(MAX)=
        (
            SELECT CONCAT(clc.Cod_Estado, '|', clc.Monto_Base, '|', clc.Monto_Real)
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );
        DECLARE @FechaEmision DATETIME=
        (
            SELECT clc.Fecha_Reg
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        );

        --Cambiamos el estado de la letra, montos = 0
        UPDATE dbo.CAJ_LETRA_CAMBIO
          SET 
              dbo.CAJ_LETRA_CAMBIO.Cod_Estado = @Cod_Estado, -- varchar
              dbo.CAJ_LETRA_CAMBIO.Monto_Real = @Monto, -- numeric
              dbo.CAJ_LETRA_CAMBIO.Cod_UsuarioAct = @Cod_Usuario, -- varchar
              dbo.CAJ_LETRA_CAMBIO.Fecha_Act = GETDATE() -- datetime
        WHERE dbo.CAJ_LETRA_CAMBIO.Id = @Id;
        --Eliminamos las formas de pago relacionadas
        DELETE dbo.CAJ_FORMA_PAGO
        WHERE dbo.CAJ_FORMA_PAGO.Id_Movimiento = @Id
              AND dbo.CAJ_FORMA_PAGO.Cod_TipoFormaPago = '001';
        --Eliminamos las relaciones
        DELETE dbo.CAJ_COMPROBANTE_RELACION
        WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = @Id
              AND dbo.CAJ_COMPROBANTE_RELACION.Cod_TipoRelacion = 'LET';

        --Guardamos la jsutificacion

        DECLARE @FechaActual DATETIME= GETDATE();
        DECLARE @id_Fila INT=
        (
            SELECT ISNULL(COUNT(*) / 9, 1) + 1
            FROM PAR_FILA
            WHERE Cod_Tabla = '079'
        );
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
             'CAJ_LETRA_CAMBIO', 
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
             @Proveedor, 
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
             @Detalle, 
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
             @FechaEmision, 
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
             @FechaActual, 
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
GO


IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_LETRA_CAMBIO_TraerLetras_ReporteGeneral'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetras_ReporteGeneral;
GO
CREATE PROCEDURE URP_CAJ_LETRA_CAMBIO_TraerLetras_ReporteGeneral @CodMoneda   VARCHAR(5)   = NULL, 
                                                                 @CodCuenta   VARCHAR(128) = NULL, 
                                                                 @IdCliente   INT          = NULL, 
                                                                 @FechaInicio DATETIME     = NULL, 
                                                                 @FechaFin    DATETIME     = NULL, 
                                                                 @CodEstado   VARCHAR(10)  = NULL, 
                                                                 @CodLibro    VARCHAR(10)  = NULL, 
                                                                 @Por_Vencer  BIT          = 0, 
                                                                 @Dias_Plazo  INT          = 0, 
                                                                 @Vencido     BIT          = 0
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
       clc.Id, 
       clc.Id_Letra, 
       CAST(clc.Nro_Letra AS BIGINT) Nro_Letra, 
       clc.Cod_Libro, 
       clc.Ref_Girador, 
       clc.Fecha_Girado, 
       clc.Fecha_Vencimiento,
       CASE
           WHEN clc.Cod_Estado = '001'
           THEN DATEDIFF(dd, GETDATE(), clc.Fecha_Vencimiento)
           ELSE 0
       END Diferencia, 
       clc.Fecha_Pago,
       CASE
           WHEN clc.Cod_Estado = '001'
           THEN clc.Monto_Base
           ELSE 0
       END Monto_Base, 
       clc.Cod_Cuenta, 
       bcb.Des_CuentaBancaria, 
       clc.Nro_Operacion, 
       clc.Cod_Moneda, 
       vm.Nom_Moneda, 
       clc.Id_Comprobante, 
       clc.Cod_Estado, 
       vel.Des_Estado, 
       clc.Nro_Referencia, 
       clc.Monto_Base, 
       clc.Monto_Real, 
       clc.Observaciones, 
       ccp.Id_Cliente, 
       vtd.Nom_TipoDoc, 
       ccp.Cod_TipoDoc, 
       ccp.Doc_Cliente, 
       ccp.Nom_Cliente, 
       ccp.Cod_TipoComprobante, 
       vtc.Nom_TipoComprobante, 
       ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero SerieNumero
FROM dbo.CAJ_LETRA_CAMBIO clc
     INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago = clc.Id_Comprobante
     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
     INNER JOIN dbo.VIS_MONEDAS vm ON clc.Cod_Moneda = vm.Cod_Moneda
     INNER JOIN dbo.VIS_ESTADOS_LETRA vel ON clc.Cod_Estado = vel.Cod_Estado
     INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
     INNER JOIN dbo.BAN_CUENTA_BANCARIA bcb ON clc.Cod_Cuenta = bcb.Cod_CuentaBancaria
WHERE(@CodMoneda IS NULL
      OR clc.Cod_Moneda = @CodMoneda)
     AND (@CodCuenta IS NULL
          OR clc.Cod_Cuenta = @CodCuenta)
     AND (@IdCliente IS NULL
          OR ccp.Id_Cliente = @IdCliente)
     AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), clc.Fecha_Girado, 103)) BETWEEN CONVERT(DATETIME, @FechaInicio) AND CONVERT(DATETIME, @FechaFin)
          OR @FechaInicio IS NULL)
     AND ((@Por_Vencer = 0
           AND @Vencido = 0
           AND (@CodEstado IS NULL
                OR clc.Cod_Estado = @CodEstado))
          OR (@Por_Vencer = 1
              AND @Vencido = 0
              AND (clc.Cod_Estado = '001'
                   AND DATEDIFF(dd, GETDATE(), clc.Fecha_Vencimiento) <= @Dias_Plazo
                   AND DATEDIFF(dd, GETDATE(), clc.Fecha_Vencimiento) > 0))
          OR (@Por_Vencer = 0
              AND @Vencido = 1
              AND (clc.Cod_Estado = '001'
                   AND DATEDIFF(dd, GETDATE(), clc.Fecha_Vencimiento) < 0)))
     AND (@CodLibro IS NULL
          OR clc.Cod_Libro = @CodLibro)
ORDER BY ccp.Id_Cliente, 
         clc.Id_Letra, 
         CAST(clc.Nro_Letra AS BIGINT), 
         clc.Fecha_Girado;
    END;
GO