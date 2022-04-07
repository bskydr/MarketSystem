import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:get/get.dart';
import 'package:marketsystem/controllers/products_controller.dart';
import 'package:marketsystem/models/product.dart';
import 'package:marketsystem/shared/components/default_button.dart';
import 'package:marketsystem/shared/components/default_text_form.dart';
import 'package:marketsystem/shared/constant.dart';
import 'package:marketsystem/shared/styles.dart';
import 'package:marketsystem/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SellScreen extends StatefulWidget {
  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  List<String> headertitles = ['Name', 'BarCode', 'Price', 'Qty', ''];
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewcontroller;
  Barcode? barCode = null;

  var qtyController = TextEditingController();
  var receivedCashController = TextEditingController();

  bool _iscashSuccess = false;

  @override
  void dispose() {
    // TODO: implement dispose
    this.qrViewcontroller?.dispose();
    super.dispose();
  }

  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await qrViewcontroller?.pauseCamera();
    }
    qrViewcontroller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    var prod_controller = Provider.of<ProductsController>(context);
    return Scaffold(
      body: prod_controller.isloadingGetProducts
          ? Center(child: CircularProgressIndicator())
          : _iscashSuccess
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    color: defaultColor.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          child: Icon(
                            Icons.done,
                            size: 50,
                            color: defaultColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Order Completed!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(
                          "Your Order was Completed successfully",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        _continueButton(),
                      ],
                    ),
                  ),
                )
              : Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    _buildQr(context),

                    Positioned(
                      top: 10,
                      child: _buildControlButton(),
                    ),
                    if (barCode != null)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: DataTable(
                                        headingTextStyle:
                                            TextStyle(color: defaultColor),
                                        border: TableBorder.all(
                                            width: 1, color: Colors.grey),
                                        columns: [
                                          ...headertitles
                                              .map((e) => _build_header_item(e))
                                        ],
                                        rows: [
                                          ...prod_controller.basket_products
                                              .map((e) =>
                                                  _build_Row(e, context)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _buildTotalPrice(prod_controller),
                            Container(
                              height: 10,
                              color: Colors.white,
                            ),
                            _buildSubmitRow(prod_controller),
                          ],
                        ),
                      ),
                    // DataTable(
                    //   headingTextStyle: TextStyle(color: defaultColor),
                    //   border: TableBorder.all(width: 1, color: Colors.grey),
                    //   columns: [
                    //     ...headertitles.map((e) => _build_header_item(e))
                    //   ],
                    //   rows: [
                    //     ...prod_controller.list_ofProduct_inStore.map(
                    //         (e) =>
                    //             _build_Row(e, marketController, context)),
                    //   ],
                    // ),
                  ],
                ),
    );
  }

  _buildSubmitRow(ProductsController controller) => Container(
        width: double.infinity,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: defaultButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  text: "Cash",
                  onpress: () {
                    Alert(
                        context: context,
                        title: "Cash",
                        content: Column(
                          children: <Widget>[
                            Text(
                              'Total : ${controller.totalprice.toString()} LL',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        buttons: [
                          DialogButton(
                            onPressed: () {
                              controller.addFacture();
                              // controller.clearBasket();
                              setState(() {
                                barCode = null;
                                _iscashSuccess = true;
                              });

                              Navigator.pop(context);
                            },
                            child: Text(
                              "Enter",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ]).show();
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: defaultButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  text: "Add More",
                  onpress: () {
                    qrViewcontroller!.resumeCamera();
                    setState(() {
                      barCode = null;
                    });
                  }),
            ),
          ],
        ),
      );

  _buildControlButton() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                qrViewcontroller!.toggleFlash();
              },
              icon: Icon(
                Icons.flash_on,
                color: defaultColor,
              ))
        ],
      );

  _build_header_item(String headerTitle) => DataColumn(
      label: Text(headerTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )));

  _build_Row(ProductModel model, BuildContext context) => DataRow(cells: [
        DataCell(Text(model.name.toString())),
        DataCell(Text(model.barcode.toString())),
        DataCell(Text(model.price.toString())),
        DataCell(
            Text(
              model.qty.toString(),
              style: TextStyle(
                  color: defaultColor, decoration: TextDecoration.underline),
            ), onTap: () {
          Alert(
              context: context,
              title: "Enter Qty",
              content: Column(
                children: <Widget>[
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                    ),
                  ),
                ],
              ),
              buttons: [
                DialogButton(
                  onPressed: () {
                    context.read<ProductsController>().onchangeQtyInBasket(
                        model.barcode.toString(), qtyController.text);
                    Navigator.pop(context);
                    qtyController.clear();
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
        }),
        DataCell(IconButton(
            onPressed: () {
              context
                  .read<ProductsController>()
                  .deleteProductFromBasket(model.barcode.toString());
            },
            icon: Icon(Icons.close))),
      ]);

  _buildQr(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreatedCallback,
        overlay: QrScannerOverlayShape(
            borderColor: defaultColor,
            borderWidth: 7,
            borderLength: 20,
            borderRadius: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.7),
      );

  void onQRViewCreatedCallback(QRViewController controller) {
    setState(() {
      this.qrViewcontroller = controller;
      //this.context = context;
    });

    qrViewcontroller?.scannedDataStream.listen((barcode) => setState(() {
          this.barCode = barcode;
          qrViewcontroller?.pauseCamera();
          FlutterBeep.beep();
          context
              .read<ProductsController>()
              .fetchProductBybarCode(barcode.code.toString());
        }));
  }

  _buildTotalPrice(ProductsController controller) => Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Total Price : ",
              style: TextStyle(color: Colors.red[300], fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              controller.totalprice.toString() + " LL",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      );

  _continueButton() => GestureDetector(
        onTap: () {
          setState(() {
            _iscashSuccess = false;
            qrViewcontroller!.resumeCamera();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(
              'Continue',
              style: TextStyle(color: defaultColor, letterSpacing: 2),
            ),
            Container(
              child: Icon(Icons.navigate_next, color: Colors.white),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: defaultColor,
              ),
            ),
          ]),
        ),
      );
}
