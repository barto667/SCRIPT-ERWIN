--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 23/02/2016
-- OBJETIVO: Reporte de Kardex Valorizado detallado
-- URP_CAJ_COMPROBANTE_PAGO_KardexDetallado 1,null,null,NULL,0,null,0,'A101'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_KardexDetallado'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_KardexDetallado;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_KardexDetallado @Flag_Contable AS       BIT, 
                                                          @FechaInicio AS         DATETIME    = NULL, 
                                                          @FechaFin AS            DATETIME    = NULL, 
                                                          @Cod_Periodo AS         VARCHAR(8)  = NULL, 
                                                          @Id_ClienteProveedor AS INT         = 0, 
                                                          @Cod_Categoria AS       VARCHAR(8)  = NULL, 
                                                          @Id_Producto AS         INT         = 0, 
                                                          @Cod_Almacen AS         VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        CREATE TABLE #KARDEX
        (orden           INT, 
         Cod_Producto    VARCHAR(32), 
         Nom_Producto    VARCHAR(512), 
         Des_Categoria   VARCHAR(512), 
         Fecha           DATETIME, 
         TipoComprobante VARCHAR(2), 
         Serie           VARCHAR(5), 
         Numero          VARCHAR(50), 
         Detalle         VARCHAR(512), 
         UnidadMedida    VARCHAR(128), 
         CantidadEntrada NUMERIC(38, 2), 
         PrecioEntrada   NUMERIC(38, 6), 
         MontoEntrada    NUMERIC(38, 2), 
         CantidadSalida  NUMERIC(38, 2), 
         PrecioSalida    NUMERIC(38, 6), 
         MontoSalida     NUMERIC(38, 2), 
         CantidadSaldo   NUMERIC(38, 2), 
         PrecioSaldo     NUMERIC(38, 6), 
         MontoSaldo      NUMERIC(38, 2)
        );

        -- CALCULAR SALDO INICIALS
        INSERT INTO #KARDEX
               SELECT CASE AM.Cod_TipoComprobante
                          WHEN 'NE'
                          THEN 1
                          ELSE 2
                      END AS Orden, 
                      P.Cod_Producto, 
                      P.Nom_Producto, 
                      C.Des_Categoria, 
                      CONVERT(DATETIME, CONVERT(VARCHAR(32), AM.Fecha, 103)) AS Fecha, 
                      AM.Cod_TipoComprobante AS TipoComprobante, 
                      AM.Serie, 
                      AM.Numero, 
                      VTO.Nom_TipoOperacion AS Detalle, 
                      VUM.Nom_UnidadMedida AS UnidadMedida, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Cantidad
                              ELSE 0.00
                          END) AS CantidadEntrada, 
                      AVG(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS PrecioEntrada, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Cantidad * AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS MontoEntrada, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Cantidad
                              ELSE 0.00
                          END) AS CantidadSalida, 
                      AVG(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS PrecioSalida, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Cantidad * AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS MontoSalida, 
                      0.000000 AS CantidadSaldo, 
                      0.000000 AS PrecioSaldo, 
                      0.000000 AS MontoSaldo
               FROM ALM_ALMACEN_MOV AS AM
                    INNER JOIN ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
                    INNER JOIN PRI_PRODUCTOS AS P ON AMD.Id_Producto = P.Id_Producto
                    INNER JOIN PRI_CATEGORIA AS C ON P.Cod_Categoria = C.Cod_Categoria
                    INNER JOIN VIS_TIPO_OPERACIONES AS VTO ON AM.Cod_TipoOperacion = VTO.Cod_TipoOperacion
                    INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON AMD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
               WHERE(AM.Cod_TipoOperacion NOT IN('03', '04'))
                    AND (AMD.Id_Producto = @Id_Producto
                         OR @Id_Producto = 0)
                    AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), AM.Fecha, 103)) BETWEEN @FechaInicio AND @FechaFin
                         OR @FechaInicio IS NULL) 
                    --AND (CP.Cod_Periodo = @Cod_Periodo OR  @Cod_Periodo IS NOT NULL) 
                    AND AM.FLAG_ANULADO = 0
                    AND P.Flag_Stock = 1
                    AND (AM.Cod_Almacen = @Cod_Almacen
                         OR @Cod_Almacen IS NULL)
                    AND (P.Cod_Categoria IN
               (
                   SELECT Cod_Categoria
                   FROM UFN_PadreCategorias(@Cod_Categoria) AS UFN_PadreCategorias_1
               )
               OR @Cod_Categoria IS NULL)
               GROUP BY P.Cod_Producto, 
                        P.Nom_Producto, 
                        C.Des_Categoria, 
                        AM.Fecha, 
                        AM.Cod_TipoComprobante, 
                        AM.Serie, 
                        AM.Numero, 
                        VTO.Nom_TipoOperacion, 
                        VUM.Nom_UnidadMedida		
        -- CARGAR FACTURAS Y OTROS
               UNION
               SELECT CASE CP.Cod_Libro
                          WHEN '14'
                          THEN 2
                          WHEN '08'
                          THEN 1
                          ELSE 3
                      END AS Orden, 
                      P.Cod_Producto, 
                      P.Nom_Producto, 
                      CT.Des_Categoria, 
                      CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) AS Fecha, 
                      VTC.Cod_Sunat AS TipoComprobante, 
                      CP.Serie, 
                      CP.Numero AS Documento, 
                      cp.Nom_Cliente AS Detalle, 
                      VUM.Nom_UnidadMedida AS UnidadMedida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadEntrada, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadSalida, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioSalida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoSalida, 
                      0.000000 AS CantidadSaldo, 
                      0.000000 AS PrecioSaldo, 
                      0.000000 AS MontoSaldo
               FROM CAJ_COMPROBANTE_PAGO AS CP
                    INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                    INNER JOIN CAJ_CAJAS AS CA ON CP.Cod_Caja = CA.Cod_Caja
                    INNER JOIN VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
                    INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
                    INNER JOIN PRI_CATEGORIA AS CT ON P.Cod_Categoria = CT.Cod_Categoria
                    INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON CD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
               WHERE --(CP.Cod_TipoComprobante IN ('FA','TKF','NC'))  --AND P.Cod_TipoProducto = 'PRO' 
               (CD.Id_Producto = @Id_Producto
                OR @Id_Producto = 0)
               AND CP.FLAG_ANULADO = 0
               AND P.Flag_Stock = 1
               AND CP.Flag_Despachado = 1
               AND (CD.Cod_Almacen = @Cod_Almacen
                    OR @Cod_Almacen IS NULL)
               AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) BETWEEN @FechaInicio AND @FechaFin
                    OR @FechaInicio IS NULL)
               AND (CP.Cod_Periodo = @Cod_Periodo
                    OR @Cod_Periodo IS NULL)
               AND (P.Cod_Categoria IN
               (
                   SELECT Cod_Categoria
                   FROM UFN_PadreCategorias(@Cod_Categoria) AS UFN_PadreCategorias_1
               )
               OR @Cod_Categoria IS NULL)
               --AND CD.Cantidad - CD.Formalizado > 0
               GROUP BY P.Cod_Producto, 
                        P.Nom_Producto, 
                        CT.Des_Categoria, 
                        CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)), 
                        VTC.Cod_Sunat, 
                        CP.Serie, 
                        CP.Cod_Libro, 
                        VUM.Nom_UnidadMedida, 
                        CP.Numero, 
                        cp.Nom_Cliente
               ORDER BY Cod_Producto, 
                        Fecha, 
                        Orden, 
                        TipoComprobante, 
                        Serie, 
                        Numero;
        DECLARE @Cantidad NUMERIC(38, 2), @Importe NUMERIC(38, 2), @SCostoTotal NUMERIC(38, 2), @TCostoUnitario NUMERIC(38, 6), @Cod_Producto VARCHAR(32);
        SET @Cantidad = 0.00;
        SET @Importe = 0.00;
        SET @SCostoTotal = 0.00;
        SET @TCostoUnitario = 0.00;
        SET @Cod_Producto = '';
        --SELECT * FROM #KARDEX
        -- ACTUALIZAR LOS SALDOS orden 0= saldo 1= compra 2=venta
        UPDATE #KARDEX
          SET 
              @TCostoUnitario = PrecioSalida = CASE ORDEN
                                                   WHEN 2
                                                   THEN @TCostoUnitario
                                                   ELSE 0.00
                                               END, 
              @SCostoTotal = MontoSalida = CASE ORDEN
                                               WHEN 2
                                               THEN ROUND(@TCostoUnitario * CantidadSalida, 2)
                                               ELSE 0.00
                                           END, 
              @Cantidad = CantidadSaldo = CASE
                                              WHEN @Cod_Producto <> Cod_Producto
                                              THEN CantidadEntrada - CantidadSalida
                                              ELSE @Cantidad + CantidadEntrada - CantidadSalida
                                          END, 
              @Importe = MontoSaldo = CASE
                                          WHEN @Cod_Producto <> Cod_Producto
                                          THEN MontoEntrada - @SCostoTotal
                                          ELSE @Importe + MontoEntrada - @SCostoTotal
                                      END, 
              @TCostoUnitario = PrecioSaldo = CASE @Cantidad
                                                  WHEN 0.00
                                                  THEN 0.00
                                                  ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                              END, 
              @Cod_Producto = Cod_Producto;
        SELECT *
        FROM #KARDEX;
        DROP TABLE #KARDEX;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 17/07/2013 - 25/07/2015
-- OBJETIVO: Reporte de Kardex Valorizado y mas
-- URP_CAJ_COMPROBANTE_PAGO_Kardex 1,null,null,NULL,null,0,NULL,NULL,1
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_Kardex'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_Kardex;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_Kardex @Flag_Contable AS       BIT, 
                                                 @FechaInicio AS         DATETIME    = NULL, 
                                                 @FechaFin AS            DATETIME    = NULL, 
                                                 @Cod_Periodo AS         VARCHAR(8)  = NULL, 
                                                 @Id_ClienteProveedor AS INT         = 0, 
                                                 @Cod_Categoria AS       VARCHAR(8)  = NULL, 
                                                 @Id_Producto AS         INT         = 0, 
                                                 @Cod_Almacen AS         VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        CREATE TABLE #KARDEX
        (orden           INT, 
         Cod_Producto    VARCHAR(32), 
         Nom_Producto    VARCHAR(512), 
         Des_Categoria   VARCHAR(512), 
         Fecha           DATETIME, 
         TipoComprobante VARCHAR(2), 
         Serie           VARCHAR(5), 
         Numero          VARCHAR(50), 
         Detalle         VARCHAR(512), 
         UnidadMedida    VARCHAR(128), 
         CantidadEntrada NUMERIC(38, 2), 
         PrecioEntrada   NUMERIC(38, 6), 
         MontoEntrada    NUMERIC(38, 2), 
         CantidadSalida  NUMERIC(38, 2), 
         PrecioSalida    NUMERIC(38, 6), 
         MontoSalida     NUMERIC(38, 2), 
         CantidadSaldo   NUMERIC(38, 2), 
         PrecioSaldo     NUMERIC(38, 6), 
         MontoSaldo      NUMERIC(38, 2)
        );

        -- CALCULAR SALDO INICIALS

        INSERT INTO #KARDEX
               SELECT CASE AM.Cod_TipoComprobante
                          WHEN 'NE'
                          THEN 1
                          ELSE 2
                      END AS Orden, 
                      P.Cod_Producto, 
                      P.Nom_Producto, 
                      C.Des_Categoria, 
                      CONVERT(DATETIME, CONVERT(VARCHAR(32), AM.Fecha, 103)) AS Fecha, 
                      AM.Cod_TipoComprobante AS TipoComprobante, 
                      AM.Serie, 
                      AM.Numero, 
                      VTO.Nom_TipoOperacion AS Detalle, 
                      VUM.Nom_UnidadMedida AS UnidadMedida, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Cantidad
                              ELSE 0.00
                          END) AS CantidadEntrada, 
                      AVG(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS PrecioEntrada, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NE'
                              THEN AMD.Cantidad * AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS MontoEntrada, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Cantidad
                              ELSE 0.00
                          END) AS CantidadSalida, 
                      AVG(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS PrecioSalida, 
                      SUM(CASE AM.Cod_TipoComprobante
                              WHEN 'NS'
                              THEN AMD.Cantidad * AMD.Precio_Unitario
                              ELSE 0.00
                          END) AS MontoSalida, 
                      0.000000 AS CantidadSaldo, 
                      0.000000 AS PrecioSaldo, 
                      0.000000 AS MontoSaldo
               FROM ALM_ALMACEN_MOV AS AM
                    INNER JOIN ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
                    INNER JOIN PRI_PRODUCTOS AS P ON AMD.Id_Producto = P.Id_Producto
                    INNER JOIN PRI_CATEGORIA AS C ON P.Cod_Categoria = C.Cod_Categoria
                    INNER JOIN VIS_TIPO_OPERACIONES AS VTO ON AM.Cod_TipoOperacion = VTO.Cod_TipoOperacion
                    INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON AMD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
               WHERE(AM.Cod_TipoOperacion NOT IN('03', '04'))
                    AND (AMD.Id_Producto = @Id_Producto
                         OR @Id_Producto = 0)
                    AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), AM.Fecha, 103)) BETWEEN @FechaInicio AND @FechaFin
                         OR @FechaInicio IS NULL) 
                    --AND (CP.Cod_Periodo = @Cod_Periodo OR  @Cod_Periodo IS NOT NULL) 
                    AND AM.FLAG_ANULADO = 0
                    AND P.Flag_Stock = 1
                    AND (AM.Cod_Almacen = @Cod_Almacen
                         OR @Cod_Almacen IS NULL)
                    AND (P.Cod_Categoria IN
               (
                   SELECT Cod_Categoria
                   FROM UFN_PadreCategorias(@Cod_Categoria) AS UFN_PadreCategorias_1
               )
               OR @Cod_Categoria IS NULL)
               GROUP BY P.Cod_Producto, 
                        P.Nom_Producto, 
                        C.Des_Categoria, 
                        AM.Fecha, 
                        AM.Cod_TipoComprobante, 
                        AM.Serie, 
                        AM.Numero, 
                        VTO.Nom_TipoOperacion, 
                        VUM.Nom_UnidadMedida
               UNION
               -- CALCULAR MOVIMIENTOS RESUMENES
               SELECT CASE CP.Cod_Libro
                          WHEN '14'
                          THEN 2
                          WHEN '08'
                          THEN 1
                          ELSE 3
                      END AS Orden, 
                      P.Cod_Producto, 
                      P.Nom_Producto, 
                      CT.Des_Categoria, 
                      CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) AS Fecha, 
                      '99' AS TipoComprobante, 
                      CP.Serie,
                      CASE
                          WHEN MIN(CP.Numero) = MAX(CP.Numero)
                          THEN MIN(CP.Numero)
                          ELSE MIN(CP.Numero) + ' - ' + MAX(CP.Numero)
                      END AS Numero,
                      CASE CP.Cod_Libro
                          WHEN '14'
                          THEN 'VENTA DEL DIA'
                          ELSE 'COMPRA DEL DIA'
                      END AS Detalle, 
                      VUM.Nom_UnidadMedida AS UnidadMedida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadEntrada, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadSalida, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioSalida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoSalida, 
                      0.000000 AS CantidadSaldo, 
                      0.000000 AS PrecioSaldo, 
                      0.000000 AS MontoSaldo
               FROM CAJ_COMPROBANTE_PAGO AS CP
                    INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                    INNER JOIN CAJ_CAJAS AS CA ON CP.Cod_Caja = CA.Cod_Caja
                    INNER JOIN VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
                    INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
                    INNER JOIN PRI_CATEGORIA AS CT ON P.Cod_Categoria = CT.Cod_Categoria
                    INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON CD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
               WHERE(CP.Cod_TipoComprobante IN('NP', 'BO', 'TKB', 'BE'))  --AND P.Cod_TipoProducto = 'PRO' and cp.Flag_Anulado = 0
                    AND (CD.Id_Producto = @Id_Producto
                         OR @Id_Producto = 0)
                    AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) BETWEEN @FechaInicio AND @FechaFin
                         OR @FechaInicio IS NULL)
                    AND (CP.Cod_Periodo = @Cod_Periodo
                         OR @Cod_Periodo IS NULL)
                    AND CP.FLAG_ANULADO = 0
                    AND P.Flag_Stock = 1
                    AND CP.Flag_Despachado = 1
                    AND (CD.Cod_Almacen = @Cod_Almacen
                         OR @Cod_Almacen IS NULL)
                    AND (P.Cod_Categoria IN
               (
                   SELECT Cod_Categoria
                   FROM UFN_PadreCategorias(@Cod_Categoria) AS UFN_PadreCategorias_1
               )
        OR @Cod_Categoria IS NULL)
               --AND CD.Cantidad - CD.Formalizado > 0
               GROUP BY P.Cod_Producto, 
                        P.Nom_Producto, 
                        CT.Des_Categoria, 
                        CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)), 
                        VTC.Cod_Sunat, 
                        CP.Serie, 
                        CP.Cod_Libro, 
                        VUM.Nom_UnidadMedida
    -- CARGAR FACTURAS Y OTROS
               UNION
               SELECT CASE CP.Cod_Libro
                          WHEN '14'
                          THEN 2
                          WHEN '08'
                          THEN 1
                          ELSE 3
                      END AS Orden, 
                      P.Cod_Producto, 
                      P.Nom_Producto, 
                      CT.Des_Categoria, 
                      CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) AS Fecha, 
                      VTC.Cod_Sunat AS TipoComprobante, 
                      CP.Serie, 
                      CP.Numero AS Documento, 
                      cp.Nom_Cliente AS Detalle, 
                      VUM.Nom_UnidadMedida AS UnidadMedida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadEntrada, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '08'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoEntrada, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN CD.Cantidad
                              ELSE 0.00
                          END) AS CantidadSalida, 
                      AVG(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.PrecioUnitario)
                              ELSE 0.00
                          END) AS PrecioSalida, 
                      SUM(CASE CP.Cod_Libro
                              WHEN '14'
                              THEN dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(CP.FechaEmision, CP.Cod_Moneda, CD.Sub_Total)
                              ELSE 0.00
                          END) AS MontoSalida, 
                      0.000000 AS CantidadSaldo, 
                      0.000000 AS PrecioSaldo, 
                      0.000000 AS MontoSaldo
               FROM CAJ_COMPROBANTE_PAGO AS CP
                    INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                    INNER JOIN CAJ_CAJAS AS CA ON CP.Cod_Caja = CA.Cod_Caja
                    INNER JOIN VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
                    INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
                    INNER JOIN PRI_CATEGORIA AS CT ON P.Cod_Categoria = CT.Cod_Categoria
                    INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON CD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
               WHERE(CP.Cod_TipoComprobante IN('FA', 'TKF', 'NC', 'FE', 'NCE'))  --AND P.Cod_TipoProducto = 'PRO' 
                    AND (CD.Id_Producto = @Id_Producto
                         OR @Id_Producto = 0)
                    AND CP.FLAG_ANULADO = 0
                    AND P.Flag_Stock = 1
                    AND CP.Flag_Despachado = 1
                    AND (CD.Cod_Almacen = @Cod_Almacen
                         OR @Cod_Almacen IS NULL)
                    AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) BETWEEN @FechaInicio AND @FechaFin
                         OR @FechaInicio IS NULL)
                    AND (CP.Cod_Periodo = @Cod_Periodo
                         OR @Cod_Periodo IS NULL)
                    AND (P.Cod_Categoria IN
               (
                   SELECT Cod_Categoria
                   FROM UFN_PadreCategorias(@Cod_Categoria) AS UFN_PadreCategorias_1
               )
OR @Cod_Categoria IS NULL)
               --AND CD.Cantidad - CD.Formalizado > 0
               GROUP BY P.Cod_Producto, 
                        P.Nom_Producto, 
                        CT.Des_Categoria, 
                        CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)), 
                        VTC.Cod_Sunat, 
                        CP.Serie, 
                        CP.Cod_Libro, 
                        VUM.Nom_UnidadMedida, 
                        CP.Numero, 
                        cp.Nom_Cliente
               ORDER BY Cod_Producto, 
                        Fecha, 
                        Orden, 
                        TipoComprobante, 
                        Serie, 
                        Numero;
        DECLARE @Cantidad NUMERIC(38, 2), @Importe NUMERIC(38, 2), @SCostoTotal NUMERIC(38, 2), @TCostoUnitario NUMERIC(38, 6), @Cod_Producto VARCHAR(32);
        SET @Cantidad = 0.00;
        SET @Importe = 0.00;
        SET @SCostoTotal = 0.00;
        SET @TCostoUnitario = 0.00;
        SET @Cod_Producto = '';
        --SELECT * FROM #KARDEX
        -- ACTUALIZAR LOS SALDOS orden 0= saldo 1= compra 2=venta
        UPDATE #KARDEX
          SET 
              @TCostoUnitario = PrecioSalida = CASE ORDEN
                                                   WHEN 2
                                                   THEN @TCostoUnitario
                                                   ELSE 0.00
                                               END, 
              @SCostoTotal = MontoSalida = CASE ORDEN
                                               WHEN 2
                                               THEN ROUND(@TCostoUnitario * CantidadSalida, 2)
                                               ELSE 0.00
                                           END, 
              @Cantidad = CantidadSaldo = CASE
                                              WHEN @Cod_Producto <> Cod_Producto
                                              THEN CantidadEntrada - CantidadSalida
                                              ELSE @Cantidad + CantidadEntrada - CantidadSalida
                                          END, 
              @Importe = MontoSaldo = CASE
                                          WHEN @Cod_Producto <> Cod_Producto
                                          THEN MontoEntrada - @SCostoTotal
                                          ELSE @Importe + MontoEntrada - @SCostoTotal
                                      END, 
              @TCostoUnitario = PrecioSaldo = CASE @Cantidad
                                                  WHEN 0.00
                                                  THEN 0.00
                                                  ELSE CONVERT(NUMERIC(38, 6), @Importe / @Cantidad, 6)
                                              END, 
              @Cod_Producto = Cod_Producto;
        SELECT *
        FROM #KARDEX;
        DROP TABLE #KARDEX;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 29/01/2019
-- OBJETIVO: reporte de insumos quimicos
-- URP_CAJ_COMPROBANTE_PAGO_IQEgresos '01/01/2018','12/12/2018'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_IQEgresos'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_IQEgresos;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_IQEgresos @FechaInicio AS DATETIME, 
                                                    @FechaFin AS    DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT '2' AS Cod_TipoOperacion, 
               S.Cod_Sucursal, 
               '010' AS Cod_TipoTransaccion, 
               P.Cuenta_Contable AS Cod_Producto, 
               CONVERT(NUMERIC(38, 3), ROUND(CD.Cantidad, 3), 3) AS Cantidad, 
               VC.Cod_Sunat AS Cod_TipoComprobante, 
               cp.Serie + '-' + cp.Numero AS Comprobante, 
               CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 103)) AS FechaEmision, 
               cp.Cod_TipoDoc, 
               cp.Doc_Cliente, 
               cp.Nom_Cliente, 
               '' AS RUCTransportista, 
               '' AS GuiaRemision, 
               '' AS NroGuiaRemision, 
               '' AS PlacaVehiculo, 
               '' AS NroLicencia, 
               '' AS Observaciones, 
               '' AS CodIncidencia, 
               '2|' + S.Cod_Sucursal + '|010|' + P.Cuenta_Contable + '|' + CONVERT(VARCHAR, CONVERT(NUMERIC(38, 3), ROUND(CD.Cantidad, 3), 3)) + '|' + VC.Cod_Sunat + '|' + cp.Serie + '-' + cp.Numero + '|' + CONVERT(VARCHAR(32), CP.FechaEmision, 103) + '|' + cp.Cod_TipoDoc + '|' + cp.Doc_Cliente + '|' + CONVERT(VARCHAR(30), cp.Nom_Cliente) + '||||' + CP.Placa_Vehiculo + '|||' AS Cadena
        FROM CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
             INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
             INNER JOIN PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
             INNER JOIN VIS_TIPO_COMPROBANTES AS VC ON CP.Cod_TipoComprobante = VC.Cod_TipoComprobante
        WHERE CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 105)) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(32), @FechaInicio, 105)) AND CONVERT(DATETIME, CONVERT(VARCHAR(32), @FechaFin, 105))
              AND Cod_Libro = '14'
              AND CP.Cod_TipoComprobante IN('BE', 'FE', 'FC', 'BC', 'TKB', 'TKF', 'BO', 'FA') -- solo comprobantes sunat
        ORDER BY CONVERT(DATETIME, cp.FechaEmision, 103), 
                 serie, 
                 Numero;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_IQIngresos'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_IQIngresos;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_IQIngresos @FechaInicio AS DATETIME, 
                                                     @FechaFin AS    DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT '1' AS Cod_TipoOperacion, 
               S.Cod_Sucursal, 
               '001' AS Cod_TipoTransaccion, 
               P.Cuenta_Contable AS Cod_Producto, 
               CONVERT(NUMERIC(38, 3), ROUND(CD.Cantidad, 3), 3) AS Cantidad, 
               cp.Cod_TipoComprobante, 
               cp.Serie + '-' + cp.Numero AS Comprobante, 
               CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 105)) AS FechaEmision, 
               cp.Cod_TipoDoc, 
               cp.Doc_Cliente, 
               cp.Nom_Cliente, 
               '' AS RUCTransportista, 
               '' AS GuiaRemision, 
               '' AS NroGuiaRemision, 
               '' AS PlacaVehiculo, 
               '' AS NroLicencia, 
               '' AS Observaciones, 
               '' AS CodIncidencia, 
               '1|' + S.Cod_Sucursal + '|001|' + P.Cuenta_Contable + '|' + CONVERT(VARCHAR, CONVERT(NUMERIC(38, 3), ROUND(CD.Cantidad, 3), 3)) + '|' + cp.Serie + '-' + cp.Numero + '|' + CONVERT(VARCHAR(32), CP.FechaEmision, 105) + '|' + cp.Cod_TipoDoc + '|' + cp.Doc_Cliente + '|' + CONVERT(VARCHAR(30), cp.Nom_Cliente) + '||||' + CP.Placa_Vehiculo + '|||' AS Cadena
        FROM CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
             INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
             INNER JOIN PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
             INNER JOIN VIS_TIPO_COMPROBANTES AS VC ON CP.Cod_TipoComprobante = VC.Cod_TipoComprobante
        WHERE CONVERT(DATETIME, CONVERT(VARCHAR(32), CP.FechaEmision, 105)) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(32), @FechaInicio, 105)) AND CONVERT(DATETIME, CONVERT(VARCHAR(32), @FechaFin, 105))
              AND Cod_Libro = '08'
              AND CP.Cod_TipoComprobante IN
        (
            SELECT Cod_TipoComprobante
            FROM VIS_TIPO_COMPROBANTES
            WHERE Flag_RegistroCompras = 1
        ) -- solo comprobantes sunat
        ORDER BY CONVERT(DATETIME, cp.FechaEmision, 103), 
                 serie, 
                 Numero;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 17/07/2015, 18/07/2018
-- OBJETIVO: Reporte Licitaciones en formato general
-- URP_PRI_LICITACIONES_ReporteGeneral 0,NULL,NULL,NULL,'01/01/2015','1/01/2017'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_PRI_LICITACIONES_ReporteGeneral'
          AND type = 'P'
)
    DROP PROCEDURE URP_PRI_LICITACIONES_ReporteGeneral;
GO
CREATE PROCEDURE URP_PRI_LICITACIONES_ReporteGeneral @Id_ClienteProveedor AS INT         = 0, 
                                                     @Cod_Licitacion AS      VARCHAR(32) = NULL, 
                                                     @Cod_Caja AS            VARCHAR(32) = NULL, 
                                                     @Cod_Turno AS           VARCHAR(32) = NULL, 
                                                     @FechaInicio AS         DATETIME, 
                                                     @FechaFinal AS          DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        -- selecionar en tablas temporales las vistas q generan mucha lentitud
        SELECT Nro, 
               Cod_TipoDoc, 
               Nom_TipoDoc, 
               Estado
        INTO [#VIS_TIPO_DOCUMENTOS]
        FROM VIS_TIPO_DOCUMENTOS;
        SELECT Nro, 
               Cod_TipoLicitacion, 
               Nom_TipoLicitacion, 
               Estado
        INTO [#VIS_TIPO_LICITACIONES]
        FROM VIS_TIPO_LICITACIONES;
        SELECT CPRO.Id_ClienteProveedor, 
               VTD.Nom_TipoDoc, 
               CPRO.Nro_Documento, 
               CPRO.Cliente, 
               CPRO.Direccion, 
               L.Cod_Licitacion, 
               L.Des_Licitacion, 
               L.Nro_Licitacion, 
               L.Cod_TipoLicitacion, 
               VTL.Nom_TipoLicitacion, 
               L.Fecha_Inicio, 
               L.Flag_AlFinal, 
               L.Fecha_Facturacion, 
               LD.Nro_Detalle, 
               LD.Id_Producto, 
               LD.Cod_UnidadMedida, 
               LD.Cantidad, 
               LD.Descripcion, 
               LD.Precio_Unitario, 
               LD.Por_Descuento, 
               CP.Cod_TipoComprobante + ' : ' + CP.Serie + ' - ' + CP.Numero AS Comprobante, 
               C.Des_Caja, 
               T.Des_Turno, 
               CP.FechaEmision, 
               CD.Cantidad AS CantidadDespachado, 
               CD.PrecioUnitario, 
               CD.Sub_Total, 
               CPR.Cod_TipoComprobante + ' : ' + CPR.Serie + ' - ' + CPR.Numero AS Factura, 
               CPR.FechaEmision AS Fecha, 
               CPR.Total, 
               dbo.UFN_ConvertirPlaca(Point.Registro.value('PLACA[1]', 'VARCHAR(32)')) AS PLACA, 
               Point.Registro.value('KILOMETRAJE[1]', 'VARCHAR(32)') AS KILOMETRAJE, 
               Point.Registro.value('CHOFER[1]', 'VARCHAR(32)') AS CHOFER, 
               Point.Registro.value('OBS_COMPROBANTE[1]', 'VARCHAR(64)') AS OBS_COMPROBANTE, 
               Point.Registro.value('NRO_VALE[1]', 'VARCHAR(32)') AS NRO_VALE
        FROM CAJ_COMPROBANTE_PAGO AS CPR
             RIGHT OUTER JOIN CAJ_COMPROBANTE_RELACION AS CR ON CPR.id_ComprobantePago = CR.Id_ComprobanteRelacion
             RIGHT OUTER JOIN PRI_LICITACIONES AS L
             INNER JOIN PRI_LICITACIONES_D AS LD ON L.Id_ClienteProveedor = LD.Id_ClienteProveedor
                                                    AND L.Cod_Licitacion = LD.Cod_Licitacion
             INNER JOIN PRI_LICITACIONES_M AS LM ON LD.Id_ClienteProveedor = LM.Id_ClienteProveedor
                                                    AND LD.Cod_Licitacion = LM.Cod_Licitacion
                                                    AND LD.Nro_Detalle = LM.Nro_Detalle
             INNER JOIN CAJ_COMPROBANTE_D AS CD ON LM.id_ComprobantePago = CD.id_ComprobantePago
                                                   AND LD.Id_Producto = CD.Id_Producto
             INNER JOIN CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
             INNER JOIN PRI_CLIENTE_PROVEEDOR AS CPRO ON L.Id_ClienteProveedor = CPRO.Id_ClienteProveedor
             INNER JOIN #VIS_TIPO_DOCUMENTOS AS VTD ON CPRO.Cod_TipoDocumento = VTD.Cod_TipoDoc
             INNER JOIN #VIS_TIPO_LICITACIONES AS VTL ON L.Cod_TipoLicitacion = VTL.Cod_TipoLicitacion
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
             INNER JOIN CAJ_TURNO_ATENCION AS T ON CP.Cod_Turno = T.Cod_Turno ON CR.id_ComprobantePago = CD.id_ComprobantePago
                                                                                 AND CR.id_Detalle = CD.id_Detalle
             CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro)
        WHERE CP.Cod_Libro = '14'
              AND CP.Flag_Anulado = 0
              AND (@Id_ClienteProveedor = CPRO.Id_ClienteProveedor
                   OR @Id_ClienteProveedor = 0)
              AND (@Cod_Licitacion = L.Cod_Licitacion
                   OR @Cod_Licitacion IS NULL)
              AND (CONVERT(DATETIME, CONVERT(VARCHAR, CP.FechaEmision, 103)) BETWEEN @FechaInicio AND @FechaFinal)
              AND (@Cod_Caja = CP.Cod_Caja
                   OR @Cod_Caja IS NULL)
              AND (@Cod_Turno = CP.Cod_Turno
                   OR @Cod_Turno IS NULL);
        DROP TABLE [#VIS_TIPO_DOCUMENTOS];
        DROP TABLE [#VIS_TIPO_LICITACIONES];
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 3/10/2017
-- OBJETIVO: Reporte general auxiliar detallado
-- URP_CAJ_COMPROBANTE_PAGO_ReporteAuxiliarD 14,NULL,0,NULL,'01/02/2019','28/02/2019',NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,0
--------------------------------------------------------------------------------------------------------------

IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_ReporteAuxiliarD'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_ReporteAuxiliarD;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_ReporteAuxiliarD @Cod_Libro AS           VARCHAR(5), 
                                                           @Cod_Sucursal AS        VARCHAR(32) = NULL, 
                                                           @Id_Cliente          INT         = 0, 
                                                           @Cod_Caja            VARCHAR(32) = NULL, 
                                                           @FechaInicio AS         VARCHAR(32) = NULL, 
                                                           @FechaFin AS            VARCHAR(32) = NULL, 
                                                           @Cod_TurnoInicio AS     VARCHAR(32) = NULL, 
                                                           @Cod_TurnoFinal AS      VARCHAR(32) = NULL, 
                                                           @Cod_Moneda AS          VARCHAR(5)  = NULL, 
                                                           @Cod_FormaPago AS       VARCHAR(5)  = NULL, 
                                                           @Cod_TipoComprobante AS VARCHAR(5)  = NULL, 
                                                           @Serie AS               VARCHAR(5)  = NULL, 
                                                           @Id_producto AS         INT         = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        CREATE TABLE #Turnos(Cod_Turno VARCHAR(32));
        --CREATE TABLE #Turnos ( Cod_Turno  varchar(32) collate SQL_Latin1_General_CP1_CI_AS);

        IF(@Cod_TurnoInicio IS NOT NULL)
            BEGIN
                DECLARE @FechaI AS DATETIME, @FechaF AS DATETIME;
                SELECT @FechaI = MIN(Fecha_Inicio), 
                       @FechaF = MAX(Fecha_Fin)
                FROM CAJ_TURNO_ATENCION
                WHERE Cod_Turno IN(@Cod_TurnoInicio, @Cod_TurnoFinal);
                INSERT INTO #Turnos
                       SELECT Cod_Turno
                       FROM CAJ_TURNO_ATENCION
                       WHERE Fecha_Inicio BETWEEN @FechaI AND @FechaF;
        END;
            ELSE
            BEGIN
                INSERT INTO #Turnos
                       SELECT Cod_Turno
                       FROM CAJ_TURNO_ATENCION
                       WHERE Fecha_Inicio BETWEEN @FechaInicio AND @FechaFin;
        END;

        -- selecionar en tablas temporales las vistas q generan mucha lentitud
        SELECT Nro, 
               Cod_TipoComprobante, 
               Nom_TipoComprobante, 
               Cod_Sunat, 
               Flag_Ventas, 
               Flag_Compras, 
               Flag_RegistroVentas, 
               Flag_RegistroCompras, 
               Estado
        INTO [#VIS_TIPO_COMPROBANTES]
        FROM VIS_TIPO_COMPROBANTES;
        SELECT Nro, 
               Cod_FormaPago, 
               Nom_FormaPago, 
               Estado
        INTO [#VIS_FORMAS_PAGO]
        FROM VIS_FORMAS_PAGO;
        SELECT DISTINCT 
               CP.id_ComprobantePago, 
               cd.id_Detalle, 
               CP.Cod_Libro, 
               CP.Cod_Periodo, 
               CONVERT(DATETIME, CONVERT(VARCHAR(20), CP.FechaEmision, 103)) AS FechaEmision, 
               CONVERT(DATETIME, CONVERT(VARCHAR(20), CP.FechaCancelacion, 103)) AS FechaCancelacion, 
               VTD.Cod_Sunat AS Cod_TipoComprobante, 
               CP.Serie, 
               CP.Numero, 
               CP.Cod_TipoDoc,
               CASE Flag_Anulado
                   WHEN 1
                   THEN ''
                   ELSE CP.Doc_Cliente
               END AS Doc_Cliente,
               CASE Flag_Anulado
                   WHEN 1
                   THEN 'ANULADO'
                   ELSE CP.Nom_Cliente
               END AS Nom_Cliente, 
               CP.TipoCambio, 
               CP.Nro_Ticketera, 
               CP.Impuesto, 
               CP.Total, 
               dbo.UFN_Percepcion(CP.id_ComprobantePago) AS ImportePercepcion, 
               CD.Descripcion, 
               ISNULL(CD.Cantidad, 0) AS Cantidad, 
               ISNULL(CD.PrecioUnitario, 0) AS PrecioUnitario, 
               cd.Descuento, 
               ISNULL(CD.Sub_Total, 0) AS Sub_Total, 
               CD.Cod_Manguera, 
               CP.Cod_Turno AS cod_turno, 
               CP.Cod_Moneda, 
               CP.Placa_Vehiculo, 
               Point.Registro.value('PLACA[1]', 'VARCHAR(64)') AS PLACA_XML, 
               ISNULL(FP.Des_FormaPago, 'CREDITO') AS FormaPago, 
               ISNULL(FP.Cuenta_CajaBanco, '') AS Referencia
        FROM CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN [#VIS_TIPO_COMPROBANTES] AS VTD ON CP.Cod_TipoComprobante = VTD.Cod_TipoComprobante
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
             INNER JOIN PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
             LEFT OUTER JOIN CAJ_FORMA_PAGO AS FP ON CP.id_ComprobantePago = FP.id_ComprobantePago
             LEFT OUTER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
             CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro)
        WHERE(CP.Cod_TipoComprobante IN
        (
            SELECT Cod_TipoComprobante
            FROM #VIS_TIPO_COMPROBANTES
            WHERE Flag_RegistroCompras = 1
                  OR Flag_RegistroVentas = 1
        ))
             AND (cp.Id_Cliente = @Id_Cliente
                  OR @Id_Cliente = 0)
             AND (Cod_Libro = @Cod_Libro)
             AND (S.Cod_Sucursal = @Cod_Sucursal
                  OR @Cod_Sucursal IS NULL)
             AND (C.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (cp.Cod_FormaPago = @Cod_FormaPago
                  OR @Cod_FormaPago IS NULL)
             AND (CD.Id_Producto = @Id_producto
                  OR @Id_producto = 0)
             AND (CP.Cod_TipoComprobante = @Cod_TipoComprobante
                  OR @Cod_TipoComprobante IS NULL)
             AND (CP.Serie = @Serie
                  OR @Serie IS NULL)
             AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), FechaEmision, 103)) BETWEEN CONVERT(DATETIME, @FechaInicio) AND CONVERT(DATETIME, @FechaFin)
                  OR @FechaInicio IS NULL)
             AND (@Cod_TurnoInicio IS NULL
                  OR cp.Cod_Turno IN
        (
            SELECT Cod_Turno
            FROM #Turnos
        ))
             AND (CP.Cod_Moneda = @Cod_Moneda
                  OR @Cod_Moneda IS NULL)
        ORDER BY FechaEmision, 
                 Cod_TipoComprobante, 
                 Serie, 
                 Numero;
        DROP TABLE #Turnos;
        DROP TABLE [#VIS_TIPO_COMPROBANTES];
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 11/12/2015
-- OBJETIVO: Reporte de Stock
-- URP_PRI_PRODUCTO_STOCK_TotalReporteGeneral NULL,NULL,NULL,NULL,1,0,0,'2018-06-27'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_PRI_PRODUCTO_STOCK_TotalReporteGeneral'
          AND type = 'P'
)
    DROP PROCEDURE URP_PRI_PRODUCTO_STOCK_TotalReporteGeneral;
GO
CREATE PROCEDURE URP_PRI_PRODUCTO_STOCK_TotalReporteGeneral @Cod_UnidadMedida AS   VARCHAR(32) = NULL, 
                                                            @Cod_Moneda AS         VARCHAR(5)  = NULL, 
                                                            @Cod_Categoria AS      VARCHAR(32) = NULL, 
                                                            @Cod_Marca AS          VARCHAR(32) = NULL, 
                                                            @Flag_Activos AS       BIT         = 1, 
                                                            @Flag_IncluirCero AS   BIT         = 0, 
                                                            @Flag_SoloNegativos AS BIT         = 0, 
                                                            @Fecha AS              DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        -- contar los productos de comprobantes de pago
        SELECT Nro, 
               Cod_UnidadMedida, 
               Nom_UnidadMedida, 
               Tipo, 
               Cod_Sunat, 
               Estado
        INTO #VIS_UNIDADES_DE_MEDIDA
        FROM VIS_UNIDADES_DE_MEDIDA;
        SELECT Nro, 
               Cod_Moneda, 
               Nom_Moneda, 
               Simbolo, 
               Definicion, 
               Estado
        INTO #VIS_MONEDAS
        FROM VIS_MONEDAS;
        SELECT DISTINCT 
               P.Nom_Producto, 
               P.Flag_Activo, 
               P.Flag_Stock, 
               P.Cod_Categoria, 
               C.Des_Categoria, 
               P.Cod_Fabricante, 
               P.Cod_Producto, 
               VM.Simbolo, 
               VM.Definicion, 
               VUM.Nom_UnidadMedida, 
               PS.Precio_Compra, 
               PS.Precio_Venta, 
               PS.Stock_Min, 
               PS.Stock_Max, 
               PS.Stock_Act,
               CASE P.Flag_Stock
                   WHEN 1
                   THEN StockCalculado
                   ELSE 0
               END AS StockCalculado, 
               '' AS Serie
        FROM
        (
            SELECT P.Id_Producto, 
                   P.Cod_UnidadMedida, 
                   SUM(P.StockActual) AS StockCalculado, 
                   AVG(P.Stock_Act) AS Stock_Act
            FROM
            (
                SELECT CD.Id_Producto, 
                       CD.Cod_UnidadMedida, 
                       ISNULL(SUM(CASE CP.Cod_Libro
                                      WHEN '08'
                                      THEN CD.Cantidad
                                      WHEN '14'
                                      THEN-1 * CD.Cantidad
                                      ELSE 0
                                  END), 0) AS StockActual, 
                       PS.Stock_Act
                FROM CAJ_COMPROBANTE_PAGO AS CP
                     INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON CD.Id_Producto = PS.Id_Producto
                                                            AND CD.Cod_Almacen = PS.Cod_Almacen
                                                            AND CD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE Flag_Despachado = 1
                      AND Flag_Anulado = 0
                      AND CONVERT(DATETIME, CONVERT(VARCHAR, CP.FechaEmision, 103)) <= @Fecha
                GROUP BY CD.Id_Producto, 
                         CD.Cod_UnidadMedida, 
                         PS.Stock_Act
                UNION
                SELECT AMD.Id_Producto, 
                       AMD.Cod_UnidadMedida, 
                       SUM(CASE AM.Cod_TipoComprobante
                               WHEN 'NE'
                               THEN AMD.Cantidad
                               WHEN 'NS'
                               THEN-1 * AMD.Cantidad
                               ELSE 0
                           END) AS Stock, 
                       PS.Stock_Act
                FROM ALM_ALMACEN_MOV AS AM
                     INNER JOIN ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON AM.Cod_Almacen = PS.Cod_Almacen
                                                            AND AMD.Id_Producto = PS.Id_Producto
                                                            AND AMD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE CONVERT(DATETIME, CONVERT(VARCHAR, AM.Fecha, 103)) <= @Fecha
                      AND Flag_Anulado = 0
                GROUP BY AMD.Id_Producto, 
                         AMD.Cod_UnidadMedida, 
                         PS.Stock_Act
            ) AS P
            GROUP BY P.Id_Producto, 
                     P.Cod_UnidadMedida
        ) AS SP
        INNER JOIN PRI_PRODUCTO_STOCK AS PS ON SP.Id_Producto = PS.Id_Producto
                                               AND SP.Cod_UnidadMedida = PS.Cod_UnidadMedida
                                               AND SP.Id_Producto = PS.Id_Producto
        INNER JOIN PRI_PRODUCTOS AS P ON PS.Id_Producto = P.Id_Producto
        INNER JOIN #VIS_UNIDADES_DE_MEDIDA AS VUM ON PS.Cod_UnidadMedida = VUM.Cod_UnidadMedida
        INNER JOIN #VIS_MONEDAS AS VM ON PS.Cod_Moneda = VM.Cod_Moneda
        INNER JOIN PRI_CATEGORIA AS C ON P.Cod_Categoria = C.Cod_Categoria
        WHERE(@Cod_UnidadMedida = PS.Cod_UnidadMedida
              OR @Cod_UnidadMedida IS NULL)
             AND (@Cod_Moneda = PS.Cod_Moneda
                  OR @Cod_Moneda IS NULL)
             AND (@Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
            AND (@Cod_Marca = P.Cod_Marca
                 OR @Cod_Marca IS NULL)
            AND (@Flag_Activos = P.Flag_Activo)
            AND ((@Flag_IncluirCero = 1
                  AND StockCalculado > 0)
                 OR @Flag_IncluirCero = 0)
            AND ((@Flag_SoloNegativos = 1
                  AND StockCalculado < 0)
                 OR @Flag_SoloNegativos = 0)
        ORDER BY Nom_Producto;
        DROP TABLE #VIS_UNIDADES_DE_MEDIDA;
        DROP TABLE #VIS_MONEDAS;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 11/12/2015,26/03/2019
-- OBJETIVO: Reporte de VENTAS, AGREGAMOS lo del vendedor
-- URP_CAJ_COMPROBANTE_PAGO_ReporteGeneral NULL,NULL,NULL,NULL,1,0,0,'2018-06-27'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_ReporteGeneral'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_ReporteGeneral;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_ReporteGeneral @Cod_Libro AS           VARCHAR(5), 
                                                         @Cod_Sucursal AS        VARCHAR(32) = NULL, 
                                                         @Id_Cliente          INT         = 0, 
                                                         @Cod_Caja            VARCHAR(32) = NULL, 
                                                         @Id_producto AS         INT         = 0, 
                                                         @FechaInicio AS         VARCHAR(32) = NULL, 
                                                         @FechaFin AS            VARCHAR(32) = NULL, 
                                                         @Cod_TurnoInicio AS     VARCHAR(32) = NULL, 
                                                         @Cod_TurnoFinal AS      VARCHAR(32) = NULL, 
                                                         @Cod_Moneda AS          VARCHAR(5)  = NULL, 
                                                         @Cod_FormaPago AS       VARCHAR(5)  = NULL, 
                                                         @Cod_TipoComprobante AS VARCHAR(5)  = NULL, 
                                                         @Serie AS               VARCHAR(5)  = NULL, 
                                                         @Cod_Licitacion AS      VARCHAR(32) = NULL, 
                                                         @Cod_Categoria AS       VARCHAR(32) = NULL, 
                                                         @Anulados AS            BIT         = 0, 
                                                         @Cod_UsuarioVendedor AS VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        -------------- CARGAR LAS VISTAS PARA TRABAJAR MEJOR
        SELECT Nro, 
               Cod_Moneda, 
               Nom_Moneda, 
               Simbolo, 
               Definicion, 
               Estado
        INTO [#VIS_MONEDAS]
        FROM VIS_MONEDAS;
        SELECT Nro, 
               Cod_FormaPago, 
               Nom_FormaPago, 
               Estado
        INTO [#VIS_FORMAS_PAGO]
        FROM VIS_FORMAS_PAGO;
        SELECT Nro, 
               Cod_TipoComprobante, 
               Nom_TipoComprobante, 
               Cod_Sunat, 
               Flag_Ventas, 
               Flag_Compras, 
               Flag_RegistroVentas, 
               Flag_RegistroCompras, 
               Estado
        INTO [#VIS_TIPO_COMPROBANTES]
        FROM VIS_TIPO_COMPROBANTES;
        SELECT Nro, 
               Cod_TipoDoc, 
               Nom_TipoDoc, 
               Estado
        INTO [#VIS_TIPO_DOCUMENTOS]
        FROM VIS_TIPO_DOCUMENTOS;
        SELECT Nro, 
               Cod_UnidadMedida, 
               Nom_UnidadMedida, 
               Tipo, 
               Cod_Sunat, 
               Estado
        INTO [#VIS_UNIDADES_DE_MEDIDA]
        FROM VIS_UNIDADES_DE_MEDIDA;
        CREATE TABLE #Turnos(Cod_Turno VARCHAR(32));
        --CREATE TABLE #Turnos ( Cod_Turno  varchar(32) collate SQL_Latin1_General_CP1_CI_AS);

        IF(@Cod_TurnoInicio IS NOT NULL)
            BEGIN
                DECLARE @FechaI AS DATETIME, @FechaF AS DATETIME;
                SELECT @FechaI = MIN(Fecha_Inicio), 
                       @FechaF = MAX(Fecha_Fin)
                FROM CAJ_TURNO_ATENCION
                WHERE Cod_Turno IN(@Cod_TurnoInicio, @Cod_TurnoFinal);
                INSERT INTO #Turnos
                       SELECT Cod_Turno
                       FROM CAJ_TURNO_ATENCION
                       WHERE Fecha_Inicio BETWEEN @FechaI AND @FechaF;
        END;
            ELSE
            BEGIN
                INSERT INTO #Turnos
                       SELECT Cod_Turno
                       FROM CAJ_TURNO_ATENCION
                       WHERE Fecha_Inicio BETWEEN @FechaInicio AND @FechaFin;
        END;
        SELECT DISTINCT 
               CP.id_ComprobantePago, 
               CP.Cod_Libro, 
               CP.Cod_Periodo, 
               C.Cod_Caja, 
               C.Des_Caja, 
               S.Cod_Sucursal, 
               S.Nom_Sucursal, 
               CP.Cod_Turno, 
               CP.Cod_TipoOperacion, 
               VTD.Cod_TipoComprobante, 
               VTD.Nom_TipoComprobante, 
               CP.Serie, 
               CP.Numero, 
               CP.Id_Cliente, 
               TD.Cod_TipoDoc, 
               TD.Nom_TipoDoc, 
               CP.Doc_Cliente,
               CASE CP.Flag_Anulado
                   WHEN 1
                   THEN 'ANULADO'
                   ELSE CP.Nom_Cliente
               END AS Nom_Cliente, 
               CP.Direccion_Cliente, 
               CP.FechaEmision, 
               CP.FechaVencimiento, 
               CP.FechaCancelacion, 
               CP.Glosa, 
               CP.TipoCambio, 
               CP.Flag_Anulado, 
               CP.Flag_Despachado, 
               VFP.Cod_FormaPago, 
               VFP.Nom_FormaPago, 
               CP.Descuento_Total, 
               VM.Cod_Moneda, 
               VM.Nom_Moneda, 
               VM.Simbolo, 
               CP.Impuesto, 
               CP.Total, 
               CP.Id_GuiaRemision, 
               CP.GuiaRemision, 
               CP.id_ComprobanteRef, 
               CP.Cod_Plantilla, 
               CP.Cod_UsuarioReg, 
               CP.Fecha_Reg, 
               CPD.id_Detalle, 
               P.Id_Producto,
               CASE CP.Flag_Anulado
                   WHEN 1
                   THEN 'ANULADO'
                   ELSE P.Nom_Producto
               END AS Nom_Producto, 
               P.Des_CortaProducto, 
               P.Cod_Categoria, 
               P.Cod_Marca, 
               P.Cod_TipoProducto, 
               P.Cod_Producto, 
               P.Cod_Garantia, 
               P.Cod_TipoExistencia, 
               P.Cod_TipoOperatividad, 
               P.Flag_Activo, 
               P.Flag_Stock, 
               P.Cod_Fabricante, 
               CPD.Cod_Almacen, 
               CPD.Cantidad, 
               VUM.Cod_UnidadMedida, 
               VUM.Nom_UnidadMedida, 
               CPD.Despachado, 
               CPD.Descripcion, 
               CPD.PrecioUnitario, 
               CPD.Descuento, 
               CPD.Sub_Total, 
               CPD.Tipo, 
               dbo.UFN_CAJ_COMPROBANTE_D_Serie(CPD.id_ComprobantePago, CPD.id_Detalle) AS Obs_ComprobanteD, 
               CPD.Cod_Manguera, 
               LM.Cod_Licitacion, 
               CA.Des_Categoria
        FROM PRI_CATEGORIA AS CA
             RIGHT OUTER JOIN PRI_PRODUCTOS AS P ON CA.Cod_Categoria = P.Cod_Categoria
             RIGHT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
             INNER JOIN #VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
             LEFT OUTER JOIN #VIS_FORMAS_PAGO AS VFP ON CP.Cod_FormaPago = VFP.Cod_FormaPago
             INNER JOIN #VIS_TIPO_COMPROBANTES AS VTD ON CP.Cod_TipoComprobante = VTD.Cod_TipoComprobante
             INNER JOIN PRI_SUCURSAL AS S ON C.Cod_Sucursal = S.Cod_Sucursal
             INNER JOIN #VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDoc = TD.Cod_TipoDoc
             LEFT OUTER JOIN CAJ_COMPROBANTE_D AS CPD ON CP.id_ComprobantePago = CPD.id_ComprobantePago
             LEFT OUTER JOIN #VIS_UNIDADES_DE_MEDIDA AS VUM ON CPD.Cod_UnidadMedida = VUM.Cod_UnidadMedida
             LEFT OUTER JOIN PRI_LICITACIONES_M AS LM ON CP.id_ComprobantePago = LM.id_ComprobantePago ON P.Id_Producto = CPD.Id_Producto
        WHERE(cp.Id_Cliente = @Id_Cliente
              OR @Id_Cliente = 0)
             AND (Cod_Libro = @Cod_Libro)
             AND (S.Cod_Sucursal = @Cod_Sucursal
                  OR @Cod_Sucursal IS NULL)
             AND (C.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (cp.Cod_FormaPago = @Cod_FormaPago
                  OR @Cod_FormaPago IS NULL)
             AND (P.Id_Producto = @Id_producto
                  OR @Id_producto = 0)
             AND (CP.Cod_TipoComprobante = @Cod_TipoComprobante
                  OR @Cod_TipoComprobante IS NULL)
             AND (CP.Serie = @Serie
                  OR @Serie IS NULL)
             AND (CONVERT(DATETIME, CONVERT(VARCHAR(32), FechaEmision, 103)) BETWEEN CONVERT(DATETIME, @FechaInicio) AND CONVERT(DATETIME, @FechaFin)
                  OR @FechaInicio IS NULL)
             AND (@Cod_TurnoInicio IS NULL
                  OR Cod_Turno IN
        (
            SELECT Cod_Turno
            FROM #Turnos
        ))
             AND (CP.Cod_Moneda = @Cod_Moneda
                  OR @Cod_Moneda IS NULL)
             AND (LM.Cod_Licitacion = @Cod_Licitacion
                  OR @Cod_Licitacion IS NULL)
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (@Anulados = 0
                  OR CP.Flag_Anulado = 1)
        ORDER BY FechaEmision, 
                 Cod_TipoComprobante, 
                 Serie, 
                 Numero;
        DROP TABLE #Turnos;
        DROP TABLE #VIS_MONEDAS;
        DROP TABLE #VIS_FORMAS_PAGO;
        DROP TABLE #VIS_TIPO_COMPROBANTES;
        DROP TABLE #VIS_UNIDADES_DE_MEDIDA;
        DROP TABLE #VIS_TIPO_DOCUMENTOS;
    END;
GO
-- URP_ResumenVentasXProducto 'D02/08/2018','101'
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_ResumenVentasXProducto'
          AND type = 'P'
)
    DROP PROCEDURE URP_ResumenVentasXProducto;
GO
CREATE PROCEDURE URP_ResumenVentasXProducto @Cod_Turno AS VARCHAR(32), 
                                            @Cod_Caja AS  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT P.Cod_Producto, 
               CD.Descripcion AS Nom_Producto, 
               SUM(CD.Cantidad) AS Cantidad, 
               SUM(CD.Cantidad * CD.PrecioUnitario - CD.Descuento) AS Total, 
               C.Des_Caja, 
               T.Des_Turno
        FROM CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
             INNER JOIN PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto
             INNER JOIN CAJ_TURNO_ATENCION AS T ON CP.Cod_Turno = T.Cod_Turno
             INNER JOIN CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja
        WHERE(CP.Cod_Caja = @Cod_Caja)
             AND (CP.Cod_Turno = @Cod_Turno)
             AND cod_libro = '14'
        GROUP BY P.Cod_Producto, 
                 CD.Descripcion, 
                 C.Des_Caja, 
                 T.Des_Turno
        ORDER BY Cantidad DESC;
    END; 
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento a CAJ_GUIA_REMISION_REMITENTE sin detalles adicionales
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los elementos relacionados de una guia de remision
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_ComprobantesRelacionados_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los vehiculos relacionados de una guia de remision
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_Relacionados_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los transportistas relacionados de una guia de remision
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_Conductores_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los documentos adicionales relacionados de una guia de remision
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_Documentos_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae las guias de remision remitente en base a los filtros seleccionados
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.URP_CAJ_GUIA_REMISION_REMITENTE_TraerGuias
--	@Cod_Caja = '101',
--	@Cod_Turno = 'D01/01/2018',
--	@Cod_TipoComprobante = 'GRR',
--	@Cod_Libro = '14',
--	@Cod_Periodo = '2018-02',
--	@Serie = 'G001',
--	@Cod_EstadoGuia = 'INI',
--	@Flag_Anulado = 0,
--	@Fecha_Inicio = NULL,
--	@Fecha_Final = NULL
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
--exec URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota 26127,'NC','14','B101','PEN','2016-04-29 00:00:00:000','2018-06-08 00:00:00:000'
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TraerComprobantesAfectarNota @IdCliente              INT, 
                                                                       @CodTipoComprobanteNota VARCHAR(10), 
                                                                       @CodLibro               VARCHAR(10), 
                                                                       @Serie                  VARCHAR(10), 
                                                                       @CodMoneda              VARCHAR(10) = NULL, 
                                                                       @FechaInicio            DATETIME, 
                                                                       @FechaFin               DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        --NC : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
        IF(@CodTipoComprobanteNota = 'NC')
            BEGIN
                SELECT Res.id_ComprobantePago, 
                       Res.FechaEmision, 
                       Res.Cod_Moneda, 
                       Res.Documento, 
                       Res.Cliente, 
                       CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                       CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                       CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                       Res.Cod_Turno, 
                       Res.Glosa
                FROM
                (
                    SELECT ccp.id_ComprobantePago, 
                           ccp.FechaEmision, 
                           ccp.Cod_Moneda, 
                           ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                           ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                           ccp.Total, 
                           ISNULL(
                    (
                        SELECT SUM(ABS(ISNULL(ccp2.Total, 0)))
                        FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp2.id_ComprobantePago = ccr.id_ComprobantePago
                        WHERE ccr.Cod_TipoRelacion = 'CRE'
                              AND ccr.Id_ComprobanteRelacion = ccp.id_ComprobantePago
                    ), 0) TotalNotas, 
                           ccp.Cod_Turno, 
                           ccp.Glosa
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'FA', 'BO')
                           AND ccp.Flag_Anulado = 0
                           AND ccp.Cod_Libro = @CodLibro
                           AND (@CodMoneda IS NULL
                                OR @CodMoneda = ccp.Cod_Moneda)
                           AND ccp.Id_Cliente = @IdCliente
                ) Res
                WHERE 
                --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
                Res.FechaEmision >= @FechaInicio
                AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                ORDER BY Res.FechaEmision;
        END;
        --NCE : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
        IF(@CodTipoComprobanteNota = 'NCE')
            BEGIN
                IF(@Serie LIKE 'F%')
                    BEGIN
                        SELECT Res.id_ComprobantePago, 
                               Res.FechaEmision, 
                               Res.Cod_Moneda, 
                               Res.Documento, 
                               Res.Cliente, 
                               CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                               CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                               CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                               Res.Cod_Turno, 
                               Res.Glosa
                        FROM
                        (
                            SELECT ccp.id_ComprobantePago, 
                                   ccp.FechaEmision, 
                                   ccp.Cod_Moneda, 
                                   ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                                   ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                                   ccp.Total, 
                                   ISNULL(
                            (
                                SELECT SUM(ABS(ccp2.Total))
                                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                                WHERE ccp2.id_ComprobanteRef = ccp.id_ComprobantePago
                                      AND ccp2.Cod_Libro = @CodLibro
                                      AND ccp2.Flag_Anulado = 0
                            ), 0) TotalNotas, 
                                   ccp.Cod_Turno, 
                                   ccp.Glosa
                            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                            WHERE ccp.Cod_TipoComprobante IN('FE')
                            AND ccp.Serie LIKE 'F%'
                            AND ccp.Flag_Anulado = 0
                            AND ccp.Cod_Libro = @CodLibro
                            AND (@CodMoneda IS NULL
                                 OR @CodMoneda = ccp.Cod_Moneda)
                            AND ccp.Id_Cliente = @IdCliente
                        ) Res
                        WHERE
                        --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
                        Res.FechaEmision >= @FechaInicio
                        AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                        ORDER BY Res.FechaEmision;
                END;
                IF(@Serie LIKE 'B%')
                    BEGIN
                        SELECT Res.id_ComprobantePago, 
                               Res.FechaEmision, 
                               Res.Cod_Moneda, 
                               Res.Documento, 
                               Res.Cliente, 
                               CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                               CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                               CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                               Res.Cod_Turno, 
                               Res.Glosa
                        FROM
                        (
                            SELECT ccp.id_ComprobantePago, 
                                   ccp.FechaEmision, 
                                   ccp.Cod_Moneda, 
                                   ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                                   ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                                   ccp.Total, 
                                   ISNULL(
                            (
                                SELECT SUM(ABS(ccp2.Total))
                                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                                WHERE ccp2.id_ComprobanteRef = ccp.id_ComprobantePago
                                      AND ccp2.Cod_Libro = @CodLibro
                                      AND ccp2.Flag_Anulado = 0
                            ), 0) TotalNotas, 
                                   ccp.Cod_Turno, 
                                   ccp.Glosa
                            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                            WHERE ccp.Cod_TipoComprobante IN('BE')
                            AND ccp.Serie LIKE 'B%'
                            AND ccp.Flag_Anulado = 0
                            AND ccp.Cod_Libro = @CodLibro
                            AND (@CodMoneda IS NULL
                                 OR @CodMoneda = ccp.Cod_Moneda)
                            AND ccp.Id_Cliente = @IdCliente
                        ) Res
                        WHERE --((Res.Total - Res.TotalNotas > 0 AND @CodLibro='14') OR (@CodLibro='08')) AND 
                        Res.FechaEmision >= @FechaInicio
                        AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                        ORDER BY Res.FechaEmision;
                END;
        END;

        --ND : puede afectar a FE,BE,FA,BO,TKB,TKF no importa la serie
        IF(@CodTipoComprobanteNota = 'ND')
            BEGIN
                SELECT Res.id_ComprobantePago, 
                       Res.FechaEmision, 
                       Res.Cod_Moneda, 
                       Res.Documento, 
                       Res.Cliente, 
                       CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                       CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                       CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                       Res.Cod_Turno, 
                       Res.Glosa
                FROM
                (
                    SELECT ccp.id_ComprobantePago, 
                           ccp.FechaEmision, 
                           ccp.Cod_Moneda, 
                           ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                           ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                           ccp.Total, 
                           0 TotalNotas, 
                           ccp.Cod_Turno, 
                           ccp.Glosa
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'FA', 'BO')
                    AND ccp.Flag_Anulado = 0
                    AND ccp.Cod_Libro = @CodLibro
                    AND (@CodMoneda IS NULL
                         OR @CodMoneda = ccp.Cod_Moneda)
                    AND ccp.Id_Cliente = @IdCliente
                ) Res
                WHERE Res.FechaEmision >= @FechaInicio
                      AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                ORDER BY Res.FechaEmision;
        END;	
        --NDE : : solo puede afectar a FE,BE si la serie empieza con F solo afecta a comprobantes de serie F, igual con B
        IF(@CodTipoComprobanteNota = 'NDE')
            BEGIN
                IF(@Serie LIKE 'F%')
                    BEGIN
                        SELECT Res.id_ComprobantePago, 
                               Res.FechaEmision, 
                               Res.Cod_Moneda, 
                               Res.Documento, 
                               Res.Cliente, 
                               CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                               CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                               CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                               Res.Cod_Turno, 
                               Res.Glosa
                        FROM
                        (
                            SELECT ccp.id_ComprobantePago, 
                                   ccp.FechaEmision, 
                                   ccp.Cod_Moneda, 
                                   ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                                   ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                                   ccp.Total, 
                                   0 TotalNotas, 
                                   ccp.Cod_Turno, 
                                   ccp.Glosa
                            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                            WHERE ccp.Cod_TipoComprobante IN('FE')
                            AND ccp.Serie LIKE 'F%'
                            AND ccp.Flag_Anulado = 0
                            AND ccp.Cod_Libro = @CodLibro
                            AND (@CodMoneda IS NULL
                                 OR @CodMoneda = ccp.Cod_Moneda)
                            AND ccp.Id_Cliente = @IdCliente
                        ) Res
                        WHERE Res.FechaEmision >= @FechaInicio
                              AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                        ORDER BY Res.FechaEmision;
                END;
                IF(@Serie LIKE 'B%')
                    BEGIN
                        SELECT Res.id_ComprobantePago, 
                               Res.FechaEmision, 
                               Res.Cod_Moneda, 
                               Res.Documento, 
                               Res.Cliente, 
                               CAST(Res.Total AS NUMERIC(38, 6)) Total, 
                               CAST(Res.TotalNotas AS NUMERIC(38, 6)) TotalNotas, 
                               CAST(Res.Total - Res.TotalNotas AS NUMERIC(38, 6)) Disponible, 
                               Res.Cod_Turno, 
                               Res.Glosa
                        FROM
                        (
                            SELECT ccp.id_ComprobantePago, 
                                   ccp.FechaEmision, 
                                   ccp.Cod_Moneda, 
                                   ccp.Cod_TipoComprobante + ':' + ccp.Serie + '-' + ccp.Numero Documento, 
                                   ccp.Doc_Cliente + ':' + ccp.Nom_Cliente Cliente, 
                                   ccp.Total, 
                                   0 TotalNotas, 
                                   ccp.Cod_Turno, 
                                   ccp.Glosa
                            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                            WHERE ccp.Cod_TipoComprobante IN('BE')
                            AND ccp.Serie LIKE 'B%'
                            AND ccp.Flag_Anulado = 0
                            AND ccp.Cod_Libro = @CodLibro
                            AND (@CodMoneda IS NULL
                                 OR @CodMoneda = ccp.Cod_Moneda)
                            AND ccp.Id_Cliente = @IdCliente
                        ) Res
                        WHERE Res.FechaEmision >= @FechaInicio
                              AND Res.FechaEmision < DATEADD(day, 1, @FechaFin)
                        ORDER BY Res.FechaEmision;
                END;
        END;
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
--Exec URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda 76542
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_RecuperarComanda @Id_ComprobanteComanda INT
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @TotalComanda NUMERIC(38, 2)=
        (
            SELECT SUM(((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) + CASE
                                                                                     WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                                                                                     THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                                                                                     WHEN ppt.Cod_Aplicacion = 'MONTO'
                                                                                     THEN(ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa
                                                                                     ELSE 0
                                                                                 END)
            FROM dbo.CAJ_COMPROBANTE_D ccd
                 LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ccd.Id_Producto = ppt.Id_Producto
            WHERE ccd.id_ComprobantePago = @Id_ComprobanteComanda
                  AND ccd.IGV = 0
        );
        WITH PRIMERORDEN(id_Detalle, 
                         Padre, 
                         Cod_Manguera, 
                         Numero, 
                         Cod_UsuarioReg, 
                         FechaEmision, 
                         Cantidad, 
                         Descripcion, 
                         Nivel)
             AS (SELECT ccd.id_Detalle, 
                        CONVERT(INT, ccd.IGV) Grupo, 
                        ccd.Cod_Manguera, 
                        ccp.Numero, 
                        ccp.Cod_UsuarioReg, 
                        ccp.FechaEmision, 
                        ccd.Cantidad - ccd.Formalizado Cantidad, 
                        ccd.Descripcion, 
                        0 Nivel
                 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                      INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                 WHERE(ccp.id_ComprobantePago = @Id_ComprobanteComanda
                       AND ccd.IGV = 0
                       AND ccd.Cantidad - ccd.Formalizado > 0)
                 UNION ALL
                 SELECT ccd.id_Detalle, 
                        CONVERT(INT, ccd.IGV) Grupo, 
                        ccd.Cod_Manguera, 
                        res.Numero, 
                        res.Cod_UsuarioReg, 
                        res.FechaEmision, 
                        ccd.Cantidad, 
                        ccd.Descripcion, 
                        Nivel + 1 Nivel
                 FROM dbo.CAJ_COMPROBANTE_D ccd
                      INNER JOIN PRIMERORDEN res ON res.id_Detalle = ccd.IGV
                 WHERE ccd.id_ComprobantePago = @Id_ComprobanteComanda)
             SELECT pe.RUC, 
                    pe.Nom_Comercial, 
                    pe.RazonSocial, 
                    pe.Direccion, 
                    pe.Web, 
                    vtc.Cod_TipoComprobante, 
                    vtc.Nom_TipoComprobante, 
                    CAST(CASE
                             WHEN p.Padre = 0
                             THEN CONCAT(p.id_Detalle, '0')
                             ELSE CONCAT(p.Padre, RIGHT(p.id_Detalle, 1))
                         END AS INT) Orden, 
                    p.id_Detalle, 
                    p.Padre, 
                    p.Cod_Manguera Cod_Mesa, 
                    vm.Nom_Mesa, 
                    p.Numero, 
                    p.Cod_UsuarioReg, 
                    p.FechaEmision,
                    CASE
                        WHEN p.Nivel = 0
                        THEN p.Cantidad
                        ELSE 0
                    END Cantidad_Principal,
                    CASE
                        WHEN p.Nivel = 0
                        THEN 0
                        ELSE p.Cantidad
                    END Cantidad_Auxiliar, 
                    p.Descripcion, 
                    ccd.PrecioUnitario, 
                    (ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario Sub_Total,
                    CASE
                        WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                        THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                        WHEN ppt.Cod_Aplicacion = 'MONTO'
                        THEN(ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa
                        ELSE 0
                    END ICBPER, 
                    @TotalComanda Total, 
                    ccp.Cod_UsuarioVendedor, 
                    p.Nivel
             FROM PRIMERORDEN p
                  INNER JOIN dbo.VIS_MESAS vm ON p.Cod_Manguera = vm.Cod_Mesa
                  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON @Id_ComprobanteComanda = ccp.id_ComprobantePago
                  INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp.Cod_TipoComprobante = vtc.Cod_TipoComprobante
                  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
                                                          AND p.id_Detalle = ccd.id_Detalle
                  LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ppt.Cod_Libro = '14'
                                                         AND ppt.Cod_Tasa = 'ICBPER'
                                                         AND ccd.Id_Producto = ppt.Id_Producto
                  CROSS JOIN dbo.PRI_EMPRESA pe
             ORDER BY Orden, 
                      p.id_Detalle;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_COMPROBANTE_PAGO_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK;
GO
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK @id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT @id_ComprobantePago id_ComprobantePago,
               CASE
                   WHEN ccp.Cod_TipoComprobante = 'BE'
                   THEN 'BOLETA DE VENTA ELECTRONICA'
                   WHEN ccp.Cod_TipoComprobante = 'FE'
                   THEN 'FACTURA ELECTRONICA'
                   WHEN ccp.Cod_TipoComprobante = 'NCE'
                   THEN 'NOTA DE CREDITO ELECTRONICA'
                   WHEN ccp.Cod_TipoComprobante = 'NDE'
                   THEN 'NOTA DE DEBITO ELECTRONICA'
                   WHEN ccp.Cod_TipoComprobante = 'BO'
                   THEN 'BOLETA'
                   WHEN ccp.Cod_TipoComprobante = 'FA'
                   THEN 'FACTURA'
                   WHEN ccp.Cod_TipoComprobante = 'NC'
                   THEN 'NOTA DE CREDITO'
                   WHEN ccp.Cod_TipoComprobante = 'ND'
                   THEN 'NOTA DE DEBITO'
                   WHEN ccp.Cod_TipoComprobante = 'TKB'
                   THEN 'TICKET BOLETA'
                   WHEN ccp.Cod_TipoComprobante = 'TKF'
                   THEN 'TICKET FACTURA'
                   ELSE ''
               END Nom_TipoComprobante, 
               ccp.Serie, 
               ccp.Numero,
               CASE
                   WHEN ccp.Cod_TipoDoc = '0'
                        OR ccp.Cod_TipoDoc = '99'
                   THEN 'SIN'
                   WHEN ccp.Cod_TipoDoc = '6'
                   THEN 'RUC'
                   WHEN ccp.Cod_TipoDoc = '7'
                   THEN 'PASAPORTE'
                   WHEN ccp.Cod_TipoDoc = '4'
                   THEN 'CARNET DE EXTRANJERIA'
                   WHEN ccp.Cod_TipoDoc = 'A'
                   THEN 'CÉDULA DIPLOMÁTICA DE IDENTIDAD'
                   WHEN ccp.Cod_TipoDoc = '1'
                   THEN 'DNI'
                   ELSE 'SIN'
               END Nom_TipoDoc, 
               ccp.Doc_Cliente, 
               ccp.Nom_Cliente, 
               ccp.Direccion_Cliente, 
               ccp.FechaEmision, 
               ccp.FechaVencimiento, 
               ccp.FechaCancelacion, 
               ccp.Glosa, 
               ccp.TipoCambio, 
               ccp.Flag_Anulado,
               CASE
                   WHEN ccp.Cod_FormaPago = '008'
                   THEN 'EFECTIVO'
                   WHEN ccp.Cod_FormaPago = '007'
                   THEN 'CHEQUES'
                   WHEN ccp.Cod_FormaPago = '011'
                   THEN 'DEPOSITO EN CUENTA'
                   WHEN ccp.Cod_FormaPago = '005'
                        OR ccp.Cod_FormaPago = '006'
                   THEN 'TARJETA DE CREDITO/DEBITO'
                   WHEN ccp.Cod_FormaPago = '002'
                   THEN 'GIRO'
                   WHEN ccp.Cod_FormaPago = '998'
                   THEN 'PAGO ADELANTADO'
                   WHEN ccp.Cod_FormaPago = '999'
                   THEN 'CREDITO'
                   ELSE 'OTROS TIPOS DE PAGO'
               END Nom_FormaPago, 
               ccp.Descuento_Total,
               CASE
                   WHEN ccp.Cod_Moneda = 'PEN'
                   THEN 'SOLES'
                   WHEN ccp.Cod_Moneda = 'USD'
                   THEN 'DOLARES'
                   WHEN ccp.Cod_Moneda = 'EUR'
                   THEN 'EUROS'
                   ELSE 'OTRAS MONEDAS'
               END Nom_Moneda,
               CASE
                   WHEN ccp.Cod_Moneda = 'PEN'
                   THEN 'S/'
                   WHEN ccp.Cod_Moneda = 'USD'
                   THEN '$'
                   WHEN ccp.Cod_Moneda = '€'
                   THEN 'EUROS'
                   ELSE ''
               END Simbolo,
               CASE
                   WHEN ccp.Cod_Moneda = 'PEN'
                   THEN 'SOLES'
                   WHEN ccp.Cod_Moneda = 'USD'
                   THEN 'DOLARES'
                   WHEN ccp.Cod_Moneda = 'EUR'
                   THEN 'EUROS'
                   ELSE 'OTRAS MONEDAS'
               END Definicion, 
               ccp.Impuesto, 
               ccp.Total, 
               CONVERT(VARCHAR(255),
                                  CASE ccp.Cod_TipoComprobante
                                      WHEN 'NCE'
                                      THEN dbo.UFN_CAJ_COMPROBANTE_RELACION_TConcatenado(ccp.id_ComprobantePago, 'CRE')
                                      WHEN 'NDE'
                                      THEN dbo.UFN_CAJ_COMPROBANTE_RELACION_TConcatenado(ccp.id_ComprobantePago, 'DEB')
                                      ELSE ''
                                  END) Obs_Comprobante, 
               ccp.GuiaRemision, 
               ccp.Nro_Ticketera, 
               ccp.Cod_UsuarioVendedor, 
               ccp.Cod_RegimenPercepcion, 
               ccp.Tasa_Percepcion, 
               ccp.Placa_Vehiculo, 
               ccp.Cod_TipoDocReferencia, 
               ccp.Nro_DocReferencia, 
               ccp.Valor_Resumen, 
               ccp.Valor_Firma, 
               ccp.MotivoAnulacion, 
               ccp.Otros_Cargos, 
               ccp.Otros_Tributos, 
               pp.Cod_Producto, 
               aa.Des_Almacen, 
               aa.Des_CortaAlmacen, 
               ccd.Cantidad, 
               vudm.Nom_UnidadMedida, 
               CONVERT(VARCHAR(MAX), ccd.Descripcion) Descripcion, 
               ccd.PrecioUnitario, 
               ccd.Descuento, 
               ccd.Sub_Total, 
               dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(@id_ComprobantePago, ccd.id_Detalle, 'ICBPER', '14') ICBPER,
               CASE
                   WHEN pp.Cod_TipoOperatividad = 'GRT'
                   THEN 'GRATUITAS'
                   WHEN pp.Cod_TipoOperatividad = 'GRA'
                   THEN 'GRAVADAS'
                   WHEN pp.Cod_TipoOperatividad = 'INA'
                   THEN 'INAFECTAS'
                   WHEN pp.Cod_TipoOperatividad = 'EXO'
                   THEN 'EXONERADAS'
                   WHEN pp.Cod_TipoOperatividad = 'DES'
                   THEN 'DESCUENTOS'
                   WHEN pp.Cod_TipoOperatividad = 'PER'
                   THEN 'PERCECPION'
                   WHEN pp.Cod_TipoOperatividad = 'NGR'
                   THEN 'NO GRAVADAS'
                   ELSE 'OTROS'
               END Nom_TipoOperatividad, 
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
               NULL Foto, 
               dbo.UFN_ConvertirNumeroLetra(ccp.Total) + ' ' + CASE
                                                                   WHEN ccp.Cod_Moneda = 'PEN'
                                                                   THEN 'SOLES'
                                                                   WHEN ccp.Cod_Moneda = 'USD'
                                                                   THEN 'DOLARES'
                                                                   WHEN ccp.Cod_Moneda = 'EUR'
                                                                   THEN 'EUROS'
                                                                   ELSE 'OTRAS MONEDAS'
                                                               END Monto_Letras
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             LEFT JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.ALM_ALMACEN aa ON ccd.Cod_Almacen = aa.Cod_Almacen
             INNER JOIN dbo.VIS_UNIDADES_DE_MEDIDA vudm ON ccd.Cod_UnidadMedida = vudm.Cod_UnidadMedida
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
        WHERE ccp.id_ComprobantePago = @id_ComprobantePago;
    END;
GO