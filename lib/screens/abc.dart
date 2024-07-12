import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Simple Interest Calculator App",
      home: SIForm(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          accentColor: Colors.indigoAccent,
        ),
      ),
    ),
  );
}

class SIForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SIFormState();
  }
}

class _SIFormState extends State<SIForm> {

  var _formKey = GlobalKey<FormState>();
  var _currencies = ['Rupees', 'Dollars', 'Pounds'];
  var _currentItemSelected = '';
  final _minimumPadding = 5.0;
  TextEditingController principalController = TextEditingController();
  TextEditingController roiController = TextEditingController();
  TextEditingController termController = TextEditingController();
  var displayResult = '';

  @override
  void initState() {
    super.initState();
    _currentItemSelected = _currencies[0];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium ?? TextStyle();

    return Scaffold(

      appBar: AppBar(
        title: Text('Simple Interest Calculator'),
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: [

              getImageAsset(),

              Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: textStyle,
                  controller: principalController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter principal amount';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) { // Check if input contains only digits
                      return 'Please enter numbers only';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Principal',
                    hintText: 'Enter Principal e.g. 1200',
                    labelStyle: textStyle,
                    errorStyle: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 15.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: textStyle,
                  controller: roiController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rate of interest';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Please enter numbers only';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Rate of Interest',
                    hintText: 'In percent',
                    labelStyle: textStyle,
                    errorStyle: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 15.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: textStyle,
                        controller: termController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter time';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Please enter numbers only';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Term',
                          hintText: 'Time in years',
                          labelStyle: textStyle,
                          errorStyle: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 15.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Container(width: _minimumPadding * 5),
                    Expanded(
                      child: DropdownButton<String>(
                        items: _currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: _currentItemSelected,
                        onChanged: (String? newValueSelected) {
                          if (newValueSelected != null) {
                            _onDropDownItemSelected(newValueSelected);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        ),
                        child: Text('Calculate', style: TextStyle(fontSize: 16 * 1.5)),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                              displayResult = _calculateTotalReturns();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Text('Reset', style: TextStyle(fontSize: 16 * 1.5)),
                        onPressed: () {
                          setState(() {
                            _reset();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(_minimumPadding * 2),
                child: Text(displayResult, style: textStyle),
              ),

            ],
          ),
        ),

      ),
    );
  }

  Widget getImageAsset() {
    AssetImage assetImage = AssetImage('images/money.png');
    Image image = Image(image: assetImage, width: 125.0, height: 125.0);
    return Container(child: image, margin: EdgeInsets.all(_minimumPadding * 10));
  }

  void _onDropDownItemSelected(String newValueSelected) {
    setState(() {
      _currentItemSelected = newValueSelected;
    });
  }

  String _calculateTotalReturns() {
    double principal = double.parse(principalController.text);
    double roi = double.parse(roiController.text);
    double term = double.parse(termController.text);
    double totalAmountPayable = principal + (principal * roi * term) / 100;
    String result = 'After $term years, your investment will be worth $totalAmountPayable $_currentItemSelected';
    return result;
  }

  void _reset() {
    _currentItemSelected = _currencies[0];
    principalController.text = '';
    roiController.text = '';
    termController.text = '';
    displayResult = '';
  }
}
