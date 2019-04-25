use rustler_codegen::NifStruct;
use rand::{thread_rng, Rng};


#[derive(Default, Clone, NifStruct)]
#[module = "BinbaseBackend.Order"]
pub struct Order{
    id: u32,
    maker_id: u32,
    market_id: u16,
    kind: bool,
    price: f32,
    amount: f32,
    amount_filled: f32,
    active: bool,
}

#[derive(NifStruct)]
#[module = "BinbaseBackend.Trade"]
pub struct Trade{
    price: f32,
    amount: f32,
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

pub fn scan_orders(orderbook: &Vec<Order>, mut order: Order) -> (Order, Vec<Order>, Vec<Trade>){
    let mut trades: Vec<Trade> = vec![];
    let mut modified_orders: Vec<Order> = vec![];

    for (_i, head) in orderbook.iter().enumerate() {
        if (order.kind == false && head.price <= order.price) || (order.kind == true && head.price >= order.price) {

            let har = head.rem_amount();
            let oar =  order.rem_amount();

            let (orm, hrm, trade_amount) = extract(oar, har);


            order = order.update_amount(orm);
            let head = head.update_amount(hrm);
            

            let (buy_id, sell_id) = get_ids(&order, &head);
            if trade_amount != 0.0 {
                trades.push(Trade{
                    price: head.price,
                    amount: trade_amount,
                    buy_id,
                    sell_id,
                })
            }
            modified_orders.push(head);
            if orm == 0.0 {
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
    fn update_amount(&self, amount_remaining: f32) -> Order{
        let amount_filled = self.amount - amount_remaining;
        let active = if amount_filled == self.amount { false } else { true };

        return Order{
            id: self.id,
            maker_id: self.maker_id,
            market_id: self.market_id,
            kind: self.kind,
            price: self.price,
            amount: self.amount,
            amount_filled,
            active,
        };
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
            kind: false,
            price: 4000.0,
            amount: 50.0,
            ..Default::default()
        },
        Order{
            id: 1,
            kind: false,
            price: 4010.0,
            amount: 200.0,
            ..Default::default()
        }        
        ];
        let order = Order{
            id: 2,
            kind: true,
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
        let (new_order, new_orderbook, trades) = scan_orders(&orderbook, order);

        for (_i, item) in new_orderbook.iter().enumerate(){
            assert_eq!(item.amount, item.amount_filled)
        }
        assert_eq!(new_order.amount_filled, 250.0);
        assert_eq!(trades.len(), 2)
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
                let kind = rand_true_false();
                let order = Order{
                    id: x,
                    kind,
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