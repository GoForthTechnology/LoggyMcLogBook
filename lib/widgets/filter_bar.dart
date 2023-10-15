import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Filter<T> {
  final String label;
  final bool Function(T) predicate;

  Filter({required this.label, required this.predicate});

  bool operator==(Object other) => other is Filter && label == other.label;

  int get hashCode => label.hashCode;
}

class FilterBarModel<T> extends ChangeNotifier {
  final Map<Filter<T>, bool> filters = {};
  final _queryController = TextEditingController();

  FilterBarModel(List<Filter<T>> filters) {
    for (var filter in filters) {
      this.filters.putIfAbsent(filter, () => true);
    }
    _queryController.addListener(() => notifyListeners());
  }

  List<Filter<T>> activeFilters() {
    return filters.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  List<Filter<T>> inactiveFilters() {
    return filters.entries.where((e) => !e.value).map((e) => e.key).toList();
  }

  void activateFilter(Filter<T> filter) {
    filters[filter] = true;
    notifyListeners();
  }

  void deactivateFilter(Filter<T> filter) {
    filters[filter] = false;
    notifyListeners();
  }

  bool filter(T item) {
    bool matchesFilter = true;
    if (activeFilters().isNotEmpty) {
      matchesFilter = false;
      for (var filter in activeFilters()) {
        if (filter.predicate(item)) {
          matchesFilter = true;
        }
      }
    }
    var query = _queryController.text.toLowerCase();
    String itemTitle = item.toString().toLowerCase();
    bool matchesQuery = query.isEmpty || itemTitle.contains(query);
    return matchesFilter && matchesQuery;
  }
}

class FilterBar<T> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FilterBarModel<T>>(builder: (context, model, child) {
      return Padding(padding: EdgeInsets.all(4), child: TextField(
        controller: model._queryController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Query",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          suffixIcon: _filterWidgets(context, model),
        ),
      ));
    });
  }

  Widget _filterWidgets(BuildContext context, FilterBarModel<T> model) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...model.activeFilters()
          .map((f) => _FilterChip(filter: f, onDeleted: (df) => model.deactivateFilter(f),))
          .toList(),
      if (model.inactiveFilters().isNotEmpty) IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () => showDialog(context: context, builder: (context) => _alertDialog(model, context)),
      ),
    ],);
  }

  AlertDialog _alertDialog(FilterBarModel<T> model, BuildContext context) {
    return AlertDialog(
      title: Text("Add Filter"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: model.inactiveFilters().map((f) => TextButton(
          onPressed: () {
            model.activateFilter(f);
            Navigator.of(context).pop();
          },
          child: Text(f.label),
        )).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final Filter filter;
  final Function(Filter) onDeleted;

  const _FilterChip({required this.filter, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Chip(
        label: Text(filter.label),
        deleteIcon: Icon(Icons.remove_circle_outline),
        onDeleted: () => onDeleted(filter),
      ),);
  }
}
