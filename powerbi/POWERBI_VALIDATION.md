# Power BI Validation Checklist

## Status
The expected results below are independently verified from `data/superstore_clean.csv`. The Power BI report and its visuals are **not yet validated**. Use the existing imported `Data` table in the open report; do not re-import the Excel workbook. The CSV is the reconciliation authority.

## Source check
Use the validation and KPI queries in `sql/retail_sales_analysis.sql`, then reconcile the results with the workbook's `KPI Summary` and analysis sheets. This checks the source analysis; it does not validate the Power BI model.

## Expected unfiltered model values

| Check | Expected |
|---|---:|
| Transaction lines | 10,194 |
| Distinct orders | 5,111 |
| Distinct customers | 804 |
| Total sales | $2,326,534.35 |
| Total profit | $292,296.81 |
| Profit margin | 12.56% |
| Total quantity | 38,654 |
| Average order value | $455.20 |
| High-discount transaction lines (Discount >= 0.50) | 940 |
| Distinct orders with at least one high-discount line | 745 |
| Profit on high-discount lines | -$97,536.62 |

## Model checks in Desktop
- `Data` contains 10,194 transaction rows and the expected field names; no duplicate transaction keys or blank key/measure values.
- `Data[Order Date]` and `Data[Ship Date]` are Date values; Sales/Profit/Discount are decimal values; Quantity is whole number; IDs are text.
- `Calendar` covers the full order-date range, has one row per date, and is marked as the date table.
- Active one-to-many relationship: `Calendar[Date]` to `Data[Order Date]`.
- The measures return the unfiltered expected values above. Profit Margin is `[Total Profit] / [Total Sales]`; Average Order Value is sales divided by distinct orders, not transaction rows.
- Applying Discount Band = `50%+` returns 940 lines, 745 distinct orders, and -$97,536.62 profit. Do not count every transaction line as an order.

## Visual and interaction checks
- All four pages in `POWERBI_BUILD_SPEC.md` exist, have the required titles and visuals, and show no visual error banners or missing-field warnings.
- Year, Region, Segment, and Category slicers filter the intended visuals across all pages. Clear selections and re-check the benchmark values.
- Month charts are chronological. Discount Band is sorted by its numeric sort column. Product rankings respond to slicers and use the intended direction.
- Category, region, segment, sub-category, and product totals reconcile to the SQL output and workbook analysis sheets.
- Save to `powerbi/Retail_Sales_Intelligence.pbix`, close it, reopen it, and repeat the visual-error check.

## Completion evidence
Record the PBIX path, date checked, KPI results, pages checked, and any exceptions in this file only after the report has been reopened and visually validated. Until then, leave the report status as incomplete.
