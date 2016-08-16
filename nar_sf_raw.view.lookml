
- view: nar_sf_raw
  derived_table:
    sql: |
      SELECT b.Account,
                 cwo.[Account Name  Account Name] AS AccountName,
                 cwo.[Opportunity Owner  Full Name] AS OpportunityOwner,
                 b.FirstOrderDate,
                 b.RevMnth1,
                 b.RevMnth2,
                 b.RevMnth3,
                 b.RevMnth4,
                 b.RevMnth1 AS NARMnth1,
                 CASE
                     WHEN b.RevMnth2 > b.RevMnth1
                     THEN b.RevMnth2 - b.RevMnth1
                     ELSE 0
                 END AS NARMnth2,
                 CASE
                     WHEN b.RevMnth3 > 0.5 * ((b.RevMnth1 + b.RevMnth2) + ABS(b.RevMnth1 - b.RevMnth2))
                     THEN b.RevMnth3 - 0.5 * ((b.RevMnth1 + b.RevMnth2) + ABS(b.RevMnth1 - b.RevMnth2))
                     ELSE 0
                 END AS NARMnth3,
                 CASE
                     WHEN b.RevMnth4 > CASE
                                         WHEN b.RevMnth3 > = b.RevMnth2
                                              AND b.RevMnth3 >= b.RevMnth1
                                         THEN b.RevMnth3
                                         WHEN b.RevMnth2 >= b.RevMnth1
                                              AND b.RevMnth2 >= b.RevMnth3
                                         THEN b.RevMnth2
                                         ELSE b.RevMnth1
                                     END
                     THEN b.RevMnth4 - CASE
                                         WHEN b.RevMnth3 >= b.RevMnth2
                                              AND b.RevMnth3 >= b.RevMnth1
                                         THEN b.RevMnth3
                                         WHEN b.RevMnth2 >= b.RevMnth1
                                              AND b.RevMnth2 >= b.RevMnth3
                                         THEN b.RevMnth2
                                         ELSE b.RevMnth1
                                     END
                     ELSE 0
                 END AS NARMnth4
          FROM
          (
              SELECT Account,
                     FirstOrderDate,
                     SUM([1]) AS RevMnth1,
                     SUM([2]) AS RevMnth2,
                     SUM([3]) AS RevMnth3,
                     SUM([4]) AS RevMnth4
              FROM
              (
                  SELECT a.Account,
                         EOMONTH(a.[Time Entered], 0) AS TimeEntered,
                         b.FirstOrderDate,
                         ABS(DATEDIFF(m, EOMONTH(a.[Time Entered], 0), b.FirstOrderDate) - 1) AS NARMonth,
                         SUM(a.[Addon subtotal] + a.[Adjustment subtotal] + a.[Billed state/court fees]) AS Amt
                  FROM [CSV2 - Order Date] a
                       LEFT JOIN
                  (
                      SELECT c.Account,
                             MIN(EOMONTH(CAST(c.[Time Entered] AS DATE), 0)) AS FirstOrderDate
                      FROM [dbo].[CSV2 - Order Date] c
                      WHERE c.[Addon subtotal] + c.[Adjustment subtotal] + c.[Billed state/court fees] > 0
                      GROUP BY c.Account
                  ) b ON a.Account = b.Account
                  WHERE FirstOrderDate >= '2016-01-01'
                  GROUP BY a.Account,
                           EOMONTH(a.[Time Entered], 0),
                           b.FirstOrderDate
                  HAVING SUM(a.[Addon subtotal] + a.[Adjustment subtotal] + a.[Billed state/court fees]) > 0
                         AND ABS(DATEDIFF(m, EOMONTH(a.[Time Entered], 0), b.FirstOrderDate) - 1) <= 4
              ) a PIVOT(SUM(Amt) FOR NARMonth IN([1],
                                                 [2],
                                                 [3],
                                                 [4])) pvt
              GROUP BY Account,
                       FirstOrderDate
          ) b
          LEFT JOIN ClosedWonOpportunities cwo ON b.Account = cwo.[Client Code]
          WHERE cwo.[Opportunity Owner  Full Name] NOT IN('Ryan Matheny', 'Michele Shareef', 'Nicholas Zundel')
    persist_for: 1 hour
    indexes: [Account, OpportunityOwner]
    
  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: account
    type: string
    sql: ${TABLE}.Account

  - dimension: account_name
    type: string
    sql: ${TABLE}.AccountName

  - dimension: opportunity_owner
    type: string
    sql: ${TABLE}.OpportunityOwner

  - dimension: first_order_date
    type: date
    sql: ${TABLE}.FirstOrderDate

  - dimension: "rev_mnth1"
    type: number
    sql: ${TABLE}.RevMnth1
    value_format_name: usd

  - dimension: "rev_mnth2"
    type: number
    sql: ${TABLE}.RevMnth2
    value_format_name: usd

  - dimension: "rev_mnth3"
    type: number
    sql: ${TABLE}.RevMnth3
    value_format_name: usd

  - dimension: "rev_mnth4"
    type: number
    sql: ${TABLE}.RevMnth4
    value_format_name: usd

  - dimension: "narmnth1"
    type: number
    sql: ${TABLE}.NARMnth1
    value_format_name: usd

  - dimension: "narmnth2"
    type: number
    sql: ${TABLE}.NARMnth2
    value_format_name: usd

  - dimension: "narmnth3"
    type: number
    sql: ${TABLE}.NARMnth3
    value_format_name: usd

  - dimension: "narmnth4"
    type: number
    sql: ${TABLE}.NARMnth4
    value_format_name: usd

  sets:
    detail:
      - account
      - account_name
      - opportunity_owner
      - first_order_date
      - rev_mnth1
      - rev_mnth2
      - rev_mnth3
      - rev_mnth4
      - narmnth1
      - narmnth2
      - narmnth3
      - narmnth4

