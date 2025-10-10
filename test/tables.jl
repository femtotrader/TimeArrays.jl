using Test
using Dates
using TimeArrays
import Tables

@testset "Tables.jl interface" begin
    # Create test data
    timestamps = [DateTime("2024-01-01"), DateTime("2024-01-02"), DateTime("2024-01-03")]
    values = [1.0, 2.0, 3.0]
    ta = TimeArray(timestamps, values)

    @testset "Basic interface" begin
        @test Tables.istable(ta) == true
        @test Tables.istable(typeof(ta)) == true
        @test Tables.rowaccess(typeof(ta)) == true
        @test Tables.columnaccess(typeof(ta)) == true
    end

    @testset "Schema" begin
        schema = Tables.schema(ta)
        @test schema.names == (:timestamp, :value)
        @test schema.types == (DateTime, Float64)
    end

    @testset "Column access" begin
        cols = Tables.columns(ta)
        @test Tables.columnnames(cols) == [:timestamp, :value]

        timestamp_col = Tables.getcolumn(cols, :timestamp)
        @test timestamp_col == timestamps

        value_col = Tables.getcolumn(cols, :value)
        @test value_col == values

        # Test column access by index
        timestamp_col2 = Tables.getcolumn(ta, DateTime, 1, :timestamp)
        @test timestamp_col2 == timestamps

        value_col2 = Tables.getcolumn(ta, Float64, 2, :value)
        @test value_col2 == values

        # Test invalid column access
        @test_throws ArgumentError Tables.getcolumn(cols, :invalid)
    end

    @testset "Row access" begin
        rows = Tables.rows(ta)
        @test length(rows) == 3

        # Test iteration
        row_data = collect(rows)
        @test length(row_data) == 3

        # Test first row
        first_row = first(row_data)
        @test Tables.getcolumn(first_row, :timestamp) == DateTime("2024-01-01")
        @test Tables.getcolumn(first_row, :value) == 1.0
        @test Tables.columnnames(first_row) == [:timestamp, :value]

        # Test invalid column access on row
        @test_throws ArgumentError Tables.getcolumn(first_row, :invalid)
    end

    @testset "Construction from Tables" begin
        # Test with a simple table-like structure
        simple_table = Tables.columntable([(timestamp=DateTime("2024-01-01"), value=10.0),
                                          (timestamp=DateTime("2024-01-02"), value=20.0)])

        ta_from_table = TimeArray(simple_table)
        @test length(ta_from_table) == 2
        @test ta_timestamp(ta_from_table[1]) == DateTime("2024-01-01")
        @test ta_value(ta_from_table[1]) == 10.0
        @test ta_timestamp(ta_from_table[2]) == DateTime("2024-01-02")
        @test ta_value(ta_from_table[2]) == 20.0

        # Test with custom column names
        custom_table = Tables.columntable([(time=DateTime("2024-01-01"), price=100.0),
                                         (time=DateTime("2024-01-02"), price=200.0)])

        ta_from_custom = TimeArray(custom_table; timestamp=:time, value=:price)
        @test length(ta_from_custom) == 2
        @test ta_timestamp(ta_from_custom[1]) == DateTime("2024-01-01")
        @test ta_value(ta_from_custom[1]) == 100.0
    end

    @testset "Round-trip conversion" begin
        # Convert TimeArray to table and back
        table_data = Tables.columntable(ta)
        ta_roundtrip = TimeArray(table_data)

        @test length(ta_roundtrip) == length(ta)
        for i in 1:length(ta)
            @test ta_timestamp(ta_roundtrip[i]) == ta_timestamp(ta[i])
            @test ta_value(ta_roundtrip[i]) == ta_value(ta[i])
        end
    end

    @testset "Type compatibility" begin
        # Test with different timestamp types
        int_timestamps = [1, 2, 3]
        int_values = [10.0, 20.0, 30.0]
        int_ta = TimeArray(int_timestamps, int_values)

        @test Tables.istable(int_ta) == true
        schema = Tables.schema(int_ta)
        @test schema.names == (:timestamp, :value)
        @test schema.types == (Int64, Float64)

        # Test column access
        cols = Tables.columns(int_ta)
        @test Tables.getcolumn(cols, :timestamp) == int_timestamps
        @test Tables.getcolumn(cols, :value) == int_values
    end
end