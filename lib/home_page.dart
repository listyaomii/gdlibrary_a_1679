import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdlibrary_a_1679/invoice/model/product.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:uuid/uuid.dart';
import 'package:gdlibrary_a_1679/pdf_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String id = const Uuid().v1();
  File? image;

  List<Product> product = [
    Product("Membership", 50000),
    Product("Books", 50000),
    Product("Pen", 50000),
    Product("Snacks", 50000),
    Product("Hamburger", 50000),
  ];

  int number = 0;
  getTotal() => product
      .fold(0.0,
          (double prev, element) => prev + (element.price * element.amount))
      .toStringAsFixed(2);

  getPPN() => product
      .fold(
          0.0,
          (double prev, element) =>
              prev +
              (element.price / 100 * element.ppnInPercent * element.amount))
      .toStringAsFixed(2);

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image : $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Container inputPersonalData() {
    return Container(
      margin: EdgeInsets.all(3.h),
      child: Column(children: [
        Center(
          child: Text(
            'Fill This Form',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 2.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                onPressed: () {
                  pickImageC();
                },
                child: const Text("Pick Image from Camera"),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 2.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                onPressed: () {
                  pickImage();
                },
                child: const Text("Pick Image from gallery"),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
        if (image != null)
          Column(
            children: [
              kIsWeb ? Image.network(image!.path) : Image.file(image!),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                child: IconButton(
                  color: Colors.red,
                  iconSize: 5.h,
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      image = null;
                    });
                  },
                ),
              )
            ],
          )
        else
          const Text("No image selected"),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
              hintText: 'Enter your name', labelText: 'Name'),
        ),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
              hintText: 'Enter your phone number', labelText: 'Phone number'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(
              hintText: 'Enter your address', labelText: 'Address'),
        ),
      ]),
    );
  }

  Padding inputProduct() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemBuilder: (context, index) {
                final currentProduct = product[index];
                return Row(
                  children: [
                    Expanded(child: Text(currentProduct.name)),
                    Expanded(
                        child: Text(
                            "Price: Rp ${currentProduct.price.toStringAsFixed(2)}")),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                setState(() => currentProduct.amount++);
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currentProduct.amount.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                setState(() => currentProduct.amount--);
                              },
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              itemCount: product.length,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text("Total"), Text("Rp ${getTotal()}")],
          )
        ],
      ),
    );
  }

  Container buttonCreatePDF(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: ElevatedButton(
        onPressed: () {
          if (image == null ||
              nameController.text.isEmpty ||
              phoneController.text.isEmpty ||
              addressController.text.isEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Warning"),
                content: const Text('Please fill in all the fileds.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          } else {
            createPdf(nameController, phoneController, addressController, id,
                image!, context, product);
            setState(() {
              const uuid = Uuid();
              id = uuid.v1();
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        child: const Text('Create PDF'),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(
        'Modul Library',
        style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            inputPersonalData(),
            SizedBox(height: 5.h),
            Center(
              child: Text(
                'Buy Product',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            inputProduct(),
            buttonCreatePDF(context)
          ],
        ),
      ),
    );
  }
}
