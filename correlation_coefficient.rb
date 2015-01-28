require "csv"
require "pg"
require "statsample"

connection = PG::connect(:host => "localhost", :user => "osa", :dbname => "stock_and_exchange")

begin
  codes = connection.exec("SELECT distinct code FROM stock_prices ORDER BY code;").to_a.map{|r| r["code"].to_i }

  arr = []

  CSV.open("export/pearson_correlation_coefficient.csv", "w") do |writer|
    writer << ["Code", "Pearson's Correlation Coefficient"]
    codes.each do |code|
      res = connection.exec("select s.closing_price as stock_price, e.closing_price as dollar_price FROM stock_prices as s JOIN exchange_rates as e ON s.date = e.date WHERE s.code = $1 ORDER BY s.date;", [code]).to_a

      closing_prices = res.map{|r| r["stock_price"].to_f }.to_scale
      dollar_prices = res.map{|r| r["dollar_price"].to_f }.to_scale
      writer << [code, Statsample::Bivariate.pearson(closing_prices, dollar_prices)]
    end
  end
ensure
  connection.finish
end
