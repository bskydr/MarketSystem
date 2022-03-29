import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:marketsystem/layout/market_controller.dart';
import 'package:marketsystem/models/product.dart';
import 'package:marketsystem/shared/components/default_button.dart';
import 'package:marketsystem/shared/components/default_text_form.dart';
import 'package:marketsystem/shared/toast_message.dart';

class AddProductToMyStoreScreen extends StatefulWidget {
  @override
  State<AddProductToMyStoreScreen> createState() =>
      _AddProductToMyStoreScreenState();
}

class _AddProductToMyStoreScreenState extends State<AddProductToMyStoreScreen> {
  var text_productNameController = TextEditingController();

  var text_barcode_controller = TextEditingController();

  var text_qty_controller = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isEnable = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketController>(
      init: Get.find<MarketController>(),
      builder: (marketController) => Scaffold(
        appBar: AppBar(
          title: Text("Add Product To Store"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      height: 50,
                      child: TypeAheadField(
                        hideOnError: true,
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: text_productNameController,
                            enabled: _isEnable,
                            autofocus: true,
                            style: TextStyle(fontSize: 24),
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: "Select Product ...")),
                        suggestionsCallback: (pattern) async {
                          return await marketController
                              .search_In_Store(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: Icon(Icons.shopping_cart),
                            title: Text(
                                (suggestion as ProductModel).name.toString()),
                            subtitle: Text('${suggestion.price.toString()} LL'),
                          );
                        },
                        onSuggestionSelected: (Object? suggestion) {
                          print((suggestion as ProductModel).barcode);
                          text_productNameController.text =
                              suggestion.name.toString();
                          text_barcode_controller.text =
                              suggestion.barcode.toString();
                          setState(() {
                            _isEnable = false;
                          });
                        },

                        // onSuggestionSelected: (suggestion) {
                        //   Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => ProductPage(product: suggestion)
                        //   ));
                        // },
                      ),
                    ),
                    !_isEnable
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                text_productNameController.clear();
                                _isEnable = true;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade500,
                            ))
                        : SizedBox(
                            width: 2,
                          ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                defaultTextFormField(
                    controller: text_qty_controller,
                    onvalidate: (value) {
                      if (value!.isEmpty) {
                        return "Quantity must not be empty";
                      }
                    },
                    inputtype: TextInputType.phone,
                    border: UnderlineInputBorder(),
                    hinttext: "Quantity"),
                SizedBox(
                  height: 10,
                ),
                defaultButton(
                    text: "Save",
                    onpress: () {
                      if (_formkey.currentState!.validate()) {
                        int? qty =
                            int.tryParse(text_qty_controller.text.toString());
                        if (qty != null) {
                        } else {
                          showToast(
                              message: "Quantity Must be a number ",
                              status: ToastStatus.Error);
                        }
                      }

                      print(text_barcode_controller.text.toString());
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
