
- view: pf_nar
  derived_table:
    sql: |
      SELECT unpvt.Account,
                   cwo.[Account Name  Account Name] AS AccountName,
                   cwo.[Opportunity Owner  Full Name] AS OpportunityOwner,
                   EOMONTH(unpvt.FirstOrderDate, SUBSTRING(unpvt.NARMnth, 8, 1) - 1) AS TransDate,
                   SUBSTRING(unpvt.NARMnth, 8, 1) AS NARMnth,
                   unpvt.NAR
            FROM ${account_nar_1.SQL_TABLE_NAME} AS c
            UNPIVOT(NAR FOR NARMnth IN([NARMnth1],
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

  - dimension_group: trans_date
    type: time
    sql: ${TABLE}.TransDate
    timeframes: [date, month]

  - dimension: narmnth
    type: number
    sql: ${TABLE}.NARMnth
    drill_fields: [trans_date_date]

  - measure: nar
    type: sum
    sql: ${TABLE}.NAR
    value_format_name: usd
    drill_fields: detail*

  sets:
    detail:
      - account
      - trans_date_date
      - narmnth
      - nar

