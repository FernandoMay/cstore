import 'package:cstore/models.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:velocity_x/velocity_x.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: "Cart".text.make(),
      ),
      body: Column(
        children: [
          _CartList().p32().expand(),
          const Divider(),
          _CartTotal(),
        ],
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  final _paymentItems = <PaymentItem>[];
  @override
  Widget build(BuildContext context) {
    final Cart _cart = (VxState.store as Store).cart;
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          VxBuilder(
            mutations: const {RemoveMutation},
            builder: (context, _, _a) {
              _paymentItems.add(PaymentItem(
                amount: _cart.totalPrice.toString(),
                label: "Codepur course",
                status: PaymentItemStatus.final_price,
              ));
              return "\$${_cart.totalPrice}"
                  .text
                  .xl5
                  .color(context.theme.accentColor)
                  .make();
            },
          ),
          30.widthBox,
          Row(
            children: [
              ApplePayButton(
                paymentConfigurationAsset: 'applepay.json',
                paymentItems: _paymentItems,
                width: 200,
                height: 50,
                style: ApplePayButtonStyle.black,
                type: ApplePayButtonType.buy,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: (data) {
                  print(data);
                },
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              GooglePayButton(
                paymentConfigurationAsset: 'gpay.json',
                paymentItems: _paymentItems,
                width: 200,
                height: 50,
                style: GooglePayButtonStyle.black,
                type: GooglePayButtonType.pay,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: (data) {
                  print(data);
                },
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          )
          // ElevatedButton(
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       content: "Buying not supported yet.".text.make(),
          //     ));
          //   },
          //   style: ButtonStyle(
          //       backgroundColor:
          //           MaterialStateProperty.all(context.theme.buttonColor)),
          //   child: "Buy".text.white.make(),
          // ).w32(context)
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VxState.watch(context, on: [RemoveMutation]);
    final Cart _cart = (VxState.store as Store).cart;
    return _cart.items.isEmpty
        ? "Nothing to show".text.xl3.makeCentered()
        : ListView.builder(
            itemCount: _cart.items.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.done),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => RemoveMutation(_cart.items[index]),
              ),
              title: _cart.items[index].name.text.make(),
            ),
          );
  }
}
