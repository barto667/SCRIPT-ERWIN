


sp_configure 'show advanced options','1'
RECONFIGURE WITH OVERRIDE;
GO
sp_configure 'xp_cmdshell','1'
RECONFIGURE WITH OVERRIDE;

DECLARE @Nombre varchar(max)

DECLARE cursorbd CURSOR LOCAL FOR
SELECT DISTINCT name FROM sys.databases
WHERE name LIKE 'PALERP%'

OPEN cursorbd 

FETCH NEXT FROM cursorbd INTO @Nombre
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC ('master..xp_cmdshell  ''Sqlcmd -S .\PALEHOST -d '+@Nombre+' -i G:\SERVIDOR.sql -o G:\SERVIDOR.txt''')
    FETCH NEXT FROM cursorbd INTO @Nombre
END
CLOSE cursorbd;
DEALLOCATE cursorbd