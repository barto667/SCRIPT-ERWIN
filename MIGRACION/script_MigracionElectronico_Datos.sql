-- -- Actualizaqr los campos de las unidades de medida
-- ALTER TABLE PRI_PRODUCTO_PRECIO  
-- DROP CONSTRAINT FK__PRI_PRODUCTO_PRE__34C8D9D1;
-- GO
-- UPDATE PRI_PRODUCTO_STOCK SET Cod_UnidadMedida = 'GLL', Cod_UnidadMedidaMin = 'GLL' WHERE Cod_UnidadMedida = 'GL'
-- UPDATE PRI_PRODUCTO_PRECIO SET Cod_UnidadMedida = 'GLL' WHERE Cod_UnidadMedida = 'GL'
-- UPDATE PRI_PRODUCTO_STOCK SET Cod_UnidadMedida = 'NIU', Cod_UnidadMedidaMin = 'NIU' WHERE Cod_UnidadMedida = 'UNI'
-- UPDATE PRI_PRODUCTO_PRECIO SET Cod_UnidadMedida = 'NIU' WHERE Cod_UnidadMedida = 'UNI'
-- UPDATE CAJ_COMPROBANTE_D SET Cod_UnidadMedida = 'GLL' WHERE Cod_UnidadMedida = 'GL'
-- UPDATE ALM_ALMACEN_MOV_D SET Cod_UnidadMedida = 'GLL' WHERE Cod_UnidadMedida = 'GL'
-- UPDATE PRI_LICITACIONES_D SET Cod_UnidadMedida = 'GLL' WHERE Cod_UnidadMedida = 'GL'
-- UPDATE CAJ_COMPROBANTE_D SET Cod_UnidadMedida = 'NIU' WHERE Cod_UnidadMedida = 'UNI'
-- UPDATE ALM_ALMACEN_MOV_D SET Cod_UnidadMedida = 'NIU' WHERE Cod_UnidadMedida = 'UNI'
-- UPDATE PRI_LICITACIONES_D SET Cod_UnidadMedida = 'NIU' WHERE Cod_UnidadMedida = 'UNI'
-- GO
-- ALTER TABLE PRI_PRODUCTO_PRECIO
-- ADD FOREIGN KEY (Id_Producto, Cod_UnidadMedida, Cod_Almacen)
-- REFERENCES PRI_PRODUCTO_STOCK(Id_Producto, Cod_UnidadMedida, Cod_Almacen)
-- GO


-- SOLO PARA LAS EMPRESA
-- Actualizar los tipos de comprobantes
EXEC USP_PAR_FILA_G '090','002',1,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',2,'FE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',3,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',4,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',5,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',6,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '090','002',7,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
GO
UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_TipoComprobante = 'BE' WHERE Cod_TipoComprobante IN ('BO','TKB');
UPDATE PRI_CLIENTE_PROVEEDOR SET Cod_TipoComprobante = 'FE' WHERE Cod_TipoComprobante IN ('FA','TKF');
GO

-- Alternativo segun cada empresa
UPDATE [PALERPdata].dbo.PRI_CLIENTE_PROVEEDOR SET Cod_TipoComprobante = 'BE' WHERE Cod_TipoComprobante IN ('BO','TKB');
UPDATE [PALERPdata].dbo.PRI_CLIENTE_PROVEEDOR SET Cod_TipoComprobante = 'FE' WHERE Cod_TipoComprobante IN ('FA','TKF');
go