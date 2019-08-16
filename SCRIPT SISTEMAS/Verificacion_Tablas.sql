
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VerificarTablas'
          AND type = 'P'
)
    DROP PROCEDURE USP_VerificarTablas;
GO
CREATE PROCEDURE USP_VerificarTablas
WITH ENCRYPTION
AS
    BEGIN
        --Verificacion de las tablas y columnas de la base de datos
        DECLARE @Contador INT= 0;
        IF OBJECT_ID('tempdb..#tempTablaResultado') IS NOT NULL
            BEGIN
                DROP TABLE dbo.#tempTablaResultado;
        END;
        CREATE TABLE #tempTablaResultado
        (Contador       INT, 
         Error          VARCHAR(MAX), 
         Nombre_Tabla   VARCHAR(MAX), 
         Nombre_Columna VARCHAR(MAX)
        );
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'ALM_ALMACEN'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('ALM_ALMACEN', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Cod_TipoAlmacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoAlmacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Des_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Des_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Des_CortaAlmacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Des_CortaAlmacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN', 'Flag_Principal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Flag_Principal' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'ALM_ALMACEN_MOV'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_TipoOperacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Flag_Anulado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Flag_Anulado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Id_AlmacenMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Id_AlmacenMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Motivo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Motivo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Obs_AlmacenMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Obs_AlmacenMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'ALM_ALMACEN_MOV_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Des_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Des_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Id_AlmacenMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Id_AlmacenMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Obs_AlmacenMovD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Obs_AlmacenMovD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_ALMACEN_MOV_D', 'Precio_Unitario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_ALMACEN_MOV_D', -- Nombre_Tabla - VARCHAR
                         'Precio_Unitario' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'ALM_INVENTARIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('ALM_INVENTARIO', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Cod_EstadoInventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoInventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Cod_TipoInventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoInventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Des_Inventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Des_Inventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Fecha_Inventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Id_Inventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Id_Inventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO', 'Obs_Inventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO', -- Nombre_Tabla - VARCHAR
                         'Obs_Inventario' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'ALM_INVENTARIO_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cantidad_Encontrada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad_Encontrada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cantidad_Sistema') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad_Sistema' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Id_Inventario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Id_Inventario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Obs_InventarioD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Obs_InventarioD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('ALM_INVENTARIO_D', 'Precio_Unitario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'ALM_INVENTARIO_D', -- Nombre_Tabla - VARCHAR
                         'Precio_Unitario' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'BAN_CUENTA_BANCARIA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_EntidadFinanciera') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_EntidadFinanciera' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_TipoCuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Des_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Des_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_BANCARIA', 'Saldo_Disponible') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_BANCARIA', -- Nombre_Tabla - VARCHAR
                         'Saldo_Disponible' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'BAN_CUENTA_M'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('BAN_CUENTA_M', 'Beneficiario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Beneficiario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_TipoOperacionBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperacionBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Des_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Des_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Id_MovimientoCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Nro_Cheque') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Nro_Cheque' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Nro_Operacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Nro_Operacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'Obs_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Obs_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('BAN_CUENTA_M', 'TipoCambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'BAN_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'TipoCambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_ARQUEOFISICO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Des_ArqueoFisico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Des_ArqueoFisico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Flag_Cerrado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Flag_Cerrado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'id_ArqueoFisico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'id_ArqueoFisico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO', 'Obs_ArqueoFisico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO', -- Nombre_Tabla - VARCHAR
                         'Obs_ArqueoFisico' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_ARQUEOFISICO_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Cod_Billete') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Billete' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_D', 'id_ArqueoFisico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_D', -- Nombre_Tabla - VARCHAR
                         'id_ArqueoFisico' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_ARQUEOFISICO_SALDO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'id_ArqueoFisico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'id_ArqueoFisico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_ARQUEOFISICO_SALDO', 'Tipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_ARQUEOFISICO_SALDO', -- Nombre_Tabla - VARCHAR
                         'Tipo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_CAJA_ALMACEN'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_ALMACEN', 'Flag_Principal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_ALMACEN', -- Nombre_Tabla - VARCHAR
                         'Flag_Principal' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_CAJA_MOVIMIENTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_MonedaEgr') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_MonedaEgr' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_MonedaIng') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_MonedaIng' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_UsuarioAut') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAut' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Des_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Des_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Egreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Egreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Fecha_Aut') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Aut' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Flag_Extornado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Flag_Extornado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Id_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'id_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'id_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Id_MovimientoRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Ingreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Ingreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Obs_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJA_MOVIMIENTOS', 'Tipo_Cambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJA_MOVIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Tipo_Cambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_CAJAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_UsuarioCajero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioCajero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Des_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Des_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_CAJAS_DOC'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Flag_FacRapida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Flag_FacRapida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Flag_Imprimir') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Flag_Imprimir' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Impresora') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Impresora' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Limite') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Limite' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Nom_Archivo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Nom_Archivo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Nom_ArchivoPublicar') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Nom_ArchivoPublicar' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Nro_SerieTicketera') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Nro_SerieTicketera' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CAJAS_DOC', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CAJAS_DOC', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_COMPROBANTE_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_Manguera') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Manguera' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_TipoIGV') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoIGV' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_TipoISC') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoISC' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Descripcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Descripcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Descuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Descuento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Despachado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Despachado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Flag_AplicaImpuesto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Flag_AplicaImpuesto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Formalizado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Formalizado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'id_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'id_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'IGV') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'IGV' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'ISC') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'ISC' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Obs_ComprobanteD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Obs_ComprobanteD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Porcentaje_IGV') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Porcentaje_IGV' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Porcentaje_ISC') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Porcentaje_ISC' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'PrecioUnitario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'PrecioUnitario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Sub_Total') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Sub_Total' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Tipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Tipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_D', 'Valor_NoOneroso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_D', -- Nombre_Tabla - VARCHAR
                         'Valor_NoOneroso' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_COMPROBANTE_LOG'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Cod_Mensaje') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Cod_Mensaje' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_LOG', 'Mensaje') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_LOG', -- Nombre_Tabla - VARCHAR
                         'Mensaje' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_COMPROBANTE_PAGO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_EstadoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_FormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_FormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Periodo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Periodo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_RegimenPercepcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_RegimenPercepcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_TipoDoc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDoc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_TipoDocReferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocReferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_TipoOperacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Cod_UsuarioVendedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioVendedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Descuento_Total') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Descuento_Total' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Direccion_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Direccion_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Doc_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Doc_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'FechaCancelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'FechaCancelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'FechaEmision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'FechaEmision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'FechaVencimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'FechaVencimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Flag_Anulado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Flag_Anulado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Flag_Despachado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Flag_Despachado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Glosa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Glosa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'GuiaRemision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'GuiaRemision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Id_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Id_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'id_ComprobanteRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'id_ComprobanteRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Id_GuiaRemision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Impuesto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Impuesto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'MotivoAnulacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'MotivoAnulacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Nom_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Nom_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Nro_DocReferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Nro_DocReferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Nro_Ticketera') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Nro_Ticketera' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Obs_Comprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Obs_Comprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Otros_Cargos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Otros_Cargos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Otros_Tributos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Otros_Tributos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Placa_Vehiculo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Placa_Vehiculo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Tasa_Percepcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Tasa_Percepcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'TipoCambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'TipoCambio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Total') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Total' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Valor_Firma') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Valor_Firma' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_PAGO', 'Valor_Resumen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_PAGO', -- Nombre_Tabla - VARCHAR
                         'Valor_Resumen' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_COMPROBANTE_RELACION'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Cod_TipoRelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoRelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Id_ComprobanteRelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Id_ComprobanteRelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'id_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'id_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Id_DetalleRelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Id_DetalleRelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Obs_Relacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Obs_Relacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMPROBANTE_RELACION', 'Valor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMPROBANTE_RELACION', -- Nombre_Tabla - VARCHAR
                         'Valor' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_COMUNICACION_BAJA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Cod_Usuario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Cod_Usuario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Fecha_Comunicacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Comunicacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Fecha_Emision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Emision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Justificacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Justificacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Mensaje_Respuesta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Mensaje_Respuesta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Numero_Comunicado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Numero_Comunicado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_COMUNICACION_BAJA', 'Ticket') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_COMUNICACION_BAJA', -- Nombre_Tabla - VARCHAR
                         'Ticket' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_CONCEPTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_CONCEPTO', 'Cod_ClaseConcepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Cod_ClaseConcepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Des_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Des_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Id_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Id_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_CONCEPTO', 'Id_ConceptoPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_CONCEPTO', -- Nombre_Tabla - VARCHAR
                         'Id_ConceptoPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_FORMA_PAGO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_TipoFormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoFormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Cuenta_CajaBanco') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Cuenta_CajaBanco' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Des_FormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Des_FormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Id_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Id_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'Obs_FormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'Obs_FormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_FORMA_PAGO', 'TipoCambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_FORMA_PAGO', -- Nombre_Tabla - VARCHAR
                         'TipoCambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_GUIA_REMISION_REMITENTE'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_Caja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_Caja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_EstadoGuia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoGuia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_ModalidadTraslado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_ModalidadTraslado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_MotivoTraslado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_MotivoTraslado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_Periodo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_Periodo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_Puerto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_Puerto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_UbigeoLlegada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_UbigeoLlegada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_UbigeoPartida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_UbigeoPartida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Des_MotivoTraslado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Des_MotivoTraslado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Direccion_LLegada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Direccion_LLegada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Direccion_Partida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Direccion_Partida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Fecha_Emision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Emision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Fecha_EntregaBienes') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Fecha_EntregaBienes' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Fecha_TrasladoBienes') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Fecha_TrasladoBienes' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Flag_Anulado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Flag_Anulado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Flag_Transbordo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Flag_Transbordo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Id_ClienteDestinatario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteDestinatario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Id_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Id_GuiaRemisionRemitenteBaja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitenteBaja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Nro_Bulltos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Nro_Bulltos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Nro_Contenedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Nro_Contenedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Obs_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Obs_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Peso_Bruto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Peso_Bruto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Valor_Firma') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Valor_Firma' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE', 'Valor_Resumen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE', -- Nombre_Tabla - VARCHAR
                         'Valor_Resumen' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_GUIA_REMISION_REMITENTE_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cod_ProductoSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_ProductoSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Descripcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Descripcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Id_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Id_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Id_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Obs_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Obs_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_D', 'Peso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_D', -- Nombre_Tabla - VARCHAR
                         'Peso' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Cod_TipoDocumento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocumento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Cod_TipoRelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoRelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Id_DocRelacionado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Id_DocRelacionado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Id_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Observacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Observacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_RELACIONADOS', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Cod_ModalidadTransporte') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_ModalidadTransporte' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Cod_TipoDocumento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocumento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Id_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Licencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Licencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Nombres') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Nombres' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Numero_Documento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Numero_Documento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', 'Observaciones') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_TRANSPORTISTAS', -- Nombre_Tabla - VARCHAR
                         'Observaciones' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Certificado_Habilitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Certificado_Habilitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Certificado_Inscripcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Certificado_Inscripcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Id_GuiaRemisionRemitente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Id_GuiaRemisionRemitente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Observaciones') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Observaciones' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', 'Placa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_GUIA_REMISION_REMITENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Placa' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_LETRA_CAMBIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Fecha_Girado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Girado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Fecha_Pago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Pago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Fecha_Vencimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Vencimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Id') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Id' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Id_Comprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Id_Comprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Id_Letra') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Id_Letra' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Monto_Base') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Monto_Base' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Monto_Real') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Monto_Real' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Nro_Letra') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Nro_Letra' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Nro_Operacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Nro_Operacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Nro_Referencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Nro_Referencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Observaciones') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Observaciones' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_LETRA_CAMBIO', 'Ref_Girador') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_LETRA_CAMBIO', -- Nombre_Tabla - VARCHAR
                         'Ref_Girador' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_MEDICION_VC'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Cod_AMedir') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Cod_AMedir' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Cod_UsuarioMedicion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioMedicion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Fecha_Medicion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Fecha_Medicion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Id_Medicion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Id_Medicion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Medida_Actual') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Medida_Actual' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Medida_Anterior') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Medida_Anterior' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_MEDICION_VC', 'Medio_AMedir') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_MEDICION_VC', -- Nombre_Tabla - VARCHAR
                         'Medio_AMedir' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_RESUMEN_DIARIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Fecha_Envio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Envio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Fecha_Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Nom_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Nom_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Ticket') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Ticket' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_RESUMEN_DIARIO', 'Total_Resumen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_RESUMEN_DIARIO', -- Nombre_Tabla - VARCHAR
                         'Total_Resumen' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_SERIES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_SERIES', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Cod_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Cod_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Fecha_Vencimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Vencimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Id_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Id_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Obs_Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Obs_Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_SERIES', 'Serie') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_SERIES', -- Nombre_Tabla - VARCHAR
                         'Serie' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_TIPOCAMBIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Compra') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Compra' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'FechaHora') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'FechaHora' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Id_TipoCambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Id_TipoCambio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'SunatCompra') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'SunatCompra' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'SunatVenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'SunatVenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TIPOCAMBIO', 'Venta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TIPOCAMBIO', -- Nombre_Tabla - VARCHAR
                         'Venta' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_TRANSFERENCIAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_Banco') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Banco' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_Destino') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Destino' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_EstadoTransferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoTransferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_Origen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Origen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_UsuarioEmision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioEmision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_UsuarioPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Comision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Comision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Doc_Transferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Doc_Transferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Fecha_Emision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Emision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Fecha_Pago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Pago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Flag_Leido') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Leido' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'id_ClienteBeneficiarioP') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'id_ClienteBeneficiarioP' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'id_ClienteBeneficiarioS') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'id_ClienteBeneficiarioS' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'id_ClienteEmisor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'id_ClienteEmisor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_ComprobanteSolicitud') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_ComprobanteSolicitud' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_MovimientoComision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoComision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_MovimientoOtros') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoOtros' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_MovimientoPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_MovimientoSolicitud') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_MovimientoSolicitud' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Id_Transferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_Transferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Num_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Num_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Obs_Tranferencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Obs_Tranferencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TRANSFERENCIAS', 'Otros') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TRANSFERENCIAS', -- Nombre_Tabla - VARCHAR
                         'Otros' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAJ_TURNO_ATENCION'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Cod_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Cod_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Des_Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Des_Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAJ_TURNO_ATENCION', 'Flag_Cerrado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAJ_TURNO_ATENCION', -- Nombre_Tabla - VARCHAR
                         'Flag_Cerrado' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CAL_CALENDARIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CAL_CALENDARIO', 'Asunto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Asunto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Aviso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Aviso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Cod_UsuarioCreador') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioCreador' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Detalles') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Detalles' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Fecha_Comienza') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Comienza' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Fecha_Finaliza') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Finaliza' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Flag_DiaEntero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Flag_DiaEntero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Flag_Importante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Flag_Importante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Flag_Prioridad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Flag_Prioridad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Flag_Privado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Flag_Privado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Id_Calendario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Id_Calendario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'MostrarComo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'MostrarComo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CAL_CALENDARIO', 'Ubicacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CAL_CALENDARIO', -- Nombre_Tabla - VARCHAR
                         'Ubicacion' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CON_ASIENTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CON_ASIENTO', 'Cod_ComSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_ComSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_Periodo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Periodo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_TasaSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TasaSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_TipoCom') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCom' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_TipoComRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Fecha_Com') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Com' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Fecha_ComRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_ComRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Glosa_Asiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Glosa_Asiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Id_Comprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Id_Comprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Nro_Asiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Nro_Asiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Num_Com') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Num_Com' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Num_ComRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Num_ComRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Num_ComSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Num_ComSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Obs_Asiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Obs_Asiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'RazonSocial') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'RazonSocial' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'RUC') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'RUC' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Serie_Com') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Serie_Com' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Serie_ComRef') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Serie_ComRef' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO', 'Tipo_Cambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Tipo_Cambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CON_ASIENTO_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_CuentaAnalitica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaAnalitica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_TipoOperacionAsiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperacionAsiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Debe_ME') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Debe_ME' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Debe_MN') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Debe_MN' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Doc_CuentaAnalitica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Doc_CuentaAnalitica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Haber_ME') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Haber_ME' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Haber_MN') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Haber_MN' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Nro_Asiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Nro_Asiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Nro_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Nro_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_ASIENTO_D', 'Obs_AsientoD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Obs_AsientoD' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CON_PLANTILLA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_Modulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Modulo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_TipoDoc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDoc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_TipoFormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoFormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Des_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Des_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Flag_Activa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_Activa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Flag_EsModelo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_EsModelo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'Flag_Exonerada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_Exonerada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA', 'SerieDoc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA', -- Nombre_Tabla - VARCHAR
                         'SerieDoc' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CON_PLANTILLA_ASIENTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO', 'TipoCambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO', -- Nombre_Tabla - VARCHAR
                         'TipoCambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CON_PLANTILLA_ASIENTO_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Cod_Plantilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Plantilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Cod_TipoOperacionAsiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperacionAsiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Formula_CodCuentaAnalitica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Formula_CodCuentaAnalitica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Formula_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Formula_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Formula_Debe') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Formula_Debe' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Formula_DocCuentaAnalitica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Formula_DocCuentaAnalitica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Formula_Haber') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Formula_Haber' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CON_PLANTILLA_ASIENTO_D', 'Nro_Linea') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CON_PLANTILLA_ASIENTO_D', -- Nombre_Tabla - VARCHAR
                         'Nro_Linea' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CUE_CLIENTE_CUENTA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_EstadoCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_TipoCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Des_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Des_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Flag_ITF') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Flag_ITF' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Interes') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Interes' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Limite_Max') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Limite_Max' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'MesesMax') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'MesesMax' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Monto_Deposito') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Monto_Deposito' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Saldo_Contable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Saldo_Contable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA', 'Saldo_Disponible') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA', -- Nombre_Tabla - VARCHAR
                         'Saldo_Disponible' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CUE_CLIENTE_CUENTA_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Cod_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Cod_EstadoDCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoDCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Des_CuentaD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Des_CuentaD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Fecha_Emision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Emision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Fecha_Vencimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Vencimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_D', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_D', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CUE_CLIENTE_CUENTA_M'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_MonedaEgr') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_MonedaEgr' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_MonedaIng') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_MonedaIng' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_TipoMovimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoMovimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Des_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Des_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Egreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Egreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Flag_Extorno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Flag_Extorno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Id_ClienteCuentaMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteCuentaMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Id_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Id_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'id_MovimientoCaja') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'id_MovimientoCaja' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Ingreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Ingreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_CLIENTE_CUENTA_M', 'Tipo_Cambio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_CLIENTE_CUENTA_M', -- Nombre_Tabla - VARCHAR
                         'Tipo_Cambio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'CUE_TARJETAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('CUE_TARJETAS', 'CCV') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'CCV' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Cod_Tarjeta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Tarjeta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Contraseña') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Contraseña' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Fecha_Vencimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Vencimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Flag_Entregado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Entregado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('CUE_TARJETAS', 'Nombre_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'CUE_TARJETAS', -- Nombre_Tabla - VARCHAR
                         'Nombre_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAR_COLUMNA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAR_COLUMNA', 'Cod_Columna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Cod_Columna' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Cod_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Cod_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Columna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Columna' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Des_Columna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Des_Columna' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Flag_NULL') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Flag_NULL' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Flag_PK') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Flag_PK' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Predeterminado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Predeterminado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Tamano') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Tamano' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_COLUMNA', 'Tipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_COLUMNA', -- Nombre_Tabla - VARCHAR
                         'Tipo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAR_FILA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAR_FILA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAR_FILA', 'Boleano') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Boleano' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cadena') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cadena' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cod_Columna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cod_Columna' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cod_Fila') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cod_Fila' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cod_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cod_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Entero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Entero' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'FechaHora') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'FechaHora' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Flag_Creacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Flag_Creacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_FILA', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_FILA', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAR_TABLA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAR_TABLA', 'Cod_Sistema') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Sistema' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Cod_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Des_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Des_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Flag_Acceso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Flag_Acceso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAR_TABLA', 'Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAR_TABLA', -- Nombre_Tabla - VARCHAR
                         'Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAT_BIENES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAT_BIENES', 'Cod_Bien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_Bien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_BienPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_BienPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_Condicion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_Condicion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_EstadoBien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoBien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_Grupo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_Grupo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_PersonalResponsable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_PersonalResponsable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Des_Bien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Des_Bien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Factor_Depreciacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Factor_Depreciacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Fecha_Deprecesacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Deprecesacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Fecha_Ingreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Ingreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Flag_Asegurado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Flag_Asegurado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Obs_Bien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Obs_Bien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Valor_Historico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Valor_Historico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Valor_Libros') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Valor_Libros' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Valor_Reposicion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Valor_Reposicion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Valor_Residual') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Valor_Residual' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Valor_Tasacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Valor_Tasacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES', 'Vida_Util') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES', -- Nombre_Tabla - VARCHAR
                         'Vida_Util' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAT_BIENES_CARACTERISTICAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Caracteristica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Caracteristica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Cod_Bien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Bien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Cod_Caracteristica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Caracteristica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_CARACTERISTICAS', 'Valor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Valor' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAT_BIENES_MOVIMIENTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_Bien') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Bien' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_TipoBienMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoBienMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_TipoDocMov') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocMov' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_TrabajadorDestino') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TrabajadorDestino' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_TrabajadorOrigen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TrabajadorOrigen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Des_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Des_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Doc_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Doc_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Fecha_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_BIENES_MOVIMIENTO', 'Nro_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_BIENES_MOVIMIENTO', -- Nombre_Tabla - VARCHAR
                         'Nro_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAT_GRUPOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_CuentaDebe') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaDebe' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_CuentaHaber') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaHaber' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_Grupo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Grupo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_GrupoPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_GrupoPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Des_Grupo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Des_Grupo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Factor_Depreciacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Factor_Depreciacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS', 'Vida_Util') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS', -- Nombre_Tabla - VARCHAR
                         'Vida_Util' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PAT_GRUPOS_CARACTERISTICAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Caracteristica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Caracteristica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Cod_Caracteristica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Caracteristica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Cod_Grupo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Grupo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PAT_GRUPOS_CARACTERISTICAS', 'Predeterminado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PAT_GRUPOS_CARACTERISTICAS', -- Nombre_Tabla - VARCHAR
                         'Predeterminado' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_AFP_PRIMA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Cod_AFP') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Cod_AFP' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Cod_Periodo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Cod_Periodo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Monto_Max') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Monto_Max' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Monto_Min') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Monto_Min' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Por_Aporte') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Por_Aporte' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Por_Comision') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Por_Comision' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_AFP_PRIMA', 'Por_Prima') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_AFP_PRIMA', -- Nombre_Tabla - VARCHAR
                         'Por_Prima' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_ASISTENCIA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_Incidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Incidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_Proceso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Proceso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Entro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Entro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Fecha') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Fecha' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'HoraEntrada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'HoraEntrada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'HoraSalida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'HoraSalida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Id_Asistencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Id_Asistencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Id_Horario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Id_Horario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Obs_Asistencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Obs_Asistencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Salio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Salio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_ASISTENCIA', 'Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_ASISTENCIA', -- Nombre_Tabla - VARCHAR
                         'Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_BIOMETRICO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_BIOMETRICO', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Des_Biometrico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Des_Biometrico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'HashHuella10') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'HashHuella10' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Id_Biometrico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Id_Biometrico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Obs_Biometrico') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Obs_Biometrico' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BIOMETRICO', 'Valor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BIOMETRICO', -- Nombre_Tabla - VARCHAR
                         'Valor' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_BOLETA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_BOLETA', 'Cod_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_ContraCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_ContraCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_Planilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_Planilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Des_Boleta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Des_Boleta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_BOLETA', 'NroColumna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_BOLETA', -- Nombre_Tabla - VARCHAR
                         'NroColumna' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_CONCEPTOS_PLANILLA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_ConceptoPDT') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_ConceptoPDT' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_ContraCuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_ContraCuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_TipoConcepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoConcepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Des_Boleta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Des_Boleta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Des_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Des_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_AfectoAFP') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoAFP' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_AfectoCTS') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoCTS' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_AfectoESSALUD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoESSALUD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_AfectoQuinta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoQuinta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_AfectoSENATI') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoSENATI' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONCEPTOS_PLANILLA', 'Flag_EsQuintaCat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONCEPTOS_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_EsQuintaCat' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_CONTRATOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_Cargo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Cargo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_TipoContrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoContrato' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Contrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Contrato' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Des_Contrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Des_Contrato' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Fecha_Firma') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Firma' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Monto_Base') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Monto_Base' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Nro_Contrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Nro_Contrato' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_CONTRATOS', 'Obs_Contrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_CONTRATOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Contrato' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_HORARIOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_HORARIOS', 'Cod_TipoHorario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoHorario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Dias') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Dias' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Flag_ContemplaDias') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Flag_ContemplaDias' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Flag_Corrido') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Flag_Corrido' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'HoraEntrada') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'HoraEntrada' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'HoraSalida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'HoraSalida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Id_Horario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Id_Horario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Id_HorarioPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Id_HorarioPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Tiempo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Tiempo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_HORARIOS', 'Turno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_HORARIOS', -- Nombre_Tabla - VARCHAR
                         'Turno' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_PERSONAL_HORARIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Id_Horario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Id_Horario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PERSONAL_HORARIO', 'Id_PersonalHorario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PERSONAL_HORARIO', -- Nombre_Tabla - VARCHAR
                         'Id_PersonalHorario' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_PLANILLA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_PLANILLA', 'Cod_Periodo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Periodo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Cod_Planilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_Planilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Cod_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Des_Planilla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Des_Planilla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Cierre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Cierre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Pago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Pago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Flag_AfectoCTS') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoCTS' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Flag_AfectoQuinta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_AfectoQuinta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA', 'Flag_Cierre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA', -- Nombre_Tabla - VARCHAR
                         'Flag_Cierre' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_PLANILLA_TIPO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Cod_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Cod_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Cod_TipoImresionBoleta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoImresionBoleta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Des_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Des_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO', 'Obs_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO', -- Nombre_Tabla - VARCHAR
                         'Obs_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_PLANILLA_TIPO_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Cod_Concepto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Concepto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Cod_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Formula') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Formula' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'NroColumna') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'NroColumna' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Obs_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Obs_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Rotulo1') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Rotulo1' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_D', 'Rotulo2') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_D', -- Nombre_Tabla - VARCHAR
                         'Rotulo2' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PLA_PLANILLA_TIPO_PERSONAL'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Cod_PlanillaTipo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_PlanillaTipo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PLA_PLANILLA_TIPO_PERSONAL', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PLA_PLANILLA_TIPO_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_ACTIVIDADES_ECONOMICAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'CIIU') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'CIIU' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Cod_ActividadEconomica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_ActividadEconomica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Des_ActividadEconomica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Des_ActividadEconomica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Escala') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Escala' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ACTIVIDADES_ECONOMICAS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ACTIVIDADES_ECONOMICAS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_AREAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_AREAS', 'Cod_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Cod_AreaPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Cod_AreaPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Des_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Des_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_AREAS', 'Numero') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_AREAS', -- Nombre_Tabla - VARCHAR
                         'Numero' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CATEGORIA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CATEGORIA', 'Cod_Categoria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Categoria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Cod_CategoriaPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Cod_CategoriaPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Des_Categoria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Des_Categoria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CATEGORIA', 'Foto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CATEGORIA', -- Nombre_Tabla - VARCHAR
                         'Foto' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_CONTACTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Anexo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Anexo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Ap_Materno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Ap_Materno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Ap_Paterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Ap_Paterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Celular') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Celular' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Cod_Telefono') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Telefono' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Cod_TipoDocumento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocumento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Cod_TipoRelacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoRelacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Email_Empresarial') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Email_Empresarial' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Email_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Email_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Fecha_Incorporacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Incorporacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Id_ClienteContacto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteContacto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Nombres') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Nombres' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Nro_Documento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Nro_Documento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CONTACTO', 'Nro_Telefono') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CONTACTO', -- Nombre_Tabla - VARCHAR
                         'Nro_Telefono' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_CUENTABANCARIA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Cod_EntidadFinanciera') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_EntidadFinanciera' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Cod_TipoCuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Cuenta_Interbancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Cuenta_Interbancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Des_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Des_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Flag_Principal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Flag_Principal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'NroCuenta_Bancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'NroCuenta_Bancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_CUENTABANCARIA', 'Obs_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_CUENTABANCARIA', -- Nombre_Tabla - VARCHAR
                         'Obs_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_PRODUCTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Cod_TipoDescuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDescuento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PRODUCTO', 'Obs_ClienteProducto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PRODUCTO', -- Nombre_Tabla - VARCHAR
                         'Obs_ClienteProducto' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_PROVEEDOR'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Ap_Materno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Ap_Materno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Ap_Paterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Ap_Paterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_CondicionCliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_CondicionCliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_EstadoCliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoCliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_FormaPago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_FormaPago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_Nacionalidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_Nacionalidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_Sexo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_Sexo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_TipoCliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_TipoDocumento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDocumento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_Ubigeo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_Ubigeo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Email1') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Email1' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Email2') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Email2' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Fax') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Fax' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Fecha_Nacimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Fecha_Nacimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Firma') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Firma' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Foto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Foto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Limite_Credito') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Limite_Credito' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Nombres') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Nombres' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Nro_Documento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Nro_Documento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Num_DiaCredito') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Num_DiaCredito' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Obs_Cliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Obs_Cliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'PaginaWeb') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'PaginaWeb' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'RUC_Natural') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'RUC_Natural' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Ruta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Ruta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Telefono1') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Telefono1' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Telefono2') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Telefono2' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Ubicacion_EjeX') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Ubicacion_EjeX' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_PROVEEDOR', 'Ubicacion_EjeY') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_PROVEEDOR', -- Nombre_Tabla - VARCHAR
                         'Ubicacion_EjeY' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_VEHICULOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Cod_Placa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Placa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Color') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Color' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Marca') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Marca' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Modelo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Modelo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Placa_Vigente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Placa_Vigente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Propiestarios') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Propiestarios' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VEHICULOS', 'Sede') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VEHICULOS', -- Nombre_Tabla - VARCHAR
                         'Sede' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CLIENTE_VISITAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_ClienteVisita') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_ClienteVisita' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_Resultado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Resultado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_TipoVisita') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoVisita' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_UsuarioResponsable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioResponsable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Cod_UsuarioVendedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioVendedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Comentarios') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Comentarios' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Des_Compromiso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Des_Compromiso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Fecha_HoraCompromiso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_HoraCompromiso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Fecha_HoraVisita') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_HoraVisita' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Flag_Compromiso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Compromiso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CLIENTE_VISITAS', 'Ruta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CLIENTE_VISITAS', -- Nombre_Tabla - VARCHAR
                         'Ruta' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_CUENTA_CONTABLE'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Clase_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Clase_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Cod_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Cod_EntidadBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Cod_EntidadBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Des_CuentaContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Des_CuentaContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Flag_CentroCostos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Flag_CentroCostos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Flag_CuentaAnalitica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Flag_CuentaAnalitica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Flag_CuentaBancaria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Flag_CuentaBancaria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Numero_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Numero_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_CUENTA_CONTABLE', 'Tipo_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_CUENTA_CONTABLE', -- Nombre_Tabla - VARCHAR
                         'Tipo_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_DESCUENTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_DESCUENTOS', 'Aplica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Aplica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_Aplica') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Aplica' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_TipoCliente') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoCliente' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_TipoDescuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDescuento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_TipoPrecio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoPrecio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Fecha_Inicia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Id_Descuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_Descuento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Monto_Precio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Monto_Precio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_DESCUENTOS', 'Obs_Descuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_DESCUENTOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Descuento' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_EMPRESA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_EMPRESA', 'Cod_Empresa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Cod_Empresa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Cod_Ubigeo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Cod_Ubigeo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Des_Impuesto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Des_Impuesto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'EstructuraContable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'EstructuraContable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Flag_ExoneradoImpuesto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Flag_ExoneradoImpuesto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Imagen_H') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Imagen_H' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Imagen_V') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Imagen_V' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Nom_Comercial') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Nom_Comercial' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Por_Impuesto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Por_Impuesto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'RazonSocial') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'RazonSocial' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'RUC') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'RUC' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Telefonos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Telefonos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Version') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Version' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_EMPRESA', 'Web') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_EMPRESA', -- Nombre_Tabla - VARCHAR
                         'Web' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_ESTABLECIMIENTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Cod_Establecimientos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Establecimientos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Cod_TipoEstablecimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoEstablecimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Cod_Ubigeo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Ubigeo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Des_Establecimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Des_Establecimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Obs_Establecimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Establecimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_ESTABLECIMIENTOS', 'Telefono') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_ESTABLECIMIENTOS', -- Nombre_Tabla - VARCHAR
                         'Telefono' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_LICITACIONES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_LICITACIONES', 'Cod_Licitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Cod_Licitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Cod_TipoComprobante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoComprobante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Cod_TipoLicitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoLicitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Des_Licitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Des_Licitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Fecha_Facturacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Facturacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Flag_AlFinal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Flag_AlFinal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES', 'Nro_Licitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES', -- Nombre_Tabla - VARCHAR
                         'Nro_Licitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_LICITACIONES_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Cod_Licitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Licitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Descripcion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Descripcion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Nro_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Nro_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Por_Descuento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Por_Descuento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_D', 'Precio_Unitario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_D', -- Nombre_Tabla - VARCHAR
                         'Precio_Unitario' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_LICITACIONES_M'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Cod_Licitacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Cod_Licitacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Flag_Cancelado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Flag_Cancelado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Id_Movimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Id_Movimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Nro_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Nro_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_LICITACIONES_M', 'Obs_LicitacionesM') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_LICITACIONES_M', -- Nombre_Tabla - VARCHAR
                         'Obs_LicitacionesM' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_MENSAJES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_MENSAJES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Cod_UsuarioRecibe') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioRecibe' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Cod_UsuarioRemite') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioRemite' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Fecha_Recibe') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Recibe' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Fecha_Remite') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Remite' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Flag_Leido') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Flag_Leido' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Id_Mensaje') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Id_Mensaje' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MENSAJES', 'Mensaje') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MENSAJES', -- Nombre_Tabla - VARCHAR
                         'Mensaje' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_MODULO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_MODULO', 'Cod_Modulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Cod_Modulo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Des_Modulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Des_Modulo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_MODULO', 'Padre_Modulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_MODULO', -- Nombre_Tabla - VARCHAR
                         'Padre_Modulo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PADRONES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PADRONES', 'Cod_Padron') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Cod_Padron' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Cod_TipoPadron') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoPadron' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Des_Padron') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Des_Padron' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PADRONES', 'Nro_Resolucion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PADRONES', -- Nombre_Tabla - VARCHAR
                         'Nro_Resolucion' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PERFIL'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PERFIL', 'Cod_Perfil') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Cod_Perfil' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL', 'Des_Perfil') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Des_Perfil' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PERFIL_D'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PERFIL_D', 'Acceso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Acceso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Cod_Modulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Modulo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Cod_Perfil') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Cod_Perfil' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Escritura') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Escritura' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERFIL_D', 'Lectura') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERFIL_D', -- Nombre_Tabla - VARCHAR
                         'Lectura' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PERSONAL'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PERSONAL', 'ApellidoMaterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'ApellidoMaterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'ApellidoPaterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'ApellidoPaterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'AutoGeneradoAFP') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'AutoGeneradoAFP' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'AutoGeneradoEsSalud') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'AutoGeneradoEsSalud' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_AFP') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_AFP' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_BancoRemuneracion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_BancoRemuneracion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Cargo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Cargo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_CentroCostos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_CentroCostos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_CuentaCTS') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_CuentaCTS' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_EstadoCivil') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoCivil' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Local') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Local' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_Sexo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Sexo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_TipoDoc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDoc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_UsuarioLogin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioLogin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Email') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Email' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Fecha_Ingreso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Ingreso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Fecha_InsESSALUD') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_InsESSALUD' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Fecha_Nacimiento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Nacimiento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Flag_CertificadoAntPoliciales') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_CertificadoAntPoliciales' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Flag_CertificadorAntJudiciales') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_CertificadorAntJudiciales' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Flag_CertificadoSalud') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_CertificadoSalud' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Flag_DeclaracionBienes') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_DeclaracionBienes' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Flag_OtrosDocumentos') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Flag_OtrosDocumentos' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Grupo_Sanguinio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Grupo_Sanguinio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Num_CuentaCTS') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Num_CuentaCTS' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Num_CuentaRemuneracion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Num_CuentaRemuneracion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Num_Doc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Num_Doc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Obs_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Obs_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'PrimeroNombre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'PrimeroNombre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Ref_Direccion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Ref_Direccion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'SegundoNombre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'SegundoNombre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL', 'Telefono') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL', -- Nombre_Tabla - VARCHAR
                         'Telefono' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PERSONAL_PARENTESCO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'ApellidoMaterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'ApellidoMaterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'ApellidoPaterno') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'ApellidoPaterno' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Cod_Personal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Cod_Personal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Cod_TipoDoc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDoc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Cod_TipoParentesco') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoParentesco' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Item_Parentesco') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Item_Parentesco' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Nombres') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Nombres' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Num_Doc') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Num_Doc' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PERSONAL_PARENTESCO', 'Obs_Parentesco') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PERSONAL_PARENTESCO', -- Nombre_Tabla - VARCHAR
                         'Obs_Parentesco' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTO_DETALLE'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Cantidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Cantidad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Cod_TipoDetalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoDetalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Id_ProductoDetalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Id_ProductoDetalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_DETALLE', 'Item_Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_DETALLE', -- Nombre_Tabla - VARCHAR
                         'Item_Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTO_IMAGEN'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Cod_TipoImagen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoImagen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Imagen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Imagen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_IMAGEN', 'Item_Imagen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_IMAGEN', -- Nombre_Tabla - VARCHAR
                         'Item_Imagen' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTO_PRECIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Cod_TipoPrecio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoPrecio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_PRECIO', 'Valor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_PRECIO', -- Nombre_Tabla - VARCHAR
                         'Valor' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTO_STOCK'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cantidad_Min') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cantidad_Min' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_Almacen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_Almacen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_Moneda') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_Moneda' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_UnidadMedida') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedida' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_UnidadMedidaMin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_UnidadMedidaMin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Peso') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Peso' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Precio_Compra') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Precio_Compra' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Precio_Flete') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Precio_Flete' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Precio_Venta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Precio_Venta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Stock_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Stock_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Stock_Max') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Stock_Max' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_STOCK', 'Stock_Min') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_STOCK', -- Nombre_Tabla - VARCHAR
                         'Stock_Min' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTO_TASA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Cod_Libro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Cod_Libro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Cod_Tasa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Cod_Tasa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Cod_TipoTasa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoTasa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Des_Tasa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Des_Tasa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Obs_Tasa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Obs_Tasa' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTO_TASA', 'Por_Tasa') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTO_TASA', -- Nombre_Tabla - VARCHAR
                         'Por_Tasa' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_PRODUCTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_PRODUCTOS', 'Caracteristicas') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Caracteristicas' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_Categoria') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Categoria' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_Fabricante') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Fabricante' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_Garantia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Garantia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_Marca') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Marca' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_ProductoSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_ProductoSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_TipoExistencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoExistencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_TipoOperatividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoOperatividad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_TipoProducto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoProducto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Contra_Cuenta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Contra_Cuenta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Cuenta_Contable') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cuenta_Contable' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Des_CortaProducto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Des_CortaProducto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Des_LargaProducto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Des_LargaProducto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Flag_Stock') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Flag_Stock' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Id_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Id_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Nom_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Nom_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Obs_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_PRODUCTOS', 'Porcentaje_Utilidad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Porcentaje_Utilidad' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_SUCURSAL'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_SUCURSAL', 'Cabecera_Pagina') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cabecera_Pagina' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Cod_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Cod_Ubigeo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cod_Ubigeo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Cod_UsuarioAdm') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAdm' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Dir_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Dir_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Nom_Sucursal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Nom_Sucursal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Pie_Pagina') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Pie_Pagina' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Por_UtilidadMax') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Por_UtilidadMax' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUCURSAL', 'Por_UtilidadMin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUCURSAL', -- Nombre_Tabla - VARCHAR
                         'Por_UtilidadMin' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_SUNAT_CLASE'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Cod_Clase') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Cod_Clase' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Cod_Familia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Cod_Familia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Des_Clase') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Des_Clase' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_CLASE', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_CLASE', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_SUNAT_FAMILIA'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Cod_Familia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Familia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Cod_Segmento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Cod_Segmento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Des_Familia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Des_Familia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_FAMILIA', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_FAMILIA', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_SUNAT_PRODUCTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_Clase') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Clase' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_Familia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Familia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_Segmento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Segmento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Des_Producto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Des_Producto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_PRODUCTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_PRODUCTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_SUNAT_SEGMENTO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Cod_Segmento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_Segmento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Des_Segmento') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Des_Segmento' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_SUNAT_SEGMENTO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_SUNAT_SEGMENTO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'PRI_USUARIO'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('PRI_USUARIO', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Cod_Perfil') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Perfil' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Cod_Usuarios') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Cod_Usuarios' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Contrasena') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Contrasena' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Foto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Foto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Nick') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Nick' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Pregunta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Pregunta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('PRI_USUARIO', 'Respuesta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'PRI_USUARIO', -- Nombre_Tabla - VARCHAR
                         'Respuesta' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'SOP_ASISTENCIAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Cod_UsuarioAsistencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAsistencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Id_Incidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_Incidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Item') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Item' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Obs_Asistencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Obs_Asistencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_ASISTENCIAS', 'Tiempo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_ASISTENCIAS', -- Nombre_Tabla - VARCHAR
                         'Tiempo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'SOP_INCIDENCIAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_MedioOrigen') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_MedioOrigen' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_Prioridad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Prioridad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_TipoIncidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoIncidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_UsuarioIncidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioIncidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Detalle') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Detalle' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Id_Incidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_Incidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Id_Terminal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Id_Terminal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Obs_Incidencia') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Obs_Incidencia' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Pregunta1') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Pregunta1' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Pregunta2') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Pregunta2' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Pregunta3') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Pregunta3' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_INCIDENCIAS', 'Respuesta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_INCIDENCIAS', -- Nombre_Tabla - VARCHAR
                         'Respuesta' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'SOP_SERVICIOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('SOP_SERVICIOS', 'Cod_EstadoServicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoServicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Cod_TipoServicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoServicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Cod_Usuario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Usuario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Id_ComprobantePago') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Id_ComprobantePago' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Id_Servicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Id_Servicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Monto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Monto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Nom_Servicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Nom_Servicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Nro_Contrato') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Nro_Contrato' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Obs_Servicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Obs_Servicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Password') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Password' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SERVICIOS', 'Ruta_Servicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SERVICIOS', -- Nombre_Tabla - VARCHAR
                         'Ruta_Servicio' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'SOP_SUNAT'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('SOP_SUNAT', 'Cod_TipoUsuario') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Cod_TipoUsuario' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Cod_UsuarioSunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioSunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Contraseña') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Contraseña' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Id_Sunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Id_Sunat' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_SUNAT', 'Obs_Sunat') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_SUNAT', -- Nombre_Tabla - VARCHAR
                         'Obs_Sunat' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'SOP_TERMINALES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('SOP_TERMINALES', 'Cod_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Cod_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Des_Terminal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Des_Terminal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Fecha_Creacion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Creacion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Flag_Estado') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Flag_Estado' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_AnyDesk') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_AnyDesk' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_ClienteProveedor') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_ClienteProveedor' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_Otros') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_Otros' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_Sistema') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_Sistema' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_TeamViewer') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_TeamViewer' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Id_Terminal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Id_Terminal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'MAC_Terminal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'MAC_Terminal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Obs_Terminal') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Obs_Terminal' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Pass_AnyDesk') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Pass_AnyDesk' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Pass_Otros') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Pass_Otros' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Pass_Teamviewer') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Pass_Teamviewer' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('SOP_TERMINALES', 'Serie_Sistema') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'SOP_TERMINALES', -- Nombre_Tabla - VARCHAR
                         'Serie_Sistema' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TAR_ACTIVIDADES'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_Actividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_Actividad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_ActividadPadre') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_ActividadPadre' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_EstadoActividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_EstadoActividad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_Proyecto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_Proyecto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Nom_Actividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Nom_Actividad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ACTIVIDADES', 'Obs_Actividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ACTIVIDADES', -- Nombre_Tabla - VARCHAR
                         'Obs_Actividad' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TAR_ALERTAS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TAR_ALERTAS', 'Cod_Alerta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Alerta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Cod_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Des_Alerta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Des_Alerta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Fecha_Alerta') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Alerta' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Fecha_Hora') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Hora' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Flag_Activo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Flag_Activo' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_ALERTAS', 'Titulo') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_ALERTAS', -- Nombre_Tabla - VARCHAR
                         'Titulo' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TAR_CRONOMETROS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TAR_CRONOMETROS', 'Cod_Actividad') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Cod_Actividad' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Cod_Proyecto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Cod_Proyecto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Fecha_Fin') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Fin' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Fecha_Inicio') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Inicio' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Id_Cronometro') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Id_Cronometro' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_CRONOMETROS', 'Notas') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_CRONOMETROS', -- Nombre_Tabla - VARCHAR
                         'Notas' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TAR_PROYECTOS'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TAR_PROYECTOS', 'Cod_Area') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Area' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Cod_Proyecto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_Proyecto' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Cod_UsuarioAct') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioAct' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Cod_UsuarioReg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Cod_UsuarioReg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Fecha_Act') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Act' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TAR_PROYECTOS', 'Nom_Proyecto') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TAR_PROYECTOS', -- Nombre_Tabla - VARCHAR
                         'Nom_Proyecto' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TMP_REGISTRO_LOG'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Accion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Accion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Id') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Id' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Id_Fila') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Id_Fila' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Nombre_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Nombre_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG', 'Script') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG', -- Nombre_Tabla - VARCHAR
                         'Script' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        IF NOT EXISTS
        (
            SELECT name
            FROM sysobjects
            WHERE name = N'TMP_REGISTRO_LOG_H'
                  AND type = 'U'
        )
            BEGIN
                SET @Contador = @Contador + 1;
                INSERT INTO #tempTablaResultado
                VALUES
                (@Contador, -- Contador - INT
                 'NO EXISTE LA TABLA', -- Error - VARCHAR
                 'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                 '' -- Nombre_Columna - VARCHAR
                );
        END;
            ELSE
            BEGIN
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Accion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Accion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Fecha_Reg') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Fecha_Reg_Insercion') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Fecha_Reg_Insercion' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Id') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Id' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Id_Fila') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Id_Fila' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Nombre_Tabla') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Nombre_Tabla' -- Nombre_Columna - VARCHAR
                        );
                END;
                IF COL_LENGTH('TMP_REGISTRO_LOG_H', 'Script') IS NULL
                    BEGIN
                        SET @Contador = @Contador + 1;
                        INSERT INTO #tempTablaResultado
                        VALUES
                        (@Contador, -- Contador - INT
                         'NO EXISTE LA COLUMNA', -- Error - VARCHAR
                         'TMP_REGISTRO_LOG_H', -- Nombre_Tabla - VARCHAR
                         'Script' -- Nombre_Columna - VARCHAR
                        );
                END;
        END;
        SELECT ttr.*
        FROM #tempTablaResultado ttr;
    END;
GO