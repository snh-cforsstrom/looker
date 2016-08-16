
- view: pf_nar_with_sf
  derived_table:
    sql: |
      SELECT unpvt.Account,
                   cwo.[Account Name  Account Name] AS AccountName,
                   cwo.[Opportunity Owner  Full Name] AS OpportunityOwner,
                   EOMONTH(unpvt.FirstOrderDate, SUBSTRING(unpvt.NARMnth, 8, 1) - 1) AS TransDate,
                   SUBSTRING(unpvt.NARMnth, 8, 1) AS NARMnth,
                   unpvt.NAR
            FROM
            (
                SELECT Account,
                       FirstOrderDate,
                       RevMnth1,
                       RevMnth2,
                       RevMnth3,
                       RevMnth4,
                       RevMnth1 AS NARMnth1,
                       CASE
                           WHEN RevMnth2 > RevMnth1
                           THEN RevMnth2 - RevMnth1
                           ELSE 0
                       END AS NARMnth2,
                       CASE
                           WHEN RevMnth3 > 0.5 * ((RevMnth1 + RevMnth2) + ABS(RevMnth1 - RevMnth2))
                           THEN RevMnth3 - 0.5 * ((RevMnth1 + RevMnth2) + ABS(RevMnth1 - RevMnth2))
                           ELSE 0
                       END AS NARMnth3,
                       CASE
                           WHEN RevMnth4 > CASE
                                               WHEN RevMnth3 > = RevMnth2
                                                    AND RevMnth3 >= RevMnth1
                                               THEN RevMnth3
                                               WHEN RevMnth2 >= RevMnth1
                                                    AND RevMnth2 >= RevMnth3
                                               THEN RevMnth2
                                               ELSE RevMnth1
                                           END
                           THEN RevMnth4 - CASE
                                               WHEN RevMnth3 >= RevMnth2
                                                    AND RevMnth3 >= RevMnth1
                                               THEN RevMnth3
                                               WHEN RevMnth2 >= RevMnth1
                                                    AND RevMnth2 >= RevMnth3
                                               THEN RevMnth2
                                               ELSE RevMnth1
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
            ) c UNPIVOT(NAR FOR NARMnth IN([NARMnth1],
                                           [NARMnth2],
                                           [NARMnth3],
                                           [NARMnth4])) unpvt
            LEFT JOIN ClosedWonOpportunities cwo ON unpvt.Account = cwo.[Client Code]
            WHERE cwo.[Opportunity Owner  Full Name] NOT IN('Ryan Matheny','Michele Shareef','Nicholas Zundel')

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

  - dimension_group: trans_date
    type: time
    sql: ${TABLE}.TransDate
    timeframes: [date, month]

  - dimension: narmnth
    type: string
    sql: ${TABLE}.NARMnth

  - measure: nar
    type: sum
    sql: ${TABLE}.NAR
    value_format_name: usd

  sets:
    detail:
      - account
      - account_name
      - opportunity_owner
      - trans_date
      - narmnth
      - nar

