use rustler_codegen::NifStruct;
use rand::{thread_rng, Rng};


#[derive(Default, Clone, NifStruct)]
#[module = "BinbaseBackend.Order"]
pub struct Order{
    id: u32,
    maker_id: u32,
    market_id: u16,
    kind: bool,
    price: u32,
    amount: u32,
    amount_filled: u32,
    stop_price: u32,
}

#[derive(NifStruct)]
#[module = "BinbaseBackend.Trade"]
pub struct Trade{
    price: u32,
    amount: u32,
    buy_id: u32,
    sell_id: u32,
}
#[derive(NifStruct)]
#[module = "BinbaseBackend.Engine.Native"]
pub struct Outputs{
    pub orderbook: Vec<Order>,
    pub orderbook_inverse: Vec<Order>,
    pub trades: Vec<Trade>,
    pub order: Order,
    pub modified_orders: Vec<Order>,
}

pub fn scan_orders(orderbook: &Vec<Order>, order: Order) -> (Order, Vec<Order>, Vec<Trade>){
    let mut trades: Vec<Trade> = vec![];
    let mut modified_orders: Vec<Order> = vec![];

    for (_i, head) in orderbook.iter().enumerate() {
        if (order.kind == false && head.price <= order.price) || (order.kind == true && head.price >= order.price) {

            let har = head.rem_amount();
            let oar =  order.rem_amount();

            let (oar, har, trade_amount) = extract(oar, har);


            let order = order.update_amount(oar);
            let head = head.update_amount(har);
            

            let (buy_id, sell_id) = get_ids(&order, &head);
            if trade_amount != 0 {
                trades.push(Trade{
                    price: head.price,
                    amount: trade_amount,
                    buy_id: buy_id,
                    sell_id: sell_id,
                })
            }
            modified_orders.push(head);
            if oar == 0 {
                break;
            }
        }
    }
    (order, modified_orders, trades)
}
fn get_ids(order: &Order, head: &Order) -> (u32, u32){
    if order.kind == false {
        (order.id, head.id)
    }else{
        (head.id, order.id)
    }
}
fn extract(oar: u32, har: u32) -> (u32, u32, u32){
    if oar > har {
        let x = oar - har;
        (x, 0, x)
    }else if oar < har {
        (0, har - oar, oar)
    }else{
        (0, 0, oar)
    } 
}
impl Order{
    fn rem_amount(&self) -> u32 {
        self.amount - self.amount_filled
    }
    fn update_amount(&self, amount_remaining: u32) -> Order{
        let order = Order{
            id: self.id,
            maker_id: self.maker_id,
            market_id: self.market_id,
            kind: self.kind,
            price: self.price,
            amount: self.amount,
            amount_filled: self.amount - amount_remaining,
            stop_price: self.stop_price,            
        };
        order
    }
}

pub fn add_order(mut orderbook: Vec<Order>, order: Order, tl: usize) -> Vec<Order>{
    let kind = order.kind;
    if tl > 0 && order.amount != order.amount_filled {
        let order_a = [order];
        orderbook.splice(0..0, order_a.iter().cloned());
    } else if tl == 0 {
        orderbook.push(order);
        if kind == false {
            orderbook.sort_by(|a, b| a.amount.cmp(&b.amount).reverse().then(a.id.cmp(&b.id)));
        }else {
            orderbook.sort_by(|a, b| a.amount.cmp(&b.amount).then(a.id.cmp(&b.id)));
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
    
    use test::Bencher;
    fn get_data() -> (Vec<Order>, Order){
        let orderbook = vec![Order{
            id: 0,
            kind: false,
            price: 4000,
            amount: 50,
            ..Default::default()
        },
        Order{
            id: 1,
            kind: false,
            price: 4010,
            amount: 200,
            ..Default::default()
        }        
        ];
        let order = Order{
            id: 2,
            kind: true,
            price: 4000,
            amount: 250,
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
        let (_new_order, new_orderbook, trades) = scan_orders(&orderbook, order);

        for (_i, item) in new_orderbook.iter().enumerate(){
            assert_eq!(item.amount, item.amount_filled)
        }
        assert_eq!(trades.len(), 2)
    }

    #[bench]
    fn bench_scan_orders(b: &mut Bencher) {
        b.iter(|| {
            let n: u32 = 1;
            let mut orderbook: Vec<Order> = vec![];
            for x in 0..n {
                let price: u32 = thread_rng().gen_range(4000, 4050);
                let amount: u32 = thread_rng().gen_range(10, 300);
                let kind = rand_true_false();
                let order = Order{
                    id: x,
                    kind: kind,
                    price: price,
                    amount: amount,
                    ..Default::default()
                };
                let (new_order, mut new_orderbook, _trades) = scan_orders(&orderbook, order);
                let new_order_new = [new_order];
                new_orderbook.splice(0..0, new_order_new.iter().cloned());
                orderbook = new_orderbook;
            }            
        });        
    }
}