import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;

  var _formKey = GlobalKey<FormState>();

  NoteDetailState(this.note, this.appBarTitle);
  static var _priorities = ['High', 'Low'];

  bool _isPopping = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium ?? TextStyle();

    titleController.text = note.title;
    descriptionController.text = note.description ?? '';

    return WillPopScope(
        onWillPop: () async {
          return await moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),

          body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: [

            // First Element
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),

                style: textStyle,

                value: getPriorityAsString(note.priority),

                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('User selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser!);
                  });
                },
              ),
            ),

            // Second Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),

              child: TextFormField(
                controller: titleController,
                style: textStyle,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value){
                  debugPrint('Something changed in Title Text Field');
                  updateTitle();
                },

                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )
                ),
              ),
            ),

            // Third Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),

              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in Description Text Field');
                  updateDescription();
                },

                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )
                ),
              ),
            ),

            // Fourth Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 16 * 1.5)),
                      onPressed: () {
                        setState(() {
                          debugPrint('Save button clicked');
                          _save();
                          },
                        );
                      },
                    ),
                  ),

                  Container(width: 5.0,),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text('Delete', style: TextStyle(fontSize: 16 * 1.5)),
                      onPressed: () {
                        setState(() {
                          debugPrint('Delete button clicked');
                          _delete();
                        });
                      },
                    ),
                  ),


                ],
              ),
            ),

          ],
        ),
      ),

    )));
  }

  Future<bool> moveToLastScreen() async {
    if (!_isPopping) {
      _isPopping = true;
      Navigator.of(context).pop(true);
      return false;
    }
    return true;
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value){
    String? priority;
    switch (value){
      case 1:
        priority = _priorities[0];  // High
        break;
      case 2:
        priority = _priorities[1];  // Low
        break;
    }
    return priority!;
  }

  // Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription(){
    note.description = descriptionController.text.isNotEmpty ? descriptionController.text : null;
  }

  void _delete() async {
    Navigator.pop(context, true);  // Return true to indicate changes

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to the detail page by pressing the FAB of NoteList page.
    if(note.id == null){
      _showAlertDialog('Status', 'No note was Deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id!);
    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    }else{
      _showAlertDialog('Status', 'Error Occurred while Deleting Note');
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      moveToLastScreen();

      note.date = DateFormat.yMMMd().format(DateTime.now());
      int result;

      if (note.id != null) {  // Case 1: Update operation
        result = await helper.updateNote(note);
      } else {  // Case 2: Insert Operation
        result = await helper.insertNote(note);
        // Instead of setting the id directly, we create a new Note object with the returned id
        if (result != 0) {
          note = Note.withId(result, note.title, note.date, note.priority, note.description);
        }
      }

      if (result != 0) {  // Success
        _showAlertDialog('Status', 'Note Saved Successfully');
        Navigator.pop(context, true);  // Return true to indicate changes
      } else {  // Failure
        _showAlertDialog('Status', 'Problem Saving Note');
        Navigator.pop(context, false);  // Return false to indicate no changes
      }
    }
  }


  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

}