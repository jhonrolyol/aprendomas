
-- Establecer la conección a la base de datos "monitoring"
	use Monitoring;
	go


-- Tabla auxiliar "aux_semanas"
    drop table if exists aux_semanas;
    go
      
    select
        semana, 
        cast(inicio_semana as date) as inicio_semana,
        cast(fin_semana as date) as fin_semana
    into aux_semanas
    from (values (1,'2026-08-17','2026-08-23'),
                 (2,'2026-08-24','2026-08-30'),
                 (3,'2026-08-31','2026-09-06'),
                 (4,'2026-09-07','2026-09-13'),
                 (5,'2026-09-14','2026-09-20'),
                 (6,'2026-09-21','2026-09-27')) as s(semana, inicio_semana, fin_semana);
    go

    select * from aux_semanas;
    go
    
-- Tabla auxiliar "aux_familas"
    drop table if exists aux_familias;
    go

    select 
        p.telefono_hash   as persona_id,
        min(p.fecha_alta) as fecha_alta,
        min(p.grupo_id)   as grupo_id,   
        min(i.ugel)       as ugel
    into aux_familias
    from participantes p
    inner join grupos g        on (g.grupo_id       = p.grupo_id)
    inner join instituciones i on (i.institucion_id = g.institucion_id)
    --where p.rol = 'familia'
    group by p.telefono_hash;
    go

    select * from aux_familias;
    go

-- Tabla auxiliar "aux_evidencias"
    drop table if exists aux_evidencias;
    go

    select 
        distinct p.telefono_hash as persona_id, 
        a.semana
    into aux_evidencias
    from interacciones i
    inner join participantes p on (p.participante_id = i.participante_id and p.rol = 'familia')
    inner join actividades a   on (a.actividad_id    = i.actividad_id)
    where lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video');
    go

    select * from aux_evidencias;
    go

-- Tabla auxiliar "aux_base"
    drop table if exists aux_base;
    go

    select 
        s.semana, 
        f.persona_id, 
        f.grupo_id, 
        f.ugel,
        case 
            when e.persona_id is not null then 1 
            else 0
        end as participo
    into aux_base
    from aux_semanas s
    inner join aux_familias f  on (f.fecha_alta <= s.fin_semana)
    left join aux_evidencias e on (e.persona_id = f.persona_id and e.semana = s.semana);
    go

    select * from aux_base;
    go


-- Tasa de participación semanal
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


