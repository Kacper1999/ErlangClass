defmodule PollutionData do
    @moduledoc false
    # data in pollution.csv:
    # DATE,HOUR,LENGTH,WIDTH,VALUE
    def import_lines_from_csv(filename) do
        filename
        |> File.read!()
        |> String.split("\r\n")
    end

    def parse_date(s_date, s_hour) do
        date = s_date
               |> String.split("-")
               |> Enum.reverse()
               |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)  # not using pipe to save space
               |> :erlang.list_to_tuple()
        hour = s_hour <> ":30"
               |> String.split(":")
               |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
               |> :erlang.list_to_tuple()
        {date, hour}
    end

    def parse_line(line) do
        [s_date, s_hour, s_len, s_width, s_val] = String.split(line, ",")
        date_time = parse_date(s_date, s_hour)
        location = [s_len, s_width]
                   |> Enum.map(fn x -> elem(Float.parse(x), 0) end)
                   |> :erlang.list_to_tuple()
        val = elem(Integer.parse(s_val), 0) # not using pipe to stick with a convention
        %{date_time: date_time, location: location, val: val}
    end

    def identify_stations(parsed_file) do
        parsed_file
        |> Enum.uniq_by(fn m -> m.location end)
    end

    def test() do
        lines = import_lines_from_csv("pollution.csv")
        IO.puts("Lines num: #{length(lines)}")

        unique_stations = lines
        |> Enum.map(fn line -> parse_line(line) end)
        |> identify_stations()
        IO.puts("Unique stations num: #{length(unique_stations)}")
    end
end
