/* ========================================
	
	Exploración de la tabla "grupos"

===========================================*/

	use monitoring;
	go

-- Consulta 1: Visualizar los campos (columnas o variables) de la tabla "grupos"
	select * from grupos;
	go 

-- Consulta 2: Explorar la columna "grupo_id"
	select * from grupos;
	go

	select
		distinct grupo_id
	from grupos;
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%A%');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%A%4');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%A%5');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%B%');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%B%4');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%B%5');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%C%');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%C%4');
	go

	select 
		grupo_id
	from grupos
	where grupo_id like ('%C%5');
	go


-- Consulta 3: Explorar la columna "institucion_id"
	select * from grupos;
	go

	select 
		institucion_id,
		count(grupo_id) as [Grupos de WhatsApp por institución]
	from grupos
	group by institucion_id;
	go

	select
		substring(institucion_id, 4, 1) as Ugel,
		institucion_id,
		count(grupo_id) as [Grupos de WhatsApp por institución]
	from grupos
	group by institucion_id;
	go

-- Consulta 4: Explorar la columna "edad"
	select * from grupos;
	go

	select
		distinct edad 
	from grupos;
	go


-- Consulta 5: Explorar la columna "docente_id"
	select * from grupos;
	go

	select 
		distinct docente_id
	from grupos;
	go 

	select 
		docente_id,
		substring(docente_id, 1, 1) as [Rol],
		substring(docente_id, 3, 1) as [Ugel],
		substring(docente_id, 4, 2) as [Nro. de la institución],
		substring(docente_id, 7, 1) as [Edad del niño(a)]
	from grupos;
	go





