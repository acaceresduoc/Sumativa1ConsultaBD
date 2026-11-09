/* ============================================================
   PRY2205 - Semana 3: Aplicando funciones de agrupacion
   Consultas construidas a partir del esquema PRY2205_S3
   ============================================================ */

/* CASO 1: ANALISIS DE PROPIEDADES
   En SQL Developer, ingrese el gasto comun total minimo solicitado. */
   
SELECT
    UPPER(tp.desc_tipo_propiedad) AS "TIPO PROPIEDAD",
    COUNT(p.nro_propiedad) AS "CANTIDAD PROPIEDADES",
    TO_CHAR(ROUND(MAX(p.valor_arriendo)), 'FM999G999G999G990') AS "VALOR MAXIMO ARRIENDO",
    TO_CHAR(ROUND(MIN(p.valor_arriendo)), 'FM999G999G999G990') AS "VALOR MINIMO ARRIENDO",
    TO_CHAR(ROUND(AVG(p.valor_arriendo)), 'FM999G999G999G990') AS "PROMEDIO ARRIENDO",
    CASE
        WHEN MAX(p.valor_arriendo) > 1000000 THEN 'PREMIUM'
        ELSE 'ESTANDAR'
    END AS "CLASIFICACION",
    TO_CHAR(ROUND(SUM(NVL(p.valor_gasto_comun, 0))), 'FM999G999G999G990')
        AS "TOTAL GASTO COMUN"
FROM propiedad p
JOIN tipo_propiedad tp
    ON tp.id_tipo_propiedad = p.id_tipo_propiedad
GROUP BY tp.desc_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;

/* CASO 2: ANTIGUEDAD DE EMPLEADOS
   Ingrese el codigo de la sucursal que se debe excluir. */

SELECT
    UPPER(e.nombre_emp || ' ' || e.apaterno_emp || ' ' || e.apmaterno_emp)
        AS "NOMBRE EMPLEADO",
    TO_CHAR(ROUND(e.sueldo_emp), 'FM999G999G999G990') AS "SUELDO",
    CASE
        WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "NIVEL SUELDO",
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) AS "ANOS SERVICIO",
    TO_CHAR(
        ROUND(e.sueldo_emp *
            CASE
                WHEN MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12 > 5
                 AND MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12 <= 10 THEN 0.05
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 11 AND 20 THEN 0.10
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     > 20 THEN 0.15
            END),
        'FM999G999G999G990'
    ) AS "BONO ANTIGUEDAD"
FROM empleado e
WHERE e.id_categoria_emp = 3
  AND e.id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12 > 5
ORDER BY e.sueldo_emp DESC;

/* CASO 3: LISTA DE CLIENTES
   El modelo define FONOFIJO_CLI como NOT NULL. Por ello, si se
   consideran telefono fijo o celular, todos los clientes tienen
   telefono y el resultado sera "Clientes con Telefono". */

SELECT
    datos.clasificacion AS "CLASIFICACION RENTA",
    COUNT(*) AS "CANTIDAD CLIENTES",
    CASE
        WHEN MAX(datos.tiene_telefono) = 1 THEN 'Clientes con Telefono'
        ELSE 'Clientes sin Telefono'
    END AS "ESTADO TELEFONO"
FROM (
    SELECT
        CASE
            WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
            WHEN c.renta_cli >= 600000 THEN 'ALTA'
            WHEN c.renta_cli >= 300000 THEN 'MEDIA'
            ELSE 'BAJA'
        END AS clasificacion,
        CASE
            WHEN c.fonofijo_cli IS NOT NULL OR c.celular_cli IS NOT NULL THEN 1
            ELSE 0
        END AS tiene_telefono
    FROM cliente c
    WHERE c.renta_cli > 200000
) datos
GROUP BY datos.clasificacion
HAVING COUNT(*) > 0
ORDER BY CASE datos.clasificacion
    WHEN 'PREMIUM' THEN 1
    WHEN 'ALTA' THEN 2
    WHEN 'MEDIA' THEN 3
    WHEN 'BAJA' THEN 4
END;



