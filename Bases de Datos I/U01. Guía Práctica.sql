USE LIBRERIA_2026_BDI

-- UNIDAD 01 -- 

-- Consultas Sumarias (o agregadas) ------------------------------------------

-- X) Cuántos clientes hay, cuántos tienen teléfonos conocidos
-- y cuántos tienen mail conocido

SELECT * FROM clientes

SELECT COUNT(*) AS 'Cantidad de Clientes',
	COUNT(nro_tel) AS 'Cantidad de Clientes con Teléfonos Conocido',
	COUNT([e-mail]) AS 'Cantidad de Clientes con E-mail Conocidos'
FROM clientes

-- X) ¿A cuántos clientes les facturamos en el 2020?

SELECT COUNT(DISTINCT cod_cliente)
FROM facturas
WHERE YEAR(fecha) = 2020

-- X) Monto total facturado en el 2020, promedio de facturación

SELECT SUM(pre_unitario * cantidad) AS 'Total Facturado',
	AVG(pre_unitario * cantidad) AS 'Promedio por Detalle Factura',
	SUM(pre_unitario * cantidad) / COUNT(DISTINCT F.nro_factura) AS 'Promedio por Factura'
FROM detalle_facturas AS DF	
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
WHERE YEAR(F.fecha) = 2020

-- X) Facturación total anual

SELECT YEAR(fecha) AS 'Año',
	SUM(pre_unitario * cantidad) AS 'Total Facturado'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
GROUP BY YEAR(fecha)
ORDER BY 1

-- Problema 1.1: Consultas Sumarias ------------------------------------------

-- 7. Se quiere saber la cantidad de ventas que hizo el vendedor de código 3. 

SELECT COUNT(*) AS 'Cantidad de Ventas del Vendedor de Código 3'
FROM facturas
WHERE cod_vendedor = 3

-- 8. ¿Cuál fue la fecha de la primera y última venta que se realizó en este negocio?

SELECT MIN(fecha) AS 'Primera Fecha',
	MAX(fecha) AS 'Última Fecha'
FROM facturas

-- 9. Mostrar la siguiente información respecto a la factura nro.: 450:
-- cantidad total de unidades vendidas, la cantidad de artículos
-- diferentes vendidos y el importe total. 

SELECT SUM(cantidad) AS 'Cantidad Total de Unidades Vendidas',
	COUNT(DISTINCT cod_articulo) AS 'Cantidad de Artículos Diferentes Vendidos',
	SUM(pre_unitario * cantidad) AS 'Importe Total'
FROM detalle_facturas
WHERE nro_factura = 450

-- 10. ¿Cuál fue la cantidad total de unidades vendidas, importe total
-- y el importe promedio para vendedores cuyos nombres comienzan
-- con letras que van de la “d” a la “l”? 

SELECT SUM(DF.cantidad) AS 'Cantidad Total de Unidades Vendidas',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Importe Promedio'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
WHERE nom_vendedor LIKE '[D-L]%'

-- 11. Se quiere saber el importe total vendido, el promedio del importe
-- vendido y la cantidad total de artículos vendidos para el cliente Roque Paez. 

SELECT 'Roque Paez' AS 'Cliente',
	SUM(pre_unitario * cantidad) AS 'Importe Total Vendido',
	AVG(pre_unitario * cantidad) AS 'Promedio del Importe Vendido',
	SUM(cantidad) AS 'Cantidad Total de Artículos Vendidos'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE (C.nom_cliente + ' ' + C.ape_cliente) LIKE 'Roque Paez'
	OR C.nom_cliente = 'Roque' AND C.ape_cliente = 'Paez'

-- 12. Mostrar la fecha de la primera venta, la cantidad total vendida
-- y el importe total vendido para los artículos que empiecen con “C”.

SELECT --MIN(fecha) AS 'Primera Venta',
	FORMAT(MIN(fecha), 'MM - MMMM - yyyy', 'es-ES') AS 'Mes',
	SUM(DF.cantidad) AS 'Cantidad Total Vendida',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total Vendido'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN articulos AS A
		ON DF.cod_articulo = A.cod_articulo
WHERE A.descripcion LIKE 'C%'

-- 13. Se quiere saber la cantidad total de artículos vendidos y el
-- importe total vendido para el periodo del 15/06/2011 al 15/06/2017.

SELECT SUM(DF.cantidad) AS 'Cantidad Total de Artículos Vendidos',
	SUM(pre_unitario * cantidad) AS 'Importe Total'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
WHERE --F.fecha BETWEEN '2011-06-15' AND '2017-06-15'
	F.fecha BETWEEN '20110615' AND '20170615' -- mejor poner en este formato, funciona siempre (YYYYMMDD)
	OR DATEDIFF(YEAR, 2011-06-14, 2017-06-15) = 6

-- 14. Se quiere saber la cantidad de veces y la última vez que vino
-- el cliente de apellido Abarca y cuánto gastó en total.

SELECT COUNT(DISTINCT F.nro_factura) AS 'Total de Visitas',
	MAX(F.fecha) AS 'Última Visita',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Gasto Total'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE C.ape_cliente = 'Abarca'

-- 15. Mostrar el importe total y el promedio del importe para los clientes
-- cuya dirección de mail es conocida.

SELECT C.cod_cliente AS 'Código',
	C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente', 
	SUM(DF.pre_unitario * cantidad) AS 'Importe Total',
	AVG(DF.pre_unitario * cantidad) AS 'Promedio del Importe'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE [e-mail] IS NOT NULL
GROUP BY C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente

-- 16. Obtener la siguiente información: el importe total vendido y el importe
-- promedio vendido para números de factura que no sean los siguientes: 13,
-- 5, 17, 33, 24.

SELECT F.nro_factura AS 'Factura',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total Vendido',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio Vendido'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
WHERE F.nro_factura NOT IN (13, 5, 17, 33, 24)
GROUP BY F.nro_factura

-- Consultas agrupadas: Cláusula GROUP BY ------------------------------------

-- X. Listar la facturacción mensual de los últimos 2 años (este y el anterior)
-- siempre que el promedio de la factura por mes sea mayor a 50.000

SELECT YEAR(F.fecha) AS 'Año',
	MONTH(F.fecha) AS 'Mes',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Facturación'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE YEAR(F.fecha) = YEAR(GETDATE()) -1
	OR YEAR(F.fecha) = YEAR(GETDATE())
GROUP BY MONTH(F.fecha), YEAR(F.fecha)
HAVING AVG(DF.pre_unitario * DF.cantidad) > 50000
ORDER BY 2, 1

-- Problema 1.2: Consultas agrupadas: Cláusula GROUP BY ----------------------

-- 2. Por cada factura emitida mostrar la cantidad total de artículos vendidos
-- (suma de las cantidades vendidas), la cantidad ítems que tiene cada factura
-- en el detalle (cantidad de registros de detalles) y el Importe total de la
-- facturación de este año.

-- TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR

SELECT F.nro_factura AS 'Factura',
	SUM(DF.cantidad) AS 'Cantidad Total de Artículos Vendidos',
	COUNT(*) AS 'Cantidad de Registros de Detalles'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
GROUP BY F.nro_factura

SELECT * FROM detalle_facturas WHERE nro_factura = 1

-- TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR TERMINAR

-- 3. Se quiere saber en este negocio, cuánto se factura:
-- a. Diariamente
-- b. Mensualmente
-- c. Anualmente

SELECT DAY(F.fecha) AS 'Día',
	MONTH(F.fecha) AS 'Mes',
	YEAR(F.fecha) AS 'Año',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Facturación'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
GROUP BY DAY(F.fecha), MONTH(F.fecha), YEAR(F.fecha)

SELECT DAY(F.fecha) AS 'Día',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Facturación'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
GROUP BY DAY(F.fecha)
ORDER BY 1

SELECT YEAR(F.fecha) AS 'Año',
	MONTH(F.fecha) AS 'Mes',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Facturación'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
GROUP BY YEAR(F.fecha), MONTH(F.fecha)
ORDER BY 1, 2

SELECT YEAR(F.fecha) AS 'Año',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Facturación'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
GROUP BY YEAR(F.fecha)
ORDER BY 1

-- 4. Emitir un listado de la cantidad de facturas confeccionadas diariamente,
-- correspondiente a los meses que no sean enero, julio ni diciembre. Ordene
-- por la cantidad de facturas en forma descendente y fecha.

SELECT fecha AS 'Fecha',
	COUNT(*) AS 'Cantidad de Facturas'
FROM facturas
WHERE MONTH(fecha) NOT IN (1, 7, 12)
GROUP BY fecha
ORDER BY 2 DESC, 1 DESC

-- 5. Se quiere saber la cantidad y el importe promedio vendido por fecha y
-- cliente, para códigos de vendedor superiores a 2. Ordene por fecha y
-- cliente.

SELECT F.fecha AS 'Fecha',
	C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	SUM(DF.cantidad) AS 'Cantidad',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio Vendido'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE F.cod_vendedor > 2
GROUP BY F.fecha, C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
ORDER BY 1, 2

-- 6. Se quiere saber el importe promedio vendido y la cantidad total
-- vendida por fecha y artículo, para códigos de cliente inferior a 3.
-- Ordene por fecha y artículo.

SELECT F.fecha AS 'Fecha',
	A.descripcion AS 'Artículo',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio',
	SUM(DF.cantidad) AS 'Cantidad Total Vendida'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN articulos AS A
		ON DF.cod_articulo = A.cod_articulo
WHERE F.cod_cliente < 3
GROUP BY F.fecha, A.cod_articulo, A.descripcion
ORDER BY 1, 2

-- 7. Listar la cantidad total vendida, el importe total vendido y el importe
-- promedio total vendido por número de factura, siempre que la fecha no
-- oscile entre el 13/2/2007 y el 13/7/2010.

SELECT F.nro_factura AS 'Factura',
	SUM(DF.cantidad) AS 'Cantidad Total Vendida',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total Vendido',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio Total Vendido'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE fecha NOT BETWEEN '2007-02-13' AND '2010-07-13'
GROUP BY F.nro_factura

-- 8. Emitir un reporte que muestre la fecha de la primer y última venta y el
-- importe comprado por cliente. Rotule como CLIENTE, PRIMER VENTA,
-- ÚLTIMA VENTA, IMPORTE.

SELECT C.ape_cliente + ' ' + C.nom_cliente AS 'CLIENTE',
	MIN(F.fecha) AS 'PRIMER VENTA',
	MAX(F.fecha) AS 'ÚLTIMA VENTA',
	SUM(DF.pre_unitario * DF.cantidad) AS 'IMPORTE'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
GROUP BY C.cod_cliente, .ape_cliente + ' ' + C.nom_cliente

-- 9. Se quiere saber el importe total vendido, la cantidad total vendida y el precio
-- unitario promedio por cliente y artículo, siempre que el nombre del cliente
-- comience con letras que van de la “a” a la “m”. Ordene por cliente, precio
-- unitario promedio en forma descendente y artículo. Rotule como IMPORTE
-- TOTAL, CANTIDAD TOTAL, PRECIO PROMEDIO.

SELECT C.ape_cliente + ' ' + C.nom_cliente AS 'CLIENTE',
	A.descripcion AS 'ARTÍCULO',
	SUM(DF.pre_unitario * DF.cantidad) AS 'IMPORTE TOTAL',
	SUM(DF.cantidad) AS 'CANTIDAD TOTAL',
	AVG(DF.pre_unitario) AS 'PRECIO PROMEDIO'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
	JOIN articulos AS A
		ON DF.cod_articulo = A.cod_articulo
WHERE C.nom_cliente LIKE '[a-m]%'
GROUP BY C.cod_cliente,
	C.ape_cliente + ' ' + C.nom_cliente,
	A.cod_articulo,
	A.descripcion
ORDER BY C.ape_cliente + ' ' + C.nom_cliente,
	AVG(DF.pre_unitario) DESC,
	A.descripcion

-- 10. Se quiere saber la cantidad de facturas y la fecha la primer y última factura
-- por vendedor y cliente, para números de factura que oscilan entre 5 y 30.
-- Ordene por vendedor, cantidad de ventas en forma descendente y cliente.

SELECT V.ape_vendedor + ' ' + V.nom_vendedor AS 'Vendedor',
	C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	COUNT(*) AS 'Cantidad de Facturas',
	MIN(F.fecha) AS 'Primera Factura',
	MAX(F.fecha) AS 'Última Factura'
FROM facturas AS F
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
WHERE F.nro_factura BETWEEN 5 AND 30
GROUP BY V.cod_vendedor,
	V.ape_vendedor + ' ' + V.nom_vendedor,
	C.cod_cliente,
	C.ape_cliente + ' ' + C.nom_cliente
ORDER BY 1, 3 DESC, 2

-- Problema 1.3: Consultas agrupadas: Cláusula HAVING ------------------------

-- 3. Se quiere saber la fecha de la primera venta, la cantidad total vendida y el
-- importe total vendido por vendedor para los casos en que el promedio de
-- la cantidad vendida sea inferior o igual a 56.

SELECT V.ape_vendedor + ' ' + V.nom_vendedor AS 'Vendedor',
	MIN(F.fecha) AS 'Primera venta',
	SUM(DF.cantidad) AS 'Cantidad Total Vendida',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total Vendido'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
GROUP BY V.cod_vendedor, V.ape_vendedor + ' ' + V.nom_vendedor
HAVING AVG(DF.cantidad) <= 56

-- 4. Se necesita un listado que informe sobre el monto máximo, mínimo y total
-- que gastó en esta librería cada cliente el año pasado, pero solo donde el
-- importe total gastado por esos clientes esté entre 300 y 800.

SELECT C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	MAX(DF.pre_unitario * DF.cantidad) AS 'Monto Máximo',
	MIN(DF.pre_unitario * DF.cantidad) AS 'Monto Mínimo',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Monto Total'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE YEAR(F.fecha) = YEAR(GETDATE()) -1
GROUP BY C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
HAVING SUM(DF.pre_unitario * DF.cantidad) BETWEEN 300 AND 800
ORDER BY 2

-- 5. Muestre la cantidad facturas diarias por vendedor; para los casos en que
-- esa cantidad sea 2 o más.

SELECT DAY(F.fecha) AS 'Día',
	V.ape_vendedor + ' ' + V.nom_vendedor AS 'Vendedor',
	COUNT(*) 'Cantidad Facturas Diarias'
FROM facturas AS F
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
GROUP BY V.cod_vendedor, V.ape_vendedor + ' ' + V.nom_vendedor, DAY(F.fecha)
HAVING COUNT(*) >= 2

-- 6. Desde la administración se solicita un reporte que muestre el precio
-- promedio, el importe total y el promedio del importe vendido por artículo
-- que no comiencen con “c”, que su cantidad total vendida sea 100 o más o
-- que ese importe total vendido sea superior a 700.

SELECT A.descripcion AS 'Artículo',
	AVG(DF.pre_unitario) AS 'Precio Promedio',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio Importe Vendido por Artículo'
FROM detalle_facturas AS DF
	JOIN articulos AS A
		ON DF.cod_articulo = A.cod_articulo
WHERE A.descripcion NOT LIKE 'C%'
GROUP BY A.cod_articulo, A.descripcion
HAVING SUM(DF.cantidad) >= 100
	OR SUM(DF.pre_unitario * DF.cantidad) > 700
ORDER BY 1

-- 7. Muestre en un listado la cantidad total de artículos vendidos, el importe
-- total y la fecha de la primer y última venta por cada cliente, para lo
-- números de factura que no sean los siguientes: 2, 12, 20, 17, 30 y que el
-- promedio de la cantidad vendida oscile entre 2 y 6. 

SELECT C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	SUM(DF.cantidad) AS 'Cantidad Total de Artículos Vendidos',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total',
	MIN(F.fecha) AS 'Primer Venta',
	MAX(F.fecha) AS 'Última Venta'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE F.nro_factura NOT IN (2, 12, 20, 17, 30)
GROUP BY C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
HAVING AVG(DF.cantidad) BETWEEN 2 AND 6

-- 8. Emitir un listado que muestre la cantidad total de artículos vendidos, el
-- importe total vendido y el promedio del importe vendido por vendedor y
-- por cliente; para los casos en que el importe total vendido esté entre 200
-- y 600 y para códigos de cliente que oscilen entre 1 y 5.

SELECT V.ape_vendedor + ' ' +  V.nom_vendedor AS 'Vendedor',
	C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	SUM(DF.cantidad) AS 'Cantidad Total de Artículos Vendidos',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total Vendido',
	AVG(DF.pre_unitario * DF.cantidad) AS 'Promedio del Importe Vendido'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE C.cod_cliente BETWEEN 1 AND 5
GROUP BY V.cod_vendedor, V.ape_vendedor + ' ' +  V.nom_vendedor,
	C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
HAVING SUM(DF.pre_unitario * DF.cantidad) BETWEEN 200 AND 600

-- 9. ¿Cuáles son los vendedores cuyo promedio de facturación el mes pasado
-- supera los $ 800?

SELECT V.cod_vendedor AS 'Código',
	V.ape_vendedor + ' ' + V.nom_vendedor AS 'Vendedor',
	SUM(DF.pre_unitario * DF.cantidad) / COUNT(DISTINCT F.nro_factura) AS 'Promedio de Facturación'
FROM vendedores AS V
	JOIN facturas AS F
		ON V.cod_vendedor = F.cod_vendedor
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE DATEDIFF(MONTH, F.fecha, GETDATE()) = 1
GROUP BY V.cod_vendedor, V.ape_vendedor + ' ' + V.nom_vendedor
HAVING AVG(DF.pre_unitario * DF.cantidad) > 800
ORDER BY 3

-- 10.¿Cuánto le vendió cada vendedor a cada cliente el año pasado siempre
-- que la cantidad de facturas emitidas (por cada vendedor a cada cliente)
-- sea menor a 5?

SELECT V.ape_vendedor + ' ' + V.nom_vendedor AS 'Vendedor',
	C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
	SUM(DF.pre_unitario * DF.cantidad) AS 'Importe'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN vendedores AS V
		ON F.cod_vendedor = V.cod_vendedor
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
WHERE YEAR(F.fecha) = YEAR(GETDATE()) - 1
GROUP BY V.cod_vendedor, V.ape_vendedor + ' ' + V.nom_vendedor,
	C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
HAVING COUNT(DISTINCT F.nro_factura) < 5

-- Combinación de resultados de consulta. UNION ------------------------------

-- X) Se quiere ver la facturación del 2020 y en el mismo listado, pero en la última
-- fila el total facturado

SELECT STR(DF.nro_factura) AS 'Número de Factura',
	(pre_unitario * cantidad) AS 'SubTotal'
FROM detalle_facturas AS DF
	JOIN facturas AS F
		ON DF.nro_factura = F.nro_factura
WHERE YEAR(F.fecha) = 2020

UNION

SELECT 'Total',
	SUM(pre_unitario * cantidad)
FROM detalle_facturas

-- Problema 1.4: Combinación de resultados de consultas. UNION ---------------

-- 2. Se quiere saber qué vendedores y clientes hay en la empresa; para los casos en
-- que su teléfono y dirección de e-mail sean conocidos. Se deberá visualizar el
-- código, nombre y si se trata de un cliente o de un vendedor. Ordene por la columna
-- tercera y segunda.

SELECT cod_vendedor AS 'Código',
	ape_vendedor + ' ' + nom_vendedor AS 'Nombre',
	'Vendedor' AS 'V o C'
FROM vendedores

UNION

SELECT cod_cliente,
	ape_cliente + ' ' + nom_cliente AS 'Nombre',
	'Cliente'
FROM clientes
ORDER BY 3, 1

-- 3. Emitir un listado donde se muestren qué artículos, clientes y vendedores hay en
-- la empresa. Determine los campos a mostrar y su ordenamiento.

SELECT 'Artículo' AS 'Descripción',
	cod_articulo AS 'Código',
	descripcion AS 'Nombre'
FROM articulos

UNION

SELECT 'Cliente',
	cod_cliente,
	ape_cliente + ' ' + nom_cliente
FROM clientes

UNION

SELECT 'Vendedor',
	cod_vendedor,
	ape_vendedor + ' ' + nom_vendedor
FROM vendedores

ORDER BY 1, 2

-- 4. Se quiere saber las direcciones (incluido el barrio) tanto de clientes como de 
-- vendedores. Para el caso de los vendedores, códigos entre 3 y 12. En ambos casos 
-- las direcciones deberán ser conocidas. Rotule como NOMBRE, DIRECCION, 
-- BARRIO, INTEGRANTE (en donde indicará si es cliente o vendedor). Ordenado por 
-- la primera y la última columna.

SELECT C.cod_cliente AS 'CÓDIGO',
	ape_cliente + ' ' + nom_cliente AS 'NOMBRE',
	calle + ' ' + TRIM(STR(altura)) AS 'DIRECCIÓN',
	B.barrio AS 'BARRIO',
	'Cliente' AS 'INTEGRANTE'
FROM clientes AS C
	JOIN barrios AS B
		ON B.cod_barrio = C.cod_barrio
WHERE calle IS NOT NULL AND altura IS NOT NULL and barrio IS NOT NULL

UNION

SELECT V.cod_vendedor AS 'CÓDIGO',
	ape_vendedor + ' ' + nom_vendedor AS 'NOMBRE',
	calle + ' ' + TRIM(STR(altura)) AS 'DIRECCIÓN',
	B.barrio AS 'BARRIO',
	'Vendedor' AS 'INTEGRANTE'
FROM vendedores AS V
	JOIN barrios AS B
		ON B.cod_barrio = V.cod_barrio
WHERE cod_vendedor BETWEEN 3 AND 12
	AND calle IS NOT NULL AND altura IS NOT NULL and barrio IS NOT NULL

ORDER BY 1, 4

-- 6. Listar todos los artículos que están a la venta cuyo precio unitario oscile
-- entre 10 y 50; también se quieren listar los artículos que fueron comprados por
-- los clientes cuyos apellidos comiencen con “M” o con “P”.

SELECT descripcion AS 'Artículo',
	pre_unitario AS 'Precio Unitario'
FROM articulos
WHERE pre_unitario BETWEEN 10 AND 50

UNION

SELECT A.descripcion,
	A.pre_unitario
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
	JOIN clientes AS C
		ON F.cod_cliente = C.cod_cliente
	JOIN articulos AS A
		ON A.cod_articulo = DF.cod_articulo
WHERE C.ape_cliente LIKE '[M, P]%'

-- 7. El encargado del negocio quiere saber cuánto fue la facturación del año pasado.
-- Por otro lado, cuánto es la facturación del mes pasado, la de este mes y la de hoy
-- (Cada pedido en una consulta distinta, y puede unirla en una sola tabla de resultado)

SELECT * FROM facturas, detalle_facturas

SELECT 'Año Pasado' AS 'Período',
	SUM(pre_unitario * cantidad) AS 'Total Facturado'
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE YEAR(fecha) = YEAR(getdate()) - 1

UNION

SELECT 'Mes Pasado',
	SUM(pre_unitario * cantidad)
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE DATEDIFF(MONTH, fecha, GETDATE())	= 1

-- no uso month(fecha) = month(getdate)) - 1
-- porque si estoy en enero daría 0 y no hay mes 0

UNION

SELECT 'Este Mes',
	SUM(pre_unitario * cantidad)
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE DATEDIFF(MONTH, fecha, GETDATE())	= 0

UNION

SELECT 'Hoy',
	SUM(pre_unitario * cantidad)
FROM facturas AS F
	JOIN detalle_facturas AS DF
		ON F.nro_factura = DF.nro_factura
WHERE DATEDIFF(DAY, fecha, GETDATE()) = 0

-- Vistas --------------------------------------------------------------------

-- X. Cree una vista que muestre el importe total gastado por cliente este año, además
-- cantidad de facturas y primer y última fecha de factura.

CREATE VIEW VW_facturacion_por_cliente
AS
	SELECT C.cod_cliente,
		C.ape_cliente + ' ' + C.nom_cliente AS 'Cliente',
		SUM(DF.pre_unitario * DF.cantidad) AS 'Importe Total',
		COUNT(DISTINCT F.nro_factura) AS 'Cantidad de Facturas',
		MIN(F.fecha) AS 'Primer Fecha',
		MAX(F.fecha) AS 'Última Fecha'
FROM clientes AS C
	JOIN facturas AS F
		ON C.cod_cliente = F.cod_cliente
	JOIN detalle_facturas AS DF
		ON DF.nro_factura = DF.nro_factura
WHERE YEAR(F.fecha) = YEAR(GETDATE())
GROUP BY C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente

SELECT * FROM VW_facturacion_por_cliente
ORDER BY Cliente

-- Consulte la vista anterior mostrando código, ape y nom del cliente, y el importe
-- total siempre que la cantidad de facturas sea menor a 2

SELECT cod_cliente,
	Cliente,
	[Importe Total]
FROM VW_facturacion_por_cliente
WHERE [Cantidad de Facturas] < 7

-- Problema 1.5: Vistas ------------------------------------------------------

-- 2. Cree una vista que liste la fecha, la factura, el código y nombre
-- del vendedor, el artículo, la cantidad e importe, para lo que va del año.
-- Rotule como FECHA, NRO_FACTURA, CODIGO_VENDEDOR, NOMBRE_VENDEDOR,
-- ARTICULO, CANTIDAD, IMPORTE. 

CREATE VIEW VW_Ejercicio_2
AS
	SELECT F.fecha AS 'FECHA',
		F.nro_factura AS 'NRO_FACTURA',
		V.cod_vendedor AS 'CODIGO_VENDEDOR',
		V.ape_vendedor + ' ' + V.nom_vendedor AS 'NOMBRE_VENDEDOR',
		A.descripcion AS 'ARTICULO',
		DF.cantidad AS 'CANTIDAD',
		(DF.pre_unitario * DF.cantidad) AS 'IMPORTE'
FROM facturas AS F
		JOIN detalle_facturas AS DF
			ON F.nro_factura = DF.nro_factura
		JOIN vendedores AS V
			ON F.cod_vendedor = V.cod_vendedor
		JOIN articulos AS A
			ON DF.cod_articulo = A.cod_articulo
WHERE YEAR(F.fecha) = YEAR(GETDATE())

SELECT * FROM VW_Ejercicio_2

-- Detalle de la IA:
-- El enunciado te pide listar "el artículo, la cantidad e importe".
-- Es decir, quiere ver el detalle fila por fila (renglón por renglón)
-- de lo que se vendió en cada factura, no un subtotal acumulado.

-- 3. Modifique la vista creada en el punto anterior, agréguele la condición
-- de que solo tome el mes pasado (mes anterior al actual) y que también
-- muestre la dirección del vendedor.

ALTER VIEW VW_Ejercicio_2
AS
	SELECT F.fecha AS 'FECHA',
		F.nro_factura AS 'NRO_FACTURA',
		V.cod_vendedor AS 'CODIGO_VENDEDOR',
		V.ape_vendedor + ' ' + V.nom_vendedor AS 'NOMBRE_VENDEDOR',
		V.calle + ' ' + LTRIM(STR(V.altura)) AS 'Dirección',
		A.descripcion AS 'ARTICULO',
		DF.cantidad AS 'CANTIDAD',
		(DF.pre_unitario * DF.cantidad) AS 'IMPORTE'
FROM facturas AS F
		JOIN detalle_facturas AS DF
			ON F.nro_factura = DF.nro_factura
		JOIN vendedores AS V
			ON F.cod_vendedor = V.cod_vendedor
		JOIN articulos AS A
			ON DF.cod_articulo = A.cod_articulo
WHERE YEAR(F.fecha) = YEAR(GETDATE())
	AND MONTH(F.fecha) = MONTH(GETDATE()) - 1

SELECT * FROM VW_Ejercicio_2

-- 4. Consulta las vistas según el siguiente detalle: 
--		a. Llame a la vista creada en el punto anterior
--		pero filtrando por importes inferiores a $120.
--		b. Llame a la vista creada en el punto anterior
--		filtrando para el vendedor Miranda.
--		c. Llama a la vista creada en el punto 4
--		filtrando para los importes menores a 10.000.

-- a.
SELECT *
FROM VW_Ejercicio_2
WHERE IMPORTE < 120
-- da 0 resultados

-- b.
SELECT *
FROM VW_Ejercicio_2
WHERE NOMBRE_VENDEDOR LIKE 'Miranda%'
-- da 16 resultados

-- c.
SELECT *
FROM VW_Ejercicio_2
WHERE IMPORTE < 10000 
-- da 7 resultados

-- 5. Elimine las vistas creadas en el punto 3.

DROP VIEW VW_Ejercicio_2

SELECT * FROM VW_Ejercicio_2