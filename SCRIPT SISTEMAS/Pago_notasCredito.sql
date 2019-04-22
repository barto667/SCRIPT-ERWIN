
IF NOT EXISTS
(
    SELECT vfp.*
    FROM dbo.VIS_FORMAS_PAGO vfp
    WHERE vfp.Cod_FormaPago = '997'
)
    BEGIN
        DECLARE @Fila INT= ISNULL(
        (
            SELECT MAX(vfp.Nro)
            FROM dbo.VIS_FORMAS_PAGO vfp
        ), 0) + 1;
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '001', 
             @Cod_Fila = @Fila, 
             @Cadena = N'997', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = NULL, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '002', 
             @Cod_Fila = @Fila, 
             @Cadena = N'NOTA DE CREDITO', 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = NULL, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
        EXEC dbo.USP_PAR_FILA_G 
             @Cod_Tabla = '028', 
             @Cod_Columna = '003', 
             @Cod_Fila = @Fila, 
             @Cadena = NULL, 
             @Numero = NULL, 
             @Entero = NULL, 
             @FechaHora = NULL, 
             @Boleano = 1, 
             @Flag_Creacion = 1, 
             @Cod_Usuario = 'MIGRACION';
END;