# Retail Sales Intelligence Dashboard Build Specification

## Status and handoff
The visual report is **not complete**. Use the existing report and its Excel-imported transaction table named `Data`; do not import the workbook again. Use `data/superstore_clean.csv` as the independent validation source.

## Report and model
- Report title: Retail Sales Intelligence
- Model table: `Data`
- Required fields, exact spelling: `Order ID`, `Order Date`, `Ship Date`, `Customer ID`, `Customer Name`, `Segment`, `Region`, `Category`, `Sub-Category`, `Product Name`, `Sales`, `Profit`, `Quantity`, `Discount`
- Keep one row per transaction line. Use Date for order/ship dates, decimal for Sales/Profit/Discount, whole number for Quantity, and text for IDs (including Postal Code).
- Create a contiguous `Calendar` date table and relate `Calendar[Date]` (one) to `Data[Order Date]` (many), active, single direction.
- Mark `Calendar` as the date table using `Calendar[Date]`.
- Create the calculated columns and measures documented in `Retail_Sales_Intelligence_DAX.md`.
- Set currency/decimal formats and sort `Calendar[Year Month]` by `Calendar[Year Month Sort]`, `Calendar[Month]` by `Calendar[Month Number]`, and `Data[Discount Band]` by `Data[Discount Band Sort]`.

## Report pages
### 1. Executive Overview
- Five KPI cards: Total Sales, Total Profit, Profit Margin %, Total Orders, Total Customers.
- Monthly Sales and Monthly Profit line charts using `Calendar[Year Month]`.
- Sales by Category clustered bar/column chart.
- Profit by Region bar chart.
- Slicers: Calendar Year, Region, Segment, Category. Sync these across all pages; provide a clear/reset-filters control if available.

### 2. Sales & Customer
- Sales by Segment chart.
- Category performance matrix: Category, Total Sales, Total Profit, Profit Margin %.
- Top 10 Sub-Categories by Total Sales.
- Top 10 Customers by Total Sales.
- Customer order frequency table using Customer Name, Total Orders, Total Sales, Average Order Value.

### 3. Profitability & Discount
- Profit and Profit Margin % by Category.
- Discount Band table: transaction lines, distinct orders, sales, profit, margin.
- Discount analysis chart: Discount Band against Total Sales and Total Profit; use the band sort column.
- High-discount KPI cards: High Discount Rows, High Discount Orders, High Discount Profit.
- Loss-making products table filtered to product profit below zero, sorted from lowest profit.
- Regional profitability matrix: Region, Total Sales, Total Profit, Profit Margin %.

### 4. Product Performance
- Top 10 products by sales, top 10 by profit, and bottom 10 by profit.
- Include Product Name, Total Sales, Total Profit, Profit Margin %, Sales Rank by Product, Profit Rank by Product.
- Add a sub-category performance chart or matrix with sales, profit, and margin.

## Visual and interaction requirements
- Use a consistent report theme, clear page titles, compact number formats, and readable axis labels; format currency as `$#,##0;($#,##0)` and margin as `0.00%`.
- Use display units consistently (prefer thousands/millions on chart axes, full currency values in KPI tooltips or labels where space allows).
- Sort monthly visuals chronologically, not alphabetically. Sort rankings by their intended measure.
- Confirm slicers filter every visual on every page and that visual interactions do not suppress unrelated KPIs.
- Use descriptive visual titles and show units; avoid map visuals because the geographic fields do not establish a reliable map grain.

## Build order
1. Verify the existing `Data` table, exact field names, data types, and 10,194 transaction rows. Do not re-import the workbook.
2. Create and relate the `Calendar` table, then mark it as a date table.
3. Create calculated columns and measures from the DAX file; apply formats and sort-by-column settings.
4. Build pages in the order above and sync slicers.
5. Reconcile the Power BI cards and tables against the SQL analysis, Excel workbook, and `POWERBI_VALIDATION.md`.
6. Save, close, and reopen the finished PBIX; verify every page renders without an error state.

## Output
Save the completed report to `powerbi/Retail_Sales_Intelligence.pbix`. Do not claim completion until the PBIX exists and the reopen/visual checks pass.
