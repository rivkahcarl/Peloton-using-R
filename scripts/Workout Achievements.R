# Workout Achievements
workout.achiev.urls <- sprintf(paste0(base.url, "workout/%s"), workouts.all)

# Achievements function
achievements.fun <- function(x) {
  json.achievement <- jsonlite::fromJSON(x)
  return(json.achievement)}

json.achievement <- lapply(workout.achiev.urls, achievements.fun)

leaderboard.rank.df <-
  as.data.frame(do.call(rbind, json.achievement)) %>%
  dplyr::select(id, leaderboard_rank) %>%
  dplyr::rename(workout_id = id) %>%
  tidyr::unnest()

achievements.list <-
  as.data.frame(do.call(rbind, json.achievement)) %>%
  dplyr::select(id, achievement_templates) %>%
  dplyr::mutate(list.length = lengths(achievement_templates)) %>%
  dplyr::filter(list.length != 0) 

# Achievements function
workouts.w.achiev.fun <- function(x) {
  workout.achievements.df <-
    achievements.list %>%
    dplyr::filter(id == x) %>%
    dplyr::select(achievement_templates) %>%
    tidyr::unnest() %>%
    dplyr::mutate(workout_id = x)
  return(workout.achievements.df)}

workout.achievements.df <- 
  lapply(unlist(achievements.list$id),
         workouts.w.achiev.fun) %>%
  do.call(rbind, .) %>%
  tidyr::unnest()

rm(workout.achiev.urls, achievements.fun, json.achievement, achievements.list, workouts.w.achiev.fun)