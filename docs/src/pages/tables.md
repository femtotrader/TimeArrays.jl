# Tables.jl Integration

TimeArrays.jl provides seamless integration with the [Tables.jl](https://github.com/JuliaData/Tables.jl) ecosystem, allowing easy conversion between `TimeArray` objects and other tabular data structures like DataFrames, CSV files, and more.

## Tables.jl Interface

TimeArrays implements the complete Tables.jl interface, making `TimeArray` objects compatible with any package that supports Tables.jl sources and sinks.

### Key Features

- **Column Access**: Access timestamps and values as separate columns
- **Row Access**: Iterate over time series data row by row
- **Schema Information**: Automatic type inference and column naming
- **Round-trip Conversion**: Convert to other table formats and back without data loss

### Column Structure

When viewed as a table, a `TimeArray` has two columns:
- `:timestamp` - Contains the time index values
- `:value` - Contains the corresponding data values

## Usage Examples

### Basic Table Interface

```julia
using TimeArrays, Dates
import Tables

# Create a TimeArray
timestamps = [DateTime("2024-01-01"), DateTime("2024-01-02"), DateTime("2024-01-03")]
values = [1.0, 2.0, 3.0]
ta = TimeArray(timestamps, values)

# Check Tables.jl compatibility
Tables.istable(ta)  # true

# Get schema information
schema = Tables.schema(ta)
schema.names  # (:timestamp, :value)
schema.types  # (DateTime, Float64)
```

### Column Access

```julia
# Access as columns
cols = Tables.columns(ta)
timestamps = Tables.getcolumn(cols, :timestamp)
values = Tables.getcolumn(cols, :value)
```

### Row Access

```julia
# Iterate over rows
for row in Tables.rows(ta)
    timestamp = Tables.getcolumn(row, :timestamp)
    value = Tables.getcolumn(row, :value)
    println("$timestamp: $value")
end
```

### Creating TimeArrays from Tables

Use the `TimeArray` constructor to create TimeArrays from any Tables.jl-compatible source:

```julia
# From a table with default column names
table_data = Tables.columntable([
    (timestamp=DateTime("2024-01-01"), value=10.0),
    (timestamp=DateTime("2024-01-02"), value=20.0)
])
ta = TimeArray(table_data)

# From a table with custom column names
custom_data = Tables.columntable([
    (time=DateTime("2024-01-01"), price=100.0),
    (time=DateTime("2024-01-02"), price=200.0)
])
ta = TimeArray(custom_data; timestamp=:time, value=:price)
```

### Round-trip Conversions

```julia
# TimeArray → Table → TimeArray
original = TimeArray(timestamps, values)
table_format = Tables.columntable(original)
restored = TimeArray(table_format)

# Data is preserved
original == restored  # true
```

## Integration with DataFrames.jl

```julia
using DataFrames

# TimeArray to DataFrame
df = DataFrame(ta)

# DataFrame to TimeArray
ta_from_df = TimeArray(df)
```

## Integration with CSV.jl

```julia
using CSV

# Save TimeArray to CSV
CSV.write("data.csv", ta)

# Load TimeArray from CSV
ta_from_csv = TimeArray(CSV.File("data.csv"))
```

## Performance Notes

- Column access is optimized for bulk operations
- Row access provides convenient iteration but may be slower for large datasets
- Round-trip conversions preserve data types and ordering
- Memory usage is efficient due to columnar storage in Tables.jl format