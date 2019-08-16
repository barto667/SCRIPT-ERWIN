-- Archivo: Script Procedimientos.sql
--
-- Versión: v4.2.5
--
-- Autor(es): Reyber Yuri Palma Quispe  y Laura Yanina Alegria Amudio
--
-- Fecha de Creación:  26/06/2011, 21/09/2015
--
-- Copyright R&L Consultores PUSP_CAJ_MEDICION_VC_TXTurnoeru2011

--SELECT * FROM dbo.UFN_PRI_CATEGORIA_TXCategoria('304')
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PRI_CATEGORIA_TXCategoria' AND type = 'TF')
DROP FUNCTION UFN_PRI_CATEGORIA_TXCategoria
go
CREATE FUNCTION UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria as  varchar(32))
RETURNS @TABLA_CATEGORIAS TABLE (Cod_Categoria  varchar(32))
WITH ENCRYPTION
AS
BEGIN
 WITH CATEGORIAS (Cod_Categoria)
AS
(
select Cod_Categoria
from PRI_CATEGORIA
where Cod_Categoria = @Cod_Categoria
UNION ALL
select c.Cod_Categoria
from PRI_CATEGORIA AS C INNER JOIN CATEGORIAS AS CA
on  Cod_CategoriaPadre = ca.Cod_Categoria
)
INSERT @TABLA_CATEGORIAS
SELECT Cod_Categoria
FROM CATEGORIAS 
RETURN
END
GO
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_ConvertirNumeroLetra'                    
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_ConvertirNumeroLetra
go
CREATE FUNCTION dbo.UFN_ConvertirNumeroLetra ( @Numero  numeric(20, 2) )
RETURNS  varchar(1024)
    WITH ENCRYPTION
AS 
    BEGIN
 
        DECLARE @lnEntero INT ,
            @lcRetorno  varchar(512) ,
            @lnTerna INT ,
            @lcMiles  varchar(512) ,
            @lcCadena  varchar(512) ,
            @lnUnidades INT ,
            @lnDecenas INT ,
            @lnCentenas INT ,
            @lnFraccion INT

        SELECT  @lnEntero = CAST(@Numero AS INT) ,
                @lnFraccion = ( @Numero - @lnEntero ) * 100 ,
                @lcRetorno = '' ,
                @lnTerna = 1
 
        WHILE @lnEntero > 0 
            BEGIN /* WHILE */
 
    -- Recorro columna por columna
                SELECT  @lcCadena = ''
                SELECT  @lnUnidades = @lnEntero % 10
                SELECT  @lnEntero = CAST(@lnEntero / 10 AS INT)
                SELECT  @lnDecenas = @lnEntero % 10
                SELECT  @lnEntero = CAST(@lnEntero / 10 AS INT)
                SELECT  @lnCentenas = @lnEntero % 10
                SELECT  @lnEntero = CAST(@lnEntero / 10 AS INT)
 
    -- Analizo las unidades
                SELECT  @lcCadena = CASE /* UNIDADES */
                                         WHEN @lnUnidades = 1
                                              AND @lnTerna = 1
                                         THEN 'UNO ' + @lcCadena
                                         WHEN @lnUnidades = 1
                                              AND @lnTerna <> 1
                                         THEN 'UN ' + @lcCadena
                                         WHEN @lnUnidades = 2
                                         THEN 'DOS ' + @lcCadena
                                         WHEN @lnUnidades = 3
                                         THEN 'TRES ' + @lcCadena
                                         WHEN @lnUnidades = 4
                                         THEN 'CUATRO ' + @lcCadena
                                         WHEN @lnUnidades = 5
                                         THEN 'CINCO ' + @lcCadena
                                         WHEN @lnUnidades = 6
                                         THEN 'SEIS ' + @lcCadena
                                         WHEN @lnUnidades = 7
                                         THEN 'SIETE ' + @lcCadena
                                         WHEN @lnUnidades = 8
                                         THEN 'OCHO ' + @lcCadena
                                         WHEN @lnUnidades = 9
                                         THEN 'NUEVE ' + @lcCadena
                                         ELSE @lcCadena
                                    END /* UNIDADES */
 
    -- Analizo las decenas
                SELECT  @lcCadena = CASE /* DECENAS */
                                         WHEN @lnDecenas = 1
                                         THEN CASE @lnUnidades
                                                WHEN 0 THEN 'DIEZ '
                                                WHEN 1 THEN 'ONCE '
                                                WHEN 2 THEN 'DOCE '
                                                WHEN 3 THEN 'TRECE '
                                                WHEN 4 THEN 'CATORCE '
                                                WHEN 5 THEN 'QUINCE '
                                                ELSE 'DIECI' + @lcCadena
                                              END
                                         WHEN @lnDecenas = 2
                                              AND @lnUnidades = 0
                                         THEN 'VEINTE ' + @lcCadena
                                         WHEN @lnDecenas = 2
                                              AND @lnUnidades <> 0
                                         THEN 'VEINTI' + @lcCadena
                                         WHEN @lnDecenas = 3
                                              AND @lnUnidades = 0
                                         THEN 'TREINTA ' + @lcCadena
                                         WHEN @lnDecenas = 3
                                              AND @lnUnidades <> 0
                                         THEN 'TREINTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 4
                                              AND @lnUnidades = 0
                                         THEN 'CUARENTA ' + @lcCadena
                                         WHEN @lnDecenas = 4
                                              AND @lnUnidades <> 0
                                         THEN 'CUARENTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 5
                                              AND @lnUnidades = 0
                                         THEN 'CINCUENTA ' + @lcCadena
                                         WHEN @lnDecenas = 5
                                              AND @lnUnidades <> 0
                                         THEN 'CINCUENTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 6
                                              AND @lnUnidades = 0
                                         THEN 'SESENTA ' + @lcCadena
                                         WHEN @lnDecenas = 6
                                              AND @lnUnidades <> 0
                                         THEN 'SESENTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 7
                                              AND @lnUnidades = 0
                                         THEN 'SETENTA ' + @lcCadena
                                         WHEN @lnDecenas = 7
                                              AND @lnUnidades <> 0
                                         THEN 'SETENTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 8
                                              AND @lnUnidades = 0
                                         THEN 'OCHENTA ' + @lcCadena
                                         WHEN @lnDecenas = 8
                                              AND @lnUnidades <> 0
                                         THEN 'OCHENTA Y ' + @lcCadena
                                         WHEN @lnDecenas = 9
                                              AND @lnUnidades = 0
                                         THEN 'NOVENTA ' + @lcCadena
                                         WHEN @lnDecenas = 9
                                              AND @lnUnidades <> 0
                                         THEN 'NOVENTA Y ' + @lcCadena
                                         ELSE @lcCadena
                                    END /* DECENAS */
 
    -- Analizo las centenas
                SELECT  @lcCadena = CASE /* CENTENAS */
                                         WHEN @lnCentenas = 1
                                              AND @lnUnidades = 0
                                              AND @lnDecenas = 0
                                         THEN 'CIEN ' + @lcCadena
                                         WHEN @lnCentenas = 1
                                              AND NOT ( @lnUnidades = 0
                                                        AND @lnDecenas = 0
                                                      )
                                         THEN 'CIENTO ' + @lcCadena
                                         WHEN @lnCentenas = 2
                                         THEN 'DOSCIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 3
                                         THEN 'TRESCIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 4
                                         THEN 'CUATROCIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 5
                                         THEN 'QUINIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 6
                                         THEN 'SEISCIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 7
                                         THEN 'SETECIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 8
                                         THEN 'OCHOCIENTOS ' + @lcCadena
                                         WHEN @lnCentenas = 9
                                         THEN 'NOVECIENTOS ' + @lcCadena
                                         ELSE @lcCadena
                                    END /* CENTENAS */
 
    -- Analizo los millares
                SELECT  @lcCadena = CASE /* TERNA */
                                         WHEN @lnTerna = 1 THEN @lcCadena
                                         WHEN @lnTerna = 2
                                              AND ( @lnUnidades + @lnDecenas
                                                    + @lnCentenas <> 0 )
                                         THEN @lcCadena + ' MIL '
                                         WHEN @lnTerna = 3
                                              AND ( @lnUnidades + @lnDecenas
                                                    + @lnCentenas <> 0 )
                                              AND @lnUnidades = 1
                                              AND @lnDecenas = 0
                                              AND @lnCentenas = 0
                                         THEN @lcCadena + ' MILLON '
                                         WHEN @lnTerna = 3
                                              AND ( @lnUnidades + @lnDecenas
                                                    + @lnCentenas <> 0 )
                                              AND NOT ( @lnUnidades = 1
                                                        AND @lnDecenas = 0
                                                        AND @lnCentenas = 0
                                                      )
                                         THEN @lcCadena + ' MILLONES '
                                         WHEN @lnTerna = 4
                                              AND ( @lnUnidades + @lnDecenas
                                                    + @lnCentenas <> 0 )
                                         THEN @lcCadena + ' MIL MILLONES '
                                         ELSE ''
                                    END /* MILLARES */
 
    -- Armo el retorno columna a columna
                SELECT  @lcRetorno = @lcCadena + @lcRetorno
                SELECT  @lnTerna = @lnTerna + 1
 
            END /* WHILE */
 
        IF @lnTerna = 1 
            SELECT  @lcRetorno = 'CERO'
        DECLARE @TextoNumero AS  varchar(1024) ;
        SELECT  @TextoNumero = RTRIM(@lcRetorno) + ' CON '
                + CASE WHEN LEN(LTRIM(STR(@lnFraccion, 2))) = 1
                       THEN '0' + LTRIM(STR(@lnFraccion, 2))
                       ELSE LTRIM(STR(@lnFraccion, 2))
                  END + '/100 '
        RETURN @TextoNumero
    END
GO
-- Traer Paginado
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_MOVIMIENTOS_TP'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_TP
go
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_TP
    @TamañoPagina  varchar(16) ,
    @NumeroPagina  varchar(16) ,
    @ScripOrden  varchar(MAX) = NULL ,
    @ScripWhere  varchar(MAX) = NULL
    WITH ENCRYPTION
AS 
    BEGIN
        DECLARE @ScripSQL  varchar(MAX)
        SET @ScripSQL = 'SELECT NumeroFila, id_Movimiento, Cod_Caja, Cod_TipoDocInterno, Serie, Numero, Soles, Dolares, Material, Des_Movimiento, Fecha, Flag_Extornado, Cliente, Nro_Documento, Id_Cliente, 
                      Cod_CuentaContable
FROM (SELECT TOP 100 PERCENT  id_Movimiento, Cod_Caja, Cod_TipoDocInterno, Serie, Numero, Soles, Dolares, Material, Des_Movimiento, Fecha, Flag_Extornado, Cliente, Nro_Documento, Id_Cliente, 
                      Cod_CuentaContable,
  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
  FROM VIS_MOVIMIENTOS ' + @ScripWhere + ') aCAJ_MOVIMIENTO
WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina
            + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)'
        EXECUTE(@ScripSQL) ; 
    END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_MOVIMIENTOS_UltimoSaldo'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_UltimoSaldo
go
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_UltimoSaldo
    @Cod_Caja AS  varchar(32) ,
    @Fecha AS  datetime
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  AFS.Cod_Moneda ,
                AFS.Tipo ,
                AFS.Monto ,
                AF.Fecha ,
                AF.Cod_Caja
        FROM    CAJ_ARQUEOFISICO AS AF
                INNER JOIN CAJ_ARQUEOFISICO_SALDO AS AFS ON AF.id_ArqueoFisico = AFS.id_ArqueoFisico
        WHERE   ( AFS.Tipo = 'CIERRE' )
                AND ( AF.Fecha <= CONVERT( datetime, CONVERT( varchar(20), @Fecha, 103)) )
                AND Cod_Caja = @Cod_Caja
        ORDER BY Cod_Moneda
    END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_MOVIMIENTOS_SaldoInicial'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_SaldoInicial
go
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_SaldoInicial
    @Cod_Caja AS  varchar(32) ,
    @Fecha AS  datetime
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  AFS.Cod_Moneda ,
                AFS.Tipo ,
                AFS.Monto ,
                AF.Fecha ,
                AF.Cod_Caja
        FROM    CAJ_ARQUEOFISICO AS AF
                INNER JOIN CAJ_ARQUEOFISICO_SALDO AS AFS ON AF.id_ArqueoFisico = AFS.id_ArqueoFisico
        WHERE   ( AFS.Tipo = 'APERTURA' )
                AND ( AF.Fecha = CONVERT( datetime, CONVERT( varchar(20), @Fecha, 103)) )
                AND Cod_Caja = @Cod_Caja
        ORDER BY Cod_Moneda
    END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_MOVIMIENTOS_SaldoActual'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_SaldoActual
go
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_SaldoActual
    @Cod_Caja AS  varchar(32) ,
    @Fecha AS  datetime
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  AFS.Cod_Moneda ,
                AFS.Tipo ,
                AFS.Monto ,
                AF.Fecha ,
                AF.Cod_Caja
        FROM    CAJ_ARQUEOFISICO AS AF
                INNER JOIN CAJ_ARQUEOFISICO_SALDO AS AFS ON AF.id_ArqueoFisico = AFS.id_ArqueoFisico
        WHERE   ( AFS.Tipo = 'APERTURA' )
                AND ( AF.Fecha = CONVERT( datetime, CONVERT( varchar(20), @Fecha, 103)) )
                AND Cod_Caja = @Cod_Caja
        ORDER BY Cod_Moneda
    END
go
-- USP_CAJ_TIPOCAMBIO_TXFechaMoneda 'PEN','25/06/2014'
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_TIPOCAMBIO_TXFechaMoneda'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_TIPOCAMBIO_TXFechaMoneda
go
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_TXFechaMoneda
    @Cod_Moneda AS  varchar(3) ,
    @FechaHora AS  datetime
    WITH ENCRYPTION
AS 
    BEGIN
set dateformat dmy;
        SELECT TOP 1
                Id_TipoCambio ,
                FechaHora ,
                Cod_Moneda ,
                SunatCompra ,
                SunatVenta ,
                Compra ,
                Venta
        FROM    CAJ_TIPOCAMBIO
        WHERE   CONVERT( datetime, CONVERT( varchar(20), FechaHora, 103)) = CONVERT( datetime, CONVERT( varchar(20), @FechaHora, 103))
                and Cod_Moneda = @Cod_Moneda
        ORDER BY FechaHora DESC
    END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_SUCURSAL_TXMenos'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_SUCURSAL_TXMenos
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TXMenos
    @Cod_Sucursal AS  varchar(32)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  Cod_Sucursal ,
                Nom_Sucursal
        FROM    PRI_SUCURSAL
        WHERE   Cod_Sucursal NOT IN ( @Cod_Sucursal )
    END
go
------------------------------------------------------------------------------------------
--FECHA: 10/04/2011
--OBJETIVO: APERTURA Y CIERRE DE SISTEMA
--PENDIENTES: SOLICITUD DE TRANSFERENCIA
------------------------------------------------------------------------------------------
-- Traer Por Claves primarias
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_ARQUEOFISICO_TSaldoTipo'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_TSaldoTipo
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_TSaldoTipo
    @Cod_Caja  varchar(32) ,
    @Fecha  datetime ,
    @Tipo  varchar(32)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  A.Cod_Caja ,
                A.Fecha ,
                ASA.Cod_Moneda ,
                ASA.Tipo ,
                ASA.Monto
        FROM    CAJ_ARQUEOFISICO AS A
                INNER JOIN CAJ_ARQUEOFISICO_SALDO AS ASA ON A.id_ArqueoFisico = ASA.id_ArqueoFisico
        WHERE   a.Cod_Caja = @Cod_Caja
                AND a.Fecha = CONVERT( datetime, CONVERT( varchar(20), @Fecha, 103))
                AND ASA.Tipo = @Tipo
        ORDER BY A.Fecha ,
                ASA.Cod_Moneda
    END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_ARQUEOFISICO_TUltimoSaldo'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_ARQUEOFISICO_TUltimoSaldo
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_TUltimoSaldo @Cod_Caja  varchar(32)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT TOP 3
                A.Cod_Caja ,
                A.Fecha ,
                ASA.Cod_Moneda ,
                ASA.Tipo ,
                ASA.Monto
        FROM    CAJ_ARQUEOFISICO AS A
                INNER JOIN CAJ_ARQUEOFISICO_SALDO AS ASA ON A.id_ArqueoFisico = ASA.id_ArqueoFisico
        WHERE   a.Cod_Caja = @Cod_Caja
                AND ASA.Tipo = 'CIERRE'
        ORDER BY Fecha ,
                ASA.Cod_Moneda 
    END
GO
-- Eliminar
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_CAJAS_E'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_CAJAS_E
go
CREATE PROCEDURE USP_CAJ_CAJAS_E @Cod_Caja  varchar(32)
    WITH ENCRYPTION
AS 
    BEGIN

        DELETE  FROM dbo.CAJ_CAJAS_DOC
        WHERE   ( Cod_Caja = @Cod_Caja )

        DELETE  FROM CAJ_CAJAS
        WHERE   ( Cod_Caja = @Cod_Caja )


    END
go

-- Traer Todo
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_CAJAS_TXCajero'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_CAJAS_TXCajero
go
CREATE PROCEDURE USP_CAJ_CAJAS_TXCajero @codCajero  varchar(32)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  Cod_Caja ,
                Cod_Sucursal 
        FROM    CAJ_CAJAS
        WHERE   Cod_UsuarioCajero = @codCajero
    END
go

IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_PRI_CUENTA_DV' ) 
    DROP function UFN_PRI_CUENTA_DV
go
CREATE function [dbo].[UFN_PRI_CUENTA_DV] ( @Cuenta  varchar(12) )
returns  varchar(1)
as 
    begin
        declare @DV  varchar(1)
        DECLARE @Suma AS INT
        DECLARE @i AS INT
        SET @Suma = 8 * CONVERT( int, SUBSTRING(@Cuenta, 1, 1)) + 7
            * CONVERT( int, SUBSTRING(@Cuenta, 2, 1)) + 6
            * CONVERT( int, SUBSTRING(@Cuenta, 3, 1)) + 5
            * CONVERT( int, SUBSTRING(@Cuenta, 4, 1)) + 4
            * CONVERT( int, SUBSTRING(@Cuenta, 5, 1)) + 3
            * CONVERT( int, SUBSTRING(@Cuenta, 6, 1)) + 2
            * CONVERT( int, SUBSTRING(@Cuenta, 7, 1)) + 8
            * CONVERT( int, SUBSTRING(@Cuenta, 8, 1)) + 7
            * CONVERT( int, SUBSTRING(@Cuenta, 9, 1)) + 6
            * CONVERT( int, SUBSTRING(@Cuenta, 10, 1)) + 5
            * CONVERT( int, SUBSTRING(@Cuenta, 11, 1)) + 4
            * CONVERT( int, SUBSTRING(@Cuenta, 12, 1)) ;
        set @i = 11 - ( @suma - ( Ceiling(@suma / 11) * 11 ) )
        if ( @i >= 10 ) 
            set @i = @i - 10 
        set @DV = convert( varchar(1), @i)
        return @DV
    end
go
-- CALCULAR LA SIGUIENTE CUENTA  USP_PRI_CUENTA_SNumCuenta '512', '001'
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_CUENTA_SNumCuenta'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_CUENTA_SNumCuenta
go
CREATE PROCEDURE USP_PRI_CUENTA_SNumCuenta
    @Cod_Empresa  varchar(32) ,
    @Cod_TipoCuenta  varchar(3)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  @Cod_Empresa + '-' + @Cod_TipoCuenta + '-' + RIGHT('000000'
                                                              + CAST(ISNULL(COUNT(*),
                                                              0) + 1 AS  varchar(6)),
                                                              6) + '-'
                + dbo.UFN_PRI_CUENTA_DV(@Cod_Empresa + @Cod_TipoCuenta
                                        + RIGHT('000000'
                                                + CAST(ISNULL(COUNT(*), 0) + 1 AS  varchar(6)),
                                                6)) as Cod_Cuenta
        FROM    CUE_CLIENTE_CUENTA
        WHERE   Cod_TipoCuenta = @Cod_TipoCuenta
    END
go
-- Traer Todo
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_EMPRESA_Tempresa'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_EMPRESA_Tempresa
go
CREATE PROCEDURE USP_PRI_EMPRESA_Tempresa
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT TOP 1
                Cod_Empresa
        FROM    PRI_EMPRESA
    END
go
-- Traer Por Claves primarias
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_MOVIMIENTOS_NumeroXTipoSerie'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_NumeroXTipoSerie
go
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_NumeroXTipoSerie
    @Cod_TipoComprobante  varchar(5) ,
    @Serie  varchar(4)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  ISNULL(MAX(Numero) + 1, 1) AS Numero
        FROM    CAJ_CAJA_MOVIMIENTOS
        WHERE   Serie = @Serie
                AND Cod_TipoComprobante = @Cod_TipoComprobante
    END
go
-- Traer Por Claves primarias
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerie'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerie
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerie
    @Cod_TipoComprobante  varchar(5) ,
    @Serie  varchar(4)
    WITH ENCRYPTION
AS 
    BEGIN
       SELECT     ISNULL(MAX(Numero) + 1, 1) AS NumeroSiguiente
FROM         CAJ_COMPROBANTE_PAGO
WHERE     (Serie = @Serie) AND (Cod_TipoComprobante = @Cod_TipoComprobante)
    END
go
-- Traer Por Claves primarias
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_CONCEPTO_TXClase'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_CONCEPTO_TXClase
go
CREATE PROCEDURE USP_CAJ_CONCEPTO_TXClase
    @Cod_ClaseConcepto  varchar(3)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  Id_Concepto ,                
                Des_Concepto
        FROM    CAJ_CONCEPTO
        WHERE   ( Cod_ClaseConcepto = @Cod_ClaseConcepto )
                AND Flag_Activo = 1
    END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_GUIA_REMISION_E' AND type = 'P')
DROP PROCEDURE USP_CAJ_GUIA_REMISION_E
go
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_E 
@Id_GuiaRemision int
WITH ENCRYPTION
AS
BEGIN
DELETE FROM dbo.CAJ_GUIA_REMISION_D
WHERE (Id_GuiaRemision = @Id_GuiaRemision)
 
DELETE FROM CAJ_GUIA_REMISION
WHERE (Id_GuiaRemision = @Id_GuiaRemision)
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_VIS_PERIODOS_TXFecha'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_VIS_PERIODOS_TXFecha
go
CREATE PROCEDURE USP_VIS_PERIODOS_TXFecha
    @Fecha  datetime
    WITH ENCRYPTION
AS 
    BEGIN
SET @Fecha = CONVERT( datetime,CONVERT( varchar(20),@Fecha,103));
       SELECT TOP 7  Cod_Periodo, Nom_Periodo+'-'+CONVERT( varchar(4),YEAR(Fecha_Inicio)) AS Nom_Periodo
   FROM         VIS_PERIODOS
   WHERE DATEADD(month,-4,@Fecha) < Fecha_Inicio
ORDER BY Fecha_Inicio
    END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_LIMITES_AUTORIZACION_TXMonto' AND type = 'P')
DROP PROCEDURE USP_VIS_LIMITES_AUTORIZACION_TXMonto
go
CREATE PROCEDURE USP_VIS_LIMITES_AUTORIZACION_TXMonto
@Cod_TipoDocInt  varchar(3),
@Cod_Moneda  varchar(3),
@Monto  numeric(38,2)
WITH ENCRYPTION
AS
BEGIN
	SELECT     Nro, Cod_Comision, Cod_TipoDocint, Monto_Max, Cod_Moneda, Estado
	FROM         VIS_LIMITES_AUTORIZACION
	where Cod_TipoDocInt=@Cod_TipoDocInt and Cod_Moneda = @Cod_Moneda and @Monto >= Monto_Max
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_UIT_TActual' AND type = 'P')
DROP PROCEDURE USP_VIS_UIT_TActual
go
CREATE PROCEDURE USP_VIS_UIT_TActual 
WITH ENCRYPTION
AS
BEGIN
    SELECT  ISNULL(Valor_Uit, 0) AS Valor_Uit
    FROM    VIS_UIT
    WHERE   YEAR(GETDATE()) = Nom_uit
END
go
------------------------------------------------------------------------------------------
--FECHA: 19/11/2012
--OBJETIVO: Login: filtro de periodos,  
--PENDIENTES: Inicio de Caja Administrativo.
------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PERIODOS_TraerPorGestion' AND type = 'P')
DROP PROCEDURE USP_VIS_PERIODOS_TraerPorGestion
go
CREATE PROCEDURE USP_VIS_PERIODOS_TraerPorGestion
@Gestion int
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Periodo ,Nom_Periodo
FROM VIS_PERIODOS
WHERE YEAR(Fecha_Inicio) = @Gestion and Estado = 1
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PERIODOS_TraerPorFechaGestion' AND type = 'P')
DROP PROCEDURE USP_VIS_PERIODOS_TraerPorFechaGestion
go
CREATE PROCEDURE USP_VIS_PERIODOS_TraerPorFechaGestion
@Gestion  int,
@Fecha  datetime
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Periodo ,Nom_Periodo
FROM VIS_PERIODOS
WHERE YEAR(Fecha_Inicio) = @Gestion and @Fecha between Fecha_Inicio and Fecha_Fin and Estado = 1
END
go
------------------------------------------------------------------------------------------
--FECHA: 27/11/2012
--OBJETIVO: POS Cambio precio, SErafin, Descarga de Tanques  
--PENDIENTES: Realizar Movimientos de RE y RI en Caja y Compra/venta de Dolares
------------------------------------------------------------------------------------------
--USP_PRI_PRODUCTO_STOCK_XCategoria '100'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_XCategoria' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_XCategoria
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_XCategoria
@Cod_Categoria  varchar(512)
WITH ENCRYPTION
AS
BEGIN
SELECT     PS.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, PS.Precio_Venta, P.Nom_Producto
FROM         PRI_PRODUCTOS AS P INNER JOIN
                      PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
                      PRI_CATEGORIA AS c ON P.Cod_Categoria = c.Cod_Categoria
WHERE (@Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)))
--AND Flag_Activo = 1
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_EMPRESA_TraerUnicaEmpresa' AND type = 'P')
DROP PROCEDURE USP_PRI_EMPRESA_TraerUnicaEmpresa
go
CREATE PROCEDURE USP_PRI_EMPRESA_TraerUnicaEmpresa
WITH ENCRYPTION
AS
BEGIN
SELECT     TOP (1) Cod_Empresa
FROM         PRI_EMPRESA                  
END
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CUENTA_CONTABLE_Buscar' AND type = 'P')
DROP PROCEDURE USP_PRI_CUENTA_CONTABLE_Buscar
go
CREATE PROCEDURE USP_PRI_CUENTA_CONTABLE_Buscar
@TextoBuscar  varchar(128)
WITH ENCRYPTION
AS
BEGIN

SELECT    Cod_CuentaContable, Des_CuentaContable
FROM         PRI_CUENTA_CONTABLE                 
where Cod_CuentaContable like @TextoBuscar+'%' or Des_CuentaContable  like '%'+@TextoBuscar+'%'

END
go
------------------------------------------------------------------------------------------
--FECHA: 01/12/2012
--OBJETIVO: Plantillas
--PENDIENTES: Ingresar comprobantes de Pago
------------------------------------------------------------------------------------------
-- TRAER SEGUN LA CUENTA ORIGEN LAS CUENTAS DE AMARRE SI LO TVIERA
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_AMARRES_CONTABLES_TraerXCuentaOrigen' AND type = 'P')
DROP PROCEDURE USP_VIS_AMARRES_CONTABLES_TraerXCuentaOrigen
go
CREATE PROCEDURE USP_VIS_AMARRES_CONTABLES_TraerXCuentaOrigen
@Cod_CuentaOrigen  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     AC.Cod_Amarre, AC.Cod_CuentaOrigen, AC.Cod_CuentaDestino, AC.Porcentaje_Debe, AC.Porcentaje_Haber, CC.Des_CuentaContable, CC.Flag_CuentaAnalitica, 
  CC.Tipo_Cuenta, CC.Clase_Cuenta
FROM         VIS_AMARRES_CONTABLES AS AC INNER JOIN
  PRI_CUENTA_CONTABLE AS CC ON AC.Cod_CuentaDestino = CC.Cod_CuentaContable
WHERE     (AC.Estado = 1) AND (AC.Cod_CuentaOrigen = @Cod_CuentaOrigen)
ORDER BY AC.Orden
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_TXCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_ARQUEOFISICO_TXCajaTurno
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_TXCajaTurno
@CodCaja  varchar(32),
@CodTurno  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     A.id_ArqueoFisico, A.Cod_Caja, A.Cod_Turno, A.Numero, A.Des_ArqueoFisico, A.Fecha, AO.Cod_Moneda, AO.Tipo, AO.Monto
FROM         CAJ_ARQUEOFISICO AS A INNER JOIN
                      CAJ_ARQUEOFISICO_SALDO AS AO ON A.id_ArqueoFisico = AO.id_ArqueoFisico
WHERE     (A.Cod_Caja = @CodCaja) AND (A.Cod_Turno = @CodTurno)and AO.Tipo = 'SALDO INICIAL'
END
go
-- USP_CAJ_ARQUEOFISICO_TNumeroSiguiente
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_TNumeroSiguiente' AND type = 'P')
DROP PROCEDURE USP_CAJ_ARQUEOFISICO_TNumeroSiguiente
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_TNumeroSiguiente
@CodCaja  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT top 1 Numero
FROM CAJ_ARQUEOFISICO
where Cod_Caja = @CodCaja
order by Numero desc
END
go
 --------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 06/10/2015
-- OBJETIVO: Trae todos los turnos segun el periodo y la hora actual
-- USP_CAJ_TURNO_ATENCION_TXCodPeriodo '2015-10'
-------------------------------------------------------------------------------------------------------------- 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TURNO_ATENCION_TXCodPeriodo' AND type = 'P')
DROP PROCEDURE USP_CAJ_TURNO_ATENCION_TXCodPeriodo
go
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_TXCodPeriodo
@Cod_Periodo  varchar(32)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Fecha as datetime;
	SET @Fecha = DATEADD(HOUR,2,GETDATE());
	SELECT     T.Cod_Turno,case T.Flag_Cerrado when 1 then 'C ' else 'A ' end + T.Des_Turno as Des_Turno 
	FROM         CAJ_TURNO_ATENCION AS T CROSS JOIN
						  VIS_PERIODOS AS P
	WHERE (t.Fecha_Inicio between P.Fecha_Inicio and DATEADD(day,1,P.Fecha_Fin)) 
	and P.Cod_Periodo = @Cod_Periodo
	and t.Fecha_Inicio <= @Fecha
	ORDER BY t.Fecha_Inicio
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_TXTipoAlmacen' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_TXTipoAlmacen
go
CREATE PROCEDURE USP_ALM_ALMACEN_TXTipoAlmacen
@Cod_TipoAlmacen  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Almacen , Des_Almacen
FROM ALM_ALMACEN
where Cod_TipoAlmacen = @Cod_TipoAlmacen
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TXAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TXAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TXAlmacen
@Cod_Almacen  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     PS.Cod_Almacen, PS.Stock_Min, PS.Stock_Max, PS.Stock_Act, PS.Cod_UnidadMedida, P.Nom_Producto,P.Id_Producto
FROM         PRI_PRODUCTO_STOCK AS PS INNER JOIN
                      PRI_PRODUCTOS AS P ON PS.Id_Producto = P.Id_Producto
where  PS.Cod_Almacen=@Cod_Almacen
END
go
-- Traer Documentos por Caja
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TXCod_Caja' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_DOC_TXCod_Caja
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TXCod_Caja
@Cod_Caja  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     CD.Cod_Caja, CD.Item, CD.Cod_TipoComprobante, CD.Serie, 
          CD.Impresora, CD.Flag_Imprimir, CD.Nom_Archivo, 
          CD.Nro_SerieTicketera, TC.Nom_TipoComprobante, 
              TC.Cod_Sunat, TC.Flag_Ventas, TC.Flag_Compras, Flag_FacRapida
FROM         CAJ_CAJAS_DOC AS CD INNER JOIN
                      VIS_TIPO_COMPROBANTES AS TC ON CD.Cod_TipoComprobante = TC.Cod_TipoComprobante
WHERE     (CD.Cod_Caja = @Cod_Caja)
END
go
-- USP_CAJ_CAJAS_DOC_TXFacRapida '301','08'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TXFacRapida' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_DOC_TXFacRapida
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TXFacRapida
@Cod_Caja  varchar(32),
@Cod_Libro as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT     Cod_Caja, Cod_TipoComprobante, Serie, Impresora, Flag_Imprimir, Nom_Archivo, Nro_SerieTicketera,
(select ISNULL(MAX(p.Numero)+1,1) from CAJ_COMPROBANTE_PAGO as P 
where P.Cod_TipoComprobante = CD.Cod_TipoComprobante and CD.Serie = P.Serie and P.Cod_Libro = @Cod_Libro) as Numero
FROM         CAJ_CAJAS_DOC as CD
where Flag_FacRapida = 1 and Cod_Caja = @Cod_Caja
END
go
--USP_CAJ_CAJAS_DOC_TXCodCaja 'ISLA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TXCodCaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_DOC_TXCodCaja
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TXCodCaja
@Cod_Caja  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT  DISTINCT   CD.Cod_TipoComprobante, TC.Nom_TipoComprobante, CD.Serie, CD.Impresora, CD.Flag_Imprimir, CD.Nom_Archivo, CD.Nro_SerieTicketera, TC.Cod_Sunat, 
                      TC.Flag_Ventas, TC.Flag_Compras, TC.Flag_RegistroVentas, TC.Flag_RegistroCompras, CD.Flag_FacRapida
FROM         CAJ_CAJAS_DOC AS CD INNER JOIN
                      VIS_TIPO_COMPROBANTES AS TC ON CD.Cod_TipoComprobante = TC.Cod_TipoComprobante
WHERE     (CD.Cod_Caja = @Cod_Caja) and TC.Estado = 1
order by CD.Cod_TipoComprobante
END
go
-- traer clientes varios
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TClientesVarios' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TClientesVarios
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TClientesVarios
WITH ENCRYPTION
AS
BEGIN
SELECT Id_ClienteProveedor , Cod_TipoDocumento , Nro_Documento , Cliente 
FROM PRI_CLIENTE_PROVEEDOR
where Cliente = 'CLIENTES VARIOS'
END
go
-- Buscar Comprobante segun libro
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TXClienteTipoSerieNumero' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXClienteTipoSerieNumero
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXClienteTipoSerieNumero
@Id_Cliente  int,
@Cod_TipoComprobante  varchar(5),
@Serie  varchar(5),
@Numero  varchar(20)

WITH ENCRYPTION
AS
BEGIN
SELECT     id_ComprobantePago
FROM         CAJ_COMPROBANTE_PAGO
WHERE     (Id_Cliente = @Id_Cliente) and Cod_TipoComprobante = @Cod_TipoComprobante and Serie =@Serie and Numero = @Numero
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TXTipoSerieNumero' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXTipoSerieNumero
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXTipoSerieNumero
@Cod_TipoComprobante  varchar(5),
@Serie  varchar(5),
@Numero  varchar(20)

WITH ENCRYPTION
AS
BEGIN
SELECT     id_ComprobantePago
FROM         CAJ_COMPROBANTE_PAGO
WHERE     Cod_TipoComprobante = @Cod_TipoComprobante and Serie =@Serie and Numero = @Numero
END
go

IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_TotalXAlmacen'
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_TotalXAlmacen
go
CREATE FUNCTION dbo.UFN_TotalXAlmacen ( @Cod_Almacen  varchar(32), @CodTurno  varchar(32) )
RETURNS  numeric(38,2)
    WITH ENCRYPTION
AS 
    BEGIN
    DECLARE @TotalAlmacen as  numeric(38,2);        
    
    SET @TotalAlmacen = (select sum(F.Debe-F.Haber) from (
    SELECT    ISNULL(sum(CD.Despachado),0) as Debe, 0.0 as Haber 
FROM CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                      CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                      WHERE CD.Cod_Almacen = @Cod_Almacen AND CP.Cod_Turno = @CodTurno 
                      and CP.Cod_Libro = '14' and cp.Flag_Anulado = 0 and cp.Flag_Despachado = 1
                      union
                     SELECT     0.0 AS Debe, ISNULL(SUM(AMD.Cantidad), 0) AS Haber
FROM         ALM_ALMACEN_MOV_D AS AMD INNER JOIN
                      ALM_ALMACEN_MOV AS AM ON AMD.Id_AlmacenMov = AM.Id_AlmacenMov INNER JOIN
                      ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen
WHERE     (AM.Cod_Turno = @CodTurno) AND (@Cod_Almacen = AM.Cod_Almacen) AND (AM.Flag_Anulado = 0) and A.Cod_TipoAlmacen = '03') as F)
    RETURN @TotalAlmacen;
    END
    GO
 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TotalxCajaTurnoForma' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TotalxCajaTurnoForma
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TotalxCajaTurnoForma
@Cod_Turno  varchar(32),
@Cod_Caja  varchar(32),
@Cod_TipoComprobante  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT     TC.Nom_TipoComprobante AS Comprobante, CM.Serie, 
CASE COUNT(CM.Numero) WHEN 1 THEN MAX(CM.Numero) ELSE COUNT(CM.Numero) END AS Numero, 
                      CP.Cod_TipoDocumento + '-' + CP.Nro_Documento AS Documento,
                       CONVERT( varchar(20), CM.Fecha, 103) AS Fecha, CP.Cliente,
                       sum(case when Ingreso > 0 then Ingreso else Egreso end) as Importe
FROM         CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
                      VIS_TIPO_COMPROBANTES AS TC ON CM.Cod_TipoComprobante = TC.Cod_TipoComprobante INNER JOIN
                      PRI_CLIENTE_PROVEEDOR AS CP ON CP.Id_ClienteProveedor = CP.Id_ClienteProveedor
WHERE     (Flag_Extornado = 0) AND(CM.Cod_Turno = @Cod_Turno) 
                      AND (CM.Cod_Caja = @Cod_Caja) and cm.Cod_TipoComprobante = @Cod_TipoComprobante
GROUP BY CM.Serie, CP.Cod_TipoDocumento + '-' + CP.Nro_Documento, CP.Cliente, CONVERT( varchar(20), CM.Fecha, 103), TC.Nom_TipoComprobante, CP.Cliente

END
go
-- funcion que traiga el detalle del documento adjunto
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UF_CAJ_COMPROBANTE_PAGO_TXIdRef')
DROP FUNCTION dbo.UF_CAJ_COMPROBANTE_PAGO_TXIdRef
go
CREATE FUNCTION dbo.UF_CAJ_COMPROBANTE_PAGO_TXIdRef(@id_ComprobantePagoRef int) 
RETURNS  varchar(64)
WITH ENCRYPTION
AS
BEGIN
   DECLARE @ComprobanteRef as  varchar(64);
SELECT @ComprobanteRef=Cod_TipoComprobante+':'+ Serie+ '-'+Numero
FROM         CAJ_COMPROBANTE_PAGO
where @id_ComprobantePagoRef = id_ComprobantePago

RETURN(@ComprobanteRef);

END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CATEGORIA_TT' AND type = 'P')
DROP PROCEDURE USP_PRI_CATEGORIA_TT
go
CREATE PROCEDURE USP_PRI_CATEGORIA_TT
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Categoria , Des_Categoria 
FROM PRI_CATEGORIA
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_MARCAS_TT' AND type = 'P')
DROP PROCEDURE USP_PRI_MARCAS_TT
go
CREATE PROCEDURE USP_PRI_MARCAS_TT
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Marca , Des_Marca
FROM PRI_MARCAS
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TXIdProducto' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TXIdProducto
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TXIdProducto
@Id_Producto as int
WITH ENCRYPTION
AS
BEGIN
SELECT     PS.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, PS.Cod_Moneda, PS.Precio_Compra, PS.Precio_Venta, PS.Stock_Min, PS.Stock_Max, PS.Stock_Act, 
                      PS.Cod_UnidadMedidaMin, PS.Cantidad_Min, UM.Nom_UnidadMedida, A.Des_Almacen, 
                      UMin.Nom_UnidadMedida AS Nom_UnidadMedidaMin
FROM         PRI_PRODUCTO_STOCK AS PS INNER JOIN
                      VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
                      ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
                      VIS_UNIDADES_DE_MEDIDA AS UMin ON PS.Cod_UnidadMedidaMin = UMin.Cod_UnidadMedida
WHERE Id_Producto = @Id_Producto
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_DETALLE_TXIdProducto' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto
go
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto
@Id_Producto int
WITH ENCRYPTION
AS
BEGIN
SELECT     PD.Id_Producto, PD.Item_Detalle, PD.Id_ProductoDetalle, PD.Cod_TipoDetalle, PD.Cantidad, PD.Cod_UnidadMedida, UM.Nom_UnidadMedida, 
                      TDP.Nom_TipoDetallePro, P.Nom_Producto
FROM         PRI_PRODUCTO_DETALLE AS PD INNER JOIN
                      VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro INNER JOIN
                      VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
                      PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
WHERE (PD.Id_Producto = @Id_Producto) 
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_PRODUCTOS' ) 
    DROP VIEW VIS_PRODUCTOS
go
CREATE VIEW VIS_PRODUCTOS
WITH ENCRYPTION
AS
SELECT        P.Id_Producto, P.Cod_Producto, P.Cod_Categoria, P.Cod_Marca, P.Cod_TipoProducto, P.Nom_Producto, P.Des_LargaProducto, P.Des_CortaProducto, 
                         P.Caracteristicas, P.Porcentaje_Utilidad, P.Cuenta_Contable, P.Contra_Cuenta, P.Cod_Garantia, P.Cod_TipoOperatividad, P.Cod_TipoExistencia, 
                         P.Flag_Activo, P.Cod_Fabricante, C.Des_Categoria, TP.Nom_TipoProducto, VIS_MARCA.Nom_Marca
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         PRI_CATEGORIA AS C ON P.Cod_Categoria = C.Cod_Categoria INNER JOIN
                         VIS_TIPO_PRODUCTO AS TP ON P.Cod_TipoProducto = TP.Cod_TipoProducto INNER JOIN
                         VIS_MARCA ON P.Cod_Marca = VIS_MARCA.Cod_Marca
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_TP' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_TP
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila, Id_Producto, Cod_Producto, Cod_Categoria, Cod_Marca, Cod_TipoProducto, Nom_Producto, Des_LargaProducto, Des_CortaProducto, Caracteristicas, 
                      Porcentaje_Utilidad, Cuenta_Contable, Contra_Cuenta, Cod_Garantia, Cod_TipoOperatividad, Cod_TipoExistencia, Flag_Activo, Cod_Fabricante, Nom_Marca, 
                      Des_Categoria, Nom_TipoProducto  
FROM (SELECT TOP 100 PERCENT  Id_Producto, Cod_Producto, Cod_Categoria, Cod_Marca, Cod_TipoProducto, Nom_Producto, Des_LargaProducto, Des_CortaProducto, Caracteristicas, 
                      Porcentaje_Utilidad, Cuenta_Contable, Contra_Cuenta, Cod_Garantia, Cod_TipoOperatividad, Cod_TipoExistencia, Flag_Activo, Cod_Fabricante, Nom_Marca, 
                      Des_Categoria, Nom_TipoProducto ,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_PRODUCTOS '+@ScripWhere+') aPRI_PRODUCTOS
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go

--SELECT dbo.Ubigeo('200101')
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'Ubigeo' ) 
    DROP FUNCTION Ubigeo
go
CREATE FUNCTION dbo.Ubigeo(@CodUbigeo as  varchar(8))
RETURNS  varchar(512)
AS
BEGIN
DECLARE @Ubigeo as  varchar(512);
SET @Ubigeo = '';
SET @Ubigeo = (SELECT top 1  ISNULL( DE.Nom_Departamento+' - '+  P.Nom_Provincia+' - '+  D.Nom_Distrito,'')
FROM         VIS_PROVINCIAS AS P INNER JOIN
                      VIS_DISTRITOS AS D ON P.Cod_Provincia = D.Cod_Provincia AND P.Cod_Departamento = D.Cod_Departamento INNER JOIN
                      VIS_DEPARTAMENTOS AS DE ON P.Cod_Departamento = DE.Cod_Departamento
                      WHERE D.Cod_Ubigeo = @CodUbigeo);

RETURN @Ubigeo;
END
GO
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'USP_PRI_CLIENTE_PROVEEDOR_TUbigeo' ) 
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TUbigeo
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TUbigeo 
@CodUbigeo as  varchar(8)
AS
BEGIN
select dbo.Ubigeo(@CodUbigeo)
END
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_MONEDAS_SinSoles' AND type = 'P')
DROP PROCEDURE USP_VIS_MONEDAS_SinSoles
go
CREATE PROCEDURE USP_VIS_MONEDAS_SinSoles
WITH ENCRYPTION
AS
BEGIN

SELECT Cod_Moneda
      ,Nom_Moneda      
  FROM VIS_MONEDAS
  WHERE Estado = 1 AND Cod_Moneda <> 'PEN'
  END
go

-- USP_PRI_CLIENTE_CONTACTO_TXId_ClienteProveedor 685
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CONTACTO_TXId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_CONTACTO_TXId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_CLIENTE_CONTACTO_TXId_ClienteProveedor
@Id_ClienteProveedor as int
WITH ENCRYPTION
AS
BEGIN
	SELECT        CC.Id_ClienteProveedor, CC.Id_ClienteContacto, CC.Cod_TipoDocumento, CC.Nro_Documento, CC.Ap_Paterno, CC.Ap_Materno, CC.Nombres, 
                         '(' + SUBSTRING(VCT.Ciudad, 1, 3) + ') ' + CC.Nro_Telefono AS Telefono, CC.Anexo, CC.Email_Empresarial, CC.Email_Personal, CC.Celular, CC.Fecha_Incorporacion, 
                         VTD.Nom_TipoDoc, VCT.Ciudad
FROM            PRI_CLIENTE_CONTACTO AS CC LEFT OUTER JOIN
                         VIS_TIPO_DOCUMENTOS AS VTD ON CC.Cod_TipoDocumento = VTD.Cod_TipoDoc LEFT OUTER JOIN
                         VIS_CODIGO_TELEFONO AS VCT ON CC.Cod_Telefono = VCT.Cod_Telefono
WHERE        (CC.Id_ClienteProveedor = @Id_ClienteProveedor)
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ESTABLECIMIENTOS_TXId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_ESTABLECIMIENTOS_TXId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_ESTABLECIMIENTOS_TXId_ClienteProveedor
@Id_ClienteProveedor as int
WITH ENCRYPTION
AS
BEGIN
SELECT     ES.Cod_Establecimientos, ES.Id_ClienteProveedor, ES.Des_Establecimiento, ES.Cod_TipoEstablecimiento, ES.Direccion, ES.Telefono, ES.Obs_Establecimiento, 
                      VTE.Nom_TipoEstablecimiento
FROM         PRI_ESTABLECIMIENTOS AS ES INNER JOIN
                      VIS_TIPO_ESTABLECIMIENTOS AS VTE ON ES.Cod_TipoEstablecimiento = VTE.Cod_TipoEstablecimiento
where Id_ClienteProveedor = @Id_ClienteProveedor
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_TXId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_LICITACIONES_TXId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_LICITACIONES_TXId_ClienteProveedor
@Id_ClienteProveedor as Int
WITH ENCRYPTION
AS
BEGIN
SELECT        L.Id_ClienteProveedor, L.Cod_Licitacion, L.Des_Licitacion, L.Cod_TipoLicitacion, L.Nro_Licitacion, 
L.Fecha_Inicio, L.Fecha_Facturacion, L.Flag_AlFinal, L.Cod_TipoComprobante, TC.Nom_TipoComprobante, 
                         TL.Nom_TipoLicitacion
FROM            PRI_LICITACIONES AS L INNER JOIN
                         VIS_TIPO_LICITACIONES AS TL ON L.Cod_TipoLicitacion = TL.Cod_TipoLicitacion INNER JOIN
                         VIS_TIPO_COMPROBANTES AS TC ON L.Cod_TipoComprobante = TC.Cod_TipoComprobante
where Id_ClienteProveedor = @Id_ClienteProveedor
END
go
-- Traer Resumen  USP_CAJ_COMPROBANTE_P_CreditoxCajaTurno 'ISLA01','09/02/2013','PEN'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_P_CreditoxCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_P_CreditoxCajaTurno
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_P_CreditoxCajaTurno
@Cod_Libro as  varchar(32),
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32),
@Cod_Moneda AS  varchar(8)
WITH ENCRYPTION
AS
BEGIN
SELECT    cp.Cod_TipoComprobante + ':'+CP.Serie+ '-'+ CP.Numero as Comprobante, TD.Nom_TipoDoc + ': ' + CP.Doc_Cliente AS Documento, CP.Nom_Cliente, P.Des_CortaProducto, CP.FechaEmision, CP.Total, 
                         CP.Descuento_Total,cp.id_ComprobantePago
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDoc = TD.Cod_TipoDoc INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
                         PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
WHERE  CP.Cod_FormaPago <> '008' AND CP.Cod_Caja = @Cod_Caja AND  CP.Cod_Turno = @Cod_Turno and  @Cod_Moneda = cp.Cod_Moneda
and (@Cod_Libro = cp.Cod_Libro)

END
go
 --  USP_CAJ_COMPROBANTE_P_ContadoxCajaTurno '501','09/07/2013','PEN'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_P_ContadoxCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_P_ContadoxCajaTurno
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_P_ContadoxCajaTurno
@Cod_Libro as  varchar(32),
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32),
@Cod_Moneda AS  varchar(8)
WITH ENCRYPTION
AS
BEGIN
SET DATEFORMAT dmy;
--SELECT     cp.Cod_TipoComprobante + ':'+CP.Serie+ '('+ CONVERT( varchar(50), MIN(CP.Numero)) + ' - ' + CONVERT( varchar(50), MAX(CP.Numero))+ ')' AS Comprobante, 
--  TD.Nom_TipoDoc + ': ' + CP.Doc_Cliente AS Documento, CP.Nom_Cliente, P.Des_CortaProducto, CONVERT( datetime, CONVERT( varchar, CP.FechaEmision, 103)) 
--  AS FechaEmision, sum(CP.Total) AS Total, 0.00 AS Descuento_Total, cp.id_ComprobantePago
--FROM         CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
--  VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDoc = TD.Cod_TipoDoc INNER JOIN
--  VIS_TIPO_COMPROBANTES AS TC ON CP.Cod_TipoComprobante = TC.Cod_TipoComprobante INNER JOIN
--  CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
--  PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
--WHERE     (CP.Cod_FormaPago = '008') AND (CP.Cod_Caja = @Cod_Caja) 
--AND (CP.Cod_Turno = @Cod_Turno) AND (TC.Cod_TipoComprobante = 'TKB') and @Cod_Moneda = cp.Cod_Moneda
--and (@Cod_Libro = cp.Cod_Libro)
--GROUP BY  cp.id_ComprobantePago,cp.Cod_TipoComprobante,CP.Serie,TD.Nom_TipoDoc + ': ' + CP.Doc_Cliente, CP.Nom_Cliente, P.Des_CortaProducto, CONVERT( datetime, CONVERT( varchar, 
--  CP.FechaEmision, 103)) 
--UNION
SELECT        CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CP.Numero AS Comprobante, TD.Nom_TipoDoc + ': ' + CP.Doc_Cliente AS Documento, CP.Nom_Cliente, 
                         P.Des_CortaProducto, CP.FechaEmision, CP.Total, CP.Descuento_Total, CP.id_ComprobantePago
FROM            PRI_PRODUCTOS AS P RIGHT OUTER JOIN
                         CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto RIGHT OUTER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDoc = TD.Cod_TipoDoc INNER JOIN
                         VIS_TIPO_COMPROBANTES AS TC ON CP.Cod_TipoComprobante = TC.Cod_TipoComprobante ON CD.id_ComprobantePago = CP.id_ComprobantePago
WHERE        (CP.Cod_FormaPago = '008') AND (CP.Cod_Caja = @Cod_Caja) AND (CP.Cod_Turno = @Cod_Turno) AND (@Cod_Moneda = CP.Cod_Moneda) AND 
                         (@Cod_Libro = CP.Cod_Libro)
ORDER BY Comprobante, Documento, P.Des_CortaProducto
END
go
-- USP_CAJ_TRANSFERENCIAS_TXDestinoMoneda '100','pen'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TRANSFERENCIAS_TXDestinoMoneda' AND type = 'P')
DROP PROCEDURE USP_CAJ_TRANSFERENCIAS_TXDestinoMoneda
go
CREATE PROCEDURE USP_CAJ_TRANSFERENCIAS_TXDestinoMoneda
@Cod_Sucursal as  varchar(32) = NULL,
@Cod_Moneda AS  varchar(8) = NULL
WITH ENCRYPTION
AS
BEGIN
   SELECT DISTINCT 
                         T.Id_Transferencia, T.Fecha_Emision, T.Cod_UsuarioEmision, T.Cod_Moneda, CASE T .Cod_Moneda WHEN '001' THEN 'X' ELSE '' END AS Soles, 
                         CASE T .Cod_Moneda WHEN '002' THEN 'X' ELSE '' END AS Dolares, T.Monto, T.Comision, T.Otros, 
                         dbo.UFN_ConvertirNumeroLetra(T.Monto + T.Comision + T.Otros) + M.Definicion AS Son, T.Cod_Banco, T.Num_Cuenta, T.Cod_EstadoTransferencia, 
                         T.Obs_Tranferencia, CE.Cliente AS Emisor, CP.Cliente AS Beneficiario1, CS.Cliente AS Beneficiario2, M.Nom_Moneda, B.Nom_EntidadFinanciera, 
                         SO.Nom_Sucursal AS Origen, SD.Nom_Sucursal AS Destino, C.Cod_Caja, C.Des_Caja, ET.Nom_EstadoTransferencia, M.Simbolo, 
                         CS.Nro_Documento AS DocumentoS, CP.Nro_Documento AS DocumentoP, CE.Nro_Documento AS DocumentoE, T.Fecha_Pago
FROM            CAJ_TRANSFERENCIAS AS T INNER JOIN
                         VIS_MONEDAS AS M ON T.Cod_Moneda = M.Cod_Moneda INNER JOIN
                         VIS_ESTADO_TRANSFERENCIA AS ET ON T.Cod_EstadoTransferencia = ET.Cod_EstadoTransferencia LEFT OUTER JOIN
                         VIS_ENTIDADES_FINANCIERAS AS B ON T.Cod_Banco = B.Cod_EntidadFinanciera LEFT OUTER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CE ON T.id_ClienteEmisor = CE.Id_ClienteProveedor LEFT OUTER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CP ON T.id_ClienteBeneficiarioP = CP.Id_ClienteProveedor LEFT OUTER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CS ON T.id_ClienteBeneficiarioS = CS.Id_ClienteProveedor LEFT OUTER JOIN
                         CAJ_CAJAS AS C ON T.Cod_UsuarioEmision = C.Cod_UsuarioCajero LEFT OUTER JOIN
                         PRI_SUCURSAL AS SO ON T.Cod_Origen = SO.Cod_Sucursal LEFT OUTER JOIN
                         PRI_SUCURSAL AS SD ON T.Cod_Destino = SD.Cod_Sucursal      
        WHERE (T.Cod_Destino = @Cod_Sucursal  or @Cod_Sucursal is null)
and (@Cod_Moneda = @Cod_Moneda or @Cod_Moneda is null )
END
go

-- USP_CAJ_CAJA_MOVIMIENTOS_TxCajaTurno 'ISLA','19/06/2013','EGRESO','PEN'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_TxCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TxCajaTurno
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TxCajaTurno
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32),
@Tipo as  varchar(32),
@Cod_Moneda AS  varchar(8)
WITH ENCRYPTION
AS
BEGIN
IF (@Tipo = 'INGRESO')
SELECT     cm.Cod_TipoComprobante+ ':'  +CM.Serie+ '-'+CM.Numero as Nom_TipoComprobante, CM.Cliente, CM.Des_Movimiento, CM.Fecha, 
                       VM.Simbolo + ' ' + CONVERT( varchar, CM.Ingreso)  ImporteTexto,
                      CM.Ingreso  as Importe,CM.id_Movimiento
FROM         CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
                      VIS_TIPO_COMPROBANTES AS VTC ON CM.Cod_TipoComprobante = VTC.Cod_TipoComprobante INNER JOIN
                      VIS_MONEDAS AS VM ON CM.Cod_MonedaIng = VM.Cod_Moneda 
WHERE      (CM.Cod_Caja = @Cod_Caja) AND (CM.Cod_Turno = @Cod_Turno) and CM.Cod_MonedaIng = @Cod_Moneda and CM.Ingreso <> 0

ORDER BY VTC.Nom_TipoComprobante, CM.Fecha
ELSE
SELECT     cm.Cod_TipoComprobante + ':' + CM.Serie+'-'+ CM.Numero as Nom_TipoComprobante, CM.Cliente, CM.Des_Movimiento, CM.Fecha, 
                      VME.Simbolo + ' ' + CONVERT( varchar,CM.Egreso) AS ImporteTexto,
                      CM.Egreso AS Importe,CM.id_Movimiento
FROM         CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
                      VIS_TIPO_COMPROBANTES AS VTC ON CM.Cod_TipoComprobante = VTC.Cod_TipoComprobante INNER JOIN
                      VIS_MONEDAS AS VME ON CM.Cod_MonedaEgr = VME.Cod_Moneda
WHERE     (CM.Cod_Caja = @Cod_Caja) AND (CM.Cod_Turno = @Cod_Turno) and CM.Cod_MonedaEgr = @Cod_Moneda and CM.Egreso <> 0
ORDER BY VTC.Nom_TipoComprobante, CM.Fecha
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_PRI_CLIENTEPROVEEDOR_SaldoPagoAdelantado' ) 
    DROP FUNCTION UFN_PRI_CLIENTEPROVEEDOR_SaldoPagoAdelantado
go
CREATE FUNCTION [dbo].[UFN_PRI_CLIENTEPROVEEDOR_SaldoPagoAdelantado] ( @idMovimiento  int, @CodMoneda  varchar(5))
RETURNS  numeric(38,2)
as 
    begin
        DECLARE @Saldo AS  numeric(38,2);
SET @Saldo = ( SELECT SUM(F.Monto) FROM(
SELECT     Ingreso AS Monto 
FROM         CAJ_CAJA_MOVIMIENTOS
where id_Movimiento = @idMovimiento and Cod_MonedaIng = @CodMoneda
UNION
SELECT -1*SUM(EGRESO) as Monto
FROM CAJ_CAJA_MOVIMIENTOS
WHERE Id_MovimientoRef = @idMovimiento and Cod_MonedaEgr = @CodMoneda
UNION
SELECT -1*SUM(Monto) as Monto
FROM CAJ_FORMA_PAGO
WHERE Id_Movimiento = @idMovimiento and Cod_Moneda = @CodMoneda) AS F
        );
return @Saldo;
    end
go
-- Traer Todo USP_CAJ_FORMA_PAGO_TXPagoAdelantado 1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_TXPagoAdelantado' AND type = 'P')
DROP PROCEDURE USP_CAJ_FORMA_PAGO_TXPagoAdelantado
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_TXPagoAdelantado
@id_ClienteProveedor as Int

WITH ENCRYPTION
AS
BEGIN
SELECT     CM.id_Movimiento, CM.Des_Movimiento + ' Saldo: ['+CONVERT( varchar,dbo.UFN_PRI_CLIENTEPROVEEDOR_SaldoPagoAdelantado(CM.id_Movimiento,Cod_MonedaIng))+']' as Des_Movimiento
FROM  CAJ_CAJA_MOVIMIENTOS AS CM
WHERE  (CM.Id_Concepto = 9000) and cm.Id_ClienteProveedor = @id_ClienteProveedor
and dbo.UFN_PRI_CLIENTEPROVEEDOR_SaldoPagoAdelantado(CM.id_Movimiento,Cod_MonedaIng) > 0
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_TXCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_MEDICION_TXCajaTurno
go
CREATE PROCEDURE USP_CAJ_MEDICION_TXCajaTurno
@Cod_Caja AS  varchar(32),
@Cod_Turno AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @ColumnasCabecera Nvarchar(MAX)
DECLARE @ColumnasPivot Nvarchar(MAX)
DECLARE @ScriptVista Nvarchar(MAX)
 SET @ColumnasCabecera = STUFF(( SELECT  '",[' +   Cod_Manguera + '] AS "'
                                                + substring(M.Cod_Manguera,2,len(M.Cod_Manguera)-1) 
FROM   VIS_MANGUERAS AS M INNER JOIN
                      VIS_SURTIDORES AS S ON M.Cod_Surtidor = S.Cod_Surtidor
                      where S.Cod_Caja = @Cod_Caja
                                      FOR
                                        XML PATH('')
                                      ), 1, 2, '') + '"'

SET @ColumnasPivot = STUFF(( SELECT '],[' + M.Cod_Manguera
FROM   VIS_MANGUERAS AS M INNER JOIN
VIS_SURTIDORES AS S ON M.Cod_Surtidor = S.Cod_Surtidor
where S.Cod_Caja = @Cod_Caja
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ']'
PRINT @ColumnasCabecera;
PRINT @ColumnasPivot;

SET @ScriptVista = N'SELECT Descripcion, ' + @ColumnasCabecera + '
FROM 
(-- MEDICION ANTERIOR
SELECT   ''MEDICION ANTERIOR'' AS Descripcion,  ISNULL(M.Cod_AMedir, MA.Cod_Manguera) AS Cod_AMedir, ISNULL(M.Medida_Anterior, 0.0) AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN
                      VIS_MANGUERAS AS MA ON M.Cod_AMedir = MA.Cod_Manguera INNER JOIN
                      VIS_SURTIDORES AS S ON MA.Cod_Surtidor = S.Cod_Surtidor
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''CONTOMETRO'') AND (MA.Estado = 1) AND S.Cod_Caja = '''+@Cod_Caja+'''
UNION
-- MEDICION ACTUAL
 SELECT   ''MEDICION ACTUAL'' AS Descripcion,  ISNULL(M.Cod_AMedir, MA.Cod_Manguera) AS Cod_AMedir, ISNULL(M.Medida_Actual, 0.0) AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN
                      VIS_MANGUERAS AS MA ON M.Cod_AMedir = MA.Cod_Manguera INNER JOIN
                      VIS_SURTIDORES AS S ON MA.Cod_Surtidor = S.Cod_Surtidor
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''CONTOMETRO'') AND (MA.Estado = 1) AND S.Cod_Caja = '''+@Cod_Caja+'''
UNION                     
-- SALIDA REAL
SELECT   ''SALIDA REAL'' AS Descripcion,  ISNULL(M.Cod_AMedir, MA.Cod_Manguera) AS Cod_AMedir, ISNULL(M.Medida_Actual, 0.0) - ISNULL(M.Medida_Anterior, 0.0) AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN
                      VIS_MANGUERAS AS MA ON M.Cod_AMedir = MA.Cod_Manguera INNER JOIN
                      VIS_SURTIDORES AS S ON MA.Cod_Surtidor = S.Cod_Surtidor
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''CONTOMETRO'') AND (MA.Estado = 1)  AND S.Cod_Caja = '''+@Cod_Caja+'''
UNION
-- SERAFIN
SELECT     ''SERAFIN'' AS Descripcion, D.Cod_Manguera AS Cod_AMedir, SUM(D.Cantidad) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE     (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''') AND (P.Cod_TipoComprobante = ''SE'')
GROUP BY D.Cod_Manguera
UNION
-- CONSUMO INTERNO
SELECT     ''CONSUMO INTERNO'' AS Descripcion, D.Cod_Manguera AS Cod_AMedir, SUM(D.Despachado) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE     (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''') AND (P.Cod_TipoComprobante = ''CI'')
GROUP BY D.Cod_Manguera 
UNION
-- TOTAL SISTEMA
SELECT     ''TOTAL SISTEMA'' AS Descripcion, D.Cod_Manguera AS Cod_AMedir, SUM(D.Cantidad) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE  P.Cod_Libro =''14'' AND P.Flag_Despachado = 1 AND  (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''')
GROUP BY D.Cod_Manguera
UNION
-- TOTAL VENTA
SELECT     ''TOTAL VENTA'' AS Descripcion, D.Cod_Manguera AS Cod_AMedir, SUM(D.Sub_Total) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE   P.Cod_Libro =''14'' AND P.Flag_Despachado = 1 AND   (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''')
GROUP BY D.Cod_Manguera) AS P
-- 
PIVOT
(
SUM (P.Valor)
FOR P.Cod_AMedir IN
( '+@ColumnasPivot+' )
) AS pvt';
EXECUTE(@ScriptVista);

END
go
-- Traer Todo  USP_CAJ_MEDICION_TANQUESXCajaTurno 'ISLA01','19/02/2013'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_TANQUESXCajaTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_MEDICION_TANQUESXCajaTurno
go
CREATE PROCEDURE USP_CAJ_MEDICION_TANQUESXCajaTurno
@Cod_Caja AS  varchar(32),
@Cod_Turno AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @ColumnasCabecera Nvarchar(MAX)
DECLARE @ColumnasPivot Nvarchar(MAX)
DECLARE @ScriptVista Nvarchar(MAX)
 SET @ColumnasCabecera = STUFF(( SELECT     '",[' + A.Cod_Almacen + '] AS "' + A.Cod_Almacen 
FROM         ALM_ALMACEN AS A INNER JOIN
                      CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                      where ca.Cod_Caja = @Cod_Caja and A.Cod_TipoAlmacen = '03'
                                      FOR
                                        XML PATH('')
                                      ), 1, 2, '') + '"'

SET @ColumnasPivot = STUFF(( SELECT '],[' + A.Cod_Almacen
FROM         ALM_ALMACEN AS A INNER JOIN
                      CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                      where ca.Cod_Caja = @Cod_Caja and A.Cod_TipoAlmacen = '03'
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ']'
PRINT @ColumnasCabecera;
PRINT @ColumnasPivot;

SET @ScriptVista = N'SELECT Descripcion, ' + @ColumnasCabecera + '
FROM 
(-- MEDICION ANTERIOR
SELECT   ''MEDICION ANTERIOR'' AS Descripcion,  ISNULL(M.Cod_AMedir, A.Cod_Almacen) AS Cod_AMedir, ISNULL(M.Medida_Anterior, 0.0) AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN                      
                      ALM_ALMACEN AS A ON M.Cod_AMedir = A.Cod_Almacen
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''TANQUE'')  --AND Cod_AMedir = '''+@Cod_Caja+'''
UNION
-- MEDICION ACTUAL
 SELECT   ''MEDICION ACTUAL'' AS Descripcion,  ISNULL(M.Cod_AMedir, A.Cod_Almacen) AS Cod_AMedir, ISNULL(M.Medida_Actual, 0.0) AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN                      
                      ALM_ALMACEN AS A ON M.Cod_AMedir = A.Cod_Almacen
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''TANQUE'') --AND Cod_AMedir = '''+@Cod_Caja+'''
UNION                     
-- SALIDA REAL
SELECT   ''SALIDA REAL'' AS Descripcion,  ISNULL(M.Cod_AMedir, A.Cod_Almacen) AS Cod_AMedir, ISNULL(M.Medida_Anterior, 0.0)-ISNULL(M.Medida_Actual, 0.0)  AS Valor
FROM         CAJ_MEDICION_VC AS M INNER JOIN                      
                      ALM_ALMACEN AS A ON M.Cod_AMedir = A.Cod_Almacen
WHERE     (M.Cod_Turno = '''+@Cod_Turno+''') AND (M.Medio_AMedir = ''TANQUE'')  --AND Cod_AMedir = '''+@Cod_Caja+'''
UNION
-- TOTAL SISTEMA
SELECT     ''TOTAL SISTEMA'' AS Descripcion, D.Cod_Almacen AS Cod_AMedir, SUM(D.Cantidad) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE  P.Cod_Libro =''14'' AND P.Flag_Despachado = 1 AND    (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''')
GROUP BY D.Cod_Almacen
UNION
-- TOTAL VENTA
SELECT     ''TOTAL VENTA'' AS Descripcion, D.Cod_Almacen AS Cod_AMedir, SUM(D.Sub_Total) AS Valor
FROM         CAJ_COMPROBANTE_D AS D INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
WHERE  P.Cod_Libro =''14'' AND P.Flag_Despachado = 1 AND    (P.Cod_Turno = '''+@Cod_Turno+''') AND (P.Cod_Caja = '''+@Cod_Caja+''')
GROUP BY D.Cod_Almacen) AS P
-- 
PIVOT
(
SUM (P.Valor)
FOR P.Cod_AMedir IN
( '+@ColumnasPivot+' )
) AS pvt';
EXECUTE(@ScriptVista);

END
go
---------------------------------------------------------------------------------------------------------------
-- USP_CUE_CLIENTE_CUENTA_SNumCuenta '2049','102','COR'
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CUE_CLIENTE_CUENTA_SNumCuenta'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_SNumCuenta
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_SNumCuenta
    @Cod_Empresa  varchar(3) ,
    @Nom_TipoCuenta  varchar(3),
@Cod_TipoCuenta  varchar(3)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT  @Cod_Empresa + '-' + @Nom_TipoCuenta + '-' + RIGHT('000000'
                                                              + CAST(ISNULL(COUNT(*),
                                                              0) + 1 AS  varchar(6)),
                                                              6) + '-'
                + dbo.UFN_PRI_CUENTA_DV(@Cod_Empresa + @Nom_TipoCuenta
                                        + RIGHT('000000'
                                                + CAST(ISNULL(COUNT(*), 0) + 1 AS  varchar(6)),
                                                6)) as Cod_Cuenta
        FROM    CUE_CLIENTE_CUENTA
        WHERE   Cod_TipoCuenta = @Cod_TipoCuenta
    END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_UNIDADES_DE_MEDIDA_TXTipo' AND type = 'P')
DROP PROCEDURE USP_VIS_UNIDADES_DE_MEDIDA_TXTipo
go

CREATE PROCEDURE USP_VIS_UNIDADES_DE_MEDIDA_TXTipo
@Tipo as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     Cod_UnidadMedida, Nom_UnidadMedida
FROM         VIS_UNIDADES_DE_MEDIDA
where Tipo = @Tipo and Estado = 1
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_UNIDADES_DE_MEDIDA_TPK' AND type = 'P')
DROP PROCEDURE USP_VIS_UNIDADES_DE_MEDIDA_TPK
go

CREATE PROCEDURE USP_VIS_UNIDADES_DE_MEDIDA_TPK
@Cod_UnidadMedida as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT     Nom_UnidadMedida
FROM         VIS_UNIDADES_DE_MEDIDA
where Cod_UnidadMedida = @Cod_UnidadMedida
END
GO
-- Traer Todo   USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacenUnidad 5,'ALMACEN_CENTRAL','UNI'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacenUnidad' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacenUnidad
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXProductoAlmacenUnidad
@Id_Producto as   int,
@Cod_Almacen as  varchar(32),
@Cod_UnidadMedida as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT   distinct  PP.Cod_TipoPrecio, 
VP.Nom_Precio+'['+ CONVERT( varchar(20),CONVERT( numeric(38,2), PP.Valor)) +']' AS Nom_Precio
FROM         PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                      VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
WHERE pp.Id_Producto = @Id_Producto 
and (@Cod_Almacen = pp.Cod_Almacen or @Cod_Almacen is null)
and (@Cod_UnidadMedida = pp.Cod_UnidadMedida or @Cod_UnidadMedida is null )
and (PP.Valor <> 0)

END
go
-- Traer Precio por Almacen unidad de medida y tipo de precio
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TPrecioXProductoAlmacenUnidadTipo' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPrecioXProductoAlmacenUnidadTipo
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPrecioXProductoAlmacenUnidadTipo
@Id_Producto as   int,
@Cod_Almacen as  varchar(32),
@Cod_UnidadMedida as  varchar(32),
@Cod_TipoPrecio as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
 IF EXISTS(SELECT     Valor
FROM         PRI_PRODUCTO_PRECIO AS PP
WHERE pp.Id_Producto = @Id_Producto 
and (@Cod_Almacen = pp.Cod_Almacen)
and (@Cod_UnidadMedida = pp.Cod_UnidadMedida)
AND PP.Cod_TipoPrecio = @Cod_TipoPrecio)
BEGIN
SELECT     Valor
FROM         PRI_PRODUCTO_PRECIO AS PP
WHERE pp.Id_Producto = @Id_Producto 
and (@Cod_Almacen = pp.Cod_Almacen)
and (@Cod_UnidadMedida = pp.Cod_UnidadMedida)
AND PP.Cod_TipoPrecio = @Cod_TipoPrecio
END
ELSE
BEGIN
  SELECT     Precio_Venta
FROM         PRI_PRODUCTO_STOCK AS PP
WHERE pp.Id_Producto = @Id_Producto 
and (@Cod_Almacen = pp.Cod_Almacen)
and (@Cod_UnidadMedida = pp.Cod_UnidadMedida)
END
END
go
-- Traer Todo USP_PRI_PRODUCTO_TUnidadMedidaXProductoAlmacen 5,'ALMACEN_CENTRAL'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_TUnidadMedidaXProductoAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_TUnidadMedidaXProductoAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_TUnidadMedidaXProductoAlmacen
@Id_Producto AS  int,
@Cod_Almacen as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT DISTINCT PRI_PRODUCTO_STOCK.Cod_UnidadMedida, Id_Producto,Cod_Almacen,
VIS_UNIDADES_DE_MEDIDA.Nom_UnidadMedida +' ['+ 
CONVERT( varchar(32),CONVERT( numeric(38,2),PRI_PRODUCTO_STOCK.Cantidad_Min)) +']' as Nom_UnidadMedida
FROM         PRI_PRODUCTO_STOCK INNER JOIN
                      VIS_UNIDADES_DE_MEDIDA ON PRI_PRODUCTO_STOCK.Cod_UnidadMedida = VIS_UNIDADES_DE_MEDIDA.Cod_UnidadMedida
WHERE @Id_Producto = Id_Producto and @Cod_Almacen = Cod_Almacen
END
go
-- Traer Todo USP_CAJ_CAJA_ALMACEN_TXCaja '100'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_ALMACEN_TXCaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_TXCaja
go
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_TXCaja
@Cod_Caja as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        CA.Cod_Almacen, AL.Des_Almacen
FROM            CAJ_CAJA_ALMACEN AS CA INNER JOIN
                         ALM_ALMACEN AS AL ON CA.Cod_Almacen = AL.Cod_Almacen
WHERE        (CA.Cod_Caja = @Cod_Caja)
END
go
-- Este Autoriza el Movimiento
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_AutorizarMovimiento' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_AutorizarMovimiento
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_AutorizarMovimiento
@id_Movimiento as  int,
@Cod_Usuario as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
update CAJ_CAJA_MOVIMIENTOS
SET Cod_UsuarioAut = @Cod_Usuario, Fecha_Aut = GETDATE(), Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
WHERE id_Movimiento = @id_Movimiento
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_LIMITES_AUTORIZACION_Autorizar' AND type = 'P')
DROP PROCEDURE USP_VIS_LIMITES_AUTORIZACION_Autorizar
go
CREATE PROCEDURE USP_VIS_LIMITES_AUTORIZACION_Autorizar
@Cod_TipoComprobante as  varchar(5),
@Cod_Moneda as  varchar(5),
@Monto as  numeric(38,2)
WITH ENCRYPTION
AS
BEGIN
SELECT * FROM VIS_LIMITES_AUTORIZACION
WHERE Cod_TipoDocInt = @Cod_TipoComprobante AND @Monto >= Monto_Max and Cod_Moneda = @Cod_Moneda and Estado = 1
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_TIPO_COMPROBANTES_TXLibro' AND type = 'P')
DROP PROCEDURE USP_VIS_TIPO_COMPROBANTES_TXLibro
go
CREATE PROCEDURE USP_VIS_TIPO_COMPROBANTES_TXLibro
@Cod_Liro as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
IF (@Cod_Liro = '08')
SELECT Cod_TipoComprobante,Nom_TipoComprobante, Flag_Compras, Flag_Ventas
FROM VIS_TIPO_COMPROBANTES 
WHERE Flag_Compras = 1 AND Estado = 1
ELSE
SELECT Cod_TipoComprobante,Nom_TipoComprobante, Flag_Compras, Flag_Ventas 
FROM VIS_TIPO_COMPROBANTES 
WHERE Flag_Ventas = 1 AND Estado = 1
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TXIdClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TXIdClienteProveedor
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TXIdClienteProveedor
@Id_ClienteProveedor int
WITH ENCRYPTION
AS
BEGIN
SELECT        CC.Cod_Cuenta, CC.Id_ClienteProveedor, CC.Des_Cuenta, CC.Cod_TipoCuenta, CC.Monto_Deposito, CC.Interes, CC.MesesMax, CC.Limite_Max, CC.Flag_ITF, 
                         CC.Cod_Moneda, CC.Cod_EstadoCuenta, CC.Saldo_Contable, CC.Saldo_Disponible, 
                         VTC.Nom_TipoCuenta, VTDC.Nom_EstadoCuenta, VM.Nom_Moneda
FROM            CUE_CLIENTE_CUENTA AS CC INNER JOIN
                         VIS_TIPO_CUENTA_BANCO AS VTC ON CC.Cod_TipoCuenta = VTC.Cod_TipoCuenta INNER JOIN
                         VIS_ESTADO_CUENTA AS VTDC ON CC.Cod_EstadoCuenta = VTDC.Cod_EstadoCuenta INNER JOIN
                         VIS_MONEDAS AS VM ON CC.Cod_Moneda = VM.Cod_Moneda
where Id_ClienteProveedor = @Id_ClienteProveedor and CC.Cod_EstadoCuenta <> '005'
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TXIdClienteCombo' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TXIdClienteCombo
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TXIdClienteCombo
@Id_ClienteProveedor int
WITH ENCRYPTION
AS
BEGIN
SELECT        CC.Cod_Cuenta, CC.Cod_Cuenta+': '+CC.Des_Cuenta + 
'['+convert( varchar(32),case cc.Cod_TipoCuenta when 'CUS' then cc.Monto_Deposito else cc.Saldo_Disponible end)+']'  as Des_Cuenta
FROM            CUE_CLIENTE_CUENTA AS CC INNER JOIN
                         VIS_MONEDAS AS VM ON CC.Cod_Moneda = VM.Cod_Moneda
WHERE        (CC.Id_ClienteProveedor = @Id_ClienteProveedor) AND (CC.Cod_EstadoCuenta <> '005')
order by fecha_reg
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_ALMACEN' ) 
    DROP VIEW VIS_ALMACEN
go
CREATE VIEW VIS_ALMACEN
WITH ENCRYPTION
AS
SELECT        ALM_ALMACEN.Cod_Almacen, ALM_ALMACEN.Des_Almacen, ALM_ALMACEN.Des_CortaAlmacen, ALM_ALMACEN.Cod_TipoAlmacen, 
                         VIS_TIPO_ALMACENES.Nom_TipoAlmacen, ALM_ALMACEN.Flag_Principal, ALM_ALMACEN.Cod_UsuarioReg, ALM_ALMACEN.Fecha_Reg, 
                         ALM_ALMACEN.Cod_UsuarioAct, ALM_ALMACEN.Fecha_Act
FROM            ALM_ALMACEN INNER JOIN
                         VIS_TIPO_ALMACENES ON ALM_ALMACEN.Cod_TipoAlmacen = VIS_TIPO_ALMACENES.Cod_TipoAlmacen
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_TP' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_TP
go
CREATE PROCEDURE USP_ALM_ALMACEN_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Cod_Almacen , Des_Almacen , Des_CortaAlmacen , Cod_TipoAlmacen, Nom_TipoAlmacen , Flag_Principal , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
FROM (SELECT TOP 100 PERCENT Cod_Almacen , Des_Almacen , Des_CortaAlmacen , Cod_TipoAlmacen, Nom_TipoAlmacen , Flag_Principal , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_ALMACEN '+@ScripWhere+') aALM_ALMACEN
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_SiguienteItem' AND type = 'P')
DROP PROCEDURE USP_CAJ_FORMA_PAGO_SiguienteItem
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_SiguienteItem
@id_ComprobantePago int
WITH ENCRYPTION
AS
BEGIN
SELECT isnull(max(Item)+1,1)
FROM CAJ_FORMA_PAGO
where id_ComprobantePago = @id_ComprobantePago
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_TSiguienteNumero' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_MOV_TSiguienteNumero
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_TSiguienteNumero
@Cod_TipoComprobante as  varchar(5),
@Serie as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT isnull(max(Numero)+1,1)
FROM ALM_ALMACEN_MOV
where Cod_TipoComprobante = @Cod_TipoComprobante and Serie = @Serie
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUCURSAL_TDistintoDe' AND type = 'P')
DROP PROCEDURE USP_PRI_SUCURSAL_TDistintoDe
go
CREATE PROCEDURE USP_PRI_SUCURSAL_TDistintoDe
@Cod_Sucursal AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Sucursal , Nom_Sucursal 
FROM PRI_SUCURSAL
WHERE Cod_Sucursal <> @Cod_Sucursal
END
go
-- USP_CAJ_CAJA_MOVIMIENTOS_TLimite 'RE','PEN',1999
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_TLimite' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TLimite
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TLimite
@Cod_TipoComprobante as  varchar(5),
@Cod_Moneda as  varchar(5),
@Monto as  numeric(38,8)
WITH ENCRYPTION
AS
BEGIN
SELECT Nro, Cod_Comision, Cod_TipoDocint, Monto_Max, Cod_Moneda, Estado
FROM       VIS_LIMITES_AUTORIZACION
where @Cod_TipoComprobante = Cod_TipoDocInt and Cod_Moneda = @Cod_Moneda
and  @Monto >= Monto_Max
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_TAutorizado' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TAutorizado
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TAutorizado
@id_Movimiento as int
WITH ENCRYPTION
AS
BEGIN
SELECT id_Movimiento
FROM CAJ_CAJA_MOVIMIENTOS
where id_Movimiento = @id_Movimiento and (Cod_UsuarioAut IS NOT NULL or Cod_UsuarioAut <> '')
END
go

-- TRAER tipo de operaciopnes segun el tipo de documento
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_TIPO_OPERACIONES_TXComprobante' AND type = 'P')
DROP PROCEDURE USP_VIS_TIPO_OPERACIONES_TXComprobante
go
CREATE PROCEDURE USP_VIS_TIPO_OPERACIONES_TXComprobante
@Cod_TipoComprobante as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT        Cod_TipoOperacion, Nom_TipoOperacion
FROM            VIS_TIPO_OPERACIONES
WHERE Cod_TipoComprobante = @Cod_TipoComprobante
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_PadreCategorias') 
    DROP FUNCTION UFN_PadreCategorias
go
CREATE FUNCTION UFN_PadreCategorias ( @Cod_Categoria AS  varchar(32) )
RETURNS  @CategoriaPadre TABLE 
(
    Cod_Categoria Nvarchar(32) NOT NULL
)

    WITH ENCRYPTION
AS 
    BEGIN

WITH CATEGORIAS (Cod_Categoria, Des_Categoria,Cod_CategoriaPadre, Level)
AS
(
	select Cod_Categoria,Des_Categoria,Cod_CategoriaPadre, 0 as Level 
	from PRI_CATEGORIA
	where Cod_Categoria = @Cod_Categoria
	UNION ALL
	select c.Cod_Categoria,c.Des_Categoria,c.Cod_CategoriaPadre, Level + 1 
	from PRI_CATEGORIA AS C INNER JOIN CATEGORIAS AS CA
	on  CA.Cod_CategoriaPadre = c.Cod_Categoria 
) insert @CategoriaPadre
	SELECT top 1 CA.Cod_Categoria
	from CATEGORIAS AS CA INNER JOIN PRI_CATEGORIA AS C
	ON C.Cod_Categoria = CA.Cod_Categoria
ORDER BY Level desc

return
end
GO
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_PadreCategoria') 
    DROP FUNCTION dbo.UFN_PadreCategoria
go
CREATE FUNCTION dbo.UFN_PadreCategoria ( @Cod_Categoria AS  varchar(32) )
RETURNS  varchar(512)
WITH ENCRYPTION
AS 
BEGIN
DECLARE @Cod_CategoriaPadre as  varchar(512);
set @Cod_CategoriaPadre = (SELECT        TOP (1) C.Des_Categoria
FROM            dbo.UFN_PadreCategorias(@Cod_Categoria) AS Padre inner JOIN
                         PRI_CATEGORIA AS C on padre.Cod_Categoria = c.Cod_Categoria)
return @Cod_CategoriaPadre;
END
GO
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_D_TxCod_Cuenta' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_TxCod_Cuenta
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_TxCod_Cuenta
@Cod_Cuenta AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Cuenta , item , Des_CuentaD , Monto , Fecha_Emision , Fecha_Vencimiento , Cod_EstadoDCuenta  
FROM CUE_CLIENTE_CUENTA_D
WHERE Cod_Cuenta = @Cod_Cuenta
END
go
 -- USP_VIS_COMISION_TXMonedaMonto 500,'PEN'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_COMISION_TXMonedaMonto' AND type = 'P')
DROP PROCEDURE USP_VIS_COMISION_TXMonedaMonto
go
CREATE PROCEDURE USP_VIS_COMISION_TXMonedaMonto
    @Monto as  numeric(38,2),
@Cod_Moneda as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT  isnull(case Tipo 
when 'PORCENTAJE' then  Monto_Porcentaje * @Monto / 100
when 'MONTO' THEN Monto_Porcentaje 
ELSE Monto_Porcentaje END, 0)
FROM            VIS_COMISION
where Cod_Moneda=@Cod_Moneda and @Monto between Monto_Min and Monto_Max
END
go
 -- USP_VIS_COMISION_TELEGIRO_TXMonedaMonto 500,'PEN'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_COMISION_TELEGIRO_TXMonedaMonto' AND type = 'P')
DROP PROCEDURE USP_VIS_COMISION_TELEGIRO_TXMonedaMonto
go
CREATE PROCEDURE USP_VIS_COMISION_TELEGIRO_TXMonedaMonto
    @Monto as  numeric(38,2),
@Cod_Moneda as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT  isnull(case Tipo 
when 'PORCENTAJE' then  Monto_Porcentaje * @Monto / 100
when 'MONTO' THEN Monto_Porcentaje 
ELSE Monto_Porcentaje END, 0)
FROM            VIS_COMISION_TELEGIRO
where Cod_Moneda=@Cod_Moneda and @Monto between Monto_Min and Monto_Max
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_TPrecioCompraAlmacen' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TPrecioCompraAlmacen
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TPrecioCompraAlmacen
WITH ENCRYPTION
AS
BEGIN
SELECT        PS.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, PS.Precio_Compra, A.Des_Almacen, PS.Stock_Act, S.Por_UtilidadMin AS Porcentaje
FROM            PRI_PRODUCTO_STOCK AS PS INNER JOIN
                         ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen INNER JOIN
                         CAJ_CAJAS AS C ON CA.Cod_Caja = C.Cod_Caja INNER JOIN
                         PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
where C.Flag_Activo = 1
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_TDistintoDe' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_TDistintoDe
go
CREATE PROCEDURE USP_ALM_ALMACEN_TDistintoDe
@Cod_Almacen as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Almacen , Des_Almacen 
FROM ALM_ALMACEN
where Cod_Almacen <> @Cod_Almacen
END
go
-- Traer Documentos por Caja USP_CAJ_CAJA_ALMACEN_TSerieXCod_Almacen 'A401'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_ALMACEN_TSerieXCod_Almacen' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_TSerieXCod_Almacen
go
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_TSerieXCod_Almacen
@Cod_Almacen as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT  distinct      CD.Cod_Caja, CD.Item, CD.Cod_TipoComprobante, CD.Serie, CD.Impresora, CD.Flag_Imprimir, CD.Nom_Archivo, CD.Nro_SerieTicketera, 
                         TC.Nom_TipoComprobante, TC.Cod_Sunat, TC.Flag_Ventas, TC.Flag_Compras, CD.Flag_FacRapida, CA.Cod_Almacen
FROM            CAJ_CAJAS_DOC AS CD INNER JOIN
                         VIS_TIPO_COMPROBANTES AS TC ON CD.Cod_TipoComprobante = TC.Cod_TipoComprobante INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON CD.Cod_Caja = CA.Cod_Caja
WHERE     (CA.Cod_Almacen = @Cod_Almacen)
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_TT' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_MOV_TT
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_TT
@Cod_Turno as  varchar(32)

WITH ENCRYPTION
AS
BEGIN
SELECT        AM.Id_AlmacenMov, AM.Cod_Almacen, AM.Cod_TipoOperacion, AM.Cod_Turno, AM.Cod_TipoComprobante, AM.Serie, AM.Numero, AM.Fecha, AM.Motivo, 
                         AM.Flag_Anulado, AMD.Des_Producto, AMD.Precio_Unitario, AMD.Cantidad, AMD.Cod_UnidadMedida, VUM.Nom_UnidadMedida
                         
FROM            ALM_ALMACEN_MOV AS AM INNER JOIN
                         ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VUM ON AMD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
WHERE Flag_Anulado = 0 AND AM.Id_ComprobantePago = 0 and Cod_Turno = @Cod_Turno

SELECT        CONVERT( varchar(20),CP.FechaEmision,103), VTC.Cod_Sunat, CP.Serie, CP.Numero, CP.Nom_Cliente, ROUND(CD.Cantidad,2), ROUND(CD.PrecioUnitario,2), CD.Sub_Total
FROM            CAJ_COMPROBANTE_D AS CD INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago INNER JOIN
                         VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
WHERE Cod_Libro = '08' AND Cod_Turno = @Cod_Turno
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_TActivos' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_TActivos
go
CREATE PROCEDURE USP_CAJ_CAJAS_TActivos
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Caja , Des_Caja 
FROM CAJ_CAJAS
where Flag_Activo = 1;
END
go
-- Actualizar saldo Actual de la Cuenta
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_ActualizarSaldo' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_ActualizarSaldo
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_ActualizarSaldo 
@Cod_CuentaBancaria  varchar(32), 
@Monto  numeric(38,2),
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
UPDATE BAN_CUENTA_BANCARIA
SET
Saldo_Disponible += @Monto,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Cod_CuentaBancaria = @Cod_CuentaBancaria)
END
go
-- Actualizar saldo Actual de la Cuenta
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UTR_BAN_CUENTA_M_INSERT')
DROP TRIGGER UTR_BAN_CUENTA_M_INSERT
go
CREATE TRIGGER UTR_BAN_CUENTA_M_INSERT
   ON  BAN_CUENTA_M
   AFTER INSERT
AS 
BEGIN
UPDATE BAN_CUENTA_BANCARIA
SET
Saldo_Disponible += (SELECT Monto from inserted),
Cod_UsuarioAct = (SELECT Cod_UsuarioReg from inserted), 
Fecha_Act = GETDATE()
WHERE (Cod_CuentaBancaria = (SELECT Cod_CuentaBancaria from inserted))
END
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UTR_BAN_CUENTA_M_UPDATE')
DROP TRIGGER UTR_BAN_CUENTA_M_UPDATE
go
CREATE TRIGGER UTR_BAN_CUENTA_M_UPDATE
   ON  BAN_CUENTA_M
   AFTER UPDATE
AS 
BEGIN
UPDATE BAN_CUENTA_BANCARIA
SET
Saldo_Disponible -= (SELECT Monto from deleted)
WHERE (Cod_CuentaBancaria = (SELECT Cod_CuentaBancaria from deleted))

UPDATE BAN_CUENTA_BANCARIA
SET
Saldo_Disponible += (SELECT Monto from inserted),
Cod_UsuarioAct = (SELECT Cod_UsuarioReg from inserted), 
Fecha_Act = GETDATE()
WHERE (Cod_CuentaBancaria = (SELECT Cod_CuentaBancaria from inserted))
END
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UTR_BAN_CUENTA_M_DELETE')
DROP TRIGGER UTR_BAN_CUENTA_M_DELETE
go
CREATE TRIGGER UTR_BAN_CUENTA_M_DELETE
   ON  BAN_CUENTA_M
   AFTER DELETE
AS 
BEGIN
UPDATE BAN_CUENTA_BANCARIA
SET
Saldo_Disponible -= (SELECT Monto from deleted),
Cod_UsuarioAct = (SELECT Cod_UsuarioReg from deleted), 
Fecha_Act = GETDATE()
WHERE (Cod_CuentaBancaria = (SELECT Cod_CuentaBancaria from deleted))
END
GO

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_G' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_MOV_G
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_G 
@Id_AlmacenMov int output, 
@Cod_Almacen  varchar(32), 
@Cod_TipoOperacion  varchar(5), 
@Cod_Turno  varchar(32), 
@Cod_TipoComprobante  varchar(5), 
@Serie  varchar(5) output, 
@Numero  varchar(32) output, 
@Fecha  datetime, 
@Motivo  varchar(512), 
@Id_ComprobantePago  int, 
@Flag_Anulado  bit,
@Obs_AlmacenMov xml,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN

IF CONVERT(NVARCHAR(MAX),ISNULL(@Obs_AlmacenMov,'')) = ''
BEGIN
SET @Obs_AlmacenMov = dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('ALM_ALMACEN_MOV');
END

IF NOT EXISTS (SELECT @Id_AlmacenMov FROM ALM_ALMACEN_MOV WHERE  (Id_AlmacenMov = @Id_AlmacenMov))
BEGIN
if ((@Numero is null OR @Numero = '') AND @Cod_TipoComprobante <> '')
BEGIN
if (@Serie is null OR @Serie = '')
begin
SET @Serie = (SELECT        TOP (1) CD.Serie
FROM            CAJ_CAJA_ALMACEN AS CA INNER JOIN
 CAJ_CAJAS_DOC AS CD ON CA.Cod_Caja = CD.Cod_Caja
WHERE   (CA.Cod_Almacen = @Cod_Almacen) AND (CD.Cod_TipoComprobante = @Cod_TipoComprobante))
end
SET @Numero = (SELECT TOP 1 RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(NUMERO)),0)+1), 8) 
FROM ALM_ALMACEN_MOV WHERE Serie = @Serie AND Cod_TipoComprobante=@Cod_TipoComprobante)
END
INSERT INTO ALM_ALMACEN_MOV  VALUES (
@Cod_Almacen,
@Cod_TipoOperacion,
@Cod_Turno,
@Cod_TipoComprobante,
@Serie,
@Numero,
@Fecha,
@Motivo,
@Id_ComprobantePago,
@Flag_Anulado,
@Obs_AlmacenMov,
@Cod_Usuario,GETDATE(),NULL,NULL)
SET @Id_AlmacenMov = @@IDENTITY 
END
ELSE
BEGIN
UPDATE ALM_ALMACEN_MOV
SET
Cod_Almacen = @Cod_Almacen, 
Cod_TipoOperacion = @Cod_TipoOperacion, 
Cod_Turno = @Cod_Turno, 
Cod_TipoComprobante = @Cod_TipoComprobante, 
Serie = @Serie, 
Numero = @Numero, 
Fecha = @Fecha, 
Motivo = @Motivo, 
Id_ComprobantePago = @Id_ComprobantePago, 
Flag_Anulado = @Flag_Anulado,
Obs_AlmacenMov= @Obs_AlmacenMov,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Id_AlmacenMov = @Id_AlmacenMov)
END
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_TXTipoSerieNumero' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TXTipoSerieNumero
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_TXTipoSerieNumero
@Cod_TipoComprobante as  varchar(5),
@Serie as  varchar(5),
@Numero as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT id_Movimiento
FROM CAJ_CAJA_MOVIMIENTOS
where Cod_TipoComprobante=@Cod_TipoComprobante and Serie = @Serie and Numero= @Numero
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CUE_CLIENTE_CUENTA_D_PK' AND type = 'P')
DROP PROCEDURE URP_CUE_CLIENTE_CUENTA_D_PK
go
CREATE PROCEDURE URP_CUE_CLIENTE_CUENTA_D_PK
@Cod_Cuenta as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        CC.Cod_Cuenta, CC.Id_ClienteProveedor, CC.Des_Cuenta, CC.Cod_TipoCuenta, CC.Monto_Deposito, CC.Interes, CC.MesesMax, CC.Limite_Max, CC.Flag_ITF, 
		 CC.Cod_Moneda, CC.Cod_EstadoCuenta, CC.Saldo_Contable, CC.Saldo_Disponible, PCP.Cod_TipoDocumento, 
		 PCP.Nro_Documento, PCP.Cliente, VTD.Nom_TipoDoc, PCP.Direccion, PCP.Cod_Sexo, VS.Nom_Sexo, PCP.Email1, PCP.Email2, PCP.Telefono1, 
		 PCP.Telefono2, PCP.Obs_Cliente, CCD.item, CCD.Des_CuentaD, CCD.Monto, CCD.Fecha_Vencimiento, CCD.Fecha_Emision, CCD.Cod_EstadoDCuenta, 
		 VEDC.Nom_EstadoDCuenta, VM.Nom_Moneda, VM.Simbolo, VM.Definicion
FROM            CUE_CLIENTE_CUENTA AS CC INNER JOIN
		 PRI_CLIENTE_PROVEEDOR AS PCP ON CC.Id_ClienteProveedor = PCP.Id_ClienteProveedor INNER JOIN
		 VIS_TIPO_DOCUMENTOS AS VTD ON PCP.Cod_TipoDocumento = VTD.Cod_TipoDoc INNER JOIN
		 VIS_SEXOS AS VS ON PCP.Cod_Sexo = VS.Cod_Sexo INNER JOIN
		 CUE_CLIENTE_CUENTA_D AS CCD ON CC.Cod_Cuenta = CCD.Cod_Cuenta INNER JOIN
		 VIS_ESTADO_D_CUENTA AS VEDC ON CCD.Cod_EstadoDCuenta = VEDC.Cod_EstadoDCuenta INNER JOIN
		 VIS_MONEDAS AS VM ON CC.Cod_Moneda = VM.Cod_Moneda
where CC.Cod_Cuenta=@Cod_Cuenta
order by item
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_D_TxCuentaEstado' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_TxCuentaEstado
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_TxCuentaEstado
@Cod_Cuenta AS  varchar(32),
@Cod_EstadoDCuenta as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Cuenta , item , Des_CuentaD , Monto , Fecha_Emision , Fecha_Vencimiento , Cod_EstadoDCuenta , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
FROM CUE_CLIENTE_CUENTA_D
WHERE Cod_Cuenta = @Cod_Cuenta and Cod_EstadoDCuenta =  @Cod_EstadoDCuenta
END
go
-- Traer Todo
-- URP_CUE_CLIENTE_CUENTA_M_TOP20 '101-003-000002-2'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CUE_CLIENTE_CUENTA_M_TOP20' AND type = 'P')
DROP PROCEDURE URP_CUE_CLIENTE_CUENTA_M_TOP20
go
CREATE PROCEDURE URP_CUE_CLIENTE_CUENTA_M_TOP20
@Cod_Cuenta AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT    CCM.Id_ClienteCuentaMov, CCM.Cod_Cuenta, CCM.Cod_TipoMovimiento, CCM.Id_Movimiento, CCM.Des_Movimiento, CCM.Cod_MonedaIng, 
                         CCM.Ingreso, CCM.Cod_MonedaEgr, CCM.Egreso, CCM.Tipo_Cambio, CCM.Fecha, CCM.Flag_Extorno, CC.Des_Cuenta, CC.Saldo_Contable, 
                         CC.Saldo_Disponible, CP.Cliente, CA.Des_Caja
FROM            CUE_CLIENTE_CUENTA_M AS CCM INNER JOIN
                         CUE_CLIENTE_CUENTA AS CC ON CCM.Cod_Cuenta = CC.Cod_Cuenta INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CP ON CC.Id_ClienteProveedor = CP.Id_ClienteProveedor INNER JOIN
                         CAJ_CAJA_MOVIMIENTOS AS CM ON CCM.id_MovimientoCaja = CM.id_Movimiento INNER JOIN
                         CAJ_CAJAS AS CA ON CM.Cod_Caja = CA.Cod_Caja
WHERE        (CCM.Cod_Cuenta = @Cod_Cuenta)
order by CCM.Fecha_Reg DESC
END
go
-- URP_CUE_CLIENTE_CUENTA_M_TOP50
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CUE_CLIENTE_CUENTA_M_TOP50' AND type = 'P')
DROP PROCEDURE URP_CUE_CLIENTE_CUENTA_M_TOP50
go
CREATE PROCEDURE URP_CUE_CLIENTE_CUENTA_M_TOP50
@Cod_Cuenta AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT TOP 50   CCM.Id_ClienteCuentaMov, CCM.Cod_Cuenta, CCM.Cod_TipoMovimiento, CCM.Id_Movimiento, CCM.Des_Movimiento, CCM.Cod_MonedaIng, 
                         CCM.Ingreso, CCM.Cod_MonedaEgr, CCM.Egreso, CCM.Tipo_Cambio, CCM.Fecha, CCM.Flag_Extorno, CC.Des_Cuenta, CC.Saldo_Contable, 
                        case CC.cod_tipocuenta when 'CUS' THEN Monto_Deposito ELSE CC.Saldo_Disponible END AS Saldo_Disponible, CP.Cliente, CA.Des_Caja
FROM            CUE_CLIENTE_CUENTA_M AS CCM INNER JOIN
                         CUE_CLIENTE_CUENTA AS CC ON CCM.Cod_Cuenta = CC.Cod_Cuenta INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CP ON CC.Id_ClienteProveedor = CP.Id_ClienteProveedor INNER JOIN
                         CAJ_CAJA_MOVIMIENTOS AS CM ON CCM.id_MovimientoCaja = CM.id_Movimiento INNER JOIN
                         CAJ_CAJAS AS CA ON CM.Cod_Caja = CA.Cod_Caja
WHERE        (CCM.Cod_Cuenta = @Cod_Cuenta)
order by Id_Movimiento DESC
END
go
-- scrip que actualice el estado de los detalle de intres y cuotas
-- select * from CUE_CLIENTE_CUENTA where id_clienteProveedor = 47
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_D_Sincronizar' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_D_Sincronizar
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_D_Sincronizar
WITH ENCRYPTION
AS
BEGIN
set dateformat dmy;
UPDATE CUE_CLIENTE_CUENTA_D
SET Cod_EstadoDCuenta = '003'
--select * from CUE_CLIENTE_CUENTA_D
WHERE convert( datetime,convert( varchar(20),Fecha_Vencimiento,103)) < convert( datetime,convert( varchar(20),getdate(),103)) 
and (Cod_EstadoDCuenta = '002' or Cod_EstadoDCuenta = '001' ) 

UPDATE CUE_CLIENTE_CUENTA_D
SET Cod_EstadoDCuenta = '002'
--select * from CUE_CLIENTE_CUENTA_D
WHERE convert( datetime,convert( varchar(20),Fecha_Vencimiento,103)) = convert( datetime,convert( varchar(20),getdate(),103)) 
and (Cod_EstadoDCuenta = '001') 
END
go
-- Traer interes vencidos USP_CUE_CLIENTE_CUENTA_VencidosXCodCuenta '512-002-000003-1'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_VencidosXCodCuenta' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_VencidosXCodCuenta
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_VencidosXCodCuenta
@CodCuenta as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        CCD.Cod_Cuenta, CCD.Des_CuentaD + '['+VEDC.Nom_EstadoDCuenta+']' as Des_CuentaD
, CCD.item, CCD.Monto, DATEADD(day, 1, CCD.Fecha_Vencimiento) AS Vence
FROM            CUE_CLIENTE_CUENTA_D AS CCD INNER JOIN
                         VIS_ESTADO_D_CUENTA AS VEDC ON CCD.Cod_EstadoDCuenta = VEDC.Cod_EstadoDCuenta
where @CodCuenta = Cod_Cuenta AND ccd.Cod_EstadoDCuenta = '003'
ORDER BY item
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_M_G' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_M_G
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_M_G 
@Id_ClienteCuentaMov int output, 
@Cod_Cuenta  varchar(32), 
@Cod_TipoMovimiento  varchar(16), 
@Id_Movimiento  int, 
@Des_Movimiento  varchar(512), 
@Cod_MonedaIng  varchar(5), 
@Ingreso  numeric(38,2), 
@Cod_MonedaEgr  varchar(5), 
@Egreso  numeric(38,2), 
@Tipo_Cambio  numeric(10,4), 
@Fecha  datetime, 
@Flag_Extorno  bit, 
@id_MovimientoCaja  int,
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN

IF NOT EXISTS (SELECT @Id_ClienteCuentaMov FROM CUE_CLIENTE_CUENTA_M WHERE  (Id_ClienteCuentaMov = @Id_ClienteCuentaMov))
BEGIN
set @Id_Movimiento = (select isnull(MAX(Id_Movimiento)+1,1) from CUE_CLIENTE_CUENTA_M where Cod_Cuenta = @Cod_Cuenta)
INSERT INTO CUE_CLIENTE_CUENTA_M  VALUES (
@Cod_Cuenta,
@Cod_TipoMovimiento,
@Id_Movimiento,
@Des_Movimiento,
@Cod_MonedaIng,
@Ingreso,
@Cod_MonedaEgr,
@Egreso,
@Tipo_Cambio,
@Fecha,
@Flag_Extorno,
@id_MovimientoCaja,
@Cod_Usuario,GETDATE(),NULL,NULL)
SET @Id_ClienteCuentaMov = @@IDENTITY 
END
ELSE
BEGIN
UPDATE CUE_CLIENTE_CUENTA_M
SET
Cod_Cuenta = @Cod_Cuenta, 
Cod_TipoMovimiento = @Cod_TipoMovimiento, 
Id_Movimiento = @Id_Movimiento, 
Des_Movimiento = @Des_Movimiento, 
Cod_MonedaIng = @Cod_MonedaIng, 
Ingreso = @Ingreso, 
Cod_MonedaEgr = @Cod_MonedaEgr, 
Egreso = @Egreso, 
Tipo_Cambio = @Tipo_Cambio, 
Fecha = @Fecha, 
Flag_Extorno = @Flag_Extorno, 
id_MovimientoCaja = @id_MovimientoCaja,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Id_ClienteCuentaMov = @Id_ClienteCuentaMov)
END
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_CONCEPTO' ) 
    DROP VIEW VIS_CONCEPTO
go
CREATE VIEW VIS_CONCEPTO
WITH ENCRYPTION
AS
SELECT        CAJ_CONCEPTO.Id_Concepto, CAJ_CONCEPTO.Des_Concepto, CAJ_CONCEPTO.Cod_ClaseConcepto, VIS_TIPO_CONCEPTO.Nom_TipoConcepto, 
                         CAJ_CONCEPTO.Flag_Activo, CAJ_CONCEPTO.Cod_UsuarioReg, CAJ_CONCEPTO.Fecha_Reg, CAJ_CONCEPTO.Cod_UsuarioAct, 
                         CAJ_CONCEPTO.Fecha_Act
FROM            CAJ_CONCEPTO INNER JOIN
                         VIS_TIPO_CONCEPTO ON CAJ_CONCEPTO.Cod_ClaseConcepto = VIS_TIPO_CONCEPTO.Cod_TipoConcepto
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CONCEPTO_TP' AND type = 'P')
DROP PROCEDURE USP_CAJ_CONCEPTO_TP
go
CREATE PROCEDURE USP_CAJ_CONCEPTO_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Id_Concepto , Des_Concepto , Cod_ClaseConcepto , Nom_TipoConcepto,Flag_Activo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
FROM (SELECT TOP 100 PERCENT Id_Concepto , Des_Concepto , Cod_ClaseConcepto ,Nom_TipoConcepto, Flag_Activo , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_CONCEPTO '+@ScripWhere+') aCAJ_CONCEPTO
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go

IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_CUENTA_BANCARIA' ) 
    DROP VIEW VIS_CUENTA_BANCARIA
go
CREATE VIEW VIS_CUENTA_BANCARIA
WITH ENCRYPTION
AS
SELECT        BAN_CUENTA_BANCARIA.Cod_CuentaBancaria, BAN_CUENTA_BANCARIA.Cod_EntidadFinanciera, VIS_ENTIDADES_FINANCIERAS.Nom_EntidadFinanciera, 
                         BAN_CUENTA_BANCARIA.Des_CuentaBancaria, BAN_CUENTA_BANCARIA.Cod_CuentaContable, BAN_CUENTA_BANCARIA.Cod_Moneda, 
                         VIS_MONEDAS.Nom_Moneda, BAN_CUENTA_BANCARIA.Flag_Activo, BAN_CUENTA_BANCARIA.Saldo_Disponible, 
                         BAN_CUENTA_BANCARIA.Cod_UsuarioReg, BAN_CUENTA_BANCARIA.Fecha_Reg, BAN_CUENTA_BANCARIA.Cod_UsuarioAct, 
                         BAN_CUENTA_BANCARIA.Fecha_Act
FROM            BAN_CUENTA_BANCARIA INNER JOIN
                         VIS_ENTIDADES_FINANCIERAS ON BAN_CUENTA_BANCARIA.Cod_EntidadFinanciera = VIS_ENTIDADES_FINANCIERAS.Cod_EntidadFinanciera INNER JOIN
                         VIS_MONEDAS ON BAN_CUENTA_BANCARIA.Cod_Moneda = VIS_MONEDAS.Cod_Moneda
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_TP' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TP
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Cod_CuentaBancaria, Cod_EntidadFinanciera, Nom_EntidadFinanciera, Des_CuentaBancaria, Cod_CuentaContable, Cod_Moneda, Nom_Moneda, 
                         Flag_Activo, Saldo_Disponible, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act  
FROM (SELECT TOP 100 PERCENT Cod_CuentaBancaria, Cod_EntidadFinanciera, Nom_EntidadFinanciera, Des_CuentaBancaria, Cod_CuentaContable, Cod_Moneda, Nom_Moneda, 
                         Flag_Activo, Saldo_Disponible, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_CUENTA_BANCARIA '+@ScripWhere+') aBAN_CUENTA_BANCARIA
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_AREAS' ) 
    DROP VIEW VIS_AREAS
go
CREATE VIEW VIS_AREAS
WITH ENCRYPTION
AS
SELECT        PRI_AREAS.Cod_Area, PRI_AREAS.Cod_Sucursal, PRI_SUCURSAL.Nom_Sucursal, PRI_AREAS.Des_Area, PRI_AREAS.Numero, PRI_AREAS.Cod_AreaPadre, 
                         PRI_AREAS.Cod_UsuarioReg, PRI_AREAS.Fecha_Reg, PRI_AREAS.Cod_UsuarioAct, PRI_AREAS.Fecha_Act
FROM            PRI_AREAS INNER JOIN
                         PRI_SUCURSAL ON PRI_AREAS.Cod_Sucursal = PRI_SUCURSAL.Cod_Sucursal
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_AREAS_TP' AND type = 'P')
DROP PROCEDURE USP_PRI_AREAS_TP
go
CREATE PROCEDURE USP_PRI_AREAS_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Cod_Area , Cod_Sucursal ,Nom_Sucursal, Des_Area , Numero , Cod_AreaPadre , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
FROM (SELECT TOP 100 PERCENT Cod_Area , Cod_Sucursal ,Nom_Sucursal, Des_Area , Numero , Cod_AreaPadre , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_AREAS '+@ScripWhere+') aPRI_AREAS
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go
/* **************************** USP_PLA_ASISTENCIA_RegistrarAsistencia **************************** */

IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PLA_ASISTENCIA_RegistrarAsistencia' AND type = 'P' ) 
    DROP PROCEDURE USP_PLA_ASISTENCIA_RegistrarAsistencia
GO
CREATE PROCEDURE USP_PLA_ASISTENCIA_RegistrarAsistencia 
 @Cod_Personal  varchar(8),
 @Fecha_HoraActual  datetime
WITH ENCRYPTION
AS 
  BEGIN      
      SET DATEFORMAT 'dmy' 
      DECLARE @CodTipoHorario  varchar(8)
      SELECT @CodTipoHorario = PH.Cod_TipoHorario FROM PLA_PERSONAL_HORARIO PPH INNER JOIN PLA_HORARIOS PH
      ON PPH.Id_Horario = PH.Id_Horario WHERE Cod_Personal = @Cod_Personal
      
      IF(@CodTipoHorario <> '005')
      BEGIN
  DECLARE @EstadoProceso  varchar(5)
  DECLARE @AE  int,@T  int,@DE  int,@AS INT ,@DS INT -- Politicas
  -- Las horas estan en minutos
  DECLARE @Id_Horario  int,@Turno  varchar(32) ,@HoraEntrada  int,@HoraSalida INT ,@Min_FechaHoraActual INT
    
  -- Asignamos valores (estan en minutos) a las Politicas 
  SELECT @AE = 15, @T = 10,@DE = 20,@AS =10,@DS = 30 ;
  
  -- Verificamos en que estado se encuentra el registro de esta persona
  SELECT @EstadoProceso = Cod_Proceso  FROM PLA_ASISTENCIA WHERE Cod_Personal = @Cod_Personal AND
   60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual)
   BETWEEN 60*(DATEPART(HOUR,HoraEntrada)) + DATEPART(MINUTE,HoraEntrada) - @AE
   AND    60*(DATEPART(HOUR,HoraSalida)) +  DATEPART(MINUTE,HoraSalida) + @DS
  
  IF (@EstadoProceso IS NULL)
  BEGIN
  SELECT 'No existen horarios asignados para esta hora, intentalo mas tarde' Mensaje ,'SEC'  TipoMensaje
  END
  ELSE
  BEGIN
  -- Verificamos en que estado esta el registro, para aumentar o disminuir la tolerancia
  IF(@EstadoProceso = 'NR') 
   BEGIN
     -- Aca le sumo @DS , para mandar el mensaje "Se Registro Su Salida"
   SELECT  @Id_Horario = Id_Horario FROM PLA_HORARIOS WHERE 
   60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual)
   BETWEEN 60*(DATEPART(HOUR,HoraEntrada)) + DATEPART(MINUTE,HoraEntrada) - @AE
   AND    60*(DATEPART(HOUR,HoraSalida)) + DATEPART(MINUTE,HoraSalida)+ @DS    
--  Luego traemos los demas datos de este Horario
SELECT @Turno = Turno,
 @HoraEntrada = 60*(DATEPART(HOUR,HoraEntrada)) + DATEPART(MINUTE,HoraEntrada),
 @HoraSalida  = 60*(DATEPART(HOUR,HoraSalida)) +  DATEPART(MINUTE,HoraSalida)
 FROM PLA_HORARIOS WHERE Id_Horario=@Id_Horario;  
-- Convertimos la fecha de logueo en minutos  
SET @Min_FechaHoraActual = 60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual)
  
  /* ********************************** REGISTRAR INGRESO ********************************** */  
  -- Esta habilitado para picar
  IF( (@Min_FechaHoraActual >= (@HoraEntrada - @AE )) AND (@Min_FechaHoraActual <= (@HoraEntrada + @DE )) ) 
   BEGIN
IF( @Min_FechaHoraActual <= (@HoraEntrada + @T ))
BEGIN
 UPDATE PLA_ASISTENCIA SET Entro=@Fecha_HoraActual,Cod_Incidencia= 'REG',Cod_Proceso= 'RI'
 WHERE Cod_Personal=@Cod_Personal AND Turno =@Turno
 SELECT 'Usted registro su ingreso correctamente' Mensaje  ,'PRI'  TipoMensaje ,'GREEN' Incidencia
END
ELSE
BEGIN
 UPDATE PLA_ASISTENCIA SET Entro=@Fecha_HoraActual,Cod_Incidencia= 'TAR',Cod_Proceso= 'RI'
 WHERE Cod_Personal=@Cod_Personal AND Turno =@Turno
 SELECT 'Usted registro su ingreso en forma tardia' Mensaje,'PRI'  TipoMensaje ,'AMBAR' Incidencia     
END
   END
  ELSE 
   BEGIN
  IF( (@Min_FechaHoraActual > (@HoraEntrada + @DE )) AND (@Min_FechaHoraActual < ( @HoraSalida - @AS )) )-- Llego muy tarde
  BEGIN
 UPDATE PLA_ASISTENCIA SET Entro=@Fecha_HoraActual,Cod_Incidencia= 'FAL',Cod_Proceso= 'RI'
 WHERE Cod_Personal=@Cod_Personal AND Turno =@Turno
 SELECT 'Usted registro su ingreso en forma de falta' Mensaje ,'PRI'  TipoMensaje ,'RED' Incidencia      
  END
  IF EXISTS(SELECT * FROM PLA_ASISTENCIA WHERE Entro IS NULL AND Turno =@Turno )
  BEGIN --  Si esta en hora de salida
IF( (@Min_FechaHoraActual >= (@HoraSalida - @AS )) AND (@Min_FechaHoraActual <= (@HoraSalida + @DS )) )
 BEGIN
   IF NOT EXISTS(SELECT * FROM PLA_ASISTENCIA WHERE Cod_Proceso ='RS' AND Turno =@Turno )
BEGIN 
  UPDATE PLA_ASISTENCIA SET Salio=@Fecha_HoraActual,Cod_Proceso= 'RS'
  WHERE Cod_Personal=@Cod_Personal AND Turno =@Turno
  SELECT 'Usted registro su salida correctamente' Mensaje ,'PRI'  TipoMensaje ,'GREEN' Incidencia 
END
   END
  END               
   END
 END
  IF(@EstadoProceso = 'RI')
   BEGIN
  -- Aca le resto @AE , para mandar el mensaje "Ya Registro Su Ingreso"
   SELECT  @Id_Horario = Id_Horario FROM PLA_HORARIOS WHERE 
   60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual)
   BETWEEN 60*(DATEPART(HOUR,HoraEntrada)) + DATEPART(MINUTE,HoraEntrada) - @AE
   AND    60*(DATEPART(HOUR,HoraSalida)) + DATEPART(MINUTE,HoraSalida) + @DS    
--  Luego traemos los demas datos de este Horario
SELECT @Turno = Turno,
 @HoraEntrada = 60*(DATEPART(HOUR,HoraEntrada)) + DATEPART(MINUTE,HoraEntrada),
 @HoraSalida  = 60*(DATEPART(HOUR,HoraSalida)) +  DATEPART(MINUTE,HoraSalida)
 FROM PLA_HORARIOS WHERE Id_Horario=@Id_Horario;  
-- Convertimos la fecha de logueo en minutos  
SET @Min_FechaHoraActual = 60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual)
   
   /* ********************************** REGISTRAR SALIDA ********************************** */ 

 IF( (@Min_FechaHoraActual >= (@HoraEntrada - @AE )) AND (@Min_FechaHoraActual <= (@HoraEntrada + @DE )) ) 
  BEGIN
   SELECT 'Usted ya registro su ingreso' Mensaje,'SEC'  TipoMensaje
  END
 ELSE
  BEGIN
  IF(@Min_FechaHoraActual >(@HoraEntrada + @DE ) AND @Min_FechaHoraActual < (@HoraSalida - @AS ))-- Quiere salir muy temprano
BEGIN
   SELECT 'Aun no es hora para registrar salidas' Mensaje,'SEC'  TipoMensaje      
END
   ELSE IF( (@Min_FechaHoraActual >= (@HoraSalida - @AS )) AND (@Min_FechaHoraActual <= (@HoraSalida + @DS )) )
BEGIN
  UPDATE PLA_ASISTENCIA SET Salio=@Fecha_HoraActual,Cod_Proceso= 'RS'
  WHERE Cod_Personal=@Cod_Personal AND Turno =@Turno
  SELECT 'Usted registro su salida correctamente' Mensaje ,'PRI'  TipoMensaje ,'GREEN' Incidencia   
END
  END             
   END  
  IF(@EstadoProceso = 'RS')
   BEGIN
 SELECT 'Usted ya Registro Su Salida' Mensaje ,'SEC'  TipoMensaje
   END 
  END
  END
  ELSE -- Horario Corrido
  BEGIN
  IF NOT EXISTS(SELECT * FROM PLA_ASISTENCIA WHERE Cod_Personal = @Cod_Personal AND Fecha = CONVERT( varchar(10), @Fecha_HoraActual,103))
  BEGIN
    INSERT INTO PLA_ASISTENCIA (Cod_Personal,Id_Horario,Cod_Estado,Turno,Fecha,HoraEntrada,HoraSalida,Entro,Salio,Cod_Incidencia,
    Cod_Proceso,Obs_Asistencia,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act)

VALUES(@Cod_Personal,NULL,'00001',NULL,CONVERT( varchar(10), @Fecha_HoraActual,103),
 NULL ,NULL,NULL,NULL,NULL,NULL,NULL,'MIGRACION',@Fecha_HoraActual,NULL,NULL)
  
      
  INSERT INTO PLA_ASISTENCIA (Cod_Personal,Entro,Salio)
  VALUES (@Cod_Personal,@Fecha_HoraActual,NULL)  
  SELECT 'Usted registro su ingreso correctamente' Mensaje  ,'PRI'  TipoMensaje ,'GREEN' Incidencia
  END
  ELSE
  BEGIN
      DECLARE @ESSALIDAVALIDA INT
  DECLARE @ENTRO  datetime
  SELECT  @ENTRO = Entro FROM PLA_ASISTENCIA WHERE Cod_Personal = @Cod_Personal AND Fecha = CONVERT( varchar(10), @Fecha_HoraActual,103)
 
  -- Si no transcurrio 5 minutos luego de su picada de ingreso, no le habilitamos su picada de salida
      SET @ESSALIDAVALIDA = 60*(DATEPART(HOUR,@ENTRO)) + DATEPART(MINUTE,@ENTRO)
      
  IF(@ESSALIDAVALIDA + 5 >= 60*(DATEPART(HOUR,@Fecha_HoraActual)) + DATEPART(MINUTE,@Fecha_HoraActual))
  BEGIN
  UPDATE PLA_ASISTENCIA SET Salio=@Fecha_HoraActual
    SELECT 'Usted registro su salida correctamente' Mensaje  ,'PRI'  TipoMensaje ,'GREEN' Incidencia
  END
  END
  END   
  END
GO

    --exec USP_PLA_ASISTENCIA_RegistrarAsistencia '43684274' ,'06/06/2013 18:38:00'
    --  select * delete from PLA_ASISTENCIA  


/* **************************** USP_PLA_ASISTENCIA_GenerarAsistenciasXPersonal **************************** */
IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PLA_ASISTENCIA_GenerarAsistenciasXPersonal' AND type = 'P' ) 
    DROP PROCEDURE USP_PLA_ASISTENCIA_GenerarAsistenciasXPersonal
GO
CREATE PROCEDURE USP_PLA_ASISTENCIA_GenerarAsistenciasXPersonal 
 @FechaActual  datetime
WITH ENCRYPTION
AS 
  BEGIN
      SET DATEFORMAT 'dmy' 
      DECLARE @Fecha  datetime,@FechaHoraActual  datetime ,@NroDeDia INT   
  -- Asignamos valores
  IF(@FechaActual IS NULL)
  BEGIN
      SET @FechaHoraActual = GETDATE()
  SET @Fecha = CONVERT( datetime,CONVERT( varchar(10),GETDATE() , 103),103)
  SET @NroDeDia = DATEPART(dw,@Fecha)
  END
  ELSE
  BEGIN
      SET @FechaHoraActual = @FechaActual
  SET @Fecha = CONVERT( datetime,CONVERT( varchar(10),@FechaActual , 103),103)
  SET @NroDeDia = DATEPART(dw,@Fecha)
  END
  INSERT INTO PLA_ASISTENCIA (Cod_Personal,Cod_Estado,Turno,Fecha,HoraEntrada,HoraSalida,Entro,Salio,Cod_Incidencia,
    Cod_Proceso,Obs_Asistencia,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act)
    
  SELECT PPH.Cod_Personal,'00001',PH.Turno,@Fecha,
   CONVERT( varchar(10), @FechaHoraActual,103)+' '+ CONVERT( varchar(10), DATEPART(HOUR,PH.HoraEntrada))
          +':'+ CONVERT( varchar(10), DATEPART(MINUTE,PH.HoraEntrada)) ,
       CONVERT( varchar(10), @FechaHoraActual,103)+' '+ CONVERT( varchar(10), DATEPART(HOUR,PH.HoraSalida))
      +':'+ CONVERT( varchar(10), DATEPART(MINUTE,PH.HoraSalida)),           
  NULL,NULL,'FAL','NR',NULL,'MIGRACION',@Fecha,NULL,NULL
  FROM PLA_HORARIOS PH INNER JOIN PLA_PERSONAL_HORARIO PPH ON PH.Id_Horario = PPH.Id_Horario 
  WHERE SUBSTRING(PH.Dias, @NroDeDia, 1)='1'  
  --AND  Cod_TipoHorario <> '005'  
  END
GO

--  EXEC USP_PLA_ASISTENCIA_GenerarAsistenciasXPersonal null
--  delete from PLA_ASISTENCIA

/* **************************** USP_PLA_ASISTENCIA_ListarAsistenciasXPersonal **************************** */

IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PLA_ASISTENCIA_ListarAsistenciasXPersonal' AND type = 'P' ) 
    DROP PROCEDURE USP_PLA_ASISTENCIA_ListarAsistenciasXPersonal
GO
CREATE PROCEDURE USP_PLA_ASISTENCIA_ListarAsistenciasXPersonal 
 @Cod_Personal  varchar(8),
 @Fecha_HoraActual  datetime
WITH ENCRYPTION
AS 
 BEGIN
   SET DATEFORMAT 'dmy' 
   SELECT * FROM PLA_ASISTENCIA WHERE Cod_Personal = @Cod_Personal AND      
   CONVERT( varchar(10), @Fecha_HoraActual,103) =  CONVERT( varchar(10), Fecha,103)    
 END
 GO
--  exec USP_PLA_ASISTENCIA_ListarAsistenciasXPersonal '45128063' ,'06/06/2013 15:21:00'    -- 45128063
   
  /* **************************** USP_PLA_BIOMETRICO_ListarBiometricosXPersonal **************************** */
 
 
 IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PLA_BIOMETRICO_ListarBiometricosXPersonal' AND type = 'P' ) 
    DROP PROCEDURE USP_PLA_BIOMETRICO_ListarBiometricosXPersonal
GO
CREATE PROCEDURE USP_PLA_BIOMETRICO_ListarBiometricosXPersonal 
 @Cod_Personal  varchar(8)
WITH ENCRYPTION
AS 
 BEGIN
   SELECT * FROM  PLA_BIOMETRICO WHERE Cod_Personal = @Cod_Personal ORDER BY Des_Biometrico ASC  
 END
 GO
 --  exec USP_PLA_BIOMETRICO_ListarBiometricosXPersonal '43684274'
   /* **************************** USP_PRI_PERSONAL_ListarDatosPersonal **************************** */
 
 IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PRI_PERSONAL_ListarDatosPersonal' AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_PERSONAL_ListarDatosPersonal
GO
CREATE PROCEDURE USP_PRI_PERSONAL_ListarDatosPersonal 
 @Cod_Personal  varchar(8)
WITH ENCRYPTION
AS 
 BEGIN
   SELECT * FROM  PRI_PERSONAL WHERE Cod_Personal = @Cod_Personal  
 END
  GO


   /* **************************** USP_PRI_PERSONAL_BuscarPersonal **************************** */
   
  IF EXISTS ( SELECT  name FROM sysobjects WHERE   name = 'USP_PRI_PERSONAL_BuscarPersonal' AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_PERSONAL_BuscarPersonal
GO
CREATE PROCEDURE USP_PRI_PERSONAL_BuscarPersonal 
@Patron   varchar(30)
WITH ENCRYPTION
AS 
 BEGIN 
   IF(@Patron IS NOT NULL)
      BEGIN
        SELECT * FROM PRI_PERSONAL WHERE 
        ApellidoPaterno LIKE '%'+ @Patron +'%' OR
        ApellidoMaterno LIKE '%'+ @Patron +'%' OR
        PrimeroNombre LIKE '%'+ @Patron +'%' OR
        SegundoNombre LIKE '%'+ @Patron +'%' 
     END 
 END
 GO
-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_E' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_E
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_E 
@Id_Producto  int, 
@Cod_UnidadMedida  varchar(5), 
@Cod_Almacen  varchar(32)
WITH ENCRYPTION
AS
BEGIN
DELETE FROM PRI_PRODUCTO_PRECIO
WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)

DELETE FROM PRI_PRODUCTO_STOCK
WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_TxEntidadFinanciera' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TxEntidadFinanciera
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TxEntidadFinanciera
@Cod_EntidadFinanciera as  varchar(8),
@Cod_Moneda as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_CuentaBancaria , Des_CuentaBancaria  + '['+Cod_CuentaBancaria+']' as Des_CuentaBancaria
FROM BAN_CUENTA_BANCARIA
where Cod_EntidadFinanciera=@Cod_EntidadFinanciera and Cod_Moneda = @Cod_Moneda
END
go
-- traer stock actual y costo promedio USP_CAJ_COMPROBANTE_PAGO_CostoCompra '101','09/07/2013'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_CostoCompra' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CostoCompra
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CostoCompra
@Cod_Caja  varchar(32),
@Cod_Turno  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        AVG(PS.Stock_Act) AS Stock_Act, AVG(CD.PrecioUnitario) AS PrecioUnitario
FROM            PRI_PRODUCTO_STOCK AS PS INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON PS.Cod_Almacen = CA.Cod_Almacen INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON PS.Id_Producto = CD.Id_Producto INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP ON CP.id_ComprobantePago = CD.id_ComprobantePago
WHERE        (CA.Cod_Caja = @Cod_Caja) AND (CP.Cod_Turno = @Cod_Turno)
GROUP BY CA.Cod_Caja
END
go

-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_M_TXPKCajaTurno' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_M_TXPKCajaTurno
go
CREATE PROCEDURE USP_BAN_CUENTA_M_TXPKCajaTurno 
@Cod_CuentaBancaria  varchar(32),
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Id_MovimientoCuenta, Cod_CuentaBancaria, Nro_Operacion, Des_Movimiento, Fecha, Monto, Nro_Cheque, Beneficiario, Id_ComprobantePago, Obs_Movimiento 
FROM BAN_CUENTA_M
WHERE (Cod_CuentaBancaria = @Cod_CuentaBancaria)and Cod_Caja=@Cod_Caja and Cod_Turno=@Cod_Turno
END
go
-- Traer Por Claves primarias
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_ALMACEN_TXAlmacen' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_ALMACEN_TXAlmacen
go
CREATE PROCEDURE USP_CAJ_CAJA_ALMACEN_TXAlmacen 
@Cod_Almacen  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        CAA.Cod_Caja, CAA.Cod_Almacen, CAA.Flag_Principal, CAA.Cod_UsuarioReg, CAA.Fecha_Reg, CAA.Cod_UsuarioAct, CAA.Fecha_Act, AA.Des_CortaAlmacen, 
                         CA.Des_Caja
FROM            CAJ_CAJA_ALMACEN AS CAA INNER JOIN
                         ALM_ALMACEN AS AA ON CAA.Cod_Almacen = AA.Cod_Almacen INNER JOIN
                         CAJ_CAJAS AS CA ON CAA.Cod_Caja = CA.Cod_Caja
WHERE        (AA.Cod_Almacen = @Cod_Almacen)
END
go
-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_E' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_E
go
CREATE PROCEDURE USP_ALM_ALMACEN_E 
@Cod_Almacen  varchar(32)
WITH ENCRYPTION
AS
BEGIN
DELETE FROM CAJ_CAJA_ALMACEN
WHERE (Cod_Almacen = @Cod_Almacen)

DELETE FROM ALM_ALMACEN
WHERE (Cod_Almacen = @Cod_Almacen)


END
go
 -- USP_PRI_PRODUCTO_PRECIO_XAlmacenUnidadProducto 'TANQUE_2B5','GL',2
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_XAlmacenUnidadProducto' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_XAlmacenUnidadProducto
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_XAlmacenUnidadProducto
@Cod_Almacen  varchar(512),
@Cod_UnidadMedida as  varchar(5),
@Id_Producto as int
WITH ENCRYPTION
AS
BEGIN
if exists(SELECT       PP.Valor
FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_UnidadMedida = PS.Cod_UnidadMedida AND 
                         PP.Cod_Almacen = PS.Cod_Almacen
where PS.Cod_Almacen = @Cod_Almacen and PS.Cod_UnidadMedida = @Cod_UnidadMedida and PS.Id_Producto = @Id_Producto and PP.Valor <> 0)
BEGIN
SELECT        PP.Valor AS Precio, convert( varchar,convert( numeric(10,2),PP.Valor)) + ' - ' + VP.Nom_Precio as NomPrecio
FROM     PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_UnidadMedida = PS.Cod_UnidadMedida AND 
                         PP.Cod_Almacen = PS.Cod_Almacen INNER JOIN
                         VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
where PS.Cod_Almacen = @Cod_Almacen and PS.Cod_UnidadMedida = @Cod_UnidadMedida and PS.Id_Producto = @Id_Producto  and PP.Valor <> 0
END 
ELSE
BEGIN
SELECT       PS.Precio_Venta AS Precio,convert( varchar,convert( numeric(10,2),PS.Precio_Venta))+' - VENTA' as NomPrecio
FROM PRI_PRODUCTO_STOCK AS PS 
where PS.Cod_Almacen = @Cod_Almacen and PS.Cod_UnidadMedida = @Cod_UnidadMedida and PS.Id_Producto = @Id_Producto
END
END
go
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 04/09/2016
-- OBJETIVO: Selecionar los almacenes con su respectivo producto del tipo tanque
-- USP_ALM_ALMACEN_XTipoProducto
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_XTipoProducto' AND type = 'P')
DROP PROCEDURE USP_ALM_ALMACEN_XTipoProducto
go
CREATE PROCEDURE USP_ALM_ALMACEN_XTipoProducto
WITH ENCRYPTION
AS
BEGIN
SELECT        A.Cod_Almacen, A.Des_Almacen +' - '+ P.Nom_Producto as Des_Almacen
FROM            ALM_ALMACEN AS A INNER JOIN
                         PRI_PRODUCTO_STOCK AS S ON A.Cod_Almacen = S.Cod_Almacen INNER JOIN
                         PRI_PRODUCTOS AS P ON S.Id_Producto = P.Id_Producto
where a.Cod_TipoAlmacen = '03'
order by cod_almacen
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_PROVINCIAS_TT' AND type = 'P')
DROP PROCEDURE USP_VIS_PROVINCIAS_TT
go
CREATE PROCEDURE USP_VIS_PROVINCIAS_TT
@Cod_Departamento as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        Cod_Provincia, Nom_Provincia
FROM            VIS_PROVINCIAS
WHERE Cod_Departamento = @Cod_Departamento
END
go
 IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_DISTRITOS_TT' AND type = 'P')
DROP PROCEDURE USP_VIS_DISTRITOS_TT
go
CREATE PROCEDURE USP_VIS_DISTRITOS_TT
@Cod_Departamento as  varchar(32),
@Cod_Provincia as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        Cod_Ubigeo, Nom_Distrito
FROM            VIS_DISTRITOS
WHERE Cod_Departamento = @Cod_Departamento AND Cod_Provincia = @Cod_Provincia
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_SaldoClienteSoles'                    
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_SaldoClienteSoles
go
CREATE FUNCTION dbo.UFN_SaldoClienteSoles ( @Id_ClienteProveedor int )
RETURNS  numeric(38,2)
    WITH ENCRYPTION
AS 
    BEGIN
DECLARE @saldo AS  numeric(38,2)
SET @saldo=(SELECT ISNULL(SUM(Saldo_Disponible),0)
FROM            CUE_CLIENTE_CUENTA
where Id_ClienteProveedor=@Id_ClienteProveedor AND Cod_TipoCuenta not in ('CUS') and Cod_Moneda = 'PEN' )
RETURN @saldo;
END
GO
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_SaldoClienteDolares'                    
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_SaldoClienteDolares
go
CREATE FUNCTION dbo.UFN_SaldoClienteDolares ( @Id_ClienteProveedor int )
RETURNS  numeric(38,2)
    WITH ENCRYPTION
AS 
    BEGIN
DECLARE @saldo AS  numeric(38,2)
SET @saldo=(SELECT  ISNULL(SUM(Saldo_Disponible),0)
FROM            CUE_CLIENTE_CUENTA
where Id_ClienteProveedor=@Id_ClienteProveedor AND Cod_TipoCuenta not in ('CUS') and Cod_Moneda = 'USD' )
RETURN @saldo;
END
GO
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_SaldoClienteMaterial'                    
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_SaldoClienteMaterial
go
CREATE FUNCTION dbo.UFN_SaldoClienteMaterial ( @Id_ClienteProveedor int )
RETURNS  numeric(38,2)
    WITH ENCRYPTION
AS 
    BEGIN
DECLARE @saldo AS  numeric(38,2)
SET @saldo=(SELECT  ISNULL(SUM(Monto_Deposito),0)
FROM            CUE_CLIENTE_CUENTA
where Id_ClienteProveedor=@Id_ClienteProveedor AND Cod_TipoCuenta in ('CUS'))
RETURN @saldo;
END
GO
-- USP_CUE_CLIENTE_CUENTA_TSaldoXIdCliente 2
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_TSaldoXIdCliente' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_TSaldoXIdCliente
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_TSaldoXIdCliente
@Id_ClienteProveedor int
WITH ENCRYPTION
AS
BEGIN
SELECT        Id_ClienteProveedor, dbo.UFN_SaldoClienteSoles (@Id_ClienteProveedor) AS Soles,
dbo.UFN_SaldoClienteDolares (@Id_ClienteProveedor) AS Dolares,dbo.UFN_SaldoClienteMaterial (@Id_ClienteProveedor) AS Material
FROM            PRI_CLIENTE_PROVEEDOR
WHERE Id_ClienteProveedor=@Id_ClienteProveedor
END
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_MovimientosMaterialCajaTurno' AND type = 'P')
DROP PROCEDURE USP_MovimientosMaterialCajaTurno
go
CREATE PROCEDURE USP_MovimientosMaterialCajaTurno
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT   'CAJ_COMPROBANTE_PAGO' as Entidad,CP.id_ComprobantePago as ID, CP.Cod_TipoComprobante+':'+ CP.Serie+'-'+ CP.Numero as Documento, 
CASE WHEN Flag_Anulado = 0 AND CP.Cod_Libro = '08' THEN CD.Despachado ELSE 0 END AS Entrada,
CASE WHEN Flag_Anulado = 0 AND CP.Cod_Libro = '14' THEN CD.Despachado ELSE 0 END AS Salida, cp.Fecha_Reg
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
                         PRI_PRODUCTOS AS PR ON CD.Id_Producto = PR.Id_Producto
where Cod_Caja = @Cod_Caja and Cod_Turno=@Cod_Turno AND Flag_Despachado = 1
UNION
SELECT 'ALM_ALMACEN_MOV' as Entidad,AM.Id_AlmacenMov as ID ,AM.Cod_TipoComprobante+':'+ AM.Serie+'-'+ AM.Numero as Documento, 
CASE WHEN AM.Flag_Anulado = 0 AND Cod_TipoComprobante = 'NE' THEN AMD.Cantidad ELSE 0 END AS Entrada,
CASE WHEN AM.Flag_Anulado = 0 AND Cod_TipoComprobante = 'NS' THEN AMD.Cantidad ELSE 0 END AS Salida, am.Fecha_Reg
FROM  ALM_ALMACEN_MOV AS AM INNER JOIN
ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov INNER JOIN
CAJ_CAJA_ALMACEN AS CA ON AM.Cod_Almacen = CA.Cod_Almacen
WHERE CA.Cod_Caja = @Cod_Caja AND Cod_Turno = @Cod_Turno
ORDER BY Fecha_Reg
END
GO
-- determinar pendientes de cada proceso USP_NumeroPendientesxCaja '101'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_NumeroPendientesxCaja' AND type = 'P')
DROP PROCEDURE USP_NumeroPendientesxCaja
go
CREATE PROCEDURE USP_NumeroPendientesxCaja
@Cod_Caja as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT 'HABILITACION_FONDOS' as Tipo,isnull(count(*) ,0) AS Pendientes
FROM CAJ_CAJA_MOVIMIENTOS
where Cod_Caja = @Cod_Caja and Cod_Turno is null
UNION
SELECT   'HABILITACION_MATERIAL' as Tipo,ISNULL(COUNT(*), 0) AS Pendientes
FROM  ALM_ALMACEN_MOV AS AM INNER JOIN
   CAJ_CAJA_ALMACEN AS CA ON AM.Cod_Almacen = CA.Cod_Almacen
where Cod_Caja = @Cod_Caja and Cod_Turno is null
UNION 
SELECT        'TRANSFERENCIAS_PENDIENTES' AS Tipo, ISNULL(COUNT(*), 0) AS Pendientes
FROM            CAJ_TRANSFERENCIAS AS T INNER JOIN
 PRI_SUCURSAL AS S ON T.Cod_Destino = S.Cod_Sucursal INNER JOIN
 CAJ_CAJAS AS C ON S.Cod_Sucursal = C.Cod_Sucursal
WHERE        (T.Id_MovimientoPago = 0) AND (C.Cod_Caja = @Cod_Caja) and T.Cod_EstadoTransferencia <> '004'
UNION
SELECT 'AUTORIZACIONES' AS Tipo, ISNULL(COUNT(*), 0) AS Pendientes
FROM CAJ_CAJA_MOVIMIENTOS
where Cod_UsuarioAct is null
END
GO
-- Traer Todo USP_CAJ_CONCEPTO_TXClaseConcepto '006'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CONCEPTO_TXClaseConcepto' AND type = 'P')
DROP PROCEDURE USP_CAJ_CONCEPTO_TXClaseConcepto
go
CREATE PROCEDURE USP_CAJ_CONCEPTO_TXClaseConcepto
@Cod_ClaseConcepto  varchar(5),
@Flag_Activo as bit = null
WITH ENCRYPTION
AS
BEGIN
SELECT Id_Concepto , Des_Concepto 
FROM CAJ_CONCEPTO
WHERE Cod_ClaseConcepto = @Cod_ClaseConcepto AND (Flag_Activo = @Flag_Activo or @Flag_Activo is null)
UNION 
SELECT Id_Concepto , Des_Concepto 
FROM CAJ_CONCEPTO
WHERE Cod_ClaseConcepto = '009' AND (Flag_Activo = @Flag_Activo or @Flag_Activo is null)
AND @Cod_ClaseConcepto = '007'
UNION
SELECT Id_Concepto , Des_Concepto 
FROM CAJ_CONCEPTO
WHERE Cod_ClaseConcepto = '010' AND (Flag_Activo = @Flag_Activo or @Flag_Activo is null)
AND @Cod_ClaseConcepto = '006'
ORDER BY Des_Concepto 
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_Split')
DROP FUNCTION dbo.UFN_Split
go
CREATE FUNCTION dbo.UFN_Split
(
    @Text  varchar(MAX),
    @Delimiter  varchar(100),
    @Index INT
)
RETURNS  varchar(MAX)
WITH ENCRYPTION
AS BEGIN
    DECLARE @A TABLE (ID INT IDENTITY, V  varchar(MAX));
    DECLARE @R  varchar(MAX);
    WITH CTE AS
    (
    SELECT 0 A, 1 B
    UNION ALL
    SELECT B, CONVERT( int,CHARINDEX(@Delimiter, @Text, B) + LEN(@Delimiter))
    FROM CTE
    WHERE B > A
    )
    INSERT @A(V)
    SELECT SUBSTRING(@Text,A,CASE WHEN B > LEN(@Delimiter) THEN B-A-LEN(@Delimiter) ELSE LEN(@Text) - A + 1 END) VALUE      
    FROM CTE WHERE A >0

    SELECT      @R
    =           V
    FROM        @A
    WHERE       ID = @Index + 1
    RETURN      @R
END
go
-- USP_ConectividadExportacion 'ISLA','18/09/2013'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ConectividadExportacion' AND type = 'P')
DROP PROCEDURE USP_ConectividadExportacion
go
CREATE PROCEDURE USP_ConectividadExportacion
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SET DATEFORMAT dmy;
DECLARE @FechaInicio as  datetime, @FechaFin as  datetime;
SELECT @FechaInicio = Fecha_Inicio, @FechaFin = Fecha_Fin FROM CAJ_TURNO_ATENCION WHERE Cod_Turno = @Cod_Turno

SELECT  'CAJ_TURNO_ATENCION' AS Tabla, Cod_Turno, Des_Turno, Fecha_Inicio, Fecha_Fin, Flag_Cerrado, Cod_UsuarioReg
FROM   CAJ_TURNO_ATENCION
WHERE Cod_Turno=@Cod_Turno

SELECT 'PRI_CLIENTE_PROVEEDOR' as Tabla,Cod_TipoDocumento +'|'+Nro_Documento as Cod_ClienteProveedor , Cod_TipoDocumento , 
Nro_Documento , Cliente , Ap_Paterno , Ap_Materno , Nombres , Direccion , Cod_EstadoCliente , Cod_CondicionCliente , 
Cod_TipoCliente , RUC_Natural , Foto , Firma , Cod_TipoComprobante , Cod_Nacionalidad , Fecha_Nacimiento , Cod_Sexo , 
Email1 , Email2 , Telefono1 , Telefono2 , Fax , PaginaWeb , Cod_Ubigeo , Cod_FormaPago , Limite_Credito , Obs_Cliente , 
Cod_UsuarioReg  
FROM PRI_CLIENTE_PROVEEDOR
--WHERE Fecha_Reg between @FechaInicio and @FechaFin 


SELECT 'PRI_PRODUCTOS' as Tabla,Cod_Producto, Cod_Categoria, Cod_Marca, Cod_TipoProducto, Nom_Producto, Des_CortaProducto, Des_LargaProducto, Caracteristicas, Porcentaje_Utilidad, 
                         Cuenta_Contable, Contra_Cuenta, Cod_Garantia, Cod_TipoExistencia, Cod_TipoOperatividad, Flag_Activo, Flag_Stock, Cod_Fabricante, Obs_Producto, 
                         Cod_UsuarioReg
FROM            PRI_PRODUCTOS
--WHERE Fecha_Reg between @FechaInicio and @FechaFin OR (Fecha_Act is null and Fecha_Act between @FechaInicio and @FechaFin)

SELECT        'PRI_PRODUCTO_STOCK' AS Tabla, P.Cod_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, PS.Cod_Moneda, PS.Precio_Compra, PS.Precio_Venta, 
                         PS.Stock_Min, PS.Stock_Max, PS.Stock_Act, PS.Cod_UnidadMedidaMin, PS.Cantidad_Min, PS.Cod_UsuarioReg
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--WHERE ps.Fecha_Reg between @FechaInicio and @FechaFin OR (ps.Fecha_Act is null and ps.Fecha_Act between @FechaInicio and @FechaFin)

SELECT 'PRI_PRODUCTO_PRECIO' AS Tabla, P.Cod_Producto, PP.Cod_UnidadMedida, PP.Cod_Almacen, PP.Cod_TipoPrecio, PP.Valor, PP.Cod_UsuarioReg
FROM PRI_PRODUCTOS AS P INNER JOIN
         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto
--WHERE PP.Fecha_Reg between @FechaInicio and @FechaFin OR (PP.Fecha_Act is null and PP.Fecha_Act between @FechaInicio and @FechaFin)

SELECT  'CAJ_CAJA_MOVIMIENTOS' AS Tabla, CM.Cod_TipoComprobante+ '|' + CM.Serie+ '|' + CM.Numero as Cod_Movimiento, CM.Cod_Caja, CM.Cod_Turno, CM.Id_Concepto, 
CP.Cod_TipoDocumento + '|' +  CP.Nro_Documento as Cod_ClienteProveedor, 
CM.Cliente, CM.Des_Movimiento, CM.Cod_TipoComprobante, 
                         CM.Serie, CM.Numero, CM.Fecha, CM.Tipo_Cambio, CM.Ingreso, CM.Cod_MonedaIng, CM.Egreso, CM.Cod_MonedaEgr, CM.Flag_Extornado, 
                         CM.Cod_UsuarioAut, CM.Fecha_Aut, CM.Obs_Movimiento, CM.Id_MovimientoRef, CM.Cod_UsuarioReg                         
FROM            CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CP ON CM.Id_ClienteProveedor = CP.Id_ClienteProveedor
WHERE        (CM.Cod_Caja = @Cod_Caja) AND (CM.Cod_Turno = @Cod_Turno)
SELECT 'CAJ_ARQUEOFISICO' AS Tabla,Cod_Caja+ '|' +Cod_Turno+ '|' + CONVERT( varchar(32),Numero) as Cod_ArqueoFisico, Cod_Caja, Cod_Turno, 
Numero, Des_ArqueoFisico, Obs_ArqueoFisico, Fecha, Flag_Cerrado, Cod_UsuarioReg
FROM            CAJ_ARQUEOFISICO
WHERE Cod_Caja = @Cod_Caja  and Cod_Turno=@Cod_Turno

SELECT        'CAJ_ARQUEOFISICO_D' AS Tabla, AF.Cod_Caja + '|' + AF.Cod_Turno + '|' + CONVERT( varchar(32),AF.Numero) AS Cod_ArqueoFisico, AFD.Cod_Billete, AFD.Cantidad, 
                         AFD.Cod_UsuarioReg
FROM            CAJ_ARQUEOFISICO AS AF INNER JOIN
                         CAJ_ARQUEOFISICO_D AS AFD ON AF.id_ArqueoFisico = AFD.id_ArqueoFisico
WHERE        (AF.Cod_Caja = @Cod_Caja) AND (AF.Cod_Turno = @Cod_Turno)

SELECT        'CAJ_ARQUEOFISICO_SALDO' AS Tabla, AF.Cod_Caja + '|' + AF.Cod_Turno + '|' + CONVERT( varchar(32),AF.Numero) AS Cod_ArqueoFisico, AFS.Cod_Moneda, AFS.Tipo, AFS.Monto, 
                         AFS.Cod_UsuarioReg
FROM            CAJ_ARQUEOFISICO AS AF INNER JOIN
                         CAJ_ARQUEOFISICO_SALDO AS AFS ON AF.id_ArqueoFisico = AFS.id_ArqueoFisico
WHERE        (AF.Cod_Caja = @Cod_Caja) AND (AF.Cod_Turno = @Cod_Turno)

SELECT 'CAJ_MEDICION_VC' AS Tabla,Cod_AMedir + '|' + Medio_AMedir + '|' + Cod_Turno as Cod_Medicion, Cod_AMedir, Medio_AMedir, Medida_Anterior, Medida_Actual, Fecha_Medicion, Cod_Turno, Cod_UsuarioMedicion, Cod_UsuarioReg
FROM            CAJ_MEDICION_VC
WHERE Cod_Turno = @Cod_Turno

SELECT 'ALM_ALMACEN_MOV' AS Tabla,Cod_TipoComprobante+ '|' + Serie+ '|' + Numero AS Cod_AlmacenMov, Cod_Almacen, Cod_TipoOperacion, 
Cod_Turno, Cod_TipoComprobante, Serie, Numero, Fecha, Motivo, Id_ComprobantePago, Flag_Anulado, 
                         Cod_UsuarioReg
FROM            ALM_ALMACEN_MOV
WHERE Cod_Turno = @Cod_Turno

SELECT        'ALM_ALMACEN_MOV_D' AS Tabla, AM.Cod_TipoComprobante + '|' + AM.Serie + '|' + AM.Numero AS Cod_AlmacenMov, AMD.Item, AMD.Id_Producto, 
                         AMD.Des_Producto, AMD.Precio_Unitario, AMD.Cantidad, AMD.Cod_UnidadMedida, AMD.Obs_AlmacenMovD, AMD.Cod_UsuarioReg
FROM            ALM_ALMACEN_MOV AS AM INNER JOIN
                         ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
WHERE AM.Cod_Turno = @Cod_Turno


SELECT 'CAJ_COMPROBANTE_PAGO' as Tabla,Cod_Libro +'|'+Cod_TipoComprobante+'|'+Serie+'|'+Numero+'|'+Cod_TipoDoc+'|'+Doc_Cliente as Cod_ComprobantePago, 
Cod_Libro , Cod_Periodo , Cod_Caja , Cod_Turno , Cod_TipoOperacion , Cod_TipoComprobante , Serie , Numero , 
Cod_TipoDoc +'|'+ Doc_Cliente as Cod_Cliente,Cod_TipoDoc , Doc_Cliente , Nom_Cliente , Direccion_Cliente , FechaEmision , FechaVencimiento , 
FechaCancelacion , Glosa , TipoCambio , Flag_Anulado , Flag_Despachado , Cod_FormaPago , Descuento_Total , 
Cod_Moneda , Impuesto , Total , Obs_Comprobante , Id_GuiaRemision , GuiaRemision , id_ComprobanteRef , 
Cod_Plantilla , Cod_UsuarioReg  
FROM CAJ_COMPROBANTE_PAGO
WHERE Cod_Caja = @Cod_Caja  and Cod_Turno=@Cod_Turno

SELECT        'CAJ_COMPROBANTE_D' AS Tabla, 
                         CP.Cod_Libro + '|' + CP.Cod_TipoComprobante + '|' + CP.Serie + '|' + CP.Numero + '|' + CP.Cod_TipoDoc + '|' + CP.Doc_Cliente AS Cod_ComprobantePago, 
                         CD.id_Detalle, CD.Id_Producto, CD.Cod_Almacen, CD.Cantidad, CD.Cod_UnidadMedida, CD.Despachado, CD.Descripcion, CD.PrecioUnitario, CD.Descuento, 
                         CD.Sub_Total, CD.Tipo, CD.Obs_ComprobanteD, CD.Cod_Manguera, CD.Flag_AplicaImpuesto, CD.Formalizado, CD.Cod_UsuarioReg
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
WHERE Cod_Caja = @Cod_Caja  and Cod_Turno=@Cod_Turno

SELECT        'CAJ_FORMA_PAGO' AS Tabla, 
                         CP.Cod_Libro + '|' + CP.Cod_TipoComprobante + '|' + CP.Serie + '|' + CP.Numero + '|' + CP.Cod_TipoDoc + '|' + CP.Doc_Cliente AS Cod_ComprobantePago, 
                         FP.Item, FP.Des_FormaPago, FP.Cod_TipoFormaPago, FP.Cuenta_CajaBanco, FP.Id_Movimiento, FP.TipoCambio, FP.Cod_Moneda, FP.Monto, FP.Cod_Caja, 
                         FP.Cod_Turno, FP.Cod_Plantilla, FP.Obs_FormaPago, FP.Fecha, FP.Cod_UsuarioReg
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_FORMA_PAGO AS FP ON CP.id_ComprobantePago = FP.id_ComprobantePago
WHERE        (CP.Cod_Caja = @Cod_Caja) AND (CP.Cod_Turno = @Cod_Turno)



END
GO
-----------------------------------------------------------------------------------------------------------
--------------OBJECTIVO: ACTIVOS FIJOS---------------------------------------------------------------------
--------------FECHA: 06/10/2013----------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UFN_PAT_GRUPOS_TXGrupo' AND type = 'TF')
DROP FUNCTION dbo.UFN_PAT_GRUPOS_TXGrupo
go
CREATE FUNCTION dbo.UFN_PAT_GRUPOS_TXGrupo(@Cod_Grupo as  varchar(32))
RETURNS @TABLA_GRUPOS TABLE (Cod_Grupo  varchar(32))
WITH ENCRYPTION
AS
BEGIN
 WITH GRUPOS (Cod_Grupo)
AS
(
select Cod_Grupo
from PAT_GRUPOS
where Cod_Grupo = @Cod_Grupo
UNION ALL
select c.Cod_Grupo
from PAT_GRUPOS AS C INNER JOIN GRUPOS AS CA
on  Cod_GrupoPadre = ca.Cod_Grupo
)
INSERT @TABLA_GRUPOS
SELECT Cod_Grupo
FROM GRUPOS 
RETURN
END
GO
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PAT_GRUPOS_TArbol'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PAT_GRUPOS_TArbol
go
CREATE PROCEDURE USP_PAT_GRUPOS_TArbol
    WITH ENCRYPTION
AS 
BEGIN
WITH GRUPOS (Cod_Grupo, Des_Grupo, Level)
AS
(
select Cod_Grupo,Des_Grupo, 0 as Level 
from PAT_GRUPOS
where Cod_GrupoPadre is null
UNION ALL
select c.Cod_Grupo,c.Des_Grupo, Level + 1 
from PAT_GRUPOS AS C INNER JOIN GRUPOS AS CA
on  Cod_GrupoPadre = ca.Cod_Grupo 
)
select C.Cod_Grupo, 
case level 
when 1 then '-'+ C.Des_Grupo
when 2 then '-'+ C.Des_Grupo
when 3 then '-'+ C.Des_Grupo
when 4 then '-'+ C.Des_Grupo
when 5 then '-'+ C.Des_Grupo
when 6 then '-'+ C.Des_Grupo
when 7 then '-'+ C.Des_Grupo
when 8 then '-'+ C.Des_Grupo
when 9 then '-'+ C.Des_Grupo
ELSE C.Des_Grupo
END AS Des_Grupo, Level
from GRUPOS AS CA INNER JOIN PAT_GRUPOS AS C
ON C.Cod_Grupo = CA.Cod_Grupo
ORDER BY Cod_Grupo

END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PAT_GRUPOS_CARACTERISTICAS_TXCod_Grupo' AND type = 'P')
DROP PROCEDURE USP_PAT_GRUPOS_CARACTERISTICAS_TXCod_Grupo
go
CREATE PROCEDURE USP_PAT_GRUPOS_CARACTERISTICAS_TXCod_Grupo
@Cod_Grupo as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Grupo , Cod_Caracteristica , Caracteristica , Predeterminado 
FROM PAT_GRUPOS_CARACTERISTICAS
where Cod_Grupo=@Cod_Grupo
END
go

-- validar ingreso de tanques o varillajes

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_VC_ValidarTanqueXTurno' AND type = 'P')
DROP PROCEDURE USP_CAJ_MEDICION_VC_ValidarTanqueXTurno
go
CREATE PROCEDURE USP_CAJ_MEDICION_VC_ValidarTanqueXTurno
@Cod_Turno as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        Id_Medicion, Cod_AMedir, Medio_AMedir, Medida_Anterior, Medida_Actual, Fecha_Medicion
FROM            CAJ_MEDICION_VC
where Cod_Turno = @Cod_Turno  and Medio_AMedir = 'TANQUE' 
AND Medida_Anterior <> 0 and Medida_Actual = 0
END
go
-- USP_BAN_CUENTA_BANCARIA_TMXCod_CuentaBancaria '285-1422367-1-39','14'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_TMXCod_CuentaBancaria' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TMXCod_CuentaBancaria
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TMXCod_CuentaBancaria 
@Cod_CuentaBancaria  varchar(32),
@Cod_Libro  varchar(8)
WITH ENCRYPTION
AS
BEGIN
SELECT        CM.Id_MovimientoCuenta, 
' SALDO[' + CONVERT( varchar(32), SUM(CM.Monto) - ISNULL(SUM(FP.Monto),0)) + '] '+CM.Des_Movimiento +' - '+ CM.Obs_Movimiento AS Des_Movimiento                         
FROM            BAN_CUENTA_M AS CM INNER JOIN
                         VIS_TIPO_MOVIMIENTO_BANCARIO AS VTB ON CM.Cod_TipoOperacionBancaria = VTB.Cod_TipoMovimientoBancario LEFT OUTER JOIN
                         CAJ_FORMA_PAGO AS FP ON CM.Id_MovimientoCuenta = FP.Id_Movimiento
WHERE        (CM.Cod_CuentaBancaria = @Cod_CuentaBancaria) AND 
VTB.Tipo = CASE @Cod_Libro WHEN '08' THEN  'EGRESO' WHEN '14' THEN 'INGRESO' else '' END
GROUP BY CM.Id_MovimientoCuenta, CM.Des_Movimiento,CM.Obs_Movimiento
END
go


-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PLA_CONTRATOS_G' AND type = 'P')
DROP PROCEDURE USP_PLA_CONTRATOS_G
go
CREATE PROCEDURE USP_PLA_CONTRATOS_G 
@Cod_Personal varchar(32), 
@Nro_Contrato int out, 
@Des_Contrato varchar(32), 
@Cod_Area varchar(32), 
@Cod_TipoContrato varchar(5), 
@Fecha_Firma datetime, 
@Fecha_Inicio datetime, 
@Fecha_Fin datetime, 
@Cod_Cargo varchar(5), 
@Monto_Base numeric(38,2), 
@Contrato image, 
@Obs_Contrato varchar(1024),
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
if (@Nro_Contrato = 0)
BEGIN
SET @Nro_Contrato = (SELECT ISNULL(MAX(Nro_Contrato), 0) + 1 FROM PLA_CONTRATOS where Cod_Personal = @Cod_Personal)
END

IF NOT EXISTS (SELECT @Cod_Personal, @Nro_Contrato FROM PLA_CONTRATOS WHERE  (Cod_Personal = @Cod_Personal) AND (Nro_Contrato = @Nro_Contrato))
BEGIN
INSERT INTO PLA_CONTRATOS  VALUES (
@Cod_Personal,
@Nro_Contrato,
@Des_Contrato,
@Cod_Area,
@Cod_TipoContrato,
@Fecha_Firma,
@Fecha_Inicio,
@Fecha_Fin,
@Cod_Cargo,
@Monto_Base,
@Contrato,
@Obs_Contrato,
@Cod_Usuario,GETDATE(),NULL,NULL)

END
ELSE
BEGIN
UPDATE PLA_CONTRATOS
SET
Des_Contrato = @Des_Contrato, 
Cod_Area = @Cod_Area, 
Cod_TipoContrato = @Cod_TipoContrato, 
Fecha_Firma = @Fecha_Firma, 
Fecha_Inicio = @Fecha_Inicio, 
Fecha_Fin = @Fecha_Fin, 
Cod_Cargo = @Cod_Cargo, 
Monto_Base = @Monto_Base, 
Contrato = @Contrato, 
Obs_Contrato = @Obs_Contrato,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Cod_Personal = @Cod_Personal) AND (Nro_Contrato = @Nro_Contrato)
END
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PERSONAL_PARENTESCO_TxCod_Personal' AND type = 'P')
DROP PROCEDURE USP_PRI_PERSONAL_PARENTESCO_TxCod_Personal
go
CREATE PROCEDURE USP_PRI_PERSONAL_PARENTESCO_TxCod_Personal
@Cod_Personal as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        P.Item_Parentesco, P.Cod_TipoDoc, P.Num_Doc, P.ApellidoPaterno, P.ApellidoMaterno, P.Nombres, P.Cod_TipoParentesco, 
                         VP.Nom_Parentesco
FROM            PRI_PERSONAL_PARENTESCO AS P INNER JOIN
                         VIS_PARENTESCOS AS VP ON P.Cod_TipoParentesco = VP.Cod_Parentesco
where Cod_Personal=@Cod_Personal
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PLA_CONTRATOS_TXCod_Personal' AND type = 'P')
DROP PROCEDURE USP_PLA_CONTRATOS_TXCod_Personal
go
CREATE PROCEDURE USP_PLA_CONTRATOS_TXCod_Personal
@Cod_Personal as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        C.Cod_Personal, C.Nro_Contrato, C.Des_Contrato, C.Cod_Area, C.Cod_TipoContrato, C.Fecha_Firma, C.Fecha_Inicio, C.Fecha_Fin, C.Cod_Cargo, 
                         C.Monto_Base, C.Contrato, C.Obs_Contrato, VC.Nom_Cargo, VTC.Nom_TipoContrato, A.Des_Area
FROM            PLA_CONTRATOS AS C INNER JOIN
                         PRI_AREAS AS A ON C.Cod_Area = A.Cod_Area INNER JOIN
                         VIS_TIPO_CONTRATOS AS VTC ON C.Cod_TipoContrato = VTC.Cod_TipoContrato INNER JOIN
                         VIS_CARGOS AS VC ON C.Cod_Cargo = VC.Cod_Cargo
where Cod_Personal=@Cod_Personal
END
go

-- Traer Todo USP_PRI_CLIENTE_PROVEEDOR_Remplazar 31,243
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_Remplazar' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_Remplazar
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_Remplazar
@Id_ClienteProveedorPrincipal as  int,
@Id_ClienteProveedorRemplazar as int
WITH ENCRYPTION
AS
BEGIN
UPDATE CAJ_CAJA_MOVIMIENTOS
SET Id_ClienteProveedor = @Id_ClienteProveedorPrincipal
WHERE Id_ClienteProveedor = @Id_ClienteProveedorRemplazar

UPDATE CAJ_COMPROBANTE_PAGO
SET Id_Cliente = @Id_ClienteProveedorPrincipal
WHERE Id_Cliente = @Id_ClienteProveedorRemplazar

UPDATE CAJ_TRANSFERENCIAS
SET id_ClienteEmisor = @Id_ClienteProveedorPrincipal
WHERE id_ClienteEmisor = @Id_ClienteProveedorRemplazar

UPDATE CAJ_TRANSFERENCIAS
SET id_ClienteBeneficiarioP = @Id_ClienteProveedorPrincipal
WHERE id_ClienteBeneficiarioP = @Id_ClienteProveedorRemplazar

UPDATE CAJ_TRANSFERENCIAS
SET id_ClienteBeneficiarioS = @Id_ClienteProveedorPrincipal
WHERE id_ClienteBeneficiarioS = @Id_ClienteProveedorRemplazar

UPDATE CUE_CLIENTE_CUENTA
SET Id_ClienteProveedor = @Id_ClienteProveedorPrincipal
WHERE Id_ClienteProveedor = @Id_ClienteProveedorRemplazar

DELETE FROM PRI_CLIENTE_PROVEEDOR
WHERE Id_ClienteProveedor = @Id_ClienteProveedorRemplazar
END
go

-- USP_BAN_CUENTA_TNroChequeSiguienteXCodCuentaBancaria '01225-152200000125-25'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_TNroChequeSiguienteXCodCuentaBancaria' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_TNroChequeSiguienteXCodCuentaBancaria
go
CREATE PROCEDURE USP_BAN_CUENTA_TNroChequeSiguienteXCodCuentaBancaria
@Cod_CuentaBancaria as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT top 1 isnull(Max( Nro_Cheque),0)+1
FROM BAN_CUENTA_M
where @Cod_CuentaBancaria=Cod_CuentaBancaria and Cod_TipoOperacionBancaria = '006'
END
go
-- USP_PRI_COMPROBANTE_PAGO_Combo '14'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_COMPROBANTE_PAGO_Combo' AND type = 'P')
DROP PROCEDURE USP_PRI_COMPROBANTE_PAGO_Combo
go
CREATE PROCEDURE USP_PRI_COMPROBANTE_PAGO_Combo
@Cod_Libro as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CP.Numero + '; ' + CP.Doc_Cliente + ': ' + CP.Nom_Cliente + '; ' 
+ CONVERT( varchar,CP.FechaEmision,103) + '; ' + CONVERT( varchar,CP.Total) + ' [' + CONVERT( varchar,SUM(D.Cantidad))
                          + ']' AS Comprobante, CP.id_ComprobantePago,CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CP.Numero AS Documento
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_COMPROBANTE_D AS D ON CP.id_ComprobantePago = D.id_ComprobantePago
WHERE Cod_Libro=@Cod_Libro
GROUP BY CP.Cod_TipoComprobante, CP.Serie, CP.Numero, CP.Doc_Cliente, CP.Nom_Cliente, CP.FechaEmision, CP.Total, CP.id_ComprobantePago
ORDER BY cp.serie,cp.numero DESC
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PERSONAL_PARENTESCO_G' AND type = 'P')
DROP PROCEDURE USP_PRI_PERSONAL_PARENTESCO_G
go
CREATE PROCEDURE USP_PRI_PERSONAL_PARENTESCO_G 
@Cod_Personal  varchar(32), 
@Item_Parentesco  int, 
@Cod_TipoDoc  varchar(5), 
@Num_Doc  varchar(20), 
@ApellidoPaterno  varchar(124), 
@ApellidoMaterno  varchar(124), 
@Nombres  varchar(124), 
@Cod_TipoParentesco  varchar(5), 
@Obs_Parentesco  varchar(1024),
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Cod_Personal, @Item_Parentesco FROM PRI_PERSONAL_PARENTESCO WHERE  (Cod_Personal = @Cod_Personal) AND (Item_Parentesco = @Item_Parentesco))
BEGIN
set @Item_Parentesco = (SELECT ISNULL(MAX(@Item_Parentesco),0)+1 FROM PRI_PERSONAL_PARENTESCO WHERE  (Cod_Personal = @Cod_Personal));
INSERT INTO PRI_PERSONAL_PARENTESCO  VALUES (
@Cod_Personal,
@Item_Parentesco,
@Cod_TipoDoc,
@Num_Doc,
@ApellidoPaterno,
@ApellidoMaterno,
@Nombres,
@Cod_TipoParentesco,
@Obs_Parentesco,
@Cod_Usuario,GETDATE(),NULL,NULL)

END
ELSE
BEGIN
UPDATE PRI_PERSONAL_PARENTESCO
SET
Cod_TipoDoc = @Cod_TipoDoc, 
Num_Doc = @Num_Doc, 
ApellidoPaterno = @ApellidoPaterno, 
ApellidoMaterno = @ApellidoMaterno, 
Nombres = @Nombres, 
Cod_TipoParentesco = @Cod_TipoParentesco, 
Obs_Parentesco = @Obs_Parentesco,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Cod_Personal = @Cod_Personal) AND (Item_Parentesco = @Item_Parentesco)
END
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_PERSONAL' ) 
    DROP VIEW VIS_PERSONAL
go
CREATE VIEW VIS_PERSONAL
WITH ENCRYPTION
AS
SELECT        P.Cod_Personal, P.Cod_TipoDoc, P.Num_Doc, P.ApellidoPaterno, P.ApellidoMaterno, P.PrimeroNombre, P.SegundoNombre, P.Direccion, P.Ref_Direccion, P.Telefono, P.Email, P.Fecha_Ingreso, 
                         P.Fecha_Nacimiento, P.Cod_Cargo, P.Cod_Estado, P.Cod_Area, P.Cod_Local, P.Cod_CentroCostos, P.Cod_EstadoCivil, P.Fecha_InsESSALUD, P.AutoGeneradoEsSalud, P.Cod_CuentaCTS, P.Num_CuentaCTS, 
                         P.Cod_BancoRemuneracion, P.Num_CuentaRemuneracion, P.Grupo_Sanguinio, P.Cod_AFP, P.AutoGeneradoAFP, P.Flag_CertificadoSalud, P.Flag_CertificadoAntPoliciales, P.Flag_CertificadorAntJudiciales, 
                         P.Flag_DeclaracionBienes, P.Flag_OtrosDocumentos, P.Cod_Sexo, P.Cod_UsuarioLogin, P.Obs_Personal, CTD.Nom_TipoDoc, VC.Nom_Cargo, VET.Nom_Estado, A.Des_Area, VL.Nom_Local, 
                         VCC.Nom_CentroCostos, VEC.Nom_EstadoCivil
FROM            PRI_PERSONAL AS P INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS CTD ON P.Cod_TipoDoc = CTD.Cod_TipoDoc INNER JOIN
                         VIS_CARGOS AS VC ON P.Cod_Cargo = VC.Cod_Cargo INNER JOIN
                         VIS_ESTADO_TRABAJADOR AS VET ON P.Cod_Estado = VET.Cod_Estado INNER JOIN
                         PRI_AREAS AS A ON P.Cod_Area = A.Cod_Area INNER JOIN
                         VIS_LOCALES AS VL ON P.Cod_Local = VL.Cod_Local INNER JOIN
                         VIS_CENTROS_COSTOS AS VCC ON P.Cod_CentroCostos = VCC.Cod_CentroCostos INNER JOIN
                         VIS_ESTADO_CIVIL AS VEC ON P.Cod_EstadoCivil = VEC.Cod_EstadoCivil
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PERSONAL_TP' AND type = 'P')
DROP PROCEDURE USP_PRI_PERSONAL_TP
go
CREATE PROCEDURE USP_PRI_PERSONAL_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Cod_Personal , Num_Doc , ApellidoPaterno , ApellidoMaterno , PrimeroNombre , SegundoNombre  , Nom_TipoDoc,Nom_Cargo,Nom_Estado
FROM (SELECT TOP 100 PERCENT Cod_Personal , Num_Doc , ApellidoPaterno , ApellidoMaterno , PrimeroNombre , SegundoNombre  , Nom_TipoDoc,Nom_Cargo,Nom_Estado,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_PERSONAL '+@ScripWhere+') aPRI_PERSONAL
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go
-- USP_BAN_CUENTA_BANCARIA_TDistintoDe ''
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_BANCARIA_TDistintoDe' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TDistintoDe
go
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TDistintoDe
@Cod_CuentaBancaria as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
declare @Cod_Moneda  varchar(5);
set @Cod_Moneda = (select Cod_Moneda from BAN_CUENTA_BANCARIA where Cod_CuentaBancaria = @Cod_CuentaBancaria)

declare @Cod_Sucursal  varchar(32);
set @Cod_Sucursal = (select Cod_Sucursal from BAN_CUENTA_BANCARIA where Cod_CuentaBancaria = @Cod_CuentaBancaria)

SELECT Cod_CuentaBancaria ,  Des_CuentaBancaria + ', SALDO ['+ convert( varchar,Saldo_Disponible)+']' AS Des_CuentaBancaria 
FROM BAN_CUENTA_BANCARIA
where Flag_Activo = 1 and Cod_Moneda=@Cod_Moneda and Cod_CuentaBancaria <> @Cod_CuentaBancaria
and Cod_Sucursal = @Cod_Sucursal
END
go

-- USP_BAN_CUENTA_TNroSiguienteXCodCuentaBancaria '0201-0100029092-12'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_TNroSiguienteXCodCuentaBancaria' AND type = 'P')
DROP PROCEDURE USP_BAN_CUENTA_TNroSiguienteXCodCuentaBancaria
go
CREATE PROCEDURE USP_BAN_CUENTA_TNroSiguienteXCodCuentaBancaria
@Cod_CuentaBancaria as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        TOP (1) ISNULL(MAX(convert(bigint,Nro_Operacion)), 0) + 1 
FROM            BAN_CUENTA_M
WHERE        (Cod_CuentaBancaria = @Cod_CuentaBancaria)

END
go
--Modificacion de metodo USP_PRI_CATEGORIA_TArbol para que reconosca los espacios en blanco
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_CATEGORIA_TArbol'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_CATEGORIA_TArbol
go
CREATE PROCEDURE USP_PRI_CATEGORIA_TArbol
    WITH ENCRYPTION
AS 
BEGIN
WITH CATEGORIAS (Cod_Categoria, Des_Categoria, Level, Ordenar,Cod_Padre)
AS
(
select Cod_Categoria,CONVERT( varchar(1024),Des_Categoria), 0 as Level,CONVERT( varchar(1024),Cod_Categoria),Cod_CategoriaPadre
from PRI_CATEGORIA
where Cod_CategoriaPadre is null OR Cod_CategoriaPadre=''
UNION ALL
select c.Cod_Categoria,
CONVERT( varchar(1024),REPLICATE('',level+1)+'-->'+c.Des_Categoria), 
Level + 1, CONVERT( varchar(1024),Ordenar+c.Cod_Categoria),Cod_CategoriaPadre
from PRI_CATEGORIA AS C INNER JOIN CATEGORIAS AS CA
on  Cod_CategoriaPadre = ca.Cod_Categoria 
)
select Cod_Categoria,Des_Categoria, Level,ISNULL(Cod_Padre,'') as Cod_Padre 
from CATEGORIAS
ORDER BY Ordenar
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_TIPOCAMBIO' ) 
    DROP VIEW VIS_TIPOCAMBIO
go
CREATE VIEW VIS_TIPOCAMBIO
WITH ENCRYPTION
AS
SELECT        DATEPART(year, CAJ_TIPOCAMBIO.FechaHora) AS Año, DATEPART(MONTH, CAJ_TIPOCAMBIO.FechaHora) AS MesNumero, RIGHT('00' + CONVERT( varchar, DATEPART(MONTH, CAJ_TIPOCAMBIO.FechaHora)), 
                         2) + ' - ' + DATENAME(MONTH, CAJ_TIPOCAMBIO.FechaHora) AS Mes, AVG(CAJ_TIPOCAMBIO.Compra) AS PromedioCompra, AVG(CAJ_TIPOCAMBIO.Venta) AS PromedioVenta, AVG(CAJ_TIPOCAMBIO.SunatCompra) 
                         AS PromedioCompraSUNAT, AVG(CAJ_TIPOCAMBIO.SunatVenta) AS PromedioVentaSUNAT, VM.Cod_Moneda, VM.Nom_Moneda
FROM            CAJ_TIPOCAMBIO INNER JOIN
                         VIS_MONEDAS AS VM ON CAJ_TIPOCAMBIO.Cod_Moneda = VM.Cod_Moneda
GROUP BY DATEPART(year, CAJ_TIPOCAMBIO.FechaHora), DATEPART(MONTH, CAJ_TIPOCAMBIO.FechaHora), DATENAME(MONTH, CAJ_TIPOCAMBIO.FechaHora), VM.Cod_Moneda, VM.Nom_Moneda
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TIPOCAMBIO_TP' AND type = 'P')
DROP PROCEDURE USP_CAJ_TIPOCAMBIO_TP
go
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
DECLARE @ScripSQL  varchar(MAX)
SET @ScripSQL='SELECT NumeroFila,Año, MesNumero, Mes, PromedioCompra, PromedioVenta, PromedioCompraSUNAT, PromedioVentaSUNAT, Cod_Moneda, Nom_Moneda  
FROM (SELECT TOP 100 PERCENT Año, MesNumero, Mes, PromedioCompra, PromedioVenta, PromedioCompraSUNAT, PromedioVentaSUNAT, Cod_Moneda, Nom_Moneda,
  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
  FROM VIS_TIPOCAMBIO '+@ScripWhere+') aCAJ_TIPOCAMBIO
WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
EXECUTE(@ScripSQL); 
END
go
-- actualizar precios de compra y venta promedio
-- USP_PRI_PRODUCTO_STOCK_ActualizarPrecio '14'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_ActualizarPrecio' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_ActualizarPrecio
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_ActualizarPrecio
@Cod_Libro as  varchar(8)
WITH ENCRYPTION
AS
BEGIN

DECLARE @Id_Producto AS  int,
@Cod_Almacen AS  varchar(32),
@Cod_UnidadMedida AS  varchar(32);

DECLARE PRODUCTO_STOCK_cursor CURSOR FOR 
SELECT        S.Id_Producto, S.Cod_Almacen, S.Cod_UnidadMedida
FROM  PRI_PRODUCTO_STOCK AS S INNER JOIN
 CAJ_COMPROBANTE_D AS D ON S.Id_Producto = D.Id_Producto AND S.Cod_Almacen = D.Cod_Almacen AND S.Cod_UnidadMedida = D.Cod_UnidadMedida
GROUP BY S.Id_Producto, S.Cod_Almacen, S.Cod_UnidadMedida
HAVING COUNT(D.id_Detalle) > 0

OPEN PRODUCTO_STOCK_cursor

FETCH NEXT FROM PRODUCTO_STOCK_cursor 
INTO @Id_Producto,@Cod_Almacen,@Cod_UnidadMedida

WHILE @@FETCH_STATUS = 0
BEGIN
        -- SUMAR Y RESTAR LOS MOVIMIENTOS DE LA CUENTA
if (@Cod_Libro = '14')
BEGIN
UPDATE PRI_PRODUCTO_STOCK
SET Precio_Venta = 
(SELECT      isnull(SUM(CASE Cod_Moneda WHEN 'PEN' THEN d.Cantidad * D.PrecioUnitario 
ELSE d.Cantidad * D.PrecioUnitario*TipoCambio END)/SUM(d.Cantidad),0)
FROM            CAJ_COMPROBANTE_D AS D INNER JOIN
 CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago

where  P.Cod_Libro=@Cod_Libro and D.Id_Producto=@Id_Producto AND D.Cod_Almacen=@Cod_Almacen 
AND D.Cod_UnidadMedida=@Cod_UnidadMedida
having SUM(d.Cantidad) > 0 )
where  Id_Producto=@Id_Producto AND Cod_Almacen=@Cod_Almacen AND Cod_UnidadMedida=@Cod_UnidadMedida
END
if (@Cod_Libro = '08')
BEGIN
UPDATE PRI_PRODUCTO_STOCK
SET Precio_Compra = 
(SELECT      isnull(SUM(CASE Cod_Moneda WHEN 'PEN' THEN d.Cantidad * D.PrecioUnitario ELSE d.Cantidad * D.PrecioUnitario*TipoCambio END)/SUM(d.Cantidad),0)
FROM            CAJ_COMPROBANTE_D AS D INNER JOIN
 CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
where  P.Cod_Libro=@Cod_Libro and D.Id_Producto=@Id_Producto AND D.Cod_Almacen=@Cod_Almacen 
AND D.Cod_UnidadMedida=@Cod_UnidadMedida
having SUM(d.Cantidad) > 0 )
where  Id_Producto=@Id_Producto AND Cod_Almacen=@Cod_Almacen AND Cod_UnidadMedida=@Cod_UnidadMedida
END

FETCH NEXT FROM PRODUCTO_STOCK_cursor 
INTO @Id_Producto,@Cod_Almacen,@Cod_UnidadMedida
END 
CLOSE PRODUCTO_STOCK_cursor;
DEALLOCATE PRODUCTO_STOCK_cursor;
END
go
-- Traer Por Claves primarias 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_ActividadEconomica_TXId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_ActividadEconomica_TXId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_ActividadEconomica_TXId_ClienteProveedor 
@Id_ClienteProveedor int
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_ActividadEconomica, Id_ClienteProveedor, CIIU, Escala, Des_ActividadEconomica, Flag_Activo
FROM PRI_ACTIVIDADES_ECONOMICAS
WHERE (Id_ClienteProveedor = @Id_ClienteProveedor)
END
go

-- USP_ParametrosDelProcedimiento 'USP_CAJ_TURNO_ATENCION_I'
IF EXISTS(SELECT 1 FROM sysobjects WHERE type='P' AND name= 'USP_ParametrosDelProcedimiento')
DROP PROCEDURE USP_ParametrosDelProcedimiento
GO
CREATE PROCEDURE USP_ParametrosDelProcedimiento 
@in_NombreProcedimiento  varchar(300)
AS
BEGIN
DECLARE @var_NombreProcedimiento  varchar(300);
SET @var_NombreProcedimiento ='[dbo].['+@in_NombreProcedimiento+']';
SELECT SCHEMA_NAME(schema_id) AS schema_name
,o.name AS object_name
,o.type_desc
,p.parameter_id
,p.name AS parameter_name
,TYPE_NAME(p.user_type_id) AS parameter_type
,p.max_length
,p.precision
,p.scale
,p.is_output
FROM sys.objects AS o
INNER JOIN sys.parameters AS p ON o.object_id = p.object_id
WHERE o.object_id = OBJECT_ID(''+@var_NombreProcedimiento+'')
ORDER BY schema_name,  p.parameter_id,o.name;
END
GO
-- Importar turno atencioon
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TURNO_ATENCION_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_TURNO_ATENCION_I
go
CREATE PROCEDURE USP_CAJ_TURNO_ATENCION_I 
	@Cod_Turno	varchar(32), 
	@Des_Turno	varchar(512), 
	@Fecha_Inicio	datetime, 
	@Fecha_Fin	datetime, 
	@Flag_Cerrado	bit,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM CAJ_TURNO_ATENCION WHERE  (Cod_Turno = @Cod_Turno))
	BEGIN
		INSERT INTO CAJ_TURNO_ATENCION  VALUES (
		@Cod_Turno,
		@Des_Turno,
		@Fecha_Inicio,
		@Fecha_Fin,
		@Flag_Cerrado,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE CAJ_TURNO_ATENCION
		SET	
			Des_Turno = @Des_Turno, 
			Fecha_Inicio = @Fecha_Inicio, 
			Fecha_Fin = @Fecha_Fin, 
			Flag_Cerrado = @Flag_Cerrado,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Turno = @Cod_Turno)	
	END
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_BAN_CUENTA_M_i' AND type = 'P')
	DROP PROCEDURE USP_BAN_CUENTA_M_I
go
CREATE PROCEDURE USP_BAN_CUENTA_M_I 
	@Cod_CuentaBancaria	varchar(32), 
	@Nro_Operacion	varchar(32), 
	@Des_Movimiento	varchar(512), 
	@Cod_TipoOperacionBancaria	varchar(8), 
	@Fecha	datetime, 
	@Monto	numeric(38,2), 
	@TipoCambio	numeric(10,4), 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Cod_Plantilla	varchar(32), 
	@Nro_Cheque	varchar(32), 
	@Beneficiario	varchar(512), 
	@Id_ComprobantePago	int, 
	@Obs_Movimiento	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_MovimientoCuenta	int = (SELECT Id_MovimientoCuenta FROM BAN_CUENTA_M WHERE Cod_CuentaBancaria=@Cod_CuentaBancaria)
IF NOT EXISTS (SELECT * FROM BAN_CUENTA_M WHERE  (Id_MovimientoCuenta = @Id_MovimientoCuenta))
	BEGIN
		INSERT INTO BAN_CUENTA_M  VALUES (
		@Cod_CuentaBancaria,
		@Nro_Operacion,
		@Des_Movimiento,
		@Cod_TipoOperacionBancaria,
		@Fecha,
		@Monto,
		@TipoCambio,
		@Cod_Caja,
		@Cod_Turno,
		@Cod_Plantilla,
		@Nro_Cheque,
		@Beneficiario,
		@Id_ComprobantePago,
		@Obs_Movimiento,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE BAN_CUENTA_M
		SET	
			Cod_CuentaBancaria = @Cod_CuentaBancaria, 
			Nro_Operacion = @Nro_Operacion, 
			Des_Movimiento = @Des_Movimiento, 
			Cod_TipoOperacionBancaria = @Cod_TipoOperacionBancaria, 
			Fecha = @Fecha, 
			Monto = @Monto, 
			TipoCambio = @TipoCambio, 
			Cod_Caja = @Cod_Caja, 
			Cod_Turno = @Cod_Turno, 
			Cod_Plantilla = @Cod_Plantilla, 
			Nro_Cheque = @Nro_Cheque, 
			Beneficiario = @Beneficiario, 
			Id_ComprobantePago = @Id_ComprobantePago, 
			Obs_Movimiento = @Obs_Movimiento,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_MovimientoCuenta = @Id_MovimientoCuenta)	
	END
END
go
-- USP_CAJ_TRANSFERENCIAS_TXOrigenDestinoEstado NULL,'300',0,'001'
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_TRANSFERENCIAS_TXOrigenDestinoEstado'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_TRANSFERENCIAS_TXOrigenDestinoEstado
go
CREATE PROCEDURE USP_CAJ_TRANSFERENCIAS_TXOrigenDestinoEstado
@Cod_SucursalOrigen  varchar(32) = null,
@Cod_SucursalDestino as  varchar(32) = null,
@Flag_Caja as bit = null,
    @Cod_Estado  varchar(5)
    WITH ENCRYPTION
AS 
    BEGIN
     SELECT DISTINCT 
                         T.Id_Transferencia, T.Fecha_Emision, T.Cod_UsuarioEmision, T.id_ClienteEmisor, T.id_ClienteBeneficiarioP, T.id_ClienteBeneficiarioS, T.Cod_Moneda, 
                         T.Monto,T.Comision, T.Otros, T.Cod_Origen, T.Cod_Destino, T.Cod_Banco, 
                         T.Num_Cuenta, T.Cod_EstadoTransferencia, T.Obs_Tranferencia, CE.Cliente AS Emisor, CP.Cliente AS Beneficiario1, CE.Cliente AS Beneficiario2, 
                         M.Nom_Moneda, B.Nom_EntidadFinanciera, SO.Nom_Sucursal AS Origen, SD.Nom_Sucursal AS Destino, ET.Nom_EstadoTransferencia, CP.Nro_Documento, 
                         CM.Cod_TipoComprobante+':'+ CM.Serie+'-'+ CM.Numero as Solicitud
FROM            VIS_ENTIDADES_FINANCIERAS AS B RIGHT OUTER JOIN
                         CAJ_TRANSFERENCIAS AS T ON B.Cod_EntidadFinanciera = T.Cod_Banco INNER JOIN
                         VIS_MONEDAS AS M ON T.Cod_Moneda = M.Cod_Moneda INNER JOIN
                         VIS_ESTADO_TRANSFERENCIA AS ET ON T.Cod_EstadoTransferencia = ET.Cod_EstadoTransferencia INNER JOIN
                         PRI_SUCURSAL AS SO ON T.Cod_Origen = SO.Cod_Sucursal INNER JOIN
                         PRI_SUCURSAL AS SD ON T.Cod_Destino = SD.Cod_Sucursal LEFT OUTER JOIN
                         CAJ_CAJA_MOVIMIENTOS AS CM ON T.Id_MovimientoSolicitud = CM.id_Movimiento INNER JOIN 
                         PRI_CLIENTE_PROVEEDOR AS CE ON T.id_ClienteEmisor = CE.Id_ClienteProveedor INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CP ON T.id_ClienteBeneficiarioP = CP.Id_ClienteProveedor LEFT OUTER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CS ON T.id_ClienteBeneficiarioS = CS.Id_ClienteProveedor
              
        WHERE   ( T.Cod_EstadoTransferencia = @Cod_Estado)
and (Cod_Origen = @Cod_SucursalOrigen or @Cod_SucursalOrigen is null)
and (Cod_Destino = @Cod_SucursalDestino or @Cod_SucursalDestino is null)
and ((@Flag_Caja = 1 AND Cod_Banco is null)
or (@Flag_Caja = 0 AND Cod_Banco is not null) or @Flag_Caja is null)
ORDER BY Fecha_Emision
    END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_INVENTARIO_D_TxIdAlmacen' AND type = 'P')
DROP PROCEDURE USP_ALM_INVENTARIO_D_TxIdAlmacen
go
CREATE PROCEDURE USP_ALM_INVENTARIO_D_TxIdAlmacen
@Id_Inventario as int
WITH ENCRYPTION
AS
BEGIN
SELECT         ID.Item, ID.Id_Producto, P.Nom_Producto, ID.Cod_UnidadMedida, VUM.Nom_UnidadMedida, ID.Cod_Almacen, A.Des_Almacen, 
                         ID.Cantidad_Sistema, ID.Cantidad_Encontrada, ID.Obs_InventarioD
FROM            ALM_INVENTARIO_D AS ID INNER JOIN
                         PRI_PRODUCTOS AS P ON ID.Id_Producto = P.Id_Producto INNER JOIN
                         ALM_ALMACEN AS A ON ID.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VUM ON ID.Cod_UnidadMedida = VUM.Cod_UnidadMedida
where ID.Id_Inventario = @Id_Inventario
order by convert( int,ID.Item)
END
go
-- Este procedimiento traer todos los movimientos por autorizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_XAutorizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_XAutorizar
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_XAutorizar
@Cod_Sucursal as  varchar(32) = NULL,
@Cod_Caja as  varchar(32) = NULL
WITH ENCRYPTION
AS
BEGIN
SELECT        0 AS Selecionar, SU.Nom_Sucursal, CA.Des_Caja, CM.id_Movimiento, CM.Cliente, CM.Des_Movimiento, 
                         CM.Cod_TipoComprobante + ':' + CM.Serie + '-' + CM.Numero AS Documento, CM.Fecha, VM.Simbolo + ' ' + CONVERT( varchar(38), CM.Egreso) AS Monto, 
                         CM.Cod_Caja, CM.Cod_Turno
FROM            CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
                         CAJ_CAJAS AS CA ON CM.Cod_Caja = CA.Cod_Caja INNER JOIN
                         PRI_SUCURSAL AS SU ON CA.Cod_Sucursal = SU.Cod_Sucursal INNER JOIN
                         VIS_MONEDAS AS VM ON CM.Cod_MonedaEgr = VM.Cod_Moneda
WHERE        (CM.Cod_UsuarioAut IS NULL OR
                         CM.Cod_UsuarioAut = '') AND (@Cod_Sucursal = SU.Cod_Sucursal OR
                         @Cod_Sucursal IS NULL) AND (CA.Cod_Caja = @Cod_Caja) AND (CM.Flag_Extornado = 0) OR
                         (CM.Cod_UsuarioAut IS NULL OR
                         CM.Cod_UsuarioAut = '') AND (@Cod_Sucursal = SU.Cod_Sucursal OR
                         @Cod_Sucursal IS NULL) AND (CM.Flag_Extornado = 0) AND (@Cod_Caja IS NULL)
END
go
IF EXISTS ( SELECT  name FROM    sysobjects WHERE   name = 'UFN_PRI_PRODUCTO_PRECIO_TValor' AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_PRI_PRODUCTO_PRECIO_TValor
go
CREATE FUNCTION dbo.UFN_PRI_PRODUCTO_PRECIO_TValor ( @Id_Producto  int, 
@Cod_UnidadMedida varchar(5), 
@Cod_Almacen varchar(32), 
@Cod_TipoPrecio varchar(5) )
RETURNS  numeric(38,6)
    WITH ENCRYPTION
AS 
    BEGIN
    DECLARE @Valor as  numeric(38,6);        
    
    SET @Valor = (SELECT Valor 
FROM PRI_PRODUCTO_PRECIO
WHERE (Id_Producto = @Id_Producto) 
AND (Cod_UnidadMedida = @Cod_UnidadMedida) 
AND (Cod_Almacen = @Cod_Almacen) 
AND (Cod_TipoPrecio = @Cod_TipoPrecio))
    RETURN @Valor;
END
GO
-- actualizar SALDO DE LAS CUENTAS CORRIENTES
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CUE_CLIENTE_CUENTA_ActualizarSaldo' AND type = 'P')
DROP PROCEDURE USP_CUE_CLIENTE_CUENTA_ActualizarSaldo
go
CREATE PROCEDURE USP_CUE_CLIENTE_CUENTA_ActualizarSaldo
WITH ENCRYPTION
AS
BEGIN

DECLARE @Cod_Cuenta AS  varchar(32);

DECLARE CUENTA_cursor CURSOR FOR 
SELECT         Cod_Cuenta
FROM            CUE_CLIENTE_CUENTA
where Cod_TipoCuenta='COR'

OPEN CUENTA_cursor

FETCH NEXT FROM CUENTA_cursor 
INTO @Cod_Cuenta

WHILE @@FETCH_STATUS = 0
BEGIN
        -- SUMAR Y RESTAR LOS MOVIMIENTOS DE LA CUENTA
UPDATE CUE_CLIENTE_CUENTA
SET Saldo_Contable = (SELECT ISNULL(SUM(Ingreso-Egreso),0)
FROM CUE_CLIENTE_CUENTA_M
where Cod_Cuenta = @Cod_Cuenta), 
Saldo_Disponible = (SELECT ISNULL(SUM(Ingreso-Egreso),0)
FROM CUE_CLIENTE_CUENTA_M
where Cod_Cuenta = @Cod_Cuenta)
WHERE (Cod_Cuenta = @Cod_Cuenta)

FETCH NEXT FROM CUENTA_cursor 
INTO @Cod_Cuenta
END 
CLOSE CUENTA_cursor;
DEALLOCATE CUENTA_cursor;
END
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_TXid_ComprobantePago' AND type = 'P')
DROP PROCEDURE USP_CAJ_FORMA_PAGO_TXid_ComprobantePago
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_TXid_ComprobantePago
@id_ComprobantePago int
WITH ENCRYPTION
AS
BEGIN
	SELECT        FP.id_ComprobantePago, FP.Item, FP.Des_FormaPago, FP.Cod_TipoFormaPago, vFP.Nom_FormaPago, FP.Cuenta_CajaBanco, FP.Id_Movimiento, FP.TipoCambio, FP.Cod_Moneda, vM.Nom_Moneda, 
							 vM.Simbolo, vM.Definicion, FP.Monto, FP.Cod_Caja, FP.Cod_Turno, FP.Cod_Plantilla, FP.Fecha, C.Des_Caja
	FROM            CAJ_FORMA_PAGO AS FP INNER JOIN
							 VIS_FORMAS_PAGO AS vFP ON FP.Cod_TipoFormaPago = vFP.Cod_FormaPago INNER JOIN
							 VIS_MONEDAS AS vM ON FP.Cod_Moneda = vM.Cod_Moneda INNER JOIN
							 CAJ_CAJAS AS C ON FP.Cod_Caja = C.Cod_Caja
	where id_ComprobantePago=@id_ComprobantePago
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PLA_BIOMETRICO_TPersonalXHashHuella10' AND type = 'P')
DROP PROCEDURE USP_PLA_BIOMETRICO_TPersonalXHashHuella10
go
CREATE PROCEDURE USP_PLA_BIOMETRICO_TPersonalXHashHuella10
@HashHuella10 as  varchar(max)
WITH ENCRYPTION
AS
BEGIN
SELECT Cod_Personal 
FROM PLA_BIOMETRICO
where HashHuella10=@HashHuella10
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PLA_HORARIOS_TXTipo' AND type = 'P')
DROP PROCEDURE USP_PLA_HORARIOS_TXTipo
go
CREATE PROCEDURE USP_PLA_HORARIOS_TXTipo
@Cod_TipoHorario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT Id_Horario , Turno +' ['+CONVERT( varchar,HoraEntrada,108) +' - '+ CONVERT( varchar,HoraSalida,108) +'] : '+ Dias AS Horario
FROM PLA_HORARIOS
where Cod_TipoHorario=@Cod_TipoHorario
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PLA_PERSONAL_HORARIO_TXCodPersonal' AND type = 'P')
DROP PROCEDURE USP_PLA_PERSONAL_HORARIO_TXCodPersonal
go
CREATE PROCEDURE USP_PLA_PERSONAL_HORARIO_TXCodPersonal
@Cod_Personal as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        PH.Id_PersonalHorario, PH.Id_Horario, PH.Cod_Personal, PH.Fecha_Inicio, PH.Fecha_Fin, PH.Flag_Activo,
Turno +' ['+CONVERT( varchar,HoraEntrada,108) +' - '+ CONVERT( varchar,HoraSalida,108) +'] : '+ Dias AS Horario
FROM            PLA_PERSONAL_HORARIO AS PH INNER JOIN
                         PLA_HORARIOS AS h ON PH.Id_Horario = h.Id_Horario
where Cod_Personal=@Cod_Personal
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_D_TXclienteLicitacion' AND type = 'P')
DROP PROCEDURE USP_PRI_LICITACIONES_D_TXclienteLicitacion
go
CREATE PROCEDURE USP_PRI_LICITACIONES_D_TXclienteLicitacion
@Id_ClienteProveedor AS  int,
@Cod_Licitacion AS  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        LD.Id_ClienteProveedor, LD.Cod_Licitacion, LD.Nro_Detalle, LD.Id_Producto, LD.Cantidad, LD.Cod_UnidadMedida,
 LD.Descripcion, LD.Precio_Unitario, LD.Por_Descuento, VUM.Nom_UnidadMedida
FROM            PRI_LICITACIONES_D AS LD INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VUM ON LD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
where Id_ClienteProveedor=@Id_ClienteProveedor and Cod_Licitacion=@Cod_Licitacion
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_D_G' AND type = 'P')
DROP PROCEDURE USP_PRI_LICITACIONES_D_G
go
CREATE PROCEDURE USP_PRI_LICITACIONES_D_G 
@Id_ClienteProveedor  int, 
@Cod_LicitacioN varchar(32), 
@Nro_Detalle  int, 
@Id_Producto  int, 
@Cantidad numeric(38,2), 
@Cod_UnidadMedida varchar(5), 
@DescripcioN varchar(512), 
@Precio_Unitario numeric(38,6), 
@Por_Descuento numeric(5,2),
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT @Id_ClienteProveedor, @Cod_Licitacion, @Nro_Detalle FROM PRI_LICITACIONES_D WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle))
BEGIN
IF (@Nro_Detalle = 0)
BEGIN
SET @Nro_Detalle = (SELECT ISNULL(MAX(Nro_Detalle)+1,1) FROM PRI_LICITACIONES_D WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) )
END
INSERT INTO PRI_LICITACIONES_D  VALUES (
@Id_ClienteProveedor,
@Cod_Licitacion,
@Nro_Detalle,
@Id_Producto,
@Cantidad,
@Cod_UnidadMedida,
@Descripcion,
@Precio_Unitario,
@Por_Descuento,
@Cod_Usuario,GETDATE(),NULL,NULL)

END
ELSE
BEGIN
UPDATE PRI_LICITACIONES_D
SET
Id_Producto = @Id_Producto, 
Cantidad = @Cantidad, 
Cod_UnidadMedida = @Cod_UnidadMedida, 
Descripcion = @Descripcion, 
Precio_Unitario = @Precio_Unitario, 
Por_Descuento = @Por_Descuento,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle)
END
END
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_ALM_ALMACEN_MOV_TxCajaTurno' AND type = 'P')
	DROP PROCEDURE USP_ALM_ALMACEN_MOV_TxCajaTurno
go
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_TxCajaTurno
	@Cod_TipoComprobante as varchar(5) = null,
	@Cod_Caja as varchar(32),
	@Cod_Turno as VARCHAR(32)
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT dmy;	
		SELECT     amd.Id_AlmacenMov,  AM.Cod_TipoComprobante + ':' + AM.Serie + '-' + AM.Numero AS Comprobante, P.Des_CortaProducto, 
				   AM.Motivo, AM.Fecha, AMD.Cantidad,AMD.Precio_Unitario, A.Des_CortaAlmacen
	FROM            PRI_PRODUCTOS AS P INNER JOIN
							 ALM_ALMACEN_MOV_D AS AMD ON P.Id_Producto = AMD.Id_Producto INNER JOIN
							 ALM_ALMACEN_MOV AS AM ON AMD.Id_AlmacenMov = AM.Id_AlmacenMov INNER JOIN
							 VIS_TIPO_COMPROBANTES AS TC ON AM.Cod_TipoComprobante = TC.Cod_TipoComprobante INNER JOIN
							 ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen INNER JOIN
							 CAJ_CAJA_ALMACEN AS AC ON AC.Cod_Almacen = A.Cod_Almacen
	where (AM.Cod_TipoComprobante = @Cod_TipoComprobante or @Cod_TipoComprobante is null) and AC.Cod_Caja = @Cod_Caja and AM.Cod_Turno=@Cod_Turno
	ORDER BY Comprobante
END
GO
-- ANULAR transferencia
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TRANSFERENCIAS_EXTORNAR' AND type = 'P')
DROP PROCEDURE USP_CAJ_TRANSFERENCIAS_EXTORNAR
go
CREATE PROCEDURE USP_CAJ_TRANSFERENCIAS_EXTORNAR
@Id_Transferencia  int,
@Cod_Caja varchar(32), 
@Cod_Turno varchar(32), 
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
if (select Cod_EstadoTransferencia from CAJ_TRANSFERENCIAS WHERE (Id_Transferencia = @Id_Transferencia)) = '001'
BEGIN
UPDATE CAJ_TRANSFERENCIAS
SET
Cod_EstadoTransferencia = '004', 
Flag_Leido = 1, 
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Id_Transferencia = @Id_Transferencia)

declare @Id_MovimientoSolicitud as  int,
 @Id_MovimientoComision as  int,
 @Id_MovimientoOtros as  int,
 @Id_ComprobanteSolicitud as int;

SELECT @Id_MovimientoSolicitud= Id_MovimientoSolicitud, @Id_MovimientoComision=Id_MovimientoComision, 
@Id_MovimientoOtros=Id_MovimientoOtros, @Id_ComprobanteSolicitud=Id_ComprobanteSolicitud
FROM CAJ_TRANSFERENCIAS
WHERE (Id_Transferencia = @Id_Transferencia)

if (@Id_MovimientoSolicitud <> 0)
exec USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR @Id_MovimientoSolicitud,@Cod_Caja, @Cod_Turno,@Cod_Usuario;
if (@Id_MovimientoComision <> 0)
exec USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR @Id_MovimientoComision,@Cod_Caja, @Cod_Turno,@Cod_Usuario;
if (@Id_MovimientoOtros <> 0)
exec USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR @Id_MovimientoOtros,@Cod_Caja, @Cod_Turno,@Cod_Usuario;
-- extornar comprobante solo se anula nada mas.
if (@Id_ComprobanteSolicitud <> 0)
exec USP_CAJ_COMPROBANTE_PAGO_EXTORNAR @Id_ComprobanteSolicitud
END
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_DescripcionXComprobante'                    
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_DescripcionXComprobante
go
CREATE FUNCTION dbo.UFN_DescripcionXComprobante ( @id_ComprobantePago  int)
RETURNS  varchar(512)
    WITH ENCRYPTION
AS 
    BEGIN

DECLARE @Descripcion AS  varchar(512)

SET @Descripcion = STUFF(( SELECT distinct ' , ' + D.Descripcion
                                     FROM   CAJ_COMPROBANTE_D D
                                     WHERE  D.id_ComprobantePago = @id_ComprobantePago
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + '.'

set @Descripcion = (SELECT  top 1  CASE WHEN CD.Id_Producto = 0 THEN @Descripcion 
   WHEN CD.Id_Producto <> 0 AND CP.Cod_Libro = '14' THEN 'POR LA VENTA DE: ' +  @Descripcion
   WHEN CD.Id_Producto <> 0 AND CP.Cod_Libro = '08' THEN 'POR LA COMPRA DE: ' + @Descripcion
   WHEN CP.Flag_Anulado = 0 AND id_ComprobanteRef <> 0 THEN CP.Glosa
   ELSE CP.Glosa END
FROM            CAJ_COMPROBANTE_PAGO AS CP LEFT OUTER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
WHERE @id_ComprobantePago=CP.id_ComprobantePago
)
RETURN RTRIM(@Descripcion);
END
GO
--USP_MovimientosMaterialCajaTurno '101','25/02/2014'

-- resumen de cierre X o Z USP_CAJ_CAJAS_DOC_TicketeraXCaja '101'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJAS_DOC_TicketeraXCaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJAS_DOC_TicketeraXCaja
go
CREATE PROCEDURE USP_CAJ_CAJAS_DOC_TicketeraXCaja
@Cod_Caja  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT top 1 Nro_SerieTicketera
FROM CAJ_CAJAS_DOC
where Cod_Caja = @Cod_Caja and Nro_SerieTicketera <> ''

END
go
-- ANULAR MOVIMIENTOS
 -- exec USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR @id_Movimiento=34,@Cod_Caja='101',@Cod_Turno='09/07/2013',@Cod_Usuario='CUSCO'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR' AND type = 'P')
DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_EXTORNAR
@id_Movimiento  int,
@Cod_Caja varchar(32), 
@Cod_Turno varchar(32), 
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT Id_Transferencia FROM CAJ_TRANSFERENCIAS
WHERE Cod_EstadoTransferencia <> '004' AND (Id_MovimientoSolicitud = @id_Movimiento OR Id_MovimientoComision = @id_Movimiento
OR Id_MovimientoOtros= @id_Movimiento OR Id_MovimientoPago = @id_Movimiento) )
BEGIN -- es un movimiento normal
IF  EXISTS (SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS 
WHERE  (id_Movimiento = @id_Movimiento) AND (Cod_Caja = @Cod_Caja)
AND (Cod_Turno = @Cod_Turno))
BEGIN
UPDATE CAJ_CAJA_MOVIMIENTOS
SET
Ingreso = 0, 
Egreso = 0, 
Flag_Extornado = 1, 
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (id_Movimiento = @id_Movimiento)
IF EXISTS (SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS WHERE  (Id_MovimientoRef = @id_Movimiento) AND (Id_MovimientoRef <> 0))
BEGIN
UPDATE CAJ_CAJA_MOVIMIENTOS
SET
Ingreso = 0, 
Egreso = 0, 
Flag_Extornado = 1,
Cod_Turno = @Cod_Turno,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (id_Movimiento IN (SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS WHERE  (Id_MovimientoRef = @id_Movimiento)))
END
END
ELSE
BEGIN
--INSERTAR UNA OPERACION INVERTIDA
DECLARE @Cod_TipoComprobante varchar(5),
@Serie varchar(4), 
@Numero varchar(20);
SET @Cod_TipoComprobante = (SELECT TOP 1 CASE Cod_TipoComprobante WHEN 'RI' THEN 'RE' WHEN 'RE' THEN 'RI' ELSE Cod_TipoComprobante END
FROM CAJ_CAJA_MOVIMIENTOS
WHERE (id_Movimiento = @id_Movimiento))
SET @Serie = (SELECT TOP 1 Serie FROM CAJ_CAJAS_DOC WHERE  Cod_Caja = @Cod_Caja AND Cod_TipoComprobante=@Cod_TipoComprobante)
SET @Numero = (SELECT TOP 1 RIGHT('00000000'+CONVERT( varchar(38), ISNULL(CONVERT(BIGint,MAX(NUMERO)),0)+1), 8) 
FROM CAJ_CAJA_MOVIMIENTOS WHERE Serie = @Serie AND Cod_TipoComprobante=@Cod_TipoComprobante)
INSERT INTO CAJ_CAJA_MOVIMIENTOS  
SELECT @Cod_Caja, @Cod_Turno, Id_Concepto, Id_ClienteProveedor, Cliente, 'POR LA ANULACION DE MOVIMIENTO : ', 
CASE Cod_TipoComprobante WHEN 'RI' THEN 'RE' WHEN 'RE' THEN 'RI' ELSE Cod_TipoComprobante END, 
Serie, Numero, Fecha, Tipo_Cambio, Egreso,Cod_MonedaEgr , Ingreso, Cod_MonedaIng, Flag_Extornado, 
Cod_UsuarioAut, Fecha_Aut, Obs_Movimiento, @id_Movimiento, 
@Cod_Usuario,GETDATE(),NULL,NULL
FROM CAJ_CAJA_MOVIMIENTOS
WHERE (id_Movimiento = @id_Movimiento)

SET @id_Movimiento = @@IDENTITY 
END

-- VERIFICAR EL MOVIMIENTO DEL CLIENTE O PAGO DE TRANSFERENCIA
IF EXISTS(SELECT Id_ClienteCuentaMov FROM CUE_CLIENTE_CUENTA_M where id_MovimientoCaja = @id_Movimiento)
BEGIN
-- ENTONCES ELIMINAR EL MOVIMIENTO Y CALCULAR EL SALDO
DECLARE @Cod_Cuenta as  varchar(32);
set @Cod_Cuenta = (SELECT Cod_Cuenta FROM CUE_CLIENTE_CUENTA_M where id_MovimientoCaja = @id_Movimiento)
DECLARE @Monto  as  numeric(38,2);
set @Monto = (SELECT Egreso-Ingreso FROM CUE_CLIENTE_CUENTA_M where id_MovimientoCaja = @id_Movimiento)


UPDATE CUE_CLIENTE_CUENTA_M set Ingreso = 0, Egreso = 0, Flag_Extorno = 1, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()  
where id_MovimientoCaja = @id_Movimiento

UPDATE CUE_CLIENTE_CUENTA set Saldo_Contable = Saldo_Contable  + @Monto,Saldo_Disponible = Saldo_Disponible + @Monto,
 Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
WHERE Cod_Cuenta = @Cod_Cuenta
END
-- VERIFICAR MOVIMIENTOS EN FORMAS DE PAGO ACTUALIZAR EL MOVIMIENTO
IF EXISTS(SELECT id_ComprobantePago FROM CAJ_FORMA_PAGO where Id_Movimiento = @id_Movimiento)
BEGIN
UPDATE CAJ_FORMA_PAGO 
SET Des_FormaPago = 'ANULADO',
Monto = 0, Cod_UsuarioAct = @Cod_Usuario, Fecha_Act = GETDATE()
WHERE Id_Movimiento = @id_Movimiento
END
END
ELSE --es una transferencia de clientes
IF EXISTS(SELECT Id_Transferencia FROM CAJ_TRANSFERENCIAS
WHERE Cod_EstadoTransferencia = '002' AND (Id_MovimientoPago = @id_Movimiento) )
BEGIN
-- ACTUALIZAR 
DECLARE @Id_Transferencia INT
SET @Id_Transferencia = (SELECT Id_Transferencia FROM CAJ_TRANSFERENCIAS
WHERE Cod_EstadoTransferencia = '002' AND (Id_MovimientoPago = @id_Movimiento));

UPDATE CAJ_CAJA_MOVIMIENTOS
SET
Ingreso = 0, 
Egreso = 0, 
Flag_Extornado = 1, 
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (id_Movimiento = @id_Movimiento)
UPDATE CAJ_TRANSFERENCIAS
SET Cod_EstadoTransferencia = '001',
Id_MovimientoPago = 0,
Cod_UsuarioPago = NULL,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE Id_Transferencia=@Id_Transferencia

END

END

go
-- Traer lista de pendientes de despacho, de compra o de venta
-- USP_CAJ_COMPROBANTE_PAGO_TPendientesEntrega '08'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TPendientesEntrega' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TPendientesEntrega
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TPendientesEntrega
@Cod_Libro as  varchar(5)
WITH ENCRYPTION
AS
BEGIN
SELECT        CP.Cod_TipoComprobante+':'+ CP.Serie+' - '+ CP.Numero as Documento, CP.FechaEmision, 
CP.Doc_Cliente, CP.Nom_Cliente, CD.Descripcion, CD.Despachado,Cantidad - Despachado AS PorDespachar
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
WHERE Cod_Libro=@Cod_Libro AND Cantidad - Despachado > 0
END
go
-- USP_SaldosXCajaTurno '501','19/08/2013'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_SaldosXCajaTurno' AND type = 'P')
DROP PROCEDURE USP_SaldosXCajaTurno
go
CREATE PROCEDURE USP_SaldosXCajaTurno
@Cod_Caja as  varchar(32),
@Cod_Turno as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
set dateformat dmy;
		SELECT Moneda, SUM(SaldoInicial) AS SaldoInicial, SUM(Ingresos) AS Ingresos, SUM(Egresos) AS Egresos, SUM(SaldoInicial)+SUM(Ingresos)-SUM(Egresos) AS SaldoFinal
		FROM (
		SELECT VM.Nro, VM.Nom_Moneda AS Moneda,AFS.Monto as SaldoInicial, 0.00 as Ingresos, 0.00 as Egresos, 0.00 as SaldoFinal
		FROM            CAJ_ARQUEOFISICO_SALDO AS AFS INNER JOIN
		 CAJ_ARQUEOFISICO AS AF ON AFS.id_ArqueoFisico = AF.id_ArqueoFisico INNER JOIN
		 VIS_MONEDAS AS VM ON AFS.Cod_Moneda = VM.Cod_Moneda
		WHERE        (AF.Cod_Caja = @Cod_Caja) AND (AF.Cod_Turno = @Cod_Turno) AND (AFS.Tipo = 'SALDO INICIAL')
	UNION
		SELECT        VM.Nro,VM.Nom_Moneda AS Moneda, 0.00 AS SaldoInicial, 
		SUM(CASE WHEN Flag_Extornado = 0 THEN Ingreso ELSE 0 END) AS Ingreso, 0.00 AS Egresos, 0.00 AS SaldoFinal
		FROM CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
		 VIS_MONEDAS AS VM ON CM.Cod_MonedaIng = VM.Cod_Moneda
		WHERE        (CM.Cod_Caja = @Cod_Caja) AND (CM.Cod_Turno = @Cod_Turno) AND Cod_UsuarioAut is not null
		GROUP BY VM.Nro,VM.Nom_Moneda
	UNION
		SELECT        VM.Nro,VM.Nom_Moneda AS Moneda, 0.00 AS SaldoInicial, 0.00 as Ingresos,
		SUM(CASE WHEN Flag_Extornado = 0 THEN Egreso ELSE 0 END) AS Egresos, 0.00 AS SaldoFinal
		FROM CAJ_CAJA_MOVIMIENTOS AS CM INNER JOIN
		 VIS_MONEDAS AS VM ON CM.Cod_MonedaEgr = VM.Cod_Moneda
		WHERE        (CM.Cod_Caja = @Cod_Caja) AND (CM.Cod_Turno = @Cod_Turno) AND Cod_UsuarioAut is not null
		GROUP BY VM.Nro,VM.Nom_Moneda
	UNION
		SELECT        VM.Nro, VM.Nom_Moneda AS Moneda, 0.00 AS SaldoInicial, 
		SUM(CASE WHEN CP.Flag_Anulado = 0 AND CP.Cod_Libro = '14' and fp.Id_Movimiento = 0 THEN FP.Monto ELSE 0 END) AS Ingresos, SUM(CASE WHEN CP.Flag_Anulado = 0 AND 
                         CP.Cod_Libro = '08' and fp.Id_Movimiento = 0 THEN FP.Monto ELSE 0 END) AS Egresos, 0.00 AS SaldoFinal
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_FORMA_PAGO AS FP ON CP.id_ComprobantePago = FP.id_ComprobantePago INNER JOIN
                         VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
WHERE  (FP.Cod_Caja = @Cod_Caja) AND (FP.Cod_Turno = @Cod_Turno) AND (FP.Cod_TipoFormaPago = '008')
GROUP BY VM.Nro, VM.Nom_Moneda

) AS F
GROUP BY Moneda,Nro
order by Nro
END
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_ResumenXComprobanteRelacion' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_ResumenXComprobanteRelacion
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_ResumenXComprobanteRelacion
@id_ComprobantePagoRelacion  int
WITH ENCRYPTION
AS
BEGIN
SELECT        CD.Descripcion as Producto, SUM(CR.Valor) AS CantidadTotal, AVG(CD.PrecioUnitario) AS PrecioUnitario, SUM(CD.Sub_Total) AS Sub_Total
FROM            CAJ_COMPROBANTE_RELACION AS CR INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CR.id_ComprobantePago = CD.id_ComprobantePago AND CR.id_Detalle = CD.id_Detalle
WHERE        (CR.Id_ComprobanteRelacion = @id_ComprobantePagoRelacion)
GROUP BY CD.Descripcion
ORDER BY Producto
END
go

-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_E' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_E
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_E 
	@id_ComprobantePago	int, 
	@id_Detalle	int, 
	@Item	int
WITH ENCRYPTION
AS
BEGIN
	-- Antes de Eliminar Revertir la Formalizacion para Comprobante en Relacion}	
	UPDATE CAJ_COMPROBANTE_PAGO
		SET				
			id_ComprobanteRef = 0, 						
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago)	

	UPDATE CAJ_COMPROBANTE_D
		SET				
			Formalizado = Formalizado - (SELECT Valor FROM CAJ_COMPROBANTE_RELACION	
	WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle)),			
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle)	

	DELETE FROM CAJ_COMPROBANTE_RELACION	
	WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle) AND (Item = @Item)	
END
go
-- USP_PRI_LICITACIONES_NroDetalleXClienteLicitacionProducto 441,'003-8562',1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_NroDetalleXClienteLicitacionProducto' AND type = 'P')
DROP PROCEDURE USP_PRI_LICITACIONES_NroDetalleXClienteLicitacionProducto
go
CREATE PROCEDURE USP_PRI_LICITACIONES_NroDetalleXClienteLicitacionProducto
@Id_ClienteProveedor  int,
@Cod_Licitacion  varchar(32),
@Id_Producto int
WITH ENCRYPTION
AS
BEGIN
SELECT Nro_Detalle
FROM PRI_LICITACIONES_D
where Id_ClienteProveedor=@Id_ClienteProveedor and Cod_Licitacion=@Cod_Licitacion and Id_Producto=@Id_Producto
END
go
-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_M_G' AND type = 'P')
DROP PROCEDURE USP_PRI_LICITACIONES_M_G
go
CREATE PROCEDURE USP_PRI_LICITACIONES_M_G 
@Id_Movimiento int output, 
@Id_ClienteProveedor  int, 
@Cod_Licitacion  varchar(32), 
@Nro_Detalle  int, 
@id_ComprobantePago  int, 
@Flag_Cancelado  bit, 
@Obs_LicitacionesM  varchar(1024),
@Cod_Usuario  varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT Id_Movimiento FROM PRI_LICITACIONES_M WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor AND Cod_Licitacion=@Cod_Licitacion AND Nro_Detalle=@Nro_Detalle AND id_ComprobantePago = @id_ComprobantePago))
BEGIN
IF NOT EXISTS (SELECT @Id_Movimiento FROM PRI_LICITACIONES_M WHERE  (Id_Movimiento = @Id_Movimiento))
BEGIN
INSERT INTO PRI_LICITACIONES_M  VALUES (
@Id_ClienteProveedor,
@Cod_Licitacion,
@Nro_Detalle,
@id_ComprobantePago,
@Flag_Cancelado,
@Obs_LicitacionesM,
@Cod_Usuario,GETDATE(),NULL,NULL)
SET @Id_Movimiento = @@IDENTITY 
END
ELSE
BEGIN
UPDATE PRI_LICITACIONES_M
SET
Id_ClienteProveedor = @Id_ClienteProveedor, 
Cod_Licitacion = @Cod_Licitacion, 
Nro_Detalle = @Nro_Detalle, 
id_ComprobantePago = @id_ComprobantePago, 
Flag_Cancelado = @Flag_Cancelado, 
Obs_LicitacionesM = @Obs_LicitacionesM,
Cod_UsuarioAct = @Cod_Usuario, 
Fecha_Act = GETDATE()
WHERE (Id_Movimiento = @Id_Movimiento)
END
END
END
go
-- Modificar la Licitacion por otra
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_M_CambioLicitacion' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_M_CambioLicitacion
go
CREATE PROCEDURE USP_PRI_LICITACIONES_M_CambioLicitacion
	@Id_Movimiento	int, 	
	@Cod_Licitacion	varchar(32), 	
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF EXISTS (SELECT Id_Movimiento FROM PRI_LICITACIONES_M WHERE  (Id_Movimiento = @Id_Movimiento))	
	BEGIN
		UPDATE PRI_LICITACIONES_M
		SET				
			Cod_Licitacion = @Cod_Licitacion, 			
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Movimiento = @Id_Movimiento)	
	END
END
go

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_TItemMaximo' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TItemMaximo
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TItemMaximo
	@Id_ComprobanteRelacion int
WITH ENCRYPTION
AS
BEGIN
	SELECT isnull(max(Item) + 1,1)
	FROM CAJ_COMPROBANTE_RELACION
	where Id_ComprobanteRelacion = @Id_ComprobanteRelacion
END
go
-- Archivo: Script Procedimientos_1.sql
--
-- Versión: v1.0.0
--
-- Autor(es): Reyber Yuri Palma Quispe
--
-- Fecha de Creación:  11/07/2014
--
-- Copyright R&L Consultores Peru2014
IF OBJECT_ID (N'dbo.UFN_Percepcion', N'FN') IS NOT NULL
    DROP FUNCTION dbo.UFN_Percepcion;
GO
CREATE FUNCTION dbo.UFN_Percepcion ( @id_ComprobantePago int )
RETURNS numeric(38,2)
    WITH ENCRYPTION
AS 
    BEGIN
    DECLARE @TotalPercepcion as NUMERIC(38,2); 
    SET @TotalPercepcion = (SELECT  ISNULL(SUM(CD.Despachado),0) AS Total
FROM         CAJ_COMPROBANTE_D AS CD INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
                      WHERE cd.Tipo = 'PERCEPCION' AND CP.id_ComprobantePago = @id_ComprobantePago)
    RETURN @TotalPercepcion;
    END
GO
IF OBJECT_ID (N'dbo.Saldo_Cheque', N'FN') IS NOT NULL
    DROP FUNCTION dbo.Saldo_Cheque;
GO
CREATE FUNCTION dbo.Saldo_Cheque (@Id_MovimientoCuenta int)
RETURNS  numeric(38,2)
WITH EXECUTE AS CALLER
AS
BEGIN
     DECLARE @Saldo  numeric(38,2);
 SET @Saldo = 0;
     SET @Saldo = (SELECT        AVG(CASE WHEN CM.Monto < 0 THEN - 1 ELSE 1 END * CM.Monto) - ISNULL(SUM(FP.Monto), 0) AS Saldo
FROM            CAJ_FORMA_PAGO AS FP INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP ON FP.id_ComprobantePago = CP.id_ComprobantePago AND FP.Cuenta_CajaBanco IS NOT NULL RIGHT OUTER JOIN
                         BAN_CUENTA_M AS CM ON FP.Id_Movimiento = CM.Id_MovimientoCuenta
where Id_MovimientoCuenta = @Id_MovimientoCuenta --and FP.Cuenta_CajaBanco IS NOT NULL
)
     RETURN(@Saldo);
END;
GO
--SELECT dbo.Saldo_Cheque(6011)

-- FECHA DE ACTUALIZACION : 17/11/2014
-- AUTOR: RPALMA
-- Traer Todo USP_CAJ_COMPROBANTE_PAGO_TXPagarCobrar 0,'08','01/01/2000','12/12/2014',null,null,NULL
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TXPagarCobrar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXPagarCobrar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TXPagarCobrar
@Id_Cliente  int,
@Cod_Libro AS  varchar(5),
@FechaInicio as  datetime,
@FechaFin as  datetime,
@Cod_Moneda as   varchar(5) = null,
@Vencimiento as bit = NULL,
@Cod_Licitacion as  varchar(32) = NULL

WITH ENCRYPTION
AS
BEGIN
	SELECT        CP.id_ComprobantePago, CP.FechaEmision, CP.FechaVencimiento, 
				DATEDIFF(DAY, GETDATE(), CP.FechaVencimiento) AS Dias, 
				cp.Cod_TipoComprobante + ':' + CP.Serie + '-' + CP.Numero as Documento,
				AVG(CP.Total)- ISNULL(SUM(FP.Monto), 0) AS TotalFaltante, 
				CP.Nom_Cliente, CP.Doc_Cliente, CP.Id_Cliente, CP.Cod_TipoDoc, CP.Cod_Moneda, 
										 VM.Simbolo AS Moneda
	FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda LEFT OUTER JOIN
							 CAJ_FORMA_PAGO AS FP ON CP.id_ComprobantePago = FP.id_ComprobantePago LEFT OUTER JOIN
							 PRI_LICITACIONES_M AS M ON CP.id_ComprobantePago = M.id_ComprobantePago
		WHERE Cod_Libro = @Cod_Libro AND (Id_Cliente = @Id_Cliente or @Id_Cliente = 0 ) 
		AND (M.Cod_Licitacion = @Cod_Licitacion OR @Cod_Licitacion IS NULL) and (cp.FechaEmision between @FechaInicio and @FechaFin)
	AND (@Cod_Moneda = CP.Cod_Moneda or @Cod_Moneda is null)
	AND (CP.Cod_FormaPago = '999') 
	AND CP.Flag_Anulado = 0
	AND cp.id_ComprobanteRef = 0
	AND ((@Vencimiento = 1 AND  DATEDIFF(DAY,GETDATE(), CP.FechaVencimiento) > 0) OR 
	(@Vencimiento = 0 AND  DATEDIFF(DAY,GETDATE(), CP.FechaVencimiento) <= 0) OR @Vencimiento IS NULL)     
	-- quitar todos los que se llegaron a formalizar
	and (cp.id_ComprobantePago not in (SELECT        id_ComprobantePago 
FROM            CAJ_COMPROBANTE_RELACION where Cod_TipoRelacion = 'FOR' ))              
	GROUP BY CP.id_ComprobantePago, CP.FechaEmision, CP.FechaVencimiento, 
	CP.Total,cp.Cod_TipoComprobante + ':' + CP.Serie + '-' + CP.Numero, cp.Nom_Cliente, cp.Doc_Cliente,
	cp.Id_Cliente,cp.Cod_TipoDoc, cp.Cod_Moneda,VM.Simbolo
	having AVG(CP.Total) - ISNULL(SUM(FP.Monto), 0) > 0
	order by Nom_Cliente,FechaEmision
END
go
-- USP_CAJ_COMPROBANTE_PAGO_PendientePercepcionRetencion 'Cp','14'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_PendientePercepcionRetencion' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_PendientePercepcionRetencion
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_PendientePercepcionRetencion
@Cod_TipoComprobante as varchar(32),
@Cod_Libro AS VARCHAR(32)
WITH ENCRYPTION
AS
BEGIN
	IF (@Cod_TipoComprobante = 'CP')
	BEGIN
		-- CARGAR LAS FACTURAS DE LAS EMPRESAS QUE SON AGENTES DE RETENCION
SELECT        CP.id_ComprobantePago, CP.Cod_TipoComprobante+' : '+ CP.Serie+' - '+ CP.Numero as Comprobante, CP.Id_Cliente, 
CP.Cod_TipoDoc, CP.Doc_Cliente, CP.Nom_Cliente, CP.Direccion_Cliente, CP.FechaEmision, CP.Cod_Moneda, CP.Total, 
                         VM.Nom_Moneda, VM.Simbolo
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS C ON CP.Id_Cliente = C.Id_ClienteProveedor INNER JOIN
                         PRI_PADRONES AS P ON C.Id_ClienteProveedor = P.Id_ClienteProveedor INNER JOIN
                         VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
					WHERE CP.Cod_TipoComprobante IN (SELECT Cod_TipoComprobante FROM VIS_TIPO_COMPROBANTES WHERE Flag_RegistroVentas = 1)
					AND P.Cod_TipoPadron = 'P' AND GETDATE() BETWEEN P.Fecha_Inicio AND P.Fecha_Fin and cp.Cod_Libro = @Cod_Libro
					order by FechaEmision
	END
	ELSE IF (@Cod_TipoComprobante = 'CR')
	BEGIN
		SELECT        CP.id_ComprobantePago, CP.Cod_TipoComprobante+' : '+ CP.Serie+' - '+ CP.Numero as Comprobante, CP.Id_Cliente, CP.Cod_TipoDoc, CP.Doc_Cliente, CP.Nom_Cliente, CP.Direccion_Cliente, CP.FechaEmision, CP.Cod_Moneda, CP.Total, 
                         VM.Nom_Moneda, VM.Simbolo
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS C ON CP.Id_Cliente = C.Id_ClienteProveedor INNER JOIN
                         PRI_PADRONES AS P ON C.Id_ClienteProveedor = P.Id_ClienteProveedor INNER JOIN
                         VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
					WHERE CP.Cod_TipoComprobante IN (SELECT Cod_TipoComprobante FROM VIS_TIPO_COMPROBANTES WHERE Flag_RegistroCompras = 1)
					AND P.Cod_TipoPadron = 'R' AND GETDATE() BETWEEN P.Fecha_Inicio AND P.Fecha_Fin and cp.Cod_Libro = @Cod_Libro
					order by FechaEmision
	END

	
END
go
-- buscar clientes con condicion, como clientes con padrones agentes 

-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TXPadron' AND type = 'P')
	DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPadron
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPadron
@Buscar as varchar(512),
@Cod_TipoPadron as varchar(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT        CP.Id_ClienteProveedor, CP.Cod_TipoDocumento, CP.Nro_Documento, CP.Cliente, CP.Direccion, CP.Telefono1, CP.Email1, CP.Obs_Cliente, 
                         CP.Cod_EstadoCliente, CP.Ap_Paterno, CP.Ap_Materno, CP.Nombres, CP.Cod_CondicionCliente, CP.Cod_TipoCliente, CP.RUC_Natural, 
                         CP.Cod_TipoComprobante, CP.Cod_Nacionalidad, CP.Fecha_Nacimiento, CP.Cod_Sexo, CP.Email2, CP.Telefono2, CP.Fax, CP.PaginaWeb, CP.Cod_Ubigeo, 
                         CP.Cod_FormaPago, CP.Limite_Credito
FROM            PRI_CLIENTE_PROVEEDOR AS CP INNER JOIN
                         PRI_PADRONES AS P ON CP.Id_ClienteProveedor = P.Id_ClienteProveedor
						 where p.Cod_TipoPadron = @Cod_TipoPadron and (CP.Cliente like '%'+  +'%')
END
go
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_PRI_CLIENTE_TXCliente'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_PRI_CLIENTE_TXCliente
go
CREATE PROCEDURE USP_PRI_CLIENTE_TXCliente
	@Cod_TipoCliente as varchar(32) = NULL,
    @Cliente AS  varchar(512)
    WITH ENCRYPTION
AS 
    BEGIN
        SELECT        CP.Id_ClienteProveedor, CP.Cod_TipoDocumento, CP.Nro_Documento, CP.Cliente, CP.Ap_Paterno, CP.Ap_Materno, CP.Nombres, CP.Direccion, 
                         CP.Cod_EstadoCliente, CP.Cod_CondicionCliente, CP.Cod_TipoCliente, CP.RUC_Natural, CP.Cod_TipoComprobante, CP.Cod_Nacionalidad, 
                         CP.Fecha_Nacimiento, CP.Cod_Sexo, CP.Email1, CP.Email2, CP.Telefono1, CP.Telefono2, CP.Fax, CP.PaginaWeb, CP.Cod_Ubigeo, CP.Cod_FormaPago, 
                         CP.Limite_Credito, VTD.Nom_TipoDoc as Nom_TipoDocumento
FROM            PRI_CLIENTE_PROVEEDOR AS CP INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS VTD ON CP.Cod_TipoDocumento = VTD.Cod_TipoDoc
        WHERE   (Cliente like '%' +@Cliente + '%')   
		AND (CP.Cod_TipoCliente = @Cod_TipoCliente OR @Cod_TipoCliente IS NULL)               
         UNION -- AGREGAR TODOS LOS CLIENTE-PROVVEDORES
		  SELECT        CP.Id_ClienteProveedor, CP.Cod_TipoDocumento, CP.Nro_Documento, CP.Cliente, CP.Ap_Paterno, CP.Ap_Materno, CP.Nombres, CP.Direccion, 
                         CP.Cod_EstadoCliente, CP.Cod_CondicionCliente, CP.Cod_TipoCliente, CP.RUC_Natural, CP.Cod_TipoComprobante, CP.Cod_Nacionalidad, 
                         CP.Fecha_Nacimiento, CP.Cod_Sexo, CP.Email1, CP.Email2, CP.Telefono1, CP.Telefono2, CP.Fax, CP.PaginaWeb, CP.Cod_Ubigeo, CP.Cod_FormaPago, 
                         CP.Limite_Credito, VTD.Nom_TipoDoc as Nom_TipoDocumento
FROM            PRI_CLIENTE_PROVEEDOR AS CP INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS VTD ON CP.Cod_TipoDocumento = VTD.Cod_TipoDoc
        WHERE   (Cliente like '%' +@Cliente + '%')   
		AND (CP.Cod_TipoCliente = '003')                    
    END
go
-- Mostrar las mangueras apartir de una  
-- USP_VIS_MANGUERA_TXManguera '1B'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_MANGUERA_TXManguera' AND type = 'P')
	DROP PROCEDURE USP_VIS_MANGUERA_TXManguera
go
CREATE PROCEDURE USP_VIS_MANGUERA_TXManguera
	@Cod_Manguera AS VARCHAR(32)
WITH ENCRYPTION
AS
BEGIN
	declare @Cod_Caja as varchar(32), @Cod_Producto as int;

	SELECT     @Cod_Caja= VS.Cod_Caja, @Cod_Producto = VM.Cod_Producto
FROM            VIS_MANGUERAS AS VM INNER JOIN
                         VIS_SURTIDORES AS VS ON VM.Cod_Surtidor = VS.Cod_Surtidor
WHERE VM.Cod_Manguera= @Cod_Manguera

	SELECT        VM.Cod_Manguera, VM.Nom_Manguera
FROM            VIS_MANGUERAS AS VM INNER JOIN
                         VIS_SURTIDORES AS VS ON VM.Cod_Surtidor = VS.Cod_Surtidor
WHERE @Cod_Caja= VS.Cod_Caja AND @Cod_Producto = VM.Cod_Producto AND VM.Cod_Manguera <> @Cod_Manguera and vm.Estado = 1
END
go
-- cambiar la manguera
-- USP_CAJ_COMPROBANTE_D_CambiarManguera
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_D_CambiarManguera' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_D_CambiarManguera
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_CambiarManguera
	@id_ComprobantePago	int, 
	@id_Detalle	int, 	
	@Cod_Manguera	varchar(32), 	
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF EXISTS (SELECT @id_ComprobantePago, @id_Detalle FROM CAJ_COMPROBANTE_D WHERE  (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle))	
	BEGIN
		UPDATE CAJ_COMPROBANTE_D
		SET				
			Cod_Manguera = @Cod_Manguera, 			
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago) AND (id_Detalle = @id_Detalle)	
	END
END
go

-- Cambiar Turno
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_CambiarTurno' AND type = 'P')
	DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CambiarTurno
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_CambiarTurno
	@id_ComprobantePago	int output, 	
	@Cod_Turno	varchar(32), 	
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF EXISTS (SELECT @id_ComprobantePago FROM CAJ_COMPROBANTE_PAGO WHERE  (id_ComprobantePago = @id_ComprobantePago))	
	BEGIN
		UPDATE CAJ_COMPROBANTE_PAGO
		SET				
			Cod_Turno = @Cod_Turno, 			
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago)
		
		UPDATE dbo.CAJ_FORMA_PAGO
		SET				
			Cod_Turno = @Cod_Turno, 			
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_ComprobantePago = @id_ComprobantePago)	
	END
END
go
-- USP_PRI_CLIENTE_CUENTABANCARIA_TXId_ClienteProveedor 1
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_CUENTABANCARIA_TXId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_TXId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_CLIENTE_CUENTABANCARIA_TXId_ClienteProveedor
@Id_ClienteProveedor as int
WITH ENCRYPTION
AS
BEGIN
SELECT     CCB.Id_ClienteProveedor, CCB.NroCuenta_Bancaria, CCB.Cod_EntidadFinanciera, CCB.Flag_Principal, CCB.Cuenta_Interbancaria, CCB.Obs_CuentaBancaria, 
                      EF.Nom_EntidadFinanciera,CCB.Des_CuentaBancaria + ' [' + CCB.NroCuenta_Bancaria +']' as CuentaBancaria,Des_CuentaBancaria
FROM         PRI_CLIENTE_CUENTABANCARIA AS CCB INNER JOIN
                      VIS_ENTIDADES_FINANCIERAS AS EF ON CCB.Cod_EntidadFinanciera = EF.Cod_EntidadFinanciera
where Id_ClienteProveedor = @Id_ClienteProveedor
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_TXComprobanteRelacion' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TXComprobanteRelacion
go

CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TXComprobanteRelacion
@id_ComprobantePagoRelacion  int
WITH ENCRYPTION
AS
BEGIN
SELECT        CR.id_ComprobantePago, CR.id_Detalle, CR.Item, CR.Cod_TipoRelacion, CP.Cod_TipoComprobante + ': ' + CP.Serie + ' - ' + CP.Numero AS Documento, CR.Valor, CD.Descripcion, CR.Obs_Relacion, 
                         CP.FechaEmision
FROM            CAJ_COMPROBANTE_RELACION AS CR INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS CP ON CR.id_ComprobantePago = CP.id_ComprobantePago INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CR.id_ComprobantePago = CD.id_ComprobantePago AND CR.id_Detalle = CD.id_Detalle AND CP.id_ComprobantePago = CD.id_ComprobantePago
WHERE        (CR.Id_ComprobanteRelacion = @id_ComprobantePagoRelacion)
ORDER BY FechaEmision
END
GO
   --  SELECT *,dbo.UFN_TotalXAlmaceN(Cod_almacen,'04/02/2013') AS TOTAL FROM dbo.ALM_ALMACEN
   IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'UFN_TotalXManguera'
                    AND type = 'FN' ) 
    DROP FUNCTION dbo.UFN_TotalXManguera
go
CREATE FUNCTION dbo.UFN_TotalXManguera ( @Cod_Manguera  varchar(32), @CodTurno  varchar(32) )
RETURNS  numeric(38,3)
    WITH ENCRYPTION
AS 
    BEGIN
    DECLARE @TotalAlmacen as  numeric(38,3); 
    SET @TotalAlmacen = (SELECT  ISNULL(SUM(CD.Despachado),0.000) AS Total
FROM         CAJ_COMPROBANTE_D AS CD INNER JOIN
                      CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
                      WHERE CP.Cod_Turno = @CodTurno AND CD.Cod_Manguera = @Cod_Manguera)
    RETURN @TotalAlmacen;
    END
    GO
-- USP_PRI_PADRONES_TxId_ClienteProveedor 2
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PADRONES_TxId_ClienteProveedor' AND type = 'P')
DROP PROCEDURE USP_PRI_PADRONES_TxId_ClienteProveedor
go
CREATE PROCEDURE USP_PRI_PADRONES_TxId_ClienteProveedor
@Id_ClienteProveedor int
WITH ENCRYPTION
AS
BEGIN
	SELECT        Cod_Padron, Id_ClienteProveedor, Cod_TipoPadron, Des_Padron, Fecha_Inicio, Fecha_Fin, Nro_Resolucion
	FROM            PRI_PADRONES
	where Id_ClienteProveedor=@Id_ClienteProveedor
END
go
-- USP_VIS_FAVORITOS_TXCaja '101'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_FAVORITOS_TXCaja' AND type = 'P')
	DROP PROCEDURE USP_VIS_FAVORITOS_TXCaja
go
CREATE PROCEDURE USP_VIS_FAVORITOS_TXCaja
	@Cod_Caja AS VARCHAR(32)
WITH ENCRYPTION
AS
BEGIN
	SELECT    DISTINCT  CA.Cod_Caja, PP.Id_Producto, PP.Cod_UnidadMedida, PP.Cod_Almacen, P.Nom_Producto, PP.Valor, 
                         P.Cod_TipoOperatividad,P.Cod_Producto,P.Des_CortaProducto,P.Des_LargaProducto,PS.Stock_Act,P.Flag_Stock
FROM           VIS_CAJA_PRODUCTOS AS VF INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON VF.Id_Producto = PP.Id_Producto INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON PP.Cod_Almacen = CA.Cod_Almacen INNER JOIN
                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
						 PRI_PRODUCTO_STOCK as PS on P.Id_Producto=PS.Id_Producto
WHERE        (CA.Cod_Caja = @Cod_Caja) AND (PP.Cod_TipoPrecio = '001') 
END
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_MEDICION_VC_ValidarContometroXTurnoCaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_MEDICION_VC_ValidarContometroXTurnoCaja
go
CREATE PROCEDURE USP_CAJ_MEDICION_VC_ValidarContometroXTurnoCaja
@Cod_Turno as  varchar(32),
@Cod_Caja as  varchar(32)
WITH ENCRYPTION
AS
BEGIN
SELECT        M.Id_Medicion, M.Cod_AMedir, M.Medio_AMedir, M.Medida_Anterior, M.Medida_Actual, M.Fecha_Medicion
FROM            CAJ_MEDICION_VC AS M INNER JOIN
                         VIS_MANGUERAS AS VM ON M.Cod_AMedir = VM.Cod_Manguera INNER JOIN
                         VIS_SURTIDORES AS VS ON VM.Cod_Surtidor = VS.Cod_Surtidor
where Cod_Turno = @Cod_Turno  and Medio_AMedir = 'CONTOMETRO' AND  VS.Cod_Caja = @Cod_Caja
AND Medida_Anterior <> 0 and Medida_Actual = 0
END
go
IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_ARQUEOFISICO' ) 
    DROP VIEW VIS_ARQUEOFISICO
go
CREATE VIEW VIS_ARQUEOFISICO
WITH ENCRYPTION
AS
	SELECT        AF.id_ArqueoFisico, AF.Cod_Caja, AF.Cod_Turno, AF.Numero, AF.Des_ArqueoFisico, AF.Obs_ArqueoFisico, AF.Fecha, AF.Flag_Cerrado, C.Des_Caja, T.Des_Turno, T.Fecha_Inicio, T.Fecha_Fin, 
                         T.Flag_Cerrado AS Flag_CerradoTurno, S.Nom_Sucursal
FROM            CAJ_ARQUEOFISICO AS AF INNER JOIN
                         CAJ_CAJAS AS C ON AF.Cod_Caja = C.Cod_Caja INNER JOIN
                         CAJ_TURNO_ATENCION AS T ON AF.Cod_Turno = T.Cod_Turno INNER JOIN
                         PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
GO
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_TP' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_TP
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_TP
	@TamañoPagina varchar(16),
	@NumeroPagina varchar(16),
	@ScripOrden varchar(MAX) = NULL,
	@ScripWhere varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,id_ArqueoFisico, Cod_Caja, Cod_Turno, Numero, Des_ArqueoFisico, Obs_ArqueoFisico, Fecha, Flag_Cerrado, Des_Caja, Des_Turno, Fecha_Inicio, Fecha_Fin, Flag_CerradoTurno,Nom_Sucursal  
	FROM (SELECT TOP 100 PERCENT id_ArqueoFisico, Cod_Caja, Cod_Turno, Numero, Des_ArqueoFisico, Obs_ArqueoFisico, Fecha, Flag_Cerrado, Des_Caja, Des_Turno, Fecha_Inicio, Fecha_Fin, Flag_CerradoTurno,Nom_Sucursal,
		  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
		  FROM VIS_ARQUEOFISICO '+@ScripWhere+') aCAJ_ARQUEOFISICO
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 20/07/2015
-- OBJETIVO: Traer los Detalles del Arqueo, es decir los billetes
-- USP_CAJ_ARQUEOFISICO_D_TXid_ArqueoFisico 9
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_D_TXid_ArqueoFisico' AND type = 'P')
DROP PROCEDURE USP_CAJ_ARQUEOFISICO_D_TXid_ArqueoFisico
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_D_TXid_ArqueoFisico
@id_ArqueoFisico AS INT
WITH ENCRYPTION
AS
BEGIN
	SELECT        AFD.id_ArqueoFisico, AFD.Cod_Billete, isnull(AFD.Cantidad,0) as Cantidad, VB.Nom_Billete, VB.Valor_Billete, 
		VB.Cod_Moneda, isnull(AFD.Cantidad,0) *  VB.Valor_Billete as SubTotal
	FROM            CAJ_ARQUEOFISICO_D AS AFD RIGHT OUTER JOIN
							 VIS_BILLETES AS VB ON AFD.Cod_Billete = VB.Cod_Billete
	WHERE AFD.id_ArqueoFisico = @id_ArqueoFisico
END
go
-- Traer Todo
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_SALDO_TXId_ArqueoFisico' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_TXId_ArqueoFisico
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_SALDO_TXId_ArqueoFisico
@id_ArqueoFisico AS INT
WITH ENCRYPTION
AS
BEGIN
	SELECT        AF.id_ArqueoFisico, AF.Cod_Moneda, AF.Tipo, AF.Monto, VM.Nom_Moneda, VM.Simbolo
	FROM            CAJ_ARQUEOFISICO_SALDO AS AF INNER JOIN
							 VIS_MONEDAS AS VM ON AF.Cod_Moneda = VM.Cod_Moneda
	WHERE id_ArqueoFisico=@id_ArqueoFisico
	ORDER BY AF.Cod_Moneda, AF.Tipo
END
go
-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_ARQUEOFISICO_E' AND type = 'P')
	DROP PROCEDURE USP_CAJ_ARQUEOFISICO_E
go
CREATE PROCEDURE USP_CAJ_ARQUEOFISICO_E 
	@id_ArqueoFisico	int
WITH ENCRYPTION
AS
BEGIN	
	DELETE FROM CAJ_ARQUEOFISICO_D	
	WHERE (id_ArqueoFisico = @id_ArqueoFisico)	

	DELETE FROM dbo.CAJ_ARQUEOFISICO_SALDO	
	WHERE (id_ArqueoFisico = @id_ArqueoFisico)

	DELETE FROM CAJ_ARQUEOFISICO	
	WHERE (id_ArqueoFisico = @id_ArqueoFisico)	
END
go
IF EXISTS (SELECT name FROM sy
-- Eliminarsobjects WHERE name = 'USP_PRI_MODULO_E' AND type = 'P')
	DROP PROCEDURE USP_PRI_MODULO_E
go
CREATE PROCEDURE USP_PRI_MODULO_E 
	@Cod_Modulo	varchar(8)
WITH ENCRYPTION
AS
BEGIN
	DELETE FROM PRI_PERFIL_D
	WHERE (Cod_Modulo = @Cod_Modulo)

	DELETE FROM PRI_MODULO	
	WHERE (Cod_Modulo = @Cod_Modulo)	
END
go
-- Traer Por Claves primarias
--USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerieLibro 'TKB', '0011','14'
IF EXISTS ( SELECT  name
            FROM    sysobjects
            WHERE   name = 'USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerieLibro'
                    AND type = 'P' ) 
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerieLibro
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_NumeroXTipoSerieLibro
    @Cod_TipoComprobante  varchar(5) ,
    @Serie  varchar(4),
@CodLibro as  varchar(4)
    WITH ENCRYPTION
AS 
BEGIN
    SELECT     ISNULL(MAX(convert(int,Numero)) + 1, 1) AS NumeroSiguiente
	FROM         CAJ_COMPROBANTE_PAGO
	WHERE     (Serie = @Serie) AND (Cod_TipoComprobante = @Cod_TipoComprobante) and cod_libro = @CodLibro
END
go

-- Importar Productos
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTOS_I
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_I 
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
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTOS WHERE  (Cod_Producto = @Cod_Producto))
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
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE PRI_PRODUCTOS
		SET	
			Cod_Producto = @Cod_Producto, 
			Cod_Categoria = @Cod_Categoria, 
			--Cod_Marca = @Cod_Marca, 
			Cod_TipoProducto = @Cod_TipoProducto, 
			Nom_Producto = @Nom_Producto, 
			Des_CortaProducto = @Des_CortaProducto, 
			Des_LargaProducto = @Des_LargaProducto, 
			--Caracteristicas = @Caracteristicas, 
			Porcentaje_Utilidad = @Porcentaje_Utilidad, 
			Cuenta_Contable = @Cuenta_Contable, 
			Contra_Cuenta = @Contra_Cuenta, 
			Cod_Garantia = @Cod_Garantia, 
			Cod_TipoExistencia = @Cod_TipoExistencia, 
			Cod_TipoOperatividad = @Cod_TipoOperatividad, 
			Flag_Activo = @Flag_Activo, 
			Flag_Stock = @Flag_Stock, 
			--Cod_Fabricante = @Cod_Fabricante, 
			Obs_Producto = @Obs_Producto,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Cod_Producto = @Cod_Producto)	
	END
END
go

-- Importar producto stock
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_STOCK_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_I 
	@Cod_Producto	varchar(64), 
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
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto int =  (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_STOCK WHERE  (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen))
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
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen)	
	END
END
go

-- Importar producto precio
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_I
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_I
	@Cod_Producto	varchar(64), 
	@Cod_UnidadMedida	varchar(5), 
	@Cod_Almacen	varchar(32), 
	@Cod_TipoPrecio	varchar(5), 
	@Valor	numeric(38,6),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_Producto int = (SELECT TOP 1 Id_Producto FROM PRI_PRODUCTOS where Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT * FROM PRI_PRODUCTO_PRECIO WHERE  (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen) AND (Cod_TipoPrecio = @Cod_TipoPrecio))
	BEGIN
		INSERT INTO PRI_PRODUCTO_PRECIO  VALUES (
		@Id_Producto,
		@Cod_UnidadMedida,
		@Cod_Almacen,
		@Cod_TipoPrecio,
		@Valor,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_PRODUCTO_PRECIO
		SET	
			Valor = @Valor,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Producto = @Id_Producto) AND (Cod_UnidadMedida = @Cod_UnidadMedida) AND (Cod_Almacen = @Cod_Almacen) AND (Cod_TipoPrecio = @Cod_TipoPrecio)	
	END
END
go
--SELECT * FROM VIS_CLIENTE_PROVEEDOR

IF EXISTS ( SELECT  name  FROM    sysobjects WHERE   name = 'VIS_CLIENTE_PROVEEDOR' ) 
    DROP VIEW VIS_CLIENTE_PROVEEDOR
go
CREATE VIEW VIS_CLIENTE_PROVEEDOR
WITH ENCRYPTION
AS
	SELECT        CP.Id_ClienteProveedor, CP.Cod_TipoDocumento, CP.Nro_Documento, CP.Cliente, CP.Ap_Paterno, CP.Ap_Materno, CP.Nombres, CP.Direccion, CP.Cod_EstadoCliente, CP.Cod_CondicionCliente, 
				CP.Cod_TipoCliente, CP.RUC_Natural, CP.Cod_TipoComprobante, CP.Cod_Nacionalidad, CP.Fecha_Nacimiento, CP.Cod_Sexo, CP.Email1, CP.Email2, CP.Telefono1, CP.Telefono2, CP.Fax, CP.PaginaWeb, 
				CP.Cod_Ubigeo, CP.Cod_FormaPago, CP.Limite_Credito, CP.Obs_Cliente, CP.Cod_UsuarioReg, CP.Fecha_Reg, CP.Cod_UsuarioAct, CP.Fecha_Act, PA.Nom_Pais, SE.Nom_Sexo, TD.Nom_TipoDoc, 
				TC.Nom_TipoComprobante, CC.Nom_CondicionCliente, EC.Nom_EstadoCliente, FP.Nom_FormaPago, VTC.Nom_TipoCliente
	FROM            PRI_CLIENTE_PROVEEDOR AS CP INNER JOIN
					VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc INNER JOIN
					VIS_TIPO_COMPROBANTES AS TC ON CP.Cod_TipoComprobante = TC.Cod_TipoComprobante INNER JOIN
					VIS_SEXOS AS SE ON CP.Cod_Sexo = SE.Cod_Sexo INNER JOIN
					VIS_TIPO_CLIENTES AS VTC ON CP.Cod_TipoCliente = VTC.Cod_TipoCliente LEFT OUTER JOIN
					VIS_CONDICION_CLIENTE AS CC ON CP.Cod_CondicionCliente = CC.Cod_CondicionCliente LEFT OUTER JOIN
					VIS_ESTADO_CLIENTE AS EC ON CP.Cod_EstadoCliente = EC.Cod_EstadoCliente LEFT OUTER JOIN
					VIS_FORMAS_PAGO AS FP ON CP.Cod_FormaPago = FP.Cod_FormaPago LEFT OUTER JOIN
					VIS_PAISES AS PA ON CP.Cod_Nacionalidad = PA.Cod_Pais
GO

 --USP_PRI_CLIENTE_PROVEEDOR_TP '20','1',' ORDER BY Id_ClienteProveedor desc',''
-- Traer Paginado
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TP' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP
@TamañoPagina  varchar(16),
@NumeroPagina  varchar(16),
@ScripOrden  varchar(MAX) = NULL,
@ScripWhere  varchar(MAX) = NULL
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ScripSQL  varchar(MAX)
	SET @ScripSQL='SELECT NumeroFila,Id_ClienteProveedor, Cod_TipoDocumento, Nro_Documento, Cliente, 
	Ap_Paterno, Ap_Materno, Nombres, Direccion, Cod_EstadoCliente, 
						  Cod_CondicionCliente, Cod_TipoCliente, RUC_Natural, Cod_TipoComprobante, 
						  Cod_Nacionalidad, Fecha_Nacimiento, Cod_Sexo, Email1, Email2, Telefono1, 
						  Telefono2, Fax, PaginaWeb, Cod_Ubigeo, Cod_FormaPago, Limite_Credito, 
						  Obs_Cliente, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act, Nom_Pais, 
						  Nom_Sexo, Nom_TipoDoc, Nom_TipoComprobante, Nom_CondicionCliente, 
						  Nom_EstadoCliente, Nom_FormaPago 
	FROM (SELECT TOP 100 PERCENT Id_ClienteProveedor, Cod_TipoDocumento, 
	Nro_Documento, Cliente, Ap_Paterno, Ap_Materno, Nombres, Direccion, Cod_EstadoCliente, 
						  Cod_CondicionCliente, Cod_TipoCliente, RUC_Natural, Cod_TipoComprobante, 
						  Cod_Nacionalidad, Fecha_Nacimiento, Cod_Sexo, Email1, Email2, Telefono1, 
						  Telefono2, Fax, PaginaWeb, Cod_Ubigeo, Cod_FormaPago, Limite_Credito, 
						  Obs_Cliente, Cod_UsuarioReg, Fecha_Reg, Cod_UsuarioAct, Fecha_Act, Nom_Pais, 
						  Nom_Sexo, Nom_TipoDoc, Nom_TipoComprobante, Nom_CondicionCliente, 
						  Nom_EstadoCliente, Nom_FormaPago ,
	  ROW_NUMBER() OVER ('+@ScripOrden+') AS NumeroFila 
	  FROM  VIS_CLIENTE_PROVEEDOR '+@ScripWhere+') aPRI_CLIENTE_PROVEEDOR
	WHERE NumeroFila BETWEEN ('+@TamañoPagina+' * '+@NumeroPagina+')+1 AND '+@TamañoPagina+' * ('+@NumeroPagina+' + 1)'
	EXECUTE(@ScripSQL); 
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_I 
	@Cod_TipoDocumento int,
	@Nro_Documento varchar(32), 
	@Cod_Licitacion	varchar(32), 
	@Des_Licitacion	varchar(512), 
	@Cod_TipoLicitacion	varchar(5), 
	@Nro_Licitacion	varchar(16), 
	@Fecha_Inicio	datetime, 
	@Fecha_Facturacion	datetime, 
	@Flag_AlFinal	bit, 
	@Cod_TipoComprobante	varchar(5),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
IF NOT EXISTS (SELECT * FROM PRI_LICITACIONES WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion))
	BEGIN
		INSERT INTO PRI_LICITACIONES  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Des_Licitacion,
		@Cod_TipoLicitacion,
		@Nro_Licitacion,
		@Fecha_Inicio,
		@Fecha_Facturacion,
		@Flag_AlFinal,
		@Cod_TipoComprobante,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE PRI_LICITACIONES
		SET	
			Des_Licitacion = @Des_Licitacion, 
			Cod_TipoLicitacion = @Cod_TipoLicitacion, 
			Nro_Licitacion = @Nro_Licitacion, 
			Fecha_Inicio = @Fecha_Inicio, 
			Fecha_Facturacion = @Fecha_Facturacion, 
			Flag_AlFinal = @Flag_AlFinal, 
			Cod_TipoComprobante = @Cod_TipoComprobante,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_D_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_D_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_D_I 
	@Cod_TipoDocumento int,
	@Nro_Documento varchar(32), 
	@Cod_Licitacion	varchar(32), 
	@Nro_Detalle	int, 
	@Cod_Producto	varchar(32), 
	@Cantidad	numeric(38,2), 
	@Cod_UnidadMedida	varchar(5), 
	@Descripcion	varchar(512), 
	@Precio_Unitario	numeric(38,6), 
	@Por_Descuento	numeric(5,2),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor	int=(SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento and Nro_Documento=@Nro_Documento)
DECLARE @Id_Producto	int = (SELECT Id_Producto FROM PRI_PRODUCTOS WHERE Cod_Producto=@Cod_Producto)
IF NOT EXISTS (SELECT @Id_ClienteProveedor, @Cod_Licitacion, @Nro_Detalle FROM PRI_LICITACIONES_D WHERE  (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle))
	BEGIN
		INSERT INTO PRI_LICITACIONES_D  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Nro_Detalle,
		@Id_Producto,
		@Cantidad,
		@Cod_UnidadMedida,
		@Descripcion,
		@Precio_Unitario,
		@Por_Descuento,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		
	END
	ELSE
	BEGIN
		UPDATE PRI_LICITACIONES_D
		SET	
			Id_Producto = @Id_Producto, 
			Cantidad = @Cantidad, 
			Cod_UnidadMedida = @Cod_UnidadMedida, 
			Descripcion = @Descripcion, 
			Precio_Unitario = @Precio_Unitario, 
			Por_Descuento = @Por_Descuento,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_ClienteProveedor = @Id_ClienteProveedor) AND (Cod_Licitacion = @Cod_Licitacion) AND (Nro_Detalle = @Nro_Detalle)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_LICITACIONES_M_I' AND type = 'P')
	DROP PROCEDURE USP_PRI_LICITACIONES_M_I
go
CREATE PROCEDURE USP_PRI_LICITACIONES_M_I 
	@Cod_TipoDoc   varchar(4),
	@Doc_Cliente   varchar(32),
	@Cod_Licitacion	varchar(32), 
	@Nro_Detalle	int, 
	@Cod_Libro varchar(4),
	@Cod_TipoComprobante varchar(4),
	@Serie varchar(5),
	@Numero  varchar(32),
	@Cod_TipoDocC  varchar(4),
	@Doc_ClienteC   varchar(32),
	@Flag_Cancelado	bit, 
	@Obs_LicitacionesM	varchar(1024),
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @id_ComprobantePago INT=0;
	SET @id_ComprobantePago = (SELECT ISNULL(id_ComprobantePago,0) FROM CAJ_COMPROBANTE_PAGO
	WHERE Cod_Libro = @Cod_Libro
	AND Cod_TipoComprobante = @Cod_TipoComprobante
	AND Serie = @Serie
	AND Numero= @Numero
	AND Cod_TipoDoc = @Cod_TipoDoc
	AND Doc_Cliente = @Doc_Cliente)
DECLARE @Id_ClienteProveedor	int = (SELECT TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocC AND @Doc_ClienteC=Nro_Documento )
DECLARE @Id_Movimiento	int =(SELECT Id_Movimiento FROM PRI_LICITACIONES_M where Cod_Licitacion=@Cod_Licitacion and Nro_Detalle=@Nro_Detalle AND id_ComprobantePago=@id_ComprobantePago)
IF NOT EXISTS (SELECT @Id_Movimiento FROM PRI_LICITACIONES_M WHERE  (Id_Movimiento = @Id_Movimiento))
	BEGIN
		INSERT INTO PRI_LICITACIONES_M  VALUES (
		@Id_ClienteProveedor,
		@Cod_Licitacion,
		@Nro_Detalle,
		@id_ComprobantePago,
		@Flag_Cancelado,
		@Obs_LicitacionesM,
		@Cod_Usuario,GETDATE(),NULL,NULL)
		SET @Id_Movimiento = @@IDENTITY 
	END
	ELSE
	BEGIN
		UPDATE PRI_LICITACIONES_M
		SET	
			Id_ClienteProveedor = @Id_ClienteProveedor, 
			Cod_Licitacion = @Cod_Licitacion, 
			Nro_Detalle = @Nro_Detalle, 
			id_ComprobantePago = @id_ComprobantePago, 
			Flag_Cancelado = @Flag_Cancelado, 
			Obs_LicitacionesM = @Obs_LicitacionesM,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (Id_Movimiento = @Id_Movimiento)	
	END
END
go

-- Guadar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_CAJA_MOVIMIENTOS_I' AND type = 'P')
	DROP PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I
go
CREATE PROCEDURE USP_CAJ_CAJA_MOVIMIENTOS_I 
	@Cod_Caja	varchar(32), 
	@Cod_Turno	varchar(32), 
	@Id_Concepto	int, 
	@Cod_TipoDocumento	varchar (10), 
	@DocCliente	varchar(512), 
	@Des_Movimiento	varchar(512), 
	@Cod_TipoComprobante	varchar(5), 
	@Serie	varchar(4), 
	@Numero	varchar(20), 
	@Fecha	datetime, 
	@Tipo_Cambio	numeric(10,4), 
	@Ingreso	numeric(38,2), 
	@Cod_MonedaIng	varchar(3), 
	@Egreso	numeric(38,2), 
	@Cod_MonedaEgr	varchar(3), 
	@Flag_Extornado	bit, 
	@Cod_UsuarioAut	varchar(32), 
	@Fecha_Aut	datetime, 
	@Obs_Movimiento	xml, 
	@Id_MovimientoRef	int,
	@Cod_Usuario Varchar(32)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Id_ClienteProveedor int= (select TOP 1 Id_ClienteProveedor FROM PRI_CLIENTE_PROVEEDOR where Cod_TipoDocumento=@Cod_TipoDocumento AND Nro_Documento=@DocCliente)
DECLARE @Nom_Cliente varchar(MAX)= (select Nombres FROM PRI_CLIENTE_PROVEEDOR where Id_ClienteProveedor=@Id_ClienteProveedor)
DECLARE @id_Movimiento	int =(SELECT id_Movimiento FROM CAJ_CAJA_MOVIMIENTOS where Cod_TipoComprobante=@Cod_TipoComprobante and Serie=@Serie and Numero=@Numero
and Cod_Caja=@Cod_Caja and Cod_Turno =@Cod_Turno) 
IF NOT EXISTS (SELECT * FROM CAJ_CAJA_MOVIMIENTOS WHERE  (id_Movimiento = @id_Movimiento))
	BEGIN
		INSERT INTO CAJ_CAJA_MOVIMIENTOS  VALUES (
		@Cod_Caja,
		@Cod_Turno,
		@Id_Concepto,
		@Id_ClienteProveedor,
		@Nom_Cliente,
		@Des_Movimiento,
		@Cod_TipoComprobante,
		@Serie,
		@Numero,
		@Fecha,
		@Tipo_Cambio,
		@Ingreso,
		@Cod_MonedaIng,
		@Egreso,
		@Cod_MonedaEgr,
		@Flag_Extornado,
		@Cod_UsuarioAut,
		@Fecha_Aut,
		@Obs_Movimiento,
		@Id_MovimientoRef,
		@Cod_Usuario,GETDATE(),NULL,NULL)
	END
	ELSE
	BEGIN
		UPDATE CAJ_CAJA_MOVIMIENTOS
		SET	
			Cod_Caja = @Cod_Caja, 
			Cod_Turno = @Cod_Turno, 
			Id_Concepto = @Id_Concepto, 
			Id_ClienteProveedor = @Id_ClienteProveedor, 
			Cliente = @Nom_Cliente, 
			Des_Movimiento = @Des_Movimiento, 
			Cod_TipoComprobante = @Cod_TipoComprobante, 
			Serie = @Serie, 
			Numero = @Numero, 
			Fecha = @Fecha, 
			Tipo_Cambio = @Tipo_Cambio, 
			Ingreso = @Ingreso, 
			Cod_MonedaIng = @Cod_MonedaIng, 
			Egreso = @Egreso, 
			Cod_MonedaEgr = @Cod_MonedaEgr, 
			Flag_Extornado = @Flag_Extornado, 
			Cod_UsuarioAut = @Cod_UsuarioAut, 
			Fecha_Aut = @Fecha_Aut, 
			Obs_Movimiento = @Obs_Movimiento, 
			Id_MovimientoRef = @Id_MovimientoRef,
			Cod_UsuarioAct = @Cod_Usuario, 
			Fecha_Act = GETDATE()
		WHERE (id_Movimiento = @id_Movimiento)	
	END
END
go