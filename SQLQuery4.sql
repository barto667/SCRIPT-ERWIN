select * from PRI_CATEGORIA

select * from PRI_PRODUCTOS where Cod_Producto='7007457'
select * from VIS_SERIES where Id_Producto='498' and Cod_Almacen='A0006' 

select Cod_Producto, count(Cod_Producto)
from PRI_PRODUCTOS
group by Cod_Producto
having count(Cod_Producto) > 1

select * from PRI_PRODUCTOS where Cod_Producto='7007446'