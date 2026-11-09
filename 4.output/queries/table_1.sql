-- Consulta SQL para generar la tabla "aux_semanas"
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
