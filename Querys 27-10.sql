---------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- CONVERSION DE FECHAS JDE -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

select to_char(TO_DATE(TO_CHAR(117001+1900000),'YYYYDDD'),'YYYY-MM-DD') jdedate from dual;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- COMPAÑIA --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW  LOCALES1   AS ( 

SELECT
    TRIM(T2.MCMCU) UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCRP06) CONCENTRADORA_LC,
      TRIM(T1.CCCO) COMPAÑIA_LC,
    T2.MCAN8 ID_DIRECCION_LC,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.MCSTYL = UDC.DRKY   AND 
                              UDC.DRSY  LIKE '00  '  AND 
                              UDC.DRRT   LIKE 'MC') TIPO_UNIDAD_NEGOCIO_LC,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T3.ABAC03||  '' = UDC.DRKY   AND 
                              UDC.DRSY   LIKE '01  '  AND 
                              UDC.DRRT   = '03') CATEGORIA_UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCDL01) DESC_UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCTXA1) TASA_FISCAL
FROM
    QADTA.F0010 T1, 
    QADTA.F0006 T2,
    QADTA.F0101 T3
WHERE
    T1.CCCO = T2.MCCO
    AND T2.MCAN8 = T3.ABAN8
    
UNION ALL

SELECT
    TRIM(T2.MCMCU) UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCRP06)CONCENTRADORA_LC,
    TRIM(T1.CCCO) COMPAÑIA_LC,
    T2.MCAN8 ID_DIRECCION_LC,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.MCSTYL = UDC.DRKY   AND 
                              UDC.DRSY  LIKE '00  '  AND 
                              UDC.DRRT   LIKE 'MC') TIPO_UNIDAD_NEGOCIO_LC,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              UDC.DRKY LIKE '          '   AND 
                              UDC.DRSY   LIKE '01  '  AND 
                              UDC.DRRT   = '03') CATEGORIA_UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCDL01) DESC_UNIDAD_NEGOCIO_LC,
    TRIM(T2.MCTXA1) TASA_FISCAL
FROM
    QADTA.F0010 T1, 
    QADTA.F0006 T2  
WHERE
    T1.CCCO = T2.MCCO
    AND NOT EXISTS (SELECT * FROM QADTA.F0101 T3 WHERE T2.MCAN8 = T3.ABAN8 )

) --FIN VIEW LOCALES1   
 

CREATE OR REPLACE VIEW LOCALES AS  (

SELECT 
    T1.*,
    TRIM(T2.NHUNIT)ID_LOCAL,
    TRIM(T2.NHUTTY) TIPO_LOCAL,
    TRIM(T2.NHDL01) COMERCIO,
    TRIM(T2.NHFLOR) PISO,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T2.NHUST = UDC.DRKY   AND 
                              UDC.DRSY  LIKE '15  '  AND 
                              UDC.DRRT   LIKE 'US') ESTATUS_LOCAL
    
FROM
    TECHNOLAB.LOCALES1 T1,
    QADTA.F1507 T2
WHERE
     T1.UNIDAD_NEGOCIO_LC = TRIM(T2.NHMCU)
     
UNION ALL

SELECT 
    T1.*,
    TO_NCHAR('N/A') ID_LOCAL,
    TO_NCHAR('N/A')  TIPO_LOCAL,
    TO_NCHAR('N/A')  COMERCIO,
    TO_NCHAR('N/A')  PISO,
    TO_NCHAR('N/A')  ESTATUS_LOCAL
FROM
    TECHNOLAB.LOCALES1 T1
WHERE
     NOT EXISTS (SELECT * FROM QADTA.F1507 T2 WHERE T1.UNIDAD_NEGOCIO_LC = TRIM(T2.NHMCU))
) --FIN VIEW LOCALES

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- CONTRATOS -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW CONTRATOS1 AS (
SELECT
    T1.NWDOCO ID_CONTRATO,
    CASE LENGTH(T1.NWDOCO)
      WHEN 1 THEN TO_NCHAR(T1.NWDOCO,'00000009')
      WHEN 2 THEN TO_NCHAR(T1.NWDOCO,'00000099')
      WHEN 3 THEN TO_NCHAR(T1.NWDOCO,'00000999')
      WHEN 4 THEN TO_NCHAR(T1.NWDOCO,'00009999')
      WHEN 5 THEN TO_NCHAR(T1.NWDOCO,'00099999')
      WHEN 6 THEN TO_NCHAR(T1.NWDOCO,'00999999')
      WHEN 7 THEN TO_NCHAR(T1.NWDOCO,'09999999')
      WHEN 8 THEN TO_NCHAR(T1.NWDOCO,'99999999')
      ELSE NULL
    END ID_CONTRATO_ALF,
    T1.NWLSVR VERSION_CONTRATO,
    TRIM(T1.NWMCU) UNIDAD_NEGOCIO_CT,
    TRIM( T1.NWUNIT) ID_LOCAL_CT,
    TO_DATE(TO_CHAR(T1.NWMIDT + 1900000),'YYYYDDD') FECHA_INICIO,
    TO_DATE(TO_CHAR(T1.NWSPAD + 1900000),'YYYYDDD') FECHA_FIN,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.NELSET = UDC.DRKY   AND 
                              UDC.DRSY   = '15  '  AND 
                              UDC.DRRT   = 'LT')  TIPO_CONTRATO, 
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T2.NELSST = UDC.DRKY   AND 
                              UDC.DRSY   = '15  '  AND 
                              UDC.DRRT   = 'LS') ESTATUS_CONTRATO,
    TRIM(T2.NECRCD) MONEDA_CT, 
    CASE 
      WHEN T1.NWMODT > 0 THEN (TO_DATE(TO_CHAR(T1.NWMODT + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_RESCINDIDO,
    TRIM(T1.NWRM02) PV,
    (T3.NPPDUE/100) PV_CONTRATO,
    TRIM(T3.NPSUSP) SUSP_CONTRATO,
    CASE 
      WHEN T3.NPSUDT > 0 THEN (TO_DATE(TO_CHAR(T3.NPSUDT + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_SUSPENSION,
    TO_DATE(TO_CHAR(T1.NWCMTB + 1900000),'YYYYDDD') FECHA_COMPROMISO,
    T2.NEAN8 INQUILINO,
    T2.NEAN8J BENEFICIARIO,
    (T1.NWRNTA/1000000000) AREA_ALQUILABLE,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T1.NWUTUS = UDC.DRKY   AND 
                              UDC.DRSY   = '15   '  AND 
                              UDC.DRRT   = 'UU') USO_LOCAL,
    TRIM(T2.NEDL01) NOMBRE_COMERCIAL
FROM 
    QADTA.F15017 T1,
    QADTA.F1501B T2,
    QADTA.F15014B T3
WHERE 
    T1.NWDOCO = T2.NEDOCO
    AND T1.NWLSVR = T2.NELSVR
    AND T1.NWDOCO = T3.NPDOCO
    AND T1.NWLSVR = T3.NPLSVR

UNION ALL

SELECT 

    T1.NWDOCO ID_CONTRATO,
    CASE LENGTH(T1.NWDOCO)
      WHEN 1 THEN TO_NCHAR(T1.NWDOCO,'00000009')
      WHEN 2 THEN TO_NCHAR(T1.NWDOCO,'00000099')
      WHEN 3 THEN TO_NCHAR(T1.NWDOCO,'00000999')
      WHEN 4 THEN TO_NCHAR(T1.NWDOCO,'00009999')
      WHEN 5 THEN TO_NCHAR(T1.NWDOCO,'00099999')
      WHEN 6 THEN TO_NCHAR(T1.NWDOCO,'00999999')
      WHEN 7 THEN TO_NCHAR(T1.NWDOCO,'09999999')
      WHEN 8 THEN TO_NCHAR(T1.NWDOCO,'99999999')
      ELSE NULL
    END ID_CONTRATO_ALF,
    T1.NWLSVR VERSION_CONTRATO,
    TRIM(T1.NWMCU) UNIDAD_NEGOCIO_CT,
    TRIM(T1.NWUNIT) ID_LOCAL_CT,
    TO_DATE(TO_CHAR(T1.NWMIDT + 1900000),'YYYYDDD') FECHA_INICIO,
    TO_DATE(TO_CHAR(T1.NWSPAD + 1900000),'YYYYDDD') FECHA_FIN,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.NELSET = UDC.DRKY   AND 
                              UDC.DRSY   = '15  '  AND 
                              UDC.DRRT   = 'LT')  TIPO_CONTRATO, 
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T2.NELSST = UDC.DRKY   AND 
                              UDC.DRSY   = '15  '  AND 
                              UDC.DRRT   = 'LS') ESTATUS_CONTRATO,
    T2.NECRCD MONEDA_CT, 
    CASE 
      WHEN T1.NWMODT > 0 THEN (TO_DATE(TO_CHAR(T1.NWMODT + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_RESCINDIDO,
    TRIM(T1.NWRM02) PV,
    NULL PV_CONTRATO,
    NULL SUSP_CONTRATO,
    NULL FECHA_SUSPENSION,
    TO_DATE(TO_CHAR(T1.NWCMTB + 1900000),'YYYYDDD') FECHA_COMPROMISO,
    T2.NEAN8 INQUILINO,
    T2.NEAN8J BENEFICIARIO,
    (T1.NWRNTA/1000000000) AREA_ALQUILABLE,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T1.NWUTUS = UDC.DRKY   AND 
                              UDC.DRSY   = '15   '  AND 
                              UDC.DRRT   = 'UU') USO_LOCAL,
    TRIM(T2.NEDL01) NOMBRE_COMERCIAL    
FROM

    QADTA.F15017 T1,
    QADTA.F1501B T2
    
WHERE
    T1.NWDOCO = T2.NEDOCO
    AND T1.NWLSVR = T2.NELSVR
    AND NOT EXISTS (SELECT * FROM QADTA.F15014B T3 WHERE T1.NWDOCO = T3.NPDOCO
    AND T1.NWLSVR = T3.NPLSVR) 
) --FIN VIEW CONTRATOS1


CREATE OR REPLACE VIEW CONTRATOS2 AS (

SELECT T1.*,
      TRIM(T2.NFBLGR) PARAMETRO_UN,
      (T2.NFAG/100) MONTO_BRUTO_CANON_MINIMO,
      T2.NFLNID VERSION_CANON,
      CASE 
              WHEN T2.NFEFTB > 0 THEN (TO_DATE(TO_CHAR(T2.NFEFTB + 1900000),'YYYYDDD'))
              ELSE NULL
      END FECHA_INICIO_FACT,
      CASE 
              WHEN T2.NFEFTE > 0 THEN (TO_DATE(TO_CHAR(T2.NFEFTE + 1900000),'YYYYDDD'))
              ELSE NULL
      END FECHA_FIN_FACT,
      TRIM(T2.NFGLC) COD_FACTURACION,
      TRIM(T2.NFRMK) DESC_FACTURADO
FROM TECHNOLAB.CONTRATOS1 T1,
             QADTA.F1502B T2
WHERE T2.NFDOCO = T1.ID_CONTRATO

UNION ALL

SELECT T1.*,
      NULL PARAMETRO_UN,
      NULL MONTO_BRUTO_CANON_MINIMO,
      NULL VERSION_CANON,
      NULL FECHA_INICIO_FACTURACION,
      NULL FECHA_FIN_FACTURACION,
      NULL COD_FACTURACION,
      NULL DESC_FACTURADO
      FROM TECHNOLAB.CONTRATOS1 T1
WHERE NOT EXISTS (SELECT * FROM QADTA.F1502B T2 WHERE T2.NFDOCO = T1.ID_CONTRATO)
     
) --FIN VIEW CONTRATOS2

CREATE OR REPLACE VIEW CONTRATOS AS (
SELECT T1.* 
FROM TECHNOLAB.CONTRATOS2 T1 
WHERE VERSION_CONTRATO = (SELECT MAX(T2.VERSION_CONTRATO) FROM TECHNOLAB.CONTRATOS2 T2 WHERE T1.ID_CONTRATO = T2.ID_CONTRATO)
AND (T1.VERSION_CANON = (SELECT MAX(T2.VERSION_CANON) FROM TECHNOLAB.CONTRATOS2 T2 WHERE T1.ID_CONTRATO = T2.ID_CONTRATO) OR T1.VERSION_CANON IS NULL)

) --FIN VIEW CONTRATOS2

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- CLIENTES --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW CLIENTES AS (
SELECT 
    T1.ABAN8 ID_CLIENTE,
    TRIM(T1.ABALPH) NOMBRE,
    TRIM(T1.ABTAX) RIF_CEDULA,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '         '||T1.ABTAXC = UDC.DRKY   AND 
                              UDC.DRSY   = 'H00 '  AND 
                              UDC.DRRT   = 'TA') TIPO_CLIENTE,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.ABAT1 = RTRIM(UDC.DRKY)   AND 
                              UDC.DRSY   = '01  '  AND 
                              UDC.DRRT   = 'ST') CATEGORIA_CLIENTE,
    TRIM(T2.AIARC) IDENTIFICADOR_CLIENTE,
    TRIM(T1.ABAC01) FPA
FROM
    QADTA.F0101 T1,
    QADTA.F03012 T2
WHERE
    T2.AIAN8 = T1.ABAN8
) -- FIN VIEW CLIENTES

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- GEOGRAFIA --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW GEOGRAFIA AS (

SELECT 
    T1.ALAN8 ID_DIRECCION,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.ALCTR = UDC.DRKY   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'CN') PAIS,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.ALADDS||' ' =  UDC.DRKY   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'S') ESTADO,
    T1.ALCTY1 CIUDAD,
    ALADD1|| ALADD2 ||ALADD3 || ALADD4 DIRECCION,
    ALADD4 FIN_DIRECCION
FROM 
    QADTA.F0116 T1
) --FIN VIEW GEOGRAFIA

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- GEOGRAFIA --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW GEOGRAFIA_CLIENTE AS (

SELECT 
    T1.ALAN8 ID_DIRECCION_CL,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.ALCTR = UDC.DRKY   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'CN') PAIS_CL,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.ALADDS||' ' =  UDC.DRKY   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'S') ESTADO_CL,
    T1.ALCTY1 CIUDAD_CL,
    ALADD1|| ALADD2 ||ALADD3 || ALADD4 DIRECCION_CL,
    ALADD4 FIN_DIRECCION
FROM 
    QADTA.F0116 T1
) --FIN VIEW GEOGRAFIA_CLIENTE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------- BATCH ----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW BATCHS AS  (
SELECT  NJICU NUM_BATCH, 
                NJDOCO ID_DOCUMENTO, 
                TO_DATE(TO_CHAR(NJDG + 1900000),'YYYYDDD') FECHA_BATCH
                
FROM QADTA.F1511B
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- VENTAS  --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW VENTAS AS(
SELECT 
      NRDOCO ID_CONTRATO_VT,
    CASE LENGTH(NRDOCO)
      WHEN 1 THEN TO_NCHAR(NRDOCO,'00000009')
      WHEN 2 THEN TO_NCHAR(NRDOCO,'00000099')
      WHEN 3 THEN TO_NCHAR(NRDOCO,'00000999')
      WHEN 4 THEN TO_NCHAR(NRDOCO,'00009999')
      WHEN 5 THEN TO_NCHAR(NRDOCO,'00099999')
      WHEN 6 THEN TO_NCHAR(NRDOCO,'00999999')
      WHEN 7 THEN TO_NCHAR(NRDOCO,'09999999')
      WHEN 8 THEN TO_NCHAR(NRDOCO,'99999999')
      ELSE NULL
    END ID_CONTRATO_ALF_VT,
      NRMCU UNIDAD_NEGOCIO_VT,
      NRUNIT ID_LOCAL_VT,
      NRAN8 ID_DIRECCION_VT,
      NRRPRD PERIODO_MES,
      NRYR PERIODO_AÑO,
      NRSOSS ESTATUS_CONTABILIZACION,
      NRSOIC INDICADOR_REG_VENTAS,
      NRPSLS VENTAS_MES,
      NRDCTO TIPO_DOCUMENTO_VT,
      NRICU NUM_BATCH_VT,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||NRICUT = UDC.DRKY   AND 
                              UDC.DRSY   = '98  '  AND 
                              UDC.DRRT   = 'IT') TIPO_BATCH_VT,
      NRDL01 DESCRIPCION,
      NRBCRC MONEDA_VT
FROM
    QADTA.F1540B
    )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------- UNIDAD DE NEGOCIO ---------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW UNIDAD_NEGOCIO AS ( 

SELECT
    TRIM(T2.MCMCU) UNIDAD_NEGOCIO,
    TRIM(T2.MCRP06) CONCENTRADORA,
    TRIM(T1.CCCO) COMPAÑIA_UN,
    T2.MCAN8 ID_DIRECCION_UN,
    TRIM(T1.CCNAME) DESC_COMPAÑIA_UN,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.MCSTYL = UDC.DRKY   AND 
                              UDC.DRSY  LIKE '00  '  AND 
                              UDC.DRRT   LIKE 'MC') TIPO_UNIDAD_NEGOCIO,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T3.ABAC03||  '' = UDC.DRKY   AND 
                              UDC.DRSY   LIKE '01  '  AND 
                              UDC.DRRT   = '03') CATEGORIA_UNIDAD_NEGOCIO,
    TRIM(T2.MDL01C) DESC_UNIDAD_NEGOCIO,
     TRIM(T2.MCTXA1) TASA_FISCAL
FROM
    QADTA.F0010 T1, 
    QADTA.F0006 T2,
    QADTA.F0101 T3
WHERE
    T1.CCCO = T2.MCCO
    AND T2.MCAN8 = T3.ABAN8
    
UNION ALL

SELECT
    TRIM(T2.MCMCU) UNIDAD_NEGOCIO,
    TRIM(T2.MCRP06) CONCENTRADORA_UN,
    TRIM(T1.CCCO) COMPAÑIA_UN,
    T2.MCAN8 ID_DIRECCION_UN,
    TRIM(T1.CCNAME) DES_COMPAÑIA_UN,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '        '||T2.MCSTYL = UDC.DRKY   AND 
                              UDC.DRSY  LIKE '00  '  AND 
                              UDC.DRRT   LIKE 'MC') TIPO_UNIDAD_NEGOCIO,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              UDC.DRKY LIKE '          '   AND 
                              UDC.DRSY   LIKE '01  '  AND 
                              UDC.DRRT   = '03') CATEGORIA_UNIDAD_NEGOCIO,
    TRIM(T2.MCDL01) DESC_UN,
     TRIM(T2.MCTXA1) TASA_FISCAL
FROM
    QADTA.F0010 T1, 
    QADTA.F0006 T2  
WHERE
    T1.CCCO = T2.MCCO
    AND NOT EXISTS (SELECT * FROM QADTA.F0101 T3 WHERE T2.MCAN8 = T3.ABAN8 )

) --FIN VIEW UNIDAD_NEGOCIO    
 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------- COMPAÑIA ---------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW COMPAÑIA AS (
SELECT 
    TRIM(T1.CCCO) COMPAÑIA,
    TRIM(T1.CCNAME) DES_COMPAÑIA
FROM
    QADTA.F0010 T1
) -- FIN VIEW COMPAÑIA

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- CS_DIM_CUENTAS_CONTABLES  ---------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW CUENTAS_CONTABLES AS (
SELECT 
    TRIM(T1.GBAID) ID_CUENTA,
    TRIM(T2.GMDL01) DES_CUENTA,
    TRIM(T1.GBCO) COMPAÑIA,
    TRIM(T1.GBMCU) UN_CUENTA,
    TRIM(T1.GBOBJ) CUENTA_OBJ,
    TRIM(T1.GBSUB) AUXILIAR,
    T1.GBFY AÑO_FISCAL_CC,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC
                          WHERE 
                              '        '||T1.GBLT = UDC.DRKY   AND 
                              UDC.DRSY   = '09  '  AND 
                              UDC.DRRT   = 'LT') TIPO_LIBRO,
    (T1.GBAPYC/100) SALDO_INICIAL,
    (T1.GBAN01/100) SALDO_PERIODO_MES_1,
    (T1.GBAN02/100) SALDO_PERIODO_MES_2,
    (T1.GBAN03/100) SALDO_PERIODO_MES_3,
    (T1.GBAN04/100) SALDO_PERIODO_MES_4,
    (T1.GBAN05/100) SALDO_PERIODO_MES_5,
    (T1.GBAN06/100) SALDO_PERIODO_MES_6,
    (T1.GBAN07/100) SALDO_PERIODO_MES_7,
    (T1.GBAN08/100) SALDO_PERIODO_MES_8,
    (T1.GBAN09/100) SALDO_PERIODO_MES_9,
    (T1.GBAN10/100) SALDO_PERIODO_MES_10,
    (T1.GBAN11/100) SALDO_PERIODO_MES_11,
    (T1.GBAN12/100) SALDO_PERIODO_MES_12,
    (T1.GBAN13/100) SALDO_PERIODO_MES_13,
    (T1.GBAN14/100) SALDO_PERIODO_MES_14
FROM
    QADTA.F0902 T1,
    QADTA.F0901 T2
WHERE
    T2.GMAID = T1.GBAID
)    
    
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- RECIBOS---------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW  RECIBOS AS (
SELECT
    TRIM (T1.RYAID) ID_CUENTA_COBRO,
    TRIM(T2.RZKCO) COMPAÑIA,
    TRIM(T2.RZDCT) TIPO_DOCUMENTO,
    T2.RZDOC ID_DOCUMENTO,
    T2.RZSFX ID_SUFIJO,
    TRIM(T2.RZCKNU) NUMERO_RECIBO,
    T2.RZRC5 LINEA_DOC_COBRO,
    TRIM(T1.RYEXR) OBSERVACIONES_MC,
    T1.RYPYID ID_COBRO, 
    (T1.RYAAP/100) MONTO_APERTURA,
    TRIM(T2.RZPOST) ESTATUS_CONTABILIZACION_COBRO,
    CASE 
      WHEN T2.RZDGJ   > 0 THEN (TO_DATE(TO_CHAR(T2.RZDGJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_LM_COBRO,
    CASE 
      WHEN T2.RZDMTJ   > 0 THEN (TO_DATE(TO_CHAR(T2.RZDMTJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_COBRO,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T2.RZICUT = UDC.DRKY OR '        '||T2.RZICUT||' ' = UDC.DRKY )   AND 
                              UDC.DRSY   = '98  '  AND 
                              UDC.DRRT   = 'IT') TIPO_BATCH_COBRO,
    T2.RZICU NUM_BATCH_COBRO,
    CASE 
      WHEN T2.RZDICJ   > 0 THEN (TO_DATE(TO_CHAR(T2.RZDICJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_BATCH_COBRO,
    TRIM(T2.RZTCRC) MONEDA_MC,
    (T2.RZPAAP/100) MONTO_COBRO,
    (T2.RZTAAJ/100) MONTO_AMORTIZACION,
    (T2.RZADSA/100) MONTO_DESCUENTO
FROM
    QADTA.F03B13 T1,
    QADTA.F03B14 T2

WHERE
             T1.RYPYID = T2.RZPYID
)
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- CS_DIM_MOVIMIENTOS_CONTABLES---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW MOVIMIENTOS_CONTABLES AS (
SELECT 
      TRIM(T1.RPAID) ID_CUENTA_CXC,
    TRIM(T1.RPKCO) COMPAÑIA_MC,    
      TRIM(T1.RPMCU) UNIDAD_NEGOCIO_MC,
   TO_NCHAR(SUBSTR(T1.RPKCO, 3,3)||'00GRAL') UNIDAD_NEGOCIO_CONTABLE_MC,
    T1.RPFY AÑO_FISCAL_MC,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.RPAR02||'  ' = UDC.DRKY   AND 
                              UDC.DRSY   = '01  '  AND 
                              UDC.DRRT   = '02') NATURALEZA,
    T1.RPDOC ID_DOCUMENTO_MC, 
    TRIM(T1.RPSFX) ITEM_DOCUMENTO_MC,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPDCT = UDC.DRKY OR '        '||T1.RPDCT||' ' = UDC.DRKY)   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'DT')TIPO_DOCUMENTO_MC,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPEXR1 = UDC.DRKY  OR '        '||T1.RPEXR1||' ' = UDC.DRKY) AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'EX') COD_EXPLICACION_FISCAL,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                                '       '||T1.RPAR04 = UDC.DRKY   AND 
                              UDC.DRSY   = '01  '  AND 
                              UDC.DRRT   = '04') CONCEPTO_FACTURACION,
    TRIM(T1.RPRMK) DESCRIPCION_CXC,
    TRIM(T1.RPPO) ID_CONTRATO_MC, 
    T1.RPAN8 ID_CLIENTE_MC, 
    (T1.RPAG/100) IMPORTE_BRUTO,
    (T1.RPAAP/100) IMPORTE_PENDIENTE,
    T1.RPPN PERIODO,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPICUT = UDC.DRKY OR '        '||T1.RPICUT||' ' = UDC.DRKY )   AND 
                              UDC.DRSY   = '98  '  AND 
                              UDC.DRRT   = 'IT') TIPO_BATCH_CXC,
    T1.RPICU NUM_BATCH_CXC,
    CASE 
      WHEN T1.RPDICJ   > 0 THEN (TO_DATE(TO_CHAR(T1.RPDICJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_BATCH_CXC,
    TRIM(T1.RPPOST) STATUS_CONTABILIZACION_CXC,
    TRIM(T3.ABAC01) FPA,
    CASE 
      WHEN T1.RPDIVJ  > 0 THEN (TO_DATE(TO_CHAR(T1.RPDIVJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_FACTURA,
    CASE 
      WHEN T1.RPDGJ  > 0 THEN (TO_DATE(TO_CHAR(T1.RPDGJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_LM_CXC,
    CASE 
      WHEN T1.RPJCL > 0 THEN (TO_DATE(TO_CHAR(T1.RPJCL + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_CIERRE_CXC,
    T2.TIPO_BATCH_COBRO,
    T2.NUM_BATCH_COBRO,
    T2.FECHA_BATCH_COBRO,
    T2.ID_CUENTA_COBRO,
    T2.FECHA_LM_COBRO,
    T2.ESTATUS_CONTABILIZACION_COBRO,
    T2.NUMERO_RECIBO,
    T2.LINEA_DOC_COBRO,
    T2.OBSERVACIONES_MC,
    T2.ID_COBRO, 
    T2.MONTO_APERTURA,
    T2.MONEDA_MC,
    T2.MONTO_COBRO,
    T2.MONTO_AMORTIZACION,
    T2.MONTO_DESCUENTO
FROM 
    QADTA.F03B11 T1,
    TECHNOLAB.RECIBOS T2,
    QADTA.F0101 T3
 WHERE  TRIM(T1.RPKCO) = T2.COMPAÑIA
    AND TRIM(T1.RPDCT) = T2.TIPO_DOCUMENTO
    AND T1.RPDOC = T2.ID_DOCUMENTO
    AND (T1.RPSFX) = T2.ID_SUFIJO
    AND T1.RPAN8 = T3.ABAN8
    
UNION ALL

SELECT 
    TRIM(T1.RPAID) ID_CUENTA_CXC, 
    TRIM(T1.RPKCO) COMPAÑIA_MC, 
    TRIM(T1.RPMCU) UNIDAD_NEGOCIO_MC,
   TO_NCHAR(SUBSTR(T1.RPKCO, 3,3)||'00GRAL') UNIDAD_NEGOCIO_MC_CONTABLE,
    T1.RPFY AÑO_FISCAL_MC,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.RPAR02||'  ' = UDC.DRKY   AND 
                              UDC.DRSY   = '01  '  AND 
                              UDC.DRRT   = '02') NATURALEZA,
    T1.RPDOC ID_DOCUMENTO, 
    TRIM(T1.RPSFX) ITEM_DOCUMENTO,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPDCT = UDC.DRKY OR '        '||T1.RPDCT||' ' = UDC.DRKY)   AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'DT')TIPO_DOCUMENTO,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPEXR1 = UDC.DRKY  OR '        '||T1.RPEXR1||' ' = UDC.DRKY) AND 
                              UDC.DRSY   = '00  '  AND 
                              UDC.DRRT   = 'EX') COD_EXPLICACION_FISCAL,
     (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              '       '||T1.RPAR04 = UDC.DRKY   AND 
                              UDC.DRSY   = '01  '  AND 
                              UDC.DRRT   = '04') CONCEPTO_FACTURACION,
    TRIM(T1.RPRMK) DESCRIPCION_CXC,
    TRIM(T1.RPPO) ID_CONTRATO_MC, 
    T1.RPAN8 ID_CLIENTE_MC, 
   (T1.RPAG/100) IMPORTE_BRUTO,
    (T1.RPAAP/100) IMPORTE_PENDIENTE,
    T1.RPPN PERIODO,
    (SELECT 
                    TRIM(UDC.DRDL01)     
                          FROM   
                              QACTL.F0005 UDC 
                          WHERE 
                              ('        '||T1.RPICUT = UDC.DRKY OR '        '||T1.RPICUT||' ' = UDC.DRKY )   AND 
                              UDC.DRSY   = '98  '  AND 
                              UDC.DRRT   = 'IT') TIPO_BATCH_CXC,
    T1.RPICU NUM_BATCH_CXC,
    CASE 
      WHEN T1.RPDICJ   > 0 THEN (TO_DATE(TO_CHAR(T1.RPDICJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_BATCH_CXC,
    TRIM(T1.RPPOST) STATUS_CONTABILIZACION_CXC,
    TRIM(T2.ABAC01) FPA,
    CASE 
      WHEN T1.RPDIVJ  > 0 THEN (TO_DATE(TO_CHAR(T1.RPDIVJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_FACTURA,
    CASE 
      WHEN T1.RPDGJ  > 0 THEN (TO_DATE(TO_CHAR(T1.RPDGJ  + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_LM_CXC,
    CASE 
      WHEN T1.RPJCL > 0 THEN (TO_DATE(TO_CHAR(T1.RPJCL + 1900000),'YYYYDDD'))
      ELSE NULL
    END FECHA_CIERRE_CXC,
    NULL TIPO_BATCH_COBRO,
    NULL NUMERO_BATCH_COBRO,
    NULL FECHA_BATCH_COBRO,
    NULL ID_CUENTA_COBRO,
    NULL FECHA_LM_COBRO,
    NULL ESTATUS_CONTABILIZACION_COBRO,
    NULL NUMERO_RECIBO,
    NULL LINEA_DOC_COBRO,
    NULL OBSERVACIONES_MC,
    NULL ID_COBRO, 
    NULL MONTO_APERTURA,
    NULL MONEDA,
    NULL MONTO_COBRO,
    NULL MONTO_AMORTIZACION,
    NULL MONTO_DESCUENTO
FROM 
    QADTA.F03B11 T1,
    QADTA.F0101 T2    
 WHERE  
 NOT EXISTS (SELECT * 
                      FROM  TECHNOLAB.RECIBOS T2 
                      WHERE T1.RPKCO = T2.COMPAÑIA
                      AND T1.RPDCT = T2.TIPO_DOCUMENTO
                      AND T1.RPDOC = T2.ID_DOCUMENTO
                      AND (T1.RPSFX) = T2.ID_SUFIJO)
    AND T1.RPAN8 = T2.ABAN8
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- HECHO --------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW HECHO AS 
  (
SELECT T1.ID_CUENTA_CXC ID_CUENTA,
              T1.COMPAÑIA_MC COMPAÑIA, 
              T1.UNIDAD_NEGOCIO_MC UNIDAD_NEGOCIO,
              T1.AÑO_FISCAL_MC AÑO_FISCAL,
              T1.ID_CLIENTE_MC ID_CLIENTE, 
              T1.IMPORTE_BRUTO,
              T1.IMPORTE_PENDIENTE,
              T1.MONTO_APERTURA,
              T1.MONTO_COBRO,
              T1.MONTO_AMORTIZACION,
              T1.MONTO_DESCUENTO,
              T1.ID_CONTRATO_MC ID_CONTRATO,
              T2.ID_DIRECCION_UN ID_DIRECCION
FROM MOVIMIENTOS_CONTABLES T1,
UNIDAD_NEGOCIO T2
WHERE T1.UNIDAD_NEGOCIO_MC = T2.UNIDAD_NEGOCIO
)
