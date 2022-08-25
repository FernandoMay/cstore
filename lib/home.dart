import 'package:cstore/detail.dart';
import 'package:cstore/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int days = 30;

  final String name = "Codepur";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    final catalogJson =
        await rootBundle.loadString("assets/files/catalog.json");
    final decodedData = jsonDecode(catalogJson);
    var productsData = decodedData["products"];
    Catalog.items = List.from(productsData)
        .map<Item>((item) => Item.fromMap(item))
        .toList();
    (VxState.store as Store).items = Catalog.items;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Store store = VxState.store;
    return Scaffold(
        backgroundColor: context.canvasColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              store.navigator.routeManager.push(Uri.parse("/cart")),
          backgroundColor: context.theme.secondaryHeaderColor,
          child: const Icon(
            CupertinoIcons.cart,
            color: Colors.white,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: Vx.m32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Catalog App"
                        .text
                        .xl5
                        .bold
                        .color(context.theme.secondaryHeaderColor)
                        .make(),
                    "Trending products".text.xl2.make(),
                  ],
                ),
                CupertinoSearchTextField(
                  onChanged: (value) {
                    SearchMutation(value);
                  },
                ).py12(),
                if (Catalog.items.isNotEmpty)
                  const CatalogList().py16().expand()
                else
                  const CircularProgressIndicator().centered().expand(),
              ],
            ),
          ),
        ));
  }
}

class CatalogList extends StatelessWidget {
  const CatalogList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Store store = VxState.store;
    return Scrollbar(
      child: VxBuilder(
        mutations: const {SearchMutation},
        builder: (context, _, _a) => !context.isMobile
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: store.items.length,
                itemBuilder: (context, index) {
                  final catalog = store.items[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Detail(catalog: catalog),
                      ),
                    ),
                    child: CatalogItem(catalog: catalog),
                  );
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: store.items.length,
                itemBuilder: (context, index) {
                  final catalog = store.items[index];
                  return InkWell(
                    onTap: () => context.vxNav.push(
                      Uri(
                          path: "/detail",
                          queryParameters: {"id": catalog.id.toString()}),
                    ),
                    child: CatalogItem(catalog: catalog),
                  );
                },
              ),
      ),
    );
  }
}

class CatalogItem extends StatelessWidget {
  final Item catalog;

  const CatalogItem({Key? key, required this.catalog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VxBox(
      child: Row(
        children: [
          Hero(
              tag: Key(catalog.id.toString()),
              child: Image.network(
                catalog.image,
              )
                  .box
                  .rounded
                  .p8
                  .color(context.canvasColor)
                  .make()
                  .p16()
                  .w40(context)),
          VxBuilder(
            mutations: const {ChangeQuantity},
            builder: (context, _, _a) => Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                catalog.name.text.lg.color(context.accentColor).bold.make(),
                catalog.desc.text.textStyle(context.captionStyle).make(),
                10.heightBox,
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  buttonPadding: EdgeInsets.zero,
                  children: [
                    "\$${catalog.totalPrice}".text.bold.xl.make(),
                    AddToCart(catalog: catalog),
                  ],
                ).pOnly(right: 8.0)
              ],
            )),
          )
        ],
      ),
    ).color(context.cardColor).rounded.square(150).make().py16();
  }
}
