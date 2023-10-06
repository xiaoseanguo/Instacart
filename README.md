# Instacart: Insights on Product Sales, Consumer Behavior, and Item Assocations

Xiao Sean Guo

### Code & Dashboard Links

- Market Basket Analysis Dashboard: <a href="https://public.tableau.com/app/profile/sean.guo/viz/InstacartAnalysis_16953440131720/MarketBasketDashboard" target="_blank"> Tableau </a>
- Product Analysis Dashboard: <a href="https://app.powerbi.com/view?r=eyJrIjoiNmNiMTRlNjgtZWEzZi00MGM2LTgwZmEtYWFhZGY1NDFiZGJhIiwidCI6ImU4ZThkM2I1LTg2ZTctNGIzMC1hZWRhLTgyYTMxYWUyODQ4NSIsImMiOjJ9&pageName=ReportSection" target="_blank"> Power BI </a> <sub>on page 2</sub>
- Consumer Behavior Dashboard: <a href="https://app.powerbi.com/view?r=eyJrIjoiNmNiMTRlNjgtZWEzZi00MGM2LTgwZmEtYWFhZGY1NDFiZGJhIiwidCI6ImU4ZThkM2I1LTg2ZTctNGIzMC1hZWRhLTgyYTMxYWUyODQ4NSIsImMiOjJ9&pageName=ReportSection" target="_blank"> Power BI </a> <sub>on page 1</sub>
- Data Cleaning: <a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_python_data_processing.py" target="_blank"> Python </a>
- Data Cleaning & Preparation: <a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_sql_queries.sql" target="_blank"> SQL </a>
- Apriori Algorithm: <a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_python_market_basket_analysis.py
  " target="_blank"> Python </a>

# Introduction

Instacart is an ecommerce app for grocery delivery service. On the app, the consumer (user) can choose a retailer and purchase items from that retailer. A shopper will then pick out the selected items and deliver them to the user. Thereby, it connects retailers, shoppers, and consumers.

In 2017, Instacart released a sales dataset to host a competition on Kaggle. The dataset included information on the transactions, the products, and the anonymized users from its business.

# Motivation

The main goals of this project is to uncover insights on the performance of different grocery items as well as consumer shopping patterns.

From the consumer perspective, we can look for correlations between the volume of purchases and the following factors:

- Basket size
- Number of trips
- Shopping frequency
- Percent of purchases that are repurchases of the same items
- Variety of items purchased

From the product perspective, we can segment the products based on their department and examine the relative volume of sales from each department. In addition, we can examine if the sales of each department is driven by:

- Large user based
- Repeat sales
- Combination of both

Shoppers browse through virtual platforms such as Instacart very differently from brick and mortar stores. Therefore, there are new opportunities for Instacart to drive sales volume or increase user base, unavailable to physical stores. For instance, selling a staple product at a loss is a physical retailer strategy to entice shoppers to come to the store and purchase more items. However, this strategy is less effective for Instacart since it takes much less time and effort to open a website than to drive to a store. Furthermore, store layout and shelf layout are not available to Instacart to promote the visibility of specific items. As an alternative, Instacart can provide recommendations to items that are commonly bought together. Consequently, another goal of this project is to perform market basket analysis to find closely associated items.

# Dataset

The dataset is made up of 6 files. It contains information on more than 3 million orders, more than 30 million units purchased, nearly 200 thousand unique users, and nearly 50 thousand unique items.

The tables and their columns are as follows:

> **products.csv**: 49688 rows
>
> - _product_id_: product identifier, primary key
> - _product_name_: product name
> - _aisle_id_: foreign key
> - _department_id_: foreign key

> **aisles.csv**: 134 rows
>
> - _aisle_id_: aisle identifier, primary key
> - _aisle_: aisle name

> **departments.csv**: 21 rows
>
> - _department_id_: department identifier, primary key
> - _department_: department name

> **order_products\_\_prior.csv** & **order_products\_\_train.csv**: 1384617 + 32434489 rows
>
> - _order_id_: foreign key
> - _product_id_: foreign key
> - _add_to_cart_order_: the sequence of the product that is added to cart
> - _reordered_: boolean indicating if item was ordered before by the user

> **orders.csv**: 3421083 rows
>
> - _order_id_: order identifier, primary key
> - _user_id_: user identifier
> - _eval_set_: divide the orders into prior, train, and test sets
> - _order_number_: the sequence of the order that the user placed
> - _order_dow_: day of the week the order was placed
> - _order_hour_of_day_: hour of the day the order was placed
> - _days_since_prior_: number of days since previous order was placed by same user

# Project Summary

This project involves the following steps:

1. Cleaning files in Python to allow for the import of the csv files into a database.
2. Importing, cleaning, and processing the tables, then calculating sales metrics with mySQL.
3. Analyzing product sales and consumer behavior in Power BI.
4. Performing market basket analysis in Python.
5. Visualizing and quantifying the product associations in Tableau.

# Data Preparation: Python

<a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_python_data_processing.py" target="_blank"> Python Code Link </a>

The file format of the data is CSV (comma separated value). However, some fields in the products.csv file contain characters that would disrupt the delimiter when importing the file. Python and the Pandas library were used to remove comma, back slash, and quotation characters from the products.csv file.

Below are some example of the rows with that disrupt the csv delimiter:
![CSV Table](https://github.com/xiaoseanguo/Instacart/assets/64453542/e75ffd1a-7baf-4b3a-aca4-8bf475d62682)

# Data Processing & Cleaning: SQL

<a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_sql_queries.sql" target="_blank"> SQL Code Link</a>

The 6 csv files were imported into tables in mySQL.

All the tables were then checked for duplicated rows and null values. Fortunately there were no duplicate values. The only null values were found in the “days_since_prior_order” column in the “orders” file. They were simply converted to 0 as they represent the very first order from that specific user.

For the Kaggle competition, Instacart divided their orders into the “prior” set, the “train” set, and the “test” test. Since only data for the prior and train sets were released, the rows corresponding to the test set were removed from the order table. This is to prevent null values when the tables merge.

The order_products\_\_prior and order_products\_\_train tables contain the same column headings. Therefore, they were concatenated vertically via UNION.

The tables were then merged together by matching the primary keys to foreign keys on the tables.

The ERD diagram of the merged tables is shown below.
![ERD Diagram - processed](https://github.com/xiaoseanguo/Instacart/assets/64453542/5339ef41-1cbe-4939-9e67-ecc5921cc2f5)

# Data Aggregation SQL:

<a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_sql_queries.sql" target="_blank"> SQL Code Link</a>

To calculate key metrics, aggregated tables were generated using SQL queries. This is because the raw data is too large for the data analytic and visualization softwares to handle. Aggregated tables were generated for the following key metrics:

Order metrics:

- Basket size for each order

Product metrics:

- Total units purchased for each product
- Total units reordered for each product
- Total unique users that bought each product

User metrics:

- Total units purchased by each user
- Total units reordered by each user
- Total orders “trips” by each user
- Total unique products purchased by each user
- Average basket size for each user
- Average number of days between orders for each user

# Product Analysis: Power BI

<a href="https://app.powerbi.com/view?r=eyJrIjoiNmNiMTRlNjgtZWEzZi00MGM2LTgwZmEtYWFhZGY1NDFiZGJhIiwidCI6ImU4ZThkM2I1LTg2ZTctNGIzMC1hZWRhLTgyYTMxYWUyODQ4NSIsImMiOjJ9&pageName=ReportSection" target="_blank"> Power BI Interactive Dashboard </a> <sub> (on page 2) </sub>

![Power BI Product Analysis](https://github.com/xiaoseanguo/Instacart/assets/64453542/d6bc145b-7123-4d96-bc8c-3b2c373b098f)

The product analysis dashboard has 3 graphs as well as a card with 3 summary statistics.

The card summarizes the number of unique users, unique products, and unique orders. These numbers change when filtered by departments.

The map plot shows all 21 departments. The size of each rectangle represents the number of unique items (SKUs) in each department. When clicking on a specific rectangle, you can filter for the corresponding department in the other plots as well as the card. The largest departments are personal care and snacks, while the smallest is bulk.

The bar plot shows the total units sold for each department.
The 2 departments with the most units sold by far are produce, and dairy & eggs. Surprisingly, they are not the departments with the most SKUs. The next 4 departments with the most units sold are snacks, beverages, frozen, and pantry.

The scatter plot visualizes each product by the number of unique users that purchased it (x-axis) against the percent of orders that are reorders (y-axis). The bottom left quadrant are products that are purchased by a few people and rarely repurchased. The top left quadrant are products that are purchased by a few people and often repurchased. The bottom right quadrant are products purchased by many people but rarely repurchased. The top right quadrant are products purchased by many people and often repurchased.

Regardless of the sales volume, the products in all the departments have a spread of values for the order frequency. (The dots are spread continuously on the y axis in every department.) The high volume sales departments differentiates from the low volume sales departments by the number of unique SKUs that are bought by a large number of unique users. (The dots in high volume departments are spread further to the right on the x axis.)

This analysis suggests that Instacart has done a good job with getting users to reorder items. However, Instacart may benefit by exposing their current users to other items available on their site and recruiting new users. This makes sense since it is much easier to see a retailer's entire offerings by browsing in a physical store than searching through a website.

# Consumer Behavior: Power BI

<a href="https://app.powerbi.com/view?r=eyJrIjoiNmNiMTRlNjgtZWEzZi00MGM2LTgwZmEtYWFhZGY1NDFiZGJhIiwidCI6ImU4ZThkM2I1LTg2ZTctNGIzMC1hZWRhLTgyYTMxYWUyODQ4NSIsImMiOjJ9&pageName=ReportSection" target="_blank"> Power BI Interactive Dashboard </a> <sub>(on page 1)</sub>

![Power BI Consumer Behavior](https://github.com/xiaoseanguo/Instacart/assets/64453542/80ee877d-c1c4-4770-beb8-f2fdfffbd29f)

The consumer behavior dashboard contains the same 3 summarizing statistics on the top right: number of unique users, unique products, and unique orders.

This dashboard also contains 6 histograms that counts the number of unique user for the 6 following metrics:

- Total units purchased
- Average basket size
- Number of trips
- Percentage of purchased items that are reordered items
- Days between orders
- Total unique item purchased

Each graph has a slider filter at the bottom to isolate a specific segment of the users. The plots can be further segmented by clicking on one or more bars on each histogram. Manipulating either or both filters on any one plot will change all 6 graphs, as well as the summarizing statistics at the top.

The most important filter is the one for the "total units sold" as it segments users by the amount they ordered. Not surprisingly it is negatively correlated with order interval while positively correlated with product variety, reorder ratio, basket size, and trip count.

Unexpectedly, the segment of the highest purchase volume users still have a large range of values for all the metrics. This suggests that the high volume users is not a single homogenous group.

As expected, reorder ratio, trip count, and product variety are positively correlated with each other and negatively correlated with order interval.

It is surprising to find that basket size is only weakly correlated with product variety, and is nearly independent of order interval, reorder ratio, and trip count. This means that increasing basket size will not negatively impact the other metrics, thus making it a good lever to pull to drive sales.

# Market Basket Analysis: Python

<a href="https://github.com/xiaoseanguo/Instacart/blob/main/Instacart_python_market_basket_analysis.py
  " target="_blank"> Python Code Link </a>

Although Instacart’s Kaggle competition focused on reorders, my analysis on consumer behavior above suggested that increasing basket size can be an alternate effective method to drive sales. One way to drive sales is to make suggestions on complementary products based on the items that are already in the cart. Market basket analysis is the method to identify associations between products.

Two important metrics in market basket analysis are support and lift. Support is an indicator of popularity. It is the fraction of transactions that contain a set of items. For example, if 25% of transactions has item X, 20% has item Y, and 10% has both X and Y, then the support for X, Y, and both X & Y are 0.30, 0.25, and 0.10 respectively.

Lift is an indicator of association between items. It is the ratio of transactions containing both items X and Y, over the product of transactions with item X and transactions with item Y. For example, if 25% of transactions has item X, 20% has item Y, and 10% has both X & Y, then the lift for X & Y is 0.10/(0.20\*0.25) = 2. Values above 1 indicate association between the items, value of 1 indicates no association, values below 1 indicate negative association, and value of 0 indicates mutual exclusivity.

The market basket analysis was performed with the apriori algorithm using Python with the Pandas and Mlxtend libraries. The tables were imported into Python and joined together to form a matrix where the columns are the aisle names and the rows are the order numbers. The values were converted to the boolean data type, where it is true if a specific order contained at least one item from a specific aisle. The apriori algorithm was then run to find item pairs with a minimum support of 0.01 and a minimum lift of 1.5. In total, 440 aisle associations were found under these parameters.

# Recommended Items: Tableau

<a href="https://public.tableau.com/app/profile/sean.guo/viz/InstacartAnalysis_16953440131720/MarketBasketDashboard" target="_blank"> Tableau Interactive Dashboard</a>

![Tableau Dashboard](https://github.com/xiaoseanguo/Instacart/assets/64453542/1f149def-4de5-4c9a-86ac-a14a548f9e12)

The market basket analysis dashboard makes item suggestions based on the product already selected in the cart. The analysis was performed on the aisle level instead of the product SKU level to consolidate factors like packaging sizes and brands. In this dataset, the word “aisle” refers to a group of similar products such as “frozen pizza” and not necessarily a physical aisle in a store.

As a business intelligence tool, the learnings from this dashboard can be used to make promotional offers or simply “often bought together” suggestions. To use the dashboard, select the department and the aisle of interest from the filters on the left. On the generated table, the first column (grey) is the aisle of interest that was selected from the filters. Columns 2 and 3 are the department and the name of the recommended aisles. Columns 3 and 4 are the support metric and the lift metric, respectively. For ease of viewing, both metrics are color coded by the department of the recommended product.

Support represents the popularity of the item pair. Pairs with items that are frequently bought such as bananas will have high support. While pairs with items that are infrequently bought such as baking soda will have low support. Lift represents the closeness of the association between item pairs. Closely associated item pairs such as beef patty and burger bun will have high lift. Product pairs that are not closely associated such as organic quinoa and donuts will have low lift.

Most of the item associations are intuitive, where the item pairs are usually either ingredients used to create a specific dish, or items that are common to a certain lifestyle. Examples of the former are baking ingredients, sandwich ingredients, and breakfast items. Examples of the latter are snacks, vegan items, and minimum preparation meals. The pairs with the highest lifts (above 3) are pasta + pasta sauce, canned vegetables + canned beans, and frozen pizza + frozen meal.

Although most of the associations are intuitive, it would still be a challenge for anyone to come up with many of these associations off the top of their head without seeing the data. For example, cereal is highly associated with other breakfast food, but it is also highly associated with snacks, and minimal preparation foods.

# Conclusion

The analysis of the Instacart dataset provides several insights to product sales, consumer behavior, and association between items.

- The departments with the most sales volume are the perishable departments, which are not necessarily the departments with the most SKUs.
- Departments with high sales volumes have a much larger user base than departments with low sales volumes.
- Departments with low sales volumes do not suffer from low repeat purchases.

- The users that purchased the most items also purchased the most variety of products, reorder often, have large baskets, make more total trips, and more frequent trips.
- Order interval, reorder ratio, trip count, and product variety are correlated with each other, but they have almost no correlation to basket size.

- The above suggests exposing users to items they may be unaware of, and increasing basket size are good strategies for growing sales. Both can be achieved by making product recommendations.
- The products with the strongest associations are either products that are used to create a specific meal, or products that belong to the same life style.

- Market basket analysis can uncover these relationships to make product recommendations for sales and marketing strategies.
