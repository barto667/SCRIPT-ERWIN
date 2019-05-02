
IF NOT EXISTS
(
    SELECT vfp.*
    FROM dbo.VIS_FORMAS_PAGO vfp
    WHERE vfp.Cod_FormaPago = '997'
)
    BEGIN
        DECLARE @Fila INT= ISNULL(
        (
            SELECT MAX(vfp.Nro)
            FROM dbo.VIS_FORMAS_PAGO vfp
        ), 0) + 1;
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '001', 
             @Cod_Fila = @Fila, 
             @Cadena = N'997', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = NULL, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '002', 
             @Cod_Fila = @Fila, 
             @Cadena = N'NOTA DE CREDITO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = NULL, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '003', 
             @Cod_Fila = @Fila, 
             @Cadena = NULL, 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 1, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
END;

--EXEC dbo.USP_CAJ_COMPROBANTE_PAGO_TraerNotasCreditoSaldo
--	@Cod_Libro = '14',
--	@Id_Cliente = 105651,
--	@Cod_Moneda = 'PEN'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_TraerNotasCreditoSaldo'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerNotasCreditoSaldo;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerNotasCreditoSaldo @Cod_Libro  VARCHAR(2) , 
                                                                 @Id_Cliente INT        , 
                                                                 @Cod_Moneda VARCHAR(3) 
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               ccp.id_ComprobantePago, 
               CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Documento, 
               AVG(ABS(ccp.Total)) - ISNULL(
        (
            SELECT SUM(cfp.Monto)
            FROM dbo.CAJ_FORMA_PAGO cfp
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp3 ON cfp.id_ComprobantePago = ccp3.id_ComprobantePago
            WHERE cfp.id_ComprobantePago = ccp2.id_ComprobantePago
                  AND cfp.Cod_Moneda = @Cod_Moneda
        ), 0) Saldo, 
               CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero, ' [', AVG(ABS(ccp.Total)) - ISNULL(
        (
            SELECT SUM(cfp.Monto)
            FROM dbo.CAJ_FORMA_PAGO cfp
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp3 ON cfp.id_ComprobantePago = ccp3.id_ComprobantePago
            WHERE cfp.id_ComprobantePago = ccp2.id_ComprobantePago
                  AND cfp.Cod_Moneda = @Cod_Moneda
        ), 0), '] ') Descripcion
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccp2.id_ComprobantePago = ccr.Id_ComprobanteRelacion
        WHERE ccp.Cod_Libro = @Cod_Libro
              AND ccp.Cod_TipoComprobante IN('NCE', 'NC')
             AND ccp.Flag_Anulado = 0
             AND ccr.Cod_TipoRelacion = 'CRE'
             AND ccp2.Flag_Anulado = 0
             AND ccp2.Cod_Moneda = @Cod_Moneda
             AND ccp.Id_Cliente = @Id_Cliente
             AND ccp.Cod_Moneda = @Cod_Moneda
        GROUP BY ccp.id_ComprobantePago, 
                 ccp.Cod_TipoComprobante, 
                 ccp.Serie, 
                 ccp.Numero, 
                 ccp2.id_ComprobantePago
        HAVING AVG(ABS(ccp.Total)) - ISNULL(
        (
            SELECT SUM(cfp.Monto)
            FROM dbo.CAJ_FORMA_PAGO cfp
            WHERE cfp.id_ComprobantePago = ccp2.id_ComprobantePago
        ), 0) > 0;
    END;
GO