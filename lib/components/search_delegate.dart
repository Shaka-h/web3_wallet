import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> listObhects;

  CustomSearchDelegate(this.listObhects);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.cancel))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, String>> newList = [];
    for (var element in listObhects) {
      var value = element.values.first;
      if (value.contains(query)) {
        newList.add(element);
      }
    }

    return ListView.builder(
        itemCount: newList.length, itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(newList[index]['image']!),
            title: Text(newList[index]['name']!),
            subtitle: Text(newList[index]['id'] ?? ''),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List newList = [];
    for (var element in listObhects) {
      var value = element.values.first;
      if (value.contains(query)) {
        newList.add(value);
      }
    }
    return ListView.builder(
        itemCount: newList.length, itemBuilder: (context, index) {
          return ListTile(
            title: Text(newList[index]),
            onTap: () {
              query = newList[index];
              showResults(context);
            },
          );
        });
  }
}
