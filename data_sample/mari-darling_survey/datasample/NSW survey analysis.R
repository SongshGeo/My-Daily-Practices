### IMPORT DATASETS

setwd("~/Google Drive/Working Papers/00 Groundwater Commons Game (NATURE)/NSW Survey Data")
df_NSW=read.csv("raw.csv")

### SELECT GRID/GROUP QUESTIONS
grid_questions <- c("q3law","q1sus","q1pro","q1com","q3ill")
group_questions <- c("q3lic","q3rep","q3econ")
M_questions <- c("q2off","q3pro")
F_questions <- c("q3det","q3crim")
C_questions <- c("q3big")

#####################################################
########### ALL REGIONS POOLED TOGETHER  ############
#####################################################

### EXTRACT GRID/GROUP DATAFRAMES
df_grid_NSW <- subset(x=df_NSW, select = grid_questions)
df_group_NSW <- subset(x=df_NSW, select = group_questions)
df_M_NSW <- subset(x=df_NSW, select = M_questions)
df_F_NSW <- subset(x=df_NSW, select = F_questions)
df_C_NSW <- subset(x=df_NSW, select = C_questions)

#HOUSEKEEPING NON-RESPONSES
df_grid_NSW[df_grid_NSW == 6] <- NA
df_group_NSW[df_group_NSW == 6] <- NA
df_M_NSW[df_M_NSW == 6] <- NA
df_F_NSW[df_F_NSW == 6] <- NA
df_C_NSW[df_C_NSW == 6] <- NA

#KEEP COMPLETE CASES
df_grid_NSW <- df_grid_NSW[complete.cases(df_grid_NSW),]
df_group_NSW <- df_group_NSW[complete.cases(df_group_NSW),]
df_M_NSW <- df_M_NSW[complete.cases(df_M_NSW),]
df_F_NSW <- df_F_NSW[complete.cases(df_F_NSW),]
df_C_NSW <- df_C_NSW[complete.cases(df_C_NSW),]

#REVERSE SCALE WHERE NEEDED
df_grid_NSW$q1sus <- sapply(df_grid_NSW$q1sus,function(x){6-x})
df_grid_NSW$q1pro <- sapply(df_grid_NSW$q1pro,function(x){6-x})
df_grid_NSW$q1com <- sapply(df_grid_NSW$q1com,function(x){6-x})
df_grid_NSW$q3ill <- sapply(df_grid_NSW$q3ill,function(x){6-x})
df_group_NSW$q3econ <- sapply(df_group_NSW$q3econ,function(x){6-x})
#df_C_NSW <- sapply(df_C_NSW,function(x){6-x})

grid_scores=data.frame(grid=rowMeans(df_grid_NSW,na.rm = TRUE))
group_scores=data.frame(group=rowMeans(df_group_NSW,na.rm = TRUE))
M_scores=data.frame(group=rowMeans(df_M_NSW,na.rm = TRUE))
F_scores=data.frame(group=rowMeans(df_F_NSW,na.rm = TRUE))

grid_scores_NSW <- data.frame(sapply(grid_scores,function(x){(x-1)/(5-1)}))
group_scores_NSW <- data.frame(sapply(group_scores,function(x){(x-1)/(5-1)}))
M_scores_NSW <- data.frame(sapply(M_scores,function(x){(x-1)/(5-1)}))
F_scores_NSW <- data.frame(sapply(F_scores,function(x){(x-1)/(5-1)}))
C_scores_NSW <- sapply(df_C_NSW,function(x){(x-1)/(5-1)})

describe(C_scores_NSW)
describe(M_scores_NSW)
describe(F_scores_NSW)

grid_scores_NSW["survey"] <- "NSW"
group_scores_NSW["survey"] <- "NSW"

################# WVS6 DATASET #################

grid_scores <- subset(df_grid, subset = (V2 == 36))
group_scores <- subset(df_group, subset = (V2 == 36))

grid_scores=data.frame(grid=rowMeans(grid_scores[-1],na.rm = TRUE))
group_scores=data.frame(group=rowMeans(group_scores[-1],na.rm = TRUE))

#grid_scores_WVS["survey"] <- "WVS"
#group_scores_WVS["survey"] <- "WVS"

################# BIND WVS AND NSW #################

#grid_ALL=rbind(grid_scores_WVS,grid_scores_NSW)
#group_ALL=rbind(group_scores_WVS,group_scores_NSW)

t.test(grid_scores_NSW$grid,grid_scores$grid)
t.test(group_scores_NSW$group,group_scores$group)

mean(grid_scores_NSW$grid)
mean(group_scores_NSW$group)

# ###################################
# ########### NC REGION  ############
# ###################################
# 
# df_NSW=read.csv("raw_regions.csv")
# 
# ### EXTRACT GRID/GROUP DATAFRAMES
# df_grid_NC <- subset(x=df_NSW, subset=region == "NC", select = grid_questions)
# df_group_NC <- subset(x=df_NSW, subset=region == "NC", select = group_questions)
# 
# #HOUSEKEEPING NON-RESPONSES
# df_grid_NC[df_grid_NC == 6] <- NA
# df_group_NC[df_group_NC == 6] <- NA
# 
# #KEEP COMPLETE CASES
# df_grid_NC <- df_grid_NC[complete.cases(df_grid_NC),]
# df_group_NC <- df_group_NC[complete.cases(df_group_NC),]
# 
# #REVERSE SCALE WHERE NEEDED
# df_grid_NC$q1sus <- sapply(df_grid_NC$q1sus,function(x){6-x})
# df_grid_NC$q1pro <- sapply(df_grid_NC$q1pro,function(x){6-x})
# df_grid_NC$q1com <- sapply(df_grid_NC$q1com,function(x){6-x})
# df_grid_NC$q3ill <- sapply(df_grid_NC$q3ill,function(x){6-x})
# df_group_NC$q3econ <- sapply(df_group_NC$q3econ,function(x){6-x})
# 
# grid_scores=data.frame(grid=rowMeans(df_grid_NC,na.rm = TRUE))
# group_scores=data.frame(group=rowMeans(df_group_NC,na.rm = TRUE))
# 
# grid_scores_NC <- data.frame(sapply(grid_scores,function(x){(x-1)/(5-1)}))
# group_scores_NC <- data.frame(sapply(group_scores,function(x){(x-1)/(5-1)}))
# 
# grid_scores_NC["survey"] <- "NC"
# group_scores_NC["survey"] <- "NC"
# 
# mean(grid_scores_NC$grid)
# mean(group_scores_NC$group)
# 
# ###################################
# ########### CW REGION  ############
# ###################################
# 
# df_NSW=read.csv("raw_regions.csv")
# 
# ### EXTRACT GRID/GROUP DATAFRAMES
# df_grid_CW <- subset(x=df_NSW, subset=region == "CW", select = grid_questions)
# df_group_CW <- subset(x=df_NSW, subset=region == "CW", select = group_questions)
# 
# #HOUSEKEEPING NON-RESPONSES
# df_grid_CW[df_grid_CW == 6] <- NA
# df_group_CW[df_group_CW == 6] <- NA
# 
# #KEEP COMPLETE CASES
# df_grid_CW <- df_grid_CW[complete.cases(df_grid_CW),]
# df_group_CW <- df_group_CW[complete.cases(df_group_CW),]
# 
# #REVERSE SCALE WHERE NEEDED
# df_grid_CW$q1sus <- sapply(df_grid_CW$q1sus,function(x){6-x})
# df_grid_CW$q1pro <- sapply(df_grid_CW$q1pro,function(x){6-x})
# df_grid_CW$q1com <- sapply(df_grid_CW$q1com,function(x){6-x})
# df_grid_CW$q3ill <- sapply(df_grid_CW$q3ill,function(x){6-x})
# df_group_CW$q3econ <- sapply(df_group_CW$q3econ,function(x){6-x})
# 
# grid_scores=data.frame(grid=rowMeans(df_grid_CW,na.rm = TRUE))
# group_scores=data.frame(group=rowMeans(df_group_CW,na.rm = TRUE))
# 
# grid_scores_CW <- data.frame(sapply(grid_scores,function(x){(x-1)/(5-1)}))
# group_scores_CW <- data.frame(sapply(group_scores,function(x){(x-1)/(5-1)}))
# 
# grid_scores_CW["survey"] <- "CW"
# group_scores_CW["survey"] <- "CW"
# 
# mean(grid_scores_CW$grid)
# mean(group_scores_CW$group)
# 
# ###################################
# ########### MM REGION  ############
# ###################################
# 
# df_NSW=read.csv("raw_regions.csv")
# 
# ### EXTRACT GRID/GROUP DATAFRAMES
# df_grid_MM <- subset(x=df_NSW, subset=region == "MM", select = grid_questions)
# df_group_MM <- subset(x=df_NSW, subset=region == "MM", select = group_questions)
# 
# #HOUSEKEEPING NON-RESPONSES
# df_grid_MM[df_grid_MM == 6] <- NA
# df_group_MM[df_group_MM == 6] <- NA
# 
# #KEEP COMPLETE CASES
# df_grid_MM <- df_grid_MM[complete.cases(df_grid_MM),]
# df_group_MM <- df_group_MM[complete.cases(df_group_MM),]
# 
# #REVERSE SCALE WHERE NEEDED
# df_grid_MM$q1sus <- sapply(df_grid_MM$q1sus,function(x){6-x})
# df_grid_MM$q1pro <- sapply(df_grid_MM$q1pro,function(x){6-x})
# df_grid_MM$q1com <- sapply(df_grid_MM$q1com,function(x){6-x})
# df_grid_MM$q3ill <- sapply(df_grid_MM$q3ill,function(x){6-x})
# df_group_MM$q3econ <- sapply(df_group_MM$q3econ,function(x){6-x})
# 
# grid_scores=data.frame(grid=rowMeans(df_grid_MM,na.rm = TRUE))
# group_scores=data.frame(group=rowMeans(df_group_MM,na.rm = TRUE))
# 
# grid_scores_MM <- data.frame(sapply(grid_scores,function(x){(x-1)/(5-1)}))
# group_scores_MM <- data.frame(sapply(group_scores,function(x){(x-1)/(5-1)}))
# 
# grid_scores_MM["survey"] <- "MM"
# group_scores_MM["survey"] <- "MM"
# 
# mean(grid_scores_MM$grid)
# mean(group_scores_MM$group)

########################################################
########### GRID-GROUP VALIDATION BOXPLOTS  ############
########################################################

selectrows_grid=temp_grid_df[temp_grid_df$Country=="Australia",]
selectrows_group=temp_group_df[temp_group_df$Country=="Australia",]

selectrows_grid <- selectrows_grid["Grid.score"]
selectrows_group <- selectrows_group["Group.score"]

selectrows_grid$cultdim="grid"
selectrows_group$cultdim="group"
selectrows_grid$source="WVS"
selectrows_group$source="WVS"

names(selectrows_grid)=c("score","cultdim","source")
names(selectrows_group)=c("score","cultdim","source")

grid_scores_NSW$cultdim="grid"
group_scores_NSW$cultdim="group"
grid_scores_NSW$source="MDB surveys"
group_scores_NSW$source="MDB surveys"

names(grid_scores_NSW)=c("score","cultdim","source")
names(group_scores_NSW)=c("score","cultdim","source")

ALL_scores <- rbind(grid_scores_NSW,group_scores_NSW,selectrows_grid,selectrows_group)  

ALL_scores$f1f2 <- interaction(ALL_scores$cultdim, ALL_scores$source)

p <- ggplot(ALL_scores,aes(x=cultdim,fill=source, y=score))
p + 
  geom_boxplot() +
  labs(x="cultural dimension") +
  theme(axis.title = element_text(size = 14, face="bold"))
  

########################################################
########### COMPLIANCE VALIDATION BOXPLOTS  ############
########################################################

compliance_max_GCG=0.6
compliance_min_GCG=0.5

############################################
########### SUMMARY STATISTICS  ############
############################################

summary(M_scores_NSW)
summary(F_scores_NSW)
summary(C_scores_NSW)

describe(M_scores_NSW)
describe(F_scores_NSW)
describe(C_scores_NSW)

