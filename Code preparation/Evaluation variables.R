# This file contains code to determine TRUE/FALSE for evaluation variables, which in turn determine which chunks to evaluate in the RMD file. 

# Note these can be combined, e.g. eval=(eval_paid & eval_relapse_2)

# eval_free = free trial, BUT the user has to have entered some Variables_data first - say 3 rows. Also must have at least 1 relapse, which needs
# to be taken care of at app level. 
if (nrow(Variables_user) < 3) {
  eval_free <- FALSE
} else {
  eval_free <- TRUE
}

# eval_paid = paid version
eval_paid <- TRUE

# eval_1_week = > 1 week
eval_1_week <- TRUE

# eval_relapse_2 = relapses >= 2
if (nrow(Relapses_user) < 2) {
  eval_relapse_2 <- FALSE
} else {
  eval_relapse_2 <- TRUE
}