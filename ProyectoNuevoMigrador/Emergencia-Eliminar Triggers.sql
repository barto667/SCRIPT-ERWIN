IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_ALMACEN_MOV_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_ALMACEN_MOV_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_INVENTARIO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_INVENTARIO_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_ALM_INVENTARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_ALM_INVENTARIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_BAN_CUENTA_BANCARIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_BAN_CUENTA_BANCARIA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_BAN_CUENTA_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_BAN_CUENTA_M_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_ARQUEOFISICO_SALDO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_ARQUEOFISICO_SALDO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJA_ALMACEN_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJA_ALMACEN_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJA_MOVIMIENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJA_MOVIMIENTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJAS_DOC_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJAS_DOC_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CAJAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CAJAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_LOG_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_LOG_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_PAGO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_PAGO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_COMPROBANTE_RELACION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_COMPROBANTE_RELACION_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_CONCEPTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_CONCEPTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_FORMA_PAGO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_FORMA_PAGO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_GUIA_REMISION_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_GUIA_REMISION_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_GUIA_REMISION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_GUIA_REMISION_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_IMPUESTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_IMPUESTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_MEDICION_VC_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_MEDICION_VC_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_SERIES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_SERIES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TIPOCAMBIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TIPOCAMBIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TRANSFERENCIAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TRANSFERENCIAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAJ_TURNO_ATENCION_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAJ_TURNO_ATENCION_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAL_CALENDARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAL_CALENDARIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CAL_DOCUMENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CAL_DOCUMENTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_ASIENTO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_ASIENTO_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_ASIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_ASIENTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_ASIENTO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_ASIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_ASIENTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CON_PLANTILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CON_PLANTILLA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_CLIENTE_CUENTA_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_CLIENTE_CUENTA_M_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_CUE_TARJETAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_CUE_TARJETAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_COLUMNA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_COLUMNA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_FILA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_FILA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAR_TABLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAR_TABLA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_CARACTERISTICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_CARACTERISTICAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_BIENES_MOVIMIENTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_BIENES_MOVIMIENTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_GRUPOS_CARACTERISTICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_GRUPOS_CARACTERISTICAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PAT_GRUPOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PAT_GRUPOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_AFP_PRIMA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_AFP_PRIMA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_ASISTENCIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_ASISTENCIA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_BIOMETRICO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_BIOMETRICO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_BOLETA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_BOLETA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_CONCEPTOS_PLANILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_CONCEPTOS_PLANILLA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_CONTRATOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_CONTRATOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_HORARIOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_HORARIOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PERSONAL_HORARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PERSONAL_HORARIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PLA_PLANILLA_TIPO_PERSONAL_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_ACTIVIDADES_ECONOMICAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_AREAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_AREAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CATEGORIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CATEGORIA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_CONTACTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_CONTACTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_CUENTABANCARIA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_CUENTABANCARIA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_PRODUCTO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_PRODUCTO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_PROVEEDOR_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_PROVEEDOR_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_VEHICULOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_VEHICULOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CLIENTE_VISITAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CLIENTE_VISITAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_CUENTA_CONTABLE_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_CUENTA_CONTABLE_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_DESCUENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_DESCUENTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_EMPRESA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_EMPRESA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_ESTABLECIMIENTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_ESTABLECIMIENTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_LICITACIONES_M_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_LICITACIONES_M_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_MENSAJES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_MENSAJES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_MODULO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_MODULO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PADRONES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PADRONES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERFIL_D_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERFIL_D_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERFIL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERFIL_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERSONAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERSONAL_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PERSONAL_PARENTESCO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PERSONAL_PARENTESCO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_DETALLE_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_DETALLE_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_IMAGEN_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_IMAGEN_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_PRECIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_PRECIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_STOCK_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_STOCK_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTO_TASA_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTO_TASA_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_PRODUCTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_PRODUCTOS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_SUCURSAL_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_SUCURSAL_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_PRI_USUARIO_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_PRI_USUARIO_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_ACTIVIDADES_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_ACTIVIDADES_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_ALERTAS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_ALERTAS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_CRONOMETROS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_CRONOMETROS_IUD
IF EXISTS (SELECT name  FROM   sysobjects WHERE  name ='UTR_TAR_PROYECTOS_IUD' AND 	  type = 'TR') DROP TRIGGER UTR_TAR_PROYECTOS_I