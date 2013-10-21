CREATE SCHEMA mario_killers AUTHORIZATION gd

CREATE TABLE Persona (
	Persona_ID int,
	Persona_Nombre varchar(255),
	Persona_Apellido varchar(255),
	Persona_Documento numeric(18, 0),
	Persona_Fecha_Nac datetime,
	Persona_Direccion varchar(255),
	Persona_Telefono numeric(18, 0),
	Persona_Mail varchar(255),
    
    -- Campos faltantes
	Persona_Tipo_Doc int,
	Persona_Grupo_Familia int,
	Persona_Nro_Familiar int
	
	CONSTRAINT PK_Persona PRIMARY KEY (Persona_ID)
)

CREATE TABLE Usuario (
	Usuario_Nombre varchar(255),
	Usuario_Persona int,
	Usuario_Password char(64), -- SHA256
	Usuario_Intentos_Login int,
	CONSTRAINT PK_Usuario PRIMARY KEY (Usuario_Nombre)
) 

CREATE TABLE Plan_Med (
	Plan_Med_Codigo numeric(18, 0),
	Plan_Med_Descripcion varchar(255),
	Plan_Med_Precio_Bono_Consulta numeric(18, 0),
	Plan_Med_Precio_Bono_Farmacia numeric(18, 0)
	CONSTRAINT PK_Plan_Med PRIMARY KEY (Plan_Med_Codigo)
)

CREATE TABLE Compra (
	Compra_ID int,
	Compra_Fecha datetime,
	Compra_Persona int,
	Compra_Plan int -- Para qué guardabamos esto?
	CONSTRAINT PK_Compra PRIMARY KEY (Compra_ID)
)

CREATE TABLE Afiliado (
	Afiliado_Persona int,
	Afiliado_ID_Grupo int,
	Afiliado_Activo bit
	CONSTRAINT PK_Afiliado PRIMARY KEY (Afiliado_Persona)
)

CREATE TABLE Profesional (
	Profesional_Persona int,
	Profesional_Matricula int, -- unique
	Profesional_Activo bit
	CONSTRAINT PK_Profesional PRIMARY KEY (Profesional_Persona)
)

CREATE TABLE Especialidad_Profesional (
	EspecPro_Profesional int,
	EspecPro_Especialidad int
	CONSTRAINT PK_EspecPro PRIMARY KEY (EspecPro_Profesional, EspecPro_Especialidad)
)

CREATE TABLE Especialidad (
	Especialidad_Codigo numeric(18, 0),
	Especialidad_Descripcion varchar(255),
	Especialidad_Tipo numeric(18, 0),
	CONSTRAINT PK_Especialidad PRIMARY KEY (Especialidad_Codigo)
)

CREATE TABLE Tipo_Especialidad (
	Tipo_Especialidad_Codigo numeric(18, 0),
	Tipo_Especialidad_Descripcion varchar(255),
	CONSTRAINT PK_Tipo_Especialidad PRIMARY KEY (Tipo_Especialidad_Codigo)
)

CREATE TABLE Turno (
	Turno_ID int,
	Turno_Persona int,
	Turno_Profesional int,
	Turno_Horario datetime,
	Turno_Especialidad int,
	Turno_Activo bit,
	Turno_Horario_Llegada datetime
)

CREATE TABLE Bono_Consulta (
	Bono_Consulta_ID_Compra int,
	Bono_Consulta_Contador int,
	Bono_Consulta_Turno int
)

CREATE TABLE Bono_Farmacia (
	Bono_Farmacia_ID_Compra int,
	Bono_Farmacia_Receta int
)

CREATE TABLE Medicamento (
	Medicamento_ID int,
	Medicamento_Detalle varchar(255)
)

CREATE TABLE Medicamento_Receta (
	MedRec_Medicamento_ID int,
	MedRec_Receta_ID int,
	MedRec_Cantidad int -- constraint  <= 3
)

CREATE TABLE Receta (
	Receta_ID int,
	Receta_Atencion int
)

CREATE TABLE Atencion (
	Atencion_Turno int,
	Atencion_Fecha datetime,
	Atencion_Diagnostico varchar(255)
)

CREATE TABLE Sintoma (
	Sintoma_Atencion int,
	Sintoma_Detalle varchar(255)
)
