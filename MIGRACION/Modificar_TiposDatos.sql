-- --Consulta que detecta los tipos de datos de todas los objetos de la base de datos
-- --Necesitamos conocer el tipo
--     DECLARE @tipo_datoColumna varchar(max) ='image'
--     SELECT OBJ.id AS id_tabla,OBJ.NAME AS nombre_tabla, 
--             ROW_NUMBER() OVER (ORDER BY COL.colid) AS id_columna, 
--             COL.name AS nombre_columna, 
--             TYP.name AS tipo_columna, 
--             --Por algun motivo los nvarchar dan el doble de la longitud
--             Longitud = CASE TYP.name 
--                 WHEN 'nvarchar' THEN COL.LENGTH/2
--                 WHEN 'varchar' THEN COL.LENGTH/2
--                 ELSE COL.LENGTH
--                 END,
--             COL.xprec AS precision_columna, 
--             COL.xscale AS escala, 
--             COL.isnullable AS acepta_nulos, 
--             FK.constid AS id_claveforanea, 
--             OBJ2.name AS nombre_tablaforanea, 
--             COL2.name  AS nombre_columnaforanea
--             --COL.*
--         FROM dbo.syscolumns COL
--         JOIN dbo.sysobjects OBJ ON OBJ.id = COL.id
--         JOIN dbo.systypes TYP ON TYP.xusertype = COL.xtype
--         --left join dbo.sysconstraints CON on CON.colid = COL.colid
--         LEFT JOIN dbo.sysforeignkeys FK ON FK.fkey = COL.colid AND FK.fkeyid=OBJ.id
--         LEFT JOIN dbo.sysobjects OBJ2 ON OBJ2.id = FK.rkeyid
--         LEFT JOIN dbo.syscolumns COL2 ON COL2.colid = FK.rkey AND COL2.id = OBJ2.id
--         WHERE  (OBJ.xtype='U' OR OBJ.xtype='V')
--        AND TYP.name=@tipo_datoColumna
--        order by OBJ.NAME,COL.NAME


--Script que modifica los tipos de datos de binary a image en todas las tabla
--Se hace de forma manual por seguirdad
ALTER TABLE dbo.CAJ_TRANSFERENCIAS 
ALTER COLUMN Doc_Transferencia image
GO
ALTER TABLE dbo.CAL_DOCUMENTOS 
ALTER COLUMN Documento image
GO
ALTER TABLE dbo.PLA_BIOMETRICO 
ALTER COLUMN Valor image
GO
ALTER TABLE dbo.PRI_CATEGORIA 
ALTER COLUMN Foto image
GO
ALTER TABLE dbo.PRI_CLIENTE_PROVEEDOR 
ALTER COLUMN Firma image
GO
ALTER TABLE dbo.PRI_CLIENTE_PROVEEDOR 
ALTER COLUMN Foto image
GO
ALTER TABLE dbo.PRI_EMPRESA 
ALTER COLUMN Imagen_H image
GO
ALTER TABLE dbo.PRI_EMPRESA 
ALTER COLUMN Imagen_V image
GO
ALTER TABLE dbo.PRI_PRODUCTO_IMAGEN 
ALTER COLUMN Imagen image
GO
ALTER TABLE dbo.PRI_USUARIO 
ALTER COLUMN Foto image
GO


--Metodo que trae todos los datos de pri_productoimagen en base a un id_producto
--exec USP_PRI_PRODUCTO_IMAGEN_TXIdProducto 1
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_IMAGEN_TXIdProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_IMAGEN_TXIdProducto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_IMAGEN_TXIdProducto @Id_Producto INT
AS
     BEGIN
         SELECT ppi.*
         FROM dbo.PRI_PRODUCTO_IMAGEN ppi
         WHERE ppi.Id_Producto = @Id_Producto;
     END;
GO

--Metodo que elimina todos los datos de pri_productoimagen en base a un id_producto
--exec USP_PRI_PRODUCTO_IMAGEN_EXIdProducto 1
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_PRI_PRODUCTO_IMAGEN_EXIdProducto'
          AND type = 'P'
)
    DROP PROCEDURE USP_PRI_PRODUCTO_IMAGEN_EXIdProducto;
GO
CREATE PROCEDURE USP_PRI_PRODUCTO_IMAGEN_EXIdProducto @Id_Producto INT
AS
     BEGIN
         DELETE dbo.PRI_PRODUCTO_IMAGEN
         WHERE dbo.PRI_PRODUCTO_IMAGEN.Id_Producto = @Id_Producto;
     END;


-- -- Guadar
-- IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_PRODUCTO_IMAGEN_G' AND type = 'P')
--     DROP PROCEDURE USP_PRI_PRODUCTO_IMAGEN_G
-- go
-- CREATE PROCEDURE USP_PRI_PRODUCTO_IMAGEN_G 
--     @Id_Producto    int, 
--     @Item_Imagen    int, 
--     @Imagen image, 
--     @Cod_TipoImagen varchar(5),
--     @Cod_Usuario Varchar(32)
-- WITH ENCRYPTION
-- AS
-- BEGIN
-- IF NOT EXISTS (SELECT @Id_Producto, @Item_Imagen FROM PRI_PRODUCTO_IMAGEN WHERE  (Id_Producto = @Id_Producto) AND (Item_Imagen = @Item_Imagen))
--     BEGIN
--         INSERT INTO PRI_PRODUCTO_IMAGEN  VALUES (
--         @Id_Producto,
--         @Item_Imagen,
--         @Imagen,
--         @Cod_TipoImagen,
--         @Cod_Usuario,GETDATE(),NULL,NULL)
        
--     END
--     ELSE
--     BEGIN
--         UPDATE PRI_PRODUCTO_IMAGEN
--         SET 
--             Imagen = @Imagen, 
--             Cod_TipoImagen = @Cod_TipoImagen,
--             Cod_UsuarioAct = @Cod_Usuario, 
--             Fecha_Act = GETDATE()
--         WHERE (Id_Producto = @Id_Producto) AND (Item_Imagen = @Item_Imagen) 
--     END
-- END
-- go
	
