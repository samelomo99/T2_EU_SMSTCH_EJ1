# T2_EU_SMSTCH_EJ1 

## Taller 2 - Economía Urbana - Ejercicio 1  

###### 

### Santiago Melo, Corina Hernández, Sara Torres  

---

## 📂 Estructura del repositorio T2_EU_SMSTCH_EJ1 

El repositorio está organizado en las siguientes carpetas:

### 🧠 `code/`
Contiene el código en **R** con todas las rutinas empleadas en el ejercicio:
- Limpieza y preparación de las bases de barrios, población y restaurantes.  
- Construcción del indicador restaurantes per cápita en 2004 y 2012.
- Generación de mapas comparativos por barrio.
- Estimación de distribuciones de precios (KDE).
- Implementación del test de Duranton & Overman (2005).

### 🗂️ `data/`
Incluye la base de datos de los restaurantes de Milán para 2004 y 2012:
- Polígonos de los barrios de Milán (geometry, zona180).
- Población diurna y nocturna por barrio (day_pop, nite_pop).
- Restaurantes con coordenadas y categorías en 2004 y 2012 (ethnic, michelin, sitdown, lat, long, prezzo).

### 📈 `export/`
Almacena los productos finales del ejercicio:
- Mapas de restaurantes per cápita (2004 y 2012).
- Mapa del cambio porcentual 2004–2012.
- Densidades Kernel (Gaussian y Epanechnikov).
- Comparaciones de bandas de ancho de banda.
- Test de Duranton & Overman para 2004 y 2012.

---

## ⚙️ Desarrollo del ejercicio 1

Este ejercicio analiza la evolución espacial de los restaurantes en la ciudad de Milán, combinando datos de barrios, población y establecimientos para estudiar patrones de concentración, cambios per cápita y evidencia de aglomeración económica. Se desarrollo en las siguientes etapas:

1. **Preparación y limpieza de datos** 🧹  
- Se estandarizó la llave zona180 entre las bases de barrios, población y restaurantes.
- La existencia de un restaurante en 2004 o 2012 se definió de manera amplia:
  - Al menos una categoría activa (ethnic, michelin, sitdown), o
  - Coordenadas disponibles (lat, long) para el año correspondiente.
- Se eliminaron filas sin ubicación geográfica válida.
- Los restaurantes se agregaron por barrio para ambos años.
- La base final combina:
barrios + población + conteo de restaurantes por año.

2. **Construcción del indicador per cápita** 📉  
Para cada barrio se calculó:
<img width="316" height="55" alt="image" src="https://github.com/user-attachments/assets/98201313-f4e8-4c2f-9939-b4fc9c69fa7c" />
Y luego se restó el promedio de la ciudad, lo que permite ver qué barrios están por encima o por debajo del promedio de Milán.

3. **Mapas comparativos 2004 - 2012** 🔍  
- Se utilizaron breaks fijos de −4, 14 cada 2 unidades.
- Se construyó una leyenda compartida para ambos años.
- Los resultados muestran que:
  - En 2004 los barrios centrales tienen valores per cápita relativamente altos.
  - Entre 2004 y 2012 la oferta per cápita crece especialmente en la periferia nor-oriental.

4. **Distribución de precios: KDE** 🔍
Se realizó la estimación no paramétrica usando Kernel Gaussiano y Epanechnikov
- El ancho de banda se calculó con **Silverman Rule of Thumb** en dos versiones:
<img width="463" height="95" alt="image" src="https://github.com/user-attachments/assets/ba80704f-ccb8-49a0-94d9-0bf8924b0bf0" />

Se construyeron:
- Gráficas Gauss vs. Epanechnikov
- Gráficas con bw, bw/2 y 2bw
- Paneles separando 2004 y 2012 con misma escala
 
5. **Test de Duranton y Overman** 🔍  
- Se replicó el test para 2004 y 2012, usando los 5 barrios con mayor crecimiento per cápita.

**Proceso**
- Se calculan todas las distancias bilaterales entre restaurantes.
- Se limita el análisis a 0–1 km, asumiendo que la competencia es local.
- Se estima una densidad Kernel Epanechnikov.
- Se generan simulaciones aleatorias (500) ubicando restaurantes de forma uniforme dentro de los 5 barrios.
- Se construyen bandas del 5% y 95%.
- Se compara la curva observada con el rango aleatorio.

**Resultados**
- En ambos años, especialmente en 2012, la curva observada está por encima del rango aleatorio en distancias cortas (< 0.3 km). Esto evidencia aglomeración espacial de restaurantes.
---
