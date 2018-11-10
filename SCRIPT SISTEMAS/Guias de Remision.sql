IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_SUCURSAL_TraerSucursalesActivas' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas
GO

CREATE PROCEDURE USP_PRI_SUCURSAL_TraerSucursalesActivas
WITH ENCRYPTION
AS
BEGIN
	SELECT ps.Cod_Sucursal, ps.Nom_Sucursal, ps.Dir_Sucursal, ps.Por_UtilidadMax, ps.Por_UtilidadMin, ps.Cod_UsuarioAdm, ps.Cabecera_Pagina, ps.Pie_Pagina, ps.Cod_Ubigeo,COALESCE(ps.Cod_UsuarioAct,ps.Cod_UsuarioReg) Cod_Usuario,COALESCE(ps.Fecha_Act,ps.Fecha_Reg) Fecha_UltimaModificacion FROM dbo.PRI_SUCURSAL ps WHERE ps.Flag_Activo = 1
END
GO
