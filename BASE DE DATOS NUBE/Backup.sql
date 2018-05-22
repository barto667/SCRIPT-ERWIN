DECLARE @NombreArchivo as Varchar(512);
set @NombreArchivo = N'D:\COPIA_SEGURIDAD\PALERPloayza_' + replace(CONVERT(VARCHAR,GETDATE(),103),'/','') + '_' + replace(CONVERT(VARCHAR,GETDATE(),108),':','')+'.bak';
BACKUP DATABASE PALERPchincheros
TO  DISK = @NombreArchivo
WITH NOFORMAT, NOINIT,  NAME = N'PALERPloayza-Completa Base de datos Copia de seguridad', SKIP, 
NOREWIND, NOUNLOAD,  STATS = 10, COMPRESSION
GO

--Script que detecta y elimina duplicados de DNI

select pcp.Id_ClienteProveedor ,pcp.Nro_Documento from dbo.PRI_CLIENTE_PROVEEDOR pcp
inner join dbo.PRI_CLIENTE_PROVEEDOR pcp2
on pcp.Nro_Documento = pcp2.Nro_Documento
and pcp.Id_ClienteProveedor > pcp2.Id_ClienteProveedor

DELETE FROM dbo.PRI_CLIENTE_PROVEEDOR WHERE dbo.PRI_CLIENTE_PROVEEDOR.Id_ClienteProveedor in(
select pcp.Id_ClienteProveedor from dbo.PRI_CLIENTE_PROVEEDOR pcp
inner join dbo.PRI_CLIENTE_PROVEEDOR pcp2
on pcp.Nro_Documento = pcp2.Nro_Documento
and pcp.Id_ClienteProveedor > pcp2.Id_ClienteProveedor
)
