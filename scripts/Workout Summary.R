
# Workout summary 
workout.summary.fun <- function(x) {
  json.user.workout.summaries <- jsonlite::fromJSON(x)
  return(json.user.workout.summaries)}

json.user.workout.summaries <- 
  lapply(sprintf(paste0(base.url, "workout/%s/summary"), workouts.all),
         workout.summary.fun)

workout.summary.list <-
  as.data.frame(do.call(rbind, json.user.workout.summaries)) %>%
  dplyr::select(workout_id, ride_id, avg_power, avg_cadence, avg_resistance, avg_speed, avg_heart_rate,
                max_power, max_cadence, max_resistance, max_speed, max_heart_rate, distance,
                calories, seconds_since_pedaling_start)

# Fill in blanks
list.names <- colnames(workout.summary.list)
nullToNA <- function(x) {
  x[sapply(x, is.null)] <- NA
  return(x)}
workout.summary.list <- lapply(workout.summary.list, nullToNA)

workout.summary.df <-
  as.data.frame(do.call(cbind, workout.summary.list)) %>%
  tidyr::unnest()

rm(workout.summary.fun, json.user.workout.summaries, workout.summary.list, list.names)