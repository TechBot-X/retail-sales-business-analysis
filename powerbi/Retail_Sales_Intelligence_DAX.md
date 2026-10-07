# Retail Sales Intelligence DAX

These definitions target the already-imported Excel transaction table named `Data`. Do not paste the full file as one expression: create the calculated table/columns first, then create each measure separately. If the actual field names differ, resolve that against the imported `Data` table rather than loading a duplicate table.

## Calculated table

Create this calculated table, then add its calculated columns below. Mark it as the model date table using `[Date]` and create the active one-to-many relationship `Calendar[Date]` -> `Data[Order Date]`.

```DAX
Calendar =
CALENDAR(
    MINX(ALL(Data), Data[Order Date]),
    MAXX(ALL(Data), Data[Order Date])
)
```

## Calculated columns

Add to `Calendar`:

```DAX
Year = YEAR(Calendar[Date])
Month Number = MONTH(Calendar[Date])
Month = FORMAT(Calendar[Date], "MMM")
Year Month = FORMAT(Calendar[Date], "yyyy-MM")
Year Month Sort = YEAR(Calendar[Date]) * 100 + MONTH(Calendar[Date])
```

Sort `Calendar[Month]` by `[Month Number]` and `[Year Month]` by `[Year Month Sort]`.

Add to `Data`:

```DAX
High Discount Flag = INT(Data[Discount] >= 0.5)

Discount Band =
SWITCH(
    TRUE(),
    Data[Discount] >= 0.5, "50%+",
    Data[Discount] >= 0.3, "30% to 49%",
    Data[Discount] >= 0.2, "20% to 29%",
    Data[Discount] >= 0.1, "10% to 19%",
    "0% to 9%"
)

Discount Band Sort =
SWITCH(
    TRUE(),
    Data[Discount] >= 0.5, 1,
    Data[Discount] >= 0.3, 2,
    Data[Discount] >= 0.2, 3,
    Data[Discount] >= 0.1, 4,
    5
)
```

Sort `Data[Discount Band]` by `[Discount Band Sort]`.

## Core measures

```DAX
Transaction Lines = COUNTROWS(Data)
Total Sales = SUM(Data[Sales])
Total Profit = SUM(Data[Profit])
Profit Margin % = DIVIDE([Total Profit], [Total Sales])
Total Orders = DISTINCTCOUNT(Data[Order ID])
Total Customers = DISTINCTCOUNT(Data[Customer ID])
Total Quantity = SUM(Data[Quantity])
Average Order Value = DIVIDE([Total Sales], [Total Orders])
Sales per Customer = DIVIDE([Total Sales], [Total Customers])
Average Discount = AVERAGE(Data[Discount])
```

## Time measures

```DAX
Sales YTD = TOTALYTD([Total Sales], Calendar[Date])
Profit YTD = TOTALYTD([Total Profit], Calendar[Date])
Sales LY = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(Calendar[Date]))
Profit LY = CALCULATE([Total Profit], SAMEPERIODLASTYEAR(Calendar[Date]))
Sales Growth % = DIVIDE([Total Sales] - [Sales LY], [Sales LY])
Profit Growth % = DIVIDE([Total Profit] - [Profit LY], [Profit LY])
Running Sales Total =
CALCULATE(
    [Total Sales],
    FILTER(
        ALLSELECTED(Calendar[Date]),
        Calendar[Date] <= MAX(Calendar[Date])
    )
)
```

## Discount and product measures

```DAX
High Discount Rows =
CALCULATE([Transaction Lines], KEEPFILTERS(Data[Discount] >= 0.5))

High Discount Orders =
CALCULATE([Total Orders], KEEPFILTERS(Data[Discount] >= 0.5))

High Discount Sales =
CALCULATE([Total Sales], KEEPFILTERS(Data[Discount] >= 0.5))

High Discount Profit =
CALCULATE([Total Profit], KEEPFILTERS(Data[Discount] >= 0.5))

Products with Negative Profit =
COUNTROWS(
    FILTER(
        VALUES(Data[Product Name]),
        CALCULATE([Total Profit]) < 0
    )
)

Sales Rank by Product =
RANKX(ALLSELECTED(Data[Product Name]), [Total Sales],, DESC, DENSE)

Profit Rank by Product =
RANKX(ALLSELECTED(Data[Product Name]), [Total Profit],, DESC, DENSE)

Bottom Profit Rank by Product =
RANKX(ALLSELECTED(Data[Product Name]), [Total Profit],, ASC, DENSE)
```

## Formatting
- Currency measures: currency, 2 decimal places for cards/tables; chart axes may use display units in thousands or millions.
- `Profit Margin %`, `Sales Growth %`, `Profit Growth %`, `Average Discount`: percentage, 2 decimal places.
- Counts and ranks: whole number, no decimals.
- `High Discount Profit` is expected to be negative; preserve its sign.

## Reconciliation targets

At unfiltered report context, verify the values in `POWERBI_VALIDATION.md`. The high-discount measures are context-sensitive; at the full dataset context they should show 940 rows, 745 distinct orders, and -97,536.62 profit.
