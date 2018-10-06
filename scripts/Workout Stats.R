# User Workout Stats; need Peloton cookie and workout.count
workout.urls <- paste0(base.url, "user/", userid, "/workouts?joins=peloton.ride&limit=1000")

json.user.workouts <- 
  httr::GET(workout.urls, set_cookies(peloton_session_id = peloton.cookie)) %>% 
  httr::content("text") %>%
  jsonlite::fromJSON(., simplifyDataFrame = TRUE)

ride.stats.df <-
  as.data.frame(do.call(cbind, json.user.workouts$data$peloton$ride)) %>%
  dplyr::select(id, series_id, ride_type_id, instructor_id, duration, pedaling_duration, 
                title, description, fitness_discipline, difficulty_rating_count, 
                difficulty_rating_avg, difficulty_estimate, overall_rating_count, 
                overall_rating_avg, total_workouts, image_url) %>%
  dplyr::rename(ride_id = id, ride_url=image_url) %>%
  tidyr::unnest() %>%
  distinct(ride_id, .keep_all = TRUE)

user.workouts.df <-
  as.data.frame(do.call(cbind, json.user.workouts$data)) %>%
  dplyr::select(user_id, id, strava_id, name, workout_type, is_total_work_personal_record, 
                total_work, start_time, end_time, created_at) %>%
  dplyr::rename(workout_id = id) %>%
  tidyr::unnest()

rm(workout.urls, json.user.workouts)





