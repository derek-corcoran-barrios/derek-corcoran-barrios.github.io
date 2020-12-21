library(gstat)
library(sp)
library(rgdal)

library(raster)
library(rworldxtra)
library(sf)
library(tidyverse)

data(meuse)

## Transformar a SF

Meuse <- meuse %>% st_as_sf(coords = c(1,2), crs = "+init=epsg:28992")

ggplot() + 
  geom_sf(data = Meuse, aes(color = zinc)) + 
  scale_color_viridis_c()

coordinates(meuse) <- ~x + y

proj4string(meuse) <- CRS("+init=epsg:28992")

Z_vgm_null <- variogram(log(zinc) ~ 1 , data = meuse) %>% mutate(Modelo = "Nulo")

Z_vgm_spatial <- variogram(log(zinc) ~ x + y, data = meuse) %>% mutate(Modelo = "Espacial")

Z_vgm_dist <- variogram(log(zinc) ~  dist.m, data = meuse) %>% mutate(Modelo = "Distancia")

Z_vgm_Dist_sq <- variogram(log(zinc) ~ sqrt(dist), meuse) %>% 
  mutate(Modelo = "sqrt(dist)")

## Todos los modelos juntos
Z_vgm <- rbind(Z_vgm_null, Z_vgm_spatial, Z_vgm_dist, Z_vgm_Dist_sq)


ggplot(Z_vgm, aes(x = dist, y = gamma, color = Modelo)) + 
  geom_path() + 
  geom_point() +
  theme_bw()

Abn_fit_espacial <- fit.variogram(Z_vgm_spatial, model = vgm(0.5, "Sph", 900, 1))

ggplot(Z_vgm_spatial, aes(x = dist, y = gamma, color = Modelo)) + 
  geom_point() +
  geom_hline(yintercept = 0.08234213 + 0.38866509, lty = 2) + 
  geom_vline(xintercept = 1098.571, lty = 2) + 
  theme_bw()




### Ajuste de modelo de Variograma para todos los modelos anteriores
  
  Abn_fit_null <- fit.variogram(Z_vgm_null, model = vgm(1, "Sph", 
                                                        700, 1))
  Abn_fit_Spat <- fit.variogram(Z_vgm_spatial, model = vgm(1, "Sph", 
                                                        700, 1))
  Abn_fit_Dist <- fit.variogram(Z_vgm_dist, model = vgm(1, "Sph", 
                                                        700, 1))
  Abn_fit_Dist_sq <- fit.variogram(Z_vgm_Dist_sq, model = vgm(1, 
                                                              "Sph", 700, 1))
## Meuse grid
  
data(meuse.grid)
coordinates(meuse.grid) <- ~ x + y
proj4string(meuse.grid) <- CRS("+init=epsg:28992")

Meuse_grid_SF <- st_as_sf(meuse.grid,coords = c(1,2), crs = "+init=epsg:28992")  


ggplot() + geom_sf(data = Meuse_grid_SF, aes(color = dist))

## Hacemos prediccion con krigging

Spat_pred <- krige(log(zinc) ~ x + y, meuse, meuse.grid, model = Abn_fit_Spat) %>% st_as_sf()

ggplot() + 
  geom_sf(data = Spat_pred, aes(color = exp(var1.pred))) + 
  scale_color_viridis_c(name= "Concentración zinc") + 
  theme_bw()


ggplot() + 
  geom_sf(data = Spat_pred, aes(color = var1.var)) + 
  scale_color_viridis_c() + 
  theme_bw()
  

## HAcemos predicciones

Null_pred <- krige(log(zinc) ~ 1, Meuse, Meuse_grid_SF, model = Abn_fit_null) %>% 
  mutate(Modelo = "Nulo")

Spat_pred <- krige(log(zinc) ~ x + y, meuse, meuse.grid, model = Abn_fit_Spat) %>% 
  st_as_sf(crs = "+init=epsg:28992") %>% 
  mutate(Modelo = "Espacial")

Dist_pred <- krige(log(zinc) ~ dist, Meuse, Meuse_grid_SF, model = Abn_fit_Dist) %>% 
  mutate(Modelo = "distancia")

Dist_sq_pred <- krige(log(zinc) ~ dist, Meuse, Meuse_grid_SF, model = Abn_fit_Dist_sq) %>% 
  mutate(Modelo = "distancia SQ")


Pred <- list(Null_pred, Dist_pred, Dist_sq_pred, Spat_pred) %>% 
  reduce(bind_rows)


ggplot() + 
  geom_sf(data = Pred, aes(color = exp(var1.pred))) + 
  scale_color_viridis_c(name= "Concentración zinc") + 
  facet_wrap(~Modelo) + 
  theme_bw()


### Cross validation

Null_CV <- krige.cv(log(zinc) ~ 1, meuse, model = Abn_fit_null, 
                    nfold = 5) %>% st_as_sf() %>% mutate(Modelo = "Nulo")
Spat_CV <- krige.cv(log(zinc) ~ x + y, meuse, model = Abn_fit_Spat, 
                    nfold = 5) %>% st_as_sf() %>% mutate(Modelo = "Espacial")
Dist_CV <- krige.cv(log(zinc) ~ dist, meuse, model = Abn_fit_Dist, 
                    nfold = 5) %>% st_as_sf() %>% mutate(Modelo = "distancia")
Dist_sq_CV <- krige.cv(log(zinc) ~ sqrt(dist), meuse, model = Abn_fit_Dist_sq, 
                       nfold = 5) %>% st_as_sf() %>% mutate(Modelo = "sqrt(dist)")
Pred_CV <- list(Null_CV, Spat_CV, Dist_CV, Dist_sq_CV) %>% reduce(bind_rows)

## Calculo del root mean square error

Resumen2 <- Pred_CV %>% as.data.frame() %>% group_by(Modelo) %>% 
  summarise(RMSE = sqrt(sum(residual^2)/length(residual))) %>% 
  arrange(RMSE)

ggplot() + geom_sf(data = Null_pred, aes(color = residual)) + facet_wrap(~fold) + scale_color_viridis_c()

Spat_pred <- krige(log(zinc) ~ x + y, meuse, meuse.grid, model = Abn_fit_Spat) %>% 
  st_as_sf(crs = "+init=epsg:28992") %>% 
  mutate(Modelo = "Espacial")

Dist_pred <- krige(log(zinc) ~ dist, Meuse, Meuse_grid_SF, model = Abn_fit_Dist) %>% 
  mutate(Modelo = "distancia")

Dist_sq_pred <- krige(log(zinc) ~ dist, Meuse, Meuse_grid_SF, model = Abn_fit_Dist_sq) %>% 
  mutate(Modelo = "distancia SQ")


Pred <- list(Null_pred, Dist_pred, Dist_sq_pred, Spat_pred) %>% 
  reduce(bind_rows)
