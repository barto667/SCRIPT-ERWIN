--Pruebas de comprobantes
--No en produccion

---Recupera los detalles de un tipo de comprobante
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  05/12/2016
-- USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante 'BE'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante' AND type = 'P')
DROP PROCEDURE USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante
go
CREATE PROCEDURE USP_VIS_TIPO_COMPROBANTES_TraerXCodTipoComprobante
@Cod_TipoComprobante varchar(50)
WITH ENCRYPTION
AS
BEGIN
	SELECT * FROM VIS_TIPO_COMPROBANTES where Cod_TipoComprobante=@Cod_TipoComprobante
END
go


---Recupera la fechas de comprobantes hasta antes de un dia emitidos en base a un codigo de estado
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  07/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado 'EMI'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerXFechasyEstado
@Cod_EstadoComprobante varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select CONVERT(VARCHAR(10), FechaEmision, 126) as Fecha, count(FechaEmision) as Totales
	from CAJ_COMPROBANTE_PAGO where  CONVERT(VARCHAR(10), FechaEmision, 126)<CONVERT(VARCHAR(10), GETDATE(), 126) and Cod_EstadoComprobante=@Cod_EstadoComprobante
	group by CONVERT(VARCHAR(10), FechaEmision, 126)
	having count(CONVERT(VARCHAR(10), FechaEmision, 126)) > 0 
END
go

/*
---Recupera los comprobantes que faltan emitir
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  09/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
WITH ENCRYPTION
AS
BEGIN
	select id_ComprobantePago,0 as Item,Cod_EstadoComprobante,'' as Cod_Mensaje,'' as Mensaje,Cod_UsuarioReg
	from CAJ_COMPROBANTE_PAGO
	where (Cod_EstadoComprobante<>'FIN' or Cod_EstadoComprobante<>'REC') and Flag_Anulado=0 
	and (Cod_TipoComprobante='BE' or Cod_TipoComprobante='FE' or Cod_TipoComprobante='NCE' or Cod_TipoComprobante='NDE')
END
go
*/

---Recupera los comprobantes que faltan emitir, agregados email
-- Autor(es): Rayme Chambi Erwin Miuller,Rayme Chambi Erwin Miuller
-- Fecha de Creación:  09/12/2016,26/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerSinFinalizar
WITH ENCRYPTION
AS
BEGIN
	select id_ComprobantePago,0 as Item,Cod_EstadoComprobante,'' as Cod_Mensaje,'' as Mensaje,ISNULL(PP.Email1,'') as Email1,ISNULL(PP.Email2,'') as Email2,CP.Cod_UsuarioReg
	from CAJ_COMPROBANTE_PAGO as CP inner join PRI_CLIENTE_PROVEEDOR as PP on CP.Id_Cliente=PP.Id_ClienteProveedor
	where (CP.Cod_EstadoComprobante<>'FIN' or CP.Cod_EstadoComprobante<>'REC') and CP.Flag_Anulado=0 
	and (CP.Cod_TipoComprobante='BE' or CP.Cod_TipoComprobante='FE' or CP.Cod_TipoComprobante='NCE' or CP.Cod_TipoComprobante='NDE')
END
go

-- Recupera el resumen de boletas dada una fecha 
-- La fecha debe entrar en formato AAAA/MM/DD
-- Autor(es): Rayme Chambi Erwin Miuller
-- Fecha de Creación:  13/12/2016
-- USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas '2016-12-05'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
@Fecha varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select RESB.TipoDocumento,RESB.Serie,RESB.CorrelativoDocumentoInicio,RESB.CorrelativoDocumentoFin,
	SUM(RESB.Importe_Total) as Importe_Total,SUM(RESB.SumaGravadas) as SumaGravadas, SUM (RESB.SumaExoneradas) as SumaExoneradas, SUM (RESB.SumaInafectas) as SumaInafectas,
	SUM(RESB.SumaGratuitas) as SumaGratuitas, SUM(RESB.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RESB.SumatoriaTotalISC) as SumatoriaISC,
	SUM(RESB.TotalOtrosCargos) as TotalOtrosCargos,SUM(RESB.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
	 from
	(select  distinct '03' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
	where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
	where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
	SUM(CD.Sub_Total) as Importe_Total,
	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV) as RESB
	group by TipoDocumento,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin
	union
	select case when RES.Cod_TipoComprobante='NCE' then '07' when  RES.Cod_TipoComprobante='NDE' then '08' end aS TipoDocumento,RES.Serie,RES.CorrelativoDocumentoInicio,RES.CorrelativoDocumentoFin,
	SUM(RES.Importe_Total) as Importe_Total,SUM(RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
	SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RES.SumatoriaTotalISC) as SumatoriaISC,
	SUM(RES.TotalOtrosCargos) as TotalOtrosCargos,SUM(RES.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
	 from
	(select  distinct Cp.Cod_TipoComprobante,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
	SUM(CD.Sub_Total) as Importe_Total,
	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where (CP.Cod_TipoComprobante='NPE' or CP.Cod_TipoComprobante='NCE') and CP.Serie LIKE 'B' +'%' and Cp.Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV,CP.Cod_TipoComprobante) as RES
	group by Cod_TipoComprobante,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin

END
go


--FALLANDO
/*
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas' AND type = 'P')
DROP PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
go
CREATE PROCEDURE USP_CAJ_COMPROBANTE_PAGO_TraerResumenBoletas
@Fecha varchar(10)
WITH ENCRYPTION
AS
BEGIN
	select case when RES.Cod_TipoComprobante='NCE' then '07' when  RES.Cod_TipoComprobante='NDE' then '08'  when  RES.Cod_TipoComprobante='BE' then '03'end aS TipoDocumento,RES.Serie,RES.CorrelativoDocumentoInicio,RES.CorrelativoDocumentoFin,
	SUM(RES.Importe_Total) as Importe_Total,SUM(RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
	SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RES.SumatoriaTotalISC) as SumatoriaISC,
	SUM(RES.TotalOtrosCargos) as TotalOtrosCargos,SUM(RES.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
	 from
	(select  distinct Cp.Cod_TipoComprobante,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
	(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
	where (Cod_TipoComprobante=CP.Cod_TipoComprobante) and Serie LIKE 'B' +'%' and Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
	SUM(CD.Sub_Total) as Importe_Total,
	case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
	case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
	case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
	case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
	then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
	SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
	from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where ((CP.Cod_TipoComprobante='NPE' or CP.Cod_TipoComprobante='NCE') and CP.Serie LIKE 'B' +'%') or (CP.Cod_TipoComprobante='BE') and Cp.Cod_EstadoComprobante<>'FIN'
	and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV,CP.Cod_TipoComprobante) as RES
	group by Cod_TipoComprobante,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin
END
go

*/

/*


(select RES.id_ComprobantePago, RES.Serie,RES.Numero,CONVERT(VARCHAR(10), RES.FechaEmision, 126) as FechaEmision,RES.Cod_TipoComprobante,RES.Cod_TipoDoc,
RES.Doc_Cliente,RES.Total,RES.Otros_Cargos,RES.Otros_Tributos, SUM (RES.SumaGravadas) as SumaGravadas, SUM (RES.SumaExoneradas) as SumaExoneradas, SUM (RES.SumaInafectas) as SumaInafectas,
SUM(RES.SumaGratuitas) as SumaGratuitas, SUM(RES.SumatoriaIGV) as SumatoriaIGV,SUM(RES.SumatoriaISC) as SumatoriaISC from 
(select distinct CP.id_ComprobantePago, CP.Serie,CP.Numero,CONVERT(VARCHAR(10), CP.FechaEmision, 126) as FechaEmision, 
case when Cp.Cod_TipoComprobante='BE' then '03' when Cp.Cod_TipoComprobante='NCE' then '07' when Cp.Cod_TipoComprobante='NPE' then '08' end as Cod_TipoComprobante ,Cp.Cod_TipoDoc,
Cp.Doc_Cliente,Cp.Total,CP.Otros_Cargos,cp.Otros_Tributos, 
case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas, 
case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
case when 
CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or
CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas, 
SUM(CD.IGV) as SumatoriaIGV, SUM(CD.ISC) as SumatoriaISC
from CAJ_COMPROBANTE_PAGO as CP full outer join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago
where CP.Cod_TipoComprobante='BE' and CONVERT(VARCHAR(10), CP.FechaEmision, 126)='2016-11-26'
group by CP.id_ComprobantePago,CP.Serie,CP.Numero,CP.FechaEmision,CP.Cod_TipoComprobante,cp.Cod_TipoDoc,CP.Doc_Cliente,Cp.Total,
Cp.Otros_Cargos,Cp.Otros_Tributos,CD.Sub_Total,CD.Cod_TipoIGV) as RES group by RES.id_ComprobantePago, RES.Serie,RES.Numero,CONVERT(VARCHAR(10), RES.FechaEmision, 126),RES.Cod_TipoComprobante,RES.Cod_TipoDoc,
RES.Doc_Cliente,RES.Total,RES.Otros_Cargos,RES.Otros_Tributos)



declare  @Fecha varchar(10)='2016-12-05'

select  distinct 'BE' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
and CONVERT(VARCHAR(10), FechaEmision, 126)='2016-12-05' order by Numero asc) as CorrelativoDocumentoInicio,
(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
SUM(CP.Total) as Importe_Total,SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
from CAJ_COMPROBANTE_PAGO as CP where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante<>'FIN'
and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie



declare  @Fecha varchar(10)='2016-12-13'
select RESB.TipoDocumento,RESB.Serie,RESB.CorrelativoDocumentoInicio,RESB.CorrelativoDocumentoFin,
SUM(RESB.Importe_Total) as Importe_Total,SUM(RESB.SumaGravadas) as SumaGravadas, SUM (RESB.SumaExoneradas) as SumaExoneradas, SUM (RESB.SumaInafectas) as SumaInafectas,
SUM(RESB.SumaGratuitas) as SumaGratuitas, SUM(RESB.SumatoriaTotalIGV) as SumatoriaIGV,SUM(RESB.SumatoriaTotalISC) as SumatoriaISC,
SUM(RESB.TotalOtrosCargos) as TotalOtrosCargos,SUM(RESB.SumatoriaTotalOtrosTrib) as SumatoriaTotalOtrosTrib
 from
(select  distinct '03' as TipoDocumento,CP.Serie, (select Top 1 Numero from CAJ_COMPROBANTE_PAGO  
where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero asc) as CorrelativoDocumentoInicio,
(select Top 1 Numero from CAJ_COMPROBANTE_PAGO 
where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and Serie=Cp.Serie
and CONVERT(VARCHAR(10), FechaEmision, 126)=@Fecha order by Numero desc) as CorrelativoDocumentoFin,
SUM(CD.Sub_Total) as Importe_Total,
case when CD.Cod_TipoIGV=10 or CD.Cod_TipoIGV=17 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGravadas,
case when CD.Cod_TipoIGV=20 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaExoneradas,
case when CD.Cod_TipoIGV=40 then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaInafectas,
case when CD.Cod_TipoIGV=11 or CD.Cod_TipoIGV=12 or CD.Cod_TipoIGV=13 or CD.Cod_TipoIGV=14 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=15 or CD.Cod_TipoIGV=16 or CD.Cod_TipoIGV=20 or CD.Cod_TipoIGV=31 or CD.Cod_TipoIGV=32 or CD.Cod_TipoIGV=33 or CD.Cod_TipoIGV=34 or CD.Cod_TipoIGV=35 or CD.Cod_TipoIGV=36 
then SUM(CD.Sub_Total-(CD.IGV+CD.ISC)) else 0 end as SumaGratuitas,
SUM(CP.Otros_Cargos) as TotalOtrosCargos,SUM(CD.IGV) as SumatoriaTotalIGV,SUM(CD.ISC) as SumatoriaTotalISC,SUM(CP.Otros_Tributos) as SumatoriaTotalOtrosTrib
from CAJ_COMPROBANTE_PAGO as CP left join CAJ_COMPROBANTE_D as CD on CP.id_ComprobantePago=CD.id_ComprobantePago where cp.Cod_TipoComprobante='BE' and Cp.Cod_EstadoComprobante<>'FIN'
and CONVERT(VARCHAR(10), Cp.FechaEmision, 126)=@Fecha group by Cp.Serie,CD.Cod_TipoIGV) as RESB
group by TipoDocumento,Serie,CorrelativoDocumentoInicio,CorrelativoDocumentoFin

/*select * from CAJ_COMPROBANTE_D as CD inner Join CAJ_COMPROBANTE_PAGO as CP on cd.id_ComprobantePago=Cp.id_ComprobantePago where CP.Cod_TipoComprobante='BE' and CP.Cod_EstadoComprobante<>'FIN' and CONVERT(VARCHAR(10), CP.FechaEmision, 126)='2016-12-13'
select * from CAJ_COMPROBANTE_PAGO where Cod_TipoComprobante='BE' and Cod_EstadoComprobante<>'FIN' and CONVERT(VARCHAR(10), FechaEmision, 126)='2016-12-13'

*/