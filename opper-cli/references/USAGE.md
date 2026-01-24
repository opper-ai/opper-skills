# CLI Usage Analytics

Track token usage, costs, and analytics from the command line.

## Basic Usage

```bash
# List usage for today
opper usage list

# Specify date range
opper usage list --from-date=2025-05-15 --to-date=2025-05-16
```

## Filtering and Grouping

```bash
# Select specific fields
opper usage list --fields=total_tokens,cost

# Group by a tag
opper usage list --group-by=customer_id

# Combine filters
opper usage list --from-date=2025-05-01 --to-date=2025-05-31 --fields=total_tokens,cost --group-by=customer_id
```

## Output Formats

```bash
# Default: table format
opper usage list

# CSV export
opper usage list --out=csv

# Redirect to file
opper usage list --out=csv > usage_report.csv
```

## Available Fields

| Field | Description |
|-------|-------------|
| `total_tokens` | Total tokens consumed |
| `input_tokens` | Input/prompt tokens |
| `output_tokens` | Output/completion tokens |
| `cost` | Total cost in USD |
| `count` | Number of calls |

## Grouping Options

Group results by any tag key used in your calls:

```bash
# Group by customer
opper usage list --group-by=customer_id

# Group by environment
opper usage list --group-by=env

# Group by project
opper usage list --group-by=project
```

## Tips

- Use `--tags` in `opper call` to enable granular usage tracking later
- CSV export is useful for importing into spreadsheets or billing systems
- Date format is `YYYY-MM-DD`
- Usage data is available shortly after calls complete
