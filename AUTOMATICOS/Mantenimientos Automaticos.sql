--Crear mantenimientos programados automaticamente

--Crea una copia de seguridad de una BD determinada
--exec USP_Crear_CopiaSeguridad PALERPquillabamba,N'D:\COPIA_SEGURIDAD','bak'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_Crear_CopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_Crear_CopiaSeguridad
go
CREATE PROCEDURE USP_Crear_CopiaSeguridad
@BDActual varchar(MAX),
@RutaBackup varchar(MAX),
@Extension varchar(MAX)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @NombreArchivo as Varchar(MAX)= CONCAT( @RutaBackup,CHAR(92),@BDActual,'_',replace(CONVERT(VARCHAR,GETDATE(),103),'/','') ,'_',replace(CONVERT(VARCHAR,GETDATE(),108),':',''),'.',@Extension)
	DECLARE @NombreCopia varchar(MAX)=CONCAT(@BDActual,'-Completa Base de datos Copia de seguridad')
	BACKUP DATABASE @BDActual
	TO  DISK = @NombreArchivo
	WITH NOFORMAT, NOINIT,  NAME = @NombreCopia, SKIP, 
	NOREWIND, NOUNLOAD,  STATS = 10, COMPRESSION
END
go


--Crea un procedimiento por el cual se pueden crear tareas programadas, ejecutar sobre la bd destino
--En la ruta C:\APLICACIONES\TEMP y con extension palerp
--Crea dos copias, por defecto a las 0 y a las 12 horas 
--NumeroIntentos entero el nuemro de intentos , si es 0 si reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--HoraPrimeraCopia,HoraSegundaCopia entero que indica la hora en que sucede la copia
--tiene el formato de 24 horas de la siguiente forma HHMMSS (ej 235958- Copia a las 23 horas 59 minutos 58 segundos)
--exec USP_CrearTareaCopiaSeguridad N'COPIA 1',2,60,0,235959
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaCopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_CrearTareaCopiaSeguridad
go
CREATE PROCEDURE USP_CrearTareaCopiaSeguridad
@NombreTarea varchar(max)=N'COPIA DE SEGURIDAD',
@NumeroIntentos int = 0,
@IntervaloMinutos int = 0,
@HoraPrimeraCopia int = 0,
@HoraSegundaCopia int = 235959
WITH ENCRYPTION
AS
BEGIN
	--Borramnos la tare si existia anteriormente
	DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = @NombreTarea))
	IF (@jobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @jobId
	END

	SET @jobId=null
	--Agregamos la tarea
	EXEC msdb.dbo.sp_add_job @job_name=@NombreTarea, @enabled=1, @owner_login_name=N'sa', @job_id = @jobId OUTPUT
	--Agregamos el paso COPIA DE SEGURIDAD
	DECLARE @BDActual varchar(512) =(SELECT DB_NAME() AS [Base de datos actual])
	DECLARE @Comando varchar(MAX)= CONCAT('exec USP_Crear_CopiaSeguridad ',@BDActual,N',N''C:\APLICACIONES\TEMP''',',palerp')
	EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COPIA DE SEGURIDAD', 
			@step_id=1, 
			@retry_attempts=@NumeroIntentos, 
			@retry_interval=@IntervaloMinutos, 
			@os_run_priority=1, @subsystem=N'TSQL', 
			@command=@Comando, 
			@database_name=@BDActual, 
			@output_file_name=N'C:\APLICACIONES\TEMP\log_mantenimiento.txt',
			@flags=2

	--Agregamos las frecuencias Diario a una hora predeterminada
	DECLARE @FechaActual varchar(20) = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'PRIMERA COPIA', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@HoraPrimeraCopia,
			@schedule_id=1

	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SEGUNDA COPIA', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@HoraSegundaCopia,
			@schedule_id=1

	--Agregamos el jobserver
	EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
END
go



--Procedimiento que elimina una tarea copia de seguridad
--exec USP_EliminarTareaCopiaSeguridad N'COPIA 1'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_EliminarTareaCopiaSeguridad' AND type = 'P')
DROP PROCEDURE USP_EliminarTareaCopiaSeguridad
go
CREATE PROCEDURE USP_EliminarTareaCopiaSeguridad
@NombreTarea varchar(max)
WITH ENCRYPTION
AS
BEGIN
	--Borramnos la tare si existia anteriormente
	DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = @NombreTarea))
	IF (@jobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @jobId
	END
END
go


--Procedimiento que elimina los bakups antiguos
--Path = ruta donde estan los bakups
--Extension= extension de los archivo sin punto
--Tiempo en horas par aeliminar los backups antiguos
--exec USP_EliminarBackupsAntiguos N'C:\APLICACIONES\TEMP',bak,720
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_EliminarBackupsAntiguos' AND type = 'P')
DROP PROCEDURE USP_EliminarBackupsAntiguos
go
CREATE PROCEDURE USP_EliminarBackupsAntiguos
	@path NVARCHAR(256),
	@Extension NVARCHAR(10),
	@TiempoHoras INT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @DeleteDate NVARCHAR(50)
	DECLARE @DeleteDateTime DATETIME
	SET @DeleteDateTime = DateAdd(hh, - @TiempoHoras, GetDate())
	SET @DeleteDate = (Select Replace(Convert(nvarchar, @DeleteDateTime, 111), '/', '-') + 'T' + Convert(nvarchar, @DeleteDateTime, 108))
	EXECUTE master.dbo.xp_delete_file 0,
		@path,
		@extension,
		@DeleteDate,
		1
END
go


--Crea un procedimiento por el cual se pueden eliminar copias de seguridad en una tarea, ejecutar sobre la bd destino
--En la ruta C:\APLICACIONES\TEMP y con extension palerp
--Crea una copias, por defecto las 12 horas 
--NumeroIntentos entero el numero de intentos , si es 0 sin reintentos
--IntervaloMinutos entero que indica el intervalo de tiempo en minutos si hay numero de intentos >0
--Hora entero que indica la hora en que sucede la copia
--tiene el formato de 24 horas de la siguiente forma HHMMSS (ej 235958- Copia a las 23 horas 59 minutos 58 segundos)
--exec USP_CrearTareaEliminarCopiasSeguridad N'ELIMINAR COPIA DE SEGURIDAD',0,0,120000
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CrearTareaEliminarCopiasSeguridad' AND type = 'P')
DROP PROCEDURE USP_CrearTareaEliminarCopiasSeguridad
go
CREATE PROCEDURE USP_CrearTareaEliminarCopiasSeguridad
@NombreTarea varchar(max)=N'ELIMINAR COPIA DE SEGURIDAD',
@NumeroIntentos int = 0,
@IntervaloMinutos int = 0,
@Hora int = 12000
WITH ENCRYPTION
AS
BEGIN
	--Borramnos la tare si existia anteriormente
	DECLARE @jobId binary(16) = (SELECT job_id FROM msdb.dbo.sysjobs WHERE (name = @NombreTarea))
	IF (@jobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @jobId
	END

	SET @jobId=null
	--Agregamos la tarea
	EXEC msdb.dbo.sp_add_job @job_name=@NombreTarea, @enabled=1, @owner_login_name=N'sa', @job_id = @jobId OUTPUT
	--Agregamos el paso COPIA DE SEGURIDAD
	DECLARE @BDActual varchar(512) =(SELECT DB_NAME() AS [Base de datos actual])
	DECLARE @Comando varchar(MAX)= CONCAT('exec USP_EliminarBackupsAntiguos ',N'N''C:\APLICACIONES\TEMP''',',palerp,720')
	EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ELIMINAR COPIAS', 
			@step_id=1, 
			@retry_attempts=@NumeroIntentos, 
			@retry_interval=@IntervaloMinutos, 
			@os_run_priority=1, @subsystem=N'TSQL', 
			@command=@Comando, 
			@database_name=@BDActual, 
			@output_file_name=N'C:\APLICACIONES\TEMP\log_mantenimiento.txt',
			@flags=2

	--Agregamos las frecuencias Diario a una hora predeterminada
	DECLARE @FechaActual varchar(20) = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
	EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ELIMINAR', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@FechaActual, 
			@active_end_date=99991231, 
			@active_start_time=@Hora,
			@schedule_id=1

	--Agregamos el jobserver
	EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
END
go

--Ejecutamos los procedimientos
exec USP_CrearTareaCopiaSeguridad N'COPIA DE SEGURIDAD',2,60,080000,200000
exec USP_CrearTareaEliminarCopiasSeguridad N'ELIMINAR COPIA DE SEGURIDAD',0,0,120000


--Script de prueba
--SELECT  DISTINCT CONCAT((FORMAT(datepart(hour, DATEADD(hour,-1,cta.Fecha_Inicio)),'00')),(FORMAT(datepart(Minute, cta.Fecha_Inicio),'00')),(FORMAT(datepart(second, cta.Fecha_Inicio),'00'))) AS Hora FROM dbo.CAJ_TURNO_ATENCION cta

--SELECT  DISTINCT CONCAT((FORMAT(datepart(hour, DATEADD(hour,-1,cta.Fecha_Inicio)),'00')),'00','00') AS Hora FROM dbo.CAJ_TURNO_ATENCION cta
--where Des_Turno not like '%CIERRE%' and Cod_Turno not LIke 'C%'
