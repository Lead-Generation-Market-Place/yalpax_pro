import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdvancedDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<T> items;
  final T? selectedValue;
  final String Function(T)? getLabel;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enableSearch;
  final void Function(String)? onSearchChanged;

  const AdvancedDropdownField({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.selectedValue,
    this.getLabel,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.enableSearch = false,
    this.onSearchChanged,
  });

  @override
  State<AdvancedDropdownField<T>> createState() =>
      _AdvancedDropdownFieldState<T>();
}

class _AdvancedDropdownFieldState<T> extends State<AdvancedDropdownField<T>> {
  late List<T> filteredItems;
  late TextEditingController searchController;
  T? selectedItem;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController = TextEditingController();
    selectedItem = widget.selectedValue;
  }

  @override
  void didUpdateWidget(covariant AdvancedDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != selectedItem) {
      selectedItem = widget.selectedValue;
    }
    filteredItems = widget.items;
  }

  String getItemLabel(T item) {
    return widget.getLabel != null ? widget.getLabel!(item) : item.toString();
  }

  String? _validate(T? val) {
    if (widget.validator != null) return widget.validator!(val);
    if (widget.isRequired && val == null) {
      return '${widget.label ?? "This field"} is required';
    }
    return null;
  }

  void _openDropdownDialog(BuildContext context, FormFieldState<T> field) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.label ?? 'Select an item'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.enableSearch)
                TextField(
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
                      setState(() {
                        filteredItems = widget.items
                            .where((item) => getItemLabel(item)
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      });
                    }
                  },
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  final itemsToShow = widget.onSearchChanged != null
                      ? widget.items
                      : filteredItems;

                  if (itemsToShow.isEmpty) {
                    return const Center(
                      child: Text('No items found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemsToShow.length,
                    itemBuilder: (_, index) {
                      final item = itemsToShow[index];
                      return ListTile(
                        title: Text(getItemLabel(item)),
                        onTap: () {
                          setState(() {
                            selectedItem = item;
                            widget.onChanged?.call(item);
                            field.didChange(item);
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
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
    return FormField<T>(
      validator: _validate,
      initialValue: selectedItem,
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  suffixIcon: selectedItem != null && widget.onChanged != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedItem = null;
                              widget.onChanged?.call(null);
                              field.didChange(null);
                            });
                          },
                        )
                      : const Icon(Icons.arrow_drop_down, size: 24),
                ),
                child: Text(
                  selectedItem != null
                      ? getItemLabel(selectedItem!)
                      : widget.hint ?? 'Select',
                  style: TextStyle(
                    color:
                        selectedItem == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ),
            ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}