# Performance Graphs

# Import streams already downloaded
metrics.stream.current.df <- read.csv(paste0(results, "/workoutmetrics.csv"))
#metrics.stream.current.df <- as.data.frame(list(workout_id = c("0", "1")))

# Create missing urls
time_offset_interval <- 1
workout.graph.missing.urls <- 
  sprintf(paste0(base.url, "workout/%s/performance_graph?every_n=", time_offset_interval),
          setdiff(workouts.all, unique(metrics.stream.current.df$workout_id)))

# Performance graphs function
json.graphs.fun <- function(x) {
  json.graphs <- jsonlite::fromJSON(x)
  heart.zones.df <- 
    list(workout_id = replicate(length(json.graphs[["metrics"]][["zones"]][[5]]$display_name), x),
         max = json.graphs[["metrics"]][["zones"]][[5]]$max_value,
         Heart_Zone = json.graphs[["metrics"]][["zones"]][[5]]$display_name) %>%
    data.frame() %>%
    unnest()
  segment.list.df <- 
    json.graphs$segment_list[c("start_time_offset", "name")] %>%
    data.frame() 
  seconds.all.df <- 
    0:json.graphs$duration %>%
    data.frame() %>%
    dplyr::rename(seconds_since_start = "." ) %>%
    dplyr::left_join(segment.list.df, by = c("seconds_since_start" = "start_time_offset")) %>% 
    do(zoo::na.locf(.))
  seconds.df <- 
    json.graphs$seconds_since_pedaling_start %>%
    data.frame() %>%
    dplyr::rename(seconds_since_start = "." ) %>%
    dplyr::left_join(seconds.all.df, by = c("seconds_since_start" = "seconds_since_start")) %>%
    dplyr::mutate(workout_id = x)
  metrics.df <- 
    json.graphs$metrics$values %>%
    data.frame() 
  names(metrics.df) <- json.graphs$metrics$display_name
  metrics.values.df <- 
    c(seconds.df, metrics.df) %>%
    data.frame() 
  return(list(heart.zones.df, metrics.values.df))}
json.graphs.list <- lapply(workout.graph.missing.urls, json.graphs.fun)

# Extract data from performance graphs function results
heart.zones.df <-
  as.data.frame(do.call(rbind, json.graphs.list))[1] %>%
  tidyr::unnest() %>%
  reshape(dir = "wide", idvar = "workout_id", timevar = "Heart_Zone")

metrics.stream.missing.df <-
  as.data.frame(do.call(rbind, json.graphs.list))[2] %>%
  tidyr::unnest() %>%
  dplyr::left_join(heart.zones.df, by = c("workout_id" = "workout_id")) %>%
  dplyr::mutate(seconds_spent = time_offset_interval,
                Heart_Zone = ifelse(is.na(Heart.Rate), 'No Heart Rate', 
                                    ifelse(Heart.Rate <= `max.Zone 1`, 'Zone 1', 
                                           ifelse(Heart.Rate <= `max.Zone 2`, 'Zone 2', 
                                                  ifelse(Heart.Rate <= `max.Zone 3`, 'Zone 3',
                                                         ifelse(Heart.Rate <= `max.Zone 4`, 'Zone 4', 
                                                                'Zone 5')))))) %>%
  select(workout_id, seconds_since_start, seconds_spent, name, Output,
         Cadence, Resistance, Speed, Heart.Rate, Heart_Zone) %>%
  dplyr::rename(Segment_name = name,
                Heart_Rate = Heart.Rate)

metrics.stream.missing.df$workout_id <- 
  gsub(paste0(base.url, "workout/"), "", metrics.stream.missing.df$workout_id, fixed=TRUE)
metrics.stream.missing.df$workout_id <- 
  gsub(paste0("/performance_graph?every_n=", time_offset_interval), "", 
       metrics.stream.missing.df$workout_id, fixed=TRUE)

# Combine current and missing dataframes; export
metrics.stream.df <- 
  rbind(metrics.stream.current.df, metrics.stream.missing.df) %>%
  dplyr::filter(seconds_since_start >0)

# Prepare for tableau; long instead of wide; export
metrics.stream.long.df <- 
  metrics.stream.df %>%
  reshape2::melt(id.vars = c("seconds_since_start", "workout_id", "Segment_name", "Heart_Zone")) %>%
  dplyr::rename(Metric_name = variable,
                Metric = value)

rm(time_offset_interval, workout.graph.missing.urls, json.graphs.fun, json.graphs.list, 
   heart.zones.df, metrics.stream.current.df, metrics.stream.missing.df)






