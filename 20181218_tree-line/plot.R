# data extracted from here https://en.wikipedia.org/wiki/Tree_line
dat = tibble::tribble(
                                       ~Place, ~Latirude, ~TreeLine, ~TreeLine_ft, ~NS, ~Latitude_cor,                 ~Label,        ~Continent,
                     "Finnmarksvidda, Norway",        69,       500,         1600,  1L,            69,                     NA,          "Europe",
                             "Abisko, Sweden",        68,       650,         2100,  1L,            68,                     NA,          "Europe",
                  "Chugach Mountains, Alaska",        61,       700,         2300,  1L,            61,                     "Chugach Mountains, Alaska",   "North America",
                            "Southern Norway",        61,      1100,         3600,  1L,            61,                     NA,          "Europe",
                                   "Scotland",        57,       500,         1600,  1L,            57,                     NA,          "Europe",
                            "Northern Quebec",        56,         0,            0,  1L,            56,                     NA,   "North America",
                             "Southern Urals",        55,      1100,         3600,  1L,            55,                     NA,          "Europe",
                           "Canadian Rockies",        51,      2400,         7900,  1L,            51,                     NA,   "North America",
                            "Tatra Mountains",        49,      1600,         5200,  1L,            49,      "Tatra Mountains, Poland",          "Europe",
        "Olympic Mountains WA, United States",        47,      1500,         4900,  1L,            47,    "Olympic Mountains, WA",   "North America",
                                 "Swiss Alps",        47,      2200,         7200,  1L,            47,           "Swiss Alps",          "Europe",
       "Mount Katahdin, Maine, United States",        46,      1150,         3800,  1L,            46,                     NA,   "North America",
               "Eastern Alps, Austria, Italy",        46,      1750,         5700,  1L,            46,                     NA,          "Europe",
                       "Sikhote-Alin, Russia",        46,      1600,         5200,  1L,            46,                     NA,          "Europe",
       "Alps of Piedmont, Northwestern Italy",        45,      2100,         6900,  1L,            45,                     NA,          "Europe",
               "New Hampshire, United States",        44,      1350,         4400,  1L,            44,                     NA,   "North America",
                     "Wyoming, United States",        43,      3000,         9800,  1L,            43,                     NA,   "North America",
         "Rila and Pirin Mountains, Bulgaria",        42,      2300,         7500,  1L,            42,                     NA,          "Europe",
            "Pyrenees Spain, France, Andorra",        42,      2300,         7500,  1L,            42,             "Pyrenees, Spain",          "Europe",
     "Wasatch Mountains, Utah, United States",        40,      2900,         9500,  1L,            40,                     NA,   "North America",
       "Rocky Mountain NP, CO, United States",        40,      3550,        11600,  1L,            40,      "Rocky Mountains, CO",   "North America",
       "Rocky Mountain NP, CO, United States",        40,      3250,        10700,  1L,            40,                     NA,   "North America",
                              "Japanese Alps",        36,      2900,         9500,  1L,            36,        "Japanese Alps",            "Asia",
                "Yosemite, CA, United States",        38,      3200,        10500,  1L,            38,                     NA,   "North America",
                "Yosemite, CA, United States",        38,      3600,        11800,  1L,            38,         "Yosemite, CA",   "North America",
                       "Sierra Nevada, Spain",        37,      2400,         7900,  1L,            37, "Sierra Nevada, Spain",          "Europe",
                           "Khumbu, Himalaya",        28,      4200,        13800,  1L,            28,                     NA,            "Asia",
                             "Yushan, Taiwan",        23,      3600,        11800,  1L,            23,                     NA,            "Asia",
                      "Hawaii, United States",        20,      3000,         9800,  1L,            20,                     NA,   "North America",
                    "Pico de Orizaba, Mexico",        19,      4000,        13100,  1L,            19,                     NA, "Central America",
                                 "Costa Rica",       9.5,      3400,        11200,  1L,           9.5,                     NA, "Central America",
                     "Mount Kinabalu, Borneo",       6.1,      3400,        11200,  1L,           6.1,                     NA,            "Asia",
                "Mount Kilimanjaro, Tanzania",         3,      3100,        10200, -1L,            -3,                     NA,          "Africa",
                                 "New Guinea",         6,      3850,        12600, -1L,            -6,                     NA,          "Africa",
                                "Andes, Peru",        11,      3900,        12800, -1L,           -11,                     "Andes, Peru",   "South America",
                             "Andes, Bolivia",        18,      5200,        17100, -1L,           -18,                     NA,   "South America",
                             "Andes, Bolivia",        18,      4100,        13500, -1L,           -18,                     NA,   "South America",
               "Sierra de C?rdoba, Argentina",        31,      2000,         6600, -1L,           -31,                     NA,   "South America",
                 "Australian Alps, Australia",        36,      2000,         6600, -1L,           -36,                     "Australian Alps",         "Oceania",
                 "Australian Alps, Australia",        36,      1700,         5600, -1L,           -36,                     NA,         "Oceania",
              "Andes, Laguna del Laja, Chile",        37,      1600,         5200, -1L,           -37,                     NA,   "South America",
  "Mount Taranaki, North Island, New Zealand",        39,      1500,         4900, -1L,           -39,                     NA,         "Oceania",
                        "Tasmania, Australia",        41,      1200,         3900, -1L,           -41,                     NA,         "Oceania",
       "Fiordland, South Island, New Zealand",        45,       950,         3100, -1L,           -45,                     NA,         "Oceania",
                    "Torres del Paine, Chile",        51,       950,         3100, -1L,           -51,                     NA,   "South America",
                     "Navarino Island, Chile",        55,       600,         2000, -1L,           -55,                     NA,   "South America"
  )

# from http://colorbrewer2.org/
colors = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#a65628", "#f781bf")

# imports =====
library(magrittr)
library(ggplot2)

# plot ==
dat %>% ggplot(aes(x = Latirude,y = TreeLine)) +
  geom_point(aes(color = Continent)) +
  geom_smooth(method = "lm",color = "black",linetype = "dashed",alpha = 0.1) +
  ggrepel::geom_text_repel(aes(label = Label,color = Continent),
                           #direction     = "y",
                           nudge_x = 15,
                           nudge_y = 200) +
  theme_minimal() +
  scale_color_manual(values = colors) +
  labs(y = "Elevation of tree line (m)",
       x = "Latitude")


ggsave(plot = fp,filename = "plot.png",device = "png",width = 10,height = 5,dpi = 400)
