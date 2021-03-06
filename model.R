if (getwd() != "/Users/stephenmortensen/Documents/DSI/Capstone/Data") {
  setwd("/Users/stephenmortensen/Documents/DSI/Capstone/Data")}
getwd()

library(readr)
library(tidyverse)
library(lubridate)
library(ROSE)
library(caret)
library(randomForest)

# Read in data===================================================================================================================

data_raw <- read.csv("Oppty_Acct_df.csv")

# Preprocessing==================================================================================================================

# Filter to only closed deals
data_closed = data_raw %>% filter(CLOSED__C==1)

# Select relevant variables
target = c("WON__C")
features = c("AMOUNT",
             "Code_1",
             "TYPE",
             "CORE_RECORD_TYPE__C",
             "ENTERPRISE_ACCOUNT__C_x",
             "ACCOUNT_TIER__C",
             "ACCOUNT_TYPE__C",
             "CUSTOMER_CLASSIFICATION__C",
             "OPENTIME",
             "LASTACTTIME",
             "VALID_OPENTIME",
             "FIELDS_COMPLETED",
             "TASK_COUNT",
             "DIVISION__C",
             "Code_2",
             "Code_industry")
table(data_raw$OWNER_REGION__C)
all_variables = append(target,features)
data = data_closed %>% select(all_variables)

# Create test and train sets
set.seed(123)
train_idx = createDataPartition(data$WON__C, p = 0.5, list=FALSE)
train = data[train_idx,]
test = data[-train_idx,]

# Modeling=======================================================================================================================

# Establish win rate baseline
win_tbl = table(data$WON__C)
(win_pct = win_tbl[2]/sum(win_tbl))*100

# Logistic regression-----------------------------------------------------
start.time = Sys.time()
train.glm = glm(WON__C ~ .,
                data = train, family=binomial(link = "logit"))
print(Sys.time() - start.time)

print(summary(train.glm))

# Prediction and accuracy
predict.glm = predict(train.glm, newdata = test, type='response')
# Confusion matrix
conf_mat.glm = table(test$WON__C, predict.glm > 0.55)
print(conf_mat.glm)
# Loss accuracy
print(conf_mat.glm[1,1]/sum(conf_mat.glm[1,]))
# Win accuracy
print(conf_mat.glm[2,2]/sum(conf_mat.glm[2,]))
# Overall accuracy
print((conf_mat.glm[2,2] + conf_mat.glm[1,1])/sum(conf_mat.glm))

# Percentage of test data being predicted on
sum(conf_mat.glm)/nrow(test)

# Random forest - note: takes ~25 minutes to run--------------------------
start.time = Sys.time()
train.rf = randomForest(WON__C ~ .,
                        data = train, na.action=na.exclude, importance=T)
print(Sys.time() - start.time)

# Importance plot
varImpPlot(train.rf, type=1, color="black", lcolor="black")

# Prediction and accuracy
predict.rf = predict(train.rf, test, predict.all=TRUE)$aggregate
# Confusion matrix
conf_mat.rf = table(test$WON__C, predict.rf > 0.55)
print(conf_mat.rf)
# Loss accuracy
print(conf_mat.rf[1,1]/sum(conf_mat.rf[1,]))
# Win accuracy
print(conf_mat.rf[2,2]/sum(conf_mat.rf[2,]))
# Overall accuracy
print((conf_mat.rf[2,2] + conf_mat.rf[1,1])/sum(conf_mat.rf))

# Percentage of test data being predicted on
sum(conf_mat.rf)/nrow(test)

#Division-level Modeling=======================================================================================================

# Identify divisions, specify variables by division
divisions = levels(data$DIVISION__C)
BEV_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry")
BRA_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry"
                  )
COR_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry")
FLD_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry")
MD_variables = c("AMOUNT",
                 "Code_1",
                 "TYPE",
                 "CORE_RECORD_TYPE__C",
                 "ENTERPRISE_ACCOUNT__C_x",
                 "ACCOUNT_TIER__C",
                 "ACCOUNT_TYPE__C",
                 "CUSTOMER_CLASSIFICATION__C",
                 # "OPENTIME",
                 # "LASTACTTIME",
                 # "VALID_OPENTIME",
                 # "FIELDS_COMPLETED",
                 # "TASK_COUNT",
                 "Code_2",
                 "Code_industry")
MPS_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry")
Other_variables = c("AMOUNT",
                    "Code_1",
                    "TYPE",
                    "CORE_RECORD_TYPE__C",
                    "ENTERPRISE_ACCOUNT__C_x",
                    "ACCOUNT_TIER__C",
                    "ACCOUNT_TYPE__C",
                    "CUSTOMER_CLASSIFICATION__C",
                    # "OPENTIME",
                    # "LASTACTTIME",
                    # "VALID_OPENTIME",
                    # "FIELDS_COMPLETED",
                    # "TASK_COUNT",
                    "Code_2",
                    "Code_industry"
                    )
PPD_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry"
                  )
RTS_variables = c("AMOUNT",
                  "Code_1",
                  "TYPE",
                  "CORE_RECORD_TYPE__C",
                  "ENTERPRISE_ACCOUNT__C_x",
                  "ACCOUNT_TIER__C",
                  "ACCOUNT_TYPE__C",
                  "CUSTOMER_CLASSIFICATION__C",
                  # "OPENTIME",
                  # "LASTACTTIME",
                  # "VALID_OPENTIME",
                  # "FIELDS_COMPLETED",
                  # "TASK_COUNT",
                  "Code_2",
                  "Code_industry")
variables = list("BEV"=BEV_variables,
             "BRA"=BRA_variables,
             "COR"=COR_variables,
             "FLD"=FLD_variables,
             "MD"=MD_variables,
             "MPS"=MPS_variables,
             "Other"=Other_variables,
             "PPD"=PPD_variables,
             "RTS"=RTS_variables)

# Initialize accuracy and importance lists
loss_acc = list()
win_acc = list()
total_acc = list()
importance = list()
accuracy.df = data.frame(matrix(NA,nrow=length(divisions),ncol=5))
names(accuracy.df) = c("division","false_positive","true_negative","true_positive","false_negative")

# Loop through random forest model for each division
start.time = Sys.time()
for(i in 1:length(divisions)){
  print(divisions[i])
  # Select variables and filter data by division
  data.tmp = data_closed %>% filter(DIVISION__C == divisions[i]) %>% select(append(target,variables[[divisions[i]]]))
  print(sprintf("%i rows",nrow(data.tmp)))
  # Create training and testing data
  set.seed(123)
  train_idx.tmp = createDataPartition(data.tmp$WON__C, p = 0.5, list=FALSE)
  train.tmp = data.tmp[train_idx.tmp,]
  test.tmp = data.tmp[-train_idx.tmp,]
  # Run random forest model (and time it)
  rf.start.time = Sys.time()
  train.rf = randomForest(WON__C ~ .,
                          data = train.tmp, na.action=na.exclude, importance=T)
  print(Sys.time() - rf.start.time)
  
  # Importance plot
  varImpPlot(train.rf, type=1, color="black", lcolor="black", main=paste(divisions[i]," Importance"))
  # Record in dictionary
  importance[[divisions[i]]] = importance(train.rf)
  
  # Prediction and accuracy
  predict.rf = predict(train.rf, test.tmp, predict.all=TRUE)$aggregate
  # Confusion matrix
  conf_mat.rf = table(test.tmp$WON__C, predict.rf > 0.55)
  accuracy.df$division[i] = divisions[i]
  accuracy.df$true_negative[i] = if(min(predict.rf) > 0.55){0}else{conf_mat.rf[1,1]}
  accuracy.df$false_positive[i] = if(max(predict.rf) <= 0.55){0}else{conf_mat.rf[1,2]}
  accuracy.df$true_positive[i] = if(max(predict.rf) <= 0.55){0}else{conf_mat.rf[2,2]}
  accuracy.df$false_negative[i] = if(min(predict.rf) > 0.55){0}else{conf_mat.rf[2,1]}
  print(conf_mat.rf)
  # # Loss accuracy
  # loss_acc[divisions[i]] = conf_mat.rf[1,1]/sum(conf_mat.rf[1,])
  # print(sprintf("Loss accuracy: %f",loss_acc[divisions[i]]))
  # # Win accuracy
  # win_acc[divisions[i]] = conf_mat.rf[2,2]/sum(conf_mat.rf[2,])
  # print(sprintf("Win accuracy: %f:",win_acc[divisions[i]]))
  # # Overall accuracy
  # total_acc[divisions[i]] = (conf_mat.rf[2,2] + conf_mat.rf[1,1])/sum(conf_mat.rf)
  # print(sprintf("Overall accuracy: %f",total_acc[divisions[i]]))
  # 
  # # ROC curve
  # roc.curve(test.tmp$WON__C, predict.rf, main=paste(divisions[i]," ROC Curve"))
}
print(Sys.time() - start.time)

accuracy.df
i = 1
for(div in importance){
  print(divisions[i])
  print(data.frame(div[,1]), row.names = FALSE)
  i = i + 1
}
print(data.frame(row.names(importance[[1]])), row.names=FALSE)
