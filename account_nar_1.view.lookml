- view: account_nar_1
  derived_table:
    sql: |
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
            )

  fields:

  - dimension: account
    type: string
    sql: ${TABLE}.Account

  - dimension: first_order_date
    type: date
    sql: ${TABLE}.FirstOrderDate

  - dimension: "rev_mnth1"
    type: number
    sql: ${TABLE}.RevMnth1

  - dimension: "rev_mnth2"
    type: number
    sql: ${TABLE}.RevMnth2

  - dimension: "rev_mnth3"
    type: number
    sql: ${TABLE}.RevMnth3

  - dimension: "rev_mnth4"
    type: number
    sql: ${TABLE}.RevMnth4

  - dimension: "narmnth1"
    type: number
    sql: ${TABLE}.NARMnth1

  - dimension: "narmnth2"
    type: number
    sql: ${TABLE}.NARMnth2

  - dimension: "narmnth3"
    type: number
    sql: ${TABLE}.NARMnth3

  - dimension: "narmnth4"
    type: number
    sql: ${TABLE}.NARMnth4

  sets:
    detail:
      - account
      - first_order_date
      - rev_mnth1
      - rev_mnth2
      - rev_mnth3
      - rev_mnth4
      - narmnth1
      - narmnth2
      - narmnth3
      - narmnth4

