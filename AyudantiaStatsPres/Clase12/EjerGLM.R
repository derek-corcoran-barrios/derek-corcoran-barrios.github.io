train <- read_csv("train.csv") %>% filter(Embarked == "S")

FitBin <- glm(Survived ~ Fare + Sex, family = "binomial", data = train)

logit <- function(y){log(y/(1-y))}

DF <- expand.grid(Fare = seq(from = -200, to = 1000, length.out = 50), Prediction = NA, SE = NA, Sex = c("male", "female"))

DF$Prediction <- predict(FitBin, DF, se.fit = TRUE)$fit
DF$SE <- predict(FitBin, DF, se.fit = TRUE)$se.fit

ggplot(DF, aes(x = Fare, y = Prediction)) + geom_ribbon(aes(ymax= Prediction + SE, ymin =Prediction - SE, fill = Sex), alpha = 0.5) + geom_line(aes(lty = Sex)) + theme_classic()
