/* ========================================
	
	      Exploración general

===========================================*/

-- Conectar a la base de datos
	use monitoring;
	go

-- Explorar todas las tablas
	select * from instituciones;
	select * from grupos;
	select * from participantes;
	select * from interacciones;
	select * from actividades;
	go

-- Vista "v_tps_ugel"
	create or alter view v_tps_ugel
    as 
	select 
		semana as Semana,
		cast(round(100.0 * sum(case when ugel = 'UGEL A' then participo end) / sum(case when ugel = 'UGEL A' then 1 end), 1) as decimal(5,1)) as [UGEL A],
		cast(round(100.0 * sum(case when ugel = 'UGEL B' then participo end) / sum(case when ugel = 'UGEL B' then 1 end), 1) as decimal(5,1)) as [UGEL B],
		cast(round(100.0 * sum(case when ugel = 'UGEL C' then participo end) / sum(case when ugel = 'UGEL C' then 1 end), 1) as decimal(5,1)) as [UGEL C],
		cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as Total
	from aux_base
	group by semana;
	go
	 
-- Vista "v_tps_prom"
	create or alter view v_tps_prom 
	as
	with tasa_grupo_semana as (
          select 
            grupo_id, 
            semana,
            cast(100.0 * sum(participo) / count(*) as float) as tasa,   
            count(*) as n_familias
          from aux_base
          group by grupo_id, semana
	),
	resumen as (
          select 
            grupo_id,
            avg(case when semana between 1 and 4 then tasa end) as prom_s1_4,
            avg(case when semana between 5 and 6 then tasa end) as prom_s5_6,
            max(n_familias) as familias_s6
          from tasa_grupo_semana
          group by grupo_id
	)
	select top (5)
               r.grupo_id as grupo, 
               i.ugel,
               cast(round(r.prom_s1_4, 1) as decimal(5,1)) as prom_s1_4,
               cast(round(r.prom_s5_6, 1) as decimal(5,1)) as prom_s5_6,
               cast(round(r.prom_s1_4 - r.prom_s5_6, 1) as decimal(5,1)) as caida_pp,
               r.familias_s6
	from resumen r
	inner join grupos g        on (g.grupo_id       = r.grupo_id)
	inner join instituciones i on (i.institucion_id = g.institucion_id)
	order by (r.prom_s1_4 - r.prom_s5_6) desc, r.grupo_id;
	go



-- Verificar las interacciones de la semana 3 de ugel B

	select * from grupos;
	select * from participantes;

	
	select * from actividades;
	select * from interacciones;
	select * from instituciones;
	go

	select 
	* 
	from actividades t1 
	inner join interacciones t2 on t1.actividad_id = t2.actividad_id
	where t1.actividad_id = 'ACT013';













-- ...

select * from instituciones;
select distinct ugel from instituciones;


select * from instituciones;
select 
	ugel, 
	count(institucion_id) as total_instituciones_ugel
from instituciones
group by ugel;

select * from instituciones;
select * from instituciones
where (ugel = 'UGEL A' and (zona = 'urbana' or zona = 'rural')); 


select * from grupos;
select * from grupos
where (institucion_id = 'IE-A01');



select * from participantes;
select distinct rol from participantes;
select * from participantes
where (grupo_id = 'G-A01-4');
select * from participantes
where (grupo_id = 'G-A01-5');


select * from interacciones;
select distinct tipo from interacciones;
select actividad_id from interacciones;
select distinct actividad_id from interacciones
order by actividad_id asc;
select
	tipo,
	count(interaccion_id) as total
from interacciones
group by tipo;
select
	tipo,
	count(interaccion_id) as total,
	sum(count(interaccion_id)) over() as total_general
from interacciones
group by tipo;
select
	tipo,
	count(interaccion_id) as total,
	sum(count(interaccion_id)) over() as total_general
from interacciones
group by tipo
order by total desc;
select 
	actividad_id,
	count(interaccion_id) as total, 
	sum(count(interaccion_id)) over () as total_general
from interacciones
group by (actividad_id)
order by (total) desc;
select 
	actividad_id,
	count(interaccion_id) as total
from interacciones
where (tipo = 'audio')
group by (actividad_id)
order by (actividad_id);





