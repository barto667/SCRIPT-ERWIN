--Detecta las serie y numeros de NCE que afectan a FE y BE
SELECT        P.Cod_TipoComprobante, P.Serie, P.Numero, F.Cod_TipoComprobante AS Expr1, F.Serie AS Expr2, F.Numero AS Expr3, P.GLOSA
FROM            CAJ_COMPROBANTE_PAGO AS P INNER JOIN
                         CAJ_COMPROBANTE_RELACION AS R ON P.id_ComprobantePago = R.id_ComprobantePago INNER JOIN
                         CAJ_COMPROBANTE_PAGO AS F ON R.Id_ComprobanteRelacion = F.id_ComprobantePago
WHERE COD_TIPORELACION = 'CRE' AND F.SERIE LIKE 'B%'


--Corrige las glosas
GO

	DECLARE @IdNota int
	declare @id_referencia int
	DECLARE @TipoRef varchar(10)
	DECLARE @SerieRef varchar(10)
	DECLARE @NumeroRef varchar(10)

	DECLARE Cursorfila CURSOR LOCAL FOR 
	SELECT        P.id_ComprobantePago,F.Cod_TipoComprobante, F.Serie AS Serie, F.Numero AS Numero
	FROM            CAJ_COMPROBANTE_PAGO AS P INNER JOIN
							 CAJ_COMPROBANTE_RELACION AS R ON P.id_ComprobantePago = R.id_ComprobantePago INNER JOIN
							 CAJ_COMPROBANTE_PAGO AS F ON R.Id_ComprobanteRelacion = F.id_ComprobantePago
	WHERE COD_TIPORELACION = 'CRE' AND F.SERIE LIKE 'B%'

	--Abrimos el cursor de los precios
	open Cursorfila
	FETCH NEXT FROM Cursorfila INTO @IdNota,@TipoRef,@SerieRef,@NumeroRef
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		--Guardamos los datos en el pri_producto_precio
		UPDATE CAJ_COMPROBANTE_PAGO SET Glosa='POR LA ANULACION DE: '+@TipoRef+': '+@SerieRef+' - '+@NumeroRef
		WHERE CAJ_COMPROBANTE_PAGO.id_ComprobantePago=@IdNota

		FETCH NEXT FROM Cursorfila INTO @IdNota,@TipoRef,@SerieRef,@NumeroRef
	END
	CLOSE Cursorfila
	DEALLOCATE Cursorfila
go