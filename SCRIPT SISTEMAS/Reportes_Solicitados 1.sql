--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener los margenes de utilidad por comprobante
-- EXEC dbo.URP_ReporteMargenUtilidadXComprobante @Id_ComprobantePago = NULL,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_ReporteMargenUtilidadXComprobante'
          AND type = 'P'
)
    DROP PROCEDURE URP_ReporteMargenUtilidadXComprobante;
GO
CREATE PROCEDURE URP_ReporteMargenUtilidadXComprobante @Id_ComprobantePago  INT         = NULL, 
                                                       @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                       @Cod_Caja            VARCHAR(32) = NULL, 
                                                       @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                       @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                       @Cod_Categoria       VARCHAR(32) = NULL, 
                                                       @Id_Cliente          INT         = NULL, 
                                                       @Cod_Turno           VARCHAR(32) = NULL, 
                                                       @Fecha_Inicio        DATETIME    = NULL, 
                                                       @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT DISTINCT 
               ccp.id_ComprobantePago, 
               CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', ccp.Numero) Documento, 
               cc.Cod_Sucursal, 
               ps.Nom_Sucursal, 
               ccp.Cod_Caja, 
               cc.Des_Caja, 
               ccp.Cod_Periodo, 
               ccp.Cod_Turno, 
               vtd.Nom_TipoDoc, 
               ccp.Doc_Cliente, 
               ccp.Nom_Cliente, 
               ccp.FechaEmision, 
               SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Valor_Compra, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) Valor_Venta, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
        WHERE ccp.Cod_Libro = '14'
              AND (@Id_ComprobantePago IS NULL
                   OR ccp.id_ComprobantePago = @Id_ComprobantePago)
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY ccp.id_ComprobantePago, 
                 ccp.Cod_TipoComprobante, 
                 ccp.Serie, 
                 ccp.Numero, 
                 ccp.Cod_Caja, 
                 ccp.Cod_Periodo, 
                 ccp.Cod_Turno, 
                 ccp.Cod_TipoDoc, 
                 ccp.Doc_Cliente, 
                 ccp.Nom_Cliente, 
                 ccp.FechaEmision, 
                 vtd.Nom_TipoDoc, 
                 cc.Cod_Sucursal, 
                 ps.Nom_Sucursal, 
                 cc.Des_Caja
        ORDER BY Documento;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener los margenes de utilidad por producto
-- EXEC dbo.URP_ReporteMargenUtilidadXProducto @Id_producto = NULL,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Categoria = 'AA',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_ReporteMargenUtilidadXProducto'
          AND type = 'P'
)
    DROP PROCEDURE URP_ReporteMargenUtilidadXProducto;
GO
CREATE PROCEDURE URP_ReporteMargenUtilidadXProducto @Id_producto         INT         = NULL, 
                                                    @Cod_Almacen         VARCHAR(32) = NULL, 
                                                    @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                    @Cod_Marca           VARCHAR(32) = NULL, 
                                                    @Cod_Categoria       VARCHAR(32) = NULL, 
                                                    @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                    @Cod_Caja            VARCHAR(32) = NULL, 
                                                    @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                    @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                    @Id_Cliente          INT         = NULL, 
                                                    @Cod_Turno           VARCHAR(32) = NULL, 
                                                    @Fecha_Inicio        DATETIME    = NULL, 
                                                    @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT DISTINCT 
               pp.Id_Producto, 
               pp.Cod_Producto, 
               pp.Des_CortaProducto, 
               ccd.Cod_Almacen, 
               pps.Cod_UnidadMedida, 
               pp.Cod_Marca, 
               vm.Nom_Marca, 
               SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Valor_Compra, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) Valor_Venta, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.VIS_MARCA vm ON pp.Cod_Marca = vm.Cod_Marca
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Id_producto IS NULL
                  OR pp.Id_Producto = @Id_producto)
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
        GROUP BY pp.Id_Producto, 
                 pp.Cod_Producto, 
                 pp.Des_CortaProducto, 
                 ccd.Cod_Almacen, 
                 pps.Cod_UnidadMedida, 
                 pp.Cod_Marca, 
                 vm.Nom_Marca
        ORDER BY pp.Des_CortaProducto;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener los margenes de utilidad por vendedor
-- EXEC dbo.URP_ReporteMargenUtilidadXVendedor @Cod_UsuarioVendedor = 'ERWIN',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio =NULL,@Fecha_Final =NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_ReporteMargenUtilidadXVendedor'
          AND type = 'P'
)
    DROP PROCEDURE URP_ReporteMargenUtilidadXVendedor;
GO
CREATE PROCEDURE URP_ReporteMargenUtilidadXVendedor @Cod_UsuarioVendedor VARCHAR(32) = NULL, 
                                                    @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                    @Cod_Caja            VARCHAR(32) = NULL, 
                                                    @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                    @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                    @Cod_Categoria       VARCHAR(32) = NULL, 
                                                    @Id_Cliente          INT         = NULL, 
                                                    @Cod_Turno           VARCHAR(32) = NULL, 
                                                    @Fecha_Inicio        DATETIME    = NULL, 
                                                    @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT DISTINCT 
               ccp.Cod_UsuarioVendedor, 
               pu.Nick, 
               pp2.Des_Perfil, 
               SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Valor_Compra, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) Valor_Venta, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_USUARIO pu ON ccp.Cod_UsuarioVendedor = pu.Cod_Usuarios
             INNER JOIN dbo.PRI_PERFIL pp2 ON pu.Cod_Perfil = pp2.Cod_Perfil
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_UsuarioVendedor IS NULL
                  OR ccp.Cod_UsuarioVendedor = @Cod_UsuarioVendedor)
        GROUP BY ccp.Cod_UsuarioVendedor, 
                 pu.Nick, 
                 pp2.Des_Perfil
        ORDER BY ccp.Cod_UsuarioVendedor;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener los margenes de utilidad por cliente
-- EXEC dbo.URP_ReporteMargenUtilidadXCliente @Id_Cliente = NULL,@Cod_TipoDocumento = '6',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_ReporteMargenUtilidadXCliente'
          AND type = 'P'
)
    DROP PROCEDURE URP_ReporteMargenUtilidadXCliente;
GO
CREATE PROCEDURE URP_ReporteMargenUtilidadXCliente @Id_Cliente          INT         = NULL, 
                                                   @Cod_TipoDocumento   VARCHAR(3)  = NULL, 
                                                   @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                   @Cod_Caja            VARCHAR(32) = NULL, 
                                                   @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                   @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                   @Cod_Categoria       VARCHAR(32) = NULL, 
                                                   @Cod_Turno           VARCHAR(32) = NULL, 
                                                   @Fecha_Inicio        DATETIME    = NULL, 
                                                   @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Por Producto
        SELECT DISTINCT 
               pcp.Id_ClienteProveedor, 
               pcp.Cod_TipoDocumento, 
               pcp.Nro_Documento, 
               pcp.Cliente, 
               SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Valor_Compra, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) Valor_Venta, 
               SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_TipoDocumento IS NULL
                  OR pcp.Cod_TipoDocumento = @Cod_TipoDocumento)
        GROUP BY pcp.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 pcp.Nro_Documento, 
                 pcp.Cliente
        ORDER BY pcp.Cliente;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de productos mas vendidos por cantidad
-- EXEC dbo.URP_RankingProductosXCantidadVendidos @Top = 10,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Categoria = 'AA',@Cod_Sucursal = '0001',@Cod_Caja = 'A101',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingProductosXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingProductosXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingProductosXCantidadVendidos @Top                 INT         = 10, 
                                                       @Cod_Almacen         VARCHAR(32) = NULL, 
                                                       @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                       @Cod_Marca           VARCHAR(32) = NULL, 
                                                       @Cod_Categoria       VARCHAR(32) = NULL, 
                                                       @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                       @Cod_Caja            VARCHAR(32) = NULL, 
                                                       @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                       @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                       @Id_Cliente          INT         = NULL, 
                                                       @Cod_Turno           VARCHAR(32) = NULL, 
                                                       @Fecha_Inicio        DATETIME    = NULL, 
                                                       @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) pp.Id_Producto, 
                          pp.Cod_Producto, 
                          pp.Cod_Categoria, 
                          pp.Cod_Marca, 
                          pp.Nom_Producto, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND pp.Flag_Activo = 1
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
        GROUP BY pp.Id_Producto, 
                 pp.Cod_Producto, 
                 pp.Cod_Categoria, 
                 pp.Cod_Marca, 
                 pp.Nom_Producto
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de productos mas vendidos por utilidad
-- EXEC dbo.URP_RankingProductosXUtilidadVendidos @Top = 10,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Categoria = 'AA',@Cod_Sucursal = '0001',@Cod_Caja = 'A101',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingProductosXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingProductosXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingProductosXUtilidadVendidos @Top                 INT         = 10, 
                                                       @Cod_Almacen         VARCHAR(32) = NULL, 
                                                       @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                       @Cod_Marca           VARCHAR(32) = NULL, 
                                                       @Cod_Categoria       VARCHAR(32) = NULL, 
                                                       @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                       @Cod_Caja            VARCHAR(32) = NULL, 
                                                       @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                       @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                       @Id_Cliente          INT         = NULL, 
                                                       @Cod_Turno           VARCHAR(32) = NULL, 
                                                       @Fecha_Inicio        DATETIME    = NULL, 
                                                       @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) pp.Id_Producto, 
                          pp.Cod_Producto, 
                          pp.Cod_Categoria, 
                          pp.Cod_Marca, 
                          pp.Nom_Producto, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND pp.Flag_Activo = 1
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
        GROUP BY pp.Id_Producto, 
                 pp.Cod_Producto, 
                 pp.Cod_Categoria, 
                 pp.Cod_Marca, 
                 pp.Nom_Producto
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de categorias mas vendidos por cantidad
-- EXEC dbo.URP_RankingCategoriasXCantidadVendidos @Top = 10,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingCategoriasXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingCategoriasXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingCategoriasXCantidadVendidos @Top                 INT         = 10, 
                                                        @Cod_Almacen         VARCHAR(32) = NULL, 
                                                        @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                        @Cod_Marca           VARCHAR(32) = NULL, 
                                                        @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                        @Cod_Caja            VARCHAR(32) = NULL, 
                                                        @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                        @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                        @Id_Cliente          INT         = NULL, 
                                                        @Cod_Turno           VARCHAR(32) = NULL, 
                                                        @Fecha_Inicio        DATETIME    = NULL, 
                                                        @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --CATEGORIAS MAS VENDIDAS
        SELECT TOP (@Top) pc.Cod_Categoria, 
                          pc.Des_Categoria, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_CATEGORIA pc ON pp.Cod_Categoria = pc.Cod_Categoria
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
        GROUP BY pc.Cod_Categoria, 
                 pc.Des_Categoria
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de categorias mas vendidos por utilidad
-- EXEC dbo.URP_RankingCategoriasXUtilidadVendidos @Top = 10,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingCategoriasXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingCategoriasXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingCategoriasXUtilidadVendidos @Top                 INT         = 10, 
                                                        @Cod_Almacen         VARCHAR(32) = NULL, 
                                                        @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                        @Cod_Marca           VARCHAR(32) = NULL, 
                                                        @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                        @Cod_Caja            VARCHAR(32) = NULL, 
                                                        @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                        @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                        @Id_Cliente          INT         = NULL, 
                                                        @Cod_Turno           VARCHAR(32) = NULL, 
                                                        @Fecha_Inicio        DATETIME    = NULL, 
                                                        @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) pc.Cod_Categoria, 
                          pc.Des_Categoria, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_CATEGORIA pc ON pp.Cod_Categoria = pc.Cod_Categoria
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
        GROUP BY pc.Cod_Categoria, 
                 pc.Des_Categoria
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de marcas mas vendidos por cantidad
-- EXEC dbo.URP_RankingMarcasXCantidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingMarcasXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingMarcasXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingMarcasXCantidadVendidos @Top                 INT         = 10, 
                                                    @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                    @Cod_Caja            VARCHAR(32) = NULL, 
                                                    @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                    @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                    @Cod_Categoria       VARCHAR(32) = NULL, 
                                                    @Id_Cliente          INT         = NULL, 
                                                    @Cod_Turno           VARCHAR(32) = NULL, 
                                                    @Fecha_Inicio        DATETIME    = NULL, 
                                                    @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) vm.Cod_Marca, 
                          vm.Nom_Marca, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY vm.Cod_Marca, 
                 vm.Nom_Marca
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de marcas mas vendidos por utilidad
-- EXEC dbo.URP_RankingMarcasXUtilidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingMarcasXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingMarcasXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingMarcasXUtilidadVendidos @Top                 INT         = 10, 
                                                    @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                    @Cod_Caja            VARCHAR(32) = NULL, 
                                                    @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                    @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                    @Cod_Categoria       VARCHAR(32) = NULL, 
                                                    @Id_Cliente          INT         = NULL, 
                                                    @Cod_Turno           VARCHAR(32) = NULL, 
                                                    @Fecha_Inicio        DATETIME    = NULL, 
                                                    @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Marcas mas vendidas
        SELECT TOP (@Top) vm.Cod_Marca, 
                          vm.Nom_Marca, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY vm.Cod_Marca, 
                 vm.Nom_Marca
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de las cajas con mas ventas por cantidad
-- EXEC dbo.URP_RankingCajasXCantidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingCajasXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingCajasXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingCajasXCantidadVendidos @Top                 INT         = 10, 
                                                   @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                   @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                   @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                   @Cod_Categoria       VARCHAR(32) = NULL, 
                                                   @Id_Cliente          INT         = NULL, 
                                                   @Cod_Turno           VARCHAR(32) = NULL, 
                                                   @Fecha_Inicio        DATETIME    = NULL, 
                                                   @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Por caja
        SELECT TOP (@Top) ccp.Cod_Caja, 
                          cc.Des_Caja, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY ccp.Cod_Caja, 
                 cc.Des_Caja
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de las cajas con mas ventas por cantidad
-- EXEC dbo.URP_RankingCajasXUtilidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingCajasXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingCajasXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingCajasXUtilidadVendidos @Top                 INT         = 10, 
                                                   @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                   @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                   @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                   @Cod_Categoria       VARCHAR(32) = NULL, 
                                                   @Id_Cliente          INT         = NULL, 
                                                   @Cod_Turno           VARCHAR(32) = NULL, 
                                                   @Fecha_Inicio        DATETIME    = NULL, 
                                                   @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Por caja
        SELECT TOP (@Top) ccp.Cod_Caja, 
                          cc.Des_Caja, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY ccp.Cod_Caja, 
                 cc.Des_Caja
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los clientes con mas ventas por cantidad
-- EXEC dbo.URP_RankingClienteXCantidadVendidos @Top = 10, @Cod_TipoDocumento = '6', @Cod_Almacen = 'A101', @Cod_UnidadMedida = 'NIU', @Cod_Marca = 'M000136', @Cod_Categoria = 'AA', @Cod_Sucursal = '0001', @Cod_Caja = '100', @Cod_TipoComprobante = 'FE', @Cod_Moneda = 'PEN', @Id_Cliente = NULL, @Cod_Turno = NULL, @Fecha_Inicio = NULL, @Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingClienteXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingClienteXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingClienteXCantidadVendidos @Top                 INT         = 10, 
                                                     @Cod_TipoDocumento   VARCHAR(3)  = NULL, 
                                                     @Cod_Almacen         VARCHAR(32) = NULL, 
                                                     @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                     @Cod_Marca           VARCHAR(32) = NULL, 
                                                     @Cod_Categoria       VARCHAR(32) = NULL, 
                                                     @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                     @Cod_Caja            VARCHAR(32) = NULL, 
                                                     @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                     @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                     @Id_Cliente          INT         = NULL, 
                                                     @Cod_Turno           VARCHAR(32) = NULL, 
                                                     @Fecha_Inicio        DATETIME    = NULL, 
                                                     @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Por caja
        SELECT TOP (@Top) pcp.Id_ClienteProveedor, 
                          pcp.Cod_TipoDocumento, 
                          vtd.Nom_TipoDoc, 
                          ccp.Doc_Cliente, 
                          ccp.Nom_Cliente, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND pp.Flag_Activo = 1
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
             AND (@Cod_TipoDocumento IS NULL
                  OR ccp.Cod_TipoDoc = @Cod_TipoDocumento)
        GROUP BY pcp.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 vtd.Nom_TipoDoc, 
                 ccp.Doc_Cliente, 
                 ccp.Nom_Cliente
        ORDER BY Total_Vendidos DESC;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los clientes con mas ventas por cantidad
-- EXEC dbo.URP_RankingClienteXUtilidadVendidos @Top = 10, @Cod_TipoDocumento = '6', @Cod_Almacen = 'A101', @Cod_UnidadMedida = 'NIU', @Cod_Marca = 'M000136', @Cod_Categoria = 'AA', @Cod_Sucursal = '0001', @Cod_Caja = '100', @Cod_TipoComprobante = 'FE', @Cod_Moneda = 'PEN', @Id_Cliente = NULL, @Cod_Turno = NULL, @Fecha_Inicio = NULL, @Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingClienteXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingClienteXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingClienteXUtilidadVendidos @Top                 INT         = 10, 
                                                     @Cod_TipoDocumento   VARCHAR(3)  = NULL, 
                                                     @Cod_Almacen         VARCHAR(32) = NULL, 
                                                     @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                     @Cod_Marca           VARCHAR(32) = NULL, 
                                                     @Cod_Categoria       VARCHAR(32) = NULL, 
                                                     @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                     @Cod_Caja            VARCHAR(32) = NULL, 
                                                     @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                     @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                     @Id_Cliente          INT         = NULL, 
                                                     @Cod_Turno           VARCHAR(32) = NULL, 
                                                     @Fecha_Inicio        DATETIME    = NULL, 
                                                     @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Por caja
        SELECT TOP (@Top) pcp.Id_ClienteProveedor, 
                          pcp.Cod_TipoDocumento, 
                          vtd.Nom_TipoDoc, 
                          ccp.Doc_Cliente, 
                          ccp.Nom_Cliente, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.VIS_MARCA vm
             INNER JOIN dbo.PRI_PRODUCTOS pp ON vm.Cod_Marca = pp.Cod_Marca
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND pp.Flag_Activo = 1
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
             AND (@Cod_TipoDocumento IS NULL
                  OR ccp.Cod_TipoDoc = @Cod_TipoDocumento)
        GROUP BY pcp.Id_ClienteProveedor, 
                 pcp.Cod_TipoDocumento, 
                 vtd.Nom_TipoDoc, 
                 ccp.Doc_Cliente, 
                 ccp.Nom_Cliente
        ORDER BY Utilidad_Neta DESC;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los vendedores con mas ventas por cantidad
-- EXEC dbo.URP_RankingVendedorXCantidadVendidos@Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingVendedorXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingVendedorXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingVendedorXCantidadVendidos @Top                 INT         = 10, 
                                                      @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                      @Cod_Caja            VARCHAR(32) = NULL, 
                                                      @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                      @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                      @Cod_Categoria       VARCHAR(32) = NULL, 
                                                      @Id_Cliente          INT         = NULL, 
                                                      @Cod_Turno           VARCHAR(32) = NULL, 
                                                      @Fecha_Inicio        DATETIME    = NULL, 
                                                      @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) ccp.Cod_UsuarioVendedor, 
                          pu.Nick, 
                          pp2.Des_Perfil, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_USUARIO pu ON ccp.Cod_UsuarioVendedor = pu.Cod_Usuarios
             INNER JOIN dbo.PRI_PERFIL pp2 ON pu.Cod_Perfil = pp2.Cod_Perfil
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY ccp.Cod_UsuarioVendedor, 
                 pu.Nick, 
                 pp2.Des_Perfil
        ORDER BY Total_Vendidos DESC;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los vendedores con mas ventas por utilidad
-- EXEC dbo.URP_RankingVendedorXUtilidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL,@Fecha_Inicio = NULL,@Fecha_Final = NULL;
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingVendedorXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingVendedorXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingVendedorXUtilidadVendidos @Top                 INT         = 10, 
                                                      @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                      @Cod_Caja            VARCHAR(32) = NULL, 
                                                      @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                      @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                      @Cod_Categoria       VARCHAR(32) = NULL, 
                                                      @Id_Cliente          INT         = NULL, 
                                                      @Cod_Turno           VARCHAR(32) = NULL, 
                                                      @Fecha_Inicio        DATETIME    = NULL, 
                                                      @Fecha_Final         DATETIME    = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) ccp.Cod_UsuarioVendedor, 
                          pu.Nick, 
                          pp2.Des_Perfil, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_USUARIO pu ON ccp.Cod_UsuarioVendedor = pu.Cod_Usuarios
             INNER JOIN dbo.PRI_PERFIL pp2 ON pu.Cod_Perfil = pp2.Cod_Perfil
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
        GROUP BY ccp.Cod_UsuarioVendedor, 
                 pu.Nick, 
                 pp2.Des_Perfil
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los dias con mas ventas por cantidad
-- EXEC dbo.URP_RankingDiaXCantidadVendidos @Top = 10,@Mes = 3,@Anio = 2019,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingDiaXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingDiaXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingDiaXCantidadVendidos @Top                 INT         = 10, 
                                                 @Mes                 INT, 
                                                 @Anio                INT, 
                                                 @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                 @Cod_Caja            VARCHAR(32) = NULL, 
                                                 @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                 @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                 @Cod_Categoria       VARCHAR(32) = NULL, 
                                                 @Id_Cliente          INT         = NULL, 
                                                 @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) DAY(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) Dia, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND MONTH(ccp.FechaEmision) = @Mes
             AND YEAR(ccp.FechaEmision) = @Anio
        GROUP BY DAY(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Total_Vendidos DESC;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los dias con mas ventas por utilidad
-- EXEC dbo.URP_RankingDiaXUtilidadVendidos @Top = 10,@Mes = 3,@Anio = 2019,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingDiaXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingDiaXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingDiaXUtilidadVendidos @Top                 INT         = 10, 
                                                 @Mes                 INT, 
                                                 @Anio                INT, 
                                                 @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                 @Cod_Caja            VARCHAR(32) = NULL, 
                                                 @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                 @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                 @Cod_Categoria       VARCHAR(32) = NULL, 
                                                 @Id_Cliente          INT         = NULL, 
                                                 @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) DAY(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) Dia, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND MONTH(ccp.FechaEmision) = @Mes
             AND YEAR(ccp.FechaEmision) = @Anio
        GROUP BY DAY(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los meses con mas ventas por Cantidad
-- EXEC dbo.URP_RankingMesXCantidadVendidos @Top = 10,@Anio = 2019,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingMesXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingMesXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingMesXCantidadVendidos @Top                 INT         = 10, 
                                                 @Anio                INT, 
                                                 @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                 @Cod_Caja            VARCHAR(32) = NULL, 
                                                 @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                 @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                 @Cod_Categoria       VARCHAR(32) = NULL, 
                                                 @Id_Cliente          INT         = NULL, 
                                                 @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) MONTH(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) MES, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND YEAR(ccp.FechaEmision) = @Anio
        GROUP BY MONTH(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los meses con mas ventas por Utilidad
-- EXEC dbo.URP_RankingMesXUtilidadVendidos @Top = 10,@Anio = 2019,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingMesXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingMesXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingMesXUtilidadVendidos @Top                 INT         = 10, 
                                                 @Anio                INT, 
                                                 @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                 @Cod_Caja            VARCHAR(32) = NULL, 
                                                 @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                 @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                 @Cod_Categoria       VARCHAR(32) = NULL, 
                                                 @Id_Cliente          INT         = NULL, 
                                                 @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) MONTH(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) Dia, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND YEAR(ccp.FechaEmision) = @Anio
        GROUP BY MONTH(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Utilidad_Neta DESC;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los meses con mas ventas por cantidad
-- EXEC dbo.URP_RankingAnioXCantidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingAnioXCantidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingAnioXCantidadVendidos;
GO
CREATE PROCEDURE URP_RankingAnioXCantidadVendidos @Top                 INT         = 10, 
                                                  @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                  @Cod_Caja            VARCHAR(32) = NULL, 
                                                  @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                  @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                  @Cod_Categoria       VARCHAR(32) = NULL, 
                                                  @Id_Cliente          INT         = NULL, 
                                                  @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT TOP (@Top) YEAR(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) ANIO, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
        GROUP BY YEAR(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Total_Vendidos DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el ranking de los meses con mas ventas por utilidad
-- EXEC dbo.URP_RankingAnioXUtilidadVendidos @Top = 10,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_RankingAnioXUtilidadVendidos'
          AND type = 'P'
)
    DROP PROCEDURE URP_RankingAnioXUtilidadVendidos;
GO
CREATE PROCEDURE URP_RankingAnioXUtilidadVendidos @Top                 INT         = 10, 
                                                  @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                  @Cod_Caja            VARCHAR(32) = NULL, 
                                                  @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                  @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                  @Cod_Categoria       VARCHAR(32) = NULL, 
                                                  @Id_Cliente          INT         = NULL, 
                                                  @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Vendedor
        SELECT TOP (@Top) YEAR(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision))) Dia, 
                          SUM(ccd.Cantidad) Total_Vendidos, 
                          SUM(ccd.Cantidad * dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, ccp.Cod_Moneda, ccd.PrecioUnitario)) - SUM(ccd.Cantidad * (dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Compra) + dbo.UFN_CAJ_TIPOCAMBIOxFechaMoneda(ccp.FechaEmision, pps.Cod_Moneda, pps.Precio_Venta))) Utilidad_Neta
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_DOCUMENTOS vtd ON ccp.Cod_TipoDoc = vtd.Cod_TipoDoc
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON ccd.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
        GROUP BY YEAR(CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)))
        ORDER BY Utilidad_Neta DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener el los productos sin ventas en base a un minimo de ventas
-- EXEC dbo.URP_PRODUCTOS_ConStockSinVentasXFechaNroVentasMinimo @Top = 10,@Minimo = 1,@Fecha_Inicio = NULL,@Fecha_Final = NULL,@Cod_Almacen = 'A101',@Cod_UnidadMedida = 'NIU',@Cod_Marca = 'M000136',@Cod_Categoria = 'AA',@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_PRODUCTOS_ConStockSinVentasXFechaNroVentasMinimo'
          AND type = 'P'
)
    DROP PROCEDURE URP_PRODUCTOS_ConStockSinVentasXFechaNroVentasMinimo;
GO
CREATE PROCEDURE URP_PRODUCTOS_ConStockSinVentasXFechaNroVentasMinimo @Top                 INT         = 100, 
                                                                      @Minimo              INT         = 0, 
                                                                      @Fecha_Inicio        DATETIME    = NULL, 
                                                                      @Fecha_Final         DATETIME    = NULL, 
                                                                      @Cod_Almacen         VARCHAR(32) = NULL, 
                                                                      @Cod_UnidadMedida    VARCHAR(5)  = NULL, 
                                                                      @Cod_Marca           VARCHAR(32) = NULL, 
                                                                      @Cod_Categoria       VARCHAR(32) = NULL, 
                                                                      @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                                      @Cod_Caja            VARCHAR(32) = NULL, 
                                                                      @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                                      @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                                      @Id_Cliente          INT         = NULL, 
                                                                      @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --PRODUCTOS MAS VENDIDOS
        SELECT TOP (@Top) pp.Id_Producto, 
                          pp.Cod_Producto, 
                          pp.Cod_Categoria, 
                          pp.Cod_Marca, 
                          pp.Nom_Producto, 
                          SUM(ccd.Cantidad) Total_Vendidos
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
             INNER JOIN dbo.PRI_SUCURSAL ps ON cc.Cod_Sucursal = ps.Cod_Sucursal
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
                                                      AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
                                                      AND ccd.Cod_Almacen = pps.Cod_Almacen
        WHERE ccp.Cod_Libro = '14'
              AND ((@Cod_TipoComprobante IS NULL
                    AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
        OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
             AND ccp.Flag_Anulado = 0
             AND pp.Flag_Activo = 1
             AND (@Cod_Sucursal IS NULL
                  OR cc.Cod_Sucursal = @Cod_Sucursal)
             AND (@Cod_Caja IS NULL
                  OR ccp.Cod_Caja = @Cod_Caja)
             AND (@Cod_Moneda IS NULL
                  OR ccp.Cod_Moneda = @Cod_Moneda)
             AND (@Cod_Categoria IS NULL
                  OR pp.Cod_Categoria = @Cod_Categoria)
             AND (@Id_Cliente IS NULL
                  OR ccp.Id_Cliente = @Id_Cliente)
             AND (@Cod_Turno IS NULL
                  OR ccp.Cod_Turno = @Cod_Turno)
             AND ((@Fecha_Inicio IS NULL
                   AND @Fecha_Final IS NULL)
                  OR (ccp.FechaEmision >= CONVERT(DATETIME, CONVERT(DATE, @Fecha_Inicio))
                      AND ccp.FechaEmision < DATEADD(dd, 1, CONVERT(DATETIME, CONVERT(DATE, @Fecha_Final)))))
             AND (@Cod_Almacen IS NULL
                  OR ccd.Cod_Almacen = @Cod_Almacen)
             AND (@Cod_UnidadMedida IS NULL
                  OR ccd.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (@Cod_Marca IS NULL
                  OR pp.Cod_Marca = @Cod_Marca)
             AND pp.Flag_Stock = 1
             AND pps.Stock_Act > 0
        GROUP BY pp.Id_Producto, 
                 pp.Cod_Producto, 
                 pp.Cod_Categoria, 
                 pp.Cod_Marca, 
                 pp.Nom_Producto
        HAVING SUM(ccd.Cantidad) <= @Minimo
        ORDER BY Total_Vendidos ASC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 16/04/2019
-- OBJETIVO: Permite obtener la variacion de precios de venta de productos en un mes de 31 dias
-- EXEC dbo.URP_CAJ_COMROBANTE_PAGO_VariacionPrecio @Anio = 2019,@Mes = 3,@Cod_Sucursal = '0001',@Cod_Caja = '100',@Cod_TipoComprobante = 'FE',@Cod_Moneda = 'PEN',@Cod_Categoria = 'AA',@Id_Cliente = NULL,@Cod_Turno = NULL
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'URP_CAJ_COMROBANTE_PAGO_VariacionPrecio'
          AND type = 'P'
)
    DROP PROCEDURE URP_CAJ_COMROBANTE_PAGO_VariacionPrecio;
GO
CREATE PROCEDURE URP_CAJ_COMROBANTE_PAGO_VariacionPrecio @Anio                INT, 
                                                         @Mes                 INT, 
                                                         @Cod_Sucursal        VARCHAR(32) = NULL, 
                                                         @Cod_Caja            VARCHAR(32) = NULL, 
                                                         @Cod_TipoComprobante VARCHAR(5)  = NULL, 
                                                         @Cod_Moneda          VARCHAR(5)  = NULL, 
                                                         @Cod_Categoria       VARCHAR(32) = NULL, 
                                                         @Id_Cliente          INT         = NULL, 
                                                         @Cod_Turno           VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT YMD;
        DECLARE @NumeroDias VARCHAR(2)=
        (
            SELECT DAY(EOMONTH(CONCAT(@Anio, '-', @Mes, '-01')))
        );
        DECLARE @dt1 DATETIME= CONCAT(@Anio, '-', @Mes, '-01');
        DECLARE @dt2 DATETIME= CONCAT(@Anio, '-', @Mes, '-', @NumeroDias);
        IF OBJECT_ID('tempdb..#tempTablaResultadoDias') IS NOT NULL
            BEGIN
                DROP TABLE dbo.#tempTablaResultadoDias;
        END;
        WITH ListaDias
             AS (SELECT rn = ROW_NUMBER() OVER(
                        ORDER BY
                 (
                     SELECT NULL
                 ))
                 FROM sys.objects a
                      CROSS JOIN sys.objects b
                      CROSS JOIN sys.objects c
                      CROSS JOIN sys.objects d)
             SELECT DISTINCT 
                    PV_Table.*
             INTO #tempTablaResultadoDias
             FROM
             (
                 SELECT CONCAT('DIA_', Res.Dia) Dia, 
                        Res.Id_Producto, 
                        Res.Cod_Producto, 
                        Res.Nom_Producto, 
                        Res.Precio
                 FROM
                 (
                     SELECT ld.rn Dia, 
                            pp.Id_Producto, 
                            pp.Cod_Producto, 
                            pp.Nom_Producto, 
                            AVG(ISNULL(ct.SunatVenta, 1) * ccd.PrecioUnitario) Precio
                     FROM ListaDias ld, 
                          dbo.PRI_PRODUCTOS pp
                          INNER JOIN CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto
                          INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
                          INNER JOIN dbo.CAJ_CAJAS cc ON ccp.Cod_Caja = cc.Cod_Caja
                          LEFT JOIN dbo.CAJ_TIPOCAMBIO ct ON CONVERT(DATETIME, CONVERT(DATE, ccp.FechaEmision)) = ct.FechaHora
                                                             AND ccp.Cod_Moneda = ct.Cod_Moneda
                     WHERE ld.rn <= DATEDIFF(dd, @dt1, @dt2)
                           AND DAY(ccp.FechaEmision) = ld.rn
                           AND ccp.Cod_Libro = '14'
                           AND YEAR(ccp.FechaEmision) = @Anio
                           AND MONTH(ccp.FechaEmision) = @Mes
                           AND (@Cod_Sucursal IS NULL
                                OR cc.Cod_Sucursal = @Cod_Sucursal)
                           AND (@Cod_Caja IS NULL
                                OR ccp.Cod_Caja = @Cod_Caja)
                           AND ((@Cod_TipoComprobante IS NULL
                                 AND ccp.Cod_TipoComprobante IN('FE', 'BE', 'TKB', 'TKF', 'BO', 'FA'))
                     OR ccp.Cod_TipoComprobante = @Cod_TipoComprobante)
                          AND (@Cod_Moneda IS NULL
                               OR ccp.Cod_Moneda = @Cod_Moneda)
                          AND (@Cod_Categoria IS NULL
                               OR pp.Cod_Categoria = @Cod_Categoria)
                          AND (@Id_Cliente IS NULL
                               OR ccp.Id_Cliente = @Id_Cliente)
                          AND (@Cod_Turno IS NULL
                               OR ccp.Cod_Turno = @Cod_Turno)
                     GROUP BY ld.rn, 
                              pp.Id_Producto, 
                              pp.Cod_Producto, 
                              pp.Nom_Producto
                 ) Res
             ) T PIVOT(AVG(T.Precio) FOR T.Dia IN(DIA_1, 
                                                  DIA_2, 
                                                  DIA_3, 
                                                  DIA_4, 
                                                  DIA_5, 
                                                  DIA_6, 
                                                  DIA_7, 
                                                  DIA_8, 
                                                  DIA_9, 
                                                  DIA_10, 
                                                  DIA_11, 
                                                  DIA_12, 
                                                  DIA_13, 
                                                  DIA_14, 
                                                  DIA_15, 
                                                  DIA_16, 
                                                  DIA_17, 
                                                  DIA_18, 
                                                  DIA_19, 
                                                  DIA_20, 
                                                  DIA_21, 
                                                  DIA_22, 
                                                  DIA_23, 
                                                  DIA_24, 
                                                  DIA_25, 
                                                  DIA_26, 
                                                  DIA_27, 
                                                  DIA_28, 
                                                  DIA_29, 
                                                  DIA_30, 
                                                  DIA_31)) AS PV_Table;
        DECLARE @Valor_Anterior NUMERIC(38, 6);
        UPDATE #tempTablaResultadoDias
          SET 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_1 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_1 IS NULL
                                                                    THEN 0.000000
                                                                    ELSE #tempTablaResultadoDias.DIA_1
                                                                END, -- unknown type

              @Valor_Anterior = #tempTablaResultadoDias.DIA_2 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_2 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_2 --Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_3 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_3 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_3--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_4 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_4 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_4--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_5 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_5 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_5--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_6 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_6 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_6--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_7 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_7 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_7--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_8 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_8 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_8--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_9 = CASE
                                                                    WHEN #tempTablaResultadoDias.DIA_9 IS NULL --Miramos el anterior
                                                                    THEN @Valor_Anterior
                                                                    ELSE #tempTablaResultadoDias.DIA_9--Toma su mismo valor
                                                                END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_10 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_10 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_10--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_11 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_11 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_11--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_12 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_12 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_12--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_13 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_13 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_13--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_14 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_14 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_14--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_15 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_15 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_15--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_16 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_16 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_16--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_17 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_17 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_17--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_18 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_18 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_18--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_19 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_19 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_19--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_20 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_20 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_20--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_21 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_21 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_21--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_22 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_22 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_22--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_23 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_23 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_23--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_24 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_24 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_24--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_25 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_25 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_25--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_26 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_26 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_26--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_27 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_27 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_27--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_28 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_28 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_28--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_29 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_29 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_29--Toma su mismo valor
                                                                 END, 
              @Valor_Anterior = #tempTablaResultadoDias.DIA_30 = CASE
                                                                     WHEN #tempTablaResultadoDias.DIA_30 IS NULL --Miramos el anterior
                                                                     THEN @Valor_Anterior
                                                                     ELSE #tempTablaResultadoDias.DIA_30--Toma su mismo valor
                                                                 END, 
              #tempTablaResultadoDias.DIA_31 = CASE
                                                   WHEN #tempTablaResultadoDias.DIA_31 IS NULL --Miramos el anterior
                                                   THEN @Valor_Anterior
                                                   ELSE #tempTablaResultadoDias.DIA_31--Toma su mismo valor
                                               END;
        SELECT Res.*
        FROM #tempTablaResultadoDias Res;
        IF OBJECT_ID('tempdb..#tempTablaResultadoDias') IS NOT NULL
            BEGIN
                DROP TABLE dbo.#tempTablaResultadoDias;
        END;
    END;
GO