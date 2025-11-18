# T2_EU_SMSTCH_EJ1 

## Taller 2 - Economía Urbana - Ejercicio 1  

###### 

### Santiago Melo, Corina Hernández, Sara Torres  

---

## 📂 Estructura del repositorio T2_EU_SMSTCH_EJ1 

El repositorio está organizado en las siguientes carpetas:

### 🧠 `code/`
Contiene el código en **R** con todas las rutinas empleadas en el ejercicio:
- Limpieza y preparación de datos.  
- Especificación y estimación de los modelos.  
- Generación de tablas y gráficas de resultados.

### 🗂️ `data/`
Incluye la base de datos utilizada en el análisis, con información de transacciones inmobiliarias, características estructurales y variables de control.

### 📈 `export/`
Almacena los productos finales del ejercicio:
- Gráficas de evolución de precios.  
- Tablas resumen de resultados econométricos.  

---

## ⚙️ Desarrollo del ejercicio 1

El trabajo se estructuró en tres etapas principales:

1. **Preparación y limpieza de datos** 🧹  
   Se realizó una descripción del conjunto de datos, eliminando observaciones con valores faltantes (*NA*) y seleccionando las variables de control relevantes para las regresiones.

2. **Estimación de modelos** 📉  
   Se implementaron tres enfoques de modelación del precio de la vivienda:  
   - Modelo **Hedónico simple**.  
   - Modelo **Hedónico con efectos fijos y clúster a nivel de propiedad**.  
   - Modelo **de Ventas Repetidas** (*Repeat Sales*).  

3. **Comparación de resultados** 🔍  
   Se compararon los modelos en términos de número de observaciones, poder explicativo y comportamiento temporal del índice de precios, evaluando la coherencia entre metodologías.

---
