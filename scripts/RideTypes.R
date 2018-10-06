# Ride Types
ride.type.page.count <- 
  jsonlite::fromJSON(paste0(base.url, "ride_type"))[c("page_count")] %>%
  unlist()
ride.type.pages <- 0:(ride.type.page.count-1)
ride.type.urls <- sprintf(paste0(base.url, "ride_type/?page=%s"), ride.type.pages)

# Ride Type function
ride.type.fun <- function(x) {
  json.ride.type <- jsonlite::fromJSON(x)
  ride.type.df <-
    json.ride.type$data %>%
    select(id, fitness_discipline, display_name) %>%
    dplyr::rename(ride_type_id = id,
                  ride_type_name = display_name,
                  ride_type_discipline = fitness_discipline)
  return(ride.type.df)}

# Ride Type dataframe
ride.type.df <- 
  lapply(ride.type.urls, ride.type.fun) %>% 
  bind_rows() 

saveRDS(ride.type.df, file = paste0(data, "RideType.RData"))
rm(ride.type.page.count, ride.type.pages, ride.type.urls, ride.type.fun)