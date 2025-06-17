import 'package:flutter/material.dart';

class ServiceSearchPage extends StatefulWidget {
  const ServiceSearchPage({Key? key}) : super(key: key);

  @override
  State<ServiceSearchPage> createState() => _ServiceSearchPageState();
}

class _ServiceSearchPageState extends State<ServiceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> allServices = [
    'Haircut',
    'Massage',
    'Facial',
    'Hair Coloring',
    'Beard Trim',
    'Nail Care',
  ];

  String? selectedService;

  List<String> get filteredServices {
    if (selectedService != null) return [];
    final query = _searchController.text.toLowerCase();
    return allServices
        .where((service) => service.toLowerCase().contains(query))
        .toList();
  }

  void _onServiceSelected(String service) {
    setState(() {
      selectedService = service;
      _searchController.text = service;
    });
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  void _onClearSelection() {
    setState(() {
      selectedService = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              readOnly: selectedService != null,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search services...',
                suffixIcon: selectedService != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _onClearSelection,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            if (filteredServices.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredServices.length,
                  itemBuilder: (_, index) {
                    final service = filteredServices[index];
                    return ListTile(
                      title: Text(service),
                      onTap: () => _onServiceSelected(service),
                    );
                  },
                ),
              )
            else if (selectedService == null)
              const Text('No services found'),
          ],
        ),
      ),
    );
  }
}
