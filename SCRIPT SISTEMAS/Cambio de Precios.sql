
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