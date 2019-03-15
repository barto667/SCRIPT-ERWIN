--Creaciond e la tabla eliminados
IF NOT EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = N'HIS_ELIMINADOS'
          AND type = 'U'
)
    BEGIN
        CREATE TABLE HIS_ELIMINADOS
        (Id                INT IDENTITY(1, 1) PRIMARY KEY, 
         Cod_Eliminado     VARCHAR(128) NOT NULL, 
         Tabla             VARCHAR(256) NOT NULL, 
         Cliente           VARCHAR(MAX) NOT NULL, 
         Detalle           VARCHAR(MAX) NOT NULL, 
         Fecha_Emision     DATETIME NOT NULL, 
         Fecha_Eliminacion DATETIME NOT NULL, 
         Responsable       VARCHAR(64) NOT NULL, 
         Justifcacion      VARCHAR(MAX) NOT NULL, 
         Cod_UsuarioReg    VARCHAR(32) NOT NULL, 
         Fecha_Reg         DATETIME NOT NULL, 
         Cod_UsuarioAct    VARCHAR(32), 
         Fecha_Act         DATETIME
        );
END;
GO
--procedimientos
--Guardar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_G'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_G;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_G @Id                INT OUTPUT, 
                                      @Cod_Eliminado     VARCHAR(128), 
                                      @Tabla             VARCHAR(256), 
                                      @Cliente           VARCHAR(MAX), 
                                      @Detalle           VARCHAR(MAX), 
                                      @Fecha_Emision     DATETIME, 
                                      @Fecha_Eliminacion DATETIME, 
                                      @Responsable       VARCHAR(64), 
                                      @Justificacion     VARCHAR(MAX), 
                                      @Cod_Usuario       VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        IF @Id IS NULL
           OR @Id = 0
            BEGIN
                --Se inserta la informacion
                INSERT INTO dbo.HIS_ELIMINADOS
                VALUES
                (
                -- Id - INT
                @Cod_Eliminado, -- Cod_Eliminado - VARCHAR
                @Tabla, -- Tabla - VARCHAR
                @Cliente, -- Cliente - VARCHAR
                @Detalle, -- Detalle - VARCHAR
                @Fecha_Emision, -- Fecha_Emision - DATETIME
                @Fecha_Eliminacion, -- Fecha_Eliminacion - DATETIME
                @Responsable, -- Responsable - VARCHAR
                @Justificacion, -- Justifcacion - VARCHAR
                @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                GETDATE(), -- Fecha_Reg - DATETIME
                NULL, -- Cod_UsuarioAct - VARCHAR
                NULL -- Fecha_Act - DATETIME
                );
                SET @Id = @@IDENTITY;
        END;
            ELSE
            BEGIN
                IF NOT EXISTS
                (
                    SELECT he.*
                    FROM dbo.HIS_ELIMINADOS he
                    WHERE he.Id = @Id
                )
                    BEGIN
                        INSERT INTO dbo.HIS_ELIMINADOS
                        VALUES
                        (
                        -- Id - INT
                        @Cod_Eliminado, -- Cod_Eliminado - VARCHAR
                        @Tabla, -- Tabla - VARCHAR
                        @Cliente, -- Cliente - VARCHAR
                        @Detalle, -- Detalle - VARCHAR
                        @Fecha_Emision, -- Fecha_Emision - DATETIME
                        @Fecha_Eliminacion, -- Fecha_Eliminacion - DATETIME
                        @Responsable, -- Responsable - VARCHAR
                        @Justificacion, -- Justifcacion - VARCHAR
                        @Cod_Usuario, -- Cod_UsuarioReg - VARCHAR
                        GETDATE(), -- Fecha_Reg - DATETIME
                        NULL, -- Cod_UsuarioAct - VARCHAR
                        NULL -- Fecha_Act - DATETIME
                        );
                        SET @Id = @@IDENTITY;
                END;
                    ELSE
                    BEGIN
                        UPDATE dbo.HIS_ELIMINADOS
                          SET
                        --Id - column value is auto-generated
                              dbo.HIS_ELIMINADOS.Cod_Eliminado = @Cod_Eliminado, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Tabla = @Tabla, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Cliente = @Cliente, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Detalle = @Detalle, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Fecha_Emision = @Fecha_Emision, -- DATETIME
                              dbo.HIS_ELIMINADOS.Fecha_Eliminacion = @Fecha_Eliminacion, -- DATETIME
                              dbo.HIS_ELIMINADOS.Responsable = @Responsable, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Justifcacion = @Justificacion, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Cod_UsuarioAct = @Cod_Usuario, -- VARCHAR
                              dbo.HIS_ELIMINADOS.Fecha_Act = GETDATE() -- DATETIME
                        WHERE dbo.HIS_ELIMINADOS.Id = @Id;
                END;
        END;
    END;
GO
--Eliminar
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_E;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_E @Id INT
WITH ENCRYPTION
AS
    BEGIN
        DELETE dbo.HIS_ELIMINADOS
        WHERE dbo.HIS_ELIMINADOS.Id = @id;
    END;
GO
--Traer todo
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_TT'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_TT;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_TT
WITH ENCRYPTION
AS
    BEGIN
        SELECT he.*
        FROM dbo.HIS_ELIMINADOS he;
    END;
GO
--Traer por claves primarias
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_TXPK'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_TXPK;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_TXPK @Id INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT he.*
        FROM dbo.HIS_ELIMINADOS he
        WHERE he.Id = @Id;
    END;
GO
--Traer auditoria
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_Auditoria'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_Auditoria;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_Auditoria @Id INT
WITH ENCRYPTION
AS
    BEGIN
        SELECT he.Cod_UsuarioReg, 
               he.Fecha_Reg, 
               he.Cod_UsuarioAct, 
               he.Fecha_Act
        FROM dbo.HIS_ELIMINADOS he
        WHERE he.Id = @Id;
    END;
GO
--Traer numero de filas
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_TNF'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_TNF;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_TNF @ScripWhere VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        EXECUTE ('SELECT COUNT(*) AS Nro_Filas FROM HIS_ELIMINADOS '+@ScripWhere);
    END;
GO
-- Traer Paginado
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_HIS_ELIMINADOS_TP'
          AND type = 'P'
)
    DROP PROCEDURE USP_HIS_ELIMINADOS_TP;
GO
CREATE PROCEDURE USP_HIS_ELIMINADOS_TP @TamañoPagina VARCHAR(16), 
                                       @NumeroPagina VARCHAR(16), 
                                       @ScripOrden   VARCHAR(MAX) = NULL, 
                                       @ScripWhere   VARCHAR(MAX) = NULL
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @ScripSQL VARCHAR(MAX);
        SET @ScripSQL = 'SELECT NumeroFila,Id,Cod_Eliminado,Tabla,Cliente,Detalle,Fecha_Emision,Fecha_Eliminacion,Responsable,Justificacion,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			FROM (SELECT TOP 100 PERCENT Id,Cod_Eliminado,Tabla,Cliente,Detalle,Fecha_Emision,Fecha_Eliminacion,Responsable,Justificacion,Cod_UsuarioReg,Fecha_Reg,Cod_UsuarioAct,Fecha_Act,
			ROW_NUMBER() OVER (' + @ScripOrden + ') AS NumeroFila
			FROM HIS_ELIMINADOS ' + @ScripWhere + ') aHIS_ELIMINADOS
			WHERE NumeroFila BETWEEN (' + @TamañoPagina + ' * ' + @NumeroPagina + ')+1 AND ' + @TamañoPagina + ' * (' + @NumeroPagina + ' + 1)';
        EXECUTE (@ScripSQL);
    END;
GO

--METODO QUE DA DE BAJA UN COMPROBANTE POR ID
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_DarBaja'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_DarBaja @id_ComprobantePago INT, 
                                                  @CodUsuario         VARCHAR(32), 
                                                  @Justificacion      VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @Id_Producto INT, @Signo INT, @Cod_Almacen VARCHAR(32), @Cod_UnidadMedida VARCHAR(5), @Despachado NUMERIC(38, 6), @Documento VARCHAR(128), @Proveedor VARCHAR(1024), @Detalle VARCHAR(MAX), @FechaEmision DATETIME, @FechaActual DATETIME, @id_Fila INT;
        SET @FechaActual = GETDATE();
        SELECT @Documento = Cod_Libro + '-' + Cod_TipoComprobante + ':' + Serie + '-' + Numero, 
               @Proveedor = Cod_TipoDoc + ':' + Doc_Cliente + '-' + Nom_Cliente, 
               @FechaEmision = FechaEmision
        FROM CAJ_COMPROBANTE_PAGO
        WHERE id_ComprobantePago = @id_ComprobantePago;

        -- RECUPERAR LOS DETALLES
        SET @Detalle = STUFF(
        (
            SELECT DISTINCT 
                   ' ; ' + CONVERT(VARCHAR, D.Id_Producto) + '|' + d.Descripcion + '|' + CONVERT(VARCHAR, d.Cantidad)
            FROM CAJ_COMPROBANTE_D D
            WHERE D.id_ComprobantePago = @id_ComprobantePago FOR XML PATH('')
        ), 1, 2, '') + '';
        SET @Signo =
        (
            SELECT CASE Cod_Libro
                       WHEN '08'
                       THEN-1
                       WHEN '14'
                       THEN 1
                       ELSE 0
                   END
            FROM CAJ_COMPROBANTE_PAGO
            WHERE id_ComprobantePago = @id_ComprobantePago
        );
        DECLARE ComprobanteD CURSOR
        FOR SELECT Id_Producto, 
                   Cod_UnidadMedida, 
                   Cod_Almacen, 
                   Despachado
            FROM CAJ_COMPROBANTE_D
            WHERE id_ComprobantePago = @id_ComprobantePago
                  AND Id_Producto <> 0;
        OPEN ComprobanteD;
        FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE PRI_PRODUCTO_STOCK
                  SET 
                      Stock_Act = Stock_Act + @Signo * @Despachado
                WHERE Id_Producto = @Id_Producto
                      AND Cod_UnidadMedida = @Cod_UnidadMedida
                      AND Cod_Almacen = @Cod_Almacen;
                FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
            END;
        CLOSE ComprobanteD;
        DEALLOCATE ComprobanteD;

        --Actualizamos la informacion en comprobante pago
        UPDATE dbo.CAJ_COMPROBANTE_PAGO
          SET 
              dbo.CAJ_COMPROBANTE_PAGO.Flag_Anulado = 1, 
              dbo.CAJ_COMPROBANTE_PAGO.Cod_EstadoComprobante = 'REC', 
              dbo.CAJ_COMPROBANTE_PAGO.Impuesto = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Descuento_Total = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.id_ComprobanteRef = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Cargos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.Otros_Tributos = 0, 
              dbo.CAJ_COMPROBANTE_PAGO.MotivoAnulacion = @Justificacion
        WHERE dbo.CAJ_COMPROBANTE_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de los detalles
        UPDATE dbo.CAJ_COMPROBANTE_D
          SET 
              dbo.CAJ_COMPROBANTE_D.Cantidad = 0, 
              dbo.CAJ_COMPROBANTE_D.Despachado = 0, 
              dbo.CAJ_COMPROBANTE_D.Formalizado = 0, 
              dbo.CAJ_COMPROBANTE_D.Descuento = 0, 
              dbo.CAJ_COMPROBANTE_D.Sub_Total = 0, 
              dbo.CAJ_COMPROBANTE_D.IGV = 0, 
              dbo.CAJ_COMPROBANTE_D.ISC = 0
        WHERE dbo.CAJ_COMPROBANTE_D.id_ComprobantePago = @id_ComprobantePago;

        --Actualizamos la informacion de la forma de pago
        UPDATE dbo.CAJ_FORMA_PAGO
          SET 
              dbo.CAJ_FORMA_PAGO.Monto = 0
        WHERE dbo.CAJ_FORMA_PAGO.id_ComprobantePago = @id_ComprobantePago;

        --Eliminamos todas las relaciones
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(Id_ComprobanteRelacion = @id_ComprobantePago);
        DELETE FROM CAJ_COMPROBANTE_RELACION
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        --Eliminamos las licitaciones
        DELETE FROM PRI_LICITACIONES_M
        WHERE(id_ComprobantePago = @id_ComprobantePago);

        -- Eliminar las Serie que se colocaron
        DELETE FROM CAJ_SERIES
        WHERE(Id_Tabla = @id_ComprobantePago
              AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO');
        EXEC dbo.USP_HIS_ELIMINADOS_G 
             @Id = NULL, 
             @Cod_Eliminado = @Documento, 
             @Tabla = 'CAJ_COMPROBANTE_PAGO', 
             @Cliente = @Proveedor, 
             @Detalle = @Detalle, 
             @Fecha_Emision = @FechaEmision, 
             @Fecha_Eliminacion = @FechaActual, 
             @Responsable = @CodUsuario, 
             @Justificacion = @Justificacion, 
             @Cod_Usuario = @CodUsuario;
    END;
GO
--Eliminar comprobante
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_E'
          AND type = 'P'
)
    DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_E;
GO
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_E @id_ComprobantePago INT, 
                                            @CodUsuario         VARCHAR(32), 
                                            @Justificacion      VARCHAR(1024)
WITH ENCRYPTION
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            IF EXISTS
            (
                SELECT id_ComprobantePago
                FROM CAJ_COMPROBANTE_PAGO
                WHERE Cod_Libro = '14'
                      AND Cod_EstadoComprobante NOT IN('EMI', 'INI')
                AND id_ComprobantePago = @id_ComprobantePago
            )
                BEGIN
                    RAISERROR('No se puede Eliminar Dicho comprombprobante porque ya fue notificado a SUNAT', 16, 1);
            END;
                ELSE
                IF EXISTS
                (
                    SELECT id_ComprobantePago
                    FROM CAJ_COMPROBANTE_PAGO
                    WHERE Cod_Libro = '14'
                          AND Cod_TipoComprobante + ':' + Serie + '-' + Numero =
                    (
                        SELECT Cod_TipoComprobante + ':' + Serie + '-' + RIGHT('00000000' + CONVERT(VARCHAR(32), CONVERT(BIGINT, Numero) + 1), 8)
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE id_ComprobantePago = @id_ComprobantePago
                    )
                )
                    BEGIN
                        RAISERROR('No se puede Eliminar Dicho Comprobante porque existe un Numero Superior que lo precede.', 16, 1);
                END;
                    ELSE
                    BEGIN
                        DECLARE @Id_Producto INT, @Signo INT, @Cod_Almacen VARCHAR(32), @Cod_UnidadMedida VARCHAR(5), @Despachado NUMERIC(38, 6), @Documento VARCHAR(128), @Proveedor VARCHAR(1024), @Detalle VARCHAR(MAX), @FechaEmision DATETIME, @FechaActual DATETIME, @id_Fila INT;
                        SET @FechaActual = GETDATE();
                        SELECT @Documento = Cod_Libro + '-' + Cod_TipoComprobante + ':' + Serie + '-' + Numero, 
                               @Proveedor = Cod_TipoDoc + ':' + Doc_Cliente + '-' + Nom_Cliente, 
                               @FechaEmision = FechaEmision
                        FROM CAJ_COMPROBANTE_PAGO
                        WHERE id_ComprobantePago = @id_ComprobantePago;
                        -- RECUPERAR LOS DETALLES
                        SET @Detalle = STUFF(
                        (
                            SELECT DISTINCT 
                                   ' ; ' + CONVERT(VARCHAR, D.Id_Producto) + '|' + d.Descripcion + '|' + CONVERT(VARCHAR, d.Cantidad)
                            FROM CAJ_COMPROBANTE_D D
                            WHERE D.id_ComprobantePago = @id_ComprobantePago FOR XML PATH('')
                        ), 1, 2, '') + '';
                        SET @Signo =
                        (
                            SELECT CASE Cod_Libro
                                       WHEN '08'
                                       THEN-1
                                       WHEN '14'
                                       THEN 1
                                       ELSE 0
                                   END
                            FROM CAJ_COMPROBANTE_PAGO
                            WHERE id_ComprobantePago = @id_ComprobantePago
                        );
                        DECLARE ComprobanteD CURSOR
                        FOR SELECT Id_Producto, 
                                   Cod_UnidadMedida, 
                                   Cod_Almacen, 
                                   Despachado
                            FROM CAJ_COMPROBANTE_D
                            WHERE id_ComprobantePago = @id_ComprobantePago
                                  AND Id_Producto <> 0;
                        OPEN ComprobanteD;
                        FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
                        WHILE @@FETCH_STATUS = 0
                            BEGIN
                                UPDATE PRI_PRODUCTO_STOCK
                                  SET 
                                      Stock_Act = Stock_Act + @Signo * @Despachado
                                WHERE Id_Producto = @Id_Producto
                                      AND Cod_UnidadMedida = @Cod_UnidadMedida
                                      AND Cod_Almacen = @Cod_Almacen;
                                FETCH NEXT FROM ComprobanteD INTO @Id_Producto, @Cod_UnidadMedida, @Cod_Almacen, @Despachado;
                END;
                        CLOSE ComprobanteD;
                        DEALLOCATE ComprobanteD;

                        -- QUITAR LA REFERENCIA 
                        UPDATE CAJ_COMPROBANTE_PAGO
                          SET 
                              id_Comprobanteref = 0
                        WHERE(id_Comprobanteref = @id_ComprobantePago);

                        -- ACTUALIZAR LA FORMALIZACION QUITAR LO QUE SE LLEGO A FORMALIZAR EN ESTE PROCESO
                        -- REVERTIR LA ENTRADA ANTES DE ELIMINAR
                        UPDATE CAJ_COMPROBANTE_D
                          SET 
                              Formalizado-=CR.Valor
                        FROM CAJ_COMPROBANTE_D CD
                             INNER JOIN CAJ_COMPROBANTE_RELACION CR ON CD.id_ComprobantePago = CR.id_ComprobantePago
                                                                       AND CD.id_Detalle = CR.id_Detalle
                        WHERE CR.Id_ComprobanteRelacion = @id_ComprobantePago;
                        DELETE FROM CAJ_COMPROBANTE_RELACION
                        WHERE(Id_ComprobanteRelacion = @id_ComprobantePago);
                        DELETE FROM CAJ_COMPROBANTE_RELACION
                        WHERE(id_ComprobantePago = @id_ComprobantePago);
                        DELETE FROM CAJ_COMPROBANTE_D
                        WHERE(id_ComprobantePago = @id_ComprobantePago);
                        DELETE FROM CAJ_FORMA_PAGO
                        WHERE(id_ComprobantePago = @id_ComprobantePago);
                        DELETE FROM PRI_LICITACIONES_M
                        WHERE(id_ComprobantePago = @id_ComprobantePago);
                        DELETE FROM CAJ_COMPROBANTE_PAGO
                        WHERE(id_ComprobantePago = @id_ComprobantePago);

                        -- Eliminar las Serie que se colocaron
                        DELETE FROM CAJ_SERIES
                        WHERE(Id_Tabla = @id_ComprobantePago
                              AND Cod_Tabla = 'CAJ_COMPROBANTE_PAGO');
                        -- insertar elementos en un datos a ver que pasa
                        EXEC dbo.USP_HIS_ELIMINADOS_G 
                             @Id = NULL, 
                             @Cod_Eliminado = @Documento, 
                             @Tabla = 'CAJ_COMPROBANTE_PAGO', 
                             @Cliente = @Proveedor, 
                             @Detalle = @Detalle, 
                             @Fecha_Emision = @FechaEmision, 
                             @Fecha_Eliminacion = @FechaActual, 
                             @Responsable = @CodUsuario, 
                             @Justificacion = @Justificacion, 
                             @Cod_Usuario = @CodUsuario;
                END;
        END TRY
        BEGIN CATCH
            SELECT ERROR_NUMBER() AS ErrorNumber, 
                   ERROR_SEVERITY() AS ErrorSeverity, 
                   ERROR_STATE() AS ErrorState, 
                   ERROR_PROCEDURE() AS ErrorProcedure, 
                   ERROR_LINE() AS ErrorLine, 
                   ERROR_MESSAGE() AS ErrorMessage;
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO