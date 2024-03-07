class CardItem {
  final String id;
  final String title;
  final String price;
  final String description;

  final List<String> images;
  int currentIndex;

  CardItem({
    this.currentIndex = 0,
    required this.title,
    required this.price,
    required this.images,
    required this.description,
    required this.id,
  });
}