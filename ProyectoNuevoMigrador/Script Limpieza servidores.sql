EXEC USP_PAR_FILA_G '120','001',1,NULL,NULL,NULL,NULL,0,1,'MIGRACION';
GO
DELETE dbo.TMP_REGISTRO_LOG
GO


SELECT session_id
FROM sys.dm_exec_sessions
WHERE login_name = 'WIN-N4RPOF550O4\Administrador'

KILL 56

SELECT name, suser_sname(owner_sid) AS DBOwner FROM sys.databases

use PALERPmaster 
GO
sp_changedbowner 'sa'