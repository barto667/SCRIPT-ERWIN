IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_Verificar_ComprobantesXEnviar' AND type = 'P')
DROP PROCEDURE USP_Verificar_ComprobantesXEnviar
go
CREATE PROCEDURE USP_Verificar_ComprobantesXEnviar
WITH ENCRYPTION
AS
BEGIN
	--Creamos la tabla resultado
	   IF OBJECT_ID('tempdb..#tempTablaResultado') IS NOT NULL
		  BEGIN
			 DROP TABLE dbo.#tempTablaResultado;
	   END

	   CREATE TABLE #tempTablaResultado
	   (Numero        INT IDENTITY(1, 1) NOT NULL,
	    CodigoError   VARCHAR(MAX),
	    Descripcion   VARCHAR(MAX),
	    IdComprobante INT,
	    Detalle       VARCHAR(MAX)
	   )
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
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
				   CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			 FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			 WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
			 AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			 AND ccp.Cod_Libro = '14'
			 AND ccp.Flag_Anulado = 0
			 AND (ccp.Id_Cliente IS NULL
				 OR ccp.Doc_Cliente IS NULL
				 OR LEN(REPLACE(ccp.Doc_Cliente, ' ', '')) = 0
				 OR ccp.Nom_Cliente IS NULL
				 OR LEN(REPLACE(ccp.Nom_Cliente, ' ', '')) = 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
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
					    OR LEN(REPLACE(ccp.Direccion_Cliente, ' ', '')) = 0)))
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NCE', 'NDE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccd.Cod_TipoIGV IS NULL
				OR LEN(REPLACE(ccd.Cod_TipoIGV, ' ', '')) = 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('FE', 'BE', 'NDE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccp.Total < 0
				OR ccd.Sub_Total < 0
				OR ccp.Impuesto < 0
				OR ccd.IGV < 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('NCE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccp.Total > 0
				OR ccd.Sub_Total > 0
				OR ccp.Impuesto > 0
				OR ccd.IGV > 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			WHERE ccp.Cod_TipoComprobante IN('NCE')
			AND ccp.Cod_Libro = '14'
			AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccp.Cod_TipoOperacion NOT IN('01', '02', '03', '04', '05', '06', '07', '08', '09', '10')
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			WHERE ccp.Cod_TipoComprobante IN('NDE')
			AND ccp.Cod_Libro = '14'
			AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccp.Cod_TipoOperacion NOT IN('01', '02', '03')
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			WHERE ccp.Cod_TipoComprobante IN('FE')
			AND ccp.Cod_Libro = '14'
			AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccp.Serie NOT LIKE 'F%'
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			WHERE ccp.Cod_TipoComprobante IN('BE')
			AND ccp.Cod_Libro = '14'
			AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccp.Serie NOT LIKE 'B%'
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
			WHERE ccp.Cod_TipoComprobante IN('NCE', 'NDE')
			AND ccp.Cod_Libro = '14'
			AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccp.id_ComprobanteRef = 0
				OR ccp.id_ComprobanteRef IS NULL)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccd.Descripcion IS NULL
				OR LEN(REPLACE(ccd.Descripcion, ' ', '')) = 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND (ccd.Cantidad IS NULL
				OR ccd.Cantidad = 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('BE', 'FE', 'NCE', 'NDE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccd.Cod_TipoIGV IN('10', '11', '12', '13', '14', '15', '16', '17')
		  AND (ccd.Porcentaje_IGV IS NULL
		  OR ccd.Porcentaje_IGV = 0)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('FE')
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Cod_Libro = '14'
			AND ccp.Flag_Anulado = 0
			AND ccp.Cod_TipoOperacion = '02'
			AND (ccd.Cod_TipoIGV <> '40'
				OR ccd.Cod_TipoIGV IS NULL)
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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('FE', 'BE')
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Cod_Libro = '14'
			AND ccp.Flag_Anulado = 0
			AND ccp.Total > 0
			AND ccd.Sub_Total = 0  AND  ccd.Cod_TipoIGV IN (10,20)
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
	   DECLARE @tipoComprobante varchar(10)
	   DECLARE @SerieComprobante varchar(10)
	   DECLARE @Cod_TipoComprobante AS VARCHAR(5),
		  @serie AS VARCHAR(5),@Comprobante AS varchar(max);

	   DECLARE @id_ComprobantePago int,
	   @numero int
	   DECLARE @NumeroTabla varchar(10)
	   DECLARE @flag bit;

	   DECLARE CURSORCOMPROBANTES CURSOR FOR
	   SELECT DISTINCT ccp.Cod_TipoComprobante,ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp
	   WHERE ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE') AND ccp.Cod_Libro=14 
	   AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')

	   ORDER BY ccp.Cod_TipoComprobante,ccp.Serie
	   OPEN CURSORCOMPROBANTES
	   FETCH NEXT FROM CURSORCOMPROBANTES 
	   INTO @tipoComprobante,@SerieComprobante
	   WHILE @@FETCH_STATUS = 0
	   BEGIN   
		SET @Cod_TipoComprobante = @tipoComprobante
		SET @serie = @SerieComprobante
		DECLARE Medicion_cursor CURSOR FOR 
		SELECT        id_ComprobantePago,Numero
		FROM            CAJ_COMPROBANTE_PAGO
		where cod_libro ='14' and Cod_TipoComprobante = @Cod_TipoComprobante and serie = @serie --AND Flag_Anulado=0
		AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
		ORDER BY Numero DESC
		SET @flag=1
		SET @numero=(SELECT TOP 1 ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante=@Cod_TipoComprobante AND ccp.Serie=@serie AND ccp.cod_libro='14' ORDER BY ccp.Numero DESC)
		OPEN Medicion_cursor
		FETCH NEXT FROM Medicion_cursor 
		INTO    @id_ComprobantePago,@NumeroTabla
		WHILE @@FETCH_STATUS = 0 AND @flag=1
		BEGIN   
		  if(@numero<>CONVERT(int,@NumeroTabla))
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
				CONCAT((SELECT ccp2.Cod_TipoComprobante FROM dbo.CAJ_COMPROBANTE_PAGO ccp2 WHERE ccp2.id_ComprobantePago=@id_ComprobantePago),
				 '|',' ESTA : ', @serie +'-'+ CONVERT(varchar, @NumeroTabla), '|',' DEBE DE SER : ', @serie +'-'+CONVERT(varchar,@numero),'|',CONVERT(varchar,(SELECT ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@id_ComprobantePago)))

		    set @flag=0
		  END
		  SET @numero -= 1;

		  FETCH NEXT FROM Medicion_cursor 
		  INTO @id_ComprobantePago,@NumeroTabla
		END 
		CLOSE Medicion_cursor;
		DEALLOCATE Medicion_cursor;
  
		FETCH NEXT FROM CURSORCOMPROBANTES 
		INTO @tipoComprobante,@SerieComprobante
	   END 
	   CLOSE CURSORCOMPROBANTES;
	   DEALLOCATE CURSORCOMPROBANTES 


	   --Verifica posible incoherencias entre la fecha de emision y la numeracion
	   SET DATEFORMAT dmy;
	   DECLARE @CodTipoComprobante varchar(10)

	   DECLARE @FechaAnterior date ='01-01-1990 00:00:00:000';
	   DECLARE @IdComprobantePAgo int
	   DECLARE @CodAux varchar(10)
	   DECLARE @SerieAux varchar(10)
	   DECLARE @NumeroAux varchar(10)


	   DECLARE CURSORCOMPROBANTES CURSOR LOCAL FOR
	   SELECT DISTINCT ccp.Cod_TipoComprobante,ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp
	   WHERE ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE') AND ccp.Cod_Libro=14 
	   AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
	   AND ccp.cod_libro ='14' 
	   ORDER BY ccp.Cod_TipoComprobante,ccp.Serie
	   OPEN CURSORCOMPROBANTES
	   FETCH NEXT FROM CURSORCOMPROBANTES 
	   INTO @CodTipoComprobante,@SerieComprobante
	   WHILE @@FETCH_STATUS = 0
	   BEGIN   
     
		   DECLARE CURSORCOMPROBANTES2 CURSOR LOCAL FOR
		   SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
		   WHERE ccp.Cod_TipoComprobante =@CodTipoComprobante AND ccp.Serie=@SerieComprobante
		   AND ccp.Cod_Libro=14 
		   AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
		   ORDER BY ccp.Numero
		   OPEN CURSORCOMPROBANTES2
		   FETCH NEXT FROM CURSORCOMPROBANTES2
		   INTO @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaActual
		   WHILE @@FETCH_STATUS = 0
		   BEGIN   
			IF (@FechaAnterior> @FechaActual)
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
				CONCAT(@CodAux,
			   '|', @SerieAux +'-'+@NumeroAux , '|',' FECHA ANTERIOR : ' + CONVERT(varchar,@FechaAnterior) + ' - FECHA ACTUAL : '+CONVERT(varchar,@FechaActual))

			 --BREAK;
			 SET  @FechaAnterior  ='01-01-1990 00:00:00:000';
			END
			ELSE
			BEGIN
			 SET @FechaAnterior=@FechaActual
			END

			FETCH NEXT FROM CURSORCOMPROBANTES2 
			INTO  @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaActual
		   END 
		   CLOSE CURSORCOMPROBANTES2
		   DEALLOCATE CURSORCOMPROBANTES2

		SET  @FechaAnterior  ='01-01-1990 00:00:00:000';
		FETCH NEXT FROM CURSORCOMPROBANTES 
		INTO @CodTipoComprobante,@SerieComprobante
	   END 
	   CLOSE CURSORCOMPROBANTES;
	   DEALLOCATE CURSORCOMPROBANTES 

	   --Verifica que los documentos tengan detalles y las notas su relacion

	   DECLARE @Cod_TipocomprobanteR varchar(max)
	   DECLARE @SerieR varchar(max)
	   DECLARE @NumeroR varchar(max)

	   DECLARE @IdComprobante int,
	   @Detalle varchar(MAX),@Fecha date

	   DECLARE CursorFila CURSOR FOR
	   SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision  from dbo.CAJ_COMPROBANTE_PAGO ccp 
	   WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14 AND Flag_Anulado=0
	   AND ccp.Cod_EstadoComprobante IN ('INI','EMI')
	   --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
	   ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision

	   OPEN CursorFila

	   FETCH NEXT FROM CursorFila 
	   INTO    @IdComprobante,@Cod_TipocomprobanteR,@SerieR,@NumeroR,@Fecha

	   WHILE @@FETCH_STATUS = 0
	   BEGIN  
		SET @Detalle='' 
		--Verificamos que tenga detalles
		IF((SELECT COUNT(*) FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobante)=0)--Sin detalles
		BEGIN
		  SET @Detalle='No tiene detalles - ' 
		END

		--Verificamos que las notas tengan relacion
		IF((SELECT TOP 1 ccp.Cod_TipoComprobante from dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobante) IN ('NCE','NDE'))
		BEGIN
		  IF((SELECT COUNT(*) FROM dbo.CAJ_COMPROBANTE_RELACION ccr  WHERE ccr.id_ComprobantePago=@IdComprobante)=0)--Sin relacion
		  BEGIN
		    SET @Detalle=@Detalle+'No tiene relacion'
		  END
		END
		IF(@Detalle<>'')
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
				CONCAT(@Cod_TipocomprobanteR,
			   '|', @SerieR +'-'+@NumeroR , '|',@Detalle)

		END

		FETCH NEXT FROM CursorFila 
		INTO @IdComprobante,@Cod_TipocomprobanteR,@SerieR,@NumeroR,@Fecha
	   END 
	   CLOSE CursorFila;
	   DEALLOCATE CursorFila;


	   --Verifica cuantos documentos afectan las notas,

	   DECLARE @Id_ComprobanteRef int,@Conteo int
	   DECLARE @id_comprobante int,@serieN varchar(max),@Referenciados varchar(MAX)

	   DECLARE cursorfila CURSOR LOCAL FOR
	   select ccp.id_ComprobanteRef, count(ccp.id_ComprobanteRef) AS Conteo
	   from dbo.CAJ_COMPROBANTE_PAGO ccp
	   WHERE ccp.Cod_TipoComprobante='NCE' AND ccp.Cod_Libro=14 AND ccp.Flag_Anulado=0
	   AND ccp.Cod_EstadoComprobante IN ('INI','EMI')
	   --AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7
	   group by ccp.id_ComprobanteRef
	   having count(ccp.id_ComprobanteRef) > 1

	   OPEN cursorfila

	   FETCH NEXT FROM cursorfila INTO @Id_ComprobanteRef,@Conteo 

	   WHILE @@FETCH_STATUS = 0
	   BEGIN
		SET @id_comprobante=(SELECT TOP 1 ccp.id_ComprobantePago from dbo.CAJ_COMPROBANTE_PAGO ccp 
		WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
		SET @Cod_Tipocomprobante=(SELECT TOP 1 ccp.Cod_TipoComprobante from dbo.CAJ_COMPROBANTE_PAGO ccp 
		WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
		SET @serieN=(SELECT TOP 1 ccp.Serie from dbo.CAJ_COMPROBANTE_PAGO ccp 
		WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
		SET @numero=(SELECT TOP 1 ccp.Numero from dbo.CAJ_COMPROBANTE_PAGO ccp 
		WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
		SET @fecha=(SELECT TOP 1 ccp.FechaEmision from dbo.CAJ_COMPROBANTE_PAGO ccp 
		WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
		--Recupera los comprobantes que afectan a la nota
		SELECT @Referenciados= COALESCE(@Referenciados + ', ', '') + CONVERT(varchar(10),ccp.id_ComprobantePago) FROM CAJ_COMPROBANTE_PAGO ccp
		  WHERE ccp.id_ComprobanteRef=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante='NCE' AND ccp.Flag_Anulado=0
		  AND ccp.Cod_TipoOperacion='01'
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
				CONCAT(@Cod_Tipocomprobante,
			   '|', @serieN +'-'+CONVERT(varchar, @Numero) , '|','REFERENCIAS : ' + @Referenciados,'|',CONVERT(varchar,@fecha))


		SET @Referenciados = NULL
		FETCH NEXT FROM cursorfila INTO @Id_ComprobanteRef,@Conteo 
	   END
	   CLOSE cursorfila
	   DEALLOCATE cursorfila

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
				  CONCAT(ccp.Cod_TipoComprobante, '|', ccp.Serie+'-'+ccp.Numero, '|', ccp.FechaEmision)
			FROM dbo.CAJ_COMPROBANTE_PAGO ccp
				INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
			WHERE ccp.Cod_TipoComprobante IN('FE', 'BE')
				AND ccp.Cod_Libro = '14'
				AND ccp.Cod_EstadoComprobante IN('INI', 'EMI')
			AND ccp.Flag_Anulado = 0
			AND ccd.Cod_TipoIGV IN ('10','20','40') AND ccd.PrecioUnitario=0
			--AND DATEDIFF(DAY, CONVERT(DATETIME, CONVERT(VARCHAR(10), ccp.FechaEmision, 103)), CONVERT(DATETIME, CONVERT(VARCHAR(10), @FEchaActual, 103))) <= 7;

	   --Mostramos resultados

	   SELECT ttr.*
	   FROM #tempTablaResultado ttr
	   ORDER BY ttr.Numero;
END
go