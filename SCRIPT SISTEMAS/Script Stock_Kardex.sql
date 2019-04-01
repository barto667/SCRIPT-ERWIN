--Retorna el stock fisico de un almacen y una caja
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_StockFisico'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_StockFisico;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_StockFisico @Cod_Almacen        VARCHAR(32), --Obligatorio
                                              @Cod_UnidadMedida   VARCHAR(32) = NULL, 
                                              @Cod_Moneda         VARCHAR(5)  = NULL, 
                                              @Cod_Categoria      VARCHAR(32) = NULL, 
                                              @Cod_Marca          VARCHAR(32) = NULL, 
                                              @Cod_Caja           VARCHAR(32), --Obligatorio
                                              @Fecha              DATETIME, --Obligatorio
                                              --Filtros adicionales
                                              @Cod_EstadoProducto VARCHAR(2)  = '0', -- 0:Todos,1:Activos,2:Inactivos
                                              @Cod_StockProducto  VARCHAR(2)  = '0' -- 0:Todos,1:Con Stock,2:Sin Stock
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT *
        INTO [#VIS_UNIDADES_DE_MEDIDA]
        FROM VIS_UNIDADES_DE_MEDIDA;
        SELECT pp.Id_Producto, 
               pp.Cod_Producto, 
               pp.Nom_Producto, 
               pps.Cod_UnidadMedida, 
               vudm.Nom_UnidadMedida, 
               ROUND(ISNULL(
        (
            SELECT SUM(ccd.Cantidad) Vendidos
            FROM dbo.CAJ_COMPROBANTE_PAGO AS ccp
                 INNER JOIN dbo.CAJ_COMPROBANTE_D AS ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            WHERE ccp.Cod_Libro = '14'
                  AND ccd.Id_Producto = pp.Id_Producto
                  AND ccp.Flag_Anulado = 0
                  AND (@Cod_Almacen IS NULL
                       OR ccd.Cod_Almacen = @Cod_Almacen)
                  AND (@Cod_UnidadMedida IS NULL
                       OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
                  AND (@Cod_Moneda IS NULL
                       OR ccp.Cod_Moneda = @Cod_Moneda)
                  AND ccp.Cod_Caja = @Cod_Caja
                  AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha)))
            GROUP BY ccd.Id_Producto
        ), 0), 2) Total_Vendidos,
               CASE
                   WHEN pp.Flag_Stock = 1
                   THEN sc.StockCalculado
                   ELSE 0.00
               END Stock_Calculado, 
               ROUND(ISNULL(pps.Stock_Act, 0.00), 2) Stock_Act, 
               ROUND(ISNULL(pps.Precio_Compra, 0.00), 2) Precio_Compra, 
               ROUND(ISNULL(pps.Stock_Act, 0.00) * ISNULL(pps.Precio_Compra, 0.00), 2) Total
        FROM dbo.PRI_PRODUCTOS AS pp
             INNER JOIN dbo.PRI_PRODUCTO_STOCK AS pps ON pp.Id_Producto = pps.Id_Producto
             INNER JOIN
        (
            SELECT P.Id_Producto, 
                   P.Cod_Almacen, 
                   P.Cod_UnidadMedida, 
                   SUM(P.StockActual) StockCalculado
            FROM
            (
                SELECT CD.Id_Producto, 
                       CD.Cod_Almacen, 
                       CD.Cod_UnidadMedida, 
                       ISNULL(SUM(CASE CP.Cod_Libro
                                      WHEN '08'
                                      THEN CD.Cantidad
                                      WHEN '14'
                                      THEN-1 * CD.Cantidad
                                      ELSE 0
                                  END), 0) StockActual
                FROM CAJ_COMPROBANTE_PAGO AS CP
                     INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON CD.Id_Producto = PS.Id_Producto
                                                            AND CD.Cod_Almacen = PS.Cod_Almacen
                                                            AND CD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE Flag_Despachado = 1
                      AND Flag_Anulado = 0
                      AND CP.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha)))
                GROUP BY CD.Id_Producto, 
                         CD.Cod_Almacen, 
                         CD.Cod_UnidadMedida, 
                         PS.Stock_Act
                UNION
                SELECT AMD.Id_Producto, 
                       AM.Cod_Almacen, 
                       AMD.Cod_UnidadMedida, 
                       SUM(CASE AM.Cod_TipoComprobante
                               WHEN 'NE'
                               THEN AMD.Cantidad
                               WHEN 'NS'
                               THEN-1 * AMD.Cantidad
                               ELSE 0
                           END) StockActual
                FROM ALM_ALMACEN_MOV AS AM
                     INNER JOIN ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON AM.Cod_Almacen = PS.Cod_Almacen
                                                            AND AMD.Id_Producto = PS.Id_Producto
                                                            AND AMD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE AM.Fecha < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha)))
                      AND Flag_Anulado = 0
                GROUP BY AMD.Id_Producto, 
                         AM.Cod_Almacen, 
                         AMD.Cod_UnidadMedida, 
                         PS.Stock_Act
            ) AS P
            WHERE P.Cod_Almacen = @Cod_Almacen
                  AND (@Cod_UnidadMedida IS NULL
                       OR P.Cod_UnidadMedida = @Cod_UnidadMedida)
            GROUP BY P.Id_Producto, 
                     P.Cod_Almacen, 
                     P.Cod_UnidadMedida
        ) sc ON sc.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.#VIS_UNIDADES_DE_MEDIDA vudm ON pps.Cod_UnidadMedida = vudm.Cod_UnidadMedida
        WHERE(@Cod_UnidadMedida IS NULL
              OR pps.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND pps.Cod_Almacen = @Cod_Almacen
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
             AND (@Cod_Moneda IS NULL
                  OR pps.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_EstadoProducto = '0'
                  OR (@Cod_EstadoProducto = '1'
                      AND pp.Flag_Activo = 1)
                  OR (@Cod_EstadoProducto = '2'
                      AND pp.Flag_Activo = 0))
             AND (@Cod_StockProducto = '0'
                  OR (@Cod_StockProducto = '1'
                      AND pps.Stock_Act > 0)
                  OR (@Cod_StockProducto = '2'
                      AND pps.Stock_Act <= 0));
        DROP TABLE [#VIS_UNIDADES_DE_MEDIDA];
    END;
GO

--EXEC USP_PRI_PRODUCTOS_KardexValorizadoXPeriodo 
--     @Cod_Almacen = 'A101', 
--     @Id_Cliente = DEFAULT, 
--     @Cod_Categoria = DEFAULT, 
--     @Id_Producto = 1060, 
--     @Cod_Periodo = '2019-03', 
--     @Cod_UnidadMedida = 'NIU', 
--     @Cod_Moneda = DEFAULT;
--Procedimiento que obtiene el kardex valorizado
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTOS_KardexValorizadoXPeriodo'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_KardexValorizadoXPeriodo;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_KardexValorizadoXPeriodo @Cod_Almacen      VARCHAR(10), --Obligatorio
                                                            @Id_Cliente       INT         = NULL, 
                                                            @Cod_Categoria    VARCHAR(10) = NULL, 
                                                            @Id_Producto      INT, --Obligatorio
                                                            @Cod_Periodo      VARCHAR(32), --Obligatorio
                                                            @Cod_UnidadMedida VARCHAR(10), --Obligatorio
                                                            @Cod_Moneda       VARCHAR(10) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --DROP TABLE #kardexInicial
        --Creamos las tabla para saldo inicial
        CREATE TABLE #kardexInicial
        (Orden               INT, 
         Id                  INT, 
         Tabla               VARCHAR(100), 
         Fecha_Emision       DATETIME, 
         Cod_TipoComprobante VARCHAR(10), 
         Serie               VARCHAR(5), 
         Numero              VARCHAR(50), 
         Comprobante         VARCHAR(150), 
         Cod_Producto        VARCHAR(32), 
         Descripcion         VARCHAR(512), 
         Cantidad_Entrada    NUMERIC(38, 2), 
         Precio_Entrada      NUMERIC(38, 6), 
         Monto_Entrada       NUMERIC(38, 2), 
         Cantidad_Salida     NUMERIC(38, 2), 
         Precio_Salida       NUMERIC(38, 6), 
         Monto_Salida        NUMERIC(38, 2), 
         Cantidad_Saldo      NUMERIC(38, 2), 
         Precio_Saldo        NUMERIC(38, 6), 
         Monto_Saldo         NUMERIC(38, 2), 
         Orden_Aux           INT
        );
        --Introducimos los datos de todos lo comprobantes hasta la fecha
        INSERT INTO #kardexInicial
               SELECT KI.*, 
                      ROW_NUMBER() OVER(
                      ORDER BY KI.Fecha_Emision, 
                               KI.Orden, 
                               KI.Cod_TipoComprobante, 
                               KI.Serie, 
                               KI.Numero) Orden_Aux
               FROM
               (
                   SELECT DISTINCT 
                          CASE aam.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN 1
                              ELSE 2
                          END AS Orden, 
                          aam.Id_AlmacenMov, 
                          'ALM_ALMACEN_MOV' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR(32), aam.Fecha, 103)) Fecha_Emision, 
                          aam.Cod_TipoComprobante, 
                          aam.Serie, 
                          aam.Numero, 
                          CONCAT(aam.Cod_TipoComprobante, ':', aam.Serie, '-', aam.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          vto.Nom_TipoOperacion, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Entrada, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) AS Monto_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Salida, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.ALM_ALMACEN_MOV aam
                        INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON aamd.Id_Producto = pp.Id_Producto
                        INNER JOIN dbo.VIS_TIPO_OPERACIONES vto ON aam.Cod_TipoOperacion = vto.Cod_TipoOperacion
                        INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON aamd.Id_Producto = pps.Id_Producto
                        INNER JOIN dbo.VIS_PERIODOS vp ON aam.Fecha BETWEEN vp.Fecha_Inicio AND vp.Fecha_Fin
                   WHERE aam.Flag_Anulado = 0
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND aam.Cod_Almacen = @Cod_Almacen
                         AND aamd.Id_Producto = @Id_Producto
                         AND pp.Flag_Stock = 1
                         AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_Almacen = @Cod_Almacen
                         AND (@Cod_Moneda IS NULL
                              OR pps.Cod_Moneda = @Cod_Moneda)
                         AND vp.Cod_Periodo < @Cod_Periodo
                   GROUP BY aam.Cod_TipoComprobante, 
                            aam.Id_AlmacenMov, 
                            aam.Fecha, 
                            aam.Serie, 
                            aam.Numero, 
                            vto.Nom_TipoOperacion, 
                            pp.Cod_Producto
                   UNION
                   SELECT DISTINCT 
                          CASE ccp.Cod_Libro
                              WHEN '14'
                              THEN 2
                              WHEN '08'
                              THEN 1
                              ELSE 3
                          END Orden, 
                          ccp.id_ComprobantePago, 
                          'CAJ_COMPROBANTE_PAGO' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) Fecha_Emision, 
                          ccp.Cod_TipoComprobante, 
                          ccp.Serie, 
                          ccp.Numero, 
                          CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          ccp.Nom_Cliente, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '08'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Entrada, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Entrada, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '14'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Salida, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                        INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
                   WHERE ccp.Flag_Anulado = 0
                         AND ccp.Flag_Despachado = 1
                         AND pp.Flag_Stock = 1
                         AND ccd.Cod_Almacen = @Cod_Almacen
                         AND ccd.Id_Producto = @Id_Producto
                         AND (@Id_Cliente IS NULL
                              OR ccp.Id_Cliente = @Id_Cliente)
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND ccd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND (@Cod_Moneda IS NULL
                              OR ccp.Cod_Moneda = @Cod_Moneda)
                         AND ccp.Cod_Periodo < @Cod_Periodo
                   GROUP BY ccp.Cod_Libro, 
                            ccp.id_ComprobantePago, 
                            ccp.FechaEmision, 
                            ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero, 
                            ccp.Nom_Cliente, 
                            pp.Cod_Producto
               ) KI;

        --Actualizamos los totales del kardex inicial
        DECLARE @Cantidad NUMERIC(38, 2)= 0.00;
        DECLARE @Importe NUMERIC(38, 2)= 0.00;
        DECLARE @SCostoTotal NUMERIC(38, 2)= 0.00;
        DECLARE @TCostoUnitario NUMERIC(38, 6)= 0.00;
        DECLARE @CodProducto VARCHAR(32)= '';
        UPDATE #kardexInicial
          SET 
              @TCostoUnitario = #kardexInicial.Precio_Salida = CASE
                                                                   WHEN #kardexInicial.Cantidad_Salida IS NULL
                                                                   THEN NULL
                                                                   ELSE CASE
                                                                            WHEN ORDEN = 2
                                                                            THEN @TCostoUnitario
                                                                            ELSE 0.00
                                                                        END
                                                               END, 
              @SCostoTotal = #kardexInicial.Monto_Salida = CASE
                                                               WHEN #kardexInicial.Cantidad_Salida IS NULL
                                                               THEN NULL
                                                               ELSE CASE
                                                                        WHEN ORDEN = 2
                                                                        THEN ROUND(@TCostoUnitario * Cantidad_Salida, 2)
                                                                        ELSE 0.00
                                                                    END
                                                           END, 
              @Cantidad = #kardexInicial.Cantidad_Saldo = CASE
                                                              WHEN @CodProducto <> #kardexInicial.Cod_Producto
                                                              THEN ISNULL(#kardexInicial.Cantidad_Entrada, 0.00) - ISNULL(#kardexInicial.Cantidad_Salida, 0.00)
                                                              ELSE @Cantidad + ISNULL(#kardexInicial.Cantidad_Entrada, 0.00) - ISNULL(#kardexInicial.Cantidad_Salida, 0.00)
                                                          END, 
              @Importe = #kardexInicial.Monto_Saldo = @Importe + ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00), 
              @TCostoUnitario = #kardexInicial.Precio_Saldo = CASE
                                                                  WHEN @Cantidad = 0.00
                                                                  THEN 0.00
                                                                  ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                                              END, 
              @CodProducto = #kardexInicial.Cod_Producto;

        --Fusionamos con los demas kardex
        --Creamos el kardex final
        CREATE TABLE #kardexFinal
        (Orden               INT, 
         Id                  INT, 
         Tabla               VARCHAR(100), 
         Fecha_Emision       DATETIME, 
         Cod_TipoComprobante VARCHAR(10), 
         Serie               VARCHAR(5), 
         Numero              VARCHAR(50), 
         Comprobante         VARCHAR(150), 
         Cod_Producto        VARCHAR(32), 
         Descripcion         VARCHAR(512), 
         Cantidad_Entrada    NUMERIC(38, 2), 
         Precio_Entrada      NUMERIC(38, 6), 
         Monto_Entrada       NUMERIC(38, 2), 
         Cantidad_Salida     NUMERIC(38, 2), 
         Precio_Salida       NUMERIC(38, 6), 
         Monto_Salida        NUMERIC(38, 2), 
         Cantidad_Saldo      NUMERIC(38, 2), 
         Precio_Saldo        NUMERIC(38, 6), 
         Monto_Saldo         NUMERIC(38, 2), 
         Orden_Aux           INT
        );
        INSERT INTO #kardexFinal
               SELECT RES.*, 
                      ROW_NUMBER() OVER(
                      ORDER BY RES.Fecha_Emision, 
                               RES.Orden, 
                               RES.Cod_TipoComprobante, 
                               RES.Serie, 
                               RES.Numero)
               FROM
               (
                   --Seleccionamos el ultimo saldo del KardexInicial
                   SELECT T1.*
                   FROM
                   (
                       SELECT TOP 1 1 Orden, 
                                    ki.Id, 
                                    NULL Tabla, 
                                    NULL Fecha_Emision, 
                                    NULL Cod_TipoComprobante, 
                                    NULL Serie, 
                                    NULL Numero, 
                                    NULL Comprobante, 
                                    NULL Cod_Producto, 
                                    'SALDO INICIAL' Descripcion, 
                                    ki.Cantidad_Saldo Cantidad_Entrada, 
                                    ki.Precio_Saldo Precio_Entrada, 
                                    ki.Monto_Saldo Monto_Entrada, 
                                    NULL Cantidad_Salida, 
                                    NULL Precio_Salida, 
                                    NULL Monto_Salida, 
                                    NULL Cantidad_Saldo, 
                                    NULL Precio_Saldo, 
                                    NULL Monto_Saldo
                       FROM #kardexInicial ki
                       ORDER BY ki.Fecha_Emision DESC, 
                                ki.Orden DESC, 
                                ki.Cod_TipoComprobante DESC, 
                                ki.Serie DESC, 
                                ki.Numero DESC
                   ) T1
                   UNION
                   SELECT DISTINCT 
                          CASE aam.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN 1
                              ELSE 2
                          END AS Orden, 
                          aam.Id_AlmacenMov, 
                          'ALM_ALMACEN_MOV' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR(32), aam.Fecha, 103)) Fecha_Emision, 
                          aam.Cod_TipoComprobante, 
                          aam.Serie, 
                          aam.Numero, 
                          CONCAT(aam.Cod_TipoComprobante, ':', aam.Serie, '-', aam.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          vto.Nom_TipoOperacion, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Entrada, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) AS Monto_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Salida, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.ALM_ALMACEN_MOV aam
                        INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON aamd.Id_Producto = pp.Id_Producto
                        INNER JOIN dbo.VIS_TIPO_OPERACIONES vto ON aam.Cod_TipoOperacion = vto.Cod_TipoOperacion
                        INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON aamd.Id_Producto = pps.Id_Producto
                        INNER JOIN dbo.VIS_PERIODOS vp ON aam.Fecha BETWEEN vp.Fecha_Inicio AND vp.Fecha_Fin
                   WHERE aam.Flag_Anulado = 0
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND aam.Cod_Almacen = @Cod_Almacen
                         AND aamd.Id_Producto = @Id_Producto
                         AND pp.Flag_Stock = 1
                         AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_Almacen = @Cod_Almacen
                         AND (@Cod_Moneda IS NULL
                              OR pps.Cod_Moneda = @Cod_Moneda)
                         AND vp.Cod_Periodo = @Cod_Periodo
                   GROUP BY aam.Cod_TipoComprobante, 
                            aam.Id_AlmacenMov, 
                            aam.Fecha, 
                            aam.Serie, 
                            aam.Numero, 
                            vto.Nom_TipoOperacion, 
                            pp.Cod_Producto
                   UNION
                   SELECT DISTINCT 
                          CASE ccp.Cod_Libro
                              WHEN '14'
                              THEN 2
                              WHEN '08'
                              THEN 1
                              ELSE 3
                          END Orden, 
                          ccp.id_ComprobantePago, 
                          'CAJ_COMPROBANTE_PAGO' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) Fecha_Emision, 
                          ccp.Cod_TipoComprobante, 
                          ccp.Serie, 
                          ccp.Numero, 
                          CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          ccp.Nom_Cliente, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '08'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Entrada, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Entrada, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '14'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Salida, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                        INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
                   WHERE ccp.Flag_Anulado = 0
                         AND ccp.Flag_Despachado = 1
                         AND pp.Flag_Stock = 1
                         AND ccd.Cod_Almacen = @Cod_Almacen
                         AND ccd.Id_Producto = @Id_Producto
                         AND (@Id_Cliente IS NULL
                              OR ccp.Id_Cliente = @Id_Cliente)
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND ccd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND (@Cod_Moneda IS NULL
                              OR ccp.Cod_Moneda = @Cod_Moneda)
                         AND ccp.Cod_Periodo = @Cod_Periodo
                   GROUP BY ccp.Cod_Libro, 
                            ccp.id_ComprobantePago, 
                            ccp.FechaEmision, 
                            ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero, 
                            ccp.Nom_Cliente, 
                            pp.Cod_Producto
               ) RES;
        --Actualizamos el kardex Final
        SET @Cantidad = 0.00;
        SET @Importe = 0.00;
        SET @SCostoTotal = 0.00;
        SET @TCostoUnitario = 0.00;
        SET @CodProducto = '';
        UPDATE #kardexFinal
          SET 
              @TCostoUnitario = #kardexFinal.Precio_Salida = CASE
                                                                 WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                                      OR #kardexFinal.Cantidad_Salida = 0
                                                                 THEN NULL
                                                                 ELSE CASE
                                                                          WHEN #kardexFinal.ORDEN = 2
                                                                          THEN @TCostoUnitario
                                                                          ELSE 0.00
                                                                      END
                                                             END, 
              @SCostoTotal = #kardexFinal.Monto_Salida = CASE
                                                             WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                                  OR #kardexFinal.Cantidad_Salida = 0
                                                             THEN NULL
                                                             ELSE CASE
                                                                      WHEN ORDEN = 2
                                                                      THEN ROUND(@TCostoUnitario * Cantidad_Salida, 2)
                                                                      ELSE 0.00
                                                                  END
                                                         END, 
              @Cantidad = #kardexFinal.Cantidad_Saldo = CASE
                                                            WHEN @CodProducto <> #kardexFinal.Cod_Producto
                                                            THEN ISNULL(#kardexFinal.Cantidad_Entrada, 0.00) - ISNULL(#kardexFinal.Cantidad_Salida, 0.00)
                                                            ELSE @Cantidad + ISNULL(#kardexFinal.Cantidad_Entrada, 0.00) - ISNULL(#kardexFinal.Cantidad_Salida, 0.00)
                                                        END, 
              @Importe = #kardexFinal.Monto_Saldo = CASE
                                                        WHEN @CodProducto <> #kardexFinal.Cod_Producto
                                                        THEN ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00)
                                                        ELSE @Importe + ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00)
                                                    END, 
              @TCostoUnitario = #kardexFinal.Precio_Saldo = CASE
                                                                WHEN @Cantidad = 0.00
                                                                THEN 0.00
                                                                ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                                            END, 
              @CodProducto = #kardexFinal.Cod_Producto, 
              #kardexFinal.Cantidad_Salida = CASE
                                                 WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                      OR #kardexFinal.Cantidad_Salida = 0
                                                 THEN NULL
                                                 ELSE #kardexFinal.Cantidad_Salida
                                             END, 
              #kardexFinal.Cantidad_Entrada = CASE
                                                  WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                       OR #kardexFinal.Cantidad_Entrada = 0
                                                  THEN NULL
                                                  ELSE #kardexFinal.Cantidad_Entrada
                                              END, 
              #kardexFinal.Precio_Entrada = CASE
                                                WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                     OR #kardexFinal.Cantidad_Entrada = 0
                                                THEN NULL
                                                ELSE #kardexFinal.Precio_Entrada
                                            END, 
              #kardexFinal.Monto_Entrada = CASE
                                               WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                    OR #kardexFinal.Cantidad_Entrada = 0
                                               THEN NULL
                                               ELSE #kardexFinal.Monto_Entrada
                                           END;

        --Mostramos el ultimo kardex
        SELECT DISTINCT 
               kf.*
        FROM #kardexFinal kf
        ORDER BY kf.Fecha_Emision, 
                 kf.Orden, 
                 kf.Cod_TipoComprobante, 
                 kf.Serie, 
                 kf.Numero;

        --Eliminamos los temporales
        DROP TABLE #kardexInicial;
        DROP TABLE #kardexFinal;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTOS_KardexValorizadoXFecha'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_KardexValorizadoXFecha;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_KardexValorizadoXFecha @Cod_Almacen      VARCHAR(10), --Obligatorio
                                                          @Id_Cliente       INT         = NULL, 
                                                          @Cod_Categoria    VARCHAR(10) = NULL, 
                                                          @Id_Producto      INT, --Obligatorio
                                                          @Fecha_Inicio     DATETIME, --Obligatorio
                                                          @Fecha_Final      DATETIME, --Obligatorio
                                                          @Cod_UnidadMedida VARCHAR(10), --Obligatorio
                                                          @Cod_Moneda       VARCHAR(10) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --DROP TABLE #kardexInicial
        --Creamos las tabla para saldo inicial
        CREATE TABLE #kardexInicial
        (Orden               INT, 
         Id                  INT, 
         Tabla               VARCHAR(100), 
         Fecha_Emision       DATETIME, 
         Cod_TipoComprobante VARCHAR(10), 
         Serie               VARCHAR(5), 
         Numero              VARCHAR(50), 
         Comprobante         VARCHAR(150), 
         Cod_Producto        VARCHAR(32), 
         Descripcion         VARCHAR(512), 
         Cantidad_Entrada    NUMERIC(38, 2), 
         Precio_Entrada      NUMERIC(38, 6), 
         Monto_Entrada       NUMERIC(38, 2), 
         Cantidad_Salida     NUMERIC(38, 2), 
         Precio_Salida       NUMERIC(38, 6), 
         Monto_Salida        NUMERIC(38, 2), 
         Cantidad_Saldo      NUMERIC(38, 2), 
         Precio_Saldo        NUMERIC(38, 6), 
         Monto_Saldo         NUMERIC(38, 2), 
         Orden_Aux           INT
        );
        --Introducimos los datos de todos lo comprobantes hasta la fecha
        INSERT INTO #kardexInicial
               SELECT KI.*, 
                      ROW_NUMBER() OVER(
                      ORDER BY KI.Fecha_Emision, 
                               KI.Orden, 
                               KI.Cod_TipoComprobante, 
                               KI.Serie, 
                               KI.Numero) Orden_Aux
               FROM
               (
                   SELECT DISTINCT 
                          CASE aam.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN 1
                              ELSE 2
                          END AS Orden, 
                          aam.Id_AlmacenMov, 
                          'ALM_ALMACEN_MOV' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR(32), aam.Fecha, 103)) Fecha_Emision, 
                          aam.Cod_TipoComprobante, 
                          aam.Serie, 
                          aam.Numero, 
                          CONCAT(aam.Cod_TipoComprobante, ':', aam.Serie, '-', aam.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          vto.Nom_TipoOperacion, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Entrada, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) AS Monto_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Salida, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.ALM_ALMACEN_MOV aam
                        INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON aamd.Id_Producto = pp.Id_Producto
                        INNER JOIN dbo.VIS_TIPO_OPERACIONES vto ON aam.Cod_TipoOperacion = vto.Cod_TipoOperacion
                        INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON aamd.Id_Producto = pps.Id_Producto
                   WHERE aam.Flag_Anulado = 0
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND aam.Cod_Almacen = @Cod_Almacen
                         AND aamd.Id_Producto = @Id_Producto
                         AND pp.Flag_Stock = 1
                         AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_Almacen = @Cod_Almacen
                         AND (@Cod_Moneda IS NULL
                              OR pps.Cod_Moneda = @Cod_Moneda)
                         AND aam.Fecha < CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                   GROUP BY aam.Cod_TipoComprobante, 
                            aam.Id_AlmacenMov, 
                            aam.Fecha, 
                            aam.Serie, 
                            aam.Numero, 
                            vto.Nom_TipoOperacion, 
                            pp.Cod_Producto
                   UNION
                   SELECT DISTINCT 
                          CASE ccp.Cod_Libro
                              WHEN '14'
                              THEN 2
                              WHEN '08'
                              THEN 1
                              ELSE 3
                          END Orden, 
                          ccp.id_ComprobantePago, 
                          'CAJ_COMPROBANTE_PAGO' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) Fecha_Emision, 
                          ccp.Cod_TipoComprobante, 
                          ccp.Serie, 
                          ccp.Numero, 
                          CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          ccp.Nom_Cliente, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '08'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Entrada, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Entrada, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '14'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Salida, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                        INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
                   WHERE ccp.Flag_Anulado = 0
                         AND ccp.Flag_Despachado = 1
                         AND pp.Flag_Stock = 1
                         AND ccd.Cod_Almacen = @Cod_Almacen
                         AND ccd.Id_Producto = @Id_Producto
                         AND (@Id_Cliente IS NULL
                              OR ccp.Id_Cliente = @Id_Cliente)
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND ccd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND (@Cod_Moneda IS NULL
                              OR ccp.Cod_Moneda = @Cod_Moneda)
                         AND ccp.FechaEmision < CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                   GROUP BY ccp.Cod_Libro, 
                            ccp.id_ComprobantePago, 
                            ccp.FechaEmision, 
                            ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero, 
                            ccp.Nom_Cliente, 
                            pp.Cod_Producto
               ) KI;

        --Actualizamos los totales del kardex inicial
        DECLARE @Cantidad NUMERIC(38, 2)= 0.00;
        DECLARE @Importe NUMERIC(38, 2)= 0.00;
        DECLARE @SCostoTotal NUMERIC(38, 2)= 0.00;
        DECLARE @TCostoUnitario NUMERIC(38, 6)= 0.00;
        DECLARE @CodProducto VARCHAR(32)= '';
        UPDATE #kardexInicial
          SET 
              @TCostoUnitario = #kardexInicial.Precio_Salida = CASE
                                                                   WHEN #kardexInicial.Cantidad_Salida IS NULL
                                                                   THEN NULL
                                                                   ELSE CASE
                                                                            WHEN ORDEN = 2
                                                                            THEN @TCostoUnitario
                                                                            ELSE 0.00
                                                                        END
                                                               END, 
              @SCostoTotal = #kardexInicial.Monto_Salida = CASE
                                                               WHEN #kardexInicial.Cantidad_Salida IS NULL
                                                               THEN NULL
                                                               ELSE CASE
                                                                        WHEN ORDEN = 2
                                                                        THEN ROUND(@TCostoUnitario * Cantidad_Salida, 2)
                                                                        ELSE 0.00
                                                                    END
                                                           END, 
              @Cantidad = #kardexInicial.Cantidad_Saldo = CASE
                                                              WHEN @CodProducto <> #kardexInicial.Cod_Producto
                                                              THEN ISNULL(#kardexInicial.Cantidad_Entrada, 0.00) - ISNULL(#kardexInicial.Cantidad_Salida, 0.00)
                                                              ELSE @Cantidad + ISNULL(#kardexInicial.Cantidad_Entrada, 0.00) - ISNULL(#kardexInicial.Cantidad_Salida, 0.00)
                                                          END, 
              @Importe = #kardexInicial.Monto_Saldo = @Importe + ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00), 
              @TCostoUnitario = #kardexInicial.Precio_Saldo = CASE
                                                                  WHEN @Cantidad = 0.00
                                                                  THEN 0.00
                                                                  ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                                              END, 
              @CodProducto = #kardexInicial.Cod_Producto;

        --Fusionamos con los demas kardex
        --Creamos el kardex final
        CREATE TABLE #kardexFinal
        (Orden               INT, 
         Id                  INT, 
         Tabla               VARCHAR(100), 
         Fecha_Emision       DATETIME, 
         Cod_TipoComprobante VARCHAR(10), 
         Serie               VARCHAR(5), 
         Numero              VARCHAR(50), 
         Comprobante         VARCHAR(150), 
         Cod_Producto        VARCHAR(32), 
         Descripcion         VARCHAR(512), 
         Cantidad_Entrada    NUMERIC(38, 2), 
         Precio_Entrada      NUMERIC(38, 6), 
         Monto_Entrada       NUMERIC(38, 2), 
         Cantidad_Salida     NUMERIC(38, 2), 
         Precio_Salida       NUMERIC(38, 6), 
         Monto_Salida        NUMERIC(38, 2), 
         Cantidad_Saldo      NUMERIC(38, 2), 
         Precio_Saldo        NUMERIC(38, 6), 
         Monto_Saldo         NUMERIC(38, 2), 
         Orden_Aux           INT
        );
        INSERT INTO #kardexFinal
               SELECT RES.*, 
                      ROW_NUMBER() OVER(
                      ORDER BY RES.Fecha_Emision, 
                               RES.Orden, 
                               RES.Cod_TipoComprobante, 
                               RES.Serie, 
                               RES.Numero)
               FROM
               (
                   --Seleccionamos el ultimo saldo del KardexInicial
                   SELECT T1.*
                   FROM
                   (
                       SELECT TOP 1 1 Orden, 
                                    ki.Id, 
                                    NULL Tabla, 
                                    ki.Fecha_Emision Fecha_Emision, 
                                    NULL Cod_TipoComprobante, 
                                    NULL Serie, 
                                    NULL Numero, 
                                    NULL Comprobante, 
                                    NULL Cod_Producto, 
                                    'SALDO INICIAL' Descripcion, 
                                    ki.Cantidad_Saldo Cantidad_Entrada, 
                                    ki.Precio_Saldo Precio_Entrada, 
                                    ki.Monto_Saldo Monto_Entrada, 
                                    NULL Cantidad_Salida, 
                                    NULL Precio_Salida, 
                                    NULL Monto_Salida, 
                                    NULL Cantidad_Saldo, 
                                    NULL Precio_Saldo, 
                                    NULL Monto_Saldo
                       FROM #kardexInicial ki
                       ORDER BY ki.Fecha_Emision DESC, 
                                ki.Orden DESC, 
                                ki.Cod_TipoComprobante DESC, 
                                ki.Serie DESC, 
                                ki.Numero DESC
                   ) T1
                   UNION
                   SELECT DISTINCT 
                          CASE aam.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN 1
                              ELSE 2
                          END AS Orden, 
                          aam.Id_AlmacenMov, 
                          'ALM_ALMACEN_MOV' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR(32), aam.Fecha, 103)) Fecha_Emision, 
                          aam.Cod_TipoComprobante, 
                          aam.Serie, 
                          aam.Numero, 
                          CONCAT(aam.Cod_TipoComprobante, ':', aam.Serie, '-', aam.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          vto.Nom_TipoOperacion, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Entrada, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NE'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) AS Monto_Entrada, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad
                                        ELSE 0.00
                                    END), 2) Cantidad_Salida, 
                          ROUND(AVG(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE aam.Cod_TipoComprobante
                                        WHEN 'NS'
                                        THEN aamd.Cantidad * aamd.Precio_Unitario
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.ALM_ALMACEN_MOV aam
                        INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON aamd.Id_Producto = pp.Id_Producto
                        INNER JOIN dbo.VIS_TIPO_OPERACIONES vto ON aam.Cod_TipoOperacion = vto.Cod_TipoOperacion
                        INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON aamd.Id_Producto = pps.Id_Producto
                   WHERE aam.Flag_Anulado = 0
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND aam.Cod_Almacen = @Cod_Almacen
                         AND aamd.Id_Producto = @Id_Producto
                         AND pp.Flag_Stock = 1
                         AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND pps.Cod_Almacen = @Cod_Almacen
                         AND (@Cod_Moneda IS NULL
                              OR pps.Cod_Moneda = @Cod_Moneda)
                         AND (aam.Fecha >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                              AND aam.Fecha < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final))))
                   GROUP BY aam.Cod_TipoComprobante, 
                            aam.Id_AlmacenMov, 
                            aam.Fecha, 
                            aam.Serie, 
                            aam.Numero, 
                            vto.Nom_TipoOperacion, 
                            pp.Cod_Producto
                   UNION
                   SELECT DISTINCT 
                          CASE ccp.Cod_Libro
                              WHEN '14'
                              THEN 2
                              WHEN '08'
                              THEN 1
                              ELSE 3
                          END Orden, 
                          ccp.id_ComprobantePago, 
                          'CAJ_COMPROBANTE_PAGO' Tabla, 
                          CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) Fecha_Emision, 
                          ccp.Cod_TipoComprobante, 
                          ccp.Serie, 
                          ccp.Numero, 
                          CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Comprobante, 
                          pp.Cod_Producto, 
                          ccp.Nom_Cliente, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '08'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Entrada, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Entrada, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '08'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Entrada, 
                          ISNULL(ROUND(SUM(CASE
                                               WHEN ccp.Cod_Libro = '14'
                                               THEN ccd.Cantidad
                                               ELSE 0.00
                                           END), 2), 0.00) Cantidad_Salida, 
                          ROUND(AVG(CASE ccp.Cod_Libro
                                        WHEN '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)
                                        ELSE 0.00
                                    END), 2) Precio_Salida, 
                          ROUND(SUM(CASE
                                        WHEN ccp.Cod_Libro = '14'
                                        THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario * ccd.Cantidad)
                                        ELSE 0.00
                                    END), 2) Monto_Salida, 
                          0.00 Cantidad_Saldo, 
                          0.00 Precio_Saldo, 
                          0.00 Monto_Saldo
                   FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                        INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                        INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
                   WHERE ccp.Flag_Anulado = 0
                         AND ccp.Flag_Despachado = 1
                         AND pp.Flag_Stock = 1
                         AND ccd.Cod_Almacen = @Cod_Almacen
                         AND ccd.Id_Producto = @Id_Producto
                         AND (@Id_Cliente IS NULL
                              OR ccp.Id_Cliente = @Id_Cliente)
                         AND (@Cod_Categoria IS NULL
                              OR pp.Cod_Categoria = @Cod_Categoria)
                         AND ccd.Cod_UnidadMedida = @Cod_UnidadMedida
                         AND (@Cod_Moneda IS NULL
                              OR ccp.Cod_Moneda = @Cod_Moneda)
                         AND (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                              AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final))))
                   GROUP BY ccp.Cod_Libro, 
                            ccp.id_ComprobantePago, 
                            ccp.FechaEmision, 
                            ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero, 
                            ccp.Nom_Cliente, 
                            pp.Cod_Producto
               ) RES;

        --Actualizamos el kardex Final
        SET @Cantidad = 0.00;
        SET @Importe = 0.00;
        SET @SCostoTotal = 0.00;
        SET @TCostoUnitario = 0.00;
        SET @CodProducto = '';
        UPDATE #kardexFinal
          SET 
              @TCostoUnitario = #kardexFinal.Precio_Salida = CASE
                                                                 WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                                      OR #kardexFinal.Cantidad_Salida = 0
                                                                 THEN NULL
                                                                 ELSE CASE
                                                                          WHEN #kardexFinal.ORDEN = 2
                                                                          THEN @TCostoUnitario
                                                                          ELSE 0.00
                                                                      END
                                                             END, 
              @SCostoTotal = #kardexFinal.Monto_Salida = CASE
                                                             WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                                  OR #kardexFinal.Cantidad_Salida = 0
                                                             THEN NULL
                                                             ELSE CASE
                                                                      WHEN ORDEN = 2
                                                                      THEN ROUND(@TCostoUnitario * Cantidad_Salida, 2)
                                                                      ELSE 0.00
                                                                  END
                                                         END, 
              @Cantidad = #kardexFinal.Cantidad_Saldo = CASE
                                                            WHEN @CodProducto <> #kardexFinal.Cod_Producto
                                                            THEN ISNULL(#kardexFinal.Cantidad_Entrada, 0.00) - ISNULL(#kardexFinal.Cantidad_Salida, 0.00)
                                                            ELSE @Cantidad + ISNULL(#kardexFinal.Cantidad_Entrada, 0.00) - ISNULL(#kardexFinal.Cantidad_Salida, 0.00)
                                                        END, 
              @Importe = #kardexFinal.Monto_Saldo = CASE
                                                        WHEN @CodProducto <> #kardexFinal.Cod_Producto
                                                        THEN ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00)
                                                        ELSE @Importe + ISNULL(Monto_Entrada, 0.00) - ISNULL(@SCostoTotal, 0.00)
                                                    END, 
              @TCostoUnitario = #kardexFinal.Precio_Saldo = CASE
                                                                WHEN @Cantidad = 0.00
                                                                THEN 0.00
                                                                ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                                            END, 
              @CodProducto = #kardexFinal.Cod_Producto, 
              #kardexFinal.Cantidad_Salida = CASE
                                                 WHEN #kardexFinal.Cantidad_Salida IS NULL
                                                      OR #kardexFinal.Cantidad_Salida = 0
                                                 THEN NULL
                                                 ELSE #kardexFinal.Cantidad_Salida
                                             END, 
              #kardexFinal.Cantidad_Entrada = CASE
                                                  WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                       OR #kardexFinal.Cantidad_Entrada = 0
                                                  THEN NULL
                                                  ELSE #kardexFinal.Cantidad_Entrada
                                              END, 
              #kardexFinal.Precio_Entrada = CASE
                                                WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                     OR #kardexFinal.Cantidad_Entrada = 0
                                                THEN NULL
                                                ELSE #kardexFinal.Precio_Entrada
                                            END, 
              #kardexFinal.Monto_Entrada = CASE
                                               WHEN #kardexFinal.Cantidad_Entrada IS NULL
                                                    OR #kardexFinal.Cantidad_Entrada = 0
                                               THEN NULL
                                               ELSE #kardexFinal.Monto_Entrada
                                           END;

        --Mostramos el ultimo kardex
        SELECT DISTINCT 
               kf.*
        FROM #kardexFinal kf
        ORDER BY kf.Fecha_Emision, 
                 kf.Orden, 
                 kf.Cod_TipoComprobante, 
                 kf.Serie, 
                 kf.Numero;

        --Eliminamos los temporales
        DROP TABLE #kardexInicial;
        DROP TABLE #kardexFinal;
    END;
GO