library(tidyverse)
library(gganimate)
library(ggrepel)
# Function to simulate abundance over time with a disturbance
simulate_abundance <- function(ecosystem, steady_state, stressor_start, stressor_duration, stressor_slope = -0.1, recovery_duration, recovery_slope = 0.1, top_recovery = 100, noise = 2) {
  time <- seq(1, (stressor_start + stressor_duration + recovery_duration))
  
  abundance <- c(rep(steady_state, stressor_start - 1),
                 steady_state * exp(stressor_slope * (1:stressor_duration)))
  
  Min <- min(abundance)
  
  Left <- length(time) - length(abundance)
  
  recovery <- c(Min * exp(recovery_slope * (1:Left)))
  
  recovery <- ifelse(recovery > top_recovery, top_recovery, recovery)
  
  abundance <- c(abundance, recovery)
  
  abundance <- abundance + rnorm(length(abundance), mean = 0, sd = noise)
  
  data.frame(time = time, ecosystem = rep(ecosystem, length(time)), abundance = abundance, stressor_duration = stressor_duration, stressor_slope = stressor_slope, recovery_slope = recovery_slope)
}

# Simulate data for resilience, tolerance, and resistance

DF <- expand.grid(stressor_slope = seq(from = -0.04, to = -0.1, by = -0.02), recovery_slope = seq(from = 0.04, to = 0.1, by = 0.02), stressor_duration = seq(from = 5, to = 10, by = 5))

resilience_data <- list()

for(i in 1:nrow(DF)){
  resilience_data[[i]] <- simulate_abundance(paste("stressor =", DF$stressor_slope[i], "recovery =", DF$recovery_slope[i], "duration =", DF$stressor_duration[i]), steady_state = 100, stressor_start = 31, stressor_duration = DF$stressor_duration[i], stressor_slope = DF$stressor_slope[i], recovery_duration = 50, recovery_slope = DF$recovery_slope[i], top_recovery = 100, noise = 26) 
}

resilience_data <- resilience_data |> purrr::reduce(bind_rows)

resistent <- simulate_abundance("resistent", steady_state = 100, stressor_start = 31, stressor_duration = 2, stressor_slope = -0.05, recovery_slope = 0.1,recovery_duration = 67)

resilient <- simulate_abundance("resilient", steady_state = 100, stressor_start = 31, stressor_duration = 10, recovery_duration = 59,  stressor_slope = -0.05, recovery_slope = 0.1)

non_resilient <- simulate_abundance("non-resilient", steady_state = 100, stressor_start = 31, stressor_duration = 10, recovery_duration = 59,  stressor_slope = -0.05, recovery_slope = 0.04,  top_recovery = 70)


all_data <- dplyr::bind_rows(resistent, resilient, non_resilient)

ggplot(data = all_data, aes(x = time, y = abundance, color = ecosystem)) + geom_path() + geom_vline(xintercept = 30, lty = 2, color = "red") + facet_grid(ecosystem~.)  + theme_bw() + theme(legend.position = "none") +
  transition_reveal(time)



Animation <- ggplot(all_data, aes(x = time, y = abundance, group =ecosystem))  + geom_linerange(aes(color = ecosystem, xmax = max(time), xmin = time), lty = 2) + geom_text_repel(direction = "y", seed = 2020, aes(x = max(time), label = ecosystem, color = ecosystem), force = 0.5) + geom_point(aes(color = ecosystem)) + geom_path(aes(color = ecosystem)) + transition_reveal(along = time) + geom_vline(xintercept = 30, lty = 2) + theme_bw() + facet_wrap(~ecosystem, ncol = 1) + theme(legend.position = "none")

library(gifski)

animate(Animation, width = 1100, height = 1100, nframes = 150, renderer = gifski_renderer(loop = F), end_pause = 30, res = 150, fps = 8)
anim_save("Animacion.gif")



library(plotly)

accumulate_by <- function(dat, var) {
  var <- lazyeval::f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  dplyr::bind_rows(dats)
}


fig <- all_data
fig <- fig %>% accumulate_by(~time)


fig <- fig %>%
  plot_ly(
    x = ~time, 
    y = ~abundance,
    split = ~ecosystem,
    frame = ~frame, 
    type = 'scatter',
    mode = 'lines', 
    line = list(simplyfy = F)
  )
fig <- fig %>% layout(
  xaxis = list(
    title = "Time",
    zeroline = F
  ),
  yaxis = list(
    title = "Abundance",
    zeroline = F
  )
) 
fig <- fig %>% animation_opts(
  frame = 100, 
  transition = 0, 
  redraw = FALSE
)
fig <- fig %>% animation_slider(
  hide = T
)
fig <- fig %>% animation_button(
  x = 1, xanchor = "right", y = 0, yanchor = "bottom"
)

fig

## New try

fig <- all_data
fig <- fig %>% accumulate_by(~time)

gg <- ggplot(fig, aes(x=time, y=abundance)) +
  geom_path(aes(frame = frame, color = ecosystem)) + facet_grid(ecosystem~.) + theme_bw()
gg <- ggplotly(gg)

gg <- gg %>% animation_opts(
  frame = 100, 
  transition = 0, 
  redraw = FALSE
)
gg <- gg %>% animation_slider(
  hide = T
)
gg <- gg %>% animation_button(
  x = 1, xanchor = "right", y = 0, yanchor = "bottom"
)
