-- GUARDAR Caja Producto
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_RESUMEN_DIARIO_G' AND type = 'P')
DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_G
go
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_G
@Cod_Caja varchar(32),
@Id_Producto INT,
@Cod_Almacen varchar(32),
@Cod_UnidadMedida varchar(32),
@Cod_Precio varchar(16)
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro AS INT;

IF NOT EXISTS (SELECT Nro FROM USP_VIS_RESUMEN_DIARIO_G WHERE  (Cod_Caja = @Cod_Caja AND Id_Producto = @Id_Producto))
BEGIN
-- Calcular el ultimo el elemento ingresado para este tabla
SET @Nro = (SELECT ISNULL(MAX(Nro),0) + 1 FROM USP_VIS_RESUMEN_DIARIO_G)
EXEC USP_PAR_FILA_G '115','001',@Nro,@Cod_Caja,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '115','002',@Nro,NULL,@Id_Producto,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '115','003',@Nro,@Cod_Almacen,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '115','004',@Nro,@Cod_UnidadMedida,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '115','005',@Nro,@Cod_Precio,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '115','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
ELSE
BEGIN
SET @Nro = (SELECT Nro FROM VIS_CAJA_PRODUCTOS WHERE  (Cod_Caja = @Cod_Caja AND Id_Producto = @Id_Producto))
EXEC USP_PAR_FILA_G '114','001',@Nro,@Cod_Caja,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '114','002',@Nro,NULL,@Id_Producto,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '114','003',@Nro,@Cod_Almacen,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '114','004',@Nro,@Cod_UnidadMedida,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '114','005',@Nro,@Cod_Precio,NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '114','006',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
END
END
go


-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_CAJA_PRODUCTO_E' AND type = 'P')
DROP PROCEDURE USP_VIS_CAJA_PRODUCTO_E
go
CREATE PROCEDURE USP_VIS_CAJA_PRODUCTO_E
@Cod_Caja varchar(32),
@Id_Producto int
WITH ENCRYPTION
AS
BEGIN
DECLARE @Nro int;
SET @Nro = (SELECT Nro FROM VIS_CAJA_PRODUCTOS WHERE  (Cod_Caja = @Cod_Caja AND Id_Producto = @Id_Producto))
EXEC USP_PAR_FILA_E '114','001',@Nro;
EXEC USP_PAR_FILA_E '114','002',@Nro;
EXEC USP_PAR_FILA_E '114','003',@Nro;
EXEC USP_PAR_FILA_E '114','004',@Nro;
EXEC USP_PAR_FILA_E '114','005',@Nro;
EXEC USP_PAR_FILA_E '114','006',@Nro;
END
go


EXEC USP_PAR_TABLA_G '115','RESUMEN_DIARIO','Almacena los tickets diario de la facturacion lectronica.','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','001','Fecha','Fecha de la generacion del envio','CADENA',0,16,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','002','Serie','la Fecha del cual se emite','CADENA',0,16,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','003','Numero','Numero de envio de a','CADENA',0,8,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','004','Ticket','almacen los ticket de su comproanna','CADENA',0,34,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','005','Cod_Error','Codigo ','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','006','Mensaje_Error','La descripcion del error','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','007','Nom_Estado','La descripcion de la Cata.','CADENA',0,33,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','008','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '115';


select * from CAJ_COMPROBANTE_PAGO as CP 
inner join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago
where Serie='B001' and Numero>'00000192' and Numero<'00000632' order by CD.Cod_TipoIGV DESC




SET DATEFORMAT DMY;
SELECT CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)),
       COUNT(*)
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) IN
(
    SELECT DISTINCT
           CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103))
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp
    WHERE ccp.Cod_TipoComprobante IN('BE', 'NCE', 'NDE')
    AND ccp.Serie LIKE 'B%'
)
AND ccp.Cod_Libro = 14
AND ccp.Cod_TipoComprobante IN('BE', 'NCE', 'NDE')
AND ccp.Serie LIKE 'B%'
GROUP BY CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)); 

--exec USP_CAJ_COMPROBANTE_PAGO_GenerarResumenDiarioDetallado '11-09-2017'
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_GenerarResumenDiarioDetallado'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenDiarioDetallado;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_GenerarResumenDiarioDetallado @Fecha DATETIME
WITH ENCRYPTION
AS
         BEGIN
             SET DATEFORMAT DMY;
--DECLARE @Fecha DATETIME= '11-09-2017';
             SELECT vtc.Cod_Sunat,
                    ccp.Serie+'-'+ccp.Numero SerieNumero,
                    ccp.Cod_TipoDoc,
                    ccp.Doc_Cliente,
                    CASE
                        WHEN ccp.Cod_TipoComprobante = 'BE'
                        THEN 0
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
    SELECT ccp2.Serie+'-'+ccp2.Numero
    FROM dbo.CAJ_COMPROBANTE_PAGO ccp2
    WHERE ccp2.id_ComprobantePago = ccp.id_ComprobanteRef
)
                    END SerieNumeroDocumentoAfectado,	
	  --CASE WHEN ccp.Cod_RegimenPercepcion IS NULL THEN '' ELSE ccp.Cod_RegimenPercepcion END Cod_RegimenPercepcion,
                    '' RegimenPercepcion,
                    0.00 TasaPercepcion,
                    0.00 MontoPercepcion,
                    0.00 MontoTotalPercepcion,
                    0.00 MontoBasePercepcion,
                    '1' EstadoItem,
                    ABS(ROUND(SUM(ccd.Cantidad * ccd.PrecioUnitario), 2)) ImporteTotal,
                    ABS(SUM(CASE
                                WHEN ccd.Cod_TipoIGV IN('10', '17')
                                THEN ccd.Sub_Total - ccd.IGV - ccd.ISC
                                ELSE 0
                            END)) AS SumaGravadas,
                    ABS(SUM(CASE
                                WHEN ccd.Cod_TipoIGV IN('20')
                                THEN ccd.Sub_Total
                                ELSE 0
                            END)) SumaExoneradas,
                    ABS(SUM(CASE
                                WHEN ccd.Cod_TipoIGV IN('30','40')
                                THEN ccd.Sub_Total
                                ELSE 0
                            END)) SumaInafectas,
                    ABS(SUM(CASE
                                WHEN ccd.Cod_TipoIGV IN('11','12','13','14','15','16','21','31','32','33','34','35','36')
                                THEN ccd.Sub_Total
                                ELSE 0
                            END)) SumaGratuitas,
                    ABS(AVG(ccp.Otros_Cargos)) Otros_Cargos,
                    ABS(SUM(ccd.ISC)) ISC,
                    ABS(SUM(ccd.IGV)) IGV,
                    ABS(AVG(ccp.Otros_Tributos)) Otros_Tributos
             FROM dbo.CAJ_COMPROBANTE_PAGO ccp
                  INNER JOIN dbo.VIS_TIPO_COMPROBANTES vtc ON vtc.Cod_TipoComprobante = ccp.Cod_TipoComprobante
                  INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
             WHERE ccp.Cod_TipoComprobante IN('BE', 'NCE', 'NDE')
                  AND ccp.Serie LIKE 'B%'
                  AND ccp.Cod_Libro = 14
                  AND CONVERT(DATETIME, CONVERT(VARCHAR, ccp.FechaEmision, 103)) = CONVERT(DATETIME, CONVERT(VARCHAR, @Fecha, 103))
             GROUP BY ccp.id_ComprobantePago,
                      vtc.Cod_Sunat,
                      ccp.Serie,
                      ccp.Numero,
                      ccp.Cod_TipoDoc,
                      ccp.Doc_Cliente,
                      ccp.id_ComprobanteRef,
                      ccp.Cod_TipoComprobante;
         END;