# Peloton session id; get cookie
credentials <- httr::POST(auth.url, 
                          body = list(password = password, username_or_email = username), 
                          encode = "json") 

session.id <-
  as.data.frame(do.call(rbind, credentials$headers)) %>%
  dplyr::filter(grepl("peloton_session_id", V1)) %>%
  unlist() %>%
  strsplit(';') %>%
  data.frame() %>%
  dplyr::filter(grepl("peloton_session_id", V1)) %>%
  unlist() %>%
  strsplit('=') %>%
  data.frame() %>%
  unnest()

peloton.cookie <- session.id[-1, ] 

rm(credentials, session.id)