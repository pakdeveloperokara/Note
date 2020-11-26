import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_note/models/note.dart';
import 'package:flutter_app_note/utils/database_helper.dart';
import 'package:flutter_app_note/screens/note_detail.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {
  final String navigatorTitle;
  final Note note;
  NoteDetail(this.note,this.navigatorTitle);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note,this.navigatorTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appTitle;
  Note note;
  _NoteDetailState(this.note,this.appTitle);
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleEditionController=TextEditingController();
  TextEditingController descriptionEditionController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;
    titleEditionController.text = note.title;
    descriptionEditionController.text = note.description;
    return WillPopScope(
      onWillPop: (){
        backToMain();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
          leading: IconButton(
            icon: Icon(Icons.add_to_home_screen_sharp),
            onPressed: (){
              backToMain();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15,left: 10,right: 10),
          child: ListView(
            children: [
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownitme){
                    return DropdownMenuItem(
                      value: dropDownitme,
                      child: Text(dropDownitme),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSetbyuser){
                    setState(() {
                      debugPrint("drop down set $valueSetbyuser");
                      updatePriorityAsInt(valueSetbyuser);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15,bottom: 10),
                child: TextField(
                  controller: titleEditionController,
                  style: textStyle,
                  onChanged: (String mTitle){
                    debugPrint("Enter Text for title");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15,bottom: 10),
                child: TextField(
                  controller: descriptionEditionController,
                  style: textStyle,
                  onChanged: (String mTitle){
                    debugPrint("Enter Text for Description");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15,bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            "SAVE",
                            textScaleFactor: 1.5,
                          ),
                          onPressed: (){
                            debugPrint("Save Button Press");
                            _save();
                          },
                        )
                    ),Container(width: 15,),
                    Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            "DELETE",
                            textScaleFactor: 1.5,
                          ),
                          onPressed: (){
                            debugPrint("Delete Button Press");
                            _delete();
                          },
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void backToMain(){
    Navigator.pop(context,true);
  }
  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];  // 'High'
        break;
      case 2:
        priority = _priorities[1];  // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle(){
    note.title = titleEditionController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionEditionController.text;
  }

  // Save data to database
  void _save() async {

    backToMain();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await helper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }

  void _delete() async {

    backToMain();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }
  void _showAlertDialog(String title, String message) {

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
