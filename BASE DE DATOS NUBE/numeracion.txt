-- Corregir la numeracion de datos 
DECLARE @Cod_TipoComprobante AS VARCHAR(5),
		@serie AS VARCHAR(5);

SET @Cod_TipoComprobante = 'NP'
SET @serie = '0002';
DECLARE @id_ComprobantePago int,
@numero int
SET @numero = '00000001';
--SET @numero = (SELECT MIN(CONVERT(INT, NUMERO)) FROM CAJ_COMPROBANTE_PAGO WHERE cod_libro ='14' and Cod_TipoComprobante = @Cod_TipoComprobante and serie = @serie)

DECLARE Medicion_cursor CURSOR FOR 
SELECT        id_ComprobantePago
FROM            CAJ_COMPROBANTE_PAGO
where cod_libro ='14' and Cod_TipoComprobante = @Cod_TipoComprobante and serie = @serie --and id_ComprobantePago >73750
ORDER BY Fecha_Reg ASC
-- 0002 TKF
OPEN Medicion_cursor

FETCH NEXT FROM Medicion_cursor 
INTO 		@id_ComprobantePago

WHILE @@FETCH_STATUS = 0
BEGIN   
	-- actualizar todo de nuevo
	UPDATE CAJ_COMPROBANTE_PAGO SET NUMERO = RIGHT('00000000'+CONVERT( varchar(38), @numero,0), 8)
	WHERE id_ComprobantePago = @id_ComprobantePago
	SET @numero += 1;

	FETCH NEXT FROM Medicion_cursor 
	INTO @id_ComprobantePago
END 
CLOSE Medicion_cursor;
DEALLOCATE Medicion_cursor;
