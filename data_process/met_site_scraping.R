library(rvest)
library(dplyr)
library(purrr)
library(ralger)

# getting a silly recaptcha from when trying dynamically
# going to code it up myself manually
dept_desc <- tibble::tribble(
  ~dept_id, ~department, ~dept_description,
  13, "Greek and Roman Art", "The Museum's collection of Greek and Roman art comprises more than 30,000 works ranging in date from the Neolithic period (ca. 4500 B.C.) to the time of the Roman emperor Constantine's conversion to Christianity in A.D. 312.",
  12, "European Sculpture and Decorative Arts", "The 50,000 objects in the Museum's comprehensive collection of European sculpture and decorative arts reflect the development of a number of art forms in Western European countries from the early fifteenth through the early twentieth century.",
  14, "Islamic Art", "The Met's collection of Islamic art is one of the most comprehensive in the world and ranges in date from the seventh to the twenty-first century. Its more than 15,000 objects reflect the great diversity and range of the cultural traditions from Spain to Indonesia.",
  10, "Egyptian Art", "The Met's collection of ancient Egyptian art consists of approximately 26,000 objects of artistic, historical, and cultural importance, dating from the Paleolithic to the Roman period (ca. 300,000 B.C.–A.D. 4th century).",
  3, "Ancient Near Eastern Art", "The Met's collection of ancient Near Eastern art includes more than 7,000 works ranging in date from the eighth millennium B.C. through the centuries just beyond the time of the Arab conquests of the seventh century A.D.",
  8, "Costume Institute", "The Costume Institute's collection of more than 33,000 costumes and accessories represents five continents and seven centuries of fashionable dress and accessories for men, women, and children, from the fifteenth century to the present.",
  5, "Arts of Africa, Oceania, and the Americas", "Nearly 1,600 objects from Africa, the Pacific Islands, and the Americas are on view in The Metropolitan Museum of Art's Michael C. Rockefeller Wing. They span 3,000 years, three continents, and many islands, and represent a rich diversity of cultural traditions.",
  17, "Medieval Art", "The Museum's collection of medieval and Byzantine art is among the most comprehensive in the world, encompassing the art of the Mediterranean and Europe from the fall of Rome to the beginning of the Renaissance.",
  1, "The American Wing", "Ever since its establishment in 1870, the Museum has acquired important examples of American art. Today, the American Wing's ever-evolving collection comprises some 20,000 works by African American, Euro American, Native American, and Latin American artists, ranging from the colonial to early-modern period.",
  4, "Arms and Armor", "The principal goals of the Arms and Armor Department are to collect, preserve, research, publish, and exhibit distinguished examples representing the art of the armorer, swordsmith, and gunmaker.",
  6, "Asian Art", "The Met's collection of Asian art—more than 35,000 objects, ranging in date from the third millennium B.C. to the twenty-first century—is one of the largest and most comprehensive in the world.",
  7, "The Cloisters", "The Museum's collection of medieval and Byzantine art is among the most comprehensive in the world, encompassing the art of the Mediterranean and Europe from the fall of Rome to the beginning of the Renaissance.",
  18, "Musical Instruments", "The Museum's collection of musical instruments includes approximately 5,000 examples from six continents and the Pacific Islands, dating from about 300 B.C. to the present.",
  15,"Robert Lehman Collection", "The Robert Lehman Collection is one of the most distinguished privately assembled art collections in the United States. Robert Lehman's bequest to The Met is a remarkable example of twentieth-century American collecting.",
  9, "Drawings and Prints", "The Met's collection of drawings and prints—one of the most comprehensive and distinguished of its kind in the world—began with a gift of 670 works from Cornelius Vanderbilt, a Museum trustee, in 1880.",
  19, "Photographs", "Established as an independent curatorial department in 1992, The Met's Department of Photographs houses a collection of more than 75,000 works spanning the history of photography from its invention in the 1830s to the present.",
  16, "The Libraries", "With over one million volumes, an extensive digital collection, and online resources, Thomas J. Watson Library is one of the world's most comprehensive art libraries."
)

saveRDS(dept_desc, file = fs::path(here::here(), "data_process", "dept_desc.rds"))

