# Note: update file paths to match your local directory before running

library(tidyverse)
library(readxl)

list.files("C:/Users/sanch/OneDrive/Documents")

gdp_raw <- read_excel("C:/Users/sanch/OneDrive/Documents/gdp.xlsx.xlsx",
                      sheet = "Data",
                      skip = 3)

gdp <- gdp_raw %>%
  select('Country Name', 'Country Code', '2022') %>%
  rename(country = 'Country Name',
         code = 'Country Code',
         gdp_per_capita = '2022') %>%
  filter(!is.na(gdp_per_capita))

hdi_raw <- read_excel("C:/Users/sanch/OneDrive/Documents/hdi.xlsx.xlsx",
                      sheet = "Table 1. HDI",
                      skip = 6)

hdi <- hdi_raw %>%
  select(2, 3) %>%
  rename(country = 1,
         hdi = 2) %>%
  filter(!is.na(hdi),
         !is.na(country)) %>%
  mutate(hdi = as.numeric(hdi))

merged <- inner_join(gdp, hdi, by = "country")

head(merged)

library(ggplot2)

highlight <- c("India", "China", "United States", 
               "Bangladesh", "Nigeria", "Germany", 
               "Sweden", "Brazil", "Pakistan")

merged <- merged %>%
  mutate(label = ifelse(country %in% highlight, country, NA))

library(ggrepel)

ggplot(merged, aes(x = gdp_per_capita, y = hdi)) +
  geom_point(color = "#6b4fa0", alpha = 0.6, size = 2.5) +
  geom_point(data = filter(merged, country == "India"),
             color = "#ff6b35", size = 4) +
  ggrepel::geom_text_repel(aes(label = label),
                           size = 3,
                           na.rm = TRUE) +
  scale_x_log10(labels = scales::comma) +
  labs(
    title = "GDP per Capita vs Human Development Index (2022–23)",
    subtitle = "Each dot = one country. India highlighted in orange.",
    x = "GDP per Capita (log scale, USD)",
    y = "Human Development Index (HDI)",
    caption = "Sources: World Bank (2022), UNDP HDR (2023)"
  ) +
  theme_minimal()

library(ggplot2)
ggsave("C:/Users/sanch/OneDrive/Documents/Coding Projects/gdp_vs_hdi.png", width = 10, height = 7, dpi = 300)
