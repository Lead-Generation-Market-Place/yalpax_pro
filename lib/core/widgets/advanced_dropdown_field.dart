import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdvancedDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<T> items;
  final T? selectedValue;
  final List<T>? selectedValues;
  final String Function(T)? getLabel;
  final void Function(T?)? onChanged;
  final void Function(List<T>)? onMultiChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enableSearch;
  final bool multiSelect;
  final void Function(String)? onSearchChanged;

  const AdvancedDropdownField({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.selectedValue,
    this.selectedValues,
    this.getLabel,
    this.onChanged,
    this.onMultiChanged,
    this.validator,
    this.isRequired = false,
    this.enableSearch = false,
    this.multiSelect = false,
    this.onSearchChanged,
  }) : assert(
         !multiSelect || (selectedValues != null && onMultiChanged != null),
         'For multi-select, selectedValues and onMultiChanged must be provided',
       );

  @override
  State<AdvancedDropdownField<T>> createState() =>
      _AdvancedDropdownFieldState<T>();
}

class _AdvancedDropdownFieldState<T> extends State<AdvancedDropdownField<T>> {
  late TextEditingController searchController;
  final Rx<T?> selectedItem = Rx<T?>(null);
  final RxList<T> selectedItems = <T>[].obs;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    selectedItem.value = widget.selectedValue;
    selectedItems.assignAll(widget.selectedValues ?? []);
  }

  @override
  void didUpdateWidget(covariant AdvancedDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedValue != oldWidget.selectedValue) {
      selectedItem.value = widget.selectedValue;
    }

    if (widget.selectedValues != null &&
        !listEquals(widget.selectedValues, oldWidget.selectedValues)) {
      selectedItems.assignAll(widget.selectedValues!);
    }
  }

  String getItemLabel(T item) {
    return widget.getLabel != null ? widget.getLabel!(item) : item.toString();
  }

  String? _validate(T? val) {
    if (widget.validator != null) return widget.validator!(val);
    if (widget.isRequired &&
        ((!widget.multiSelect && val == null) ||
            (widget.multiSelect && selectedItems.isEmpty))) {
      return '${widget.label ?? "This field"} is required';
    }
    return null;
  }

  Widget _buildListItem(T item, FormFieldState<T?> field) {
    return Obx(() {
      final isSelected = widget.multiSelect
          ? selectedItems.contains(item)
          : selectedItem.value == item;

      return ListTile(
        leading: widget.multiSelect
            ? Checkbox(
                value: isSelected,
                onChanged: (value) {
                  if (value == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                },
              )
            : null,
        title: Text(getItemLabel(item)),
        onTap: widget.multiSelect
            ? () {
                if (selectedItems.contains(item)) {
                  selectedItems.remove(item);
                } else {
                  selectedItems.add(item);
                }
              }
            : () {
                selectedItem.value = item;
                widget.onChanged?.call(item);
                field.didChange(item);
                Navigator.pop(context);
              },
      );
    });
  }

  void _openDropdownDialog(BuildContext context, FormFieldState<T?> field) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                minWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.label ?? 'Select an item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (widget.enableSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) {
                          if (widget.onSearchChanged != null) {
                            widget.onSearchChanged!(query);
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      final itemsToShow = widget.onSearchChanged != null
                          ? widget.items
                          : widget.items.where((item) {
                              return getItemLabel(item).toLowerCase().contains(
                                searchController.text.toLowerCase(),
                              );
                            }).toList();

                      if (itemsToShow.isEmpty) {
                        return const Center(child: Text('No items found'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemsToShow.length,
                        itemBuilder: (_, index) {
                          return _buildListItem(itemsToShow[index], field);
                        },
                      );
                    }),
                  ),
                  if (widget.multiSelect)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              widget.onMultiChanged?.call(selectedItems);
                              field.didChange(
                                selectedItems.isNotEmpty
                                    ? selectedItems.first
                                    : null,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T?>(
      validator: _validate,
      initialValue: selectedItem.value,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  widget.label!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _openDropdownDialog(context, field),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Select',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: field.errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  suffixIcon:
                      (selectedItem.value != null ||
                              selectedItems.isNotEmpty) &&
                          (widget.onChanged != null ||
                              widget.onMultiChanged != null)
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            selectedItem.value = null;
                            selectedItems.clear();
                            widget.onChanged?.call(null);
                            widget.onMultiChanged?.call([]);
                            field.didChange(null);
                          },
                        )
                      : const Icon(Icons.arrow_drop_down, size: 24),
                ),
                child: Obx(
                  () => Text(
                    widget.multiSelect
                        ? selectedItems.isEmpty
                              ? widget.hint ?? 'Select'
                              : selectedItems.length == 1
                              ? getItemLabel(selectedItems.first)
                              : '${selectedItems.length} selected'
                        : selectedItem.value != null
                        ? getItemLabel(selectedItem.value!)
                        : widget.hint ?? 'Select',
                    style: TextStyle(
                      color:
                          (selectedItem.value == null && selectedItems.isEmpty)
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.multiSelect && selectedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Obx(
                  () => Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: selectedItems.map((item) {
                      return Chip(
                        label: Text(getItemLabel(item)),
                        onDeleted: () {
                          selectedItems.remove(item);
                          widget.onMultiChanged?.call(selectedItems);
                          field.didChange(
                            selectedItems.isNotEmpty
                                ? selectedItems.first
                                : null,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
