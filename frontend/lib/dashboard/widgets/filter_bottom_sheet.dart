import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final double initialRadius;
  final String initialSortBy;
  final String initialOrder;
  final String initialMinRating;
  final Function(double radius, String sortBy, String order, String minRating) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.initialRadius,
    required this.initialSortBy,
    required this.initialOrder,
    required this.initialMinRating,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _radius;
  late String _sortBy;
  late String _order;
  late String _minRating;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
    _sortBy = widget.initialSortBy;
    _order = widget.initialOrder;
    _minRating = widget.initialMinRating;
  }

  void _reset() {
    setState(() {
      _radius = 50.0;
      _sortBy = 'name';
      _order = 'asc';
      _minRating = 'any';
    });
  }

  Widget _buildChoiceChip(String label, String value, String currentValue, Function(String) onSelect) {
    bool isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter & Sort",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _reset,
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            /// RADIUS
            Text("Search Radius (${_radius.toInt()} km)", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.deepPurple,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.deepPurple,
              ),
              child: Slider(
                value: _radius,
                min: 1,
                max: 100,
                onChanged: (val) {
                  setState(() {
                    _radius = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            /// SORT BY
            const Text("Sort Results By", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              children: [
                _buildChoiceChip("Name", "name", _sortBy, (v) => setState(() => _sortBy = v)),
                _buildChoiceChip("Rating", "rating", _sortBy, (v) => setState(() => _sortBy = v)),
                _buildChoiceChip("Distance", "distance", _sortBy, (v) => setState(() => _sortBy = v)),
              ],
            ),
            const SizedBox(height: 10),

            /// ORDER
            const Text("Order", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              children: [
                _buildChoiceChip("Ascending", "asc", _order, (v) => setState(() => _order = v)),
                _buildChoiceChip("Descending", "desc", _order, (v) => setState(() => _order = v)),
              ],
            ),
            const SizedBox(height: 10),

            /// MIN RATING
            const Text("Minimum Rating", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              children: [
                _buildChoiceChip("Any", "any", _minRating, (v) => setState(() => _minRating = v)),
                _buildChoiceChip("3.0+", "3.0", _minRating, (v) => setState(() => _minRating = v)),
                _buildChoiceChip("4.0+", "4.0", _minRating, (v) => setState(() => _minRating = v)),
                _buildChoiceChip("4.5+", "4.5", _minRating, (v) => setState(() => _minRating = v)),
              ],
            ),
            const SizedBox(height: 30),

            /// APPLY BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_radius, _sortBy, _order, _minRating);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
