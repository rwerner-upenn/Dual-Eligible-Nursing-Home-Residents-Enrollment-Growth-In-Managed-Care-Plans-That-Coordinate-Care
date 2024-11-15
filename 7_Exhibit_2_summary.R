
### Exhibit 2: calculate proportions of plans by year
### Appendix Exhibit 1
### Appendix Exhibit 2


setwd("<path to analytic data>")

library(tableone)
options(max.print = 5000)

# import data 
stable = read.csv("./SNP_analytic_stable_240310.csv", header = TRUE, sep = ",")
stable = stable[which(stable$COVERAGE_CAT != 2 & stable$COVERAGE_CAT != 6), ]

# characteristics
coverage_var = c("COVERAGE_CAT", "INTEGRATED")

# balanced panel 
stabletable = CreateTableOne(vars = coverage_var, data = stable, test = FALSE, factorVars = coverage_var, includeNA = TRUE, strata = "YEAR")
stabletable_out = print(stabletable, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "fp", printToggle = FALSE)

write.csv(stabletable_out, file = "./SNP_stable_coverage_sample.csv")

