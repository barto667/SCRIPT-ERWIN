--Cambai el estado de todas las FE y notas a FIN
--update CAJ_COMPROBANTE_PAGO set Cod_EstadoComprobante='FIN' where Cod_EstadoComprobante='ENB'
--and Cod_Libro=14 and Serie like 'F%'

--VErifica si algun documento no fue enviado en el plazo de 7 dias
SET DATEFORMAT dmy
SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.Doc_Cliente,ccp.Nom_Cliente,ccp.Total,ccp.FechaEmision 
FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_EstadoComprobante NOT IN ('ACS','ENB','ENF','ENE','FIN','REC') 
AND ccp.Cod_TipoComprobante IN ('FE','NCE') AND ccp.Serie LIKE 'F%' AND ccp.Cod_Libro=14
AND DATEDIFF (DAY,convert(datetime,CONVERT(VARCHAR(10),ccp.FechaEmision,103)),convert(datetime,CONVERT(VARCHAR(10),GETDATE(),103)))>7

--Verifica los comprobantes no enviados
select * from CAJ_COMPROBANTE_PAGO where Cod_EstadoComprobante='FIN' and (Valor_Firma ='' or Valor_Resumen='') and Cod_TipoComprobante='FE' and Cod_Libro=14

--Verificar que no existan campos null en cod_IGV o tipo
SELECT distinct ccp.id_ComprobantePago,ccd.id_Detalle,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.Cod_TipoIGV,ccd.Tipo,ccp.FechaEmision 
FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
WHERE (ccd.Cod_TipoIGV IS NULL OR ccd.Cod_TipoIGV='' OR ccd.Tipo IS NULL OR ccd.Tipo='') AND ccp.Cod_Libro=14  
AND ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND Flag_Anulado=0
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,FechaEmision


--Verifica los tipos de documento, en este caso a boletas y facturas
select id_ComprobantePago,Cod_TipoComprobante,Serie,Numero,Cod_TipoDoc,Doc_Cliente,Nom_Cliente,Direccion_Cliente,FechaEmision
 from CAJ_COMPROBANTE_PAGO
 where Cod_TipoComprobante='FE' and (Cod_TipoDoc<>6 or LEN(Doc_Cliente)<>11 
 or LEN(REPLACE(Nom_Cliente,' ',''))=0  )
--OR (Cod_TipoComprobante='BE' and (Cod_TipoDoc=6 or LEN(Doc_Cliente)=11)))
 and Cod_Libro=14 and Flag_Anulado=0


--Verifica que no existan montos negativos
select * from CAJ_COMPROBANTE_PAGO ccp inner join CAJ_COMPROBANTE_D ccd on ccp.id_ComprobantePago=ccd.id_ComprobantePago
where ccp.Cod_TipoComprobante in ('FE','BE') and Cod_Libro=14 and (ccd.Sub_Total<0 or IGV<0)

--Para empresas afectadas por IGV
--Verificar los codigos de afecatcaion de igv de los comprobantes corresponden a los de los comprobantes,
--si los Tipos son gravados entonces solo pueden ser codigo 10 
-- si son gartuitas solo pueden ser codigos de 13 
SELECT distinct ccd.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,
pp.Nom_Producto,pp.Cod_TipoOperatividad,ccd.Tipo,ccd.Cod_TipoIGV,ccd.Sub_Total,ccd.IGV,ccp.FechaEmision
 FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto 
INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14 
 AND ccp.Flag_Anulado = 0 AND
(
(pp.Cod_TipoOperatividad='GRA' AND (ccd.Tipo<>'GRA' OR ccd.Cod_TipoIGV<>10  OR Sub_Total=0)) OR
(pp.Cod_TipoOperatividad='GRT' AND (ccd.Tipo<>'GRT' OR ccd.Cod_TipoIGV<>13 OR ccd.IGV<>0 OR ccd.Sub_Total<>0))
)
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,ccd.id_ComprobantePago


--Para empresas exoneradas  del IGV
--Verificar los codigos de afecatcaion de igv de los comprobantes corresponden a los de los comprobantes,
--si los Tipos son gravados entonces solo pueden ser codigo 20
-- si son gartuitas solo pueden ser codigos de 21

SELECT distinct ccd.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,
pp.Nom_Producto,pp.Cod_TipoOperatividad,ccd.Tipo,ccd.Cod_TipoIGV,ccd.Sub_Total,ccd.IGV,ccp.FechaEmision
 FROM dbo.PRI_PRODUCTOS pp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON pp.Id_Producto = ccd.Id_Producto 
INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON ccd.id_ComprobantePago = ccp.id_ComprobantePago
WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14
 AND ccp.Flag_Anulado = 0 AND
(
(pp.Cod_TipoOperatividad='GRA' AND (ccd.Tipo<>'GRA' OR ccd.Cod_TipoIGV<>20 OR ccd.IGV<>0 OR Sub_Total=0)) OR
(pp.Cod_TipoOperatividad='GRT' AND (ccd.Tipo<>'GRT' OR ccd.Cod_TipoIGV<>21 OR ccd.IGV<>0 OR ccd.Sub_Total<>0))
)
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccd.id_Detalle,ccd.id_ComprobantePago


--Verifica los posibles errores en nuemrcacion que puede haber
--SELECT        Cod_Libro, Cod_TipoComprobante, Serie, Min(Numero) as Minimo, Max(convert(int,numero)) as Maximo, count(*) as Total, 
--count(*) - Max(convert(int,numero)) - Min(convert(int,Numero)) + 1 as Error
--FROM            CAJ_COMPROBANTE_PAGO
--where Cod_Libro = '14' AND Cod_TipoComprobante IN ('BE','FE','NCE','NDE')-- AND Flag_Anulado=0
--group by Cod_Libro, Cod_TipoComprobante, Serie
--order by Cod_Libro, Cod_TipoComprobante, Serie



--Verifica los posibles errores en nuemrcacion que puede haber

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE dbo.#temp1
END
CREATE TABLE #temp1(id_Comprobante int, Serie varchar(10), Esta varchar(10),DebeSer varchar(10))
GO
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
	ORDER BY Numero ASC
	SET @flag=1
	SET @numero=1
	OPEN Medicion_cursor
	FETCH NEXT FROM Medicion_cursor 
	INTO 		@id_ComprobantePago,@NumeroTabla
	WHILE @@FETCH_STATUS = 0 AND @flag=1
	BEGIN   
		if(@numero<>CONVERT(int,@NumeroTabla))
		BEGIN
			INSERT #temp1
			VALUES
			(
				@id_ComprobantePago, @serie,@NumeroTabla,@numero
			)
			set @flag=0
		END
		SET @numero += 1;

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

SELECT ccp.Cod_TipoComprobante,t.id_Comprobante,t.Serie,t.Esta,t.DebeSer 
FROM #temp1 t  INNER JOIN dbo.CAJ_COMPROBANTE_PAGO ccp ON t.id_Comprobante=ccp.id_ComprobantePago ORDER BY t.Serie




--Verifica posible incoherencias entre la fecha de emision y la numeracion

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE dbo.#temp1
END
CREATE TABLE #temp1(id_Comprobante int,CodTipoComprobante varchar(10), Serie varchar(10),Numero varchar(10),FechaAnterior_FechaActual varchar(MAX))
GO
SET DATEFORMAT dmy;
DECLARE @CodTipoComprobante varchar(10)
DECLARE @SerieComprobante varchar(10)
DECLARE @FechaAnterior date ='01-01-1990 00:00:00:000';
DECLARE @IdComprobantePAgo int
DECLARE @CodAux varchar(10)
DECLARE @SerieAux varchar(10)
DECLARE @NumeroAux varchar(10)
DECLARE @FechaActual date

DECLARE CURSORCOMPROBANTES CURSOR LOCAL FOR
SELECT DISTINCT ccp.Cod_TipoComprobante,ccp.Serie FROM dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_TipoComprobante IN ('FE','BE','NCE','NDE') AND ccp.Cod_Libro=14 
AND (ccp.Serie LIKE 'F%' OR ccp.Serie LIKE 'B%')
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie
OPEN CURSORCOMPROBANTES
FETCH NEXT FROM CURSORCOMPROBANTES 
INTO @CodTipoComprobante,@SerieComprobante
WHILE @@FETCH_STATUS = 0
BEGIN   
	   
	   DECLARE CURSORCOMPROBANTES2 CURSOR LOCAL FOR
	   SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
	   WHERE ccp.Cod_TipoComprobante =@CodTipoComprobante AND ccp.Serie=@SerieComprobante
	   AND ccp.Cod_Libro=14 ORDER BY ccp.Numero
	   OPEN CURSORCOMPROBANTES2
	   FETCH NEXT FROM CURSORCOMPROBANTES2
	   INTO @IdComprobantePAgo,@CodAux,@SerieAux,@NumeroAux,@FechaActual
	   WHILE @@FETCH_STATUS = 0
	   BEGIN   
		   IF (@FechaAnterior> @FechaActual)
			 BEGIN
				INSERT #temp1
				VALUES
				(
				    @IdComprobantePAgo, -- id_Comprobante - int
				    @CodAux, -- CodTipoComprobante - varchar
				    @SerieAux, -- Serie - varchar
				    @NumeroAux, -- Numero - varchar
				    CONVERT(varchar,@FechaAnterior) + ' - '+CONVERT(varchar,@FechaActual)
				)
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
SELECT * FROM #temp1 t


-- --Verifica si existen salto en la nuemracion en base a una serie y tipo de docuemnto
-- DECLARE @Cod_TipoComprobante AS VARCHAR(5),
-- 		@serie AS VARCHAR(5),@Comprobante AS varchar(max);
-- SET @Cod_TipoComprobante = 'FE'
-- SET @serie = 'F002';
-- DECLARE @id_ComprobantePago int,
-- @numero int
-- SET @numero =1;
-- DECLARE @NumeroTabla varchar(10)

-- IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
-- BEGIN
-- 	DROP TABLE #temp1
-- END
-- CREATE TABLE #temp1(id_Comprobante int, Serie varchar(10), Esta varchar(10),DebeSer varchar(10))

-- DECLARE Medicion_cursor CURSOR FOR 
-- SELECT        id_ComprobantePago,Numero
-- FROM            CAJ_COMPROBANTE_PAGO
-- where cod_libro ='14' and Cod_TipoComprobante = @Cod_TipoComprobante and serie = @serie --AND Flag_Anulado=0
-- ORDER BY Numero ASC

-- OPEN Medicion_cursor

-- FETCH NEXT FROM Medicion_cursor 
-- INTO 		@id_ComprobantePago,@NumeroTabla

-- WHILE @@FETCH_STATUS = 0
-- BEGIN   

-- 	if(@numero<>CONVERT(int,@NumeroTabla))
-- 	BEGIN
-- 		INSERT #temp1
	
-- 		VALUES
-- 		(
-- 		    @id_ComprobantePago, @serie,@NumeroTabla,@numero
-- 		)
-- 	END
-- 	SET @numero += 1;

-- 	FETCH NEXT FROM Medicion_cursor 
-- 	INTO @id_ComprobantePago,@NumeroTabla
-- END 
-- CLOSE Medicion_cursor;
-- DEALLOCATE Medicion_cursor;
-- SELECT * FROM #temp1 t


--Verificar las glosas de los documentos
--DECLARE @SerieAfectada varchar(10) ='B002'
--DECLARE @Cod_TipoComprobanteAfectado varchar(10)='BE'

-- DECLARE @idNota int,@SerieNota varchar(10),@NumeroNota varchar(10),@GlosaNota varchar(MAX),
-- @idAfec int,@SerieAfec varchar(10),@NumeroAfec varchar(10),@GlosaAfec varchar(MAX)

-- IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
-- BEGIN
-- 	DROP TABLE #temp1
-- END
-- CREATE TABLE #temp1(idNota int,SerieNota varchar(10),NumeroNota varchar(10),DiceGlosa varchar(MAX),
-- idAfec int,SerieAfec varchar(10),NumeroAfec varchar(10),DebeDecirGlosa varchar(MAX))

-- DECLARE CursorFila CURSOR FOR
-- SELECT       P.id_ComprobantePago, P.Serie, P.Numero,P.GLOSA,F.id_ComprobantePago, F.Serie , F.Numero,'POR LA ANULACION DE: '+ F.Cod_TipoComprobante+': '+F.Serie+' - '+F.Numero AS Glosa2 
-- FROM            CAJ_COMPROBANTE_PAGO AS P INNER JOIN
--                          CAJ_COMPROBANTE_RELACION AS R ON P.id_ComprobantePago = R.id_ComprobantePago INNER JOIN
--                          CAJ_COMPROBANTE_PAGO AS F ON R.Id_ComprobanteRelacion = F.id_ComprobantePago
-- WHERE COD_TIPORELACION = 'CRE' 
-- AND F.Cod_TipoComprobante=@Cod_TipoComprobanteAfectado
-- AND F.Serie=@SerieAfectada

-- OPEN CursorFila

-- FETCH NEXT FROM CursorFila 
-- INTO 		@idNota,@SerieNota,@NumeroNota,@GlosaNota,
-- @idAfec ,@SerieAfec,@NumeroAfec ,@GlosaAfec

-- WHILE @@FETCH_STATUS = 0
-- BEGIN   
-- 	IF(@GlosaNota<>@GlosaAfec)
-- 	BEGIN
-- 		INSERT INTO #temp1
-- 		(
-- 		    idNota,		    SerieNota,
-- 		    NumeroNota,		    DiceGlosa,
-- 		    idAfec,		    SerieAfec,
-- 		    NumeroAfec,		    DebeDecirGlosa
-- 		)
-- 		VALUES
-- 		(
-- 		    @idNota, -- idNota - int
-- 		    @SerieNota, -- SerieNota - varchar
-- 		    @NumeroNota, -- NumeroNota - varchar
-- 		    @GlosaNota, -- DiceGlosa - varchar
-- 		    @idAfec, -- idAfec - int
-- 		    @SerieAfectada, -- SerieAfec - varchar
-- 		    @NumeroAfec, -- NumeroAfec - varchar
-- 		    @GlosaAfec -- DebeDecirGlosa - varchar
-- 		)
-- 	END
-- 	FETCH NEXT FROM CursorFila 
-- 	INTO @idNota,@SerieNota,@NumeroNota,@GlosaNota,
-- 	@idAfec ,@SerieAfec,@NumeroAfec ,@GlosaAfec
-- END 
-- CLOSE CursorFila;
-- DEALLOCATE CursorFila;
-- SELECT * FROM #temp1 t


--Verifica que los documentos tengan detalles y las notas su relacion
IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE dbo.#temp1
END

CREATE TABLE #temp1(IdComprobante int,Cod_TipoComprobante varchar(10),Serie varchar(10),Numero varchar(10),Detalle varchar(MAX))
GO
DECLARE @IdComprobante int,
@Cod_Tipocomprobante varchar(10),@Serie varchar(10),@Numero varchar(10),
@Detalle varchar(MAX),@Fecha date

DECLARE CursorFila CURSOR FOR
SELECT ccp.id_ComprobantePago,ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision  from dbo.CAJ_COMPROBANTE_PAGO ccp 
WHERE ccp.Cod_TipoComprobante IN ('BE','FE','NCE','NDE') AND ccp.Cod_Libro=14 AND Flag_Anulado=0
ORDER BY ccp.Cod_TipoComprobante,ccp.Serie,ccp.Numero,ccp.FechaEmision

OPEN CursorFila

FETCH NEXT FROM CursorFila 
INTO 		@IdComprobante,@Cod_Tipocomprobante,@Serie,@Numero,@Fecha

WHILE @@FETCH_STATUS = 0
BEGIN  
	SET @Detalle='' 
	--Verificamos que tenga detalles
	IF((SELECT COUNT(*) FROM dbo.CAJ_COMPROBANTE_D ccd WHERE ccd.id_ComprobantePago=@IdComprobante)=0)--Sin detalles
	BEGIN
		SET @Detalle='No tiene detalles-' 
	END

	--Verificamos que las notas tengan relacion
	IF((SELECT TOP 1 ccp.Cod_TipoComprobante from dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=@IdComprobante) IN ('NCE','NDE'))
	BEGIN
		IF((SELECT COUNT(*) FROM dbo.CAJ_COMPROBANTE_RELACION ccr  WHERE ccr.id_ComprobantePago=@IdComprobante)=0)--Sin relacion
		BEGIN
			SET @Detalle=@Detalle+'No tiene relacion '
		END
	END
	IF(@Detalle<>'')
	BEGIN
		INSERT #temp1
		(
		    IdComprobante,
		    Cod_TipoComprobante,
		    Serie,
		    Numero,
		    Detalle
		)
		VALUES
		(
		    @IdComprobante,@Cod_Tipocomprobante,@Serie,@Numero,@Detalle
		)
	END

	FETCH NEXT FROM CursorFila 
	INTO @IdComprobante,@Cod_Tipocomprobante,@Serie,@Numero,@Fecha
END 
CLOSE CursorFila;
DEALLOCATE CursorFila;
SELECT * FROM #temp1 t



--Verifica cuantos documentos afectan las notas,
IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
	DROP TABLE dbo.#temp1
END
CREATE TABLE #temp1(id_Comprobante int,Cod_TipoComprobante varchar(10), Serie varchar(10), Numero varchar(10),Fecha datetime,Referenciados varchar(MAX))

GO
DECLARE @Id_ComprobanteRef int,@Conteo int
DECLARE @id_comprobante int,
 @Cod_Tipocomprobante varchar(10),@serie varchar(10), @numero varchar(10),@fecha datetime,
 @Referenciados varchar(MAX)


DECLARE cursorfila CURSOR LOCAL FOR
select ccp.id_ComprobanteRef, count(ccp.id_ComprobanteRef) AS Conteo
from dbo.CAJ_COMPROBANTE_PAGO ccp
WHERE ccp.Cod_TipoComprobante='NCE' AND ccp.Cod_Libro=14 AND ccp.Flag_Anulado=0
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
	SET @serie=(SELECT TOP 1 ccp.Serie from dbo.CAJ_COMPROBANTE_PAGO ccp 
	WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
	SET @numero=(SELECT TOP 1 ccp.Numero from dbo.CAJ_COMPROBANTE_PAGO ccp 
	WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
	SET @fecha=(SELECT TOP 1 ccp.FechaEmision from dbo.CAJ_COMPROBANTE_PAGO ccp 
	WHERE id_ComprobantePago=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante IN ('FE','BE') AND ccp.Flag_Anulado=0)
	--Recupera los comprobantes que afectan a la nota
	SELECT @Referenciados= COALESCE(@Referenciados + ', ', '') + CONVERT(varchar(10),ccp.id_ComprobantePago) FROM CAJ_COMPROBANTE_PAGO ccp
		WHERE ccp.id_ComprobanteRef=@Id_ComprobanteRef AND ccp.Cod_Libro=14 AND ccp.Cod_TipoComprobante='NCE' AND ccp.Flag_Anulado=0
	INSERT #temp1	VALUES
	(
	    @id_comprobante, -- id_Comprobante - int
	    @Cod_Tipocomprobante, -- Cod_TipoComprobante - varchar
	    @serie, -- Serie - varchar
	    @numero, -- Numero - varchar
		@fecha,
	    @Referenciados -- Referenciados - varchar
	)
	SET @Referenciados = NULL
	FETCH NEXT FROM cursorfila INTO @Id_ComprobanteRef,@Conteo 
END
CLOSE cursorfila
DEALLOCATE cursorfila
SELECT * FROM #temp1 t ORDER BY t.Cod_TipoComprobante,t.Serie,Numero




-- --Verifica valores para intercambia,en caso de querer intercambiar montos en emisiones con monto cero
-- SELECT ccp.id_ComprobantePago,ccp.Cod_Turno,ccd.Cod_Almacen,ccd.Cod_Manguera,ccp.Nom_Cliente,ccd.Id_Producto,ccd.Cantidad,ccd.PrecioUnitario,ccd.Sub_Total,ccd.IGV
-- FROM dbo.CAJ_COMPROBANTE_PAGO ccp INNER JOIN dbo.CAJ_COMPROBANTE_D ccd ON ccp.id_ComprobantePago = ccd.id_ComprobantePago
-- WHERE ccp.Cod_Turno='D28/01/2017' 
-- AND ccp.Cod_TipoComprobante='BE' 
-- AND ccd.Cod_Almacen='T84' 
-- AND ccp.Cod_Caja='101' 
-- AND ccd.Cod_Manguera='1A84'


-- select * from CAJ_COMPROBANTE_PAGO where Cod_EstadoComprobante not in ('INI','EMI')
-- and Cod_TipoComprobante='FE' and Cod_Libro=14 and Impuesto<>0


-- DECLARE @IdComprobante int=5427
-- SELECT  ccp.id_ComprobantePago,ccp.Serie,ccp.Numero FROM dbo.CAJ_COMPROBANTE_PAGO ccp 
-- WHERE ccp.id_ComprobanteRef=@IdComprobante
-- AND ccp.Cod_TipoOperacion='01'
-- AND ccp.Cod_TipoComprobante IN ('BE','FE','TKB','TKF','FA','BO')

-- SELECT * FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.Cod_TipoComprobante='NCE'

-- SELECT * FROM dbo.CAJ_COMPROBANTE_PAGO ccp WHERE ccp.id_ComprobantePago=5427





-- SET DATEFORMAT dmy
-- update CAJ_COMPROBANTE_PAGO set Cod_EstadoComprobante='ACS' where Cod_TipoComprobante in ('FE','NCE','NDE') and Serie like 'F%' and Cod_Libro=14 and Cod_EstadoComprobante='FIN' and FechaEmision>='10-07-2017'



SET DATEFORMAT dmy;
DECLARE @FechaInicio datetime='01-01-2017'
DECLARE @FechaFin datetime='01-10-2017'

SELECT DISTINCT RC.TipoDocumento,RC.Serie,RC.* FROM (
SELECT VTC.Cod_Sunat as TipoDocumento, CP.Serie, MIN(CP.Numero) AS CorrelativoDocumentoInicio,MAX(CP.Numero) AS CorrelativoDocumentoFin,
convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) AS Fecha
FROM            CAJ_COMPROBANTE_PAGO AS CP INNER JOIN
CAJ_COMPROBANTE_D AS CD ON CP.id_ComprobantePago = CD.id_ComprobantePago INNER JOIN
VIS_TIPO_COMPROBANTES AS VTC ON CP.Cod_TipoComprobante = VTC.Cod_TipoComprobante
where convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) >= convert(datetime,CONVERT(VARCHAR,@FechaInicio,103))
AND convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103)) <= convert(datetime,CONVERT(VARCHAR,@FechaFin,103))
AND CP.Serie like 'B%'
AND Cod_Libro = '14'
GROUP BY VTC.Cod_Sunat, CP.Serie,convert(datetime,CONVERT(VARCHAR,CP.FechaEmision,103))) AS RC