
-- Establecer la conección a la base de datos "monitoring"
	use Monitoring;
	go


-- Modificando la tabla de interacciones
	select top 50 * from interacciones
	order by participante_id desc;
	go

	begin transaction; -- Inicio
		-- 1.- Make changes
			delete from interacciones
			where participante_id > 'P01101';
			go

		-- 2.- Check the results
			select * from interacciones
			order by participante_id desc;
			go

		-- 3.- Choose one:
			commit transaction; -- Hacer un "commit transaction" si estamos seguros de los cambios
			--rollback transaction; -- Hacer "rollback transaction" sino estamos seguros con los cambios o cometimos un error
	go 

	
-- Luego de eliminar a los participantes fantasma ¿Cambia la tasa de participación semanal, según hugel?
	select * from aux_base;
	go
        
	select 
            semana as Semana,
            cast(round(100.0 * sum(case when ugel = 'UGEL A' then participo end) / sum(case when ugel = 'UGEL A' then 1 end), 1) as decimal(5,1)) as [UGEL A],
            cast(round(100.0 * sum(case when ugel = 'UGEL B' then participo end) / sum(case when ugel = 'UGEL B' then 1 end), 1) as decimal(5,1)) as [UGEL B],
            cast(round(100.0 * sum(case when ugel = 'UGEL C' then participo end) / sum(case when ugel = 'UGEL C' then 1 end), 1) as decimal(5,1)) as [UGEL C],
            cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as Total
	from aux_base
	group by semana
	order by semana;   
	go


