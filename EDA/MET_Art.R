
# Met Art Collection

# https://github.com/metmuseum/openaccess

# -- data dictionary , a table 
# https://metmuseum.github.io/


# the MET has a living map of where the art is
# https://maps.metmuseum.org/?screenmode=base&floor=1#hash=17.92/40.779513/-73.963425/-61

# search for the collection for Open Access 
# https://www.metmuseum.org/art/collection/search?showOnly=highlights%7CwithImage%7CopenAccess&pageSize=0&sortBy=Relevance&sortOrder=asc&searchField=All




library(tidyverse)
library(lubridate)
library(stringr)
library(janitor)


# read in the 477,804 rows and must column clean names
art = read_csv('https://media.githubusercontent.com/media/metmuseum/openaccess/master/MetObjects.csv') %>% clean_names()

glimpse(art)

# prototyping folder was not showing up on my end, file too large to have locally
# write_csv2(art, path = 'prototyping/MetObjects.csv')

# EDA ---------------------------------------------------------------------

art %>% 
  select(is_highlight) %>% 
  janitor::tabyl(is_highlight)


art %>% 
  select(is_timeline_work) %>% 
  tabyl(is_timeline_work)

# the public domain is what we care about
art %>% 
  select(is_public_domain) %>% 
  tabyl(is_public_domain)


art %>% 
  select(is_public_domain, object_id) %>% 
  filter(is_public_domain ==TRUE)


# art$gallery_number = factor(art$gallery_number)

art %>% 
  select(department) %>%
  distinct()

art$department = factor(art$department)
art$accession_year = factor(art$accession_year)
art$object_name = factor(art$object_name)
art$title = factor(art$title)
art$culture = factor(art$culture)
art$dynasty = factor(art$dynasty)
art$medium = factor(art$medium)
art$classification = factor(art$classification)
art$region = factor(art$region)

art %>% 
  select(medium) %>% 
  count(medium, sort = T)


art$country = factor(art$country)

art %>% 
  select(country) %>% 
  count(country, sort = T)



art %>% 
  select(region) %>% 
  count(region, sort = T)



#-------- artist display name , artist count by name
art$artist_display_name = factor(art$artist_display_name)
art %>% 
  select(artist_display_name) %>% 
  count(artist_display_name, sort = T)

# portfolio = set of works created as a group
art %>% 
  select(artist_display_name, portfolio) %>% 
  distinct() %>% 
  filter(!is.na(portfolio) ) %>% 
  count(artist_display_name, sort = T)


art %>% 
  select(artist_display_name, country) %>% 
  distinct()


# artist age in Bio, birth & death city (when known)
# needs more work --
art %>% 
  select(artist_display_bio) %>%
  distinct() %>% 
  mutate(artist_age = str_replace_all(artist_display_bio, 
                                      pattern = "[:alpha:]", 
                                      replacement = ""),
         artist_age = str_trim(artist_display_bio, side = 'both')
         ) %>% view()






# -- city where art was created
art$city = factor(art$city)

art %>% 
  select(city) %>% 
  count(city, sort = T)

# - state
art$state = factor(art$state)
art %>% 
  select(state) %>% 
  count(state, sort = T) 



# - river
art$river = factor(art$river)
art %>% 
  select(river) %>% 
  count(river, sort = T)



# - tags, array of subject keywords associated w/ object
art$tags = factor(art$tags)

art %>% 
  select(tags) %>% 
  # distinct() %>% 
  count(tags, sort = T)







# search ------------------------------------------------------------------

# used website to look at marble statue then look it up
art %>% 
  filter(culture == "Roman",
         classification =="Stone Sculpture",
         medium == 'Marble'
         # title =="Marble head of an athlete"
         ) %>% view()



# search tags for dresses by culture 
art %>% 
  select(tags, object_name, title, culture) %>% 
  filter(tags =="Dresses") %>% 
  count(object_name, culture, sort = T)






