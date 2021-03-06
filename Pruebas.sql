select * from PAR_FILA 

declare @Cod_Precio varchar(10)='PNSA'
declare @Id_Fila int = (select Top(1)Cod_Fila from PAR_FILA  where Cod_Tabla=83 and Cod_Fila=(select top(1) Cod_Fila from PAR_FILA where Cod_Tabla=83 and Cadena=@Cod_Precio and Cod_Columna=1))
declare @Cod_Padre varchar(10) = (select top(1) Cadena from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cod_Fila=@Id_Fila)
declare @Orden int =   (select top(1)Entero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Id_Fila)
select  @Id_Fila

drop table #temp1
select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4
drop table #temp2
select Cod_Fila into #temp2 from #temp1  where Cadena=@Cod_Padre

declare @fila int;
declare cursor_fila cursor for select T2.Cod_Fila from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T2.Cod_Columna=5 and T1.Cod_Fila=T2.Cod_Fila and T2.Entero>@Orden
open cursor_fila;
fetch cursor_fila into @fila;
WHILE (@@FETCH_STATUS = 0 )
begin;
update PAR_FILA set Entero=Entero-1 where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila= @fila;
fetch cursor_fila into @fila;
end;
close cursor_fila;
deallocate cursor_fila;

delete from PAR_FILA where Cod_Tabla=83 and Cod_Fila=4

/*
--Recuperamos previamente el codigo de la fila
declare @Fila int=5
declare @Orden int = (select top(1) Entero from PAR_FILA where Cod_Tabla=83 and Cod_Columna=5 and Cod_Fila=@Fila)
--Recuperamos el padre
declare @Cod_Padre varchar(10) = (select top(1) Cadena from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cod_Fila=@Fila)
--Recuperamos todos aquellos registros que tengan el mismo padre
drop table #temp1
select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4 and Cadena=@Cod_Padre 
select * from #temp1
--Recuperamos solo los planes con orden mayor al de la fila
drop table #temp2
select  * into #temp2  from PAR_FILA  where Cod_Tabla=83 and Cod_Columna=5 and Entero>=@Orden order by Entero ASC
select * from #temp2


drop table #temp3
select Entero,Entero into #temp3 from #temp2 order by Entero ASC
select Cod_Fila,Entero  from #temp2 order by Entero ASC
select * from #temp3 


--Recuperamos los registros que tienen un orden mayor y que tienen padre comun
drop table #temp4
select T1.Cod_Fila into #temp4 from #temp1 as T1 inner join #temp2 as T2 on T1.Cod_Tabla=T2.Cod_Tabla and T1.Cod_Fila=T2.Cod_Fila
select * from #temp4

drop table #temp5
--Recuperamos una lista de codigos de planes en base a los codigos de fila obtenidos
select T1.Cod_Fila into #temp5 from PAR_FILA as T1 inner join #temp3 as T2 on T1.Cod_Tabla=83 and T1.Cod_Columna=1 and T1.Cod_Fila=T2.Cod_Fila order by T2.Entero ASC

--Aplicar delete from PAR_FILA where Cod_Tabla=83 and Cod_Fila=@Fila para borrar todos los registros
select * from #temp1
select * from #temp2
select * from #temp3
select * from #temp4
select * from #temp5*/
--delete from PAR_FILA where Cod_Tabla=83
select Cod_Precio,Nom_Precio,Cod_Categoria,Cod_PrecioPadre,Orden,Estado from VIS_PRECIOS
--select * from PRI_CATEGORIA
delete from PAR_FILA where Cod_Tabla=83



--Necesitamos un codigo de padre
declare @Cod_Padre varchar(10)='P'
declare @Orden int=0
drop table #temp1
select * into #temp1 from PAR_FILA where Cod_Tabla=83 and Cod_Columna=4
drop table #temp2
select * into #temp2 from #temp1  where Cadena=@Cod_Padre
select * from #temp2

select * from #temp2 as T1 inner join PAR_FILA as T2 on T2.Cod_Tabla=83 and T1.Cod_Fila=T2.Cod_Fila 

--Recuperamos el codigo de la fila en base al codigo del plan
declare @Cod_Fila int= (select MAX(Cod_Fila) from PAR_FILA where Cod_Tabla=83 and Cod_Columna=1 and Cadena ='P7')

select * from VIS_PRECIOS 

EXEC USP_VIS_PRECIOS_xCategoria 

drop table #temp1
create table #temp1 (Cod_Almacen varchar(10),Stock_Max numeric(38, 6),Stock_Min numeric(38, 6),Stock_Act numeric(38, 6),Cod_UnidadMedida varchar(10),Nom_Producto varchar(100),Id_Producto int)
INSERT INTO #temp1 EXEC [dbo].[USP_PRI_PRODUCTO_STOCK_TXAlmacen] @Cod_Almacen = N'A00142'
drop table #temp2
select T1.Id_Producto,T1.Cod_UnidadMedida,T2.Des_CortaProducto from #temp1 as T1 inner join #temp2 as T2 on T1.Id_Producto=T2.Id_Producto

SELECT *  FROM [PALERPmelqui].[dbo].[PRI_PRODUCTOS] where Des_CortaProducto='Alcatel OT5050 POP S3'
select * from PRI_PRODUCTOS where Des_CortaProducto='ALCATEL OT-1030A'
select * from PRI_PRODUCTO_PRECIO where Id_Producto=3
select * from PRI_PRODUCTOS where SOUNDEX('ACE LIQUID Z410') =SOUNDEX(Des_CortaProducto)



select * from PRI_PRODUCTOS where Des_CortaProducto='ALCATEL OT-1030A'
select * from PRI_PRODUCTOS as P inner join PRI_PRODUCTO_PRECIO as PP on P.Des_CortaProducto='RV' and PP.Cod_TipoPrecio='REC' and P.Id_Producto=PP.Id_Producto

