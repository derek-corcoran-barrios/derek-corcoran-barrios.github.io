library(tidyverse)

DF <- structure(list(Time = c(0, 1, 2, 4, 6, 8, 9, 10, 11, 12, 13, 
                             14, 15, 16, 18, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29, 30), 
                    Counts = c(126.6, 101.8, 71.6, 101.6, 68.1, 62.9, 45.5, 41.9, 
                               46.3, 34.1, 38.2, 41.7, 24.7, 41.5, 36.6, 19.6, 
                               22.8, 29.6, 23.5, 15.3, 13.4, 26.8, 9.8, 18.8, 25.9, 19.3)), .Names = c("Time", "Counts"), row.names = c(1L, 2L,
                                                                                                                                        3L, 5L, 7L, 9L, 10L, 11L, 12L, 13L, 14L, 15L, 16L, 17L, 19L, 20L, 21L, 22L, 23L, 25L, 26L, 27L, 28L, 29L, 30L,


                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                31L), class = "data.frame")


ggplot(DF, aes(x = Time, y = Counts)) +   
  geom_point() + 
  theme_bw()


fit <- nls(Counts ~ SSasymp(Time, Asym, R0, lrc), data = DF)
summary(fit)


ggplot(DF, aes(x = Time, y = Counts)) + 
  geom_point() +
  stat_smooth(method = "nls", formula = y ~ SSasymp(x, Asym, R0, lrc), se = FALSE) +
  theme_bw()


fit2 <- nls(Counts ~ a * exp(-S * Time), start = list(a = 116,S = 0.02), data = DF)


summary(fit2)





ggplot(DF, aes(x = Time, y = Counts)) + 
  geom_point() +
  stat_smooth(method = "nls", formula = y ~ a * exp(-S * x), 
              method.args = list(start = list(a = 78, S = 0.02)), se = FALSE, #starting values obtained from fit above
              color = "dark red") +
  stat_smooth(method = "nls", formula = y ~ SSasymp(x, Asym, R0, lrc), se = FALSE) +
  theme_bw()



