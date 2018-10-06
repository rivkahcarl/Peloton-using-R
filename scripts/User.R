#  User Info
json.user <- jsonlite::fromJSON(paste0(base.url, "user/", userid))

user.counts.df <-
  do.call(cbind, json.user$workout_counts) %>%
  data.frame() %>%
  tidyr::unnest()

user.df <-
  cbind(json.user[c("id", "username", "location", "total_workouts", "total_non_pedaling_metric_workouts", 
                    "last_workout_at", "image_url", "total_following")] %>%
          rbind() %>% data.frame() %>% dplyr::rename(user_id = id, user_url=image_url),
        do.call(cbind, json.user$streaks) %>% data.frame()) %>%
  tidyr::unnest()

user.df$start_date_of_current_weekly = 
  as.POSIXct(as.POSIXlt(user.df$start_date_of_current_weekly, origin="1970-01-01", tz="America/Los_Angeles"))
user.df$last_workout_at = 
  as.POSIXct(as.POSIXlt(user.df$last_workout_at,origin="1970-01-01", tz="America/Los_Angeles"))

rm(json.user)