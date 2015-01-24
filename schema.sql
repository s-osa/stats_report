CREATE DATABASE stock_and_exchange;

create table stock_prices(
  code integer NOT NULL,
  date date NOT NULL,
  closing_price integer NOT NULL
);

alter table stock_prices add constraint stock_prices_uq unique(code, date);

-- exchange_rates: date, closing_price
