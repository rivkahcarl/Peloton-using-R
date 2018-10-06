# Instructor Info
instructor.page.count <- 
  jsonlite::fromJSON(paste0(base.url, "instructor"))[c("page_count")] %>%
  unlist()
instructor.pages <- 0:(instructor.page.count-1)
instructor.urls <- sprintf(paste0(base.url, "instructor/?page=%s"), instructor.pages)

# Instructor function
instructor.fun <- function(x) {
  json.instructor <- jsonlite::fromJSON(x)
  instructor.df <- 
    json.instructor$data %>%
    select(id, name, first_name, username, user_id, background, quote, bio, image_url,
           web_instructor_list_display_image_url, jumbotron_url, instructor_hero_image_url,
           life_style_image_url, facebook_fan_page) %>%
    dplyr::rename(instructor_id = id,
                  instructor_name = name,
                  instructor_first = first_name,
                  instructor_username = username,
                  instructor_user_id = user_id,
                  instructor_background = background,
                  instructor_quote = quote,
                  instructor_fan_page = facebook_fan_page,
                  instructor_bio = bio,
                  instructor_url = image_url,
                  instructor_url2 = web_instructor_list_display_image_url,
                  instructor_jumbo_url = jumbotron_url,
                  instructor_hero_url = instructor_hero_image_url,
                  instructor_style_url = life_style_image_url)
  return(instructor.df)}

# Instructor data frame
instructor.df <- 
  lapply(instructor.urls, instructor.fun) %>% 
  bind_rows() 

saveRDS(instructor.df, file = paste0(data, "Instructors.RData"))
rm(instructor.page.count, instructor.pages, instructor.urls, instructor.fun)