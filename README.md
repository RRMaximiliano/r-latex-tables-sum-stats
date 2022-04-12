
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Building Summary Statistics Tables with `modelsummary` and `gtsummary`

<!-- badges: start -->
<!-- badges: end -->

`modelsummary` and `gtsummary` are two excellent r packages to build
summary statistics. However, their syntax might not be fully intituitive
if you are comming from Stata. Here are a couple of examples using these
two packages.

First, let’s load the following packages and load our data:

``` r
library(tidyverse)
library(gtsummary)
library(modelsummary)
library(haven)

census <- read_dta("http://www.stata-press.com/data/r9/census.dta") %>%
  # Create dummy treatment
  mutate(
    rand = runif(n()),
    treatment = as.numeric(rand > 0.5)
  )
```

I’m using the census stata dta file for those who are familiar with this
Stata dataset.

## Model Summary

When it comes to model summary, we have two approaches: (1) a rapid data
summary, and (2) a more elaborated one. For the former, we use the
`datasummary_skim()` function as follows:

``` r
datasummary_skim(census)
```

|           | Unique (#) | Missing (%) |      Mean |        SD |      Min |    Median |        Max |
|:----------|-----------:|------------:|----------:|----------:|---------:|----------:|-----------:|
| region    |          4 |           0 |       2.7 |       1.1 |      1.0 |       3.0 |        4.0 |
| pop       |         50 |           0 | 4518149.4 | 4715037.8 | 401851.0 | 3066433.0 | 23667902.0 |
| poplt5    |         50 |           0 |  326277.8 |  331585.1 |  35998.0 |  227467.5 |  1708400.0 |
| pop5_17   |         50 |           0 |  945951.6 |  959372.8 |  91796.0 |  629654.0 |  4680558.0 |
| pop18p    |         50 |           0 | 3245920.1 | 3430531.3 | 271106.0 | 2175130.0 | 17278944.0 |
| pop65p    |         50 |           0 |  509502.8 |  538932.4 |  11547.0 |  370495.0 |  2414250.0 |
| popurban  |         50 |           0 | 3328253.2 | 4090177.9 | 172735.0 | 2156905.0 | 21607606.0 |
| medage    |         37 |           0 |      29.5 |       1.7 |     24.2 |      29.8 |       34.7 |
| death     |         50 |           0 |   39474.3 |   41742.3 |   1604.0 |   26176.5 |   186428.0 |
| marriage  |         50 |           0 |   47701.4 |   45130.4 |   4437.0 |   36279.0 |   210864.0 |
| divorce   |         50 |           0 |   23679.4 |   25094.0 |   2142.0 |   17112.5 |   133541.0 |
| rand      |         50 |           0 |       0.5 |       0.3 |      0.0 |       0.4 |        1.0 |
| treatment |          2 |           0 |       0.5 |       0.5 |      0.0 |       0.0 |        1.0 |

If we want to select only a few variables, we could past a variables
vector to the `select` function or create a new object with only the
variables we need.

``` r
census %>%
  select(pop, death, marriage, divorce) %>%
  datasummary_skim()
```

|          | Unique (#) | Missing (%) |      Mean |        SD |      Min |    Median |        Max |
|:---------|-----------:|------------:|----------:|----------:|---------:|----------:|-----------:|
| pop      |         50 |           0 | 4518149.4 | 4715037.8 | 401851.0 | 3066433.0 | 23667902.0 |
| death    |         50 |           0 |   39474.3 |   41742.3 |   1604.0 |   26176.5 |   186428.0 |
| marriage |         50 |           0 |   47701.4 |   45130.4 |   4437.0 |   36279.0 |   210864.0 |
| divorce  |         50 |           0 |   23679.4 |   25094.0 |   2142.0 |   17112.5 |   133541.0 |

In addition, we can let the function knows if we would like to have only
summary statistics for those variables that are either numeric or
categorical, for example:

``` r
datasummary_skim(census, type = "numeric")
```

If we would like to have only the mean, sd, min, max instead of all the
statistics that are presented using `datasummary_skim` we can use a
2-sided formula.

``` r
build <- pop + death + marriage + divorce ~ N + Mean + SD + Median + Min + Max 

## Without labels

datasummary(
  build,
  data = census
) 
```

|          |   N |       Mean |         SD |     Median |       Min |         Max |
|:---------|----:|-----------:|-----------:|-----------:|----------:|------------:|
| pop      |  50 | 4518149.44 | 4715037.75 | 3066433.00 | 401851.00 | 23667902.00 |
| death    |  50 |   39474.26 |   41742.35 |   26176.50 |   1604.00 |   186428.00 |
| marriage |  50 |   47701.40 |   45130.42 |   36279.00 |   4437.00 |   210864.00 |
| divorce  |  50 |   23679.44 |   25094.01 |   17112.50 |   2142.00 |   133541.00 |

In the case of variables labels, we will need to modify those variables
names.

``` r
## With labels

build <- `Population` + `Number of deaths` + `Number of marriages` + `Number of divorces` ~ N + Mean + SD + Median + Min + Max 

datasummary(
  build,
  data = census %>% 
    rename(`Population` = pop, `Number of deaths` = death, `Number of marriages` = marriage, `Number of divorces` = divorce)
) 
```

|                     |   N |       Mean |         SD |     Median |       Min |         Max |
|:--------------------|----:|-----------:|-----------:|-----------:|----------:|------------:|
| Population          |  50 | 4518149.44 | 4715037.75 | 3066433.00 | 401851.00 | 23667902.00 |
| Number of deaths    |  50 |   39474.26 |   41742.35 |   26176.50 |   1604.00 |   186428.00 |
| Number of marriages |  50 |   47701.40 |   45130.42 |   36279.00 |   4437.00 |   210864.00 |
| Number of divorces  |  50 |   23679.44 |   25094.01 |   17112.50 |   2142.00 |   133541.00 |

Finally, we can use the `output` argument to export our table to a
several file formats.

``` r
build <- pop + death + marriage + divorce ~ N + Mean + SD + Median + Min + Max 

datasummary(
  build,
  data = census,
  output = "latex"
) 
```

In the case of latex, your output would like this and you can use the
`\input` command in your latex document to add your table to your
reports or working papers:

    \begin{table}
    \centering
    \begin{tabular}[t]{lrrrrrr}
    \toprule
      & N & Mean & SD & Median & Min & Max\\
    \midrule
    pop & 50 & \num{4518149.44} & \num{4715037.75} & \num{3066433.00} & \num{401851.00} & \num{23667902.00}\\
    death & 50 & \num{39474.26} & \num{41742.35} & \num{26176.50} & \num{1604.00} & \num{186428.00}\\
    marriage & 50 & \num{47701.40} & \num{45130.42} & \num{36279.00} & \num{4437.00} & \num{210864.00}\\
    divorce & 50 & \num{23679.44} & \num{25094.01} & \num{17112.50} & \num{2142.00} & \num{133541.00}\\
    \bottomrule
    \end{tabular}
    \end{table}

Check the official official
[vignette](https://vincentarelbundock.github.io/modelsummary/articles/datasummary.html)
for more examples.

## GT Summary

`gtsummary` is another package that can be used for basic and complex
summary statistics. Its syntax follows the `gt` family. For a basic
summary statistics table, we can use the `tbl_summary()` function as
follows:

``` r
vars <- c("pop", "death", "marriage", "divorce")

census %>% 
  select(all_of(vars)) %>% 
  tbl_summary()
```

<div id="xtwzcxshvy" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#xtwzcxshvy .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#xtwzcxshvy .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#xtwzcxshvy .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#xtwzcxshvy .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#xtwzcxshvy .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xtwzcxshvy .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#xtwzcxshvy .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#xtwzcxshvy .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#xtwzcxshvy .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#xtwzcxshvy .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#xtwzcxshvy .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#xtwzcxshvy .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#xtwzcxshvy .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#xtwzcxshvy .gt_from_md > :first-child {
  margin-top: 0;
}

#xtwzcxshvy .gt_from_md > :last-child {
  margin-bottom: 0;
}

#xtwzcxshvy .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#xtwzcxshvy .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#xtwzcxshvy .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#xtwzcxshvy .gt_row_group_first td {
  border-top-width: 2px;
}

#xtwzcxshvy .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xtwzcxshvy .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#xtwzcxshvy .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#xtwzcxshvy .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xtwzcxshvy .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xtwzcxshvy .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#xtwzcxshvy .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#xtwzcxshvy .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xtwzcxshvy .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#xtwzcxshvy .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xtwzcxshvy .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#xtwzcxshvy .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xtwzcxshvy .gt_left {
  text-align: left;
}

#xtwzcxshvy .gt_center {
  text-align: center;
}

#xtwzcxshvy .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#xtwzcxshvy .gt_font_normal {
  font-weight: normal;
}

#xtwzcxshvy .gt_font_bold {
  font-weight: bold;
}

#xtwzcxshvy .gt_font_italic {
  font-style: italic;
}

#xtwzcxshvy .gt_super {
  font-size: 65%;
}

#xtwzcxshvy .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#xtwzcxshvy .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#xtwzcxshvy .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#xtwzcxshvy .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#xtwzcxshvy .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1"><strong>Characteristic</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1"><strong>N = 50</strong><sup class="gt_footnote_marks">1</sup></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">Population</td>
<td class="gt_row gt_center">3,066,433 (1,169,218, 5,434,033)</td></tr>
    <tr><td class="gt_row gt_left">Number of deaths</td>
<td class="gt_row gt_center">26,176 (9,087, 46,532)</td></tr>
    <tr><td class="gt_row gt_left">Number of marriages</td>
<td class="gt_row gt_center">36,279 (14,840, 57,338)</td></tr>
    <tr><td class="gt_row gt_left">Number of divorces</td>
<td class="gt_row gt_center">17,112 (6,898, 27,986)</td></tr>
  </tbody>
  
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="2"><sup class="gt_footnote_marks">1</sup> Median (IQR)</td>
    </tr>
  </tfoot>
</table>
</div>

By treatment variable and p-value:

``` r
census %>% 
  select(all_of(vars), treatment) %>% 
  tbl_summary(by = treatment) %>% 
  add_p()
```

<div id="ldsukazhbg" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ldsukazhbg .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ldsukazhbg .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ldsukazhbg .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ldsukazhbg .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ldsukazhbg .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ldsukazhbg .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ldsukazhbg .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ldsukazhbg .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ldsukazhbg .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ldsukazhbg .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ldsukazhbg .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ldsukazhbg .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#ldsukazhbg .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ldsukazhbg .gt_from_md > :first-child {
  margin-top: 0;
}

#ldsukazhbg .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ldsukazhbg .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ldsukazhbg .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ldsukazhbg .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ldsukazhbg .gt_row_group_first td {
  border-top-width: 2px;
}

#ldsukazhbg .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ldsukazhbg .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ldsukazhbg .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ldsukazhbg .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ldsukazhbg .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ldsukazhbg .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ldsukazhbg .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ldsukazhbg .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ldsukazhbg .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ldsukazhbg .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ldsukazhbg .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ldsukazhbg .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ldsukazhbg .gt_left {
  text-align: left;
}

#ldsukazhbg .gt_center {
  text-align: center;
}

#ldsukazhbg .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ldsukazhbg .gt_font_normal {
  font-weight: normal;
}

#ldsukazhbg .gt_font_bold {
  font-weight: bold;
}

#ldsukazhbg .gt_font_italic {
  font-style: italic;
}

#ldsukazhbg .gt_super {
  font-size: 65%;
}

#ldsukazhbg .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#ldsukazhbg .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ldsukazhbg .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#ldsukazhbg .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#ldsukazhbg .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1"><strong>Characteristic</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1"><strong>0</strong>, N = 27<sup class="gt_footnote_marks">1</sup></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1"><strong>1</strong>, N = 23<sup class="gt_footnote_marks">1</sup></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1"><strong>p-value</strong><sup class="gt_footnote_marks">2</sup></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">Population</td>
<td class="gt_row gt_center">3,107,576 (1,292,848, 7,376,151)</td>
<td class="gt_row gt_center">2,718,215 (1,125,024, 5,026,292)</td>
<td class="gt_row gt_center">0.7</td></tr>
    <tr><td class="gt_row gt_left">Number of deaths</td>
<td class="gt_row gt_center">28,227 (9,436, 62,216)</td>
<td class="gt_row gt_center">23,570 (9,158, 41,604)</td>
<td class="gt_row gt_center">0.7</td></tr>
    <tr><td class="gt_row gt_left">Number of marriages</td>
<td class="gt_row gt_center">34,917 (14,499, 72,376)</td>
<td class="gt_row gt_center">41,111 (15,440, 54,854)</td>
<td class="gt_row gt_center">>0.9</td></tr>
    <tr><td class="gt_row gt_left">Number of divorces</td>
<td class="gt_row gt_center">16,731 (7,004, 37,464)</td>
<td class="gt_row gt_center">17,546 (8,511, 25,180)</td>
<td class="gt_row gt_center">0.7</td></tr>
  </tbody>
  
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="4"><sup class="gt_footnote_marks">1</sup> Median (IQR)</td>
    </tr>
    <tr>
      <td class="gt_footnote" colspan="4"><sup class="gt_footnote_marks">2</sup> Wilcoxon rank sum exact test</td>
    </tr>
  </tfoot>
</table>
</div>

Given that we would like to have a more econ-paper type of descriptive
statistics, we can pass the columns we would like to have in a
vectorized way.

``` r
cols <- c(N = "{N_nonmiss}", Mean = "{mean} ({sd})", Median = "{median}", Min = "{min}", Max = "{max}")

cols %>% 
  # we would go through each of these columns
  imap(
    ~ census %>% 
      # and select the variables we need in our table
      select(all_of(vars)) %>% 
      tbl_summary(
        statistic = all_continuous() ~ .x
      ) %>% 
      # We will modify the title of cols headers
      modify_header(stat_0 ~ str_glue("{.y}"), label ~ "Variables") 
  ) %>% 
  # and merge every single of the columns into one single table
  tbl_merge() %>% 
  # remove spanning headers and footnote
  modify_spanning_header(everything() ~ NA) %>%
  modify_footnote(everything() ~ NA) 
```

<div id="kfwuiitacg" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#kfwuiitacg .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#kfwuiitacg .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kfwuiitacg .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#kfwuiitacg .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#kfwuiitacg .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kfwuiitacg .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kfwuiitacg .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#kfwuiitacg .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#kfwuiitacg .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#kfwuiitacg .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#kfwuiitacg .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#kfwuiitacg .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#kfwuiitacg .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#kfwuiitacg .gt_from_md > :first-child {
  margin-top: 0;
}

#kfwuiitacg .gt_from_md > :last-child {
  margin-bottom: 0;
}

#kfwuiitacg .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#kfwuiitacg .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#kfwuiitacg .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#kfwuiitacg .gt_row_group_first td {
  border-top-width: 2px;
}

#kfwuiitacg .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kfwuiitacg .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#kfwuiitacg .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#kfwuiitacg .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kfwuiitacg .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kfwuiitacg .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#kfwuiitacg .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#kfwuiitacg .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kfwuiitacg .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kfwuiitacg .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#kfwuiitacg .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kfwuiitacg .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#kfwuiitacg .gt_left {
  text-align: left;
}

#kfwuiitacg .gt_center {
  text-align: center;
}

#kfwuiitacg .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#kfwuiitacg .gt_font_normal {
  font-weight: normal;
}

#kfwuiitacg .gt_font_bold {
  font-weight: bold;
}

#kfwuiitacg .gt_font_italic {
  font-style: italic;
}

#kfwuiitacg .gt_super {
  font-size: 65%;
}

#kfwuiitacg .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#kfwuiitacg .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#kfwuiitacg .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#kfwuiitacg .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#kfwuiitacg .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Variables</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">N</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">Mean</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">Median</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">Min</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1">Max</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">Population</td>
<td class="gt_row gt_center">50</td>
<td class="gt_row gt_center">4,518,149 (4,715,038)</td>
<td class="gt_row gt_center">3,066,433</td>
<td class="gt_row gt_center">401,851</td>
<td class="gt_row gt_center">23,667,902</td></tr>
    <tr><td class="gt_row gt_left">Number of deaths</td>
<td class="gt_row gt_center">50</td>
<td class="gt_row gt_center">39,474 (41,742)</td>
<td class="gt_row gt_center">26,176</td>
<td class="gt_row gt_center">1,604</td>
<td class="gt_row gt_center">186,428</td></tr>
    <tr><td class="gt_row gt_left">Number of marriages</td>
<td class="gt_row gt_center">50</td>
<td class="gt_row gt_center">47,701 (45,130)</td>
<td class="gt_row gt_center">36,279</td>
<td class="gt_row gt_center">4,437</td>
<td class="gt_row gt_center">210,864</td></tr>
    <tr><td class="gt_row gt_left">Number of divorces</td>
<td class="gt_row gt_center">50</td>
<td class="gt_row gt_center">23,679 (25,094)</td>
<td class="gt_row gt_center">17,112</td>
<td class="gt_row gt_center">2,142</td>
<td class="gt_row gt_center">133,541</td></tr>
  </tbody>
  
  
</table>
</div>

And, finally, we can use the `as_kable_extra` function to export our
table to latex. The full example is here below:

``` r
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
  )
```

That gives you the following latex:

    \begin{tabular}{lccccc}
    \toprule
    Variables & N & Mean & Median & Min & Max\\
    \midrule
    Population & 50 & 4,518,149 (4,715,038) & 3,066,433 & 401,851 & 23,667,902\\
    Number of deaths & 50 & 39,474 (41,742) & 26,176 & 1,604 & 186,428\\
    Number of marriages & 50 & 47,701 (45,130) & 36,279 & 4,437 & 210,864\\
    Number of divorces & 50 & 23,679 (25,094) & 17,112 & 2,142 & 133,541\\
    \bottomrule
    \end{tabular}

Check the official official
[vignette](https://www.danieldsjoberg.com/gtsummary/articles/tbl_summary.html)
for more examples.

## PDF Example

A compiled PDF example of some of the tables that were created here can
be found
[here](https://rawcdn.githack.com/RRMaximiliano/r-latex-tables-sum-stats/e8a5d1e465163620d13172f03e59479b3ab11201/outputs/r-tables-sum-stats.pdf)
