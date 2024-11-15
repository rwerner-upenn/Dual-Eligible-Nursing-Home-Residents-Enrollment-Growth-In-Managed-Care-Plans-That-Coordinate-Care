
setwd("<path to analytic data")
library(tableone)
options(max.print = 5000)

# import data 
sample = read.csv("./mds_2019_2020_w_fac_info_updated.csv", header = TRUE, sep = ",")
dput(names(sample))

metro = sample[which(sample$METRO == 1), ]
nonmetro = sample[which(sample$METRO == 0), ]

# characteristics

fac_var = c(
 "TOTBEDS_NUM"
, "PROFIT"
, "MULTIFAC"
, "METRO"
, "REGION_FAC"
, "MA_PENETRATION"
, "SDI_SCORE"
, "PAYMCAID"
, "PCT_FEMALE"
, "MEAN_AGE"
, "PCT_WHITE"
, "PCT_BLACK"
, "PCT_HISPANIC"
, "PCT_ASIAN"
, "AVG_ADL"
, "AVG_CHESS"
)

fac_catvar = c(
 "PROFIT"
, "MULTIFAC"
, "METRO"
, "REGION_FAC"	
)


# NH level summary: by quartile, overall and by metro/non-metro

isnp_q = CreateTableOne(vars = fac_var, data = sample, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_I_SNP")
isnp_q_out = print(isnp_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)

integrated_q = CreateTableOne(vars = fac_var, data = sample, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_INTEGRATED")
integrated_q_out = print(integrated_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)

toexport = cbind(isnp_q_out, integrated_q_out)

write.csv(toexport, file = "./SNP_NH_by_penetration_quartile_updated.csv")


overall_metro = CreateTableOne(vars = fac_var, data = metro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE)
overall_metro_out = print(overall_metro, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)


isnp_q = CreateTableOne(vars = fac_var, data = metro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_I_SNP")
isnp_q_out = print(isnp_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)

integrated_q = CreateTableOne(vars = fac_var, data = metro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_INTEGRATED")
integrated_q_out = print(integrated_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)


toexport_metro = cbind(overall_metro_out, isnp_q_out, integrated_q_out)

write.csv(toexport_metro, file = "./SNP_NH_by_penetration_quartile_metro_updated.csv")


overall_nonmetro = CreateTableOne(vars = fac_var, data = nonmetro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE)
overall_nonmetro_out = print(overall_nonmetro, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)


isnp_q = CreateTableOne(vars = fac_var, data = nonmetro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_I_SNP")
isnp_q_out = print(isnp_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)

integrated_q = CreateTableOne(vars = fac_var, data = nonmetro, test = FALSE, factorVars = fac_catvar, includeNA = TRUE, strata = "QUARTILE_INTEGRATED")
integrated_q_out = print(integrated_q, showAllLevels = FALSE, contDigits = 1, catDigits = 1, quote = FALSE, noSpaces = TRUE, format = "p", printToggle = FALSE)


toexport_nonmetro = cbind(overall_nonmetro_out, isnp_q_out, integrated_q_out)

write.csv(toexport_nonmetro, file = "./SNP_NH_by_penetration_quartile_nonmetro_updated.csv")


