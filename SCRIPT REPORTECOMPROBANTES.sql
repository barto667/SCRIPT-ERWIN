--Usado para generar el procedimiento para Cristal report de los comprobantes impresos
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'URP_CAJ_COMPROBANTE_PAGO_TXPK' AND type = 'P')
DROP PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK
go
CREATE PROCEDURE URP_CAJ_COMPROBANTE_PAGO_TXPK 
@id_ComprobantePago int
WITH ENCRYPTION
AS
BEGIN
SELECT        CP.id_ComprobantePago, VTC.Nom_TipoComprobante, CP.Serie, CP.Numero, VTD.Nom_TipoDoc, CP.Doc_Cliente, CP.Nom_Cliente, CP.Direccion_Cliente, 
                         CP.FechaEmision, CP.FechaVencimiento, CP.FechaCancelacion, CP.Glosa, CP.TipoCambio, CP.Flag_Anulado, VF.Nom_FormaPago, CP.Descuento_Total, 
                         VM.Nom_Moneda, VM.Simbolo, VM.Definicion, CP.Impuesto, CP.Total, CP.Obs_Comprobante, CP.GuiaRemision, CP.Nro_Ticketera, CP.Cod_UsuarioVendedor, 
                         CP.Cod_RegimenPercepcion, CP.Tasa_Percepcion, CP.Placa_Vehiculo, CP.Cod_TipoDocReferencia, CP.Nro_DocReferencia, CP.Valor_Resumen, CP.Valor_Firma, 
                         CP.MotivoAnulacion, CP.Otros_Cargos, CP.Otros_Tributos, P.Cod_Producto, A.Des_Almacen, A.Des_CortaAlmacen, CD.Cantidad, VUM.Nom_UnidadMedida, 
                         CD.Despachado, CD.Descripcion, CD.PrecioUnitario, CD.Descuento, CD.Sub_Total, VTO.Nom_TipoOperatividad, CD.Obs_ComprobanteD, CD.Cod_Manguera, 
                         CD.Flag_AplicaImpuesto, CD.Formalizado, CD.Valor_NoOneroso, CD.Cod_TipoISC, CD.Porcentaje_ISC, CD.ISC, CD.Cod_TipoIGV, CD.Porcentaje_IGV, CD.IGV, 
                         CI.Foto,dbo.UFN_ConvertirNumeroLetra(CP.Total)+' '+VM.Definicion AS Monto_Letras
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
                         CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
                         CAJ_CAJAS AS C ON CP.Cod_Caja = C.Cod_Caja INNER JOIN
                         CAJ_TURNO_ATENCION AS T ON CP.Cod_Turno = T.Cod_Turno INNER JOIN
                         VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante INNER JOIN
                         VIS_TIPO_DOCUMENTOS AS VTD ON CP.Cod_TipoDoc = VTD.Cod_TipoDoc INNER JOIN
                         VIS_FORMAS_PAGO AS VF ON CP.Cod_FormaPago = VF.Cod_FormaPago INNER JOIN
                         VIS_MONEDAS AS VM ON CP.Cod_Moneda = VM.Cod_Moneda INNER JOIN
                         PRI_PRODUCTOS AS P ON CD.Id_Producto = P.Id_Producto INNER JOIN
                         ALM_ALMACEN AS A ON CD.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS VUM ON CD.Cod_UnidadMedida = VUM.Cod_UnidadMedida INNER JOIN
                         VIS_TIPO_OPERATIVIDAD AS VTO ON CD.Tipo = VTO.Cod_TipoOperatividad INNER JOIN
                         PRI_CLIENTE_PROVEEDOR AS CI ON CP.Id_Cliente = CI.Id_ClienteProveedor
WHERE     (CP.id_ComprobantePago = @id_ComprobantePago) 
order by id_Detalle
END
go

URP_CAJ_COMPROBANTE_PAGO_TXPK '393520'
select * from CAJ_COMPROBANTE_PAGO

select id_ComprobantePago, count(id_ComprobantePago)
from dbo.CAJ_COMPROBANTE_D 
group by id_ComprobantePago
having count(id_ComprobantePago) > 1 

select * from CAJ_COMPROBANTE_PAGO where Cod_Libro=14 and Cod_TipoComprobante='FA' order by Total DESC