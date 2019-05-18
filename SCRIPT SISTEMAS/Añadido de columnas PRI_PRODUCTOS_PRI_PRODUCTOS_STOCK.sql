--PRI_PRODUCTOS
ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_PRODUCTOS ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_PRODUCTOS ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_PRODUCTOS SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Reg
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_PRODUCTOS ADD Cod_ProductoSunat varchar(64);
GO
ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_PRODUCTOS ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_PRODUCTOS ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_PRODUCTOS ADD Fecha_Act datetime NULL
GO
UPDATE PRI_PRODUCTOS SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Cod_ProductoSunat = ''
GO
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_PRODUCTOS DROP COLUMN Fecha_Acth;
GO
--PRI_PRODUCTO_STOCK
ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioRegh   varchar(32) NULL
ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Regh datetime NULL
ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioActh  varchar(32) NULL
ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Acth datetime NULL
GO
UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioRegh=Cod_UsuarioReg, Fecha_Regh=Fecha_Reg,Cod_UsuarioActh=Cod_UsuarioAct,Fecha_Acth=Fecha_Act
GO
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioReg
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Reg
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioAct
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Act
GO
ALTER TABLE PRI_PRODUCTO_STOCK ADD Precio_Flete numeric(38,6);
ALTER TABLE PRI_PRODUCTO_STOCK ADD Peso numeric(38,6);
GO
ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioReg   varchar(32) NOT NULL DEFAULT('')
ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Reg datetime NOT NULL DEFAULT(GETDATE())
ALTER TABLE PRI_PRODUCTO_STOCK ADD Cod_UsuarioAct  varchar(32) NULL
ALTER TABLE PRI_PRODUCTO_STOCK ADD Fecha_Act datetime NULL
GO
UPDATE PRI_PRODUCTO_STOCK SET Cod_UsuarioReg=Cod_UsuarioRegh, Fecha_Reg=Fecha_Regh,
Cod_UsuarioAct=Cod_UsuarioActh,Fecha_Act=Fecha_Acth, Precio_Flete = 0,Peso=0
GO
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioRegh;
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Regh;
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Cod_UsuarioActh;
ALTER TABLE PRI_PRODUCTO_STOCK DROP COLUMN Fecha_Acth;
GO

--PROCEDMIENTOS MODIFICADOS

--Se añadio el peso
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOS_Buscar' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOS_Buscar
GO

CREATE PROCEDURE USP_PRI_PRODUCTOS_Buscar
@Cod_Caja as  varchar(32)=null,
@Buscar  varchar(512),
@CodTipoProducto as  varchar(8) = NULL,
@Cod_Categoria as  varchar(32) = NULL,
@Cod_Precio as  varchar(32) = NULL,
@Flag_RequiereStock as bit = 0
WITH ENCRYPTION
AS
BEGIN

SET DATEFORMAT dmy;	
--SET @Buscar = REPLACE(@Buscar,'%',' ');
		SELECT        P.Id_Producto, P.Nom_Producto AS Nom_Producto, P.Cod_Producto, PS.Stock_Act, PS.Precio_Venta, 
						M.Nom_Moneda as Nom_Moneda, PS.Cod_Almacen, 0 AS Descuento,
						'NINGUNO' AS TipoDescuento, A.Des_CortaAlmacen as Des_Almacen, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida,P.Flag_Stock,PS.Precio_Compra, 
					case when @Cod_Precio is null then 0 else dbo.UFN_PRI_PRODUCTO_PRECIO_TValor(P.Id_Producto,PS.Cod_UnidadMedida,PS.Cod_Almacen, @Cod_Precio)
					end as Precio,
					P.Cod_TipoOperatividad,M.Cod_Moneda,Cod_TipoProducto,PS.Peso
		FROM            PRI_PRODUCTOS AS P INNER JOIN
						PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto INNER JOIN
						VIS_MONEDAS AS M ON PS.Cod_Moneda = M.Cod_Moneda INNER JOIN
						ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
						VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
						CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen
		WHERE  (P.Cod_TipoProducto = @CodTipoProducto OR @CodTipoProducto IS NULL) 
		AND ( (P.Cod_Producto LIKE @Buscar) OR (P.Nom_Producto LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%') OR (P.Cod_Fabricante LIKE '%' + @Buscar + '%'))
		AND (P.Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria))  OR @Cod_Categoria IS NULL) 
		AND  (ca.Cod_Caja = @Cod_Caja or @Cod_Caja is null)
		AND (P.Flag_Activo = 1)
		--AND (@Flag_RequiereStock = 0 OR PS.Stock_Act > 0 OR P.Flag_Stock = 0)	
		order by  Nom_Producto	
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor
GO

CREATE PROCEDURE USP_PRI_PRODUCTOS_BuscarXIdClienteProveedor
@Cod_Caja as  varchar(32) = null,
@Buscar  varchar(512),
@IdClienteProveedor  int,
@Cod_Categoria as  varchar(32) = NULL
WITH ENCRYPTION
AS
BEGIN
SELECT        P.Id_Producto, P.Des_LargaProducto AS Nom_Producto, P.Cod_Producto, PS.Cod_Almacen, PS.Stock_Act, PS.Precio_Venta as Precio, ISNULL(PP.Nom_TipoPrecio, 
                         'NINGUNO') AS TipoDescuento, CASE PP.Cod_TipoPrecio WHEN '01' THEN 0 WHEN '02' THEN ISNULL(CP.Monto, 0) 
                         WHEN '03' THEN PS.Precio_Venta - ISNULL(CP.Monto, 0) WHEN '04' THEN PS.Precio_Venta * ISNULL(CP.Monto, 0) 
                         / 100 ELSE 0 END AS Descuento, M.Nom_Moneda, PS.Cod_UnidadMedida, UM.Nom_UnidadMedida, A.Des_Almacen,P.Flag_Stock,
                         P.Cod_TipoOperatividad,M.Cod_Moneda,PS.Precio_Compra,PS.Peso
FROM            VIS_MONEDAS AS M INNER JOIN
                         PRI_PRODUCTOS AS P INNER JOIN
                         PRI_PRODUCTO_STOCK AS PS ON P.Id_Producto = PS.Id_Producto ON M.Cod_Moneda = PS.Cod_Moneda INNER JOIN
                         VIS_UNIDADES_DE_MEDIDA AS UM ON PS.Cod_UnidadMedida = UM.Cod_UnidadMedida INNER JOIN
                         ALM_ALMACEN AS A ON PS.Cod_Almacen = A.Cod_Almacen INNER JOIN
                         CAJ_CAJA_ALMACEN AS CA ON A.Cod_Almacen = CA.Cod_Almacen LEFT OUTER JOIN
                         VIS_TIPO_PRECIOS AS PP INNER JOIN
                         PRI_CLIENTE_PRODUCTO AS CP ON PP.Cod_TipoPrecio = CP.Cod_TipoDescuento ON P.Id_Producto = CP.Id_Producto
WHERE     (CP.Id_ClienteProveedor = @IdClienteProveedor) OR    (P.Nom_Producto LIKE '%' + @Buscar + '%') AND (P.Flag_Activo = 1) OR
                      (P.Flag_Activo = 1) AND (P.Cod_Producto LIKE @Buscar + '%') OR
                      (P.Flag_Activo = 1) AND (PS.Cod_Almacen = @Buscar)
					   and
                      (@Cod_Categoria IN (SELECT Cod_Categoria FROM dbo.UFN_PRI_CATEGORIA_TXCategoria(@Cod_Categoria)) OR @Cod_Categoria IS NULL) and
  (CA.Cod_Caja=@Cod_Caja or @Cod_Caja is null)
order by Cod_Producto
END
GO