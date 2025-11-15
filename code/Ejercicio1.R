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
    legend.show = FALSE,
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
tmap_save(tmap_arrange(
  mapa_diff_2004,
  mapa_diff_2012,
  leyenda_compartida,
  ncol = 3,
  widths = c(1, 1, 0.4) # ajusta la proporción de ancho de la leyenda
),
filename = "export/mapa_restaurantes_pc_2004_2012.png",
width = 3000, 
height = 1200,
dpi = 300
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
    main.title = "Cambio porcentual del número per cápita de restaurantes\n 2004 vs. 2012",
    main.title.position = "center",
    legend.outside = TRUE,
    legend.text.size = 0.8,
    frame = FALSE
  )

# Mostrar el mapa
tmap_save(
  tm = mapa_cambio_2004_2012,
  filename = "export/mapa_cambio_2004_2012.png",
  width = 2100,
  height = 1600,
  dpi = 300
)


# ----

## ---- DISTRIBUCIÓN DE PRECIOS ----
# Eliminamos los NA de precio en ambos años
prezzo_2004 <- na.omit(restaurants$prezzo2004)
prezzo_2012 <- na.omit(restaurants$prezzo2012)

## --- Distribución precios Gaussiano y Epanechnikov ----
# Ancho de banda - Silverman's Rule of Thumb
# 1.059σn^(-1/5)
# 0.9 An^(1/5), donde A = min(s, IQR/1.34)

# Creamos una función para obtener los anchos de banda para ambos métodos
ancho_banda_srf <- function(x){
  x <- na.omit(x)
  n <- length(x)
  s <- sd(x)
  A <- min(s, IQR(x) / 1.34)
  
  h_sigma <- 1.059 * s * n^(-1/5) # Versión clásica
  h_A <- 0.9 * A * n^(-1/5) # Versión robusta
  
  list(
    bw_sigma = h_sigma,
    bw_robust = h_A
  )
}

bw_2004 <- ancho_banda_srf(prezzo_2004)
bw_2012 <- ancho_banda_srf(prezzo_2012)

c(bw_2004, bw_2012)

# Densidades kernel para 2004
dens_gauss_2004 <- density(prezzo_2004, 
                           bw = bw_2004$bw_sigma, 
                           kernel = "gaussian",
                           from = min(prezzo_2004) - 1,
                           to = max(prezzo_2004) + 1,
                           n = 1024)

dens_epan_2004  <- density(prezzo_2004, 
                           bw = bw_2004$bw_sigma, 
                           kernel = "epanechnikov",
                           from = min(prezzo_2004) - 1,
                           to = max(prezzo_2004) + 1,
                           n = 1024)

# Densidades kernel para 2012
dens_gauss_2012 <- density(prezzo_2004, 
                           bw = bw_2012$bw_sigma, 
                           kernel = "gaussian",
                           from = min(prezzo_2004) - 1,
                           to = max(prezzo_2004) + 1,
                           n = 1024)

dens_epan_2012  <- density(prezzo_2004, 
                           bw = bw_2012$bw_sigma, 
                           kernel = "epanechnikov",
                           from = min(prezzo_2004) - 1,
                           to = max(prezzo_2004) + 1,
                           n = 1024)

# Gráfica de distribución
# Calculamos el valor máximo de las densidades
# png("export/epan_vs_gauss_bandas.png", width = 1800, height = 800)

# par(mfrow = c(1, 2))  # <-- 1 fila, 2 columnas (lado a lado)

ymax <- max(
  dens_gauss_2004$y,
  dens_epan_2004$y,
  dens_gauss_2012$y,
  dens_epan_2012$y
)
yticks <- seq(0, ymax, by = 0.005)

par(mfrow = c(1, 2))
# Panel 1: Año 2004
plot(dens_gauss_2004, lwd = 2, col = "blue",
     main = "Distribución precios (2004)",
     xlab = "Precio", ylab = "Densidad",
     ylim = c(0, ymax),
     yaxt = "n")  # quitamos eje Y automático
axis(2, at = yticks, las = 1)  # eje Y manual cada 0.005

lines(dens_epan_2004, lwd = 2, col = "red", lty = 2)
legend("topright", legend = c("Gaussiano", "Epanechnikov"),
       col = c("blue", "red"), lwd = 2, lty = c(1, 2), bty = "n")


# Panel 2: Año 2012
plot(dens_gauss_2012, lwd = 2, col = "blue",
     main = "Distribución precios (2012)",
     xlab = "Precio", ylab = "Densidad",
     ylim = c(0, ymax),
     yaxt = "n")
axis(2, at = yticks, las = 1)

lines(dens_epan_2012, lwd = 2, col = "red", lty = 2)
legend("topright", legend = c("Gaussiano", "Epanechnikov"),
       col = c("blue", "red"), lwd = 2, lty = c(1, 2), bty = "n")

# dev.off()

## --- Distribución precios Epanechnikov con distintos anchos de banda ----

# Año 2004
bw_2004_sigma = bw_2004$bw_sigma
bw_2004_sigma_mitad <- bw_2004$bw_sigma / 2
bw_2004_sigma_doble <- 2*(bw_2004$bw_sigma)

dens_epan_2004_sigma <- density(prezzo_2004, 
                           bw = bw_2004_sigma, 
                           kernel = "epanechnikov",
                           from = min(prezzo_2004) - 1,
                           to = max(prezzo_2004) + 1,
                           n = 1024)

dens_epan_2004_sigma_mitad <- density(prezzo_2004, 
                                 bw = bw_2004_sigma_mitad, 
                                 kernel = "epanechnikov",
                                 from = min(prezzo_2004) - 1,
                                 to = max(prezzo_2004) + 1,
                                 n = 1024)

dens_epan_2004_sigma_doble <- density(prezzo_2004, 
                                 bw = bw_2004_sigma_doble, 
                                 kernel = "epanechnikov",
                                 from = min(prezzo_2004) - 1,
                                 to = max(prezzo_2004) + 1,
                                 n = 1024)

# Año 2012
bw_2012_sigma = bw_2012$bw_sigma
bw_2012_sigma_mitad <- bw_2012$bw_sigma / 2
bw_2012_sigma_doble <- 2*(bw_2012$bw_sigma)

dens_epan_2012_sigma <- density(prezzo_2012, 
                                bw = bw_2012_sigma, 
                                kernel = "epanechnikov",
                                from = min(prezzo_2012) - 1,
                                to = max(prezzo_2012) + 1,
                                n = 1024)

dens_epan_2012_sigma_mitad <- density(prezzo_2012, 
                                      bw = bw_2012_sigma_mitad, 
                                      kernel = "epanechnikov",
                                      from = min(prezzo_2012) - 1,
                                      to = max(prezzo_2012) + 1,
                                      n = 1024)

dens_epan_2012_sigma_doble <- density(prezzo_2012, 
                                      bw = bw_2012_sigma_doble, 
                                      kernel = "epanechnikov",
                                      from = min(prezzo_2012) - 1,
                                      to = max(prezzo_2012) + 1,
                                      n = 1024)

# png("export/epan_2004_2012_distintas_bandas.png", width = 1800, height = 800)

# par(mfrow = c(1, 2))  # <-- 1 fila, 2 columnas (lado a lado)

# Gráfica 2004
ymax_epan_2004 <- max(dens_epan_2004_sigma$y,
                      dens_epan_2004_sigma_mitad$y,
                      dens_epan_2004_sigma_doble$y)

yticks_epan_2004 <- pretty(c(0, ymax_epan_2004))


plot(dens_epan_2004_sigma, lwd = 3, col = "blue",
     main = "Distribución precios (2004)",
     xlab = "Precio", ylab = "Densidad",
     ylim = c(0, ymax_epan_2004),
     yaxt = "n")

axis(2, at = yticks_epan_2004, las = 1)

lines(dens_epan_2004_sigma_doble, lwd = 3, col = "red", lty = 3)
lines(dens_epan_2004_sigma_mitad, lwd = 3, col = "green", lty = 3)

legend("topright", legend = c("bw", "bw doble", "bw mitad"),
       col = c("blue", "red", "green"),
       lwd = 3, lty = c(1, 3), bty = "n")

# Gráfica 2012
ymax_epan_2012 <- max(dens_epan_2012_sigma$y,
                 dens_epan_2012_sigma_mitad$y,
                 dens_epan_2012_sigma_doble$y)

yticks_epan_2012 <- pretty(c(0, ymax_epan_2012))


plot(dens_epan_2012_sigma, lwd = 3, col = "blue",
     main = "Distribución precios (2012)",
     xlab = "Precio", ylab = "Densidad",
     ylim = c(0, ymax_epan_2012),
     yaxt = "n")

axis(2, at = yticks_epan_2012, las = 1)

lines(dens_epan_2012_sigma_doble, lwd = 3, col = "red", lty = 3)
lines(dens_epan_2012_sigma_mitad, lwd = 3, col = "green", lty = 3)

legend("topright", legend = c("bw", "bw doble", "bw mitad"),
       col = c("blue", "red", "green"),
       lwd = 3, lty = c(1, 3), bty = "n")

# dev.off()

# ----

## ---- TEST DURANTON Y OVERMAN ----
# Filtramos los 5 barrios que mayor crecimiento tuvieron en el número de restaurantes per cápita
barrios_top5 <- datos_milan %>% 
  arrange(desc(cambio_pc_2004_2012)) %>% 
  slice_head(n = 5) %>% 
  dplyr::select(zona180, cambio_pc_2004_2012)

# Trabajamos con la base de restaurants que solo tenga estos barrios
# Eliminamos todos los restaurantes que no tengan ubicaciones exactas
restaurants_top5 <- restaurants %>% 
  filter(zona180 %in% barrios_top5$zona180) %>% 
  filter(!is.na(lat2012) & !is.na(long2012))

# Convertimos a points, ST = 32632 específico para Milán
restaurants_pt <- st_as_sf(
  restaurants_top5,
  coords = c("long2012", "lat2012"),
  crs = 4326) %>% 
  st_transform(32632)

# Configuración para el test DO
from_val <- 0
to_val <- 1
n_points <- 60

# Distancias observadas
bilat_distances_mat <- st_distance(restaurants_pt)
bilat_distances_mat[lower.tri(bilat_distances_mat, diag = TRUE)] <- NA

bilat_vec <- c(bilat_distances_mat)
bilat_vec <- bilat_vec[!is.na(bilat_vec)]
units(bilat_vec) <- make_units(km)

bilat_km <- as.numeric(bilat_vec)

# Limitamos las distancias a 1 km
bilat_km <- bilat_km[bilat_km <= 1]

# Densidad observada
dens_obs_epan <- density(
  bilat_km, 
  bw = "nrd",
  kernel = "epanechnikov",
  from = from_val, to = to_val, n = n_points
)

# Simulaciones aleatorias: generamos puntos aleatorios
top5_poly <- st_transform(barrios_top5, 32632)

set.seed(123)
n_sim      <- 500
boot_points <- list()
for(i in 1:n_sim){
  boot_points[[i]] <- st_sample(top5_poly, size = nrow(restaurants_pt), type = "random")
}

# Calculamos vector de densidad de las distancias bilaterales
density_calculator_epan <- function(sample_pts){
  dmat <- st_distance(sample_pts)
  dmat[lower.tri(dmat, diag = TRUE)] <- NA
  dvec <- c(dmat)
  dvec <- dvec[!is.na(dvec)]
  units(dvec) <- make_units(km)
  dvec_km <- as.numeric(dvec)
  dvec_km <- dvec_km[dvec_km <= 1]
  dens <- density(
    dvec_km, bw = "nrd", kernel = "epanechnikov",
    from = from_val, to = to_val, n = n_points
  )
  dens$y
}

# Aplicamos la función a cada simulación y convertimos a matriz
boot_dens_list <- lapply(boot_points, density_calculator_epan)
boot_dens_mat  <- do.call(cbind, boot_dens_list)

# Calculamos percentiles 5 y 95 para cada punto de la malla
q05_epan <- apply(boot_dens_mat, 1, function(x) quantile(x, probs = 0.05))
q95_epan <- apply(boot_dens_mat, 1, function(x) quantile(x, probs = 0.95))

# Construimos data.frame para graficar 
rest_test <- data.frame(
  locations = dens_obs_epan$x,
  observada = dens_obs_epan$y,
  q05 = q05_epan,
  q95 = q95_epan
)

# Gráfica de densidad observada vs bandas aleatorias
library(ggplot2)
plot_test_epan <- ggplot(rest_test) +
  geom_line(aes(x = locations, y = observada), size = 1) +
  geom_line(aes(x = locations, y = q05), linetype = "dashed") +
  geom_line(aes(x = locations, y = q95), linetype = "dashed") +
  theme_bw() +
  labs(x = "Distancia (km)",
       y = "Densidad (estimada)",
       title = "Test de Duranton & Overman (Kernel Epanechnikov)") +
  theme(plot.title = element_text(hjust = 0.5))

plot_test_epan
ggsave("export/test_DO.png", plot = plot_test_epan, width = 9, height = 6)
