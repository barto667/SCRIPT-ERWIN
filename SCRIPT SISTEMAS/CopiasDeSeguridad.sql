
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_TraerCopiasSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_TraerCopiasSeguridad;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_TraerCopiasSeguridad
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            vc.Valor_Configuracion RUTA_COPIA_SEGURIDAD, 
            vc2.Valor_Configuracion FRECUENCIA_COPIA_SEGURIDAD, 
            vc3.Valor_Configuracion INTERVALO_COPIA_SEGURIDAD, 
            vc4.Valor_Configuracion HORA_COPIA_SEGURIDAD
     FROM dbo.VIS_CONFIGURACION vc
          LEFT JOIN dbo.VIS_CONFIGURACION vc2 ON vc2.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                                                 AND vc2.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc3 ON vc3.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                                                 AND vc3.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc4 ON vc4.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                                                 AND vc4.Estado = 1
     WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
           AND vc.Estado = 1;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_TraerEliminarCopiasSeguridad
WITH ENCRYPTION
AS
     SELECT DISTINCT 
            vc.Valor_Configuracion RUTA_COPIA_SEGURIDAD, 
            vc2.Valor_Configuracion FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD, 
            vc3.Valor_Configuracion INTERVALO_ELIMINAR_COPIA_SEGURIDAD
     FROM dbo.VIS_CONFIGURACION vc
          LEFT JOIN dbo.VIS_CONFIGURACION vc2 ON vc2.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                                                 AND vc2.Estado = 1
          LEFT JOIN dbo.VIS_CONFIGURACION vc3 ON vc3.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                                                 AND vc3.Estado = 1
     WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
           AND vc.Estado = 1;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadMensual'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadMensual;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadMensual @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                     @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                     @NumeroIntentos   INT          = 0, 
                                                     @IntervaloMinutos INT          = 0, 
                                                     @DiaEjecucion     INT          = 1, 
                                                     @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_MENSUAL', 
             @enabled = 1, 
             @freq_type = 16, 
             @freq_interval = @DiaEjecucion, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadSemanal'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadSemanal;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadSemanal @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                     @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                     @NumeroIntentos   INT          = 0, 
                                                     @IntervaloMinutos INT          = 0, 
                                                     @DiaEjecucion     INT          = 1, 
                                                     @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_SEMANAL', 
             @enabled = 1, 
             @freq_type = 8, 
             @freq_interval = @DiaEjecucion, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadDiaria'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadDiaria;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadDiaria @NombreTarea      VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                    @RutaGuardado     VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                    @NumeroIntentos   INT          = 0, 
                                                    @IntervaloMinutos INT          = 0, 
                                                    @HoraEjecucion    INT          = 120000
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_DIARIO', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 1, 
             @freq_subday_interval = 24, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = @HoraEjecucion, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaCopiaSeguridadIntervalos'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos;
GO
CREATE PROCEDURE USP_CrearTareaCopiaSeguridadIntervalos @NombreTarea             VARCHAR(MAX) = N'COPIA DE SEGURIDAD', 
                                                        @RutaGuardado            VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                        @NumeroIntentos          INT          = 0, 
                                                        @IntervaloMinutos        INT          = 0, 
                                                        @IntervaloEjecucionHoras INT          = 1
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ', @BDActual, N',N''', @RutaGuardado, ''',palerp');
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'COPIA_INTERVALOS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 8, 
             @freq_subday_interval = @IntervaloEjecucionHoras, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = 0, 
             @active_end_time = 235959, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_GuardarInformacionCopia'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionCopia;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionCopia @RutaCopiaSeguridad       VARCHAR(MAX), 
                                                               @FrecuenciaCopiaSeguridad VARCHAR(MAX) = NULL, 
                                                               @IntervaloCopiaSeguridad  VARCHAR(MAX) = NULL, 
                                                               @HoraCopiaSeguridad       VARCHAR(MAX) = NULL, 
                                                               @CodUsuario               VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @IdFila INT;
            --ALMACENAMOS LA RUTA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'RUTA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @RutaCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'RUTA_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @RutaCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS LA FRECUENCIA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'FRECUENCIA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @FrecuenciaCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'FRECUENCIA_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @FrecuenciaCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS EL INTERVALOD DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'INTERVALO_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @IntervaloCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'INTERVALO_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @IntervaloCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS LA HORA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'HORA_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @HoraCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'HORA_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @HoraCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(4000);
            SELECT @ErrorMessage = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
            IF(XACT_STATE()) = -1
                BEGIN
                    ROLLBACK TRANSACTION;
            END;
            IF(XACT_STATE()) = 1
                BEGIN
                    COMMIT TRANSACTION;
            END;
            THROW;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_EjecutarCopiaSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_EjecutarCopiaSeguridad;
GO
CREATE PROCEDURE USP_EjecutarCopiaSeguridad @NombreArchivo VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_CrearTareaEliminarCopiaSeguridadIntervalos'
          AND type = 'P'
)
    DROP PROCEDURE USP_CrearTareaEliminarCopiaSeguridadIntervalos;
GO
CREATE PROCEDURE USP_CrearTareaEliminarCopiaSeguridadIntervalos @NombreTarea             VARCHAR(MAX) = N'ELIMINAR_COPIA_SEGURIDAD', 
                                                                @RutaGuardado            VARCHAR(MAX) = N'C:\APLICACIONES\TEMP', 
                                                                @NumeroIntentos          INT          = 0, 
                                                                @IntervaloMinutos        INT          = 0, 
                                                                @IntervaloEjecucionHoras INT          = 1, 
                                                                @AntiguedadHoras         INT          = 1
WITH ENCRYPTION
AS
    BEGIN
        --Borramnos la tare si existia anteriormente
        DECLARE @jobId BINARY(16)=
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE(name = @NombreTarea)
        );
        IF(@jobId IS NOT NULL)
            BEGIN
                EXEC msdb.dbo.sp_delete_job 
                     @jobId;
        END;
        SET @jobId = NULL;
        --Agregamos la tarea
        EXEC msdb.dbo.sp_add_job 
             @job_name = @NombreTarea, 
             @enabled = 1, 
             @owner_login_name = N'sa', 
             @job_id = @jobId OUTPUT;
        --Agregamos el paso COPIA DE SEGURIDAD
        DECLARE @BDActual VARCHAR(512)=
        (
            SELECT DB_NAME() AS [Base de datos actual]
        );
        --DECLARE @Comando varchar(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos ',N'N''C:\APLICACIONES\TEMP''',',palerp,720')
        DECLARE @Comando VARCHAR(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos N''', @RutaGuardado, ''',N''palerp'',', @AntiguedadHoras);
        EXEC msdb.dbo.sp_add_jobstep 
             @job_id = @jobId, 
             @step_name = N'ELIMINAR COPIA DE SEGURIDAD', 
             @step_id = 1, 
             @retry_attempts = @NumeroIntentos, 
             @retry_interval = @IntervaloMinutos, 
             @os_run_priority = 1, 
             @subsystem = N'TSQL', 
             @command = @Comando, 
             @database_name = @BDActual, 
             @output_file_name = N'C:\APLICACIONES\TEMP\log_mantenimiento.txt', 
             @flags = 2;

        --Agregamos las frecuencias Diario a una hora predeterminada
        DECLARE @FechaActual VARCHAR(20)= CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'));
        DECLARE @HoraActual VARCHAR(20)= CONCAT(FORMAT(DATEPART(hour, GETDATE()), '00'), FORMAT(DATEPART(minute, GETDATE()), '00'), FORMAT(DATEPART(second, GETDATE()), '00'));
        EXEC msdb.dbo.sp_add_jobschedule 
             @job_id = @jobId, 
             @name = N'ELIMINAR_COPIA_INTERVALOS', 
             @enabled = 1, 
             @freq_type = 4, 
             @freq_interval = 1, 
             @freq_subday_type = 8, 
             @freq_subday_interval = @IntervaloEjecucionHoras, 
             @freq_relative_interval = 0, 
             @freq_recurrence_factor = 1, 
             @active_start_date = @FechaActual, 
             @active_end_date = 99991231, 
             @active_start_time = 0, 
             @active_end_time = 235959, 
             @schedule_id = 1;
        --Agregamos el jobserver
        EXEC msdb.dbo.sp_add_jobserver 
             @job_id = @jobId;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia'
          AND type = 'P'
)
    DROP PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia;
GO
CREATE PROCEDURE USP_VIS_CONFIGURACION_GuardarInformacionEliminacionCopia @FrecuenciaEliminacionCopiaSeguridad VARCHAR(MAX) = NULL, 
                                                                          @IntervaloEliminacionCopiaSeguridad  VARCHAR(MAX) = NULL, 
                                                                          @CodUsuario                          VARCHAR(32)
WITH ENCRYPTION
AS
    BEGIN
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @IdFila INT;
            --ALMACENAMOS LA FRECUENCIA DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @FrecuenciaEliminacionCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'FRECUENCIA_ELIMINAR_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @FrecuenciaEliminacionCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            --ALMACENAMOS EL INTERVALOD DE GUARDADO
            IF EXISTS
            (
                SELECT vc.*
                FROM dbo.VIS_CONFIGURACION vc
                WHERE vc.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                      AND vc.Estado = 1
            )
                BEGIN
                    SET @IdFila =
                    (
                        SELECT vc.Nro
                        FROM dbo.VIS_CONFIGURACION vc
                        WHERE vc.Cod_Configuracion = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD'
                              AND vc.Estado = 1
                    );
                    --Actualizamos el valor
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @IntervaloEliminacionCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
                ELSE
                BEGIN
                    SET @IdFila = ISNULL(
                    (
                        SELECT MAX(vc.Nro)
                        FROM dbo.VIS_CONFIGURACION vc
                    ), 0) + 1;
                    --Insertamos
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '001', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = 'INTERVALO_ELIMINAR_COPIA_SEGURIDAD', 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '002', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = @IntervaloEliminacionCopiaSeguridad, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = NULL, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
                    EXEC dbo.USP_PAR_FILA_G 
                         @Cod_Tabla = '099', 
                         @Cod_Columna = '003', 
                         @Cod_Fila = @IdFila, 
                         @Cadena = NULL, 
                         @Numero = NULL, 
                         @Entero = NULL, 
                         @FechaHora = NULL, 
                         @Boleano = 1, 
                         @Flag_Creacion = 1, 
                         @Cod_Usuario = @CodUsuario;
            END;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(4000);
            SELECT @ErrorMessage = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
            IF(XACT_STATE()) = -1
                BEGIN
                    ROLLBACK TRANSACTION;
            END;
            IF(XACT_STATE()) = 1
                BEGIN
                    COMMIT TRANSACTION;
            END;
            THROW;
        END CATCH;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PROGRAMADOR_TAREAS_RecuperarEstado'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_RecuperarEstado;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_RecuperarEstado
WITH ENCRYPTION
AS
     IF EXISTS
     (
         SELECT 1
         FROM master.dbo.sysprocesses
         WHERE program_name = N'SQLAgent - Generic Refresher'
     )
         BEGIN
             SELECT @@SERVERNAME AS 'Instancia', 
                    CAST(1 AS BIT) Estado;
     END;
         ELSE
         BEGIN
             SELECT @@SERVERNAME AS 'Instancia', 
                    CAST(0 AS BIT) Estado;
     END;
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PROGRAMADOR_TAREAS_TraerXNombre'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre @Nombre_Tarea VARCHAR(MAX)
WITH ENCRYPTION
AS
     SELECT s.*
     FROM msdb.dbo.sysjobs s
     WHERE(name = @Nombre_Tarea);
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_PROGRAMADOR_TAREAS_TraerXNombre'
          AND type = 'P'
)
    DROP PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre;
GO
CREATE PROCEDURE USP_PROGRAMADOR_TAREAS_TraerXNombre @Nombre_Tarea VARCHAR(MAX)
WITH ENCRYPTION
AS
     SELECT s.job_id, 
            s.originating_server_id, 
            s.name, 
            CAST(s.enabled AS BIT) enabled, 
            s.description, 
            s.start_step_id, 
            s.category_id, 
            s.owner_sid, 
            s.notify_level_eventlog, 
            s.notify_level_email, 
            s.notify_level_netsend, 
            s.notify_level_page, 
            s.notify_email_operator_id, 
            s.notify_netsend_operator_id, 
            s.notify_page_operator_id, 
            s.delete_level, 
            s.date_created, 
            s.date_modified, 
            s.version_number
     FROM msdb.dbo.sysjobs s
     WHERE(name = @Nombre_Tarea);
GO
IF EXISTS
(
    SELECT *
    FROM sysobjects
    WHERE name = N'USP_TraerNombreBaseDatos'
          AND type = 'P'
)
    DROP PROCEDURE USP_TraerNombreBaseDatos;
GO
CREATE PROCEDURE USP_TraerNombreBaseDatos
WITH ENCRYPTION
AS
     SELECT DB_NAME() NombreBD;
GO
--exec USP_Crear_CopiaSeguridad PALERPquillabamba,N'D:\COPIA_SEGURIDAD','bak'
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Crear_CopiaSeguridad'
          AND type = 'P'
)
    DROP PROCEDURE USP_Crear_CopiaSeguridad;
GO
CREATE PROCEDURE USP_Crear_CopiaSeguridad @BDActual   VARCHAR(MAX), 
                                          @RutaBackup VARCHAR(MAX), 
                                          @Extension  VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @NombreArchivo AS VARCHAR(MAX)= CONCAT(@RutaBackup, CHAR(92), @BDActual, '_', replace(CONVERT(VARCHAR, GETDATE(), 103), '/', ''), '_', replace(CONVERT(VARCHAR, GETDATE(), 108), ':', ''), '.', @Extension);
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
    END;
GO
--exec USP_EliminarBackupsAntiguos N'C:\APLICACIONES\TEMP',bak,720
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_EliminarBackupsAntiguos'
          AND type = 'P'
)
    DROP PROCEDURE USP_EliminarBackupsAntiguos;
GO
CREATE PROCEDURE USP_EliminarBackupsAntiguos @path        NVARCHAR(256), 
                                             @Extension   NVARCHAR(10), 
                                             @TiempoHoras INT
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @DeleteDate NVARCHAR(50);
        DECLARE @DeleteDateTime DATETIME;
        SET @DeleteDateTime = DATEADD(hh, -@TiempoHoras, GETDATE());
        SET @DeleteDate =
        (
            SELECT Replace(CONVERT(NVARCHAR, @DeleteDateTime, 111), '/', '-') + 'T' + CONVERT(NVARCHAR, @DeleteDateTime, 108)
        );
        EXECUTE master.dbo.xp_delete_file 
                0, 
                @path, 
                @extension, 
                @DeleteDate, 
                1;
    END;
GO
IF EXISTS
(
    SELECT name
    FROM sysobjects
    WHERE name = 'USP_Crear_CopiaSeguridadXRutaExtension'
          AND type = 'P'
)
    DROP PROCEDURE USP_Crear_CopiaSeguridadXRutaExtension;
GO
CREATE PROCEDURE USP_Crear_CopiaSeguridadXRutaExtension @RutaBackup VARCHAR(MAX), 
                                                        @Extension  VARCHAR(MAX)
WITH ENCRYPTION
AS
    BEGIN
        DECLARE @BDActual VARCHAR(MAX)=
        (
            SELECT DB_NAME()
        );
        DECLARE @NombreArchivo AS VARCHAR(MAX)= CONCAT(@RutaBackup, CHAR(92), @BDActual, '_', replace(CONVERT(VARCHAR, GETDATE(), 103), '/', ''), '_', replace(CONVERT(VARCHAR, GETDATE(), 108), ':', ''), '.', @Extension);
        DECLARE @NombreCopia VARCHAR(MAX)= CONCAT(@BDActual, '-Completa Base de datos Copia de seguridad');
        BACKUP DATABASE @BDActual TO DISK = @NombreArchivo WITH NOFORMAT, NOINIT, NAME = @NombreCopia, SKIP, NOREWIND, NOUNLOAD, STATS = 10, COMPRESSION;
        SELECT @NombreArchivo Archivo
    END;
GO