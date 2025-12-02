import 'package:flutter/material.dart';
import '../../storage/truth_dare_local_storage.dart';

class TruthDareCustomWordsScreen extends StatefulWidget {
  const TruthDareCustomWordsScreen({super.key});

  @override
  State<TruthDareCustomWordsScreen> createState() =>
      _TruthDareCustomWordsScreenState();
}

class _TruthDareCustomWordsScreenState
    extends State<TruthDareCustomWordsScreen> {
  final _truthController = TextEditingController();
  final _dareController = TextEditingController();

  List<String> truths = [];
  List<String> dares = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    truths = await TruthDareLocalStorage.getTruths();
    dares = await TruthDareLocalStorage.getDares();
    setState(() {});
  }

  Future<void> _addTruth() async {
    if (_truthController.text.trim().isEmpty) return;
    await TruthDareLocalStorage.addTruth(_truthController.text.trim());
    _truthController.clear();
    _load();
  }

  Future<void> _addDare() async {
    if (_dareController.text.trim().isEmpty) return;
    await TruthDareLocalStorage.addDare(_dareController.text.trim());
    _dareController.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Truth & Dare")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Add Truth"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _truthController,
                    decoration: const InputDecoration(
                      hintText: "Enter custom truth",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: _addTruth, icon: const Icon(Icons.add)),
              ],
            ),

            const SizedBox(height: 10),
            const Text("Add Dare"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dareController,
                    decoration: const InputDecoration(
                      hintText: "Enter custom dare",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: _addDare, icon: const Icon(Icons.add)),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Custom Truths"),
            Expanded(
              child: ListView.builder(
                itemCount: truths.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(truths[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await TruthDareLocalStorage.deleteTruth(i);
                      _load();
                    },
                  ),
                ),
              ),
            ),

            const Text("Custom Dares"),
            Expanded(
              child: ListView.builder(
                itemCount: dares.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(dares[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await TruthDareLocalStorage.deleteDare(i);
                      _load();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
