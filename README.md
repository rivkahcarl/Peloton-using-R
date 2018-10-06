# Peloton using R

I created these R scripts to be able to download my workout data with more granularity than what's available in the peloton website. You'll need first to find your Peloton ID by going to the peloton website and copying the url of one of your workouts. URL looks something like this:

```
https://members.onepeloton.com/profile/workouts/b152j64s1pm6532a9454sa53a44ec43
```

Once you have workout id, you can find out your Peloton ID:

```
library(jsonlite)
id.from.peloton <- 'b152j64s1pm6532a9454sa53a44ec43'
json.find.user.id <- 
  jsonlite::fromJSON(paste0("https://api.pelotoncycle.com/api/workout/", id.from.peloton, "/summary"))
json.find.user.id$user_id
```
