require "csv"
require "pg"

connection = PG::connect(:host => "localhost", :user => "osa", :dbname => "stock_and_exchange")

begin
  codes = connection.exec("SELECT distinct code FROM stock_prices ORDER BY code;").to_a.map{|r| r["code"].to_i }

  codes.each do |code|
    res = connection.exec("select s.date, s.closing_price as stock_price, e.closing_price as dollar_price FROM stock_prices as s JOIN exchange_rates as e ON s.date = e.date WHERE s.code = $1 ORDER BY s.date;", [code])
    CSV.open("export/#{code}.csv", "w") do |writer|
      writer << ["Date", "Stock Price", "Dollar Price"]
      res.to_a.each do |r|
        writer << [r["date"], r["stock_price"], r["dollar_price"]]
      end
    end
  end
ensure
  connection.finish
end
