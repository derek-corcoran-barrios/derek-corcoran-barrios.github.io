library(vegan)
library(tidyverse)

data("dune")
data("dune.env")

sol <- metaMDS(dune)

Data <- sol$points %>% as.data.frame() %>% bind_cols(dune.env)

ggplot(Data, aes(MDS1, MDS2)) +
  geom_point(aes(color = Management, size = A1)) +
  theme_bw()


StatChull <- ggproto("StatChull", Stat,
                     compute_group = function(data, scales) {
                       data[chull(data$x, data$y), , drop = FALSE]
                     },
                     
                     required_aes = c("x", "y")
) 


stat_chull <- function(mapping = NULL, data = NULL, geom = "polygon",
                       position = "identity", na.rm = FALSE, show.legend = NA, 
                       inherit.aes = TRUE, ...) {
  layer(
    stat = StatChull, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

ggplot(dune, aes(x = Achimill, y = Agrostol)) +
  geom_point()

anosim(dune, grouping = dune.env$Management)


ggplot(Data, aes(MDS1, MDS2)) +
  stat_chull(aes(fill = Management), alpha =0.5) +
  geom_point(aes(color = Management)) +
  theme_bw() 


Sitio1 <- data.frame(Sitio1 = paste0("S", 1:nrow(dune.env)), Management1 = dune.env$Management)
Sitio2 <- Sitio1 %>% rename(Sitio2  = Sitio1, Management2 = Management1)

bray <- as.matrix(vegdist(dune)) %>% as.data.frame()
bray[upper.tri(bray)] <- NA
diag(bray) <- NA
colnames(bray) <- paste0("S", 1:ncol(bray))
bray$Sitio1 <- paste0("S", 1:nrow(bray))

bray <-  bray %>% 
  pivot_longer(cols = -Sitio1, names_to = "Sitio2", values_to = "Distancia") %>% 
  dplyr::filter(!is.na(Distancia)) %>% 
  left_join(Sitio1) %>% left_join(Sitio2) %>% 
  mutate(Tipo = ifelse(Management1 == Management2, "Igual", "Diferente")) %>% 
  group_split(Management1) %>% 
  purrr::map(~mutate(.x, codigo1 = dplyr::row_number(), codigo1 = paste0(Management1, codigo1))) %>% 
  reduce(bind_rows) %>% 
  group_split(Management2) %>% 
  purrr::map(~mutate(.x, codigo2 = dplyr::row_number(), codigo2 = paste0(Management2, codigo2))) %>% 
  reduce(bind_rows) %>% 
  arrange(codigo1, codigo2) %>% 
  mutate(Sitio2 = fct_relevel(Sitio2, "S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10", 
                              "S11", "S12", "S13", "S14", "S15", "S16", "S17", "S18", "S19"),
         Sitio1 = fct_relevel(Sitio1, "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10", 
                              "S11", "S12", "S13", "S14", "S15", "S16", "S17", "S18", "S19"))
  

ggplot(bray, aes(x = Sitio1, y = Sitio2)) + 
  geom_tile(aes(fill = Tipo)) + 
  geom_text(aes(label = round(Distancia, 1))) +
  theme_bw()

ggplot(bray, aes(x = Tipo, y = Distancia)) + 
  geom_boxplot(notch = T) + 
  theme_bw()


Mod0 <- adonis2(dune ~ 1, data = dune.env, by = "terms")
Mod1 <- adonis2(dune ~ Management, data = dune.env, by = "terms")
Mod2 <- adonis2(dune ~ Management*A1, data = dune.env, by = "terms")
Mod3 <- adonis2(dune ~ Use*A1, data = dune.env, by = "terms")
Mod4 <- adonis2(dune ~ A1, data = dune.env, by = "terms")
Mod5 <- adonis2(dune ~ Management + Moisture, data = dune.env, by = "terms")

AICc.PERMANOVA <- function(adonis.model) {
  
  # check to see if object is an adonis model...
  
  if (!(adonis.model$aov.tab[1,1] >= 1))
    stop("object not output of adonis {vegan} ")
  
  # Ok, now extract appropriate terms from the adonis model
  # Calculating AICc using residual sum of squares (RSS) since I don't think that adonis returns something I can use as a liklihood function...
  
  RSS <- adonis.model$aov.tab[rownames(adonis.model$aov.tab) == "Residuals", "SumsOfSqs"]
  MSE <- adonis.model$aov.tab[rownames(adonis.model$aov.tab) == "Residuals", "MeanSqs"]
  
  k <- ncol(adonis.model$model.matrix)# + 1 # add one for error variance
  
  nn <- nrow(adonis.model$model.matrix)
  
  # AIC : 2*k + n*ln(RSS)
  # AICc: AIC + [2k(k+1)]/(n-k-1)
  
  # based on https://en.wikipedia.org/wiki/Akaike_information_criterion;
  # https://www.researchgate.net/post/What_is_the_AIC_formula;
  # http://avesbiodiv.mncn.csic.es/estadistica/ejemploaic.pdf
  
  # AIC.g is generalized version of AIC = 2k + n [Ln( 2(pi) RSS/n ) + 1]
  # AIC.pi = k + n [Ln( 2(pi) RSS/(n-k) ) +1],
  
  AIC <- 2*k + nn*log(RSS)
  AICc <- AIC + (2*k*(k + 1))/(nn - k - 1)
  
  output <- data.frame(AICc = AICc,k = k, n = nn)
  
  return(output)   
}

AICc.PERMANOVA2 <- function(adonis2.model) {
  
  # check to see if object is an adonis2 model...
  
  if (is.na(adonis2.model$SumOfSqs[1]))
    stop("object not output of adonis2 {vegan} ")
  
  # Ok, now extract appropriate terms from the adonis model Calculating AICc
  # using residual sum of squares (RSS or SSE) since I don't think that adonis
  # returns something I can use as a likelihood function... maximum likelihood
  # and MSE estimates are the same when distribution is gaussian See e.g.
  # https://www.jessicayung.com/mse-as-maximum-likelihood/;
  # https://towardsdatascience.com/probability-concepts-explained-maximum-likelihood-estimation-c7b4342fdbb1
  # So using RSS or MSE estimates is fine as long as the residuals are
  # Gaussian https://robjhyndman.com/hyndsight/aic/ If models have different
  # conditional likelihoods then AIC is not valid. However, comparing models
  # with different error distributions is ok (above link).
  
  
  RSS <- adonis2.model$SumOfSqs[ length(adonis2.model$SumOfSqs) - 1 ]
  MSE <- RSS / adonis2.model$Df[ length(adonis2.model$Df) - 1 ]
  
  nn <- adonis2.model$Df[ length(adonis2.model$Df) ] + 1
  
  k <- nn - adonis2.model$Df[ length(adonis2.model$Df) - 1 ]
  
  
  # AIC : 2*k + n*ln(RSS/n)
  # AICc: AIC + [2k(k+1)]/(n-k-1)
  
  # based on https://en.wikipedia.org/wiki/Akaike_information_criterion;
  # https://www.statisticshowto.datasciencecentral.com/akaikes-information-criterion/ ;
  # https://www.researchgate.net/post/What_is_the_AIC_formula;
  # http://avesbiodiv.mncn.csic.es/estadistica/ejemploaic.pdf;
  # https://medium.com/better-programming/data-science-modeling-how-to-use-linear-regression-with-python-fdf6ca5481be 
  

  AIC <- 2*k + nn*log(RSS/nn)
  AICc <- AIC + (2*k*(k + 1))/(nn - k - 1)

  output <- data.frame(AICc = AICc, k = k, N = nn)
  
  return(output)   
  
}

DF<- data.frame(Modelo = paste0("Mod", 0:5), AICc = NA)


DF$AICc[1] <- AICc.PERMANOVA2(Mod0)$AICc
DF$AICc[2] <-  AICc.PERMANOVA2(Mod1)$AICc
DF$AICc[3] <- AICc.PERMANOVA2(Mod2)$AICc
DF$AICc[4] <-  AICc.PERMANOVA2(Mod3)$AICc
DF$AICc[5] <-  AICc.PERMANOVA2(Mod4)$AICc
DF$AICc[6] <-  AICc.PERMANOVA2(Mod5)$AICc

AICc.PERMANOVA2(Mod1)
AICc.PERMANOVA2(Mod2)
AICc.PERMANOVA2(Mod3)



data(dune)
data(dune.env)
mod0 <- rda(dune ~ 1, dune.env)  # Model with intercept only
mod1 <- rda(dune ~ ., dune.env)  # Model with all explanatory variables

## With scope present, the default direction is "both"
mod <- ordistep(mod0, scope = formula(mod1))
mod
## summary table of steps
mod$anova



tbRDA <- rda(spe.hell ~ pH + SOILDPT + ELEVATION, data= vltava.env[,1:18])
par(mfrow =c(1,2))
ordiplot (tbRDA)
ef <- envfit (tbRDA ~ pH + SOILDPT + ELEVATION, data= vltava.env, display ='lc')
ef12 <- envfit (tbRDA ~ pH + SOILDPT + ELEVATION, data= vltava.env)
ef123 <- envfit (tbRDA ~ pH + SOILDPT + ELEVATION, data= vltava.env, choices =1:3)

ordiplot (tbRDA, type ='n')
plot(ef, col='blue')
plot(ef12, col='red')
plot(ef123, col='green')

ordiplot(tbRDA, type ='n')
plot(ef, col='blue')
plot(ef12, col='red')
plot(ef123, col='green')
legend('bottomright', lwd =1, col=c('blue', 'red', 'green'), legend=c('envfit on linear combination of scores', 'envfit  on sample scores (1st &2nd axis)', 'envfit on sample scores (1st, 2nd and 3rd axis)'), bty ='n')
