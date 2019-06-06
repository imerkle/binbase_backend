use rustler_codegen::NifStruct;
use rand::{thread_rng, Rng};


#[derive(Default, Clone, NifStruct)]
#[module = "Exchange.Order"]
pub struct Order{
    id: u32,
    maker_id: u32,
    market_id: u16,
    side: bool,
    kind: u8,
    price: f32,
    amount: f32,
    amount_filled: f32,
    active: bool,
}

/*
kind
0 - limit order
1 - stop trigger order
2 - market order
*/

#[derive(Default, NifStruct)]
#[module = "Exchange.Trade"]
pub struct Trade{
    price: f32,
    amount: f32,
    buy_id: u32,
    sell_id: u32,
    fees_incl: f32,
    fees_excl: f32,
}
#[derive(NifStruct)]
#[module = "Exchange.Engine.Native"]
pub struct Outputs{
    pub orderbook: Vec<Order>,
    pub orderbook_inverse: Vec<Order>,
    pub trades: Vec<Trade>,
    pub order: Order,
    pub modified_orders: Vec<Order>,
    pub balances: Vec<Balance>,
}
#[derive(NifStruct)]
#[module = "Exchange.Balance"]
pub struct Balance{
    pub user_id: u32,
    pub coin_id: usize,
    pub amount: f32,
    pub amount_locked: f32,
}

static REL: [&str; 2] = ["BTC","ETH"];
static BASE: [&str; 2] = ["USDT","BTC"];
static COINS: [&str; 3]  = ["USDT","BTC", "ETH"];

fn get_coin_id(ticker: &str) -> usize {
    return COINS.iter().position(|&r| r == ticker).unwrap();
}
fn get_tickers_from_market_id(market_id: u16) -> (&'static str, &'static str){
    let tr = market_id%100;
    let tb = (market_id - tr) / 100;
    return (REL[tr as usize], BASE[tb as usize]);
}

pub fn scan_orders(orderbook: &Vec<Order>, mut order: Order) -> (Order, Vec<Order>, Vec<Trade>, Vec<Balance>){
    let mut trades: Vec<Trade> = vec![];
    let mut modified_orders: Vec<Order> = vec![];
    let mut balances: Vec<Balance> = vec![];
    
    let (token_rel, token_base)  = get_tickers_from_market_id(order.market_id);
    let (ticker_o, ticker_h) = if order.side == false { (token_base, token_rel) } else {(token_rel, token_base)};
    let (coin_id_o, coin_id_h) = (get_coin_id(ticker_o), get_coin_id(ticker_h));
    for (_i, head) in orderbook.iter().enumerate() {
        if (order.side == false && head.price <= order.price) || (order.side == true && head.price >= order.price) || order.kind == 2 {

            let har = head.rem_amount();
            let oar =  order.rem_amount();

            let (orm, hrm, trade_amount) = extract(oar, har);

            let hprice = if order.kind == 2 { Some(head.price) } else { None }; 
            order = order.update_amount(orm, hprice);
            let head = head.update_amount(hrm, None);
            

            let (buy_id, sell_id) = get_ids(&order, &head);
            if trade_amount != 0.0 {
                trades.push(Trade{
                    price: head.price,
                    amount: trade_amount,
                    buy_id,
                    sell_id,
                    ..Default::default()
                })
            }
        
            //let (amt_o, amt_h) = if order.side == false { (token_base, token_rel) } else {(token_rel, token_base)};

            balances = add_or_insert(balances, order.maker_id, trade_amount, coin_id_o);
            balances = add_or_insert(balances, head.maker_id, trade_amount, coin_id_h);
            
            modified_orders.push(head);
            if orm == 0.0 {
                break;
            }
        }
    }
    (order, modified_orders, trades, balances)
}
fn add_or_insert(mut balances: Vec<Balance>, user_id: u32, amount: f32, coin_id: usize) -> Vec<Balance>{
    let mut found: bool = false;
    for item in &mut balances {
      if item.user_id == user_id {
        item.amount = item.amount + amount;
        found = true;
        break;
      }
    }
    if !found {
        balances.push(Balance{user_id: user_id, coin_id: coin_id, amount: amount, amount_locked: -amount});
    }
    return balances;
}
fn get_ids(order: &Order, head: &Order) -> (u32, u32){
    if order.side == false {
        (order.id, head.id)
    }else{
        (head.id, order.id)
    }
}
fn extract(oar: f32, har: f32) -> (f32, f32, f32){
    if oar > har {
        (oar - har, 0.0, har)
    }else if oar < har {
        (0.0, har - oar, oar)
    }else{
        (0.0, 0.0, oar)
    } 
}
impl Order{
    fn rem_amount(&self) -> f32 {
        self.amount - self.amount_filled
    }
    fn update_amount(&self, amount_remaining: f32, price: Option<f32>) -> Order{
        let amount_filled = self.amount - amount_remaining;
        let active = if amount_filled == self.amount { false } else { true };
        let new_price = match price {
            Some(x) => x,
            None    => self.price,
        };
        return Order{
            amount_filled,
            active,
            price: new_price,
            ..*self
        };
    }
}

pub fn add_order(mut orderbook: Vec<Order>, order: Order, tl: usize) -> Vec<Order>{
    let side = order.side;
    if tl > 0 && order.amount != order.amount_filled {
        let order_a = [order];
        orderbook.splice(0..0, order_a.iter().cloned());
    } else if tl == 0 {
        orderbook.push(order);
        if side == false {
            orderbook.sort_by(|a, b| a.amount.partial_cmp(&b.amount).unwrap().reverse().then(a.id.partial_cmp(&b.id).unwrap()));
        }else {
            orderbook.sort_by(|a, b| a.amount.partial_cmp(&b.amount).unwrap().then(a.id.partial_cmp(&b.id).unwrap()));
        }
    }
    orderbook
}
pub fn update_orders(mut orderbook: Vec<Order>, modified_orders: Vec<Order>) -> Vec<Order> {
 
    let orderbook_back = orderbook.split_off(modified_orders.len());

    let mut modified_orders = modified_orders.into_iter()
    .filter(|ref x| x.amount != x.amount_filled)
    .collect::<Vec<Order>>();
    
    modified_orders.extend(orderbook_back);
    modified_orders
}

#[cfg(test)]
mod tests {
    use super::*;
    
    //use test::Bencher;
    fn get_data() -> (Vec<Order>, Order){
        let orderbook = vec![Order{
            id: 0,
            side: false,
            price: 4000.0,
            amount: 50.0,
            ..Default::default()
        },
        Order{
            id: 1,
            side: false,
            price: 4010.0,
            amount: 200.0,
            ..Default::default()
        }        
        ];
        let order = Order{
            id: 2,
            side: true,
            price: 4000.0,
            amount: 300.0,
            ..Default::default()
        };
        (orderbook, order)
    }
    fn rand_true_false() -> bool {
        thread_rng().gen_range(0.0, 1.0) < 0.5
    }    

    #[test]
    fn can_scan_orders() {
        let (orderbook, order) = get_data();
        let (new_order, new_orderbook, trades, _balances) = scan_orders(&orderbook, order);

        for (_i, item) in new_orderbook.iter().enumerate(){
            assert_eq!(item.amount, item.amount_filled)
        }
        assert_eq!(new_order.amount_filled, 250.0);
        assert_eq!(trades.len(), 2)
    }
    
    #[test]
    fn check_ids(){
        let (token_rel, token_base)  = get_tickers_from_market_id(1);
        assert_eq!(token_rel, "ETH");
        assert_eq!(token_base, "USDT");
        
        let (token_rel, token_base)  = get_tickers_from_market_id(101);
        assert_eq!(token_rel, "ETH");
        assert_eq!(token_base, "BTC");

        let (coin_id_o, coin_id_h) = (get_coin_id(token_rel), get_coin_id(token_base));

        assert_eq!(coin_id_o, 2);
        assert_eq!(coin_id_h, 1);

    }
/*
    #[bench]
    fn bench_scan_orders(b: &mut Bencher) {
        b.iter(|| {
            let n: u32 = 1;
            let mut orderbook: Vec<Order> = vec![];
            for x in 0..n {
                let price: f32 = thread_rng().gen_range(4000.0, 4050.0);
                let amount: f32 = thread_rng().gen_range(10.0, 300.0);
                let side = rand_true_false();
                let order = Order{
                    id: x,
                    side,
                    price,
                    amount,
                    ..Default::default()
                };
                let (new_order, mut new_orderbook, _trades) = scan_orders(&orderbook, order);
                let new_order_new = [new_order];
                new_orderbook.splice(0..0, new_order_new.iter().cloned());
                orderbook = new_orderbook;
            }            
        });        
    }
    */
}