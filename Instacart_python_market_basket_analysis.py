# Import libraries
import os
import pandas as pd
from mlxtend.frequent_patterns import apriori, association_rules

# Get current working directory
cwd =os.getcwd()

# Import all csv files as data frames
order_products_train_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\order_products__train.csv") 
order_products_prior_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\order_products__prior.csv") 
products_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\products.csv")
aisles_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\aisles.csv") 
departments_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\departments.csv") 


## Join tables 
# Combine the order_products dataframes
order_products_df = pd.concat([order_products_train_df, order_products_prior_df], axis = 0)

# Combine products_df & aisles_df & departments_df
products_df_combined = products_df.merge(aisles_df, how='left', on='aisle_id').merge(departments_df, how='left', on='department_id')


## Process the data
# Downsize the product_order table to aisle level 
order_aisle = order_products_df.merge(products_df, on='product_id', how= 'left')
order_aisle_df = order_aisle[['order_id', 'aisle_id']]
order_aisle_df_unique = order_aisle_df.drop_duplicates()

# Reduce size of dataframe
order_aisle_df_small = order_aisle_df_unique[order_aisle_df_unique['order_id'] <= 300000]

# Create value matrix
apriori_crosstab_aisle = pd.crosstab(order_aisle_df_small['order_id'], order_aisle_df_small['aisle_id'])


## Apriori algorithm
# Convert matrix datatype to bool
apriori_crosstab_aisle_bool = apriori_crosstab_aisle.astype(bool)

# Find frequent itemsets
frequent_aisle = apriori(apriori_crosstab_aisle_bool, min_support=0.01, max_len=2, use_colnames=True)

frequent_aisle_min_lift = association_rules(frequent_aisle, metric = 'lift', min_threshold=1.5)


## Reformat tables
# Create table of unique aisles
aisle_df_combined = products_df_combined[['aisle_id', 'aisle', 'department']]
aisle_df_concise = aisle_df_combined.drop_duplicates()
aisle_df_concise = aisle_df_concise.astype({'aisle_id':str})

# Remove '(' & ')' from frequent_items_min_lift table
frequent_aisle_named = frequent_aisle_min_lift

frequent_aisle_named = frequent_aisle_named.astype({'antecedents':str})
frequent_aisle_named['antecedents'] = frequent_aisle_named['antecedents'].str.replace('frozenset({', '')
frequent_aisle_named['antecedents'] = frequent_aisle_named['antecedents'].str.replace('})', '')

frequent_aisle_named = frequent_aisle_named.astype({'consequents':str})
frequent_aisle_named['consequents'] = frequent_aisle_named['consequents'].str.replace('frozenset({', '')
frequent_aisle_named['consequents'] = frequent_aisle_named['consequents'].str.replace('})', '')

# Add and rename product, aisle, department columns
frequent_aisle_named = frequent_aisle_named.merge(aisle_df_concise, left_on='antecedents', right_on='aisle_id', how= 'left')
frequent_aisle_named = frequent_aisle_named.rename({'aisle_id': 'ant_id', 'aisle': 'ant_aisle', 'department': 'ant_dept'}, axis=1)
frequent_aisle_named = frequent_aisle_named.merge(aisle_df_concise, left_on='consequents', right_on='aisle_id', how= 'left')
frequent_aisle_named = frequent_aisle_named.rename({'aisle_id': 'con_id', 'aisle': 'con_aisle', 'department': 'con_dept'}, axis=1)


## Export frequent_items_named to csv
frequent_aisle_named.to_csv(str(cwd)+"\\Desktop\\Instacart Project\\new tables\\frequent_aisles.csv", index=False)

