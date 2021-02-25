class OutletType {
  String id, category_image_path, category_name;

  OutletType.fromMap(Map<String, dynamic> data, String docId){
    id = docId;
    category_image_path = data['category_image_path'];
    category_name = data['category_name'];
  }
}