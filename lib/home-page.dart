import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _toDoController = TextEditingController();

  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {

    super.initState();

    _readData().then((data) {
      
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("To-do List"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget> [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "New task",
                    ),
                  ),
                ),
                Container(
                  height: 55.0,
                  padding: EdgeInsets.only(left: 5.0),
                  child: RaisedButton(
                    child: Icon(Icons.add),
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    onPressed: _addToDo, 
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: _buildItem
              ),
              onRefresh: _refresh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      onDismissed: (direction) {

        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);

          _lastRemovedPos = index;

          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Task \"${_lastRemoved["title"]}\" removed."),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {

                setState(() {

                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
                });
              },
            ),
          );

          Scaffold.of(context).removeCurrentSnackBar();  
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["check"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["check"] ?
              Icons.check :
              Icons.error,
            color: Colors.white,
          ),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["check"] = c;
            _saveData();
          });
        },
      ),
    );
  }

  void _addToDo() {

    setState(() {
      Map<String, dynamic> newToDo = Map();

      newToDo["title"] = _toDoController.text;

      _toDoController.text = "";

      newToDo["check"] = false;

      _toDoList.add(newToDo);

      _saveData();
    });    
  }

  Future<Null> _refresh() async {

    await Future.delayed(Duration(seconds: 1));

      setState(() {

        _toDoList.sort((a, b){
          if(a["check"] && !b["check"]) return 1;
          else if(!a["check"] && b["check"]) return -1;
          else return 0;
        });

        _saveData();
      });

    return null;
  }

  Future<File> _getFile() async {

    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {

    String data = json.encode(_toDoList);

    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {

      final file = await _getFile();

      return file.readAsString();
    } catch(e) {

      return null;
    }
  }
}

