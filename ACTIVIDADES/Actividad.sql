--IF EXISTS (SELECT * 
--	   FROM   master..sysdatabases 
--	   WHERE  name = N'E_PROYECTOS')
--	DROP DATABASE E_PROYECTOS
--GO

--CREATE DATABASE E_PROYECTOS
--GO
--USE E_PROYECTOS
--GO

----Creamos las tablas
--IF OBJECT_ID('PRI_AREAS', 'U') IS NOT NULL
--  DROP TABLE PRI_AREAS
--GO

--CREATE TABLE PRI_AREAS
--(
--	Cod_Area varchar(32) NOT NULL PRIMARY KEY,
--	Nom_Area varchar(max) NOT NULL
--)
--GO

--IF OBJECT_ID('PRI_ESTADOS_USUARIO', 'U') IS NOT NULL
--    DROP TABLE PRI_ESTADOS_USUARIO
--GO

--CREATE TABLE PRI_ESTADOS_USUARIO
--(
--	Cod_Estado varchar(32) NOT NULL PRIMARY KEY,
--	Nom_Estado varchar(max) NOT NULL,

--)
--GO

--IF OBJECT_ID('PRI_USUARIOS', 'U') IS NOT NULL
--  DROP TABLE PRI_USUARIOS
--GO

--CREATE TABLE PRI_USUARIOS
--(
--	Id_Usuario int IDENTITY (1, 1) NOT NULL PRIMARY KEY,
--	Cod_Area varchar(max) NOT NULL,
--	Nom_Usuario varchar(max) NOT NULL,
--	Estado varchar(32) NOT NULL FOREIGN KEY REFERENCES dbo.PRI_ESTADOS_USUARIO(Cod_Estado)
--)
--GO

--IF OBJECT_ID('PRI_ESTADOS_ACTIVIDADES', 'U') IS NOT NULL
--    DROP TABLE PRI_ESTADOS_ACTIVIDADES
--GO

--CREATE TABLE PRI_ESTADOS_ACTIVIDADES
--(
--	Cod_Estado varchar(32) NOT NULL PRIMARY KEY,
--	Nom_Estado varchar(max) NOT NULL,
--)
--GO

--IF OBJECT_ID('PRI_ACTIVIDADES', 'U') IS NOT NULL
--  DROP TABLE PRI_ACTIVIDADES
--GO

--CREATE TABLE PRI_ACTIVIDADES
--(
--	Id_Actividades int IDENTITY (1, 1)  PRIMARY KEY,
--	Descripcion varchar(max) NOT NULL,
--	Fecha_Inicio datetime NOT NULL,
--	Fecha_Fin datetime  NULL ,
--	Id_Usuario int NOT NULL FOREIGN KEY REFERENCES dbo.PRI_USUARIOS(Id_Usuario),
--	Cod_Estado varchar(32) NOT NULL FOREIGN KEY REFERENCES dbo.PRI_ESTADOS_ACTIVIDADES(Cod_Estado),
--	Flag bit NOT NULL
--)
--GO

--IF OBJECT_ID('PRI_PERMISOS', 'U') IS NOT NULL
--  DROP TABLE PRI_PERMISOS
--GO

--CREATE TABLE PRI_PERMISOS
--(
--	Id_Permiso int IDENTITY (1, 1)  PRIMARY KEY,
--	Id_Usuario int FOREIGN KEY REFERENCES dbo.PRI_USUARIOS(Id_Usuario),
--	Descripcion varchar(max) NOT NULL,
--	Fecha_Solicitud datetime NOT NULL,
--	Fecha_Inicio datetime NOT NULL ,
--	Fecha_Fin datetime NOT NULL
--)
--GO

--Metodos de guardado,eliminacion
--PRI_ACTIVIDADES
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_ACTIVIDADES_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_ACTIVIDADES_G
GO

CREATE PROCEDURE USP_PRI_ACTIVIDADES_G
    @Id_Actividades int = NULL,
    @Descripcion varchar(max),
    @Fecha_Inicio datetime,
    @Fecha_Fin datetime,
    @Id_Usuario int,
    @Cod_Estado varchar(32),
    @Flag bit
WITH ENCRYPTION
AS
BEGIN
    IF(@Id_Actividades IS NOT NULL)
    BEGIN
	   INSERT dbo.PRI_ACTIVIDADES
	   (
		  --Id_Actividades - this column value is auto-generated
		  Descripcion,
		  Fecha_Inicio,
		  Fecha_Fin,
		  Id_Usuario,
		  Cod_Estado,
		  Flag
	   )
	   VALUES
	   (
		  @Descripcion,
		  @Fecha_Inicio,
		  @Fecha_Fin,
		  @Id_Usuario,
		  @Cod_Estado,
		  @Flag
	   )
    END
    ELSE
    BEGIN
    IF EXISTS (SELECT pa.* FROM dbo.PRI_ACTIVIDADES pa WHERE pa.Id_Actividades=@Id_Actividades)
    BEGIN
	   UPDATE dbo.PRI_ACTIVIDADES
	   SET
		  --Id_Actividades - this column value is auto-generated
		  dbo.PRI_ACTIVIDADES.Descripcion = @Descripcion, -- varchar
		  dbo.PRI_ACTIVIDADES.Fecha_Inicio = @Fecha_Inicio, -- datetime
		  dbo.PRI_ACTIVIDADES.Fecha_Fin = @Fecha_Fin, -- datetime
		  dbo.PRI_ACTIVIDADES.Id_Usuario = @Id_Usuario, -- int
		  dbo.PRI_ACTIVIDADES.Cod_Estado = @Cod_Estado, -- varchar
		  dbo.PRI_ACTIVIDADES.Flag = @Flag -- bit
	   WHERE dbo.PRI_ACTIVIDADES.Id_Actividades=@Id_Actividades
    END
    END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_ACTIVIDADES_E' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_ACTIVIDADES_E
GO

CREATE PROCEDURE USP_PRI_ACTIVIDADES_E
    @Id_Actividades int 
WITH ENCRYPTION
AS
BEGIN
    IF  EXISTS (SELECT pa.* FROM dbo.PRI_ACTIVIDADES pa WHERE pa.Id_Actividades=@Id_Actividades)
    BEGIN
	   DELETE dbo.PRI_ACTIVIDADES WHERE dbo.PRI_ACTIVIDADES.Id_Actividades=@Id_Actividades
    END
END
GO

--PRI AREAS
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_AREAS_G' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_AREAS_G
GO

CREATE PROCEDURE USP_PRI_AREAS_G
    @Cod_Area varchar(32),
    @Nom_Area varchar(max)
WITH ENCRYPTION
AS
BEGIN
    IF EXISTS (SELECT pa.* FROM dbo.PRI_AREAS pa WHERE pa.Cod_Area=@Cod_Area)
    BEGIN
	   UPDATE dbo.PRI_AREAS
	   SET
	       --dbo.PRI_AREAS.Cod_Area = '', -- varchar
	       dbo.PRI_AREAS.Nom_Area = @Nom_Area -- varchar
	   WHERE dbo.PRI_AREAS.Cod_Area = @Cod_Area
    END
    ELSE
    BEGIN
	   INSERT dbo.PRI_AREAS
	   (
	       Cod_Area,
	       Nom_Area
	   )
	   VALUES
	   (
	       @Cod_Area,
		  @Nom_Area
	   )
    END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'USP_PRI_AREAS_E' 
	 AND type = 'P'
)
  DROP PROCEDURE USP_PRI_AREAS_E
GO

CREATE PROCEDURE USP_PRI_AREAS_E
    @Cod_Area varchar(32) 
WITH ENCRYPTION
AS
BEGIN
    DELETE dbo.PRI_AREAS WHERE dbo.PRI_AREAS.Cod_Area=@Cod_Area
END
GO

--PRI_ESTADOS_ACTIVIDADES
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'PRI_ESTADOS_ACTIVIDADES_G' 
	 AND type = 'P'
)
  DROP PROCEDURE PRI_ESTADOS_ACTIVIDADES_G
GO

CREATE PROCEDURE PRI_ESTADOS_ACTIVIDADES_G
    @Cod_Estado varchar(32),
    @Nom_Estado varchar(max)
WITH ENCRYPTION
AS
BEGIN
    IF EXISTS (SELECT pea.* FROM dbo.PRI_ESTADOS_ACTIVIDADES pea WHERE pea.Cod_Estado=@Cod_Estado)
    BEGIN
	   UPDATE dbo.PRI_ESTADOS_ACTIVIDADES
	   SET
	       dbo.PRI_ESTADOS_ACTIVIDADES.Cod_Estado = @Cod_Estado, -- varchar
	       dbo.PRI_ESTADOS_ACTIVIDADES.Nom_Estado = @Nom_Estado -- varchar
		  WHERE dbo.PRI_ESTADOS_ACTIVIDADES.Cod_Estado=@Cod_Estado
    END
    ELSE
    BEGIN
	   INSERT dbo.PRI_ESTADOS_ACTIVIDADES
	   (
	       Cod_Estado,
	       Nom_Estado
	   )
	   VALUES
	   (
	       @Cod_Estado, -- Cod_Estado - varchar
	       @Nom_Estado -- Nom_Estado - varchar
	   )
    END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'PRI_ESTADOS_ACTIVIDADES_E' 
	 AND type = 'P'
)
  DROP PROCEDURE PRI_ESTADOS_ACTIVIDADES_E
GO

CREATE PROCEDURE PRI_ESTADOS_ACTIVIDADES_E
    @Cod_Estado varchar(32) 
WITH ENCRYPTION
AS
BEGIN
    DELETE dbo.PRI_ESTADOS_ACTIVIDADES WHERE dbo.PRI_ESTADOS_ACTIVIDADES.Cod_Estado=@Cod_Estado
END
GO

--PRI_ESTADOS_USUARIO
IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'PRI_PRI_ESTADOS_USUARIO_G' 
	 AND type = 'P'
)
  DROP PROCEDURE PRI_PRI_ESTADOS_USUARIO_G
GO

CREATE PROCEDURE PRI_PRI_ESTADOS_USUARIO_G
    @Cod_Estado varchar(32),
    @Nom_Estado varchar(max)
WITH ENCRYPTION
AS
BEGIN
    IF EXISTS (SELECT peu.* FROM dbo.PRI_ESTADOS_USUARIO peu WHERE peu.Cod_Estado=@Cod_Estado)
    BEGIN
	   UPDATE dbo.PRI_ESTADOS_USUARIO
	   SET
	       --dbo.PRI_ESTADOS_USUARIO.Cod_Estado = '', -- varchar
	       dbo.PRI_ESTADOS_USUARIO.Nom_Estado = @Nom_Estado -- varchar
		  WHERE dbo.PRI_ESTADOS_USUARIO.Cod_Estado=@Cod_Estado
    END
    ELSE
    BEGIN

	   INSERT dbo.PRI_ESTADOS_USUARIO
	   (
	       Cod_Estado,
	       Nom_Estado
	   )
	   VALUES
	   (
	       @Cod_Estado, -- Cod_Estado - varchar
	       @Nom_Estado -- Nom_Estado - varchar
	   )
    END
END
GO

IF EXISTS (
  SELECT * 
    FROM sysobjects 
   WHERE name = N'PRI_ESTADOS_USUARIO_E' 
	 AND type = 'P'
)
  DROP PROCEDURE PRI_ESTADOS_USUARIO_E
GO

CREATE PROCEDURE PRI_ESTADOS_USUARIO_E
    @Cod_Estado varchar(32) 
WITH ENCRYPTION
AS
BEGIN
    DELETE dbo.PRI_ESTADOS_USUARIO WHERE dbo.PRI_ESTADOS_USUARIO.Cod_Estado=@Cod_Estado
END
GO
