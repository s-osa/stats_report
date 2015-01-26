require "csv"
require "pg"

connection = PG::connect(:host => "localhost", :user => "osa", :dbname => "stock_and_exchange")

begin
  CSV.foreach("import/dollar-yen.csv") do |row|
    date, closing_price = row[0], row[1]
    res = connection.exec("SELECT * FROM exchange_rates WHERE date = $1;", [date])
    if res.ntuples == 0
      connection.exec("INSERT INTO exchange_rates(date, closing_price) VALUES($1, $2);", [date, closing_price])
    end
  end
ensure
  connection.finish
end
