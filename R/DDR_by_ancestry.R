.libPaths(c("~/Documents/Rpackagesv2", .libPaths()))
library(tidyverse)
library(viridis)

# import damage scores --------------------------------------------------------

## precalculated by Knijnenburg et al. 

ddr <- "https://github.com/GerkeLab/TCGAhrd/raw/master/data/intermediateFIles/DDRscores.RData"
load(url(ddr))

## DDR (DNA damage repair) missing for n=2685

rm(ddr)

# import ancestry info --------------------------------------------------------

ancestry <- "https://github.com/GerkeLab/TCGAancestry/raw/master/data/admixture_calls.txt"
dat_ancestry <- read.table(ancestry, sep="\t", header = TRUE)

dat_ancestry <- dat_ancestry %>%
  filter(tissue %in% c("Primary Solid Tumor",
                       "Primary Blood Derived Cancer - Peripheral Blood",
                       "Metastatic")) %>%
  mutate(barcode = case_when(
    tissue == "Primary Solid Tumor" ~ paste0(ID, "-01"),
    tissue == "Primary Blood Derived Cancer - Peripheral Blood" ~ paste0(ID, "-03"),
    tissue == "Metastatic" ~ paste0(ID, "-06")
  ))

rm(ancestry)

# combine data ----------------------------------------------------------------

full <- dat %>% 
  select(patient_id, acronym, rppa_ddr_score) %>% 
  left_join(dat_ancestry %>% select(barcode, POP:AFR),
            by = c("patient_id" = "barcode"))

rm(dat, dat_ancestry)

# basic plotting --------------------------------------------------------------

ggplot(full, aes(x = POP, y = rppa_ddr_score, fill = as.factor(POP))) + 
  scale_fill_manual(values = rep("white",length(unique(full$POP)))) +
  geom_jitter(position = position_jitterdodge(jitter.width = .95,
                                              jitter.height = 0,
                                              dodge.width = .95),
              aes(fill = as.factor(POP), col = as.factor(POP)), alpha = 0.5) + 
  geom_boxplot(outlier.shape = NA, alpha = 0) + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black")) + 
  guides(fill=FALSE, colour=FALSE) +
  labs(x = "Ancestral Population", y = "DDR Score") + 
  scale_color_viridis_d() + 
  facet_wrap(~acronym)
