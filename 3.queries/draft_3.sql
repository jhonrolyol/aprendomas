/* ========================================
	
	Exploración de la tabla "participantes"

===========================================*/

	use monitoring;
	go

-- Consulta 1: Visualizar los campos (columnas o variables) de la tabla "participantes"
	select * from participantes;
	go

-- Consulta 2: Explorar la columna "participante_id"
	select * from participantes;
	go

	select 
		count(*) as [Cantidad de participantes]
	from participantes;
	go

	select 
		distinct participante_id
	from participantes;
	go

-- Consulta 3: Explorar la columna "grupo_id"
	select * from participantes;
	go

	select 
		distinct grupo_id 
	from participantes;
	go

	select 
		grupo_id, 
		rol,
		count(participante_id) as [Cantidad de participantes]
	from participantes
	group by grupo_id, rol
	having rol = 'familia'
	order by grupo_id;
	go

-- Consulta 4: Explorar la columna "rol"
	select * from participantes;
	go

	select 
		distinct rol
	from participantes;
	go

	select 
		grupo_id,
		count(rol) as [Cantidad de docentes]
	from participantes
	where rol = 'docente'
	group by grupo_id
	order by grupo_id
	go

-- Consulta 5: Explorar la columna "telefono_hash"
	select * from participantes;
	go

	select 
		count(*) as [Cantidad de participantes]
	from participantes;
	go 

	select 
		distinct telefono_hash
	from participantes;
	go 

	-- 1101 participantes
	-- 1071 participantes distintos 
	-- 30 copias

	select
		distinct telefono_hash,
		rol
	from participantes
	where rol = 'docente';
	go

	-- Hipótesis: no será que un familia tiene dos hijos y usa un único teléfono en dos grupos o el mismo grupo
	-- Hipótesis: ...

	select * from participantes;
	go

	select 
		rol,
		telefono_hash,
		count(*) as [Veces repetidos]
	from participantes
	group by rol, telefono_hash
	having count(*) > 1
	go

	with duplicados as (
		select
			telefono_hash
		from participantes
		group by telefono_hash
		having count(*) > 1
	)
	select p.*
	from participantes as p
	inner join duplicados as d on (p.telefono_hash = d.telefono_hash)
	order by telefono_hash;
	go 


-- Consulta 6: Explorar la columna "fecha_alta"
	select * from participantes;
	go

	select 
		distinct fecha_alta
	from participantes
	order by fecha_alta;
	go









