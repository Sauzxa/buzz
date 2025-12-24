import '../models/category_model.dart';

/// Static fallback categories when API returns no data
final List<CategoryModel> staticCategories = [
  CategoryModel(
    id: 'static_1',
    categoryName: 'Graphic Design',
    description: 'Professional graphic design services',
    categoryColor: '#07A061',
    categoryImage: '', // No image for static categories
  ),
  CategoryModel(
    id: 'static_2',
    categoryName: 'Printing',
    description: 'High-quality printing services',
    categoryColor: '#9747FF',
    categoryImage: '', // No image for static categories
  ),
  CategoryModel(
    id: 'static_3',
    categoryName: 'Audio Visual',
    description: 'Audio and video production services',
    categoryColor: '#D80027',
    categoryImage: '', // No image for static categories
  ),
];
