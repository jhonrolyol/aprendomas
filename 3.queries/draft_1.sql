/* ========================================
	
	Exploración de la tabla "actividades"

===========================================*/
	
	use Monitoring;
	go

-- Consulta 1: Visualizar los campos (columnas o variables) de la tabla "actividades"
	select * from actividades;
	go 
	
-- Consulta 2: Explorar la columna "actividad_id"
	select * from actividades;
	go

	select 
		count(actividad_id) as cantidad
	from actividades;
	go

-- Consulta 3: Explorar la columna "fecha_envio_utc"
	select * from actividades;
	go

	select 
		fecha_envio_utc,
		cast(fecha_envio_utc as date) as texto_a_fecha,
		datepart(year,  fecha_envio_utc) as anio,
		datepart(month, fecha_envio_utc) as mes,
		datepart(day,   fecha_envio_utc) as dia,
		datepart(hour,  fecha_envio_utc) as hora_utc,
		datepart(hour,  fecha_envio_utc) - 5 as hora_peru
	from actividades;
	go 

	-- NOTA: UTC = Coordinated Universal Time. En español = Tiempo Universal Coordinado. Perú usa UTC − 5

-- Consulta 4: Explorar la columna "area"
	select * from actividades;
	go

	select  
		distinct area
	from actividades;
	go

	select  
		semana,
		area,
		count(actividad_id) as cantidad
	from actividades
	group by semana, area
	order by semana;
	go
	
	select
		area,
		semana,
		count(actividad_id) as cantidad
	from actividades
	group by semana, area
	order by semana;
	go

-- Consulta 5: Explorar la columna "semana"
	select * from actividades;
	go

	select 
		distinct semana
	from actividades;
	go

	select 
		semana as semana, 
		count(semana) as [Cantidad de actividades por semana]
	from actividades
	group by semana;
	go


