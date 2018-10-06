
# Load Packages
options(stringsAsFactors = FALSE); 
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)
library(tidyr)
library(zoo)
library(data.table)
library(reshape2)

# Folders
input <- paste0("/folder/Peloton")
results <- paste0(input, "/results")
shapes <- paste0("/folder/My Tableau Repository/Shapes/Peloton/")
data <- paste0(input, "/data/")
scripts <- paste0(input, "/scripts/")


################################################
# Run Scripts
################################################
# Peloton API Credentials; get cookie
source(paste0(scripts, "API Credentials.r"))
source(paste0(scripts, "Peloton Cookie.r"))

# Instructor Info
source(paste0(scripts, "Instructors.r"))

# Ride Types
source(paste0(scripts, "RideTypes.r"))

# User Info
source(paste0(scripts, "User.r"))
workout.count <- user.df$total_workouts

# Workout List and Ride Stats; need cookie and workout.count
source(paste0(scripts, "Workout Stats.r"))
workouts.all <- unlist(user.workouts.df$workout_id)

# Workout Summary
source(paste0(scripts, "Workout Summary.r"))

# Workout Achievements
source(paste0(scripts, "Workout Achievements.r"))

# Performance Graphs
source(paste0(scripts, "Performance Graphs.r"))


################################################
# Create final data frame; export
################################################
user.workouts.final.df <-
  user.workouts.df %>%
  dplyr::left_join(leaderboard.rank.df, by = c("workout_id" = "workout_id")) %>%
  dplyr::left_join(workout.summary.df, by = c("workout_id" = "workout_id")) %>%
  dplyr::left_join(ride.stats.df, by = c("ride_id" = "ride_id")) %>%
  dplyr::mutate(start_time = as.POSIXct(as.POSIXlt(start_time, origin="1970-01-01", tz="America/Los_Angeles")),
                end_time = as.POSIXct(as.POSIXlt(end_time, origin="1970-01-01", tz="America/Los_Angeles")),
                created_at = as.POSIXct(as.POSIXlt(created_at, origin="1970-01-01", tz="America/Los_Angeles")),
                date.id = lubridate::year(start_time)*100000+
                  lubridate::month(start_time)*1000+
                  lubridate::day(start_time)*10) %>%
  dplyr::group_by(date.id) %>%
  dplyr::arrange(start_time) %>% 
  dplyr::mutate(seq = row_number()) 
     
user.workouts.final.df$workout_num <- user.workouts.final.df$date.id+user.workouts.final.df$seq               
user.workouts.final.df$date.id <- NULL
user.workouts.final.df$seq <- NULL     

master.ids.df <- 
  user.workouts.final.df[c("user_id", "workout_id", "workout_num", "strava_id", 
                           "ride_id", "ride_type_id", "instructor_id")]
rm(user.workouts.df, leaderboard.rank.df, workout.summary.df, ride.stats.df)


# Export csvs
write.csv(instructor.df, file = paste0(results, "/instructors.csv"), row.names = F)
write.csv(ride.type.df, file = paste0(results, "/ridetypes.csv"), row.names = F)
write.csv(user.df, file = paste0(results, "/userdetails.csv"), row.names = F)
write.csv(user.counts.df, file = paste0(results, "/usercounts.csv"), row.names = F)
write.csv(workout.achievements.df, file = paste0(results, "/achievements.csv"), row.names = F)
write.csv(user.workouts.final.df, file = paste0(results, "/workouts.csv"), row.names = F)
write.csv(master.ids.df, file = paste0(results, "/master_ids.csv"), row.names = F)
write.csv(metrics.stream.df, file = paste0(results, "/workoutmetrics.csv"), row.names = F)
write.csv(metrics.stream.long.df, file = paste0(results, "/workoutmetricslong.csv"), row.names = F)


# Pictures
shapes.df <- 
  rbind(workout.achievements.df[c("slug", "image_url")] %>% unique() %>% dplyr::rename(url = image_url),
        user.counts.df[c("slug", "icon_url")] %>% unique() %>% dplyr::rename(url = icon_url))

shapes.fun <- function(x) {
  url.df <- shapes.df[x,]
  download.file(url.df$url, paste0(shapes, url.df$slug, '.png'))
  return(url.df)}

url.df <- lapply(c(1:nrow(shapes.df)), shapes.fun)

rm(shapes.df, shapes.fun, url.df)




