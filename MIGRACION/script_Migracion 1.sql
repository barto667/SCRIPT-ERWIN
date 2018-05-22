SET DATEFORMAT dmy;
GO
EXEC USP_PAR_TABLA_G '088','MOTIVO_EMISION','Almacena los motivos de emision de Notas de Debito o Credito','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '088','001','Cod_MotivoEmision','Código del Motivo de Emision','CADENA',0,3,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '088','002','Nom_MotivoEmision','Nombre del Motivo de Emision','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '088','003','Tipo_MotivoEmision','Tipo del Motivo de Emision, NC Nota de Credito: ND Nota de Debito','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '088','004','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',3,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',4,'04',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',5,'05',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',6,'06',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',7,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',8,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',9,'09',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',10,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','001',11,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',1,'ANULACIÓN DE LA OPERACIÓN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',2,'ANULACIÓN POR ERROR EN EL RUC ',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',3,'CORRECCIÓN POR ERROR EN LA DESCRIPCIÓN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',4,'DESCUENTO GLOBAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',5,'DESCUENTO POR ITEM ',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',6,'DEVOLUCIÓN TOTAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',7,'DEVOLUCIÓN POR ITEM',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',8,'BONIFICACIÓN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',9,'DISMINUCIÓN EN EL VALOR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',10,'INTERESES POR MORA ',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','002',11,'AUMENTO EN EL VALOR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',1,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',2,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',3,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',4,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',5,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',6,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',7,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',8,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',9,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',10,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','003',11,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '088','004',11,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '088';
GO
EXEC USP_PAR_TABLA_G'104','SISTEMA_ISC','Almacena codigos de tipos de sistema de calculo ISC','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'104','001','Cod_SistemaISC','Código del tipo de sistema ISC','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'104','002','Nom_SistemaISC','Nombre del tipo de sistema ISC','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'104','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'104','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','001',3,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','002',1,'SISTEMA AL VALOR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','002',2,'APLICACIÓN D EMONTO FIJO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','002',3,'SISTEMA DE PRECIOS DE VENTA AL PUBLICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'104','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'104';
GO

EXEC USP_PAR_TABLA_G'105','DOCUMENTOS_RELACIONADOS','Almacena codigos de documentos relacionados','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'105','001','Cod_DocRelacionado','Codigo Documento Relacionado','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'105','002','Nom_DocRelacionado','Nombre Documento Relacionado','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'105','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',1,'04',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',2,'05',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',3,'99',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',4,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',5,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','001',6,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',1,'TICKET DE SALIDA-ENAPU',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',2,'CODIGO SCOP',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',3,'OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',4,'FACTURA-EMITIDA PARA CORREGIR ERROR EN EL RUC',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',5,'FACTURA-EMITIDA POR ANTICIPOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','002',6,'BOLETA D EVENTA-EMITIDA POR ANTICIPOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'105','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'105';
GO

EXEC USP_PAR_TABLA_G'106','TIPO_OPERACION_GUIA','Tipo de operacion en factura-guia de remision','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'106','001','Cod_TipoOperacion','Codigo de tipo de operacion','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'106','002','Nom_TipoOperacion','Nombre de tipo de operacion','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'106','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',3,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',4,'04',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',5,'05',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',6,'06',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',7,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',8,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',9,'09',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','001',10,'10',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',1,'VENTA INTERNA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',2,'EXPORTACION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',3,'NO DOMICILIADOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',4,'VENTA INTERNA-ANTICIPOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',5,'VENTA ITINERANTE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',6,'FACTURA GUIA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',7,'VENTA ARROZ PILADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',8,'FACTURA-COMPROBANTE DE PERCEPCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',9,'FACTURA-GUIA REMITENTE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','002',10,'FACTURA-GUIA TRANSPORTISTA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'106','003',10,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'106';
GO

EXEC USP_PAR_TABLA_G'107','MODALIDAD_TRASLADO','Modalidad detraslado en guia de remision','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'107','001','Cod_ModTraslado','Codigo de modalidad de traslado','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'107','002','Nom_ModTraslado','Nombre demodalidad de traslado','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'107','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'107','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'107','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'107','002',1,'TRANSPORTE PUBLICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'107','002',2,'TRANSPORTE PRIVADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'107','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'107','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'107';
GO

EXEC USP_PAR_TABLA_G'108','DOCUMENTOS_RELACIONADOS_GUIA','Documentos relacionados de la guia de remision','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'108','001','Cod_DocRelacionado','Codigo de documento relacionado de la guia','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'108','002','Nom_DocRelacionado','Nombre de documento relacionado de la guia','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'108','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',3,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',4,'04',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',5,'05',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','001',6,'06',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',1,'NUMERACION DAM',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',2,'NUMERO DE ORDEN DE ENTREGA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',3,'NUMERO SCOP',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',4,'NUMERO DE MANIFIESTO DE CARGA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',5,'NUMERO DE CONSTANCIA DE DETRACCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','002',6,'OTROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'108','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'108';
GO

EXEC USP_PAR_TABLA_G'109','REGIMEN_CONTABLE','Regimen contable para comprobante de percepcion y retencion','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'109','001','Cod_Regimen','Codigo de documento relacionado de la guia','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'109','002','Nom_Regimen','Nombre de documento relacionado de la guia','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'109','003','Tasa_Regimen','Tasa del regimen','NUMERO',0,2,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'109','004','Nom_Comprobante','Nombre de comprobante','CADENA',0,16,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'109','005','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'109','001',1,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','001',2,'02',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','001',3,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','001',4,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','002',1,'PERCEPCION VENTA INTERNA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','002',2,'PERCEPCION ALA ADQUISICION DE COMBUSTIBLE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','002',3,'PERCEPCION REALIZADA ALA GENTE DE PERCEPCION CON TASA ESPECIAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','002',4,'RETENCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','003',1,'2.00',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','003',2,'1.00',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','003',3,'0.50',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','003',4,'3.00',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','004',1,'PERCEPCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','004',2,'PERCEPCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','004',3,'PERCEPCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','004',4,'RETENCION',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','005',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','005',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','005',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'109','005',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'109';
GO

EXEC USP_PAR_TABLA_G'110','CODIGO_ESTADO_RESUMEN','Codigo de estado del resumen diario','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'110','001','Cod_Estado','Codigo de estado del resumen','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'110','002','Nom_Estado','Nombre de estado del resumen','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G'110','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G'110','001',1,'1',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','001',2,'2',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','001',3,'3',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','001',4,'4',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','002',1,'ADICIONAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','002',2,'MODIFICAR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','002',3,'ANULADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','002',4,'ANULADO EN EL DIA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G'110','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'110';
GO



EXEC USP_PAR_TABLA_G '111','ESTADO_COMPROBANTE','Codigo de estado del resumen diario','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '111','001','Cod_EstadoComprobante','Codigo de estado del resumen','CADENA',0,4,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '111','002','Nom_EstadoComprobante','Nombre de estado del resumen','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '111','003','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',1,'INI',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',2,'EMI',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',3,'ENS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',4,'REC',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',5,'ACS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',6,'ENB',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',7,'ENF',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',8,'ENE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','001',9,'FIN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',1,'INICIADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',2,'EMITIDO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',3,'ENVIADO SUNAT',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',4,'RECHAZADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',5,'ACEPTADO SUNAT',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',6,'ENVIADO BD',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',7,'ENVIADO FTP',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',8,'ENVIADO EMAIL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','002',9,'FINALIZADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',6,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',7,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',8,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '111','003',9,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS'111';
GO

EXEC USP_PAR_TABLA_G '112','DIRECTORIO','Almacen los certificados','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','001','Cod_Directorio','Codigo del Directorio','CADENA',0,32,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','002','Carpeta','Carpeta','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','003','FTP','Direccion del FTP','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','004','Usuario','Usuario FTP','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','005','Contraseña','Contraseña','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '112','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G '112','001',1,'XML',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','001',2,'CDR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','001',3,'PDF',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','001',4,'CER',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','001',5,'SER_XML',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','002',1,'C:\APLICACIONES\XML',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','002',2,'C:\APLICACIONES\CDR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','002',3,'C:\APLICACIONES\PDF',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','002',4,'C:\APLICACIONES\CERTIFICADO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','002',5,'\\192.168.1.254\SUNAT\XML',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','003',1,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','003',2,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','003',3,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','003',4,'ftp://ftp.palerp.com/',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','003',5,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','004',1,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','004',2,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','004',3,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','004',4,'facemusica',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','004',5,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','005',1,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','005',2,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','005',3,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','005',4,'paleC0nsult0r',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','005',5,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','006',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','006',2,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','006',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','006',4,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '112','006',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';

EXEC USP_PAR_TABLA_GENERADOR_VISTAS '112';
GO

EXEC USP_PAR_TABLA_G '113','CERTIFICADOS','Almacen los certificados','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','001','Cod_Certificado','Codigo del certificado','CADENA',0,32,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','002','Nom_Certificado','Nombre del certificado','CADENA',0,1024,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','003','Fecha_Inicio','Fecha de Inicio','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','004','Fecha_Fin','Fecha de Finalizacion','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','005','Contrasena','Contraseña','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '113','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '113';
GO

EXEC USP_PAR_TABLA_G '083','PRECIOS','Almacena las descripcion de los precios','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','001','Cod_Precio','Código de precio','CADENA',0,8,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','002','Nom_Precio','Nombre de precio','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','003','Cod_Categoria','Código de categoria','CADENA',0,32,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','004','Cod_PrecioPadre','Código de Precio Padre','CADENA',0,5,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','005','Orden','Orden','NUMERO',0,0,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '083','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G '083','001',1,'001',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '083','002',1,'GENERAL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '083','003',1,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '083','004',1,'',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '083','005',1,NULL,1,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '083','006',1,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '083';
-- intecambio de orden (Cod_precioAnterior, Cod_PrecioActual) restricion: tienes q ser del mismo padre
GO

-- Agregar los comprobantes electronicos
EXEC USP_PAR_FILA_G '005','001',41,'FE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','002',41,'FACTURA ELECTRONICA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','003',41,'01',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','004',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','005',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','006',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','007',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','008',41,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','001',42,'BE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','002',42,'BOLETA ELECTRONICA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','003',42,'03',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','004',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','005',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','006',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','007',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','008',42,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','001',43,'NCE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','002',43,'NOTA CREDITO ELECTRONICA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','003',43,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','004',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','005',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','006',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','007',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','008',43,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','001',44,'NDE',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','002',44,'NOTA DEBITO ELECTRONICA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','003',44,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','004',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','005',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','006',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','007',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '005','008',44,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
-- Agreagr
-- Agregar Favoritos para los productos
EXEC USP_PAR_TABLA_G '114','CAJA_PRODUCTOS','Almacen los productos favoritos de una caja','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','001','Cod_Caja','Codigo de la caja','CADENA',0,32,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','002','Id_Producto','id del producto','NUMERO',0,0,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','003','Cod_Almacen','Codigo de almacen','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','004','Cod_UnidadMedida','Codigo unidad de medida','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','005','Cod_Precio','Codigo del precio','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '114','006','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '114';
GO
EXEC USP_PAR_TABLA_G '023','UNIDADES_DE_MEDIDA','Almacena las Unidades de Medida.','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '023','001','Cod_UnidadMedida','Código de la Unidades de Medida','CADENA',0,3,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '023','002','Nom_UnidadMedida','Nombre de la Unidades de Medida','CADENA',0,512,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '023','003','Tipo','Tipo de la Unidades de Medida','CADENA',0,32,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '023','004','Cod_Sunat','Codigo Sunat de la Unidades de Medida','CADENA',0,33,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '023','005','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',1,'KGM',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',2,'GRM',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',3,'NIU',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',4,'LTR',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',5,'GLL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',6,'BLL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',7,'MLL',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',8,'MTK',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',9,'ME',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',10,'CO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',11,'VA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',12,'BO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','001',13,'CA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',1,'KILOGRAMOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',2,'GRAMOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',3,'UNIDADES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',4,'LITROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',5,'GALONES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',6,'BARRILES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',7,'MILLARES',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',8,'METROS CÚBICOS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',9,'METROS',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',10,'COJIN',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',11,'VARILLA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',12,'BOTELLA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','002',13,'CAJA',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',1,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',2,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',3,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',4,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',5,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',6,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',7,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',8,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',9,'BASICO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',10,'COMPUESTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',11,'COMPUESTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',12,'COMPUESTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','003',13,'COMPUESTO',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',1,'KMG',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',2,'GK',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',3,'07',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',4,'08',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',5,'09',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',6,'10',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',7,'11',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',8,'12',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',9,'13',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',10,'90',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',11,'91',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',12,'92',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','004',13,'93',NULL,NULL,NULL,NULL,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',1,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',2,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',3,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',4,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',5,NULL,NULL,NULL,NULL,1,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',6,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',7,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',8,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',9,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',10,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',11,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',12,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_FILA_G '023','005',13,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '023';

EXEC USP_PAR_TABLA_G '115','RESUMEN_DIARIO','Almacena los tickets diario de la facturacion lectronica.','001',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','001','Fecha_Serie','Fecha de la generacion del envio','CADENA',0,16,'',1,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','002','Numero','Numero de envio de a','CADENA',0,8,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','003','Ticket','almacen los ticket de su comproanna','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','004','Nom_Estado','La descripcion de la Cata.','CADENA',0,64,'',0,'MIGRACION';
EXEC USP_PAR_COLUMNA_G '115','005','Estado','Estado','BOLEANO',0,1,'',0,'MIGRACION';
EXEC USP_PAR_TABLA_GENERADOR_VISTAS '115';



-- GUARDAR Caja Producto
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_RESUMEN_DIARIO_G' AND type = 'P')
	DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_G
go
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_G 
	@Fecha_Serie	varchar(16), 
	@Numero	varchar(8), 
	@Ticket	varchar(64), 
	@Nom_Estado	varchar(64)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Nro AS INT;

IF NOT EXISTS (SELECT Nro FROM VIS_RESUMEN_DIARIO WHERE  (Fecha_Serie = @Fecha_Serie AND Numero = @Numero))
	BEGIN
	-- Calcular el ultimo el elemento ingresado para este tabla
		SET @Nro = (SELECT ISNULL(MAX(Nro),0) + 1 FROM VIS_RESUMEN_DIARIO)
		EXEC USP_PAR_FILA_G '115','001',@Nro,@Fecha_Serie,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','002',@Nro,@Numero,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','003',@Nro,@Ticket,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','004',@Nro,@Nom_Estado,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','005',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';		
	END
	ELSE
	BEGIN
		SET @Nro = (SELECT Nro FROM VIS_RESUMEN_DIARIO WHERE  (Fecha_Serie = @Fecha_Serie AND Numero = @Numero))
		EXEC USP_PAR_FILA_G '115','001',@Nro,@Fecha_Serie,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','002',@Nro,@Numero,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','003',@Nro,@Ticket,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','004',@Nro,@Nom_Estado,NULL,NULL,NULL,NULL,1,'MIGRACION';
		EXEC USP_PAR_FILA_G '115','005',@Nro,NULL,NULL,NULL,NULL,1,1,'MIGRACION';		
	END
END
go
-- Eliminar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_RESUMEN_DIARIO_E' AND type = 'P')
	DROP PROCEDURE USP_VIS_RESUMEN_DIARIO_E
go
CREATE PROCEDURE USP_VIS_RESUMEN_DIARIO_E 
	@Fecha_Serie	varchar(16),
	@Numero varchar(8)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Nro int;
	SET @Nro = (SELECT Nro FROM VIS_RESUMEN_DIARIO WHERE  (Fecha_Serie = @Fecha_Serie AND Numero = @Numero))
	EXEC USP_PAR_FILA_E '115','001',@Nro;
	EXEC USP_PAR_FILA_E '115','002',@Nro;
	EXEC USP_PAR_FILA_E '115','003',@Nro;
	EXEC USP_PAR_FILA_E '115','004',@Nro;
	EXEC USP_PAR_FILA_E '115','005',@Nro;	
END
go

