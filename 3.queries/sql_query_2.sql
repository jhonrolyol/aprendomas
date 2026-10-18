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
    3.- Explore tables using basic queries  
    4.- Create auxiliary tables
    5.- SQL query from part 1.1
    6.- SQL query from part 1.2
    7.- SQL query from part 1.3
    8.- SQL query from part 1.4

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

-- 3.- Explore tables using basic queries 
    
    -- 3.1.- Query 1: Todos los campos 
        select * from instituciones;
        select * from grupos;
        select * from participantes;
        select * from interacciones;
        select * from actividades;
        go

    -- 3.2.- Query 2: Filas por tabla (esperado: 24, 48, 1101, 30, 7077)
        select
            'instituciones' as tabla,  
            count(*) as filas 
        from instituciones
        union all select 'grupos',        count(*) from grupos
        union all select 'participantes', count(*) from participantes
        union all select 'actividades',   count(*) from actividades
        union all select 'interacciones', count(*) from interacciones;
        go
        
    -- 3.3.- Query 3: Columnas, tipos y si aceptan nulos
        select 
            table_name as tabla, 
            ordinal_position as pos, 
            column_name as columna,
            data_type as tipo_dato, 
            character_maximum_length as largo, 
            is_nullable as acepta_nulos
        from information_schema.columns
        where table_name in ('instituciones','grupos','participantes','actividades','interacciones')
        order by table_name, ordinal_position;
        go
    
    -- 3.4.- Query 4: primeras 10 filas de cada tabla
        select top 10 * from instituciones order by institucion_id;
        select top 10 * from grupos        order by grupo_id;
        select top 10 * from participantes order by participante_id;
        select top 10 * from actividades   order by actividad_id;
        select top 10 * from interacciones order by interaccion_id;
        go

    -- 3.5.- Query 5: Instituciones por UGEL y zona
        select 
            ugel, 
            zona, 
            count(*) as instituciones
        from instituciones
        group by ugel, zona
        order by ugel, zona;
        go
    
    -- 3.6.- Query 6: Instituciones, grupos y familias por UGEL
        select 
            i.ugel,
            count(distinct i.institucion_id) as instituciones,
            count(distinct g.grupo_id)       as grupos,
            count(distinct case when p.rol = 'familia' then p.participante_id end) as registros_familia
        from instituciones i
        left join grupos g        on g.institucion_id = i.institucion_id
        left join participantes p on p.grupo_id       = g.grupo_id
        group by i.ugel
        order by i.ugel;
        go

    -- 3.7.- Query 7: Grupos por edad
        select 
            edad, 
            count(*) as grupos 
        from grupos 
        group by edad 
        order by edad;
        go

    -- 3.8.- Query 8: Grupos por institución (¿todas tienen la misma cantidad?)
        select 
            institucion_id, 
            count(*) as grupos
        from grupos
        group by institucion_id
        order by institucion_id;
        go

    -- 3.9.- Query 9: Registros por rol
        select 
            rol, 
            count(*) as registros, 
            count(distinct telefono_hash) as telefonos_distintos
        from participantes
        group by rol;
        go

    -- 3.10.- Query 10: Tamaño de los grupos (registros de familia por grupo)
        select 
            min(t.n) as min_familias, 
            max(t.n) as max_familias,
            cast(avg(cast(t.n as float)) as decimal(5,1)) as promedio_familias
        from (select 
                grupo_id, 
                count(*) as n 
              from participantes 
              where rol = 'familia' 
              group by grupo_id) as t;
        go

    -- 3.11.- Query 11: Altas por fecha (¿cuándo se registró la gente?)
        select 
            fecha_alta, 
            count(*) as altas
        from participantes
        group by fecha_alta
        order by fecha_alta;
        go

    -- 3.12.- Query 12: Rango de fechas de alta por rol
        select 
            rol, 
            min(fecha_alta) as primera_alta,
            max(fecha_alta) as ultima_alta
        from participantes
        group by rol;
        go 

    -- 3.13.- Query 13: Calendario completo de actividades
        select 
            actividad_id, 
            fecha_envio_utc, 
            datename(weekday, fecha_envio_utc) as dia_utc,
            area,
            semana
        from actividades
        order by fecha_envio_utc;
        go

    -- 3.14.- Query 14: Actividades por semana y por área
        select 
            semana, 
            count(*) as actividades, 
            min(fecha_envio_utc) as primera, 
            max(fecha_envio_utc) as ultima
        from actividades 
        group by semana 
        order by semana;
        go 

        select  
            area, 
            count(*) as actividades 
        from actividades 
        group by area 
        order by area;
        go 

    -- 3.15.- Query 15: Rango de fechas (UTC; Lima = UTC - 5)
        select 
            min(fecha_hora_utc) as primera_interaccion, 
            max(fecha_hora_utc) as ultima_interaccion
        from interacciones;
        go 

    -- 3.16.- Query 16: Valores de 'tipo' TAL CUAL vienen (agrupa por bytes; los corchetes muestran espacios finales). Con el collation por defecto, GROUP BY tipo fusionaría 'Foto' con 'foto'; por eso se agrupa por bytes.
        select 
            min('[' + tipo + ']') as tipo_literal, 
            count(*) as filas
        from interacciones
        group by convert(varbinary(20), tipo)
        order by filas desc;
        go

    -- 3.17.- Query 17: Interacciones por rol del participante ('(no registrado)' = ID que no está en participantes)
        select
            coalesce(p.rol, '(no registrado)') as rol, 
            count(*) as interacciones,
            count(distinct i.participante_id) as participantes_distintos
        from interacciones i
        left join participantes p on (p.participante_id = i.participante_id)
        group by coalesce(p.rol, '(no registrado)')
        order by interacciones desc;
        go

    -- 3.18.- Query 18: Interacciones por semana de la actividad
        select
            a.semana, 
            count(*) as interacciones, 
            count(distinct a.actividad_id) as actividades
        from interacciones i
        inner join actividades a on (a.actividad_id = i.actividad_id)
        group by a.semana
        order by a.semana;
        go 

    -- 3.19.- Query 19: Interacciones por actividad y UGEL (excluye IDs no registrados). Útil para detectar huecos. 
        select 
            i.actividad_id,
            sum(case when ins.ugel = 'UGEL A' then 1 else 0 end) as ugel_a,
            sum(case when ins.ugel = 'UGEL B' then 1 else 0 end) as ugel_b,
            sum(case when ins.ugel = 'UGEL C' then 1 else 0 end) as ugel_c
        from interacciones i
        inner join participantes p   on (p.participante_id  = i.participante_id)
        inner join grupos g          on (g.grupo_id         = p.grupo_id)
        inner join instituciones ins on (ins.institucion_id = g.institucion_id)
        group by i.actividad_id
        order by i.actividad_id;
        go 

    -- 3.20.- Query 20: Distribución por hora UTC (las horas 00-04 UTC son del día anterior en Lima)
        select 
            datepart(hour, fecha_hora_utc) as hora_utc, 
            count(*) as interacciones
        from interacciones
        group by datepart(hour, fecha_hora_utc)
        order by hora_utc;
        go

    -- 3.21.- Query 21: Tiempo de respuesta en horas desde el envío de la actividad (negativos = respondió ANTES del envío)
        select
            min(datediff(minute, a.fecha_envio_utc, i.fecha_hora_utc) / 60.0) as min_horas,
            max(datediff(minute, a.fecha_envio_utc, i.fecha_hora_utc) / 60.0) as max_horas,
            sum(case when i.fecha_hora_utc < a.fecha_envio_utc then 1 else 0 end) as respuestas_antes_del_envio
        from interacciones i
        inner join actividades a on (a.actividad_id = i.actividad_id);
        go 

    -- 3.22.- Query 22: Nulos y textos en blanco en las columnas de texto
        select 
            'participantes' as tabla,
            sum(case when participante_id is null or ltrim(rtrim(participante_id)) = '' then 1 else 0 end) as participante_id,
            sum(case when grupo_id        is null or ltrim(rtrim(grupo_id))        = '' then 1 else 0 end) as grupo_id,
            sum(case when rol             is null or ltrim(rtrim(rol))             = '' then 1 else 0 end) as rol,
            sum(case when telefono_hash   is null or ltrim(rtrim(telefono_hash))   = '' then 1 else 0 end) as telefono_hash,
            sum(case when fecha_alta      is null then 1 else 0 end) as fecha_alta
        from participantes;
        go 

        select
            'interacciones' as tabla,
            sum(case when interaccion_id  is null or ltrim(rtrim(interaccion_id))  = '' then 1 else 0 end) as interaccion_id,
            sum(case when participante_id is null or ltrim(rtrim(participante_id)) = '' then 1 else 0 end) as participante_id,
            sum(case when actividad_id    is null or ltrim(rtrim(actividad_id))    = '' then 1 else 0 end) as actividad_id,
            sum(case when fecha_hora_utc  is null then 1 else 0 end) as fecha_hora_utc,
            sum(case when tipo            is null or ltrim(rtrim(tipo))            = '' then 1 else 0 end) as tipo
        from interacciones;
        go 

    -- 3.23.- Query 23: Llaves repetidas (esperado: 0 en todas)
        select 
            'instituciones.institucion_id' as llave, 
            count(*) - count(distinct institucion_id) as repetidos 
        from dbo.instituciones
        union all select 'grupos.grupo_id',                count(*) - count(distinct grupo_id)        from dbo.grupos
        union all select 'participantes.participante_id',  count(*) - count(distinct participante_id) from dbo.participantes
        union all select 'actividades.actividad_id',       count(*) - count(distinct actividad_id)    from dbo.actividades
        union all select 'interacciones.interaccion_id',   count(*) - count(distinct interaccion_id)  from dbo.interacciones;


    -- 3.24.- Query 24: Teléfonos repetidos entre participantes (misma persona con más de un ID)
        select 
            count(*) as telefonos_con_mas_de_un_id
        from (select telefono_hash 
              from participantes 
              group by telefono_hash 
              having count(*) > 1) as t;
        go
    

-- 4.- Create auxiliary tables

    -- 4.1.- Table 1: Calendario de semanas (lunes a domingo). fin_semana = domingo.
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

    -- 4.2.- Table 2: Familias únicas (1 fila por PERSONA = telefono_hash). Fecha de alta MÁS ANTIGUA. Sin docentes.
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
        where p.rol = 'familia'
        group by p.telefono_hash;
        go

        select * from aux_familias;
        go

    -- 4.3.- Table 3: Evidencias: persona x semana con al menos 1 interacción con evidencia.
    --                ltrim/rtrim/lower normalizan 'Foto','FOTO ','Audio','Video'; 'imagen' se trata como foto.
    --                texto, reaccion y reenvio NO son evidencia. El inner join descarta IDs no registrados.
    --                distinct: una persona cuenta una vez por semana aunque tenga varios mensajes o 2 IDs.
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

    -- 4.4.- Table 4: Base analítica: cada familia registrada hasta el fin de cada semana (denominador)
    --                con la marca de si participó con evidencia (numerador).
        select * from aux_semanas;
        select * from aux_familias;
        select * from aux_evidencias;
        go

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

-- 5.- SQL query from part 1.1

    -- 5.1.- Tasa de participación semanal por UGEL y total (%, 1 decimal)
    --       tasa = familias distintas con evidencia / familias registradas hasta el domingo de esa semana.
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

    -- 5.2.- (apoyo) Familias registradas (denominador) y con evidencia (numerador) por semana y UGEL
        select * from aux_base;
        go
        
        select 
            semana as Semana,
            sum(case when ugel = 'UGEL A' then 1 else 0 end) as den_A, sum(case when ugel = 'UGEL A' then participo end) as num_A,
            sum(case when ugel = 'UGEL B' then 1 else 0 end) as den_B, sum(case when ugel = 'UGEL B' then participo end) as num_B,
            sum(case when ugel = 'UGEL C' then 1 else 0 end) as den_C, sum(case when ugel = 'UGEL C' then participo end) as num_C,
            count(*) as den_total, sum(participo) as num_total
        from aux_base 
        group by semana 
        order by semana;
        go

-- 6.- SQL query from part 1.2
    
    -- 6.1.- Cinco grupos con mayor caída: promedio semanas 1-4 vs promedio semanas 5-6.
    --       Caída en puntos porcentuales = prom(S1..S4) - prom(S5,S6); promedio simple de las tasas semanales del grupo. 
        select * from aux_base;
        select * from grupos;
        select * from instituciones;
        go
        
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
    
-- 7.- SQL query from part 1.3
    
    -- 7.1.- Familias con evidencia en >=2 semanas distintas de S1-S4 y SIN evidencia en S5 ni S6
        select * from aux_evidencias;
        go
        
        drop table if exists aux_dejan;
        go
        
        with hist as (
          select 
            persona_id,
            count(distinct case when semana between 1 and 4 then semana end) as sem_1_4,
            count(distinct case when semana between 5 and 6 then semana end) as sem_5_6
          from aux_evidencias
          group by persona_id
        )
        select 
            f.persona_id, 
            f.grupo_id, 
            f.ugel
        into aux_dejan
        from aux_familias f
        inner join hist h on (h.persona_id = f.persona_id)
        where (h.sem_1_4 >= 2 and h.sem_5_6 = 0);
        go

        select * from aux_dejan;
        go

    -- 7.2.- Total de familias que dejan de participar
        select * from aux_dejan;
        go

        select 
            count(*) as familias_que_dejan_de_participar 
        from aux_dejan;
        go

    -- 7.3.- Concentración por grupo (con % sobre las familias del grupo y % acumulado del total)
        select * from aux_dejan;
        go

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
        order by n_dejan desc, grupo_id;
        go

    -- 7.4.- Por UGEL
        select 
            ugel, 
            count(*) as n_dejan
        from aux_dejan 
        group by ugel 
        order by ugel;
        go

-- 8.- SQL query from part 1.4
    
    -- 8.1.- Quality control 1: Valores distintos de 'tipo' tal cual vienen (agrupa por bytes; los corchetes hacen visible el espacio final de 'FOTO ')
            select * from interacciones;
            go

            select 
                min('[' + tipo + ']') as tipo_literal,
                count(*) as filas
            from interacciones
            group by convert(varbinary(20), tipo)
            order by filas desc;
            go

    -- 8.2.- Quality control 2: Personas con más de un participante_id (mismo telefono_hash, mismo grupo)
        select * from participantes;
        go

        select 
            'Persona duplicada (mismo telefono_hash)' as control,
            count(*) as filas_afectadas,
            count(distinct telefono_hash) as personas_afectadas,
            count(*) - count(distinct telefono_hash) as registros_sobrantes
        from participantes
        where telefono_hash in (select telefono_hash from participantes group by telefono_hash having count(*) > 1);
        go

    -- 8.3.- Quality control 3: Interacciones duplicadas exactas (mismo participante, actividad, instante y tipo; distinto interaccion_id)
    --                          El tipo se compara por bytes para no fusionar 'Foto' con 'foto'.
        select * from interacciones;
        go
        
        select 
            'Interacción duplicada exacta' as control, 
            coalesce(sum(d.n - 1), 0) as filas_sobrantes, 
            count(*) as grupos_duplicados
        from (select 
                count(*) as n
              from interacciones
              group by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)
              having count(*) > 1) as d; 
        go

        with x as (
            select i.*,
                   count(*)     over (partition by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)) as copias,
                   row_number() over (partition by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)
                                      order by interaccion_id) as nro_copia
            from dbo.interacciones i
        )
        select *
        from x
        where copias > 1
        order by participante_id, actividad_id, fecha_hora_utc, nro_copia;
        go

    -- 8.4.- Quality control 4: Respuesta con fecha ANTERIOR al envío de la actividad (cronología imposible), comparada en hora de Lima.
    --                          Tratamiento elegido: se CONSERVAN (la actividad_id define la semana) y se cuantifica el efecto de excluirlas.
        select * from interacciones;
        select * from actividades;
        go

        select
            'Respuesta antes del envío' as control, 
            count(*) as filas_afectadas,
            sum(case when lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video') then 1 else 0 end) as con_evidencia,
            cast(min(datediff(minute, a.fecha_envio_utc, i.fecha_hora_utc)) / 60.0 as decimal(6,1)) as max_horas_antes
        from interacciones i
        inner join actividades a on (a.actividad_id = i.actividad_id)
        where dateadd(hour, -5, i.fecha_hora_utc) < dateadd(hour, -5, a.fecha_envio_utc);
        go 
        
    -- 8.5.- Quality control 5: HUECO DE DATOS: UGEL x actividad con CERO interacciones (ni de familias ni de docentes)
        select * from interacciones;
        select * from participantes;
        select * from grupos;
        select * from instituciones;
        
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
        
