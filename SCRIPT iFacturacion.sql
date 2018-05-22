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

--Autor Erwin M. Rayme Chambi,23/11/2016
--Metodo que trae los productos con stock >0 por codigo de categoria, un codigo de almacen y un codigo de precio
--Devuelve el codigo de producto, sus nombres  y precio de venta
--USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock '01','A0006','CPRAA'
--IF EXISTS ( SELECT  name FROM    sysobjects WHERE   name = 'USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock' AND type = 'P' ) 
--   DROP PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
--go
--CREATE PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
--@CodCategoria varchar(10),
--@CodAlmacen varchar(10),
--@CodPrecio varchar(10)
--WITH ENCRYPTION
--AS 
--BEGIN
--	SELECT  DISTINCT   P.Cod_Producto, P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto, PP.Valor, PS.Stock_Act, PP.Id_Producto
--	FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
--                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
--                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_Almacen = PS.Cod_Almacen AND P.Id_Producto = PS.Id_Producto
--	WHERE        (P.Cod_Categoria = @CodCategoria) AND (PS.Stock_Act > 0) AND (PS.Cod_Almacen = @CodAlmacen) AND (PP.Cod_TipoPrecio=@CodPrecio)
--END
--go

--Autor Erwin M. Rayme Chambi,23/11/2016
--Metodo que trae los productos con stock >0 por codigo de categoria, un codigo de almacen y un codigo de precio, Agregado flag stock
--Devuelve el codigo de producto, sus nombres  y precio de venta
--USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock '01','A0006','CPRAA'
--IF EXISTS ( SELECT  name FROM    sysobjects WHERE   name = 'USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock' AND type = 'P' ) 
--   DROP PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
--go
--CREATE PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
--@CodCategoria varchar(10),
--@CodAlmacen varchar(10),
--@CodPrecio varchar(10)
--WITH ENCRYPTION
--AS 
--BEGIN
--	SELECT  DISTINCT   P.Cod_Producto, P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto, PP.Valor, PS.Stock_Act, PP.Id_Producto,P.Flag_Stock
--	FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
--                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
--                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_Almacen = PS.Cod_Almacen AND P.Id_Producto = PS.Id_Producto
--	WHERE        (P.Cod_Categoria = @CodCategoria) AND (PS.Stock_Act > 0) AND (PS.Cod_Almacen = @CodAlmacen) AND (PP.Cod_TipoPrecio=@CodPrecio)
--END
--go

--Autor Erwin M. Rayme Chambi,23/11/2016,16/01/2017
--Metodo que trae los productos con stock >0 por codigo de categoria, un codigo de almacen y un codigo de precio, Agregado flag stock, Agregado sin control de stock
--Devuelve el codigo de producto, sus nombres  y precio de venta
--USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock '01','A0006','CPRAA'
IF EXISTS ( SELECT  name FROM    sysobjects WHERE   name = 'USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock' AND type = 'P' ) 
   DROP PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
go
CREATE PROCEDURE USP_PRODUCTOS_TXCodCat_CodAlm_CodPrec_Stock
@CodCategoria varchar(10),
@CodAlmacen varchar(10),
@CodPrecio varchar(10)
WITH ENCRYPTION
AS 
BEGIN
	SELECT  DISTINCT   P.Cod_Producto, P.Nom_Producto,P.Des_CortaProducto,P.Des_LargaProducto, PP.Valor, PS.Stock_Act, PP.Id_Producto,P.Flag_Stock
	FROM            PRI_PRODUCTO_PRECIO AS PP INNER JOIN
                         PRI_PRODUCTOS AS P ON PP.Id_Producto = P.Id_Producto INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON PP.Id_Producto = PS.Id_Producto AND PP.Cod_Almacen = PS.Cod_Almacen AND P.Id_Producto = PS.Id_Producto
	WHERE       ( (P.Cod_Categoria = @CodCategoria) AND (P.Flag_Stock=1) AND (PS.Stock_Act > 0) AND (PS.Cod_Almacen = @CodAlmacen) AND (PP.Cod_TipoPrecio=@CodPrecio))
	or ((P.Cod_Categoria = @CodCategoria) AND (P.Flag_Stock=0)  AND (PS.Cod_Almacen = @CodAlmacen) AND (PP.Cod_TipoPrecio=@CodPrecio))
END
go


-- USP_PRI_PRODUCTOS_Buscar '0006','',NULL,'01','001',null,0
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTOS_Buscar' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar
go
CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar
@Cod_Caja as  varchar(32)=null,
@Buscar  varchar(512),
@CodTipoProducto as  varchar(8) = NULL,
@Cod_Categoria as  varchar(32) = NULL,
@Cod_Precio as  varchar(32) = NULL,
@Flag_Stock AS BIT = 1,
@Flag_RequiereStock as bit = 1
WITH ENCRYPTION
AS
BEGIN

SET DATEFORMAT dmy;
	if(@Flag_RequiereStock=1)
	begin
	SELECT        P.Id_Producto, P.Des_LargaProducto AS Nom_Producto, P.Cod_Producto, PS.Stock_Act, PS.Precio_Venta, 
					M.Nom_Moneda, PS.Cod_Almacen, 0 AS Descuento,
					'NINGUNO' AS TipoDescuento, A.Des_Almacen, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida,P.Flag_Stock,PS.Precio_Compra, 
				case when @Cod_Precio is null then 0 else dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto,PS.Cod_UnidadMedida,PS.Cod_Almacen,@Cod_Precio) end as Precio,
				P.Cod_TipoOperatividad
	FROM            PRI_PRODUCTOS AS P INNER JOIN
							 PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
							 VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda INNER JOIN
							 ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
							 VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
							 CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
	WHERE  (P.Cod_TipoProducto = @CodTipoProducto OR @CodTipoProducto IS NULL) 
	AND ( (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Producto LIKE @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
	AND (P.Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria))  OR @Cod_Categoria IS NULL) 
	AND  (ca.Cod_Caja = @Cod_Caja or @Cod_Caja is null)
	AND (P.Flag_Activo = 1)
	AND (PS.Stock_Act > 0)	
	order by Cod_Producto
	end
	else
	begin
	SELECT        P.Id_Producto, P.Des_LargaProducto AS Nom_Producto, P.Cod_Producto, PS.Stock_Act, PS.Precio_Venta, 
					M.Nom_Moneda, PS.Cod_Almacen, 0 AS Descuento,
					'NINGUNO' AS TipoDescuento, A.Des_Almacen, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida,P.Flag_Stock,PS.Precio_Compra, 
				case when @Cod_Precio is null then 0 else dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto,PS.Cod_UnidadMedida,PS.Cod_Almacen,@Cod_Precio) end as Precio,
				P.Cod_TipoOperatividad
	FROM            PRI_PRODUCTOS AS P INNER JOIN
							 PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
							 VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda INNER JOIN
							 ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
							 VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
							 CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
	WHERE  (P.Cod_TipoProducto = @CodTipoProducto OR @CodTipoProducto IS NULL) 
	AND ( (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Producto LIKE @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
	AND (P.Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria))  OR @Cod_Categoria IS NULL) 
	AND  (ca.Cod_Caja = @Cod_Caja or @Cod_Caja is null)
	AND (P.Flag_Activo = 1)
	order by Cod_Producto
	end
END
go





---Recupera los detalles de un producto en base a su codigo de producto, usado para recuperar la categoria
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/11/2016
-- USP_PRI_PRODUCTO_TPreciosXCodProd '70001526'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_TPreciosXCodProd' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_TPreciosXCodProd
go
CREATE PROCEDURE USP_PRI_PRODUCTO_TPreciosXCodProd
@Cod_Producto varchar(50)
WITH ENCRYPTION
AS
BEGIN
	select Top 1 * from PRI_PRODUCTOS where Cod_Producto=@Cod_Producto
END
go

-----Recupera los detalles de un producto y precios en base a un codigo de producto
---- Autor(es): Rayme Chambi Erwin Miuller
---- Fecha de Creación:  24/11/2016
---- USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre '70003180','A0006','CPRAA'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre' AND type = 'P')
--DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
--go
--CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
--@Cod_Producto varchar(50),
--@Cod_Almacen varchar(50),
--@Cod_TipoPrecio varchar(50)
--WITH ENCRYPTION
--AS
--BEGIN
--	SELECT  *
--	FROM            PRI_PRODUCTOS as P INNER JOIN
--							 PRI_PRODUCTO_PRECIO as PP ON P.Id_Producto =PP.Id_Producto
--	where P.Cod_Producto=@Cod_Producto and Cod_Almacen=@Cod_Almacen and Cod_TipoPrecio=@Cod_TipoPrecio
--END
--go



---Recupera los detalles de un producto y precios en base a un codigo de producto(Modificado para agregar StockCActual)
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  24/11/2016
-- USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre '70003180','A0006','CPRAA'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre' AND type = 'P')
DROP PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
go
CREATE PROCEDURE USP_PRI_PRODUCTO_PRECIO_TPreciosXCodProd_CodAlm_CodPre
@Cod_Producto varchar(50),
@Cod_Almacen varchar(50),
@Cod_TipoPrecio varchar(50)
WITH ENCRYPTION
AS
BEGIN
	SELECT  *
	FROM            PRI_PRODUCTOS as P INNER JOIN
							 PRI_PRODUCTO_PRECIO as PP ON P.Id_Producto =PP.Id_Producto
							 INNER JOIN
							 PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto and PP.Cod_Almacen=PS.Cod_Almacen
	where P.Cod_Producto=@Cod_Producto and PP.Cod_Almacen=@Cod_Almacen and Cod_TipoPrecio=@Cod_TipoPrecio
END
go



--Pruebas de comprobantes
--

---Recupera los detalles de un tipo de comprobante
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  05/12/2016
-- USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante 'BE'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante' AND type = 'P')
DROP PROCEDURE USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante
go
CREATE PROCEDURE USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante
@Cod_TipoComprobante varchar(50)
WITH ENCRYPTION
AS
BEGIN
	SELECT * FROM VIS_TIPO_COMPROBANTES where Cod_TipoComprobante=@Cod_TipoComprobante
END
go


---Recupera la fechas de comprobantes hasta antes de un dia emitidos en base a un codigo de estado
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  07/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado 'EMI'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado
@Cod_EstadoComprobante varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select CONVERT(VARCHAR(10), FechaEmision, 126) as Fecha, count(FechaEmision) as Totales
	from CAJ_COMPROBANTE_PAGO where  CONVERT(VARCHAR(10), FechaEmision, 126)<CONVERT(VARCHAR(10), GETDATE(), 126) and Cod_EstadoComprobante=@Cod_EstadoComprobante
	group by CONVERT(VARCHAR(10), FechaEmision, 126)
	having count(CONVERT(VARCHAR(10), FechaEmision, 126)) > 0 
END
go


---Recupera los comprobantes que faltan emitir
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  09/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
WITH ENCRYPTION
AS
BEGIN
	select id_ComprobantePago,0 as Item,Cod_EstadoComprobante,'' as Cod_Mensaje,'' as Mensaje,Cod_UsuarioReg
	from CAJ_COMPROBANTE_PAGO
	where Cod_EstadoComprobante!='FIN' and Flag_Anulado=0 
	and (Cod_TipoComprobante='BE' or Cod_TipoComprobante='FE' or Cod_TipoComprobante='NCE' or Cod_TipoComprobante='NDE')
END
go



---- Recupera el resumen de boletas dada una fecha 
---- La fecha debe entrar en formato AAAA/MM/DD
---- Autor(es): Rayme Chambi Erwin Miuller
---- Fecha de Creación:  13/12/2016
---- USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas '2016-12-05'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas' AND type = 'P')
--DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
--go
--CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
--@Fecha varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	select RESB.TipoDocumento,RESB.Serie,RESB.CorrelativoDocumentoInicio,RESB.CorrelativoDocumentoFin,
--	SUM(RESB.Importe_Total) as Importe_Total,SUM(RESB.SumaGravadas) as SumaGravadas, SUM (RESB.SumaExoneradas) as SumaExoneradas, SUM (RESB.SumaInafectas) as SumaInafectas,
--	SUM(RESB.SumaGratuitas) as SumaGratuitas, SUM(RESB.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RESB.SumatoriaTotalISC) as SumatoriaISC,
--	SUM(RESB.TotalOtrosCargos) as TotalOtrosCargos,SUM(RESB.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
--	 from
--	(select  distinct '03' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
--	where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
--	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
--	where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
--	SUM(CD.Sub_Total) as Importe_Total,
--	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
--	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
--	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
--	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
--	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
--	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
--	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV) as RESB
--	group by TipoDocumento,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin
--	union
--	select case when RES.Cod_TipoComprobante='NCE' then '07' when  RES.Cod_TipoComprobante='NDE' then '08' end aS TipoDocumento,RES.Serie,RES.CorrelativoDocumentoInicio,RES.CorrelativoDocumentoFin,
--	SUM(RES.Importe_Total) as Importe_Total,SUM(RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
--	SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RES.SumatoriaTotalISC) as SumatoriaISC,
--	SUM(RES.TotalOtrosCargos) as TotalOtrosCargos,SUM(RES.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
--	 from
--	(select  distinct Cp.Cod_TipoComprobante,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
--	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
--	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
--	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
--	SUM(CD.Sub_Total) as Importe_Total,
--	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
--	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
--	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
--	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
--	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
--	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
--	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where (CP.Cod_TipoComprobante='NPE' or CP.Cod_TipoComprobante='NCE') and CP.Serie LIKE 'B' +'%' and Cp.Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV,CP.Cod_TipoComprobante) as RES
--	group by Cod_TipoComprobante,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin

--END
--go


---- Recupera el resumen de boletas dada una fecha ,
---- Modificado para optimizar la consulta y reducirla
---- La fecha debe entrar en formato AAAA-MM-DD
---- Autor(es): Rayme Chambi Erwin Miuller,Erwin
---- Fecha de Creación:  13/12/2016,14/12/2016
---- USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas '2016-12-31 00:12:15'
--IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas' AND type = 'P')
--DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
--go
--CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
--@Fecha varchar(10)
--WITH ENCRYPTION
--AS
--BEGIN
--	set @Fecha=CONVERT(VARCHAR(10), @Fecha, 126)
--	select case when RES.Cod_TipoComprobante='NCE' then '07' when  RES.Cod_TipoComprobante='NDE' then '08'  when  RES.Cod_TipoComprobante='BE' then '03'end aS TipoDocumento,RES.Serie,RES.CorrelativoDocumentoInicio,RES.CorrelativoDocumentoFin,
--	SUM(RES.Importe_Total) as Importe_Total,SUM(RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
--	SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RES.SumatoriaTotalISC) as SumatoriaISC,
--	SUM(RES.TotalOtrosCargos) as TotalOtrosCargos,SUM(RES.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
--	 from
--	(select  distinct Cp.Cod_TipoComprobante,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
--	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
--	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
--	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
--	SUM(CD.Sub_Total) as Importe_Total,
--	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
--	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
--	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
--	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
--	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
--	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
--	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where ((CP.Cod_TipoComprobante='NPE' or CP.Cod_TipoComprobante='NCE') and CP.Serie LIKE 'B' +'%') or (CP.Cod_TipoComprobante='BE') and Cp.Cod_EstadoComprobante!='FIN'
--	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV,CP.Cod_TipoComprobante) as RES
--	group by Cod_TipoComprobante,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin
--END
--


--(select RES.id_ComprobantePago, RES.Serie,RES.Numero,CONVERT(VARCHAR(10), RES.FechaEmision, 126) as FechaEmision,RES.Cod_TipoComprobante,RES.Cod_TipoDoc,
--RES.Doc_Cliente,RES.Total,RES.Otros_Cargos,RES.Otros_Tributos, SUM (RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
--SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaIGV) as SumatoriaIGV,SUM(RES.SumatoriaISC) as SumatoriaISC from 
--(select distinct CP.id_ComprobantePago, CP.Serie,CP.Numero,CONVERT(VARCHAR(10), CP.FechaEmision, 126) as FechaEmision, 
--case when Cp.Cod_TipoComprobante='BE' then '03' when Cp.Cod_TipoComprobante='NCE' then '07' when Cp.Cod_TipoComprobante='NPE' then '08' end as Cod_TipoComprobante ,Cp.Cod_TipoDoc,
--Cp.Doc_Cliente,Cp.Total,CP.Otros_Cargos,cp.Otros_Tributos, 
--case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas, 
--case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
--case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
--case when 
--CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or
--CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
--then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas, 
--SUM(CD.IGV) as SumatoriaIGV, SUM(CD.ISC) as SumatoriaISC
--from CAJ_COMPROBANTE_PAGO as CP full outer join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago
--where CP.Cod_TipoComprobante='BE' and CONVERT(VARCHAR(10), CP.FechaEmision, 126)='2016-11-26'
--group by CP.id_ComprobantePago,CP.Serie,CP.Numero,CP.FechaEmision,CP.Cod_TipoComprobante,cp.Cod_TipoDoc,CP.Doc_Cliente,Cp.Total,
--Cp.Otros_Cargos,Cp.Otros_Tributos,CD.Sub_Total,CD.Cod_TipoIGV) as RES group by RES.id_ComprobantePago, RES.Serie,RES.Numero,CONVERT(VARCHAR(10), RES.FechaEmision, 126),RES.Cod_TipoComprobante,RES.Cod_TipoDoc,
--RES.Doc_Cliente,RES.Total,RES.Otros_Cargos,RES.Otros_Tributos)



--declare  @Fecha varchar(10)='2016-12-05'

--select  distinct 'BE' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
--where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--and CONVERT(VARCHAR(10), FechaEmision, 126)='2016-12-05' order by Numero asc) as CorrelativoDocumentoInicio,
--(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
--where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
--SUM(CP.Total) as Importe_Total,SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
--from CAJ_COMPROBANTE_PAGO as CP where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante!='FIN'
--and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie



--declare  @Fecha varchar(10)='2016-12-13'
--select RESB.TipoDocumento,RESB.Serie,RESB.CorrelativoDocumentoInicio,RESB.CorrelativoDocumentoFin,
--SUM(RESB.Importe_Total) as Importe_Total,SUM(RESB.SumaGravadas) as SumaGravadas, SUM (RESB.SumaExoneradas) as SumaExoneradas, SUM (RESB.SumaInafectas) as SumaInafectas,
--SUM(RESB.SumaGratuitas) as SumaGratuitas, SUM(RESB.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RESB.SumatoriaTotalISC) as SumatoriaISC,
--SUM(RESB.TotalOtrosCargos) as TotalOtrosCargos,SUM(RESB.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
-- from
--(select  distinct '03' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
--where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
--(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
--where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and Serie=Cp.Serie
--and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
--SUM(CD.Sub_Total) as Importe_Total,
--case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
--case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
--case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
--case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
--then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
--SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
--from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante!='FIN'
--and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV) as RESB
--group by TipoDocumento,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin

--select * from CAJ_COMPROBANTE_D as CD inner Join CAJ_COMPROBANTE_PAGO as CP on cd.id_ComprobantePago=Cp.id_ComprobantePago where CP.Cod_TipoComprobante='BE' and CP.Cod_EstadoComprobante!='FIN' and CONVERT(VARCHAR(10), CP.FechaEmision, 126)='2016-12-13'
--select * from CAJ_COMPROBANTE_PAGO where Cod_TipoComprobante='BE' and Cod_EstadoComprobante!='FIN' and CONVERT(VARCHAR(10), FechaEmision, 126)='2016-12-13'



---Recupera las formas de pago de un comprobante por su id
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  02/01/2017
-- USP_CAJ_FORMA_PAGO_TraerXIdComprobante 1119
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_TraerXIdComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_FORMA_PAGO_TraerXIdComprobante
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_TraerXIdComprobante
@Id_Comprobante int
WITH ENCRYPTION
AS
BEGIN
	select CP.id_ComprobantePago, CP.Cod_Caja,CP.Cod_Turno,CP.Cod_UsuarioReg,CP.Cod_TipoComprobante+' '+Cp.Serie+'-'+CP.Numero as Descripcion,
	CP.Cod_Moneda as Cod_MonedaComprobante,CP.TipoCambio as Tipo_CambioComprobante,CP.Total,CF.Cod_Moneda as Cod_MonedaPago,
	CF.Cod_TipoFormaPago,CF.Cod_UsuarioReg,CF.Cuenta_CajaBanco,CF.Des_FormaPago,CF.Monto,CF.TipoCambio as Tipo_CambioPAgo,CF.Item,CF.Fecha_Reg
	from CAJ_FORMA_PAGO as CF inner join CAJ_COMPROBANTE_PAGO as CP on CF.id_ComprobantePago=CP.id_ComprobantePago where CP.id_ComprobantePago=@Id_Comprobante
END
go

---Elimina las formas de pago mde un comprobante en base a un id de comprobante
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  04/01/2017
-- USP_CAJ_FORMA_PAGO_EliminarXIdComprobante 141
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_FORMA_PAGO_EliminarXIdComprobante' AND type = 'P')
DROP PROCEDURE USP_CAJ_FORMA_PAGO_EliminarXIdComprobante
go
CREATE PROCEDURE USP_CAJ_FORMA_PAGO_EliminarXIdComprobante
@Id_Comprobante int
WITH ENCRYPTION
AS
BEGIN
	delete from CAJ_FORMA_PAGO where id_ComprobantePago=@Id_Comprobante
END
go


-- Recupera los tipos de cambio en base a un fecha
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  07/12/2016
-- USP_CAJ_TIPOCAMBIO_TraerXFecha '2017-01-04 22:34:29.383'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_TIPOCAMBIO_TraerXFecha' AND type = 'P')
DROP PROCEDURE USP_CAJ_TIPOCAMBIO_TraerXFecha
go
CREATE PROCEDURE USP_CAJ_TIPOCAMBIO_TraerXFecha
@Fecha datetime 
WITH ENCRYPTION
AS
BEGIN
	select Id_TipoCambio,FechaHora,Cod_Moneda,SunatCompra,SunatVenta,Compra,Venta from CAJ_TIPOCAMBIO where CONVERT(VARCHAR(10), FechaHora, 126) =CONVERT(VARCHAR(10), @Fecha, 126)
END
go

-- Recupera el resumen de boletas dada una fecha ,
-- Modificado para optimizar la consulta y reducirla
-- La fecha debe entrar en formato AAAA-MM-DD
-- Autor(es): Rayme Chambi Erwin Miuller,Erwin
-- Fecha de Creación:  13/12/2016,14/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas '31-12-2016 00:12:15'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
@Fecha datetime
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT dmy;
	SELECT VTC.Cod_Sunat as TipoDocumento, CP.Serie, MIN(CP.Numero) AS CorrelativoDocumentoInicio,MAX(CP.Numero) AS CorrelativoDocumentoFin, ABS(SUM(CD.Sub_Total)) AS Importe_Total, 
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('10','17') THEN CD.Sub_Total-CD.IGV-CD.ISC ELSE 0 END)) AS SumaGravadas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('20') THEN CD.Sub_Total ELSE 0 END)) AS SumaExoneradas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('30') THEN CD.Sub_Total ELSE 0 END)) AS SumaInafectas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('11','12','13','14','15','16','21','31','32','33','34','35','36') THEN CD.Sub_Total ELSE 0 END)) AS SumaGratuitas,
	ABS(SUM(CD.IGV)) AS SumatoriaIGV, ABS(SUM(CD.ISC)) AS SumatoriaISC,ABS( AVG(CP.Otros_Cargos)) AS TotalOtrosCargos , ABS(AVG(CP.Otros_Tributos)) AS SumatoriaTotalOtrosTrib
	FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
							 VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Serie like 'B%'
	GROUP BY VTC.Cod_Sunat, CP.Serie
END
go


-- Realiza el resumen de contingencia para el excel SOLO PARA TKB Y TKF
-- Modificado para optimizar la consulta y reducirla
-- La fecha debe entrar en formato DD-MM-AAA
-- Autor(es): Rayme Chambi Erwin Miuller,Erwin
-- Fecha de Creación:  06/01/2017
--exec USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF '29-12-2016'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenExcelTKByTKF
@Fecha datetime
WITH ENCRYPTION
AS
BEGIN
	SET DATEFORMAT dmy;
	select Motivo,Fecha,NomComprobante,Serie,NumeroComprobante,FinalTicketera,TipoDocumento,NumeroDocumento,RazonSocial,SumaGravadas,SumaExoneradas,SumaInafectas,
	SumatoriaISC,SumatoriaIGV,SumOtrosTribCarg,Importe_Total,ComprobanteAfectado,SerieAfectado,NumeroAfectado from
	(SELECT 'OTROS' as Motivo,CONVERT(VARCHAR(10), @Fecha, 126) as Fecha,
	'TICKET DE MAQUINA REGISTRADORA' as NomComprobante
	, CP.Serie, 
	MIN(CP.Numero) AS NumeroComprobante,
	MAX(CP.Numero) AS FinalTicketera,
	'SIN DOCUMENTO' as TipoDocumento,
	'' as NumeroDocumento,
	'' as RazonSocial, 
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('10','17') THEN CD.Sub_Total-CD.IGV-CD.ISC ELSE 0 END)) AS SumaGravadas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('20') THEN CD.Sub_Total ELSE 0 END)) AS SumaExoneradas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('30') THEN CD.Sub_Total ELSE 0 END)) AS SumaInafectas,
	ABS(SUM(CD.ISC)) AS SumatoriaISC,
	ABS(SUM(CD.IGV)) AS SumatoriaIGV,
	ABS(AVG(CP.Otros_Tributos+Cp.Otros_Cargos)) AS SumOtrosTribCarg,
	ABS(SUM(CD.Sub_Total)) AS Importe_Total,
	'' as ComprobanteAfectado,
	'' as SerieAfectado,
	'' as NumeroAfectado
	FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
							 VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Cod_TipoComprobante like 'TKB%'
	and CP.Flag_Anulado=0
	GROUP BY VTC.Cod_Sunat, CP.Serie
	union 
	SELECT 'OTROS' as Motivo,CONVERT(VARCHAR(10), @Fecha, 126) as Fecha,
	'TICKET DE MAQUINA REGISTRADORA' as NomComprobante,
	CP.Serie,
	CP.Numero AS NumeroComprobante,
	'' AS FinalTicketera,
	'RUC' as TipoDocumento,
	CP.Doc_Cliente as NumeroDocumento,
	CP.Nom_Cliente as RazonSocial, 
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('10','17') THEN CD.Sub_Total-CD.IGV-CD.ISC ELSE 0 END)) AS SumaGravadas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('20') THEN CD.Sub_Total ELSE 0 END)) AS SumaExoneradas,
	ABS(SUM(CASE WHEN CD.Cod_TipoIGV IN ('30') THEN CD.Sub_Total ELSE 0 END)) AS SumaInafectas,
	ABS(SUM(CD.ISC)) AS SumatoriaISC,
	ABS(SUM(CD.IGV)) AS SumatoriaIGV,
	ABS(AVG(CP.Otros_Tributos+Cp.Otros_Cargos)) AS SumOtrosTribCarg,
	ABS(SUM(CD.Sub_Total)) AS Importe_Total,
	'' as ComprobanteAfectado,
	'' as SerieAfectado,
	'' as NumeroAfectado
	FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
							 CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
							 VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
	where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@Fecha,103)) AND CP.Cod_TipoComprobante like 'TKF%'
	and CP.Flag_Anulado=0
	GROUP BY CP.Numero, CP.Serie,Cp.Doc_Cliente,CP.Nom_Cliente) RES
	order by NumeroComprobante
END
go
--Modificacion de metodo USP_P
---Recupera los comprobantes que faltan emitir
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  09/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerFacturasSinFinalizar
WITH ENCRYPTION
AS
BEGIN
	select A.id_ComprobantePago,0 as Item,A.Cod_EstadoComprobante,A.Cod_TipoComprobante,A.Serie + '-' + A.Numero as Comprobante,
	A.Cod_Moneda,A.Total,A.FechaEmision,B.Email1,B.Email2,A.Nom_Cliente,0 as Sunat,0 as BD, 0 as FTP, 0 as Email,A.Cod_UsuarioReg
	from CAJ_COMPROBANTE_PAGO A inner join PRI_CLIENTE_PROVEEDOR B
	on A.Id_Cliente = B.Id_ClienteProveedor
	where A.Cod_EstadoComprobante!='FIN' and A.Flag_Anulado=0 
	and (A.Cod_TipoComprobante='FE' or A.Cod_TipoComprobante='NCE' or A.Cod_TipoComprobante='NDE') and (A.Serie like 'F%')
	order by FechaEmision ASC
END
go

---Recupera los comprobantes que faltan emitir
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  09/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerBoletasSinFinalizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerBoletasSinFinalizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerBoletasSinFinalizar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerBoletasSinFinalizar
WITH ENCRYPTION
AS
BEGIN
	select A.id_ComprobantePago,0 as Item,A.Cod_EstadoComprobante,A.Cod_TipoComprobante,A.Serie + '-' + A.Numero as Comprobante,
	A.Cod_Moneda,A.Total,A.FechaEmision,B.Email1,B.Email2,A.Nom_Cliente,0 as Sunat,0 as BD, 0 as FTP, 0 as Email,A.Cod_UsuarioReg
	from CAJ_COMPROBANTE_PAGO A inner join PRI_CLIENTE_PROVEEDOR B
	on A.Id_Cliente = B.Id_ClienteProveedor
	where A.Cod_EstadoComprobante!='FIN' and A.Flag_Anulado=0 
	and (A.Cod_TipoComprobante='BE' or A.Cod_TipoComprobante='NCE' or A.Cod_TipoComprobante='NDE') and (A.Serie like 'B%') and (A.FechaEmision < DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0))
	order by FechaEmision ASC
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
