# Marketing Analytics — dbt Project

A dbt (data build tool) project that transforms raw customer, transaction, and campaign data into clean analytical models for marketing performance measurement.

Built on DuckDB for local development — no cloud warehouse required to run.

## What This Project Does

Takes three raw data sources (customers, transactions, campaign spend) and builds a layered analytics architecture:

- **Staging layer** — cleans, standardizes, and validates raw data
- **Marts layer** — builds business-ready analytical models with documented logic

## Models

### Staging
| Model | Description |
|-------|-------------|
| `stg_customers` | Cleaned customer records with acquisition metadata |
| `stg_transactions` | Standardized transactions with net amount calculation |
| `stg_campaign_spend` | Cleaned campaign spend by channel and date |

### Marts
| Model | Description |
|-------|-------------|
| `mart_cac` | Customer Acquisition Cost by channel and month |
| `mart_ltv` | Customer Lifetime Value with segmentation tiers |
| `mart_cohort_retention` | Monthly cohort retention rates |
| `mart_churn_risk` | Rule-based churn risk scoring by recency |

## Data Tests

Schema tests defined in `models/schema.yml` covering:
- Uniqueness and not-null constraints on all primary keys
- Referential integrity between transactions and customers
- Accepted values for categorical fields (channel, plan_tier, churn_risk)

## Project Structure

```
dbt_marketing_analytics/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # DuckDB connection profile
├── models/
│   ├── schema.yml           # Column docs and data tests
│   ├── staging/
│   │   ├── stg_customers.sql
│   │   ├── stg_transactions.sql
│   │   └── stg_campaign_spend.sql
│   └── marts/
│       ├── mart_cac.sql
│       ├── mart_ltv.sql
│       ├── mart_cohort_retention.sql
│       └── mart_churn_risk.sql
└── seeds/
    ├── customers.csv
    ├── transactions.csv
    └── campaign_spend.csv
```

## How to Run

### Prerequisites
```bash
pip install dbt-duckdb
```

### Run the project
```bash
# Navigate to project directory
cd dbt_marketing_analytics

# Load seed data
dbt seed

# Run all models
dbt run

# Run data tests
dbt test

# Generate and serve documentation
dbt docs generate
dbt docs serve
```

### Run a specific model
```bash
dbt run --select mart_cac
dbt run --select mart_ltv
```

## Key Analytical Questions Answered

- **CAC by channel:** Which acquisition channels are most cost-efficient?
- **LTV segmentation:** Who are our highest-value customers and how were they acquired?
- **Cohort retention:** At what point do customers drop off, and which cohorts retain best?
- **Churn risk:** Which active customers are at risk of churning based on recent activity?

---

*Built by Kaitlyn Nguyen | [linkedin.com/in/kaitlynnguyens](https://linkedin.com/in/kaitlynnguyens)*
