#![feature(test)] extern crate test;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate rustler;
//#[macro_use] extern crate lazy_static;
extern crate rand;

mod atoms;
mod orders;

use rustler::{Env, Term, NifResult, Encoder};



fn match_order<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let order: orders::Order = args[0].decode()?;
    let orderbook: Vec<orders::Order> = args[1].decode()?;
    let orderbook_inverse: Vec<orders::Order> = args[2].decode()?;
    
    /*
        new_order = order with amount_fulfilled
        new_orderbook_inverse = modified orders with ^orderbook_inverse
    */
    let (new_order, new_orderbook_inverse, trades) = orders::scan_orders(&orderbook_inverse, order);
    let orderbook: Vec<orders::Order> = orders::add_order(orderbook, new_order.clone(), trades.len());
    let orderbook_inverse: Vec<orders::Order> = orders::update_orders(orderbook_inverse, new_orderbook_inverse.clone());
    Ok((atoms::ok(), orders::Outputs{
        orderbook,
        orderbook_inverse,
        trades,
        order: new_order,
        modified_orders: new_orderbook_inverse,
    }).encode(env))
}


rustler_export_nifs! {
    "Elixir.BinbaseBackend.Engine.Native",
    [("match_order", 3, match_order)],
    None
}

