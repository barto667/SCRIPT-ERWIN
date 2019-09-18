--SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,CASE when PP.Cod_TipoPrecio IS NULL then NULL else PP.Cod_TipoPrecio  end as Cod_TipoPrecio,
--					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
--					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
--FROM            PRI_PRODUCTOS AS P INNER JOIN
--                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
--                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
--                         VIS_PRECIOS AS VP 
--WHERE        (VS.Serie = '356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01'

--VERSION ESTABLE con duplicados pero diferenciables
--SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,
--					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
--					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
--FROM            PRI_PRODUCTOS AS P INNER JOIN
--                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
--                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
--                         VIS_PRECIOS AS VP 
--WHERE        (VS.Serie LIKE '%'+'356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01' 
--order by VP.Cod_Precio

SELECT   DISTINCT     P.Id_Producto, P.Cod_Producto, VS.Serie, P.Des_CortaProducto,P.Nom_Producto,
					  case when PP.Cod_TipoPrecio!=VP.Cod_Precio then NULL else PP.Valor end as Valor,
					  VP.Cod_Precio,VP.Nom_Precio, VP.Cod_PrecioPadre
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto CROSS JOIN
                         VIS_PRECIOS AS VP 
WHERE        (VS.Serie LIKE '%'+'356656075499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006') and PP.Id_Producto=P.Id_Producto and VP.Cod_Categoria='01' 
--order by VP.Cod_Precio
--and VP.Cod_Precio='CPA8�'
--and VP.Cod_Precio='1'
--and PP.Cod_TipoPrecio=VP.Cod_Precio
--select * from PRI_CATEGORIA
--select * from VIS_PRECIOS
--select * from PRI_PRODUCTOS where Id_Producto=92
--select * from VIS_PRECIOS where Cod_Precio='CPRAA' 
--select * from PRI_PRODUCTO_PRECIO as PP inner join VIS_PRECIOS as VP on PP.Cod_TipoPrecio=VP.Cod_Precio  where Id_Producto=92 and Cod_Almacen='A0006' order by Cod_TipoPrecio
SELECT        VS.Serie, VS.Cod_Producto, VS.Des_Producto, VS.Des_Almacen, VS.Stock, VS.Estado, PP.Id_Producto, PP.Cod_UnidadMedida, PP.Cod_Almacen, PP.Cod_TipoPrecio, PP.Valor, P.Id_Producto AS Expr1, 
                         P.Cod_Producto AS Expr2, P.Cod_Marca, P.Des_CortaProducto, P.Nom_Producto, P.Des_LargaProducto, P.Cod_TipoProducto, P.Cod_Categoria, VIS_PRECIOS.Nom_Precio, VIS_PRECIOS.Estado AS Expr3, 
                         VP.Orden
FROM            VIS_SERIES AS VS INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON VS.Id_Producto = PP.Id_Producto INNER JOIN
                         PRI_PRODUCTOS AS P ON VS.Id_Producto = P.Id_Producto INNER JOIN
                         VIS_PRECIOS as VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
WHERE        (VS.Serie LIKE '%' + '75499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006')
select * from VIS_PRECIOS
select * from PRI_PRODUCTO_PRECIO
select * from PRI_PRODUCTOS
select * from VIS_SERIES 

SELECT        PP.Cod_TipoPrecio, VS.Cod_Producto, P.Id_Producto, PP.Valor, PP.Cod_Almacen, PP.Cod_UnidadMedida, PP.Id_Producto AS Expr1, VP.Nom_Precio, VP.Cod_Precio, VS.Serie, VS.Des_Almacen, 
                         P.Des_CortaProducto, P.Des_LargaProducto, P.Nom_Producto
FROM            PRI_PRODUCTOS AS P INNER JOIN
                         VIS_SERIES AS VS ON P.Id_Producto = VS.Id_Producto AND P.Cod_Producto = VS.Cod_Producto INNER JOIN
                         PRI_PRODUCTO_PRECIO AS PP ON P.Id_Producto = PP.Id_Producto INNER JOIN
                         VIS_PRECIOS AS VP ON PP.Cod_TipoPrecio = VP.Cod_Precio
where (VS.Serie LIKE '%' + '75499987') AND (VP.Estado = 1) AND (VS.Stock = 1) AND (PP.Cod_Almacen = 'A0006')



IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_MovimientosCajaTurno'
          AND type = 'P'
)
    DROP PROCEDURE USP_MovimientosCajaTurno;
GO
CREATE PROCEDURE USP_MovimientosCajaTurno @Cod_Caja AS     VARCHAR(32), 
                                          @Cod_Turno AS    VARCHAR(32), 
                                          @Flag_Resumen AS BIT         = 0
WITH ENCRYPTION
AS
    BEGIN
        SET DATEFORMAT DMY;
        -- SELECIONAR LAS VISTAS PREVIAS

        SELECT Nro, 
               Cod_EstadoComprobante, 
               Nom_EstadoComprobante, 
               Estado
        INTO [#VIS_ESTADO_COMPROBANTE]
        FROM VIS_ESTADO_COMPROBANTE;
        SELECT Nro, 
               Cod_Moneda, 
               Nom_Moneda, 
               Simbolo, 
               Definicion, 
               Estado
        INTO [#VIS_MONEDAS]
        FROM VIS_MONEDAS;
        SELECT 'CAJ_CAJA_MOVIMIENTOS' AS Entidad, 
               M.id_Movimiento AS ID, 
               M.Cod_TipoComprobante + ':' + M.Serie + '-' + CONVERT(VARCHAR, CONVERT(INT, M.Numero)) AS Documento,
               CASE Flag_Extornado
                   WHEN 0
                   THEN Cliente
                   ELSE 'ANULADO'
               END AS Cliente,
               CASE
                   WHEN Flag_Extornado = 1
                   THEN 'ANULADO'
                   WHEN Cod_UsuarioAut IS NULL
                   THEN 'REQUIERE DE AUTORIZACION'
                   ELSE Des_Movimiento
               END AS Movimiento, 
               M.Fecha_Reg, 
               1 AS Cantidad,
               CASE
                   WHEN Flag_Extornado = 0
                   THEN 0
                   WHEN Ingreso <> 0
                        AND Cod_UsuarioAut IS NOT NULL
                   THEN Ingreso
                   ELSE Egreso
               END AS PrecioUnitario, 
               0 ICBPER,
               CASE
                   WHEN Flag_Extornado = 0
                   THEN 0
                   WHEN Ingreso <> 0
                        AND Cod_UsuarioAut IS NOT NULL
                   THEN Ingreso
                   ELSE Egreso
               END AS Sub_Total, 
               '' AS Cod_Manguera, 
               0 AS id_Detalle, 
               M.Fecha AS FechaEmision, 
               '' AS OBS, --Point.Registro.value('OBS_MOVIMIENTO[1]', 'VARCHAR(64)') AS OBS, 
               VMI.Simbolo AS SimboloIng, 
               M.Ingreso, 
               VME.Simbolo AS SimboloEgr, 
               M.Egreso, 
               0.00 AS Pago, 
               0.00 AS Saldo, 
               1 AS Pagado, 
               0.00 AS Descuento, 
               '' AS Banco, 
               '' AS Operacion, 
               M.Cod_UsuarioReg, 
               'EFECTIVO' AS PagoCon, 
               1 AS Despachado, 
               '' AS Estado
        FROM CAJ_CAJA_MOVIMIENTOS AS M
             INNER JOIN #VIS_MONEDAS AS VMI ON M.Cod_MonedaIng = VMI.Cod_Moneda
             INNER JOIN #VIS_MONEDAS AS VME ON M.Cod_MonedaEgr = VME.Cod_Moneda
        --CROSS APPLY Obs_Movimiento.nodes('/Registro') AS Point(Registro) 
        WHERE Cod_Caja = @Cod_Caja
              AND Cod_Turno = @Cod_Turno --AND Cod_UsuarioAut is not null 
              AND Id_Concepto NOT IN(7101, 7102, 7100)
        UNION -- comprobantes pagados en su totalidad
        SELECT DISTINCT 
               'CAJ_COMPROBANTE_PAGO' AS Entidad, 
               CP.id_ComprobantePago AS ID, 
               CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CONVERT(VARCHAR, CONVERT(INT, CP.Numero)) AS Documento,
               CASE CP.Flag_Anulado
                   WHEN 0
                   THEN CP.Nom_Cliente
                   ELSE 'ANULADO'
               END AS Cliente,
               CASE
                   WHEN CP.Flag_Anulado = 1
                        AND cp.id_ComprobanteRef <> 0
                   THEN CP.Glosa
                   ELSE D.Descripcion
               END AS Movimiento, 
               CP.Fecha_Reg, 
               D.Cantidad, 
               D.PrecioUnitario, 
               dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14') ICBPER, 
               D.Sub_Total + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14') Sub_Total, 
               ISNULL(D.Cod_Manguera, '') AS Cod_Manguera, 
               D.id_Detalle, 
               CP.FechaEmision, 
               Point.Registro.value('NRO_VALE[1]', 'VARCHAR(32)') AS OBS, 
               VM.Simbolo AS SimboloIng, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '08'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0) + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14')
                     END, 2) AS Ingreso, 
               VM.Simbolo AS SimboloEgr, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '14'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0) + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14')
                     END, 2) AS Egreso, 
               D.Sub_Total AS Pago, 
               0.00 AS Saldo, 
               1 AS Pagado,
               CASE D.Cantidad
                   WHEN 0
                   THEN 0
                   ELSE 100 * (D.Descuento / D.Cantidad)
               END AS Descuento, 
               '', 
               '', 
               CP.Cod_UsuarioReg,
               CASE
                   WHEN F.Id_Movimiento IS NULL
                   THEN 'SERAFIN'
                   ELSE F.Des_FormaPago + ' ' + ISNULL(F.Cuenta_CajaBanco, '')
               END AS PagoCon, 
               CP.Flag_Despachado, 
               VC.Nom_EstadoComprobante
        FROM CAJ_COMPROBANTE_D AS D
             RIGHT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN #VIS_ESTADO_COMPROBANTE VC ON cp.Cod_EstadoComprobante = vc.Cod_EstadoComprobante
             INNER JOIN #VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
             LEFT OUTER JOIN CAJ_FORMA_PAGO AS F ON CP.id_ComprobantePago = F.id_ComprobantePago ON D.id_ComprobantePago = CP.id_ComprobantePago
             CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro)
        WHERE(CP.Cod_Caja = @Cod_Caja)
             AND (CP.Cod_Turno = @Cod_Turno)
             AND (Cod_FormaPago <> '999')
             AND (@Flag_Resumen = 0)
        --UNION -- resumen por ventas al efectivo
        --	SELECT DISTINCT 
        --		'CAJ_COMPROBANTE_PAGO' AS Entidad, CP.id_ComprobantePago AS ID, CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CONVERT(varchar, CONVERT(int, 
        --		CP.Numero)) AS Documento, CASE CP.Flag_Anulado WHEN 0 THEN CP.Nom_Cliente ELSE 'ANULADO' END AS Cliente, CASE WHEN CP.Flag_Anulado = 1 AND 
        --		cp.id_ComprobanteRef <> 0 THEN CP.Glosa ELSE dbo.UFN_CAJ_COMPROBANTE_D_Detalle(CP.id_ComprobantePago) END AS Movimiento, CP.Fecha_Reg, 
        --		CP.Total - CP.Impuesto, CP.Impuesto, CP.Total, 
        --		'' AS Cod_Manguera,0, CP.FechaEmision, Point.Registro.value('NRO_VALE[1]', 'VARCHAR(32)') AS OBS, 
        --		VM.Simbolo AS SimboloIng, ROUND(CASE WHEN CP.Cod_Libro = '08' THEN 0 ELSE ISNULL(CP.Total, 0) END, 2) AS Ingreso, VM.Simbolo AS SimboloEgr, 
        --		ROUND(CASE WHEN CP.Cod_Libro = '14' THEN 0 ELSE ISNULL(CP.Total, 0) END, 2) AS Egreso, CP.Total AS Pago, 0.00 AS Saldo, 1 AS Pagado, 
        --		cp.Descuento_Total,'','', CP.Cod_UsuarioReg, 
        --		CASE WHEN F.Id_Movimiento IS NULL THEN 'SERAFIN' ELSE F.Des_FormaPago + ' ' + F.Cuenta_CajaBanco END AS PagoCon, CP.Flag_Despachado
        --	FROM    CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
        --		VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda LEFT OUTER JOIN
        --		CAJ_FORMA_PAGO AS F ON CP.id_ComprobantePago = F.id_ComprobantePago
        --	CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro) 
        --	WHERE   (CP.Cod_Caja = @Cod_Caja ) AND (CP.Cod_Turno = @Cod_Turno) AND (Cod_FormaPago <> '999') AND (@Flag_Resumen = 1)
        UNION -- comprobantes al credito
        SELECT DISTINCT 
               'CAJ_COMPROBANTE_PAGO' AS Entidad, 
               CP.id_ComprobantePago AS ID, 
               CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CONVERT(VARCHAR, CONVERT(BIGINT, CP.Numero)) AS Documento,
               CASE
                   WHEN CP.Flag_Anulado = 0
                        OR CP.id_ComprobanteRef <> 0
                   THEN CP.Nom_Cliente
                   ELSE 'ANULADO'
               END AS Cliente,
               CASE
                   WHEN CP.Flag_Anulado = 1
                        AND cp.id_ComprobanteRef <> 0
                   THEN CP.Glosa
                   ELSE D.Descripcion
               END AS Movimiento, 
               CP.Fecha_Reg, 
               D.Cantidad, 
               D.PrecioUnitario, 
               dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14') ICBPER, 
               D.Sub_Total + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14') Sub_Total, 
               ISNULL(D.Cod_Manguera, '') AS Cod_Manguera, 
               D.id_Detalle, 
               CP.FechaEmision, 
               Point.Registro.value('NRO_VALE[1]', 'VARCHAR(32)') AS OBS, 
               VM.Simbolo AS SimboloIng, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '08'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0) + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14')
                     END, 2) AS Ingreso, 
               VM.Simbolo AS SimboloEgr, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '14'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0) + dbo.UFN_CAJ_COMPROBANTE_D_TraerTasasXIdDetalleCodTasaCodLibro(CP.id_ComprobantePago, D.Id_Detalle, 'ICBPER', '14')
                     END, 2) AS Egreso, 
               F.Monto, 
               dbo.UFN_CAJ_COMPROBANTE_PAGO_Saldo(CP.id_ComprobantePago) AS Expr1,
               CASE
                   WHEN dbo.UFN_CAJ_COMPROBANTE_PAGO_Saldo(CP.id_ComprobantePago) = 0
                   THEN 1
                   WHEN F.Monto IS NULL
                        OR F.Monto = 0
                   THEN 2
                   ELSE 3
               END AS Pagado,
               CASE D.Cantidad
                   WHEN 0
                   THEN 0
                   ELSE 100 * (D.Descuento / D.Cantidad)
               END AS Descuento, 
               '', 
               '', 
               CP.Cod_UsuarioReg,
               CASE
                   WHEN F.Id_Movimiento IS NULL
                   THEN 'CREDITO'
                   ELSE f.Des_FormaPago + ' ' + f.Cuenta_CajaBanco
               END AS PagoCon, 
               CP.Flag_Despachado, 
               VC.Nom_EstadoComprobante
        FROM CAJ_COMPROBANTE_D AS D
             RIGHT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN #VIS_ESTADO_COMPROBANTE VC ON cp.Cod_EstadoComprobante = vc.Cod_EstadoComprobante
             INNER JOIN #VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
             LEFT OUTER JOIN CAJ_FORMA_PAGO AS F ON CP.id_ComprobantePago = F.id_ComprobantePago ON D.id_ComprobantePago = CP.id_ComprobantePago
             CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro)
        WHERE(CP.Cod_Caja = @Cod_Caja)
             AND (CP.Cod_Turno = @Cod_Turno)
             AND Cod_FormaPago = '999'
        UNION
        SELECT 'CAJ_FORMA_PAGO' AS Entidad, 
               F.id_ComprobantePago AS ID, 
               CP.Cod_TipoComprobante + ':' + CP.Serie + '-' + CONVERT(VARCHAR, CONVERT(BIGINT, CP.Numero)) AS Documento,
               CASE CP.Flag_Anulado
                   WHEN 0
                   THEN CP.Nom_Cliente
                   ELSE 'ANULADO'
               END AS Cliente,
               CASE
                   WHEN CP.Flag_Anulado = 1
                        AND cp.id_ComprobanteRef <> 0
                   THEN CP.Glosa
                   ELSE D.Descripcion
               END AS Movimiento, 
               F.Fecha_Reg, 
               D.Cantidad, 
               D.PrecioUnitario, 
               0 ICBPER, 
               D.Sub_Total, 
               ISNULL(D.Cod_Manguera, '') AS Cod_Manguera, 
               D.id_Detalle, 
               CP.FechaEmision, 
               Point.Registro.value('OBS_COMPROBANTE[1]', 'VARCHAR(64)') + ', ' + D.Obs_ComprobanteD AS OBS, 
               VM.Simbolo AS SimboloIng, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '08'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0)
                     END, 2) AS Ingreso, 
               VM.Simbolo AS SimboloEgr, 
               ROUND(CASE
                         WHEN CP.Cod_Libro = '14'
                         THEN 0
                         ELSE ISNULL(D.Sub_Total, 0)
                     END, 2) AS Egreso, 
               F.Monto, 
               dbo.UFN_CAJ_COMPROBANTE_PAGO_Saldo(CP.id_ComprobantePago) AS Expr1,
               CASE
                   WHEN dbo.UFN_CAJ_COMPROBANTE_PAGO_Saldo(CP.id_ComprobantePago) = 0
                   THEN 1
                   WHEN F.Monto IS NULL
                        OR F.Monto = 0
                   THEN 2
                   ELSE 3
               END AS Pagado,
               CASE D.Cantidad
                   WHEN 0
                   THEN 0
                   ELSE 100 * (D.Descuento / D.Cantidad)
               END AS Descuento, 
               B.Des_CuentaBancaria AS Banco, 
               M.Nro_Operacion AS Operacion, 
               CP.Cod_UsuarioReg, 
               F.Des_FormaPago + ' ' + F.Cuenta_CajaBanco AS PagoCon, 
               CP.Flag_Despachado, 
               VC.Nom_EstadoComprobante
        FROM CAJ_COMPROBANTE_D AS D
             RIGHT OUTER JOIN CAJ_COMPROBANTE_PAGO AS CP
             INNER JOIN #VIS_ESTADO_COMPROBANTE VC ON cp.Cod_EstadoComprobante = vc.Cod_EstadoComprobante
             INNER JOIN #VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda
             LEFT OUTER JOIN BAN_CUENTA_M AS M
             INNER JOIN CAJ_FORMA_PAGO AS F ON M.Id_MovimientoCuenta = F.Id_Movimiento
             INNER JOIN BAN_CUENTA_BANCARIA AS B ON M.Cod_CuentaBancaria = B.Cod_CuentaBancaria ON CP.id_ComprobantePago = F.id_ComprobantePago ON D.id_ComprobantePago = CP.id_ComprobantePago
             CROSS APPLY cp.Obs_Comprobante.nodes('/Registro') AS Point(Registro)
        WHERE(CP.Cod_Caja = @Cod_Caja)
             AND (F.Cod_Turno = @Cod_Turno)
             AND (F.Cod_Turno <> CP.Cod_Turno)
        UNION -- Movimientos de Almacen
        SELECT 'ALM_ALMACEN_MOV' AS Entidad, 
               M.Id_AlmacenMov AS ID, 
               M.Cod_TipoComprobante + ':' + M.Serie + '-' + CONVERT(VARCHAR, CONVERT(INT, M.Numero)) AS Documento,
               CASE M.Flag_Anulado
                   WHEN 0
                   THEN M.Motivo
                   ELSE 'ANULADO'
               END AS Cliente, 
               D.Des_Producto, 
               M.Fecha_Reg, 
               D.Cantidad, 
               D.Precio_Unitario, 
               0 ICBPER, 
               ROUND(D.Cantidad * D.Precio_Unitario, 2), 
               Obs_AlmacenMovD, 
               D.Item, 
               M.Fecha, 
               '', 
               'S/', 
               0.00, 
               'S/', 
               0.00, 
               0.00, 
               0.00, 
               1, 
               0.00, 
               '', 
               '', 
               M.Cod_UsuarioReg, 
               '', 
               1, 
               'FINALIZADO'
        FROM ALM_ALMACEN_MOV AS M
             INNER JOIN ALM_ALMACEN_MOV_D AS D ON M.Id_AlmacenMov = D.Id_AlmacenMov
             INNER JOIN CAJ_CAJA_ALMACEN AS C ON M.Cod_Almacen = C.Cod_Almacen
        WHERE(C.Cod_Caja = @Cod_Caja)
             AND (M.Cod_Turno = @Cod_Turno)
        -- Movimientos de Pago
        -- Movimientos de Bancos
        ORDER BY Fecha_Reg DESC;
        DROP TABLE #VIS_ESTADO_COMPROBANTE;
        DROP TABLE #VIS_MONEDAS;
    END;
GO