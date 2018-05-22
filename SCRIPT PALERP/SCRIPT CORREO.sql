-- Procedimiento para recueperar los clientes con correo
--exec USP_PRI_CLIENTE_PROVEEDOR_TraerCorreosCliente
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_PRI_CLIENTE_PROVEEDOR_TraerCorreosCliente' AND type = 'P')
DROP PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TraerCorreosCliente
go
CREATE PROCEDURE USP_PRI_CLIENTE_PROVEEDOR_TraerCorreosCliente
WITH ENCRYPTION
AS
BEGIN
    SELECT DISTINCT pcp.Nro_Documento AS Documento,pcp.Cliente AS Nombres,
	   CONCAT(pcp.Email1,' ',pcp.Email2) AS Correo
	   FROM dbo.PRI_CLIENTE_PROVEEDOR pcp
	   WHERE LEN(pcp.Email1)>0 OR LEN(pcp.Email2)>0
END
go
