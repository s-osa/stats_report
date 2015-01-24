require "date"
require "mechanize"
require "pg"

agent      = Mechanize.new
connection = PG::connect(:host => "localhost", :user => "osa", :dbname => "stock_and_exchange")

begin
  current_max = [connection.exec("SELECT max(code) FROM stock_prices;").first["max"].to_i, 1300].max
  (current_max..9999).each do |code|
    (1..13).each do |page_no|
      url = "http://info.finance.yahoo.co.jp/history/?code=#{code}.T&sy=2014&sm=1&sd=1&ey=2014&em=12&ed=31&tm=d&p=#{page_no}"
      table = agent.get(url).search("table.boardFin")
      sleep 0.5
      break if table.empty?

      table.children[1..-1].each do |row|
        date = Date.parse(row.children[0].text.gsub(/[年月]/,"/").gsub("日",""))
        closing_price = row.children[6].text.gsub(",","").to_f.round rescue next

        res = connection.exec("SELECT * FROM stock_prices WHERE code = $1 AND date = $2;", [code, date])
        if res.ntuples == 0
          puts [code, date, closing_price].join(", ")
          connection.exec("INSERT INTO stock_prices(code, date, closing_price) VALUES($1, $2, $3);", [code, date, closing_price])
        end
      end
    end
  end
ensure
  connection.finish
end


