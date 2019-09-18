--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 12/12/2015
-- OBJETIVO: Buscar Cliente con IDCliente proveedor, cambiar para q traiga descuento una vez q el producto tenga su repectivo descuento
-- USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor '%',1
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                             @Buscar             VARCHAR(512), 
                                                             @IdClienteProveedor INT, 
                                                             @Cod_Categoria AS      VARCHAR(32)  = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT P.Id_Producto, 
               P.Des_LargaProducto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Cod_Almacen, 
               PS.Stock_Act, 
               PS.Precio_Venta AS Precio, 
               ISNULL(PP.Nom_TipoPrecio, 'NINGUNO') AS TipoDescuento,
               CASE PP.Cod_TipoPrecio
                   WHEN '01'
                   THEN 0
                   WHEN '02'
                   THEN ISNULL(CP.Monto, 0)
                   WHEN '03'
                   THEN PS.Precio_Venta - ISNULL(CP.Monto, 0)
                   WHEN '04'
                   THEN PS.Precio_Venta * ISNULL(CP.Monto, 0) / 100
                   ELSE 0
               END AS Descuento, 
               M.Nom_Moneda, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               A.Des_Almacen, 
               P.Flag_Stock, 
               P.Cod_TipoOperatividad, 
               M.Cod_Moneda, 
               PS.Precio_Compra
        FROM VIS_MONEDAS AS M
             INNER JOIN PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto ON M.Cod_Moneda = PS.Cod_Moneda
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
             LEFT OUTER JOIN VIS_TIPO_PRECIOS AS PP
             INNER JOIN PRI_CLIENTE_PRODUCTO AS CP ON PP.Cod_TipoPrecio = CP.Cod_TipoDescuento ON P.Id_Producto = CP.Id_Producto
        WHERE(CP.Id_ClienteProveedor = @IdClienteProveedor)
             OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
             AND (P.Flag_Activo = 1)
             OR (P.Flag_Activo = 1)
             AND (P.Cod_Producto LIKE @Buscar + '%')
             OR (P.Flag_Activo = 1)
             AND (PS.Cod_Almacen = @Buscar)
             AND (@Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (CA.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
        ORDER BY Cod_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 12/12/2015
-- OBJETIVO: Buscar Cliente con IDCliente proveedor, cambiar para q traiga descuento una vez q el producto tenga su repectivo descuento
-- USP_PRI_PRODUCTOS_Buscar '%',0
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                          @Buscar             VARCHAR(512), 
                                          @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                          @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                          @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                          @Flag_RequiereStock AS BIT          = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT P.Id_Producto, 
               P.Nom_Producto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda AS Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_CortaAlmacen AS Des_Almacen, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               P.Flag_Stock, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio, 
               P.Cod_TipoOperatividad, 
               M.Cod_Moneda, 
               Cod_TipoProducto
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
        WHERE(P.Cod_TipoProducto = @CodTipoProducto
              OR @CodTipoProducto IS NULL)
             AND ((P.Cod_Producto LIKE @Buscar + '%')
                  OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (ca.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (P.Flag_Activo = 1)
        --AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
        ORDER BY Nom_Producto;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_BuscarXAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXAlmacen @Buscar          VARCHAR(512), 
                                                  @CodTipoProducto AS VARCHAR(8)   = NULL, 
                                                  @Cod_Categoria AS   VARCHAR(32)  = NULL, 
                                                  @Cod_Almacen AS     VARCHAR(32)  = NULL, 
                                                  @Cod_Precio AS      VARCHAR(32)  = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT P.Id_Producto, 
               P.Des_LargaProducto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_Almacen, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
        WHERE(P.Cod_TipoProducto = @CodTipoProducto
              OR @CodTipoProducto IS NULL)
             AND ((P.Nom_Producto LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Producto LIKE @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE @Buscar + '%'))
             AND (p.Flag_Activo = 1)
             AND (PS.Cod_Almacen = @Cod_Almacen
                  OR @Cod_Almacen IS NULL)
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
        ORDER BY Cod_Producto;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TProductoAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TProductoAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TProductoAlmacen @Id_Producto INT, 
                                                          @Cod_Almacen AS VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT VP.Cod_Precio, 
               VP.Nom_Precio, 
               VP.Cod_PrecioPadre, 
               VP.Orden, 
               PP.Valor
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto
             INNER JOIN VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
                                             AND P.Cod_Categoria = VP.Cod_Categoria
        WHERE p.Id_Producto = @Id_Producto
              AND Cod_Almacen = @Cod_Almacen;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN RAYME
-- FECHA: 04/11/2016,28/11/2016
-- OBJETIVO: Recupera el codigo(s) de un producto(s), nombre(s) y  serie(s) en base a un codigo de almacen y los ultimos 6 digitos de la serie 
-- USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen 'A0006','356656075499987'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXSerieyCodAlmacen @Cod_Almacen AS VARCHAR(32), 
                                                           @Buscar      VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               Cod_Producto, 
               Nom_Producto, 
               Serie, 
               Id_Producto, 
               Cod_UnidadMedida, 
               Cod_TipoOperatividad
        FROM
        (
            SELECT P.Cod_Producto, 
                   P.Nom_Producto, 
                   S.Serie, 
                   P.Id_Producto, 
                   PP.Cod_UnidadMedida, 
                   P.Cod_TipoOperatividad
            FROM CAJ_SERIES AS S
                 INNER JOIN ALM_ALMACEN_MOV_D AS MD ON S.Item = MD.Item
                                                       AND S.Id_Tabla = MD.Id_AlmacenMov
                 INNER JOIN PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto
                 INNER JOIN ALM_ALMACEN_MOV AS M ON M.Id_AlmacenMov = MD.Id_AlmacenMov
                 INNER JOIN PRI_PRODUCTO_PRECIO AS PP ON PP.Id_Producto = P.Id_Producto
                                                         AND PP.Cod_Almacen = @Cod_Almacen
            WHERE(S.Cod_Tabla = 'ALM_ALMACEN_MOV')
                 AND M.Cod_Almacen = @Cod_Almacen
                 AND M.Cod_Turno IS NOT NULL
                 AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie, @Cod_Almacen) = 1
                 AND (S.Serie LIKE '%' + @Buscar)
            UNION
            SELECT P.Cod_Producto, 
                   P.Nom_Producto, 
                   S.Serie, 
                   P.Id_Producto, 
                   PP.Cod_UnidadMedida, 
                   P.Cod_TipoOperatividad
            FROM CAJ_SERIES AS S
                 INNER JOIN CAJ_COMPROBANTE_D AS MD ON S.Item = MD.id_Detalle
                                                       AND S.Id_Tabla = MD.id_ComprobantePago
                 INNER JOIN PRI_PRODUCTOS AS P ON MD.Id_Producto = P.Id_Producto
                 INNER JOIN PRI_PRODUCTO_PRECIO AS PP ON PP.Id_Producto = P.Id_Producto
                                                         AND PP.Cod_Almacen = @Cod_Almacen
            WHERE(S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
                 AND MD.Cod_Almacen = @Cod_Almacen
                 AND dbo.UFN_VIS_SERIES_StockAlmacen(S.Serie, @Cod_Almacen) = 1
                 AND (S.Serie LIKE '%' + @Buscar)
        ) AS S;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;ESTEFANI HUAMAN 
-- FECHA: 01/02/2018;28/02/2019
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_CAJ_COMPROBANTE_PAGO_TUltimaFechaXTipoSerie 'FE','F001'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TUltimaFechaXTipoSerie'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TUltimaFechaXTipoSerie;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TUltimaFechaXTipoSerie @Cod_TipoComprobante AS VARCHAR(32), 
                                                                 @Serie AS               VARCHAR(8)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        DECLARE @cont INT;
        SET @cont =
        (
            SELECT COUNT(*)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Cod_Libro = '14'
                  AND Cod_TipoComprobante = @Cod_TipoComprobante
                  AND Serie = @Serie
        );
        IF(@cont = 0)
            BEGIN
                SELECT DATEADD(DAY, -7, GETDATE());
        END;
            ELSE
            BEGIN
                SELECT TOP 1 CONVERT(DATETIME, CONVERT(VARCHAR, FechaEmision, 103))
                FROM CAJ_COMPROBANTE_PAGO
                WHERE Cod_Libro = '14'
                      AND Cod_TipoComprobante = @Cod_TipoComprobante
                      AND Serie = @Serie
                ORDER BY FechaEmision DESC;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 08/02/2018;
-- OBJETIVO: Procedimiento que permite listar el Tipo de IGV 
-- EXEC USP_TIPO_IGV_Listar
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_TIPO_IGV_Listar'
          AND type = 'P'
)
    DROP PROCEDURE USP_TIPO_IGV_Listar;
GO
CREATE PROCEDURE USP_TIPO_IGV_Listar
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_TipoOperatividad AS 'CODIGO', 
               Nom_TipoOperatividad AS 'TIPO IGV'
        FROM [dbo].[VIS_TIPO_OPERATIVIDAD];
    END;
GO
IF OBJECT_ID(N'dbo.RecuperarTipoCambioXDia', N'FN') IS NOT NULL
    DROP FUNCTION RecuperarTipoCambioXDia;  
GO  
CREATE FUNCTION dbo.RecuperarTipoCambioXDia
(@Fecha      DATETIME, 
 @TipoMoneda VARCHAR(3)
)
RETURNS FLOAT
AS   
     -- Returns the stock level for the product.  
     BEGIN
         DECLARE @TipoCambio FLOAT;
(
    SELECT TOP 1 @TipoCambio = SunatVenta
    FROM CAJ_TIPOCAMBIO
    WHERE CONVERT(DATETIME, CONVERT(VARCHAR(MAX), FechaHora, 103), 103) = CONVERT(DATETIME, CONVERT(VARCHAR(MAX), @Fecha, 103), 103)
          AND Cod_Moneda = @TipoMoneda
);
         --IF (@TipoCambio IS NULL)   
         --    SET @TipoCambio = 0;  
         RETURN @TipoCambio;
     END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_RecuperarTipoCambioXDia'
          AND type = 'P'
)
    DROP PROCEDURE USP_RecuperarTipoCambioXDia;
GO
CREATE PROCEDURE USP_RecuperarTipoCambioXDia
(@Fecha      DATETIME, 
 @TipoMoneda VARCHAR(3)
)
AS   
    -- Returns the stock level for the product.  
    BEGIN
        SET DATEFORMAT DMY;
        SELECT *
        FROM CAJ_TIPOCAMBIO
        WHERE CONVERT(DATETIME, CONVERT(VARCHAR(MAX), FechaHora, 103), 103) = CONVERT(DATETIME, CONVERT(VARCHAR(MAX), @Fecha, 103), 103)
              AND Cod_Moneda = @TipoMoneda;
        --IF (@TipoCambio IS NULL)   
        --    SET @TipoCambio = 0;  

    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_RESUMEN_DIARIO_G'
)
    DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_G;
GO
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_G @Fecha_Serie   VARCHAR(16), 
                                          @Numero        VARCHAR(8), 
                                          @Ticket        VARCHAR(64), 
                                          @Nom_Estado    VARCHAR(64), 
                                          @Fecha_Envio   VARCHAR(64), 
                                          @Total_Resumen NUMERIC(32, 2)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Nro AS INT;
        IF NOT EXISTS
        (
            SELECT Nro
            FROM VIS_RESUMEN_DIARIO
            WHERE(Fecha_Serie = @Fecha_Serie
                  AND Numero = @Numero)
        )
            BEGIN
                -- Calcular el ultimo el elemento ingresado para este tabla
                SET @Nro =
                (
                    SELECT ISNULL(MAX(Nro), 0) + 1
                    FROM VIS_RESUMEN_DIARIO
                );
                EXEC USP_PAR_FILA_G '115', '001', @Nro, @Fecha_Serie, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '002', @Nro, @Numero, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '003', @Nro, @Ticket, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '004', @Nro, @Nom_Estado, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '005', @Nro, @Fecha_Envio, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '006', @Nro, NULL, @Total_Resumen, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '007', @Nro, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
        END;
            ELSE
            BEGIN
                SET @Nro =
                (
                    SELECT Nro
                    FROM VIS_RESUMEN_DIARIO
                    WHERE(Fecha_Serie = @Fecha_Serie
                          AND Numero = @Numero)
                );
                EXEC USP_PAR_FILA_G '115', '001', @Nro, @Fecha_Serie, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '002', @Nro, @Numero, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '003', @Nro, @Ticket, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '004', @Nro, @Nom_Estado, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '005', @Nro, @Fecha_Envio, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '006', @Nro, NULL, @Total_Resumen, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '115', '007', @Nro, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
        END;
    END;
GO
-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_RESUMEN_DIARIO_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_E;
GO
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_E @Fecha_Serie VARCHAR(16), 
                                          @Numero      VARCHAR(8)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Nro INT;
        SET @Nro =
        (
            SELECT Nro
            FROM VIS_RESUMEN_DIARIO
            WHERE(Fecha_Serie = @Fecha_Serie
                  AND Numero = @Numero)
        );
        EXEC USP_PAR_FILA_E '115', '001', @Nro;
        EXEC USP_PAR_FILA_E '115', '002', @Nro;
        EXEC USP_PAR_FILA_E '115', '003', @Nro;
        EXEC USP_PAR_FILA_E '115', '004', @Nro;
        EXEC USP_PAR_FILA_E '115', '005', @Nro;
        EXEC USP_PAR_FILA_E '115', '006', @Nro;
        EXEC USP_PAR_FILA_E '115', '007', @Nro;
    END;
GO
-- Traer datos del recumen diario
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_RESUMEN_DIARIO_TXFechaSerieNumero'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_TXFechaSerieNumero;
GO
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_TXFechaSerieNumero @Fecha_Serie VARCHAR(16), 
                                                           @Numero      VARCHAR(8)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Nro, 
               Fecha_Serie, 
               Numero, 
               Ticket, 
               Nom_Estado, 
               Fecha_Envio, 
               Total_Resumen, 
               Estado
        FROM VIS_RESUMEN_DIARIO
        WHERE(Fecha_Serie = @Fecha_Serie
              AND Numero = @Numero);
    END;
GO
--METODO QUE DA DE BAJA UN COMPROBANTE POR ID
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_DarBaja'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja @id_ComprobantePago INT, 
                                                  @CodUsuario         VARCHAR(32), 
                                                  @Justificacion      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Id_Producto INT, @Signo INT, @Cod_Almacen VARCHAR(32), @Cod_UnidadMedida VARCHAR(5), @Despachado NUMERIC(38, 6), @Documento VARCHAR(128), @Proveedor VARCHAR(1024), @Detalle VARCHAR(MAX), @FechaEmision DATETIME, @FechaActual DATETIME, @id_Fila INT;
        SET @FechaActual = GETDATE();
        SELECT @Documento = Cod_Libro + '-' + Cod_TipoComprobante + ':' + Serie + '-' + Numero, 
               @Proveedor = Cod_TipoDoc + ':' + Doc_Cliente + '-' + Nom_Cliente, 
               @FechaEmision = FechaEmision
        FROM CAJ_COMPROBANTE_PAGO
        WHERE id_ComprobantePago = @id_ComprobantePago;

        -- RECUPERAR LOS DETALLES
        SET @Detalle = STUFF(
        (
            SELECT DISTINCT 
                   ' ; ' + CONVERT(VARCHAR, D.Id_Producto) + '|' + d.Descripcion + '|' + CONVERT(VARCHAR, d.Cantidad)
            FROM CAJ_COMPROBANTE_D D
            WHERE D.id_ComprobantePago = @id_ComprobantePago FOR XML PATH('')
        ), 1, 2, '') + '';
        SET @Signo =
        (
            SELECT CASE Cod_Libro
                       WHEN '08'
                       THEN-1
                       WHEN '14'
                       THEN 1
                       ELSE 0
                   END
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @id_ComprobantePago
        );
        DECLARE ComprobanteD CURSOR
        FOR SELECT Id_Producto, 
                   Cod_UnidadMedida, 
                   Cod_Almacen, 
                   Despachado
            FROM CAJ_COMPROBANTE_D
            WHERE id_ComprobantePago = @id_ComprobantePago
                  AND Id_Producto <> 0;
        OPEN ComprobanteD;
        FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE PRI_PRODUCTO_STOCK
                  SET 
                      Stock_Act = Stock_Act + @Signo * @Despachado
                WHERE Id_Producto = @Id_Producto
                      AND Cod_UnidadMedida = @Cod_UnidadMedida
                      AND Cod_Almacen = @Cod_Almacen;
                FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
            END;
        CLOSE ComprobanteD;
        DEALLOCATE ComprobanteD;

        --Actualizamos la informacion en comprobante pago
        UPDATE dbo.CAJ_COMPROBANTE_PAGO
          SET 
              dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado = 1, 
              dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante = 'REC', 
              dbo.CAJ_COMPROBANTE_PAGO.Impuesto = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.MotivoAnulacion = @Justificacion
        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de los detalles
        UPDATE dbo.CAJ_COMPROBANTE_D
          SET 
              dbo.CAJ_COMPROBANTE_D.Cantidad = 0, 
              dbo.CAJ_COMPROBANTE_D.Despachado = 0, 
              dbo.CAJ_COMPROBANTE_D.Formalizado = 0, 
              dbo.CAJ_COMPROBANTE_D.Descuento = 0, 
              dbo.CAJ_COMPROBANTE_D.Sub_Total = 0, 
              dbo.CAJ_COMPROBANTE_D.IGV = 0, 
              dbo.CAJ_COMPROBANTE_D.ISC = 0
        WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de la forma de pago
        UPDATE dbo.CAJ_FORMA_PAGO
          SET 
              dbo.CAJ_FORMA_PAGO.Monto = 0
        WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Eliminamos todas las relaciones
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(Id_ComprobanteRelacion = @id_ComprobantePago);
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        --Eliminamos las licitaciones
        DELETE FROM PRI_LICITACIONES_M
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        -- Eliminar las Serie que se colocaron
        DELETE FROM CAJ_SERIES
        WHERE(Id_Tabla = @id_ComprobantePago
              AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO');

        -- insertar elementos en un datos a ver que pasa
        SET @id_Fila =
        (
            SELECT ISNULL(COUNT(*) / 9, 1) + 1
            FROM PAR_FILA
            WHERE Cod_Tabla = '079'
        );
        EXEC USP_PAR_FILA_G '079', '001', @id_Fila, @Documento, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '002', @id_Fila, 'CAJ_COMPROBANTE_PAGO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '003', @id_Fila, @Proveedor, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '004', @id_Fila, @Detalle, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '005', @id_Fila, NULL, NULL, NULL, @FechaEmision, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '006', @id_Fila, NULL, NULL, NULL, @FechaActual, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '007', @id_Fila, @CodUsuario, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '008', @id_Fila, @Justificacion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '009', @id_Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
    END;
GO
-- Traer Todo USP_CAJ_COMPROBANTE_PAGO_TDetalleXIdComprobantePago 8
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerDetalesXIdComprobantePago_ResumenDiario'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerDetalesXIdComprobantePago_ResumenDiario;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerDetalesXIdComprobantePago_ResumenDiario @id_ComprobantePago AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT *
        FROM CAJ_COMPROBANTE_D
        WHERE id_ComprobantePago = @id_ComprobantePago;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerFacturasNotasRetroceso'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasNotasRetroceso;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasNotasRetroceso @PrimeraFechaRetroceso DATETIME, 
                                                                      @SegundaFechaRetroceso DATETIME, 
                                                                      @NroDocumentoCliente   VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               SerieNumero, 
               Cod_EstadoComprobante, 
               Cod_TipoDoc, 
               Doc_Cliente, 
               Flag_Anulado, 
               FechaEmision
        FROM
        (
            SELECT ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_EstadoComprobante, 
                   ccp.Cod_TipoDoc, 
                   ccp.Doc_Cliente, 
                   ccp.Flag_Anulado, 
                   ccp.FechaEmision, 
                   ROW_NUMBER() OVER(
                   ORDER BY ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE(@NroDocumentoCliente <> ''
                  AND ccp.Doc_Cliente = @NroDocumentoCliente
                  AND ccp.Cod_TipoComprobante IN('FE', 'NCE', 'NDE')
            AND ccp.Serie LIKE 'F%'
            AND ccp.Cod_Libro = 14
            --AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) between CONVERT(DATETIME, CONVERT(VARCHAR, @PrimeraFechaRetroceso, 103)) and CONVERT(DATETIME, CONVERT(VARCHAR, @SegundaFechaRetroceso, 103))) 
            AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) >= CONVERT(DATETIME, CONVERT(VARCHAR, @PrimeraFechaRetroceso, 103)))
            AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) < CONVERT(DATETIME, CONVERT(VARCHAR, @SegundaFechaRetroceso, 103))))
            OR (@NroDocumentoCliente = ''
                AND ccp.Cod_TipoComprobante IN('FE', 'NCE', 'NDE')
            AND ccp.Serie LIKE 'F%'
            AND ccp.Cod_Libro = 14
            --AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) between CONVERT(DATETIME, CONVERT(VARCHAR, @PrimeraFechaRetroceso, 103)) and CONVERT(DATETIME, CONVERT(VARCHAR, @SegundaFechaRetroceso, 103))) 
            AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) >= CONVERT(DATETIME, CONVERT(VARCHAR, @PrimeraFechaRetroceso, 103)))
            AND (CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) < CONVERT(DATETIME, CONVERT(VARCHAR, @SegundaFechaRetroceso, 103))))
            GROUP BY ccp.id_ComprobantePago, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Flag_Anulado, 
                     ccp.FechaEmision, 
                     ccp.Cod_EstadoComprobante
        ) aResumenDiarioDetallado
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraBoleta'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraBoleta;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraBoleta
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 FechaEmision
        FROM CAJ_COMPROBANTE_PAGO
        WHERE Cod_Libro = '14'
              AND Cod_TipoComprobante IN('BE', 'NCE', 'NDE')
        AND Serie LIKE 'B%'
        ORDER BY FechaEmision;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraFactura'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraFactura;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerPrimeraFactura
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 FechaEmision
        FROM CAJ_COMPROBANTE_PAGO
        WHERE Cod_Libro = '14'
              AND Cod_TipoComprobante IN('FE', 'NCE', 'NDE')
        AND Serie LIKE 'F%'
        ORDER BY FechaEmision;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_RELACION_TAnticipoXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TAnticipoXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TAnticipoXIdComprobante @id_ComprobantePago AS INT
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT DISTINCT 
               VTC.Cod_Sunat AS Cod_TipoComprobante, 
               CPR.Serie + '-' + CPR.Numero AS Comprobante, 
               CR.Valor AS MontoAnticipo, 
               CPR.Cod_Moneda AS MonedaAnticipo, 
               CPR.FechaEmision AS FechaEmisionAnticipo
        FROM CAJ_COMPROBANTE_RELACION AS CR
             INNER JOIN CAJ_COMPROBANTE_PAGO AS CPR ON CR.id_ComprobantePago = CPR.id_ComprobantePago
             INNER JOIN VIS_TIPO_COMPROBANTES AS VTC ON CPR.Cod_TipoComprobante = VTC.Cod_TipoComprobante
        WHERE cr.Cod_TipoRelacion IN('ANT')
             AND cr.id_ComprobanteRelacion = @id_ComprobantePago;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_RESUMENDIARIO_NUEVO'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_RESUMENDIARIO_NUEVO;
GO
CREATE PROCEDURE USP_VIS_RESUMENDIARIO_NUEVO
WITH ENCRYPTION
AS
    BEGIN
        SELECT *
        FROM VIS_RESUMEN_DIARIO;
    END;
GO
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas @Fecha DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT COUNT(*) Totales
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        WHERE ccp.Cod_TipoComprobante IN('BE')
        AND ccp.Serie LIKE 'B%'
        AND ccp.Cod_Libro = 14
        AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103));
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas_Personalizado'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas_Personalizado;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_Boletas_Personalizado @Fecha DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT COUNT(*) Totales
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        WHERE ccp.Cod_TipoComprobante IN('BE')
        AND ccp.Serie LIKE 'B%'
        AND ccp.Cod_Libro = 14
        AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103));
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_BoletasContingencia'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_BoletasContingencia;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_BoletasContingencia @Fecha DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT COUNT(*) Totales
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        WHERE ccp.Cod_TipoComprobante IN('BC')
        AND ccp.Cod_Libro = 14
        AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103));
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas @Fecha DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT COUNT(*) Totales
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
        AND ccp.Serie LIKE 'B%'
        AND ccp.Cod_Libro = 14
        AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103));
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas_Personalizado'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas_Personalizado;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ContarItems_ResumenDiario_NotasDeBoletas_Personalizado @Fecha DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT COUNT(*) Totales
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
        AND ccp.Serie LIKE 'B%'
        AND ccp.Cod_Libro = 14
        AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103));
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas @FechaResumen DATETIME, 
                                                                           @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT vtc2.Cod_Sunat
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc2 ON ccp2.Cod_TipoComprobante = vtc2.Cod_TipoComprobante
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END TipoDocumentoAfectado,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT ccp2.Serie + '-' + ccp2.Numero
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                       ORDER BY ccp.Cod_TipoComprobante, 
                                ccp.Serie, 
                                ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('BE')
                 AND ccp.Serie LIKE 'B%'
                 AND ccp.Cod_Libro = 14
                 AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas_Personalizado'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas_Personalizado;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_Boletas_Personalizado @FechaResumen DATETIME, 
                                                                                         @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT vtc2.Cod_Sunat
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc2 ON ccp2.Cod_TipoComprobante = vtc2.Cod_TipoComprobante
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END TipoDocumentoAfectado,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT ccp2.Serie + '-' + ccp2.Numero
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                       ORDER BY ccp.Cod_TipoComprobante, 
                                ccp.Serie, 
                                ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('BE')
                 AND ccp.Serie LIKE 'B%'
                 AND ccp.Cod_Libro = 14
                 AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_BoletasContingencia'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_BoletasContingencia;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_BoletasContingencia @FechaResumen DATETIME, 
                                                                                       @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente, 
                   '' TipoDocumentoAfectado, 
                   '' SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                   ORDER BY ccp.Cod_TipoComprobante, 
                            ccp.Serie, 
                            ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('BC')
                 AND ccp.Cod_Libro = 14
                 AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas @FechaResumen DATETIME, 
                                                                                  @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT vtc2.Cod_Sunat
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc2 ON ccp2.Cod_TipoComprobante = vtc2.Cod_TipoComprobante
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END TipoDocumentoAfectado,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT ccp2.Serie + '-' + ccp2.Numero
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                       ORDER BY ccp.Cod_TipoComprobante, 
                                ccp.Serie, 
                                ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
                 AND ccp.Serie LIKE 'B%'
                 AND ccp.Cod_Libro = 14
                 AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
	GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas_Personalizado'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas_Personalizado;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletas_Personalizado @FechaResumen DATETIME, 
                                                                                                @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT vtc2.Cod_Sunat
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc2 ON ccp2.Cod_TipoComprobante = vtc2.Cod_TipoComprobante
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END TipoDocumentoAfectado,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BE'
                       THEN ''
                       ELSE
            (
                SELECT ccp2.Serie + '-' + ccp2.Numero
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                       ORDER BY ccp.Cod_TipoComprobante, 
                                ccp.Serie, 
                                ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
                 AND ccp.Serie LIKE 'B%'
                 AND ccp.Cod_Libro = 14
                 AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletasContingencia'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletasContingencia;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerItems_ResumenDiario_NotasDeBoletasContingencia @FechaResumen DATETIME, 
                                                                                              @NumeroPagina VARCHAR(16)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT NumeroFila, 
               id_ComprobantePago, 
               Cod_TipoComprobante, 
               Descuento_Total, 
               Cod_Moneda, 
               tipocambio, 
               Cod_Sunat, 
               SerieNumero, 
               Cod_TipoDoc, 
               Total, 
               Impuesto, 
               Doc_Cliente, 
               TipoDocumentoAfectado, 
               SerieNumeroDocumentoAfectado, 
               RegimenPercepcion, 
               TasaPercepcion, 
               MontoPercepcion, 
               MontoTotalPercepcion, 
               MontoBasePercepcion, 
               EstadoItem, 
               ImporteTotal, 
               SumaGravadas, 
               SumaExoneradas, 
               SumaInafectas, 
               SumaGratuitas, 
               Otros_Cargos, 
               ISC, 
               IGV, 
               Otros_Tributos, 
               Cod_Moneda
        FROM
        (
            SELECT vtc.Cod_Sunat, 
                   ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero SerieNumero, 
                   ccp.Cod_TipoDoc, 
                   ccp.Total, 
                   ccp.Impuesto, 
                   ccp.Doc_Cliente,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BC'
                       THEN ''
                       ELSE
            (
                SELECT vtc2.Cod_Sunat
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                     INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc2 ON ccp2.Cod_TipoComprobante = vtc2.Cod_TipoComprobante
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END TipoDocumentoAfectado,
                   CASE
                       WHEN ccp.Cod_TipoComprobante = 'BC'
                       THEN ''
                       ELSE
            (
                SELECT ccp2.Serie + '-' + ccp2.Numero
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
            )
                   END SerieNumeroDocumentoAfectado, 
                   '' RegimenPercepcion, 
                   0.00 TasaPercepcion, 
                   0.00 MontoPercepcion, 
                   0.00 MontoTotalPercepcion, 
                   0.00 MontoBasePercepcion, 
                   '1' EstadoItem, 
                   0.00 ImporteTotal, 
                   0.00 SumaGravadas, 
                   0.00 SumaExoneradas, 
                   0.00 SumaInafectas, 
                   0.00 SumaGratuitas, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Cargos))) AS Otros_Cargos, 
                   0.00 ISC, 
                   0.00 IGV, 
                   CONVERT(NUMERIC(38, 2), ABS(AVG(ccp.Otros_Tributos))) Otros_Tributos, 
                   ccp.Cod_Moneda, 
                   ccp.tipocambio, 
                   ccp.Descuento_Total, 
                   ROW_NUMBER() OVER(
                       ORDER BY ccp.Cod_TipoComprobante, 
                                ccp.Serie, 
                                ccp.Numero) AS NumeroFila
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
                 LEFT JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
                 LEFT JOIN dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccr.Id_ComprobanteRelacion = ccp2.id_ComprobantePago
            --INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
            --LEFT JOIN (select TOP 1 * from CAJ_TIPOCAMBIO where CONVERT(VARCHAR, FechaHora , 103) = CONVERT(VARCHAR, @FechaResumen, 103)) ctc
            --ON CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, ctc.FechaHora , 103))
            WHERE ccp.Cod_TipoComprobante IN('NCC', 'NDC')
                 AND (ccp2.Cod_TipoComprobante IN('03')
                   OR ccp2.Cod_TipoComprobante IS NULL
                   OR ccp2.Cod_TipoComprobante = '')
            AND ccp.Cod_Libro = 14
            AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @FechaResumen, 103))
            GROUP BY ccp.id_ComprobantePago, 
                     vtc.Cod_Sunat, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.Cod_TipoDoc, 
                     ccp.Doc_Cliente, 
                     ccp.id_ComprobanteRef, 
                     ccp.Cod_TipoComprobante, 
                     ccp.Cod_Moneda, 
                     ccp.tipocambio, 
                     ccp.Descuento_Total, 
                     ccp.Total, 
                     ccp.Impuesto, 
                     ccp.Cod_TipoComprobante
        ) aResumenDiarioDetallado
        WHERE NumeroFila BETWEEN(500 * @NumeroPagina) + 1 AND+500 * (@NumeroPagina + 1)
        ORDER BY NumeroFila;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar
WITH ENCRYPTION
AS
    BEGIN
        SELECT CONVERT(VARCHAR, FechaEmision, 111) AS FechaCorta, 
               *
        FROM
        (
            SELECT ccp.id_ComprobantePago, 
                   0 Item, 
                   ccp.Cod_EstadoComprobante, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero Comprobante, 
                   ccp.Cod_Moneda, 
                   ccp.Total, 
                   ccp.FechaEmision, 
                   pcp.Email1, 
                   pcp.Email2, 
                   ccp.Nom_Cliente, 
                   0 Sunat, 
                   0 BD, 
                   0 FTP, 
                   0 Email, 
                   '' Cod_Mensaje, 
                   '' Mensaje, 
                   ccp.Cod_UsuarioReg
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 LEFT JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
            WHERE ccp.Cod_TipoComprobante IN('FE', 'NCE', 'NDE')
                 AND ccp.Serie LIKE 'F%'
                 AND ccp.Cod_EstadoComprobante <> 'FIN'
                 AND ccp.Flag_Anulado = 0
                 AND ccp.Cod_Libro = '14'
            UNION
            SELECT ccp.id_ComprobantePago, 
                   0 Item, 
                   ccp.Cod_EstadoComprobante, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero Comprobante, 
                   ccp.Cod_Moneda, 
                   ccp.Total, 
                   ccp.FechaEmision, 
                   pcp.Email1, 
                   pcp.Email2, 
                   ccp.Nom_Cliente, 
                   0 Sunat, 
                   0 BD, 
                   0 FTP, 
                   0 Email, 
                   '' Cod_Mensaje, 
                   '' Mensaje, 
                   ccp.Cod_UsuarioReg
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 LEFT JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
            WHERE ccp.Cod_TipoComprobante IN('FC')
                 AND ccp.Cod_EstadoComprobante <> 'FIN'
                 AND ccp.Flag_Anulado = 0
                 AND ccp.Cod_Libro = '14'
            UNION
            SELECT ccp.id_ComprobantePago, 
                   0 Item, 
                   ccp.Cod_EstadoComprobante, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie + '-' + ccp.Numero Comprobante, 
                   ccp.Cod_Moneda, 
                   ccp.Total, 
                   ccp.FechaEmision, 
                   pcp.Email1, 
                   pcp.Email2, 
                   ccp.Nom_Cliente, 
                   0 Sunat, 
                   0 BD, 
                   0 FTP, 
                   0 Email, 
                   '' Cod_Mensaje, 
                   '' Mensaje, 
                   ccp.Cod_UsuarioReg
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                 LEFT JOIN dbo.PRI_CLIENTE_PROVEEDOR pcp ON ccp.Id_Cliente = pcp.Id_ClienteProveedor
                 LEFT JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
                 LEFT JOIN dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccr.Id_ComprobanteRelacion = ccp2.id_ComprobantePago
            WHERE ccp.Cod_TipoComprobante IN('NCC', 'NDC')
                 AND ccp.Cod_EstadoComprobante <> 'FIN'
                 AND ccp.Flag_Anulado = 0
                 AND ccp.Cod_Libro = '14'
        ) T
        ORDER BY FechaCorta, 
                 T.Cod_TipoComprobante, 
                 T.Comprobante; --,T.FechaEmision
        --ORDER BY T.id_ComprobantePago,T.Comprobante,T.FechaEmision
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Verificar_ComprobantesXEnviar'
          AND type = 'P'
)
    DROP PROCEDURE USP_Verificar_ComprobantesXEnviar;
GO
CREATE PROCEDURE USP_Verificar_ComprobantesXEnviar
WITH ENCRYPTION
AS
    BEGIN
        --Creamos la tabla resultado
        IF OBJECT_ID('tempdb..#tempTablaResultado') IS NOT NULL
            BEGIN
                DROP TABLE dbo.#tempTablaResultado;
        END;
        CREATE TABLE #tempTablaResultado
        (Numero        INT IDENTITY(1, 1) NOT NULL, 
         CodigoError   VARCHAR(MAX), 
         Descripcion   VARCHAR(MAX), 
         IdComprobante INT, 
         Detalle       VARCHAR(MAX)
        );
        DECLARE @FEchaActual DATETIME= GETDATE();

        --Variables auxiliares
        SET DATEFORMAT DMY;
        DECLARE @RUCemisor VARCHAR(MAX)=
        (
            SELECT pe.RUC
            FROM dbo.PRI_EMPRESA pe
        );

        --Verificar que no existan documentos que se hayan emitido a ellos mismos
        -- INSERT INTO #tempTablaResultado
        -- (
        --     --Numero - this column value is auto-generated
        -- CodigoError,
        -- Descripcion,
        -- IdComprobante,
        -- Detalle
        -- )
        --        SELECT DISTINCT
        --               '01',
        --               'Documento emitido a la misma empresa',
        --               ccp.id_ComprobantePago,
        --               CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
        --        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        --        WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
        --        AND ccp.Cod_Libro = '14'
        --        AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
        --        AND ccp.Flag_Anulado = 0
        --        AND ccp.Doc_Cliente = @RUCemisor
        --     --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
        --Verificar si un comprobante no fue emitido en el plazo de los 7 dias
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '02', 
                      'Factura/Nota emitido fuera del plazo de los 7 dias', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('FE', 'NCE', 'NDE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Serie LIKE 'F%'
               AND ccp.Cod_Libro = 14
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103))) > 7;

        --Verificar si un comprobante no fue emitido en el futuro 1 dia adelante
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '03', 
                      'Documento emitido en un plazo de mas de 1 dia para adelante', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Cod_Libro = '14'
               AND ccp.Flag_Anulado = 0
               AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) < -1;

        --Verifica que los documentos no hayan sido emitidos a un cliente vacio o nulo
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '04', 
                      'Comprobante emitido a clientes nulos/vacios/Nombre muy corto', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Cod_Libro = '14'
               AND ccp.Flag_Anulado = 0
               AND (ccp.Id_Cliente IS NULL
                    OR ccp.Doc_Cliente IS NULL
                    OR LEN(REPLACE(ccp.Doc_Cliente, ' ', '')) = 0
                    OR ccp.Nom_Cliente IS NULL
                    OR LEN(REPLACE(ccp.Nom_Cliente, ' ', '')) = 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verificar que las facturas sean emitidas a un RUC necesariamente, excepto que sean de exportacion
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '05', 
                      'Factura emitida a clientes que no son RUC o no son de exportacion', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('FE')
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Cod_Libro = '14'
               AND ccp.Flag_Anulado = 0
               AND ((ccp.Cod_TipoOperacion = '01'
                     AND (ccp.Cod_TipoDoc <> '6'
                          OR LEN(ccp.Doc_Cliente) <> 11))
                    OR (ccp.Cod_TipoOperacion = '02'
                        AND (LEN(REPLACE(ccp.Nom_Cliente, ' ', '')) = 0
                             OR ccp.Nom_Cliente IS NULL
                             OR ccp.Direccion_Cliente IS NULL
                             OR LEN(REPLACE(ccp.Direccion_Cliente, ' ', '')) = 0)));
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Muestra los comprobantes que tengan campos nulos o vacios en el tipo de afectacion del IGV
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '06', 
                      'Comprobante con el campo de codigo de afectacion del IGV en NULL o vacio', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccd.Cod_TipoIGV IS NULL
                    OR LEN(REPLACE(ccd.Cod_TipoIGV, ' ', '')) = 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        ----Muestra los comprobantes que tengan campos nulos o vacios en el tipo de afectacion del ISC
        --INSERT INTO #tempTablaResultado
        --(
        --    --Numero - this column value is auto-generated
        --CodigoError,
        --Descripcion,
        --IdComprobante,
        --Detalle
        --)
        --       SELECT '06',
        --              'Comprobantes con el campo de codigo de afectacion del ISC en NULL o vacio',
        --              ccp.id_ComprobantePago,
        --              CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
        --       FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        --            INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
        --       WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
        --            AND ccp.Cod_Libro = '14'
        --            AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
        --       AND ccp.Flag_Anulado = 0
        --       AND (ccd.Cod_TipoISC IS NULL
        --            OR LEN(REPLACE(ccd.Cod_TipoISC, ' ', '')) = 0)
        --       --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que no existan montos negativos para BE,FE,NDE
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '07', 
                      'Comprobante con monto negativo en su cabezera y/o detalle', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NDE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccp.Total < 0
                    OR ccd.Sub_Total < 0
                    OR ccp.Impuesto < 0
                    OR ccd.IGV < 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que no existan montos positivos para NCE
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '08', 
                      'Nota de credito emitido en positivo', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('NCE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccp.Total > 0
                    OR ccd.Sub_Total > 0
                    OR ccp.Impuesto > 0
                    OR ccd.IGV > 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica el tipo de operacion en las NCE
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '09', 
                      'Codigo tipo de operacion para la NCE nulo o fuera de los limites', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('NCE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccp.Cod_TipoOperacion NOT IN('01', '02', '03', '04', '05', '06', '07', '08', '09', '10');
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica el tipo de operacion en la NDE
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '10', 
                      'Codigo tipo de operacion para la NDE nulo o fuera de los limites', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('NDE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccp.Cod_TipoOperacion NOT IN('01', '02', '03');
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que una FE tenga una serie que comienze con F
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '11', 
                      'La serie de la factura no comienza con F', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('FE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccp.Serie NOT LIKE 'F%';
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que una BE tenga una serie que comienze con B
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '12', 
                      'La serie de la boleta no comienza con B', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('BE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccp.Serie NOT LIKE 'B%';
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que las NCE/NDE tengan como idref un valor distinto de 0
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '13', 
                      'El documento no tiene un id de referencia valido', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
               WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
               AND ccp.Cod_Libro = '14'
               AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccp.id_ComprobanteRef = 0
                    OR ccp.id_ComprobanteRef IS NULL);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que no existan campos vacios o nulos en la descripcion de los detalles
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '14', 
                      'El documento tiene itens con descripcion de detalles vacio o nulos', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccd.Descripcion IS NULL
                    OR LEN(REPLACE(ccd.Descripcion, ' ', '')) = 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica que no existan comprobantes con cantidad en 0
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '15', 
                      'El comprobante tiene itens con cantidad en cero', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND (ccd.Cantidad IS NULL
                    OR ccd.Cantidad = 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica el porcentaje de afectacion al IGV tenga un valor distinto de 0 si este es 10,11,12,13,14,15,16,17
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '16', 
                      'El comprobante tiene por porcentaje de IGV un valor igual a cero', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccd.Cod_TipoIGV IN('10', '11', '12', '13', '14', '15', '16', '17')
        AND (ccd.Porcentaje_IGV IS NULL
             OR ccd.Porcentaje_IGV = 0);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Verifica si el documento es un doceumento de exportacion, que sus detalles sean de esportacion por cod_tipo IGV
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '17', 
                      'Detalle(s) de factura de exportacion incorrectos', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('FE')
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Cod_Libro = '14'
               AND ccp.Flag_Anulado = 0
               AND ccp.Cod_TipoOperacion = '02'
               AND (ccd.Cod_TipoIGV <> '40'
                    OR ccd.Cod_TipoIGV IS NULL);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
        --Verifica en base a los codigos de afectacion al IGV el monto total de la operacion
        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '18', 
                      'Comprobante con subtotales en 0', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Cod_Libro = '14'
               AND ccp.Flag_Anulado = 0
               AND ccp.Total > 0
               AND ccd.Sub_Total = 0
               AND ccd.Cod_TipoIGV IN(10, 20);
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
        -- --Verificar los subtotales acumulados
        -- INSERT INTO #tempTablaResultado
        -- (
        --     --Numero - this column value is auto-generated
        -- CodigoError,
        -- Descripcion,
        -- IdComprobante,
        -- Detalle
        -- )
        --        SELECT DISTINCT
        --               '19',
        --               'El calculo de los Impuestos y/o totales no estan correctamente calculados',
        --               ccp.id_ComprobantePago,
        --               CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
        --        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        --             INNER JOIN
        --        (
        --            SELECT ccp.id_ComprobantePago,
        --                   CASE
        --                       WHEN ccp2.IGV <> 0
        --                       THEN ccp2.IGV-(CASE
        --                                          WHEN ccp.Cod_TipoComprobante = 'NCE'
        --                                          THEN-1
        --                                          ELSE 1
        --                                      END)*ccp.Descuento_Total*18/118
        --                       ELSE 0
        --                   END AS IGV,
        --                   ccp2.Total-(CASE
        --                                   WHEN ccp.Cod_TipoComprobante = 'NCE'
        --                                   THEN-1
        --                                   ELSE 1
        --                               END)*ccp.Descuento_Total AS Total
        --            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
        --                 INNER JOIN
        --            (
        --                SELECT ccd.id_ComprobantePago,
        --                       SUM(CASE
        --                               WHEN ccd.Cod_TipoIGV = 10
        --                               THEN ccd.Cantidad * ccd.PrecioUnitario * 18 / 118
        --                               ELSE 0
        --                           END) AS IGV,
        --                       ROUND(SUM(ccd.Cantidad * ccd.PrecioUnitario), 2) AS Total
        --                FROM dbo.CAJ_COMPROBANTE_D ccd
        --                     INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
        --                WHERE(ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE'))
        --                     AND (ccp.Cod_Libro = 14)
        --                     AND (ccp.Cod_EstadoComprobante IN('INI', 'EMI'))
        --                GROUP BY ccd.id_ComprobantePago
        --            ) ccp2 ON ccp2.id_ComprobantePago = ccp.id_ComprobantePago
        --            GROUP BY ccp.id_ComprobantePago,
        --                     ccp2.Total,
        --                     ccp2.IGV,
        --                     ccp.Total,
        --                     ccp.Impuesto,
        --                     ccp.Descuento_Total,
        --                     ccp.Cod_TipoComprobante
        --            HAVING AVG(ccp.Total) <> ccp2.Total
        --                   OR AVG(ccp.Impuesto) <> ccp2.IGV
        --        ) ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago;
        --        --WHERE ccp.Total <> ccd.Total
        --        --      OR ROUND(ccp.Impuesto, 2) <> ROUND(ccd.IGV, 2);
        --        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
        --Verificamos la numeracion de los comprobantes en base al ultimo emitido y la fecha actual
        --Verifica los posibles errores en nuemrcacion que puede haber
        DECLARE @tipoComprobante VARCHAR(10);
        DECLARE @SerieComprobante VARCHAR(10);
        DECLARE @Cod_TipoComprobante AS VARCHAR(5), @serie AS VARCHAR(5), @Comprobante AS VARCHAR(MAX);
        DECLARE @id_ComprobantePago INT, @numero INT;
        DECLARE @NumeroTabla VARCHAR(10);
        DECLARE @flag BIT;
        DECLARE CURSORCOMPROBANTES CURSOR
        FOR SELECT DISTINCT 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
            AND ccp.Cod_Libro = 14
            AND (ccp.Serie LIKE 'F%'
                 OR ccp.Serie LIKE 'B%')
            ORDER BY ccp.Cod_TipoComprobante, 
                     ccp.Serie;
        OPEN CURSORCOMPROBANTES;
        FETCH NEXT FROM CURSORCOMPROBANTES INTO @tipoComprobante, @SerieComprobante;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @Cod_TipoComprobante = @tipoComprobante;
                SET @serie = @SerieComprobante;
                DECLARE Medicion_cursor CURSOR
                FOR SELECT id_ComprobantePago, 
                           Numero
                    FROM CAJ_COMPROBANTE_PAGO
                    WHERE cod_libro = '14'
                          AND Cod_TipoComprobante = @Cod_TipoComprobante
                          AND serie = @serie --AND Flag_Anulado=0
                          AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
                    ORDER BY Numero DESC;
                SET @flag = 1;
                SET @numero =
                (
                    SELECT TOP 1 ccp.Numero
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE ccp.Cod_TipoComprobante = @Cod_TipoComprobante
                          AND ccp.Serie = @serie
                          AND ccp.cod_libro = '14'
                    ORDER BY ccp.Numero DESC
                );
                OPEN Medicion_cursor;
                FETCH NEXT FROM Medicion_cursor INTO @id_ComprobantePago, @NumeroTabla;
                WHILE @@FETCH_STATUS = 0
                      AND @flag = 1
                    BEGIN
                        IF(@numero <> CONVERT(INT, @NumeroTabla))
                            BEGIN
                                INSERT INTO #tempTablaResultado
                                (
                                --Numero - this column value is auto-generated
                                CodigoError, 
                                Descripcion, 
                                IdComprobante, 
                                Detalle
                                )
                                       SELECT DISTINCT 
                                              '20', 
                                              'Error en la numeracion de los ultimos 7 dias', 
                                              @id_ComprobantePago, 
                                              CONCAT(
                                       (
                                           SELECT ccp2.Cod_TipoComprobante
                                           FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
                                           WHERE ccp2.id_ComprobantePago = @id_ComprobantePago
                                       ), '|', ' ESTA : ', @serie + '-' + CONVERT(VARCHAR, @NumeroTabla), '|', ' DEBE DE SER : ', @serie + '-' + CONVERT(VARCHAR, @numero), '|', CONVERT(VARCHAR,
                                       (
                                           SELECT ccp.FechaEmision
                                           FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                                           WHERE ccp.id_ComprobantePago = @id_ComprobantePago
                                       )));
                                SET @flag = 0;
                        END;
                        SET @numero-=1;
                        FETCH NEXT FROM Medicion_cursor INTO @id_ComprobantePago, @NumeroTabla;
                    END;
                CLOSE Medicion_cursor;
                DEALLOCATE Medicion_cursor;
                FETCH NEXT FROM CURSORCOMPROBANTES INTO @tipoComprobante, @SerieComprobante;
            END;
        CLOSE CURSORCOMPROBANTES;
        DEALLOCATE CURSORCOMPROBANTES;

        --Verifica posible incoherencias entre la fecha de emision y la numeracion
        SET DATEFORMAT DMY;
        DECLARE @CodTipoComprobante VARCHAR(10);
        DECLARE @FechaAnterior DATE= '01-01-1990 00:00:00:000';
        DECLARE @IdComprobantePAgo INT;
        DECLARE @CodAux VARCHAR(10);
        DECLARE @SerieAux VARCHAR(10);
        DECLARE @NumeroAux VARCHAR(10);
        DECLARE CURSORCOMPROBANTES CURSOR LOCAL
        FOR SELECT DISTINCT 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
            AND ccp.Cod_Libro = 14
            AND (ccp.Serie LIKE 'F%'
                 OR ccp.Serie LIKE 'B%')
            AND ccp.cod_libro = '14'
            ORDER BY ccp.Cod_TipoComprobante, 
                     ccp.Serie;
        OPEN CURSORCOMPROBANTES;
        FETCH NEXT FROM CURSORCOMPROBANTES INTO @CodTipoComprobante, @SerieComprobante;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE CURSORCOMPROBANTES2 CURSOR LOCAL
                FOR SELECT ccp.id_ComprobantePago, 
                           ccp.Cod_TipoComprobante, 
                           ccp.Serie, 
                           ccp.Numero, 
                           ccp.FechaEmision
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE ccp.Cod_TipoComprobante = @CodTipoComprobante
                          AND ccp.Serie = @SerieComprobante
                          AND ccp.Cod_Libro = 14
                          AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
                    ORDER BY ccp.Numero;
                OPEN CURSORCOMPROBANTES2;
                FETCH NEXT FROM CURSORCOMPROBANTES2 INTO @IdComprobantePAgo, @CodAux, @SerieAux, @NumeroAux, @FechaActual;
                WHILE @@FETCH_STATUS = 0
                    BEGIN
                        IF(@FechaAnterior > @FechaActual)
                            BEGIN
                                INSERT INTO #tempTablaResultado
                                (
                                --Numero - this column value is auto-generated
                                CodigoError, 
                                Descripcion, 
                                IdComprobante, 
                                Detalle
                                )
                                       SELECT DISTINCT 
                                              '21', 
                                              'Incogruencia en la correlatividad de la fecha de emision entre la fecha de emision de los comprobantes en los ultimos 7 dias', 
                                              @IdComprobantePAgo, 
                                              CONCAT(@CodAux, '|', @SerieAux + '-' + @NumeroAux, '|', ' FECHA ANTERIOR : ' + CONVERT(VARCHAR, @FechaAnterior) + ' - FECHA ACTUAL : ' + CONVERT(VARCHAR, @FechaActual));

                                --BREAK;
                                SET @FechaAnterior = '01-01-1990 00:00:00:000';
                        END;
                            ELSE
                            BEGIN
                                SET @FechaAnterior = @FechaActual;
                        END;
                        FETCH NEXT FROM CURSORCOMPROBANTES2 INTO @IdComprobantePAgo, @CodAux, @SerieAux, @NumeroAux, @FechaActual;
                    END;
                CLOSE CURSORCOMPROBANTES2;
                DEALLOCATE CURSORCOMPROBANTES2;
                SET @FechaAnterior = '01-01-1990 00:00:00:000';
                FETCH NEXT FROM CURSORCOMPROBANTES INTO @CodTipoComprobante, @SerieComprobante;
            END;
        CLOSE CURSORCOMPROBANTES;
        DEALLOCATE CURSORCOMPROBANTES;

        --Verifica que los documentos tengan detalles y las notas su relacion

        DECLARE @Cod_TipocomprobanteR VARCHAR(MAX);
        DECLARE @SerieR VARCHAR(MAX);
        DECLARE @NumeroR VARCHAR(MAX);
        DECLARE @IdComprobante INT, @Detalle VARCHAR(MAX), @Fecha DATE;
        DECLARE CursorFila CURSOR
        FOR SELECT ccp.id_ComprobantePago, 
                   ccp.Cod_TipoComprobante, 
                   ccp.Serie, 
                   ccp.Numero, 
                   ccp.FechaEmision
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
            AND ccp.Cod_Libro = 14
            AND Flag_Anulado = 0
            AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
            --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
            ORDER BY ccp.Cod_TipoComprobante, 
                     ccp.Serie, 
                     ccp.Numero, 
                     ccp.FechaEmision;
        OPEN CursorFila;
        FETCH NEXT FROM CursorFila INTO @IdComprobante, @Cod_TipocomprobanteR, @SerieR, @NumeroR, @Fecha;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @Detalle = ''; 
                --Verificamos que tenga detalles
                IF(
                (
                    SELECT COUNT(*)
                    FROM dbo.CAJ_COMPROBANTE_D ccd
                    WHERE ccd.id_ComprobantePago = @IdComprobante
                ) = 0)--Sin detalles
                    BEGIN
                        SET @Detalle = 'No tiene detalles - ';
                END;

                --Verificamos que las notas tengan relacion
                IF(
                (
                    SELECT TOP 1 ccp.Cod_TipoComprobante
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE ccp.id_ComprobantePago = @IdComprobante
                ) IN('NCE', 'NDE'))
                    BEGIN
                        IF(
                        (
                            SELECT COUNT(*)
                            FROM dbo.CAJ_COMPROBANTE_RELACION ccr
                            WHERE ccr.id_ComprobantePago = @IdComprobante
                        ) = 0)--Sin relacion
                            BEGIN
                                SET @Detalle = @Detalle + 'No tiene relacion';
                        END;
                END;
                IF(@Detalle <> '')
                    BEGIN
                        INSERT INTO #tempTablaResultado
                        (
                        --Numero - this column value is auto-generated
                        CodigoError, 
                        Descripcion, 
                        IdComprobante, 
                        Detalle
                        )
                               SELECT DISTINCT 
                                      '22', 
                                      'Comprobante sin detalles y/o relacion', 
                                      @IdComprobante, 
                                      CONCAT(@Cod_TipocomprobanteR, '|', @SerieR + '-' + @NumeroR, '|', @Detalle);
                END;
                FETCH NEXT FROM CursorFila INTO @IdComprobante, @Cod_TipocomprobanteR, @SerieR, @NumeroR, @Fecha;
            END;
        CLOSE CursorFila;
        DEALLOCATE CursorFila;

        --Verifica cuantos documentos afectan las notas,

        DECLARE @Id_ComprobanteRef INT, @Conteo INT;
        DECLARE @id_comprobante INT, @serieN VARCHAR(MAX), @Referenciados VARCHAR(MAX);
        DECLARE cursorfila CURSOR LOCAL
        FOR SELECT ccp.id_ComprobanteRef, 
                   COUNT(ccp.id_ComprobanteRef) AS Conteo
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.Cod_TipoComprobante = 'NCE'
                  AND ccp.Cod_Libro = 14
                  AND ccp.Flag_Anulado = 0
                  AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
            --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
            GROUP BY ccp.id_ComprobanteRef
            HAVING COUNT(ccp.id_ComprobanteRef) > 1;
        OPEN cursorfila;
        FETCH NEXT FROM cursorfila INTO @Id_ComprobanteRef, @Conteo;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @id_comprobante =
                (
                    SELECT TOP 1 ccp.id_ComprobantePago
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE id_ComprobantePago = @Id_ComprobanteRef
                          AND ccp.Cod_Libro = 14
                          AND ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Flag_Anulado = 0
                );
                SET @Cod_Tipocomprobante =
                (
                    SELECT TOP 1 ccp.Cod_TipoComprobante
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE id_ComprobantePago = @Id_ComprobanteRef
                          AND ccp.Cod_Libro = 14
                          AND ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Flag_Anulado = 0
                );
                SET @serieN =
                (
                    SELECT TOP 1 ccp.Serie
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE id_ComprobantePago = @Id_ComprobanteRef
                          AND ccp.Cod_Libro = 14
                          AND ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Flag_Anulado = 0
                );
                SET @numero =
                (
                    SELECT TOP 1 ccp.Numero
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE id_ComprobantePago = @Id_ComprobanteRef
                          AND ccp.Cod_Libro = 14
                          AND ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Flag_Anulado = 0
                );
                SET @fecha =
                (
                    SELECT TOP 1 ccp.FechaEmision
                    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    WHERE id_ComprobantePago = @Id_ComprobanteRef
                          AND ccp.Cod_Libro = 14
                          AND ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Flag_Anulado = 0
                );
                --Recupera los comprobantes que afectan a la nota
                SELECT @Referenciados = COALESCE(@Referenciados + ', ', '') + CONVERT(VARCHAR(10), ccp.id_ComprobantePago)
                FROM CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.id_ComprobanteRef = @Id_ComprobanteRef
                      AND ccp.Cod_Libro = 14
                      AND ccp.Cod_TipoComprobante = 'NCE'
                      AND ccp.Flag_Anulado = 0
                      AND ccp.Cod_TipoOperacion = '01';
                INSERT INTO #tempTablaResultado
                (
                --Numero - this column value is auto-generated
                CodigoError, 
                Descripcion, 
                IdComprobante, 
                Detalle
                )
                       SELECT DISTINCT 
                              '23', 
                              'Comprobante referenciado por multiples notas de credito de anulacion', 
                              @id_comprobante, 
                              CONCAT(@Cod_Tipocomprobante, '|', @serieN + '-' + CONVERT(VARCHAR, @Numero), '|', 'REFERENCIAS : ' + @Referenciados, '|', CONVERT(VARCHAR, @fecha));
                SET @Referenciados = NULL;
                FETCH NEXT FROM cursorfila INTO @Id_ComprobanteRef, @Conteo;
            END;
        CLOSE cursorfila;
        DEALLOCATE cursorfila;

        --Verificar que no existan comprobantes con itens con precio unitario en cero

        INSERT INTO #tempTablaResultado
        (
        --Numero - this column value is auto-generated
        CodigoError, 
        Descripcion, 
        IdComprobante, 
        Detalle
        )
               SELECT DISTINCT 
                      '24', 
                      'Comprobante con precio unitario en cero', 
                      ccp.id_ComprobantePago, 
                      CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie + '-' + ccp.Numero, '|', ccp.FechaEmision)
               FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                    INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
               WHERE ccp.Cod_TipoComprobante IN('FE', 'BE')
                    AND ccp.Cod_Libro = '14'
                    AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
               AND ccp.Flag_Anulado = 0
               AND ccd.Cod_TipoIGV IN('10', '20', '40')
        AND ccd.PrecioUnitario = 0;
        --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;
        --Mostramos resultados

        SELECT ttr.*
        FROM #tempTablaResultado ttr
        ORDER BY ttr.Numero;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_USUARIO_SUNAT_TraerUsuarioSecundarioXRUC'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_USUARIO_SUNAT_TraerUsuarioSecundarioXRUC;
GO
--Trae el top 1 usuario secundario para un RUC especificado
CREATE PROCEDURE USP_VIS_USUARIO_SUNAT_TraerUsuarioSecundarioXRUC @RUC VARCHAR(11)
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 vus.*
        FROM dbo.VIS_USUARIO_SUNAT vus
        WHERE vus.RUC = @RUC
              AND vus.Tipo_Cuenta = 'SECUNDARIO'
              AND vus.Estado = 1;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CORREOS_TraerCorreoComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CORREOS_TraerCorreoComprobante;
GO

--Traer el top 1 de correos para COMPROBANTES
CREATE PROCEDURE USP_VIS_CORREOS_TraerCorreoComprobante
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 vc.*
        FROM dbo.VIS_CORREOS vc
        WHERE vc.Tipo_Uso = 'COMPROBANTES'
              AND vc.Estado = 1;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CORREOS_TraerFTPComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CORREOS_TraerFTPComprobante;
GO

--Trae el Top 1 de FTP para comprobantes
CREATE PROCEDURE USP_VIS_CORREOS_TraerFTPComprobante
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 vf.*
        FROM dbo.VIS_FTP vf
        WHERE vf.Tipo_Uso = 'COMPROBANTES'
              AND vf.Estado = 1;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_G;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_G @Cod_Configuracion   VARCHAR(64), 
                                         @Valor_Configuracion VARCHAR(1024), 
                                         @Estado              BIT
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Nro AS INT;
        IF NOT EXISTS
        (
            SELECT vc.*
            FROM dbo.VIS_CONFIGURACION vc
            WHERE vc.Cod_Configuracion = @Cod_Configuracion
        )
            BEGIN
                -- Calcular el ultimo el elemento ingresado para este tabla
                SET @Nro =
                (
                    SELECT ISNULL(MAX(vc.Nro), 0) + 1
                    FROM dbo.VIS_CONFIGURACION vc
                );
                EXEC USP_PAR_FILA_G '099', '001', @Nro, @Cod_Configuracion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '099', '002', @Nro, @Valor_Configuracion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '099', '003', NULL, NULL, NULL, NULL, NULL, @Estado, 1, 'MIGRACION';
        END;
            ELSE
            BEGIN
                SET @Nro =
                (
                    SELECT vc.Nro
                    FROM dbo.VIS_CONFIGURACION vc
                    WHERE vc.Cod_Configuracion = @Cod_Configuracion
                );
                EXEC USP_PAR_FILA_G '099', '001', @Nro, @Cod_Configuracion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '099', '002', @Nro, @Valor_Configuracion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
                EXEC USP_PAR_FILA_G '099', '003', NULL, NULL, NULL, NULL, NULL, @Estado, 1, 'MIGRACION';
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_E;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_E @Cod_Configuracion VARCHAR(64)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Nro AS INT;
        IF EXISTS
        (
            SELECT vc.*
            FROM dbo.VIS_CONFIGURACION vc
            WHERE vc.Cod_Configuracion = @Cod_Configuracion
        )
            BEGIN
                SET @Nro =
                (
                    SELECT vc.Nro
                    FROM dbo.VIS_CONFIGURACION vc
                    WHERE vc.Cod_Configuracion = @Cod_Configuracion
                );
                EXEC dbo.USP_PAR_FILA_E @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @Nro;
                EXEC dbo.USP_PAR_FILA_E @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @Nro;
                EXEC dbo.USP_PAR_FILA_E @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @Nro;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 22/07/2015
-- OBJETIVO: Actualizar el Stock de toda la empresa
-- USP_PRI_PRODUCTO_STOCK_ActualizarStockGeneral
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_ActualizarStockGeneral'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_ActualizarStockGeneral;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_ActualizarStockGeneral
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        DECLARE @Id_Producto INT, @Cod_Almacen VARCHAR(32), @Cod_UnidadMedida VARCHAR(32), @StockCalculado AS NUMERIC(38, 6);
        DECLARE Medicion_cursor CURSOR
        FOR SELECT P.Id_Producto, 
                   P.Cod_Almacen, 
                   P.Cod_UnidadMedida, 
                   SUM(P.StockActual) AS StockCalculado
            FROM
            (
                SELECT CD.Id_Producto, 
                       CD.Cod_Almacen, 
                       CD.Cod_UnidadMedida, 
                       ISNULL(SUM(CASE CP.Cod_Libro
                                      WHEN '08'
                                      THEN CD.Despachado
                                      WHEN '14'
                                      THEN-1 * CD.Despachado
                                      ELSE 0
                                  END), 0) AS StockActual
                FROM CAJ_COMPROBANTE_PAGO AS CP
                     INNER JOIN CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON CD.Id_Producto = PS.Id_Producto
                                                            AND CD.Cod_Almacen = PS.Cod_Almacen
                                                            AND CD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE Flag_Despachado = 1
                      AND Flag_Anulado = 0
                      AND Cod_Turno IS NOT NULL
                GROUP BY CD.Id_Producto, 
                         CD.Cod_Almacen, 
                         CD.Cod_UnidadMedida
                UNION ALL
                SELECT AMD.Id_Producto, 
                       AM.Cod_Almacen, 
                       AMD.Cod_UnidadMedida, 
                       SUM(CASE AM.Cod_TipoComprobante
                               WHEN 'NE'
                               THEN AMD.Cantidad
                               WHEN 'NS'
                               THEN-1 * AMD.Cantidad
                               ELSE 0
                           END) AS StockActual
                FROM ALM_ALMACEN_MOV AS AM
                     INNER JOIN ALM_ALMACEN_MOV_D AS AMD ON AM.Id_AlmacenMov = AMD.Id_AlmacenMov
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON AM.Cod_Almacen = PS.Cod_Almacen
                                                            AND AMD.Id_Producto = PS.Id_Producto
                                                            AND AMD.Cod_UnidadMedida = PS.Cod_UnidadMedida
                WHERE Flag_Anulado = 0
                      AND Cod_Turno IS NOT NULL
                GROUP BY AMD.Id_Producto, 
                         AM.Cod_Almacen, 
                         AMD.Cod_UnidadMedida
            ) AS P
            GROUP BY P.Id_Producto, 
                     P.Cod_Almacen, 
                     P.Cod_UnidadMedida;
        OPEN Medicion_cursor;
        FETCH NEXT FROM Medicion_cursor INTO @Id_Producto, @Cod_Almacen, @Cod_UnidadMedida, @StockCalculado;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                IF EXISTS
                (
                    SELECT Id_Producto
                    FROM PRI_PRODUCTOS
                    WHERE Flag_Activo = 1
                          AND Flag_Stock = 1
                          AND Id_Producto = @Id_Producto
                )
                    BEGIN
                        -- actualizar todo de nuevo
                        UPDATE PRI_PRODUCTO_STOCK
                          SET 
                              Stock_Act = @StockCalculado
                        WHERE Id_Producto = @Id_Producto
                              AND Cod_Almacen = @Cod_Almacen
                              AND Cod_UnidadMedida = @Cod_UnidadMedida;
                END;
                    ELSE
                    BEGIN
                        -- actualizar todo de nuevo
                        UPDATE PRI_PRODUCTO_STOCK
                          SET 
                              Stock_Act = 0
                        WHERE Id_Producto = @Id_Producto
                              AND Cod_Almacen = @Cod_Almacen
                              AND Cod_UnidadMedida = @Cod_UnidadMedida;
                END;
                FETCH NEXT FROM Medicion_cursor INTO @Id_Producto, @Cod_Almacen, @Cod_UnidadMedida, @StockCalculado;
            END;
        CLOSE Medicion_cursor;
        DEALLOCATE Medicion_cursor;
    END;
GO
-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_BAN_CUENTA_BANCARIA_TXSucursal'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TXSucursal;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TXSucursal @Cod_Sucursal VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_CuentaBancaria, 
               Des_CuentaBancaria AS Des_CuentaBancaria
        FROM BAN_CUENTA_BANCARIA
        WHERE(Cod_Sucursal = @Cod_Sucursal
              OR Cod_Sucursal IS NULL)
        ORDER BY Des_CuentaBancaria;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 27/11/2015
-- OBJETIVO: Selecionar los precios de Categoria
-- EXEC USP_PRI_PRODUCTO_PRECIO_TXCategoria 1,'01'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TXCategoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXCategoria;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TXCategoria @Id_Producto AS   INT, 
                                                     @Cod_Categoria AS VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               VP.Cod_Precio, 
               VP.Nom_Precio, 
               ISNULL(PP.Valor, 0) AS Valor, 
               VP.Cod_Categoria, 
               VP.Nro
        FROM VIS_PRECIOS AS VP
             LEFT JOIN PRI_PRODUCTO_PRECIO AS PP ON VP.Cod_Precio = PP.Cod_TipoPrecio
                                                    AND PP.Id_Producto = @Id_Producto
        WHERE(VP.Cod_Categoria = @Cod_Categoria)
             OR (VP.Cod_Categoria = '')
             OR (VP.Cod_Categoria IS NULL)
             AND (VP.Estado = 1)
        ORDER BY VP.Nro;
    END;
GO
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
--EXEC dbo.USP_ALM_ALMACEN_MOV_ObtenerMovimientoSaldoInicial 'A101',34,'NIU'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_ALM_ALMACEN_MOV_ObtenerMovimientoSaldoInicial'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerMovimientoSaldoInicial;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerMovimientoSaldoInicial @Cod_Almacen      VARCHAR(32), 
                                                                   @Id_Producto      INT, 
                                                                   @Cod_UnidadMedida VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 1 aamd.Id_AlmacenMov, 
                     aamd.Item, 
                     aam.Cod_Almacen, 
                     aamd.Id_Producto, 
                     aamd.Cod_UnidadMedida
        FROM dbo.ALM_ALMACEN_MOV aam
             INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
        WHERE aam.Cod_Almacen = @Cod_Almacen
              AND aamd.Id_Producto = @Id_Producto
              AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
              AND aam.Cod_TipoComprobante = 'NE'
              AND aam.Cod_TipoOperacion = '16'
              AND aamd.Cantidad = 999999
              AND aam.Flag_Anulado = 0
        ORDER BY aam.Fecha ASC;
    END;
GO
--EXEC dbo.USP_PRI_PRODUCTOS_KardexXCodAlmacenIdProductoCodMedida 'A101',34,'NIU'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTOS_KardexXCodAlmacenIdProductoCodMedida'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_KardexXCodAlmacenIdProductoCodMedida;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_KardexXCodAlmacenIdProductoCodMedida @Cod_Almacen      VARCHAR(32), 
                                                                        @Id_Producto      INT, 
                                                                        @Cod_UnidadMedida VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        --Creamos las tabla para saldo inicial
        --Introducimos los datos de todos lo comprobantes hasta la fecha

        SELECT DISTINCT 
               CASE aam.Cod_TipoComprobante
                   WHEN 'NE'
                   THEN 1
                   ELSE 2
               END AS Orden, 
               aam.Id_AlmacenMov, 
               aamd.Item, 
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
                         END), 2) Monto_Salida
        FROM dbo.ALM_ALMACEN_MOV aam
             INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
             INNER JOIN dbo.PRI_PRODUCTOS pp ON aamd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.VIS_TIPO_OPERACIONES vto ON aam.Cod_TipoOperacion = vto.Cod_TipoOperacion
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON aamd.Id_Producto = pps.Id_Producto
        WHERE aam.Flag_Anulado = 0
              AND aam.Cod_Almacen = @Cod_Almacen
              AND aamd.Id_Producto = @Id_Producto
              AND pp.Flag_Stock = 1
              AND aamd.Cod_UnidadMedida = @Cod_UnidadMedida
              AND pps.Cod_UnidadMedida = @Cod_UnidadMedida
              AND pps.Cod_Almacen = @Cod_Almacen
        GROUP BY aam.Cod_TipoComprobante, 
                 aam.Id_AlmacenMov, 
                 aam.Fecha, 
                 aam.Serie, 
                 aam.Numero, 
                 vto.Nom_TipoOperacion, 
                 pp.Cod_Producto, 
                 aamd.Item
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
               ccd.id_Detalle Item, 
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
                         END), 2) Monto_Salida
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
        WHERE ccp.Flag_Anulado = 0
              AND ccp.Flag_Despachado = 1
              AND pp.Flag_Stock = 1
              AND ccd.Cod_Almacen = @Cod_Almacen
              AND ccd.Id_Producto = @Id_Producto
              AND ccd.Cod_UnidadMedida = @Cod_UnidadMedida
        GROUP BY ccp.Cod_Libro, 
                 ccp.id_ComprobantePago, 
                 ccp.FechaEmision, 
                 ccp.Cod_TipoComprobante, 
                 ccp.Serie, 
                 ccp.Numero, 
                 ccp.Nom_Cliente, 
                 pp.Cod_Producto, 
                 ccd.id_Detalle;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA: 21/02/2019 | 25/06/2019
-- OBJETIVO: Procedimiento que Lista los productos indicando el Tipo de producto PRL(Lote),PRS(Serie)
-- Procedimiento que permite buscar los productos de acuerdo al tipo de producto
-- EXEC USP_PRI_PRODUCTOS_Buscar 100,'diclo',null,null,'001',0
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTOS_Buscar_TIPO'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO @Cod_Caja AS           VARCHAR(32)  = NULL, 
--                                                @Buscar             VARCHAR(512), 
--                                                @CodTipoProducto AS    VARCHAR(8)   = NULL, 
--                                                @Cod_Categoria AS      VARCHAR(32)  = NULL, 
--                                                @Cod_Precio AS         VARCHAR(32)  = NULL, 
--                                                @Flag_RequiereStock AS BIT          = 0
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         SET DATEFORMAT DMY;
--         SET @Buscar = REPLACE(@Buscar, '%', ' ');
--         SELECT P.Id_Producto, 
--                P.Nom_Producto AS Nom_Producto, 
--                P.Cod_Producto, 
--                PS.Stock_Act, 
--                PS.Precio_Venta, 
--                M.Nom_Moneda AS Nom_Moneda, 
--                PS.Cod_Almacen, 
--                0 AS Descuento, 
--                'NINGUNO' AS TipoDescuento, 
--                A.Des_CortaAlmacen AS Des_Almacen, 
--                PS.Cod_UnidadMedida, 
--                UM.Nom_UnidadMedida, 
--                P.Flag_Stock, 
--                PS.Precio_Compra,
--                CASE
--                    WHEN @Cod_Precio IS NULL
--                    THEN 0
--                    ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--                END AS Precio, 
--                P.Cod_TipoOperatividad, 
--                PS.Cod_Moneda, 
--                Cod_TipoProducto AS TipoProducto
--         FROM PRI_PRODUCTOS AS P
--              INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--              INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--              INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--              INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--              INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--         WHERE(P.Cod_TipoProducto = @CodTipoProducto
--               OR @CodTipoProducto IS NULL)
--              AND ((P.Cod_Producto LIKE @Buscar)
--                   OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--                   OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--                   OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--              AND (P.Cod_Categoria IN
--         (
--             SELECT Cod_Categoria
--             FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--         )
--         OR @Cod_Categoria IS NULL)
--              AND (ca.Cod_Caja = @Cod_Caja
--                   OR @Cod_Caja IS NULL)
--              AND (P.Flag_Activo = 1)
--         -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
--         ORDER BY Nom_Producto;
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_Buscar_TIPO'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                               @Buscar             VARCHAR(512), 
                                               @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                               @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                               @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                               @Flag_RequiereStock AS BIT          = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT P.Id_Producto, 
               P.Nom_Producto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda AS Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_CortaAlmacen AS Des_Almacen, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               P.Flag_Stock, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio, 
               P.Cod_TipoOperatividad, 
               PS.Cod_Moneda, 
               Cod_TipoProducto AS TipoProducto
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
        WHERE(P.Cod_TipoProducto = @CodTipoProducto
              OR @CodTipoProducto IS NULL)
             AND ((P.Cod_Producto LIKE @Buscar)
                  OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (ca.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (P.Flag_Activo = 1)
        -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
        ORDER BY Nom_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN 
-- FECHA:  26/02/2019 | 25/06/2019
-- OBJETIVO: Metodo que recupera el stock cuando el tipo del producto es Lote
-- Metodo que permite recuperar el stock de productos segun lote o serie 
-- SELECT dbo.UFN_CAJ_LOTES_Stocks ('108327',2869,'A101','08/03/2019','PRL')
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'UFN_CAJ_LOTES_Stocks'
-- )
--     DROP FUNCTION UFN_CAJ_LOTES_Stocks;
-- GO
-- CREATE FUNCTION UFN_CAJ_LOTES_Stocks
-- (@Serie AS          VARCHAR(512), 
--  @Id_Producto AS    INT, 
--  @Id_Almacen AS     VARCHAR(32), 
--  @F_Venc         DATE, 
--  @CodTipoProucto AS VARCHAR(5)
-- )
-- RETURNS INT
-- WITH ENCRYPTION
-- AS
--      BEGIN
--          DECLARE @Stock AS NUMERIC(38, 2);
--          DECLARE @StockComprobante AS NUMERIC(38, 2);
--          DECLARE @StockAlmacen AS NUMERIC(38, 2);
--          IF(@CodTipoProucto = 'PRL')
--              BEGIN
--                  SET @StockComprobante =
--                  (
--                      SELECT ISNULL(SUM(CASE
--                                            WHEN Cod_Libro = '08'
--                                            THEN C.Cantidad
--                                        END), 0) - ISNULL(SUM(CASE
--                                                                  WHEN Cod_Libro = '14'
--                                                                  THEN C.Cantidad
--                                                              END), 0)
--                      FROM [dbo].[CAJ_COMPROBANTE_D] C
--                           INNER JOIN [dbo].[CAJ_SERIES] S ON(C.id_ComprobantePago = S.Id_Tabla
--                                                              AND c.id_Detalle = s.Item)
--                           INNER JOIN [CAJ_COMPROBANTE_PAGO] CC ON(C.id_ComprobantePago = CC.id_ComprobantePago)
--                      WHERE S.serie = @Serie
--                            AND c.Id_Producto = @Id_Producto
--                            AND [Cod_Almacen] = @Id_Almacen
--                            AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
--                  );
--                  SET @StockAlmacen =
--                  (
--                      SELECT ISNULL(SUM(CASE
--                                            WHEN Cod_TipoComprobante = 'NE'
--                                            THEN C.Cantidad
--                                        END), 0) - ISNULL(SUM(CASE
--                                                                  WHEN Cod_TipoComprobante = 'NS'
--                                                                  THEN C.Cantidad
--                                                              END), 0)
--                      FROM ALM_ALMACEN_MOV_D C
--                           INNER JOIN [dbo].[CAJ_SERIES] S ON(C.Id_AlmacenMov = S.Id_Tabla
--                                                              AND c.Item = s.Item)
--                           INNER JOIN ALM_ALMACEN_MOV CC ON(C.Id_AlmacenMov = CC.Id_AlmacenMov)
--                      WHERE S.serie = @Serie
--                            AND c.Id_Producto = @Id_Producto
--                            AND [Cod_Almacen] = @Id_Almacen
--                            AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
--                  );
--                  SET @Stock = @StockComprobante + @StockAlmacen;
--          END;
--              ELSE
--              BEGIN
--                  SET @Stock =
--                  (
--                      SELECT ISNULL(Stock_Act, 0)
--                      FROM PRI_PRODUCTO_STOCK
--                      WHERE [Id_Producto] = @Id_Producto
--                            AND [Cod_Almacen] = @Id_Almacen
--                  );
--          END;
--          RETURN @Stock;
--      END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'UFN_CAJ_LOTES_Stocks'
)
    DROP FUNCTION UFN_CAJ_LOTES_Stocks;
GO
CREATE FUNCTION UFN_CAJ_LOTES_Stocks
(@Serie AS          VARCHAR(512), 
 @Id_Producto AS    INT, 
 @Id_Almacen AS     VARCHAR(32), 
 @F_Venc         DATE, 
 @CodTipoProucto AS VARCHAR(5)
)
RETURNS INT
WITH ENCRYPTION
AS
     BEGIN
         DECLARE @Stock AS NUMERIC(38, 2);
         DECLARE @StockComprobante AS NUMERIC(38, 2);
         DECLARE @StockAlmacen AS NUMERIC(38, 2);
         IF(@CodTipoProucto = 'PRL')
             BEGIN
                 SET @StockComprobante =
                 (
                     SELECT ISNULL(SUM(CASE
                                           WHEN Cod_Libro = '08'
                                           THEN C.Cantidad
                                       END), 0) - ISNULL(SUM(CASE
                                                                 WHEN Cod_Libro = '14'
                                                                 THEN C.Cantidad
                                                             END), 0)
                     FROM [dbo].[CAJ_COMPROBANTE_D] C
                          INNER JOIN [dbo].[CAJ_SERIES] S ON(C.id_ComprobantePago = S.Id_Tabla
                                                             AND c.id_Detalle = s.Item)
                          INNER JOIN [CAJ_COMPROBANTE_PAGO] CC ON(C.id_ComprobantePago = CC.id_ComprobantePago)
                     WHERE S.serie = @Serie
                           AND c.Id_Producto = @Id_Producto
                           AND [Cod_Almacen] = @Id_Almacen
                           AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
                 );
                 SET @StockAlmacen =
                 (
                     SELECT ISNULL(SUM(CASE
                                           WHEN Cod_TipoComprobante = 'NE'
                                           THEN C.Cantidad
                                       END), 0) - ISNULL(SUM(CASE
                                                                 WHEN Cod_TipoComprobante = 'NS'
                                                                 THEN C.Cantidad
                                                             END), 0)
                     FROM ALM_ALMACEN_MOV_D C
                          INNER JOIN [dbo].[CAJ_SERIES] S ON(C.Id_AlmacenMov = S.Id_Tabla
                                                             AND c.Item = s.Item)
                          INNER JOIN ALM_ALMACEN_MOV CC ON(C.Id_AlmacenMov = CC.Id_AlmacenMov)
                     WHERE S.serie = @Serie
                           AND c.Id_Producto = @Id_Producto
                           AND [Cod_Almacen] = @Id_Almacen
                           AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
                 );
                 SET @Stock = @StockComprobante + @StockAlmacen;
         END;
             ELSE
             BEGIN
                 SET @Stock =
                 (
                     SELECT ISNULL(Stock_Act, 0)
                     FROM PRI_PRODUCTO_STOCK
                     WHERE [Id_Producto] = @Id_Producto
                           AND [Cod_Almacen] = @Id_Almacen
                 );
         END;
         RETURN @Stock;
     END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA:  4/03/2019
-- OBJETIVO: Traer la lista de productos de tipo de producto Lote
-- EXEC USP_CAJ_LOTES_X_PRODUCTO 2869,'A101'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_LOTES_X_PRODUCTO'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_LOTES_X_PRODUCTO;
GO
CREATE PROCEDURE USP_CAJ_LOTES_X_PRODUCTO @Cod_Producto AS INT, 
                                          @Cod_Almacen  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
(
    SELECT S.Serie AS Lote, 
           dbo.UFN_CAJ_LOTES_Stocks(S.Serie, PS.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Cantidad, 
           CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
           S.Obs_Serie AS Obs_Lote, 
           P.Cod_Producto AS Cod_Producto, 
           P.Nom_Producto AS 'Des_Producto', 
           A.Des_Almacen AS Des_Almacen, 
           AM.Cod_Almacen AS Cod_Almacen, 
           MD.Cod_UnidadMedida AS Cod_UnidadMedida, 
           VU.Nom_UnidadMedida, 
           Precio_Venta, 
           Cod_TipoProducto, 
           MD.Id_Producto AS IdProducto, 
           PS.Precio_Compra
    FROM PRI_PRODUCTOS AS P
         INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
         INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
         INNER JOIN ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                AND AM.Cod_Almacen = PS.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida
         RIGHT OUTER JOIN CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla
                                             AND MD.Item = S.Item
    WHERE(S.Cod_Tabla = 'ALM_ALMACEN_MOV')
         AND p.Cod_TipoProducto = 'PRL'
         AND MD.Id_Producto = @Cod_Producto
         AND AM.Cod_Almacen = @Cod_Almacen
         AND AM.Cod_TipoComprobante = 'NE'
         AND dbo.UFN_CAJ_LOTES_Stocks(S.Serie, PS.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
)
UNION
(
    SELECT S.Serie AS Lote, 
           dbo.UFN_CAJ_LOTES_Stocks(S.Serie, PS.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Cantidad, 
           CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
           S.Obs_Serie AS Obs_Lote, 
           P.Cod_Producto AS Cod_Producto, 
           P.Nom_Producto AS 'Des_Producto', 
           A.Des_Almacen AS Des_Almacen, 
           CD.Cod_Almacen AS Cod_Almacen, 
           CD.Cod_UnidadMedida AS Cod_UnidadMedida, 
           VU.Nom_UnidadMedida, 
           Precio_Venta, 
           Cod_TipoProducto, 
           CD.Id_Producto AS IdProducto, 
           PS.Precio_Compra
    FROM PRI_PRODUCTOS AS P
         INNER JOIN CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto
         INNER JOIN CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
         INNER JOIN ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                AND CD.Cod_Almacen = PS.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON CD.Cod_UnidadMedida = VU.Cod_UnidadMedida
         RIGHT OUTER JOIN CAJ_SERIES AS S ON CD.id_ComprobantePago = S.Id_Tabla
                                             AND CD.id_Detalle = S.Item
    WHERE(S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
         AND p.Cod_TipoProducto = 'PRL'
         AND CD.Id_Producto = @Cod_Producto
         AND CD.Cod_Almacen = @Cod_Almacen
         AND cp.Cod_Libro = '08'
         AND dbo.UFN_CAJ_LOTES_Stocks(S.Serie, PS.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
)
    ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) ASC;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Composicion'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Composicion;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Composicion @Buscar VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        SELECT PD.Id_Producto, 
               PD.Item_Detalle, 
               PD.Id_ProductoDetalle, 
               PD.Cod_TipoDetalle, 
               PD.Cantidad, 
               PD.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               TDP.Nom_TipoDetallePro, 
               P.Nom_Producto AS Nom_Producto, 
               P_.Nom_Producto AS Nom_Producto_com
        FROM PRI_PRODUCTO_DETALLE AS PD
             INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
             INNER JOIN PRI_PRODUCTOS AS P_ ON PD.Id_Producto = P_.Id_Producto
        WHERE(P.Cod_Producto LIKE @Buscar)
             OR (P.Nom_Producto LIKE '%' + @Buscar + '%');
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA: 18/03/2019 | 25/06/2019
-- OBJETIVO: Procedimiento que Lista los productos de acuerdo al Id_Producto
-- Procedimiento que permite buscar productos de acuerdo al parametro codigo
-- EXEC USP_PRI_PRODUCTOS_Buscar 100,'pro',null,null,'001',0
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTOS_Buscar_X_Codigo'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_X_Codigo;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_X_Codigo @Cod_Caja AS           VARCHAR(32)  = NULL, 
--                                                    @Buscar             VARCHAR(512), 
--                                                    @CodTipoProducto AS    VARCHAR(8)   = NULL, 
--                                                    @Cod_Categoria AS      VARCHAR(32)  = NULL, 
--                                                    @Cod_Precio AS         VARCHAR(32)  = NULL, 
--                                                    @Flag_RequiereStock AS BIT          = 0
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         SET DATEFORMAT DMY;
--         SELECT P.Id_Producto, 
--                P.Nom_Producto AS Nom_Producto, 
--                P.Cod_Producto, 
--                PS.Stock_Act, 
--                PS.Precio_Venta, 
--                M.Nom_Moneda AS Nom_Moneda, 
--                PS.Cod_Almacen, 
--                0 AS Descuento, 
--                'NINGUNO' AS TipoDescuento, 
--                A.Des_CortaAlmacen AS Des_Almacen, 
--                PS.Cod_UnidadMedida, 
--                UM.Nom_UnidadMedida, 
--                P.Flag_Stock, 
--                PS.Precio_Compra,
--                CASE
--                    WHEN @Cod_Precio IS NULL
--                    THEN 0
--                    ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--                END AS Precio, 
--                P.Cod_TipoOperatividad, 
--                PS.Cod_Moneda, 
--                Cod_TipoProducto AS TipoProducto
--         FROM PRI_PRODUCTOS AS P
--              INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--              INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--              INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--              INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--              INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--         WHERE(P.Cod_TipoProducto = @CodTipoProducto
--               OR @CodTipoProducto IS NULL)
--              AND (P.Id_Producto = @Buscar)
--              AND (P.Cod_Categoria IN
--         (
--             SELECT Cod_Categoria
--             FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--         )
--         OR @Cod_Categoria IS NULL)
--              AND (ca.Cod_Caja = @Cod_Caja
--                   OR @Cod_Caja IS NULL)
--              AND (P.Flag_Activo = 1)
--         -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
--         ORDER BY Nom_Producto;
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_Buscar_X_Codigo'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_X_Codigo;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_X_Codigo @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                   @Buscar             VARCHAR(512), 
                                                   @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                                   @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                                   @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                                   @Flag_RequiereStock AS BIT          = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT P.Id_Producto, 
               P.Nom_Producto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda AS Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_CortaAlmacen AS Des_Almacen, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               P.Flag_Stock, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio, 
               P.Cod_TipoOperatividad, 
               PS.Cod_Moneda, 
               Cod_TipoProducto AS TipoProducto
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
        WHERE(P.Cod_TipoProducto = @CodTipoProducto
              OR @CodTipoProducto IS NULL)
             AND (P.Id_Producto = @Buscar)
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (ca.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (P.Flag_Activo = 1)
        -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
        ORDER BY Nom_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA:  26/02/2019 | 25/06/2019
-- OBJETIVO: Metodo que traer los producto cuyo tipo es Lote
-- Procedimiento que permite Buscar los productos que contienen lote, casos que indiquen como parametro codigo de almacen o no
-- USP_PRI_PRODUCTOS_LOTE_Buscar  100,'%%',null,null,'001',0,'a101'
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTOS_LOTE_Buscar'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTOS_LOTE_Buscar;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTOS_LOTE_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
--                                                @Buscar             VARCHAR(512), 
--                                                @CodTipoProducto AS    VARCHAR(8)   = NULL, 
--                                                @Cod_Categoria AS      VARCHAR(32)  = NULL, 
--                                                @Cod_Precio AS         VARCHAR(32)  = NULL, 
--                                                @Flag_RequiereStock AS BIT          = 0, 
--                                                @Cod_Almacen AS        VARCHAR(32)
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         SET DATEFORMAT DMY;
-- (
--     SELECT P.Id_Producto, 
--            P.Nom_Producto AS Nom_Producto, 
--            P.Cod_Producto, 
--            PS.Stock_Act, 
--            PS.Precio_Venta, 
--            M.Nom_Moneda AS Nom_Moneda, 
--            PS.Cod_Almacen, 
--            0 AS Descuento, 
--            'NINGUNO' AS TipoDescuento, 
--            A.Des_CortaAlmacen AS Des_Almacen, 
--            PS.Cod_UnidadMedida, 
--            UM.Nom_UnidadMedida, 
--            P.Flag_Stock, 
--            PS.Precio_Compra,
--            CASE
--                WHEN @Cod_Precio IS NULL
--                THEN 0
--                ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--            END AS Precio, 
--            P.Cod_TipoOperatividad, 
--            PS.Cod_Moneda, 
--            Cod_TipoProducto AS TipoProducto, 
--            CS.Serie AS Lote, 
--            CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
--            P.Cod_TipoProducto, 
--            dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Stock_
--     FROM PRI_PRODUCTOS AS P
--          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--          INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--          INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--          INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--          LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
--                                               AND PS.Cod_Almacen = CD.Cod_Almacen
--                                               AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
--          LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
--          LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
--                                        AND CD.id_Detalle = CS.Item
--                                        AND CD.id_ComprobantePago = CS.Id_Tabla
--                                        AND Cod_TipoProducto = 'PRL'
--                                        AND CC.Flag_Anulado = 0)
--     WHERE(P.Cod_TipoProducto = @CodTipoProducto
--           OR @CodTipoProducto IS NULL)
--          AND ((P.Cod_Producto LIKE @Buscar)
--               OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--          AND (P.Cod_Categoria IN
--     (
--         SELECT Cod_Categoria
--         FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--     )
--     OR @Cod_Categoria IS NULL)
--          AND (ca.Cod_Caja = @Cod_Caja
--               OR @Cod_Caja IS NULL)
--          AND (P.Flag_Activo = 1)
--          AND ps.Cod_Almacen = @Cod_Almacen
--          AND CC.Cod_Libro = '08'
--          AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
--     -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	)	
-- )
-- UNION
-- (
--     SELECT P.Id_Producto, 
--            P.Nom_Producto AS Nom_Producto, 
--            P.Cod_Producto, 
--            PS.Stock_Act, 
--            PS.Precio_Venta, 
--            M.Nom_Moneda AS Nom_Moneda, 
--            PS.Cod_Almacen, 
--            0 AS Descuento, 
--            'NINGUNO' AS TipoDescuento, 
--            A.Des_CortaAlmacen AS Des_Almacen, 
--            PS.Cod_UnidadMedida, 
--            UM.Nom_UnidadMedida, 
--            P.Flag_Stock, 
--            PS.Precio_Compra,
--            CASE
--                WHEN @Cod_Precio IS NULL
--                THEN 0
--                ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--            END AS Precio, 
--            P.Cod_TipoOperatividad, 
--            PS.Cod_Moneda, 
--            Cod_TipoProducto AS TipoProducto, 
--            CS.Serie AS Lote, 
--            CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
--            P.Cod_TipoProducto, 
--            dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Stock_
--     FROM PRI_PRODUCTOS AS P
--          INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
--          INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
--          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--          INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--          INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--          INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--          LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'ALM_ALMACEN_MOV'
--                                        AND MD.Id_AlmacenMov = CS.Id_Tabla
--                                        AND MD.Item = CS.Item
--                                        AND Cod_TipoProducto = 'PRL'
--                                        AND AM.Flag_Anulado = 0)
--     WHERE(P.Cod_TipoProducto = @CodTipoProducto
--           OR @CodTipoProducto IS NULL)
--          AND ((P.Cod_Producto LIKE @Buscar)
--               OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--          AND (P.Cod_Categoria IN
--     (
--         SELECT Cod_Categoria
--         FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--     )
--     OR @Cod_Categoria IS NULL)
--          AND (ca.Cod_Caja = @Cod_Caja
--               OR @Cod_Caja IS NULL)
--          AND (P.Flag_Activo = 1)
--          AND ps.Cod_Almacen = @Cod_Almacen
--          AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
-- )
-- ORDER BY Fecha_Vencimiento DESC;
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_LOTE_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_LOTE_Buscar;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_LOTE_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                               @Buscar             VARCHAR(512), 
                                               @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                               @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                               @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                               @Flag_RequiereStock AS BIT          = 0, 
                                               @Cod_Almacen AS        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');

        IF(@Cod_Almacen != '')
            BEGIN
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           CS.Serie AS Lote, 
           CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Stock_
    FROM PRI_PRODUCTOS AS P
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                              AND PS.Cod_Almacen = CD.Cod_Almacen
                                              AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
         LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
         LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
                                       AND CD.id_Detalle = CS.Item
                                       AND CD.id_ComprobantePago = CS.Id_Tabla
                                       AND Cod_TipoProducto = 'PRL'
                                       AND CC.Flag_Anulado = 0)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND (P.Flag_Activo = 1)
         AND ps.Cod_Almacen = @Cod_Almacen
         AND CC.Cod_Libro = '08'
         AND Cod_TipoProducto = 'PRL'
         AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
        -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
        --order by  Nom_Producto,CONVERT(DATETIME,CONVERT(VARCHAR,Fecha_Vencimiento,103))	
)
UNION
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           '' AS Lote, 
           '' AS Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           0
    --dbo.UFN_CAJ_LOTES_Stocks(CS.Serie,P.Id_Producto,PS.Cod_Almacen,CONVERT(DATETIME,CONVERT(VARCHAR,Fecha_Vencimiento,103)) ,P.Cod_TipoProducto) as Stock_
    FROM PRI_PRODUCTOS AS P
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                              AND PS.Cod_Almacen = CD.Cod_Almacen
                                              AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
         LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND Cod_TipoProducto != 'PRL'
         AND (P.Flag_Activo = 1)
         AND ps.Cod_Almacen = @Cod_Almacen --AND CC.Cod_Libro='08' --and dbo.UFN_CAJ_LOTES_Stocks(CS.Serie,P.Id_Producto,PS.Cod_Almacen,CONVERT(DATETIME,CONVERT(VARCHAR,Fecha_Vencimiento,103)) ,P.Cod_TipoProducto)>0
        -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)		
)
        ORDER BY Nom_Producto, 
                 CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103));
        END;
            ELSE
            BEGIN
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           CS.Serie AS Lote, 
           Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) AS Stock_
    FROM PRI_PRODUCTOS AS P
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                              AND PS.Cod_Almacen = CD.Cod_Almacen
                                              AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
         LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
         LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
                                       AND CD.id_Detalle = CS.Item
                                       AND CD.id_ComprobantePago = CS.Id_Tabla
                                       AND Cod_TipoProducto = 'PRL'
                                       AND CC.Flag_Anulado = 0)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND (P.Flag_Activo = 1)
         AND CC.Cod_Libro = '08'
         AND Cod_TipoProducto = 'PRL'
         AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
)-- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
UNION
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           '' AS Lote, 
           '' AS Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           0
    --dbo.UFN_CAJ_LOTES_Stocks(CS.Serie,P.Id_Producto,PS.Cod_Almacen,CONVERT(DATETIME,CONVERT(VARCHAR,Fecha_Vencimiento,103)) ,P.Cod_TipoProducto) as Stock_
    FROM PRI_PRODUCTOS AS P
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                              AND PS.Cod_Almacen = CD.Cod_Almacen
                                              AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
         LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND Cod_TipoProducto != 'PRL'
         AND (P.Flag_Activo = 1)
         AND ps.Cod_Almacen = @Cod_Almacen --AND CC.Cod_Libro='08' --and dbo.UFN_CAJ_LOTES_Stocks(CS.Serie,P.Id_Producto,PS.Cod_Almacen,CONVERT(DATETIME,CONVERT(VARCHAR,Fecha_Vencimiento,103)) ,P.Cod_TipoProducto)>0
    -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)		
)
    ORDER BY Nom_Producto, 
             Fecha_Vencimiento;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA: 20/03/2019 | 25/06/2019
-- OBJETIVO: Procedimiento que permite buscar al producto segun su serie 
-- Procedimiento que permite buscar un producto con serie asi como productos que no son tipo de producto serie
-- USP_PRI_PRODUCTOS_X_SERIE_Buscar 100,'1234',null,null,'001',0,'A101'
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTOS_X_SERIE_Buscar'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTOS_X_SERIE_Buscar;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTOS_X_SERIE_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
--                                                   @Buscar             VARCHAR(512), 
--                                                   @CodTipoProducto AS    VARCHAR(8)   = NULL, 
--                                                   @Cod_Categoria AS      VARCHAR(32)  = NULL, 
--                                                   @Cod_Precio AS         VARCHAR(32)  = NULL, 
--                                                   @Flag_RequiereStock AS BIT          = 0, 
--                                                   @Cod_Almacen AS        VARCHAR(32)
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         SET DATEFORMAT DMY;
-- (
--     SELECT P.Id_Producto, 
--            P.Nom_Producto AS Nom_Producto, 
--            P.Cod_Producto, 
--            PS.Stock_Act, 
--            PS.Precio_Venta, 
--            M.Nom_Moneda AS Nom_Moneda, 
--            PS.Cod_Almacen, 
--            0 AS Descuento, 
--            'NINGUNO' AS TipoDescuento, 
--            A.Des_CortaAlmacen AS Des_Almacen, 
--            PS.Cod_UnidadMedida, 
--            UM.Nom_UnidadMedida, 
--            P.Flag_Stock, 
--            PS.Precio_Compra,
--            CASE
--                WHEN @Cod_Precio IS NULL
--                THEN 0
--                ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--            END AS Precio, 
--            P.Cod_TipoOperatividad, 
--            PS.Cod_Moneda, 
--            Cod_TipoProducto AS TipoProducto, 
--            CS.Serie AS Serie, 
--            CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
--            P.Cod_TipoProducto, 
--            Obs_Serie
--     FROM PRI_PRODUCTOS AS P
--          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--          INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--          INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--          INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--          LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
--                                               AND PS.Cod_Almacen = CD.Cod_Almacen
--                                               AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
--          LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
--          LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
--                                        AND CD.id_Detalle = CS.Item
--                                        AND CD.id_ComprobantePago = CS.Id_Tabla
--                                        AND Cod_TipoProducto = 'PRS'
--                                        AND CC.Flag_Anulado = 0)
--     WHERE(P.Cod_TipoProducto = @CodTipoProducto
--           OR @CodTipoProducto IS NULL)
--          AND ((P.Cod_Producto LIKE @Buscar)
--               OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--          OR cs.Serie = @Buscar
--          AND (P.Cod_Categoria IN
--     (
--         SELECT Cod_Categoria
--         FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--     )
--     OR @Cod_Categoria IS NULL)
--          AND (ca.Cod_Caja = @Cod_Caja
--               OR @Cod_Caja IS NULL)
--          AND (P.Flag_Activo = 1)
--          AND ps.Cod_Almacen = @Cod_Almacen
--          AND CC.Cod_Libro = '08'
--          AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
--         -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	)	
-- )
-- UNION
-- (
--     SELECT P.Id_Producto, 
--            P.Nom_Producto AS Nom_Producto, 
--            P.Cod_Producto, 
--            PS.Stock_Act, 
--            PS.Precio_Venta, 
--            M.Nom_Moneda AS Nom_Moneda, 
--            PS.Cod_Almacen, 
--            0 AS Descuento, 
--            'NINGUNO' AS TipoDescuento, 
--            A.Des_CortaAlmacen AS Des_Almacen, 
--            PS.Cod_UnidadMedida, 
--            UM.Nom_UnidadMedida, 
--            P.Flag_Stock, 
--            PS.Precio_Compra,
--            CASE
--                WHEN @Cod_Precio IS NULL
--                THEN 0
--                ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--            END AS Precio, 
--            P.Cod_TipoOperatividad, 
--            PS.Cod_Moneda, 
--            Cod_TipoProducto AS TipoProducto, 
--            CS.Serie AS Serie, 
--            CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
--            P.Cod_TipoProducto, 
--            Obs_Serie
--     FROM PRI_PRODUCTOS AS P
--          INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
--          INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
--          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--          INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--          INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--          INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--          LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'ALM_ALMACEN_MOV'
--                                        AND MD.Id_AlmacenMov = CS.Id_Tabla
--                                        AND MD.Item = CS.Item
--                                        AND Cod_TipoProducto = 'PRS'
--                                        AND AM.Flag_Anulado = 0)
--     WHERE(P.Cod_TipoProducto = @CodTipoProducto
--           OR @CodTipoProducto IS NULL)
--          AND ((P.Cod_Producto LIKE @Buscar)
--               OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--          OR cs.Serie = @Buscar
--          AND (P.Cod_Categoria IN
--     (
--         SELECT Cod_Categoria
--         FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--     )
--     OR @Cod_Categoria IS NULL)
--          AND (ca.Cod_Caja = @Cod_Caja
--               OR @Cod_Caja IS NULL)
--          AND (P.Flag_Activo = 1)
--          AND ps.Cod_Almacen = @Cod_Almacen
--          AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
-- )
--     ORDER BY Fecha_Vencimiento DESC;
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_X_SERIE_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_X_SERIE_Buscar;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_X_SERIE_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                  @Buscar             VARCHAR(512), 
                                                  @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                                  @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                                  @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                                  @Flag_RequiereStock AS BIT          = 0, 
                                                  @Cod_Almacen AS        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           CS.Serie AS Serie, 
           CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           Obs_Serie
    FROM PRI_PRODUCTOS AS P
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                              AND PS.Cod_Almacen = CD.Cod_Almacen
                                              AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
         LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
         LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
                                       AND CD.id_Detalle = CS.Item
                                       AND CD.id_ComprobantePago = CS.Id_Tabla
                                       AND Cod_TipoProducto = 'PRS'
                                       AND CC.Flag_Anulado = 0)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         OR cs.Serie = @Buscar
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND (P.Flag_Activo = 1)
         AND ps.Cod_Almacen = @Cod_Almacen
         AND CC.Cod_Libro = '08'
         AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
        -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	)	
)
UNION
(
    SELECT P.Id_Producto, 
           P.Nom_Producto AS Nom_Producto, 
           P.Cod_Producto, 
           PS.Stock_Act, 
           PS.Precio_Venta, 
           M.Nom_Moneda AS Nom_Moneda, 
           PS.Cod_Almacen, 
           0 AS Descuento, 
           'NINGUNO' AS TipoDescuento, 
           A.Des_CortaAlmacen AS Des_Almacen, 
           PS.Cod_UnidadMedida, 
           UM.Nom_UnidadMedida, 
           P.Flag_Stock, 
           PS.Precio_Compra,
           CASE
               WHEN @Cod_Precio IS NULL
               THEN 0
               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
           END AS Precio, 
           P.Cod_TipoOperatividad, 
           PS.Cod_Moneda, 
           Cod_TipoProducto AS TipoProducto, 
           CS.Serie AS Serie, 
           CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
           P.Cod_TipoProducto, 
           Obs_Serie
    FROM PRI_PRODUCTOS AS P
         INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
         INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
         LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'ALM_ALMACEN_MOV'
                                       AND MD.Id_AlmacenMov = CS.Id_Tabla
                                       AND MD.Item = CS.Item
                                       AND Cod_TipoProducto = 'PRS'
                                       AND AM.Flag_Anulado = 0)
    WHERE(P.Cod_TipoProducto = @CodTipoProducto
          OR @CodTipoProducto IS NULL)
         AND ((P.Cod_Producto LIKE @Buscar)
              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
         OR cs.Serie = @Buscar
         AND (P.Cod_Categoria IN
    (
        SELECT Cod_Categoria
        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
    )
    OR @Cod_Categoria IS NULL)
         AND (ca.Cod_Caja = @Cod_Caja
              OR @Cod_Caja IS NULL)
         AND (P.Flag_Activo = 1)
         AND ps.Cod_Almacen = @Cod_Almacen
         AND dbo.UFN_CAJ_LOTES_Stocks(CS.Serie, P.Id_Producto, PS.Cod_Almacen, CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)), P.Cod_TipoProducto) > 0
)
    ORDER BY Fecha_Vencimiento DESC;
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
               VTC.Cod_Sunat AS Cod_TipoComprobante, 
               CPR.Serie + '-' + CPR.Numero AS Comprobante
        FROM CAJ_COMPROBANTE_RELACION AS CR
             INNER JOIN CAJ_GUIA_REMISION_REMITENTE AS CPR ON CR.Id_ComprobanteRelacion = CPR.Id_GuiaRemisionRemitente
             INNER JOIN VIS_TIPO_COMPROBANTES AS VTC ON CPR.Cod_TipoComprobante = VTC.Cod_TipoComprobante
        WHERE cr.Cod_TipoRelacion IN('GRT', 'GUR')
             AND cr.id_ComprobantePago = @id_ComprobantePago;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 18/09/2018 ------ !!!		ACTUALIZARRRR URGENTE !!!!!!
-- OBJETIVO: Selecionar Mesas
-- EXEC USP_VIS_MESAS_TT 'M19'
-- select * from CAJ_COMPROBANTE_D where Cod_Manguera = 'M19' order by Fecha_Reg desc
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_MESAS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_MESAS_TT;
GO
CREATE PROCEDURE USP_VIS_MESAS_TT @Cod_Ambiente AS VARCHAR(64)
WITH ENCRYPTION
AS
    BEGIN
        SELECT VM.Cod_Mesa, 
               VM.Nom_Mesa, 
               VM.Estado_Mesa, 
               VM.Estado, 
        (
            SELECT COUNT(X.id_ComprobantePago)
            FROM
            (
                SELECT DISTINCT 
                       CP.id_ComprobantePago
                FROM CAJ_COMPROBANTE_PAGO CP
                     INNER JOIN CAJ_COMPROBANTE_D CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                                                        AND (CD.Cantidad - CD.Formalizado) > 0
                WHERE CD.Cod_Manguera = VM.Cod_Mesa
                      AND CD.Cantidad > 0
            ) X
        ) AS Nro_Cuentas, 
               ISNULL(
        (
            SELECT TOP 1 CP.Cod_UsuarioAct
            FROM CAJ_COMPROBANTE_PAGO CP
                 INNER JOIN CAJ_COMPROBANTE_D CD ON CP.id_ComprobantePago = CD.id_ComprobantePago
                                                    AND CP.Flag_Despachado = 0
            WHERE CD.Cod_Manguera = VM.Cod_Mesa
            ORDER BY CP.id_ComprobantePago DESC
        ), '') AS Mesero
        FROM VIS_MESAS VM
        WHERE Estado = 1
              AND Cod_Ambiente = @Cod_Ambiente; --Se categoriza por ambiente
    END;
GO
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_G_Comanda_MOVIL'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G_Comanda_MOVIL;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G_Comanda_MOVIL @Numero           VARCHAR(30), 
                                                          @id_Detalle       INT, 
                                                          @Id_Producto      INT, 
                                                          @Cod_Almacen      VARCHAR(32), 
                                                          @Cantidad         NUMERIC(38, 6), 
                                                          @Descripcion      VARCHAR(MAX), 
                                                          @PrecioUnitario   NUMERIC(38, 6), 
                                                          @Sub_Total        NUMERIC(38, 2), 
                                                          @Tipo             VARCHAR(256), 
                                                          @Obs_ComprobanteD VARCHAR(1024), 
                                                          @Cod_Mesa         VARCHAR(32),
                                                          --Nuevos
                                                          @Id_Referencia    NUMERIC(38, 2), 
                                                          @Estado_Pedido    VARCHAR(8), 
                                                          @Cod_Usuario      VARCHAR(32)    = 'COMANDERO'
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @id_ComprobantePago INT= 0, @Cod_UnidadMedida VARCHAR(5)= 'NIU', @Despachado NUMERIC(38, 6)= @Cantidad, @Descuento NUMERIC(38, 2)= 0.00, @Flag_AplicaImpuesto BIT= 0, @Formalizado NUMERIC(38, 6)= 0.00, @Valor_NoOneroso NUMERIC(38, 2)= 0.00, @Cod_TipoISC VARCHAR= NULL, @Porcentaje_ISC NUMERIC(38, 2)= 0.00, @ISC NUMERIC(38, 2)= 0.00, @Cod_TipoIGV VARCHAR= NULL, @Porcentaje_IGV NUMERIC(38, 2)= 0.00, @IGV NUMERIC(38, 2)= 0.00;
        SET @id_ComprobantePago = ISNULL(
        (
            SELECT TOP 1 ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE(Cod_Libro = ''
                  AND Cod_TipoComprobante = 'CO'
                  AND Serie = '0000'
                  AND Numero = @Numero)
        ), 0);

        --IF @id_Detalle = 0
        --DELETE FROM CAJ_COMPROBANTE_D WHERE id_ComprobantePago = @id_ComprobantePago
        -- NUMERAR DE UNO
        --SET @id_Detalle = (SELECT ISNULL(COUNT(*),1) FROM CAJ_COMPROBANTE_D WHERE id_ComprobantePago = @id_ComprobantePago)

        IF NOT EXISTS
        (
            SELECT @id_ComprobantePago, 
                   @id_Detalle
            FROM CAJ_COMPROBANTE_D
            WHERE(id_ComprobantePago = @id_ComprobantePago)
                 AND (id_Detalle = @id_Detalle)
        )
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_D
                VALUES
                (@id_ComprobantePago, 
                 @id_Detalle, 
                 @Id_Producto, 
                 @Cod_Almacen, 
                 @Cantidad, 
                 @Cod_UnidadMedida, 
                 @Despachado, 
                 @Descripcion, 
                 @PrecioUnitario, 
                 @Descuento, 
                 @Sub_Total, 
                 @Tipo, 
                 @Obs_ComprobanteD, 
                 @Cod_Mesa, 
                 @Flag_AplicaImpuesto, 
                 @Formalizado, 
                 @Valor_NoOneroso, 
                 @Estado_Pedido, 
                 @Porcentaje_ISC, 
                 @ISC, 
                 @Cod_TipoIGV, 
                 @Porcentaje_IGV, 
                 @Id_Referencia, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_COMPROBANTE_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cantidad = @Cantidad, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Despachado = @Despachado, 
                      Descripcion = @Descripcion, 
                      PrecioUnitario = @PrecioUnitario, 
                      Descuento = @Descuento, 
                      Sub_Total = @Sub_Total, 
                      Tipo = @Tipo, 
                      Obs_ComprobanteD = @Obs_ComprobanteD, 
                      Cod_Manguera = @Cod_Mesa, 
                      Flag_AplicaImpuesto = @Flag_AplicaImpuesto, 
                      Formalizado = @Formalizado, 
                      Valor_NoOneroso = @Valor_NoOneroso, 
                      Cod_TipoISC = @Estado_Pedido, 
                      Porcentaje_ISC = @Porcentaje_ISC, 
                      ISC = @ISC, 
                      Cod_TipoIGV = @Cod_TipoIGV, 
                      Porcentaje_IGV = @Porcentaje_IGV, 
                      IGV = @Id_Referencia, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago)
                     AND (id_Detalle = @id_Detalle);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 18/09/2018 ------ !!!		ACTUALIZARRRR URGENTE !!!!!!
-- OBJETIVO: Seleccionar los pedidos de una mesa
-- EXEC USP_CAJ_COMANDA_TXCodMesa 'M03'
--------------------------------------------------------------------------------------------------------------984012613

IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMANDA_TXCodMesa'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMANDA_TXCodMesa;
GO
CREATE PROCEDURE USP_CAJ_COMANDA_TXCodMesa @Cod_Mesa VARCHAR(32)
AS
    BEGIN
        SELECT CPD.Id_Producto, 
               CPD.id_Detalle AS Id_Detalle, 
               CPD.IGV Id_Referencia, 
               CP.Numero, 
               CPD.Tipo AS Cod_TipoOperatividad, 
               CPD.Cod_Almacen, 
               CPD.Descripcion AS Nom_Producto, 
               CPD.Cantidad, 
               CPD.Cod_Manguera AS Cod_Mesa, 
               CPD.PrecioUnitario, 
               CPD.Cod_TipoISC Estado_Pedido, 
               CP.Total
        FROM CAJ_COMPROBANTE_D AS CPD
             INNER JOIN CAJ_COMPROBANTE_PAGO CP ON CPD.id_ComprobantePago = CP.id_ComprobantePago
        WHERE CPD.Cod_Manguera = @Cod_Mesa
              AND (CPD.Cantidad - CPD.Formalizado) > 0
              AND CPD.Cantidad > 0
        ORDER BY Numero;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 24/03/2018
-- OBJETIVO: Actualizar la Mesa y su estado
-- EXEC USP_CAJ_COMPROBANTE_PAGO_G_Comanda_2 '00000006','M01','OCUPADO' USP_CAJ_COMPROBANTE_D_COMANDA_G_2
--------------------------------------------------------------------------------------------------------------

IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_G_Comanda_2'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G_Comanda_2;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_G_Comanda_2 @Numero      VARCHAR(30), 
                                                      @Nom_Cliente VARCHAR(512), 
                                                      @Cod_Moneda  VARCHAR(3), 
                                                      @Total       NUMERIC(38, 2), 
                                                      @Cod_Usuario VARCHAR(32)    = 'COMANDERO'
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @id_ComprobantePago INT= 0, @Cod_Libro VARCHAR(2)= '14', @FechaEmision DATETIME= GETDATE(), @Cod_Periodo VARCHAR= '', @Cod_Caja VARCHAR(32)= NULL, @Cod_Turno VARCHAR(32)= NULL, @Cod_TipoOperacion VARCHAR(5)= '01', @Cod_TipoComprobante VARCHAR(5)= 'CO', @Serie VARCHAR(5)= '0000', @Id_Cliente INT= 0, @Cod_TipoDoc VARCHAR(2)= '0', @Doc_Cliente VARCHAR(20)= '', @Direccion_Cliente VARCHAR(512)= '', @FechaVencimiento DATETIME= GETDATE(), @FechaCancelacion DATETIME= GETDATE(), @Glosa VARCHAR(512)= 'COMANDA', @TipoCambio NUMERIC(10, 4)= 1, @Flag_Anulado BIT= 0, @Flag_Despachado BIT= 0, @Cod_FormaPago VARCHAR(5)= '004', @Descuento_Total NUMERIC(38, 2)= 0.00, @Impuesto NUMERIC(38, 6)= 0.00, @Obs_Comprobante XML= NULL, @Id_GuiaRemision INT= 0, @GuiaRemision VARCHAR(50)= '', @id_ComprobanteRef INT= 0, @Cod_Plantilla VARCHAR(32)= '', @Nro_Ticketera VARCHAR(64)= '', @Cod_UsuarioVendedor VARCHAR(32)= '', @Cod_RegimenPercepcion VARCHAR= NULL, @Tasa_Percepcion NUMERIC(38, 2)= 0.00, @Placa_Vehiculo VARCHAR(64)= '', @Cod_TipoDocReferencia VARCHAR= NULL, @Nro_DocReferencia VARCHAR(64)= '', @Valor_Resumen VARCHAR(1024)= NULL, @Valor_Firma VARCHAR(2048)= NULL, @Cod_EstadoComprobante VARCHAR= 'INI', @MotivoAnulacion VARCHAR(512)= '', @Otros_Cargos NUMERIC(38, 2)= 0.00, @Otros_Tributos NUMERIC(38, 2)= 0.00;

        -- recuperar el cliente
        IF @Nom_Cliente = ''
            BEGIN
                -- SELECIONAR CLIENTES VARIOS
                SET @Id_Cliente =
                (
                    SELECT TOP 1 Id_ClienteProveedor
                    FROM PRI_CLIENTE_PROVEEDOR
                    WHERE Cliente = 'CLIENTES VARIOS'
                );
                SET @Doc_Cliente =
                (
                    SELECT TOP 1 Nro_Documento
                    FROM PRI_CLIENTE_PROVEEDOR
                    WHERE Cliente = 'CLIENTES VARIOS'
                );
                SET @Direccion_Cliente =
                (
                    SELECT TOP 1 Direccion
                    FROM PRI_CLIENTE_PROVEEDOR
                    WHERE Cliente = 'CLIENTES VARIOS'
                );
                SET @Nom_Cliente = 'CLIENTES VARIOS';
        END;
            ELSE
            BEGIN
                IF(EXISTS
                (
                    SELECT TOP 1 Id_ClienteProveedor
                    FROM PRI_CLIENTE_PROVEEDOR
                    WHERE Cliente = @Nom_Cliente
                ))
                    BEGIN
                        SET @Id_Cliente =
                        (
                            SELECT TOP 1 Id_ClienteProveedor
                            FROM PRI_CLIENTE_PROVEEDOR
                            WHERE Cliente = @Nom_Cliente
                        );
                        SET @Doc_Cliente =
                        (
                            SELECT TOP 1 Nro_Documento
                            FROM PRI_CLIENTE_PROVEEDOR
                            WHERE Cliente = @Nom_Cliente
                        );
                        SET @Direccion_Cliente =
                        (
                            SELECT TOP 1 Direccion
                            FROM PRI_CLIENTE_PROVEEDOR
                            WHERE Cliente = @Nom_Cliente
                        );
                END;
        END;
        IF CONVERT(NVARCHAR(MAX), ISNULL(@Obs_Comprobante, '')) = ''
            BEGIN
                SET @Obs_Comprobante = dbo.UFN_VIS_DIAGRAMAS_XML_XTabla('CAJ_COMPROBANTE_PAGO');
        END;
        IF(@Numero = ''
           AND @Cod_Libro = '14')
            BEGIN
                SET @Numero =
                (
                    SELECT RIGHT('00000000' + CONVERT(VARCHAR(38), ISNULL(CONVERT(BIGINT, MAX(Numero)), 0) + 1), 8)
                    FROM CAJ_COMPROBANTE_PAGO
                    WHERE Cod_TipoComprobante = @Cod_TipoComprobante
                          AND Serie = @Serie
                          AND Cod_Libro = @Cod_Libro
                );
        END;
        SET @id_ComprobantePago = 0;
        SET @id_ComprobantePago = ISNULL(
        (
            SELECT TOP 1 ISNULL(id_ComprobantePago, 0)
            FROM CAJ_COMPROBANTE_PAGO
            WHERE(--Cod_Libro = @Cod_Libro 
            Cod_TipoComprobante = @Cod_TipoComprobante
            AND Serie = @Serie
            AND Numero = @Numero)
        ), 0);
        IF @id_ComprobantePago = 0
            BEGIN
                INSERT INTO CAJ_COMPROBANTE_PAGO
                VALUES
                (@Cod_Libro, 
                 @Cod_Periodo, 
                 @Cod_Caja, 
                 @Cod_Turno, 
                 @Cod_TipoOperacion, 
                 @Cod_TipoComprobante, 
                 @Serie, 
                 @Numero, 
                 @Id_Cliente, 
                 @Cod_TipoDoc, 
                 @Doc_Cliente, 
                 @Nom_Cliente, 
                 @Direccion_Cliente, 
                 @FechaEmision, 
                 @FechaVencimiento, 
                 @FechaCancelacion, 
                 @Glosa, 
                 @TipoCambio, 
                 @Flag_Anulado, 
                 @Flag_Despachado, 
                 @Cod_FormaPago, 
                 @Descuento_Total, 
                 @Cod_Moneda, 
                 @Impuesto, 
                 @Total, 
                 @Obs_Comprobante, 
                 @Id_GuiaRemision, 
                 @GuiaRemision, 
                 @id_ComprobanteRef, 
                 @Cod_Plantilla, 
                 @Nro_Ticketera, 
                 @Cod_UsuarioVendedor, 
                 @Cod_RegimenPercepcion, 
                 @Tasa_Percepcion, 
                 @Placa_Vehiculo, 
                 @Cod_TipoDocReferencia, 
                 @Nro_DocReferencia, 
                 @Valor_Resumen, 
                 @Valor_Firma, 
                 @Cod_EstadoComprobante, 
                 @MotivoAnulacion, 
                 @Otros_Cargos, 
                 @Otros_Tributos, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 @Cod_Usuario, 
                 NULL
                );
                SET @id_ComprobantePago = @@IDENTITY;
        END;
            ELSE
            BEGIN
                DELETE FROM CAJ_COMPROBANTE_RELACION
                WHERE id_ComprobantePago = @id_ComprobantePago;
                DELETE FROM CAJ_COMPROBANTE_D
                WHERE id_ComprobantePago = @id_ComprobantePago; --AND Cod_TipoISC = 'PENDI'

                UPDATE CAJ_COMPROBANTE_PAGO
                  SET 
                      Cod_Libro = @Cod_Libro, 
                      Cod_Periodo = @Cod_Periodo, 
                      Cod_Caja = @Cod_Caja, 
                      Cod_Turno = @Cod_Turno, 
                      Cod_TipoOperacion = @Cod_TipoOperacion, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Serie = @Serie, 
                      Numero = @Numero, 
                      Id_Cliente = @Id_Cliente, 
                      Cod_TipoDoc = @Cod_TipoDoc, 
                      Doc_Cliente = @Doc_Cliente, 
                      Nom_Cliente = @Nom_Cliente, 
                      Direccion_Cliente = @Direccion_Cliente, 
                      FechaEmision = @FechaEmision, 
                      FechaVencimiento = @FechaVencimiento, 
                      FechaCancelacion = @FechaCancelacion, 
                      Glosa = @Glosa, 
                      TipoCambio = @TipoCambio, 
                      Flag_Anulado = @Flag_Anulado, 
                      Flag_Despachado = @Flag_Despachado, 
                      Cod_FormaPago = @Cod_FormaPago, 
                      Descuento_Total = @Descuento_Total, 
                      Cod_Moneda = @Cod_Moneda, 
                      Impuesto = @Impuesto, 
                      Total = @Total, 
                      Obs_Comprobante = @Obs_Comprobante, 
                      Id_GuiaRemision = @Id_GuiaRemision, 
                      GuiaRemision = @GuiaRemision, 
                      id_ComprobanteRef = @id_ComprobanteRef, 
                      Cod_Plantilla = @Cod_Plantilla, 
                      Nro_Ticketera = @Nro_Ticketera, 
                      Cod_RegimenPercepcion = @Cod_RegimenPercepcion, 
                      Tasa_Percepcion = @Tasa_Percepcion, 
                      Placa_Vehiculo = @Placa_Vehiculo, 
                      Cod_TipoDocReferencia = @Cod_TipoDocReferencia, 
                      Nro_DocReferencia = @Nro_DocReferencia, 
                      Valor_Resumen = @Valor_Resumen, 
                      Valor_Firma = @Valor_Firma, 
                      Cod_EstadoComprobante = @Cod_EstadoComprobante, 
                      MotivoAnulacion = @MotivoAnulacion, 
                      Otros_Cargos = @Otros_Cargos, 
                      Otros_Tributos = @Otros_Tributos, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(id_ComprobantePago = @id_ComprobantePago);
        END;
        SELECT @Numero AS Numero;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 10/09/2018 ------
-- OBJETIVO: Seleccionar los pedidos de una mesa
-- EXEC USP_COD_AMBIENTE_MESA 'M01'
--------------------------------------------------------------------------------------------------------------984012613
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_COD_AMBIENTE_MESA'
          AND type = 'P'
)
    DROP PROCEDURE USP_COD_AMBIENTE_MESA;
GO
CREATE PROCEDURE USP_COD_AMBIENTE_MESA @Cod_Mesa VARCHAR(32)
AS
    BEGIN
        SELECT Cod_Ambiente
        FROM VIS_MESAS
        WHERE Cod_Mesa = @Cod_Mesa;
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 10/09/2018 ------
-- OBJETIVO: Traer el id_Comprobante por el Numero
-- EXEC USP_ID_COMPROBANTE_BY_NUMERO '000007'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ID_COMPROBANTE_BY_NUMERO'
          AND type = 'P'
)
    DROP PROCEDURE USP_ID_COMPROBANTE_BY_NUMERO;
GO
CREATE PROCEDURE USP_ID_COMPROBANTE_BY_NUMERO @Numero VARCHAR(30)
AS
    BEGIN
        SELECT TOP 1 ISNULL(id_ComprobantePago, 0) Id_Comprobante
        FROM CAJ_COMPROBANTE_PAGO
        WHERE(Cod_TipoComprobante = 'CO'
              AND Serie = '0000'
              AND Numero = @Numero);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: JOSUE FARFAN
-- FECHA: 10/09/2018 ------
-- OBJETIVO: Traer verificacion del Pin, devuelve Cod_Usuarios y Nick
-- EXEC USP_VERIFICACION_PIN '1234'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VERIFICACION_PIN'
          AND type = 'P'
)
    DROP PROCEDURE USP_VERIFICACION_PIN;
GO
CREATE PROCEDURE USP_VERIFICACION_PIN @PIN VARCHAR(4)
AS
    BEGIN
        SELECT Cod_Usuarios, 
               Nick
        FROM PRI_USUARIO
        WHERE Pregunta = 'PIN'
              AND Respuesta = @PIN;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_PRECIO_PermutarXCodAlmacenCodTipoPrecio'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_PermutarXCodAlmacenCodTipoPrecio;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_PermutarXCodAlmacenCodTipoPrecio @Cod_Almacen    VARCHAR(32), 
                                                                          @Cod_TipoPrecio VARCHAR(5), 
                                                                          @Cod_Usuario    VARCHAR(32)
AS
    BEGIN
        --Se permuta todos los productos activos por cada unidad de medida de pri_producto_precio
        DECLARE @Cod_UnidadMedida VARCHAR(5);
        DECLARE @Id_Producto INT;
        DECLARE Cursor_Productos CURSOR LOCAL
        FOR SELECT DISTINCT 
                   pp.Id_Producto
            FROM dbo.PRI_PRODUCTOS pp
            WHERE pp.Flag_Activo = 1;
        OPEN Cursor_Productos;
        FETCH NEXT FROM Cursor_Productos INTO @Id_Producto;
        WHILE(@@FETCH_STATUS = 0)
            BEGIN

                --Recorremos todas las unidades de medida del producto con dicho almacen y dicho precio
                DECLARE Cursor_UnidadesMedida CURSOR LOCAL
                FOR SELECT DISTINCT 
                           ppp.Cod_UnidadMedida
                    FROM dbo.PRI_PRODUCTO_PRECIO ppp
                    WHERE ppp.Cod_Almacen = @Cod_Almacen
                          AND ppp.Cod_TipoPrecio = '001'
                          AND ppp.Id_Producto = @Id_Producto;
                OPEN Cursor_UnidadesMedida;
                FETCH NEXT FROM Cursor_UnidadesMedida INTO @Cod_UnidadMedida;
                WHILE(@@FETCH_STATUS = 0)
                    BEGIN
                        IF NOT EXISTS
                        (
                            SELECT ppp.*
                            FROM dbo.PRI_PRODUCTO_PRECIO ppp
                            WHERE ppp.Id_Producto = @Id_Producto
                                  AND ppp.Cod_UnidadMedida = @Cod_UnidadMedida
                                  AND ppp.Cod_Almacen = @Cod_Almacen
                                  AND ppp.Cod_TipoPrecio = @Cod_TipoPrecio
                        )
                            BEGIN
                                SELECT @Id_Producto, 
                                       @Cod_UnidadMedida, 
                                       @Cod_Almacen, 
                                       @Cod_TipoPrecio;
                                INSERT INTO dbo.PRI_PRODUCTO_PRECIO
                                VALUES
                                (@Id_Producto, -- Id_Producto - int
                                 @Cod_UnidadMedida, -- Cod_UnidadMedida - varchar
                                 @Cod_Almacen, -- Cod_Almacen - varchar
                                 @Cod_TipoPrecio, -- Cod_TipoPrecio - varchar
                                 0, -- Valor - numeric
                                 @Cod_Usuario, -- Cod_UsuarioReg - varchar
                                 GETDATE(), -- Fecha_Reg - datetime
                                 NULL, -- Cod_UsuarioAct - varchar
                                 NULL -- Fecha_Act - datetime
                                );
                        END;
                        FETCH NEXT FROM Cursor_UnidadesMedida INTO @Cod_UnidadMedida;
                    END;
                CLOSE Cursor_UnidadesMedida;
                DEALLOCATE Cursor_UnidadesMedida;
                FETCH NEXT FROM Cursor_Productos INTO @Id_Producto;
            END;
        CLOSE Cursor_Productos;
        DEALLOCATE Cursor_Productos;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_STOCK_XPrecioAlmacenMarcaAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_XPrecioAlmacenMarcaAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_XPrecioAlmacenMarcaAlmacen @Cod_TipoPrecio VARCHAR(5), 
                                                                   @Cod_Almacen    VARCHAR(32), 
                                                                   @Cod_Marca      VARCHAR(32) = NULL, 
                                                                   @Cod_Categoria  VARCHAR(32) = NULL
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            pp.Id_Producto, 
            pps.Cod_UnidadMedida, 
            pp.Cod_Producto, 
            pp.Nom_Producto, 
            vudm.Nom_UnidadMedida, 
            pps.Cod_Almacen, 
            aa.Des_Almacen, 
            pps.Precio_Compra, 
            pps.Precio_Venta Flete, 
            ppp.Valor Precio_Venta,
            CASE
                WHEN pps.Precio_Compra + pps.Precio_Venta > 0
                THEN ppp.Valor - (pps.Precio_Compra + pps.Precio_Venta)
                ELSE 0.000000
            END Utilidad_Neta,
            CASE
                WHEN pe.Flag_ExoneradoImpuesto = 1
                     AND pp.Cod_TipoOperatividad = 'GRA'
                THEN((ppp.Valor * 100) / (pe.Por_Impuesto + 100)) - (((pps.Precio_Compra + pps.Precio_Venta) * 100) / (pe.Por_Impuesto + 100))
                ELSE ppp.Valor - (pps.Precio_Compra + pps.Precio_Venta)
            END Utilidad_Bruta,
            CASE
                WHEN pps.Precio_Compra + pps.Precio_Venta > 0
                THEN 100 * (ppp.Valor - (pps.Precio_Compra + pps.Precio_Venta)) / (pps.Precio_Compra + pps.Precio_Venta)
                ELSE 0.000000
            END Por_Utilidad, 
            0.000000 Precio_Actual, 
            0.000000 Utilidad_Neta_Actual, 
            0.000000 Utilidad_Bruta_Actual, 
            0.000000 Por_Utilidad_NetaActual
     FROM dbo.PRI_PRODUCTOS pp
          INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
          INNER JOIN dbo.PRI_PRODUCTO_PRECIO ppp ON pps.Id_Producto = ppp.Id_Producto
                                                    AND pps.Cod_UnidadMedida = ppp.Cod_UnidadMedida
                                                    AND pps.Cod_Almacen = ppp.Cod_Almacen
          INNER JOIN dbo.VIS_UNIDADES_DE_MEDIDA vudm ON pps.Cod_UnidadMedida = vudm.Cod_UnidadMedida
          INNER JOIN dbo.ALM_ALMACEN aa ON pps.Cod_Almacen = aa.Cod_Almacen
          CROSS JOIN dbo.PRI_EMPRESA pe
     WHERE pps.Cod_Almacen = @Cod_Almacen
           AND ppp.Cod_TipoPrecio = @Cod_TipoPrecio
           AND (@Cod_Marca IS NULL
                OR pp.Cod_Marca = @Cod_Marca)
           AND (@Cod_Categoria IS NULL
                OR pp.Cod_Categoria = @Cod_Categoria)
           AND pp.Flag_Activo = 1
     ORDER BY pp.Nom_Producto;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerDetallesXIdComprobante @IdComprobantePago INT
AS
    BEGIN
        SELECT DISTINCT 
               ccd.id_ComprobantePago, 
               ccd.id_Detalle, 
               ccd.Id_Producto, 
               ccd.Cod_Almacen, 
               ccd.Cantidad, 
               ccd.Cod_UnidadMedida, 
               ccd.Despachado, 
               ccd.Descripcion, 
               ccd.PrecioUnitario, 
               ccd.Descuento, 
               ccd.Sub_Total, 
               ccd.Tipo, 
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
               ccp.Cod_Libro, 
               ccp.Cod_Periodo, 
               ccp.Cod_Caja, 
               ccp.Cod_Turno, 
               ccp.Cod_TipoOperacion, 
               ccp.Cod_TipoComprobante, 
               ccp.Serie SerieComprobante, 
               ccp.Numero, 
               ccp.Id_Cliente, 
               ccp.Cod_TipoDoc, 
               ccp.Doc_Cliente, 
               ccp.Nom_Cliente, 
               ccp.Direccion_Cliente, 
               ccp.FechaEmision, 
               ccp.FechaVencimiento, 
               ccp.FechaCancelacion, 
               ccp.Glosa, 
               ccp.TipoCambio, 
               ccp.Flag_Anulado, 
               ccp.Flag_Despachado, 
               ccp.Cod_FormaPago, 
               ccp.Descuento_Total, 
               ccp.Cod_Moneda, 
               ccp.Impuesto, 
               ccp.Total, 
               ccp.Id_GuiaRemision, 
               ccp.GuiaRemision, 
               ccp.id_ComprobanteRef, 
               ccp.Cod_Plantilla, 
               ccp.Nro_Ticketera, 
               ccp.Cod_UsuarioVendedor, 
               ccp.Cod_RegimenPercepcion, 
               ccp.Tasa_Percepcion, 
               ccp.Placa_Vehiculo, 
               ccp.Cod_TipoDocReferencia, 
               ccp.Nro_DocReferencia, 
               ccp.Cod_EstadoComprobante, 
               ccp.MotivoAnulacion, 
               ccp.Otros_Cargos, 
               ccp.Otros_Tributos, 
               dbo.UFN_CAJ_COMPROBANTE_D_Serie(ccp.id_ComprobantePago, ccd.id_Detalle) Serie
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
        WHERE ccp.id_ComprobantePago = @IdComprobantePago;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_RELACION_TNotasXIdComprobante @id_ComprobantePago AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vtc.Cod_Sunat AS Cod_TipoComprobante, 
               ccp2.Serie + '-' + ccp2.Numero AS Comprobante
        FROM dbo.CAJ_COMPROBANTE_RELACION ccr
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccr.Id_ComprobanteRelacion = ccp.id_ComprobantePago
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp2 ON ccr.id_ComprobantePago = ccp2.id_ComprobantePago
             INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON ccp2.Cod_TipoComprobante = vtc.Cod_TipoComprobante
        WHERE ccr.Cod_TipoRelacion IN('CRE', 'DEB')
             AND ccr.id_ComprobantePago = @id_ComprobantePago;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_AfectarXNotaCreditoVenta @IdComprobantePago INT, 
                                                                   @IdComprobanteNota INT, 
                                                                   @CodTiponota       VARCHAR(MAX), 
                                                                   @Justificacion     VARCHAR(MAX), 
                                                                   @CodUsuario        VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @CodTipoCOmprobante VARCHAR(5)=
        (
            SELECT ccp.Cod_TipoComprobante
            FROM dbo.CAJ_COMPROBANTE_PAGO ccp
            WHERE ccp.id_ComprobantePago = @IdComprobanteNota
        );
        IF @CodTipoCOmprobante IN('NC', 'NCE')
            BEGIN
                --ANULACION COMPLETA
                IF(@CodTiponota IN('01', '02'))
                    BEGIN
                        --Editamos CAJ_FORMA_PAGO
                        UPDATE dbo.CAJ_FORMA_PAGO
                          SET 
                              dbo.CAJ_FORMA_PAGO.Monto = 0, 
                              dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario, 
                              dbo.CAJ_FORMA_PAGO.Fecha_Act = GETDATE()
                        WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @IdComprobantePago;
                        --Editamos ALMACEN_MOV
                        UPDATE dbo.ALM_ALMACEN_MOV
                          SET 
                              dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO', 
                              dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct = @CodUsuario, 
                              dbo.ALM_ALMACEN_MOV.Fecha_Act = GETDATE()
                        WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago;
                        --Editamos ALMACEN_MOV_D
                        UPDATE dbo.ALM_ALMACEN_MOV_D
                          SET 
                              dbo.ALM_ALMACEN_MOV_D.Precio_Unitario = 0, 
                              dbo.ALM_ALMACEN_MOV_D.Cantidad = 0, 
                              dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct = @CodUsuario, 
                              dbo.ALM_ALMACEN_MOV_D.Fecha_Act = GETDATE()
                        WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov =
                        (
                            SELECT aam.Id_AlmacenMov
                            FROM dbo.ALM_ALMACEN_MOV aam
                            WHERE aam.Id_ComprobantePago = @IdComprobantePago
                        );
                        --Editamos PRI_LICITACIONES_M
                        DELETE dbo.PRI_LICITACIONES_M
                        WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago = @IdComprobantePago;
                        --Editamos CAJ_COMPROBANTE_D
                        UPDATE dbo.CAJ_COMPROBANTE_D
                          SET 
                              dbo.CAJ_COMPROBANTE_D.Formalizado-=ccr.Valor, 
                              dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @CodUsuario, 
                              dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago
                                                                            AND ccd.id_Detalle = ccr.id_Detalle
                        WHERE ccr.Id_ComprobanteRelacion = @IdComprobantePago;
                        --Editamos CAJ_SERIES
                        DELETE FROM dbo.CAJ_SERIES
                        WHERE(dbo.CAJ_SERIES.Id_Tabla = @IdComprobantePago
                              AND dbo.CAJ_SERIES.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO');
                        --Editamos CAJ_COMPROBANTE_RELACION
                        DELETE dbo.CAJ_COMPROBANTE_RELACION
                        WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = @IdComprobantePago;
                        --Editamos CAJ_COMPROBANTE_PAGO
                        UPDATE dbo.CAJ_COMPROBANTE_PAGO
                          SET 
                              dbo.CAJ_COMPROBANTE_PAGO.Glosa = 'ANULADO', 
                              dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago = '004', 
                              dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
                              dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
                        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @IdComprobantePago;
                END;

                --CORECCION POR ERROR EN LA DESCRIPCION
                --No se hace nada
                ----DESCUENTO GLOBAL,DESCUENTO POR ITEM,BONIFICACION,DISMINUCION EN EL VALOR,OTROS CONCEPTOS
                --IF(@CodTiponota IN ('04','05','08','09','10'))
                --BEGIN
                ----Editamos CAJ_FORMA_PAGO
                ----Debemos obtener el total de la nota de credito, luego debemos de obtener la razon entre el total de la nota y el total del comprobante y multiplicar por ese valor 
                ----Todos los items de la forma de pago
                --DECLARE @TotalNota numeric(38,6) = (SELECT ccp.Total FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago = @IdComprobanteNota)
                --DECLARE @TotalComprobante numeric(38,6) = (SELECT ISNULL(SUM(cfp.Monto),0) FROM dbo.CAJ_FORMA_PAGO cfp WHERE cfp.id_ComprobantePago = @IdComprobantePago)
                --DECLARE @Factor numeric(38,6) = (1 - (@TotalNota/@TotalComprobante))
                --UPDATE dbo.CAJ_FORMA_PAGO
                --SET
                --    dbo.CAJ_FORMA_PAGO.Monto=dbo.CAJ_FORMA_PAGO.Monto*@Factor
                --WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@IdComprobantePago
                --END
                --DEVOLUCION TOTAL
                IF(@CodTiponota IN('06'))
                    BEGIN
                        --Editamos CAJ_FORMA_PAGO
                        UPDATE dbo.CAJ_FORMA_PAGO
                          SET 
                              dbo.CAJ_FORMA_PAGO.Monto = 0, 
                              dbo.CAJ_FORMA_PAGO.Cod_UsuarioAct = @CodUsuario, 
                              dbo.CAJ_FORMA_PAGO.Fecha_Act = GETDATE()
                        WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @IdComprobantePago;
                        --Editamos ALMACEN_MOV
                        UPDATE dbo.ALM_ALMACEN_MOV
                          SET 
                              dbo.ALM_ALMACEN_MOV.Motivo = 'ANULADO', 
                              dbo.ALM_ALMACEN_MOV.Cod_UsuarioAct = @CodUsuario, 
                              dbo.ALM_ALMACEN_MOV.Fecha_Act = GETDATE()
                        WHERE dbo.ALM_ALMACEN_MOV.Id_ComprobantePago = @IdComprobantePago;
                        --Editamos ALMACEN_MOV_D
                        UPDATE dbo.ALM_ALMACEN_MOV_D
                          SET 
                              dbo.ALM_ALMACEN_MOV_D.Precio_Unitario = 0, 
                              dbo.ALM_ALMACEN_MOV_D.Cantidad = 0, 
                              dbo.ALM_ALMACEN_MOV_D.Cod_UsuarioAct = @CodUsuario, 
                              dbo.ALM_ALMACEN_MOV_D.Fecha_Act = GETDATE()
                        WHERE dbo.ALM_ALMACEN_MOV_D.Id_AlmacenMov =
                        (
                            SELECT aam.Id_AlmacenMov
                            FROM dbo.ALM_ALMACEN_MOV aam
                            WHERE aam.Id_ComprobantePago = @IdComprobantePago
                        );
                        --Editamos PRI_LICITACIONES_M
                        DELETE dbo.PRI_LICITACIONES_M
                        WHERE dbo.PRI_LICITACIONES_M.id_ComprobantePago = @IdComprobantePago;
                        --Editamos CAJ_COMPROBANTE_D
                        UPDATE dbo.CAJ_COMPROBANTE_D
                          SET 
                              dbo.CAJ_COMPROBANTE_D.Formalizado-=ccr.Valor, 
                              dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @CodUsuario, 
                              dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccd.id_ComprobantePago = ccr.id_ComprobantePago
                                                                            AND ccd.id_Detalle = ccr.id_Detalle
                        WHERE ccr.Id_ComprobanteRelacion = @IdComprobantePago;
                        --Insertamos CAJ_SERIES
                        INSERT INTO dbo.CAJ_SERIES
                        (Cod_Tabla, 
                         Id_Tabla, 
                         Item, 
                         Serie, 
                         Fecha_Vencimiento, 
                         Obs_Serie, 
                         Cod_UsuarioReg, 
                         Fecha_Reg, 
                         Cod_UsuarioAct, 
                         Fecha_Act
                        )
                               SELECT 'CAJ_COMPROBANTE_PAGO', 
                                      @IdComprobanteNota, 
                                      cs.Item, 
                                      cs.Serie, 
                                      cs.Fecha_Vencimiento, 
                                      cs.Obs_Serie, 
                                      @CodUsuario, 
                                      GETDATE(), 
                                      NULL, 
                                      NULL
                               FROM dbo.CAJ_SERIES cs
                               WHERE cs.Id_Tabla = @IdComprobantePago
                                     AND cs.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO';
                        --Editamos CAJ_COMPROBANTE_RELACION
                        DELETE dbo.CAJ_COMPROBANTE_RELACION
                        WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion = @IdComprobantePago;
                        --Editamos CAJ_COMPROBANTE_PAGO
                        UPDATE dbo.CAJ_COMPROBANTE_PAGO
                          SET 
                              dbo.CAJ_COMPROBANTE_PAGO.Glosa = 'ANULADO', 
                              dbo.CAJ_COMPROBANTE_PAGO.Cod_FormaPago = '004', 
                              dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, -- varchar
                              dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE() -- datetime
                        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @IdComprobantePago;
                END;

                --DEVOLUCION POR ITEM
                IF(@CodTiponota IN('07'))
                    BEGIN
                        --Editamos CAJ_FORMA_PAGO
                        --Insertamos CAJ_SERIES
                        INSERT INTO dbo.CAJ_SERIES
                        (Cod_Tabla, 
                         Id_Tabla, 
                         Item, 
                         Serie, 
                         Fecha_Vencimiento, 
                         Obs_Serie, 
                         Cod_UsuarioReg, 
                         Fecha_Reg, 
                         Cod_UsuarioAct, 
                         Fecha_Act
                        )
                               SELECT 'CAJ_COMPROBANTE_PAGO', 
                                      @IdComprobanteNota, 
                                      cs.Item, 
                                      cs.Serie, 
                                      cs.Fecha_Vencimiento, 
                                      cs.Obs_Serie, 
                                      @CodUsuario, 
                                      GETDATE(), 
                                      NULL, 
                                      NULL
                               FROM dbo.CAJ_SERIES cs
                               WHERE cs.Id_Tabla = @IdComprobantePago
                                     AND cs.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO';
                END;
        END;
    END;
GO
--EXEC USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago 17784
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerSumatoriaNotasXIdComprobantePago @Id_Comprobante INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT COUNT(ccp.id_ComprobantePago) Conteo, 
               ISNULL(SUM(ABS(ISNULL(ccp.Total, 0))), 0) Sumatoria_Notas
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
        WHERE ccr.Id_ComprobanteRelacion = @Id_Comprobante
              AND ccr.Cod_TipoRelacion = 'CRE';
    END;
GO
--EXEC USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago 17784
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasXIdComprobantePago @Id_Comprobante INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT ccp.*
        FROM dbo.CAJ_COMPROBANTE_PAGO ccp
             INNER JOIN dbo.CAJ_COMPROBANTE_RELACION ccr ON ccp.id_ComprobantePago = ccr.id_ComprobantePago
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
        WHERE ccr.Id_ComprobanteRelacion = @Id_Comprobante
              AND ccr.Cod_TipoRelacion = 'CRE';
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ObtenerNotasRelacionadasXIdComprobanteCodLibro @Id_ComprobantePago INT, 
                                                                                         @Cod_Libro          VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               ccp.id_ComprobantePago, 
               ccp.Cod_Libro, 
               ccp.Cod_TipoComprobante, 
               ccp.Serie, 
               ccp.Numero, 
               ccp.Id_Cliente, 
               ccp.Cod_TipoDoc, 
               ccp.Doc_Cliente, 
               ccp.Nom_Cliente, 
               ccp.Direccion_Cliente, 
               ccp.FechaEmision, 
               ccp.Total, 
               ccp.Impuesto
        FROM dbo.CAJ_COMPROBANTE_RELACION ccr
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccr.id_ComprobantePago = ccp.id_ComprobantePago
        WHERE ccr.Cod_TipoRelacion IN('CRE', 'DEB')
             AND ccp.Flag_Anulado = 0
             AND ((ccr.Cod_TipoRelacion <> '07'
                   AND ccr.Cod_TipoRelacion = 'CRE')
                  OR (ccr.Cod_TipoRelacion = 'DEB'))
             AND ccr.Id_ComprobanteRelacion = @Id_ComprobantePago
             AND ccp.Cod_Libro = @Cod_Libro;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_TAlmacenXCajaProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TAlmacenXCajaProducto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TAlmacenXCajaProducto @CodCaja AS     VARCHAR(32), 
                                                        @Id_Producto AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               PS.Cod_Almacen, 
               A.Des_Almacen
        FROM PRI_PRODUCTO_STOCK AS PS
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
        WHERE(PS.Id_Producto = @Id_Producto)
             AND ca.Cod_Caja = @CodCaja;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TraerUnidadesXIdProductoMonedaAlmacen @IdProducto INT, 
                                                                              @CodAlmacen VARCHAR(32), 
                                                                              @CodMoneda  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               pps.Id_Producto, 
               pps.Cod_UnidadMedida, 
               pps.Cod_Almacen, 
               vudm.Nom_UnidadMedida, 
               vudm.Tipo
        FROM dbo.PRI_PRODUCTO_STOCK pps
             INNER JOIN dbo.VIS_UNIDADES_DE_MEDIDA vudm ON pps.Cod_UnidadMedida = vudm.Cod_UnidadMedida
        WHERE pps.Id_Producto = @IdProducto
              AND pps.Cod_Almacen = @CodAlmacen
              AND pps.Cod_Moneda = @CodMoneda;
    END;
GO
--EXEC dbo.USP_CAJ_COMPROBANTE_D_TraerHistorial
--	@CodLibro = '14',
--	@IdProducto = 16,
--	@IdCliente = 2,
--	@CodAlmacen = 'A101',
--	@CodUnidadMedida = 'NIU',
--	@CodMoneda = 'PEN',
--	@NroFilas = 100

IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerHistorial'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerHistorial;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerHistorial @CodLibro        VARCHAR(5), 
                                                      @IdProducto      INT, 
                                                      @IdCliente       INT, 
                                                      @CodAlmacen      VARCHAR(32), 
                                                      @CodUnidadMedida VARCHAR(32), 
                                                      @CodMoneda       VARCHAR(5), 
                                                      @NroFilas        INT         = 100
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Sentencia VARCHAR(MAX)= 'SELECT DISTINCT TOP ' + CONVERT(VARCHAR(32), @NroFilas) + ' ccp.FechaEmision,ccp.id_ComprobantePago,ccp.Cod_TipoComprobante+'':''+ccp.Serie+''-''+ccp.Numero Comprobante,ROUND(ccd.Cantidad,2) Cantidad,
		ROUND(ccd.PrecioUnitario,2) PrecioUnitario, pps.Precio_Venta Flete,ROUND(ccd.Cantidad,2)*ROUND(ccd.PrecioUnitario,2) Total
		FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
		INNER JOIN dbo.PRI_PRODUCTO_STOCK pps  ON ccd.Id_Producto = pps.Id_Producto AND ccd.Cod_Almacen = pps.Cod_Almacen AND ccd.Cod_UnidadMedida = pps.Cod_UnidadMedida
		WHERE ccp.Cod_Libro=''' + @CodLibro + ''' AND ccd.Id_Producto=' + CONVERT(VARCHAR(32), @IdProducto) + ' AND ccd.Cod_Almacen=''' + @CodAlmacen + ''' AND ccd.Cod_UnidadMedida=''' + @CodUnidadMedida + '''
		AND ccp.Cod_Moneda=''' + @CodMoneda + ''' AND ccp.Id_Cliente=' + CONVERT(VARCHAR(32), @IdCliente) + ' AND  ccp.Cod_Caja IS NOT NULL AND RTRIM(LTRIM(ccp.Cod_Caja))!='''' AND ccp.Cod_Turno IS NOT NULL AND RTRIM(LTRIM(ccp.Cod_Turno))!=''''
		AND ccp.Cod_TipoComprobante IN (''FE'',''BE'',''FA'',''BO'',''TKF'',''TKB'') AND ccp.Flag_Anulado=0
		ORDER BY ccp.FechaEmision  ASC';
        EXECUTE (@Sentencia);
    END;
GO
--Recuepra poroductos activos de un almacen y un tipo de existencia
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TraerProductosXCodExistenciaCodAlmacen @CodTipoExistencia VARCHAR(32), 
                                                                         @CodAlmacen        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               pp.Id_Producto, 
               pp.Cod_Producto, 
               pp.Cod_Categoria, 
               pp.Cod_Marca, 
               pp.Cod_TipoProducto, 
               pp.Nom_Producto, 
               pp.Des_CortaProducto, 
               pp.Des_LargaProducto, 
               pp.Caracteristicas, 
               pp.Porcentaje_Utilidad, 
               pp.Cuenta_Contable, 
               pp.Contra_Cuenta, 
               pp.Cod_Garantia, 
               pp.Cod_TipoOperatividad, 
               pp.Flag_Activo, 
               pp.Flag_Stock, 
               pp.Cod_Fabricante, 
               pp.Cod_UsuarioReg
        FROM dbo.PRI_PRODUCTOS pp
             INNER JOIN dbo.PRI_PRODUCTO_STOCK pps ON pp.Id_Producto = pps.Id_Producto
        WHERE pps.Cod_Almacen = @CodAlmacen
              AND pp.Cod_TipoExistencia = @CodTipoExistencia
              AND pp.Flag_Activo = 1;
    END;
GO
--EXEC dbo.USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion
--	@Id_ClienteProveedor = 2
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_ObtenerDiferenciaXId_ClienteCodTipoOperacion @Id_ClienteProveedor INT, 
                                                                                  @Cod_tipoOperacionNS VARCHAR(32) = '30', 
                                                                                  @Cod_tipoOperacionNE VARCHAR(32) = '29'
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               T1.Id_AlmacenMov, 
               T1.Id_ComprobantePago, 
               T1.Fecha, 
               T1.SerieNumero, 
               T1.Id_Producto, 
               T1.Des_Producto, 
               T1.Cantidad - ISNULL(T2.Cantidad, 0) Cantidad
        FROM
        (
            SELECT DISTINCT 
                   aam.Id_AlmacenMov, 
                   aam.Id_ComprobantePago, 
                   aam.Fecha, 
                   aam.Cod_TipoComprobante + ':' + aam.Serie + '-' + aam.Numero SerieNumero, 
                   aamd.Id_Producto, 
                   aamd.Des_Producto, 
                   SUM(aamd.Cantidad) Cantidad
            FROM dbo.ALM_ALMACEN_MOV aam
                 INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago = aam.Id_ComprobantePago
            WHERE aam.Cod_TipoComprobante = 'NS'
                  AND ccp.Id_Cliente = @Id_ClienteProveedor
                  AND aam.Flag_Anulado = 0
                  AND ccp.Flag_Anulado = 0
                  AND aam.Cod_TipoOperacion = @Cod_tipoOperacionNS
            GROUP BY aam.Id_ComprobantePago, 
                     aamd.Id_Producto, 
                     aam.Id_AlmacenMov, 
                     aam.Cod_TipoComprobante, 
                     aam.Fecha, 
                     aam.Serie, 
                     aam.Numero, 
                     aamd.Des_Producto
        ) T1
        LEFT JOIN
        (
            SELECT DISTINCT 
                   aam.Id_ComprobantePago, 
                   aamd.Id_Producto, 
                   SUM(aamd.Cantidad) Cantidad
            FROM dbo.ALM_ALMACEN_MOV aam
                 INNER JOIN dbo.ALM_ALMACEN_MOV_D aamd ON aam.Id_AlmacenMov = aamd.Id_AlmacenMov
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccp.id_ComprobantePago = aam.Id_ComprobantePago
            WHERE aam.Cod_TipoComprobante = 'NE'
                  AND ccp.Id_Cliente = @Id_ClienteProveedor
                  AND aam.Flag_Anulado = 0
                  AND ccp.Flag_Anulado = 0
                  AND aam.Cod_TipoOperacion = @Cod_tipoOperacionNE
            GROUP BY aam.Id_ComprobantePago, 
                     aamd.Id_Producto
        ) T2 ON T1.Id_ComprobantePago = T2.Id_ComprobantePago
                AND T1.Id_Producto = T2.Id_Producto
        WHERE T1.Cantidad - ISNULL(T2.Cantidad, 0) > 0
        ORDER BY T1.SerieNumero;
    END;
GO
--EXEC dbo.USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto
--	@Id_Cliente = 2,
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto;
GO
CREATE PROCEDURE USP_CAJ_MOVIMIENTOS_ObtenerSumatoriaRIXIdClienteIdConcepto @Id_Cliente        INT, 
                                                                            @Id_ConceptoRI     INT         = 70001, 
                                                                            @Id_ConceptoRE     INT         = 70002, 
                                                                            @Cod_MonedaIngreso VARCHAR(32) = 'PEN'
WITH ENCRYPTION
AS
    BEGIN
        SELECT 'RI' TipoComprobante, 
               (T1.SumIngreso - T2.SumEgreso) SumIngreso
        FROM
        (
            SELECT DISTINCT 
                   'RI' TipoComprobante, 
                   ISNULL(SUM(ISNULL(ccm.Ingreso, 0)), 0) SumIngreso, 
                   @Id_Cliente Id_ClienteProveedor
            FROM dbo.CAJ_CAJA_MOVIMIENTOS ccm
            WHERE ccm.Id_ClienteProveedor = @Id_Cliente
                  AND ccm.Cod_MonedaIng = @Cod_MonedaIngreso
                  AND ccm.Id_Concepto = @Id_ConceptoRI
                  AND ccm.Id_MovimientoRef <> 0
                  AND ccm.Cod_TipoComprobante = 'RI'
                  AND ccm.Flag_Extornado = 0
        ) T1
        LEFT JOIN
        (
            SELECT DISTINCT 
                   'RE' TipoComprobante, 
                   ISNULL(SUM(ccm.Egreso), 0) SumEgreso, 
                   @Id_Cliente Id_ClienteProveedor
            FROM dbo.CAJ_CAJA_MOVIMIENTOS ccm
            WHERE ccm.Id_ClienteProveedor = @Id_Cliente
                  AND ccm.Cod_MonedaEgr = @Cod_MonedaIngreso
                  AND ccm.Id_Concepto = @Id_ConceptoRE
                  AND ccm.Cod_TipoComprobante = 'RE'
                  AND ccm.Flag_Extornado = 0
        ) T2 ON T1.Id_ClienteProveedor = T2.Id_ClienteProveedor;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_TraerCopiasSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_TraerCopiasSeguridad;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_TraerCopiasSeguridad
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            vc.Valor_Configuracion RUTA_COPIA_SEGURIDAD, 
            vc2.Valor_Configuracion FRECUENCIA_COPIA_SEGURIDAD, 
            vc3.Valor_Configuracion INTERVALO_COPIA_SEGURIDAD, 
            vc4.Valor_Configuracion HORA_COPIA_SEGURIDAD
     FROM dbo.VIS_CONFIGURACION vc
          LEFT JOIN dbo.VIS_CONFIGURACION vc2 ON vc2.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                                                 AND vc2.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc3 ON vc3.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                                                 AND vc3.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc4 ON vc4.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                                                 AND vc4.Estado = 1
     WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
           AND vc.Estado = 1;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            vc.Valor_Configuracion RUTA_COPIA_SEGURIDAD, 
            vc2.Valor_Configuracion FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD, 
            vc3.Valor_Configuracion INTERVALO_ELIMINAR_COPIA_SEGURIDAD
     FROM dbo.VIS_CONFIGURACION vc
          LEFT JOIN dbo.VIS_CONFIGURACION vc2 ON vc2.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                                                 AND vc2.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc3 ON vc3.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                                                 AND vc3.Estado = 1
     WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
           AND vc.Estado = 1;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadMensual'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadMensual;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadMensual @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                     @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                     @NumeroIntentos   INT          = 0, 
                                                     @IntervaloMinutos INT          = 0, 
                                                     @DiaEjecucion     INT          = 1, 
                                                     @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_MENSUAL', 
             @enabled = 1, 
             @freq_type = 16, 
             @freq_interval = @DiaEjecucion, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadSemanal'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadSemanal;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadSemanal @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                     @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                     @NumeroIntentos   INT          = 0, 
                                                     @IntervaloMinutos INT          = 0, 
                                                     @DiaEjecucion     INT          = 1, 
                                                     @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_SEMANAL', 
             @enabled = 1, 
             @freq_type = 8, 
             @freq_interval = @DiaEjecucion, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadDiaria'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadDiaria;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadDiaria @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                    @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                    @NumeroIntentos   INT          = 0, 
                                                    @IntervaloMinutos INT          = 0, 
                                                    @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_DIARIO', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadIntervalos'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos @NombreTarea             VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                        @RutaGuardado            VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                        @NumeroIntentos          INT          = 0, 
                                                        @IntervaloMinutos        INT          = 0, 
                                                        @IntervaloEjecucionHoras INT          = 1
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_INTERVALOS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 8, 
             @freq_subday_interval = @IntervaloEjecucionHoras, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = 0, 
             @active_end_time = 235959, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadIntervalos'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos @NombreTarea             VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                        @RutaGuardado            VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                        @NumeroIntentos          INT          = 0, 
                                                        @IntervaloMinutos        INT          = 0, 
                                                        @IntervaloEjecucionHoras INT          = 1
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_INTERVALOS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 8, 
             @freq_subday_interval = @IntervaloEjecucionHoras, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = 0, 
             @active_end_time = 235959, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_GuardarInformacionCopia'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionCopia;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionCopia @RutaCopiaSeguridad       VARCHAR(MAX), 
                                                               @FrecuenciaCopiaSeguridad VARCHAR(MAX) = NULL, 
                                                               @IntervaloCopiaSeguridad  VARCHAR(MAX) = NULL, 
                                                               @HoraCopiaSeguridad       VARCHAR(MAX) = NULL, 
                                                               @CodUsuario               VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @IdFila INT;
            --ALMACENAMOS LA RUTA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @RutaCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'RUTA_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @RutaCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS LA FRECUENCIA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @FrecuenciaCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'FRECUENCIA_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @FrecuenciaCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS EL INTERVALOD DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @IntervaloCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'INTERVALO_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @IntervaloCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS LA HORA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @HoraCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'HORA_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @HoraCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
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
    WHERE name = N'USP_EjecutarCopiaSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_EjecutarCopiaSeguridad;
GO
CREATE PROCEDURE USP_EjecutarCopiaSeguridad @NombreArchivo VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaEliminarCopiaSeguridadIntervalos'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaEliminarCopiaSeguridadIntervalos;
GO
CREATE PROCEDURE USP_CrearTareaEliminarCopiaSeguridadIntervalos @NombreTarea             VARCHAR(MAX) = N'ELIMINAR_COPIA_SEGURIDAD', 
                                                                @RutaGuardado            VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                                @NumeroIntentos          INT          = 0, 
                                                                @IntervaloMinutos        INT          = 0, 
                                                                @IntervaloEjecucionHoras INT          = 1, 
                                                                @AntiguedadHoras         INT          = 1
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        --DECLARE @Comando varchar(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos ',N'N''C:\APLICACIONES\TEMP''',',palerp,720')
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos N''', @RutaGuardado, ''',N''palerp'',', @AntiguedadHoras);
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'ELIMINAR COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'ELIMINAR_COPIA_INTERVALOS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 8, 
             @freq_subday_interval = @IntervaloEjecucionHoras, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = 0, 
             @active_end_time = 235959, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia @FrecuenciaEliminacionCopiaSeguridad VARCHAR(MAX) = NULL, 
                                                                          @IntervaloEliminacionCopiaSeguridad  VARCHAR(MAX) = NULL, 
                                                                          @CodUsuario                          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @IdFila INT;
            --ALMACENAMOS LA FRECUENCIA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @FrecuenciaEliminacionCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @FrecuenciaEliminacionCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS EL INTERVALOD DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @IntervaloEliminacionCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '001', @Cod_Fila = @IdFila, @Cadena = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD', @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '002', @Cod_Fila = @IdFila, @Cadena = @IntervaloEliminacionCopiaSeguridad, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = NULL, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G @Cod_Tabla = '099', @Cod_Columna = '003', @Cod_Fila = @IdFila, @Cadena = NULL, @Numero = NULL, @Entero = NULL, @FechaHora = NULL, @Boleano = 1, @Flag_Creacion = 1, @Cod_Usuario = @CodUsuario;
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
    WHERE name = N'USP_PROGRAMADOR_TAREAS_RecuperarEstado'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_RecuperarEstado;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_RecuperarEstado
WITH ENCRYPTION
AS
     IF EXISTS
     (
         SELECT 1
         FROM master.dbo.sysprocesses
         WHERE program_name = N'SQLAgent - Generic Refresher'
     )
         BEGIN
             SELECT @@SERVERNAME AS 'Instancia', 
                    CAST(1 AS BIT) Estado;
     END;
         ELSE
         BEGIN
             SELECT @@SERVERNAME AS 'Instancia', 
                    CAST(0 AS BIT) Estado;
     END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PROGRAMADOR_TAREAS_TraerXNombre'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre @Nombre_Tarea VARCHAR(MAX)
WITH ENCRYPTION
AS
     SELECT s.job_id, 
            s.originating_server_id, 
            s.name, 
            CAST(s.enabled AS BIT) enabled, 
            s.description, 
            s.start_step_id, 
            s.category_id, 
            s.owner_sid, 
            s.notify_level_eventlog, 
            s.notify_level_email, 
            s.notify_level_netsend, 
            s.notify_level_page, 
            s.notify_email_operator_id, 
            s.notify_netsend_operator_id, 
            s.notify_page_operator_id, 
            s.delete_level, 
            s.date_created, 
            s.date_modified, 
            s.version_number
     FROM msdb.dbo.sysjobs s
     WHERE(name = @Nombre_Tarea);
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TraerNombreBaseDatos'
          AND type = 'P'
)
    DROP PROCEDURE USP_TraerNombreBaseDatos;
GO
CREATE PROCEDURE USP_TraerNombreBaseDatos
WITH ENCRYPTION
AS
     SELECT DB_NAME() NombreBD;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Crear_CopiaSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_Crear_CopiaSeguridad;
GO
CREATE PROCEDURE USP_Crear_CopiaSeguridad @BDActual   VARCHAR(MAX), 
                                          @RutaBackup VARCHAR(MAX), 
                                          @Extension  VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @NombreArchivo AS VARCHAR(MAX)= CONCAT(@RutaBackup, CHAR(92), @BDActual, '_', replace(CONVERT(VARCHAR, GETDATE(), 103), '/', ''), '_', replace(CONVERT(VARCHAR, GETDATE(), 108), ':', ''), '.', @Extension);
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_EliminarBackupsAntiguos'
          AND type = 'P'
)
    DROP PROCEDURE USP_EliminarBackupsAntiguos;
GO
CREATE PROCEDURE USP_EliminarBackupsAntiguos @path        NVARCHAR(256), 
                                             @Extension   NVARCHAR(10), 
                                             @TiempoHoras INT
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @DeleteDate NVARCHAR(50);
        DECLARE @DeleteDateTime DATETIME;
        SET @DeleteDateTime = DATEADD(hh, -@TiempoHoras, GETDATE());
        SET @DeleteDate =
        (
            SELECT Replace(CONVERT(NVARCHAR, @DeleteDateTime, 111), '/', '-') + 'T' + CONVERT(NVARCHAR, @DeleteDateTime, 108)
        );
        EXECUTE master.dbo.xp_delete_file 
                0, 
                @path, 
                @extension, 
                @DeleteDate, 
                1;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 10/09/2015
-- OBJETIVO: Vista que numera las series de los numeros
-- select * from VIS_SERIES where serie like '%1389'
-- USP_CAJ_SERIES_Buscar 'ES7817001','a101'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_Buscar;
GO
CREATE PROCEDURE USP_CAJ_SERIES_Buscar @pSerie      VARCHAR(512), 
                                       @pCodAlmacen VARCHAR(512)
WITH ENCRYPTION
AS
     SELECT S.Cod_Tabla, 
            S.Id_Tabla, 
            S.Item, 
            S.Serie, 
            S.Fecha_Vencimiento, 
            S.Obs_Serie, 
            P.Cod_Producto, 
            MD.Des_Producto, 
            A.Des_Almacen, 
            AM.Cod_TipoComprobante + ' : ' + AM.Serie + ' - ' + AM.Numero AS Comprobante, 
            AM.Fecha, 
            AM.Motivo, 
            AM.Flag_Anulado,
            CASE AM.Cod_TipoComprobante
                WHEN 'NE'
                THEN 'ENTRADA'
                WHEN 'NS'
                THEN 'SALIDA'
                ELSE ''
            END AS Estado,
            CASE
                WHEN AM.Cod_TipoComprobante = 'NE'
                     AND Flag_Anulado = 0
                THEN 1
                WHEN AM.Cod_TipoComprobante = 'NS'
                     AND Flag_Anulado = 0
                THEN-1
                ELSE 0
            END AS Stock, 
            P.Id_Producto, 
            A.Cod_Almacen, 
            PS.Cod_UnidadMedida, 
            AM.Fecha_Reg, 
            PS.Precio_Venta, 
            PS.Precio_Compra, 
            VU.Nom_UnidadMedida, 
            P.Cod_TipoOperatividad
     FROM PRI_PRODUCTOS AS P
          INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
          INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
          INNER JOIN ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen
          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                 AND AM.Cod_Almacen = PS.Cod_Almacen
          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida
          RIGHT OUTER JOIN CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla
                                              AND MD.Item = S.Item
     WHERE(S.Cod_Tabla = 'ALM_ALMACEN_MOV')
          AND s.Serie = @pSerie
          AND am.Cod_Almacen = @pCodAlmacen
     UNION
     SELECT S.Cod_Tabla, 
            S.Id_Tabla, 
            S.Item, 
            S.Serie, 
            S.Fecha_Vencimiento, 
            S.Obs_Serie, 
            P.Cod_Producto, 
            CD.Descripcion AS Des_Producto, 
            A.Des_Almacen, 
            CP.Cod_TipoComprobante + ' : ' + CP.Serie + ' - ' + CP.Numero AS Comprobante, 
            CP.FechaEmision, 
            CP.Glosa, 
            CP.Flag_Anulado,
            CASE cp.Cod_Libro
                WHEN '08'
                THEN 'ENTRADA'
                WHEN '14'
                THEN 'SALIDA'
                ELSE ''
            END AS Estado,
            CASE
                WHEN cp.Cod_Libro = '08'
                     AND Flag_Anulado = 0
                THEN 1
                WHEN cp.Cod_Libro = '14'
                     AND Flag_Anulado = 0
                THEN-1
                ELSE 0
            END AS Stock, 
            P.Id_Producto, 
            A.Cod_Almacen, 
            PS.Cod_UnidadMedida, 
            CP.Fecha_Reg, 
            PS.Precio_Venta, 
            PS.Precio_Compra, 
            VU.Nom_UnidadMedida, 
            P.Cod_TipoOperatividad
     FROM PRI_PRODUCTOS AS P
          INNER JOIN CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto
          INNER JOIN CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
          INNER JOIN ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen
          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                 AND CD.Cod_Almacen = PS.Cod_Almacen
          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON CD.Cod_UnidadMedida = VU.Cod_UnidadMedida
          RIGHT OUTER JOIN CAJ_SERIES AS S ON CD.id_ComprobantePago = S.Id_Tabla
                                              AND CD.id_Detalle = S.Item
     WHERE(S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
          AND s.Serie = @pSerie
          AND cd.Cod_Almacen = @pCodAlmacen;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN
-- FECHA: 20/03/2019
-- OBJETIVO: Vista que numera las series de los numeros
-- select * from VIS_SERIES where serie like '%1389'
-- USP_PRI_PRODUCTOS_SERIE_Buscar 100,'ES7817001',null,null,'001',0,'A101'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_SERIE_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_SERIE_Buscar;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_SERIE_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                @Buscar             VARCHAR(512), 
                                                @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                                @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                                @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                                @Flag_RequiereStock AS BIT          = 0, 
                                                @Cod_Almacen AS        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        -- SET @Buscar = REPLACE(@Buscar,'%',' ');

        IF(@Cod_Almacen != '')
            BEGIN
                SELECT P.Id_Producto, 
                       P.Nom_Producto AS Nom_Producto, 
                       P.Cod_Producto, 
                       PS.Stock_Act, 
                       PS.Precio_Venta, 
                       M.Nom_Moneda AS Nom_Moneda, 
                       PS.Cod_Almacen, 
                       0 AS Descuento, 
                       'NINGUNO' AS TipoDescuento, 
                       A.Des_CortaAlmacen AS Des_Almacen, 
                       PS.Cod_UnidadMedida, 
                       UM.Nom_UnidadMedida, 
                       P.Flag_Stock, 
                       PS.Precio_Compra,
                       CASE
                           WHEN @Cod_Precio IS NULL
                           THEN 0
                           ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
                       END AS Precio, 
                       P.Cod_TipoOperatividad, 
                       PS.Cod_Moneda, 
                       Cod_TipoProducto AS TipoProducto, 
                       CS.Serie AS Serie, 
                       CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
                       CS.Obs_Serie, 
                       P.Cod_TipoProducto
                FROM PRI_PRODUCTOS AS P
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                     INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
                     INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
                     INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
                     INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                     LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                                          AND PS.Cod_Almacen = CD.Cod_Almacen
                                                          AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
                     LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
                     LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
                                                   AND CD.id_Detalle = CS.Item
                                                   AND CD.id_ComprobantePago = CS.Id_Tabla
                                                   AND Cod_TipoProducto = 'PRL'
                                                   AND CC.Flag_Anulado = 0)
                WHERE(P.Cod_TipoProducto = @CodTipoProducto
                      OR @CodTipoProducto IS NULL) 
                     --AND ( (P.Cod_Producto LIKE @Buscar) OR (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
                     AND (P.Cod_Categoria IN
                (
                    SELECT Cod_Categoria
                    FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
                )
                OR @Cod_Categoria IS NULL)
                     AND (ca.Cod_Caja = @Cod_Caja
                          OR @Cod_Caja IS NULL)
                     AND (P.Flag_Activo = 1)
                     AND ps.Cod_Almacen = @Cod_Almacen
                     AND CS.Serie LIKE @Buscar
                -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
                ORDER BY Nom_Producto, 
                         CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103));
        END;
            ELSE
            BEGIN
                SELECT P.Id_Producto, 
                       P.Nom_Producto AS Nom_Producto, 
                       P.Cod_Producto, 
                       PS.Stock_Act, 
                       PS.Precio_Venta, 
                       M.Nom_Moneda AS Nom_Moneda, 
                       PS.Cod_Almacen, 
                       0 AS Descuento, 
                       'NINGUNO' AS TipoDescuento, 
                       A.Des_CortaAlmacen AS Des_Almacen, 
                       PS.Cod_UnidadMedida, 
                       UM.Nom_UnidadMedida, 
                       P.Flag_Stock, 
                       PS.Precio_Compra,
                       CASE
                           WHEN @Cod_Precio IS NULL
                           THEN 0
                           ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
                       END AS Precio, 
                       P.Cod_TipoOperatividad, 
                       PS.Cod_Moneda, 
                       Cod_TipoProducto AS TipoProducto, 
                       CS.Serie AS Serie, 
                       CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) AS Fecha_Vencimiento, 
                       CS.Obs_Serie, 
                       P.Cod_TipoProducto
                FROM PRI_PRODUCTOS AS P
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                     INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
                     INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
                     INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
                     INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                     LEFT JOIN CAJ_COMPROBANTE_D AS CD ON(P.Id_Producto = CD.Id_Producto
                                                          AND PS.Cod_Almacen = CD.Cod_Almacen
                                                          AND PS.Cod_UnidadMedida = CD.Cod_UnidadMedida)
                     LEFT JOIN CAJ_COMPROBANTE_PAGO CC ON(CC.id_ComprobantePago = CD.id_ComprobantePago)
                     LEFT JOIN CAJ_SERIES AS CS ON(Cod_Tabla = 'CAJ_COMPROBANTE_PAGO'
                                                   AND CD.id_Detalle = CS.Item
                                                   AND CD.id_ComprobantePago = CS.Id_Tabla
                                                   AND Cod_TipoProducto = 'PRL'
                                                   AND CC.Flag_Anulado = 0)
                WHERE(P.Cod_TipoProducto = @CodTipoProducto
                      OR @CodTipoProducto IS NULL)
                     AND ((P.Cod_Producto LIKE @Buscar)
                          OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                          OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                          OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
                     AND (P.Cod_Categoria IN
                (
                    SELECT Cod_Categoria
                    FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
                )
                OR @Cod_Categoria IS NULL)
                     AND (ca.Cod_Caja = @Cod_Caja
                          OR @Cod_Caja IS NULL)
                     AND (P.Flag_Activo = 1)
                     AND CS.Serie LIKE @Buscar
                -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
                ORDER BY Nom_Producto, 
                         CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103));
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 22/03/2019;
-- OBJETIVO: Procedimiento que muestra la Lista del inventario inicial pendiente
-- EXEC USP_ALM_Traer_Almacen_Inventario_Inicial_Detalle_Pendiente 100,'pro',null,null,'001',0
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_Traer_Almacen_Inventario_Inicial_Detalle_Pendiente'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_Traer_Almacen_Inventario_Inicial_Detalle_Pendiente;
GO
CREATE PROCEDURE USP_ALM_Traer_Almacen_Inventario_Inicial_Detalle_Pendiente @pIdInventario INT
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT *
        FROM [dbo].[ALM_INVENTARIO_D]
        WHERE [Id_Inventario] = @pIdInventario;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/03/2019;
-- OBJETIVO: Procedimiento que muestra la Lista del inventario inicial pendiente
-- EXEC USP_CAJ_SERIES_TXAlmacenProductoLote 'a101','6','F004676F'
--------------------------------------------------------------------------------------------------------------
GO 
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_TXAlmacenProductoLote'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_TXAlmacenProductoLote;
GO
CREATE PROCEDURE USP_CAJ_SERIES_TXAlmacenProductoLote @Cod_Almacen AS VARCHAR(32), 
                                                      @Id_Producto AS INT, 
                                                      @Lote AS        VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Serie, 
               Fecha_Vencimiento, 
               Obs_Serie
        FROM VIS_SERIES
        WHERE(Serie = @Lote) 
             --and Cod_Almacen = @Cod_Almacen 
             AND Id_Producto = @Id_Producto
        GROUP BY Serie, 
                 Fecha_Vencimiento, 
                 Obs_Serie
        ORDER BY Fecha_Vencimiento DESC;
    END;
GO

--------------------------------------------------------------------------------------------------------------
--  AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA:  12/03/2019 | 25/06/2019
-- OBJETIVO: Metodo que traer productos que pertenecen a una composicion
-- Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_ALM_INVENTARIO_RECUPERAR_CABECERA 3037
--------------------------------------------------------------------------------------------------------------
--IF EXISTS
--(
--    SELECT name
--    FROM sysobjects
--    WHERE name = 'USP_ALM_INVENTARIO_RECUPERAR_CABECERA'
--          AND type = 'P'
--)
--    DROP PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_CABECERA;
--GO
--CREATE PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_CABECERA @pIdInventario INT
--WITH ENCRYPTION
--AS
--    BEGIN
--        SELECT *
--        FROM ALM_INVENTARIO
--        WHERE Id_Inventario = @pIdInventario;
--    END;
--GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_RECUPERAR_CABECERA'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_CABECERA;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_CABECERA @pIdInventario INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT [Id_Inventario], 
               [Des_Inventario], 
               [Cod_TipoInventario], 
               [Cod_Almacen], 
               [Cod_EstadoInventario], 
               [Fecha_Inventario], 
               [Fecha_Fin], 
               [Obs_Inventario], 
               [Cod_UsuarioReg], 
               [Fecha_Reg], 
               [Cod_UsuarioAct], 
               [Fecha_Act]
        FROM ALM_INVENTARIO
        WHERE Id_Inventario = @pIdInventario;
    END;
GO
--------------------------------------------------------------------------------------------------------------
--  AUTOR: ESTEFANI HUAMAN;
-- FECHA:  26/02/2019
-- OBJETIVO: Metodo que traer
-- SELECT dbo.UFN_CAJ_SERIES_Stocks; ('152645',1423,'A101')
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'UFN_CAJ_SERIES_Stocks'
)
    DROP FUNCTION UFN_CAJ_SERIES_Stocks;
GO
CREATE FUNCTION UFN_CAJ_SERIES_Stocks
(@Serie AS       VARCHAR(512), 
 @Id_Producto AS INT, 
 @Id_Almacen AS  VARCHAR(32)
)
RETURNS INT
WITH ENCRYPTION
AS
     BEGIN
         DECLARE @StockComprobante AS NUMERIC(38, 6);
         DECLARE @StockAlmacen AS NUMERIC(38, 6);
         SET @StockComprobante =
         (
             SELECT ISNULL(SUM(CASE
                                   WHEN cp.Cod_Libro = '08'
                                        AND Flag_Anulado = 0
                                   THEN 1
                                   WHEN cp.Cod_Libro = '14'
                                        AND Flag_Anulado = 0
                                   THEN-1
                                   ELSE 0
                               END), 0)
             FROM [dbo].[CAJ_COMPROBANTE_D] C
                  INNER JOIN [dbo].[CAJ_SERIES] S ON(C.id_ComprobantePago = S.Id_Tabla
                                                     AND c.id_Detalle = s.Item)
                  INNER JOIN [CAJ_COMPROBANTE_PAGO] CP ON(C.id_ComprobantePago = CP.id_ComprobantePago)
             WHERE S.serie = @Serie
                   AND c.Id_Producto = @Id_Producto
                   AND [Cod_Almacen] = @Id_Almacen
         );
         SET @StockAlmacen =
         (
             SELECT ISNULL(SUM(CASE
                                   WHEN AM.Cod_TipoComprobante = 'NE'
                                        AND Flag_Anulado = 0
                                   THEN 1
                                   WHEN AM.Cod_TipoComprobante = 'NS'
                                        AND Flag_Anulado = 0
                                   THEN-1
                                   ELSE 0
                               END), 0)
             FROM ALM_ALMACEN_MOV_D C
                  INNER JOIN [dbo].[CAJ_SERIES] S ON(C.Id_AlmacenMov = S.Id_Tabla
                                                     AND c.Item = s.Item)
                  INNER JOIN ALM_ALMACEN_MOV AM ON(C.Id_AlmacenMov = AM.Id_AlmacenMov)
             WHERE S.serie = @Serie
                   AND c.Id_Producto = @Id_Producto
                   AND [Cod_Almacen] = @Id_Almacen
         );
         RETURN @StockComprobante + @StockAlmacen;
     END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USUSP_PRI_CATEGORIA_TT_TODO
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CATEGORIA_TT_TODO'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CATEGORIA_TT_TODO;
GO
CREATE PROCEDURE USP_PRI_CATEGORIA_TT_TODO
WITH ENCRYPTION
AS
    BEGIN
(
    SELECT '-1' AS Cod_Categoria, 
           'TODOS' AS Des_Categoria
)
UNION
(
    SELECT Cod_Categoria, 
           Des_Categoria
    FROM PRI_CATEGORIA
);
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA:  12/03/2019 | 25/06/2019
-- OBJETIVO: Metodo que traer
-- Procedimiento que permite recuperar los productos compuestos
-- EXEC USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto 'sul'
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto @Buscar VARCHAR(512)
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         -- SET @Buscar = REPLACE(@Buscar,'%',' ');
--         SELECT PD.Id_Producto, 
--                PD.Item_Detalle, 
--                PD.Id_ProductoDetalle, 
--                PD.Cod_TipoDetalle, 
--                PD.Cantidad, 
--                PD.Cod_UnidadMedida, 
--                UM.Nom_UnidadMedida, 
--                TDP.Nom_TipoDetallePro, 
--                P.Nom_Producto AS Nom_Producto, 
--                P_.Nom_Producto AS Nom_Producto_com
--         FROM PRI_PRODUCTO_DETALLE AS PD
--              INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
--              INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
--              INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
--              INNER JOIN PRI_PRODUCTOS AS P_ ON PD.Id_Producto = P_.Id_Producto
--         WHERE(P.Cod_Producto LIKE @Buscar)
--              OR (P.Nom_Producto LIKE '%' + @Buscar + '%');
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_TXIdProducto_Compuesto @Buscar VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT PD.Id_Producto, 
               PD.Item_Detalle, 
               PD.Id_ProductoDetalle, 
               PD.Cod_TipoDetalle, 
               PD.Cantidad, 
               PD.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               TDP.Nom_TipoDetallePro, 
               P.Nom_Producto AS Nom_Producto, 
               P_.Nom_Producto AS Nom_Producto_com
        FROM PRI_PRODUCTO_DETALLE AS PD
             INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
             INNER JOIN PRI_PRODUCTOS AS P_ ON PD.Id_Producto = P_.Id_Producto
        WHERE(P.Cod_Producto LIKE @Buscar)
             OR (P.Nom_Producto LIKE '%' + @Buscar + '%');
    END;
GO
-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_VEHICULOS_TXId_ClienteProveedor'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_VEHICULOS_TXId_ClienteProveedor;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_VEHICULOS_TXId_ClienteProveedor @Id_ClienteProveedor AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_ClienteProveedor, 
               Cod_Placa, 
               Color, 
               Marca, 
               Modelo, 
               Propiestarios, 
               Sede, 
               Placa_Vigente
        FROM PRI_CLIENTE_VEHICULOS
        WHERE Id_ClienteProveedor = @Id_ClienteProveedor;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PROGRAMADOR_TAREAS_TraerXNombre'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre @Nombre_Tarea VARCHAR(MAX)
WITH ENCRYPTION
AS
     SELECT s.job_id, 
            s.originating_server_id, 
            s.name, 
            CAST(s.enabled AS BIT) enabled, 
            s.description, 
            s.start_step_id, 
            s.category_id, 
            s.owner_sid, 
            s.notify_level_eventlog, 
            s.notify_level_email, 
            s.notify_level_netsend, 
            s.notify_level_page, 
            s.notify_email_operator_id, 
            s.notify_netsend_operator_id, 
            s.notify_page_operator_id, 
            s.delete_level, 
            s.date_created, 
            s.date_modified, 
            s.version_number
     FROM msdb.dbo.sysjobs s
     WHERE(name = @Nombre_Tarea);
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 09/10/2015, 14/06/2019
-- OBJETIVO: Metodo que traer todos los contometros ahora traer todos
-- USP_CAJ_MEDICION_TANQUE_XCajaTurno '101', '28/09/2015'
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_MEDICION_TANQUE_XCajaTurno'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_MEDICION_TANQUE_XCajaTurno;
GO
CREATE PROCEDURE USP_CAJ_MEDICION_TANQUE_XCajaTurno @Cod_Caja  VARCHAR(32), 
                                                    @Cod_Turno VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Medicion, 
               Cod_AMedir, 
               Medio_AMedir, 
               Medida_Anterior, 
               Medida_Actual, 
               Cod_Turno, 
               AMedir, 
               SUM(Ventas) AS Ventas, 
               SUM(Compras) AS Compras, 
               Medida_Anterior - SUM(Ventas) + SUM(Compras) AS Saldo
        FROM
        (
            SELECT ISNULL(M.Id_Medicion, 0) AS Id_Medicion, 
                   ISNULL(M.Cod_AMedir, A.Cod_Almacen) AS Cod_AMedir, 
                   ISNULL(M.Medio_AMedir, 'TANQUE') AS Medio_AMedir, 
                   ISNULL(M.Medida_Anterior, 0.000) AS Medida_Anterior, 
                   ISNULL(M.Medida_Actual, 0.000) AS Medida_Actual, 
                   ISNULL(M.Cod_Turno, @Cod_Turno) AS Cod_Turno, 
                   A.Des_Almacen AS AMedir, 
                   SUM(CASE
                           WHEN P.Cod_Libro = '14'
                           THEN D.Despachado
                           ELSE 0
                       END) AS Ventas, 
                   SUM(CASE
                           WHEN P.Cod_Libro = '08'
                           THEN D.Despachado
                           ELSE 0
                       END) AS Compras
            FROM CAJ_COMPROBANTE_D AS D
                 INNER JOIN CAJ_COMPROBANTE_PAGO AS P ON D.id_ComprobantePago = P.id_ComprobantePago
                 INNER JOIN ALM_ALMACEN AS A
                 INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen ON D.Cod_Almacen = A.Cod_Almacen
                                                                                        AND P.Cod_Caja = CA.Cod_Caja
                 INNER JOIN CAJ_MEDICION_VC AS M ON P.Cod_Turno = M.Cod_Turno
                                                    AND A.Cod_Almacen = M.Cod_AMedir
            WHERE Medio_AMedir = 'TANQUE'
                  AND A.Cod_TipoAlmacen = '03'
                  AND Flag_Despachado = 1
                  AND ca.Cod_Caja = @Cod_Caja
                  AND M.Cod_Turno = @Cod_Turno
            GROUP BY ISNULL(M.Id_Medicion, 0), 
                     ISNULL(M.Cod_AMedir, A.Cod_Almacen), 
                     ISNULL(M.Medio_AMedir, 'TANQUE'), 
                     ISNULL(M.Medida_Anterior, 0.000), 
                     ISNULL(M.Medida_Actual, 0.000), 
                     ISNULL(M.Cod_Turno, @Cod_Turno), 
                     A.Des_Almacen, 
                     D.Cod_Almacen, 
                     P.Cod_Libro
            UNION -- los ingresos a almacen
            SELECT ISNULL(M.Id_Medicion, 0) AS Id_Medicion, 
                   ISNULL(M.Cod_AMedir, A.Cod_Almacen) AS Cod_AMedir, 
                   ISNULL(M.Medio_AMedir, 'TANQUE') AS Medio_AMedir, 
                   ISNULL(M.Medida_Anterior, 0.000) AS Medida_Anterior, 
                   ISNULL(M.Medida_Actual, 0.000) AS Medida_Actual, 
                   ISNULL(M.Cod_Turno, @Cod_Turno) AS Cod_Turno, 
                   A.Des_Almacen AS AMedir, 
                   SUM(CASE
                           WHEN AM.Cod_TipoComprobante = 'NS'
                           THEN MD.Cantidad
                           ELSE 0
                       END) AS Ventas, 
                   SUM(CASE
                           WHEN AM.Cod_TipoComprobante = 'NE'
                           THEN MD.Cantidad
                           ELSE 0
                       END) AS Compras
            FROM ALM_ALMACEN AS A
                 INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                 INNER JOIN ALM_ALMACEN_MOV AS AM ON A.Cod_Almacen = AM.Cod_Almacen
                 INNER JOIN ALM_ALMACEN_MOV_D AS MD ON AM.Id_AlmacenMov = MD.Id_AlmacenMov
                 INNER JOIN CAJ_MEDICION_VC AS M ON AM.Cod_Turno = M.Cod_Turno
                                                    AND A.Cod_Almacen = M.Cod_AMedir
            WHERE(A.Cod_TipoAlmacen = '03')
                 AND (CA.Cod_Caja = @Cod_Caja)
                 AND (M.Medio_AMedir = 'TANQUE')
                 AND (M.Cod_Turno = @Cod_Turno)
            GROUP BY ISNULL(M.Id_Medicion, 0), 
                     ISNULL(M.Cod_AMedir, A.Cod_Almacen), 
                     ISNULL(M.Medio_AMedir, 'TANQUE'), 
                     ISNULL(M.Medida_Anterior, 0.000), 
                     ISNULL(M.Medida_Actual, 0.000), 
                     ISNULL(M.Cod_Turno, @Cod_Turno), 
                     A.Des_Almacen, 
                     AM.Cod_TipoComprobante
        ) AS Tanque
        GROUP BY Id_Medicion, 
                 Cod_AMedir, 
                 Medio_AMedir, 
                 Medida_Anterior, 
                 Medida_Actual, 
                 Cod_Turno, 
                 AMedir;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TXPlaca'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPlaca;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPlaca @Cod_Placa VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT CV.Cod_Placa, 
               CP.Cliente, 
               CV.Marca, 
               CV.Modelo, 
               CP.Id_ClienteProveedor, 
               CP.Nro_Documento, 
               CP.Direccion
        FROM PRI_CLIENTE_VEHICULOS AS CV
             INNER JOIN PRI_CLIENTE_PROVEEDOR AS CP ON CV.Id_ClienteProveedor = CP.Id_ClienteProveedor
        WHERE(CV.Cod_Placa = REPLACE(REPLACE(REPLACE(@Cod_Placa, '-', ''), '.', ''), ' ', ''));
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA: 24/04/2019 | 25/06/2019
-- OBJETIVO: Procedimiento que Lista los productos indicando el Tipo de producto PRL(Lote),PRS(Serie)
-- Procedimiento que permite recuperar las parte del producto
-- EXEC USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE 100,'kit fa',null,null,'001',0,'GENERAL',2881,'a101'
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE @Cod_Caja AS           VARCHAR(32)  = NULL, 
--                                                      @Buscar             VARCHAR(512), 
--                                                      @CodTipoProducto AS    VARCHAR(8)   = NULL, 
--                                                      @Cod_Categoria AS      VARCHAR(32)  = NULL, 
--                                                      @Cod_Precio AS         VARCHAR(32)  = NULL, 
--                                                      @Flag_RequiereStock AS BIT          = 0, 
--                                                      @Tipo_Busqueda      VARCHAR(50), 
--                                                      @IdProducto         INT, 
--                                                      @Cod_Almacen        VARCHAR(32)
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         SET DATEFORMAT DMY;
--         SET @Buscar = REPLACE(@Buscar, '%', ' ');
--         IF(@Tipo_Busqueda = 'GENERAL')
--             BEGIN
--                 SELECT P.Id_Producto, 
--                        P.Nom_Producto AS Nom_Producto, 
--                        P.Cod_Producto,
--                        CASE
--                            WHEN p.Cod_TipoProducto = 'SER'
--                            THEN 0
--                            ELSE PS.Stock_Act
--                        END Stock_Act, 
--                        PS.Precio_Venta, 
--                        M.Nom_Moneda AS Nom_Moneda, 
--                        PS.Cod_Almacen, 
--                        0 AS Descuento, 
--                        'NINGUNO' AS TipoDescuento, 
--                        A.Des_Almacen AS Des_Almacen, 
--                        PS.Cod_UnidadMedida, 
--                        UM.Nom_UnidadMedida, 
--                        P.Flag_Stock, 
--                        PS.Precio_Compra,
--                        CASE
--                            WHEN @Cod_Precio IS NULL
--                            THEN 0
--                            ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--                        END AS Precio, 
--                        P.Cod_TipoOperatividad, 
--                        PS.Cod_Moneda, 
--                        Cod_TipoProducto AS TipoProducto, 
--                        STUFF(
--                 (
--                     SELECT '|' + CONCAT(Nom_Producto, ' ')
--                     FROM [dbo].[PRI_PRODUCTO_DETALLE] T
--                          INNER JOIN PRI_PRODUCTOS PPRO ON(T.[Id_ProductoDetalle] = PPRO.Id_Producto)
--                     WHERE T.[Cod_TipoDetalle] = 'PAR'
--                           AND T.[Id_Producto] = P.Id_Producto FOR XML PATH('')
--                 ), 1, 1, '') AS Parte
--                 FROM PRI_PRODUCTOS AS P
--                      INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--                      INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--                      INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--                      INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--                      INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--                 WHERE(P.Cod_TipoProducto = @CodTipoProducto
--                       OR @CodTipoProducto IS NULL)
--                      AND ((P.Cod_Producto LIKE @Buscar)
--                           OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--                           OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--                           OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--                      AND (P.Cod_Categoria IN
--                 (
--                     SELECT Cod_Categoria
--                     FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--                 )
--                 OR @Cod_Categoria IS NULL)
--                      AND (ca.Cod_Caja = @Cod_Caja
--                           OR @Cod_Caja IS NULL)
--                      AND (P.Flag_Activo = 1)  
--                 -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
--                 ORDER BY Nom_Producto;
--         END;
--             ELSE
--             IF(@Tipo_Busqueda = 'GENERAL_CON_ALMACEN')
--                 BEGIN
--                     SELECT P.Id_Producto, 
--                            P.Nom_Producto AS Nom_Producto, 
--                            P.Cod_Producto,
--                            CASE
--                                WHEN p.Cod_TipoProducto = 'SER'
--                                THEN 0
--                                ELSE PS.Stock_Act
--                            END Stock_Act, 
--                            PS.Precio_Venta, 
--                            M.Nom_Moneda AS Nom_Moneda, 
--                            PS.Cod_Almacen, 
--                            0 AS Descuento, 
--                            'NINGUNO' AS TipoDescuento, 
--                            A.Des_Almacen AS Des_Almacen, 
--                            PS.Cod_UnidadMedida, 
--                            UM.Nom_UnidadMedida, 
--                            P.Flag_Stock, 
--                            PS.Precio_Compra,
--                            CASE
--                                WHEN @Cod_Precio IS NULL
--                                THEN 0
--                                ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--                            END AS Precio, 
--                            P.Cod_TipoOperatividad, 
--                            PS.Cod_Moneda, 
--                            Cod_TipoProducto AS TipoProducto, 
--                            STUFF(
--                     (
--                         SELECT '|' + CONCAT(Nom_Producto, ' ')
--                         FROM [dbo].[PRI_PRODUCTO_DETALLE] T
--                              INNER JOIN PRI_PRODUCTOS PPRO ON(T.[Id_ProductoDetalle] = PPRO.Id_Producto)
--                         WHERE T.[Cod_TipoDetalle] = 'PAR'
--                               AND T.[Id_Producto] = P.Id_Producto FOR XML PATH('')
--                     ), 1, 1, '') AS Parte
--                     FROM PRI_PRODUCTOS AS P
--                          INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
--                          INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--                          INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--                          INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
--                          INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
--                     WHERE(P.Cod_TipoProducto = @CodTipoProducto
--                           OR @CodTipoProducto IS NULL)
--                          AND ((P.Cod_Producto LIKE @Buscar)
--                               OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
--                               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
--                               OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
--                          AND (P.Cod_Categoria IN
--                     (
--                         SELECT Cod_Categoria
--                         FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
--                     )
--                     OR @Cod_Categoria IS NULL)
--                          AND (ca.Cod_Caja = @Cod_Caja
--                               OR @Cod_Caja IS NULL)
--                          AND (P.Flag_Activo = 1)
--                          AND (ps.Cod_Almacen = @Cod_Almacen)
--                     -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
--                     ORDER BY Nom_Producto;
--             END;
--                 ELSE
--                 IF(@Tipo_Busqueda = 'SUMINISTRO')
--                     BEGIN
--                         SELECT P.Id_Producto, 
--                                P.Nom_Producto AS Nom_Producto, 
--                                P.Cod_Producto,
--                                CASE
--                                    WHEN p.Cod_TipoProducto = 'SER'
--                                    THEN 0
--                                    ELSE PS.Stock_Act
--                                END Stock_Act, 
--                                PS.Precio_Venta, 
--                                M.Nom_Moneda AS Nom_Moneda, 
--                                PS.Cod_Almacen, 
--                                0 AS Descuento, 
--                                'NINGUNO' AS TipoDescuento, 
--                                A.Des_Almacen AS Des_Almacen, 
--                                PS.Cod_UnidadMedida, 
--                                UM.Nom_UnidadMedida, 
--                                P.Flag_Stock, 
--                                PS.Precio_Compra, 
--                                P.Cod_TipoOperatividad AS Cod_TipoOperatividad, 
--                                PS.Cod_Moneda, 
--                                Cod_TipoProducto AS TipoProducto, 
--                                PD.[Id_ProductoDetalle], 
--                                PD.Cantidad AS Cant_Equivalente, 
--                                PD.Cod_TipoDetalle
--                         FROM PRI_PRODUCTO_DETALLE AS PD
--                              INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
--                              INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
--                              INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
--                              INNER JOIN PRI_PRODUCTO_STOCK AS PS ON PD.Id_ProductoDetalle = PS.Id_Producto
--                              INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--                              INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--                         WHERE PD.Cod_TipoDetalle = 'SUM'
--                               AND PD.Id_Producto = @IdProducto
--                               AND ps.Cod_Almacen = @Cod_Almacen;
--                 END;
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar_TIPO_PARTE @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                     @Buscar             VARCHAR(512), 
                                                     @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                                     @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                                     @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                                     @Flag_RequiereStock AS BIT          = 0, 
                                                     @Tipo_Busqueda      VARCHAR(50), 
                                                     @IdProducto         INT, 
                                                     @Cod_Almacen        VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        IF(@Tipo_Busqueda = 'GENERAL')
            BEGIN
                SELECT P.Id_Producto, 
                       P.Nom_Producto AS Nom_Producto, 
                       P.Cod_Producto,
                       CASE
                           WHEN p.Cod_TipoProducto = 'SER'
                           THEN 0
                           ELSE PS.Stock_Act
                       END Stock_Act, 
                       PS.Precio_Venta, 
                       M.Nom_Moneda AS Nom_Moneda, 
                       PS.Cod_Almacen, 
                       0 AS Descuento, 
                       'NINGUNO' AS TipoDescuento, 
                       A.Des_Almacen AS Des_Almacen, 
                       PS.Cod_UnidadMedida, 
                       UM.Nom_UnidadMedida, 
                       P.Flag_Stock, 
                       PS.Precio_Compra,
                       CASE
                           WHEN @Cod_Precio IS NULL
                           THEN 0
                           ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
                       END AS Precio, 
                       P.Cod_TipoOperatividad, 
                       PS.Cod_Moneda, 
                       Cod_TipoProducto AS TipoProducto, 
                       STUFF(
                (
                    SELECT '|' + CONCAT(Nom_Producto, ' ')
                    FROM [dbo].[PRI_PRODUCTO_DETALLE] T
                         INNER JOIN PRI_PRODUCTOS PPRO ON(T.[Id_ProductoDetalle] = PPRO.Id_Producto)
                    WHERE T.[Cod_TipoDetalle] = 'PAR'
                          AND T.[Id_Producto] = P.Id_Producto FOR XML PATH('')
                ), 1, 1, '') AS Parte
                FROM PRI_PRODUCTOS AS P
                     INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                     INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
                     INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
                     INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
                     INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                WHERE(P.Cod_TipoProducto = @CodTipoProducto
                      OR @CodTipoProducto IS NULL)
                     AND ((P.Cod_Producto LIKE @Buscar)
                          OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                          OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                          OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
                     AND (P.Cod_Categoria IN
                (
                    SELECT Cod_Categoria
                    FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
                )
                OR @Cod_Categoria IS NULL)
                     AND (ca.Cod_Caja = @Cod_Caja
                          OR @Cod_Caja IS NULL)
                     AND (P.Flag_Activo = 1)  
                -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
                ORDER BY Nom_Producto;
        END;
            ELSE
            IF(@Tipo_Busqueda = 'GENERAL_CON_ALMACEN')
                BEGIN
                    SELECT P.Id_Producto, 
                           P.Nom_Producto AS Nom_Producto, 
                           P.Cod_Producto,
                           CASE
                               WHEN p.Cod_TipoProducto = 'SER'
                               THEN 0
                               ELSE PS.Stock_Act
                           END Stock_Act, 
                           PS.Precio_Venta, 
                           M.Nom_Moneda AS Nom_Moneda, 
                           PS.Cod_Almacen, 
                           0 AS Descuento, 
                           'NINGUNO' AS TipoDescuento, 
                           A.Des_Almacen AS Des_Almacen, 
                           PS.Cod_UnidadMedida, 
                           UM.Nom_UnidadMedida, 
                           P.Flag_Stock, 
                           PS.Precio_Compra,
                           CASE
                               WHEN @Cod_Precio IS NULL
                               THEN 0
                               ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
                           END AS Precio, 
                           P.Cod_TipoOperatividad, 
                           PS.Cod_Moneda, 
                           Cod_TipoProducto AS TipoProducto, 
                           STUFF(
                    (
                        SELECT '|' + CONCAT(Nom_Producto, ' ')
                        FROM [dbo].[PRI_PRODUCTO_DETALLE] T
                             INNER JOIN PRI_PRODUCTOS PPRO ON(T.[Id_ProductoDetalle] = PPRO.Id_Producto)
                        WHERE T.[Cod_TipoDetalle] = 'PAR'
                              AND T.[Id_Producto] = P.Id_Producto FOR XML PATH('')
                    ), 1, 1, '') AS Parte
                    FROM PRI_PRODUCTOS AS P
                         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
                         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
                         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
                         INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
                    WHERE(P.Cod_TipoProducto = @CodTipoProducto
                          OR @CodTipoProducto IS NULL)
                         AND ((P.Cod_Producto LIKE @Buscar)
                              OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                              OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
                         AND (P.Cod_Categoria IN
                    (
                        SELECT Cod_Categoria
                        FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
                    )
                    OR @Cod_Categoria IS NULL)
                         AND (ca.Cod_Caja = @Cod_Caja
                              OR @Cod_Caja IS NULL)
                         AND (P.Flag_Activo = 1)
                         AND (ps.Cod_Almacen = @Cod_Almacen)
                    -- AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
                    ORDER BY Nom_Producto;
            END;
                ELSE
                BEGIN
                    SELECT P.Id_Producto, 
                           P.Nom_Producto AS Nom_Producto, 
                           P.Cod_Producto,
                           CASE
                               WHEN p.Cod_TipoProducto = 'SER'
                               THEN 0
                               ELSE PS.Stock_Act
                           END Stock_Act, 
                           PS.Precio_Venta, 
                           M.Nom_Moneda AS Nom_Moneda, 
                           PS.Cod_Almacen, 
                           0 AS Descuento, 
                           'NINGUNO' AS TipoDescuento, 
                           A.Des_Almacen AS Des_Almacen, 
                           PS.Cod_UnidadMedida, 
                           UM.Nom_UnidadMedida, 
                           P.Flag_Stock, 
                           PS.Precio_Compra, 
                           P.Cod_TipoOperatividad AS Cod_TipoOperatividad, 
                           PS.Cod_Moneda, 
                           Cod_TipoProducto AS TipoProducto, 
                           PD.[Id_ProductoDetalle], 
                           PD.Cantidad AS Cant_Equivalente, 
                           PD.Cod_TipoDetalle
                    FROM PRI_PRODUCTO_DETALLE AS PD
                         INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
                         INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
                         INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
                         INNER JOIN PRI_PRODUCTO_STOCK AS PS ON PD.Id_ProductoDetalle = PS.Id_Producto
                         INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
                         INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
                    WHERE PD.Cod_TipoDetalle = @Tipo_Busqueda
                          AND PD.Id_Producto = @IdProducto
                          AND ps.Cod_Almacen = @Cod_Almacen;
            END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA:  12/03/2019 | 02/05/2019 | 25/06/2019
-- OBJETIVO: Metodo que permite obtener la lista de Los productos Kit
-- Procedimiento que permite recuperar los productos que son componentes de kit de un determinado producto
-- EXEC USP_PRI_PRODUCTO_DETALLE_KIT 4288,'001','a102'
--------------------------------------------------------------------------------------------------------------
-- IF EXISTS
-- (
--     SELECT name
--     FROM sysobjects
--     WHERE name = 'USP_PRI_PRODUCTO_DETALLE_KIT'
--           AND type = 'P'
-- )
--     DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_KIT;
-- GO
-- CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_KIT @IdProducto  INT, 
--                                               @Cod_Precio AS  VARCHAR(32) = NULL, 
--                                               @Cod_Almacen VARCHAR(32)
-- WITH ENCRYPTION
-- AS
--     BEGIN
--         -- SET @Buscar = REPLACE(@Buscar,'%',' ');
--         SELECT P.Id_Producto, 
--                P.Nom_Producto AS Nom_Producto, 
--                P.Cod_Producto, 
--                PS.Stock_Act, 
--                PS.Precio_Venta, 
--                M.Nom_Moneda AS Nom_Moneda, 
--                PS.Cod_Almacen, 
--                0 AS Descuento, 
--                'NINGUNO' AS TipoDescuento, 
--                A.Des_CortaAlmacen AS Des_Almacen, 
--                PD.Cod_UnidadMedida, 
--                UM.Nom_UnidadMedida, 
--                P.Flag_Stock, 
--                PS.Precio_Compra,
--                CASE
--                    WHEN @Cod_Precio IS NULL
--                    THEN 0
--                    ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
--                END AS Precio,
--         --P.Cod_TipoOperatividad 
--                'PAR' AS Cod_TipoOperatividad, 
--                PS.Cod_Moneda, 
--                Cod_TipoProducto AS TipoProducto, 
--                PD.[Id_ProductoDetalle], 
--                PD.Cantidad AS Cant_Equivalente
--         FROM PRI_PRODUCTO_DETALLE AS PD
--              INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
--              INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
--              INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
--              INNER JOIN PRI_PRODUCTO_STOCK AS PS ON PD.Id_ProductoDetalle = PS.Id_Producto
--              INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
--              INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
--         WHERE(PD.Id_Producto = @IdProducto
--               AND ps.Cod_Almacen = @Cod_Almacen)
--              AND PD.Cod_TipoDetalle = 'PAR';
--     END;
-- GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_DETALLE_KIT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_DETALLE_KIT;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_DETALLE_KIT @IdProducto  INT, 
                                              @Cod_Precio AS  VARCHAR(32) = NULL, 
                                              @Cod_Almacen VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        -- SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT P.Id_Producto, 
               P.Nom_Producto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda AS Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_CortaAlmacen AS Des_Almacen, 
               PD.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               P.Flag_Stock, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio,
        --P.Cod_TipoOperatividad 
               'PAR' AS Cod_TipoOperatividad, 
               PS.Cod_Moneda, 
               Cod_TipoProducto AS TipoProducto, 
               PD.[Id_ProductoDetalle], 
               PD.Cantidad AS Cant_Equivalente
        FROM PRI_PRODUCTO_DETALLE AS PD
             INNER JOIN VIS_TIPO_DETALLE_PRODUCTO AS TDP ON PD.Cod_TipoDetalle = TDP.Cod_TipoDetallePro
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PD.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN PRI_PRODUCTOS AS P ON PD.Id_ProductoDetalle = P.Id_Producto
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON PD.Id_ProductoDetalle = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
        WHERE(PD.Id_Producto = @IdProducto
              AND ps.Cod_Almacen = @Cod_Almacen)
             AND PD.Cod_TipoDetalle = 'PAR';
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: REYBER PALMA
-- FECHA: 27/11/2015
-- OBJETIVO: selectionar las serie de un Comprobante Pago
-- SELECT dbo.UFN_CAJ_COMPROBANTE_D_Serie(9,6)
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'UFN_CAJ_COMPROBANTE_D_Serie'
)
    DROP FUNCTION UFN_CAJ_COMPROBANTE_D_Serie;
GO
CREATE FUNCTION UFN_CAJ_COMPROBANTE_D_Serie
(@id_ComprobantePago AS INT, 
 @id_Detalle         INT
)
RETURNS VARCHAR(MAX)
WITH ENCRYPTION
AS
     BEGIN
         DECLARE @Detalle AS VARCHAR(MAX);
         --IF EXISTS(SELECT cs.Id_Tabla,cs.Item,cs.Cod_Tabla FROM CAJ_SERIES as cs WHERE cs.Id_Tabla=@id_ComprobantePago  AND cs.Item=@id_Detalle 
         --			AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO'
         --			GROUP BY cs.Id_Tabla,cs.Item,cs.Cod_Tabla
         --			HAVING SUM(ISNUMERIC(CS.Serie)) = count(*))
         --BEGIN
         -- SET @Detalle = STUFF(( 
         --    SELECT ' , '+ CASE WHEN Min(T.Serie)=MAX(T.Serie) THEN MAX(T.Serie) ELSE CONCAT (Min(T.Serie),' - ',MAX(T.Serie)) END +'' FROM 
         --    (SELECT  cs.Serie,CONVERT(bigint,cs.Serie) - ROW_NUMBER() OVER(ORDER BY cs.Serie) AS Grupo FROM dbo.CAJ_SERIES cs
         --    WHERE cs.Id_Tabla=@id_ComprobantePago  AND cs.Item=@id_Detalle AND cs.Cod_Tabla='CAJ_COMPROBANTE_PAGO') T 
         --    GROUP BY T.Grupo
         --    ORDER BY T.Grupo
         --							    FOR
         --								 XML PATH('')
         --                                   ), 1, 2, '') + ''
         --END
         --ELSE
         --BEGIN	
         SET @Detalle = STUFF(
         (
             SELECT DISTINCT 
                    ' , ' + Serie + ''
             FROM CAJ_SERIES
             WHERE Id_Tabla = @id_ComprobantePago
                   AND Item = @id_Detalle
                   AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO' FOR XML PATH('')
         ), 1, 2, '') + '';
         --END
         RETURN @Detalle;
     END;
GO
--------------------------------------------------------------------------------------------------------------
--  AUTOR:REYBER PALMA
-- FECHA:  15/07/2019
-- OBJETIVO: 
-- EXEC USP_PRI_CLIENTE_PROVEEDOR_ReiniciarConsultaVivos
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_ReiniciarConsultaVivos'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_ReiniciarConsultaVivos;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_ReiniciarConsultaVivos
WITH ENCRYPTION
AS
    BEGIN
        UPDATE PRI_CLIENTE_PROVEEDOR
          SET 
              PaginaWeb = 'REVISAR'
        WHERE Cod_TipoDocumento = '1'
              AND Cod_EstadoCliente = '001'
              AND Cod_CondicionCliente = '01';
    END;
GO

--------------------------------------------------------------------------------------------------------------
--  AUTOR:REYBER PALMA
-- FECHA:  15/07/2019
-- OBJETIVO: 
-- EXEC USP_PRI_CLIENTE_PROVEEDOR_T100Revision
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_T100Revision'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_T100Revision;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_T100Revision
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP 100 Id_ClienteProveedor, 
                       Nro_Documento, 
                       Cliente, 
                       PaginaWeb, 
                       Fecha_Reg
        FROM PRI_CLIENTE_PROVEEDOR
        WHERE Cod_TipoDocumento = '1'
              AND PaginaWeb = 'REVISAR';
    END;
GO
--------------------------------------------------------------------------------------------------------------
--  AUTOR:REYBER PALMA
-- FECHA:  15/07/2019
-- OBJETIVO: 
-- EXEC USP_PRI_CLIENTE_PROVEEDOR_EstaVivo 123,1
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_EstaVivo'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_EstaVivo;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_EstaVivo @Id_ClienteProveedor INT, 
                                                    @Vivo                BIT, 
                                                    @FechaDefuncion      DATETIME
WITH ENCRYPTION
AS
    BEGIN
        IF(@Vivo = 1)
            BEGIN
                UPDATE PRI_CLIENTE_PROVEEDOR
                  SET 
                      Cod_EstadoCliente = '001', 
                      Cod_CondicionCliente = '01', 
                      PaginaWeb = 'VIVO', 
                      Cod_TipoCliente = '002', 
                      Fecha_Act = GETDATE(), 
                      Fax = @FechaDefuncion
                WHERE Id_ClienteProveedor = @Id_ClienteProveedor;
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_PROVEEDOR
                  SET 
                      Cod_EstadoCliente = '003', 
                      Cod_CondicionCliente = '03', 
                      PaginaWeb = 'MUERTO', 
                      Cod_TipoCliente = '', 
                      Fecha_Act = GETDATE(), 
                      Fax = @FechaDefuncion
                WHERE Id_ClienteProveedor = @Id_ClienteProveedor;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guardar un elemento a CAJ_GUIA_REMISION_REMITENTE
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_G
--	@Id_GuiaRemisionRemitente = 0 OUTPUT,
--	@Cod_Caja = '101',
--	@Cod_Turno = 'N20/01/2018',
--	@Cod_TipoComprobante = 'GR',
--	@Cod_Libro = '14',
--	@Cod_Periodo = '2018-2',
--	@Serie = 'G001',
--	@Numero = '00000001',
--	@Fecha_Emision = '19/06/2018',
--	@Fecha_TrasladoBienes = '19/06/2018',
--	@Fecha_EntregaBienes = '19/06/2018',
--	@Cod_MotivoTraslado = '01',
--	@Des_MotivoTraslado = 'VENTA',
--	@Cod_ModalidadTraslado = '01',
--	@Cod_UnidadMedida = 'KGM',
--	@Id_ClienteDestinatario = 1024,
--	@Cod_UbigeoPartida = '080101',
--	@Direccion_Partida = 'CUSCO',
--	@Cod_UbigeoLlegada = '080101',
--	@Direccion_LLegada = 'CUSCO',
--	@Flag_Transbordo = 0,
--	@Peso_Bruto = 100,
--	@Nro_Contenedor = NULL,
--	@Cod_Puerto = NULL,
--	@Nro_Bulltos = NULL,
--	@Cod_EstadoGuia = 'EMI',
--	@Obs_GuiaRemisionRemitente = '',
--	@Id_GuiaRemisionRemitenteBaja = NULL,
--	@Flag_Anulado = 0,
--	@Valor_Resumen = NULL,
--	@Valor_Firma =NULL,
--	@Cod_Usuario = 'ADMINISTRADOR'
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
                                                   @Des_MotivoTraslado           VARCHAR(2048), 
                                                   @Cod_ModalidadTraslado        VARCHAR(5), 
                                                   @Cod_UnidadMedida             VARCHAR(5), 
                                                   @Id_ClienteDestinatario       INT, 
                                                   @Cod_UbigeoPartida            VARCHAR(8), 
                                                   @Direccion_Partida            VARCHAR(2048), 
                                                   @Cod_UbigeoLlegada            VARCHAR(8), 
                                                   @Direccion_LLegada            VARCHAR(2048), 
                                                   @Flag_Transbordo              BIT, 
                                                   @Peso_Bruto                   NUMERIC(38, 6), 
                                                   @Nro_Contenedor               VARCHAR(64), 
                                                   @Cod_Puerto                   VARCHAR(64), 
                                                   @Nro_Bulltos                  INT, 
                                                   @Cod_EstadoGuia               VARCHAR(8), 
                                                   @Obs_GuiaRemisionRemitente    VARCHAR(2048), 
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Eliminar un elemento a CAJ_GUIA_REMISION_REMITENTE
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_E
--	@Id_GuiaRemisionRemitente = 1024,
--	@Cod_Usuario = 'ADMINISTRADOR',
--	@Justificacion = 'ERROR'
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
                                                   @Justificacion            VARCHAR(2048)
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
            DECLARE @Vehiculos VARCHAR(2048)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrv.Placa, '|', cgrrv.Certificado_Inscripcion, '|', cgrrv.Certificado_Habilitacion)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_VEHICULOS cgrrv
                WHERE cgrrv.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los conductores
            DECLARE @Conductores VARCHAR(2048)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrt.Cod_TipoDocumento, '|', cgrrt.Numero_Documento, '|', cgrrt.Numero_Documento, '|', cgrrt.Licencia, '|', cgrrt.Cod_ModalidadTransporte)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS cgrrt
                WHERE cgrrt.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los detalles
            DECLARE @Detalles VARCHAR(2048)= STUFF(
            (
                SELECT ';' + CONCAT(CONVERT(VARCHAR(32), cgrrd.Id_Producto), '|', CONVERT(VARCHAR(54), cgrrd.Cantidad), '|', cgrrd.Descripcion)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_D cgrrd
                WHERE cgrrd.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos los relacionados
            DECLARE @Relacionados VARCHAR(2048)= STUFF(
            (
                SELECT ';' + CONCAT(cgrrr.Cod_TipoDocumento, '|', cgrrr.Serie, '|', cgrrr.Numero)
                FROM dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr
                WHERE cgrrr.Id_GuiaRemisionRemitente = @Id_GuiaRemisionRemitente FOR XML PATH('')
            ), 1, 2, '') + '';
            --Almacenamos la cabezera
            DECLARE @Cod_Eliminado VARCHAR(2048)= @Cod_Libro + '-' + @Cod_TipoComprobante + ':' + @Serie + '-' + @Numero;
            DECLARE @Cliente VARCHAR(2048)=
            (
                SELECT CONCAT(pcp.Cod_TipoComprobante, ':', pcp.Nro_Documento, '-', pcp.Cliente)
                FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
                WHERE pcp.Id_ClienteProveedor = @Id_ClienteDestinatario
            );
            --Concatenamos la Guia
            DECLARE @Detalle_Guia VARCHAR(2048)= @Detalles + ' # ' + @Conductores + ' # ' + @Vehiculos + ' # ' + @Relacionados;

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
            EXEC USP_PAR_FILA_G '079', '001', @id_Fila, @Cod_Eliminado, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '002', @id_Fila, 'CAJ_GUIA_REMISION_REMITENTE', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '003', @id_Fila, @Cliente, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '004', @id_Fila, @Detalle_Guia, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '005', @id_Fila, NULL, NULL, NULL, @Fecha_Emision, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '006', @id_Fila, NULL, NULL, NULL, @Fecha_Actual, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '007', @id_Fila, @Cod_Usuario, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '008', @id_Fila, @Justificacion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
            EXEC USP_PAR_FILA_G '079', '009', @id_Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento a CAJ_GUIA_REMISION_REMITENTE
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TXPK
--	@Id_GuiaRemisionRemitente = 1024
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_D
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_D_G
--	@Id_GuiaRemisionRemitente = 1024,
--	@Id_Detalle = 1,
--	@Cod_Almacen = '101',
--	@Cod_UnidadMedida = 'NIU',
--	@Id_Producto = 100,
--	@Cantidad = 1,
--	@Descripcion = 'PRODUCTO 1',
--	@Peso = 1,
--	@Obs_Detalle = '',
--	@Cod_ProductoSunat = NULL,
--	@Cod_Usuario = 'ADMINISTRADOR'
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
                                                     @Descripcion              VARCHAR(2048), 
                                                     @Peso                     NUMERIC(38, 6), 
                                                     @Obs_Detalle              VARCHAR(2048), 
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Elimina un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_D
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_D_E
--	@Id_GuiaRemisionRemitente = 1024,
--	@Id_Detalle = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_D
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_D_TXPK
--	@Id_GuiaRemisionRemitente = 1024,
--	@Id_Detalle = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_G
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1,
--	@Cod_TipoDocumento = '001',
--	@Id_DocRelacionado = 0,
--	@Serie = '',
--	@Numero = '0000001',
--	@Cod_TipoRelacion = 'GRR',
--	@Observacion = '',
--	@Cod_Usuario = 'ADMINISTRADOR'
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
                                                                @Observacion              VARCHAR(2048), 
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Elimina un elemento de USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_E
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento de USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS_TXPK
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_G
--	@Id_GuiaRemisionRemitente = 10247,
--	@Item = 1,
--	@Cod_TipoDocumento = '01',
--	@Numero = '00000001',
--	@Nombres = 'CLIENTES VARIOS',
--	@Direccion = 'SN NUMERAL',
--	@Cod_ModalidadTransporte = '01',
--	@Licencia = '123456',
--	@Observaciones = '',
--	@Cod_Usuario = 'ADMINSITRADOR'
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
                                                                  @Nombres                  VARCHAR(2048), 
                                                                  @Direccion                VARCHAR(2048), 
                                                                  @Cod_ModalidadTransporte  VARCHAR(5), 
                                                                  @Licencia                 VARCHAR(64), 
                                                                  @Observaciones            VARCHAR(2048), 
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Elimina un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_E
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS_TXPK
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_G
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1,
--	@Placa = '123456',
--	@Certificado_Inscripcion = '',
--	@Certificado_Habilitacion = '',
--	@Observaciones = '',
--	@Cod_Usuario = 'ADMINISTRADOR'
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
                                                             @Observaciones            VARCHAR(2048), 
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Elimina un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_E
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento a USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_VEHICULOS_TXPK
--	@Id_GuiaRemisionRemitente = 1024,
--	@Item = 1
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

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Obtiene una guia de remision remitente por el cod de libro, tipo, serie y numero
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TXCodLibro_CodTipoComprobante_Serie_Numero
--	@Cod_Libro = '14',
--	@Cod_TipoComprobante = 'GRR',
--	@Serie = 'G001',
--	@Numero = '00000001'
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los tipos de comprobantes autorizados por cod libro y cod caja
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXCodLibroCodCaja
--	@Cod_Libro = '14',
--	@Cod_Caja = '101'
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

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un nuemro siguiente en base al comprobante, la serie y el libro
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_NumeroXTipoSerieLibro
--	@Cod_TipoComprobante = 'GRR',
--	@Serie = 'G001',
--	@Cod_Libro = '14'
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
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los comprobantes relacionados a las guias por numero de documento de cliente
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXDocClienteTipoguia
--	@NumDocumento = '00000001',
--	@TipoGuia = 'GRR'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXDocClienteTipoguia'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXDocClienteTipoguia;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXDocClienteTipoguia @NumDocumento VARCHAR(32), 
                                                                                      @TipoGuia     VARCHAR(32)
AS
    BEGIN
        IF @TipoGuia = 'GRE'
           OR @TipoGuia = 'GRR'
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Doc_Cliente = @NumDocumento
                      AND ccp.Flag_Anulado = 0
                      AND ccp.Cod_TipoComprobante IN('BE', 'FE', 'BO', 'FA', 'TKB', 'TKF')
                EXCEPT
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr ON cgrrr.Id_DocRelacionado = ccp.id_ComprobantePago
                                                                                      AND cgrrr.Cod_TipoRelacion = 'GRR'
                                                                                      AND ccp.Cod_TipoComprobante = cgrrr.Cod_TipoDocumento
                                                                                      AND cgrrr.Cod_TipoDocumento IN('BE', 'FE', 'BO', 'FA', 'TKB', 'TKF')
                WHERE ccp.Doc_Cliente = @NumDocumento
                      AND ccp.Flag_Anulado = 0;
        END;
            ELSE
            BEGIN
                --Solo facturas electronicas
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Doc_Cliente = @NumDocumento
                      AND ccp.Flag_Anulado = 0
                      AND ccp.Cod_TipoComprobante = 'FE'
                EXCEPT
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr ON cgrrr.Id_DocRelacionado = ccp.id_ComprobantePago
                                                                                      AND cgrrr.Cod_TipoRelacion = 'GRR'
                                                                                      AND ccp.Cod_TipoComprobante = cgrrr.Cod_TipoDocumento
                                                                                      AND cgrrr.Cod_TipoDocumento = 'FE'
                WHERE ccp.Doc_Cliente = @NumDocumento
                      AND ccp.Flag_Anulado = 0;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los comprobantes relacionados a las guias por nombre de cliente
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXNomClienteTipoguia
--	@NomCliente = 'VARIOS',
--	@TipoGuia = 'GRR'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXNomClienteTipoguia'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXNomClienteTipoguia;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerComprobantesXNomClienteTipoguia @NomCliente VARCHAR(1024), 
                                                                                      @TipoGuia   VARCHAR(32)
AS
    BEGIN
        IF @TipoGuia = 'GRE'
           OR @TipoGuia = 'GRR'
            BEGIN
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Nom_Cliente LIKE '%' + @NomCliente + '%'
                      AND ccp.Flag_Anulado = 0
                      AND ccp.Cod_TipoComprobante IN('BE', 'FE', 'BO', 'FA', 'TKB', 'TKF')
                EXCEPT
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr ON cgrrr.Id_DocRelacionado = ccp.id_ComprobantePago
                                                                                      AND cgrrr.Cod_TipoRelacion = 'GRR'
                                                                                      AND ccp.Cod_TipoComprobante = cgrrr.Cod_TipoDocumento
                                                                                      AND cgrrr.Cod_TipoDocumento IN('BE', 'FE', 'BO', 'FA', 'TKB', 'TKF')
                WHERE ccp.Nom_Cliente LIKE '%' + @NomCliente + '%'
                      AND ccp.Flag_Anulado = 0;
        END;
            ELSE
            BEGIN
                --Solo facturas electronicas
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                WHERE ccp.Nom_Cliente LIKE '%' + @NomCliente + '%'
                      AND ccp.Flag_Anulado = 0
                      AND ccp.Cod_TipoComprobante = 'FE'
                EXCEPT
                SELECT DISTINCT 
                       ccp.id_ComprobantePago,
                       CASE
                           WHEN ccp.Cod_Libro = '08'
                           THEN 'COMPRA'
                           ELSE 'VENTA'
                       END Operacion, 
                       UPPER(CONCAT(ccp.Cod_TipoComprobante, ':', ccp.Serie, '-', RIGHT('00000000' + LTRIM(RTRIM(ccp.Numero)), 8))) CodSerieNumero, 
                       ccp.Id_Cliente, 
                       ccp.Doc_Cliente, 
                       ccp.Nom_Cliente, 
                       ccp.FechaEmision, 
                       ccp.Total
                FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                     INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr ON cgrrr.Id_DocRelacionado = ccp.id_ComprobantePago
                                                                                      AND cgrrr.Cod_TipoRelacion = 'GRR'
                                                                                      AND ccp.Cod_TipoComprobante = cgrrr.Cod_TipoDocumento
                                                                                      AND cgrrr.Cod_TipoDocumento = 'FE'
                WHERE ccp.Nom_Cliente LIKE '%' + @NomCliente + '%'
                      AND ccp.Flag_Anulado = 0;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los comprobantes relacionados a las guias por id de comprobante
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_CAJ_GUIA_REMISION_REMITENTE_TraerFacturasGuiasXIdComprobante
--	@Id_ComprobantePago = 1024
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_GUIA_REMISION_REMITENTE_TraerFacturasGuiasXIdComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerFacturasGuiasXIdComprobante;
GO
CREATE PROCEDURE USP_CAJ_GUIA_REMISION_REMITENTE_TraerFacturasGuiasXIdComprobante @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cgrr.Id_GuiaRemisionRemitente, 
               cgrr.Cod_Caja, 
               cgrr.Cod_Turno, 
               cgrr.Cod_TipoComprobante, 
               cgrr.Cod_Libro, 
               cgrr.Cod_Periodo, 
               cgrr.Serie, 
               cgrr.Numero, 
               cgrr.Fecha_Emision, 
               cgrr.Fecha_TrasladoBienes, 
               cgrr.Fecha_EntregaBienes, 
               cgrr.Cod_MotivoTraslado, 
               cgrr.Des_MotivoTraslado, 
               cgrr.Cod_ModalidadTraslado, 
               cgrr.Cod_UnidadMedida, 
               cgrr.Id_ClienteDestinatario, 
               cgrr.Cod_UbigeoPartida, 
               cgrr.Direccion_Partida, 
               cgrr.Cod_UbigeoLlegada, 
               cgrr.Direccion_LLegada, 
               cgrr.Flag_Transbordo, 
               cgrr.Peso_Bruto, 
               cgrr.Nro_Contenedor, 
               cgrr.Cod_Puerto, 
               cgrr.Nro_Bulltos, 
               cgrr.Cod_EstadoGuia, 
               cgrr.Obs_GuiaRemisionRemitente, 
               cgrr.Id_GuiaRemisionRemitenteBaja, 
               cgrr.Flag_Anulado, 
               cgrr.Valor_Resumen, 
               cgrr.Valor_Firma
        FROM dbo.CAJ_GUIA_REMISION_REMITENTE cgrr
             INNER JOIN dbo.CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS cgrrr ON cgrr.Id_GuiaRemisionRemitente = cgrrr.Id_GuiaRemisionRemitente
                                                                              AND cgrrr.Cod_TipoDocumento = 'FE'
                                                                              AND cgrrr.Cod_TipoRelacion = 'GRR'
        WHERE cgrrr.Id_DocRelacionado = @Id_ComprobantePago
              AND cgrr.Flag_Anulado = 0;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento en PRI_PRODUCTOS
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_G;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_G @Id_Producto          INT OUTPUT, 
                                     @Cod_Producto         VARCHAR(64), 
                                     @Cod_Categoria        VARCHAR(32), 
                                     @Cod_Marca            VARCHAR(32), 
                                     @Cod_TipoProducto     VARCHAR(5), 
                                     @Nom_Producto         VARCHAR(512), 
                                     @Des_CortaProducto    VARCHAR(512), 
                                     @Des_LargaProducto    VARCHAR(1024), 
                                     @Caracteristicas      VARCHAR(MAX), 
                                     @Porcentaje_Utilidad  NUMERIC(5, 2), 
                                     @Cuenta_Contable      VARCHAR(16), 
                                     @Contra_Cuenta        VARCHAR(16), 
                                     @Cod_Garantia         VARCHAR(5), 
                                     @Cod_TipoExistencia   VARCHAR(5), 
                                     @Cod_TipoOperatividad VARCHAR(5), 
                                     @Flag_Activo          BIT, 
                                     @Flag_Stock           BIT, 
                                     @Cod_Fabricante       VARCHAR(64), 
                                     @Obs_Producto         XML, 
                                     @Cod_ProductoSunat    VARCHAR(64), 
                                     @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Producto
            FROM PRI_PRODUCTOS
            WHERE(Id_Producto = @Id_Producto)
        )
            BEGIN
                INSERT INTO dbo.PRI_PRODUCTOS
                (
                    --Id_Producto - column value is auto-generated
                    Cod_Producto,
                    Cod_Categoria,
                    Cod_Marca,
                    Cod_TipoProducto,
                    Nom_Producto,
                    Des_CortaProducto,
                    Des_LargaProducto,
                    Caracteristicas,
                    Porcentaje_Utilidad,
                    Cuenta_Contable,
                    Contra_Cuenta,
                    Cod_Garantia,
                    Cod_TipoExistencia,
                    Cod_TipoOperatividad,
                    Flag_Activo,
                    Flag_Stock,
                    Cod_Fabricante,
                    Obs_Producto,
                    Cod_ProductoSunat,
                    Cod_UsuarioReg,
                    Fecha_Reg,
                    Cod_UsuarioAct,
                    Fecha_Act
                )
                VALUES
                (@Cod_Producto, 
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
                 @Cod_ProductoSunat, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_Producto = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTOS
                  SET 
                      Cod_Producto = @Cod_Producto, 
                      Cod_Categoria = @Cod_Categoria, 
                      Cod_Marca = @Cod_Marca, 
                      Cod_TipoProducto = @Cod_TipoProducto, 
                      Nom_Producto = @Nom_Producto, 
                      Des_CortaProducto = @Des_CortaProducto, 
                      Des_LargaProducto = @Des_LargaProducto, 
                      Caracteristicas = @Caracteristicas, 
                      Porcentaje_Utilidad = @Porcentaje_Utilidad, 
                      Cuenta_Contable = @Cuenta_Contable, 
                      Contra_Cuenta = @Contra_Cuenta, 
                      Cod_Garantia = @Cod_Garantia, 
                      Cod_TipoExistencia = @Cod_TipoExistencia, 
                      Cod_TipoOperatividad = @Cod_TipoOperatividad, 
                      Flag_Activo = @Flag_Activo, 
                      Flag_Stock = @Flag_Stock, 
                      Cod_Fabricante = @Cod_Fabricante, 
                      Obs_Producto = @Obs_Producto, 
                      Cod_ProductoSunat = @Cod_ProductoSunat, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae todos los elementos de PRI_PRODUCTOS
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_TT;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pp.*
        FROM PRI_PRODUCTOS pp;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae Los elementos paginados de PRI_PRODUCTOS
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_TP;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_TP @TamañoPagina VARCHAR(16), 
                                      @NumeroPagina VARCHAR(16), 
                                      @ScripOrden   VARCHAR(MAX) = NULL, 
                                      @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT *
		FROM (SELECT TOP 100 PERCENT ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila ,*
		  FROM PRI_PRODUCTOS ' + @ScripWhere + ') aPRI_PRODUCTOS
		WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento de PRI_PRODUCTOS por clave primaria
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTOS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_TXPK;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_TXPK @Id_Producto INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pp.*
        FROM PRI_PRODUCTOS pp
        WHERE(Id_Producto = @Id_Producto);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento de PRI_PRODUCTO_STOCK
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_G;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_G @Id_Producto         INT, 
                                          @Cod_UnidadMedida    VARCHAR(5), 
                                          @Cod_Almacen         VARCHAR(32), 
                                          @Cod_Moneda          VARCHAR(5), 
                                          @Precio_Compra       NUMERIC(38, 6), 
                                          @Precio_Venta        NUMERIC(38, 6), 
                                          @Stock_Min           NUMERIC(38, 6), 
                                          @Stock_Max           NUMERIC(38, 6), 
                                          @Stock_Act           NUMERIC(38, 6), 
                                          @Cod_UnidadMedidaMin VARCHAR(5), 
                                          @Cantidad_Min        NUMERIC(38, 6), 
                                          @Precio_Flete        NUMERIC(38, 6), 
                                          @Peso                NUMERIC(38, 6), 
                                          @Cod_Usuario         VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Producto, 
                   @Cod_UnidadMedida, 
                   @Cod_Almacen
            FROM PRI_PRODUCTO_STOCK
            WHERE(Id_Producto = @Id_Producto)
                 AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                 AND (Cod_Almacen = @Cod_Almacen)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_STOCK
                VALUES
                (@Id_Producto, 
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
                 @Precio_Flete, 
                 @Peso, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
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
                      Precio_Flete = @Precio_Flete, 
                      Peso = @Peso, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_UnidadMedida = @Cod_UnidadMedida)
                     AND (Cod_Almacen = @Cod_Almacen);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae todos los elementos de PRI_PRODUCTO_STOCK
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TT;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pps.*
        FROM PRI_PRODUCTO_STOCK pps;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae el paginado de los elementos de PRI_PRODUCTO_STOCK
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TP;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TP @TamañoPagina VARCHAR(16), 
                                           @NumeroPagina VARCHAR(16), 
                                           @ScripOrden   VARCHAR(MAX) = NULL, 
                                           @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT *  
	FROM (SELECT TOP 100 PERCENT *,ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 	  
		  FROM PRI_PRODUCTO_STOCK ' + @ScripWhere + ') aPRI_PRODUCTO_STOCK
	WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento de PRI_PRODUCTO_STOCK por clave primaria
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_STOCK_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_STOCK_TXPK;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_STOCK_TXPK @Id_Producto      INT, 
                                             @Cod_UnidadMedida VARCHAR(5), 
                                             @Cod_Almacen      VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT pps.*
        FROM PRI_PRODUCTO_STOCK pps
        WHERE(pps.Id_Producto = @Id_Producto)
             AND (pps.Cod_UnidadMedida = @Cod_UnidadMedida)
             AND (pps.Cod_Almacen = @Cod_Almacen);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento de CAJ_SERIES
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_G;
GO
CREATE PROCEDURE USP_CAJ_SERIES_G @Cod_Tabla         VARCHAR(64), 
                                  @Id_Tabla          INT, 
                                  @Item              INT, 
                                  @Serie             VARCHAR(512), 
                                  @Fecha_Vencimiento DATETIME, 
                                  @Obs_Serie         VARCHAR(1024), 
                                  @Cantidad          NUMERIC(38, 6), 
                                  @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Cod_Tabla, 
                   @Id_Tabla, 
                   @Item, 
                   @Serie
            FROM CAJ_SERIES
            WHERE(Cod_Tabla = @Cod_Tabla)
                 AND (Id_Tabla = @Id_Tabla)
                 AND (Item = @Item)
                 AND (Serie = @Serie)
        )
            BEGIN
                INSERT INTO CAJ_SERIES
                VALUES
                (@Cod_Tabla, 
                 @Id_Tabla, 
                 @Item, 
                 @Serie, 
                 @Fecha_Vencimiento, 
                 @Obs_Serie, 
                 @Cantidad, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE CAJ_SERIES
                  SET 
                      Fecha_Vencimiento = @Fecha_Vencimiento, 
                      Obs_Serie = @Obs_Serie, 
                      Cantidad = @Cantidad, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Cod_Tabla = @Cod_Tabla)
                     AND (Id_Tabla = @Id_Tabla)
                     AND (Item = @Item)
                     AND (Serie = @Serie);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae todos los elementos de CAJ_SERIES
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_TT;
GO
CREATE PROCEDURE USP_CAJ_SERIES_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT cs.*
        FROM CAJ_SERIES cs;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae los elementos paginados de CAJ_SERIES
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_TP;
GO
CREATE PROCEDURE USP_CAJ_SERIES_TP @TamañoPagina VARCHAR(16), 
                                   @NumeroPagina VARCHAR(16), 
                                   @ScripOrden   VARCHAR(MAX) = NULL, 
                                   @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT *  
		FROM (SELECT TOP 100 PERCENT ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila ,*
			  FROM CAJ_SERIES ' + @ScripWhere + ') aCAJ_SERIES
		WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento de CAJ_SERIES por clave primaria
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_TXPK;
GO
CREATE PROCEDURE USP_CAJ_SERIES_TXPK @Cod_Tabla VARCHAR(64), 
                                     @Id_Tabla  INT, 
                                     @Item      INT, 
                                     @Serie     VARCHAR(512)
WITH ENCRYPTION
AS
    BEGIN
        SELECT cs.*
        FROM CAJ_SERIES cs
        WHERE(cs.Cod_Tabla = @Cod_Tabla)
             AND (cs.Id_Tabla = @Id_Tabla)
             AND (cs.Item = @Item)
             AND (cs.Serie = @Serie);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Guarda un elemento en PRI_CLIENTE_PROVEEDOR
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_G @Id_ClienteProveedor  INT OUTPUT, 
                                             @Cod_TipoDocumento    VARCHAR(3), 
                                             @Nro_Documento        VARCHAR(32), 
                                             @Cliente              VARCHAR(512), 
                                             @Ap_Paterno           VARCHAR(128), 
                                             @Ap_Materno           VARCHAR(128), 
                                             @Nombres              VARCHAR(128), 
                                             @Direccion            VARCHAR(512), 
                                             @Cod_EstadoCliente    VARCHAR(3), 
                                             @Cod_CondicionCliente VARCHAR(3), 
                                             @Cod_TipoCliente      VARCHAR(3), 
                                             @RUC_Natural          VARCHAR(32), 
                                             @Foto                 BINARY, 
                                             @Firma                BINARY, 
                                             @Cod_TipoComprobante  VARCHAR(5), 
                                             @Cod_Nacionalidad     VARCHAR(8), 
                                             @Fecha_Nacimiento     DATETIME, 
                                             @Cod_Sexo             VARCHAR(3), 
                                             @Email1               VARCHAR(1024), 
                                             @Email2               VARCHAR(1024), 
                                             @Telefono1            VARCHAR(512), 
                                             @Telefono2            VARCHAR(512), 
                                             @Fax                  VARCHAR(512), 
                                             @PaginaWeb            VARCHAR(512), 
                                             @Cod_Ubigeo           VARCHAR(8), 
                                             @Cod_FormaPago        VARCHAR(3), 
                                             @Limite_Credito       NUMERIC(38, 2), 
                                             @Obs_Cliente          XML, 
                                             @Num_DiaCredito       INT, 
                                             @Ubicacion_EjeX       NUMERIC(38, 8), 
                                             @Ubicacion_EjeY       NUMERIC(38, 8), 
                                             @Ruta                 VARCHAR(2048), 
                                             @Cod_Usuario          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE(Id_ClienteProveedor = @Id_ClienteProveedor)
        )
            BEGIN
                INSERT INTO dbo.PRI_CLIENTE_PROVEEDOR
                (
                    --Id_ClienteProveedor - column value is auto-generated
                    Cod_TipoDocumento,
                    Nro_Documento,
                    Cliente,
                    Ap_Paterno,
                    Ap_Materno,
                    Nombres,
                    Direccion,
                    Cod_EstadoCliente,
                    Cod_CondicionCliente,
                    Cod_TipoCliente,
                    RUC_Natural,
                    Foto,
                    Firma,
                    Cod_TipoComprobante,
                    Cod_Nacionalidad,
                    Fecha_Nacimiento,
                    Cod_Sexo,
                    Email1,
                    Email2,
                    Telefono1,
                    Telefono2,
                    Fax,
                    PaginaWeb,
                    Cod_Ubigeo,
                    Cod_FormaPago,
                    Limite_Credito,
                    Obs_Cliente,
                    Num_DiaCredito,
                    Ubicacion_EjeX,
                    Ubicacion_EjeY,
                    Ruta,
                    Cod_UsuarioReg,
                    Fecha_Reg,
                    Cod_UsuarioAct,
                    Fecha_Act
                )
                VALUES
                (@Cod_TipoDocumento, 
                 @Nro_Documento, 
                 @Cliente, 
                 @Ap_Paterno, 
                 @Ap_Materno, 
                 @Nombres, 
                 @Direccion, 
                 @Cod_EstadoCliente, 
                 @Cod_CondicionCliente, 
                 @Cod_TipoCliente, 
                 @RUC_Natural, 
                 @Foto, 
                 @Firma, 
                 @Cod_TipoComprobante, 
                 @Cod_Nacionalidad, 
                 @Fecha_Nacimiento, 
                 @Cod_Sexo, 
                 @Email1, 
                 @Email2, 
                 @Telefono1, 
                 @Telefono2, 
                 @Fax, 
                 @PaginaWeb, 
                 @Cod_Ubigeo, 
                 @Cod_FormaPago, 
                 @Limite_Credito, 
                 @Obs_Cliente, 
                 @Num_DiaCredito, 
                 @Ubicacion_EjeX, 
                 @Ubicacion_EjeY, 
                 @Ruta, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
                SET @Id_ClienteProveedor = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE PRI_CLIENTE_PROVEEDOR
                  SET 
                      Cod_TipoDocumento = @Cod_TipoDocumento, 
                      Nro_Documento = @Nro_Documento, 
                      Cliente = @Cliente, 
                      Ap_Paterno = @Ap_Paterno, 
                      Ap_Materno = @Ap_Materno, 
                      Nombres = @Nombres, 
                      Direccion = @Direccion, 
                      Cod_EstadoCliente = @Cod_EstadoCliente, 
                      Cod_CondicionCliente = @Cod_CondicionCliente, 
                      Cod_TipoCliente = @Cod_TipoCliente, 
                      RUC_Natural = @RUC_Natural, 
                      Foto = @Foto, 
                      Firma = @Firma, 
                      Cod_TipoComprobante = @Cod_TipoComprobante, 
                      Cod_Nacionalidad = @Cod_Nacionalidad, 
                      Fecha_Nacimiento = @Fecha_Nacimiento, 
                      Cod_Sexo = @Cod_Sexo, 
                      Email1 = @Email1, 
                      Email2 = @Email2, 
                      Telefono1 = @Telefono1, 
                      Telefono2 = @Telefono2, 
                      Fax = @Fax, 
                      PaginaWeb = @PaginaWeb, 
                      Cod_Ubigeo = @Cod_Ubigeo, 
                      Cod_FormaPago = @Cod_FormaPago, 
                      Limite_Credito = @Limite_Credito, 
                      Obs_Cliente = @Obs_Cliente, 
                      Num_DiaCredito = @Num_DiaCredito, 
                      Ubicacion_EjeX = @Ubicacion_EjeX, 
                      Ubicacion_EjeY = @Ubicacion_EjeY, 
                      Ruta = @Ruta, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_ClienteProveedor = @Id_ClienteProveedor);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae todos los elementos de PRI_CLIENTE_PROVEEDOR
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pcp.*
        FROM PRI_CLIENTE_PROVEEDOR pcp;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae el paginado de los elementos de PRI_CLIENTE_PROVEEDOR
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TP @TamañoPagina VARCHAR(16), 
                                              @NumeroPagina VARCHAR(16), 
                                              @ScripOrden   VARCHAR(MAX) = NULL, 
                                              @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT *  
		FROM (SELECT TOP 100 PERCENT ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila,*
			  FROM PRI_CLIENTE_PROVEEDOR ' + @ScripWhere + ') aPRI_CLIENTE_PROVEEDOR
		WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Trae un elemento de PRI_CLIENTE_PROVEEDOR por clave primaria
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TXPK @Id_ClienteProveedor INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pcp.*
        FROM PRI_CLIENTE_PROVEEDOR pcp
        WHERE(pcp.Id_ClienteProveedor = @Id_ClienteProveedor);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Buscar un Producto
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTOS_Buscar'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                          @Buscar             VARCHAR(512), 
                                          @CodTipoProducto AS    VARCHAR(8)   = NULL, 
                                          @Cod_Categoria AS      VARCHAR(32)  = NULL, 
                                          @Cod_Precio AS         VARCHAR(32)  = NULL, 
                                          @Flag_RequiereStock AS BIT          = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;	
        --SET @Buscar = REPLACE(@Buscar,'%',' ');
        SELECT P.Id_Producto, 
               P.Nom_Producto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Stock_Act, 
               PS.Precio_Venta, 
               M.Nom_Moneda AS Nom_Moneda, 
               PS.Cod_Almacen, 
               0 AS Descuento, 
               'NINGUNO' AS TipoDescuento, 
               A.Des_CortaAlmacen AS Des_Almacen, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               P.Flag_Stock, 
               PS.Precio_Compra,
               CASE
                   WHEN @Cod_Precio IS NULL
                   THEN 0
                   ELSE dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto, PS.Cod_UnidadMedida, PS.Cod_Almacen, @Cod_Precio)
               END AS Precio, 
               P.Cod_TipoOperatividad, 
               M.Cod_Moneda, 
               Cod_TipoProducto, 
               PS.Peso
        FROM PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
             INNER JOIN VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
        WHERE(P.Cod_TipoProducto = @CodTipoProducto
              OR @CodTipoProducto IS NULL)
             AND ((P.Cod_Producto LIKE @Buscar)
                  OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%')
                  OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
             AND (P.Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (ca.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
             AND (P.Flag_Activo = 1)
        --AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
        ORDER BY Nom_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Buscar un producto por un id_Cliente_Proveedor
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor;
GO
CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor @Cod_Caja AS           VARCHAR(32)  = NULL, 
                                                             @Buscar             VARCHAR(512), 
                                                             @IdClienteProveedor INT, 
                                                             @Cod_Categoria AS      VARCHAR(32)  = NULL
WITH ENCRYPTION
AS
    BEGIN
        SELECT P.Id_Producto, 
               P.Des_LargaProducto AS Nom_Producto, 
               P.Cod_Producto, 
               PS.Cod_Almacen, 
               PS.Stock_Act, 
               PS.Precio_Venta AS Precio, 
               ISNULL(PP.Nom_TipoPrecio, 'NINGUNO') AS TipoDescuento,
               CASE PP.Cod_TipoPrecio
                   WHEN '01'
                   THEN 0
                   WHEN '02'
                   THEN ISNULL(CP.Monto, 0)
                   WHEN '03'
                   THEN PS.Precio_Venta - ISNULL(CP.Monto, 0)
                   WHEN '04'
                   THEN PS.Precio_Venta * ISNULL(CP.Monto, 0) / 100
                   ELSE 0
               END AS Descuento, 
               M.Nom_Moneda, 
               PS.Cod_UnidadMedida, 
               UM.Nom_UnidadMedida, 
               A.Des_Almacen, 
               P.Flag_Stock, 
               P.Cod_TipoOperatividad, 
               M.Cod_Moneda, 
               PS.Precio_Compra, 
               PS.Peso
        FROM VIS_MONEDAS AS M
             INNER JOIN PRI_PRODUCTOS AS P
             INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto ON M.Cod_Moneda = PS.Cod_Moneda
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida
             INNER JOIN ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen
             INNER JOIN CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
             LEFT OUTER JOIN VIS_TIPO_PRECIOS AS PP
             INNER JOIN PRI_CLIENTE_PRODUCTO AS CP ON PP.Cod_TipoPrecio = CP.Cod_TipoDescuento ON P.Id_Producto = CP.Id_Producto
        WHERE(CP.Id_ClienteProveedor = @IdClienteProveedor)
             OR (P.Nom_Producto LIKE '%' + @Buscar + '%')
             AND (P.Flag_Activo = 1)
             OR (P.Flag_Activo = 1)
             AND (P.Cod_Producto LIKE @Buscar + '%')
             OR (P.Flag_Activo = 1)
             AND (PS.Cod_Almacen = @Buscar)
             AND (@Cod_Categoria IN
        (
            SELECT Cod_Categoria
            FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)
        )
        OR @Cod_Categoria IS NULL)
             AND (CA.Cod_Caja = @Cod_Caja
                  OR @Cod_Caja IS NULL)
        ORDER BY Cod_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- FECHA: 05/08/2019
-- OBJETIVO: Buscar un cliente por un documento de cliente
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_TXDocumento'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_TXDocumento;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_TXDocumento @Cod_TipoCliente AS     VARCHAR(32) = NULL, 
                                             @Nro_Documento AS       VARCHAR(32), 
                                             @Cod_TipoDocumento AS   VARCHAR(3), 
                                             @Cod_TipoComprobante AS VARCHAR(32) = NULL
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT Id_ClienteProveedor
            FROM PRI_CLIENTE_PROVEEDOR
            WHERE Nro_Documento = @Nro_Documento
        )
            BEGIN
                SELECT CP.Id_ClienteProveedor, 
                       CP.Cod_TipoDocumento, 
                       CP.Nro_Documento, 
                       CP.Cliente, 
                       CP.Direccion, 
                       CP.Telefono1, 
                       CP.Email1, 
                       CP.Cod_EstadoCliente, 
                       CP.Ap_Paterno, 
                       CP.Ap_Materno, 
                       CP.Nombres, 
                       CP.Cod_CondicionCliente, 
                       CP.Cod_TipoCliente, 
                       CP.RUC_Natural, 
                       CP.Cod_TipoComprobante, 
                       CP.Cod_Nacionalidad, 
                       CP.Fecha_Nacimiento, 
                       CP.Cod_Sexo, 
                       CP.Email2, 
                       CP.Telefono2, 
                       CP.Fax, 
                       CP.PaginaWeb, 
                       CP.Cod_Ubigeo, 
                       CP.Cod_FormaPago, 
                       CP.Limite_Credito, 
                       TD.Nom_TipoDoc AS Nom_TipoDocumento
                FROM PRI_CLIENTE_PROVEEDOR AS CP
                     INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc
                WHERE(Nro_Documento = @Nro_Documento);
        END;
            ELSE
            BEGIN
                IF EXISTS
                (
                    SELECT Id_ClienteProveedor
                    FROM PALERPdata.dbo.PRI_CLIENTE_PROVEEDOR
                    WHERE Nro_Documento = @Nro_Documento
                )
                    BEGIN
                        -- INSERTAR EN LA BASE DE DATOS ACTUAL
                        INSERT INTO PRI_CLIENTE_PROVEEDOR
                               SELECT TOP 1 Cod_TipoDocumento, 
                                            Nro_Documento, 
                                            Cliente, 
                                            Ap_Paterno, 
                                            Ap_Materno, 
                                            Nombres, 
                                            Direccion, 
                                            Cod_EstadoCliente, 
                                            Cod_CondicionCliente, 
                                            Cod_TipoCliente, 
                                            RUC_Natural, 
                                            Foto, 
                                            Firma, 
                                            Cod_TipoComprobante, 
                                            Cod_Nacionalidad, 
                                            Fecha_Nacimiento, 
                                            Cod_Sexo, 
                                            Email1, 
                                            Email2, 
                                            Telefono1, 
                                            Telefono2, 
                                            Fax, 
                                            PaginaWeb, 
                                            Cod_Ubigeo, 
                                            Cod_FormaPago, 
                                            Limite_Credito, 
                                            Obs_Cliente, 
                                            0, 
                                            0, 
                                            0, 
                                            '', 
                                            'MIGRACION', 
                                            GETDATE(), 
                                            NULL, 
                                            NULL
                               FROM PALERPdata.dbo.PRI_CLIENTE_PROVEEDOR
                               WHERE Nro_Documento = @Nro_Documento;
                        SELECT CP.Id_ClienteProveedor, 
                               CP.Cod_TipoDocumento, 
                               CP.Nro_Documento, 
                               CP.Cliente, 
                               CP.Direccion, 
                               CP.Telefono1, 
                               CP.Email1, 
                               CP.Cod_EstadoCliente, 
                               CP.Ap_Paterno, 
                               CP.Ap_Materno, 
                               CP.Nombres, 
                               CP.Cod_CondicionCliente, 
                               CP.Cod_TipoCliente, 
                               CP.RUC_Natural, 
                               CP.Cod_TipoComprobante, 
                               CP.Cod_Nacionalidad, 
                               CP.Fecha_Nacimiento, 
                               CP.Cod_Sexo, 
                               CP.Email2, 
                               CP.Telefono2, 
                               CP.Fax, 
                               CP.PaginaWeb, 
                               CP.Cod_Ubigeo, 
                               CP.Cod_FormaPago, 
                               CP.Limite_Credito, 
                               TD.Nom_TipoDoc AS Nom_TipoDocumento
                        FROM PRI_CLIENTE_PROVEEDOR AS CP
                             INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc
                        WHERE(Nro_Documento = @Nro_Documento);
                END;
                    ELSE
                    BEGIN
                        SELECT TOP 0 CP.Id_ClienteProveedor, 
                                     CP.Cod_TipoDocumento, 
                                     CP.Nro_Documento, 
                                     CP.Cliente, 
                                     CP.Direccion, 
                                     CP.Telefono1, 
                                     CP.Email1, 
                                     CP.Cod_EstadoCliente, 
                                     CP.Ap_Paterno, 
                                     CP.Ap_Materno, 
                                     CP.Nombres, 
                                     CP.Cod_CondicionCliente, 
                                     CP.Cod_TipoCliente, 
                                     CP.RUC_Natural, 
                                     CP.Cod_TipoComprobante, 
                                     CP.Cod_Nacionalidad, 
                                     CP.Fecha_Nacimiento, 
                                     CP.Cod_Sexo, 
                                     CP.Email2, 
                                     CP.Telefono2, 
                                     CP.Fax, 
                                     CP.PaginaWeb, 
                                     CP.Cod_Ubigeo, 
                                     CP.Cod_FormaPago, 
                                     CP.Limite_Credito, 
                                     TD.Nom_TipoDoc AS Nom_TipoDocumento
                        FROM PRI_CLIENTE_PROVEEDOR AS CP
                             INNER JOIN VIS_TIPO_DOCUMENTOS AS TD ON CP.Cod_TipoDocumento = TD.Cod_TipoDoc;
                END;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 22/03/2019;
-- OBJETIVO: Procedimiento que muestra la Lista del inventario inicial pendiente
-- EXEC USP_ALM_Traer_Almacen_Inventario_Inicial_Pendiente 100,'pro',null,null,'001',0
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_Traer_Almacen_Inventario_Inicial_Pendiente'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_Traer_Almacen_Inventario_Inicial_Pendiente;
GO
CREATE PROCEDURE USP_ALM_Traer_Almacen_Inventario_Inicial_Pendiente
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        SELECT Id_Inventario, 
               Des_Inventario, 
               Cod_TipoInventario, 
               Obs_Inventario, 
               Cod_Almacen, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM ALM_INVENTARIO
        WHERE Cod_EstadoInventario = 'PENDIENTE';
    END;
GO 
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 22/03/2019;
-- OBJETIVO: Procedimiento que muestra la Lista del inventario inicial pendiente
-- EXEC USP_ALM_INVENTARIO_G 00001010,'pro','001','JN','A101','ADMINISTRADOR','PENDIENTE','2019-04-02',''
--------------------------------------------------------------------------------------------------------------
GO 
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_G;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_G @Id_Inventario      INT OUTPUT, 
                                      @Des_Inventario     VARCHAR(512), 
                                      @Cod_TipoInventario VARCHAR(5), 
                                      @Obs_Inventario     VARCHAR(1024), 
                                      @Cod_Almacen        VARCHAR(32), 
                                      @Cod_Usuario        VARCHAR(32), 
                                      @Cod_Estado         VARCHAR(32), 
                                      @Fecha_Inventario   DATETIME, 
                                      @Fecha_Fin          VARCHAR(64)
WITH ENCRYPTION
AS
    BEGIN
        IF(@Fecha_Fin = '')
            BEGIN
                SET @Fecha_Fin = NULL;
        END;
        IF NOT EXISTS
        (
            SELECT @Id_Inventario
            FROM ALM_INVENTARIO
            WHERE(Id_Inventario = @Id_Inventario)
        )
            BEGIN
                INSERT INTO ALM_INVENTARIO
                VALUES
                (@Des_Inventario, 
                 @Cod_TipoInventario, 
                 @Obs_Inventario, 
                 @Cod_Almacen, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL, 
                 @Cod_Estado, 
                 @Fecha_Inventario, 
                 @Fecha_Fin
                );
                SET @Id_Inventario = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE ALM_INVENTARIO
                  SET 
                      Des_Inventario = @Des_Inventario, 
                      Cod_TipoInventario = @Cod_TipoInventario, 
                      Obs_Inventario = @Obs_Inventario, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE(), 
                      [Cod_EstadoInventario] = @Cod_Estado, 
                      [Fecha_Fin] = @Fecha_Fin
                WHERE(Id_Inventario = @Id_Inventario);
        END;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_D_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_D_G;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_D_G @Id_Inventario       INT, 
                                        @Item                VARCHAR(32), 
                                        @Id_Producto         INT, 
                                        @Cod_UnidadMedida    VARCHAR(5), 
                                        @Cod_Almacen         VARCHAR(32), 
                                        @Cantidad_Sistema    NUMERIC(38, 6), 
                                        @Cantidad_Encontrada NUMERIC(38, 6), 
                                        @Obs_InventarioD     VARCHAR(1024), 
                                        @Cod_Usuario         VARCHAR(32), 
                                        @Precio              NUMERIC(38, 6)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Inventario, 
                   @Item
            FROM ALM_INVENTARIO_D
            WHERE(Id_Inventario = @Id_Inventario)
                 AND (Item = @Item)
        )
            BEGIN
                INSERT INTO ALM_INVENTARIO_D
                VALUES
                (@Id_Inventario, 
                 @Item, 
                 @Id_Producto, 
                 @Cod_UnidadMedida, 
                 @Cod_Almacen, 
                 @Cantidad_Sistema, 
                 @Cantidad_Encontrada, 
                 @Obs_InventarioD, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL, 
                 @Precio
                );
        END;
            ELSE
            BEGIN
                UPDATE ALM_INVENTARIO_D
                  SET 
                      Id_Producto = @Id_Producto, 
                      Cod_UnidadMedida = @Cod_UnidadMedida, 
                      Cod_Almacen = @Cod_Almacen, 
                      Cantidad_Sistema = @Cantidad_Sistema, 
                      Cantidad_Encontrada = @Cantidad_Encontrada, 
                      Obs_InventarioD = @Obs_InventarioD, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE(), 
                      Precio_Unitario = @Precio
                WHERE(Id_Inventario = @Id_Inventario)
                     AND (Item = @Item);
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA:  03/04/2019 |  25/06/2019 | 25/072019
-- OBJETIVO: Metodo que traer productos que pertenecen a una composicion
-- Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_ALM_INVENTARIO_RECUPERAR_X_ANIO 2019
--------------------------------------------------------------------------------------------------------------
--IF EXISTS
--(
--    SELECT name
--    FROM sysobjects
--    WHERE name = 'USP_ALM_INVENTARIO_RECUPERAR_X_ANIO'
--          AND type = 'P'
--)
--    DROP PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_X_ANIO;
--GO
--CREATE PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_X_ANIO @pAnio INT
--WITH ENCRYPTION
--AS
--    BEGIN
--        SELECT [Id_Inventario], 
--               [Des_Inventario], 
--               [Cod_EstadoInventario], 
--               TI.Nom_TipoInventario
--        FROM ALM_INVENTARIO AI
--             INNER JOIN VIS_TIPO_INVENTARIO TI ON AI.Cod_TipoInventario = TI.Cod_TipoInventario
--        WHERE YEAR(Fecha_Reg) = @pAnio;
--    END;
--GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_RECUPERAR_X_ANIO'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_X_ANIO;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_X_ANIO @pAnio INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT [Id_Inventario], 
               [Des_Inventario], 
               AI.[Cod_EstadoInventario], 
               EI.Nom_EstadoInventario, 
               TI.Nom_TipoInventario
        FROM ALM_INVENTARIO AI
             INNER JOIN VIS_TIPO_INVENTARIO TI ON AI.Cod_TipoInventario = TI.Cod_TipoInventario
             INNER JOIN VIS_ESTADO_INVENTARIO EI ON AI.Cod_EstadoInventario = EI.Cod_EstadoInventario
        WHERE YEAR(Fecha_Reg) = @pAnio;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN | ESTEFANI HUAMAN
-- FECHA: 17/04/2019 | 25/06/2019
-- OBJETIVO: Procedimiento que permite recuperar el Siguiente Numero del Inventario Inicial
-- Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_ALM_Inventario_VerificarExiste '4','2019',3073
--------------------------------------------------------------------------------------------------------------
--IF EXISTS
--(
--    SELECT name
--    FROM sysobjects
--    WHERE name = 'USP_ALM_Inventario_VerificarExiste'
--          AND type = 'P'
--)
--    DROP PROCEDURE USP_ALM_Inventario_VerificarExiste;
--GO
--CREATE PROCEDURE USP_ALM_Inventario_VerificarExiste @Mes         INT, 
--                                                    @Anio        INT, 
--                                                    @pInventario INT
--WITH ENCRYPTION
--AS
--    BEGIN
--        DECLARE @respuesta INT;
--        DECLARE @resultado INT;
--        DECLARE @InvRecuperado INT;
--        SET @resultado = 1;
--        SET @respuesta =
--        (
--            SELECT COUNT(*)
--            FROM [dbo].[ALM_INVENTARIO]
--            WHERE MONTH(Fecha_Inventario) = @Mes
--                  AND YEAR(Fecha_Inventario) = @Anio
--        );
--        IF(@respuesta = 1)
--            BEGIN
--                SET @InvRecuperado =
--                (
--                    SELECT [Id_Inventario]
--                    FROM [dbo].[ALM_INVENTARIO]
--                    WHERE MONTH(Fecha_Inventario) = @Mes
--                          AND YEAR(Fecha_Inventario) = @Anio
--                );
--                IF(@InvRecuperado = @pInventario)
--                    BEGIN
--                        SET @resultado = 0;
--                END;
--        END;
--            ELSE
--            IF(@respuesta = 0)
--                BEGIN
--                    SET @resultado = 0;
--            END;
--        SELECT @resultado, 
--               @InvRecuperado;
--    END;
--GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_Inventario_VerificarExiste'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_Inventario_VerificarExiste;
GO
CREATE PROCEDURE USP_ALM_Inventario_VerificarExiste @Mes         INT, 
                                                    @Anio        INT, 
                                                    @pInventario INT
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @respuesta INT;
        DECLARE @resultado INT;
        DECLARE @InvRecuperado INT;
        SET @resultado = 1;
        SET @respuesta =
        (
            SELECT COUNT(*)
            FROM [dbo].[ALM_INVENTARIO]
            WHERE MONTH(Fecha_Inventario) = @Mes
                  AND YEAR(Fecha_Inventario) = @Anio
        );
        IF(@respuesta = 1)
            BEGIN
                SET @InvRecuperado =
                (
                    SELECT [Id_Inventario]
                    FROM [dbo].[ALM_INVENTARIO]
                    WHERE MONTH(Fecha_Inventario) = @Mes
                          AND YEAR(Fecha_Inventario) = @Anio
                );
                IF(@InvRecuperado = @pInventario)
                    BEGIN
                        SET @resultado = 0;
                END;
        END;
            ELSE
            IF(@respuesta = 0)
                BEGIN
                    SET @resultado = 0;
            END;
        SELECT @resultado, 
               @InvRecuperado;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CATEGORIA_TraerCategoriaXIdProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CATEGORIA_TraerCategoriaXIdProducto;
GO
CREATE PROCEDURE USP_PRI_CATEGORIA_TraerCategoriaXIdProducto @Id_Producto INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               ccd.Id_Producto, 
               ccd.Descripcion, 
               pp.Cod_Categoria, 
               pc.Des_Categoria
        FROM dbo.CAJ_COMPROBANTE_D ccd
             INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto = pp.Id_Producto
             INNER JOIN dbo.PRI_CATEGORIA pc ON pp.Cod_Categoria = pc.Cod_Categoria
        WHERE ccd.Id_Producto = @Id_Producto;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_ObtenerHoraServidor'
          AND type = 'P'
)
    DROP PROCEDURE USP_ObtenerHoraServidor;
GO
CREATE PROCEDURE USP_ObtenerHoraServidor
WITH ENCRYPTION
AS
    BEGIN
        SELECT GETDATE() FechaHora_Servidor;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_FusionarComandas'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FusionarComandas;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_FusionarComandas @Id_ComandaDestino INT, --Donde se volcaran los datos del origen
                                                           @Id_ComandaOrigen  INT, --De donde se copiaran los datos
                                                           @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Id_ComandaDestino IS NOT NULL
           AND @Id_ComandaDestino > 0
           AND @Id_ComandaOrigen IS NOT NULL
           AND @Id_ComandaOrigen > 0
           AND @Id_ComandaOrigen != @Id_ComandaDestino
            BEGIN
                SET XACT_ABORT ON;
                BEGIN TRY
                    BEGIN TRANSACTION;
                    --Variables a utilizar
                    --Origen
                    DECLARE @Origen_IdDetalle INT;
                    DECLARE @Origen_IdProducto INT;
                    DECLARE @Origen_Descripcion VARCHAR(MAX);
                    DECLARE @Origen_PrecioUnitario NUMERIC(38, 6);
                    DECLARE @Origen_Observacion VARCHAR(1024);
                    DECLARE @Origen_Contador INT= 0;
                    DECLARE @Origen_TotalDetalles INT=
                    (
                        SELECT COUNT(ccd.id_Detalle)
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                              AND ccd.IGV = 0
                    );
                    DECLARE @Origen_CodMesa VARCHAR(5)=
                    (
                        SELECT TOP 1 ccd.Cod_Manguera
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                    );

                    --Destino
                    DECLARE @Destino_IdDetalle INT;
                    DECLARE @Destino_IdProducto INT;
                    DECLARE @Destino_Descripcion VARCHAR(MAX);
                    DECLARE @Destino_PrecioUnitario NUMERIC(38, 6);
                    DECLARE @Destino_Observacion VARCHAR(1024);
                    DECLARE @Destino_Contador INT= 0;
                    DECLARE @Destino_TotalDetalles INT=
                    (
                        SELECT COUNT(ccd.id_Detalle)
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                              AND ccd.IGV = 0
                    );
                    DECLARE @Destino_IdDetalleMaximo INT;
                    DECLARE @Destino_CodMesa VARCHAR(5)=
                    (
                        SELECT TOP 1 ccd.Cod_Manguera
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                    );

                    --Variable de control
                    DECLARE @Item_Encontrado BIT= 0;

                    --Recorremos los items del origen
                    IF
                    (
                        SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                    ) >= -1
                        BEGIN
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                            ) > -1
                                BEGIN
                                    CLOSE Cursor_Origen;
                            END;
                            DEALLOCATE Cursor_Origen;
                    END;
                    DECLARE Cursor_Origen CURSOR LOCAL
                    FOR SELECT ccd.id_Detalle, 
                               ccd.Id_Producto, 
                               ccd.Descripcion, 
                               ccd.PrecioUnitario, 
                               ccd.Obs_ComprobanteD
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                              AND ccd.IGV = 0
                        ORDER BY ccd.id_Detalle;
                    OPEN Cursor_Origen;
                    FETCH NEXT FROM Cursor_Origen INTO @Origen_IdDetalle, @Origen_IdProducto, @Origen_Descripcion, @Origen_PrecioUnitario, @Origen_Observacion;
                    WHILE @Origen_Contador < @Origen_TotalDetalles
                        BEGIN
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                            ) >= -1
                                BEGIN
                                    IF
                                    (
                                        SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                                    ) > -1
                                        BEGIN
                                            CLOSE Cursor_Destino;
                                    END;
                                    DEALLOCATE Cursor_Destino;
                            END;
                            --Empezamos con un cursor para reccorrer los items del destin cuyo IGV=0 (padres)
                            SET @Item_Encontrado = 0;
                            SET @Destino_TotalDetalles =
                            (
                                SELECT COUNT(ccd.id_Detalle)
                                FROM dbo.CAJ_COMPROBANTE_D ccd
                                WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                                      AND ccd.IGV = 0
                            );
                            SET @Destino_Contador = 0;
                            DECLARE Cursor_Destino CURSOR LOCAL
                            FOR SELECT ccd.id_Detalle, 
                                       ccd.Id_Producto, 
                                       ccd.Descripcion, 
                                       ccd.PrecioUnitario, 
                                       ccd.Obs_ComprobanteD
                                FROM dbo.CAJ_COMPROBANTE_D ccd
                                WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                                      AND ccd.IGV = 0
                                ORDER BY ccd.id_Detalle;
                            OPEN Cursor_Destino;
                            FETCH NEXT FROM Cursor_Destino INTO @Destino_IdDetalle, @Destino_IdProducto, @Destino_Descripcion, @Destino_PrecioUnitario, @Destino_Observacion;
                            WHILE @Destino_Contador < @Destino_TotalDetalles
                                  AND @Item_Encontrado = 0
                                BEGIN
                                    IF @Origen_IdProducto = @Destino_IdProducto
                                       AND @Origen_Descripcion = @Destino_Descripcion
                                       AND @Origen_PrecioUnitario = @Destino_PrecioUnitario
                                       AND @Origen_Observacion = @Destino_Observacion --La cabezera coincide
                                        BEGIN
                                            --Comparamos los hijos
                                            DECLARE @SumaHijosDestino BIGINT= ISNULL(
                                            (
                                                SELECT SUM(CAST(CHECKSUM(ccd.Id_Producto, ccd.Descripcion, ccd.PrecioUnitario, ccd.Obs_ComprobanteD) AS BIGINT))
                                                FROM dbo.CAJ_COMPROBANTE_D ccd
                                                WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                                                      AND CAST(ccd.IGV AS INT) = @Destino_IdDetalle
                                            ), 0);
                                            DECLARE @SumaHijosOrigen BIGINT= ISNULL(
                                            (
                                                SELECT SUM(CAST(CHECKSUM(ccd.Id_Producto, ccd.Descripcion, ccd.PrecioUnitario, ccd.Obs_ComprobanteD) AS BIGINT))
                                                FROM dbo.CAJ_COMPROBANTE_D ccd
                                                WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                                      AND CAST(ccd.IGV AS INT) = @Origen_IdDetalle
                                            ), 0);
                                            IF @SumaHijosDestino = @SumaHijosOrigen
                                                BEGIN
                                                    --Actualizamos el destino
                                                    UPDATE dbo.CAJ_COMPROBANTE_D
                                                      SET 
                                                          dbo.CAJ_COMPROBANTE_D.Cantidad = dbo.CAJ_COMPROBANTE_D.Cantidad +
                                                    (
                                                        SELECT ccd.Cantidad - ccd.Formalizado
                                                        FROM dbo.CAJ_COMPROBANTE_D ccd
                                                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                                              AND ccd.id_Detalle = @Origen_IdDetalle
                                                    ), 
                                                          dbo.CAJ_COMPROBANTE_D.Sub_Total = ROUND((dbo.CAJ_COMPROBANTE_D.Cantidad +
                                                    (
                                                        SELECT ccd.Cantidad - ccd.Formalizado
                                                        FROM dbo.CAJ_COMPROBANTE_D ccd
                                                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                                              AND ccd.id_Detalle = @Origen_IdDetalle
                                                    )) * dbo.CAJ_COMPROBANTE_D.PrecioUnitario, 2), 
                                                          dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @Cod_Usuario, 
                                                          dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                                                    WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComandaDestino
                                                          AND dbo.CAJ_COMPROBANTE_D.id_Detalle = @Destino_IdDetalle;
                                                    --Debemos editar el origen, poniendo  el campo cantidad=Formalizado
                                                    UPDATE dbo.CAJ_COMPROBANTE_D
                                                      SET 
                                                          dbo.CAJ_COMPROBANTE_D.Cantidad = 0, 
                                                          dbo.CAJ_COMPROBANTE_D.Sub_Total = 0, 
                                                          dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @Cod_Usuario, 
                                                          dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                                                    WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComandaOrigen
                                                          AND (dbo.CAJ_COMPROBANTE_D.id_Detalle = @Origen_IdDetalle
                                                               OR CAST(dbo.CAJ_COMPROBANTE_D.IGV AS INT) = @Origen_IdDetalle);
                                                    SET @Item_Encontrado = 1;
                                            END;
                                    END;
                                    FETCH NEXT FROM Cursor_Destino INTO @Destino_IdDetalle, @Destino_IdProducto, @Destino_Descripcion, @Destino_PrecioUnitario, @Destino_Observacion;
                                    SET @Destino_Contador = @Destino_Contador + 1;
        END;
                            CLOSE Cursor_Destino;
                            DEALLOCATE Cursor_Destino;

                            --Si no se encontro el el item entonces se procede a insertar en el destino
                            IF @Item_Encontrado = 0
                                BEGIN
                                    SET @Destino_IdDetalleMaximo =
                                    (
                                        SELECT MAX(ccd.id_Detalle)
                                        FROM dbo.CAJ_COMPROBANTE_D ccd
                                        WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                                    );
                                    --Se procede a insertar los detalles del origen al destino, incluidos sus hijos
                                    INSERT INTO dbo.CAJ_COMPROBANTE_D
                                    (id_ComprobantePago, 
                                     id_Detalle, 
                                     Id_Producto, 
                                     Cod_Almacen, 
                                     Cantidad, 
                                     Cod_UnidadMedida, 
                                     Despachado, 
                                     Descripcion, 
                                     PrecioUnitario, 
                                     Descuento, 
                                     Sub_Total, 
                                     Tipo, 
                                     Obs_ComprobanteD, 
                                     Cod_Manguera, 
                                     Flag_AplicaImpuesto, 
                                     Formalizado, 
                                     Valor_NoOneroso, 
                                     Cod_TipoISC, 
                                     Porcentaje_ISC, 
                                     ISC, 
                                     Cod_TipoIGV, 
                                     Porcentaje_IGV, 
                                     IGV, 
                                     Cod_UsuarioReg, 
                                     Fecha_Reg, 
                                     Cod_UsuarioAct, 
                                     Fecha_Act
                                    )
                                           SELECT @Id_ComandaDestino, 
                                                  ccd.id_Detalle + @Destino_IdDetalleMaximo, 
                                                  ccd.Id_Producto, 
                                                  ccd.Cod_Almacen, 
                                                  ccd.Cantidad, 
                                                  ccd.Cod_UnidadMedida, 
                                                  ccd.Despachado, 
                                                  ccd.Descripcion, 
                                                  ccd.PrecioUnitario, 
                                                  ccd.Descuento, 
                                                  ccd.Sub_Total, 
                                                  ccd.Tipo, 
                                                  ccd.Obs_ComprobanteD, 
                                                  @Destino_CodMesa, 
                                                  ccd.Flag_AplicaImpuesto, 
                                                  ccd.Formalizado, 
                                                  ccd.Valor_NoOneroso, 
                                                  ccd.Cod_TipoISC, 
                                                  ccd.Porcentaje_ISC, 
                                                  ccd.ISC, 
                                                  ccd.Cod_TipoIGV, 
                                                  ccd.Porcentaje_IGV,
                                                  CASE
                                                      WHEN ccd.IGV IS NULL
                                                           OR ccd.IGV = 0
                                                      THEN 0
                                                      ELSE ccd.IGV + @Destino_IdDetalleMaximo
                                                  END, 
                                                  @Cod_Usuario, 
                                                  GETDATE(), 
                                                  NULL, 
                                                  NULL
                                           FROM dbo.CAJ_COMPROBANTE_D ccd
                                           WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                                 AND (ccd.id_Detalle = @Origen_IdDetalle
                                                      OR CAST(ccd.IGV AS INT) = @Origen_IdDetalle);
                            END;
                                ELSE
                                BEGIN
                                    --Debemos editar el destino, poniendo  el campo cantidad+=Formalizado
                                    UPDATE dbo.CAJ_COMPROBANTE_D
                                      SET 
                                          dbo.CAJ_COMPROBANTE_D.Cantidad = dbo.CAJ_COMPROBANTE_D.Cantidad +
                                    (
                                        SELECT ccd.Cantidad - ccd.Formalizado
                                        FROM dbo.CAJ_COMPROBANTE_D ccd
                                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                              AND ccd.id_Detalle = @Origen_IdDetalle
                                    ), 
                                          dbo.CAJ_COMPROBANTE_D.Sub_Total = ROUND((dbo.CAJ_COMPROBANTE_D.Cantidad +
                                    (
                                        SELECT ccd.Cantidad - ccd.Formalizado
                                        FROM dbo.CAJ_COMPROBANTE_D ccd
                                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                                              AND ccd.id_Detalle = @Origen_IdDetalle
                                    )) * dbo.CAJ_COMPROBANTE_D.PrecioUnitario, 2), 
                                          dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @Cod_Usuario, 
                                          dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                                    WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComandaDestino
                                          AND dbo.CAJ_COMPROBANTE_D.id_Detalle = @Destino_IdDetalle;
                            END;
                            --Debemos editar el origen, poniendo  el campo cantidad=Formalizado
                            UPDATE dbo.CAJ_COMPROBANTE_D
                              SET 
                                  dbo.CAJ_COMPROBANTE_D.Cantidad = 0, 
                                  dbo.CAJ_COMPROBANTE_D.Sub_Total = 0, 
                                  dbo.CAJ_COMPROBANTE_D.Cod_UsuarioAct = @Cod_Usuario, 
                                  dbo.CAJ_COMPROBANTE_D.Fecha_Act = GETDATE()
                            WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @Id_ComandaOrigen
                                  AND (dbo.CAJ_COMPROBANTE_D.id_Detalle = @Origen_IdDetalle
                                       OR CAST(dbo.CAJ_COMPROBANTE_D.IGV AS INT) = @Origen_IdDetalle);
                            FETCH NEXT FROM Cursor_Origen INTO @Origen_IdDetalle, @Origen_IdProducto, @Origen_Descripcion, @Origen_PrecioUnitario, @Origen_Observacion;
                            SET @Origen_Contador = @Origen_Contador + 1;
        END;
                    CLOSE Cursor_Origen;
                    DEALLOCATE Cursor_Origen;

                    --Actualizamos los totales de las cabezeras del origen y el destino
                    --Origen
                    UPDATE dbo.CAJ_COMPROBANTE_PAGO
                      SET 
                          dbo.CAJ_COMPROBANTE_PAGO.Total = ROUND(
                    (
                        SELECT SUM(ccd.Cantidad * ccd.PrecioUnitario)
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaOrigen
                    ), 2), 
                          dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @Cod_Usuario, 
                          dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE()
                    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_ComandaOrigen; 
                    --Destino
                    UPDATE dbo.CAJ_COMPROBANTE_PAGO
                      SET 
                          dbo.CAJ_COMPROBANTE_PAGO.Total = ROUND(
                    (
                        SELECT SUM(ccd.Cantidad * ccd.PrecioUnitario)
                        FROM dbo.CAJ_COMPROBANTE_D ccd
                        WHERE ccd.id_ComprobantePago = @Id_ComandaDestino
                    ), 2), 
                          dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @Cod_Usuario, 
                          dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE()
                    WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @Id_ComandaDestino; 
                    --Se procede a liberar la mesa de origen
                    IF @Origen_CodMesa <> @Destino_CodMesa
                        BEGIN
                            DECLARE @IdMesaComanda INT;
                            SELECT @IdMesaComanda = a.id_ComprobantePago
                            FROM
                            (
                                SELECT Mesas.Cod_Mesa, 
                                       Mesas.Nom_Mesa, 
                                       ISNULL(Ocupados.Cod_UsuarioVendedor, '') Cod_UsuarioVendedor, 
                                       ISNULL(Ocupados.id_ComprobantePago, 0) id_ComprobantePago, 
                                       Ocupados.Fecha_Reg
                                FROM
                                (
                                    SELECT vm.Cod_Mesa, 
                                           vm.Nom_Mesa, 
                                           NULL Cod_UsuarioVendedor, 
                                           NULL id_ComprobantePago, 
                                           NULL Fecha_Reg
                                    FROM dbo.VIS_MESAS vm
                                    WHERE vm.Estado = 1
                                ) Mesas
                                LEFT JOIN
                                (
                                    SELECT DISTINCT 
                                           vm.Cod_Mesa, 
                                           vm.Nom_Mesa, 
                                           COALESCE(CASE
                                                        WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor, ' ', '')) = 0
                                                        THEN NULL
                                                        ELSE ccp.Cod_UsuarioVendedor
                                                    END, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor, 
                                           ccp.id_ComprobantePago, 
                                           ccp.Fecha_Reg
                                    FROM dbo.VIS_MESAS vm
                                         INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa = ccd.Cod_Manguera
                                         INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
                                    WHERE vm.Estado_Mesa = 'OCUPADO'
                                          AND vm.Estado = 1
                                          AND ccp.Cod_TipoComprobante = 'CO'
                                          AND ccp.Cod_Caja IS NULL
                                          AND ccp.Cod_Turno IS NULL
                                          AND ccd.Cantidad - ccd.Formalizado > 0
                                    UNION
                                    SELECT DISTINCT 
                                           vm.Cod_Mesa, 
                                           vm.Nom_Mesa, 
                                           COALESCE(CASE
                                                        WHEN LEN(REPLACE(ccp.Cod_UsuarioVendedor, ' ', '')) = 0
                                                        THEN NULL
                                                        ELSE ccp.Cod_UsuarioVendedor
                                                    END, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor, 
                                           ccp.id_ComprobantePago, 
                                           ccp.Fecha_Reg
                                    FROM dbo.VIS_MESAS vm
                                         INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON vm.Cod_Mesa = ccd.Cod_Manguera
                                         INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
                                    WHERE vm.Estado_Mesa = 'OCUPADO'
                                          AND vm.Estado = 1
                                          AND ccp.Cod_TipoComprobante = 'CO'
                                          AND ccd.IGV = 0
                                          AND ccd.Cantidad - ccd.Formalizado > 0
                                ) Ocupados ON Mesas.Cod_Mesa = Ocupados.Cod_Mesa
                            ) a
                            WHERE a.Cod_Mesa = @Origen_CodMesa;
                            IF @IdMesaComanda = 0
                                BEGIN
                                    EXEC dbo.USP_VIS_MESAS_GXEstado 
                                         @Cod_Mesa = @Origen_CodMesa, 
                                         @Estado_Mesa = 'LIBRE', 
                                         @Cod_Vendedor = @Cod_Usuario;
                            END;
                    END;
                    COMMIT TRANSACTION;
        END TRY
                BEGIN CATCH
                    IF(XACT_STATE()) = -1
                        BEGIN
                            ROLLBACK TRANSACTION;
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                            ) >= -1
                                BEGIN
                                    IF
                                    (
                                        SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                                    ) > -1
                                        BEGIN
                                            CLOSE Cursor_Origen;
                                    END;
                                    DEALLOCATE Cursor_Origen;
                            END;
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                            ) >= -1
                                BEGIN
                                    IF
                                    (
                                        SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                                    ) > -1
                                        BEGIN
                                            CLOSE Cursor_Destino;
                                    END;
                                    DEALLOCATE Cursor_Destino;
                            END;
                    END;
                    IF(XACT_STATE()) = 1
                        BEGIN
                            COMMIT TRANSACTION;
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                            ) >= -1
                                BEGIN
                                    IF
                                    (
                                        SELECT CURSOR_STATUS('global', 'Cursor_Origen')
                                    ) > -1
                                        BEGIN
                                            CLOSE Cursor_Origen;
                                    END;
                                    DEALLOCATE Cursor_Origen;
                            END;
                            IF
                            (
                                SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                            ) >= -1
                                BEGIN
                                    IF
                                    (
                                        SELECT CURSOR_STATUS('global', 'Cursor_Destino')
                                    ) > -1
                                        BEGIN
                                            CLOSE Cursor_Destino;
                                    END;
                                    DEALLOCATE Cursor_Destino;
                            END;
                    END;
                    THROW;
        END CATCH;
        END;
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
        EXEC USP_PAR_FILA_G '079', '001', @id_Fila, @Documento, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '002', @id_Fila, 'CAJ_LETRA_CAMBIO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '003', @id_Fila, @Proveedor, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '004', @id_Fila, @Detalle, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '005', @id_Fila, NULL, NULL, NULL, @FechaEmision, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '006', @id_Fila, NULL, NULL, NULL, @FechaActual, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '007', @id_Fila, @CodUsuario, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '008', @id_Fila, @Justificacion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '009', @id_Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
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
        WHERE dbo.CAJ_COMPROBANTE_RELACION.Id_ComprobanteRelacion =
        (
            SELECT clc.Id_Letra
            FROM dbo.CAJ_LETRA_CAMBIO clc
            WHERE clc.Id = @Id
        )
              AND dbo.CAJ_COMPROBANTE_RELACION.Cod_TipoRelacion = 'LET';

        --Guardamos la jsutificacion

        DECLARE @FechaActual DATETIME= GETDATE();
        DECLARE @id_Fila INT=
        (
            SELECT ISNULL(COUNT(*) / 9, 1) + 1
            FROM PAR_FILA
            WHERE Cod_Tabla = '079'
        );
        EXEC USP_PAR_FILA_G '079', '001', @id_Fila, @Documento, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '002', @id_Fila, 'CAJ_LETRA_CAMBIO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '003', @id_Fila, @Proveedor, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '004', @id_Fila, @Detalle, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '005', @id_Fila, NULL, NULL, NULL, @FechaEmision, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '006', @id_Fila, NULL, NULL, NULL, @FechaActual, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '007', @id_Fila, @Cod_Usuario, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '008', @id_Fila, @Justificacion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '009', @id_Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
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
        EXEC USP_PAR_FILA_G '079', '001', @id_Fila, @Documento, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '002', @id_Fila, 'CAJ_LETRA_CAMBIO', NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '003', @id_Fila, @Proveedor, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '004', @id_Fila, @Detalle, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '005', @id_Fila, NULL, NULL, NULL, @FechaEmision, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '006', @id_Fila, NULL, NULL, NULL, @FechaActual, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '007', @id_Fila, @Cod_Usuario, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '008', @id_Fila, @Justificacion, NULL, NULL, NULL, NULL, 1, 'MIGRACION';
        EXEC USP_PAR_FILA_G '079', '009', @id_Fila, NULL, NULL, NULL, NULL, 1, 1, 'MIGRACION';
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_BAN_CUENTA_BANCARIA_TraerXIdCLienteProveedor'
          AND type = 'P'
)
    DROP PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXIdCLienteProveedor;
GO
CREATE PROCEDURE USP_BAN_CUENTA_BANCARIA_TraerXIdCLienteProveedor @Id_ClienteProveedor INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               pcc.NroCuenta_Bancaria Cod_CuentaBancaria, 
               pcc.Cod_EntidadFinanciera Cod_EntidadFinanciera, 
               pcc.Des_CuentaBancaria Des_CuentaBancaria, 
               pcc.Cod_TipoCuentaBancaria Cod_TipoCuentaBancaria
        FROM dbo.PRI_CLIENTE_CUENTABANCARIA pcc
        WHERE pcc.Id_ClienteProveedor = @Id_ClienteProveedor;
    END;
GO
IF NOT EXISTS
(
    SELECT cc.*
    FROM dbo.CAJ_CONCEPTO cc
    WHERE cc.Id_Concepto = 70003
)
    BEGIN
        INSERT INTO dbo.CAJ_CONCEPTO
        VALUES
        (70003, -- Id_Concepto - int
         'AMORTIZACION DE LETRA DE CAMBIO', -- Des_Concepto - varchar
         '006', -- Cod_ClaseConcepto - varchar
         1, -- Flag_Activo - bit
         0, -- Id_ConceptoPadre - int
         'MIGRACION', -- Cod_UsuarioReg - varchar
         GETDATE(), -- Fecha_Reg - datetime
         NULL, -- Cod_UsuarioAct - varchar
         NULL -- Fecha_Act - datetime
        );
END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite verificar si en la lista de productos existe tipo de producto como Lote
-- EXEC USP_PRI_Recuperar_Existe_Producto_Lote
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_Recuperar_Existe_Producto_Lote'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_Recuperar_Existe_Producto_Lote;
GO
CREATE PROCEDURE USP_PRI_Recuperar_Existe_Producto_Lote
AS
    BEGIN
        SELECT COUNT(*)
        FROM [PALERPpale].[dbo].[PRI_PRODUCTOS]
        WHERE Cod_TipoProducto = 'PRL';
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_TAR_ACTIVIDADES_X_Cronometro_TT 'c000001','ADMINISTRADOR','-------------' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_D_TxIdAlmacen'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_D_TxIdAlmacen;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_D_TxIdAlmacen @Id_Inventario AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT ID.Item, 
               ID.Id_Producto, 
               P.Nom_Producto, 
               ID.Cod_UnidadMedida, 
               VUM.Nom_UnidadMedida, 
               ID.Cod_Almacen, 
               A.Des_Almacen, 
               ID.Cantidad_Sistema, 
               ID.Cantidad_Encontrada, 
               ID.Obs_InventarioD
        FROM ALM_INVENTARIO_D AS ID
             INNER JOIN PRI_PRODUCTOS AS P ON ID.Id_Producto = P.Id_Producto
             INNER JOIN ALM_ALMACEN AS A ON ID.Cod_Almacen = A.Cod_Almacen
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON ID.Cod_UnidadMedida = VUM.Cod_UnidadMedida
        WHERE ID.Id_Inventario = @Id_Inventario
        ORDER BY CONVERT(INT, ID.Item);
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_TAR_ACTIVIDADES_X_Cronometro_TT 'c000001','ADMINISTRADOR','-------------' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_VIS_TIPO_INVENTARIO'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_TIPO_INVENTARIO;
GO
CREATE PROCEDURE USP_VIS_TIPO_INVENTARIO
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_TipoInventario, 
               Nom_TipoInventario
        FROM VIS_TIPO_INVENTARIO;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_TAR_ACTIVIDADES_X_Cronometro_TT 'c000001','ADMINISTRADOR','-------------' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_Inventario_TSiguienteNumero'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_Inventario_TSiguienteNumero;
GO
CREATE PROCEDURE USP_ALM_Inventario_TSiguienteNumero @IdAlmacen VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT ISNULL(MAX([Id_Inventario]), 0) + 1
        FROM [dbo].[ALM_INVENTARIO]
        WHERE [Cod_Almacen] = @IdAlmacen;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_TAR_ACTIVIDADES_X_Cronometro_TT 'c000001','ADMINISTRADOR','-------------' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_ALMACEN_MOV_D_TXIdMovimiento'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_ALMACEN_MOV_D_TXIdMovimiento;
GO
CREATE PROCEDURE USP_ALM_ALMACEN_MOV_D_TXIdMovimiento @Id_AlmacenMov AS INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT D.Id_AlmacenMov, 
               D.Item, 
               D.Id_Producto, 
               D.Des_Producto, 
               D.Precio_Unitario, 
               D.Cantidad, 
               D.Cod_UnidadMedida, 
               D.Obs_AlmacenMovD, 
               VUM.Nom_UnidadMedida, 
               P.Des_CortaProducto, 
               P.Des_LargaProducto, 
               p.Cod_Producto
        FROM ALM_ALMACEN_MOV_D AS D
             INNER JOIN PRI_PRODUCTOS AS P ON D.Id_Producto = P.Id_Producto
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON D.Cod_UnidadMedida = VUM.Cod_UnidadMedida
        WHERE Id_AlmacenMov = @Id_AlmacenMov;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'UFN_CAJ_SERIES_Stocks'
)
    DROP FUNCTION UFN_CAJ_SERIES_Stocks;
GO
CREATE FUNCTION UFN_CAJ_SERIES_Stocks
(@Serie AS       VARCHAR(512), 
 @Id_Producto AS INT, 
 @Id_Almacen AS  VARCHAR(32), 
 @F_Venc      DATE, 
 @CodTabla AS    VARCHAR(32)
)
RETURNS INT
WITH ENCRYPTION
AS
     BEGIN
         DECLARE @StockComprobante AS INT;
         DECLARE @StockAlmacen AS INT;
         SET @StockComprobante =
         (
             SELECT ISNULL(SUM(CASE
                                   WHEN cp.Cod_Libro = '08'
                                        AND Flag_Anulado = 0
                                   THEN 1
                                   WHEN cp.Cod_Libro = '14'
                                        AND Flag_Anulado = 0
                                   THEN-1
                                   ELSE 0
                               END), 0)
             FROM [dbo].[CAJ_COMPROBANTE_D] CD
                  INNER JOIN [dbo].[CAJ_SERIES] S ON(CD.id_ComprobantePago = S.Id_Tabla
                                                     AND CD.id_Detalle = s.Item)
                  INNER JOIN [CAJ_COMPROBANTE_PAGO] CP ON(CD.id_ComprobantePago = CP.id_ComprobantePago)
             WHERE S.serie = @Serie
                   AND CD.Id_Producto = @Id_Producto
                   AND [Cod_Almacen] = @Id_Almacen
                   AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
         );
         SET @StockAlmacen =
         (
             SELECT ISNULL(SUM(CASE
                                   WHEN AM.Cod_TipoComprobante = 'NE'
                                        AND Flag_Anulado = 0
                                   THEN 1
                                   WHEN AM.Cod_TipoComprobante = 'NS'
                                        AND Flag_Anulado = 0
                                   THEN-1
                                   ELSE 0
                               END), 0)
             FROM ALM_ALMACEN_MOV_D AMD
                  INNER JOIN [dbo].[CAJ_SERIES] S ON(AMD.Id_AlmacenMov = S.Id_Tabla
                                                     AND AMD.Item = s.Item)
                  INNER JOIN ALM_ALMACEN_MOV AM ON(AMD.Id_AlmacenMov = AM.Id_AlmacenMov)
             WHERE S.serie = @Serie
                   AND AMD.Id_Producto = @Id_Producto
                   AND [Cod_Almacen] = @Id_Almacen
                   AND CONVERT(DATETIME, CONVERT(VARCHAR, Fecha_Vencimiento, 103)) = @F_Venc
         );
         RETURN @StockComprobante + @StockAlmacen;
     END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_TAR_ACTIVIDADES_X_Cronometro_TT 'c000001','ADMINISTRADOR','-------------' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_ALM_INVENTARIO_RECUPERAR_DETALLE'
          AND type = 'P'
)
    DROP PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_DETALLE;
GO
CREATE PROCEDURE USP_ALM_INVENTARIO_RECUPERAR_DETALLE @pIdInventario INT, 
                                                      @pCodCategoria VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF(@pCodCategoria = '-1')
            BEGIN
                SELECT [Item], 
                       AID.[Id_Producto], 
                       PR.[Cod_Producto] AS 'Codigo', 
                       PR.Nom_Producto AS 'Producto',
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN Stock_Act - Cantidad_Sistema
                           ELSE 0
                       END AS Stock_Act, 
                       Cantidad_Sistema,
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN [Cantidad_Sistema] + (Stock_Act - Cantidad_Sistema)
                           ELSE Cantidad_Sistema
                       END AS Cantidad, 
                       Cantidad_Encontrada,
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN Cantidad_Encontrada + (Stock_Act - Cantidad_Sistema)
                           ELSE Cantidad_Encontrada
                       END AS Inventario, 
                       ISNULL(Cantidad_Encontrada, 0) - ISNULL(Cantidad_Sistema, 0) saldo, 
                       AID.Precio_Unitario AS Precio, 
                       um.Nom_UnidadMedida UM, 
                       AID.Cod_UnidadMedida, 
                       PR.Cod_TipoProducto TipoProducto, 
                       STUFF(
                (
                    SELECT '.' + CONCAT(T.[Serie], ',', CONVERT(VARCHAR, T.[Fecha_Vencimiento], 103))
                    FROM [dbo].[CAJ_SERIES] T
                    --				@Serie as varchar(512),
                    --@Id_Producto as int,
                    --@Id_Almacen as varchar(32),
                    --@F_Venc date,
                    --@CodTabla as varchar(32)) 
                    WHERE AID.Id_Inventario = T.Id_Tabla
                          AND AID.Item = T.Item
                          AND dbo.whg(Serie, AID.Id_Producto, AI.Cod_Almacen, T.Fecha_Vencimiento, '') = 1 FOR XML PATH('')
                ), 1, 1, '') AS Serie
                FROM [dbo].[ALM_INVENTARIO_D] AID
                     INNER JOIN [dbo].[ALM_INVENTARIO] AI ON(AID.Id_Inventario = AI.Id_Inventario)
                     INNER JOIN PRI_PRODUCTOS PR ON(AID.Id_Producto = PR.Id_Producto)
                     INNER JOIN PRI_PRODUCTO_STOCK PS ON(AID.Id_Producto = PS.Id_Producto
                                                         AND AI.Cod_Almacen = PS.Cod_Almacen)
                     INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON AID.Cod_UnidadMedida = UM.Cod_UnidadMedida
                WHERE AID.Id_Inventario = @pIdInventario;
        END;
            ELSE
            BEGIN
                SELECT [Item], 
                       AID.[Id_Producto], 
                       PR.[Cod_Producto] AS 'Codigo', 
                       PR.Nom_Producto AS 'Producto',
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN Stock_Act - Cantidad_Sistema
                           ELSE 0
                       END AS Stock_Act, 
                       Cantidad_Sistema,
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN [Cantidad_Sistema] + (Stock_Act - Cantidad_Sistema)
                           ELSE Cantidad_Sistema
                       END AS Cantidad, 
                       Cantidad_Encontrada, 
                       ISNULL(Cantidad_Encontrada, 0) - ISNULL(Cantidad_Sistema, 0) saldo,
                       CASE
                           WHEN AI.Cod_EstadoInventario = 'PENDIENTE'
                           THEN Cantidad_Encontrada + (Stock_Act - Cantidad_Sistema)
                           ELSE Cantidad_Encontrada
                       END AS Inventario, 
                       AID.Precio_Unitario AS Precio, 
                       um.Nom_UnidadMedida UM, 
                       AID.Cod_UnidadMedida, 
                       PR.Cod_TipoProducto TipoProducto, 
                       STUFF(
                (
                    SELECT '.' + CONCAT(T.[Serie], ',', CONVERT(VARCHAR, T.[Fecha_Vencimiento], 103))
                    FROM [dbo].[CAJ_SERIES] T
                    WHERE AID.Id_Inventario = T.Id_Tabla
                          AND AID.Item = T.Item
                          AND dbo.UFN_CAJ_SERIES_Stocks(Serie, AID.Id_Producto, AI.Cod_Almacen, T.Fecha_Vencimiento, '') = 1 FOR XML PATH('')
                ), 1, 1, '') AS Serie
                FROM [dbo].[ALM_INVENTARIO_D] AID
                     INNER JOIN [dbo].[ALM_INVENTARIO] AI ON(AID.Id_Inventario = AI.Id_Inventario)
                     INNER JOIN PRI_PRODUCTOS PR ON(AID.Id_Producto = PR.Id_Producto)
                     INNER JOIN PRI_PRODUCTO_STOCK PS ON(AID.Id_Producto = PS.Id_Producto
                                                         AND AI.Cod_Almacen = PS.Cod_Almacen)
                     INNER JOIN VIS_UNIDADES_DE_MEDIDA AS UM ON AID.Cod_UnidadMedida = UM.Cod_UnidadMedida
                WHERE AID.Id_Inventario = @pIdInventario
                      AND PR.Cod_Categoria = @pCodCategoria;
        END;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_PRI_PRODUCTO_TXCodAlmacen_Periodo
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TXCodAlmacen_Periodo'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TXCodAlmacen_Periodo;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TXCodAlmacen_Periodo @Cod_Almacen AS VARCHAR(32), 
                                                       @anio        INT, 
                                                       @mes         INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT PS.Id_Producto, 
               PS.Cod_UnidadMedida, 
               PS.Cod_Almacen, 
               PS.Stock_Act, 
               VUM.Nom_UnidadMedida, 
               P.Nom_Producto, 
               P.Cod_Producto, 
               PS.Precio_Venta, 
               [Cantidad_Sistema], 
               [Cantidad_Encontrada], 
               'ogog' serie
        FROM PRI_PRODUCTO_STOCK AS PS
             INNER JOIN PRI_PRODUCTOS AS P ON PS.Id_Producto = P.Id_Producto
             INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VUM ON PS.Cod_UnidadMedida = VUM.Cod_UnidadMedida
             LEFT JOIN ALM_INVENTARIO_D AS INV ON PS.Id_Producto = INV.Id_Producto
        WHERE(PS.Cod_Almacen = @Cod_Almacen)
             AND p.Flag_Activo = 1
             AND P.Flag_Stock = 1
        ORDER BY P.Id_Producto;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USP_CAJ_SERIES_xSerie
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_TOPxSerie'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_TOPxSerie;
GO
CREATE PROCEDURE USP_CAJ_SERIES_TOPxSerie @Serie       VARCHAR(32), 
                                          @Cod_Almacen VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        WITH SERIE(Cod_Tabla, 
                   Id_Tabla, 
                   Item, 
                   Serie, 
                   Fecha_Vencimiento, 
                   Obs_Serie, 
                   Cod_Producto, 
                   Des_Producto, 
                   Des_Almacen, 
                   Comprobante, 
                   Fecha, 
                   Motivo, 
                   Flag_Anulado, 
                   Estado, 
                   Stock, 
                   Id_Producto, 
                   Cod_Almacen, 
                   Cod_UnidadMedida, 
                   Fecha_Reg, 
                   Precio_Venta, 
                   Precio_Compra, 
                   Nom_UnidadMedida, 
                   Cod_TipoOperatividad)
             AS (SELECT TOP 1 S.Cod_Tabla, 
                              S.Id_Tabla, 
                              S.Item, 
                              S.Serie, 
                              S.Fecha_Vencimiento, 
                              S.Obs_Serie, 
                              P.Cod_Producto, 
                              MD.Des_Producto, 
                              A.Des_Almacen, 
                              AM.Cod_TipoComprobante + ' : ' + AM.Serie + ' - ' + AM.Numero AS Comprobante, 
                              AM.Fecha, 
                              AM.Motivo, 
                              AM.Flag_Anulado,
                              CASE AM.Cod_TipoComprobante
                                  WHEN 'NE'
                                  THEN 'ENTRADA'
                                  WHEN 'NS'
                                  THEN 'SALIDA'
                                  ELSE ''
                              END AS Estado,
                              CASE
                                  WHEN AM.Cod_TipoComprobante = 'NE'
                                       AND Flag_Anulado = 0
                                  THEN 1
                                  WHEN AM.Cod_TipoComprobante = 'NS'
                                       AND Flag_Anulado = 0
                                  THEN-1
                                  ELSE 0
                              END AS Stock, 
                              P.Id_Producto, 
                              A.Cod_Almacen, 
                              PS.Cod_UnidadMedida, 
                              AM.Fecha_Reg, 
                              PS.Precio_Venta, 
                              PS.Precio_Compra, 
                              VU.Nom_UnidadMedida, 
                              P.Cod_TipoOperatividad
                 FROM PRI_PRODUCTOS AS P
                      INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
                      INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
                      INNER JOIN ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen
                      INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                             AND AM.Cod_Almacen = PS.Cod_Almacen
                      INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida
                      RIGHT OUTER JOIN CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla
                                                          AND MD.Item = S.Item
                 WHERE(S.Cod_Tabla = 'ALM_ALMACEN_MOV')
                      AND (S.Serie LIKE '%' + @Serie)
                      AND Flag_Anulado = 0
                      AND AM.Cod_Almacen = @Cod_Almacen
                 ORDER BY Fecha_Reg DESC
                 UNION
                 SELECT TOP 1 S.Cod_Tabla, 
                              S.Id_Tabla, 
                              S.Item, 
                              S.Serie, 
                              S.Fecha_Vencimiento, 
                              S.Obs_Serie, 
                              P.Cod_Producto, 
                              CD.Descripcion AS Des_Producto, 
                              A.Des_Almacen, 
                              CP.Cod_TipoComprobante + ' : ' + CP.Serie + ' - ' + CP.Numero AS Comprobante, 
                              CP.FechaEmision, 
                              CP.Glosa, 
                              CP.Flag_Anulado,
                              CASE cp.Cod_Libro
                                  WHEN '08'
                                  THEN 'ENTRADA'
                                  WHEN '14'
                                  THEN 'SALIDA'
                                  ELSE ''
                              END AS Estado,
                              CASE
                                  WHEN cp.Cod_Libro = '08'
                                       AND Flag_Anulado = 0
                                  THEN 1
                                  WHEN cp.Cod_Libro = '14'
                                       AND Flag_Anulado = 0
                                  THEN-1
                                  ELSE 0
                              END AS Stock, 
                              P.Id_Producto, 
                              A.Cod_Almacen, 
                              PS.Cod_UnidadMedida, 
                              CP.Fecha_Reg, 
                              PS.Precio_Venta, 
                              PS.Precio_Compra, 
                              VU.Nom_UnidadMedida, 
                              P.Cod_TipoOperatividad
                 FROM PRI_PRODUCTOS AS P
                      INNER JOIN CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto
                      INNER JOIN CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
                      INNER JOIN ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen
                      INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                             AND CD.Cod_Almacen = PS.Cod_Almacen
                      INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON CD.Cod_UnidadMedida = VU.Cod_UnidadMedida
                      RIGHT OUTER JOIN CAJ_SERIES AS S ON CD.id_ComprobantePago = S.Id_Tabla
                                                          AND CD.id_Detalle = S.Item
                 WHERE(S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
                      AND (S.Serie LIKE '%' + @Serie)
                      AND Flag_Anulado = 0
                      AND CD.Cod_Almacen = @Cod_Almacen)
             SELECT Serie, 
                    Fecha_Vencimiento, 
                    Obs_Serie, 
                    Cod_Producto, 
                    Des_Producto, 
                    Des_Almacen, 
                    dbo.UFN_VIS_SERIES_Stock(Serie) AS Stock, 
                    Id_Producto, 
                    Cod_Almacen, 
                    Cod_UnidadMedida, 
                    Nom_UnidadMedida, 
                    Precio_Venta, 
                    Cod_TipoOperatividad
             FROM SERIE;
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 25/06/2019;
-- OBJETIVO: Procedimiento que permite Recuperar la ultima Fecha de la emision del Comprobante segun tipo de comprobante 
-- EXEC USUSP_PRI_CATEGORIA_TT_TODO
--------------------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_SERIES_RecuperarXProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_SERIES_RecuperarXProducto;
GO
CREATE PROCEDURE USP_CAJ_SERIES_RecuperarXProducto @Cod_Producto AS VARCHAR(32), 
                                                   @Cod_Almacen  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        WITH SERIE(Cod_Tabla, 
                   Id_Tabla, 
                   Item, 
                   Serie, 
                   Fecha_Vencimiento, 
                   Obs_Serie, 
                   Cod_Producto, 
                   Des_Producto, 
                   Des_Almacen, 
                   Comprobante, 
                   Fecha, 
                   Motivo, 
                   Flag_Anulado, 
                   Estado, 
                   Stock, 
                   Id_Producto, 
                   Cod_Almacen, 
                   Cod_UnidadMedida, 
                   Fecha_Reg, 
                   Precio_Venta, 
                   Precio_Compra, 
                   Nom_UnidadMedida, 
                   Cod_TipoOperatividad)
             AS (SELECT TOP 1 S.Cod_Tabla, 
                              S.Id_Tabla, 
                              S.Item, 
                              S.Serie, 
                              S.Fecha_Vencimiento, 
                              S.Obs_Serie, 
                              P.Cod_Producto, 
                              MD.Des_Producto, 
                              A.Des_Almacen, 
                              AM.Cod_TipoComprobante + ' : ' + AM.Serie + ' - ' + AM.Numero AS Comprobante, 
                              AM.Fecha, 
                              AM.Motivo, 
                              AM.Flag_Anulado,
                              CASE AM.Cod_TipoComprobante
                                  WHEN 'NE'
                                  THEN 'ENTRADA'
                                  WHEN 'NS'
                                  THEN 'SALIDA'
                                  ELSE ''
                              END AS Estado,
                              CASE
                                  WHEN AM.Cod_TipoComprobante = 'NE'
                                       AND Flag_Anulado = 0
                                  THEN 1
                                  WHEN AM.Cod_TipoComprobante = 'NS'
                                       AND Flag_Anulado = 0
                                  THEN-1
                                  ELSE 0
                              END AS Stock, 
                              P.Id_Producto, 
                              A.Cod_Almacen, 
                              PS.Cod_UnidadMedida, 
                              AM.Fecha_Reg, 
                              PS.Precio_Venta, 
                              PS.Precio_Compra, 
                              VU.Nom_UnidadMedida, 
                              P.Cod_TipoOperatividad
                 FROM PRI_PRODUCTOS AS P
                      INNER JOIN ALM_ALMACEN_MOV_D AS MD ON P.Id_Producto = MD.Id_Producto
                      INNER JOIN ALM_ALMACEN_MOV AS AM ON MD.Id_AlmacenMov = AM.Id_AlmacenMov
                      INNER JOIN ALM_ALMACEN AS A ON AM.Cod_Almacen = A.Cod_Almacen
                      INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                             AND AM.Cod_Almacen = PS.Cod_Almacen
                      INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON MD.Cod_UnidadMedida = VU.Cod_UnidadMedida
                      RIGHT OUTER JOIN CAJ_SERIES AS S ON MD.Id_AlmacenMov = S.Id_Tabla
                                                          AND MD.Item = S.Item
                 WHERE(S.Cod_Tabla = 'ALM_ALMACEN_MOV')
                      AND (P.Id_Producto = @Cod_Producto)
                      AND Flag_Anulado = 0
                      AND AM.Cod_Almacen = @Cod_Almacen
                 ORDER BY Fecha_Reg DESC
                 UNION
                 SELECT TOP 1 S.Cod_Tabla, 
                              S.Id_Tabla, 
                              S.Item, 
                              S.Serie, 
                              S.Fecha_Vencimiento, 
                              S.Obs_Serie, 
                              P.Cod_Producto, 
                              CD.Descripcion AS Des_Producto, 
                              A.Des_Almacen, 
                              CP.Cod_TipoComprobante + ' : ' + CP.Serie + ' - ' + CP.Numero AS Comprobante, 
                              CP.FechaEmision, 
                              CP.Glosa, 
                              CP.Flag_Anulado,
                              CASE cp.Cod_Libro
                                  WHEN '08'
                                  THEN 'ENTRADA'
                                  WHEN '14'
                                  THEN 'SALIDA'
                                  ELSE ''
                              END AS Estado,
                              CASE
                                  WHEN cp.Cod_Libro = '08'
                                       AND Flag_Anulado = 0
                                  THEN 1
                                  WHEN cp.Cod_Libro = '14'
                                       AND Flag_Anulado = 0
                                  THEN-1
                                  ELSE 0
                              END AS Stock, 
                              P.Id_Producto, 
                              A.Cod_Almacen, 
                              PS.Cod_UnidadMedida, 
                              CP.Fecha_Reg, 
                              PS.Precio_Venta, 
                              PS.Precio_Compra, 
                              VU.Nom_UnidadMedida, 
                              P.Cod_TipoOperatividad
                 FROM PRI_PRODUCTOS AS P
                      INNER JOIN CAJ_COMPROBANTE_D AS CD ON P.Id_Producto = CD.Id_Producto
                      INNER JOIN CAJ_COMPROBANTE_PAGO AS CP ON CD.id_ComprobantePago = CP.id_ComprobantePago
                      INNER JOIN ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen
                      INNER JOIN PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto
                                                             AND CD.Cod_Almacen = PS.Cod_Almacen
                      INNER JOIN VIS_UNIDADES_DE_MEDIDA AS VU ON CD.Cod_UnidadMedida = VU.Cod_UnidadMedida
                      RIGHT OUTER JOIN CAJ_SERIES AS S ON CD.id_ComprobantePago = S.Id_Tabla
                                                          AND CD.id_Detalle = S.Item
                 WHERE(S.Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')
                      AND (P.Id_Producto = @Cod_Producto)
                      AND Flag_Anulado = 0
                      AND CD.Cod_Almacen = @Cod_Almacen)
             SELECT Serie, 
                    Fecha_Vencimiento, 
                    Obs_Serie
             FROM SERIE;
    END;
GO

--	 Archivo: USP_PRI_PRODUCTO_TASA.sql
--
--	 Versión: v2.1.10
--
--	 Autor(es): Reyber Yuri Palma Quispe  y Laura Yanina Alegria Amudio
--
--	 Fecha de Creación:  Thu Aug 08 18:47:23 2019
--
--	 Copyright  Pale Consultores EIRL Peru	2013
-- Guadar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_G;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_G @Id_Producto    INT, 
                                         @Cod_Tasa       VARCHAR(32), 
                                         @Cod_Libro      VARCHAR(2), 
                                         @Des_Tasa       VARCHAR(512), 
                                         @Por_Tasa       NUMERIC(10, 4), 
                                         @Cod_TipoTasa   VARCHAR(64), 
                                         @Cod_Aplicacion VARCHAR(64), 
                                         @Flag_Activo    BIT, 
                                         @Obs_Tasa       VARCHAR(1024), 
                                         @Cod_Usuario    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT @Id_Producto, 
                   @Cod_Tasa
            FROM PRI_PRODUCTO_TASA
            WHERE(Id_Producto = @Id_Producto)
                 AND (Cod_Tasa = @Cod_Tasa)
        )
            BEGIN
                INSERT INTO PRI_PRODUCTO_TASA
                VALUES
                (@Id_Producto, 
                 @Cod_Tasa, 
                 @Cod_Libro, 
                 @Des_Tasa, 
                 @Por_Tasa, 
                 @Cod_TipoTasa, 
                 @Cod_Aplicacion, 
                 @Flag_Activo, 
                 @Obs_Tasa, 
                 @Cod_Usuario, 
                 GETDATE(), 
                 NULL, 
                 NULL
                );
        END;
            ELSE
            BEGIN
                UPDATE PRI_PRODUCTO_TASA
                  SET 
                      Cod_Libro = @Cod_Libro, 
                      Des_Tasa = @Des_Tasa, 
                      Por_Tasa = @Por_Tasa, 
                      Cod_TipoTasa = @Cod_TipoTasa, 
                      Cod_Aplicacion = @Cod_Aplicacion, 
                      Flag_Activo = @Flag_Activo, 
                      Obs_Tasa = @Obs_Tasa, 
                      Cod_UsuarioAct = @Cod_Usuario, 
                      Fecha_Act = GETDATE()
                WHERE(Id_Producto = @Id_Producto)
                     AND (Cod_Tasa = @Cod_Tasa);
        END;
    END;
GO

-- Eliminar
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_E;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_E @Id_Producto INT, 
                                         @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DELETE FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Todo
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TT;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Producto, 
               Cod_Tasa, 
               Cod_Libro, 
               Des_Tasa, 
               Por_Tasa, 
               Cod_TipoTasa, 
               Cod_Aplicacion, 
               Flag_Activo, 
               Obs_Tasa, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA;
    END;
GO

-- Traer Paginado
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TP;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TP @TamañoPagina VARCHAR(16), 
                                          @NumeroPagina VARCHAR(16), 
                                          @ScripOrden   VARCHAR(MAX) = NULL, 
                                          @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id_Producto , Cod_Tasa , Cod_Libro , Des_Tasa , Por_Tasa , Cod_TipoTasa , Cod_Aplicacion , Flag_Activo , Obs_Tasa , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act  
		FROM (SELECT TOP 100 PERCENT Id_Producto , Cod_Tasa , Cod_Libro , Des_Tasa , Por_Tasa , Cod_TipoTasa , Cod_Aplicacion , Flag_Activo , Obs_Tasa , Cod_UsuarioReg , Fecha_Reg , Cod_UsuarioAct , Fecha_Act ,
			  ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila 
			  FROM PRI_PRODUCTO_TASA ' + @ScripWhere + ') aPRI_PRODUCTO_TASA
		WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

-- Traer Por Claves primarias
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TXPK;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TXPK @Id_Producto INT, 
                                            @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Id_Producto, 
               Cod_Tasa, 
               Cod_Libro, 
               Des_Tasa, 
               Por_Tasa, 
               Cod_TipoTasa, 
               Cod_Aplicacion, 
               Flag_Activo, 
               Obs_Tasa, 
               Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Auditoria
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_Auditoria;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_Auditoria @Id_Producto INT, 
                                                 @Cod_Tasa    VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT Cod_UsuarioReg, 
               Fecha_Reg, 
               Cod_UsuarioAct, 
               Fecha_Act
        FROM PRI_PRODUCTO_TASA
        WHERE(Id_Producto = @Id_Producto)
             AND (Cod_Tasa = @Cod_Tasa);
    END;
GO

-- Traer Número de Filas
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_TASA_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TNF;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS NroFilas  FROM PRI_PRODUCTO_TASA '+@ScripWhere);
    END;
GO

--------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYEM CHAMBI
-- CREACION: 13/08/2019
-- OBJETIVO : Trae las tasas en base a un id de producto
-- EXEC USP_PRI_PRODUCTO_TASA_TraerXIdProducto 1000
--------------------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_PRODUCTO_TASA_TraerXIdProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_TASA_TraerXIdProducto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_TASA_TraerXIdProducto @Id_Producto INT
AS
    BEGIN
        SELECT DISTINCT 
               ppt.Cod_Tasa,
               CASE
                   WHEN ppt.Cod_Libro = '14'
                   THEN 'VENTA'
                   ELSE 'COMPRA'
               END Libro, 
               ppt.Des_Tasa, 
               ppt.Cod_Aplicacion, 
               ppt.Por_Tasa, 
               ppt.Flag_Activo
        FROM dbo.PRI_PRODUCTO_TASA ppt
        WHERE ppt.Id_Producto = @Id_Producto;
    END;
GO
-----------------------------------------------------------------------------------------------
-- CREACION : 16/08/2019
-- AUTOR: ERWIN M. RAYME CHAMBI
-- OBJETIVO : Obtener las tasa especificada de un detalle de comprobante por id_comprobantepago, id_detalle, Cod_tasa y Cod_libro
-- SELECT dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(8477,1,'ICBPER','14')
------------------------------------------------------------------------------------------------ 
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro'
)
    BEGIN
        DROP FUNCTION UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro;
END;
GO
CREATE FUNCTION UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro
(@Id_ComprobantePago INT, 
 @Id_Detalle         INT, 
 @Cod_Tasa           VARCHAR(32), 
 @Cod_Libro          VARCHAR(2)
)
RETURNS NUMERIC(38, 6)
AS
     BEGIN
         RETURN ISNULL(
         (
             SELECT CASE
                        WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                        THEN ccd.Cantidad * (CAST(ppt.Por_Tasa AS NUMERIC(38, 6)) / 100) * (100 - CASE
                                                                                                      WHEN ccd.Cod_TipoIGV = 10
                                                                                                      THEN CAST(ccd.Porcentaje_IGV AS NUMERIC(38, 6))
                                                                                                      ELSE 0
                                                                                                  END - CASE
                                                                                                            WHEN ccd.Cod_TipoIGV != NULL
                                                                                                            THEN CAST(ccd.Porcentaje_ISC AS NUMERIC(38, 6))
                                                                                                            ELSE 0
                                                                                                        END) * ((ccd.PrecioUnitario - (CAST(ccd.Descuento AS NUMERIC(38, 6)) / ccd.Cantidad)) / 100)
                        WHEN ppt.Cod_Aplicacion = 'MONTO'
                        THEN ccd.Cantidad * CAST(ppt.Por_Tasa AS NUMERIC(38, 6))
                        ELSE 0
                    END
             FROM dbo.PRI_PRODUCTO_TASA ppt
                  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.id_ComprobantePago = @Id_ComprobantePago
                                                          AND ccd.id_Detalle = @Id_Detalle
                                                          AND ppt.Id_Producto = ccd.Id_Producto
                                                          AND ppt.Cod_Tasa = @Cod_Tasa
                                                          AND ppt.Cod_Libro = @Cod_Libro
         ), 0);
     END;
GO

------------------------------------------------------------------------------------------------------------
-- FECHA: 19/08/2019
-- AUTOR: ERWIN M. RAYME CHAMBI
-- OBJECTIVO: Obtiene la tasa de un producto en base al id_comprobante, id_detalle y cod_tasa
-- EXEC USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle 1900,0,'ICBPER'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_D_TraerTasaXIdComprobanteIdDetalle @Id_ComprobantePago INT, 
                                                                        @Id_Detalle         INT, 
                                                                        @Cod_Tasa           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT ppt.*
        FROM dbo.CAJ_COMPROBANTE_D ccd
             INNER JOIN dbo.PRI_PRODUCTO_TASA ppt ON ccd.id_ComprobantePago = @Id_ComprobantePago
                                                     AND ccd.id_Detalle = @Id_Detalle
                                                     AND ppt.Cod_Tasa = @Cod_Tasa
                                                     AND ppt.Flag_Activo = 1
                                                     AND ccd.Id_Producto = ppt.Id_Producto;
    END;
GO
--Obtiene los items de un comprobante por id
--solo aquellos que no son componentes, sino productos
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_MESAS_ObtenerDetallesComprobante'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_MESAS_ObtenerDetallesComprobante;
GO
CREATE PROCEDURE USP_VIS_MESAS_ObtenerDetallesComprobante @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               ccd.id_ComprobantePago, 
               ccd.id_Detalle, 
               ccd.Id_Producto, 
               ccd.Cod_Almacen, 
               (ccd.Cantidad - ccd.Formalizado) Cantidad, 
               ccd.Cod_UnidadMedida, 
               ccd.Despachado, 
               ccd.Descripcion, 
               ccd.PrecioUnitario, 
               ppt.Por_Tasa, 
               ppt.Cod_Aplicacion, 
               ccd.Descuento, 
               ccd.Sub_Total, 
               ccd.Tipo, 
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
               ccd.Cod_UsuarioReg, 
               ccd.Fecha_Reg, 
               ccd.Cod_UsuarioAct, 
               ccd.Fecha_Act
        FROM dbo.CAJ_COMPROBANTE_D ccd
             LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ppt.Cod_Libro = '14'
                                                    AND ppt.Cod_Tasa = 'ICBPER'
                                                    AND ppt.Flag_Activo = 1
                                                    AND ccd.Id_Producto = ppt.Id_Producto
        WHERE ccd.id_ComprobantePago = @Id_ComprobantePago
              AND ccd.IGV = 0
              AND ccd.Cantidad - ccd.Formalizado > 0
        ORDER BY ccd.Descripcion;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_ActualizarTotalComandaXIdComanda @IdComprobanteComanda INT, 
                                                                           @CodUsuario           VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        UPDATE dbo.CAJ_COMPROBANTE_PAGO
          SET 
              dbo.CAJ_COMPROBANTE_PAGO.Total =
        (
            SELECT SUM(((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) + CASE
                                                                                     WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                                                                                     THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                                                                                     WHEN ppt.Cod_Aplicacion = 'MONTO'
                                                                                     THEN((ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa)
                                                                                     ELSE 0
                                                                                 END)
            FROM dbo.CAJ_COMPROBANTE_D ccd
                 LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ppt.Cod_Libro = '14'
                                                        AND ppt.Cod_Tasa = 'ICBPER'
                                                        AND ccd.Id_Producto = ppt.Id_Producto
            WHERE ccd.id_ComprobantePago = @IdComprobanteComanda
                  AND ccd.IGV = 0
        ), 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos =
        (
            SELECT SUM(CASE
                           WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                           THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                           WHEN ppt.Cod_Aplicacion = 'MONTO'
                           THEN((ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa)
                           ELSE 0
                       END)
            FROM dbo.CAJ_COMPROBANTE_D ccd
                 LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ccd.Id_Producto = ppt.Id_Producto
            WHERE ccd.id_ComprobantePago = @IdComprobanteComanda
                  AND ccd.IGV = 0
        ), 
              dbo.CAJ_COMPROBANTE_PAGO.Cod_UsuarioAct = @CodUsuario, 
              dbo.CAJ_COMPROBANTE_PAGO.Fecha_Act = GETDATE()
        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @IdComprobanteComanda;
    END;
GO
--CONDICIONES PREVIA:
--Si la mesa no tiene el flag delivery, se trae solo las mesas con su codigo
--Si tiene el flag existen dos opciones:
--Si el campo ambiente es vacio entonces esa mesa delkivery es disponible para cualqueir ambiente
--Caso contrario se respeta el ambiente al que pertenece
--EXEC dbo.USP_VIS_MESAS_ObtenerMesasXCodAmbiente 'P2'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_MESAS_ObtenerMesasXCodAmbiente'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_MESAS_ObtenerMesasXCodAmbiente;
GO
CREATE PROCEDURE USP_VIS_MESAS_ObtenerMesasXCodAmbiente @Cod_Ambiente VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               Mesas.Cod_Mesa, 
               COUNT(Ocupadas.id_ComprobantePago) Total_Ordenes, 
               MAX(Mesas.Nom_Mesa) Nom_Mesa, 
               MAX(Ocupadas.id_ComprobantePago) Id_Comanda, 
               CAST(ROUND(SUM(Ocupadas.Total), 2) AS NUMERIC(38, 2)) Total, 
               MAX(Ocupadas.Cod_UsuarioVendedor) Cod_UsuarioVendedor, 
               Mesas.Flag_Delivery
        FROM
        (
            SELECT vm.Cod_Mesa, 
                   vm.Nom_Mesa, 
                   NULL id_ComprobantePago, 
                   NULL Total, 
                   NULL Cod_UsuarioVendedor, 
                   vm.Flag_Delivery
            FROM dbo.VIS_MESAS vm
            WHERE(vm.Cod_Ambiente = @Cod_Ambiente
                  AND (vm.Flag_Delivery = 0
                       OR vm.Flag_Delivery IS NULL))
                 OR (vm.Flag_Delivery = 1
                     AND ((vm.Cod_Ambiente IS NULL
                           OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '')
                          OR (vm.Cod_Ambiente = @Cod_Ambiente)))
                 AND vm.Estado = 1
        ) Mesas
        LEFT JOIN
        (
            SELECT DISTINCT 
                   vm.Cod_Mesa, 
                   vm.Nom_Mesa, 
                   ccd.id_ComprobantePago, 
                   CAST(SUM(CASE
                                WHEN ccd.IGV = 0
                                THEN ROUND(((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) + CASE
                                                                                                         WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                                                                                                         THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                                                                                                         WHEN ppt.Cod_Aplicacion = 'MONTO'
                                                                                                         THEN(ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa
                                                                                                         ELSE 0
                                                                                                     END, 2)
                                ELSE 0
                            END) AS NUMERIC(38, 2)) Total, 
                   COALESCE(ccp.Cod_UsuarioVendedor, ccp.Cod_UsuarioAct, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor, 
                   vm.Flag_Delivery
            FROM dbo.VIS_MESAS vm
                 INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.Cod_Manguera = vm.Cod_Mesa
                 INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
                 LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ppt.Cod_Libro = '14'
                                                        AND ppt.Cod_Tasa = 'ICBPER'
                                                        AND ccd.Id_Producto = ppt.Id_Producto
            WHERE((vm.Cod_Ambiente = @Cod_Ambiente
                   AND (vm.Flag_Delivery = 0
                        OR vm.Flag_Delivery IS NULL))
                  OR (vm.Flag_Delivery = 1
                      AND ((vm.Cod_Ambiente IS NULL
                            OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '')
                           OR (vm.Cod_Ambiente = @Cod_Ambiente))))
                 AND vm.Estado = 1
                 AND vm.Estado_Mesa = 'OCUPADO'
                 AND ccp.Cod_TipoComprobante = 'CO'
                 AND ccd.Cantidad > 0
                 AND (ccd.Cantidad - ccd.Formalizado > 0
                      AND ccd.IGV = 0)
            GROUP BY vm.Cod_Mesa, 
                     vm.Nom_Mesa, 
                     ccd.id_ComprobantePago, 
                     ccp.Cod_UsuarioAct, 
                     ccp.Cod_UsuarioReg, 
                     ccp.Cod_UsuarioVendedor, 
                     vm.Flag_Delivery
        ) Ocupadas ON Mesas.Cod_Mesa = Ocupadas.Cod_Mesa
        GROUP BY Mesas.Cod_Mesa, 
                 Mesas.Flag_Delivery
        ORDER BY Mesas.Flag_Delivery DESC, 
                 Mesas.Cod_Mesa ASC;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa;
GO
CREATE PROCEDURE USP_VIS_MESAS_ObtenerDetallesMesasXCodAmbienteCodMesa @Cod_Ambiente VARCHAR(32), 
                                                                       @Cod_Mesa     VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT DISTINCT 
               vm.Cod_Mesa, 
               1 Total_Ordenes, 
               vm.Nom_Mesa, 
               ccp.id_ComprobantePago Id_Comanda, 
               CAST(SUM(CASE
                            WHEN ccd.IGV = 0
                            THEN ROUND(((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) + CASE
                                                                                                     WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                                                                                                     THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                                                                                                     WHEN ppt.Cod_Aplicacion = 'MONTO'
                                                                                                     THEN(ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa
                                                                                                     ELSE 0
                                                                                                 END, 2)
                            ELSE 0
                        END) AS NUMERIC(38, 2)) Total, 
               COALESCE(ccp.Cod_UsuarioVendedor, ccp.Cod_UsuarioAct, ccp.Cod_UsuarioReg) Cod_UsuarioVendedor, 
               vm.Flag_Delivery
        FROM dbo.VIS_MESAS vm
             INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccd.Cod_Manguera = vm.Cod_Mesa
             INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
             LEFT JOIN dbo.PRI_PRODUCTO_TASA ppt ON ppt.Cod_Libro = '14'
                                                    AND ppt.Cod_Tasa = 'ICBPER'
                                                    AND ccd.Id_Producto = ppt.Id_Producto
        WHERE((vm.Cod_Ambiente = @Cod_Ambiente
               AND (vm.Flag_Delivery = 0
                    OR vm.Flag_Delivery IS NULL))
              OR (vm.Flag_Delivery = 1
                  AND ((vm.Cod_Ambiente IS NULL
                        OR RTRIM(LTRIM(vm.Cod_Ambiente)) = '')
                       OR (vm.Cod_Ambiente = @Cod_Ambiente))))
             AND vm.Estado = 1
             AND vm.Estado_Mesa = 'OCUPADO'
             AND ccp.Cod_TipoComprobante = 'CO'
             AND ccd.Cantidad > 0
             AND ((ccp.Cod_Caja IS NULL
                   AND ccp.Cod_Turno IS NULL)
                  OR (ccd.Cantidad - ccd.Formalizado > 0
                      AND ccd.IGV = 0))
             AND vm.Cod_Mesa = @Cod_Mesa
        GROUP BY vm.Cod_Mesa, 
                 vm.Nom_Mesa, 
                 ccp.id_ComprobantePago, 
                 ccp.Cod_UsuarioReg, 
                 ccp.Cod_UsuarioVendedor, 
                 ccp.Cod_UsuarioAct, 
                 vm.Flag_Delivery
        HAVING CAST(SUM(CASE
                            WHEN ccd.IGV = 0
                            THEN ROUND(((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) + CASE
                                                                                                     WHEN ppt.Cod_Aplicacion = 'PORCENTAJE'
                                                                                                     THEN((ccd.Cantidad - ccd.Formalizado) * ccd.PrecioUnitario) * ppt.Por_Tasa / 100
                                                                                                     WHEN ppt.Cod_Aplicacion = 'MONTO'
                                                                                                     THEN(ccd.Cantidad - ccd.Formalizado) * ppt.Por_Tasa
                                                                                                     ELSE 0
                                                                                                 END, 2)
                            ELSE 0
                        END) AS NUMERIC(38, 2)) > 0
        ORDER BY vm.Cod_Mesa;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios;
GO
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_CrearClientesVarios
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT pcp.*
            FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
            WHERE pcp.Cliente = 'CLIENTES VARIOS'
                  AND pcp.Cod_TipoDocumento = '99'
                  AND pcp.Nro_Documento = '00000001'
                  AND pcp.Cod_TipoComprobante = 'BE'
        )
            BEGIN
                DECLARE @FECHA DATETIME= GETDATE();
                DECLARE @Lugar VARCHAR(MAX)=
                (
                    SELECT vd.Nom_Distrito
                    FROM dbo.VIS_DISTRITOS vd
                         INNER JOIN dbo.PRI_EMPRESA pe ON vd.Cod_Ubigeo = pe.Cod_Ubigeo
                );
                EXEC dbo.USP_PRI_CLIENTE_PROVEEDOR_G 0, '0', '00000001', 'CLIENTES VARIOS', '', '', '', @Lugar, '001', '01', '002', '', NULL, NULL, 'BE', '156', @FECHA, '01', '', '', '', '', '', '', '080101', '008', 0, 'CREADO POR SCRIPT', 0, 0, 0, '', 'SCRIPT';
        END;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision;
GO
CREATE PROCEDURE USP_Traer_GuiaRemision @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE
                WHERE Id_GuiaRemisionRemitente IN
                (
                    SELECT Id_GuiaRemision
                    FROM CAJ_COMPROBANTE_PAGO
                    WHERE Cod_Libro = '14'
                          AND id_ComprobantePago = @Id_ComprobantePago
                );
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision_D'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision_D;
GO
CREATE PROC USP_Traer_GuiaRemision_D @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE_D
                WHERE Id_GuiaRemisionRemitente IN
                (
                    SELECT Id_GuiaRemisionRemitente
                    FROM CAJ_GUIA_REMISION_REMITENTE
                    WHERE Id_GuiaRemisionRemitente IN
                    (
                        SELECT Id_GuiaRemision
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE Cod_Libro = '14'
                              AND id_ComprobantePago = @Id_ComprobantePago
                    )
                )
                ORDER BY Id_Detalle;
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE_D
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision_DatosTransportista'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision_DatosTransportista;
GO
CREATE PROC USP_Traer_GuiaRemision_DatosTransportista @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
                     INNER JOIN VIS_MODALIDAD_TRASLADO ON Cod_ModalidadTransporte = Cod_ModTraslado
                WHERE Id_GuiaRemisionRemitente IN
                (
                    SELECT Id_GuiaRemisionRemitente
                    FROM CAJ_GUIA_REMISION_REMITENTE
                    WHERE Id_GuiaRemisionRemitente IN
                    (
                        SELECT Id_GuiaRemision
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE Cod_Libro = '14'
                              AND id_ComprobantePago = @Id_ComprobantePago
                    )
                )
                ORDER BY Item;
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision_DatosVehiculo'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision_DatosVehiculo;
GO
CREATE PROC USP_Traer_GuiaRemision_DatosVehiculo @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
                WHERE Id_GuiaRemisionRemitente IN
                (
                    SELECT Id_GuiaRemisionRemitente
                    FROM CAJ_GUIA_REMISION_REMITENTE
                    WHERE Id_GuiaRemisionRemitente IN
                    (
                        SELECT Id_GuiaRemision
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE Cod_Libro = '14'
                              AND id_ComprobantePago = @Id_ComprobantePago
                    )
                )
                ORDER BY Item;
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE_VEHICULOS
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision_DXIdGuiaRemision'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision_DXIdGuiaRemision;
GO
CREATE PROC USP_Traer_GuiaRemision_DXIdGuiaRemision @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE Id_GuiaRemision = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE_D
                WHERE Id_GuiaRemisionRemitente IN(@Id_ComprobantePago)
                ORDER BY Id_Detalle;
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE_D
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_Traer_GuiaRemision_relacionados'
          AND type = 'P'
)
    DROP PROCEDURE USP_Traer_GuiaRemision_relacionados;
GO
CREATE PROC USP_Traer_GuiaRemision_relacionados @Id_ComprobantePago INT
WITH ENCRYPTION
AS
    BEGIN
        IF EXISTS
        (
            SELECT *
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @Id_ComprobantePago
                  AND (Id_GuiaRemision IS NOT NULL
                       OR Id_GuiaRemision NOT IN(''))
        )
            BEGIN
                SELECT *
                FROM CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
                WHERE Id_GuiaRemisionRemitente IN
                (
                    SELECT Id_GuiaRemisionRemitente
                    FROM CAJ_GUIA_REMISION_REMITENTE
                    WHERE Id_GuiaRemisionRemitente IN
                    (
                        SELECT Id_GuiaRemision
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE Cod_Libro = '14'
                              AND id_ComprobantePago = @Id_ComprobantePago
                    )
                )
                ORDER BY Item;
        END;
            ELSE
            SELECT *
            FROM CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS
            WHERE Id_GuiaRemisionRemitente = 0;
    END;
GO
--CAJ_COMPROBANTE_PAGO
IF EXISTS (SELECT name
	   FROM   sysobjects 
	   WHERE  name = N'UTR_CAJ_COMPROBANTE_PAGO_IUD'
	   AND 	  type = 'TR')
    DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
GO

CREATE TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
ON dbo.CAJ_COMPROBANTE_PAGO
WITH ENCRYPTION
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	--Variables de tabla primarias
	DECLARE @id_ComprobantePago int
	DECLARE @Fecha_Reg datetime
	DECLARE @Fecha_Act datetime
	DECLARE @NombreTabla varchar(max)='CAJ_COMPROBANTE_PAGO'
	--Variables de tabla secundarias
	DECLARE @Cod_Libro varchar(2)
	DECLARE @Cod_Periodo varchar(8)
	DECLARE @Cod_Caja varchar(32)
	DECLARE @Cod_Turno varchar(32)
	DECLARE @Cod_TipoOperacion varchar(5)
	DECLARE @Cod_TipoComprobante varchar(5)
	DECLARE @Serie varchar(5)
	DECLARE @Numero varchar(30)
	DECLARE @Id_Cliente int
	DECLARE @Cod_TipoDoc varchar(2)
	DECLARE @Doc_Cliente varchar(20)
	DECLARE @Nom_Cliente varchar(512)
	DECLARE @Direccion_Cliente varchar(512)
	DECLARE @FechaEmision datetime
	DECLARE @FechaVencimiento datetime
	DECLARE @FechaCancelacion datetime
	DECLARE @Glosa varchar(512)
	DECLARE @TipoCambio numeric(10,4)
	DECLARE @Flag_Anulado bit
	DECLARE @Flag_Despachado bit
	DECLARE @Cod_FormaPago varchar(5)
	DECLARE @Descuento_Total numeric(38,2)
	DECLARE @Cod_Moneda varchar(3)
	DECLARE @Impuesto numeric(38,6)
	DECLARE @Total numeric(38,2)
	DECLARE @Obs_Comprobante xml
	DECLARE @Id_GuiaRemision int
	DECLARE @GuiaRemision varchar(50)
	DECLARE @id_ComprobanteRef int
	DECLARE @Cod_Plantilla varchar(32)
	DECLARE @Nro_Ticketera varchar(64)
	DECLARE @Cod_UsuarioVendedor varchar(32)
	DECLARE @Cod_RegimenPercepcion varchar(8)
	DECLARE @Tasa_Percepcion numeric(38,2)
	DECLARE @Placa_Vehiculo varchar(64)
	DECLARE @Cod_TipoDocReferencia varchar(8)
	DECLARE @Nro_DocReferencia varchar(64)
	DECLARE @Valor_Resumen varchar(1024)
	DECLARE @Valor_Firma varchar(2048)
	DECLARE @Cod_EstadoComprobante varchar(8)
	DECLARE @MotivoAnulacion varchar(512)
	DECLARE @Otros_Cargos numeric(38,2)
	DECLARE @Otros_Tributos numeric(38,2)
	DECLARE @Cod_UsuarioReg varchar(32)
	DECLARE @Cod_UsuarioAct varchar(32)
	--Variables Generales
	DECLARE @Script varchar(max)
	DECLARE @NombreBD VARCHAR(MAX)=(SELECT DB_NAME())
	DECLARE @FechaReg datetime
	DECLARE @Accion varchar(MAX)
	DECLARE @Exportacion bit =(SELECT DISTINCT vce.Estado FROM dbo.VIS_CONFIGURACION_EXPORTACION vce)
	--Nombre del equipo|IP/Direccion Origen|Fecha/Hora Conexion yyyy-mm-dd hh:mi:ss.mmm|Nombre de usuario actual|Nombre de usuario de inicio de sesion
	DECLARE @InformacionConexion varchar(max)= (SELECT  TOP 1 CONCAT(ISNULL(HOST_NAME(),''),'|',ISNULL(dec.client_net_address,''),'|',ISNULL(CONVERT(varchar,dec.connect_time,121),''),'|',ISNULL(CURRENT_USER,''),'|',ISNULL(SYSTEM_USER,'')) 
	FROM sys.dm_exec_connections dec WHERE dec.session_id=@@SPID)
   --Acciones
	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ACTUALIZAR'
	END

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='INSERTAR'
	END

	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @Accion='ELIMINAR'
	END

	--Cursor solo para los eventos de insercion y actualizacion cuando la exportacion esta habilitada
	IF ((@Exportacion=1 AND @Accion='INSERTAR') 
	OR (@Exportacion=1 AND @Accion='ACTUALIZAR' AND 
	NOT UPDATE(Valor_Resumen) AND
	NOT UPDATE(Valor_Firma) AND
	NOT UPDATE(Cod_EstadoComprobante) AND
    NOT UPDATE(Id_Cliente)
	))
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    i.id_ComprobantePago,
		    i.Fecha_Reg,
		    i.Fecha_Act
		    FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_I '+ 
			  CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			  CASE WHEN CP.Cod_Periodo IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Periodo,'''','')+''',' END +
			  CASE WHEN CP.Cod_Caja IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Caja,'''','')+''',' END +
			  CASE WHEN CP.Cod_Turno IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Turno,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoOperacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoOperacion,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			  CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			  CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			  CASE WHEN CP.Cod_TipoDoc IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDoc,'''','')+''',' END +
			  CASE WHEN CP.Doc_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Doc_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Nom_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nom_Cliente,'''','')+''',' END +
			  CASE WHEN CP.Direccion_Cliente IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Direccion_Cliente,'''','')+''',' END +
			  CASE WHEN CP.FechaEmision IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaEmision,121)+''','END+ 
			  CASE WHEN CP.FechaVencimiento IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaVencimiento,121)+''','END+ 
			  CASE WHEN CP.FechaCancelacion IS NULL THEN 'NULL,' ELSE ''''+ CONVERT(VARCHAR(MAX),CP.FechaCancelacion,121)+''','END+ 
			  CASE WHEN CP.Glosa IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Glosa,'''','')+''',' END +
			  CASE WHEN CP.TipoCambio IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.TipoCambio)+','END+
			  CONVERT(VARCHAR(MAX),CP.Flag_Anulado)+','+ 
			  CONVERT(VARCHAR(MAX),CP.Flag_Despachado)+','+ 
			  CASE WHEN CP.Cod_FormaPago IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_FormaPago,'''','')+''',' END +
			  CASE WHEN CP.Descuento_Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Descuento_Total)+','END+
			  CASE WHEN CP.Cod_Moneda IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Moneda,'''','')+''',' END +
			  CASE WHEN CP.Impuesto IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Impuesto)+','END+
			  CASE WHEN CP.Total IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Total)+','END+
			  CASE WHEN CP.Obs_Comprobante IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CONVERT(NVARCHAR(MAX),CP.Obs_Comprobante),'''','')+''','END+
			  CASE WHEN CP.Id_GuiaRemision IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Id_GuiaRemision)+','END+
			  CASE WHEN CP.GuiaRemision IS NULL THEN 'NULL,' ELSE ''''+ REPLACE(CP.GuiaRemision,'''','')+''','END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_Libro FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.id_ComprobanteRef IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CONVERT(VARCHAR(MAX),
			  (CASE WHEN CP.id_ComprobanteRef=0  THEN '' ELSE ISNULL((SELECT TOP 1 ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=CP.id_ComprobanteRef),'') END )),'''','')+''',' END+
			  CASE WHEN CP.Cod_Plantilla IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Plantilla,'''','')+''',' END +
			  CASE WHEN CP.Nro_Ticketera IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_Ticketera,'''','')+''',' END +
			  CASE WHEN CP.Cod_UsuarioVendedor IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_UsuarioVendedor,'''','')+''',' END +
			  CASE WHEN CP.Cod_RegimenPercepcion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_RegimenPercepcion,'''','')+''',' END +
			  CASE WHEN CP.Tasa_Percepcion IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Tasa_Percepcion)+','END+
			  CASE WHEN CP.Placa_Vehiculo IS NULL THEN 'NULL,' ELSE ''''+REPLACE( CP.Placa_Vehiculo,'''','')+''',' END +
			  CASE WHEN CP.Cod_TipoDocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoDocReferencia,'''','')+''',' END +
			  CASE WHEN CP.Nro_DocReferencia IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Nro_DocReferencia,'''','')+''',' END +
			  CASE WHEN CP.Valor_Resumen IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Resumen,'''','')+''',' END +
			  CASE WHEN CP.Valor_Firma IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Valor_Firma,'''','')+''',' END +
			  CASE WHEN CP.Cod_EstadoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_EstadoComprobante,'''','')+''',' END +
			  CASE WHEN CP.MotivoAnulacion IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.MotivoAnulacion,'''','')+''',' END +
			  CASE WHEN CP.Otros_Cargos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Cargos)+','END+
			  CASE WHEN CP.Otros_Tributos IS NULL THEN 'NULL,' ELSE  CONVERT(VARCHAR(MAX),CP.Otros_Tributos)+','END+
			  ''''+REPLACE(COALESCE(CP.Cod_UsuarioAct,CP.Cod_UsuarioReg),'''','')+ ''';' 	 
			  FROM            INSERTED   CP 
			  WHERE CP.id_ComprobantePago=@id_ComprobantePago


		   	SET @FechaReg= GETDATE()
			INSERT dbo.TMP_REGISTRO_LOG
			(
			   --Id,
			   Nombre_Tabla,
			   Id_Fila,
			   Accion,
			   Script,
			   Fecha_Reg
		     )
		    VALUES
			(
			   --NULL, -- Id - uniqueidentifier
			   @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
			   @Accion, -- Accion - varchar
			   @Script, -- Script - varchar
			   @FechaReg -- Fecha_Reg - datetime
		     )
		  FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END 

    IF @Exportacion=1 AND @Accion IN ('ELIMINAR')
	BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
		    d.id_ComprobantePago,
		    d.Fecha_Reg,
		    d.Fecha_Act
		    FROM DELETED d 
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO
		    @id_ComprobantePago,
		    @Fecha_Reg,
		    @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
			--Si esta habilitada la exportacion para almacenar en la tabla de
			--exportaciones
			 SELECT @Script= 'USP_CAJ_COMPROBANTE_PAGO_D '+ 
			 CASE WHEN CP.Cod_Libro IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_Libro,'''','')+''',' END +
			 CASE WHEN CP.Cod_TipoComprobante IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Cod_TipoComprobante,'''','')+''',' END +
			 CASE WHEN CP.Serie IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Serie,'''','')+''',' END +
			 CASE WHEN CP.Numero IS NULL THEN 'NULL,' ELSE ''''+REPLACE(CP.Numero,'''','')+''',' END +	
			 ''''+'TRIGGER'+''',' +
			 ''''+'ELIMINACION SOLICITADA DESDE SERVIDOR REMOTO'+ ''';' 	 
			 FROM            DELETED  CP 
			 WHERE CP.id_ComprobantePago=@id_ComprobantePago
		   	    SET @FechaReg= GETDATE()
			    INSERT dbo.TMP_REGISTRO_LOG
			    (
				  --Id,
				  Nombre_Tabla,
				  Id_Fila,
				  Accion,
				  Script,
				  Fecha_Reg
			    )
			   VALUES
			    (
				  --NULL, -- Id - uniqueidentifier
				  @NombreTabla, -- Nombre_Tabla - varchar
				  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
				  @Accion, -- Accion - varchar
				  @Script, -- Script - varchar
				  @FechaReg -- Fecha_Reg - datetime
			    )
			 FETCH NEXT FROM cursorbd INTO
			   @id_ComprobantePago,
			   @Fecha_Reg,
			   @Fecha_Act
		    END
		    CLOSE cursorbd;
    		DEALLOCATE cursorbd
    END

    --Acciones de auditoria, especiales por tipo
    --Insercion
    IF @Accion='INSERTAR'
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 i.id_ComprobantePago,
			 i.Cod_Libro,
			 i.Cod_Periodo,
			 i.Cod_Caja,
			 i.Cod_Turno,
			 i.Cod_TipoOperacion,
			 i.Cod_TipoComprobante,
			 i.Serie,
			 i.Numero,
			 i.Id_Cliente,
			 i.Cod_TipoDoc,
			 i.Doc_Cliente,
			 i.Nom_Cliente,
			 i.Direccion_Cliente,
			 i.FechaEmision,
			 i.FechaVencimiento,
			 i.FechaCancelacion,
			 i.Glosa,
			 i.TipoCambio,
			 i.Flag_Anulado,
			 i.Flag_Despachado,
			 i.Cod_FormaPago,
			 i.Descuento_Total,
			 i.Cod_Moneda,
			 i.Impuesto,
			 i.Total,
			 i.Obs_Comprobante,
			 i.Id_GuiaRemision,
			 i.GuiaRemision,
			 i.id_ComprobanteRef,
			 i.Cod_Plantilla,
			 i.Nro_Ticketera,
			 i.Cod_UsuarioVendedor,
			 i.Cod_RegimenPercepcion,
			 i.Tasa_Percepcion,
			 i.Placa_Vehiculo,
			 i.Cod_TipoDocReferencia,
			 i.Nro_DocReferencia,
			 i.Valor_Resumen,
			 i.Valor_Firma,
			 i.Cod_EstadoComprobante,
			 i.MotivoAnulacion,
			 i.Otros_Cargos,
			 i.Otros_Tributos,
			 i.Cod_UsuarioReg,
			 i.Fecha_Reg,
			 i.Cod_UsuarioAct,
			 i.Fecha_Act
		  FROM INSERTED i
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(nvarchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			  CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

    --Actualizacion y eliminacion
    IF @Accion IN ('ACTUALIZAR','ELIMINAR')
	 BEGIN
	    DECLARE cursorbd CURSOR LOCAL FOR
		    SELECT
			 d.id_ComprobantePago,
			 d.Cod_Libro,
			 d.Cod_Periodo,
			 d.Cod_Caja,
			 d.Cod_Turno,
			 d.Cod_TipoOperacion,
			 d.Cod_TipoComprobante,
			 d.Serie,
			 d.Numero,
			 d.Id_Cliente,
			 d.Cod_TipoDoc,
			 d.Doc_Cliente,
			 d.Nom_Cliente,
			 d.Direccion_Cliente,
			 d.FechaEmision,
			 d.FechaVencimiento,
			 d.FechaCancelacion,
			 d.Glosa,
			 d.TipoCambio,
			 d.Flag_Anulado,
			 d.Flag_Despachado,
			 d.Cod_FormaPago,
			 d.Descuento_Total,
			 d.Cod_Moneda,
			 d.Impuesto,
			 d.Total,
			 d.Obs_Comprobante,
			 d.Id_GuiaRemision,
			 d.GuiaRemision,
			 d.id_ComprobanteRef,
			 d.Cod_Plantilla,
			 d.Nro_Ticketera,
			 d.Cod_UsuarioVendedor,
			 d.Cod_RegimenPercepcion,
			 d.Tasa_Percepcion,
			 d.Placa_Vehiculo,
			 d.Cod_TipoDocReferencia,
			 d.Nro_DocReferencia,
			 d.Valor_Resumen,
			 d.Valor_Firma,
			 d.Cod_EstadoComprobante,
			 d.MotivoAnulacion,
			 d.Otros_Cargos,
			 d.Otros_Tributos,
			 d.Cod_UsuarioReg,
			 d.Fecha_Reg,
			 d.Cod_UsuarioAct,
			 d.Fecha_Act
		  FROM DELETED d
	    OPEN cursorbd 
	    FETCH NEXT FROM cursorbd INTO 
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		  --Acciones
		  SET @Script = CONCAT(
			 @id_ComprobantePago,'|' ,
			 @Cod_Libro,'|' ,
			 @Cod_Periodo,'|' ,
			 @Cod_Caja,'|' ,
			 @Cod_Turno,'|' ,
			 @Cod_TipoOperacion,'|' ,
			 @Cod_TipoComprobante,'|' ,
			 @Serie,'|' ,
			 @Numero,'|' ,
			 @Id_Cliente,'|' ,
			 @Cod_TipoDoc,'|' ,
			 @Doc_Cliente,'|' ,
			 @Nom_Cliente,'|' ,
			 @Direccion_Cliente,'|' ,
			 CONVERT(varchar,@FechaEmision,121), '|' ,
			 CONVERT(varchar,@FechaVencimiento,121), '|' ,
			 CONVERT(varchar,@FechaCancelacion,121), '|' ,
			 @Glosa,'|' ,
			 @TipoCambio,'|' ,
			 @Flag_Anulado,'|' ,
			 @Flag_Despachado,'|' ,
			 @Cod_FormaPago,'|' ,
			 @Descuento_Total,'|' ,
			 @Cod_Moneda,'|' ,
			 @Impuesto,'|' ,
			 @Total,'|' ,
			 CONVERT(nvarchar(max),@Obs_Comprobante),'|' ,
			 @Id_GuiaRemision,'|' ,
			 @GuiaRemision,'|' ,
			 @id_ComprobanteRef,'|' ,
			 @Cod_Plantilla,'|' ,
			 @Nro_Ticketera,'|' ,
			 @Cod_UsuarioVendedor,'|' ,
			 @Cod_RegimenPercepcion,'|' ,
			 @Tasa_Percepcion,'|' ,
			 @Placa_Vehiculo,'|' ,
			 @Cod_TipoDocReferencia,'|' ,
			 @Nro_DocReferencia,'|' ,
			 @Valor_Resumen,'|' ,
			 @Valor_Firma,'|' ,
			 @Cod_EstadoComprobante,'|' ,
			 @MotivoAnulacion,'|' ,
			 @Otros_Cargos,'|' ,
			 @Otros_Tributos,'|' ,
			 @Cod_UsuarioReg,'|' ,
			 CONVERT(varchar,@Fecha_Reg,121), '|' ,
			 @Cod_UsuarioAct,'|' ,
			 CONVERT(varchar,@Fecha_Act,121), '|',
			 @InformacionConexion
		  )

		  INSERT PALERP_Auditoria.dbo.PRI_AUDITORIA
		  (
		      Nombre_BD,
		      Nombre_Tabla,
		      Id_Fila,
		      Accion,
		      Valor,
		      Fecha_Reg
		  )
		  VALUES
		  (
		      @NombreBD, -- Nombre_BD - varchar
		      @NombreTabla, -- Nombre_Tabla - varchar
			   CONCAT('',@id_ComprobantePago), -- Id_Fila - varchar
		      @Accion, -- Accion - varchar
		      @Script, -- Valor - varchar
		      GETDATE() -- Fecha_Reg - datetime
		  )

		  FETCH NEXT FROM cursorbd INTO
			 @id_ComprobantePago,
			 @Cod_Libro,
			 @Cod_Periodo,
			 @Cod_Caja,
			 @Cod_Turno,
			 @Cod_TipoOperacion,
			 @Cod_TipoComprobante,
			 @Serie,
			 @Numero,
			 @Id_Cliente,
			 @Cod_TipoDoc,
			 @Doc_Cliente,
			 @Nom_Cliente,
			 @Direccion_Cliente,
			 @FechaEmision,
			 @FechaVencimiento,
			 @FechaCancelacion,
			 @Glosa,
			 @TipoCambio,
			 @Flag_Anulado,
			 @Flag_Despachado,
			 @Cod_FormaPago,
			 @Descuento_Total,
			 @Cod_Moneda,
			 @Impuesto,
			 @Total,
			 @Obs_Comprobante,
			 @Id_GuiaRemision,
			 @GuiaRemision,
			 @id_ComprobanteRef,
			 @Cod_Plantilla,
			 @Nro_Ticketera,
			 @Cod_UsuarioVendedor,
			 @Cod_RegimenPercepcion,
			 @Tasa_Percepcion,
			 @Placa_Vehiculo,
			 @Cod_TipoDocReferencia,
			 @Nro_DocReferencia,
			 @Valor_Resumen,
			 @Valor_Firma,
			 @Cod_EstadoComprobante,
			 @MotivoAnulacion,
			 @Otros_Cargos,
			 @Otros_Tributos,
			 @Cod_UsuarioReg,
			 @Fecha_Reg,
			 @Cod_UsuarioAct,
			 @Fecha_Act
		END
		CLOSE cursorbd;
    	DEALLOCATE cursorbd
    END

END
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;ESTEFANI HUAMAN
-- FECHA: 16/05/2019;26/09/2019
-- OBJETIVO: Procedimiento que permite listar los segmentos de los productos SUNAT
-- EXEC USP_PRI_SUNAT_SEGMENTO_T
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUNAT_SEGMENTO_T' AND type = 'P')
DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_T
go
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_T
WITH ENCRYPTION
AS
    BEGIN
        (SELECT -1 Cod_Segmento,'SELECCIONAR' Des_Segmento)
		UNION
        (SELECT Cod_Segmento,Des_Segmento
        FROM dbo.PRI_SUNAT_SEGMENTO pss)
    END;
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;ESTEFANI HUAMAN
-- FECHA: 16/05/2019;26/09/2019
-- OBJETIVO: Procedimiento que permite listar familia de los productos SUNAT
-- EXEC USP_PRI_SUNAT_FAMILIA_T '10'
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUNAT_FAMILIA_T' AND type = 'P')
DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_T
go
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_T
@Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN 
		SELECT -1 Cod_Familia,'SELECCIONAR' Des_Familia
		UNION
        SELECT Cod_Familia,Des_Familia
        FROM dbo.PRI_SUNAT_FAMILIA pss
		WHERE Cod_Segmento=@Cod_Segmento
    END
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;ESTEFANI HUAMAN
-- FECHA: 16/05/2019;26/09/2019
-- OBJETIVO: Procedimiento que permite listar las clases de los productos SUNAT
-- EXEC USP_PRI_SUNAT_CLASE_T '1010'
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUNAT_CLASE_T' AND type = 'P')
DROP PROCEDURE USP_PRI_SUNAT_CLASE_T
go
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_T
@Cod_Familia VARCHAR(10) 
WITH ENCRYPTION
AS
    BEGIN
        SELECT -1  Cod_Clase,'SELECCIONAR' Des_Clase 
		UNION
		SELECT Cod_Clase,Des_Clase
        FROM dbo.PRI_SUNAT_CLASE pss
		WHERE Cod_Familia=@Cod_Familia
    END
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;ESTEFANI HUAMAN
-- FECHA: 16/05/2019;26/09/2019
-- OBJETIVO: Procedimiento que permite listar los productos con sus repectivos codigos de SUNAT
-- EXEC USP_PRI_SUNAT_COD_PRODUCTO_T null,null,null,'placa'
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_SUNAT_COD_PRODUCTO_T' AND type = 'P')
DROP PROCEDURE USP_PRI_SUNAT_COD_PRODUCTO_T
go
CREATE PROCEDURE USP_PRI_SUNAT_COD_PRODUCTO_T
@Cod_Segmento VARCHAR(10) = NULL,
@Cod_Familia VARCHAR(10)= NULL ,
@Cod_Clase VARCHAR(10) = NULL,
@Des_Producto varchar(512)
WITH ENCRYPTION
AS
BEGIN  
		select Cod_Producto,Des_Producto  from PRI_SUNAT_PRODUCTOS
		where (Cod_Familia = @Cod_Familia OR @Cod_Familia IS NULL)
		AND (Cod_Segmento = @Cod_Segmento OR @Cod_Segmento IS NULL)
		AND (Cod_Clase = @Cod_Clase OR @Cod_Clase IS NULL)
		AND Des_Producto LIKE '%'+@Des_Producto+'%'
END
GO 
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN
-- FECHA: 26/09/2019
-- OBJETIVO: Procedimiento que permite listar los productos con sus repectivos codigos de SUNAT
-- EXEC USP_PRI_PRODUCTOS_CODIGO_SUNAT  '50313457' 
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_CODIGO_SUNAT' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_CODIGO_SUNAT
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_CODIGO_SUNAT
@Cod_Producto varchar(64)
AS
BEGIN
	SELECT Cod_Producto+' - '+Des_Producto
    FROM dbo.PRI_SUNAT_PRODUCTOS pss
	WHERE Cod_Producto=@Cod_Producto
END
GO
--------------------------------------------------------------------------------------------------------------
-- AUTOR: ERWIN M. RAYME CHAMBI
-- CREACION: 07/08/2019
-- OBJETIVOS: Verifica la cantidad de elementos de las tablas PRI_SUNAT_SEGMENTO,PRI_SUNAT_FAMILIA,PRI_SUNAT_CLASE,
-- PRI_SUNAT_PRODUCTOS, si la cantidad de elemntos de cualquiera de ellos no coincide, elimina todos los elementos 
-- de las tablas y los vuelve a insertar ejecutando el archivo especificado en la ruta(*)
-- (*)La ruta no debe contener espacios
--------------------------------------------------------------------------------------------------------------
--EXEC dbo.USP_VerificarTablasProductoSUNAT
--	@NroSegmentos = 1000,
--	@NroFamilias = 1000,
--	@NroClases = 1000,
--	@NroProductos = 1000,
--	@RutaArchivoScript = 'G:\Productos_Sunat-Productos.sql'
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VerificarTablasProductoSUNAT'
          AND type = 'P'
)
    DROP PROCEDURE USP_VerificarTablasProductoSUNAT;
GO
CREATE PROCEDURE USP_VerificarTablasProductoSUNAT @NroSegmentos INT, 
                                                  @NroFamilias  INT, 
                                                  @NroClases    INT, 
                                                  @NroProductos INT, 
                                                  @RutaArchivoScript   VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        --Ejecutamos los scripts previamente
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_SEGMENTO''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_SEGMENTO
        (Cod_Segmento   VARCHAR(5)
         PRIMARY KEY, 
         Des_Segmento   VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_FAMILIA''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_FAMILIA
        (Cod_Familia    VARCHAR(10)
         PRIMARY KEY, 
         Cod_Segmento   VARCHAR(5) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_SEGMENTO(Cod_Segmento) NOT NULL, 
         Des_Familia    VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_CLASE''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_CLASE
        (Cod_Clase      VARCHAR(20)
         PRIMARY KEY, 
         Cod_Familia    VARCHAR(10) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_FAMILIA(Cod_Familia) NOT NULL, 
         Des_Clase      VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N''PRI_SUNAT_PRODUCTOS''
          AND type = ''U''
)
    BEGIN
        CREATE TABLE PRI_SUNAT_PRODUCTOS
        (Cod_Producto   VARCHAR(32)
         PRIMARY KEY, 
         Cod_Segmento   VARCHAR(5) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_SEGMENTO(Cod_Segmento) NOT NULL, 
         Cod_Familia    VARCHAR(10) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_FAMILIA(Cod_Familia) NOT NULL, 
         Cod_Clase      VARCHAR(20) FOREIGN KEY REFERENCES dbo.PRI_SUNAT_CLASE(Cod_Clase) NOT NULL, 
         Des_Producto   VARCHAR(MAX) NOT NULL, 
         Estado         BIT NOT NULL, 
         Cod_UsuarioReg VARCHAR(32) NOT NULL, 
         Fecha_Reg      DATETIME NOT NULL, 
         Cod_UsuarioAct VARCHAR(32), 
         Fecha_Act      DATETIME
        );
END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_G @Cod_Segmento VARCHAR(5), 
                                          @Des_Segmento VARCHAR(MAX), 
                                          @Estado       BIT, 
                                          @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT pss.*
            FROM dbo.PRI_SUNAT_SEGMENTO pss
            WHERE pss.Cod_Segmento = @Cod_Segmento
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_SEGMENTO
                VALUES
                (@Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Des_Segmento, -- Des_Segmento - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_SEGMENTO
                  SET 
                      dbo.PRI_SUNAT_SEGMENTO.Des_Segmento = @Des_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_SEGMENTO.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_SEGMENTO.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_SEGMENTO.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_SEGMENTO.Cod_Segmento = @Cod_Segmento;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_E @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_SEGMENTO
        WHERE dbo.PRI_SUNAT_SEGMENTO.Cod_Segmento = @Cod_Segmento;
	END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.*
        FROM dbo.PRI_SUNAT_SEGMENTO pss;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TXPK @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.*
        FROM dbo.PRI_SUNAT_SEGMENTO pss
        WHERE pss.Cod_Segmento = @Cod_Segmento;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria @Cod_Segmento VARCHAR(5)
WITH ENCRYPTION
AS
    BEGIN
        SELECT pss.Cod_UsuarioReg, 
               pss.Fecha_Reg, 
               pss.Cod_UsuarioAct, 
               pss.Fecha_Act
        FROM dbo.PRI_SUNAT_SEGMENTO pss
        WHERE pss.Cod_Segmento = @Cod_Segmento;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_SEGMENTO ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_TP @TamañoPagina VARCHAR(16), 
                                           @NumeroPagina VARCHAR(16), 
                                           @ScripOrden   VARCHAR(MAX) = NULL, 
                                           @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Segmento,Des_Segmento,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act 
			FROM (SELECT TOP 100 PERCENT Cod_Segmento,Des_Segmento,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_SEGMENTO '' + @ScripWhere + '') aPRI_SUNAT_SEGMENTO
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_G @Cod_Familia  VARCHAR(10), 
                                         @Cod_Segmento VARCHAR(5), 
                                         @Des_Familia  VARCHAR(MAX), 
                                         @Estado       BIT, 
                                         @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psf.*
            FROM dbo.PRI_SUNAT_FAMILIA psf
            WHERE  psf.Cod_Familia = @Cod_Familia
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_FAMILIA
                VALUES
                (@Cod_Familia, -- Cod_Familia - VARCHAR
                 @Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Des_Familia, -- Des_Familia - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_FAMILIA
                  SET 
                      dbo.PRI_SUNAT_FAMILIA.Cod_Segmento = @Cod_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Des_Familia = @Des_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_FAMILIA.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_FAMILIA.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_FAMILIA.Cod_Familia = @Cod_Familia;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_E @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_FAMILIA
        WHERE dbo.PRI_SUNAT_FAMILIA.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.*
        FROM dbo.PRI_SUNAT_FAMILIA psf;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TXPK @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.*
        FROM dbo.PRI_SUNAT_FAMILIA psf
        WHERE psf.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_SEGMENTO_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_SEGMENTO_Auditoria @Cod_Familia VARCHAR(10)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psf.Cod_UsuarioReg, 
               psf.Fecha_Reg, 
               psf.Cod_UsuarioAct, 
               psf.Fecha_Act
        FROM dbo.PRI_SUNAT_FAMILIA psf
        WHERE psf.Cod_Familia = @Cod_Familia;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_FAMILIA ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_FAMILIA_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_FAMILIA_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_FAMILIA_TP @TamañoPagina VARCHAR(16), 
                                          @NumeroPagina VARCHAR(16), 
                                          @ScripOrden   VARCHAR(MAX) = NULL, 
                                          @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Familia,Cod_Segmento,Des_Familia,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Familia,Cod_Segmento,Des_Familia,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_FAMILIA '' + @ScripWhere + '') aPRI_SUNAT_FAMILIA
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_G @Cod_Clase   VARCHAR(20), 
                                           @Cod_Familia VARCHAR(10), 
                                           @Des_Clase   VARCHAR(MAX), 
                                           @Estado      BIT, 
                                           @Cod_Usuario VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psc.*
            FROM dbo.PRI_SUNAT_CLASE psc
            WHERE psc.Cod_Clase = @Cod_Clase
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_CLASE
                VALUES
                (@Cod_Clase, -- Cod_Clase - VARCHAR
                 @Cod_Familia, -- Cod_Familia - VARCHAR
                 @Des_Clase, -- Des_Clase - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_CLASE
                  SET 
                      dbo.PRI_SUNAT_CLASE.Cod_Familia = @Cod_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Des_Clase = @Des_Clase, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_CLASE.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_CLASE.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_CLASE.Cod_Clase = @Cod_Clase;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_E @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_CLASE
        WHERE dbo.PRI_SUNAT_CLASE.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.*
        FROM dbo.PRI_SUNAT_CLASE psc;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TXPK @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.*
        FROM dbo.PRI_SUNAT_CLASE psc
        WHERE psc.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_Auditoria @Cod_Clase VARCHAR(20)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psc.Cod_UsuarioReg, 
               psc.Fecha_Reg, 
               psc.Cod_UsuarioAct, 
               psc.Fecha_Act
        FROM dbo.PRI_SUNAT_CLASE psc
        WHERE psc.Cod_Clase = @Cod_Clase;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_CLASE ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_CLASE_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_CLASE_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_CLASE_TP @TamañoPagina VARCHAR(16), 
                                        @NumeroPagina VARCHAR(16), 
                                        @ScripOrden   VARCHAR(MAX) = NULL, 
                                        @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Clase,Cod_Familia,Des_Clase,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Clase,Cod_Familia,Des_Clase,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_CLASE '' + @ScripWhere + '') aPRI_SUNAT_CLASE
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_G''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_G;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_G @Cod_Producto VARCHAR(32), 
                                               @Cod_Segmento VARCHAR(5), 
                                               @Cod_Familia  VARCHAR(10), 
                                               @Cod_Clase    VARCHAR(20), 
                                               @Des_Producto VARCHAR(MAX), 
                                               @Estado       BIT, 
                                               @Cod_Usuario  VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF NOT EXISTS
        (
            SELECT psp.*
            FROM dbo.PRI_SUNAT_PRODUCTOS psp
            WHERE psp.Cod_Producto = @Cod_Producto
        )
            BEGIN
                INSERT INTO dbo.PRI_SUNAT_PRODUCTOS
                VALUES
                (@Cod_Producto, -- Cod_Producto - VARCHAR
                 @Cod_Segmento, -- Cod_Segmento - VARCHAR
                 @Cod_Familia, -- Cod_Familia - VARCHAR
                 @Cod_Clase, -- Cod_Clase - VARCHAR
                 @Des_Producto, -- Des_Producto - VARCHAR
                 @Estado, -- Estado - BIT
                 @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                 GETDATE(), -- Fecha_Reg - DATETIME
                 NULL, -- Cod_UsuarioAct - VARCHAR
                 NULL -- Fecha_Act - DATETIME
                );
        END;
            ELSE
            BEGIN
                UPDATE dbo.PRI_SUNAT_PRODUCTOS
                  SET 
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Segmento = @Cod_Segmento, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Familia = @Cod_Familia, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_Clase = @Cod_Clase, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Des_Producto = @Des_Producto, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Estado = @Estado, -- BIT
                      dbo.PRI_SUNAT_PRODUCTOS.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                      dbo.PRI_SUNAT_PRODUCTOS.Fecha_Act = GETDATE() -- DATETIME
                WHERE dbo.PRI_SUNAT_PRODUCTOS.Cod_Producto = @Cod_Producto;
        END;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_E''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_E;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_E @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.PRI_SUNAT_PRODUCTOS
        WHERE dbo.PRI_SUNAT_PRODUCTOS.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TT''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TT;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.*
        FROM dbo.PRI_SUNAT_PRODUCTOS psp;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TXPK''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TXPK;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TXPK @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.*
        FROM dbo.PRI_SUNAT_PRODUCTOS psp
        WHERE psp.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_Auditoria''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_Auditoria;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_Auditoria @Cod_Producto VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SELECT psp.Cod_UsuarioReg, 
               psp.Fecha_Reg, 
               psp.Cod_UsuarioAct, 
               psp.Fecha_Act
        FROM dbo.PRI_SUNAT_PRODUCTOS psp
        WHERE psp.Cod_Producto = @Cod_Producto;
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TNF''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TNF;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE (''SELECT COUNT(*) AS Nro_Filas FROM PRI_SUNAT_PRODUCTOS ''+@ScripWhere);
    END;
');
        EXEC ('
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N''USP_PRI_SUNAT_PRODUCTOS_TP''
          AND type = ''P''
)
    DROP PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TP;
');
        EXEC ('
CREATE PROCEDURE USP_PRI_SUNAT_PRODUCTOS_TP @TamañoPagina VARCHAR(16), 
                                            @NumeroPagina VARCHAR(16), 
                                            @ScripOrden   VARCHAR(MAX) = NULL, 
                                            @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = ''SELECT NumeroFila,Cod_Producto,Cod_Segmento,Cod_Familia,Cod_Clase,Des_Producto,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act
			FROM (SELECT TOP 100 PERCENT Cod_Producto,Cod_Segmento,Cod_Familia,Cod_Clase,Des_Producto,Estado,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER ('' + @ScripOrden + '') AS NumeroFila
			FROM PRI_SUNAT_PRODUCTOS '' + @ScripWhere + '') aPRI_SUNAT_PRODUCTOS
			WHERE NumeroFila BETWEEN ('' + @TamañoPagina + '' * '' + @NumeroPagina + '')+1 AND '' + @TamañoPagina + '' * ('' + @NumeroPagina + '' + 1)'';
        EXECUTE (@ScripSQL);
    END;
');
        IF @NroSegmentos <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_SEGMENTO pss
        )
           OR @NroFamilias <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_FAMILIA psf
        )
           OR @NroClases <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_CLASE psc
        )
           OR @NroProductos <>
        (
            SELECT COUNT(*)
            FROM dbo.PRI_SUNAT_PRODUCTOS psp
        )
            BEGIN
                --Borramos el contenido previamente almacenado
                DELETE dbo.PRI_SUNAT_PRODUCTOS;
                DELETE dbo.PRI_SUNAT_CLASE;
                DELETE dbo.PRI_SUNAT_FAMILIA;
                DELETE dbo.PRI_SUNAT_SEGMENTO;
                --Ejecutamos el script de productos de acuerdo a la ruta 
                DECLARE @NombreBD VARCHAR(MAX)=
                (
                    SELECT DB_NAME()
                );
                EXEC ('master..xp_cmdshell  ''Sqlcmd -S .\PALEHOST -d '+@NombreBD+' -i  '+@RutaArchivoScript+'''');
        END;
    END;
GO

--------------------------------------------------------------------------------------------------------------
-- AUTOR: ESTEFANI HUAMAN;
-- FECHA: 10/06/2019;
-- OBJETIVO: Procedimiento que permite listar tipos de productos 
-- EXEC USP_PRI_TRAER_PRODUCTOSXTipo
--------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_TRAER_PRODUCTOSXTipo' AND type = 'P')
DROP PROCEDURE USP_PRI_TRAER_PRODUCTOSXTipo
go 
CREATE  PROCEDURE USP_PRI_TRAER_PRODUCTOSXTipo 
AS
BEGIN
	SELECT DISTINCT [Cod_TipoProducto]
	FROM PRI_PRODUCTOS 
	--where [Cod_TipoProducto]='PRO'
END
GO