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
restaurantes_per_capita = (total_restaurantes / población_diurna) * 1000
diff_city = percapita_barrio – percapita_promedio_ciudad

3. **Comparación de resultados** 🔍  
   Se compararon los modelos en términos de número de observaciones, poder explicativo y comportamiento temporal del índice de precios, evaluando la coherencia entre metodologías.

---
