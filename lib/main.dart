import 'package:flutter/material.dart';
import 'package:practice_sqlite_database/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map<String, dynamic>> journals = [];

  bool isLoading = true;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void refreshJournals()async{
    final data = await SQLHelper.getItems();
    setState(() {
      journals = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    refreshJournals();
    print('Number_of_Items:-> ${journals.length}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text('SQLite'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: journals.length,
            itemBuilder: (context, index){
              return Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(journals[index]['title']),
                  subtitle: Text(journals[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: (){
                              showForm(journals[index]['id']);
                            },
                            icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: (){},
                            icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),

                ),
              );
            }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()=> showForm(null),
      ),
    );
  }

  void showForm(int? id)async {
    if(id != null){
      final existingJournal = journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournal['title'];
      descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_)=> Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: 'description'),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: ()async{
                      if(id == null){
                        await addItem();
                      }
                      if(id != null){
                         await updateItem(id);
                      }
                      titleController.clear();
                      descriptionController.clear();
                      Navigator.of(context).pop();

                    },
                    child: Text(id == null? 'Create New': 'Update'),
                ),
              ],
            ),
          ),
        )
    );

  }

  Future<void> addItem() async {
    await SQLHelper.createItem(
        titleController.text,
        descriptionController.text,
    );
    refreshJournals();
    print('Number_of_Items:-> ${journals.length}');
  }

  Future<void> updateItem(int id) async{
    await SQLHelper.updateItem(
        id,
        titleController.text,
        descriptionController.text,
    );
    refreshJournals();
  }
}


