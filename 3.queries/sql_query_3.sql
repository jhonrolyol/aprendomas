/*==================================================================================================
  Description of the SQL query
  
                                       " Caso Práctico "
  
           .--.                  
          |o_o |         
          |:_/ |           ---------------------------------------------------
         //   \ \                  Monitoreo de Participación Semanal 
        (|     | )         ---------------------------------------------------        
        /'\_   _/`\   
        \___)=(___/
    
  Outline
    1.- Keyboard shortcuts
    2.- Use the "monitoring" database
    3.- Construction of views
    4.- Additional exploratory consultations

                                         Jhon R. Ordoñez
                                    (rolyordonezleon@gmail.com)
                                                                                            ><(((º>
==================================================================================================*/


-- 1.- Keyboard shortcuts
    -- Ctrl + s: save
    -- Ctrl + e or F5: execute the code (Remember to select the code that is to be executed)
    -- Select the code --> right-click --> Execute: execute the code (I like this option better)
    -- ...

-- 2.- Use the "monitoring" database
    use monitoring;
    go 

-- 3.- Construction of views
    
    -- 3.1.- View 1: v_tps_ugel
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

    -- 3.2.- View 2: v_tps_prom
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

    -- 3.3.- View 3: v_n_dejan
        create or alter view v_n_dejan
        as
        with por_grupo as (
          select 
            d.grupo_id, 
            d.ugel, 
            count(*) as n_dejan,
            (select count(*) from aux_familias f where f.grupo_id = d.grupo_id) as familias_grupo
          from aux_dejan d
          group by d.grupo_id, d.ugel
        )
        select 
            grupo_id as grupo,
            ugel, 
            n_dejan,
            familias_grupo, 
            cast(round(100.0 * n_dejan / familias_grupo, 1) as decimal(5,1)) as pct_del_grupo,
            cast(round(100.0 * sum(n_dejan) over (order by n_dejan desc, grupo_id rows unbounded preceding) / sum(n_dejan) over (), 1) as decimal(5,1)) as pct_acum_del_total
        from por_grupo
        go

    -- 3.4.- View 4: ...
    -- 3.5.- View 5: ...
    -- 3.6.- View 6: ...


-- 4.- Additional exploratory consultations

    -- 4.1.- Formato ancho: una fila por grupo, columnas S1 a S6 (+ tasa del periodo completo)
        select
            grupo_id as Grupo,
            ugel as UGEL,
            cast(round(100.0 * sum(case when semana = 1 then participo end) / sum(case when semana = 1 then 1 end), 1) as decimal(5,1)) as [S1],
            cast(round(100.0 * sum(case when semana = 2 then participo end) / sum(case when semana = 2 then 1 end), 1) as decimal(5,1)) as [S2],
            cast(round(100.0 * sum(case when semana = 3 then participo end) / sum(case when semana = 3 then 1 end), 1) as decimal(5,1)) as [S3],
            cast(round(100.0 * sum(case when semana = 4 then participo end) / sum(case when semana = 4 then 1 end), 1) as decimal(5,1)) as [S4],
            cast(round(100.0 * sum(case when semana = 5 then participo end) / sum(case when semana = 5 then 1 end), 1) as decimal(5,1)) as [S5],
            cast(round(100.0 * sum(case when semana = 6 then participo end) / sum(case when semana = 6 then 1 end), 1) as decimal(5,1)) as [S6],
            cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as [Periodo]  
        from aux_base
        group by grupo_id, ugel
        order by grupo_id;
        go

        select
            grupo_id as Grupo,
            ugel as UGEL,
            cast(round(100.0 * sum(case when semana = 1 then participo end) / sum(case when semana = 1 then 1 end), 1) as decimal(5,1)) as [S1],
            cast(round(100.0 * sum(case when semana = 2 then participo end) / sum(case when semana = 2 then 1 end), 1) as decimal(5,1)) as [S2],
            cast(round(100.0 * sum(case when semana = 3 then participo end) / sum(case when semana = 3 then 1 end), 1) as decimal(5,1)) as [S3],
            cast(round(100.0 * sum(case when semana = 4 then participo end) / sum(case when semana = 4 then 1 end), 1) as decimal(5,1)) as [S4],
            cast(round(100.0 * sum(case when semana = 5 then participo end) / sum(case when semana = 5 then 1 end), 1) as decimal(5,1)) as [S5],
            cast(round(100.0 * sum(case when semana = 6 then participo end) / sum(case when semana = 6 then 1 end), 1) as decimal(5,1)) as [S6],
            cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as [Periodo]  
        from aux_base
        where ugel = 'ugel c'
        group by grupo_id, ugel
        order by grupo_id;
        go

    -- 4.2.- Formato largo: una fila por grupo y semana (el más cómodo para Power BI y para gráficos)
        select
            grupo_id as Grupo,
            ugel as UGEL,
            semana as Semana,
            sum(participo) as Con_evidencia,
            count(*) as Registradas,
            cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as Tasa
        from aux_base
        group by grupo_id, ugel, semana
        order by grupo_id, semana;
        go

    -- 4.3.- Tasa de participación semanal promedio de las 3 instituciones frente al resto del programa
        select * from aux_base;
        select * from grupos;
        go
        
        select
            b.semana as Semana,
            cast(round(100.0 * sum(case when g.institucion_id in ('IE-C05','IE-C06','IE-C07') then b.participo end) / sum(case when g.institucion_id in ('IE-C05','IE-C06','IE-C07') then 1 end), 1) as decimal(5,1)) as [IE-C05/06/07],
            cast(round(100.0 * sum(case when g.institucion_id not in ('IE-C05','IE-C06','IE-C07') then b.participo end) / sum(case when g.institucion_id not in ('IE-C05','IE-C06','IE-C07') then 1 end), 1) as decimal(5,1)) as [Resto],
            cast(round(100.0 * sum(b.participo) / count(*), 1) as decimal(5,1)) as Total
        from aux_base b
        inner join grupos g on g.grupo_id = b.grupo_id
        group by b.semana
        order by b.semana;
        go

    -- 4.4.- Promedios con la misma convención de 1.2 (promedio simple de las tasas semanales)
        with t as (
            select b.semana,
                   case when g.institucion_id in ('IE-C05','IE-C06','IE-C07') then 'IE-C05/06/07' else 'Resto' end as segmento,
                   cast(100.0 * sum(b.participo) / count(*) as float) as tasa
            from aux_base b
            inner join grupos g on g.grupo_id = b.grupo_id
            group by b.semana, case when g.institucion_id in ('IE-C05','IE-C06','IE-C07') then 'IE-C05/06/07' else 'Resto' end
        )
        select segmento,
               cast(round(avg(case when semana between 1 and 4 then tasa end), 1) as decimal(5,1)) as prom_s1_s4,
               cast(round(avg(case when semana between 5 and 6 then tasa end), 1) as decimal(5,1)) as prom_s5_s6,
               cast(round(avg(case when semana = 6 then tasa end), 1) as decimal(5,1)) as solo_s6
        from t
        group by segmento;
        go

    -- 4.5.- De las 142 familias que dejan de participar, cuántas son de esas instituciones
        select 
            g.institucion_id as Institucion, count(*) as Familias_que_dejan,
            sum(count(*)) over () as Total_programa,
            cast(round(100.0 * count(*) / sum(count(*)) over (), 1) as decimal(5,1)) as Pct_del_total
        from aux_dejan d
        inner join grupos g on g.grupo_id = d.grupo_id
        group by g.institucion_id
        order by Familias_que_dejan desc, g.institucion_id;
        go

    -- 4.6.- Las tres instituciones con mayor caida son de la zona rural y ugel c
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
               i.zona,
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

    -- 4.7.- HUECO DE DATOS: UGEL x actividad con CERO interacciones (ni de familias ni de docentes)
        with x as (
          select 
            ins.ugel, 
            i.actividad_id,
            count(*) as n
          from interacciones i
          inner join participantes p   on (p.participante_id  = i.participante_id)
          inner join grupos g          on (g.grupo_id         = p.grupo_id)
          inner join instituciones ins on (ins.institucion_id = g.institucion_id)
          group by ins.ugel, i.actividad_id
        )
        select 
            u.ugel, 
            a.actividad_id, 
            a.fecha_envio_utc, 
            a.semana, 
            coalesce(x.n, 0) as interacciones
        from (select distinct ugel from instituciones) u
        cross join actividades a
        left join x on (x.ugel = u.ugel and x.actividad_id = a.actividad_id)
        where coalesce(x.n, 0) = 0;
        go

    -- 4.8.- Variantes de 'tipo' (mayúsculas, espacio final, sinónimo 'imagen').
        select count(*) from interacciones;
        select 
            distinct tipo, 
            count(*) as n 
        from interacciones
        group by tipo;
        go

        select 
            'Tipo no estandarizado' as control,
            count(*) as filas_afectadas,
            sum(case when lower(ltrim(rtrim(tipo))) in ('foto','imagen','audio','video') then 1 else 0 end) as de_las_cuales_con_evidencia,
            (select count(*) from interacciones) as filas_base
        from interacciones
        where tipo collate Latin1_General_BIN2 not in ('texto','foto','audio','video','reaccion','reenvio') or datalength(tipo) <> len(tipo);
        go 

        select * from interacciones;
        go

        select 
            min('[' + tipo + ']') as tipo_literal,
            count(*) as filas
        from interacciones
        group by convert(varbinary(20), tipo)
        order by filas desc;
        go

    -- 4.9.- ¿Algún duplicado está en grupos distintos? (si fuera >0, min(grupo_id) en aux_familias sería ambiguo)
        select * from participantes;
        go

        select 
            count(*) as telefonos_en_mas_de_un_grupo
        from (select telefono_hash from participantes group by telefono_hash having count(distinct grupo_id) > 1) as t;
        go

    -- 4.10.- INFORMATIVO (no es un error): grupos.docente_id ('D-A01-4') y participantes.participante_id ('P00529') son
    --                          identificadores distintos por diseño (confirmado por Aprendo+).
    --                          La docente se ubica con participantes.rol = 'docente' y grupo_id.
        select * from grupos;
        select * from participantes;
        go
        
        select 
            'Docente_id sin llave de cruce' as control,
            count(*) as grupos_afectados,
           (select count(*) from grupos) as grupos_total
        from grupos g
        where not exists (select 1 from participantes p where p.participante_id = g.docente_id);
        go
        
    -- 4.11.- Silencio de docentes: grupo x semana sin NINGÚN mensaje del docente
        select * from grupos;
        select * from aux_semanas;
        select * from interacciones;
        select * from participantes;
        select * from actividades;
        go 

        select 
            g.grupo_id, 
            s.semana
        from grupos g
        cross join aux_semanas s
        where not exists (
          select 1
          from interacciones i
          inner join participantes p on p.participante_id = i.participante_id and p.rol = 'docente' and p.grupo_id = g.grupo_id
          inner join actividades a   on a.actividad_id    = i.actividad_id    and a.semana = s.semana)
        order by g.grupo_id, s.semana;
        go

    -- 4.12.- Huso horario: fecha_hora_utc está en UTC; Lima = UTC - 5. Las horas 00:00-04:59 UTC caen en el DÍA ANTERIOR en Lima.
    --                          No afecta la métrica (la semana la define la actividad; todas las actividades tienen la misma fecha en UTC y en Lima).
        select * from interacciones;
        go 

        select 
            'Fecha UTC distinta a fecha Lima' as control,
            sum(case when datepart(hour, fecha_hora_utc) < 5 then 1 else 0 end) as filas_afectadas,
            count(*) as filas_base
        from interacciones;
        go

    -- 4.13.- Frescura: último dato vs fecha del reporte (2-nov-2026)
        select * from interacciones;
        go
        
        select 
            max(fecha_hora_utc) as ultimo_dato_utc, 
            min(fecha_hora_utc) as primer_dato_utc,
            datediff(day, cast(max(fecha_hora_utc) as date), 
            cast('2026-11-02' as date)) as dias_sin_datos_al_2_nov
        from interacciones;
        go

    -- 4.14.- Consistencia de actividades.semana con el calendario (lun-dom)
        select * from actividades;
        select * from aux_semanas;
        go
       
        select 
            'Actividad fuera de su semana' as control, 
            count(*) as filas_afectadas
        from actividades a
        inner join aux_semanas s on (s.semana = a.semana)
        where cast(a.fecha_envio_utc as date) not between s.inicio_semana and s.fin_semana;
        go

    -- 4.15.- Familias (personas únicas) registradas sin ninguna interacción en las 6 semanas
        select * from aux_familias;
        select * from participantes;
        select * from interacciones;
        go 

        select 
            'Familia sin ninguna interacción' as control, 
            count(*) as personas_afectadas,
            (select count(*) from aux_familias) as personas_base
        from aux_familias f
        where not exists (
            select 1
            from participantes p
            inner join interacciones i on (i.participante_id = p.participante_id)
            where p.telefono_hash = f.persona_id);
        go

    -- 4.16.- Controles SIN hallazgos (deben dar 0)
        select 
            'nulos en interacciones' as control,
            sum(case when participante_id is null or actividad_id is null or fecha_hora_utc is null or tipo is null then 1 else 0 end) as filas
        from dbo.interacciones
        union all select 'interaccion_id repetido', count(*) - count(distinct interaccion_id) from dbo.interacciones
        union all select 'participante_id repetido', count(*) - count(distinct participante_id) from dbo.participantes
        union all select 'interacción con actividad inexistente', count(*) from dbo.interacciones i
                  where not exists (select 1 from dbo.actividades a where a.actividad_id = i.actividad_id)
        union all select 'participante con grupo inexistente', count(*) from dbo.participantes p
                  where not exists (select 1 from dbo.grupos g where g.grupo_id = p.grupo_id)
        union all select 'grupo con institución inexistente', count(*) from dbo.grupos g
                  where not exists (select 1 from dbo.instituciones n where n.institucion_id = g.institucion_id)
        union all select 'docente con foto/audio/video', count(*) from dbo.interacciones i
                  join dbo.participantes p on p.participante_id = i.participante_id
                  where p.rol = 'docente' and lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video')
        union all select 'familia con tipo reenvio', count(*) from dbo.interacciones i
                  join dbo.participantes p on p.participante_id = i.participante_id
                  where p.rol = 'familia' and i.tipo = 'reenvio'
        union all select 'interacción antes de la fecha_alta', count(*) from dbo.interacciones i
                  join dbo.participantes p on p.participante_id = i.participante_id
                  where cast(i.fecha_hora_utc as date) < p.fecha_alta;
        go

    -- 4.17.- Interacciones de participante_id que no existe en participantes (huérfanas)
        select * from interacciones;
        select * from participantes;
        go
        
        select 
            'Interacción de ID no registrado' as control, 
            count(*) as filas_afectadas,
            count(distinct i.participante_id) as ids_distintos,
            sum(case when lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video') then 1 else 0 end) as con_evidencia
        from interacciones i
        where not exists (select 1 from participantes p where p.participante_id = i.participante_id);
        go

    -- 4.18.- ...
    -- 4.19.- ...

