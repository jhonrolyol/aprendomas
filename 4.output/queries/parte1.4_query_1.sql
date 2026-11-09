-- Valores distintos de 'tipo' tal cual vienen (agrupa por bytes; los corchetes hacen visible el espacio final de 'FOTO ')
select 
    min('[' + tipo + ']') as tipo_literal,
    count(*) as filas
from interacciones
group by convert(varbinary(20), tipo)
order by filas desc;
go
