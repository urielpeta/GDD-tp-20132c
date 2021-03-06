CREATE SCHEMA mario_killers AUTHORIZATION gd
GO

CREATE PROCEDURE mario_killers.agregarAtencion (@horario_atencion datetime, @sintomas text, @diagnostico text, @turno numeric(18,0), @ret numeric(18,0) output)
AS BEGIN
	INSERT INTO mario_killers.Atencion (horario_atencion, sintomas, diagnostico, turno)
	VALUES (@horario_atencion, @sintomas, @diagnostico, @turno)
	SET @ret = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE mario_killers.anularRango(@profesional numeric(18,0),
										 @fechaInicio date,
										 @fechaFin date,
										 @ret numeric(18,0) output)
AS BEGIN
	UPDATE mario_killers.Turno SET activo = 0 WHERE profesional = @profesional AND horario BETWEEN CONVERT(DATE,@fechaInicio) AND CONVERT(DATE,@fechaFin)
END
GO

CREATE PROCEDURE mario_killers.anularDia(@profesional numeric(18,0),
										 @horario date,
										 @ret numeric(18,0) output)
AS BEGIN
	UPDATE mario_killers.Turno SET activo = 0 WHERE profesional = @profesional AND CONVERT(DATE,horario) =  CONVERT(DATE,@horario)
	SET @ret = 0
END
GO

CREATE PROCEDURE mario_killers.agregarTurno(@persona numeric(18,0),
											@profesional numeric(18,0),
											@horario varchar(255),
											@especialidad numeric(18,0),
											@ret numeric(18,0) output)
AS BEGIN
	INSERT INTO mario_killers.Turno(persona, profesional, horario, especialidad)
			VALUES (@persona, @profesional, CONVERT(DATETIME, @horario), @especialidad)
	SET @ret = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE mario_killers.verificarTurno(@fecha date,
											  @horario time,
											  @profesional numeric(18,0),
											  @ret numeric(18,0) output)
AS BEGIN
	IF(EXISTS(SELECT * FROM mario_killers.Turno WHERE profesional = @profesional AND 
														CONVERT(DATE, horario) = CONVERT(DATE,@fecha) AND 
														CONVERT(TIME, horario) = CONVERT(TIME, @horario))) BEGIN SET @ret = 0 END
	ELSE BEGIN SET @ret = 1 END
END
GO

CREATE PROCEDURE mario_killers.modificarProfesional(@id numeric(18,0),
													@sexo char(1),
												   @direccion varchar(255),
												   @telefono numeric(18,0),
												   @mail varchar(255),
												   @matricula numeric(18,0),
												   @ret numeric(18,0) output)
AS BEGIN
UPDATE mario_killers.Persona SET sexo = @sexo, direccion = @direccion, telefono = @telefono, mail = @mail
WHERE id = @id
UPDATE mario_killers.Profesional SET matricula = @matricula
WHERE persona = @id
SET @ret = @id
END
GO

CREATE PROCEDURE mario_killers.agregarProfesionalSinPersona(@tipo_doc numeric(18,0),
												   @documento numeric(18,0),												   
												   @matricula numeric(18,0),
												   @ret numeric(18,0) output)
AS BEGIN
DECLARE @pers numeric(18,0)
SET @pers = (SELECT id FROM mario_killers.Persona WHERE tipo_doc = @tipo_doc AND documento = @documento)
INSERT INTO mario_killers.Profesional (persona, matricula)
	VALUES (@pers, @matricula) 
 
INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (CONVERT(VARCHAR(255),@documento), 2)	

SET @ret = @pers
END
GO

CREATE PROCEDURE mario_killers.agregarProfesional(@nombre varchar(255),
												   @apellido varchar(255),
												   @fecha_nac datetime,
												   @sexo char(1),
												   @tipo_doc numeric(18,0),
												   @documento numeric(18,0),
												   @direccion varchar(255),
												   @telefono numeric(18,0),
												   @mail varchar(255),
												   @matricula numeric(18,0),
												   @ret numeric(18,0) output)
AS BEGIN
INSERT INTO mario_killers.Persona (nombre, apellido, documento,
                                   fecha_nac, direccion, telefono,
                                   mail, tipo_doc, sexo)
	VALUES (@nombre, @apellido, @documento,
			@fecha_nac, @direccion, @telefono,
			@mail, @tipo_doc, @sexo)
DECLARE @pers numeric(18,0)
SET @pers = SCOPE_IDENTITY()
INSERT INTO mario_killers.Profesional (persona, matricula)
	VALUES (@pers, @matricula) 

DECLARE @usr VARCHAR(255)
SET @usr = CONVERT(VARCHAR(255),@documento)
INSERT INTO mario_killers.Usuario (nombre, persona, pw)
	VALUES (@usr, @pers, '24afe47d0bd302ae42643c5848d99b683264026cd12cc998e05e100bbf2dc30d')
	
INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (@usr, 2)
SET @ret = @pers
END
GO

CREATE PROCEDURE mario_killers.registrarCambioPlan(@grupo numeric(18,0),
												   @plan numeric(18,0),
												   @date datetime,
												   @desc varchar(255),
												   @ret numeric(18,0) output)
AS BEGIN
INSERT INTO mario_killers.Modificaciones_Grupo (grupo_familia, plan_medico, fecha, motivo)
	VALUES (@grupo, @plan, @date, @desc)
	SET @ret = @grupo
END
GO

CREATE PROCEDURE mario_killers.agregarAfiliadoFamilia(@nombre varchar(255),
                                               @apellido varchar(255),
                                               @fecha_nac datetime,
                                               @sexo char(1),
                                               @tipo_doc numeric(18,0),
                                               @documento numeric(18,0),
                                               @direccion varchar(255),
                                               @telefono numeric(18,0),
                                               @estado_civil numeric(18,0),
                                               @mail varchar(255),
                                               @cant_hijos numeric(18,0),
                                               @plan_medico numeric(18,0),
                                               @nro_flia numeric(18,0),
                                               @grupo_familia numeric(18,0),
                                               @ret numeric(18,0) output)
AS BEGIN
INSERT INTO mario_killers.Persona (nombre, apellido, documento,
                                   fecha_nac, direccion, telefono,
                                   mail, tipo_doc, sexo)
	VALUES (@nombre, @apellido, @documento,
			@fecha_nac, @direccion, @telefono,
			@mail, @tipo_doc, @sexo)
DECLARE @pers numeric(18,0)
SET @pers = SCOPE_IDENTITY()

IF(@nro_flia = 0) BEGIN SET @nro_flia = (SELECT COUNT(nro_familiar)+1 FROM mario_killers.Afiliado WHERE grupo_familia = @grupo_familia) END

INSERT INTO mario_killers.Afiliado (persona, estado_civil, grupo_familia, nro_familiar, cant_hijos)
	VALUES (@pers, @estado_civil, @grupo_familia, @nro_flia, @cant_hijos) 
	
DECLARE @usr VARCHAR(255)
SET @usr = CONVERT(VARCHAR(255),@documento)
INSERT INTO mario_killers.Usuario (nombre, persona, pw)
	VALUES (@usr, @pers, '1aeaeba4bdbf8907638434b60504b1037c01905bec294fb2cd5348724f2fa64f')
	
INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (@usr, 3)
SET @ret = @grupo_familia
END
GO

CREATE PROCEDURE mario_killers.agregarAfiliadoFamiliaSinPersona(@tipo_doc numeric(18,0),
                                               @documento numeric(18,0),                                               
                                               @estado_civil numeric(18,0),                                               
                                               @cant_hijos numeric(18,0),
                                               @plan_medico numeric(18,0),
                                               @nro_flia numeric(18,0),
                                               @grupo_familia numeric(18,0),
                                               @ret numeric(18,0) output)
AS BEGIN
DECLARE @pers numeric(18,0)
SET @pers = (SELECT id FROM mario_killers.Persona WHERE tipo_doc = @tipo_doc AND documento = @documento)

IF(@nro_flia = 0) BEGIN SET @nro_flia = (SELECT COUNT(nro_familiar)+1 FROM mario_killers.Afiliado WHERE grupo_familia = @grupo_familia) END

INSERT INTO mario_killers.Afiliado (persona, estado_civil, grupo_familia, nro_familiar, cant_hijos)
	VALUES (@pers, @estado_civil, @grupo_familia, @nro_flia, @cant_hijos) 

INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (CONVERT(VARCHAR(255),@documento), 3)	
SET @ret = @pers
END
GO

CREATE PROCEDURE mario_killers.agregarAfiliadoSinPersona(@tipo_doc numeric(18,0),
                                               @documento numeric(18,0),                                               
                                               @estado_civil numeric(18,0),                                              
                                               @cant_hijos numeric(18,0),
                                               @plan_medico numeric(18,0),
                                               @nro_flia numeric(18,0),
                                               @ret numeric(18,0) output)
AS BEGIN
DECLARE @pers numeric(18,0)
SET @pers = (SELECT id FROM mario_killers.Persona WHERE tipo_doc = @tipo_doc AND documento = @documento)
INSERT INTO mario_killers.Grupo_Familia (plan_medico)
	VALUES (@plan_medico)
DECLARE @grupo numeric(18,0) SET @grupo = SCOPE_IDENTITY()
INSERT INTO mario_killers.Afiliado (persona, estado_civil, grupo_familia, nro_familiar, cant_hijos)
	VALUES (@pers, @estado_civil, @grupo, @nro_flia, @cant_hijos) 

INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (CONVERT(VARCHAR(255),@documento), 3)	
SET @ret = @grupo
END
GO


CREATE PROCEDURE mario_killers.agregarAfiliado(@nombre varchar(255),
                                               @apellido varchar(255),
                                               @fecha_nac datetime,
                                               @sexo char(1),
                                               @tipo_doc numeric(18,0),
                                               @documento numeric(18,0),
                                               @direccion varchar(255),
                                               @telefono numeric(18,0),
                                               @estado_civil numeric(18,0),
                                               @mail varchar(255),
                                               @cant_hijos numeric(18,0),
                                               @plan_medico numeric(18,0),
                                               @nro_flia numeric(18,0),
                                               @ret numeric(18,0) output)
AS BEGIN
INSERT INTO mario_killers.Persona (nombre, apellido, documento,
                                   fecha_nac, direccion, telefono,
                                   mail, tipo_doc, sexo)
	VALUES (@nombre, @apellido, @documento,
			@fecha_nac, @direccion, @telefono,
			@mail, @tipo_doc, @sexo)
DECLARE @pers numeric(18,0)
SET @pers = SCOPE_IDENTITY()
INSERT INTO mario_killers.Grupo_Familia (plan_medico)
	VALUES (@plan_medico)
DECLARE @grupo numeric(18,0) SET @grupo = SCOPE_IDENTITY()
INSERT INTO mario_killers.Afiliado (persona, estado_civil, grupo_familia, nro_familiar, cant_hijos)
	VALUES (@pers, @estado_civil, @grupo, @nro_flia, @cant_hijos) 
	
DECLARE @usr VARCHAR(255)
SET @usr = CONVERT(VARCHAR(255),@documento)
INSERT INTO mario_killers.Usuario (nombre, persona, pw)
	VALUES (@usr, @pers, '1aeaeba4bdbf8907638434b60504b1037c01905bec294fb2cd5348724f2fa64f')
	
INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	VALUES (@usr, 3)	
	
SET @ret = @grupo
END
GO

CREATE PROCEDURE mario_killers.agregarPlanAlGrupo (@plan_medico numeric(18,0), @afil_viejo numeric(18,0), @ret numeric(18,0) output)
AS BEGIN
	INSERT INTO mario_killers.Grupo_Familia (plan_medico) VALUES (@plan_medico)
	DECLARE @aux numeric(18,0)
	SET @aux = SCOPE_IDENTITY()
	
	UPDATE mario_killers.Afiliado
	SET grupo_familia = @aux, nro_familiar = 01
	WHERE persona = @afil_viejo
	
	SET @ret = @aux
END
GO

CREATE PROCEDURE mario_killers.agregarRol(@nombreRol varchar(255), @ret numeric(18,0) output)
AS BEGIN
	INSERT INTO mario_killers.Rol (nombre, activo) VALUES (@nombreRol, 1)
	SET @ret = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE mario_killers.hacerCompra(@persona numeric(18, 0),@fecha datetime, @plan_medico numeric(18, 0) , @ret numeric(18,0) output)
AS BEGIN
	INSERT INTO mario_killers.Compra (fecha, persona, plan_medico) VALUES ( @fecha, @persona,@plan_medico )
	SET @ret = SCOPE_IDENTITY()
END
GO

CREATE FUNCTION mario_killers.Turno_Valido(@fecha datetime)
RETURNS BIT
AS BEGIN
	IF DATEPART(weekday, @fecha) = 1
		RETURN 0
	RETURN 1
END
GO

CREATE FUNCTION mario_killers.bono_farmacia_valido(@fecha datetime, @vencimiento datetime, @medicamento varchar(255)) RETURNS bit
AS BEGIN
	IF @vencimiento < @fecha OR @medicamento IS NOT NULL
		RETURN 0
	RETURN 1
END
GO

CREATE FUNCTION mario_killers.horario_atencion(@hora datetime) returns numeric(18, 0)
AS BEGIN
	DECLARE @result numeric(18, 0)
	SET @result = CASE
		WHEN DATEPART(DW, @hora) BETWEEN 2 AND 6
		     AND CONVERT(TIME, @hora) BETWEEN '07:00:00' AND '20:00:00'
		THEN 1
		WHEN DATEPART(DW, @hora) = 7
		     AND CONVERT(TIME, @hora) BETWEEN '10:00:00' AND '15:00:00'
		THEN 1
		ELSE 0
	END
	RETURN @result
END
GO

CREATE FUNCTION mario_killers.horas_por_semana(@profesional numeric(18, 0)) RETURNS numeric(18, 0) AS
BEGIN
	RETURN (SELECT SUM(DATEDIFF(HOUR, hora_desde, hora_hasta))
	FROM (SELECT DISTINCT dia, profesional, hora_desde, hora_hasta FROM mario_killers.Rango) f
	WHERE profesional = @profesional)
END
GO

CREATE FUNCTION mario_killers.horas_se_pisan(@profesional numeric(18, 0)) RETURNS bit AS
BEGIN
	RETURN (
		SELECT COUNT(1)
		FROM mario_killers.Rango r1 JOIN mario_killers.Rango r2 ON r1.dia = r2.dia
		WHERE r1.hora_desde < r2.hora_hasta AND r2.hora_desde < r1.hora_hasta
		      AND r1.id <> r2.id
	)
END
GO

CREATE FUNCTION mario_killers.roles_usuario(@username varchar(255))
RETURNS @roles TABLE (rol int, nombre varchar(255)) AS
BEGIN
	INSERT INTO @roles
		SELECT id, nombre
		FROM
			mario_killers.Rol_Usuario JOIN mario_killers.Rol
			ON Rol_Usuario.rol = Rol.id
		WHERE Rol_Usuario.usuario = @username
	RETURN
END
GO

CREATE PROCEDURE mario_killers.agregar_funcionalidad(@rol varchar(255), @func varchar(255)) AS
BEGIN
	INSERT INTO mario_killers.Funcionalidad_Rol (rol, funcionalidad)
		VALUES ((SELECT id FROM mario_killers.Rol WHERE nombre = @rol),
		        (SELECT id FROM mario_killers.Funcionalidad WHERE nombre = @func))
END
GO

CREATE TABLE mario_killers.Tipo_Documento (
	id numeric(18, 0) IDENTITY,
	tipo varchar(10) NOT NULL,
	PRIMARY KEY (id)
)

CREATE TABLE mario_killers.Persona (
	id numeric(18, 0) IDENTITY,
	nombre varchar(255) NOT NULL,
	apellido varchar(255) NOT NULL,
	documento numeric(18, 0) NOT NULL,
	fecha_nac datetime NOT NULL,
	direccion varchar(255) NOT NULL,
	telefono numeric(18, 0) NOT NULL,
	mail varchar(255) NOT NULL,

    -- Campos faltantes
	tipo_doc numeric(18, 0),
	sexo char(1),
	
	PRIMARY KEY (id),
	FOREIGN KEY (tipo_doc) REFERENCES mario_killers.Tipo_Documento(id),
	UNIQUE (tipo_doc, documento)
)

CREATE TABLE mario_killers.Usuario (
	nombre varchar(255),
	persona numeric(18, 0),
	pw char(64) NOT NULL, -- SHA256
	intentos_login numeric(18, 0) NOT NULL
		CONSTRAINT "intentos_login_0" DEFAULT 0,
	activo bit NOT NULL
		CONSTRAINT "usuario_activo" DEFAULT 1,
	PRIMARY KEY (nombre),
	FOREIGN KEY (persona) REFERENCES mario_killers.Persona(id),
)

CREATE TABLE mario_killers.Rol (
	id numeric(18, 0) IDENTITY,
	nombre varchar(255) NOT NULL,
	activo bit NOT NULL
		CONSTRAINT rol_activo DEFAULT 1,
	PRIMARY KEY (id)
)

CREATE TABLE mario_killers.Funcionalidad (
	id numeric(18, 0) IDENTITY,
	nombre varchar(255) NOT NULL,
	PRIMARY KEY (id)
)

CREATE TABLE mario_killers.Funcionalidad_Rol (
	rol numeric(18, 0) NOT NULL,
	funcionalidad numeric(18, 0) NOT NULL,
	FOREIGN KEY (rol) REFERENCES mario_killers.Rol(id),
	FOREIGN KEY (funcionalidad) REFERENCES mario_killers.Funcionalidad(id)
)

CREATE TABLE mario_killers.Rol_Usuario (
	usuario varchar(255),
	rol numeric(18, 0),
	FOREIGN KEY (usuario) REFERENCES mario_killers.Usuario(nombre),
	FOREIGN KEY (rol) REFERENCES mario_killers.Rol(id),
	PRIMARY KEY (usuario, rol)
)

CREATE TABLE mario_killers.Plan_Medico (
	codigo numeric(18, 0),
	descripcion varchar(255) NOT NULL,
	precio_bono_consulta numeric(18, 0) NOT NULL,
	precio_bono_farmacia numeric(18, 0) NOT NULL,
	PRIMARY KEY (codigo)
)

CREATE TABLE mario_killers.Estado_Civil (
	id numeric(18, 0) IDENTITY,
	estado varchar(255) NOT NULL,
	PRIMARY KEY (id)
)

CREATE TABLE mario_killers.Grupo_Familia (
	codigo numeric(18, 0) IDENTITY,
	plan_medico numeric(18, 0) NOT NULL,
	PRIMARY KEY (codigo),
	FOREIGN KEY (plan_medico) REFERENCES mario_killers.Plan_Medico(codigo)
)

CREATE TABLE mario_killers.Afiliado (
	-- Cantidad de consultas se calcula
	persona numeric(18, 0),
	estado_civil numeric(18, 0),
	grupo_familia numeric(18,0) NOT NULL,
	nro_familiar numeric(18, 0) NOT NULL,
	cant_hijos numeric(18, 0),
	activo bit NOT NULL
		CONSTRAINT afiliado_activo DEFAULT 1,
	PRIMARY KEY (persona),
	UNIQUE (grupo_familia, nro_familiar),
	FOREIGN KEY (persona) REFERENCES mario_killers.Persona(id),
	FOREIGN KEY (estado_civil) REFERENCES mario_killers.Estado_Civil(id),
	FOREIGN KEY (grupo_familia) REFERENCES mario_killers.Grupo_Familia(codigo)
)

CREATE TABLE mario_killers.Bajas_Afiliado (
	persona numeric(18, 0) NOT NULL,
	fecha datetime NOT NULL,
	FOREIGN KEY (persona) REFERENCES mario_killers.Afiliado(persona)
)


CREATE TABLE mario_killers.Modificaciones_Grupo (
	grupo_familia numeric(18, 0) NOT NULL,
	plan_medico numeric(18, 0) NOT NULL,
	fecha datetime NOT NULL,
	motivo varchar(255) NOT NULL,
	FOREIGN KEY (grupo_familia) REFERENCES mario_killers.Grupo_Familia(codigo),
	FOREIGN KEY (plan_medico) REFERENCES mario_killers.Plan_medico(codigo)
)

CREATE TABLE mario_killers.Profesional (
	persona numeric(18, 0),
	matricula numeric(18, 0),
	activo bit NOT NULL
		CONSTRAINT profesional_activo DEFAULT 1,
	PRIMARY KEY (persona),
	FOREIGN KEY (persona) REFERENCES mario_killers.Persona(id)
	-- UNIQUE (matricula)
)

CREATE TABLE mario_killers.Agenda (
	id numeric(18, 0) IDENTITY,
	profesional numeric(18, 0) NOT NULL,
	desde date NOT NULL,
	hasta date NOT NULL,
	activo bit NOT NULL
		CONSTRAINT agenda_activa DEFAULT 1,
	PRIMARY KEY (id),
	--CONSTRAINT max_120_dias CHECK (DATEDIFF(day, desde, hasta) <= 120),
	CONSTRAINT fechas_validas CHECK (desde < hasta),
	FOREIGN KEY (profesional) REFERENCES mario_killers.Profesional(persona)
)

CREATE TABLE mario_killers.Tipo_Especialidad (
	codigo numeric(18, 0) IDENTITY,
	descripcion varchar(255) NOT NULL,
	PRIMARY KEY (codigo)
)

CREATE TABLE mario_killers.Especialidad (
	codigo numeric(18, 0) IDENTITY,
	descripcion varchar(255) NOT NULL,
	tipo numeric(18, 0) NOT NULL,
	PRIMARY KEY (codigo),
	FOREIGN KEY (tipo) REFERENCES mario_killers.Tipo_Especialidad(codigo)
)

CREATE TABLE mario_killers.Rango (
	id numeric(18, 0) IDENTITY,
	dia numeric(18, 0) NOT NULL, -- domingo = 1, valor default de DATEFIRST
	profesional numeric(18, 0) NOT NULL,
	hora_desde time NOT NULL,
	hora_hasta time NOT NULL,
	especialidad numeric(18, 0) NOT NULL,
	activo bit NOT NULL
		CONSTRAINT rango_activo DEFAULT 1,
	PRIMARY KEY (id),
	CONSTRAINT horarios_validos CHECK (
	mario_killers.horario_atencion(CONVERT(TIME,hora_desde)) = 1 AND
	mario_killers.horario_atencion(CONVERT(TIME,hora_hasta)) = 1 AND
	hora_desde < hora_hasta
	),
	--CONSTRAINT max_horas_por_semana CHECK (mario_killers.horas_por_semana(profesional) <= 48),
	--CONSTRAINT horas_no_se_pisan CHECK (mario_killers.horas_se_pisan(profesional) = 0),
	FOREIGN KEY (profesional) REFERENCES mario_killers.Profesional(persona),
	FOREIGN KEY (especialidad) REFERENCES mario_killers.Especialidad(codigo)
)

CREATE TABLE mario_killers.Especialidad_Profesional (
	profesional numeric(18, 0),
	especialidad numeric(18, 0),
	PRIMARY KEY (profesional, especialidad),
	FOREIGN KEY (profesional) REFERENCES mario_killers.Profesional(persona),
	FOREIGN KEY (especialidad) REFERENCES mario_killers.Especialidad(codigo)
)

CREATE TABLE mario_killers.Turno (
	id numeric(18, 0) IDENTITY,
	persona numeric(18, 0) NOT NULL,
	profesional numeric(18, 0) NOT NULL,
	horario datetime NOT NULL,
	horario_llegada datetime,
	especialidad numeric(18, 0) NOT NULL,
	activo bit
		CONSTRAINT turno_activo DEFAULT 1,
	PRIMARY KEY (id),
	FOREIGN KEY (persona) REFERENCES mario_killers.Persona(id),
	FOREIGN KEY (profesional) REFERENCES mario_killers.Profesional(persona),
	FOREIGN KEY (especialidad) REFERENCES mario_killers.Especialidad(codigo),
	UNIQUE (horario, profesional)
)

CREATE TABLE mario_killers.Compra (
	id numeric(18, 0) IDENTITY,
	fecha datetime,
	persona numeric(18, 0),
	plan_medico numeric(18, 0) NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (plan_medico) REFERENCES mario_killers.Plan_Medico(codigo),
	FOREIGN KEY (persona) REFERENCES mario_killers.Afiliado(persona)
)

CREATE TABLE mario_killers.Bono_Consulta (
	id numeric(18, 0) IDENTITY,
	compra numeric(18, 0),
	plan_medico numeric(18, 0),
	cant_consultas numeric(18,0)
		CONSTRAINT cant_consultas DEFAULT 1,
	activo bit NOT NULL
		CONSTRAINT bono_consulta_activo DEFAULT 1,
	PRIMARY KEY (id),
	FOREIGN KEY (plan_medico) REFERENCES mario_killers.Plan_Medico(codigo),
	FOREIGN KEY (compra) REFERENCES mario_killers.Compra(id)
)

CREATE TABLE mario_killers.Atencion (
	id numeric(18, 0),
	horario_atencion datetime,
	sintomas text,
	diagnostico text,
	bono_consulta numeric(18, 0),
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES mario_killers.Turno(id),
	FOREIGN KEY (bono_consulta) REFERENCES mario_killers.Bono_Consulta(id)
)

CREATE TABLE mario_killers.Bono_Farmacia (
	codigo numeric(18, 0) IDENTITY,
	compra numeric(18, 0),
	plan_medico numeric(18, 0),
	activo bit
		CONSTRAINT bono_nuevo DEFAULT 1,
	PRIMARY KEY (codigo),
	FOREIGN KEY (plan_medico) REFERENCES mario_killers.Plan_Medico(codigo),
	FOREIGN KEY (compra) REFERENCES mario_killers.Compra(id)
)

CREATE TABLE mario_killers.Medicamento (
	detalle varchar(255) NOT NULL,
	PRIMARY KEY (detalle)
)
GO

CREATE FUNCTION mario_killers.cant_medicamentos(@historia_id numeric(18, 0)) returns int
AS BEGIN
	RETURN (
			SELECT COUNT(DISTINCT medicamento)
			FROM mario_killers.Medicamento_Atencion
			WHERE Atencion = @historia_id
			GROUP BY Atencion
			HAVING COUNT(DISTINCT medicamento) > 5
	)
END
GO

CREATE TABLE mario_killers.Medicamento_Atencion (
	id numeric(18, 0) IDENTITY,
	medicamento varchar(255),
	Atencion numeric(18, 0),
	cantidad numeric(18, 0)
		CONSTRAINT default_1_med DEFAULT 1,
	bono_farmacia numeric(18, 0),
	activo bit
		CONSTRAINT activo DEFAULT 1,
	PRIMARY KEY (id),
	FOREIGN KEY (Atencion) REFERENCES mario_killers.Atencion(id),
	FOREIGN KEY (bono_farmacia) REFERENCES mario_killers.Bono_Farmacia(codigo),
	FOREIGN KEY (medicamento) REFERENCES mario_killers.Medicamento(detalle),
	CONSTRAINT max_3_medicamento CHECK (cantidad <= 3)
)
GO

CREATE TABLE mario_killers.Tipo_Cancelacion (
	id numeric(18,0) IDENTITY,
	descripcion varchar(255),
	PRIMARY KEY (id)
)
GO

CREATE TABLE mario_killers.Cancelacion (
	tipo numeric(18,0),
	motivo varchar(255),
	persona numeric(18,0),
	turno numeric(18,0)
	FOREIGN KEY (persona) REFERENCES mario_killers.Persona,
	FOREIGN KEY (tipo) REFERENCES mario_killers.Tipo_Cancelacion(id),
	FOREIGN KEY (turno) REFERENCES mario_killers.Turno
)
GO

--------------------------------- DATOS INICIALES -----------------------------

INSERT INTO mario_killers.Estado_Civil (estado)
	VALUES ('Soltero/a'),
	       ('Casado/a'),
	       ('Viudo/a'),
	       ('Concubinato'),
	       ('Divorciado/a'),
	       ('X');

INSERT INTO mario_killers.Tipo_Documento (tipo)
	VALUES ('DNI'), ('CI'), ('LC'), ('LE'), ('X');

INSERT INTO mario_killers.Rol (nombre)
	VALUES ('Administrador General'),
	       ('Profesional'),
	       ('Afiliado'),
	       ('Administrativo');
	       
INSERT INTO mario_killers.Funcionalidad (nombre)
	VALUES ('ABM de roles'),
	       ('ABM de afiliados'),
	       ('ABM de profesionales'),
	       ('ABM de especialidades medicas'),
	       ('ABM de planes'),
	       ('Registrar agenda profesional'),
	       ('Registro de resultado para atencion medica'),
	       ('Registro de llegada para atencion medica'),
	       ('Registrar diagnostico'),
	       ('Cancelar atencion medica'),
	       ('Cancelar dia'),
	       ('Confeccionar receta medica'),
	       ('Consultar listado estadistico'),
	       ('Compra de bonos'),
	       ('Pedido de turno');

EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'ABM de roles';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'ABM de afiliados';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'ABM de profesionales';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'ABM de especialidades medicas';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'ABM de planes';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'ABM de roles';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'ABM de afiliados';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'ABM de profesionales';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'ABM de especialidades medicas';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'ABM de planes';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Registrar agenda profesional';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Profesional', @func = 'Registrar agenda profesional';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Afiliado', @func = 'Compra de bonos';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Compra de bonos';	
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'Compra de bonos';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Afiliado', @func = 'Pedido de turno';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Pedido de turno';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Registro de llegada para atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'Registro de llegada para atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Profesional', @func = 'Registro de resultado para atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Registro de resultado para atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Profesional', @func = 'Cancelar dia';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Cancelar dia';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Afiliado', @func = 'Cancelar atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Cancelar atencion medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Profesional', @func = 'Confeccionar receta medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Confeccionar receta medica';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrador General', @func = 'Consultar listado estadistico';
EXEC mario_killers.agregar_funcionalidad
	@rol = 'Administrativo', @func = 'Consultar listado estadistico';

SET IDENTITY_INSERT mario_killers.Tipo_Cancelacion ON
INSERT INTO mario_killers.Tipo_Cancelacion (id, descripcion) VALUES (1, 'Evento Imprevisto')
INSERT INTO mario_killers.Tipo_Cancelacion (id, descripcion) VALUES (2, 'Problemas Laborales')
INSERT INTO mario_killers.Tipo_Cancelacion (id, descripcion) VALUES (3, 'Problema Personal')
INSERT INTO mario_killers.Tipo_Cancelacion (id, descripcion) VALUES (4, 'Factor Climatico')
INSERT INTO mario_killers.Tipo_Cancelacion (id, descripcion) VALUES (5, 'Otro')
SET IDENTITY_INSERT mario_killers.Tipo_Cancelacion OFF
GO

CREATE FUNCTION mario_killers.mes(@m int)
RETURNS varchar(100)
AS BEGIN
	RETURN (CASE @m
		WHEN 1 THEN 'Enero'
		WHEN 2 THEN 'Febrero'
		WHEN 3 THEN 'Marzo'
		WHEN 4 THEN 'Abril'
		WHEN 5 THEN 'Mayo'
		WHEN 6 THEN 'Junio'
		WHEN 7 THEN 'Julio'
		WHEN 8 THEN 'Agosto'
		WHEN 9 THEN 'Septiembre'
		WHEN 10 THEN 'Octubre'
		WHEN 11 THEN 'Noviembre'
		WHEN 12 THEN 'Diciembre'
	END)
END
GO


-- Vistas ABM

-------------- Listado 1
CREATE VIEW mario_killers.cancelaciones_por_especialidad AS
SELECT Turno.id ID_Turno,
       YEAR(Turno.horario) Anio,
       MONTH(Turno.horario) Mes,
       Especialidad.descripcion Desc_Especialidad,
       Tipo_Especialidad.descripcion Desc_Tipo_Especialidad
       
FROM mario_killers.Cancelacion
	JOIN mario_killers.Turno ON Cancelacion.turno = Turno.id
	JOIN mario_killers.Especialidad ON Turno.especialidad = Especialidad.codigo
	JOIN mario_killers.Tipo_Especialidad ON Tipo_Especialidad.codigo = Especialidad.tipo
GO

CREATE VIEW mario_killers.listado_1_view AS
SELECT *, [1]+[2]+[3]+[4]+[5]+[6] Total_Primer_Semestre, [7]+[8]+[9]+[10]+[11]+[12] Total_Segundo_Semestre
FROM mario_killers.cancelaciones_por_especialidad
-- Mucha magia
PIVOT (COUNT(ID_Turno) FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS Cancelaciones_Pivot
GO
-------------------- Listado 2 (ver archivo)

-------------------- Listado 3

CREATE VIEW mario_killers.bonos_farmacia_por_especialidad AS
SELECT Bono_Farmacia.codigo AS Codigo_Bono,
       YEAR(Atencion.horario_atencion) Anio,
       MONTH(Atencion.horario_atencion) Mes,
       Especialidad.descripcion Desc_Especialidad,
       Tipo_Especialidad.descripcion Desc_Tipo_Especialidad
FROM mario_killers.Medicamento_Atencion
	JOIN mario_killers.Atencion ON Atencion.id = Medicamento_Atencion.Atencion
	JOIN mario_killers.Bono_Farmacia ON Medicamento_Atencion.bono_farmacia = Bono_Farmacia.codigo
	JOIN mario_killers.Turno ON Turno.id = Atencion.id
	JOIN mario_killers.Especialidad ON Turno.especialidad = Especialidad.codigo
	JOIN mario_killers.Tipo_Especialidad ON Tipo_Especialidad.codigo = Especialidad.tipo
GO

CREATE VIEW mario_killers.listado_3_view AS
SELECT *, [1]+[2]+[3]+[4]+[5]+[6] Total_Primer_Semestre, [7]+[8]+[9]+[10]+[11]+[12] Total_Segundo_Semestre
FROM mario_killers.bonos_farmacia_por_especialidad
PIVOT (COUNT(Codigo_Bono) FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as Bonos_Farmacia_Por_Mes
GO

----------- Listado 4

CREATE VIEW mario_killers.bonos_consulta_distinto_comprador AS
	SELECT Bono_Consulta.id AS ID_Bono,
	       Persona.nombre Nombre,
	       Persona.apellido Apellido,
	       Persona.documento Documento,
	       MONTH(Turno.horario) Mes,
	       YEAR(Turno.horario) Anio
	FROM mario_killers.Atencion
		JOIN mario_killers.Turno ON Turno.id = Atencion.id
		JOIN mario_killers.Bono_Consulta ON Bono_Consulta.id = Atencion.bono_consulta
		JOIN mario_killers.Compra ON Compra.id = Bono_Consulta.compra
		JOIN mario_killers.Afiliado ON Turno.persona = Afiliado.persona
		JOIN mario_killers.Persona ON Persona.id = Afiliado.persona
	WHERE Turno.persona <> Compra.persona
GO

CREATE VIEW mario_killers.bonos_farmacia_distinto_comprador AS
	SELECT Bono_Farmacia.codigo ID_Bono,
	       Persona.nombre Nombre,
	       Persona.apellido Apellido,
	       Persona.documento Documento,
	       MONTH(Turno.horario) Mes,
	       YEAR(Turno.horario) Anio
	FROM mario_killers.Turno
		JOIN mario_killers.Atencion ON Atencion.id = Turno.id
		JOIN mario_killers.Medicamento_Atencion ON Medicamento_Atencion.Atencion = Atencion.id
		JOIN mario_killers.Bono_Farmacia ON Medicamento_Atencion.bono_farmacia = Bono_Farmacia.codigo
		JOIN mario_killers.Compra ON Compra.id = Bono_Farmacia.compra
		JOIN mario_killers.Afiliado ON Afiliado.persona = Turno.persona
		JOIN mario_killers.Persona ON Afiliado.persona = Persona.id
	WHERE Compra.persona <> Turno.persona
GO

CREATE VIEW mario_killers.bonos_distinto_comprador AS
	SELECT ID_Bono, Nombre, Apellido, Documento, Mes, Anio
	FROM mario_killers.bonos_consulta_distinto_comprador
	UNION
	SELECT ID_Bono, Nombre, Apellido, Documento, Mes, Anio
	FROM mario_killers.bonos_farmacia_distinto_comprador
GO

CREATE VIEW mario_killers.listado_4_view AS
	SELECT *, [1]+[2]+[3]+[4]+[5]+[6] Total_Primer_Semestre, [7]+[8]+[9]+[10]+[11]+[12] Total_Segundo_Semestre
	FROM mario_killers.bonos_distinto_comprador
	PIVOT (COUNT(ID_Bono) FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS Bonos_Pivot
GO

CREATE VIEW mario_killers.AfiliadosABM AS 
SELECT A.persona AS persona, A.grupo_familia AS grupo_familia, A.nro_familiar AS nro_familiar, P.apellido AS apellido, P.nombre AS nombre, P.documento AS documento, GF.plan_medico AS plan_medico, 
		P.direccion AS direccion, P.fecha_nac AS fecha_nac, P.mail AS mail, TD.id AS tipo_doc, P.sexo AS sexo, P.telefono AS telefono, A.cant_hijos AS cant_hijos, A.estado_civil AS estado_civil
FROM mario_killers.Afiliado A JOIN mario_killers.Persona P ON A.persona = P.id
							  JOIN mario_killers.Grupo_Familia GF ON A.grupo_familia = GF.codigo
							  JOIN mario_killers.Tipo_Documento TD ON P.tipo_doc = TD.id
WHERE A.activo = 1
GO

CREATE VIEW mario_killers.ProfesionalABM AS
SELECT PRO.persona AS persona, PRO.matricula AS matricula, P.nombre AS nombre, P.apellido AS apellido, P.documento AS documento, 
		p.direccion AS direccion, P.fecha_nac AS fecha_nac, P.mail AS mail, TD.id AS tipo_doc, P.sexo AS sexo, P.telefono AS telefono
FROM mario_killers.Profesional PRO JOIN mario_killers.Persona P ON PRO.persona = P.id
									JOIN mario_killers.Especialidad_Profesional EP ON EP.profesional = PRO.persona
									JOIN mario_killers.Especialidad E ON E.codigo = EP.especialidad
									JOIN mario_killers.Tipo_Documento TD ON TD.id = P.tipo_doc
WHERE PRO.activo = 1
GROUP BY PRO.persona, PRO.matricula, P.nombre, P.apellido, P.documento, P.direccion, P.fecha_nac, P.mail, TD.id, P.sexo, P.telefono
GO

CREATE VIEW mario_killers.ProfesionalYPersona AS
SELECT pro.matricula AS matricula, per.apellido AS apellido, per.nombre AS nombre, per.id AS codigoPersona, per.direccion AS direccion, per.documento AS documento, per.fecha_nac AS fechaNac, per.mail AS mail, per.sexo AS sexo, per.telefono AS tel, per.tipo_doc AS tipo_doc
FROM mario_killers.Profesional pro JOIN mario_killers.Persona per ON pro.persona = per.id
GO 

CREATE VIEW mario_killers.AfiliadosParaCompra AS 
SELECT A.persona AS persona, A.grupo_familia AS grupo_familia, A.nro_familiar AS nro_familiar, P.apellido AS apellido, P.nombre AS nombre, P.documento AS documento, GF.plan_medico AS plan_medico, 
  P.direccion AS direccion, P.fecha_nac AS fecha_nac, P.mail AS mail, TD.id AS tipo_doc, P.sexo AS sexo, P.telefono AS telefono, A.cant_hijos AS cant_hijos, A.estado_civil AS estado_civil, A.activo AS activo
FROM mario_killers.Afiliado A JOIN mario_killers.Persona P ON A.persona = P.id
         JOIN mario_killers.Grupo_Familia GF ON A.grupo_familia = GF.codigo
         JOIN mario_killers.Tipo_Documento TD ON P.tipo_doc = TD.id
GO

CREATE VIEW mario_killers.BonoYcompra AS
SELECT c.id AS compra, c.fecha AS fecha, bf.codigo AS codigo, bf.plan_medico AS plan_medico, a.grupo_familia AS grupo, bf.activo AS activo, precio_bono_consulta, precio_bono_farmacia
FROM mario_killers.Bono_Farmacia bf
	join mario_killers.Compra c on c.id = bf.compra
	join mario_killers.Afiliado a on a.persona = c.persona
	join mario_killers.Grupo_Familia on Grupo_Familia.codigo = a.grupo_familia
	join mario_killers.Plan_Medico on Plan_Medico.codigo = Grupo_Familia.plan_medico
GO

CREATE VIEW mario_killers.BonoConsultaYcompra AS
SELECT Compra.id AS compra, Compra.fecha AS fecha, Bono_Consulta.id AS codigo, Bono_Consulta.plan_medico AS plan_medico, Afiliado.grupo_familia AS grupo, Bono_Consulta.activo AS activo, precio_bono_consulta, precio_bono_farmacia
FROM mario_killers.Bono_Consulta
	join mario_killers.Compra ON Compra.id = Bono_Consulta.compra
	join mario_killers.Afiliado on Afiliado.persona = Compra.persona
	join mario_killers.Grupo_Familia on Grupo_Familia.codigo = Afiliado.grupo_familia
	join mario_killers.Plan_Medico on Plan_Medico.codigo = Grupo_Familia.plan_medico
GO

CREATE VIEW mario_killers.TurnosPorPaciente AS
SELECT T.id AS id, T.persona AS paciente_id, PA.nombre + ' ' + PA.apellido AS paciente, 
	   T.profesional AS profesional_id, PP.nombre + ' ' + PP.apellido AS profesional, T.horario AS fecha, T.especialidad AS especialidad
FROM mario_killers.Turno T JOIN mario_killers.Persona PA ON T.persona = PA.id
						   JOIN mario_killers.Persona PP ON T.profesional = PP.id
WHERE T.activo = 1 AND T.horario_llegada IS NULL
GO

-------------------------------------------------- MIGRACION --------------------------------

CREATE VIEW mario_killers.Pacientes AS
	SELECT DISTINCT Paciente_Nombre, Paciente_Apellido,
					Paciente_Dni, Paciente_Fecha_Nac,
					Paciente_Direccion, Paciente_Telefono, Paciente_Mail,
					Plan_Med_Codigo
	FROM gd_esquema.Maestra
	WHERE Paciente_Nombre IS NOT NULL
GO 

CREATE VIEW mario_killers.Medicos AS
	SELECT DISTINCT Medico_Nombre, Medico_Apellido,
					Medico_Dni, Medico_Fecha_Nac,
					Medico_Direccion, Medico_Telefono, Medico_Mail
	FROM gd_esquema.Maestra
	WHERE Medico_Nombre IS NOT NULL
GO

CREATE VIEW mario_killers.Especialidades AS
	SELECT DISTINCT Especialidad_Codigo, Especialidad_Descripcion,
	                Tipo_Especialidad_Codigo, Tipo_Especialidad_Descripcion
	FROM gd_esquema.Maestra
	WHERE Especialidad_Codigo IS NOT NULL AND
	      Especialidad_Descripcion IS NOT NULL AND
	      Tipo_Especialidad_Codigo IS NOT NULL AND
	      Tipo_Especialidad_Descripcion IS NOT NULL
GO

CREATE VIEW mario_killers.Planes_Medicos AS
	SELECT DISTINCT Plan_Med_Codigo, Plan_Med_Descripcion,
	                Plan_Med_Precio_Bono_Consulta, Plan_Med_Precio_Bono_Farmacia
	FROM gd_esquema.Maestra
	WHERE Plan_Med_Codigo IS NOT NULL
GO

CREATE VIEW mario_killers.Medicamentos AS
	SELECT DISTINCT Bono_Farmacia_Medicamento
	FROM gd_esquema.Maestra
	WHERE Bono_Farmacia_Medicamento IS NOT NULL
GO

CREATE VIEW mario_killers.Medicamentos_Atencion AS
	SELECT Bono_Farmacia_Medicamento, Turno_Numero, Bono_Farmacia_Numero
	FROM gd_esquema.Maestra
	WHERE Bono_Farmacia_Medicamento IS NOT NULL AND Turno_Numero IS NOT NULL
GO


CREATE VIEW mario_killers.Compras AS
	SELECT Bono_Consulta_Numero AS id, Compra_Bono_Fecha, Paciente_Dni, Plan_Med_Codigo
	FROM gd_esquema.Maestra
	WHERE Compra_Bono_Fecha IS NOT NULL
	      AND Plan_Med_Codigo IS NOT NULL
	      AND Bono_Consulta_Numero IS NOT NULL
	      AND Bono_Farmacia_Numero IS NULL
	UNION
	SELECT Bono_Farmacia_Numero + 1000000 AS id, Compra_Bono_Fecha, Paciente_Dni, Plan_Med_Codigo
	FROM gd_esquema.Maestra
	WHERE Compra_Bono_Fecha IS NOT NULL
		AND Plan_Med_Codigo IS NOT NULL
		AND Bono_Farmacia_Numero IS NOT NULL
		AND Bono_Consulta_Numero IS NULL
GO

CREATE VIEW mario_killers.Atenciones AS
	SELECT DISTINCT Turno_Numero, Turno_Fecha, Consulta_Sintomas, Consulta_Enfermedades, Bono_Consulta_Numero
	FROM gd_esquema.Maestra
	WHERE Consulta_Sintomas IS NOT NULL  AND Consulta_Enfermedades IS NOT NULL
	GROUP BY Turno_Numero, Turno_Fecha, Consulta_Sintomas, Consulta_Enfermedades, Bono_Consulta_Numero
GO

CREATE VIEW mario_killers.Turnos AS
	SELECT DISTINCT Turno_Numero, Paciente_Dni, Medico_Dni, Turno_Fecha, Especialidad_Codigo,
	                MAX(Consulta_Sintomas) Consulta_Sintomas,
	                MAX(Consulta_Enfermedades) Consulta_Enfermedades,
	                mario_killers.Turno_Valido(Turno_Fecha) AS Turno_Activo
	FROM gd_esquema.Maestra
	WHERE Turno_Numero IS NOT NULL
	GROUP BY Turno_Numero, Paciente_Dni, Medico_Dni, Turno_Fecha, Especialidad_Codigo, Plan_Med_Codigo
GO

CREATE VIEW mario_killers.Bonos_Consulta AS
	SELECT DISTINCT Bono_Consulta_Numero,
	                MAX(Turno_Numero) AS Turno_Numero,
	                MAX(Compra_Bono_Fecha) AS Compra_Bono_Fecha,
	                Paciente_Dni,
	                Plan_Med_Codigo
	FROM gd_esquema.Maestra
	WHERE Bono_Consulta_Numero IS NOT NULL
	GROUP BY Bono_Consulta_Numero, Paciente_Dni, Plan_Med_Codigo
GO

CREATE VIEW mario_killers.Bonos_Farmacia AS
	SELECT DISTINCT Bono_Farmacia_Numero,
	                MAX(Compra_Bono_Fecha) Compra_Bono_Fecha,
	                Bono_Farmacia_Fecha_Vencimiento,
	                Bono_Farmacia_Medicamento,
	                MAX(Turno_Numero) AS Turno_Numero,
	                Paciente_Dni,
	                Plan_Med_Codigo,
	                mario_killers.bono_farmacia_valido(Compra_Bono_Fecha, Bono_Farmacia_Fecha_Vencimiento, Bono_Farmacia_Medicamento) AS valido
	FROM gd_esquema.Maestra
	WHERE Bono_Farmacia_Numero IS NOT NULL AND Compra_Bono_Fecha IS NOT NULL
	GROUP BY Bono_Farmacia_Numero, Paciente_Dni, Bono_Farmacia_Fecha_Vencimiento, Bono_Farmacia_Medicamento, Compra_Bono_Fecha, Plan_Med_Codigo
GO

CREATE VIEW mario_killers.Especialidades_Profesional AS
	SELECT DISTINCT Medico_Dni, Especialidad_Codigo
	FROM gd_esquema.Maestra
	WHERE Medico_Dni IS NOT NULL
	      AND Especialidad_Codigo IS NOT NULL
GO

CREATE VIEW mario_killers.Usuarios AS
	SELECT DISTINCT CONVERT(VARCHAR(255), Medico_Dni) AS nombre, Medico_Dni AS persona, '24afe47d0bd302ae42643c5848d99b683264026cd12cc998e05e100bbf2dc30d' AS pw, 2 AS rol
	FROM gd_esquema.Maestra
	WHERE Medico_Dni IS NOT NULL
	UNION 
	SELECT DISTINCT CONVERT(VARCHAR(255), Paciente_Dni) AS nombre, Paciente_Dni AS persona, '1aeaeba4bdbf8907638434b60504b1037c01905bec294fb2cd5348724f2fa64f' AS pw, 3 AS rol
	FROM gd_esquema.Maestra
	WHERE Paciente_Dni IS NOT NULL
GO

-- Personas
SET IDENTITY_INSERT mario_killers.Persona ON
INSERT INTO mario_killers.Persona (id, nombre, apellido, documento, fecha_nac, direccion, telefono, mail, sexo, tipo_doc)
	SELECT Paciente_Dni, Paciente_Nombre, Paciente_Apellido, Paciente_Dni,
	       Paciente_Fecha_Nac, Paciente_Direccion, Paciente_Telefono,
	       Paciente_Mail, 'X', 5
	FROM mario_killers.Pacientes

INSERT INTO mario_killers.Persona (id, nombre, apellido, documento, fecha_nac, direccion, telefono, mail, sexo, tipo_doc)
	SELECT Medico_Dni, Medico_Nombre, Medico_Apellido, Medico_Dni,
	       Medico_Fecha_Nac, Medico_Direccion, Medico_Telefono,
	       Medico_Mail, 'X', 5
	FROM mario_killers.Medicos
SET IDENTITY_INSERT mario_killers.Persona OFF

-- Planes medicos
INSERT INTO mario_killers.Plan_Medico
           (codigo, descripcion, precio_bono_consulta, precio_bono_farmacia)
	SELECT Plan_Med_Codigo,
	       Plan_Med_Descripcion,
	       Plan_Med_Precio_Bono_Consulta,
	       Plan_Med_Precio_Bono_Farmacia
	FROM mario_killers.Planes_Medicos

-- Grupos de familia
SET IDENTITY_INSERT mario_killers.Grupo_Familia ON
INSERT INTO mario_killers.Grupo_Familia (codigo, plan_medico)
	SELECT Persona.id, Plan_Med_Codigo
	FROM mario_killers.Pacientes
	     JOIN mario_killers.Persona
	     ON mario_killers.Pacientes.Paciente_DNI = mario_killers.Persona.documento
SET IDENTITY_INSERT mario_killers.Grupo_Familia OFF  

-- Afiliados y grupos de familia individuales
INSERT INTO mario_killers.Afiliado (persona, grupo_familia, nro_familiar, estado_civil, cant_hijos)
	SELECT id, id, 1, 6, 0
	FROM mario_killers.Persona
	WHERE documento IN (SELECT Paciente_Dni FROM mario_killers.Pacientes)

-- Especialidades
SET IDENTITY_INSERT mario_killers.Tipo_Especialidad ON
INSERT INTO mario_killers.Tipo_Especialidad (codigo, descripcion)
	SELECT DISTINCT Tipo_Especialidad_Codigo, Tipo_Especialidad_Descripcion
	FROM mario_killers.Especialidades
SET IDENTITY_INSERT mario_killers.Tipo_Especialidad OFF

SET IDENTITY_INSERT mario_killers.Especialidad ON
INSERT INTO mario_killers.Especialidad (codigo, descripcion, tipo)
	SELECT Especialidad_Codigo, Especialidad_Descripcion, Tipo_Especialidad_Codigo
	FROM mario_killers.Especialidades
SET IDENTITY_INSERT mario_killers.Especialidad OFF

-- Profesionales
INSERT INTO mario_killers.Profesional (persona)
	SELECT id
	FROM mario_killers.Persona
	WHERE documento IN (SELECT Medico_Dni FROM mario_killers.Medicos)

INSERT INTO mario_killers.Especialidad_Profesional (profesional, especialidad)
	SELECT Medico_Dni, Especialidad_Codigo
	FROM mario_killers.Especialidades_Profesional

-- Medicamentos
INSERT INTO mario_killers.Medicamento (detalle)
	SELECT Bono_Farmacia_Medicamento FROM mario_killers.Medicamentos

-- Turnos
SET IDENTITY_INSERT mario_killers.Turno ON
INSERT INTO mario_killers.Turno (id, persona, profesional, horario, especialidad, activo)
	SELECT Turno_Numero, Paciente_Dni,
	       Medico_Dni, Turno_Fecha, Especialidad_Codigo,
	       Turno_Activo
	FROM mario_killers.Turnos
SET IDENTITY_INSERT mario_killers.Turno OFF
GO

-- Compras
SET IDENTITY_INSERT mario_killers.Compra ON
INSERT INTO mario_killers.Compra (id, fecha, persona, plan_medico)
	SELECT id, Compra_Bono_Fecha, Paciente_Dni, Plan_Med_Codigo
	FROM mario_killers.Compras
SET IDENTITY_INSERT mario_killers.Compra OFF

-- Bonos consulta
SET IDENTITY_INSERT mario_killers.Bono_Consulta ON
INSERT INTO mario_killers.Bono_Consulta (id, compra, plan_medico, activo)
	SELECT B.Bono_Consulta_Numero, B.Bono_Consulta_Numero, B.Plan_Med_Codigo, 
								CASE WHEN EXISTS (SELECT * FROM mario_killers.Atenciones A WHERE A.Bono_Consulta_Numero = B.Bono_Consulta_Numero) THEN 0
								 ELSE 1 END
	FROM mario_killers.Bonos_Consulta B
SET IDENTITY_INSERT mario_killers.Bono_Consulta OFF

-- Bonos farmacia
SET IDENTITY_INSERT mario_killers.Bono_Farmacia ON
INSERT INTO mario_killers.Bono_Farmacia (codigo, compra, plan_medico,  activo)
	SELECT Bono_Farmacia_Numero, Bono_Farmacia_Numero + 1000000, Plan_Med_Codigo, valido
	FROM mario_killers.Bonos_Farmacia
SET IDENTITY_INSERT mario_killers.Bono_Farmacia OFF

-- Atencion
-- Inicialmente los ID de atencion son los numeros de turno
INSERT INTO mario_killers.Atencion (id, horario_atencion, sintomas, diagnostico, bono_consulta)
	SELECT Turno_Numero, Turno_Fecha, Consulta_Sintomas, Consulta_Enfermedades, Bono_Consulta_Numero
	FROM mario_killers.Atenciones
	WHERE Turno_Numero IS NOT NULL

-- Cantidad de atenciones
UPDATE BC
	SET cant_consultas = (
		SELECT COUNT(*)
		FROM mario_killers.Turno t1
			JOIN mario_killers.Atencion on t1.id = Atencion.id
		WHERE t1.persona = t2.persona
			AND t2.horario >= t1.horario
			--AND EXISTS (SELECT * FROM mario_killers.Atencion WHERE Atencion.id = t1.id)
	)
	FROM mario_killers.Bono_Consulta BC
		JOIN mario_killers.Atencion a ON a.bono_consulta = BC.id
		JOIN mario_killers.Turno t2 ON t2.id = a.id

-- Medicamentos por atencion
-- Inicialmente los ID de atencion son los numeros de turno
INSERT INTO mario_killers.Medicamento_Atencion (medicamento, atencion, bono_farmacia)
	SELECT Bono_Farmacia_Medicamento, Turno_Numero, Bono_Farmacia_Numero
	FROM mario_killers.Medicamentos_Atencion

--Usuarios
INSERT INTO mario_killers.Usuario (nombre, persona, pw)
	SELECT nombre, persona, pw
	FROM mario_killers.Usuarios
GO
	
--Rol por usuario
INSERT INTO mario_killers.Rol_Usuario (usuario, rol)
	SELECT nombre, rol
	FROM mario_killers.Usuarios
GO

-- Agendas
INSERT INTO mario_killers.Agenda (profesional, desde, hasta, activo)
	SELECT Medico_Dni, MIN(Turno_Fecha), MAX(Turno_Fecha), 0
	FROM mario_killers.Turnos
	GROUP BY Medico_Dni
GO

CREATE VIEW mario_killers.RangoView AS
SELECT DISTINCT DATEPART(WEEKDAY, Turno_Fecha) diaV,
	   Medico_Dni,
       CONVERT(TIME, Turno_Fecha) hora_desdeV,
       CONVERT(TIME, DATEADD(MINUTE, 30, Turno_Fecha)) hora_hastaV,
       Especialidad_Codigo,
       0 activo
FROM mario_killers.Turnos
WHERE DATEPART(WEEKDAY, Turno_Fecha) <> 1
GO

-- D�as de atenci�n
INSERT INTO mario_killers.Rango (dia, profesional, hora_desde, hora_hasta, especialidad, activo)
SELECT *
FROM mario_killers.RangoView
GO

DROP VIEW mario_killers.Pacientes
         ,mario_killers.Medicos
         ,mario_killers.Especialidades
         ,mario_killers.Planes_Medicos
         ,mario_killers.Medicamentos
         ,mario_killers.Medicamentos_Atencion
         ,mario_killers.Bonos_Consulta
         ,mario_killers.Turnos
         ,mario_killers.Compras
         ,mario_killers.Bonos_Farmacia
         ,mario_killers.Especialidades_Profesional
         ,mario_killers.Usuarios
         ,mario_killers.Atenciones
         ,mario_killers.RangoView

---------------------- Constraints post-migracion ----------------------

ALTER TABLE mario_killers.Turno WITH NOCHECK
	ADD CONSTRAINT fecha_turno CHECK (mario_killers.horario_atencion(horario) = 1)
	
ALTER TABLE mario_killers.Medicamento_Atencion WITH NOCHECK
	ADD CONSTRAINT max_5_receta CHECK ( mario_killers.cant_medicamentos(Atencion) <= 5)
	
ALTER TABLE mario_killers.Turno WITH NOCHECK
	ADD CONSTRAINT horario_valido CHECK (mario_killers.Turno_Valido(horario) = 1)
	
ALTER TABLE mario_killers.Agenda WITH NOCHECK
	ADD CONSTRAINT max_120_dias CHECK (DATEDIFF(day, desde, hasta) <= 120)


------ Administrador General (admin) y un Administrativo
INSERT INTO mario_killers.Usuario (nombre, pw)
	VALUES ('admin', 'e6b87050bfcb8143fcb8db0170a4dc9ed00d904ddd3e2a4ad1b1e8dc0fdc9be7'),
		   ('administrador', 'e6b87050bfcb8143fcb8db0170a4dc9ed00d904ddd3e2a4ad1b1e8dc0fdc9be7');
	GO

INSERT INTO mario_killers.Rol_Usuario
	VALUES ('admin', 1),
	       ('administrador', 4)	       	       
GO