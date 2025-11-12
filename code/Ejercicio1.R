## --- 
# Universidad de los Andes
# Taller 2 - Economía Urbana
# Grupo 1 - Santiago Melo - Sara Torres - Corina Hernández
# ---

rm(list = ls())
require("pacman") #pacman facilita la carga e instalaci?n simult?nea de librer?as

p_load(
  tidyverse,
  modeldata,
  stargazer,
  broom,
  fixest,
  dplyr,
  summarytools,
  DataExplorer,
  rio,
  osmdata,
  sf,
  SpatialKDE,
  tmap,
  gridExtra,
  evmix,
  units,
  skimr,
  tmap
)

setwd("C:/Users/samel/OneDrive/Datos adjuntos/Universidad de los Andes/V/Economía Urbana/Talleres/Taller 2/T2_EU_SMSTCH_EJ1")
data_ej1 <- load("data/Taller2_Ejercicio1.Rdata")

## ---- RECREAR FIGURA 1 ----

# Base ----

# Estandarizamos el nombre de la llave (para unir)
barrios <- barrios %>% 
  rename(zona180 = ZONA180)

# Calculamos el número de restaurantes por barrio
restaurants <- restaurants %>% 
  mutate(
    rest_2004 = if_else(
      (ethnic2004 == 1 | michelin2004 == 1 | sitdown2004 == 1 |
         (!is.na(lat2004) & !is.na(long2004))),
      1, 0
    ),
    rest_2012 = if_else(
      (ethnic2012 == 1 | michelin2012 == 1 | sitdown2012 == 1 |
         (!is.na(lat2012) & !is.na(long2012))),
      1, 0
    )
  )

restaurants_barrio <- restaurants %>% 
  filter(!(is.na(rest_2004) & is.na(rest_2012)))

restaurants_barrio <- restaurants_barrio %>% 
  group_by(zona180) %>% 
  summarise(
    total_rest_2004 = sum(rest_2004, na.rm = TRUE),
    total_rest_2012 = sum(rest_2012, na.rm = TRUE)
  )

# Join con base de población
datos_milan <- barrios %>%
  left_join(poblacion, by = "zona180") %>% 
  left_join(restaurants_barrio, by = "zona180")

# Calculamos el número de restaurantes per cápita
datos_milan <- datos_milan %>% 
  mutate(
    percapita_2004 = (total_rest_2004 / day_pop)*1000,
    percapita_2012 = (total_rest_2012 / day_pop)*1000
  )

# Calculamos el promedio per cápita de la ciudad
prom_milan_2004 <- mean(datos_milan$percapita_2004, na.rm = TRUE)
prom_milan_2012 <- mean(datos_milan$percapita_2012, na.rm = TRUE)

datos_milan <- datos_milan %>% 
  mutate(
    diff_city_2004 = percapita_2004 - prom_milan_2004,
    diff_city_2012 = percapita_2012 - prom_milan_2012
  )

# --- Mapas - Número de restaurantes per cápita  ----
breaks_fixed <- seq(-4, 14, by = 2)
labels_fixed <- c("-4 a -2", "-2 a 0", "0 a 2", "2 a 4", "4 a 6", "6 a 8", "8 a 10", "10 a 12", "12 a 14")
tmap_mode("plot")
tmap_options(component.autoscale = FALSE)

# --- Mapa 2004 ---
mapa_diff_2004 <- tm_shape(datos_milan) +
  tm_polygons(
    col = "diff_city_2004",
    palette = "OrRd",
    breaks = breaks_fixed,
    labels = labels_fixed,
    title = "",
    colorNA = "grey90",
    border.col = "grey40",
    lwd = 0.5,
    showNA = FALSE
  ) +
  tm_layout(
    main.title = "Número per cápita de restaurantes en 2004",
    legend.show = FALSE,
    frame = FALSE
  )

# --- Mapa 2012 ---
mapa_diff_2012 <- tm_shape(datos_milan) +
  tm_polygons(
    col = "diff_city_2012",
    palette = "OrRd",
    breaks = breaks_fixed,
    labels = labels_fixed,
    title = "",
    colorNA = "grey90",
    border.col = "grey40",
    lwd = 0.5,
    showNA = FALSE
  ) +
  tm_layout(
    main.title = "Número per cápita de restaurantes en 2012",
    legend.show = FALSE,  # también ocultamos la leyenda
    frame = FALSE
  )

# --- Crear leyenda compartida ---
leyenda_compartida <- tm_shape(datos_milan) +
  tm_polygons(
    col = "diff_city_2012",
    palette = "OrRd",
    breaks = breaks_fixed,
    labels = labels_fixed,
    title = "",
    colorNA = "grey90",
    showNA = FALSE
  ) +
  tm_layout(legend.only = TRUE, legend.text.size = 0.8)

# --- Mostrar ambos mapas con leyenda común ---
tmap_arrange(
  mapa_diff_2004,
  mapa_diff_2012,
  leyenda_compartida,
  ncol = 3,
  widths = c(1, 1, 0.4) # ajusta la proporción de ancho de la leyenda
)

# --- Crecimiento en porcentaje de los restaurantes per cápita ----
datos_milan <- datos_milan %>% 
  mutate(
    cambio_pc_2004_2012 = (percapita_2012 - percapita_2004)/percapita_2004
  )

# --- Mapa cambio 2004 - 2012 ---
mapa_cambio_2004_2012 <- tm_shape(datos_milan) +
  tm_polygons(
    col = "cambio_pc_2004_2012",
    palette = "Blues",
    title = "",
    breaks = c(-0.6, -0.3, -0.2, 0, 0.2, 0.3, 0.6),
    colorNA = "grey90",
    border.col = "grey40",
    lwd = 0.5,
    showNA = FALSE
  ) +
  tm_layout(
    main.title = "Cambio porcentual del número per cápita de restaurantes",
    legend.outside = TRUE,
    legend.text.size = 0.8,
    frame = FALSE
  )

# Mostrar el mapa
mapa_cambio_2004_2012


# ----

## ---- DISTRIBUCIÓN DE PRECIOS ----
# Eliminamos los NA de precio en ambos años
prezzo_2004 <- na.omit(restaurants$prezzo2004)
prezzo_2012 <- na.omit(restaurants$prezzo2012)

# Ancho de banda (rule of thumb)
# Gaussian Kernel: 1.059σn^(-1/5)
# Epanechnikov Kernel: 1.06 A/n^(1/5), donde A = min(s, IQR/1.34)
gauss_kernel_h <- 0.8
epanechnikov_kernel_h <- 0.9

# Densidades kernel para 2004
dens_gauss_2004 <- density(prezzo_2004, bw = gauss_kernel_h, kernel = "gaussian",
                           from = min(prezzo_2004) - 1, to = max(prezzo_2004) + 1, n = 1024)
dens_epan_2004  <- density(prezzo_2004, bw = epanechnikov_kernel_h, kernel = "epanechnikov",
                           from = min(prezzo_2004) - 1, to = max(prezzo_2004) + 1, n = 1024)

# Densidades kernel para 2012
dens_gauss_2012 <- density(prezzo_2012, bw = gauss_kernel_h, kernel = "gaussian",
                           from = min(prezzo_2012) - 1, to = max(prezzo_2012) + 1, n = 1024)
dens_epan_2012  <- density(prezzo_2012, bw = epanechnikov_kernel_h, kernel = "epanechnikov",
                           from = min(prezzo_2012) - 1, to = max(prezzo_2012) + 1, n = 1024)

# Gráfico comparativo
par(mfrow = c(1, 2))

# Panel 1: Año 2004
plot(dens_gauss_2004, lwd = 2, col = "blue",
     main = "Distribución precios (2004)",
     xlab = "Precio", ylab = "Densidad")
lines(dens_epan_2004, lwd = 2, col = "red", lty = 2)
legend("topright", legend = c("Gaussiano", "Epanechnikov"),
       col = c("blue", "red"), lwd = 2, lty = c(1, 2), bty = "n")

# Panel 2: Año 2012
plot(dens_gauss_2012, lwd = 2, col = "blue",
     main = "Distribución precios (2012)",
     xlab = "Precio", ylab = "Densidad")
lines(dens_epan_2012, lwd = 2, col = "red", lty = 2)
legend("topright", legend = c("Gaussiano", "Epanechnikov"),
       col = c("blue", "red"), lwd = 2, lty = c(1, 2), bty = "n")

