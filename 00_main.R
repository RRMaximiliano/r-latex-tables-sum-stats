# Packages ----------------------------------------------------------------

library(tidyverse)
library(gtsummary)
library(modelsummary)
library(fixest)
library(gt)
library(haven)
library(vtable)

# Load data ---------------------------------------------------------------

census <- read_dta("http://www.stata-press.com/data/r9/census.dta") %>%
  # Create dummy treatment
  mutate(
    rand = runif(nrow(census)),
    treatment = as.numeric(rand > 0.5)
  ) 

# GT Summary --------------------------------------------------------------

vars <- c("pop", "death", "marriage", "divorce")
cols <- c(N = "{N_nonmiss}", Mean = "{mean} ({sd})", Median = "{median}", Min = "{min}", Max = "{max}")
  
## Regular summ stats
tab1 <- cols %>% 
  imap(
    ~ census %>% 
      select(all_of(vars)) %>% 
      tbl_summary(
        statistic = all_continuous() ~ .x
      ) %>% 
      modify_header(stat_0 ~ str_glue("{.y}"), label ~ "Variables") 
  ) %>% 
  tbl_merge() %>% 
  # remove spanning headers and footnote
  modify_spanning_header(everything() ~ NA) %>%
  modify_footnote(everything() ~ NA) 

tab1 %>%
  as_kable_extra(
    format = "latex", 
    booktabs = TRUE, 
    linesep = ""
  ) %>% 
  cat(file = here::here("outputs", "tables", "tab1.tex"))

## By treatment

tab2 <- census %>%
  select(all_of(vars), treatment) %>% 
  tbl_summary(
    by = treatment,
    statistic = ~ "{mean} ({sd})"
  ) %>% 
  modify_header(label ~  "Variable", stat_1 ~  "Control, N = {n}", stat_2 = "Treatment, N = {n}") %>% 
  add_overall() %>% 
  add_p(pvalue_fun = ~style_pvalue(.x, digits = 2)) %>%
  modify_footnote(everything() ~ NA)

tab2 %>%
  as_kable_extra(
    format = "latex", 
    booktabs = TRUE, 
    linesep = ""
  ) %>% 
  cat(file = here::here("outputs", "tables", "tab2.tex"))

## By treatment without overall

tab3 <- census %>%
  select(all_of(vars), treatment) %>% 
  tbl_summary(
    by = treatment,
    statistic = ~ "{mean} ({sd})"
  ) %>% 
  modify_header(label ~  "Variable", stat_1 ~  "Control, N = {n}", stat_2 = "Treatment, N = {n}") %>% 
  add_p(pvalue_fun = ~style_pvalue(.x, digits = 2)) %>%
  modify_footnote(everything() ~ NA)

tab3 %>% 
  as_kable_extra(
    format = "latex", 
    booktabs = TRUE, 
    linesep = ""
  ) %>% 
  cat(file = here::here("outputs", "tables", "tab3.tex"))

# Model Summary -----------------------------------------------------------

build <- pop + death + marriage + divorce ~ N + Mean + SD + Median + Min + Max 

## Without labels

datasummary(
  build,
  data = census,
  output = "latex"
) %>%
  gsub("^.*?&","Variables &", .) %>% 
  gsub("[\\\\][bottomrule][^ ]+$", "", .) %>% 
  cat(file = here::here("outputs", "tables", "tab1_modsum.tex"))

## With labels

build <- `Population` + `Number of deaths` + `Number of marriages` + `Number of divorces` ~ N + Mean + SD + Median + Min + Max 

datasummary(
  build,
  data = census %>% 
    rename(`Population` = pop, `Number of deaths` = death, `Number of marriages` = marriage, `Number of divorces` = divorce),
  output = "latex"
) %>%
  gsub("^.*?&","Variables &", .) %>% 
  gsub("[\\\\][bottomrule][^ ]+$", "", .) %>% 
  cat(file = here::here("outputs", "tables", "tab1_modsum_labels.tex"))
