--METODO QUE DA DE BAJA UN COMPROBANTE POR ID
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_DarBaja' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja 
@id_ComprobantePago int,
@CodUsuario varchar(32),
@Justificacion varchar(MAX)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Id_Producto  int, @Signo  int, 
	@Cod_Almacen  varchar(32), 
	@Cod_UnidadMedida  varchar(5), 
	@Despachado  numeric(38,6),
	@Documento varchar(128),
	@Proveedor varchar(1024),
	@Detalle varchar(MAX),
	@FechaEmision datetime,
	@FechaActual datetime,
	@id_Fila int;

	SET @FechaActual =GETDATE();

	SELECT @Documento = Cod_Libro +'-'+ Cod_TipoComprobante+':'+Serie+'-'+Numero,
	@Proveedor = Cod_TipoDoc +':'+ Doc_Cliente+'-'+ Nom_Cliente,
	@FechaEmision = FechaEmision
	FROM CAJ_COMPROBANTE_PAGO WHERE id_ComprobantePago = @id_ComprobantePago

	-- RECUPERAR LOS DETALLES
	SET @Detalle = STUFF(( SELECT distinct ' ; ' + convert(varchar,D.Id_Producto) +'|'+d.Descripcion +'|'+convert(varchar,d.Cantidad)
                                     FROM   CAJ_COMPROBANTE_D D
                                     WHERE  D.id_ComprobantePago = @id_ComprobantePago
                                   FOR
                                     XML PATH('')
                                   ), 1, 2, '') + ''

	set @Signo = (select case Cod_Libro when '08' then -1 when '14' then 1 else 0 end from CAJ_COMPROBANTE_PAGO 
	where id_ComprobantePago = @id_ComprobantePago);

	DECLARE ComprobanteD CURSOR FOR
		SELECT Id_Producto,Cod_UnidadMedida,Cod_Almacen,Despachado
		from CAJ_COMPROBANTE_D
		WHERE id_ComprobantePago = @id_ComprobantePago and Id_Producto <> 0
		OPEN ComprobanteD;
	FETCH NEXT FROM ComprobanteD INTO @Id_Producto,@Cod_UnidadMedida,@Cod_Almacen,@Despachado;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE PRI_PRODUCTO_STOCK 
		SET Stock_Act = Stock_Act+@Signo * @Despachado
		WHERE Id_Producto = @Id_Producto and Cod_UnidadMedida = @Cod_UnidadMedida and Cod_Almacen = @Cod_Almacen
	FETCH NEXT FROM ComprobanteD INTO @Id_Producto,@Cod_UnidadMedida,@Cod_Almacen,@Despachado;
	END;
	CLOSE ComprobanteD;
	DEALLOCATE ComprobanteD;

	--Actualizamos la informacion en comprobante pago
	UPDATE dbo.CAJ_COMPROBANTE_PAGO
	SET	
	dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado=1,
	dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante='REC',
	dbo.CAJ_COMPROBANTE_PAGO.Impuesto=0,
	dbo.CAJ_COMPROBANTE_PAGO.Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total=0,
	dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos=0,
	dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos=0,
	dbo.CAJ_COMPROBANTE_PAGO.MotivoAnulacion=@Justificacion
	WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@id_ComprobantePago

    --Actualizamos la informacion de los detalles
	UPDATE dbo.CAJ_COMPROBANTE_D
	SET	
	dbo.CAJ_COMPROBANTE_D.Cantidad=0,
	dbo.CAJ_COMPROBANTE_D.Despachado=0,
	dbo.CAJ_COMPROBANTE_D.Formalizado=0,
	dbo.CAJ_COMPROBANTE_D.Descuento=0,
	dbo.CAJ_COMPROBANTE_D.Sub_Total=0,
	dbo.CAJ_COMPROBANTE_D.IGV=0,
	dbo.CAJ_COMPROBANTE_D.ISC=0
	WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago=@id_ComprobantePago

	--Actualizamos la informacion de la forma de pago
	UPDATE dbo.CAJ_FORMA_PAGO
	SET
	dbo.CAJ_FORMA_PAGO.Monto = 0
	WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago=@id_ComprobantePago

	--Eliminamos todas las relaciones
	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (Id_ComprobanteRelacion = @id_ComprobantePago)
	DELETE FROM CAJ_COMPROBANTE_RELACION
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	--Eliminamos las licitaciones
	DELETE FROM PRI_LICITACIONES_M
	WHERE (id_ComprobantePago = @id_ComprobantePago)

	-- Eliminar las Serie que se colocaron
	DELETE FROM CAJ_SERIES
	WHERE (Id_Tabla = @id_ComprobantePago AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO')

	-- insertar elementos en un datos a ver que pasa
	SET @id_Fila = (SELECT ISNULL(COUNT(*)/9,1)+1 FROM PAR_FILA WHERE Cod_Tabla = '079')
	EXEC USP_PAR_FILA_G '079','001',@id_Fila,@Documento,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','002',@id_Fila,'CAJ_COMPROBANTE_PAGO',NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','003',@id_Fila,@Proveedor,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','004',@id_Fila,@Detalle,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','005',@id_Fila,NULL,NULL,NULL,@FechaEmision,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','006',@id_Fila,NULL,NULL,NULL,@FechaActual,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','007',@id_Fila,@CodUsuario,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','008',@id_Fila,@Justificacion,NULL,NULL,NULL,NULL,1,'MIGRACION';
	EXEC USP_PAR_FILA_G '079','009',@id_Fila,NULL,NULL,NULL,NULL,1,1,'MIGRACION';	
END
go





--actualiza todos los documentos rechazados
DECLARE @id_ComprobantePago INT
DECLARE product_cursor CURSOR FOR   
SELECT ccp.id_ComprobantePago FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Cod_EstadoComprobante='REC' AND ccp.Cod_Libro=14 

OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago 
WHILE @@FETCH_STATUS = 0  
BEGIN  
	EXEC USP_CAJ_COMPROBANTE_PAGO_DarBaja @id_ComprobantePago,'ADMINISTRADOR','ENVIO SUNAT'
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago 
END  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO


--Para empresdas gravadas
--Actualiza el campo de detalles del tipo de IGV con 10 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=10 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRA'
----Actualiza el campo de detalles del tipo de IGV con 13 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=13 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE  (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRT'

--Para empresdas exoneradas
--Actualiza el campo de detalles del tipo de IGV con 20 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=20 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRA'
--Actualiza el campo de detalles del tipo de IGV con 13 en ccualquier comprobante 
UPDATE dbo.CAJ_COMPROBANTE_D
SET dbo.CAJ_COMPROBANTE_D.Cod_TipoIGV=21 FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE  (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='') AND ccp.Cod_Libro=14  AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccd.Tipo='GRT'



--Actualiza la informacion de las cabezeras y los detalles
update dbo.CAJ_COMPROBANTE_D
SET
    dbo.CAJ_COMPROBANTE_D.Sub_Total = ROUND(ccd.Cantidad*ccd.PrecioUnitario,2),
	dbo.CAJ_COMPROBANTE_D.IGV=CASE WHEN ccd.Cod_TipoIGV=10 THEN 
	ROUND(ROUND(ccd.Cantidad*ccd.PrecioUnitario,2)/1.18*0.18,2) ELSE 0 END
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE  ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14 AND 
(ccd.Sub_Total<> ROUND(ccd.Cantidad*ccd.PrecioUnitario,2) OR ccd.IGV= CASE WHEN ccd.Cod_TipoIGV=10 then
round(ROUND(ccd.Cantidad * ccd.PrecioUnitario, 2)/1.18*0.18,2)
ELSE 0 END)
-- recorrer todos los comprobantes con errores y corregir
GO
DECLARE @id_ComprobantePago INT, @IGV numeric(38,2), @CTotal AS NUMERIC(38,2)
DECLARE product_cursor CURSOR FOR   
SELECT        p.id_ComprobantePago, SUM(d.IGV) AS IGV, SUM(d.Sub_Total) AS CTotal
FROM            CAJ_COMPROBANTE_D AS d INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS p ON d.id_ComprobantePago = p.id_ComprobantePago
WHERE        (p.Cod_TipoComprobante IN ('FE', 'BE', 'NCE','NDE')) AND (p.Cod_EstadoComprobante  IN ('INI', 'EMI')) AND (p.Cod_Libro = '14')
GROUP BY p.id_ComprobantePago, p.Cod_EstadoComprobante, p.Cod_TipoComprobante, p.Serie, p.Numero, p.Nom_Cliente
HAVING        (AVG(p.Total) <> ROUND(SUM(d.Sub_Total), 2))
OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
   -- Actualizar los totaltes y el igv
	update CAJ_COMPROBANTE_PAGO set Total = @CTotal, Impuesto = @IGV
	where id_ComprobantePago =   @id_ComprobantePago        
  -- actualizar las formas de pago
  update CAJ_FORMA_PAGO SET Monto = @CTotal
  where id_ComprobantePago =   @id_ComprobantePago and Cod_TipoFormaPago IN ('008','005','006')
      
FETCH NEXT FROM product_cursor INTO @id_ComprobantePago  , @IGV, @CTotal  
END  
  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO




DECLARE @FechaEmision varchar(20)='2017-01-01'

SET DATEFORMAT dmy


SELECT ccp.Serie,ccp.Numero,ccp.Doc_Cliente,ccp.Nom_Cliente,ccp.Cod_Caja,ccp.Cod_Turno,ccp.FechaEmision from dbo.CAJ_COMPROBANTE_PAGO ccp
INNER JOIN (
SELECT ccp.Id_Cliente,count(*) AS Total
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_TipoComprobante='BE' AND ccp.Cod_Libro=14 AND convert(datetime,CONVERT(VARCHAR,ccp.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@FechaEmision,103)) 
GROUP BY ccp.Id_Cliente
HAVING COUNT(*) >1
)
AS cci ON ccp.Id_Cliente=cci.Id_Cliente AND convert(datetime,CONVERT(VARCHAR,ccp.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@FechaEmision,103))  
AND ccp.Cod_TipoComprobante='BE'




SET DATEFORMAT dmy
DECLARE @FechaEmision varchar(20)='19-03-2017'
SELECT ccp.Serie,ccp.Numero,ccp.Doc_Cliente,ccp.Nom_Cliente,ccp.Cod_Caja,ccp.Cod_Turno,ccp.FechaEmision from dbo.CAJ_COMPROBANTE_PAGO ccp
INNER JOIN (
SELECT ccp.Id_Cliente,count(*) AS Total
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_TipoComprobante='TKB' 
AND ccp.Cod_Libro=14 
AND convert(datetime,CONVERT(VARCHAR,ccp.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@FechaEmision,103)) 
AND ccp.Flag_Anulado=0
GROUP BY ccp.Id_Cliente
HAVING COUNT(*) >1
)
cci ON ccp.Id_Cliente=cci.Id_Cliente 
INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago=ccd.id_ComprobantePago
--INNER JOIN dbo.PRI_PRODUCTOS pp ON ccd.Id_Producto=pp.Id_Producto
where convert(datetime,CONVERT(VARCHAR,ccp.FechaEmision,103)) = convert(datetime,CONVERT(VARCHAR,@FechaEmision,103))  
AND ccp.Cod_TipoComprobante='TKB' 
AND ccd.Id_Producto IN (SELECT pp.Id_Producto from dbo.PRI_PRODUCTOS pp WHERE pp.Cod_Producto IN ('B5','G84','G90'))
AND ccp.Flag_Anulado=0
