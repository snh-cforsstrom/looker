- connection: snh-test

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: pf_nar
- explore: pf_nar_with_sf

- explore: nar_sf_raw
  joins: 
  - join: closed_won_opportunities
    type: left_outer
    relationship: one_to_many
    sql_on: ${closed_won_opportunities.client_code} = ${nar_sf_raw.account}