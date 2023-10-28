import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterableListView<T> extends StatelessWidget {
  final Stream<List<T>> itemStream;
  final List<Filter<T>> filters;
  final Sort<T> defaultSort;
  final List<Sort<T>> additionalSortingOptions;
  final Widget Function(T) buildTile;

  const FilterableListView({super.key, required this.itemStream, required this.filters, required this.defaultSort, this.additionalSortingOptions =  const [], required this.buildTile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(stream: itemStream, initialData: [], builder: (context, snapshot) {
      var items = snapshot.data ?? [];
      return ChangeNotifierProvider<FilterBarModel<T>>(
        create: (BuildContext context) => FilterBarModel(
          filters: filters,
          defaultSort: defaultSort,
          additionalSortingOptions: additionalSortingOptions,
        ),
        builder: (context, child) => Column(children: [
          FilterBar<T>(),
          Consumer<FilterBarModel<T>>(builder: (context, model, child) {
            var filteredItems = items.where((cd) => model.filter(cd)).toList();
            var sortedItems = model.getSorted(filteredItems);
            return Expanded(child: ListView.builder(
              itemCount: sortedItems.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) => buildTile(sortedItems[index]),
            ));
          }),
        ],),
      );
    });
  }
}

class Filter<T> {
  final String label;
  final bool Function(T) predicate;

  Filter({required this.label, required this.predicate});

  bool operator==(Object other) => other is Filter && label == other.label;
  int get hashCode => label.hashCode;
}

class Sort<T> {
  final String label;
  final Comparator<T> comparator;

  Sort({required this.label, required this.comparator});

  bool operator==(Object other) => other is Sort && label == other.label;
  int get hashCode => label.hashCode;
}

enum SortDirection {
  ASC, DESC;
}

class FilterBarModel<T> extends ChangeNotifier {
  final Map<Filter<T>, bool> filters = {};
  final List<Sort<T>> additionalSortingOptions;
  final Sort<T> defaultSort;

  Sort<T> _activeSort;
  SortDirection _sortDirection = SortDirection.ASC;
  final _queryController = TextEditingController();

  FilterBarModel({
    required List<Filter<T>> filters,
    required this.defaultSort,
    required this.additionalSortingOptions,
  }) : _activeSort = defaultSort {
    for (var filter in filters) {
      this.filters.putIfAbsent(filter, () => true);
    }
    _queryController.addListener(() => notifyListeners());
  }

  List<T> getSorted(List<T> items) {
    items.sort(_activeSort.comparator);
    if (_sortDirection == SortDirection.DESC) {
      return List.from(items.reversed);
    }
    return List.from(items);
  }

  List<Sort<T>> sortingOptions() {
    return [defaultSort, ...additionalSortingOptions];
  }

  List<Filter<T>> activeFilters() {
    return filters.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  List<Filter<T>> inactiveFilters() {
    return filters.entries.where((e) => !e.value).map((e) => e.key).toList();
  }

  void setSort(Sort<T> sort, SortDirection direction) {
    _activeSort = sort;
    _sortDirection = direction;
    notifyListeners();
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
      return Padding(padding: EdgeInsets.all(4), child: Row(children: [
        Expanded(child: TextField(
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
        )),
        IconButton(
          icon: Icon(Icons.sort),
          onPressed: () => showDialog(context: context, builder: (context) => _changeSortingDialog(model, context)),
        ),
      ],));
    });
  }

  Widget _filterWidgets(BuildContext context, FilterBarModel<T> model) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...model.activeFilters()
          .map((f) => _FilterChip(filter: f, onDeleted: (df) => model.deactivateFilter(f),))
          .toList(),
      if (model.inactiveFilters().isNotEmpty) IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () => showDialog(context: context, builder: (context) => _addFilterDialog(model, context)),
      ),
    ],);
  }

  AlertDialog _addFilterDialog(FilterBarModel<T> model, BuildContext context) {
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

  AlertDialog _changeSortingDialog(FilterBarModel<T> model, BuildContext context) {
    return AlertDialog(
      title: Text("List Sorting"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: model.sortingOptions().map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
          Text(o.label),
          TextButton(
            onPressed: () {
              model.setSort(o, SortDirection.ASC);
              Navigator.of(context).pop();
            },
            child: Text("ASC"),
          ),
          TextButton(
            onPressed: () {
              model.setSort(o, SortDirection.DESC);
              Navigator.of(context).pop();
            },
            child: Text("DESC"),
          ),
        ],)).toList(),
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
