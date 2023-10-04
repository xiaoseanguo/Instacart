# Import libraries
import os
import pandas as pd

# Get current working directory
cwd =os.getcwd()

# Import products table
products_df = pd.read_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\products.csv")


## Clean the data in product_name column
# Remove comma
products_df['product_name'] = products_df['product_name'].str.replace(',', '')

# Remove back slash
products_df['product_name'] = products_df['product_name'].str.replace('\\', '')

# Remove quotations
products_df['product_name'] = products_df['product_name'].str.replace('"Constant Comment"', 'Constant Comment')
products_df['product_name'] = products_df['product_name'].str.replace("World's" , "Worlds")
products_df['product_name'] = products_df['product_name'].str.replace('"Worlds Best"', 'Worlds Best')
products_df['product_name'] = products_df['product_name'].str.replace('"Cheese"', 'Cheese')
products_df['product_name'] = products_df['product_name'].str.replace('"Rice Style"', 'Rice Style')
products_df['product_name'] = products_df['product_name'].str.replace('"Darn Good"', 'Darn Good')
products_df['product_name'] = products_df['product_name'].str.replace('Splits"', 'Splits')
products_df['product_name'] = products_df['product_name'].str.replace('"Im Pei-nut Butter"', 'Im Pei-nut Butter')
products_df['product_name'] = products_df['product_name'].str.replace('"Shells"', 'Shells')
products_df['product_name'] = products_df['product_name'].str.replace('"Mies Vanilla Rohe"', 'Mies Vanilla Rohe')
products_df['product_name'] = products_df['product_name'].str.replace('"100"', '100')
products_df['product_name'] = products_df['product_name'].str.replace('"Forte"', 'Forte')
products_df['product_name'] = products_df['product_name'].str.replace('"Louis Ba-Kahn"', 'Louis Ba-Kahn')
products_df['product_name'] = products_df['product_name'].str.replace('"Mokaccino"', 'Mokaccino')
products_df['product_name'] = products_df['product_name'].str.replace('"', 'in')

# Export cleaned table to csv
products_df.to_csv(str(cwd)+"\\Desktop\\Instacart Project\\data\\products_clean.csv", index=False)
