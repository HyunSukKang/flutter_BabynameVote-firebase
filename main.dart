import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _newBabyname();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.delete,),
            onPressed: () => record.reference.delete(),
          ),
          title: Text(record.name),
          trailing: FittedBox(
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () => record.reference.updateData({'votes': FieldValue.increment(1)}),
                    ),
                    Text(record.votes.toString()),
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: () => record.reference.updateData({'dislike': FieldValue.increment(1)}),
                    ),
//                    SizedBox(height: 5,),
                    Text(record.dislike.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _newBabyname() {
    final _babynameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add a baby name',
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: _babynameController,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                _registerBabyname(context, _babynameController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _registerBabyname(BuildContext context, String name) {
    Firestore.instance.collection('baby').document().setData({'name': name, 'votes': 0, 'dislike': 0});
    Navigator.of(context).pop();
  }
}

class Record {
  final String name;
  final int votes;
  final int dislike;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        assert(map['dislike'] != null),
        name = map['name'],
        votes = map['votes'],
        dislike = map['dislike'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}