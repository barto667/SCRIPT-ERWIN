--Tabla que contiene las empresas
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_EMPRESA' 
	  AND 	 type = 'U')
    DROP TABLE EMP_EMPRESA
GO

CREATE TABLE EMP_EMPRESA (
Cod_Empresa varchar(20)  PRIMARY KEY NOT NULL,
RUC varchar(max) NOT NULL,
Nombre_Comercial varchar(max) NOT NULL,
Razon_Social varchar(max) NOT NULL,
Ubigeo_Empresa varchar(max) NOT NULL,
Flag_Exogenarado BINARY NOT NULL,
Estado_Empresa BINARY NOT NULL,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la lista de temviewer o conexiones que se manejan
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_CONEXIONES' 
	  AND 	 type = 'U')
    DROP TABLE EMP_CONEXIONES
GO

CREATE TABLE EMP_CONEXIONES (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Tipo_Conexion varchar(max) NOT NULL,
Id_Conexion varchar(max),
Password_Conexion varchar(max),
Estado_Conexion BINARY NOT NULL,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la lista de certificado manejados
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_CERTIFICADOS' 
	  AND 	 type = 'U')
    DROP TABLE EMP_CERTIFICADOS
GO

CREATE TABLE EMP_CERTIFICADOS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Cod_Certificado varchar(max) NOT NULL,
Password_Certificado varchar(max) NOT NULL,
Fecha_Inicio_Certificado datetime NOT NULL,
Fecha_Fin_Certificado datetime NOT NULL,
Estado_Certificado BINARY NOT NULL,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la lista de documentos y autorizaciones necesarias para algun proceso
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_DOCUMENTOS' 
	  AND 	 type = 'U')
    DROP TABLE EMP_DOCUMENTOS
GO

CREATE TABLE EMP_DOCUMENTOS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Tipo_Documento varchar(max) NOT NULL,
Cod_Documento varchar(max) NOT NULL,
Fecha_Documento datetime NOT NULL,
Estado_Documento binary NOT NULL,
Ruta_Fisica_Documento varchar(MAX),
Informacion_Adicional XML ,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la lista de usuarios por empresa
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_USUARIOS' 
	  AND 	 type = 'U')
    DROP TABLE EMP_USUARIOS
GO

CREATE TABLE EMP_USUARIOS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Tipo_Usuario varchar(max) NOT NULL,
Usuario_Usuario varchar(max) NOT NULL,
Password_Usuario varchar(max) NOT NULL,
Estado_Usuario binary NOT NULL,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la lista de contactos personales
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'EMP_CONTACTOS' 
	  AND 	 type = 'U')
    DROP TABLE EMP_CONTACTOS
GO

CREATE TABLE EMP_CONTACTOS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Codigo_Contacto varchar(max) NOT NULL,
Tipo_Contacto varchar(max) NOT NULL,
Informacion_Contacto varchar(max) NOT NULL,
Descripcion_Contacto varchar(max) NOT NULL,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene la informacion del envio
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'ENV_ENVIOS' 
	  AND 	 type = 'U')
    DROP TABLE ENV_ENVIOS
GO

CREATE TABLE ENV_ENVIOS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Cod_Envio varchar(20) PRIMARY KEY NOT NULL,
Fecha_Envio datetime NOT NULL,
Informacion_Envio varchar(max) NOT NULL,
Observacion_Envio xml,
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO

--Tabla que contiene las incidencias de los envios
IF EXISTS(SELECT name 
	  FROM 	 sysobjects 
	  WHERE  name = N'ENV_INCIDENCIAS' 
	  AND 	 type = 'U')
    DROP TABLE ENV_INCIDENCIAS
GO

CREATE TABLE ENV_INCIDENCIAS (
Cod_Empresa varchar(20) FOREIGN KEY REFERENCES dbo.EMP_EMPRESA (Cod_Empresa),
Cod_Envio varchar(20) FOREIGN KEY REFERENCES dbo.ENV_ENVIOS (Cod_Envio),
Cod_Incidencia varchar(20) NOT NULL,
Fecha_Incidencia datetime NOT NULL,
Informacion_Incidencia varchar(max) NOT NULL,
Solucion_Incidencia varchar(max) NOT NULL,
Observacion_Incidencia xml, 
Cod_UsuarioReg varchar(max) NOT NULL,
Fecha_Reg datetime NOT NULL,
Cod_UsuarioAct varchar(max),
Fecha_Act datetime 
)
GO